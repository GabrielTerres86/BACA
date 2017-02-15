CREATE OR REPLACE PROCEDURE CECRED.pc_crps294 (pr_cdcooper IN crapcop.cdcooper%TYPE   --> Cooperativa solicitada
                    ,pr_flgresta  IN PLS_INTEGER            --> Flag padrão para utilização de restart
                    ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                    ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                    ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                    ,pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada
  BEGIN
    /* .............................................................................

   Programa: pc_crps294     (Antigo: Fontes/crps294.p)
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Margarete/Planner
   Data    : Agosto/2000.                    Ultima atualizacao: 15/02/2017

   Dados referentes ao programa:

   Frequencia: Diario (Batch - Background).
   Objetivo  : Atende a solicitacao 4.
               Emite relatorio de creditos concedidos aos funcionarios e
               conselheiros.

   Alteracoes: 13/03/2003 - Alterado para tratar novos campos craplim (Edson).

               10/07/2003 - Alterado para listar TODOS os registros do craplim
                            no periodo (Edson).

               30/06/2004 - Incluido, na leitura dos associados, os novos tipos
                            de vinculo (Evandro).

               03/12/2004 - Emissao Rel.394 (Auditoria) - Todas operacoes de
                            Creditos Ativas(Mirtes)

               16/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando.

               31/03/2006 - Concertada clausula OR do FOR EACH, pondo entre
                            parenteses (Diego).

               22/03/2007 - Incluido comite cooperativa (Magui).

               15/10/2008 - Incluido tratamento para Desconto de Cheques e
                            Titulos (Diego).

               05/05/2009 - Considerar pagamentos no dia apenas para titulos
                            pagos via CAIXA ou INTERNETBANK(Guilherme).

               10/06/2010 - Tratamento para pagamentos feitos atraves de TAA
                            (Elton).

               04/12/2013 - Conversao Progress -> Oracle (Edison - AMcom)

               08/07/2014 - Aplicar as alterações solicitadas através do
                            chamado 43219, que haviam sido feitas no fonte
                            progress por engano:       ( Renato - Supero )

                            > Adicionadas informaçoes de PAC, Data da operação
                            e numero do contrato (Daniele).

                            > Alterado  o formato do relatorio para 132
                            caracteres (Daniele).

                            > Nova forma de chamar as agências, de PAC agora
                            a escrita será PA (Guilherme Gielow)

               24/10/2014 - Ajustado para exibir as informações dos cooperados
                            que possuem o tipo de vinculo DI - "Diretor de Cooperativa"
                            (Douglas - Chamado 208639)

               16/12/2014 - Ajustado para que o relatório faça o filtro levando em consideração
                            o mês inteiro da data de movimentação (Kelvin - SD 233303).

               13/01/2015 - Feito o ajuste para que quando listado os imprestimos, apareça
                            o contrato e a data de movimentação correta. (Kelvin- SD 240325)

               15/01/2015 - Ajuste no cursor cr_craplim394 para somente pegar os limites
                            que estao ativos. (James)

               26/01/2015 - Alterado o formato do campo nrctremp para 8
                            caracters (Kelvin - 233714)

               15/02/2017 - Ajustando o format do campo nrctrcrd nos relatórios que o utilizam.
			     		    SD 594718 (Kelvin).
    ............................................................................ */

    DECLARE
      ------------------------ VARIAVEIS PRINCIPAIS ----------------------------

      -- Código do programa
      vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'CRPS294';

      -- Tratamento de erros
      vr_exc_saida  EXCEPTION;
      vr_exc_fimprg EXCEPTION;
      vr_cdcritic   PLS_INTEGER;
      vr_dscritic   VARCHAR2(4000);

      vr_totcredi   NUMBER(15,2);
      vr_ttslddev   NUMBER(15,2);
      vr_totcredi394 NUMBER(15,2);
      vr_ttslddev394 crapepr.vlsdeved%TYPE;
      vr_nmmesref   varchar2(100);
      vr_datamvto   DATE;
      vr_deslimit   VARCHAR2(100);
      vr_vlrutili   NUMBER;
      vr_vllimite   NUMBER;
      vr_dssituac   VARCHAR2(100);
      vr_seq        INTEGER;
      vr_flgexist   BOOLEAN;
      vr_caminho_cooper VARCHAR2(500);
      vr_dslabel1   VARCHAR2(100);
      vr_dslabel2   VARCHAR2(100);
      vr_dslabel3   VARCHAR2(100);

      -- Variavel de Controle de XML
      vr_crrl244_xml      CLOB;
      vr_crrl394_xml      CLOB;
      vr_detalhe          VARCHAR2(4000);
      vr_detalhe394       VARCHAR2(4000);

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

      -- Dados dos cooperados
      CURSOR cr_crapass ( pr_cdcooper IN crapass.cdcooper%TYPE) IS
        SELECT crapass.nrdconta
              ,crapass.nmprimtl
              ,decode(crapass.tpvincul,'FU', 'FUNCIONARIO DA COOPERATIVA'
                                      ,'CA', 'CONSELHO DE ADMINISTRACAO'
                                      ,'CF', 'CONSELHO FISCAL'
                                      ,'CC', 'CONSELHO DA CENTRAL'
                                      ,'CO', 'COMITE COOPERATIVA'
                                      ,'FC', 'FUNCIONARIO DA CENTRAL'
                                      ,'FO', 'FUNCIONARIO DE OUTRAS COOP'
                                      ,'ET', 'ESTAGIARIO TERCEIRO'
                                      ,'DI', 'DIRETOR DE COOPERATIVA') desvincu
              ,crapass.cdagenci
        FROM   crapass
        WHERE  crapass.cdcooper = pr_cdcooper
          AND  crapass.tpvincul IN ( 'FU' /* funcionario da cooperativa*/
                                    ,'CA' /* conselho de administracao */
                                    ,'CF' /* conselho fiscal */
                                    ,'CC' /* conselho da central */
                                    ,'CO' /* comite cooperativa */
                                    ,'FC' /* funcionario da central */
                                    ,'FO' /* funcionario de outras coop*/
                                    ,'ET' /* estagiario terceiro */
                                    ,'DI')/* diretor de cooperativa*/
        ORDER BY crapass.cdcooper
                ,crapass.nrdconta;
      -- rowtype dos associados
      rw_crapass cr_crapass%ROWTYPE;

      /* pesquisa limite de credito */
      -- Busca os limites de crédito do associado com vigencia
      -- iniciando no mes do processamento (dtmvtolt)
      CURSOR cr_craplim( pr_cdcooper IN craplim.cdcooper%TYPE
                        ,pr_nrdconta IN craplim.nrdconta%TYPE
                        ,pr_tpctrlim IN craplim.tpctrlim%TYPE
                        ,pr_dtinivig IN DATE) IS
        SELECT craplim.inbaslim
              ,craplim.vllimite
              ,craplim.insitlim
              ,craplim.nrctrlim
              ,craplim.dtinivig
        FROM   craplim
        WHERE  craplim.cdcooper = pr_cdcooper -- Codigo da cooperativa
        AND    craplim.nrdconta = pr_nrdconta -- Numero da conta/dv do associado.
        AND    craplim.tpctrlim = pr_tpctrlim -- Tipo de contrato do limite.
        AND    craplim.dtinivig > pr_dtinivig -- Data de inicio da vigencia.
        AND    craplim.insitlim <> 1          -- 1-em estudo;2-ativo;3-cancelado;
        ORDER BY cdcooper
                ,nrdconta
                ,dtinivig
                ,tpctrlim
                ,nrctrlim;
      --
      rw_craplim cr_craplim%ROWTYPE;

      /* pesquisa limite de credito */
      -- Busca os limites de crédito do associado vigentes
      CURSOR cr_craplim394( pr_cdcooper IN craplim.cdcooper%TYPE
                           ,pr_nrdconta IN craplim.nrdconta%TYPE
                           ,pr_tpctrlim IN craplim.tpctrlim%TYPE) IS
        SELECT craplim.inbaslim
              ,craplim.vllimite
              ,craplim.insitlim
              ,craplim.dtinivig
              ,craplim.nrctrlim
        FROM   craplim
        WHERE  craplim.cdcooper = pr_cdcooper -- Codigo da cooperativa
        AND    craplim.nrdconta = pr_nrdconta -- Numero da conta/dv do associado.
        AND    craplim.tpctrlim = pr_tpctrlim -- Tipo de contrato do limite.
        AND    craplim.dtinivig IS NOT NULL   -- Data de inicio da vigencia.
        AND    craplim.insitlim = 2           -- Situacao Ativo
        ORDER BY cdcooper
                ,nrdconta
                ,dtinivig
                ,tpctrlim
                ,nrctrlim;
      --
      rw_craplim394 cr_craplim394%ROWTYPE;

      -- Titulos contidos do Bordero de desconto de titulos
      -- Busca os títulos liberados com vencimento no dia e
      -- os titulos pagos no dia
      CURSOR cr_craptdb( pr_cdcooper IN crapcop.cdcooper%TYPE
                        ,pr_nrdconta IN craptdb.nrdconta%TYPE
                        ,pr_nrctrlim IN craptdb.nrctrlim%TYPE
                        ,pr_dtmvtolt IN DATE
                        ,pr_flgtprel IN VARCHAR2) IS
        /* Titulos que estao em uso */
        SELECT craptdb.cdbandoc
              ,craptdb.nrdctabb
              ,craptdb.nrcnvcob
              ,craptdb.nrdconta
              ,craptdb.nrdocmto
              ,craptdb.insittit
              ,craptdb.vltitulo
              ,craptdb.rowid
          FROM craptdb
         WHERE craptdb.cdcooper =  pr_cdcooper  -- Codigo da cooperativa
           AND craptdb.insittit =  4            -- Situacao do titulo: 0-nao proc,1-resgat,2-proc,3-baixado s/pagto,4-liberado
           AND craptdb.nrdconta =  pr_nrdconta  -- Conta do associado
           AND (craptdb.nrctrlim =  pr_nrctrlim  OR -- Contem o numero do contrato de limite de destonto de titulo.
                pr_nrctrlim IS NULL)
           --Adicionado validação para ver qual relatório que esta chamadando o cursor
           --caso for o 244 é filtrado para todo o mês atual, se for o 394 filtra normalmente
           AND DECODE(pr_flgtprel
                    , 244
                    , TRUNC(craptdb.dtvencto,'MM')
                    , craptdb.dtvencto) >= DECODE(pr_flgtprel
                                                , 244
                                                , TRUNC(pr_dtmvtolt,'MM')
                                                , pr_dtmvtolt) -- Data do resgate do titulo ao solicitante da custodia.

         UNION
        /* Pagos no dia */
        SELECT craptdb.cdbandoc
              ,craptdb.nrdctabb
              ,craptdb.nrcnvcob
              ,craptdb.nrdconta
              ,craptdb.nrdocmto
              ,craptdb.insittit
              ,craptdb.vltitulo
              ,craptdb.rowid
          FROM craptdb
         WHERE craptdb.cdcooper = pr_cdcooper
           AND craptdb.insittit =  2 -- Situacao do titulo: 0-nao proc,1-resgat,2-proc,3-baixado s/pagto,4-liberado
           AND craptdb.nrdconta = pr_nrdconta
           AND (craptdb.nrctrlim =  pr_nrctrlim  OR pr_nrctrlim IS NULL)
           --Adicionado validação para ver qual relatório que esta chamadando o cursor
           --caso for o 244 é filtrado para todo o mês atual, se for o 394 filtra normalmente
           AND DECODE(pr_flgtprel
                    , 244
                    , TRUNC(craptdb.dtdpagto,'MM')
                    , craptdb.dtdpagto) = DECODE(pr_flgtprel
                                        , 244
                                        , TRUNC(pr_dtmvtolt,'MM')
                                        , pr_dtmvtolt); -- Data do pagamento do titulo.

      rw_craptdb cr_craptdb%ROWTYPE;

      -- Cadastro de bloquetos de cobranca
      CURSOR cr_crapcob ( pr_cdcooper IN crapcop.cdcooper%TYPE
                         ,pr_cdbandoc IN crapcob.cdbandoc%TYPE
                         ,pr_nrdctabb IN crapcob.nrdctabb%TYPE
                         ,pr_nrcnvcob IN crapcob.nrcnvcob%TYPE
                         ,pr_nrdconta IN crapcob.nrdconta%TYPE
                         ,pr_nrdocmto IN crapcob.nrdocmto%TYPE) IS
        SELECT crapcob.indpagto
        FROM   crapcob
        WHERE  crapcob.cdcooper = pr_cdcooper
        AND    crapcob.cdbandoc = pr_cdbandoc
        AND    crapcob.nrdctabb = pr_nrdctabb
        AND    crapcob.nrcnvcob = pr_nrcnvcob
        AND    crapcob.nrdconta = pr_nrdconta
        AND    crapcob.nrdocmto = pr_nrdocmto;
      --
      rw_crapcob cr_crapcob%ROWTYPE;

      -- Busca os cheques contidos do Bordero de desconto de cheques
      -- que ja foram processados e pendentes de liberação no mês atual da data de movimentação
      -- para o relatório 244
      CURSOR cr_crapcdb244(pr_cdcooper IN crapcop.cdcooper%TYPE
                          ,pr_nrdconta IN crapcob.nrdconta%TYPE
                          ,pr_nrctrlim IN crapcdb.nrctrlim%TYPE
                          ,pr_dtmvtolt IN DATE) IS
        SELECT SUM(crapcdb.vlcheque) vlcheque
          FROM crapcdb
         WHERE crapcdb.cdcooper = pr_cdcooper
           AND crapcdb.nrdconta = pr_nrdconta
           AND (crapcdb.nrctrlim = pr_nrctrlim OR pr_nrctrlim IS NULL)
           AND crapcdb.insitchq = 2 --Situacao do cheque: 0=nao processado, 1=resgatado, 2=processado.
           AND TRUNC(crapcdb.dtlibera,'MM') = TRUNC(pr_dtmvtolt,'MM');

      -- Busca os cheques contidos do Bordero de desconto de cheques
      -- que ja foram processados e pendentes de liberação na data atual de movimentação
      -- para o relatório 394
      CURSOR cr_crapcdb394(pr_cdcooper IN crapcop.cdcooper%TYPE
                          ,pr_nrdconta IN crapcob.nrdconta%TYPE
                          ,pr_nrctrlim IN crapcdb.nrctrlim%TYPE
                          ,pr_dtmvtolt IN DATE) IS
        SELECT SUM(crapcdb.vlcheque) vlcheque
          FROM crapcdb
         WHERE crapcdb.cdcooper = pr_cdcooper
           AND crapcdb.nrdconta = pr_nrdconta
           AND (crapcdb.nrctrlim = pr_nrctrlim OR pr_nrctrlim IS NULL)
           AND crapcdb.insitchq = 2 --Situacao do cheque: 0=nao processado, 1=resgatado, 2=processado.
           AND crapcdb.dtlibera > pr_dtmvtolt; -- Data da liberacao do cheque para credito em conta.

      rw_crapcdb cr_crapcdb244%ROWTYPE;

      -- Busca cartoes de credito em uso data de entrega a partir
      -- do mes do movimento
      CURSOR cr_crawcrd ( pr_cdcooper IN crapcop.cdcooper%TYPE
                         ,pr_nrdconta IN crawcrd.nrdconta%TYPE
                         ,pr_dtentreg IN crawcrd.dtentreg%TYPE) IS
        SELECT crawcrd.cdadmcrd
              ,crawcrd.tpcartao
              ,crawcrd.cdlimcrd
              ,crawcrd.dtmvtolt
              ,crawcrd.nrctrcrd
        FROM   crawcrd
        WHERE  crawcrd.cdcooper = pr_cdcooper
        AND    crawcrd.nrdconta = pr_nrdconta
        AND    crawcrd.dtentreg > pr_dtentreg --Data de entrega do cartão ao associado
        AND    crawcrd.insitcrd = 4; -- Situacao: 0-estudo, 1-aprov., 2-solic., 3-liber., 4-em uso,5-canc.
      --
      rw_crawcrd cr_crawcrd%ROWTYPE;

      -- Busca os cartoes de credito em uso que possuem data de entrega
      -- e não estão cancelados
      CURSOR cr_crawcrd01 ( pr_cdcooper IN crapcop.cdcooper%TYPE
                         ,pr_nrdconta IN crawcrd.nrdconta%TYPE) IS
        SELECT crawcrd.cdadmcrd
              ,crawcrd.tpcartao
              ,crawcrd.cdlimcrd
              ,crawcrd.dtmvtolt
              ,crawcrd.nrctrcrd
        FROM   crawcrd
        WHERE  crawcrd.cdcooper = pr_cdcooper
        AND    crawcrd.nrdconta = pr_nrdconta
        AND    crawcrd.dtentreg IS NOT NULL
        AND    crawcrd.dtcancel IS NULL
        AND    crawcrd.insitcrd = 4;

      -- Tabela de limites de cartao de credito e dias de debito
      CURSOR cr_craptlc ( pr_cdcooper IN crapcop.cdcooper%TYPE
                         ,pr_cdadmcrd IN craptlc.cdadmcrd%TYPE
                         ,pr_tpcartao IN craptlc.tpcartao%TYPE
                         ,pr_cdlimcrd IN craptlc.cdlimcrd%TYPE
                         ) IS
        SELECT craptlc.vllimcrd
        FROM   craptlc
        WHERE  craptlc.cdcooper = pr_cdcooper
        AND    craptlc.cdadmcrd = pr_cdadmcrd -- Codigo da administradora (1-Credicard, 2-Bradesco Visa)
        AND    craptlc.tpcartao = pr_tpcartao -- Tipo de cartao (0, 1-nacional, 2-internacional, 3-gold)
        AND    craptlc.cdlimcrd = pr_cdlimcrd -- Codigo do limite de credito.
        AND    craptlc.dddebito = 0; -- Dia do debito em conta-corrente.
      --
      rw_craptlc cr_craptlc%ROWTYPE;

      -- Cadastro de administradoras de cartoes de credito
      CURSOR cr_crapadc( pr_cdcooper IN crapcop.cdcooper%TYPE
                        ,pr_cdadmcrd IN crapadc.cdadmcrd%TYPE) IS
        SELECT crapadc.nmadmcrd
        FROM   crapadc
        WHERE  crapadc.cdcooper = pr_cdcooper
        AND    crapadc.cdadmcrd = pr_cdadmcrd;
      --
      rw_crapadc cr_crapadc%ROWTYPE;

      -- Busca informacoes dos emprestimos do associado
      CURSOR cr_crapepr( pr_cdcooper IN crapcop.cdcooper%TYPE
                        ,pr_dtmvtolt IN crapepr.dtmvtolt%TYPE DEFAULT NULL
                        ,pr_nrdconta IN crapepr.nrdconta%TYPE) IS
        SELECT crapepr.dtmvtolt
              ,crapepr.inliquid
              ,crapepr.vlemprst
              ,crapepr.vlpreemp
              ,crapepr.qtpreemp
              ,crapepr.vlsdeved
              ,crapepr.nrctremp
          FROM crapepr
         WHERE crapepr.cdcooper = pr_cdcooper
           AND DECODE(pr_dtmvtolt
                    , NULL
                    , crapepr.dtmvtolt
                    , TRUNC(crapepr.dtmvtolt, 'MM')) = DECODE(pr_dtmvtolt
                                                            , NULL
                                                            , crapepr.dtmvtolt
                                                            , TRUNC(pr_dtmvtolt,'MM'))
           AND crapepr.nrdconta = pr_nrdconta
         ORDER BY crapepr.cdcooper
                 ,crapepr.nrdconta
                 ,crapepr.nrctremp;
      --
      rw_crapepr cr_crapepr%ROWTYPE;

      -- Busca os limites de desconto de titulos ativos
      CURSOR cr_craplim03( pr_cdcooper IN craplim.cdcooper%TYPE
                          ,pr_nrdconta IN craplim.nrdconta%TYPE) IS
        SELECT craplim.vllimite
             , craplim.nrctrlim
             , craplim.dtinivig
        FROM   craplim
        WHERE  craplim.cdcooper = pr_cdcooper
        AND    craplim.nrdconta = pr_nrdconta
        AND    craplim.tpctrlim = 3 -- Tipo de contrato: 1-Chq Esp. / 2-Desc Chq. / 3-Desc Tit.
        AND    craplim.insitlim = 2;-- Situacao 1-estudo, 2-ativo, 3-cancelado
      rw_craplim03 cr_craplim03%ROWTYPE;

      -- Busca os limites de desconto de titulos de desconto de cheques ativos
      CURSOR cr_craplim04( pr_cdcooper IN crapcop.cdcooper%TYPE
                          ,pr_nrdconta IN craplim.nrdconta%TYPE) IS
        SELECT craplim.vllimite
             , craplim.nrctrlim
             , craplim.dtinivig
        FROM   craplim
        WHERE  craplim.cdcooper = pr_cdcooper
        AND    craplim.nrdconta = pr_nrdconta
        AND    craplim.tpctrlim = 2 -- Tipo de contrato: 1-Chq Esp. / 2-Desc Chq. / 3-Desc Tit.
        AND    craplim.insitlim = 2 -- Situacao 1-estudo, 2-ativo, 3-cancelado
        ORDER BY progress_recid;
      rw_craplim04 cr_craplim04%ROWTYPE;


      ---------------------------- ESTRUTURAS DE REGISTRO ---------------------

      ------------------------------- VARIAVEIS -------------------------------

      --------------------------- SUBROTINAS INTERNAS --------------------------
      -- Função para retornar informações complementares para a linha
      FUNCTION fn_texto_comple_pa(pr_cdagenci   IN crapage.cdagenci%TYPE
                                 ,pr_invigope   IN NUMBER
                                 ,pr_dtvigope   IN DATE
                                 ,pr_inconpro   IN NUMBER
                                 ,pr_nrconpro   IN NUMBER   ) RETURN VARCHAR2 IS
        vr_dsreturn   VARCHAR2(200);
      BEGIN
        -- Agencia
        vr_dsreturn := 'PA:'||lpad(pr_cdagenci,5,' ');

        -- Verifica se deve imprimir vigencia ou operação
        IF    pr_invigope = 1 THEN
          -- Data Vigencia
          vr_dsreturn := vr_dsreturn||'  INI.VIGENCIA: '||to_char(pr_dtvigope,'DD/MM/YYYY');
        ELSIF pr_invigope = 2 THEN
          -- Data operação
          vr_dsreturn := vr_dsreturn||'  DATA OPERAC.: '||to_char(pr_dtvigope,'DD/MM/YYYY');
        END IF;

        -- Verifica se deve imprimir contrato ou proposta
        IF    pr_inconpro = 1 THEN
          -- Contrato
          vr_dsreturn := vr_dsreturn||' NR.CONTRATO:'||LPAD(to_char(pr_nrconpro,'FM99G999G990'),10,' ');
        ELSIF pr_inconpro = 2 THEN
          -- Proposta
          vr_dsreturn := vr_dsreturn||' NR.PROPOSTA:'||LPAD(to_char(pr_nrconpro,'FM999G999G990'),10,' ');
        END IF;

        -- RETORNA O TEXTO JÁ FORMADO
        RETURN vr_dsreturn;
      END;
      -- Procedure que escreve linha no arquivo CLOB
      -- utiliza-se o mesmo procedimento para gerar os dois relatorios
	    PROCEDURE pc_escreve_xml(pr_tprel VARCHAR2, pr_des_dados IN VARCHAR2) IS
      BEGIN
        IF pr_tprel = 'CRRL244' THEN
          --Escrever no arquivo CLOB
          dbms_lob.writeappend(vr_crrl244_xml, length(pr_des_dados),pr_des_dados);
        ELSE
          --Escrever no arquivo CLOB
          dbms_lob.writeappend(vr_crrl394_xml, length(pr_des_dados),pr_des_dados);
        END IF;
      END;

    BEGIN
      --------------- VALIDACOES INICIAIS -----------------

      -- Incluir nome do módulo logado
      GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra
                                ,pr_action => null);
      -- Verifica se a cooperativa esta cadastrada
      OPEN cr_crapcop;
      FETCH cr_crapcop INTO rw_crapcop;
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
      FETCH btch0001.cr_crapdat INTO rw_crapdat;
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

      -- Busca o último dia do mes anterior a data do movimento
      vr_datamvto := TRUNC(rw_crapdat.dtmvtolt, 'MONTH')-1;

      -- Mês/ano referencia que será exibido no relatório
      vr_nmmesref := GENE0001.vr_vet_nmmesano(to_char(rw_crapdat.dtmvtolt,'MM'))||'/'||to_char(rw_crapdat.dtmvtolt,'YYYY');

      -- Inicializar o CLOB para o relatorio crrl244
      dbms_lob.createtemporary(vr_crrl244_xml, TRUE);
      dbms_lob.open(vr_crrl244_xml, dbms_lob.lob_readwrite);

      -- Inicializar o CLOB para o relatorio crrl394
      dbms_lob.createtemporary(vr_crrl394_xml, TRUE);
      dbms_lob.open(vr_crrl394_xml, dbms_lob.lob_readwrite);

      -- Busca o diretorio da cooperativa conectada
      vr_caminho_cooper := gene0001.fn_diretorio(pr_tpdireto => 'C' --> Usr/Coop
                                                 ,pr_cdcooper => pr_cdcooper
                                                 ,pr_nmsubdir => '');

      -- inicializando a geração do xml para o relatorio crrl244
      pc_escreve_xml('CRRL244', '<?xml version="1.0" encoding="utf-8"?><crrl244>');
      -- inicializando a geração do xml para o relatorio crrl394
      pc_escreve_xml('CRRL394', '<?xml version="1.0" encoding="utf-8"?><crrl394>');

      -- Percorre o cursor de cooperados
      OPEN cr_crapass(pr_cdcooper => pr_cdcooper);
      LOOP
        FETCH cr_crapass INTO rw_crapass;
        EXIT WHEN cr_crapass%NOTFOUND;

        -- inicializando variáveis de controle
        vr_totcredi := 0;
        vr_ttslddev := 0;
        vr_deslimit := NULL;
        -- variavel para armazenar o corpo do xml
        vr_detalhe  := NULL;
        -- variavel de controle para indicar repeticao de registros
        -- e controlar a impressao dos labels
        vr_seq      := 1;

        -------------------------------------------------
        -- INICIANDO CRRL244
        -------------------------------------------------

        -- Busca os limites de crédito de cheque especial do associado com
        -- vigencia iniciando no mes do processamento (dtmvtolt)
        OPEN cr_craplim( pr_cdcooper => pr_cdcooper
                        ,pr_nrdconta => rw_crapass.nrdconta
                        ,pr_tpctrlim => 1 --Tipo de contrato: 1-Chq Esp. / 2-Desc Chq. / 3-Desc Tit.
                        ,pr_dtinivig => vr_datamvto);
        LOOP
          FETCH cr_craplim INTO rw_craplim;
          EXIT WHEN cr_craplim%NOTFOUND;

          -- Verifica se a base do limite eh sobre
          -- 1 - cotas de capital ou 2 - cadastral
          IF rw_craplim.inbaslim = 1 THEN
            vr_deslimit := 'COTAS DE CAPITAL';
          ELSE
            vr_deslimit := 'CADASTRAL';
          END IF;

          -- se a situacao do limite eh diferente de ativo
          IF rw_craplim.insitlim <> 2 THEN
            vr_deslimit := vr_deslimit || ' (CANCELADO)';
          END IF;

          -- se a situacao estiver ativa, acumula o limite
          IF rw_craplim.insitlim = 2 THEN
            vr_totcredi := nvl(rw_craplim.vllimite,0);
          END IF;

          -- montando o registro detalhe
          vr_detalhe := vr_detalhe||'<tipo dstipo="LIMITE"><detalhe>'||
                                          ' LIMITE CRED.:'||lpad(to_char(rw_craplim.vllimite,'fm999G999G990D00'),13,' ')||
                                          ' TIPO:  '||rpad(vr_deslimit,38,' ')||
                                          ' PA:'||lpad(rw_crapass.cdagenci,5,' ')||
                                          '  INI.VIGENCIA: '||to_char(rw_craplim.dtinivig,'dd/mm/yyyy')||
                                          ' NR.CONTRATO:'||lpad(to_char(rw_craplim.nrctrlim,'fm9G999G990'),10,' ')||
                                          '</detalhe></tipo>';

          -- incrementa o controle de registros
          vr_seq := vr_seq + 1;
        END LOOP;--OPEN cr_craplim( pr_cdcooper => pr_cdcooper
        -- fecha o cursor
        CLOSE cr_craplim;

        -- limpa o conteúdo da situação
        vr_dssituac := NULL;
        -- inicializa o controle de impressao do label
        vr_seq := 1;

        -- limites desconto de titulos
        -- Busca os limites de crédito de desconto de titulos
        -- do associado com vigencia iniciando no mes do processamento (dtmvtolt)
        OPEN cr_craplim( pr_cdcooper => pr_cdcooper
                        ,pr_nrdconta => rw_crapass.nrdconta
                        ,pr_tpctrlim => 3 --Tipo de contrato: 1-Chq Esp. / 2-Desc Chq. / 3-Desc Tit.
                        ,pr_dtinivig => vr_datamvto);
        LOOP
          FETCH cr_craplim INTO rw_craplim;
          EXIT WHEN cr_craplim%NOTFOUND;

          -- se a situacao diferente de 2-Ativo
          IF rw_craplim.insitlim <> 2 THEN
            vr_dssituac := '(CANCELADO)';
          ELSE
            vr_dssituac := NULL;
          END IF;

          -- acumula o valor do limite
          vr_vllimite := nvl(rw_craplim.vllimite,0);
          vr_vlrutili := 0;

          /* Titulos que estao em uso */
          -- Busca os títulos liberados com vencimento no dia e
          -- os titulos pagos no dia pelo associado
          OPEN cr_craptdb( pr_cdcooper => pr_cdcooper
                          ,pr_nrdconta => rw_crapass.nrdconta
                          ,pr_nrctrlim => rw_craplim.nrctrlim
                          ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                          ,pr_flgtprel => 244);
          LOOP
            FETCH cr_craptdb INTO rw_craptdb;
            EXIT WHEN cr_craptdb%NOTFOUND;

            OPEN cr_crapcob ( pr_cdcooper => pr_cdcooper
                             ,pr_cdbandoc => rw_craptdb.cdbandoc
                             ,pr_nrdctabb => rw_craptdb.nrdctabb
                             ,pr_nrcnvcob => rw_craptdb.nrcnvcob
                             ,pr_nrdconta => rw_craptdb.nrdconta
                             ,pr_nrdocmto => rw_craptdb.nrdocmto);
            FETCH cr_crapcob INTO rw_crapcob;

            -- se não tem informações gera log e vai para o proximo registro
            IF cr_crapcob%NOTFOUND THEN
              -- fecha o cursor
              CLOSE cr_crapcob;

              -- montando a mensagem que será grava no log
              vr_dscritic := 'Titulo em desconto nao encontrado no crapcob - ROWID(craptdb) = '||
                              rw_craptdb.rowid;
              -- gerando log de erro
              btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                        ,pr_ind_tipo_log => 2 -- Erro tratato
                                        ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                         || vr_cdprogra || ' --> '
                                                         || vr_dscritic );
              -- limpa a variável de crítica
              vr_dscritic := NULL;

              -- vai para o proximo registro
              CONTINUE;
            END IF;
            -- fecha o cursor
            CLOSE cr_crapcob;

            /*  Se foi pago via CAIXA, InternetBank ou TAA
                Despreza, pois ja esta pago, o dinheiro
                ja entrou para a cooperativa */
            IF rw_craptdb.insittit = 2  AND
               (rw_crapcob.indpagto IN (1,3,4)) THEN  /** TAA **/
              -- vai para o proximo registro
              CONTINUE;
            END IF;
            -- acumulando o valor total
            vr_vlrutili := nvl(vr_vlrutili,0) + nvl(rw_craptdb.vltitulo,0);

          END LOOP;--OPEN cr_craptdb( pr_cdcooper => pr_cdcooper
          -- fecha o cursor
          CLOSE cr_craptdb;

          -- se estiver ativo acumula o valor do limite
          IF rw_craplim.insitlim = 2  THEN  /* Ativo */
            vr_totcredi := nvl(vr_totcredi,0) + nvl(vr_vllimite,0);
          END IF;

          -- totaliza o saldo devedor
          vr_ttslddev := nvl(vr_ttslddev,0) + nvl(vr_vlrutili,0);

          -- montando o registro detalhe
          -- se eh o primeiro registro de limite, imprime o label
          -- senao, gera somente os valores sem o label
          IF vr_seq = 1 THEN
            vr_detalhe := vr_detalhe||'<tipo dstipo="TITULO"><detalhe>'||
                                            ' LIMITE DSC. TIT.:'||lpad(NVL(to_char(vr_vllimite,'fm99G990D00'),' '),9,' ')||
                                            rpad(nvl(vr_dssituac,' '),11,' ')||
                                            'VLR.UTILIZADO: '||lpad(to_char(vr_vlrutili,'fm999G999G990D00'),15,' ')||
                                            '       PA:'||lpad(rw_crapass.cdagenci,3,' ')||
                                            '  INI.VIGENCIA: '||to_char(rw_craplim.dtinivig,'dd/mm/yyyy')||
                                            ' NR.CONTRATO:'||lpad(to_char(rw_craplim.nrctrlim,'fm9G999G990'),10,' ')||
                                            '</detalhe></tipo>';
          ELSE
            vr_detalhe := vr_detalhe||'<tipo dstipo="TITULO"><detalhe>'||
                                            lpad(to_char(vr_vllimite,'fm999G999G990D00'),27,' ')||
                                            rpad(nvl(vr_dssituac,' '),11,' ')||
                                            lpad(' ',15,' ')||
                                            lpad(to_char(vr_vlrutili,'fm999G999G990D00'),15,' ')||
                                            '       PA:'||lpad(rw_crapass.cdagenci,3,' ')||
                                            '  INI.VIGENCIA: '||to_char(rw_craplim.dtinivig,'dd/mm/yyyy')||
                                            ' NR.CONTRATO:'||lpad(to_char(rw_craplim.nrctrlim,'fm9G999G990'),10,' ')||
                                            '</detalhe></tipo>';
          END IF;
          -- incrementa o controle de registros
          vr_seq := vr_seq + 1;

        END LOOP;--OPEN cr_craplim( pr_cdcooper => pr_cdcooper
        -- fecha o cursor
        CLOSE cr_craplim;

        -- limpa o conteúdo da variável
        vr_dssituac := NULL;
        -- inicializa a variavel de controle de labels
        vr_seq := 1;

        -- Busca os limites de crédito de desconto de cheques
        -- do associado com vigencia iniciando no mes do processamento (dtmvtolt)
        OPEN cr_craplim( pr_cdcooper => pr_cdcooper
                        ,pr_nrdconta => rw_crapass.nrdconta
                        ,pr_tpctrlim => 2
                        ,pr_dtinivig => vr_datamvto);
        LOOP
          FETCH cr_craplim INTO rw_craplim;
          EXIT WHEN cr_craplim%NOTFOUND;

          -- Se a situacao é diferente de ativo, marca como cancelado
          IF rw_craplim.insitlim <> 2  THEN
            vr_dssituac := '(CANCELADO)';
          ELSE
            vr_dssituac := NULL;
          END IF;

          -- armazenando o valor do limite
          vr_vllimite := nvl(rw_craplim.vllimite,0);

          -- inicializando o valor utilizado
          vr_vlrutili := 0;

          -- Busca o valor total dos cheques contidos do Bordero de desconto de cheques
          -- que ja foram processados e pendentes de liberação
          OPEN cr_crapcdb244 ( pr_cdcooper => pr_cdcooper
                           ,pr_nrdconta => rw_crapass.nrdconta
                           ,pr_nrctrlim => rw_craplim.nrctrlim
                           ,pr_dtmvtolt => rw_crapdat.dtmvtolt);
          FETCH cr_crapcdb244 INTO rw_crapcdb;
          -- fecha o cursor
          CLOSE cr_crapcdb244;

          -- totalizando o valor utilizado
          vr_vlrutili := nvl(vr_vlrutili,0) + rw_crapcdb.vlcheque;

          -- se estiver ativo, acumula no totalizador
          IF rw_craplim.insitlim = 2 THEN  /* Ativo */
            vr_totcredi := nvl(vr_totcredi,0) + nvl(vr_vllimite,0);
          END IF;

          -- totalizando
          vr_ttslddev := nvl(vr_ttslddev,0) + nvl(vr_vlrutili,0);

          -- montando o registro detalhe
          -- se eh o primeiro registro de limite, imprime o label
          -- senao, gera somente os valores sem o label
          IF vr_seq = 1 THEN
            vr_detalhe := vr_detalhe||'<tipo dstipo="CHEQUE"><detalhe>'||
                                            ' LIMITE DSC.CHQ.:'||lpad(NVL(to_char(vr_vllimite,'fm99G990D00'),' '),10,' ')||
                                            rpad(nvl(vr_dssituac,' '),11,' ')||
                                            'VLR.UTILIZADO: '||lpad(to_char(vr_vlrutili,'fm999G999G990D00'),15,' ')||
                                            '       PA:'||lpad(rw_crapass.cdagenci,3,' ')||
                                            '  INI.VIGENCIA: '||to_char(rw_craplim.dtinivig,'dd/mm/yyyy')||
                                            ' NR.CONTRATO:'||lpad(to_char(rw_craplim.nrctrlim,'fm9G999G990'),10,' ')||
                                            '</detalhe></tipo>';
          ELSE
            vr_detalhe := vr_detalhe||'<tipo dstipo="CHEQUE"><detalhe>'||
                                            lpad(to_char(vr_vllimite,'fm999G999G990D00'),27,' ')||
                                            rpad(nvl(vr_dssituac,' '),11,' ')||
                                            lpad(' ',15,' ')||
                                            lpad(to_char(vr_vlrutili,'fm999G999G990D00'),15,' ')||
                                            '       PA:'||lpad(rw_crapass.cdagenci,3,' ')||
                                            '  INI.VIGENCIA: '||to_char(rw_craplim.dtinivig,'dd/mm/yyyy')||
                                            ' NR.CONTRATO:'||lpad(to_char(rw_craplim.nrctrlim,'fm9G999G990'),10,' ')||
                                            '</detalhe></tipo>';
          END IF;
          -- incrementa o controle de registros
          vr_seq := vr_seq + 1;

        END LOOP;--OPEN cr_craplim( pr_cdcooper => pr_cdcooper
        -- fecha o cursor
        CLOSE cr_craplim;

        -- inicializando a variáveis
        vr_flgexist := FALSE;
        -- inicializa a variavel de controle de labels
        vr_seq := 1;

        /* pesquisa cartoes de credito */
        -- Busca cartoes de credito em uso com data de entrega
        -- a partir do mes do movimento
        OPEN cr_crawcrd ( pr_cdcooper => pr_cdcooper
                         ,pr_nrdconta => rw_crapass.nrdconta
                         ,pr_dtentreg => vr_datamvto);
        LOOP
          FETCH cr_crawcrd INTO rw_crawcrd;
          EXIT WHEN cr_crawcrd%NOTFOUND;

          -- inicializando os rowtypes
          rw_craptlc := NULL;
          rw_crapadc := NULL;

          -- limites do cartao de credito
          OPEN cr_craptlc ( pr_cdcooper => pr_cdcooper
                           ,pr_cdadmcrd => rw_crawcrd.cdadmcrd
                           ,pr_tpcartao => rw_crawcrd.tpcartao
                           ,pr_cdlimcrd => rw_crawcrd.cdlimcrd);
          FETCH cr_craptlc INTO rw_craptlc;
          -- fecha o cursor
          CLOSE cr_craptlc;

          -- Cadastro de administradoras de cartoes de credito
          OPEN cr_crapadc( pr_cdcooper => pr_cdcooper
                          ,pr_cdadmcrd => rw_crawcrd.cdadmcrd);
          FETCH cr_crapadc INTO rw_crapadc;
          -- fecha o cursor
          CLOSE cr_crapadc;

          -- totalizando
          vr_totcredi := nvl(vr_totcredi,0) + nvl(rw_craptlc.vllimcrd,0);

          vr_detalhe := vr_detalhe||'<tipo dstipo="CARTAO"><detalhe>';

          -- montando o registro detalhe
          -- se eh o primeiro registro de limite, imprime o label
          -- senao, gera somente os valores sem o label
          IF vr_seq = 1 THEN
            vr_detalhe := vr_detalhe||' CARTAO CRED:'||lpad(NVL(to_char(rw_craptlc.vllimcrd,'fm999G999G990D00'),' '),14,' ')||
                                      ' ADMINISTRADORA: ';
          ELSE
            vr_detalhe := vr_detalhe||lpad(NVL(to_char(rw_craptlc.vllimcrd,'fm999G999G990D00'),' '),44,' ');
          END IF;

          vr_detalhe := vr_detalhe|| rpad(NVL(substr(rw_crapadc.nmadmcrd,1,15),' '),30,' ')||
                                     'PA:'||lpad(rw_crapass.cdagenci,3,' ')||
                                     '    DATA OPERAC.: '||lpad(NVL(to_char(rw_crawcrd.dtmvtolt,'dd/mm/yyyy'),' '),10,' ')||
                                     ' NR.PROPOSTA:'||lpad(to_char(rw_crawcrd.nrctrcrd,'FM999G990'),10,' ')||
                                     '</detalhe></tipo>';

          -- indica que o relatóri possui registro de desconto de cheques
          vr_flgexist := TRUE;

          -- incrementa o controle de registros
          vr_seq := vr_seq + 1;
        END LOOP;--OPEN cr_crawcrd ( pr_cdcooper => pr_cdcooper
        CLOSE cr_crawcrd;

        /* pesquisa emprestimos */
        vr_flgexist := FALSE;

        -- inicializa o controle de labels
        vr_seq := 1;

        -- Emprestimos do associado
        OPEN cr_crapepr( pr_cdcooper => pr_cdcooper
                        ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                        ,pr_nrdconta => rw_crapass.nrdconta);
        LOOP
          FETCH cr_crapepr INTO rw_crapepr;
          EXIT WHEN cr_crapepr%NOTFOUND;

          -- se a data de movimento do emprestimo estiver dentro do mes atual
          -- e esteja ativo "inliquid = 0" (0=ativo, 1=liquid.)
          IF rw_crapepr.dtmvtolt > vr_datamvto AND
             rw_crapepr.inliquid = 0  THEN

            -- montando o registro detalhe
            -- se eh o primeiro registro de limite, imprime o label
            -- senao, gera somente os valores sem o label
            IF vr_seq = 1 THEN
              vr_detalhe := vr_detalhe||'<tipo dstipo="EMPRESTIMO"><detalhe>'||
                                              ' EMPRESTIMO:'||lpad(NVL(to_char(rw_crapepr.vlemprst,'fm999G999G990D00'),' '),15,' ')||
                                              lpad('PRESTACAO:',10,' ')||
                                              ' '||lpad(to_char(rw_crapepr.vlpreemp,'fm999G999G990D00'),15,' ')||
                                              ' '||lpad('QTD.PREST:',10,' ')||
                                              ' '||lpad(rw_crapepr.qtpreemp,4,' ')||
                                              '       PA:'||lpad(rw_crapass.cdagenci,3,' ')||
                                              '  INI.VIGENCIA: '||to_char(rw_crapepr.dtmvtolt,'dd/mm/yyyy')||
                                              ' NR.CONTRATO:'||lpad(to_char(rw_crapepr.nrctremp,'fm99G999G990'),10,' ')||
                                              '</detalhe></tipo>';
            ELSE
              vr_detalhe := vr_detalhe||'<tipo dstipo="EMPRESTIMO"><detalhe>'||
                                              lpad(to_char(rw_crapepr.vlemprst,'fm999G999G990D00'),27,' ')||
                                              ' '||lpad(' ',10,' ')||
                                              ' '||lpad(to_char(rw_crapepr.vlpreemp,'fm999G999G990D00'),15,' ')||
                                              ' '||lpad(' ',10,' ')||
                                              ' '||lpad(rw_crapepr.qtpreemp,4,' ')||
                                              '       PA:'||lpad(rw_crapass.cdagenci,3,' ')||
                                              '  INI.VIGENCIA: '||to_char(rw_crapepr.dtmvtolt,'dd/mm/yyyy')||
                                              ' NR.CONTRATO:'||lpad(to_char(rw_crapepr.nrctremp,'fm99G999G990'),10,' ')||
                                              '</detalhe></tipo>';
            END IF;
            -- totalizando
            vr_totcredi := nvl(vr_totcredi,0) + nvl(rw_crapepr.vlemprst,0);

            -- indica que existe registro de emprestimo
            vr_flgexist := TRUE;

            -- incrementa o controle de registros
            vr_seq := vr_seq + 1;
          END IF;

          -- se o emprestimo estiver ativo, totaliza o saldo devedor
          IF rw_crapepr.inliquid = 0 THEN
            vr_ttslddev := nvl(vr_ttslddev,0) + nvl(rw_crapepr.vlsdeved,0);
          END IF;

        END LOOP; --OPEN cr_crapepr( pr_cdcooper => pr_cdcooper
        -- fecha o cursor
        CLOSE cr_crapepr;

        -- se tem informacoes, gera o registro do associado
        IF vr_detalhe IS NOT NULL THEN
          -- gerando o xml ref. ao relatorio crrl244
          pc_escreve_xml('CRRL244', '<crapass id="'||rw_crapass.nrdconta||'" '||
                                       'nmprimtl="'||rw_crapass.nmprimtl||'" '||
                                       'desvincu="'||rw_crapass.desvincu||'" '||
                                       'nrdconta="'||gene0002.fn_mask_conta(rw_crapass.nrdconta)||'" ');

          -- se o total do credito é maior que zero imprime
          -- senao apenas limpa as linhas
          IF vr_totcredi > 0 THEN
            pc_escreve_xml('CRRL244', 'dslinha="'||lpad(' ',18,' ')||lpad('-',15,'-')||'" '||
                                      'dstotal="'||lpad(' ',18,' ')
                                                 ||lpad(to_char(vr_totcredi,'fm999G999G990D00'),15,' ')
                                                 ||'       SALDO DEVEDOR ATUAL: '
                                                 ||lpad(to_char(vr_ttslddev,'fm999G999G990D00'),15,' ')
                                                 ||'">');
          ELSE
            pc_escreve_xml('CRRL244', 'dslinha="" dstotal="">');
          END IF;

          -- finaliza o xml
          pc_escreve_xml('CRRL244', vr_detalhe||'</crapass>');
        END IF;

        -- inicializando variáveis de controle
        vr_totcredi394 := 0;
        vr_ttslddev394 := 0;
        vr_detalhe394  := NULL;
        -- inicializa o controle de labels
        vr_seq         := 1;
        -------------------------------------------------
        -- INICIANDO CRRL394
        -------------------------------------------------
        -- Busca os limites de crédito vigentes do associado
        OPEN cr_craplim394( pr_cdcooper => pr_cdcooper
                           ,pr_nrdconta => rw_crapass.nrdconta
                           ,pr_tpctrlim => 1);
        LOOP
          FETCH cr_craplim394 INTO rw_craplim394;
          EXIT WHEN cr_craplim394%NOTFOUND;
          -- verifica se a base do limite é sobre as 1-Cotas de capital
          -- ou 2-cadastral
          IF rw_craplim394.inbaslim = 1 THEN
            vr_deslimit := 'COTAS DE CAPITAL';
          ELSE
            vr_deslimit := 'CADASTRAL';
          END IF;

          -- se é diferente de ativo, marca como cancelado
          IF rw_craplim394.insitlim <> 2 THEN
            vr_deslimit := vr_deslimit || ' (CANCELADO)';
          END IF;

          /*  Ativo  */
          IF rw_craplim394.insitlim = 2 THEN
            vr_totcredi394 := nvl(rw_craplim394.vllimite,0);
          END IF;

          -- montando o registro detalhe
          vr_detalhe394 := vr_detalhe394||'<tipo dstipo="LIMITE"><detalhe>';

          -- se eh o primeiro registro de limite, imprime o label
          -- senao, gera somente os valores sem o label
          IF vr_seq = 1 THEN
            vr_detalhe394 := vr_detalhe394||' LIMITE CRED.: ';
            vr_dslabel1 := 'TIPO: ';
          ELSE
            vr_detalhe394 := vr_detalhe394||lpad(' ',15,' ');
            -- Define Label
            vr_dslabel1 := '      ';
          END IF;

          vr_detalhe394 := vr_detalhe394||lpad(to_char(rw_craplim394.vllimite,'fm9G999G990D00'),12,' ')||
                                          ' '||vr_dslabel1||' '||RPAD(vr_deslimit,39,' ')||
                                          fn_texto_comple_pa(rw_crapass.cdagenci
                                                            ,1 ,rw_craplim394.dtinivig
                                                            ,1 ,rw_craplim394.nrctrlim)||
                                          '</detalhe></tipo>';

          -- incrementa o controle de registros
          vr_seq := vr_seq + 1;
        END LOOP;--OPEN cr_craplim( pr_cdcooper => pr_cdcooper
        -- fecha o cursor
        CLOSE cr_craplim394;

        /*  pesquisa limite desconto de titulo  */
        vr_flgexist := FALSE;

        -- Busca os limites de desconto de titulos ativos
        OPEN cr_craplim03( pr_cdcooper => pr_cdcooper
                          ,pr_nrdconta => rw_crapass.nrdconta);
        FETCH cr_craplim03 INTO rw_craplim03;
        -- se existir informacao guarda o valor, se não zera
        IF cr_craplim03%FOUND THEN
          -- armazena o limite
          vr_vllimite := rw_craplim03.vllimite;
          -- marcando que exite registros
          vr_flgexist := TRUE;
        ELSE
          vr_vllimite := 0;
        END IF;
        -- fechando o cursor
        CLOSE cr_craplim03;

        -- limpa a descricao da situacao
        vr_dssituac := NULL;

        -- inicializando o valor utilizado
        vr_vlrutili := 0;

        /* Titulos que estao em uso */
        -- Busca os títulos liberados com vencimento no dia e
        -- os titulos pagos no dia pelo associado
        OPEN cr_craptdb( pr_cdcooper => pr_cdcooper
                        ,pr_nrdconta => rw_crapass.nrdconta
                        ,pr_nrctrlim => NULL
                        ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                        ,pr_flgtprel => 394);
        LOOP
          FETCH cr_craptdb INTO rw_craptdb;
          EXIT WHEN cr_craptdb%NOTFOUND;

          -- verifica se o titulo está no bordero de titulos
          OPEN cr_crapcob ( pr_cdcooper => pr_cdcooper
                           ,pr_cdbandoc => rw_craptdb.cdbandoc
                           ,pr_nrdctabb => rw_craptdb.nrdctabb
                           ,pr_nrcnvcob => rw_craptdb.nrcnvcob
                           ,pr_nrdconta => rw_craptdb.nrdconta
                           ,pr_nrdocmto => rw_craptdb.nrdocmto);
          FETCH cr_crapcob INTO rw_crapcob;

          -- se não tem informações gera log e vai para o proximo registro
          IF cr_crapcob%NOTFOUND THEN
            -- fecha o cursor
            CLOSE cr_crapcob;
            -- montando a mensagem que será grava no log
            vr_dscritic := 'Titulo em desconto nao encontrado no crapcob - ROWID(craptdb) = '||
                            rw_craptdb.rowid;
            -- gerando log de erro
            btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                      ,pr_ind_tipo_log => 2 -- Erro tratato
                                      ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                       || vr_cdprogra || ' --> '
                                                       || vr_dscritic );
            -- limpa a variável de crítica
            vr_dscritic := NULL;

            -- vai para o proximo registro
            CONTINUE;
          END IF;
          -- fecha o cursor
          CLOSE cr_crapcob;

          /*  Se foi pago via CAIXA, InternetBank ou TAA
              Despreza, pois ja esta pago, o dinheiro
              ja entrou para a cooperativa */
          IF rw_craptdb.insittit = 2  AND
             (rw_crapcob.indpagto = 1  OR
              rw_crapcob.indpagto = 3  OR
              rw_crapcob.indpagto = 4) THEN  /** TAA **/
            -- vai para o proximo registro
            CONTINUE;
          END IF;
          -- acumulando o valor total
          vr_vlrutili := nvl(vr_vlrutili,0) + nvl(rw_craptdb.vltitulo,0);
          -- indica que tem informacoes
          vr_flgexist := TRUE;

        END LOOP;--OPEN cr_craptdb( pr_cdcooper => pr_cdcooper
        -- fecha o cursor
        CLOSE cr_craptdb;

        -- se tem informações de desconto, monta o xml
        IF vr_flgexist THEN
          vr_detalhe394 := vr_detalhe394||'<tipo dstipo="TITULO"><detalhe>'||
                                        ' LIMITE DSC.TIT.:'||
                                        lpad(to_char(vr_vllimite,'fm999G990D00'),10,' ')||
                                        lpad('VLR.UTILIZADO:',30,' ')||
                                        lpad(to_char(vr_vlrutili,'fm999G999G990D00'),16,' ')||' '||
                                        fn_texto_comple_pa(rw_crapass.cdagenci
                                                          ,1 ,rw_craplim03.dtinivig
                                                          ,1 ,rw_craplim03.nrctrlim)||
                                        '</detalhe></tipo>';

		      -- totaliza o valor de creditos
          vr_totcredi394 := nvl(vr_totcredi394,0) + nvl(vr_vllimite,0);
          -- totaliza o valor utilizado
          vr_ttslddev394 := nvl(vr_ttslddev394,0) + nvl(vr_vlrutili,0);
		    END IF;--IF vr_flgexist THEN

        /*  pesquisa limite desconto de cheque  */
        -- LIMITE DSC.CHQ.:
        vr_flgexist := FALSE;

        -- Busca os limites de desconto de titulos de desconto de cheques ativos
        OPEN cr_craplim04 ( pr_cdcooper => pr_cdcooper
                           ,pr_nrdconta => rw_crapass.nrdconta);
        FETCH cr_craplim04 INTO rw_craplim04;

        -- verifica se retornou registros e armazena o valor do limite
        IF cr_craplim04%FOUND THEN
          vr_vllimite := rw_craplim04.vllimite;
          vr_flgexist := TRUE;
        ELSE
          vr_vllimite := 0;
        END IF;
        -- fecha o cursor
        CLOSE cr_craplim04;

        -- inicializa a variavel da situacao
        vr_dssituac := NULL;

        -- inicializa o valor utilizado
        vr_vlrutili := 0;

        /* Verifica Valor Utilizado */
        -- busca o valor total dos cheques
        OPEN cr_crapcdb394 ( pr_cdcooper => pr_cdcooper
                            ,pr_nrdconta => rw_crapass.nrdconta
                            ,pr_nrctrlim => NULL
                            ,pr_dtmvtolt => rw_crapdat.dtmvtolt);
        FETCH cr_crapcdb394 INTO rw_crapcdb;

        -- fecha o cursor
        CLOSE cr_crapcdb394;

        -- acumula o valor utilizado
        vr_vlrutili := nvl(vr_vlrutili,0) + nvl(rw_crapcdb.vlcheque,0);

        -- se tem registros de cheques
        IF vr_flgexist THEN

          -- montando o registro detalhe
          vr_detalhe394 := vr_detalhe394||'<tipo dstipo="CHEQUE"><detalhe>'||
                                          ' LIMITE DSC.CHQ.:'||
                                          lpad(to_char(vr_vllimite,'fm999G990D00'),10,' ')||
                                          lpad('VLR.UTILIZADO:',30,' ')||
                                          lpad(to_char(vr_vlrutili,'fm999G999G990D00'),16,' ')||' '||
                                          fn_texto_comple_pa(rw_crapass.cdagenci
                                                            ,1 ,rw_craplim04.dtinivig
                                                            ,1 ,rw_craplim04.nrctrlim)||
                                          '</detalhe></tipo>';

          -- totaliza o valor de creditos
          vr_totcredi394 := nvl(vr_totcredi394,0) + nvl(vr_vllimite,0);
          -- totaliza o valor utilizado
          vr_ttslddev394 := nvl(vr_ttslddev394,0) + nvl(vr_vlrutili,0);
        END IF;

        -- inicializa a variavel de controle de labels
        vr_seq := 1;

        /* pesquisa cartoes de credito */
        -- Busca os cartoes de credito em uso que possuem data de entrega
        -- e não estão cancelados
        OPEN cr_crawcrd01( pr_cdcooper => pr_cdcooper
                          ,pr_nrdconta => rw_crapass.nrdconta);
        LOOP
          FETCH cr_crawcrd01 INTO rw_crawcrd;
          EXIT WHEN cr_crawcrd01%NOTFOUND;

          -- inicializando os rowtypes com null, pois se não encontrar nenhum
          -- registro na abertura do cursor, os rowtypes permanecem com os
          -- valores anteriores
          rw_craptlc := NULL;
          rw_crapadc := NULL;

          -- busca o limite do cartao de credito pelo codigo do limite
          OPEN cr_craptlc ( pr_cdcooper => pr_cdcooper
                           ,pr_cdadmcrd => rw_crawcrd.cdadmcrd
                           ,pr_tpcartao => rw_crawcrd.tpcartao
                           ,pr_cdlimcrd => rw_crawcrd.cdlimcrd);
          FETCH cr_craptlc INTO rw_craptlc;
          -- fechando o cursor
          CLOSE cr_craptlc;

          -- Cadastro de administradoras de cartoes de credito
          OPEN cr_crapadc( pr_cdcooper => pr_cdcooper
                          ,pr_cdadmcrd => rw_crawcrd.cdadmcrd);
          FETCH cr_crapadc INTO rw_crapadc;
          CLOSE cr_crapadc;

          -- totalizando o valor dos creditos
          vr_totcredi394 := nvl(vr_totcredi394,0) + nvl(rw_craptlc.vllimcrd,0);

          -- se eh o primeiro registro de limite, imprime o label
          -- senao, gera somente os valores sem o label
          IF vr_seq = 1 THEN
            -- Montar os labels
            vr_dslabel1 := ' CARTAO CRED.:';
            vr_dslabel2 := ' ADMINISTRADORA: ';
          ELSE
            -- Montar os labels
            vr_dslabel1 := '              ';
            vr_dslabel2 := '                 ';
          END IF;

          -- montando o registro detalhe
          vr_detalhe394 := vr_detalhe394||'<tipo dstipo="CARTAO"><detalhe>'||
                                            vr_dslabel1||
                                            lpad(to_char(rw_craptlc.vllimcrd,'fm99G999G990D00'),13,' ')||
                                            vr_dslabel2||
                                            rpad(substr(rw_crapadc.nmadmcrd,1,15),30,' ')||
                                            fn_texto_comple_pa(rw_crapass.cdagenci
                                                              ,2 ,rw_crawcrd.dtmvtolt
                                                              ,2 ,rw_crawcrd.nrctrcrd)||
                                            '</detalhe></tipo>';

          -- incrementando a variavel de controle de labels
          vr_seq := vr_seq + 1;
        END LOOP;--OPEN cr_crawcrd
        -- fecha o cursor
        CLOSE cr_crawcrd01;

        -- inicializa a variavel de controle de labels
        vr_seq := 1;

        /* pesquisa emprestimos */
        OPEN cr_crapepr( pr_cdcooper => pr_cdcooper
                        ,pr_nrdconta => rw_crapass.nrdconta);
        LOOP
          FETCH cr_crapepr INTO rw_crapepr;
          EXIT WHEN cr_crapepr%NOTFOUND;
          -- se o emprestimo estiver ativo "inliquid = 0" (0=ativo, 1=liquid.)
          IF rw_crapepr.inliquid = 0 THEN

            -- se eh o primeiro registro de limite, imprime o label
            -- senao, gera somente os valores sem o label
            IF vr_seq = 1 THEN
              -- Definindo os labels
              vr_dslabel1 := ' EMPRESTIMO:';
              vr_dslabel2 := ' PRESTACAO:';
              vr_dslabel3 := ' QTD.PREST.:';
            ELSE
              -- Definindo os labels
              vr_dslabel1 := '            ';
              vr_dslabel2 := '           ';
              vr_dslabel3 := '            ';
            END IF;

            -- montando o registro detalhe
            vr_detalhe394 := vr_detalhe394||'<tipo dstipo="EMPRESTIMO"><detalhe>'||
                                          vr_dslabel1||
                                          lpad(to_char(rw_crapepr.vlemprst,'fm9G999G990D00'),15,' ')||
                                          vr_dslabel2||
                                          lpad(to_char(rw_crapepr.vlpreemp,'fm9G999G990D00'),13,' ')||
                                          vr_dslabel3||
                                          lpad(rw_crapepr.qtpreemp,4,' ')||'       '||
                                          fn_texto_comple_pa(rw_crapass.cdagenci
                                                            ,2 ,rw_crapepr.dtmvtolt
                                                            ,1 ,rw_crapepr.nrctremp)||
                                          '</detalhe></tipo>';

            -- totalizando o valor do credito
            vr_totcredi394 := nvl(vr_totcredi394,0) + nvl(rw_crapepr.vlemprst,0);

            -- totaliza o valor utilizado
            vr_ttslddev394 := nvl(vr_ttslddev394,0) + nvl(rw_crapepr.vlsdeved,0);

            -- incrementando a variavel de controle de labels
            vr_seq := vr_seq + 1;
          END IF;

        END LOOP; --OPEN cr_crapepr( pr_cdcooper => pr_cdcooper
        CLOSE cr_crapepr;

        -- se tem informacoes, gera o registro do associado
        IF vr_detalhe394 IS NOT NULL THEN
          -- gerando o xml ref. ao relatorio crrl244
          pc_escreve_xml('CRRL394', '<crapass id="'||rw_crapass.nrdconta||'" '||
                                       'nmprimtl="'||rw_crapass.nmprimtl||'" '||
                                       'desvincu="'||rw_crapass.desvincu||'" '||
                                       'nrdconta="'||gene0002.fn_mask_conta(rw_crapass.nrdconta)||'" ');


          -- Ajustar o arredondamento
          vr_ttslddev394 := APLI0001.fn_round(vr_ttslddev394,2);

          -- se o totalizador possuir valor maior que zero
          -- gera os totais, caso contrario, limpa as linhas
          IF vr_totcredi394 > 0 THEN
            pc_escreve_xml('CRRL394', 'dslinha="'||lpad(' ',12,' ')||lpad('-',15,'-')||'" '||
                                      'dstotal="'||lpad(to_char(vr_totcredi394,'fm999G999G990D00'),27,' ')||
                                                   lpad('SALDO DEVEDOR ATUAL: ',28,' ')||
                                                   lpad(to_char(vr_ttslddev394,'fm999G999G990D00'),15,' ')||
                                                   '">');
          ELSE
            pc_escreve_xml('CRRL394', 'dslinha="" dstotal="">');
          END IF;

          -- finaliza a tag do associado
          pc_escreve_xml('CRRL394', vr_detalhe394||'</crapass>');
        END IF;

      END LOOP;--OPEN cr_crapass(pr_cdcooper => pr_cdcooper);
      -- fecha o cursor
      CLOSE cr_crapass;

      -------------------------------------------------
      -- FINALIZANDO
      -------------------------------------------------
      -- finaliza o arquivo xml ref. ao relatorio crrl244
      pc_escreve_xml('CRRL244', '</crrl244>');

      -- Gerando o relatorio
      gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper
                                ,pr_cdprogra  => vr_cdprogra
                                ,pr_dtmvtolt  => rw_crapdat.dtmvtolt
                                ,pr_dsxml     => vr_crrl244_xml
                                ,pr_dsxmlnode => '/crrl244/crapass/tipo'
                                ,pr_dsjasper  => 'crrl244.jasper'
                                ,pr_dsparams  => 'PR_MESREF##'||vr_nmmesref -- mes de referencia
                                ,pr_dsarqsaid => vr_caminho_cooper ||'/rl/crrl244.lst'
                                ,pr_flg_gerar => 'N'
                                ,pr_qtcoluna  => 132
                                ,pr_sqcabrel  => 1
                                ,pr_flg_impri => 'S'
                                ,pr_nmformul  => '132col'
                                ,pr_nrcopias  => 2
                                ,pr_des_erro  => vr_dscritic);

      -- Liberando a memória alocada pro CLOB crrl244
      dbms_lob.close(vr_crrl244_xml);
      dbms_lob.freetemporary(vr_crrl244_xml);


      -- finaliza o arquivo xml ref. ao relatorio crrl394
      pc_escreve_xml('CRRL394', '</crrl394>');

      -- Gerando o relatorio
      gene0002.pc_solicita_relato(pr_cdcooper => pr_cdcooper
                                ,pr_cdprogra  => vr_cdprogra
                                ,pr_dtmvtolt  => rw_crapdat.dtmvtolt
                                ,pr_dsxml     => vr_crrl394_xml
                                ,pr_dsxmlnode => '/crrl394/crapass/tipo'
                                ,pr_dsjasper  => 'crrl394.jasper'
                                ,pr_dsparams  => 'PR_MESREF##'||vr_nmmesref -- mes de referencia
                                ,pr_dsarqsaid => vr_caminho_cooper ||'/rl/crrl394.lst'
                                ,pr_flg_gerar => 'N'
                                ,pr_qtcoluna  => 132
                                ,pr_sqcabrel  => 2
                                ,pr_flg_impri => 'S'
                                ,pr_nmformul  => '132col'
                                ,pr_nrcopias  => 1
                                ,pr_des_erro  => vr_dscritic);

      -- Liberando a memória alocada pro CLOB crrl394
      dbms_lob.close(vr_crrl394_xml);
      dbms_lob.freetemporary(vr_crrl394_xml);

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

  END pc_crps294;
/
