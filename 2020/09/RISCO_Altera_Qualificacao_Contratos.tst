PL/SQL Developer Test script 3.0
279
/*

*/
DECLARE
  CURSOR cr_cop IS
    SELECT cdcooper
      FROM crapcop c
     WHERE c.flgativo = 1
     ORDER BY c.cdcooper DESC;
  rw_cop   cr_cop%ROWTYPE;

  CURSOR cr_contratos (pr_cdcooper IN crapcop.cdcooper%TYPE)IS
    SELECT w.cdcooper, w.nrdconta, w.nrctremp, w.dtmvtolt
          ,w.cdlcremp, w.cdfinemp
          , w.idquapro
          , w.rowid rowid_wepr
          , e.rowid rowid_epr
        FROM crawepr w, crapepr e 
       WHERE w.cdcooper = pr_cdcooper
         AND w.dtmvtolt <= TO_date('22/10/2019')       -- ANTERIORES DATA DE LIBERAÇÃO
         AND w.idquapro = 5                            -- QUE ESTEJAM COM QUALIFICACAO 5
         AND e.cdcooper = w.cdcooper
         AND e.nrdconta = w.nrdconta
         AND e.nrctremp = w.nrctremp
         AND (e.inliquid = 0 OR e.inprejuz = 1)        -- CONTRATOS AINDA ABERTOS OU EM PREJUIZO
         AND (   EXISTS (SELECT 1                      -- QUE TENHAM LIQUIDADO ALGUM CONTRATO DE CESSAO
                           FROM crawepr w1
                          WHERE w1.cdcooper   = w.cdcooper 
                            AND w1.nrdconta   = w.nrdconta
                            AND w1.nrctremp   = w.nrctrliq##1 
                            AND w1.cdlcremp   = 6901
                            AND w1.idquapro   = 5
                            AND w.nrctrliq##1 > 0)
              OR EXISTS (SELECT 1 
                           FROM crawepr w1
                          WHERE w1.cdcooper   = w.cdcooper 
                            AND w1.nrdconta   = w.nrdconta
                            AND w1.nrctremp   = w.nrctrliq##2
                            AND w1.cdlcremp   = 6901
                            AND w1.idquapro   = 5
                            AND w.nrctrliq##2 > 0)
              OR EXISTS (SELECT 1 
                           FROM crawepr w1
                          WHERE w1.cdcooper   = w.cdcooper 
                            AND w1.nrdconta   = w.nrdconta
                            AND w1.nrctremp   = w.nrctrliq##3
                            AND w1.cdlcremp   = 6901
                            AND w1.idquapro   = 5
                            AND w.nrctrliq##3 > 0)
              OR EXISTS (SELECT 1 
                           FROM crawepr w1
                          WHERE w1.cdcooper   = w.cdcooper 
                            AND w1.nrdconta   = w.nrdconta
                            AND w1.nrctremp   = w.nrctrliq##4
                            AND w1.cdlcremp   = 6901
                            AND w1.idquapro   = 5
                            AND w.nrctrliq##4 > 0)
              OR EXISTS (SELECT 1 
                           FROM crawepr w1
                          WHERE w1.cdcooper   = w.cdcooper 
                            AND w1.nrdconta   = w.nrdconta
                            AND w1.nrctremp   = w.nrctrliq##5
                            AND w1.cdlcremp   = 6901
                            AND w1.idquapro   = 5
                            AND w.nrctrliq##5 > 0)
              OR EXISTS (SELECT 1 
                           FROM crawepr w1
                          WHERE w1.cdcooper   = w.cdcooper 
                            AND w1.nrdconta   = w.nrdconta
                            AND w1.nrctremp   = w.nrctrliq##6
                            AND w1.cdlcremp   = 6901
                            AND w1.idquapro   = 5
                            AND w.nrctrliq##6 > 0)
              OR EXISTS (SELECT 1 
                           FROM crawepr w1
                          WHERE w1.cdcooper   = w.cdcooper 
                            AND w1.nrdconta   = w.nrdconta
                            AND w1.nrctremp   = w.nrctrliq##7
                            AND w1.cdlcremp   = 6901
                            AND w1.idquapro   = 5
                            AND w.nrctrliq##7 > 0)
              OR EXISTS (SELECT 1 
                           FROM crawepr w1
                          WHERE w1.cdcooper   = w.cdcooper 
                            AND w1.nrdconta   = w.nrdconta
                            AND w1.nrctremp   = w.nrctrliq##8
                            AND w1.cdlcremp   = 6901
                            AND w1.idquapro   = 5
                            AND w.nrctrliq##8 > 0)
              OR EXISTS (SELECT 1 
                           FROM crawepr w1
                          WHERE w1.cdcooper   = w.cdcooper 
                            AND w1.nrdconta   = w.nrdconta
                            AND w1.nrctremp   = w.nrctrliq##9
                            AND w1.cdlcremp   = 6901
                            AND w1.idquapro   = 5
                            AND w.nrctrliq##9 > 0)
              OR EXISTS (SELECT 1 
                           FROM crawepr w1
                          WHERE w1.cdcooper   = w.cdcooper 
                            AND w1.nrdconta   = w.nrdconta
                            AND w1.nrctremp   = w.nrctrliq##10
                            AND w1.cdlcremp   = 6901
                            AND w1.idquapro   = 5
                            AND w.nrctrliq##10 > 0)
             )
         ORDER BY w.cdcooper, w.nrdconta, w.nrctremp;
   rw_contratos cr_contratos%ROWTYPE;


  vr_dsdireto             VARCHAR2(4000);
  vr_dirname              VARCHAR2(100);

  vr_typ_saida            VARCHAR2(3);
  vr_incidente            VARCHAR2(50);
  vr_index                VARCHAR2(50);
  vr_cdcritic             NUMBER;
  vr_dscritic             VARCHAR2(2000);

  vr_des_log              CLOB;
  vr_des_rel              CLOB;
  vr_des_erro             CLOB;

  vr_texto_rollback       VARCHAR2(32600);
  vr_texto_relatorio      VARCHAR2(32600);
  vr_texto_erro           VARCHAR2(32600);

  vr_idx_grupos           VARCHAR2(15);
  vr_data_risco           DATE;
  vr_found                BOOLEAN;


  PROCEDURE pc_escreve_rollback(pr_des_dados IN VARCHAR2,
                                pr_fecha_xml IN BOOLEAN DEFAULT FALSE) IS
  BEGIN
    gene0002.pc_escreve_xml(vr_des_log, vr_texto_rollback, pr_des_dados || chr(10), pr_fecha_xml);
  END;

  PROCEDURE pc_escreve_relatorio(pr_des_dados IN VARCHAR2,
                                 pr_fecha_xml IN BOOLEAN DEFAULT FALSE) IS
  BEGIN
    gene0002.pc_escreve_xml(vr_des_rel, vr_texto_relatorio, pr_des_dados || chr(10), pr_fecha_xml);
  END;

  PROCEDURE pc_escreve_erro(pr_des_dados IN VARCHAR2,
                            pr_fecha_xml IN BOOLEAN DEFAULT FALSE) IS
  BEGIN
    gene0002.pc_escreve_xml(vr_des_erro, vr_texto_erro, pr_des_dados || chr(10), pr_fecha_xml);
  END;



BEGIN
  vr_incidente := 'INC0055554';

  vr_dsdireto := gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS') || 'cpd/bacas';
  gene0001.pc_OScommand_Shell(pr_des_comando => 'mkdir ' || vr_dsdireto || '/' || vr_incidente
                             ,pr_typ_saida   => vr_typ_saida
                             ,pr_des_saida   => vr_dscritic);

  vr_dsdireto := vr_dsdireto || '/' || vr_incidente;
  vr_dirname  := sistema.obternomedirectory(vr_dsdireto);

  gene0001.pc_OScommand_Shell(pr_des_comando => 'rm -f ' || vr_dsdireto || '/*'
                             ,pr_typ_saida   => vr_typ_saida
                             ,pr_des_saida   => vr_dscritic);


  dbms_output.enable(buffer_size => null);

  -- Inicializar o CLOB
 -- Inicializar o CLOB
  vr_texto_rollback := NULL;
  vr_des_log        := NULL;
  dbms_lob.createtemporary(vr_des_log, TRUE);
  dbms_lob.open(vr_des_log, dbms_lob.lob_readwrite);

  vr_texto_erro := NULL;
  vr_des_erro   := NULL;
  dbms_lob.createtemporary(vr_des_erro, TRUE);
  dbms_lob.open(vr_des_erro, dbms_lob.lob_readwrite);

  vr_texto_relatorio := NULL;
  vr_des_rel         := NULL;
  dbms_lob.createtemporary(vr_des_rel, TRUE);
  dbms_lob.open(vr_des_rel, dbms_lob.lob_readwrite);

  pc_escreve_relatorio('-- Contratos Alterar Qualificação',TRUE);

  
  -- BLOCO DE CODIGO
  pc_escreve_relatorio('COP;CONTA;CONTRATO;DT EFET.;QUALIF DE;QUALIF PARA');
  FOR rw_cop  IN cr_cop LOOP
    FOR rw_contratos IN cr_contratos (pr_cdcooper => rw_cop.cdcooper)LOOP

      pc_escreve_relatorio(rw_contratos.cdcooper      || ';' ||
                           rw_contratos.nrdconta      || ';' ||
                           rw_contratos.nrctremp      || ';' ||
                           rw_contratos.dtmvtolt      || ';' ||
                           rw_contratos.idquapro|| ';' ||  -- DE
                           '4');               -- PARA

      pc_escreve_rollback('UPDATE crapepr SET idquaprc = 5' ||
                          ' WHERE cdcooper = ' || rw_contratos.cdcooper ||
                          ' AND nrdconta = ' || rw_contratos.nrdconta ||
                          ' AND nrctremp = ' || rw_contratos.nrctremp || ';');
      pc_escreve_rollback('UPDATE crawepr SET idquapro = 5' ||
                          ' WHERE cdcooper = ' || rw_contratos.cdcooper ||
                          ' AND nrdconta = ' || rw_contratos.nrdconta ||
                          ' AND nrctremp = ' || rw_contratos.nrctremp || ';');
      BEGIN
        UPDATE crapepr e
           SET e.idquaprc = 4
         WHERE cdcooper = rw_contratos.cdcooper 
           AND nrdconta = rw_contratos.nrdconta
           AND nrctremp = rw_contratos.nrctremp;
      EXCEPTION
        WHEN OTHERS THEN
          pc_escreve_erro('ERR_UPD1,' ||
                           rw_contratos.cdcooper      || ';' ||
                           rw_contratos.nrdconta      || ';' ||
                           rw_contratos.nrctremp      || ';' ||
                           rw_contratos.dtmvtolt      || ';' ||
                           rw_contratos.idquapro|| ';' ||  -- DE
                           '4');
      END;
      BEGIN
        UPDATE crawepr w
           SET w.idquapro = 4
         WHERE cdcooper = rw_contratos.cdcooper 
           AND nrdconta = rw_contratos.nrdconta
           AND nrctremp = rw_contratos.nrctremp;
      EXCEPTION
        WHEN OTHERS THEN
          pc_escreve_erro('ERR_UPD2,' ||
                           rw_contratos.cdcooper      || ';' ||
                           rw_contratos.nrdconta      || ';' ||
                           rw_contratos.nrctremp      || ';' ||
                           rw_contratos.dtmvtolt      || ';' ||
                           rw_contratos.idquapro|| ';' ||  -- DE
                           '4');
      END;
    END LOOP;
    COMMIT; -- Commit por Cooperativa
  END LOOP;




  -- FINAL
  -- FINAL
  pc_escreve_relatorio(' ',TRUE);
  DBMS_XSLPROCESSOR.CLOB2FILE(vr_des_rel, vr_dirname, 'QUALIFICACAO_DE_PARA_'||to_char(sysdate,'ddmmyyyy_hh24miss')|| '.txt', NLS_CHARSET_ID('UTF8'));

  dbms_lob.close(vr_des_rel);
  dbms_lob.freetemporary(vr_des_rel);

  pc_escreve_rollback(' ',TRUE);
  DBMS_XSLPROCESSOR.CLOB2FILE(vr_des_log, vr_dirname, 'QUALIFICACAO_ROLLBACK_'||to_char(sysdate,'ddmmyyyy_hh24miss')|| '.sql', NLS_CHARSET_ID('UTF8'));

  -- Liberando a memória alocada pro CLOB
  dbms_lob.close(vr_des_log);
  dbms_lob.freetemporary(vr_des_log);

  pc_escreve_erro(' ',TRUE);
  DBMS_XSLPROCESSOR.CLOB2FILE(vr_des_erro, vr_dirname, 'QUALIFICACAO_ERROS_'||to_char(sysdate,'ddmmyyyy_hh24miss')|| '.txt', NLS_CHARSET_ID('UTF8'));

  -- Liberando a memória alocada pro CLOB
  dbms_lob.close(vr_des_erro);
  dbms_lob.freetemporary(vr_des_erro);

  -- Permissão nos arquivos
  gene0001.pc_OScommand_Shell(pr_des_comando => 'chmod 777 ' || vr_dsdireto || '/*'
                             ,pr_typ_saida   => vr_typ_saida
                             ,pr_des_saida   => vr_dscritic);

  COMMIT;

END;
0
3
vr_dsdireto
vr_des_rel
pr_des_dados
