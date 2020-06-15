# :passenger_ship: MachineLearningFromDisaster :passenger_ship:
My solutions for Kaggle Titanic competition

I used method called Random Forest with
- python :snake:
- R :chart_with_upwards_trend:

Datasets available here: https://www.kaggle.com/c/titanic/data also here is available description and additional ifnormation about dataset

Good practice is always to look at dataset manually no matter which program language or method we will be using. By this we can notice what steps in data cleaning we have to do:
- we need to convert some values into numeric ones, 
- values have different ranges (we will need to convert them)
- There are some missing values: NaN = not a number

# R:

### 1. Loading the datasets:
```
train <- read.csv("~/Desktop/titanic/train.csv")
test <- read.csv("~/Desktop/titanic/test.csv")
```
### 2. Data cleaning: 
We will clean both datasets together so first I merging them into one: 
```
test$Survived <- NA 
both <- rbind(train, test)
rm(train,test)
```

Then we can check what is missing: 
```
both[both == ""] <- NA
sapply(both, function(x)sum(is.na(x)))
```
Output: 
```
PassengerId    Survived      Pclass        Name         Sex 
          0         418           0           0           0 
        Age       SibSp       Parch      Ticket        Fare 
        263           0           0           0           1 
      Cabin    Embarked 
       1014           2 
 ```
 In age we changing NAs in mean from both datasets, the same for one missign value in 'Fare': 
 ```
 both$Age[is.na(both$Age)] <- mean(both$Age, na.rm=T)
 both$Fare[is.na(both$Fare)] <- mean(both$Fare, na.rm=T)
 ```
 'Embarked' we change for 'S' because most observations have this value so is highly possibly that missing values have also: 
  ```
  both$Embarked[is.na(both$Embarked)] <- 'S'
   ```
 There is too many missing values in 'Cabin' so I will drop this column.
 
 Now we can check if everything is ok with data to perform Random Forest. 
  ```
  str(both)
 ```
 Change some values into type 'factor': 
``` 
both$Survived <- as.factor(both$Survived)
both$Pclass <- as.factor(both$Pclass)
both$SibSp <- as.factor(both$SibSp)
both$Parch <- as.factor(both$Parch)
str(both)
```

### 3. Random Forest:

**Install & load necessary package:**
```
install.packages("randomForest")
library(randomForest)
```

**Split dataset in two back: ** 
```
train <- both[1:891,]
test <- both[892:1309,]
```

**Model:** 
```
dataformodel <- train[,c("Survived", "Pclass", "Sex", "Age", "SibSp", "Parch", "Fare", "Embarked")] 
variablenames <- names(dataformodel)
variablenames <- variablenames[!variablenames %in% c("Survived")]

variablenames <- paste(variablenames, collapse = "+")
randomforest_formula <- as.formula(paste("Survived", variablenames, sep = " ~ "))

my_tree <- rpart(randomforest_formula, data=dataformodel, method="class", control=rpart.control(minsplit = 50, cp = 0))
```
I made randomorest_formula to not write every time all variables :("Survived", "Pclass", "Sex", "Age", "SibSp", "Parch", "Fare", "Embarked")] with separators etc

**Visualisation of tree:**
```
library(rattle)
library(rpart.plot)
library(RColorBrewer)
fancyRpartPlot(my_tree)
```

**Predictions:** 
```
prediction <- predict(my_tree, dataformodel, type="class")
forest <- randomForest(randomforest_formula, data=dataformodel, ntree=1000, importance=TRUE, proximity=TRUE)
forest
```

Checking which variables are most important: 
```
varImpPlot(forest, sort=T)
```
It is visible that sex are most important variable. 
*if an error pops up 'plot.new()':figure margins too large' just increase the size of plot window*


To make a submision on kaggle you can save your file on your computer: 
```
my_prediction <- predict(forest, newdata = test, type = "class")
my_solution <- data.frame(PassengerId = test$PassengerId, Survived = prediction)
nrow(my_solution)
write.csv(my_solution, file="mysolution.csv", row.names = FALSE)
```
