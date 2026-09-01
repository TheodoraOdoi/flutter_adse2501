// Dart file to illustrate various flutter input widgets

// Import the flutter material package
import 'package:flutter/material.dart';

class InputScreen extends StatefulWidget {
  const InputScreen({super.key});

  @override
  State<InputScreen> createState() => _InputScreenState();
}

class _InputScreenState extends State<InputScreen> {
  // Screen constants
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _textController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  bool _switchValue = false;
  bool _checkboxValue = false;

  bool _switchListTileValue = false;
  String? _selectedPizzaSize;
  String? _selectedPizzaCrust;

  // Pizza size and toppings
  final List<String> _pizzaSizes = ['Small', 'Medium', 'Large', 'X-Large'];
  final Map<String, bool> pizzaToppings =
  {
    'Pepperoni': false,
    'Mushrooms': false,
    'Onion': false,
    'Sausage': false,
    'Olives': false,
  };

  @override
  void dispose() {
    _textController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Input widgets Demonstration"),
        leading: IconButton(onPressed: () =>
            Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Text Field
            const Text("TextField:", style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextFormField(
              controller: _textController,
              decoration: const InputDecoration(
                hintText: "Enter some text",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 17),

            // Text Form Field with validation
            const Text("TextFormField (Email):", style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: "Email",
                hintText: "Enter your email address",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your email address';
                }
                if (!value.contains('a')) {
                  return 'Please enter a valid email address';
                }
                return null;
              },
            ),
            const SizedBox(height: 17),

            // Checkbox for simple boolean
            Row(
              children:[
                const Text(
                    "I agree to the terms and conditions",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Checkbox(value: _checkboxValue, onChanged: (bool? value) {
                  setState(() {
                    _checkboxValue = value!;
                  });
                },
                ),
              ],
            ),

            // Pizza Toppings Checkbox
            const Text(
              "Pizza Toppings:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            ...pizzaToppings.entries.map((entry) {
              return CheckboxListTile(
                title: Text(entry.key),
                value: entry.value,
                onChanged: (bool? value) {
                  setState(() {
                    pizzaToppings[entry.key] = value?? false;
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
              );
            }),

            // Switch
            const Text("Enable Notifications",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Switch(
              value: _switchValue,
              onChanged: (bool value) {
                setState(() {
                  _switchValue = value;
                });
              },
            ),

            // SwitchListTile
            SwitchListTile(
              title: const Text("Dark Mode", style: TextStyle(fontWeight: FontWeight.bold),),
              value: _switchListTileValue,
              onChanged: (bool value) {
                setState(() {
                  _switchListTileValue = value;
                });
              },
              secondary: const Icon(Icons.dark_mode_rounded),
            ),

            // Radiobuttons for pizza size
            const Text("Pizza Size:", style: TextStyle(fontWeight: FontWeight.bold),),
            ..._pizzaSizes.map((size) {
              return RadioListTile<String>(
                title: Text(size),
                value: size,
                groupValue: _selectedPizzaSize,
                onChanged: (String? value) {
                setState(() {
                  _selectedPizzaSize = value;
                });
              },
            );
            }).toList(),

            // Radiobuttons for crust type
            const Text(
              'Crust Type', style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Column(
              children: [
                RadioListTile(
                  title: const Text('Thin Crust'),
                  value: 'Thin',
                 groupValue: _selectedPizzaCrust,
                  onChanged: (String? value){
                    setState(() {
                      _selectedPizzaCrust = value;
                    });
                  },
                ),
                RadioListTile(
                  title: const Text('Thick Crust'),
                  value: 'Thick',
                  groupValue: _selectedPizzaCrust,
                  onChanged: (String? value) {
                    setState(() {
                      _selectedPizzaCrust = value;
                    });
                  },
                ),
                RadioListTile(
                  title: const Text('Stuffed Crust'),
                  value: 'Stuffed',
                  groupValue: _selectedPizzaCrust,
                  onChanged: (String? value) {
                    setState(() {
                      _selectedPizzaCrust = value;
                    });
                  },
                ),
              ],
            ),

            // Submit buttons to show selections
            const SizedBox(height: 20,),
            ElevatedButton(
              onPressed: ()
                  {
                    // First validate the form fields
                    if(!_formKey.currentState!.validate()){return;}
                    // check whether the user has selected a pizza size
                    if(_selectedPizzaSize == null){
                      showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text("Pizza size required"),
                            content: const Text("Please select the size of your pizza"),
                            actions: [
                              TextButton(
                                  onPressed: () => Navigator.pop(context),
                                child: const Text("OK"),
                              ),
                            ],
                          )
                      );
                      return;
                    }
                    // check whether the user has selected a pizza size
                    if(_selectedPizzaCrust == null){
                      showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text("Pizza crust required"),
                            content: const Text("Please select the pizza's crust type"),
                            actions: [
                              TextButton(
                                  onPressed: () => Navigator.pop(context),
                                child: const Text("OK"),
                              ),
                            ],
                          )
                      );
                      return;
                    }

                    // show a dialog with all selected values
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text("Order Summary"),
                        content: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if(_textController.text.isNotEmpty)
                                Padding(padding: const EdgeInsets.only(bottom: 8.0),
                                  child: Text("Note: ${_textController.text}"),
                                ),
                              Text("Email: ${_emailController.text}"),
                              if(_checkboxValue)
                                const Text("✔ Agreed to terms and conditions"),
                              const SizedBox(height: 10),
                              const Text("Your pizza order:", style: TextStyle(fontWeight: FontWeight.bold),),
                              Text("Size: $_selectedPizzaSize"),
                              Text("Crust: $_selectedPizzaCrust"),
                              if(pizzaToppings.entries.any((e) => e.value))...[
                                const Text("◆ Toppings:", style: TextStyle(fontWeight: FontWeight.bold),),
                                ...pizzaToppings.entries
                                  .where((e) => e.value)
                                  .map((e) => Text("- ${e.key}"))
                                  .toList(),
                              ],
                              const SizedBox(height: 10),
                              if(_switchValue)
                                const Text("🔔 You will receive your order notifications"),
                              if(_switchListTileValue)
                                const Text("🌙 Dark mode is enabled"),
                            ],
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("Cancel")
                            ),
                            ElevatedButton(
                                onPressed: (){
                                  // Here you would typically process the pizza order
                                  Navigator.pop(context); // close the dialog
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text("Order placed successfully!🍕"),
                                        backgroundColor: Colors.green,
                                      ),
                                  );
                                },
                                child: const Text("Confirm Order"),
                            ),
                        ],
                      ),
                    );
                  },
              child: const Text("Submit"),
            ),
          ],
        ),
      ),
    );
  }
}
