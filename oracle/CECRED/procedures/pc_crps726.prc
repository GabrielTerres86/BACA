CREATE OR REPLACE PROCEDURE CECRED.pc_crps726(pr_cdcooper IN crapcop.cdcooper%TYPE   --> Cooperativa solicitada                                             
                                             ,pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada

  /*..............................................................................

    Programa: pc_crps726                      
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Odirlei Busana - AMcom
    Data    : Janeiro/2018                  Ultima Atualizacao : 24/01/2018

    Dados referente ao programa:

    Frequencia : Mensal (JOB).
    Objetivo   : Gerar arquivos contabeis de Convenios Bancoob .

    Alteracoes : 
  ..............................................................................*/

  --------------------- ESTRUTURAS PARA OS RELATÓRIOS ---------------------

  ------------------------------- VARIAVEIS -------------------------------

  -- Tratamento de erros
  vr_exc_saida  EXCEPTION;
  vr_exc_fimprg EXCEPTION;
  vr_cdcritic   PLS_INTEGER;
  vr_dscritic   VARCHAR2(4000);

  
  -- Auxiliares para o processamento 
  vr_dtarquiv     DATE;
  vr_dtarquiv_ddmmyy VARCHAR2(10);
  vr_dtarquiv_yymmdd VARCHAR2(10);
  vr_dsdircop     VARCHAR2(100);
  vr_nmdireto     VARCHAR2(100);
  vr_nmarquiv     VARCHAR2(100);
  vr_lshistor     VARCHAR2(100);
  vr_dshistor     VARCHAR2(100);
  vr_vldespes     NUMBER;           
  
  -- Código do programa
  vr_cdprogra           CONSTANT crapprg.cdprogra%TYPE := 'CRPS726';
  vr_nomdojob           CONSTANT VARCHAR2(30)          := 'JBCONV_BANCOOB_CONTABIL';
  vr_flgerlog           BOOLEAN;
  
  
  -- Variáveis para armazenar as informações 
  vr_desclob         CLOB;
  vr_desclob_rev     CLOB;
  -- Variável para armazenar os dados antes de incluir no CLOB
  vr_txtcompl        VARCHAR2(32600);
  vr_txtcompl_rev    VARCHAR2(32600);
  vr_dsdlinha        VARCHAR2(32600);
  vr_fechaarq        BOOLEAN;
  vr_flgerrel        BOOLEAN;

  ---------------------------------- CURSORES  ----------------------------------

  -- Busca dos dados da cooperativa
  CURSOR cr_crapcop(pr_cdcooper IN crapcop.cdcooper%TYPE) IS
    SELECT cop.cdcooper
          ,cop.nmrescop
          ,cop.vltardrf
          ,cop.vltarbcb
      FROM crapcop cop
     WHERE cop.cdcooper = DECODE(pr_cdcooper,0,cop.cdcooper,pr_cdcooper) -- Se passado zero, traz todas 
       AND cop.flgativo = 1  -- SOmente ativas
       AND cop.cdcooper <> 3
       ORDER BY cdcooper;

  -- Buscar faturas
  CURSOR cr_craplft(pr_cdcooper crapcop.cdcooper%type
                   ,pr_dtmvtolt craplft.dtvencto%type) IS
    SELECT r.*,
           SUM(r.vltarifa) OVER (PARTITION BY r.inpessoa ORDER BY r.inpessoa) vltartot,
           SUM(r.qtlanmto) OVER (PARTITION BY r.inpessoa ORDER BY r.inpessoa) qttotlan,
           row_number() OVER (PARTITION BY r.inpessoa ORDER BY r.inpessoa) pos_inpessoa,
           COUNT(1) OVER (PARTITION BY r.inpessoa ORDER BY r.inpessoa) total_inpessoa
           
      FROM ( SELECT decode(ass.inpessoa,3,2,ass.inpessoa) inpessoa,     
                    decode(lft.cdagenci,
                          90, nvl(ass.cdagenci, lft.cdagenci),
                          91, nvl(ass.cdagenci, lft.cdagenci),
                          lft.cdagenci) cdagenci_fatura,
                   COUNT(lft.vllanmto) qtlanmto,
                   SUM(lft.vllanmto) vllanmto,
                   SUM(DECODE(lft.cdagenci,90,arr.vltarifa_internet,
                                               91,arr.vltarifa_taa,
                                               arr.vltarifa_caixa))  vltarifa
                   
              FROM crapass ass,
                   craplft lft,
                   crapcon con,
                   tbconv_arrecadacao arr,
                   --> Listar dias do mês para utilizar index ao filtrar tabela craplft
                   (SELECT TRUNC(pr_dtmvtolt,'MM') +LEVEL-1 dtfiltro  
                     from dual  
                     connect by level <= last_day(pr_dtmvtolt) - TRUNC(pr_dtmvtolt,'MM') + 1 ) t                     
             WHERE lft.cdcooper = con.cdcooper       
               AND lft.cdempcon = con.cdempcon
               AND lft.cdsegmto = con.cdsegmto
               AND lft.cdhistor = con.cdhistor
               AND con.cdempcon = arr.cdempcon
               AND con.cdsegmto = arr.cdsegmto
               AND con.tparrecd = arr.tparrecadacao
               AND ass.cdcooper (+) = lft.cdcooper
               AND ass.nrdconta (+) = lft.nrdconta          
               AND lft.cdcooper = pr_cdcooper
               AND lft.insitfat = 2
               AND lft.dtvencto = t.dtfiltro
               AND con.tparrecd = 2
             group BY lft.cdagenci,
                      decode(ass.inpessoa,3,2,ass.inpessoa), 
                      nvl(ass.cdagenci, lft.cdagenci)              
             order by 1,2,3) r             
      WHERE r.vltarifa > 0;
  
  ------------------------------- REGISTROS -------------------------------
    rw_crapcop cr_crapcop%ROWTYPE;
    -- Cursor genérico de calendário
    rw_crapdat btch0001.cr_crapdat%ROWTYPE;

  ------------------------- PROCEDIMENTOS INTERNOS -----------------------------   
    --> Controla log proc_batch, para apensa exibir qnd realmente processar informação
    PROCEDURE pc_controla_log_batch(pr_dstiplog IN VARCHAR2,
                                    pr_dscritic IN VARCHAR2 DEFAULT NULL) IS
    BEGIN
      
      --> Controlar geração de log de execução dos jobs 
      BTCH0001.pc_log_exec_job( pr_cdcooper  => 3              --> Cooperativa
                               ,pr_cdprogra  => vr_cdprogra    --> Codigo do programa
                               ,pr_nomdojob  => vr_nomdojob    --> Nome do job
                               ,pr_dstiplog  => pr_dstiplog    --> Tipo de log(I-inicio,F-Fim,E-Erro)
                               ,pr_dscritic  => pr_dscritic    --> Critica a ser apresentada em caso de erro
                               ,pr_flgerlog  => vr_flgerlog);  --> Controla se gerou o log de inicio, sendo assim necessario apresentar log fim
        
    END pc_controla_log_batch;
    
    -- Subrotina para escrever texto na variável CLOB 
    PROCEDURE pc_escreve_linha(pr_dsdlinha IN VARCHAR2,
                               pr_flrevers IN BOOLEAN DEFAULT FALSE,
                               pr_fechaarq IN BOOLEAN DEFAULT FALSE) IS
      vr_des_dados VARCHAR2(32000);
    BEGIN
      vr_des_dados := pr_dsdlinha;
      IF pr_flrevers = FALSE THEN
        gene0002.pc_escreve_xml(vr_desclob, vr_txtcompl, vr_des_dados, pr_fechaarq);
      ELSE
        gene0002.pc_escreve_xml(vr_desclob_rev, vr_txtcompl_rev, vr_des_dados, pr_fechaarq);
      END IF;
    END;
  

  BEGIN
    -- Incluir nome do módulo logado
    GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra
                              ,pr_action => null);
    
    --> Controla log proc_batch, para apensa exibir qnd realmente processar informação
    pc_controla_log_batch(pr_dstiplog => 'I');
    
    
    vr_dtarquiv := gene0005.fn_valida_dia_util( pr_cdcooper => 3, 
                                                pr_dtmvtolt => trunc(SYSDATE,'MM'), --> será o primeiro dia do mês
                                                pr_tipo     => 'A'); 
    
    vr_dtarquiv_ddmmyy  := to_char(vr_dtarquiv, 'DDMMRR');
    vr_dtarquiv_yymmdd  := to_char(vr_dtarquiv, 'RRMMDD');
      
    
    --> Diretório: 
    vr_dsdircop := gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                            ,pr_cdcooper => 3
                                            ,pr_cdacesso => 'DIR_ARQ_CONTAB_X'); 
    
    FOR rw_crapcop IN cr_crapcop(pr_cdcooper => pr_cdcooper) LOOP
    
      vr_nmarquiv := to_char(vr_dtarquiv,'RRMMDD')||'_'||
                     to_char(rw_crapcop.cdcooper,'fm00')||
                     '_CONVEN_BCB.txt';
    
    
      -- Inicializar o CLOB
      vr_desclob := NULL;
      dbms_lob.createtemporary(vr_desclob, TRUE);
      dbms_lob.open(vr_desclob, dbms_lob.lob_readwrite);
      
      vr_desclob_rev := NULL;
      dbms_lob.createtemporary(vr_desclob_rev, TRUE);
      dbms_lob.open(vr_desclob_rev, dbms_lob.lob_readwrite);
      
      -- Inicilizar as informações do XML
      vr_txtcompl_rev := NULL;
      vr_txtcompl     := NULL;  
      vr_flgerrel     := FALSE;
      
      -- Buscar faturas
      FOR rw_craplft IN  cr_craplft( pr_cdcooper => rw_crapcop.cdcooper
                                    ,pr_dtmvtolt => vr_dtarquiv) LOOP
        
        --> Caso for o primeiro registro, deve gerar linha cabecalho
        IF rw_craplft.pos_inpessoa = 1 THEN
          vr_flgerrel     := TRUE;
          
          IF rw_craplft.inpessoa = 1 THEN
            vr_lshistor := '7613,7611';
            vr_dshistor := '"TARIFAS CONVENIO BANCOOB - COOPERADOS PESSOA FISICA."';
            
          ELSIF rw_craplft.inpessoa = 2 THEN
            vr_lshistor := '7613,7612';
            vr_dshistor := '"TARIFAS CONVENIO BANCOOB - COOPERADOS PESSOA JURIDICA."';            
          END IF;         
        
          --> gerar linha cabeçalho
          vr_dsdlinha := '70'||TRIM(vr_dtarquiv_yymmdd)        ||','||
                         TRIM(vr_dtarquiv_ddmmyy)              ||','||
                         vr_lshistor                           ||','||
                         to_char(rw_craplft.vltartot,'FM9999999999990D00','NLS_NUMERIC_CHARACTERS=''.,''') ||','||
                         '5210'                                ||','||
                         vr_dshistor||
                         chr(10);
          --> Escrever no arquivo               
          pc_escreve_linha(pr_dsdlinha => vr_dsdlinha); 
          vr_dsdlinha := NULL;        
      
        END IF;                   
        
        --> gerar registro pa
        vr_dsdlinha := to_char(rw_craplft.cdagenci_fatura,'fm00')   ||','||
                       to_char(rw_craplft.vltarifa,'FM9999999999990D00','NLS_NUMERIC_CHARACTERS=''.,''') ||
                       chr(10);
        
        --> Verificar se é o ultima linha, para descaregar o buffer
        IF rw_craplft.total_inpessoa = rw_craplft.pos_inpessoa THEN
          vr_fechaarq := TRUE;
        ELSE
          vr_fechaarq := FALSE; 
        END IF;
        
        --> Escrever no arquivo               
        pc_escreve_linha(pr_dsdlinha => vr_dsdlinha,
                         pr_fechaarq => vr_fechaarq ); 
        pc_escreve_linha(pr_dsdlinha => vr_dsdlinha,
                         pr_flrevers => TRUE,
                         pr_fechaarq => vr_fechaarq); 
        
        vr_dsdlinha := NULL;   
        
        --> Verificar se é o ultima linha, para descaregar o buffer
        IF rw_craplft.total_inpessoa = rw_craplft.pos_inpessoa THEN
          --> Concatenar lançamentos 
          dbms_lob.append(vr_desclob,vr_desclob_rev);
          
          --Fechar clob utilizado apenas para duplicar dados          
          IF dbms_lob.isopen(vr_desclob_rev) <> 0 THEN
            -- Liberando a memória alocada pro CLOB
            dbms_lob.close(vr_desclob_rev);      
          END IF;
          dbms_lob.freetemporary(vr_desclob_rev); 
          
          --> abri-lo novamente para ser usado caso necessario
          vr_desclob_rev := NULL;
          vr_txtcompl_rev:= NULL;
          dbms_lob.createtemporary(vr_desclob_rev, TRUE);
          dbms_lob.open(vr_desclob_rev, dbms_lob.lob_readwrite);
          
        END IF;
        
      END LOOP;                              
      
      --> Gerar arquivo apenas se possuir informações
      IF vr_flgerrel = TRUE THEN
      
        -- Busca do diretório onde ficará o arquivo
        vr_nmdireto := gene0001.fn_diretorio(pr_tpdireto => 'C', -- /usr/coop
                                             pr_cdcooper => rw_crapcop.cdcooper,
                                             pr_nmsubdir => '/arq');
        
        gene0002.pc_solicita_relato_arquivo(pr_cdcooper  => rw_crapcop.cdcooper, 
                                            pr_cdprogra  => 'CRPS726', 
                                            pr_dtmvtolt  => vr_dtarquiv, 
                                            pr_dsxml     => vr_desclob, 
                                            pr_dsarqsaid => vr_nmdireto||'/'||vr_nmarquiv, 
                                            pr_cdrelato  => 0, 
                                            pr_dspathcop => vr_dsdircop,
                                            pr_fldoscop  => 'S',  
                                            pr_flg_gerar => 'S',
                                            pr_des_erro  => vr_dscritic);
        IF TRIM(vr_dscritic) IS NOT NULL THEN
          RAISE vr_exc_saida;
        END IF;
      END IF;
      
      IF dbms_lob.isopen(vr_desclob) <> 1 THEN
        -- Liberando a memória alocada pro CLOB
        dbms_lob.close(vr_desclob);        
      END IF;
      
      dbms_lob.freetemporary(vr_desclob);
      
      IF dbms_lob.isopen(vr_desclob_rev) <> 0 THEN
        -- Liberando a memória alocada pro CLOB
        dbms_lob.close(vr_desclob_rev);      
      END IF;
      dbms_lob.freetemporary(vr_desclob_rev); 
    
      ---->>>>> GERACAO SEGUNDO ARQUIVO DESPESAS <<<<<<<<-----
          
      --> Gerar arq apenas para coops que possuam valor para calcular
      IF rw_crapcop.vltarbcb <> 0 THEN
      
        vr_nmarquiv := to_char(vr_dtarquiv,'RRMMDD')||'_'||
                       to_char(rw_crapcop.cdcooper,'fm00')||
                       '_DESPESABANCOOB.txt';
      
      
        -- Inicializar o CLOB
        vr_desclob := NULL;
        dbms_lob.createtemporary(vr_desclob, TRUE);
        dbms_lob.open(vr_desclob, dbms_lob.lob_readwrite);
        
        vr_desclob_rev := NULL;
        dbms_lob.createtemporary(vr_desclob_rev, TRUE);
        dbms_lob.open(vr_desclob_rev, dbms_lob.lob_readwrite);
        
        -- Inicilizar as informações do XML
        vr_txtcompl_rev := NULL;
        vr_txtcompl     := NULL;
        vr_flgerrel     := FALSE;  
        
        -- Buscar faturas
        FOR rw_craplft IN  cr_craplft( pr_cdcooper => rw_crapcop.cdcooper
                                      ,pr_dtmvtolt => vr_dtarquiv) LOOP
          
          --> Caso for o primeiro registro, deve gerar linha cabecalho
          IF rw_craplft.pos_inpessoa = 1 THEN
            --> marcar como possui dados para gerar relat
            vr_flgerrel     := TRUE;
            
            IF rw_craplft.inpessoa = 1 THEN
              vr_lshistor := '8646,8648';
              vr_dshistor := '"DESPESA ARRECADACAO BANCOOB - PESSOA FISICA."';
              
            ELSIF rw_craplft.inpessoa = 2 THEN
              vr_lshistor := '8647,8648';
              vr_dshistor := '"DESPESA ARRECADACAO BANCOOB - PESSOA JURIDICA."';            
            END IF;         
            
            vr_vldespes := rw_craplft.qttotlan * rw_crapcop.vltarbcb;
            
            --> gerar linha cabeçalho
            vr_dsdlinha := '70'||TRIM(vr_dtarquiv_yymmdd)        ||','||
                           TRIM(vr_dtarquiv_ddmmyy)              ||','||
                           vr_lshistor                           ||','||
                           to_char(vr_vldespes,'FM9999999999990D00','NLS_NUMERIC_CHARACTERS=''.,''') ||','||
                           '5210'                                ||','||
                           vr_dshistor||
                           chr(10);
            --> Escrever no arquivo               
            pc_escreve_linha(pr_dsdlinha => vr_dsdlinha); 
            vr_dsdlinha := NULL;        
        
          END IF;                   
          
          
          vr_vldespes := rw_craplft.qtlanmto * rw_crapcop.vltarbcb;
          --> gerar registro pa
          vr_dsdlinha := to_char(rw_craplft.cdagenci_fatura,'fm00')   ||','||
                         to_char(vr_vldespes,'FM9999999999990D00','NLS_NUMERIC_CHARACTERS=''.,''') ||
                         chr(10);
          
          --> Verificar se é o ultima linha, para descaregar o buffer
          IF rw_craplft.total_inpessoa = rw_craplft.pos_inpessoa THEN
            vr_fechaarq := TRUE;
          ELSE
            vr_fechaarq := FALSE; 
          END IF;
          
          --> Escrever no arquivo               
          pc_escreve_linha(pr_dsdlinha => vr_dsdlinha,
                           pr_fechaarq => vr_fechaarq ); 
          pc_escreve_linha(pr_dsdlinha => vr_dsdlinha,
                           pr_flrevers => TRUE,
                           pr_fechaarq => vr_fechaarq); 
          
          vr_dsdlinha := NULL;   
          
          --> Verificar se é o ultima linha, para descaregar o buffer
          IF rw_craplft.total_inpessoa = rw_craplft.pos_inpessoa THEN
            --> Concatenar lançamentos 
            dbms_lob.append(vr_desclob,vr_desclob_rev);
            
            --Fechar clob utilizado apenas para duplicar dados          
            IF dbms_lob.isopen(vr_desclob_rev) <> 0 THEN
              -- Liberando a memória alocada pro CLOB
              dbms_lob.close(vr_desclob_rev);      
            END IF;
            dbms_lob.freetemporary(vr_desclob_rev); 
            
            --> abri-lo novamente para ser usado caso necessario
            vr_desclob_rev := NULL;
            vr_txtcompl_rev:= NULL;
            dbms_lob.createtemporary(vr_desclob_rev, TRUE);
            dbms_lob.open(vr_desclob_rev, dbms_lob.lob_readwrite);
            
          END IF;
          
        END LOOP;                              
                
        --> Gerar arquivo apenas se possuir informações
        IF vr_flgerrel = TRUE THEN
      
          -- Busca do diretório onde ficará o arquivo
          vr_nmdireto := gene0001.fn_diretorio(pr_tpdireto => 'C', -- /usr/coop
                                               pr_cdcooper => rw_crapcop.cdcooper,
                                               pr_nmsubdir => '/arq');
          
          gene0002.pc_solicita_relato_arquivo(pr_cdcooper  => rw_crapcop.cdcooper, 
                                              pr_cdprogra  => 'CRPS726', 
                                              pr_dtmvtolt  => vr_dtarquiv, 
                                              pr_dsxml     => vr_desclob, 
                                              pr_dsarqsaid => vr_nmdireto||'/'||vr_nmarquiv, 
                                              pr_cdrelato  => 0, 
                                              pr_dspathcop => vr_dsdircop,
                                              pr_fldoscop  => 'S',  
                                              pr_flg_gerar => 'S',
                                              pr_des_erro  => vr_dscritic);
          IF TRIM(vr_dscritic) IS NOT NULL THEN
            RAISE vr_exc_saida;
          END IF;
        END IF;
        
        IF dbms_lob.isopen(vr_desclob) <> 1 THEN
          -- Liberando a memória alocada pro CLOB
          dbms_lob.close(vr_desclob);        
        END IF;
        
        dbms_lob.freetemporary(vr_desclob);
        
        IF dbms_lob.isopen(vr_desclob_rev) <> 0 THEN
          -- Liberando a memória alocada pro CLOB
          dbms_lob.close(vr_desclob_rev);      
        END IF;
        dbms_lob.freetemporary(vr_desclob_rev);       
      
      END IF;
        
    END LOOP; --> Fim loop CRAPCOP
        
    ----------------- ENCERRAMENTO DO PROGRAMA -------------------                                                     
  
    --> Controla log proc_batch, para apensa exibir qnd realmente processar informação
    pc_controla_log_batch(pr_dstiplog => 'F');
    

    -- Salvar informações atualizadas
    COMMIT;

  EXCEPTION
    WHEN vr_exc_saida THEN
    -- Se foi retornado apenas código
    IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
      -- Buscar a descrição
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
    END IF;
    
    --> Controla log proc_batch, para apensa exibir qnd realmente processar informação
    pc_controla_log_batch(pr_dstiplog => 'E',
                          pr_dscritic => vr_dscritic);
    
    pr_dscritic := vr_dscritic;
    -- Efetuar rollback
    ROLLBACK;
    raise_application_error(-20500,vr_dscritic);
  WHEN OTHERS THEN
    -- Efetuar retorno do erro não tratado
    vr_dscritic := SQLERRM;                           
    --> Controla log proc_batch, para apensa exibir qnd realmente processar informação
    pc_controla_log_batch(pr_dstiplog => 'E',
                          pr_dscritic => vr_dscritic);
    pr_dscritic := vr_dscritic;                      
    -- Efetuar rollback
    ROLLBACK;
    raise_application_error(-20500,vr_dscritic);
End pc_crps726;
/
