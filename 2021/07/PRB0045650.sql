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
  vr_inpessoa   crapass.inpessoa%TYPE;
  
  
  vr_exc_erro   EXCEPTION; 
  vr_dados_rollback CLOB; -- Grava update de rollback
  vr_texto_rollback VARCHAR2(32600);
  
  -- Cursores
  CURSOR cr_crapcop IS 
    SELECT c.cdcooper
          ,c.dsdircop
      FROM crapcop c
     ORDER BY cdcooper;
     
  rw_crapcop cr_crapcop%ROWTYPE;
  
  -- Cartoes vencidos
  CURSOR cr_dtvalida(pr_cdcooper crapcop.cdcooper%TYPE) IS
    SELECT c.rowid dsrowid
          ,c.*
      FROM crawcrd c
     WHERE cdcooper = pr_cdcooper
       AND insitcrd NOT IN (5,6)
       AND cdadmcrd BETWEEN 10 AND 80
       AND dtvalida < TRUNC(SYSDATE);
  
  rw_dtvalida cr_dtvalida%ROWTYPE;
    
  CURSOR cr_crawcrd(pr_cdcooper crapcop.cdcooper%TYPE) IS
    SELECT c1.nrdconta
          ,c1.nrcctitg
          ,c1.nrcrcard
          ,c1.cdadmcrd
          ,c1.rowid    dsrowid
      FROM crawcrd c1
          ,crawcrd c2
     WHERE c1.cdcooper = pr_cdcooper
       AND c1.cdcooper = c2.cdcooper
       AND c1.nrdconta = c2.nrdconta
       AND c1.nrcctitg = c2.nrcctitg
       AND c1.insitcrd = c2.insitcrd
       AND c1.cdadmcrd <> c2.cdadmcrd
       AND c1.nrctrcrd <> c2.nrctrcrd
       AND c1.insitcrd NOT IN (5,6)
       AND substr(c1.nrcrcard,1,6) = substr(c2.nrcrcard,1,6)
       AND NVL(c1.nrcrcard,0) > 0
       AND NVL(c1.nrcctitg,0) > 0
       AND c1.cdadmcrd BETWEEN 10 AND 80
     GROUP BY c1.nrdconta
             ,c1.nrcctitg
             ,c1.nrcrcard
             ,c1.cdadmcrd
             ,c1.rowid;
     
  rw_crawcrd cr_crawcrd%ROWTYPE;
  
  CURSOR cr_tbcrd_conta_cartao(pr_cdcooper crapcop.cdcooper%TYPE) IS
    SELECT crd.cdadmcrd  cdadmcrd_crawcrd
          ,tb.cdadmcrd   cdadmcrd_conta_cartao
          ,tb.rowid      dsrowid
      FROM tbcrd_conta_cartao tb
          ,crawcrd            crd
          ,(SELECT nrcctitg, MAX(dtpropos) dtpropos
              FROM crawcrd
             WHERE insitcrd NOT IN (5,6)
               AND cdcooper = pr_cdcooper
             GROUP BY nrcctitg) conta
       WHERE tb.cdcooper = pr_cdcooper
         AND tb.cdcooper = crd.cdcooper
         AND tb.nrdconta = crd.nrdconta
         AND tb.nrconta_cartao = crd.nrcctitg
         AND NVL(tb.nrconta_cartao,0) > 0
         AND crd.insitcrd NOT IN (5,6)
         AND tb.cdadmcrd <> crd.cdadmcrd
         AND crd.nrcctitg = conta.nrcctitg
         AND crd.dtpropos = conta.dtpropos;
      
  rw_tbcrd_conta_cartao  cr_tbcrd_conta_cartao%ROWTYPE;
   
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
  
  vr_nmdireto := vr_nmdireto || '/PRB0045650';
  
  -- Primeiro criamos o diretorio da INC, dentro de um diretorio ja existente
  pc_valida_direto(pr_nmdireto => vr_nmdireto
                  ,pr_dscritic => vr_dscritic);
    
  IF TRIM(vr_dscritic) IS NOT NULL THEN
     RAISE vr_exc_erro;
  END IF;
                                             
  FOR rw_crapcop IN cr_crapcop LOOP  
    
    -- dtvalida
    vr_dados_rollback := NULL;
    dbms_lob.createtemporary(vr_dados_rollback, TRUE, dbms_lob.CALL);
    dbms_lob.open(vr_dados_rollback, dbms_lob.lob_readwrite);       
    gene0002.pc_escreve_xml(vr_dados_rollback, vr_texto_rollback, '-- Programa para rollback das informacoes'||chr(13), FALSE);
    gene0002.pc_escreve_xml(vr_dados_rollback, vr_texto_rollback, 'BEGIN'||chr(13), FALSE);
    vr_cdcooper  := rw_crapcop.cdcooper;     
    vr_nmarqbkp  := 'BKP_DTVALIDA_'||upper(rw_crapcop.dsdircop)||'_'||to_char(sysdate,'hh24miss')||'.sql';
                          
    FOR rw_dtvalida IN cr_dtvalida(rw_crapcop.cdcooper) LOOP
      -- Atualiza administradora
      BEGIN
         UPDATE crawcrd
            SET insitcrd = 6
          WHERE rowid = rw_dtvalida.dsrowid;
      END;                  
         
      -- Cria rollback    
      gene0002.pc_escreve_xml(vr_dados_rollback
                             ,vr_texto_rollback
                             ,'UPDATE crawcrd ' || chr(13) || 
                              '   SET insitcrd = ' || rw_dtvalida.insitcrd || chr(13) ||
                              ' WHERE rowid = '''  || rw_dtvalida.dsrowid  || '''; ' ||chr(13)||chr(13), FALSE);
    END LOOP;
    
    -- Efetuamos a transação  
    COMMIT;

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
    
    -- crawcrd
    vr_dados_rollback := NULL;
    dbms_lob.createtemporary(vr_dados_rollback, TRUE, dbms_lob.CALL);
    dbms_lob.open(vr_dados_rollback, dbms_lob.lob_readwrite);       
    gene0002.pc_escreve_xml(vr_dados_rollback, vr_texto_rollback, '-- Programa para rollback das informacoes'||chr(13), FALSE);
    gene0002.pc_escreve_xml(vr_dados_rollback, vr_texto_rollback, 'BEGIN'||chr(13), FALSE);
    vr_cdcooper  := rw_crapcop.cdcooper;     
    vr_nmarqbkp  := 'BKP_CRAWCRD_'||upper(rw_crapcop.dsdircop)||'_'||to_char(sysdate,'hh24miss')||'.sql';
                     
    FOR rw_crawcrd IN cr_crawcrd(rw_crapcop.cdcooper) LOOP
      
      BEGIN
        SELECT cdadmcrd
          INTO vr_cdadmcrd
          FROM tbcrd_grupo_afinidade_bin
         WHERE cdcooper = rw_crapcop.cdcooper
           AND nrctamae_ant = substr(rw_crawcrd.nrcrcard,1,6)
           AND rownum = 1;
      END;
      
      IF (vr_cdadmcrd IN (16,17)) THEN
        
        SELECT inpessoa
          INTO vr_inpessoa
          FROM crapass
         WHERE cdcooper = rw_crapcop.cdcooper
           AND nrdconta = rw_crawcrd.nrdconta;
           
        IF (vr_inpessoa = 1) THEN
          vr_cdadmcrd := 16;
        ELSE
          vr_cdadmcrd := 17;
        END IF;
      END IF;
      
      IF (rw_crawcrd.cdadmcrd <> vr_cdadmcrd) THEN
        -- Atualiza administradora
        BEGIN
           UPDATE crawcrd
              SET cdadmcrd = vr_cdadmcrd
            WHERE rowid = rw_crawcrd.dsrowid;
        END;                  
           
        -- Cria rollback    
        gene0002.pc_escreve_xml(vr_dados_rollback
                               ,vr_texto_rollback
                               ,'UPDATE crawcrd ' || chr(13) || 
                                '   SET cdadmcrd = ' || rw_crawcrd.cdadmcrd || chr(13) ||
                                ' WHERE rowid = '''  || rw_crawcrd.dsrowid  || '''; ' ||chr(13)||chr(13), FALSE);
      END IF;
      
    END LOOP;
    
    -- Efetuamos a transação  
    COMMIT;

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
    
    
    -- tbcrd_conta_cartao
    vr_dados_rollback := NULL;
    dbms_lob.createtemporary(vr_dados_rollback, TRUE, dbms_lob.CALL);
    dbms_lob.open(vr_dados_rollback, dbms_lob.lob_readwrite);       
    gene0002.pc_escreve_xml(vr_dados_rollback, vr_texto_rollback, '-- Programa para rollback das informacoes'||chr(13), FALSE);
    gene0002.pc_escreve_xml(vr_dados_rollback, vr_texto_rollback, 'BEGIN'||chr(13), FALSE);
    vr_cdcooper  := rw_crapcop.cdcooper;     
    vr_nmarqbkp  := 'BKP_TBCRD_CONTA_CARTAO_'||upper(rw_crapcop.dsdircop)||'_'||to_char(sysdate,'hh24miss')||'.sql';
                     
    FOR rw_tbcrd_conta_cartao IN cr_tbcrd_conta_cartao(rw_crapcop.cdcooper) LOOP
      -- Atualiza administradora
      BEGIN
         UPDATE tbcrd_conta_cartao
            SET cdadmcrd = rw_tbcrd_conta_cartao.cdadmcrd_crawcrd
          WHERE rowid = rw_tbcrd_conta_cartao.dsrowid;
      END;                  
         
      -- Cria rollback    
      gene0002.pc_escreve_xml(vr_dados_rollback
                             ,vr_texto_rollback
                             ,'UPDATE tbcrd_conta_cartao ' || chr(13) || 
                              '   SET cdadmcrd = ' || rw_tbcrd_conta_cartao.cdadmcrd_conta_cartao || chr(13) ||
                              ' WHERE rowid = '''  || rw_tbcrd_conta_cartao.dsrowid  || '''; ' ||chr(13)||chr(13), FALSE);
    END LOOP;
    
    -- Efetuamos a transação  
    COMMIT;

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

  END LOOP; 
                               
  -- Efetuamos a transação  
  COMMIT;
  
EXCEPTION
  WHEN vr_exc_erro THEN
    raise_application_error(-20111, vr_dscritic);
END;

