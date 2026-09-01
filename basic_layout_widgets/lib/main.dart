// Import the flutter material package
import 'package:flutter/material.dart';

// import the units.dart file to use the measurements therein for
// the dimensions various widgets in this file.
import 'package:basic_layout_widgets/measurements/units.dart';

void main() {
  runApp(const BasicLayoutApp());
}

class BasicLayoutApp extends StatelessWidget{
  const BasicLayoutApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Remove the debug banner
      debugShowCheckedModeBanner: false,
      home: SafeArea(
          child: Scaffold(
            appBar: AppBar(
              backgroundColor: Theme.of(context).colorScheme.inversePrimary,
              title: Text(
                "Flutter Basic Layout Widgets",
                style: TextStyle(fontSize: 25.0,),
              ),
            ),
            body: Center(
              child: ListView(
                shrinkWrap: true,
                children: [
                  Container(
                    color:Colors.lightBlue,
                    child: Column(
                      // Center the columns children along the vertical axis
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          // Add some internal spacing with the left and top side of the container
                          padding: EdgeInsets.only(left: defaultPadding, top: defaultPadding),
                          height: containerHeight,
                          width: containerWidth,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25.0),
                            color: Color(0xffff0000)
                          ),
                          child: Text("Column Widget 1", style: TextStyle(color: Colors.amberAccent),
                          ),
                        ),
                        // Add some spacing between containers using a sized box
                        SizedBox(height: 15.0,),
                        Container(
                          // Add some internal spacing with the left and top side of the container
                          padding: EdgeInsets.only(left: defaultPadding, top: defaultPadding),
                          height: containerHeight,
                          width: containerWidth,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25.0),
                              color: Color(0xffff0000)
                          ),
                          child: Text("Column Widget 2", style: TextStyle(color: Colors.amberAccent),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: defaultPadding),
                  Container(
                    color:Colors.black45,
                    padding: EdgeInsets.all(defaultPadding),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          // Add some internal spacing with the left and top side of the container
                          padding: EdgeInsets.only(left: defaultPadding, top: defaultPadding),
                          height: containerHeight,
                          width: containerWidth,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25.0),
                              color: Color(0xffff0000)
                          ),
                          child: Text("Row Widget 1", style: TextStyle(color: Colors.amberAccent),
                          ),
                        ),
                        // Add some spacing between containers using a sized box
                        SizedBox(width: defaultPadding),
                        Container(
                          // Add some internal spacing with the left and top side of the container
                          padding: EdgeInsets.only(left: defaultPadding, top: defaultPadding),
                          height: containerHeight,
                          width: containerWidth,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25.0),
                              color: Color(0xffff0000)
                          ),
                          child: Text("Row Widget 2", style: TextStyle(color: Colors.amberAccent),
                          ),
                        ),
                        // Add some spacing between containers using a sized box
                        SizedBox(width: defaultPadding),
                        Container(
                          // Add some internal spacing with the left and top side of the container
                          padding: EdgeInsets.only(left: defaultPadding, top: defaultPadding),
                          height: containerHeight,
                          width: containerWidth,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25.0),
                              color: Color(0xffff0000)
                          ),
                          child: Text("Row Widget 3", style: TextStyle(color: Colors.amberAccent),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Add an image
                  SizedBox(height: defaultPadding),
                  Text("picture from assets/images folder", textAlign: TextAlign.center,),
                  Image.asset("assets/images/bkgd.jpg"),
                  SizedBox(height: defaultPadding),
                  Text("Picture from online url", textAlign: TextAlign.center),
                  Image.network("https://Flutter.github.io/assets-for-api-docs/assets/widgets/owl.jpg",
                    fit: BoxFit.cover,
                  ),
                ],
              ),
            ),
          ),
      )
    );
  }
}


