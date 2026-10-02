import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/document_service.dart';
import 'login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AuthService authService = AuthService();
  final DocumentService documentService = DocumentService();

  List<Map<String, dynamic>> documents = [];

  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadDocuments();
  }

  // ==========================================
  // READ DOCUMENTS
  // ==========================================

  Future<void> loadDocuments() async {
    try {
      final result = await documentService.getDocuments();

      if (!mounted) return;

      setState(() {
        documents = result;
        loading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        loading = false;
      });

      showMessage('Failed to load documents: $error');
    }
  }

  // ==========================================
  // CREATE DOCUMENT
  // ==========================================

  Future<void> addDocument() async {
    final titleController = TextEditingController();

    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Document'),
          content: TextField(
            controller: titleController,
            decoration: const InputDecoration(
              labelText: 'Document title',
              hintText: 'e.g. Database Systems',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final title = titleController.text.trim();

                if (title.isNotEmpty) {
                  Navigator.pop(context, title);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );

    titleController.dispose();

    if (result == null) return;

    try {
      await documentService.createDocument(
        title: result,
        filePath: '',
        fileType: 'unknown',
      );

      await loadDocuments();

      showMessage('Document created successfully!');
    } catch (error) {
      showMessage('Failed to create document: $error');
    }
  }

  // ==========================================
  // UPDATE DOCUMENT
  // ==========================================

  Future<void> editDocument(Map<String, dynamic> document) async {
    final titleController = TextEditingController(text: document['title']);

    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Document'),
          content: TextField(
            controller: titleController,
            decoration: const InputDecoration(
              labelText: 'Document title',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final title = titleController.text.trim();

                if (title.isNotEmpty) {
                  Navigator.pop(context, title);
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    titleController.dispose();

    if (result == null) return;

    try {
      await documentService.updateDocument(
        documentId: document['id'],
        title: result,
      );

      await loadDocuments();

      showMessage('Document updated successfully!');
    } catch (error) {
      showMessage('Failed to update document: $error');
    }
  }

  // ==========================================
  // DELETE DOCUMENT
  // ==========================================

  Future<void> deleteDocument(Map<String, dynamic> document) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Document'),
          content: Text(
            'Are you sure you want to delete "${document['title']}"?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    try {
      await documentService.deleteDocument(documentId: document['id']);

      await loadDocuments();

      showMessage('Document deleted successfully!');
    } catch (error) {
      showMessage('Failed to delete document: $error');
    }
  }

  // ==========================================
  // MESSAGE
  // ==========================================

  void showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  // ==========================================
  // LOGOUT
  // ==========================================

  Future<void> logout() async {
    await authService.logout();

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  // ==========================================
  // UI
  // ==========================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quizzy App'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: logout,
          ),
        ],
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : documents.isEmpty
          ? const Center(
              child: Text(
                'No learning materials yet.\n\nTap + to add one.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
            )
          : RefreshIndicator(
              onRefresh: loadDocuments,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: documents.length,
                itemBuilder: (context, index) {
                  final document = documents[index];

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: const Icon(Icons.description, size: 36),

                      title: Text(document['title'] ?? 'Untitled'),

                      subtitle: Text(
                        'Type: ${document['file_type'] ?? 'Unknown'}',
                      ),

                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              editDocument(document);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              deleteDocument(document);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

      floatingActionButton: FloatingActionButton(
        onPressed: addDocument,
        child: const Icon(Icons.add),
      ),
    );
  }
}
