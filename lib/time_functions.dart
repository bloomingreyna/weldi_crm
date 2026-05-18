String determineMeridiem(int hour) {
  if (hour < 12) {
    return "AM";
  }
  return "PM";
}

String moduloHour(int hour) {
  if (hour == 0) {
    return '12';
  } else if (hour > 12) {
    return (hour - 12).toString();
  }
  return hour.toString();
}

String formatMinute(int minute) {
  if (minute < 10) {
    return '0$minute';
  }
  return minute.toString();
}