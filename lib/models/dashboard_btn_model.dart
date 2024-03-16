import 'package:flutter/material.dart';

import '../core/services/assets_manager.dart';
import '../screens/edit/edit_upload_product_form.dart';
import '../screens/inspect_product/search_screen.dart';


class DashboardButtonsModel {
  final String text, imagePath;
  final Function onPressed;

  DashboardButtonsModel({
    required this.text,
    required this.imagePath,
    required this.onPressed,
  });

  static List<DashboardButtonsModel> dashboardBtnList(BuildContext context) => [
        DashboardButtonsModel(
          text: "Add a new product",
          imagePath: AssetsManager.cloud,
          onPressed: () {
            Navigator.pushNamed(context, EditOrUploadProductScreen.routeName);
          },
        ),
        DashboardButtonsModel(
          text: "inspect all products",
          imagePath: AssetsManager.shoppingCart,
          onPressed: () {

              Navigator.pushNamed(context, InspectProduct.routName);
          },
        ),
        // DashboardButtonsModel(
        //   text: "View Orders",
        //   imagePath: AssetsManager.order,
        //   onPressed: () {
        //     Navigator.pushNamed(context, OrdersScreenFree.routeName);
        //   },
        // ),
      ];
}
