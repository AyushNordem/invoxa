class InvoiceNumberGenerator {
  /// Example Output:
  /// INV-20260516-0001

  static String generate({
    required int sequenceNumber,
    String prefix = "INV",
  }) {
    final now = DateTime.now();

    final date =
        "${now.year}"
        "${now.month.toString().padLeft(2, '0')}"
        "${now.day.toString().padLeft(2, '0')}";

    final formattedSequence =
        sequenceNumber.toString().padLeft(4, '0');

    return "$prefix-$date-$formattedSequence";
  }
}
