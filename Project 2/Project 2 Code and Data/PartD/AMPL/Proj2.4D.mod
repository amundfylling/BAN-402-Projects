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
var m{D,H} binary; # Takes the value 1 if the the state-of-charge is less than or equal to 32 (50%) at day d in hour h-1. In other words the ingoing balance.
var j{D,H} binary; # Takes the value 1 if the state-of-Charge is greater than 51.2 (80%) at day d in hour h-1.
var t{D,H} binary; # Takes the value 1 if the state-of-Charge is less than 51.2 (80%) at day d in hour h-1.
var r{D,H} binary; # Takes the value 1 if the the state-of-charge is greater than 32 (50%) at day d in hour h. (auxiliary)
var c{D,H} binary; # Takes the value 1 if the car is charging and 0 otherwise.
var l{D,H} binary; # Takes the value 1 if the car goes from not charging to charging.
var o{D,H} binary; # Takes the value 1 if the car goes from charging to not charging.
var s{D,H} binary; # Takes the value 1 if a charging event starts, and 0 otherwise.
var e{D,H} binary; # Takes the value 1 if a charging event stops, and 0 otehrwise.
var f{D,H} binary; # Takes the value 1 if there is a charging event and 0 otherwise.
var p{D,H} binary; # Takes the value 1 if it is the last hour of the charging event and 0 otherwise.

# Objective function:
minimize cost:
	sum{d in D, h in H}C[d,h]*x[d,h];

# Restrictions and logical constraints:
subject to
maxchargerate{d in D, h in H}: # maximum charge rate (7.5)
	x[d,h] <= max_charge;

Unavailable{d in D_weekdays, h in 8 .. 17}:
	x[d,h] = 0;
	
# Car needs to be driven each week in hour 8 and 17 
driving{d in D_weekdays, h in H: h = 8 or h = 17}:
	G[d,h] = 1;

Capacitybalance{d in D, h in H: h > 1}: # Battery capacity must equal capacity at previous period + charge - consumption
	y[d,h] = y[d,h-1] + x[d,h] - travel_cost*G[d,h] -travel_cost_rec*u[d,h];

CapacitybalanceDoD{d in D:d > 32}: # Battery capacity must be transfered from one day to another (we could have included G[d,h] but we now there is no consumption at this time)
	y[d,1] = y[d-1, 24] + x[d,1];

initialcap: # Initial value of the battery capacity
	y[32,1] = init_y;
	
finalcap: # Final value of battery capacity
	y[87, 24] = final_y;

maxcapacity{d in D, h in H}: # Maximum battery capacity
	y[d,h] <= 64;

mincapacity{d in D, h in H}: # minimum battery capacity
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

logic1a{d in D, h in H: h > 1}: # Ensures that m must take the value 1 if y < 32
	y[d,h-1] >= 32*(1-m[d,h]);
logic1b{d in D: d > 32}: 
	y[d-1,24] >= 32*(1-m[d,1]);

logic2a{d in D, h in H: h > 1}: # Ensures that r must take the value 1 if the y > 32
	y[d,h-1] - 32 <= 64*r[d,h];
logic2b{d in D: d > 32}:
	y[d-1, 24] - 32 <= 64*r[d,1];
	
logic3{d in D, h in H}: # Ensures that r and m are mutually exclusive
	m[d,h]+r[d,h] = 1;

logic4a{d in D, h in H: h > 1}: # Ensures that t must take the value 1 if y < 51.2
	y[d,h-1] >= 51.2*(1-t[d,h]);
logic4b{d in D: d > 32}: 
	y[d-1,24] >= 51.2*(1-t[d,1]);

logic5a{d in D, h in H: h > 1}: # Ensures that j must take the value 1 if the y > 51.2
	y[d,h-1] - 51.2 <= 64*j[d,h];
logic5b{d in D: d > 32}:
	y[d-1, 24] - 51.2 <= 64*j[d,1];
	
logica6{d in D, h in H}: # Ensures that r and m are mutually exclusive
	t[d,h]+j[d,h] = 1;
 
logic7{d in D, h in H}: # ensures that c takes the value 1 if x > 0
	x[d,h] <= max_charge*c[d,h];

logic8{d in D, h in H}: # ensures that c takes the value 0 if x = 0 
	x[d,h] >= c[d,h];

logic9a{d in D, h in H: h > 1}: # Logic 9-11 ensures that l takes the value 1 only if the car goes from not charging to charging
	2*c[d,h] - c[d,h-1] <= 1 + l[d,h];
	
logic9b{d in D: d > 32}:
	2*c[d,1] - c[d-1,24] <= 1 + l[d,1];

logic10a{d in D, h in H: h > 1}:
	l[d,h] <= 1 - c[d,h-1];

logic10b{d in D: d > 32}:
	l[d,1] <= 1 - c[d-1,24];

logic11{d in D, h in H}:
	l[d,h] <= c[d,h];

	
logic12{d in D, h in H}: # Logic 11-14 ensures that s takes the value 1 if a charging event starts and 0 otherwise
	l[d,h] + m[d,h] <= 1 + s[d,h];

logic13{d in D, h in H}:
	s[d,h] <= l[d,h];
	
logic14{d in D, h in H}:
	s[d,h] <= m[d,h];


logic15a{d in D, h in H: h > 1}: # Logic 14-17 ensures that o takes the value 1 only if the car goes from charging to charging
	2*c[d,h-1] - c[d,h] <= 1 + o[d,h];
	
logic15b{d in D: d > 32}:
	2*c[d-1,24] - c[d,1] <= 1 + o[d,1];

logic16{d in D, h in H}:
	o[d,h] <= 1 - c[d,h];

logic17a{d in D, h in H: h > 1}:
	o[d,h] <= c[d,h-1];
logic17b{d in D: d > 32}:
	o[d,1] <= c[d-1,24];

logic18{d in D, h in H}: # Logic 18-20 ensures that e takes the value 1 if a charging event stops and 0 otherwise
	o[d,h] + j[d,h] <= 1 + e[d,h];

logic19{d in D, h in H}:
	e[d,h] <= o[d,h];
	
logic20{d in D, h in H}:
	e[d,h] <= j[d,h];

Logic21a{d in D, h in H: h > 1}: # Logic 21 ensures that f takes the value 1 if there is a charging event and 0 otherwise.
	f[d,h] = f[d,h-1] + s[d,h] - e[d,h];
Logic21b{d in D: d > 32}: 
	f[d,1] = f[d-1, 24] + s[d,1] - e[d,1];
	
Logic22{d in D, h in H}: # Ensures that the car can only be charged in the charging event.
	c[d,h] = f[d,h]; 


Logic23a{d in D, h in H: h < 24}: # Logic 23-26 ensures that the car must charge 7.5 all hours of the charging event, except the last one
	2*f[d,h] - e[d,h+1] <= 1 + p[d,h];
Logic23b{d in D: d < 87}:
	2*f[d,24] - e[d+1,1] <= 1 + p[d,24];

Logic24a{d in D, h in H: h < 24}:
	p[d,h] <= 1 - e[d,h+1];
Logic24b{d in D: d < 87}:
	p[d,24] <= 1 - e[d+1,1];

Logic25{d in D, h in H}:
	p[d,h] <= f[d,h];

Logic26{d in D, h in H}: 
	x[d,h] >= max_charge*p[d,h];
	




