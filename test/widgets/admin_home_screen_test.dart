import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mindfulness_app/core/theme/app_colors.dart';
import 'package:mindfulness_app/core/theme/app_theme.dart';
import 'package:mindfulness_app/features/home/presentation/admin_home_screen.dart';
import 'package:mindfulness_app/viewmodels/auth_viewmodel.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('blocks admin panel when current user is not admin', (
    tester,
  ) async {
    AppColors.useLight();

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AuthViewModel(),
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const AdminHomeScreen(),
        ),
      ),
    );

    expect(find.text('Acceso restringido'), findsOneWidget);
    expect(
      find.text('Tu cuenta no tiene permisos de Administrador.'),
      findsOneWidget,
    );
  });
}
