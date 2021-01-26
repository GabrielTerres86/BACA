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
  
  -- Cursores
  CURSOR cr_crapcop IS 
    SELECT c.cdcooper
           ,c.dsdircop
      FROM crapcop c;
     
  rw_crapcop cr_crapcop%ROWTYPE;
  
  CURSOR cr_tbcrd_conta_cartao(pr_cdcooper crapcop.cdcooper%TYPE) IS
    SELECT *
      FROM tbcrd_conta_cartao
     WHERE cdcooper = pr_cdcooper; 
      
  rw_tbcrd_conta_cartao  cr_tbcrd_conta_cartao%ROWTYPE;
  
  CURSOR cr_crawcrd(pr_cdcooper crapcop.cdcooper%TYPE) IS
    SELECT crd.cdcooper
          ,crd.nrdconta
          ,crd.nrcctitg
          ,crd.cdadmcrd
          ,MAX(crd.dtpropos)
      FROM crapass ass
          ,crawcrd crd
     WHERE ass.cdcooper = crd.cdcooper
       AND ass.nrdconta = crd.nrdconta
       AND ass.cdsitdct = 1
       AND ass.cdcooper = pr_cdcooper
       AND crd.insitcrd in (0,1,2,3,4,8,9,10)
       AND NVL(crd.cdadmcrd,0) > 0
       AND NVL(crd.nrcctitg,0) > 0
       AND NOT EXISTS (SELECT 1
                         FROM tbcrd_conta_cartao tcc
                        WHERE tcc.cdcooper = crd.cdcooper
                          AND tcc.nrdconta = crd.nrdconta
                          AND tcc.nrconta_cartao = crd.nrcctitg)
     GROUP BY crd.cdcooper
             ,crd.nrdconta
             ,crd.nrcctitg
             ,crd.cdadmcrd;
  
  rw_crawcrd  cr_crawcrd%ROWTYPE;
   
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

          -- Efetuar a cria��o do mesmo
          gene0001.pc_OSCommand_Shell(pr_des_comando => 'mkdir ' || pr_nmdireto || ' 1> /dev/null'
                                      ,pr_typ_saida  => vr_typ_saida
                                      ,pr_des_saida  => vr_des_saida);

          --Se ocorreu erro dar RAISE
          IF vr_typ_saida = 'ERR' THEN
             vr_dscritic := 'CRIAR DIRETORIO ARQUIVO --> Nao foi possivel criar o diretorio para gerar os arquivos. ' || vr_des_saida;
             RAISE vr_exc_erro;
          END IF;

          -- Adicionar permiss�o total na pasta
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
  
  vr_nmdireto := vr_nmdireto || '/RITM0089276';
  
  -- Primeiro criamos o diretorio da INC, dentro de um diretorio ja existente
  pc_valida_direto(pr_nmdireto => vr_nmdireto
                  ,pr_dscritic => vr_dscritic);
    
  IF TRIM(vr_dscritic) IS NOT NULL THEN
     RAISE vr_exc_erro;
  END IF;
                                             
  FOR rw_crapcop IN cr_crapcop LOOP  
    vr_dados_rollback := NULL;

    dbms_lob.createtemporary(vr_dados_rollback, TRUE, dbms_lob.CALL);
    dbms_lob.open(vr_dados_rollback, dbms_lob.lob_readwrite);       
    
    gene0002.pc_escreve_xml(vr_dados_rollback, vr_texto_rollback, '-- Programa para rollback das informacoes'||chr(13), FALSE);
    gene0002.pc_escreve_xml(vr_dados_rollback, vr_texto_rollback, 'BEGIN'||chr(13), FALSE);
    
    vr_cdcooper  := rw_crapcop.cdcooper;     
    
    vr_nmarqbkp  := 'BKP_'||upper(rw_crapcop.dsdircop)||''||to_char(sysdate,'hh24miss')||'.sql';
                   
    -- Percorrer todas as contas para gerar o arquivo de rollback
    FOR rw_tbcrd_conta_cartao IN cr_tbcrd_conta_cartao(vr_cdcooper) LOOP
      BEGIN
        SELECT cdadmcrd
              ,MAX(dtpropos)
          INTO vr_cdadmcrd
              ,vr_dtpropos
          FROM crawcrd
         WHERE cdcooper = rw_tbcrd_conta_cartao.cdcooper
           AND nrdconta = rw_tbcrd_conta_cartao.nrdconta
           AND nrcctitg = rw_tbcrd_conta_cartao.nrconta_cartao
           AND insitcrd IN (0,1,2,3,4,8,9,10)
           AND NVL(cdadmcrd,0) > 0
         GROUP BY cdadmcrd;
      EXCEPTION
        WHEN OTHERS THEN
          vr_cdadmcrd := 0;
      END;
          
      IF NVL(vr_cdadmcrd,0) > 0 THEN
        -- Atualiza administradora
         BEGIN
            UPDATE tbcrd_conta_cartao
               SET cdadmcrd = vr_cdadmcrd
             WHERE cdcooper       = rw_tbcrd_conta_cartao.cdcooper
               AND nrdconta       = rw_tbcrd_conta_cartao.nrdconta
               AND nrconta_cartao = rw_tbcrd_conta_cartao.nrconta_cartao;
         END;                  
         
         -- Cria rollback    
         gene0002.pc_escreve_xml(vr_dados_rollback
                                ,vr_texto_rollback
                                ,'UPDATE tbcrd_conta_cartao ' || chr(13) || 
                                 '   SET cdadmcrd = NULL '    || chr(13) ||
                                 ' WHERE cdcooper = ' || rw_tbcrd_conta_cartao.cdcooper  || chr(13) ||
                                 '   AND nrdconta = ' || rw_tbcrd_conta_cartao.nrdconta  || chr(13) ||
                                 '   AND nrconta_cartao = ' || rw_tbcrd_conta_cartao.nrconta_cartao  || '; ' ||chr(13)||chr(13), FALSE);
      END IF; 
    END LOOP; 
      
    FOR rw_crawcrd IN cr_crawcrd(vr_cdcooper) LOOP
      -- Insere conta cart�o
      BEGIN
        INSERT INTO tbcrd_conta_cartao
                   (cdcooper
                   ,nrdconta
                   ,nrconta_cartao
                   ,cdadmcrd)
            VALUES (rw_crawcrd.cdcooper
                   ,rw_crawcrd.nrdconta
                   ,rw_crawcrd.nrcctitg
                   ,rw_crawcrd.cdadmcrd);
      EXCEPTION
        WHEN OTHERS THEN
          CONTINUE;
      END;
        
      -- Cria rollback    
       gene0002.pc_escreve_xml(vr_dados_rollback
                              ,vr_texto_rollback
                              ,'DELETE tbcrd_conta_cartao ' || chr(13) || 
                               ' WHERE cdcooper = ' || rw_crawcrd.cdcooper  || chr(13) ||
                               '   AND nrdconta = ' || rw_crawcrd.nrdconta  || chr(13) ||
                               '   AND nrconta_cartao = ' || rw_crawcrd.nrcctitg  || '; ' ||chr(13)||chr(13), FALSE);
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
                                         ,pr_flg_impri => 'N'                           --> Chamar a impress�o (Imprim.p)
                                         ,pr_flg_gerar => 'S'                           --> Gerar o arquivo na hora
                                         ,pr_flgremarq => 'N'                           --> remover arquivo apos geracao
                                         ,pr_nrcopias  => 1                             --> N�mero de c�pias para impress�o
                                         ,pr_des_erro  => vr_dscritic);                 --> Retorno de Erro
        
    IF TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_erro;
    END IF;    
                                                     
    -- Liberando a mem�ria alocada pro CLOB    
    dbms_lob.close(vr_dados_rollback);
    dbms_lob.freetemporary(vr_dados_rollback);   
      
  END LOOP;  
  
  -- Efetuamos a transa��o  
  COMMIT;
  
EXCEPTION
  WHEN vr_exc_erro THEN
    raise_application_error(-20111, vr_dscritic);
END;

