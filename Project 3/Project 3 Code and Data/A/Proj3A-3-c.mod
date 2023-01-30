# Project 3 Part A-3-c Mod file
# Sets:
set I; # Segments

# Parameters:
param Cap; # Total amount of tickets available given venue capacity
param D{I}; # Max demand/intercept (p = 0) for segment i
param S{I}; # Slope for segment i (How much does the demand falls for a marginal increase in p)
param P_MIN; # Minimum price allowed

# Decision Variables:
var Q{I} >= 0; # Demand from segment i
var P{I} >= 0; # Price for segment i


# Objective function:
maximize revenue:
	sum{i in I}Q[i]*P[i];
	
# Constraints:
Capconstraint: # Total amount of tickets sold cannot be greater than the available quantity
	sum{i in I}Q[i] <= Cap;

minimumtickets{i in I}: # # Each segment must make up at least 5% of the venue capacity
	Q[i] >= 0.05*Cap;	

demandconstraint{i in I}: # Tickets sold to segment i cannot be higher than the demand from the segment at price i
	Q[i] <= D[i] + S[i]*P[i];

minimumprice{i in I}: # The price of the tickets must be equal to or higher than the minimum price allowed (C) 
	P[i] >= P_MIN;

priceconstraint{i in I, m in I: i <> m}: # The price for one ticket cannot be twice as large as the price of another
	P[i] <= 2*P[m];

