import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:carelinemed/Api/data_store.dart';
import 'package:carelinemed/helpar/routes_helper.dart';
import 'package:carelinemed/model/font_family_model.dart';
import 'package:carelinemed/screen/language/localstring.dart';
import 'package:carelinemed/utils/custom_colors.dart';
import 'package:carelinemed/utils/customwidget.dart';
import 'package:carelinemed/screen/video_call/vc_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

import '';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  initPlatformState();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => VcProvider()),
      ],
      child: GetMaterialApp(
        title: "CarelineMed",
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          hoverColor: Colors.transparent,
          dividerColor: Colors.transparent,
          primaryColor: primeryColor,
          scaffoldBackgroundColor: bgcolor,
          colorScheme: ColorScheme.fromSwatch().copyWith(
            primary: primeryColor,
            secondary: blueColor,
          ),
          iconTheme: IconThemeData(color: BlackColor),
          textTheme: GoogleFonts.poppinsTextTheme(), // Use Poppins
          useMaterial3: false,
          appBarTheme: AppBarTheme(
            backgroundColor: primeryColor, // Using Peacock Teal
            elevation: 0,
            centerTitle: true,
            actionsIconTheme: IconThemeData(color: WhiteColor),
            iconTheme: IconThemeData(color: WhiteColor),
            titleTextStyle: GoogleFonts.poppins(
              color: WhiteColor,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
            systemOverlayStyle: SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: Brightness.light,
            ),
          ),
        ),
        translations: LocaleString(),
        locale: getData.read("lan2") != null
            ? Locale(getData.read("lan2"), getData.read("lan1"))
            : Locale('en_US', 'en_US'),
        initialRoute: Routes.initial,
        // home: OurProduct(),
        getPages: getPages,
      ),
    ),
  );
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
