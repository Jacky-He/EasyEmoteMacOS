#import <Foundation/Foundation.h>
#import <YCML/YCML.h>
#import <fmdb/FMDB.h>
#import "Pair.h"

@interface Preferences : NSObject
{
    YCFFN* _prediction_model;
    FMDatabase* db;
}

-(Preferences*)initialize;
-(void)sort_based_on_history:(NSArray<Pair*>*)arr;
-(void)insert_new_entry:(Pair*)entry;

@end
