import playtomic_macros
import Foundation


// MARK: - Freestanding expression
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


