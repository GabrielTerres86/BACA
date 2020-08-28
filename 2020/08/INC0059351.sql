DECLARE
  -- Local variables here
  vr_nome_baca  VARCHAR2(100);
  vr_nmarqlog   VARCHAR2(100);
  vr_nmarqimp   VARCHAR2(100);
  vr_nmarqbkp   VARCHAR2(100);
  vr_nmdireto   VARCHAR2(4000); 
  vr_dscritic   crapcri.dscritic%TYPE;
  vr_exc_erro   EXCEPTION; 
  vr_dados_rollback CLOB; -- Grava update de rollback
  vr_texto_rollback VARCHAR2(32600);
  aux_flgprcrd crawcrd.flgprcrd%type;
  vr_pasta varchar2(100) := 'INC0059351';
  
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

  -- Primeiro criamos o diretorio da INC, dentro de um diretorio ja existente
  pc_valida_direto(pr_nmdireto => vr_nmdireto || '/'||vr_pasta
                     ,pr_dscritic => vr_dscritic);

  IF TRIM(vr_dscritic) IS NOT NULL THEN
     RAISE vr_exc_erro;
  END IF;     
  
  vr_nmdireto := vr_nmdireto || '/'||vr_pasta;
                                             
  vr_dados_rollback := NULL;

  dbms_lob.createtemporary(vr_dados_rollback, TRUE, dbms_lob.CALL);
  dbms_lob.open(vr_dados_rollback, dbms_lob.lob_readwrite);       
    
  gene0002.pc_escreve_xml(vr_dados_rollback, vr_texto_rollback, '-- Programa para rollback das informacoes'||chr(13), FALSE);
  gene0002.pc_escreve_xml(vr_dados_rollback, vr_texto_rollback, 'BEGIN'||chr(13), FALSE);
    
  vr_nmarqbkp  := 'ROLLBACK_'||to_char(sysdate,'hh24miss')||'.sql';
  
  --alterar registro
  UPDATE crawcrd
     SET nrcrcard = 0
        ,nrcctitg = 0
        ,insitcrd = 6
   WHERE cdcooper = 1
     AND nrdconta = 11387181;
  --rolback
  gene0002.pc_escreve_xml(vr_dados_rollback, vr_texto_rollback, 
                                             'UPDATE crawcrd'||chr(13)||
                                             '   SET nrcrcard = 5127070000008573'||chr(13)||
                                             '      ,nrcctitg = 7563239589029'||chr(13)||
                                             '      ,insitcrd = 2'||chr(13)||
                                             ' WHERE cdcooper = 1'||chr(13)||
                                             '   AND nrdconta = 11387181;'||chr(13), FALSE);
  
  FOR reg1 IN (SELECT a.cdcooper, a.nrdconta, a.nrconta_cartao, a.vllimite_global, a.rowid  
                FROM tbcrd_conta_cartao a
               WHERE (a.cdcooper, a.nrdconta, a.nrconta_cartao) IN ((1, 11387181, 7563239589029), (1, 3766870, 7563239509018)))                                             
  LOOP
    --rolback
    gene0002.pc_escreve_xml(vr_dados_rollback, vr_texto_rollback, 
                                             'INSERT INTO tbcrd_conta_cartao (cdcooper, nrdconta, nrconta_cartao) values'||chr(13)||
                                             '   ('||reg1.cdcooper||','||reg1.nrdconta||','||reg1.nrconta_cartao||');'||chr(13), FALSE);
    FOR reg2 IN (SELECT al.rowid, al.qtdias_atraso, to_char(al.vlsaldo_devedor,'9999999999999999999999999.99') vlsaldo_devedor
                   FROM tbcrd_alerta_atraso al
                  WHERE al.cdcooper = reg1.cdcooper
                    AND al.nrdconta = reg1.nrdconta
                    AND al.nrconta_cartao = reg1.nrconta_cartao) 
    LOOP
      --rolback
      gene0002.pc_escreve_xml(vr_dados_rollback, vr_texto_rollback, 
                                               'INSERT INTO tbcrd_alerta_atraso (cdcooper, nrdconta, nrconta_cartao, qtdias_atraso, vlsaldo_devedor) values'||chr(13)||
                                               '   ('||reg1.cdcooper||','
                                                     ||reg1.nrdconta||','
                                                     ||reg1.nrconta_cartao||','
                                                     ||reg2.qtdias_atraso||','
                                                     ||reg2.vlsaldo_devedor||');'||chr(13), FALSE);
      --excluir registro                                               
      DELETE tbcrd_alerta_atraso al 
       WHERE al.rowid = reg2.rowid; 
    END LOOP;       
    --excluir registro
    DELETE tbcrd_conta_cartao a                                                      
     WHERE a.rowid = reg1.rowid;
  END LOOP;               
          
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
