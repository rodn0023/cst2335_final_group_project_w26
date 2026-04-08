import 'package:flutter/material.dart';
import 'Veterinarian.dart';
import 'database.dart';

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

  late var dao;

  List<Veterinarian> veterinarianList = [];
  Veterinarian? selectedItem;


  Future<void> loadDatabase() async {
    final database = await $FloorVetDatabase
        .databaseBuilder('vet_database.db')
        .build();

    dao = database.veterinarianDAO;


    dao.findAllVeterinarians().then(
            (list) {
          setState((){veterinarianList = list;
          } );
        });
  }

  @override
  void initState() {
    super.initState();

    loadDatabase();

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

  Widget reactiveLayout(){

    var size = MediaQuery.of(context).size;
    var height = size.height;
    var width = size.width;

    if( (width>height) && (width > 720)) {
      return Row(
          children:[
            Expanded(flex: 1,
                child: ListPage()),
            Expanded(flex: 1,
                child: Container(child: DetailsPage()))
          ]);
    }
    else{
      if(selectedItem == null){
        return ListPage();
      }
      else
      {
        return Container(color: Colors.lightBlueAccent, child: DetailsPage());
      }
    }
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
              onPressed: () async {
                final veterinarian = Veterinarian(Veterinarian.ID++, nameController.text, birthdayController.text, addressController.text, universityController.text);
                await dao.insertVeterinarian(veterinarian);
                setState(() {
                  veterinarianList.add(veterinarian);
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
        if (veterinarianList.isEmpty)
          Text("There are no items in the list."),
        Expanded(
          child: ListView.builder(
            itemCount: veterinarianList.length,
            itemBuilder: (context, rowNum) {
              return GestureDetector(child:
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("${rowNum + 1}. ${veterinarianList[rowNum].name}", style: TextStyle(fontSize: 15.0)),
                  Text(" - Birthdate: ${veterinarianList[rowNum].birthday}", style: TextStyle(fontSize: 15.0)),
                  Text(" | Address: ${veterinarianList[rowNum].address}", style: TextStyle(fontSize: 15.0)),
                  Text(" | University: ${veterinarianList[rowNum].university}", style: TextStyle(fontSize: 15.0)),
                ],
              ),
                onTap: () {
                  setState(() {
                    selectedItem = veterinarianList[rowNum];
                  });
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget DetailsPage() {
    if (selectedItem != null) {
      return Center(child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Veterinarian Name: ${selectedItem!.name}", style: TextStyle(fontSize: 25.0)),
          Text("Birthdate: ${selectedItem!.birthday}", style: TextStyle(fontSize: 25.0)),
          Text("Address: ${selectedItem!.address}", style: TextStyle(fontSize: 25.0)),
          Text("University: ${selectedItem!.university}", style: TextStyle(fontSize: 25.0)),
          Text("Database ID: ${selectedItem!.id}", style: TextStyle(fontSize: 25.0)),

          ElevatedButton(
            child: Text("Delete Item"),
            onPressed: () async {
              await dao.deleteVeterinarian(selectedItem!);
              setState(() {
                veterinarianList.remove(selectedItem);
                selectedItem = null;
              });
            },
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                selectedItem = null;
              });
            },
            child: Text("Close"),
          ),
        ],
      ));
    } else {
      return Center(child: Text("Nothing Selected!", style: TextStyle(fontSize: 25.0)));
    }
  }

  //this returns how this looks on the page
  @override
  Widget build(BuildContext context) {

    return Scaffold(appBar: AppBar(title: Text("Veterinarian Page")),
        body: reactiveLayout()
    );
  }

}