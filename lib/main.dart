import 'package:flutter/material.dart';
import 'petowner/PetOwnerPage.dart';
import 'pet/PetPage.dart';
import 'vaccine/VaccinePage.dart';
import 'veterinarian/VeterinarianPage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        "/": (context) => MyHomePage(title: "Pet Clinic"),
        "/petOwnerPage": (context) => PetOwnerPage(),
        "/petPage": (context) => PetPage(),
        "/vaccinePage": (context) => VaccinePage(),
        "/veterinarianPage": (context) => VeterinarianPage(),
      },
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      initialRoute: "/",
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.all(10),
              child: ElevatedButton(
                child: Text("Pet Owner Page"),
                onPressed: () {
                  Navigator.pushNamed(context, "/petOwnerPage");
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.all(10),
              child: ElevatedButton(
                child: Text("Pet Page"),
                onPressed: () {
                  Navigator.pushNamed(context, "/petPage");
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.all(10),
              child: ElevatedButton(
                child: Text("Vaccine Page"),
                onPressed: () {
                  Navigator.pushNamed(context, "/vaccinePage");
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.all(10),
              child: ElevatedButton(
                child: Text("Veterinarian Page"),
                onPressed: () {
                  Navigator.pushNamed(context, "/veterinarianPage");
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
