# SPM PUMA Estimates
Project uses an information theoretic model to refine ACS SPM PUMA-level estimates. 

This project uses both STATA and Python. STATA programs were used to clean and prep the microdata, and compile needed aggregate estimates by geography. The information theoretic model is a maximum entropy one and produced in Python. In this Python code, for each state in the U.S., the program (1) imports a smaller dataset produced by the previously noted STATA program, (2) runs the maximum entropy optimization problem to produce the estimates of interest, and (3) and exports the estimates of interest. The exports from Python are then assembled in STATA, where all corresponding analyses are done.
