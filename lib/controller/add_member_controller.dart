import 'package:chat_app/controller/base_controller.dart';
import 'package:chat_app/utility/app_constant.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

class AddMemberController extends BaseController {
  RxString groupName = ''.obs;
  RxString groupId = ''.obs;

  RxString currentId = ''.obs;
  RxString currentUserName = ''.obs;

  var collection = FirebaseFirestore.instance;

  List<Map<String, dynamic>> membersList = [];
  List membersListAlreadyInGrp = [];
  RxList usersList = [].obs;

  RxBool isButtonLoader = false.obs;

  @override
  void onInit() {
    User? user = FirebaseAuth.instance.currentUser;

    debugPrint('userDataAddM1-' + user!.uid.toString());

    currentId.value = user.uid.toString();
    currentUserName.value = user.displayName.toString();
    debugPrint(
        'userDataAddM2-' + currentId.value + ' ' + currentUserName.value);

    groupName.value = Get.parameters['grpName'].toString();
    groupId.value = Get.parameters['grpId'].toString();

    debugPrint('groupChat-' + groupName.value + ' ' + groupId.value);
    super.onInit();

    getAllGroupMember();
  }

  void getAllGroupMember() async {
    isLoading.value = true;
    await collection
        .collection(AppConstants.pathGroupsCollection)
        .doc(groupId.value)
        .get()
        .then((chatMap) {
      membersListAlreadyInGrp = chatMap['members'];
      //membersList = chatMap['members'];
      debugPrint('totalGrpMember-' +
          membersListAlreadyInGrp.length.toString() +
          ' ' +
          membersList.length.toString());
      //getAllMember();
      getAllUsers();
    });
  }

  void getAllMember() async {
    await collection
        .collection(AppConstants.pathUserCollection)
        .get()
        .then((chatMap) {
      debugPrint('totalAllMember-' +
          chatMap.docs.length.toString() +
          ' ' +
          chatMap.docs[0]['displayName'].toString());

      if (chatMap.docs.length > 0 || membersListAlreadyInGrp.length > 0) {
        for (int i = 0; i < chatMap.docs.length; i++) {
          debugPrint('TotalName-' + chatMap.docs[i]['displayName']);
          if (chatMap.docs[i]['id'] != membersListAlreadyInGrp[i]['id']) {
            debugPrint('alreadyInGrp-' + chatMap.docs[i]['displayName']);
          } else {
            debugPrint('NeedToAddInGrp-' + chatMap.docs[i]['displayName']);
          }
        }
      } else {
        debugPrint('no member found');
      }
    });
  }

  Stream<QuerySnapshot> getFirestoreData() {
    return collection
        .collection(AppConstants.pathUserCollection)
        .limit(20)
        .where(AppConstants.displayName)
        .snapshots();
  }

  void getAllUsers() async {

    debugPrint('call_getAllUsers');
    await collection
        .collection(AppConstants.pathUserCollection)
        .get()
        .then((value) {
      usersList.value = value.docs;
      isLoading.value = false;
      debugPrint('totalUsers-' + usersList.length.toString());
    });
  }

  void addMember(String name, String id, int index) async {
    bool isAlreadyExist = false;
    debugPrint(name + ' ' + id + ' ' + index.toString());
    isButtonLoader.value = true;

    debugPrint('totalGrpMember-' +
        membersListAlreadyInGrp.length.toString() +
        ' ' +
        membersList.length.toString());

    debugPrint('totalUsers-' + usersList.length.toString());

    for (int i = 0; i < membersListAlreadyInGrp.length; i++) {
      if (membersListAlreadyInGrp[i]['id'] == id) {
        isAlreadyExist = true;
        isButtonLoader.value = false;
        Fluttertoast.showToast(
            msg: name + ' You are already in group.',
            backgroundColor: Colors.grey);
        debugPrint(
            'userIsAlreadyInGrp-' + membersListAlreadyInGrp[i]['displayName']);
      }
    }

    if (!isAlreadyExist) {
      membersListAlreadyInGrp.add({
        "displayName": name,
        "id": id,
        "isAdmin": false,
      });
      debugPrint(name + ' added');

      await collection
          .collection(AppConstants.pathGroupsCollection)
          .doc(groupId.value)
          .update({
        "members": membersListAlreadyInGrp,
      }).whenComplete(() async {
        debugPrint('added');
        Fluttertoast.showToast(
            msg: name + ' Added', backgroundColor: Colors.grey);
        isButtonLoader.value = false;
        usersList.removeAt(index);
        usersList.refresh();

        await collection
            .collection(AppConstants.pathUserCollection)
            .doc(id)
            .collection(AppConstants.pathGroupsCollection)
            .doc(groupId.value)
            .set({"name": groupName.value, "id": groupId.value});
      });
    }

    debugPrint('totalUsers-' + usersList.length.toString());

    update();
  }
}
