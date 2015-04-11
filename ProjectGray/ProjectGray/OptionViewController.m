//
//  OptionViewController.m
//  ProjectGray
//
//  Created by Matthew Ku on 2015-04-10.
//  Copyright (c) 2015 Tim Wang. All rights reserved.
//

#import "OptionViewController.h"

@interface OptionViewController ()

@end

@implementation OptionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadStats];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) loadStats {
    //get the documents directory:
    NSArray *paths = NSSearchPathForDirectoriesInDomains
    (NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    //make a file name to write the data to using the documents directory:
    NSString *fileName = [NSString stringWithFormat:@"%@/optionFile.txt", documentsDirectory];
    NSString *content = [[NSString alloc] initWithContentsOfFile:fileName usedEncoding:nil error:nil];
    NSArray *dataSegments = [content componentsSeparatedByString:@"<data>"];
    if(dataSegments.count == 3) {
        self.soundVolume.value = ((NSString*)dataSegments[0]).intValue;
        self.musicVolume.value = ((NSString*)dataSegments[1]).intValue;
        if(((NSString*)dataSegments[1]).intValue > 0) {
            [self.skipSceneButton setTitle:@"On" forState:UIControlStateNormal];
        }else {
            [self.skipSceneButton setTitle:@"Off" forState:UIControlStateNormal];
        }
    }
    else {
        self.soundVolume.value = 100;
        self.musicVolume.value = 100;
        [self.skipSceneButton setTitle:@"Off" forState:UIControlStateNormal];
    }
}

- (IBAction)soundVolume:(id)sender {
    self.volumeSound = self.soundVolume.value;
    [self writeToTextFile];
}

- (IBAction)musicVolume:(id)sender {
    self.volumeMusic = self.musicVolume.value;
}

- (IBAction)skipSceneButton:(id)sender {
    
}


//Save Data Functions -----------------------------------------

-(BOOL)saveScores {
    //    NSString *pathName = @"/Users/a00795612/Desktop/8081 Project/comp8051_group1/ProjectGray/testSave";
    //    [[NSFileManager defaultManager] createFileAtPath:pathName contents:nil attributes:nil];
    //    NSString *str = @"testString";
    //    [str writeToFile:pathName atomically:YES encoding:NSUTF8StringEncoding error:nil];
    [self writeToTextFile];
    [self readTextFile];
    return false;
}

-(void) writeToTextFile{
    //get the documents directory:
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    //make a file name to write the data to using the documents directory:
    NSString *fileName = [NSString stringWithFormat:@"%@/optionsFile.txt", documentsDirectory];
    //Order: Sound, Music, SkipScene
    NSString *content = [NSString stringWithFormat:@"%i<data>%i<data>%i"
                         , self.volumeSound, self.volumeMusic, self.skipScene];
    //save content to the documents directory
    [content writeToFile:fileName atomically:NO encoding:NSStringEncodingConversionAllowLossy error:nil];
}

-(void) readTextFile{
    //get the documents directory:
    NSArray *paths = NSSearchPathForDirectoriesInDomains
    (NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    //make a file name to write the data to using the documents directory:
    NSString *fileName = [NSString stringWithFormat:@"%@/optionsFile.txt", documentsDirectory];
    NSString *content = [[NSString alloc] initWithContentsOfFile:fileName usedEncoding:nil error:nil];
    NSArray *dataSegments = [content componentsSeparatedByString:@"<data>"];
    //Hard coded
    if(dataSegments.count == 3) {
        self.volumeSound = ((NSString*)dataSegments[0]).intValue;
        self.volumeMusic = ((NSString*)dataSegments[1]).intValue;
        self.skipScene = ((NSString*)dataSegments[2]).intValue;
    } else {
        self.volumeSound = 0;
        self.volumeMusic = 0;
        self.skipScene = 0;
    }
    //printf("%s", [content UTF8String]);
    //use simple alert from my library (see previous post for details)
    //    [ASFunctions alert:content];
    //    [content release];
}

//writes empty file
-(void) resetFiles{
    //get the documents directory:
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    //make a file name to write the data to using the documents directory:
    NSString *fileName = [NSString stringWithFormat:@"%@/optionsFile.txt", documentsDirectory];
    //create content - four lines of text
    //NSString *content = @"1<data>2<data>3<data>4<data>5";  //Testing
    NSString *content = @"";
    //save content to the documents directory
    [content writeToFile:fileName atomically:NO encoding:NSStringEncodingConversionAllowLossy error:nil];
}

//End of Save Data Functions ---------------------------------------------------

@end
