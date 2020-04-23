--INC0037000 - atualizar a data de retirada.

update crapfdc
set dtretchq = trunc(sysdate)
where nrdconta = 856819
  and cdcooper = 1
  and nrseqems = 153
  and nrpedido = 148065
  and nrcheque in (2940,2941,2942,2943,2944,2945,2946,2947,2948,2949,2950,2951,2952,2953,2954,2955,2956,2957,2958); 

update crapfdc
set dtretchq = trunc(sysdate)
where nrdconta = 2732165
  and cdcooper = 1
  and nrseqems = 52
  and nrpedido = 100890
  and nrcheque in (511,512,513,514,515,516,517,518,519,520); 

update crapfdc
set dtretchq = trunc(sysdate)
where nrdconta = 6122221
  and cdcooper = 1
  and nrseqems = 10
  and nrpedido = 35584
  and nrcheque in (91,92,93,94,95,96,97,98,99,100); 


update crapfdc
set dtretchq = trunc(sysdate)
where nrdconta = 6897061
  and cdcooper = 1
  and nrseqems = 47
  and nrpedido = 146245
  and nrcheque in (461,462,464,465,466,467,468,469,470); 


update crapfdc
set dtretchq = trunc(sysdate)
where nrdconta = 9805303
  and cdcooper = 1
  and nrseqems = 2
  and nrpedido = 145127
  and nrcheque in (11,13,14,15,16,17,18,19,20);
  

update crapfdc
set dtretchq = trunc(sysdate)
where nrdconta = 152480
  and cdcooper = 5
  and nrseqems = 8
  and nrpedido = 147789
  and nrcheque = 72; 
  
update crapfdc
set dtretchq = trunc(sysdate)
where nrdconta = 380920
  and cdcooper = 11
  and nrseqems = 4
  and nrpedido = 145272
  and nrcheque = 33; 

update crapfdc
set dtretchq = trunc(sysdate)
where nrdconta = 613096
  and cdcooper = 16
  and nrseqems = 53
  and nrpedido = 150219
  and nrcheque = 981; 


update crapfdc
set dtretchq = trunc(sysdate)
where nrdconta = 6546455
  and cdcooper = 16
  and nrseqems = 62
  and nrpedido = 150585
  and nrcheque in (741,742,743,744,745,746,747,748); 
  
COMMIT;  
