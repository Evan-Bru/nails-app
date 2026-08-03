class AgendaGridConfig {
  AgendaGridConfig._();

  static const int startHour = 8;
  static const int endHour = 19;
  static const int slotMinutes = 15;
  static const double slotHeight = 28;
  static const double dayColumnMinWidth = 140;
  static const double timeColumnWidth = 52;
  static const double headerHeight = 60;

  static double get hourHeight => slotHeight * (60 / slotMinutes);

  static double get totalHeight =>
      ((endHour - startHour) * 60 / slotMinutes) * slotHeight;

  static double get totalHeightWithHeader => headerHeight + totalHeight;

  static double totalWidthFor(int dayCount,
          {double dayColumnWidth = dayColumnMinWidth}) =>
      timeColumnWidth + dayCount * dayColumnWidth;

  static double offsetForTime(DateTime time) {
    final minutesFromStart = (time.hour - startHour) * 60 + time.minute;
    return (minutesFromStart / slotMinutes) * slotHeight;
  }

  static double heightForDuration(int minutes) =>
      (minutes / slotMinutes) * slotHeight;
}
