//Dirgh
import 'package:flutter/material.dart';

class PetPage extends StatefulWidget{
  @override
  State<PetPage> createState() => PetPageState();
}

class PetPageState extends State<PetPage>
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

    return Scaffold(appBar: AppBar(title: Text("Pet Page")),
        body:
        Center(child: Text('Pet Page')
        )
    );
  }

}