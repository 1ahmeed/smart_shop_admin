import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dynamic_height_grid_view/dynamic_height_grid_view.dart';

import '../../core/services/assets_manager.dart';
import '../../core/utils/app_colors.dart';
import '../../core/widgets/product_widget.dart';
import '../../core/widgets/title_text.dart';
import '../../models/product_model.dart';
import '../../providers/product_provider.dart';


class InspectProduct extends StatefulWidget {
  static String routName="/SearchScreen";
  const InspectProduct({super.key});

  @override
  State<InspectProduct> createState() => _InspectProductState();
}

class _InspectProductState extends State<InspectProduct> {
  late TextEditingController searchTextController;

  @override
  void initState() {
    searchTextController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    searchTextController.dispose();
    super.dispose();
  }
   List<ProductModel> productListSearch = [];

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    String? passedCategory= ModalRoute.of(context)!.settings.arguments as String?;
    final List<ProductModel> productList = passedCategory ==null ?
    productProvider.getProduct:productProvider.findByCategory(categoryName: passedCategory);


    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
          appBar: AppBar(
            title:  TitlesTextWidget(label:passedCategory?? "Search"),
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.asset(AssetsManager.shoppingCart),
            ),
          ),
          body:
          StreamBuilder<List<ProductModel>>(
            stream:  productProvider.fetchProductsStream(),
            builder: (context, snapshot) {
              if(snapshot.connectionState== ConnectionState.waiting){
                return const Center(child: CircularProgressIndicator());
              }else if(snapshot.hasError){
                return Center(child: TitlesTextWidget(label: snapshot.error.toString()));
              }else if(snapshot.data==null){
                return const Center(child: TitlesTextWidget(label:"No product has been founded" ));
              }
              return  Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    const SizedBox(
                      height: 15.0,
                    ),
                    TextField(
                      controller: searchTextController,
                      decoration: InputDecoration(
                        hintText: "search",
                        filled: true,
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: IconButton(
                          splashColor: AppColors.grey,
                          onPressed:  () {
                            // setState(() {
                            searchTextController.clear();
                            FocusScope.of(context).unfocus();
                            // });
                          },
                          icon:  const Icon(
                            Icons.clear,
                            color: Colors.red,
                          ),
                        ),
                      ),
                      onSubmitted: (value) {
                        setState(() {
                          productListSearch= productProvider.searchQuery(
                              passedList:productList ,
                              searchText: searchTextController.text);
                        });
                      },
                    ),
                    const SizedBox(
                      height: 15.0,
                    ),
                    if(searchTextController.text.isNotEmpty && productListSearch.isEmpty)...[
                      const Center(child: TitlesTextWidget(label: "No Result Found"))
                    ],
                    Expanded(
                      child: DynamicHeightGridView(
                        itemCount:searchTextController.text.isNotEmpty?
                        productListSearch.length: productList.length,
                        builder: ((context, index) {
                          return  ProductWidget(
                            productId: searchTextController.text.isNotEmpty?
                            productListSearch[index].productId:productList[index].productId,
                          );
                        }),
                        crossAxisCount: 2,
                      ),
                    ),
                  ],
                ),
              );
            },
          )),
    );
  }
}
