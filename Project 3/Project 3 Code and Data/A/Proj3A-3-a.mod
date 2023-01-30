# Project 3 Part A-3-a Mod file
# Sets:
set I; # Segments

# Parameters:
param Cap; # Total amount of tickets available given venue capacity
param D{I}; # Max demand/intercept (p = 0) for segment i
param S{I}; # Slope for segment i (How much does the demand falls for a marginal increase in p)

# Decision Variables:
var Q{I} >= 0; # Demand from segment i
var P{I} >= 0; # Price for segment i


# Objective function:
maximize revenue:
	sum{i in I}Q[i]*P[i];
	
# Constraints:
Capconstraint: # Total amount of tickets sold cannot be greater than the available quantity
	sum{i in I}Q[i] <= Cap;

minimumtickets_General: # Segment "General" must make up least 20% of the venue capacity.
	Q["General"] >= 0.2*Cap;	

minimumtickets_Students_and_Seniors: # The segments students and seniors must make up least 20% of the venue capacity.
	Q["Students"] + Q["Seniors"] >= 0.2*Cap;	

demandconstraint{i in I}: # Tickets sold to segment i cannot be higher than the demand from the segment at price i
	Q[i] <= D[i] + S[i]*P[i];

priceconstraint:
	P["Students"] = P["Seniors"];
