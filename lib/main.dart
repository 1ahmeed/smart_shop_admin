import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_shop_admin/providers/product_provider.dart';
import 'package:smart_shop_admin/providers/theme_provider.dart';
import 'package:smart_shop_admin/screens/dashboard/dashboard_screen.dart';
import 'package:smart_shop_admin/screens/edit/edit_upload_product_form.dart';
import 'package:smart_shop_admin/screens/inspect_product/search_screen.dart';
import 'package:smart_shop_admin/screens/splash/splash_screen.dart';
import 'core/utils/theme_data.dart';
import 'firebase_options.dart';


void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
     options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // final themeProvider = Provider.of<ThemeProvider>(context);
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => ProductProvider(),
        ),
      ],
      child: Consumer<ThemeProvider>(builder: (
          context,
          themeProvider,
          child,
          ) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: Styles.themeData(
              isDarkTheme: themeProvider.getIsDarkTheme, context: context),
          home: const SplashScreen(),
          routes: {
            InspectProduct.routName: (context) => const InspectProduct(),
            EditOrUploadProductScreen.routeName: (context) => const EditOrUploadProductScreen(),
          },
        );
      }),
    );
  }
}
