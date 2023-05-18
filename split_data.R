# Load original data
data <- read.csv("Ames_data.csv")
testIDs <- read.table("testIDs.dat")

# Create 10 splits of the data
for (i in 1:10) {
  dir.create(paste("split_", i, sep=""))
  train <- data[-testIDs[, i], ]
  test <- data[testIDs[, i], ]
  test.y <- test[, c(1, 83)]
  test <- test[, -83]
  tmp_file_name <- paste("split_", i, "/", "train.csv", sep="") 
  write.csv(train, tmp_file_name, row.names=FALSE)
  tmp_file_name <- paste("split_", i, "/", "test.csv", sep="") 
  write.csv(test, tmp_file_name, row.names=FALSE)
  tmp_file_name <- paste("split_", i, "/", "test_y.csv", sep="") 
  write.csv(test.y, tmp_file_name, row.names=FALSE)
}
