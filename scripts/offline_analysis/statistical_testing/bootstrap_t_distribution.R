# comparing means/correlations between two groups regarding any number of variables with bootstrapped t-values

# input: two numeric matrices (or column vectors) - one for each group - in dataframe format, where each column 
# denotes a variable (same in each matrix), test to use (e. g. t.test(), wilcox.test(), cor.test()), 
# variance equality or inequality (e. g. var.equal = TRUE)).
# output: matrix of size 4 (p-value, bootstrap mean, lower & upper bound) times the number of variables. 

# if test is cor.test: correlations can only be tested columnwise with respect to both matrices, i.e., 
# correlation between column1 of matrix1 and column1 of matrix2, column2 of matrix1 and column2 of matrix2 etc.

bootstrap_t_distribution <- function(matrix1, matrix2, test, var.equal){
  
  tVector = numeric()
  t = array(1, dim=c(7,dim(matrix1)[2]))    # 7: number of values to be returned from the bootstrapping

  
  for (j in 1:dim(matrix1)[2]){
      FUN = match.fun(test)
      t_value = as.numeric(FUN(matrix1[,j],matrix2[,j], "two.sided", var.equal = var.equal)[1])
      df = as.numeric(FUN(matrix1[,j],matrix2[,j], "two.sided", var.equal = var.equal)[2])
      
      n = 3000
      
      index1 = numeric()
      set.seed(10)
      index1 = sample(1:100000,3000,replace=T)
      index2 = numeric()
      set.seed(20)
      index2 = sample(1:100000,3000,replace=T)
      
      for (i in 1:n) {
        grand_sample = rbind(t(t(matrix1[,j])), t(t(matrix2[,j])))
        
        set.seed(index1[i])
        blubb1 = sample(grand_sample, nrow(matrix1), replace = T)
        set.seed(index2[i])
        blubb2 = sample(grand_sample, nrow(matrix2), replace = T)
        
        tVector[i] = as.numeric(FUN(blubb1,blubb2, "two.sided", var.equal = var.equal)[1])
      }
      
      t_mean = mean(as.numeric(tVector),na.rm = TRUE)
      t_sd = sd(as.numeric(tVector))
      
      ninetyfive_percentile = quantile(tVector, c(.025, .975), na.rm = TRUE)
      
      if (t_value<t_mean){
        p_value = length(which(tVector<t_value))/n
        } else {
        p_value = length(which(tVector>t_value))/n}
      
      p_value = p_value*2
      
      blubb3 = t(t(c(p_value, t_value, df, t_mean, t_sd, c(as.numeric(ninetyfive_percentile[1]), as.numeric(ninetyfive_percentile[2])))))
        t[, j] = blubb3
  }
  
  t = round(data.frame(t), digits = 4)
  rownames(t) = c("p-value", "t-value", "df", "mean", "sd", "lower bound 95% interval", "upper bound 95% interval")
  colnames(t) <- colnames(matrix1)
  return(t)
}
