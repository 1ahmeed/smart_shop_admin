
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:smart_shop_admin/screens/dashboard/dashboard_screen.dart';

import '../../core/widgets/app_name_text.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);


  @override
  State<SplashScreen> createState() => _SplashScreenState();
}


class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>const DashboardScreen()
      ));
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
         Expanded(child: Center(child: AppNameTextWidget())),
           

            Text(
           "Made by ahmed tarek", style: TextStyle(color: Theme.of(context).textTheme.bodySmall!.color),)
        ],
      ),
    );
  }
}
