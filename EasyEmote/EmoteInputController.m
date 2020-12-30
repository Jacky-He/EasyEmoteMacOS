#import "EmoteInputController.h"

@implementation EmoteInputController


-(BOOL)handleEvent:(NSEvent *)event client:(id)sender
{
    CandidateWindow* candidates = [self get_candidate_window];
    _currentClient = sender;
    if ([event type] == keyUp) return false;
    unsigned short keycode = [event keyCode];
    NSString* s = [event characters];
    NSLog(@"DEBUGMESSAGE: %@, %d", s, keycode);
    if ([s containsString:@":"])
    {
        _starting = !_starting;
        _doConvert = YES;
        if (!_starting) return [self convert:s client:sender];
    }
    if (!_starting) return false;
    if (keycode == 36 || keycode == 76) [candidates handleEvent:event];
    else if (keycode == 51) [self handle_backspace:sender];
    else if (keycode == 49) [self handle_space:sender];
    else if (123 <= keycode && keycode <= 126) [candidates handleEvent:event]; //arrow keys
    else if (!s) [candidates handleEvent:event];
    else if ([s intValue] == 0) [self originalBufferAppend:s client:sender];
    else [candidates handleEvent:event];
    //        [self handle_number:s client:sender];
    return true;
}

-(CandidateWindow*)get_candidate_window
{
    AppDelegate* delegate = [[NSApplication sharedApplication] delegate];
    return [delegate get_window];
}

-(void)activateServer:(id)sender
{
    _currentClient = sender;
    extern Preferences* preferences;
    CandidateWindow* candidates = [self get_candidate_window];
    [candidates setInputController:self];
//    [preferences train_model];
}

-(void)deactivateServer:(id)sender
{
    CandidateWindow* candidates = [self get_candidate_window];
    [candidates hide];
}

-(void)commitComposition:(id)sender
{
    NSString* text = [self composedBuffer];
    if (text == nil || [text length] == 0) text = [self originalBuffer];
    NSLog(@"DEBUGMESSAGE: COMPOSEDBUFFER2: %@", [self composedBuffer]);
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
    _starting = NO;;
    extern Preferences* preferences;
    NSMutableString* original = [self originalBuffer];
    NSMutableString* composed = [self composedBuffer];

    if ([_curr_candidates count] > 0 && _doConvert)
    {
        [self setComposedBuffer:[_curr_candidates[0] second]];
        NSMutableArray<Triplet*>* t = [_curr_candidates retain];
        dispatch_async(dispatch_get_main_queue(), ^{
            @autoreleasepool {
                [preferences insert_new_entry:t[0] candidates:t];
                [t release];
            }
        });
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

-(void)handle_number:(NSString*)trigger client:(id)sender
{
    extern Preferences* preferences;
    NSInteger val = [trigger intValue];
    if (val < 1 || val > 9) return;
    val--;
    NSInteger target = _curr_page*9 + val;
    if (0 <= target && target < [_curr_candidates count])
    {
        [self setComposedBuffer:[_curr_candidates[target] second]];
        [self commitComposition:sender];
        [preferences insert_new_entry:_curr_candidates[target] candidates:_curr_candidates];
    }
}

-(void)handle_space:(id)sender
{
    _doConvert = NO;
    [self convert:@" " client:sender];
}

-(void)handle_newline:(id)sender
{
//    _doConvert = YES;
//    [self convert:@"\n" client:sender];
}

-(void)handle_backspace:(id)sender
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
    @autoreleasepool {
        NSString* str = [candidateString string];
        _curr_index = [self get_index:str];
        _curr_page = [self get_page_with_index:_curr_index];
    }
}

-(void)updateCandidatesWindow
{
    CandidateWindow* candidates = [self get_candidate_window];
    if (!candidates)
    {
        NSLog(@"DEBUGMESSAGE: No Candidates?!");
        return;
    }
    NSLog(@"DEBUGMESSAGE: updateCandidates?");
    if (!_starting) [candidates hide];
    else
    {
        //@assert that original buffer is not empty
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
            [candidates setCandidates:_candidate_strings];
            [candidates show:_currentClient];
        }
    }
}

-(id)get_curr_client
{
    return _currentClient;
}

-(void)update_curr_candidates
{
    extern Trie* dict;
    extern Preferences* preferences;
    NSMutableArray<Triplet*>* new_can = [[dict subsequence_search:[[self originalBuffer] substringFromIndex:1]] retain];
    [_curr_candidates release];
    _curr_candidates = new_can;
    [preferences sort_based_on_history:_curr_candidates];
    [_candidate_strings release];
    _candidate_strings = [[NSMutableArray alloc]init];
    for (NSInteger i = 0; i < [_curr_candidates count]; i++) \
    {
        NSString* obj = [[NSString alloc] initWithFormat:@"%@ %@", [_curr_candidates[i] second], [_curr_candidates[i] first]];
        NSFont* font = [NSFont fontWithName:@"Chalkboard" size:15];
        NSMutableDictionary* attributes = [NSMutableDictionary dictionary];
        [attributes setObject:font forKey:NSFontAttributeName];
        NSAttributedString* temp = [[NSAttributedString alloc]initWithString:obj attributes:attributes];
        [_candidate_strings addObject:temp];
        [obj release];
        [temp release];
    }
}

-(NSArray*)candidates:(id)sender
{
    _currentClient = sender;
    return _candidate_strings;
}

-(void)candidateSelected:(NSAttributedString *)candidateString
{
    extern Preferences* preferences;
    NSString* tmp = [candidateString string];
    NSArray<NSString*>* line = [tmp componentsSeparatedByString:@" "];
    [self setComposedBuffer:line[0]];
    NSMutableArray<Triplet*>* t = [_curr_candidates retain];
    dispatch_async(dispatch_get_main_queue(), ^{
        @autoreleasepool {
            Triplet* obj = [Triplet triplet:line[1] second:line[0] third:line[0]];
            [preferences insert_new_entry:obj candidates:t];
            [t release];
        }
    });
    [self commitComposition:_currentClient];
}

-(NSInteger)get_page_with_index:(NSInteger)candidateIdentifier // zero indexed
{
    return candidateIdentifier/9;
}

-(NSInteger)get_index:(id)candidateString // zero indexed
{
    NSString* s = candidateString;
    NSArray<NSAttributedString*>* arr = _candidate_strings;
    for (NSInteger i = 0; i < [arr count]; i++)
    {
        if ([[arr[i] string] isEqualToString:s]) return i;
    }
    return NSNotFound;
}

-(void)dealloc
{
    [_originalBuffer release];
    [_composedBuffer release];
    [_curr_candidates release];
    [_candidate_strings release];
    [super dealloc];
}

@end
