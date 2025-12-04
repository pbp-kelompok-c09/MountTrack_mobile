import '../models/community_event.dart';

class EventStore {
  static final List<CommunityEvent> events = [];
  static int _nextEventId = 1;

  static int nextEventId() => _nextEventId++;
}
