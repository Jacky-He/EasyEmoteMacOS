#import <Cocoa/Cocoa.h>
#import <InputMethodKit/InputMethodKit.h>

const NSString* modeString = @"com.apple.inputmethod.emote";

@interface EmoteInputController : IMKInputController
{
    NSMutableString* _composedBuffer;
    NSMutableString* _originalBuffer;
    NSInteger _insertionIndex;
    BOOL _didConvert;
    BOOL _starting;
    id _currentClient;
}

-(NSMutableString*)composedBuffer;
-(void)setComposedBuffer:(NSString*)string;
-(NSMutableString*)originalBuffer;
-(void)originalBufferAppend:(NSString*)string client:(id)sender;
-(void)setOriginalBuffer:(NSString*)string;
-(BOOL)convert:(NSString*)trigger client:(id)sender;
-(void)updateCandidatesWindow;

@end
