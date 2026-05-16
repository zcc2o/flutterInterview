import 'package:go_router/go_router.dart';
import 'package:interview_core/interview_core.dart';
import 'screens/storage_screen.dart';

final routes = <InterviewRoutes, GoRoute>{
  InterviewRoutes.storage: GoRoute(
    path: InterviewRoutes.storage.path,
    builder: (context, state) => const StorageScreen(),
  ),
};
