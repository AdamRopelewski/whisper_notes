class Summary {
  final String originalText;
  final String summaryText;
  final String styleUsed;
  final DateTime timestamp;
  
  Summary({
    required this.originalText,
    required this.summaryText,
    required this.styleUsed,
    required this.timestamp,
  });
  
  String toMarkdown() {
    return '''
# Podsumowanie

*Styl: $styleUsed*
*Data: ${timestamp.toLocal().toString().split('.')[0]}*

## Treść oryginalna

${originalText.length > 300 ? '${originalText.substring(0, 300)}...' : originalText}

## Podsumowanie

$summaryText
''';
  }
}