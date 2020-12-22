#import "EmoteInputController.h"

@implementation EmoteInputController

-(BOOL)inputText:(NSString *)string client:(id)sender
{
    //if contains whitespaces
    if ([string containsString:@":"])
    {
        _starting = !_starting;
        if (!_starting) return [self convert:string client:sender];
    }
    
    //convert to emoji if whitespace or end colon
    if ([string rangeOfCharacterFromSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].location != NSNotFound) return [self convert:string client:sender];
    
    //if start colon, then just add the string to the original buffer
    if (_starting)
    {
        [self originalBufferAppend:string client:sender];
        return YES;
    }
    return NO;
}

-(void)commitComposition:(id)sender
{
    NSString* text = [self composedBuffer];
    if (text == nil || [text length] == 0) text = [self originalBuffer];
    [sender insertText:text replacementRange:NSMakeRange(NSNotFound, NSNotFound)];
    [self setComposedBuffer:@""];
    [self setOriginalBuffer:@""];
    _insertionIndex = 0;
    _didConvert = NO;
}

-(NSMutableString*)composedBuffer
{
    if (_composedBuffer == nil) _composedBuffer = [[NSMutableString alloc] init];
    return _composedBuffer;
}

-(void)setComposedBuffer:(NSString *)string
{
    NSMutableString* buffer = [self composedBuffer];
    [buffer setString:string];
}

-(NSMutableString*)originalBuffer
{
    if (_originalBuffer == nil) _originalBuffer = [[NSMutableString alloc] init];
    return _originalBuffer;
}

-(void)originalBufferAppend:(NSString *)string client:(id)sender
{
    NSMutableString* buffer = [self originalBuffer];
    [buffer appendString: string];
    _insertionIndex++;
    [sender setMarkedText:buffer selectionRange:NSMakeRange(0, [buffer length]) replacementRange:NSMakeRange(NSNotFound, NSNotFound)];
    [self updateCandidatesWindow];
}

-(void)setOriginalBuffer:(NSString *)string
{
    NSMutableString* buffer = [self originalBuffer];
    [buffer setString:string];
}

//converts the things in the originalBuffer and commits it if possible
//ensures that both buffers end up empty and insertion index is at 0
-(BOOL)convert:(NSString*)trigger client:(id)sender
{
    _starting = NO;
    return YES;
}

-(BOOL)didCommandBySelector:(SEL)aSelector client:(id)sender
{
    if ([self respondsToSelector:aSelector])
    {
        NSString* bufferedText = [self originalBuffer];
        if (bufferedText && [bufferedText length] > 0)
        {
            if (aSelector == @selector(insertNewline:) || aSelector == @selector(deleteBackward:))
            {
                [self performSelector:aSelector withObject:sender];
                return YES;
            }
        }
    }
    return NO;
}

-(void)insertNewline:(id)sender
{
    [self commitComposition:sender];
}

-(void)deleteBackward:(id)sender
{
    NSMutableString* originalText = [self originalBuffer];
    NSString* convertedString;
    if (_insertionIndex > 0 && _insertionIndex <= [originalText length])
    {
        _insertionIndex--;
        [originalText deleteCharactersInRange:NSMakeRange(_insertionIndex, 1)];
        [sender setMarkedText:originalText selectionRange:NSMakeRange(0, [originalText length]) replacementRange:NSMakeRange(NSNotFound, NSNotFound)];
    }
}

-(void)candidateSelectionChanged:(NSAttributedString *)candidateString
{
    [_currentClient setMarkedText:[candidateString string] selectionRange:NSMakeRange(_insertionIndex, 0) replacementRange:NSMakeRange(NSNotFound, NSNotFound)];
    _insertionIndex = [candidateString length];
}

-(void)setValue:(id)value forTag:(long)tag client:(id)sender
{
    return;
}

-(void)updateCandidatesWindow
{
    extern IMKCandidates* candidates;
    if (!candidates)
    {
        NSLog(@"DEBUGMESSAGE: No Candidates?!");
        return;
    }
    NSLog(@"DEBUGMESSAGE: updateCandidates?");
    [candidates setPanelType:kIMKSingleRowSteppingCandidatePanel];
    [candidates updateCandidates];
    [candidates show:kIMKLocateCandidatesBelowHint];
}

-(NSArray*)candidates:(id)sender
{
    NSMutableArray* theCandidates = [NSMutableArray array];
    [theCandidates addObject:@"💃"];
    return theCandidates;
}

-(void)candidateSelected:(NSAttributedString *)candidateString
{
    [self setComposedBuffer:[candidateString string]];
    [self commitComposition:_currentClient];
}

-(void)dealloc
{
    [_originalBuffer release];
    [_composedBuffer release];
    [super dealloc];
}

@end
