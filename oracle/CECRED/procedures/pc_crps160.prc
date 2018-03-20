CREATE OR REPLACE PROCEDURE CECRED.pc_crps160(pr_cdcooper IN crapcop.cdcooper%TYPE   --> Cooperativa solicitada
                                      ,pr_flgresta IN PLS_INTEGER             --> Flag padrão para utilização de restart
                                      ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                                      ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                                      ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                                      ,pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada
  BEGIN
    /* .............................................................................
       
       Programa: pc_crps160      (Antigo Fontes/crps160.p)
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Odair
       Data    : Maio/96                        Ultima atualizacao: 16/06/2014

       Dados referentes ao programa:

       Frequencia: Diario (Batch).
       Objetivo  : Atende a solicitacao 067.
                   Gerar os debitos referentes a poupanca programada Ceval de
                   cheque salario
                   Emite relatorio 127.

       Alteracoes: 09/09/96 - Alterado para tratar outrar empresas (Edson).

                   17/07/97 - Tratar data crapavs.dtmvtolt dependendo do tpconven
                              (Odair).

                   24/07/97 - Atualizar crapemp.inavsppr (Odair).

                   31/07/97 - Acerto no for each das poupancas suspensas (Deborah)

                   27/08/97 - Alterado para incluir o campo flgproce na criacao
                              do crapavs (Deborah).

                   22/01/98 - Alterado para gerar cdsecext para Ceval Jaragua com
                              zeros (Deborah).

                   24/03/98 - Cancelada a alteracao anterior (Deborah).

                   28/04/98 - Tratamento para milenio e troca para V8 (Margarete).
                   
                   10/09/98 - Tratar tipo de conta 7 (Deborah).

                   08/06/2005 - Incluidos tipos de conta Integracao(17/18)(Mirtes)
                   
                   29/06/2005 - Alimentado campo cdcooper da tabela crapavs (Diego).

                   15/02/2006 - Unificacao dos bancos- SQLWorks - Eder
                   
                   09/06/2008 - Incluída a chave de acesso (craphis.cdcooper = 
                                glb_cdcooper) no "find" da tabela CRAPHIS. 
                              - Kbase IT Solutions - Paulo Ricardo Maciel.
                              
                   01/09/2008 - Alteracao CDEMPRES (Kbase) - Eduardo Silva.
                   
                   01/12/2010 - 001 - Alterado format "x(40)" para "x(50)"
                                KBASE - Kamila Ploharski de Oliveira

                   13/12/2013 - Verificar se ja existe um aviso cadastrado para 
                                a data de referencia. Se existir, deletar o registro
                                e criar um novo (David).
                                
                   04/03/2014 - Conversão Progress >> Oracle (Petter - Supero).
                   
                   16/06/2014 - Ajustes no padrão de tratamento de DML cfme 
                                solicitação da equipe de qualidade (Marcos-Supero)

                   05/03/2018 - Substituída verificacao do tipo de conta "IN (5,6,7,17,18)" para a 
                                modalidade do tipo de conta igual a "2" ou "3". PRJ366 (Lombardi)

    ............................................................................ */

    DECLARE
      ---------------------------- PL TABLES -----------------------------------
      -- PL Table para dados da CRAPEMP
      TYPE typ_reg_crapemp IS
        RECORD(tpdebppr crapemp.tpdebppr%TYPE
              ,tpconven crapemp.tpconven%TYPE);
      TYPE typ_tab_crapemp IS TABLE OF typ_reg_crapemp INDEX BY VARCHAR2(10);
      
      -- PL Table para dados da CRAPASS
      TYPE typ_reg_crapass IS
        RECORD(nrdconta crapass.nrdconta%TYPE
              ,nmprimtl crapass.nmprimtl%TYPE);
      TYPE typ_tab_crapass IS TABLE OF typ_reg_crapass INDEX BY VARCHAR2(15);
      
      -- PL Table para daddos do UNION das tabelas CRAPTTL e CRAPJUR
      TYPE typ_reg_ttljur IS
        RECORD(cdempres crapttl.cdempres%TYPE);
      TYPE typ_tab_ttljur IS TABLE OF typ_reg_ttljur INDEX BY VARCHAR2(15);
      

      ------------------------ VARIAVEIS PRINCIPAIS ----------------------------
      -- Código do programa
      vr_cdprogra      CONSTANT crapprg.cdprogra%TYPE := 'CRPS160';

      -- Tratamento de erros
      vr_exc_saida     EXCEPTION;
      vr_exc_fimprg    EXCEPTION;
      vr_cdcritic      PLS_INTEGER;
      vr_dscritic      VARCHAR2(4000);
      
      vr_dtinirpp      DATE;
      vr_rel_dshistor  VARCHAR2(400);
      vr_nrseqdig      PLS_INTEGER := 0;
      vr_nrdocmto      PLS_INTEGER := 0;
      vr_vldebito      NUMBER(20,2) := 0;
      vr_tot_vldebito  NUMBER(20,2) := 0;
      vr_tot_qtassoci  PLS_INTEGER := 0;
      vr_regexist      BOOLEAN;
      vr_rel_dtrefere  DATE;
      vr_dtultdia      DATE;
      vr_dtmvtolt      DATE; 
      vr_tab_crapemp   typ_tab_crapemp;
      vr_nrctares      crapass.nrdconta%TYPE;
      vr_dsrestar      VARCHAR2(4000);
      vr_inrestar      INTEGER := 0;
      vr_xmlb          VARCHAR2(32767);
      vr_xmlc          CLOB;
      vr_tab_crapass   typ_tab_crapass;
      vr_tab_ttljur    typ_tab_ttljur;
      vr_tempdata      VARCHAR2(100);
      vr_nom_dir       VARCHAR2(400);
      vr_nmarquiv      VARCHAR2(256);

      ------------------------------- CURSORES ---------------------------------
      -- Busca dos dados da cooperativa
      CURSOR cr_crapcop IS
        SELECT cop.nmrescop
              ,cop.nmextcop
          FROM crapcop cop
         WHERE cop.cdcooper = pr_cdcooper;
      rw_crapcop cr_crapcop%ROWTYPE;
      
      -- Cursor genérico de calendário
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;
      
      -- Busca dados das solicitações
      CURSOR cr_crapsol(pr_cdcooper IN crapsol.cdcooper%TYPE
                       ,pr_dtmvtolt IN crapsol.dtrefere%TYPE) IS
        SELECT cl.cdempres
              ,cl.dsparame
        FROM crapsol cl
        WHERE cl.cdcooper = pr_cdcooper  
          AND cl.dtrefere = pr_dtmvtolt  
          AND cl.nrsolici = 67            
          AND cl.insitsol = 1;
      
      -- Busca dados do cadastro das empresas
      CURSOR cr_crapemp(pr_cdcooper IN crapemp.cdcooper%TYPE) IS
        SELECT cm.cdempres
              ,cm.tpdebppr
              ,cm.tpconven
        FROM crapemp cm
        WHERE cm.cdcooper = pr_cdcooper;
      
      -- Busca dados do histórico
      CURSOR cr_craphis(pr_cdcooper IN craphis.cdcooper%TYPE) IS
        SELECT cr.dshistor
        FROM craphis cr
        WHERE cr.cdcooper = pr_cdcooper 
          AND cr.cdhistor = 160;
      rw_craphis cr_craphis%ROWTYPE;
      
      -- Buscar dados dos associados
      CURSOR cr_crapass(pr_cdcooper IN crapass.cdcooper%TYPE
                       ,pr_nrctares IN crapass.nrdconta%TYPE) IS
        SELECT cp.inpessoa
              ,cp.nrdconta
              ,cp.cdagenci
              ,cp.cdsecext
        FROM crapass cp
            ,tbcc_tipo_conta tpcta
        WHERE cp.cdcooper = pr_cdcooper                  
          AND cp.nrdconta > pr_nrctares
          AND cp.inpessoa = tpcta.inpessoa
          AND cp.cdtipcta = tpcta.cdtipo_conta
          AND (tpcta.cdmodalidade_tipo IN (2, 3)
               OR cp.cdsitdct = 5);
               
      -- Buscar as informações para restart e Rowid para atualização posterior
      CURSOR cr_crapres(pr_cdcooper IN crapres.cdcooper%TYPE
                       ,vr_cdprogra IN crapres.cdprogra%TYPE) IS
        SELECT res.dsrestar
              ,res.nrdconta
              ,res.rowid
          FROM crapres res
         WHERE res.cdcooper = pr_cdcooper
           AND UPPER(res.cdprogra) = UPPER(vr_cdprogra);
      rw_crapres cr_crapres%ROWTYPE;
      
      -- Buscar empresa para pessoas físicas e jurídicas
      CURSOR cr_ttljur(pr_cdcooper IN crapttl.cdcooper%TYPE) IS 
        SELECT ttl.cdempres
              ,ttl.nrdconta
        FROM crapttl ttl
        WHERE ttl.cdcooper = pr_cdcooper
          AND ttl.idseqttl = 1
        UNION ALL
        SELECT jur.cdempres
              ,jur.nrdconta
        FROM crapjur jur
        WHERE jur.cdcooper = pr_cdcooper;
      
      -- Buscar dados de poupança programada
      CURSOR cr_craprpp(pr_cdcooper IN craprpp.cdcooper%TYPE
                       ,pr_nrdconta IN craprpp.nrdconta%TYPE
                       ,pr_dtinirpp IN craprpp.dtinirpp%TYPE) IS
        SELECT cpp.nrctrrpp
              ,cpp.vlprerpp
        FROM craprpp cpp
        WHERE cpp.cdcooper = pr_cdcooper          
          AND cpp.nrdconta = pr_nrdconta      
          AND (cpp.cdsitrpp = 1                     
               OR (cpp.cdsitrpp = 2                     
                   AND cpp.dtrnirpp = cpp.dtdebito))   
          AND TO_NUMBER(TO_CHAR(cpp.dtdebito, 'DD')) < 11               
          AND cpp.dtinirpp < pr_dtinirpp;
                             
      -- Buscar dados do cadastro de avisos de debito em conta corrente
      CURSOR cr_crapavs(pr_cdcooper IN crapavs.cdcooper%TYPE
                       ,pr_dtrefere IN crapavs.dtrefere%TYPE) IS
        SELECT /*+ index(crapavs crapavs2)*/
               cv.nrdconta
              ,cv.vllanmto
              ,cv.cdempres
              ,cv.nrseqdig
              ,cv.nrdocmto
        FROM crapavs cv
        WHERE cv.cdcooper = pr_cdcooper  
          AND cv.dtrefere = pr_dtrefere  
          AND cv.cdhistor = 160;
                                
      -- Buscar dados gerais de associados
      CURSOR cr_crapassp(pr_cdcooper IN crapass.cdcooper%TYPE) IS
        SELECT cs.nrdconta
              ,cs.nmprimtl
        FROM crapass cs
        WHERE cs.cdcooper = pr_cdcooper;
      
    BEGIN
      -- Incluir nome do módulo logado
      GENE0001.pc_informa_acesso(pr_module => 'PC_' || vr_cdprogra, pr_action => null);
      
      -- Verifica se a cooperativa esta cadastrada
      OPEN cr_crapcop;
      FETCH cr_crapcop INTO rw_crapcop;
      
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
      FETCH btch0001.cr_crapdat INTO rw_crapdat;
      
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

      --------------- REGRA DE NEGOCIO DO PROGRAMA -----------------
      -- Tratamento e retorno de valores de restart
      btch0001.pc_valida_restart(pr_cdcooper  => pr_cdcooper   --> Cooperativa conectada
                                ,pr_cdprogra  => vr_cdprogra   --> Código do programa
                                ,pr_flgresta  => pr_flgresta   --> Indicador de restart
                                ,pr_nrctares  => vr_nrctares   --> Número da conta de restart
                                ,pr_dsrestar  => vr_dsrestar   --> String genérica com informações para restart
                                ,pr_inrestar  => vr_inrestar   --> Indicador de Restart
                                ,pr_cdcritic  => vr_cdcritic   --> Código de erro
                                ,pr_des_erro  => vr_dscritic); --> Saída de erro
      
      -- Se encontrou erro, gerar exceção
      IF vr_dscritic IS NOT NULL OR vr_cdcritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;
      
      -- Somente se a flag de restart estiver ativa
      IF pr_flgresta = 1 THEN
        -- Buscar as informações para restart e Rowid para atualização posterior
        OPEN cr_crapres(pr_cdcooper, vr_cdprogra);
        FETCH cr_crapres INTO rw_crapres;
        
        -- Se não tiver encontrador
        IF cr_crapres%NOTFOUND THEN
          CLOSE cr_crapres;
          
          -- Montar mensagem de critica
          vr_cdcritic := 151;
          vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
          
          RAISE vr_exc_saida;
        ELSE
          CLOSE cr_crapres;
        END IF;
      END IF;
      
      -- Carregar PL Table de empresas
      FOR rw_crapemp IN cr_crapemp(pr_cdcooper) LOOP
        vr_tab_crapemp(LPAD(rw_crapemp.cdempres, 10, '0')).tpdebppr := rw_crapemp.tpdebppr;
        vr_tab_crapemp(LPAD(rw_crapemp.cdempres, 10, '0')).tpconven := rw_crapemp.tpconven;
      END LOOP;
      
      -- Carregar PL Table de associados
      FOR rw_crapass IN cr_crapassp(pr_cdcooper) LOOP
        vr_tab_crapass(LPAD(rw_crapass.nrdconta, 15, '0')).nrdconta := rw_crapass.nrdconta;
        vr_tab_crapass(LPAD(rw_crapass.nrdconta, 15, '0')).nmprimtl := rw_crapass.nmprimtl;
      END LOOP;
      
      -- Carregar PL Tabl de pessoas (juridica e físca)
      FOR rw_ttljur IN cr_ttljur(pr_cdcooper) LOOP
        vr_tab_ttljur(LPAD(rw_ttljur.nrdconta, 15, '0')).cdempres := rw_ttljur.cdempres;
      END LOOP;
      
      -- Assimilar data e controle inicial
      vr_regexist := FALSE;
      vr_dtultdia := LAST_DAY(rw_crapdat.dtmvtolt);
      
      -- Nome do relatório
      vr_nmarquiv := 'crrl127.lst';
      
      -- Capturar o path do arquivo
      vr_nom_dir := gene0001.fn_diretorio(pr_tpdireto => 'C' -- /usr/coop
                                         ,pr_cdcooper => pr_cdcooper
                                         ,pr_nmsubdir => '/rl'); --> Utilizaremos o rl
      
      -- Consultar dados do histórico
      OPEN cr_craphis(pr_cdcooper);
      FETCH cr_craphis INTO rw_craphis;
      
      -- Verificar se a tupla retornou registro
      IF cr_craphis%NOTFOUND THEN
        CLOSE cr_craphis;
        
        vr_rel_dshistor := '160 - Nao cadastrado';
      ELSE
        CLOSE cr_craphis;
        
        vr_rel_dshistor := '160 - ' || rw_craphis.dshistor;
      END IF;

      -- Leitura da solicitação das integrações
      FOR rw_crapsol IN cr_crapsol(pr_cdcooper, rw_crapdat.dtmvtolt) LOOP                
        -- Se não existir registro de empresa grava LOG com a crítica e vai para próxima iteração
        IF NOT vr_tab_crapemp.exists(LPAD(rw_crapsol.cdempres, 10, '0')) THEN
          vr_cdcritic := 40;
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                    ,pr_ind_tipo_log => 2
                                    ,pr_des_log      => to_char(SYSDATE,'hh24:mi:ss') || ' - ' || vr_cdprogra || ' --> ' || vr_dscritic
                                    ,pr_nmarqlog     => 'PROC_BATCH');
          CONTINUE;
        END IF;

        -- Verificar tipo da empresa
        IF vr_tab_crapemp(LPAD(rw_crapsol.cdempres, 10, '0')).tpdebppr <> 2 THEN
          CONTINUE;
        END IF;

        -- Verificar tipo de convênio
        IF vr_tab_crapemp(LPAD(rw_crapsol.cdempres, 10, '0')).tpconven = 2 THEN
          -- Obter próximo dia útil
          vr_dtmvtolt := gene0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper, pr_dtmvtolt => vr_dtultdia + 1, pr_excultdia => TRUE);
        ELSE
          vr_dtmvtolt := rw_crapdat.dtmvtolt;
        END IF;

        -- Verificar data inicial do período
        IF TO_CHAR(rw_crapdat.dtmvtolt, 'MM') = '12' THEN
          vr_tempdata := TO_CHAR(rw_crapdat.dtmvtolt, 'RRRR') + 1;
          vr_dtinirpp := TO_DATE('11/01/' || vr_tempdata, 'DD/MM/RRRR');
        ELSE
          vr_tempdata := TO_CHAR(rw_crapdat.dtmvtolt, 'MM') + 1; 
          vr_dtinirpp := TO_DATE('11/' || vr_tempdata || TO_CHAR(rw_crapdat.dtmvtolt, '/RRRR'), 'DD/MM/RRRR');
        END IF;
        
        -- Buscar data de referencia
        vr_rel_dtrefere := TO_DATE(SUBSTR(rw_crapsol.dsparame, 0, 10), 'DD/MM/RRRR');

        -- Processar associados
        FOR rw_crapass IN cr_crapass(pr_cdcooper, rw_crapres.nrdconta) LOOP
          -- Verifica se existe diferenção entre empresas
          IF vr_tab_ttljur(LPAD(rw_crapass.nrdconta, 15, '0')).cdempres <> rw_crapsol.cdempres THEN
            CONTINUE;
          END IF;
          
          -- Verifica se empresa é 4 considerando as agências 14 e 15
          IF vr_tab_ttljur(LPAD(rw_crapass.nrdconta, 15, '0')).cdempres = 4 AND rw_crapass.cdagenci NOT IN (14, 15) THEN
            CONTINUE;
          END IF;
          
          -- Buscar poupança programada
          FOR rw_craprpp IN cr_craprpp(pr_cdcooper, rw_crapass.nrdconta, vr_dtinirpp) LOOP
            vr_nrdocmto := NVL(rw_craprpp.nrctrrpp, 0);
            vr_vldebito := vr_vldebito + NVL(rw_craprpp.vlprerpp, 0);
          END LOOP;
          
          -- Verifica se o valor de débito irá pular a iteração
          IF vr_vldebito = 0 THEN
            CONTINUE;
          END IF;
          
          -- Criar ponto de salvaguarda para rollback da iteração
          SAVEPOINT vr_trans_1;
          
          -- Apagar registro da tabela
          DELETE crapavs 
          WHERE crapavs.cdcooper = pr_cdcooper     
            AND crapavs.dtmvtolt = vr_dtmvtolt     
            AND crapavs.cdempres = vr_tab_ttljur(LPAD(rw_crapass.nrdconta, 15, '0')).cdempres     
            AND crapavs.cdagenci = rw_crapass.cdagenci 
            AND crapavs.cdsecext = rw_crapass.cdsecext 
            AND crapavs.nrdconta = rw_crapass.nrdconta 
            AND crapavs.dtdebito IS NULL          
            AND crapavs.cdhistor = 160              
            AND crapavs.nrdocmto = vr_nrdocmto;

          -- Atribuir contador
          vr_nrseqdig := vr_nrseqdig + 1;

          -- Criar novo registro
          BEGIN
            INSERT INTO crapavs(dtmvtolt
                               ,cdagenci
                               ,cdempres
                               ,cdhistor
                               ,cdsecext
                               ,dtdebito
                               ,dtrefere
                               ,insitavs
                               ,nrdconta
                               ,nrseqdig
                               ,nrdocmto
                               ,vllanmto
                               ,tpdaviso
                               ,vldebito
                               ,vlestdif
                               ,flgproce
                               ,cdcooper)
              VALUES(vr_dtmvtolt
                    ,rw_crapass.cdagenci
                    ,vr_tab_ttljur(LPAD(rw_crapass.nrdconta, 15, '0')).cdempres
                    ,160
                    ,rw_crapass.cdsecext
                    ,NULL
                    ,vr_rel_dtrefere
                    ,0
                    ,rw_crapass.nrdconta
                    ,vr_nrseqdig
                    ,vr_nrdocmto
                    ,vr_vldebito
                    ,1
                    ,0
                    ,0
                    ,0
                    ,pr_cdcooper);
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao gravar em CRAPAVS: ' || SQLERRM;
              
              RAISE vr_exc_saida;
          END;
          
          vr_vldebito := 0;
          vr_regexist := TRUE;

          -- Atualizar informação de restart
          BEGIN
            UPDATE crapres
            SET nrdconta = rw_crapass.nrdconta
            WHERE cdcooper = pr_cdcooper    
              AND cdprogra = vr_cdprogra;
            
            -- Verificar se o registro foi atualizado
            IF SQL%ROWCOUNT = 0 THEN
              vr_cdcritic := 151;
              vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
              btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                        ,pr_ind_tipo_log => 2
                                        ,pr_des_log      => to_char(SYSDATE,'hh24:mi:ss') || ' - ' || vr_cdprogra || ' --> ' || vr_dscritic
                                        ,pr_nmarqlog     => 'PROC_BATCH');
            
              ROLLBACK TO vr_trans_1;
              RAISE vr_exc_saida;
            END IF;
          EXCEPTION
            WHEN vr_exc_saida THEN
              RAISE vr_exc_saida;            
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao gravar em CRAPRES: ' || SQLERRM;              
              RAISE vr_exc_saida;
          END;
        END LOOP;

        -- Atualizar dados das empresas
        BEGIN
          UPDATE crapemp
          SET inavsppr = 1
          WHERE cdcooper = pr_cdcooper
            AND cdempres = rw_crapsol.cdempres;
            
            -- Verifica seo registro foi atualizado
            IF SQL%ROWCOUNT = 0 THEN
              vr_cdcritic := 40;
              vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
              btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                        ,pr_ind_tipo_log => 2
                                        ,pr_des_log      => to_char(SYSDATE,'hh24:mi:ss') || ' - ' || vr_cdprogra || ' --> ' || vr_dscritic
                                        ,pr_nmarqlog     => 'PROC_BATCH');
            
              ROLLBACK TO vr_trans_1;
              RAISE vr_exc_saida;
            END IF;
        EXCEPTION
          WHEN vr_exc_saida THEN
            RAISE vr_exc_saida;          
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao gravar em CRAPEMP: ' || SQLERRM;              
            RAISE vr_exc_saida;
        END;
      END LOOP;
      
      -- Iniciar processo para gerar relatório
      IF vr_regexist THEN
        -- Inicializar CLOB para XML
        dbms_lob.createtemporary(vr_xmlc, TRUE);
        dbms_lob.open(vr_xmlc, dbms_lob.lob_readwrite);
        
        -- Iniciar escrita do XML
        vr_xmlb := '<?xml version="1.0" encoding="utf-8"?><root>';
        vr_xmlb := vr_xmlb || '<cab><rel_dtrefere>' || TO_CHAR(vr_rel_dtrefere, 'DD/MM/RRRR') || '</rel_dtrefere>';
        vr_xmlb := vr_xmlb || '<rel_dshistor>' || vr_rel_dshistor || '</rel_dshistor></cab>';
        gene0002.pc_clob_buffer(pr_dados => vr_xmlb, pr_gravfim => FALSE, pr_clob => vr_xmlc);
        
        -- Abrir TAG de valores
        vr_xmlb := vr_xmlb || '<valores>';
        
        -- Gerar dados de aplicações de débito
        FOR rw_crapavs IN cr_crapavs(pr_cdcooper, vr_rel_dtrefere) LOOP
          -- Verifica se o associado existe
          IF NOT vr_tab_crapass.exists(LPAD(rw_crapavs.nrdconta, 15, '0')) THEN
            vr_cdcritic := 251;
            vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
            btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                      ,pr_ind_tipo_log => 2
                                      ,pr_des_log      => to_char(SYSDATE,'hh24:mi:ss') || ' - ' || vr_cdprogra || ' --> ' || TO_CHAR(rw_crapavs.nrdconta, 'FM9999G999G0')
                                      ,pr_nmarqlog     => 'PROC_BATCH');
          
            RAISE vr_exc_saida;
          END IF;
          
          -- Sumarizar valores
          vr_tot_vldebito := vr_tot_vldebito + NVL(rw_crapavs.vllanmto, 0);
          vr_tot_qtassoci := vr_tot_qtassoci + 1;

          -- Gerar dados para relatório
          vr_xmlb := vr_xmlb || '<valor><nrdconta>' || TO_CHAR(vr_tab_crapass(LPAD(rw_crapavs.nrdconta, 15, '0')).nrdconta, 'FM9999G999G9') || '</nrdconta>';
          vr_xmlb := vr_xmlb || '<ordem>' || LPAD(rw_crapavs.nrdconta, 15, '0') || LPAD(rw_crapavs.nrseqdig, 5, '0') || '</ordem>';
          vr_xmlb := vr_xmlb || '<cdempres>' || rw_crapavs.cdempres || '</cdempres>';
          vr_xmlb := vr_xmlb || '<nrseqdig>' || rw_crapavs.nrseqdig || '</nrseqdig>';
          gene0002.pc_clob_buffer(pr_dados => vr_xmlb, pr_gravfim => FALSE, pr_clob => vr_xmlc);
          vr_xmlb := vr_xmlb || '<nrdocmto>' || TO_CHAR(rw_crapavs.nrdocmto, 'FM999G999G999G999') || '</nrdocmto>';
          vr_xmlb := vr_xmlb || '<vllanmto>' || TO_CHAR(rw_crapavs.vllanmto, 'FM999G999G999G990D00') || '</vllanmto>';
          vr_xmlb := vr_xmlb || '<nmprimtl>'  || vr_tab_crapass(LPAD(rw_crapavs.nrdconta, 15, '0')).nmprimtl || '</nmprimtl></valor>';
          gene0002.pc_clob_buffer(pr_dados => vr_xmlb, pr_gravfim => FALSE, pr_clob => vr_xmlc);
        END LOOP;
        
        -- Fechar TAG de valores
        vr_xmlb := vr_xmlb || '</valores>';

        -- Gerar valores de totalização
        vr_xmlb := vr_xmlb || '<totais><tot_qtassoci>' || TO_CHAR(vr_tot_qtassoci, 'FM999G999G999G999') || '</tot_qtassoci>';
        vr_xmlb := vr_xmlb || '<tot_vldebito>' || TO_CHAR(vr_tot_vldebito, 'FM999G999G999G990D00') || '</tot_vldebito></totais>';
        
        -- Finalizar TAG XML
        vr_xmlb := vr_xmlb || '</root>';
        gene0002.pc_clob_buffer(pr_dados => vr_xmlb, pr_gravfim => TRUE, pr_clob => vr_xmlc);

        -- Gerar relatório
        gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper
                                   ,pr_cdprogra  => vr_cdprogra
                                   ,pr_dtmvtolt  => rw_crapdat.dtmvtolt 
                                   ,pr_dsxml     => vr_xmlc
                                   ,pr_dsxmlnode => '/root/valores/valor'
                                   ,pr_dsjasper  => 'crrl127.jasper'
                                   ,pr_dsparams  => NULL
                                   ,pr_dsarqsaid => vr_nom_dir || '/' || vr_nmarquiv
                                   ,pr_flg_gerar => 'N'
                                   ,pr_qtcoluna  => 132
                                   ,pr_sqcabrel  => 1
                                   ,pr_cdrelato  => NULL
                                   ,pr_flg_impri => 'N'
                                   ,pr_nmformul  => NULL
                                   ,pr_nrcopias  => 1
                                   ,pr_dsmailcop => NULL
                                   ,pr_dsassmail => NULL
                                   ,pr_dscormail => NULL
                                   ,pr_dspathcop => NULL
                                   ,pr_dsextcop  => NULL
                                   ,pr_flsemqueb => 'N'
                                   ,pr_des_erro  => pr_dscritic); 
      
        -- Finalizar XML
        dbms_lob.close(vr_xmlc);
        dbms_lob.freetemporary(vr_xmlc);
      END IF;
      
      -- Procedimento para eliminar o controle de reprocesso, pois o programa chegou ao fim
      btch0001.pc_elimina_restart(pr_cdcooper,
                                  vr_cdprogra,
                                  pr_flgresta,
                                  vr_dscritic);
                                  
      IF vr_dscritic IS NOT NULL THEN
        vr_cdcritic := 0;
        RAISE vr_exc_saida;
      END IF;

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
  END pc_crps160;
/

