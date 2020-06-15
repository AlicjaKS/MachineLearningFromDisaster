train <- read.csv("~/Desktop/titanic/train.csv")
test <- read.csv("~/Desktop/titanic/test.csv")

test$Survived <- NA 
both <- rbind(train, test)
rm(train,test)

both[both == ""] <- NA
sapply(both, function(x)sum(is.na(x)))
both$Age[is.na(both$Age)] <- mean(both$Age, na.rm=T)
both$Embarked[is.na(both$Embarked)] <- 'S'
both$Fare[is.na(both$Fare)] <- mean(both$Fare, na.rm=T)
sapply(both, function(x) sum(is.na(x)))

str(both)
both$Survived <- as.factor(both$Survived)
both$Pclass <- as.factor(both$Pclass)
both$SibSp <- as.factor(both$SibSp)
both$Parch <- as.factor(both$Parch)
str(both)

install.packages("randomForest")
library(randomForest)

train <- both[1:891,]
test <- both[892:1309,]

library(rattle)
library(rpart.plot)
library(RColorBrewer)

dataformodel <- train[,c("Survived", "Pclass", "Sex", "Age", "SibSp", "Parch", "Embarked")] 
variablenames <- names(dataformodel)
variablenames <- variablenames[!variablenames %in% c("Survived")]

variablenames <- paste(variablenames, collapse = "+")
randomforest_formula <- as.formula(paste("Survived", variablenames, sep = " ~ "))

my_tree <- rpart(randomforest_formula, data=dataformodel, method="class", control=rpart.control(minsplit = 50, cp = 0))
fancyRpartPlot(my_tree)

forest <- randomForest(randomforest_formula, data=dataformodel, ntree=100, importance=TRUE, proximity=TRUE)
forest
varImpPlot(forest, sort=T)
prediction <- predict(forest, test, type="class")


my_prediction <- predict(forest, newdata = test, type = "class")
my_solution <- data.frame(PassengerId = test$PassengerId, Survived = prediction)
nrow(my_solution)
write.csv(my_solution, file="mysolution.csv", row.names = FALSE)
