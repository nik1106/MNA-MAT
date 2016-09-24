%%Delete previously run simulation results, if any
if(exist('Results.txt'))
    delete('Results.txt');
elseif(exist('Results.xls'))
    delete('Results.xls');
    if(exist('MC_values_ode.txt'))
        delete('MC_values_ode.txt');
    end
    delete('Voltages_graph.fig');
    if(exist('Currents_graph.fig'))
        delete('Currents_graph.fig');
    end
end
%%-----------------------------------------------------------------------------
prompt='Enter the file name - ';
fname=input(prompt,'s');
fileID1=fopen('Element_indep.txt','wt+'); %Create an empty text file for passive elements and independent sources
fileID2=fopen('VCVS.txt','wt+'); %Create an empty text file for voltage controlled voltage sources
fileID3=fopen('VCCS.txt','wt+'); %Create an empty text file for voltage controlled current sources
fileID4=fopen('CCVS.txt','wt+'); %Create an empty text file for current controlled voltage sources
fileID5=fopen('CCCS.txt','wt+'); %Create an empty text file for current controlled current sources
netlist=textscan(fopen(fname),'%s %s %s %s %s %s');
%%-----------------------------------------------------------------------------
%%Initialize
num_Elements=0; %Number of passive elements
num_V=0; %Number of independent voltage sources
num_I=0; %Number of independent current sources
num_Nodes=0; %Number of nodes, excluding ground (node 0)
num_VCVS=0; %Number of voltage controlled voltage sources
num_VCCS=0; %Number of voltage controlled current sources
num_CCVS=0; %Number of current controlled voltage sources
num_CCCS=0; %Number of current controlled current sources
num_L=0; %Number of inductors
%%-----------------------------------------------------------------------------
for i=1:length(netlist{1})
    s=netlist{1}{i};
    switch(s(1))
        case{'V','I','R','L','C'} %For independent sources and passive elements
            fprintf(fileID1,[netlist{1}{i} ' ' netlist{2}{i} ' ' ...
                netlist{3}{i} ' ' netlist{4}{i} '\n']);
        case{'E'} %For voltage controlled voltage sources
            fprintf(fileID2,[netlist{1}{i} ' ' netlist{2}{i} ' ' ...
                netlist{3}{i} ' ' netlist{4}{i} ' ' netlist{5}{i} ' ' ...
                netlist{6}{i} '\n']);
        case{'G'} %For voltage controlled current sources
            fprintf(fileID3,[netlist{1}{i} ' ' netlist{2}{i} ' ' ...
                netlist{3}{i} ' ' netlist{4}{i} ' ' netlist{5}{i} ' ' ...
                netlist{6}{i} '\n']);
        case{'H'} %For current controlled voltage sources
            fprintf(fileID4,[netlist{1}{i} ' ' netlist{2}{i} ' ' ...
                netlist{3}{i} ' ' netlist{4}{i} ' ' netlist{5}{i} '\n']);
        case{'F'} %For current controlled current sources
            fprintf(fileID5,[netlist{1}{i} ' ' netlist{2}{i} ' ' ...
                netlist{3}{i} ' ' netlist{4}{i} ' ' netlist{5}{i} '\n']);
    end
end
%%-----------------------------------------------------------------------------
%%Read the data from the newly created 'Element_indep.txt' text file
[Name,N1,N2,value]=textread('Element_indep.txt','%s %s %s %s');
for i=1:length(Name)
    switch(Name{i}(1))
        case{'R','L','C'}
            num_Elements=num_Elements+1;
            Element(num_Elements).Name=Name{i};
            Element(num_Elements).Node1=str2num(N1{i});
            Element(num_Elements).Node2=str2num(N2{i});
            Element(num_Elements).Value=str2double(value{i});
            if(Name{i}(1)=='L')
                num_L=num_L+1;
                Inductor(num_L).Name=Name{i};
                Inductor(num_L).N1=str2num(N1{i});
                Inductor(num_L).N2=str2num(N2{i});
                Inductor(num_L).Value=str2double(value{i});
            end
        case{'V'}
            num_V=num_V+1;
            Volt_source(num_V).Name=Name{i};
            Volt_source(num_V).Node1=str2num(N1{i});
            Volt_source(num_V).Node2=str2num(N2{i});
            Volt_source(num_V).Value=str2double(value{i});
            
        case{'I'}
            num_I=num_I+1;
            Current_source(num_I).Name=Name{i};
            Current_source(num_I).Node1=str2num(N1{i});
            Current_source(num_I).Node2=str2num(N2{i});
            Current_source(num_I).Value=str2double(value{i});
    end
    num_Nodes=max(str2num(N1{i}),max(str2num(N2{i}),num_Nodes));
end
%%-----------------------------------------------------------------------------
%%Read the data from the newly created 'VCVS.txt' text file
[Name,N1,N2,NC1,NC2,Gain]=textread('VCVS.txt','%s %s %s %s %s %s');
num_VCVS=length(Name);
for i=1:num_VCVS
    VCVS(i).Name=Name{i};
    VCVS(i).N1=str2num(N1{i});
    VCVS(i).N2=str2num(N2{i});
    VCVS(i).NC1=str2num(NC1{i});
    VCVS(i).NC2=str2num(NC2{i});
    VCVS(i).Gain=str2double(Gain{i});
    num_Nodes=max(str2num(N1{i}),max(str2num(N2{i}),num_Nodes));
end
%%-----------------------------------------------------------------------------
%%Read the data from the newly created 'VCCS.txt' text file
[Name,N1,N2,NC1,NC2,Transconductance]=textread('VCCS.txt','%s %s %s %s %s %s');
num_VCCS=length(Name);
for i=1:num_VCCS
    VCCS(i).Name=Name{i};
    VCCS(i).N1=str2num(N1{i});
    VCCS(i).N2=str2num(N2{i});
    VCCS(i).NC1=str2num(NC1{i});
    VCCS(i).NC2=str2num(NC2{i});
    VCCS(i).Transconductance=str2double(Transconductance{i});
    num_Nodes=max(str2num(N1{i}),max(str2num(N2{i}),num_Nodes));
end
%%-----------------------------------------------------------------------------
%%Read the data from the newly created 'CCVS.txt' text file
[Name,N1,N2,Vcontrol,Transresistance]=textread('CCVS.txt','%s %s %s %s %s');
num_CCVS=length(Name);
for i=1:num_CCVS
    CCVS(i).Name=Name{i};
    CCVS(i).N1=str2num(N1{i});
    CCVS(i).N2=str2num(N2{i});
    CCVS(i).Vcontrol=Vcontrol{i};
    CCVS(i).Transresistance=str2double(Transresistance{i});
    num_Nodes=max(str2num(N1{i}),max(str2num(N2{i}),num_Nodes));
end
%%-----------------------------------------------------------------------------
%%Read the data from the newly created 'CCCS.txt' text file
[Name,N1,N2,Vcontrol,Gain]=textread('CCCS.txt','%s %s %s %s %s');
num_CCCS=length(Name);
for i=1:num_CCCS
    CCCS(i).Name=Name{i};
    CCCS(i).N1=str2num(N1{i});
    CCCS(i).N2=str2num(N2{i});
    CCCS(i).Vcontrol=Vcontrol{i};
    CCCS(i).Gain=str2double(Gain{i});
    num_Nodes=max(str2num(N1{i}),max(str2num(N2{i}),num_Nodes));
end
%%-----------------------------------------------------------------------------
%%Close all the created text files and then delete them
fclose('all');
delete('Element_indep.txt');
delete('VCVS.txt');
delete('VCCS.txt');
delete('CCVS.txt');
delete('CCCS.txt');
%%-----------------------------------------------------------------------------
%%Create the equations for the independent voltage sources and apply KCL at the nodes
node_equation=cell(num_Nodes,1);
volt_equation=cell(num_V,1);
for i=1:num_V
    switch((Volt_source(i).Node1==0)||(Volt_source(i).Node2==0))
        case{1} %One of the terminals of independent voltage source is grounded
            if(Volt_source(i).Node1==0)
                volt=['v_' num2str(Volt_source(i).Node2) '=' '-' num2str(Volt_source(i).Value)];
                node_equation{Volt_source(i).Node2}=[node_equation{Volt_source(i).Node2} ...
                    '-' 'i_' Volt_source(i).Name];
            else
                volt=['v_' num2str(Volt_source(i).Node1) '='  num2str(Volt_source(i).Value)];
                node_equation{Volt_source(i).Node1}=[node_equation{Volt_source(i).Node1} ...
                    '+' 'i_' Volt_source(i).Name];
            end
            volt_equation{i}=volt;
        case{0}
            volt=['v_' num2str(Volt_source(i).Node1) '-' ...
                'v_' num2str(Volt_source(i).Node2) '=' num2str(Volt_source(i).Value)];
            volt_equation{i}=volt;
            node_equation{Volt_source(i).Node1}=[node_equation{Volt_source(i).Node1} ...
                '+' 'i_' Volt_source(i).Name];
            node_equation{Volt_source(i).Node2}=[node_equation{Volt_source(i).Node2} ...
                '-' 'i_' Volt_source(i).Name];
    end
end
%%-----------------------------------------------------------------------------
%%Create the equations for the voltage controlled voltage sources and apply KCL at the nodes
VCVS_equation=cell(num_VCVS,1);
for i=1:num_VCVS
    switch((VCVS(i).N1==0)||(VCVS(i).N2==0))
        case{1}
            if(VCVS(i).N1==0)
                switch((VCVS(i).NC1==0)||(VCVS(i).NC2==0))
                    case{1}
                        if(VCVS(i).NC1==0)
                            volt=['-' 'v_' num2str(VCVS(i).N2) '-' num2str(VCVS(i).Gain) ...
                                '*' '(' '-' 'v_' num2str(VCVS(i).NC2) ')'];
                        else
                            volt=['-' 'v_' num2str(VCVS(i).N2) '-' num2str(VCVS(i).Gain) ...
                                '*' '(' 'v_' num2str(VCVS(i).NC1) ')'];
                        end
                    case{0}
                        volt=['-' 'v_' num2str(VCVS(i).N2) '-' num2str(VCVS(i).Gain) ...
                            '*' '(' 'v_' num2str(VCVS(i).NC1) '-' 'v_' num2str(VCVS(i).NC2) ')'];
                end
                node_equation{VCVS(i).N2}=[node_equation{VCVS(i).N2} '-' 'i_' VCVS(i).Name];
            else
                switch((VCVS(i).NC1==0)||(VCVS(i).NC2==0))
                    case{1}
                        if(VCVS(i).NC1==0)
                            volt=['v_' num2str(VCVS(i).N1) '-' num2str(VCVS(i).Gain) ...
                                '*' '(' '-' 'v_' num2str(VCVS(i).NC2) ')'];
                        else
                            volt=['v_' num2str(VCVS(i).N1) '-' num2str(VCVS(i).Gain) ...
                                '*' '(' 'v_' num2str(VCVS(i).NC1) ')'];
                        end
                    case{0}
                        volt=['v_' num2str(VCVS(i).N1) '-' num2str(VCVS(i).Gain) ...
                            '*' '(' 'v_' num2str(VCVS(i).NC1) '-' 'v_' num2str(VCVS(i).NC2) ')'];
                end
                node_equation{VCVS(i).N1}=[node_equation{VCVS(i).N1} '+' 'i_' VCVS(i).Name];
            end
        case{0}
            switch((VCVS(i).NC1==0)||(VCVS(i).NC2==0))
                case{1}
                    if(VCVS(i).NC1==0)
                        volt=['v_' num2str(VCVS(i).N1) '-' 'v_' num2str(VCVS(i).N2) '-' ...
                            num2str(VCVS(i).Gain) '*' '(' '-' 'v_' num2str(VCVS(i).NC2) ')'];
                    else
                        volt=['v_' num2str(VCVS(i).N1) '-' 'v_' num2str(VCVS(i).N2) '-' ...
                            num2str(VCVS(i).Gain) '*' '(' 'v_' num2str(VCVS(i).NC1) ')'];
                    end
                case{0}
                    volt=['v_' num2str(VCVS(i).N1) '-' 'v_' num2str(VCVS(i).N2) '-' ...
                        num2str(VCVS(i).Gain) '*' '(' 'v_' num2str(VCVS(i).NC1) '-' 'v_' num2str(VCVS(i).NC2) ')'];
            end
            node_equation{VCVS(i).N1}=[node_equation{VCVS(i).N1} '+' 'i_' VCVS(i).Name];
            node_equation{VCVS(i).N2}=[node_equation{VCVS(i).N2} '-' 'i_' VCVS(i).Name];
    end
    VCVS_equation{i}=volt;
end
%%------------------------------------------------------------------------------
%%Create the equations for the current controlled voltage sources and apply KCL at the nodes
CCVS_equation=cell(num_CCVS,1);
for i=1:num_CCVS
    switch((CCVS(i).N1==0)||(CCVS(i).N2==0))
        case{1}
            if(CCVS(i).N1==0)
                volt=['v_' num2str(CCVS(i).N2) '+' '(' num2str(CCVS(i).Transresistance) '*' 'i_' CCVS(i).Vcontrol ')'];
                node_equation{CCVS(i).N2}=[node_equation{CCVS(i).N2} ...
                    '-' 'i_' CCVS(i).Name];
            else
                volt=['v_' num2str(CCVS(i).N1) '-' '(' num2str(CCVS(i).Transresistance) '*' 'i_' CCVS(i).Vcontrol ')'];
                node_equation{CCVS(i).N1}=[node_equation{CCVS(i).N1} ...
                    '+' 'i_' CCVS(i).Name];
            end
            CCVS_equation{i}=volt;
        case{0}
            volt=['v_' num2str(CCVS(i).N1) '-' ...
                'v_' num2str(CCVS(i).N2) '-' '(' num2str(CCVS(i).Transresistance) '*' 'i_' CCVS(i).Vcontrol ')'];
            CCVS_equation{i}=volt;
            node_equation{CCVS(i).N1}=[node_equation{CCVS(i).N1} ...
                '+' 'i_' CCVS(i).Name];
            node_equation{CCVS(i).N2}=[node_equation{CCVS(i).N2} ...
                '-' 'i_' CCVS(i).Name];
    end
end
%%-----------------------------------------------------------------------------
solver_flag=0; %A flag used for deciding which solver to finally use
%solver_flag=0 => Purely resistive circuit, use solve for the equations
%solver_flag=1 => Pure C, pure L, LC, RC, RL or RLC circuit, use ode15i for the equations
%%------------------------------------------------------------------------------
%%Add each elemental current using KCL to corresponding node equation, and
%%make the equations for inductors
L_equation=cell(num_L,1);
L_ctr=0;
for i=1:num_Elements
    switch(Element(i).Name(1))
        case{'R'}
            switch((Element(i).Node1==0)||(Element(i).Node2==0))
                case{0}
                    node_equation{Element(i).Node1}=[node_equation{Element(i).Node1} '+' '(' ...
                        'v_' num2str(Element(i).Node2) '-' 'v_' ...
                        num2str(Element(i).Node1) ')' '/' num2str(Element(i).Value)];
                    node_equation{Element(i).Node2}=[node_equation{Element(i).Node2} '+' '(' ...
                        'v_' num2str(Element(i).Node1) '-' 'v_' ...
                        num2str(Element(i).Node2) ')' '/' num2str(Element(i).Value)];
                case{1}
                    if(Element(i).Node1==0)
                        node_equation{Element(i).Node2}=[node_equation{Element(i).Node2} ...
                            '-' '(' 'v_' num2str(Element(i).Node2) ')' '/' num2str(Element(i).Value)];
                    else
                        node_equation{Element(i).Node1}=[node_equation{Element(i).Node1} ...
                            '-' '(' 'v_' num2str(Element(i).Node1) ')' '/' num2str(Element(i).Value)];
                    end
            end
        case{'C'}
            if(solver_flag==0) %If solver_flag is still 0, this is the first non-resistive element in Element netlist
                solver_flag=1;
            end
            switch((Element(i).Node1==0)||(Element(i).Node2==0))
                case{0}
                    node_equation{Element(i).Node1}=[node_equation{Element(i).Node1} ...
                        '+' num2str(Element(i).Value) '*' '(' 'vp(' num2str(Element(i).Node2) ')' ...
                        '-' 'vp(' num2str(Element(i).Node1) ')' ')'];
                    node_equation{Element(i).Node2}=[node_equation{Element(i).Node2} ...
                        '+' num2str(Element(i).Value) '*' '(' 'vp(' num2str(Element(i).Node1) ')' ...
                        '-' 'vp(' num2str(Element(i).Node2) ')' ')'];
                case{1}
                    if(Element(i).Node1==0)
                        node_equation{Element(i).Node2}=[node_equation{Element(i).Node2} ...
                            '-' num2str(Element(i).Value) '*' '(' 'vp(' num2str(Element(i).Node2) ')' ')'];
                    else
                        node_equation{Element(i).Node1}=[node_equation{Element(i).Node1} ...
                            '-' num2str(Element(i).Value) '*' '(' 'vp(' num2str(Element(i).Node1) ')' ')'];
                    end
            end
        case{'L'}
            if(solver_flag==0) %If solver_flag is still 0, this is the first non-resistive element in Element netlist
                solver_flag=1;
            end
            L_ctr=L_ctr+1;
            switch((Element(i).Node1==0)||(Element(i).Node2==0))
                case{0}
                    node_equation{Element(i).Node1}=[node_equation{Element(i).Node1} '-' 'i_' Element(i).Name];
                    node_equation{Element(i).Node2}=[node_equation{Element(i).Node2} '+' 'i_' Element(i).Name];
                    L_equation{L_ctr}=['v_' num2str(Element(i).Node1) '-' 'v_' num2str(Element(i).Node2) '-' ...
                        '('  num2str(Element(i).Value) '*' 'ip(' num2str(L_ctr) ')' ')'];
                case{1}
                    if(Element(i).Node1==0)
                        node_equation{Element(i).Node2}=[node_equation{Element(i).Node2}  '+' 'i_' Element(i).Name];
                        L_equation{L_ctr}=['-' 'v_' num2str(Element(i).Node2) '-' ...
                            '('  num2str(Element(i).Value) '*' 'ip(' num2str(L_ctr) ')' ')'];
                    else
                        node_equation{Element(i).Node1}=[node_equation{Element(i).Node1}  '-' 'i_' Element(i).Name];
                        L_equation{L_ctr}=['v_' num2str(Element(i).Node1) '-' ...
                            '('  num2str(Element(i).Value) '*' 'ip(' num2str(L_ctr) ')' ')'];
                    end
            end
    end
end
%%-----------------------------------------------------------------------------
%%Add the independent current sources to the node equations
for i=1:num_I
    switch((Current_source(i).Node1==0)||(Current_source(i).Node2==0))
        case{1}
            if(Current_source(i).Node1==0)
                node_equation{Current_source(i).Node2}=[node_equation{Current_source(i).Node2} ...
                    '+' num2str(Current_source(i).Value)];
            else
                node_equation{Current_source(i).Node1}=[node_equation{Current_source(i).Node1} ...
                    '-' num2str(Current_source(i).Value)];
            end
        case{0}
            node_equation{Current_source(i).Node1}=[node_equation{Current_source(i).Node1} ...
                '-' num2str(Current_source(i).Value)];
            node_equation{Current_source(i).Node2}=[node_equation{Current_source(i).Node2} ...
                '+' num2str(Current_source(i).Value)];
    end
end
%%-----------------------------------------------------------------------------
%%Next, add the voltage controlled current sources to the node equations
for i=1:num_VCCS
    switch((VCCS(i).N1==0)||(VCCS(i).N2==0))
        case{1}
            if(VCCS(i).N1==0)
                switch((VCCS(i).NC1==0)||(VCCS(i).NC2==0))
                    case{1}
                        if(VCCS(i).NC1==0)
                            node_equation{VCCS(i).N2}=[node_equation{VCCS(i).N2} '+' ...
                                num2str(VCCS(i).Transconductance) '*' '(' '-' 'v_' num2str(VCCS(i).NC2) ')'];
                        else
                            node_equation{VCCS(i).N2}=[node_equation{VCCS(i).N2} '+' ...
                                num2str(VCCS(i).Transconductance) '*' '(' 'v_' num2str(VCCS(i).NC1) ')'];
                        end
                    case{0}
                        node_equation{VCCS(i).N2}=[node_equation{VCCS(i).N2} '+' ...
                            num2str(VCCS(i).Transconductance) '*' '(' 'v_' num2str(VCCS(i).NC1) '-' ...
                            'v_' num2str(VCCS(i).NC2) ')'];
                end
            else
                switch((VCCS(i).NC1==0)||(VCCS(i).NC2==0))
                    case{1}
                        if(VCCS(i).NC1==0)
                            node_equation{VCCS(i).N1}=[node_equation{VCCS(i).N1} '-' ...
                                num2str(VCCS(i).Transconductance) '*' '(' '-' 'v_' num2str(VCCS(i).NC2) ')'];
                        else
                            node_equation{VCCS(i).N1}=[node_equation{VCCS(i).N1} '-' ...
                                num2str(VCCS(i).Transconductance) '*' '(' 'v_' num2str(VCCS(i).NC1) ')'];
                        end
                    case{0}
                        node_equation{VCCS(i).N1}=[node_equation{VCCS(i).N1} '-' ...
                            num2str(VCCS(i).Transconductance) '*' '(' 'v_' num2str(VCCS(i).NC1) ...
                            '-' 'v_' num2str(VCCS(i).NC2) ')'];
                end
            end
        case{0}
            switch((VCCS(i).NC1==0)||(VCCS(i).NC2==0))
                case{1}
                    if(VCCS(i).NC1==0)
                        node_equation{VCCS(i).N1}=[node_equation{VCCS(i).N1} '-' ...
                            num2str(VCCS(i).Transconductance) '*' '(' '-' 'v_' num2str(VCCS(i).NC2) ')'];
                        node_equation{VCCS(i).N2}=[node_equation{VCCS(i).N2} '+' ...
                            num2str(VCCS(i).Transconductance) '*' '(' '-' 'v_' num2str(VCCS(i).NC2) ')'];
                    else
                        node_equation{VCCS(i).N1}=[node_equation{VCCS(i).N1} '-' ...
                            num2str(VCCS(i).Transconductance) '*' '(' 'v_' num2str(VCCS(i).NC1) ')'];
                        node_equation{VCCS(i).N2}=[node_equation{VCCS(i).N2} '+' ...
                            num2str(VCCS(i).Transconductance) '*' '(' 'v_' num2str(VCCS(i).NC1) ')'];
                    end
                case{0}
                    node_equation{VCCS(i).N1}=[node_equation{VCCS(i).N1} '-' ...
                        num2str(VCCS(i).Transconductance) '*' '(' 'v_' num2str(VCCS(i).NC1) '-' ...
                        'v_' num2str(VCCS(i).NC2) ')'];
                    node_equation{VCCS(i).N2}=[node_equation{VCCS(i).N2} '+' ...
                        num2str(VCCS(i).Transconductance) '*' '(' 'v_' num2str(VCCS(i).NC1) '-' ...
                        'v_' num2str(VCCS(i).NC2) ')'];
            end
    end
end
%%-----------------------------------------------------------------------------
%%Finally, add the current controlled current sources to the node equations
for i=1:num_CCCS
    switch((CCCS(i).N1==0)||(CCCS(i).N2==0))
        case{1}
            if(CCCS(i).N1==0)
                node_equation{CCCS(i).N2}=[node_equation{CCCS(i).N2} ...
                    '+' '(' num2str(CCCS(i).Gain) '*' 'i_' CCCS(i).Vcontrol ')'];
            else
                node_equation{CCCS(i).N1}=[node_equation{CCCS(i).N1} ...
                    '-' '(' num2str(CCCS(i).Gain) '*' 'i_' CCCS(i).Vcontrol ')'];
            end
        case{0}
            node_equation{CCCS(i).N1}=[node_equation{CCCS(i).N1} ...
                '-' '(' num2str(CCCS(i).Gain) '*' 'i_' CCCS(i).Vcontrol ')'];
            node_equation{CCCS(i).N2}=[node_equation{CCCS(i).N2} ...
                '+' '(' num2str(CCCS(i).Gain) '*' 'i_' CCCS(i).Vcontrol ')'];
    end
end
%%-----------------------------------------------------------------------------
%%If solver_flag=0 (purely resistive circuit), add the RHS('=0') to each
%%nodal KCL equation, to each VCVS equation, and to each CCVS equation
if(solver_flag==0)
    for i=1:length(node_equation)
        node_equation{i}=[node_equation{i} '=' '0'];
    end
    for i=1:length(VCVS_equation)
        VCVS_equation{i}=[VCVS_equation{i} '=' '0'];
    end
    for i=1:length(CCVS_equation)
        CCVS_equation{i}=[CCVS_equation{i} '=' '0'];
    end
    %%Else if solver_flag=1 (Pure C, pure L, LC, RC, RL or RLC circuit),do not add the RHS ('=0')
    %%to each nodal KCL equation,VCVS equation and CCVS equation, instead replace the node voltage terms
    %%v_1,v_2,...v_num_Nodes in LHS of all the equations with v(1),v(2),...v(num_Nodes) respectively,
    %%modify each independent voltage source equation to only LHS [no RHS ('=0')] (similar to all the other equations),
    %%also replace the independent voltage source current terms with v(num_Nodes+j) (j=1:num_V)
    %%VCVS current terms with v(num_Nodes+num_V+j) (j=1:num_VCVS)
    %%CCVS current terms with v(num_Nodes+num_V+num_VCVS+j) (j=1:num_CCVS)
    %%and inductor current terms with v(num_Nodes+num_V+num_VCVS+num_CCVS+j) (j=1:num_L)
elseif(solver_flag==1)
    for i=1:num_Nodes %For each nodal KCL equation (only LHS)
        for j=1:num_Nodes
            node_equation{i}=strrep(node_equation{i},['v_' num2str(j)],['v(' num2str(j) ')']);
        end
        for j=1:num_V
            node_equation{i}=strrep(node_equation{i},['i_' Volt_source(j).Name],['v(' num2str(num_Nodes+j) ')']);
        end
        for j=1:num_VCVS
            node_equation{i}=strrep(node_equation{i},['i_' VCVS(j).Name],['v(' num2str(num_Nodes+num_V+j) ')']);
        end
        for j=1:num_CCVS
            node_equation{i}=strrep(node_equation{i},['i_' CCVS(j).Name],['v(' num2str(num_Nodes+num_V+num_VCVS+j) ')']);
        end
        for j=1:num_L
            node_equation{i}=strrep(node_equation{i},['i_' Inductor(j).Name],['v(' num2str(num_Nodes+num_V+num_VCVS+num_CCVS+j) ')']);
        end
    end
    for i=1:num_V %For each independent voltage source equation
        for j=1:num_Nodes
            volt_equation{i}=strrep(volt_equation{i},['v_' num2str(j)],['v(' num2str(j) ')']);
        end
        volt_equation{i}=strrep(volt_equation{i},'=','-');  %Modify each independent voltage source equation to only LHS [no RHS ('=0')]
    end
    for i=1:num_VCVS %For each VCVS equation (only LHS)
        for j=1:num_Nodes
            VCVS_equation{i}=strrep(VCVS_equation{i},['v_' num2str(j)],['v(' num2str(j) ')']);
        end
    end
    for i=1:num_CCVS %For each CCVS equation (only LHS)
        for j=1:num_Nodes
            CCVS_equation{i}=strrep(CCVS_equation{i},['v_' num2str(j)],['v(' num2str(j) ')']);
        end
        for j=1:num_V
            CCVS_equation{i}=strrep(CCVS_equation{i},['i_' Volt_source(j).Name],['v(' num2str(num_Nodes+j) ')']);
        end
        for j=1:num_VCVS
            CCVS_equation{i}=strrep(CCVS_equation{i},['i_' VCVS(j).Name],['v(' num2str(num_Nodes+num_V+j) ')']);
        end
        for j=1:num_CCVS
            CCVS_equation{i}=strrep(CCVS_equation{i},['i_' CCVS(j).Name],['v(' num2str(num_Nodes+num_V+num_VCVS+j) ')']);
        end
    end
    for i=1:num_L %For each inductor equation (only LHS)
        for j=1:num_Nodes
            L_equation{i}=strrep(L_equation{i},['v_' num2str(j)],['v(' num2str(j) ')']);
        end
    end
end
%%-----------------------------------------------------------------------------
eqn=cell(num_Nodes+num_V+num_VCVS+num_CCVS+num_L,1);
for i=1:num_Nodes
    eqn{i}=sym(node_equation{i});
end
for i=1:num_V
    eqn{num_Nodes+i}=sym(volt_equation{i});
end
for i=1:num_VCVS
    eqn{num_Nodes+num_V+i}=sym(VCVS_equation{i});
end
for i=1:num_CCVS
    eqn{num_Nodes+num_V+num_VCVS+i}=sym(CCVS_equation{i});
end
for i=1:num_L
    eqn{num_Nodes+num_V+num_VCVS+num_CCVS+i}=sym(L_equation{i});
end
%%-----------------------------------------------------------------------------
switch(solver_flag)
    case{0}
        %Create the symbolic variables for node voltages and currents through voltage sources
        variables='syms';
        for i=1:num_Nodes
            variables=[variables ' ' 'v_' num2str(i)];
        end
        for i=1:num_V
            variables=[variables ' ' 'i_' Volt_source(i).Name];
        end
        for i=1:num_VCVS
            variables=[variables ' ' 'i_' VCVS(i).Name];
        end
        for i=1:num_CCVS
            variables=[variables ' ' 'i_' CCVS(i).Name];
        end
        eval(variables);
        %----------------------------------------------
        %Create a row vector var of the symbolic variables created above - to be used in solve
        var_string=['var=[' variables(6:end) ']'];
        eval(var_string);
        %----------------------------------------------
        %Create the symbolic variables for the symbolic equations
        equations='syms';
        for i=1:(num_Nodes+num_V+num_VCVS+num_CCVS)
            equations=[equations ' ' 'eqn' num2str(i)];
        end
        eval(equations);
        %----------------------------------------------
        %Create a row vector eqn_solve of the equation symbolic variables
        interm_string=['eqn_solve=[' equations(6:end) ']'];
        eval(interm_string);
        %----------------------------------------------
        %Assign the equation symbolic variables with the corresponding symbolic equations
        for i=1:(num_Nodes+num_V+num_VCVS+num_CCVS)
            eqn_string=['eqn' num2str(i) '=' 'eqn{' num2str(i) '}'];
            eval(eqn_string);
        end
        %----------------------------------------------
        %Solve the symbolic linear equations using solve
        sol=solve(eval(eqn_solve),var);
        %Note :- We use eval(eqn_solve) to substitute the symbolic equation associated with
        %each equation symbolic variable
        %----------------------------------------------
        %Write the node voltages and voltage source currents to newly created
        %Results.txt text file
        F=fopen('Results.txt','wt+');
        date=datetime('now');
        date_string=datestr(date);
        fprintf(F,date_string);
        fprintf(F,'\n');
        fprintf(F,['File name : ' fname]);
        fprintf(F,'\n');
        fprintf(F,'---------------------------------------------------------------------------- \n');
        fprintf(F,'NODE VOLTAGES \n');
        for i=1:num_Nodes
            fprintf(F,['v_' num2str(i) ' = ']);
            fprintf(F,num2str(eval(eval(['sol.v_' num2str(i)]))));
            fprintf(F,'\n');
        end
        fprintf(F,'---------------------------------------------------------------------------- \n');
        if(num_V~=0)
            fprintf(F,'CURRENTS THROUGH INDEPENDENT VOLTAGE SOURCES (NEGATIVE TO POSITIVE TERMINAL) \n');
            for i=1:num_V
                fprintf(F,['i_' Volt_source(i).Name ' = ']);
                fprintf(F,num2str(eval(eval(['sol.i_' Volt_source(i).Name]))));
                fprintf(F,'\n');
            end
            fprintf(F,'----------------------------------------------------------------------------- \n');
        end
        if(num_VCVS~=0)
            fprintf(F,'CURRENTS THROUGH VOLTAGE CONTROLLED VOLTAGE SOURCES (NEGATIVE TO POSITIVE TERMINAL) \n');
            for i=1:num_VCVS
                fprintf(F,['i_' VCVS(i).Name ' = ']);
                fprintf(F,num2str(eval(eval(['sol.i_' VCVS(i).Name]))));
                fprintf(F,'\n');
            end
            fprintf(F,'----------------------------------------------------------------------------- \n');
        end
        if(num_CCVS~=0)
            fprintf(F,'CURRENTS THROUGH CURRENT CONTROLLED VOLTAGE SOURCES (NEGATIVE TO POSITIVE TERMINAL) \n');
            for i=1:num_CCVS
                fprintf(F,['i_' CCVS(i).Name ' = ']);
                fprintf(F,num2str(eval(eval(['sol.i_' CCVS(i).Name]))));
                fprintf(F,'\n');
            end
            fprintf(F,'----------------------------------------------------------------------------- \n');
        end
        type('Results.txt');
        fclose(F);
        %%--------------------------------------------------------------------------
    case{1}
        %Create the state variables
        variables='syms';
        for i=1:(num_Nodes+num_V+num_VCVS+num_CCVS+num_L)
            variables=[variables ' ' 'v' num2str(i) '(t)'];
        end
        eval(variables);
        %-----------------------------------------------
        %Create a row vector var of the state variables - to be used in daeFunction
        var_string=['var=[' variables(6:end) ']'];
        eval(var_string);
        %-----------------------------------------------
        %Convert the symbolic equations (only LHS) to a form suitable for daeFunction
        %Use the converted symbolic equations to make a row vector eqn_daeFunction - to be used in daeFunction
        eqn_string='eqn_daeFunction=[';
        for i=1:length(eqn)
            interm_string=char(eqn{i});
            for j=1:(num_Nodes+num_V+num_VCVS+num_CCVS+num_L)
                interm_string=strrep(interm_string,['v(' num2str(j) ')'],['v' num2str(j) '(t)']);
            end
            for j=1:num_Nodes
                interm_string=strrep(interm_string,['vp(' num2str(j) ')'],['diff(v' num2str(j) ...
                    '(t)' ',t)']);
            end
            for j=1:num_L
                interm_string=strrep(interm_string,['ip(' num2str(j) ')'],['diff(v' num2str(num_Nodes+num_V+num_VCVS+num_CCVS+j) ...
                    '(t)' ',t)']);
            end
            eqn_string=[eqn_string interm_string ','];
        end
        eqn_string=[eqn_string ']'];
        eval(eqn_string);
        %-------------------------------------------------------------------
        %Use daeFunction to create the function handle odefun
        odefun=daeFunction(eqn_daeFunction,var);
        %-------------------------------------------------------------------
        %Use ode15i along with created function handle odefun
        v0=zeros(length(eqn_daeFunction),1); %Initial conditions for v
        vp0=zeros(length(eqn_daeFunction),1); %Initial conditions for v'
        disp('--------------------------------------------------------');
        fprintf('The transient analysis will be performed from t=0 to t=tf');
        fprintf('\n');
        tf=input('Enter the final time value tf in seconds : ');
        options=odeset('RelTol',1e-03,'AbsTol',1e-03);
        [t,v]=ode15i(odefun,[0 tf],v0,vp0,options);
        %-------------------------------------------------------------------
        table_heading=cell(1,(1+num_Nodes+num_V+num_VCVS+num_CCVS+num_L));
        table_heading{1}='Time';
        for j=1:num_Nodes
            table_heading{1+j}=['v_' num2str(j)];
        end
        for j=1:num_V
            table_heading{1+num_Nodes+j}=['i_' Volt_source(j).Name];
        end
        for j=1:num_VCVS
            table_heading{1+num_Nodes+num_V+j}=['i_' VCVS(j).Name];
        end
        for j=1:num_CCVS
            table_heading{1+num_Nodes+num_V+num_VCVS+j}=['i_' CCVS(j).Name];
        end
        for j=1:num_L
            table_heading{1+num_Nodes+num_V+num_VCVS+num_CCVS+j}=['i_' Inductor(j).Name];
        end
        T=array2table([t,v],'VariableNames',table_heading);
        date=datetime('now');
        date_string=datestr(date);
        xlswrite('Results.xls',{date_string});
        xlswrite('Results.xls',{['File name : ' fname]},1,'A2');
        writetable(T,'Results.xls','Range','A4');
        plot(t,v(:,1:num_Nodes)); %Plot the node voltages as a function of time
        legend_voltage='legend(';
        for i=1:num_Nodes
            interm_string=table_heading{1+i};
            interm_string=strrep(interm_string,'_','\_');
            legend_voltage=[legend_voltage '''' interm_string '''' ','];
        end
        legend_voltage(end)=')';
        eval(legend_voltage);
        xlabel('TIME (s)');
        ylabel('NODE VOLTAGES (V)');
        savefig('Voltages_graph.fig');
        if((num_V~=0)||(num_VCVS~=0)||(num_CCVS~=0)||(num_L~=0))
            figure; %Create new figure window
            plot(t,v(:,(num_Nodes+1):end)); %Plot the currents through voltage sources and inductors as a function of time
            legend_current='legend(';
            for i=1:num_V
                interm_string=table_heading{1+num_Nodes+i};
                interm_string=strrep(interm_string,'_','\_');
                legend_current=[legend_current '''' interm_string '''' ','];
            end
            for i=1:num_VCVS
                interm_string=table_heading{1+num_Nodes+num_V+i};
                interm_string=strrep(interm_string,'_','\_');
                legend_current=[legend_current '''' interm_string '''' ','];
            end
            for i=1:num_CCVS
                interm_string=table_heading{1+num_Nodes+num_V+num_VCVS+i};
                interm_string=strrep(interm_string,'_','\_');
                legend_current=[legend_current '''' interm_string '''' ','];
            end
            for i=1:num_L
                interm_string=table_heading{1+num_Nodes+num_V+num_VCVS+num_CCVS+i};
                interm_string=strrep(interm_string,'_','\_');
                legend_current=[legend_current '''' interm_string '''' ','];
            end
            legend_current(end)=')';
            eval(legend_current);
            xlabel('TIME (s)');
            ylabel('CURRENTS (A)');
            savefig('Currents_graph.fig');
        end
end

