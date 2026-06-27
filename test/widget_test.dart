import 'package:flutter_test/flutter_test.dart';
import 'package:edusphere/app.dart';
import 'package:edusphere/services/cache_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await CacheService.instance.init();
    await tester.pumpWidget(const EduSphereApp());
    expect(find.byType(EduSphereApp), findsOneWidget);
  });
}
