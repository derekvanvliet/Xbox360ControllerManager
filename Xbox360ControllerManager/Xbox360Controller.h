//
//  Xbox360Controller.h
//  Xbox360ControllerManager
//
//  Created by Derek van Vliet on 11-05-12.
//  Copyright 2011 Get Set Games. All rights reserved.
//


#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED)
#import <Foundation/Foundation.h>
#import <IOKit/IOKitLib.h>
#import <IOKit/IOCFPlugIn.h>
#import <IOKit/hid/IOHIDLib.h>
#import <IOKit/hid/IOHIDKeys.h>
#import <ForceFeedback/ForceFeedback.h>
#endif
#import "Xbox360ControllerDelegate.h"

@interface Xbox360Controller : NSObject {
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED)
    IOHIDElementCookie axis[6],buttons[15];    
    IOHIDDeviceInterface122 **device;
    IOHIDQueueInterface **hidQueue;
    FFDeviceObjectReference ffDevice;
    io_registry_entry_t registryEntry;
    IONotificationPortRef notifyPort;
    io_iterator_t onIteratorWired, offIteratorWired;
    io_iterator_t onIteratorWireless, offIteratorWireless;	    
    io_object_t myHid;
#endif
    
	mach_port_t masterPort;

    int largeMotor,smallMotor;
    
    CFRunLoopSourceRef notifySource;
	
    CGFloat leftStickX;
    CGFloat leftStickY;
    CGFloat rightStickX;
    CGFloat rightStickY;
    CGFloat leftTrigger;
    CGFloat rightTrigger;
    
    BOOL a,b,x,y;
    BOOL leftShoulder,rightShoulder;
    BOOL leftStick,rightStick;
    BOOL start,back,home;
    BOOL up,down,left,right;
	BOOL leftTriggerPressed;
	BOOL rightTriggerPressed;
    
    id<Xbox360ControllerDelegate> delegate;
    
    BOOL invertY;
    BOOL invertX;    
}

@property (readonly) CGFloat leftStickX; // -1.0 to 1.0
@property (readonly) CGFloat leftStickY;
@property (readonly) CGFloat rightStickX;
@property (readonly) CGFloat rightStickY;
@property (readonly) CGFloat leftTrigger; // 0 to 1.0
@property (readonly) CGFloat rightTrigger;
@property (readonly) BOOL a,b,x,y;
@property (readonly) BOOL leftShoulder,rightShoulder;
@property (readonly) BOOL leftStick,rightStick;
@property (readonly) BOOL start,back,home;
@property (readonly) BOOL up,down,left,right;
@property (readwrite,retain) id<Xbox360ControllerDelegate> delegate;
@property (readwrite,assign) BOOL invertX,invertY;
@property (readonly) BOOL deviceIsAccessible;

#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED)
@property (readonly) io_object_t myHid;
-(id)initWithHidDevice:(io_object_t)hid;
-(void)eventQueueFired:(void*)sender withResult:(IOReturn)result;
#endif

-(void)buttonDelegateMethod:(SEL)downSel Released:(SEL)upSel State:(BOOL)state;
-(void)stopDevice;
-(void)startDevice;
-(void)runMotorsLarge:(unsigned char)large Small:(unsigned char)small;
-(void)disconnect;

@end
