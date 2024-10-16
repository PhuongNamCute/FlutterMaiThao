import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CRUDEoperation extends StatefulWidget {
  const CRUDEoperation({super.key});

  @override
  State<CRUDEoperation> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<CRUDEoperation> {
  //TEXT EDITING CONTROLLER
  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController typeController = TextEditingController();
  final CollectionReference myProducts =
      FirebaseFirestore.instance.collection("Product");

  // CREATE
  Future<void> create() async {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return myDialogBox(
            name: "Create Product",
            condition: "Create",
            onPressed: () {
              String name = nameController.text;
              String price = priceController.text;
              String type = typeController.text;
              addProducts(name, price, type);
              Navigator.pop(context);
            },
          );
        });
  }

  void addProducts(String name, String price, String type) {
    myProducts.add({
      "Name": name,
      "Price": price,
      "Type": type,
    });
  }

  //UPDATE PRODUCT
  Future<void> update(DocumentSnapshot documentSnapshot) async {
    nameController.text = documentSnapshot["Name"];
    priceController.text = documentSnapshot["Price"];
    typeController.text = documentSnapshot["Type"];
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return myDialogBox(
            name: "Update Product",
            condition: "Update",
            onPressed: () async {
              String name = nameController.text;
              String price = priceController.text;
              String type = typeController.text;

              await myProducts.doc(documentSnapshot.id).update({
                "Name": name,
                "Price": price,
                "Type": type,
              });
              nameController.text = "";
              priceController.text = "";
              typeController.text = "";
              Navigator.pop(context);
            },
          );
        });
  }

  //DELETE PRODUCT
  Future<void> delete(String itemID) async {
    await myProducts.doc(itemID).delete();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: Colors.red,
        duration: Duration(seconds: 2),
        content: Text("Delete successfully"),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[100],
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.blue,
        title: const Text("Product Form"),
      ),
      body: StreamBuilder(
          stream: myProducts.snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
            if (streamSnapshot.hasData) {
              return ListView.builder(
                  itemCount: streamSnapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final DocumentSnapshot documentSnapshot =
                        streamSnapshot.data!.docs[index];
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Material(
                        elevation: 5,
                        borderRadius: BorderRadius.circular(20),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ListTile(
                            title: Text(
                              documentSnapshot["Name"],
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 20.0),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(documentSnapshot["Price"]),
                                Text(documentSnapshot["Type"]),
                              ],
                            ),
                            trailing: SizedBox(
                              width: 100,
                              child: Row(
                                children: [
                                  IconButton(
                                    onPressed: () => update(documentSnapshot),
                                    icon: const Icon(Icons.edit),
                                  ),
                                  IconButton(
                                    onPressed: () =>
                                        delete(documentSnapshot.id),
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  });
            }
            return const Center(
              child: CircularProgressIndicator(),
            );
          }),

      //for create new project  icon
      floatingActionButton: FloatingActionButton(
        onPressed: create,
        backgroundColor: Colors.blue,
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }

  Dialog myDialogBox({
    required String name,
    required String condition,
    required VoidCallback onPressed,
  }) =>
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(),
                  Text(
                    name,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18.0),
                  ),
                  IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(
                        Icons.close,
                      ))
                ],
              ),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                    labelText: "Enter the Name", hintText: "eg . Ao Polo"),
              ),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(
                    labelText: "Enter the Price", hintText: "eg . 1000"),
              ),
              TextField(
                controller: typeController,
                decoration: const InputDecoration(
                    labelText: "Enter the Type", hintText: "eg . Ao mua he"),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: onPressed,
                child: Text(condition),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      );
}
