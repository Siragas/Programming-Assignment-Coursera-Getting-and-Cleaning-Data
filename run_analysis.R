#download and unzip the required data in your working directory
if(!file.exists("./project.data")){dir.create("./project.data")}
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl,destfile="./project.data/data.zip")
unzip(zipfile="./project.data/data.zip",exdir="./data")

#Reading the test and training data using fread function which is in the data.table package 
# in order to do it faster.Reading features and activity labels as well.
#Finally,we name the data accordingly in order to have a better understanding
#of what each table represents.

#run if necessary 
install.packages("data.table")
library(data.table)

test_values <- fread("./data/UCI HAR Dataset/test/X_test.txt")
test_activities <- fread("./data/UCI HAR Dataset/test/y_test.txt")
test_subjects <- fread("./data/UCI HAR Dataset/test/subject_test.txt")

train_values <- fread("./data/UCI HAR Dataset/train/X_train.txt")
train_activities <- fread("./data/UCI HAR Dataset/train/y_train.txt")
train_subjects <- fread("./data/UCI HAR Dataset/train/subject_train.txt")

features <- fread('./data/UCI HAR Dataset/features.txt')

activity_labels <-fread('./data/UCI HAR Dataset/activity_labels.txt')

#Now, we will merge the test and training data sets in order to create
# one data set.

merged_test_data<-cbind(test_subjects,test_activities,test_values)
merged_train_data<-cbind(train_subjects,train_activities,train_values)

merged_data<-rbind(merged_test_data,merged_train_data) #we have merged all the data into one data frame

#In this step we name the columns of our  data frame accordingly.
colnames(merged_data)<-c("subject","activity",features$V2)

#In order to keep only the required columns,we extract the measurements
# of the mean and standard deviation ,as well as the subject and acticity
# columns.
required_columns<-grepl("subject|activity|mean|std", colnames(merged_data))

mean_std_data<-merged_data[,required_columns,with=F]

mean_std_data<-mean_std_data[order(subject)] #order the data table by ascending subject order


#Use descricptive activity names to name the activities in the data set by using factors
mean_std_data$activity<-factor(mean_std_data$activity,
                               levels = activity_labels$V1,
                               labels = activity_labels$V2)

#Turn the subject into factor as well

mean_std_data$subject<-as.factor(mean_std_data$subject)

#Now,we want to label our data set with descriptive variable names.
# One way to do that without renaming each column one by one, is
# by removing the unecessary symbols.Furthermore, we can use the 
# features_info txt which we have downloaded in order to replace
# the abbreviated names with somewhat full ones.

#first we take a look at the variable names to see what changes should be made
names(mean_std_data)

#Then we make some changes

col_names<-names(mean_std_data)

col_names<-gsub("[-()]","",col_names) #remove symbols
col_names<-gsub("mean","Mean",col_names)
col_names<-gsub("std","Std",col_names)
col_names<-gsub("BodyBody","Body",col_names)
#IMPORTANT: We could replace all the  abbreviated terms such as 
# t-->time or Mag-->Magnitude 
#I chose not to do it because then we would end up with lengthy variable
# names,which defeats the whole purpose of making the variable names more
#accurate and descriptive.


#Now we have our tidy data set
colnames(mean_std_data)<-col_names
tidyData_1<-mean_std_data


#Finally,from the tidy data set of the previous step,we create an new
# independent tidy data set with the average of each variable for each 
# activity and each subject.Then we convert the final tidy dataset
# into a txt file.
melted_data<-melt(tidyData_1,id.vars = c("subject","activity"))
tidyData<-dcast(melted_data,subject+activity~variable,mean)

write.table(tidyData,"tidyData.txt", row.names = FALSE)


 
