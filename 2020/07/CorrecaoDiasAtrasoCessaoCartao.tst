PL/SQL Developer Test script 3.0
193
/*
Autor: Luiz Otávio Olinger Momm / AMCOM
Analistas: James e Odirlei / AILOS
Incidente: INC0057248
Squad Riscos

Objetivo:

Alterar na virada do mês a data de vencimento da cessão de cartão
para calcular corretamente os dias em atraso não gerando impacto
na provisão da cooperatidas. No dia seguinte, 01/08, necessário
reverter a data pelo baca gerado automaticamente por esse script.

*/
DECLARE

  -- Todos contratos de cessão com mais de uma parce
  -- com quantidade de dias em atraso inválidos
  CURSOR contratosCessao IS
    SELECT e.cdcooper
          ,e.nrdconta
          ,e.nrctremp
          ,e.cdlcremp
          ,e.cdfinemp
          ,e.dtmvtolt
          ,d.dtmvtolt datdtmvtolt
          ,d.dtmvtoan datdtmvtoan
          ,cc.dtvencto
          ,cc.rowid
          ,(d.dtmvtoan - e.dtmvtolt) AS qtdDiasAtraso
          ,(SELECT r.qtdiaatr
              FROM crapris r
             WHERE r.cdcooper = e.cdcooper
               AND r.nrdconta = e.nrdconta
               AND r.nrctremp = e.nrctremp
               AND r.dtrefere = d.dtmvtoan) AS qtdDiasAtrRisco
          ,(SELECT d.dtmvtolt - MIN(p.dtvencto)
              FROM crappep p
             WHERE p.cdcooper = e.cdcooper
               AND p.nrdconta = e.nrdconta
               AND p.nrctremp = e.nrctremp
               AND p.inliquid = 0) AS qtdDiasCorrecao
          ,(SELECT MIN(p.dtvencto)
              FROM crappep p
             WHERE p.cdcooper = e.cdcooper
               AND p.nrdconta = e.nrdconta
               AND p.nrctremp = e.nrctremp
               AND p.inliquid = 0) AS dataAtualizacao
      FROM crapepr e
          ,crapdat d
          ,tbcrd_cessao_credito cc
     WHERE e.inliquid = 0
       AND e.qtpreemp > 1
       AND e.cdlcremp = 6901
       AND e.cdfinemp = 69
       AND e.cdcooper = d.cdcooper
       AND e.cdcooper = cc.cdcooper
       AND e.nrdconta = cc.nrdconta
       AND e.nrctremp = cc.nrctremp
     ORDER BY e.cdcooper;

  vr_dsdireto             VARCHAR2(4000);
  vr_dirname              VARCHAR2(100);

  vr_des_log              CLOB;
  vr_des_rel              CLOB;
  vr_des_erro             CLOB;

  vr_texto_completo       VARCHAR2(32600);
  vr_texto_relatorio      VARCHAR2(32600);
  vr_texto_erro           VARCHAR2(32600);

  vr_typ_saida            VARCHAR2(3);
  vr_dscritic             VARCHAR2(2000);
  vr_incidente            VARCHAR2(50);
  vr_index                VARCHAR2(50);
  vr_qualificacao         NUMBER;
  vr_dsctrliq             VARCHAR(200);

  PROCEDURE pc_escreve_rollback(pr_des_dados IN VARCHAR2,
                                pr_fecha_xml IN BOOLEAN DEFAULT FALSE) IS
  BEGIN
    -- dbms_output.put_line(pr_des_dados);
    gene0002.pc_escreve_xml(vr_des_log, vr_texto_completo, pr_des_dados || chr(10), pr_fecha_xml);
  END;

  PROCEDURE pc_escreve_relatorio(pr_des_dados IN VARCHAR2,
                                 pr_fecha_xml IN BOOLEAN DEFAULT FALSE) IS
  BEGIN
    -- dbms_output.put_line(pr_des_dados);
    gene0002.pc_escreve_xml(vr_des_rel, vr_texto_relatorio, pr_des_dados || chr(10), pr_fecha_xml);
  END;

  PROCEDURE pc_escreve_erro(pr_des_dados IN VARCHAR2,
                            pr_fecha_xml IN BOOLEAN DEFAULT FALSE) IS
  BEGIN
    gene0002.pc_escreve_xml(vr_des_erro, vr_texto_erro, pr_des_dados, pr_fecha_xml);
  END;

BEGIN
  vr_incidente := 'INC0057248';

  -- Desativar Job
  BEGIN
    sys.dbms_scheduler.disable(name => 'CECRED.JBCRD_IMPORTA_CESSAO');
  EXCEPTION
    WHEN OTHERS THEN
      CECRED.pc_internal_exception (pr_cdcooper => 3);
  END;

  vr_dsdireto := gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS') || 'cpd/bacas';

  gene0001.pc_OScommand_Shell(pr_des_comando => 'mkdir ' || vr_dsdireto || '/' || vr_incidente
                             ,pr_typ_saida   => vr_typ_saida
                             ,pr_des_saida   => vr_dscritic);

  vr_dsdireto := vr_dsdireto || '/' || vr_incidente;
  vr_dirname := sistema.obternomedirectory(vr_dsdireto);

  -- Inicializar o CLOB
  vr_texto_completo := NULL;
  vr_des_log := NULL;
  dbms_lob.createtemporary(vr_des_log, TRUE);
  dbms_lob.open(vr_des_log, dbms_lob.lob_readwrite);

  vr_texto_erro := NULL;
  vr_des_erro := NULL;
  dbms_lob.createtemporary(vr_des_erro, TRUE);
  dbms_lob.open(vr_des_erro, dbms_lob.lob_readwrite);

  vr_texto_relatorio := NULL;
  vr_des_rel := NULL;
  dbms_lob.createtemporary(vr_des_rel, TRUE);
  dbms_lob.open(vr_des_rel, dbms_lob.lob_readwrite);

  -- Altera Parâmetro
  UPDATE crapprm m
     SET m.dsvlrprm = '01/08/2020'
   WHERE m.cdacesso = 'DTCESSAO_CORTE_ATRASO';

  FOR contrato IN contratosCessao LOOP
    pc_escreve_relatorio(contrato.cdcooper || ',' ||
                         contrato.nrdconta || ',' ||
                         contrato.nrctremp || ',' ||
                         contrato.cdlcremp || ',' ||
                         contrato.cdfinemp || ',' ||
                         to_char(contrato.dtmvtolt, 'dd/mm/YYYY') || ',' ||
                         to_char(contrato.datdtmvtolt, 'dd/mm/YYYY') || ',' ||
                         to_char(contrato.datdtmvtoan, 'dd/mm/YYYY') || ',' ||
                         to_char(contrato.dtvencto, 'dd/mm/YYYY') || ',' ||
                         contrato.rowid || ',' ||
                         contrato.qtddiasatraso || ',' ||
                         contrato.qtddiasatrrisco || ',' ||
                         contrato.qtddiascorrecao || ',' ||
                         to_char(contrato.dataatualizacao, 'dd/mm/YYYY')
                         );

    pc_escreve_rollback('UPDATE tbcrd_cessao_credito cc SET cc.dtvencto = to_date('''|| to_char(contrato.dtvencto, 'dd/mm/YYYY') ||''', ''dd/mm/YYYY'') WHERE cc.rowid = ''' || contrato.rowid || ''';');

    UPDATE tbcrd_cessao_credito cc SET cc.dtvencto = contrato.dataatualizacao WHERE cc.rowid = contrato.rowid;
  END LOOP;

  pc_escreve_rollback('UPDATE crapprm m SET m.dsvlrprm = ''22/11/2018'' WHERE m.cdacesso = ''DTCESSAO_CORTE_ATRASO'';');
  pc_escreve_rollback('COMMIT;');

  pc_escreve_rollback('/');
  pc_escreve_rollback('BEGIN');
  pc_escreve_rollback('  sys.dbms_scheduler.enable(name => ''CECRED.JBCRD_IMPORTA_CESSAO'');');
  pc_escreve_rollback('END;');

  -- FINAL
  pc_escreve_relatorio(' ',TRUE);
  DBMS_XSLPROCESSOR.CLOB2FILE(vr_des_rel, vr_dirname, 'CESSAO_'||to_char(sysdate,'ddmmyyyy_hh24miss')|| '.txt', NLS_CHARSET_ID('UTF8'));

  dbms_lob.close(vr_des_rel);
  dbms_lob.freetemporary(vr_des_rel);

  pc_escreve_rollback(' ',TRUE);
  DBMS_XSLPROCESSOR.CLOB2FILE(vr_des_log, vr_dirname, 'CESSAO_ROLLBACK_'||to_char(sysdate,'ddmmyyyy_hh24miss')|| '.sql', NLS_CHARSET_ID('UTF8'));

  -- Liberando a memória alocada pro CLOB
  dbms_lob.close(vr_des_log);
  dbms_lob.freetemporary(vr_des_log);

  pc_escreve_erro(' ',TRUE);
  DBMS_XSLPROCESSOR.CLOB2FILE(vr_des_erro, vr_dirname, 'CESSAO_ERROS_'||to_char(sysdate,'ddmmyyyy_hh24miss')|| '.txt', NLS_CHARSET_ID('UTF8'));

  -- Liberando a memória alocada pro CLOB
  dbms_lob.close(vr_des_erro);
  dbms_lob.freetemporary(vr_des_erro);

  COMMIT;
END;
0
1
vr_dsmensagem
