import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget{

  const MyApp ({super.key});

  @override
  Widget build(BuildContext context)  {

    return  MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
       backgroundColor: Colors.white10,
  appBar: AppBar(
  backgroundColor: Colors.deepPurple,
  leading: Icon(Icons.menu , color: Colors.white,size: 30,),
  actions: [
    IconButton
      (onPressed: (){},
          icon: Icon(
            Icons.logout,
            color: Colors.white,
            size: 30,
          ),
      ),
  ],
  
),

       body: Center(
         child: Container(
           height: 300,
           width: 300,
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(20),
          ),

           child: Icon(

             Icons.favorite,
             color: Colors.white,
             size:100,




           ),
         ),
       ),
      ),

    );

  }
}

