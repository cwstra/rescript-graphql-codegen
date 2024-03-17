// Basically copied from RescriptCore
//include RescriptCore.Core__Global
/***
Bindings to functions available in the global JavaScript scope.
*/

/**
An `id` representing a timeout started via `setTimeout`.

See [`setTimeout`](https://developer.mozilla.org/en-US/docs/Web/API/setTimeout) on MDN.
*/
type timeoutId = RescriptCore.timeoutId

/**
`setTimeout(callback, durationInMilliseconds)` starts a timer that will execute `callback` after `durationInMilliseconds`.

See [`setTimeout`](https://developer.mozilla.org/en-US/docs/Web/API/setTimeout) on MDN.

## Examples
```rescript
// Log to the console after 2 seconds (2000 milliseconds).
let timeoutId = setTimeout(() => {
  Console.log("This prints in 2 seconds.")
}, 2000)
```
*/
let setTimeout = RescriptCore.setTimeout

/**
`setTimeoutFloat(callback, durationInMilliseconds)` starts a timer that will execute `callback` after `durationInMilliseconds`.

The same as `setTimeout`, but allows you to pass a `float` instead of an `int` for the duration.

See [`setTimeout`](https://developer.mozilla.org/en-US/docs/Web/API/setTimeout) on MDN.

## Examples
```rescript
// Log to the console after 2 seconds (2000 milliseconds).
let timeoutId = setTimeoutFloat(() => {
  Console.log("This prints in 2 seconds.")
}, 2000.)
```
*/
let setTimeoutFloat = RescriptCore.setTimeoutFloat

/**
`clearTimeout(timeoutId)` clears a scheduled timeout if it hasn't already executed.

See [`clearTimeout`](https://developer.mozilla.org/en-US/docs/Web/API/clearTimeout) on MDN.

## Examples
```rescript
let timeoutId = setTimeout(() => {
  Console.log("This prints in 2 seconds.")
}, 2000)

// Clearing the timeout right away, before 2 seconds has passed, means that the above callback logging to the console will never run.
clearTimeout(timeoutId)
```
*/
let clearTimeout = RescriptCore.clearTimeout

/**
An `id` representing an interval started via `setInterval`.

See [`setInterval`](https://developer.mozilla.org/en-US/docs/Web/API/setInterval) on MDN.
*/
type intervalId = RescriptCore.intervalId

/**
`setInterval(callback, intervalInMilliseconds)` starts an interval that will execute `callback` every `durationInMilliseconds` milliseconds.

See [`setInterval`](https://developer.mozilla.org/en-US/docs/Web/API/setInterval) on MDN.

## Examples
```rescript
// Log to the console ever 2 seconds (2000 milliseconds).
let intervalId = setInterval(() => {
  Console.log("This prints every 2 seconds.")
}, 2000)
```
*/
let setInterval = RescriptCore.setInterval

/**
`setIntervalFloat(callback, intervalInMilliseconds)` starts an interval that will execute `callback` every `durationInMilliseconds` milliseconds.

The same as `setInterval`, but allows you to pass a `float` instead of an `int` for the duration.

See [`setInterval`](https://developer.mozilla.org/en-US/docs/Web/API/setInterval) on MDN.

## Examples
```rescript
// Log to the console ever 2 seconds (2000 milliseconds).
let intervalId = setIntervalFloat(() => {
  Console.log("This prints every 2 seconds.")
}, 2000.)
```
*/
let setIntervalFloat = RescriptCore.setIntervalFloat

/**
`clearInterval(intervalId)` clears a scheduled interval.

See [`clearInterval`](https://developer.mozilla.org/en-US/docs/Web/API/clearInterval) on MDN.

## Examples
```rescript
let intervalId = setInterval(() => {
  Console.log("This prints in 2 seconds.")
}, 2000)

// Stop the interval after 10 seconds
let timeoutId = setTimeout(() => {
  clearInterval(intervalId)
}, 10000)
```
*/
let clearInterval = RescriptCore.clearInterval

/**
Encodes a URI by replacing characters in the provided string that aren't valid in a URL.

This is intended to operate on full URIs, so it encodes fewer characters than what `encodeURIComponent` does.
If you're looking to encode just parts of a URI, like a query parameter, prefer `encodeURIComponent`.

See [`encodeURI`](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/encodeURI) on MDN.

## Examples
```rescript
Console.log(encodeURI("https://rescript-lang.org?array=[someValue]"))
// Logs "https://rescript-lang.org?array=%5BsomeValue%5D" to the console.
```

*/
let encodeURI = RescriptCore.encodeURI

/**
Decodes a previously encoded URI back to a regular string.

This is intended to operate on full URIs, so it decodes fewer characters than what `decodeURIComponent` does.
If you're looking to decode just parts of a URI, like a query parameter, prefer `decodeURIComponent`.

See [`decodeURI`](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/decodeURI) on MDN.

## Examples
```rescript
Console.log(decodeURI("https://rescript-lang.org?array=%5BsomeValue%5D"))
// Logs "https://rescript-lang.org?array=[someValue]" to the console.
```
*/
let decodeURI = RescriptCore.decodeURI

/**
Encodes a string so it can be used as part of a URI.

See [`encodeURIComponent`](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/encodeURIComponent) on MDN.

## Examples
```rescript
Console.log(encodeURIComponent("array=[someValue]"))
// Logs "array%3D%5BsomeValue%5D" to the console.
```
*/
let encodeURIComponent = RescriptCore.encodeURIComponent

/**
Decodes a previously URI encoded string back to its original form.

See [`decodeURIComponent`](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/decodeURIComponent) on MDN.

## Examples
```rescript
Console.log(decodeURIComponent("array%3D%5BsomeValue%5D"))
// Logs "array=[someValue]" to the console.
```
*/
let decodeURIComponent = RescriptCore.decodeURIComponent

module Array = {
  include RescriptCore.Array
  let takeDropWhile = (arr, fn) => {
    let ind = findIndex(arr, e => !fn(e))
    if ind == -1 {
      (arr, [])
    } else {
      (slice(arr, ~start=0, ~end=ind), sliceToEnd(arr, ~start=ind))
    }
  }
  let groupBy: (array<'t>, 't => string) => Js.Dict.t<('t, array<'t>)> = %raw(`
    (arr, fn) => {
      const result = {}
      arr.forEach(e => {
        const key = fn(e)
        if (key in result) {
          result[key][1].push(e)
        } else {
          result[key] = [e, []]
        }
      })
      return result;
    }
  `)
  let uniqBy: (array<'t>, 't => string) => array<'t> = %raw(`
    (arr, fn) => {
      const m = new Map()
      arr.forEach(e => {
        const key = fn(e)
        if (!m.has(key)) {
          m.set(key, e)
        }
      });
      return new Array(...m.values())
    }
  `)
  type nonEmpty<'t> = ('t, array<'t>)
  let headTail = (arr): option<nonEmpty<_>> =>
    switch (at(arr, 0), sliceToEnd(arr, ~start=1)) {
    | (Some(e), es) => Some(e, es)
    | (None, _) => None
    }
  @send external flatMapWithIndex: (array<'a>, ('a, int) => array<'b>) => array<'b> = "flatMap"
}
module Console = RescriptCore.Console
module DataView = RescriptCore.DataView
module Date = RescriptCore.Date
//module Dict = RescriptCore.Dict
module Error = RescriptCore.Error
module Float = RescriptCore.Float
module Int = RescriptCore.Int
module BigInt = RescriptCore.BigInt
module Math = RescriptCore.Math
module Null = RescriptCore.Null
module Nullable = RescriptCore.Nullable
module Object = RescriptCore.Object
//module Ordering = RescriptCore.Ordering
module Promise = RescriptCore.Promise
module RegExp = RescriptCore.RegExp
//module String = RescriptCore.String
module Symbol = RescriptCore.Symbol
module Type = RescriptCore.Type
module JSON = RescriptCore.JSON

module Iterator = RescriptCore.Iterator
module AsyncIterator = RescriptCore.AsyncIterator
module Map = RescriptCore.Map
module WeakMap = RescriptCore.WeakMap
module Set = RescriptCore.Set
module WeakSet = RescriptCore.WeakSet

module ArrayBuffer = RescriptCore.ArrayBuffer
module TypedArray = RescriptCore.TypedArray
module Float32Array = RescriptCore.Float32Array
module Float64Array = RescriptCore.Float64Array
module Int8Array = RescriptCore.Int8Array
module Int16Array = RescriptCore.Int16Array
module Int32Array = RescriptCore.Int32Array
module Uint8Array = RescriptCore.Uint8Array
module Uint16Array = RescriptCore.Uint16Array
module Uint32Array = RescriptCore.Uint32Array
module Uint8ClampedArray = RescriptCore.Uint8ClampedArray
module BigInt64Array = RescriptCore.BigInt64Array
module BigUint64Array = RescriptCore.BigUint64Array

module Intl = RescriptCore.Intl

@val external window: Dom.window = "window"
@val external document: Dom.document = "document"
@val external globalThis: {..} = "globalThis"

external null: RescriptCore.Nullable.t<'a> = "#null"
external undefined: RescriptCore.Nullable.t<'a> = "#undefined"
external typeof: 'a => RescriptCore.Type.t = "#typeof"

type t<'a> = Js.t<'a>
module MapperRt = Js.MapperRt
module Internal = Js.Internal
module Re = RescriptCore.RegExp // needed for the %re sugar
module Exn = Js.Exn
// module Option = RescriptCore.Option
module List = RescriptCore.List
//module Result = RescriptCore.Result

type null<+'a> = Js.null<'a>

type undefined<+'a> = Js.undefined<'a>

type nullable<+'a> = Js.nullable<'a>

let panic = RescriptCore.Error.panic
// End copy

module Dict = {
  include RescriptCore.Dict
  let put: (t<'t>, string, 't) => t<'t> = %raw(`
    (dict, key, value) => ({...dict, [key]: value})
  `)
  let merge: (t<'t>, t<'t>) => t<'t> = %raw(`
    (d1, d2) => ({...d1, ...d2})
  `)
  let mergeWith: (t<'t>, t<'t>, ('t, 't) => 't) => t<'t> = %raw(`
    (d1, d2, fn) => {
      const result = {...d1}
      Object.entries(d2).forEach(([k, v]) => {
        result[k] =
          k in d1
            ? fn(d1[k], d2[k])
            : d2[k]
      })
      return result
    }
  `)
  let update: (t<'t>, string, option<'t> => 't) => t<'t> = %raw(`
    (dict, key, fn) => ({...dict, [key]: fn(dict[key])})
  `)
}
module Option = {
  include RescriptCore.Option
  let ok_or = (opt, err): result<_, _> =>
    switch opt {
    | Some(v) => Ok(v)
    | None => Error(err)
    }
  let apply: (option<'a => 'b>, 'a) => option<'b> = %raw(`
    (mFn, a) => mFn?.(a)
  `)
  let apply2: (option<('a, 'b) => 'c>, 'a, 'b) => option<'c> = %raw(`
    (mFn, a, b) => mFn?.(a, b)
  `)
  let toArray = opt =>
    switch opt {
    | Some(o) => [o]
    | None => []
    }
  let traverse = (arr, fn): option<array<_>> =>
    Array.reduce(arr, Some([]), (res, ele) =>
      flatMap(res, arr =>
        map(
          fn(ele),
          a => {
            Array.push(arr, a)
            arr
          },
        )
      )
    )
  let liftConcat = (concat, o1, o2) =>
    switch (o1, o2) {
    | (Some(v1), Some(v2)) => Some(concat(v1, v2))
    | (Some(_), None) => o1
    | (None, _) => o2
    }
  let getOrExn = (o: option<'t>, e: exn): 't =>
    switch o {
    | Some(o) => o
    | None => raise(e)
    }
  let getOrPanic = (o: option<'t>, msg: string): 't =>
    switch o {
    | Some(o) => o
    | None => panic(msg)
    }
}
module Result = {
  include RescriptCore.Result
  let traverse = (arr, fn): result<array<'b>, 'e> =>
    Array.reduce(arr, Ok([]), (res, ele) =>
      flatMap(res, arr =>
        map(
          fn(ele),
          a => {
            Array.push(arr, a)
            arr
          },
        )
      )
    )
}
module Either = {
  type t<'a, 'b> =
    | Left('a)
    | Right('b)
  let partition = arr => {
    let lefts = []
    let rights = []
    Array.forEach(arr, elem =>
      switch elem {
      | Left(l) => Array.push(lefts, l)
      | Right(r) => Array.push(rights, r)
      }
    )
    (lefts, rights)
  }
  let partitionMap = (arr, fn) => {
    let lefts = []
    let rights = []
    Array.forEach(arr, elem =>
      switch fn(elem) {
      | Left(l) => Array.push(lefts, l)
      | Right(r) => Array.push(rights, r)
      }
    )
    (lefts, rights)
  }
}
module Ordering = {
  include RescriptCore.Ordering
  let compare = (a, b) =>
    if a == b {
      equal
    } else if a < b {
      less
    } else {
      greater
    }
}
module String = {
  include RescriptCore.String
  let capitalize = s => concat(charAt(s, 0)->toUpperCase, sliceToEnd(s, ~start=1))
  @module("./camelcase_facade.mjs")
  external pascalCase: string => string = "pascalCase"
}
