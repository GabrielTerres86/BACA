CREATE OR REPLACE PROCEDURE CECRED.
         pc_crps162 (pr_cdcooper IN crapcop.cdcooper%TYPE   --> Cooperativa solicitada
                    ,pr_flgresta  IN PLS_INTEGER            --> Flag padrão para utilização de restart
                    ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                    ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                    ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                    ,pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada
  BEGIN
    /* .............................................................................

       Programa: pc_crps162 (Fontes/crps162.p)
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Deborah/Edson
       Data    : Junho/96.                    Ultima atualizacao: 21/01/2015

       Dados referentes ao programa:

       Frequencia: Mensal.
       Objetivo  : Atende a solicitacao 4.
                   Emite relatorio dos emprestimos em atraso e em credito em
                   liquidacao (129).
       Alteracoes: 02/02/98 - Alterado de 2 para 3 copias (Deborah).

                   28/04/98 - Tratamento para milenio e troca para V8 (Margarete).

                   15/02/2006 - Unificacao dos bancos - SQLWorks - Eder

                   29/12/2006 - Efetuado acerto validacao leitura crapass(MIrtes)

                   05/03/2008 - Tratamento para o caso de nao haver taxa no mes de
                              calculo e liberacao do imprim.p (Evandro).
                   09/04/2008 - Alterado formato do campo "crapepr.qtpreemp" e da
                              variável "rel_qtpreemp"
                              de "999" para "zz9" para visualização no FORM
                              - Kbase IT Solutions - Paulo Ricardo Maciel.

                   01/09/2008 - Alteracao CDEMPRES (Kbase).

                   09/10/2008 - Estava buscando taxa do mes novo (Magui).

                   09/09/2013 - Nova forma de chamar as agências, de PAC agora
                              a escrita será PA (André Euzébio - Supero).
                   19/12/2013 - Conversão Progress >> Oracle PLSQL (Tiago Castro - RKAM).

                   21/01/2015 - Alterado o formato do campo nrctremp para 8
                                caracters (Kelvin - 233714)
    ............................................................................ */

    DECLARE

      ------------------------ VARIAVEIS PRINCIPAIS ----------------------------

      -- Código do programa
      vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'CRPS162';

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
          FROM crapcop cop
         WHERE cop.cdcooper = pr_cdcooper;
      rw_crapcop cr_crapcop%ROWTYPE;

      -- Cursor genérico de calendário
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;

      -- busca dados de emprestimos em atrazo da cooperativa
      CURSOR cr_crapepr IS
        SELECT  crapepr.cdcooper,
                crapepr.nrdconta,
                crapepr.nrctremp,
                crapepr.qtmesdec,
                crapepr.qtprecal,
                crapepr.vlsdeved,
                crapepr.qtpreemp,
                crapepr.dtinipag,
                crapepr.cdlcremp,
                crapepr.vlpreemp,
                crapepr.cdempres,
                crapepr.dtmvtolt,
                crapepr.dtultpag
        FROM    crapepr
        WHERE   crapepr.cdcooper = pr_cdcooper
        AND     crapepr.vlsdeved > 0
        AND     crapepr.inliquid = 0
        AND     (crapepr.qtmesdec - crapepr.qtprecal) > 1
        ORDER   BY crapepr.cdagenci,crapepr.nrdconta,crapepr.cdempres;

      rw_crapepr cr_crapepr%ROWTYPE;

      -- busca dados dos emprestimos das contas em atrazo
      CURSOR cr_crawepr(pr_cdcooper IN NUMBER,
                        pr_nrdconta IN NUMBER,
                        pr_nrctremp IN NUMBER
                        ) IS
        SELECT crawepr.dtdpagto
        FROM   crawepr
        WHERE  crawepr.cdcooper = pr_cdcooper
        AND    crawepr.nrdconta = pr_nrdconta
        AND    crawepr.nrctremp = pr_nrctremp;
      rw_crawepr cr_crawepr%ROWTYPE;

      --busca dados dos associados
      CURSOR cr_crapass(pr_nrdconta IN NUMBER) IS
        SELECT crapass.dtdemiss,
               crapass.cdagenci,
               crapass.nrdconta,
               crapass.nmprimtl
        FROM   crapass
        WHERE  crapass.cdcooper = pr_cdcooper
        AND    crapass.nrdconta = pr_nrdconta;
      rw_crapass cr_crapass%ROWTYPE;

      -- busca dados das taxas
      CURSOR cr_craptax(pr_dtcalcul IN DATE, pr_cdlcremp IN NUMBER) IS
        SELECT craptax.txmensal,
               craptax.dtmvtolt
        FROM   craptax
        WHERE  craptax.cdcooper = pr_cdcooper
        AND    craptax.dtmvtolt > pr_dtcalcul
        AND    craptax.tpdetaxa = 1
        AND    craptax.cdlcremp = pr_cdlcremp;
      rw_craptax cr_craptax%ROWTYPE;

      -- busca dados dos PAs
      CURSOR cr_crapage(pr_cdagenci IN NUMBER) IS
        SELECT nmresage
        FROM   crapage
        WHERE  crapage.cdcooper = pr_cdcooper
        AND    crapage.cdagenci = pr_cdagenci;



      ---------------------------- ESTRUTURAS DE REGISTRO ---------------------

      TYPE typ_reg_relato IS
        RECORD (cdagenci crapass.cdagenci%TYPE
               ,nrdconta crapass.nrdconta%TYPE
               ,nmprimtl crapass.nmprimtl%TYPE
               ,cdempres crapepr.cdempres%TYPE
               ,nrctremp crapepr.nrctremp%TYPE
               ,dtmvtolt crapepr.dtmvtolt%TYPE
               ,qtpreemp crapepr.qtpreemp%TYPE
               ,qtpredev NUMBER
               ,qtprecal crapepr.qtprecal%TYPE
               ,dtultpag crapepr.dtultpag%TYPE
               ,vlpreemp crapepr.vlpreemp%TYPE
               ,vlpreatr NUMBER
               ,vlprecrl NUMBER
               ,vlsdeved crapepr.vlsdeved%TYPE
               ,dtdemiss DATE
               ,dsdjuros varchar2(12));
      TYPE typ_tab_relato IS
        TABLE OF typ_reg_relato
          INDEX BY VARCHAR2(35); --> 05 PA + 10 Conta + 10 Epr + 10 Empresa
      vr_tab_relato typ_tab_relato;
      vr_des_chave  VARCHAR2(35);

      ------------------------------- VARIAVEIS -------------------------------

     vr_qtpredev_rel NUMBER(8,4);
     vr_qtctremp NUMBER;
     vr_qtctremp NUMBER;
     vr_vlpreatr NUMBER(24,10);
     vr_vlprecrl NUMBER(24,10);
     vr_dtdemiss DATE;
     vr_qtpreatr NUMBER(8,4);
     vr_qtpredev NUMBER(8,4);
     vr_qtintatr NUMBER;
     vr_qtintdev NUMBER;
     vr_qtintcal NUMBER;
     vr_qtdecatr NUMBER(8,4);
     vr_qtdecdev NUMBER(8,4);
     vr_qtdeccal NUMBER(8,4);
     vr_vlcalcul NUMBER;
     vr_txdjuros NUMBER(8,7);
     vr_dtcalcul DATE;
     vr_dtrefpcl DATE;
     vr_flgderro BOOLEAN;
     vr_dtcalant crapdat.dtmvtolt%TYPE;
     vr_nmresage crapage.nmresage%TYPE;
     vr_dsdjuros varchar2(12);

     -- Variaveis para os XMLs e relatórios
     vr_clobxml     CLOB;   -- Clob para conter o XML de dados
     vr_nom_direto  VARCHAR2(200);         -- Diretório para gravação do arquivo





      --------------------------- SUBROTINAS INTERNAS --------------------------
      PROCEDURE pc_escreve_clob(pr_clobdado IN OUT NOCOPY CLOB
                               ,pr_desdados IN VARCHAR2) IS
      BEGIN
        dbms_lob.writeappend(pr_clobdado, length(pr_desdados),pr_desdados);
      END;

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

      vr_dtrefpcl := rw_crapdat.dtinimes;
      vr_dtrefpcl:= gene0005.fn_dtfun(vr_dtrefpcl,-4); -- calcula a data menos 4 meses
--      Leitura dos contratos de emprestimos do associado
      FOR rw_crapepr IN cr_crapepr -- leitura de todas as contas com emprestimos em atrazo
      LOOP
        EXIT WHEN cr_crapepr%NOTFOUND;--sair do loop quando a leitura nao retornar mais dados.
        OPEN cr_crawepr(rw_crapepr.cdcooper, rw_crapepr.nrdconta,rw_crapepr.nrctremp) ;--leitura dos dados das contas em atrazo
        FETCH cr_crawepr INTO rw_crawepr;
        IF cr_crawepr%NOTFOUND THEN
          CLOSE cr_crawepr; --fecha cursor
          CONTINUE;
        ELSE
          CLOSE cr_crawepr; --fecha cursor
        END IF;
        vr_qtpreatr := rw_crapepr.qtmesdec - rw_crapepr.qtprecal; -- calcula prestacoes em atrazo = qtd mes decorridos - qtd de prestacoes calculadas
        vr_vlpreatr := 0;
        vr_vlprecrl := 0;
        vr_vlcalcul := 0;
        vr_flgderro := FALSE;
        IF vr_qtpreatr <= 0 THEN -- verifica se qtd prestacoes em atrazo é maior que zero
          -- Envio centralizado de log de erro
          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                    ,pr_ind_tipo_log => 2 -- Erro tratato
                                    ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                     || vr_cdprogra || ' --> '
                                                     || 'ATENCAO: Verificar este contrato. Conta: '
                                                     || to_char(rw_crapepr.nrdconta,'fm9999,990.9')
                                                     || ' Contrato: '
                                                     || to_char(rw_crapepr.nrctremp,'fm99G999G990')
                                                     || ' qtpreatr: '|| to_char(vr_qtpreatr,'990.9999')
                                                     || ' Saldo: '||to_char(rw_crapepr.vlsdeved,'9999,990.99'));
          CONTINUE;-- proximo registro
        END IF;
        OPEN cr_crapass(rw_crapepr.nrdconta); -- leitura dos associados
        FETCH cr_crapass INTO rw_crapass;
        IF cr_crapass%NOTFOUND THEN -- verifica se encontrou o associado
          CLOSE cr_crapass;-- fecha cursor
          vr_cdcritic := 251;-- Montar mensagem de critica
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)|| ' --> '
                            ||' Conta: ' ||to_char(rw_crapepr.nrdconta,'9999,990,9')
                            ||' Contrato: '|| to_char(rw_crapepr.nrctremp,'fm99G999G990');

          -- Envio centralizado de log de erro
          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                    ,pr_ind_tipo_log => 2 -- Erro tratato
                                    ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                       || vr_cdprogra || ' --> '
                                                       || vr_dscritic );

          --RAISE vr_exc_saida; -- Envio centralizado de log de erro
          CONTINUE;
        ELSE
         CLOSE cr_crapass;--fecha cursor
        END IF;
        -- verifica se qtd meses decorridos eh maior que qtd de prestaçoes
        IF rw_crapepr.qtmesdec > rw_crapepr.qtpreemp THEN
           vr_qtpredev := rw_crapepr.qtpreemp - rw_crapepr.qtprecal; -- pr. devidas = qtd de pestaçoes - qtd prestacoes calculadas
        ELSE
          vr_qtpredev := ((rw_crapepr.qtmesdec - rw_crapepr.qtprecal) - 1); --  pr. devidas = qtd mes decorridos - qtd prestacoes calculadas
        END IF;
        -- verifica se data inicial do pagamento nao é nula
        IF  rw_crapepr.dtinipag IS NOT NULL THEN
          vr_dtcalcul := rw_crapepr.dtinipag;
        ELSE
          vr_dtcalcul := rw_crawepr.dtdpagto;
        END IF;
        IF vr_qtpredev < 0 THEN -- verifica se valor é menor que zero
          vr_qtpredev := (vr_qtpredev * -1) + 4;-- transforma valor em positivo e soma com mais 4
          --verfica se qtd prestacoes dev. é meno que qtd mes decorrentes
          IF vr_qtpredev < rw_crapepr.qtmesdec   THEN
            vr_vlprecrl := rw_crapepr.vlsdeved;
          ELSE
            vr_vlpreatr := rw_crapepr.vlsdeved;
          END IF;
          vr_qtpredev := 0;
          vr_qtpreatr := 0;
        END IF;
        vr_qtpredev_rel := vr_qtpredev;
        --retorna o inteiro e decimal de um valor
        gene0005.pc_intdec(pr_vlcalcul => vr_qtpreatr,--valor entrada
                           pr_vlintcal => vr_qtintatr,--retorno inteiro
                           pr_vldeccal => vr_qtdecatr,--retorno decimal
                           pr_des_erro => vr_dscritic--msg de erro
                           );
        IF vr_dscritic IS NOT NULL THEN--verifica se retornou erro
          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                  ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                   || vr_cdprogra || ' --> '
                                                   || vr_dscritic );
          vr_cdcritic := 0;-- Montar mensagem de critica
          RAISE vr_exc_saida;
        END IF;
        -- retorna o inteiro e decimal de um valor
        gene0005.pc_intdec(pr_vlcalcul => vr_qtpredev,--valor entrada
                           pr_vlintcal => vr_qtintdev,--retorno inteiro
                           pr_vldeccal => vr_qtdecdev,--retorno decimal
                           pr_des_erro => vr_dscritic--msg de erro
                           );
        IF vr_dscritic IS NOT NULL THEN --verifica se retornou erro
          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                  ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                   || vr_cdprogra || ' --> '
                                                   || vr_dscritic );
          vr_cdcritic := 0;-- Montar mensagem de critica
          RAISE vr_exc_saida;
        END IF;
        -- retorna o inteiro e decimal de um valor
        gene0005.pc_intdec(pr_vlcalcul => rw_crapepr.qtprecal,--valor entrada
                           pr_vlintcal => vr_qtintcal,--retorno inteiro
                           pr_vldeccal => vr_qtdeccal,--retorno decimal
                           pr_des_erro => vr_dscritic--msg de erro
                           );
        IF vr_dscritic IS NOT NULL THEN --verifica se retornou erro
           btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                  ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                   || vr_cdprogra || ' --> '
                                                   || vr_dscritic );
          vr_cdcritic := 0;-- Montar mensagem de critica
          RAISE vr_exc_saida;
        END IF;
        -- crapepr qtprecal com valor decimal, essa variavel fica com valor inteiro igual a zero,
        -- nao necessitando somar a data calculada + zero
       if vr_qtintcal > 0 then
        -- calcular data +/- uma quantidade de dias
        vr_dtcalcul:= gene0005.fn_dtfun(vr_dtcalcul,vr_qtintcal);
        end if;

        /*  Calculo das prestacoes em atraso  */

        LOOP
          EXIT WHEN vr_qtpreatr <= 0;--sair quando qtd prestacoes for menor/igual a zero
          IF vr_qtdecatr > 0 THEN
            vr_vlcalcul := rw_crapepr.vlpreemp * vr_qtdecatr;
          ELSE
            vr_vlcalcul := rw_crapepr.vlpreemp;
          END IF;
          OPEN cr_craptax(vr_dtcalcul, rw_crapepr.cdlcremp);--abri cursor passando valor da data como parametro
          FETCH cr_craptax INTO rw_craptax;
          IF cr_craptax%NOTFOUND THEN
            CLOSE cr_craptax;
            vr_cdcritic := 347;-- Montar mensagem de critica
            vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
            -- Envio centralizado de log de erro
            btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                      ,pr_ind_tipo_log => 2 -- Erro tratato
                                      ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                       || vr_cdprogra || ' --> '
                                                       || vr_dscritic || ' --> '
                                                       ||' Conta: ' ||to_char(rw_crapepr.nrdconta,'9999,990,9')
                                                       ||' Contrato: '|| to_char(rw_crapepr.nrctremp,'fm99G999G990')
                                                       ||' Mes/Ano: '||substr(to_char(vr_dtcalcul,'dd/mm/yyyy'),4,7)
                                                       );
            -- RAISE vr_exc_saida; -- Envio centralizado de log de err
            -- REtirado Raise, para que o processo não finalize.

            -- Seta a flag para Erro
            vr_flgderro := TRUE;
            EXIT; -- Sai do loop
          ELSE
            CLOSE cr_craptax;
          END IF;
          IF to_char(rw_craptax.dtmvtolt,'mm')<> to_char(vr_dtcalcul, 'mm') THEN
            vr_cdcritic := 347;-- Montar mensagem de critica
            vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
            -- Envio centralizado de log de erro
            btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                      ,pr_ind_tipo_log => 2 -- Erro tratato
                                      ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                       || vr_cdprogra || ' --> '
                                                       || vr_dscritic || ' --> '
                                                       ||' Conta: '||to_char(rw_crapepr.nrdconta, '9999,990,9')
                                                       ||' Contrato: '||to_char(rw_crapepr.nrctremp, 'fm99G999G990')
                                                       ||' Mes/Ano: '||substr(to_char(vr_dtcalcul, 'dd/mm/yyyy'),4,7)
                                                       );
            -- Seta a flag para Erro
            vr_flgderro := TRUE;
            EXIT; -- Sai do loop
          END IF;
          vr_txdjuros := 1 + (rw_craptax.txmensal / 100);--calcula taxa de juros
          IF vr_dtcalcul < vr_dtrefpcl THEN
            IF vr_qtpredev > 0 THEN
              vr_vlprecrl := vr_vlprecrl + vr_vlcalcul;-- acumula valor credilo liquido.
            END IF;
            vr_vlprecrl := vr_vlprecrl * vr_txdjuros;-- acumula valor credilo liquuido * taxa de juros.
          ELSE
            IF vr_qtpredev > 0 THEN -- verifica se prestacoes devidas eh maior que zero
              vr_vlpreatr := vr_vlpreatr + vr_vlcalcul;--acumumula prestacoes em atrazo
            END IF;
            vr_vlpreatr := vr_vlpreatr * vr_txdjuros;--calcula prestacao em atrazo * o percentual de juros
            vr_vlprecrl := vr_vlprecrl * vr_txdjuros;
          END IF;
          IF vr_qtdecatr > 0 THEN
            vr_qtpreatr := vr_qtpreatr - vr_qtdecatr;
            vr_qtpredev := vr_qtpredev - vr_qtdecdev;
            vr_qtdecatr := 0;
            vr_qtdecdev := 0;
          ELSE
            vr_qtpreatr := vr_qtpreatr - 1; --decrementa qtd de parcelas em atrazo.
            vr_qtpredev := vr_qtpredev - 1; -- decrementa qtd de prestacoes devidas
          END IF;
          vr_dtcalant := vr_dtcalcul;
          vr_dtcalcul:= gene0005.fn_dtfun(vr_dtcalcul,1); -- calcular data calculada +1 mes
          IF vr_dtcalcul > rw_crapdat.dtinimes THEN
            vr_dtcalcul := vr_dtcalant;
          END IF;
        END LOOP; -- fim loop calculo do atraso
        IF vr_flgderro THEN
          CONTINUE;
        END IF;
        /*  Verifica saldo devedor  */
        vr_vlcalcul := vr_vlpreatr + vr_vlprecrl;
        IF vr_vlcalcul > rw_crapepr.vlsdeved THEN -- verifica se o acumulado de debitos eh maior que valor devedor
          vr_vlcalcul := vr_vlcalcul - rw_crapepr.vlsdeved;
        ELSE
          vr_vlcalcul := 0;
        END IF;
        IF vr_vlpreatr > 0 AND vr_vlcalcul > 0 THEN
          IF vr_vlpreatr > vr_vlcalcul THEN
            vr_vlpreatr := vr_vlpreatr - vr_vlcalcul;
            vr_vlcalcul := 0;
          ELSE
            vr_vlcalcul := vr_vlcalcul - vr_vlpreatr;
            vr_vlpreatr := 0;
          END IF;
        END IF;
        IF vr_vlprecrl > 0 AND vr_vlcalcul > 0 THEN
          IF vr_vlprecrl > vr_vlcalcul THEN
            vr_vlprecrl := vr_vlprecrl - vr_vlcalcul;
            vr_vlcalcul := 0;
          ELSE
            vr_vlprecrl := 0;
          END IF;
        END IF;
        IF vr_vlpreatr = 0 AND vr_vlprecrl = 0 AND rw_crapepr.vlsdeved > 0 THEN
          vr_vlprecrl := rw_crapepr.vlsdeved;
        END IF;
        /* Ajuste no CL quando o tempo decorrido ja ultrapassou a quantidade
           de prestacoes contradas - lanca todo o saldo devedor em CL, descontando
           o foi calculado como atraso */
        IF rw_crapepr.qtmesdec > rw_crapepr.qtpreemp THEN
          IF (vr_vlpreatr + vr_vlprecrl) < rw_crapepr.vlsdeved THEN
            IF vr_vlprecrl > 0 THEN
              vr_vlprecrl := rw_crapepr.vlsdeved - vr_vlpreatr;
            ELSE
              vr_vlpreatr := rw_crapepr.vlsdeved;
            END IF;
          END IF;
        END IF;
        IF rw_crapass.dtdemiss IS NULL THEN
          vr_dtdemiss := NULL;
        ELSE
          vr_dtdemiss := rw_crapass.dtdemiss;
        END IF;
        if nvl(vr_qtpredev_rel,0) = 0 then
          vr_dsdjuros := '** JUROS **';
        else
          vr_dsdjuros := null;
        end if;
        -- Finalmente inserir na tabela base ao relatorio
        vr_des_chave := lpad(rw_crapass.cdagenci,5,'0')||lpad(rw_crapepr.nrdconta,10,'0')||lpad(rw_crapepr.cdempres,10,'0')||lpad(rw_crapepr.nrctremp,10,'0');
        vr_tab_relato(vr_des_chave).cdagenci := lpad(rw_crapass.cdagenci,3,'0');-- Agencia
        vr_tab_relato(vr_des_chave).nrdconta := rw_crapass.nrdconta;--conta  crapass
        vr_tab_relato(vr_des_chave).nmprimtl := rw_crapass.nmprimtl;--nome associado
        vr_tab_relato(vr_des_chave).cdempres := rw_crapepr.cdempres;-- codigo empresa onde associado trabalha
        vr_tab_relato(vr_des_chave).nrctremp := rw_crapepr.nrctremp; -- nro conta do emprestimo
        vr_tab_relato(vr_des_chave).dtmvtolt := rw_crapepr.dtmvtolt;--dt movimento atual
        vr_tab_relato(vr_des_chave).qtpreemp := rw_crapepr.qtpreemp;--qt prestacoes do emprestimo
        vr_tab_relato(vr_des_chave).qtpredev := vr_qtpredev_rel;--qt prestacoes dev
        vr_tab_relato(vr_des_chave).qtprecal := rw_crapepr.qtprecal;--qt prestacoes calculadas
        vr_tab_relato(vr_des_chave).dtultpag := rw_crapepr.dtultpag;--dt ultimo pagamento
        vr_tab_relato(vr_des_chave).vlpreemp := rw_crapepr.vlpreemp;--vl prestacao emprestimo
        vr_tab_relato(vr_des_chave).vlpreatr := vr_vlpreatr;--vl prestacao atraso
        vr_tab_relato(vr_des_chave).vlprecrl := vr_vlprecrl;--vl saldo devedor emprestimo
        vr_tab_relato(vr_des_chave).vlsdeved := rw_crapepr.vlsdeved;-- valor saldo devedor emprestimo
        vr_tab_relato(vr_des_chave).dtdemiss := vr_dtdemiss;--dt demissao do associado
        vr_tab_relato(vr_des_chave).dsdjuros := vr_dsdjuros;
      END LOOP;

      -- Com a tabela do relatorio povoada, iremos varre-la para gerar o xml de base ao relatorio

      vr_des_chave := vr_tab_relato.first;
      dbms_lob.createtemporary(vr_clobxml, TRUE, dbms_lob.CALL);
      dbms_lob.open(vr_clobxml, dbms_lob.lob_readwrite);
      pc_escreve_clob(vr_clobxml,'<?xml version="1.0" encoding="utf-8"?><raiz>');
      WHILE vr_des_chave IS NOT NULL LOOP
        -- No primeiro ou ao mudar o PA
        IF vr_des_chave = vr_tab_relato.first OR vr_tab_relato(vr_des_chave).cdagenci <> vr_tab_relato(vr_tab_relato.PRIOR(vr_des_chave)).cdagenci THEN
          -- Gerar a tag do PA
          OPEN cr_crapage(vr_tab_relato(vr_des_chave).cdagenci);
          FETCH cr_crapage INTO vr_nmresage;
          CLOSE cr_crapage;
          IF vr_nmresage IS NULL THEN
            vr_nmresage := '- PA NAO CADASTRADO.';
          END IF;
          pc_escreve_clob(vr_clobxml,'<pac cdagenci="'||vr_tab_relato(vr_des_chave).cdagenci||'" nmresage="'||vr_nmresage||'">');
        END IF;

        -- Enviar detalhe do relatorio
         pc_escreve_clob(vr_clobxml, '<conta>'
                                   ||'  <nrdconta>'||LTRIM(gene0002.fn_mask_conta(vr_tab_relato(vr_des_chave).nrdconta))||'</nrdconta>'
                                   ||'  <titular>'||substr(vr_tab_relato(vr_des_chave).nmprimtl,1,38)||'</titular>'
                                   ||'  <cdempres>'||vr_tab_relato(vr_des_chave).cdempres||'</cdempres>'
                                   ||'  <contrato>'||to_char(gene0002.fn_mask_contrato(vr_tab_relato(vr_des_chave).nrctremp))||'</contrato>'
                                   ||'  <dtmvtolt>'||to_char(vr_tab_relato(vr_des_chave).dtmvtolt,'dd/mm/yyyy')||'</dtmvtolt>'
                                   ||'  <qtpreemp>'||to_char(vr_tab_relato(vr_des_chave).qtprecal,'fm990d0000')||'/ '||vr_tab_relato(vr_des_chave).qtpreemp||'</qtpreemp>'
                                   ||'  <qtpredev>'||to_char(vr_tab_relato(vr_des_chave).qtpredev,'fm990d0000')||'</qtpredev>'
                                   ||'  <qtprecal>'||to_char(vr_tab_relato(vr_des_chave).qtprecal,'fm990d0000')||'</qtprecal>'
                                   ||'  <dtultpag>'||to_char(vr_tab_relato(vr_des_chave).dtultpag,'dd/mm/yyyy')||'</dtultpag>'
                                   ||'  <vlpreemp>'||to_char(vr_tab_relato(vr_des_chave).vlpreemp,'fm999999990d00' )||'</vlpreemp>'
                                   ||'  <vlpreatr>'||to_char(vr_tab_relato(vr_des_chave).vlpreatr,'fm999999990d00'  )||'</vlpreatr>'
                                   ||'  <vlprecrl>'||to_char(vr_tab_relato(vr_des_chave).vlprecrl,'fm999999999d00' )||'</vlprecrl>'
                                   ||'  <vlsdeved>'||to_char(vr_tab_relato(vr_des_chave).vlsdeved,'fm999999999d00' )||'</vlsdeved>'
                                   ||'  <dtdemiss>'||to_char(vr_tab_relato(vr_des_chave).dtdemiss,'dd/mm/yyyy')||'</dtdemiss>'
                                   ||'  <dsdjuros>'||vr_tab_relato(vr_des_chave).dsdjuros||'</dsdjuros>'
                                   ||'</conta>');


        -- No ultimo ou se for mudar o PA
        IF vr_des_chave = vr_tab_relato.last OR vr_tab_relato(vr_des_chave).cdagenci <> vr_tab_relato(vr_tab_relato.NEXT(vr_des_chave)).cdagenci THEN
          -- Gerar a tag do PA
          pc_escreve_clob(vr_clobxml,'</pac>');
        END IF;
        -- Buscar o proximo
        vr_des_chave := vr_tab_relato.NEXT(vr_des_chave);
      END LOOP;

      -- Encerrar tag raiz
      pc_escreve_clob(vr_clobxml,'</raiz>');

      --busca diretorio padrao da cooperativa
      vr_nom_direto := gene0001.fn_diretorio(pr_tpdireto => 'C' --> /usr/coop
                                            ,pr_cdcooper => pr_cdcooper
                                            ,pr_nmsubdir => 'rl');
      --gerar relatorio
      gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper                              --> Cooperativa conectada
                                 ,pr_cdprogra  => vr_cdprogra                          --> Programa chamador
                                 ,pr_dtmvtolt  => rw_crapdat.dtmvtolt                  --> Data do movimento atual
                                 ,pr_dsxml     => vr_clobxml                           --> Arquivo XML de dados
                                 ,pr_dsxmlnode => '/raiz/pac/conta'                    --> Nó base do XML para leitura dos dados
                                 ,pr_dsjasper  => 'crrl129.jasper'                     --> Arquivo de layout do iReport
                                 ,pr_dsparams  => null                                 --> Sem parâmetros
                                 ,pr_dsarqsaid => vr_nom_direto||'/crrl129.lst'       --> Arquivo final com o path
                                 ,pr_qtcoluna  => 132                                  --> 132 colunas
                                 ,pr_flg_gerar => 'N'                                  --> Geraçao na hora
                                 ,pr_flg_impri => 'S'                                  --> Chamar a impressão (Imprim.p)
                                 ,pr_nmformul  => ''                                   --> Nome do formulário para impressão
                                 ,pr_nrcopias  => 3                                    --> Número de cópias
                                 ,pr_sqcabrel  => 1                                    --> Qual a seq do cabrel
                                 ,pr_des_erro  => vr_dscritic);                        --> Saída com erro
      IF vr_dscritic IS NOT NULL THEN
        -- Gerar exceção
        RAISE vr_exc_saida;
      END IF;
      -- Liberando a memória alocada pro CLOB
      dbms_lob.close(vr_clobxml);
      dbms_lob.freetemporary(vr_clobxml);


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

  END pc_crps162;
/

