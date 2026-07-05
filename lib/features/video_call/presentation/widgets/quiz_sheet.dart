import 'package:flutter/material.dart';
import 'package:grad_project/features/video_call/presentation/bloc/quiz/quiz_state.dart';

class QuizSheet extends StatefulWidget {
  final QuizState state;
  final bool isInstructor;
  final String meetingId;
  final Function(String, List<Map<String, dynamic>>) onCreateQuiz;
  final Function(String) onStopQuiz;
  final Function(String, String) onSubmitAnswer;

  const QuizSheet({
    super.key,
    required this.state,
    required this.isInstructor,
    required this.meetingId,
    required this.onCreateQuiz,
    required this.onStopQuiz,
    required this.onSubmitAnswer,
  });

  @override
  State<QuizSheet> createState() => _QuizSheetState();
}

class _QuizSheetState extends State<QuizSheet> {
  final _questionController = TextEditingController();
  final _optAController = TextEditingController();
  final _optBController = TextEditingController();
  final _optCController = TextEditingController();
  final _optDController = TextEditingController();

  String? _selectedOption;
  bool _hasAnswered = false;
  bool? _isCorrectAnswer;

  @override
  void dispose() {
    _questionController.dispose();
    _optAController.dispose();
    _optBController.dispose();
    _optCController.dispose();
    _optDController.dispose();
    super.dispose();
  }

  void _submitQuizCreation() {
    final questionText = _questionController.text.trim();
    final a = _optAController.text.trim();
    final b = _optBController.text.trim();
    final c = _optCController.text.trim();
    final d = _optDController.text.trim();

    if (questionText.isNotEmpty && a.isNotEmpty && b.isNotEmpty) {
      final questions = [
        {
          'questionText': questionText,
          'optionA': a,
          'optionB': b,
          'optionC': c.isEmpty ? 'N/A' : c,
          'optionD': d.isEmpty ? 'N/A' : d,
          'orderIndex': 0,
        }
      ];
      widget.onCreateQuiz(widget.meetingId, questions);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      padding: const EdgeInsets.only(top: 8, bottom: 24, left: 16, right: 16),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Live Class Quiz',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(),
            _buildContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    final state = widget.state;

    // ── 1. QUIZ ACTIVE (Student view / Instructor view) ──────────────────
    if (state is QuizActive) {
      if (widget.isInstructor) {
        return Column(
          children: [
            const SizedBox(height: 12),
            Text(
              'Active Question: ${state.session.questions.firstOrNull?.questionText ?? "No question"}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Text(
              'Realtime Responses: ${state.results}',
              style: const TextStyle(fontSize: 13, color: Colors.blueGrey),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                onPressed: () => widget.onStopQuiz(state.session.sessionId),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                child: const Text('End Quiz & Show Results', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        );
      } else {
        // Student answering screen
        final q = state.session.questions.firstOrNull;
        if (q == null) return const Center(child: Text('No active question in quiz'));

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              q.questionText,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 16),
            _optionTile(q.id, 'A', q.optionA),
            _optionTile(q.id, 'B', q.optionB),
            _optionTile(q.id, 'C', q.optionC),
            _optionTile(q.id, 'D', q.optionD),
            const SizedBox(height: 24),
            if (_hasAnswered && _isCorrectAnswer != null)
              Center(
                child: Text(
                  _isCorrectAnswer! ? '🎉 Correct Answer!' : '❌ Incorrect Answer. Try again on next quiz!',
                  style: TextStyle(
                    color: _isCorrectAnswer! ? Colors.green : Colors.redAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
          ],
        );
      }
    }

    // ── 2. QUIZ ENDED / RESULTS ──────────────────────────────────────────
    if (state is QuizEndedState) {
      return Column(
        children: [
          const Center(
            child: Icon(Icons.analytics_outlined, size: 48, color: Colors.green),
          ),
          const SizedBox(height: 12),
          const Text('Quiz ended. Final results:', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              state.results.toString(),
              style: const TextStyle(fontSize: 13, color: Colors.black87),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          if (widget.isInstructor)
            SizedBox(
              width: double.infinity,
              height: 46,
              child: OutlinedButton(
                onPressed: () {
                  // Reset state to initial to let instructor create a new quiz
                },
                child: const Text('Back to Creator'),
              ),
            ),
        ],
      );
    }

    // ── 3. CREATE QUIZ (Instructor creator view) ─────────────────────────
    if (widget.isInstructor) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Create Live Quiz Question', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          TextField(
            controller: _questionController,
            decoration: const InputDecoration(labelText: 'Question Text', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _optAController,
            decoration: const InputDecoration(labelText: 'Option A (Correct)', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _optBController,
            decoration: const InputDecoration(labelText: 'Option B', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _optCController,
            decoration: const InputDecoration(labelText: 'Option C (Optional)', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _optDController,
            decoration: const InputDecoration(labelText: 'Option D (Optional)', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton(
              onPressed: _submitQuizCreation,
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF163D69)),
              child: const Text('Launch Live Quiz', style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      );
    }

    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: Text('Waiting for instructor to launch quiz...', style: TextStyle(color: Colors.black54)),
      ),
    );
  }

  Widget _optionTile(String questionId, String optionCode, String optionText) {
    if (optionText.isEmpty || optionText == 'N/A') return const SizedBox.shrink();

    final isSelected = _selectedOption == optionCode;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: _hasAnswered
            ? null
            : () async {
                setState(() {
                  _selectedOption = optionCode;
                  _hasAnswered = true;
                });
                final isCorrect = await widget.onSubmitAnswer(questionId, optionCode);
                setState(() {
                  _isCorrectAnswer = isCorrect;
                });
              },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFDAF3FF) : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? const Color(0xFF163D69) : Colors.transparent,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Text(
                '$optionCode. ',
                style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF163D69)),
              ),
              Expanded(child: Text(optionText)),
            ],
          ),
        ),
      ),
    );
  }
}
