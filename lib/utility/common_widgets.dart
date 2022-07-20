import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'app_constant.dart';
import 'color_constant.dart';
import 'dimensions.dart';

widgetLoader() {
  return Container(
      height: Dimensions.screenHeight,
      width: Dimensions.screenWidth,
      color: ColorConstants.white,
      child: const Center(
          child: CircularProgressIndicator(
        color: ColorConstants.orange,
      )));
}

widgetAppbar(String title, bool isBack) {
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
    title: Text(
      title,
      style:
          textStyle(20, Colors.white, AppConstants.fontMedium, FontWeight.w400),
    ),
  );
}

widgetText(String text, double fontSize, Color fontColor, String fontFamily,
    FontWeight fontWeight) {
  return Text(text,
      style: textStyle(fontSize, fontColor, fontFamily, fontWeight));
}

textStyle(double fontSize, Color fontColor, String fontFamily,
    FontWeight fontWeight) {
  return TextStyle(
      fontSize: fontSize,
      color: fontColor,
      fontFamily: fontFamily,
      fontWeight: fontWeight);
}

widgetTextNormal(String text, double fontSize) {
  return widgetText(text, fontSize, ColorConstants.black_regular,
      AppConstants.fontRegular, FontWeight.normal);
}

widgetTextMedium(String text, double fontSize) {
  return widgetText(text, fontSize, ColorConstants.black_regular,
      AppConstants.fontMedium, FontWeight.normal);
}

Widget chatImage({required String imageSrc, required GestureTapCallback? onTap}) {
  return InkWell(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.all(4.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6.0),
        child: Image.network(
          imageSrc,
          width: 200,
          height: 200,
          fit: BoxFit.fill,
          loadingBuilder:
              (BuildContext ctx, Widget child, ImageChunkEvent? loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(6.0),
              ),
              width: 200,
              height: 200,
              child: Center(
                child: CircularProgressIndicator(
                  color: Colors.green,
                  value: loadingProgress.expectedTotalBytes != null &&
                          loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
                ),
              ),
            );
          },
          errorBuilder: (context, object, stackTrace) => errorContainer(),
        ),
      ),
    ),
  );
}

Widget errorContainer() {
  return Container(
    clipBehavior: Clip.hardEdge,
    child: Image.asset(
      'assets/img_not_available.jpeg',
      height: 200,
      width: 200,
    ),
  );
}
