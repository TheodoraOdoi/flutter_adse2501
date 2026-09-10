// ------------------------------------
// Snackbar helper to display user feedback messages
// ----------------------------------------------------------
import 'package:flutter/material.dart';

extension SnackbarHelper on BuildContext
{
  void showMessage(String message)
  {
    if(!mounted){return;}

    ScaffoldMessenger.of(this)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message)), );
  }
}