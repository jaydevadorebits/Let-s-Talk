import 'dart:async';
import 'dart:io';

import 'package:chat_app/utility/helper_class.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:shared_preferences/shared_preferences.dart';

import '../route/app_pages.dart';
import '../utility/app_constant.dart';
import '../utility/dimensions.dart';
import 'base_controller.dart';

class SplashController extends BaseController {
  SharedPreferences? prefs;
  RxBool isUserLogin = false.obs;
  RxString language = 'English'.obs;

  ConnectivityResult result = ConnectivityResult.none;

  @override
  void onInit() {
    super.onInit();

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.bottom, SystemUiOverlay.top]);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.black,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ));

    //checkUserIsLogin();
    //getSharedPref();
    checkUserIsLoginOrNot();
  }

  void checkUserIsLoginOrNot() async {
    result = await Connectivity().checkConnectivity();
    /*User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      debugPrint('userDataSplash-' + user.uid);
      navigateToHomeScreen(user.uid.toString());
    } else {
      debugPrint('user-null');
      navigateToLoginScreen();
    }*/
    if (result == ConnectivityResult.mobile ||
        result == ConnectivityResult.wifi) {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        debugPrint('userDataSplash-' + user.uid);
        navigateToHomeScreen(user.uid.toString());
      } else {
        debugPrint('user-null');
        navigateToLoginScreen();
      }
    } else {
      if (Platform.isAndroid) {
        SystemNavigator.pop();
      } else if (Platform.isIOS) {
        exit(0);
      }
      Helper.showMsg(AppConstants.internetMsg);

      //Utility().snackBar(AppConstants.networkMsg, context);
    }
  }

  /*getSharedPref() async {
    prefs = await SharedPreferences.getInstance();
    try {
      language.value = (await Helper.getSelectedLanguage())!;
      debugPrint('checkLanguage->' + language.value);
      if (language.value == 'Hindi') {
        debugPrint('set_hindi');
        Get.updateLocale(const Locale('hi', 'IN'));
      } else {
        debugPrint('set_english');
        Get.updateLocale(const Locale('en', 'US'));
      }
    } catch (e) {
      debugPrint('exeLanguage->' + e.toString());
    }
  }*/

  void navigateToHomeScreen(String authId) {
    var _duration = Duration(
      seconds: Dimensions.screenLoadTime,
    );
    Timer(_duration, () async {
      debugPrint('userDataSplash2-' + authId);
      Get.offNamedUntil(Routes.home, (route) => false);
    });
  }

  void navigateToLoginScreen() {
    var _duration = Duration(
      seconds: Dimensions.screenLoadTime,
    );
    Timer(_duration, () async {
      Get.offNamedUntil(Routes.login, (route) => false);
    });
  }
}
