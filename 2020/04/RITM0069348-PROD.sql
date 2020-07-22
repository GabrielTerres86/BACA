--RITM0069348 - Ana - 27/04/2020
DECLARE 
--Pasta com o arquivo a ser lido - pode ser em um desses caminhos
--PROD
  vr_arq_path  VARCHAR2(1000):= '/micros/cpd/bacas/RITM0069348'; --> Diretorio que sera criado o relatorio  --\\pkgprod\micros\cpd\bacas\RITM0069348

--DEV1
--vr_arq_path  VARCHAR2(1000):= '/microsd1/cpd/bacas/RITM0069348'; --> Diretorio que sera criado o relatorio  --\\pkgdesen1\micros\cpd\bacas\RITM0069348


  vr_nmarquiv  VARCHAR2(100) := 'contas.txt';
  vr_nmarqbkp  VARCHAR2(100) := 'RITM0069348_ROLLBACK.sql';

  vr_hutlfile utl_file.file_type;
  vr_dstxtlid VARCHAR2(1000);
  vr_txtauxil VARCHAR2(200); -- Texto auxiliar
  
  vr_contador INTEGER := 0;
  vr_rowid ROWID;

  vr_des_xml         CLOB;
  vr_texto_completo  VARCHAR2(32600);
  
  vr_cdcooper  crapass.cdcooper%TYPE;
  vr_nrdconta  crapass.nrdconta%TYPE;
  vr_nrctrlim  craplim.nrctrlim%TYPE;
  vr_cddlinha_nova craplim.cddlinha%TYPE;
  vr_cddlinha_atual craplim.cddlinha%TYPE;

  vr_nrdconta2 VARCHAR2(100);
  
  vr_dscritic crapcri.dscritic%TYPE;
  vr_exc_erro EXCEPTION;

  vr_qtd_linhas NUMBER := 0;
  
  --Valida contrato de limite
  CURSOR cr_craplim (pr_cdcooper crapass.cdcooper%TYPE
                    ,pr_nrdconta crapass.nrdconta%TYPE
                    ,pr_nrctrlim craplim.nrctrlim%TYPE
                    ,pr_cddlinha craplim.cddlinha%TYPE) IS
    SELECT a.nrdconta, a.nrctrlim, a.cddlinha, a.rowid
      FROM craplim a 
     WHERE a.cdcooper = pr_cdcooper
       AND a.nrdconta = pr_nrdconta
       AND a.nrctrlim = pr_nrctrlim
       AND a.cddlinha = pr_cddlinha;


  PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR2,
                           pr_fecha_xml IN BOOLEAN DEFAULT FALSE) IS
  BEGIN
    gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo, pr_des_dados, pr_fecha_xml);
  END;

BEGIN 

  -- Inicializar o CLOB
  vr_des_xml := NULL;
  dbms_lob.createtemporary(vr_des_xml, TRUE);
  dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
  vr_texto_completo := NULL;
  
  -- Efetuar abertura do arquivo para processamento
  gene0001.pc_abre_arquivo(pr_nmdireto => vr_arq_path   --> Diretorio do arquivo
                          ,pr_nmarquiv => vr_nmarquiv   --> Nome do arquivo
                          ,pr_tipabert => 'R'           --> Modo de abertura (R,W,A)
                          ,pr_utlfileh => vr_hutlfile   --> Handle do arquivo aberto
                          ,pr_des_erro => vr_dscritic); --> Erro
                          
  IF vr_dscritic IS NOT NULL THEN
    --Levantar Excecao
    vr_dscritic := 'Erro na leitura do arquivo --> '||vr_dscritic;
    dbms_output.put_line(vr_dscritic);
    RAISE vr_exc_erro;
  END IF;  
  
  --Verifica se o arquivo esta aberto
  IF utl_file.IS_OPEN(vr_hutlfile) THEN
    BEGIN   
      -- Laço para efetuar leitura de todas as linhas do arquivo 
      LOOP  
        -- Leitura da linha x
        gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_hutlfile --> Handle do arquivo aberto
                                    ,pr_des_text => vr_dstxtlid); --> Texto lido

--dbms_output.put_line('Texto lido: vr_dstxtlid:'||vr_dstxtlid);
        
        vr_contador   := vr_contador + 1;
        vr_qtd_linhas := vr_qtd_linhas + 1;

        --Se for primeira linha desconsiderar pois é o cabeçalho
    /*    IF vr_contador = 1 THEN
           continue;
        END IF; */
            
        -- Ignorar linhas vazias
        IF length(vr_dstxtlid) <= 3 THEN 
          continue;
        END IF;

        -- Efetuar leitura do operador
        BEGIN
          --CONTA
          vr_txtauxil := gene0002.fn_busca_entrada(pr_postext     => 1
                                                  ,pr_dstext      => vr_dstxtlid
                                                  ,pr_delimitador => ';');


--dbms_output.put_line('Texto auxiliar 1 -> vr_txtauxil:'||trim(vr_txtauxil));

          vr_nrdconta := trim(TO_NUMBER( REPLACE(SRCSTR => vr_txtauxil, OLDSUB => chr(13), NEWSUB => '' ) ));                                                  

          --CONTRATO
          vr_txtauxil := gene0002.fn_busca_entrada(pr_postext     => 2 --INSTR(vr_dstxtlid, ';')+1  --busca a partir do ;
                                                  ,pr_dstext      => vr_dstxtlid
                                                  ,pr_delimitador => ';');

          vr_nrctrlim := trim(TO_NUMBER( REPLACE(SRCSTR => vr_txtauxil, OLDSUB => chr(13), NEWSUB => '' ) ));                                                  

          --CDDLINHA_NOVA
          vr_txtauxil := gene0002.fn_busca_entrada(pr_postext     => 3 --INSTR(vr_dstxtlid, ';')+2  --busca a partir do ;
                                                  ,pr_dstext      => vr_dstxtlid
                                                  ,pr_delimitador => ';');

          vr_cddlinha_atual := trim(TO_NUMBER( REPLACE(SRCSTR => vr_txtauxil, OLDSUB => chr(13), NEWSUB => '' ) ));                                                  

          --CDDLINHA_ATUAL
          vr_txtauxil := gene0002.fn_busca_entrada(pr_postext     => 4 --INSTR(vr_dstxtlid, ';')+3  --busca a partir do ;
                                                  ,pr_dstext      => vr_dstxtlid
                                                  ,pr_delimitador => ';');

          vr_cddlinha_nova := trim(TO_NUMBER( REPLACE(SRCSTR => vr_txtauxil, OLDSUB => chr(13), NEWSUB => '' ) ));

--dbms_output.put_line('vr_nrdconta:'||vr_nrdconta||', vr_nrctrlim:'||vr_nrctrlim||', vr_cddlinha_nova:'||vr_cddlinha_nova||', vr_cddlinha_atual:'||vr_cddlinha_atual);

        EXCEPTION
          WHEN OTHERS THEN
            cecred.pc_internal_exception;
            vr_dscritic := 'Erro na leitura do arquivo2 linha: '||vr_contador||' --> '||vr_txtauxil||', erro:'||SQLERRM;  
            dbms_output.put_line(vr_dscritic);            
            RAISE vr_exc_erro;
        END;
        
        --Procurar o CPF / CNPJ
        FOR rw_craplim IN cr_craplim(pr_cdcooper => 1
                                    ,pr_nrdconta => vr_nrdconta
                                    ,pr_nrctrlim => vr_nrctrlim
                                    ,pr_cddlinha => vr_cddlinha_atual) LOOP
                                    

          BEGIN
            --------------------------------
            UPDATE craplim
               SET cddlinha = vr_cddlinha_nova
             WHERE rowid = rw_craplim.rowid;

              pc_escreve_xml('UPDATE craplim  '||
                                'SET cddlinha = ' ||vr_cddlinha_atual||
                             ' WHERE craplim.rowid = '''||rw_craplim.rowid||''';'||chr(10));        
      

--dbms_output.put_line('  UPDATE craplim -> nova:'||vr_cddlinha_atual||', rw_craplim.rowid:'||rw_craplim.rowid);
                           
                                                      
          EXCEPTION
               WHEN OTHERS THEN
                 vr_dscritic := 'Problemas na hora de atualizar o registro linha: '||vr_contador||' '|| SQLERRM;
                 dbms_output.put_line(vr_dscritic);
                 RAISE vr_exc_erro;
          END;                                    

       END LOOP;

      END LOOP; --Fim loop arquivo

      COMMIT;
    EXCEPTION 
      WHEN no_data_found THEN 
        -- fechar arquivo
        gene0001.pc_fecha_arquivo(pr_utlfileh => vr_hutlfile);
        
        pc_escreve_xml('COMMIT;');
        pc_escreve_xml(' ',TRUE);
        DBMS_XSLPROCESSOR.CLOB2FILE(vr_des_xml, vr_arq_path, to_char(sysdate,'ddmmyyyy_hh24miss')||'_'||vr_nmarqbkp, NLS_CHARSET_ID('UTF8'));
        -- Liberando a memória alocada pro CLOB
        dbms_lob.close(vr_des_xml);
        dbms_lob.freetemporary(vr_des_xml);
      WHEN OTHERS THEN
        cecred.pc_internal_exception;
    END;
  END IF;  
  
  COMMIT;
  dbms_output.put_line('Qtd_linhas:'||vr_qtd_linhas);

EXCEPTION
  WHEN vr_exc_erro THEN
    ROLLBACK;
  WHEN OTHERS THEN
    cecred.pc_internal_exception;
    ROLLBACK;
END;            
/


