PL/SQL Developer Test script 3.0
432
-- Created on 13/02/2017 by F0030367 
-- .........................................................................
--
--  Programa : BACA
--  Sistema  : Cred
--  Autor    : Lucas Ranghetti
--  Data     : Fevereiro/2017.                   Ultima atualizacao: --/--/----
--
--  Dados referentes ao programa: Chamado 601475
--
--   Frequencia: Sempre que for chamado
--   Objetivo  : 
-------------------------------------------------------------------------------

DECLARE                             

  TYPE typ_rec_contaitg IS RECORD(cdagenci crapass.cdagenci%TYPE
                                 ,nrdconta crapass.nrdconta%TYPE
                                 ,nrcpfcgc crapass.nrcpfcgc%TYPE
                                 ,nmprimtl crapass.nmprimtl%TYPE
                                 ,nrdctitg crapass.nrdctitg%TYPE);
                               
  TYPE typ_tab_contaitg IS TABLE OF typ_rec_contaitg INDEX BY PLS_INTEGER;

  vr_nrregres   INTEGER;
  vr_nome_baca  VARCHAR2(100);
  vr_nmarqlog   VARCHAR2(100);
  vr_nmarqimp   VARCHAR2(100);
  vr_nmarqbkp   VARCHAR2(100);
  vr_ind_arquiv utl_file.file_type;
  vr_ind_arqlog utl_file.file_type;
  vr_dslinha    VARCHAR2(4000);              
  vr_tab_contaitg typ_tab_contaitg;
  vr_nmdireto   VARCHAR2(4000);   
  vr_dscritic   VARCHAR2(4000);   
  vr_exc_erro   EXCEPTION;
  vr_cdcooper  INTEGER;
  vr_nrdctitg  VARCHAR2(20);
  vr_nrdctitg2 VARCHAR2(20);
  
  -- Colocar as cooperativas que deseja buscar os arquivos
  CURSOR cr_crapcop IS
  SELECT cop.dsdircop
        ,cop.cdcooper 
    FROM crapcop cop 
   WHERE cop.flgativo = 1
     AND cop.cdcooper IN(13); --scrcred

  PROCEDURE pc_carrega_contaitg( pr_dsdireto IN VARCHAR2 -- Diretorio onde esta o arquivo (/usr/coop/sistema)
                                ,pr_nmarquiv IN VARCHAR2 -- Nome do arquivo (arquivo.txt)
                                ,pr_pprlinha IN INTEGER  -- Pula primeira linha (0-nao, 1-sim)
                                ,pr_tab_contaitg OUT typ_tab_contaitg
                                ,pr_dscritic OUT crapcri.dscritic%TYPE) IS
  
    vr_dsdireto   VARCHAR2(4000);           --> Descrição do diretorio onde o arquivo se enconta
    vr_nmarquiv   VARCHAR2(100);            --> Nome do arquivo a ser importado
    vr_dscritic   VARCHAR2(4000);           --> Retorna critica Caso ocorra    
    vr_split      gene0002.typ_split; 
        
    vr_contlin    NUMBER := 0;

    vr_excerror   EXCEPTION;
  
  BEGIN  
    
    --apaga temp-table
    pr_tab_contaitg.DELETE;
  
    IF NOT GENE0001.fn_exis_arquivo(pr_caminho => pr_dsdireto||'/'||pr_nmarquiv) THEN
      -- Retorno de erro
      vr_dscritic := 'Erro no upload do arquivo: '||REPLACE(vr_dsdireto,'/','-')||'-'||pr_nmarquiv;
      RAISE vr_excerror;
    END IF;    
    
    --Abrir arquivo
    gene0001.pc_abre_arquivo ( pr_nmdireto => pr_dsdireto    --> Diretório do arquivo
                              ,pr_nmarquiv => pr_nmarquiv    --> Nome do arquivo
                              ,pr_tipabert => 'R'            --> Modo de abertura (R,W,A)
                              ,pr_utlfileh => vr_ind_arquiv  --> Handle do arquivo aberto
                              ,pr_des_erro => vr_dscritic);  --> Erro
                      
    IF vr_dscritic IS NOT NULL THEN
        --Levantar Excecao
        RAISE vr_excerror;
    END IF;

    BEGIN
      vr_contlin := 0;
      LOOP
        IF utl_file.IS_OPEN(vr_ind_arquiv) THEN
             
            -- incrementar contador da linha
            vr_contlin := vr_contlin + 1;
                                                   
            -- Ler linha
            gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_ind_arquiv --> Handle do arquivo aberto
                                        ,pr_des_text => vr_dslinha);  --> Texto lido
        
            --Desconsidera primeira linha
            IF vr_contlin = 1 AND pr_pprlinha = 1 THEN
              CONTINUE;
            END IF;
            
            --Quebra linha do arquivo com separador ';'
            vr_split := gene0002.fn_quebra_string(pr_string => vr_dslinha, 
                                                  pr_delimit => ';'); 
            
            --alimenta temptable com o seguinte layout
            --PA;Conta;CPF/CNPJ;Nome;Conta integração
            BEGIN 
              pr_tab_contaitg(vr_contlin).cdagenci := substr(trim(vr_split(1)),1,3);
            EXCEPTION
              WHEN OTHERS THEN
                pr_tab_contaitg(vr_contlin).cdagenci := substr(trim(vr_split(1)),1,2);
            END;
            pr_tab_contaitg(vr_contlin).nrdconta := to_number(vr_split(2));
            pr_tab_contaitg(vr_contlin).nrcpfcgc := to_number(vr_split(3));
            pr_tab_contaitg(vr_contlin).nmprimtl := substr(vr_split(4),1,60);
            pr_tab_contaitg(vr_contlin).nrdctitg := substr(trim(vr_split(5)),1,8); 
            
        END IF;    
      END LOOP;
     EXCEPTION
       WHEN no_data_found THEN
         -- Fechar o arquivo
         gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv); --> Handle do arquivo aberto;  
     END;
  EXCEPTION 
    WHEN vr_excerror THEN
      pr_dscritic := ' Problemas na pc_carrega_contaitg - '||vr_dscritic;
      --LOG
      gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, to_char(sysdate,'ddmmyyyy_hh24miss')||pr_dscritic);
    WHEN OTHERS THEN
      pr_dscritic := ' Problemas na pc_carrega_contaitg - '||SQLERRM;
      --LOG
      gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, to_char(sysdate,'ddmmyyyy_hh24miss')||pr_dscritic);
  END pc_carrega_contaitg;

  PROCEDURE pc_atualiza_contaitg( pr_dsdireto   IN VARCHAR2 --Diretorio onde vaii gravar o backup
                                 ,pr_nmarqbkp   IN VARCHAR2 -- Arquivo de bkp que deleta as opcoes criadas
                                 ,pr_tab_contaitg IN typ_tab_contaitg
                                 ,pr_dscritic   OUT crapcri.dscritic%TYPE) IS
    
    vr_ind   INTEGER;
    vr_rowid ROWID;
    vr_des_xml         CLOB;
    vr_texto_completo  VARCHAR2(32600);
    vr_exc_fim EXCEPTION;
    
    vr_cdsitdct INTEGER;
    vr_cdtipcta INTEGER;
    vr_nmdcampo VARCHAR2(100);
    vr_crapalt_insere BOOLEAN;
    
   CURSOR cr_crapass(pr_nrdconta crapass.nrdconta%TYPE) IS
      SELECT s.progress_recid
            ,s.cdsitdct
            ,s.cdtipcta
            ,s.flgctitg
            ,s.nrdctitg
        FROM crapass s
       WHERE s.cdcooper = vr_cdcooper
         AND s.nrdconta = pr_nrdconta;
    rw_crapass cr_crapass%ROWTYPE;
    
    CURSOR cr_crapalt (pr_nrdconta crapass.nrdconta%TYPE,
                       pr_dtmvtolt crapdat.dtmvtolt%TYPE) IS
       SELECT flgctitg 
             ,cdoperad
             ,tpaltera
             ,dsaltera
             ,ROWID
         FROM crapalt
        WHERE crapalt.cdcooper = vr_cdcooper
          AND crapalt.nrdconta = pr_nrdconta
          AND crapalt.dtaltera = pr_dtmvtolt;
     rw_crapalt cr_crapalt%ROWTYPE;

    -- Subrotina para escrever texto na variável CLOB do XML
    PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR2
                            ,pr_fecha_xml IN BOOLEAN DEFAULT FALSE) IS
    BEGIN
      gene0002.pc_escreve_xml(vr_des_xml
                             ,vr_texto_completo
                             ,pr_des_dados
                             ,pr_fecha_xml);
    END;

  BEGIN
    
     -- Inicializar o CLOB
     vr_des_xml := NULL;
     dbms_lob.createtemporary(vr_des_xml, TRUE);
     dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
     vr_texto_completo := NULL;  
  
     --loop na temptable com as novas permissoes
     FOR vr_ind IN pr_tab_contaitg.FIRST..pr_tab_contaitg.LAST LOOP
     
        -- Verifica se o operador existe
        OPEN cr_crapass(pr_nrdconta => pr_tab_contaitg(vr_ind).nrdconta);        
        FETCH cr_crapass INTO rw_crapass;
        
        IF cr_crapass%NOTFOUND THEN     
          CLOSE cr_crapass;           
          continue;                
        ELSE         
          CLOSE cr_crapass;           
          
          -- Como no arquivo foi enviado sem zeros a frente da conta itg, vamos verificar como numero
          -- antes de verificar como texto
          BEGIN     
            vr_nrdctitg:= to_number(rw_crapass.nrdctitg);
            vr_nrdctitg2:= to_number(REPLACE(REPLACE(pr_tab_contaitg(vr_ind).nrdctitg,chr(13),''),chr(10),''));
          EXCEPTION
            WHEN OTHERS THEN
              vr_nrdctitg:= TRIM(rw_crapass.nrdctitg);
              vr_nrdctitg2:= REPLACE(REPLACE(pr_tab_contaitg(vr_ind).nrdctitg,chr(13),''),chr(10),'');
          END;
          
          IF vr_nrdctitg <> vr_nrdctitg2 THEN
             continue;
          END IF;
          
          -- Verificar se existe crapalt para a conta
          OPEN cr_crapalt(pr_nrdconta => pr_tab_contaitg(vr_ind).nrdconta,
                          pr_dtmvtolt => to_char(SYSDATE,'dd/mm/rrrr'));
          FETCH cr_crapalt INTO rw_crapalt;
          
          -- Se nao existir vamos inserir
          IF cr_crapalt%NOTFOUND THEN      
            CLOSE cr_crapalt; 
            vr_crapalt_insere:= TRUE;
            
            BEGIN
              INSERT INTO crapalt(nrdconta,
                                  dtaltera,
                                  tpaltera,
                                  cdcooper)
                           VALUES(pr_tab_contaitg(vr_ind).nrdconta,
                                  to_char(SYSDATE,'dd/mm/rrrr'),
                                  2,
                                  vr_cdcooper) 
                                  RETURNING 
                                    ROWID
                                   INTO 
                                    rw_crapalt.ROWID; 
                                      
                                   
            EXCEPTION
              WHEN OTHERS THEN
                pr_dscritic := ' Problemas na pc_atualiza_contaitg - ' ||
                            SQLERRM;
                RAISE vr_exc_fim;
            END;
            
            rw_crapalt.dsaltera:= '';
          ELSE
             CLOSE cr_crapalt;   
             vr_crapalt_insere:= FALSE;
          END IF;
 
          vr_nmdcampo:= 'exclusao conta-itg('||to_char(vr_nrdctitg2)||')- ope.1';
         
          -- Registrar rollback caso ocorra algum erro
          pc_escreve_xml('UPDATE crapass SET cdsitdct = ' || rw_crapass.cdsitdct|| 
                                           ',cdtipcta = ' || rw_crapass.cdtipcta||
                                           ',flgctitg = ' || rw_crapass.flgctitg|| 
                                           ' WHERE crapass.progress_recid = '||rw_crapass.progress_recid||';'||chr(10)); 
                                      
          -- Registrar Rollback caso seja necessario     
          IF vr_crapalt_insere THEN
            pc_escreve_xml('DELETE crapalt WHERE crapalt.rowid = '''||to_char(rw_crapalt.rowid)||''';'||chr(10));
          ELSE
            pc_escreve_xml('UPDATE crapalt SET flgctitg = ' || rw_crapalt.flgctitg|| 
                                             ',cdoperad = ' || rw_crapalt.cdoperad||
                                             ',tpaltera = ' || rw_crapalt.tpaltera|| 
                                             ',dsaltera = ''' || rw_crapalt.dsaltera||
                                             ''' WHERE crapalt.rowid = '''||rw_crapalt.rowid||''';'||chr(10)); 
          END IF;
          
           -- Inativar contas ITG
           BEGIN
             UPDATE crapalt
                SET flgctitg = 0
                   ,cdoperad = '1'
                   ,tpaltera = 2
                   ,dsaltera = rw_crapalt.dsaltera||vr_nmdcampo||','
              WHERE crapalt.rowid = rw_crapalt.rowid;
           EXCEPTION
             WHEN OTHERS THEN
               pr_dscritic := ' Problemas na pc_atualiza_contaitg - ' ||
                              SQLERRM;
               RAISE vr_exc_fim;
           END;
          
          IF rw_crapass.cdsitdct <> 4 AND rw_crapass.cdtipcta > 11 THEN
            vr_cdsitdct := 6;
          ELSE
            vr_cdsitdct := rw_crapass.cdsitdct;
          END IF;
          
          IF rw_crapass.cdtipcta > 11 THEN 
            vr_cdtipcta := rw_crapass.cdtipcta - 11;
          ELSE 
            vr_cdtipcta := rw_crapass.cdtipcta;
          END IF;
          
          -- Inativar contas ITG
         BEGIN
           UPDATE crapass
              SET cdsitdct = vr_cdsitdct
                 ,cdtipcta = vr_cdtipcta
                 ,flgctitg = 3
            WHERE crapass.progress_recid = rw_crapass.progress_recid;
         EXCEPTION
           WHEN OTHERS THEN
             pr_dscritic := ' Problemas na pc_atualiza_contaitg - ' ||
                            SQLERRM;
             RAISE vr_exc_fim;
         END;
          
        END IF;
        
     END LOOP;
     
     pc_escreve_xml('COMMIT;');
     pc_escreve_xml(' ',TRUE);
     DBMS_XSLPROCESSOR.CLOB2FILE(vr_des_xml, pr_dsdireto, to_char(sysdate,'ddmmyyyy_hh24miss')||'_'||vr_nmarqbkp, NLS_CHARSET_ID('UTF8'));
     -- Liberando a memória alocada pro CLOB
     dbms_lob.close(vr_des_xml);
     dbms_lob.freetemporary(vr_des_xml);

  EXCEPTION 
    WHEN vr_exc_fim THEN
      --LOG
      gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, to_char(sysdate,'ddmmyyyy_hh24miss')||pr_dscritic);
    WHEN OTHERS THEN
      pr_dscritic := ' Problemas na pc_atualiza_contaitg - '||SQLERRM; 
      --LOG
      gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, to_char(sysdate,'ddmmyyyy_hh24miss')||pr_dscritic);
  END pc_atualiza_contaitg;

  
BEGIN 
  
  --Layout do arquivo que irei importar
  --PA;Conta;CPF/CNPJ;Nome;Conta integração

  FOR rw_crapcop IN cr_crapcop LOOP
    
    /* Exemplo de como tem que ser o nome do arquivo dentro do diretorio /micros/cpd/bacas/conta_itg 
       viacredi_itg.csv */
    vr_nome_baca := 'CONTAITG_'||upper(rw_crapcop.dsdircop);
    vr_nmdireto := gene0001.fn_param_sistema('CRED',vr_cdcooper,'ROOT_MICROS');
    vr_nmdireto := vr_nmdireto||'cpd/bacas/conta_itg'; 
    vr_nmarqimp  := rw_crapcop.dsdircop||'_itg.csv';
    vr_nmarqbkp  := 'ROLLBACK_ATUALIZA_CONTAITG_'||upper(rw_crapcop.dsdircop)||'.txt';
    vr_nmarqlog := 'LOG_'||vr_nome_baca||'_'||to_char(sysdate,'ddmmyyyy_hh24miss')||'.txt';

    vr_cdcooper:= rw_crapcop.cdcooper;
    
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
      
      gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, to_char(sysdate,'ddmmyyyy_hh24miss')||' - Inicio Processo - '||upper(rw_crapcop.dsdircop));  
    /* ############# FIM LOG ########################### */
    
    vr_tab_contaitg.DELETE;

    --LOG
    gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, to_char(sysdate,'ddmmyyyy_hh24miss')||' - Inicio pc_carrega_contaitg - '||upper(rw_crapcop.dsdircop));
    
    -- carrega uma tmeptable com base no arquivo
    pc_carrega_contaitg( pr_dsdireto     => vr_nmdireto                    -- Diretorio onde esta o arquivo
                        ,pr_nmarquiv     => vr_nmarqimp                    -- Nome do arquivo (arquivo.txt|arquivo.csv)
                        ,pr_pprlinha     => 1                              -- Pula primeira linha (0-nao, 1-sim)
                        ,pr_tab_contaitg => vr_tab_contaitg                -- Temp-Table com o conteudo do arquivo
                        ,pr_dscritic     => vr_dscritic);                  -- descricao da critica 
                                
    -- Se houve erro ao carregar o arquivo aborta
    IF vr_dscritic IS NOT NULL THEN
       --LOG
       gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, to_char(sysdate,'ddmmyyyy_hh24miss')||' - Fim pc_carrega_contaitg com ERRO '||vr_dscritic);
       RAISE vr_exc_erro;
    END IF;
    
    --LOG
    gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, to_char(sysdate,'ddmmyyyy_hh24miss')||' - Fim pc_carrega_contaitg  - '||upper(rw_crapcop.dsdircop));
    gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, to_char(sysdate,'ddmmyyyy_hh24miss')||' - Inicio pc_atualiza_contaitg  - '||upper(rw_crapcop.dsdircop));
    
    --criar cpf e cpnj na tabela de cadastro restritivo crapcrt
    pc_atualiza_contaitg(pr_dsdireto     => vr_nmdireto
                        ,pr_nmarqbkp     => vr_nmarqbkp -- Arquivo de bkp que volta as alteracoes criadas
                        ,pr_tab_contaitg => vr_tab_contaitg
                        ,pr_dscritic     => vr_dscritic); 
    
    -- Se houve erro ao carregar o arquivo aborta
    IF vr_dscritic IS NOT NULL THEN
       --LOG
       gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, to_char(sysdate,'ddmmyyyy_hh24miss')||' - Fim pc_atualiza_contaitg com ERRO '||vr_dscritic);
       RAISE vr_exc_erro;
    END IF;

    --LOG
    gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, to_char(sysdate,'ddmmyyyy_hh24miss')||' - Fim pc_atualiza_contaitg - '||upper(rw_crapcop.dsdircop));
    gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, to_char(sysdate,'ddmmyyyy_hh24miss')||' - Fim Processo com sucesso - '||upper(rw_crapcop.dsdircop));
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arqlog); --> Handle do arquivo aberto;  
  END LOOP;
  
  COMMIT;                            
EXCEPTION
  WHEN vr_exc_erro THEN
    --LOG
    gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, to_char(sysdate,'ddmmyyyy_hh24miss')||' - Fim Processo com erro');  
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arqlog); --> Handle do arquivo aberto;  
    ROLLBACK;
  WHEN OTHERS THEN
    --LOG
    gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, to_char(sysdate,'ddmmyyyy_hh24miss')||' - Fim Processo com erro');
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arqlog); --> Handle do arquivo aberto;  
    ROLLBACK; 
END;
0
4
vr_cdcooper
pr_tab_contaitg(vr_ind).nrdconta
pr_tab_contaitg(vr_ind).nrdctitg
vr_nrdctitg
