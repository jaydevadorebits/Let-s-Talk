import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:shared_preferences/shared_preferences.dart';

class Helper {
  static final _sharedPref = SharedPreferences.getInstance();

  static const isUserLoggedIn = 'isUserLoggedIn';
  static const _userGoogleId = 'userGoogleId';
  static const selectedLanguage = 'language';

  static setLanguage(String language) async {
    final SharedPreferences pref = await _sharedPref;
    pref.setString(selectedLanguage, language);
  }

  static Future<String?> getSelectedLanguage() async {
    final SharedPreferences pref = await _sharedPref;
    return pref.getString(selectedLanguage);
  }

  static setUserGoogleId(String token) async {
    final SharedPreferences pref = await _sharedPref;
    pref.setString(_userGoogleId, token);
  }

  static Future<String?> getUserGoogleId() async {
    final SharedPreferences pref = await _sharedPref;
    return pref.getString(_userGoogleId);
  }

  static setIsUserLoggedIn(bool value) async {
    final SharedPreferences pref = await _sharedPref;
    pref.setBool(isUserLoggedIn, value);
  }

  static Future<bool?> getIsUserLoggedIn() async {
    final SharedPreferences pref = await _sharedPref;
    return pref.getBool(isUserLoggedIn);
  }

  static showMsg(String msg) {
    Fluttertoast.showToast(
        msg: msg,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16);
  }
}
