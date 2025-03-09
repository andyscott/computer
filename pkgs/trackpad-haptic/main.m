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
