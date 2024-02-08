String formatDate(String timeString) {
  try {
    DateTime? dateTime = parseDateTime(timeString);
    if (dateTime == null) return '';

    String period = getPeriod(dateTime.hour);

    var year = dateTime.year.toString().padLeft(2, '0');
    var month = dateTime.month.toString().padLeft(2, '0');
    var day = dateTime.day.toString().padLeft(2, '0');
    return '$year-$month-$day $period';
  } catch (e) {
    return '';
  }
}

DateTime? parseDateTime(String inputDateTimeString) {
  RegExp regExp =
      RegExp(r'(\d{4})[:-](\d{2})[:-](\d{2}) (\d{2}):(\d{2}):(\d{2})');
  Match? match = regExp.firstMatch(inputDateTimeString);
  if (match != null) {
    int year = int.parse(match.group(1)!);
    int month = int.parse(match.group(2)!);
    int day = int.parse(match.group(3)!);
    return DateTime(year, month, day);
  }
  return null;
}

String getPeriod(int hour) {
  if (hour >= 0 && hour < 6) {
    return '早晨';
  } else if (hour >= 6 && hour < 12) {
    return '上午';
  } else if (hour == 12) {
    return '中午';
  } else if (hour > 12 && hour < 18) {
    return '下午';
  } else {
    return '晚上';
  }
}
