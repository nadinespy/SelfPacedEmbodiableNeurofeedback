# This script performs null hypothesis significance testing with bootstrapping: 
# ANOVAs for mixed effects models and t-tests for differences in means between groups and correlations.

# load functions
setwd("/mydir/scripts/offline_analysis/statistical_testing/")

source("bootstrap_t_distribution.R")
source("bootstrap_t_cor_distribution.R")
source("bootstrap_two_way_rm_anova.R")

# load table
myData = read.csv("/mydir/analysis/data_aggregation_and_boxplots/myData.csv", header = TRUE)

# set path for saving files
setwd("/mydir/analysis/statistical_testing/")

# --------------------------------------------------------------------------------------------------------------
# mixed effects linear model: repeated measurements anova

# grouping variables for SoO, SoA, ER, MIAB, ERDs, movements in "rest vs. move task"
group = t(t(c(matrix(0,9), matrix(1,9), matrix(0,9), matrix(1,9))))
phase = t(t(c(matrix(1, 18), matrix(0, 18))))
id = t(t(c(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18)))

# SoO
SoO = t(t(c(myData$SoOtr,myData$SoOfb)))
rm_anova_SoO_bootstrap = bootstrap_two_way_rm_anova(SoO, group, phase, id)
save(rm_anova_SoO_bootstrap,file="rm_anova_SoO_bootstrap.Rda")

# SoA
SoA = t(t(c(myData$SoAtr,myData$SoAfb)))
rm_anova_SoA_bootstrap = bootstrap_two_way_rm_anova(SoA, group, phase, id)
save(rm_anova_SoA_bootstrap,file="rm_anova_SoA_bootstrap.Rda")

# MIAB
MIAB = t(t(c(myData$MIABtr,myData$MIABfb)))
rm_anova_MIAB_bootstrap = bootstrap_two_way_rm_anova(MIAB, group, phase, id)
save(rm_anova_MIAB_bootstrap,file="rm_anova_MIAB_bootstrap.Rda")

# ER
ER = t(t(c(myData$ERtr,myData$ERfb)))
rm_anova_ER_bootstrap = bootstrap_two_way_rm_anova(ER, group, phase, id)
save(rm_anova_ER_bootstrap,file="rm_anova_ER_bootstrap.Rda")

# movements in "rest vs. move task"
MoveRest = t(t(c(myData$rmMovementsInRest,myData$rmMovementsInMove)))
rm_anova_MoveRest_bootstrap = bootstrap_two_way_rm_anova(MoveRest, group, phase, id)
save(rm_anova_MoveRest_bootstrap,file="rm_anova_MoveRest_bootstrap.Rda")

# ERDs
ERD = t(t(c(myData$ERDtrainFuni,myData$ERDtrainEuni)))
rm_anova_ERD_bootstrap = bootstrap_two_way_rm_anova(ERD, group, phase, id)
save(rm_anova_ERD_bootstrap,file="rm_anova_ERD_bootstrap.Rda")

# grouping variables for feedback and training accuracies
task = t(t(c(matrix(1, 18), matrix(0, 18), matrix(2, 18))))
group = t(t(c(matrix(0,9), matrix(1,9), matrix(0,9), matrix(1,9), matrix(0,9), matrix(1,9))))
id = t(t(c(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18)))

# feedback accuracies 
fb_accuracies = t(t(c(myData$FArm_ALL, myData$FAfc_ALL,myData$FAan_ALL)))
rm_anova_fb_accuracies_bootstrap = bootstrap_two_way_rm_anova(fb_accuracies, group, task, id)
save(rm_anova_fb_accuracies_bootstrap,file="rm_anova_fb_accuracies_bootstrap.Rda")

# training accuracies
ta_accuracies = t(t(c(myData$TAof, myData$TAce, myData$TAef)))
rm_anova_ta_accuracies_bootstrap = bootstrap_two_way_rm_anova(tr_accuracies, group, task, id)
save(rm_anova_ta_accuracies_bootstrap,file="rm_anova_ta_accuracies_bootstrap.Rda")

# --------------------------------------------------------------------------------------------------------------
# differences in means: t-tests

# ERD latencies
test_latency_bootstrap = bootstrap_t_distribution(t(t(myData$ERDlatency[1:9])), t(t(myData$ERDlatency[10:18])), t.test, var.equal = TRUE)
save(test_latency_bootstrap,file="test_latency_bootstrap.Rda")

# CSP criteria
test_CSPfilters_bootstrap = bootstrap_t_distribution(t(t(myData$CSPcriteria[1:9])), t(t(myData$CSPcriteria[10:18])), t.test, var.equal = TRUE)
save(test_CSPfilters_bootstrap,file="test_CSPfilters_bootstrap.Rda")

# feedback accuracies from "rest vs. move task" and "follow commands task"
test_rm_fc_bootstrap = bootstrap_t_distribution(t(t(myData$FArm_ALL)), t(t(myData$FAfc_ALL)), t.test, var.equal = TRUE)
save(test_rm_fc_bootstrap,file="test_rm_fc_bootstrap.Rda")

# feedback accuracies from "rest vs. move task" and "announce commands task"
test_rm_an_bootstrap = bootstrap_t_distribution(t(t(myData$FArm_ALL)), t(t(myData$FAan_ALL)), t.test, var.equal = TRUE)
save(test_rm_an_bootstrap,file="test_rm_an_bootstrap.Rda")

# feedback accuracies from "announce commands" and "follow commands task"
test_an_fc_bootstrap = bootstrap_t_distribution(t(t(myData$FAan_ALL)), t(t(myData$FAfc_ALL)), t.test, var.equal = TRUE)
save(test_an_fc_bootstrap,file="test_an_fc_bootstrap.Rda")

# movements from "rest vs. move task"
test_rm_bootstrap = bootstrap_t_distribution(t(t(myData$rmMovementsInRest)), t(t(myData$rmMovementsInMove)), t.test, var.equal = TRUE)
save(test_rm_bootstrap,file="test_rm_bootstrap.Rda")

# training accuracies for "closed vs. extension classifier" and "open vs. flexion classifier"
test_ce_of_bootstrap = bootstrap_t_distribution(t(t(myData$TAce)), t(t(myData$TAof)), t.test, var.equal = TRUE)
save(test_ce_of_bootstrap,file="test_ce_of_bootstrap.Rda")

# training accuracies for "closed vs. extension classifier" and "extension vs. flexion classifier"
test_ce_ef_bootstrap = bootstrap_t_distribution(t(t(myData$TAce)), t(t(myData$TAef)), t.test, var.equal = TRUE)
save(test_ce_ef_bootstrap,file="test_ce_ef_bootstrap.Rda")

# # training accuracies for "extension vs. flexion classifier" and "open vs. flexion classifier" 
test_ef_of_bootstrap = bootstrap_t_distribution(t(t(myData$TAef)), t(t(myData$TAof)), t.test, var.equal = TRUE)
save(test_ef_of_bootstrap,file="test_ef_of_bootstrap.Rda")

# effect sizes for training accuracies
mean_of = mean(myData$TAof)
var_of = var(myData$TAof)
mean_ce = mean(myData$TAce)
var_ce = var(myData$TAce)
mean_ef = mean(myData$TAef)
var_ef = var(myData$TAef)

# difference "open vs. flexion classifier" - "extension vs. flexion classifier"
d1 <- abs(mean_of-mean_ef) / sqrt(mean(var_of+var_ef))

# difference "closed vs. extension classifier" - "extension vs. flexion classifier"
d2 <- abs(mean_ce-mean_ef) / sqrt(mean(var_ce+var_ef))

# -------------------------------------------------------------------------------------------------------------
# correlations

# pooling training and feedback phase for correlations between phenomenological contructs
SoO = t(t(c(myData$SoOtr, myData$SoOfb)))
SoA = t(t(c(myData$SoAtr, myData$SoAfb)))
ER = t(t(c(myData$ERtr, myData$ERfb)))
MIAB = t(t(c(myData$MIABtr, myData$MIABfb)))

test_cor_SoO_SoA_bootstrap = bootstrap_t_cor_distribution(SoO, SoA, "pearson")
save(test_cor_SoO_SoA_bootstrap,file="test_cor_SoO_SoA_bootstrap.Rda")
test_cor_SoO_ER_bootstrap = bootstrap_t_cor_distribution(SoO, ER, "pearson")
save(test_cor_SoO_ER_bootstrap,file="test_cor_SoO_ER_bootstrap.Rda")
test_cor_SoO_MIAB_bootstrap = bootstrap_t_cor_distribution(SoO, MIAB, "pearson")
save(test_cor_SoO_MIAB_bootstrap,file="test_cor_SoO_MIAB_bootstrap.Rda")

test_cor_SoA_ER_bootstrap = bootstrap_t_cor_distribution(SoA, ER, "pearson")
save(test_cor_SoA_ER_bootstrap,file="test_cor_SoA_ER_bootstrap.Rda")
test_cor_SoA_MIAB_bootstrap = bootstrap_t_cor_distribution(SoA, MIAB, "pearson")
save(test_cor_SoA_MIAB_bootstrap,file="test_cor_SoA_MIAB_bootstrap.Rda")

test_cor_ER_MIAB_bootstrap = bootstrap_t_cor_distribution(ER, MIAB, "pearson")
save(test_cor_ER_MIAB_bootstrap,file="test_cor_ER_MIAB_bootstrap.Rda")

# R-squared
SoO_SoA_Rsquared = test_cor_SoO_SoA_bootstrap[[1]]^2
SoO_ER_Rsquared = test_cor_SoO_ER_bootstrap[[1]]^2
SoO_MIAB_Rsquared = test_cor_SoO_MIAB_bootstrap[[1]]^2
SoA_ER_Rsquared = test_cor_SoA_ER_bootstrap[[1]]^2
SoA_MIAB_Rsquared = test_cor_SoA_MIAB_bootstrap[[1]]^2
ER_MIAB_Rsquared = test_cor_ER_MIAB_bootstrap[[1]]^2

# correlations between phenomenological contructs from training and training accuracies
test_cor_SoA_TR_bootstrap = bootstrap_t_cor_distribution(t(t(myData$SoAtr)), t(t(myData$mean_of_ce_ef)), "pearson")
save(test_cor_SoA_TR_bootstrap,file="test_cor_SoA_TR_bootstrap.Rda")
test_cor_SoO_TR_bootstrap = bootstrap_t_cor_distribution(t(t(myData$SoOtr)), t(t(myData$mean_of_ce_ef)), "pearson")
save(test_cor_SoO_TR_bootstrap,file="test_cor_SoO_TR_bootstrap.Rda")
test_cor_ER_TR_bootstrap = bootstrap_t_cor_distribution(t(t(myData$mean_of_ce_ef)), t(t(myData$ERtr)), "pearson")
save(test_cor_ER_TR_bootstrap,file="test_cor_ER_TR_bootstrap.Rda")
test_cor_MIAB_TR_bootstrap = bootstrap_t_cor_distribution(t(t(myData$mean_of_ce_ef)), t(t(myData$MIABtr)), "pearson")
save(test_cor_MIAB_TR_bootstrap,file="test_cor_MIAB_TR_bootstrap.Rda")

# R-squared
SoO_TR_Rsquared = test_cor_SoO_TR_bootstrap[[1]]^2
SoA_TR_Rsquared = test_cor_SoA_TR_bootstrap[[1]]^2
ER_TR_Rsquared = test_cor_ER_TR_bootstrap[[1]]^2
MIAB_TR_Rsquared = test_cor_MIAB_TR_bootstrap[[1]]^2

# correlations between phenomenological contructs from feedback and feedback accuracies
test_cor_SoA_FB_bootstrap = bootstrap_t_cor_distribution(t(t(myData$SoAfb)), t(t(myData$mean_fc_ac_rm)), "pearson")
save(test_cor_SoA_FB_bootstrap,file="test_cor_SoA_FB_bootstrap.Rda")
test_cor_SoO_FB_bootstrap = bootstrap_t_cor_distribution(t(t(myData$SoOfb)), t(t(myData$mean_fc_ac_rm)), "pearson")
save(test_cor_SoO_FB_bootstrap,file="test_cor_SoO_FB_bootstrap.Rda")
test_cor_ER_FB_bootstrap = bootstrap_t_cor_distribution(t(t(myData$mean_fc_ac_rm)), t(t(myData$ERfb)), "pearson")
save(test_cor_ER_FB_bootstrap,file="test_cor_ER_FB_bootstrap.Rda")
test_cor_MIAB_FB_bootstrap = bootstrap_t_cor_distribution(t(t(myData$mean_fc_ac_rm)), t(t(myData$MIABfb)), "pearson")
save(test_cor_MIAB_FB_bootstrap,file="test_cor_MIAB_FB_bootstrap.Rda")

# R-squared
SoO_FB_Rsquared = test_cor_SoO_FB_bootstrap[[1]]^2
SoA_FB_Rsquared = test_cor_SoA_FB_bootstrap[[1]]^2
ER_FB_Rsquared = test_cor_ER_FB_bootstrap[[1]]^2
MIAB_FB_Rsquared = test_cor_MIAB_FB_bootstrap[[1]]^2
