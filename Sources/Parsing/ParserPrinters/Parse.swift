/// A parser that attempts to run a number of parsers to accumulate their outputs.
public struct Parse<Parsers>: Parser where Parsers: Parser {
  public let parsers: Parsers

  @inlinable
  public init(
    @ParserBuilder with build: () -> Parsers
  ) {
    self.parsers = build()
  }

  @inlinable
  public init<Upstream, NewOutput>(
    _ transform: @escaping (Upstream.Output) -> NewOutput,
    @ParserBuilder with build: () -> Upstream
  ) where Parsers == Parsing.Parsers.Map<Upstream, NewOutput> {
    self.parsers = build().map(transform)
  }

  @inlinable
  public init<Upstream, Downstream>(
    _ transform: Downstream,
    @ParserBuilder with build: () -> Upstream
  ) where Parsers == Parsing.Parsers.Pipe<Upstream, Downstream> {
    self.parsers = build().pipe(transform)
  }

  @inlinable
  public init<Upstream, NewOutput>(
    _ output: NewOutput,
    @ParserBuilder with build: () -> Upstream
  ) where Upstream.Output == Void, Parsers == Parsing.Parsers.Map<Upstream, NewOutput> {
    self.parsers = build().map { output }
  }

  @inlinable
  public func parse(_ input: inout Parsers.Input) -> Parsers.Output? {
    self.parsers.parse(&input)
  }
}

extension Parse: Printer where Parsers: Printer {
  @inlinable
  public func print(_ output: Parsers.Output) -> Parsers.Input? {
    self.parsers.print(output)
  }
}
