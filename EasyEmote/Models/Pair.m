#import <Foundation/Foundation.h>
#import "Pair.h"
@implementation Pair

+(instancetype)pair:(id)first second:(id)val2
{
    Pair* p = [[Pair alloc] init];
    [p set_first:first];
    [p set_second:val2];
    return [p autorelease];
}

-(id)first
{
    return _first;
}

-(id)second
{
    return _second;
}

-(void)set_first:(id)first
{
    [first retain];
    [_first release];
    _first = first;
}

-(void)set_second:(id)second
{
    [second retain];
    [_second release];
    _second = second;
}

-(void)dealloc
{
    [_first release];
    [_second release];
    [super dealloc];
}

@end
