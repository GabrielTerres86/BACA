rem PL/SQL Developer Test Script

set feedback off
set autoprint off

rem Execute PL/SQL Block
-- Created on 18/01/2019 by F0031800 
declare 
  wpr_stprogra PLS_INTEGER;            --> Saída de termino da execução
  wpr_infimsol PLS_INTEGER;            --> Saída de termino da solicitação
  wpr_cdcritic crapcri.cdcritic%TYPE;
  wpr_dscritic VARCHAR2(32767);


   PROCEDURE pc_crps433_w (pr_cdcooper IN crapcop.cdcooper%TYPE   --> Cooperativa solicitada
                          ,pr_flgresta  IN PLS_INTEGER            --> Flag padrão para utilização de restart
                          ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                          ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                          ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                          ,pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada
  BEGIN
  
    DECLARE

      ------------------------ VARIAVEIS PRINCIPAIS ----------------------------

      -- Código do programa
      vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'CRPS433';

      -- Tratamento de erros
      vr_exc_saida  EXCEPTION;
      vr_exc_fimprg EXCEPTION;
      vr_cdcritic   PLS_INTEGER;
      vr_dscritic   VARCHAR2(4000);

      vr_dtmvtolt   DATE; --data referencia
      vr_cdretenc   NUMBER; --cod retencao do lancamento
      vr_nrseqdig   NUMBER;--seq digitacao
      vr_ano        NUMBER; --ano referencia

      ------------------------------- CURSORES ---------------------------------

      -- Busca dos dados da cooperativa
      CURSOR cr_crapcop IS
        SELECT cop.nmrescop
              ,cop.nmextcop
              ,cop.nrdocnpj
          FROM crapcop cop
         WHERE cop.cdcooper = pr_cdcooper;
      rw_crapcop cr_crapcop%ROWTYPE;
      -- Cursor genérico de calendário
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;

      CURSOR cr_crapdir IS -- busca dados geracao de Imposto Renda
        SELECT  nrdconta
               ,vlirabap##1
               ,vlirabap##2
               ,vlirabap##3
               ,vlirabap##4
               ,vlirabap##5
               ,vlirabap##6
               ,vlirabap##7
               ,vlirabap##8
               ,vlirabap##9
               ,vlirabap##10
               ,vlirabap##11
               ,vlirabap##12
               ,vlirajus##1
               ,vlirajus##2
               ,vlirajus##3
               ,vlirajus##4
               ,vlirajus##5
               ,vlirajus##6
               ,vlirajus##7
               ,vlirajus##8
               ,vlirajus##9
               ,vlirajus##10
               ,vlirajus##11
               ,vlirajus##12
               ,vlirrdca##1
               ,vlirrdca##2
               ,vlirrdca##3
               ,vlirrdca##4
               ,vlirrdca##5
               ,vlirrdca##6
               ,vlirrdca##7
               ,vlirrdca##8
               ,vlirrdca##9
               ,vlirrdca##10
               ,vlirrdca##11
               ,vlirrdca##12
               ,vlrirrpp##1
               ,vlrirrpp##2
               ,vlrirrpp##3
               ,vlrirrpp##4
               ,vlrirrpp##5
               ,vlrirrpp##6
               ,vlrirrpp##7
               ,vlrirrpp##8
               ,vlrirrpp##9
               ,vlrirrpp##10
               ,vlrirrpp##11
               ,vlrirrpp##12
               ,vlirfrdc##1
               ,vlirfrdc##2
               ,vlirfrdc##3
               ,vlirfrdc##4
               ,vlirfrdc##5
               ,vlirfrdc##6
               ,vlirfrdc##7
               ,vlirfrdc##8
               ,vlirfrdc##9
               ,vlirfrdc##10
               ,vlirfrdc##11
               ,vlirfrdc##12
               ,vlrentot##1
               ,vlrentot##2
               ,vlrentot##3
               ,vlrentot##4
               ,vlrentot##5
               ,vlrentot##6
               ,vlrentot##7
               ,vlrentot##8
               ,vlrentot##9
               ,vlrentot##10
               ,vlrentot##11
               ,vlrentot##12
               ,dtmvtolt
               ,vlirfcot
               ,vlrencot
        FROM    crapdir
        WHERE   crapdir.cdcooper      = pr_cdcooper
        AND     crapdir.nrdconta      > 0
        AND     crapdir.dtmvtolt      = vr_dtmvtolt
        AND     (crapdir.vlrentot##1  > 0
        OR       crapdir.vlrentot##2  > 0
        OR       crapdir.vlrentot##3  > 0
        OR       crapdir.vlrentot##4  > 0
        OR       crapdir.vlrentot##5  > 0
        OR       crapdir.vlrentot##6  > 0
        OR       crapdir.vlrentot##7  > 0
        OR       crapdir.vlrentot##8  > 0
        OR       crapdir.vlrentot##9  > 0
        OR       crapdir.vlrentot##10 > 0
        OR       crapdir.vlrentot##11 > 0
        OR       crapdir.vlrentot##12 > 0
        OR       crapdir.vlirfcot > 0);

      --busca cadastro de associados
      CURSOR cr_crapass(pr_nrdconta IN crapdir.nrdconta%TYPE) IS
        SELECT   cdagenci
                ,nrdconta
                ,inpessoa
                ,nrcpfcgc
                ,nmprimtl
        FROM    crapass
        WHERE   crapass.cdcooper = pr_cdcooper
        AND     crapass.nrdconta = pr_nrdconta;
      rw_crapass cr_crapass%ROWTYPE;

      --busca cadastro de valores de imposto de renda
      CURSOR cr_crapvir(pr_nrcpfcgc IN crapass.nrcpfcgc%TYPE
                       ,pr_controle IN NUMBER )  IS
        SELECT  cdcooper
        FROM    crapvir
        WHERE   crapvir.cdcooper = pr_cdcooper
        AND     crapvir.nrcpfbnf = pr_nrcpfcgc
        AND     crapvir.nranocal = vr_ano
        AND     crapvir.nrmesref = pr_controle
        AND     crapvir.cdretenc = vr_cdretenc
        AND     crapvir.nrseqdig = vr_nrseqdig;
      rw_crapvir cr_crapvir%ROWTYPE;

      --busca lancamentos de cotas de capital
      CURSOR cr_craplct(pr_nrdconta IN crapass.nrdconta%TYPE) IS
        SELECT  dtmvtolt
        FROM    craplct
        WHERE   craplct.cdcooper = pr_cdcooper
        AND     to_char(craplct.dtmvtolt,'yyyy') = vr_ano
        AND     craplct.nrdconta = pr_nrdconta
        AND     craplct.cdhistor = 926;
      rw_craplct cr_craplct%ROWTYPE;


      ---------------------------- ESTRUTURAS DE REGISTRO ---------------------
      -- vetor para receber valores do imposto
      TYPE typ_tab_vlimpost IS VARRAY(12) OF NUMBER;
      vr_tab_vlimpost typ_tab_vlimpost:= typ_tab_vlimpost(0,0,0,0,0,0,0,0,0,0,0,0);
      --vetor para receber o valor de rendimento de aplicacoes
      TYPE typ_tab_vlrentot IS VARRAY(12) OF NUMBER;
      vr_tab_vlrentot typ_tab_vlrentot:= typ_tab_vlrentot(0,0,0,0,0,0,0,0,0,0,0,0);

      ------------------------------- VARIAVEIS -------------------------------

      vr_regcriad BOOLEAN;
      vr_mesref   NUMBER;
      vr_cont NUMBER :=0;
      vr_dsobserv VARCHAR2(12);
      --------------------------- SUBROTINAS INTERNAS --------------------------


      --------------- VALIDACOES INICIAIS -----------------
    BEGIN

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
      IF vr_cdcritic <> 0 THEN
        -- Envio centralizado de log de erro
        RAISE vr_exc_saida;
      END IF;

      --------------- REGRA DE NEGOCIO DO PROGRAMA -----------------
      --monta data ultimo dia do ano
      vr_dtmvtolt := to_date('31122018','ddmmyyyy');--to_date(12||31||to_char(rw_crapdat.dtmvtolt,'yyyy')-1,'mmddyyyy');
      vr_ano := 2018;
      --verifica se a data calculada é dia util, caso nao for pega o dia util anterior
      /*vr_dtmvtolt := gene0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper,
                                                 pr_dtmvtolt => vr_dtmvtolt,
                                                 pr_tipo     => 'A'
                                                 );*/

      FOR rw_crapdir IN cr_crapdir -- busca dados geracao de Imposto Renda
      LOOP
        EXIT WHEN cr_crapdir%NOTFOUND;
        OPEN cr_crapass(rw_crapdir.nrdconta);--busca associado
        FETCH cr_crapass INTO rw_crapass;
        IF cr_crapass%NOTFOUND THEN -- se nao encontrou associado gera critica e pula para proximo
          CLOSE cr_crapass;
          vr_cdcritic := 9;
          -- Buscar a descrição
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
          -- Envio centralizado de log de erro
          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                    ,pr_ind_tipo_log => 2 -- Erro tratato
                                    ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                   || vr_cdprogra || ' --> '
                                                   || vr_dscritic );
          continue;
        ELSE
          CLOSE cr_crapass;
        END IF;
        /* 3426/8053 -> IR sobre aplicacoes finnanceiras de renda fixa, exceto em
                       fundos de investimento */
        --verifica se eh pessoa fisica
        IF  rw_crapass.inpessoa = 1   THEN
          vr_cdretenc := 8053;
        ELSE
          vr_cdretenc := 3426;
        END IF;
        vr_nrseqdig := nvl(vr_nrseqdig,0) + 1;
        --popula vetor para cada mes de 1 a 12
        vr_tab_vlimpost(1) := rw_crapdir.vlirabap##1 + rw_crapdir.vlirajus##1 +
                              rw_crapdir.vlirrdca##1 + rw_crapdir.vlrirrpp##1 +
                              rw_crapdir.vlirfrdc##1;

        vr_tab_vlimpost(2) := rw_crapdir.vlirabap##2 + rw_crapdir.vlirajus##2 +
                              rw_crapdir.vlirrdca##2 + rw_crapdir.vlrirrpp##2 +
                              rw_crapdir.vlirfrdc##2;

        vr_tab_vlimpost(3) := rw_crapdir.vlirabap##3 + rw_crapdir.vlirajus##3 +
                              rw_crapdir.vlirrdca##3 + rw_crapdir.vlrirrpp##3 +
                              rw_crapdir.vlirfrdc##3;

        vr_tab_vlimpost(4) := rw_crapdir.vlirabap##4 + rw_crapdir.vlirajus##4 +
                              rw_crapdir.vlirrdca##4 + rw_crapdir.vlrirrpp##4 +
                              rw_crapdir.vlirfrdc##4;

        vr_tab_vlimpost(5) := rw_crapdir.vlirabap##5 + rw_crapdir.vlirajus##5 +
                              rw_crapdir.vlirrdca##5 + rw_crapdir.vlrirrpp##5 +
                              rw_crapdir.vlirfrdc##5;

        vr_tab_vlimpost(6) := rw_crapdir.vlirabap##6 + rw_crapdir.vlirajus##6 +
                              rw_crapdir.vlirrdca##6 + rw_crapdir.vlrirrpp##6 +
                              rw_crapdir.vlirfrdc##6;

        vr_tab_vlimpost(7) := rw_crapdir.vlirabap##7 + rw_crapdir.vlirajus##7 +
                              rw_crapdir.vlirrdca##7 + rw_crapdir.vlrirrpp##7 +
                              rw_crapdir.vlirfrdc##7;

        vr_tab_vlimpost(8) := rw_crapdir.vlirabap##8 + rw_crapdir.vlirajus##8 +
                              rw_crapdir.vlirrdca##8 + rw_crapdir.vlrirrpp##8 +
                              rw_crapdir.vlirfrdc##8;

        vr_tab_vlimpost(9) := rw_crapdir.vlirabap##9 + rw_crapdir.vlirajus##9 +
                              rw_crapdir.vlirrdca##9 + rw_crapdir.vlrirrpp##9 +
                              rw_crapdir.vlirfrdc##9;

        vr_tab_vlimpost(10):= rw_crapdir.vlirabap##10 + rw_crapdir.vlirajus##10 +
                              rw_crapdir.vlirrdca##10 + rw_crapdir.vlrirrpp##10 +
                              rw_crapdir.vlirfrdc##10;

        vr_tab_vlimpost(11):= rw_crapdir.vlirabap##11 + rw_crapdir.vlirajus##11 +
                              rw_crapdir.vlirrdca##11 + rw_crapdir.vlrirrpp##11 +
                              rw_crapdir.vlirfrdc##11;

        vr_tab_vlimpost(12):= rw_crapdir.vlirabap##12 + rw_crapdir.vlirajus##12 +
                              rw_crapdir.vlirrdca##12 + rw_crapdir.vlrirrpp##12 +
                              rw_crapdir.vlirfrdc##12;

       vr_tab_vlrentot(1) := rw_crapdir.vlrentot##1;
       vr_tab_vlrentot(2) := rw_crapdir.vlrentot##2;
       vr_tab_vlrentot(3) := rw_crapdir.vlrentot##3;
       vr_tab_vlrentot(4) := rw_crapdir.vlrentot##4;
       vr_tab_vlrentot(5) := rw_crapdir.vlrentot##5;
       vr_tab_vlrentot(6) := rw_crapdir.vlrentot##6;
       vr_tab_vlrentot(7) := rw_crapdir.vlrentot##7;
       vr_tab_vlrentot(8) := rw_crapdir.vlrentot##8;
       vr_tab_vlrentot(9) := rw_crapdir.vlrentot##9;
       vr_tab_vlrentot(10):= rw_crapdir.vlrentot##10;
       vr_tab_vlrentot(11):= rw_crapdir.vlrentot##11;
       vr_tab_vlrentot(12):= rw_crapdir.vlrentot##12;

        vr_regcriad := FALSE;
        FOR vr_controle IN 1..12 --varre varray
        LOOP
          /* Criar registro apenas quando houver valores */
          IF vr_tab_vlimpost(vr_controle) = 0   AND
            vr_tab_vlrentot(vr_controle)  = 0   THEN
            continue;
          END IF;
          --busca se existe os valores de imposto para o cpf
          OPEN cr_crapvir(rw_crapass.nrcpfcgc, vr_controle);
          FETCH cr_crapvir INTO rw_crapvir;
          IF cr_crapvir%NOTFOUND THEN
            CLOSE cr_crapvir;
          --insere os dados caso nao exista imposto para o cpf
            BEGIN
              INSERT INTO crapvir
              ( cdcooper
               ,nrcpfbnf
               ,nranocal
               ,nrmesref
               ,cdretenc
               ,nrseqdig
               ,tporireg
               ,vlrrtirf
               ,vlrdrtrt
              )
              VALUES
              ( pr_cdcooper
               ,rw_crapass.nrcpfcgc
               ,vr_ano
               ,vr_controle
               ,vr_cdretenc
               ,vr_nrseqdig
               ,1
               ,vr_tab_vlimpost(vr_controle) *100
               ,vr_tab_vlrentot(vr_controle) *100
              );
              vr_regcriad := TRUE;
            EXCEPTION
              WHEN OTHERS THEN --gera log erro
                vr_dscritic := SQLERRM;
                -- Envio centralizado de log de erro
                btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                          ,pr_ind_tipo_log => 2 -- Erro tratato
                                          ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                        || vr_cdprogra || ' --> '
                                        || vr_dscritic );
                RAISE vr_exc_saida;
            END;
          ELSE
            CLOSE cr_crapvir;
          END IF;
        END LOOP;
        --grava informacoes crapvir
        COMMIT;
        vr_dsobserv := lpad(rw_crapass.cdagenci, 3,'0')||' '||lpad(rw_crapass.nrdconta,8,'0');
        /*  A tabela crapdrf deverá criar registro somente se existir valor para
            algum mes. */
        IF vr_regcriad THEN
          BEGIN
            INSERT INTO crapdrf --insere dados DIRF
            ( cdretenc
             ,nrseqdig
             ,tporireg
             ,tpregist
             ,dtmvtolt
             ,nranocal
             ,inpessoa
             ,insitimp
             ,nmbenefi
             ,nrcpfbnf
             ,nrcpfcgc
             ,nrdconta
             ,dsobserv
             ,cdcooper
            )
            VALUES
            ( vr_cdretenc
             ,vr_nrseqdig
             ,1
             ,2
             ,rw_crapdir.dtmvtolt
             ,vr_ano
             ,rw_crapass.inpessoa
             ,0
             ,rw_crapass.nmprimtl
             ,rw_crapass.nrcpfcgc
             ,rw_crapcop.nrdocnpj
             ,rw_crapdir.nrdconta
             ,vr_dsobserv
             ,pr_cdcooper
            );
          EXCEPTION
            WHEN OTHERS THEN
            --gera log erro
              vr_dscritic := SQLERRM;
                -- Envio centralizado de log de erro
                btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                          ,pr_ind_tipo_log => 2 -- Erro tratato
                                          ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                        || vr_cdprogra || ' --> '
                                        || vr_dscritic );
                RAISE vr_exc_saida;

          END;
        END IF;
        /* Cfe. IN 1.216 DE 15/12/2011 art. 11 parágrafo 4º: Não considerar para
           fins de informações no arquivo da DIRF e no Informe de Rendimentos quando
           houver IRRF código 5706 igual ou inferior a R$ 10,00
           Valor alterado de R$10,00 para $R0,00 em 02/2013 */

        IF rw_crapdir.vlirfcot > 0 THEN -- Valor do IRRF sobre rendimento ao capital > 0
          /* Identificar o mes de credito das SOBRAS */
          OPEN cr_craplct(rw_crapass.nrdconta);
          FETCH cr_craplct INTO rw_craplct;
          CLOSE cr_craplct;
--          vr_cdretenc := 5706; /* IRRF Juros Sobre Capital Proprio */
          vr_cdretenc := 3277;
          vr_mesref   := to_char(rw_craplct.dtmvtolt,'mm');--mes referencia
          BEGIN
            INSERT INTO crapvir --insere dados Imposto Renda
            ( cdcooper
             ,nrcpfbnf
             ,nranocal
             ,nrmesref
             ,cdretenc
             ,nrseqdig
             ,tporireg
             ,vlrrtirf
             ,vlrdrtrt
            )
            VALUES
            ( pr_cdcooper
             ,rw_crapass.nrcpfcgc
             ,vr_ano
             ,vr_mesref
             ,vr_cdretenc
             ,vr_nrseqdig
             ,1
             ,rw_crapdir.vlirfcot * 100
             ,rw_crapdir.vlrencot * 100
            );
          EXCEPTION
            WHEN OTHERS THEN
            -- gera log erro
              vr_dscritic := SQLERRM;
              -- Envio centralizado de log de erro
              btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                        ,pr_ind_tipo_log => 2 -- Erro tratato
                                        ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                      || vr_cdprogra || ' --> '
                                      || vr_dscritic );
             RAISE vr_exc_saida;
          END;
          BEGIN -- insere dados DIRF
            INSERT INTO crapdrf
            ( cdretenc
             ,nrseqdig
             ,tporireg
             ,tpregist
             ,dtmvtolt
             ,nranocal
             ,inpessoa
             ,insitimp
             ,nmbenefi
             ,nrcpfbnf
             ,nrcpfcgc
             ,nrdconta
             ,dsobserv
             ,cdcooper
            )
            VALUES
            (  vr_cdretenc
              ,vr_nrseqdig
              ,1
              ,2
              ,rw_crapdir.dtmvtolt
              ,vr_ano
              ,rw_crapass.inpessoa
              ,0
              ,rw_crapass.nmprimtl
              ,rw_crapass.nrcpfcgc
              ,rw_crapcop.nrdocnpj
              ,rw_crapdir.nrdconta
              ,vr_dsobserv
              ,pr_cdcooper
            );
          EXCEPTION
            WHEN OTHERS THEN
            -- gera log erro
              vr_dscritic := SQLERRM;
              -- Envio centralizado de log de erro
              btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                        ,pr_ind_tipo_log => 2 -- Erro tratato
                                        ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                      || vr_cdprogra || ' --> '
                                      || vr_dscritic );
             RAISE vr_exc_saida;
          END;
        END IF;
       --calculo para commitar parcialmente
        IF vr_cont > 0 AND mod(vr_cont,1000) = 0 THEN
          COMMIT;
        END IF;
        vr_cont := vr_cont +1;
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
    END;

  END pc_crps433_w;  

BEGIN
 
 -- remove 2 linhas de cabeçalho geradas de forma inválida para 2018. 
 DELETE crapdrf crapdrf
 WHERE crapdrf.nranocal = 2018   
 and crapdrf.cdcooper IN (1,12);

  -- Gerar os dados de todas as cooperativas
  FOR reg IN (SELECT * FROM crapcop a WHERE a.flgativo = 1 ORDER BY a.cdcooper) LOOP
   
    pc_crps433_w (pr_cdcooper => reg.cdcooper   --> Cooperativa solicitada
                 ,pr_flgresta => 0              --> Flag padrão para utilização de restart
                 ,pr_stprogra => wpr_stprogra   --> Saída de termino da execução
                 ,pr_infimsol => wpr_infimsol   --> Saída de termino da solicitação
                 ,pr_cdcritic => wpr_cdcritic   --> Critica encontrada
                 ,pr_dscritic => wpr_dscritic);
    IF wpr_cdcritic <> 0 OR wpr_dscritic IS NOT NULL THEN
      dbms_output.put_line('Erro (Coop: '||reg.cdcooper||'): '||wpr_cdcritic||' e '||substr(wpr_dscritic,1,60));
    ELSE
      dbms_output.put_line('Sucesso Coop: '||reg.cdcooper);  
    END IF;
    
    COMMIT;
   
  END LOOP;  

  
end;
/
