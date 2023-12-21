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
  @new external makeUninitializedUnsafe: int => array<'a> = "Array"
  @set external truncateToLengthUnsafe: (array<'a>, int) => unit = "length"
  external getUnsafe: (array<'a>, int) => 'a = "%array_unsafe_get"
  external setUnsafe: (array<'a>, int, 'a) => unit = "%array_unsafe_set"

  @val external fromIterator: Core__Iterator.t<'a> => array<'a> = "Array.from"
  @val external fromArrayLike: Js.Array2.array_like<'a> => array<'a> = "Array.from"
  @val
  external fromArrayLikeWithMap: (Js.Array2.array_like<'a>, 'a => 'b) => array<'b> = "Array.from"

  @send external fillAll: (array<'a>, 'a) => unit = "fill"

  @send external fillToEnd: (array<'a>, 'a, ~start: int) => unit = "fill"

  @send external fill: (array<'a>, 'a, ~start: int, ~end: int) => unit = "fill"

  let make = (~length, x) =>
    if length <= 0 {
      []
    } else {
      let arr = makeUninitializedUnsafe(length)
      arr->fillAll(x)
      arr
    }

  let fromInitializer = (~length, f) =>
    if length <= 0 {
      []
    } else {
      let arr = makeUninitializedUnsafe(length)
      for i in 0 to length - 1 {
        arr->setUnsafe(i, f(i))
      }
      arr
    }

  @val external isArray: 'a => bool = "Array.isArray"

  @get external length: array<'a> => int = "length"

  let rec equalFromIndex = (a, b, i, eq, len) =>
    if i === len {
      true
    } else if eq(a->getUnsafe(i), b->getUnsafe(i)) {
      equalFromIndex(a, b, i + 1, eq, len)
    } else {
      false
    }

  let equal = (a, b, eq) => {
    let len = a->length
    if len === b->length {
      equalFromIndex(a, b, 0, eq, len)
    } else {
      false
    }
  }

  let rec compareFromIndex = (a, b, i, cmp, len) =>
    if i === len {
      Core__Ordering.equal
    } else {
      let c = cmp(a->getUnsafe(i), b->getUnsafe(i))
      if c == Core__Ordering.equal {
        compareFromIndex(a, b, i + 1, cmp, len)
      } else {
        c
      }
    }

  let compare = (a, b, cmp) => {
    let lenA = a->length
    let lenB = b->length
    lenA < lenB
      ? Core__Ordering.less
      : lenA > lenB
      ? Core__Ordering.greater
      : compareFromIndex(a, b, 0, cmp, lenA)
  }

  @send external copyAllWithin: (array<'a>, ~target: int) => array<'a> = "copyWithin"

  @send
  external copyWithinToEnd: (array<'a>, ~target: int, ~start: int) => array<'a> = "copyWithin"

  @send
  external copyWithin: (array<'a>, ~target: int, ~start: int, ~end: int) => array<'a> = "copyWithin"

  @send external pop: array<'a> => option<'a> = "pop"

  @send external push: (array<'a>, 'a) => unit = "push"

  @variadic @send external pushMany: (array<'a>, array<'a>) => unit = "push"

  @send external reverse: array<'a> => unit = "reverse"
  @send external toReversed: array<'a> => array<'a> = "toReversed"

  @send external shift: array<'a> => option<'a> = "shift"

  @variadic @send
  external splice: (array<'a>, ~start: int, ~remove: int, ~insert: array<'a>) => unit = "splice"
  @variadic @send
  external toSpliced: (array<'a>, ~start: int, ~remove: int, ~insert: array<'a>) => array<'a> =
    "toSpliced"

  @send external with: (array<'a>, int, 'a) => array<'a> = "with"

  @send external unshift: (array<'a>, 'a) => unit = "unshift"

  @variadic @send external unshiftMany: (array<'a>, array<'a>) => unit = "unshift"

  @send external concat: (array<'a>, array<'a>) => array<'a> = "concat"
  @variadic @send external concatMany: (array<'a>, array<array<'a>>) => array<'a> = "concat"

  @send external flat: array<array<'a>> => array<'a> = "flat"

  @send external includes: (array<'a>, 'a) => bool = "includes"

  @send external indexOf: (array<'a>, 'a) => int = "indexOf"
  let indexOfOpt = (arr, item) =>
    switch arr->indexOf(item) {
    | -1 => None
    | index => Some(index)
    }
  @send external indexOfFrom: (array<'a>, 'a, int) => int = "indexOf"

  @send external joinWith: (array<string>, string) => string = "join"

  @send external joinWithUnsafe: (array<'a>, string) => string = "join"

  @send external lastIndexOf: (array<'a>, 'a) => int = "lastIndexOf"
  let lastIndexOfOpt = (arr, item) =>
    switch arr->lastIndexOf(item) {
    | -1 => None
    | index => Some(index)
    }
  @send external lastIndexOfFrom: (array<'a>, 'a, int) => int = "lastIndexOf"

  @send external slice: (array<'a>, ~start: int, ~end: int) => array<'a> = "slice"
  @send external sliceToEnd: (array<'a>, ~start: int) => array<'a> = "slice"
  @send external copy: array<'a> => array<'a> = "slice"

  @send external sort: (array<'a>, ('a, 'a) => Core__Ordering.t) => unit = "sort"
  @send external toSorted: (array<'a>, ('a, 'a) => Core__Ordering.t) => array<'a> = "toSorted"

  @send external toString: array<'a> => string = "toString"
  @send external toLocaleString: array<'a> => string = "toLocaleString"

  @send external every: (array<'a>, 'a => bool) => bool = "every"
  @send external everyWithIndex: (array<'a>, ('a, int) => bool) => bool = "every"

  @send external filter: (array<'a>, 'a => bool) => array<'a> = "filter"
  @send external filterWithIndex: (array<'a>, ('a, int) => bool) => array<'a> = "filter"

  @send external find: (array<'a>, 'a => bool) => option<'a> = "find"
  @send external findWithIndex: (array<'a>, ('a, int) => bool) => option<'a> = "find"

  @send external findIndex: (array<'a>, 'a => bool) => int = "findIndex"
  @send external findIndexWithIndex: (array<'a>, ('a, int) => bool) => int = "findIndex"

  @send external forEach: (array<'a>, 'a => unit) => unit = "forEach"
  @send external forEachWithIndex: (array<'a>, ('a, int) => unit) => unit = "forEach"

  @send external map: (array<'a>, 'a => 'b) => array<'b> = "map"
  @send external mapWithIndex: (array<'a>, ('a, int) => 'b) => array<'b> = "map"

  @send external reduce: (array<'b>, ('a, 'b) => 'a, 'a) => 'a = "reduce"
  let reduce = (arr, init, f) => reduce(arr, f, init)
  @send external reduceWithIndex: (array<'b>, ('a, 'b, int) => 'a, 'a) => 'a = "reduce"
  let reduceWithIndex = (arr, init, f) => reduceWithIndex(arr, f, init)
  @send
  external reduceRight: (array<'b>, ('a, 'b) => 'a, 'a) => 'a = "reduceRight"
  let reduceRight = (arr, init, f) => reduceRight(arr, f, init)
  @send
  external reduceRightWithIndex: (array<'b>, ('a, 'b, int) => 'a, 'a) => 'a = "reduceRight"
  let reduceRightWithIndex = (arr, init, f) => reduceRightWithIndex(arr, f, init)

  @send external some: (array<'a>, 'a => bool) => bool = "some"
  @send external someWithIndex: (array<'a>, ('a, int) => bool) => bool = "some"

  @get_index external get: (array<'a>, int) => option<'a> = ""
  @set_index external set: (array<'a>, int, 'a) => unit = ""

  @get_index external getSymbol: (array<'a>, Core__Symbol.t) => option<'b> = ""
  @get_index external getSymbolUnsafe: (array<'a>, Core__Symbol.t) => 'b = ""
  @set_index external setSymbol: (array<'a>, Core__Symbol.t, 'b) => unit = ""

  let findIndexOpt = (array: array<'a>, finder: 'a => bool): option<int> =>
    switch findIndex(array, finder) {
    | -1 => None
    | index => Some(index)
    }

  let swapUnsafe = (xs, i, j) => {
    let tmp = getUnsafe(xs, i)
    setUnsafe(xs, i, getUnsafe(xs, j))
    setUnsafe(xs, j, tmp)
  }

  let shuffle = xs => {
    let len = length(xs)
    for i in 0 to len - 1 {
      swapUnsafe(xs, i, Js.Math.random_int(i, len)) /* [i,len) */
    }
  }

  let toShuffled = xs => {
    let result = copy(xs)
    shuffle(result)
    result
  }

  let filterMapU = (a, f) => {
    let l = length(a)
    let r = makeUninitializedUnsafe(l)
    let j = ref(0)
    for i in 0 to l - 1 {
      let v = getUnsafe(a, i)
      switch f(. v) {
      | None => ()
      | Some(v) =>
        setUnsafe(r, j.contents, v)
        j.contents = j.contents + 1
      }
    }
    truncateToLengthUnsafe(r, j.contents)
    r
  }

  let filterMap = (a, f) => filterMapU(a, (. a) => f(a))

  let keepSome = filterMap(_, x => x)

  @send external flatMap: (array<'a>, 'a => array<'b>) => array<'b> = "flatMap"

  let findMap = (arr, f) => {
    let rec loop = i =>
      if i == arr->length {
        None
      } else {
        switch f(getUnsafe(arr, i)) {
        | None => loop(i + 1)
        | Some(_) as r => r
        }
      }

    loop(0)
  }

  @send external at: (array<'a>, int) => option<'a> = "at"

  let takeDropWhile = (arr, fn) => {
    let ind = findIndex(arr, e => !fn(e))
    if ind == -1 {
      (arr, [])
    } else {
      (slice(arr, ~start=0, ~end=ind), sliceToEnd(arr, ~start=ind))
    }
  }
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
module String = RescriptCore.String
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
  let update: (t<'t>, string, option<'t> => 't) => t<'t> = %raw(`
    (dict, key, fn) => ({...dict, [key]: fn(dict[key])})
  `)
}
module Option = {
  include RescriptCore.Option
  let ok_or = (opt, err): result<_, _> =>
    switch opt {
    | Some(v) => RescriptCore.Result.Ok(v)
    | None => RescriptCore.Result.Error(err)
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
}
module Result = {
  include RescriptCore.Result
  let traverse = (arr, fn): result<array<'b>, 'e> =>
    Array.reduce(arr, Ok([]), (res, ele) => 
      flatMap(res, arr => map(fn(ele), a => {
        Array.push(arr, a)
        arr
      }))
    )
}
module Either = {
  type t<'a, 'b> =
    | Left('a)
    | Right('b)
  let partition = (arr, fn) => {
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
  let compare = (a, b) => if a == b {
    equal
  } else if a < b {
    less
  } else {
    greater
  }
}
