CREATE OR REPLACE PROCEDURE CECRED.PC_CRPS686(pr_cdcooper IN crapcop.cdcooper%TYPE  --> Código Cooperativa
                                             ,pr_flgresta IN PLS_INTEGER            --> Flag padrão para utilização de restart
                                             ,pr_stprogra OUT PLS_INTEGER           --> Saída de termino da execução
                                             ,pr_infimsol OUT PLS_INTEGER           --> Saída de termino da solicitação
                                             ,pr_cdcritic OUT crapcri.cdcritic%TYPE --> Código da Critica
                                             ,pr_dscritic OUT VARCHAR2) IS          --> Descricao da Critica
BEGIN

  /* ....................................................................................
  
   Programa: pc_crps686                          Antigo: ------
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Jean Michel
   Data    : Setembro/2014                       Ultima atualizacao: 11/07/2018
  
   Dados referentes ao programa:
  
   Frequencia: Diario.
   Objetivo  : Quando a aplicação atingir sua data de vencimento, o sistema deve
               creditar o valor de resgate automaticamente na conta-corrente do cooperado.
  
  
   Alteracoes: 11/02/2015 - Ajustes na leitura de aplicacao a vencer (Jean Michel).

               07/12/2017 - Checar a nova forma de bloqueio e aproveitar o processo que ja
                            existe para resgate de conta investimento para reaplicacao.
                            (Jaison/Marcos Martini - PRJ404)

               11/07/2018 - PJ450 Regulatório de Credito - Substituido o Insert na tabela craplcm 
                            pela chamada da rotina lanc0001.pc_gerar_lancamento_conta. (Josiane Stiehler - AMcom)  

               15/07/2018 - Desconsiderar Aplicações Programadas
                            Proj. 411.2 - CIS Corporate

  .................................................................................... */

  DECLARE
  
    -- Definicao do tipo de registro de listagem de aplicacoes
    TYPE typ_reg_aplicacoes IS RECORD(
      cdagenci crapage.cdagenci%TYPE -- Codigo do PA
      ,dsagenci VARCHAR2(40) -- Nome Agencia
      ,nrdconta VARCHAR2(40) -- Conta/dv: 
      ,nmprimtl crapass.nmprimtl%TYPE -- Nome
      ,nraplica VARCHAR2(40) -- Numero da Aplicacao
      ,qtdiaapl craprac.qtdiaapl%TYPE -- Qtd de dias de Aplicacao
      ,vllanmto craplac.vllanmto%TYPE -- Valor de Lancamento
      ,nrramfon VARCHAR2(60) -- Numeros de Telefone
      ,dtvencto craprac.dtvencto%TYPE -- data de Vencimento
      ,dscritic crapcri.dscritic%TYPE); -- Descricao de critica
  
    -- Definicao de registro de aplicacoes
    TYPE typ_aplicacoes IS TABLE OF typ_reg_aplicacoes INDEX BY VARCHAR2(21);
  
    -- Selecionar os dados da Cooperativa
    CURSOR cr_crapcop(pr_cdcooper IN crapcop.cdcooper%TYPE) IS
      SELECT cop.cdcooper,
             cop.nmrescop,
             cop.nrtelura,
             cop.cdbcoctl,
             cop.cdagectl,
             cop.dsdircop,
             cop.nrctactl
        FROM crapcop cop
       WHERE cop.cdcooper = pr_cdcooper;
    rw_crapcop cr_crapcop%ROWTYPE;
  
    -- Selecionar os dados da Cooperativa
    CURSOR cr_crapass(pr_cdcooper IN crapcop.cdcooper%TYPE,
                      pr_nrdconta IN crapass.nrdconta%TYPE) IS
      SELECT ass.cdagenci || ' - ' || age.nmresage AS nmagenci,
             ass.cdagenci,
             ass.nrdconta,
             ass.nmprimtl,
             ass.inpessoa
        FROM crapass ass, crapage age
       WHERE ass.cdcooper = age.cdcooper
         AND ass.cdagenci = age.cdagenci
         AND ass.cdcooper = pr_cdcooper
         AND ass.nrdconta = pr_nrdconta;
    rw_crapass cr_crapass%ROWTYPE;
  
    -- Seleciona registros de aplicacoes
    CURSOR cr_craprac(pr_cdcooper IN craprac.cdcooper%TYPE,
                      pr_idsaqtot IN craprac.idsaqtot%TYPE,
                      pr_dtmvtopr IN craprac.dtvencto%TYPE) IS
    
      SELECT rac.cdcooper,
             rac.nrdconta,
             rac.nraplica,
             rac.dtmvtolt,
             rac.idblqrgt,
             rac.txaplica,
             rac.qtdiacar,
             rac.vlbasapl,
             rac.vlsldatl,
             rac.dtatlsld,
             rac.qtdiaapl,
             rac.qtdiaprz,
             rac.rowid,
             cpc.cdprodut,
             cpc.idtippro,
             cpc.cdhsprap,
             cpc.cdhsrvap,
             cpc.cdhsrdap,
             cpc.cdhsirap,
             cpc.cdhsvtap,
             cpc.cdhsvrcc,
             cpc.idtxfixa,
             cpc.cddindex
        FROM craprac rac, crapcpc cpc
       WHERE rac.cdcooper = pr_cdcooper
         AND rac.cdprodut = cpc.cdprodut
         AND rac.idsaqtot = pr_idsaqtot -- 0 - Ativa / 1 - Encerrada
         AND cpc.indplano = 0           -- Apenas não programadas
         AND rac.dtvencto <= pr_dtmvtopr;
  
    rw_craprac cr_craprac%ROWTYPE;
  
    -- Seleciona registros de lancamentos de aplicacao
    CURSOR cr_craplac(pr_cdcooper IN craplac.cdcooper%TYPE,
                      pr_nrdconta IN craplac.nrdconta%TYPE,
                      pr_nraplica IN craplac.nraplica%TYPE,
                      pr_dtmvtolt IN craplac.dtmvtolt%TYPE) IS
      SELECT lac.vllanmto,
             lac.cdcooper,
             lac.nrdconta,
             lac.nraplica,
             lac.dtmvtolt
        FROM craplac lac, craprac rac, crapcpc cpc
       WHERE lac.cdcooper = pr_cdcooper
         AND lac.nrdconta = pr_nrdconta
         AND lac.nraplica = pr_nraplica
         AND lac.dtmvtolt = pr_dtmvtolt
         AND rac.cdcooper = lac.cdcooper
         AND rac.nrdconta = lac.nrdconta
         AND rac.nraplica = lac.nraplica
         AND cpc.cdprodut = rac.cdprodut
         AND cpc.indplano = 0; -- Apenas não programadas
  
    rw_craplac cr_craplac%ROWTYPE;
  
    -- Seleciona registros de lotes
    CURSOR cr_craplot(pr_cdcooper IN craplot.cdcooper%TYPE,
                      pr_dtmvtolt IN craplot.dtmvtolt%TYPE,
                      pr_cdagenci IN craplot.cdagenci%TYPE,
                      pr_cdbccxlt IN craplot.cdbccxlt%TYPE,
                      pr_nrdolote IN craplot.nrdolote%TYPE) IS
    
      SELECT lot.cdcooper,
             lot.dtmvtolt,
             lot.cdagenci,
             lot.cdbccxlt,
             lot.nrdolote,
             lot.tplotmov,
             lot.nrseqdig,
             lot.qtinfoln,
             lot.qtcompln,
             lot.vlinfodb,
             lot.vlcompdb,
             lot.vlinfocr,
             lot.vlcompcr,
             lot.rowid
        FROM craplot lot
       WHERE lot.cdcooper = pr_cdcooper
         AND lot.dtmvtolt = pr_dtmvtolt
         AND lot.cdagenci = pr_cdagenci
         AND lot.cdbccxlt = pr_cdbccxlt
         AND lot.nrdolote = pr_nrdolote;
  
    rw_craplot cr_craplot%ROWTYPE;
    rw_craplot_II cr_craplot%ROWTYPE;
  
    -- Selecionar lancamento de credito
    CURSOR cr_craplci(pr_cdcooper IN craplci.cdcooper%TYPE --> Código da Cooperativa
                     ,pr_dtmvtolt IN craplci.dtmvtolt%TYPE --> Data de movimento
                     ,pr_cdagenci IN craplci.cdagenci%TYPE --> Codigo da agencia     
                     ,pr_cdbccxlt IN craplci.cdbccxlt%TYPE --> Codigo do caixa
                     ,pr_nrdolote IN craplci.nrdolote%TYPE --> Numero do lote
                     ,pr_nrdconta IN craplci.nrdconta%TYPE --> Numero da conta
                     ,pr_nrdocmto IN craplci.nrdocmto%TYPE) IS --> Numero do documento
    
      SELECT lci.cdcooper,
             lci.dtmvtolt,
             lci.cdagenci,
             lci.cdbccxlt,
             lci.nrdolote,
             lci.nrdconta,
             lci.nrdocmto
        FROM craplci lci
       WHERE lci.cdcooper = pr_cdcooper
         AND lci.dtmvtolt = pr_dtmvtolt
         AND lci.cdagenci = pr_cdagenci
         AND lci.cdbccxlt = pr_cdbccxlt
         AND lci.nrdolote = pr_nrdolote
         AND lci.nrdconta = pr_nrdconta
         AND lci.nrdocmto = pr_nrdocmto;
  
    rw_craplci cr_craplci%ROWTYPE;
  
    -- Selecionar telefone
    CURSOR cr_craptfc(pr_cdcooper craptfc.cdcooper%TYPE --> Codigo da cooperativa
                     ,pr_nrdconta craptfc.cdcooper%TYPE --> Numero da conta
                     ,pr_idseqttl craptfc.cdcooper%TYPE --> Sequencia do titular
                     ,pr_tptelefo craptfc.cdcooper%TYPE) IS --> Sequencia do telefone
    
      SELECT tfc.nrdddtfc, tfc.nrtelefo
        FROM craptfc tfc
       WHERE tfc.cdcooper = pr_cdcooper
         AND tfc.nrdconta = pr_nrdconta
         AND tfc.idseqttl = pr_idseqttl
         AND tfc.tptelefo = pr_tptelefo;
  
    rw_craptfc cr_craptfc%ROWTYPE;
  
    -- Selecionar aplicacoes a vencer
    CURSOR cr_crapcpc(pr_cdcooper craprac.cdcooper%TYPE,
                      pr_dtvenini craprac.dtvencto%TYPE,
                      pr_dtvenfin craprac.dtvencto%TYPE) IS
    
      SELECT cpc.cdprodut,
             cpc.idtippro,
             cpc.idtxfixa,
             cpc.cddindex,
             rac.nrdconta,
             rac.nraplica,
             rac.dtmvtolt,
             rac.dtvencto,
             rac.cdcooper,
             rac.txaplica,
             rac.qtdiacar,
             rac.qtdiaapl
        FROM crapcpc cpc, craprac rac
       WHERE rac.cdcooper = pr_cdcooper
         AND rac.cdprodut = cpc.cdprodut
         AND rac.idsaqtot = 0
         AND cpc.indplano = 0    -- Apenas aplicações não programadas
         AND rac.dtvencto > pr_dtvenini
         AND rac.dtvencto <= pr_dtvenfin;
  
    rw_crapcpc cr_crapcpc%ROWTYPE;
  
    --Registro do tipo calendario
    rw_crapdat btch0001.cr_crapdat%ROWTYPE;
  
    -- Variaveis de excecao
    vr_exc_saida  EXCEPTION;
    vr_exc_fimprg EXCEPTION;
  
    --Variaveis Locais
    vr_des_erro VARCHAR2(3);
    vr_cdcritic crapcri.cdcritic%TYPE := 0;
    vr_dscritic crapcri.dscritic%TYPE := '';
    vr_tab_erro GENE0001.typ_tab_erro;
  
    vr_cdprogra VARCHAR2(10);
    vr_dsarquiv VARCHAR2(200) := '/rl/crrl679.lst';
  
    vr_dscchave VARCHAR2(21) := ''; -- Chave PL TABLE
    vr_tptelefo VARCHAR2(15) := '';
    vr_nrramfon VARCHAR2(100) := '';
    vr_contatel INTEGER := 1;
    vr_nraplica craprac.nraplica%TYPE;
    vr_dtvencto DATE;

    vr_controle BOOLEAN := FALSE;

    -- Variaveis para consulta de aplicacoes a vencer
    vr_dtvenfin DATE;
  
    -- Variaveis de retorno de bloqueio judicial
    vr_vlbloque NUMBER(20,8) := 0; -- Valor bloqueado
    vr_vlresblq NUMBER(20,8) := 0; -- Valor que falta bloquear
  
    -- Variaveis de posicao de saldo
    vr_idgravir INTEGER := 0; -- Imunidade do cooperado
    vr_idtipbas INTEGER := 0; -- Tipo de base de calculo (1-Parcial / 2-Total)       
    vr_vlbascal NUMBER(20,8) := 0; -- Valor de base de calculo
    vr_vlsldtot NUMBER(20,8) := 0; -- Valor de saldo total
    vr_vlsldrgt NUMBER(20,8) := 0; -- Valor de saldo de resgate
    vr_vlultren NUMBER(20,8) := 0; -- Valor de ultimo rendimento
    vr_vlrentot NUMBER(20,8) := 0; -- Valor de rendimento total
    vr_vlrevers NUMBER(20,8) := 0; -- Valor de reversao
    vr_vlrdirrf NUMBER(20,8) := 0; -- Valor de IRRF
    vr_percirrf NUMBER(20,8) := 0; -- Valor percentual de IRRF
    vr_idcalorc NUMBER(20,8) := 0;

    vr_nrdocmto craprac.nraplica%TYPE := 0; -- Numero de documento
  
    -- PL Table com registros de aplicacaoes
    vr_tab_aplicacoes typ_aplicacoes;
    vr_tab_aplicvence typ_aplicacoes;
  
    vr_clobxml CLOB; -- Variavel para XML do relatorio CRRL679
  
    vr_cdagenan crapage.cdagenci%TYPE := 0;
    vr_cdagenci crapage.cdagenci%TYPE := 0;
  
    -- PJ450
    vr_incrineg      INTEGER;
    vr_tab_retorno   LANC0001.typ_reg_retorno;

    -- Subrotinas
  
    -- Subrotina para escrever texto na variável clob do xml
    PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR2) IS
      BEGIN
        -- Escreve dados na variavel vr_clobxml que ira conter os dados do xml
        dbms_lob.writeappend(vr_clobxml, length(pr_des_dados), pr_des_dados);
      END;
    
    PROCEDURE pc_gera_lancamento(pr_tplancto IN VARCHAR2,
                                 pr_cdhistor IN crapcpc.cdhsprap%TYPE,
                                 pr_vllanmto IN craplot.vlcompdb%TYPE) IS
    
      /* .............................................................................
      Programa: pc_gera_lancamento
      Autor   : Jean Michel.
      Data    : 24/09/2014                     Ultima atualizacao:
      
      Dados referentes ao programa:
      
      Objetivo   : Procedure criada p/ gerar lancamento
      
      Parametros : pr_tplancto -- Tipo do lancamento
                   pr_cdhistor -- Codigo do historico
                   pr_vllanmto -- Valor de lancamento
      
      Premissa   :
      
      Alteracoes :
      
      .............................................................................*/
    
    BEGIN
      DECLARE
      
      BEGIN
        
        IF NVL(pr_vllanmto,0) <= 0 THEN
          RETURN;
        END IF;
         
        IF UPPER(pr_tplancto) IN ('REVERSAO', 'IRRF', 'VENCIMENTO') THEN
          -- Atualiza registro de lote
          BEGIN
            UPDATE craplot
               SET craplot.nrseqdig = craplot.nrseqdig + 1,
                   craplot.qtinfoln = craplot.qtinfoln + 1,
                   craplot.qtcompln = craplot.qtcompln + 1,
                   craplot.vlinfodb = nvl(craplot.vlinfodb, 0) +
                                      nvl(pr_vllanmto, 0),
                   craplot.vlcompdb = nvl(craplot.vlcompdb, 0) +
                                      nvl(pr_vllanmto, 0)
             WHERE
               craplot.rowid = rw_craplot_II.rowid
             RETURNING
               cdcooper, dtmvtolt, cdagenci, cdbccxlt, nrdolote, tplotmov, nrseqdig, qtinfoln, qtcompln,
               vlinfodb, vlcompdb, vlinfocr, vlcompcr, ROWID
             INTO rw_craplot_II.cdcooper, rw_craplot_II.dtmvtolt, rw_craplot_II.cdagenci, rw_craplot_II.cdbccxlt,
                  rw_craplot_II.nrdolote, rw_craplot_II.tplotmov, rw_craplot_II.nrseqdig, rw_craplot_II.qtinfoln,
                  rw_craplot_II.qtcompln, rw_craplot_II.vlinfodb, rw_craplot_II.vlcompdb, rw_craplot_II.vlinfocr,
                  rw_craplot_II.vlcompcr, rw_craplot_II.rowid;  

          EXCEPTION
            WHEN OTHERS THEN
              vr_cdcritic := 0;
              vr_dscritic := 'Erro ao atualizar registro de lote. Erro: ' || SQLERRM;
              RAISE vr_exc_saida;
          END;
        ELSIF upper(pr_tplancto) IN ('PROVISAO', 'RENDIMENTO') THEN
          -- Atualiza registro de lote
          BEGIN
            UPDATE craplot
               SET craplot.nrseqdig = craplot.nrseqdig + 1,
                   craplot.qtinfoln = craplot.qtinfoln + 1,
                   craplot.qtcompln = craplot.qtcompln + 1,
                   craplot.vlinfocr = nvl(craplot.vlinfocr, 0) +
                                      nvl(pr_vllanmto, 0),
                   craplot.vlcompcr = nvl(craplot.vlcompcr, 0) +
                                      nvl(pr_vllanmto, 0)
             WHERE
               craplot.rowid = rw_craplot_II.rowid
             RETURNING 
               cdcooper, dtmvtolt, cdagenci, cdbccxlt, nrdolote, tplotmov, nrseqdig, qtinfoln,
               qtcompln, vlinfodb, vlcompdb, vlinfocr, vlcompcr, ROWID
             INTO rw_craplot_II.cdcooper, rw_craplot_II.dtmvtolt, rw_craplot_II.cdagenci, rw_craplot_II.cdbccxlt,
                  rw_craplot_II.nrdolote, rw_craplot_II.tplotmov, rw_craplot_II.nrseqdig, rw_craplot_II.qtinfoln,
                  rw_craplot_II.qtcompln, rw_craplot_II.vlinfodb, rw_craplot_II.vlcompdb, rw_craplot_II.vlinfocr,
                  rw_craplot_II.vlcompcr, rw_craplot_II.rowid;
          EXCEPTION
            WHEN OTHERS THEN
              vr_cdcritic := 0;
              vr_dscritic := 'Erro ao atualizar registro de lote. Erro: ' || SQLERRM;
              RAISE vr_exc_saida;
          END;
        END IF;
      
        -- Insere registro de lancamento de aplicacao
        BEGIN
          INSERT INTO craplac
            (cdcooper,
             dtmvtolt,
             cdagenci,
             cdbccxlt,
             nrdolote,
             nrdconta,
             nraplica,
             nrdocmto,
             nrseqdig,
             vllanmto,
             cdhistor)
          VALUES
            (rw_craprac.cdcooper,
             rw_craplot_II.dtmvtolt,
             rw_craplot_II.cdagenci,
             rw_craplot_II.cdbccxlt,
             rw_craplot_II.nrdolote,
             rw_craprac.nrdconta,
             rw_craprac.nraplica,
             rw_craplot_II.nrseqdig,
             rw_craplot_II.nrseqdig,
             pr_vllanmto,
             pr_cdhistor);
        EXCEPTION
          WHEN OTHERS THEN
            vr_cdcritic := 0;
            vr_dscritic := 'Erro ao inserir registro de lancamento de aplicacao. Conta: ' ||
                           GENE0002.fn_mask_conta(rw_craprac.nrdconta) || ', Aplic.: ' ||
                           rw_craprac.nraplica || '. Erro: ' || SQLERRM;
            RAISE vr_exc_saida;
        END;
      
      END;
    
    END pc_gera_lancamento;
  
  BEGIN
  
    --Atribuir o nome do programa que está executando
    vr_cdprogra := 'CRPS686';
  
    -- Incluir nome do módulo logado
    gene0001.pc_informa_acesso(pr_module => vr_cdprogra, pr_action => NULL);
  
    -- Verifica se a cooperativa esta cadastrada
    OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
    FETCH cr_crapcop
      INTO rw_crapcop;
    -- Se não encontrar
    IF cr_crapcop%NOTFOUND THEN
      -- Fechar o cursor pois haverá raise
      CLOSE cr_crapcop;
      -- Montar mensagem de critica
      vr_cdcritic := 651;
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      RAISE vr_exc_saida;
    ELSE
      -- Apenas fechar o cursor
      CLOSE cr_crapcop;
    END IF;
  
    -- Verifica se a data esta cadastrada
    OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
    FETCH btch0001.cr_crapdat
      INTO rw_crapdat;
    -- Se não encontrar
    IF btch0001.cr_crapdat%NOTFOUND THEN
      -- Fechar o cursor pois haverá raise
      CLOSE btch0001.cr_crapdat;
      -- Montar mensagem de critica
      vr_cdcritic := 1;
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      RAISE vr_exc_saida;
    ELSE
      -- Apenas fechar o cursor
      CLOSE btch0001.cr_crapdat;
    END IF;
  
    -- Validações iniciais do programa
    btch0001.pc_valida_iniprg(pr_cdcooper => pr_cdcooper,
                              pr_flgbatch => 1,
                              pr_cdprogra => vr_cdprogra,
                              pr_infimsol => pr_infimsol,
                              pr_cdcritic => vr_cdcritic);
  
    --Se retornou critica aborta programa
    IF vr_cdcritic <> 0 THEN
      --Descricao do erro recebe mensagam da critica
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      -- Envio centralizado de log de erro
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                 pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_des_log      => to_char(SYSDATE,'hh24:mi:ss') ||
                                                    ' - ' || vr_cdprogra || ' --> ' || vr_dscritic);
      --Sair do programa
      RAISE vr_exc_saida;
    END IF;
  
    -- ARQUIVO P/ GERACAO DO RELATORIO
    vr_dsarquiv := gene0001.fn_diretorio(pr_tpdireto => 'C',
                                         pr_cdcooper => pr_cdcooper) || vr_dsarquiv;
  
    -- Consulta se existe lote
    OPEN cr_craplot(pr_cdcooper => pr_cdcooper,
                    pr_dtmvtolt => rw_crapdat.dtmvtopr,
                    pr_cdagenci => 1,
                    pr_cdbccxlt => 100,
                    pr_nrdolote => 8504);
  
    FETCH cr_craplot
      INTO rw_craplot_II;
  
    -- Verifica se registro existe
    IF cr_craplot%NOTFOUND THEN
    
      -- Fecha cursor
      CLOSE cr_craplot;
    
      -- Insere novo registro de lote
      BEGIN
        INSERT INTO craplot
          (cdcooper,
           dtmvtolt,
           cdagenci,
           cdbccxlt,
           nrdolote,
           tplotmov,
           nrseqdig,
           qtinfoln,
           qtcompln,
           vlinfodb,
           vlcompdb,
           vlinfocr,
           vlcompcr)
        VALUES
          (pr_cdcooper,
           rw_crapdat.dtmvtopr,
           1,
           100,
           8504,
           9,
           0,
           0,
           0,
           0,
           0,
           0,
           0)
        RETURNING cdcooper, dtmvtolt, cdagenci, cdbccxlt, nrdolote, tplotmov, nrseqdig, qtinfoln, qtcompln, vlinfodb, vlcompdb, vlinfocr, vlcompcr, 
        ROWID INTO rw_craplot_II.cdcooper, rw_craplot_II.dtmvtolt, rw_craplot_II.cdagenci, rw_craplot_II.cdbccxlt, rw_craplot_II.nrdolote, rw_craplot_II.tplotmov, 
                   rw_craplot_II.nrseqdig, rw_craplot_II.qtinfoln, rw_craplot_II.qtcompln, rw_craplot_II.vlinfodb, rw_craplot_II.vlcompdb, rw_craplot_II.vlinfocr,
                   rw_craplot_II.vlcompcr, rw_craplot_II.rowid;
      EXCEPTION
        WHEN OTHERS THEN
          vr_cdcritic := 0;
          vr_dscritic := 'Erro ao inserir registro de lote. Erro: ' || SQLERRM;
          RAISE vr_exc_saida;
      END;
    
    ELSE
      -- Fecha cursor
      CLOSE cr_craplot;
    END IF;
  
    -- Leitura de aplicacoes com data vencida
    OPEN cr_craprac(pr_cdcooper => pr_cdcooper,
                    pr_idsaqtot => 0,
                    pr_dtmvtopr => rw_crapdat.dtmvtopr);
    LOOP

      FETCH cr_craprac INTO rw_craprac;

      -- Sai do loop quando chegar ao final dos registros             
      EXIT WHEN cr_craprac%NOTFOUND;
    
      -- Consulta lançamento de cadastro da aplicação
      OPEN cr_craplac(pr_cdcooper => rw_craprac.cdcooper,
                      pr_nrdconta => rw_craprac.nrdconta,
                      pr_nraplica => rw_craprac.nraplica,
                      pr_dtmvtolt => rw_craprac.dtmvtolt);
    
      FETCH cr_craplac
        INTO rw_craplac;
    
      -- Verifica se encontrou registro
      IF cr_craplac%NOTFOUND THEN
        -- Fecha cursor
        CLOSE cr_craplac;
        vr_cdcritic := 90;
        --Descricao do erro recebe mensagam da critica
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) ||
                       ' Conta: ' || TO_CHAR(GENE0002.fn_mask_conta(rw_craprac.nrdconta)) ||
                       ', Aplic.: ' || to_char(rw_craprac.nraplica);

        -- Envio centralizado de log de erro
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                   pr_ind_tipo_log => 2 -- Erro tratato
                                  ,pr_des_log      => to_char(SYSDATE,
                                                              'hh24:mi:ss') ||
                                                      ' - ' || vr_cdprogra ||
                                                      ' --> ' || vr_dscritic);
        CONTINUE;
      ELSE
        -- Fecha cursor
        CLOSE cr_craplac;
      END IF;
    
      -- Consulta de cooperado   
      OPEN cr_crapass(pr_cdcooper => rw_craprac.cdcooper,
                      pr_nrdconta => rw_craprac.nrdconta);
    
      FETCH cr_crapass
        INTO rw_crapass;
    
      -- Verifica se cooperado esta cadastrado
      IF cr_crapass%NOTFOUND THEN
        -- Fecha cursor
        CLOSE cr_crapass;
        -- Gera critica
        vr_cdcritic := 0;
        vr_dscritic := '1.Registro de cooperado/agencia inexistente. Conta: ' ||
                       gene0002.fn_mask_conta(pr_nrdconta => rw_craprac.nrdconta);
        RAISE vr_exc_saida;
      ELSE
        -- Fecha cursor
        CLOSE cr_crapass;
      END IF;
    
      -- Monta chave da pl table
      vr_dscchave := LPAD(rw_crapass.cdagenci, 5, '0') ||
                     LPAD(rw_crapass.nrdconta, 10, '0') ||
                     LPAD(rw_craprac.nraplica, 6, '0');
    
      -- Verifica se aplicacao esta bloqueada para resgate
      IF rw_craprac.idblqrgt > 0 THEN
        vr_tab_aplicacoes(vr_dscchave).nrdconta := rw_craprac.nrdconta;
        vr_tab_aplicacoes(vr_dscchave).nraplica := rw_craprac.nraplica;
        vr_tab_aplicacoes(vr_dscchave).dscritic := 'Aplicacao bloqueada';
      END IF; 
      -- Fim verificacao de aplicacao bloqueada
    
      -- Verifica se existe bloqueio judicial para o cooperado da aplicacao
      gene0005.pc_retorna_valor_blqjud(pr_cdcooper => rw_craprac.cdcooper -- Codigo da cooperativa
                                      ,pr_nrdconta => rw_craprac.nrdconta -- Numero da conta
                                      ,pr_nrcpfcgc => 0                   -- CPF/CGC
                                      ,pr_cdtipmov => 1                   -- Transferencia
                                      ,pr_cdmodali => 2                   -- Aplicacao
                                      ,pr_dtmvtolt => rw_crapdat.dtmvtolt -- Data de movimento atual
                                      ,pr_vlbloque => vr_vlbloque         -- Valor bloqueado
                                      ,pr_vlresblq => vr_vlresblq         -- Valor que falta bloquear
                                      ,pr_dscritic => vr_dscritic);       -- Descricao de critica
    
      -- Verifica se aplicacao esta bloqueada judicialmente
      IF vr_vlbloque > 0 THEN
        vr_tab_aplicacoes(vr_dscchave).nrdconta := rw_craprac.nrdconta;
        vr_tab_aplicacoes(vr_dscchave).nraplica := rw_craprac.nraplica;
        vr_tab_aplicacoes(vr_dscchave).dscritic := 'Bloqueio judicial';
      END IF;
      -- Fim verificacao de aplicacao bloqueada                                
    
      vr_vlbascal := 0; -- Variavel para base de calculo de posicao do saldo
      vr_idgravir := 1; -- Gravar imunidade do cooperado
      vr_idtipbas := 2; -- Tipo de base de calculo (1-Parcial / 2-Total)
    
      -- Verifica tipo de aplicacao
      IF rw_craprac.idtippro = 1 THEN
        
        -- Pré-Fixada
        apli0006.pc_posicao_saldo_aplicacao_pre(pr_cdcooper => rw_craprac.cdcooper,
                                                pr_nrdconta => rw_craprac.nrdconta,
                                                pr_nraplica => rw_craprac.nraplica,
                                                pr_dtiniapl => rw_craprac.dtmvtolt,
                                                pr_txaplica => rw_craprac.txaplica,
                                                pr_idtxfixa => rw_craprac.idtxfixa,
                                                pr_cddindex => rw_craprac.cddindex,
                                                pr_qtdiacar => rw_craprac.qtdiacar,
                                                pr_idgravir => vr_idgravir,
                                                pr_idaplpgm => 0,                   -- Aplicação Programada  (0-Não/1-Sim)
                                                pr_dtinical => rw_craprac.dtmvtolt,
                                                pr_dtfimcal => rw_crapdat.dtmvtopr,
                                                pr_idtipbas => vr_idtipbas,
                                                pr_vlbascal => vr_vlbascal,
                                                pr_vlsldtot => vr_vlsldtot,
                                                pr_vlsldrgt => vr_vlsldrgt,
                                                pr_vlultren => vr_vlultren,
                                                pr_vlrentot => vr_vlrentot,
                                                pr_vlrevers => vr_vlrevers,
                                                pr_vlrdirrf => vr_vlrdirrf,
                                                pr_percirrf => vr_percirrf,
                                                pr_cdcritic => vr_cdcritic,
                                                pr_dscritic => vr_dscritic);
      
        -- Verifica se houve critica no processamento
        IF vr_dscritic IS NOT NULL THEN
          -- Executa excecao
          RAISE vr_exc_saida;
        END IF;
      
      ELSIF rw_craprac.idtippro = 2 THEN
        
        -- Pós-Fixada    
        apli0006.pc_posicao_saldo_aplicacao_pos(pr_cdcooper => rw_craprac.cdcooper,
                                                pr_nrdconta => rw_craprac.nrdconta,
                                                pr_nraplica => rw_craprac.nraplica,
                                                pr_dtiniapl => rw_craprac.dtmvtolt,
                                                pr_txaplica => rw_craprac.txaplica,
                                                pr_idtxfixa => rw_craprac.idtxfixa,
                                                pr_cddindex => rw_craprac.cddindex,
                                                pr_qtdiacar => rw_craprac.qtdiacar,
                                                pr_idgravir => vr_idgravir,
                                                pr_idaplpgm => 0,                   -- Aplicação Programada  (0-Não/1-Sim)
                                                pr_dtinical => rw_craprac.dtmvtolt,
                                                pr_dtfimcal => rw_crapdat.dtmvtopr,
                                                pr_idtipbas => vr_idtipbas,
                                                pr_vlbascal => vr_vlbascal,
                                                pr_vlsldtot => vr_vlsldtot,
                                                pr_vlsldrgt => vr_vlsldrgt,
                                                pr_vlultren => vr_vlultren,
                                                pr_vlrentot => vr_vlrentot,
                                                pr_vlrevers => vr_vlrevers,
                                                pr_vlrdirrf => vr_vlrdirrf,
                                                pr_percirrf => vr_percirrf,
                                                pr_cdcritic => vr_cdcritic,
                                                pr_dscritic => vr_dscritic);

        -- Verifica se houve critica no processamento
        IF vr_dscritic IS NOT NULL THEN
          -- Executa excecao
          RAISE vr_exc_saida;
        END IF;
      
      ELSE
        vr_cdcritic := 0;
        vr_cdcritic := 'Tipo de aplicacao invalida.';
        -- Executa excecao
        RAISE vr_exc_saida;
      END IF; 
      -- Fim verificacao tipo aplicacao
    
      -- Efetua lancamentos de provisão, reversão, resgate, rendimento e IRRF.
      pc_gera_lancamento(pr_tplancto => 'PROVISAO',
                         pr_cdhistor => rw_craprac.cdhsprap,
                         pr_vllanmto => vr_vlultren);
    
      pc_gera_lancamento(pr_tplancto => 'REVERSAO',
                         pr_cdhistor => rw_craprac.cdhsrvap,
                         pr_vllanmto => vr_vlrevers);
    
      pc_gera_lancamento(pr_tplancto => 'VENCIMENTO',
                         pr_cdhistor => rw_craprac.cdhsvtap,
                         pr_vllanmto => vr_vlsldrgt);
    
      pc_gera_lancamento(pr_tplancto => 'RENDIMENTO',
                         pr_cdhistor => rw_craprac.cdhsrdap,
                         pr_vllanmto => vr_vlrentot);
    
      pc_gera_lancamento(pr_tplancto => 'IRRF',
                         pr_cdhistor => rw_craprac.cdhsirap,
                         pr_vllanmto => vr_vlrdirrf);
    
      -- Finaliza aplicacao
      BEGIN
        
        IF TO_CHAR(rw_crapdat.dtmvtopr) <> TO_CHAR(rw_crapdat.dtmvtolt) THEN -- Ultimo dia útil do mes
          vr_idcalorc := 0;
        ELSE
          vr_idcalorc := 1;
        END IF;
 
        -- Atualiza e finaliza registro de aplicacao
        UPDATE craprac
           SET craprac.vlbasant = rw_craprac.vlbasapl, -- Valor de base anterior
               craprac.vlsldant = rw_craprac.vlsldatl, -- Valor de saldo atual
               craprac.dtsldant = rw_craprac.dtatlsld, -- Data da ultima atualizacao de saldo
               craprac.vlbasapl = 0,                   -- Valor base da aplicação
               craprac.idsaqtot = 2,                   -- Aplicação foi encerrada
               craprac.vlsldatl = 0,                   -- Saldo atual da aplicação
               craprac.dtatlsld = rw_crapdat.dtmvtopr, -- Data de atualização de saldo
               craprac.idcalorc = vr_idcalorc 
         WHERE craprac.rowid = rw_craprac.rowid;
      
      EXCEPTION
        WHEN OTHERS THEN
          vr_cdcritic := 0;
          vr_dscritic := 'Erro ao finalizar aplicacao, conta: ' ||
                         rw_craprac.nrdconta || ', Apli.: ' ||
                         rw_craprac.nraplica || '.Erro: ' || SQLERRM;
      END;
    
      -- Obter os valores bloqueados de aplicacao
      APLI0002.pc_ver_val_bloqueio_aplica(pr_cdcooper => pr_cdcooper
                                         ,pr_cdagenci => 1
                                         ,pr_nrdcaixa => 1
                                         ,pr_cdoperad => '1'
                                         ,pr_nmdatela => 'CRPS686'
                                         ,pr_idorigem => 5
                                         ,pr_nrdconta => rw_craprac.nrdconta
                                         ,pr_nraplica => rw_craprac.nraplica
                                         ,pr_idseqttl => 1
                                         ,pr_cdprogra => 'CRPS686'
                                         ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                         ,pr_vlresgat => vr_vlsldrgt
                                         ,pr_flgerlog => 0
                                         ,pr_innivblq => 2 -- Somente observar Bloqueio Garantia
                                         ,pr_des_reto => vr_des_erro 
                                         ,pr_tab_erro => vr_tab_erro); 
      -- Se houve erro
      IF vr_des_erro = 'NOK' THEN

        -- Se retornou na tab de erros
        IF vr_tab_erro.COUNT() > 0 THEN
          -- Guarda o código e descrição do erro
          vr_cdcritic := NVL(vr_tab_erro(vr_tab_erro.FIRST).cdcritic,0);
          vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
        ELSE
          -- Definir o código do erro
          vr_cdcritic := 0;
          vr_dscritic := 'Nao foi possivel cadastrar o resgate --> '
                      || 'Erro na busca de Bloqueios';
        END IF;

        -- Se encontramos a critica 640 significa que há Bloqueio
        IF vr_cdcritic = 640 THEN
          --Monta chave da pl table
          vr_dscchave := LPAD(rw_crapass.cdagenci, 5, '0')
                      || LPAD(rw_crapass.nrdconta, 10, '0')
                      || LPAD(rw_craprac.nraplica, 6, '0');
          vr_tab_aplicacoes(vr_dscchave).nrdconta := rw_craprac.nrdconta; 
          vr_tab_aplicacoes(vr_dscchave).nraplica := rw_craprac.nraplica; 
          vr_tab_aplicacoes(vr_dscchave).dscritic := 'Bloqueio Garantia';
        ELSE
          -- Senão significa que houve erro não tratado
          RAISE vr_exc_saida;
        END IF;

      END IF; -- vr_des_erro = 'NOK'

      -- Verifica se aplicacao esta bloqueada BLQRGT ou Garantia
      IF rw_craprac.idblqrgt > 0 OR vr_cdcritic = 640 THEN
      
        -- Consulta se existe lote
        OPEN cr_craplot(pr_cdcooper => rw_craprac.cdcooper,
                        pr_dtmvtolt => rw_crapdat.dtmvtopr,
                        pr_cdagenci => 1,
                        pr_cdbccxlt => 100,
                        pr_nrdolote => 10113);
      
        FETCH cr_craplot
          INTO rw_craplot;
      
        -- Verifica se registro existe
        IF cr_craplot%NOTFOUND THEN
        
          -- Fecha cursor
          CLOSE cr_craplot;
        
          -- Insere novo registro de lote
          BEGIN
            INSERT INTO craplot
              (cdcooper,
               dtmvtolt,
               cdagenci,
               cdbccxlt,
               nrdolote,
               tplotmov,
               nrseqdig,
               qtinfoln,
               qtcompln,
               vlinfodb,
               vlcompdb,
               vlinfocr,
               vlcompcr)
            VALUES
              (pr_cdcooper,
               rw_crapdat.dtmvtopr,
               1,
               100,
               10113,
               29,
               0,
               0,
               0,
               0,
               0,
               0,
               0)
            RETURNING
              cdcooper, dtmvtolt, cdagenci, cdbccxlt, nrdolote, tplotmov, nrseqdig, qtinfoln,
              qtcompln, vlinfodb, vlcompdb, vlinfocr, vlcompcr, ROWID 
            INTO
              rw_craplot.cdcooper, rw_craplot.dtmvtolt, rw_craplot.cdagenci, rw_craplot.cdbccxlt,
              rw_craplot.nrdolote, rw_craplot.tplotmov, rw_craplot.nrseqdig, rw_craplot.qtinfoln,
              rw_craplot.qtcompln, rw_craplot.vlinfodb, rw_craplot.vlcompdb, rw_craplot.vlinfocr,
              rw_craplot.vlcompcr, rw_craplot.rowid;
          EXCEPTION
            WHEN OTHERS THEN
              vr_cdcritic := 0;
              vr_dscritic := 'Erro ao inserir registro de lote. Erro: ' || SQLERRM;
              RAISE vr_exc_saida;
          END;
        
        ELSE
          -- Fecha cursor
          CLOSE cr_craplot;
        END IF;
      
        BEGIN
        
          UPDATE craplot
             SET craplot.nrseqdig = NVL(craplot.nrseqdig, 0) + 1,
                 craplot.qtinfoln = NVL(craplot.qtinfoln, 0) + 1,
                 craplot.qtcompln = NVL(craplot.qtcompln, 0) + 1,
                 craplot.vlinfocr = NVL(craplot.vlinfocr, 0) +
                                    NVL(vr_vlsldrgt, 0),
                 craplot.vlcompcr = NVL(craplot.vlcompcr, 0) +
                                    NVL(vr_vlsldrgt, 0)
           WHERE
             craplot.rowid = rw_craplot.rowid
           RETURNING
             cdcooper, dtmvtolt, cdagenci, cdbccxlt, nrdolote, tplotmov, nrseqdig, qtinfoln,
             qtcompln, vlinfodb, vlcompdb, vlinfocr, vlcompcr, ROWID
           INTO
             rw_craplot.cdcooper, rw_craplot.dtmvtolt, rw_craplot.cdagenci, rw_craplot.cdbccxlt,
             rw_craplot.nrdolote, rw_craplot.tplotmov, rw_craplot.nrseqdig, rw_craplot.qtinfoln,
             rw_craplot.qtcompln, rw_craplot.vlinfodb, rw_craplot.vlcompdb, rw_craplot.vlinfocr,
             rw_craplot.vlcompcr, rw_craplot.rowid;

        EXCEPTION
          WHEN OTHERS THEN
            vr_cdcritic := 0;
            vr_dscritic := 'Erro ao atualizar registro de lote. Erro:' || SQLERRM;
            RAISE vr_exc_saida;
        END;
      
        -- Numero do documento de lancamento
        vr_nrdocmto := rw_craprac.nraplica;
      
        LOOP
          --Consulta de documentos
          OPEN cr_craplci(pr_cdcooper => rw_craplot.cdcooper --> Código da Cooperativa
                         ,pr_dtmvtolt => rw_craplot.dtmvtolt --> Data de movimento
                         ,pr_cdagenci => rw_craplot.cdagenci --> Codigo da agencia     
                         ,pr_cdbccxlt => rw_craplot.cdbccxlt --> Codigo do caixa
                         ,pr_nrdolote => rw_craplot.nrdolote --> Numero do lote
                         ,pr_nrdconta => rw_craprac.nrdconta --> Numero da conta
                         ,pr_nrdocmto => vr_nrdocmto);       --> Numero do documento
        
          FETCH cr_craplci
            INTO rw_craplci;
        
          IF cr_craplci%NOTFOUND THEN
          
            -- Fecha cursor
            CLOSE cr_craplci;
            -- Sai do loop
            EXIT;
          ELSE
          
            -- Fecha cursor
            CLOSE cr_craplci;
            -- Atualiza numero do documento
            vr_nrdocmto := TO_NUMBER('9' || TO_CHAR(vr_nrdocmto));
            -- Continua o loop ate encontrar um documento valido
            CONTINUE;
          
          END IF;
        
        END LOOP;
      
        -- Lancamento de credito
        BEGIN
        
          INSERT INTO craplci
            (cdcooper,
             dtmvtolt,
             cdagenci,
             cdbccxlt,
             nrdolote,
             nrdconta,
             nrdocmto,
             nrseqdig,
             vllanmto,
             cdhistor)
          VALUES
            (rw_craplot.cdcooper,
             rw_craplot.dtmvtolt,
             rw_craplot.cdagenci,
             rw_craplot.cdbccxlt,
             rw_craplot.nrdolote,
             rw_craprac.nrdconta,
             vr_nrdocmto,
             rw_craplot.nrseqdig,
             vr_vlsldrgt,         -- Valor do resgate
             490);
        
        EXCEPTION
          WHEN OTHERS THEN
            vr_cdcritic := 0;
            vr_dscritic := 'Erro ao inserir registro de lancamento de aplicacao. Erro:' || SQLERRM;
            RAISE vr_exc_saida;
        END;
      
        -- Insere ou atualiza registro de saldo de aplicacao
        BEGIN
          INSERT INTO crapsli
            (cdcooper, nrdconta, dtrefere, vlsddisp)
          VALUES
            (rw_craplot.cdcooper,
             rw_craprac.nrdconta,
             rw_crapdat.dtultdia,
             vr_vlsldrgt);
        EXCEPTION
          WHEN dup_val_on_index THEN
            BEGIN
            
              UPDATE crapsli
                 SET vlsddisp = NVL(vlsddisp, 0) + NVL(vr_vlsldrgt, 0)
               WHERE crapsli.cdcooper = rw_craplot.cdcooper
                 AND crapsli.nrdconta = rw_craprac.nrdconta
                 AND crapsli.dtrefere = rw_crapdat.dtultdia;
            
            EXCEPTION
              WHEN OTHERS THEN
                vr_cdcritic := 0;
                vr_dscritic := 0;
                RAISE vr_exc_saida;
            END;
          WHEN OTHERS THEN
            vr_cdcritic := 0;
            vr_cdcritic := 'Erro ao inserir registro de saldo(CRAPSLI). Erro: ' || SQLERRM;
            RAISE vr_exc_saida;
        END;
      
        -- Bloqueios de Garantia
        IF vr_cdcritic = 640 THEN

          -- Calculo da data de vencimento
          vr_dtvencto := rw_craplot.dtmvtolt + rw_craprac.qtdiaapl;
          vr_dtvencto := GENE0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper
                                                    ,pr_dtmvtolt => vr_dtvencto
                                                    ,pr_tipo => 'P');

          -- Reaplicação com as mesmas caracteristicas da anterior
          APLI0005.pc_cadastra_aplic(pr_cdcooper => pr_cdcooper         -- Código da Cooperativa
                                    ,pr_cdoperad => '1'                 -- Código do Operador
                                    ,pr_nmdatela => 'CRPS686'           -- Nome da Tela
                                    ,pr_idorigem => 1                   -- Identificador de Origem
                                    ,pr_nrdconta => rw_craprac.nrdconta -- Número da Conta
                                    ,pr_idseqttl => 1                   -- Titular da Conta
                                    ,pr_nrdcaixa => 100                 -- Numero de caixa
                                    ,pr_dtmvtolt => rw_craplot.dtmvtolt -- Data de Movimento
                                    ,pr_cdprodut => rw_craprac.cdprodut -- Código do Produto
                                    ,pr_qtdiaapl => rw_craprac.qtdiaapl -- Dias da Aplicação
                                    ,pr_dtvencto => vr_dtvencto         -- Data de Vencimento da Aplicação
                                    ,pr_qtdiacar => rw_craprac.qtdiacar -- Carência da Aplicação
                                    ,pr_qtdiaprz => rw_craprac.qtdiaprz -- Prazo da Aplicação
                                    ,pr_vlaplica => vr_vlsldrgt         -- Valor da Aplicação (Valor informado em tela)
                                    ,pr_iddebcti => 1                   -- Identificador de Débito na Conta Investimento
                                    ,pr_idorirec => 0                   -- Identificador de Origem do Recurso (Renovação)
                                    ,pr_idgerlog => 1                   -- Identificador de Log (Fixo no código, 0 – Não / 1 – Sim)
                                    ,pr_nraplica => vr_nraplica         -- Numero da aplicacao cadastrada
                                    ,pr_cdcritic => vr_cdcritic         -- Codigo da critica de erro
                                    ,pr_dscritic => vr_dscritic);       -- Descrição da critica de erro
          -- Se houve erro
          IF NVL(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
            --Monta mensagem de critica
            vr_cdcritic := vr_cdcritic;
            vr_dscritic := vr_dscritic;
            RAISE vr_exc_saida;
          END IF;

        END IF; -- vr_cdcritic = 640
      
      ELSIF rw_craprac.idblqrgt = 0 THEN
        -- Aplicacao nao bloqueada
      
        -- Verifica registro lote de debito
        OPEN cr_craplot(pr_cdcooper => rw_craprac.cdcooper,
                        pr_dtmvtolt => rw_crapdat.dtmvtopr,
                        pr_cdagenci => 1,
                        pr_cdbccxlt => 100,
                        pr_nrdolote => 10111);
      
        FETCH cr_craplot
          INTO rw_craplot;
      
        -- Verifica se registro existe
        IF cr_craplot%NOTFOUND THEN
        
          -- Fecha cursor
          CLOSE cr_craplot;
        
          -- Insere novo registro de lote
          BEGIN
            INSERT INTO craplot
              (cdcooper,
               dtmvtolt,
               cdagenci,
               cdbccxlt,
               nrdolote,
               tplotmov,
               nrseqdig,
               qtinfoln,
               qtcompln,
               vlinfodb,
               vlcompdb,
               vlinfocr,
               vlcompcr)
            VALUES
              (pr_cdcooper,
               rw_crapdat.dtmvtopr,
               1,
               100,
               10111,
               29,
               0,
               0,
               0,
               0,
               0,
               0,
               0)
            RETURNING
              cdcooper, dtmvtolt, cdagenci, cdbccxlt, nrdolote, tplotmov, nrseqdig, qtinfoln,
              qtcompln, vlinfodb, vlcompdb, vlinfocr, vlcompcr, ROWID
            INTO rw_craplot.cdcooper,
              rw_craplot.dtmvtolt, rw_craplot.cdagenci, rw_craplot.cdbccxlt, rw_craplot.nrdolote,
              rw_craplot.tplotmov, rw_craplot.nrseqdig, rw_craplot.qtinfoln, rw_craplot.qtcompln,
              rw_craplot.vlinfodb, rw_craplot.vlcompdb, rw_craplot.vlinfocr, rw_craplot.vlcompcr,
              rw_craplot.rowid;
          EXCEPTION
            WHEN OTHERS THEN
              vr_cdcritic := 0;
              vr_dscritic := 'Erro ao inserir registro de lote de debito. Erro: ' || SQLERRM;
              RAISE vr_exc_saida;
          END;
        
        ELSE
          -- Fecha cursor
          CLOSE cr_craplot;
        END IF;
      
        BEGIN
        
          UPDATE craplot
             SET craplot.nrseqdig = NVL(craplot.nrseqdig, 0) + 1,
                 craplot.qtinfoln = NVL(craplot.qtinfoln, 0) + 1,
                 craplot.qtcompln = NVL(craplot.qtcompln, 0) + 1,
                 craplot.vlinfodb = NVL(craplot.vlinfodb, 0) +
                                    NVL(vr_vlsldrgt, 0),
                 craplot.vlcompdb = NVL(craplot.vlcompdb, 0) +
                                    NVL(vr_vlsldrgt, 0)
           WHERE craplot.rowid = rw_craplot.rowid
           RETURNING
             cdcooper, dtmvtolt, cdagenci, cdbccxlt, nrdolote, tplotmov, nrseqdig, qtinfoln, qtcompln,
             vlinfodb, vlcompdb, vlinfocr, vlcompcr, ROWID
           INTO
             rw_craplot.cdcooper, rw_craplot.dtmvtolt, rw_craplot.cdagenci, rw_craplot.cdbccxlt,
             rw_craplot.nrdolote, rw_craplot.tplotmov, rw_craplot.nrseqdig, rw_craplot.qtinfoln,
             rw_craplot.qtcompln, rw_craplot.vlinfodb, rw_craplot.vlcompdb, rw_craplot.vlinfocr,
             rw_craplot.vlcompcr, rw_craplot.rowid;
        
        EXCEPTION
          WHEN OTHERS THEN
            vr_cdcritic := 0;
            vr_dscritic := 'Erro ao atualizar registro de lote de debito. Erro:' || SQLERRM;
            RAISE vr_exc_saida;
        END;
      
        -- Numero do documento de lancamento
        vr_nrdocmto := rw_craprac.nraplica;
      
        LOOP
          --Consulta de documentos
          OPEN cr_craplci(pr_cdcooper => rw_craplot.cdcooper --> Código da Cooperativa
                         ,pr_dtmvtolt => rw_craplot.dtmvtolt --> Data de movimento
                         ,pr_cdagenci => rw_craplot.cdagenci --> Codigo da agencia     
                         ,pr_cdbccxlt => rw_craplot.cdbccxlt --> Codigo do caixa
                         ,pr_nrdolote => rw_craplot.nrdolote --> Numero do lote
                         ,pr_nrdconta => rw_craprac.nrdconta --> Numero da conta
                         ,pr_nrdocmto => vr_nrdocmto);       --> Numero do documento
        
          FETCH cr_craplci
            INTO rw_craplci;
        
          IF cr_craplci%NOTFOUND THEN
          
            -- Fecha cursor
            CLOSE cr_craplci;
            -- Sai do loop
            EXIT;
          ELSE
          
            -- Fecha cursor
            CLOSE cr_craplci;
            -- Atualiza numero do documento
            vr_nrdocmto := TO_NUMBER('9' || TO_CHAR(vr_nrdocmto));
            -- Continua o loop ate encontrar um documento valido
            CONTINUE;
          
          END IF;
        
        END LOOP;

        -- Lancamento de debito
        BEGIN
        
          INSERT INTO craplci
            (cdcooper,
             dtmvtolt,
             cdagenci,
             cdbccxlt,
             nrdolote,
             nrdconta,
             nrdocmto,
             nrseqdig,
             vllanmto,
             cdhistor)
          VALUES
            (rw_craplot.cdcooper,
             rw_crapdat.dtmvtopr,
             rw_craplot.cdagenci,
             rw_craplot.cdbccxlt,
             rw_craplot.nrdolote,
             rw_craprac.nrdconta,
             vr_nrdocmto,
             rw_craplot.nrseqdig,
             vr_vlsldrgt,          -- Valor do resgate
             rw_craprac.cdhsvtap);
        
        EXCEPTION
          WHEN OTHERS THEN
            vr_cdcritic := 0;
            vr_dscritic := '';
            RAISE vr_exc_saida;
        END;
      
        -- Verifica registro lote de credito
        OPEN cr_craplot(pr_cdcooper => rw_craprac.cdcooper,
                        pr_dtmvtolt => rw_crapdat.dtmvtopr,
                        pr_cdagenci => 1,
                        pr_cdbccxlt => 100,
                        pr_nrdolote => 10112);
      
        FETCH cr_craplot
          INTO rw_craplot;
      
        -- Verifica se registro existe
        IF cr_craplot%NOTFOUND THEN
        
          -- Fecha cursor
          CLOSE cr_craplot;
        
          -- Insere novo registro de lote
          BEGIN
            INSERT INTO craplot
              (cdcooper,
               dtmvtolt,
               cdagenci,
               cdbccxlt,
               nrdolote,
               tplotmov,
               nrseqdig,
               qtinfoln,
               qtcompln,
               vlinfodb,
               vlcompdb,
               vlinfocr,
               vlcompcr)
            VALUES
              (pr_cdcooper,
               rw_crapdat.dtmvtopr,
               1,
               100,
               10112,
               29,
               0,
               0,
               0,
               0,
               0,
               0,
               0)
            RETURNING
              cdcooper, dtmvtolt, cdagenci, cdbccxlt, nrdolote, tplotmov, nrseqdig, qtinfoln, qtcompln,
              vlinfodb, vlcompdb, vlinfocr, vlcompcr, ROWID
            INTO
              rw_craplot.cdcooper, rw_craplot.dtmvtolt, rw_craplot.cdagenci, rw_craplot.cdbccxlt,
              rw_craplot.nrdolote, rw_craplot.tplotmov, rw_craplot.nrseqdig, rw_craplot.qtinfoln,
              rw_craplot.qtcompln, rw_craplot.vlinfodb, rw_craplot.vlcompdb, rw_craplot.vlinfocr,
              rw_craplot.vlcompcr, rw_craplot.rowid;
          EXCEPTION
            WHEN OTHERS THEN
              vr_cdcritic := 0;
              vr_dscritic := 'Erro ao inserir registro de lote de credito. Erro: ' || SQLERRM;
              RAISE vr_exc_saida;
          END;
        
        ELSE
          -- Fecha cursor
          CLOSE cr_craplot;
        END IF;
      
        BEGIN
        
          UPDATE craplot
             SET craplot.nrseqdig = NVL(craplot.nrseqdig, 0) + 1,
                 craplot.qtinfoln = NVL(craplot.qtinfoln, 0) + 1,
                 craplot.qtcompln = NVL(craplot.qtcompln, 0) + 1,
                 craplot.vlinfocr = NVL(craplot.vlinfocr, 0) +
                                    NVL(vr_vlsldrgt, 0),
                 craplot.vlcompcr = NVL(craplot.vlcompcr, 0) +
                                    NVL(vr_vlsldrgt, 0)
           WHERE craplot.rowid = rw_craplot.rowid
           RETURNING
             cdcooper, dtmvtolt, cdagenci, cdbccxlt, nrdolote, tplotmov, nrseqdig,
             qtinfoln, qtcompln, vlinfodb, vlcompdb, vlinfocr, vlcompcr, ROWID
           INTO
             rw_craplot.cdcooper, rw_craplot.dtmvtolt, rw_craplot.cdagenci, rw_craplot.cdbccxlt,
             rw_craplot.nrdolote, rw_craplot.tplotmov, rw_craplot.nrseqdig, rw_craplot.qtinfoln,
             rw_craplot.qtcompln, rw_craplot.vlinfodb, rw_craplot.vlcompdb, rw_craplot.vlinfocr,
             rw_craplot.vlcompcr, rw_craplot.rowid;
        
        EXCEPTION
          WHEN OTHERS THEN
            vr_cdcritic := 0;
            vr_dscritic := 'Erro ao atualizar registro de lote de credito. Erro:' || SQLERRM;
            RAISE vr_exc_saida;
        END;
      
        -- Numero do documento de lancamento
        vr_nrdocmto := rw_craprac.nraplica;
      
        LOOP
          --Consulta de documentos
          OPEN cr_craplci(pr_cdcooper => rw_craplot.cdcooper --> Código da Cooperativa
                         ,pr_dtmvtolt => rw_craplot.dtmvtolt --> Data de movimento
                         ,pr_cdagenci => rw_craplot.cdagenci --> Codigo da agencia     
                         ,pr_cdbccxlt => rw_craplot.cdbccxlt --> Codigo do caixa
                         ,pr_nrdolote => rw_craplot.nrdolote --> Numero do lote
                         ,pr_nrdconta => rw_craprac.nrdconta --> Numero da conta
                         ,pr_nrdocmto => vr_nrdocmto);       --> Numero do documento
        
          FETCH cr_craplci
            INTO rw_craplci;
        
          IF cr_craplci%NOTFOUND THEN
          
            -- Fecha cursor
            CLOSE cr_craplci;
            -- Sai do loop
            EXIT;
          ELSE
          
            -- Fecha cursor
            CLOSE cr_craplci;
            -- Atualiza numero do documento
            vr_nrdocmto := TO_NUMBER('9' || TO_CHAR(vr_nrdocmto));
            -- Continua o loop ate encontrar um documento valido
            CONTINUE;
          
          END IF;
        
        END LOOP;

        -- Lancamento de credito
        BEGIN
        
          INSERT INTO craplci
            (cdcooper,
             dtmvtolt,
             cdagenci,
             cdbccxlt,
             nrdolote,
             nrdconta,
             nrdocmto,
             nrseqdig,
             vllanmto,
             cdhistor)
          VALUES
            (rw_craplot.cdcooper,
             rw_crapdat.dtmvtopr,
             rw_craplot.cdagenci,
             rw_craplot.cdbccxlt,
             rw_craplot.nrdolote,
             rw_craprac.nrdconta,
             vr_nrdocmto,
             rw_craplot.nrseqdig,
             vr_vlsldrgt,         -- Valor do resgate
             489);
        
        EXCEPTION
          WHEN OTHERS THEN
            vr_cdcritic := 0;
            vr_dscritic := '';
            RAISE vr_exc_saida;
        END;
      
        -- Verifica lote para lancamento em conta-corrente      
        OPEN cr_craplot(pr_cdcooper => rw_craprac.cdcooper,
                        pr_dtmvtolt => rw_crapdat.dtmvtopr,
                        pr_cdagenci => 1,
                        pr_cdbccxlt => 100,
                        pr_nrdolote => 8505);
      
        FETCH cr_craplot
          INTO rw_craplot;
      
        -- Verifica se registro existe
        IF cr_craplot%NOTFOUND THEN
        
          -- Fecha cursor
          CLOSE cr_craplot;
        
          -- Insere novo registro de lote
          BEGIN
            INSERT INTO craplot
              (cdcooper,
               dtmvtolt,
               cdagenci,
               cdbccxlt,
               nrdolote,
               tplotmov,
               nrseqdig,
               qtinfoln,
               qtcompln,
               vlinfodb,
               vlcompdb,
               vlinfocr,
               vlcompcr)
            VALUES
              (pr_cdcooper,
               rw_crapdat.dtmvtopr,
               1,
               100,
               8505,
               1,
               0,
               0,
               0,
               0,
               0,
               0,
               0)
            RETURNING
              cdcooper, dtmvtolt, cdagenci, cdbccxlt, nrdolote, tplotmov, nrseqdig, qtinfoln, qtcompln,
              vlinfodb, vlcompdb, vlinfocr, vlcompcr, ROWID 
            INTO
              rw_craplot.cdcooper, rw_craplot.dtmvtolt, rw_craplot.cdagenci, rw_craplot.cdbccxlt,
              rw_craplot.nrdolote, rw_craplot.tplotmov, rw_craplot.nrseqdig, rw_craplot.qtinfoln,
              rw_craplot.qtcompln, rw_craplot.vlinfodb, rw_craplot.vlcompdb, rw_craplot.vlinfocr,
              rw_craplot.vlcompcr, rw_craplot.rowid;
          EXCEPTION
            WHEN OTHERS THEN
              vr_cdcritic := 0;
              vr_dscritic := 'Erro ao inserir registro de lote de lancamento em Conta-Corrente. Erro: ' || SQLERRM;
              RAISE vr_exc_saida;
          END;
        
        ELSE
          -- Fecha cursor
          CLOSE cr_craplot;
        END IF;
      
        BEGIN
        
          UPDATE craplot
             SET craplot.nrseqdig = NVL(craplot.nrseqdig, 0) + 1,
                 craplot.qtinfoln = NVL(craplot.qtinfoln, 0) + 1,
                 craplot.qtcompln = NVL(craplot.qtcompln, 0) + 1,
                 craplot.vlinfocr = NVL(craplot.vlinfocr, 0) +
                                    NVL(vr_vlsldrgt, 0),
                 craplot.vlcompcr = NVL(craplot.vlcompcr, 0) +
                                    NVL(vr_vlsldrgt, 0)
           WHERE craplot.rowid = rw_craplot.rowid
           RETURNING
             cdcooper, dtmvtolt, cdagenci, cdbccxlt, nrdolote, tplotmov, nrseqdig, qtinfoln,
             qtcompln, vlinfodb, vlcompdb, vlinfocr, vlcompcr, ROWID
           INTO
             rw_craplot.cdcooper, rw_craplot.dtmvtolt, rw_craplot.cdagenci, rw_craplot.cdbccxlt,
             rw_craplot.nrdolote, rw_craplot.tplotmov, rw_craplot.nrseqdig, rw_craplot.qtinfoln,
             rw_craplot.qtcompln, rw_craplot.vlinfodb, rw_craplot.vlcompdb, rw_craplot.vlinfocr,
             rw_craplot.vlcompcr, rw_craplot.rowid;
        
        EXCEPTION
          WHEN OTHERS THEN
            vr_cdcritic := 0;
            vr_dscritic := 'Erro ao atualizar registro de lote de credito Conta-Corrente. Erro:' || SQLERRM;
            RAISE vr_exc_saida;
        END;
      
        -- PJ450 - Insere Lancamento 
        -- Efetua lancamento de crédito em conta-corrente
        LANC0001.pc_gerar_lancamento_conta(pr_cdcooper => rw_craplot.cdcooper
                                          ,pr_dtmvtolt => rw_craplot.dtmvtolt
                                          ,pr_cdagenci => rw_craplot.cdagenci
                                          ,pr_cdbccxlt => rw_craplot.cdbccxlt
                                          ,pr_nrdolote => rw_craplot.nrdolote
                                          ,pr_nrdconta => rw_craprac.nrdconta
                                          ,pr_nrdctabb => rw_craprac.nrdconta
                                          ,pr_nrdocmto => rw_craprac.nraplica
                                          ,pr_dtrefere => rw_craplot.dtmvtolt
                                          ,pr_cdhistor => rw_craprac.cdhsvrcc
                                          ,pr_nrseqdig => rw_craplot.nrseqdig
                                          ,pr_vllanmto => vr_vlsldrgt
                                          ,pr_inprolot => 0                    -- Indica se a procedure deve processar (incluir/atualizar) o LOTE (CRAPLOT)
                                          ,pr_tplotmov => 0                    -- Tipo Movimento 
                                          ,pr_cdcritic => vr_cdcritic          -- Codigo Erro
                                          ,pr_dscritic => vr_dscritic          -- Descricao Erro
                                          ,pr_incrineg => vr_incrineg          -- Indicador de crítica de negócio
                                          ,pr_tab_retorno => vr_tab_retorno    -- Registro com dados do retorno
                                          );

          -- Conforme tipo de erro realiza acao diferenciada
          IF nvl(vr_cdcritic, 0) > 0 OR vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_saida;
          END IF;
      
      END IF; -- Fim verifica se aplicacao esta bloqueada
    
      vr_tptelefo := ''; -- Inicializa variavel de sequencia de telefone
      vr_contatel := 1;  -- Contador de telefones
      vr_nrramfon := ''; -- Numeros de telefone
    
      -- Verifica o tipo de cooperado
      IF rw_crapass.inpessoa = 1 THEN
        -- Fisica -- Residencial/Celular/Comercial/Contato 
        vr_tptelefo := '1,2,3,4';
      ELSE
        -- Juridica -- Comercial/Celular/Residencial/Contato
        vr_tptelefo := '3,2,1,4';
      END IF;
    
      -- Loop para listar telefone
      LOOP

        IF vr_contatel = 5 THEN
          EXIT;
        END IF;
 
        -- Consulta telefone
        OPEN cr_craptfc(pr_cdcooper => rw_craprac.cdcooper,
                        pr_nrdconta => rw_crapass.nrdconta,
                        pr_idseqttl => 1,
                        pr_tptelefo => gene0002.fn_busca_entrada(pr_postext     => vr_contatel,
                                                                 pr_dstext      => vr_tptelefo,
                                                                 pr_delimitador => ','));
      
        FETCH cr_craptfc
          INTO rw_craptfc;
      
        IF cr_craptfc%NOTFOUND THEN
          -- Fecha cursor
          CLOSE cr_craptfc;
          vr_contatel := vr_contatel + 1;
          CONTINUE;
        ELSE
          -- Fecha cursor
          CLOSE cr_craptfc;
        END IF;
      
        -- Coloca DDD          
        IF rw_craptfc.nrdddtfc <> 0 THEN
          vr_nrramfon := '(' || rw_craptfc.nrdddtfc || ') ';
        END IF;
      
        -- Incrementa numero de telefone          
        vr_nrramfon := vr_nrramfon || rw_craptfc.nrtelefo;
      
        vr_contatel := vr_contatel + 1;
      
      END LOOP;
    
      -- Monta PL Table para XML
      vr_tab_aplicacoes(vr_dscchave).cdagenci := rw_crapass.cdagenci;
      vr_tab_aplicacoes(vr_dscchave).dsagenci := rw_crapass.nmagenci;
      vr_tab_aplicacoes(vr_dscchave).nrdconta := rw_crapass.nrdconta;
      vr_tab_aplicacoes(vr_dscchave).nmprimtl := rw_crapass.nmprimtl;
      vr_tab_aplicacoes(vr_dscchave).nraplica := rw_craprac.nraplica;
      vr_tab_aplicacoes(vr_dscchave).qtdiaapl := rw_craprac.qtdiaapl;
      vr_tab_aplicacoes(vr_dscchave).vllanmto := vr_vlsldrgt;
      vr_tab_aplicacoes(vr_dscchave).nrramfon := vr_nrramfon;
    
    END LOOP; -- Fim leitura de aplicacoes
  
    -- Fecha cursor
    CLOSE cr_craprac;

    ---------- APLICACOES A VENCER ----------
  
    -- Monta tabela com aplicacoes a vencer para listar no relatorio CRRL679
  
    -- Data de inicio e fim para verificacao de aplicacoes a vencer
    vr_dtvenfin := gene0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper
                                              ,pr_dtmvtolt => rw_crapdat.dtmvtopr + 5 
                                              ,pr_tipo     => 'P');
    
    FOR rw_crapcpc IN cr_crapcpc(pr_cdcooper => pr_cdcooper
                                ,pr_dtvenini => rw_crapdat.dtmvtopr
                                ,pr_dtvenfin => vr_dtvenfin) LOOP                                
      
      -- Verifica tipo de aplicacao
      IF rw_crapcpc.idtippro = 1 THEN
          
        -- Pré-Fixada 
        apli0006.pc_posicao_saldo_aplicacao_pre(pr_cdcooper => rw_crapcpc.cdcooper,
                                                pr_nrdconta => rw_crapcpc.nrdconta,
                                                pr_nraplica => rw_crapcpc.nraplica,
                                                pr_dtiniapl => rw_crapcpc.dtmvtolt,
                                                pr_txaplica => rw_crapcpc.txaplica,
                                                pr_idtxfixa => rw_crapcpc.idtxfixa,
                                                pr_cddindex => rw_crapcpc.cddindex,
                                                pr_qtdiacar => rw_crapcpc.qtdiacar,
                                                pr_idgravir => 1,
                                                pr_idaplpgm => 0,                   -- Aplicação Programada  (0-Não/1-Sim)
                                                pr_dtinical => rw_crapcpc.dtmvtolt,
                                                pr_dtfimcal => rw_crapdat.dtmvtopr,
                                                pr_idtipbas => 2,
                                                pr_vlbascal => vr_vlbascal,
                                                pr_vlsldtot => vr_vlsldtot,
                                                pr_vlsldrgt => vr_vlsldrgt,
                                                pr_vlultren => vr_vlultren,
                                                pr_vlrentot => vr_vlrentot,
                                                pr_vlrevers => vr_vlrevers,
                                                pr_vlrdirrf => vr_vlrdirrf,
                                                pr_percirrf => vr_percirrf,
                                                pr_cdcritic => vr_cdcritic,
                                                pr_dscritic => vr_dscritic);
        
      ELSIF rw_crapcpc.idtippro = 2 THEN
          
        -- Pós-Fixada    
        apli0006.pc_posicao_saldo_aplicacao_pos(pr_cdcooper => rw_crapcpc.cdcooper,
                                                pr_nrdconta => rw_crapcpc.nrdconta,
                                                pr_nraplica => rw_crapcpc.nraplica,
                                                pr_dtiniapl => rw_crapcpc.dtmvtolt,
                                                pr_txaplica => rw_crapcpc.txaplica,
                                                pr_idtxfixa => rw_crapcpc.idtxfixa,
                                                pr_cddindex => rw_crapcpc.cddindex,
                                                pr_qtdiacar => rw_crapcpc.qtdiacar,
                                                pr_idgravir => 1,
                                                pr_idaplpgm => 0,                   -- Aplicação Programada  (0-Não/1-Sim)
                                                pr_dtinical => rw_crapcpc.dtmvtolt,
                                                pr_dtfimcal => rw_crapdat.dtmvtopr,
                                                pr_idtipbas => 2,
                                                pr_vlbascal => vr_vlbascal,
                                                pr_vlsldtot => vr_vlsldtot,
                                                pr_vlsldrgt => vr_vlsldrgt,
                                                pr_vlultren => vr_vlultren,
                                                pr_vlrentot => vr_vlrentot,
                                                pr_vlrevers => vr_vlrevers,
                                                pr_vlrdirrf => vr_vlrdirrf,
                                                pr_percirrf => vr_percirrf,
                                                pr_cdcritic => vr_cdcritic,
                                                pr_dscritic => vr_dscritic);
        
      END IF;
      
      -- Veririca se houve critica na consulta de posicao de saldo
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;
      
      -- Consulta dados do cooperado e agencia
      OPEN cr_crapass(pr_cdcooper => rw_crapcpc.cdcooper,
                      pr_nrdconta => rw_crapcpc.nrdconta);
      
      FETCH cr_crapass
        INTO rw_crapass;
      
      -- Verifica se registro de cooperado/agencia existe
      IF cr_crapass%NOTFOUND THEN
        -- Fecha cursor
        CLOSE cr_crapass;
        -- Gera critica
        vr_cdcritic := 0;
        vr_dscritic := '2.Registro de cooperado/agencia inexistente.Conta: ' ||
                       gene0002.fn_mask_conta(pr_nrdconta => rw_crapcpc.nrdconta);
        RAISE vr_exc_saida;
      ELSE
        -- Fecha cursor
        CLOSE cr_crapass;
      END IF;
      
      vr_tptelefo := ''; -- Inicializa variavel de sequencia de telefone
      vr_contatel := 1; -- Contador de telefones
      vr_nrramfon := ''; -- Numeros de telefone
      
      -- Verifica o tipo de cooperado
      IF rw_crapass.inpessoa = 1 THEN
        -- Fisica -- Residencial/Celular/Comercial/Contato 
        vr_tptelefo := '1,2,3,4';
      ELSE
        -- Juridica -- Comercial/Celular/Residencial/Contato
        vr_tptelefo := '3,2,1,4';
      END IF;
      
      -- Loop para listar telefone
      LOOP
        IF vr_contatel = 5 THEN
          EXIT;
        END IF;

        -- Consulta telefone
        OPEN cr_craptfc(pr_cdcooper => rw_crapcpc.cdcooper,
                        pr_nrdconta => rw_crapass.nrdconta,
                        pr_idseqttl => 1,
                        pr_tptelefo => gene0002.fn_busca_entrada(pr_postext     => vr_contatel,
                                                                 pr_dstext      => vr_tptelefo,
                                                                 pr_delimitador => ','));
        
        FETCH cr_craptfc
          INTO rw_craptfc;
        
        IF cr_craptfc%NOTFOUND THEN
          -- Fecha cursor
          CLOSE cr_craptfc;
          vr_contatel := vr_contatel + 1;	
          CONTINUE;
        ELSE
          -- Fecha cursor
          CLOSE cr_craptfc;
        END IF;
        
        -- Coloca DDD          
        IF rw_craptfc.nrdddtfc <> 0 THEN
          vr_nrramfon := '(' || rw_craptfc.nrdddtfc || ') ';
        END IF;
        
        -- Incrementa numero de telefone          
        vr_nrramfon := vr_nrramfon || rw_craptfc.nrtelefo;
        
        vr_contatel := vr_contatel + 1;
        
      END LOOP; -- Fim loop telefones
      
      -- Monta chave da pl table
      vr_dscchave := LPAD(rw_crapass.cdagenci, 5, '0') ||
                     LPAD(rw_crapass.nrdconta, 10, '0') ||
                     LPAD(rw_crapcpc.nraplica, 6, '0');
      
      -- Monta PL Table para XML
      vr_tab_aplicvence(vr_dscchave).cdagenci := rw_crapass.cdagenci;
      vr_tab_aplicvence(vr_dscchave).dsagenci := rw_crapass.nmagenci;
      vr_tab_aplicvence(vr_dscchave).nrdconta := rw_crapass.nrdconta;
      vr_tab_aplicvence(vr_dscchave).nmprimtl := rw_crapass.nmprimtl;
      vr_tab_aplicvence(vr_dscchave).nraplica := rw_crapcpc.nraplica;
      vr_tab_aplicvence(vr_dscchave).dtvencto := rw_crapcpc.dtvencto;
      vr_tab_aplicvence(vr_dscchave).vllanmto := vr_vlsldrgt;
      vr_tab_aplicvence(vr_dscchave).nrramfon := vr_nrramfon;
    
    END LOOP;
    -- Fim loop leitura de aplicacoes a vencer (5d pra frente)
  
    ---------- FIM APLICACOES A VENCER ----------
  
    ---------- MONTA XML PARA RELATORIO ----------
  
    -- INICIALIZAR O CLOB (XML)
    dbms_lob.createtemporary(vr_clobxml, TRUE);
    dbms_lob.open(vr_clobxml, dbms_lob.lob_readwrite);
  
    -- INICIO DO ARQUIVO XML
    pc_escreve_xml('<?xml version="1.0" encoding="utf-8"?><raiz>');
  
    -- Limpa variaveis com PA
    vr_cdagenan := 0;
    vr_cdagenci := 0;
  
    -- Atribuicao de primeiro indice
    vr_dscchave := vr_tab_aplicacoes.first;
  
    IF vr_dscchave IS NOT NULL THEN

      vr_controle := TRUE;

      -- Monta TAG XML com aplicacoes vencidas
      pc_escreve_xml('<vencidas>');
    
      LOOP
      
        vr_cdagenci := vr_tab_aplicacoes(vr_dscchave).cdagenci;
      
        IF vr_cdagenan <> vr_cdagenci AND vr_cdagenan = 0 THEN
          pc_escreve_xml('<cdagenci id="' || vr_tab_aplicacoes(vr_dscchave).dsagenci || '"><dsagenci>' || vr_tab_aplicacoes(vr_dscchave)
                         .dsagenci || '</dsagenci>');
        ELSIF vr_cdagenan <> vr_cdagenci AND vr_cdagenan <> 0 THEN
          pc_escreve_xml('</cdagenci><cdagenci id="' || vr_tab_aplicacoes(vr_dscchave).dsagenci || '"><dsagenci>' ||
                         vr_tab_aplicacoes(vr_dscchave).dsagenci || '</dsagenci>');
        END IF;
           
        pc_escreve_xml('<numaplic id="' ||
                       TRIM(gene0002.fn_mask_conta(vr_tab_aplicacoes(vr_dscchave).nrdconta)) ||
                       TRIM(gene0002.fn_mask_contrato(vr_tab_aplicacoes(vr_dscchave).nraplica)) || '">'||
                       '<nrdconta>' || TRIM(gene0002.fn_mask_conta(vr_tab_aplicacoes(vr_dscchave).nrdconta)) || '</nrdconta>' ||
                       '<nmprimtl>' || TRIM(vr_tab_aplicacoes(vr_dscchave).nmprimtl) || '</nmprimtl>' ||
                       '<nraplica>' || TRIM(gene0002.fn_mask_contrato(vr_tab_aplicacoes(vr_dscchave).nraplica)) || '</nraplica>' ||
                       '<qtdiaapl>' || TRIM(NVL(vr_tab_aplicacoes(vr_dscchave).qtdiaapl,0)) || '</qtdiaapl>' ||
                       '<vllanmto>' || TO_CHAR(NVL(vr_tab_aplicacoes(vr_dscchave).vllanmto,0),'fm999G999G990D00') || '</vllanmto>' ||
                       '<nrramfon>' || TRIM(vr_tab_aplicacoes(vr_dscchave).nrramfon) || '</nrramfon>' ||
                       '<dscritic>' || TRIM(vr_tab_aplicacoes(vr_dscchave).dscritic) || '</dscritic>' ||
                       '</numaplic>');
        
        -- Verifica se esta no ultimo registro da pl table
        IF vr_dscchave = vr_tab_aplicacoes.last THEN
          pc_escreve_xml('</cdagenci>');
          EXIT;
        END IF;
                            
        -- Popula nova chave
        vr_dscchave := vr_tab_aplicacoes.next(vr_dscchave);
      
        -- Alimenta variavel com agencia anterior         
        vr_cdagenan := vr_cdagenci;
      
      END LOOP;
    
      -- Fecha tag pai de aplicacoes resgatadas mau sucedidas
      pc_escreve_xml('</vencidas>');
    
    END IF;
  
    -- Monta TAG XML com aplicacoes a vencer
  
    -- Limpa variaveis com PA
    vr_cdagenan := 0;
    vr_cdagenci := 0;
  
    -- Atribuicao de primeiro indice
    vr_dscchave := vr_tab_aplicvence.first;
  
    IF vr_dscchave IS NOT NULL THEN
    
      vr_controle := TRUE;

      -- Monta TAG XML com aplicacoes vencidas
      pc_escreve_xml('<avencer>');
    
      LOOP
      
        vr_cdagenci := vr_tab_aplicvence(vr_dscchave).cdagenci;
      
        IF vr_cdagenan <> vr_cdagenci AND vr_cdagenan = 0 THEN
          pc_escreve_xml('<cdagenci id="' || vr_tab_aplicvence(vr_dscchave).dsagenci || '">' ||
                         '<dsagenci>' || vr_tab_aplicvence(vr_dscchave).dsagenci || '</dsagenci>');
        ELSIF vr_cdagenan <> vr_cdagenci AND vr_cdagenan <> 0 THEN
          pc_escreve_xml('</cdagenci><cdagenci id="' || vr_tab_aplicvence(vr_dscchave).dsagenci || '">'||
                         '<dsagenci>' || vr_tab_aplicvence(vr_dscchave).dsagenci || '</dsagenci>');
        END IF;
         
        pc_escreve_xml('<numaplic id="' || TRIM(vr_tab_aplicvence(vr_dscchave).nrdconta) ||
                                           TRIM(vr_tab_aplicvence(vr_dscchave).nraplica) ||'">' ||
                       '<nrdconta>' || TRIM(gene0002.fn_mask_conta(vr_tab_aplicvence(vr_dscchave).nrdconta)) || '</nrdconta>' ||
                       '<nmprimtl>' || TRIM(vr_tab_aplicvence(vr_dscchave).nmprimtl) || '</nmprimtl>' ||
                       '<nraplica>' || TRIM(gene0002.fn_mask_contrato(vr_tab_aplicvence(vr_dscchave).nraplica)) || '</nraplica>' ||
                       '<dtvencto>' || TO_CHAR(vr_tab_aplicvence(vr_dscchave).dtvencto,'dd/mm/RRRR') || '</dtvencto>' ||
                       '<vllanmto>' || TO_CHAR(NVL(vr_tab_aplicvence(vr_dscchave).vllanmto,0),'fm999G999G990D00') || '</vllanmto>' ||
                       '<nrramfon>' || TRIM(vr_tab_aplicvence(vr_dscchave).nrramfon) || '</nrramfon>' ||
                       '</numaplic>');

        -- Verifica se esta no ultimo registro da pl table
        IF vr_dscchave = vr_tab_aplicvence.last THEN
          pc_escreve_xml('</cdagenci>');
          EXIT;
        END IF;
             
        -- Popula nova chave
        vr_dscchave := vr_tab_aplicvence.next(vr_dscchave);
      
        -- Alimenta variavel com agencia anterior         
        vr_cdagenan := vr_cdagenci;
      
      END LOOP;
    
      -- Fecha tag pai de aplicacoes resgatadas mau sucedidas
      pc_escreve_xml('</avencer>');
    
    END IF;
  
    -- FIM DO ARQUIVO XML
    pc_escreve_xml('</raiz>');
  
    ---------- FIM MONTA XML PARA RELATORIO ----------
  
    ---------- SOLICITA RELATORIO ----------
    vr_dscritic := NULL;
  
    IF vr_controle THEN
      gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper         --> Cooperativa
                                 ,pr_cdprogra  => vr_cdprogra         --> Programa chamador
                                 ,pr_dtmvtolt  => rw_crapdat.dtmvtolt --> Data do movimento atual
                                 ,pr_dsxml     => vr_clobxml          --> Arquivo XML de dados
                                 ,pr_dsxmlnode => '/raiz'             --> Nó do XML para iteração
                                 ,pr_dsjasper  => 'crrl679.jasper'    --> Arquivo de layout do iReport
                                 ,pr_dsparams  => ''                  --> Array de parametros diversos
                                 ,pr_dsarqsaid => vr_dsarquiv         --> Path/Nome do arquivo PDF gerado
                                 ,pr_flg_gerar => 'S'                 --> Gerar o arquivo na hora*
                                 ,pr_qtcoluna  => 132                 --> Qtd colunas do relatório (80,132,234)
                                 ,pr_sqcabrel  => 1                   --> Indicado de seq do cabrel
                                 ,pr_flg_impri => 'S'                 --> Chamar a impressão (Imprim.p)*
                                 ,pr_nmformul  => ''                  --> Nome do formulário para impressão
                                 ,pr_nrcopias  => 1                   --> Qtd de cópias
                                 ,pr_flappend  => 'N'                 --> Indica que a solicitação irá incrementar o arquivo
                                 ,pr_des_erro  => vr_dscritic);       --> Saída com erro
    

      -- Verifica se ocorreu uma critica
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;

    END IF;
    -- Libera a memoria alocada p/ variave clob
    dbms_lob.close(vr_clobxml);
    dbms_lob.freetemporary(vr_clobxml);
  
    ---------- FIM SOLICITA RELATORIO ----------
  
    -- Processo OK, devemos chamar a fimprg
    btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper,
                              pr_cdprogra => vr_cdprogra,
                              pr_infimsol => pr_infimsol,
                              pr_stprogra => pr_stprogra);
  
    --Salvar informacoes no banco de dados
    COMMIT;        
  EXCEPTION
    WHEN vr_exc_fimprg THEN
      -- Se foi retornado apenas codigo
      IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      -- Se foi gerada critica para envio ao log
      IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
        -- Envio centralizado de log de erro
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                   pr_ind_tipo_log => 2 -- Erro tratato
                                  ,pr_des_log      => to_char(SYSDATE,
                                                              'hh24:mi:ss') ||
                                                      ' - ' || vr_cdprogra ||
                                                      ' --> ' || vr_dscritic);
      END IF;

      --Limpar variaveis retorno
      pr_cdcritic := NULL;
      pr_dscritic := NULL;
      -- Chamamos a fimprg para encerrarmos o processo sem parar a cadeia
      btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper,
                                pr_cdprogra => vr_cdprogra,
                                pr_infimsol => pr_infimsol,
                                pr_stprogra => pr_stprogra);
      -- Efetuar commit pois gravaremos o que foi processo até então
      COMMIT;            
    WHEN vr_exc_saida THEN
      -- Se foi retornado apenas código
      IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      -- Devolvemos código e critica encontradas
      pr_cdcritic := nvl(vr_cdcritic, 0);
      pr_dscritic := vr_dscritic;
      -- Efetuar rollback
      ROLLBACK;
    
    WHEN OTHERS THEN
      -- Efetuar retorno do erro não tratado
      pr_cdcritic := 0;
      pr_dscritic := 'Erro na procedure pc_crps686. ' || SQLERRM;
      -- Efetuar rollback
      ROLLBACK;
    
  END;
END pc_crps686;
/
