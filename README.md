# Exploring Self-Paced Embodiable Neurofeedback for Post-stroke Motor Rehabilitation
&nbsp;

These are the scripts for the paper "Exploring Self-Paced Embodiable Neurofeedback for Post-stroke Motor Rehabilitation." Please cite it, if you use code from this repository.
&nbsp;

Spychala, N., Debener, S., Bongartz, E., Müller, H. H. O., Philipsen, A., Thorne, J.,
& Braun, N. (2019). Exploring Self-Paced Embodiable Neurofeedback for Post-
Stroke Motor Rehabilitation. Frontiers in Neuroscience.
&nbsp;

## Online analysis
Scripts used for experiments, need to be run in the given order:

1. **TRAIN.m** <br /> 
script for the training block, <br />
required packages/files: 
    + BCILAB-1.1 
    + lsl_loadlib.m
    + lsl_outlet.m
    + lsl_streaminfo.m <br />
&nbsp;

2. **onlineAnalysisMultipleClassifier.m** <br />
script for training a predictive model and deriving training accuracies for the training block, <br />
required packages/files: 
    + BCILAB-1.1
    + eeglab13_4_4b <br />
&nbsp;

3. **runClassifier.m** <br />
script for loading the trained model for the training block, <br />
required packages/files: 
    + BCILAB-1.1 <br />
&nbsp;

4. **runFSA.m** <br />
script for ensemble-classification algorithm in the feedback bock, <br />
required packages/files: 
    + BCILAB-1.1<br />
&nbsp;

## Offline analysis
Scripts used for analysis after experiments (scripts of each subsection run independently, except for "Data aggregation & boxplots" and "Statistical testing," which require that scripts of all other subsections have run before):

### Time-frequency analysis
Scripts need to be run in the given order.

1. **preprocessingICA.m** <br />
script for conducting ICA on data from training block, <br />
required packages/files: 
    + eeglab13_4_4b
    + eeg_load_xdf.m (eeglab plugin)
    + pop_firws.m (eeglab plugin) 
    + niclas_mobile24_proper_labels.elp (should be contained in auxiliaries) <br />
&nbsp;

2. **selectionCSP.m** <br />
script for calculating CSP filters on data from training block, <br />
required packages/files: 
    + eeglab13_4_4b 
    + pop_firws (eeglab plugin) 
    + cov_shrink.m (should be contained in auxiliaries) 
    + eqTrials.m (should be contained in auxiliaries) 
    + getERD.m (should be contained in auxiliaries) 
    + tilefigs.m (should be contained in auxiliaries) <br />
&nbsp;

3. **time_frequency_analysis.m** <br />
script for conducting time-frequency analysis on data from training block, <br />
required packages/files: 
    + eeglab13_4_4b 
    + suptitle.m (should be contained in auxiliaries) 
    + plotWavelet2.m (should be contained in auxiliaries) 
    + jt_st_wave.m (should be contained in auxiliaries) 
    + vline.m (should be contained in auxiliaries) <br />
&nbsp;

### Classification accuracies
&nbsp;

#### Training accuracies

* **training_accuracies.m** <br />
script for extracting training accuracies of the training block
&nbsp;

&nbsp;

#### Feedback accuracies
Scripts need to be run in the given order.

1. **extract_EEG_data_according_to_tasks.m** <br />
script for extracting EEG data from the feedback block accordings to tasks, <br />
required packages/files: 
    + eeglab13_4_4b 
    + eeg_load_xdf.m (eeglab plugin) <br />
&nbsp;

2. **performanceAnalysis_generateANNOUNCE.m** <br />
**performanceAnalysis_generateCOMMAND.m** <br />
**performanceAnalysis_generateRM.m** <br />
scripts for imposing a trial structure on the data from tasks of the feedback block (order does not matter), <br />
required packages/files:
    + eeglab13_4_4b <br />
&nbsp;

3. **performanceAnalysis_successANNOUNCE.m** <br />
**performanceAnalysis_successCOMMAND.m** <br />
**performanceAnalysis_successRM.m** <br />
scripts for deriving success rates for the trials in tasks from the feedback block (order does not matter), <br />
required packages/files:  
    + eeglab13_4_4b (for all)
    + find_command_index_ranges.m (for all but performanceAnalysis_successRM.m, contained in auxiliaries) 
    + find_command_pattern_in_range.m (for all but performanceAnalysis_successRM.m, contained in auxiliaries) <br />
&nbsp;

4. **save_all_successes_and_failures_in_one_table.m**  <br />
script for agglomerating successes and failures from all tasks
&nbsp;

5. **get_trial_frequencies.m**  <br />
script for calculating the number of trials for commands
&nbsp;

6. **get_chance_level.m**  <br />
script for evaluating chance levels for the feedback accuracies
&nbsp;

7. **extract_number_of_RMmovements.m**  <br />
script for extracting RH movements in "rest vs. move task" 
&nbsp;

&nbsp;

### Subjective ratings

* **FCQdata_contr.m** <br />
script for calculating assessing the four phenomenological constructs for control subjects
&nbsp;

* **FCQdata_stroke.m** <br />
script for calculating assessing the four phenomenological constructs for stroke patients
&nbsp;

&nbsp;

### Data aggregation & boxplots
Scripts need to be run in the given order.

1. **organize_data_for_agregation.m** <br />
script for aggregating output files from various scripts
&nbsp;

2. **aggregate_data.m** <br />
script for further aggregation
&nbsp;

3. **boxplots.m** <br />
script for plotting boxplots
&nbsp;

&nbsp;

### Statstical testing
Scripts need to be run in the given order.

1. **check_distribution_and_variance.m** <br />
script for checking normality and variance homogeneity of the data
&nbsp;

2. **NHST.R** <br />
script for conducting null hypothesis significance testing
&nbsp;
