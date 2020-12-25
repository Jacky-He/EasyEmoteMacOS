#import <Foundation/Foundation.h>

@interface Record : NSObject
{
    double _res;
    int _total_select;
    int _mago_select;
    int _wago_select;
    double _ave_int;
}

-(Record*)initialize:(double)res total_select:(int)ts mago_select:(int)ms wago_select:(int)ws ave_int:(double)ai;
-(int)total_select;
-(int)mago_select;
-(int)wago_select;
-(double)ave_int;
-(double)res;

@end
