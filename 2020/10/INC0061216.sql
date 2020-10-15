-- Created on 02/10/2020 by T0032717 
DECLARE 
  
  CURSOR cr_crapcop IS
    SELECT cdcooper
      FROM crapcop
     WHERE flgativo = 1;
  rw_crapcop cr_crapcop%ROWTYPE;
  
  CURSOR cr_principal(pr_cdcooper IN crapcop.cdcooper%TYPE) IS
    SELECT e.cdcooper, e.nrdconta 
         , e.nrctremp, e.DTPREJUZ
         , e.VLSDPREJ, e.VLIOFCPL
         , e.vltiofpr, e.cdfinemp
         , e.vlpiofpr, c.dtdbaixa
      FROM crapepr e, crapcyb c
     WHERE e.inprejuz = 1 
       AND e.vliofcpl > 0 
       AND c.cdcooper = e.cdcooper
       AND c.nrdconta = e.nrdconta
       AND c.nrctremp = e.nrctremp
       AND e.cdcooper = pr_cdcooper
       AND c.dtdbaixa IS NULL;
  rw_principal cr_principal%ROWTYPE;

  rw_crapdat btch0001.cr_crapdat%ROWTYPE;

  --Variaveis para retorno de erro
  vr_cdcritic      INTEGER:= 0;
  vr_dscritic      VARCHAR2(4000);
  vr_exc_erro      EXCEPTION;
  
  vr_nmarqrbk       VARCHAR2(100);
  vr_nmdireto       VARCHAR2(400); 
  vr_dados_rollback CLOB; -- Grava update de rollback
  vr_texto_rollback VARCHAR2(32600);
  
  vr_contratos      VARCHAR2(2000);
  
  -- Validacao de diretorio
  PROCEDURE pc_valida_direto(pr_nmdireto IN VARCHAR2
                             ,pr_dscritic OUT crapcri.dscritic%TYPE) IS
  BEGIN
    DECLARE
      vr_dscritic crapcri.dscritic%TYPE;
      vr_typ_saida VARCHAR2(3);
      vr_des_saida VARCHAR2(1000);      
    BEGIN
        -- Primeiro garantimos que o diretorio exista
        IF NOT gene0001.fn_exis_diretorio(pr_nmdireto) THEN

          -- Efetuar a criação do mesmo
          gene0001.pc_OSCommand_Shell(pr_des_comando => 'mkdir ' || pr_nmdireto || ' 1> /dev/null'
                                      ,pr_typ_saida  => vr_typ_saida
                                      ,pr_des_saida  => vr_des_saida);

          --Se ocorreu erro dar RAISE
          IF vr_typ_saida = 'ERR' THEN
             vr_dscritic := 'CRIAR DIRETORIO ARQUIVO --> Nao foi possivel criar o diretorio para gerar os arquivos. ' || vr_des_saida;
             RAISE vr_exc_erro;
          END IF;

          -- Adicionar permissão total na pasta
          gene0001.pc_OSCommand_Shell(pr_des_comando => 'chmod 777 ' || pr_nmdireto || ' 1> /dev/null'
                                      ,pr_typ_saida  => vr_typ_saida
                                      ,pr_des_saida  => vr_des_saida);

          --Se ocorreu erro dar RAISE
          IF vr_typ_saida = 'ERR' THEN
             vr_dscritic := 'PERMISSAO NO DIRETORIO --> Nao foi possivel adicionar permissao no diretorio dos arquivos. ' || vr_des_saida;
             RAISE vr_exc_erro;
          END IF;

        END IF;
    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_dscritic := vr_dscritic;
    END;    
  END;
BEGIN
  vr_nmdireto := gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS') || 'cpd/bacas/INC0061216';
  vr_nmarqrbk := 'ROLLBACK_IOFCPL_'||to_char(sysdate,'ddmmyyyy_hh24miss')||'.sql';
  
  pc_valida_direto(pr_nmdireto => vr_nmdireto
                  ,pr_dscritic => vr_dscritic);
    
  IF TRIM(vr_dscritic) IS NOT NULL THEN
     RAISE vr_exc_erro;
  END IF;  
  vr_dados_rollback := NULL;

  dbms_lob.createtemporary(vr_dados_rollback, TRUE, dbms_lob.CALL);
  dbms_lob.open(vr_dados_rollback, dbms_lob.lob_readwrite);     

  gene0002.pc_escreve_xml(vr_dados_rollback, vr_texto_rollback, '-- Programa para rollback das informacoes'||chr(13), FALSE);
  
  FOR rw_crapcop IN cr_crapcop LOOP
		vr_contratos := '';
    FOR rw_principal IN cr_principal(pr_cdcooper => rw_crapcop.cdcooper) LOOP
      OPEN btch0001.cr_crapdat(pr_cdcooper => rw_crapcop.cdcooper);
      FETCH btch0001.cr_crapdat  INTO rw_crapdat;
      CLOSE btch0001.cr_crapdat;
      -- abono para o vliofcpl
      empr0001.pc_cria_lancamento_lem(pr_cdcooper => rw_crapcop.cdcooper
                                     ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                     ,pr_cdagenci => 1
                                     ,pr_cdbccxlt => 100
                                     ,pr_cdoperad => 1
                                     ,pr_cdpactra => 1
                                     ,pr_tplotmov => 5
                                     ,pr_nrdolote => 600029
                                     ,pr_nrdconta => rw_principal.nrdconta
                                     ,pr_cdhistor => 2391 -- abono
                                     ,pr_nrctremp => rw_principal.nrctremp
                                     ,pr_vllanmto => rw_principal.vliofcpl
                                     ,pr_dtpagemp => rw_crapdat.dtmvtolt
                                     ,pr_txjurepr => 0
                                     ,pr_vlpreemp => 0
                                     ,pr_nrsequni => 0
                                     ,pr_nrparepr => 0
                                     ,pr_flgincre => TRUE 
                                     ,pr_flgcredi => FALSE  
                                     ,pr_nrseqava => 0
                                     ,pr_cdorigem => 7 -- batch
                                     ,pr_cdcritic => vr_cdcritic
                                     ,pr_dscritic => vr_dscritic);
      
      gene0002.pc_escreve_xml(vr_dados_rollback
                             ,vr_texto_rollback
                             ,'UPDATE crapepr e ' || chr(13) || 
                              '   SET e.vltiofpr = ' || rw_principal.vltiofpr  || chr(13) ||
                              '     , e.vlsdprej = ' || rw_principal.vlsdprej  || chr(13) ||
                              '     , e.vliofcpl = ' || rw_principal.vliofcpl  || chr(13) ||
                              ' WHERE e.cdcooper = ' || rw_crapcop.cdcooper    || chr(13) ||
                              '   AND e.nrdconta = ' || rw_principal.nrdconta  || chr(13) ||
                              '   AND e.nrctremp = ' || rw_principal.nrctremp  || '; ' ||chr(13)||chr(13), FALSE);  
      
      -- Corrige o iof e saldo prejuizo para fluxo de pagamento lançar o valor corretamente
      UPDATE crapepr e
         SET e.vltiofpr = e.vliofcpl
           , e.vlsdprej = e.vlsdprej - e.vliofcpl
           , e.vliofcpl = 0
       WHERE e.cdcooper = rw_crapcop.cdcooper
         AND e.nrdconta = rw_principal.nrdconta
         AND e.nrctremp = rw_principal.nrctremp;
  
      vr_contratos := vr_contratos || rw_principal.nrctremp || ';';

    END LOOP;
    
    INSERT INTO crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
    VALUES ('CRED', rw_crapcop.cdcooper, 'IGNABONO_PREJ_ERR', 'Ignorar abonos de correcao para evitar valor negativo em tela de pagamento', vr_contratos);
  
    INSERT INTO crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
    VALUES ('CRED', rw_crapcop.cdcooper, 'IGNABONO_PREJ_ERR_DT', 'Data de movimento para ignorar abonos de correcao para evitar valor negativo em tela de pagamento', rw_crapdat.dtmvtolt);
  END LOOP;
  
  -- Adiciona TAG de commit 
  gene0002.pc_escreve_xml(vr_dados_rollback, vr_texto_rollback, 'COMMIT;'||chr(13), FALSE);
        
  -- Fecha o arquivo          
  gene0002.pc_escreve_xml(vr_dados_rollback, vr_texto_rollback, chr(13), TRUE);    
  
  -- Grava o arquivo de rollback
  GENE0002.pc_solicita_relato_arquivo(pr_cdcooper  => 3                     --> Cooperativa conectada
                                     ,pr_cdprogra  => 'ATENDA'                      --> Programa chamador - utilizamos apenas um existente 
                                     ,pr_dtmvtolt  => trunc(SYSDATE)                --> Data do movimento atual
                                     ,pr_dsxml     => vr_dados_rollback             --> Arquivo XML de dados
                                     ,pr_dsarqsaid => vr_nmdireto||'/'||vr_nmarqrbk --> Path/Nome do arquivo PDF gerado
                                     ,pr_flg_impri => 'N'                           --> Chamar a impressão (Imprim.p)
                                     ,pr_flg_gerar => 'S'                           --> Gerar o arquivo na hora
                                     ,pr_flgremarq => 'N'                           --> remover arquivo apos geracao
                                     ,pr_nrcopias  => 1                             --> Número de cópias para impressão
                                     ,pr_des_erro  => vr_dscritic);                 --> Retorno de Erro
        
  IF TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;
  END IF;    
  
  COMMIT;
  
  -- Liberando a memória alocada pro CLOB
  dbms_lob.close(vr_dados_rollback);
  dbms_lob.freetemporary(vr_dados_rollback);
    
EXCEPTION
  WHEN vr_exc_erro THEN
    raise_application_error(-20111, vr_dscritic);
END;
