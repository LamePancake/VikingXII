//
//  TestViewController.m
//  ProjectGray
//
//  Created by Shane Spoor on 2015-04-13.
//  Copyright (c) 2015 Tim Wang. All rights reserved.
//

@import QuartzCore;
#import "LoreViewController.h"

const float SCROLL_PER_SECOND = 0.5;

const float TIME_BETWEEN_CHARS = 0.07f;

char loreText[] = "The year is 2343.\n\n"
                  "For over 1300 years, the Vikings have worked in secrecy to perfect their longships."
                  "Frustrated that historians refused at first to believe that they reached the"
                  "Americas before anyone else, they are about to embark on the first ever manned mission beyond"
                  "the solar system to prove once and for all that they are the best explorers.\n\n"
                  "What they don’t know is that the space just beyond the solar system teems with an alien race"
                  "known as the Grayliens. Furious that their heads are too big to wear the Vikings’ awesome hats, "
                  "they have sworn to blast these stylish interlopers back to the 800s.\n\n"
                  "Welcome to Viking XII.";

@interface LoreViewController()
{
    CFTimeInterval _lastCharTime;
    int charIndex;
}
@end

@implementation LoreViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Create the animation controller thing
    CADisplayLink* tempLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateAnimations:)];
    [tempLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:[NSRunLoop mainRunLoop].currentMode];
    _lastCharTime = 0;
}

- (void)updateAnimations: (CADisplayLink*)link
{
    if((link.timestamp - _lastCharTime) > TIME_BETWEEN_CHARS && charIndex != strlen(loreText))
    {
        _textView.selectable = YES;
        _lastCharTime = link.timestamp;
        
        // Save the character after the current character and then replace it null to only copy up to that point
        char characterAfter = loreText[charIndex + 1];
        loreText[charIndex + 1] = 0;
        
        // Make a string with the current string
        NSString* string = [NSString stringWithUTF8String:loreText];
        _textView.text = string;
        
        // and then put the character back
        loreText[++charIndex] = characterAfter;
        _textView.selectable = NO;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
