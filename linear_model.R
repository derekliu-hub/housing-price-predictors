set.seed(2)
library(glmnet)

# Set working directory to one of the 10 splits
setwd("split_10")

###########################################
# Step 1: Preprocess training data and fit the linear model

train = read.csv("train.csv", stringsAsFactors = FALSE)
train.y = subset(train, select=c(PID, Sale_Price))
train.y$Sale_Price = log(train.y$Sale_Price)

train.x = subset(train, select=-c(PID, Sale_Price))
train.x$Garage_Yr_Blt[is.na(train.x$Garage_Yr_Blt)] = 0
train.x = subset(train.x, select=-c(Street, Utilities, Condition_2, Roof_Matl, Heating, Pool_QC, Misc_Feature, Low_Qual_Fin_SF, Pool_Area, Longitude, Latitude))
winsor.vars = c("Lot_Frontage", "Lot_Area", "Mas_Vnr_Area", "BsmtFin_SF_2", "Bsmt_Unf_SF", "Total_Bsmt_SF", "Second_Flr_SF", 'First_Flr_SF', "Gr_Liv_Area", "Garage_Area", "Wood_Deck_SF", "Open_Porch_SF", "Enclosed_Porch", "Three_season_porch", "Screen_Porch", "Misc_Val")
quan.value = 0.95
for (var in winsor.vars) {
  tmp = train.x[, var]
  myquan = quantile(tmp, probs = quan.value, na.rm = TRUE)
  tmp[tmp > myquan] = myquan
  train.x[, var] = tmp
}

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
elastic.model = cv.glmnet(as.matrix(train.matrix), train.y$Sale_Price, alpha=0.5)

###########################################
# Step 2: Preprocess test data and output predictions into a file

test.x = read.csv("test.csv")
test.x$Garage_Yr_Blt[is.na(test.x$Garage_Yr_Blt)] = 0
test.x = subset(test.x, select=-c(Street, Utilities, Condition_2, Roof_Matl, Heating, Pool_QC, Misc_Feature, Low_Qual_Fin_SF, Pool_Area, Longitude, Latitude))
quan.value = 0.95
for (var in winsor.vars) {
  tmp = test.x[, var]
  myquan = quantile(tmp, probs = quan.value, na.rm = TRUE)
  tmp[tmp > myquan] = myquan
  test.x[, var] = tmp
}

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
linear_pred = predict(elastic.model, s = elastic.model$lambda.min, newx = as.matrix(test.matrix))
linear_pred = cbind(test.x$PID, exp(linear_pred))
colnames(linear_pred) = c("PID", "Sale_Price")
write.csv(linear_pred, "linear_pred.txt", row.names=FALSE)

test.y = read.csv("test_y.csv")
names(test.y)[2] = "True_Sale_Price"
pred = read.csv("linear_pred.txt")
pred = merge(pred, test.y, by="PID")
print(paste0("RMSE of linear model is: ", sqrt(mean((log(pred$Sale_Price) - log(pred$True_Sale_Price))^2))))

# Return to main directory
setwd("..")
