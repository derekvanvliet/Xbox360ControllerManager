//
//  Xbox360Controller.m
//  Xbox360ControllerManager
//
//  Created by Derek van Vliet on 11-05-12.
//  Copyright 2011 Get Set Games. All rights reserved.
//

#import "Xbox360Controller.h"

#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED)
#include <mach/mach.h>
#include <IOKit/usb/IOUSBLib.h>

static void Xbox360ControllerCallback(void *target,IOReturn result,void *refCon,void *sender) {
    if(target!=NULL) [((Xbox360Controller*)target) eventQueueFired:sender withResult:result];
}
#endif

@implementation Xbox360Controller
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED)
@synthesize myHid;
#endif
@synthesize leftStickX;
@synthesize leftStickY;
@synthesize rightStickX;
@synthesize rightStickY;
@synthesize leftTrigger;
@synthesize rightTrigger;
@synthesize a,b,x,y;
@synthesize leftShoulder,rightShoulder;
@synthesize leftStick,rightStick;
@synthesize start,back,home;
@synthesize up,down,left,right;
@synthesize delegate;
@synthesize invertX,invertY;

#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED)
-(id)initWithHidDevice:(io_object_t)hid {
	self = [super init];

	if (self) {
        myHid = hid;
		
		// Get master port, for accessing I/O Kit
		IOMasterPort(MACH_PORT_NULL,&masterPort);
		// Set up notification of USB device addition/removal
		notifyPort=IONotificationPortCreate(masterPort);
		notifySource=IONotificationPortGetRunLoopSource(notifyPort);
		CFRunLoopAddSource(CFRunLoopGetCurrent(),notifySource,kCFRunLoopCommonModes);
		// Prepare other fields
		device=NULL;
		hidQueue=NULL;
		
        if (self) {
            IOReturn ret;
            IOCFPlugInInterface **plugInInterface;
            SInt32 score=0;
            
            ret=IOCreatePlugInInterfaceForService(myHid,kIOHIDDeviceUserClientTypeID,kIOCFPlugInInterfaceID,&plugInInterface,&score);
            if(ret!=kIOReturnSuccess) {
                IOObjectRelease(myHid);
                [self release];
                return nil;
            }
            else {
                ret=(*plugInInterface)->QueryInterface(plugInInterface,CFUUIDGetUUIDBytes(kIOHIDDeviceInterfaceID122),(LPVOID)&device);
                (*plugInInterface)->Release(plugInInterface);
                if(ret!=kIOReturnSuccess) {
                    IOObjectRelease(myHid);                
                    [self release];
                    return nil;
                }
                else {
                    ffDevice=0;
                    FFCreateDevice(myHid,&ffDevice);
                    registryEntry=myHid;                
                }
            }
        }
		
        [self startDevice];
	}
	
	return self;
}
#endif

-(void)dealloc {	
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED)
    int i;
    FFEFFESCAPE escape;
    unsigned char c;
	
    // Remove notification source
    IOObjectRelease(onIteratorWired);
    IOObjectRelease(onIteratorWireless);
    IOObjectRelease(offIteratorWired);
    IOObjectRelease(offIteratorWireless);
    CFRunLoopRemoveSource(CFRunLoopGetCurrent(),notifySource,kCFRunLoopCommonModes);
    CFRunLoopSourceInvalidate(notifySource);
    IONotificationPortDestroy(notifyPort);
    // Release device and info
    [self stopDevice];
	if (ffDevice != 0) {
        c = 0x06 + (i % 0x04);
        escape.dwSize = sizeof(escape);
        escape.dwCommand = 0x02;
        escape.cbInBuffer = sizeof(c);
        escape.lpvInBuffer = &c;
        escape.cbOutBuffer = 0;
        escape.lpvOutBuffer = NULL;
        FFDeviceEscape(ffDevice, &escape);
	}
    if(registryEntry!=0) IOObjectRelease(registryEntry);
    if(device!=NULL) (*device)->Release(device);
    if(ffDevice!=0) FFReleaseDevice(ffDevice);
    // Close master port
    mach_port_deallocate(mach_task_self(),masterPort);
#endif
	
    if (delegate)
        [delegate release];
	
    // Done
    [super dealloc];
}

// If the direct rumble control is enabled, this will set the motors
// to the desired speed.
-(void)runMotorsLarge:(unsigned char)large Small:(unsigned char)small {
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED)
    FFEFFESCAPE escape;
    char c[2];
    
    if(ffDevice==0) return;
    c[0]=large;
    c[1]=small;
    escape.dwSize=sizeof(escape);
    escape.dwCommand=0x01;
    escape.cbInBuffer=sizeof(c);
    escape.lpvInBuffer=c;
    escape.cbOutBuffer=0;
    escape.lpvOutBuffer=NULL;
    FFDeviceEscape(ffDevice,&escape);
#endif
}

// Enables and disables the rumble motor "override"
-(void)setMotorOverride:(BOOL)enable {
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED)
    FFEFFESCAPE escape;
    char c;
    
    if(ffDevice==0) return;
    // If true, the motors will no longer obey any Force Feedback Framework
    // effects, and the motors may be controlled directly. False and the
    // motors will perform effects but can not be directly controlled.
    c=enable?0x01:0x00;
    escape.dwSize=sizeof(escape);
    escape.dwCommand=0x00;
    escape.cbInBuffer=sizeof(c);
    escape.lpvInBuffer=&c;
    escape.cbOutBuffer=0;
    escape.lpvOutBuffer=NULL;
    FFDeviceEscape(ffDevice,&escape);
#endif
}

-(void)axisChanged:(int)index newValue:(int)value {
    switch(index) {
        case 0:
            leftStickX = value;
            break;
        case 1:
            leftStickY = value;
            break;
        case 2:
            rightStickX = value;
            break;
        case 3:
            rightStickY = value;
            break;
        case 4:
            leftTrigger = value;
            break;
        case 5:
            rightTrigger = value;
            break;
        default:
            break;
    }
}

-(void)buttonDelegateMethod:(SEL)downSel Released:(SEL)upSel State:(BOOL)state {
    if (delegate) {
        if (state) {
            if ([delegate respondsToSelector:downSel]) {
                [delegate performSelector:downSel];
            }            
        }
        else {
            if ([delegate respondsToSelector:upSel]) {
                [delegate performSelector:upSel];
            }                        
        }
    }
}

-(void)buttonChanged:(int)index newValue:(int)value {
    BOOL state;
    
    state=value!=0;
    switch(index) {
        case 0:
            a = state;
            [self buttonDelegateMethod:@selector(buttonAPressed) Released:@selector(buttonAReleased) State:state];
            break;
        case 1:
            b = state;
            [self buttonDelegateMethod:@selector(buttonBPressed) Released:@selector(buttonBReleased) State:state];
            break;
        case 2:
            x = state;
            [self buttonDelegateMethod:@selector(buttonXPressed) Released:@selector(buttonXReleased) State:state];
            break;
        case 3:
            y = state;
            [self buttonDelegateMethod:@selector(buttonYPressed) Released:@selector(buttonYReleased) State:state];
            break;
        case 4:
            leftShoulder = state;
            [self buttonDelegateMethod:@selector(buttonLeftShoulderPressed) Released:@selector(buttonLeftShoulderReleased) State:state];
            break;
        case 5:
            rightShoulder = state;
            [self buttonDelegateMethod:@selector(buttonRightShoulderPressed) Released:@selector(buttonRightShoulderReleased) State:state];
            break;
        case 6:
            leftStick = state;
            [self buttonDelegateMethod:@selector(buttonLeftStickPressed) Released:@selector(buttonLeftStickReleased) State:state];
            break;
        case 7:
            rightStick = state;
            [self buttonDelegateMethod:@selector(buttonRightStickPressed) Released:@selector(buttonRightStickReleased) State:state];
            break;
        case 8:
            start = state;
            [self buttonDelegateMethod:@selector(buttonStartPressed) Released:@selector(buttonStartReleased) State:state];
            break;
        case 9:
            back = state;
            [self buttonDelegateMethod:@selector(buttonBackPressed) Released:@selector(buttonBackReleased) State:state];
            break;
        case 10:
            home = state;
            [self buttonDelegateMethod:@selector(buttonHomePressed) Released:@selector(buttonHomeReleased) State:state];
            break;
        case 11:
            up = state;
            [self buttonDelegateMethod:@selector(buttonUpPressed) Released:@selector(buttonUpReleased) State:state];
            break;
        case 12:
            down = state;
            [self buttonDelegateMethod:@selector(buttonDownPressed) Released:@selector(buttonDownReleased) State:state];
            break;
        case 13:
            left = state;
            [self buttonDelegateMethod:@selector(buttonLeftPressed) Released:@selector(buttonLeftReleased) State:state];
            break;
        case 14:
            right = state;
            [self buttonDelegateMethod:@selector(buttonRightPressed) Released:@selector(buttonRightReleased) State:state];
            break;
        default:
            break;
    }
}

// Handle message from I/O Kit indicating something happened on the device
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED)
-(void)eventQueueFired:(void*)sender withResult:(IOReturn)result {
    AbsoluteTime zeroTime={0,0};
    IOHIDEventStruct event;
    BOOL found;
    int i;
    
    if(sender!=hidQueue) return;
    while(result==kIOReturnSuccess) {
        result=(*hidQueue)->getNextEvent(hidQueue,&event,zeroTime,0);
        if(result!=kIOReturnSuccess) continue;
        // Check axis
        for(i=0,found=FALSE;(i<6)&&(!found);i++) {
            if(event.elementCookie==axis[i]) {
                [self axisChanged:i newValue:event.value];
                found=TRUE;
            }
        }
        if(found) continue;
        // Check buttons
        for(i=0,found=FALSE;(i<15)&&(!found);i++) {
            if(event.elementCookie==buttons[i]) {
                [self buttonChanged:i newValue:event.value];
                found=TRUE;
            }
        }
        if(found) continue;
        // Cookie wasn't for us?
    }
}
#endif

// Start using a HID device
-(void)startDevice {
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED)
    int i,j;
    CFArrayRef elements;
    CFDictionaryRef element;
    CFTypeRef object;
    long number;
    IOHIDElementCookie cookie;
    long usage,usagePage;
    CFRunLoopSourceRef eventSource;
    IOReturn ret;
    
	i = 0;
    if((*device)->copyMatchingElements(device,NULL,&elements)!=kIOReturnSuccess) {
        NSLog(@"Can't get elements list");
        // Make note of failure?
        return;
    }
    for(i=0;i<CFArrayGetCount(elements);i++) {
        element=CFArrayGetValueAtIndex(elements,i);
        // Get cookie
        object=CFDictionaryGetValue(element,CFSTR(kIOHIDElementCookieKey));
        if((object==NULL)||(CFGetTypeID(object)!=CFNumberGetTypeID())) continue;
        if(!CFNumberGetValue((CFNumberRef)object,kCFNumberLongType,&number)) continue;
        cookie=(IOHIDElementCookie)number;
        // Get usage
        object=CFDictionaryGetValue(element,CFSTR(kIOHIDElementUsageKey));
        if((object==0)||(CFGetTypeID(object)!=CFNumberGetTypeID())) continue;
        if(!CFNumberGetValue((CFNumberRef)object,kCFNumberLongType,&number)) continue;
        usage=number;
        // Get usage page
        object=CFDictionaryGetValue(element,CFSTR(kIOHIDElementUsagePageKey));
        if((object==0)||(CFGetTypeID(object)!=CFNumberGetTypeID())) continue;
        if(!CFNumberGetValue((CFNumberRef)object,kCFNumberLongType,&number)) continue;
        usagePage=number;
        // Match up items
        switch(usagePage) {
            case 0x01:  // Generic Desktop
                j=0;
                switch(usage) {
                    case 0x35:  // Right trigger
                        j++;
                    case 0x32:  // Left trigger
                        j++;
                    case 0x34:  // Right stick Y
                        j++;
                    case 0x33:  // Right stick X
                        j++;
                    case 0x31:  // Left stick Y
                        j++;
                    case 0x30:  // Left stick X
                        axis[j]=cookie;
                        break;
                    default:
                        break;
                }
                break;
            case 0x09:  // Button
                if((usage>=1)&&(usage<=15)) {
                    // Button 1-11
                    buttons[usage-1]=cookie;
                }
                break;
            default:
                break;
        }
    }
    // Start queue
    if((*device)->open(device,0)!=kIOReturnSuccess) {
        NSLog(@"Can't open device");
        // Make note of failure?
        return;
    }
    hidQueue=(*device)->allocQueue(device);
    if(hidQueue==NULL) {
        NSLog(@"Unable to allocate queue");
        // Error?
        return;
    }
    ret=(*hidQueue)->create(hidQueue,0,32);
    if(ret!=kIOReturnSuccess) {
        NSLog(@"Unable to create the queue");
        // Error?
        return;
    }
    // Create event source
    ret=(*hidQueue)->createAsyncEventSource(hidQueue,&eventSource);
    if(ret!=kIOReturnSuccess) {
        NSLog(@"Unable to create async event source");
        // Error?
        return;
    }
    // Set callback
    ret=(*hidQueue)->setEventCallout(hidQueue,Xbox360ControllerCallback,self,NULL);
    if(ret!=kIOReturnSuccess) {
        NSLog(@"Unable to set event callback");
        // Error?
        return;
    }
    // Add to runloop
    CFRunLoopAddSource(CFRunLoopGetCurrent(),eventSource,kCFRunLoopCommonModes);
    // Add some elements
    for(i=0;i<6;i++)
        (*hidQueue)->addElement(hidQueue,axis[i],0);
    for(i=0;i<15;i++)
        (*hidQueue)->addElement(hidQueue,buttons[i],0);
    // Start
    ret=(*hidQueue)->start(hidQueue);
    if(ret!=kIOReturnSuccess) {
        NSLog(@"Unable to start queue - 0x%.8x",ret);
        // Error?
        return;
    }
    [self setMotorOverride:TRUE];
    [self runMotorsLarge:0 Small:0];
    largeMotor=0;
    smallMotor=0;
    // Battery level?
    {
        CFTypeRef prop;
        
        if (IOObjectConformsTo(registryEntry, "WirelessHIDDevice"))
        {
            prop = IORegistryEntryCreateCFProperty(registryEntry, CFSTR("BatteryLevel"), NULL, 0);
            if (prop != nil)
            {
                unsigned char level;
                
                if (CFNumberGetValue(prop, kCFNumberCharType, &level)) {
                    // level
                }
                CFRelease(prop);
            }
        }
    }
#endif
}

// Stop using the HID device
-(void)stopDevice {
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED)
    if(registryEntry==0) return;
    [self runMotorsLarge:0 Small:0];
    [self setMotorOverride:FALSE];
    if(hidQueue!=NULL) {
        CFRunLoopSourceRef eventSource;
        
        (*hidQueue)->stop(hidQueue);
        eventSource=(*hidQueue)->getAsyncEventSource(hidQueue);
        if((eventSource!=NULL)&&CFRunLoopContainsSource(CFRunLoopGetCurrent(),eventSource,kCFRunLoopCommonModes))
            CFRunLoopRemoveSource(CFRunLoopGetCurrent(),eventSource,kCFRunLoopCommonModes);
        (*hidQueue)->Release(hidQueue);
        hidQueue=NULL;
    }
    if(device!=NULL) {
        (*device)->close(device);
        device=NULL;
    }
    registryEntry=0;
#endif
}

-(int)leftStickX {
    return invertX ? -leftStickX : leftStickX;
}
-(int)leftStickY {
    return invertY ? -leftStickY : leftStickY;
    
}
-(int)rightStickX {
    return invertX ? -rightStickX : rightStickX;
}
-(int)rightStickY {
    return invertY ? -rightStickY : rightStickY;    
}
-(BOOL)deviceIsAccessible {
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
	return NO;
#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED)
    IOReturn ret;
    IOCFPlugInInterface **plugInInterface;
    SInt32 score=0;
    
    ret=IOCreatePlugInInterfaceForService(myHid,kIOHIDDeviceUserClientTypeID,kIOCFPlugInInterfaceID,&plugInInterface,&score);
    if(ret!=kIOReturnSuccess) {
        IOObjectRelease(myHid);
        return NO;
    }
	
	return YES;
#endif
}

-(void)disconnect {
    if (delegate) {
		if ([delegate respondsToSelector:@selector(controllerDisconnected)]) {
			[delegate performSelector:@selector(controllerDisconnected)];
		}            
	}
    
    [delegate release];
    delegate = nil;
}
@end
