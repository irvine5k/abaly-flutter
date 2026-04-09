import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../shared/models/patient.dart';
import 'patient_repository.dart';

class SupabasePatientRepository implements PatientRepository {
  SupabasePatientRepository({required SupabaseClient client}) : _client = client;

  final SupabaseClient _client;

  @override
  Future<List<Patient>> getPatients({required String organizationId}) async {
    final response = await _client
        .from('patients')
        .select()
        .eq('organization_id', organizationId)
        .order('created_at', ascending: false);

    return response.map((json) => Patient.fromJson(json)).toList();
  }

  @override
  Future<Patient> getPatient({required String id}) async {
    final response =
        await _client.from('patients').select().eq('id', id).single();

    return Patient.fromJson(response);
  }

  @override
  Future<Patient> createPatient({required Patient patient}) async {
    final response = await _client
        .from('patients')
        .insert(patient.toJson()..remove('id'))
        .select()
        .single();

    return Patient.fromJson(response);
  }
}
