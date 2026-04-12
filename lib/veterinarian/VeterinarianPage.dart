import 'package:flutter/material.dart';
import 'Veterinarian.dart';
import 'VeterinarianDAO.dart';
import 'database.dart';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import 'package:cst2335_final_group_project_w26/main.dart';
import '../AppLocalizations.dart';

class VeterinarianPage extends StatefulWidget {
  const VeterinarianPage({super.key});

  @override
  State<VeterinarianPage> createState() => VeterinarianPageState();
}

class VeterinarianPageState extends State<VeterinarianPage> {
  late EncryptedSharedPreferences prefs;

  late TextEditingController nameController;
  late TextEditingController birthdayController;
  late TextEditingController addressController;
  late TextEditingController universityController;

  late VeterinarianDAO dao;

  List<Veterinarian> veterinarianList = [];
  Veterinarian? selectedItem;

  Future<void> loadDatabase() async {
    final database = await $FloorVetDatabase
        .databaseBuilder('vet_database.db')
        .build();

    dao = database.veterinarianDAO;

    dao.findAllVeterinarians().then((list) {
      setState(() {
        veterinarianList = list;
      });
    });
  }

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () {
      MyApp.setLocale(context, Locale("en"));
    });

    loadDatabase();

    nameController = TextEditingController();
    birthdayController = TextEditingController();
    addressController = TextEditingController();
    universityController = TextEditingController();

    prefs = EncryptedSharedPreferences();

    prefs.getString("name").then((savedName) {
      nameController.text = savedName;
    });

    prefs.getString("birthday").then((savedBirthday) {
      birthdayController.text = savedBirthday;
    });

    prefs.getString("address").then((savedAddress) {
      addressController.text = savedAddress;
    });

    prefs.getString("university").then((savedUniversity) {
      universityController.text = savedUniversity;
    });
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
        title: Text(AppLocalizations.of(context)!.translate('VetAddAlertHead')!),
        content: Text(
          AppLocalizations.of(context)!.translate('VetAddAlertDesc')!,
        ),
        actions: [
          ElevatedButton(
            child: Text(AppLocalizations.of(context)!.translate('VetNo')!),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          ElevatedButton(
            child: Text(AppLocalizations.of(context)!.translate('VetYes')!),
            onPressed: () async {
              final savedName = await prefs.getString("name");
              final savedBirthday = await prefs.getString("birthday");
              final savedAddress = await prefs.getString("address");
              final savedUniversity = await prefs.getString("university");

              setState(() {
                nameController.text = savedName;
                birthdayController.text = savedBirthday;
                addressController.text = savedAddress;
                universityController.text = savedUniversity;
              });

              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  void helpAlert() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.translate('VetHelpAlertHead')!),
        content: Text(
            AppLocalizations.of(context)!.translate('VetHelpAlertDesc')!,
        ),
        actions: [
          ElevatedButton(
            child: Text(AppLocalizations.of(context)!.translate('VetClose')!),
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

  Widget reactiveLayout() {
    var size = MediaQuery.of(context).size;
    var height = size.height;
    var width = size.width;

    if ((width > height) && (width > 720)) {
      return Row(
        children: [
          Expanded(flex: 3, child: ListPage()),
          Expanded(
            flex: 1,
            child: Container(
              color: Color(0xFF006341),
              child: DetailsPageDesktop(),
            ),
          ),
        ],
      );
    } else {
      if (selectedItem == null) {
        return ListPage();
      } else {
        return Container(color: Color(0xFF006341), child: DetailsPageMobile());
      }
    }
  }

  Widget ListPage() {
    var size = MediaQuery.of(context).size;
    var height = size.height;
    var width = size.width;

    return Padding(
      padding: EdgeInsets.all(10),
      child: Column(
        children: [
          Text(AppLocalizations.of(context)!.translate('VetFormMessage')!),
          (width > height && width > 720)
              ? Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: nameController,
                        decoration: InputDecoration(
                          hintText: AppLocalizations.of(context)!.translate('VetName')!,
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: birthdayController,
                        decoration: InputDecoration(
                          hintText: AppLocalizations.of(context)!.translate('VetBirthday')!,
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: addressController,
                        decoration: InputDecoration(
                          hintText: AppLocalizations.of(context)!.translate('VetAddress')!,
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: universityController,
                        decoration: InputDecoration(
                          hintText: AppLocalizations.of(context)!.translate('VetUniversity')!,
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    if (selectedItem == null)
                      Padding(
                        padding: EdgeInsets.all(10),
                        child: ElevatedButton(
                          onPressed: () async {
                            if (nameController.text.isEmpty ||
                                birthdayController.text.isEmpty ||
                                addressController.text.isEmpty ||
                                universityController.text.isEmpty) {
                              var snackBar = SnackBar(
                                content: Text(
                                    AppLocalizations.of(context)!.translate('VetFormFail')!
                                ),
                              );
                              ScaffoldMessenger.of(
                                context,
                              ).showSnackBar(snackBar);
                            } else {

                              prefs.setString("name", nameController.text);
                              prefs.setString("birthday", birthdayController.text);
                              prefs.setString("address", addressController.text);
                              prefs.setString("university", universityController.text);


                              final veterinarian = Veterinarian(
                                Veterinarian.ID++,
                                nameController.text,
                                birthdayController.text,
                                addressController.text,
                                universityController.text,
                              );
                              await dao.insertVeterinarian(veterinarian);
                              setState(() {
                                veterinarianList.add(veterinarian);
                                nameController.clear();
                                birthdayController.clear();
                                addressController.clear();
                                universityController.clear();
                              });

                              addAlert();
                            }
                          },
                          child: Text(
                            AppLocalizations.of(context)!.translate('VetAdd')!,
                            style: TextStyle(color: Color(0xFF06402B)),
                          ),
                        ),
                      ),
                    if (selectedItem != null)
                      Padding(
                        padding: EdgeInsets.all(10),
                        child: Column(
                          children: [
                            ElevatedButton(
                              onPressed: () async {
                                final updatedVet = Veterinarian(
                                  selectedItem!.id,
                                  nameController.text,
                                  birthdayController.text,
                                  addressController.text,
                                  universityController.text,
                                );

                                await dao.updateVeterinarian(updatedVet);
                                await loadDatabase();

                                setState(() {
                                  nameController.clear();
                                  birthdayController.clear();
                                  addressController.clear();
                                  universityController.clear();

                                  selectedItem = null;
                                });
                              },
                              child: Text(
                                AppLocalizations.of(context)!.translate('VetUpdate')!,
                                style: TextStyle(color: Color(0xFF06402B)),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(10),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                ),
                                child: Text(
                                  AppLocalizations.of(context)!.translate('VetDelete')!,
                                  style: TextStyle(color: Colors.white),
                                ),
                                onPressed: () async {
                                  await dao.deleteVeterinarian(selectedItem!);
                                  setState(() {
                                    veterinarianList.remove(selectedItem);
                                    nameController.clear();
                                    birthdayController.clear();
                                    addressController.clear();
                                    universityController.clear();
                                    selectedItem = null;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                )
              : Column(
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(context)!.translate('VetName')!,
                        border: OutlineInputBorder(),
                      ),
                    ),
                    TextField(
                      controller: birthdayController,
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(context)!.translate('VetBirthday')!,
                        border: OutlineInputBorder(),
                      ),
                    ),
                    TextField(
                      controller: addressController,
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(context)!.translate('VetAddress')!,
                        border: OutlineInputBorder(),
                      ),
                    ),
                    TextField(
                      controller: universityController,
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(context)!.translate('VetUniversity')!,
                        border: OutlineInputBorder(),
                      ),
                    ),
                    if (selectedItem == null)
                      Padding(
                        padding: EdgeInsets.all(10),
                        child: ElevatedButton(
                          onPressed: () async {
                            if (nameController.text.isEmpty ||
                                birthdayController.text.isEmpty ||
                                addressController.text.isEmpty ||
                                universityController.text.isEmpty) {
                              var snackBar = SnackBar(
                                content: Text(
                                  AppLocalizations.of(context)!.translate('VetFormFail')!,
                                ),
                              );
                              ScaffoldMessenger.of(
                                context,
                              ).showSnackBar(snackBar);
                            } else {

                              prefs.setString("name", nameController.text);
                              prefs.setString("birthday", birthdayController.text);
                              prefs.setString("address", addressController.text);
                              prefs.setString("university", universityController.text);


                              final veterinarian = Veterinarian(
                                Veterinarian.ID++,
                                nameController.text,
                                birthdayController.text,
                                addressController.text,
                                universityController.text,
                              );
                              await dao.insertVeterinarian(veterinarian);
                              setState(() {
                                veterinarianList.add(veterinarian);
                                nameController.clear();
                                birthdayController.clear();
                                addressController.clear();
                                universityController.clear();
                              });


                              addAlert();
                            }
                          },
                          child: const Text(
                            "Add",
                            style: TextStyle(color: Color(0xFF06402B)),
                          ),
                        ),
                      ),
                    if (selectedItem != null)
                      Padding(
                        padding: EdgeInsets.all(10),
                        child: Column(
                          children: [
                            ElevatedButton(
                              onPressed: () async {
                                final updatedVet = Veterinarian(
                                  selectedItem!.id,
                                  nameController.text,
                                  birthdayController.text,
                                  addressController.text,
                                  universityController.text,
                                );

                                await dao.updateVeterinarian(updatedVet);
                                await loadDatabase();

                                setState(() {
                                  nameController.clear();
                                  birthdayController.clear();
                                  addressController.clear();
                                  universityController.clear();

                                  selectedItem = null;
                                });
                              },
                              child: Text(
                                AppLocalizations.of(context)!.translate('VetUpdate')!,
                                style: TextStyle(color: Color(0xFF06402B)),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(10),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                ),
                                child: Text(
                                  AppLocalizations.of(context)!.translate('VetDelete')!,
                                  style: TextStyle(color: Colors.white),
                                ),
                                onPressed: () async {
                                  await dao.deleteVeterinarian(selectedItem!);
                                  setState(() {
                                    veterinarianList.remove(selectedItem);
                                    nameController.clear();
                                    birthdayController.clear();
                                    addressController.clear();
                                    universityController.clear();
                                    selectedItem = null;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),

          if (veterinarianList.isEmpty) Text("There are no items in the list."),
          Expanded(
            child: ListView.builder(
              itemCount: veterinarianList.length,
              itemBuilder: (context, rowNum) {
                return GestureDetector(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "${rowNum + 1}. ${veterinarianList[rowNum].name}",
                        style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "${AppLocalizations.of(context)!.translate('VetDetailsBirthdate')!} ${veterinarianList[rowNum].birthday}",
                        style: TextStyle(fontSize: 20.0),
                      ),
                      Text(
                        "${AppLocalizations.of(context)!.translate('VetAddress')!}: ${veterinarianList[rowNum].address}",
                        style: TextStyle(fontSize: 20.0),
                      ),
                      Text(
                        "${AppLocalizations.of(context)!.translate('VetUniversity')!}: ${veterinarianList[rowNum].university}",
                        style: TextStyle(fontSize: 20.0),
                      ),
                      Text(""),
                    ],
                  ),
                  onTap: () {
                    setState(() {
                      selectedItem = veterinarianList[rowNum];

                      nameController.text = selectedItem!.name;
                      birthdayController.text = selectedItem!.birthday;
                      addressController.text = selectedItem!.address;
                      universityController.text = selectedItem!.university;
                    });
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget DetailsPageDesktop() {
    if (selectedItem != null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "${AppLocalizations.of(context)!.translate('VetDetailsName')!}${selectedItem!.name}",
                style: TextStyle(fontSize: 20.0, color: Colors.white),
              ),
              Text(
                "${AppLocalizations.of(context)!.translate('VetDetailsBirthdate')!}${selectedItem!.birthday}",
                style: TextStyle(fontSize: 20.0, color: Colors.white),
              ),
              Text(
                "${AppLocalizations.of(context)!.translate('VetDetailsAddress')!}${selectedItem!.address}",
                style: TextStyle(fontSize: 20.0, color: Colors.white),
              ),
              Text(
                "${AppLocalizations.of(context)!.translate('VetDetailsUniversity')!}${selectedItem!.university}",
                style: TextStyle(fontSize: 20.0, color: Colors.white),
              ),
              Text(
                "${AppLocalizations.of(context)!.translate('VetDetailsID')!}${selectedItem!.id}",
                style: TextStyle(fontSize: 20.0, color: Colors.white),
              ),

              ElevatedButton(
                onPressed: () {
                  setState(() {
                    nameController.clear();
                    birthdayController.clear();
                    addressController.clear();
                    universityController.clear();
                    selectedItem = null;
                  });
                },
                child: Text(
                  AppLocalizations.of(context)!.translate('VetClose')!,
                  style: TextStyle(color: Color(0xFF06402B)),
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      return Center(
        child: Text(
          AppLocalizations.of(context)!.translate('VetSelection')!,
          style: TextStyle(
            fontSize: 21.0,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }
  }

  Widget DetailsPageMobile() {
    if (selectedItem != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "${AppLocalizations.of(context)!.translate('VetDetailsName')!}${selectedItem!.name}",
              style: TextStyle(fontSize: 22.0, color: Colors.white),
            ),
            Text(
              "${AppLocalizations.of(context)!.translate('VetDetailsBirthdate')!}${selectedItem!.birthday}",
              style: TextStyle(fontSize: 22.0, color: Colors.white),
            ),
            Text(
              "${AppLocalizations.of(context)!.translate('VetDetailsAddress')!}${selectedItem!.address}",
              style: TextStyle(fontSize: 22.0, color: Colors.white),
            ),
            Text(
              "${AppLocalizations.of(context)!.translate('VetDetailsUniversity')!}${selectedItem!.university}",
              style: TextStyle(fontSize: 22.0, color: Colors.white),
            ),
            Text(
              "${AppLocalizations.of(context)!.translate('VetDetailsID')!}${selectedItem!.id}",
              style: TextStyle(fontSize: 22.0, color: Colors.white),
            ),

            Column(
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    hintText: "Name",
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                TextField(
                  controller: birthdayController,
                  decoration: const InputDecoration(
                    hintText: "Birthday",
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                TextField(
                  controller: addressController,
                  decoration: const InputDecoration(
                    hintText: "Address",
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                TextField(
                  controller: universityController,
                  decoration: const InputDecoration(
                    hintText: "University",
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final updated = Veterinarian(
                      selectedItem!.id,
                      nameController.text,
                      birthdayController.text,
                      addressController.text,
                      universityController.text,
                    );

                    await dao.updateVeterinarian(updated);

                    await loadDatabase();

                    setState(() {
                      nameController.clear();
                      birthdayController.clear();
                      addressController.clear();
                      universityController.clear();

                      selectedItem = null;
                    });
                  },
                  child: Text(
                    AppLocalizations.of(context)!.translate('VetUpdate')!,
                    style: TextStyle(color: Color(0xFF06402B)),
                  ),
                ),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: () async {
                    await dao.deleteVeterinarian(selectedItem!);

                    setState(() {
                      veterinarianList.remove(selectedItem);
                      selectedItem = null;
                    });
                  },
                  child: Text(AppLocalizations.of(context)!.translate('VetDelete')!,
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            ),

            ElevatedButton(
              onPressed: () {
                setState(() {
                  nameController.clear();
                  birthdayController.clear();
                  addressController.clear();
                  universityController.clear();
                  selectedItem = null;
                });
              },
              child: Text(AppLocalizations.of(context)!.translate('VetClose')!, style: TextStyle(color: Color(0xFF06402B))),
            ),
          ],
        ),
      );
    } else {
      return Center(
        child: Text(
          AppLocalizations.of(context)!.translate('VetSelection')!,
          style: TextStyle(
            fontSize: 21.0,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.translate('VetPage')!),
        actions: [
          Padding(
            padding: EdgeInsets.all(10),
            child: OutlinedButton(
              onPressed: () {
                MyApp.setLocale(context, Locale("en", "CA"));
              },
              child: Text(AppLocalizations.of(context)!.translate('VetEnglish')!, style: TextStyle(color: Color(0xFF06402B))),
            ),
          ),

          Padding(
            padding: EdgeInsets.all(10),
            child: OutlinedButton(
              onPressed: () {
                MyApp.setLocale(context, Locale("fr"));
              },
              child: Text(AppLocalizations.of(context)!.translate('VetFrench')!, style: TextStyle(color: Color(0xFF06402B))),
            ),
          ),

          Padding(
            padding: EdgeInsets.all(10),
            child: OutlinedButton(
              onPressed: () {
                helpAlert();
              },
              child: Text(AppLocalizations.of(context)!.translate('VetHelp')!, style: TextStyle(color: Color(0xFF06402B))),
            ),
          ),
        ],
      ),
      body: reactiveLayout(),
    );
  }
}