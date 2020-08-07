--RITM000086044 - Desbloqueio pré-aprovado Credifoz (UPDATE NA TBCC_PARAM_PESSOA_PRODUTO E INSERT NA TBCC_HIST_PARAM_PESSOA_PROD)
DECLARE 
--Pasta com o arquivo a ser lido - pode ser em um desses caminhos
--PROD
  vr_arq_path  VARCHAR2(1000):= '/micros/cpd/bacas/RITM0086044'; --> Diretorio em PRODUÇÃO que será criado o relatorio
  --'/usr/sistemas/Consignado/ailos011/envia'; --> Diretorio no testes2 que sera criado o relatorio e para ler o arquivo contas_pa.txt 

  vr_nmarquiv  VARCHAR2(100) := 'CONTAS_PF.txt'; 
  vr_nmarqbkp  VARCHAR2(100) := 'RITM0086044_ROLLBACK_PF.sql';

  vr_hutlfile utl_file.file_type;
  vr_dstxtlid VARCHAR2(1000);
  vr_txtauxil VARCHAR2(200); -- Texto auxiliar
  
  vr_contador INTEGER := 0;
  vr_rowid ROWID;

  vr_des_xml         CLOB;
  vr_texto_completo  VARCHAR2(32600);
  
  vr_cdcooper crapass.cdcooper%TYPE;
  vr_nrdconta crapass.nrdconta%TYPE;
  vr_nrcpfcnpj_base tbcc_hist_param_pessoa_prod.nrcpfcnpj_base%TYPE;

  vr_dscritic crapcri.dscritic%TYPE;
  vr_exc_erro EXCEPTION;

  vr_qtd_linhas NUMBER := 0;
  
  --Busca CPF / CNPJ
  CURSOR cr_crapass(pr_cdcooper crapass.cdcooper%TYPE
                   ,pr_nrdconta crapass.nrdconta%TYPE) IS
    SELECT a.inpessoa, a.nrcpfcgc, a.cdcooper, a.nrdconta
      FROM crapass a
     WHERE a.cdcooper = pr_cdcooper
       AND a.nrdconta = pr_nrdconta;

  --Busca histórico de parâmetros
  CURSOR cr_pessoa1(pr_cdcooper crapass.cdcooper%TYPE
                   ,pr_nrcpfcgc tbcc_hist_param_pessoa_prod.nrcpfcnpj_base%TYPE) IS
    SELECT ROWID
      FROM tbcc_hist_param_pessoa_prod c
     WHERE c.cdcooper       = pr_cdcooper
       AND c.nrcpfcnpj_base = pr_nrcpfcgc;

  --Busca parâmetros
  CURSOR cr_pessoa2(pr_cdcooper crapass.cdcooper%TYPE
                   ,pr_nrcpfcgc tbcc_hist_param_pessoa_prod.nrcpfcnpj_base%TYPE) IS
    SELECT ROWID
      FROM tbcc_param_pessoa_produto c
     WHERE c.cdcooper       = pr_cdcooper
       AND c.nrcpfcnpj_base = pr_nrcpfcgc;



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

--dbms_output.put_line('Texto lido: '||vr_dstxtlid);
        
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
          --COOPER
          vr_txtauxil := gene0002.fn_busca_entrada(pr_postext     => 1
                                                  ,pr_dstext      => vr_dstxtlid
                                                  ,pr_delimitador => ';');
          vr_cdcooper := TO_NUMBER( REPLACE(SRCSTR => vr_txtauxil, OLDSUB => chr(13), NEWSUB => '' ) );                                                  
          --CONTA
          vr_txtauxil := gene0002.fn_busca_entrada(pr_postext     => INSTR(vr_dstxtlid, ';')+1  --busca a partir do ;
                                                  ,pr_dstext      => vr_dstxtlid
                                                  ,pr_delimitador => ';');
          vr_nrdconta := TO_NUMBER( REPLACE(SRCSTR => vr_txtauxil, OLDSUB => chr(13), NEWSUB => '' ) );                                                  
        EXCEPTION
          WHEN OTHERS THEN
            cecred.pc_internal_exception;
            vr_dscritic := 'Erro na leitura do arquivo2 linha: '||vr_contador||' --> '||vr_txtauxil;  
            dbms_output.put_line(vr_dscritic);            
            RAISE vr_exc_erro;
        END;
        
        --Procurar o CPF / CNPJ
        FOR rw_crapass IN cr_crapass(pr_cdcooper => vr_cdcooper --7 --1
                                    ,pr_nrdconta => vr_nrdconta) LOOP
          BEGIN
            --Se pessoa física
            IF rw_crapass.inpessoa = 1 THEN
               vr_nrcpfcnpj_base := rw_crapass.nrcpfcgc;
            ELSE  --Se pessoa jurídica
               IF LENGTH(rw_crapass.nrcpfcgc) = 14 THEN
                  --vr_nrcpfcnpj_base := SUBSTR(STR1 => TO_CHAR(rw_crapass.nrcpfcgc), POS => 0, LEN => 8);
                   vr_nrcpfcnpj_base := to_number( SUBSTR( TO_CHAR( lpad( rw_crapass.nrcpfcgc,14,'0' )), 0, 8) );
               ELSE
                  --vr_nrcpfcnpj_base := SUBSTR(STR1 => TO_CHAR(rw_crapass.nrcpfcgc), POS => 0, LEN => 7);   
                  vr_nrcpfcnpj_base := to_number( SUBSTR( TO_CHAR( lpad( rw_crapass.nrcpfcgc,14,'0' )), 0, 8) );          
               END IF;   
            END IF;
            
--dbms_output.put_line('cooper:'||rw_crapass.cdcooper||', nrdconta:'||vr_nrdconta||', inpessoa:'||rw_crapass.inpessoa||', nrcpfcgc:'||rw_crapass.nrcpfcgc||', nrcpfcnpj_base:'||vr_nrcpfcnpj_base);
            
            FOR rw_pessoa IN cr_pessoa2(pr_cdcooper => rw_crapass.cdcooper
                                       ,pr_nrcpfcgc => vr_nrcpfcnpj_base) LOOP
            
--dbms_output.put_line('  update TBCC_PARAM_PESSOA_PRODUTO -> rowid:'||rw_pessoa.rowid);
            
              --------------------------------
              BEGIN
                UPDATE TBCC_PARAM_PESSOA_PRODUTO
                   SET FLGLIBERA = 1
                 WHERE rowid = rw_pessoa.rowid;
              EXCEPTION
                WHEN OTHERS THEN
                  vr_dscritic := 'Problemas UPDATE TBCC_PARAM_PESSOA_PRODUTO  linha: '||vr_contador||' '|| SQLERRM;
                  dbms_output.put_line(vr_dscritic);
                  RAISE vr_exc_erro;                                   
              END;
              pc_escreve_xml('UPDATE TBCC_PARAM_PESSOA_PRODUTO  '||
                                'SET TBCC_PARAM_PESSOA_PRODUTO.flglibera = 0' ||
                             ' WHERE TBCC_PARAM_PESSOA_PRODUTO.rowid = '''||rw_pessoa.rowid||''';'||chr(10));        
            END LOOP; 

--dbms_output.put_line('  insert TBCC_HIST_PARAM_PESSOA_PROD -> coop:'||rw_crapass.cdcooper||', conta:'||rw_crapass.nrdconta||', cnpj:'||vr_nrcpfcnpj_base);
            BEGIN
              INSERT INTO tbcc_hist_param_pessoa_prod( cdcooper
                                                     , nrdconta
                                                     , tppessoa
                                                     , nrcpfcnpj_base
                                                     , dtoperac
                                                     , cdproduto
                                                     , cdoperac_produto
                                                     , flglibera
                                                     , idmotivo
                                                     , cdoperad )
                                            VALUES ( rw_crapass.cdcooper  --1
                                                   , rw_crapass.nrdconta
                                                   , rw_crapass.inpessoa
                                                   , vr_nrcpfcnpj_base
                                                   , SYSDATE --to_date('31/03/2020 16:00:00','DD/MM/YYYY HH24:MI:SS')
                                                   , 25
                                                   , 1
                                                   , 1
                                                   , 19
                                                   , 1 ) RETURNING rowid into vr_rowid;
                             
              pc_escreve_xml('delete from  tbcc_hist_param_pessoa_prod  '||
                             ' WHERE tbcc_hist_param_pessoa_prod.rowid = '''|| vr_rowid ||''';'||chr(10));        
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Problemas UPDATE TBCC_PARAM_PESSOA_PRODUTO  linha: '||vr_contador||' '|| SQLERRM;
                dbms_output.put_line(vr_dscritic);
                RAISE vr_exc_erro;
            END;
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Problemas na hora de atualizar o registro linha: '||vr_contador||' '|| SQLERRM;
              dbms_output.put_line(vr_dscritic);
              RAISE vr_exc_erro;
          END;
        END LOOP;
      END LOOP; --Fim loop arquivo
      --
      COMMIT;
      --
    EXCEPTION 
      WHEN no_data_found THEN 
        dbms_output.put_line('fechar arquivo');
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
