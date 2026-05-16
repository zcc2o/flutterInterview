import 'package:go_router/go_router.dart';
import 'package:interview_core/interview_core.dart';
import 'screens/painter_screen.dart';

final routes = <InterviewRoutes, GoRoute>{
  InterviewRoutes.painter: GoRoute(
    path: InterviewRoutes.painter.path,
    builder: (context, state) => const PainterScreen(),
  ),
};
