# Playtomic iOS Macros

By the moment this is a POC of the swift macros to be tested on the playtomic-iOS project.

Link to iOS project: [Playtomic iOS Project](https://github.com/syltek/playtomic-ios)  
Here you can find a notion document related with this project: [WIP Macros](https://www.notion.so/playtomicio/WIP-Macros-de6f8d16c7244f21a4331d76930406e7?pvs=4)

### List Of Macros in this project

#### 1. `stringify` Macro

A macro that produces both a value and a string containing the source code that generated the value. For example,

```swift
#stringify(x + y)

// produces a tuple (x + y, "x + y"). 
```

#### 2. `URL` Macro

Creates a non-optional URL from a static string. The string is checked to be valid during compile time.

```swift
#URL("https://playtomic.io")

// produces a URL(string: "https://playtomic.io")!
```

#### 3. warning Macro

Displays compile time warning

```swift
#warning("This macro generates a message")

// produces a warning at compile time with following message: "This macro generates a message"
```

#### 4. `addAsyncMacro` Macro

Converts callbacks to async code


```swift

@addAsyncMacro
func sportsSelector(sports: [String], callback: @escaping (String) -> Void) -> Void {
    callback(sports.joined(separator: ", "))
}

// Generates:

func sportsSelector(sports: [String]) async -> String {
  await withCheckedContinuation { continuation in
    sportsSelector(sports: sports) { returnValue in
        continuation.resume(returning: returnValue)
    }
  }
}
```

#### 5. `Copyable` Macro

@Copyable is a Swift syntax macro that generates a copy function for a class or struct, similar to the copy function in Android. This function allows you to create a copy of an instance with modified properties.

```swift
@Copyable
struct ExampleViewState {
    let title: String
    let count: Int?
}

// Generates: 

struct ExampleViewState {
    let title: String
    let count: Int?

    func copy(
        title: String? = nil,
        count: Nullable<Int> = .none
    ) -> ExampleViewState {
        return ExampleViewState(
            title: title ?? self.title,
            count: count ?? self.count
        )
    }
}
```

#### 6. `AddInit` Macro

Adds initializer to the type, very useful for classes that doesnt implement init by themselve.

```swift
@AddInit
class Object: CustomStringConvertible {
    let id: Int
    private let name: String

    var description: String {
        "id: \(id), name: \(name)"
    }
}

// Generates: 

class Object: CustomStringConvertible {
    let id: Int
    private let name: String

    var description: String {
        "id: \(id), name: \(name)"
    }
    
    init(id: Int, name: String) {
        self.id = id
        self.name = name
    }
}
```

#### 7. `caseDetection` Macro

Implements boolean computed properties per each enum case to provide case detection.

```swift
@caseDetection
enum ProfileViewState {
    case loading
    case loaded(userName: String)
}

// Generates:

enum ProfileViewState {
    case loading
    case loaded(userName: String)
    
    var isLoading: Bool {
        if case .loading = self {
            return true
        }
        return false
    }

    var isLoaded: Bool {
        if case .loaded = self {
            return true
        }
        return false
    }
}
```


#### 8. `wrapStoredProperties` Macro

Apply the specified attribute to each of the stored properties within the type or member to which the macro is attached. The string can be any attribute (without the @).

```swift
@wrapStoredProperties(#"available(*, deprecated, message: "hands off my data")"#)
struct OldStorage {
  var x: Int
}

// Generates:

struct OldStorage {
    @available(*, deprecated, message: "hands off my data")
    var x: Int
}
```

#### 9. `storedAccess` Macro

Implements `UserDefaults.standard` setter and getter methods over each property attached with `@storedAccess`.

```swift
struct User {
    @storedAccess(defaultValue: "")
    var userId: String
}

// Generates:

struct User {
    var userId: String {
        get {
            if UserDefaults.standard.value(forKey: "userId") == nil {
                return ""
            }
            return UserDefaults.standard.string(forKey: "userId") ?? ""
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "userId")
        }
    }
}
```

#### 10. `equatable` Macro

Creates an extension that conforms to Equatable protocol.

```swift
@equatable
struct MatchTeam {
    let id: String
    let playerd: [String]
}

// Generates:

struct MatchTeam {
    let id: String
    let playerd: [String]
}

extension MatchTeam: Equatable { } 
```

#### 11. `Sealed` Macro

Generates sealed class boiler plate from attached type

```swift

protocol ViewAction { }

@Sealed
public class LevelUpgradeViewAction: ViewAction {
    private init() {}

    public protocol NavigationAction {
        var navigationActionType: NavigationActionSealedType { get }
    }

    public protocol EventAction {
        var eventActionType: EventActionSealedType { get }
    }

    public protocol ObserverAction {
        var observerActionType: ObserverActionSealedType { get }
    }

    @AddInit
    public class OnAppear: LevelUpgradeViewAction, EventAction, ObserverAction { }

    @AddInit
    public class Upgrade: LevelUpgradeViewAction { }

    @AddInit
    public class OnUpgradeStarted: LevelUpgradeViewAction, EventAction {
        let from: Decimal
        let to: Decimal
    }

    @AddInit
    public class OnUpgradeSuccess: LevelUpgradeViewAction, NavigationAction {
        let from: Decimal
        let to: Decimal
    }

    @AddInit
    public class OnUpgradeError: LevelUpgradeViewAction, NavigationAction {
        let error: String
    }

    @AddInit
    public class OnUpgradeSkipped: LevelUpgradeViewAction, NavigationAction, EventAction { }
}

// Generates:

public extension LevelUpgradeViewAction {
    enum SealedType {
        case OnAppear
        case Upgrade
        case OnUpgradeStarted(LevelUpgradeViewAction.OnUpgradeStarted)
        case OnUpgradeSuccess(LevelUpgradeViewAction.OnUpgradeSuccess)
        case OnUpgradeError(LevelUpgradeViewAction.OnUpgradeError)
        case OnUpgradeSkipped
    }

    enum EventActionSealedType {
        case OnAppear
        case OnUpgradeStarted(LevelUpgradeViewAction.OnUpgradeStarted)
        case OnUpgradeSkipped
    }

    enum ObserverActionSealedType {
        case OnAppear
    }

    enum NavigationActionSealedType {
        case OnUpgradeSuccess(LevelUpgradeViewAction.OnUpgradeSuccess)
        case OnUpgradeError(LevelUpgradeViewAction.OnUpgradeError)
        case OnUpgradeSkipped
    }

}

public extension LevelUpgradeViewAction {
    var type: LevelUpgradeViewAction.SealedType {
        switch self {
        case is LevelUpgradeViewAction.OnAppear:
            LevelUpgradeViewAction.SealedType.OnAppear
        case is LevelUpgradeViewAction.Upgrade:
            LevelUpgradeViewAction.SealedType.Upgrade
        case is LevelUpgradeViewAction.OnUpgradeStarted:
            LevelUpgradeViewAction.SealedType.OnUpgradeStarted(self as! LevelUpgradeViewAction.OnUpgradeStarted)
        case is LevelUpgradeViewAction.OnUpgradeSuccess:
            LevelUpgradeViewAction.SealedType.OnUpgradeSuccess(self as! LevelUpgradeViewAction.OnUpgradeSuccess)
        case is LevelUpgradeViewAction.OnUpgradeError:
            LevelUpgradeViewAction.SealedType.OnUpgradeError(self as! LevelUpgradeViewAction.OnUpgradeError)
        case is LevelUpgradeViewAction.OnUpgradeSkipped:
            LevelUpgradeViewAction.SealedType.OnUpgradeSkipped
        default:
            fatalError("Unknown type \(self) in LevelUpgradeViewAction.SealedType")
        }
    }
}

public extension LevelUpgradeViewAction.EventAction {
    var eventActionType: LevelUpgradeViewAction.EventActionSealedType {
        switch self {
        case is LevelUpgradeViewAction.OnAppear:
            LevelUpgradeViewAction.EventActionSealedType.OnAppear
        case is LevelUpgradeViewAction.OnUpgradeStarted:
            LevelUpgradeViewAction.EventActionSealedType.OnUpgradeStarted(self as! LevelUpgradeViewAction.OnUpgradeStarted)
        case is LevelUpgradeViewAction.OnUpgradeSkipped:
            LevelUpgradeViewAction.EventActionSealedType.OnUpgradeSkipped
        default:
            fatalError("Unknown type \(self) in LevelUpgradeViewAction.EventActionSealedType")
        }
    }
}

public extension LevelUpgradeViewAction.ObserverAction {
    var observerActionType: LevelUpgradeViewAction.ObserverActionSealedType {
        switch self {
        case is LevelUpgradeViewAction.OnAppear:
            LevelUpgradeViewAction.ObserverActionSealedType.OnAppear
        default:
            fatalError("Unknown type \(self) in LevelUpgradeViewAction.ObserverActionSealedType")
        }
    }
}

public extension LevelUpgradeViewAction.NavigationAction {
    var navigationActionType: LevelUpgradeViewAction.NavigationActionSealedType {
        switch self {
        case is LevelUpgradeViewAction.OnUpgradeSuccess:
            LevelUpgradeViewAction.NavigationActionSealedType.OnUpgradeSuccess(self as! LevelUpgradeViewAction.OnUpgradeSuccess)
        case is LevelUpgradeViewAction.OnUpgradeError:
            LevelUpgradeViewAction.NavigationActionSealedType.OnUpgradeError(self as! LevelUpgradeViewAction.OnUpgradeError)
        case is LevelUpgradeViewAction.OnUpgradeSkipped:
            LevelUpgradeViewAction.NavigationActionSealedType.OnUpgradeSkipped
        default:
            fatalError("Unknown type \(self) in LevelUpgradeViewAction.NavigationActionSealedType")
        }
    }
}

```
