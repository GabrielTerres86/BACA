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
       Data    : Marco/2013                      Ultima atualizacao: 26/01/2018

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

      -- Código do programa
      vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'CRPS635_i';

      -- Tratamento de erros
      vr_exc_saida  EXCEPTION;
      vr_exc_fimprg EXCEPTION;
      vr_cdcritic   PLS_INTEGER;
      vr_dscritic   VARCHAR2(4000);
      vr_dsmensag   VARCHAR2(500):='';


      vr_datautil   DATE;       --> Auxiliar para busca da data
      vr_dtrefere   DATE;       --> Data de referência do processo
      vr_dtrefere_aux DATE;       --> Data de referência auxiliar do processo
      vr_dtdrisco   crapris.dtdrisco%TYPE; -- Data da atualização do risco


      ------------------------------- CURSORES ---------------------------------


      -- Cursor genérico de calendário
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;

      --Cadastro de formacao dos grupos economicos
      CURSOR cr_crapgrp IS
        SELECT * FROM (SELECT crapgrp.nrctasoc
                             ,crapgrp.nrdconta
                             ,crapgrp.innivrge
                             ,crapgrp.nrdgrupo
                             ,row_number() OVER(PARTITION BY crapgrp.cdcooper
                                                            ,crapgrp.nrctasoc
                                                    ORDER BY crapgrp.nrctasoc
                                                            ,crapgrp.nrdconta
                                                            ,crapgrp.innivrge
                                                            ,crapgrp.nrdgrupo) seq
                       FROM crapgrp
                      WHERE cdcooper = pr_cdcooper
                      ORDER BY crapgrp.nrctasoc
                              ,crapgrp.nrdconta
                              ,crapgrp.innivrge
                              ,crapgrp.nrdgrupo) grupo
        WHERE grupo.seq = 1;

      -- Cadastro de informacoes de central de riscos
      CURSOR cr_crapris(pr_nrctasoc IN crapgrp.nrctasoc%TYPE) IS
        SELECT  /*+ INDEX(crapris CRAPRIS##CRAPRIS1) */
                 crapris.cdcooper
                ,crapris.dtrefere
                ,crapris.nrdconta
                ,crapris.innivris
                ,crapris.cdmodali
                ,crapris.cdorigem
                ,crapris.nrctremp
                ,crapris.nrseqctr
                ,crapris.progress_recid
        FROM    crapris
        WHERE   crapris.cdcooper = pr_cdcooper
        AND     crapris.nrdconta = pr_nrctasoc
        AND     crapris.dtrefere = pr_dtrefere
        AND     crapris.inddocto = 1
        AND     crapris.vldivida > pr_vlr_arrasto
        AND     crapris.inindris < 10;

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

        -- Comentado cursor original cr_crapris_last Daniel(AMcom)
        /*SELECT dtrefere
              ,innivris
              ,dtdrisco
          FROM crapris
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta
           -- Buscar somente informações do dia anterior - Daniel(AMcom)
           --AND dtrefere < vr_dtrefere
           AND dtrefere >= rw_crapdat.dtmvtoan
           --
           AND dtrefere <> pr_dtrefere
           AND inddocto = 1 -- 3020 e 3030
           AND innivris < 10
         ORDER BY dtrefere DESC  --> Retornar o ultimo gravado
                 ,innivris DESC  --> Retornar o ultimo gravado
                 ,dtdrisco DESC;*/--> Retornar o ultimo gravado




      PROCEDURE pc_popula_ass_arrasto(pr_cpfcnpj  IN VARCHAR2
                                     ,pr_inpessoa IN INTEGER
                                     ,pr_innivris IN INTEGER
                                     ,pr_des_erro OUT VARCHAR2) IS

        -- BUSCA TODAS AS CONTAS DE UM CNPJ RAIZ
        CURSOR cr_cpfcnpj IS
          SELECT ass.nrdconta, ass.nrcpfcgc
            FROM crapass ass
           WHERE ass.cdcooper = pr_cdcooper
             AND ((pr_inpessoa = 1 AND ass.nrcpfcgc  = to_number(pr_cpfcnpj)) Or
                  (pr_inpessoa = 2 AND ass.nrcpfcgc >= to_number(pr_cpfcnpj||'000000')
                                   AND ass.nrcpfcgc <= to_number(pr_cpfcnpj||'999999')) );

      BEGIN

        -- SE PF, POPULA DIRETO O CPF COM O RISCO (não ha variacoes de cpf)
        IF pr_inpessoa = 1 THEN
           --se for maior que ao ja existente, atualiza.
           IF vr_tab_ass_cpfcnpj.exists(pr_cpfcnpj) THEN
             IF pr_innivris > vr_tab_risco(vr_tab_ass_cpfcnpj(pr_cpfcnpj)) THEN
               vr_tab_ass_cpfcnpj(pr_cpfcnpj) := vr_tab_risco_num(pr_innivris);
             END IF;
           ELSE
             vr_tab_ass_cpfcnpj(pr_cpfcnpj) := vr_tab_risco_num(pr_innivris);
           END IF;
        ELSE
          -- SE FOR JURIDICA, PEGA TODAS AS CONTAS DO CNPJ RAIZ(8digitos)
          FOR rw_cpfcnpj IN cr_cpfcnpj LOOP
            IF vr_tab_ass_cpfcnpj.exists(rw_cpfcnpj.nrcpfcgc) THEN
              --se for maior que ao ja existente, atualiza.
              IF pr_innivris > vr_tab_risco(vr_tab_ass_cpfcnpj(rw_cpfcnpj.nrcpfcgc)) THEN
            vr_tab_ass_cpfcnpj(rw_cpfcnpj.nrcpfcgc) := vr_tab_risco_num(pr_innivris);
              END IF;
            ELSE
              vr_tab_ass_cpfcnpj(rw_cpfcnpj.nrcpfcgc) := vr_tab_risco_num(pr_innivris);
            END IF;
          END LOOP;
        END IF;

      EXCEPTION
        WHEN vr_exc_fimprg THEN
          pr_des_erro := 'pc_popula_ass_arrasto --> Erro ao popular arrasto associado.'
                       ||' PARAM: CPF/CNPJ: ' || pr_cpfcnpj || ' RISCO: ' || pr_innivris;

        WHEN OTHERS THEN
          pr_des_erro := 'pc_popula_ass_arrasto --> Erro não tratado ao popular arrasto associado.'
                       ||' PARAM: CPF/CNPJ: ' || pr_cpfcnpj || ' RISCO: ' || pr_innivris
                       ||' Detalhes: '||sqlerrm;
      END;



      -- Rotina gerar o arrasto para CPF/CNPJ
      PROCEDURE pc_efetua_arrasto_cpfcnpj(pr_des_erro OUT VARCHAR2) IS

        -- Variaveis auxiliares
        vr_dsmsgerr     VARCHAR2(200);
        vr_chave_ass    VARCHAR2(14);
        vr_maxrisco     INTEGER:=-10;

        -- LISTAR CONTAS DO GRUPO ECON. QUE ESTÃO COM RISCO MENOR QUE DO GRUPO
        CURSOR cr_contas_grupo IS
          SELECT grupo.*
            FROM (SELECT crapgrp.nrctasoc
                        , CASE
                             WHEN crapgrp.innivrge > crapgrp.innivris THEN 'GRP'
                             WHEN crapgrp.innivris > crapgrp.innivrge THEN 'RIS'
                             ELSE 'IGUAL'
                          END STATUS
                        ,ass.inpessoa
                        ,DECODE(ass.inpessoa
                               ,1,gene0002.fn_mask(ass.nrcpfcgc,
                                           DECODE(ass.inpessoa,1,'99999999999','99999999999999'))
                                 ,SUBSTR(gene0002.fn_mask(ass.nrcpfcgc,
                                           DECODE(ass.inpessoa,1,'99999999999','99999999999999'))
                                        ,1,8) ) CPF_CNPJ
                        ,crapgrp.nrcpfcgc
                        ,crapgrp.nrdconta
                        ,crapgrp.innivrge
                        ,crapgrp.innivris
                        ,crapgrp.nrdgrupo
                        ,row_number() OVER(PARTITION BY crapgrp.cdcooper
                                                       ,crapgrp.nrctasoc
                                               ORDER BY crapgrp.nrctasoc
                                                       ,crapgrp.nrdconta
                                                       ,crapgrp.innivrge
                                                       ,crapgrp.nrdgrupo) seq
                    FROM crapgrp, crapass ass
                   WHERE crapgrp.cdcooper = pr_cdcooper
                     AND ass.cdcooper = crapgrp.cdcooper
                     AND ass.nrdconta = crapgrp.nrctasoc
                   ORDER BY crapgrp.nrctasoc
                           ,crapgrp.nrdconta
                           ,crapgrp.innivrge
                           ,crapgrp.nrdgrupo) grupo
          WHERE grupo.seq    = 1       -- APENAS A PRIMEIRA DE UMA CONTA
            AND grupo.status = 'GRP'   -- APENAS AQUELES QUE TEM O RISCO DO GRUPO MAIOR QUE INNIVRIS
          ORDER BY nrdgrupo;


        -- Busca todos os riscos que deverão ser arrastados
        -- É passado apenas a raíz do cnpj, por isso a função
        CURSOR cr_riscos_cpfcnpj( pr_nrcpfcgc IN VARCHAR2
                                 ,pr_inpessoa in crapass.inpessoa%TYPE
                                 ,pr_innivris IN crapris.innivris%TYPE) IS
          SELECT  ris.nrdconta
                 ,ris.innivris
                 ,ris.dtdrisco
                 ,ris.nrcpfcgc
                 -- CDCOOPER, DTREFERE, NRDCONTA, INNIVRIS, CDMODALI, NRCTREMP, NRSEQCTR, CDVENCTO
                 ,ris.cdmodali
                 ,ris.nrctremp
                 ,ris.nrseqctr
                 ,rowid
                 ,ROW_NUMBER () OVER (PARTITION BY ris.nrdconta
                                          ORDER BY ris.nrcpfcgc,ris.nrdconta) SEQ_CTA
            FROM crapris ris
           WHERE ris.cdcooper = pr_cdcooper
             AND ris.dtrefere = pr_dtrefere
             AND ris.inddocto = 1
             AND ris.vldivida > pr_vlr_arrasto --> Valor dos parâmetros
             AND ((pr_inpessoa = 1 AND ris.nrcpfcgc  = to_number(pr_nrcpfcgc)) Or
                  (pr_inpessoa = 2 AND ris.nrcpfcgc >= to_number(pr_nrcpfcgc||'000000')
                                   AND ris.nrcpfcgc <= to_number(pr_nrcpfcgc||'999999'))  )
             AND (ris.innivris < pr_innivris);

        BEGIN


        vr_tab_ass_cpfcnpj.delete;


        -- CONTAS DO GRUPO COM RISCO MENOR QUE O GRUPO (Serão arrastadas)
        FOR rw_contas_grupo IN cr_contas_grupo LOOP

          IF rw_contas_grupo.innivrge = 10 THEN
            vr_maxrisco := 9;
          ELSE
            vr_maxrisco := rw_contas_grupo.innivrge;
          END IF;


          -- PERCORRER TODOS CONTRATOS DA RIS - COM RISCO DIFERENTE DO GRUPO
          FOR rw_riscos_cpfcnpj IN cr_riscos_cpfcnpj( pr_nrcpfcgc => rw_contas_grupo.cpf_cnpj
                                                     ,pr_inpessoa => rw_contas_grupo.inpessoa
                                                     ,pr_innivris => vr_maxrisco) LOOP


            -- Efetuar atualização da CENTRAL RISCO cfme os valores maior risco
            BEGIN

              UPDATE crapris
                 SET innivris = vr_maxrisco
                    ,inindris = vr_maxrisco
                    ,dtdrisco = pr_dtrefere
               WHERE rowid = rw_riscos_cpfcnpj.rowid;
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'pc_efetua_arrasto_cpfcnpj - '
                            || 'Erro ao atualizar a data e Risco com base no risco mais elevado --> '
                            || 'Conta: '    ||rw_riscos_cpfcnpj.nrdconta
                            ||', Rowid: '   ||rw_riscos_cpfcnpj.rowid
                            ||'. Detalhes:'||sqlerrm;
                RAISE vr_exc_fimprg;
            END;

            -- ATUALIZAR VENCIMENTOS RISCO COM BASE NO MAIOR RISCO
            BEGIN

              UPDATE crapvri
                 SET innivris = vr_maxrisco
               WHERE cdcooper = pr_cdcooper
                 AND dtrefere = pr_dtrefere
                 AND nrdconta = rw_riscos_cpfcnpj.nrdconta
                 AND cdmodali = rw_riscos_cpfcnpj.cdmodali
                 AND nrctremp = rw_riscos_cpfcnpj.nrctremp
                 AND nrseqctr = rw_riscos_cpfcnpj.nrseqctr;
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'pc_efetua_arrasto_cpfcnpj - '
                            || 'Erro ao atualizar Vencimentos Risco com base no risco mais elevado --> '
                            || 'Conta: '        ||rw_riscos_cpfcnpj.nrdconta
                            ||', Modalidade: '  ||rw_riscos_cpfcnpj.cdmodali
                            ||', Nr.Ctr.Emp.: ' ||rw_riscos_cpfcnpj.nrctremp
                            ||', Seq.Ctr.Emp.: '||rw_riscos_cpfcnpj.nrseqctr
                            || '. Detalhes:'||sqlerrm;
                RAISE vr_exc_fimprg;
            END;

          END LOOP; -- FIM LOOP - CONTRATOS DA CONTA

          -- Atualiza participante do Grupo Economico com o valor do arrasto
          BEGIN

            -- APENAS DO GRUPO ATUAL
            UPDATE crapgrp cr
               SET cr.innivris = vr_maxrisco
                  ,cr.dsdrisco = vr_tab_risco_num(vr_maxrisco)
                  ,cr.dtrefere = pr_dtrefere
             WHERE cr.cdcooper = pr_cdcooper
               AND cr.nrdgrupo = rw_contas_grupo.nrdgrupo
               AND cr.nrcpfcgc = rw_contas_grupo.nrcpfcgc
               AND cr.nrctasoc = rw_contas_grupo.nrctasoc;
          EXCEPTION
            WHEN OTHERS THEN
              --gera critica
              vr_dscritic := 'pc_efetua_arrasto_cpfcnpj - '
                           ||'Erro ao atualizar Grupo Economico com base no risco mais elevado. '||
                             'Erro: '||SQLERRM;
              RAISE vr_exc_fimprg;
          END;


          pc_popula_ass_arrasto(rw_contas_grupo.cpf_cnpj
                               ,rw_contas_grupo.inpessoa
                               ,vr_maxrisco
                               ,pr_des_erro => vr_dscritic);
          -- Se retornou derro
          IF vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_fimprg;
          END IF;

        END LOOP;     -- FIM cr_contas_grupo


       -- Atualiza todas as contas do CPF/CNPJ
        vr_chave_ass := vr_tab_ass_cpfcnpj.FIRST;
        LOOP
          EXIT WHEN vr_chave_ass IS NULL;

          BEGIN
            -- Atualizar utilizar a tabela de-para de texto do nível com base no indice
            UPDATE crapass
               SET dsnivris = vr_tab_ass_cpfcnpj(vr_chave_ass)
             WHERE cdcooper = pr_cdcooper
               AND nrcpfcgc = to_number(vr_chave_ass);

            -- Buscar o próximo
            vr_chave_ass := vr_tab_ass_cpfcnpj.NEXT(vr_chave_ass);

            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'pc_efetua_arrasto_cpfcnpj - '
                            || 'Erro ao atualizar Risco da Conta com base no risco mais elevado --> '
                            ||'CPF/CNPJ: '||vr_chave_ass
                            || '. Detalhes:'||SQLERRM;
                RAISE vr_exc_fimprg;
            END;

        END LOOP;



        EXCEPTION
          WHEN vr_exc_fimprg THEN
               pr_des_erro := 'pc_efetua_arrasto_cpfcnpj --> Erro ao processar arrasto CPF/CNPJ. Detalhes: '||vr_dscritic;
          WHEN OTHERS THEN
               pr_des_erro := 'pc_efetua_arrasto_cpfcnpj --> Erro não tratado ao processar arrasto CPF/CNPJ. Detalhes: '||sqlerrm;
        END; -- FIM PROCEDURE pc_efetua_arrasto_cpfcnpj


      PROCEDURE pc_validar_data_risco(pr_des_erro OUT VARCHAR2) IS

        -- Variaveis auxiliares
        vr_dsmsgerr     VARCHAR2(200);
        vr_maxrisco     INTEGER:=-10;


        -- Busca de todos os riscos
        CURSOR cr_crapris (pr_dtrefant IN crapris.dtrefere%TYPE) IS
          SELECT ris.cdcooper
               , ris.nrdconta
               , ris.nrctremp
               , ris.innivris   risco_atual
               , r_ant.innivris risco_anterior
               , ris.dtdrisco   dtdrisco_atual
               , r_ant.dtdrisco dtdrisco_anterior
               , ris.rowid
            FROM crapris ris
               , (SELECT *  -- Busca risco anterior
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

          IF to_char(rw_crapdat.dtmvtolt, 'MM') <> to_char(rw_crapdat.dtmvtopr, 'MM') THEN
            -- Utilizar o final do mês como data
            vr_dtrefere_aux := rw_crapdat.dtultdma;
          ELSE
            -- Utilizar a data atual
            vr_dtrefere_aux := rw_crapdat.dtmvtoan;
          END IF;

  
          FOR rw_crapris IN cr_crapris (vr_dtrefere_aux) LOOP

            -- atualiza data dos riscos que não sofreram alteração de risco
            BEGIN
              UPDATE crapris r
                 SET r.dtdrisco = rw_crapris.dtdrisco_anterior
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

      FOR rw_crapgrp IN cr_crapgrp -- busca grupos economicos
      LOOP
        EXIT WHEN cr_crapgrp%NOTFOUND;
        FOR rw_crapris IN cr_crapris(rw_crapgrp.nrctasoc) -- busca controle de riscos
        LOOP
          EXIT WHEN cr_crapris%NOTFOUND;
           --busca vencimento de riscos
          FOR rw_crapvri IN cr_crapvri( rw_crapris.cdcooper
                                       ,rw_crapris.dtrefere
                                       ,rw_crapris.nrdconta
                                       ,rw_crapris.innivris
                                       ,rw_crapris.cdmodali
                                       ,rw_crapris.nrctremp
                                       ,rw_crapris.nrseqctr
                                       )
          LOOP
            EXIT WHEN cr_crapvri%NOTFOUND;

            -- Regra para carga de data para o cursor
            -- Se for rotina mensal - Daniel(AMcom)
            IF to_char(rw_crapdat.dtmvtolt, 'MM') <> to_char(rw_crapdat.dtmvtopr, 'MM') THEN
              -- Utilizar o final do mês como data
              vr_dtrefere_aux := rw_crapdat.dtultdma;
            ELSE
              -- Utilizar a data atual
              vr_dtrefere_aux := rw_crapdat.dtmvtoan;
            END IF;

            -- Busca dos dados do ultimo risco de origem 1
            OPEN cr_crapris_last(pr_nrdconta => rw_crapris.nrdconta
                                ,pr_nrctremp => rw_crapris.nrctremp
                                ,pr_cdmodali => rw_crapris.cdmodali
                                ,pr_cdorigem => rw_crapris.cdorigem
                                ,pr_dtrefere => vr_dtrefere_aux);
            FETCH cr_crapris_last
             INTO rw_crapris_last;
            -- Se encontrou
            IF cr_crapris_last%FOUND THEN
              -- Se a data de refência é diferente do ultimo dia do mês anterior
              -- OU o nível deste registro é diferente do nível do risco no cursor principal
              -- e o nível do risco principal seja diferente de HH(10)
              -- ATENCAO: caso seja alterada esta regra, ajustar em crps310_i tb
              --
              -- Comentado comparativo de datas(dtrefere <> dtultdma), pois esta condição sempre irá existir - Daniel(AMcom)
              IF /*rw_crapris_last.dtrefere <> rw_crapdat.dtultdma
              OR */(rw_crapris_last.innivris <> rw_crapgrp.innivrge /*AND rw_crapris.innivris <> 10*/) THEN
                -- Utilizar a data de referência do processo
                vr_dtdrisco := vr_dtrefere;
              ELSE
                -- Utilizar a data do ultimo risco
                IF rw_crapris_last.dtdrisco IS NULL THEN
                vr_dtdrisco := vr_dtrefere;
              ELSE
                -- Utilizar a data do ultimo risco
                vr_dtdrisco := rw_crapris_last.dtdrisco;
              END IF;
              END IF;
            ELSE
              -- Utilizar a data de referência do processo
              vr_dtdrisco := vr_dtrefere;
            END IF;
            -- Fechar o cursor
            CLOSE cr_crapris_last;

            -- atualiza controle de riscos.
            BEGIN
              UPDATE crapris
                 SET crapris.innivris = rw_crapgrp.innivrge,
                     crapris.dtdrisco = vr_dtdrisco
               WHERE cdcooper         = rw_crapris.cdcooper
                 AND nrdconta         = rw_crapris.nrdconta
                 AND dtrefere         = rw_crapris.dtrefere
                 AND innivris         = rw_crapris.innivris
                 AND progress_recid   = rw_crapris.progress_recid;
            EXCEPTION
              WHEN OTHERS THEN
                --gera critica
                vr_dscritic := 'Erro ao atualizar Arquivo para controle das informacoes da central de risco(crapris). '||
                               'Erro: '||SQLERRM;
                RAISE vr_exc_fimprg;
            END;
            BEGIN -- atualiza vencimento dos riscos
              UPDATE crapvri
                 SET crapvri.innivris = rw_crapgrp.innivrge
               WHERE ROWID = rw_crapvri.rowid;
            EXCEPTION
              WHEN OTHERS THEN
                --gera critica
                vr_dscritic := 'Erro ao atualizar Vencimento do risco(crapvri). '||
                               'Erro: '||SQLERRM;
                RAISE vr_exc_fimprg;
            END;
          END LOOP;
        END LOOP;

        -- Atualiza Grupo Economico
        BEGIN
          UPDATE crapris
             SET nrdgrupo = rw_crapgrp.nrdgrupo
           WHERE cdcooper = pr_cdcooper
             AND nrdconta = rw_crapgrp.nrctasoc
             AND dtrefere = pr_dtrefere;
        EXCEPTION
          WHEN OTHERS THEN
            --gera critica
            vr_dscritic := 'Erro ao atualizar Grupo Economico das informacoes da central de risco(crapris). '||
                           'Erro: '||SQLERRM;
            RAISE vr_exc_fimprg;
        END;

      END LOOP;
      --gera log de sucesso
      vr_dscritic := 'Atualizacao dos riscos efetuada com sucesso.';
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                  ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                   || vr_cdprogra || ' --> '
                                                   || vr_dscritic );


      -- Chamar rotina de geração do arrasto por CPF/CNPJ
      pc_efetua_arrasto_cpfcnpj(pr_des_erro => vr_dscritic);
      -- Se retornou derro
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_fimprg;
      END IF;
      --gera log de sucesso
      vr_dscritic := 'Arrasto riscos CPF/CNPJ efetuada com sucesso.';
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                  ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                   || vr_cdprogra || ' --> '
                                                   || vr_dscritic );



      pc_validar_data_risco(pr_des_erro => vr_dscritic);
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_fimprg;
      END IF;

    EXCEPTION
      WHEN vr_exc_fimprg THEN
        -- Efetuar rollback
        ROLLBACK;
      WHEN OTHERS THEN
        -- Efetuar retorno do erro não tratado
        pr_cdcritic := 0;
        pr_dscritic := sqlerrm;
        -- Efetuar rollback
        ROLLBACK;
    END;
  END pc_crps635_i;

