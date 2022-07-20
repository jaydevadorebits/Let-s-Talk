import 'package:chat_app/controller/add_member_controller.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../utility/app_constant.dart';
import '../utility/common_widgets.dart';

// ignore: must_be_immutable
class AddMemberScreen extends StatelessWidget {
  AddMemberController controller = Get.put(AddMemberController());

  AddMemberScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Scaffold(
          appBar: widgetAppbar(controller.groupName.value, true),
          body: controller.isLoading.value
              ? const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                  ),
                )
              // ignore: invalid_use_of_protected_member
              : controller.usersList.value.length > 1
                  ? ListView.builder(
                      itemCount: controller.usersList.length,
                      itemBuilder: (context, index) {
                        return widgetUserList(
                            controller.usersList[index]['displayName'],
                            controller.usersList[index]['id'],
                            index);
                      },
                    )
                  : const Center(
                      child: Text('No user found'),
                    ));
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

  Widget widgetUserList(String name, String id, int index) {
    if (name.isNotEmpty) {
      //ChatUser userChat = ChatUser.fromDocument(documentSnapshot);
      if (id == controller.currentId.value) {
        return const SizedBox.shrink();
      } else {
        return Column(
          children: [
            Padding(
              padding:
                  const EdgeInsets.only(left: 18.0, right: 15.0, top: 10.0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      name,
                      style: textStyle(16, Colors.black,
                          AppConstants.fontMedium, FontWeight.w400),
                    ),
                  ),
                  Obx(() {
                    return SizedBox(
                      height: 50,
                      width: 50,
                      child: controller.isButtonLoader.value
                          ? const SizedBox(
                              height: 50,
                              width: 50,
                              child: Center(
                                child: SizedBox(
                                  height: 17,
                                  width: 17,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 1.5,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.green),
                                  ),
                                ),
                              ),
                            )
                          : IconButton(
                              onPressed: () {
                                debugPrint('index-' + index.toString());
                                controller.addMember(name, id, index);
                              },
                              icon: const Icon(Icons.add)),
                    );
                  })
                ],
              ),
            ),
            const Divider(),
          ],
        );
      }
    } else {
      return const SizedBox.shrink();
    }
  }
}

/*
body: StreamBuilder<QuerySnapshot>(
            stream: controller.getFirestoreData(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasData) {
                if ((snapshot.data?.docs.length ?? 0) > 0) {
                  return ListView.separated(
                      shrinkWrap: true,
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) =>
                          widgetUserList(snapshot.data?.docs[index], index),
                      //buildItem(context, snapshot.data?.docs[index]),

                      separatorBuilder: (BuildContext context, int index) {
                        return Container();
                      });
                } else {
                  return const Center(
                    child: Text('Invite friends to chat with him.'),
                  );
                }
              } else {
                return const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                  ),
                );
              }
            },
          )
 */
