import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import 'data_classes.dart';
import 'comparators.dart';

late Future<Database> crm_database;
List<Job> jobs = [];
List<VisitedAddress> visitedAddresses = [];

Future<void> initializeDatabase() async {
  final database = openDatabase(
    join(await getDatabasesPath(), 'crm_database.db'),
    version: 1,
    onConfigure: (db) async {
      if (await databaseExists(join(await getDatabasesPath(), 'job_database.db'))) {
        await deleteDatabase(join(await getDatabasesPath(), 'job_database.db'));
      }
    },
    onCreate: (db, version) async {
      await db.execute(
        'CREATE TABLE jobs(id INTEGER PRIMARY KEY, name TEXT, address TEXT, phoneNum TEXT, service TEXT, date TEXT, pay TEXT)'
      );

      await db.execute(
        'CREATE TABLE addresses(id INTEGER PRIMARY KEY, buildingNum TEXT, streetName TEXT, city TEXT, state TEXT, zipCode TEXT, timeOfVisit TEXT, status INTEGER)'
      );
    }
  );
  crm_database = database;
  await refreshJobs();
  await refreshAddresses();
}

int findFirstAvailableId(List<DataClass> arr) {
  List<int> ids = [];
  for (int i = 0; i < arr.length; i++) {
    ids.add(arr[i].id);
  }
  ids.sort(compareNum);

  for (int i = 1; i < ids.length; i++) {
    if (ids[i] - ids[i - 1] > 1) {
      return ids[i - 1] + 1;
    }
  }

  if (ids.isEmpty || ids[0] != 1) {
    return 1;
  }
  return ids.length + 1;
}

Future<void> insertJob(Job job) async {
  final db = await crm_database;
  await db.insert(
    'jobs',
    job.toMap(),
    conflictAlgorithm: ConflictAlgorithm.replace
  );
  refreshJobs();
}

Future<void> removeJob(int id) async {
  final db = await crm_database;
  await db.delete(
    'jobs',
    where: 'id = ?',
    whereArgs: [id]
  );
  refreshJobs();
}

Future<void> refreshJobs() async {
  final db = await crm_database;
  final List<Map<String, Object?>> jobMaps = await db.query('jobs');

  jobs = [
    for (final {
    'id': id as int,
    'name': name as String,
    'address': address as String,
    'phoneNum': phoneNum as String,
    'service': service as String,
    'date': date as String,
    'pay': pay as String
    } in jobMaps) Job(
        id,
        name,
        address,
        phoneNum,
        service,
        DateTime.parse(date),
        pay
    )
  ];
  jobs.sort(compareJobs);
}

Future<void> insertAddress(VisitedAddress address) async {
  final db = await crm_database;
  await db.insert(
      'addresses',
      address.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace
  );
  refreshAddresses();
}

Future<void> removeAddress(int id) async {
  final db = await crm_database;
  await db.delete(
    'addresses',
    where: 'id = ?',
    whereArgs: [id]
  );
  refreshAddresses();
}

Future<void> refreshAddresses() async {
  final db = await crm_database;
  final List<Map<String, Object?>> addressMaps = await db.query('addresses');

  visitedAddresses = [
    for (final {
    'id': id as int,
    'buildingNum': buildingNum as String,
    'streetName': streetName as String,
    'city': city as String,
    'state': state as String,
    'zipCode': zipCode as String,
    'timeOfVisit': timeOfVisit as String,
    'status': status as int,
    } in addressMaps) VisitedAddress(
        id,
        buildingNum,
        streetName,
        city,
        state,
        zipCode,
        DateTime.parse(timeOfVisit),
        status
    )
  ];
  visitedAddresses.sort(compareAddressTimes);
}