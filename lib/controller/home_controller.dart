import 'dart:convert';

import 'package:chat_app/controller/base_controller.dart';
import 'package:chat_app/model/user_mode.dart';
import 'package:chat_app/utility/app_constant.dart';
import 'package:chat_app/utility/authentication.dart';
import 'package:chat_app/utility/helper_class.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';


class HomeController extends BaseController with WidgetsBindingObserver {
  BuildContext context;

  HomeController({required this.context});

  List<UserModel> userList = <UserModel>[].obs;

  RxInt limit = 20.obs;
  final RxInt limitIncrement = 20.obs;
  RxString textSearch = "".obs;

  //bool isLoading = false;
  final ScrollController scrollController = ScrollController();

  RxString currentId = ''.obs;

  late final FirebaseFirestore firebaseFirestore;

  var collection = FirebaseFirestore.instance;

  ConnectivityResult result = ConnectivityResult.none;

  @override
  void onInit() {
    User? user = FirebaseAuth.instance.currentUser;

    debugPrint('userDataHome1-' + user!.uid.toString());

    currentId.value = user.uid.toString();
    debugPrint('userDataHome2-' + currentId.value);

    WidgetsBinding.instance!.addObserver(this);
    scrollController.addListener(scrollListener);

    setStatus('Online');
    super.onInit();

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.bottom, SystemUiOverlay.top]);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.green,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ));
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      setStatus('Online');
      update();
    } else {
      setStatus('Offline');
      update();
    }
  }

  void setStatus(String status) async {
    result = await Connectivity().checkConnectivity();
    if (result == ConnectivityResult.mobile ||
        result == ConnectivityResult.wifi) {
      var token = await FirebaseMessaging.instance.getToken();
      debugPrint('token_home-' + token.toString());

      await collection
          .collection(AppConstants.pathUserCollection)
          .doc(currentId.value)
          .update(
              {AppConstants.status: status, AppConstants.deviceToken: token});
    } else {
      Helper.showMsg(AppConstants.internetMsg);
      //Utility().snackBar(AppConstants.networkMsg, context);
    }
  }

  void scrollListener() {
    if (scrollController.offset >= scrollController.position.maxScrollExtent &&
        !scrollController.position.outOfRange) {
      limit.value += limitIncrement.value;
      update();
    }
  }

  Stream<QuerySnapshot> getFirestoreData(
      String collectionPath, int limit, String? textSearch) {
    if (textSearch?.isNotEmpty == true) {
      return collection
          .collection(collectionPath)
          .limit(limit)
          .where(AppConstants.displayName, isEqualTo: textSearch)
          .snapshots();
    } else {
      return collection.collection(collectionPath).limit(limit).snapshots();
    }
  }



  Future logout() async {
    await Authentication.signOut(context: context);
  }
}
