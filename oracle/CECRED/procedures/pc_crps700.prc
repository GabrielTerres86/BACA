CREATE OR REPLACE PROCEDURE CECRED.pc_crps700 (
                                        pr_cdcooper IN crapcop.cdcooper%TYPE
                                       ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                                       ,pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada
  BEGIN
    /* .............................................................................

       Programa: pc_crps700
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Tiago Castro (RKAM)
       Data    : Janeiro/2016                     Ultima atualizacao: 17/05/16

       Dados referentes ao programa:

       Frequencia: Diário (JOB)
       Objetivo  : Popular a tabela de beneficiarios do INSS, apenas inicia JOBS
                   chamando crps700_1.

       Alteracoes: 05/04/2016 - PRJ 255 Fase 2 - Mudança no conceito, alterado para
                                apenas importar o arquivo de Prova de Vida enviado
                                pelo SICREDI (Guilherme/SUPERO)
                                
                   17/05/2016 - Incluido tratamento para gerar log de execução do job
                                no proc_batch (Odirlei-AMcom)             

    ............................................................................ */

    DECLARE

      ------------------------ VARIAVEIS PRINCIPAIS ----------------------------

      -- Código do programa
      vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'CRPS700';
      vr_nomdojob CONSTANT VARCHAR2(100) := 'JBINSS_IMP_BENEFICIARIO_700';

      -- Tratamento de erros
      vr_exc_saida  EXCEPTION;
      vr_exc_valid  EXCEPTION;
      vr_exc_email  EXCEPTION;
      vr_cdcritic   PLS_INTEGER;
      vr_dscritic   VARCHAR2(4000);
      vr_dscriti2   crapcri.dscritic%TYPE;
      vr_flgerlog   BOOLEAN := FALSE;

      -- Variaveis
      vr_dsdireto   VARCHAR2(200);
      vr_tab_linhas gene0009.typ_tab_linhas;
      vr_indice2    PLS_INTEGER;
      vr_contareg   PLS_INTEGER;
      vr_dsdanexo   VARCHAR2(200);
      vr_nmarquiv   VARCHAR2(20);

      lt_d_nrsequen   NUMBER:=0;
      lt_d_nrrecben   NUMBER:=0;
      lt_d_cdorgins   NUMBER:=0;
      lt_d_dtinclus   DATE;
      lt_d_dtvencpv   DATE;
      vr_houveerro    BOOLEAN:=FALSE;
      vr_linhaserro   VARCHAR2(1000);

      ------------------------------- CURSORES ---------------------------------

      -- Cursor genérico de calendário
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;

      -- Verificar se NB existe
      CURSOR cr_dcb(pr_nrrecben IN tbinss_dcb.nrrecben%TYPE)IS
        SELECT dcb.id_dcb
              ,dcb.dtvencpv
          FROM tbinss_dcb dcb
         WHERE dcb.nrrecben = pr_nrrecben;
      rw_dcb cr_dcb%ROWTYPE;

      -- Buscar o CPF do NB informado
      CURSOR cr_crapdbi(pr_nrrecben IN crapdbi.nrrecben%TYPE)IS
        SELECT dbi.rowid
              ,dbi.nrcpfcgc
          FROM crapdbi dbi
         WHERE dbi.nrrecben = pr_nrrecben
           AND rownum       = 1;
      rw_crapdbi cr_crapdbi%ROWTYPE;


      -- Buscar a Cooperativa do OP
      CURSOR cr_crapage(pr_cdorgins IN crapage.cdorgins%TYPE)IS
        SELECT age.cdagenci
              ,age.cdcooper
              ,cop.cdagesic
          FROM crapage age, crapcop cop
         WHERE cop.cdcooper = age.cdcooper
           AND age.cdorgins = pr_cdorgins;
      rw_crapage cr_crapage%ROWTYPE;

      -- Buscar as Contas do CPF
      CURSOR cr_crapttl(pr_cdcooper IN crapttl.cdcooper%TYPE
                       ,pr_nrcpfcgc IN crapttl.nrcpfcgc%TYPE)IS
        SELECT ttl.nrdconta
              ,ttl.nmextttl
          FROM crapttl ttl
         WHERE ttl.cdcooper = pr_cdcooper
           AND ttl.nrcpfcgc = pr_nrcpfcgc;
      rw_crapttl cr_crapttl%ROWTYPE;

      -- Verificar se a conta teve lancamento 1399 nos ultimos 3 meses
      CURSOR cr_craplcm_inss(pr_cdcooper IN crapcop.cdcooper%TYPE
                            ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE
                            ,pr_nrdconta IN tbinss_dcb.nrdconta%TYPE) IS
        SELECT 1
          FROM craplcm lcm
         WHERE lcm.cdcooper = pr_cdcooper
           AND lcm.nrdconta = pr_nrdconta
           AND lcm.cdhistor = 1399
           AND lcm.dtmvtolt <= pr_dtmvtolt
           AND lcm.dtmvtolt >= (pr_dtmvtolt - 90);
      rw_craplcm_inss cr_craplcm_inss%ROWTYPE;



      ---------------------------- ESTRUTURAS DE REGISTRO ---------------------

      ------------------------------- VARIAVEIS -------------------------------



      --------------------------- SUBROTINAS INTERNAS --------------------------
      --------------------------- SUBROTINAS INTERNAS --------------------------
      --> Controla log proc_batch, para apensa exibir qnd realmente processar informação
      PROCEDURE pc_controla_log_batch(pr_dstiplog IN VARCHAR2,
                                      pr_dscritic IN VARCHAR2 DEFAULT NULL) IS
      BEGIN
        
        --> Controlar geração de log de execução dos jobs 
        BTCH0001.pc_log_exec_job( pr_cdcooper  => nvl(pr_cdcooper,3) --> Cooperativa
                                 ,pr_cdprogra  => vr_cdprogra    --> Codigo do programa
                                 ,pr_nomdojob  => vr_nomdojob    --> Nome do job
                                 ,pr_dstiplog  => pr_dstiplog    --> Tipo de log(I-inicio,F-Fim,E-Erro)
                                 ,pr_dscritic  => pr_dscritic    --> Critica a ser apresentada em caso de erro
                                 ,pr_flgerlog  => vr_flgerlog);  --> Controla se gerou o log de inicio, sendo assim necessario apresentar log fim
          
      END pc_controla_log_batch;
      
      PROCEDURE gera_log(pr_cdcooper IN crapcop.cdcooper%TYPE
                        ,pr_cdprogra IN crapprg.cdprogra%TYPE
                        ,pr_indierro IN PLS_INTEGER
                        ,pr_cdcritic IN crapcri.cdcritic%TYPE
                        ,pr_dscritic IN crapcri.dscritic%TYPE) IS
      BEGIN
        -- Se foi retornado apenas código
        IF pr_cdcritic > 0 AND pr_dscritic IS NULL THEN
          -- Buscar a descrição
          vr_dscriti2 := gene0001.fn_busca_critica(pr_cdcritic);
        END IF;

        IF TRIM(pr_dscritic) IS NOT NULL THEN
           vr_dscriti2 := pr_dscritic;
        END IF;

        -- Envio centralizado de log de erro
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                  ,pr_des_log      => vr_dscriti2
                                  ,pr_nmarqlog     => 'log_crps700');

      EXCEPTION
        WHEN OTHERS THEN
            vr_cdcritic := 0;
            vr_dscritic := 'Problemas com geracao de Log';
            RAISE vr_exc_saida;
      END gera_log;

     
      --------------- VALIDACOES INICIAIS -----------------
    BEGIN
      --> Log de inicio de execução
      pc_controla_log_batch(pr_dstiplog => 'I');   

      -- Leitura do calendário da cooperativa
       OPEN btch0001.cr_crapdat(pr_cdcooper => 3);
         FETCH btch0001.cr_crapdat
          INTO rw_crapdat;
       CLOSE btch0001.cr_crapdat;

       -- Gerar hora inicio no log
       gera_log(pr_cdcooper => 3 --pr_cdcooper
               ,pr_cdprogra => vr_cdprogra
               ,pr_indierro => 2
               ,pr_cdcritic => 0
               ,pr_dscritic => to_char(SYSDATE,'DD/MM/YYYY HH24:MI:SS') ||
                                      ' - crps700 - INICIO.');



      --------------- REGRA DE NEGOCIO DO PROGRAMA -----------------
      vr_houveerro := FALSE;
      vr_dsdireto  := gene0001.fn_param_sistema('CRED', 1, 'DIR_INSS_RECEBE_PV');
      vr_nmarquiv  := 'PV_CECRED.csv';
      vr_dsdanexo  := vr_dsdireto || '/' || vr_nmarquiv;


      -- Verificar se existe arquivo na pasta padrão
      IF NOT gene0001.fn_exis_arquivo(pr_caminho => vr_dsdanexo) THEN
         vr_dscritic := 'Nao existe arquivo ' || vr_nmarquiv || ' na pasta!';
         RAISE vr_exc_saida;        
      END IF;

      -- Importar o arquivo utilizando o Layout, separado por Virgula
      gene0009.pc_importa_arq_layout(pr_nmlayout   => 'INSSVIDA'
                                    ,pr_dsdireto   => vr_dsdireto
                                    ,pr_nmarquiv   => vr_nmarquiv
                                    ,pr_dscritic   => vr_dscritic
                                    ,pr_tab_linhas => vr_tab_linhas);


      IF TRIM(vr_dscritic) IS NOT NULL THEN
         vr_dscritic := vr_dscritic || ' , Arquivo: ' || vr_nmarquiv;
         RAISE vr_exc_saida;
      END IF;


      vr_contareg := 0; -- Contador de Linhas

      -- Se menos que 2 linha (linha 1 = Cabeçalho)
      IF vr_tab_linhas.count < 2 THEN
        vr_dscritic := 'Arquivo ' || vr_nmarquiv || ' não possui conteúdo!';
        RAISE vr_exc_saida;
      END IF;


      -- Navegar em cada linha do arquivo aberto para leitura
      FOR vr_indice2 IN vr_tab_linhas.FIRST..vr_tab_linhas.LAST LOOP --LINHAS ARQUIVO

        IF vr_tab_linhas(vr_indice2).exists('$ERRO$') THEN --Problemas com importacao do layout
           vr_dscritic := vr_tab_linhas(vr_indice2)('$ERRO$').texto || ' . Arquivo: ' || vr_nmarquiv;
           RAISE vr_exc_saida;
        END IF;

        vr_contareg := vr_contareg + 1; --Conta qtd de linhas do arquivo

        -- Se for a linha de cabeçalho do arquivo
        IF  vr_contareg = 1 THEN
          CONTINUE;
        END IF;


        -- Coloca o conteudo da linha/coluna em cada campo
        BEGIN
--        lt_d_nrsequen := to_number(TRIM(REPLACE(vr_tab_linhas(vr_indice2)('NRSEQUEN').texto,'"','')));
--        lt_d_dtinclus := to_date(TRIM(REPLACE(vr_tab_linhas(vr_indice2)('DTINCLUS').texto,'"','')),'DD/MM/RRRR');
          lt_d_nrrecben := to_number(TRIM(REPLACE(vr_tab_linhas(vr_indice2)('NRRECBEN').texto,'"','')));
          lt_d_cdorgins := to_number(TRIM(REPLACE(vr_tab_linhas(vr_indice2)('CDORGINS').texto,'"','')));
          lt_d_dtvencpv := to_date(TRIM(REPLACE(vr_tab_linhas(vr_indice2)('DTVENCPV').texto,'"','')),'DD/MM/RRRR');
          

          IF (lt_d_nrrecben IS NULL OR lt_d_nrrecben = 0)
          OR (lt_d_cdorgins IS NULL OR lt_d_cdorgins = 0)
          OR (lt_d_dtvencpv IS NULL) THEN
            RAISE vr_exc_valid;
          END IF;
          
        EXCEPTION
          WHEN vr_exc_valid THEN -- Erro de Validação
            IF vr_houveerro THEN -- TRUE (Primeira vez, estará false)
              vr_linhaserro := vr_linhaserro || ', ' || vr_contareg;
            ELSE
              vr_linhaserro := vr_contareg;
            END IF;

            vr_houveerro  := TRUE;

            CONTINUE;
          WHEN OTHERS THEN   -- Erro de Atribuição / Tipo inválido
            IF vr_houveerro THEN -- TRUE (Primeira vez, estará false)
              vr_linhaserro := vr_linhaserro || ', ' || vr_contareg;
            ELSE
              vr_linhaserro := vr_contareg;
            END IF;

            vr_houveerro  := TRUE;

            CONTINUE;
        END;


        -- Verificar se o NB do arquivo já está na base
        OPEN cr_dcb(pr_nrrecben => lt_d_nrrecben);
        FETCH cr_dcb INTO rw_dcb;

        IF cr_dcb%NOTFOUND THEN -- Se o NB ainda não está na base, criar

          CLOSE cr_dcb;

          -- Buscar o CPF do NB do arquivo
          OPEN cr_crapdbi(pr_nrrecben => lt_d_nrrecben);
          FETCH cr_crapdbi INTO rw_crapdbi;
          IF cr_crapdbi%NOTFOUND THEN
            CLOSE cr_crapdbi;
            -- Gera LOG
            gera_log(pr_cdcooper => 3 --pr_cdcooper
                    ,pr_cdprogra => vr_cdprogra
                    ,pr_indierro => 1
                    ,pr_cdcritic => 0
                    ,pr_dscritic => ' => CPF do NB do arquivo não localizado! NB: ' || lt_d_nrrecben);

            CONTINUE; -- Passa para próxima linha do arquivo
          END IF;
          CLOSE cr_crapdbi;


          -- Verificar a cooperativa do OP/NB
          OPEN cr_crapage(pr_cdorgins => lt_d_cdorgins);
          FETCH cr_crapage INTO rw_crapage;
          IF cr_crapage%NOTFOUND THEN
            CLOSE cr_crapage;
            -- Gera LOG
            gera_log(pr_cdcooper => 3 --pr_cdcooper
                    ,pr_cdprogra => vr_cdprogra
                    ,pr_indierro => 1
                    ,pr_cdcritic => 0
                    ,pr_dscritic => ' => OP do arquivo não localizado! OP: '|| lt_d_cdorgins
                                    || ' - NB: ' || lt_d_nrrecben);
            CONTINUE; -- Passa para próxima linha do arquivo
          END IF;
          CLOSE cr_crapage;

          -- Buscar as Contas do CPF
          OPEN cr_crapttl(pr_cdcooper => rw_crapage.cdcooper
                         ,pr_nrcpfcgc => rw_crapdbi.nrcpfcgc);
          FETCH cr_crapttl INTO rw_crapttl;
          IF cr_crapttl%NOTFOUND THEN
            CLOSE cr_crapttl;
            -- Gera LOG
            gera_log(pr_cdcooper => 3 --pr_cdcooper
                    ,pr_cdprogra => vr_cdprogra
                    ,pr_indierro => 1
                    ,pr_cdcritic => 0
                    ,pr_dscritic => ' => Titular não localizado com o CPF: ' || rw_crapdbi.nrcpfcgc);

            CONTINUE; -- Passa para próxima linha do arquivo
          ELSE -- SE Encontrou
            -- Para todas as contas que encontrar com esse CPF
            LOOP

              -- SAI DO LOOP QUANDO CHEGAR AO FIM DOS REGISTROS
              EXIT WHEN cr_crapttl%NOTFOUND;

              -- Verificar se a conta possui LCM 1399 nos ultimos 3 meses
              OPEN cr_craplcm_inss(pr_cdcooper => rw_crapage.cdcooper,
                                   pr_dtmvtolt => rw_crapdat.dtmvtolt,
                                   pr_nrdconta => rw_crapttl.nrdconta);
              FETCH cr_craplcm_inss INTO rw_craplcm_inss;

              IF cr_craplcm_inss%NOTFOUND THEN
                FETCH cr_crapttl INTO rw_crapttl;
                CLOSE cr_craplcm_inss;
                CONTINUE; -- Passa para próxima Conta TTL
              END IF;
              CLOSE cr_craplcm_inss;
              -- Gravar tbinss_dcb apenas para as contas que receberam
              -- credito de beneficio(1399) nos ultimos 3 meses.
              -- Se nao recebeu, não grava.

              -- Criar o registro
              INSERT INTO tbinss_dcb(id_dcb
                                    ,cdcooper
                                    ,nrdconta
                                    ,dtvencpv
                                    ,DTCOMPET
                                    ,NMEMISSOR
                                    ,NRCNPJ_EMISSOR
                                    ,NMBENEFI
                                    ,NRRECBEN
                                    ,CDORGINS
                                    ,NRCPF_BENEFI
                                    ,CDAGENCIA_CONV  )
                            VALUES(fn_sequence('TBINSS_DCB','ID_DCB','ID_DCB')
                                  ,rw_crapage.cdcooper
                                  ,rw_crapttl.nrdconta
                                  ,lt_d_dtvencpv
                                  ,to_date('01/01/2008','dd/mm/RRRR')
                                  ,'INSTITUTO NACIONAL DO SEGURO SOCIAL'
                                  ,29979036000140
                                  ,rw_crapttl.nmextttl
                                  ,lt_d_nrrecben
                                  ,lt_d_cdorgins
                                  ,rw_crapdbi.nrcpfcgc
                                  ,rw_crapage.cdagesic
                                   ) RETURNING id_dcb INTO rw_dcb.id_dcb;

              FETCH cr_crapttl INTO rw_crapttl;
            END LOOP; -- FIM LOOP TTL
            CLOSE cr_crapttl;
          END IF; -- IF FOUND/NOTFOUND - cr_crapttl

        ELSE -- Se encontrou, atualizar

          -- Para DCB desse NB
          LOOP

            -- SAI DO LOOP QUANDO CHEGAR AO FIM DOS REGISTROS
            EXIT WHEN cr_dcb%NOTFOUND;

            -- Verificar se a data no Arquivo é Maior que a data da Base
            IF lt_d_dtvencpv > rw_dcb.dtvencpv
            OR rw_dcb.dtvencpv IS NULL THEN

              -- Atualizar o registro
              UPDATE tbinss_dcb
                 SET tbinss_dcb.dtvencpv = lt_d_dtvencpv
               WHERE tbinss_dcb.id_dcb   = rw_dcb.id_dcb;

            END IF;

            FETCH cr_dcb INTO rw_dcb;
          END LOOP;
          CLOSE cr_dcb;

        END IF;

        COMMIT; -- Ao termino de cada linha, COMMIT

      END LOOP;  -- LOOP de Linhas do Arquivo


      IF  vr_houveerro THEN
        
          vr_dscritic := 'Nao foi possivel realizar a importacao da planilha. Erro linha(s): ' 
                         || vr_linhaserro || '. Arquivo: ' || vr_nmarquiv;
          -- Gera LOG
          gera_log(pr_cdcooper => 3 --pr_cdcooper
                  ,pr_cdprogra => vr_cdprogra
                  ,pr_indierro => 1
                  ,pr_cdcritic => 0
                  ,pr_dscritic => ' => ' || vr_dscritic);

          -- Mandar email para INSS com a planilha e a linha com erro.
          gene0003.pc_solicita_email(pr_cdcooper        => 3 --pr_cdcooper
                                    ,pr_cdprogra        => 'CRPS700'
                                    ,pr_des_destino     => 'inss@cecred.coop.br'
                                    ,pr_des_assunto     => 'SICREDI - PLANILHA PROVA DE VIDA - ERRO'
                                    ,pr_des_corpo       => vr_dscritic  ||
                                                           '</br></br>' ||
                                                           'As ' ||
                                                           to_char(SYSDATE,'dd/mm/RRRR hh24:mi:ss')
                                    ,pr_des_anexo       => vr_dsdanexo
                                    ,pr_flg_remove_anex => 'N' --> Remover os anexos passados
                                    ,pr_flg_remete_coop => 'N' --> Se o envio sera do e-mail da Cooperativa
                                    ,pr_flg_enviar      => 'S' --> Enviar o e-mail na hora
                                    ,pr_des_erro        => vr_dscritic);
          -- Se houver erros
          IF vr_dscritic IS NOT NULL THEN
            -- Gera critica
            vr_cdcritic := 0;
            vr_dscritic := 'Erro no envio do Email!' || '. Erro: '||vr_dscritic;
            RAISE vr_exc_saida;
          END IF;

        
      END IF;


      ----------------- ENCERRAMENTO DO PROGRAMA -------------------

      -- Gerar hora Fim no log
      gera_log(pr_cdcooper => 3 --pr_cdcooper
              ,pr_cdprogra => vr_cdprogra
              ,pr_indierro => 2
              ,pr_cdcritic => 0
              ,pr_dscritic => to_char(SYSDATE,'DD/MM/YYYY HH24:MI:SS') ||
                                      ' - ' || vr_cdprogra || ' - FIM.');


      --> Log de final de execução
      pc_controla_log_batch(pr_dstiplog => 'F');
      
    EXCEPTION
      WHEN vr_exc_saida THEN -- SAIDA SEM ENVIO DE EMAIL
        -- Se foi retornado apenas código
        IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
          -- Buscar a descrição
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;
        -- Devolvemos código e critica encontradas das variaveis locais
        pr_cdcritic := NVL(vr_cdcritic,0);
        pr_dscritic := vr_dscritic;

        -- gera log do erro
        gera_log(pr_cdcooper => 3 --pr_cdcooper
                ,pr_cdprogra => vr_cdprogra
                ,pr_indierro => 1
                ,pr_cdcritic => 0
                ,pr_dscritic => ' => '|| vr_dscritic);

        --> Final da execução com ERRO
        pc_controla_log_batch(pr_dstiplog => 'E',
                              pr_dscritic => vr_dscritic);
                          
        -- Efetuar rollback
        ROLLBACK;



      WHEN OTHERS THEN
        -- Efetuar retorno do erro não tratado
        pr_cdcritic := 0;
        pr_dscritic := sqlerrm;
        -- gera log do erro
        gera_log(pr_cdcooper => 3 --pr_cdcooper
                ,pr_cdprogra => vr_cdprogra
                ,pr_indierro => 1
                ,pr_cdcritic => 0
                ,pr_dscritic => ' => when OTHERS: ' || pr_dscritic || ' SEQ: ' || vr_contareg);

        --> Final da execução com ERRO
        pc_controla_log_batch(pr_dstiplog => 'E',
                              pr_dscritic => vr_dscritic);
                          
        -- Efetuar rollback
        ROLLBACK;
    END;

  END pc_crps700;
