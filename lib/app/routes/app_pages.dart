import 'package:get/get.dart';
import 'package:x2local/app/modules/home/bindings/home_binding.dart';
import 'package:x2local/app/modules/home/views/home_view.dart';
import 'package:x2local/app/modules/about/views/about_view.dart';
import 'package:x2local/app/modules/about/bindings/about_binding.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const initial = Routes.home;

  static final routes = [
    GetPage(
      name: _Paths.home,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.about,
      page: () => const AboutView(),
      binding: AboutBinding(),
    ),
  ];
}
