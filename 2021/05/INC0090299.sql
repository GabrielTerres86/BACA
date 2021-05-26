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
    SELECT t.*, w.nrcrcard, t.rowid
      FROM tbcrd_conta_cartao t
          ,crawcrd w 
     WHERE t.nrconta_cartao = w.nrcctitg
       and t.cdcooper = pr_cdcooper
       AND NVL(t.cdadmcrd,0) = 0; 
      
  rw_tbcrd_conta_cartao  cr_tbcrd_conta_cartao%ROWTYPE;
  
  CURSOR cr_crawcrd(pr_cdcooper crapcop.cdcooper%TYPE) IS
    SELECT c1.nrcctitg, c1.nrcrcard, c1.rowid
      FROM CRAWCRD C1
     WHERE C1.CDCOOPER = pr_cdcooper
       AND NVL(C1.CDADMCRD,0) = 0
       AND NOT EXISTS (SELECT 1
                         FROM CRAWCRD C2
                        WHERE C2.CDCOOPER  = C1.CDCOOPER
                          AND C2.NRDCONTA  = C1.NRDCONTA
                          AND C2.NRCRCARD  = C1.NRCRCARD
                          AND C2.NRCCTITG  = C1.NRCCTITG
                          AND C2.CDADMCRD <> C1.CDADMCRD);

  rw_crawcrd cr_crawcrd%ROWTYPE;
  
  CURSOR cr_crapcrd(pr_cdcooper crapcop.cdcooper%TYPE) IS
    SELECT w.nrcctitg, c1.nrcrcard, c1.rowid
      FROM CRAPCRD C1
          ,CRAWCRD W
     WHERE C1.CDCOOPER = pr_cdcooper
       AND NVL(C1.CDADMCRD,0) = 0
       AND C1.CDCOOPER = W.CDCOOPER
       AND C1.NRDCONTA = W.NRDCONTA
       AND C1.NRCRCARD = W.NRCRCARD
       AND C1.CDADMCRD = W.CDADMCRD
       AND NOT EXISTS (SELECT 1
                         FROM CRAPCRD C2
                        WHERE C2.CDCOOPER = C1.CDCOOPER
                          AND C2.NRDCONTA = C1.NRDCONTA
                          AND C2.NRCRCARD = C1.NRCRCARD
                          AND C2.CDADMCRD <> C1.CDADMCRD); 

  rw_crapcrd cr_crapcrd%ROWTYPE;
  
  CURSOR cr_cdamdcrd(pr_nrcctitg crawcrd.nrcctitg%TYPE) IS
    SELECT MAX(cdadmcrd) cdadmcrd
      FROM crawcrd
     WHERE nrcctitg = pr_nrcctitg;
  
  rw_cdamdcrd  cr_cdamdcrd%ROWTYPE;
  
  CURSOR cr_bin(pr_cdcooper crapcop.cdcooper%TYPE
               ,pr_nrctamae tbcrd_grupo_afinidade_bin.nrctamae%TYPE) IS
    SELECT *
      FROM tbcrd_grupo_afinidade_bin
     WHERE cdcooper = pr_cdcooper
       AND (nrctamae = pr_nrctamae OR nrctamae_ant = pr_nrctamae);
  rw_bin cr_bin%rowtype;
  
  CURSOR cr_tbcrd_conta_cartao_2(pr_cdcooper crapcop.cdcooper%TYPE) IS
    SELECT t.*, t.rowid
      FROM tbcrd_conta_cartao t
     WHERE t.cdcooper = pr_cdcooper
       AND NVL(t.cdadmcrd,0) = 0; 
      
  rw_tbcrd_conta_cartao_2  cr_tbcrd_conta_cartao_2%ROWTYPE;
  
  CURSOR cr_crapass(pr_cdcooper crapass.cdcooper%TYPE
                   ,pr_nrdconta crapass.NRDCONTA%TYPE) IS
    SELECT inpessoa
      FROM crapass 
     WHERE cdcooper = pr_cdcooper
       AND nrdconta = pr_nrdconta;
  rw_crapass cr_crapass%ROWTYPE;
   
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
  
  vr_nmdireto := vr_nmdireto || '/INC0090299';
  
  -- Primeiro criamos o diretorio da INC, dentro de um diretorio ja existente
  pc_valida_direto(pr_nmdireto => vr_nmdireto
                  ,pr_dscritic => vr_dscritic);
    
  IF TRIM(vr_dscritic) IS NOT NULL THEN
     RAISE vr_exc_erro;
  END IF;
                                             
  FOR rw_crapcop IN cr_crapcop LOOP  
    
    -- crapcrd
    vr_dados_rollback := NULL;
    dbms_lob.createtemporary(vr_dados_rollback, TRUE, dbms_lob.CALL);
    dbms_lob.open(vr_dados_rollback, dbms_lob.lob_readwrite);       
    gene0002.pc_escreve_xml(vr_dados_rollback, vr_texto_rollback, '-- Programa para rollback das informacoes'||chr(13), FALSE);
    gene0002.pc_escreve_xml(vr_dados_rollback, vr_texto_rollback, 'BEGIN'||chr(13), FALSE);
    vr_cdcooper  := rw_crapcop.cdcooper;     
    vr_nmarqbkp  := 'BKP_CRAPCRD_'||upper(rw_crapcop.dsdircop)||'_'||to_char(sysdate,'hh24miss')||'.sql';
                     
    FOR rw_crapcrd IN cr_crapcrd(rw_crapcop.cdcooper) LOOP
      
      OPEN  cr_cdamdcrd(rw_crapcrd.nrcctitg);
      FETCH cr_cdamdcrd
       INTO rw_cdamdcrd;
       
      IF NVL(rw_cdamdcrd.cdadmcrd,0) = 0 THEN
        open cr_bin(rw_crapcop.cdcooper, substr(rw_crapcrd.nrcrcard,1,6));
        fetch cr_bin
        into rw_bin;
      
        vr_cdadmcrd := rw_bin.cdadmcrd;
        close cr_bin;
      else
        vr_cdadmcrd := rw_cdamdcrd.cdadmcrd;
      end if;
      
      close cr_cdamdcrd;
        -- Atualiza administradora
        BEGIN
           UPDATE crapcrd
              SET cdadmcrd = vr_cdadmcrd
            WHERE rowid = rw_crapcrd.rowid;
        END;                  
         
        -- Cria rollback    
        gene0002.pc_escreve_xml(vr_dados_rollback
                               ,vr_texto_rollback
                               ,'UPDATE crapcrd '      || chr(13) || 
                                '   SET cdadmcrd = 0 ' || chr(13) ||
                                ' WHERE rowid = '''    || rw_crapcrd.rowid  || '''; ' ||chr(13)||chr(13), FALSE);

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
    
    -- crawcrd
    vr_dados_rollback := NULL;
    dbms_lob.createtemporary(vr_dados_rollback, TRUE, dbms_lob.CALL);
    dbms_lob.open(vr_dados_rollback, dbms_lob.lob_readwrite);       
    gene0002.pc_escreve_xml(vr_dados_rollback, vr_texto_rollback, '-- Programa para rollback das informacoes'||chr(13), FALSE);
    gene0002.pc_escreve_xml(vr_dados_rollback, vr_texto_rollback, 'BEGIN'||chr(13), FALSE);
    vr_cdcooper  := rw_crapcop.cdcooper;     
    vr_nmarqbkp  := 'BKP_CRAWCRD_'||upper(rw_crapcop.dsdircop)||'_'||to_char(sysdate,'hh24miss')||'.sql';
                     
    FOR rw_crawcrd IN cr_crawcrd(rw_crapcop.cdcooper) LOOP
      
      OPEN  cr_cdamdcrd(rw_crawcrd.nrcctitg);
      FETCH cr_cdamdcrd
       INTO rw_cdamdcrd;
       
      IF NVL(rw_cdamdcrd.cdadmcrd,0) = 0 THEN
        open cr_bin(rw_crapcop.cdcooper, substr(rw_crawcrd.nrcrcard,1,6));
        fetch cr_bin
        into rw_bin;
      
        vr_cdadmcrd := rw_bin.cdadmcrd;
        close cr_bin;
      else
        vr_cdadmcrd := rw_cdamdcrd.cdadmcrd;
      end if;
      
      close cr_cdamdcrd;
      
      -- Atualiza administradora
      BEGIN
         UPDATE crawcrd
            SET cdadmcrd = vr_cdadmcrd
          WHERE rowid = rw_crawcrd.rowid;
      END;                  
         
      -- Cria rollback    
      gene0002.pc_escreve_xml(vr_dados_rollback
                             ,vr_texto_rollback
                             ,'UPDATE crawcrd '      || chr(13) || 
                              '   SET cdadmcrd = 0 ' || chr(13) ||
                              ' WHERE rowid = '''    || rw_crawcrd.rowid  || '''; ' ||chr(13)||chr(13), FALSE);
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
    
    -- tbcrd_conta_cartao
    vr_dados_rollback := NULL;
    dbms_lob.createtemporary(vr_dados_rollback, TRUE, dbms_lob.CALL);
    dbms_lob.open(vr_dados_rollback, dbms_lob.lob_readwrite);       
    gene0002.pc_escreve_xml(vr_dados_rollback, vr_texto_rollback, '-- Programa para rollback das informacoes'||chr(13), FALSE);
    gene0002.pc_escreve_xml(vr_dados_rollback, vr_texto_rollback, 'BEGIN'||chr(13), FALSE);
    vr_cdcooper  := rw_crapcop.cdcooper;     
    vr_nmarqbkp  := 'BKP_TBCRD_CONTA_CARTAO_'||upper(rw_crapcop.dsdircop)||'_'||to_char(sysdate,'hh24miss')||'.sql';
                     
    FOR rw_tbcrd_conta_cartao IN cr_tbcrd_conta_cartao(rw_crapcop.cdcooper) LOOP
      
      OPEN  cr_cdamdcrd(rw_tbcrd_conta_cartao.nrconta_cartao);
      FETCH cr_cdamdcrd
       INTO rw_cdamdcrd;
       
      IF NVL(rw_cdamdcrd.cdadmcrd,0) = 0 THEN
        open cr_bin(rw_crapcop.cdcooper, substr(rw_tbcrd_conta_cartao.nrcrcard,1,6));
        fetch cr_bin
        into rw_bin;
      
        vr_cdadmcrd := rw_bin.cdadmcrd;
        close cr_bin;
      else
        vr_cdadmcrd := rw_cdamdcrd.cdadmcrd;
      end if;
        -- Atualiza administradora
        BEGIN
           UPDATE tbcrd_conta_cartao
              SET cdadmcrd = vr_cdadmcrd
            WHERE rowid = rw_tbcrd_conta_cartao.rowid;
        END;                  
         
        -- Cria rollback    
        gene0002.pc_escreve_xml(vr_dados_rollback
                               ,vr_texto_rollback
                               ,'UPDATE tbcrd_conta_cartao '      || chr(13) || 
                                '   SET cdadmcrd = 0 ' || chr(13) ||
                                ' WHERE rowid = '''    || rw_tbcrd_conta_cartao.rowid  || '''; ' ||chr(13)||chr(13), FALSE);

      CLOSE cr_cdamdcrd;
    END LOOP;
    
    -- Efetuamos a transação  
    COMMIT;
    
    FOR rw_tbcrd_conta_cartao_2 IN cr_tbcrd_conta_cartao_2(rw_crapcop.cdcooper) LOOP
      OPEN  cr_crapass(rw_tbcrd_conta_cartao_2.cdcooper, rw_tbcrd_conta_cartao_2.nrdconta);
      FETCH cr_crapass
      INTO  rw_crapass;
      
      if (rw_crapass.inpessoa = 1) then
        vr_cdadmcrd := 12;
      else
        vr_cdadmcrd := 15;
      end if;
      
      close cr_crapass;
      
      -- Atualiza administradora
      BEGIN
         UPDATE tbcrd_conta_cartao
            SET cdadmcrd = vr_cdadmcrd
          WHERE rowid = rw_tbcrd_conta_cartao_2.rowid;
      END;                  
         
      -- Cria rollback    
      gene0002.pc_escreve_xml(vr_dados_rollback
                             ,vr_texto_rollback
                             ,'UPDATE tbcrd_conta_cartao '      || chr(13) || 
                              '   SET cdadmcrd = 0 ' || chr(13) ||
                              ' WHERE rowid = '''    || rw_tbcrd_conta_cartao_2.rowid  || '''; ' ||chr(13)||chr(13), FALSE);
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

  END LOOP; 
  
  BEGIN
    DELETE CRAWCRD
     WHERE ROWID IN (SELECT ROWID
                        FROM CRAWCRD C1
                       WHERE NVL(C1.CDADMCRD,0) = 0
                         AND EXISTS (SELECT 1
                                        FROM CRAWCRD C2
                                       WHERE C2.CDCOOPER  = C1.CDCOOPER
                                         AND C2.NRDCONTA  = C1.NRDCONTA
                                         AND C2.NRCRCARD  = C1.NRCRCARD
                                         AND C2.NRCCTITG  = C1.NRCCTITG
                                         AND C2.CDADMCRD <> C1.CDADMCRD));
  EXCEPTION
    WHEN OTHERS THEN
      NULL;
  END;                                 
  -- Efetuamos a transação  
  COMMIT;
  
EXCEPTION
  WHEN vr_exc_erro THEN
    raise_application_error(-20111, vr_dscritic);
END;

