import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(const PersonaMirrorApp());

class PersonaMirrorApp extends StatelessWidget {
  const PersonaMirrorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Persona Mirror',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1E2A4A)),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final baseUrlController = TextEditingController(text: 'http://10.0.2.2:3000');
  final idTokenController = TextEditingController();
  final titleController = TextEditingController();
  final contextController = TextEditingController();
  String category = 'work';
  String accessToken = '';
  List<dynamic> scenarios = [];
  String error = '';

  Future<void> login() async {
    final response = await http.post(
      Uri.parse('${baseUrlController.text}/api/v1/auth/google'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'id_token': idTokenController.text}),
    );
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    if (body['error'] != null) {
      setState(() => error = body['error']['message'] as String);
      return;
    }
    setState(() {
      accessToken = body['access_token'] as String? ?? '';
      error = '';
    });
    await fetchScenarios();
  }

  Future<void> fetchScenarios() async {
    if (accessToken.isEmpty) return;
    final response = await http.get(
      Uri.parse('${baseUrlController.text}/api/v1/scenarios'),
      headers: {'Authorization': 'Bearer $accessToken'},
    );
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    setState(() {
      scenarios = body['scenarios'] as List<dynamic>? ?? [];
    });
  }

  Future<void> createScenario() async {
    final response = await http.post(
      Uri.parse('${baseUrlController.text}/api/v1/scenarios'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'title': titleController.text,
        'context': contextController.text,
        'category': category,
      }),
    );
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    if (body['error'] != null) {
      setState(() => error = body['error']['message'] as String);
      return;
    }
    titleController.clear();
    contextController.clear();
    await fetchScenarios();
  }

  Future<void> startSession(String scenarioId) async {
    final response = await http.post(
      Uri.parse('${baseUrlController.text}/api/v1/sessions'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'scenario_id': scenarioId}),
    );
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    if (body['error'] != null) {
      setState(() => error = body['error']['message'] as String);
      return;
    }

    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SessionScreen(
          baseUrl: baseUrlController.text,
          accessToken: accessToken,
          sessionId: body['session']['id'] as String,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Persona Mirror')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: baseUrlController,
            decoration: const InputDecoration(labelText: 'Base URL'),
          ),
          TextField(
            controller: idTokenController,
            decoration: const InputDecoration(labelText: 'Google id_token'),
          ),
          const SizedBox(height: 8),
          FilledButton(onPressed: login, child: const Text('Google ile Giris')),
          const SizedBox(height: 16),
          TextField(
            controller: titleController,
            decoration: const InputDecoration(labelText: 'Senaryo Basligi'),
          ),
          TextField(
            controller: contextController,
            decoration: const InputDecoration(labelText: 'Baglam'),
            maxLines: 3,
          ),
          DropdownButton<String>(
            value: category,
            items: const [
              DropdownMenuItem(value: 'work', child: Text('Is')),
              DropdownMenuItem(value: 'family', child: Text('Aile')),
              DropdownMenuItem(value: 'friendship', child: Text('Arkadaslik')),
              DropdownMenuItem(value: 'romantic', child: Text('Romantik')),
              DropdownMenuItem(value: 'other', child: Text('Diger')),
            ],
            onChanged: (value) => setState(() => category = value ?? 'work'),
          ),
          FilledButton(onPressed: createScenario, child: const Text('Senaryo Olustur')),
          if (error.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: SelectableText.rich(
                TextSpan(text: error, style: const TextStyle(color: Colors.red)),
              ),
            ),
          const SizedBox(height: 16),
          ...scenarios.map(
            (scenario) => Card(
              child: ListTile(
                title: Text(scenario['title'] as String? ?? ''),
                subtitle: Text(scenario['category'] as String? ?? ''),
                trailing: FilledButton(
                  onPressed: () => startSession(scenario['id'] as String),
                  child: const Text('Baslat'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SessionScreen extends StatefulWidget {
  const SessionScreen({
    super.key,
    required this.baseUrl,
    required this.accessToken,
    required this.sessionId,
  });

  final String baseUrl;
  final String accessToken;
  final String sessionId;

  @override
  State<SessionScreen> createState() => _SessionScreenState();
}

class _SessionScreenState extends State<SessionScreen> {
  final messageController = TextEditingController();
  List<dynamic> messages = [];
  String error = '';

  @override
  void initState() {
    super.initState();
    fetchSession();
  }

  Future<void> fetchSession() async {
    final response = await http.get(
      Uri.parse('${widget.baseUrl}/api/v1/sessions/${widget.sessionId}'),
      headers: {'Authorization': 'Bearer ${widget.accessToken}'},
    );
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    setState(() {
      messages = body['messages'] as List<dynamic>? ?? [];
    });
  }

  Future<void> sendMessage() async {
    final response = await http.post(
      Uri.parse('${widget.baseUrl}/api/v1/sessions/${widget.sessionId}/message'),
      headers: {
        'Authorization': 'Bearer ${widget.accessToken}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'content': messageController.text}),
    );
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    if (body['error'] != null) {
      setState(() => error = body['error']['message'] as String);
      return;
    }
    messageController.clear();
    await fetchSession();
  }

  Future<void> endSession() async {
    await http.patch(
      Uri.parse('${widget.baseUrl}/api/v1/sessions/${widget.sessionId}/end'),
      headers: {'Authorization': 'Bearer ${widget.accessToken}'},
    );
    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AnalysisScreen(
          baseUrl: widget.baseUrl,
          accessToken: widget.accessToken,
          sessionId: widget.sessionId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Simulasyon'),
        actions: [
          TextButton(
            onPressed: endSession,
            child: const Text('Bitir'),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: messages
                  .map(
                    (item) => Align(
                      alignment: item['role'] == 'user'
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: item['role'] == 'user'
                              ? const Color(0xFF1E2A4A)
                              : const Color(0xFFF5EFE9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          item['content'] as String? ?? '',
                          style: TextStyle(
                            color: item['role'] == 'user' ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          if (error.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SelectableText.rich(
                TextSpan(text: error, style: const TextStyle(color: Colors.red)),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    decoration: const InputDecoration(hintText: 'Mesajini yaz'),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(onPressed: sendMessage, child: const Text('Gonder')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AnalysisScreen extends StatefulWidget {
  const AnalysisScreen({
    super.key,
    required this.baseUrl,
    required this.accessToken,
    required this.sessionId,
  });

  final String baseUrl;
  final String accessToken;
  final String sessionId;

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  Map<String, dynamic>? analysis;

  @override
  void initState() {
    super.initState();
    loadAnalysis();
  }

  Future<void> loadAnalysis() async {
    final response = await http.get(
      Uri.parse('${widget.baseUrl}/api/v1/sessions/${widget.sessionId}/analyse'),
      headers: {'Authorization': 'Bearer ${widget.accessToken}'},
    );
    if (response.statusCode == 404) {
      await http.post(
        Uri.parse('${widget.baseUrl}/api/v1/sessions/${widget.sessionId}/analyse'),
        headers: {'Authorization': 'Bearer ${widget.accessToken}'},
      );
    }
    final retried = await http.get(
      Uri.parse('${widget.baseUrl}/api/v1/sessions/${widget.sessionId}/analyse'),
      headers: {'Authorization': 'Bearer ${widget.accessToken}'},
    );
    final body = jsonDecode(retried.body) as Map<String, dynamic>;
    setState(() => analysis = body['analysis'] as Map<String, dynamic>?);
  }

  @override
  Widget build(BuildContext context) {
    if (analysis == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Analiz')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Empati: ${analysis!['empathy_score']}/10'),
          Text('Netlik: ${analysis!['clarity_score']}/10'),
          Text('Kararlilik: ${analysis!['assertiveness_score']}/10'),
          const SizedBox(height: 8),
          Text(analysis!['summary'] as String? ?? ''),
        ],
      ),
    );
  }
}
