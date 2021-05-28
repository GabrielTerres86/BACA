update 
	crappro pro 
set 
	pro.dsinform##3 = replace(pro.dsinform##3, '#Agente Arrecadador: #Agência:', '#Agente Arrecadador: 93 - P0LOCRED SOCIEDADE DE CREDITO AO MICROEMPREENDEDOR #Agência: 9999 - P0LOCRED SOCIEDADE DE CREDITO AO MICROEMPREENDEDOR')
where 
	p.cdcooper >= 1 
	and p.cdtippro = 16 
	and p.dtmvtolt between '06/05/2021' and '27/05/2021' 
	and p.dsinform##3 like '%#Agente Arrecadador: #Agência: %';

commit;