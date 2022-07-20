import 'package:chat_app/controller/base_controller.dart';
import 'package:chat_app/utility/app_constant.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

import '../route/app_pages.dart';

class GroupInfoController extends BaseController {
  BuildContext context;

  GroupInfoController({required this.context});

  RxString groupName = ''.obs;
  RxString groupId = ''.obs;

  RxString currentId = ''.obs;
  RxString currentUserName = ''.obs;

  var collection = FirebaseFirestore.instance;

  List membersList = [];

  @override
  void onInit() {
    User? user = FirebaseAuth.instance.currentUser;

    debugPrint('userDataGrpInfo1-' + user!.uid.toString());

    currentId.value = user.uid.toString();
    currentUserName.value = user.displayName.toString();
    debugPrint(
        'userDataGrpInfo2-' + currentId.value + ' ' + currentUserName.value);

    groupName.value = Get.parameters['grpName'].toString();
    groupId.value = Get.parameters['grpId'].toString();

    debugPrint('groupGrpInfo-' + groupName.value + ' ' + groupId.value);

    super.onInit();

    getGroupDetails();
  }

  Future getGroupDetails() async {
    isLoading.value = true;
    await collection
        .collection(AppConstants.pathGroupsCollection)
        .doc(groupId.value)
        .get()
        .then((chatMap) {
      membersList = chatMap['members'];
      debugPrint('grpDetails-' + membersList.length.toString());
      isLoading.value = false;
      update();
    });
  }

  Future removeMembers(int index) async {
    String uid = membersList[index]['id'];

    isLoading.value = true;
    membersList.removeAt(index);

    await collection
        .collection(AppConstants.pathGroupsCollection)
        .doc(groupId.value)
        .update({
      "members": membersList,
    }).then((value) async {
      await collection
          .collection(AppConstants.pathUserCollection)
          .doc(uid)
          .collection(AppConstants.pathGroupsCollection)
          .doc(groupId.value)
          .delete();

      isLoading.value = false;
      update();
    });
  }

  void showDialogBox(int index) {
    if (checkAdmin()) {
      if (currentId.value != membersList[index]['id']) {
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                content: ListTile(
                  onTap: () => removeMembers(index),
                  title: const Text("Remove This Member"),
                ),
              );
            });
      }
    }
  }

  Future onLeaveGroup() async {
    debugPrint('call leave grp method');
    if (!checkAdmin()) {
      isLoading.value = true;

      for (int i = 0; i < membersList.length; i++) {
        if (membersList[i]['id'] == currentId.value) {
          membersList.removeAt(i);
        }
      }

      await collection
          .collection(AppConstants.pathGroupsCollection)
          .doc(groupId.value)
          .update({
        "members": membersList,
      }).whenComplete(() {
        debugPrint('deleteUpdateList-');
      });

      await collection
          .collection(AppConstants.pathUserCollection)
          .doc(currentId.value)
          .collection(AppConstants.pathGroupsCollection)
          .doc(groupId.value)
          .delete()
          .whenComplete(() {
        debugPrint('deleted grp success-');
        debugPrint('deleted- ' + currentId.value);
        debugPrint('deleted- ' + AppConstants.pathUserCollection);
        debugPrint('deleted- ' + groupId.value);
        Fluttertoast.showToast(
            msg: groupName.value + ' Deleted.', backgroundColor: Colors.grey);
        Get.offNamedUntil(Routes.home, (route) => false);
      });
    } else {
      debugPrint('call leave grp elase');

      isLoading.value = true;

      for (int i = 0; i < membersList.length; i++) {
        if (membersList[i]['id'] == currentId.value) {
          membersList.removeAt(i);
        }
      }

      await collection
          .collection(AppConstants.pathGroupsCollection)
          .doc(groupId.value)
          .update({
        "members": membersList,
      }).whenComplete(() {
        debugPrint('deleteUpdateList-');
      });

      await collection
          .collection(AppConstants.pathUserCollection)
          .doc(currentId.value)
          .collection(AppConstants.pathGroupsCollection)
          .doc(groupId.value)
          .delete()
          .whenComplete(() {
        debugPrint('deleted grp success-');
        debugPrint('deleted- ' + currentId.value);
        debugPrint('deleted- ' + AppConstants.pathUserCollection);
        debugPrint('deleted- ' + groupId.value);
        Get.offNamedUntil(Routes.home, (route) => false);
        Fluttertoast.showToast(
            msg: groupName.value + ' Deleted.', backgroundColor: Colors.grey);
      });
    }
  }

  bool checkAdmin() {
    bool isAdmin = false;

    for (var element in membersList) {
      if (element['id'] == currentId.value) {
        isAdmin = element['isAdmin'];
      }
    }
    return isAdmin;
  }
}
