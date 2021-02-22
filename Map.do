**Need to run geo2xy.ado, spmap.ado, spmap_color.ado, spmap_psl.ado shp2dta.ado and mif2dta.ado files before you run this program

/*The programs/ado files were found here: 
spmap: http://fmwww.bc.edu/RePEc/bocode/s/spmap.ado
shp2dta: http://fmwww.bc.edu/RePEc/bocode/s/shp2dta.ado
mif2dta: http://fmwww.bc.edu/RePEc/bocode/m/mif2dta.ado
...*/

/*Need to download the geo2xy files (for the U.S.) accordingly 
https://econpapers.repec.org/software/bocbocode/s457990.htm
and then.... */

/*Use the shape files to create (1) a database, usdb, and (2) a coordinate dataset, uscoord.*/ 
//shp2dta using tl_2017_us_state, data(usdb) coord(uscoord) genid(id)

clear all 
ssc install geo2xy

use "E:\Summer2019Project\Map\geo2xy_us_coor.dta", clear

// flip longitudes to reconnect Hawaii and Alaska
replace _X = cond(_X > 0, _X - 180, _X + 180) if inlist(_ID, 14, 42)

// Alaska - USGS recommends standard parallels of 55 and 65 north
sum _X if _ID == 14
local midlon = (r(min) + r(max)) / 2
geo2xy _Y _X if _ID == 14, replace ///
proj(albers, 6378137 298.257223563 55 65 0 `midlon')
replace _Y = _Y / 3 + 800000 if _ID == 14
replace _X = _X / 3 - 1700000 if _ID == 14

// Hawaii - USGS recommends standard parallels of 8 and 18 north
sum _X if _ID == 42
local midlon = (r(min) + r(max)) / 2
geo2xy _Y _X if _ID == 42, replace ///
proj(albers, 6378137 298.257223563 8 18 0 `midlon')
replace _Y = _Y / 1.2 + 850000 if _ID == 42
replace _X = _X / 1.2 - 800000 if _ID == 42

// Puerto Rico
geo2xy _Y _X if _ID == 39, replace proj(albers)
replace _Y = _Y + 500000 if _ID == 39
replace _X = _X + 2000000 if _ID == 39

// 48 states - USGS recommends standard parallels of 29.5 and 45.5 north
sum _X if !inlist(_ID, 14, 42, 39)
local midlon = (r(min) + r(max)) / 2
geo2xy _Y _X if !inlist(_ID, 14, 42, 39), replace ///
proj(albers, 6378137 298.257223563 29.5 45.5 0 `midlon')

save "E:\Summer2019Project\Map\xy_coor.dta", replace

use "E:\Summer2019Project\Map\geo2xy_us_data.dta",clear

	*gen id variable for later merging*
	//sort NAME 
	//drop if STATEFP == "72"
	//gen id = _n 
	//save "E:\Summer2019Project\Map\geo2xy_us_data.dta", replace

//ssc install spmap

*Old command for old version of STATA 15
//spmap using "E:\Summer2019Project\Map\xy_coor.dta", id(_ID)  name(fun_composite, replace)

//Just map of the US- check 
grmap using "E:\Summer2019Project\Map\xy_coor.dta", id(_ID)  name(fun_composite, replace)

********************************************************************************
