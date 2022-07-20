import 'package:chat_app/controller/base_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ImageViewController extends BaseController {
  RxString imageUrl = ''.obs;

  @override
  void onInit() {
    imageUrl.value = Get.parameters['imageUrl'].toString();
    super.onInit();
  }
}
