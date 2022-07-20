import 'package:chat_app/controller/base_controller.dart';
import 'package:chat_app/utility/app_constant.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GroupChatController extends BaseController {
  RxString groupName = ''.obs;
  RxString groupId = ''.obs;

  RxString currentId = ''.obs;
  RxString currentUserName = ''.obs;

  RxInt limit = 20.obs;
  final RxInt limitIncrement = 20.obs;

  final ScrollController scrollController = ScrollController();
  final TextEditingController textMsgController = TextEditingController();

  // validation
  RxBool isMsgFieldEmpty = false.obs;

  var collection = FirebaseFirestore.instance;

  @override
  void onInit() {
    User? user = FirebaseAuth.instance.currentUser;

    debugPrint('userDataGrpChat1-' + user!.uid.toString());

    super.onInit();
  }

  scrollListener() {
    if (scrollController.offset >= scrollController.position.maxScrollExtent &&
        !scrollController.position.outOfRange) {
      limit.value += limitIncrement.value;
      update();
    }
  }

  void onSendMessage() async {
    if (textMsgController.text.isNotEmpty) {
      Map<String, dynamic> chatData = {
        "sendBy": currentUserName.value,
        "message": textMsgController.text,
        "type": "text",
        "time": DateTime.now().millisecondsSinceEpoch.toString(),
      };
      scrollController.animateTo(0,
          duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      textMsgController.clear();

      await collection
          .collection(AppConstants.pathGroupsCollection)
          .doc(groupId.value)
          .collection('chats')
          .add(chatData);
    }
  }

/*void onSendMessage1(String content, int type) {
    if (content.trim().isNotEmpty) {
      textMsgController.clear();
      sendChatMessage(
          content, type, groupChatId.value, currentUserId.value, peerId.value);
      scrollController.animateTo(0,
          duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    } else {
      Fluttertoast.showToast(
          msg: 'Nothing to send', backgroundColor: Colors.grey);
    }
  }*/

}
