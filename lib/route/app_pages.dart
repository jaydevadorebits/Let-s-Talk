import 'package:chat_app/screens/add_member_screen.dart';
import 'package:chat_app/screens/group_chat_screen.dart';
import 'package:chat_app/screens/group_info_screen.dart';
import 'package:chat_app/screens/group_list_screen.dart';
import 'package:get/get.dart';

import '../screens/chat_screen.dart';
import '../screens/home_screen.dart';
import '../screens/image_view_screen.dart';
import '../screens/login_screen.dart';
import '../screens/splash_screen.dart';

part 'app_routes.dart';

class AppPages {
  static const initial = Routes.splash;

  static final routes = [
    GetPage(
        name: Routes.splash,
        page: () => SplashScreen(),
        transition: Transition.downToUp),
    GetPage(
        name: Routes.login,
        page: () => const LoginScreen(),
        transition: Transition.downToUp),
    GetPage(
        name: Routes.home,
        page: () => HomeScreen(),
        transition: Transition.downToUp),
    GetPage(
        name: Routes.chatDetail,
        page: () => ChatScreen(),
        transition: Transition.downToUp),
    GetPage(
        name: Routes.groupList,
        page: () => GroupListScreen(),
        transition: Transition.downToUp),
    GetPage(
        name: Routes.groupChat,
        page: () => GroupChatScreen(),
        transition: Transition.downToUp),
    GetPage(
        name: Routes.addMember,
        page: () => AddMemberScreen(),
        transition: Transition.downToUp),
    GetPage(
        name: Routes.groupInfo,
        page: () => GroupInfoScreen(),
        transition: Transition.downToUp),
    GetPage(
        name: Routes.imageView,
        page: () => ImageViewScreen(),
        transition: Transition.downToUp),
  ];
}
