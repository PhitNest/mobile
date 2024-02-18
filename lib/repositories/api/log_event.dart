import '../../entities/log_event.dart';
import '../../util/http/http.dart';

Future<HttpResponse<void>> postLogEvent(LogEvent logEvent) => request(
      route: 'log',
      method: HttpMethod.post,
      data: logEvent.toJson(),
      parse: (_) {},
    );
