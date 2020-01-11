For the experiment, BCILAB-1.1 (https://sccn.ucsd.edu/wiki/BCILAB) was used. 

However, a few changes had to be made to original BCILAB package:
In order to replace BCILABS automatic (i.e. artifact-blind) CSP calculation procedure by our own semi-automatic CSP calculation procedure
and in order to be able to use our lab-internal eeg 24 channel layout, a few minor changes had to be done in the two following scripts:

- ...\BCILAB-1.1\code\paradigms\ParadigmCSP.m
- ...\BCILAB-1.1\code\dataset_editing\set_infer_chanlocs.m

In addition, the two channel location files 59_Niclas_equidistant_selection.xyz and niclas_mobile24.xyz
had to be added to the folder ...\BCILAB-1.1\resources 

The modified scripts and channel layouts are contained within this folder.