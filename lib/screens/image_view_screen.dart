import 'package:chat_app/controller/image_view_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';

class ImageViewScreen extends StatelessWidget {
  final ImageViewController controller = Get.put(ImageViewController());

  ImageViewScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Scaffold(
        appBar: AppBar(
          elevation: 0.0,
          foregroundColor: Colors.white,
          backgroundColor: Colors.black,
        ),
        body: PhotoView(
          imageProvider: NetworkImage(controller.imageUrl.value),
        ),
      );
    });
  }
}
