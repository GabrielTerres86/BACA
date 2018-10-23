CREATE OR REPLACE PROCEDURE CECRED.PC_CRPS124( pr_cdcooper  IN crapcop.cdcooper%TYPE  --> Cooperativa solicitada
                                              ,pr_flgresta  IN PLS_INTEGER            --> Flag padrão para utilização de restart
                                              ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                                              ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                                              ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                                              ,pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada AS
BEGIN
  /* ..........................................................................

   Programa: PC_CRPS124 (Fontes/crps124.p)
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Junho/95.                       Ultima atualizacao: 20/05/2016

   Dados referentes ao programa:

   Frequencia: Diario (Batch).
   Objetivo  : Atende a solicitacao 040.
               Emitir relatorio dos debitos em conta (102).

   Alteracao : Na leitura do craplau desprezar historicos 21 e 26 (Odair)

               27/04/98 - Tratamento para milenio e troca para V8 (Magui).

               20/04/1999 - Listar por PAC (Deborah).

               17/05/1999 - Tratar somente debitos da matriz via caixa.
                            Os demais debitos serao listados no crps261.
                            (Deborah).

               21/07/99 - Nao enfileirar no MTSPOOL (Odair)

               02/02/2000 - Gerar pedido de impressao (Deborah).

               01/11/2000 - Alterar nrdolote p/6 posicoes (Magui/Planner).

               13/09/2001 - Calcular o saldo e mostrar no relatorio se
                            associado esta com o saldo negativo (Junior).

               01/04/2002 - Alterar a classificacao do relatorio (Junior).

               15/07/2003 - Inserido o codigo para verificar, apartir do tipo de
                            registro do cadastro de tabelas, com qual numero de
                            conta que se esta trabalhando. O numero sera
                            armazenado na variavel aux_lsconta3 (Julio).

               08/01/2004 - Alterado para NAO tratar os historicos 521 e 526
                            (Edson).

               25/01/2005 - Estouro de Campo nrdocmto (Ze Eduardo).

               09/12/2005 - Cheque salario nao existe mais (Magui).

               16/02/2006 - Unificacao dos Bancos de Dados - SQLWorks - Andre

               08/05/2008 - Ajuste comando FIND(craphis) utilizava FOR p/ acesso
                            (Sidnei - Precise)

               04/06/2008 - Campo dsorigem nas leituras da craplau (David)

               20/06/2008 - Incluido a chave de acesso (craphis.cdcooper =
                            glb_cdcooper) no "find" da tabela CRAPHIS.
                          - Kbase IT Solutions - Paulo Ricardo Maciel.

               27/02/2009 - Gerar relatorio 102 em 132col (Gabriel).

               22/04/2009 - Gerar cabecalho do relatorio mesmo que nao haja
                            movimentos (Fernando).

               24/04/2009 - Gerar o relatorio 102 por PAC e tambem gerar
                            o consolidado crrl102_99 (Fernando).

               14/07/2009 - incluido no for each a condicao -
                            craplau.dsorigem <> "PG555" - Precise - paulo

               19/10/2009 - Alteracao Codigo Historico (Kbase).

               09/02/2011 - Incluido novo calculo e nova observacao "Esse pagto
                            gera saldo negativo" no relatorio e ajuste no tamanho
                            do campo craplau.nrdocmto no frame f_debitos (Vitor).

               25/04/2011 - Alterado a validacao do cdbccxlt atraves do crapban
                            para crapbcl (Adriano).

               29/04/2011 - Ajuste na ver_saldo para nao contabilizar o
                            lancamento do debito novamente (Gabriel)

               02/06/2011 - incluido no for each a condicao -
                            craplau.dsorigem <> "TAA" (Evandro).

               30/09/2011 - incluido no for each a condigco -
                            craplau.dsorigem <> "CARTAOBB" (Ze).

               15/05/2012 - substituicao do FIND craptab para os registros
                            CONTACONVE pela chamada do fontes ver_ctace.p
                            (Lucas R.)

               03/06/2013 - incluido no FOR EACH craplau a condicao -
                            craplau.dsorigem <> "BLOQJUD" (Andre Santos - SUPERO)

               04/09/2013 - Conversao Progress >> Oracle PLSQL (Odirlei-AMcom)

               22/11/2013 - Correção na chamada a vr_exc_fimprg, a mesma só deve
                            ser acionada em caso de saída para continuação da cadeia,
                            e não em caso de problemas na execução (Marcos-Supero)

               28/10/2013 - Alterado totalizador de 99 para 999. (Reinert)

               31/10/2013 - Ajustar format para apresentar documento (David).

               01/04/2014 - incluido nas consultas da craplau
                            craplau.dsorigem <> "DAUT BANCOOB" (Lucas).

               24/06/2014 - #139162 Inclusão do nome do cooperado no relatório 
                                                                       (Carlos)
                                                                       
               27/02/2009 - Ajustado parametros relatorio 102 para 234col 
                            SoftDesk 191581 (Daniel).   
                            
               09/12/2014 - Ajustes de Performance. Foi adicionado o hint de ordenação no cursor 
                            cr_craplau para indicar a ordem de tabelas que devem ser usadas para executar
                            a query. Foi eliminada a função pc_busca_nmprimtl que era usada para selecionar
                            o nome do titular. O nome foi buscado no cursor cr_craplau que já acessava a crapass.
                            Foi criado o vetor vr_tab_craphis para carga dos hitoricos eliminando-se os cursores 
                            nessa tabela nas procedures pc_ver_saldo e pc_busca_hist. (Alisson-AMcom) 
                            
               11/02/2015 - Adicionado historico 527 no NOT IN da craplau (Lucas R. #247921 )
               
               27/04/2015 - Adicionado historico 530 no NOT IN da craplau (Lucas Ranghetti #274139 )
               
               28/09/2015 - incluido nas consultas da craplau
                            craplau.dsorigem <> "CAIXA" (Lombardi).
                                
               20/05/2016 - Incluido nas consultas da craplau
                            craplau.dsorigem <> "TRMULTAJUROS". (Jaison/James)
                                
  --           06/08/2018 - PJ450 - TRatamento do nao pode debitar, crítica de negócio, 
  --                        após chamada da rotina de geraçao de lançamento em CONTA CORRENTE.
  --                        Alteração específica neste programa acrescentando o tratamento para a origem
  --                        BLQPREJU
  --                        (Renato Cordeiro - AMcom)
                                
............................................................................. */
  DECLARE
    -- Codigo do programa
    vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'CRPS124';

    -- Tratamento de erros
    vr_exc_erro   exception;
    vr_exc_fimprg exception;
    vr_cdcritic   crapcri.cdcritic%TYPE;
    vr_dscritic   VARCHAR2(4000);

    /* Busca dos dados da cooperativa */
    CURSOR cr_crapcop(pr_cdcooper IN craptab.cdcooper%TYPE) IS
      SELECT cop.nmrescop
            ,cop.nrtelura
            ,cop.dsdircop
            ,cop.cdbcoctl
            ,cop.cdagectl
        FROM crapcop cop
       WHERE cop.cdcooper = pr_cdcooper;
    rw_crapcop cr_crapcop%ROWTYPE;
    /* Cursor generico de calendario */
    RW_CRAPDAT BTCH0001.CR_CRAPDAT%ROWTYPE;

    -- Buscar Lancamentos Automaticos
    CURSOR cr_craplau (pr_cdcooper craptab.cdcooper%TYPE,
                       pr_dtmvtopr CRAPDAT.Dtmvtopr%type) IS
      SELECT /*+ ORDERED */
             cdbccxpg
            ,cdbccxlt
            ,crapass.cdagenci crapass_cdagenci
            ,craplau.cdagenci craplau_cdagenci
            ,nvl(crapass.nmprimtl,'NAO CADASTRADO') nmprimtl  
            ,cdhistor
            ,cdcritic
            ,dtdebito
            ,dtmvtopg
            ,craplau.nrdconta
            ,craplau.nrdocmto
            ,vllanaut
            ,vllimcre
            ,nrseqlan
            ,Count(1) OVER (PARTITION BY crapass.cdcooper,crapass.cdagenci) qtdreg_ag
            ,Row_Number() OVER (PARTITION BY crapass.cdcooper,crapass.cdagenci
                                   ORDER BY crapass.cdagenci, craplau.cdbccxpg
                                          , craplau.cdhistor, craplau.dtmvtopg
                                          , craplau.nrdconta, craplau.nrdocmto
                                          , craplau.cdagenci) nrseqreg_ag
        FROM craplau, crapass
       WHERE craplau.cdcooper = pr_cdcooper
         AND crapass.nrdconta = craplau.nrdconta
         AND crapass.cdcooper = craplau.cdcooper
         AND craplau.dtdebito = pr_dtmvtopr
         AND craplau.insitlau = 2
         AND craplau.cdhistor NOT IN (21,26,521,526,527,530)
         AND (craplau.cdagenci = 1 AND craplau.cdbccxpg = 11)
         AND craplau.dsorigem NOT IN ('CAIXA','INTERNET','TAA','PG555','CARTAOBB','BLOQJUD', 'DAUT BANCOOB','TRMULTAJUROS','BLQPREJU')
    ORDER BY crapass.cdagenci;


    /*  Localiza o lote no qual o lancamento foi criado  */
    CURSOR cr_craplcm (pr_cdcooper craptab.cdcooper%TYPE,
                       pr_dtdebito craplau.dtdebito%type,
                       pr_cdagenci craplau.cdagenci%type,
                       pr_nrdconta craplau.nrdconta%type,
                       pr_nrdocmto craplau.nrdocmto%type,
                       pr_vllanaut craplau.vllanaut%type) IS
      SELECT rowid,
             nrdolote,
             cdbccxlt
        FROM craplcm c
       WHERE c.progress_recid =
                   (SELECT MIN(progress_recid)
                      FROM craplcm
                     WHERE craplcm.cdcooper = pr_cdcooper
                       AND craplcm.dtmvtolt = pr_dtdebito
                       AND craplcm.cdagenci = pr_cdagenci
                       AND craplcm.nrdconta = pr_nrdconta
                       AND craplcm.nrdocmto = pr_nrdocmto
                       AND craplcm.vllanmto = pr_vllanaut);

    rw_craplcm cr_craplcm%rowtype;

    --Buscar Saldos do associado em depositos a vista
    CURSOR cr_crapsld (pr_cdcooper craptab.cdcooper%TYPE,
                       pr_nrdconta craplau.nrdconta%type) IS
      SELECT vlsddisp,
             vlsdbloq,
             vlsdblpr,
             vlsdblfp,
             vlsdchsl,
             vlipmfap,
             nrdconta
        FROM crapsld
       WHERE crapsld.cdcooper = pr_cdcooper
         AND crapsld.nrdconta = pr_nrdconta;
    rw_crapsld cr_crapsld%rowtype;

    -- Buscar parametro da solicitação
    CURSOR cr_dsparame(pr_cdprogra  crapprg.cdprogra%TYPE) IS
      SELECT crapsol.dsparame
        FROM crapsol crapsol
           , crapprg crapprg
        WHERE crapsol.nrsolici = crapprg.nrsolici
          AND crapsol.cdcooper = crapprg.cdcooper
          AND crapprg.cdcooper = pr_cdcooper
          AND crapprg.cdprogra = pr_cdprogra
          AND crapsol.insitsol = 1;

    -- Buscar Historicos do sistema
    CURSOR cr_craphis (pr_cdcooper craptab.cdcooper%TYPE) is
      SELECT cdhistor,
             inhistor,
             indoipmf,
             indebcre,
             dshistor
      FROM craphis
      WHERE craphis.cdcooper = pr_cdcooper;
       
    --Type para armazenar os totais de debito por agencia
    type typ_reg_tdebito is record ( cdagenci     crapass.cdagenci%type,
                                     cdhistor     craplau.cdhistor%type,
                                     qtdebito     number,
                                     vldebito     number);

    type typ_tab_reg_tdebito is table of typ_reg_tdebito
                           index by varchar2(8); --Ag(3) + His(5)

    --Type para armazenar os detalhes para exibicao no relatorio
    type typ_reg_det is record ( cdagenci     crapass.cdagenci%type,
                                 cdhistor     craplau.cdhistor%type,
                                 nrdconta     craplau.nrdconta%type,
                                 nrseqlan     craplau.nrseqlan%type,
                                 vllanaut     craplau.vllanaut%type,
                                 nrdocmto     craplau.nrdocmto%type,
                                 cdbccxlt     craplau.cdbccxlt%type,
                                 nrdolote     craplau.nrdolote%type,
                                 dsobserv     varchar2(500),
                                 nmprimtl     crapass.nmprimtl%type
                                 );

    type typ_tab_reg_det is table of typ_reg_det
                           index by varchar2(54); --Ag(3) + His(5) + Cta(8) + Ndoc(25)

    --Type para armazenar os valores por agencia, para exibicao no relatorio
    type typ_reg_ag is record ( cdagenci       crapass.cdagenci%type,
                                dtdebito       date,
                                cdbccxlt       craplau.cdbccxlt%type,
                                dtmvtopg       date,
                                dtmvtult       date,
                                vr_tab_det     typ_tab_reg_det,
                                vr_tab_tdeb    typ_tab_reg_tdebito
                                 );

    type typ_tab_reg_ag is table of typ_reg_ag
                           index by varchar2(3); --Ag(3)
    vr_tab_ag typ_tab_reg_ag;

    vr_tab_tot_ger typ_tab_reg_tdebito;
    
    --Type para armazenar os valores dos Historicos 
    type typ_reg_craphis is record (inhistor craphis.inhistor%type,
                                    indoipmf craphis.indoipmf%type,
                                    indebcre craphis.indebcre%type,
                                    dshistor craphis.dshistor%type);
    type typ_tab_craphis is table of typ_reg_craphis index by PLS_INTEGER;
    vr_tab_craphis typ_tab_craphis;

    -- Variavel para chaveamento (hash) da tabela de aplicacoes
    vr_des_chave_tdeb    varchar2(8);
    vr_des_chave_ag      varchar2(8);
    vr_des_chave_det     varchar2(54);

    -- Variavel para armazenar as informacos em XML
    vr_des_xml       clob;
    vr_des_xml_tot   clob;

    -- Variavel para criacao do relatorio
    vr_nom_direto    varchar2(100);
    vr_nom_arquivo   varchar2(100);
    vr_rel_dsobserv varchar2(500) := NULL;

    -- Variavel de informacoes exibidas no relatorio
    vr_nrdolote     craplcm.nrdolote%type := 0;
    vr_cdbccxlt     craplcm.cdbccxlt%type  := 0;
    vr_rowidlcm     rowid := null;

    vr_dsparame     crapsol.dsparame%type;

    -- Procedimento para analisar a interferencia do lancamento no saldo da conta
    PROCEDURE pc_ver_saldo ( pr_cdcooper craptab.cdcooper%TYPE,
                             pr_dtmvtopr CRAPDAT.Dtmvtopr%type,
                             pr_nrdconta crapsld.nrdconta%type,
                             pr_vllimcre crapass.vllimcre%type,
                             pr_vllanaut craplau.vllanaut%type,
                             pr_txcpmfcc number,
                             pr_rowidlcm rowid,
                             pr_dsobserv in out varchar2,
                             pr_cdcritic OUT crapcri.cdcritic%TYPE,
                             pr_dscritic OUT VARCHAR2 ) IS

      -- Buscar Lancamentos em depositos a vista da conta
      Cursor cr_craplcm is
        SELECT rowid,
               cdhistor,
               vllanmto
          FROM craplcm
         WHERE craplcm.cdcooper = pr_cdcooper
           AND craplcm.nrdconta = pr_nrdconta
           AND craplcm.dtmvtolt = pr_dtmvtopr
           AND craplcm.cdhistor <> 289
         ORDER BY cdcooper,
                  nrdconta,
                  dtmvtolt,
                  cdhistor,
                  nrdocmto,
                  progress_recid;

      rw_craphis craphis%rowtype;

      vr_txdoipmf      NUMBER;
      vr_rel_vlsddisp  NUMBER;
      vr_rel_vlsdbloq  NUMBER;
      vr_rel_vlsdblpr  NUMBER;
      vr_rel_vlsdblfp  NUMBER;
      vr_rel_vlsdchsl  NUMBER;
      vr_vlipmfap      crapsld.vlipmfap%type;

    BEGIN

      /*--Buscar Saldos do associado em depositos a vista*/
      OPEN cr_crapsld(pr_cdcooper => pr_cdcooper,
                      pr_nrdconta => pr_nrdconta
                      );
      FETCH cr_crapsld
        INTO rw_crapsld;
      -- Se nao encontrar
      IF cr_crapsld%NOTFOUND THEN
        -- Fechar o cursor pois havera raise
        CLOSE cr_crapsld;
        -- Montar mensagem de critica
        pr_cdcritic := 10;
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 10);
        RAISE vr_exc_erro;
      ELSE
        CLOSE cr_crapsld;
      END IF;

      vr_rel_vlsddisp  := nvl(rw_crapsld.vlsddisp,0);
      vr_rel_vlsdbloq  := nvl(rw_crapsld.vlsdbloq,0);
      vr_rel_vlsdblpr  := nvl(rw_crapsld.vlsdblpr,0);
      vr_rel_vlsdblfp  := nvl(rw_crapsld.vlsdblfp,0);
      vr_rel_vlsdchsl  := nvl(rw_crapsld.vlsdchsl,0);
      vr_vlipmfap      := nvl(rw_crapsld.vlipmfap,0);

      -- Buscar Lancamentos em depositos a vista da conta
      FOR rw_craplcm IN cr_craplcm LOOP

        -- buscar dados do histico
        IF NOT vr_tab_craphis.EXISTS(rw_craplcm.cdhistor) THEN
          -- Montar mensagem de critica
          pr_cdcritic := 80;
          pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 80);
          --retornar para o programa chamador
          raise vr_exc_erro;
        ELSE
          rw_craphis.inhistor:= vr_tab_craphis(rw_craplcm.cdhistor).inhistor;
          rw_craphis.indoipmf:= vr_tab_craphis(rw_craplcm.cdhistor).indoipmf;
          rw_craphis.indebcre:= vr_tab_craphis(rw_craplcm.cdhistor).indebcre;
          vr_txdoipmf:= pr_txcpmfcc;
        END IF;
        
        /* Desprezar o mesmo lancamento do debito automatico */
        IF pr_rowidlcm IS NOT NULL THEN
          IF pr_rowidlcm = rw_craplcm.rowid THEN
            continue;
          END IF;
        END IF;

        -- Armazenar valor conforme o tipo de historico do lancamento
        IF rw_craphis.inhistor = 1   THEN
          vr_rel_vlsddisp := vr_rel_vlsddisp + rw_craplcm.vllanmto;
        ELSIF rw_craphis.inhistor = 2   THEN
          vr_rel_vlsdchsl := vr_rel_vlsdchsl + rw_craplcm.vllanmto;
        ELSIF rw_craphis.inhistor = 3   THEN
          vr_rel_vlsdbloq := vr_rel_vlsdbloq + rw_craplcm.vllanmto;
        ELSIF rw_craphis.inhistor = 4   THEN
          vr_rel_vlsdblpr := vr_rel_vlsdblpr + rw_craplcm.vllanmto;
        ELSIF rw_craphis.inhistor = 5   THEN
          vr_rel_vlsdblfp := vr_rel_vlsdblfp + rw_craplcm.vllanmto;
        ELSIF rw_craphis.inhistor = 11   THEN
          vr_rel_vlsddisp := vr_rel_vlsddisp - rw_craplcm.vllanmto;
        ELSIF rw_craphis.inhistor = 12   THEN
          vr_rel_vlsdchsl := vr_rel_vlsdchsl - rw_craplcm.vllanmto;
        ELSIF rw_craphis.inhistor = 13   THEN
          vr_rel_vlsdbloq := vr_rel_vlsdbloq - rw_craplcm.vllanmto;
        ELSIF rw_craphis.inhistor = 14   THEN
          vr_rel_vlsdblpr := vr_rel_vlsdblpr - rw_craplcm.vllanmto;
        ELSIF rw_craphis.inhistor = 15   THEN
          vr_rel_vlsdblfp := vr_rel_vlsdblfp - rw_craplcm.vllanmto;
        ELSE
          -- Montar mensagem de critica caso nao for nenhum dos tipos de historicos acima
          pr_cdcritic := 83;
          pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 83);
          --retornar para o programa chamador
          raise vr_exc_erro;
        END IF;

        /*  Calcula CPMF para os lancamentos  */
        IF rw_craphis.indoipmf > 1 THEN
          IF pr_txcpmfcc > 0 THEN
            IF rw_craphis.indebcre = 'D' THEN
              vr_vlipmfap := vr_vlipmfap +
                            (TRUNC(rw_craplcm.vllanmto * pr_txcpmfcc,2));
            ELSIF rw_craphis.indebcre = 'C' THEN
              vr_vlipmfap := vr_vlipmfap -
                            (TRUNC(rw_craplcm.vllanmto * pr_txcpmfcc,2));
            END IF;
          END IF;
        ELSIF rw_craphis.inhistor = 12 THEN
          /*** Magui em substituicao ao cheque salario ***/
          IF rw_craplcm.cdhistor <> 43 THEN
            vr_rel_vlsdchsl := vr_rel_vlsdchsl -
                            (TRUNC(rw_craplcm.vllanmto * pr_txcpmfcc,2));
            vr_rel_vlsddisp := vr_rel_vlsddisp +
                            (TRUNC(rw_craplcm.vllanmto * pr_txcpmfcc,2));
            vr_vlipmfap := vr_vlipmfap +
                            (TRUNC(rw_craplcm.vllanmto * pr_txcpmfcc,2));
          END IF;
        END IF;

      END LOOP;/*  Fim do FOR -- Leitura dos lancamentos do dia  */

      IF (vr_rel_vlsddisp + pr_vllimcre) < 0 THEN
        pr_dsobserv := 'Saldo negativo';
      ELSIF (vr_rel_vlsddisp + pr_vllimcre) - pr_vllanaut < 0  THEN
        pr_dsobserv := 'Esse pagto gera saldo negativo';
      END IF;

    EXCEPTION
      WHEN vr_exc_erro THEN
        -- Se nao foi passado o codigo da critica
        IF pr_cdcritic IS NULL THEN
          -- Utilizaremos codigo zero, pois foi erro nao cadastrado
          pr_cdcritic := 0;
        END IF;
      WHEN OTHERS THEN
        -- Efetuar retorno do erro nao tratado
        pr_cdcritic := 0;
        pr_dscritic := sqlerrm;
    END pc_ver_saldo;

    -- Procedimento para retornar o nome do banco
    FUNCTION pc_busca_banco(pr_cdbccxpg craplau.cdbccxpg%type) return varchar2 is

      CURSOR cr_crapbcl is
       SELECT nmresbcc
          FROM crapbcl
         WHERE cdbccxlt = pr_cdbccxpg;
      rw_crapbcl cr_crapbcl%rowtype;

    BEGIN

      OPEN cr_crapbcl;
      FETCH cr_crapbcl
       INTO rw_crapbcl;
      IF cr_crapbcl%NOTFOUND THEN
        CLOSE cr_crapbcl;
        RETURN GENE0002.fn_mask(pr_cdbccxpg,'999')||'-NAO CAD.';
      ELSE
        CLOSE cr_crapbcl;
        RETURN rw_crapbcl.nmresbcc;
      END IF;
    END pc_busca_banco;

    -- Buscar descricao do historico
    FUNCTION pc_busca_hist (pr_cdhistor craplcm.cdhistor%type
                             ) return varchar2 is

    BEGIN
      IF NOT vr_tab_craphis.EXISTS(pr_cdhistor) THEN
        RETURN GENE0002.fn_mask(pr_cdhistor,'9999')||'-NAO CADASTRADO';
      ELSE
        RETURN GENE0002.fn_mask(pr_cdhistor,'9999')||'-'||vr_tab_craphis(pr_cdhistor).dshistor;
      END IF;    
    END pc_busca_hist;

    --Escrever no arquivo CLOB
    PROCEDURE pc_escreve_xml(pr_des_dados IN CLOB) IS
    BEGIN
      --Escrever no arquivo XML
      vr_des_xml := vr_des_xml||pr_des_dados;
    END;

  BEGIN

    -- Incluir nome do modulo logado
    GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra
                              ,pr_action => null);
    -- Verifica se a cooperativa esta cadastrada
    OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
    FETCH cr_crapcop
     INTO rw_crapcop;
    -- Se nao encontrar
    IF cr_crapcop%NOTFOUND THEN
      -- Fechar o cursor pois havera raise
      CLOSE cr_crapcop;
      -- Montar mensagem de critica
      vr_cdcritic := 651;
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 651);
      RAISE vr_exc_erro;
    ELSE
      -- Apenas fechar o cursor
      CLOSE cr_crapcop;
    END IF;
    -- Leitura do calendario da cooperativa
    OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
    FETCH btch0001.cr_crapdat
     INTO rw_crapdat;
    -- Se nao encontrar
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

    -- Validacoes iniciais do programa
    BTCH0001.pc_valida_iniprg(pr_cdcooper => pr_cdcooper
                             ,pr_flgbatch => 1 --true
                             ,pr_cdprogra => vr_cdprogra
                             ,pr_infimsol => pr_infimsol
                             ,pr_cdcritic => vr_cdcritic);
    -- Se a variavel de erro e <> 0
    IF vr_cdcritic <> 0 THEN
      -- Buscar descricao da critica
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      -- Envio centralizado de log de erro
      RAISE vr_exc_erro;
    END IF;

    vr_dsparame := NULL;

    -- Buscar a data do periodo no parametro
    OPEN  cr_dsparame(vr_cdprogra);
    FETCH cr_dsparame INTO vr_dsparame;
    CLOSE cr_dsparame;

    /*  Verifica se deve rodar ou nao  */
    IF INSTR(upper(vr_dsparame), vr_cdprogra) = 0 THEN
      --se o programa não estiver no parametro, deve finalizar o progrma sem gerar os relatorios
      raise vr_exc_fimprg;
    END IF;

    -- Carregar tabela memoria de Historicos
    FOR rw_craphis IN cr_craphis (pr_cdcooper => pr_cdcooper) LOOP
      vr_tab_craphis(rw_craphis.cdhistor).inhistor:= rw_craphis.inhistor;
      vr_tab_craphis(rw_craphis.cdhistor).indoipmf:= rw_craphis.indoipmf;
      vr_tab_craphis(rw_craphis.cdhistor).indebcre:= rw_craphis.indebcre;
      vr_tab_craphis(rw_craphis.cdhistor).dshistor:= rw_craphis.dshistor;
    END LOOP;
      
    -- Buscar Lancamentos Automaticos
    FOR rw_craplau IN cr_craplau(pr_cdcooper => pr_cdcooper,
                                 pr_dtmvtopr => rw_crapdat.dtmvtopr) LOOP

      -- Buscar descricao da critica para utilizar no relatorio
      IF   rw_craplau.cdcritic > 0   THEN
        vr_rel_dsobserv := gene0001.fn_busca_critica(pr_cdcritic => rw_craplau.cdcritic);
      ELSE
        vr_rel_dsobserv := '';
      END IF;

      /*  Localiza o lote no qual o lancamento foi criado  */
      OPEN cr_craplcm(pr_cdcooper => pr_cdcooper,
                      pr_dtdebito => rw_craplau.dtdebito,
                      pr_cdagenci => rw_craplau.craplau_cdagenci,
                      pr_nrdconta => rw_craplau.nrdconta,
                      pr_nrdocmto => rw_craplau.nrdocmto,
                      pr_vllanaut => rw_craplau.vllanaut
                      );
      FETCH cr_craplcm
       INTO rw_craplcm;
      -- Se nao encontrar
      IF cr_craplcm%NOTFOUND THEN
        vr_nrdolote := 0;
        vr_cdbccxlt := 0;
        vr_rowidlcm := null;
        -- Fechar o cursor pois havera raise
        CLOSE cr_craplcm;
      ELSE
        -- Buscar informacoes do lote para exibir no relatorio
        vr_nrdolote := rw_craplcm.nrdolote;
        vr_cdbccxlt := rw_craplcm.cdbccxlt;
        vr_rowidlcm := rw_craplcm.rowid;

        CLOSE cr_craplcm;
      END IF;

      --Verifica o saldo do associado
      pc_ver_saldo (pr_cdcooper => pr_cdcooper,
                    pr_dtmvtopr => rw_CRAPDAT.Dtmvtopr,
                    pr_nrdconta => rw_craplau.nrdconta,
                    pr_vllimcre => rw_craplau.vllimcre,
                    pr_vllanaut => rw_craplau.vllanaut,
                    pr_txcpmfcc => 0,
                    pr_rowidlcm => vr_rowidlcm,
                    pr_dsobserv => vr_rel_dsobserv,
                    pr_cdcritic => vr_cdcritic,
                    pr_dscritic => vr_dscritic);

      IF vr_dscritic IS NOT NULL THEN
        -- Envio centralizado de log de erro
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                  ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                   || vr_cdprogra || ' --> '
                                                   || 'Erro ao verificar saldo: '||vr_dscritic
                                                   || ' CONTA = '||rw_craplau.nrdconta);
      END IF;
      vr_des_chave_ag := lpad(rw_craplau.crapass_cdagenci,3,0);

      --armazenar o cabecalho
      if rw_craplau.nrseqreg_ag = 1 then -- Simular first-of
        vr_tab_ag(vr_des_chave_ag).cdagenci := rw_craplau.crapass_cdagenci;
        vr_tab_ag(vr_des_chave_ag).dtdebito := rw_CRAPDAT.dtmvtopr;
        vr_tab_ag(vr_des_chave_ag).cdbccxlt := rw_craplau.cdbccxpg;
        vr_tab_ag(vr_des_chave_ag).dtmvtopg := rw_craplau.dtmvtopg;
      end if;

      if rw_craplau.nrseqreg_ag = rw_craplau.qtdreg_ag then -- Simular last-of
        --guardar a ultima data para exibir no total, igual ao progress
        vr_tab_ag(vr_des_chave_ag).dtmvtult := rw_craplau.dtmvtopg;
      end if;

      vr_des_chave_det := lpad(rw_craplau.crapass_cdagenci,3,0)||lpad(rw_craplau.cdbccxpg,5,0)||
                          lpad(rw_craplau.cdhistor,5,0)||lpad(to_char(rw_craplau.dtmvtopg,'RRRRMMDD'),8,0)||
                          lpad(rw_craplau.nrdconta,8,0)||lpad(rw_craplau.nrdocmto,25,0);

      -- Armazenar detalhes
      vr_tab_ag(vr_des_chave_ag).vr_tab_det(vr_des_chave_det).cdagenci := rw_craplau.craplau_cdagenci;
      vr_tab_ag(vr_des_chave_ag).vr_tab_det(vr_des_chave_det).cdhistor := rw_craplau.cdhistor;
      vr_tab_ag(vr_des_chave_ag).vr_tab_det(vr_des_chave_det).nrdconta := rw_craplau.nrdconta;
      vr_tab_ag(vr_des_chave_ag).vr_tab_det(vr_des_chave_det).nrseqlan := rw_craplau.nrseqlan;
      vr_tab_ag(vr_des_chave_ag).vr_tab_det(vr_des_chave_det).vllanaut := rw_craplau.vllanaut;
      vr_tab_ag(vr_des_chave_ag).vr_tab_det(vr_des_chave_det).nrdocmto := rw_craplau.nrdocmto;
      vr_tab_ag(vr_des_chave_ag).vr_tab_det(vr_des_chave_det).cdbccxlt := vr_cdbccxlt;
      vr_tab_ag(vr_des_chave_ag).vr_tab_det(vr_des_chave_det).nrdolote := vr_nrdolote;
      vr_tab_ag(vr_des_chave_ag).vr_tab_det(vr_des_chave_det).dsobserv := nvl(vr_rel_dsobserv,' ');
      vr_tab_ag(vr_des_chave_ag).vr_tab_det(vr_des_chave_det).nmprimtl := rw_craplau.nmprimtl;

      -- Armazenar totais
      vr_des_chave_tdeb := lpad(rw_craplau.crapass_cdagenci,3,0)||lpad(rw_craplau.cdhistor,5,0);

      vr_tab_ag(vr_des_chave_ag).vr_tab_tdeb(vr_des_chave_tdeb).cdagenci := rw_craplau.crapass_cdagenci;
      vr_tab_ag(vr_des_chave_ag).vr_tab_tdeb(vr_des_chave_tdeb).cdhistor := rw_craplau.cdhistor;
      vr_tab_ag(vr_des_chave_ag).vr_tab_tdeb(vr_des_chave_tdeb).qtdebito := nvl(vr_tab_ag(vr_des_chave_ag).vr_tab_tdeb(vr_des_chave_tdeb).qtdebito,0)+1;
      vr_tab_ag(vr_des_chave_ag).vr_tab_tdeb(vr_des_chave_tdeb).vldebito := nvl(vr_tab_ag(vr_des_chave_ag).vr_tab_tdeb(vr_des_chave_tdeb).vldebito,0)+rw_craplau.vllanaut;

      -- Armazenar para o total geral
      vr_tab_tot_ger(lpad(rw_craplau.cdhistor,5,0)).cdhistor := rw_craplau.cdhistor;
      vr_tab_tot_ger(lpad(rw_craplau.cdhistor,5,0)).qtdebito := nvl(vr_tab_tot_ger(lpad(rw_craplau.cdhistor,5,0)).qtdebito,0)+1;
      vr_tab_tot_ger(lpad(rw_craplau.cdhistor,5,0)).vldebito := nvl(vr_tab_tot_ger(lpad(rw_craplau.cdhistor,5,0)).vldebito,0)+rw_craplau.vllanaut;

      -- Armazenar soma do total geral
      vr_tab_tot_ger('99999').cdhistor := vr_tab_ag(vr_des_chave_ag).cdbccxlt;
      vr_tab_tot_ger('99999').qtdebito := nvl(vr_tab_tot_ger('99999').qtdebito,0)+1;
      vr_tab_tot_ger('99999').vldebito := nvl(vr_tab_tot_ger('99999').vldebito,0)++rw_craplau.vllanaut;

    END LOOP;

    -- Busca do diretorio base da cooperativa
    vr_nom_direto := gene0001.fn_diretorio(pr_tpdireto => 'C' -- /usr/coop
                                          ,pr_cdcooper => pr_cdcooper
                                          ,pr_nmsubdir => '/rl'); --> Utilizaremos o rl

    --Buscar agencias
    if vr_tab_ag.count > 0 then
      vr_des_chave_ag := vr_tab_ag.FIRST;
      LOOP

        -- fechar a tag agencia
        if nvl(vr_des_chave_ag,'0') <> nvl(vr_tab_ag.FIRST,'0') then
          pc_escreve_xml('</agencia>');
           --guardar para exibir todos
          vr_des_xml_tot := vr_des_xml_tot||vr_des_xml;

          vr_des_xml := '<?xml version="1.0" encoding="utf-8"?><crrl102>'||vr_des_xml||'</crrl102>';
                                  
          -- Solicitar impressao de relatorio por agencia
          gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper         --> Cooperativa conectada
                                     ,pr_cdprogra  => vr_cdprogra         --> Programa chamador
                                     ,pr_dtmvtolt  => rw_crapdat.dtmvtolt --> Data do movimento atual
                                     ,pr_dsxml     => vr_des_xml          --> Arquivo XML de dados
                                     ,pr_dsxmlnode => '/crrl102'          --> No base do XML para leitura dos dados
                                     ,pr_dsjasper  => 'crrl102.jasper'    --> Arquivo de layout do iReport
                                     ,pr_dsparams  => null                --> Enviar como parametro apenas a agencia
                                     ,pr_dsarqsaid => vr_nom_direto||'/'||vr_nom_arquivo||'.lst' --> Arquivo final com codigo da agencia
                                     ,pr_qtcoluna  => 234                 --> 234 colunas
                                     ,pr_flg_impri => 'S'                 --> Chamar a impress?o (Imprim.p)
                                     ,pr_flg_gerar => 'S'
                                     ,pr_nmformul  => '234dh'             --> Nome do formulario para impress?o
                                     ,pr_nrcopias  => 1                   --> Numero de copias
                                     ,pr_des_erro  => vr_dscritic);       --> Saida com erro

          IF vr_dscritic IS NOT NULL THEN
            -- Gerar excecao
            raise vr_exc_erro;
          END IF;

          --limpar variavel
          vr_des_xml := '';
        end if;

        -- Sair quando a chave atual for null (chegou no final)
        exit when vr_des_chave_ag is null;

        --Determinar o nome do arquivo que sera gerado
        vr_nom_arquivo := 'crrl102_'||lpad(vr_tab_ag(vr_des_chave_ag).cdagenci,3,'0');

        -- Inicializar o CLOB
        dbms_lob.createtemporary(vr_des_xml, true);
        dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);

        pc_escreve_xml('<agencia '||
                        ' ag_cdagenci="'||vr_tab_ag(vr_des_chave_ag).cdagenci||'"'||
                        ' dtdebito="'||to_char(vr_tab_ag(vr_des_chave_ag).dtdebito,'DD/MM/RRRR') ||'"'||
                        ' nmresbcc="'||pc_busca_banco(vr_tab_ag(vr_des_chave_ag).cdbccxlt) ||'"'||
                        ' dtmvtopg="'||to_char(vr_tab_ag(vr_des_chave_ag).dtmvtopg,'DD/MM/RRRR') ||'" >
                        ');

        -- Montar xml com os detalhes
        IF vr_tab_ag(vr_des_chave_ag).vr_tab_det.count > 0 then
          vr_des_chave_det := vr_tab_ag(vr_des_chave_ag).vr_tab_det.FIRST;
          pc_escreve_xml('<detalhes>');
          LOOP
            -- Sair quando a chave atual for null (chegou no final)
            exit when vr_des_chave_det is null;

            pc_escreve_xml('<fatura>
                                <fat_cdagenci>'||vr_tab_ag(vr_des_chave_ag).vr_tab_det(vr_des_chave_det).cdagenci||'</fat_cdagenci>
                                <cdhistor>'||pc_busca_hist(vr_tab_ag(vr_des_chave_ag).vr_tab_det(vr_des_chave_det).cdhistor)||'</cdhistor>
                                <nrdconta>'||gene0002.fn_mask(vr_tab_ag(vr_des_chave_ag).vr_tab_det(vr_des_chave_det).nrdconta, 'z.zzz.zzz.z')||'</nrdconta>
                                <nmprimtl>'||vr_tab_ag(vr_des_chave_ag).vr_tab_det(vr_des_chave_det).nmprimtl||'</nmprimtl>
                                <nrseqlan>'||vr_tab_ag(vr_des_chave_ag).vr_tab_det(vr_des_chave_det).nrseqlan||'</nrseqlan>
                                <vllanaut>'||vr_tab_ag(vr_des_chave_ag).vr_tab_det(vr_des_chave_det).vllanaut||'</vllanaut>
                                <nrdocmto>'||vr_tab_ag(vr_des_chave_ag).vr_tab_det(vr_des_chave_det).nrdocmto||'</nrdocmto>
                                <cdbccxlt>'||vr_tab_ag(vr_des_chave_ag).vr_tab_det(vr_des_chave_det).cdbccxlt||'</cdbccxlt>
                                <nrdolote>'||gene0002.fn_mask(vr_tab_ag(vr_des_chave_ag).vr_tab_det(vr_des_chave_det).nrdolote,'zzz.zz9')||'</nrdolote>
                                <dsobserv>'||vr_tab_ag(vr_des_chave_ag).vr_tab_det(vr_des_chave_det).dsobserv||'</dsobserv>
                            </fatura>');


            vr_des_chave_det := vr_tab_ag(vr_des_chave_ag).vr_tab_det.NEXT(vr_des_chave_det);
          END LOOP;--FIM DETALHES
          pc_escreve_xml('</detalhes>');
        END IF;

        -- Montar xml com os totais por agencia
        IF vr_tab_ag(vr_des_chave_ag).vr_tab_tdeb.count > 0 then
          vr_des_chave_tdeb := vr_tab_ag(vr_des_chave_ag).vr_tab_tdeb.FIRST;
          pc_escreve_xml('<total dtdebito="'||to_char(vr_tab_ag(vr_des_chave_ag).dtmvtult,'DD/MM/RRRR') ||'">');

          LOOP
            -- Sair quando a chave atual for null (chegou no final)
            exit when vr_des_chave_tdeb is null;

            pc_escreve_xml('<total_his>
                                <tot_cdagenci>'||vr_tab_ag(vr_des_chave_ag).vr_tab_tdeb(vr_des_chave_tdeb).cdagenci||'</tot_cdagenci>
                                <cdhistor>'||substr(pc_busca_hist(vr_tab_ag(vr_des_chave_ag).vr_tab_tdeb(vr_des_chave_tdeb).cdhistor),1,13)||'</cdhistor>                                
                                <qtdebito>'||vr_tab_ag(vr_des_chave_ag).vr_tab_tdeb(vr_des_chave_tdeb).qtdebito||'</qtdebito>
                                <vldebito>'||vr_tab_ag(vr_des_chave_ag).vr_tab_tdeb(vr_des_chave_tdeb).vldebito||'</vldebito>
                            </total_his>');

            vr_des_chave_tdeb := vr_tab_ag(vr_des_chave_ag).vr_tab_tdeb.NEXT(vr_des_chave_tdeb);
          END LOOP;--FIM DETALHES
          pc_escreve_xml('</total>');

        END IF;

        vr_des_chave_ag := vr_tab_ag.NEXT(vr_des_chave_ag);
      END LOOP;

    END IF;

    -- Montar xml com os totais gerais
    IF vr_tab_tot_ger.count > 0 then
      vr_des_chave_tdeb := vr_tab_tot_ger.FIRST;
      vr_des_xml_tot := vr_des_xml_tot||('<total_geral>');

      LOOP
        -- Sair quando a chave atual for null (chegou no final)
        exit when vr_des_chave_tdeb is null;

        vr_des_xml_tot := vr_des_xml_tot||
                        '<total_his>
                            <tot_cdagenci>'||to_char(vr_tab_tot_ger(vr_des_chave_tdeb).cdagenci)||'</tot_cdagenci>';

        -- caso for a chave 99999 é a soma dos totais, descricao deve ser o nome do banco
        IF vr_des_chave_tdeb = '99999' then
          vr_des_xml_tot := vr_des_xml_tot||
                            '<cdhistor>'||pc_busca_banco(vr_tab_tot_ger(vr_des_chave_tdeb).cdhistor)||'</cdhistor>';
        ELSE
          -- senao é a descricao do historico
          vr_des_xml_tot := vr_des_xml_tot||
                            '<cdhistor>'||substr(pc_busca_hist(vr_tab_tot_ger(vr_des_chave_tdeb).cdhistor),1,13)||'</cdhistor>';
        END IF;

        vr_des_xml_tot := vr_des_xml_tot||
                            ('<qtdebito>'||vr_tab_tot_ger(vr_des_chave_tdeb).qtdebito||'</qtdebito>
                            <vldebito>'||vr_tab_tot_ger(vr_des_chave_tdeb).vldebito||'</vldebito>
                        </total_his>');

        vr_des_chave_tdeb := vr_tab_tot_ger.NEXT(vr_des_chave_tdeb);
      END LOOP;--FIM DETALHES

      vr_des_xml_tot := vr_des_xml_tot||('</total_geral>');
      vr_des_xml_tot := '<?xml version="1.0" encoding="utf-8"?><crrl102>'||vr_des_xml_tot||'</crrl102>';

      -- Solicitar impressao de todas as agencias
      gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper         --> Cooperativa conectada
                                 ,pr_cdprogra  => vr_cdprogra         --> Programa chamador
                                 ,pr_dtmvtolt  => rw_crapdat.dtmvtolt --> Data do movimento atual
                                 ,pr_dsxml     => vr_des_xml_tot      --> Arquivo XML de dados
                                 ,pr_dsxmlnode => '/crrl102'          --> No base do XML para leitura dos dados
                                 ,pr_dsjasper  => 'crrl102.jasper'    --> Arquivo de layout do iReport
                                 ,pr_dsparams  => 'PR_CDAGENCI##999'  --> Enviar como parametro apenas a agencia
                                 ,pr_dsarqsaid => vr_nom_direto||'/crrl102_'
                                                  ||gene0001.fn_param_sistema('CRED',pr_cdcooper,'SUFIXO_RELATO_TOTAL')||'.lst' --> Arquivo final com codigo da agencia
                                 ,pr_qtcoluna  => 234                 --> 234 colunas
                                 ,pr_flg_gerar => 'S'
                                 ,pr_flg_impri => 'S'                 --> Chamar a impress?o (Imprim.p)
                                 ,pr_nmformul  => '234dh'             --> Nome do formulario para impress?o
                                 ,pr_nrcopias  => 1                   --> Numero de copias
                                 ,pr_des_erro  => vr_dscritic);       --> Saida com erro

      IF vr_dscritic IS NOT NULL THEN
        -- Gerar excecao
        raise vr_exc_erro;
      END IF;

    ELSE
      -- Se nao existir dados gerar impressao em branco
      vr_des_xml_tot := '<?xml version="1.0" encoding="utf-8"?><crrl102></crrl102>';

      -- Solicitar impressao de todas as agencias
      gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper         --> Cooperativa conectada
                                 ,pr_cdprogra  => vr_cdprogra         --> Programa chamador
                                 ,pr_dtmvtolt  => rw_crapdat.dtmvtolt --> Data do movimento atual
                                 ,pr_dsxml     => vr_des_xml_tot      --> Arquivo XML de dados
                                 ,pr_dsxmlnode => '/crrl102'          --> No base do XML para leitura dos dados
                                 ,pr_dsjasper  => 'crrl102.jasper'    --> Arquivo de layout do iReport
                                 ,pr_dsparams  => 'PR_SMDADOS##S'     --> Enviar como parametro apenas a agencia
                                 ,pr_dsarqsaid => vr_nom_direto||'/crrl102_'
                                                  ||gene0001.fn_param_sistema('CRED',pr_cdcooper,'SUFIXO_RELATO_TOTAL')||'.lst' --> Arquivo final com codigo da agencia
                                 ,pr_qtcoluna  => 234                 --> 234 colunas
                                 ,pr_flg_impri => 'S'                 --> Chamar a impress?o (Imprim.p)
                                 ,pr_flg_gerar => 'S'
                                 ,pr_nmformul  => '234dh'             --> Nome do formulario para impress?o
                                 ,pr_nrcopias  => 1                   --> Numero de copias
                                 ,pr_des_erro  => vr_dscritic);       --> Saida com erro

      IF vr_dscritic IS NOT NULL THEN
        -- Gerar excecao
        raise vr_exc_erro;
      END IF;
    END IF; -- Fim vr_tab_tot_ger.count

    -- Processo OK, devemos chamar a fimprg
    btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                             ,pr_cdprogra => vr_cdprogra
                             ,pr_infimsol => pr_infimsol
                             ,pr_stprogra => pr_stprogra);

    COMMIT;
  EXCEPTION
    WHEN vr_exc_fimprg THEN
        -- Se foi retornado apenas código
        IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
          -- Buscar a descrição
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;
        -- Se foi gerada critica para envio ao log
        IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
          -- Envio centralizado de log de erro
          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                    ,pr_ind_tipo_log => 2 -- Erro tratato
                                    ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                     || vr_cdprogra || ' --> '
                                                     || vr_dscritic );
        END IF;
        -- Chamamos a fimprg para encerrarmos o processo sem parar a cadeia
        btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                                 ,pr_cdprogra => vr_cdprogra
                                 ,pr_infimsol => pr_infimsol
                                 ,pr_stprogra => pr_stprogra);
        -- Efetuar commit pois gravaremos o que foi processo até então
        COMMIT;
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
      -- Efetuar retorno do erro nao tratado
      pr_cdcritic := 0;
      pr_dscritic := sqlerrm;

      -- Efetuar rollback
      ROLLBACK;

  END;
END;
/
