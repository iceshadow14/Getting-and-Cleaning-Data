library(plyr)

## Download file
if( !file.exists("UCI HAR Dataset") ) {
  download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip",destfile = "data.zip")
  unzip("data.zip")
}

####################################################################
# 1. Merges the training and the test sets to create one data set. #
####################################################################

# Load Train Data
data.train.x <- read.table("UCI HAR Dataset/train/X_train.txt")
data.train.y <- read.table("UCI HAR Dataset/train/y_train.txt")
data.train.subject <- read.table("UCI HAR Dataset/train/subject_train.txt")

# Load Test Data
data.test.x <- read.table("UCI HAR Dataset/test/X_test.txt")
data.test.y <- read.table("UCI HAR Dataset/test/y_test.txt")
data.test.subject <- read.table("UCI HAR Dataset/test/subject_test.txt")

# Combine Train and Test
data.x <- rbind(data.train.x, data.test.x)
data.y <- rbind(data.train.y, data.test.y)
data.subject <- rbind(data.train.subject, data.test.subject)

#############################################################################################
# 2.Extracts only the measurements on the mean and standard deviation for each measurement. #
#############################################################################################

data.features <- read.table("UCI HAR Dataset/features.txt", header = FALSE, sep = " ")

# get only columns with mean() or std() in their names
features.mean.std <- grepl("mean\\(\\)|std\\(\\)",data.features[,2])

# subset measurement
data.extract.x <- data.x[,features.mean.std]

# correct the column names
names(data.extract.x) <- data.features[features.mean.std,2]

##############################################################################
# 3. Uses descriptive activity names to name the activities in the data set. #
##############################################################################

data.activity.labels <- read.table("UCI HAR Dataset/activity_labels.txt", header = FALSE, sep = " ")

# update values with correct activity names
data.y[, 1] <- data.activity.labels[data.y[, 1], 2]

# correct the column name
names(data.y) <- "activity"

########################################################################
# 4. Appropriately labels the data set with descriptive variable names.#
########################################################################

# correct column name
names(data.subject) <- "subject"

# bind all the data in a single data set
data <- cbind(data.extract.x, data.y, data.subject)

################################################################################
# 5. From the data set in step 4, creates a second, independent tidy data      #
#    set with the average of each variable for each activity and each subject. #
################################################################################
data.average <- ddply(data, .(subject, activity), function(x) colMeans(x[, 1:66]))

write.table(data.average, "tidy_data.txt", row.names = FALSE)
