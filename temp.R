library(kknn)
training = data
trctrl <- trainControl(method = 'cv', number = 7)
tuneGrid <- expand.grid(kmax = 1:3,            # allows to test a range of k values
                        distance = 1:2,        # allows to test a range of distance values
                        kernel = c('gaussian',  # different weighting types in kknn
                                   'triangular',
                                   'rectangular'
                                   ))

kknn_fit <- train(R1 ~ ., 
                  data = training, 
                  method = 'kknn',
                  trControl = trctrl,
                  preProcess = c('center', 'scale'),
                  tuneGrid = tuneGrid)






