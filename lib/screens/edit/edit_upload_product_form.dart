import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smart_shop_admin/core/utils/app_constants.dart';
import 'package:smart_shop_admin/models/product_model.dart';

import 'package:uuid/uuid.dart';

import '../../core/services/my_app_method.dart';
import '../../core/utils/loading_manager.dart';
import '../../core/utils/my_validators.dart';
import '../../core/widgets/subtitle_text.dart';
import '../../core/widgets/title_text.dart';

class EditOrUploadProductScreen extends StatefulWidget {
  static const routeName = '/EditOrUploadProductScreen';

  const EditOrUploadProductScreen({
    super.key, this.productModel,
  });
final ProductModel? productModel;
  @override
  State<EditOrUploadProductScreen> createState() =>
      _EditOrUploadProductScreenState();
}

class _EditOrUploadProductScreenState extends State<EditOrUploadProductScreen> {
  final _formKey = GlobalKey<FormState>();
  XFile? _pickedImage;
  bool isEditing=false;
  bool isLoading=false;
  String? productNetworkImage;

  late TextEditingController _titleController,
      _priceController,
      _descriptionController,
      _quantityController;
  String? _categoryValue;
  String? productImageUrl;

  @override
  void initState() {
    // _categoryController = TextEditingController();
    // _brandController = TextEditingController();
if(widget.productModel!=null){
  isEditing=true;
  productNetworkImage=widget.productModel!.productImage;
  _categoryValue=widget.productModel!.productCategory;
}
    _titleController = TextEditingController(text: widget.productModel?.productTitle);
    _priceController = TextEditingController(text: widget.productModel?.productPrice);
    _descriptionController = TextEditingController(text: widget.productModel?.productDescription);
    _quantityController = TextEditingController(text: widget.productModel?.productQuantity);

    super.initState();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  void clearForm() {
    _titleController.clear();
    _priceController.clear();
    _descriptionController.clear();
    _quantityController.clear();
    removePickedImage();
  }

  void removePickedImage() {
    setState(() {
      _pickedImage = null;
      productNetworkImage=null;
    });
  }

  Future<void> _uploadProduct() async {

    final isValid = _formKey.currentState!.validate();
    FocusScope.of(context).unfocus();

    if (_pickedImage == null) {
      MyAppMethods.showErrorORWarningDialog(context: context,
          subtitle: "Make sure to pick up an image",
          fct: (){

          });
      return;
    }
    if (_categoryValue == null) {
      MyAppMethods.showErrorORWarningDialog(context: context,
          subtitle: "category is empty",
          fct: (){

          });
      return;
    }

    setState(() {
      isLoading=true;
    });
    final productId=const Uuid().v4();
    if (_pickedImage!= null) {
      final ref= FirebaseStorage.instance.ref()
          .child("productImages")
          .child("$productId.jpg");
      await ref.putFile(File(_pickedImage!.path));
      productImageUrl =await ref.getDownloadURL();
    }


    if (isValid) {
      _formKey.currentState!.save();
      try{
        setState(() {
          isLoading=true;
        });
        final productId=const Uuid().v4();
        if (_pickedImage!= null) {
          final ref= FirebaseStorage.instance.ref()
              .child("productImages")
              .child("$productId.jpg");
          await ref.putFile(File(_pickedImage!.path));
          productImageUrl =await ref.getDownloadURL();
        }

        await FirebaseFirestore.instance.collection("products").doc(productId).set(
            {
              "productId": productId,
              "productTitle": _titleController.text,
              "productPrice": _priceController.text,
              "productImage": productImageUrl,
              "productCategory": _categoryValue,
              "productDescription": _descriptionController.text,
              "productQuantity": _quantityController.text,
              "createdAt": Timestamp.now()
            });



        Fluttertoast.showToast(
            msg: "product has been added",
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.green,
            textColor: Colors.white,
            fontSize: 16.0
        );
        if(!mounted) return;
        MyAppMethods.showErrorORWarningDialog(
            isError: false,
            context: context,
            subtitle: "clear form?",
            fct: (){
              clearForm();
            });


      }on FirebaseException catch(e){
        if(!mounted)return;
        MyAppMethods.showErrorORWarningDialog(
            context: context,
            subtitle: "an error has been occurred ${e.message}",
            fct: (){
            });
      } catch(e){
        if(!mounted)return;
        MyAppMethods.showErrorORWarningDialog(context: context,
            subtitle: "an error has been occurred $e",
            fct: (){});
      }finally{
        setState(() {
          isLoading=false;
        });
      }
    }
  }

  Future<void> _editProduct() async {

    final isValid = _formKey.currentState!.validate();
    FocusScope.of(context).unfocus();
    if(_pickedImage==null && productNetworkImage==null){
      MyAppMethods.showErrorORWarningDialog(
          context: context,
          subtitle: "please pick up an image",
          fct: (){});
      return;
    }
    if (_categoryValue == null) {
      MyAppMethods.showErrorORWarningDialog(context: context,
          subtitle: "category is empty",
          fct: (){

          });
      return;
    }

    if (isValid) {
      _formKey.currentState!.save();
      try{
        setState(() {
          isLoading=true;
        });
        if(_pickedImage!=null){
          final ref= FirebaseStorage.instance.ref()
              .child("productImages")
              .child("${widget.productModel!.productId}.jpg");
          await ref.putFile(File(_pickedImage!.path));
          productImageUrl =await ref.getDownloadURL();
        }


        // final productId=const Uuid().v4();
        await FirebaseFirestore.instance.collection("products")
            .doc(widget.productModel!.productId).update(
            {
              "productId": widget.productModel!.productId,
              "productTitle": _titleController.text,
              "productPrice": _priceController.text,
              "productImage": productImageUrl??productNetworkImage,
              "productCategory": _categoryValue,
              "productDescription": _descriptionController.text,
              "productQuantity": _quantityController.text,
              "createdAt": widget.productModel!.createdAt
            });



        Fluttertoast.showToast(
            msg: "product has been edited",
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.green,
            textColor: Colors.white,
            fontSize: 16.0
        );
        if(!mounted) return;
        MyAppMethods.showErrorORWarningDialog(
            isError: false,
            context: context,
            subtitle: "clear form?",
            fct: (){
              clearForm();
            });


      }on FirebaseException catch(e){
        if(!mounted)return;
        MyAppMethods.showErrorORWarningDialog(
            context: context,
            subtitle: "an error has been occurred ${e.message}",
            fct: (){
            });
      } catch(e){
        if(!mounted)return;
        MyAppMethods.showErrorORWarningDialog(context: context,
            subtitle: "an error has been occurred $e",
            fct: (){});
      }finally{
        setState(() {
          isLoading=false;
        });
      }
    }
  }

  Future<void> localImagePicker() async {
    final ImagePicker picker = ImagePicker();
    await MyAppMethods.imagePickerDialog(
      context: context,
      cameraFCT: () async {
        _pickedImage = await picker.pickImage(source: ImageSource.camera);
        setState(() {
          productNetworkImage=null;
        });
      },
      galleryFCT: () async {
        _pickedImage = await picker.pickImage(source: ImageSource.gallery);
        setState(() {
          if(_pickedImage !=null) {
            productNetworkImage=null;
          }

        });
      },
      removeFCT: () {
        setState(() {
          if(_pickedImage !=null) {
            productNetworkImage=null;
          }
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return LoadingManager(
      isLoading: isLoading,
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
          bottomSheet: SizedBox(
            height: kBottomNavigationBarHeight + 10,
            child: Material(
              color: Theme.of(context).scaffoldBackgroundColor,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  /// btn clear data
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(12),
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          10,
                        ),
                      ),
                    ),
                    icon: const Icon(Icons.clear,color: Colors.white),
                    label: const Text(
                      "Clear",
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white
                      ),
                    ),
                    onPressed: () {},
                  ),
                  /// btn upload data
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(12),
                      // backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          10,
                        ),
                      ),
                    ),
                    icon: const Icon(Icons.upload),
                    label:  Text(
                      isEditing?"edit product":"Upload Product",
                      style: const TextStyle(
                        fontSize: 20,
                      ),
                    ),
                    onPressed: () {
                      if(isEditing){
                        _editProduct();
                      }else {
                        _uploadProduct();
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          appBar: AppBar(
            centerTitle: true,
            elevation: 0,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            title: const TitlesTextWidget(
              label: "Upload a new product",
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(
                    height: 20,
                  ),
                  if(isEditing && productNetworkImage!=null)...[
                    ClipRRect(
                      child: Image.network(
                        productNetworkImage!,
                        height: size.width*.5,
                        alignment: Alignment.center,
                      ),

                    )
                  ]else if(_pickedImage == null)...[
                    SizedBox(
                        width: size.width*.4+10,
                        height: size.width *.4,
                        child: DottedBorder(
                          color: Colors.blue,
                            child:Center(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.image_outlined,size: 80,color: Colors.blue,),
                                  TextButton(onPressed: (){
                                    localImagePicker();
                                  }, child: const Text(
                                      "pick product image",style: TextStyle(
                                    color: Colors.blue
                                  ),),)
                                ],
                              ),
                            ))),
                  ]else...[
                    ClipRRect(
                      child: Image.file(
                        File(_pickedImage!.path),
                        height: size.width*.5,
                        alignment: Alignment.center,
                      ),

                    )
                  ],

                  if(_pickedImage != null || productNetworkImage!=null)...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(onPressed: (){
                          localImagePicker();
                        }, child: const Text(
                          "pick another image",style: TextStyle(
                            color: Colors.blue
                        ),),),
                        TextButton(onPressed: (){
                          removePickedImage();
                        }, child: const Text(
                          "remove image",style: TextStyle(
                            color: Colors.red
                        ),),)
                      ],
                    )
                  ],

                  const SizedBox(
                    height: 25,
                  ),

                  DropdownButton(
                    hint: const Text("Select Category"),
                      value: _categoryValue,
                      items: AppConstants.categoriesDropDownList, onChanged: (String? value){
                    setState(() {
                      _categoryValue=value;
                    });
                  }),
                  const SizedBox(
                    height: 25,
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          ///title product
                          TextFormField(
                            controller: _titleController,
                            key: const ValueKey('Title'),
                            maxLength: 80,
                            minLines: 1,
                            maxLines: 2,
                             keyboardType: TextInputType.multiline,
                            textInputAction: TextInputAction.newline,
                            decoration: const InputDecoration(
                              filled: true,
                              contentPadding: EdgeInsets.all(12),
                              hintText: 'Product Title',
                            ),
                            validator: (value) {
                              return MyValidators.uploadProdTexts(
                                value: value,
                                toBeReturnedString: "Please enter a valid title",
                              );
                            },
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          ///quantity price
                          Row(
                            children: [
                              Flexible(
                                flex: 1,
                                child: TextFormField(
                                  controller: _priceController,
                                  key: const ValueKey('Price \$'),
                                  keyboardType: TextInputType.number,
                                  /// constraints to can write in digits and use one coma
                                  inputFormatters: <TextInputFormatter>[
                                    FilteringTextInputFormatter.allow(
                                      RegExp(r'^(\d+)?\.?\d{0,2}'),
                                    ),
                                  ],
                                  decoration: const InputDecoration(
                                      filled: true,
                                      contentPadding: EdgeInsets.all(12),
                                      hintText: 'Price',
                                      prefix: SubtitleTextWidget(
                                        label: "\$ ",
                                        color: Colors.blue,
                                        fontSize: 16,
                                      )),
                                  validator: (value) {
                                    return MyValidators.uploadProdTexts(
                                      value: value,
                                      toBeReturnedString: "Price is missing",
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Flexible(
                                flex: 1,
                                child: TextFormField(
                                  /// constraints to can write in digits only
                                inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly
                                  ],
                                  controller: _quantityController,
                                  keyboardType: TextInputType.number,
                                  key: const ValueKey('Quantity'),
                                  decoration: const InputDecoration(
                                    filled: true,
                                    contentPadding: EdgeInsets.all(12),
                                    hintText: 'Qty',

                                  ),
                                  validator: (value) {
                                    return MyValidators.uploadProdTexts(
                                      value: value,
                                      toBeReturnedString: "Quantity is missed",
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),
                          ///product discreption
                          TextFormField(
                            key: const ValueKey('Description'),
                            controller: _descriptionController,
                            minLines: 3,
                            maxLines: 8,
                            maxLength: 1000,
                            textCapitalization: TextCapitalization.sentences,
                            decoration: const InputDecoration(
                              filled: true,
                              contentPadding: EdgeInsets.all(12),
                              hintText: 'Product description',
                            ),
                            validator: (value) {
                              return MyValidators.uploadProdTexts(
                                value: value,
                                toBeReturnedString: "Description is missed",
                              );
                            },
                            onTap: () {},
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: WidgetsBinding.instance.window.viewInsets.bottom > 0.0
                        ? 10
                        : kBottomNavigationBarHeight + 10,
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
