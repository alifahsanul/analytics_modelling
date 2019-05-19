break_string = function(my_str, delim, len){
  str_list = strsplit(my_str, delim, fixed=TRUE)
  result = paste(str_list[[1]][1], delim)
  ind_after_newline = nchar(str_list[[1]][1])
  for (s in tail(str_list[[1]], -1)){
    len_s = nchar(s)
    if (ind_after_newline+len_s < len){
      result = paste(result, s, delim, sep='')
      ind_after_newline = ind_after_newline + len_s
    } else {
      result = paste(result, '\n', s, delim, sep='')
      ind_after_newline = 0
    }
  }
  result = substr(result, 0, nchar(result)-1)
  return (result)
}

max_row_df = function(df, col){
  result = which.max(df[, c(col)])
  return (result)
}

my_ksvm = function(X, y, kernel, c_params, arg_list, verbose=TRUE){
  kpar = arg_list
  model = ksvm(X, y, type='C-svc', kernel=kernel, C=c, kpar=kpar, scaled=TRUE)
  y_pred = predict(model, X)
  conf_matr = confusionMatrix(y_pred, y)
  accuracy = conf_matr[['overall']][['Accuracy']] * 100
  f1_score = conf_matr[['byClass']][['F1']] * 100
  return_list = list('model'=model, 'conf_matrix'=conf_matr, 'accuracy'=accuracy, 'f1_score'=f1_score)
  if (verbose){
    cat(sprintf('\n---------------------------\n'))
    cat(sprintf('C: %.6f\n', c))
    print_list(arg_list)
    cat(sprintf('Accuracy: %.2f %%\tF1 Score: %.2f %%\n', accuracy, f1_score))
  }
  return (return_list)
}

print_list = function(arg_list){
  names = names(arg_list)
  s = ''
  for (i in seq_along(arg_list)){
    key = names[i]
    val = arg_list[i]
    if (typeof(val) == 'character'){
      s = paste(s, sprintf('%s: %s\t', key, val), sep='')
    } else{
      s = paste(s, sprintf('%s: %.6f\t', key, val), sep='')
    }
  }
  s1 = break_string(s, '\t', 70)
  cat(s1)
  cat('\n')
  return (s1)
}

best_model = function(df_summary, check_col){
  max_row = df_summary[which.max(df_summary[[check_col]]),]
  return(max_row)
}

is_close_to = function(a, b, max_relative_error){
  if (missing(max_relative_error)){
    max_relative_error=0.0001
    }
  rel_err = abs(a-b)/a
  if (rel_err < max_relative_error){
    res = TRUE
  }else{
    res = FALSE
  }
  return (res)
}

train_test_val_split = function(X, y, train_p, test_p, val_p){
  total_p = train_p+test_p+val_p
  stopifnot(is_close_to(total_p,1))
  spec = c(train=train_p, test=test_p, validate=val_p)
  g = sample(cut(
    seq(nrow(X)),
    nrow(X)*cumsum(c(0,spec)),
    labels = names(spec)
  ))
  res = list('X'=split(X, g), 'y'=split(y, g))
  return (res)
}

train_test_split = function(X, y, train_p, test_p){
  total_p = train_p+test_p
  stopifnot(is_close_to(total_p,1))
  spec = c(train=train_p, test=test_p)
  g = sample(cut(
    seq(nrow(X)),
    nrow(X)*cumsum(c(0,spec)),
    labels = names(spec)
  ))
  res = list('X'=split(X, g), 'y'=split(y, g))
  return (res)
}


















