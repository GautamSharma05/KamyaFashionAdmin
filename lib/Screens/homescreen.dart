import 'dart:developer';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path/path.dart' as Path;
import 'package:image_picker/image_picker.dart';
import 'package:textfield_tags/textfield_tags.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  FirebaseStorage storage = FirebaseStorage.instance;
  List<String> urls = [];
  String gender = 'Men';
  List listItem = ['Men', 'Women', 'Kids'];
  List sizeList = [];
  final List<File> _image = [];
  final picker = ImagePicker();

  chooseImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _image.add(File(pickedFile!.path));
    });
    if (pickedFile!.path == null) retrieveLostData();
  }

  Future<void> retrieveLostData() async {
    final LostDataResponse response = await picker.retrieveLostData();
    if (response.isEmpty) {
      return;
    }
    if (response.file != null) {
      setState(() {
        _image.add(File(response.file!.path));
      });
    } else {
      print(response.file);
    }
  }

  Future uploadFile() async {
    for (var img in _image) {
      Reference ref =
          storage.ref().child('ProductPhoto/${Path.basename(img.path)}');
      await ref.putFile(img).whenComplete(() async {
        await ref.getDownloadURL().then((value) {
          urls.add(value);
        });
      });
    }
  }

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
          'ProductPicUrl': urls,
        })
        .then((value) => showDialog(
            barrierDismissible: false,
            context: context,
            builder: (ctx) =>  AlertDialog(
                  title: const Text("Notify You"),
                  content: const Text("You have Successfully upload your product in Kamya Fashion"),
                  actions: [
                   ElevatedButton(onPressed: (){
                     Navigator.push(context, MaterialPageRoute(builder: (context) => const HomeScreen()));
                   }, child: const Text('Okay'))
                  ],
                ),
    ),
    )
        .catchError((error) => log("Failed to add user: $error"));
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
                GridView.builder(
                    itemCount: _image.length + 1,
                    shrinkWrap: true,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3),
                    itemBuilder: (context, index) {
                      return index == 0
                          ? Center(
                              child: IconButton(
                                  icon: const Icon(Icons.add),
                                  onPressed: () => chooseImage()),
                            )
                          : Container(
                              margin: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                  image: DecorationImage(
                                      image: FileImage(_image[index - 1]),
                                      fit: BoxFit.cover)),
                            );
                    }),
                const SizedBox(
                  height: 20,
                ),
                SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: ElevatedButton(
                      onPressed: () {
                        uploadFile().whenComplete(() => showDialog(
                          barrierDismissible: false,
                          context: context,
                          builder: (ctx) =>  AlertDialog(
                            title: const Text("Notify You"),
                            content: const Text("You have Successfully upload your Product Image in Kamya Fashion"),
                            actions: [
                              ElevatedButton(onPressed: (){
                                Navigator.of(ctx).pop();
                              }, child: const Text('Okay'))
                            ],
                          ),
                        ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        primary: const Color(0xFFf16c83),
                      ),
                      child: const Text('Upload Image')),
                ),
                const SizedBox(
                  height: 20,
                ),
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
                    hintText: "Ex- TshirtProduct ,if Tshirt then TshirtProduct",
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
                const SizedBox(
                  height: 20,
                ),
                SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: ElevatedButton(
                      onPressed: () {
                        addProduct();
                      },
                      style: ElevatedButton.styleFrom(
                        primary: const Color(0xFFf16c83),
                      ),
                      child: const Text('Add Product')),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
