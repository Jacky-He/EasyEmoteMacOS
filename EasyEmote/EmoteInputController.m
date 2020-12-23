#import "EmoteInputController.h"

@implementation EmoteInputController

-(BOOL)inputText:(NSString *)string client:(id)sender
{
    _currentClient = sender;
    //if contains whitespaces
    if ([string containsString:@":"])
    {
        _starting = !_starting;
        if (!_starting) return [self convert:string client:sender];
    }
    
    //convert to emoji if whitespace or end colon
    
    //if start colon, then just add the string to the original buffer
    if (_starting)
    {
        if ([string rangeOfCharacterFromSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].location != NSNotFound) return [self convert:string client:sender];
        [self originalBufferAppend:string client:sender];
        return YES;
    }
    [self updateCandidatesWindow];
    return NO;
}

-(void)activateServer:(id)sender
{
    _currentClient = sender;
}

-(void)commitComposition:(id)sender
{
    NSString* text = [self composedBuffer];
    if (text == nil || [text length] == 0) text = [self originalBuffer];
    [sender insertText:text replacementRange:NSMakeRange(NSNotFound, NSNotFound)];
    [self setComposedBuffer:@""];
    [self setOriginalBuffer:@""];
    _insertionIndex = 0;
    _starting = NO;
    [self updateCandidatesWindow];
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
    extern IMKCandidates* candidates;
    NSMutableString* original = [self originalBuffer];
    NSMutableString* composed = [self composedBuffer];
    
    if ([_curr_candidates count] > 0)
    {
        [self setComposedBuffer:[_curr_candidates[0] second]];
        [self commitComposition:sender];
    }
    else
    {
        [original appendString:trigger];
        [composed setString:original];
        [self commitComposition:sender];
    }
    return YES;
}

-(BOOL)didCommandBySelector:(SEL)aSelector client:(id)sender
{
    _currentClient = sender;
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
    [self convert:@"\n" client:sender];
}

-(void)deleteBackward:(id)sender
{
    NSMutableString* originalText = [self originalBuffer];
    if (_insertionIndex > 0 && _insertionIndex <= [originalText length])
    {
        _insertionIndex--;
        [originalText deleteCharactersInRange:NSMakeRange(_insertionIndex, 1)];
        [sender setMarkedText:originalText selectionRange:NSMakeRange(0, [originalText length]) replacementRange:NSMakeRange(NSNotFound, NSNotFound)];
    }
    if ([originalText length] == 0) _starting = NO;
    [self updateCandidatesWindow];
}

-(void)candidateSelectionChanged:(NSAttributedString *)candidateString
{
//    [_currentClient setMarkedText:[candidateString string] selectionRange:NSMakeRange(_insertionIndex, 0) replacementRange:NSMakeRange(NSNotFound, NSNotFound)];
//    _insertionIndex = [candidateString length];
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
    if (!_starting) [candidates hide];
    else
    {
        [candidates setPanelType:kIMKSingleColumnScrollingCandidatePanel];
        NSMutableDictionary* dict = [NSMutableDictionary dictionary];
        NSFont* font = [NSFont fontWithName:@"Chalkboard" size:15];
        [dict setValue:font forKey:@"NSFontAttributeName"];
//        [dict setValue:[NSNumber numberWithFloat:0.5] forKey:IMKCandidatesOpacityAttributeName];
        [candidates setAttributes:dict];
        //@assert that original buffer is not empty
        NSLog(@"DEBUGMESSAGE: MARK");
        [self update_curr_candidates];
        if ([_curr_candidates count] == 0)
        {
            NSString* text = [self originalBuffer];
            [_currentClient insertText:text replacementRange:NSMakeRange(NSNotFound, NSNotFound)];
            [self setComposedBuffer:@""];
            [self setOriginalBuffer:@""];
            _insertionIndex = 0;
            _starting = NO;
            [candidates hide];
        }
        else
        {
            NSArray* dict = [candidates attributeKeys];
            for (NSInteger i = 0; i < [dict count]; i++) NSLog(@"DEBUGMESSAGE: %@", dict[i]);

            [candidates updateCandidates];
            [candidates show:kIMKLocateCandidatesBelowHint];
        }
    }
}

-(void)update_curr_candidates
{
    extern Trie* dict;
    if (_curr_candidates != nil) [_curr_candidates release];
    _curr_candidates = [[dict get_most_relevant:[self originalBuffer]] retain];
}

-(NSArray*)candidates:(id)sender
{
    _currentClient = sender;
    NSMutableArray<NSString*>* array = [NSMutableArray array];
    for (NSInteger i = 0; i < [_curr_candidates count]; i++)
    {
        NSString* tmp = [[[_curr_candidates[i] second] stringByAppendingString:@" "] stringByAppendingString:[_curr_candidates[i] first]];
        [array addObject:tmp];
    }
    return array;
}

-(void)candidateSelected:(NSAttributedString *)candidateString
{
    NSString* tmp = [candidateString string];
    NSArray<NSString*>* line = [tmp componentsSeparatedByString:@":"];
    [self setComposedBuffer:line[0]];
    [self commitComposition:_currentClient];
}

-(void)dealloc
{
    [_originalBuffer release];
    [_composedBuffer release];
    [_curr_candidates release];
    [super dealloc];
}

@end
