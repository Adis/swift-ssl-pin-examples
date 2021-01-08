# SSL pinning in Swift

Code examples for SSL pinning in iOS with and without Alamofire.

More info in the blog article here: https://infinum.co/the-capsized-eight/266

## Method 1 - Using Alamofire

```
DetailViewController+Alamofire.swift
```

This example demonstrates how to use the most basic pinning methods available in Alamofire, almost always, this will be enough for your use-case.

## Method 2 - Using a custom policy manager with Alamofire

```
DetailViewController+CustomPolicyManager.swift
```

This method demonstrates a more fine grained pinning, as well as restoring the behavior what AFNetworking used to do - denying connections for any domains that have not been pinned.

## Method 3 - URLSessionDelegate

```
DetailViewController+URLSessionDelegate.swift
```

This is the manual method, not using Alamofire. Some of the code has been borrowed from Alamofire, but will work without the library if your networking is just based on `URLSession`.

## Contributing

Found an issue? Open up an issue here on Github :)

# License

MIT License

Copyright (c) 2019 Adis M.

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
