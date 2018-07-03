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
 
                   20/06/2018 - Criação da procedure utilizando novas tabelas de grupo
                              - TBCC_GRUPO_ECONOMICO, TBCC_GRUPO_ECONOMICO_INTEG (Mario - AMcom)
                                    
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
      vr_opt_innivris PLS_INTEGER;
      ------------------------------- CURSORES ---------------------------------

      
      -- Cursor genérico de calendário
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;

      --Cadastro de formacao dos grupos economicos
      CURSOR cr_grupo_econ IS
        SELECT distinct 
               gi.nrdconta
              ,ge.inrisco_grupo
              ,gi.idgrupo
          FROM tbcc_grupo_economico ge
              ,tbcc_grupo_economico_integ gi
         WHERE ge.cdcooper = pr_cdcooper
           AND gi.idgrupo = ge.idgrupo
           AND gi.cdcooper = ge.cdcooper
         ORDER BY gi.nrdconta
                 ,ge.inrisco_grupo
                 ,gi.idgrupo;

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

      -- Buscar dados da formação de grupos
      CURSOR cr_grupo_econ_tbcc(pr_cdcooper IN tbcc_grupo_economico.cdcooper%TYPE) IS  --> Código da cooperativa
        SELECT  ge.idgrupo
               ,ge.inrisco_grupo
          FROM tbcc_grupo_economico ge
         WHERE ge.cdcooper = pr_cdcooper
         ORDER BY ge.idgrupo;

      -- Buscas os riscos dos contratos
      CURSOR cr_grupo_risco(pr_cdcooper IN tbcc_grupo_economico.cdcooper%TYPE     --> Código da cooperativa
                           ,pr_dtrefere IN crapris.dtrefere%TYPE                  --> Data de referencia
                           ,pr_idgrupo  IN tbcc_grupo_economico.idgrupo%TYPE) IS  --> Código do Grupo TBCC
        select ge.cdcooper
              ,ge.idgrupo
              ,gi.nrdconta
              ,ge.inrisco_grupo 
              ,ri.innivris
              ,ri.rowid
          from tbcc_grupo_economico ge
              ,tbcc_grupo_economico_integ gi 
              ,crapris ri
         where ge.cdcooper = pr_cdcooper
           and gi.cdcooper = ge.cdcooper
           and gi.idgrupo = ge.idgrupo
           and gi.dtexclusao is null
           and ri.dtrefere = pr_dtrefere
           and ri.cdcooper = gi.cdcooper
           and ri.nrdconta = gi.nrdconta
           and ri.inddocto = 1
           and ge.idgrupo = pr_idgrupo
         order by ge.inrisco_grupo desc, ge.idgrupo, gi.nrdconta;

      -- Buscar os niveis dos grupos por CPFCGC
      CURSOR cr_arrasto_risco_grupo(pr_cdcooper IN tbcc_grupo_economico.cdcooper%TYPE) IS --> Código da cooperativa
        select ge.idgrupo
              ,ge.inrisco_grupo
              ,gi.nrdconta
              ,gi.nrcpfcgc
              ,decode(ass.dsnivris,' ', 2 ,'AA', 1 ,'A', 2 ,'B', 3 ,'C', 4 ,'D', 5 
                                  ,'E', 6 ,'F', 7  ,'G', 8 ,'H', 9 ,'HH',10) innivris_ass
              ,ass.dsnivris
              ,ass.rowid
          from tbcc_grupo_economico ge
              ,tbcc_grupo_economico_integ gi
              ,crapass ass
         where ge.cdcooper = pr_cdcooper
           and gi.cdcooper = ge.cdcooper
           and gi.idgrupo = ge.idgrupo
           and gi.dtexclusao is null
           and gi.cdcooper = ass.cdcooper
           and ((ass.inpessoa = 1 and gi.nrcpfcgc = ass.nrcpfcgc)
            or  (ass.inpessoa = 2 and round(gi.nrcpfcgc,-6) = round(ass.nrcpfcgc,-6) ))
           and ge.inrisco_grupo <> decode(ass.dsnivris,' ', 2 ,'AA', 1 ,'A', 2 ,'B', 3 ,'C', 4 ,'D', 5 
                                                      ,'E', 6 ,'F', 7  ,'G', 8 ,'H', 9 ,'HH',10);

      -- Buscar os niveis dos contratos por CPFCGC
      CURSOR cr_arrasto_risco_contrato(pr_cdcooper IN tbcc_grupo_economico.cdcooper%TYPE     --> Código da cooperativa
                                      ,pr_dtrefere IN crapris.dtrefere%TYPE) IS              --> Data de referencia
        select distinct
               ge.cdcooper
              ,ge.idgrupo 
              ,ri.innivris
              ,decode(ass.dsnivris,' ', 2 ,'AA', 1 ,'A', 2 ,'B', 3 ,'C', 4 ,'D', 5 
                                  ,'E', 6 ,'F', 7  ,'G', 8 ,'H', 9 ,'HH',10) innivris_ass
              ,ass.dsnivris
              ,ass.rowid             
          from
                crapass ass
               ,crapris ri
               ,tbcc_grupo_economico_integ gi 
               ,tbcc_grupo_economico ge
         where ge.cdcooper = pr_cdcooper
           and gi.cdcooper = ge.cdcooper
           and gi.idgrupo = ge.idgrupo
           and gi.dtexclusao is null
           and ri.cdcooper = gi.cdcooper
           and ri.nrdconta = gi.nrdconta
           and ri.dtrefere = pr_dtrefere
         --and ri.innivris = 10
           and ri.inddocto = 1
           and gi.cdcooper = ass.cdcooper
           and ((ass.inpessoa = 1 and gi.nrcpfcgc = ass.nrcpfcgc)
            or  (ass.inpessoa = 2 and round(gi.nrcpfcgc,-6) = round(ass.nrcpfcgc,-6) ))
           and ri.innivris <> decode(ass.dsnivris,' ', 2 ,'AA', 1 ,'A', 2 ,'B', 3 ,'C', 4 ,'D', 5 
                                                     ,'E', 6 ,'F', 7  ,'G', 8 ,'H', 9 ,'HH',10);

      -- Buscar os dados do associado que não possuem grupo
      CURSOR cr_associado_sem_grupo(pr_cdcooper IN tbcc_grupo_economico.cdcooper%TYPE) IS
        select distinct
               ge.cdcooper
              ,ge.idgrupo 
              ,ass.dsnivris
              ,ass.nmprimtl
              ,ass.inpessoa
              ,ass.nrcpfcgc nrcpfcgc_ass
              ,ass.nrdconta nrdconta_ass
              ,ass.rowid             
          from  crapass ass
               ,tbcc_grupo_economico_integ gi 
               ,tbcc_grupo_economico ge
         where ge.cdcooper = pr_cdcooper
           and gi.cdcooper = ge.cdcooper
           and gi.idgrupo = ge.idgrupo
           and gi.dtexclusao is null
           and gi.cdcooper = ass.cdcooper
           and ((ass.inpessoa = 1 and gi.nrcpfcgc = ass.nrcpfcgc)
            or  (ass.inpessoa = 2 and round(gi.nrcpfcgc,-6) = round(ass.nrcpfcgc,-6) ))
           and not exists(select 1 
                            from tbcc_grupo_economico_integ gi2
                           where gi2.cdcooper = ass.cdcooper
                             and gi2.nrcpfcgc = ass.nrcpfcgc
                             and gi2.nrdconta = ass.nrdconta);

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

      -- Chamar rotina de geração do arrasto por CPF/CNPJ
      --Efetuar arrasto do risco levando em consideração nrcpfcgc do grupo
      FOR rw_arrasto_risco_grupo in cr_arrasto_risco_grupo (pr_cdcooper => pr_cdcooper)
      LOOP           
        -- Atualizar o risco
        begin
          update crapass
             set dsnivris = vr_tab_risco_num(rw_arrasto_risco_grupo.inrisco_grupo)
           where rowid = rw_arrasto_risco_grupo.rowid;
        exception
          WHEN OTHERS THEN
            --gera critica
            vr_dscritic := 'Erro ao atualizar CRAPASS com o risco do grupo. '||
                           'Erro: '||SQLERRM;
            RAISE vr_exc_fimprg;
        end;
      END LOOP;

      --Efetua arrasto do risco levando em consideração nrcpfcgc do grupo
      FOR rw_arrasto_risco_contrato in cr_arrasto_risco_contrato (pr_cdcooper => pr_cdcooper
                                                                 ,pr_dtrefere => pr_dtrefere)
      LOOP      
        -- Atualizar o risco
        begin
          update crapass
             set dsnivris = vr_tab_risco_num(rw_arrasto_risco_contrato.innivris)
           where rowid = rw_arrasto_risco_contrato.rowid;
        exception
          WHEN OTHERS THEN
            --gera critica
            vr_dscritic := 'Erro ao atualizar CRAPASS com o risco do contrato. '||
                           'Erro: '||SQLERRM;
            RAISE vr_exc_fimprg;
        end;
      END LOOP;

      --Efetua arrasto do risco levando em consideração nrcpfcgc do grupo
      FOR rw_associado_sem_grupo in cr_associado_sem_grupo (pr_cdcooper => pr_cdcooper)  --> Código da cooperativa
      LOOP
        -- Insere cooperado no grupo
        BEGIN
          INSERT INTO tbcc_grupo_economico_integ
                     (idgrupo
                     ,nrcpfcgc
                     ,cdcooper
                     ,nrdconta
                     ,tppessoa
                     ,tpcarga
                     ,tpvinculo
                     ,peparticipacao
                     ,dtinclusao
                     ,cdoperad_inclusao
                     ,nmintegrante)
              VALUES (rw_associado_sem_grupo.idgrupo
                     ,rw_associado_sem_grupo.nrcpfcgc_ass
                     ,pr_cdcooper
                     ,rw_associado_sem_grupo.nrdconta_ass
                     ,rw_associado_sem_grupo.inpessoa
                     ,2 -- Carga JOB
                     ,7
                     ,null
                     ,TRUNC(SYSDATE)
                     ,1
                     ,rw_associado_sem_grupo.nmprimtl);
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao gravar o integrante do grupo economico (conta): '||SQLERRM;
            RAISE vr_exc_fimprg;
        END;
      END LOOP;
 
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
         
      --
      -- Inicio procedimento de Grupo e Risco/Grupo pela tabela TBCC_GRUPO_ECONOMICO ----
      --
      FOR rw_grupo_econ IN cr_grupo_econ -- busca grupos economicos
      LOOP
        --EXIT WHEN cr_grupo_econ%NOTFOUND;
        FOR rw_crapris IN cr_crapris(rw_grupo_econ.nrdconta) -- busca controle de riscos
        LOOP          
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
            -- Regra para carga de data para o cursor
            -- Se for rotina mensal - Daniel(AMcom)
            IF to_char(rw_crapdat.dtmvtoan, 'MM') <> to_char(rw_crapdat.dtmvtolt, 'MM') THEN
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
              --    e o nível do risco principal seja diferente de HH(10)
              -- ATENCAO: caso seja alterada esta regra, ajustar em crps310_i tb
              --
              -- Comentado comparativo de datas(dtrefere <> dtultdma), pois esta condição sempre irá existir - Daniel(AMcom)
              IF (rw_crapris_last.innivris <> rw_grupo_econ.inrisco_grupo) THEN
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
            
            vr_dttrfprj := NULL;
            IF rw_grupo_econ.inrisco_grupo >= 9 THEN
              vr_dttrfprj := PREJ0001.fn_regra_dtprevisao_prejuizo(pr_cdcooper,
                                                                   rw_grupo_econ.inrisco_grupo,
                                                                   rw_crapris.qtdiaatr,
                                                                   vr_dtdrisco);            
            END IF;            
            
            -- atualiza controle de riscos.
            BEGIN
              UPDATE  crapris
              SET     crapris.innivris = rw_grupo_econ.inrisco_grupo,
                      crapris.inindris = rw_grupo_econ.inrisco_grupo,
                      crapris.dtdrisco = vr_dtdrisco,
                      crapris.dttrfprj = vr_dttrfprj
              WHERE   cdcooper         = rw_crapris.cdcooper       
              AND     nrdconta         = rw_crapris.nrdconta      
              AND     dtrefere         = rw_crapris.dtrefere      
              AND     innivris         = rw_crapris.innivris      
              AND     progress_recid   = rw_crapris.progress_recid;
            EXCEPTION
              WHEN OTHERS THEN
                --gera critica
                vr_dscritic := 'Erro ao atualizar Arquivo para controle das informacoes da central de risco(crapris). '||
                               'Erro: '||SQLERRM;
                RAISE vr_exc_fimprg;
            END;    
            BEGIN -- atualiza vencimento dos riscos
              UPDATE crapvri
              SET     crapvri.innivris = rw_grupo_econ.inrisco_grupo
              WHERE   ROWID = rw_crapvri.rowid;
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
             SET nrdgrupo = rw_grupo_econ.idgrupo
           WHERE cdcooper = pr_cdcooper
             AND nrdconta = rw_grupo_econ.nrdconta
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

      --Busca grupos economicos
      --Efetua arrasto do risco levando em consideração as nrdconta
      FOR rw_grupo_econ_tbcc in cr_grupo_econ_tbcc(pr_cdcooper => pr_cdcooper) LOOP

        -- Zerar valores da iteração anterior
        vr_opt_innivris := -1;

        --Busca grupos e riscos
        FOR rw_grupo_risco in cr_grupo_risco (pr_cdcooper => pr_cdcooper
                                             ,pr_dtrefere => pr_dtrefere
                                             ,pr_idgrupo  => rw_grupo_econ_tbcc.idgrupo) LOOP
          -- Tratar o risco máximo
          if vr_opt_innivris = -1 then           
            if rw_grupo_risco.inrisco_grupo = 10 then
              vr_opt_innivris := 9;
            else
              vr_opt_innivris := rw_grupo_risco.innivris; 
            end if;
          end if;

          --Verificar se autiza o risco
          if vr_opt_innivris <> rw_grupo_risco.innivris and
             rw_grupo_risco.innivris <> 10 then
            
            -- Atualizar o risco
            begin
              update crapris
                 set innivris = vr_opt_innivris
                    ,inindris = vr_opt_innivris
                    ,dtdrisco = pr_dtrefere
               where rowid = rw_grupo_risco.rowid;
            exception
              WHEN OTHERS THEN
                --gera critica
                vr_dscritic := 'Erro ao atualizar Grupo Economico TBCC das informacoes da central de risco(crapris). '||
                               'Erro: '||SQLERRM;
                RAISE vr_exc_fimprg;
            end;
          end if;
        END LOOP;

      END LOOP;

      COMMIT;

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
/
