create or replace procedure cecred.pc_crps626 (pr_cdcooper IN crapcop.cdcooper%TYPE   --> Cooperativa solicitada
                                              ,pr_flgresta  IN PLS_INTEGER            --> Flag padrão para utilização de restart
                                              ,pr_nmtelant  IN VARCHAR2               --> Tela chamadora
                                              ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                                              ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                                              ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                                              ,pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada

  /* .............................................................................

    Programa: PC_CRPS626                          Antigo: Fontes/crps626.p
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : André Santos/Supero
    Data    : Agosto/2012                   Ultima atualizacao: 09/11/2017
   
    Dados referentes ao programa:
   
    Frequencia: Diario (Batch).
    Objetivo  : Integrar arquivos TIC - Recebe arquivo TIC616
   
    Alteracoes: 25/10/2012 - Desconsiderar algumas criticas (Ze).
   
                10/10/2013 - Incluido tratamento craprej.cdcritic = 12,
                             ref. FDR 43/2013 (Diego).
   
                14/01/2014 - Alteracao referente a integracao Progress X
                             Dataserver Oracle
                             Inclusao do VALIDATE ( Andre Euzebio / SUPERO)
   
                05/08/2014 - Alteraçao da Nomeclatura para PA (Vanessa).
               
                09/11/2017 - Conversão Progress para Oracle (Jonata-MOUTs)

				        06/06/2017 - Incluso tratativa para efetuar leitura da crapcst de
				                     apenas cheques que nao foram descontados. (Daniel) 
  ............................................................................. */

    ------------------------ VARIAVEIS PRINCIPAIS ----------------------------

    -- Código do programa
    vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'CRPS626';

    -- Tratamento de erros
    vr_exc_saida     EXCEPTION;
    vr_exc_fimprg    EXCEPTION;
    vr_cdcritic      PLS_INTEGER;
    vr_dscritic      VARCHAR2(4000);    
    
    ------------------------------- CURSORES ---------------------------------
    -- Busca dos dados da cooperativa
    CURSOR cr_crapcop IS
      SELECT cop.nmrescop
            ,cop.nmextcop
            ,cop.cdagectl
            ,cop.cdbcoctl
        FROM crapcop cop
       WHERE cop.cdcooper = pr_cdcooper;
    rw_crapcop cr_crapcop%ROWTYPE;

    -- Cursor genérico de calendário
    rw_crapdat btch0001.cr_crapdat%ROWTYPE;
     
    -- Busca dos cheques em custódia
    cursor CR_CRAPCST(pr_cdcooper CRAPCST.Cdcooper%type
                     ,pr_cdcmpchq CRAPCST.Cdcmpchq%type
                     ,pr_cdbanchq CRAPCST.Cdbanchq%type
                     ,pr_cdagechq CRAPCST.Cdagechq%type
                     ,pr_nrctachq CRAPCST.Nrctachq%type
                     ,pr_nrdocmto CRAPCST.Nrdocmto%type)is
      select rowid nrrowid
            ,nrdconta
            ,dtlibera
            ,dtmvtolt
            ,vlcheque
            ,cdagenci
            ,cdbccxlt
            ,nrdolote
            ,COUNT(1) OVER (PARTITION BY 1) qtdregis
        from crapcst
       where crapcst.cdcooper = pr_cdcooper 
         and crapcst.cdcmpchq = pr_cdcmpchq  -- Nro compe 
         and crapcst.cdbanchq = pr_cdbanchq  -- Nro do Bco
         and crapcst.cdagechq = pr_cdagechq  -- Age dest  
         and crapcst.nrctachq = pr_nrctachq  -- Nr ctachq 
         and crapcst.nrcheque = pr_nrdocmto  -- Nro chq   
		     AND crapcst.nrborder = 0;
    RW_CRAPCST CR_CRAPCST%ROWTYPE;
   
    -- Retorno dos cheques contidos no Borderô da Custódia
    cursor  CR_CRAPCDB(pr_cdcooper crapcdb.Cdcooper%TYPE
                      ,pr_cdcmpchq crapcdb.Cdcmpchq%TYPE
                      ,pr_cdbanchq crapcdb.Cdbanchq%TYPE
                      ,pr_cdagechq crapcdb.Cdagechq%TYPE
                      ,pr_nrctachq crapcdb.Nrctachq%TYPE
                      ,pr_nrdocmto crapcdb.Nrdocmto%type)is
      select rowid nrrowid
            ,nrdconta
            ,dtlibera
            ,dtmvtolt
            ,vlcheque
            ,cdagenci
            ,cdbccxlt
            ,nrdolote
            ,COUNT(1) OVER (PARTITION BY 1) qtdregis
        from crapcdb
       where cdcooper = pr_cdcooper 
         and cdcmpchq = pr_cdcmpchq  -- Nro compe  
         and cdbanchq = pr_cdbanchq  -- Nro do Bco 
         and cdagechq = pr_cdagechq  -- Agen dest  
         and nrctachq = pr_nrctachq  -- Nro ctachq 
         and nrcheque = pr_nrdocmto; -- Nro chq    
    rw_crapcdb cr_crapcdb%ROWTYPE;
    
    -- Busca dos rejeitos gravados 
    cursor cr_craprej(pr_cdcooper craprej.Cdcooper%type
                     ,pr_dtlimite craprej.dtdaviso%type)is
      select rowid  
            ,cdcritic
            ,cdpesqbb
            ,nrdctitg
            ,nrdocmto
            ,vllanmto
            ,dtdaviso
            ,dtmvtolt
            ,nrdconta
            ,dshistor 
        from craprej
       where cdcooper = pr_cdcooper 
         and dtdaviso > pr_dtlimite;
    
    -- Variáveis para armazenar as informações em XML
    vr_des_xml          CLOB;
    vr_des_txt          VARCHAR2(32767);
    
    --------------------------- VARIAVEIS DO CORPO DO PROGRAMA----------------
    
    -- Busca/tratamento dos arquivos para processar
    vr_dtauxili VARCHAR(10);
    vr_dtmvtolt DATE;
    vr_dtlimite DATE;
    vr_digitmes CHAR(1);
    vr_nmarquiv VARCHAR2(500);    
    vr_dslisarq VARCHAR2(1000);    
    vr_dsdircop VARCHAR2(1000);
    vr_splisarq gene0002.typ_split;
    vr_typ_saida  VARCHAR2(1000);
    vr_input_file UTL_FILE.file_type;
    vr_setlinha   varchar2(500);
    vr_contador   NUMBER;

    
    -- Variaveis auxiliares para leitura das linhas e controles do arquivo 
    vr_flgrejei BOOLEAN;
    vr_nmdcampo VARCHAR2(100);
    vr_vldcampo VARCHAR2(100);
    vr_nrdocmto number;
    vr_nrseqarq number;
    vr_cdbanchq number;
    vr_cdcmpchq number;
    vr_cdagechq number;
    vr_nrctachq craplcm.nrctachq%type;
    vr_cdocorre number;
    vr_cdpesqbb varchar2(500);
    
    -- Totalizadores para o relatório 
    vr_qtcompln NUMBER(8,2);
    vr_vlcompdb NUMBER(8,2);    

  begin
    --------------- VALIDACOES INICIAIS -----------------
    -- Incluir nome do módulo logado
    GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra
                              ,pr_action => null);
    -- Verifica se a cooperativa esta cadastrada
    OPEN cr_crapcop;
    FETCH cr_crapcop
     INTO rw_crapcop;
    -- Se não encontrar
    IF cr_crapcop%NOTFOUND THEN
      -- Fechar o cursor pois haverá raise
      CLOSE cr_crapcop;
      -- Montar mensagem de critica
      vr_cdcritic := 651;
      RAISE vr_exc_saida;
    ELSE
      -- Apenas fechar o cursor
      CLOSE cr_crapcop;
    END IF;

    -- Leitura do calendário da cooperativa
    OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
    FETCH btch0001.cr_crapdat
     INTO rw_crapdat;
    -- Se não encontrar
    IF btch0001.cr_crapdat%NOTFOUND THEN
      -- Fechar o cursor pois efetuaremos raise
      CLOSE btch0001.cr_crapdat;
      -- Montar mensagem de critica
      vr_cdcritic := 1;
      RAISE vr_exc_saida;
    ELSE
      -- Apenas fechar o cursor
      CLOSE btch0001.cr_crapdat;
    END IF;

    -- Validações iniciais do programa
    BTCH0001.pc_valida_iniprg(pr_cdcooper => pr_cdcooper
                             ,pr_flgbatch => 1
                             ,pr_cdprogra => vr_cdprogra
                             ,pr_infimsol => pr_infimsol
                             ,pr_cdcritic => vr_cdcritic);
    -- Se a variavel de erro é <> 0
    IF nvl(vr_cdcritic,0) <> 0 THEN
      -- Envio centralizado de log de erro
      RAISE vr_exc_saida;
    END IF;
    
    -- Busca do diretório base da cooperativa
    vr_dsdircop := gene0001.fn_diretorio(pr_tpdireto => 'C' -- /usr/coop
                                        ,pr_cdcooper => pr_cdcooper);
    
    -- Montagem da data de processamento conforme execução (COMPEFORA ou Não)
    IF pr_nmtelant = 'COMPEFORA' THEN
      -- Usar data anterior pois processo já rodou
      vr_dtmvtolt := rw_crapdat.dtmvtoan;
    ELSE
      -- Rodando no processo 
      vr_dtmvtolt := rw_crapdat.dtmvtolt;
    END IF;
    
    -- Montar data limite para busca dos rejeitos 
    vr_dtlimite := gene0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper
                                              ,pr_dtmvtolt => rw_crapdat.dtmvtopr + 1
                                              ,pr_tipo     => 'P'); 
    
    -- Montar data em texto para busca do arquivo 
    vr_dtauxili := to_char(vr_dtmvtolt,'rrrrmmdd');
    
    -- Montagem do nome do arquivo conforme a data
    CASE to_char(vr_dtmvtolt,'MM') 
      WHEN '10' THEN 
        vr_digitmes := 'O';
      WHEN '11' THEN
        vr_digitmes := 'N';
      WHEN '12' THEN
        vr_digitmes := 'D';
      ELSE 
        vr_digitmes := ltrim(to_char(vr_dtmvtolt,'MM'),'0');
    END CASE;


    -- Nome do arq de origem
    vr_nmarquiv := '1' || to_char(rw_crapcop.cdagectl,'fm0000') || vr_digitmes || to_char(vr_dtmvtolt,'dd') || '.CND';
    
    -- Listar arquivos no diretorio
    gene0001.pc_lista_arquivos (pr_path     => vr_dsdircop || '/integra'
                               ,pr_pesq     => vr_nmarquiv
                               ,pr_listarq  => vr_dslisarq
                               ,pr_des_erro => vr_dscritic);
    -- Se houver erro
    IF vr_dscritic IS NOT NULL THEN 
      RAISE vr_exc_saida;
    END IF;
      
    -- Separa a lista de arquivos em uma tabela com todos os encontrados
    vr_splisarq := gene0002.fn_quebra_string(vr_dslisarq, ',');
    
    -- Verifica se a quebra não retornou pelo menos um arquivo 
    IF vr_splisarq.count() = 0 THEN     
      -- Gerar critica 182
      vr_cdcritic := 182;
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      -- Sair e continuar o processo 
      RAISE vr_exc_fimprg;
    END IF;
    
    -- Limpar tabela CRAPREJ
    BEGIN 
      delete craprej 
       WHERE craprej.cdcooper = pr_cdcooper;
    EXCEPTION 
      WHEN OTHERS THEN 
        vr_dscritic := 'Erro na limpeza da tabela CRAPREJ --> '||sqlerrm;
    END;    
    
    -- Iterar sobre a lista de arquivos encontrados
    FOR idx IN 1..vr_splisarq.count() LOOP     
      
      -- Reiniciando controles e contadores
      vr_flgrejei := false;
      vr_qtcompln := 0;
      vr_vlcompdb := 0;
      vr_cdcritic := 0;
      vr_contador := 0;
      
      -- Abre o arquivo
      gene0001.pc_abre_arquivo(pr_nmdireto => vr_dsdircop||'/integra' --> Diretorio do arquivo
                              ,pr_nmarquiv => vr_splisarq(idx)        --> Nome do arquivo
                              ,pr_tipabert => 'R'                     --> Modo de abertura (R,W,A)
                              ,pr_utlfileh => vr_input_file           --> Handle do arquivo aberto
                              ,pr_des_erro => vr_dscritic);           --> Erro
      IF vr_dscritic IS NOT NULL THEN
        --Levantar Excecao
        vr_dscritic := 'Erro na leitura do arquivo ['||vr_splisarq(idx)||'] --> '||vr_dscritic;
        RAISE vr_exc_saida;
      END IF;
      
      --Verifica se o arquivo esta aberto
      IF utl_file.IS_OPEN(vr_input_file) THEN
      
        -- Leitura do HEADER
        gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                    ,pr_des_text => vr_setlinha); --> Texto lido
        
        -- Validação do Header 
        IF SUBSTR(vr_setlinha,1,10) <> '0000000000'  THEN -- Const = 0 
          vr_cdcritic := 468;
        ELSIF SUBSTR(vr_setlinha,48,6) <> 'TIC616' THEN  -- Const = 'TIC616' 
          vr_cdcritic := 173;
        ELSIF to_number(SUBSTR(vr_setlinha,61,3)) <> to_char(rw_crapcop.cdbcoctl) THEN -- Nr cd bco 
          vr_cdcritic := 057;
        ELSIF SUBSTR(vr_setlinha,66,8) <> vr_dtauxili THEN
          vr_cdcritic := 013;
        END IF;
        
        -- Se houve critica na validação do Header 
        IF (vr_cdcritic <> 0) THEN
          -- Busca critica
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
          
          -- Envio centralizado de log de erro
          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                    ,pr_ind_tipo_log => 2 -- Erro tratato
                                    ,pr_nmarqlog     => gene0001.fn_param_sistema('CRED',pr_cdcooper,'NOME_ARQ_LOG_MESSAGE')
                                    ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                     || vr_cdprogra || ' --> Arquivo : integra/'||vr_splisarq(idx)||' --> '||vr_dscritic);
          -- Renomeamos o arquivo para err_||nome_anterior         
          gene0001.pc_OScommand_Shell(pr_des_comando => 'mv '||vr_dsdircop||'/integra/'||vr_splisarq(idx) ||' '||vr_dsdircop||'/integra/err_'||vr_splisarq(idx)
                                               ,pr_typ_saida   => vr_typ_saida
                                               ,pr_des_saida   => vr_dscritic);
          IF NVL(vr_typ_saida,' ') = 'ERR' THEN
            -- Desfaz alterações e inclui erro no log pois não conseguimos tirar os arquivos da INTEGRA
            RAISE vr_exc_saida;
          END IF;
          
          -- Processar o próximo arquivo 
          CONTINUE;
        ELSE 
          -- Header OK, enviar mensagem de integração do arquivo em andamento 
          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                    ,pr_ind_tipo_log => 2 -- Erro tratato
                                    ,pr_nmarqlog     => gene0001.fn_param_sistema('CRED',pr_cdcooper,'NOME_ARQ_LOG_MESSAGE')
                                    ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                     || vr_cdprogra || ' --> '
                                                     || gene0001.fn_busca_critica(219) || ' --> ' 
                                                     || 'integra/'||vr_splisarq(idx));          
          
          -- Efetuamos a leitura dos registros do arquivo
          LOOP
            
            -- Incrementar contador
            vr_contador:= vr_contador + 1;
            
            vr_setlinha := null;
            begin
              gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                          ,pr_des_text => vr_setlinha); --> Texto lido
            exception
              -- se apresentou erro de no_data_found é pq chegou no final do arquivo, fechar arquivo e sair do loop
              WHEN NO_DATA_FOUND THEN
                -- fechar arquivo
                gene0001.pc_fecha_arquivo(pr_utlfileh => vr_input_file);
                EXIT;
            end;
            
            -- Verificação para ignorar cabeçalho e rodapé 
            if (SUBSTR(vr_setlinha,1,10) <> '9999999999' and SUBSTR(vr_setlinha,29,10) <> '9999900000') THEN
              
              -- Separar as informações conforme posições               
              BEGIN 
                vr_nmdcampo := 'Nro docmto';
                vr_vldcampo := SUBSTR(vr_setlinha,25,6);
                vr_nrdocmto := to_number(SUBSTR(vr_setlinha,25,6));          
                
                vr_nmdcampo := 'Seq Arq';
                vr_vldcampo := SUBSTR(vr_setlinha,151,10);
                vr_nrseqarq := to_number(SUBSTR(vr_setlinha,151,10));
                
                vr_nmdcampo := 'Nr do Bco';
                vr_vldcampo := SUBSTR(vr_setlinha,4,3);
                vr_cdbanchq := to_number(SUBSTR(vr_setlinha,4,3));          
                
                vr_nmdcampo := 'Nr Compe';
                vr_vldcampo := SUBSTR(vr_setlinha,1,3);
                vr_cdcmpchq := to_number(SUBSTR(vr_setlinha,1,3)); 
                
                vr_nmdcampo := 'Age Dest';
                vr_vldcampo := SUBSTR(vr_setlinha,7,4);
                vr_cdagechq := to_number(SUBSTR(vr_setlinha,7,4));
                
                vr_nmdcampo := 'Nr Cta Cheque';
                vr_vldcampo := SUBSTR(vr_setlinha,12,12);
                vr_nrctachq := to_number(SUBSTR(vr_setlinha,12,12));
                
                vr_nmdcampo := 'Ocorrencia';
                vr_vldcampo := SUBSTR(vr_setlinha,139,2);
                vr_cdocorre := to_number(SUBSTR(vr_setlinha,139,2)); 
                
                vr_cdpesqbb := vr_setlinha;
              EXCEPTION 
                WHEN OTHERS THEN 
                  -- Gerar critica 86 no LOG e processar o próximo registro 
                  btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                            ,pr_ind_tipo_log => 2 -- Erro tratato
                                            ,pr_nmarqlog     => gene0001.fn_param_sistema('CRED',pr_cdcooper,'NOME_ARQ_LOG_MESSAGE')
                                            ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                             || vr_cdprogra || ' --> '
                                                             || gene0001.fn_busca_critica(86) || ' --> Arquivo ' 
                                                             || 'integra/'||vr_splisarq(idx) || ' na linha '|| vr_contador 
                                                             || ' campo '||vr_nmdcampo|| ' valor recebido '||vr_vldcampo);          
                  -- Processar o próximo registro 
                  CONTINUE;
              END;   
                
              -- Ignorar Ocorrencias 1, 2, 3, 4, 5, 8 e 9
              IF  vr_cdocorre not in (01,02,03,04,05,08,09)  THEN
                -- Buscar cheques em custódia
                OPEN CR_CRAPCST(pr_cdcooper
                               ,vr_cdcmpchq
                               ,vr_cdbanchq
                               ,vr_cdagechq
                               ,vr_nrctachq
                               ,vr_nrdocmto);
                FETCH CR_CRAPCST
                 INTO RW_CRAPCST;
                -- Se não encontrar
                IF CR_CRAPCST%NOTFOUND OR RW_CRAPCST.Qtdregis > 1 THEN
                  CLOSE CR_CRAPCST;
                ELSE
                  CLOSE CR_CRAPCST;
                  -- Somente caso ocorrencia <> 0
                  IF vr_cdocorre <> 0 THEN
                    -- Atualizar custódia 
                    BEGIN
                      UPDATE CRAPCST  
                         SET flocotic = 1
                            ,cdocotic = vr_cdocorre
                       WHERE rowid = RW_CRAPCST.nrrowid;               
                    EXCEPTION
                      WHEN others THEN
                        vr_dscritic := ' Erro na atualizacao do cheque em custodia na linha '||vr_contador||' --> '||sqlerrm;
                        RAISE vr_exc_saida;
                    END; 
                    
                    -- Inserir REJ 
                    BEGIN 
                      INSERT INTO craprej (cdcooper
                                          ,nrdconta
                                          ,dtdaviso
                                          ,dtmvtolt
                                          ,nrdctitg
                                          ,nrdocmto
                                          ,vllanmto
                                          ,nrseqdig
                                          ,cdpesqbb
                                          ,dshistor
                                          ,cdcritic)
                                    VALUES(pr_cdcooper
                                          ,rw_crapcst.nrdconta
                                          ,rw_crapcst.dtlibera
                                          ,rw_crapcst.dtmvtolt
                                          ,gene0002.fn_mask(vr_nrctachq,'zzz.zzz.zzz.zzz.9')
                                          ,vr_nrdocmto -- Nro Docmto 
                                          ,rw_crapcst.vlcheque
                                          ,vr_nrseqarq --  seq  arq  
                                          ,vr_cdpesqbb
                                          ,to_char(RW_CRAPCST.cdagenci,'fm000') || ' ' ||to_char(RW_CRAPCST.cdbccxlt,'fm000') || ' ' ||gene0002.fn_mask(RW_CRAPCST.nrdolote,'zzz.zz9') 
                                          ,vr_cdocorre);
                    EXCEPTION 
                      WHEN OTHERS THEN 
                        vr_dscritic := ' Erro na criacao do registro rejeito na linha '||vr_contador||' --> '||SQLERRM;
                        RAISE vr_exc_saida;
                    END;
                  ELSE
                    vr_qtcompln := vr_qtcompln + 1;
                  END IF;
                END IF;
                
                -- Buscar borderos do cheque 
                OPEN cr_crapcdb(pr_cdcooper,
                                vr_cdcmpchq,
                                vr_cdbanchq,
                                vr_cdagechq,
                                vr_nrctachq,
                                vr_nrdocmto);
                FETCH cr_crapcdb
                 INTO rw_crapcdb;
                -- Se não encontrar
                IF CR_crapcdb%NOTFOUND OR rw_crapcdb.Qtdregis > 1 THEN
                  -- Fechar o cursor pois haverá raise
                  CLOSE CR_crapcdb;
                ELSE
                  CLOSE CR_crapcdb;
                  -- Somente se ocorrencia <> 0
                  IF vr_cdocorre <> 0 THEN
                    -- Atualizar borderô 
                    BEGIN
                      UPDATE crapcdb  
                         SET flocotic = 1
                            ,cdocotic = vr_cdocorre
                       WHERE rowid = rw_crapcdb.nrrowid;               
                    EXCEPTION
                      WHEN others THEN
                        vr_dscritic := ' Erro na atualizacao do Bordero na linha '||vr_contador||' --> '||sqlerrm;
                        RAISE vr_exc_saida;
                    END; 
                    -- Criar registro rejeito 
                    BEGIN 
                      insert into craprej(cdcooper
                                         ,nrdconta
                                         ,dtdaviso
                                         ,dtmvtolt
                                         ,nrdctitg
                                         ,nrdocmto
                                         ,vllanmto
                                         ,nrseqdig
                                         ,cdpesqbb
                                         ,dshistor
                                         ,cdcritic)
                                    values(pr_cdcooper
                                          ,rw_crapcdb.nrdconta
                                          ,rw_crapcdb.dtlibera
                                          ,rw_crapcdb.dtmvtolt
                                          ,gene0002.fn_mask(vr_nrctachq,'zzz.zzz.zzz.zzz.9')
                                          ,vr_nrdocmto -- Nro Docmto 
                                          ,rw_crapcdb.vlcheque
                                          ,vr_nrseqarq -- seq arq 
                                          ,vr_cdpesqbb
                                          ,to_char(RW_crapcdb.cdagenci,'fm000') || ' ' ||to_char(RW_crapcdb.cdbccxlt,'fm000') || ' ' ||gene0002.fn_mask(RW_crapcdb.nrdolote,'zzz.zz9')
                                          ,vr_cdocorre);
                    EXCEPTION 
                      WHEN OTHERS THEN 
                        vr_dscritic := ' Erro na criacao do registro rejeito na linha '||vr_contador||' --> '||SQLERRM;
                        RAISE vr_exc_saida;
                    END;
                  ELSE  
                    vr_qtcompln := vr_qtcompln + 1; 
                  END IF;
                END IF;
              END IF; -- Fim Ocorrencias ignoradas
            END IF; -- Fim não header ou trailler  
          END LOOP; -- Fim loop registros 
        END IF; -- Fim erro Header 
      END IF; -- Fim File IS OPEN  
      
      vr_cdcritic := 0;
      
      -- Geração Relatorio crrl626 
      vr_des_xml := NULL;
      vr_des_txt := '';
      dbms_lob.createtemporary(vr_des_xml, TRUE);
      dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);

      -- Inicilizar as informações do XML
      GENE0002.pc_escreve_xml(vr_des_xml
                             ,vr_des_txt
                             ,'<?xml version="1.0" encoding="utf-8"?><crrl626>');

      -- Buscar rejeitos no processamento do arquivos 
      for rw_craprej in cr_craprej(pr_cdcooper
                                  ,vr_dtlimite)loop
                            
        vr_flgrejei := TRUE;
        --Codigo da critica
        vr_cdcritic:= rw_craprej.cdcritic;
        
        -- Texto para as criticas 
        CASE rw_craprej.Cdcritic
          WHEN 1 THEN vr_dscritic   := 'Conta Encerrada';
          WHEN 2 THEN vr_dscritic   := 'Cheque cancelado pelo cliente';
          WHEN 3 THEN  vr_dscritic  := 'Cheque cancelado pelo Banco sacado';
          WHEN 4 THEN  vr_dscritic  := 'Cheque furtado/roubado';
          WHEN 5 THEN  vr_dscritic  := 'Cheque malote roubado';
          WHEN 6 THEN  vr_dscritic  := 'Registro inconsistente';
          WHEN 7 THEN  vr_dscritic  := 'Cheque já custodiado por outra IF';
          WHEN 8 THEN  vr_dscritic  := 'Registro duplicado pelo mesma IF';
          WHEN 9 THEN  vr_dscritic  := 'Registro para exclusao inexistente';
          WHEN 10 THEN  vr_dscritic := 'Cheque liquidado anteriormente';
          WHEN 11 THEN  vr_dscritic := 'Cheque inexistente';
          WHEN 12 THEN  vr_dscritic := 'Registro efetuado por outra IF nesta data';
        END CASE;

        GENE0002.pc_escreve_xml(vr_des_xml,vr_des_txt,'<rejeitados>
                                                          <reldspesqbb>'|| SUBSTR(rw_craprej.cdpesqbb,1,3) || ' ' ||
                                                                           SUBSTR(rw_craprej.cdpesqbb,4,3) || ' ' ||
                                                                           SUBSTR(rw_craprej.cdpesqbb,7,4) ||'</reldspesqbb>
                                                          <nrdctitg>' || rw_craprej.nrdctitg ||'</nrdctitg>
                                                          <nrdocmto>' || gene0002.fn_mask(rw_craprej.nrdocmto,'zz.zzz.zzz')||'</nrdocmto>
                                                          <vllanc>  ' || to_char(rw_craprej.vllanmto,'fm999G999G999G999G990d00')||'</vllanc>
                                                          <dtdaviso>' || to_char(rw_craprej.dtdaviso,'DD/MM/RR')  ||'</dtdaviso>
                                                          <dtmvtolt>' || to_char(rw_craprej.dtmvtolt,'DD/MM/RR')  ||'</dtmvtolt>
                                                          <nrdconta>' || GENE0002.FN_MASK_CONTA(rw_craprej.nrdconta) ||'</nrdconta>
                                                          <dshistor>' || SUBSTR(rw_craprej.dshistor,0,7)            ||'</dshistor>
                                                          <nrdolote>' || LTRIM(SUBSTR(rw_craprej.dshistor,8))       ||'</nrdolote>
                                                          <dscritic>' || vr_dscritic                                ||'</dscritic>
                                                        </rejeitados>');

      END LOOP;
      
      -- Encerrar o XML
      GENE0002.pc_escreve_xml(vr_des_xml,vr_des_txt,'</crrl626>',true);

      -- Efetuar solicitação de geração de relatório --
      gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper         --> Cooperativa conectada
                                 ,pr_cdprogra  => vr_cdprogra         --> Programa chamador
                                 ,pr_dtmvtolt  => rw_crapdat.dtmvtolt --> Data do movimento atual
                                 ,pr_dsxml     => vr_des_xml          --> Arquivo XML de dados
                                 ,pr_dsxmlnode => '/crrl626/rejeitados'    --> Nó base do XML para leitura dos dados
                                 ,pr_dsjasper  => 'crrl626.jasper'    --> Arquivo de layout do iReport
                                 ,pr_dsparams  => 'pr_dtrefer##'||to_char(vr_dtmvtolt,'dd/mm/rrrr')||'@@pr_nmarquiv##integra/'||vr_splisarq(idx)  --> Data e Arquivo
                                 ,pr_dsarqsaid => vr_dsdircop||'/rl/crrl626_' || to_char(idx,'fm00') || '.lst' --> Arquivo final com código da agência
                                 ,pr_qtcoluna  => 132                 --> 132 colunas
                                 ,pr_sqcabrel  => 1                   --> Sequencia do Relatorio {includes/cabrel132_5.i}
                                 ,pr_cdrelato  => 626                 --> Codigo do relatorio
                                 ,pr_flg_impri => 'S'                 --> Chamar a impressão (Imprim.p)
                                 ,pr_nmformul  => ''                  --> Nome do formulário para impressão
                                 ,pr_nrcopias  => 1                   --> Número de cópias
                                 ,pr_flg_gerar => 'N'                 --> gerar PDF
                                 ,pr_des_erro  => vr_dscritic);       --> Saída com erro

      -- Liberando a memória alocada pro CLOB
      dbms_lob.close(vr_des_xml);
      dbms_lob.freetemporary(vr_des_xml);
      
      -- Testar se houve erro
      IF vr_dscritic IS NOT NULL THEN
        -- Gerar exceção
        RAISE vr_exc_saida;
      END IF;      
      
      -- limpar rejeitados criados para este arquivo
      BEGIN 
        delete craprej 
         WHERE craprej.cdcooper = pr_cdcooper;
      EXCEPTION 
        WHEN OTHERS THEN 
          vr_dscritic := 'Erro na limpeza da tabela CRAPREJ --> '||sqlerrm;
      END;
      
      -- Gerar em LOG o processamento com erro ou não do arquivo
      IF vr_flgrejei THEN 
        vr_cdcritic := 191;
      ELSE 
        vr_cdcritic := 190;
      END IF;
      -- Enviar ao LOG 
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_nmarqlog     => gene0001.fn_param_sistema('CRED',pr_cdcooper,'NOME_ARQ_LOG_MESSAGE')
                                ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                 || vr_cdprogra || ' --> '
                                                 || gene0001.fn_busca_critica(vr_cdcritic) || ' --> ' 
                                                 || 'integra/'||vr_splisarq(idx));          
      
      -- Efetua a copia do arquivo para a SALVAR
      -- Se chegou neste ponto, então o processo foi OK e vamos 
      -- mover todos os arquivos da INTEGRA para SALVAR 
      gene0001.pc_OScommand_Shell(pr_des_comando => 'mv '||vr_dsdircop||'/integra/'||vr_splisarq(idx) ||' '||vr_dsdircop||'/salvar'
                                 ,pr_typ_saida   => vr_typ_saida
                                 ,pr_des_saida   => vr_dscritic);
      IF NVL(vr_typ_saida,' ') = 'ERR' THEN
        -- Desfaz alterações e inclui erro no log pois não conseguimos tirar os arquivos da INTEGRA
        RAISE vr_exc_saida;
      END IF;
      
      -- Commitar pois o arquivo já foi movido 
      COMMIT;      
   
    END LOOP;

    ----------------- ENCERRAMENTO DO PROGRAMA -------------------
    
    -- Processo OK, devemos chamar a fimprg
    btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                             ,pr_cdprogra => vr_cdprogra
                             ,pr_infimsol => pr_infimsol
                             ,pr_stprogra => pr_stprogra);

    -- Salvar informações atualizadas
    COMMIT;

  EXCEPTION
    WHEN vr_exc_fimprg THEN
      -- Se foi retornado apenas código
      IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      -- Envio centralizado de log de erro
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                 || vr_cdprogra || ' --> '
                                                 || vr_dscritic );
      -- Chamamos a fimprg para encerrarmos o processo sem parar a cadeia
      btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                               ,pr_cdprogra => vr_cdprogra
                               ,pr_infimsol => pr_infimsol
                               ,pr_stprogra => pr_stprogra);
      -- Efetuar commit
      COMMIT;
    WHEN vr_exc_saida THEN
      -- Se foi retornado apenas código
      IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      -- Devolvemos código e critica encontradas das variaveis locais
      pr_cdcritic := NVL(vr_cdcritic,0);
      pr_dscritic := vr_dscritic;
      -- Efetuar rollback
      ROLLBACK;
    WHEN OTHERS THEN
      -- Efetuar retorno do erro não tratado
      pr_cdcritic := 0;
      pr_dscritic := sqlerrm;
      -- Efetuar rollback
      ROLLBACK;

end;
/
