# Bugless

Bugless is an open source iOS library for collecting app feedback and bug reports. Bugless aims to integrate with several different issue trackers that you can send your bug reports to. Since this is an open source project if you don't see your favorite issue tracker or service you can create your own custom integration and contribute it to the project. 

# Installation

## Swift Package Manager

You can add Bugless as a Swift Package dependency in Xcode 11+ by using the following steps:
* Click `File -> Swift Packages -> Add Package Dependency...`  
* Enter the bugless repo url `https://github.com/scriptprojects/bugless-ios.git`
* Choose the version or branch that you want to add

# Usage

You can initialize the library by passing your configuration object to the `Bugless.initialize(with: myConfigObject)` function

```Swift
import Bugless

Bugless.initialize(with: .init(
    trigger: .manual,
    sendMethods: [.webhook],
    webhookUrl: "https://yourwebhook.com/url"
  )
)
```

The configuration above will send any reports to the url provided in `webhookUrl`. You can also configure the library to use the native email client by using `.nativeEmailClient`. You can also use `emailRecipients` to prefill the to field of the mail client.
There are more configuration options which you can explore by looking at the `Configuration` class. Since this project will be evolving, these options can change in the future.

We will have a sample iOS app that will show different ways to use the library.

Happy bug hunting!!

# Contributing

You are welcome to help with this project if you like. Any help is appreciated.