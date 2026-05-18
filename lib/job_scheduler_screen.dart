import 'package:flutter/material.dart';

import 'time_functions.dart';
import 'data_classes.dart';
import 'database_functions.dart';
import 'schedule_screen.dart';
import 'ui_elements.dart';

import 'package:country_code_picker/country_code_picker.dart';

class JobScheduler extends StatefulWidget {
  const JobScheduler({super.key});

  @override
  State<JobScheduler> createState() => _JobSchedulerState();
}

class _JobSchedulerState extends State<JobScheduler> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController numController = TextEditingController();
  String? dialCode = '';

  Color? phoneColor = Colors.red;
  bool validPhone = false;

  final TextEditingController serviceController = TextEditingController();
  final TextEditingController payController = TextEditingController();

  final List<String> weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

  DateTime? selectedDate;

  bool fieldsFilled() {
    if (selectedDate == null || !validPhone) {
      return false;
    }

    List<TextEditingController> controllers = [nameController, addressController, numController, serviceController, payController];

    for (int i = 0; i < controllers.length; i++) {
      if (controllers[i].text.isEmpty) {
        return false;
      }
    }

    return true;
  }

  String scheduledDate() {
    if (selectedDate != null) {
      return '${formatMinute(selectedDate!.month)}/${formatMinute(selectedDate!.day)}/${selectedDate!.year} at ${moduloHour(selectedDate!.hour)}:${formatMinute(selectedDate!.minute)} ${determineMeridiem(selectedDate!.hour)}';
    }
    return 'None selected';
  }

  void scheduleJob() async {
    if (fieldsFilled()) {
      Job job = Job(findFirstAvailableId(jobs), nameController.text, addressController.text, parsePhoneNum(), serviceController.text, selectedDate, payController.text);
      await insertJob(job);
      await refreshJobs();

      Navigator.pop(context);
      Navigator.push(
          context,
          MaterialPageRoute<void>(
              builder: (context) => Schedule()
          )
      );

      showDialog(
          context: context,
          builder: (context) {
            String date = '${weekdays[selectedDate!.weekday - 1]}, ${selectedDate!.month}/${selectedDate!.day}/${selectedDate!.year} at ${moduloHour(selectedDate!.hour)}:${formatMinute(selectedDate!.minute)} ${determineMeridiem(selectedDate!.hour)}';
            return AlertDialog(
                content: Text('${serviceController.text} job scheduled for ${nameController.text}! Go to ${addressController.text} on $date.')
            );
          }
      );
    } else {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
                content: Text('Necessary information incomplete!')
            );
          }
      );
    }
  }

  Future<void> _showCalendar() async {
    final DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: DateTime(DateTime.now().year + 1, 12, 31)
    );

    if (pickedDate == null) {
      return;
    }

    final TimeOfDay? pickedTime = await showTimePicker(
      // ignore: use_build_context_synchronously
        context: context,
        initialTime: TimeOfDay.now()
    );

    if (pickedTime == null) {
      return;
    }

    setState(() {
      selectedDate = pickedDate.add(Duration(hours: pickedTime.hour, minutes: pickedTime.minute));
    });
  }

  void updatePhoneColor(String text, TextEditingController controller) {
    setState(() {
      String correctedString = '';
      for (int i = 0; i < text.length; i++) {
        String char = text[i];
        if (RegExp(r'\d').hasMatch(char)) {
          correctedString = correctedString + char;
        }
      }

      controller.text = correctedString;
      if (controller.text.length != 10) {
        phoneColor = Colors.red;
        validPhone = false;
      } else {
        phoneColor = Colors.grey[400];
        validPhone = true;
      }
    });
  }

  String parsePhoneNum() {
    return '$dialCode (${numController.text.substring(0, 3)}) ${numController.text.substring(3, 6)}-${numController.text.substring(6, 10)}';
  }

  void correctPayAmt(String text, TextEditingController controller) {
    setState(() {
      String correctedString = '';
      bool dotPresent = false;
      for (int i = 0; i < text.length; i++) {
        String char = text[i];
        if (RegExp(r'\d').hasMatch(char) || (char.compareTo('.') == 0 && !dotPresent)) {
          correctedString = correctedString + char;
        }

        if (char.compareTo('.') == 0) {
          dotPresent = true;
        }
      }
      dotPresent = false;

      controller.text = correctedString;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text(
                'SCHEDULE JOB',
                style: TextStyle(color: Colors.white)
            ),
            backgroundColor: Colors.grey[800],
            centerTitle: true
        ),
        backgroundColor: Colors.grey[900],
        body: Center(
            child: ListView(
                padding: EdgeInsets.all(20),
                children: [
                  Card(
                      color: Colors.grey[800],
                      child: Padding(
                          padding: EdgeInsets.all(15),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                EasyText('Client Information', 30, Colors.white),
                                Row(
                                    crossAxisAlignment: CrossAxisAlignment.baseline,
                                    textBaseline: TextBaseline.alphabetic,
                                    children: [
                                      Flexible(child: EasyText('Client name: ', 14, Colors.white)),
                                      Flexible(child: TextField(controller: nameController, style: TextStyle(color: Colors.grey[400], fontSize: 14), decoration: InputDecoration(hintText: 'John Doe', hintStyle: TextStyle(color: Colors.grey[600])),)),
                                    ]
                                ),
                                Row(
                                    crossAxisAlignment: CrossAxisAlignment.baseline,
                                    textBaseline: TextBaseline.alphabetic,
                                    children: [
                                      EasyText('Address: ', 14, Colors.white),
                                      Flexible(child: TextField(controller: addressController, style: TextStyle(color: Colors.grey[400], fontSize: 14), decoration: InputDecoration(hintText: '123 Rellym Ave, Dustbowl, CA 97843', hintStyle: TextStyle(color: Colors.grey[600]))))
                                    ]
                                ),
                                Row(
                                    crossAxisAlignment: CrossAxisAlignment.baseline,
                                    textBaseline: TextBaseline.alphabetic,
                                    children: [
                                      EasyText('Phone #:', 14, Colors.white),
                                      CountryCodePicker(
                                          flagDecoration: ShapeDecoration(shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.all(Radius.circular(5)))),
                                          initialSelection: 'US',
                                          margin: EdgeInsetsGeometry.all(10),
                                          barrierColor: Color.fromARGB(50, 134, 203, 217),
                                          textStyle: TextStyle(color: Colors.white),
                                          onChanged: (code) {dialCode = code.dialCode;},
                                          onInit: (code) {dialCode = code!.dialCode;}
                                      ),
                                      Flexible(child: TextField(controller: numController, style: TextStyle(color: phoneColor, fontSize: 14), decoration: InputDecoration(hintStyle: TextStyle(color: Colors.grey[600], fontSize: 14), hintText: 'XXXXXXXXXX'), maxLength: 10, onChanged: (String s) {updatePhoneColor(s, numController);}))
                                    ]
                                )
                              ]
                          )
                      )
                  ),
                  Card(
                      color: Colors.grey[800],
                      child: Padding(
                          padding: EdgeInsets.all(15),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                EasyText('Job Information', 30, Colors.white),
                                Row(
                                    crossAxisAlignment: CrossAxisAlignment.baseline,
                                    textBaseline: TextBaseline.alphabetic,
                                    children: [
                                      EasyText('Service: ', 14, Colors.white),
                                      Flexible(child: TextField(controller: serviceController, style: TextStyle(color: Colors.grey[400], fontSize: 14), decoration: InputDecoration(hintStyle: TextStyle(color: Colors.grey[600], fontSize: 14), hintText: 'Window cleaning, gutters, etc.')))
                                    ]
                                ),
                                Row(
                                    crossAxisAlignment: CrossAxisAlignment.baseline,
                                    textBaseline: TextBaseline.alphabetic,
                                    children: [
                                      EasyText('Choose date and time:', 14, Colors.white),
                                      IconButton(onPressed: _showCalendar, icon: Icon(Icons.calendar_month, color: Colors.amber), color: Colors.green),
                                      Flexible(child: EasyText(scheduledDate(), 14, Colors.grey[400]))
                                    ]
                                ),
                                Row(
                                    crossAxisAlignment: CrossAxisAlignment.baseline,
                                    textBaseline: TextBaseline.alphabetic,
                                    children: [
                                      Flexible(child: EasyText('Enter pay (ignore \$ sign): ', 14, Colors.white)),
                                      Flexible(child: TextField(controller: payController, style: TextStyle(color: Colors.grey[400], fontSize: 14), decoration: InputDecoration(hintStyle: TextStyle(color: Colors.grey[600], fontSize: 14), hintText: 'Hopefully a lot!'), onChanged: (String s) {correctPayAmt(s, payController);}))
                                    ]
                                )
                              ]
                          )
                      )
                  ),
                  RoundedElevatedButton(scheduleJob, EasyText('Schedule Job', 30, Colors.white), 30, 200, 50, Colors.green[800])
                ]
            )
        )
    );
  }
}