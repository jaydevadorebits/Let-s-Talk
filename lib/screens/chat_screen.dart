import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../controller/chat_controller.dart';
import '../model/chat_messages.dart';
import '../route/app_pages.dart';
import '../utility/app_constant.dart';
import '../utility/color_constant.dart';
import '../utility/color_extenstion.dart';
import '../utility/common_widgets.dart';

class ChatScreen extends StatelessWidget {
  final ChatController _controller = Get.put(ChatController());

  ChatScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Scaffold(
        appBar: widgetAppbar(_controller.title.value, true, _controller),
        body: Container(
          width: double.infinity,
          color: Colors.grey[100],
          child: Column(
            children: [
              Flexible(
                child: _controller.groupChatId.isNotEmpty
                    ? StreamBuilder<QuerySnapshot>(
                        stream: _controller.getChatMessage(
                            _controller.groupChatId.value,
                            _controller.limit.value),
                        builder: (BuildContext context,
                            AsyncSnapshot<QuerySnapshot> snapshot) {
                          if (snapshot.hasData) {
                            _controller.listMessages.value =
                                snapshot.data!.docs;
                            if (_controller.listMessages.isNotEmpty) {
                              return ListView.builder(
                                  padding: const EdgeInsets.all(10),
                                  itemCount: snapshot.data?.docs.length,
                                  reverse: true,
                                  controller: _controller.scrollController,
                                  itemBuilder: (context, index) => buildItem(
                                      index,
                                      snapshot.data?.docs[index],
                                      _controller));
                            } else {
                              return const Center(
                                child: Text('No messages...'),
                              );
                            }
                          } else {
                            return const Center(
                              child: CircularProgressIndicator(
                                color: Colors.green,
                              ),
                            );
                          }
                        })
                    : const Center(
                        child: CircularProgressIndicator(
                          color: Colors.green,
                        ),
                      ),
              ),
              widgetButtonWithIcon(_controller, () {
                debugPrint('clicked');
                if (_controller.textMsgController.text.isEmpty) {
                  _controller.isMsgFieldEmpty.value = true;
                } else {
                  _controller.isMsgFieldEmpty.value = false;
                }

                if (!_controller.isMsgFieldEmpty.value) {
                  if (kDebugMode) {
                    print('call send msg ');
                  }
                  _controller.onSendMessage(
                      _controller.textMsgController.text, 0);
                  _controller.textMsgController.text = '';
                } else {
                  if (kDebugMode) {
                    print('else ');
                  }
                }
                FocusScope.of(context).requestFocus(FocusNode());
              })
            ],
          ),
        ),
      );
    });
  }

  widgetButtonWithIcon(ChatController controller, GestureTapCallback? onTap) {
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
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  controller: controller.textMsgController,
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.all(10),
                    border: InputBorder.none,
                    hintText: 'Type your message',
                  ),
                  onChanged: (v) {
                    if (v.isNotEmpty) {
                      controller.isMsgFieldEmpty.value = false;
                    }
                  },
                ),
              ),
              IconButton(
                onPressed: () {
                  debugPrint('call image');
                  _controller.getImage();
                },
                icon: const Icon(
                  Icons.camera_alt,
                  size: 26,
                ),
                color: Colors.green,
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

  widgetAppbar(
    String title,
    bool isBack,
    ChatController controller,
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
      title: StreamBuilder<DocumentSnapshot>(
        stream: _controller.collection
            .collection(AppConstants.pathUserCollection)
            .doc(controller.peerId.value)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.data != null) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  snapshot.data!['displayName'],
                  style: textStyle(17, Colors.white, AppConstants.fontMedium,
                      FontWeight.w400),
                ),
                Text(
                  snapshot.data!['status'].toString(),
                  style: textStyle(11, Colors.white, AppConstants.fontMedium,
                      FontWeight.w400),
                ),
              ],
            );
          } else {
            return Container();
          }
        },
      ),
    );
  }

  bubbleRight(
      String text, String timestamp, ChatController controller, int type) {
    return InkWell(
      onTap: () {
        debugPrint('msg-' + text);
      },
      child: Padding(
        padding: const EdgeInsets.only(top: 3.0, bottom: 3.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Flexible(
                  child: type == MessageType.image
                      ? Container(
                          margin: const EdgeInsets.all(0.0),
                          child: chatImage(
                              imageSrc: text,
                              onTap: () {
                                Get.toNamed(Routes.imageView, parameters: {
                                  'imageUrl': text,
                                });
                              }),
                        )
                      : Container(
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
                      child: Text(
                          controller.currentUserName.value[0].toUpperCase()),
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
                    color: Colors.grey,
                    fontSize: 9,
                    fontStyle: FontStyle.italic),
              ),
            )
          ],
        ),
      ),
    );
  }

  bubbleLeft(
      String text, String timestamp, ChatController controller, int type) {
    return InkWell(
      onTap: () {
        debugPrint('msg-' + text);
      },
      child: Padding(
        padding: const EdgeInsets.only(top: 3.0, bottom: 3.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
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
                      child: Text(_controller.title.value[0].toUpperCase()),
                    )),
                Flexible(
                  child: type == MessageType.image
                      ? chatImage(
                          imageSrc: text,
                          onTap: () {
                            Get.toNamed(Routes.imageView, parameters: {
                              'imageUrl': text,
                            });
                          })
                      : Container(
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
                    color: Colors.grey,
                    fontSize: 9,
                    fontStyle: FontStyle.italic),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget buildItem(int index, DocumentSnapshot? documentSnapshot,
      ChatController controller) {
    if (documentSnapshot != null) {
      ChatMessages chatMessages = ChatMessages.fromDocument(documentSnapshot);
      if (chatMessages.idFrom == controller.currentUserId.value) {
        // right side (my message)
        return bubbleRight(chatMessages.content, chatMessages.timestamp,
            controller, chatMessages.type);
      } else {
        return bubbleLeft(chatMessages.content, chatMessages.timestamp,
            controller, chatMessages.type);
      }
    } else {
      return const SizedBox.shrink();
    }
  }


}
