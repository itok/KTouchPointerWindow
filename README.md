KTouchPointerWindow
=====================================

![ktouchpointerwindow.gif](http://itok.jp/share/image/ktouchpointerwindow.gif)

## How to use

* Import KTouchPointerWindow
* Call KTouchPointerWindowInstall() or KTouchPointerWindowInstallWithOptions() in application:didFinishLaunchingWithOptions:
```objc
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    KTouchPointerWindowInstall();
    ...
}
```

## License

MIT license