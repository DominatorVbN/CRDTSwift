### ReplicatingTypes

ReplicatingTypes is a Swift package that implements Conflict-Free Replicated Data Types (CRDTs) in Swift. This package is based on the tutorial series on CRDTs at appdecentral.com, which covers various topics such as replicating register, replicating add-only set, replicating dictionary, and more.

**Note: This package is still a work in progress.**

### Installation

To use ReplicatingTypes in your Swift project, add the following line to your `Package.swift` file:

```Swift
dependencies: [
    .package(url: "https://github.com/dominatorvbn/CRDTSwift.git", branch: "main")
]
```

### Usage

To use ReplicatingTypes in your Swift code, import the module:

```swift
import CRDTSwift
```

Then, you can use the various replicating types provided by the package, such as `ReplicatingRegister`, `ReplicatingAddOnlySet`, `ReplicatingDictionary`, and more. For example:

```swift
var register = ReplicatingRegister<String>()
register.write("Hello, world!")
print(register.value)
```

### Testing

ReplicatingTypes includes unit tests for each replicating type. To run the tests, open the package in Xcode and select the "CRDTSwift-Package" scheme, then press Command-U.

### Done

#### Implemented 

- `LamportTimestamp`,
-  `ReplicatingAddOnlySet`, 
- `ReplicatingRegister`, 
- and `ReplicatingSet`.

#### Wrote tests for 

- `LamportTimestamp`,
-  `ReplicatingAddOnlySet`, 
- and `ReplicatingRegister`.

### To Do

- Write exhaustive tests for `ReplicatingSet`.
- Continue the journey to the next article, "Replicants All the Way Down."