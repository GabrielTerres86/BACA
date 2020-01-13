--------------------------------------------------------------------------------
-- INCLUSÃO DE PARAMETRO DO VALOR DO LIMITE/DIA DO DEPOSITO DE CHEQUE NA TB045
--------------------------------------------------------------------------------
-- **** Deverá ser feito o script para todas as cooperativas, verifica os valores para pessoa fisica e juridica
-- **** Deverá ter o valor para o Operacional e para Ailos
update craptab 
set dstextab = dstextab||'000000002000,00;000000300000,00'
where  craptab.nmsistem = 'CRED' and
                            craptab.tptabela = 'GENERI'     AND
                            craptab.cdempres = 0            AND
                            craptab.cdacesso = 'LIMINTERNT' and
                            craptab.cdcooper = 1  and    -- coperativa
                            craptab.tpregist in (1,2); --  fisica e Juridica
COMMIT;

--------------------------------------- 
-- INCLUSÃO DE PARAMETRO DE E-MAIL
---------------------------------------
-- select * from crapprm where upper(cdacesso) like '%EMAIL_CHEQUE_MOBILE%'
-- Script para cadastrar email utilizado no processo do termo de aceito do deposito de cheque mobile
-- ******* Deverá ser cadastrado para todas as cooperativas  ***********
insert into crapprm 
values ('CRED',1,'EMAIL_CHEQUE_MOBILE', 'Email utilizado processo de deposito de cheque Mobile','josiane.stiehler@amcom.com.br',null);

COMMIT;





----------------------------------------------------------------------------------------
-- INICIO DML TELA CHQMOB

DECLARE
  TYPE Cooperativas IS TABLE OF integer;
  coop Cooperativas := Cooperativas(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17);

  pr_cdcooper INTEGER;
BEGIN

  FOR i IN coop.FIRST .. coop.LAST LOOP
    pr_cdcooper := coop(i);
    -- Insere a tela
    INSERT INTO craptel
      (nmdatela,
       nrmodulo,
       cdopptel,
       tldatela,
       tlrestel,
       flgteldf,
       flgtelbl,
       nmrotina,
       lsopptel,
       inacesso,
       cdcooper,
       idsistem,
       idevento,
       nrordrot,
       nrdnivel,
       nmrotpai,
       idambtel)
      SELECT 'CHQMOB',
             5,
             'L,P,E',
             'Cheque Mobile',
             'Cheque Mobile',
             0,
             1, -- bloqueio da tela 
             ' ',
             'LIBERACAO,PARAMETROS,ESTORNO',
             1,
             pr_cdcooper, -- cooperativa
             1,
             0,
             0,
             0,
             '',
             2
        FROM crapcop
       WHERE cdcooper = pr_cdcooper;
  
    -- Permissões de consulta para os usuários pré-definidos pela CECRED                       
    INSERT INTO crapace
      (nmdatela,
       cddopcao,
       cdoperad,
       nmrotina,
       cdcooper,
       nrmodulo,
       idevento,
       idambace)
      SELECT 'CHQMOB', 'L', ope.cdoperad, ' ', cop.cdcooper, 1, 0, 2
        FROM crapcop cop, crapope ope
       WHERE cop.cdcooper IN (pr_cdcooper)
         AND ope.cdsitope = 1
         AND cop.cdcooper = ope.cdcooper
         AND trim(upper(ope.cdoperad)) = '1';
  
    -- Permissões de consulta para os usuários pré-definidos pela CECRED
    INSERT INTO crapace
      (nmdatela,
       cddopcao,
       cdoperad,
       nmrotina,
       cdcooper,
       nrmodulo,
       idevento,
       idambace)
      SELECT 'CHQMOB', 'P', ope.cdoperad, ' ', cop.cdcooper, 1, 0, 2
        FROM crapcop cop, crapope ope
       WHERE cop.cdcooper IN (pr_cdcooper)
         AND ope.cdsitope = 1
         AND cop.cdcooper = ope.cdcooper
         AND trim(upper(ope.cdoperad)) = '1';
  
    -- Permissões de consulta para os usuários pré-definidos pela CECRED                       
    INSERT INTO crapace
      (nmdatela,
       cddopcao,
       cdoperad,
       nmrotina,
       cdcooper,
       nrmodulo,
       idevento,
       idambace)
      SELECT 'CHQMOB', 'E', ope.cdoperad, ' ', cop.cdcooper, 1, 0, 2
        FROM crapcop cop, crapope ope
       WHERE cop.cdcooper IN (pr_cdcooper)
         AND ope.cdsitope = 1
         AND cop.cdcooper = ope.cdcooper
         AND trim(upper(ope.cdoperad)) = '1';

           
    -- Insere o registro de cadastro do programa
    INSERT INTO crapprg
      (nmsistem,
       cdprogra,
       dsprogra##1,
       dsprogra##2,
       dsprogra##3,
       dsprogra##4,
       nrsolici,
       nrordprg,
       inctrprg,
       cdrelato##1,
       cdrelato##2,
       cdrelato##3,
       cdrelato##4,
       cdrelato##5,
       inlibprg,
       cdcooper)
      SELECT 'CRED',
             'CHQMOB',
             'Cheque Mobile',
             '.',
             '.',
             '.',
             50,
             (select max(crapprg.nrordprg) + 1
                from crapprg
               where crapprg.cdcooper = crapcop.cdcooper
                 and crapprg.nrsolici = 50),
             1,
             0,
             0,
             0,
             0,
             0,
             1,
             cdcooper
        FROM crapcop
       WHERE cdcooper IN (pr_cdcooper);
  
  END LOOP;

  COMMIT;
END;
------------------------------------------------------------------

-- armazenar tela para interface web
INSERT INTO CRAPRDR (NMPROGRA, DTSOLICI) values ('TELA_CHQMOB', sysdate);
COMMIT;

-- Crapaca ------------------------------------------------------
INSERT INTO CRAPACA (NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
VALUES ('BUSCA_LIB_DEP_MOBILE','TELA_CHQMOB','pc_busca_lib_dep_mobile','',(SELECT a.nrseqrdr FROM CRAPRDR a WHERE a.nmprogra = 'TELA_CHQMOB' AND ROWNUM = 1));

INSERT INTO CRAPACA (NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
VALUES ('ALTERA_LIB_DEP_MOBILE','TELA_CHQMOB','pc_altera_lib_dep_mobile','pr_cdcooper, pr_arraycoop',(SELECT a.nrseqrdr FROM CRAPRDR a WHERE a.nmprogra = 'TELA_CHQMOB' AND ROWNUM = 1));

INSERT INTO CRAPACA (NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
VALUES ('BUSCA_LIB_DEP_MOBILE_COOPER','TELA_CHQMOB','pc_busca_lib_dep_mob_cooper','pr_cdcooper',(SELECT a.nrseqrdr FROM CRAPRDR a WHERE a.nmprogra = 'TELA_CHQMOB' AND ROWNUM = 1));

INSERT INTO CRAPACA (NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
VALUES ('ALTERA_LIB_DEP_MOBILE_COOPER','TELA_CHQMOB','pc_alter_lib_dep_mobile_cooper','pr_cdcooper, pr_tplibera, pr_arraypas',(SELECT a.nrseqrdr FROM CRAPRDR a WHERE a.nmprogra = 'TELA_CHQMOB' AND ROWNUM = 1));

INSERT INTO CRAPACA (NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
VALUES ('BUSCA_HORA_LIM_MOBILE','TELA_CHQMOB','pc_busca_hora_lim_mob','pr_cdcooper',(SELECT a.nrseqrdr FROM CRAPRDR a WHERE a.nmprogra = 'TELA_CHQMOB' AND ROWNUM = 1));

INSERT INTO CRAPACA (NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
VALUES ('ALTERA_HORA_LIM_MOBILE','TELA_CHQMOB','pc_altera_hora_lim_mob','pr_cdcooper,pr_hrlimdepini,pr_hrlimdepfim,pr_hrlimestini,pr_hrlimestfim',(SELECT a.nrseqrdr FROM CRAPRDR a WHERE a.nmprogra = 'TELA_CHQMOB' AND ROWNUM = 1));

INSERT INTO CRAPACA (NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
VALUES ('BUSCA_PARAM_DEP_MOB','TELA_CHQMOB','pc_busca_param_dep_mob','pr_cdcooper',(SELECT a.nrseqrdr FROM CRAPRDR a WHERE a.nmprogra = 'TELA_CHQMOB' AND ROWNUM = 1));

INSERT INTO CRAPACA (NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
VALUES ('ALTERA_PARAM_DEP_MOB','TELA_CHQMOB','pc_altera_param_dep_mob','pr_cdcooper,pr_diaEliFolChq,pr_paramEmail,pr_emailnotifica',(SELECT a.nrseqrdr FROM CRAPRDR a WHERE a.nmprogra = 'TELA_CHQMOB' AND ROWNUM = 1));

INSERT INTO CRAPACA (NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
VALUES ('ALTERA_EMAIL_NOTIF_MOB','TELA_CHQMOB','pc_altera_email_notif_mob','pr_cdcooper,pr_tpgere,pr_emailid,pr_emailnoti',(SELECT a.nrseqrdr FROM CRAPRDR a WHERE a.nmprogra = 'TELA_CHQMOB' AND ROWNUM = 1));

INSERT INTO CRAPACA (NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
VALUES ('BUSCA_CHQ_ESTORNO_MOBILE','TELA_CHQMOB','pc_busca_chq_estorno_mob','pr_cdcooper,pr_nrdconta,pr_vlvalor',(SELECT a.nrseqrdr FROM CRAPRDR a WHERE a.nmprogra = 'TELA_CHQMOB' AND ROWNUM = 1));

------------------------------------------------------------------


-- Parametros deposito mobile ------------------------------------
DECLARE
  TYPE Cooperativas IS TABLE OF integer;
  coop Cooperativas := Cooperativas(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17);

  pr_cdcooper INTEGER;
BEGIN

  FOR i IN coop.FIRST .. coop.LAST LOOP
    pr_cdcooper := coop(i);
    
    INSERT INTO CRAPPRM (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
    VALUES ('CRED', pr_cdcooper, 'DIAS_ELIM_CHEQ_MOBI', 'Dias eliminação folha de cheque mobile', '60');
    
    INSERT INTO CRAPPRM (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
    VALUES ('CRED', pr_cdcooper, 'TP_ENVIO_EMAIL_CHQ_MOB', 'Tipo de envio de email eliminação folha de cheque mobile. 1=PA, 2=Outros', '1');
    
    INSERT INTO CRAPPRM (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
    VALUES ('CRED', pr_cdcooper, 'EMAIL_NOTI_ELIM_CHEQ', 'E-mails notificação eliminação folha de cheque mobile', '');
 
  END LOOP;
  
  INSERT INTO CRAPPRM (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
  VALUES ('CRED', 3, 'HORA_INI_LIM_DEP_MOB', 'Horário Inicio Limite Depósito', '09:00');
  
  INSERT INTO CRAPPRM (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
  VALUES ('CRED', 3, 'HORA_FIM_LIM_DEP_MOB', 'Horário Fim Limite Depósito', '20:00');
  
  INSERT INTO CRAPPRM (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
  VALUES ('CRED', 3, 'HORA_INI_LIM_EST_MOB', 'Horário Inicio Limite Estorno', '09:00');
  
  INSERT INTO CRAPPRM (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
  VALUES ('CRED', 3, 'HORA_FIM_LIM_EST_MOB', 'Horário Inicio Limite Estorno', '20:00');

  COMMIT;
END;

COMMIT;

----------------------------------------------------------------------------------------
-- FIM DML TELA CHQMOB

/* INICIO TELA DEVOLU - BUSCA ORIGEM DO CHEQUE */
INSERT INTO CRAPACA (NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
VALUES ('BUSCA_ORIGEM_DEP_MOBILE','CHEQ0004','pc_busca_origem_cheque_mob','pr_cdcooper,pr_nrdconta,pr_nrcheque,pr_nrdigchq,pr_cdbanchq',(SELECT a.nrseqrdr FROM CRAPRDR a WHERE a.nmprogra = 'CHEQ0004' AND ROWNUM = 1));









