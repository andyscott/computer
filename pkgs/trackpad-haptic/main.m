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

#import <AppKit/AppKit.h>

void printUsage() {
    printf("Usage: haptic -t [generic|alignment|levelChange]\n");
}

int main(int argc, char *argv[]) {
    if (argc != 3 || strcmp(argv[1], "-t") != 0) {
        printUsage();
        return 1;
    }

    NSString *typeArg = [NSString stringWithUTF8String:argv[2]];
    NSHapticFeedbackPattern pattern;

    if ([typeArg isEqualToString:@"generic"]) {
        pattern = NSHapticFeedbackPatternGeneric;
    } else if ([typeArg isEqualToString:@"alignment"]) {
        pattern = NSHapticFeedbackPatternAlignment;
    } else if ([typeArg isEqualToString:@"levelChange"]) {
        pattern = NSHapticFeedbackPatternLevelChange;
    } else {
        printUsage();
        return 1;
    }

    NSHapticFeedbackManager *manager = [NSHapticFeedbackManager defaultPerformer];
    [manager performFeedbackPattern:pattern performanceTime:NSHapticFeedbackPerformanceTimeNow];

    return 0;
}
