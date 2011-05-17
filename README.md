# Xbox 360 Controller Manager

Xbox 360 Controller Manager is an objective-c wrapper around Colin Munro's Xbox 360 controller driver for Mac OS X. The goal of this project is to make it easy for Mac application developers to use Xbox 360 controller input in their apps. It supports wired Xbox 360 controllers and wireless Xbox 360 controllers via the Microsoft Gaming Receiver.

## API

The API consists of:

* Xbox360ControllerManager: a singleton manager class which handles detection and setup of Xbox 360 Controllers instances
* Xbox360Controller: a class that can be used to poll for button and stick states from those instances and
* Xbox360ControllerDelegate: a protocol that delegates can use to receive button inputs

The following NSNotifications are posted:

* XBOX360CONTROLLERS_UPDATED: posted whenever a controller connects or disconnects

## Usage

To use Xbox 360 controller input in your Mac application, do the following:

1. Install the driver by running 360ControllerInstall.dmg.
2. Drag and drop the Xbox360ControllerManager folder into your project.
3. Include the following frameworks in your project:
	* IOKit.framework
	* ForceFeedback.framework
