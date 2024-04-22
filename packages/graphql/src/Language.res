type sourceLocation = {
  line: int,
  column: int
}

type source = {
  body: string,
  name: string,
  locationOffset: sourceLocation
}
