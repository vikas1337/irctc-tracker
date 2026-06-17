import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:railradar/main.dart';
import 'package:railradar/state/app_state.dart';

void main() {
  testWidgets('app boots into home with quick actions', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(RailRadarApp(appState: AppState(prefs)));
    await tester.pumpAndSettle();

    expect(find.text('RailRadar'), findsOneWidget);
    expect(find.text('Live status'), findsOneWidget);
    expect(find.text('PNR status'), findsOneWidget);
  });
}
