## Script to process and clean the Smartphone activity data

# Download file
if(!file.exists("UCI HAR Dataset")){
  if (!file.exists("data.zip")) {
    download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip", destfile = "data.zip")
  }
  unzip("data.zip")
} else {
     print("Folder already exists")
}

# Merge the training and test sets to create one data set

# Read and combine the data sets
train <- read.table("UCI HAR Dataset/train/X_train.txt")
test <- read.table("UCI HAR Dataset/test/X_test.txt")
main <- rbind(test, train)
rm(train, test)

# Read and combine the subject information
subjTrain <- read.table("UCI HAR Dataset/train/subject_train.txt")
subjTest <- read.table("UCI HAR Dataset/test/subject_test.txt")
subjects <- rbind(subjTest, subjTrain)
rm(subjTrain, subjTest)


    # Read and combine the activity column

activityTrain <- read.table("UCI HAR Dataset/train/y_train.txt")
activityTest <- read.table("UCI HAR Dataset/test/y_test.txt")
activity <- rbind(activityTest, activityTrain)
rm(activityTrain, activityTest)

     # Make the activity column a factor, associating meaningful names with the activity

myLabels <- read.table("UCI HAR Dataset/activity_labels.txt")
activity <- factor(activity$V1, labels = myLabels$V2, levels = myLabels$V1)

    # Combine the data, subject, and activity columns
    
main <- cbind(main, subjects, activity)

## Extract the mean and stdev columns for each measurement

 # Read in the feature names and figure out which ones are means and std

myFeatures <- read.table("UCI HAR Dataset/features.txt")

# Grepl searches for a match to the given string and returns a logical vector indicating if each
# element of myFeatures$V2 matches this string. 

meanFeats <- grepl("mean", myFeatures$V2)
excludeFeats <- grepl("meanFreq",myFeatures$V2 )
stdFeats <-grepl("std", myFeatures$V2)

selectFeats <- (meanFeats | stdFeats) & !excludeFeats

# myFeatures$V2[selectFeats] should list all the features to be included
MyVarNames <- as.character(myFeatures$V2[selectFeats])

# add two true values onto selectFeats to grab the Subject and Activity columns
selectFeats <- c(selectFeats, TRUE, TRUE)
MyVarNames <- c(MyVarNames, "Subject", "Activity")

main <- main[selectFeats]

# Label the data set with descriptive activity and variable names
#   - the activities are already labeled since the data has been transformed from
#     a integer value to a factor. 
# 

names(main) <- MyVarNames


# Create a second tidy data set with the avg of each variable for each activity and each subject.

EndingCol <- dim(main)[2]-2
Averages <- aggregate(main[1:EndingCol], by=list(main$Subject, main$Activity), FUN=mean)

names(Averages)[1] <- "SubjectID"
names(Averages)[2] <- "Activity"

write.table(Averages, file = "AveragedSmartPhoneData.txt", row.names = FALSE)
