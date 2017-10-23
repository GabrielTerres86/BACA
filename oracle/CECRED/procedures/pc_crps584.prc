CREATE OR REPLACE PROCEDURE CECRED.pc_crps584 (pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                                              ,pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada
  BEGIN
    /* .............................................................................

       Programa: fontes/crps584.p
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Guilherme/Supero
       Data    : Novembro/2010                      Ultima atualizacao: 17/10/2017

       Dados referentes ao programa:


       Frequencia: Diario (Batch - Background).
       Objetivo  : Integra Protocolo Eletronico - Atualizacao de Cheques para
                   Processados - Tratar arquivo de retorno da Truncagem

       Alteracoes: 23/03/2011 - Incluir as atualizacoes do crapcst e crapcdb (Ze).
             
                   13/05/2011 - Acerto no tratamento do Grupo SETEC (Ze).
               
                   13/02/2012 - Alteracao para que todas as coops possam 
                                digitalizar cheques da propria cooperativa (ZE).
                            
                   15/03/2012 - Acerto no tratamento de cheques do BB na 
                                custodia/desconto (Elton).
                            
                   26/03/2012 - Faz primeiro a verificacao dos cheques da crapcdb e 
                                depois a verificacao dos cheques da crapcst (Elton).
 
          			   20/07/2016 - Alteracao do caminho onde serao salvos os arquivos
   							                de truncagem de cheque. SD 476097. Carlos R.	

               
                   05/04/2017 - Incluir dtdevolu na leitura da crapcdb e crapcst (Lucas Ranghetti #621301)
 
	                 26/05/2017 - Alterado ordem de atualizacao tabela cst e cdb (Daniel).

           			   22/08/2017 - Conversao para Progress >>>>> Oracle (Adriano)
                   
                   17/10/2017 - Ajuste para não abrir chamado ao encontrar erros, será apenas
                                efetuado log de acordo com a situação ocorrida
                                (Adriano - SD 770823).
                               
    ............................................................................ */

    DECLARE

      ------------------------ VARIAVEIS PRINCIPAIS ----------------------------

      -- Código do programa
      vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'CRPS584';

      -- Tratamento de erros
      vr_exc_saida  EXCEPTION;
      vr_exc_fimprg EXCEPTION;
      vr_cdcritic   PLS_INTEGER;
      vr_dscritic   VARCHAR2(4000);

      ------------------------------- CURSORES ---------------------------------

      -- Busca dos dados da cooperativa
      CURSOR cr_crapcop IS
      SELECT cop.nmrescop
            ,cop.nmextcop
            ,cop.cdcooper
            ,cop.cdagectl
        FROM crapcop cop
       WHERE cop.cdcooper <> 3;
         
      --Selecionar Datas de todas as cooperativas
      CURSOR cr_crapdat_cooper IS
      SELECT crapdat.cdcooper
            ,crapdat.dtmvtolt
        FROM crapdat;  
            
      --Variaveis para Diretorios
      vr_nmdireto VARCHAR2(100);
      
      --Tipo de Tabela para Diretorio Salvar
      TYPE typ_tab_salvar IS TABLE OF VARCHAR2(100) INDEX BY PLS_INTEGER;
      
      --Tipo de Tabela de Datas
      TYPE typ_tab_crapdat IS TABLE OF DATE INDEX BY PLS_INTEGER;
    
      --Tabela de Datas por Cooperativa
      vr_tab_crapdat   typ_tab_crapdat; 
      
      --Tabela de Diretorios
      vr_tab_salvar    typ_tab_salvar;
      vr_tab_dircoop   typ_tab_salvar;
      
      --Tabela para receber arquivos lidos no unix
      vr_tab_crawarq TYP_SIMPLESTRINGARRAY:= TYP_SIMPLESTRINGARRAY();
      
      vr_input_file utl_file.file_type; --> Variavel do arquivo
      vr_setlinha VARCHAR2(4000);       --> Linha do arquivo
      
      --Variáveis locais
      vr_idprglog NUMBER;
      vr_nmarquiv VARCHAR2(100);      
      vr_comando  VARCHAR2(1000);
      vr_typ_saida VARCHAR2(3);
      vr_dtarquiv DATE;
      vr_cdbanchq crapchd.cdbanchq%TYPE;
      vr_cdagechq crapchd.cdagechq%TYPE;
      vr_cdcmpchq crapchd.cdcmpchq%TYPE;
      vr_nrcheque crapchd.nrcheque%TYPE;
      vr_nrctachq crapchd.nrctachq%TYPE;
      vr_qtarquiv INTEGER;
      vr_des_reto VARCHAR2(3);
      vr_flarqerr BOOLEAN := FALSE;
      
      --Variaveis de controle de exceção
      vr_exc_prox_arq EXCEPTION;
      vr_exc_continua EXCEPTION;

    BEGIN

      cecred.pc_log_programa(pr_dstiplog   => 'I', 
                             pr_cdprograma => vr_cdprogra,
                             pr_tpexecucao => 2, -- job
                             pr_idprglog   => vr_idprglog);
                             
      -- Incluir nome do módulo logado
      GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra
                                ,pr_action => null);
                                
      --Carregar tabela de datas
      FOR rw_crapdat_cooper IN cr_crapdat_cooper LOOP
          
        vr_tab_crapdat(rw_crapdat_cooper.cdcooper):= rw_crapdat_cooper.dtmvtolt;
          
        --Montar Diretorio Padrao de cada cooperativa    
        vr_tab_dircoop(rw_crapdat_cooper.cdcooper):= gene0001.fn_diretorio (pr_tpdireto => 'C' --> Usr/Coop
                                                                           ,pr_cdcooper => rw_crapdat_cooper.cdcooper
                                                                           ,pr_nmsubdir => 'integra');

        --Montar Diretorio Salvar de cada cooperativa
        vr_tab_salvar(rw_crapdat_cooper.cdcooper):= gene0001.fn_diretorio (pr_tpdireto => 'C' --> Usr/Coop
                                                                          ,pr_cdcooper => rw_crapdat_cooper.cdcooper
                                                                          ,pr_nmsubdir => '') || 
                                                                           '/salvar/truncagem';
          
      END LOOP;
         
      FOR rw_crapcop IN cr_crapcop LOOP
        
        -- Leitura do calendário da cooperativa
        IF NOT vr_tab_crapdat.EXISTS(rw_crapcop.cdcooper) THEN                
                 
          -- Envio centralizado de log de erro
          btch0001.pc_gera_log_batch(pr_cdcooper     => 3
                                    ,pr_ind_tipo_log => 2 -- Erro tratado
                                    ,pr_nmarqlog     => gene0001.fn_param_sistema('CRED',0,'NOME_ARQ_LOG_MESSAGE')
                                    ,pr_des_log      => to_char(SYSDATE,
                                                                'hh24:mi:ss') ||
                                                        ' - ' || vr_cdprogra ||
                                                        ' -->  Cooperativa: ' || rw_crapcop.nmrescop || 
                                                        ' - Sem data de sistema(crapdat).'
                                    ,pr_cdcriticidade => 3);
                               
          CONTINUE;
          
        END IF;
        
        --Buscar Diretorio Cooperativa
        vr_nmdireto:= vr_tab_dircoop(rw_crapcop.cdcooper);
        
        --Nome Arquivo filtrar
        vr_nmarquiv:= 'R' || trim(to_char(rw_crapcop.cdagectl,'0000')) || 
                      (CASE to_char(vr_tab_crapdat(rw_crapcop.cdcooper),'MM') 
                         WHEN '10' THEN
                           'O'
                         WHEN '11' THEN
                           'N'
                         WHEN '12' THEN
                           'D'
                         ELSE
                           to_char(to_number(to_char(vr_tab_crapdat(rw_crapcop.cdcooper),'MM')))
                        END) 
                       || to_char(vr_tab_crapdat(rw_crapcop.cdcooper),'DD') || '.%';

        --Buscar a lista de arquivos do diretorio
        gene0001.pc_lista_arquivos(pr_lista_arquivo => vr_tab_crawarq
                                  ,pr_path          => vr_nmdireto
                                  ,pr_pesq          => vr_nmarquiv);                                  
                                  
        vr_qtarquiv:= vr_tab_crawarq.COUNT();                                  

        /* EFETUA A LEITURA DE CADA ARQUIVO DA PASTA INTEGRA */
        FOR idx IN 1..vr_qtarquiv LOOP
         
          --Inicializa variável
          vr_flarqerr :=FALSE;
          
          BEGIN 
            /* o comando abaixo ignora quebras de linha atraves do 'grep -v' e o 'tail -1' retorna
               a ultima linha do resultado do grep */
            vr_comando:= 'grep -v '||'''^$'' '||vr_nmdireto||'/'||vr_tab_crawarq(idx)||'| tail -1';

            --Executar o comando no unix
            GENE0001.pc_OScommand(pr_typ_comando => 'S'
                                 ,pr_des_comando => vr_comando
                                 ,pr_typ_saida   => vr_typ_saida
                                 ,pr_des_saida   => vr_setlinha);
                                  
            --Se ocorreu erro dar RAISE
            IF vr_typ_saida = 'ERR' THEN
              vr_dscritic:= 'Nao foi possivel executar comando unix. '||vr_comando;
              
              RAISE vr_exc_continua;
              
            END IF;
                   
            --Verificar se a ultima linha é o Trailer
            IF SUBSTR(vr_setlinha,01,10) <> '9999999999' THEN  
              vr_cdcritic:= 258;
              vr_dscritic:= gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
                                   
              RAISE vr_exc_continua;          
               
            END IF;
            
            -- Abre o arquivo
            gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto            --> Diretorio do arquivo
                                    ,pr_nmarquiv => vr_tab_crawarq(idx)    --> Nome do arquivo
                                    ,pr_tipabert => 'R'                    --> Modo de abertura (R,W,A)
                                    ,pr_flaltper => 0                      --> Altera permissão de acesso do arquivo (0 - Não altera / 1 - Altera)                                  
                                    ,pr_utlfileh => vr_input_file          --> Handle do arquivo aberto
                                    ,pr_des_erro => vr_dscritic);          --> Erro
                                    
            IF vr_dscritic IS NOT NULL THEN
              
              RAISE vr_exc_continua;
                
            END IF;
            
            -- Ler a linha do arquivo.
            gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                        ,pr_des_text => vr_setlinha); --> Texto lido
                                        
            --Verificar se o arquivo inicia correto
            IF SUBSTR(vr_setlinha,01,10) <> '0000000000' THEN  
              vr_cdcritic:= 468;
              vr_dscritic:= gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
              
              RAISE vr_exc_continua;
               
            END IF;            
            
            BEGIN
        
              vr_dtarquiv:= to_date(SUBSTR(vr_setlinha,66,8),'RRRR/MM/DD');
                
            EXCEPTION
              WHEN OTHERS THEN
                -- Montar mensagem de critica
                vr_dscritic := 'Data do arquivo invalida.';
                  
                RAISE vr_exc_continua;
                  
            END;            
            
          EXCEPTION
            WHEN vr_exc_continua THEN
              
              gene0001.pc_fecha_arquivo(pr_utlfileh => vr_input_file);
              
              -- Envio centralizado de log de erro
              btch0001.pc_gera_log_batch(pr_cdcooper     => 3
                                        ,pr_ind_tipo_log => 2 -- Erro tratado
                                        ,pr_nmarqlog     => gene0001.fn_param_sistema('CRED',0,'NOME_ARQ_LOG_MESSAGE')
                                        ,pr_des_log      => to_char(SYSDATE,
                                                                    'hh24:mi:ss') ||
                                                            ' - ' || vr_cdprogra ||
                                                            ' --> ' || vr_dscritic || 
                                                            '- Arquivo: ' || vr_tab_crawarq(idx) || 
                                                            '.'
                                        ,pr_cdcriticidade => 3);
                                    
              --Move o arquivo XML fisico de envio
              GENE0001.pc_OScommand (pr_typ_comando => 'S'
                                    ,pr_des_comando => 'mv '||vr_nmdireto||'/'||vr_tab_crawarq(idx)||' '||vr_tab_salvar(rw_crapcop.cdcooper)||'/ERRO_'|| vr_tab_crawarq(idx) ||' 2> /dev/null'
                                    ,pr_typ_saida   => vr_des_reto
                                    ,pr_des_saida   => vr_dscritic);
                                        
              --Se ocorreu erro dar RAISE
              IF vr_des_reto = 'ERR' THEN
                RAISE vr_exc_saida;
              END IF; 
             
              CONTINUE;
            
            WHEN OTHERS THEN
              
              cecred.pc_internal_exception(3); 
            
              gene0001.pc_fecha_arquivo(pr_utlfileh => vr_input_file);
              
              vr_dscritic:='Nao foi possivel efetuar as validacoes iniciais do arquivo: ' || SQLERRM;
              
              -- Envio centralizado de log de erro
              btch0001.pc_gera_log_batch(pr_cdcooper     => 3
                                        ,pr_ind_tipo_log => 3 -- Erro não tratado
                                        ,pr_nmarqlog     => gene0001.fn_param_sistema('CRED',0,'NOME_ARQ_LOG_MESSAGE')
                                        ,pr_des_log      => to_char(SYSDATE,
                                                                    'hh24:mi:ss') ||
                                                            ' - ' || vr_cdprogra ||
                                                            ' --> ' || vr_dscritic || 
                                                            '- Arquivo: ' || vr_tab_crawarq(idx) || 
                                                            '.'
                                        ,pr_cdcriticidade => 3);
                     
              --Move o arquivo XML fisico de envio
              GENE0001.pc_OScommand (pr_typ_comando => 'S'
                                    ,pr_des_comando => 'mv '||vr_nmdireto||'/'||vr_tab_crawarq(idx)||' '||vr_tab_salvar(rw_crapcop.cdcooper)||'/ERRO_'|| vr_tab_crawarq(idx) ||' 2> /dev/null'
                                    ,pr_typ_saida   => vr_des_reto
                                    ,pr_des_saida   => vr_dscritic);
                                        
              --Se ocorreu erro dar RAISE
              IF vr_des_reto = 'ERR' THEN
                RAISE vr_exc_saida;
              END IF;
             
              CONTINUE;
              
          END;
          
          LOOP

            BEGIN
              -- Ler a linha do arquivo.
              gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                          ,pr_des_text => vr_setlinha); --> Texto lido
                                                
            EXCEPTION
              WHEN OTHERS THEN -- Chegou ao final do arquivo
                  
                EXIT;
            END;

            IF SUBSTR(vr_setlinha,1,10) = '9999999999'  THEN
              
              CONTINUE;
              
            END IF;
            
            BEGIN  
               
              /* 04 a 06 - Numero do Banco   */
              /* 07 a 10 - Numero da Agencia */
              /* 01 a 03 - Codigo da Compe   */
              /* 25 a 30 - Numero do Cheque  */
              BEGIN
                  
                vr_cdbanchq := to_number(SUBSTR(vr_setlinha,4,3));
                vr_cdagechq := to_number(SUBSTR(vr_setlinha,7,4));
                vr_cdcmpchq := to_number(SUBSTR(vr_setlinha,1,3));
                vr_nrcheque := to_number(SUBSTR(vr_setlinha,25,6));
                vr_nrctachq := to_number(SUBSTR(vr_setlinha,12,12));
                
              EXCEPTION
                WHEN OTHERS THEN
                  -- Montar mensagem de critica
                  vr_dscritic := 'Dados invalidos encontrados na linha: ' || vr_setlinha;
                  
                  RAISE vr_exc_prox_arq;
                  
              END;

              BEGIN
                  
                UPDATE crapchd 
                   SET crapchd.insitprv = 3
                 WHERE crapchd.cdcooper = rw_crapcop.cdcooper 
                   AND crapchd.dtmvtolt = vr_dtarquiv
                   AND crapchd.cdcmpchq = vr_cdcmpchq
                   AND crapchd.cdbanchq = vr_cdbanchq
                   AND crapchd.cdagechq = vr_cdagechq
                   AND crapchd.nrctachq = vr_nrctachq
                   AND crapchd.nrcheque = vr_nrcheque;                   
                   
              EXCEPTION   
                WHEN OTHERS THEN
                  
                  -- Montar mensagem de critica
                  vr_dscritic := 'Erro ao atualizar a situacao do cheque (1): '|| SQLERRM;
                      
                  RAISE vr_exc_prox_arq;
                
              END;
                  
              -- Caso não exista o registro de cheque
              IF SQL%ROWCOUNT = 0 THEN 
                  
                /* Trata Grupo SETEC */
                IF vr_cdbanchq = 1    AND
                   vr_cdagechq = 3420 THEN
                     
                  vr_nrctachq := to_number('0070' || SUBSTR(vr_setlinha,16,08));
                  
                END IF;
                  
                BEGIN
                  
                  UPDATE crapchd 
                     SET crapchd.insitprv = 3
                   WHERE crapchd.cdcooper = rw_crapcop.cdcooper 
                     AND crapchd.dtmvtolt = vr_dtarquiv
                     AND crapchd.cdcmpchq = vr_cdcmpchq
                     AND crapchd.cdbanchq = vr_cdbanchq
                     AND crapchd.cdagechq = vr_cdagechq
                     AND crapchd.nrctachq = vr_nrctachq
                     AND crapchd.nrcheque = vr_nrcheque;
                       
               EXCEPTION 
                 WHEN OTHERS THEN
                   -- Montar mensagem de critica
                   vr_dscritic := 'Erro ao atualizar a situacao do cheque (2): '|| SQLERRM;
                          
                   RAISE vr_exc_prox_arq;
                    
                END;
                      
                -- Caso não exista o registro de cheque
                IF SQL%ROWCOUNT = 0 THEN 
                     
                  IF vr_cdbanchq = 1    AND
                     vr_cdagechq = 3420 THEN
                       
                    vr_nrctachq := to_number(SUBSTR(vr_setlinha,16,08));
                    
                  END IF;  
                    
                  BEGIN
                  
                    UPDATE crapchd 
                       SET crapchd.insitprv = 3
                     WHERE crapchd.cdcooper = rw_crapcop.cdcooper 
                       AND crapchd.dtmvtolt = vr_dtarquiv
                       AND crapchd.cdcmpchq = vr_cdcmpchq
                       AND crapchd.cdbanchq = vr_cdbanchq
                       AND crapchd.cdagechq = vr_cdagechq
                       AND crapchd.nrctachq = vr_nrctachq
                       AND crapchd.nrcheque = vr_nrcheque;
                         
                  EXCEPTION
                    WHEN OTHERS THEN
                      -- Montar mensagem de critica
                      vr_dscritic := 'Erro ao atualizar a situacao do cheque (3): '|| SQLERRM;
                            
                      RAISE vr_exc_prox_arq;
                      
                  END;
                        
                  -- Caso não exista o registro de cheque
                  IF SQL%ROWCOUNT = 0 THEN 
                    
                    --Desconto de cheque
                    IF vr_cdbanchq = 1 THEN
                         
                      vr_nrctachq := to_number(SUBSTR(vr_setlinha,16,08));
                      
                    END IF;
                       
                    BEGIN
                  
                      UPDATE crapcst 
                         SET crapcst.insitprv = 3
                       WHERE crapcst.cdcooper = rw_crapcop.cdcooper 
                         AND crapcst.cdcmpchq = vr_cdcmpchq     
                         AND crapcst.cdbanchq = vr_cdbanchq     
                         AND crapcst.cdagechq = vr_cdagechq      
                         AND crapcst.nrctachq = vr_nrctachq     
                         AND crapcst.nrcheque = vr_nrcheque     
                         AND crapcst.dtdevolu IS NULL;
                           
                    EXCEPTION
                      WHEN OTHERS THEN
                        -- Montar mensagem de critica
                        vr_dscritic := 'Erro ao atualizar a situacao do cheque (4): '|| SQLERRM;
                              
                        RAISE vr_exc_prox_arq;
                        
                    END;
                      
                    -- Caso não exista o registro de custódia
                    IF SQL%ROWCOUNT = 0 THEN 
                      
                      IF vr_cdbanchq = 1 THEN
                          
                        vr_nrctachq := to_number(substr(vr_setlinha,13,11));
                          
                      ELSE
                          
                        vr_nrctachq := to_number(substr(vr_setlinha,12,12));
                          
                      END IF;
                        
                      BEGIN
                  
                        UPDATE crapcst 
                           SET crapcst.insitprv = 3
                         WHERE crapcst.cdcooper = rw_crapcop.cdcooper 
                           AND crapcst.cdcmpchq = vr_cdcmpchq     
                           AND crapcst.cdbanchq = vr_cdbanchq     
                           AND crapcst.cdagechq = vr_cdagechq      
                           AND crapcst.nrctachq = vr_nrctachq     
                           AND crapcst.nrcheque = vr_nrcheque     
                           AND crapcst.dtdevolu IS NULL;                             
                        
                      EXCEPTION
                        WHEN OTHERS THEN
                          -- Montar mensagem de critica
                          vr_dscritic := 'Erro ao atualizar a situacao do cheque (5): '|| SQLERRM;
                                
                          RAISE vr_exc_prox_arq;
                          
                      END;
                        
                      -- Caso não exista o registro de custódia
                      IF SQL%ROWCOUNT = 0 THEN 
                          
                        IF vr_cdbanchq = 1 THEN
                          
                          vr_nrctachq := to_number(substr(vr_setlinha,16,08));  
                            
                        END IF;
                          
                        BEGIN
                  
                          UPDATE crapcdb 
                             SET crapcdb.insitprv = 3
                           WHERE crapcdb.cdcooper = rw_crapcop.cdcooper 
                             AND crapcdb.cdcmpchq = vr_cdcmpchq     
                             AND crapcdb.cdbanchq = vr_cdbanchq     
                             AND crapcdb.cdagechq = vr_cdagechq     
                             AND crapcdb.nrctachq = vr_nrctachq     
                             AND crapcdb.nrcheque = vr_nrcheque     
                             AND crapcdb.dtdevolu IS NULL;
                               
                        EXCEPTION
                          WHEN OTHERS THEN
                            -- Montar mensagem de critica
                            vr_dscritic := 'Erro ao atualizar a situacao do cheque (6): '|| SQLERRM;
                                  
                            RAISE vr_exc_prox_arq;
                            
                        END;
                          
                        -- Caso não exista o registro de custódia
                        IF SQL%ROWCOUNT = 0 THEN 
                          
                          IF vr_cdbanchq = 1 THEN
                              
                            vr_nrctachq := to_number(substr(vr_setlinha,13,11));
                              
                          ELSE
                            
                            vr_nrctachq := TO_number(substr(vr_setlinha,12,12));
                            
                          END IF;    
                          
                          BEGIN
                  
                            UPDATE crapcdb 
                               SET crapcdb.insitprv = 3
                             WHERE crapcdb.cdcooper = rw_crapcop.cdcooper 
                               AND crapcdb.cdcmpchq = vr_cdcmpchq     
                               AND crapcdb.cdbanchq = vr_cdbanchq     
                               AND crapcdb.cdagechq = vr_cdagechq     
                               AND crapcdb.nrctachq = vr_nrctachq     
                               AND crapcdb.nrcheque = vr_nrcheque     
                               AND crapcdb.dtdevolu IS NULL;
                                 
                          EXCEPTION
                            WHEN OTHERS THEN
                              -- Montar mensagem de critica
                              vr_dscritic := 'Erro ao atualizar a situacao do cheque (7): '|| SQLERRM;
                                    
                              RAISE vr_exc_prox_arq;
                              
                          END; 
                            
                        END IF;
                          
                      END IF;
                        
                    END IF;
                            
                  END IF;
                    
                END IF;
             
              END IF;
            
            EXCEPTION
              WHEN vr_exc_prox_arq THEN
                
                --Efetua o rollback das infoamções do arquivo processado com inconsistencias                                           
                ROLLBACK;
                
                vr_flarqerr :=TRUE;
                
                -- Envio centralizado de log de erro
                btch0001.pc_gera_log_batch(pr_cdcooper     => 3
                                          ,pr_ind_tipo_log => 2 -- Erro tratado
                                          ,pr_nmarqlog     => gene0001.fn_param_sistema('CRED',0,'NOME_ARQ_LOG_MESSAGE')
                                          ,pr_des_log      => to_char(SYSDATE,
                                                                      'hh24:mi:ss') ||
                                                              ' - ' || vr_cdprogra ||
                                                              ' --> ' || vr_dscritic || 
                                                              ' - Cooperativa: ' || rw_crapcop.nmrescop ||
                                                              ' - Arquivo: ' || vr_tab_crawarq(idx) || 
                                                              '.'
                                          ,pr_cdcriticidade => 3);
                                      
                EXIT;
              
              WHEN OTHERS THEN
                
                --Efetua o rollback das infoamções do arquivo processado com inconsistencias
                ROLLBACK;
                
                vr_flarqerr :=TRUE;
                
                -- Envio centralizado de log de erro
                btch0001.pc_gera_log_batch(pr_cdcooper     => 3
                                          ,pr_ind_tipo_log => 3 -- Erro não tratado
                                          ,pr_nmarqlog     => gene0001.fn_param_sistema('CRED',0,'NOME_ARQ_LOG_MESSAGE')
                                          ,pr_des_log      => to_char(SYSDATE,
                                                                      'hh24:mi:ss') ||
                                                              ' - ' || vr_cdprogra ||
                                                              ' --> Cooperativa: ' || rw_crapcop.nmrescop ||
                                                              ' - Arquivo: ' || vr_tab_crawarq(idx) || 
                                                              ' - Erro ao ler arquivo -->  ' || SQLERRM || '.'
                                          ,pr_cdcriticidade => 3);
                
                EXIT;
                    
            END;    
            
          END LOOP;
           
          gene0001.pc_fecha_arquivo(pr_utlfileh => vr_input_file);
          
          --Se encntrou algum erro durante o processamento
          IF vr_flarqerr THEN
            
            --Move o arquivo XML fisico de envio
            GENE0001.pc_OScommand (pr_typ_comando => 'S'
                                  ,pr_des_comando => 'mv '||vr_nmdireto||'/'||vr_tab_crawarq(idx)||' '||vr_tab_salvar(rw_crapcop.cdcooper)||'/ERRO_'|| vr_tab_crawarq(idx) ||' 2> /dev/null'
                                  ,pr_typ_saida   => vr_des_reto
                                  ,pr_des_saida   => vr_dscritic);
                                      
            --Se ocorreu erro dar RAISE
            IF vr_des_reto = 'ERR' THEN
              RAISE vr_exc_saida;
            END IF;
                
          ELSE
            
            --Move o arquivo XML fisico de envio
            GENE0001.pc_OScommand (pr_typ_comando => 'S'
                                  ,pr_des_comando => 'mv '||vr_nmdireto||'/'||vr_tab_crawarq(idx)||' '||vr_tab_salvar(rw_crapcop.cdcooper)||' 2> /dev/null'
                                  ,pr_typ_saida   => vr_des_reto
                                  ,pr_des_saida   => vr_dscritic);
                                  
            --Se ocorreu erro dar RAISE
            IF vr_des_reto = 'ERR' THEN
              RAISE vr_exc_saida;
            END IF;
          
          END IF;
          
          -- Salvar informações atualizadas por aquivo processado
          COMMIT;

        END LOOP;
                                                        
      END LOOP;
      
      cecred.pc_log_programa(pr_dstiplog   => 'F', 
                             pr_cdprograma => vr_cdprogra,
                             pr_idprglog   => vr_idprglog);
      
    EXCEPTION
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
        
        -- Envio centralizado de log de erro
        btch0001.pc_gera_log_batch(pr_cdcooper     => 3
                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                  ,pr_nmarqlog     => gene0001.fn_param_sistema('CRED',0,'NOME_ARQ_LOG_MESSAGE')
                                  ,pr_des_log      => to_char(SYSDATE,
                                                              'hh24:mi:ss') ||
                                                      ' - ' || vr_cdprogra ||
                                                      ' --> ' || pr_dscritic
                                  ,pr_cdcriticidade => 3);

        cecred.pc_log_programa(pr_dstiplog   => 'F' 
                              ,pr_cdprograma => vr_cdprogra
                              ,pr_flgsucesso => 0
                              ,pr_idprglog   => vr_idprglog);
        
      WHEN OTHERS THEN
        
        cecred.pc_internal_exception(3); 
      
        -- Efetuar retorno do erro não tratado
        pr_cdcritic := 0;
        pr_dscritic := sqlerrm;
        -- Efetuar rollback
        ROLLBACK;
        
        -- Envio centralizado de log de erro
        btch0001.pc_gera_log_batch(pr_cdcooper     => 3
                                  ,pr_ind_tipo_log => 3 -- Erro não tratato
                                  ,pr_nmarqlog     => gene0001.fn_param_sistema('CRED',0,'NOME_ARQ_LOG_MESSAGE')
                                  ,pr_des_log      => to_char(SYSDATE,
                                                              'hh24:mi:ss') ||
                                                      ' - ' || vr_cdprogra ||
                                                      ' --> ' || pr_dscritic
                                  ,pr_cdcriticidade => 3);

       cecred.pc_log_programa(pr_dstiplog   => 'F' 
                             ,pr_cdprograma => vr_cdprogra
                             ,pr_flgsucesso => 0
                             ,pr_idprglog   => vr_idprglog);
                              
    END;

  END pc_crps584;
/
