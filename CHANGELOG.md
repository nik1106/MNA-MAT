# Change Log
All notable changes to this project will be documented in this file.

## Unreleased

###September 5th, 2016

### Added
- In __MonteCarlo.m__, seperate distribution choices for resistors and capacitors. 
- In __MonteCarlo.m__, option to keep resistor or capacitor values fixed at each run.

### Changed
- In __MonteCarlo.m__, the uniform distribution for resistors and capacitors is now continuous rather than discrete.

###September 16th, 2016

### Added
- __Inductors__ can now be used in the SPICE netlist.
- __Current controlled voltage sources (H)__ can now be used in the SPICE netlist.
- __Current controlled current sources (F)__ can now be used in the SPICE netlist.

### Changed
- Removed unnecessary loops to improve speed.

###September 18th, 2016

### Added
- Axes labels for transient plots.

### Changed
- General code cleanup - removed unnecessary square brackets.

###September 20th, 2016

### Added
- New example SPICE netlist (example11.cir) with associated schematic (example11.png), a complex RLC circuit.

### Changed
- Minor changes.

###September 23rd, 2016

### Added
- New example SPICE netlist (example12.cir) with associated schematic (example12.png), a complex RLC circuit.

### Changed 
- Minor changes.

###October 18th, 2016

### Changed
- Minor aesthetic changes in the code and the generated output text files.

###November 26th, 2016
### Added
- MIT License.

### Changed
- Minor aesthetic improvements.
- Minor changes for avoiding the 'symbolic:sym:sym:DeprecateExpressions' warning concerning sym command in MATLAB R2016a (MuPAD symbolic engine is now called using evalin command instead), and for support on future MATLAB releases.
