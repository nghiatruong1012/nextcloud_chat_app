// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'home_bloc.dart';

@immutable
class HomeState extends Equatable {
  final List<Conversations>? listConversations;
  final List<Conversations>? searchList;

  const HomeState({this.listConversations, this.searchList});

  @override
  // TODO: implement props
  List<Object?> get props => [listConversations, searchList];

  HomeState copyWith({
    List<Conversations>? listConversations,
    List<Conversations>? searchList,
  }) {
    return HomeState(
      listConversations: listConversations ?? this.listConversations,
      searchList: searchList ?? this.searchList,
    );
  }
}

// class LoadConversationState extends HomeState {

// }

// final class HomeInitial extends HomeState {}
