#import <YCML/YCML.h>
#import <fmdb/FMDB.h>
#import "Pair.h"
#import "Record.h"
#import "CHCSVParser.h"

@interface Preferences : NSObject
{
    YCFFN* _prediction_model;
    FMDatabase* _db;
}

-(Preferences*)initialize;
-(void)sort_based_on_history:(NSArray<Pair*>*)arr;
-(void)insert_new_entry:(Pair*)entry candidates:(NSArray<Pair*>*)potential;

@end
