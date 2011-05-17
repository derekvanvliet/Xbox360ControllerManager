//
//  Xbox360ControllerManager.h
//  Xbox360ControllerManager
//
//  Created by Derek van Vliet on 11-05-12.
//  Copyright 2011 Get Set Games. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Xbox360Controller.h"

#define XBOX360CONTROLLERS_UPDATED @"Xbox360ControllerManager_ControllersUpdated"

@interface Xbox360ControllerManager : NSObject {
    mach_port_t masterPort;
    IONotificationPortRef notifyPort;
    CFRunLoopSourceRef notifySource;
    io_iterator_t onIteratorWired, offIteratorWired;
    io_iterator_t onIteratorWireless, offIteratorWireless;
    NSMutableArray *controllers;
}

@property (readonly) int controllerCount;

+(Xbox360ControllerManager*)sharedInstance;
-(Xbox360Controller*)controllerWithHid:(io_object_t)hid;
-(void)updateControllers;
-(Xbox360Controller*)getController:(int)index;
-(void)setAllDelegates:(id<Xbox360ControllerDelegate>)d;
@end
