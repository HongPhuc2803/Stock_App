import 'package:intl/intl.dart';

class AppFormatters {
  const AppFormatters({
    this.locale = 'vi_VN',
    this.currencyCode = 'VND',
    this.datePattern = 'dd/MM/yyyy',
  });

  final String locale;
  final String currencyCode;
  final String datePattern;

  String money(num value) => NumberFormat.currency(
    locale: locale,
    name: currencyCode,
    symbol: currencyCode == 'VND' ? '₫' : currencyCode,
    decimalDigits: currencyCode == 'VND' ? 0 : 2,
  ).format(value);

  String date(DateTime value) => DateFormat(datePattern, locale).format(value);

  String dateTime(DateTime value) =>
      DateFormat('$datePattern HH:mm', locale).format(value);
}

const defaultAppFormatters = AppFormatters();
