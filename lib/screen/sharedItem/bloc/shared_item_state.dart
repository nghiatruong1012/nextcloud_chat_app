part of 'shared_item_bloc.dart';

sealed class SharedItemState extends Equatable {
  const SharedItemState();
  
  @override
  List<Object> get props => [];
}

final class SharedItemInitial extends SharedItemState {}
