 
update crapfdc fdc
  set fdc.dtretchq = trunc(SYSDATE), fdc.dtliqchq = trunc(SYSDATE), fdc.incheque = 8   
where  cdcooper = 1
  and  incheque = 0
  and  progress_recid >= 37899001 AND progress_recid <= 42345362 /*usar a chave*/
  and  dtliqchq is null
  and  dtretchq is null
  and  cdbantic = 0
  and  dtemschq between to_date('01/01/2015','DD/MM/YYYY') and to_date('31/12/2015','DD/MM/YYYY');
commit;   

update crapfdc fdc
  set fdc.dtretchq = trunc(SYSDATE), fdc.dtliqchq = trunc(SYSDATE), fdc.incheque = 8   
where  cdcooper = 1
  and  incheque = 0  
  and  progress_recid >= 42359019 AND progress_recid <= 46448476  /*usar a chave*/
  and  dtretchq is null
  and  dtliqchq is null
  and  cdbantic = 0
  and  dtemschq between to_date('01/01/2016','DD/MM/YYYY') and to_date('31/12/2016','DD/MM/YYYY');
commit;    

update crapfdc fdc
  set fdc.dtretchq = trunc(SYSDATE), fdc.dtliqchq = trunc(SYSDATE), fdc.incheque = 8   
where  cdcooper = 1
  and  incheque = 0
  and  progress_recid >= 46459841 AND progress_recid <= 50698377 /*usar a chave*/
  and  dtretchq is null
  and  dtliqchq is null
  and  cdbantic = 0
  and  dtemschq between to_date('01/01/2017','DD/MM/YYYY') and to_date('31/12/2017','DD/MM/YYYY');
commit;    

 
update crapfdc fdc
  set fdc.dtretchq = trunc(SYSDATE), fdc.dtliqchq = trunc(SYSDATE), fdc.incheque = 8   
where  cdcooper = 1
  and  incheque = 0
  and  progress_recid >= 50704938 AND progress_recid <= 54388477 /*usar a chave*/
  and  dtliqchq is null
  and  dtretchq is null
  and  cdbantic = 0
  and  dtemschq between to_date('01/01/2018','DD/MM/YYYY') and to_date('31/12/2018','DD/MM/YYYY');
commit;  

update crapfdc fdc
  set fdc.dtretchq = trunc(SYSDATE), fdc.dtliqchq = trunc(SYSDATE), fdc.incheque = 8   
where  cdcooper = 1
  and  incheque = 0
  and  progress_recid >= 54396758 AND progress_recid <= 58160637 /*usar a chave*/
  and  dtliqchq is null
  and  dtretchq is null
  and  cdbantic = 0
  and  dtemschq between to_date('01/01/2019','DD/MM/YYYY') and to_date('31/12/2019','DD/MM/YYYY');
commit; 

update crapfdc fdc
  set fdc.dtretchq = trunc(SYSDATE), fdc.dtliqchq = trunc(SYSDATE), fdc.incheque = 8   
where  cdcooper = 1
  and  incheque = 0
  and  progress_recid >= 58169218 AND progress_recid <= 60177637 /*usar a chave*/
  and  dtretchq is null
  and  dtliqchq is null
  and  cdbantic = 0
  and  dtemschq between to_date('01/01/2020','DD/MM/YYYY') and to_date('30/08/2020','DD/MM/YYYY');
commit;    
   
 




