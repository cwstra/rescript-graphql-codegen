let getOrPanic = (opt, str) =>
    switch opt {
      | Some(v) => v
      | None => panic(str)
    }
