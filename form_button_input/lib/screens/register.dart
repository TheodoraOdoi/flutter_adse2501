// Dart file to illustrate a simple

// Import the flutter material package
import 'package:flutter/material.dart';

// Import our rounded button widget
import '../widgets/rounded_button.dart';

// TODO: Add the main method here to make this application's launch point

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  // Form constants
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;

  // Method to submit the form
  void _submitForm()
  {
    if(_formKey.currentState!.validate())
      {
        // You can send the form data to your backend or next screen from here
        print("Name: ${_nameController.text}");
        print("Email: ${_emailController.text}");
        print("Password: ${_passwordController.text}");

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Registration Successful")),);
      }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Sign Up"),),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [

              // Full Name
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: "Full Name",
                  border: OutlineInputBorder(),
                ),
                validator: (value)
                {
                  if(value == null || value.trim().isEmpty)
                    {return "Please enter your full name";}
                  return null;
                }
              ),
              SizedBox(height: 17,),

              // email
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: "Email Address",
                  border: OutlineInputBorder(),
                ),
                validator: (value)
                {
                  if(value == null || value.trim().isEmpty)
                    {return "Please enter your email address";}
                  if(!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value))
                    {return "Please enter your email address";}
                  return null;
                }
              ),
              SizedBox(height: 17,),

              // Password
              TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: "Password",
                    border: OutlineInputBorder(),
                    suffixIcon: IconButton(onPressed: (){
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    }, icon: Icon(_obscurePassword ? Icons.visibility_off_rounded :
                    Icons.visibility_rounded
                    )
                    ),
                  ),
                  obscureText: _obscurePassword,
                  validator: (value)
                  {
                    if(value == null || value.length < 6)
                    {return "PPassword must be at least 6 characters";}
                    return null;
                  }
              ),
              SizedBox(height: 17,),

              // Confirm Password
              TextFormField(
                  controller: _confirmPasswordController,
                  decoration: InputDecoration(
                    labelText: "Confirm Password",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value)
                  {
                    if(value != _passwordController.text)
                    {return "Passwords do not match!";}
                    return null;
                  }
              ),
              SizedBox(height: 17,),

              // Submit button
              RoundedButton(
                text: "Register",
                colour: Theme.of(context).primaryColor,
                onPressed: _submitForm,
              ),
            ],
          ),
        ),
      )
    );
  }
}
