# DHThreadSafeWrapper
Combines a value with a dispatch queue. The dispatch queue is used to handle concurrent read/write access.

## Examples
```swift
// A boolean value only accessed on an internal dispatch queue.
let someVar = ThreadSafe(false)

// Synchronously read
print("someVar: \(someVar.value)")

// Synchronously write
someVar.syncWrite { $0 = true } 

someVar.asyncRead { (value) in
    // Do some work that should be done together with reading the value...
}

someVar.asyncWrite { (value) in
    // Do some work that should be done together with writing the value...
    value = false
}

// Update the value after one second.
let workItem = someVar.writeAfter(after: 1.0) { (value) in
    // Do some work that should be done together with writing the value...
    value = false
}
// ...something has changed and we don't want to update it anymore.
workItem.cancel()

// Using one queue to synchronize read/write access over multiple instances.
let queue = DispatchQueue(label: "com.dominikhofer.myQueue", qos: .background, attributes: .concurrent)
let usingTheSameQueue1 = ThreadSafe(0, dispatchQueue: queue)
let usingTheSameQueue2 = ThreadSafe(0, dispatchQueue: queue)
usingTheSameQueue1.asyncWrite { $0 += 1 }
usingTheSameQueue2.asyncWrite { $0 += 1 }
// ...
```
