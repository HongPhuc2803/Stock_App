import 'package:flutter/material.dart';

import 'router.dart';
import '../core/theme/app_theme.dart';


class SmartStockApp extends StatelessWidget {

  const SmartStockApp({
    super.key,
  });


  @override
  Widget build(BuildContext context) {


    return MaterialApp.router(

      debugShowCheckedModeBanner: false,


      title: 'SmartStock',


      theme: AppTheme.light,


      routerConfig: router,


    );

  }

}