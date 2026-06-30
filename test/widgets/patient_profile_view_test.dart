import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mindfulness_app/core/theme/app_colors.dart';
import 'package:mindfulness_app/core/theme/app_theme.dart';
import 'package:mindfulness_app/viewmodels/accessibility_viewmodel.dart';
import 'package:mindfulness_app/viewmodels/auth_viewmodel.dart';
import 'package:mindfulness_app/views/modulo_paciente/patient_profile_view.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FakeProfileAuthViewModel extends ChangeNotifier implements AuthViewModel {
  int signOutCalls = 0;

  @override
  User? get currentUser => null;

  @override
  Future<void> signOut() async {
    signOutCalls += 1;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Widget _buildProfileView(FakeProfileAuthViewModel authViewModel) {
  AppColors.useLight();

  return MultiProvider(
    providers: [
      ChangeNotifierProvider<AuthViewModel>.value(value: authViewModel),
      ChangeNotifierProvider(create: (_) => AccessibilityViewModel()),
    ],
    child: MaterialApp(
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      home: const PatientProfileView(),
    ),
  );
}

void main() {
  testWidgets('profile exposes accessibility settings', (tester) async {
    tester.view.physicalSize = const Size(1200, 2200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final authViewModel = FakeProfileAuthViewModel();

    await tester.pumpWidget(_buildProfileView(authViewModel));
    await tester.pumpAndSettle();

    expect(find.text('Perfil'), findsOneWidget);
    expect(find.text('Accesibilidad'), findsOneWidget);
  });
}
