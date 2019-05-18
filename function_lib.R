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








