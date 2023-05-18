set.seed(2)
library(xgboost)

# Set working directory to one of the 10 splits
setwd("split_10")

###########################################
# Step 1: Preprocess training data and fit the tree model

train = read.csv("train.csv", stringsAsFactors = FALSE)
train.y = subset(train, select=c(PID, Sale_Price))
train.y$Sale_Price = log(train.y$Sale_Price)

train.x = subset(train, select=-c(PID, Sale_Price))
train.x$Garage_Yr_Blt[is.na(train.x$Garage_Yr_Blt)] = 0

categorical.vars = colnames(train.x)[which(sapply(train.x, function(x) mode(x)=="character"))]
train.matrix = train.x[, !colnames(train.x) %in% categorical.vars, drop=FALSE]
n.train = nrow(train.matrix)
for (var in categorical.vars) {
  mylevels = sort(unique(train.x[, var]))
  m = length(mylevels)
  m = ifelse(m>2, m, 1)
  tmp.train = matrix(0, n.train, m)
  col.names = NULL
  for (j in 1:m) {
    tmp.train[train.x[, var]==mylevels[j], j] = 1
    col.names = c(col.names, paste(var, '_', mylevels[j], sep=''))
  }
  colnames(tmp.train) = col.names
  train.matrix = cbind(train.matrix, tmp.train)
}
xgb.model = xgboost(data = as.matrix(train.matrix),
                    label = train.y$Sale_Price, max_depth = 6,
                    eta = 0.05, nrounds = 5000,
                    subsample = 0.5,
                    verbose = FALSE)

###########################################
# Step 2: Preprocess test data and output predictions into a file

test.x = read.csv("test.csv")
test.x$Garage_Yr_Blt[is.na(test.x$Garage_Yr_Blt)] = 0

categorical.vars = colnames(test.x)[which(sapply(test.x, function(x) mode(x)=="character"))]
test.matrix = test.x[, !colnames(test.x) %in% categorical.vars, drop=FALSE]
n.test = nrow(test.matrix)
for (var in categorical.vars) {
  mylevels = sort(unique(train.x[, var]))
  m = length(mylevels)
  m = ifelse(m>2, m, 1)
  tmp.test = matrix(0, n.test, m)
  col.names = NULL
  for (j in 1:m) {
    tmp.test[test.x[, var]==mylevels[j], j] = 1
    col.names = c(col.names, paste(var, '_', mylevels[j], sep=''))
  }
  colnames(tmp.test) = col.names
  test.matrix = cbind(test.matrix, tmp.test)
}

test.matrix = subset(test.matrix, select=-c(PID))
tree_pred = predict(xgb.model, as.matrix(test.matrix))
tree_pred = cbind(test.x$PID, exp(tree_pred))
colnames(tree_pred) = c("PID", "Sale_Price")
write.csv(tree_pred, "tree_pred.txt", row.names=FALSE)

test.y = read.csv("test_y.csv")
names(test.y)[2] = "True_Sale_Price"
pred = read.csv("tree_pred.txt")
pred = merge(pred, test.y, by="PID")
print(paste0("RMSE of tree model is: ", sqrt(mean((log(pred$Sale_Price) - log(pred$True_Sale_Price))^2))))

# Return to main directory
setwd("..")
