import 'package:chat_app/controller/group_chat_controller.dart';
import 'package:chat_app/controller/group_list_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../route/app_pages.dart';
import '../utility/app_constant.dart';
import '../utility/color_constant.dart';
import '../utility/color_extenstion.dart';
import '../utility/common_widgets.dart';

class GroupChatScreen extends StatelessWidget {
  GroupChatScreen({Key? key}) : super(key: key);

  GroupChatController controller = Get.put(GroupChatController());

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Obx(() {
      return Scaffold(
        appBar: widgetAppbar(controller.groupName.value, true),
        body: Container(
          width: double.infinity,
          color: Colors.grey[100],
          child: Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 10.0),
            child: Column(
              children: [
                Flexible(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: controller.collection
                        .collection(AppConstants.pathGroupsCollection)
                        .doc(controller.groupId.value)
                        .collection('chats')
                        .orderBy('time')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return ListView.builder(
                          itemCount: snapshot.data!.docs.length,
                          reverse: false,
                          controller: controller.scrollController,
                          itemBuilder: (context, index) {
                            Map<String, dynamic> chatMap =
                                snapshot.data!.docs[index].data()
                                    as Map<String, dynamic>;

                            if (chatMap['sendBy'] ==
                                controller.currentUserName.value) {
                              return bubbleRight(
                                  chatMap['message'],
                                  chatMap['time'],
                                  chatMap['sendBy'],
                                  controller);
                            } else {
                              return bubbleLeft(
                                  chatMap['message'],
                                  chatMap['time'],
                                  chatMap['sendBy'],
                                  controller);
                            }
                            //return messageTile(size, chatMap, controller);
                          },
                        );
                      } else {
                        return Container();
                      }
                    },
                  ),
                ),
                widgetButtonWithIcon(controller, () {
                  debugPrint('clicked');
                  if (controller.textMsgController.text.isEmpty) {
                    controller.isMsgFieldEmpty.value = true;
                  } else {
                    controller.isMsgFieldEmpty.value = false;
                  }

                  if (!controller.isMsgFieldEmpty.value) {
                    if (kDebugMode) {
                      debugPrint('call send msg ');
                    }
                    controller.onSendMessage();
                    controller.textMsgController.text = '';
                  } else {
                    if (kDebugMode) {
                      debugPrint('else ');
                    }
                  }
                  FocusScope.of(context).requestFocus(FocusNode());
                }),
              ],
            ),
          ),
        ),
      );
    });
  }

  bubbleRight(String text, String timestamp, String userName,
      GroupChatController controller) {
    return Padding(
      padding: const EdgeInsets.only(top: 3.0, bottom: 3.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Flexible(
                child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(48.0),
                      color: Colors.green,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 12, right: 12, top: 8, bottom: 8),
                      child: widgetText(text, 16, ColorConstants.white,
                          AppConstants.fontRegular, FontWeight.w400),
                    )),
              ),
              Container(
                  margin: const EdgeInsets.only(left: 5),
                  height: 25,
                  width: 25,
                  decoration: BoxDecoration(
                    border: Border.all(color: HexColor('#E3E5E5')),
                    borderRadius: const BorderRadius.all(
                      Radius.circular(
                        50.0,
                      ), ////                <--- border radius here
                    ),
                  ),
                  child: Center(
                    child: Text(userName[0].toUpperCase()),
                  ))
            ],
          ),
          Container(
            margin: const EdgeInsets.only(right: 4, top: 6, bottom: 8),
            child: Text(
              DateFormat('dd MMM yyyy, hh:mm a').format(
                DateTime.fromMillisecondsSinceEpoch(
                  int.parse(timestamp),
                ),
              ),
              style: const TextStyle(
                  color: Colors.grey, fontSize: 9, fontStyle: FontStyle.italic),
            ),
          )
        ],
      ),
    );
  }

  bubbleLeft(String text, String timestamp, String userName,
      GroupChatController controller) {
    return Padding(
      padding: const EdgeInsets.only(top: 3.0, bottom: 3.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                  margin: const EdgeInsets.only(right: 5),
                  height: 25,
                  width: 25,
                  decoration: BoxDecoration(
                    border: Border.all(color: HexColor('#E3E5E5')),
                    borderRadius: const BorderRadius.all(
                      Radius.circular(
                        50.0,
                      ), ////                <--- border radius here
                    ),
                  ),
                  child: Center(
                    child: Text(userName[0].toUpperCase()),
                  )),
              Flexible(
                child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(48.0),
                      color: Colors.grey[300],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 12, right: 12, top: 8, bottom: 8),
                      child: widgetText(text, 16, HexColor('#090A0A'),
                          AppConstants.fontRegular, FontWeight.w400),
                    )),
              ),
            ],
          ),
          Container(
            margin: const EdgeInsets.only(left: 4, top: 6, bottom: 8),
            child: Text(
              DateFormat('dd MMM yyyy, hh:mm a').format(
                DateTime.fromMillisecondsSinceEpoch(
                  int.parse(timestamp),
                ),
              ),
              style: const TextStyle(
                  color: Colors.grey, fontSize: 9, fontStyle: FontStyle.italic),
            ),
          )
        ],
      ),
    );
  }

  widgetButtonWithIcon(
      GroupChatController controller, GestureTapCallback? onTap) {
    return Container(
        margin: const EdgeInsets.only(left: 12.0, right: 12.0, bottom: 15.0),
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(48.0),
          color: Colors.transparent,
          border: Border.all(
            color: controller.isMsgFieldEmpty.value ? Colors.red : Colors.green,
            width: 1,
          ),
        ),
        child: Center(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const SizedBox(
                width: 15,
              ),
              Expanded(
                child: TextField(
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.send,
                  //maxLines: null,
                  controller: controller.textMsgController,
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.all(10),
                    border: InputBorder.none,
                    hintText: 'Type your message',
                  ),
                  onSubmitted: (value) {
                    if (controller.textMsgController.text.isEmpty) {
                      controller.isMsgFieldEmpty.value = true;
                    } else {
                      controller.isMsgFieldEmpty.value = false;
                    }

                    if (!controller.isMsgFieldEmpty.value) {
                      if (kDebugMode) {
                        debugPrint('call send msg ');
                      }
                      controller.onSendMessage();
                      controller.textMsgController.text = '';
                    } else {
                      if (kDebugMode) {
                        debugPrint('else ');
                      }
                    }
                  },
                  onChanged: (v) {
                    if (v.isNotEmpty) {
                      controller.isMsgFieldEmpty.value = false;
                    }
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 10, bottom: 2),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: InkWell(
                    onTap: onTap,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Image.asset(
                        'assets/img_send.png',
                        height: 20,
                        width: 20,
                        color: Colors.green,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ));
  }

  Widget messageTile(
      Size size, Map<String, dynamic> chatMap, GroupChatController controller) {
    return Builder(builder: (_) {
      if (chatMap['type'] == "text") {
        return Container(
          width: size.width,
          alignment: chatMap['sendBy'] == controller.currentUserName.value
              ? Alignment.centerRight
              : Alignment.centerLeft,
          child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
              margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Colors.blue,
              ),
              child: Column(
                children: [
                  Text(
                    chatMap['sendBy'],
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(
                    height: size.height / 200,
                  ),
                  Text(
                    chatMap['message'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ],
              )),
        );
      } else if (chatMap['type'] == "img") {
        return Container(
          width: size.width,
          alignment: chatMap['sendBy'] == controller.currentUserName.value
              ? Alignment.centerRight
              : Alignment.centerLeft,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
            margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
            height: size.height / 2,
            child: Image.network(
              chatMap['message'],
            ),
          ),
        );
      } else if (chatMap['type'] == "notify") {
        return Container(
          width: size.width,
          alignment: Alignment.center,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: Colors.black38,
            ),
            child: Text(
              chatMap['message'],
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        );
      } else {
        return const SizedBox();
      }
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
      actions: [
        IconButton(
            onPressed: () {
              Get.toNamed(Routes.addMember, parameters: {
                'grpName': controller.groupName.value,
                'grpId': controller.groupId.value
              });
            },
            icon: const Icon(Icons.person_add_alt_1_outlined)),
        IconButton(
            onPressed: () {
              Get.toNamed(Routes.groupInfo, parameters: {
                'grpName': controller.groupName.value,
                'grpId': controller.groupId.value
              });
            },
            icon: const Icon(Icons.more_vert)),
      ],
    );
  }
}

/*
body: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: size.height / 1.27,
                width: size.width,
                child: StreamBuilder<QuerySnapshot>(
                  stream: controller.collection
                      .collection(AppConstants.pathGroupsCollection)
                      .doc(controller.groupId.value)
                      .collection('chats')
                      .orderBy('time')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return ListView.builder(
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          Map<String, dynamic> chatMap =
                              snapshot.data!.docs[index].data()
                                  as Map<String, dynamic>;

                          return messageTile(size, chatMap, controller);
                        },
                      );
                    } else {
                      return Container();
                    }
                  },
                ),
              ),
              Container(
                height: size.height / 10,
                width: size.width,
                alignment: Alignment.center,
                child: SizedBox(
                  height: size.height / 12,
                  width: size.width / 1.1,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: size.height / 17,
                        width: size.width / 1.3,
                        child: TextField(
                          controller: controller.message,
                          decoration: InputDecoration(
                              suffixIcon: IconButton(
                                onPressed: () {},
                                icon: const Icon(Icons.photo),
                              ),
                              hintText: "Send Message",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              )),
                        ),
                      ),
                      IconButton(
                          icon: const Icon(Icons.send),
                          onPressed: controller.onSendMessage),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
 */
