library(reshape2)
filename <- "getdata_dataset.zip"
# Download and unzip the dataset

if (!file.exists(filename)){
   fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip "
   download.file(fileURL, filename, method="curl")
  }  
if (!file.exists("UCI HAR Dataset")) { 
   unzip(filename) 
  }
# load activity and feature file

activity_labels <- read.table("./activity_labels.txt")
activity_labels[,2] <- as.character(activity_labels[,2])
features <- read.table("./features.txt")
features[,2] <- as.character(features[,2])

# features required are only mean and sd

features_wanted <- grep(".*mean.*|.*std.*", features[,2])
features_names <- features[features_wanted,2]

features_names = gsub("-mean", "Mean", features_names)
features_names = gsub("-std", "Std", features_names)
features_names <- gsub('[-()]', '', features_names)

# load the dataset

train <- read.table("./train/X_train.txt")[features_wanted]
train_activity <- read.table("./train/y_train.txt")
train_subjects <- read.table("./train/subject_train.txt")

train <- cbind(train_subjects, train_activity, train)

test <- read.table("./test/X_test.txt")[features_wanted]
test_activity <- read.table("./test/y_test.txt")
test_subjects <- read.table("./test/subject_test.txt")

test <- cbind(test_subjects, test_activity, test)

# merge datasets and labels

all_data <- rbind(train, test)
colnames(all_data) <- c("Subjects", "Activity", features_names)

# turn activity and subjects into factor

all_data$Subjects <- as.factor(all_data$Subjects)
all_data$Activity <- factor(all_data$Activity, levels = activity_labels[,1], 
                            labels = activity_labels[,2])

all_data.melted <- melt(all_data, id = c("Subjects", "Activity"))
all_data.mean <- cast(all_data.melted, Subjects+Activity ~ variable, mean)

write.table(all_data.mean, "tidy.txt", row.names = F, quote = F)
