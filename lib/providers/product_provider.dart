import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../models/product_model.dart';

class ProductProvider with ChangeNotifier{
   List<ProductModel> _products = [];
  List<ProductModel> get getProduct{
    return _products;
  }

  ProductModel ? findByProdId(String prodId){
    if(_products.where((element) => element.productId==prodId).isEmpty){
      return null;
    }
    return _products.firstWhere((element) => element.productId==prodId);

  }

  List<ProductModel> findByCategory({required String categoryName}){
    List<ProductModel> ctgList=_products.where((element) => element.productCategory.toLowerCase()
        .contains(categoryName.toLowerCase())).toList();
    return ctgList;

  }
  List<ProductModel> searchQuery({required String searchText, required List<ProductModel> passedList}){
    List<ProductModel> searchList=passedList.where((element) => element.productCategory.toLowerCase()
        .contains(searchText.toLowerCase())).toList();
    return searchList;

  }

  final productFromDB= FirebaseFirestore.instance.collection("products");
  Future<List<ProductModel>>fetchProducts()async{
    try{
     await productFromDB.get().then((productSnapShot) {
       _products=[];
       for(var element in productSnapShot.docs){
         _products.insert(0, ProductModel.fromFireStore(element));
       }
     });
     notifyListeners();
     return _products;
    }catch(error){
      rethrow;
    }
  }

  Stream<List<ProductModel>>fetchProductsStream(){
    try{
      return  productFromDB.snapshots().map((snapShot){
        _products.clear();
         for(var element in snapShot.docs){
           _products.insert(0, ProductModel.fromFireStore(element));
         }
         // notifyListeners();

         return _products;
      });
      // notifyListeners();
      // return _products;
    }catch(error){
      rethrow;
    }
  }



}