import PlaytomicMacros
import Foundation


// MARK: - Freestanding expression

// "#URL" macro provides compile time checked URL construction. If the URL is
// malformed an error is emitted. Otherwise a non-optional URL is expanded.
print(#URL("https://playtomic.io/"))

let a = 17
let b = 25
let (result, code) = #stringify(a + b)

// MARK: - Freestanding declaration
#warning("This macro generates a message")

// MARK: - Attach peer
@addAsyncMacro
func sportsSelector(sports: [String], callback: @escaping (String) -> Void) -> Void {}
let sport = await sportsSelector(sports: ["Padel", "Tenis", "Pickleball"])

// MARK: - Attach member

/**
 `@Copyable` is a Swift syntax macro that generates a `copy` function for a class or struct,
 similar to the `copy` function in Android. This function allows you to create a copy of an instance
 with modified properties.
 */
@Copyable
struct ExampleViewState {
    let title: String
    let count: Int?
}

let x = ExampleViewState(title: "1", count: 2)

print(x)

print(x.copy(title: "2", count: .value(nil)))


@caseDetection
enum ProfileViewState {
    case loading
    case loaded(userName: String)
}
var state = ProfileViewState.loading
print("is the view state loading?: \(state.isLoading)")
state = ProfileViewState.loaded(userName: "Random name")
print("is the view state loaded?: \(state.isLoaded)")

// MARK: - Attach memberAttribute
@wrapStoredProperties(#"available(*, deprecated, message: "hands off my data")"#)
struct OldStorage {
  var x: Int
}

// MARK: - Attach accessor
struct User {
    @storedAccess(defaultValue: "")
    let userId: String
}

// MARK: - Attach conformance
@equatable
struct Match {
    let id: String
    let team: MatchTeam
}

@equatable
struct MatchTeam {
    let id: String
    let playerd: [String]
}


