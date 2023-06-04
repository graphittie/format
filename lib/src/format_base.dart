import 'dart:core';
import 'dart:core' as core show print;

import 'package:characters/characters.dart';
import 'package:intl/intl.dart';

/// 이 함수는 Python과 같이 문자열을 형식화합니다.
/// [Python 문자열 포맷팅](https://docs.python.org/3/library/string.html#format-specification-mini-language)
///
/// Python과의 차이점:
///
/// - 자동 및 수동 번호를 동시에 지원합니다. 수동 번호가 나타나면 자동 번호의 인덱스는
///   수동 번호의 인덱스로 재설정됩니다. 이것은 자연스러운 동작으로 보입니다만,
///   숨겨진 함정이 있을 수 있습니다.
///
/// - 이름 있는 매개변수는 국가 언어에서 지정할 수 있습니다. 동일한 원칙을 따르며
///   문자 또는 밑줄로 시작하고 이후에는 문자 또는 숫자가 올 수 있습니다.
///   문자 및 숫자 확인은 유니코드 표준을 기반으로 합니다. 이름 있는 매개변수는
///   작은따옴표나 큰따옴표로 지정할 수 있으며 여기에는 제한이 없습니다.
///   작은따옴표나 큰따옴표를 이스케이프하기 위해 중복하여 사용해야
///   식별자의 끝으로 인식되지 않습니다.
///
/// - 16진수의 대체 형식에서 '0x'가 사용되며 '0X' 대신 사용됩니다.
///   '0XABCDEF'가 필요한 이유를 이해하지 못했습니다.
///   '0xABCDEF'가 훨씬 자연스럽습니다. 필요한 경우 `.toUpperCase()`를 사용하여
///   첫 번째 형식을 손쉽게 얻을 수 있습니다.
///
/// - 2진수 ('b' - 0b..)와 8진수 ('o' - 0o..)에 대한 대체 형식은 지원되지 않습니다.
///   Dart 자체에서 해당 리터럴을 지원하지 않기 때문입니다. 그러나 '0x' 형식조차
///   Dart 자체에서는 사용되지 않으며 자체 코드를 실행할 수 없기 때문에
///   사용되지 않습니다. 이것은 논란이 될 수 있지만, 해당 형식을 지원하지 않기로
///   결정했습니다.
///
/// - 'nan' 및 'inf'는 'zero' 플래그를 사용하여 패딩되지 않습니다
///   (Python은 패딩하지만 MSVC:sprintf는 그렇지 않음).
///   'sign' 플래그는 'nan'에 영향을 미치지 않습니다
///   ('nan'은 '+nan'이 될 수 없음).
///   정렬 너비만 작동합니다.
///
/// - 'g' 및 'n' 형식에서 기본 정밀도는 6입니다.

///
/// - 대리자 및 다른 문자 조합을 지원하기 위해 'fill'은 정렬 문자 ('>', '<', '^') 중 하나로
///   끝나기만 하면 하나 이상의 문자를 받을 수 있습니다.
///
/// - TODO: 현재는 .key 및 index를 이름 있는 인수에서 지원하지 않습니다.
///   흥미로운 해결책입니다. 제게 매우 매력적으로 보입니다.
///   하지만 C++에는 채택되지 않았습니다. 난 format()을 처음 C++에서 만났습니다.
///
/// - TODO: 지수 표기법('e' 및 'g')에서 Python은 최소한 두 자리수의 지수를 출력합니다.
///   여기에서는 한 자리수로 출력됩니다.
///
/// - TODO: 'n' 형식에서 'e+05' 대신 'E5'로 출력됩니다.
///   기본적으로 NumberFormat이 작동하는 방식입니다.
///   기술적으로 'E+05'로 수정할 수 있습니다.
///   'e+05'으로 수정할 수는 없으며, 그래도 필요한지 알 수 없습니다.
///
/// - TODO: { 및 }를 이스케이프하기 위해 {{ 및 }}를 사용할 수 없습니다.
///
/// - TODO(?): align에 '='를 지원하지 않습니다.
///
/// - TODO: '%'를 지원하지 않습니다.
///
/// - TODO: {}는 너비와 정밀도에만 지원하며, Python은 템플릿 형식을 위해 어디에나 {}를
///   사용할 수 있습니다.

// ignore: long-parameter-list
String format(
  String fmt,
  Object values, [
  Object? v2,
  Object? v3,
  Object? v4,
  Object? v5,
  Object? v6,
  Object? v7,
  Object? v8,
  Object? v9,
  Object? v10,
]) {
  if (values is List) {
    return _format(fmt, positionalArgs: values);
  } else if (values is Map<String, Object?>) {
    return _format(fmt, namedArgs: values);
  } else if (values is Map<Symbol, Object?>) {
    return _format(fmt, namedArgs: values);
  }

  return _format(
    fmt,
    positionalArgs: [values, v2, v3, v4, v5, v6, v7, v8, v9, v10],
  );
}

extension StringFormat on String {
  String format(
    Object values, [
    Object? v2,
    Object? v3,
    Object? v4,
    Object? v5,
    Object? v6,
    Object? v7,
    Object? v8,
    Object? v9,
    Object? v10,
  ]) {
    if (values is List) {
      return _format(this, positionalArgs: values);
    } else if (values is Map<String, Object?>) {
      return _format(this, namedArgs: values);
    } else if (values is Map<Symbol, Object?>) {
      return _format(this, namedArgs: values);
    }

    return _format(
      this,
      positionalArgs: [values, v2, v3, v4, v5, v6, v7, v8, v9, v10],
    );
  }

  void print(
    Object values, [
    Object? v2,
    Object? v3,
    Object? v4,
    Object? v5,
    Object? v6,
    Object? v7,
    Object? v8,
    Object? v9,
    Object? v10,
  ]) {
    core.print(format(values, v2, v3, v4, v5, v6, v7, v8, v9, v10));
  }
}

final RegExp _formatSpecRe = RegExp(
  // begin
  r'\{\s*'
  // argId
  r'(\d*|[_\p{L}][_.\p{L}\d]*|'
  "'(?:''|[^'])*'"
  '|"(?:""|[^"])*")'
  //  :[  [fill ] align   ] [sign ] [#] [0]
  '(?::(?:([^}]+)?([<>^|]))?([-+ ])?(#)?(0)?'
  // width (number or {widthId})
  r'(\d+|\{(?:\d*|[_\w][_\w\d]*|\[[^\]]*\])\})?'
  // group option
  '([_,])?'
  // .precision (number or {precissionId})
  r'(?:\.(\d+|\{(?:\d*|[_\w][_\w\d]*|\[[^\]]*\])\}))?'
  // specifier
  '([csbodxXfFeEgGn])?'
  // additional template
  "('(?:''|[^'])*'"
  '|"(?:""|[^"])*")?)?'
  // end
  r'\s*\}',
  unicode: true,
);
final RegExp _triplesRe = RegExp(r'(\d)((?:\d{3})+)$');
final RegExp _quadruplesRe = RegExp(r'([0-9a-fA-F])((?:[0-9a-fA-F]{4})+)$');
final RegExp _tripleRe = RegExp(r'\d{3}');
final RegExp _quadrupleRe = RegExp('[0-9a-fA-F]{4}');
final RegExp _trailingZerosRe = RegExp(r'\.?0+(?=e|$)');
final RegExp _placeForPointRe = RegExp(r'(?=(e[-+]\d+)?$)');

/// Обрезает строку [src] до необходимой ширины [width], вставляет
/// при необходимости [ellipsis].
///
/// Пробелы после обрезки в конце полученной строки можно убрать, установив
/// флаг [trim].
String _cut(String src, int width, {String ellipsis = '…', bool trim = true}) {
  if (src.characters.length <= width) return src;

  // В заданный размер должно поместиться троеточие
  final ellipsisLength = ellipsis.characters.length;
  if (width < ellipsisLength) return '';

  var result = src.characters.take(width - ellipsisLength).toString();
  if (trim) result = result.trimRight();

  return result + ellipsis;
}

/// Берёт значение в строке [str] внутри кавычек [left] и [right].
///
/// Строкой [left] задаётся список доступных открывающих кавычек. Строкой
/// [right] - список соответствующих закрывающих кавычек. Заменяет двойные
/// вхождения кавычек внутри строки на одинарные.
///
/// Если нет кавычек возвращает null.
String? _getValueInQuotes(String str, String left, String right) {
  if (str.isNotEmpty) {
    final firstChar = str.substring(0, 1);
    final index = left.indexOf(firstChar);
    if (index >= 0) {
      final l = firstChar;
      final r = right[index];

      return str
          .substring(1, str.length - 1)
          .replaceAll('$l$l', l)
          .replaceAll('$r$r', r);
    }
  }

  return null;
}

/// Удаляет в строке [str] кавычки [left] и [right], если они есть.
///
/// Строкой [left] задаётся список доступных открывающих кавычек. Строкой
/// [right] - список соответствующих закрывающих кавычек. Заменяет двойные
/// вхождения кавычек внутри строки на одинарные.
///
/// Если нет кавычек возвращает исходную строку [str] без имзменений.
String _removeQuotesIfNeed(String str, String left, String right) =>
    _getValueInQuotes(str, left, right) ?? str;

class _Options {
  _Options(this.positionalArgs, this.namedArgs);

  final List<Object?>? positionalArgs;
  final Map<Object, Object?>? namedArgs;
  final intlNumberFormat = NumberFormat();
  int positionalArgsIndex = 0;
  String all = '';
  String? argId;
  Object? value;
  String? fill;
  String? align;
  String? sign;
  bool alt = false;
  bool zero = false;
  int? width;
  String? groupOption;
  int? precision;
  String? specifier;
  String? template;

  @override
  String toString() => '''
_Options{
  positionalArgs: ${positionalArgs?.length ?? 'null'},
  namedArgs: ${namedArgs?.length ?? 'null'},
  positionalArgsIndex: $positionalArgsIndex,
  spec: $all,
  argId: $argId,
  fill: $fill,
  align: $align,
  sign: $sign,
  alt: $alt,
  zero: $zero,
  width: $width,
  precision: $precision,
  type: $specifier,
  template: $template
}''';
}

/// Поиск значения в positionalArgs по индексу [index].
Object? _getValueByIndex(_Options options, int index) {
  final positionalArgs = options.positionalArgs;

  if (positionalArgs == null) {
    throw ArgumentError('${options.all} Positional args is missing.');
  }

  if (index >= positionalArgs.length) {
    throw ArgumentError(
      '${options.all} Index #$index out of range of positional args.',
    );
  }

  options.positionalArgsIndex = index + 1;

  return positionalArgs[index];
}

/// Поиск значения.
///
/// Варианты:
/// `{}` - перебираем параметры в positionalArgs по порядку;
/// `{index}` - индекс параметра в positionalArgs;
/// `{id}` или `{[id]}` - название параметра в namedArgs;
Object? _getValue(_Options options, String? rawId) {
  Object? value;

  if (rawId == null || rawId.isEmpty) {
    // Автоматическая нумерация.
    value = _getValueByIndex(options, options.positionalArgsIndex);
  } else {
    final index = int.tryParse(rawId);
    if (index != null) {
      // Параметр по заданному индексу.
      // В этом месте различия с C++20, который не поддерживает смешение
      // нумерованных и порядковых параметров. В нашем варианте смешение
      // возможно - как только встречается нумерованный параметр, индекс
      // перемещается на следующий параметр после него.
      value = _getValueByIndex(options, index);
    } else {
      // Именованный параметр.
      final stringId = _removeQuotesIfNeed(rawId, '\'"', '\'"');

      final namedArgs = options.namedArgs;
      if (namedArgs == null) {
        throw ArgumentError('${options.all} Named args is missing.');
      }

      final id =
          namedArgs is Map<Symbol, Object?> ? Symbol(stringId) : stringId;

      if (!namedArgs.containsKey(id)) {
        throw ArgumentError(
          '${options.all} Key [$id] is missing in named args.',
        );
      }

      value = namedArgs[id];
    }
  }

  return value;
}

// Вычисление width и precision. Варианты:
// n - значение задано напрямую;
// {} - перебираем параметры в positionalArgs по порядку;
// {index} - индекс параметра в positionalArgs;
// {id} или {[id]} - название параметра в namedArgs.
int? _getWidth(_Options options, String? str, String name, {int min = 0}) {
  int? value;

  if (str != null) {
    value = int.tryParse(str);
    if (value == null) {
      // Значение передано в виде параметра.
      final v = _getValue(options, _getValueInQuotes(str, '{', '}'));
      if (v is! int) {
        throw ArgumentError(
          '${options.all} $name must be int, passed ${v.runtimeType}.',
        );
      }

      value = v;
    }

    if (value < min) {
      throw ArgumentError(
        '${options.all} $name must be >= $min. Passed $value.',
      );
    }
  }

  return value;
}

// ignore: long-method
String _numberFormat<T extends num>(
  _Options options,
  Object? dyn, {
  bool precisionAllowed = true,
  bool altAllowed = true,
  bool standartGroupOptionAllowed = true,
  required String Function(T value, int? precision) toStr,
  bool removeTrailingZeros = false,
  bool needPoint = false,
  int groupSize = 3,
  String prefix = '',
}) {
  // Проверки.
  if (dyn is! T) {
    throw ArgumentError(
      '${options.all} Expected $T. Passed ${dyn.runtimeType}.',
    );
  }
  if (options.precision != null && !precisionAllowed) {
    throw ArgumentError(
      '${options.all} '
      'Precision not allowed with format specifier '
      "'${options.specifier}'.",
    );
  }
  if (options.alt && !altAllowed) {
    throw ArgumentError(
      '${options.all} '
      'Alternate form (#) not allowed with format specifier '
      "'${options.specifier}'.",
    );
  }
  if (options.groupOption == ',' && !standartGroupOptionAllowed) {
    throw ArgumentError(
      '${options.all} '
      "Group option ',' not allowed with format specifier "
      "'${options.specifier}'.",
    );
  }

  String result;
  final num value = dyn;

  // Числа по умолчанию прижимаются вправо
  options.align ??= '>';

  // Сохраняем знак.
  var sign = options.sign;
  if (value.isNegative) {
    sign = '-';
  } else if (sign == null || sign == '-') {
    sign = '';
  }

  // Преобразуем в строку.
  if (value.isNaN) return 'nan';
  if (value.isInfinite) return '${sign}inf';

  result = toStr(value as T, options.precision);

  // Убираем минус, вернём его в конце.
  if (result.isNotEmpty && result[0] == '-') result = result.substring(1);

  // Удаляем лишние нули.
  if (removeTrailingZeros && result.contains('.')) {
    result = result.replaceFirst(_trailingZerosRe, '');
  }

  // Ставим обязательную точку.
  if (needPoint && !result.contains('.')) {
    result = result.replaceFirst(_placeForPointRe, '.');
  }

  // Дополняем нулями (align и fill в этом случае игнорируются).
  final minWidth = (options.width ?? 0) - sign.length - prefix.length;
  if (options.zero && result.length < minWidth) {
    result = '0' * (minWidth - result.length) + result;
  }

  // Разделяем на группы.
  final grpo = options.groupOption;
  if (grpo != null) {
    final searchRe = groupSize == 3 ? _triplesRe : _quadruplesRe;
    final changeRe = groupSize == 3 ? _tripleRe : _quadrupleRe;
    var pointIndex = result.indexOf('.');
    if (pointIndex == -1) pointIndex = result.indexOf(RegExp('e[+-]'));
    if (pointIndex == -1) pointIndex = result.length;

    result = result.substring(0, pointIndex).replaceFirstMapped(
              searchRe,
              (m) =>
                  m[1]! +
                  m[2]!.replaceAllMapped(changeRe, (m) => '$grpo${m[0]}'),
            ) +
        result.substring(pointIndex);

    // Если добавляли нули, надо обрезать лишние.
    if (options.zero) {
      final extraWidth = result.length - minWidth;
      final extra = result.substring(0, extraWidth);
      result = extra.replaceFirst(RegExp('^[0$grpo]*'), '') +
          result.substring(extraWidth);
      if (result[0] == grpo) result = '0$result';
    }
  }

  // Восстанавливаем знак, добавляем префикс.
  return '$sign$prefix$result';
}

// ignore: long-method
String _intlNumberFormat<T extends num>(
  _Options options,
  Object? dyn, {
  bool removeTrailingZeros = false,
  bool needPoint = false,
}) {
  // Проверки.
  if (dyn is! T) {
    throw ArgumentError(
      '${options.all} Expected $T. Passed ${dyn.runtimeType}.',
    );
  }

  final num value = dyn;

  // Числа по умолчанию прижимаются вправо
  options.align ??= '>';

  NumberFormat fmt;
  var hasExp = false;
  String? zeros;
  final precision = options.precision;
  final width = options.width;

  if (value.isNaN || value.isInfinite) {
    fmt = NumberFormat.decimalPattern();
  } else {
    if (value is int) {
      if (precision != null) {
        throw ArgumentError(
          '${options.all} '
          'Precision not allowed for int with format specifier '
          "'${options.specifier}'.",
        );
      }

      fmt = NumberFormat.decimalPattern();
    } else {
      final tmp = value.toStringAsPrecision(precision ?? 6);
      final start = tmp[0] == '-' ? 1 : 0;
      final decPoint = tmp.indexOf('.');
      var end = tmp.indexOf('e');
      if (end != -1) {
        hasExp = true;
        fmt = NumberFormat.scientificPattern();
      } else {
        fmt = NumberFormat.decimalPattern();
        end = tmp.length;
      }
      if (decPoint == -1) {
        fmt
          ..minimumFractionDigits = fmt.maximumFractionDigits = 0
          ..minimumIntegerDigits = end - start;
      } else {
        fmt
          ..minimumFractionDigits =
              fmt.maximumFractionDigits = end - decPoint - 1
          ..minimumIntegerDigits = decPoint - start;
      }
    }

    if (options.groupOption != ',') {
      fmt.turnOffGrouping();
    }

    // Из-за того, что форматирование может быть сложным, не добиваем нулями
    // самостоятельно, а формируем отдельную строку с нулями. Длину строки
    // подбираем, исходя из того, чтобы вся дробная часть и точка могут
    // быть откинуты.
    if (options.zero && width != null) {
      final zeroFmt = NumberFormat.decimalPattern()
        ..minimumIntegerDigits = width;
      if (options.groupOption != ',') {
        zeroFmt.turnOffGrouping();
      }
      zeros = zeroFmt.format(0);
    }
  }

  // Сохраняем знак.
  var sign = options.sign;
  if (value.isNegative) {
    sign = fmt.symbols.MINUS_SIGN;
  } else if (sign == null || sign == '-') {
    sign = '';
  } else if (sign == '+') {
    sign = fmt.symbols.PLUS_SIGN;
  }

  var result = fmt.format(value);

  // Убираем минус, вернём его в конце.
  if (result.isNotEmpty && result.startsWith(fmt.symbols.MINUS_SIGN)) {
    result = result.substring(fmt.symbols.MINUS_SIGN.length);
  }

  if (!value.isNaN && !value.isInfinite) {
    final zeroDigitForRe = fmt.symbols.ZERO_DIGIT.replaceFirstMapped(
      RegExp(r'(\d)|(.)'),
      (m) => m[1] == null ? '\\${m[2]}' : m[1]!,
    );
    final expSymbolForRe = fmt.symbols.EXP_SYMBOL
        .replaceFirstMapped(RegExp('.'), (m) => '\\${m[0]}');
    final decimalSepForRe = fmt.symbols.DECIMAL_SEP
        .replaceFirstMapped(RegExp('.'), (m) => '\\${m[0]}');

    // Удаляем лишние нули в конце.
    if (removeTrailingZeros) {
      final decPoint = result.indexOf(fmt.symbols.DECIMAL_SEP);
      if (decPoint != -1) {
        result = result.replaceFirst(
          RegExp('(($decimalSepForRe)?$zeroDigitForRe)+(?=$expSymbolForRe|\$)'),
          '',
          decPoint,
        );
      }
    }

    // Ставим обязательную точку.
    if (needPoint && !result.contains(fmt.symbols.DECIMAL_SEP)) {
      if (hasExp) {
        final index = result.indexOf(fmt.symbols.EXP_SYMBOL);
        assert(index != -1);
        result = '${result.substring(0, index)}'
            '${fmt.symbols.DECIMAL_SEP}'
            '${result.substring(index)}';
      } else {
        result = '$result${fmt.symbols.DECIMAL_SEP}';
      }
    }

    if (options.zero && width != null && result.length < width - sign.length) {
      var integersCount = result.indexOf(fmt.symbols.DECIMAL_SEP);
      if (integersCount == -1) {
        integersCount =
            hasExp ? result.indexOf(fmt.symbols.EXP_SYMBOL) : result.length;
      }
      final end = zeros!.length - integersCount;
      final start = end - (width - sign.length - result.length);
      final addZeros = zeros.substring(start, end);
      result = '$addZeros$result';
      if (result.startsWith(fmt.symbols.GROUP_SEP)) {
        result = '${fmt.symbols.ZERO_DIGIT}$result';
      }
    }
  }

  // Восстанавливаем знак.
  return '$sign$result';
}

// ignore: long-method
String _format(
  String template, {
  List<Object?>? positionalArgs,
  Map<Object, Object?>? namedArgs,
}) {
  final options = _Options(positionalArgs, namedArgs);

  // var removeEmptyStrings = false;

  final result = template.replaceAllMapped(_formatSpecRe, (match) {
    options
      ..all = match.group(0)!
      ..argId = match.group(1)
      ..value = _getValue(options, options.argId)
      ..fill = match.group(2)
      ..align = match.group(3)
      ..sign = match.group(4)
      ..alt = match.group(5) != null
      ..zero = match.group(6) != null
      ..width = _getWidth(options, match.group(7), 'Width')
      ..groupOption = match.group(8)
      ..specifier = match.group(10)
      ..template = match.group(11);

    String? result;

    final value = options.value;

    // Типы форматирования по умолчанию.
    if (options.specifier == null) {
      if (value is String) {
        options.specifier = 's';
      } else if (value is int) {
        options.specifier = 'd';
      } else if (value is double) {
        options.specifier = 'g';
      }
    }

    final spec = options.specifier;

    options.precision = _getWidth(
      options,
      match.group(9),
      'Precision',
      min: spec == 'g' || spec == 'G' || spec == 'n' ? 1 : 0,
    );

    if (spec == null) {
      result = value.toString();
    } else {
      switch (spec) {
        // Символ
        case 'c':
          if (value is int) {
            result = String.fromCharCode(value);
          } else if (value is List<int>) {
            result = String.fromCharCodes(value);
          } else {
            throw ArgumentError(
              '${options.all} Expected int or List<int>.'
              ' Passed ${value.runtimeType}.',
            );
          }
          break;

        // Строка
        case 's':
          if (value is! String) {
            throw ArgumentError(
              '${options.all} Expected String. Passed ${value.runtimeType}.',
            );
          }

          final precision = options.precision;
          result = precision == null
              ? value
              : options.alt
                  ? _cut(value, precision)
                  : precision > value.characters.length
                      ? value
                      : value.characters.take(precision).toString();
          break;

        // Число
        case 'b':
          result = _numberFormat<int>(
            options,
            value,
            precisionAllowed: false,
            altAllowed: false,
            standartGroupOptionAllowed: false,
            toStr: (value, precision) => value.toRadixString(2),
            groupSize: 4,
          );
          break;

        case 'o':
          result = _numberFormat<int>(
            options,
            value,
            precisionAllowed: false,
            altAllowed: false,
            standartGroupOptionAllowed: false,
            toStr: (value, precision) => value.toRadixString(8),
            groupSize: 4,
          );
          break;

        case 'x':
          result = _numberFormat<int>(
            options,
            value,
            precisionAllowed: false,
            standartGroupOptionAllowed: false,
            toStr: (value, precision) => value.toRadixString(16),
            groupSize: 4,
            prefix: options.alt ? '0x' : '',
          );
          break;

        case 'X':
          result = _numberFormat<int>(
            options,
            value,
            precisionAllowed: false,
            standartGroupOptionAllowed: false,
            toStr: (value, precision) => value.toRadixString(16).toUpperCase(),
            groupSize: 4,
            prefix: options.alt ? '0x' : '',
          );
          break;

        case 'd':
          result = _numberFormat<int>(
            options,
            value,
            precisionAllowed: false,
            altAllowed: false,
            toStr: (value, _) => value.toString(),
          );
          break;

        case 'f':
        case 'F':
          result = _numberFormat<double>(
            options,
            value,
            toStr: (value, precision) => value.toStringAsFixed(precision ?? 6),
            needPoint: options.alt,
          );
          if (spec == 'F') result = result.toUpperCase();
          break;

        case 'e':
        case 'E':
          result = _numberFormat<double>(
            options,
            value,
            toStr: (value, precision) =>
                value.toStringAsExponential(precision ?? 6),
            needPoint: options.alt,
          );
          if (spec == 'E') result = result.toUpperCase();
          break;

        case 'g':
        case 'G':
          result = _numberFormat<double>(
            options,
            value,
            toStr: (value, precision) =>
                value.toStringAsPrecision(precision ?? 6),
            removeTrailingZeros: !options.alt,
            needPoint: options.alt,
          );
          if (spec == 'G') result = result.toUpperCase();
          break;

        case 'n':
          result = _intlNumberFormat<num>(
            options,
            value,
            removeTrailingZeros: !options.alt,
            needPoint: options.alt && value is! int,
          );
          break;
      }
    }

    final width = options.width;
    if (result != null && width != null && result.length < width) {
      // Выравниваем относительно заданной ширины
      final fill = options.fill ?? ' ';
      final n = width - result.length;

      switch (options.align ?? '<') {
        case '<':
          result += fill * n;
          break;
        case '>':
          result = fill * n + result;
          break;
        case '^':
          {
            final half = n ~/ 2;
            result = fill * half + result + fill * (n - half);
            break;
          }
      }
    }

    if (result != null) return result;

    return options.toString();
  });

  return result;
}
