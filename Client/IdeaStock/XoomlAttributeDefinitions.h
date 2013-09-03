//
//  XoomlAttributeDefinitions.h
//  Mindcloud
//
//  Created by Ali Fathalian on 8/31/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol XoomlAttributeDefinitions <NSObject>

#define SCHEMA_VERISON_NAME @"schemaVersion"
#define SCHEMA_VERSION @"2"
#define SCHEMA_LOCATION_NAME @"schemaLocation"
#define ITEM_DRIVER_NAME @"itemDriver"
#define XOOML_DRIVER_NAME @"xooMLDriver"
#define SYNC_DRIVER_NAME @"syncDriver"
#define ITEM_DESCRIBED_NAME @"itemDescribed"
#define FRAGMENT_NAMESPACE_DATA @"fragmentNamespaceData"
#define THUMBNAIL_ELEMENT_NAME @"thumbnail"
#define THUMBNAIL_REF_ID @"refId"
#define XMLNS_NAME @"xmlns"
#define GUID_NAME @"GUIDGeneratedOnLastWrite"
#define FRAGMENT_NAME @"fragment"
#define ITEM_ID @"ID"
#define ASSOCIATION_NAME @"association"

@end
