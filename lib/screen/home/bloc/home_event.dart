part of 'home_bloc.dart';

@immutable
class HomeEvent {}

class LoadConversationEvent extends HomeEvent {}

class SearchConversationEvent extends HomeEvent {
  final String query;

  SearchConversationEvent(this.query);
}
