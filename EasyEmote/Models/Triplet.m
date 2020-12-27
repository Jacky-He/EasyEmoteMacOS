#import "Triplet.h"
@implementation Triplet


+(instancetype)triplet:(id)first second:(id)val2 third:(id)val3
{
    Triplet* t = [[Triplet alloc] init];
    [t set_first:first];
    [t set_second:val2];
    [t set_third:val3];
    return [t autorelease];
}

-(id)first
{
    return _first;
}

-(id)second
{
    return _second;
}

-(id)third
{
    return _third;
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

-(void)set_third:(id)third
{
    [third retain];
    [_third release];
    _third = third;
}

-(void)dealloc
{
    [_first release];
    [_second release];
    [_third release];
    [super dealloc];
}

@end
