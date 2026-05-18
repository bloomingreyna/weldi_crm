import 'package:flutter/material.dart';

import 'time_functions.dart';
import 'data_classes.dart';
import 'database_functions.dart';
import 'ui_elements.dart';
import 'comparators.dart';
import 'main.dart';
import 'job_scheduler_screen.dart';

class Schedule extends StatefulWidget {
  const Schedule({super.key});

  @override
  State<Schedule> createState() => _ScheduleState();
}

class _ScheduleState extends State<Schedule> {
  List<Widget> allJobCards = [];

  @override
  void initState() {
    super.initState();
    allJobCards = updateJobCards();
  }

  String jobDateAndTime(Job job) {
    return '${formatMinute(job.date!.month)}/${formatMinute(job.date!.day)}/${job.date!.year} at ${moduloHour(job.date!.hour)}:${formatMinute(job.date!.minute)} ${determineMeridiem(job.date!.hour)}';
  }

  void displayDeleteConfirmation(Job job) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
              content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Delete this job?'),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          IconButton(onPressed: () {Navigator.pop(context); deleteJob(job);}, icon: Icon(Icons.check, color: Colors.green)),
                          IconButton(onPressed: () {Navigator.pop(context);}, icon: Icon(Icons.close, color: Colors.red))
                        ]
                    )
                  ]
              )
          );
        }
    );
  }

  void deleteJob(Job job) async {
    await removeJob(job.id);
    await refreshJobs();
    setState(() {
      allJobCards = updateJobCards();
    });
  }

  Widget jobCard(Job job, Color? color) {
    List<String> weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

    return Card(
        color: color,
        child: Padding(
            padding: EdgeInsets.all(15),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  EasyText(job.clientName, 30, Colors.white),
                  EasyText('Address: ${job.address}', 14, Colors.white),
                  EasyText('Contact: ${job.contactNum}', 14, Colors.white),
                  EasyText('When: ${weekdays[job.date!.weekday - 1]}, ${jobDateAndTime(job)}', 14, Colors.white),
                  EasyText('Job: ${job.serviceType} for \$${job.pay}', 14, Colors.white),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        IconButton(onPressed: () {displayDeleteConfirmation(job);}, icon: Icon(Icons.check, color: Colors.green)),
                        IconButton(onPressed: () {unimplementedAlert(context);}, icon: Icon(Icons.edit, color: Colors.pink))
                      ]
                  )
                ]
            )
        )
    );
  }

  List<Widget> updateJobCards() {
    if (jobs.isEmpty) {
      return [Center(child: EasyText('No jobs scheduled...', 30, Colors.grey[700]))];
    }

    List<Widget> jobCards = [];
    List<Color?> colors = [Colors.blueGrey[800], Colors.grey[800]];
    int color = 0;

    jobs.sort(compareJobs);
    for (int i = 0; i < jobs.length; i++) {
      jobCards.add(jobCard(jobs[i], colors[color]));

      color++;
      if (color == colors.length) {
        color = 0;
      }
    }

    return jobCards;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text(
                'SCHEDULED JOBS',
                style: TextStyle(color: Colors.white)
            ),
            backgroundColor: Colors.grey[800],
            centerTitle: true
        ),
        backgroundColor: Colors.grey[900],
        body: Center(
            child: ListView(
                padding: EdgeInsets.all(20),
                children: allJobCards
            )
        ),
        floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                      builder: (context) => JobScheduler()
                  )
              );
            },
            label: Row(
                children: [
                  Icon(Icons.calendar_month),
                  Text('  Schedule new job')
                ]
            )
        )
    );
  }
}