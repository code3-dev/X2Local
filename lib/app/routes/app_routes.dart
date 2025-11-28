part of 'app_pages.dart';

abstract class Routes {
  Routes._();
  static const home = _Paths.home;
  static const about = _Paths.about;
}

abstract class _Paths {
  _Paths._();
  static const home = '/home';
  static const about = '/about';
}
