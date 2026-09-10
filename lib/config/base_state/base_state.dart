class BaseState<T> {
  bool? isLoading;
  String? errorMessage;
  T? data;
  BaseState({this.isLoading,this.errorMessage,this.data});
}