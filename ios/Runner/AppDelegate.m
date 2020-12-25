#import "AppDelegate.h"
#import "GeneratedPluginRegistrant.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    [GeneratedPluginRegistrant registerWithRegistry:self];

    FlutterViewController* controller =
      (FlutterViewController*) self.window.rootViewController;

    /// Chinese Chess Engine
    FlutterMethodChannel* engineChannel = [FlutterMethodChannel
       methodChannelWithName:@"cn.apppk.chessroad/engine"
       binaryMessenger:controller.binaryMessenger];

    __weak CChessEngine* weakEngine = engine;

    // 以下是从 MethodChannle 收到 Flutter 层的调用
    [engineChannel setMethodCallHandler:^(FlutterMethodCall* call, FlutterResult result) {

        if ([@"startup" isEqualToString:call.method]) {
                 // 调用引擎启动
            result(@([weakEngine startup: controller]));
        }
        else if ([@"send" isEqualToString:call.method]) {
             // 发送指令给引擎
          result(@([weakEngine send: call.arguments]));
        }
        else if ([@"read" isEqualToString:call.method]) {
              // 读取引擎响应
            result([weakEngine read]);
        }
        else if ([@"shutdown" isEqualToString:call.method]) {
            // 关闭引擎
            result(@([weakEngine shutdown]));
        }
        else if ([@"isReady" isEqualToString:call.method]) {
            // 查询引擎状态是否就绪
            result(@([weakEngine isReady]));
        }
        else if ([@"isThinking" isEqualToString:call.method]) {
            // 查询引擎状态是否在思考中
            result(@([weakEngine isThinking]));
        }
        else {
            result(FlutterMethodNotImplemented);
        }
    }];

    return [super application:application didFinishLaunchingWithOptions:launchOptions];
}


- (id)init {

    self = [super init];

    if (self) {
        engine = [[CChessEngine alloc] init];
    }

    return self;
}

@end
