/*
Copyright 2025 Andy Scott <andy.g.scott@gmail.com>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

#include <ApplicationServices/ApplicationServices.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

// Declare external function for window space information
extern CFArrayRef SLSCopySpacesForWindows(int connection, int selector, CFArrayRef window_list);

// Get the default connection for space management
extern int _CGSDefaultConnection(void);

// Function to check if a window is sticky based on its window ID
bool window_is_sticky(uint32_t wid)
{
    bool result = false;
    CFNumberRef window_id_ref = CFNumberCreate(NULL, kCFNumberSInt32Type, &wid);
    CFArrayRef window_list_ref = CFArrayCreate(NULL, (const void **)&window_id_ref, 1, &kCFTypeArrayCallBacks);
    CFArrayRef space_list_ref = SLSCopySpacesForWindows(_CGSDefaultConnection(), 0x7, window_list_ref);
    if (!space_list_ref) goto err;

    result = CFArrayGetCount(space_list_ref) > 1;
    CFRelease(space_list_ref);

err:
    CFRelease(window_list_ref);
    CFRelease(window_id_ref);
    return result;
}

// Get the screen dimensions
CGSize getScreenSize() {
    CGDirectDisplayID displayID = CGMainDisplayID();
    return CGDisplayBounds(displayID).size;
}

// Calculate distance between two points
double distance(CGPoint p1, CGPoint p2) {
    return sqrt(pow(p2.x - p1.x, 2) + pow(p2.y - p1.y, 2));
}

// Move the window to the corner farthest from the mouse cursor
void moveWindowToFarthestCorner(AXUIElementRef window, CGRect windowBounds, CGPoint mouseLocation) {
    CGSize screenSize = getScreenSize();

    // Define the four corners with a 50px margin
    CGPoint corners[4] = {
        {15, 50}, // Top-left
        {screenSize.width - windowBounds.size.width - 15, 50}, // Top-right
        {15, screenSize.height - windowBounds.size.height - 15}, // Bottom-left
        {screenSize.width - windowBounds.size.width - 15, screenSize.height - windowBounds.size.height - 15} // Bottom-right
    };

    // Find the corner farthest from the mouse
    double maxDistance = -1;
    CGPoint targetPosition = corners[0];
    for (int i = 0; i < 4; i++) {
        double dist = distance(mouseLocation, corners[i]);
        if (dist > maxDistance) {
            maxDistance = dist;
            targetPosition = corners[i];
        }
    }

    // Move the window to the chosen corner
    AXValueRef positionValue = AXValueCreate(kAXValueCGPointType, &targetPosition);
    AXUIElementSetAttributeValue(window, kAXPositionAttribute, positionValue);
    CFRelease(positionValue);
}

// Callback function that will be called when a mouse event occurs
CGEventRef mouseEventCallback(CGEventTapProxy proxy, CGEventType type, CGEventRef event, void *refcon) {
    if (type == kCGEventMouseMoved) {
        // Check if Ctrl key is pressed
        if (CGEventSourceFlagsState(kCGEventSourceStateHIDSystemState) & kCGEventFlagMaskControl) {
            return event; // Do nothing if Ctrl is held down
        }

        CGPoint mouseLocation = CGEventGetLocation(event);
        AXUIElementRef window = (AXUIElementRef)refcon;

        CFTypeRef positionValue;
        CFTypeRef sizeValue;
        CGPoint windowPosition;
        CGSize windowSize;

        // Get window position and size
        AXUIElementCopyAttributeValue(window, kAXPositionAttribute, &positionValue);
        AXUIElementCopyAttributeValue(window, kAXSizeAttribute, &sizeValue);
        AXValueGetValue(positionValue, kAXValueCGPointType, &windowPosition);
        AXValueGetValue(sizeValue, kAXValueCGSizeType, &windowSize);
        CFRelease(positionValue);
        CFRelease(sizeValue);

        CGRect windowBounds = {windowPosition, windowSize};

        // Check if mouse is within the window bounds
        if (mouseLocation.x >= windowBounds.origin.x &&
            mouseLocation.x <= windowBounds.origin.x + windowBounds.size.width &&
            mouseLocation.y >= windowBounds.origin.y &&
            mouseLocation.y <= windowBounds.origin.y + windowBounds.size.height) {
            return event; // Do nothing if the mouse is inside the window
        }

        CGFloat deltaX = 200;
        CGFloat deltaY = 100;

        // Check if mouse is within delta px of the window
        if (mouseLocation.x >= windowBounds.origin.x - deltaX &&
            mouseLocation.x <= windowBounds.origin.x + windowBounds.size.width + deltaX &&
            mouseLocation.y >= windowBounds.origin.y - deltaY &&
            mouseLocation.y <= windowBounds.origin.y + windowBounds.size.height + deltaY) {
            moveWindowToFarthestCorner(window, windowBounds, mouseLocation);
        }
    }
    return event;
}

AXUIElementRef findChromeStickyWindow() {
    // Get the list of windows on the screen
    CFArrayRef windowList = CGWindowListCopyWindowInfo(kCGWindowListOptionOnScreenOnly, kCGNullWindowID);
    AXUIElementRef chromeStickyWindow = NULL;

    for (CFIndex i = 0; i < CFArrayGetCount(windowList); i++) {
        CFDictionaryRef windowInfo = CFArrayGetValueAtIndex(windowList, i);
        CFStringRef ownerName = CFDictionaryGetValue(windowInfo, kCGWindowOwnerName);

        // Check if the window belongs to Google Chrome
        if (CFStringCompare(ownerName, CFSTR("Google Chrome"), 0) == kCFCompareEqualTo) {
            uint32_t windowID;
            CFNumberGetValue(CFDictionaryGetValue(windowInfo, kCGWindowNumber), kCFNumberIntType, &windowID);

            // Check if the window is sticky
            if (window_is_sticky(windowID)) {
                pid_t pid;
                CFNumberGetValue(CFDictionaryGetValue(windowInfo, kCGWindowOwnerPID), kCFNumberIntType, &pid);
                AXUIElementRef appRef = AXUIElementCreateApplication(pid);

                // Get the list of windows for the application
                CFArrayRef appWindows;
                AXUIElementCopyAttributeValue(appRef, kAXWindowsAttribute, (CFTypeRef *)&appWindows);
                if (appWindows && CFArrayGetCount(appWindows) > 0) {
                    chromeStickyWindow = (AXUIElementRef)CFArrayGetValueAtIndex(appWindows, 0);
                    CFRetain(chromeStickyWindow);
                    CFRelease(appWindows);
                    CFRelease(appRef);
                    break;
                }
                CFRelease(appWindows);
                CFRelease(appRef);
            }
        }
    }
    CFRelease(windowList);
    return chromeStickyWindow;
}

int main(void) {
    AXUIElementRef chromeWindow = findChromeStickyWindow();
    if (!chromeWindow) {
        fprintf(stderr, "No sticky Google Chrome window found.\n");
        return 1;
    }

    // Create an event tap to intercept mouse move events
    CGEventMask eventMask = CGEventMaskBit(kCGEventMouseMoved);
    CFMachPortRef eventTap = CGEventTapCreate(
        kCGSessionEventTap,
        kCGHeadInsertEventTap,
        kCGEventTapOptionDefault,
        eventMask,
        mouseEventCallback,
        chromeWindow
    );

    if (!eventTap) {
        fprintf(stderr, "Failed to create event tap.\n");
        CFRelease(chromeWindow);
        return 1;
    }

    CFRunLoopSourceRef runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0);
    CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, kCFRunLoopCommonModes);

    CGEventTapEnable(eventTap, true);

    printf("Listening for mouse movements near the sticky Chrome window. Hold Ctrl to prevent movement. Press Ctrl+C to exit.\n");
    CFRunLoopRun();

    // Cleanup
    CFRelease(runLoopSource);
    CFRelease(eventTap);
    CFRelease(chromeWindow);

    return 0;
}
