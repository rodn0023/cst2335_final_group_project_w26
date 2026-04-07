import 'package:flutter/material.dart';

class PetOwnerPage extends StatefulWidget{
  @override
  State<PetOwnerPage> createState() => PetOwnerPageState();
}

class PetOwnerPageState extends State<PetOwnerPage>
{
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  //this returns how this looks on the page
  @override
  Widget build(BuildContext context) {

    return Scaffold(appBar: AppBar(title: Text("Pet Owner Page")),
        body:
        Center(child: Text('Pet Owner Page')
        )
    );
  }

}