-- Created on 03/03/2020 by T0032613 
DECLARE

  -- Type
  TYPE typ_rec_crawcrd IS RECORD(cdcooper crawcrd.cdcooper%TYPE
                                ,nrdconta crawcrd.nrdconta%TYPE
                                ,nrctrcrd crawcrd.nrctrcrd%TYPE
                                ,insitcrd crawcrd.insitcrd%TYPE
                                ,cdadmcrd crawcrd.cdadmcrd%TYPE);
                                
  TYPE typ_tab_crawcrd IS TABLE OF typ_rec_crawcrd INDEX BY PLS_INTEGER;                             
  
  -- Local variables here
  vr_cdcooper   crapcop.cdcooper%TYPE;
  vr_nome_baca  VARCHAR2(100);
  vr_nmarqlog   VARCHAR2(100);
  vr_nmarqimp   VARCHAR2(100);
  vr_nmarqbkp   VARCHAR2(100);
  vr_nmdireto   VARCHAR2(4000); 
  vr_tab_cccrd  typ_tab_crawcrd;
  vr_dscritic   crapcri.dscritic%TYPE;
  vr_exc_erro   EXCEPTION;
  vr_dados_cc   CLOB; -- Grava informacoes no xls
  vr_texto_cc  VARCHAR2(32600);  
  vr_dados_rollback CLOB; -- Grava update de rollback
  vr_texto_rollback VARCHAR2(32600);
  
  -- Cursores
  
  CURSOR cr_crapcop IS 
    SELECT c.cdcooper
           ,c.dsdircop
      FROM crapcop c;
  rw_crapcop cr_crapcop%ROWTYPE;
  
  -- Sub procedures
  PROCEDURE pc_altera_contas_crd(pr_cdcooper      IN crapcop.cdcooper%TYPE
                                 ,pr_tab_crawcrd OUT typ_tab_crawcrd
                                 ,pr_dscritic    OUT crapcri.dscritic%TYPE) IS
  BEGIN
    DECLARE
      -- Variaveis
      vr_idx NUMBER := 1;
      vr_dscritic crapcri.dscritic%TYPE;
                                
      -- Buscar propostas inválidas
      CURSOR cr_crawcrd(pr_cdcooper crapcop.cdcooper%TYPE) IS
        SELECT w.cdcooper
               ,w.nrdconta
               ,w.cdadmcrd
               ,w.insitcrd
               ,w.dtpropos
               ,w.nrctrcrd
          FROM crawcrd w
         WHERE w.insitcrd IN (1, 2)
           AND w.nrcctitg = 0
           AND w.cdcooper = pr_cdcooper
           AND (SELECT COUNT(*)
                  FROM crawcrd inw
                 WHERE inw.cdcooper = w.cdcooper
                   AND inw.nrdconta = w.nrdconta
                   AND inw.nrcpftit = w.nrcpftit
                   AND inw.cdadmcrd = w.cdadmcrd
                   AND inw.nrcctitg > 0
                   AND inw.insitcrd = 6) > 0
         ORDER BY w.cdcooper, w.nrdconta;
      rw_crawcrd cr_crawcrd%ROWTYPE;
          
    BEGIN
      pr_tab_crawcrd.DELETE;
      vr_idx := 1;
      
      -- Alterar a proposta para cancelada e guardar a conta/numero proposta no type record
      FOR rw_crawcrd IN cr_crawcrd(pr_cdcooper) LOOP
          BEGIN            
            UPDATE crawcrd w
               SET w.insitcrd = 6
             WHERE w.cdcooper = rw_crawcrd.cdcooper
               AND w.nrdconta = rw_crawcrd.nrdconta
               AND w.nrctrcrd = rw_crawcrd.nrctrcrd;             
               
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao alterar proposta de cartao. Cooper: ' 
                          || rw_crawcrd.cdcooper || ' Conta: ' || rw_crawcrd.nrdconta || 
                          ' Proposta: ' || rw_crawcrd.nrctrcrd;
          END;
          
          pr_tab_crawcrd(vr_idx).cdcooper := rw_crawcrd.cdcooper;
          pr_tab_crawcrd(vr_idx).nrdconta := rw_crawcrd.nrdconta;
          pr_tab_crawcrd(vr_idx).nrctrcrd := rw_crawcrd.nrctrcrd;
          pr_tab_crawcrd(vr_idx).insitcrd := rw_crawcrd.insitcrd;                              
          pr_tab_crawcrd(vr_idx).cdadmcrd := rw_crawcrd.cdadmcrd;    
          
          vr_idx := vr_idx + 1;      
      END LOOP;
    
    EXCEPTION
      WHEN OTHERS THEN
        
        pr_dscritic := vr_dscritic;
        
        IF trim(pr_dscritic) IS NULL THEN
           pr_dscritic := 'Erro ao buscar as propostas invalidas: ' || SQLERRM;
        END IF;
    END;
  END pc_altera_contas_crd;      

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
 
  FOR rw_crapcop IN cr_crapcop LOOP  
    vr_dados_cc := NULL;
    vr_dados_rollback := NULL;
    
    dbms_lob.createtemporary(vr_dados_cc, TRUE, dbms_lob.CALL);
    dbms_lob.open(vr_dados_cc, dbms_lob.lob_readwrite);

    dbms_lob.createtemporary(vr_dados_rollback, TRUE, dbms_lob.CALL);
    dbms_lob.open(vr_dados_rollback, dbms_lob.lob_readwrite);    
    

    gene0002.pc_escreve_xml(vr_dados_cc, vr_texto_cc, 'Cooperativa; Conta; Nr.Proposta; Administradora; Situacao'||chr(13), FALSE);
    
    gene0002.pc_escreve_xml(vr_dados_rollback, vr_texto_rollback, '-- Programa para rollback das informacoes'||chr(13), FALSE);
    
    vr_cdcooper  := rw_crapcop.cdcooper;
    
    vr_nome_baca := 'PROPOSTAS_INVALIDAS_'||upper(rw_crapcop.dsdircop);
    vr_nmdireto  := gene0001.fn_param_sistema('CRED',vr_cdcooper,'ROOT_MICROS');
    
    -- Primeiro criamos o diretorio da RITM, dentro de um diretorio ja existente
    pc_valida_direto(pr_nmdireto => vr_nmdireto || 'bancoob/RITM0035743'
                     ,pr_dscritic => vr_dscritic);
    
    IF TRIM(vr_dscritic) IS NOT NULL THEN
       RAISE vr_exc_erro;
    END IF;   

    -- Depois criamos o diretorio da cooperativa
    pc_valida_direto(pr_nmdireto => vr_nmdireto || 'bancoob/RITM0035743/'||rw_crapcop.dsdircop
                     ,pr_dscritic => vr_dscritic);
    
    IF TRIM(vr_dscritic) IS NOT NULL THEN
       RAISE vr_exc_erro;
    END IF;       
        
    vr_nmdireto  := vr_nmdireto||'bancoob/RITM0035743/'||rw_crapcop.dsdircop; 
    vr_nmarqimp  := rw_crapcop.dsdircop||'_crd.csv';
    vr_nmarqbkp  := 'ROLLBACK_ATUALIZA_PROPOSTA_INVALIDA_'||upper(rw_crapcop.dsdircop)||'_'||to_char(sysdate,'ddmmyyyy_hh24miss')||'.sql';
    vr_nmarqlog  := 'LOG_'||vr_nome_baca||'_'||to_char(sysdate,'ddmmyyyy_hh24miss')||'.csv';  
           
    pc_altera_contas_crd(pr_cdcooper     => vr_cdcooper
                         ,pr_tab_crawcrd => vr_tab_cccrd
                         ,pr_dscritic    => vr_dscritic);            
                         
    IF TRIM(vr_dscritic) IS NOT NULL THEN
       RAISE vr_exc_erro;
    END IF;
        
    -- Percorrer todas as contas para gerar o arquivo de rollback e xls com as informações alteradas
    IF vr_tab_cccrd.count > 0 THEN
       -- Percorre as contas alteradas
       FOR idx IN vr_tab_cccrd.FIRST..vr_tab_cccrd.LAST LOOP
           -- Escreve linha CSV
           gene0002.pc_escreve_xml(vr_dados_cc, vr_texto_cc, vr_tab_cccrd(idx).cdcooper   ||';' -- Cooperativa
                          ||vr_tab_cccrd(idx).nrdconta               ||';' -- Conta
                          ||vr_tab_cccrd(idx).nrctrcrd               ||';' -- Nr. Proposta
                          ||vr_tab_cccrd(idx).cdadmcrd               ||';' -- Administradora
                          ||vr_tab_cccrd(idx).insitcrd               ||';' -- Situacao do cartao
                          ||chr(13), FALSE);  
                          
           gene0002.pc_escreve_xml(vr_dados_rollback
                                   , vr_texto_rollback
                                   , 'UPDATE crawcrd w ' || chr(13) || 
                                     '   SET w.insitcrd = ' || vr_tab_cccrd(idx).insitcrd  || chr(13) ||
                                     ' WHERE w.cdcooper = ' || vr_tab_cccrd(idx).cdcooper  || chr(13) ||
                                     '   AND w.nrdconta = ' || vr_tab_cccrd(idx).nrdconta  || chr(13) ||
                                     '   AND w.nrctrcrd = ' || vr_tab_cccrd(idx).nrctrcrd  || '; ' ||chr(13)||chr(13), FALSE);                                   

       END LOOP;
    END IF;
                
    vr_tab_cccrd.DELETE;
    
    -- Adiciona TAG de commit 
    gene0002.pc_escreve_xml(vr_dados_rollback, vr_texto_rollback, 'COMMIT;'||chr(13), FALSE);
        
    -- Fecha o arquivo          
    gene0002.pc_escreve_xml(vr_dados_cc, vr_texto_cc, chr(13), TRUE);
    gene0002.pc_escreve_xml(vr_dados_rollback, vr_texto_rollback, chr(13), TRUE);    
    
    -- Grava arquivo de contas alteradas
    GENE0002.pc_solicita_relato_arquivo(pr_cdcooper  => vr_cdcooper                   --> Cooperativa conectada
                                       ,pr_cdprogra  => 'ATENDA'                      --> Programa chamador - utilizamos apenas um existente 
                                       ,pr_dtmvtolt  => trunc(SYSDATE)                --> Data do movimento atual
                                       ,pr_dsxml     => vr_dados_cc                   --> Arquivo XML de dados
                                       ,pr_dsarqsaid => vr_nmdireto||'/'||vr_nmarqlog --> Path/Nome do arquivo PDF gerado
                                       ,pr_flg_impri => 'N'                           --> Chamar a impressão (Imprim.p)
                                       ,pr_flg_gerar => 'S'                           --> Gerar o arquivo na hora
                                       ,pr_flgremarq => 'N'                           --> remover arquivo apos geracao
                                       ,pr_nrcopias  => 1                             --> Número de cópias para impressão
                                       ,pr_des_erro  => vr_dscritic);                 --> Retorno de Erro
    
    IF TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_erro;
    END IF;
    
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
    dbms_lob.close(vr_dados_cc);
    dbms_lob.freetemporary(vr_dados_cc);    
    
    dbms_lob.close(vr_dados_rollback);
    dbms_lob.freetemporary(vr_dados_rollback);   
      
  END LOOP;  
  
  -- Efetuamos a transação  
  COMMIT;
  
EXCEPTION
  WHEN vr_exc_erro THEN
    raise_application_error(-20111, vr_dscritic);
END;