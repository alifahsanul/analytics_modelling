library("e1071")

attach(iris)
x <- subset(iris, select=-Species)
y <- Species
svm_model <- svm(Species ~ ., data=iris)
summary(svm_model)






