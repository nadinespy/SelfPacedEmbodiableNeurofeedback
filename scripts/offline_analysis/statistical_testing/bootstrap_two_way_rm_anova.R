# two-way repeated measures mixed-effects anova for comparing means, for either two or three levels in the within-subjects factor

# input: response variable, between-subjects factor, within-subjects factor and indices for subjects (all as column vectors);
# within-subjects factor has to be provided in an ordering way.
# output: usual output as given by anova(), but with bootstrap p-values instead.

# example: sample of 9 patients and 9 controls (between-subjects factor "group"), two experimental conditions per subject (within-subjects factor "phase").
# group = t(t(c(matrix(0,9), matrix(1,9), matrix(0,9), matrix(1,9))))
# phase = t(t(c(matrix(1, 18), matrix(0, 18))))
# id = t(t(c(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18)))


bootstrap_two_way_rm_anova <- function(response_variable, between_subjects_factor, within_subjects_factor, id){
  
  rm_anova = anova(lme(response_variable ~ between_subjects_factor*within_subjects_factor, random=~1 | id, method="ML"))  # delivers same result as rm anova in SPSS
  
  FValue_between_subjects_factor = rm_anova[2,3]
  FValue_within_subjects_factor = rm_anova[3,3]
  FValue_interaction = rm_anova[4,3]
  pValue_between_subjects_factor = rm_anova[2,4]
  pValue_within_subjects_factor = rm_anova[3,4]
  pValue_interaction = rm_anova[4,4]
  
  FVector_between_subjects_factor = numeric()
  pVector_between_subjects_factor = numeric()
  FVector_within_subjects_factor = numeric()
  pVector_within_subjects_factor = numeric()
  FVector_interaction = numeric()
  pVector_interaction = numeric()
  
  n = 3000
  
  index1 = numeric()
  set.seed(10)
  index1 = sample(1:100000,3000,replace=T)
  index2 = numeric()
  set.seed(20)
  index2 = sample(1:100000,3000,replace=T)
  
  number_of_levels = length(seq(range(within_subjects_factor)[1], range(within_subjects_factor)[2],by=1))
  split = nrow(response_variable)/number_of_levels
  
  if (number_of_levels ==3){
    mean1 = mean(response_variable[1:split])
    mean2 = mean(response_variable[(split+1):(split*2)])
    mean3 = mean(response_variable[(split*2+1):(split*3)])
    
    response_variable[1:split] = response_variable[1:split]-mean1
    response_variable[(split+1):(split*2)] = response_variable[(split+1):(split*2)]-mean2
    response_variable[(split*2+1):(split*3)] = response_variable[(split*2+1):(split*3)]-mean3
  } else {
    mean1 = mean(response_variable[1:split])
    mean2 = mean(response_variable[(split+1):(split*2)])
    
    response_variable[1:split] = response_variable[1:split]-mean1
    response_variable[(split+1):(split*2)] = response_variable[(split+1):(split*2)]-mean2
  }
  
  for (i in 1:n){
    
    if (number_of_levels ==3){
      sample_from_third_level = sample(response_variable[(split*2+1):(split*3)], split, replace = T)  
      set.seed(index1[i])
      sample_from_first_level = sample(response_variable[1:split], split, replace = T)
      set.seed(index1[i])
      sample_from_second_level = sample(response_variable[(split+1):(split*2)], split, replace = T)
    } else {
      set.seed(index1[i])
      sample_from_first_level = sample(response_variable[1:split], split, replace = T)
      set.seed(index1[i])
      sample_from_second_level = sample(response_variable[(split+1):(split*2)], split, replace = T)
    }
    set.seed(index2[i])
    sample_between_subjects_factor = t(t(sample(between_subjects_factor, nrow(between_subjects_factor), replace = T)))
    
    if (number_of_levels ==3){
      concatenate_samples = rbind(t(t(sample_from_first_level)),t(t(sample_from_second_level)), t(t(sample_from_third_level)))
    } else {concatenate_samples = rbind(t(t(sample_from_first_level)),t(t(sample_from_second_level)))
    }
    
    rm_anova_simulation = anova(lme(concatenate_samples ~ sample_between_subjects_factor*within_subjects_factor, random=~1 | id, method="ML", control=lmeControl(singular.ok=TRUE)))  # delivers same result as rm anova in SPSS
    
    FVector_between_subjects_factor[i] = as.numeric(rm_anova_simulation[2,3])
    FVector_within_subjects_factor[i] = as.numeric(rm_anova_simulation[3,3])
    FVector_interaction[i] = as.numeric(rm_anova_simulation[4,3])
    
    pVector_between_subjects_factor[i] = as.numeric(rm_anova_simulation[2,4])
    pVector_within_subjects_factor[i] = as.numeric(rm_anova_simulation[3,4])
    pVector_interaction[i] = as.numeric(rm_anova_simulation[4,4])
  }
  
  # bootstrap p-value for between-subjects factor
  bootstrap_pValue_between_subjects_factor = length(which(FVector_between_subjects_factor>FValue_between_subjects_factor))/n
  
  # bootstrap p-value for within-subjects factor
  bootstrap_pValue_within_subjects_factor = length(which(FVector_within_subjects_factor>FValue_within_subjects_factor))/n
  
  # bootstrap p-value for interaction
  bootstrap_pValue_interaction = length(which(FVector_interaction>FValue_interaction))/n
  
  
  FValues = rbind(FValue_between_subjects_factor, FValue_within_subjects_factor, FValue_interaction)
  bootstrap_pValues = rbind(bootstrap_pValue_between_subjects_factor, bootstrap_pValue_within_subjects_factor, bootstrap_pValue_interaction)
  
  rm_anova[2:nrow(rm_anova), "p-value"] = bootstrap_pValues
  return(rm_anova)
}
