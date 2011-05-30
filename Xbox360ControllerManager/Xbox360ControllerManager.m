//
//  Xbox360ControllerManager.m
//  Xbox360ControllerManager
//
//  Created by Derek van Vliet on 11-05-12.
//  Copyright 2011 Get Set Games. All rights reserved.
//

#import "Xbox360ControllerManager.h"
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED)
#include <mach/mach.h>
#include <IOKit/usb/IOUSBLib.h>
#endif

// Handle callback for when our device is connected or disconnected. Both events are
// actually handled identically.
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED)
static void callbackHandleDevice(void *param,io_iterator_t iterator) {
    io_service_t object=0;
    BOOL update;
    
    update=FALSE;
    while((object=IOIteratorNext(iterator))!=0) {
        IOObjectRelease(object);
        update=TRUE;
    }
    if(update) [(Xbox360ControllerManager*)param updateControllers];
}
#endif

@implementation Xbox360ControllerManager

static Xbox360ControllerManager *sharedXbox360ControllerManager = nil;

+(Xbox360ControllerManager *) sharedInstance {
	return sharedXbox360ControllerManager;
}

+(void)initialize {
	if ( self == [Xbox360ControllerManager class] ) {
		if (!sharedXbox360ControllerManager) {
			sharedXbox360ControllerManager = [Xbox360ControllerManager new];
		}
	}
}

-(id)init {
	self = [super init];
	
	if (self) {
        controllers = [[NSMutableArray alloc] initWithCapacity:4];
        
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED)
        io_object_t object;
		
        // Get master port, for accessing I/O Kit
        IOMasterPort(MACH_PORT_NULL,&masterPort);
        // Set up notification of USB device addition/removal
        notifyPort=IONotificationPortCreate(masterPort);
        notifySource=IONotificationPortGetRunLoopSource(notifyPort);
        CFRunLoopAddSource(CFRunLoopGetCurrent(),notifySource,kCFRunLoopCommonModes);
		
        // Activate callbacks
        // Wired
        IOServiceAddMatchingNotification(notifyPort, kIOFirstMatchNotification, IOServiceMatching(kIOUSBDeviceClassName), callbackHandleDevice, self, &onIteratorWired);
        callbackHandleDevice(self, onIteratorWired);
        IOServiceAddMatchingNotification(notifyPort, kIOTerminatedNotification, IOServiceMatching(kIOUSBDeviceClassName), callbackHandleDevice, self, &offIteratorWired);
        while((object = IOIteratorNext(offIteratorWired)) != 0)
            IOObjectRelease(object);
        // Wireless
        IOServiceAddMatchingNotification(notifyPort, kIOFirstMatchNotification, IOServiceMatching("WirelessHIDDevice"), callbackHandleDevice, self, &onIteratorWireless);
        callbackHandleDevice(self, onIteratorWireless);
        IOServiceAddMatchingNotification(notifyPort, kIOTerminatedNotification, IOServiceMatching("WirelessHIDDevice"), callbackHandleDevice, self, &offIteratorWireless);
        while((object = IOIteratorNext(offIteratorWireless)) != 0)
            IOObjectRelease(object);
#endif
	}
	
	return self;
}

-(void)dealloc {
	[controllers release];
	
	[super dealloc];
}

#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED)
-(Xbox360Controller*)controllerWithHid:(io_object_t)hid {
    for (Xbox360Controller* controller in controllers) {
        if (controller.myHid == hid) {
            return controller;
        }
    }
    
    return nil;
}
#endif

-(int)controllerCount {
    return controllers.count;
}

-(Xbox360Controller*)getController:(int)index {
    return [controllers objectAtIndex:index];
}

// Update the device list from the I/O Kit
-(void)updateControllers {
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED)
    CFMutableDictionaryRef hidDictionary;
    IOReturn ioReturn;
    io_iterator_t iterator;
    io_object_t hidDevice;
    int count;
        
	NSMutableArray *newControllers = [[NSMutableArray alloc] initWithCapacity:4];
	
    // Add new items
    hidDictionary=IOServiceMatching(kIOHIDDeviceKey);
	
    ioReturn=IOServiceGetMatchingServices(masterPort,hidDictionary,&iterator);
    if((ioReturn!=kIOReturnSuccess)||(iterator==0)) {
        return;
    }
    count=0;
    while((hidDevice=IOIteratorNext(iterator))) {
        BOOL deviceWired = IOObjectConformsTo(hidDevice, "ControllerClass");
        BOOL deviceWireless = IOObjectConformsTo(hidDevice, "WirelessHIDDevice");

//		io_name_t className;
//		IOReturn ioReturnValue = kIOReturnSuccess;		
//		ioReturnValue = IOObjectGetClass(hidDevice, className);
//		NSLog(@"%s",className);
		
        if ((!deviceWired) && (!deviceWireless))
        {
            IOObjectRelease(hidDevice);
            continue;
        }
		
		Xbox360Controller *controller = [self controllerWithHid:hidDevice];
		if (controller) {
			if (controller.deviceIsAccessible) {
				[newControllers addObject:controller];
			}
		}
		else {
			controller = [[Xbox360Controller alloc] initWithHidDevice:hidDevice];
			if (controller) {
				[newControllers addObject:controller];
				[controller release];
			}
		}
		
    }
    IOObjectRelease(iterator);
    
    for (Xbox360Controller *controller in controllers) {
        if ([newControllers indexOfObject:controller] == NSNotFound) {
            [controller disconnect];
        }
    }
	[controllers release];
	controllers = newControllers;
	[[NSNotificationCenter defaultCenter] postNotificationName:XBOX360CONTROLLERS_UPDATED object:nil];
#endif
}

-(void)setAllDelegates:(id<Xbox360ControllerDelegate>)d {
    for (Xbox360Controller* c in controllers) {
        c.delegate = d;
    }
}
@end
