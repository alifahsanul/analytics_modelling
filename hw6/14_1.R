setwd('/home/alifahsanul/Documents/analytics_modelling/hw6')
rm(list=ls())
Mode <- function(x) {
  ux <- unique(x)
  ux[which.max(tabulate(match(x, ux)))]
}
cancer_df = read.csv('breast-cancer-wisconsin.data.txt', header = FALSE, stringsAsFactors=FALSE)

missing_rows = which(cancer_df$V7 == '?', arr.ind=TRUE)

print('ratio of missing rows')
length(missing_rows) / nrow(cancer_df)

cancer_df$V7 = as.numeric(cancer_df$V7)
cancer_df$V11 <- as.factor(cancer_df$V11)
str(cancer_df)

imputation_mode = 'add_binary_col' #choose from: mean, mode, regr, regr_pert, remove, add_binary_col

if (imputation_mode == 'mean'){
  cancer_df$V7[missing_rows] = mean(cancer_df$V7, na.rm = TRUE) #1.a. mean imputation
} else if (imputation_mode == 'mode'){
  cancer_df$V7[missing_rows] = Mode(cancer_df$V7) #1.b. mode imputation
} else if (imputation_mode == 'regr'){ #2. regression imputation
  regr_imp_df = cancer_df[-missing_rows, 2:10]
  regr_imp_model = lm(V7 ~ ., data=regr_imp_df)
  summary(regr_imp_model)
  new_data = predict(regr_imp_model, cancer_df[missing_rows, 2:10])
  cancer_df$V7[missing_rows] = new_data
} else if (imputation_mode == 'regr_pert'){ #3. regression with perturbation imputation
  regr_imp_df = cancer_df[-missing_rows, 2:10]
  regr_imp_model = lm(V7 ~ ., data=regr_imp_df)
  summary(regr_imp_model)
  new_data = predict(regr_imp_model, cancer_df[missing_rows, 2:10])
  new_data = rnorm(n=length(new_data), mean=new_data, sd=sd(new_data))
  cancer_df$V7[missing_rows] = new_data
} else if (imputation_mode == 'remove'){ #4. remove missing value
  cancer_df = cancer_df[-missing_rows, ]
} else if (imputation_mode == 'add_binary_col'){ #5. introduce binary variable
  cancer_df$V7[missing_rows] = 0
  cancer_df$ismissing = 1 #dummy, only for initialization
  cancer_df$ismissing[missing_rows] = 1
  cancer_df$ismissing[-missing_rows] = 0
}

#remove id number (first column)
cancer_df = cancer_df[, 2:ncol(cancer_df)]
cancer_df[missing_rows, ]

set.seed(0)
library(caTools)
sample = sample.split(cancer_df, SplitRatio=0.8)
train = subset(cancer_df, sample == TRUE)
test = subset(cancer_df, sample == FALSE)

library(caret)
trctrl = trainControl(method='repeatedcv', number=5, repeats=2)
svm_Linear <- train(V11 ~., data = train, method = 'svmLinear',
                    trControl=trctrl,
                    preProcess = c('center', 'scale'),
                    tuneLength = 10)

test_pred <- predict(svm_Linear, newdata = test)
confusionMatrix(test_pred, test$V11)

