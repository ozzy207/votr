//
//  DALabeledCircularProgressView.h
//  DACircularProgressExample
//

#import "DACircularProgressView.h"

/**
 @class DALabeledCircularProgressView
 
 @brief Subclass of DACircularProgressView that adds a UILabel.
 */
@interface DALabeledCircularProgressView : DACircularProgressView

/**
 UILabel placed right on the DACircularProgressView.
 */
@property (strong, nonatomic) UILabel *progressLabel;

@end
