rem PL/SQL Developer Test Script

set feedback off
set autoprint off

rem Execute PL/SQL Block
-- Created on 01/10/2020 by T0032613 
DECLARE
  vr_dados_rollback CLOB; -- Grava update de rollback
  vr_texto_rollback VARCHAR2(32600); 
  vr_nmarqbkp       VARCHAR2(100);
  vr_nmdireto       VARCHAR2(4000); 
  vr_dscritic       crapcri.dscritic%TYPE;
  vr_exc_erro       EXCEPTION;
   
  CURSOR cr_crapcop IS
    SELECT c.cdcooper
      FROM crapcop c
     WHERE c.flgativo = 1
       AND c.cdcooper <> 3;
       
  -- Selecionar os cartoes sem administradoras
  CURSOR cr_cartoes(pr_cdcooper crapcop.cdcooper%TYPE) IS
    SELECT w.cdcooper
           ,w.nrdconta
           ,w.nrcrcard
           ,w.nrctrcrd
           ,SUBSTR(w.nrcrcard, 0, 6) bin
      FROM crawcrd w 
     WHERE w.cdadmcrd = 0
       AND w.cdcooper = pr_cdcooper;  
        
  -- Selecionamos a administradora pelo BIN
  CURSOR cr_administradora(pr_bin crapadc.nrctamae%TYPE) IS
    SELECT a.cdadmcrd
      FROM crapadc a
     WHERE a.nrctamae = pr_bin;
  rw_administradora cr_administradora%ROWTYPE;

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

   pc_valida_direto(pr_nmdireto => vr_nmdireto || '/PRB0043567'
                   ,pr_dscritic => vr_dscritic);
    
   IF TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;
   END IF;    
  
   vr_nmdireto := vr_nmdireto || '/PRB0043567';                                    
                                         

   vr_dados_rollback := NULL;  

   dbms_lob.createtemporary(vr_dados_rollback, TRUE, dbms_lob.CALL);
   dbms_lob.open(vr_dados_rollback, dbms_lob.lob_readwrite);       
    
   gene0002.pc_escreve_xml(vr_dados_rollback, vr_texto_rollback, '-- Programa para rollback das informacoes'||chr(13), FALSE);
   gene0002.pc_escreve_xml(vr_dados_rollback, vr_texto_rollback, 'BEGIN'||chr(13), FALSE);
    
   vr_nmarqbkp  := 'ROLLBACK_PRB0043567'||to_char(sysdate,'hh24miss')||'.sql';    
   --
   FOR coop IN cr_crapcop LOOP
     --
     FOR crd IN cr_cartoes(coop.cdcooper) LOOP
         --
         IF nvl(crd.nrcrcard,0) > 0 THEN
            
            OPEN  cr_administradora(crd.bin);
            FETCH cr_administradora INTO rw_administradora;
            CLOSE cr_administradora;
            --
            -- Atribuimos o cod da administradora ao cartao
            IF nvl(rw_administradora.cdadmcrd, 0) > 0 THEN
               BEGIN
                 UPDATE crawcrd 
                    SET cdadmcrd = rw_administradora.cdadmcrd
                  WHERE cdcooper = crd.cdcooper
                    AND nrdconta = crd.nrdconta
                    AND nrctrcrd = crd.nrctrcrd;
               END;
               --rolback
               gene0002.pc_escreve_xml(vr_dados_rollback, vr_texto_rollback, 
                                                         'UPDATE crawcrd      ' || chr(13)      ||
                                                         '   SET cdadmcrd = 0 ' || chr(13)      ||
                                                         ' WHERE cdcooper =   ' || crd.cdcooper || chr(13) ||
                                                         '   AND nrdconta =   ' || crd.nrdconta || chr(13) ||
                                                         '   AND nrctrcrd =   ' || crd.nrctrcrd || ';'     ||chr(13), FALSE);               
            END IF;
            
         END IF;
         --
     END LOOP;
     --
   END LOOP;
   --

   -- Adiciona TAG de commit 
   gene0002.pc_escreve_xml(vr_dados_rollback, vr_texto_rollback, 'COMMIT;'||chr(13), FALSE);
   gene0002.pc_escreve_xml(vr_dados_rollback, vr_texto_rollback, 'END;'||chr(13), FALSE);    
    
   -- Fecha o arquivo          
   gene0002.pc_escreve_xml(vr_dados_rollback, vr_texto_rollback, chr(13), TRUE);      
    
   -- Grava o arquivo de rollback
   GENE0002.pc_solicita_relato_arquivo(pr_cdcooper  => 3                               --> Cooperativa conectada
                                       ,pr_cdprogra  => 'ATENDA'                      --> Programa chamador - utilizamos apenas um existente 
                                       ,pr_dtmvtolt  => trunc(SYSDATE)                --> Data do movimento atual
                                       ,pr_dsxml     => vr_dados_rollback             --> Arquivo XML de dados
                                       ,pr_dsarqsaid => vr_nmdireto||'/'||vr_nmarqbkp --> Path/Nome do arquivo PDF gerado
                                       ,pr_flg_impri => 'N'                           --> Chamar a impressão (Imprim.p)
                                       ,pr_flg_gerar => 'S'                           --> Gerar o arquivo na hora
                                       ,pr_flgremarq => 'N'                           --> remover arquivo apos geracao
                                       ,pr_nrcopias  => 1                             --> Número de cópias para impressão
                                       ,pr_des_erro  => vr_dscritic);                 --> Retorno de Erro
                                                  
   -- Liberando a memória alocada pro CLOB    
   dbms_lob.close(vr_dados_rollback);
   dbms_lob.freetemporary(vr_dados_rollback);   
  
   -- Efetuamos a transação  
   COMMIT;   
END;
/
