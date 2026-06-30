import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mindfulness_app/core/theme/app_theme.dart';
import 'package:mindfulness_app/features/auth/presentation/register_screen.dart';
import 'package:mindfulness_app/viewmodels/auth_viewmodel.dart';
import 'package:provider/provider.dart';

class FakeRegisterAuthViewModel extends ChangeNotifier
    implements AuthViewModel {
  bool loading = false;
  String? message;
  int signUpCalls = 0;
  String? email;
  String? password;
  String? fullName;

  @override
  bool get isLoading => loading;

  @override
  String? get errorMessage => message;

  @override
  Future<void> signUpWithAcceptedConsent({
    required String email,
    required String password,
    required String fullName,
  }) async {
    signUpCalls += 1;
    this.email = email;
    this.password = password;
    this.fullName = fullName;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Widget _buildRegisterScreen(FakeRegisterAuthViewModel viewModel) {
  return ChangeNotifierProvider<AuthViewModel>.value(
    value: viewModel,
    child: MaterialApp(
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      home: const RegisterScreen(),
      routes: {'/home': (_) => const Scaffold(body: Text('Home de prueba'))},
    ),
  );
}

Future<void> _fillValidRegisterForm(WidgetTester tester) async {
  await tester.enterText(
    find.widgetWithText(TextFormField, 'Nombre y apellido'),
    'Doménica Cevallos',
  );
  await tester.enterText(
    find.widgetWithText(TextFormField, 'Correo personal o institucional'),
    'DOMENICA@ESPE.EDU.EC',
  );
  await tester.enterText(
    find.widgetWithText(TextFormField, 'Contraseña'),
    'Nidara1@',
  );
  await tester.enterText(
    find.widgetWithText(TextFormField, 'Confirmar contraseña'),
    'Nidara1@',
  );
  await tester.pumpAndSettle();
}

Future<void> _tapCreateAccount(WidgetTester tester) async {
  final button = find.widgetWithText(ElevatedButton, 'Crear cuenta');
  await tester.ensureVisible(button);
  await tester.pumpAndSettle();
  await tester.tap(button);
  await tester.pumpAndSettle();
}

ElevatedButton _createAccountButton(WidgetTester tester) {
  return tester.widget<ElevatedButton>(
    find.widgetWithText(ElevatedButton, 'Crear cuenta'),
  );
}

void main() {
  testWidgets('register button starts disabled', (tester) async {
    final viewModel = FakeRegisterAuthViewModel();

    await tester.pumpWidget(_buildRegisterScreen(viewModel));
    await tester.pumpAndSettle();

    expect(_createAccountButton(tester).onPressed, isNull);
  });

  testWidgets('register button enables when all fields are valid', (
    tester,
  ) async {
    final viewModel = FakeRegisterAuthViewModel();

    await tester.pumpWidget(_buildRegisterScreen(viewModel));
    await tester.pumpAndSettle();

    await _fillValidRegisterForm(tester);

    expect(_createAccountButton(tester).onPressed, isNotNull);
    expect(find.text('Entre 8 y 30 caracteres'), findsWidgets);
    expect(find.byIcon(Icons.check_circle_rounded), findsWidgets);
  });

  testWidgets('rejecting consent does not create an account', (tester) async {
    final viewModel = FakeRegisterAuthViewModel();

    await tester.pumpWidget(_buildRegisterScreen(viewModel));
    await tester.pumpAndSettle();
    await _fillValidRegisterForm(tester);

    await _tapCreateAccount(tester);

    expect(find.text('Consentimiento para crear tu cuenta'), findsOneWidget);

    await tester.tap(find.widgetWithText(OutlinedButton, 'Rechazar'));
    await tester.pumpAndSettle();

    expect(viewModel.signUpCalls, 0);
    expect(
      find.text(
        'No se creará la cuenta porque el consentimiento es necesario para usar Nidara.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('accepting consent registers and saves consent flow', (
    tester,
  ) async {
    final viewModel = FakeRegisterAuthViewModel();

    await tester.pumpWidget(_buildRegisterScreen(viewModel));
    await tester.pumpAndSettle();
    await _fillValidRegisterForm(tester);

    await _tapCreateAccount(tester);
    final consentCheckbox = find.byType(Checkbox);
    await tester.ensureVisible(consentCheckbox);
    await tester.tap(consentCheckbox);
    await tester.pumpAndSettle();
    await tester.tap(
      find.widgetWithText(ElevatedButton, 'Aceptar y crear cuenta'),
    );
    await tester.pumpAndSettle();

    expect(viewModel.signUpCalls, 1);
    expect(viewModel.email, 'domenica@espe.edu.ec');
    expect(viewModel.password, 'Nidara1@');
    expect(viewModel.fullName, 'Doménica Cevallos');
    expect(find.text('Home de prueba'), findsOneWidget);
  });
}
