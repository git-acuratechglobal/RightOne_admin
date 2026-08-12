String formatInt(num value) {
  final negative = value < 0;
  final digits = value.abs().round().toString();
  final buffer = StringBuffer();
  for (int i = 0; i < digits.length; i++) {
    final posFromEnd = digits.length - i;
    buffer.write(digits[i]);
    if (posFromEnd > 1 && posFromEnd % 3 == 1) buffer.write(',');
  }
  return (negative ? '-' : '') + buffer.toString();
}

String formatCompactK(num thousands) {
  if (thousands == 0) return '0';
  final isWhole = thousands == thousands.roundToDouble();
  final str =
      isWhole ? thousands.toStringAsFixed(0) : thousands.toStringAsFixed(1);
  return '${str}K';
}

String capitalize(String s) =>
    s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
