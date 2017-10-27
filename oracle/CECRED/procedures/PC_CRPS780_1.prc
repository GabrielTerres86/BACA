CREATE OR REPLACE PROCEDURE CECRED.PC_CRPS780_1( pr_cdcooper IN crapcop.cdcooper%TYPE  --> Codigo Cooperativa
                                                ,pr_nrdconta IN crapepr.nrdconta%TYPE  --> Número da conta
                                                ,pr_nrctremp IN crapepr.nrctremp%type  --> contrato de emprestimo
                                                ,pr_vlpagmto in crapepr.vlsdprej%type  --> valor do pagamento
                                                ,pr_vldabono in crapepr.vlsdprej%type  --> valor do abono
                                                ,pr_cdagenci IN crapass.cdagenci%type  --> código da agencia
                                                ,pr_cdoperad IN crapnrc.cdoperad%TYPE  --> Código do operador
                                                ,pr_cdcritic OUT crapcri.cdcritic%TYPE --> Codigo da Critica
                                                ,pr_dscritic OUT VARCHAR2) IS          --> Descricao da Critica
BEGIN

  /* .............................................................................

  Programa: PC_CRPS780_1
  Sistema : Prejuizo - Cooperativa de Credito
  Sigla   : CRED
  Autor   : Jean (Mout´S)
  Data    : Junho/2017.                    Ultima atualizacao:

  Dados referentes ao programa:

  Frequencia: Diaria
         Programa Chamador: PC_CRPS780 (rotina de priorização das parcelas para pagamento)

  Objetivo  : Pagamento de parcelas dos emprestimos em prejuizo

  Alteracoes: 12/06/2017 - Criação da rotina (Everton / Mout´S)

    ............................................................................. */

  DECLARE

    -- Cursor genérico de calendário
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;

    -- Código do programa
      vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'CRPS780_1';

    --Variaveis para retorno de erro
      vr_cdcritic      INTEGER:= 0;
      vr_dscritic      VARCHAR2(4000);

    --Variaveis de Excecao
       vr_exc_erro           EXCEPTION;
       vr_exc_erro_principal EXCEPTION;

    --Procedure para gerar o pagamento das parcelas de empréstimos TR
    PROCEDURE pc_gera_pagamento(pr_cdcooper IN crapcop.cdcooper%TYPE  --> Codigo Cooperativa
                               ,pr_nrdconta IN crapepr.nrdconta%TYPE  --> Número da conta
                               ,pr_nrctremp IN crapepr.nrctremp%type) IS  --> contrato de emprestimo

      -- Variaveis para gravação da craplot
      vr_cdagenci INTEGER := pr_cdagenci;
      vr_cdbccxlt CONSTANT PLS_INTEGER := 100;
      vr_vldabono number;

      ------------------------------- CURSORES ---------------------------------

      -- Buscar o cadastro dos associados da Cooperativa
      CURSOR cr_crapass IS
        SELECT ass.nrdconta
              ,ass.vllimcre
              ,ass.cdagenci
              ,ass.cdsecext
              ,ass.nrramemp
              ,ass.inpessoa
              ,ass.nmprimtl
          FROM crapass ass
         WHERE ass.cdcooper = pr_cdcooper
           AND ass.nrdconta = pr_nrdconta;

      -- Busca das informações de saldo cfme a conta
      CURSOR cr_crapsld IS
        SELECT sld.nrdconta
              ,sld.vlsdblfp
              ,sld.vlsdbloq
              ,sld.vlsdblpr
              ,sld.vlsddisp
              ,sld.vlipmfap
              ,sld.vlipmfpg
              ,sld.vlsdchsl
          FROM crapsld sld
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta;

      -- Busca das informações de históricos de lançamento
      CURSOR cr_craphis IS
        SELECT his.cdhistor
              ,his.inhistor
              ,his.indoipmf
          FROM craphis his
         WHERE cdcooper = pr_cdcooper;

      -- Busca dos empréstimos
      CURSOR cr_crapepr IS
        SELECT epr.rowid
              ,epr.cdcooper
              ,epr.cdorigem
              ,epr.nrdconta
              ,epr.nrctremp
              ,epr.inliquid
              ,epr.qtpreemp
              ,epr.qtprecal
              ,epr.vlsdeved
              ,epr.dtmvtolt
              ,epr.inprejuz
              ,epr.txjuremp
              ,epr.vljuracu
              ,epr.dtdpagto
              ,epr.flgpagto
              ,epr.qtmesdec
              ,epr.vlpreemp
              ,epr.cdlcremp
              ,epr.qtprepag
              ,epr.dtultpag
              ,epr.tpdescto
              ,epr.indpagto
              ,epr.cdagenci
              ,epr.cdfinemp
              ,epr.vlemprst
              ,epr.vlsdprej
              ,epr.tpemprst
              ,nvl(epr.vlttmupr,0) vlttmupr
              ,nvl(epr.vlttjmpr,0) vlttjmpr
              ,nvl(epr.vlpgmupr,0) vlpgmupr
              ,nvl(epr.vlpgjmpr,0) vlpgjmpr
              ,epr.txmensal vltaxa_juros         
          FROM crapepr epr
         WHERE epr.cdcooper = pr_cdcooper
           AND epr.nrdconta = pr_nrdconta
           AND epr.nrctremp = pr_nrctremp
           and epr.inprejuz = 1;

      -- Busca dos lançamentos de deposito a vista
      CURSOR cr_craplcm IS
        SELECT lcm.nrdconta
              ,lcm.dtrefere
              ,lcm.vllanmto
              ,lcm.dtmvtolt
              ,lcm.cdhistor
              ,ROW_NUMBER () OVER (PARTITION BY lcm.nrdconta, lcm.cdhistor
                                       ORDER BY lcm.nrdconta, lcm.cdhistor) sqatureg
          FROM craplcm lcm
         WHERE lcm.cdcooper = pr_cdcooper
           AND lcm.nrdconta = pr_nrdconta
           AND lcm.cdhistor <> 289
           AND lcm.dtmvtolt = rw_crapdat.dtmvtolt
         ORDER BY lcm.cdhistor;

      -- Buscar as capas de lote para a cooperativa e data atual
      CURSOR cr_craplot(pr_nrdolote IN craplot.nrdolote%TYPE
                       ,pr_dtmvtolt IN craplot.dtmvtolt%TYPE) IS
        SELECT lot.cdagenci
              ,lot.cdbccxlt
              ,lot.nrdolote
              ,lot.tplotmov
              ,lot.nrseqdig
              ,lot.vlinfodb
              ,lot.vlcompdb
              ,lot.qtinfoln
              ,lot.qtcompln
              ,lot.vlinfocr
              ,lot.vlcompcr
              ,lot.dtmvtolt
              ,rowid
          FROM craplot lot
         WHERE lot.cdcooper = pr_cdcooper
           AND lot.dtmvtolt = pr_dtmvtolt
           AND lot.cdagenci = vr_cdagenci
           AND lot.cdbccxlt = vr_cdbccxlt
           AND lot.nrdolote = pr_nrdolote;
      -- Criaremos um registro para cada tipo de lote utilizado
      rw_craplot_8457 cr_craplot%ROWTYPE; --> Lancamento de prestação de empréstimo
      rw_craplot_8453 cr_craplot%ROWTYPE; --> Lancamento de pagamento de empréstimo na CC

      -- Verificar se já existe outro lançamento para o lote atual
      CURSOR cr_craplem_nrdocmto(pr_dtmvtolt crapdat.dtmvtolt%TYPE
                                ,pr_nrdolote craplot.nrdolote%TYPE
                                ,pr_nrdconta crapepr.nrdconta%TYPE
                                ,pr_nrdocmto craplem.nrdocmto%TYPE) IS
        SELECT count(1)
          FROM craplem
         WHERE cdcooper = pr_cdcooper
           AND dtmvtolt = pr_dtmvtolt
           AND cdagenci = vr_cdagenci
           AND cdbccxlt = vr_cdbccxlt
           AND nrdolote = pr_nrdolote
           AND nrdconta = pr_nrdconta
           AND nrdocmto = pr_nrdocmto;
      vr_qtd_lem_nrdocmto NUMBER;
  
      cursor c_verifica_lote(pr_cdcooper craplem.cdcooper%type 
                            ,pr_cdagenci craplem.cdagenci%type
                            ,pr_dtmvtolt craplem.dtmvtolt%type
                            ,pr_nrdolote craplem.nrdolote%type) is
         select nvl(max(craplem.nrseqdig) ,0)
         from   craplem
         where  craplem.cdcooper = pr_cdcooper
         and    craplem.cdagenci = pr_cdagenci
         and    craplem.dtmvtolt = pr_dtmvtolt
         and    craplem.nrdolote = pr_nrdolote;
         
      cursor c_crapris (pr_cdcooper craplem.cdcooper%type 
                       ,pr_nrdconta craplem.nrdconta%type
                       ,pr_nrctremp craplem.nrctremp%type) is
                       
         select vljura60
         from   crapris ris
         where  ris.cdcooper = pr_cdcooper
         and    ris.nrdconta = pr_nrdconta
         and    ris.nrctremp = pr_nrctremp
         and    ris.dtrefere = rw_crapdat.dtultdma;
         
        vr_vljura60 crapris.vljura60%type;
         
      ------------------------- ESTRUTURAS DE REGISTRO ---------------------

      -- Definição dos lançamentos de deposito a vista
      TYPE typ_reg_craplcm_det IS
        RECORD(dtrefere craplcm.dtrefere%TYPE,
               vllanmto craplcm.vllanmto%TYPE,
               dtmvtolt craplcm.dtmvtolt%TYPE,
               cdhistor craplcm.cdhistor%TYPE,
               sqatureg NUMBER(05));
      TYPE typ_tab_craplcm_det IS
        TABLE OF typ_reg_craplcm_det
          INDEX BY PLS_INTEGER; -- Cod historico || sequencia registro

      TYPE typ_reg_craplcm IS
        RECORD(tab_craplcm typ_tab_craplcm_det);
      TYPE typ_tab_craplcm IS
        TABLE OF typ_reg_craplcm
          INDEX BY PLS_INTEGER; -- Numero da conta
      vr_tab_craplcm typ_tab_craplcm;

      -- Definição de tipo para armazenar informações dos associados
      TYPE typ_reg_crapass IS
        RECORD(vllimcre crapass.vllimcre%TYPE
              ,cdagenci crapass.cdagenci%TYPE
              ,cdsecext crapass.cdsecext%TYPE
              ,nrramemp crapass.nrramemp%TYPE
              ,inpessoa crapass.inpessoa%TYPE
              ,nmprimtl crapass.nmprimtl%TYPE);
      TYPE typ_tab_crapass IS
        TABLE OF typ_reg_crapass
          INDEX BY PLS_INTEGER; --> Número da conta
      vr_tab_crapass typ_tab_crapass;

      -- Definição de tipo para armazenar informações dos saldos associados
      TYPE typ_reg_crapsld IS
        RECORD(vlsdblfp crapsld.vlsdblfp%TYPE
              ,vlsdbloq crapsld.vlsdbloq%TYPE
              ,vlsdblpr crapsld.vlsdblpr%TYPE
              ,vlsddisp crapsld.vlsddisp%TYPE
              ,vlsdchsl crapsld.vlsdchsl%TYPE
              ,vlipmfap crapsld.vlipmfap%TYPE
              ,vlipmfpg crapsld.vlipmfpg%TYPE);
      TYPE typ_tab_crapsld IS
        TABLE OF typ_reg_crapsld
          INDEX BY PLS_INTEGER; --> Número da conta
      vr_tab_crapsld typ_tab_crapsld;

      -- Definição de tipo para armazenar as informações de histórico
      TYPE typ_reg_craphis IS
        RECORD(inhistor craphis.inhistor%TYPE
              ,indoipmf craphis.indoipmf%TYPE);
      TYPE typ_tab_craphis IS
        TABLE OF typ_reg_craphis
          INDEX BY PLS_INTEGER; --> Código do histórico
      vr_tab_craphis typ_tab_craphis;

      ---------------------- VARIÁVEIS -------------------------
      -- Variáveis de CPMF
      vr_dtinipmf DATE;
      vr_dtfimpmf DATE;
      vr_txcpmfcc NUMBER(12,6);
      vr_txrdcpmf NUMBER(12,6);
      vr_indabono INTEGER;
      vr_dtiniabo DATE;

      -- Variáveis auxiliares no processo
      vr_vldescto     NUMBER(18,6);           --> Valor de desconto das parcelas
      vr_vldescori     NUMBER(18,6);           --> Valor de desconto original
      vr_vlsldtot     NUMBER;                 --> Valor de saldo total
      vr_vlcalcob     NUMBER;                 --> Valor calculado de cobrança
      vr_vlpremes     NUMBER;                 --> Valor da prestação do mês
      vr_ind_lcm      NUMBER(10);             --> Indice da tabela craplcm
      vr_flgrejei     BOOLEAN;                --> Flag para indicação de empréstimo rejeitado
      vr_nrdocmto     craplem.nrdocmto%TYPE;  --> Número do documento para a LEM
      vr_cdhismul     INTEGER;
      vr_vldmulta     NUMBER;
      vr_cdhismor     INTEGER;
      vr_vljumora     NUMBER;
      vr_inusatab     BOOLEAN;                --> Indicador S/N de utilização de tabela de juros
      vr_flgprc       INTEGER;
      vr_cdagencia    number;

      -- Erro em chamadas da pc_gera_erro
      vr_des_reto VARCHAR2(3);
      vr_tab_erro GENE0001.typ_tab_erro;

      -- Variaveis para o CPMF cfme cada histório na craplcm
      vr_inhistor PLS_INTEGER;
      vr_indoipmf PLS_INTEGER;
      vr_txdoipmf NUMBER;
      
      vr_vlpgmupr NUMBER;
      vr_vlpgjmpr NUMBER;
      vr_vlttmupr NUMBER;
      vr_vlttjmpr NUMBER;
      vr_vlsdprej NUMBER;
      vr_tab_dados_epr empr0001.typ_tab_dados_epr;
      vr_qtregist integer;
           

      ----------------- SUBROTINAS INTERNAS --------------------

      -- Subrotina para checar a existência de lote cfme tipo passado
      PROCEDURE pc_cria_craplot(pr_dtmvtolt   IN craplot.dtmvtolt%TYPE
                               ,pr_nrdolote   IN craplot.nrdolote%TYPE
                               ,pr_tplotmov   IN craplot.tplotmov%TYPE
                               ,pr_rw_craplot IN OUT NOCOPY cr_craplot%ROWTYPE
                               ,pr_dscritic  OUT VARCHAR2) IS
      BEGIN
        -- Buscar as capas de lote cfme lote passado
        OPEN cr_craplot(pr_nrdolote => pr_nrdolote
                       ,pr_dtmvtolt => pr_dtmvtolt);
        FETCH cr_craplot
         INTO pr_rw_craplot; --> Rowtype passado
        -- Se não tiver encontrado
        IF cr_craplot%NOTFOUND THEN
          -- Fechar o cursor
          CLOSE cr_craplot;
          -- Efetuar a inserção de um novo registro
          BEGIN
            INSERT INTO craplot(cdcooper
                               ,dtmvtolt
                               ,cdagenci
                               ,cdbccxlt
                               ,nrdolote
                               ,tplotmov
                               ,nrseqdig
                               ,vlinfodb
                               ,vlcompdb
                               ,qtinfoln
                               ,qtcompln
                               ,vlinfocr
                               ,vlcompcr
                               ,cdhistor
                               ,tpdmoeda
                               ,cdoperad)
                         VALUES(pr_cdcooper
                               ,pr_dtmvtolt
                               ,vr_cdagenci
                               ,vr_cdbccxlt
                               ,pr_nrdolote --> Cfme enviado
                               ,pr_tplotmov --> Cfme enviado
                               ,0
                               ,0
                               ,0
                               ,0
                               ,0
                               ,0
                               ,0
                               ,0
                               ,1
                               ,'1')
                       RETURNING dtmvtolt
                                ,cdagenci
                                ,cdbccxlt
                                ,nrdolote
                                ,tplotmov
                                ,nrseqdig
                                ,rowid
                            INTO pr_rw_craplot.dtmvtolt
                                ,pr_rw_craplot.cdagenci
                                ,pr_rw_craplot.cdbccxlt
                                ,pr_rw_craplot.nrdolote
                                ,pr_rw_craplot.tplotmov
                                ,pr_rw_craplot.nrseqdig
                                ,pr_rw_craplot.rowid;
          EXCEPTION
            WHEN OTHERS THEN
              -- Gerar erro e fazer rollback
              pr_dscritic := 'Erro ao inserir capas de lotes (craplot), lote: '||pr_nrdolote||'. Detalhes: '||sqlerrm;
          END;
        ELSE
          -- apenas fechar o cursor
          CLOSE cr_craplot;
        END IF;
      END;

    /* inicio da rotina Pagamento */
    BEGIN
     
          
     IF vr_flgprc = 1 THEN
        vr_flgrejei := TRUE;
      ELSE
        --
        -- Procedimento padrão de busca de informações de CPMF
      /*  gene0005.pc_busca_cpmf(pr_cdcooper  => pr_cdcooper
                              ,pr_dtmvtolt  => to_date(rw_crapdat.dtmvtolt,'dd/mm/yyyy')
                              ,pr_dtinipmf  => vr_dtinipmf
                              ,pr_dtfimpmf  => vr_dtfimpmf
                              ,pr_txcpmfcc  => vr_txcpmfcc
                              ,pr_txrdcpmf  => vr_txrdcpmf
                              ,pr_indabono  => vr_indabono
                              ,pr_dtiniabo  => vr_dtiniabo
                              ,pr_cdcritic  => vr_cdcritic
                              ,pr_dscritic  => vr_dscritic);
        -- Se retornou erro
        IF vr_dscritic IS NOT NULL OR vr_cdcritic IS NOT NULL THEN
          -- Gerar raise
          vr_cdcritic := 0;
          RAISE vr_exc_erro;
        END IF;
        */
        vr_txcpmfcc:=0;
        vr_txrdcpmf:=1;
        vr_indabono:=0;
        --
        -- Busca dos associados da cooperativa
        FOR rw_crapass IN cr_crapass LOOP
          -- Adicionar ao vetor as informações chaveando pela conta
          vr_tab_crapass(rw_crapass.nrdconta).vllimcre := rw_crapass.vllimcre;
          vr_tab_crapass(rw_crapass.nrdconta).cdagenci := rw_crapass.cdagenci;
          vr_tab_crapass(rw_crapass.nrdconta).cdsecext := rw_crapass.cdsecext;
          vr_tab_crapass(rw_crapass.nrdconta).nrramemp := rw_crapass.nrramemp;
          vr_tab_crapass(rw_crapass.nrdconta).nrramemp := rw_crapass.nrramemp;
          vr_tab_crapass(rw_crapass.nrdconta).inpessoa := rw_crapass.inpessoa;
          vr_tab_crapass(rw_crapass.nrdconta).nmprimtl := rw_crapass.nmprimtl;
        END LOOP;

        -- Busca dos lancamentos de deposito a vista
        FOR rw_craplcm IN cr_craplcm LOOP
          -- Adicionar ao vetor as informações chaveando pela conta
          vr_tab_craplcm(rw_craplcm.nrdconta).tab_craplcm(cr_craplcm%ROWCOUNT).dtrefere := rw_craplcm.dtrefere;
          vr_tab_craplcm(rw_craplcm.nrdconta).tab_craplcm(cr_craplcm%ROWCOUNT).vllanmto := rw_craplcm.vllanmto;
          vr_tab_craplcm(rw_craplcm.nrdconta).tab_craplcm(cr_craplcm%ROWCOUNT).dtmvtolt := rw_craplcm.dtmvtolt;
          vr_tab_craplcm(rw_craplcm.nrdconta).tab_craplcm(cr_craplcm%ROWCOUNT).cdhistor := rw_craplcm.cdhistor;
          vr_tab_craplcm(rw_craplcm.nrdconta).tab_craplcm(cr_craplcm%ROWCOUNT).sqatureg := rw_craplcm.sqatureg;
        END LOOP;

        -- Busca das informações de saldo cfme a conta
        FOR rw_crapsld IN cr_crapsld LOOP
          -- Adicionar ao vetor as informações de saldo novamente chaveando pela conta
          vr_tab_crapsld(rw_crapsld.nrdconta).vlsdblfp := rw_crapsld.vlsdblfp;
          vr_tab_crapsld(rw_crapsld.nrdconta).vlsdbloq := rw_crapsld.vlsdbloq;
          vr_tab_crapsld(rw_crapsld.nrdconta).vlsdblpr := rw_crapsld.vlsdblpr;
          vr_tab_crapsld(rw_crapsld.nrdconta).vlsddisp := rw_crapsld.vlsddisp;
          vr_tab_crapsld(rw_crapsld.nrdconta).vlipmfap := rw_crapsld.vlipmfap;
          vr_tab_crapsld(rw_crapsld.nrdconta).vlipmfpg := rw_crapsld.vlipmfpg;
          vr_tab_crapsld(rw_crapsld.nrdconta).vlsdchsl := rw_crapsld.vlsdchsl;
        END LOOP;

        -- Busca do cadastro de histórico
        FOR rw_craphis IN cr_craphis LOOP
          -- Adicionar ao vetor utilizando o histórico como chave
          vr_tab_craphis(rw_craphis.cdhistor).inhistor := rw_craphis.inhistor;
          vr_tab_craphis(rw_craphis.cdhistor).indoipmf := rw_craphis.indoipmf;
        END LOOP;
        --
      END IF;
      --
      -- Busca do Empréstimo
      FOR rw_crapepr IN cr_crapepr LOOP
        --
        -- se parcelas com vencimento anterior já rejeitadas, nem entra no cálculo
        IF vr_flgprc = 1 then
          vr_vldescto := 0;
        ELSE
          if  nvl(pr_vlpagmto,0) = 0 
          and nvl(pr_vldabono,0) = 0 then
             vr_vldescto := rw_crapepr.vlsdprej;
          else
             vr_vldescto := pr_vlpagmto;
             vr_vldabono := pr_vldabono;
          end if;
          --
          -- Verificar se a conta não possui saldo
          IF NOT vr_tab_crapsld.EXISTS(rw_crapepr.nrdconta) THEN
            -- Gerar critica 10
            vr_cdcritic := 10;
            vr_dscritic := gene0001.fn_busca_critica(10) || ' Cta: ' || gene0002.fn_mask_conta(rw_crapepr.nrdconta);
            RAISE vr_exc_erro;
          END IF;

          -- Verificar se a conta não está na crapass
          IF NOT vr_tab_crapass.EXISTS(rw_crapepr.nrdconta) THEN
            -- Gerar critica 251
            vr_cdcritic := 251;
            vr_dscritic := gene0001.fn_busca_critica(251) || ' Cta: ' || gene0002.fn_mask_conta(rw_crapepr.nrdconta);
            RAISE vr_exc_erro;
          END IF;

          -- Calcular o saldo total --
          vr_vlsldtot := NVL(vr_tab_crapsld(rw_crapepr.nrdconta).vlsddisp,0)
                       + NVL(vr_tab_crapass(rw_crapepr.nrdconta).vllimcre,0) - NVL(vr_tab_crapsld(rw_crapepr.nrdconta).vlipmfap,0) - NVL(vr_tab_crapsld(rw_crapepr.nrdconta).vlipmfpg,0);

          -- Calcular o saldo a cobrar --
          vr_vlcalcob := NVL(vr_tab_crapsld(rw_crapepr.nrdconta).vlsddisp,0)
                       + NVL(vr_tab_crapsld(rw_crapepr.nrdconta).vlsdchsl,0) - NVL(vr_tab_crapsld(rw_crapepr.nrdconta).vlipmfap,0)
                       - NVL(vr_tab_crapsld(rw_crapepr.nrdconta).vlipmfpg,0);

          -- Se o valor a cobrar ficar negativo
          IF vr_vlcalcob < 0 THEN
            -- Descontar do total o valor absoluto a cobrar aplicando o * de CPMF
            vr_vlsldtot := vr_vlsldtot - (TRUNC((ABS(vr_vlcalcob)  * vr_txcpmfcc),2));
          END IF;

          -- Busca dos lançamentos de deposito a vista
          IF vr_tab_craplcm.EXISTS(rw_crapepr.nrdconta) THEN
            vr_ind_lcm := vr_tab_craplcm(rw_crapepr.nrdconta).tab_craplcm.first;
            WHILE vr_ind_lcm IS NOT NULL LOOP
              -- No primeiro registro do histórico atual
              IF vr_tab_craplcm(rw_crapepr.nrdconta).tab_craplcm(vr_ind_lcm).sqatureg = 1 THEN
                -- Verificar se o histórico está cadastrado
                IF NOT vr_tab_craphis.EXISTS(vr_tab_craplcm(rw_crapepr.nrdconta).tab_craplcm(vr_ind_lcm).cdhistor) THEN
                  -- Gerar critica 83 no log
                  btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                            ,pr_ind_tipo_log => 2 -- Erro tratato
                                            ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                             || vr_cdprogra || ' --> '
                                                             || to_char(vr_tab_craplcm(rw_crapepr.nrdconta).tab_craplcm(vr_ind_lcm).cdhistor,'fm9900') || ' ' ||gene0001.fn_busca_critica(83) );
                  -- Limpar as variaveis de controle do cpmf
                  vr_inhistor := 0;
                  vr_indoipmf := 0;
                  vr_txdoipmf := 0;
                ELSE
                  -- Utilizaremos do cadastro do histórico
                  vr_inhistor := vr_tab_craphis(vr_tab_craplcm(rw_crapepr.nrdconta).tab_craplcm(vr_ind_lcm).cdhistor).inhistor;
                  vr_indoipmf := vr_tab_craphis(vr_tab_craplcm(rw_crapepr.nrdconta).tab_craplcm(vr_ind_lcm).cdhistor).indoipmf;
                  vr_txdoipmf := vr_txcpmfcc;
                  -- Se houver abono e o histórico for um dos abaixo:
                  -- CDHISTOR DSHISTOR
                  -- -------- --------------------------------------------------
                  -- 114 DB.APLIC.RDCA
                  -- 127 DB. COTAS
                  -- 160 DB.POUP.PROGR
                  -- 177 DB.APL.RDCA60
                  IF vr_indabono = 0 AND vr_tab_craplcm(rw_crapepr.nrdconta).tab_craplcm(vr_ind_lcm).cdhistor IN(0114,0127,0160,0177) THEN
                    -- Indicar que não há CPMF
                    vr_indoipmf := 1;
                    vr_txdoipmf := 0;
                  END IF;
                END IF;
              END IF;

              -- Se houver abono e a data for inferior a data lançada e o histório estiver na lista abaixo:
              -- CDHISTOR DSHISTOR
              -- -------- --------------------------------------------------
              -- 186 CR.ANTEC.RDCA
              -- 187 CR.ANT.RDCA60
              -- 498 CR.ANTEC.RDCA
              -- 500 CR.ANT.RDCA60
              IF vr_indabono = 0 AND vr_dtiniabo <= vr_tab_craplcm(rw_crapepr.nrdconta).tab_craplcm(vr_ind_lcm).dtrefere AND
                 vr_tab_craplcm(rw_crapepr.nrdconta).tab_craplcm(vr_ind_lcm).cdhistor IN(0114,0127,0160,0177) THEN
                -- Descontar do saldo total este lançamento aplicando a taxa de CPMF cadastrada
                vr_vlsldtot := vr_vlsldtot - (TRUNC((vr_tab_craplcm(rw_crapepr.nrdconta).tab_craplcm(vr_ind_lcm).vllanmto * vr_txcpmfcc),2));
              END IF;

              -- Se tivermos um lançamento de crédito da data atual --
              IF vr_tab_craphis(vr_tab_craplcm(rw_crapepr.nrdconta).tab_craplcm(vr_ind_lcm).cdhistor).inhistor IN (1) AND rw_crapdat.dtmvtolt = vr_tab_craplcm(rw_crapepr.nrdconta).tab_craplcm(vr_ind_lcm).dtmvtolt THEN
                -- Tratamento de CPMF --
                IF vr_indoipmf = 2 THEN
                  -- Acumular ao saldo o valor do lançamento aplicando a taxa de CPMF +1 do teste de histórico acima
                  vr_vlsldtot := vr_vlsldtot + (TRUNC((vr_tab_craplcm(rw_crapepr.nrdconta).tab_craplcm(vr_ind_lcm).vllanmto * (1+vr_txdoipmf)),2));
                ELSE
                  -- Apenas acumular o lançamento
                  vr_vlsldtot := vr_vlsldtot + vr_tab_craplcm(rw_crapepr.nrdconta).tab_craplcm(vr_ind_lcm).vllanmto;
                END IF;
              -- Senão, se tivermos um lançamento de débito --
              ELSIF vr_tab_craphis(vr_tab_craplcm(rw_crapepr.nrdconta).tab_craplcm(vr_ind_lcm).cdhistor).inhistor IN(11,13,14,15) THEN
                -- Tratamento de CPMF --
                IF vr_indoipmf = 2 THEN
                  -- Diminuir do saldo o valor do lançamento aplicando a taxa de CPMF +1 do teste de histórico acima
                  vr_vlsldtot := vr_vlsldtot - (TRUNC((vr_tab_craplcm(rw_crapepr.nrdconta).tab_craplcm(vr_ind_lcm).vllanmto * (1+vr_txdoipmf)),2));
                ELSE
                  -- Apenas diminuir o lançamento
                  vr_vlsldtot := vr_vlsldtot - vr_tab_craplcm(rw_crapepr.nrdconta).tab_craplcm(vr_ind_lcm).vllanmto;
                END IF;
              END IF;

              vr_ind_lcm := vr_tab_craplcm(rw_crapepr.nrdconta).tab_craplcm.next(vr_ind_lcm);
            END LOOP; -- Fim leitura craplcm
          END IF;

          -- Armazenar o valor original de desconto
          vr_vlpremes := vr_vldescto;

          -- Se o valor de desconto aplicando a CPMF for maior que o saldo total
          IF TRUNC((vr_vldescto * (1 + vr_txcpmfcc)),2) > vr_vlsldtot 
             AND nvl(pr_vlpagmto,0) = 0 THEN
            -- Se houver saldo total
            IF vr_vlsldtot > 0 THEN
              -- Aplicar a taxa de CPMF
              vr_vldescto := TRUNC(vr_vlsldtot * vr_txrdcpmf,2);
            ELSE
              -- Utilizaremos zero se o pagamento não foi realizado pela tela
              if nvl(pr_vlpagmto,0) = 0 then
                 vr_vldescto := 0;
              end if;
            END IF;
            -- Se o valor original do desconto for superior ao desconto acima ajustado
            IF vr_vlpremes > vr_vldescto THEN
              -- Indicar que há rejeição
              vr_flgrejei := TRUE;
            END IF;
          END IF;
          --
        END IF;
        --
                
        -- Se houver desconto 
        IF vr_vldescto > 0 THEN
            
            if rw_crapepr.tpemprst = 1 then -- emprestimo PP
                -- Calcula multa e juros totais
                EMPR0001.pc_obtem_dados_empresti(pr_cdcooper       => pr_cdcooper ,
                                                 pr_cdagenci       => 1,
                                                 pr_nrdcaixa       => 1,
                                                 pr_cdoperad       => '1',
                                                 pr_nmdatela       => 'crps780',
                                                 pr_idorigem       => 1,
                                                 pr_nrdconta       => pr_nrdconta,
                                                 pr_idseqttl       => 1,
                                                 pr_rw_crapdat     => rw_crapdat,
                                                 pr_dtcalcul       => rw_crapdat.dtmvtolt,
                                                 pr_nrctremp       => pr_nrctremp,
                                                 pr_cdprogra       => 'crps780',
                                                 pr_inusatab       => false,
                                                 pr_flgerlog       => 'S',
                                                 pr_flgcondc       => false,
                                                 pr_nmprimtl       => '',
                                                 pr_tab_parempctl  => '', 
                                                 pr_tab_digitaliza => '',
                                                 pr_nriniseq       => 0,
                                                 pr_nrregist       => 0,
                                                 pr_qtregist       => vr_qtregist,
                                                 pr_tab_dados_epr  => vr_tab_dados_epr,
                                                 pr_des_reto       => vr_des_reto,
                                                 pr_tab_erro       => vr_tab_erro);
                                                 
                 if vr_des_reto <> 'OK' then
                     vr_dscritic := 'Erro ao buscar dados do emprestimo. Conta: ' || 
                                     pr_Nrdconta || ', contrato: ' || pr_nrctremp;
                                     
                    RAISE vr_exc_erro;
                 end if;              
                 
                 vr_vlttmupr := vr_tab_dados_epr(vr_tab_dados_epr.first).vlttmupr;
                 vr_vlttjmpr := vr_tab_dados_epr(vr_tab_dados_epr.first).vlttjmpr;
                 
                 /*if nvl(pr_vlpagmto,0 ) = 0 and nvl(pr_vldabono,0) = 0 then
                    vr_vldescto := vr_vldescto + vr_vlttmupr + vr_vlttjmpr;
                 end if;*/
            end if;
            
            if vr_vlsldtot < vr_vldescto 
            and nvl(pr_vlpagmto,0) = 0  then -- nao tem saldo suficiente na conta corrente para o desconto
               vr_vldescto := vr_vlsldtot;
            end if;
            
            -- Subtrai o valor pago do saldo disponivel
            vr_vlsldtot := vr_vlsldtot - vr_vldescto;
            
            -- Lancamento do valor de juros + 60
            open c_crapris(pr_cdcooper => pr_cdcooper
                          ,pr_nrdconta => rw_crapepr.nrdconta
                          ,pr_nrctremp => rw_crapepr.nrctremp);
            fetch c_crapris into vr_vljura60;
            close c_crapris;
            
            
            
            -- Efetuar lancamento na conta-corrente
            
            empr0001.pc_cria_lancamento_cc(pr_cdcooper => pr_cdcooper 
                                           , pr_dtmvtolt => rw_crapdat.dtmvtolt
                                           , pr_cdagenci => 1 --rw_craplot_8457.cdagenci
                                           , pr_cdbccxlt => 100
                                           , pr_cdoperad => user
                                           , pr_cdpactra => 1 --rw_craplot_8457.cdagenci
                                           , pr_nrdolote => 8457 --rw_craplot_8457.nrdolote
                                           , pr_nrdconta => rw_crapepr.nrdconta
                                           , pr_cdhistor => 2386
                                           , pr_vllanmto => vr_vldescto
                                           , pr_nrparepr => 1
                                           , pr_nrctremp => rw_crapepr.nrctremp
                                           , pr_nrseqava => 0
                                           , pr_idlautom => 0 
                                           , pr_des_reto => vr_des_reto
                                           , pr_tab_erro => vr_tab_erro );
                                                         
                    if vr_des_reto <> 'OK' then
                       vr_dscritic := 'Erro ao gerar lancamento de conta corrente (LCM):' || vr_des_reto;
                       --pr_des_reto := 'NOK';
                       raise vr_exc_erro;
                       
                    end if;
            -- Inicializar número auxiliar de documento com o empréstimo
            vr_nrdocmto := rw_crapepr.nrctremp;
            
            if nvl(vr_vljura60,0) > 0 then
               vr_vldescto := vr_vldescto - vr_vljura60;  
            end if;
            
            -- cria lancamento LEM
            
             empr0001.pc_cria_lancamento_lem(pr_cdcooper => pr_cdcooper
                                                   ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                                   ,pr_cdagenci => pr_cdagenci
                                                   ,pr_cdbccxlt => 100
                                                   ,pr_cdoperad => pr_cdoperad
                                                   ,pr_cdpactra => pr_cdagenci
                                                   ,pr_tplotmov => 5
                                                   ,pr_nrdolote => 600029
                                                   ,pr_nrdconta => rw_crapepr.nrdconta
                                                   ,pr_cdhistor => 2388 -- valor principal
                                                   ,pr_nrctremp => rw_crapepr.nrctremp
                                                   ,pr_vllanmto => vr_vldescto
                                                   ,pr_dtpagemp => rw_crapdat.dtmvtolt
                                                   ,pr_txjurepr => 0
                                                   ,pr_vlpreemp => 0
                                                   ,pr_nrsequni => 0
                                                   ,pr_nrparepr => 0
                                                   ,pr_flgincre => true
                                                   ,pr_flgcredi => false
                                                   ,pr_nrseqava => 0
                                                   ,pr_cdorigem => 7 -- batch
                                                   ,pr_cdcritic => vr_cdcritic
                                                   ,pr_dscritic => vr_dscritic);
                                                           
                      if vr_dscritic is not null then
                          vr_dscritic := 'Ocorreu erro ao retornar gravação LEM (valor principal): ' || vr_dscritic;
                          --pr_des_reto := 'NOK';
                          raise vr_exc_erro;
                       end if;
                       
           -- Lancamento de juros + 60 -  2473
          if nvl(vr_vljura60,0) > 0 then
              empr0001.pc_cria_lancamento_lem(pr_cdcooper => pr_cdcooper
                                                   ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                                   ,pr_cdagenci => pr_cdagenci
                                                   ,pr_cdbccxlt => 100
                                                   ,pr_cdoperad => pr_cdoperad
                                                   ,pr_cdpactra => pr_cdagenci
                                                   ,pr_tplotmov => 5
                                                   ,pr_nrdolote => 600029
                                                   ,pr_nrdconta => rw_crapepr.nrdconta
                                                   ,pr_cdhistor => 2473 -- juros de mora
                                                   ,pr_nrctremp => rw_crapepr.nrctremp
                                                   ,pr_vllanmto => vr_vljura60
                                                   ,pr_dtpagemp => rw_crapdat.dtmvtolt
                                                   ,pr_txjurepr => 0
                                                   ,pr_vlpreemp => 0
                                                   ,pr_nrsequni => 0
                                                   ,pr_nrparepr => 0
                                                   ,pr_flgincre => true
                                                   ,pr_flgcredi => false
                                                   ,pr_nrseqava => 0
                                                   ,pr_cdorigem => 7 -- batch
                                                   ,pr_cdcritic => vr_cdcritic
                                                   ,pr_dscritic => vr_dscritic);
                                                           
                      if vr_dscritic is not null then
                          vr_dscritic := 'Ocorreu erro ao retornar gravação LEM (valor juros+60): ' || vr_dscritic;
                          --pr_des_reto := 'NOK';
                          raise vr_exc_erro;
                       end if;
              

          end if;
          
          
          IF rw_crapepr.txjuremp <> rw_crapepr.vltaxa_juros THEN
            rw_crapepr.txjuremp := rw_crapepr.vltaxa_juros;
            vr_inusatab := true;
          ELSE
            vr_inusatab := false;
          END IF;

          -- Caso pagamento seja menor que data atual
        
          -- Zerar o valor de desconto
        Else
           vr_vldescto := 0;
           if pr_vlpagmto > 0 then
              vr_dscritic := 'Nao existe saldo suficiente para efetuar o pagamento.';                        
              RAISE vr_exc_erro;
           end if;
        end if;
          
        if nvl(pr_vldabono,0) > 0 then 
          
            empr0001.pc_cria_lancamento_lem(pr_cdcooper => pr_cdcooper
                                                   ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                                   ,pr_cdagenci => pr_cdagenci
                                                   ,pr_cdbccxlt => 100
                                                   ,pr_cdoperad => pr_cdoperad
                                                   ,pr_cdpactra => pr_cdagenci
                                                   ,pr_tplotmov => 5
                                                   ,pr_nrdolote => 600029
                                                   ,pr_nrdconta => rw_crapepr.nrdconta
                                                   ,pr_cdhistor => 2391 -- abono
                                                   ,pr_nrctremp => rw_crapepr.nrctremp
                                                   ,pr_vllanmto => pr_vldabono
                                                   ,pr_dtpagemp => rw_crapdat.dtmvtolt
                                                   ,pr_txjurepr => 0
                                                   ,pr_vlpreemp => 0
                                                   ,pr_nrsequni => 0
                                                   ,pr_nrparepr => 0
                                                   ,pr_flgincre => true
                                                   ,pr_flgcredi => false
                                                   ,pr_nrseqava => 0
                                                   ,pr_cdorigem => 7 -- batch
                                                   ,pr_cdcritic => vr_cdcritic
                                                   ,pr_dscritic => vr_dscritic);
                                                           
                      if vr_dscritic is not null then
                          vr_dscritic := 'Ocorreu erro ao retornar gravação LEM (valor abono): ' || vr_dscritic;
                          --pr_des_reto := 'NOK';
                          raise vr_exc_erro;
                       end if;
                       
 
          end if;
          
        --
        -- Se o saldo devedor for menor ou igual ao desconto da parcela
        IF rw_crapepr.vlsdprej +  -- saldo devedor atualizado
          (nvl(rw_crapepr.vlttmupr,0) - nvl(rw_crapepr.vlpgmupr,0)) + -- valor residual de multa
          (nvl(rw_crapepr.vlttjmpr,0) - nvl(rw_crapepr.vlpgjmpr,0)) = (vr_vldescto + nvl(pr_vldabono,0)) -- valor residual do juros
        THEN
          -- Indicar que o emprestimo está liquidado
          rw_crapepr.inliquid := 1;
          --rw_crapepr.dtultpag := rw_crapdat.dtmvtolt;
          --
          vr_vlsdprej := nvl(rw_crapepr.vlsdprej,0) - (nvl(vr_vldescto,0) + nvl(pr_vldabono,0));
          
          IF nvl(rw_crapepr.vlpgmupr,0) <= 0  
           OR nvl(rw_crapepr.vlpgjmpr,0) <= 0 THEN -- SE NAO FOI PAGO
            if nvl(rw_crapepr.vlttmupr,0) > 0 
             or nvl(rw_crapepr.vlttjmpr,0) > 0 then
                --vr_vlttmupr := abs(vr_vlsdprej) * rw_crapepr.vlttmupr /( rw_crapepr.vlttmupr + rw_crapepr.vlttjmpr);
                vr_vlpgmupr := abs(vr_vlsdprej) * rw_crapepr.vlttmupr /( rw_crapepr.vlttmupr + rw_crapepr.vlttjmpr);
                --vr_vlttjmpr := abs(vr_vlsdprej) * rw_crapepr.vlttjmpr /( rw_crapepr.vlttmupr + rw_crapepr.vlttjmpr);            
                vr_vlpgjmpr := abs(vr_vlsdprej) * rw_crapepr.vlttjmpr /( rw_crapepr.vlttmupr + rw_crapepr.vlttjmpr);            
            else
              --vr_vlttmupr := 0;
              vr_vlpgmupr := 0;
              --vr_vlttjmpr := 0;
               vr_vlpgjmpr := 0;
            end if;          
          END IF;
          -- Desativar o Rating associado a esta operaçao
          rati0001.pc_desativa_rating(pr_cdcooper   => pr_cdcooper         --> Código da Cooperativa
                                     ,pr_cdagenci   => 0                   --> Código da agência
                                     ,pr_nrdcaixa   => 0                   --> Número do caixa
                                     ,pr_cdoperad   => pr_cdoperad         --> Código do operador
                                     ,pr_rw_crapdat => rw_crapdat          --> Vetor com dados de parâmetro (CRAPDAT)
                                     ,pr_nrdconta   => rw_crapepr.nrdconta --> Conta do associado
                                     ,pr_tpctrrat   => 90                  --> Tipo do Rating (90-Empréstimo)
                                     ,pr_nrctrrat   => rw_crapepr.nrctremp --> Número do contrato de Rating
                                     ,pr_flgefeti   => 'S'                 --> Flag para efetivação ou não do Rating
                                     ,pr_idseqttl   => 1                   --> Sequencia de titularidade da conta
                                     ,pr_idorigem   => 1                   --> Indicador da origem da chamada
                                     ,pr_inusatab   => vr_inusatab         --> Indicador de utilização da tabela de juros
                                     ,pr_nmdatela   => vr_cdprogra         --> Nome datela conectada
                                     ,pr_flgerlog   => 'N'                 --> Gerar log S/N
                                     ,pr_des_reto   => vr_des_reto         --> Retorno OK / NOK
                                     ,pr_tab_erro   => vr_tab_erro);       --> Tabela com possíves erros



          /** GRAVAMES **/
          GRVM0001.pc_solicita_baixa_automatica(pr_cdcooper => pr_cdcooper          -- Código da cooperativa
                                               ,pr_nrdconta => rw_crapepr.nrdconta  -- Numero da conta do contrato
                                               ,pr_nrctrpro => rw_crapepr.nrctremp  -- Numero do contrato
                                               ,pr_dtmvtolt => rw_crapdat.dtmvtolt  -- Data de movimento para baixa
                                               ,pr_des_reto => vr_des_reto          -- Retorno OK ou NOK
                                               ,pr_tab_erro => vr_tab_erro          -- Retorno de erros em PlTable
                                               ,pr_cdcritic => vr_cdcritic          -- Retorno de codigo de critica
                                               ,pr_dscritic => vr_dscritic);        -- Retorno de descricao de critica

          -- zerar o saldo devedor
          rw_crapepr.vlsdprej := 0;
        
        ELSIF (rw_crapepr.vlsdprej +  -- saldo devedor atualizado
              (nvl(rw_crapepr.vlttmupr,0) - nvl(rw_crapepr.vlpgmupr,0)) + -- valor residual de multa
              (nvl(rw_crapepr.vlttjmpr,0) - nvl(rw_crapepr.vlpgjmpr,0))) - (vr_vldescto + nvl(pr_vldabono,0)) > 0 THEN
          
          /* se saldo remanescente de multa + saldo remanescente juros for menor que o valor a descontar,
             assume como pagamento de multa e de juros o mesmo valor de multa e juros */
          if ((nvl(rw_crapepr.vlttmupr,0) - nvl(rw_crapepr.vlpgmupr,0)) + -- valor residual de multa
              (nvl(rw_crapepr.vlttjmpr,0) - nvl(rw_crapepr.vlpgjmpr,0))) < vr_vldescto then
              vr_vlpgmupr := nvl(rw_crapepr.vlttmupr,0);
              vr_vlpgjmpr := nvl(rw_crapepr.vlttjmpr,0);
              -- saldo devedor deve ser a diferença entre o valor descontado e os juros e multa
              rw_crapepr.vlsdprej := rw_crapepr.vlsdprej - (vr_vldescto - vr_vlpgmupr - vr_vlpgjmpr); -- - vr_vlttmupr - vr_vlttjmpr;
          else
             /* se multa + juros for > que valor do desconto + abono, deve calcular multa e juros proporcional
                calcula zero para saldo devedor */
              vr_vldescori := vr_vldescto; -- mantem o desconto original
                /* 1 prioriza multa */
              if rw_crapepr.vlttmupr > 0 then
                  vr_vlpgmupr := rw_crapepr.vlpgmupr + vr_vldescto;
                
                  vr_vldescto := vr_vldescto - (rw_crapepr.vlttmupr - rw_crapepr.vlpgmupr);
                  
                  if vr_vlpgmupr > rw_crapepr.vlttmupr then
                     vr_vlpgmupr := rw_crapepr.vlttmupr  ;
                  end if;
              end if;
              /* 2 prioriza juros */
              
              if rw_crapepr.vlttjmpr > 0 
               and vr_vldescto > 0  then
                 vr_vlpgjmpr :=  rw_crapepr.vlpgjmpr + abs(vr_vldescto);
                  if vr_vlpgjmpr > rw_crapepr.vlttjmpr then
                     vr_vlpgjmpr := rw_crapepr.vlttjmpr ;
                  end if;
              end if;   
              rw_crapepr.vlsdprej := rw_crapepr.vlsdprej - vr_vldescori; 
          end if;
        ELSE
          vr_dscritic := 'Valor de pagamento superior ao valor do saldo disponivel do prejuizo: '||vr_vldescto;
          raise vr_exc_erro;        
        END IF;
        
        
          -- atualizar juros de mora -- 2475
          if nvl(vr_vlpgjmpr,0) > 0 then
            
             empr0001.pc_cria_lancamento_lem(pr_cdcooper => pr_cdcooper
                                                   ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                                   ,pr_cdagenci => pr_cdagenci
                                                   ,pr_cdbccxlt => 100
                                                   ,pr_cdoperad => pr_cdoperad
                                                   ,pr_cdpactra => pr_cdagenci
                                                   ,pr_tplotmov => 5
                                                   ,pr_nrdolote => 600029
                                                   ,pr_nrdconta => rw_crapepr.nrdconta
                                                   ,pr_cdhistor => 2475 -- juros de mora
                                                   ,pr_nrctremp => rw_crapepr.nrctremp
                                                   ,pr_vllanmto => vr_vlpgjmpr
                                                   ,pr_dtpagemp => rw_crapdat.dtmvtolt
                                                   ,pr_txjurepr => 0
                                                   ,pr_vlpreemp => 0
                                                   ,pr_nrsequni => 0
                                                   ,pr_nrparepr => 0
                                                   ,pr_flgincre => true
                                                   ,pr_flgcredi => false
                                                   ,pr_nrseqava => 0
                                                   ,pr_cdorigem => 7 -- batch
                                                   ,pr_cdcritic => vr_cdcritic
                                                   ,pr_dscritic => vr_dscritic);
                                                           
                      if vr_dscritic is not null then
                          vr_dscritic := 'Ocorreu erro ao retornar gravação LEM (valor juros): ' || vr_dscritic;
                          --pr_des_reto := 'NOK';
                          raise vr_exc_erro;
                       end if;

          end if;
          
          -- Lancamento da multa 2390
          if nvl(vr_vlpgmupr,0) > 0 then
             empr0001.pc_cria_lancamento_lem(pr_cdcooper => pr_cdcooper
                                                   ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                                   ,pr_cdagenci => pr_cdagenci
                                                   ,pr_cdbccxlt => 100
                                                   ,pr_cdoperad => pr_cdoperad
                                                   ,pr_cdpactra => pr_cdagenci
                                                   ,pr_tplotmov => 5
                                                   ,pr_nrdolote => 600029
                                                   ,pr_nrdconta => rw_crapepr.nrdconta
                                                   ,pr_cdhistor => 2390 -- juros de mora
                                                   ,pr_nrctremp => rw_crapepr.nrctremp
                                                   ,pr_vllanmto => vr_vlpgmupr
                                                   ,pr_dtpagemp => rw_crapdat.dtmvtolt
                                                   ,pr_txjurepr => 0
                                                   ,pr_vlpreemp => 0
                                                   ,pr_nrsequni => 0
                                                   ,pr_nrparepr => 0
                                                   ,pr_flgincre => true
                                                   ,pr_flgcredi => false
                                                   ,pr_nrseqava => 0
                                                   ,pr_cdorigem => 7 -- batch
                                                   ,pr_cdcritic => vr_cdcritic
                                                   ,pr_dscritic => vr_dscritic);
                                                           
                      if vr_dscritic is not null then
                          vr_dscritic := 'Ocorreu erro ao retornar gravação LEM (valor multa): ' || vr_dscritic;
                         --pr_des_reto := 'NOK';
                          raise vr_exc_erro;
                       end if;
              
 
          end if;
          
        BEGIN
          UPDATE crapepr
            SET dtdpagto  = rw_crapepr.dtdpagto
                --,dtultpag = rw_crapepr.dtultpag
                ,txjuremp = rw_crapepr.txjuremp
                ,indpagto = rw_crapepr.indpagto
                ,vlsdprej = rw_crapepr.vlsdprej  
                ,vlpgjmpr = nvl( vr_vlpgjmpr, nvl(vlpgjmpr,0) )
                ,vlpgmupr = nvl( vr_vlpgmupr, nvl(vlpgmupr,0) )
         WHERE rowid = rw_crapepr.rowid;
        EXCEPTION
          WHEN OTHERS THEN
            -- Gerar erro e fazer rollback
            vr_dscritic := 'Erro ao atualizar o empréstimo (CRAPEPR).'
                        || '- Conta:'||rw_crapepr.nrdconta || ' CtrEmp:'||rw_crapepr.nrctremp
                        || '. Detalhes: '||sqlerrm;
            RAISE vr_exc_erro;
        END;
        --
       
        --
      END LOOP;
      --
    EXCEPTION
      WHEN vr_exc_erro THEN
        -- Se foi retornado apenas código
        IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
          -- Buscar a descrição
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;
        -- Devolvemos código e critica encontradas
        pr_cdcritic := NVL(vr_cdcritic,0);
        pr_dscritic := vr_dscritic;
        -- Efetuar rollback
        ROLLBACK;      
    
      WHEN OTHERS THEN
        --Variavel de erro recebe erro ocorrido
           vr_cdcritic:= 0;
           vr_dscritic:= 'Erro ao criar pagar parcelas. Rotina pc_CRPS780_1.pc_gera_pagamento. - '||nvl(vr_dscritic,sqlerrm);
        --Sair do programa
        RAISE vr_exc_erro_principal;
    END pc_gera_pagamento;

    ---------------------------------------
    -- Inicio Bloco Principal PC_CRPS780_1
    ---------------------------------------
  BEGIN
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
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 1);
        RAISE vr_exc_erro;
      ELSE
        -- Apenas fechar o cursor
        CLOSE btch0001.cr_crapdat;
      END IF;
      
      pc_gera_pagamento(pr_cdcooper
                       ,pr_nrdconta
                       ,pr_nrctremp);
      --
  EXCEPTION
      WHEN vr_exc_erro_principal THEN
        -- Se foi retornado apenas código
        IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
          -- Buscar a descrição
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;
        -- Devolvemos código e critica encontradas
        pr_cdcritic := NVL(vr_cdcritic,0);
        pr_dscritic := vr_dscritic;
        -- Efetuar rollback
        ROLLBACK;

      WHEN OTHERS THEN
        -- Efetuar retorno do erro nao tratado
        pr_cdcritic := 0;
        pr_dscritic := sqlerrm;

        -- Efetuar rollback
        ROLLBACK;
  END;
END PC_CRPS780_1;
/
