update 
	crappro pro 
set 
	pro.dsinform##3 = replace(pro.dsinform##3, '#Agente Arrecadador: #Agência:', '#Agente Arrecadador: 93 - P0LOCRED SOCIEDADE DE CREDITO AO MICROEMPREENDEDOR #Agência: 9999 - P0LOCRED SOCIEDADE DE CREDITO AO MICROEMPREENDEDOR')
where 
	pro.cdcooper >= 1 
	and pro.cdtippro = 16 
	and pro.dtmvtolt between '06/05/2021' and '27/05/2021' 
	and pro.dsinform##3 like '%#Agente Arrecadador: #Agência: %';

commit;