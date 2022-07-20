import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

import '../utility/app_constant.dart';

class UserModel {
  String? userId;
  String? userName;
  String? userProfile;
  String? lastMsgTime;

  UserModel({this.userId, this.userName, this.userProfile, this.lastMsgTime});

  UserModel.fromJson(Map<String, dynamic> json) {
    userId = json['userId'];
    userName = json['userName'];
    userProfile = json['userProfile'];
    lastMsgTime = json['lastMsgTime'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['userId'] = this.userId;
    data['userName'] = this.userName;
    data['userProfile'] = this.userProfile;
    data['lastMsgTime'] = this.lastMsgTime;
    return data;
  }
}

class ChatUser extends Equatable {
  final String id;
  final String photoUrl;
  final String displayName;
  final String phoneNumber;
  final String aboutMe;
  final String status;
  final String deviceToken;

  const ChatUser(
      {required this.id,
      required this.photoUrl,
      required this.displayName,
      required this.phoneNumber,
      required this.aboutMe,
      required this.status,
      required this.deviceToken});

  ChatUser copyWith(
          {String? id,
          String? photoUrl,
          String? nickname,
          String? phoneNumber,
          String? email,
          String? status,
          String? deviceToken}) =>
      ChatUser(
          id: id ?? this.id,
          photoUrl: photoUrl ?? this.photoUrl,
          displayName: nickname ?? displayName,
          phoneNumber: phoneNumber ?? this.phoneNumber,
          aboutMe: email ?? aboutMe,
          status: status ?? this.status,
          deviceToken: deviceToken ?? this.deviceToken);

  Map<String, dynamic> toJson() => {
        AppConstants.displayName: displayName,
        AppConstants.photoUrl: photoUrl,
        AppConstants.phoneNumber: phoneNumber,
        AppConstants.aboutMe: aboutMe,
        AppConstants.status: status,
        AppConstants.deviceToken: deviceToken
      };

  factory ChatUser.fromDocument(DocumentSnapshot snapshot) {
    String photoUrl = "";
    String nickname = "";
    String phoneNumber = "";
    String aboutMe = "";
    String status = "";
    String deviceToken = "";

    try {
      photoUrl = snapshot.get(AppConstants.photoUrl);
      nickname = snapshot.get(AppConstants.displayName);
      phoneNumber = snapshot.get(AppConstants.phoneNumber);
      aboutMe = snapshot.get(AppConstants.aboutMe);
      status = snapshot.get(AppConstants.status);
      deviceToken = snapshot.get(AppConstants.deviceToken);
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    return ChatUser(
        id: snapshot.id,
        photoUrl: photoUrl,
        displayName: nickname,
        phoneNumber: phoneNumber,
        aboutMe: aboutMe,
        status: status,
        deviceToken: deviceToken);
  }

  @override
  // TODO: implement props
  List<Object?> get props =>
      [id, photoUrl, displayName, phoneNumber, aboutMe, status, deviceToken];
}
