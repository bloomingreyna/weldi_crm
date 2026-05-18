import 'data_classes.dart';

int compareNum(int a, int b) {
  if (a < b) {
    return -1;
  }
  return 1;
}

int compareJobs(Job a, Job b) {
  if (a.date!.isBefore(b.date!)) {
    return -1;
  }
  return 1;
}

int compareAddressTimes(VisitedAddress a, VisitedAddress b) {
  if (a.timeOfVisit.isBefore(b.timeOfVisit)) {
    return 1;
  }
  return -1;
}