DECLARE
  -- Local variables here
  vr_cdcooper   crapcop.cdcooper%TYPE;
  vr_nome_baca  VARCHAR2(100);
  vr_nmarqlog   VARCHAR2(100);
  vr_nmarqimp   VARCHAR2(100);
  vr_nmarqbkp   VARCHAR2(100);
  vr_nmdireto   VARCHAR2(4000); 
  vr_dscritic   crapcri.dscritic%TYPE;
  vr_cdadmcrd   crawcrd.cdadmcrd%TYPE;
  vr_dtpropos   crawcrd.dtpropos%TYPE;
  
  
  vr_exc_erro   EXCEPTION; 
  vr_dados_rollback CLOB; -- Grava update de rollback
  vr_texto_rollback VARCHAR2(32600);
  
  CURSOR cr_bin IS
    SELECT CRD.ROWID    CRAWCRD_ROWID
          ,CRP.ROWID    CRAPCRD_ROWID
          ,CRD.CDADMCRD CRAWCRD_CDADMCRD
          ,CRP.CDADMCRD CRAPCRD_CDADMCRD
          ,TB.CDADMCRD  CDADMCRD
      FROM CRAWCRD CRD
          ,CRAPCRD CRP
          ,TBCRD_GRUPO_AFINIDADE_BIN TB
     WHERE CRD.CDCOOPER = CRP.CDCOOPER
       AND CRD.NRDCONTA = CRP.NRDCONTA
       AND CRD.NRCTRCRD = CRP.NRCTRCRD
       AND CRD.CDADMCRD = CRP.CDADMCRD
       AND CRD.CDCOOPER = TB.CDCOOPER
       AND SUBSTR(CRD.NRCRCARD,1,6) = TB.NRCTAMAE_ANT
       AND CRD.CDADMCRD <> TB.CDADMCRD
       AND CRD.NRCRCARD > 0
       AND CRD.INSITCRD NOT IN (5,6)
       AND CRD.CDADMCRD NOT IN (16,17)
     UNION
    SELECT CRD.ROWID    CRAWCRD_ROWID
          ,CRP.ROWID    CRAPCRD_ROWID
          ,CRD.CDADMCRD CRAWCRD_CDADMCRD
          ,CRP.CDADMCRD CRAPCRD_CDADMCRD
          ,TB.CDADMCRD  CDADMCRD
      FROM CRAWCRD CRD
          ,CRAPCRD CRP
          ,CRAPASS ASS
          ,TBCRD_GRUPO_AFINIDADE_BIN TB
     WHERE CRD.CDCOOPER = CRP.CDCOOPER
       AND CRD.NRDCONTA = CRP.NRDCONTA
       AND CRD.NRCTRCRD = CRP.NRCTRCRD
       AND CRD.CDADMCRD = CRP.CDADMCRD
       AND CRD.CDCOOPER = ASS.CDCOOPER
       AND CRD.NRDCONTA = ASS.NRDCONTA
       AND CRD.CDCOOPER = TB.CDCOOPER
       AND SUBSTR(CRD.NRCRCARD,1,6) = TB.NRCTAMAE_ANT
       AND CRD.CDADMCRD <> TB.CDADMCRD
       AND CRD.NRCRCARD > 0
       AND CRD.INSITCRD NOT IN (5,6)
       AND ASS.INPESSOA = 1
       AND TB.CDADMCRD = 16
     UNION
    SELECT CRD.ROWID    CRAWCRD_ROWID
          ,CRP.ROWID    CRAPCRD_ROWID
          ,CRD.CDADMCRD CRAWCRD_CDADMCRD
          ,CRP.CDADMCRD CRAPCRD_CDADMCRD
          ,TB.CDADMCRD  CDADMCRD
      FROM CRAWCRD CRD
          ,CRAPCRD CRP
          ,CRAPASS ASS
          ,TBCRD_GRUPO_AFINIDADE_BIN TB
     WHERE CRD.CDCOOPER = CRP.CDCOOPER
       AND CRD.NRDCONTA = CRP.NRDCONTA
       AND CRD.NRCTRCRD = CRP.NRCTRCRD
       AND CRD.CDADMCRD = CRP.CDADMCRD
       AND CRD.CDCOOPER = ASS.CDCOOPER
       AND CRD.NRDCONTA = ASS.NRDCONTA
       AND CRD.CDCOOPER = TB.CDCOOPER
       AND SUBSTR(CRD.NRCRCARD,1,6) = TB.NRCTAMAE_ANT
       AND CRD.CDADMCRD <> TB.CDADMCRD
       AND CRD.NRCRCARD > 0
       AND CRD.INSITCRD NOT IN (5,6)
       AND ASS.INPESSOA = 2
       AND TB.CDADMCRD = 17
     ORDER BY 3,5;
    /*SELECT CRD.CDCOOPER CDCOOPER
          ,CRD.NRDCONTA NRDCONTA
          ,CRD.NRCTRCRD NRCTRCRD
          ,CRD.CDADMCRD CRAWCRD_CDADMCRD
          ,TB.CDADMCRD  CDADMCRD
      FROM CRAWCRD CRD, TBCRD_GRUPO_AFINIDADE_BIN TB
     WHERE CRD.CDCOOPER = TB.CDCOOPER
       AND SUBSTR(CRD.NRCRCARD, 1, 6) = TB.NRCTAMAE_ANT
       AND CRD.CDADMCRD <> TB.CDADMCRD
       AND CRD.NRCRCARD > 0
       AND CRD.INSITCRD NOT IN (5, 6)
     ORDER BY 1,4,5;*/
      
  rw_bin  cr_bin%ROWTYPE;
   
  -- Sub procedures    

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

  vr_nmdireto  := gene0001.fn_diretorio(pr_tpdireto => 'C' 
                                       ,pr_cdcooper => 3);
  
  vr_nmdireto := vr_nmdireto || '/INC0103737';
  
  -- Primeiro criamos o diretorio da INC, dentro de um diretorio ja existente
  pc_valida_direto(pr_nmdireto => vr_nmdireto
                  ,pr_dscritic => vr_dscritic);
    
  IF TRIM(vr_dscritic) IS NOT NULL THEN
     RAISE vr_exc_erro;
  END IF;
    
  -- crapcrd
  vr_dados_rollback := NULL;
  dbms_lob.createtemporary(vr_dados_rollback, TRUE, dbms_lob.CALL);
  dbms_lob.open(vr_dados_rollback, dbms_lob.lob_readwrite);       
  gene0002.pc_escreve_xml(vr_dados_rollback, vr_texto_rollback, '-- Programa para rollback das informacoes'||chr(13), FALSE);
  gene0002.pc_escreve_xml(vr_dados_rollback, vr_texto_rollback, 'BEGIN'||chr(13), FALSE);  
  vr_nmarqbkp  := 'BKP_CDADMCRD_'||to_char(sysdate,'hh24miss')||'.sql';
                     
  FOR rw_bin IN cr_bin LOOP
      
    -- Atualiza administradora
    BEGIN
       UPDATE crawcrd
          SET cdadmcrd = rw_bin.cdadmcrd
        WHERE rowid = rw_bin.crawcrd_rowid;
       
       UPDATE crapcrd
          SET cdadmcrd = rw_bin.cdadmcrd
        WHERE rowid = rw_bin.crapcrd_rowid;
    END;                  
         
    -- Cria rollback    
    gene0002.pc_escreve_xml(vr_dados_rollback
                           ,vr_texto_rollback
                           ,'UPDATE crawcrd '    || chr(13) || 
                            '   SET cdadmcrd = ' || rw_bin.crawcrd_cdadmcrd ||chr(13) ||
                            ' WHERE rowid = '''  || rw_bin.crawcrd_rowid  || '''; ' ||chr(13) ||chr(13), FALSE);

    gene0002.pc_escreve_xml(vr_dados_rollback
                           ,vr_texto_rollback
                           ,'UPDATE crapcrd '    || chr(13) || 
                            '   SET cdadmcrd = ' || rw_bin.crapcrd_cdadmcrd ||chr(13) ||
                            ' WHERE rowid = '''  || rw_bin.crapcrd_rowid  || '''; ' ||chr(13) ||chr(13), FALSE);

  END LOOP; 

  -- Adiciona TAG de commit 
  gene0002.pc_escreve_xml(vr_dados_rollback, vr_texto_rollback, 'COMMIT;'||chr(13), FALSE);
  gene0002.pc_escreve_xml(vr_dados_rollback, vr_texto_rollback, 'END;'||chr(13), FALSE);    
  -- Fecha o arquivo          
  gene0002.pc_escreve_xml(vr_dados_rollback, vr_texto_rollback, chr(13), TRUE);      
      
  -- Grava o arquivo de rollback
  GENE0002.pc_solicita_relato_arquivo(pr_cdcooper  => vr_cdcooper                     --> Cooperativa conectada
                                       ,pr_cdprogra  => 'ATENDA'                      --> Programa chamador - utilizamos apenas um existente 
                                       ,pr_dtmvtolt  => trunc(SYSDATE)                --> Data do movimento atual
                                       ,pr_dsxml     => vr_dados_rollback             --> Arquivo XML de dados
                                       ,pr_dsarqsaid => vr_nmdireto||'/'||vr_nmarqbkp --> Path/Nome do arquivo PDF gerado
                                       ,pr_flg_impri => 'N'                           --> Chamar a impressão (Imprim.p)
                                       ,pr_flg_gerar => 'S'                           --> Gerar o arquivo na hora
                                       ,pr_flgremarq => 'N'                           --> remover arquivo apos geracao
                                       ,pr_nrcopias  => 1                             --> Número de cópias para impressão
                                       ,pr_des_erro  => vr_dscritic);                 --> Retorno de Erro
          
  IF TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;
  END IF;    
                                                       
  -- Liberando a memória alocada pro CLOB    
  dbms_lob.close(vr_dados_rollback);
  dbms_lob.freetemporary(vr_dados_rollback);
    
  -- Efetuamos a transação  
  COMMIT;
    
  
EXCEPTION
  WHEN vr_exc_erro THEN
    raise_application_error(-20111, vr_dscritic);
END;

