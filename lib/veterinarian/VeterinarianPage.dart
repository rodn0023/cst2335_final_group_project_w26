import 'package:flutter/material.dart';
import 'VeterinarianListItem.dart';

class VeterinarianPage extends StatefulWidget{
  const VeterinarianPage({super.key});

  @override
  State<VeterinarianPage> createState() => VeterinarianPageState();
}

class VeterinarianPageState extends State<VeterinarianPage> {
  late TextEditingController nameController;
  late TextEditingController birthdayController;
  late TextEditingController addressController;
  late TextEditingController universityController;

  List<VeterinarianListItem> myList = [];
  VeterinarianListItem? selectedItem;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    birthdayController = TextEditingController();
    addressController = TextEditingController();
    universityController = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    nameController.dispose();
    birthdayController.dispose();
    addressController.dispose();
    universityController.dispose();
  }

  Widget ListPage() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  hintText: "Name",
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            Expanded(
              child: TextField(
                controller: birthdayController,
                decoration: const InputDecoration(
                  hintText: "Birthday",
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            Expanded(
              child: TextField(
                controller: addressController,
                decoration: const InputDecoration(
                  hintText: "Address",
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            Expanded(
              child: TextField(
                controller: universityController,
                decoration: const InputDecoration(
                  hintText: "University",
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final veterinarianListItem = VeterinarianListItem(VeterinarianListItem.ID++, nameController.text, birthdayController.text, addressController.text, universityController.text);
                setState(() {
                  myList.add(veterinarianListItem);
                  nameController.clear();
                  birthdayController.clear();
                  addressController.clear();
                  universityController.clear();
                });
              },
              child: const Text("Add"),
            ),
          ],
        ),
        if (myList.isEmpty)
          Text("There are no items in the list."),
        Expanded(
          child: ListView.builder(
            itemCount: myList.length,
            itemBuilder: (context, rowNum) {
              return GestureDetector(child:
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("${rowNum + 1}. ${myList[rowNum].name}", style: TextStyle(fontSize: 20.0)),
                  Text(" - Birthdate: ${myList[rowNum].birthday}", style: TextStyle(fontSize: 20.0)),
                  Text(" | Address: ${myList[rowNum].address}", style: TextStyle(fontSize: 20.0)),
                  Text(" | University: ${myList[rowNum].university}", style: TextStyle(fontSize: 20.0)),
                ],
              ),
                onTap: () {
                  setState(() {
                    selectedItem = myList[rowNum];
                  });
                },
              );
            },
          ),
        ),
      ],
    );
  }

  //this returns how this looks on the page
  @override
  Widget build(BuildContext context) {

    return Scaffold(appBar: AppBar(title: Text("Veterinarian Page")),
        body: ListPage()
    );
  }

}