import 'package:chat_app/controller/home_controller.dart';
import 'package:chat_app/route/app_pages.dart';
import 'package:chat_app/utility/app_constant.dart';
import 'package:chat_app/utility/common_widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../model/user_mode.dart';
import '../utility/keyboard_utils.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final HomeController _controller =
        Get.put(HomeController(context: context));
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.green,
        body: SizedBox(
          width: double.infinity,
          child: Column(
            children: [
              SizedBox(
                height: 150,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 24.0, left: 12.0),
                          child: Text(
                            "Let's Talk",
                            style: textStyle(32, Colors.white,
                                AppConstants.fontBold, FontWeight.w400),
                          ),
                        ),
                        Padding(
                          padding:
                              const EdgeInsets.only(top: 24.0, right: 12.0),
                          child: IconButton(
                              onPressed: () {
                                openDialog(_controller);
                              },
                              icon: const Icon(
                                Icons.logout,
                                color: Colors.white,
                              )),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 13,
                    ),
                    widgetSearch(),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(25),
                      topLeft: Radius.circular(25),
                    ),
                    color: Colors.white,
                  ),
                  child: StreamBuilder<QuerySnapshot>(
                    stream: _controller.getFirestoreData(
                        AppConstants.pathUserCollection,
                        _controller.limit.value,
                        ''),
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.hasData) {
                        if ((snapshot.data?.docs.length ?? 0) > 0) {
                          return ListView.separated(
                              shrinkWrap: true,
                              itemCount: snapshot.data!.docs.length,
                              itemBuilder: (context, index) => buildItem(
                                  context,
                                  snapshot.data?.docs[index],
                                  _controller),
                              controller: _controller.scrollController,
                              separatorBuilder:
                                  (BuildContext context, int index) {
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
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.green),
                          ),
                        );
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildItem(BuildContext context, DocumentSnapshot? documentSnapshot,
      HomeController _controller) {
    if (documentSnapshot != null) {
      ChatUser userChat = ChatUser.fromDocument(documentSnapshot);
      if (userChat.id == _controller.currentId.value) {
        return const SizedBox.shrink();
      } else {
        return TextButton(
          onPressed: () {
            if (KeyboardUtils.isKeyboardShowing()) {
              KeyboardUtils.closeKeyboard(context);
            }
            debugPrint(
                'Navigate to chat screen ' + documentSnapshot['deviceToken']);
            debugPrint('Navigate to chat screen ' +
                userChat.deviceToken +
                ' ' +
                userChat.displayName);
            //Get.toNamed(Routes.chatDetail);
            Get.toNamed(Routes.chatDetail, parameters: {
              'userId': _controller.currentId.value,
              'peerId': userChat.id,
              'name': userChat.displayName,
              'peerProfile': userChat.photoUrl,
              'userToken': documentSnapshot['deviceToken']
            });
          },
          child: ListTile(
            leading: userChat.photoUrl.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: Image.network(
                      userChat.photoUrl,
                      fit: BoxFit.cover,
                      width: 45,
                      height: 45,
                      loadingBuilder: (BuildContext ctx, Widget child,
                          ImageChunkEvent? loadingProgress) {
                        if (loadingProgress == null) {
                          return child;
                        } else {
                          return SizedBox(
                            width: 45,
                            height: 45,
                            child: CircularProgressIndicator(
                                color: Colors.grey,
                                value: loadingProgress.expectedTotalBytes !=
                                        null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null),
                          );
                        }
                      },
                      errorBuilder: (context, object, stackTrace) {
                        return const Icon(Icons.account_circle, size: 45);
                      },
                    ),
                  )
                : const Icon(
                    Icons.account_circle,
                    size: 45,
                  ),
            title: Text(
              userChat.displayName,
              style: const TextStyle(color: Colors.black),
            ),
          ),
        );
      }
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget widgetSearch() {
    return Container(
      margin: const EdgeInsets.only(left: 22.0, right: 22.0),
      height: 45.0,
      width: double.infinity,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(
          Radius.circular(8.0),
        ),
        color: Colors.white,
      ),
      child: const Padding(
        padding: EdgeInsets.only(left: 10.0, right: 10.0),
        child: TextField(
          decoration: InputDecoration(
            focusColor: Colors.green,
            hintText: 'Search here..',
            border: InputBorder.none,
          ),
          textAlign: TextAlign.start,
        ),
      ),
    );
  }

  void openDialog(HomeController controller) {
    Get.dialog(
      AlertDialog(
        content: const Text('Do you want to logout?'),
        //Text('do_you_want_to_logout'.tr),
        actions: [
          TextButton(
            child: const Text(
              'No', //"no".tr,
              style: TextStyle(color: Colors.green),
            ),
            onPressed: () => Get.back(),
          ),
          TextButton(
              child: const Text(
                'Yes', //"yes".tr,
                style: TextStyle(color: Colors.green),
              ),
              onPressed: () {
                controller.logout().whenComplete(() {
                  Get.offAllNamed(Routes.login);
                });
              }),
        ],
      ),
      barrierDismissible: false,
    );
  }
}
