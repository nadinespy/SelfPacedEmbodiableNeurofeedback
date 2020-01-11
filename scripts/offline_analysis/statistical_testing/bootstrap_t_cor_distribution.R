# calculatig correlations between all variables contained in two matrices of any size, 
# including significance testing with bootstrapping;

# input: two numeric matrices (or column vectors) in dataframe format, where each column denotes a variable, 
# type of correlation (e. g. "pearson").
# output: matrix of size number of variables in first matrix times number of variables in second matrix 
# times 8 (p-value, bootstrap p-value, test-statistic, bootstrap mean, sd, lower & upper bound in the 
# 95% cofidence interval (all in third dimension of matrix)).

bootstrap_t_cor_distribution <- function(matrix1, matrix2, cortype){
  
  t_corVector = numeric()
  corVector = numeric()
  
  tCOR = array(1, dim=c(dim(matrix1)[2], dim(matrix2)[2],8))
  dimnames(tCOR)[[1]] <- colnames(matrix1)
  dimnames(tCOR)[[2]] <- colnames(matrix2) 
  dimnames(tCOR)[[3]] <- c("cor", "p-value", "bootstrap p-value", "test-statistic", "mean", "sd", "lower bound 95% interval", "upper bound 95% interval")

  for (j in 1:dim(matrix1)[2]){
    for (k in 1:dim(matrix2)[2]){
      
      cor = cor(matrix1[,j],matrix2[,k], use = "pairwise.complete.obs", cortype)
      t_cor = as.numeric(cor.test(matrix1[,j],matrix2[,k], "two.sided", cortype, 0.95)[1])
      p_cor = as.numeric(cor.test(matrix1[,j],matrix2[,k], "two.sided", cortype, 0.95)[3])
      
      index = numeric()
      set.seed(10)
      index = sample(1:100000,3000,replace=T)
      
      for (i in 1:3000) {

        blubb1 = matrix1[,j]
        set.seed(index[i])
        blubb2 = sample(matrix2[,k])
        
        corVector[i] = cor(blubb1,blubb2, use = "pairwise.complete.obs", cortype)
        t_corVector[i] = as.numeric(cor.test(blubb1,blubb2, "two.sided", cortype, 0.95)[1])
      }
      
      n = 3000

      t_cor_mean = mean(as.numeric(t_corVector),na.rm = TRUE)
      t_cor_sd = sd(as.numeric(t_corVector))
      
      ninetyfive_percentile = quantile(t_corVector, c(.025, .975), na.rm = TRUE)
      
      if (t_cor<t_cor_mean){
        bootstrap_p_cor = length(which(t_corVector<t_cor))/n
      } else {
        bootstrap_p_cor = length(which(t_corVector>t_cor))/n}
      
      bootstrap_p_cor = bootstrap_p_cor*2
      
      blubb3 = round(t(t(c(cor, p_cor, bootstrap_p_cor, t_cor, t_cor_mean, t_cor_sd, c(as.numeric(ninetyfive_percentile[1]), as.numeric(ninetyfive_percentile[2]))))), digits = 4)
      tCOR[j, k,] = blubb3
    }
  }
  
  tCOR <- list(tCOR[,,1], tCOR[,,2], tCOR[,,3], tCOR[,,4], tCOR[,,5], tCOR[,,6], tCOR[,,7], tCOR[,,8])
  return(tCOR)
}

