clc;
clear;
close all;
choice = input('<< Welcome to MNA-MAT - A SPICE netlist simulation tool >> \n 1. Standard Analysis \n 2. Monte Carlo Analysis \n 3. View the results of previous simulation \n');
switch(choice)
    case{1}
        run('Standard_Analysis.m');
    case{2}
        run('MonteCarlo.m');
    case{3}
        if(exist('Results.txt'))
            type('Results.txt');
        elseif(exist('Results.xls'))
            open('Results.xls');
            if(exist('MC_values_ode.txt'))
                type('MC_values_ode.txt');
            end
            open('Voltages_graph.fig');
            if(exist('Currents_graph.fig'))
                open('Currents_graph.fig');
            end
        else
            disp('No results of previous simulation found');
        end
end
