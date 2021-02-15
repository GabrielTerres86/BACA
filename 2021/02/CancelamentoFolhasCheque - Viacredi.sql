 
update crapfdc fdc
  set fdc.dtretchq = trunc(SYSDATE), fdc.dtliqchq = trunc(SYSDATE), fdc.incheque = 8   
where  cdcooper = 1
  and  incheque = 0
  and  dtretchq is null
  and  cdbantic = 0
  and  dtemschq between to_date('01/01/2015','DD/MM/YYYY') and to_date('31/12/2015','DD/MM/YYYY');
commit;   

update crapfdc fdc
  set fdc.dtretchq = trunc(SYSDATE), fdc.dtliqchq = trunc(SYSDATE), fdc.incheque = 8   
where  cdcooper = 1
  and  incheque = 0
  and  dtretchq is null
  and  cdbantic = 0
  and  dtemschq between to_date('01/01/2016','DD/MM/YYYY') and to_date('31/12/2016','DD/MM/YYYY');
commit;    

update crapfdc fdc
  set fdc.dtretchq = trunc(SYSDATE), fdc.dtliqchq = trunc(SYSDATE), fdc.incheque = 8   
where  cdcooper = 1
  and  incheque = 0
  and  dtretchq is null
  and  cdbantic = 0
  and  dtemschq between to_date('01/01/2017','DD/MM/YYYY') and to_date('31/12/2017','DD/MM/YYYY');
commit;    

 
update crapfdc fdc
  set fdc.dtretchq = trunc(SYSDATE), fdc.dtliqchq = trunc(SYSDATE), fdc.incheque = 8   
where  cdcooper = 1
  and  incheque = 0
  and  dtretchq is null
  and  cdbantic = 0
  and  dtemschq between to_date('01/01/2018','DD/MM/YYYY') and to_date('31/12/2018','DD/MM/YYYY');
commit;  

update crapfdc fdc
  set fdc.dtretchq = trunc(SYSDATE), fdc.dtliqchq = trunc(SYSDATE), fdc.incheque = 8   
where  cdcooper = 1
  and  incheque = 0
  and  dtretchq is null
  and  cdbantic = 0
  and  dtemschq between to_date('01/01/2019','DD/MM/YYYY') and to_date('31/12/2019','DD/MM/YYYY');
commit; 

update crapfdc fdc
  set fdc.dtretchq = trunc(SYSDATE), fdc.dtliqchq = trunc(SYSDATE), fdc.incheque = 8   
where  cdcooper = 1
  and  incheque = 0
  and  dtretchq is null
  and  cdbantic = 0
  and  dtemschq between to_date('01/01/2020','DD/MM/YYYY') and to_date('30/08/2020','DD/MM/YYYY');
commit;    
   
 




