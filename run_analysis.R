##Download the file in your path, hence getwd() for the path variable
packages <- c("data.table", "knitr", "markdown", "memisc")
sapply(packages, require, character.only = TRUE, quietly = TRUE)
library(data.table)
#Package used to generate the Codebook
library(memisc)
path <- getwd()
url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
destFile <- "ProjectDataSet.zip"
download.file(url, file.path(path, destFile))
##Extract the file
executable <- file.path("C:", "Program Files", "WinRAR", "WinRAR.exe")
parameters <- "x"
cmd <- paste(paste0("\"", executable, "\""), parameters, paste0("\"", file.path(path, 
                                                                                destFile), "\""))
system(cmd)
pathIn <- file.path(path, "UCI HAR Dataset")
##Read the files
dtSubjectTrain <- fread(file.path(pathIn, "train", "subject_train.txt"))
dtSubjectTest <- fread(file.path(pathIn, "test", "subject_test.txt"))
dtActivityTrain <- fread(file.path(pathIn, "train", "Y_train.txt"))
dtActivityTest <- fread(file.path(pathIn, "test", "Y_test.txt"))
dtTrain <- fread(file.path(pathIn, "train", "X_train.txt"))
dtTest <- fread(file.path(pathIn, "test", "X_test.txt"))

##Merge Files
#Rows
dtSubject <- rbind(dtSubjectTrain, dtSubjectTest)
setnames(dtSubject, "V1", "subject")
dtActivity <- rbind(dtActivityTrain, dtActivityTest)
setnames(dtActivity, "V1", "activityNum")
dt <- rbind(dtTrain, dtTest)
#Columns
dtSubject <- cbind(dtSubject, dtActivity)
dt <- cbind(dtSubject, dt)
#Set Key
setkey(dt, subject, activityNum)

##Mean and Standard Deviation
dtFeatures <- fread(file.path(pathIn, "features.txt"))
setnames(dtFeatures, names(dtFeatures), c("featureNum", "featureName"))
dtFeatures <- dtFeatures[grepl("mean\\(\\)|std\\(\\)", featureName)]
dtFeatures$featureCode <- dtFeatures[, paste0("V", featureNum)]
select <- c(key(dt), dtFeatures$featureCode)
dt <- dt[, select, with = FALSE]

##Descriptive Activity Names
dtActivityNames <- fread(file.path(pathIn, "activity_labels.txt"))
setnames(dtActivityNames, names(dtActivityNames), c("activityNum", "activityName"))
dt <- merge(dt, dtActivityNames, by = "activityNum", all.x = TRUE)
setkey(dt, subject, activityNum, activityName)
dt <- data.table(melt(dt, key(dt), variable.name = "featureCode"))
dt <- merge(dt, dtFeatures[, list(featureNum, featureCode, featureName)], by = "featureCode", 
            all.x = TRUE)
dt$activity <- factor(dt$activityName)
dt$feature <- factor(dt$featureName)
grepthis <- function(regex) {
  grepl(regex, dt$feature)
}
## Features with 2 categories
n <- 2
y <- matrix(seq(1, n), nrow = n)
x <- matrix(c(grepthis("^t"), grepthis("^f")), ncol = nrow(y))
dt$featDomain <- factor(x %*% y, labels = c("Time", "Freq"))
x <- matrix(c(grepthis("Acc"), grepthis("Gyro")), ncol = nrow(y))
dt$featInstrument <- factor(x %*% y, labels = c("Accelerometer", "Gyroscope"))
x <- matrix(c(grepthis("BodyAcc"), grepthis("GravityAcc")), ncol = nrow(y))
dt$featAcceleration <- factor(x %*% y, labels = c(NA, "Body", "Gravity"))
x <- matrix(c(grepthis("mean()"), grepthis("std()")), ncol = nrow(y))
dt$featVariable <- factor(x %*% y, labels = c("Mean", "SD"))
## Features with 1 category
dt$featJerk <- factor(grepthis("Jerk"), labels = c(NA, "Jerk"))
dt$featMagnitude <- factor(grepthis("Mag"), labels = c(NA, "Magnitude"))
## Features with 3 categories
n <- 3
y <- matrix(seq(1, n), nrow = n)
x <- matrix(c(grepthis("-X"), grepthis("-Y"), grepthis("-Z")), ncol = nrow(y))
dt$featAxis <- factor(x %*% y, labels = c(NA, "X", "Y", "Z"))
r1 <- nrow(dt[, .N, by = c("feature")])
r2 <- nrow(dt[, .N, by = c("featDomain", "featAcceleration", "featInstrument", 
                           "featJerk", "featMagnitude", "featVariable", "featAxis")])
r1 == r2

##Generate the tidy set
setkey(dt, subject, activity, featDomain, featAcceleration, featInstrument, 
       featJerk, featMagnitude, featVariable, featAxis)
dtTidy2 <- dt[, list(count = .N, average = mean(value)), by = key(dt)]
View(dtTidy2)

##Using package memisc
codebook(dtTidy2)
