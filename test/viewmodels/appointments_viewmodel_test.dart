import 'package:flutter_test/flutter_test.dart';
import 'package:mindfulness_app/moduloCitas/model/appointment_model.dart';
import 'package:mindfulness_app/moduloCitas/services/appointments_service.dart';
import 'package:mindfulness_app/moduloCitas/viewmodels/appointments_viewmodel.dart';

class FakeAppointmentsService implements AppointmentsService {
  FakeAppointmentsService({List<Appointment>? seed})
    : appointments = List<Appointment>.from(seed ?? const []);

  final List<Appointment> appointments;
  Appointment? requestedAppointment;
  int getCalls = 0;
  int requestCalls = 0;

  @override
  String? get currentUserId => 'patient-1';

  @override
  Future<List<Appointment>> getAppointments() async {
    getCalls += 1;
    return List<Appointment>.from(appointments);
  }

  @override
  Future<void> requestAppointment(Appointment appointment) async {
    requestCalls += 1;
    requestedAppointment = appointment;
    appointments.add(appointment);
  }

  @override
  Future<void> updateByProfessional({
    required String appointmentId,
    required Map<String, dynamic> data,
  }) async {}

  @override
  Future<void> updateByPatient({
    required String appointmentId,
    required String newStatus,
  }) async {}

  @override
  Future<void> completeAppointment(String appointmentId, String notes) async {}
}

void main() {
  group('AppointmentsViewModel', () {
    test('rejects appointment motive longer than 50 characters', () async {
      final service = FakeAppointmentsService();
      final viewModel = AppointmentsViewModel(service: service);
      final longMotive = List.filled(51, 'a').join();

      expect(
        () => viewModel.createNewRequest(
          'professional-1',
          'Primera vez',
          longMotive,
        ),
        throwsA(
          isA<Exception>().having(
            (error) => error.toString(),
            'message',
            contains(
              'El motivo de la cita permite máximo 50 caracteres. Actualmente tiene 51.',
            ),
          ),
        ),
      );
      expect(service.getCalls, 0);
      expect(service.requestCalls, 0);
    });

    test(
      'does not count extra appointment note against motive limit',
      () async {
        final service = FakeAppointmentsService();
        final viewModel = AppointmentsViewModel(service: service);
        const motive = 'Quiero revisar mi descanso esta semana.';

        await viewModel.createNewRequest(
          'professional-1',
          'Seguimiento',
          motive,
          extraNote: '(Fecha sugerida por el paciente: 24/06/2026)',
        );

        expect(service.requestCalls, 1);
        expect(service.requestedAppointment?.motive, contains(motive));
        expect(
          service.requestedAppointment?.motive,
          contains('(Fecha sugerida por el paciente: 24/06/2026)'),
        );
      },
    );
  });
}
