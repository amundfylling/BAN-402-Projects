# Part C model for task 3
set R; 						 # Set of regions
set P; 						 # Set of ports
set K; 						 # Set of markets

param demand{K}; 			 # demand in 1000 kg of apples in market K
param shipping_r{R, P}; 	 # cost of shipping 1000kg of apples from region r to port p
param shipping_p{P, K}; 	 # cost of shipping 1000kg of apples from port p to market k
param shipping_d{R, K}; 	 # cost of shipping 1000kg of apples directly from region r to market k
param limit{R}; 			 # Supply limit for region r in 1000kgs
param satisfaction_share{K}; # Minimum satisfaction share required for each market.

var x{R,P} >= 0; 			 # amount in 1000kg shipped from region r to port p
var y{P,K} >= 0; 			 # amount in 1000kg shipped from port p to market k
var z{R,K} >= 0; 			 # amount in 1000kg shipped from region r to market k 

minimize total_cost: 		 # minimize cost function
	sum{r in R, p in P}shipping_r[r,p]*x[r,p] +
	sum{p in P, k in K}shipping_p[p,k]*y[p,k] +
	sum{r in R, k in K}shipping_d[r,k]*z[r,k]
	;

subject to

continuity{p in P}: 		 # Everything that exits P must equal everything that enters
	sum{r in R}x[r,p] = sum{k in K}y[p,k];

requirement{k in K}: 		 # The sum of what enters the market must at least equal the demand
	sum{p in P}y[p,k] + sum{r in R}z[r,k] >= demand[k]*satisfaction_share[k];

obtainable_maximum{r in R}:  # the sum of what exits region r cannot be greater than the supply limit
	sum{p in P}x[r,p] + sum{k in K}z[r,k] <= limit[r]

