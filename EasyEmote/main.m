//
//  main.m
//  EasyEmoteObjective-C
//
//  Created by Jacky He on 2020-12-21.
//
#import <Cocoa/Cocoa.h>
#import <InputMethodKit/InputMethodKit.h>
#import "Trie.h"
//#import "DDFileReader.h"

const NSString* kConnectionName = @"EasyEmote_Connection";

IMKServer* server;
IMKCandidates* candidates = nil;
Trie* dict;

int main(int argc, char * argv[])
{
    NSLog(@"DEBUGMESSAGE: LOL1");
    
    @autoreleasepool {
        NSString* identifier = [[NSBundle mainBundle] bundleIdentifier];
        
        server = [[IMKServer alloc] initWithName:(NSString*)kConnectionName bundleIdentifier:identifier];
        candidates = [[IMKCandidates alloc] initWithServer:server panelType:kIMKSingleColumnScrollingCandidatePanel];
        
        //load emojis
        dict = [[Trie alloc]init];
        NSURL* url = [[NSBundle mainBundle] URLForResource:@"emojiStore" withExtension:@"txt"];
        @try
        {
            NSString* inputString = [[NSString alloc]initWithContentsOfURL: url encoding:NSUTF8StringEncoding error:nil];
            NSArray<NSString*>* lines = [inputString componentsSeparatedByString:@"\n"];
            for (NSInteger i = 0; i < [lines count]; i++)
            {
                NSString* str = lines[i];
                if (![str containsString:@":"]) continue;
                NSArray<NSString*>* parts = [str componentsSeparatedByString:@":"];
                NSString* codestr = [parts[0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                NSString* descr = [parts[1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                [dict insert:descr unicodestr:codestr];
            }
        }
        @catch (NSException* exception)
        {
            NSLog(@"DEBUGMESSAGE: Error getting contents of file");
        }
        
        NSLog(@"DEBUGMESSAGE: LOL2");
        
        [[NSApplication sharedApplication] run];
    }
    return 0;
}
