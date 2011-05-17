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
-(void)buttonAPressed;
-(void)buttonAReleased;

-(void)buttonBPressed;
-(void)buttonBReleased;

-(void)buttonXPressed;
-(void)buttonXReleased;

-(void)buttonYPressed;
-(void)buttonYReleased;

-(void)buttonLeftStickPressed;
-(void)buttonLeftStickReleased;

-(void)buttonRightStickPressed;
-(void)buttonRightStickReleased;

-(void)buttonLeftShoulderPressed;
-(void)buttonLeftShoulderReleased;

-(void)buttonRightShoulderPressed;
-(void)buttonRightShoulderReleased;

-(void)buttonUpPressed;
-(void)buttonUpReleased;

-(void)buttonDownPressed;
-(void)buttonDownReleased;

-(void)buttonLeftPressed;
-(void)buttonLeftReleased;

-(void)buttonRightPressed;
-(void)buttonRightReleased;

-(void)buttonBackPressed;
-(void)buttonBackReleased;

-(void)buttonHomePressed;
-(void)buttonHomeReleased;

-(void)buttonStartPressed;
-(void)buttonStartReleased;
@end
