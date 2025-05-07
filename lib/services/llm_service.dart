import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:whisper_notes/models/summary.dart';

class LlmService {
  // W prawdziwym projekcie użylibyśmy prawdziwego API lub lokalnego modelu
  // Na potrzeby przykładu symulujemy działanie LLM
  Future<Summary> generateSummary(String text, String prompt, String styleName) async {
    try {
      // Symulacja opóźnienia przetwarzania
      await Future.delayed(const Duration(seconds: 2));
      
      // W rzeczywistym scenariuszu wysłalibyśmy zapytanie do API lub użyli lokalnego modelu
      // final response = await http.post(
      //   Uri.parse('https://api.llm-provider.com/generate'),
      //   body: jsonEncode({
      //     'prompt': '$prompt\n\n$text',
      //     'max_tokens': 500,
      //   }),
      // );
      
      // Przykładowe podsumowanie w zależności od stylu
      String summaryText;
      
      if (styleName.contains('Punkty')) {
        summaryText = '- Punkt pierwszy: to jest przykładowe podsumowanie\n'
            '- Punkt drugi: symuluje działanie modelu językowego\n'
            '- Punkt trzeci: w rzeczywistej aplikacji tekst byłby generowany przez LLM\n'
            '- Punkt czwarty: w odpowiedzi na wybrany styl podsumowania';
      } else if (styleName.contains('ELI5')) {
        summaryText = 'Ten tekst mówi o bardzo ważnych rzeczach! '
            'Wyobraź sobie, że ktoś nagrał swoim głosem ważne informacje, '
            'a komputer zamienił to na słowa, które możemy przeczytać. '
            'Teraz inny mądry komputer próbuje powiedzieć nam krócej, o czym to było, '
            'żebyśmy szybciej zrozumieli.';
      } else {
        summaryText = 'To jest przykładowe podsumowanie tekstu w stylu "$styleName". '
            'W rzeczywistej aplikacji, treść byłaby generowana przez model językowy '
            'w odpowiedzi na transkrypcję i wybrany styl podsumowania. '
            'Długość i szczegółowość podsumowania zależałaby od parametrów modelu '
            'oraz wybranego stylu formatowania.';
      }
      
      return Summary(
        originalText: text,
        summaryText: summaryText,
        styleUsed: styleName,
        timestamp: DateTime.now(),
      );
    } catch (e) {
      throw Exception('Błąd podczas generowania podsumowania: $e');
    }
  }
}