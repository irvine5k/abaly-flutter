import '../../../shared/models/patient.dart';

abstract class PatientRepository {
  Future<List<Patient>> getPatients({required String organizationId});
  Future<Patient> getPatient({required String id});
  Future<Patient> createPatient({required Patient patient});
}
