# Exploring Self-Paced Embodiable Neurofeedback for Post-stroke Motor Rehabilitation

These are the scripts for the paper "Exploring Self-Paced Embodiable Neurofeedback for Post-stroke Motor Rehabilitation." Please cite it, if you use code from this repository.

Spychala, N., Debener, S., Bongartz, E., Müller, H. H. O., Philipsen, A., Thorne, J.,
& Braun, N. (2019). Exploring Self-Paced Embodiable Neurofeedback for Post-
Stroke Motor Rehabilitation. Frontiers in Neuroscience.

## Online analysis
Scripts used for experiments

TRAIN.m
  required packages/files: 
    BCILAB-1.1 
    lsl_loadlib.m
    lsl_outlet.m
    lsl_streaminfo.m

onlineAnalysisMultipleClassifier.m
  required packages/files: 
    BCILAB-1.1
    eeglab13_4_4b

runClassifier.m
  required packages/files: 
    BCILAB-1.1 

runFSA.m
  required packages/files: 
    BCILAB-1.1

## Offline analysis
Scripts used for analysis after experiments

### Time-frequency analysis
Scripts need to be run in the given order.

1. preprocessingICA.m <br />
&nbsp;&nbsp;required packages/files: <br />
&nbsp;&nbsp;&nbsp;&nbsp;eeglab13_4_4b <br />
&nbsp;&nbsp;&nbsp;&nbsp;eeg_load_xdf.m (eeglab plugin) <br />
&nbsp;&nbsp;&nbsp;&nbsp;pop_firws.m (eeglab plugin) <br />
&nbsp;&nbsp;&nbsp;&nbsp;niclas_mobile24_proper_labels.elp (should be contained in auxiliaries) <br />

2. selectionCSP.m <br />
&nbsp;&nbsp;required packages/files: <br />
&nbsp;&nbsp;&nbsp;&nbsp;eeglab13_4_4b <br />
&nbsp;&nbsp;&nbsp;&nbsp;pop_firws (eeglab plugin) <br />
&nbsp;&nbsp;&nbsp;&nbsp;cov_shrink.m (should be contained in auxiliaries) <br />
&nbsp;&nbsp;&nbsp;&nbsp;eqTrials.m (should be contained in auxiliaries) <br />
&nbsp;&nbsp;&nbsp;&nbsp;getERD.m (should be contained in auxiliaries) <br />
&nbsp;&nbsp;&nbsp;&nbsp;tilefigs.m (should be contained in auxiliaries) <br />

3. time_frequency_analysis.m <br />
    required packages/files: <br />
&nbsp;&nbsp;&nbsp;&nbsp;eeglab13_4_4b <br />
&nbsp;&nbsp;&nbsp;&nbsp;suptitle.m (should be contained in auxiliaries) <br />
&nbsp;&nbsp;&nbsp;&nbsp;plotWavelet2.m (should be contained in auxiliaries) <br />
&nbsp;&nbsp;&nbsp;&nbsp;jt_st_wave.m (should be contained in auxiliaries) <br />
&nbsp;&nbsp;&nbsp;&nbsp;vline.m (should be contained in auxiliaries) <br />

### Classification accuracies

#### Training accuracies

training_accuracies.m

#### Feedback accuracies

Scripts need to be run in the given order.

1. extract_EEG_data_according_to_tasks.m <br />
&nbsp;&nbsp;required packages/files: <br />
&nbsp;&nbsp;&nbsp;&nbsp;eeglab13_4_4b <br />
&nbsp;&nbsp;&nbsp;&nbsp;eeg_load_xdf.m (eeglab plugin) <br />

2. performanceAnalysis_generateANNOUNCE.m <br />
&nbsp;required packages/files:<br />
&nbsp;&nbsp;&nbsp;eeglab13_4_4b <br />

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;performanceAnalysis_generateCOMMAND.m <br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;required packages/files:<br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;eeglab13_4_4b <br />

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;performanceAnalysis_generateRM.m <br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;required packages/files: <br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;eeglab13_4_4b <br />

3. performanceAnalysis_successANNOUNCE.m <br />
&nbsp;&nbsp;required packages/files:  <br />
&nbsp;&nbsp;&nbsp;&nbsp;eeglab13_4_4b <br />
&nbsp;&nbsp;&nbsp;&nbsp;find_command_index_ranges.m (contained in auxiliaries) <br />
&nbsp;&nbsp;&nbsp;&nbsp;find_command_pattern_in_range.m (contained in auxiliaries) <br />

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;performanceAnalysis_successCOMMAND.m <br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;required packages/files:<br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;eeglab13_4_4b <br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;find_command_index_ranges.m (contained in auxiliaries) <br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;find_command_pattern_in_range.m (contained in auxiliaries) <br />

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;performanceAnalysis_successRM.m <br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;required packages/files: <br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;eeglab13_4_4b <br />

4. save_all_successes_and_failures_in_one_table.m 
5. get_trial_frequencies.m 
6. get_chance_level.m. 
7. extract_number_of_RMmovements.m

### Subjective ratings

FCQdata_contr.m <br />
FCQdata_stroke.m <br />

### Data aggregation & boxplots

organize_data_for_agregation.m <br />
aggregate_data.m <br />
boxplots.m <br />

### Statstical testing

check_distribution_and_variance.m <br />
NHST.R <br />

