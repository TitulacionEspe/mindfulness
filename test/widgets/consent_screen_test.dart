import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mindfulness_app/core/theme/app_theme.dart';
import 'package:mindfulness_app/features/auth/presentation/consent_screen.dart';
import 'package:mindfulness_app/viewmodels/auth_viewmodel.dart';
import 'package:provider/provider.dart';

class FakeConsentAuthViewModel extends ChangeNotifier implements AuthViewModel {
  FakeConsentAuthViewModel({required this.accepted});

  bool accepted;
  bool loading = false;
  String? message;
  int acceptCalls = 0;
  int signOutCalls = 0;

  @override
  bool get hasAcceptedConsent => accepted;

  @override
  bool get isLoading => loading;

  @override
  String? get errorMessage => message;

  @override
  Future<void> acceptConsent() async {
    acceptCalls += 1;
    accepted = true;
    notifyListeners();
  }

  @override
  Future<void> signOut() async {
    signOutCalls += 1;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Widget _buildConsentScreen(
  FakeConsentAuthViewModel viewModel, {
  bool readOnly = false,
}) {
  return ChangeNotifierProvider<AuthViewModel>.value(
    value: viewModel,
    child: MaterialApp(
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      home: ConsentScreen(readOnly: readOnly),
    ),
  );
}

void main() {
  testWidgets('shows accepted consent as read-only information', (
    tester,
  ) async {
    final viewModel = FakeConsentAuthViewModel(accepted: true);

    await tester.pumpWidget(_buildConsentScreen(viewModel, readOnly: true));
    await tester.pumpAndSettle();

    expect(find.text('Consentimiento aceptado'), findsOneWidget);
    expect(find.text('Volver'), findsOneWidget);
    expect(find.text('Aceptar'), findsNothing);
    expect(find.text('Rechazar'), findsNothing);
    expect(viewModel.acceptCalls, 0);
  });

  testWidgets('requires explicit consent before accepting initial access', (
    tester,
  ) async {
    final viewModel = FakeConsentAuthViewModel(accepted: false);

    await tester.pumpWidget(_buildConsentScreen(viewModel));
    await tester.pumpAndSettle();

    final acceptButton = find.widgetWithText(ElevatedButton, 'Aceptar');

    await tester.tap(acceptButton);
    await tester.pumpAndSettle();

    expect(viewModel.acceptCalls, 0);
    expect(
      find.text('Debes aceptar los términos para continuar.'),
      findsOneWidget,
    );

    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(Checkbox));
    await tester.pumpAndSettle();
    await tester.tap(acceptButton);
    await tester.pumpAndSettle();

    expect(viewModel.acceptCalls, 1);
  });
}
