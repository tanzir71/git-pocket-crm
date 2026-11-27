import '../format/app_formatters.dart';

/// Person inputs for [renderTemplate].
class TemplatePerson {
  const TemplatePerson({
    required this.displayName,
    this.company,
    this.amountDue = 0.0,
    this.currencyCode,
  });

  final String displayName;
  final String? company;
  final double amountDue;
  final String? currencyCode;
}

/// Global settings inputs for [renderTemplate].
class TemplateSettings {
  const TemplateSettings({
    this.myName = '',
    this.currencyCode = 'USD',
    this.localeName = 'en_US',
  });

  final String myName;
  final String currencyCode;
  final String localeName;
}

/// Output of [renderTemplate] with diagnostics for the composer.
class RenderedTemplate {
  const RenderedTemplate({
    required this.text,
    required this.unknownFields,
    required this.emptyFieldsWithoutFallback,
    this.primaryMergeSummary,
  });

  final String text;
  final List<String> unknownFields;
  final List<String> emptyFieldsWithoutFallback;
  final String? primaryMergeSummary;
}

/// Supported merge field canonical names.
const Set<String> kKnownMergeFields = {
  'first name',
  'name',
  'company',
  'amount due',
  'my name',
};

final RegExp _mergeTokenPattern = RegExp(r'\{([^{}]+)\}');

/// Pure template renderer implementing Spec 10 Part A rules:
/// - `{first name}`, `{name}`, `{company}`, `{amount due}`, `{my name}`
/// - Optional explicit fallback `{field|fallback}`
/// - Unknown fields left as typed and reported in [RenderedTemplate.unknownFields]
/// - Collapses repeated spaces and removes spaces left before punctuation
RenderedTemplate renderTemplate(
  String template,
  TemplatePerson person,
  TemplateSettings settings,
) {
  final unknown = <String>[];
  final emptyWithoutFallback = <String>[];

  final currency = (person.currencyCode != null && person.currencyCode!.trim().isNotEmpty)
      ? person.currencyCode!.trim().toUpperCase()
      : settings.currencyCode.trim().toUpperCase();
  final fmt = AppFormatters(
    localeName: settings.localeName,
    currencyCode: currency,
  );

  final fullName = person.displayName.trim();
  final firstName = fullName.isEmpty ? '' : fullName.split(RegExp(r'\s+')).first;
  final company = (person.company ?? '').trim();
  final formattedAmount = person.amountDue > 0.005 ? fmt.formatCurrency(person.amountDue) : '';
  final myName = settings.myName.trim();

  String? primarySummary;

  final substituted = template.replaceAllMapped(_mergeTokenPattern, (match) {
    final rawInner = match.group(1) ?? '';
    final barIndex = rawInner.indexOf('|');
    final rawField = (barIndex >= 0 ? rawInner.substring(0, barIndex) : rawInner).trim();
    final canonical = rawField.toLowerCase();
    final hasExplicitFallback = barIndex >= 0;
    final explicitFallback = hasExplicitFallback ? rawInner.substring(barIndex + 1) : null;

    if (!kKnownMergeFields.contains(canonical)) {
      if (!unknown.contains(rawField)) {
        unknown.add(rawField);
      }
      return match.group(0)!;
    }

    String value;
    String defaultFallback;
    switch (canonical) {
      case 'first name':
        value = firstName;
        defaultFallback = 'there';
      case 'name':
        value = fullName;
        defaultFallback = 'there';
      case 'company':
        value = company;
        defaultFallback = '';
      case 'amount due':
        value = formattedAmount;
        defaultFallback = '';
        if (formattedAmount.isNotEmpty) {
          primarySummary = '$formattedAmount due';
        }
      case 'my name':
        value = myName;
        defaultFallback = '';
      default:
        value = '';
        defaultFallback = '';
    }

    if (value.isNotEmpty) {
      if (canonical == 'company' && primarySummary == null) {
        primarySummary = company;
      }
      return value;
    }

    if (hasExplicitFallback) {
      return explicitFallback!;
    }

    if (defaultFallback.isNotEmpty) {
      return defaultFallback;
    }

    if (!emptyWithoutFallback.contains(canonical)) {
      emptyWithoutFallback.add(canonical);
    }
    return '';
  });

  final cleaned = _cleanSubstitutedText(substituted);

  return RenderedTemplate(
    text: cleaned,
    unknownFields: unknown,
    emptyFieldsWithoutFallback: emptyWithoutFallback,
    primaryMergeSummary: primarySummary,
  );
}

String _cleanSubstitutedText(String input) {
  final lines = input.split('\n');
  final cleanedLines = lines.map((line) {
    var s = line.replaceAll(RegExp(r' {2,}'), ' ');
    s = s.replaceAllMapped(RegExp(r' +([.,!?;:])'), (m) => m.group(1)!);
    return s.trim();
  });
  return cleanedLines.join('\n');
}
