class Formatters {
  static const int _titleMaxLength = 17;
  static const int _titleTruncateLength = 14;

  static const List<String> _monthLabels = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  static String truncateTitle(String title) {
    if (title.length <= _titleMaxLength) return title;
    return '${title.substring(0, _titleTruncateLength)}...';
  }

  static String formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day} ${_monthLabels[date.month - 1]} ${date.year}';
    } catch (_) {
      return dateStr;
    }
  }
}