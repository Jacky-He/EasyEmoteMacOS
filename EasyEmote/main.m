//
//  main.m
//  EasyEmoteObjective-C
//
//  Created by Jacky He on 2020-12-21.
//

#import <Cocoa/Cocoa.h>
#import <InputMethodKit/InputMethodKit.h>

const NSString* kConnectionName = @"EasyEmote_Connection";

IMKServer* server;
IMKCandidates* candidates = nil;

int main(int argc, char * argv[])
{
    NSLog(@"DEBUGMESSAGE: LOL1");
    
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    NSString* identifier = [[NSBundle mainBundle] bundleIdentifier];
    
    server = [[IMKServer alloc] initWithName:(NSString*)kConnectionName bundleIdentifier:identifier];
    candidates = [[IMKCandidates alloc] initWithServer:server panelType:kIMKSingleColumnScrollingCandidatePanel];
    
    NSLog(@"DEBUGMESSAGE: LOL2");
    
    [[NSApplication sharedApplication] run];
        
    [server release];
    [candidates release];
    [pool release];
    return 0;
}
