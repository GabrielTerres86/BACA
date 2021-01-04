PL/SQL Developer Test script 3.0
585
declare 

  wpr_cdcooper     NUMBER := 2; -- Será rodado para 2 - Acredicoop e 1 - Viacredi(somente após validarmos para a 2 - Acredicoop).
  wpr_dtrefere     VARCHAR(8) := '31122020';
  wpr_dtrefere_aux VARCHAR(8) := '30122020';
  wpr_stprogra     PLS_INTEGER;
  wpr_infimsol     PLS_INTEGER;
  wpr_cdcritic     crapcri.cdcritic%TYPE;
  wpr_dscritic     VARCHAR2(32767);

  PROCEDURE pc_central_risco_grupo_wag(pr_cdcooper IN NUMBER           --> Cooperativa
                                      ,pr_dtrefere IN DATE             -- Data do dia da Coop
                                      ,pr_dtmvtoan IN DATE             -- Data da central anterior
                                      ,pr_dscritic OUT VARCHAR2) IS   --> Critica

    -- ESTE CURSOR INDICA EM QUAL GRUPO TAL CPF/CNPJ DEVERIA ESTAR
    CURSOR cr_grupo_cpf (pr_cdcooper IN crapcop.cdcooper%TYPE) IS
      SELECT DISTINCT grp.cdcooper
                    , grp.tppessoa
                    , grp.nrcpfcnpj_base
                    , first_value(idgrupo) over (partition by nrcpfcnpj_base
                                                     order by dtinclusao, idgrupo
                                                   rows unbounded preceding) as nrdgrupo
        FROM (SELECT dados.*
                FROM (SELECT int.cdcooper
                           , int.tppessoa
                           , CASE WHEN int.tppessoa = 1                      then int.nrcpfcgc
                                  WHEN int.tppessoa = 2 and int.nrcpfcgc > 0 then to_number(substr(to_char(int.nrcpfcgc,'FM00000000000000'),1,8))
                                  ELSE NULL
                             END AS nrcpfcnpj_base
                           , int.dtinclusao
                           , int.idgrupo
                        FROM tbcc_grupo_economico_integ int
                       WHERE int.dtexclusao IS NULL
                         AND int.cdcooper = pr_cdcooper
                       UNION
                      SELECT pai.cdcooper
                           , ass.inpessoa
                           , ass.nrcpfcnpj_base
                           , pai.dtinclusao
                           , pai.idgrupo
                        FROM tbcc_grupo_economico       pai
                           , crapass                    ass
                           , tbcc_grupo_economico_integ int
                       WHERE ass.cdcooper = pai.cdcooper
                         AND ass.nrdconta = pai.nrdconta
                         AND int.idgrupo  = pai.idgrupo
                         AND int.dtexclusao is null
                         AND pai.cdcooper = pr_cdcooper
                         AND ass.cdcooper = pr_cdcooper
                    ) dados
              ORDER BY 1,2,3,4
        ) grp;
    rw_grupo_cpf cr_grupo_cpf%ROWTYPE;

    CURSOR cr_ass_contas (pr_cdcooper IN crapcop.cdcooper%TYPE
                         ,pr_nrcpfcgc IN crapass.nrcpfcnpj_base%TYPE) IS
      SELECT ass.nrdconta
            ,ass.cdcooper
            ,ass.nrcpfcgc
        FROM crapass ass
       WHERE ass.cdcooper = pr_cdcooper
         AND ass.Nrcpfcnpj_Base = pr_nrcpfcgc;
    rw_ass_contas cr_ass_contas%ROWTYPE;


    -- ENCONTRAR O MAIOR RISCO DO GRUPO
    CURSOR cr_risco_grupo (pr_cdcooper IN crapcop.cdcooper%TYPE
                          ,pr_dtrefere IN crapris.dtrefere%TYPE) IS
      SELECT r.nrdgrupo
           , MAX(r.innivris) risco_grupo
        FROM crapris r
       WHERE r.cdcooper = pr_cdcooper
         AND r.dtrefere = pr_dtrefere
         AND r.nrdgrupo > 0
         AND r.innivris > 1  -- Risco AA não participa
       GROUP BY r.nrdgrupo;
    rw_risco_grupo cr_risco_grupo%ROWTYPE;

    -- LISTAR TODAS AS CONTAS DE UM GRUPO
    CURSOR cr_contas_grupo (pr_cdcooper IN crapcop.cdcooper%TYPE
                           ,pr_idgrupo  IN tbcc_grupo_economico.idgrupo%TYPE) IS
      SELECT *
        FROM (SELECT int.idgrupo
                    ,int.nrdconta
                FROM tbcc_grupo_economico_integ INT
                    ,tbcc_grupo_economico p
               WHERE int.dtexclusao IS NULL
                 AND int.cdcooper = pr_cdcooper
                 AND int.idgrupo  = p.idgrupo
              UNION
              SELECT pai.idgrupo
                    ,pai.nrdconta
                FROM tbcc_grupo_economico       pai
                   , crapass                    ass
                   , tbcc_grupo_economico_integ int
               WHERE ass.cdcooper = pai.cdcooper
                 AND ass.nrdconta = pai.nrdconta
                 AND int.idgrupo  = pai.idgrupo
                 AND int.dtexclusao is NULL
                 AND ass.cdcooper = pr_cdcooper
                 AND pai.cdcooper = pr_cdcooper
            ) dados
       WHERE dados.idgrupo = pr_idgrupo;
    rw_contas_grupo cr_contas_grupo%ROWTYPE;

    -- Cadastro de informacoes de central de riscos
    CURSOR cr_crapris(pr_cdcooper IN crapcop.cdcooper%TYPE
                     ,pr_nrdconta IN crapris.nrdconta%TYPE
                     ,pr_dtrefere IN crapris.dtrefere%TYPE
                     ,pr_innivris IN crapris.innivris%TYPE) IS
      SELECT /*+ INDEX(crapris CRAPRIS##CRAPRIS1) */
              ris.cdcooper
             ,ris.dtrefere
             ,ris.nrdconta
             ,ris.innivris
             ,ris.cdmodali
             ,ris.cdorigem
             ,ris.nrctremp
             ,ris.nrseqctr
             ,ris.qtdiaatr
             ,ris.progress_recid
        FROM crapris ris
       WHERE ris.cdcooper = pr_cdcooper
         AND ris.dtrefere = pr_dtrefere
         AND ris.nrdconta = pr_nrdconta
         AND (    ris.innivris < pr_innivris -- Menor que o risco do grupo
              AND ris.innivris > 1)  -- Risco AA não participa
         --AND ris.inddocto = 1
         AND (ris.inddocto = 1 OR ris.cdmodali = 1901)
         ;
    rw_crapris cr_crapris%ROWTYPE;

    CURSOR cr_crapris_last(pr_nrdconta IN crapris.nrdconta%TYPE
                          ,pr_nrctremp IN crapris.nrctremp%TYPE
                          ,pr_cdmodali IN crapris.cdmodali%TYPE
                          ,pr_cdorigem IN crapris.cdorigem%TYPE
                          ,pr_dtrefere in crapris.dtrefere%TYPE) IS
         SELECT r.dtrefere
              , r.innivris
              , r.dtdrisco
          FROM stage.stg_crapris@bidw_temp r -- _TODO ADICIONAR DBLINK para o BI
         WHERE r.cdcooper = pr_cdcooper
           AND r.nrdconta = pr_nrdconta
           AND r.dtrefere = pr_dtrefere
           AND r.nrctremp = pr_nrctremp
           AND r.cdmodali = pr_cdmodali
           AND r.cdorigem = pr_cdorigem
           --AND r.inddocto = 1 -- 3020 e 3030
           AND (r.inddocto = 1 OR r.cdmodali = 1901)
           AND r.innivris > 1  -- Risco AA não participa
         ORDER BY r.dtrefere DESC --> Retornar o ultimo gravado
                , r.innivris DESC --> Retornar o ultimo gravado
                , r.dtdrisco DESC;
    rw_crapris_last cr_crapris_last%ROWTYPE;

    -- cadastro do vencimento do risco
    CURSOR cr_crapvri( pr_cdcooper IN crapris.cdcooper%TYPE
                      ,pr_dtrefere IN crapris.dtrefere%TYPE
                      ,pr_nrdconta IN crapris.nrdconta%TYPE
                      ,pr_innivris IN crapris.innivris%TYPE
                      ,pr_cdmodali IN crapris.cdmodali%TYPE
                      ,pr_nrctremp IN crapris.nrctremp%TYPE
                      ,pr_nrseqctr IN crapris.nrseqctr%TYPE
                      ) IS
      SELECT ROWID
        FROM crapvri vri
       WHERE vri.cdcooper = pr_cdcooper
         AND vri.dtrefere = pr_dtrefere
         AND vri.nrdconta = pr_nrdconta
         AND vri.innivris = pr_innivris
         AND vri.cdmodali = pr_cdmodali
         AND vri.nrctremp = pr_nrctremp
         AND vri.nrseqctr = pr_nrseqctr;
    rw_crapvri cr_crapvri%ROWTYPE;

    -- variaveis
    vr_maxrisco             INTEGER:= -10;
    vr_dtdrisco             crapris.dtdrisco%TYPE; -- Data da atualização do risco
    vr_dttrfprj             DATE;

    -- Variaveis de Erro
    vr_cdcritic             crapcri.cdcritic%TYPE;
    vr_dscritic             VARCHAR2(4000);
    vr_exc_erro             EXCEPTION;

    vr_nrcpfcnpj_base       crapass.nrcpfcnpj_base%TYPE;

   BEGIN

     -------------------------------------------------------------
     ----- GRUPO ECONOMICO - GRAVAR GRUPO NA CENTRAL DE RISCO ----
     -------------------------------------------------------------
     -- PERCORRE TODOS OS GRUPOS DA COOPERATIVA
     -- IDENTIFICA EM QUAL GRUPO O CPF/CNPJ DEVE ESTAR
     FOR rw_grupo_cpf IN cr_grupo_cpf (pr_cdcooper => pr_cdcooper) LOOP

       -- PEGAR TODAS AS CONTAS DE UM CPF/CNPJ PARA ATUALIZAR O GRUPO NA CENTRAL
       FOR rw_ass_contas IN cr_ass_contas (pr_cdcooper => pr_cdcooper
                                          ,pr_nrcpfcgc => rw_grupo_cpf.nrcpfcnpj_base) LOOP

         BEGIN
           -- ATUALIZAR GRUPO NA CENTRAL DE RISCO
           UPDATE crapris r
              SET r.nrdgrupo = rw_grupo_cpf.nrdgrupo
            WHERE r.cdcooper = rw_ass_contas.cdcooper
              AND r.nrdconta = rw_ass_contas.nrdconta
              AND r.dtrefere = pr_dtrefere;

         EXCEPTION
           WHEN OTHERS THEN
             vr_dscritic := 'RISC0004.pc_central_risco_grupo_wag - '
                            || 'Erro ao definir G.E. na Central de Risco --> '
                            ||'Conta: '||rw_ass_contas.nrdconta
                            ||'Grupo: '||rw_grupo_cpf.nrdgrupo
                            || '. Detalhes:'||SQLERRM;
              btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                        ,pr_ind_tipo_log => 2 -- Erro tratado
                                        ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                         || 'RISC0004 || ' --> '
                                                         || vr_dscritic );
             RAISE vr_exc_erro;
         END;

       END LOOP;
     END LOOP;

     ---------------------------------------------------------
     ----- RISCO DO GRUPO - ATUALIZAR NA CENTRAL DE RISCO ----
     ---------------------------------------------------------
     -- AGRUPAR POR GRUPO E VERIFICAR O MAIOR RISCO DO GRUPO
     FOR rw_risco_grupo IN cr_risco_grupo (pr_cdcooper => pr_cdcooper
                                          ,pr_dtrefere => pr_dtrefere) LOOP

         -- MAIOR RISCO DO GRUPO
       vr_maxrisco := rw_risco_grupo.risco_grupo;
       -- NAO LEVA PARA O PREJUIZO
       IF vr_maxrisco = 10 THEN
         vr_maxrisco := 9;
       END IF;

       -- LISTA DE CONTAS DO GRUPO
       FOR rw_contas_grupo IN cr_contas_grupo (pr_cdcooper => pr_cdcooper
                                              ,pr_idgrupo  => rw_risco_grupo.nrdgrupo) LOOP

         -- BUSCA NA CENTRAL CONTAS QUE TEM RISCO MENOR QUE O RISCO DO GRUPO
         FOR rw_crapris IN cr_crapris(pr_cdcooper => pr_cdcooper
                                     ,pr_nrdconta => rw_contas_grupo.nrdconta
                                     ,pr_dtrefere => pr_dtrefere -- Data do Dia
                                     ,pr_innivris => vr_maxrisco) LOOP

           -- Busca dos dados do ultimo risco de origem 1
           OPEN cr_crapris_last(pr_nrdconta => rw_crapris.nrdconta
                               ,pr_nrctremp => rw_crapris.nrctremp
                               ,pr_cdmodali => rw_crapris.cdmodali
                               ,pr_cdorigem => rw_crapris.cdorigem
                               ,pr_dtrefere => pr_dtmvtoan); -- Data da Central anterior
           FETCH cr_crapris_last
            INTO rw_crapris_last;
           -- Se encontrou
           IF cr_crapris_last%FOUND THEN
             -- RISCO DE "ONTEM" DIFERENTE DO DE "HOJE" ?
             IF (rw_crapris_last.innivris <> vr_maxrisco) THEN
               vr_dtdrisco := pr_dtrefere;
             ELSE
               -- Utilizar a data do ultimo risco
               IF rw_crapris_last.dtdrisco IS NULL THEN
                 vr_dtdrisco := pr_dtrefere;
               ELSE
                 -- Utilizar a data do ultimo risco
                 vr_dtdrisco := rw_crapris_last.dtdrisco;
               END IF;
             END IF;
           ELSE
             -- Utilizar a data de referência do processo
             vr_dtdrisco := pr_dtrefere;
           END IF;
           -- Fechar o cursor
           CLOSE cr_crapris_last;

           vr_dttrfprj := NULL;
           IF vr_maxrisco >= 9 THEN
             vr_dttrfprj := PREJ0001.fn_regra_dtprevisao_prejuizo(pr_cdcooper,
                                                                  vr_maxrisco,
                                                                  rw_crapris.qtdiaatr,
                                                                  vr_dtdrisco);
           END IF;

           -- Atualiza CENTRAL de RISCOS
           BEGIN
             UPDATE crapris
                SET crapris.innivris = vr_maxrisco,
                    crapris.inindris = vr_maxrisco,
                    crapris.dtdrisco = vr_dtdrisco,
                    crapris.dttrfprj = vr_dttrfprj
              WHERE cdcooper         = rw_crapris.cdcooper
                AND nrdconta         = rw_crapris.nrdconta
                AND dtrefere         = rw_crapris.dtrefere
                AND innivris         = rw_crapris.innivris
                AND progress_recid   = rw_crapris.progress_recid;
           EXCEPTION
             WHEN OTHERS THEN
               --gera critica
               vr_dscritic := 'RISC0004.pc_central_risco_grupo_wag: Erro ao atualizar Riscos G.E.(crapris). '||
                              'Erro: '||SQLERRM;
               RAISE vr_exc_erro;
           END;
           --busca vencimento de riscos
           FOR rw_crapvri IN cr_crapvri( rw_crapris.cdcooper
                                        ,rw_crapris.dtrefere
                                        ,rw_crapris.nrdconta
                                        ,rw_crapris.innivris
                                        ,rw_crapris.cdmodali
                                        ,rw_crapris.nrctremp
                                        ,rw_crapris.nrseqctr ) LOOP

             BEGIN -- atualiza vencimento dos riscos
                UPDATE crapvri
                   SET crapvri.innivris = vr_maxrisco
                 WHERE ROWID = rw_crapvri.rowid;
              EXCEPTION
                WHEN OTHERS THEN
                  --gera critica
                   vr_dscritic := 'Erro ao atualizar Vencimento do risco(crapvri). '||
                                  'Erro: '||SQLERRM;
                   RAISE vr_exc_erro;
              END;
            END LOOP; -- FIM FOR rw_crapvri
          END LOOP; -- FIM FOR rw_crapris

          -- Atualizar o nível de risco da conta conforme o maior risco do grupo (Heckmann/AMcom)
          BEGIN
            UPDATE crapass
               SET dsnivris = risc0004.fn_traduz_risco(vr_maxrisco)
             WHERE cdcooper = pr_cdcooper
               AND nrdconta = rw_contas_grupo.nrdconta;
          EXCEPTION
          WHEN OTHERS THEN
            --gera critica
            vr_dscritic := 'Erro ao atualizar o nível de risco da conta conforme o maior risco do grupo (crapass). '||
                           'Erro: '||SQLERRM;
            RAISE vr_exc_erro;
          END; -- Fim atualização do nível de risco do grupo

        END LOOP; -- FIM FOR rw_contas_grupo

        -- Leitura de todos do grupo para atualizar o risco do grupo
        BEGIN
          UPDATE tbcc_grupo_economico ge
             SET ge.inrisco_grupo = vr_maxrisco
           WHERE ge.cdcooper = pr_cdcooper
             AND ge.idgrupo  = rw_risco_grupo.nrdgrupo;
        EXCEPTION
          WHEN OTHERS THEN
            -- No caso de erro de programa gravar tabela especifica de log
            CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);
            vr_dscritic := 'RISC0004.pc_central_risco_grupo_wag - '
                         || 'Erro ao atualizar Risco do G.E. - '
                         || 'Grupo: '|| rw_risco_grupo.nrdgrupo
                         || '. Detalhes:'||SQLERRM;
            btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                      ,pr_ind_tipo_log => 2 -- Erro tratado
                                      ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                         || 'RISC0004 || ' --> '
                                                         || vr_dscritic );
            RAISE vr_exc_erro;
        END;
      END LOOP; -- FIM FOR rw_risco_grupo


   EXCEPTION
     WHEN vr_exc_erro THEN
       ROLLBACK;
       -- Variavel de erro recebe erro ocorrido
       IF nvl(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
         -- Buscar a descrição
         vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
       END IF;
       pr_dscritic := vr_dscritic;
     WHEN OTHERS THEN
       ROLLBACK;
       -- Descricao do erro
       pr_dscritic := 'Erro nao tratado na pc_central_risco_grupo_wag --> ' || SQLERRM;

  END pc_central_risco_grupo_wag;

  PROCEDURE pc_crps635_wag(  pr_cdcooper    IN crapcop.cdcooper%TYPE   --> Cooperativa solicitada
                            ,pr_dtrefere    IN crapdat.dtmvtolt%TYPE   --> Data referencia
                            ,pr_vlr_arrasto IN crapris.vldivida%TYPE   --> Valor da dívida
                            ,pr_flgresta    IN PLS_INTEGER             --> Flag padrÃ£o para utilização de restart
                            ,pr_stprogra    OUT PLS_INTEGER            --> Saída de termino da execução
                            ,pr_infimsol    OUT PLS_INTEGER            --> Saída de termino da solicitação
                            ,pr_cdcritic    OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                            ,pr_dscritic    OUT VARCHAR2) IS           --> Texto de erro/critica encontrada
  BEGIN

    DECLARE

      ------------------------ VARIAVEIS PRINCIPAIS ----------------------------
      -- Código do programa
      vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'CRPS635_i';

      -- Tratamento de erros
      vr_exc_saida    EXCEPTION;
      vr_exc_fimprg   EXCEPTION;
      vr_cdcritic     PLS_INTEGER;
      vr_dscritic     VARCHAR2(4000);

      vr_datautil     DATE;       --> Auxiliar para busca da data
      vr_dtrefere     DATE;       --> Data de referÃªncia do processo
      vr_dtrefere_aux DATE;       --> Data de referÃªncia auxiliar do processo
      vr_dtdrisco     crapris.dtdrisco%TYPE; -- Data da atualizaÃ§Ã£o do risco
      vr_dttrfprj     DATE;
      
      ------------------------------- CURSORES ---------------------------------
      -- Cadastro de informacoes de central de riscos
      CURSOR cr_crapris(pr_nrctasoc IN crapris.nrdconta%TYPE) IS
        SELECT  /*+ INDEX(crapris CRAPRIS##CRAPRIS1) */
                 crapris.cdcooper
                ,crapris.dtrefere
                ,crapris.nrdconta
                ,crapris.innivris
                ,crapris.cdmodali
                ,crapris.cdorigem
                ,crapris.nrctremp
                ,crapris.nrseqctr
                ,crapris.qtdiaatr
                ,crapris.progress_recid
        FROM    crapris 
        WHERE   crapris.cdcooper = pr_cdcooper
        AND     crapris.nrdconta = pr_nrctasoc
        AND     crapris.dtrefere = pr_dtrefere
        AND     crapris.inddocto = 1
        AND     crapris.inindris < 10;
      rw_crapris cr_crapris%ROWTYPE;

      ----  PROCEDURES INTERNAS ----
      -- Validar a data do risco
      PROCEDURE pc_validar_data_risco(pr_des_erro OUT VARCHAR2) IS

        -- Variaveis auxiliares
        vr_dsmsgerr     VARCHAR2(200);
        vr_maxrisco     INTEGER:=-10;

        -- Busca de todos os riscos
        CURSOR cr_crapris (pr_dtrefant IN crapris.dtrefere%TYPE) IS
          SELECT /*+ INDEX (ris CRAPRIS##CRAPRIS2) */
                 ris.cdcooper
               , ris.nrdconta
               , ris.nrctremp
               , ris.qtdiaatr
               , ris.innivris   risco_atual
               , r_ant.innivris risco_anterior
               , ris.dtdrisco   dtdrisco_atual
               , r_ant.dtdrisco dtdrisco_anterior
               , ris.rowid
            FROM crapris ris
               , (SELECT /*+ INDEX (r CRAPRIS##CRAPRIS2) */ * -- Busca risco anterior
                    FROM crapris r
                   WHERE r.dtrefere = pr_dtrefant
                     AND r.cdcooper = pr_cdcooper) r_ant
           WHERE ris.dtrefere   = vr_dtrefere
             AND ris.cdcooper   = pr_cdcooper
             AND r_ant.cdcooper = ris.cdcooper
             AND r_ant.nrdconta = ris.nrdconta
             AND r_ant.nrctremp = ris.nrctremp
             AND r_ant.cdmodali = ris.cdmodali
             AND r_ant.cdorigem = ris.cdorigem
             -- Quando o nível de risco for o mesmo e a data ainda estiver divergente
             AND (r_ant.innivris = ris.innivris AND r_ant.dtdrisco <> ris.dtdrisco);

    BEGIN

          vr_dtrefere_aux := to_date(wpr_dtrefere_aux,'ddmmyyyy');

          FOR rw_crapris IN cr_crapris (vr_dtrefere_aux) LOOP
            vr_dttrfprj := NULL;
            IF rw_crapris.risco_atual >= 9 THEN
              vr_dttrfprj := PREJ0001.fn_regra_dtprevisao_prejuizo(pr_cdcooper,
                                                                   rw_crapris.risco_atual,
                                                                   rw_crapris.qtdiaatr,
                                                                   rw_crapris.dtdrisco_anterior);
            END IF;
            --
            -- atualiza data dos riscos que não sofreram alteração de risco
            BEGIN
              UPDATE crapris r
                 SET r.dtdrisco = rw_crapris.dtdrisco_anterior
                    ,r.dttrfprj = vr_dttrfprj
               WHERE r.rowid    = rw_crapris.rowid;
            EXCEPTION
              WHEN OTHERS THEN
                cecred.pc_internal_exception;
                --gera critica
                vr_dscritic := 'Erro ao atualizar Data do risco da Central de Risco(crapris). '||
                             ' ROWID: ' || rw_crapris.rowid || ' Data Ant: ' || rw_crapris.dtdrisco_anterior ||
                             '. Detalhes:'||SQLERRM;
              btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                        ,pr_ind_tipo_log => 2 -- Erro tratado
                                        ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                         || vr_cdprogra || ' --> '
                                                         || vr_dscritic );
                RAISE vr_exc_fimprg;
            END;
          END LOOP;

        EXCEPTION
          WHEN vr_exc_fimprg THEN
               pr_des_erro := 'pc_validar_data_risco --> Erro ao processar Data do Risco. Detalhes: '||vr_dscritic;
          WHEN OTHERS THEN
            cecred.pc_internal_exception;
               pr_des_erro := 'pc_validar_data_risco --> Erro nÃ£o tratado ao processar Data do Risco. Detalhes: '||sqlerrm;
        END; -- FIM PROCEDURE pc_validar_data_risco

    BEGIN
      ----------------------------------------------------------------------
      -- NOVA ROTINA PARA CALCULO RISCO GRUPO E GRAVAÃ¿Ã¿O NA CENTRAL RISCO --
      ----------------------------------------------------------------------
      -- risc0004.pc_central_risco_grupo
      pc_central_risco_grupo_wag(pr_cdcooper => pr_cdcooper,
                                 pr_dtrefere => pr_dtrefere,     -- Data do dia da Coop
                                 pr_dtmvtoan => to_date(wpr_dtrefere_aux,'ddmmyyyy'), -- Data da central anterior
                                 pr_dscritic => vr_dscritic);
      -- Se retornou derro
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_fimprg;
      END IF;

      ---------------------------------------------------------------------
      -------------------------------- FIM --------------------------------
      ---------------------------------------------------------------------
      pc_validar_data_risco(pr_des_erro => vr_dscritic);
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_fimprg;
      END IF;

    EXCEPTION
      WHEN vr_exc_fimprg THEN
        -- Efetuar rollback
        pr_dscritic := vr_dscritic;
        ROLLBACK;
      WHEN OTHERS THEN
        cecred.pc_internal_exception;
        -- Efetuar retorno do erro nÃ£o tratado
        pr_cdcritic := 0;
        pr_dscritic := sqlerrm;
        -- Efetuar rollback
        ROLLBACK;
    END;
  END pc_crps635_wag;

-- CHAMADA PRINCIPAL
BEGIN
  -- chama procedura para atualizar tabela de riscos
  pc_crps635_wag(pr_cdcooper    => wpr_cdcooper
                ,pr_dtrefere    => to_date(wpr_dtrefere,'ddmmyyyy')
                ,pr_vlr_arrasto => 0
                ,pr_flgresta    => 0
                ,pr_stprogra    => wpr_stprogra
                ,pr_infimsol    => wpr_infimsol
                ,pr_cdcritic    => wpr_cdcritic
                ,pr_dscritic    => wpr_dscritic);

  IF wpr_dscritic IS NOT NULL THEN-- verifica se houve erros
    dbms_output.put_line('Erro '||wpr_cdcooper||' pc_crps635_wag. Descrição: '||wpr_dscritic);
  ELSE
    dbms_output.put_line('Sucesso na execução da '||wpr_cdcooper||'.');
  END IF;

  COMMIT;

  cecred.RISC0003.pc_risco_central_ocr(pr_cdcooper => wpr_cdcooper,
                                       pr_cdcritic => wpr_cdcritic,
                                       pr_dscritic => wpr_dscritic);

  COMMIT;

  IF wpr_dscritic IS NOT NULL THEN-- verifica se houve erros
    dbms_output.put_line('Erro '||wpr_cdcooper||' pc_risco_central_ocr. Descrição: '||wpr_dscritic);
  ELSE
    dbms_output.put_line('Sucesso na execução da pc_risco_central_ocr '||wpr_cdcooper||'.');
  END IF;

END;
-- CHAMADA PRINCIPAL
0
0
