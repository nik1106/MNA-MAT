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
- Axes labels for transient plots

### Changed
- General code cleanup - removed unnecessary square brackets
