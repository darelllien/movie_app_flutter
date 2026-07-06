class Formatters {
  static const List<String> _monthLabels = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  static String truncateTitle(String title, {int maxLength = 17, int truncateLength = 14}) {
    if (title.length <= maxLength) return title;
    return '${title.substring(0, truncateLength)}...';
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