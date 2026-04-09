import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../shared/models/template.dart';
import 'template_repository.dart';

class SupabaseTemplateRepository implements TemplateRepository {
  SupabaseTemplateRepository({required SupabaseClient client})
      : _client = client;

  final SupabaseClient _client;

  @override
  Future<List<Template>> getTemplates({required String organizationId}) async {
    final response = await _client
        .from('templates')
        .select()
        .eq('organization_id', organizationId)
        .order('created_at', ascending: false);

    return response.map((json) => Template.fromJson(json)).toList();
  }

  @override
  Future<Template> getTemplate({required String id}) async {
    final response =
        await _client.from('templates').select().eq('id', id).single();

    return Template.fromJson(response);
  }

  @override
  Future<Template> createTemplate({required Template template}) async {
    final response = await _client
        .from('templates')
        .insert(template.toJson()..remove('id'))
        .select()
        .single();

    return Template.fromJson(response);
  }
}
