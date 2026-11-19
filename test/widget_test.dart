import 'package:flutter_test/flutter_test.dart';
import 'package:landlord_app/core/ai/offline_ai_assistant.dart';

void main() {
  group('LandLord Core Unit Tests', () {
    test('Offline AI Assistant responds to yield query', () {
      final response = OfflineAiAssistant.getResponse('What is the rental yield in Dhaka?');
      expect(response.contains('Gross Yield'), isTrue);
      expect(response.contains('Net Yield'), isTrue);
    });

    test('Offline AI Assistant responds to rent increase query', () {
      final response = OfflineAiAssistant.getResponse('How should I handle a rent increase hike?');
      expect(response.contains('Rent Increase Guidelines'), isTrue);
    });

    test('Offline AI Assistant responds to maintenance query', () {
      final response = OfflineAiAssistant.getResponse('Emergency water leak in bathroom');
      expect(response.contains('Maintenance Best Practices'), isTrue);
    });
  });
}
