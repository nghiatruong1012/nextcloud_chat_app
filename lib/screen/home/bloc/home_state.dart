// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'home_bloc.dart';

@immutable
class HomeState extends Equatable {
  final List<Conversations>? listConversations;

  HomeState({this.listConversations});

  @override
  // TODO: implement props
  List<Object?> get props => [this.listConversations];

  HomeState copyWith({
    List<Conversations>? listConversations,
  }) {
    return HomeState(
      listConversations: listConversations ?? this.listConversations,
    );
  }
}

// class LoadConversationState extends HomeState {

// }

// final class HomeInitial extends HomeState {}
