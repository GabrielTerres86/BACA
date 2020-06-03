--------------------------------------------------------------------------------
-- INCLUSÃO DE PARAMETRO DO VALOR DO LIMITE/DIA DO DEPOSITO DE CHEQUE NA TB045
--------------------------------------------------------------------------------
-- **** Deverá ser feito o script para todas as cooperativas, verifica os valores para pessoa fisica e juridica
-- **** Deverá ter o valor para o Operacional e para Ailos
update craptab 
set dstextab = dstextab||';000000000000,00;000000000000,00'
where  craptab.nmsistem = 'CRED' and
                            craptab.tptabela = 'GENERI'     AND
                            craptab.cdempres = 0            AND
                            craptab.cdacesso = 'LIMINTERNT' and
                           -- craptab.cdcooper = 1  and    -- coperativa
                            craptab.tpregist in (1,2); --  fisica e Juridica
/

-- armazenar tela para interface web
INSERT INTO CRAPRDR (NMPROGRA, DTSOLICI) values ('TELA_CHQMOB', sysdate);
INSERT INTO CRAPRDR (NMPROGRA, DTSOLICI) values ('CHEQ0004', sysdate);
COMMIT;
/

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

INSERT INTO CRAPACA (NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
VALUES ('BUSCA_ACEITE_DEP_MOBILE','CHEQ0004','pc_busca_aceite_cheque_mob','pr_cdcooper,pr_nrdconta',(SELECT a.nrseqrdr FROM CRAPRDR a WHERE a.nmprogra = 'CHEQ0004' AND ROWNUM = 1));

INSERT INTO CRAPACA (NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
VALUES ('ALTERA_ACEITE_DEP_MOBILE','CHEQ0004','pc_altera_aceite_cheque_mob','pr_cdcooper,pr_cdoperad,pr_nrdconta,pr_prmavali,pr_dtsolici',(SELECT a.nrseqrdr FROM CRAPRDR a WHERE a.nmprogra = 'CHEQ0004' AND ROWNUM = 1));

INSERT INTO CRAPACA (NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
VALUES ('BUSCA_LIM_DIA_CHQ_MOB', 'CHEQ0004', 'pc_busca_lim_dia_chq_mob_web', 'pr_cdcooper,pr_nrdconta,pr_vllimdcm',(SELECT a.nrseqrdr FROM CRAPRDR a WHERE a.nmprogra = 'CHEQ0004' AND ROWNUM = 1));


------------------------------------------------------------------


/* INICIO TELA DEVOLU - BUSCA ORIGEM DO CHEQUE */
INSERT INTO CRAPACA (NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
VALUES ('BUSCA_ORIGEM_DEP_MOBILE','CHEQ0004','pc_busca_origem_cheque_mob','pr_cdcooper,pr_nrdconta,pr_nrcheque,pr_nrdigchq,pr_cdbanchq',(SELECT a.nrseqrdr FROM CRAPRDR a WHERE a.nmprogra = 'CHEQ0004' AND ROWNUM = 1));
----------------------------------------------------------------------------------------
/*
-- Job JBCHQ_DESCARTE_CHEQUE_MOBILE
BEGIN EXECUTE IMMEDIATE '
  ALTER SESSION SET 
    nls_calendar = ''GREGORIAN'' 
    nls_comp = ''BINARY'' 
    nls_date_format = ''DD-MON-RR'' 
    nls_date_language = ''AMERICAN'' 
    nls_iso_currency = ''AMERICA'' 
    nls_language = ''AMERICAN'' 
    nls_length_semantics = ''BYTE'' 
    nls_nchar_conv_excp = ''FALSE'' 
    nls_numeric_characters = ''.,'' 
    nls_sort = ''BINARY'' 
    nls_territory = ''AMERICA'' 
    nls_time_format = ''HH.MI.SSXFF AM'' 
    nls_time_tz_format = ''HH.MI.SSXFF AM TZR'' 
    nls_timestamp_format = ''DD-MON-RR HH.MI.SSXFF AM'' 
    nls_timestamp_tz_format = ''DD-MON-RR HH.MI.SSXFF AM TZR''';

  sys.dbms_scheduler.create_job(job_name    => 'CECRED.JBCHQ_DESCARTE_CHEQUE_MOBILE',
                                job_type    => 'PLSQL_BLOCK',
                                job_action  => 'DECLARE
    vr_cdcritic PLS_INTEGER;
    vr_dscritic VARCHAR2(4000);
  BEGIN
    cecred.cheq0004.pc_descarte_cheque_mobile(pr_cdcritic => vr_cdcritic,
                                              pr_dscritic => vr_dscritic);
    IF vr_dscritic IS NOT NULL THEN
      raise_application_error(-20001, ''Erro job CECRED.JBCHQ_DESCARTE_CHEQUE_MOBILE ''|| sqlerrm);
    END IF;
  END;',
  start_date          => to_date('20-01-2020 00:00:00', 'dd-mm-yyyy hh24:mi:ss'),
  repeat_interval     => 'Freq=Minutely;Interval=15;ByDay=Mon, Tue, Wed, Thu, Fri;ByHour= 13',
  end_date            => to_date(null),
  job_class           => 'DEFAULT_JOB_CLASS',
  enabled             => true,
  auto_drop           => false,
  comments            => 'Rodar rotina de descarte de cheque mobile compensado conforme parametrizacao.');
end;
/

----------------------------------------------------------------------------------------

-- Job JBCHQ_LIBERA_CHEQUE_MOBILE
BEGIN EXECUTE IMMEDIATE '
  ALTER SESSION SET 
    nls_calendar = ''GREGORIAN'' 
    nls_comp = ''BINARY'' 
    nls_date_format = ''DD-MON-RR'' 
    nls_date_language = ''AMERICAN'' 
    nls_iso_currency = ''AMERICA'' 
    nls_language = ''AMERICAN'' 
    nls_length_semantics = ''BYTE'' 
    nls_nchar_conv_excp = ''FALSE'' 
    nls_numeric_characters = ''.,'' 
    nls_sort = ''BINARY'' 
    nls_territory = ''AMERICA'' 
    nls_time_format = ''HH.MI.SSXFF AM'' 
    nls_time_tz_format = ''HH.MI.SSXFF AM TZR'' 
    nls_timestamp_format = ''DD-MON-RR HH.MI.SSXFF AM'' 
    nls_timestamp_tz_format = ''DD-MON-RR HH.MI.SSXFF AM TZR''';

  sys.dbms_scheduler.create_job(job_name    => 'CECRED.JBCHQ_LIBERA_CHEQUE_MOBILE',
                                job_type    => 'PLSQL_BLOCK',
                                job_action  => 'DECLARE
    vr_cdcritic PLS_INTEGER;
    vr_dscritic VARCHAR2(4000);
  BEGIN
    cecred.cheq0004.pc_libera_cheque_mobile(pr_cdcritic => vr_cdcritic,
                                            pr_dscritic => vr_dscritic);
    IF vr_dscritic IS NOT NULL THEN
      raise_application_error(-20001, ''Erro job CECRED.JBCHQ_LIBERA_CHEQUE_MOBILE ''|| sqlerrm);
    END IF;
  END;',
  start_date          => to_date('06-02-2020 00:00:00', 'dd-mm-yyyy hh24:mi:ss'),
  repeat_interval     => 'Freq=DAILY',
  end_date            => to_date(null),
  job_class           => 'DEFAULT_JOB_CLASS',
  enabled             => true,
  auto_drop           => false,
  comments            => 'Rodar rotina de liberação de cheque mobile compensado conforme parametrizacao.');
end;
/
*/
------------------------------------------------------------------------------------------

UPDATE CRAPTAB 
SET DSTEXTAB = '1 64800' 
where cdcooper = 9   
AND craptab.nmsistem = 'CRED'        
AND craptab.tptabela = 'GENERI'      
AND craptab.cdempres = 00            
AND craptab.cdacesso = 'HRTRCOMPEL'                              
and craptab.tpregist = 90
/

------------------------------------------------------------------------------------------

UPDATE crapsnh snh
   SET snh.vllimite_dep_cheq_mob = 2000
 WHERE snh.vllimite_dep_cheq_mob = 0;
/

------------------------------------------------------------------------------------------

INSERT INTO menumobile
  (menumobileid,
   menupaiid,
   nome,
   sequencia,
   habilitado,
   autorizacao,
   versaominimaapp,
   versaomaximaapp)
VALUES
  (1007, 30, 'Deposito de Cheques', 1, 1, 1, '2.8.0.0', NULL);
/


