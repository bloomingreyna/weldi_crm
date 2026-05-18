import 'package:flutter/material.dart';

import 'database_functions.dart';
import 'home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDatabase();

  runApp(MaterialApp(
    home: Home(),
  ));
}

void unimplementedAlert(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        content: Text('This feature is currently unimplemented. Please come back again later!')
      );
    }
  );
}