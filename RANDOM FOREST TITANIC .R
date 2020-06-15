#Missing values in age
library(rpart)
pred_age <- rpart(Age ~ Pclass + Sex + SibSp + Parch + Fare + Embarked, data = train[!is.na(train$Age),], method = "anova")
train$Age[is.na(train$Age)] <- predict(pred_age, train[is.na(train$Age),])
#No missing values in column Age in train dataset, the same for test:
pred_agetest <- rpart (Age ~ Pclass + Sex + SibSp + Parch + Fare + Embarked, data = test[!is.na(test$Age),], method = "anova")
test$Age[is.na(test$Age)] <- predict(pred_agetest, test[is.na(test$Age),])
#New variable called "Title" Contain -> Mr, Mrs, Miss, Dr itp... 
library(rattle)
library(rpart.plot)
library(RColorBrewer)
library(randomForest)
#drzewko:
tree <- rpart(Survived ~ Pclass + Sex + Age + SibSp + Parch + Fare + Embarked, data = train, method = "class", control = rpart.control(minsplit = 50, cp =0))
#visualization 
fancyRpartPlot(tree)
#other missing values:
train$Embarked <- factor(train$Embarked)
train$Embarked[c(62, 830)] <- "S"
test$Embarked <- factor(test$Embarked)
#randomforest:
forest <- randomForest(as.factor(Survived) ~ Pclass + Sex + Age + SibSp + Parch + Fare + Embarked, data = train, ntree = 150000, importance = TRUE)
set.seed(111)
my_prediction <- predict(forest, data = test, method="class")
solution <- data.frame(PassengerId = test$PassengerId, Survived = my_prediction)
my_prediction
forest
prediction <- predict(forest, data = test, method = "class")
solution <- data.frame(PassengerId = test$PassengerId, Survived = prediction)
