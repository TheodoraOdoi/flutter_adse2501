// Import the flutter material package
import 'package:flutter/material.dart';

class ButtonsScreen extends StatelessWidget {
  const ButtonsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Flutter Button Demonstration"),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        actions: [
          // Example of PopupMenuButton in AppBar
          PopupMenuButton<String>(
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'settings',
                child: Text("Settings"),
              ),
              const PopupMenuItem(
                value: 'about',
                child: Text("About"),
              ),
            ],
            onSelected: (value) {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                "Flutter Buttons",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // Two columns of buttons
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // First Column
                  Expanded(
                    child: Column(
                      children: [
                        // Elevated button
                        const Text("Elevated Button"),
                        ElevatedButton(
                          onPressed: () {},
                          child: const Text("Click Me!"),
                        ),
                        const SizedBox(height: 20),

                        // TextButton
                        const Text("TextButton"),
                        TextButton(
                          onPressed: () {},
                          child: const Text("Text Button!"),
                        ),
                        const SizedBox(height: 20),

                        // OutlinedButton
                        const Text("OutlinedButton"),
                        OutlinedButton(
                          onPressed: () {},
                          child: const Text("Outlined Button!"),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),

                  // Second Column
                  Expanded(
                    child: Column(
                      children: [
                        // Icon button
                        const Text("Icon Button"),
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.favorite_rounded),
                          color: Colors.red,
                        ),
                        const SizedBox(height: 20),

                        // Dropdown Button
                        const Text("Dropdown Button"),
                        DropdownButton<String>(
                          value: 'Option 1',
                          items: <String>['Option 1', 'Option 2', 'Option 3']
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {},
                        ),
                        const SizedBox(height: 28),

                        // PopupMenuButton
                        const Text("Popup Menu Button"),
                        PopupMenuButton<String>(
                          itemBuilder: (BuildContext context) => [
                            const PopupMenuItem(
                              value: 'item1',
                              child: Text("Item 1"),
                            ),
                            const PopupMenuItem(
                              value: 'item2',
                              child: Text("Item 2"),
                            ),
                          ],
                          onSelected: (value) {},
                          child: const Text("Show Menu"),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // FloatingActionButton (positioned at the bottom)
              const Text(
                "Floating Action Button",
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Center(
                child: FloatingActionButton(
                  onPressed: () {},
                  child: const Icon(Icons.add_rounded),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}