# Part B model
set C; 						# Set of crude oils
set G; 						# Set of gasolines
set M; 						# Set of markets

param rev{M, G}; 			# revenue in market m from selling gasoline g 
param purch_cost{C}; 		# Purchase cost of crude oil c
param prod_cost{G}; 		# cost of producing gasoline g
param demand{M, G}; 		# Minimum demand that must be satisfied in market m for gasoline g
param cap{C}; 				# Maximum weekly purchase of crude oil c
param hours{G}; 			# hours used to produce one barrel of gasoline g, available hours: 12*40+2*20 = 520
param oct_crude{C}; 		# rating of octane in crude oil c
param sulfur_crude{C}; 		# sulfur content in crude oil c
param oct_gas{G}; 			# minimum octane requirement in gasoline g
param sulfur_gas{G}; 		# maximum sulfur content in gasoline g


var x{C, G} >= 0; 			# Barrels of c used to produce gasoline g
var y{G, M} >= 0; 			# Barrels of g sent to market m

maximize total_profit: 		# Maximize profit function
	sum{g in G, m in M} rev[m,g]*y[g,m]
		-sum{c in C, g in G} purch_cost[c]*x[c,g]
		-sum{g in G, m in M} prod_cost[g]*y[g,m];

subject to

max_purchase{c in C}: 		# Maximum purchase quantity
	sum{g in G}x[c,g] <= cap[c];

timecap: 					# Maximum time capacity
	sum{c in C, g in G}x[c,g]*hours[g] <= 520;

continuity{g in G}: 		# Sum of crude must equal sum of gasoline
	sum{c in C}x[c,g] = sum{m in M}y[g,m];

demand_req{g in G, m in M}: # Demand for each gasoline g must be satisfied in all markets.
	y[g,m] >= demand[m,g];

octane_comp{g in G}: 		# Octane minimum rating requirement
	sum{c in C}x[c,g]*oct_crude[c] >= sum{m in M}y[g,m]*oct_gas[g]; 

sulfur_comp{g in G}: 		# Sulfur maximum requirement
	sum{c in C}x[c,g]*sulfur_crude[c] <= sum{m in M}y[g,m]*sulfur_gas[g]; 
