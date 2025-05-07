import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:whisper_notes/models/prompt_style.dart';
import 'package:whisper_notes/services/llm_service.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class SummarizationScreen extends StatefulWidget {
  final String transcription;
  
  const SummarizationScreen({Key? key, required this.transcription}) : super(key: key);

  @override
  State<SummarizationScreen> createState() => _SummarizationScreenState();
}

class _SummarizationScreenState extends State<SummarizationScreen> {
  String? _summary;
  bool _isGenerating = false;
  String? _currentStyle;
  
  final TextEditingController _transcriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _transcriptionController.text = widget.transcription;
  }

  @override
  void dispose() {
    _transcriptionController.dispose();
    super.dispose();
  }

  Future<void> _generateSummary(String styleName, String promptTemplate) async {
    if (_transcriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide a transcription first')),
      );
      return;
    }

    setState(() {
      _isGenerating = true;
      _currentStyle = styleName;
    });

    try {
      final llmService = Provider.of<LlmService>(context, listen: false);
      final summary = await llmService.generateSummary(
        _transcriptionController.text, 
        promptTemplate,
        styleName,
      );
      
      setState(() {
        _summary = summary.summaryText;
        _isGenerating = false;
      });
    } catch (e) {
      setState(() => _isGenerating = false);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error generating summary: $e')),
      );
    }
  }

  void _copyToClipboard(String text, {bool asMarkdown = false}) {
    String contentToCopy = text;
    
    if (asMarkdown) {
      contentToCopy = '# Podsumowanie\n\n$text';
      
      if (_currentStyle != null) {
        contentToCopy = '# Podsumowanie (Styl: $_currentStyle)\n\n$text';
      }
      
      if (_transcriptionController.text.isNotEmpty) {
        contentToCopy += '\n\n## Oryginalna transkrypcja\n\n${_transcriptionController.text}';
      }
    }
    
    Clipboard.setData(ClipboardData(text: contentToCopy)).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Skopiowano do schowka')),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final promptStyleProvider = Provider.of<PromptStyleProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Podsumowanie'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Transcription input
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Transkrypcja',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy),
                          tooltip: 'Kopiuj transkrypcję',
                          onPressed: () => _copyToClipboard(_transcriptionController.text),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _transcriptionController,
                      maxLines: 5,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Wpisz lub wklej transkrypcję tutaj...',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Summary style selection
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Styl podsumowania',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: List.generate(
                          promptStyleProvider.styles.length,
                          (index) => Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(promptStyleProvider.styles[index].name),
                              selected: promptStyleProvider.selectedIndex == index,
                              onSelected: (selected) {
                                if (selected) {
                                  promptStyleProvider.selectStyle(index);
                                }
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      promptStyleProvider.selectedStyle.description,
                      style: const TextStyle(fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Generate button
            ElevatedButton(
              onPressed: !_isGenerating
                  ? () => _generateSummary(
                        promptStyleProvider.selectedStyle.name,
                        promptStyleProvider.selectedStyle.promptTemplate,
                      )
                  : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isGenerating
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 16),
                        Text('Generuję podsumowanie...'),
                      ],
                    )
                  : const Text('Generuj podsumowanie'),
            ),
            
            const SizedBox(height: 16),
            
            // Summary output
            if (_summary != null)
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Podsumowanie',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.copy),
                                  tooltip: 'Kopiuj podsumowanie',
                                  onPressed: () => _copyToClipboard(_summary!),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.description),
                                  tooltip: 'Kopiuj jako Markdown',
                                  onPressed: () => _copyToClipboard(_summary!, asMarkdown: true),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Markdown(
                              data: _summary!,
                              padding: const EdgeInsets.all(16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}