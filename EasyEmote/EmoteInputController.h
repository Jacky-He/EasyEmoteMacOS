#import <Cocoa/Cocoa.h>
#import <InputMethodKit/InputMethodKit.h>
#import "Trie.h"
#import "Preferences.h"
#import "AppDelegate.h"

const NSString* modeString = @"com.apple.inputmethod.emote";

@interface EmoteInputController : IMKInputController
{
    NSMutableString* _composedBuffer;
    NSMutableString* _originalBuffer;
    NSInteger _insertionIndex;
    BOOL _doConvert;
    BOOL _starting;
    NSInteger _curr_index;
    NSInteger _curr_page;
    id _currentClient;
    NSMutableArray<Triplet*>* _curr_candidates;
    NSMutableArray<NSAttributedString*>* _candidate_strings;
}

-(id)get_curr_client;
-(NSMutableString*)composedBuffer;
-(void)setComposedBuffer:(NSString*)string;
-(NSMutableString*)originalBuffer;
-(void)originalBufferAppend:(NSString*)string client:(id)sender;
-(void)setOriginalBuffer:(NSString*)string;
-(BOOL)convert:(NSString*)trigger client:(id)sender;
-(void)updateCandidatesWindow;
-(void)update_curr_candidates;
-(void)handle_newline:(id)sender;
-(void)handle_backspace:(id)sender;
-(void)handle_space:(id)sender;
-(void)handle_number:(NSString*)trigger client:(id)sender;
-(NSInteger)get_page_with_index:(NSInteger)candidateIdentifier; // zero indexed
-(NSInteger)get_index:(id)candidateString; // zero indexed


@end
