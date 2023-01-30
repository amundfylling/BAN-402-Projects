# Part 2 D Mod File
# Sets:
set D ordered; # Days
set D_weekdays within D ordered; #Weekdays
set D_weekends within D ordered; #Weekends
set H ordered; # Hours

# Parameters
param C{D,H}; # Charging cost pr kwh on day D at hour H
param init_y; # Initial capacity
param final_y; # Final capacity
param max_charge; # Maximum charge rate
param travel_cost; # cost of travelling one way


# Decision Variables:
var x{D,H} >= 0; # Amount charged on day D at hour H
var y{D,H} >= 0; # Battery capacity on day D at hour H
var G{D,H} binary; # Takes the value 1 if the car is driven at day d in hour h. 
# Objective function:
maximize cost:
	sum{d in D, h in H: d>0}C[d,h]*x[d,h];

# Restrictions and logical constraints:
subject to
maxchargerate{d in D, h in H:d>0}: # maximum charge rate (7.5)
	x[d,h] <= max_charge;

UnavailableF{d in D_weekdays, h in 8 .. 17}:
	x[d,h] = 0;

# Car needs to be driven each week in hour 8 and 17 
driving{d in D_weekdays, h in H: h = 8 or h = 17}:
	G[d,h] = 1;

# Car can't drive other times than hour 8 and 17 in weekdays
notdriving{d in D, h in H:h <> 8 and h <> 17 and d>0}:
	G[d,h] = 0;

# Car can´t drive in weekends
notdrivingweekends{d in D_weekends, h in H:d>0}:
	G[d,h] = 0;

Capacitybalance{d in D, h in H:d>0 and h > 1}: # State-of-charge must equal capacity at previous period + charge - consumption
	y[d,h] = y[d,h-1] + x[d,h] - travel_cost*G[d,h];

CapacitybalanceDoD{d in D:d > 0}: # Battery capacity must be transfered from one day to another (we could have included G[d,h] but we know there is no consumption at this time)
	y[d,1] = y[d-1, last(H)] + x[d,1];

initialcap: # Initial value of the state-of-charge
	y[first(D),24] = init_y;
	
finalcap: # Final value of state-of-charge
	y[last(D), last(H)] = final_y;

maxcapacity{d in D, h in H: d > 0}: # Maximum battery capacity
	y[d,h] <= 64;

mincapacity{d in D, h in H: d > 0}: # minimum battery requirement
	y[d,h] >= 12.8;
