import '../../../shared/models/template.dart';

abstract class TemplateRepository {
  Future<List<Template>> getTemplates({required String organizationId});
  Future<Template> getTemplate({required String id});
  Future<Template> createTemplate({required Template template});
}
