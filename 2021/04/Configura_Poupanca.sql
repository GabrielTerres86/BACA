delete from crapind where cddindex = 6;
insert into crapind (CDDINDEX, NMDINDEX, IDPERIOD, IDCADAST, IDEXPRES, PROGRESS_RECID)
values (6, 'POUPANCA', 1, 1, 1, NULL);

delete from crapcpc where cdprodut = 1109;
insert into crapcpc (CDPRODUT, NMPRODUT, IDSITPRO, CDDINDEX, IDTIPPRO, IDTXFIXA, IDACUMUL, CDHSCACC, CDHSVRCC, CDHSRAAP, CDHSNRAP, CDHSPRAP, CDHSRVAP, CDHSRDAP, CDHSIRAP, CDHSRGAP, CDHSVTAP, PROGRESS_RECID, INDPLANO, CDHSRNAP, INDANIVE)
values (1109, 'POUPANCA', 1, 6, 2, 2, 2, 3526, 3529, 3527, 3527, 3530, 3531, 3330, 3332, 3528, 3528, NULL, 0, 3532, 1);

delete from crapnpc where cdprodut = 1109;
insert into CRAPNPC (CDPRODUT, CDNOMENC, DSNOMENC, IDSITNOM, QTMINCAR, QTMAXCAR, VLMINAPL, VLMAXAPL, PROGRESS_RECID)
values (1109, 552, 'POUPANCA', 1, 30, 90, 1.00, 999999999.00, null);

delete from crapmpc where cdprodut = 1109;
insert into crapmpc (CDPRODUT, CDMODALI, QTDIACAR, QTDIAPRZ, VLRFAIXA, VLPERREN, VLTXFIXA, PROGRESS_RECID)
values (1109, null, 30, 9999, 1.00, 0.000001, 0.000000, null);

delete from crapdpc where cdmodali = 1608;
insert into crapdpc (CDCOOPER, CDMODALI, IDSITMOD, PROGRESS_RECID)
values (1, (select CDMODALI from crapmpc where CDPRODUT = 1109), 1, null);

/*
COOP_PILOTO_POUPANCA
0 - Inativa
1 - Piloto para algumas contas
2 - Ativa
*/
insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 1, 'COOP_PILOTO_POUPANCA_PF', 'Indica se a cooperativa habilita contratacao de POUPANCA (0=Inativa,1=Piloto para algumas contas,2=Ativa)', '1');
/*
CONTAS_PILOTO_POUPANCA
O número da conta entre "," Ex.: ,329,4123,
*/
insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 1, 'CONTA_PILOTO_POUPANCA_PF', 'Indica as contas piloto para a POUPANCA', ',329,');

--script para cadastrar a cooperativa para rentabilizar a poupança
insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM) 
values ('CRED', 1, 'CAPT_POUPANCA_RENT_ATIVA', 'Indica se a rentabilidade da poupanca esta ativa para a cooperativa', '1');

INSERT INTO craptxi (cddindex, dtiniper, dtfimper, vlrdtaxa, dtcadast)
SELECT 6 cddindex
      ,mfx.dtmvtolt dtiniper
      ,mfx.dtmvtolt dtfimper
      ,round(mfx.vlmoefix,4) vlrdtaxa
      ,mfx.dtmvtolt dtcadast
  FROM crapmfx mfx
 WHERE mfx.tpmoefix = 20
   AND mfx.dtmvtolt >= to_date('01012015', 'ddmmyyyy')
   AND mfx.cdcooper = 1;

COMMIT;
