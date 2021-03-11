# SPM PUMA Estimates
Project uses an information theoretic model to refine ACS SPM PUMA-level estimates. 

This project uses both STATA and Python. A STATA program cleans and preps the microdata. Aggregate estmates are compiled from each survey (ACS and CPS-ASEC) by geography. The information theoretic model is a maximum entropy one and produced in Python. For each state in the U.S., the Python program (1) imports a smaller dataset produced by the previously noted STATA program, (2) runs the maximum entropy optimization problem to produce the estimates of interest, and (3) and exports the estimates of interest. The exports from Python are then used in STATA to perform all subsequent analyses.
