import 'time_functions.dart';

abstract class DataClass {
  int id;

  DataClass(this.id);
}

class VisitedAddress extends DataClass {
  String buildingNum;
  String streetName;
  String city;
  String state;
  String zipCode;

  DateTime timeOfVisit;

  int status;

  VisitedAddress(super.id, this.buildingNum, this.streetName, this.city, this.state, this.zipCode, this.timeOfVisit, this.status);

  @override
  String toString() {
    return '$buildingNum $streetName, $city, $state $zipCode';
  }

  String timeToString() {
    return '${formatMinute(timeOfVisit.month)}/${formatMinute(timeOfVisit.day)}/${timeOfVisit.year - 2000} at ${moduloHour(timeOfVisit.hour)}:${formatMinute(timeOfVisit.minute)} ${determineMeridiem(timeOfVisit.hour)}';
  }

  String dateString() {
    return '${timeOfVisit.toIso8601String().substring(0, 10)} ${formatMinute(timeOfVisit.hour)}:${formatMinute(timeOfVisit.minute)}:${formatMinute(timeOfVisit.second)}';
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'buildingNum': buildingNum,
      'streetName': streetName,
      'city': city,
      'state': state,
      'zipCode': zipCode,
      'timeOfVisit': dateString(),
      'status': status
    };
  }
}

class Job extends DataClass {
  final String clientName;
  final String address;
  final String contactNum;

  final String serviceType;
  final DateTime? date;
  final String pay;

  Job(super.id, this.clientName, this.address, this.contactNum, this.serviceType, this.date, this.pay);

  String dateString() {
    return '${date!.toIso8601String().substring(0, 10)} ${formatMinute(date!.hour)}:${formatMinute(date!.minute)}:00';
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'name': clientName,
      'address': address,
      'phoneNum': contactNum,
      'service': serviceType,
      'date': dateString(),
      'pay': pay
    };
  }
}