@interface R1EmitterLineItem : NSObject

/*! The item ID, as a string. */
@property (nonatomic, copy)  NSString *itemID;

/*! The item name. */
@property (nonatomic, copy) NSString *itemName;

/*! The item quantity. */
@property (nonatomic, assign) NSInteger quantity;

/*! The item unit of measure. */
@property (nonatomic, copy) NSString *unitOfMeasure;

/*! The item msrPrice. */
@property (nonatomic, assign) double msrPrice;

/*! The item pricePaid. */
@property (nonatomic, assign) double pricePaid;

/*! The item currency. */
@property (nonatomic, copy) NSString * currency;

/*! The item category. */
@property (nonatomic, copy) NSString * itemCategory;

- (id) initWithItemID:(NSString *) itemID;


/*!
 Create and initialize an item.
 
 @param itemID The item product ID; must not be `nil` or empty.
 
 @param itemName The item product name; must not be `nil` or empty.
 
 @return The newly initialized item.
 */
+ (R1EmitterLineItem *) itemWithID:(NSString *) itemID
                              name:(NSString *) itemName;

/*!
 Create and initialize an item.
 
 @param itemID The item product ID; must not be `nil` or empty.
 
 @param itemName The item product name; must not be `nil` or empty.
 
 @param quantity The item quantity, as an NSInteger.

 @param unitOfMeasure The item product unit of measure; may be `nil`.
 
 @param msrPrice The item msr price.
 
 @param pricePaid The item price paid.

 @param currency The item currency.
 
 @param itemCategory The item category.

 @return The newly initialized item.
 */
+ (R1EmitterLineItem *) itemWithID:(NSString *) itemID
                              name:(NSString *) itemName
                          quantity:(NSInteger) quantity
                     unitOfMeasure:(NSString *) unitOfMeasure
                          msrPrice:(float) msrPrice
                         pricePaid:(float) pricePaid
                          currency:(NSString *) currency
                      itemCategory:(NSString *) itemCategory;

@end
