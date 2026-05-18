import 'package:flutter/material.dart';

import 'job_scheduler_screen.dart';
import 'schedule_screen.dart';
import 'ui_elements.dart';
import 'visited_homes_screen.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    void goToJobScheduler() {
      Navigator.push(
          context,
          MaterialPageRoute<void>(
              builder: (context) => JobScheduler()
          )
      );
    }

    void goToSchedule() {
      Navigator.push(
          context,
          MaterialPageRoute<void>(
              builder: (context) => Schedule()
          )
      );
    }

    void goToVisitedHomes() {
      Navigator.push(
          context,
          MaterialPageRoute<void>(
              builder: (context) => VisitedHomes()
          )
      );
    }

    return Scaffold(
        appBar: AppBar(
            title: Text(
                'WELDI\'S CLEANING',
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
                  RoundedElevatedButton(goToJobScheduler, EasyText("New Job", 30, Colors.white), 30, 200, 100, const Color.fromARGB(255, 35, 87, 82)),
                  SizedBox(height: 10),
                  RoundedElevatedButton(goToSchedule, EasyText("See All Jobs", 30, Colors.white), 30, 200, 100, const Color.fromARGB(255, 35, 87, 82)),
                  SizedBox(height: 10),
                  RoundedElevatedButton(goToVisitedHomes, EasyText("Visited Homes", 30, Colors.white), 30, 200, 100, const Color.fromARGB(255, 35, 87, 82)),
                  SizedBox(height: 10),
                  EasyText('NOTE: This app is still in development. Certain features may be buggy or unimplemented.', 18, Colors.red)
                ]
            )
        )
    );
  }
}