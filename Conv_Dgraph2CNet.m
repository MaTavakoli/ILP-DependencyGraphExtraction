clc
clear
filter=1;
Tpat=0; %a parameter in Fodina Paper related to split/join filtering. it can be between -1 t0 1.
log_filename='E:\paper\SecondLevel\syntetic petri nets\30n20_filtered.csv';
Graph_filename='E:\paper\SecondLevel\syntetic petri nets\result\mine\30maxinoutput4\30n20(2).xls';
FlexName='30n20(2).flex';
start_end_marking=1;

outputfile_name='E:\paper\first level\Edited\Case Study\artificial_gams.xlsx';

[G,GT]=xlsread(Graph_filename);
G=G==1;


[M N]=xlsread(log_filename);

mode=2;
if size(N{2,1},2)~=0
    mode=1;
     %mode=1 if case ID is string. 2 if case ID is number
end


 
if mode==2
    casenum=zeros(size(M,1),1);
    casenum(1)=1;
    j=1;
    
    
    for i=2:size(M,1)
        if M(i)~=M(i-1)  %strcmp baraye barresi yeksan boodan stringha be kar miravad. dar soorati k yeksan bashand 1 va dar gheyre in soorat sefr midahad.
            %         if strcmp(N{i+1,1},N{i,1})~=1
            j=j+1;
        end
        casenum(i)=j;
    end
    
    
end

if mode==1
    casenum=zeros(size(N,1)-1,1);
    casenum(1)=1;
    j=1;
    
    
    for i=2:size(N,1)-1
        %     if M(i)~=M(i-1)  %strcmp baraye barresi yeksan boodan stringha be kar miravad. dar soorati k yeksan bashand 1 va dar gheyre in soorat sefr midahad.
        if strcmp(N{i+1,1},N{i,1})~=1
            j=j+1;
        end
        casenum(i)=j;
    end
end


eventnames={N{2,2}};
eventnum=zeros(size(N,1),1);
j=1;
'1'
for i=2:size(N,1)
    tf = strcmp(N{i,2},eventnames);
    j=find(tf==1);
    if sum(tf(:))==0
        j=size(tf,2)+1;
        eventnames=[eventnames,N{i,2}];
    end
    eventnum(i)=j;
end

eventnum=eventnum(2:end);


G2=zeros(size(eventnames,2),size(eventnames,2));
for i=2:size(GT,1)
    for ii=2:size(GT,2)
        if G(i-1,ii-1)==1
            tf = strcmp(GT{i,1},eventnames);
            j=find(tf==1);
            tf = strcmp(GT{1,ii},eventnames);
            jj=find(tf==1);
            G2(j,jj)=1;
        end      
    end
end


%preparing footprint of logs
'2'
task_freq=zeros(1,length(eventnames));
input_bindings=cell(1,length(eventnames));
output_bindings=cell(1,length(eventnames));
for k=1:casenum(end)
    %     foot_trace=zeros(size(eventnames,2));
    traceindex=find(casenum==k);
    trace=eventnum(traceindex);
    %     loop_trace=zeros(size(eventnames,2));
    for hh=1:size(trace,1)-1
        ev1=trace(hh);
        task_freq(ev1)=task_freq(ev1)+1;
        outputmembers=[];
        
        for jj=hh+1:size(trace,1)
%             jj
            ev2=trace(jj);
            if G2(ev1,ev2)==1
                if jj==hh+1
                    outputmembers=[outputmembers,ev2];
                else
                    tr2=trace(hh+1:jj-1);
                    inputs_ev2=find(G2(:,ev2)==1);
                    if sum(ismember(inputs_ev2,tr2))==0
                        outputmembers=[outputmembers,ev2];
                    end
                    
                end
            end
            if ev2==ev1
                break
            end
            
            
            
        end
        outputmembers=unique(outputmembers);
        if isempty(outputmembers)==0
            if isempty(output_bindings{ev1})==1
                output_bindings{ev1}=[output_bindings{ev1},{{outputmembers,1}}];           
            else
                exist=0;
                for gg=1:size(output_bindings{ev1},2)
                    oo=output_bindings{ev1}{gg}{1};
                    if (length(outputmembers)==sum(ismember(outputmembers,oo))) && (length(outputmembers)==length(oo))
                        output_bindings{ev1}{gg}{2}=output_bindings{ev1}{gg}{2}+1;
                        exist=1;
                        break
                    end
                end
                if exist==0
                    output_bindings{ev1}=[output_bindings{ev1},{{outputmembers,1}}];
                end

            end
        end
        
    end
    
    
    task_freq(trace(end))=task_freq(trace(end))+1;
    
    
    for hh=2:size(trace,1)
        ev1=trace(hh);
        inputmembers=[];
        
        for jj=hh-1:-1:1
            ev2=trace(jj);
            if G2(ev2,ev1)==1
                if jj==hh-1
                    inputmembers=[inputmembers,ev2];
                else
                    tr2=trace(jj+1:hh-1);
                    outputs_ev2=find(G2(ev2,:)==1);
                    if sum(ismember(outputs_ev2,tr2))==0
                        inputmembers=[inputmembers,ev2];
                    end
                    
                end
            end
            if ev2==ev1
                break
            end
        end
        
        inputmembers=unique(inputmembers);
        if isempty(inputmembers)==0
            if isempty(input_bindings{ev1})==1
                input_bindings{ev1}=[input_bindings{ev1},{{inputmembers,1}}];           
            else
                exist=0;
                for gg=1:size(input_bindings{ev1},2)
                    oo=input_bindings{ev1}{gg}{1};
                    if (length(inputmembers)==sum(ismember(inputmembers,oo))) && (length(inputmembers)==length(oo))
                        input_bindings{ev1}{gg}{2}=input_bindings{ev1}{gg}{2}+1;
                        exist=1;
                        break
                    end
                end
                if exist==0
                    input_bindings{ev1}=[input_bindings{ev1},{{inputmembers,1}}];
                end

            end
        end
    end   
end
'3'


    filtered_input_bindings=cell(1,length(eventnames));
    tr=zeros(1,length(eventnames));
    for ii=1:length(eventnames)
        tr=0;
        if filter==1
            for jj=1: length(input_bindings{ii})
                tr=tr+input_bindings{ii}{jj}{2}/(task_freq(ii)*length(input_bindings{ii}));
            end
            if Tpat<=0
                tr=tr+Tpat*tr;
            else
                tr=tr+Tpat*(1-tr);
            end
        end
        all=[];
        for jj=1: length(input_bindings{ii})
            if (input_bindings{ii}{jj}{2}/task_freq(ii))>=tr
                filtered_input_bindings{ii}=[filtered_input_bindings{ii},{input_bindings{ii}{jj}{1}}];
                all=[all,input_bindings{ii}{jj}{1}];
            end
        end
        input_nodes=find(G2(:,ii)==1);
        for kk=1:length(input_nodes)
            if sum(ismember(input_nodes(kk),all))==0
                filtered_input_bindings{ii}=[filtered_input_bindings{ii},{[input_nodes(kk)]}];

            end
        end
    end

    filtered_output_bindings=cell(1,length(eventnames));
    for ii=1:length(eventnames)
        tr=0;
        if filter==1
            for jj=1: length(output_bindings{ii})
                tr=tr+output_bindings{ii}{jj}{2}/(task_freq(ii)*length(output_bindings{ii}));
            end
            if Tpat<=0
                tr=tr+Tpat*tr;
            else
                tr=tr+Tpat*(1-tr);
            end
        end

        all=[];
        for jj=1: length(output_bindings{ii})
            if (output_bindings{ii}{jj}{2}/task_freq(ii))>=tr
                filtered_output_bindings{ii}=[filtered_output_bindings{ii},{output_bindings{ii}{jj}{1}}];
                all=[all,output_bindings{ii}{jj}{1}];
            end
        end
        output_nodes=find(G2(ii,:)==1);
        for kk=1:length(output_nodes)
            if sum(ismember(output_nodes(kk),all))==0
                filtered_output_bindings{ii}=[filtered_output_bindings{ii},{[output_nodes(kk)]}];

            end
        end
    end






tasknames=eventnames;
pp=G2;
outputbindings=filtered_output_bindings;
inputbindings=filtered_input_bindings;


sp=sum(pp);
start_node=find(sp==0);
sp2=sum(pp,2);
end_node=find(sp2==0);

fileID = fopen(FlexName,'w');
fprintf(fileID,['<?xml version="1.0" encoding="ISO-8859-1"?><cnet><net type="http://www.processmining.org" id="',FlexName(1:end-5) ,'" /><name>Flexible model of ', FlexName(1:end-5),'</name>']);

for i=1:size(tasknames,2)
    x=['<node id="',num2str(i),'" isInvisible="false"><name>',tasknames{i},'</name></node>'];
    fprintf(fileID,x);
end
% start_node=start_node(1);
% end_node=end_node(1);
if start_end_marking==1
    x=['<startTaskNode id="',num2str(start_node(1)),'"/><endTaskNode id="',num2str(end_node(1)),'"/>'];
    fprintf(fileID,x);
end

for i=1:size(tasknames,2)
    
    
    if i~=start_node
%         <inputNode id="1"><inputSet><node id="0" /></inputSet></inputNode>
        x=['<inputNode id="',num2str(i),'">'];
        fprintf(fileID,x);
        qq=inputbindings{i};
        for j=1:max(size(qq))
            x=['<inputSet>'];
            ww=qq{j};
            for k=1:max(size(ww))
                x=[x,'<node id="',num2str(ww(k)),'" />'];
            end
            x=[x,'</inputSet>'];
            fprintf(fileID,x);
 
        end
        
        
        x='</inputNode>';
        fprintf(fileID,x);
        
    end
    
    if i~=end_node
%         <outputNode id="1"><outputSet><node id="3" /></outputSet></outputNode>
        x=['<outputNode id="',num2str(i),'">'];
        fprintf(fileID,x);
        qq=outputbindings{i};
        for j=1:max(size(qq))
            x=['<outputSet>'];
            ww=qq{j};
            for k=1:max(size(ww))
                x=[x,'<node id="',num2str(ww(k)),'" />'];
            end
            x=[x,'</outputSet>'];
            fprintf(fileID,x);
 
        end
%         x
%         fprintf(fileID,x);
        x='</outputNode>';
        fprintf(fileID,x);
        
    end
end

% <arc id="10" source="1" target="3" />
[xc,yc]=find(pp==1);
for i=1:max(size(xc))
    x=['<arc id="',num2str(i),'" source="',num2str(xc(i)),'" target="',num2str(yc(i)),'" />'];
    fprintf(fileID,x);
end
x='</cnet>';
 fprintf(fileID,x);


fclose(fileID);

