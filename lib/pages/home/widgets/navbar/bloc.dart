part of 'navbar.dart';

enum NavBarPage { friends, explore, chat, options }

sealed class NavBarState extends Equatable {
  final NavBarPage page;
  final int numAlerts;
  String? get logoAssetPath;

  const NavBarState({
    required this.page,
    required this.numAlerts,
  }) : super();

  @override
  List<Object?> get props => [page, logoAssetPath, numAlerts];
}

enum NavBarLoadingReason { explore, sendRequest }

sealed class NavBarLoadingBaseState extends NavBarState {
  @override
  String? get logoAssetPath =>
      page == NavBarPage.explore ? null : Assets.logo.path;

  const NavBarLoadingBaseState({
    required super.page,
    required super.numAlerts,
  }) : super();
}

final class NavBarInitialState extends NavBarLoadingBaseState {
  const NavBarInitialState({
    required super.page,
    required super.numAlerts,
  }) : super();
}

final class NavBarSendingFriendRequestState extends NavBarLoadingBaseState {
  @override
  String? get logoAssetPath =>
      page == NavBarPage.explore ? null : Assets.logo.path;

  const NavBarSendingFriendRequestState({
    required super.page,
    required super.numAlerts,
  }) : super();
}

final class NavBarInactiveState extends NavBarState {
  @override
  String? get logoAssetPath => Assets.logo.path;

  const NavBarInactiveState({
    required super.page,
    required super.numAlerts,
  }) : super();
}

sealed class NavBarActiveState extends NavBarState {
  @override
  String? get logoAssetPath => Assets.coloredLogo.path;

  const NavBarActiveState({
    required super.numAlerts,
  }) : super(page: NavBarPage.explore);
}

final class NavBarLogoReadyState extends NavBarActiveState {
  const NavBarLogoReadyState({
    required super.numAlerts,
  }) : super();
}

final class NavBarHoldingLogoState extends NavBarActiveState {
  final int countdown;
  final CancelableOperation<void> nextCount;

  const NavBarHoldingLogoState(
    this.countdown,
    this.nextCount, {
    required super.numAlerts,
  }) : super();

  @override
  List<Object?> get props => [...super.props, countdown, nextCount];
}

final class NavBarReversedState extends NavBarActiveState {
  @override
  String? get logoAssetPath => Assets.darkLogo.path;

  const NavBarReversedState({
    required super.numAlerts,
  }) : super();
}

sealed class NavBarEvent extends Equatable {
  const NavBarEvent() : super();
}

final class NavBarPressPageEvent extends NavBarEvent {
  final NavBarPage page;

  const NavBarPressPageEvent(this.page) : super();

  @override
  List<Object?> get props => [page];
}

final class NavBarSetLoadingEvent extends NavBarEvent {
  final bool loading;

  const NavBarSetLoadingEvent(this.loading) : super();

  @override
  List<Object?> get props => [loading];
}

final class NavBarPressLogoEvent extends NavBarEvent {
  const NavBarPressLogoEvent() : super();

  @override
  List<Object?> get props => [];
}

final class NavBarReleaseLogoEvent extends NavBarEvent {
  const NavBarReleaseLogoEvent() : super();

  @override
  List<Object?> get props => [];
}

final class NavBarCancelLogoEvent extends NavBarEvent {
  const NavBarCancelLogoEvent() : super();

  @override
  List<Object?> get props => [];
}

final class NavBarCountDownEvent extends NavBarEvent {
  const NavBarCountDownEvent() : super();

  @override
  List<Object?> get props => [];
}

final class NavBarReverseEvent extends NavBarEvent {
  const NavBarReverseEvent() : super();

  @override
  List<Object?> get props => [];
}

final class NavBarAnimateEvent extends NavBarEvent {
  const NavBarAnimateEvent() : super();

  @override
  List<Object?> get props => [];
}

final class NavBarSetNumAlertsEvent extends NavBarEvent {
  final int numAlerts;

  const NavBarSetNumAlertsEvent(this.numAlerts) : super();

  @override
  List<Object?> get props => [numAlerts];
}

final class NavBarBloc extends Bloc<NavBarEvent, NavBarState> {
  NavBarBloc()
      : super(
            const NavBarInitialState(numAlerts: 0, page: NavBarPage.explore)) {
    on<NavBarSetLoadingEvent>(
      (event, emit) {
        switch (state) {
          case NavBarReversedState():
            break;
          default:
            if (event.loading) {
              emit(NavBarInitialState(
                  numAlerts: state.numAlerts, page: state.page));
            } else {
              emit(NavBarInactiveState(
                numAlerts: state.numAlerts,
                page: state.page,
              ));
            }
        }
      },
    );

    on<NavBarPressPageEvent>(
      (event, emit) async {
        switch (state) {
          case NavBarInitialState() || NavBarSendingFriendRequestState():
            emit(NavBarInitialState(
                page: event.page, numAlerts: state.numAlerts));
          case NavBarReversedState() ||
                NavBarInactiveState() ||
                NavBarLogoReadyState():
            emit(NavBarInactiveState(
                page: event.page, numAlerts: state.numAlerts));
          case NavBarHoldingLogoState(
              nextCount: final nextCount,
            ):
            await nextCount.cancel();
            emit(NavBarInactiveState(
                page: event.page, numAlerts: state.numAlerts));
        }
      },
    );

    on<NavBarPressLogoEvent>(
      (event, emit) {
        switch (state) {
          case NavBarLogoReadyState():
            emit(NavBarHoldingLogoState(
                3,
                CancelableOperation.fromFuture(
                    Future.delayed(const Duration(seconds: 1)))
                  ..then((_) => add(const NavBarCountDownEvent())),
                numAlerts: state.numAlerts));
          case NavBarHoldingLogoState():
            badState(state, event);
          default:
        }
      },
    );

    on<NavBarReleaseLogoEvent>(
      (event, emit) async {
        switch (state) {
          case NavBarHoldingLogoState(nextCount: final nextCount):
            await nextCount.cancel();
            emit(NavBarInactiveState(
                page: NavBarPage.explore, numAlerts: state.numAlerts));
          case NavBarInactiveState() ||
                NavBarReversedState() ||
                NavBarLogoReadyState():
            emit(NavBarInactiveState(
                page: NavBarPage.explore, numAlerts: state.numAlerts));
          case NavBarInitialState():
            emit(NavBarInitialState(
                page: NavBarPage.explore, numAlerts: state.numAlerts));
            break;
          case NavBarSendingFriendRequestState():
            emit(NavBarSendingFriendRequestState(
                page: NavBarPage.explore, numAlerts: state.numAlerts));
        }
      },
    );

    on<NavBarCancelLogoEvent>(
      (event, emit) async {
        switch (state) {
          case NavBarHoldingLogoState(nextCount: final nextCount):
            await nextCount.cancel();
            emit(NavBarInactiveState(
                page: NavBarPage.explore, numAlerts: state.numAlerts));
          default:
        }
      },
    );

    on<NavBarCountDownEvent>(
      (event, emit) {
        switch (state) {
          case NavBarHoldingLogoState(countdown: final countdown):
            if (countdown > 1) {
              emit(
                NavBarHoldingLogoState(
                  countdown - 1,
                  CancelableOperation.fromFuture(
                      Future.delayed(const Duration(seconds: 1)))
                    ..then(
                      (_) => add(
                        const NavBarCountDownEvent(),
                      ),
                    ),
                  numAlerts: state.numAlerts,
                ),
              );
            } else {
              emit(NavBarSendingFriendRequestState(
                page: NavBarPage.explore,
                numAlerts: state.numAlerts,
              ));
            }
          default:
            badState(state, event);
        }
      },
    );

    on<NavBarReverseEvent>(
      (event, emit) {
        switch (state) {
          case NavBarLogoReadyState() ||
                NavBarReversedState() ||
                NavBarHoldingLogoState():
            badState(state, event);
          case NavBarInactiveState() ||
                NavBarInitialState() ||
                NavBarSendingFriendRequestState():
            emit(NavBarReversedState(numAlerts: state.numAlerts));
        }
      },
    );

    on<NavBarAnimateEvent>(
      (event, emit) {
        emit(NavBarLogoReadyState(numAlerts: state.numAlerts));
      },
    );

    on<NavBarSetNumAlertsEvent>((event, emit) {
      switch (state) {
        case NavBarInitialState(page: final page):
          emit(NavBarInitialState(page: page, numAlerts: event.numAlerts));
        case NavBarInactiveState(page: final page):
          emit(NavBarInactiveState(page: page, numAlerts: event.numAlerts));
        case NavBarLogoReadyState():
          emit(NavBarLogoReadyState(numAlerts: event.numAlerts));
        case NavBarHoldingLogoState(
            countdown: final countdown,
            nextCount: final nextCount,
          ):
          emit(NavBarHoldingLogoState(countdown, nextCount,
              numAlerts: event.numAlerts));
        case NavBarReversedState():
          emit(NavBarReversedState(numAlerts: event.numAlerts));
        case NavBarSendingFriendRequestState():
          emit(NavBarSendingFriendRequestState(
              numAlerts: event.numAlerts, page: state.page));
      }
    });
  }

  @override
  Future<void> close() async {
    switch (state) {
      case NavBarHoldingLogoState(
          nextCount: final nextCount,
        ):
        await nextCount.cancel();
      default:
    }
    return super.close();
  }
}

extension NavBarBlocGetter on BuildContext {
  NavBarBloc get navBarBloc => BlocProvider.of(this);
}

void _handleNavBarState(
  BuildContext context,
  PageController pageController,
  NavBarState state,
) =>
    context.homeBloc.state.handleAuthHttp(
      success: (response, _) {
        user() => response
            .explore[pageController.page!.round() % response.explore.length];
        switch (state) {
          case NavBarInactiveState(page: final page):
            final explore = response.explore;
            if (pageController.hasClients &&
                page == NavBarPage.explore &&
                explore.isNotEmpty &&
                !context.sendReportBloc.state.operations
                    .map((op) => op.req.user.id)
                    .contains(user().id)) {
              context.navBarBloc.add(const NavBarAnimateEvent());
            }
          case NavBarSendingFriendRequestState():
            context.sendFriendRequestBloc.add(ParallelPushEvent(user()));
          default:
        }
      },
      fallback: () {},
    );
