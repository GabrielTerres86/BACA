
insert into crapind (CDDINDEX, NMDINDEX, IDPERIOD, IDCADAST, IDEXPRES, PROGRESS_RECID)
values (5, 'IPCA NUMERICO', 2, 1, 1, null);


insert into crapprg ( 
select 'CRED' nmsistem
      ,'CRPS795' cdprogra
      ,'Gera relatorio mensal de produtos de captacao PCAPTA' DSPROGRA##1
      ,'.' DSPROGRA##2
      ,'.' DSPROGRA##3
      ,'.' DSPROGRA##4
      ,999 NRSOLICI
      ,1215 NRORDPRG
      ,1 INCTRPRG
      ,823 CDRELATO##1
      ,0 CDRELATO##2
      ,0 CDRELATO##3
      ,0 CDRELATO##4
      ,0 CDRELATO##5
      ,1 INLIBPRG
      ,cdcooper
      ,null progress_recid
      ,null qtminmed
from crapcop
where flgativo = 1
);

commit;