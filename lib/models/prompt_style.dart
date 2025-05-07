import 'package:flutter/foundation.dart';

class PromptStyle {
  final String name;
  final String description;
  final String promptTemplate;

  const PromptStyle({
    required this.name,
    required this.description,
    required this.promptTemplate,
  });
}

class PromptStyleProvider extends ChangeNotifier {
  int _selectedIndex = 0;

  final List<PromptStyle> styles = const [
    PromptStyle(
      name: 'Akademicki',
      description: 'Formalne podsumowanie w stylu akademickim',
      promptTemplate: 'Utwórz akademickie podsumowanie następującego tekstu, używając formalnego języka i koncentrując się na najważniejszych punktach i argumentach:',
    ),
    PromptStyle(
      name: 'Punkty kluczowe',
      description: 'Lista najważniejszych punktów z transkrypcji',
      promptTemplate: 'Wypisz w punktach najważniejsze informacje z poniższego tekstu:',
    ),
    PromptStyle(
      name: 'ELI5',
      description: 'Wyjaśnienie jakby dla pięciolatka (prosto i zrozumiale)',
      promptTemplate: 'Wyjaśnij główne punkty poniższego tekstu w sposób, który zrozumiałoby pięcioletnie dziecko:',
    ),
    PromptStyle(
      name: 'Biznesowy',
      description: 'Zwięzłe podsumowanie dla środowiska biznesowego',
      promptTemplate: 'Przygotuj zwięzłe podsumowanie biznesowe poniższego tekstu, koncentrując się na kluczowych wskaźnikach, wynikach i rekomendacjach:',
    ),
    PromptStyle(
      name: 'Kreatywny',
      description: 'Podsumowanie z użyciem metafor i języka kreatywnego',
      promptTemplate: 'Napisz kreatywne podsumowanie poniższego tekstu, używając bogatego języka, metafor i analogii:',
    ),
  ];

  int get selectedIndex => _selectedIndex;
  PromptStyle get selectedStyle => styles[_selectedIndex];

  void selectStyle(int index) {
    if (index >= 0 && index < styles.length) {
      _selectedIndex = index;
      notifyListeners();
    }
  }
}