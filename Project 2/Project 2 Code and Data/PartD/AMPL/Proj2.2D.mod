# Part 2 D Mod File
# Sets:
set D ordered; # Days
set D_weekdays within D ordered; #Weekdays
set D_sunday within D ordered; #Sundays
set H ordered; # Hours
set I; #Intervals
# Parameters
param C{D,H}; # Charging cost pr kwh on day D at hour H
param init_y; # Initial capacity
param final_y; # Final capacity
param max_charge; # Maximum charge rate
param travel_cost; # Capacity cost of travelling one way
param travel_cost_rec; # Capacity cost of travelling for recreational purposes

# Decision Variables:
var x{D,H} >= 0; # Amount charged on day D at hour H
var y{D,H} >= 0; # Battery capacity on day D at hour H
var G{D,H} binary; # Takes the value 1 if the car is driven at a weekday d in hour h. 
var z{D,I} binary; # Takes the value 1 if the car is used for recreational purposes on sunday at interval i.
var u{D,H} binary; # Takes the value 1 if the car is driven at a sunday d in hour h for recreational purposes.
# Objective function:
minimize cost:
	sum{d in D, h in H: d>0}C[d,h]*x[d,h];

# Restrictions and logical constraints:
subject to
maxchargerate{d in D, h in H:d>0}: # maximum charge rate (7.5)
	x[d,h] <= max_charge;

Unavailable{d in D_weekdays, h in 8 .. 17}:
	x[d,h] = 0;

# Car needs to be driven each week in hour 8 and 17 
driving{d in D_weekdays, h in H: h = 8 or h = 17}:
	G[d,h] = 1;

Capacitybalance{d in D, h in H:d>0 and h > 1}: # Battery capacity must equal capacity at previous period + charge - consumption
	y[d,h] = y[d,h-1] + x[d,h] - travel_cost*G[d,h] -travel_cost_rec*u[d,h];

CapacitybalanceDoD{d in D:d > 0}: # Battery capacity must be transfered from one day to another (we could have included G[d,h] but we now there is no consumption at this time)
	y[d,1] = y[d-1, last(H)] + x[d,1];

initialcap: # Initial value of the battery capacity
	y[first(D),24] = init_y;
	
finalcap: # Final value of battery capacity
	y[last(D), last(H)] = final_y;

maxcapacity{d in D, h in H: d > 0}: # Maximum battery capacity
	y[d,h] <= 64;

mincapacity{d in D, h in H: d > 0}: # minimum battery capacity
	y[d,h] >= 12.8;


restrict1{d in D_sunday}: # Makes sure that only one interval is chosen each sunday
	sum{i in I}z[d,i] = 1;

int1{d in D_sunday}: # If the interval is chosen then u[d,h] for must take the value 1
	u[d,11] + u[d,14] = 2*z[d,1];
int2{d in D_sunday}:
	u[d,12] + u[d,15] = 2*z[d,2];
int3{d in D_sunday}:
	u[d,13] + u[d,16] = 2*z[d,3];
int4{d in D_sunday}:
	u[d,14] + u[d,17] = 2*z[d,4];

rec1{d in D_sunday, h in {11,12,13,14}}: # If the interval is chosen then there can be no charging
	max_charge*(1-z[d,1]) >= x[d,h];
rec2{d in D_sunday, h in {12,13,14,15}}: # If the interval is chosen then there can be no charging
	max_charge*(1-z[d,2]) >= x[d,h];
rec3{d in D_sunday, h in {13,14,15,16}}: # If the interval is chosen then there can be no charging
	max_charge*(1-z[d,3]) >= x[d,h];
rec4{d in D_sunday, h in {14,15,16,17}}: # If the interval is chosen then there can be no charging
	max_charge*(1-z[d,4]) >= x[d,h];




