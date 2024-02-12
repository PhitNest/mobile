import '../../../../../../entities/entities.dart';
import '../../../../../../util/bloc/session.dart';
import '../../../../../../util/http/http.dart';

typedef ExploreBloc = AuthLoaderBloc<void, HttpResponse<ExploreDataModel>>;

typedef ExploreConsumer
    = AuthLoaderConsumer<void, HttpResponse<ExploreDataModel>>;

// class ExploreUserCubit extends Cubit<Iterable<ExploreUser>> {
//   final List<ExploreUser> initUsers;
//   final PageController pageController;
//
//   ExploreUserCubit({required this.initUsers, required this.pageController})
//       : super(initUsers);
//
//   void jumpToStart() => pageController.jumpToPage(0);
//
//   void updateData(Iterable<ExploreUser> newUsers) => emit(newUsers);
// }
