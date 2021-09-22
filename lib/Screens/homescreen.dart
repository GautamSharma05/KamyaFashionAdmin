

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:textfield_tags/textfield_tags.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String gender = 'Men';
  List listItem = ['Men','Women','Kids'];
  List sizeList = [];

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _productName = TextEditingController();
  final TextEditingController _productSellingPrice = TextEditingController();
  final TextEditingController _productDescription = TextEditingController();
  final TextEditingController _productCategory = TextEditingController();
  final TextEditingController _productSubCategory = TextEditingController();

  CollectionReference product =
      FirebaseFirestore.instance.collection('Products');

  Future<void> addProduct() {
    return product
        .doc(gender)
        .collection('subtype')
        .doc(_productCategory.text)
        .collection(_productSubCategory.text)
        .add({
          'ProductCategory': _productSubCategory.text,
          'ProductName': _productName.text,
          'ProductSellingPrice': _productSellingPrice.text,
          'ProductDescription': _productDescription.text,
          'ProductSize': sizeList,
        })
        .then((value) => print('Successfully added'))
        .catchError((error) => print("Failed to add user: $error"));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Kamya Fashion Admin'),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
            child: Column(
              children: [
                DropdownButton(
                    hint: const Text('Select Man,Women and Kids'),
                    icon: const Icon(Icons.arrow_drop_down),
                    value: gender,
                    onChanged: (newValue) {
                      setState(() {
                        gender = newValue.toString();
                      });
                    },
                    items: listItem
                        .map((valueItem) => DropdownMenuItem(
                              value: valueItem,
                              child: Text(valueItem),
                            ))
                        .toList()),
                const SizedBox(
                  height: 20,
                ),
                TextFormField(
                  controller: _productCategory,
                  decoration: const InputDecoration(
                    hintText: "Ex- Tshirt ,Please Use First Letter Capital",
                    labelText: "Product Category",
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                TextFormField(
                  controller: _productSubCategory,
                  decoration: const InputDecoration(
                    hintText: "Ex- TshirtProduct ,if Tshirt then Tsirt Product",
                    labelText: "Product Sub Category",
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                TextFormField(
                  controller: _productName,
                  decoration: const InputDecoration(
                    hintText: "Enter Product Name",
                    labelText: "Product Name",
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                TextFormField(
                  controller: _productSellingPrice,
                  decoration: const InputDecoration(
                    hintText: "Enter Product Price",
                    labelText: "Product Price",
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                TextFormField(
                  controller: _productDescription,
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  decoration: const InputDecoration(
                    hintText: "Enter Product Description",
                    labelText: "Product Description",
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                TextFieldTags(
                  onTag: (String tag) {
                    sizeList.add(tag);
                  },
                  onDelete: (String tag) {
                    sizeList.remove(tag);
                  },
                  textFieldStyler: TextFieldStyler(),
                  tagsStyler: TagsStyler(
                      tagTextStyle:
                          const TextStyle(fontWeight: FontWeight.bold),
                      tagDecoration: BoxDecoration(
                        color: Colors.blue[300],
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      tagCancelIcon: Icon(Icons.cancel,
                          size: 18.0, color: Colors.blue[900]),
                      tagPadding: const EdgeInsets.all(6.0)),
                ),
                ElevatedButton(
                    onPressed: () {
                      addProduct();
                    }, child: const Text('Add Product'))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
