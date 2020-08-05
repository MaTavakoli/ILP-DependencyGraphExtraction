*tolerance ra barabar ba meghdar nazdik be yek migazarim:
option optcr=0.0000000001;
$onecho > taskin.txt
dset=i rng=b1:cw1 cdim=1
dset=start_nodes rng=sheet2!b1:z1 cdim=1
dset=end_nodes rng=sheet2!b2:z2 cdim=1
par=DG cdim=1 rdim=1 rng=a1:cw101
par=alpha  rdim=1 rng=sheet2!a8:b84
par=P  cdim=1 rdim=1 rng=sheet3!a1:cw101
par=short_loop cdim=1 rdim=1 rng=sheet4!a1:cw101

$offecho

$call gdxxrw.exe E:\paper\SecondLevel\GAMS\70n20_filtered_DG.xlsx @taskin.txt
$gdxin 70n20_filtered_DG.gdx
sets
         i       set of tasks

;
$load i

sets

         start_nodes(i)
         end_nodes(i)
;
$load   start_nodes , end_nodes



         alias(i,j);
         alias(i,k);

scalar
         M a large number /100000/
;

scalar MaxEdges /200/;
*MaxEdges=card(i)*1.5;
display  MaxEdges;

scalar
         MaxOutputs  /4/
;

scalar
         MaxInputs  /4/
;

parameters
         alpha(k)

;
$load alpha
parameter DG(i,j)
;
$load DG

parameters P(i,j)
;
$load P

parameters short_loop(i,j)
;
$load short_loop

$gdxin

;
display i,alpha, DG, P;




parameter end_ord2(i,end_nodes);
parameter end_ord(i) dar soorati k i barabar ba end node bashad end_ord(i) barabarba yek mishavad
;

end_ord2(i,end_nodes)=0;
end_ord2(i,end_nodes)$(sameAs(i,end_nodes)) =1;
end_ord(i)=0;
end_ord(i)=sum(end_nodes,end_ord2(i,end_nodes));
display end_ord;

parameter D(i,j);
D(i,j)=(DG(i,j)-DG(j,i))/(DG(i,j)+DG(j,i)+1);
D(i,j)$(sameAs(i,j))=DG(i,j)/(DG(i,j)+1);
Display D;

parameter L(i,j);
L(i,j)= (short_loop(i,j))/(short_loop(i,j)+1);
L(i,j)$(sameAs(i,j))=0;
display L;






parameter start_ord2(i,start_nodes);
parameter start_ord(i) dar soorati k i barabar ba start node bashad start_ord(i) barabarba yek mishavad
;

start_ord2(i,start_nodes)=0;
start_ord2(i,start_nodes)$(sameAs(i,start_nodes)) =1;
start_ord(i)=0;
start_ord(i)=sum(start_nodes,start_ord2(i,start_nodes));
display start_ord;





variable
         z


;

binary variable
         AperB(i,j)  a-->b
         r(i,j)  a lenght-two-loop b
         x(i,j)
         x2(i,j)





;
integer variable
         u(i)
         u2(i)
;
equation
         CI

         eq7
         eq8
         eq9
         eq10
         eq11
         eq12
         eq13
         eq14
         eq15
         eq16
         eq17
         eq18
         eq19


;

CI..z=e=sum((i,j),D(i,j)*AperB(i,j))+sum((i,j)$(ord(i)<ord(j)),L(i,j)*r(i,j));

eq7..sum((i,j)$(start_ord(j)=1),AperB(i,j))=e=0;
eq8..sum((i,j)$(end_ord(i)=1),AperB(i,j))=e=0;

eq9(i,j)..x(i,j)=l=AperB(i,j);
eq10(i,j)..u(i)-u(j)+x(i,j)*card(i)=l=card(i)-1;
eq11(j)$(start_ord(j)=0)..sum(i,x(i,j))=e=1;

eq12(i,j)..x2(i,j)=l=AperB(i,j);
eq13(i,j)..u2(i)-u2(j)+x2(i,j)*card(i)=l=card(i)-1;
eq14(i)$(end_ord(i)=0)..sum(j,x2(i,j))=e=1;

eq15(i,j)$(ord(i)<ord(j))..r(i,j)=g=AperB(i,j)+AperB(j,i)-1;
eq16(i,j)$(ord(i)<ord(j))..r(i,j)=l=(AperB(i,j)+AperB(j,i))/2;
eq17..sum((i,j),AperB(i,j))=l=MaxEdges;
eq18(i)..sum(j,AperB(i,j))=l=MaxOutputs;
Eq19(j)..sum(i,AperB(i,j))=l=MaxInputs;




***********************************************

model
        Dependency_Graph /all/
;
*model
*        process_precision /precision, eq1_1, eq1_2, eq1_3, eq1_4,eq1_5,eq1_6, eq2_1_1, eq2_1_2, eq2_1_3, eq2_1_4, eq2_1_5,eq2_1_6,eq2_1_7, eq2_2_1, eq2_2_2, eq2_2_3, eq2_2_4, eq2_2_5,eq2_2_6,eq2_2_7, eq2_3,eq2_4,eq2_5 eq3, eq4/
*;


solve
         Dependency_Graph using mip maximizing z

;


scalar CI_opt;
CI_opt=z.l;
display CI_opt;

execute_unload "FilteredEventLog_DG.gdx" AperB.L
execute 'gdxxrw.exe FilteredEventLog_DG.gdx o=E:\paper\SecondLevel\GAMS\FilteredEventLog.xls var AperB.L'


*execute_unload "sepsis.gdx" AperB.L  r.L
*execute 'gdxxrw.exe sepsis.gdx o=E:\paper\SecondLevel\GAMS\sepsis.xls var AperB.L'
*execute 'gdxxrw.exe sepsis.gdx o=E:\paper\SecondLevel\GAMS\sepsis.xls var r.L rng=NewSheet!a1:Z28'









