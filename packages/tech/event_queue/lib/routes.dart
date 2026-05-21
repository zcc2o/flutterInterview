import 'package:go_router/go_router.dart';
import 'package:interview_core/interview_core.dart';
import 'screens/event_queue_screen.dart';

final routes = <InterviewRoutes, GoRoute>{
  InterviewRoutes.eventQueue: GoRoute(
    path: InterviewRoutes.eventQueue.path,
    builder: (context, state) => const EventQueueScreen(),
  ),
};
