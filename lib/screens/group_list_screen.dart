import 'package:chat_app/utility/common_widgets.dart';
import 'package:chat_app/utility/keyboard_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/group_list_controller.dart';
import '../route/app_pages.dart';
import '../utility/app_constant.dart';

class GroupListScreen extends StatelessWidget {
  final GroupListController controller = Get.put(GroupListController());

  GroupListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Obx(() {
      return Scaffold(
        appBar: widgetAppbar('Groups', true),
        body: controller.isLoading.value
            ? Container(
                height: size.height,
                width: size.width,
                alignment: Alignment.center,
                child: const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                ),
              )
            : ListView.builder(
                itemCount: controller.groupList.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    onTap: () {
                      Get.toNamed(Routes.groupChat, parameters: {
                        'grpName':
                            controller.groupList[index]['name'].toString(),
                        'grpId': controller.groupList[index]['id'].toString(),
                      });
                    },
                    leading: const Icon(Icons.group),
                    title: Text(controller.groupList[index]['name']),
                  );
                },
              ),
        floatingActionButton: FloatingActionButton(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            tooltip: 'Create Group',
            child: const Icon(Icons.edit),
            onPressed: () {
              createGroupDialog(context);
            }),
      );
    });
  }

  widgetAppbar(
    String title,
    bool isBack,
  ) {
    return AppBar(
      foregroundColor: Colors.white,
      backgroundColor: Colors.green,
      elevation: 0.0,
      leading: isBack
          ? BackButton(
              onPressed: () {
                Get.back(result: 'false');
              },
            )
          : null,
      title: Text(
        title,
        style: textStyle(
            17, Colors.white, AppConstants.fontMedium, FontWeight.w400),
      ),
    );
  }

  void createGroupDialog(BuildContext context) {
    TextEditingController _textFieldController = TextEditingController();

    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Add Group Name'),
            content: TextField(
              controller: _textFieldController,
              decoration: const InputDecoration(hintText: "Name"),
            ),
            actions: [
              // ignore: deprecated_member_use
              FlatButton(
                child: Text(
                  'Cancel',
                  style: textStyle(
                      14, Colors.red, AppConstants.fontMedium, FontWeight.w400),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              // ignore: deprecated_member_use
              FlatButton(
                child: Text(
                  'Create',
                  style: textStyle(14, Colors.green, AppConstants.fontMedium,
                      FontWeight.w400),
                ),
                onPressed: () {
                  if (_textFieldController.text.isEmpty) {
                    debugPrint('enter group name');
                  } else {
                    debugPrint('create group success');
                    if (KeyboardUtils.isKeyboardShowing()) {
                      KeyboardUtils.closeKeyboard(context);
                    }
                    controller
                        .createGroup(_textFieldController.text)
                        .whenComplete(() {});
                    Navigator.of(context).pop();
                  }
                },
              )
            ],
          );
        });
  }
}
