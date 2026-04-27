/*
Copyright 2026 Andy Scott <andy.g.scott@gmail.com>

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

#import <AppKit/AppKit.h>
#import <Foundation/Foundation.h>

static NSString *const SpotifyBundleID = @"com.spotify.client";
static NSString *const SafariBundleID = @"com.apple.Safari";

typedef NS_ENUM(NSInteger, MediaCommand) {
  MediaCommandPlayPause,
  MediaCommandNext,
  MediaCommandPrevious,
};

static void printUsage(void) {
  fprintf(stderr, "Usage: media-key-router [play-pause|next|previous]\n");
}

static BOOL parseCommand(const char *arg, MediaCommand *command) {
  if (strcmp(arg, "play-pause") == 0) {
    *command = MediaCommandPlayPause;
    return YES;
  }

  if (strcmp(arg, "next") == 0) {
    *command = MediaCommandNext;
    return YES;
  }

  if (strcmp(arg, "previous") == 0) {
    *command = MediaCommandPrevious;
    return YES;
  }

  return NO;
}

static BOOL isAppRunning(NSString *bundleIdentifier) {
  NSArray<NSRunningApplication *> *apps = [NSRunningApplication
      runningApplicationsWithBundleIdentifier:bundleIdentifier];
  return [apps count] > 0;
}

static BOOL isFrontmostApp(NSString *bundleIdentifier) {
  NSRunningApplication *frontmost =
      [[NSWorkspace sharedWorkspace] frontmostApplication];
  return [[frontmost bundleIdentifier] isEqualToString:bundleIdentifier];
}

static NSString *spotifyAppleScript(MediaCommand command) {
  switch (command) {
  case MediaCommandPlayPause:
    return @"tell application id \"com.spotify.client\" to playpause";
  case MediaCommandNext:
    return @"tell application id \"com.spotify.client\" to next track";
  case MediaCommandPrevious:
    return @"tell application id \"com.spotify.client\" to previous track";
  }
}

static BOOL runAppleScript(NSString *source) {
  NSDictionary *errorInfo = nil;
  NSAppleScript *script = [[NSAppleScript alloc] initWithSource:source];
  [script executeAndReturnError:&errorInfo];

  if (errorInfo != nil) {
    NSString *message =
        errorInfo[NSAppleScriptErrorMessage] ?: @"unknown AppleScript error";
    fprintf(stderr, "media-key-router: %s\n", [message UTF8String]);
    return NO;
  }

  return YES;
}

int main(int argc, char *argv[]) {
  @autoreleasepool {
    if (argc != 2) {
      printUsage();
      return 1;
    }

    MediaCommand command;
    if (!parseCommand(argv[1], &command)) {
      printUsage();
      return 1;
    }

    // Focused Safari is handled by an skhd passthrough binding. Keep this
    // guard so direct/manual invocations preserve the same policy.
    if (isFrontmostApp(SafariBundleID)) {
      return 0;
    }

    // Never ask Spotify to do anything unless it is already running; otherwise
    // Apple Events may launch it, which is the exact behavior this tool avoids.
    if (isAppRunning(SpotifyBundleID)) {
      return runAppleScript(spotifyAppleScript(command)) ? 0 : 2;
    }

    return 0;
  }
}
