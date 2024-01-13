String formatDate(String inputString) {
  try {
    DateTime dateTime = DateTime.parse(inputString);
    String formattedDate =
        "${dateTime.day} ${getMonthName(dateTime.month)} ${dateTime.year}";
    return formattedDate;
  } catch (e) {
    print("Error parsing date: $e");
    return "Invalid Date";
  }
}

String getMonthName(int month) {
  switch (month) {
    case 1:
      return "Jan";
    case 2:
      return "Feb";
    case 3:
      return "Mar";
    case 4:
      return "Apr";
    case 5:
      return "May";
    case 6:
      return "Jun";
    case 7:
      return "Jul";
    case 8:
      return "Aug";
    case 9:
      return "Sep";
    case 10:
      return "Oct";
    case 11:
      return "Nov";
    case 12:
      return "Dec";
    default:
      return "";
  }
}
