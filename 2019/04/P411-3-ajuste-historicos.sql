

insert into tbgen_batch_param (idparametro, qtparalelo, qtreg_transacao, cdcooper, cdprograma) values ((select max(idparametro)+1 from tbgen_batch_param),10,0,1,'CRPS753');


Insert into crapprg(
select 'CRED' nmsistem
      ,'CRPS753' cdprogra
      ,'Calcula saldo das aplicacoes' dsprogra##1
      ,' ' dsprogra##2
      ,' ' dsprogra##3
      ,' ' dsprogra##4
      ,32 nrsolici
      ,3 nrordprg
      ,2 inctrprg
      ,0 cdrelato##1
      ,0 cdrelato##2
      ,0 cdrelato##3
      ,0 cdrelato##4
      ,0 cdrelato##5
      ,1 inlibprg
      ,cdcooper
      ,null progress_recid
      ,null qtminmed      
  from crapcop
 where flgativo = 1
   and cdcooper <> 3);


delete from TBCAPT_HISTOR_OPERAC_B3 where cdhistorico in (476, 533);

/* RDC POS*/
insert into TBCAPT_HISTOR_OPERAC_B3 (idhistorico_operac, tpaplicacao, cdhistorico, idtipo_arquivo, idtipo_lancto, cdoperacao_b3) 
values (null, 2, 533, 2, 3/*IR*/  , '0314');
insert into TBCAPT_HISTOR_OPERAC_B3 (idhistorico_operac, tpaplicacao, cdhistorico, idtipo_arquivo, idtipo_lancto, cdoperacao_b3)
values (null, 2, 532, 2, 4/*Rend*/, '0314');

/* RDC PRE */
insert into TBCAPT_HISTOR_OPERAC_B3 (idhistorico_operac, tpaplicacao, cdhistorico, idtipo_arquivo, idtipo_lancto, cdoperacao_b3) 
values (null, 1, 476, 2, 3/*IR*/  , '0314');
insert into TBCAPT_HISTOR_OPERAC_B3 (idhistorico_operac, tpaplicacao, cdhistorico, idtipo_arquivo, idtipo_lancto, cdoperacao_b3)
values (null, 1, 475, 2, 4/*Rend*/, '0314');

INSERT INTO crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM, PROGRESS_RECID) values
('CRED',0,'CD_TOLERANCIA_DIF_VALOR','Percentual de Tolerância para Conciliação',',1',NULL);

commit;
