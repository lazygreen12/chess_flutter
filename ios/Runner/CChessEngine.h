//
//  CChessEngine.h
//  Runner
//
//  Created by 陈智鑫 on 2020/12/24.
//

#import <Foundation/Foundation.h>
#import <Flutter/Flutter.h>
#import "engine-state.h"

NS_ASSUME_NONNULL_BEGIN

@interface CChessEngine : NSObject {
    NSOperationQueue *operationQueue;
}

@property(nonatomic) State state;

-(int) startup: (FlutterViewController *) controller;

-(int) send: (NSString *) command;

-(NSString *) read;

-(int) shutdown;

-(BOOL) isReady;

-(BOOL) isThinking;

@end

NS_ASSUME_NONNULL_END
