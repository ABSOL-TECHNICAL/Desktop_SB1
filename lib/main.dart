import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:impal_desktop/features/global/theme/theme.dart';
import 'package:impal_desktop/features/login/bindings/login_bindings.dart';
import 'package:impal_desktop/routes/app_pages.dart';
import 'package:impal_desktop/routes/app_routes.dart';
import 'package:fl_downloader/fl_downloader.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlDownloader.initialize();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          title: 'Impal',
          initialRoute: AppRoutes.login.toName,
          initialBinding: LoginBinding(),
          getPages: AppPages.list,
          theme: AppTheme.lightTheme(context).copyWith(
            scaffoldBackgroundColor: const Color.fromARGB(255, 250, 248, 248),
          ),
          themeMode: ThemeMode.light,
          locale: Get.deviceLocale,
          fallbackLocale: const Locale('en', 'US'),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
