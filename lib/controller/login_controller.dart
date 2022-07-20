import 'package:chat_app/model/user_mode.dart';
import 'package:chat_app/utility/app_constant.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../route/app_pages.dart';
import '../utility/authentication.dart';
import '../utility/helper_class.dart';
import 'base_controller.dart';

class LoginController extends BaseController {
  late BuildContext context;
  var collection = FirebaseFirestore.instance;

  late SharedPreferences prefs;

  LoginController(this.context);

  ConnectivityResult result = ConnectivityResult.none;

  @override
  void onInit() {
    super.onInit();
    getPreference();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.bottom, SystemUiOverlay.top]);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.black,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ));
  }

  void getPreference() async {
    prefs = await SharedPreferences.getInstance();
  }

  void loginWthGoogle() async {
    result = await Connectivity().checkConnectivity();
    if (result == ConnectivityResult.mobile ||
        result == ConnectivityResult.wifi) {
      User? user = await Authentication.signInWithGoogle(context: context);
      if (user != null) {
        Helper.setUserGoogleId(user.uid);
        debugPrint('userData-' + user.uid);
        isLoading.value = false;

        final QuerySnapshot result = await collection
            .collection(AppConstants.pathUserCollection)
            .where(AppConstants.id, isEqualTo: user.uid)
            .get();
        final List<DocumentSnapshot> document = result.docs;
        var token = await FirebaseMessaging.instance.getToken();
        debugPrint('token_login-' + token.toString());
        if (document.isEmpty) {
          debugPrint('user if login');
          collection
              .collection(AppConstants.pathUserCollection)
              .doc(user.uid)
              .set({
            AppConstants.displayName: user.displayName,
            AppConstants.photoUrl: user.photoURL,
            AppConstants.id: user.uid,
            "createdAt: ": DateTime.now().millisecondsSinceEpoch.toString(),
            AppConstants.chattingWith: null,
            AppConstants.status: 'UnAvailable',
            AppConstants.deviceToken: token
          });

          User? currentUser = user;
          await prefs.setString(AppConstants.id, currentUser.uid);
          await prefs.setString(
              AppConstants.displayName, currentUser.displayName ?? "");
          await prefs.setString(
              AppConstants.photoUrl, currentUser.photoURL ?? "");
          await prefs.setString(
              AppConstants.phoneNumber, currentUser.phoneNumber ?? "");
        } else {
          debugPrint('user else login');
          DocumentSnapshot documentSnapshot = document[0];
          ChatUser userChat = ChatUser.fromDocument(documentSnapshot);
          await prefs.setString(AppConstants.id, userChat.id);
          await prefs.setString(AppConstants.displayName, userChat.displayName);
          await prefs.setString(AppConstants.aboutMe, userChat.aboutMe);
          await prefs.setString(AppConstants.phoneNumber, userChat.phoneNumber);
        }

        Get.offNamedUntil(Routes.home, (route) => false,
            arguments: {'googleId': user.uid});
      } else {
        debugPrint('userLogin-error');
      }
    } else {
      Helper.showMsg(AppConstants.internetMsg);
    }
  }
}
