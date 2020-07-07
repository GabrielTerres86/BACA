PL/SQL Developer Test script 3.0
416
DECLARE
  vr_dscomando VARCHAR2(4000);
  
  vr_job_name  VARCHAR2(1000);
  
  vr_nome_baca  VARCHAR2(100);
  vr_nmarqlog   VARCHAR2(100);
  vr_nmarqbkp   VARCHAR2(100);
  vr_ind_arquiv utl_file.file_type;
  vr_ind_arqlog utl_file.file_type;
  vr_dslinha    VARCHAR2(31000);
  
  vr_nmdireto   VARCHAR2(4000);   
  vr_dscritic   VARCHAR2(4000);   
  vr_exc_erro   EXCEPTION;
  vr_qtdregist    NUMBER(25) := 0;
  vr_qtdregatl    NUMBER(25) := 0;
  vr_qtdlinhas    NUMBER(25) := 0;
  vr_split      gene0002.typ_split; 
  
  vr_cdcooper crapsnh.cdcooper%TYPE;
  vr_nrdconta crapsnh.cdcooper%TYPE;
  vr_vllimweb crapsnh.vllimweb%TYPE;
  
  vr_des_xml         CLOB;
  vr_texto_completo  VARCHAR2(32600);
    
  -- Criacao do diretorio de arquivos
  vr_typ_saida VARCHAR2(100);
  vr_des_saida VARCHAR2(1000);
  
  CURSOR cr_crapass(pr_cdcooper IN crapttl.cdcooper%TYPE
                   ,pr_nrdconta IN crapttl.nrdconta%TYPE) IS
  SELECT a.cdcooper 
        ,a.nrdconta
        ,a.inpessoa
   FROM crapass a
       ,crapsnh s 
  WHERE a.cdcooper = pr_cdcooper
    AND a.nrdconta = pr_nrdconta
    AND a.inpessoa = 1
    AND s.cdcooper = a.cdcooper
    AND s.nrdconta = a.nrdconta 
    AND s.idseqttl = 1
    AND s.tpdsenha = 1
    AND s.cdsitsnh = 1;
  rw_crapass cr_crapass%rowtype;
    
  -- Subrotina para escrever texto na variável CLOB do XML
  PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR2,
                           pr_fecha_xml IN BOOLEAN DEFAULT FALSE) IS
  BEGIN
    gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo, pr_des_dados, pr_fecha_xml);
  END;
    
  PROCEDURE pc_atualiza_registro(pr_cdcooper IN crapsnh.cdcooper%TYPE 
                                ,pr_nrdconta IN crapsnh.nrdconta%TYPE
                                ,pr_vllimweb IN crapsnh.vllimweb%TYPE
                                ,pr_dscritic   OUT crapcri.dscritic%TYPE) IS
    
    
    
    vr_exc_erro EXCEPTION;
    vr_rowid_craplgm ROWID;
    
    CURSOR cr_crapttl(pr_cdcooper IN crapttl.cdcooper%TYPE
                     ,pr_nrdconta IN crapttl.nrdconta%TYPE) IS
    SELECT t.cdcooper 
          ,t.nrdconta
          ,t.idseqttl
      FROM crapttl t
          ,crapsnh s
     WHERE t.cdcooper = pr_cdcooper
       AND t.nrdconta = pr_nrdconta
       AND s.cdcooper = t.cdcooper
       AND s.nrdconta = t.nrdconta
       AND s.idseqttl = t.idseqttl
       AND s.tpdsenha = 1
       AND s.cdsitsnh = 1; 
       
    CURSOR cr_crapsnh(pr_cdcooper IN crapttl.cdcooper%TYPE
                     ,pr_nrdconta IN crapttl.nrdconta%TYPE
                     ,pr_idseqttl IN crapsnh.idseqttl%TYPE) IS
    SELECT s.cdcooper 
          ,s.nrdconta
          ,s.idseqttl
          ,s.vllimweb
          ,s.dtlimweb
          ,s.progress_recid
      FROM crapsnh s
     WHERE s.cdcooper = pr_cdcooper
       AND s.nrdconta = pr_nrdconta
       AND s.idseqttl = pr_idseqttl
       AND s.tpdsenha = 1; 
    rw_crapsnh cr_crapsnh%ROWTYPE;
       
  BEGIN
    
     --Busca somente titulares que possuem acesso a conta on-line ativo
     FOR rw_crapttl IN cr_crapttl(pr_cdcooper => pr_cdcooper
                                 ,pr_nrdconta => pr_nrdconta) LOOP
        
         OPEN cr_crapsnh(pr_cdcooper => rw_crapttl.cdcooper 
                        ,pr_nrdconta => rw_crapttl.nrdconta
                        ,pr_idseqttl => rw_crapttl.idseqttl);
         
         FETCH cr_crapsnh INTO rw_crapsnh;
         
         IF cr_crapsnh%NOTFOUND THEN
           
           CLOSE cr_crapsnh;
           
           pr_dscritic := ' - Registro de senha nao encontrado para: ' || rw_crapttl.cdcooper || ' - ' || rw_crapttl.nrdconta || ' - ' || rw_crapttl.idseqttl || '.';
           RAISE vr_exc_erro;
           
         ELSE
           CLOSE cr_crapsnh;
         END IF;
         
         --atualiza a quantidade de registros atualizados
         vr_qtdregatl := vr_qtdregatl + 1;
                  
         --Grava no arquivo de backup
         pc_escreve_xml('UPDATE crapsnh ' || 
                           'SET crapsnh.vllimweb = '''||rw_crapsnh.vllimweb||''' ' ||
                           '   ,crapsnh.dtlimweb = '''||rw_crapsnh.dtlimweb||''' ' ||
                         'WHERE crapsnh.progress_recid = '''||rw_crapsnh.progress_recid||''';' || chr(10)); 

         IF rw_crapsnh.vllimweb = 0 THEN
           
         --Regulariza o saldo das aplicações
         BEGIN

           UPDATE crapsnh c
              SET c.vllimweb = vr_vllimweb
                 ,c.dtlimweb = trunc(SYSDATE)
                   ,c.cdopepag = '1'
                   ,c.cdagepag = 90
                   ,c.vlpagini = vr_vllimweb
                   ,c.dtinspag = trunc(SYSDATE)                    
            WHERE c.progress_recid = rw_crapsnh.progress_recid; 
          
         EXCEPTION
           WHEN OTHERS THEN
             pr_dscritic:=  'Erro ao atualizar o registro de limites ( '||rw_crapsnh.progress_recid ||' ):'|| SQLERRM;
              RAISE vr_exc_erro;
         END;
           
         ELSE 
           --Regulariza o saldo das aplicações
           BEGIN

             UPDATE crapsnh c
                SET c.vllimweb = vr_vllimweb
                   ,c.dtlimweb = trunc(SYSDATE)
              WHERE c.progress_recid = rw_crapsnh.progress_recid; 
            
           EXCEPTION
             WHEN OTHERS THEN
               pr_dscritic:=  'Erro ao atualizar o registro de limites ( '||rw_crapsnh.progress_recid ||' ):'|| SQLERRM;
                RAISE vr_exc_erro;
           END;
         
         END IF;
                  
        -- Se concluiu com sucesso 
        -- Gerar log do novo registro na CRAPLAU
        GENE0001.pc_gera_log(pr_cdcooper => rw_crapttl.cdcooper
                            ,pr_cdoperad => '1'
                            ,pr_dscritic => null
                            ,pr_dsorigem => GENE0001.vr_vet_des_origens(5)
                            ,pr_dstransa => 'Alterar limites da senha de acesso ao InternetBank'
                            ,pr_dttransa => TRUNC(SYSDATE)
                            ,pr_flgtrans => 1 --> TRUE
                            ,pr_hrtransa => gene0002.fn_busca_time
                            ,pr_idseqttl => rw_crapttl.idseqttl
                            ,pr_nmdatela => 'ATENDA'
                            ,pr_nrdconta => rw_crapttl.nrdconta
                            ,pr_nrdrowid => vr_rowid_craplgm);

        GENE0001.pc_gera_log_item
                          (pr_nrdrowid => vr_rowid_craplgm
                          ,pr_nmdcampo => 'vllimweb' 
                          ,pr_dsdadant => to_char(rw_crapsnh.vllimweb,'fm999g999g990d00') 
                          ,pr_dsdadatu => pr_vllimweb);
                                    
        GENE0001.pc_gera_log_item
                          (pr_nrdrowid => vr_rowid_craplgm
                          ,pr_nmdcampo => 'dtlimweb' 
                          ,pr_dsdadant => rw_crapsnh.dtlimweb
                          ,pr_dsdadatu => to_char(SYSDATE,'DD/MM/RRRR')); 
                          
         --Grava no arquivo de backup
         pc_escreve_xml('DELETE craplgi a ' ||                            
                         'WHERE a.rowid in (SELECT b.rowid from craplgm l, craplgi b  '   || 
                                            'WHERE l.rowid = '''||vr_rowid_craplgm||''' ' || 
                                              'AND b.cdcooper = l.cdcooper ' ||
                                              'AND b.nrdconta = l.nrdconta ' ||
                                              'AND b.idseqttl = l.idseqttl ' ||
                                              'AND b.dttransa = l.dttransa ' ||
                                              'AND b.hrtransa = l.hrtransa ' ||
                                              'AND b.nrsequen = l.nrsequen);' || chr(10)); 
        
        pc_escreve_xml('DELETE craplgm m ' ||                            
                         'WHERE m.rowid = '''||vr_rowid_craplgm||''';' || chr(10)); 
                         
        
     END LOOP;
     
     

  EXCEPTION 
    WHEN vr_exc_erro THEN
      --LOG
      gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, to_char(sysdate,'ddmmyyyy_hh24miss')||pr_dscritic);
   
    WHEN OTHERS THEN
      pr_dscritic := ' Problemas na pc_atualiza_registro - '||SQLERRM; 
      --LOG
      gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, to_char(sysdate,'ddmmyyyy_hh24miss')||pr_dscritic);
  END pc_atualiza_registro;
  
BEGIN
  
  vr_nome_baca := 'RITM0068290_ATUALIZA_VALOR_LIMITE_WEB';
  vr_nmdireto  := '/micros/cpd/bacas/RITM0068290';    
  vr_nmarqbkp  := 'ROLLBACK_RITM0068290.txt';
  vr_nmarqlog  := 'LOG_'||vr_nome_baca||'_'||to_char(sysdate,'ddmmyyyy_hh24miss')||'.txt';
      
  IF NOT gene0001.fn_exis_diretorio(vr_nmdireto) THEN
    
    -- Efetuar a criação do mesmo
    gene0001.pc_OSCommand_Shell(pr_des_comando => 'mkdir '||vr_nmdireto||' 1> /dev/null'
                               ,pr_typ_saida   => vr_typ_saida
                               ,pr_des_saida   => vr_des_saida);

    --Se ocorreu erro dar RAISE
    IF vr_typ_saida = 'ERR' THEN
      vr_dscritic := 'CRIAR DIRETORIO ARQUIVO --> Nao foi possivel criar o diretorio para gerar os arquivos. ' || vr_des_saida;  
      RAISE vr_exc_erro;
    END IF;           
    
    -- Adicionar permissão total na pasta
    gene0001.pc_OSCommand_Shell(pr_des_comando => 'chmod 777 '||vr_nmdireto||' 1> /dev/null'
                               ,pr_typ_saida   => vr_typ_saida
                               ,pr_des_saida   => vr_des_saida);

    --Se ocorreu erro dar RAISE
    IF vr_typ_saida = 'ERR' THEN
      vr_dscritic := 'PERMISSAO NO DIRETORIO --> Nao foi possivel adicionar permissao no diretorio dos arquivos. ' || vr_des_saida;
      RAISE vr_exc_erro;
    END IF;  
             
  END IF;
  
  /* ############# LOG ########################### */
  --Criar arquivo de log
  gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto        --> Diretorio do arquivo
                          ,pr_nmarquiv => vr_nmarqlog        --> Nome do arquivo
                          ,pr_tipabert => 'W'                --> modo de abertura (r,w,a)
                          ,pr_utlfileh => vr_ind_arqlog      --> handle do arquivo aberto
                          ,pr_des_erro => vr_dscritic);      --> erro
  -- em caso de crítica
  IF vr_dscritic IS NOT NULL THEN        
     RAISE vr_exc_erro;
  END IF;
    
  gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, to_char(sysdate,'ddmmyyyy_hh24miss')||' - Inicio Processo');  
  gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, to_char(sysdate,'ddmmyyyy_hh24miss')||' - Inicio pc_atualiza_registro ');
  
  
  --Abrir arquivo
  gene0001.pc_abre_arquivo ( pr_nmdireto => vr_nmdireto    --> Diretório do arquivo
                            ,pr_nmarquiv => 'contas_atualizar.csv'    --> Nome do arquivo
                            ,pr_tipabert => 'R'            --> Modo de abertura (R,W,A)
                            ,pr_utlfileh => vr_ind_arquiv  --> Handle do arquivo aberto
                            ,pr_des_erro => vr_dscritic);  --> Erro
                      
  IF vr_dscritic IS NOT NULL THEN
      --Levantar Excecao
      RAISE vr_exc_erro;
  END IF;

  -- Inicializar o CLOB para poder ser gravado os logs de backup
  vr_des_xml := NULL;
  dbms_lob.createtemporary(vr_des_xml, TRUE);
  dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
  vr_texto_completo := NULL;
         
  BEGIN
    vr_qtdlinhas := 0;
    
    LOOP
      IF utl_file.IS_OPEN(vr_ind_arquiv) THEN
          
          -- Ler linha
          gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_ind_arquiv --> Handle do arquivo aberto
                                      ,pr_des_text => vr_dslinha);  --> Texto lido
       
           vr_qtdlinhas := vr_qtdlinhas + 1; 
               
          --Desconsidera primeira linha
          IF vr_qtdlinhas = 1 THEN
             
            CONTINUE;
           
          END IF;
            
          vr_cdcooper := 0;
          vr_nrdconta := 0;
          vr_vllimweb := 0;
          
          --Quebra linha do arquivo com separador ';'
          vr_split := gene0002.fn_quebra_string(pr_string => vr_dslinha, 
                                                pr_delimit => ';'); 
            
          BEGIN 
            vr_cdcooper :=  to_number(trim(vr_split(2)));
          EXCEPTION
            WHEN OTHERS THEN
              --LOG
             gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, to_char(sysdate,'ddmmyyyy_hh24miss')||' - ERRO (1): erro ao obter a cooperativa => ' || SQLERRM);
             RAISE vr_exc_erro;
          END;
            
          BEGIN 
            vr_nrdconta :=  to_number(trim(vr_split(3)));
          EXCEPTION
            WHEN OTHERS THEN
              --LOG
             gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, to_char(sysdate,'ddmmyyyy_hh24miss')||' - ERRO (2): erro ao obter a conta => ' || SQLERRM);
             RAISE vr_exc_erro;
          END;
         
          BEGIN 
            vr_vllimweb := to_number(TRIM(upper(REPLACE(vr_split(5),CHR(13),''))));
          EXCEPTION
            WHEN OTHERS THEN
              --LOG
             gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, to_char(sysdate,'ddmmyyyy_hh24miss')||' - ERRO (3): erro ao obter o valor => ' || SQLCODE || ' - ' ||SQLERRM);
             RAISE vr_exc_erro;
          END;
    
          --Busca a conta do cooperado, considera que ele possua senha de acesso a conta on-line ativa
          OPEN cr_crapass(pr_cdcooper => vr_cdcooper 
                         ,pr_nrdconta => vr_nrdconta);
               
          FETCH cr_crapass INTO rw_crapass;
               
          IF cr_crapass%NOTFOUND THEN
                 
            CLOSE cr_crapass;
                 
            --LOG
            gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, to_char(sysdate,'ddmmyyyy_hh24miss')||' - ERRO (4): Registro de associado nao tem senha de acesso ativa: ' || vr_cdcooper || ' - ' || vr_nrdconta || '.');
            CONTINUE;
                
          ELSE
            CLOSE cr_crapass;
          END IF;
           
          --atualiza a quantidade de registos a serem verificados para atualização
          vr_qtdregist := vr_qtdregist + 1;
     
          pc_atualiza_registro(pr_cdcooper => vr_cdcooper
                              ,pr_nrdconta => vr_nrdconta
                              ,pr_vllimweb => vr_vllimweb                           
                              ,pr_dscritic => vr_dscritic);
                                   
          -- Se houve erro ao carregar o arquivo aborta
          IF vr_dscritic IS NOT NULL THEN
             --LOG
             gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, to_char(sysdate,'ddmmyyyy_hh24miss')||' - Fim pc_atualiza_registro com ERRO '||vr_dscritic);
             RAISE vr_exc_erro;
          END IF;
            
      END IF;    
    END LOOP;
   EXCEPTION
     WHEN no_data_found THEN
       -- Fechar o arquivo
       gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv); --> Handle do arquivo aberto;  
   END;
       
  --finalizado o arquivo de backup
  pc_escreve_xml('COMMIT;');
  pc_escreve_xml(' ',TRUE);
  DBMS_XSLPROCESSOR.CLOB2FILE(vr_des_xml, vr_nmdireto, to_char(sysdate,'ddmmyyyy_hh24miss')||'_'||vr_nmarqbkp, NLS_CHARSET_ID('UTF8'));
 
  -- Liberando a memória alocada pro CLOB
  dbms_lob.close(vr_des_xml);
  dbms_lob.freetemporary(vr_des_xml);
         
  --Logs finais para o arquivo de log
  gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, to_char(sysdate,'ddmmyyyy_hh24miss')||' - Quantidade de linhas no arquivo: ' || vr_qtdlinhas || '.' ); 
  gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, to_char(sysdate,'ddmmyyyy_hh24miss')||' - Quantidade de registros: ' || vr_qtdregist || '.' ); 
  gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, to_char(sysdate,'ddmmyyyy_hh24miss')||' - Quantidade de registros atualizados: ' || vr_qtdregist || '.' );
  gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, to_char(sysdate,'ddmmyyyy_hh24miss')||' - Fim Processo com sucesso');  
  gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arqlog); --> Handle do arquivo aberto;  
  
  COMMIT;
  
EXCEPTION
  WHEN vr_exc_erro THEN
    --LOG
    gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, to_char(sysdate,'ddmmyyyy_hh24miss')||' - Fim Processo com erro');  
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arqlog); --> Handle do arquivo aberto;  
     
    ROLLBACK;
  WHEN OTHERS THEN
    --LOG
    gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, to_char(sysdate,'ddmmyyyy_hh24miss')||' - Fim Processo com erro:' || SQLERRM);
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arqlog); --> Handle do arquivo aberto;  
    ROLLBACK; 
END;

0
0
