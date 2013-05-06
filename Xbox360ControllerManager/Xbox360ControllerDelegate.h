//
//  Xbox360ControllerDelegate.h
//  Xbox360ControllerManager
//
//  Created by Derek van Vliet on 11-05-13.
//  Copyright 2011 Get Set Games. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol Xbox360ControllerDelegate <NSObject>
@optional

// A-button events
-(void)buttonAPressed;
-(void)buttonAReleased;

// B-button events
-(void)buttonBPressed;
-(void)buttonBReleased;

// X-button events
-(void)buttonXPressed;
-(void)buttonXReleased;

// Y-button events
-(void)buttonYPressed;
-(void)buttonYReleased;

// Left stick button events
-(void)buttonLeftStickPressed;
-(void)buttonLeftStickReleased;

// Right stick button events
-(void)buttonRightStickPressed;
-(void)buttonRightStickReleased;

// Left shoulder button events
-(void)buttonLeftShoulderPressed;
-(void)buttonLeftShoulderReleased;

// Right shoulder button events
-(void)buttonRightShoulderPressed;
-(void)buttonRightShoulderReleased;

// Left trigger events
-(void)triggerLeftPressed;
-(void)triggerLeftReleased;

// Right trigger events
-(void)triggerRightPressed;
-(void)triggerRightReleased;

// Digipad up button events
-(void)buttonUpPressed;
-(void)buttonUpReleased;

// Digipad down button events
-(void)buttonDownPressed;
-(void)buttonDownReleased;

// Digipad left button events
-(void)buttonLeftPressed;
-(void)buttonLeftReleased;

// Digipad right button events
-(void)buttonRightPressed;
-(void)buttonRightReleased;

// Back button events
-(void)buttonBackPressed;
-(void)buttonBackReleased;

// Home button events
-(void)buttonHomePressed;
-(void)buttonHomeReleased;

// Start button events
-(void)buttonStartPressed;
-(void)buttonStartReleased;

// Called after the controller has disconnected
-(void)controllerDisconnected;
@end
