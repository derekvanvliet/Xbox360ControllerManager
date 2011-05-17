//
//  Xbox360ControllerManager.m
//  Xbox360ControllerManager
//
//  Created by Derek van Vliet on 11-05-12.
//  Copyright 2011 Get Set Games. All rights reserved.
//

#import "Xbox360ControllerManager.h"

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
        [self updateControllers];
	}
	
	return self;
}

-(Xbox360Controller*)controllerWithHid:(io_object_t)hid {
    for (Xbox360Controller* controller in controllers) {
        if (controller.myHid == hid) {
            return controller;
        }
    }
    
    return nil;
}

-(int)controllerCount {
    return controllers.count;
}

-(Xbox360Controller*)getController:(int)index {
    return [controllers objectAtIndex:index];
}

// Update the device list from the I/O Kit
-(void)updateControllers
{
    CFMutableDictionaryRef hidDictionary;
    IOReturn ioReturn;
    io_iterator_t iterator;
    io_object_t hidDevice;
    int count;
    
    // Scrub old items
    [controllers removeAllObjects];
    
    // Add new items
    hidDictionary=IOServiceMatching(kIOHIDDeviceKey);
    mach_port_t masterPort;
    IOMasterPort(MACH_PORT_NULL,&masterPort);

    ioReturn=IOServiceGetMatchingServices(masterPort,hidDictionary,&iterator);
    if((ioReturn!=kIOReturnSuccess)||(iterator==0)) {
        return;
    }
    count=0;
    while((hidDevice=IOIteratorNext(iterator))) {
        BOOL deviceWired = IOObjectConformsTo(hidDevice, "ControllerClass");
        BOOL deviceWireless = IOObjectConformsTo(hidDevice, "WirelessHIDDevice");
		
		//
		io_name_t               className;
		IOReturn                ioReturnValue = kIOReturnSuccess;		
		ioReturnValue = IOObjectGetClass(hidDevice, className);
		NSLog(@"%s",className);
		//
		
        if ((!deviceWired) && (!deviceWireless))
        {
            IOObjectRelease(hidDevice);
            continue;
        }
        if ([self controllerWithHid:hidDevice]) {
            continue;
        }
        [controllers addObject:[[Xbox360Controller alloc] initWithHidDevice:hidDevice Index:controllers.count]];
    }
    IOObjectRelease(iterator);
}

-(void)setAllDelegates:(id<Xbox360ControllerDelegate>)d {
    for (Xbox360Controller* c in controllers) {
        c.delegate = d;
    }
}
@end
