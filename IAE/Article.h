//
//  Article.h
//  IAE
//
//  Created by Philippe Nougaillon on 11/12/2013.
//  Copyright (c) 2013 Philippe Nougaillon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Article : NSManagedObject

@property (nonatomic, retain) NSString * image;
@property (nonatomic, retain) NSString * nid;
@property (nonatomic, retain) NSString * postDate;
@property (nonatomic, retain) NSNumber * read;
@property (nonatomic, retain) NSString * title;

@end
