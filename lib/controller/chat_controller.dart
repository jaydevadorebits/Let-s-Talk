import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:chat_app/controller/base_controller.dart';
import 'package:chat_app/model/chat_messages.dart';
import 'package:chat_app/utility/app_constant.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class ChatController extends BaseController {
  late TextEditingController textMsgController;

  final ScrollController scrollController = ScrollController();
  final FocusNode focusNode = FocusNode();

  late RxString currentUserProfile = ''.obs;
  late RxString currentUserName = ''.obs;
  late RxString currentUserId = ''.obs;
  late RxString peerId = ''.obs;
  late RxString title = ''.obs;
  late RxString peerProfile = ''.obs;

  RxList<QueryDocumentSnapshot> listMessages = <QueryDocumentSnapshot>[].obs;

  RxInt limit = 20.obs;
  final RxInt limitIncrement = 20.obs;
  RxString groupChatId = ''.obs;

  // validation
  RxBool isMsgFieldEmpty = false.obs;

  File? imageFile;
  String imageUrl = '';

  RxString userToken = "".obs;

  var collection = FirebaseFirestore.instance;
  final FirebaseStorage firebaseStorage = FirebaseStorage.instance;

  @override
  void onInit() {
    User? user = FirebaseAuth.instance.currentUser;

    debugPrint('userDataChat-' + user!.uid.toString());

    textMsgController = TextEditingController();

    focusNode.addListener(onFocusChanged);
    scrollController.addListener(scrollListener);

    super.onInit();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.bottom, SystemUiOverlay.top]);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.green,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ));

    currentUserProfile.value = user.photoURL.toString();
    currentUserName.value = user.displayName.toString();
    currentUserId.value = Get.parameters['userId'].toString();
    peerId.value = Get.parameters['peerId'].toString();
    title.value = Get.parameters['name'].toString();
    peerProfile.value = Get.parameters['peerProfile'].toString();
    userToken.value = Get.parameters['userToken'].toString();

    debugPrint('userId-' + currentUserId.value);
    debugPrint('peerId-' + peerId.value);
    debugPrint('userToken-' + userToken.value);

    if (currentUserId.value.compareTo(peerId.value) > 0) {
      debugPrint('compare if');
      groupChatId.value = '${currentUserId.value} - ${peerId.value}';
    } else {
      debugPrint('compare else');
      groupChatId.value = '${peerId.value} - ${currentUserId.value}';
    }

    debugPrint('groupId-' + groupChatId.value);
    updateFirestoreData(AppConstants.pathUserCollection, currentUserId.value,
        {AppConstants.chattingWith: peerId.value});
  }

  Stream<QuerySnapshot> getChatMessage(String groupChatId, int limit) {
    debugPrint('groupId-' + groupChatId);
    return collection
        .collection(AppConstants.pathMessageCollection)
        .doc(groupChatId)
        .collection(groupChatId)
        .orderBy(AppConstants.timestamp, descending: true)
        .limit(limit)
        .snapshots();
  }

  Stream<DocumentSnapshot> getUserStatus() {
    return collection
        .collection(AppConstants.pathMessageCollection)
        .doc(peerId.value)
        .snapshots();
  }

  void onSendMessage(String content, int type) {
    if (content.trim().isNotEmpty) {
      textMsgController.clear();
      sendChatMessage(
          content, type, groupChatId.value, currentUserId.value, peerId.value);
      scrollController.animateTo(0,
          duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      sendNotification();
    } else {
      Fluttertoast.showToast(
          msg: 'Nothing to send', backgroundColor: Colors.grey);
    }
  }

  void sendNotification() async {
    debugPrint("click send notification testing");
    debugPrint("userToken-" + userToken.value);
    var params = {
      "to": userToken.value,
      "notification": {
        "title": title.value,
        "body": "New message arrive.",
        "sound": "default",
      },
      "data": {"customId": "01", "badge": 0, "alert": "Alert"}
    };

    var url = 'https://fcm.googleapis.com/fcm/send';

    var response = await http.post(Uri.parse(url),
        headers: {
          "Authorization":
              "Key=AAAA7Z4cA3s:APA91bFkhAGVFCIDJXB9ttwpCYm0GtlcToMjubQjw0bcxioMx7h6A4KDNB-V8qH6tHmcsKq1lZe7ulCGoW9ZNcrz-kAYwGtz9moit7MBppino6xYL_TwEqeOYrAg_P9kqWRyazIF91H-",
          'Charset': 'utf-8',
          "Content-Type": "application/json;charset=UTF-8"
        },
        body: json.encode(params));

    if (response.statusCode == 200) {
      Map<String, dynamic> map = json.decode(response.body);
      debugPrint("fcm.google: " + map.toString());
    } else {
      Map<String, dynamic> error = jsonDecode(response.body);
      debugPrint("fcm.google: " + error.toString());
    }
  }

  void sendChatMessage(String content, int type, String groupChatId,
      String currentUserId, String peerId) {
    DocumentReference documentReference = collection
        .collection(AppConstants.pathMessageCollection)
        .doc(groupChatId)
        .collection(groupChatId)
        .doc(DateTime.now().millisecondsSinceEpoch.toString());
    ChatMessages chatMessages = ChatMessages(
        idFrom: currentUserId,
        idTo: peerId,
        timestamp: DateTime.now().millisecondsSinceEpoch.toString(),
        content: content,
        type: type);

    FirebaseFirestore.instance.runTransaction((transaction) async {
      transaction.set(documentReference, chatMessages.toJson());
    }).whenComplete(() {});
  }

  scrollListener() {
    if (scrollController.offset >= scrollController.position.maxScrollExtent &&
        !scrollController.position.outOfRange) {
      limit.value += limitIncrement.value;
      update();
    }
  }

  void onFocusChanged() {
    if (focusNode.hasFocus) {
      //isShowSticker = false;
    }
  }

  Future<void> updateFirestoreData(
      String collectionPath, String docPath, Map<String, dynamic> dataUpdate) {
    return collection
        .collection(collectionPath)
        .doc(docPath)
        .update(dataUpdate);
  }

  Future getImage() async {
    ImagePicker imagePicker = ImagePicker();
    XFile? pickedFile;
    pickedFile = await imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      imageFile = File(pickedFile.path);
      if (imageFile != null) {
        debugPrint('file-' + imageFile!.path.toString());
        isLoading.value = true;
        uploadImageFile();
      }
    }
  }

  void uploadImageFile() async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    UploadTask uploadTask = uploadImageFileTask(imageFile!, fileName);
    try {
      TaskSnapshot snapshot = await uploadTask;
      imageUrl = await snapshot.ref.getDownloadURL();
      isLoading.value = false;
      onSendMessage(imageUrl, MessageType.image);
    } on FirebaseException catch (e) {
      isLoading.value = false;
      Fluttertoast.showToast(msg: e.message ?? e.toString());
    }
  }

  UploadTask uploadImageFileTask(File image, String filename) {
    Reference reference = firebaseStorage.ref().child(filename);
    UploadTask uploadTask = reference.putFile(image);
    return uploadTask;
  }
}

class MessageType {
  static const text = 0;
  static const image = 1;
  static const sticker = 2;
}
