//
//  Xbox360Controller.h
//  Xbox360ControllerManager
//
//  Created by Derek van Vliet on 11-05-12.
//  Copyright 2011 Get Set Games. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DeviceItem.h"
#import <IOKit/IOKitLib.h>
#import <IOKit/IOCFPlugIn.h>
#import <IOKit/hid/IOHIDLib.h>
#import <IOKit/hid/IOHIDKeys.h>
#import <ForceFeedback/ForceFeedback.h>
#import "Xbox360ControllerDelegate.h"

@interface Xbox360Controller : NSObject {
    // Internal info
    mach_port_t masterPort;
	DeviceItem *deviceItem;
    IOHIDElementCookie axis[6],buttons[15];
    
    IOHIDDeviceInterface122 **device;
    IOHIDQueueInterface **hidQueue;
    FFDeviceObjectReference ffDevice;
    io_registry_entry_t registryEntry;
    
    int largeMotor,smallMotor;
    
    IONotificationPortRef notifyPort;
    CFRunLoopSourceRef notifySource;
    io_iterator_t onIteratorWired, offIteratorWired;
    io_iterator_t onIteratorWireless, offIteratorWireless;	
    
    io_object_t myHid;
	
    int leftStickX;
    int leftStickY;
    int rightStickX;
    int rightStickY;
    int leftTrigger;
    int rightTrigger;
    
    BOOL a,b,x,y;
    BOOL leftShoulder,rightShoulder;
    BOOL leftStick,rightStick;
    BOOL start,back,home;
    BOOL up,down,left,right;
    
    id<Xbox360ControllerDelegate> delegate;
    
    BOOL invertY;
    BOOL invertX;
}

@property (readonly) io_object_t myHid;
@property (readonly) int leftStickX; // -32768 to 32768
@property (readonly) int leftStickY;
@property (readonly) int rightStickX;
@property (readonly) int rightStickY;
@property (readonly) int leftTrigger; // 0 to 255
@property (readonly) int rightTrigger;
@property (readonly) BOOL a,b,x,y;
@property (readonly) BOOL leftShoulder,rightShoulder;
@property (readonly) BOOL leftStick,rightStick;
@property (readonly) BOOL start,back,home;
@property (readonly) BOOL up,down,left,right;
@property (readwrite,retain) id<Xbox360ControllerDelegate> delegate;
@property (readwrite,assign) BOOL invertX,invertY;
@property (readonly) DeviceItem* deviceItem;
@property (readonly) BOOL deviceIsAccessible;

-(id)initWithHidDevice:(io_object_t)hid;
-(void)eventQueueFired:(void*)sender withResult:(IOReturn)result;
-(void)buttonDelegateMethod:(SEL)downSel Released:(SEL)upSel State:(BOOL)state;
-(void)startDevice;
-(void)runMotorsLarge:(unsigned char)large Small:(unsigned char)small;
-(void)disconnect;
@end
