import 'package:go_router/go_router.dart';
import 'package:interview_core/interview_core.dart';
import 'screens/repaint_boundary_screen.dart';

final routes = <InterviewRoutes, GoRoute>{
  InterviewRoutes.repaintBoundary: GoRoute(
    path: InterviewRoutes.repaintBoundary.path,
    builder: (context, state) => const RepaintBoundaryScreen(),
  ),
};
