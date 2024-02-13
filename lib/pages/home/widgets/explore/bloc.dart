import '../../../../entities/entities.dart';
import '../../../../util/bloc/session.dart';
import '../../../../util/http/http.dart';

typedef ExploreBloc = AuthLoaderBloc<void, HttpResponse<ExploreDataLoaded>>;

typedef ExploreConsumer
    = AuthLoaderConsumer<void, HttpResponse<ExploreDataLoaded>>;
