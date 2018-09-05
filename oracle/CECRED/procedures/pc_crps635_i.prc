CREATE OR REPLACE PROCEDURE CECRED.pc_crps635_i( pr_cdcooper    IN crapcop.cdcooper%TYPE   --> Cooperativa solicitada
                                                ,pr_dtrefere    IN crapdat.dtmvtolt%TYPE   --> Data referencia
                                                ,pr_vlr_arrasto IN crapris.vldivida%TYPE   --> Valor da dívida
                                                ,pr_flgresta    IN PLS_INTEGER             --> Flag padrão para utilização de restart
                                                ,pr_stprogra    OUT PLS_INTEGER            --> Saída de termino da execução
                                                ,pr_infimsol    OUT PLS_INTEGER            --> Saída de termino da solicitação
                                                ,pr_cdcritic    OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                                                ,pr_dscritic    OUT VARCHAR2) IS           --> Texto de erro/critica encontrada
  BEGIN
    /* .............................................................................

       Programa: pc_crps635_i (Fontes/crps635_i.p)
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Adriano
       Data    : Marco/2013                      Ultima atualizacao: 05/04/2018

       Dados referentes ao programa:

       Frequencia: Diario (crps635)/Mensal (crps627).
       Objetivo  : ATUALIZAR RISCO SISBACEN DE ACORDO COM O GE

       Alteracoes: 08/05/2013 - Desprezar risco em prejuizo "inindris = 10"(Adriano).

                   29/04/2014 - Conversão Progress >> Oracle PLSQL (Tiago Castro - RKAM).

                   11/03/2015 - Ajuste para quando alterar nivel risco, atualizar a data de risco tb.
                                (Jorge/Gielow) - SD 231859

                   06/08/2015 - Realizado correção para pegar apenas o primeiro registro da crapgrp,
                                baseado no crapgrp.nrctasoc, pois do jeito que esta fará a atualização do risco
                                na mesma conta (crapgrp.nrctasoc) várias vezes.
                                (Adriano).

                   30/10/2015 - Ajuste no cr_crapris_last pois pegava contratos em prejuizo
                                indevidamente (Tiago/Gielow #342525).

                   24/10/2017 - Atualizacao do Grupo Economico fora do loop da crapris com valor de arrasto.
                                (Jaison/James)

                   26/01/2018 - Arrasto do Grupo Economico para CPFs/CNPJs do grupo (Guilherme/AMcom)

                   05/04/2018 - #inc0011132 Forçado o índice CRAPRIS2 na rotina pc_validar_data_risco,
                                cursor cr_crapris (Carlos)

                   20/06/2018 - P450 - Criação da procedure utilizando novas tabelas de grupo
                                TBCC_GRUPO_ECONOMICO, TBCC_GRUPO_ECONOMICO_INTEG (Mario - AMcom)
                              - P450 - Retirado tratamento para valor arrasto (Guilherme/AMcom)

    ............................................................................ */

    DECLARE

      ------------------------ VARIAVEIS PRINCIPAIS ----------------------------

      -- Vetor para armazenar os dados de riscos, dessa forma temos o valor
      -- char do risco (AA, A, B...HH) como chave e o valor é seu indice
      TYPE typ_tab_risco IS
        TABLE OF PLS_INTEGER
          INDEX BY VARCHAR2(2);
      vr_tab_risco typ_tab_risco;

      -- Outro vetor para armazenar os dados do risco, porém chaveado
      -- pelo nível em número e nao em texto
      TYPE typ_tab_risco_num IS
        TABLE OF VARCHAR2(2)
          INDEX BY PLS_INTEGER;
      vr_tab_risco_num typ_tab_risco_num;

      -- Criação de tipo de registro para armazenar o nível de risco para cada conta
      -- Sendo a chave da tabela a conta com zeros a esquerda(10)
      TYPE typ_tab_crapass_nivel IS
        TABLE OF VARCHAR2(2)
          INDEX BY PLS_INTEGER;
      vr_tab_assnivel typ_tab_crapass_nivel;

      TYPE typ_tab_crapass_cpfcnpj IS
        TABLE OF VARCHAR2(2)
          INDEX BY VARCHAR2(14);
      vr_tab_ass_cpfcnpj typ_tab_crapass_cpfcnpj;

      -- Registro de Associado que precisam alterar o Risco
      TYPE typ_ass_ris IS
        RECORD(cdcooper      crapris.cdcooper%TYPE
              ,nrdconta      crapris.nrdconta%TYPE
              ,nrcpfcgc      crapris.nrcpfcgc%TYPE
              ,cpf_cnpj      crapris.nrcpfcgc%TYPE
              ,maxrisco      crapris.innivris%TYPE
              ,inpessoa      crapris.inpessoa%TYPE);

      -- Definição de um tipo de tabela com o registro acima
      TYPE typ_tab_ass_ris IS
        TABLE OF typ_ass_ris
          INDEX BY PLS_INTEGER;
      vr_tab_ass_ris   typ_tab_ass_ris;


      -- Código do programa
      vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'CRPS635_i';

      -- Tratamento de erros
      vr_exc_saida  EXCEPTION;
      vr_exc_fimprg EXCEPTION;
      vr_cdcritic   PLS_INTEGER;
      vr_dscritic   VARCHAR2(4000);


      vr_datautil   DATE;       --> Auxiliar para busca da data
      vr_dtrefere   DATE;       --> Data de referência do processo
      vr_dtrefere_aux DATE;       --> Data de referência auxiliar do processo
      vr_dtdrisco   crapris.dtdrisco%TYPE; -- Data da atualização do risco
      vr_dttrfprj   DATE;
      
      ------------------------------- CURSORES ---------------------------------


      -- Cursor genérico de calendário
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;


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

      -- cadastro do vencimento do risco
      CURSOR cr_crapvri( pr_cdcooper IN crapris.cdcooper%TYPE
                        ,pr_dtrefere IN crapris.dtrefere%TYPE
                        ,pr_nrdconta IN crapris.nrdconta%TYPE
                        ,pr_innivris IN crapris.innivris%TYPE
                        ,pr_cdmodali IN crapris.cdmodali%TYPE
                        ,pr_nrctremp IN crapris.nrctremp%TYPE
                        ,pr_nrseqctr IN crapris.nrseqctr%TYPE
                        ) IS
        SELECT  ROWID
        FROM    crapvri
        WHERE   crapvri.cdcooper = pr_cdcooper
        AND     crapvri.dtrefere = pr_dtrefere
        AND     crapvri.nrdconta = pr_nrdconta
        AND     crapvri.innivris = pr_innivris
        AND     crapvri.cdmodali = pr_cdmodali
        AND     crapvri.nrctremp = pr_nrctremp
        AND     crapvri.nrseqctr = pr_nrseqctr;
      rw_crapvri cr_crapvri%ROWTYPE;

      -- Busca dos dados do ultimo risco Doctos 3020/3030
      CURSOR cr_crapris_last(pr_nrdconta IN crapris.nrdconta%TYPE
                            ,pr_nrctremp IN crapris.nrctremp%TYPE
                            ,pr_cdmodali IN crapris.cdmodali%TYPE
                            ,pr_cdorigem IN crapris.cdorigem%TYPE
                            ,pr_dtrefere in crapris.dtrefere%TYPE) IS
           -- Ajuste no cursor para tratar data do risco - Daniel(AMcom)
           SELECT r.dtrefere
                , r.innivris
                , r.dtdrisco
            FROM crapris r
           WHERE r.cdcooper = pr_cdcooper
             AND r.nrdconta = pr_nrdconta
             AND r.dtrefere = pr_dtrefere
             AND r.nrctremp = pr_nrctremp
             AND r.cdmodali = pr_cdmodali
             AND r.cdorigem = pr_cdorigem
             AND r.inddocto = 1 -- 3020 e 3030
--             AND r.innivris < 10
           ORDER BY r.dtrefere DESC --> Retornar o ultimo gravado
                  , r.innivris DESC --> Retornar o ultimo gravado
                  , r.dtdrisco DESC;
        rw_crapris_last cr_crapris_last%ROWTYPE;



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
             AND (r_ant.innivris = ris.innivris AND r_ant.dtdrisco <> ris.dtdrisco)  ;

      BEGIN

        IF to_char(rw_crapdat.dtmvtoan, 'MM') <> to_char(rw_crapdat.dtmvtolt, 'MM') THEN
          -- Utilizar o final do mês como data
          vr_dtrefere_aux := rw_crapdat.dtultdma;
        ELSE
          -- Utilizar a data atual
          vr_dtrefere_aux := rw_crapdat.dtmvtoan;
        END IF;

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
              --gera critica
              vr_dscritic := 'Erro ao atualizar Data do risco da Central de Risco(crapris). '||
                             'Erro: '||SQLERRM;
              RAISE vr_exc_fimprg;
          END;
        END LOOP;

      EXCEPTION
        WHEN vr_exc_fimprg THEN
             pr_des_erro := 'pc_validar_data_risco --> Erro ao processar Data do Risco. Detalhes: '||vr_dscritic;
        WHEN OTHERS THEN
             pr_des_erro := 'pc_validar_data_risco --> Erro não tratado ao processar Data do Risco. Detalhes: '||sqlerrm;
      END; -- FIM PROCEDURE pc_validar_data_risco

    BEGIN

      vr_tab_risco(' ') := 2;
      vr_tab_risco('AA') := 1;
      vr_tab_risco('A') := 2;
      vr_tab_risco('B') := 3;
      vr_tab_risco('C') := 4;
      vr_tab_risco('D') := 5;
      vr_tab_risco('E') := 6;
      vr_tab_risco('F') := 7;
      vr_tab_risco('G') := 8;
      vr_tab_risco('H') := 9;
      vr_tab_risco('HH') := 10;

      -- Carregar a tabela de-para do risco como valor e seu texto
      vr_tab_risco_num(0)  := 'A';
      vr_tab_risco_num(1)  := 'AA';
      vr_tab_risco_num(2)  := 'A';
      vr_tab_risco_num(3)  := 'B';
      vr_tab_risco_num(4)  := 'C';
      vr_tab_risco_num(5)  := 'D';
      vr_tab_risco_num(6)  := 'E';
      vr_tab_risco_num(7)  := 'F';
      vr_tab_risco_num(8)  := 'G';
      vr_tab_risco_num(9)  := 'H';
      vr_tab_risco_num(10) := 'HH';

      -- Leitura do calendário da cooperativa
      OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH btch0001.cr_crapdat
       INTO rw_crapdat;
      -- Se não encontrar
      IF btch0001.cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor pois efetuaremos raise
        CLOSE btch0001.cr_crapdat;
        -- Montar mensagem de critica
        pr_cdcritic := 1;
        RAISE vr_exc_fimprg;
      ELSE
        -- Apenas fechar o cursor
        CLOSE btch0001.cr_crapdat;
      END IF;

      -- Função para retornar dia útil anterior a data base
      vr_datautil  := gene0005.fn_valida_dia_util(pr_cdcooper  => pr_cdcooper,                -- Cooperativa
                                                  pr_dtmvtolt  => rw_crapdat.dtmvtolt - 1, -- Data de referencia
                                                  pr_tipo      => 'A',                        -- Se não for dia útil, retorna primeiro dia útil anterior
                                                  pr_feriado   => TRUE,                       -- Considerar feriados,
                                                  pr_excultdia => TRUE);                      -- Considerar 31/12


      -- Este tratamento esta sendo efetuado como solução para
      -- a situação do plsql não ter como efetuar comparativo <> NULL
      IF to_char(vr_datautil,'MM') <> to_char(rw_crapdat.dtmvtolt,'MM') THEN
        vr_datautil := to_date('31/12/9999','DD/MM/RRRR');
      END IF;

      vr_dtrefere := rw_crapdat.dtmvtolt;

      -- Regra para carga de data para o cursor
      -- Se for rotina mensal - Daniel(AMcom)
      IF to_char(rw_crapdat.dtmvtoan, 'MM') <> to_char(rw_crapdat.dtmvtolt, 'MM') THEN
        -- Utilizar o final do mês como data
        vr_dtrefere_aux := rw_crapdat.dtultdma;
      ELSE
        -- Utilizar a data atual
        vr_dtrefere_aux := rw_crapdat.dtmvtoan;
      END IF;


      ----------------------------------------------------------------------
      -- NOVA ROTINA PARA CALCULO RISCO GRUPO E GRAVAÇÃO NA CENTRAL RISCO --
      ----------------------------------------------------------------------
      risc0004.pc_central_risco_grupo(pr_cdcooper => pr_cdcooper,
                                      pr_dtrefere => vr_dtrefere,     -- Data do dia da Coop
                                      pr_dtmvtoan => vr_dtrefere_aux, -- Data da central anterior
                                      pr_dscritic => vr_dscritic);
      -- Se retornou derro
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_fimprg;
      END IF;
      --gera log de sucesso
      vr_dscritic := 'Atualizacao dos riscos efetuada com sucesso.';
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                  ,pr_ind_tipo_log => 2 -- Erro tratado
                                  ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                   || vr_cdprogra || ' --> '
                                                   || vr_dscritic );
      ---------------------------------------------------------------------
      -------------------------------- FIM --------------------------------
      ---------------------------------------------------------------------



      ------------------------------------------ 
      pc_validar_data_risco(pr_des_erro => vr_dscritic);
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_fimprg;
      END IF;
      ------------------------------------------


    EXCEPTION
      WHEN vr_exc_fimprg THEN
        -- Efetuar rollback
        pr_dscritic := vr_dscritic;
        ROLLBACK;
      WHEN OTHERS THEN
        -- Efetuar retorno do erro não tratado
        pr_cdcritic := 0;
        pr_dscritic := sqlerrm;
        -- Efetuar rollback
        ROLLBACK;
    END;
  END pc_crps635_i;
/
