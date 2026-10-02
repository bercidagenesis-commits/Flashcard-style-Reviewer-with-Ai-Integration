import 'package:supabase_flutter/supabase_flutter.dart';

class DocumentService {
  final SupabaseClient supabase = Supabase.instance.client;

  // ==============================
  // CREATE DOCUMENT
  // ==============================

  Future<void> createDocument({
    required String title,
    required String filePath,
    required String fileType,
  }) async {
    final user = supabase.auth.currentUser;

    if (user == null) {
      throw Exception('User is not logged in.');
    }

    await supabase.from('documents').insert({
      'user_id': user.id,
      'title': title,
      'file_path': filePath,
      'file_type': fileType,
      'status': 'uploaded',
    });
  }

  // ==============================
  // READ DOCUMENTS
  // ==============================

  Future<List<Map<String, dynamic>>> getDocuments() async {
    final user = supabase.auth.currentUser;

    if (user == null) {
      throw Exception('User is not logged in.');
    }

    final response = await supabase
        .from('documents')
        .select()
        .eq('user_id', user.id)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  // ==============================
  // UPDATE DOCUMENT
  // ==============================

  Future<void> updateDocument({
    required String documentId,
    required String title,
  }) async {
    final user = supabase.auth.currentUser;

    if (user == null) {
      throw Exception('User is not logged in.');
    }

    await supabase
        .from('documents')
        .update({'title': title})
        .eq('id', documentId)
        .eq('user_id', user.id);
  }

  // ==============================
  // DELETE DOCUMENT
  // ==============================

  Future<void> deleteDocument({required String documentId}) async {
    final user = supabase.auth.currentUser;

    if (user == null) {
      throw Exception('User is not logged in.');
    }

    await supabase
        .from('documents')
        .delete()
        .eq('id', documentId)
        .eq('user_id', user.id);
  }
}
