import 'package:chat_app/controller/group_info_controller.dart';
import 'package:chat_app/route/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../utility/app_constant.dart';
import '../utility/common_widgets.dart';

// ignore: must_be_immutable
class GroupInfoScreen extends StatelessWidget {
  GroupInfoScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    GroupInfoController controller =
        Get.put(GroupInfoController(context: context));
    return Obx(() {
      return SafeArea(
        child: Scaffold(
          appBar: widgetAppbar('Group Info', true),
          body: controller.isLoading.value
              ? Container(
                  height: size.height,
                  width: size.width,
                  alignment: Alignment.center,
                  child: const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: size.height / 8,
                        width: size.width / 1.1,
                        child: Row(
                          children: [
                            Container(
                              height: size.height / 11,
                              width: size.height / 11,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.grey,
                              ),
                              child: Icon(
                                Icons.group,
                                color: Colors.white,
                                size: size.width / 10,
                              ),
                            ),
                            SizedBox(
                              width: size.width / 20,
                            ),
                            Expanded(
                              child: Text(
                                controller.groupName.value,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: size.width / 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(
                        height: size.height / 20,
                      ),

                      SizedBox(
                        width: size.width / 1.1,
                        child: Text(
                          "${controller.membersList.length} Members",
                          style: TextStyle(
                            fontSize: size.width / 20,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),

                      SizedBox(
                        height: size.height / 20,
                      ),

                      // Members Name

                      controller.checkAdmin()
                          ? ListTile(
                              onTap: () {},
                              leading: const Icon(
                                Icons.add,
                              ),
                              title: Text(
                                "Add Members",
                                style: TextStyle(
                                  fontSize: size.width / 22,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            )
                          : const SizedBox(),

                      Flexible(
                        child: ListView.builder(
                          itemCount: controller.membersList.length,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            return ListTile(
                              onTap: () {
                                controller.showDialogBox(index);
                                Get.back();
                              },
                              leading: const Icon(Icons.account_circle),
                              title: Text(
                                controller.membersList[index]['displayName'],
                                style: TextStyle(
                                  fontSize: size.width / 22,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              subtitle: Text(
                                  controller.membersList[index]['displayName']),
                              trailing: Text(controller.membersList[index]
                                      ['isAdmin']
                                  ? "Admin"
                                  : ""),
                            );
                          },
                        ),
                      ),

                      ListTile(
                        onTap: () {
                          controller.onLeaveGroup();
                        },
                        leading: const Icon(
                          Icons.logout,
                          color: Colors.redAccent,
                        ),
                        title: Text(
                          "Leave Group",
                          style: TextStyle(
                            fontSize: size.width / 22,
                            fontWeight: FontWeight.w500,
                            color: Colors.redAccent,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
        ),
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
      /*actions: [
        IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert)),
      ],*/
    );
  }
}
