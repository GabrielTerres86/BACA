DECLARE
  
  vr_nmdireto           VARCHAR2(100);
  vr_nmarquiv           VARCHAR2(50) := 'PRB957210_dados_atualizar.csv';
  vr_input_file         UTL_FILE.FILE_TYPE;
  vr_nmarqbkp           VARCHAR2(50) := 'PRB957210_script_ROLLBACK';
  vr_ind_arquiv         utl_file.file_type;
  vr_nmarqlog           VARCHAR2(50) := 'PRB957210_relatorio_exec.txt';
  vr_ind_arqlog         utl_file.file_type;
  vr_base_log           VARCHAR(500);
  
  vr_texto_completo     VARCHAR2(32600) := NULL;
  vr_texto_completo_ret VARCHAR2(32600) := NULL;
  vr_setlinha           VARCHAR2(10000);
  vr_count              PLS_INTEGER;
  vr_count_file         PLS_INTEGER;
  vr_seq_file           NUMBER(2);
  
  vr_email              CECRED.crapcem.DSDEMAIL%TYPE;
  vr_nrcpfcgc           CECRED.crapass.NRCPFCGC%TYPE;
  vr_nrcpfcgc_tmp       CECRED.crapass.NRCPFCGC%TYPE;
  vr_qtd_regs_upd       PLS_INTEGER;
  idx                   PLS_INTEGER;
  vr_qtd_principais     PLS_INTEGER;
  vr_principalok        BOOLEAN;
  vr_dsmodule           VARCHAR2(100);
  
  vr_comments           VARCHAR2(2000);
  
  vr_nrmatric_new       CECRED.CRAPASS.NRMATRIC%TYPE;
  
  TYPE TP_CPF IS TABLE OF VARCHAR2(100) INDEX BY VARCHAR2(30);
  
  vt_emailprc  TP_CPF;
  
  TYPE RC_MAIL IS RECORD (
    NRCPFCGC       CECRED.crapass.NRCPFCGC%TYPE
    , CDCOOPER     CECRED.crapass.CDCOOPER%TYPE
    , NRDCONTA     CECRED.crapass.NRDCONTA%TYPE 
    , IDSEQTTL     CECRED.crapcem.IDSEQTTL%TYPE
    , DSDEMAIL     CECRED.crapcem.DSDEMAIL%TYPE
    , INPRINCIPAL  CECRED.crapcem.INPRINCIPAL%TYPE
    , INPRINCIPAL_ANT  CECRED.crapcem.INPRINCIPAL%TYPE
    , DTREFATU     VARCHAR2(30)
    , DTINSORI     VARCHAR2(30)
    , CDDEMAIL     CECRED.crapcem.CDDEMAIL%TYPE
  );
  
  TYPE TP_MAILS_COOPERADO IS TABLE OF RC_MAIL INDEX BY PLS_INTEGER;
  vt_mails_cooperado  TP_MAILS_COOPERADO;
  
  vr_dscritic           VARCHAR2(2000);
  vr_exception          EXCEPTION;
  
  vr_dscritic_mat       VARCHAR2(4000);
  
  CURSOR cr_emails_corrigir IS
    WITH BASE_EMAILS_CORRIGIR_AIMARO AS (
      SELECT E.CDCOOPER
        , E.NRDCONTA
        , E.IDSEQTTL
        , E.INPRINCIPAL
        , COUNT(*)       QTD_PRINCIPAIS
      FROM CECRED.CRAPCEM E
      WHERE E.INPRINCIPAL = 1
      GROUP BY E.CDCOOPER
        , E.NRDCONTA
        , E.IDSEQTTL
        , E.INPRINCIPAL
      HAVING COUNT(*) > 1
    )
    SELECT * 
    FROM (
      SELECT T.NRCPFCGC
        , BC.QTD_PRINCIPAIS
        , EM.*
      FROM CECRED.CRAPCEM              EM
      JOIN BASE_EMAILS_CORRIGIR_AIMARO BC ON EM.CDCOOPER = BC.CDCOOPER
                                             AND EM.NRDCONTA = BC.NRDCONTA
                                             AND EM.IDSEQTTL = BC.IDSEQTTL
      JOIN CECRED.CRAPTTL              T  ON EM.CDCOOPER = T.CDCOOPER
                                             AND EM.NRDCONTA = T.NRDCONTA
                                             AND EM.IDSEQTTL = T.IDSEQTTL
      WHERE EM.INPRINCIPAL > 0
      
      UNION ALL

      SELECT T.NRCPFCGC
        , BC.QTD_PRINCIPAIS
        , EM.*
      FROM CECRED.CRAPCEM              EM
      JOIN BASE_EMAILS_CORRIGIR_AIMARO BC ON EM.CDCOOPER = BC.CDCOOPER
                                             AND EM.NRDCONTA = BC.NRDCONTA
                                             AND EM.IDSEQTTL = BC.IDSEQTTL
      JOIN CECRED.CRAPASS              T  ON EM.CDCOOPER = T.CDCOOPER
                                             AND EM.NRDCONTA = T.NRDCONTA
      WHERE T.INPESSOA > 1
        AND EM.INPRINCIPAL > 0
    )
    ORDER BY NRCPFCGC
      , NVL(DTREFATU, DTINSORI) DESC
      , CDDEMAIL DESC
      , CDCOOPER
      , NRDCONTA
      , IDSEQTTL;
  
  TYPE TP_EMLS IS TABLE OF cr_emails_corrigir%ROWTYPE;
  vt_emails_corrigir TP_EMLS;
  
  PROCEDURE prc_atualiza_email_principal (pr_nrcpfcgc         IN CECRED.crapass.NRCPFCGC%TYPE
                                        , pr_cdcooper         IN CECRED.crapass.CDCOOPER%TYPE
                                        , pr_nrdconta         IN CECRED.crapass.NRDCONTA%TYPE
                                        , pr_idseqttl         IN CECRED.crapcem.IDSEQTTL%TYPE
                                        , pr_dsdemail         IN CECRED.crapcem.DSDEMAIL%TYPE
                                        , pr_inprincipal      IN CECRED.crapcem.INPRINCIPAL%TYPE
                                        , pr_inprincipal_ANT  IN CECRED.crapcem.INPRINCIPAL%TYPE
                                        , pr_dtrefatu         IN CECRED.crapcem.DTREFATU%TYPE  ) IS 
    
  BEGIN
    
    vr_comments := ' ### Inicializa sessão do Centralizado para NÃO deixar a trigger do Aimaro levar a info para o Centralizado, pois será tratado em outro script.';
    CADA0016.pc_sessao_trigger( pr_tpmodule => 1,
                                pr_dsmodule => vr_dsmodule);
    
    BEGIN
      
      UPDATE CECRED.CRAPCEM M
        SET M.INPRINCIPAL = pr_inprincipal
          , M.DTREFATU = TO_DATE( TO_CHAR( SYSDATE, 'DD/MM/RRRR HH24:MI:SS' ), 'DD/MM/RRRR HH24:MI:SS' )
      WHERE M.CDCOOPER = pr_cdcooper
        AND M.NRDCONTA = pr_nrdconta
        AND M.IDSEQTTL = pr_idseqttl
        AND UPPER( TRIM( M.DSDEMAIL ) ) = pr_dsdemail;
      
      vr_comments := ' ### Update seguro: UK - CRAPCEM##CRAPCEM2 - [ CDCOOPER, NRDCONTA, IDSEQTTL, UPPER(DSDEMAIL) ]';
      
      gene0001.pc_escr_linha_arquivo(vr_ind_arquiv,
        '  UPDATE CECRED.CRAPCEM ' || 
        ' SET INPRINCIPAL = ' || pr_inprincipal_ANT ||
        '   , DTREFATU = TO_DATE(''' || TO_CHAR( pr_dtrefatu, 'DD/MM/RRRR HH24:MI:SS' ) || ''', ''DD/MM/RRRR HH24:MI:SS'') ' ||
        ' WHERE CDCOOPER = ' || pr_cdcooper ||
        '   AND NRDCONTA = ' || pr_nrdconta ||
        '   AND IDSEQTTL = ' || pr_idseqttl || 
        '   AND UPPER( TRIM( DSDEMAIL ) ) = ''' || pr_dsdemail || ''' ;'
      );
      
      vr_count := vr_count + 1;
      
    EXCEPTION
      WHEN OTHERS THEN
        
        gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, 'ERRO   ;'   ||
                                                      vr_base_log  ||
                                                      ' Erro ao atualizar CRAPCEM: ' || SQLERRM );
        
    END;
    
    vr_comments := ' ### Finaliza sessao do cadastro centralizado.';
    CADA0016.pc_sessao_trigger( pr_tpmodule => 2,
                                pr_dsmodule => vr_dsmodule);
    
    gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, 'Dados Ajustados; ' || 
                                                    vr_base_log       ||
                                                    CASE WHEN pr_inprincipal <> pr_inprincipal_ANT
                                                      THEN ' Email principal de: (' || pr_inprincipal_ANT || ') para: (' || pr_inprincipal || ').' 
                                                      ELSE ' Definido como PRINCIPAL ' END
                                                   );
    
  END prc_atualiza_email_principal;
  
  PROCEDURE prc_registra_atualizacoes IS
    
  BEGIN
    
    IF vt_mails_cooperado.COUNT() > 0 THEN
      
      vr_comments := ' ### Tratar os UPDATE nos e-mails do cooperado.';
      vr_qtd_principais := 0;
      FOR jj IN vt_mails_cooperado.FIRST..vt_mails_cooperado.LAST LOOP
        
        vr_base_log := vt_mails_cooperado(jj).NRCPFCGC         || ';' ||
                       vt_mails_cooperado(jj).CDCOOPER         || ';' ||
                       vt_mails_cooperado(jj).NRDCONTA         || ';' ||
                       vt_mails_cooperado(jj).IDSEQTTL         || ';' ||
                       vt_mails_cooperado(jj).DSDEMAIL         || ';' ||
                       NVL( vt_mails_cooperado(jj).DTREFATU, 'NULL' ) || ';' ||
                       NVL( vt_mails_cooperado(jj).DTINSORI, 'NULL' ) || ';' ||
                       vt_mails_cooperado(jj).CDDEMAIL         || ';' ||
                       vt_mails_cooperado(jj).INPRINCIPAL      || ';';
        
        vr_comments := ' ### Atualizar UM e-mail do cooperado para Principal e TODOS os demais para não.';
        
        prc_atualiza_email_principal (
          vt_mails_cooperado(jj).NRCPFCGC
          , vt_mails_cooperado(jj).CDCOOPER
          , vt_mails_cooperado(jj).NRDCONTA
          , vt_mails_cooperado(jj).IDSEQTTL
          , vt_mails_cooperado(jj).DSDEMAIL
          , vt_mails_cooperado(jj).INPRINCIPAL
          , vt_mails_cooperado(jj).INPRINCIPAL_ANT
          , TO_DATE(vt_mails_cooperado(jj).DTREFATU, 'DD/MM/RRRR HH24:MI:SS')
        );
        
        IF vt_mails_cooperado(jj).INPRINCIPAL = 1 THEN
          
          vr_qtd_principais := vr_qtd_principais + 1;
          
        END IF;
        
      END LOOP;
      
      vr_comments := ' ### Validações para garantia da qualidade da alteração. Deve existir pelo menos UM como principal.';
      IF vr_qtd_principais = 0 THEN
        
        vr_base_log := vt_mails_cooperado(1).NRCPFCGC         || ';' ||
                       vt_mails_cooperado(1).CDCOOPER         || ';' ||
                       vt_mails_cooperado(1).NRDCONTA         || ';' ||
                       vt_mails_cooperado(1).IDSEQTTL         || ';' ||
                       vt_mails_cooperado(1).DSDEMAIL         || ';' ||
                       NVL( vt_mails_cooperado(1).DTREFATU, 'NULL' ) || ';' ||
                       NVL( vt_mails_cooperado(1).DTINSORI, 'NULL' ) || ';' ||
                       vt_mails_cooperado(1).CDDEMAIL         || ';' ||
                       vt_mails_cooperado(1).INPRINCIPAL      || ';';
        
        vr_comments := ' ### Caso nenhum tenha sido definido como principal, chamar a procedure novamente e defiir o mais RECENTE como tal, que é o da posição 1 do vetor.';
        vr_comments := ' ### Isso irá ocorrer quando não houve correção para o cooperado no script do CC.';
        prc_atualiza_email_principal (
          vt_mails_cooperado(1).NRCPFCGC
          , vt_mails_cooperado(1).CDCOOPER
          , vt_mails_cooperado(1).NRDCONTA
          , vt_mails_cooperado(1).IDSEQTTL
          , vt_mails_cooperado(1).DSDEMAIL
          , 1
          , vt_mails_cooperado(1).INPRINCIPAL_ANT
          , TO_DATE(vt_mails_cooperado(1).DTREFATU, 'DD/MM/RRRR HH24:MI:SS')
        );
        
      END IF;
      
      IF vr_qtd_principais > 1 THEN
        
        vr_comments := ' ### Registrar log para solução posterior caso exista mais de um principal. Situação NÃO deve ocorrer.';
        gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, 'ALERTA;' || vr_base_log 
                                                      || ' Quantidade de emails principais maior que o esperado: ' || vr_qtd_principais );
        
      END IF;
      
    END IF;
    
  END prc_registra_atualizacoes;
  
BEGIN
  
  vr_nmdireto := gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS') || 'cpd/bacas/PRB957210';
  
  vr_count_file := 0;
  vr_seq_file   := 1;
  gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto
                          ,pr_nmarquiv => vr_nmarqbkp || LPAD(vr_seq_file, 3, '0') || '.sql'
                          ,pr_tipabert => 'W'
                          ,pr_utlfileh => vr_ind_arquiv
                          ,pr_des_erro => vr_dscritic);
                          
  IF vr_dscritic IS NOT NULL THEN
    
    RAISE vr_exception;
     
  END IF;
  
  gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto
                          ,pr_nmarquiv => vr_nmarqlog
                          ,pr_tipabert => 'W'
                          ,pr_utlfileh => vr_ind_arqlog
                          ,pr_des_erro => vr_dscritic);
                          
  IF vr_dscritic IS NOT NULL THEN
    
    RAISE vr_exception;
    
  END IF;
  
  gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, 'DECLARE');
  gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, '  vr_dsmodule VARCHAR2(100);');
  gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, 'BEGIN');
  gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, '  CADA0016.pc_sessao_trigger( pr_tpmodule => 1, pr_dsmodule => vr_dsmodule);');
  
  gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, 'Inicio: ' || TO_CHAR(SYSDATE, 'DD/MM/RRRR HH24:MI:SS') );
  vr_count := 0;
  
  vr_comments := ' ### Busca os emails com problema no Aimaro para fazer as correções';
  OPEN cr_emails_corrigir;
  FETCH cr_emails_corrigir BULK COLLECT INTO vt_emails_corrigir;
  CLOSE cr_emails_corrigir;
  
  gene0001.pc_escr_linha_arquivo( vr_ind_arqlog, 'VALIDACAO;TOTAL DADOS corrigir Aimaro: ' || vt_emails_corrigir.COUNT() );
  
  vr_comments := ' ### Cabeçalho do log de execução.';
  gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, 'TIPO LOG;NRCPFCGC;CDCOOPER;NRDCONTA;IDSEQTTL;DSDEMAIL;DTREFATU;DTINSORI;CDDEMAIL;INPRINCIPAL Aimaro;DS LOG');
  
  IF vt_emails_corrigir.COUNT() > 0 THEN
    
    vr_nrcpfcgc_tmp := -1;
    idx             := NULL;
    
    FOR e IN vt_emails_corrigir.FIRST..vt_emails_corrigir.LAST LOOP
      
      vr_comments := ' ### Controla todos os emails do cooperado através do vetor vt_mails_cooperado, utilizado para garantir que apenas um ficará no final como principal.';
      
      IF NOT vt_emailprc.EXISTS( vt_emails_corrigir(e).NRCPFCGC ) AND vt_emails_corrigir(e).INPRINCIPAL = 1 THEN
        
        vr_comments := ' ### Armazena o e-mail definido como principal para replicar o mesmo em todas as contas do cooperado.';
        vt_emailprc( vt_emails_corrigir(e).NRCPFCGC ) := UPPER( TRIM( vt_emails_corrigir(e).DSDEMAIL ) );
        
      END IF;
      
      IF vr_nrcpfcgc_tmp <> vt_emails_corrigir(e).NRCPFCGC THEN
        
        vr_comments := ' ### NOVO CPF ';
        vr_comments := ' ### Finalizar a atualização do anterior setando um como principal E ';
        vr_comments := ' ### Armazenar o primeiro registro do CPF da vez.';
        
        vr_nrcpfcgc_tmp := vt_emails_corrigir(e).NRCPFCGC;
        vr_principalok  := FALSE;
        
        vr_comments := ' ### Chama procedure para registrar as atualizações.';
        prc_registra_atualizacoes;
        
        vt_mails_cooperado.DELETE();
        idx := 1;
        
        vt_mails_cooperado(idx).NRCPFCGC     := vt_emails_corrigir(e).NRCPFCGC;
        vt_mails_cooperado(idx).CDCOOPER     := vt_emails_corrigir(e).CDCOOPER;
        vt_mails_cooperado(idx).NRDCONTA     := vt_emails_corrigir(e).NRDCONTA;
        vt_mails_cooperado(idx).IDSEQTTL     := vt_emails_corrigir(e).IDSEQTTL;
        vt_mails_cooperado(idx).DSDEMAIL     := UPPER( TRIM( vt_emails_corrigir(e).DSDEMAIL ) );
        vt_mails_cooperado(idx).DTREFATU     := TO_CHAR(vt_emails_corrigir(e).DTREFATU, 'DD/MM/RRRR HH24:MI:SS');
        vt_mails_cooperado(idx).DTINSORI     := TO_CHAR(vt_emails_corrigir(e).DTINSORI, 'DD/MM/RRRR HH24:MI:SS');
        vt_mails_cooperado(idx).CDDEMAIL     := vt_emails_corrigir(e).CDDEMAIL;
        vt_mails_cooperado(idx).INPRINCIPAL_ANT  := vt_emails_corrigir(e).INPRINCIPAL;
        vt_mails_cooperado(idx).INPRINCIPAL  := CASE 
                                                  WHEN vt_emailprc.EXISTS( vt_emails_corrigir(e).NRCPFCGC ) AND vt_emailprc( vt_emails_corrigir(e).NRCPFCGC ) = UPPER( TRIM( vt_emails_corrigir(e).DSDEMAIL ) )
                                                    THEN 1
                                                  ELSE 0 END;
        
      ELSE
        
        idx := idx + 1;
        
        vt_mails_cooperado(idx).NRCPFCGC     := vt_emails_corrigir(e).NRCPFCGC;
        vt_mails_cooperado(idx).CDCOOPER     := vt_emails_corrigir(e).CDCOOPER;
        vt_mails_cooperado(idx).NRDCONTA     := vt_emails_corrigir(e).NRDCONTA;
        vt_mails_cooperado(idx).IDSEQTTL     := vt_emails_corrigir(e).IDSEQTTL;
        vt_mails_cooperado(idx).DSDEMAIL     := UPPER( vt_emails_corrigir(e).DSDEMAIL );
        vt_mails_cooperado(idx).DTREFATU     := TO_CHAR(vt_emails_corrigir(e).DTREFATU, 'DD/MM/RRRR HH24:MI:SS');
        vt_mails_cooperado(idx).DTINSORI     := TO_CHAR(vt_emails_corrigir(e).DTINSORI, 'DD/MM/RRRR HH24:MI:SS');
        vt_mails_cooperado(idx).CDDEMAIL     := vt_emails_corrigir(e).CDDEMAIL;
        vt_mails_cooperado(idx).INPRINCIPAL_ANT  := vt_emails_corrigir(e).INPRINCIPAL;
        vt_mails_cooperado(idx).INPRINCIPAL  := CASE 
                                                  WHEN vt_emailprc.EXISTS( vt_emails_corrigir(e).NRCPFCGC ) AND vt_emailprc( vt_emails_corrigir(e).NRCPFCGC ) = UPPER( TRIM( vt_emails_corrigir(e).DSDEMAIL ) )
                                                    THEN 1
                                                  ELSE 0 END;
        
      END IF;
      
      IF vr_count >= 500 THEN
        
        COMMIT;
        
        vr_count := 0;
        
      END IF;
      
    END LOOP;
    
    vr_comments := ' ### Chama procedure para registrar as atualizações - ÚLTIMOS REGISTROS DO VETOR';
    prc_registra_atualizacoes;
    
  END IF;
  
  gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, '  CADA0016.pc_sessao_trigger( pr_tpmodule => 2, pr_dsmodule => vr_dsmodule);');
  gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, '  COMMIT;');
  gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, 'EXCEPTION WHEN OTHERS THEN ROLLBACK; RAISE_APPLICATION_ERROR(-20000, SQLERRM); END;');
  gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv);
  
  gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, 'Final do script: ' || TO_CHAR(SYSDATE, 'DD/MM/RRRR HH24:MI:SS'));
  gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arqlog);
  
  COMMIT;
  
EXCEPTION
  WHEN vr_exception THEN
    
    GENE0001.pc_fecha_arquivo(pr_utlfileh => vr_input_file);
    
    gene0001.pc_escr_linha_arquivo( vr_ind_arquiv, 'ERRO: ' || vr_dscritic );
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv);
    
    gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, vr_dscritic);
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arqlog);
    
    ROLLBACK;
    
    RAISE_APPLICATION_ERROR(-20003, 'Erro: ' || vr_dscritic);
    
  WHEN OTHERS THEN
    
    cecred.pc_internal_exception;
    
    GENE0001.pc_fecha_arquivo(pr_utlfileh => vr_input_file);
    
    gene0001.pc_escr_linha_arquivo( vr_ind_arquiv, 'ERRO: ' || SQLERRM );
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv);
    
    gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, 'ERRO NAO TRATADO: ' || SQLERRM);
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arqlog);
    
    ROLLBACK;
    
    RAISE_APPLICATION_ERROR(-20004, 'ERRO NÃO TRATADO: ' || SQLERRM);
    
END;
