import 'package:go_router/go_router.dart';
import 'package:interview_core/interview_core.dart';
import 'package:interview_widgets/interview_widgets.dart';
import 'package:tech_precise_timer/routes.dart' as timer;
import 'package:tech_router_guide/routes.dart' as router_guide;
import 'package:tech_state_management/routes.dart' as state;
import 'package:tech_di_guide/routes.dart' as di;
import 'package:tech_http_client/routes.dart' as http;
import 'package:tech_custom_painter/routes.dart' as painter;
import 'package:tech_animation/routes.dart' as animation;
import 'package:tech_local_storage/routes.dart' as storage;
import 'package:tech_event_queue/routes.dart' as event_queue;
import 'package:tech_repaint_boundary/routes.dart' as repaint;

final router = GoRouter(
  initialLocation: InterviewRoutes.home.path,
  routes: [
    GoRoute(
      path: InterviewRoutes.home.path,
      builder: (context, state) => const HomeScreen(),
    ),
    ...timer.routes.values,
    ...router_guide.routes.values,
    ...state.routes.values,
    ...di.routes.values,
    ...http.routes.values,
    ...painter.routes.values,
    ...animation.routes.values,
    ...storage.routes.values,
    ...event_queue.routes.values,
    ...repaint.routes.values,
  ],
);
