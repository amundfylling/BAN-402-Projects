# Project 3 Part D Mod file
# Sets:
set I; # Set of locations to install bike racks
set N; # Set of inhabitants in the city

# Parameters:
param c; # Cost of aquiring conventional bikes
param e; # Cost of aquiring electric bikes
param v{I}; # variable cost per bike initially allocated to rack i
param f{I}; # Fixed cost incurred by installing rack i
param d{I,N}; # Distance to location rack i for inhabitant n
param t; # Maximum distance from a location rack to an inhabitant that still qualifies them as a potential user
param epsilon; # Small value used to determine y[i,n] for instances where d[i,n] = t
param M_1; # Big M_1 (Could be the maximum number of bikes allowed on a bike rack)
param M_2; # Big M_2 (Could be the maximum distance from an inhabitant to a bike rack in the dataset) 

# Decision variables:
var B_Conventional{I} integer >= 0; # Number of conventional bikes bought and installed at rack i
var B_Electric{I} integer >= 0; # Number of electric bikes bought and installed at rack i
var x{I} binary; # Takes the value 1 if a bike rack is installed at location i and 0 otherwise
var y{I,N} binary; # Takes the value 1 if inhabitant n is located at most t km from location i 
var b{I,N} binary; # Takes the value 1 if a link is eligible and 0 otherwise
var u{I,N} binary; # Takes the value 1 if a link is eligible and represents the shortest distance among the eligible links
var k{I,N} binary;  # Takes the value 1 if a link is eligible and represents the shortest distance among the eligible links and 0 otherwise.

# Objective function: 
minimize total_budget:
	sum{i in I}(
	B_Conventional[i] * (c + v[i]) +
	B_Electric[i] * (e + v[i]) + 
	x[i] * f[i]
	)
	;
	
# Constraints:
Twoforone{i in I}: # There must be exactly two electric bikes at every rack installed	
	B_Electric[i] = 2*x[i];
	
logic1{i in I}: # Ensures that x takes the value 1 if a bike rack is installed at location i and 0 otherwise
	B_Conventional[i] + B_Electric[i] <= M_1*x[i];

logic2{i in I, n in N}: # Logic 2-3 ensures that y takes the value 1 if d[i,n] <= t and 0 otherwise
	d[i,n] - (t + epsilon) >= (d[i,n]-(t + epsilon))*y[i,n];

logic3{i in I, n in N}:
	(d[i,n]-(t + epsilon))*y[i,n] <= 0;
	
logic4{i in I, n in N}:# Logic 4-6 ensures that b takes the value 1 if a link is eligible and 0 otherwise
	y[i,n] + x[i] <= b[i,n] + 1;

logic5{i in I, n in N}:
	b[i,n] <= x[i];

logic6{i in I, n in N}:
	b[i,n] <= y[i,n];

logic7{i in I, n in N, j in I: i<>j}: # Logic 7-8 ensures that u takes the value 1 if a link is eligible and represents the shortest distance among the eligible links
	b[i,n]*d[j,n]-b[j,n]*d[i,n] >= M_2*(u[i,n]-1);

logic8{n in N}:
	sum{i in I}u[i,n] = 1;

logic9{i in I, n in N}:# Logic 9-11 ensures that k takes the value 1 if a link is eligible and represents the shortest distance among the eligible links
	b[i,n] + u[i,n] <= k[i,n] + 1;

logic10{i in I, n in N}:
	k[i,n] <= u[i,n];

logic11{i in I, n in N}:
	k[i,n] <= b[i,n];

minimum_potential_users: # At least 50 percent of the inhabitants must become potential users
	sum{n in N, i in I}k[i,n] >= 0.5*card(N);

bikeallocation{i in I}: # Number of bikes allocated to each installed rack must be at least 5% of the potential users linked to the rack
	B_Conventional[i] + B_Electric[i] >= 0.05*sum{n in N}k[i,n];

