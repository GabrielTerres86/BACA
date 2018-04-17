CREATE OR REPLACE PROCEDURE CECRED.pc_crps625(pr_cdcooper  IN crapcop.cdcooper%TYPE --> Cooperativa solicitada
                                             ,pr_flgresta  IN PLS_INTEGER           --> Flag padrão para utilização de restart
                                             ,pr_nmtelant  IN VARCHAR2              --> Nome de tela anterior
                                             ,pr_stprogra OUT PLS_INTEGER           --> Saída de termino da execução
                                             ,pr_infimsol OUT PLS_INTEGER           --> Saída de termino da solicitação
                                             ,pr_cdcritic OUT crapcri.cdcritic%TYPE --> Critica encontrada
                                             ,pr_dscritic OUT VARCHAR2) IS          --> Texto de erro/critica encontrada
  BEGIN
  
    /* .............................................................................

       Programa: pc_crps625 (Fontes/crps625.p)
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : André Santos/Supero
       Data    : Agosto/2012                     Ultima atualizacao: 20/03/2018

       Dados referentes ao programa:

       Frequencia: Diario (Batch)
       Objetivo  : Integrar/Gerar arquivos TIC
                   Recebe arquivo TIC614 gera TIC606

       Alteracoes: 13/08/2012 - Primeira Versao

                   24/10/2012 - Alterar Agencia Apresentante para Depositante (Ze).

                   25/02/2013 - Alterado estrutura da procedure p_elimina_tic.
                                (Fabricio)

                   12/08/2014 - Ajustes na geracao do arquivo TIC606 para
                                tratar a Unificacao das SIRC's; 018.
                                (Chamado 146058) - (Fabricio)

                   29/05/2015 - Conversao Progress >> Oracle (Jean Michel).
                   
                   22/07/2016 - Finalização do conversão PLSQL (Jonata-Rkam)
                   
                   02/01/2017 - #530616 Corrigido o programa para verificar se há mais informações na pltable além das 
                                linhas de cabeçalho e trailler do arquivo, para não gerar o mesmo desnecessariamente (Carlos)
                   
                   20/03/2018 - #RITM0010364 Mover arquivo apenas quando não ocorrer crítica de erro no layout pois as mesmas
                                renomeiam o arquivo para ERR_ (Carlos)                   
    ............................................................................ */

    DECLARE

      -- Temp tables
      TYPE typ_reg_tic606 IS
        RECORD(nrsequen PLS_INTEGER
              ,dsdlinha VARCHAR2(201)
              ,cdocorre PLS_INTEGER
              ,dsdocmc7 crapfdc.dsdocmc7%TYPE
              ,cdcmpdes PLS_INTEGER
              ,cdbcodes PLS_INTEGER
              ,cdtipdoc PLS_INTEGER
              ,cdcomchq PLS_INTEGER
              ,cdbcoctl PLS_INTEGER);

      -- Tipo de tabela para PlTable de seguros
      TYPE typ_tab_tic606 IS
        TABLE OF typ_reg_tic606
        INDEX BY VARCHAR2(19); --cdcmpdes(3)+cdbcodes(3)+cdtipdoc(3)+nrsequen(10)

      -- Tabela temporaria
      vr_tab_tic606 typ_tab_tic606;    
      vr_chv_tic606 VARCHAR2(19);    

      -- Código do programa
      vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'CRPS625';

      -- Tratamento de erros
      vr_exc_saida  EXCEPTION;
      vr_exc_fimprg EXCEPTION;
      vr_fecha_arq  EXCEPTION;
      vr_cdcritic   PLS_INTEGER;
      vr_dscritic   VARCHAR2(4000);
      vr_flarqerr   PLS_INTEGER := 0;

      -- Variaveis locais
      vr_dtanmarq crapdat.dtmvtolt%TYPE;
      vr_dtmvtolt crapdat.dtmvtolt%TYPE;
      vr_dsauxmes VARCHAR2(2)    := '';
      vr_dsauxmesan VARCHAR2(2)    := '';
      vr_typ_said VARCHAR2(3)    := '';
      vr_dtauxili VARCHAR2(8)    := '';
      vr_dtretarq VARCHAR2(8)    := '';
      vr_nmarquiv VARCHAR2(100)  := '';
      vr_nmarqdat VARCHAR2(100)  := '';
       
      -- Valores das linhas
      vr_nrdocmto PLS_INTEGER;
      vr_nrseqarq PLS_INTEGER;
      vr_cdocorre PLS_INTEGER;
      vr_cdbanchq craplcm.cdbanchq%TYPE;
      vr_cdcmpchq craplcm.cdcmpchq%TYPE;
      vr_cdagechq craplcm.cdagechq%TYPE;
      vr_nrctachq craplcm.nrctachq%TYPE;
      vr_flgdsede PLS_INTEGER;
      vr_cdtipdoc PLS_INTEGER;
      vr_cdbanapr PLS_INTEGER;
      vr_cdageapr PLS_INTEGER;
      vr_nrctaapr craplcm.nrctachq%TYPE;
      vr_dtlibtic DATE;
      vr_dsdocmc7 crapfdc.dsdocmc7%TYPE;
      vr_dslibchq VARCHAR2(8);
      
      -- Totais do DAT
      vr_vltolarq NUMBER(18,2);
      vr_vltotlot NUMBER(18,2);
      vr_contareg PLS_INTEGER;
      vr_qttotlot PLS_INTEGER;
      
      -- Diretorios das cooperativas
      vr_caminho_coopera VARCHAR2(200);
      vr_caminho_integra VARCHAR2(200);
      vr_caminho_salvar  VARCHAR2(200);
      vr_caminho_arq     VARCHAR2(200);
      vr_caminho_micros  VARCHAR2(200);

      -- Handle para o arquivo de log
      vr_file_handle UTL_FILE.file_type;
      vr_dsctexto VARCHAR2(4000) := '';

      -- Busca dos dados da cooperativa
      CURSOR cr_crapcop IS
        SELECT cop.nmrescop
              ,cop.nmextcop
              ,cop.cdagectl
              ,cop.cdbcoctl
          FROM crapcop cop
         WHERE cop.cdcooper = pr_cdcooper;
      rw_crapcop cr_crapcop%ROWTYPE;

      -- Busca PA's
      CURSOR cr_crapage IS
        SELECT age.cdcomchq
          FROM crapage age
         WHERE age.cdcooper = pr_cdcooper
           AND age.flgdsede = 1;
      rw_crapage cr_crapage%ROWTYPE;
      
      -- Busca folhas de cheque
      CURSOR cr_crapfdc(pr_cdbanchq crapfdc.cdbanchq%TYPE
                       ,pr_cdagechq crapfdc.cdagechq%TYPE
                       ,pr_nrctachq crapfdc.nrctachq%TYPE
                       ,pr_nrdocmto crapfdc.nrcheque%TYPE) IS
        SELECT ROWID
              ,incheque
              ,dtliqchq
              ,cdbantic
              ,cdagetic
              ,nrctatic
              ,cdbanchq
              ,cdagechq
              ,nrctachq
              ,dsdocmc7
          FROM crapfdc
         WHERE crapfdc.cdcooper = pr_cdcooper 
           AND crapfdc.cdbanchq = pr_cdbanchq  /* Nr Bco   */
           AND crapfdc.cdagechq = pr_cdagechq  /* Age dest */
           AND crapfdc.nrctachq = pr_nrctachq  /* Nr ctachq*/
           AND crapfdc.nrcheque = pr_nrdocmto; /* Nro chq  */
      rw_crapfdc cr_crapfdc%ROWTYPE;
      
      -- Teste de existencia de ocorrências
      CURSOR cr_crapcor(pr_cdbanchq crapcor.cdbanchq%TYPE
                       ,pr_cdagechq crapcor.cdagechq%TYPE
                       ,pr_nrctachq crapcor.nrctachq%TYPE
                       ,pr_nrdocmto crapcor.nrcheque%TYPE) IS
        SELECT cdhistor
          FROM crapcor
         WHERE cdcooper = pr_cdcooper
           AND cdbanchq = pr_cdbanchq  /* Nr Bco   */
           AND cdagechq = pr_cdagechq  /* Age dest */
           AND nrctachq = pr_nrctachq  /* Nr ctachq*/
           AND nrcheque = pr_nrdocmto  /* Nro chq  */    
           AND flgativo = 1;
      vr_cdhistor crapcor.cdhistor%TYPE;                    
                        
      -- Teste de existência na crapass
      CURSOR cr_crapass(pr_nrdconta crapass.nrdconta%TYPE) IS
        SELECT 1
          FROM crapass
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta;
      rw_crapass cr_crapass%ROWTYPE;
      
      -- Cursor genérico de calendário
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;

      -- Subrotina para excluir registro de folhas de cheque
      PROCEDURE pc_elimina_tic IS
      BEGIN
        UPDATE crapfdc
           SET crapfdc.cdbantic = 0
              ,crapfdc.cdagetic = 0
              ,crapfdc.nrctatic = 0
              ,crapfdc.dtlibtic = NULL
              ,crapfdc.dtatutic = NULL
              ,CDAGEACO = 90
          WHERE crapfdc.cdcooper = pr_cdcooper   
            AND crapfdc.incheque BETWEEN 0 AND 9 
            AND crapfdc.dtlibtic < rw_crapdat.dtmvtolt;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao atualizar CRAPFDC. Erro: ' || SQLERRM;
          RAISE vr_exc_saida;
      END;

    BEGIN

      -- Incluir nome do módulo logado
      GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra
                                ,pr_action => NULL);

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
      IF vr_cdcritic <> 0 THEN
        -- Envio centralizado de log de erro
        RAISE vr_exc_saida;
      END IF;

      -- Laitura de PA's
      OPEN cr_crapage;
      FETCH cr_crapage INTO rw_crapage;
      IF cr_crapage%NOTFOUND THEN
        -- Fecha cursor
        CLOSE cr_crapage;
        vr_flgdsede := 16;
      ELSE
        -- Fecha cursor
        CLOSE cr_crapage;
        vr_flgdsede := rw_crapage.cdcomchq;
      END IF;

      -- Verifica nome da tela anterior
      IF pr_nmtelant = 'COMPEFORA' THEN
        vr_dtauxili := TO_CHAR(rw_crapdat.dtmvtoan,'RRRRmmdd');
        vr_dtmvtolt := rw_crapdat.dtmvtoan;
        vr_dtretarq := TO_CHAR(rw_crapdat.dtmvtolt,'RRRRmmdd');
        vr_dtanmarq := rw_crapdat.dtmvtolt;
      ELSE
        vr_dtauxili := TO_CHAR(rw_crapdat.dtmvtolt,'RRRRmmdd');
        vr_dtmvtolt := rw_crapdat.dtmvtolt;
        vr_dtretarq := TO_CHAR(rw_crapdat.dtmvtopr,'RRRRmmdd');
        vr_dtanmarq := rw_crapdat.dtmvtopr;
      END IF;

      -- Verificacao de mes
      IF TO_CHAR(vr_dtmvtolt,'mm') > 9 THEN
        CASE TO_CHAR(vr_dtmvtolt,'mm')
          WHEN 10 THEN vr_dsauxmes := 'O';
          WHEN 11 THEN vr_dsauxmes := 'N';
          WHEN 12 THEN vr_dsauxmes := 'D';
        END CASE;
      ELSE
        vr_dsauxmes := TO_NUMBER(TO_CHAR(vr_dtmvtolt,'mm'));
      END IF;

      -- Nome do arquivo de origem
      vr_nmarquiv := '1' || TRIM(TO_CHAR(rw_crapcop.cdagectl,'0000')) || vr_dsauxmes || TO_CHAR(vr_dtmvtolt,'dd') || '.CSN';
      
      -- Verificacao de mes para nomenclatura do arquivo dat
      IF TO_CHAR(vr_dtanmarq,'mm') > 9 THEN
        CASE TO_CHAR(vr_dtanmarq,'mm')
          WHEN 10 THEN vr_dsauxmesan := 'O';
          WHEN 11 THEN vr_dsauxmesan := 'N';
          WHEN 12 THEN vr_dsauxmesan := 'D';
        END CASE;
      ELSE
        vr_dsauxmesan := TO_NUMBER(TO_CHAR(vr_dtanmarq,'mm'));
      END IF;

      -- Nome do arquivo DAT
      vr_nmarqdat := '1' || TRIM(TO_CHAR(rw_crapcop.cdagectl,'0000')) || vr_dsauxmesan || TO_CHAR(vr_dtanmarq,'dd') || '.CSD';      
      
      -- Busca o diretorio da cooperativa conectada
      vr_caminho_coopera := gene0001.fn_diretorio(pr_tpdireto => 'C' --> Usr/Coop
                                                 ,pr_cdcooper => pr_cdcooper
                                                 ,pr_nmsubdir => '');
                                                 
      -- Setando os diretorios auxiliares
      vr_caminho_integra := vr_caminho_coopera||'/integra';
      vr_caminho_salvar  := vr_caminho_coopera||'/salvar';
      vr_caminho_arq  := vr_caminho_coopera||'/arq';
      
      -- Busca diretório Micros
      vr_caminho_micros := gene0001.fn_diretorio(pr_tpdireto => 'M' --> micros
                                                ,pr_cdcooper => pr_cdcooper);
      
      -- Verificar se não existe o arquivo
      IF NOT gene0001.fn_exis_arquivo(vr_caminho_integra||'/'||vr_nmarquiv) THEN
         -- Procedure para atualizar registro de folhas de cheque
         pc_elimina_tic();
         -- Codigo da critica
         vr_cdcritic := 182;
         -- Finaliza processo
         RAISE vr_exc_fimprg;
      END IF;
      
      -- Abre do arquivo
      GENE0001.pc_abre_arquivo(pr_nmdireto => vr_caminho_integra   --> Diretório do arquivo
                              ,pr_nmarquiv => vr_nmarquiv --> Nome do arquivo
                              ,pr_tipabert => 'R'                  --> Modo de abertura (R,W,A)
                              ,pr_utlfileh => vr_file_handle        --> Handle do arquivo aberto
                              ,pr_des_erro => vr_dscritic);        --> Descricao de erro

      -- Verifica se ocorreu erro na leitura do arquivo
      IF vr_dscritic IS NOT NULL OR NOT utl_file.IS_OPEN(vr_file_handle) THEN
        RAISE vr_exc_saida;
      ELSE
        BEGIN          
          -- Le linha do arquivo
          GENE0001.pc_le_linha_arquivo(pr_utlfileh => vr_file_handle
                                      ,pr_des_text => vr_dsctexto);

          IF SUBSTR(vr_dsctexto,1,10) <> '0000000000' THEN -- Const = 0
            vr_cdcritic := 468;
          ELSIF SUBSTR(vr_dsctexto,48,6) <> 'TIC614' THEN  -- Const = 'TIC614'
            vr_cdcritic := 173;
          ELSIF SUBSTR(vr_dsctexto,61,3) <> rw_crapcop.cdbcoctl THEN
            vr_cdcritic := 57;
          ELSIF SUBSTR(vr_dsctexto,66,08) <> vr_dtauxili THEN
            vr_cdcritic := 13;
          END IF;            
          IF vr_cdcritic <> 0 THEN
            -- Move arquivo
            gene0001.pc_OScommand_Shell(pr_des_comando => 'mv ' || vr_caminho_integra||'/'||vr_nmarquiv || ' ' || vr_caminho_integra||'/err_'||vr_nmarquiv
                                       ,pr_typ_saida   => vr_typ_said
                                       ,pr_des_saida   => vr_dscritic);

            -- Verificar retorno de erro
            IF NVL(vr_typ_said, ' ') = 'ERR' THEN
              -- O comando shell executou com erro, gerar log e sair do processo
              vr_cdcritic := 0;
              vr_dscritic := 'Erro ao mover arquivo. Erro: ' || vr_dscritic;
              RAISE vr_exc_saida;
            END IF;

            -- Gera critica no log
            vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic) || 'err_'||vr_nmarquiv;
            
            -- Sinaliza crítica de erro no layout do cabeçalho
            vr_flarqerr := 1;

            -- Processar próximo arquivo
            RAISE vr_fecha_arq;

          END IF;

          -- Iniciar a chave da primeiro registro
          vr_chv_tic606 := '0000000000000000000';
          
          -- Gerar linha cabeçalho
          vr_tab_tic606(vr_chv_tic606).nrsequen := 1;
          vr_tab_tic606(vr_chv_tic606).dsdlinha := vr_dsctexto;

          vr_cdcritic := 219; -- Integrando Arquivo
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);

          -- Gera critica no log
          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                    ,pr_ind_tipo_log => 2 -- Erro tratato
                                    ,pr_nmarqlog     => GENE0001.fn_param_sistema('CRED',pr_cdcooper,'NOME_ARQ_LOG_MESSAGE')
                                    ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                     || vr_cdprogra || ' --> '
                                                     || vr_dscritic || ' --> ' || vr_nmarquiv || '.');

          -- Volta codigo de critica ao estado inicial
          vr_cdcritic := 0;

          -- Ler restante das linhaz do arquivo
          LOOP 

            -- Le linhas do arquivo que esta sendo importado
            gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_file_handle
                                        ,pr_des_text => vr_dsctexto);

            -- Verificando se é a ultima linha do arquivo Trailler
            IF SUBSTR(vr_dsctexto,1,10) = '9999999999' THEN
              -- Cria ultimo registro tt-tic606
              vr_chv_tic606 := '9999999999999999999';
              vr_tab_tic606(vr_chv_tic606).nrsequen := 999999;
              vr_tab_tic606(vr_chv_tic606).dsdlinha := vr_dsctexto;                
              -- Forçar raise para saida
              RAISE no_data_found;
            END IF;
            
            -- Atribuição das Variaveis
            BEGIN
              vr_nrdocmto := SUBSTR(vr_dsctexto,25,6); /* Nro docmto  */
              vr_nrseqarq := SUBSTR(vr_dsctexto,151,10);/* Seq Arquiv */ 
              vr_cdbanchq := SUBSTR(vr_dsctexto,4,3);   /* Nr Bco Chq */
              vr_cdcmpchq := SUBSTR(vr_dsctexto,1,3);   /* Nro compe  */
              vr_cdagechq := SUBSTR(vr_dsctexto,7,4);   /* Age dest   */
              vr_nrctachq := SUBSTR(vr_dsctexto,12,12); /* Nr ctachq  */
              vr_cdtipdoc := SUBSTR(vr_dsctexto,148,3); /* NR TD   */
              vr_cdbanapr := SUBSTR(vr_dsctexto,56,3);  /* NRO Bco apr */
              vr_cdageapr := SUBSTR(vr_dsctexto,63,4);  /* NR Agen dep */ 
              vr_nrctaapr := SUBSTR(vr_dsctexto,67,12); /* Nro ctachq  */
              vr_dtlibtic := TO_DATE(SUBSTR(vr_dsctexto,131,4)||SUBSTR(vr_dsctexto,135,2)||SUBSTR(vr_dsctexto,137,2),'rrrrmmdd');
              vr_cdocorre := 0;  
              vr_dsdocmc7 := ''; 
            EXCEPTION
              WHEN OTHERS THEN
                
                btch0001.pc_log_internal_exception(pr_cdcooper);
                
                vr_cdcritic := 86;
                vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
                -- Próximo arquivo
                RAISE vr_fecha_arq;
            END;   
            -- Para inclusão
            IF vr_cdtipdoc = 960 THEN
              -- Busca folha de cheque no sistema
              OPEN cr_crapfdc(pr_cdbanchq => vr_cdbanchq   /* Nr Bco   */
                             ,pr_cdagechq => vr_cdagechq   /* Age dest */
                             ,pr_nrctachq => vr_nrctachq   /* Nr ctachq*/
                             ,pr_nrdocmto => vr_nrdocmto); /* Nro chq  */
              FETCH cr_crapfdc
               INTO rw_crapfdc;
              -- Se encontrar
              IF cr_crapfdc%FOUND THEN
                CLOSE cr_crapfdc;
                -- Ocorrencia 02
                IF rw_crapfdc.incheque = 8 THEN
                  vr_cdocorre := 2;
                -- Ocorrencia 10
                ELSIF rw_crapfdc.dtliqchq IS NOT NULL AND rw_crapfdc.incheque = 5 THEN
                  vr_cdocorre := 10;
                -- Ocorrencia 07
                ELSIF rw_crapfdc.cdbantic <> 0 AND rw_crapfdc.cdagetic <> 0 AND rw_crapfdc.nrctatic <> 0
                AND rw_crapfdc.cdbantic <> vr_cdbanapr AND rw_crapfdc.cdagetic <> vr_cdageapr AND rw_crapfdc.nrctatic <> vr_nrctaapr THEN
                  vr_cdocorre := 7;   
                ELSE
                  -- Ocorrências 4 e 5
                  OPEN cr_crapcor(pr_cdbanchq => rw_crapfdc.cdbanchq
                                 ,pr_cdagechq => rw_crapfdc.cdagechq
                                 ,pr_nrctachq => rw_crapfdc.nrctachq
                                 ,pr_nrdocmto => vr_nrdocmto);
                  FETCH cr_crapcor
                   INTO vr_cdhistor;
                  -- Somente se encontrar
                  IF cr_crapcor%FOUND THEN
                    -- Ocorrência 4
                    IF vr_cdhistor IN(818,835) THEN
                      vr_cdocorre := 4;
                    -- Ocorrência 5  
                    ELSIF vr_cdhistor = 821 THEN
                      vr_cdocorre := 5;
                    END IF;
                  END IF;
                  CLOSE cr_crapcor;
                END IF;
                
                -- Atualiza Valores do TIC
                IF vr_cdocorre = 0 THEN
                  -- Atualizar valor do TIC
                  BEGIN
                    UPDATE crapfdc 
                       SET cdbantic = vr_cdbanapr  
                          ,cdagetic = vr_cdageapr 
                          ,nrctatic = vr_nrctaapr
                          ,dtlibtic = vr_dtlibtic
                          ,dtatutic = vr_dtmvtolt
                     WHERE ROWID = rw_crapfdc.rowid;
                  EXCEPTION
                    WHEN OTHERS THEN
                      -- Gerar critica
                      vr_dscritic := 'Erro ao atualizar CRAPFDC --> '||SQLERRM;
                      RAISE vr_fecha_arq;
                  END;
                END IF;
                vr_dsdocmc7 := rw_crapfdc.dsdocmc7;
              ELSE
                CLOSE cr_crapfdc;
                -- Ocorrência 11
                vr_cdocorre := 11;
                vr_dsdocmc7 := '0';
                -- Ocorrência 06
                IF rw_crapcop.cdbcoctl = vr_cdbanchq AND rw_crapcop.cdagectl = vr_cdagechq THEN
                  -- Testar existência de cooperado
                  OPEN cr_crapass(pr_nrdconta => vr_nrctachq);
                  FETCH cr_crapass
                   INTO rw_crapass;
                  -- Não encontrando
                  IF cr_crapass%NOTFOUND THEN
                    vr_cdocorre := 6;
                  END IF;
                  CLOSE cr_crapass;
                ELSE   
                  vr_cdocorre := 6;
                END IF;
              END IF;
            -- Exclusão
            ELSIF vr_cdtipdoc = 966 THEN
              -- Busca folha de cheque no sistema
              OPEN cr_crapfdc(pr_cdbanchq => vr_cdbanchq   /* Nr Bco   */
                             ,pr_cdagechq => vr_cdagechq   /* Age dest */
                             ,pr_nrctachq => vr_nrctachq   /* Nr ctachq*/
                             ,pr_nrdocmto => vr_nrdocmto); /* Nro chq  */
              FETCH cr_crapfdc
               INTO rw_crapfdc;
              -- Se encontrar
              IF cr_crapfdc%FOUND THEN
                CLOSE cr_crapfdc;
                -- Ocorrência 9
                IF rw_crapfdc.cdbantic = 0 AND rw_crapfdc.cdagetic = 0 AND rw_crapfdc.nrctatic = 0 THEN 
                  vr_cdocorre := 9;
                ELSE 
                  -- Ocorrencia 07
                  IF rw_crapfdc.cdbantic <> vr_cdbanapr AND rw_crapfdc.cdagetic <> vr_cdageapr AND rw_crapfdc.nrctatic <> vr_nrctaapr THEN
                    vr_cdocorre := 7;
                  ELSE
                    -- Atualizar valor do TIC
                    IF vr_cdocorre = 0 THEN                        
                      BEGIN
                        UPDATE crapfdc 
                           SET cdbantic = 0  
                              ,cdagetic = 0 
                              ,nrctatic = 0
                              ,dtlibtic = NULL
                              ,dtatutic = NULL
                         WHERE ROWID = rw_crapfdc.rowid;
                      EXCEPTION
                        WHEN OTHERS THEN
                          -- Gerar critica
                          vr_dscritic := 'Erro ao atualizar CRAPFDC --> '||SQLERRM;
                          RAISE vr_fecha_arq;
                      END;
                    END IF; 
                  END IF;  
                END IF;
                --
                vr_dsdocmc7 := rw_crapfdc.dsdocmc7;
              ELSE
                CLOSE cr_crapfdc;
                -- Ocorrencia 11
                vr_cdocorre := 11;
                vr_dsdocmc7 := '0';
              END IF;
            ELSE
              -- Desconsidera qualquer outra operação
              continue;
            END IF;
            -- Se houve ocorrência
            IF vr_cdocorre <> 0 THEN
              vr_dslibchq := SUBSTR(vr_dsctexto,131,8);
              -- Rejeita registro caso a data de lib. for menor que o dia do movimento
              IF to_number(vr_dslibchq) < to_number(vr_dtretarq) THEN
                -- Proximo registro
                continue;
              END IF;
              -- Criar registro na PLTABLE
              vr_chv_tic606 := SUBSTR(vr_dsctexto,79,3)||lpad(vr_cdbanapr,3,'0')||'968'||lpad(vr_nrseqarq,10);
              vr_tab_tic606(vr_chv_tic606).nrsequen := vr_nrseqarq;
              vr_tab_tic606(vr_chv_tic606).dsdlinha := vr_dsctexto;
              vr_tab_tic606(vr_chv_tic606).cdocorre := vr_cdocorre;
              vr_tab_tic606(vr_chv_tic606).dsdocmc7 := vr_dsdocmc7;
              vr_tab_tic606(vr_chv_tic606).cdcmpdes := SUBSTR(vr_dsctexto,79,3);
              vr_tab_tic606(vr_chv_tic606).cdbcodes := vr_cdbanapr;
              vr_tab_tic606(vr_chv_tic606).cdtipdoc := 968;
              vr_tab_tic606(vr_chv_tic606).cdcomchq := vr_flgdsede;
              vr_tab_tic606(vr_chv_tic606).cdbcoctl := rw_crapcop.cdbcoctl;
            END IF;
          END LOOP;
          
        EXCEPTION
          WHEN vr_fecha_arq THEN
            -- Fecha arquivo
            gene0001.pc_fecha_arquivo(pr_utlfileh => vr_file_handle); --> Handle do arquivo aberto
            -- Desfazer alterações pendentes deste arquivo
            ROLLBACK;
            -- Limpar tabela temporária
            vr_tab_tic606.delete;
            -- Gerar log
            btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                      ,pr_ind_tipo_log => 2 -- Erro tratato
                                      ,pr_nmarqlog     => GENE0001.fn_param_sistema('CRED',pr_cdcooper,'NOME_ARQ_LOG_MESSAGE')
                                      ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                       || vr_cdprogra || ' --> '
                                                       || vr_dscritic || ' ' || TO_CHAR(vr_nrseqarq,'FM999G990')||'.');
          WHEN NO_DATA_FOUND THEN
            -- Fecha arquivo
            gene0001.pc_fecha_arquivo(pr_utlfileh => vr_file_handle); --> Handle do arquivo aberto
        END;
      END IF;
      -- Se por algum motivo o arquivo persistir aberto, devemos fechá-lo.
      IF utl_file.IS_OPEN(vr_file_handle) THEN
        gene0001.pc_fecha_arquivo(pr_utlfileh => vr_file_handle);
      END IF;
            
      -- Mover arquivo quando não ocorrer crítica de erro no layout pois as mesmas renomeiam o arquivo para ERR_
      IF vr_flarqerr = 0 THEN
        -- Após todos o processamento relacionado, mover o arquivo para a pasta salvar
        gene0001.pc_OScommand_Shell(pr_des_comando => 'mv ' || vr_caminho_integra||'/'||vr_nmarquiv || ' ' || vr_caminho_salvar
                                   ,pr_typ_saida   => vr_typ_said
                                   ,pr_des_saida   => vr_dscritic);

        -- Verificar retorno de erro
        IF NVL(vr_typ_said, ' ') = 'ERR' THEN
          -- O comando shell executou com erro, gerar log e sair do processo
          vr_cdcritic := 0;
          vr_dscritic := 'Erro ao mover arquivo . Erro: ' || vr_dscritic;
          RAISE vr_exc_saida;
        END IF;
      END IF;      
      
      -- Gerar critica 190
      vr_cdcritic := 190;
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_nmarqlog     => GENE0001.fn_param_sistema('CRED',pr_cdcooper,'NOME_ARQ_LOG_MESSAGE')
                                ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                 || vr_cdprogra || ' --> '
                                                 || vr_dscritic || ' --> ' || vr_nmarquiv ||'.');
      
      -- Efetuar limpeza do diretório ARQ
      gene0001.pc_OScommand_Shell(pr_des_comando => 'rm ' || vr_caminho_arq||'/1*.CSD 2>/dev/null '
                                 ,pr_typ_saida   => vr_typ_said
                                 ,pr_des_saida   => vr_dscritic);

      -- Verificar retorno de erro
      IF NVL(vr_typ_said, ' ') = 'ERR' THEN
        -- O comando shell executou com erro, gerar log e sair do processo
        vr_cdcritic := 0;
        vr_dscritic := 'Erro ao limpar diretorio ARQ. Erro: ' || vr_dscritic;
        RAISE vr_exc_saida;
      END IF;
      
      -- Se há mais informações na pltable além das linhas de cabeçalho e trailler do arquivo, 
      -- para não gerar o mesmo desnecessariamente
      IF vr_tab_tic606.count() > 2 THEN
        vr_cdcritic := 339;
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        -- Gerar em LOG
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                  ,pr_nmarqlog     => GENE0001.fn_param_sistema('CRED',pr_cdcooper,'NOME_ARQ_LOG_MESSAGE')
                                  ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                   || vr_cdprogra || ' --> '
                                                   || vr_dscritic || ' --> ' || vr_nmarqdat ||'.');
        vr_cdcritic := 0;
      ELSE
        -- encerrar o programa
        RAISE vr_exc_fimprg;
      END IF;
      
      -- Inicializar os contadores
      vr_vltolarq := 0;
      vr_vltotlot := 0;      
      vr_contareg := 1;
      vr_qttotlot := 0;
      
      -- Abrir o arquivo DAT para escrita
      gene0001.pc_abre_arquivo(pr_nmdireto => vr_caminho_arq
                              ,pr_nmarquiv => vr_nmarqdat
                              ,pr_tipabert => 'W'
                              ,pr_utlfileh => vr_file_handle
                              ,pr_des_erro => vr_dscritic);
      -- Verifica se ocorreu erro na leitura do arquivo
      IF vr_dscritic IS NOT NULL OR NOT utl_file.IS_OPEN(vr_file_handle) THEN
        RAISE vr_exc_saida;
      END IF;  
      
      -- Envio do Header
      vr_chv_tic606 := vr_tab_tic606.first;
      IF vr_chv_tic606 IS NOT NULL THEN
        -- Enviar Linha do Header --
        gene0001.pc_escr_linha_arquivo(vr_file_handle
                                      ,lpad('0',47,'0')
                                     ||'TIC606018'
                                     ||to_char(rw_crapcop.cdagectl,'fm0000')
                                     ||SUBSTR(vr_tab_tic606(vr_chv_tic606).dsdlinha,61,3)
                                     ||' 2'
                                     ||vr_dtretarq
                                     ||lpad(' ',77,' ')
                                     ||SUBSTR(vr_tab_tic606(vr_chv_tic606).dsdlinha,151,50));
      END IF;
      
      -- Varrer a pltable a partir do segundo registro
      vr_chv_tic606 := vr_tab_tic606.next(vr_chv_tic606);
      LOOP 
        -- Sair quando não encontrar mais ou chegar no ultimo
        EXIT WHEN vr_chv_tic606 IS NULL OR vr_chv_tic606 = vr_tab_tic606.last;
        -- Incrementar contador
        vr_contareg := vr_contareg + 1;
        vr_qttotlot := vr_qttotlot + 1;
        -- Acumular valores
        vr_vltolarq := vr_vltolarq + (SUBSTR(vr_tab_tic606(vr_chv_tic606).dsdlinha,34,17) / 100);
        vr_vltotlot := vr_vltotlot + (SUBSTR(vr_tab_tic606(vr_chv_tic606).dsdlinha,34,17) / 100);
        -- Enviar linhar de detalhe
        gene0001.pc_escr_linha_arquivo(vr_file_handle
                                      ,SUBSTR(vr_tab_tic606(vr_chv_tic606).dsdlinha,1,78)
                                     ||to_char(vr_tab_tic606(vr_chv_tic606).cdcomchq,'fm000')
                                     ||vr_dtretarq
                                     ||SUBSTR(vr_tab_tic606(vr_chv_tic606).dsdlinha,90,49)
                                     ||to_char(vr_tab_tic606(vr_chv_tic606).cdocorre,'fm00')
                                     ||'018'
                                     ||to_char(rw_crapcop.cdagectl,'fm0000')
                                     ||to_char(vr_tab_tic606(vr_chv_tic606).cdtipdoc,'fm000')
                                     ||to_char(vr_contareg,'fm0000000000') 
                                     ||SUBSTR(vr_tab_tic606(vr_chv_tic606).dsdlinha,161,40));        
        -- A cada 400 registros 
        -- OU Em cada quebra de empresa, banco ou tipo doc 
        -- ou no penúltimo registro (pois o ultimo eh lido fora do LOOP)
        IF vr_qttotlot >= 400 
        OR vr_tab_tic606.last = vr_tab_tic606.next(vr_chv_tic606)
        OR vr_tab_tic606(vr_chv_tic606).cdcmpdes <> vr_tab_tic606(vr_tab_tic606.next(vr_chv_tic606)).cdcmpdes
        OR vr_tab_tic606(vr_chv_tic606).cdbcodes <> vr_tab_tic606(vr_tab_tic606.next(vr_chv_tic606)).cdbcodes
        OR vr_tab_tic606(vr_chv_tic606).cdtipdoc <> vr_tab_tic606(vr_tab_tic606.next(vr_chv_tic606)).cdtipdoc THEN
          -- Reiniciar lote
          vr_qttotlot := 0;
          vr_contareg := vr_contareg + 1;          
          -- Enviar fechamento do lote
          gene0001.pc_escr_linha_arquivo(vr_file_handle
                                        ,'018'
                                       ||to_char(vr_tab_tic606(vr_chv_tic606).cdbcoctl,'fm000')
                                       ||lpad('9',27,'9')
                                       ||to_char(vr_vltotlot * 100,'fm00000000000000000')
                                       ||lpad(' ',5,' ')
                                       ||to_char(vr_tab_tic606(vr_chv_tic606).cdbcoctl,'fm000')
                                       ||lpad(' ',23,' ')                                       
                                       ||vr_dtretarq
                                       ||'0000001999000000'
                                       ||lpad(' ',35,' ')                                       
                                       ||'018'
                                       ||to_char(rw_crapcop.cdagectl,'fm0000')
                                       ||to_char(vr_tab_tic606(vr_chv_tic606).cdtipdoc,'fm000')
                                       ||to_char(vr_contareg,'fm0000000000') 
                                       ||SUBSTR(vr_tab_tic606(vr_chv_tic606).dsdlinha,161,40));
          -- Reiniciar total do lote
          vr_vltotlot := 0;
        END IF;
        -- Buscar o próximo registro
        vr_chv_tic606 := vr_tab_tic606.next(vr_chv_tic606);
      END LOOP;
      
      -- INcrementer o contador
      vr_contareg := vr_contareg + 1;
      -- Para o Trailler
      vr_chv_tic606 := vr_tab_tic606.last;
      IF vr_chv_tic606 IS NOT NULL THEN
        -- Enviar Linha do Header --
        gene0001.pc_escr_linha_arquivo(vr_file_handle
                                      ,lpad('9',47,'9')
                                     ||'TIC606018'
                                     ||to_char(rw_crapcop.cdagectl,'fm0000')
                                     ||SUBSTR(vr_tab_tic606(vr_chv_tic606).dsdlinha,61,3)
                                     ||' 2'
                                     ||vr_dtretarq
                                     ||to_char(vr_vltolarq * 100,'fm00000000000000000')
                                     ||lpad(' ',60,' ')
                                     ||to_char(vr_contareg,'fm0000000000')
                                     ||SUBSTR(vr_tab_tic606(vr_chv_tic606).dsdlinha,161,40));
      END IF;
            
      -- Fechar o arquivo DAT
      gene0001.pc_fecha_arquivo(vr_file_handle);
      
      -- Copia para o /micros
      gene0001.pc_OScommand_Shell(pr_des_comando => 'ux2dos ' || vr_caminho_arq||'/'||vr_nmarqdat||' | tr -d "\032"' ||
                                                    ' > ' || vr_caminho_micros ||'/abbc/'||vr_nmarqdat||' 2>/dev/null'
                                 ,pr_typ_saida   => vr_typ_said
                                 ,pr_des_saida   => vr_dscritic);
      -- Verificar retorno de erro
      IF NVL(vr_typ_said, ' ') = 'ERR' THEN
        -- O comando shell executou com erro, gerar log e sair do processo
        vr_cdcritic := 0;
        vr_dscritic := 'Erro ao mover arquivo DAT para Micros --> Erro: ' || vr_dscritic;
        RAISE vr_exc_saida;
      END IF;

      -- Move para o salvar 
      gene0001.pc_OScommand_Shell(pr_des_comando => 'mv ' || vr_caminho_arq||'/'||vr_nmarqdat||' '
                                                 || vr_caminho_salvar ||'/'||vr_nmarqdat||'_'|| to_char(SYSDATE,'sssss') ||' 2>/dev/null'
                                 ,pr_typ_saida   => vr_typ_said
                                 ,pr_des_saida   => vr_dscritic);
      -- Verificar retorno de erro
      IF NVL(vr_typ_said, ' ') = 'ERR' THEN
        -- O comando shell executou com erro, gerar log e sair do processo
        vr_cdcritic := 0;
        vr_dscritic := 'Erro ao mover arquivo DAT para Micros --> Erro: ' || vr_dscritic;
        RAISE vr_exc_saida;
      END IF;
      
      -- Procedure para atualizar registro de folhas de cheque
      pc_elimina_tic();

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
    END;

  END pc_crps625;
/
