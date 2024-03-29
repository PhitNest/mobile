import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../util/bloc/bloc.dart';

typedef FormProvider<Controllers extends FormControllers, ReqType, ResType>
    = _FormProvider<Controllers, LoaderBloc<ReqType, ResType>,
        LoaderConsumer<ReqType, ResType>, ReqType, ResType>;

typedef AuthFormProvider<Controllers extends FormControllers, ReqType, ResType>
    = _FormProvider<Controllers, AuthLoaderBloc<ReqType, ResType>,
        AuthLoaderConsumer<ReqType, ResType>, ReqType, AuthResOrLost<ResType>>;

final class _FormProvider<
    Controllers extends FormControllers,
    BlocType extends LoaderBloc<ReqType, ResType>,
    ConsumerType extends LoaderConsumer<ReqType, ResType>,
    ReqType,
    ResType> extends StatelessWidget {
  final Controllers Function(BuildContext context) createControllers;
  final BlocType Function(BuildContext) createLoader;
  final ConsumerType Function(
    BuildContext context,
    Controllers controllers,
    void Function(ReqType req, LoaderState<ResType> loaderState) submit,
  ) createConsumer;

  void _submit(BuildContext context, ReqType request) =>
      context.formBloc<Controllers>().submit(
            onAccept: () => BlocProvider.of<BlocType>(context).add(
              LoaderLoadEvent(request),
            ),
          );

  const _FormProvider({
    required this.createLoader,
    required this.createConsumer,
    required this.createControllers,
  }) : super();

  @override
  Widget build(BuildContext context) => MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => FormBloc(createControllers(context)),
          ),
          BlocProvider(create: createLoader),
        ],
        child: FormConsumer<Controllers>(
          listener: (context, formState) {},
          builder: (context, formState) {
            final FormBloc<Controllers> formBloc = context.formBloc();
            return Form(
              key: formBloc.controllers.formKey,
              child: createConsumer(
                context,
                formBloc.controllers,
                (req, loaderState) {
                  // only submit if the form is not loading already
                  switch (loaderState) {
                    case LoaderLoadingState():
                      break;
                    default:
                      _submit(context, req);
                  }
                },
              ),
            );
          },
        ),
      );
}
