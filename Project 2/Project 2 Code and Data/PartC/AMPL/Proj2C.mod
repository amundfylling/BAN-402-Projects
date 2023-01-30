# Part 2 C
# Sets:
set I; # crude oils
set B; #components
set P; #final products
set J; 	#CDU: Crude Distilling Units
set D; 	#depots
set K; #markets
set M; #running modes
set T ordered; #time periods (days)

# Parameters
param Ccrude{I,T}; # Cost of purchasing one unit of crude oil i on day t
param R{I,B,J,M}; # Amount of component b obtained from refining one unit of crude oil i in CDU j at running mode m
param N{B,P}; # Units of component b needed to produce one unit of product p
param S{P}; # Price of product p in all markets
param S_lowqc; # Price of component lowqc
param Cref{I,J,M}; # The refining cost for one unit of crude oil i in CDU j in mode m
param Cap{J,M}; # Processing capacity of CDU j in running mode m
param Cprod{P}; # Cost of producing one unit of product p
param Ctra1; # Cost of transporting one unit of any component from the refining to the blending department
param Ctra2{D}; # Cost of transporting one unit of any product from the blending department to depot d
param Ctra3{D,K}; # Cost of shipping one unit of any product from depot d to market k
param Cinvi; # Cost of storing one unit of any type of crude oil at the refining department per day.
param Cinvb; # Cost of storing one unit of any component at the refining department per day (not including lowqc which is not stored)
param Cinvp{D}; # The cost of storing one unit of any type of product at depot d
param delta{P,K,T}; # Maximum demand limit for product p from market k in day t
param Cmode{J,M}; # Fixed cost incurred per day from operation of CDU j in mode m
param Cchange; # Cost of changing running mode at CDU
param I_zero_I{I}; #initial inventory of crude i
param I_zero_b{B}; #initial inventory of component b
param I_zero_pd{P,D}; #initial inventory of product p at depot d
param I_final_b{B}; # minimum inventory of product B
param I_final_pd{P,D}; #Minimum final inventory requirement of product p at depot d
param y_zero_b{B};    #initial component b sent to blending
param x_zero_p{P,D};  #initial product p sent to depot d
param v_zero_p{P,D,K} default 0;  #initial product p sent to market k
param m_zero{J,M}; # Initial mode m of CDU j.




# Decision Variables:
var u{I,T} >= 0; # Units of crude oil i purchased at day t
var z{I,J,M,T} >= 0; # Units of crude oil i destilled in CDU j in mode m in period t
var y{B,T}>=0; #amount of component b sent to blending in period t (available for blending in t+1)
var w{P,T}>=0; #amount of product p produced at the blending department in period t
var x{P,D,T}>=0; #amount of product p sent to depot d in period t (available at depot in t+1)
var v{P,D,K,T}>=0; #amount of product p sent from depot d to market k in period t (satisfies demand in t+1)
var s{B,T} >=0; # Amount of component b sold immediately after refining (only lowqc)
var IO{I,T}>=0; #inventory of crude oil i at the refinery in the end of period t
var IC{B,T}>=0; #inventory of component b at the refinery in the end of period t
var IP{P,D,T}>=0; #inventory of product p at depot d at the end of period t
var L{J,M,T} binary; # 1 if mode m used on CDU j in period t and 0 otherwise
var E{J,M,T} binary; # Takes the value 1 if mode m used on CDU j in period t is different from previous period (t-1)


# Objective function:
maximize contribution:
	sum{p in P, d in D, k in K, t in T:t>0 and t <= card(T)-2}S[p]*v[p,d,k,t] +
	sum{t in T: t>0}s["lowqc",t]*S_lowqc	
	- sum{i in I, t in T:t>0}Ccrude[i,t]*u[i,t]
	- sum{i in I, j in J, m in M, t in T:t>0}Cref[i,j,m]*z[i,j,m,t]	
    	- sum{p in P, t in T:t>0}Cprod[p]*w[p,t]
        - sum{i in I, t in T:t>0}Cinvi*IO[i,t]
        - sum{b in B, t in T:t>0}Cinvb*IC[b,t]
        - sum{p in P, d in D, t in T:t>0}Cinvp[d]*IP[p,d,t]
        - sum{b in B, t in T:t>0}Ctra1*y[b,t]
	- sum{p in P, d in D, t in T: t>0} Ctra2[d]*x[p,d,t]
	- sum{p in P, d in D, k in K, t in T: t>0} Ctra3[d,k]*v[p,d,k,t]
	- sum{j in J,m in M, t in T: t>0} L[j,m,t]*Cmode[j,m]
	- sum{j in J,m in M, t in T: t>0} E[j,m,t]*Cchange*0.5
        ;


# Restrictions and logical constraints:
subject to
BalanceCrude{i in I, t in T:t>0}: # balance of crudes inflow purchase, stored, outflow
	IO[i,t] = IO[i,t-1] + u[i,t] - sum{j in J, m in M} z[i,j,m,t];

CapConstraint{j in J, m in M, t in T:t>0}:	# maximum amount of crudes i processed by CDU j in running mode m per day
        sum{i in I}z[i,j,m,t] <= Cap[j,m];

BalanceComponent{b in B, t in T:t>0 and b <> "lowqc"}: # balance of components inflow, stored, and outflow
        IC[b,t] = IC[b,t-1] - y[b,t] + sum{i in I, j in J, m in M}R[i,b,j,m]*z[i,j,m,t];
        
Saleoflowqc{t in T:t>0}: # All production of component lowqc is sold in time period t
		s["lowqc",t] = sum{i in I, j in J, m in M}R[i,"lowqc",j,m]*z[i,j,m,t];

FeedTheBlending{b in B, t in T:t>0}: # component b sent to blending according to product recipes
        y[b,t-1] = sum{p in P}N[b,p]*w[p,t];

BlendingToDepots{p in P, t in T:t>0}:	# all production at blending sent to depots (no storage at blending facility)
	w[p,t] = sum{d in D}x[p,d,t];

BalanceProduct{p in P, d in D, t in T:t>0}:  # balance of products at depots inflow from blender, stored, to markets
	IP[p,d,t] = IP[p,d,t-1] + x[p,d,t-1] - sum{k in K}v[p,d,k,t];

DemandConstraint{p in P, k in K, t in T: t>0}: #Shipped to market cannot be more than demand
        sum{d in D}v[p,d,k,t-1]  <= delta[p,k,t];

InventoryInitial_i{i in I}:  # initial inventory of crude oils
     	IO[i,0]=I_zero_I[i];

InventoryInitial_b{b in B}:  # initial inventory of components
     	IC[b,0]=I_zero_b[b];

InventoryInitial_p{p in P, d in D}: # initial inventory of products at depot d
     	IP[p,d,0]=I_zero_pd[p,d];  

b_InitialToBlending{b in B}: # initial component b sent to blending (available in t=1)
     	y[b,0]=y_zero_b[b];

p_InitialToDepot{p in P, d in D}: # initial product p sent to depot d (available in t=1)
     	x[p,d,0]=x_zero_p[p,d];
     	
p_InitialToMarket{p in P, d in D, k in K}: # initial product p sent from depot d to market k (available in t=1)
     	v[p,d,k,0]=v_zero_p[p,d,k];

InventoryFinal_b{b in B}: # Minimum final inventory of component b
     	IC[b,last(T)] >= I_final_b[b];  


InventoryFinal_p{p in P, d in D}: # Minimum final inventory of products at depot d
     	IP[p,d,last(T)] >= I_final_pd[p,d];  
     	
Startingmode{j in J, m in M}:
		L[j,m,0] = m_zero[j,m];

Logic1{j in J, m in M, t in T: t>0}: #If CDU j is used in mode m for a given day, then L[j,m,t] should take the value 1
		sum{i in I}z[i,j,m,t] <= L[j,m,t]*1050;

Logic2{j in J, t in T: t>0}: # Ensures that exactly one mode of CDU j is chosen for a given day
	sum{m in M}L[j,m,t] = 1;

Logic3{j in J, m in M, t in T: t>0}: # Logic 3-4 ensures that the binary variable E takes the value 1 if mode m used on CDU j in period t is different from previous period (t-1)
	L[j,m,t]+L[j,m,t-1] <= 2 - E[j,m,t];   

Logic4{j in J, m in M, t in T: t>0}: 
	L[j,m,t]-L[j,m,t-1] <= E[j,m,t];   

Logic5{j in J, m in M, t in T: t>0}:
	L[j,m,t-1]-L[j,m,t] <= E[j,m,t];   





































