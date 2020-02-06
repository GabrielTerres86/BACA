--------------------------------------------------------------------------------
-- INCLUSÃO DE PARAMETRO DO VALOR DO LIMITE/DIA DO DEPOSITO DE CHEQUE NA TB045
--------------------------------------------------------------------------------
-- **** Deverá ser feito o script para todas as cooperativas, verifica os valores para pessoa fisica e juridica
-- **** Deverá ter o valor para o Operacional e para Ailos
update craptab 
set dstextab = dstextab||';000000002000,00;000000300000,00'
where  craptab.nmsistem = 'CRED' and
                            craptab.tptabela = 'GENERI'     AND
                            craptab.cdempres = 0            AND
                            craptab.cdacesso = 'LIMINTERNT' and
                            craptab.cdcooper = 1  and    -- coperativa
                            craptab.tpregist in (1,2); --  fisica e Juridica
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
INSERT INTO CRAPRDR (NMPROGRA, DTSOLICI) values ('CHEQ0004', sysdate);
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

INSERT INTO CRAPACA (NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
VALUES ('BUSCA_ACEITE_DEP_MOBILE','CHEQ0004','pc_busca_aceite_cheque_mob','pr_cdcooper,pr_nrdconta',(SELECT a.nrseqrdr FROM CRAPRDR a WHERE a.nmprogra = 'CHEQ0004' AND ROWNUM = 1));

INSERT INTO CRAPACA (NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
VALUES ('ALTERA_ACEITE_DEP_MOBILE','CHEQ0004','pc_altera_aceite_cheque_mob','pr_cdcooper,pr_cdoperad,pr_nrdconta,pr_prmavali,pr_dtsolici',(SELECT a.nrseqrdr FROM CRAPRDR a WHERE a.nmprogra = 'CHEQ0004' AND ROWNUM = 1));

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
    VALUES ('CRED', pr_cdcooper, 'EMAIL_NOTI_DEPO_CHEQ_MOB', 'E-mails notificação cheque mobile', '');
 
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

----------------------------------------------------------------------------------------
-- INICIO Tela Atenda/Produtos Mobile
DECLARE
  TYPE Cooperativas IS TABLE OF integer;
  coop Cooperativas := Cooperativas(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17);
  
  CURSOR cr_craptel is
    SELECT max(nrordrot) + 1 nrordrot FROM craptel;
  rw_craptel cr_craptel%rowtype;

  pr_cdcooper INTEGER;
  
BEGIN
  
  open cr_craptel;
  fetch cr_craptel into rw_craptel;
  close cr_craptel;

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
      SELECT 'ATENDA',
             1,
             '@',
             'Produtos Mobile',
             'Produtos Mobile',
             0,
             1, -- bloqueio da tela 
             'PRODUTOS MOBILE',
             'ACESSO',
             2,
             pr_cdcooper, -- cooperativa
             1,
             0,
             rw_craptel.nrordrot,
             1,
             '',
             2
        FROM crapcop
       WHERE cdcooper = pr_cdcooper;
      
  END LOOP;

  COMMIT;
END;
----------------------------------------------------------------------------------------
-- FIM Tela Atenda/Produtos Mobile

/* INICIO TELA DEVOLU - BUSCA ORIGEM DO CHEQUE */
INSERT INTO CRAPACA (NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
VALUES ('BUSCA_ORIGEM_DEP_MOBILE','CHEQ0004','pc_busca_origem_cheque_mob','pr_cdcooper,pr_nrdconta,pr_nrcheque,pr_nrdigchq,pr_cdbanchq',(SELECT a.nrseqrdr FROM CRAPRDR a WHERE a.nmprogra = 'CHEQ0004' AND ROWNUM = 1));
----------------------------------------------------------------------------------------

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
----------------------------------------------------------------------------------------

-- US691 - Origem da recusa do deposito de cheque
ALTER TABLE CECRED.TBCHQ_DEPOSITO_CHEQUE_MOB ADD ORIGEM_RECUSA NUMBER(1);

COMMENT ON COLUMN CECRED.TBCHQ_DEPOSITO_CHEQUE_MOB.ORIGEM_RECUSA IS 'Indica a origem da recusa do deposito do cheque (1-Sincronica, 2-Caixa On-line, 3-Compensação)';


-- Carga na tabela TBCHQ_DEVOLUCAO_ALINEAS
INSERT INTO TBCHQ_DEVOLUCAO_ALINEAS VALUES (11, 'Cheque sem fundos - 1ª apresentação');
INSERT INTO TBCHQ_DEVOLUCAO_ALINEAS VALUES (12, 'Cheque sem fundos - 2ª apresentação');
INSERT INTO TBCHQ_DEVOLUCAO_ALINEAS VALUES (13, 'Conta encerrada');
INSERT INTO TBCHQ_DEVOLUCAO_ALINEAS VALUES (14, 'Prática espúria');
INSERT INTO TBCHQ_DEVOLUCAO_ALINEAS VALUES (20, 'Cheque sustado ou revogado em virtude de roubo, furto ou extravio de folhas de cheque em branco');
INSERT INTO TBCHQ_DEVOLUCAO_ALINEAS VALUES (21, 'Cheque sustado ou revogado');
INSERT INTO TBCHQ_DEVOLUCAO_ALINEAS VALUES (22, 'Divergência ou insuficiência de assinatura');
INSERT INTO TBCHQ_DEVOLUCAO_ALINEAS VALUES (23, 'Cheques emitidos por entidades e órgãos da administração pública federal direta e indireta, em desacordo com os requisitos constantes do art. 74, § 2º, do Decreto-lei nº 200, de 25 de fevereiro de 1967');
INSERT INTO TBCHQ_DEVOLUCAO_ALINEAS VALUES (24, 'Bloqueio judicial ou determinação do Bacen');
INSERT INTO TBCHQ_DEVOLUCAO_ALINEAS VALUES (25, 'Cancelamento de talonário pelo participante destinatário');
INSERT INTO TBCHQ_DEVOLUCAO_ALINEAS VALUES (27, 'Feriado municipal não previsto');
INSERT INTO TBCHQ_DEVOLUCAO_ALINEAS VALUES (28, 'Cheque sustado ou revogado em virtude de roubo, furto ou extravio');
INSERT INTO TBCHQ_DEVOLUCAO_ALINEAS VALUES (30, 'Furto ou roubo de cheque');
INSERT INTO TBCHQ_DEVOLUCAO_ALINEAS VALUES (70, 'Sustação ou revogação provisória');
INSERT INTO TBCHQ_DEVOLUCAO_ALINEAS VALUES (31, 'Erro formal (sem data de emissão, com o mês grafado numericamente, ausência de assinatura ou não registro do valor por extenso)');
INSERT INTO TBCHQ_DEVOLUCAO_ALINEAS VALUES (33, 'Divergência de endosso');
INSERT INTO TBCHQ_DEVOLUCAO_ALINEAS VALUES (34, 'Cheque apresentado por participante que não o indicado no cruzamento em preto, sem o endosso-mandato');
INSERT INTO TBCHQ_DEVOLUCAO_ALINEAS VALUES (35, 'Cheque fraudado, emitido sem prévio controle ou responsabilidade do participante ("cheque universal"), ou com adulteração da praça sacada, ou ainda com rasura no preenchimento');
INSERT INTO TBCHQ_DEVOLUCAO_ALINEAS VALUES (37, 'Registro inconsistente');
INSERT INTO TBCHQ_DEVOLUCAO_ALINEAS VALUES (38, 'Assinatura digital ausente ou inválida');
INSERT INTO TBCHQ_DEVOLUCAO_ALINEAS VALUES (39, 'Imagem fora do padrão');
INSERT INTO TBCHQ_DEVOLUCAO_ALINEAS VALUES (40, 'Moeda Inválida');
INSERT INTO TBCHQ_DEVOLUCAO_ALINEAS VALUES (41, 'Cheque apresentado a participante que não o destinatário');
INSERT INTO TBCHQ_DEVOLUCAO_ALINEAS VALUES (43, 'Cheque, devolvido anteriormente pelos motivos 21, 22, 23, 24, 31 e 34, não passível de reapresentação em virtude de persistir o motivo da devolução');
INSERT INTO TBCHQ_DEVOLUCAO_ALINEAS VALUES (44, 'Cheque prescrito');
INSERT INTO TBCHQ_DEVOLUCAO_ALINEAS VALUES (45, 'Cheque emitido por entidade obrigada a realizar movimentação e utilização de recursos financeiros do Tesouro Nacional mediante Ordem Bancária');
INSERT INTO TBCHQ_DEVOLUCAO_ALINEAS VALUES (48, 'Cheque de valor superior a R$100,00 (cem reais), emitido sem a identificação do beneficiário');
INSERT INTO TBCHQ_DEVOLUCAO_ALINEAS VALUES (49, 'Remessa nula, caracterizada pela reapresentação de cheque devolvido pelos motivos 12, 13, 14, 20, 25, 28, 30, 35, 43, 44 e 45.');
INSERT INTO TBCHQ_DEVOLUCAO_ALINEAS VALUES (59, 'Informação essencial faltante ou inconsistente não passível de verificação pelo participante remetente e não enquadrada no motivo 31');
INSERT INTO TBCHQ_DEVOLUCAO_ALINEAS VALUES (60, 'Instrumento inadequado para a finalidade');
INSERT INTO TBCHQ_DEVOLUCAO_ALINEAS VALUES (61, 'Papel não compensável diretamente pela instituição financeira contratada');
INSERT INTO TBCHQ_DEVOLUCAO_ALINEAS VALUES (71, 'Inadimplemento contratual da cooperativa de crédito no acordo de compensação');
INSERT INTO TBCHQ_DEVOLUCAO_ALINEAS VALUES (72, 'Contrato de Compensação encerrado');
