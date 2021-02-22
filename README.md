# Map Files 
In this branch there are STATA ado and dta files for mapping all states in the United States. 

The main do file for mapping is "Map.do", which follows the instructions provided by Robert Picard (picard@netbox.com) and Michael Stepner (michael.stepner@utoronto.ca). The do file produces a map of all U.S. states using cartesian coordinates. The main do file can be used to merge in data of interest that any analyst would like to map. 

For convenience, the ado file for the "geo2xy" command, written by Picard and Stepner, which transforms latitude and longitude coordinates into cartesian ones is provided in this folder. For more details see: https://econpapers.repec.org/software/bocbocode/s457990.htm. 

The "Map.do" optionally calls of additional commands for improving the aesthetic of maps. The ado files for theses commands were written by Maurizio Pisati (maurizio.pisati@unimib.it). 

Additionally, ado files for the "spmap" command are called but unnecessary if user has STATA 16. The release of the "grmap" command in STATA 16, which was adapted by StataCorp using Maurizio's "spmap" command, is a substitute and by default provided in the most recent version of STATA.
