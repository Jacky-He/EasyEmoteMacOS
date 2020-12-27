#import "Record.h"

@implementation Record

+(instancetype) record:(double)res total_select:(int)ts mago_select:(int)ms wago_select:(int)ws ave_int:(double)ai
{
    Record* r = [[Record alloc] init];
    [r set_res:res];
    [r set_ts:ts];
    [r set_ms:ms];
    [r set_ws:ws];
    [r set_ai:ai];
    return [r autorelease];
}

-(int)total_select
{
    return _total_select;
}

-(void)set_ts:(int)ts
{
    _total_select = ts;
}

-(void)set_ms:(int)ms
{
    _mago_select = ms;
}

-(void)set_ws:(int)ws
{
    _wago_select = ws;
}

-(void)set_ai:(double)ai
{
    _ave_int = ai;
}

-(void)set_res:(double)res
{
    _res = res;
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
