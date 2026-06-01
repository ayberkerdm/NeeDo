import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/presentation/splash_screen.dart';
import '../../features/auth/presentation/onboarding_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/main_layout/presentation/main_layout.dart';
import '../../features/requests/presentation/create_request_wizard.dart';
import '../../features/requests/presentation/proposals_screen.dart';
import '../../features/profile/presentation/provider_profile_screen.dart';
import '../../features/messages/presentation/chat_screen.dart';
import '../../features/requests/presentation/appointment_tracking_screen.dart';
import '../../features/requests/presentation/review_screen.dart';
import '../../features/provider/presentation/provider_main_layout.dart';
import '../../features/provider/presentation/provider_job_detail_screen.dart';
import '../../features/provider/presentation/provider_submit_proposal_screen.dart';
import '../../features/requests/data/models/request_model.dart';
import '../../features/notifications/presentation/notifications_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      // --- CLIENT ROUTES ---
      GoRoute(
        path: '/home',
        builder: (context, state) => const MainLayout(),
      ),
      GoRoute(
        path: '/create-request',
        builder: (context, state) => const CreateRequestWizard(),
      ),
      GoRoute(
        path: '/proposals',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return ProposalsScreen(requestId: extra?['requestId']);
        },
      ),
      GoRoute(
        path: '/provider-profile',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return ProviderProfileScreen(
            providerId: extra?['providerId'] ?? '',
          );
        },
      ),
      GoRoute(
        path: '/chat',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return ChatScreen(
            otherUserId: extra?['otherUserId'] ?? '',
            otherUserName: extra?['otherUserName'] ?? 'Sohbet',
          );
        },
      ),
      GoRoute(
        path: '/appointment-tracking',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return AppointmentTrackingScreen(requestId: extra?['requestId'] ?? '');
        },
      ),
      GoRoute(
        path: '/review',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return ReviewScreen(
            requestId: extra?['requestId'] ?? '',
            serviceName: extra?['serviceName'] ?? 'Hizmet',
          );
        },
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
      
      // --- PROVIDER ROUTES ---
      GoRoute(
        path: '/provider-home',
        builder: (context, state) => const ProviderMainLayout(),
      ),
      GoRoute(
        path: '/provider-job-detail',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return ProviderJobDetailScreen(offer: extra!['offer']);
        },
      ),
      GoRoute(
        path: '/submit-proposal',
        builder: (context, state) {
          final request = state.extra as RequestModel?;
          return ProviderSubmitProposalScreen(request: request);
        },
      ),
    ],
  );
});
