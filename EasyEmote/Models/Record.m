#import "Record.h"

@implementation Record

-(Record*)initialize:(double)res total_select:(int)ts mago_select:(int)ms wago_select:(int)ws ave_int:(double)ai
{
    self = [super init];
    if (self)
    {
        _res = res;
        _total_select = ts;
        _mago_select = ms;
        _wago_select = ws;
        _ave_int = ai;
    }
    return self;
}

-(int)total_select
{
    return _total_select;
}

-(int)mago_select
{
    return _mago_select;
}

-(int)wago_select
{
    return _wago_select;
}

-(double)ave_int
{
    return _ave_int;
}

-(double)res
{
    return _res;
}

@end
