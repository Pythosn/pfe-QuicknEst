import 'package:flutter/material.dart';


class CustomScaffold extends StatelessWidget {
  const CustomScaffold({super.key, this.child});
final Widget? child;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color:Colors.black),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body:Stack(
        children:[
          SafeArea(
            child:child!,

            )
        ],
        )
        );
  }
}