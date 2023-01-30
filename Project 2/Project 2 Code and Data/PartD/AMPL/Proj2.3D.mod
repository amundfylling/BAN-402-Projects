# Part 2 D Mod File
# Sets:
set D ordered; # Days
set D_weekdays within D ordered; #Weekdays
set D_sunday within D ordered; #Sundays
set H ordered; # Hours
set D1 within D ordered; # Week 1 (only weekdays)
set D2 within D ordered; # Week 2 (only weekdays)
set D3 within D ordered; # Week 3 (only weekdays)
set D4 within D ordered; # Week 4 (only weekdays)
set D5 within D ordered; # Week 5 (only weekdays)
set D6 within D ordered; # Week 6 (only weekdays)
set D7 within D ordered; # Week 7 (only weekdays)
set D8 within D ordered; # Week 8 (only weekdays)
set D9 within D ordered; # Week 9 (only weekdays)
set D10 within D ordered; # Week 10 (only weekdays)
set D11 within D ordered; # Week 11 (only weekdays)
set D12 within D ordered; # Week 12 (only weekdays)
set D13 within D ordered; # Week 13 (only weekdays)

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
var l{D} binary; # takes the value 1 if the car is driven to work on a weekday.


# Objective function:
minimize cost:
	sum{d in D, h in H: d>0}C[d,h]*x[d,h];

# Restrictions and logical constraints:
subject to
maxchargerate{d in D, h in H:d>0}: # maximum charge rate (7.5)
	x[d,h] <= max_charge;

Unavailable{d in D_weekdays, h in 8 .. 17}: # Car cannot be charged if the car is driven on the weekday.
	x[d,h] <= max_charge*(1-l[d]);
#Car must be driven at 8 and 17 on the friday of july 1st.
driving{h in H: h = 8 or h = 17}:
	G[1,h] = 1;

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


Logic1{d in D_weekdays}: #l must take the value 1 if the car is driven to work on a weekday.
	G[d,8]+G[d,17] <= 2*l[d];

# Car needs to be driven at least 4 days each week in hour 8 and 17: 
driving1{h in H: h = 8 or h = 17}: #week 1 
	sum{d in D1}G[d,h] >= 4; 
driving2{h in H: h = 8 or h = 17}: #week 2 
	sum{d in D2}G[d,h] >= 4; 
driving3{h in H: h = 8 or h = 17}: #week 3 
	sum{d in D3}G[d,h] >= 4; 
driving4{h in H: h = 8 or h = 17}: #week 4 
	sum{d in D4}G[d,h] >= 4; 
driving5{h in H: h = 8 or h = 17}: #week 5 
	sum{d in D5}G[d,h] >= 4; 
driving6{h in H: h = 8 or h = 17}: #week 6 
	sum{d in D6}G[d,h] >= 4;
driving7{h in H: h = 8 or h = 17}: #week 7 
	sum{d in D7}G[d,h] >= 4; 
driving8{h in H: h = 8 or h = 17}: #week 8 
	sum{d in D8}G[d,h] >= 4; 
driving9{h in H: h = 8 or h = 17}: #week 9 
	sum{d in D9}G[d,h] >= 4; 
driving010{h in H: h = 8 or h = 17}: #week 10 
	sum{d in D10}G[d,h] >= 4; 
driving011{h in H: h = 8 or h = 17}: #week 11
	sum{d in D11}G[d,h] >= 4;
driving012{h in H: h = 8 or h = 17}: #week 12
	sum{d in D12}G[d,h] >= 4; 
driving013{h in H: h = 8 or h = 17}: #week 13
	sum{d in D13}G[d,h] >= 4; # 
	

# If travels one way, he has to travel the same way back for a given day.
driving11{d in D1}: #week 1 
	G[d,8] = G[d,17];
driving21{d in D2}: #week 2
	G[d,8] = G[d,17]; 
driving31{d in D3}: #week 3 
	G[d,8] = G[d,17]; 
driving41{d in D4}: #week 4 
	G[d,8] = G[d,17]; 
driving51{d in D5}: #week 5 
	G[d,8] = G[d,17]; 
driving61{d in D6}: #week 6
	G[d,8] = G[d,17]; 
driving71{d in D7}: #week 7
	G[d,8] = G[d,17]; 
driving81{d in D8}: #week 8
	G[d,8] = G[d,17]; 
driving91{d in D9}: #week 9
	G[d,8] = G[d,17]; 
driving101{d in D10}: #week 10
	G[d,8] = G[d,17];
driving111{d in D11}: #week 11
	G[d,8] = G[d,17]; 
driving121{d in D12}: #week 12
	G[d,8] = G[d,17]; 
driving131{d in D13}: #week 13
	G[d,8] = G[d,17]; 




