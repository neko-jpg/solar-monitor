import 'dart:async';

sealed class Result<T> {
  const Result();

  bool get isOk => this is Ok<T>;
  bool get isErr => this is Err<T>;

  static Future<Result<T>> guard<T>(Future<T> Function() future) async {
    try {
      return Ok(await future());
    } catch (e) {
      return Err(e);
    }
  }
}
class Ok<T> extends Result<T> { final T value; const Ok(this.value); }
class Err<T> extends Result<T> { final Object error; const Err(this.error); }
