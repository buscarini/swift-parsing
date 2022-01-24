import Parsing
import XCTest

class ManyTests: XCTestCase {
  func testNoSeparator() {
    var input = "         Hello world"[...].utf8
    XCTAssertNoThrow(
      try Many {
        " ".utf8
      }
      .parse(&input)
    )
    XCTAssertEqual(Substring(input), "Hello world")
  }

  func testSeparator() {
    var input = "1,2,3,4,5"[...].utf8

    XCTAssertEqual(
      try Many {
        Int.parser()
      } separator: {
        ",".utf8
      }
      .parse(&input),
      [1, 2, 3, 4, 5]
    )
    XCTAssertEqual(Substring(input), "")
  }

  func testTrailingSeparator() {
    var input = "1,2,3,4,5,"[...].utf8

    XCTAssertEqual(
      try Many {
        Int.parser()
      } separator: {
        ",".utf8
      }
      .parse(&input),
      [1, 2, 3, 4, 5]
    )
    XCTAssertEqual(Substring(input), ",")
  }

  func testMinimum() {
    var input = "1,2,3,4,5"[...].utf8

    XCTAssertThrowsError(
      try Many(atLeast: 6) {
        Int.parser()
      } separator: {
        ",".utf8
      }
      .parse(&input)
    )
    XCTAssertEqual(Substring(input), "1,2,3,4,5")

    XCTAssertEqual(
      try Many(atLeast: 5) {
        Int.parser()
      } separator: {
        ",".utf8
      }
      .parse(&input),
      [1, 2, 3, 4, 5]
    )
    XCTAssertEqual(Substring(input), "")
  }

  func testMaximum() {
    var input = "1,2,3,4,5"[...].utf8

    XCTAssertEqual(
      try Many(atMost: 3) {
        Int.parser()
      } separator: {
        ",".utf8
      }
      .parse(&input),
      [1, 2, 3]
    )
    XCTAssertEqual(Substring(input), ",4,5")
  }

  func testReduce() {
    var input = "1,2,3,4,5"[...].utf8

    XCTAssertEqual(
      try Many(into: 0, +=) {
        Int.parser()
      } separator: {
        ",".utf8
      }
      .parse(&input),
      15
    )
    XCTAssertEqual(Substring(input), "")
  }

  func testEmptyComponents() {
    var input = "2001:db8::2:1"[...]
    XCTAssertEqual(
      try Many {
        Prefix(while: \.isHexDigit)
      } separator: {
        ":"
      }
      .parse(&input),
      ["2001", "db8", "", "2", "1"]
    )
  }

  func testTerminator() throws {
    let user = Parse {
      Int.parser()
      ","
      Prefix { $0 != "," }
      ","
      Bool.parser()
    }

    let users = Many {
      user
    } separator: {
      "\n"
    } terminator: {
      End()
    }

    var input = """
      1,Blob,true
      2,Blob Sr,false
      3,Blob Jr,true
      """[...]
    try users.parse(&input)
  }
}
