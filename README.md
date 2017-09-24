Bio
===

A reactive WebSocket demo.

Requirements
------------

* Cocoapods
* Xcode with Swift 3

Setup
-----

* `pod install`
* `open Bio.xcworkspace`

Usage
-----

* Tap a car to start it
* Tap again to stop it

Notes
-----

Since the WebSocket only supports stopping the last car started, the client automatically stops the last started car when a new one is started.
Without this constraint, it would be impossible to stop a car if we had started another car while it was still running.