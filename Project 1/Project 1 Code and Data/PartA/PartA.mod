# Model for Part A
set F; 	# Set of facilities
set P; 	# Set of pollutants

param requirement{P}; 	# Minimum pollution reduction requirement of pollutant p set by the government
param cost{F}; 		 	# Cost of processing one ton fish with the new technology at facility f
param reduction{P, F}; 	# Reduction of pollutant p per ton fish produced at facility f

var x{F} >= 0; 			# Tons produced at each facility

minimize total_cost: 	# Min total cost function
	sum{f in F}cost[f]*x[f];

subject to

restriction{p in P}: 	# Requirement for pollutant reduction
	sum{f in F}x[f]*reduction[p,f] >= requirement[p]
