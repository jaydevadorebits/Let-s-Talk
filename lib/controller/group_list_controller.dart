import 'package:chat_app/controller/base_controller.dart';
import 'package:chat_app/utility/app_constant.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

class GroupListController extends BaseController {
  List<Map<String, dynamic>> membersList = [];

  RxString currentId = ''.obs;
  RxString currentUserName = ''.obs;
  var collection = FirebaseFirestore.instance;
  Map<String, dynamic>? userMap;

  List groupList = [];

  @override
  void onInit() {
    User? user = FirebaseAuth.instance.currentUser;

    debugPrint('userDataGrpList1-' + user!.uid.toString());

    currentId.value = user.uid.toString();
    currentUserName.value = user.displayName.toString();
    debugPrint(
        'userDataGrpList2-' + currentId.value + ' ' + currentUserName.value);

    super.onInit();

    getCurrentUserDetails();
  }

  void getCurrentUserDetails() async {
    await collection
        .collection(AppConstants.pathUserCollection)
        .doc(currentId.value)
        .get()
        .then((map) {
      membersList.add({
        "displayName": map['displayName'],
        "id": map['id'],
        "isAdmin": true,
      });
      debugPrint('currentUser-' + map['displayName']);
      getAvailableGroups();
    });
  }

  void getAvailableGroups() async {
    isLoading.value = true;
    await collection
        .collection(AppConstants.pathUserCollection)
        .doc(currentId.value)
        .collection(AppConstants.pathGroupsCollection)
        .get()
        .then((value) {
      groupList = value.docs;
      isLoading.value = false;
      update();
    });
  }

  Future createGroup(String groupName) async {
    isLoading.value = true;
    String groupId = const Uuid().v1();

    await collection
        .collection(AppConstants.pathGroupsCollection)
        .doc(groupId)
        .set({
      "members": membersList,
      "id": groupId,
    });

    for (int i = 0; i < membersList.length; i++) {
      String uid = membersList[i]['id'];

      await collection
          .collection(AppConstants.pathUserCollection)
          .doc(uid)
          .collection(AppConstants.pathGroupsCollection)
          .doc(groupId)
          .set({
        "name": groupName,
        "id": groupId,
      }).whenComplete(() {
        debugPrint('grpName-' + groupName);
        isLoading.value = false;
        getAvailableGroups();
      });
    }

    await collection
        .collection(AppConstants.pathGroupsCollection)
        .doc(groupId)
        .collection('chats')
        .add({
      "message": "${currentUserName.value} Created This Group.",
      "type": "notify",
    });

    //Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => HomeScreen()), (route) => false);
  }
}
