import 'package:chat_app/utility/app_constant.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessages {
  String idFrom;
  String idTo;
  String timestamp;
  String content;
  int type;

  ChatMessages(
      {required this.idFrom,
      required this.idTo,
      required this.timestamp,
      required this.content,
      required this.type});

  Map<String, dynamic> toJson() {
    return {
      AppConstants.idFrom: idFrom,
      AppConstants.idTo: idTo,
      AppConstants.timestamp: timestamp,
      AppConstants.content: content,
      AppConstants.type: type,
    };
  }

  factory ChatMessages.fromDocument(DocumentSnapshot documentSnapshot) {
    String idFrom = documentSnapshot.get(AppConstants.idFrom);
    String idTo = documentSnapshot.get(AppConstants.idTo);
    String timestamp = documentSnapshot.get(AppConstants.timestamp);
    String content = documentSnapshot.get(AppConstants.content);
    int type = documentSnapshot.get(AppConstants.type);

    return ChatMessages(
        idFrom: idFrom,
        idTo: idTo,
        timestamp: timestamp,
        content: content,
        type: type);
  }
}
