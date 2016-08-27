# MNA-MAT
A SPICE netlist simulation tool for MATLAB

## About MNA-MAT
MNA-MAT is a simulation tool designed in MATLAB for solving circuits described as SPICE netlists. It accepts a file (.cir or .txt) with the SPICE netlist description of the circuit to be simulated. As of now, MNA-MAT supports the following circuit elements :-
- Resistors (R)
- Capacitors (C)
- Independent voltage sources (V)
- Independent current sources (I)
- Voltage controlled voltage sources (VCVS) (E)
- Voltage controlled current sources (VCCS) (I)

MNA-MAT supports the following simulation types as of present :-
* DC bias point (for purely resistive circuits)
* Transient analysis (for capacitive or RC circuits)
* Monte Carlo analysis (done using one of the above, again based on the type of circuit)
