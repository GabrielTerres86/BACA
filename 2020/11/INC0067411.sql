-- Created on 16/10/2020 by T0032717 
DECLARE 
  
  CURSOR cr_crapcop IS
    SELECT cdcooper
      FROM crapcop
     WHERE flgativo = 1;
  rw_crapcop cr_crapcop%ROWTYPE;
  
  CURSOR cr_principal(pr_cdcooper IN crapcop.cdcooper%TYPE) IS
    SELECT r.nrdconta, r.nrctremp
      FROM tbepr_renegociacao r 
     WHERE r.cdcooper = pr_cdcooper
       AND NOT EXISTS (SELECT 1 
                         FROM crawepr w  
                        WHERE w.cdcooper = r.cdcooper 
                          AND w.nrdconta = r.nrdconta
                          AND w.nrctremp = r.nrctremp)
       AND r.dtlibera IS NULL;
  rw_principal cr_principal%ROWTYPE;
  
  CURSOR cr_reneg(pr_cdcooper IN tbepr_renegociacao.cdcooper%TYPE
                 ,pr_nrdconta IN tbepr_renegociacao.nrdconta%TYPE
                 ,pr_nrctremp IN tbepr_renegociacao.nrctremp%TYPE) IS
    SELECT r.cdcooper,
           r.nrdconta,
           r.nrctremp,
           r.flgdocje,
           r.idfiniof,
           r.dtdpagto,
           r.qtpreemp,
           r.vlemprst,
           r.vlpreemp,
           r.dtlibera,
           r.idfintar
      FROM tbepr_renegociacao r
     WHERE r.cdcooper = pr_cdcooper
       AND r.nrdconta = pr_nrdconta
       AND r.nrctremp = pr_nrctremp;
  rw_reneg cr_reneg%ROWTYPE;
  
  CURSOR cr_ctr_reneg(pr_cdcooper IN tbepr_renegociacao.cdcooper%TYPE
                     ,pr_nrdconta IN tbepr_renegociacao.nrdconta%TYPE
                     ,pr_nrctremp IN tbepr_renegociacao.nrctremp%TYPE) IS
    SELECT r.cdcooper,
           r.nrdconta,
           r.nrctremp,
           r.nrctrepr,
           r.nrversao,
           r.vlsdeved,
           r.vlnvsdde,
           r.vlnvpres,
           r.tpemprst,
           r.nrctrotr,
           r.cdfinemp,
           r.cdlcremp,
           r.dtdpagto,
           r.idcarenc,
           r.dtcarenc,
           r.vlprecar,
           r.vliofepr,
           r.vltarepr,
           r.idqualop,
           r.nrdiaatr,
           r.cdlcremp_origem,
           r.cdfinemp_origem,
           r.vlemprst,
           r.vlfinanc,
           r.vliofadc,
           r.vliofpri,
           r.percetop,
           r.flgimune,
           r.tpcontrato_liquidado,
           r.incancelar_produto,
           r.nrctremp_novo
      FROM tbepr_renegociacao_contrato r
     WHERE r.cdcooper = pr_cdcooper
       AND r.nrdconta = pr_nrdconta
       AND r.nrctremp = pr_nrctremp;
  rw_ctr_reneg cr_ctr_reneg%ROWTYPE;

  --Variaveis para retorno de erro
  vr_cdcritic      INTEGER:= 0;
  vr_dscritic      VARCHAR2(4000);
  vr_exc_erro      EXCEPTION;
  
  vr_nmarqrbk       VARCHAR2(100);
  vr_nmdireto       VARCHAR2(400); 
  vr_dados_rollback CLOB; -- Grava update de rollback
  vr_texto_rollback VARCHAR2(32600);
  
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
  vr_nmdireto := gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS') || 'cpd/bacas/INC0067411';
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
    
    FOR rw_principal IN cr_principal(pr_cdcooper => rw_crapcop.cdcooper) LOOP

      FOR rw_reneg IN cr_reneg(pr_cdcooper => rw_crapcop.cdcooper
				                      ,pr_nrdconta => rw_principal.nrdconta
                              ,pr_nrctremp => rw_principal.nrctremp) LOOP
    
        gene0002.pc_escreve_xml(vr_dados_rollback
                               ,vr_texto_rollback
                               ,'INSERT INTO tbepr_renegociacao (' || chr(13) || 
                                '            cdcooper, nrdconta,
                                             nrctremp, flgdocje,
                                             idfiniof, dtdpagto,
                                             qtpreemp, vlemprst,
                                             vlpreemp, dtlibera,
                                             idfintar) VALUES (' || 
                                             rw_reneg.cdcooper || ',' || rw_reneg.nrdconta || ',' ||
                                             rw_reneg.nrctremp || ',' || rw_reneg.flgdocje || ',' ||
                                             rw_reneg.idfiniof || ',''' || rw_reneg.dtdpagto || ''',' ||
                                             rw_reneg.qtpreemp || ',' || REPLACE(rw_reneg.vlemprst, ',', '.') || ',' ||
                                             REPLACE(rw_reneg.vlpreemp, ',', '.') || ',''' || rw_reneg.dtlibera || ''',' ||
                                             rw_reneg.idfintar || '); ' ||chr(13)||chr(13), FALSE); 
      END LOOP;
      
      FOR rw_ctr_reneg IN cr_ctr_reneg(pr_cdcooper => rw_crapcop.cdcooper
				                              ,pr_nrdconta => rw_principal.nrdconta
                                      ,pr_nrctremp => rw_principal.nrctremp) LOOP
    
        gene0002.pc_escreve_xml(vr_dados_rollback
                               ,vr_texto_rollback
                               ,'INSERT INTO tbepr_renegociacao_contrato (' || chr(13) || 
                                '            cdcooper, nrdconta,
                                             nrctremp, nrctrepr,
                                             nrversao, vlsdeved,
                                             vlnvsdde, vlnvpres,
                                             tpemprst, nrctrotr,
                                             cdfinemp, cdlcremp,
                                             dtdpagto, idcarenc,
                                             dtcarenc, vlprecar,
                                             vliofepr, vltarepr,
                                             idqualop, nrdiaatr,
                                             cdlcremp_origem, cdfinemp_origem,
                                             vlemprst, vlfinanc,
                                             vliofadc, vliofpri,
                                             percetop, flgimune,
                                             tpcontrato_liquidado,
                                             incancelar_produto,
                                             nrctremp_novo ) VALUES (' ||
                                             rw_ctr_reneg.cdcooper || ',' || rw_ctr_reneg.nrdconta || ',' ||
                                             rw_ctr_reneg.nrctremp || ',' || rw_ctr_reneg.nrctrepr || ',' ||
                                             rw_ctr_reneg.nrversao || ',' || REPLACE(rw_ctr_reneg.vlsdeved, ',', '.') || ',' ||
                                             REPLACE(rw_ctr_reneg.vlnvsdde, ',', '.') || ',' || REPLACE(rw_ctr_reneg.vlnvpres, ',', '.') || ',' ||
                                             rw_ctr_reneg.tpemprst || ',' ||rw_ctr_reneg.nrctrotr  || ',' ||
                                             rw_ctr_reneg.cdfinemp || ',' || rw_ctr_reneg.cdlcremp || ',''' ||
                                             rw_ctr_reneg.dtdpagto || ''',' || rw_ctr_reneg.idcarenc || ',''' ||
                                             rw_ctr_reneg.dtcarenc || ''',' || rw_ctr_reneg.vlprecar || ',' ||
                                             REPLACE(rw_ctr_reneg.vliofepr, ',', '.') || ',' || REPLACE(rw_ctr_reneg.vltarepr, ',', '.') || ',' ||
                                             rw_ctr_reneg.idqualop || ',' || rw_ctr_reneg.nrdiaatr || ',' ||
                                             rw_ctr_reneg.cdlcremp_origem || ',' || rw_ctr_reneg.cdfinemp_origem || ',' ||
                                             REPLACE(rw_ctr_reneg.vlemprst, ',', '.') || ',' || REPLACE(rw_ctr_reneg.vlfinanc, ',', '.')  || ',' ||
                                             REPLACE(rw_ctr_reneg.vliofadc, ',', '.') || ',' || REPLACE(rw_ctr_reneg.vliofpri, ',', '.') || ',' ||
                                             REPLACE(rw_ctr_reneg.percetop, ',', '.') || ',' || rw_ctr_reneg.flgimune || ',' ||
                                             rw_ctr_reneg.tpcontrato_liquidado || ',' ||
                                             rw_ctr_reneg.incancelar_produto || ',' ||
                                             rw_ctr_reneg.nrctremp_novo || 
                                             '); ' ||chr(13)||chr(13), FALSE); 
      END LOOP;
      
      --
      BEGIN
        DELETE FROM tbepr_renegociacao_contrato
              WHERE cdcooper = rw_crapcop.cdcooper
                AND nrdconta = rw_principal.nrdconta
                AND nrctremp = rw_principal.nrctremp;
      EXCEPTION
        WHEN OTHERS THEN
         CONTINUE;
      END;
          
      --
      BEGIN
        DELETE FROM tbepr_renegociacao
              WHERE cdcooper = rw_crapcop.cdcooper
                AND nrdconta = rw_principal.nrdconta
                AND nrctremp = rw_principal.nrctremp;
      EXCEPTION
        WHEN OTHERS THEN
         CONTINUE;
      END;
  
    END LOOP;
    
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
