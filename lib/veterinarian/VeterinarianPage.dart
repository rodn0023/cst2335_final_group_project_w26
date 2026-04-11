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

  void addAlert() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Copy Fields"),
        content: Text("Do you wish to copy the fields from the previous entry?"),
        actions: [
          ElevatedButton(
            child: Text("NO"),
            onPressed: () async {
              final veterinarian = Veterinarian(Veterinarian.ID++, nameController.text, birthdayController.text, addressController.text, universityController.text);
              await dao.insertVeterinarian(veterinarian);
              setState(() {
                veterinarianList.add(veterinarian);
                nameController.clear();
                birthdayController.clear();
                addressController.clear();
                universityController.clear();
                Navigator.of(context).pop();
              });
            },
          ),
          ElevatedButton(
            child: Text("YES"),
            onPressed: () async {
              final veterinarian = Veterinarian(Veterinarian.ID++, nameController.text, birthdayController.text, addressController.text, universityController.text);
              await dao.insertVeterinarian(veterinarian);
              setState(() {
                veterinarianList.add(veterinarian);
                Navigator.of(context).pop();
              });
            },
          )
        ],
      ),
    );
  }

  void helpAlert() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("How To Use the Form"),
        content: Text("Please fill out all the form fields by clicking and typing in each box while entering accurate details for a new Veterinarian.\n"
            "Once you fill out all the fields, click the Add button to submit.\n"
            "If you want to keep the information in the form, click YES in the alert.\n"
            "If not, click NO and it will wipe the fields."),
        actions: [
          ElevatedButton(
            child: Text("Close"),
            onPressed: () async {
              setState(() {
                Navigator.of(context).pop();
              });
            },
          ),
        ],
      ),
    );
  }


  Widget reactiveLayout(){

    var size = MediaQuery.of(context).size;
    var height = size.height;
    var width = size.width;

    if( (width>height) && (width > 720)) {
      return Row(
          children:[
            Expanded(flex: 3,
                child: ListPage()),
            Expanded(flex: 1,
                child: Container(color: Color(0xFF006341), child: DetailsPage()))
          ]);
    }
    else{
      if(selectedItem == null){
        return ListPageMobile();
      }
      else
      {
        return Container(color: Color(0xFF006341), child: DetailsPage());
      }
    }
  }

  Widget ListPage() {
    return Padding(
      padding: EdgeInsets.all(10),
    child:
    Column(
      children: [
        Text("Please enter a new Veterinarian."),
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
            Padding(
            padding: EdgeInsets.all(10),
            child:
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isEmpty ||
                birthdayController.text.isEmpty ||
                addressController.text.isEmpty ||
                universityController.text.isEmpty) {
                  const snackBar = SnackBar(content: Text('Fill out all the fields before submission.'));
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                } else {addAlert();}
              },
              child: const Text("Add", style: TextStyle(color: Color(0xFF06402B))),
            ),
            )],
        ),
        if (veterinarianList.isEmpty)
          Text("There are no items in the list."),
        Expanded(
          child: ListView.builder(
            itemCount: veterinarianList.length,
            itemBuilder: (context, rowNum) {
              return GestureDetector(child:
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("${rowNum + 1}. ${veterinarianList[rowNum].name}", style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
                  Text("Birthdate: ${veterinarianList[rowNum].birthday}", style: TextStyle(fontSize: 20.0)),
                  Text("Address: ${veterinarianList[rowNum].address}", style: TextStyle(fontSize: 20.0)),
                  Text("University: ${veterinarianList[rowNum].university}", style: TextStyle(fontSize: 20.0)),
                  Text("")
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
    ));
  }

  Widget ListPageMobile() {
    return Padding(
        padding: EdgeInsets.all(10),
        child:
        Column(
          children: [
            Text("Please enter a new Veterinarian."),
                TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      hintText: "Name",
                      border: OutlineInputBorder(),
                    ),
                  ),
                TextField(
                    controller: birthdayController,
                    decoration: const InputDecoration(
                      hintText: "Birthday",
                      border: OutlineInputBorder(),
                    ),
                  ),
                TextField(
                    controller: addressController,
                    decoration: const InputDecoration(
                      hintText: "Address",
                      border: OutlineInputBorder(),
                    ),
                  ),
                TextField(
                    controller: universityController,
                    decoration: const InputDecoration(
                      hintText: "University",
                      border: OutlineInputBorder(),
                    ),
                  ),
                Padding(
                  padding: EdgeInsets.all(10),
                  child:
                  ElevatedButton(
                    onPressed: () async {
                      if (nameController.text.isEmpty ||
                          birthdayController.text.isEmpty ||
                          addressController.text.isEmpty ||
                          universityController.text.isEmpty) {
                        const snackBar = SnackBar(content: Text('Fill out all the fields before submission.'));
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      } else {addAlert();}
                    },
                    child: const Text("Add", style: TextStyle(color: Color(0xFF06402B))),
                  ),
                ),
            if (veterinarianList.isEmpty)
              Text("There are no items in the list."),
            Expanded(
              child: ListView.builder(
                itemCount: veterinarianList.length,
                itemBuilder: (context, rowNum) {
                  return GestureDetector(child:
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("${rowNum + 1}. ${veterinarianList[rowNum].name}", style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
                      Text("Birthdate: ${veterinarianList[rowNum].birthday}", style: TextStyle(fontSize: 20.0)),
                      Text("Address: ${veterinarianList[rowNum].address}", style: TextStyle(fontSize: 20.0)),
                      Text("University: ${veterinarianList[rowNum].university}", style: TextStyle(fontSize: 20.0)),
                      Text("")
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
        ));
  }

  Widget DetailsPage() {
    if (selectedItem != null) {
      return Center(child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Veterinarian Name: ${selectedItem!.name}", style: TextStyle(fontSize: 22.0, color: Colors.white)),
          Text("Birthdate: ${selectedItem!.birthday}", style: TextStyle(fontSize: 22.0, color: Colors.white)),
          Text("Address: ${selectedItem!.address}", style: TextStyle(fontSize: 22.0, color: Colors.white)),
          Text("University: ${selectedItem!.university}", style: TextStyle(fontSize: 22.0, color: Colors.white)),
          Text("Database ID: ${selectedItem!.id}", style: TextStyle(fontSize: 22.0, color: Colors.white)),

          Padding(
            padding: EdgeInsets.all(10),
            child: ElevatedButton(
              child: Text("Delete Item", style: TextStyle(color: Color(0xFF06402B))),
              onPressed: () async {
                await dao.deleteVeterinarian(selectedItem!);
                setState(() {
                  veterinarianList.remove(selectedItem);
                  selectedItem = null;
                });
              },
            )
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                selectedItem = null;
              });
            },
            child: Text("Close", style: TextStyle(color: Color(0xFF06402B))),
          ),
        ],
      ));
    } else {
      return Center(child: Text("Nothing Selected", style: TextStyle(fontSize: 21.0, color: Colors.white, fontWeight: FontWeight.bold)));
    }
  }

  //this returns how this looks on the page
  @override
  Widget build(BuildContext context) {

    return Scaffold(appBar: AppBar(title: Text("Veterinarian Page"), actions: [
      Padding(
        padding: EdgeInsets.all(10),
      child:
      OutlinedButton(onPressed: (){ helpAlert(); }, child: Text("Help", style: TextStyle(color: Color(0xFF06402B)))))]),
        body: reactiveLayout()
    );
  }

}