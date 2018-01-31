CREATE OR REPLACE PACKAGE CECRED.flxf0001 AS

  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa: FLXF0001                        Antiga: sistema/generico/procedures/b1wgen0131.p
  --  Autor   : Odirlei-AMcom Capoia (DB1)
  --  Data    : Dezembro/2011                     Ultima Atualizacao: 08/10/2013
  --
  --  Dados referentes ao programa:
  --
  --  Objetivo  : Tranformacao BO tela PREVIS
  --
  --  Alteracoes: 30/09/2013 - Conversao Progress para oracle (Odirlei-AMcom).
  --
  ---------------------------------------------------------------------------------------------------------------

  /* Type de registros para armazenar os valores dos periodos*/
  TYPE typ_reg_per_datas IS
      RECORD (cdagrupa NUMBER
             ,dtmvtolt DATE
             ,vlrtotal NUMBER);

  /* Definicao de tabela que compreende os registros acima declarados */
  TYPE typ_tab_per_datas IS
    TABLE OF typ_reg_per_datas
    INDEX BY varchar2(12);-- cdagrup (3) + dt(8) formato DDMMRRRR

  TYPE typ_tab_datas  is
    table of INTEGER  INDEX BY varchar2(8);-- dt(8) formato DDMMRRRR

  TYPE typ_tab_ValDia is
    varray(31) of PLS_INTEGER;
    
  -- Calculo da diferença entre a projeção e o realizado, retorno numérico.
  FUNCTION fn_calcula_difere_valor(pr_vlrealizado IN NUMBER
                                  ,pr_vlprojetado IN NUMBER) RETURN NUMBER;
  
  -- Calculo da diferença entre a projeção e o realizado, retorno em percentual.
  FUNCTION fn_calcula_difere_percent(pr_vlrealizado IN NUMBER
                                    ,pr_vlprojetado IN NUMBER) RETURN NUMBER;
  
  -- Retorno da origem da informação do Fluxo do dia para a remessa (Realizado ou Projetado).
  FUNCTION fn_tpfluxo_remessa(pr_cdremessa  IN PLS_INTEGER
                             ,pr_tpfluxo_es IN CHAR) RETURN VARCHAR2;  
  
  -- Procedure para Verificar se o dia é feriado
  FUNCTION fn_verifica_feriado(pr_cdcooper in number   -- codigo da cooperativa
                              ,pr_dtrefmes in date     -- Data referencia
                              ) return boolean;
                              
  -- Função para validar horário de alteração do Fluxo Financeiro
  FUNCTION fn_valida_horario(pr_cdcooper IN NUMBER) RETURN VARCHAR2; -- Numero da COoperativa                              

  -- Função para identificar o banco da agencia
  FUNCTION fn_identifica_bcoctl(pr_cdcooper IN Integer, -- codigo da cooperativa
                                pr_cdagenci IN Integer, -- Codigo da agencia
                                pr_idtpdoct IN VARCHAR2)-- Tipo de documento (T-titulo,D-doc,C-cheque)

           RETURN NUMBER;


  -- Procedure para gravar movimento do fluxo financeiro
  PROCEDURE pc_grava_fluxo_financeiro (pr_cdcooper  IN INTEGER      -- Codigo da Cooperativa
                                      ,pr_cdagenci  IN INTEGER      -- Codigo da agencia
                                      ,pr_nrdcaixa  IN INTEGER      -- Numero da caixa
                                      ,pr_cdoperad  IN crapope.cdoperad%type     -- Codigo do operador
                                      ,pr_dtmvtolt  IN DATE         -- Data de movimento
                                      ,pr_cdprogra  IN VARCHAR2     -- Nome da tela
                                      ,pr_dtmvtoan  IN DATE         -- Data de movimento anterior
                                      ,pr_dtmvtopr  IN DATE         -- Data do próximo dia util
                                      ,pr_cdremessa IN NUMBER DEFAULT 0 -- Tipo da remessa (0 para todas)
                                      ,pr_tpfluxo   IN NUMBER DEFAULT 0 -- TIpo do fluxo (0 para todos)
                                      ,pr_flghistor IN BOOLEAN DEFAULT FALSE -- Flag para utilização da base histórica 
                                      ,pr_tab_erro OUT GENE0001.typ_tab_erro -- Tabela contendo os erros
                                      ,pr_dscritic OUT VARCHAR2);   -- Descrição da critica
                                      
  -- Procedure para gravar Informacoes do fluxo financeiro consolidado.
  PROCEDURE pc_grava_consolidado_singular
                                    (pr_cdcooper IN INTEGER           -- Codigo da Cooperativa
                                    ,pr_cdbccxlt IN INTEGER           -- Codigo do Banco da Remessa
                                    ,pr_dtmvtolt IN DATE              -- Data de movimento
                                    ,pr_tpdcampo IN NUMBER            -- Tipo de campo
                                    ,pr_vldcampo IN NUMBER            -- Valor do campo
                                    ,pr_cdoperad IN VARCHAR2          -- Operador
                                    ,pr_dscritic OUT VARCHAR2);       -- Descrição da critica

  -- Procedure para gravar Informacoes do fluxo financeiro consolidado de entrada ou saida
  PROCEDURE pc_gera_consolidado_singular (pr_cdcooper  IN INTEGER      -- Codigo da Cooperativa
                                         ,pr_dtmvtolt  IN DATE         -- Data de movimento
                                         ,pr_cdoperad  IN VARCHAR2     -- Codigo do operador
                                         ,pr_dscritic OUT VARCHAR2);   -- Descrição da critica
                                         
  -- Procedure para atualizar previsão futura 12 meses com base no dia anterior
  PROCEDURE pc_atualiza_projecao12m;
                                 
END FLXF0001;
/
CREATE OR REPLACE PACKAGE BODY CECRED.flxf0001 AS

  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa: FLXF0001                        Antiga: sistema/generico/procedures/b1wgen0131.p
  --  Autor   : Odirlei-AMcom Capoia (DB1)
  --  Data    : Dezembro/2011                     Ultima Atualizacao: 08/10/2013
  --
  --  Dados referentes ao programa:
  --
  --  Objetivo  : Tranformacao BO tela PREVIS
  --
  --  Alteracoes: 30/09/2013 - Conversao Progress para oracle (Odirlei-AMcom).
  --
  ---------------------------------------------------------------------------------------------------------------
  
    -- Armazenar os valores da CRAPTAB na sessão
    vr_dstextab craptab.dstextab%TYPE;
  
    -- Ler lancamentos de deposito a vista, do proxima data a ser simulada
    CURSOR cr_craplcm_cheques_p(pr_cdbccxlt NUMBER
                               ,pr_dtmvtolt DATE
                               ,pr_cdcooper NUMBER
                               ,pr_dtrefere DATE) IS
      SELECT nvl(sum(lcm.vllanmto),0) vllanmto
        FROM craplcm                  lcm
            ,tbfin_histor_fluxo_caixa his
       WHERE lcm.cdcooper = pr_cdcooper
         AND his.cdbccxlt = pr_cdbccxlt
         AND lcm.cdhistor = his.cdhistor
         AND his.tpfluxo  = 'S'
         AND his.cdremessa = 1 /* Cheques */
         AND lcm.dtmvtolt = pr_dtmvtolt
         AND lcm.dtrefere = pr_dtrefere;

    -- Ler lancamentos de deposito a vista da data atual
    CURSOR cr_craplcm_cheques(pr_cdbccxlt NUMBER
                             ,pr_cdcooper NUMBER
                             ,pr_dtmvtolt DATE) IS
      SELECT  nvl(sum(lcm.vllanmto),0) vllanmto
        FROM craplcm                  lcm
            ,tbfin_histor_fluxo_caixa his
       WHERE lcm.cdcooper  = pr_cdcooper  
         AND his.cdbccxlt  = pr_cdbccxlt       
         AND lcm.cdhistor  = his.cdhistor
         AND his.tpfluxo   = 'S'
         AND his.cdremessa = 1 /* Cheques */
         AND lcm.dtmvtolt  = pr_dtmvtolt 
         AND lcm.dtrefere is NULL;
              
    --Buscar lancamentos dos funcionarios das empresas que optaram por transferir o salario para outra instituicao financeira.
    CURSOR cr_craplcs_tedtec (pr_cdbccxlt NUMBER
                             ,pr_dtmvtolt DATE
                             ,pr_cdcooper NUMBER) IS
      SELECT nvl(sum(lcs.vllanmto),0) vllanmto
        FROM craplcs                  lcs
            ,tbfin_histor_fluxo_caixa his
       WHERE lcs.cdcooper  = pr_cdcooper
         AND his.cdbccxlt  = pr_cdbccxlt
         AND lcs.dtmvtolt  = pr_dtmvtolt
         AND lcs.cdhistor  = his.cdhistor
         AND his.tpfluxo   = 'S'
         AND his.cdremessa = 3; /* TED/TEC */

    --Buscar Lancamentos Automaticos Fatura Bradesco 
    CURSOR cr_craplau_fatbra(pr_cdbccxlt NUMBER
                            ,pr_dtmvtolt DATE
                            ,pr_cdcooper NUMBER) IS
      SELECT nvl(sum(lau.vllanaut),0) vllanaut
        FROM craplau                  lau
            ,tbfin_histor_fluxo_caixa his
       WHERE lau.cdcooper = pr_cdcooper
         AND lau.dtmvtopg = pr_dtmvtolt
         AND his.cdbccxlt = pr_cdbccxlt
         AND lau.cdhistor  = his.cdhistor
         AND lau.insitlau  = 3 --> Efetivado
         AND his.tpfluxo   = 'S'
         AND his.cdremessa = 10;  /* Cartão de Crédito */         

    --Buscar lancamentos em depositos a vista
    CURSOR cr_craplcm_dep_ic(pr_cdbccxlt NUMBER
                            ,pr_dtmvtolt DATE
                            ,pr_cdcooper NUMBER
                            ,pr_tpdmovto INTEGER) IS
      SELECT NVL(sum(lcm.vllanmto),0) vllanmto, 1 id
        FROM craplcm                  lcm
            ,tbfin_histor_fluxo_caixa his
       WHERE pr_tpdmovto = 1 
         AND lcm.cdcooper = pr_cdcooper
         AND lcm.dtmvtolt = pr_dtmvtolt
         AND his.cdbccxlt = pr_cdbccxlt
         AND lcm.cdhistor = his.cdhistor
         AND his.cdremessa = 12 /* Dep IC */
         AND his.tpfluxo   = 'E'
      UNION
      -- se for 2-saida deve buscar os lanc. do hist. 1004  do cooperativa do cash
      SELECT NVL(Sum(lcm.vllanmto),0) vllanmto, 2 id
        FROM craplcm                  lcm
            ,tbfin_histor_fluxo_caixa his
       WHERE pr_tpdmovto = 2
         AND lcm.cdcooper <> pr_cdcooper
         AND lcm.dtmvtolt = pr_dtmvtolt
         AND his.cdbccxlt = pr_cdbccxlt
         AND lcm.cdcoptfn = pr_cdcooper
         AND lcm.cdhistor = his.cdhistor
         AND his.cdremessa = 12 /* Dep IC */
         AND his.tpfluxo   = 'S';
  
    -- Buscar NR Titulos
    CURSOR cr_craptit (pr_dtmvtolt DATE,
                       pr_cdcooper NUMBER) IS
      SELECT NVL(sum(tit.vldpagto),0) vldpagto
        FROM craptit tit
            ,crapage age
       WHERE tit.cdcooper = age.cdcooper 
         AND tit.cdagenci = age.cdagenci
         AND tit.cdcooper  = pr_cdcooper
         AND tit.dtdpagto  = pr_dtmvtolt
         AND tit.tpdocmto  = 20
         AND tit.intitcop  = 0
         AND tit.insittit in (2,4)
         AND tit.cdbcoenv IN(0,85)
         AND(tit.cdbcoenv = 85 OR age.cdbantit = 85);
         
    --Buscar Cheques acolhidos para depositos nas contas dos associados.
    CURSOR cr_crapchd (pr_dtmvtolt DATE,
                       pr_cdcooper NUMBER,
                       pr_inchqcop NUMBER) IS
      SELECT NVL(SUM(vlcheque),0) vlcheque
        FROM crapchd chd 
            ,crapage age 
       WHERE chd.cdcooper = age.cdcooper 
         AND chd.cdagenci = age.cdagenci
         AND chd.cdcooper  = pr_cdcooper
         AND chd.dtmvtolt  = pr_dtmvtolt
         AND chd.inchqcop  = pr_inchqcop
         AND chd.insitchq in (0,2)         
         AND chd.cdbcoenv IN(0,85)
         AND(chd.cdbcoenv = 85 OR age.cdbanchq = 85);

    -- Buscar convenios
    CURSOR cr_gnconve(pr_cdcooper crapcop.cdcooper%TYPE) IS
      SELECT gnconve.cdhisdeb
        FROM gnconve
            ,gncvcop 
       WHERE gncvcop.cdcooper = pr_cdcooper
         AND gnconve.cdconven = gncvcop.cdconven
         AND gnconve.flgativo = 1 --true
         AND gnconve.cdconven <> 39
         AND gnconve.cdhisdeb > 0;

    --Buscar Lancamentos em depositos a vista
    CURSOR cr_craplcm_generi(pr_cdbccxlt NUMBER
                            ,pr_dtmvtolt DATE
                            ,pr_cdcooper NUMBER
                            ,pr_cdhistor gnconve.cdhisdeb%type) IS
      SELECT NVL(sum(vllanmto),0) vllanmto
        FROM craplcm
       WHERE cdcooper  = pr_cdcooper
         AND dtmvtolt  = pr_dtmvtolt
         AND cdhistor  = pr_cdhistor;         
  
    --Buscar Lancamentos em depositos a vista junto a histórico parametrizável
    CURSOR cr_craplcm_parame(pr_cdbccxlt NUMBER
                            ,pr_dtmvtolt  DATE
                            ,pr_cdcooper  NUMBER
                            ,pr_cdremessa NUMBER
                            ,pr_tpfluxo   VARCHAR2) IS
      SELECT NVL(sum(lcm.vllanmto),0) vllanmto
        FROM craplcm                  lcm
            ,tbfin_histor_fluxo_caixa his
       WHERE lcm.cdcooper  = pr_cdcooper
         AND lcm.dtmvtolt  = pr_dtmvtolt
         AND his.cdbccxlt  = pr_cdbccxlt
         AND lcm.cdhistor  = his.cdhistor
         AND his.cdremessa = pr_cdremessa
         AND his.tpfluxo   = pr_tpfluxo;
         
    --Buscar Lancamentos em depositos a vista junto a histórico parametrizável
    CURSOR cr_craplcm_parame_central(pr_cdbccxlt NUMBER
                                    ,pr_dtmvtolt  DATE
                                    ,pr_cdcooper  NUMBER
                                    ,pr_cdremessa NUMBER
                                    ,pr_tpfluxo   VARCHAR2) IS
      SELECT NVL(sum(lcm.vllanmto),0) vllanmto
        FROM crapcop                  cop
            ,craplcm                  lcm
            ,tbfin_histor_fluxo_caixa his
       WHERE lcm.cdcooper  = 3 --> Fixo na central
         AND lcm.dtmvtolt  = pr_dtmvtolt
         AND his.cdbccxlt  = pr_cdbccxlt
         AND cop.cdcooper  = pr_cdcooper
         AND lcm.nrdconta  = cop.nrctacmp
         AND lcm.cdhistor  = his.cdhistor
         AND his.cdremessa = pr_cdremessa
         AND his.tpfluxo   = pr_tpfluxo;     
         
    --Buscar Lancamentos em depositos na Central
    CURSOR cr_craplcm_numera(pr_cdbccxlt NUMBER
                            ,pr_dtmvtolt  DATE
                            ,pr_cdcooper  NUMBER
                            ,pr_tpfluxo   VARCHAR2) IS
      SELECT NVL(sum(lcm.vllanmto),0) vllanmto
        FROM crapcop                  cop 
            ,craplcm                  lcm
            ,tbfin_histor_fluxo_caixa his
       WHERE cop.nrctactl  = lcm.nrdconta 
         AND lcm.cdhistor  = his.cdhistor  
         AND lcm.cdcooper  = 3 --> Lctos são na Central
         AND cop.cdcooper  = pr_cdcooper
         AND lcm.dtmvtolt  = pr_dtmvtolt
         AND his.cdbccxlt  = pr_cdbccxlt
         AND his.cdremessa = 13
         AND his.tpfluxo   = pr_tpfluxo;

    --Buscar Lancamentos em depositos a vista com devolução de cheques recebidos
    CURSOR cr_lcm_devchq_recebi(pr_cdbccxlt NUMBER
                               ,pr_dtmvtolt  DATE
                               ,pr_cdcooper  NUMBER) IS
      SELECT NVL(sum(lcm.vllanmto),0) vllanmto
        FROM craplcm                  lcm
            ,tbfin_histor_fluxo_caixa his
       WHERE lcm.cdcooper  = pr_cdcooper
         AND lcm.dtmvtolt  = pr_dtmvtolt
         AND his.cdbccxlt  = pr_cdbccxlt
         AND lcm.cdhistor  = his.cdhistor
         AND his.cdremessa = 5 --> Dev Cheques
         AND his.tpfluxo   = 'S'
         AND lcm.cdbanchq  <> 85 ;
  
    --Buscar Lancamentos de creditos de beneficios do INSS Bancoob
    CURSOR cr_craplbi (pr_dtmvtolt DATE,
                       pr_cdcooper NUMBER) IS
      SELECT NVL(sum(vlliqcre),0) vlliqcre
        FROM craplbi
       WHERE cdcooper = pr_cdcooper
         AND dtdpagto = pr_dtmvtolt;  

    --Buscar Lancamentos de debito em cartão
    CURSOR cr_craplcm_debcar(pr_dtmvtolt DATE,
                             pr_cdcooper NUMBER) IS
      SELECT NVL(sum(lcm.vllanmto),0) vllanmto
        FROM craplcm lcm
            ,craphcb hcb
       WHERE lcm.cdcooper  = pr_cdcooper
         AND lcm.dtmvtolt  = pr_dtmvtolt
         AND lcm.cdhistor  = hcb.cdhistor;


    --Buscar Retorno do COBAN (CBF800)
    CURSOR cr_craprcb (pr_dtmvtolt DATE,
                       pr_cdcooper NUMBER) IS
      SELECT cdtransa
            ,sum(valorpag) valorpag
        FROM craprcb
       WHERE cdcooper = pr_cdcooper
         AND dtmvtolt = pr_dtmvtolt
         AND cdtransa IN('268','358','284') /* Titulos, Faturas OU Recebto INSS */
         AND flgrgatv = 1
         AND cdagenci <> 9999 /* Totais dias anteriores */
       GROUP BY cdtransa;  
    
    --Buscar Lancamentos das Guias de recolhimento da Previdencia Social
    CURSOR cr_craplgp (pr_dtmvtolt DATE,
                       pr_cdcooper NUMBER) IS
      SELECT cdbccxlt
            ,nvl(sum(NVL(vlrtotal,0)),0) vlrtotal
        FROM( select 756 cdbccxlt 
                    ,lgp.vlrtotal
                from craplgp lgp
               where lgp.cdcooper = pr_cdcooper
                 and lgp.dtmvtolt = pr_dtmvtolt
                 AND lgp.cdbccxlt = 11 -- GPS ANTIGO
            UNION ALL
              select 748 cdbccxlt 
                    ,lgp.vlrtotal
                from craplgp lgp
               where lgp.cdcooper = pr_cdcooper
                 and lgp.dtmvtolt = pr_dtmvtolt
                 AND lgp.cdbccxlt = 100 -- GPS NOVO
                 AND lgp.flgpagto = 1   -- PAGO
                 AND lgp.idsicred <> 0)
              GROUP BY cdbccxlt;      
              

    -- Buscar tranferencia de valores (DOC C, DOC D E TEDS)
    CURSOR cr_craptvl (pr_dtmvtolt DATE,
                       pr_cdcooper NUMBER) IS
      SELECT nvl(sum(vldocrcb),0) vldocrcb
        FROM craptvl
       WHERE cdcooper  = pr_cdcooper
         AND dtmvtolt  = pr_dtmvtolt
         AND cdbcoenv  = 85
         AND tpdoctrf  = 3;/* TED */       
         
    -- Buscar tranferencia de valores (DOC C, DOC D E TEDS)
    CURSOR cr_craptvl_nrdoc (pr_dtmvtolt DATE,
                             pr_cdcooper NUMBER) IS
      SELECT NVL(sum(tvl.vldocrcb),0) vldocrcb
        FROM craptvl tvl
            ,crapage age 
       WHERE tvl.cdcooper = age.cdcooper 
         AND tvl.cdagenci = age.cdagenci
         AND tvl.cdcooper  = pr_cdcooper
         AND tvl.dtmvtolt  = pr_dtmvtolt
         AND tvl.cdbcoenv  IN(85,0)
         AND tvl.tpdoctrf  <> 3
         AND (   tvl.cdbcoenv = 85
              OR ( tvl.cdbcoenv = 0 AND age.cdbandoc = 1));
                
    -- Buscar lançamentos de deposito avista da cooperativa cash
    CURSOR cr_craplcm_cash(pr_cdbccxlt NUMBER
                          ,pr_cdcoptfn craplcm.cdcoptfn%TYPE
                          ,pr_dtmvtolt crapdat.dtmvtolt%TYPE) IS
      SELECT nvl(sum(decode(lcm.cdhistor,918,lcm.vllanmto,lcm.vllanmto*-1)),0) vllanmto
        FROM craplcm                  lcm
            ,tbfin_histor_fluxo_caixa his
       WHERE lcm.cdcoptfn  = pr_cdcoptfn       
         AND lcm.cdhistor  = his.cdhistor         
         AND his.tpfluxo   = 'E'
         AND his.cdremessa = 9 /* Saque TAA */         
         AND lcm.dtmvtolt  = pr_dtmvtolt
         AND his.cdbccxlt  = pr_cdbccxlt
         AND lcm.cdcooper <> lcm.cdcoptfn;
         
    -- Buscar lançamentos de deposito avista da cooperativa
    CURSOR cr_craplcm_cop(pr_cdbccxlt NUMBER
                         ,pr_cdcooper craplcm.cdcooper%TYPE
                         ,pr_dtmvtolt crapdat.dtmvtolt%TYPE) IS
      SELECT nvl(sum(decode(lcm.cdhistor,918,lcm.vllanmto,lcm.vllanmto*-1)),0) vllanmto
        FROM craplcm                  lcm
            ,tbfin_histor_fluxo_caixa his
       WHERE lcm.cdcooper  = pr_cdcooper
         AND his.cdbccxlt  = pr_cdbccxlt
         AND lcm.cdhistor  = his.cdhistor         
         AND his.tpfluxo   = 'S'
         AND his.cdremessa = 9 /* Saque TAA */
         AND lcm.dtmvtolt  = pr_dtmvtolt
         AND lcm.cdcooper <> lcm.cdcoptfn
         AND lcm.cdcoptfn <> 0;  
    
    -- Busca das TEDs Cecred e Sicredi
    CURSOR cr_craplmt(pr_cdcooper crapcop.cdcooper%TYPE
                     ,pr_dtmvtolt crapdat.dtmvtolt%TYPE
                     ,pr_cdifconv craplmt.cdifconv%TYPE) IS 
      SELECT nvl(sum(vldocmto),0) vldocmto
        FROM craplmt
       WHERE craplmt.cdcooper = pr_cdcooper
         AND craplmt.dttransa = pr_dtmvtolt 
         AND craplmt.cdifconv = pr_cdifconv -- 0 - Cecred / 1 - Sicredi
         AND craplmt.idsitmsg = 3;          -- 1-Enviada-ok / 2-enviada-nok / 3-recebida-ok / 4-Recebina-nok
    
    -- Buscar Lancamentos de faturas de convênios
    CURSOR cr_craplft (pr_cdcooper IN NUMBER
                      ,pr_dtdpagto IN DATE 
                      ,pr_tparrecd IN INTEGER) IS
      SELECT nvl(sum(vllanmto + vlrmulta + vlrjuros),0) vldtotal
        FROM craplft
       WHERE cdcooper = pr_cdcooper
         AND dtmvtolt = pr_dtdpagto
         AND ( (pr_tparrecd = 3 AND cdhistor NOT IN (1154,2515)) OR -- Convenios CECRED
               (pr_tparrecd = 1 AND cdhistor = 1154)  OR            -- Somente para Sicredi
               (pr_tparrecd = 2 AND cdhistor = 2515)                -- Somente para Bancoob
              );
              
    --Buscar de bloquetos de cobranca Cecred
    CURSOR cr_crapcob(pr_cdcooper crapcop.cdcooper%TYPE
                     ,pr_dtmvtoan crapdat.dtmvtoan%TYPE) IS
      SELECT cco.cddbanco
            ,NVL(SUM(ret.vlrpagto),0) vldpagto
        FROM crapret ret, crapcco cco
       WHERE cco.CDCOOPER = pr_cdcooper
         AND cco.cddbanco IN (85) /*Cecred e Banco do Brasil*/
         AND cco.flgregis = 1
         AND ret.cdcooper = cco.cdcooper
         AND ret.dtocorre = pr_dtmvtoan
         AND ret.nrcnvcob = cco.nrconven
         AND ret.cdocorre IN (6,17,76,77)
       GROUP BY cco.cddbanco ;   
         
    --Buscar de bloquetos de cobranca somente BB
    CURSOR cr_crapcob_bb(pr_cdcooper crapcop.cdcooper%TYPE
                        ,pr_dtmvtoan crapdat.dtmvtoan%TYPE) IS
      SELECT cob.cdbandoc
            ,nvl(SUM(cob.vldpagto),0) vldpagto
        FROM CRAPCOB cob, crapcco cco
       WHERE cco.CDCOOPER = pr_cdcooper
         AND cco.cddbanco = 1
         AND cob.cdbandoc = 1
         AND cco.flgregis = 0
         AND cob.cdcooper = cco.cdcooper
         AND cob.nrcnvcob = cco.nrconven
         AND cob.dtdpagto = pr_dtmvtoan
         AND cob.cdbandoc = cco.cddbanco
         AND cob.nrdctabb = cco.nrdctabb
         AND cob.incobran = 5
         AND cob.vldpagto > 0
       GROUP BY cob.cdbandoc
      UNION
      SELECT cco.cddbanco
            ,NVL(SUM(ret.vlrpagto),0) vldpagto
        FROM crapret ret, crapcco cco
       WHERE cco.CDCOOPER = pr_cdcooper
         AND cco.cddbanco = 1 /* Banco do Brasil*/
         AND cco.flgregis = 1
         AND ret.cdcooper = cco.cdcooper
         AND ret.dtocorre = pr_dtmvtoan
         AND ret.nrcnvcob = cco.nrconven
         AND ret.cdocorre IN (6,17,76,77)
       GROUP BY cco.cddbanco;                
              
    -- Buscar Informacoes da movimentacao do fluxo financeiro de Cheques
    CURSOR cr_crapffm_histor(pr_cdcooper crapffm.cdcooper%TYPE
                            ,pr_dtmvtolt crapffm.dtmvtolt%TYPE
                            ,pr_cdbccxlt crapffm.cdbccxlt%TYPE
                            ,pr_tpdmovto crapffm.tpdmovto%TYPE
                            ,pr_tpdcampo NUMBER) is
      SELECT CASE pr_tpdcampo
               WHEN 1 THEN vlcheque
               WHEN 2 THEN vltotdoc
               WHEN 3 THEN vltotted
               WHEN 4 THEN vltottit
               WHEN 5 THEN vldevolu
               WHEN 6 THEN vlmvtitg
               WHEN 7 THEN vlttinss
               WHEN 8 THEN vltrfitc
               WHEN 9 THEN vlsatait
               WHEN 10 THEN vlcarcre
               WHEN 11 THEN vlconven  
               WHEN 12 THEN vldepitc                
               WHEN 13 THEN vlnumera
               WHEN 14 THEN vlcardeb                 
               ELSE 0                 
             END vllanmto
        FROM crapffm ffm
       WHERE ffm.cdcooper = pr_cdcooper
         AND ffm.dtmvtolt = pr_dtmvtolt 
         AND ffm.tpdmovto = pr_tpdmovto 
         AND ffm.cdbccxlt = pr_cdbccxlt;       
         
  -- Calculo da diferença entre a projeção e o realizado, retorno numérico.
  FUNCTION fn_calcula_difere_valor(pr_vlrealizado IN NUMBER
                                  ,pr_vlprojetado IN NUMBER) RETURN NUMBER IS
  BEGIN
    -- Retornar diferença entre o Realizado e Projetado
    RETURN pr_vlrealizado - pr_vlprojetado;
  EXCEPTION
    WHEN OTHERS THEN 
      RETURN 0;
  END fn_calcula_difere_valor;
  
  -- Calculo da diferença entre a projeção e o realizado, retorno em percentual.
  FUNCTION fn_calcula_difere_percent(pr_vlrealizado IN NUMBER
                                    ,pr_vlprojetado IN NUMBER) RETURN NUMBER IS
  BEGIN
    BEGIN
      -- Se houver valor reakuzadi
      IF NVL(pr_vlrealizado,0) <> 0 THEN
        -- Retornar diferença entre o Realizado e Projetado
        RETURN ((pr_vlrealizado - pr_vlprojetado) / pr_vlrealizado) * 100;
      ELSE
        -- Diferença será zero:
        RETURN 0;
      END IF;
    END;
  EXCEPTION
    WHEN OTHERS THEN 
      RETURN 0;
  END fn_calcula_difere_percent;

  -- Retorno da origem da informação do Fluxo do dia para a remessa (Realizado ou Projetado).
  FUNCTION fn_tpfluxo_remessa(pr_cdremessa  IN PLS_INTEGER
                             ,pr_tpfluxo_es IN CHAR) RETURN VARCHAR2 IS
  BEGIN
    DECLARE
      -- Buscar a configuração da remessa:
      CURSOR cr_tipo IS
        SELECT tpfluxo_entrada
              ,tpfluxo_saida
          FROM tbfin_remessa_fluxo_caixa
         WHERE cdremessa = pr_cdremessa;
      rw_tipo cr_tipo%ROWTYPE;
    BEGIN
      -- Busca da configuração
      OPEN cr_tipo;
      FETCH cr_tipo
       INTO rw_tipo;
      CLOSE cr_tipo;
      -- Retorno da configuração conforme tipo solicitado:  
      IF pr_tpfluxo_es = 'E' THEN
        -- Retornar configuração entrada
        Return rw_tipo.tpfluxo_entrada;
      ELSE 
        -- Retornar configuração saida
        Return rw_tipo.tpfluxo_saida;
      END if;    
    END;
  END fn_tpfluxo_remessa;
  
  -- Função para retornar os percetuais gravados na TAB carregando se ainda não tenha sido
  FUNCTION fn_parfluxofinan(pr_cddcampo IN NUMBER) RETURN NUMBER IS
    vr_dsposicao VARCHAR2(1000);
  BEGIN                         
    -- Verifica se a tab já foi carregada para a COOP
    IF vr_dstextab IS NULL THEN
      -- Buscar craptab
      vr_dstextab := tabe0001.fn_busca_dstextab(pr_cdcooper => 3
                                               ,pr_nmsistem => 'CRED'
                                               ,pr_tptabela => 'GENERI'
                                               ,pr_cdempres => 00
                                               ,pr_cdacesso => 'PARFLUXOFINAN'
                                               ,pr_tpregist => 0);
    END IF;
    -- Se houver registro
    IF vr_dstextab IS NOT NULL THEN
      -- Buscar a posição solicitada
      vr_dsposicao := gene0002.fn_busca_entrada(pr_cddcampo,vr_dstextab,';');
      -- Se encontrar
      IF trim(nvl(vr_dsposicao,' ')) IS NOT NULL THEN 
        -- Retornar a posição solicitada já dividindo por 100
        RETURN to_number(vr_dsposicao) / 100;
      ELSE
        RETURN 0;
      END IF;  
    ELSE
      RETURN 0;
    END IF;
  EXCEPTION 
    WHEN OTHERS THEN
      RETURN 0;
  END;

  -- Função para validar horário de alteração do Fluxo Financeiro
  FUNCTION fn_valida_horario(pr_cdcooper IN NUMBER) RETURN VARCHAR2 IS -- Numero da COoperativa                              
    vr_dshora VARCHAR2(5);
  BEGIN
    -- Buscar o horário posicionado na primera entrada do parâmetro
    vr_dshora := gene0002.fn_busca_entrada(1
                                          ,tabe0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                                                     ,pr_nmsistem => 'CRED'
                                                                     ,pr_tptabela => 'GENERI'
                                                                     ,pr_cdempres => 00
                                                                     ,pr_cdacesso => 'PARFLUXOFINAN'
                                                                     ,pr_tpregist => 0)
                                          ,';');
    -- Se houver registro
    IF vr_dshora IS NOT NULL THEN
      -- Comparar a hora atual com a hora encontrada
      IF vr_dshora >= to_char(SYSDATE,'hh24:mi') THEN
        RETURN 'S';
      ELSE
        RETURN 'N';
      END IF;
    ELSE 
      RETURN 'N';
    END IF;
    
  EXCEPTION
    WHEN OTHERS THEN
      RETURN 'N';
  END;

  -- Procedure para gravar movimentação de fluxo financeiro
  PROCEDURE pc_grava_movimentacao(pr_cdcooper IN INTEGER      -- Codigo da Cooperativa
                                 ,pr_dtmvtolt IN DATE         -- Data de movimento
                                 ,pr_tpdmovto IN INTEGER      -- Tipo de movimento
                                 ,pr_cdbccxlt IN NUMBER       -- Codigo do banco/caixa.
                                 ,pr_tpdcampo IN NUMBER       -- Tipo de campo
                                 ,pr_vldcampo IN NUMBER       -- Valor do campo
                                 ,pr_dscritic OUT VARCHAR2) AS -- Descrição da critica

    -- .........................................................................
    --
    --  Programa : pc_grava_movimentacao          Antigo: b1wgen0131.p/grava-movimentacao
    --
    --  Sistema  : Cred
    --  Sigla    : FLXF0001
    --  Autor    : Odirlei Busana
    --  Data     : novembro/2013.                   Ultima atualizacao: 11/10/2016
    --
    --  Dados referentes ao programa:
    --
    --   Objetivo  : Grava movimentação de fluxo financeiro
    --
    --   Atualizacao: 08/11/2013 - Conversao Progress => Oracle (Odirlei-AMcom)
    --
    --                11/10/2016 - P313 - Ajustes na alimentação dos campos (Marcos-Supero)
    --..........................................................................

    -- Buscar Informacoes da movimentacao do fluxo financeiro.
    CURSOR cr_crapffm is
      SELECT ROWID
        FROM crapffm
       WHERE crapffm.cdcooper = pr_cdcooper
         AND crapffm.dtmvtolt = pr_dtmvtolt 
         AND crapffm.tpdmovto = pr_tpdmovto 
         AND crapffm.cdbccxlt = pr_cdbccxlt;
    rw_crapffm cr_crapffm%rowtype;

  BEGIN

    -- Buscar Informacoes da movimentacao do fluxo financeiro.
    OPEN cr_crapffm;
    FETCH cr_crapffm
      INTO rw_crapffm;

    IF cr_crapffm%NOTFOUND THEN
      CLOSE cr_crapffm;
      -- Se não existe o registro insere
      BEGIN
        INSERT INTO crapffm
                      ( CDCOOPER,
                        DTMVTOLT,
                        TPDMOVTO,
                        CDBCCXLT,
                        VLCHEQUE,
                        VLTOTDOC,
                        VLTOTTED,
                        VLTOTTIT,
                        VLDEVOLU,
                        VLMVTITG,
                        VLTTINSS,
                        VLTRFITC,
                        VLSATAIT,
                        VLCARCRE,
                        VLCONVEN,
                        VLDEPITC,
                        VLNUMERA,
                        VLCARDEB)
               VALUES ( pr_cdcooper, --CDCOOPER
                        pr_dtmvtolt, --DTMVTOLT,
                        pr_tpdmovto, --TPDMOVTO,
                        pr_cdbccxlt, --CDBCCXLT,
                        DECODE(pr_tpdcampo,1,pr_vldcampo,0), --vlcheque
                        DECODE(pr_tpdcampo,2,pr_vldcampo,0), -- vltotdoc
                        DECODE(pr_tpdcampo,3,pr_vldcampo,0), --vltotted
                        DECODE(pr_tpdcampo,4,pr_vldcampo,0), --vltottit
                        DECODE(pr_tpdcampo,5,pr_vldcampo,0), --vldevolu
                        DECODE(pr_tpdcampo,6,pr_vldcampo,0), --vlmvtitg
                        DECODE(pr_tpdcampo,7,pr_vldcampo,0), --vlttinss
                        DECODE(pr_tpdcampo,8,pr_vldcampo,0), --vltrfitc
                        DECODE(pr_tpdcampo,9,pr_vldcampo,0), --vlsatait
                        DECODE(pr_tpdcampo,10,pr_vldcampo,0),--vlcarcre
                        DECODE(pr_tpdcampo,11,pr_vldcampo,0),--vlconven
                        DECODE(pr_tpdcampo,12,pr_vldcampo,0),--vldepitc
                        DECODE(pr_tpdcampo,13,pr_vldcampo,0),--vlnumera
                        DECODE(pr_tpdcampo,14,pr_vldcampo,0)--vlcardeb
                       );
      EXCEPTION
        WHEN OTHERS THEN
          pr_dscritic := 'Erro ao inserir crapffm: '|| SQLerrm;
          return;
      END;
    ELSE
      CLOSE cr_crapffm;
      -- Se ja existe o registro apenas atualizar se o tipo do campo for maior que zero
      -- pois neste caso é uma chamada apenas para criar os registros (já existentes)
      IF pr_tpdcampo > 0 THEN
        BEGIN
          UPDATE crapffm
             SET vlcheque = DECODE(pr_tpdcampo,1,pr_vldcampo,vlcheque),
                 vltotdoc = DECODE(pr_tpdcampo,2,pr_vldcampo,vltotdoc),
                 vltotted = DECODE(pr_tpdcampo,3,pr_vldcampo,vltotted),
                 vltottit = DECODE(pr_tpdcampo,4,pr_vldcampo,vltottit),
                 vldevolu = DECODE(pr_tpdcampo,5,pr_vldcampo,vldevolu),
                 vlmvtitg = DECODE(pr_tpdcampo,6,pr_vldcampo,vlmvtitg),
                 vlttinss = DECODE(pr_tpdcampo,7,pr_vldcampo,vlttinss),
                 vltrfitc = DECODE(pr_tpdcampo,8,pr_vldcampo,vltrfitc),
                 vlsatait = DECODE(pr_tpdcampo,9,pr_vldcampo,vlsatait),
                 vlcarcre = DECODE(pr_tpdcampo,10,pr_vldcampo,vlcarcre),
                 vlconven = DECODE(pr_tpdcampo,11,pr_vldcampo,vlconven),
                 vldepitc = DECODE(pr_tpdcampo,12,pr_vldcampo,vldepitc),
                 vlnumera = DECODE(pr_tpdcampo,13,pr_vldcampo,vlnumera),
                 vlcardeb = DECODE(pr_tpdcampo,14,pr_vldcampo,vlcardeb)
           WHERE ROWID = rw_crapffm.rowid;
        EXCEPTION
          WHEN OTHERS THEN
            pr_dscritic := 'Erro ao atualizar crapffm: '|| SQLerrm;
            return;
        END;
      END IF;  
    END IF;
    pr_dscritic := 'OK';
  END pc_grava_movimentacao;

  -- Procedure para gravar Informacoes do fluxo financeiro consolidado.
  PROCEDURE pc_grava_consolidado_singular(pr_cdcooper IN INTEGER           -- Codigo da Cooperativa
                                         ,pr_cdbccxlt IN INTEGER           -- Codigo do Banco da Remessa
                                         ,pr_dtmvtolt IN DATE              -- Data de movimento
                                         ,pr_tpdcampo IN NUMBER            -- Tipo de campo
                                         ,pr_vldcampo IN NUMBER            -- Valor do campo
                                         ,pr_cdoperad IN VARCHAR2          -- Operador
                                         ,pr_dscritic OUT VARCHAR2) AS     -- Descrição da critica

    -- .........................................................................
    --
    --  Programa : pc_grava_consolidado_singular          Antigo: b1wgen0131.p/grava_consolidado_singular
    --
    --  Sistema  : Cred
    --  Sigla    : FLXF0001
    --  Autor    : Odirlei Busana
    --  Data     : novembro/2013.                   Ultima atualizacao: 11/10/2016
    --
    --  Dados referentes ao programa:
    --
    --   Objetivo  : Grava Informacoes do fluxo financeiro consolidado.
    --
    --   Atualizacao: 20/11/2013 - Conversao Progress => Oracle (Odirlei-AMcom)
    --
    --                11/10/2016 - P313 - Ajustes na gravação de novas tabelas 
    --                             consolidadas (Marcos-Supero)
    --..........................................................................

    -- Buscar Informacoes do fluxo financeiro consolidado.
    CURSOR cr_crapffc is
      SELECT ROWID
            ,vloutros
            ,vlaplica
            ,vlresgat
        FROM crapffc
       WHERE crapffc.cdcooper = pr_cdcooper 
         AND crapffc.dtmvtolt = pr_dtmvtolt;
    rw_crapffc cr_crapffc%rowtype;
    
    -- Fluxo financeiro consolidado por Instituição
    CURSOR cr_ffc_inst IS
      SELECT ROWID
            ,vloutros
        FROM tbfin_fluxo_caixa_consolid
       WHERE cdcooper = pr_cdcooper
         AND cdbccxlt = pr_cdbccxlt
         AND dtmvtolt = pr_dtmvtolt;
    rw_ffc_inst cr_ffc_inst%ROWTYPE;  
    
    -- 
    vr_cdoperad crapope.cdoperad%TYPE;
    vr_hrtransa NUMBER;
    vr_dttransa DATE;
    
  BEGIN

    -- Somente gravar auditoria na alteração quando operações de resgate, aplicação ou outros
    IF pr_tpdcampo > 3 THEN 
      vr_cdoperad := nvl(pr_cdoperad,'1');
      vr_hrtransa := to_char(SYSDATE,'sssss');
      vr_dttransa := SYSDATE;
    END IF;

    -- PAra a consolictação de todas as entidades
    IF pr_cdbccxlt = 0 THEN
       
      -- Buscar Informacoes do fluxo financeiro consolidado.
      OPEN cr_crapffc;
      FETCH cr_crapffc
        INTO rw_crapffc;

      IF cr_crapffc%NOTFOUND THEN
        CLOSE cr_crapffc;
        -- Se não existe o registro, deve inserir
        BEGIN
          INSERT INTO crapffc
                   ( cdcooper
                    ,dtmvtolt
                    ,vlentrad
                    ,vlsaidas
                    ,vlsldcta
                    ,vlresgat
                    ,vlaplica
                    ,vloutros
                    ,cdoperad
                    ,hrtransa)
                 VALUES
                   ( pr_cdcooper -- cdcooper
                    ,pr_dtmvtolt -- dtmvtolt
                    ,DECODE(pr_tpdcampo,1,pr_vldcampo,0)-- vlentrad
                    ,DECODE(pr_tpdcampo,2,pr_vldcampo,0)-- vlsaidas
                    ,DECODE(pr_tpdcampo,3,pr_vldcampo,0)-- vlsldcta
                    ,DECODE(pr_tpdcampo,4,pr_vldcampo,0)-- vlresgat
                    ,DECODE(pr_tpdcampo,5,pr_vldcampo,0)-- vlaplica
                    ,DECODE(pr_tpdcampo,6,pr_vldcampo,0)-- vloutros
                    ,nvl(trim(pr_cdoperad),'1')
                    ,to_char(SYSDATE,'sssss'));
        EXCEPTION
          WHEN OTHERS THEN
            pr_dscritic := 'Erro ao inserir crapffc: '|| SQLerrm;
            return;
        END;
      ELSE
        CLOSE cr_crapffc;        
        -- Se ja existe o registro, apenas altera
        BEGIN
          UPDATE crapffc
             SET vlentrad = DECODE(pr_tpdcampo,1,pr_vldcampo,vlentrad),
                 vlsaidas = DECODE(pr_tpdcampo,2,pr_vldcampo,vlsaidas),
                 vlsldcta = DECODE(pr_tpdcampo,3,pr_vldcampo,vlsldcta),
                 vlresgat = DECODE(pr_tpdcampo,4,pr_vldcampo,vlresgat),
                 vlaplica = DECODE(pr_tpdcampo,5,pr_vldcampo,vlaplica),
                 vloutros = DECODE(pr_tpdcampo,6,pr_vldcampo,vloutros),
                 cdoperad = nvl(vr_cdoperad,cdoperad),
                 hrtransa = nvl(vr_hrtransa,hrtransa)
           WHERE rowid = rw_crapffc.rowid;
        EXCEPTION
          WHEN OTHERS THEN
            pr_dscritic := 'Erro ao atualizar crapffc: '|| SQLerrm;
            return;
        END;
      
        -- Gerar Log fluxos.log
        IF pr_tpdcampo = 4 THEN
          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                    ,pr_ind_tipo_log => 1 -- apenas log
                                    ,pr_nmarqlog     => 'fluxos'
                                    ,pr_des_log      => to_char(pr_dtmvtolt,'DD/MM/RRRR') ||' '||to_char(sysdate,'hh24:mi:ss')||
                                                        ' --> Operador '|| pr_cdoperad ||
                                                        ' - alterou o valor do resgate de '|| to_char(rw_crapffc.vlresgat,'fm999g999g999g999g990d00')||
                                                        ' para '|| to_char(pr_vldcampo,'fm999g999g999g999g990d00'));
        ELSIF pr_tpdcampo = 5 THEN
          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                    ,pr_ind_tipo_log => 1 -- apenas log
                                    ,pr_nmarqlog     => 'fluxos'
                                    ,pr_des_log      => to_char(pr_dtmvtolt,'DD/MM/RRRR') ||' '||to_char(sysdate,'hh24:mi:ss')||
                                                        ' --> Operador '|| pr_cdoperad ||
                                                        ' - alterou o valor da aplicação de '|| to_char(rw_crapffc.vlaplica,'fm999g999g999g999g990d00')||
                                                        ' para '|| to_char(pr_vldcampo,'fm999g999g999g999g990d00'));

        ELSIF pr_tpdcampo = 6 THEN
          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                    ,pr_ind_tipo_log => 1 -- apenas log
                                    ,pr_nmarqlog     => 'fluxos'
                                    ,pr_des_log      => to_char(pr_dtmvtolt,'DD/MM/RRRR') ||' '||to_char(sysdate,'hh24:mi:ss')||
                                                        ' --> Operador '|| pr_cdoperad ||
                                                        ' - alterou o valor diversos de '||
                                                        to_char(rw_crapffc.vloutros,'fm999g999g999g999g990d00')||
                                                        ' para '||to_char(pr_vldcampo,'fm999g999g999g999g990d00'));
        END if;
      END IF;
      
      
    ELSE
      -- Gravação conforme a entidade
      -- Buscar Informacoes do fluxo financeiro consolidado.
      OPEN cr_ffc_inst;
      FETCH cr_ffc_inst
        INTO rw_ffc_inst;

      IF cr_ffc_inst%NOTFOUND THEN
        CLOSE cr_ffc_inst;
        -- Se não existe o registro, deve inserir
        BEGIN
          INSERT INTO tbfin_fluxo_caixa_consolid
                   ( cdcooper
                    ,cdbccxlt
                    ,dtmvtolt
                    ,vlentradas
                    ,vlsaidas
                    ,vloutros
                    ,cdoperador
                    ,dtalteracao)
                 VALUES
                   ( pr_cdcooper -- cdcooper
                    ,pr_cdbccxlt -- cdbccxlt
                    ,pr_dtmvtolt -- dtmvtolt
                    ,DECODE(pr_tpdcampo,1,pr_vldcampo,0)-- vlentrad
                    ,DECODE(pr_tpdcampo,2,pr_vldcampo,0)-- vlsaidas
                    ,DECODE(pr_tpdcampo,6,pr_vldcampo,0)-- vloutros
                    ,nvl(pr_cdoperad,'1')
                    ,SYSDATE
                    );
        EXCEPTION
          WHEN OTHERS THEN
            pr_dscritic := 'Erro ao inserir tbfin_fluxo_caixa_consolid: '|| SQLerrm;
            return;
        END;
      ELSE
        CLOSE cr_ffc_inst;        
        -- Se ja existe o registro, apenas altera
        BEGIN
          UPDATE tbfin_fluxo_caixa_consolid
             SET vlentradas = DECODE(pr_tpdcampo,1,pr_vldcampo,vlentradas),
                 vlsaidas = DECODE(pr_tpdcampo,2,pr_vldcampo,vlsaidas),
                 vloutros = DECODE(pr_tpdcampo,6,pr_vldcampo,DECODE(pr_tpdcampo,6,0,vloutros)),
                 cdoperador = nvl(vr_cdoperad,cdoperador),
                 dtalteracao = nvl(vr_dttransa,dtalteracao)
           WHERE rowid = rw_ffc_inst.rowid;
        EXCEPTION
          WHEN OTHERS THEN
            pr_dscritic := 'Erro ao atualizar tbfin_fluxo_caixa_consolid: '|| SQLerrm;
            return;
        END;
      END IF;
      -- Gerar Log fluxos.log
      IF pr_tpdcampo = 6 THEN
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                  ,pr_ind_tipo_log => 1 -- apenas log
                                  ,pr_nmarqlog     => 'fluxos'
                                  ,pr_des_log      => to_char(pr_dtmvtolt,'DD/MM/RRRR') ||' '||to_char(sysdate,'hh24:mi:ss')||
                                                      ' --> Operador '|| pr_cdoperad ||
                                                      ' - alterou o valor diversos de '||
                                                      to_char(rw_ffc_inst.vloutros,'fm999g999g999g999g990d00')||
                                                      ' para '||to_char(pr_vldcampo,'fm999g999g999g999g990d00') ||
                                                      ', banco '|| pr_cdbccxlt);
      END IF;
      
    END IF;
    
    pr_dscritic := 'OK';

  END pc_grava_consolidado_singular;

  -- Função para retornar a lista de dias conforme o dia passado como parametro
  FUNCTION fn_Busca_Lista_Dias(pr_dtdiames IN varchar2)
           RETURN VARCHAR2 IS
  -- .........................................................................
  --
  --  Programa : fn_Busca_Lista_Dias          Antigo: b1wgen0131.p/fnBuscaListaDias
  --
  --  Sistema  : Cred
  --  Sigla    : FLXF0001
  --  Autor    : Odirlei Busana
  --  Data     : novembro/2013.                   Ultima atualizacao: 13/11/2013
  --
  --  Dados referentes ao programa:
  --
  --   Objetivo  : Retorna a lista de dias conforme o dia passado como parametro
  --
  --   Atualizacao: 13/11/2013 - Conversao Progress => Oracle (Odirlei-AMcom)
  --..........................................................................
  BEGIN

    IF pr_dtdiames IN (1,2,3) THEN
      RETURN '01,02,03';
    ELSIF pr_dtdiames IN (4) THEN
      RETURN '01,02,03,04';
    ELSIF pr_dtdiames IN (5,6,7,8,9) THEN
      RETURN '06,07,08,09';
    ELSIF pr_dtdiames IN (10,11,12) THEN
      RETURN '10,11,12,13,14';
    ELSIF pr_dtdiames IN (13,14) THEN
      RETURN '11,12,13,14';
    ELSIF pr_dtdiames IN (15) THEN
      RETURN '15,16,17,18';
    ELSIF pr_dtdiames IN (16) THEN
      RETURN '15,16,17,18,19';
    ELSIF pr_dtdiames IN (17,18,19) THEN
      RETURN '16,17,18,19';
    ELSIF pr_dtdiames IN (20,21) THEN
      RETURN '20,21,22,23,24';
    ELSIF pr_dtdiames IN (22,23,24) THEN
      RETURN '21,22,23,24';
    ELSIF pr_dtdiames IN (25,26,27,28) THEN
      RETURN '26,27,28,29';
    ELSIF pr_dtdiames IN (29,30) THEN
      RETURN '26,27,28,29,30';
    ELSIF pr_dtdiames IN (31) THEN
      RETURN '26,27,28,29,30,31';
    ELSE
      RETURN pr_dtdiames;
    END IF;

  END fn_Busca_Lista_Dias;

  -- Função retornar a quantidade de dias uteis
  FUNCTION fn_Calcula_Dia_Util(pr_dtdiames IN Integer)
           RETURN VARCHAR2 IS
  -- .........................................................................
  --
  --  Programa : fn_Calcula_Dia_Util          Antigo: b1wgen0131.p/fnCalculaDiaUtil
  --
  --  Sistema  : Cred
  --  Sigla    : FLXF0001
  --  Autor    : Odirlei Busana
  --  Data     : novembro/2013.                   Ultima atualizacao: 13/11/2013
  --
  --  Dados referentes ao programa:
  --
  --   Objetivo  : Retorna a quantidade de dias uteis
  --
  --   Atualizacao: 13/11/2013 - Conversao Progress => Oracle (Odirlei-AMcom)
  --..........................................................................

  vr_tab_CalcDiaUtil typ_tab_ValDia;

  BEGIN
    --Monta temptable com os valores, o indice é o dia.
                                       -- dia :=  1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31
    vr_tab_CalcDiaUtil := typ_tab_ValDia(0,0,0,2,3,4,5,6,6, 7, 7, 8, 9,10, 0,11,12,12,13,14, 0, 0,16,16,17,18,19,20,21, 0, 0);

    return vr_tab_CalcDiaUtil(pr_dtdiames);

  END fn_Calcula_Dia_Util;

  -- Função retornar a quantidade de dias limite
  FUNCTION fn_busca_limite_Dia(pr_dtdiames IN Integer,
                               pr_tplimite IN NUMBER) -- Tipo de Limite (1 - Minimo 2 Maximo)
           RETURN VARCHAR2 IS
  -- .........................................................................
  --
  --  Programa : fn_busca_limite_Dia          Antigo: b1wgen0131.p/fnBuscaLimiteMinimo
  --                                                               fnBuscaLimiteMaximo
  --
  --  Sistema  : Cred
  --  Sigla    : FLXF0001
  --  Autor    : Odirlei Busana
  --  Data     : novembro/2013.                   Ultima atualizacao: 14/11/2013
  --
  --  Dados referentes ao programa:
  --
  --   Objetivo  : Retorna a quantidade de dias limite
  --
  --   Atualizacao: 14/11/2013 - Conversao Progress => Oracle (Odirlei-AMcom)
  --..........................................................................

  vr_tab_LimDia typ_tab_ValDia;

  BEGIN
    --Monta temptable com os valores, o indice é o dia.

    IF pr_tplimite = 1 THEN -- LIMITE MINIMO
                                    -- dia :=  1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31
      vr_tab_LimDia := typ_tab_ValDia(0,0,0,0,5,5,5,5,5, 9, 9, 9,10,10,14,14,15,15,15,19,19,20,20,20,25,25,25,25,25,25,25);

      return NVL(vr_tab_LimDia(pr_dtdiames),0);

    ELSIF pr_tplimite = 2 THEN -- LIMITE MAXIMO
                                    -- dia :=  1,2,3,4, 5, 6, 7, 8, 9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31
      vr_tab_LimDia := typ_tab_ValDia(3,3,3,5,10,10,10,10,10,15,15,15,15,15,19,20,20,20,20,25,25,25,25,25,30,20,30,30,31,31,99);

      return NVL(vr_tab_LimDia(pr_dtdiames),99);
    END IF;

  END fn_busca_limite_Dia;

  -- Função para identificar o banco da agencia
  FUNCTION fn_identifica_bcoctl(pr_cdcooper IN Integer, -- codigo da cooperativa
                                pr_cdagenci IN Integer, -- Codigo da agencia
                                pr_idtpdoct IN VARCHAR2)-- Tipo de documento (T-titulo,D-doc,C-cheque)

           RETURN NUMBER IS
  -- .........................................................................
  --
  --  Programa : pc_busca_dados_flx_singular          Antigo: b1wgen0131.p/pi_identifica_bcoctl
  --
  --
  --  Sistema  : Cred
  --  Sigla    : FLXF0001
  --  Autor    : Odirlei Busana
  --  Data     : novembro/2013.                   Ultima atualizacao: 20/11/2013
  --
  --  Dados referentes ao programa:
  --
  --   Objetivo  : Identificar o banco da agencia
  --
  --   Atualizacao: 20/11/2013 - Conversao Progress => Oracle (Odirlei-AMcom)
  --..........................................................................

    -- buscar codigo do banco no cadastro da agencia
    CURSOR cr_crapage IS
      SELECT (CASE pr_idtpdoct
               WHEN 'T' THEN cdbantit
               WHEN 'D' THEN cdbandoc
               WHEN 'C' THEN cdbanchq
              END) cdbanco
        FROM crapage
       WHERE crapage.cdcooper = pr_cdcooper
         AND crapage.cdagenci = nvl(pr_cdagenci,0);
    rw_crapage cr_crapage%rowtype;

  BEGIN

    -- buscar agencia
    OPEN cr_crapage;
    FETCH cr_crapage
      INTO rw_crapage;

    IF cr_crapage%NOTFOUND THEN
      CLOSE cr_crapage;
      RETURN NULL;
    ELSE
      CLOSE cr_crapage;

      -- Gerar identificador conforme o codigo do banco
      CASE rw_crapage.cdbanco
        WHEN 85   THEN RETURN 1;
        WHEN 1    THEN RETURN 2;
        WHEN 756  THEN RETURN 3;
      END CASE;
    END IF;

  END fn_identifica_bcoctl;
  
  -- Função retornar o numero de dia util
  FUNCTION fn_retorna_numero_dia_util(pr_cdcooper in NUMBER   -- codigo da cooperativa
                                     ,pr_dtdatmes IN DATE)    -- Data do periodo
           RETURN INTEGER IS
  -- .........................................................................
  --
  --  Programa : Fn_retorna_numero_dia_util          
  --
  --
  --  Sistema  : Cred
  --  Sigla    : FLXF0001
  --  Autor    : Marcos Martini
  --  Data     : Outubro/2016.                   Ultima atualizacao: 
  --  
  --  Dados referentes ao programa:
  --
  --   Objetivo  : Retorna o numero do dia util no mês 
  --
  --   Atualizacao: 
  --..........................................................................

    vr_dtverdat date;
    vr_contador number := 0;

  BEGIN
    -- selecionar primeiro dia do mês
    vr_dtverdat := trunc(pr_dtdatmes,'MM');

    -- Varrer dias do mês ate encontrar a data ou mudar de mes
    WHILE trunc(vr_dtverdat,'MM') = trunc(pr_dtdatmes,'MM')
      AND vr_dtverdat <= pr_dtdatmes LOOP
      -- Se não for domingo ou sabado e não for feriado
      IF NOT fn_verifica_feriado(pr_cdcooper,vr_dtverdat) THEN
        vr_contador := vr_contador + 1;
      END IF;
      vr_dtverdat := vr_dtverdat + 1;
    END LOOP;

    -- Retornar o contador 
    RETURN vr_contador;

  END fn_retorna_numero_dia_util;  

  -- Função retornar o numero dia util N no mês
  FUNCTION Fn_retorna_dia_util_n(pr_cdcooper in NUMBER   -- codigo da cooperativa
                                ,pr_numdiaut IN INTEGER  -- Numero de dia calculado
                                ,pr_dtdatmes IN DATE)    -- Data do periodo
           RETURN INTEGER IS
  -- .........................................................................
  --
  --  Programa : Fn_retorna_dia_util_n          Antigo: b1wgen0131.p/fnRetornaNumeroDiaUtilChqDoc
  --                                                                 fnRetornaNumeroDiaUtilTitulo
  --                                                                 fnRetornaNumeroDiaUtilItg
  --
  --
  --
  --  Sistema  : Cred
  --  Sigla    : FLXF0001
  --  Autor    : Odirlei Busana
  --  Data     : novembro/2013.                   Ultima atualizacao: 14/11/2013
  --
  --  Dados referentes ao programa:
  --
  --   Objetivo  : Retorna o numero de dia util para o chqdoc
  --
  --   Atualizacao: 14/11/2013 - Conversao Progress => Oracle (Odirlei-AMcom)
  --..........................................................................

    vr_dtverdat date;
    vr_contador number := 0;

  BEGIN
    -- selecionar primeiro dia do mês
    vr_dtverdat := trunc(pr_dtdatmes,'MM');

    -- Varrer dias do mês
    WHILE trunc(vr_dtverdat,'MM') = trunc(pr_dtdatmes,'MM')  LOOP
      -- Se não for domingo ou sabado e não for feriado
      IF NOT fn_verifica_feriado(pr_cdcooper,vr_dtverdat) THEN

        vr_contador := vr_contador + 1;
        -- se o contador de dias uteis for igual a qtd de dias uteis calculado
        IF vr_contador = pr_numdiaut THEN
          -- sair do loop
          exit;
        END IF;
      END IF;
      vr_dtverdat := vr_dtverdat + 1;
    END LOOP;

    -- se o contador de dias uteis for igual a qtd de dias uteis calculado
    IF vr_contador = pr_numdiaut THEN
       RETURN to_char(vr_dtverdat,'DD');
    ELSE
       RETURN 0;
    END IF;

  END Fn_retorna_dia_util_n;

  -- Função para validar a quantidade de dias uteis do mes
  FUNCTION fn_Valida_Dias_Uteis_Mes( pr_cdcooper in number,  -- codigo da cooperativa
                                     pr_dtdatmes IN DATE)   -- Data do periodo
           RETURN BOOLEAN IS
  -- .........................................................................
  --
  --  Programa : fn_Valida_Dias_Uteis_Mes          Antigo: b1wgen0131.p/fnValidaDiasUteisMes
  --
  --
  --  Sistema  : Cred
  --  Sigla    : FLXF0001
  --  Autor    : Odirlei Busana
  --  Data     : novembro/2013.                   Ultima atualizacao: 14/11/2013
  --
  --  Dados referentes ao programa:
  --
  --   Objetivo  : Valida a quantidade de dias uteis do mes
  --
  --   Atualizacao: 14/11/2013 - Conversao Progress => Oracle (Odirlei-AMcom)
  --..........................................................................

    vr_dtverdat date;
    vr_contador number := 0;

  BEGIN
    -- selecionar primeiro dia do mês
    vr_dtverdat := to_date(to_char(pr_dtdatmes,'MMRRRR'),'MMRRRR');

    -- Varrer dias do mês
    WHILE TO_CHAR(vr_dtverdat,'MM') = TO_CHAR(pr_dtdatmes,'MM')  LOOP
      -- Se não for domingo ou sabado e não for feriado
      IF NOT fn_verifica_feriado(pr_cdcooper,vr_dtverdat) THEN
        -- incrementar contador
        vr_contador := vr_contador + 1;

      END IF;
      --Incrementar data
      vr_dtverdat := vr_dtverdat + 1;

    END LOOP;

    -- se a quantidade de dias uteis for maior ou igual a 20 dias
    RETURN (vr_contador >= 20);

  END fn_Valida_Dias_Uteis_Mes;

  -- Procedure para Verificar se o dia til anterior é feriado
  FUNCTION fn_feriado_dia_anterior ( pr_cdcooper in number -- codigo da cooperativa
                                    ,pr_dtrefmes in date ) -- Data atual
                                          return boolean AS
    -- .........................................................................
    --
    --  Programa : fn_feriado_dia_anterior          Antigo: b1wgen0131.p/fnDiaAnteriorEhFeriado
    --
    --  Sistema  : Cred
    --  Sigla    : FLXF0001
    --  Autor    : Odirlei Busana
    --  Data     : novembro/2013.                   Ultima atualizacao: 08/11/2013
    --
    --  Dados referentes ao programa:
    --
    --   Objetivo  : Verifica se o dia til anterior é feriado
    --
    --   Atualizacao: 08/11/2013 - Conversao Progress => Oracle (Odirlei-AMcom)
    --..........................................................................

    vr_datautil date;

  BEGIN

    vr_datautil := pr_dtrefmes - 1;

    -- Se for domingo diminui dois dias
    IF TO_CHAR(vr_datautil,'D') = 1 THEN
      vr_datautil := vr_datautil - 2;
    -- se for sabado diminui um dia
    ELSIF TO_CHAR(vr_datautil,'D') = 7 THEN
      vr_datautil := vr_datautil - 1;
    END IF;

    -- Retorna true se for feriado
    RETURN fn_verifica_feriado(pr_cdcooper => pr_cdcooper   -- codigo da cooperativa
                              ,pr_dtrefmes => vr_datautil); -- Data referencia

  END fn_feriado_dia_anterior;

  -- Procedure para buscar a data anterior ao feriado
  FUNCTION fn_Busca_Data_anterior_feriado ( pr_cdcooper in number -- codigo da cooperativa
                                          ,pr_dtrefmes in date ) -- Data atual
                                          return DATE AS
    -- .........................................................................
    --
    --  Programa : fn_Busca_Data_anterior_feriado          Antigo: b1wgen0131.p/fnBuscaDataAnteriorFeriado
    --
    --  Sistema  : Cred
    --  Sigla    : FLXF0001
    --  Autor    : Odirlei Busana
    --  Data     : novembro/2013.                   Ultima atualizacao: 08/11/2013
    --
    --  Dados referentes ao programa:
    --
    --   Objetivo  : Buscar a data anterior ao feriado
    --
    --   Atualizacao: 08/11/2013 - Conversao Progress => Oracle (Odirlei-AMcom)
    --..........................................................................

    vr_datautil date;

  BEGIN

    vr_datautil := pr_dtrefmes - 1;

    -- Se for domingo diminui dois dias
    IF TO_CHAR(vr_datautil,'D') = 1 THEN
      vr_datautil := vr_datautil - 2;
    -- Se for sabado diminui um dia
    ELSIF TO_CHAR(vr_datautil,'D') = 7 THEN
      vr_datautil := vr_datautil - 1;
    END IF;

    -- se for feriado retorna a data
    IF fn_verifica_feriado(pr_cdcooper => pr_cdcooper   -- codigo da cooperativa
                          ,pr_dtrefmes => vr_datautil) then -- Data referencia
      RETURN vr_datautil;
    ELSE
      -- senão retorna nulo
      RETURN NULL;
    END IF;

  END fn_Busca_Data_anterior_feriado;

  -- Procedure para Verificar se o dia é feriado
  FUNCTION fn_verifica_feriado( pr_cdcooper in number   -- codigo da cooperativa
                               ,pr_dtrefmes in date     -- Data referencia
                                )
                                          return boolean AS
    -- .........................................................................
    --
    --  Programa : fn_verifica_feriado          Antigo: b1wgen0131.p/fnEhFeriado
    --
    --  Sistema  : Cred
    --  Sigla    : FLXF0001
    --  Autor    : Odirlei Busana
    --  Data     : novembro/2013.                   Ultima atualizacao: 21/10/2016
    --
    --  Dados referentes ao programa:
    --
    --   Objetivo  : Verifica se o dia é feriado
    --
    --   Atualizacao: 08/11/2013 - Conversao Progress => Oracle (Odirlei-AMcom)
    -- 
    --                21/10/2016 - Usar checagem de feriado da gene005 (Marcos-Supero)
    --..........................................................................

  BEGIN

    -- Se a data passada <> data util da mesma
    IF pr_dtrefmes <> gene0005.fn_valida_dia_util(pr_cdcooper,pr_dtrefmes) THEN
      -- Não é util
      RETURN TRUE;
    ELSE
      -- é data util 
      RETURN FALSE;
    END IF;

  END fn_verifica_feriado;

  -- Procedure para Validar a regra de media de dia util
     FUNCTION fn_valid_Media_Dia_Util_Semana ( pr_nrdiasme in varchar2 -- numero que representa o dia do mes
                                           ,pr_nrdiasse in varchar2 -- numero que representa o dia da semana
                                           ,pr_dtperiod in date     -- Data referencia
                                           ,pr_cdcooper in number   -- codigo da cooperativa
                                           ,pr_tipodoct in varchar2 -- Tipo de documento (C-Cheque,T-Titulo-I-Conta Integração )
                                            )
                                          return boolean AS
    -- .........................................................................
    --
    --  Programa : fn_valid_Media_Dia_Util_Semana          Antigo: b1wgen0131.p/fnValidaRegraMediaDiasUteisDaSemanaItg
    --                                                                          fnValidaRegraMediaDiasUteisDaSemanaTitulo
    --                                                                          fnValidaRegraMediaDiasUteisDaSemanaChqDoc
    --
    --  Sistema  : Cred
    --  Sigla    : FLXF0001
    --  Autor    : Odirlei Busana
    --  Data     : novembro/2013.                   Ultima atualizacao: 08/11/2013
    --
    --  Dados referentes ao programa:
    --
    --   Objetivo  : Valida a regra de media de dia util
    --
    --   Atualizacao: 08/11/2013 - Conversao Progress => Oracle (Odirlei-AMcom)
    --..........................................................................


  BEGIN
       -- Verifica se existe o dia do mes na string
    IF GENE0002.fn_existe_valor(pr_base      => pr_nrdiasme              --> String que irá sofrer a busca
                               ,pr_busca     => TO_CHAR(pr_dtperiod,'DD')--> String objeto de busca
                               ,pr_delimite  => ',') = 'S'               --> String que será o delimitador)
       AND -- verifica se existe o dia da semana dentro da string
       GENE0002.fn_existe_valor(pr_base      => pr_nrdiasse               --> String que irá sofrer a busca
                               ,pr_busca     => TO_CHAR(pr_dtperiod,'D')  --> String objeto de busca
                               ,pr_delimite  => ',') = 'S'                --> String que será o delimitador)
       AND
       --Verifica se o dia é dia util, comparando o retorno da função com a data passada.
       (GENE0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper, --> Cooperativa conectada
                                    pr_dtmvtolt => pr_dtperiod, --> Data do movimento
                                    pr_tipo     => 'P',       --> Tipo de busca (P = proximo, A = anterior)
                                    pr_feriado  => TRUE)
           ) = pr_dtperiod AND
       -- verifica se o dia anterior nao é um feriado
       fn_feriado_dia_anterior ( pr_cdcooper => pr_cdcooper -- codigo da cooperativa
                                ,pr_dtrefmes => pr_dtperiod ) = FALSE then

      -- Se for validação de cheque
      IF pr_tipodoct = 'C' THEN
        -- Se for os primeiros 3 dias do mês, o mês precisa ter no minimo 20 dias uteis
       IF ( pr_nrdiasme in (1,2,3) AND
           fn_Valida_Dias_Uteis_Mes(pr_cdcooper,pr_dtperiod)) or
           pr_nrdiasme not in (1,2,3)THEN
          RETURN TRUE;
        ELSE
          RETURN FALSE;
        END IF;
      ELSE --senao retornar true
        RETURN TRUE;
      END IF;

    ELSE
      RETURN FALSE;
    END IF;

  END fn_valid_Media_Dia_Util_Semana;

  -- Procedure para Gerar temptable da media de datas de segunda feira
  PROCEDURE pc_regra_media_segfeira
                                    (pr_cdcooper  IN INTEGER     -- Codigo da Cooperativa
                                    ,pr_dtmvtolt  IN DATE        -- Data de movimento
                                    ,pr_listdias  IN VARCHAR2    -- Lista de dias do mes
                                    ,pr_cdagrupa  IN INTEGER DEFAULT NULL    -- Código de agrupamento
                                    ,pr_tab_per_datas IN OUT typ_tab_per_datas -- Tabela de datas
                                    ,pr_tab_datas     IN OUT typ_tab_datas -- tabela com as datas para controle
                                    ,pr_dscritic OUT VARCHAR2) AS -- Descrição da critica

    -- .........................................................................
    --
    --  Programa : pc_regra_media_segfeira          Antigo: b1wgen0131.p/RegraMediaSegundaFeiraChqDoc
    --                                                                   RegraMediaSegundaFeiraitg
    --                                                                   RegraMediaSegundaFeiratitulo
    --
    --  Sistema  : Cred
    --  Sigla    : FLXF0001
    --  Autor    : Odirlei Busana
    --  Data     : novembro/2013.                   Ultima atualizacao: 11/11/2013
    --
    --  Dados referentes ao programa:
    --
    --   Objetivo  : Gera temptable da media de datas de segunda feira
    --
    --   Atualizacao: 08/11/2013 - Conversao Progress => Oracle (Odirlei-AMcom)
    --..........................................................................
    
    vr_dtmvtolt   DATE;
    vr_dtperiod   DATE;
    vr_idx        VARCHAR2(12);

  BEGIN
    -- Se o dia passada for superior ao dia do sistema
    IF pr_dtmvtolt > trunc(SYSDATE) THEN
      -- Usaremos o dia do sistema
      vr_dtmvtolt := trunc(SYSDATE);
    ELSE
      -- usaremos o dia passado
      vr_dtmvtolt := pr_dtmvtolt;
    END IF;
    
    -- Varrer os ultmos 360 dias    
    vr_dtperiod := vr_dtmvtolt - 360;
    WHILE vr_dtperiod < vr_dtmvtolt LOOP
      -- Verifica se existe o dia do mes na string
      IF GENE0002.fn_existe_valor(pr_base      => pr_listdias              --> String que irá sofrer a busca
                                 ,pr_busca     => TO_CHAR(vr_dtperiod,'DD')--> String objeto de busca
                                 ,pr_delimite  => ',') = 'S'               --> String que será o delimitador)
           -- Verifica se é segunda feira
           AND TO_CHAR(vr_dtperiod,'D') = 2
           AND
           --Verifica se o dia é dia util, comparando o retorno da função com a data passada.
           (GENE0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper, --> Cooperativa conectada
                                        pr_dtmvtolt => vr_dtperiod, --> Data do movimento
                                        pr_tipo     => 'P',       --> Tipo de busca (P = proximo, A = anterior)
                                        pr_feriado  => TRUE)
               ) = vr_dtperiod AND
           -- verifica se o dia anterior nao é um feriado
           fn_feriado_dia_anterior ( pr_cdcooper => pr_cdcooper -- codigo da cooperativa
                                    ,pr_dtrefmes => vr_dtperiod ) = FALSE then

        --se ainda não existe a data, então inserir
        IF pr_tab_datas.EXISTS(TO_CHAR(vr_dtperiod,'DDMMRRRR')) = FALSE THEN
          --Buscar sequencial
          vr_idx := lpad(pr_cdagrupa,3,'0')||TO_CHAR(vr_dtperiod,'RRRRMMDD');
          pr_tab_per_datas(vr_idx).dtmvtolt := vr_dtperiod;
          pr_tab_per_datas(vr_idx).cdagrupa := pr_cdagrupa;
          --controle que ja gravou a data
          pr_tab_datas(TO_CHAR(vr_dtperiod,'DDMMRRRR')) := 1;
        END IF;
      END IF;
      -- incrementar data
      vr_dtperiod := vr_dtperiod + 1;
    END LOOP;

    pr_dscritic := 'OK';

  END pc_regra_media_segfeira;

  -- Procedure para Gerar temptable da media de datas util de segunda feira
  PROCEDURE pc_media_dia_util_segfeira
                                    (pr_cdcooper  IN INTEGER    -- Codigo da Cooperativa
                                    ,pr_dtmvtolt  IN DATE       -- Data de movimento
                                    ,pr_numdiaut  IN INTEGER    -- Numero de dia calculado
                                    ,pr_diaminim  IN INTEGER    -- Qtd de dias limite minimo
                                    ,pr_diamaxim  IN INTEGER    -- Qtd de dias limite maximo
                                    ,pr_tab_per_datas IN OUT typ_tab_per_datas -- Tabela de datas
                                    ,pr_tab_datas     IN OUT typ_tab_datas     -- tabela com as datas para controle
                                    ,pr_dscritic OUT VARCHAR2) AS              -- Descrição da critica

    -- .........................................................................
    --
    --  Programa : pc_media_dia_util_segfeira          Antigo: b1wgen0131.p/RegraMediaDiaUtilSegundaFeira
    --
    --
    --  Sistema  : Cred
    --  Sigla    : FLXF0001
    --  Autor    : Odirlei Busana
    --  Data     : novembro/2013.                   Ultima atualizacao: 14/11/2013
    --
    --  Dados referentes ao programa:
    --
    --   Objetivo  : Gera temptable da media de datas util de segunda feira
    --
    --   Atualizacao: 14/11/2013 - Conversao Progress => Oracle (Odirlei-AMcom)
    --..........................................................................
    
    vr_dtmvtolt   DATE;
    vr_dtperiod   DATE;
    vr_idx        VARCHAR2(12);
    vr_numdiaut   INTEGER;

  BEGIN
    
    -- Se o dia passada for superior ao dia do sistema
    IF pr_dtmvtolt > trunc(SYSDATE) THEN
      -- Usaremos o dia do sistema
      vr_dtmvtolt := trunc(SYSDATE);
    ELSE
      -- usaremos o dia passado
      vr_dtmvtolt := pr_dtmvtolt;
    END IF;  
    
    -- Varrer os ultmos 360 dias
    vr_dtperiod := vr_dtmvtolt - 360;     
    WHILE vr_dtperiod < vr_dtmvtolt LOOP

      vr_numdiaut := Fn_retorna_dia_util_n(pr_cdcooper => pr_cdcooper,  -- codigo da cooperativa
                                           pr_numdiaut => pr_numdiaut,  -- Numero de dia calculado
                                           pr_dtdatmes => vr_dtperiod); -- Data do periodo


      IF (TO_CHAR(VR_dtperiod,'D') = 2)   AND
         (TO_CHAR(VR_dtperiod,'DD') = vr_numdiaut) AND
         (vr_numdiaut < pr_diamaxim)      AND
         (vr_numdiaut > pr_diaminim)      THEN

        --se ainda não existe a data, então inserir
        IF pr_tab_datas.EXISTS(TO_CHAR(vr_dtperiod,'DDMMRRRR')) = FALSE THEN
          --Buscar sequencial
          vr_idx := '000'||TO_CHAR(vr_dtperiod,'RRRRMMDD');
          pr_tab_per_datas(vr_idx).dtmvtolt := vr_dtperiod;
          --controle que ja gravou a data
          pr_tab_datas(TO_CHAR(vr_dtperiod,'DDMMRRRR')) := 1;
        END IF;
      END IF;

      -- incrementar data
      vr_dtperiod := vr_dtperiod + 1;
    END LOOP;

    pr_dscritic := 'OK';

  END pc_media_dia_util_segfeira;

  -- Procedure para Gerar temptable da media de datas com as primeiras segundas feiras uteis
  PROCEDURE pc_media_pri_dutil_segfeira
                                    (pr_cdcooper  IN INTEGER    -- Codigo da Cooperativa
                                    ,pr_dtmvtolt  IN DATE       -- Data de movimento
                                    ,pr_cdagrupa  IN INTEGER   -- Codigo do agrupamento
                                    ,pr_tab_per_datas IN OUT typ_tab_per_datas -- Tabela de datas
                                    ,pr_tab_datas     IN OUT typ_tab_datas     -- tabela com as datas para controle
                                    ,pr_dscritic OUT VARCHAR2) AS              -- Descrição da critica

    -- .........................................................................
    --
    --  Programa : pc_media_pri_dutil_segfeira          Antigo: b1wgen0131.p/RegraMediaPrimeiroDiaUtilSegundaFeiraTit
    --                                                                       RegraMediaPrimeiroDiaUtilSegundaFeiraItg
    --
    --
    --  Sistema  : Cred
    --  Sigla    : FLXF0001
    --  Autor    : Odirlei Busana
    --  Data     : novembro/2013.                   Ultima atualizacao: 14/11/2013
    --
    --  Dados referentes ao programa:
    --
    --   Objetivo  : Gera temptable da media de datas com as primeiras segundas feiras uteis
    --
    --   Atualizacao: 14/11/2013 - Conversao Progress => Oracle (Odirlei-AMcom)
    --..........................................................................

    vr_dtmvtolt   DATE;
    vr_dtperiod   DATE;
    vr_idx        VARCHAR2(12);
    vr_numdiaut   INTEGER;

  BEGIN
    
    -- Se o dia passada for superior ao dia do sistema
    IF pr_dtmvtolt > trunc(SYSDATE) THEN
      -- Usaremos o dia do sistema
      vr_dtmvtolt := trunc(SYSDATE);
    ELSE
      -- usaremos o dia passado
      vr_dtmvtolt := pr_dtmvtolt;
    END IF; 
    
    -- Varrer os ultmos 360 dias
    vr_dtperiod := vr_dtmvtolt - 360;
    WHILE vr_dtperiod < vr_dtmvtolt LOOP

      -- Buscar primeiro dia util do mês
      vr_numdiaut := Fn_retorna_dia_util_n(pr_cdcooper => pr_cdcooper,  -- codigo da cooperativa
                                           pr_numdiaut => 1,            -- Numero de dia calculado
                                           pr_dtdatmes => vr_dtperiod); -- Data do periodo


      IF (TO_CHAR(VR_dtperiod,'D') = 2)   AND
         (TO_CHAR(VR_dtperiod,'DD') = vr_numdiaut) AND
         (NOT fn_feriado_dia_anterior(pr_cdcooper,vr_dtperiod) ) THEN

        --se ainda não existe a data, então inserir
        IF pr_tab_datas.EXISTS(TO_CHAR(vr_dtperiod,'DDMMRRRR')) = FALSE THEN
          --Buscar sequencial
          vr_idx := '000'||TO_CHAR(vr_dtperiod,'RRRRMMDD');
          pr_tab_per_datas(vr_idx).dtmvtolt := vr_dtperiod;
          pr_tab_per_datas(vr_idx).cdagrupa := pr_cdagrupa;
          --controle que ja gravou a data
          pr_tab_datas(TO_CHAR(vr_dtperiod,'DDMMRRRR')) := 1;
        END IF;
      END IF;

      -- incrementar data
      vr_dtperiod := vr_dtperiod + 1;
    END LOOP;

    pr_dscritic := 'OK';

  END pc_media_pri_dutil_segfeira;

  -- Procedure para Gerar temptable da media de datas
  PROCEDURE pc_med_dia_util_semana  (pr_cdcooper IN INTEGER      -- Codigo da Cooperativa
                                    ,pr_dtmvtolt IN DATE         -- Data de movimento
                                    ,pr_nrdiasse IN VARCHAR2     -- Numero que representa o dia da semana
                                    ,pr_nrdiasme IN VARCHAR2     -- Numero que representa o dia do mes
                                    ,pr_cdagrupa IN INTEGER DEFAULT NULL       -- Código de agrupamento
                                    ,pr_tipodoct in varchar2     -- Tipo de documento (C-Cheque,T-Titulo-I-Conta Integração )
                                    ,pr_tab_per_datas IN OUT typ_tab_per_datas -- Tabela de datas
                                    ,pr_tab_datas     IN OUT typ_tab_datas     -- tabela com as datas para controle
                                    ,pr_dscritic OUT VARCHAR2) AS -- Descrição da critica

    -- .........................................................................
    --
    --  Programa : pc_med_dia_util_semana          Antigo: b1wgen0131.p/RegraMediaDiasUteisDaSemanaItg
    --                                                                  RegraMediaDiasUteisDaSemanaChqDoc
    --                                                                  RegraMediaDiasUteisDaSemanaTitulo
    --
    --
    --  Sistema  : Cred
    --  Sigla    : FLXF0001
    --  Autor    : Odirlei Busana
    --  Data     : novembro/2013.                   Ultima atualizacao: 11/11/2013
    --
    --  Dados referentes ao programa:
    --
    --   Objetivo  : Gera temptable da media de datas
    --
    --   Atualizacao: 08/11/2013 - Conversao Progress => Oracle (Odirlei-AMcom)
    --..........................................................................
    
    vr_dtmvtolt   DATE;
    vr_dtperiod   DATE;
    vr_tab_diasme GENE0002.typ_split := GENE0002.fn_quebra_string(pr_string => pr_nrdiasme);
    vr_idx        varchar2(15);

  BEGIN
    
      -- Se o dia passada for superior ao dia do sistema
    IF pr_dtmvtolt > trunc(SYSDATE) THEN
      -- Usaremos o dia do sistema
      vr_dtmvtolt := trunc(SYSDATE);
    ELSE
      -- usaremos o dia passado
      vr_dtmvtolt := pr_dtmvtolt;
    END IF; 
    
    -- Varrer os ultmos 360 dias
    vr_dtperiod := vr_dtmvtolt - 360;
    WHILE vr_dtperiod < vr_dtmvtolt LOOP
      -- se for diferente da validação de chequeDoc
      -- e conter dois dias mês informado
      IF pr_tipodoct <> 'C' AND --RegraMediaDiasUteisDaSemanaChqDoc
         vr_tab_diasme.COUNT = 2 THEN
        IF fn_valid_Media_Dia_Util_Semana ( pr_nrdiasme => pr_nrdiasme -- numero que representa o dia do mes
                                           ,pr_nrdiasse => pr_nrdiasse -- numero que representa o dia da semana
                                           ,pr_dtperiod => vr_dtperiod -- Data referencia
                                           ,pr_cdcooper => pr_cdcooper -- codigo da cooperativa
                                           ,pr_tipodoct => pr_tipodoct)-- Tipo de documento (C-Cheque,T-Titulo-I-Conta Integração )
          AND
           fn_valid_Media_Dia_Util_Semana ( pr_nrdiasme => pr_nrdiasme -- numero que representa o dia do mes
                                           ,pr_nrdiasse => pr_nrdiasse -- numero que representa o dia da semana
                                           ,pr_dtperiod => vr_dtperiod + 1   -- Data referencia
                                           ,pr_cdcooper => pr_cdcooper -- codigo da cooperativa
                                           ,pr_tipodoct => pr_tipodoct)THEN-- Tipo de documento (C-Cheque,T-Titulo-I-Conta Integração )

          --se ainda não existe a data, então inserir
          IF pr_tab_datas.EXISTS(TO_CHAR(vr_dtperiod,'DDMMRRRR')) = FALSE THEN
            --Buscar sequencial
            vr_idx := lpad(pr_cdagrupa,3,'0')||TO_CHAR(vr_dtperiod,'RRRRMMDD');
            pr_tab_per_datas(vr_idx).dtmvtolt := vr_dtperiod;
            pr_tab_per_datas(vr_idx).cdagrupa := pr_cdagrupa;
            --controle que ja gravou a data
            pr_tab_datas(TO_CHAR(vr_dtperiod,'DDMMRRRR')) := 1;
          END IF;

          --se ainda não existe a data + 1, então inserir
          IF pr_tab_datas.EXISTS(TO_CHAR(vr_dtperiod + 1,'DDMMRRRR')) = FALSE THEN
            --Buscar sequencial
            vr_idx := lpad(pr_cdagrupa,3,'0')||TO_CHAR(vr_dtperiod,'RRRRMMDD');
            pr_tab_per_datas(vr_idx).dtmvtolt := vr_dtperiod + 1;
            pr_tab_per_datas(vr_idx).cdagrupa := pr_cdagrupa;

            --controle que ja gravou a data
            pr_tab_datas(TO_CHAR(vr_dtperiod,'DDMMRRRR')) := 1;
          END IF;

        END IF; -- Fim fn_valid_Media_Dia_Util_Semana
      ELSE
        IF fn_valid_Media_Dia_Util_Semana ( pr_nrdiasme => pr_nrdiasme -- numero que representa o dia do mes
                                           ,pr_nrdiasse => pr_nrdiasse -- numero que representa o dia da semana
                                           ,pr_dtperiod => vr_dtperiod -- Data referencia
                                           ,pr_cdcooper => pr_cdcooper -- codigo da cooperativa
                                           ,pr_tipodoct => pr_tipodoct) THEN -- Tipo de documento (C-Cheque,T-Titulo-I-Conta Integração )



          --se ainda não existe a data, então inserir
          IF pr_tab_datas.EXISTS(TO_CHAR(vr_dtperiod,'DDMMRRRR')) = FALSE THEN
            --Buscar sequencial
            vr_idx := lpad(pr_cdagrupa,3,'0')||TO_CHAR(vr_dtperiod,'RRRRMMDD');
            pr_tab_per_datas(vr_idx).dtmvtolt := vr_dtperiod;
            pr_tab_per_datas(vr_idx).cdagrupa := pr_cdagrupa;
            --controle que ja gravou a data
            pr_tab_datas(TO_CHAR(vr_dtperiod,'DDMMRRRR')) := 1;
          END IF;

        END IF; -- Fim fn_valid_Media_Dia_Util_Semana


      END IF; -- Fim vr_tab_diasme.COUNT = 2

      -- incrementar data
      vr_dtperiod := vr_dtperiod + 1;

    END LOOP;

    pr_dscritic := 'OK';

  END pc_med_dia_util_semana;

  -- Procedimento para gerar o periodo de projeção dos titulos
  PROCEDURE pc_gera_periodo_projecao_tit
                                    (pr_cdcooper IN INTEGER      -- Codigo da Cooperativa
                                    ,pr_dtmvtolt IN DATE         -- Data de movimento
                                    ,pr_cdagrupa IN INTEGER      -- Código de agrupamento
                                    ,pr_tab_per_datas OUT typ_tab_per_datas -- Tabela de datas
                                    ,pr_dscritic      OUT VARCHAR2) AS      -- Descrição da critica

    -- .........................................................................
    --
    --  Programa : pc_gera_periodo_projecao_tit          Antigo: b1wgen0131.p/gera-periodos-projecao-titulo
    --
    --  Sistema  : Cred
    --  Sigla    : FLXF0001
    --  Autor    : Odirlei Busana
    --  Data     : novembro/2013.                   Ultima atualizacao: 08/11/2013
    --
    --  Dados referentes ao programa:
    --
    --   Objetivo  : Gera os periodo de projeção titulo
    --
    --   Atualizacao: 19/11/2013 - Conversao Progress => Oracle (Odirlei-AMcom)
    --..........................................................................

  vr_dtnumdia Varchar2(5);
  vr_dtsemdia Varchar2(5);
  vr_listadia Varchar2(10);

  vr_tab_datas typ_tab_datas;

  BEGIN

    -- verifica se o dia anterior é feriado
    IF fn_feriado_dia_anterior(pr_cdcooper, pr_dtmvtolt) THEN
      -- chamar a propria rotina passando o dia anterior ao feriado
      pc_gera_periodo_projecao_tit (pr_cdcooper => pr_cdcooper      -- Codigo da Cooperativa
                                   ,pr_dtmvtolt => fn_Busca_Data_anterior_feriado(pr_cdcooper,pr_dtmvtolt)  -- Data de movimento
                                   ,pr_cdagrupa => pr_cdagrupa + 1  -- Código de agrupamento
                                   -- OUT
                                   ,pr_tab_per_datas => pr_tab_per_datas -- Tabela de datas
                                   ,pr_dscritic      => pr_dscritic);
    END IF;

    vr_dtnumdia := to_char(pr_dtmvtolt,'DD');
    vr_dtsemdia := to_char(pr_dtmvtolt,'D');

    -- Se for diferente de segunda-feira
    IF vr_dtsemdia <> 2 THEN

      vr_listadia := to_char(pr_dtmvtolt,'DD');
      pc_med_dia_util_semana (pr_cdcooper => pr_cdcooper      -- Codigo da Cooperativa
                             ,pr_dtmvtolt => pr_dtmvtolt      -- Data de movimento
                             ,pr_nrdiasse => '3,4,5,6'        -- Numero que representa o dia da semana
                             ,pr_nrdiasme => vr_listadia      -- Numero que representa o dia do mes
                             ,pr_cdagrupa => pr_cdagrupa      -- Código de agrupamento
                             ,pr_tipodoct => 'T'              -- Tipo de documento (C-Cheque,T-Titulo-I-Conta Integração )
                             --OUT
                             ,pr_tab_per_datas => pr_tab_per_datas -- Tabela de datas
                             ,pr_tab_datas     => vr_tab_datas     -- tabela com as datas para controle
                             ,pr_dscritic      => pr_dscritic);
    ELSE
      IF vr_dtnumdia in (1,2,3) THEN
        pc_media_pri_dutil_segfeira ( pr_cdcooper => pr_cdcooper -- Codigo da Cooperativa
                                     ,pr_dtmvtolt => pr_dtmvtolt -- Data de movimento
                                     ,pr_cdagrupa => pr_cdagrupa -- Código de agrupamento
                                     --OUT
                                     ,pr_tab_per_datas => pr_tab_per_datas -- Tabela de datas
                                     ,pr_tab_datas     => vr_tab_datas -- tabela com as datas para controle
                                     ,pr_dscritic      => pr_dscritic );
      ELSIF vr_dtnumdia = 4 THEN
        pc_regra_media_segfeira ( pr_cdcooper => pr_cdcooper -- Codigo da Cooperativa
                                 ,pr_dtmvtolt => pr_dtmvtolt -- Data de movimento
                                 ,pr_listdias => vr_dtnumdia -- Lista de dias do mes
                                 ,pr_cdagrupa => pr_cdagrupa -- Código de agrupamento
                                 --OUT
                                 ,pr_tab_per_datas => pr_tab_per_datas -- Tabela de datas
                                 ,pr_tab_datas     => vr_tab_datas     -- tabela com as datas para controle
                                 ,pr_dscritic      => pr_dscritic );

        IF NVL(pr_tab_per_datas.COUNT,0) = 0 THEN
          pc_regra_media_segfeira ( pr_cdcooper => pr_cdcooper -- Codigo da Cooperativa
                                   ,pr_dtmvtolt => pr_dtmvtolt -- Data de movimento
                                   ,pr_listdias => '02,03,04,05'   -- Lista de dias do mes
                                   ,pr_cdagrupa => pr_cdagrupa -- Código de agrupamento
                                   --OUT
                                   ,pr_tab_per_datas => pr_tab_per_datas -- Tabela de datas
                                   ,pr_tab_datas     => vr_tab_datas     -- tabela com as datas para controle
                                            ,pr_dscritic => pr_dscritic );
        END IF;

      ELSIF vr_dtnumdia in (5,6,7) THEN
        pc_regra_media_segfeira ( pr_cdcooper => pr_cdcooper -- Codigo da Cooperativa
                                 ,pr_dtmvtolt => pr_dtmvtolt -- Data de movimento
                                 ,pr_listdias => '05,06,07'     -- Lista de dias do mes
                                 ,pr_cdagrupa => pr_cdagrupa -- Código de agrupamento
                                 --OUT
                                 ,pr_tab_per_datas => pr_tab_per_datas -- Tabela de datas
                                 ,pr_tab_datas     => vr_tab_datas     -- tabela com as datas para controle
                                 ,pr_dscritic      => pr_dscritic );
      ELSIF vr_dtnumdia in (8,9) THEN
        pc_regra_media_segfeira ( pr_cdcooper => pr_cdcooper -- Codigo da Cooperativa
                                 ,pr_dtmvtolt => pr_dtmvtolt -- Data de movimento
                                 ,pr_listdias => vr_dtnumdia -- Lista de dias do mes
                                 ,pr_cdagrupa => pr_cdagrupa -- Código de agrupamento
                                 --OUT
                                 ,pr_tab_per_datas => pr_tab_per_datas -- Tabela de datas
                                 ,pr_tab_datas     => vr_tab_datas     -- tabela com as datas para controle
                                 ,pr_dscritic => pr_dscritic );

        IF NVL(pr_tab_per_datas.COUNT,0) = 0 THEN
          pc_regra_media_segfeira ( pr_cdcooper => pr_cdcooper -- Codigo da Cooperativa
                                   ,pr_dtmvtolt => pr_dtmvtolt -- Data de movimento
                                   ,pr_listdias => '08,09'   -- Lista de dias do mes
                                   ,pr_cdagrupa => pr_cdagrupa -- Código de agrupamento
                                   --OUT
                                   ,pr_tab_per_datas => pr_tab_per_datas -- Tabela de datas
                                   ,pr_tab_datas     => vr_tab_datas -- tabela com as datas para controle
                                   ,pr_dscritic => pr_dscritic );
        END IF;

      ELSIF vr_dtnumdia in (10,11,12) THEN
        pc_regra_media_segfeira ( pr_cdcooper => pr_cdcooper -- Codigo da Cooperativa
                                 ,pr_dtmvtolt => pr_dtmvtolt -- Data de movimento
                                 ,pr_listdias => '10,11,12'     -- Lista de dias do mes
                                 ,pr_cdagrupa => pr_cdagrupa -- Código de agrupamento
                                 --OUT
                                 ,pr_tab_per_datas => pr_tab_per_datas -- Tabela de datas
                                 ,pr_tab_datas     => vr_tab_datas     -- tabela com as datas para controle
                                 ,pr_dscritic => pr_dscritic );

      ELSIF vr_dtnumdia in (13,14) THEN
        pc_regra_media_segfeira ( pr_cdcooper => pr_cdcooper -- Codigo da Cooperativa
                                 ,pr_dtmvtolt => pr_dtmvtolt -- Data de movimento
                                 ,pr_listdias => vr_dtnumdia -- Lista de dias do mes
                                 ,pr_cdagrupa => pr_cdagrupa -- Código de agrupamento
                                 --OUT
                                 ,pr_tab_per_datas => pr_tab_per_datas -- Tabela de datas
                                 ,pr_tab_datas     => vr_tab_datas     -- tabela com as datas para controle
                                 ,pr_dscritic      => pr_dscritic );

        IF NVL(pr_tab_per_datas.COUNT,0) = 0 THEN
          pc_regra_media_segfeira ( pr_cdcooper => pr_cdcooper -- Codigo da Cooperativa
                                   ,pr_dtmvtolt => pr_dtmvtolt -- Data de movimento
                                   ,pr_listdias => '13,14'     -- Lista de dias do mes
                                   ,pr_cdagrupa => pr_cdagrupa -- Código de agrupamento
                                   --OUT
                                   ,pr_tab_per_datas => pr_tab_per_datas -- Tabela de datas
                                   ,pr_tab_datas     => vr_tab_datas     -- tabela com as datas para controle
                                   ,pr_dscritic => pr_dscritic );
        END IF;

      ELSIF vr_dtnumdia in (15,16,17) THEN
        pc_regra_media_segfeira ( pr_cdcooper => pr_cdcooper -- Codigo da Cooperativa
                                 ,pr_dtmvtolt => pr_dtmvtolt -- Data de movimento
                                 ,pr_listdias => '15,16,17'  -- Lista de dias do mes
                                 ,pr_cdagrupa => pr_cdagrupa -- Código de agrupamento
                                 --OUT
                                 ,pr_tab_per_datas => pr_tab_per_datas -- Tabela de datas
                                 ,pr_tab_datas     => vr_tab_datas     -- tabela com as datas para controle
                                 ,pr_dscritic      => pr_dscritic );
      ELSIF vr_dtnumdia in (18,19) THEN
        pc_regra_media_segfeira ( pr_cdcooper => pr_cdcooper -- Codigo da Cooperativa
                                 ,pr_dtmvtolt => pr_dtmvtolt -- Data de movimento
                                 ,pr_listdias => vr_dtnumdia -- Lista de dias do mes
                                 ,pr_cdagrupa => pr_cdagrupa -- Código de agrupamento
                                 --OUT
                                 ,pr_tab_per_datas => pr_tab_per_datas -- Tabela de datas
                                 ,pr_tab_datas     => vr_tab_datas     -- tabela com as datas para controle
                                 ,pr_dscritic => pr_dscritic );

        IF NVL(pr_tab_per_datas.COUNT,0) = 0 THEN
          pc_regra_media_segfeira ( pr_cdcooper => pr_cdcooper -- Codigo da Cooperativa
                                   ,pr_dtmvtolt => pr_dtmvtolt -- Data de movimento
                                   ,pr_listdias => '18,19'     -- Lista de dias do mes
                                   ,pr_cdagrupa => pr_cdagrupa -- Código de agrupamento
                                   --OUT
                                   ,pr_tab_per_datas => pr_tab_per_datas -- Tabela de datas
                                   ,pr_tab_datas     => vr_tab_datas     -- tabela com as datas para controle
                                   ,pr_dscritic => pr_dscritic );
        END IF;

      ELSIF vr_dtnumdia in (20,21,22) THEN
        pc_regra_media_segfeira ( pr_cdcooper => pr_cdcooper -- Codigo da Cooperativa
                                 ,pr_dtmvtolt => pr_dtmvtolt -- Data de movimento
                                 ,pr_listdias => '20,21,22'  -- Lista de dias do mes
                                 ,pr_cdagrupa => pr_cdagrupa -- Código de agrupamento
                                 --OUT
                                 ,pr_tab_per_datas => pr_tab_per_datas -- Tabela de datas
                                 ,pr_tab_datas     => vr_tab_datas     -- tabela com as datas para controle
                                 ,pr_dscritic => pr_dscritic );
      ELSIF vr_dtnumdia in (23,24) THEN
        pc_regra_media_segfeira ( pr_cdcooper => pr_cdcooper -- Codigo da Cooperativa
                                 ,pr_dtmvtolt => pr_dtmvtolt -- Data de movimento
                                 ,pr_listdias => vr_dtnumdia -- Lista de dias do mes
                                 ,pr_cdagrupa => pr_cdagrupa -- Código de agrupamento
                                 --OUT
                                 ,pr_tab_per_datas => pr_tab_per_datas -- Tabela de datas
                                 ,pr_tab_datas     => vr_tab_datas     -- tabela com as datas para controle
                                 ,pr_dscritic      => pr_dscritic );

        IF NVL(pr_tab_per_datas.COUNT,0) = 0 THEN
          pc_regra_media_segfeira ( pr_cdcooper => pr_cdcooper -- Codigo da Cooperativa
                                   ,pr_dtmvtolt => pr_dtmvtolt -- Data de movimento
                                   ,pr_listdias => '23,24'     -- Lista de dias do mes
                                   ,pr_cdagrupa => pr_cdagrupa -- Código de agrupamento
                                   --OUT
                                   ,pr_tab_per_datas => pr_tab_per_datas -- Tabela de datas
                                   ,pr_tab_datas     => vr_tab_datas     -- tabela com as datas para controle
                                   ,pr_dscritic => pr_dscritic );
        END IF;

      ELSIF vr_dtnumdia in (25,26,27) THEN
        pc_regra_media_segfeira ( pr_cdcooper => pr_cdcooper -- Codigo da Cooperativa
                                 ,pr_dtmvtolt => pr_dtmvtolt -- Data de movimento
                                 ,pr_listdias => '25,26,27'  -- Lista de dias do mes
                                 ,pr_cdagrupa => pr_cdagrupa -- Código de agrupamento
                                 --OUT
                                 ,pr_tab_per_datas => pr_tab_per_datas -- Tabela de datas
                                 ,pr_tab_datas     => vr_tab_datas     -- tabela com as datas para controle
                                 ,pr_dscritic      => pr_dscritic );

      ELSIF vr_dtnumdia in (28,29) THEN
        pc_regra_media_segfeira ( pr_cdcooper => pr_cdcooper -- Codigo da Cooperativa
                                 ,pr_dtmvtolt => pr_dtmvtolt -- Data de movimento
                                 ,pr_listdias => vr_dtnumdia -- Lista de dias do mes
                                 ,pr_cdagrupa => pr_cdagrupa -- Código de agrupamento
                                 --OUT
                                 ,pr_tab_per_datas => pr_tab_per_datas -- Tabela de datas
                                 ,pr_tab_datas     => vr_tab_datas     -- tabela com as datas para controle
                                 ,pr_dscritic      => pr_dscritic );

        IF NVL(pr_tab_per_datas.COUNT,0) = 0 THEN
          pc_regra_media_segfeira ( pr_cdcooper => pr_cdcooper -- Codigo da Cooperativa
                                   ,pr_dtmvtolt => pr_dtmvtolt -- Data de movimento
                                   ,pr_listdias => '28,29'     -- Lista de dias do mes
                                   ,pr_cdagrupa => pr_cdagrupa -- Código de agrupamento
                                   --OUT
                                   ,pr_tab_per_datas => pr_tab_per_datas -- Tabela de datas
                                   ,pr_tab_datas     => vr_tab_datas     -- tabela com as datas para controle
                                   ,pr_dscritic => pr_dscritic );
        END IF;

      ELSIF vr_dtnumdia in (30) THEN
        pc_regra_media_segfeira ( pr_cdcooper => pr_cdcooper -- Codigo da Cooperativa
                                 ,pr_dtmvtolt => pr_dtmvtolt -- Data de movimento
                                 ,pr_listdias => vr_dtnumdia -- Lista de dias do mes
                                 ,pr_cdagrupa => pr_cdagrupa -- Código de agrupamento
                                 --OUT
                                 ,pr_tab_per_datas => pr_tab_per_datas -- Tabela de datas
                                 ,pr_tab_datas     => vr_tab_datas     -- tabela com as datas para controle
                                 ,pr_dscritic      => pr_dscritic );

        IF NVL(pr_tab_per_datas.COUNT,0) = 0 THEN
          pc_regra_media_segfeira ( pr_cdcooper => pr_cdcooper -- Codigo da Cooperativa
                                   ,pr_dtmvtolt => pr_dtmvtolt -- Data de movimento
                                   ,pr_listdias => '30,31'     -- Lista de dias do mes
                                   ,pr_cdagrupa => pr_cdagrupa -- Código de agrupamento
                                   --OUT
                                   ,pr_tab_per_datas => pr_tab_per_datas -- Tabela de datas
                                   ,pr_tab_datas     => vr_tab_datas     -- tabela com as datas para controle
                                   ,pr_dscritic => pr_dscritic );
        END IF;
      ELSIF vr_dtnumdia in (31) THEN
        pc_regra_media_segfeira ( pr_cdcooper => pr_cdcooper -- Codigo da Cooperativa
                                 ,pr_dtmvtolt => pr_dtmvtolt -- Data de movimento
                                 ,pr_listdias => '30,31'     -- Lista de dias do mes
                                 ,pr_cdagrupa => pr_cdagrupa -- Código de agrupamento
                                 --OUT
                                 ,pr_tab_per_datas => pr_tab_per_datas -- Tabela de datas
                                 ,pr_tab_datas     => vr_tab_datas     -- tabela com as datas para controle
                                 ,pr_dscritic      => pr_dscritic );

      ELSE
        pc_regra_media_segfeira ( pr_cdcooper => pr_cdcooper -- Codigo da Cooperativa
                                 ,pr_dtmvtolt => pr_dtmvtolt -- Data de movimento
                                 ,pr_listdias => vr_dtnumdia -- Lista de dias do mes
                                 ,pr_cdagrupa => pr_cdagrupa -- Código de agrupamento
                                 --OUT
                                 ,pr_tab_per_datas => pr_tab_per_datas -- Tabela de datas
                                 ,pr_tab_datas     => vr_tab_datas     -- tabela com as datas para controle
                                 ,pr_dscritic      => pr_dscritic );
      END IF;
    END IF; --Fim vr_dtsemdia <> 2

  END pc_gera_periodo_projecao_tit;

  -- Procedure para gerar os periodo de projeção Itg
  PROCEDURE pc_gera_periodo_projecao_itg
                                    (pr_cdcooper IN INTEGER      -- Codigo da Cooperativa
                                    ,pr_dtmvtolt IN DATE         -- Data de movimento
                                    ,pr_cdagrupa IN INTEGER      -- Código de agrupamento
                                    ,pr_tab_per_datas OUT typ_tab_per_datas -- Tabela de datas
                                    ,pr_dscritic      OUT VARCHAR2) AS -- Descrição da critica

    -- .........................................................................
    --
    --  Programa : pc_grava_periodo_projecao_itg          Antigo: b1wgen0131.p/gera-periodos-projecao-itg
    --
    --  Sistema  : Cred
    --  Sigla    : FLXF0001
    --  Autor    : Odirlei Busana
    --  Data     : novembro/2013.                   Ultima atualizacao: 08/11/2013
    --
    --  Dados referentes ao programa:
    --
    --   Objetivo  : Gera os periodo de projeção Itg
    --
    --   Atualizacao: 08/11/2013 - Conversao Progress => Oracle (Odirlei-AMcom)
    --..........................................................................

  -- variavel para armazenar ultimo dia do ano
  vr_ultdiaan DATE;
  -- variavel para armazenar primeiro dia do ano
  vr_pridiaan DATE;
  vr_dtperiod DATE;

  vr_dtnumdia Varchar2(5);
  vr_dtsemdia Varchar2(5);
  vr_listadia Varchar2(10);
  vr_idx      Varchar2(15);

  vr_tab_datas typ_tab_datas;

  BEGIN

    -- Passar para a função o ultimo dia do ano (ex.31122013), e a funçao retorna o dia util anterior a essa data ou ela mesma.
    vr_ultdiaan := gene0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper, --> Cooperativa conectada
                                               pr_dtmvtolt => to_date('3112'||to_char(pr_dtmvtolt,'RRRR'),'DDMMRRRR'), --> Data do movimento
                                               pr_tipo     => 'A',       --> Tipo de busca (P = proximo, A = anterior)
                                               pr_feriado  => TRUE);

    -- Passar para a função o primeiro dia do ano (ex.01012013), e a funçao retorna o proximo dia util a essa data ou ela mesma.
    vr_pridiaan := gene0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper, --> Cooperativa conectada
                                               pr_dtmvtolt => to_date('0101'||to_char(pr_dtmvtolt,'RRRR'),'DDMMRRRR'), --> Data do movimento
                                               pr_tipo     => 'P',       --> Tipo de busca (P = proximo, A = anterior)
                                               pr_feriado  => TRUE);

    -- Verificar se é o ultimo dia do ano
    IF pr_dtmvtolt = vr_ultdiaan THEN
      -- Passar para a função o ultimo dia do ano anterior (ex.31122013), e a funçao retorna o dia util anterior a essa data ou ela mesma.
      vr_dtperiod := gene0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper, --> Cooperativa conectada
                                                 pr_dtmvtolt => to_date('3112'||(to_char(pr_dtmvtolt,'RRRR')-1), 'DDMMRRRR'), --> Data do movimento
                                                 pr_tipo     => 'A',       --> Tipo de busca (P = proximo, A = anterior)
                                                 pr_feriado  => TRUE);

      --se ainda não existe a data, então inserir
      IF vr_tab_datas.EXISTS(TO_CHAR(vr_dtperiod,'DDMMRRRR')) = FALSE THEN
        --Buscar sequencial
        vr_idx := lpad(pr_cdagrupa,3,'0')||TO_CHAR(vr_dtperiod,'RRRRMMDD');
        pr_tab_per_datas(vr_idx).dtmvtolt := vr_dtperiod;
        --controle que ja gravou a data
        Vr_tab_datas(TO_CHAR(vr_dtperiod,'DDMMRRRR')) := 1;
      END IF;

      pr_dscritic := 'OK';
      RETURN;

      -- Verificar se é o primeiro dia do ano
    ELSIF pr_dtmvtolt = vr_pridiaan THEN
      -- Passar para a função o primeiro dia do ano anterior (ex.31122013), e a funçao retorna o proximo dia util a essa data ou ela mesma.
      vr_dtperiod := gene0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper, --> Cooperativa conectada
                                                 pr_dtmvtolt => to_date('0101'||(to_char(pr_dtmvtolt,'RRRR')-1), 'DDMMRRRR'), --> Data do movimento
                                                 pr_tipo     => 'P',       --> Tipo de busca (P = proximo, A = anterior)
                                                 pr_feriado  => TRUE);

      --se ainda não existe a data, então inserir
      IF vr_tab_datas.EXISTS(TO_CHAR(vr_dtperiod,'DDMMRRRR')) = FALSE THEN
        --Buscar sequencial
        vr_idx := lpad(pr_cdagrupa,3,'0')||TO_CHAR(vr_dtperiod,'RRRRMMDD');
        pr_tab_per_datas(vr_idx).dtmvtolt := vr_dtperiod;
        --controle que ja gravou a data
        vr_tab_datas(TO_CHAR(vr_dtperiod,'DDMMRRRR')) := 1;
      END IF;

      pr_dscritic := 'OK';
      RETURN;

    -- verifica se o dia anterior é feriado
    ELSIF fn_feriado_dia_anterior(pr_cdcooper, pr_dtmvtolt) THEN
      -- chamar a propria rotina passando o dia anterior ao feriado
      pc_gera_periodo_projecao_itg (pr_cdcooper => pr_cdcooper      -- Codigo da Cooperativa
                                   ,pr_dtmvtolt => fn_Busca_Data_anterior_feriado(pr_cdcooper,pr_dtmvtolt)  -- Data de movimento
                                   ,pr_cdagrupa => pr_cdagrupa + 1  -- Código de agrupamento
                                   -- OUT
                                   ,pr_tab_per_datas => pr_tab_per_datas -- Tabela de datas
                                   ,pr_dscritic      => pr_dscritic);

    END IF; -- fim pr_dtmvtolt = vr_ultdiaan

    vr_dtnumdia := to_char(pr_dtmvtolt,'DD');
    vr_dtsemdia := to_char(pr_dtmvtolt,'D');

    -- Se for diferente de segunda-feira
    IF vr_dtsemdia <> 2 THEN
      vr_listadia := to_char(pr_dtmvtolt,'DD');
      --se for o ultimo dia do mes de fevereiro
      IF ((vr_dtnumdia = 28) OR (vr_dtnumdia = 29)) AND
          (last_day(pr_dtmvtolt) = pr_dtmvtolt) THEN

        pc_med_dia_util_semana (pr_cdcooper => pr_cdcooper      -- Codigo da Cooperativa
                               ,pr_dtmvtolt => pr_dtmvtolt      -- Data de movimento
                               ,pr_nrdiasse => '3,4,5,6'        -- Numero que representa o dia da semana
                               ,pr_nrdiasme => 30               -- Numero que representa o dia do mes
                               ,pr_cdagrupa => pr_cdagrupa      -- Código de agrupamento
                               ,pr_tipodoct => 'I'              -- Tipo de documento (C-Cheque,T-Titulo-I-Conta Integração )
                               --OUT
                               ,pr_tab_per_datas => pr_tab_per_datas -- Tabela de datas
                               ,pr_tab_datas     => vr_tab_datas     -- tabela com as datas para controle
                               ,pr_dscritic      => pr_dscritic);

      ELSE
        pc_med_dia_util_semana (pr_cdcooper => pr_cdcooper      -- Codigo da Cooperativa
                               ,pr_dtmvtolt => pr_dtmvtolt      -- Data de movimento
                               ,pr_nrdiasse => '3,4,5,6'        -- Numero que representa o dia da semana
                               ,pr_nrdiasme => vr_listadia      -- Numero que representa o dia do mes
                               ,pr_cdagrupa => pr_cdagrupa      -- Código de agrupamento
                               ,pr_tipodoct => 'I'              -- Tipo de documento (C-Cheque,T-Titulo-I-Conta Integração )
                               --OUT
                               ,pr_tab_per_datas => pr_tab_per_datas -- Tabela de datas
                               ,pr_tab_datas     => vr_tab_datas     -- tabela com as datas para controle
                               ,pr_dscritic      => pr_dscritic);
      END IF; -- Fim fevereiro
    ELSE
      IF vr_dtnumdia in (1,2,3) THEN
        pc_regra_media_segfeira ( pr_cdcooper => pr_cdcooper -- Codigo da Cooperativa
                                 ,pr_dtmvtolt => pr_dtmvtolt -- Data de movimento
                                 ,pr_listdias => '01,02,03'     -- Lista de dias do mes
                                 ,pr_cdagrupa => pr_cdagrupa -- Código de agrupamento
                                 --OUT
                                 ,pr_tab_per_datas => pr_tab_per_datas -- Tabela de datas
                                 ,pr_tab_datas     => vr_tab_datas     -- tabela com as datas para controle
                                 ,pr_dscritic      => pr_dscritic );
      ELSIF vr_dtnumdia = 4 THEN
        pc_regra_media_segfeira ( pr_cdcooper => pr_cdcooper -- Codigo da Cooperativa
                                 ,pr_dtmvtolt => pr_dtmvtolt -- Data de movimento
                                 ,pr_listdias => '01,02,03,04'   -- Lista de dias do mes
                                 ,pr_cdagrupa => pr_cdagrupa -- Código de agrupamento
                                 --OUT
                                 ,pr_tab_per_datas => pr_tab_per_datas -- Tabela de datas
                                 ,pr_tab_datas     => vr_tab_datas     -- tabela com as datas para controle
                                          ,pr_dscritic      => pr_dscritic );
      ELSIF vr_dtnumdia in (5,6,7) THEN
        pc_regra_media_segfeira ( pr_cdcooper => pr_cdcooper -- Codigo da Cooperativa
                                 ,pr_dtmvtolt => pr_dtmvtolt -- Data de movimento
                                 ,pr_listdias => '05,06,07'     -- Lista de dias do mes
                                 ,pr_cdagrupa => pr_cdagrupa -- Código de agrupamento
                                 --OUT
                                 ,pr_tab_per_datas => pr_tab_per_datas -- Tabela de datas
                                 ,pr_tab_datas     => vr_tab_datas     -- tabela com as datas para controle
                                 ,pr_dscritic      => pr_dscritic );
      ELSIF vr_dtnumdia in (8,9) THEN
        pc_regra_media_segfeira ( pr_cdcooper => pr_cdcooper -- Codigo da Cooperativa
                                 ,pr_dtmvtolt => pr_dtmvtolt -- Data de movimento
                                 ,pr_listdias => '08,09'       -- Lista de dias do mes
                                 ,pr_cdagrupa => pr_cdagrupa -- Código de agrupamento
                                 --OUT
                                 ,pr_tab_per_datas => pr_tab_per_datas -- Tabela de datas
                                 ,pr_tab_datas     => vr_tab_datas     -- tabela com as datas para controle
                                 ,pr_dscritic => pr_dscritic );

      ELSIF vr_dtnumdia in (10,11,12) THEN
        pc_regra_media_segfeira ( pr_cdcooper => pr_cdcooper -- Codigo da Cooperativa
                                 ,pr_dtmvtolt => pr_dtmvtolt -- Data de movimento
                                 ,pr_listdias => '10,11,12'  -- Lista de dias do mes
                                 ,pr_cdagrupa => pr_cdagrupa -- Código de agrupamento
                                 --OUT
                                 ,pr_tab_per_datas => pr_tab_per_datas -- Tabela de datas
                                 ,pr_tab_datas     => vr_tab_datas     -- tabela com as datas para controle
                                 ,pr_dscritic => pr_dscritic );

      ELSIF vr_dtnumdia in (13,14) THEN
        pc_regra_media_segfeira ( pr_cdcooper => pr_cdcooper -- Codigo da Cooperativa
                                 ,pr_dtmvtolt => pr_dtmvtolt -- Data de movimento
                                 ,pr_listdias => '13,14'     -- Lista de dias do mes
                                 ,pr_cdagrupa => pr_cdagrupa -- Código de agrupamento
                                 --OUT
                                 ,pr_tab_per_datas => pr_tab_per_datas -- Tabela de datas
                                 ,pr_tab_datas     => vr_tab_datas     -- tabela com as datas para controle
                                 ,pr_dscritic      => pr_dscritic );

      ELSIF vr_dtnumdia in (15,16,17) THEN
        pc_regra_media_segfeira ( pr_cdcooper => pr_cdcooper -- Codigo da Cooperativa
                                 ,pr_dtmvtolt => pr_dtmvtolt -- Data de movimento
                                 ,pr_listdias => '15,16,17'  -- Lista de dias do mes
                                 ,pr_cdagrupa => pr_cdagrupa -- Código de agrupamento
                                 --OUT
                                 ,pr_tab_per_datas => pr_tab_per_datas -- Tabela de datas
                                 ,pr_tab_datas     => vr_tab_datas     -- tabela com as datas para controle
                                 ,pr_dscritic      => pr_dscritic );
      ELSIF vr_dtnumdia in (18,19) THEN
        pc_regra_media_segfeira ( pr_cdcooper => pr_cdcooper -- Codigo da Cooperativa
                                 ,pr_dtmvtolt => pr_dtmvtolt -- Data de movimento
                                 ,pr_listdias => '18,19'     -- Lista de dias do mes
                                 ,pr_cdagrupa => pr_cdagrupa -- Código de agrupamento
                                 --OUT
                                 ,pr_tab_per_datas => pr_tab_per_datas -- Tabela de datas
                                 ,pr_tab_datas     => vr_tab_datas     -- tabela com as datas para controle
                                 ,pr_dscritic => pr_dscritic );
      ELSIF vr_dtnumdia in (20,21,22) THEN
        pc_regra_media_segfeira ( pr_cdcooper => pr_cdcooper -- Codigo da Cooperativa
                                 ,pr_dtmvtolt => pr_dtmvtolt -- Data de movimento
                                 ,pr_listdias => '20,21,22'  -- Lista de dias do mes
                                 ,pr_cdagrupa => pr_cdagrupa -- Código de agrupamento
                                 --OUT
                                 ,pr_tab_per_datas => pr_tab_per_datas -- Tabela de datas
                                 ,pr_tab_datas     => vr_tab_datas     -- tabela com as datas para controle
                                 ,pr_dscritic => pr_dscritic );
      ELSIF vr_dtnumdia in (23,24) THEN
        pc_regra_media_segfeira ( pr_cdcooper => pr_cdcooper -- Codigo da Cooperativa
                                 ,pr_dtmvtolt => pr_dtmvtolt -- Data de movimento
                                 ,pr_listdias => '23,24'     -- Lista de dias do mes
                                 ,pr_cdagrupa => pr_cdagrupa -- Código de agrupamento
                                 --OUT
                                 ,pr_tab_per_datas => pr_tab_per_datas -- Tabela de datas
                                 ,pr_tab_datas     => vr_tab_datas     -- tabela com as datas para controle
                                 ,pr_dscritic      => pr_dscritic );

      ELSIF vr_dtnumdia in (25,26,27) THEN
        pc_regra_media_segfeira ( pr_cdcooper => pr_cdcooper -- Codigo da Cooperativa
                                 ,pr_dtmvtolt => pr_dtmvtolt -- Data de movimento
                                 ,pr_listdias => '25,26,27'  -- Lista de dias do mes
                                 ,pr_cdagrupa => pr_cdagrupa -- Código de agrupamento
                                 --OUT
                                 ,pr_tab_per_datas => pr_tab_per_datas -- Tabela de datas
                                 ,pr_tab_datas     => vr_tab_datas     -- tabela com as datas para controle
                                 ,pr_dscritic      => pr_dscritic );

      ELSIF vr_dtnumdia in (28,29) THEN
        IF LAST_DAY(pr_dtmvtolt) = pr_dtmvtolt THEN
          pc_regra_media_segfeira ( pr_cdcooper => pr_cdcooper -- Codigo da Cooperativa
                                   ,pr_dtmvtolt => pr_dtmvtolt -- Data de movimento
                                   ,pr_listdias => '30,31'     -- Lista de dias do mes
                                   ,pr_cdagrupa => pr_cdagrupa -- Código de agrupamento
                                   --OUT
                                   ,pr_tab_per_datas => pr_tab_per_datas -- Tabela de datas
                                   ,pr_tab_datas     => vr_tab_datas     -- tabela com as datas para controle
                                   ,pr_dscritic      => pr_dscritic );
        ELSE
          pc_regra_media_segfeira ( pr_cdcooper => pr_cdcooper -- Codigo da Cooperativa
                                   ,pr_dtmvtolt => pr_dtmvtolt -- Data de movimento
                                   ,pr_listdias => '28,29'     -- Lista de dias do mes
                                   ,pr_cdagrupa => pr_cdagrupa -- Código de agrupamento
                                   --OUT
                                   ,pr_tab_per_datas => pr_tab_per_datas -- Tabela de datas
                                   ,pr_tab_datas     => vr_tab_datas     -- tabela com as datas para controle
                                   ,pr_dscritic      => pr_dscritic );
        END IF;
      ELSIF vr_dtnumdia in (30,31) THEN
        pc_regra_media_segfeira ( pr_cdcooper => pr_cdcooper -- Codigo da Cooperativa
                                 ,pr_dtmvtolt => pr_dtmvtolt -- Data de movimento
                                 ,pr_listdias => '30,31'     -- Lista de dias do mes
                                 ,pr_cdagrupa => pr_cdagrupa -- Código de agrupamento
                                 --OUT
                                 ,pr_tab_per_datas => pr_tab_per_datas -- Tabela de datas
                                 ,pr_tab_datas     => vr_tab_datas     -- tabela com as datas para controle
                                 ,pr_dscritic      => pr_dscritic );
      ELSE
        pc_regra_media_segfeira ( pr_cdcooper => pr_cdcooper -- Codigo da Cooperativa
                                 ,pr_dtmvtolt => pr_dtmvtolt -- Data de movimento
                                 ,pr_listdias => vr_dtnumdia -- Lista de dias do mes
                                 ,pr_cdagrupa => pr_cdagrupa -- Código de agrupamento
                                 --OUT
                                 ,pr_tab_per_datas => pr_tab_per_datas -- Tabela de datas
                                 ,pr_tab_datas     => vr_tab_datas     -- tabela com as datas para controle
                                 ,pr_dscritic      => pr_dscritic );
      END IF;
    END IF; --Fim vr_dtsemdia <> 2

  END pc_gera_periodo_projecao_itg;

  -- Procedure para gerar os periodo de projeção cheque doc
  PROCEDURE pc_gr_periodo_projecao_chqdoc
                                    (pr_cdcooper IN INTEGER      -- Codigo da Cooperativa
                                    ,pr_dtmvtolt IN DATE         -- Data de movimento
                                    ,pr_tab_per_datas OUT typ_tab_per_datas -- Tabela de datas
                                    ,pr_dscritic      OUT VARCHAR2) AS      -- Descrição da critica

    -- .........................................................................
    --
    --  Programa : pc_gera_periodo_projecao_chqdoc          Antigo: b1wgen0131.p/gera-periodos-projecao-chqdoc
    --
    --  Sistema  : Cred
    --  Sigla    : FLXF0001
    --  Autor    : Odirlei Busana
    --  Data     : novembro/2013.                   Ultima atualizacao: 12/11/2013
    --
    --  Dados referentes ao programa:
    --
    --   Objetivo  : Gera os periodo de projeção do chqdoc
    --
    --   Atualizacao: 08/11/2013 - Conversao Progress => Oracle (Odirlei-AMcom)
    --..........................................................................

  -- variavel para armazenar ultimo dia do ano
  vr_ultdiaan DATE;
  -- variavel para armazenar primeiro dia do ano
  vr_pridiaan DATE;
  vr_dtperiod DATE;
  -- Variavel para controlar dias(dia mes e dia semana)
  vr_dtnumdia Varchar2(5);
  vr_dtsemdia Varchar2(5);

  vr_tab_datas typ_tab_datas;
  vr_idx       varchar2(15);

  BEGIN

    -- Passar para a função o ultimo dia do ano (ex.31122013), e a funçao retorna o dia util anterior a essa data ou ela mesma.
    vr_ultdiaan := gene0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper, --> Cooperativa conectada
                                               pr_dtmvtolt => to_date('3112'||to_char(pr_dtmvtolt,'RRRR'),'DDMMRRRR'), --> Data do movimento
                                               pr_tipo     => 'A',       --> Tipo de busca (P = proximo, A = anterior)
                                               pr_feriado  => TRUE);

    -- Passar para a função o primeiro dia do ano (ex.01012013), e a funçao retorna o proximo dia util a essa data ou ela mesma.
    vr_pridiaan := gene0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper, --> Cooperativa conectada
                                               pr_dtmvtolt => to_date('0101'||to_char(pr_dtmvtolt,'RRRR'),'DDMMRRRR'), --> Data do movimento
                                               pr_tipo     => 'P',       --> Tipo de busca (P = proximo, A = anterior)
                                               pr_feriado  => TRUE);

    -- Verificar se é o ultimo dia do ano
    IF pr_dtmvtolt = vr_ultdiaan THEN
      -- Passar para a função o ultimo dia do ano anterior (ex.31122013), e a funçao retorna o dia util anterior a essa data ou ela mesma.
      vr_dtperiod := gene0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper, --> Cooperativa conectada
                                                 pr_dtmvtolt => to_date('3112'||(to_char(pr_dtmvtolt,'RRRR')-1), 'DDMMRRRR'), --> Data do movimento
                                                 pr_tipo     => 'A',       --> Tipo de busca (P = proximo, A = anterior)
                                                 pr_feriado  => TRUE);

      --se ainda não existe a data, então inserir
      IF vr_tab_datas.EXISTS(TO_CHAR(vr_dtperiod,'DDMMRRRR')) = FALSE THEN
        --Buscar sequencial
        vr_idx := '000'||TO_CHAR(vr_dtperiod,'RRRRMMDD');
        pr_tab_per_datas(vr_idx).dtmvtolt := vr_dtperiod;
        --controle que ja gravou a data
        vr_tab_datas(TO_CHAR(vr_dtperiod,'DDMMRRRR')) := 1;
      END IF;

      pr_dscritic := 'OK';
      RETURN;

      -- Verificar se é o primeiro dia do ano
    ELSIF pr_dtmvtolt = vr_pridiaan THEN
      -- Passar para a função o primeiro dia do ano anterior (ex.31122013), e a funçao retorna o proximo dia util a essa data ou ela mesma.
      vr_dtperiod := gene0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper, --> Cooperativa conectada
                                                 pr_dtmvtolt => to_date('0101'||(to_char(pr_dtmvtolt,'RRRR')-1), 'DDMMRRRR'), --> Data do movimento
                                                 pr_tipo     => 'P',       --> Tipo de busca (P = proximo, A = anterior)
                                                 pr_feriado  => TRUE);

      --se ainda não existe a data, então inserir
      IF vr_tab_datas.EXISTS(TO_CHAR(vr_dtperiod,'DDMMRRRR')) = FALSE THEN
        --Buscar sequencial
        vr_idx := '000'||TO_CHAR(vr_dtperiod,'RRRRMMDD');
        pr_tab_per_datas(vr_idx).dtmvtolt := vr_dtperiod;
        --controle que ja gravou a data
        vr_tab_datas(TO_CHAR(vr_dtperiod,'DDMMRRRR')) := 1;
      END IF;

      pr_dscritic := 'OK';
      RETURN;

    END IF; -- fim pr_dtmvtolt = vr_ultdiaan

    vr_dtnumdia := to_char(pr_dtmvtolt,'DD');
    vr_dtsemdia := to_char(pr_dtmvtolt,'D');

    --Se o dia anterior é feriado, atribuir variavel como segunda feira
    IF fn_verifica_feriado(pr_cdcooper, pr_dtmvtolt - 1) THEN
      vr_dtsemdia := 2;
    END IF;

    -- Se for diferente de segunda-feira
    IF vr_dtsemdia <> 2 THEN
      IF vr_dtnumdia IN ('07','08',12,13,17,18) THEN
        IF vr_dtsemdia = 3 THEN
          pc_med_dia_util_semana (pr_cdcooper => pr_cdcooper  -- Codigo da Cooperativa
                                 ,pr_dtmvtolt => pr_dtmvtolt  -- Data de movimento
                                 ,pr_nrdiasse => '3'          -- Numero que representa o dia da semana
                                 ,pr_nrdiasme => TO_CHAR(pr_dtmvtolt,'DD')               -- Numero que representa o dia do mes
                                 ,pr_cdagrupa => NULL         -- Código de agrupamento
                                 ,pr_tipodoct => 'C'          -- Tipo de documento (C-Cheque,T-Titulo-I-Conta Integração )
                                 --OUT
                                 ,pr_tab_per_datas => pr_tab_per_datas -- Tabela de datas
                                 ,pr_tab_datas     => vr_tab_datas     -- tabela com as datas para controle
                                 ,pr_dscritic      => pr_dscritic);

          IF NVL(pr_tab_per_datas.COUNT,0) = 0 THEN
            IF vr_dtnumdia IN ('07','12',17) THEN
              pc_med_dia_util_semana (pr_cdcooper => pr_cdcooper  -- Codigo da Cooperativa
                                     ,pr_dtmvtolt => pr_dtmvtolt  -- Data de movimento
                                     ,pr_nrdiasse => '3'          -- Numero que representa o dia da semana
                                     ,pr_nrdiasme => TO_CHAR(pr_dtmvtolt-1,'DD')               -- Numero que representa o dia do mes
                                     ,pr_cdagrupa => NULL         -- Código de agrupamento
                                     ,pr_tipodoct => 'C'          -- Tipo de documento (C-Cheque,T-Titulo-I-Conta Integração )
                                     --OUT
                                     ,pr_tab_per_datas => pr_tab_per_datas -- Tabela de datas
                                     ,pr_tab_datas     => vr_tab_datas     -- tabela com as datas para controle
                                     ,pr_dscritic      => pr_dscritic);
            ELSE
              pc_med_dia_util_semana (pr_cdcooper => pr_cdcooper  -- Codigo da Cooperativa
                                     ,pr_dtmvtolt => pr_dtmvtolt  -- Data de movimento
                                     ,pr_nrdiasse => '3'          -- Numero que representa o dia da semana
                                     ,pr_nrdiasme => TO_CHAR(pr_dtmvtolt-1,'DD')||','||TO_CHAR(pr_dtmvtolt-2,'DD') -- Numero que representa o dia do mes
                                     ,pr_cdagrupa => NULL         -- Código de agrupamento
                                     ,pr_tipodoct => 'C'          -- Tipo de documento (C-Cheque,T-Titulo-I-Conta Integração )
                                     --OUT
                                     ,pr_tab_per_datas => pr_tab_per_datas -- Tabela de datas
                                     ,pr_tab_datas     => vr_tab_datas     -- tabela com as datas para controle
                                     ,pr_dscritic      => pr_dscritic);
            END IF;-- Fim vr_dtnumdia IN ('07','12',17)

          END IF;

        ELSE
          IF vr_dtnumdia IN ('07','08',13,18) THEN
            pc_med_dia_util_semana (pr_cdcooper => pr_cdcooper  -- Codigo da Cooperativa
                                   ,pr_dtmvtolt => pr_dtmvtolt  -- Data de movimento
                                   ,pr_nrdiasse => '3,4,5,6'    -- Numero que representa o dia da semana
                                   ,pr_nrdiasme => TO_CHAR(pr_dtmvtolt,'DD')               -- Numero que representa o dia do mes
                                   ,pr_cdagrupa => NULL         -- Código de agrupamento
                                   ,pr_tipodoct => 'C'          -- Tipo de documento (C-Cheque,T-Titulo-I-Conta Integração )
                                   --OUT
                                   ,pr_tab_per_datas => pr_tab_per_datas -- Tabela de datas
                                   ,pr_tab_datas     => vr_tab_datas     -- tabela com as datas para controle
                                   ,pr_dscritic      => pr_dscritic);
          ELSE
            pc_med_dia_util_semana (pr_cdcooper => pr_cdcooper  -- Codigo da Cooperativa
                                   ,pr_dtmvtolt => pr_dtmvtolt  -- Data de movimento
                                   ,pr_nrdiasse => '4,5,6'      -- Numero que representa o dia da semana
                                   ,pr_nrdiasme => TO_CHAR(pr_dtmvtolt,'DD')               -- Numero que representa o dia do mes
                                   ,pr_cdagrupa => NULL         -- Código de agrupamento
                                   ,pr_tipodoct => 'C'          -- Tipo de documento (C-Cheque,T-Titulo-I-Conta Integração )
                                   --OUT
                                   ,pr_tab_per_datas => pr_tab_per_datas -- Tabela de datas
                                   ,pr_tab_datas     => vr_tab_datas     -- tabela com as datas para controle
                                   ,pr_dscritic      => pr_dscritic);
          END IF; -- Fim vr_dtnumdia IN ('07','08',13,18)
        END IF; -- Fim vr_dtsemdia = 3
      ELSE
        --se for o ultimo dia do mes de fevereiro
        IF ((vr_dtnumdia = 28) OR (vr_dtnumdia = 29)) AND
            (last_day(pr_dtmvtolt) = pr_dtmvtolt) THEN

          pc_med_dia_util_semana (pr_cdcooper => pr_cdcooper      -- Codigo da Cooperativa
                                 ,pr_dtmvtolt => pr_dtmvtolt      -- Data de movimento
                                 ,pr_nrdiasse => '3,4,5,6'        -- Numero que representa o dia da semana
                                 ,pr_nrdiasme => '30'             -- Numero que representa o dia do mes
                                 ,pr_cdagrupa => null             -- Código de agrupamento
                                 ,pr_tipodoct => 'C'              -- Tipo de documento (C-Cheque,T-Titulo-I-Conta Integração )
                                 --OUT
                                 ,pr_tab_per_datas => pr_tab_per_datas -- Tabela de datas
                                 ,pr_tab_datas     => vr_tab_datas     -- tabela com as datas para controle
                                 ,pr_dscritic      => pr_dscritic);

        ELSE
          pc_med_dia_util_semana (pr_cdcooper => pr_cdcooper      -- Codigo da Cooperativa
                                 ,pr_dtmvtolt => pr_dtmvtolt      -- Data de movimento
                                 ,pr_nrdiasse => '3,4,5,6'        -- Numero que representa o dia da semana
                                 ,pr_nrdiasme => to_char(pr_dtmvtolt,'DD')      -- Numero que representa o dia do mes
                                 ,pr_cdagrupa => NULL             -- Código de agrupamento
                                 ,pr_tipodoct => 'C'              -- Tipo de documento (C-Cheque,T-Titulo-I-Conta Integração )
                                 --OUT
                                 ,pr_tab_per_datas => pr_tab_per_datas -- Tabela de datas
                                 ,pr_tab_datas     => vr_tab_datas     -- tabela com as datas para controle
                                 ,pr_dscritic      => pr_dscritic);
        END IF; -- Fim fevereiro
      END IF; -- Fim vr_dtnumdia IN ('07','08',12,13,17,18)

    ELSE
      IF vr_dtnumdia in ('01','02','03') THEN
        pc_regra_media_segfeira ( pr_cdcooper => pr_cdcooper -- Codigo da Cooperativa
                                 ,pr_dtmvtolt => pr_dtmvtolt -- Data de movimento
                                 ,pr_listdias => '01,02,03'     -- Lista de dias do mes
                                 ,pr_cdagrupa => NULL        -- Código de agrupamento
                                 --OUT
                                 ,pr_tab_per_datas => pr_tab_per_datas -- Tabela de datas
                                 ,pr_tab_datas     => vr_tab_datas     -- tabela com as datas para controle
                                 ,pr_dscritic => pr_dscritic );
      ELSIF vr_dtnumdia = 15 THEN
        pc_regra_media_segfeira ( pr_cdcooper => pr_cdcooper -- Codigo da Cooperativa
                                 ,pr_dtmvtolt => pr_dtmvtolt -- Data de movimento
                                 ,pr_listdias => vr_dtnumdia -- Lista de dias do mes
                                 ,pr_cdagrupa => NULL        -- Código de agrupamento
                                 --OUT
                                 ,pr_tab_per_datas => pr_tab_per_datas -- Tabela de datas
                                 ,pr_tab_datas     => vr_tab_datas     -- tabela com as datas para controle
                                 ,pr_dscritic => pr_dscritic );

        IF NVL(pr_tab_per_datas.COUNT,0) = 0 THEN
          pc_regra_media_segfeira ( pr_cdcooper => pr_cdcooper -- Codigo da Cooperativa
                                 ,pr_dtmvtolt => pr_dtmvtolt   -- Data de movimento
                                 ,pr_listdias => fn_Busca_Lista_Dias(vr_dtnumdia)     -- Lista de dias do mes
                                 ,pr_cdagrupa => NULL          -- Código de agrupamento
                                 --OUT
                                 ,pr_tab_per_datas => pr_tab_per_datas -- Tabela de datas
                                 ,pr_tab_datas     => vr_tab_datas     -- tabela com as datas para controle
                                 ,pr_dscritic => pr_dscritic );
        END IF;

      ELSIF vr_dtnumdia = 21 THEN
        pc_regra_media_segfeira ( pr_cdcooper => pr_cdcooper -- Codigo da Cooperativa
                                 ,pr_dtmvtolt => pr_dtmvtolt -- Data de movimento
                                 ,pr_listdias => '20,21'     -- Lista de dias do mes
                                 ,pr_cdagrupa => NULL        -- Código de agrupamento
                                 --OUT
                                 ,pr_tab_per_datas => pr_tab_per_datas -- Tabela de datas
                                 ,pr_tab_datas     => vr_tab_datas     -- tabela com as datas para controle
                                 ,pr_dscritic => pr_dscritic );

        IF NVL(pr_tab_per_datas.COUNT,0) = 0 THEN
          pc_regra_media_segfeira ( pr_cdcooper => pr_cdcooper -- Codigo da Cooperativa
                                 ,pr_dtmvtolt => pr_dtmvtolt   -- Data de movimento
                                 ,pr_listdias => fn_Busca_Lista_Dias(vr_dtnumdia)     -- Lista de dias do mes
                                 ,pr_cdagrupa => NULL          -- Código de agrupamento
                                 --OUT
                                 ,pr_tab_per_datas => pr_tab_per_datas -- Tabela de datas
                                 ,pr_tab_datas     => vr_tab_datas     -- tabela com as datas para controle
                                 ,pr_dscritic => pr_dscritic );
        END IF;

      ELSIF vr_dtnumdia = 22 THEN
        pc_regra_media_segfeira ( pr_cdcooper => pr_cdcooper -- Codigo da Cooperativa
                                 ,pr_dtmvtolt => pr_dtmvtolt -- Data de movimento
                                 ,pr_listdias => '20,22'     -- Lista de dias do mes
                                 ,pr_cdagrupa => NULL        -- Código de agrupamento
                                 --OUT
                                 ,pr_tab_per_datas => pr_tab_per_datas -- Tabela de datas
                                 ,pr_tab_datas     => vr_tab_datas     -- tabela com as datas para controle
                                 ,pr_dscritic => pr_dscritic );

        IF NVL(pr_tab_per_datas.COUNT,0) = 0 THEN
          pc_regra_media_segfeira ( pr_cdcooper => pr_cdcooper -- Codigo da Cooperativa
                                 ,pr_dtmvtolt => pr_dtmvtolt   -- Data de movimento
                                 ,pr_listdias => fn_Busca_Lista_Dias(vr_dtnumdia)     -- Lista de dias do mes
                                 ,pr_cdagrupa => NULL          -- Código de agrupamento
                                 --OUT
                                 ,pr_tab_per_datas => pr_tab_per_datas -- Tabela de datas
                                 ,pr_tab_datas     => vr_tab_datas     -- tabela com as datas para controle
                                 ,pr_dscritic => pr_dscritic );
        END IF;

      ELSIF vr_dtnumdia in (28,29) THEN
        IF LAST_DAY(pr_dtmvtolt) = pr_dtmvtolt THEN
          pc_regra_media_segfeira ( pr_cdcooper => pr_cdcooper -- Codigo da Cooperativa
                                   ,pr_dtmvtolt => pr_dtmvtolt -- Data de movimento
                                   ,pr_listdias => '30'        -- Lista de dias do mes
                                   ,pr_cdagrupa => NULL        -- Código de agrupamento
                                   --OUT
                                   ,pr_tab_per_datas => pr_tab_per_datas -- Tabela de datas
                                   ,pr_tab_datas     => vr_tab_datas     -- tabela com as datas para controle
                                   ,pr_dscritic      => pr_dscritic );

          IF NVL(pr_tab_per_datas.COUNT,0) = 0 THEN
            pc_regra_media_segfeira ( pr_cdcooper => pr_cdcooper -- Codigo da Cooperativa
                                   ,pr_dtmvtolt => pr_dtmvtolt   -- Data de movimento
                                   ,pr_listdias => fn_Busca_Lista_Dias(vr_dtnumdia)     -- Lista de dias do mes
                                   ,pr_cdagrupa => NULL          -- Código de agrupamento
                                   --OUT
                                   ,pr_tab_per_datas => pr_tab_per_datas -- Tabela de datas
                                   ,pr_tab_datas     => vr_tab_datas     -- tabela com as datas para controle
                                   ,pr_dscritic => pr_dscritic );
          END IF;
        ELSE
          pc_regra_media_segfeira ( pr_cdcooper => pr_cdcooper -- Codigo da Cooperativa
                                   ,pr_dtmvtolt => pr_dtmvtolt -- Data de movimento
                                   ,pr_listdias => vr_dtnumdia -- Lista de dias do mes
                                   ,pr_cdagrupa => NULL        -- Código de agrupamento
                                   --OUT
                                   ,pr_tab_per_datas => pr_tab_per_datas -- Tabela de datas
                                   ,pr_tab_datas     => vr_tab_datas     -- tabela com as datas para controle
                                   ,pr_dscritic      => pr_dscritic );

          IF NVL(pr_tab_per_datas.COUNT,0) = 0 THEN
            pc_media_dia_util_segfeira
                           (pr_cdcooper  => pr_cdcooper    -- Codigo da Cooperativa
                           ,pr_dtmvtolt  => pr_dtmvtolt    -- Data de movimento
                           ,pr_numdiaut  => fn_calcula_dia_util(vr_dtnumdia)   -- Numero de dia calculado
                           ,pr_diaminim  => fn_busca_limite_dia(vr_dtnumdia,1) -- Qtd de dias limite minimo
                           ,pr_diamaxim  => fn_busca_limite_dia(vr_dtnumdia,2) -- Qtd de dias limite maximo
                           ,pr_tab_per_datas => pr_tab_per_datas -- Tabela de datas
                           ,pr_tab_datas     => vr_tab_datas     -- tabela com as datas para controle
                           ,pr_dscritic      => pr_dscritic);

            IF NVL(pr_tab_per_datas.COUNT,0) = 0 THEN
              pc_regra_media_segfeira ( pr_cdcooper => pr_cdcooper -- Codigo da Cooperativa
                                     ,pr_dtmvtolt => pr_dtmvtolt   -- Data de movimento
                                     ,pr_listdias => fn_Busca_Lista_Dias(vr_dtnumdia) -- Lista de dias do mes
                                     ,pr_cdagrupa => NULL          -- Código de agrupamento
                                     --OUT
                                     ,pr_tab_per_datas => pr_tab_per_datas -- Tabela de datas
                                     ,pr_tab_datas     => vr_tab_datas     -- tabela com as datas para controle
                                     ,pr_dscritic => pr_dscritic );
            END IF;
          END IF;
        END IF;
      ELSIF vr_dtnumdia = 30 THEN
        pc_regra_media_segfeira ( pr_cdcooper => pr_cdcooper -- Codigo da Cooperativa
                                 ,pr_dtmvtolt => pr_dtmvtolt -- Data de movimento
                                 ,pr_listdias => vr_dtnumdia -- Lista de dias do mes
                                 ,pr_cdagrupa => NULL        -- Código de agrupamento
                                 --OUT
                                 ,pr_tab_per_datas => pr_tab_per_datas -- Tabela de datas
                                 ,pr_tab_datas     => vr_tab_datas     -- tabela com as datas para controle
                                 ,pr_dscritic => pr_dscritic );

        IF NVL(pr_tab_per_datas.COUNT,0) = 0 THEN
          pc_regra_media_segfeira ( pr_cdcooper => pr_cdcooper -- Codigo da Cooperativa
                                 ,pr_dtmvtolt => pr_dtmvtolt   -- Data de movimento
                                 ,pr_listdias => fn_Busca_Lista_Dias(vr_dtnumdia)     -- Lista de dias do mes
                                 ,pr_cdagrupa => NULL          -- Código de agrupamento
                                 --OUT
                                 ,pr_tab_per_datas => pr_tab_per_datas -- Tabela de datas
                                 ,pr_tab_datas     => vr_tab_datas     -- tabela com as datas para controle
                                 ,pr_dscritic => pr_dscritic );
        END IF;

      ELSIF vr_dtnumdia = 31 THEN
        pc_regra_media_segfeira ( pr_cdcooper => pr_cdcooper -- Codigo da Cooperativa
                                 ,pr_dtmvtolt => pr_dtmvtolt -- Data de movimento
                                 ,pr_listdias => '30,31'     -- Lista de dias do mes
                                 ,pr_cdagrupa => NULL        -- Código de agrupamento
                                 --OUT
                                 ,pr_tab_per_datas => pr_tab_per_datas -- Tabela de datas
                                 ,pr_tab_datas     => vr_tab_datas     -- tabela com as datas para controle
                                 ,pr_dscritic => pr_dscritic );

        IF NVL(pr_tab_per_datas.COUNT,0) = 0 THEN
          pc_regra_media_segfeira ( pr_cdcooper => pr_cdcooper -- Codigo da Cooperativa
                                 ,pr_dtmvtolt => pr_dtmvtolt   -- Data de movimento
                                 ,pr_listdias => fn_Busca_Lista_Dias(vr_dtnumdia)     -- Lista de dias do mes
                                 ,pr_cdagrupa => NULL          -- Código de agrupamento
                                 --OUT
                                 ,pr_tab_per_datas => pr_tab_per_datas -- Tabela de datas
                                 ,pr_tab_datas     => vr_tab_datas     -- tabela com as datas para controle
                                 ,pr_dscritic => pr_dscritic );
        END IF;

      ELSE
        pc_regra_media_segfeira ( pr_cdcooper => pr_cdcooper -- Codigo da Cooperativa
                                 ,pr_dtmvtolt => pr_dtmvtolt -- Data de movimento
                                 ,pr_listdias => vr_dtnumdia -- Lista de dias do mes
                                 ,pr_cdagrupa => NULL        -- Código de agrupamento
                                 --OUT
                                 ,pr_tab_per_datas => pr_tab_per_datas -- Tabela de datas
                                 ,pr_tab_datas     => vr_tab_datas     -- tabela com as datas para controle
                                 ,pr_dscritic      => pr_dscritic );

        IF NVL(pr_tab_per_datas.COUNT,0) = 0 THEN
          pc_media_dia_util_segfeira
                           (pr_cdcooper  => pr_cdcooper    -- Codigo da Cooperativa
                           ,pr_dtmvtolt  => pr_dtmvtolt    -- Data de movimento
                           ,pr_numdiaut  => fn_calcula_dia_util(vr_dtnumdia)   -- Numero de dia calculado
                           ,pr_diaminim  => fn_busca_limite_dia(vr_dtnumdia,1) -- Qtd de dias limite minimo
                           ,pr_diamaxim  => fn_busca_limite_dia(vr_dtnumdia,2) -- Qtd de dias limite maximo
                           ,pr_tab_per_datas => pr_tab_per_datas -- Tabela de datas
                           ,pr_tab_datas     => vr_tab_datas     -- tabela com as datas para controle
                           ,pr_dscritic      => pr_dscritic);

          IF NVL(pr_tab_per_datas.COUNT,0) = 0 THEN
            pc_regra_media_segfeira ( pr_cdcooper => pr_cdcooper -- Codigo da Cooperativa
                                     ,pr_dtmvtolt => pr_dtmvtolt -- Data de movimento
                                     ,pr_listdias => fn_Busca_Lista_Dias(vr_dtnumdia)     -- Lista de dias do mes
                                     ,pr_cdagrupa => NULL        -- Código de agrupamento
                                     --OUT
                                     ,pr_tab_per_datas => pr_tab_per_datas -- Tabela de datas
                                     ,pr_tab_datas     => vr_tab_datas     -- tabela com as datas para controle
                                     ,pr_dscritic      => pr_dscritic );
          END IF;
        END IF;
      END IF; --Fim vr_dtnumdia = N
    END IF; --Fim vr_dtsemdia <> 2

    pr_dscritic := 'OK';

  END pc_gr_periodo_projecao_chqdoc;
  
  /* Função para validar se duas datas caem no mesmo grupos de dia de semana */
  FUNCTION fn_valida_grupo_dia_semana(pr_dtatual IN DATE
                                     ,pr_dtteste IN DATE) RETURN BOOLEAN IS
  BEGIN
    -- Grupos:
    -- a) 2ª e 3ª feiras
    -- b) 4ª, 5ª e 6ª feiras
    IF to_char(pr_dtatual,'D') IN(2,3) AND to_char(pr_dtteste,'D') IN(2,3) THEN 
      RETURN TRUE;
    ELSIF to_char(pr_dtatual,'D') IN(4,5,6) AND to_char(pr_dtteste,'D') IN(4,5,6) THEN 
      RETURN TRUE;
    ELSE 
      RETURN FALSE;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN FALSE;
  END;                              
  
  /* Gerar periodo de projeção considerando o mesmo dia util da data passada */
  PROCEDURE pc_gera_period_diautil(pr_cdcooper IN INTEGER      -- Codigo da Cooperativa
                                  ,pr_dtmvtolt IN DATE         -- Data de movimento
                                  ,pr_qtdmeses IN NUMBER       -- Numero de meses a procurar
                                  ,pr_qtdocorr IN NUMBER       -- Limite de dadas encontradas (0 não há)
                                  ,pr_fldiasem IN BOOLEAN      -- Considerar o dia da semana passado
                                  ,pr_tab_per_datas OUT typ_tab_per_datas -- Tabela de datas
                                  ,pr_dscritic      OUT VARCHAR2) AS      -- Descrição da critica

    -- .........................................................................
    --
    --  Programa : pc_gera_period_diautil          
    --
    --  Sistema  : Cred
    --  Sigla    : FLXF0001
    --  Autor    : Marcos Martini
    --  Data     : Outubro/2016.                   Ultima atualizacao: 
    --
    --  Dados referentes ao programa:
    --
    --   Objetivo  : Gera os periodos de projeção meses usando dia util 
    --               
    --   Atualizacao: 
    --..........................................................................

    vr_ndiautil  NUMBER;
    vr_diabusca  PLS_INTEGER;
    vr_dtbuscar  DATE;
    vr_dtlimite  DATE;
    vr_dtmontad  DATE;
    vr_idx       VARCHAR2(11);

  BEGIN
    -- Sair se não receber data
    IF pr_dtmvtolt IS NULL THEN
      RETURN;
    END IF;
    
    -- Diminuir um mês até encontrar uma data inferior a data do sistema
    vr_dtbuscar := pr_dtmvtolt;
    LOOP   
      vr_dtbuscar := add_months(vr_dtbuscar,-1);
      EXIT WHEN vr_dtbuscar <= trunc(SYSDATE);
    END LOOP;
    
    -- Calcular limite para a busca cfme qtd meses passada
    vr_dtlimite := add_months(vr_dtbuscar,-pr_qtdmeses); -- n Meses
    
    -- Buscar o numero de dia util do mês referente a data passada
    vr_ndiautil := fn_retorna_numero_dia_util(pr_cdcooper,pr_dtmvtolt);
    
    -- Somente continuar se houve retorno
    IF vr_ndiautil = 0 THEN
      RETURN;
    END IF;
    
    -- Efetuar laço para encontrarmos datas em meses anteriores 
    -- onde o dia é o mesmo dia util do dia solicitado
    LOOP
      -- Sair quando tivermos buscado mais de N meses no passado 
      -- Ou há limite de datas encontradas 
      EXIT WHEN vr_dtbuscar < vr_dtlimite
             OR (pr_qtdocorr > 0 AND pr_tab_per_datas.count() >= pr_qtdocorr);
      -- Buscar o mesmo "N" dia no mesmo mês da data em procura 
      vr_diabusca := Fn_retorna_dia_util_n(pr_cdcooper => pr_cdcooper
                                          ,pr_numdiaut => vr_ndiautil
                                          ,pr_dtdatmes => vr_dtbuscar);
      -- Se houve encontro de dia 
      IF vr_diabusca <> 0 THEN
        -- Montar a data 
        vr_dtmontad := to_date(to_char(vr_diabusca,'fm00')||to_char(vr_dtbuscar,'mmrrrr'),'ddmmrrrr');
        -- Adicionar o dia ao vetor somente se é o mesmo grupo de dia da semana (se solicitado no parâmetro é claro)
        IF NOT pr_fldiasem OR fn_valida_grupo_dia_semana(pr_dtmvtolt,vr_dtmontad) THEN 
          vr_idx := '000'||TO_CHAR(to_date(to_char(vr_diabusca,'fm00')||to_char(vr_dtbuscar,'mmrrrr'),'ddmmrrrr'),'RRRRMMDD');
          pr_tab_per_datas(vr_idx).dtmvtolt := vr_dtmontad;          
        END IF;
      END IF;
      -- Diminuir mais um mês
      vr_dtbuscar := add_months(vr_dtbuscar,-1);    
    END LOOP;

  EXCEPTION
    WHEN OTHERS THEN
      pr_dscritic := 'Erro na FLXF0001.pc_gera_period_diautil --> '||SQLERRM;
  END pc_gera_period_diautil;
  
  /* Gerar periodo de projeção criterio dia mes e dia semana  */
  PROCEDURE pc_gera_period_dia_mes(pr_cdcooper IN INTEGER      -- Codigo da Cooperativa
                                  ,pr_dtmvtolt IN DATE         -- Data de movimento
                                  ,pr_qtdmeses IN NUMBER       -- Numero de meses a procurar
                                  ,pr_fldiasem IN BOOLEAN      -- Considerar o dia da semana
                                  ,pr_flprxant IN BOOLEAN      -- Considerar 1 dia a mais ou menos
                                  ,pr_qtdocorr IN NUMBER DEFAULT 0 -- Limite de dadas encontradas (0 não há)
                                  ,pr_listadia IN VARCHAR2 DEFAULT NULL   -- Lista de dias a processar
                                  ,pr_tab_per_datas OUT typ_tab_per_datas -- Tabela de datas
                                  ,pr_dscritic      OUT VARCHAR2) AS      -- Descrição da critica

    -- .........................................................................
    --
    --  Programa : pc_gera_period_dia_mes          
    --
    --  Sistema  : Cred
    --  Sigla    : FLXF0001
    --  Autor    : Marcos Martini
    --  Data     : Outubro/2016.                   Ultima atualizacao: 
    --
    --  Dados referentes ao programa:
    --
    --   Objetivo  : Gera os periodos de projeção meses usando dia mês e dia semana 
    --               
    --   Atualizacao: 
    --..........................................................................

    vr_ndiasema  NUMBER;
    vr_nrdiames  VARCHAR2(2);
    vr_dtbuscar  DATE;
    vr_dtmontag  DATE;
    vr_dtmontaa  DATE;
    vr_dtmontad  DATE;
    vr_dtlimite  DATE;
    vr_idx       VARCHAR2(11);

  BEGIN
    -- Sair se não receber data
    IF pr_dtmvtolt IS NULL THEN
      RETURN;
    END IF;
    
    -- Diminuir um mês até encontrar uma data inferior a data do sistema
    vr_dtbuscar := pr_dtmvtolt;
    LOOP   
      vr_dtbuscar := add_months(vr_dtbuscar,-1);
      EXIT WHEN vr_dtbuscar <= trunc(SYSDATE);
    END LOOP;
    
    -- Calcular limite para a busca cfme qtd meses passada
    vr_dtlimite := add_months(vr_dtbuscar,-pr_qtdmeses); -- n Meses
    
    -- Separar o dia da semana e dia do mês
    vr_ndiasema := to_char(pr_dtmvtolt,'D');
    vr_nrdiames := to_char(pr_dtmvtolt,'DD');
    
    -- Efetuar laço para encontrarmos datas em meses anteriores 
    -- onde o dia no mês é o mesmo da semana que o dia solicitado
    LOOP
      -- Sair quando tivermos buscado mais de N meses no passado 
      -- Ou há limite de datas encontradas 
      EXIT WHEN vr_dtbuscar < vr_dtlimite
             OR (pr_qtdocorr > 0 AND pr_tab_per_datas.count() >= pr_qtdocorr);
      -- Tratar com exception pois se a montagem da 
      -- data falhar é pq o dia não existe naquele mês
      BEGIN 
        -- Montar a data no mês do loop
        vr_dtmontag := to_date(vr_nrdiames||TO_CHAR(vr_dtbuscar,'MMRRRR'),'DDMMRRRR');
        -- Se foi passado lista de dias, somente continuar se o mesmo estiver nela
        IF pr_listadia IS NULL OR instr(pr_listadia,to_char(vr_dtmontag,'D')) > 0 THEN 
          -- Se solicitado na flag de parâmetro e o dia da semana na data montada é igual 
          -- ao armazenado da data solicitada E é uma data util 
          IF (NOT pr_fldiasem OR to_char(vr_dtmontag,'D') = vr_ndiasema) AND vr_dtmontag = gene0005.fn_valida_dia_util(pr_cdcooper,vr_dtmontag) THEN 
            -- Adicionar o dia ao vetor
            vr_idx := '000'||TO_CHAR(vr_dtmontag,'RRRRMMDD');
            pr_tab_per_datas(vr_idx).dtmvtolt := vr_dtmontag;
          -- Se foi passada a flag para buscar um dia para mais ou para menos
          ELSIF pr_flprxant THEN 
            -- Montar o dia anterior verificando mudança de mês
            vr_dtmontaa := vr_dtmontag - 1;
            -- Somente procurar se o dia estiver no mesmo mês (D-1) E Refazer o teste agora com a nova data 
            IF trunc(vr_dtmontag,'mm') = trunc(vr_dtmontaa,'mm') AND (NOT pr_fldiasem OR to_char(vr_dtmontaa,'D') = vr_ndiasema) AND vr_dtmontaa = gene0005.fn_valida_dia_util(pr_cdcooper,vr_dtmontaa) THEN 
              -- Adicionar o dia ao vetor
              vr_idx := '000'||TO_CHAR(vr_dtmontaa,'RRRRMMDD');
              pr_tab_per_datas(vr_idx).dtmvtolt := vr_dtmontaa;
            ELSE
              -- Testar com D+1 
              vr_dtmontad := vr_dtmontag + 1;
              -- Somente procurar se o dia posterior estiver no mesmo mês (D+1) E Refazer o teste agora com a nova data 
              IF trunc(vr_dtmontag,'mm') = trunc(vr_dtmontad,'mm') AND (NOT pr_fldiasem OR to_char(vr_dtmontad,'D') = vr_ndiasema) AND vr_dtmontad = gene0005.fn_valida_dia_util(pr_cdcooper,vr_dtmontad) THEN 
                -- Adicionar o dia ao vetor
                vr_idx := '000'||TO_CHAR(vr_dtmontad,'RRRRMMDD');
                pr_tab_per_datas(vr_idx).dtmvtolt := vr_dtmontad; 
              END IF;
            END IF;
          END IF; 
        END IF;         
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;    
      -- Diminuir mais um mês
      vr_dtbuscar := add_months(vr_dtbuscar,-1);    
    END LOOP;

  EXCEPTION
    WHEN OTHERS THEN
      pr_dscritic := 'Erro na FLXF0001.pc_gera_period_dia_mes --> '||SQLERRM;
  END pc_gera_period_dia_mes;
  

  -- Procedure para gravar movimento financeiro das contas Itg
  PROCEDURE pc_grava_mvt_conta_itg(pr_cdcooper IN INTEGER      -- Codigo da Cooperativa
                                  ,pr_dtmvtolt IN DATE         -- Data de movimento
                                  ,pr_tpdmovto IN NUMBER       -- tipo de movimento(1-entrada 2-saida)
                                  ,pr_dscritic OUT VARCHAR2)AS -- Descrição da critica

    -- .........................................................................
    --
    --  Programa : pc_grava_mvt_conta_itg          Antigo: 
    --
    --  Sistema  : Cred
    --  Sigla    : FLXF0001
    --  Autor    : Marcos Martini
    --  Data     : Outubro/2016.                   Ultima atualizacao: 
    --
    --  Dados referentes ao programa:
    --
    --   Objetivo  : Gravar movimento financeiro das contas Itg Realizado
    --
    --   Atualizacao: 
    --..........................................................................

    vr_exc_erro      EXCEPTION;
    vr_vlrtotal      NUMBER;
    vr_tpdfluxo VARCHAR2(1);
    
  BEGIN

    vr_vlrtotal := 0;

    IF pr_tpdmovto = 1 THEN
      vr_tpdfluxo := 'E';
    ELSE
      vr_tpdfluxo := 'S';
    END IF;

    -- buscar lançamentos
    FOR rw_craplcm IN cr_craplcm_parame(pr_cdbccxlt  => 1
                                       ,pr_dtmvtolt  => pr_dtmvtolt
                                       ,pr_cdcooper  => pr_cdcooper
                                       ,pr_cdremessa => 6
                                       ,pr_tpfluxo   => vr_tpdfluxo) LOOP
      -- Somar valores
      vr_vlrtotal := vr_vlrtotal + NVL(rw_craplcm.vllanmto,0);
    END LOOP;

    pc_grava_movimentacao(pr_cdcooper => pr_cdcooper      -- Codigo da Cooperativa
                         ,pr_dtmvtolt => pr_dtmvtolt      -- Data de movimento
                         ,pr_tpdmovto => pr_tpdmovto      -- Tipo de movimento
                         ,pr_cdbccxlt => 1                -- Codigo do banco/caixa.
                         ,pr_tpdcampo => 6  /*VLMVTITG*/     -- Tipo de campo
                         ,pr_vldcampo => vr_vlrtotal       -- Valor do campo
                         ,pr_dscritic => pr_dscritic);

    IF pr_dscritic <> 'OK' THEN
      RAISE vr_exc_erro;
    END IF;

    pr_dscritic := 'OK';

  EXCEPTION
    WHEN vr_exc_erro THEN
        NULL;
    WHEN OTHERS THEN
      pr_dscritic := 'Erro na FLXF0001.pc_grava_mvt_conta_itg: '||SQLerrm;
  END pc_grava_mvt_conta_itg;

  -- Procedure para gravar movimento financeiro das contas Itg
  PROCEDURE pc_grava_prj_conta_itg  ( pr_cdcooper IN INTEGER      -- Codigo da Cooperativa
                                     ,pr_dtmvtolt IN DATE         -- Data de movimento
                                     ,pr_tpdmovto IN NUMBER       -- tipo de movimento(1-entrada 2-saida)
                                     ,pr_flghistor IN BOOLEAN DEFAULT FALSE -- Flag para utilização da base histórica 
                                     ,pr_dscritic OUT VARCHAR2)AS -- Descrição da critica

    -- .........................................................................
    --
    --  Programa : pc_grava_prj_conta_itg_ent          Antigo: b1wgen0131.p/1-pi_rec_mov_conta_itg_f
    --                                                                      2-pi_rem_mov_conta_itg_f
    --
    --  Sistema  : Cred
    --  Sigla    : FLXF0001
    --  Autor    : Odirlei Busana
    --  Data     : novembro/2013.                   Ultima atualizacao: 11/11/2013
    --
    --  Dados referentes ao programa:
    --
    --   Objetivo  : Gravar movimento financeiro das contas Itg
    --
    --   Atualizacao: 08/11/2013 - Conversao Progress => Oracle (Odirlei-AMcom)
    --..........................................................................

    vr_exc_erro      EXCEPTION;
    vr_tab_per_datas typ_tab_per_datas;
    vr_maiorvlr      NUMBER;
    vr_contador      NUMBER;
    vr_vlrttdev      NUMBER;
    vr_vlrmedia      NUMBER;
    vr_idx           VARCHAR2(15);
    
    vr_tpdfluxo VARCHAR2(1);
    
  BEGIN

    vr_contador := 0;
    vr_vlrttdev := 0;
    vr_vlrmedia := 0;
    vr_maiorvlr := 0;

    IF pr_tpdmovto = 1 THEN
      vr_tpdfluxo := 'E';
    ELSE
      vr_tpdfluxo := 'S';
    END IF;

    -- gerar os periodo de projeção Itg
    pc_gera_periodo_projecao_itg (pr_cdcooper => pr_cdcooper  -- Codigo da Cooperativa
                                 ,pr_dtmvtolt => pr_dtmvtolt  -- Data de movimento
                                 ,pr_cdagrupa => 1            -- Código de agrupamento
                                 --out
                                 ,pr_tab_per_datas => vr_tab_per_datas -- Tabela de datas
                                 ,pr_dscritic      => pr_dscritic);

    IF pr_dscritic <> 'OK' THEN
      RAISE vr_exc_erro;
    ELSE
      pr_dscritic := NULL;
    END IF;

    vr_idx := vr_tab_per_datas.first;
    LOOP
      EXIT WHEN vr_idx IS NULL;

      -- CAso utilizar base histórica
      IF pr_flghistor THEN 
        -- Buscar dos valores realizados e armazenados no fluxo financeiro 
        FOR rw_crapffm IN cr_crapffm_histor(pr_cdcooper => pr_cdcooper
                                           ,pr_dtmvtolt => vr_tab_per_datas(vr_idx).dtmvtolt
                                           ,pr_cdbccxlt => 1
                                           ,pr_tpdmovto => pr_tpdmovto
                                           ,pr_tpdcampo => 6 --> VLMVTITG
                                           ) LOOP 
          vr_tab_per_datas(vr_idx).vlrtotal := NVL(vr_tab_per_datas(vr_idx).vlrtotal,0) + nvl(rw_crapffm.vllanmto,0);
        END LOOP;
      ELSE 
        -- buscar lançamentos 
        FOR rw_craplcm IN cr_craplcm_parame(pr_cdbccxlt  => 1
                                           ,pr_dtmvtolt  => vr_tab_per_datas(vr_idx).dtmvtolt
                                           ,pr_cdcooper  => pr_cdcooper
                                           ,pr_cdremessa => 6
                                           ,pr_tpfluxo   => vr_tpdfluxo) LOOP
          -- Somar valores
          vr_tab_per_datas(vr_idx).vlrtotal := NVL(vr_tab_per_datas(vr_idx).vlrtotal,0) + NVL(rw_craplcm.vllanmto,0);
        END LOOP;
      END IF;  

      -- identificar maior valor se for entrada
      IF NVL(vr_tab_per_datas(vr_idx).vlrtotal,0) > NVL(vr_maiorvlr,0) AND
         pr_tpdmovto = 1 THEN
        vr_maiorvlr := vr_tab_per_datas(vr_idx).vlrtotal;
      END IF;

      vr_vlrttdev := NVL(vr_vlrttdev,0) + NVL(vr_tab_per_datas(vr_idx).vlrtotal,0);
      vr_contador := vr_contador + 1;

      IF vr_idx = vr_tab_per_datas.LAST OR
         vr_tab_per_datas(vr_idx).cdagrupa <> vr_tab_per_datas(nvl(vr_tab_per_datas.NEXT(vr_idx),vr_idx)).cdagrupa then

        -- SE FOR ENTRADA
        IF pr_tpdmovto = 1 THEN
          IF (vr_contador > 1) THEN
            vr_vlrttdev := vr_vlrttdev - vr_maiorvlr;
            vr_vlrmedia := vr_vlrmedia + (vr_vlrttdev  / (vr_contador - 1));
          ELSE
            vr_vlrttdev := vr_maiorvlr;
            vr_vlrmedia := vr_vlrmedia + (vr_vlrttdev  / (vr_contador));
          END IF;
        -- SE FOR SAIDA
        ELSIF pr_tpdmovto = 2 THEN
          vr_vlrmedia := vr_vlrmedia + (vr_vlrttdev  / (vr_contador));
        END IF;

        vr_vlrttdev := 0;
        vr_contador := 0;
        vr_maiorvlr := 0;
      END IF;

      vr_idx := vr_tab_per_datas.NEXT(vr_idx);
    END LOOP;

    pc_grava_movimentacao(pr_cdcooper => pr_cdcooper      -- Codigo da Cooperativa
                         ,pr_dtmvtolt => pr_dtmvtolt      -- Data de movimento
                         ,pr_tpdmovto => (CASE pr_tpdmovto   -- Tipo de movimento
                                            WHEN 1 THEN 3
                                            ELSE 4
                                          END)
                         ,pr_cdbccxlt => 1                  -- Codigo do banco/caixa.
                         ,pr_tpdcampo => 6  /*VLMVTITG*/     -- Tipo de campo
                         ,pr_vldcampo => vr_vlrmedia         -- Valor do campo
                         ,pr_dscritic => pr_dscritic);

    IF pr_dscritic <> 'OK' THEN
      RAISE vr_exc_erro;
    END IF;

    pr_dscritic := 'OK';

  EXCEPTION
    WHEN vr_exc_erro THEN
        NULL;
    WHEN OTHERS THEN
      pr_dscritic := 'Erro na FLXF0001.pc_grava_prj_conta_itg: '||SQLerrm;
  END pc_grava_prj_conta_itg;

  -- Procedure para gravar movimento financeiro de cheques saida realizado
  PROCEDURE pc_grava_mvt_srcheques (pr_cdcooper IN INTEGER       -- Codigo da Cooperativa
                                   ,pr_dtmvtolt IN DATE          -- Data de movimento
                                   ,pr_dtmvtoan IN DATE          -- Data de movimento anterior
                                   ,pr_dscritic OUT VARCHAR2) AS -- Descrição da critica

    -- .........................................................................
    --
    --  Programa : pc_grava_mvt_srcheques          Antigo: 
    --
    --  Sistema  : Cred
    --  Sigla    : FLXF0001
    --  Autor    : Marcos Martini
    --  Data     : Outubro/2016.                   Ultima atualizacao: 
    --
    --  Dados referentes ao programa:
    --
    --   Objetivo  : Gravar movimento financeiro de cheques saida realizado
    --
    --   Atualizacao: 
    --..........................................................................

    vr_exc_erro      EXCEPTION;
    vr_vltotger      NUMBER(20,2);
    
  BEGIN
    
    vr_vltotger := 0;
  
    -- Buscar lancamentos do dia e data de referencia igual ao dia anterior
    FOR rw_craplcm IN cr_craplcm_cheques_p (pr_cdbccxlt => 85
                                           ,pr_dtmvtolt => pr_dtmvtolt
                                           ,pr_cdcooper => pr_cdcooper
                                           ,pr_dtrefere => pr_dtmvtoan) LOOP
      vr_vltotger := vr_vltotger + nvl(rw_craplcm.vllanmto,0);
    END LOOP;
  
    -- Buscar lancamentos do dia e data de referencia nula
    FOR rw_craplcm IN cr_craplcm_cheques (pr_cdbccxlt => 85
                                         ,pr_cdcooper => pr_cdcooper
                                         ,pr_dtmvtolt => pr_dtmvtolt) LOOP

      vr_vltotger := vr_vltotger + nvl(rw_craplcm.vllanmto,0);
    END LOOP;

    -- Buscar lancamentos do dia e data de referencia igual a data do dia
    FOR rw_craplcm IN cr_craplcm_cheques_p (pr_cdbccxlt => 85
                                           ,pr_dtmvtolt => pr_dtmvtolt
                                           ,pr_cdcooper => pr_cdcooper
                                           ,pr_dtrefere => pr_dtmvtolt) LOOP
      vr_vltotger := vr_vltotger + nvl(rw_craplcm.vllanmto,0);
    END LOOP;

    pc_grava_movimentacao(pr_cdcooper => pr_cdcooper   -- Codigo da Cooperativa
                         ,pr_dtmvtolt => pr_dtmvtolt   -- Data de movimento
                         ,pr_tpdmovto => 2             -- Tipo de movimento
                         ,pr_cdbccxlt => 85            -- Codigo do banco/caixa.
                         ,pr_tpdcampo => 1/*VLCHEQUE*/ -- Tipo de campo
                         ,pr_vldcampo => vr_vltotger   -- Valor do campo
                         ,pr_dscritic => pr_dscritic);

    IF pr_dscritic <> 'OK' THEN
      RETURN;
    END IF;

    pr_dscritic := 'OK';

  EXCEPTION
    WHEN OTHERS THEN
      -- gerar log de erro
      pr_dscritic := 'Erro na pc_grava_mvt_srcheques: '||SQLerrm;
  END pc_grava_mvt_srcheques;  

  -- Procedure para gravar movimento financeiro de cheques saida
  PROCEDURE pc_grava_prj_srcheques(pr_cdcooper IN INTEGER      -- Codigo da Cooperativa
                                  ,pr_dtmvtolt IN DATE         -- Data de movimento
                                  ,pr_flghistor IN BOOLEAN DEFAULT FALSE -- Flag para utilização da base histórica 
                                  ,pr_dscritic OUT VARCHAR2) AS          -- Descrição da critica

    -- .........................................................................
    --
    --  Programa : pc_grava_prj_srcheques          Antigo: b1wgen0131.p/pi_sr_cheques_f
    --
    --  Sistema  : Cred
    --  Sigla    : FLXF0001
    --  Autor    : Odirlei Busana
    --  Data     : novembro/2013.                   Ultima atualizacao: 11/11/2013
    --
    --  Dados referentes ao programa:
    --
    --   Objetivo  : Gravar movimento financeiro de cheques saida
    --
    --   Atualizacao: 08/11/2013 - Conversao Progress => Oracle (Odirlei-AMcom)
    --..........................................................................

    vr_exc_erro      EXCEPTION;
    vr_tab_per_datas typ_tab_per_datas;
    vr_idx           VARCHAR2(15);
    vr_dtproxim      DATE;
    vr_mesanter      NUMBER := 0;
    vr_contador      NUMBER := 0;
    vr_vltotger      NUMBER(20,2);
    vr_vlrmedia      NUMBER(20,2);
    
  BEGIN
    pc_gr_periodo_projecao_chqdoc
                           (pr_cdcooper => pr_cdcooper          -- Codigo da Cooperativa
                           ,pr_dtmvtolt => pr_dtmvtolt          -- Data de movimento
                           ,pr_tab_per_datas => vr_tab_per_datas-- Tabela de datas
                           ,pr_dscritic      => pr_dscritic);   -- Descrição da critica

    IF pr_dscritic <> 'OK' THEN
      return;
    END IF;

    vr_idx := vr_tab_per_datas.first;
    LOOP
      EXIT WHEN vr_idx is null;
      
      -- CAso utilizar base histórica
      IF pr_flghistor THEN 
        -- Buscar dos valores realizados e armazenados no fluxo financeiro 
        FOR rw_crapffm IN cr_crapffm_histor(pr_cdcooper => pr_cdcooper
                                           ,pr_dtmvtolt => vr_tab_per_datas(vr_idx).dtmvtolt
                                           ,pr_cdbccxlt => 85
                                           ,pr_tpdmovto => 2 --> Saida
                                           ,pr_tpdcampo => 1 --> VLCHEQUES
                                           ) LOOP 
          vr_tab_per_datas(vr_idx).vlrtotal := nvl(vr_tab_per_datas(vr_idx).vlrtotal,0) + nvl(rw_crapffm.vllanmto,0);
        END LOOP;
      ELSE
      
        --busca proxima data util
        vr_dtproxim := gene0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper,
                                                   pr_dtmvtolt => vr_tab_per_datas(vr_idx).dtmvtolt + 1,
                                                   pr_tipo     => 'P' ,
                                                   pr_feriado  => TRUE );

        -- Buscar lancamentos do proximo dia util
        FOR rw_craplcm IN cr_craplcm_cheques_p(pr_cdbccxlt => 85
                                              ,pr_dtmvtolt => vr_dtproxim
                                              ,pr_cdcooper => pr_cdcooper
                                              ,pr_dtrefere => vr_tab_per_datas(vr_idx).dtmvtolt) LOOP

          vr_tab_per_datas(vr_idx).vlrtotal := nvl(vr_tab_per_datas(vr_idx).vlrtotal,0) + nvl(rw_craplcm.vllanmto,0);
        END LOOP;

        -- Buscar lancamentos do dia e data de referencia nula
        FOR rw_craplcm IN cr_craplcm_cheques(pr_cdbccxlt => 85
                                            ,pr_cdcooper => pr_cdcooper
                                            ,pr_dtmvtolt => vr_tab_per_datas(vr_idx).dtmvtolt) LOOP

          vr_tab_per_datas(vr_idx).vlrtotal := nvl(vr_tab_per_datas(vr_idx).vlrtotal,0) + nvl(rw_craplcm.vllanmto,0);
        END LOOP;

        -- Buscar lancamentos do dia e data de referencia igual a data do dia
        FOR rw_craplcm IN cr_craplcm_cheques_p (pr_cdbccxlt => 85
                                               ,pr_dtmvtolt => vr_tab_per_datas(vr_idx).dtmvtolt
                                               ,pr_cdcooper => pr_cdcooper
                                               ,pr_dtrefere => vr_tab_per_datas(vr_idx).dtmvtolt) LOOP

          vr_tab_per_datas(vr_idx).vlrtotal := nvl(vr_tab_per_datas(vr_idx).vlrtotal,0) + nvl(rw_craplcm.vllanmto,0);
        END LOOP;
      END IF;
        
      -- contar os meses
      IF vr_mesanter <> to_char(vr_tab_per_datas(vr_idx).dtmvtolt,'MM') THEN
        vr_contador := nvl(vr_contador,0) + 1;
      END IF;

      vr_mesanter := to_char(vr_tab_per_datas(vr_idx).dtmvtolt,'MM');
      vr_vltotger := nvl(vr_vltotger,0) + nvl(vr_tab_per_datas(vr_idx).vlrtotal,0);

      -- busca o proximo
      vr_idx := vr_tab_per_datas.next(vr_idx);
    END LOOP; -- Fim loop per_datas

    -- calcular media mês
    IF vr_contador > 0 THEN
      vr_vlrmedia := (vr_vltotger / vr_contador);
    ELSE
      vr_vlrmedia := 0;
    END IF;

    --acrescentar percentual
    vr_vlrmedia := vr_vlrmedia + (vr_vlrmedia * fn_parfluxofinan(3));

    pc_grava_movimentacao(pr_cdcooper => pr_cdcooper   -- Codigo da Cooperativa
                         ,pr_dtmvtolt => pr_dtmvtolt   -- Data de movimento
                         ,pr_tpdmovto => 4             -- Tipo de movimento
                         ,pr_cdbccxlt => 85            -- Codigo do banco/caixa.
                         ,pr_tpdcampo => 1/*VLCHEQUE*/ -- Tipo de campo
                         ,pr_vldcampo => vr_vlrmedia   -- Valor do campo
                         ,pr_dscritic => pr_dscritic);

    IF pr_dscritic <> 'OK' THEN
      RETURN;
    END IF;

    pr_dscritic := 'OK';

  EXCEPTION
    WHEN OTHERS THEN
      -- gerar log de erro
      pr_dscritic := 'Erro na FLXF0001.pc_grava_prj_srcheques: '||SQLerrm;
  END pc_grava_prj_srcheques;
  
  -- Procedure para gravar movimento financeiro das movimentções de Cheques acolhidos para depositos nas contas dos associados.
  PROCEDURE pc_grava_mvt_nrcheques ( pr_cdcooper  IN INTEGER      -- Codigo da Cooperativa
                                    ,pr_dtmvtolt  IN DATE         -- Data de movimento
                                    ,pr_dscritic OUT VARCHAR2) AS -- Descrição da critica

    -- .........................................................................
    --
    --  Programa : pc_grava_mvt_nrcheques          Antigo: b1wgen0131.p/pi_cheques_f_nr
    --
    --
    --  Sistema  : Cred
    --  Sigla    : FLXF0001
    --  Autor    : Odirlei Busana
    --  Data     : novembro/2013.                   Ultima atualizacao: 20/11/2013
    --
    --  Dados referentes ao programa:
    --
    --   Objetivo  : Gravar movimento financeiro das movimentções de Cheques acolhidos para depositos nas contas dos associados.
    --
    --   Atualizacao: 20/11/2013 - Conversao Progress => Oracle (Odirlei-AMcom)
    --..........................................................................

    vr_exc_erro      EXCEPTION;
    vr_vlrchenr      NUMBER := 0;

  BEGIN

    vr_vlrchenr := 0;

    --Buscar Lancamentos de Cheques acolhidos para depositos nas contas dos associados.
    FOR rw_crapchd IN cr_crapchd(pr_dtmvtolt
                                ,pr_cdcooper
                                ,0) LOOP
      vr_vlrchenr := vr_vlrchenr + nvl(rw_crapchd.vlcheque,0);
    END LOOP;

    pc_grava_movimentacao(pr_cdcooper => pr_cdcooper   -- Codigo da Cooperativa
                         ,pr_dtmvtolt => pr_dtmvtolt   -- Data de movimento
                         ,pr_tpdmovto => 1             -- Tipo de movimento
                         ,pr_cdbccxlt => 85            -- Codigo do banco/caixa.
                         ,pr_tpdcampo => 1/*VLCHEQUE*/ -- Tipo de campo
                         ,pr_vldcampo => vr_vlrchenr   -- Valor do campo
                         ,pr_dscritic => pr_dscritic);

    IF pr_dscritic <> 'OK' THEN
      RAISE vr_exc_erro;
    END IF;


    pr_dscritic := 'OK';

  EXCEPTION
    WHEN vr_exc_erro THEN
        NULL;
    WHEN OTHERS THEN
      pr_dscritic := 'Erro na FLXF0001.pc_grava_mvt_nrcheques: '||SQLerrm;
  END pc_grava_mvt_nrcheques;  
  
  -- Procedure para gravar movimento financeiro de cheques entrada
  PROCEDURE pc_grava_prj_nrcheques(pr_cdcooper IN INTEGER      -- Codigo da Cooperativa
                                  ,pr_dtmvtolt IN DATE         -- Data de movimento
                                  ,pr_flghistor IN BOOLEAN DEFAULT FALSE -- Flag para utilização da base histórica 
                                  ,pr_dscritic OUT VARCHAR2) AS          -- Descrição da critica

    -- .........................................................................
    --
    --  Programa : pc_grava_prj_nrcheques
    --
    --  Sistema  : Cred
    --  Sigla    : FLXF0001
    --  Autor    : Marcos Martini
    --  Data     : Outubro/2013.                   Ultima atualizacao: 
    --
    --  Dados referentes ao programa:
    --
    --   Objetivo  : Gravar movimento financeiro de cheques saida
    --
    --   Atualizacao: 
    --..........................................................................

    vr_exc_erro      EXCEPTION;
    vr_tab_per_datas typ_tab_per_datas;
    vr_idx           VARCHAR2(15);
    vr_mesanter      NUMBER := 0;
    vr_contador      NUMBER := 0;
    vr_vltotger      NUMBER(20,2);
    vr_vlrmedia      NUMBER(20,2);
    
  BEGIN
    -- Gerar período de projeção
    pc_gr_periodo_projecao_chqdoc
                           (pr_cdcooper => pr_cdcooper          -- Codigo da Cooperativa
                           ,pr_dtmvtolt => pr_dtmvtolt          -- Data de movimento
                           ,pr_tab_per_datas => vr_tab_per_datas-- Tabela de datas
                           ,pr_dscritic      => pr_dscritic);   -- Descrição da critica

    IF pr_dscritic <> 'OK' THEN
      return;
    END IF;


    vr_idx := vr_tab_per_datas.first;
    LOOP
      EXIT WHEN vr_idx is null;
      
      -- CAso utilizar base histórica
      IF pr_flghistor THEN 
        -- Buscar dos valores realizados e armazenados no fluxo financeiro 
        FOR rw_crapffm IN cr_crapffm_histor(pr_cdcooper => pr_cdcooper
                                           ,pr_dtmvtolt => vr_tab_per_datas(vr_idx).dtmvtolt
                                           ,pr_cdbccxlt => 85
                                           ,pr_tpdmovto => 1 --> Entrada
                                           ,pr_tpdcampo => 1 --> VLCHEQUE
                                           ) LOOP 
          vr_tab_per_datas(vr_idx).vlrtotal := nvl(vr_tab_per_datas(vr_idx).vlrtotal,0) + nvl(rw_crapffm.vllanmto,0);
        END LOOP;
      ELSE       
        --Buscar Lancamentos de Cheques acolhidos para depositos nas contas dos associados.
        FOR rw_crapchd IN cr_crapchd(vr_tab_per_datas(vr_idx).dtmvtolt
                                    ,pr_cdcooper
                                    ,0) LOOP
          vr_tab_per_datas(vr_idx).vlrtotal := nvl(vr_tab_per_datas(vr_idx).vlrtotal,0) + nvl(rw_crapchd.vlcheque,0);      
        END LOOP;
      END IF;  
      
      -- contar os meses
      IF vr_mesanter <> to_char(vr_tab_per_datas(vr_idx).dtmvtolt,'MM') THEN
        vr_contador := nvl(vr_contador,0) + 1;
      END IF;

      vr_mesanter := to_char(vr_tab_per_datas(vr_idx).dtmvtolt,'MM');
      vr_vltotger := nvl(vr_vltotger,0) + nvl(vr_tab_per_datas(vr_idx).vlrtotal,0);

      -- busca o proximo
      vr_idx := vr_tab_per_datas.next(vr_idx);
    END LOOP; -- Fim loop per_datas

    -- calcular media mês
    IF vr_contador > 0 THEN
      vr_vlrmedia := (vr_vltotger / vr_contador);
    ELSE
      vr_vlrmedia := 0;
    END IF;

    pc_grava_movimentacao(pr_cdcooper => pr_cdcooper   -- Codigo da Cooperativa
                         ,pr_dtmvtolt => pr_dtmvtolt   -- Data de movimento
                         ,pr_tpdmovto => 3             -- Tipo de movimento
                         ,pr_cdbccxlt => 85            -- Codigo do banco/caixa.
                         ,pr_tpdcampo => 1/*VLCHEQUE*/ -- Tipo de campo
                         ,pr_vldcampo => vr_vlrmedia   -- Valor do campo
                         ,pr_dscritic => pr_dscritic);

    IF pr_dscritic <> 'OK' THEN
      RETURN;
    END IF;

    pr_dscritic := 'OK';

  EXCEPTION
    WHEN OTHERS THEN
      -- gerar log de erro
      pr_dscritic := 'Erro na FLXF0001.pc_grava_prj_nrcheques: '||SQLerrm;
  END pc_grava_prj_nrcheques;  

  -- Procedure para gravar movimento financeiro dos titulos
  PROCEDURE pc_grava_mvt_srtitulos (pr_cdcooper IN INTEGER      -- Codigo da Cooperativa
                                   ,pr_nmdatela IN VARCHAR2    -- Nome da tela
                                   ,pr_dtmvtolt IN DATE         -- Data de movimento
                                   ,pr_dscritic OUT VARCHAR2) AS          -- Descrição da critica

    -- .........................................................................
    --
    --  Programa : pc_grava_mvt_srtitulos          Antigo: b1wgen0131.p/pi_sr_titulos_f
    --
    --
    --  Sistema  : Cred
    --  Sigla    : FLXF0001
    --  Autor    : Odirlei Busana
    --  Data     : novembro/2013.                   Ultima atualizacao: 11/11/2013
    --
    --  Dados referentes ao programa:
    --
    --   Objetivo  : Gravar movimento financeiro dos titulos
    --
    --   Atualizacao: 08/11/2013 - Conversao Progress => Oracle (Odirlei-AMcom)
    --..........................................................................

    vr_exc_erro      EXCEPTION;
    -- Variaveis para calculo do movimento
    vr_vlrdotit_01      NUMBER;
    vr_vlrdotit_85      NUMBER;    
    
  BEGIN

    -- Inicializar valores
    vr_vlrdotit_01 := 0;
    vr_vlrdotit_85 := 0;
    
    
    /* No processo jah teremos os valores da CENTRAL */
    IF nvl(pr_nmdatela,' ') <> 'FLUXOS' THEN
      -- Buscaremos na LCM da Central
      FOR rw_craplcm IN cr_craplcm_parame_central(pr_cdbccxlt => 85
                                                 ,pr_dtmvtolt => pr_dtmvtolt
                                                 ,pr_cdcooper => pr_cdcooper
                                                 ,pr_cdremessa => 4
                                                 ,pr_tpfluxo   => 'E') LOOP
        -- Somar valores
        vr_vlrdotit_85 := NVL(vr_vlrdotit_85,0) + NVL(rw_craplcm.vllanmto,0);
      END LOOP;
    ELSE
      -- Buscaremos na COBRAN pois ainda não houve compensação
      FOR rw_crapcob IN cr_crapcob(pr_cdcooper,pr_dtmvtolt) LOOP
        vr_vlrdotit_85 := nvl(vr_vlrdotit_85,0) + nvl(rw_crapcob.vldpagto,0);
      END LOOP;
    END IF;  
    
    -- Gravar Cecred
    pc_grava_movimentacao(pr_cdcooper => pr_cdcooper    -- Codigo da Cooperativa
                         ,pr_dtmvtolt => pr_dtmvtolt    -- Data de movimento
                         ,pr_tpdmovto => 1              -- Tipo de movimento
                         ,pr_cdbccxlt => 85             -- Codigo do banco/caixa.
                         ,pr_tpdcampo => 4 /*VLTOTTIT*/ -- Tipo de campo
                         ,pr_vldcampo => vr_vlrdotit_85 -- Valor do campo
                         ,pr_dscritic => pr_dscritic);

    IF pr_dscritic <> 'OK' THEN
      RETURN;
    END IF;
    
    
    /* No processo jah teremos os valores da CENTRAL */
    IF nvl(pr_nmdatela,' ') <> 'FLUXOS' THEN
      -- Buscaremos na LCM
      FOR rw_craplcm IN cr_craplcm_parame(pr_cdbccxlt => 1
                                         ,pr_dtmvtolt => pr_dtmvtolt
                                         ,pr_cdcooper => pr_cdcooper
                                         ,pr_cdremessa => 4
                                         ,pr_tpfluxo   => 'E') LOOP
        -- Somar valores
        vr_vlrdotit_01 := NVL(vr_vlrdotit_01,0) + NVL(rw_craplcm.vllanmto,0);
      END LOOP;
    ELSE
      -- Buscar boletos BB Sempre na Cobran
      FOR rw_crapcob IN cr_crapcob_bb(pr_cdcooper,pr_dtmvtolt) LOOP
        vr_vlrdotit_01 := nvl(vr_vlrdotit_01,0) + nvl(rw_crapcob.vldpagto,0);
      END LOOP;
    END IF;  
   
    -- Gravar BBRasil
    pc_grava_movimentacao(pr_cdcooper => pr_cdcooper    -- Codigo da Cooperativa
                         ,pr_dtmvtolt => pr_dtmvtolt    -- Data de movimento
                         ,pr_tpdmovto => 1              -- Tipo de movimento
                         ,pr_cdbccxlt => 01             -- Codigo do banco/caixa.
                         ,pr_tpdcampo => 4 /*VLTOTTIT*/ -- Tipo de campo
                         ,pr_vldcampo => vr_vlrdotit_01 -- Valor do campo
                         ,pr_dscritic => pr_dscritic);

    IF pr_dscritic <> 'OK' THEN
      RETURN;
    END IF;

    pr_dscritic := 'OK';

  EXCEPTION
    WHEN OTHERS THEN
      pr_dscritic := 'Erro na FLXF0001.pc_grava_mvt_titulos: '||SQLerrm;

  END pc_grava_mvt_srtitulos;
  
  -- Procedure para gravar movimento financeiro dos titulos SR
  PROCEDURE pc_grava_prj_srtitulos (pr_cdcooper IN INTEGER      -- Codigo da Cooperativa
                                   ,pr_dtmvtolt IN DATE         -- Data de movimento
                                   ,pr_flghistor IN BOOLEAN DEFAULT FALSE -- Flag para utilização da base histórica 
                                   ,pr_dscritic OUT VARCHAR2) AS          -- Descrição da critica

    -- .........................................................................
    --
    --  Programa : pc_grava_prj_srtitulos          Antigo: b1wgen0131.p/pi_sr_titulos_f
    --
    --
    --  Sistema  : Cred
    --  Sigla    : FLXF0001
    --  Autor    : Odirlei Busana
    --  Data     : novembro/2013.                   Ultima atualizacao: 11/11/2013
    --
    --  Dados referentes ao programa:
    --
    --   Objetivo  : Gravar movimento financeiro dos titulos
    --
    --   Atualizacao: 08/11/2013 - Conversao Progress => Oracle (Odirlei-AMcom)
    --..........................................................................

    vr_exc_erro      EXCEPTION;
    vr_tab_per_datas typ_tab_per_datas;
    -- Variaveis para calculo do movimento
    vr_contador      NUMBER;
    vr_vlrmedia      NUMBER;
    vr_vltotger      NUMBER;
    vr_idx           VARCHAR2(15);
    
  BEGIN

    -- gerar os periodo de projeção titulo
    pc_gera_periodo_projecao_tit (pr_cdcooper => pr_cdcooper   -- Codigo da Cooperativa
                                 ,pr_dtmvtolt => pr_dtmvtolt   -- Data de movimento
                                 ,pr_cdagrupa => 1             -- Código de agrupamento
                                 --out
                                 ,pr_tab_per_datas => vr_tab_per_datas -- Tabela de datas
                                 ,pr_dscritic      => pr_dscritic);

    IF pr_dscritic <> 'OK' THEN
      RETURN;
    ELSE
      pr_dscritic := NULL;
    END IF;
    
    
    -- Inicializar valores
    vr_contador := 0;
    vr_vlrmedia := 0;
    vr_vltotger := 0;

    -- Buscar remessas 85
    vr_idx := vr_tab_per_datas.first;
    LOOP
      EXIT WHEN vr_idx IS NULL;

      -- CAso utilizar base histórica
      IF pr_flghistor THEN 
        -- Buscar dos valores realizados e armazenados no fluxo financeiro 
        FOR rw_crapffm IN cr_crapffm_histor(pr_cdcooper => pr_cdcooper
                                           ,pr_dtmvtolt => vr_tab_per_datas(vr_idx).dtmvtolt
                                           ,pr_cdbccxlt => 85
                                           ,pr_tpdmovto => 1 --> Entrada
                                           ,pr_tpdcampo => 4 /*VLTOTTIT*/
                                           ) LOOP 
          vr_vltotger := NVL(vr_vltotger,0) + nvl(rw_crapffm.vllanmto,0);
        END LOOP;
      ELSE 
        -- buscar lançamentos
        FOR rw_craplcm IN cr_craplcm_parame_central(pr_cdbccxlt => 85
                                                   ,pr_dtmvtolt => vr_tab_per_datas(vr_idx).dtmvtolt
                                                   ,pr_cdcooper => pr_cdcooper
                                                   ,pr_cdremessa => 4
                                                   ,pr_tpfluxo   => 'E') LOOP
          -- Somar valores
          vr_vltotger := NVL(vr_vltotger,0) + NVL(rw_craplcm.vllanmto,0);
        END LOOP;
      END IF;  

      vr_contador := vr_contador + 1;

      vr_idx := vr_tab_per_datas.NEXT(vr_idx);
    END LOOP;

    -- calcular media mês
    IF vr_contador > 0 THEN
      vr_vlrmedia := (vr_vltotger / vr_contador);
    ELSE
      vr_vlrmedia := 0;
    END IF;

    -- Buscar valor na posição 4
    vr_vlrmedia := vr_vlrmedia + (vr_vlrmedia * fn_parfluxofinan(4));

    pc_grava_movimentacao(pr_cdcooper => pr_cdcooper     -- Codigo da Cooperativa
                         ,pr_dtmvtolt => pr_dtmvtolt     -- Data de movimento
                         ,pr_tpdmovto => 3               -- Tipo de movimento
                         ,pr_cdbccxlt => 85              -- Codigo do banco/caixa.
                         ,pr_tpdcampo => 4 /*VLTOTTIT*/  -- Tipo de campo
                         ,pr_vldcampo => vr_vlrmedia     -- Valor do campo
                         ,pr_dscritic => pr_dscritic);

    IF pr_dscritic <> 'OK' THEN
      RETURN;
    END IF;
    
    -- Buscar valores de Titulos BBrasil 
    
    -- Inicializar valores
    vr_contador := 0;
    vr_vlrmedia := 0;
    vr_vltotger := 0;

    -- Buscar remessas 85
    vr_idx := vr_tab_per_datas.first;
    LOOP
      EXIT WHEN vr_idx IS NULL;

      -- CAso utilizar base histórica
      IF pr_flghistor THEN 
        -- Buscar dos valores realizados e armazenados no fluxo financeiro 
        FOR rw_crapffm IN cr_crapffm_histor(pr_cdcooper => pr_cdcooper
                                           ,pr_dtmvtolt => vr_tab_per_datas(vr_idx).dtmvtolt
                                           ,pr_cdbccxlt => 1 
                                           ,pr_tpdmovto => 1 --> Entrada
                                           ,pr_tpdcampo => 4 /*VLTOTTIT*/
                                           ) LOOP 
          vr_vltotger := NVL(vr_vltotger,0) + nvl(rw_crapffm.vllanmto,0);
        END LOOP;
      ELSE 
        -- buscar lançamentos
        FOR rw_craplcm IN cr_craplcm_parame(pr_cdbccxlt => 1
                                           ,pr_dtmvtolt => vr_tab_per_datas(vr_idx).dtmvtolt
                                           ,pr_cdcooper => pr_cdcooper
                                           ,pr_cdremessa => 4
                                           ,pr_tpfluxo   => 'E') LOOP
          -- Somar valores
          vr_vltotger := NVL(vr_vltotger,0) + NVL(rw_craplcm.vllanmto,0);
        END LOOP;
      END IF;  

      vr_contador := vr_contador + 1;

      vr_idx := vr_tab_per_datas.NEXT(vr_idx);
    END LOOP;

    -- calcular media mês
    IF vr_contador > 0 THEN
      vr_vlrmedia := (vr_vltotger / vr_contador);
    ELSE
      vr_vlrmedia := 0;
    END IF;

    -- Buscar valor na posição 4
    vr_vlrmedia := vr_vlrmedia + (vr_vlrmedia * fn_parfluxofinan(4));

    pc_grava_movimentacao(pr_cdcooper => pr_cdcooper     -- Codigo da Cooperativa
                         ,pr_dtmvtolt => pr_dtmvtolt     -- Data de movimento
                         ,pr_tpdmovto => 3               -- Tipo de movimento
                         ,pr_cdbccxlt => 1               -- Codigo do banco/caixa.
                         ,pr_tpdcampo => 4 /*VLTOTTIT*/  -- Tipo de campo
                         ,pr_vldcampo => vr_vlrmedia     -- Valor do campo
                         ,pr_dscritic => pr_dscritic);

    IF pr_dscritic <> 'OK' THEN
      RETURN;
    END IF;
    

    pr_dscritic := 'OK';

  EXCEPTION
    WHEN OTHERS THEN
      pr_dscritic := 'Erro na FLXF0001.pc_grava_prj_srtitulos: '||SQLerrm;

  END pc_grava_prj_srtitulos;    

  -- Procedure para gravar movimento financeiro dos titulos *****
  PROCEDURE pc_grava_mvt_nrtitulos (pr_cdcooper  IN INTEGER      -- Codigo da Cooperativa
                                   ,pr_dtmvtolt  IN DATE         -- Data de movimento
                                   ,pr_dtmvtoan  IN DATE         -- Data de movimento anterior
                                   ,pr_dscritic OUT VARCHAR2) AS -- Descrição da critica

    -- .........................................................................
    --
    --  Programa : pc_grava_mvt_nrtitulos          Antigo: b1wgen0131.p/pi_titulos_f_nr
    --
    --
    --  Sistema  : Cred
    --  Sigla    : FLXF0001
    --  Autor    : Odirlei Busana
    --  Data     : novembro/2013.                   Ultima atualizacao: 21/11/2013
    --
    --  Dados referentes ao programa:
    --
    --   Objetivo  : Gravar movimento financeiro dos titulos *****
    --
    --   Atualizacao: 21/11/2013 - Conversao Progress => Oracle (Odirlei-AMcom)
    --..........................................................................

    vr_exc_erro      EXCEPTION;
    vr_vlrtitnr      NUMBER := 0;

  BEGIN

    vr_vlrtitnr := 0;

    --Buscar titulos Cecred 
    FOR rw_craptit IN cr_craptit(pr_dtmvtolt => pr_dtmvtolt,
                                 pr_cdcooper => pr_cdcooper) LOOP

      vr_vlrtitnr := vr_vlrtitnr + nvl(rw_craptit.vldpagto,0);
    END LOOP;

    pc_grava_movimentacao(pr_cdcooper => pr_cdcooper   -- Codigo da Cooperativa
                         ,pr_dtmvtolt => pr_dtmvtolt   -- Data de movimento
                         ,pr_tpdmovto => 2             -- Tipo de movimento
                         ,pr_cdbccxlt => 85            -- Codigo do banco/caixa.
                         ,pr_tpdcampo => 4 /*VLTOTTIT*/           -- Tipo de campo
                         ,pr_vldcampo => vr_vlrtitnr              -- Valor do campo
                         ,pr_dscritic => pr_dscritic);

    IF pr_dscritic <> 'OK' THEN
      RAISE vr_exc_erro;
    END IF;
    
    --Buscar Retorno do COBAN
    vr_vlrtitnr := 0;    
    FOR rw_craprcb IN cr_craprcb(pr_dtmvtolt => pr_dtmvtoan,
                                 pr_cdcooper => pr_cdcooper) LOOP

      /* para resumo do banco do brasil */
      IF rw_craprcb.cdtransa = '284'  THEN   /* INSS */
        vr_vlrtitnr := vr_vlrtitnr - nvl(rw_craprcb.valorpag,0);
      ELSE  /* Titulos e Faturas */
        vr_vlrtitnr := vr_vlrtitnr + nvl(rw_craprcb.valorpag,0);
      END IF;
    END LOOP;--Fim Loop cr_craprcb

    pc_grava_movimentacao(pr_cdcooper => pr_cdcooper   -- Codigo da Cooperativa
                         ,pr_dtmvtolt => pr_dtmvtolt   -- Data de movimento
                         ,pr_tpdmovto => 2             -- Tipo de movimento
                         ,pr_cdbccxlt => 01            -- Codigo do banco/caixa.
                         ,pr_tpdcampo => 4 /*VLTOTTIT*/-- Tipo de campo
                         ,pr_vldcampo => vr_vlrtitnr   -- Valor do campo
                         ,pr_dscritic => pr_dscritic);

    IF pr_dscritic <> 'OK' THEN
      RAISE vr_exc_erro;
    END IF;

    pr_dscritic := 'OK';

  EXCEPTION
    WHEN vr_exc_erro THEN
        NULL;
    WHEN OTHERS THEN
      pr_dscritic := 'Erro na FLXF0001.pc_grava_mvt_titulos_nr: '||SQLerrm;
  END pc_grava_mvt_nrtitulos;

  -- Procedure para gravar movimento financeiro dos titulos NR
  PROCEDURE pc_grava_prj_nrtitulos (pr_cdcooper IN INTEGER      -- Codigo da Cooperativa
                                   ,pr_dtmvtolt IN DATE         -- Data de movimento
                                   ,pr_flghistor IN BOOLEAN DEFAULT FALSE -- Flag para utilização da base histórica 
                                   ,pr_dscritic OUT VARCHAR2) AS          -- Descrição da critica

    -- .........................................................................
    --
    --  Programa : pc_grava_prj_nrtitulos
    --
    --
    --  Sistema  : Cred
    --  Sigla    : FLXF0001
    --  Autor    : Marcos Martini
    --  Data     : Outubro/2016.                   Ultima atualizacao: 
    --
    --  Dados referentes ao programa:
    --
    --   Objetivo  : Gravar movimento financeiro dos titulos NR
    --
    --   Atualizacao: 
    --..........................................................................

    vr_exc_erro      EXCEPTION;
    vr_tab_per_datas typ_tab_per_datas;
    -- Variaveis para calculo do movimento
    vr_contador      NUMBER;
    vr_vlrmedia      NUMBER;
    vr_vltotger      NUMBER;
    vr_idx           VARCHAR2(15);
    
  BEGIN

    -- gerar os periodo de projeção nr titulo
    pc_gera_periodo_projecao_tit (pr_cdcooper => pr_cdcooper   -- Codigo da Cooperativa
                                 ,pr_dtmvtolt => pr_dtmvtolt   -- Data de movimento
                                 ,pr_cdagrupa => 1             -- Código de agrupamento
                                 --out
                                 ,pr_tab_per_datas => vr_tab_per_datas -- Tabela de datas
                                 ,pr_dscritic      => pr_dscritic);

    IF pr_dscritic <> 'OK' THEN
      RETURN;
    ELSE
      pr_dscritic := NULL;
    END IF;

    -- Inicializar valores para titulos Cecred
    vr_contador := 0;
    vr_vlrmedia := 0;
    vr_vltotger := 0;

    vr_idx := vr_tab_per_datas.first;
    LOOP
      EXIT WHEN vr_idx IS NULL;

      -- CAso utilizar base histórica
      IF pr_flghistor THEN 
        -- Buscar dos valores realizados e armazenados no fluxo financeiro 
        FOR rw_crapffm IN cr_crapffm_histor(pr_cdcooper => pr_cdcooper
                                           ,pr_dtmvtolt => vr_tab_per_datas(vr_idx).dtmvtolt
                                           ,pr_cdbccxlt => 85
                                           ,pr_tpdmovto => 2 --> Saida
                                           ,pr_tpdcampo => 4 /*VLTOTTIT*/
                                           ) LOOP 
          vr_vltotger := vr_vltotger + nvl(rw_crapffm.vllanmto,0);
        END LOOP;
      ELSE 
        --Buscar titulos
        FOR rw_craptit IN cr_craptit(pr_dtmvtolt => vr_tab_per_datas(vr_idx).dtmvtolt,
                                     pr_cdcooper => pr_cdcooper) LOOP
          vr_vltotger := vr_vltotger + nvl(rw_craptit.vldpagto,0);
        END LOOP;
      END IF;  
      
      vr_contador := vr_contador + 1;
      vr_idx := vr_tab_per_datas.NEXT(vr_idx);
    END LOOP;

    -- calcular media mês
    IF vr_contador > 0 THEN
      vr_vlrmedia := (vr_vltotger / vr_contador);
    ELSE
      vr_vlrmedia := 0;
    END IF;

    pc_grava_movimentacao(pr_cdcooper => pr_cdcooper     -- Codigo da Cooperativa
                         ,pr_dtmvtolt => pr_dtmvtolt     -- Data de movimento
                         ,pr_tpdmovto => 4               -- Tipo de movimento
                         ,pr_cdbccxlt => 85              -- Codigo do banco/caixa.
                         ,pr_tpdcampo => 4 /*VLTOTTIT*/  -- Tipo de campo
                         ,pr_vldcampo => vr_vlrmedia     -- Valor do campo
                         ,pr_dscritic => pr_dscritic);

    IF pr_dscritic <> 'OK' THEN
      RETURN;
    END IF;
    
    -- Buscar titulos Banco do Brasil
    vr_contador := 0;
    vr_vlrmedia := 0;
    vr_vltotger := 0;

    vr_idx := vr_tab_per_datas.first;
    LOOP
      EXIT WHEN vr_idx IS NULL;

      -- CAso utilizar base histórica
      IF pr_flghistor THEN 
        -- Buscar dos valores realizados e armazenados no fluxo financeiro 
        FOR rw_crapffm IN cr_crapffm_histor(pr_cdcooper => pr_cdcooper
                                           ,pr_dtmvtolt => vr_tab_per_datas(vr_idx).dtmvtolt
                                           ,pr_cdbccxlt => 1
                                           ,pr_tpdmovto => 2 --> Saida
                                           ,pr_tpdcampo => 4 /*VLTOTTIT*/
                                           ) LOOP 
          vr_vltotger := vr_vltotger + nvl(rw_crapffm.vllanmto,0);
        END LOOP;
      ELSE 
        --Buscar titulos BB 
        FOR rw_craprcb IN cr_craprcb(pr_dtmvtolt => gene0005.fn_valida_dia_util(pr_cdcooper,vr_tab_per_datas(vr_idx).dtmvtolt-1,'A'),
                                     pr_cdcooper => pr_cdcooper) LOOP

          /* para resumo do banco do brasil */
          IF rw_craprcb.cdtransa = '284'  THEN   /* INSS */
            vr_vltotger := vr_vltotger - nvl(rw_craprcb.valorpag,0);
          ELSE  /* Titulos e Faturas */
            vr_vltotger := vr_vltotger + nvl(rw_craprcb.valorpag,0);
          END IF;
        END LOOP;--Fim Loop cr_craprcb
      END IF;  
      
      vr_contador := vr_contador + 1;
      vr_idx := vr_tab_per_datas.NEXT(vr_idx);
    END LOOP;
    
    -- calcular media mês
    IF vr_contador > 0 THEN
      vr_vlrmedia := (vr_vltotger / vr_contador);
    ELSE
      vr_vlrmedia := 0;
    END IF;    
    
    pc_grava_movimentacao(pr_cdcooper => pr_cdcooper   -- Codigo da Cooperativa
                         ,pr_dtmvtolt => pr_dtmvtolt   -- Data de movimento
                         ,pr_tpdmovto => 4             -- Tipo de movimento
                         ,pr_cdbccxlt => 01            -- Codigo do banco/caixa.
                         ,pr_tpdcampo => 4 /*VLTOTTIT*/-- Tipo de campo
                         ,pr_vldcampo => vr_vlrmedia   -- Valor do campo
                         ,pr_dscritic => pr_dscritic);

    IF pr_dscritic <> 'OK' THEN
      RAISE vr_exc_erro;
    END IF;
    
    pr_dscritic := 'OK';

  EXCEPTION
    WHEN OTHERS THEN
      pr_dscritic := 'Erro na FLXF0001.pc_grava_prj_nrtitulos: '||SQLerrm;

  END pc_grava_prj_nrtitulos;    
  
  -- Procedure para gravar movimento financeiro dos docs
  PROCEDURE pc_grava_mvt_srdoc(pr_cdcooper IN INTEGER      -- Codigo da Cooperativa
                            ,pr_dtmvtolt IN DATE         -- Data de movimento
                            ,pr_dscritic OUT VARCHAR2) AS -- Descrição da critica

    -- .........................................................................
    --
    --  Programa : pc_grava_mvt_srdoc          Antigo: Não ha
    --
    --
    --  Sistema  : Cred
    --  Sigla    : FLXF0001
    --  Autor    : Marcos Martini
    --  Data     : Outubro/2016.                   Ultima atualizacao: 
    --
    --  Dados referentes ao programa:
    --
    --   Objetivo  : Gravar movimento financeiro dos docs realizados
    --
    --   Atualizacao: 
    --..........................................................................

    vr_exc_erro      EXCEPTION;
    -- variavel para calcular o movimento
    vr_vltotger      NUMBER;
    
  BEGIN

    vr_vltotger := 0;

    -- buscar lançamentos
    FOR rw_craplcm IN cr_craplcm_parame(pr_cdbccxlt  => 85
                                       ,pr_dtmvtolt  => pr_dtmvtolt
                                       ,pr_cdcooper  => pr_cdcooper
                                       ,pr_cdremessa => 2
                                       ,pr_tpfluxo   => 'E') LOOP
      -- Somar valores
      vr_vltotger := vr_vltotger + NVL(rw_craplcm.vllanmto,0);
    END LOOP;

    pc_grava_movimentacao(pr_cdcooper => pr_cdcooper   -- Codigo da Cooperativa
                         ,pr_dtmvtolt => pr_dtmvtolt   -- Data de movimento
                         ,pr_tpdmovto => 1             -- Tipo de movimento
                         ,pr_cdbccxlt => 85            -- Codigo do banco/caixa.
                         ,pr_tpdcampo => 2 /*VLTOTDOC*/-- Tipo de campo
                         ,pr_vldcampo => vr_vltotger   -- Valor do campo
                         ,pr_dscritic => pr_dscritic);

    IF pr_dscritic <> 'OK' THEN
      RETURN;
    END IF;

    pr_dscritic := 'OK';

  EXCEPTION
    WHEN OTHERS THEN
      pr_dscritic := 'Erro na FLXF0001.pc_grava_mvt_doc: '||SQLerrm;

  END pc_grava_mvt_srdoc;  

  -- Procedure para gravar movimento financeiro dos docs
  PROCEDURE pc_grava_prj_srdoc (pr_cdcooper IN INTEGER      -- Codigo da Cooperativa
                               ,pr_dtmvtolt IN DATE         -- Data de movimento
                               ,pr_flghistor IN BOOLEAN DEFAULT FALSE -- Flag para utilização da base histórica 
                               ,pr_dscritic OUT VARCHAR2) AS -- Descrição da critica

    -- .........................................................................
    --
    --  Programa : pc_grava_prj_srdoc          Antigo: b1wgen0131.p/pi_sr_doc_f
    --
    --
    --  Sistema  : Cred
    --  Sigla    : FLXF0001
    --  Autor    : Odirlei Busana
    --  Data     : novembro/2013.                   Ultima atualizacao: 11/11/2013
    --
    --  Dados referentes ao programa:
    --
    --   Objetivo  : Gravar movimento financeiro dos docs
    --
    --   Atualizacao: 08/11/2013 - Conversao Progress => Oracle (Odirlei-AMcom)
    --..........................................................................

    vr_exc_erro      EXCEPTION;
    vr_tab_per_datas typ_tab_per_datas;
    -- variavel para calcular o movimento
    vr_contador      NUMBER;
    vr_vlrmedia      NUMBER;
    vr_vltotger      NUMBER;
    vr_idx           VARCHAR2(15);
    -- Variavel para controlar o mes
    vr_mesanter      NUMBER := 0;
    
    vr_val number;
    vr_dt date;

  BEGIN

    vr_contador := 0;
    vr_vlrmedia := 0;
    vr_vltotger := 0;

    -- gerar os periodo de projeção chqdoc
    pc_gr_periodo_projecao_chqdoc (pr_cdcooper => pr_cdcooper   -- Codigo da Cooperativa
                                  ,pr_dtmvtolt => pr_dtmvtolt   -- Data de movimento
                                     --out
                                  ,pr_tab_per_datas => vr_tab_per_datas -- Tabela de datas
                                  ,pr_dscritic      => pr_dscritic);

    IF pr_dscritic <> 'OK' THEN
      RETURN;
    ELSE
      pr_dscritic := NULL;
    END IF;

    -- Ler todas as datas
    vr_idx := vr_tab_per_datas.first;
    LOOP
      EXIT WHEN vr_idx IS NULL;

      -- CAso utilizar base histórica
      IF pr_flghistor THEN 
        -- Buscar dos valores realizados e armazenados no fluxo financeiro 
        FOR rw_crapffm IN cr_crapffm_histor(pr_cdcooper => pr_cdcooper
                                           ,pr_dtmvtolt => vr_tab_per_datas(vr_idx).dtmvtolt
                                           ,pr_cdbccxlt => 85
                                           ,pr_tpdmovto => 1 --> Entrada
                                           ,pr_tpdcampo => 2 /*VLTOTDOC*/
                                           ) LOOP 
          vr_tab_per_datas(vr_idx).vlrtotal := NVL(vr_tab_per_datas(vr_idx).vlrtotal,0) + nvl(rw_crapffm.vllanmto,0);
        END LOOP;
      ELSE 
        -- buscar lançamentos
        FOR rw_craplcm IN cr_craplcm_parame(pr_cdbccxlt  => 85
                                           ,pr_dtmvtolt  => vr_tab_per_datas(vr_idx).dtmvtolt
                                           ,pr_cdcooper  => pr_cdcooper
                                           ,pr_cdremessa => 2
                                           ,pr_tpfluxo   => 'E') LOOP
          -- Somar valores
          vr_tab_per_datas(vr_idx).vlrtotal := NVL(vr_tab_per_datas(vr_idx).vlrtotal,0) + NVL(rw_craplcm.vllanmto,0);
        END LOOP;
      END IF;  

      -- incrementar contador de mes
      IF vr_mesanter <> to_char(vr_tab_per_datas(vr_idx).dtmvtolt,'MM') THEN
        vr_contador := nvl(vr_contador,0) + 1;
      END IF;

      vr_val := vr_tab_per_datas(vr_idx).vlrtotal;
      vr_dt  := vr_tab_per_datas(vr_idx).dtmvtolt;

      vr_mesanter := to_char(vr_tab_per_datas(vr_idx).dtmvtolt,'MM');
      vr_vltotger := nvl(vr_vltotger,0) + nvl(vr_tab_per_datas(vr_idx).vlrtotal,0);

      vr_idx := vr_tab_per_datas.NEXT(vr_idx);
    END LOOP; --Fim loop periodo

    -- calcular media mês
    IF vr_contador > 0 THEN
      vr_vlrmedia := (vr_vltotger / vr_contador);
    ELSE
      vr_vlrmedia := 0;
    END IF;

    -- Buscar valor na posição 2, e acrescentar percentual
    vr_vlrmedia := vr_vlrmedia + (vr_vlrmedia * fn_parfluxofinan(2));

    pc_grava_movimentacao(pr_cdcooper => pr_cdcooper    -- Codigo da Cooperativa
                         ,pr_dtmvtolt => pr_dtmvtolt    -- Data de movimento
                         ,pr_tpdmovto => 3              -- Tipo de movimento
                         ,pr_cdbccxlt => 85             -- Codigo do banco/caixa.
                         ,pr_tpdcampo => 2 /*VLTOTDOC*/ -- Tipo de campo
                         ,pr_vldcampo => vr_vlrmedia    -- Valor do campo
                         ,pr_dscritic => pr_dscritic);

    IF pr_dscritic <> 'OK' THEN
      RETURN;
    END IF;


    pr_dscritic := 'OK';

  EXCEPTION
    WHEN OTHERS THEN
      pr_dscritic := 'Erro na FLXF0001.pc_grava_prj_srdoc: '||SQLerrm;

  END pc_grava_prj_srdoc;

  -- Procedure para gravar movimento financeiro das transferencias DOCs
  PROCEDURE pc_grava_mvt_nrdoc (pr_cdcooper  IN INTEGER      -- Codigo da Cooperativa
                               ,pr_dtmvtolt  IN DATE         -- Data de movimento
                               ,pr_dscritic OUT VARCHAR2) AS -- Descrição da critica

    -- .........................................................................
    --
    --  Programa : pc_grava_mvt_nrdoc          Antigo: b1wgen0131.p/pi_doc_f_nr
    --
    --
    --  Sistema  : Cred
    --  Sigla    : FLXF0001
    --  Autor    : Odirlei Busana
    --  Data     : novembro/2013.                   Ultima atualizacao: 21/11/2013
    --
    --  Dados referentes ao programa:
    --
    --   Objetivo  : Gravar movimento financeiro das transferencias DOCs
    --
    --   Atualizacao: 21/11/2013 - Conversao Progress => Oracle (Odirlei-AMcom)
    --..........................................................................

    vr_exc_erro      EXCEPTION;
    vr_vlrdocnr      NUMBER;

  BEGIN

    vr_vlrdocnr := 0;

    /* Transferencias - DOC*/
    FOR rw_craptvl IN cr_craptvl_nrdoc(pr_dtmvtolt => pr_dtmvtolt,
                                       pr_cdcooper => pr_cdcooper) LOOP

      vr_vlrdocnr := vr_vlrdocnr + nvl(rw_craptvl.vldocrcb,0);
    END LOOP;

    pc_grava_movimentacao(pr_cdcooper => pr_cdcooper   -- Codigo da Cooperativa
                         ,pr_dtmvtolt => pr_dtmvtolt   -- Data de movimento
                         ,pr_tpdmovto => 2             -- Tipo de movimento
                         ,pr_cdbccxlt => 85            -- Codigo do banco/caixa.
                         ,pr_tpdcampo => 2 /*VLTOTDOC*/-- Tipo de campo
                         ,pr_vldcampo => vr_vlrdocnr   -- Valor do campo
                         ,pr_dscritic => pr_dscritic);

    IF pr_dscritic <> 'OK' THEN
      RAISE vr_exc_erro;
    END IF;

    pr_dscritic := 'OK';

  EXCEPTION
    WHEN vr_exc_erro THEN
        NULL;
    WHEN OTHERS THEN
      pr_dscritic := 'Erro na FLXF0001.pc_grava_mvt_nrdoc: '||SQLerrm;
  END pc_grava_mvt_nrdoc;
  
  -- Procedure para gravar projeção movimento financeiro das transferencias DOCs
  PROCEDURE pc_grava_prj_nrdoc (pr_cdcooper  IN INTEGER      -- Codigo da Cooperativa
                               ,pr_dtmvtolt  IN DATE         -- Data de movimento
                               ,pr_flghistor IN BOOLEAN DEFAULT FALSE -- Flag para utilização da base histórica 
                               ,pr_dscritic OUT VARCHAR2) AS -- Descrição da critica

    -- .........................................................................
    --
    --  Programa : pc_grava_prj_nrdoc          
    --
    --
    --  Sistema  : Cred
    --  Sigla    : FLXF0001
    --  Autor    : Marcos Martini
    --  Data     : novembro/2013.                   Ultima atualizacao: 21/11/2013
    --
    --  Dados referentes ao programa:
    --
    --   Objetivo  : Gravar movimento financeiro projeção das transferencias DOCs
    --
    --   Atualizacao: 
    --..........................................................................

    vr_exc_erro      EXCEPTION;
    
    vr_tab_per_datas typ_tab_per_datas;
    
    -- variavel para calcular o movimento
    vr_contador  NUMBER;
    vr_vlrmedia  NUMBER;
    vr_vltotger  NUMBER;
    vr_idx       VARCHAR2(15);
    

  BEGIN

    vr_contador := 0;
    vr_vlrmedia := 0;
    vr_vltotger := 0;
    
    -- Gerar os periodo de projeção 1 ano considerando dia do mês e dia da semana
    pc_gera_period_dia_mes(pr_cdcooper => pr_cdcooper   -- Codigo da Cooperativa
                          ,pr_dtmvtolt => pr_dtmvtolt   -- Data de movimento
                          ,pr_qtdmeses => 12            -- Numero de meses a procurar
                          ,pr_fldiasem => TRUE          -- Considerar o dia da semana
                          ,pr_flprxant => FALSE         -- Considerar 1 dia para mais ou menos
                          ,pr_tab_per_datas => vr_tab_per_datas -- Tabela de datas
                          ,pr_dscritic  => pr_dscritic);
    IF pr_dscritic <> 'OK' THEN
      RETURN;
    ELSE
      pr_dscritic := NULL;
    END IF;
    
    -- Se não for encontado algum dia para projeção
    IF vr_tab_per_datas.count() = 0 THEN
      -- Gerar os periodo de projeção 1 ano considerando somente dia do mês
      pc_gera_period_dia_mes(pr_cdcooper => pr_cdcooper   -- Codigo da Cooperativa
                            ,pr_dtmvtolt => pr_dtmvtolt   -- Data de movimento
                            ,pr_qtdmeses => 12            -- Numero de meses a procurar
                            ,pr_fldiasem => FALSE          -- Considerar o dia da semana
                            ,pr_flprxant => FALSE         -- Considerar 1 dia para mais ou menos
                            ,pr_tab_per_datas => vr_tab_per_datas -- Tabela de datas
                            ,pr_dscritic  => pr_dscritic);

      IF pr_dscritic <> 'OK' THEN
        RETURN;
      ELSE
        pr_dscritic := NULL;
      END IF;  
    END IF;
    
    -- Ler todas as datas
    vr_idx := vr_tab_per_datas.first;
    LOOP
      EXIT WHEN vr_idx IS NULL;

      -- CAso utilizar base histórica
      IF pr_flghistor THEN 
        -- Buscar dos valores realizados e armazenados no fluxo financeiro 
        FOR rw_crapffm IN cr_crapffm_histor(pr_cdcooper => pr_cdcooper
                                           ,pr_dtmvtolt => vr_tab_per_datas(vr_idx).dtmvtolt
                                           ,pr_cdbccxlt => 85
                                           ,pr_tpdmovto => 2 --> Saida
                                           ,pr_tpdcampo => 2 /*VLTOTDOC*/
                                           ) LOOP 
          vr_vltotger := vr_vltotger + nvl(rw_crapffm.vllanmto,0);
        END LOOP;
      ELSE 
        /* Transferencias - DOC*/
        FOR rw_craptvl IN cr_craptvl_nrdoc(pr_dtmvtolt => vr_tab_per_datas(vr_idx).dtmvtolt,
                                           pr_cdcooper => pr_cdcooper) LOOP
          vr_vltotger := vr_vltotger + nvl(rw_craptvl.vldocrcb,0);
        END LOOP;
      END IF;  
      
      vr_contador := vr_contador + 1;
      
      vr_idx := vr_tab_per_datas.NEXT(vr_idx);
    END LOOP; --Fim loop periodo

    -- calcular media mês de ambas IFs
    IF vr_contador > 0 THEN
      vr_vlrmedia := (vr_vltotger / vr_contador);
    ELSE
      vr_vlrmedia := 0;
    END IF;

    pc_grava_movimentacao(pr_cdcooper => pr_cdcooper   -- Codigo da Cooperativa
                         ,pr_dtmvtolt => pr_dtmvtolt   -- Data de movimento
                         ,pr_tpdmovto => 4             -- Tipo de movimento
                         ,pr_cdbccxlt => 85            -- Codigo do banco/caixa.
                         ,pr_tpdcampo => 2 /*VLTOTDOC*/-- Tipo de campo
                         ,pr_vldcampo => vr_vlrmedia   -- Valor do campo
                         ,pr_dscritic => pr_dscritic);

    IF pr_dscritic <> 'OK' THEN
      RAISE vr_exc_erro;
    END IF;

    pr_dscritic := 'OK';

  EXCEPTION
    WHEN vr_exc_erro THEN
        NULL;
    WHEN OTHERS THEN
      pr_dscritic := 'Erro na FLXF0001.pc_grava_prj_nrdoc: '||SQLerrm;
  END pc_grava_prj_nrdoc;  
  
  -- Procedure para gravar movimento financeiro dos debitos de cartao de debito
  PROCEDURE pc_grava_mvt_cart_debito(pr_cdcooper  IN INTEGER      -- Codigo da Cooperativa
                                    ,pr_dtmvtolt  IN DATE         -- Data de movimento
                                    ,pr_dscritic OUT VARCHAR2) AS -- Descrição da critica

    -- .........................................................................
    --
    --  Programa : pc_grava_mvt_cart_debito          
    --
    --
    --  Sistema  : Cred
    --  Sigla    : FLXF0001
    --  Autor    : Marcos Martini
    --  Data     : Outubro/2016.                   Ultima atualizacao: 
    --
    --  Dados referentes ao programa:
    --
    --   Objetivo  : Gravar movimento financeiro dos lançamentos de debito no cartão
    --
    --   Atualizacao: 
    --..........................................................................

    vr_exc_erro      EXCEPTION;
    vr_vldebito      NUMBER := 0;


  BEGIN

    --Buscar Lancamentos de debito Bancoob
    vr_vldebito := 0;
    FOR rw_craplcm IN cr_craplcm_debcar(pr_dtmvtolt => pr_dtmvtolt
                                       ,pr_cdcooper => pr_cdcooper) LOOP
      vr_vldebito := vr_vldebito + nvl(rw_craplcm.vllanmto,0);
    END LOOP; -- Fim loop craplcm
    pc_grava_movimentacao(pr_cdcooper => pr_cdcooper   -- Codigo da Cooperativa
                         ,pr_dtmvtolt => pr_dtmvtolt   -- Data de movimento
                         ,pr_tpdmovto => 2             -- Tipo de movimento
                         ,pr_cdbccxlt => 756           -- Codigo do banco/caixa.
                         ,pr_tpdcampo => 14            -- Tipo de campo
                         ,pr_vldcampo => vr_vldebito   -- Valor do campo
                         ,pr_dscritic => pr_dscritic);

    IF pr_dscritic <> 'OK' THEN
      RAISE vr_exc_erro;
    END IF;    

    pr_dscritic := 'OK';

  EXCEPTION
    WHEN vr_exc_erro THEN
        NULL;
    WHEN OTHERS THEN
      pr_dscritic := 'Erro na FLXF0001.pc_grava_mvt_cart_debito: '||SQLerrm;
  END pc_grava_mvt_cart_debito;  
  
  -- Procedure para gravar projeção movimento financeiro dos debitos de cartao de debito
  PROCEDURE pc_grava_prj_cart_debito(pr_cdcooper  IN INTEGER      -- Codigo da Cooperativa
                                    ,pr_dtmvtolt  IN DATE         -- Data de movimento
                                    ,pr_flghistor IN BOOLEAN DEFAULT FALSE -- Flag para utilização da base histórica 
                                    ,pr_dscritic OUT VARCHAR2) AS -- Descrição da critica

    -- .........................................................................
    --
    --  Programa : pc_grava_prj_cart_debito          
    --
    --
    --  Sistema  : Cred
    --  Sigla    : FLXF0001
    --  Autor    : Marcos Martini
    --  Data     : Outubro/2016.                   Ultima atualizacao: 
    --
    --  Dados referentes ao programa:
    --
    --   Objetivo  : Gravar movimento financeiro dos lançamentos de debito no cartão
    --
    --   Atualizacao: 
    --..........................................................................

    vr_exc_erro      EXCEPTION;
    vr_tab_per_datas typ_tab_per_datas;
    
    -- variavel para calcular o movimento
    vr_contador NUMBER := 0;
    vr_vlrmedia NUMBER;
    vr_vltotger NUMBER := 0;
    vr_idx      VARCHAR2(15);


  BEGIN
     
    -- Gerar os periodo de projeção 1 ano considerando dia do mês e dia da semana
    pc_gera_period_dia_mes(pr_cdcooper => pr_cdcooper   -- Codigo da Cooperativa
                          ,pr_dtmvtolt => pr_dtmvtolt   -- Data de movimento
                          ,pr_qtdmeses => 12            -- Numero de meses a procurar
                          ,pr_fldiasem => TRUE          -- Considerar o dia da semana
                          ,pr_flprxant => FALSE         -- Considerar 1 dia para mais ou menos
                          ,pr_tab_per_datas => vr_tab_per_datas -- Tabela de datas
                          ,pr_dscritic  => pr_dscritic);
    IF pr_dscritic <> 'OK' THEN
      RETURN;
    ELSE
      pr_dscritic := NULL;
    END IF;

    -- Se não for encontado algum dia para projeção
    IF vr_tab_per_datas.count() = 0 THEN
      -- Gerar periodo projeção considerando somente o dia util 
      pc_gera_period_diautil (pr_cdcooper => pr_cdcooper   -- Codigo da Cooperativa
                             ,pr_dtmvtolt => pr_dtmvtolt   -- Data de movimento
                             ,pr_qtdmeses => 12            -- Ultimos 12 meses                             
                             ,pr_qtdocorr => 0             -- Limite de datas encontradas (0 não há)
                             ,pr_fldiasem => FALSE         -- Não Considerar o dia da semana
                             --out
                             ,pr_tab_per_datas => vr_tab_per_datas -- Tabela de datas
                             ,pr_dscritic      => pr_dscritic);

      IF pr_dscritic <> 'OK' THEN
        RETURN;
      ELSE
        pr_dscritic := NULL;
      END IF;
    END IF;
 
    -- Ler todas as datas
    vr_idx := vr_tab_per_datas.first;
    LOOP
      EXIT WHEN vr_idx IS NULL;

      -- CAso utilizar base histórica
      IF pr_flghistor THEN 
        -- Buscar dos valores realizados e armazenados no fluxo financeiro 
        FOR rw_crapffm IN cr_crapffm_histor(pr_cdcooper => pr_cdcooper
                                           ,pr_dtmvtolt => vr_tab_per_datas(vr_idx).dtmvtolt
                                           ,pr_cdbccxlt => 756
                                           ,pr_tpdmovto => 2 --> Saida
                                           ,pr_tpdcampo => 14 --> VLCARDEB
                                           ) LOOP 
          vr_vltotger := vr_vltotger + nvl(rw_crapffm.vllanmto,0);
        END LOOP;
      ELSE         
        -- Busca lançamentos de debito 
        FOR rw_craplcm IN cr_craplcm_debcar(pr_dtmvtolt => vr_tab_per_datas(vr_idx).dtmvtolt
                                           ,pr_cdcooper => pr_cdcooper) LOOP
          vr_vltotger := vr_vltotger + nvl(rw_craplcm.vllanmto,0);
        END LOOP; -- Fim loop craplcm
      END IF;
      
      vr_contador := vr_contador + 1;
      
      vr_idx := vr_tab_per_datas.NEXT(vr_idx);
    END LOOP; --Fim loop periodo

    -- calcular media mês de ambas IFs
    IF vr_contador > 0 THEN
      vr_vlrmedia := (vr_vltotger / vr_contador);
    ELSE
      vr_vlrmedia := 0;
    END IF;   
    
    -- Enfim, gravar movimentação 
    pc_grava_movimentacao(pr_cdcooper => pr_cdcooper   -- Codigo da Cooperativa
                         ,pr_dtmvtolt => pr_dtmvtolt   -- Data de movimento
                         ,pr_tpdmovto => 4             -- Tipo de movimento
                         ,pr_cdbccxlt => 756           -- Codigo do banco/caixa.
                         ,pr_tpdcampo => 14            -- Tipo de campo
                         ,pr_vldcampo => vr_vlrmedia   -- Valor do campo
                         ,pr_dscritic => pr_dscritic);

    IF pr_dscritic <> 'OK' THEN
      RAISE vr_exc_erro;
    END IF;    

    pr_dscritic := 'OK';

  EXCEPTION
    WHEN vr_exc_erro THEN
        NULL;
    WHEN OTHERS THEN
      pr_dscritic := 'Erro na FLXF0001.pc_grava_mvt_cart_debito: '||SQLerrm;
  END pc_grava_prj_cart_debito;    

  -- Procedure para gravar movimento financeiro das faturas de Cartao de Credito
  PROCEDURE pc_grava_mvt_fatura_cart_credi(pr_cdcooper  IN INTEGER      -- Codigo da Cooperativa
                                          ,pr_dtmvtolt  IN DATE         -- Data de movimento
                                          ,pr_dtmvtoan  IN DATE         -- Data anterior ao movimento
                                          ,pr_dscritic OUT VARCHAR2) AS -- Descrição da critica

    -- .........................................................................
    --
    --  Programa : pc_grava_mvt_fatura_cart_credi          Antigo: b1wgen0131.p/pi_rem_fatura_bradesco_f
    --
    --
    --  Sistema  : Cred
    --  Sigla    : FLXF0001
    --  Autor    : Odirlei Busana
    --  Data     : novembro/2013.                   Ultima atualizacao: 20/11/2013
    --
    --  Dados referentes ao programa:
    --
    --   Objetivo  : Gravar movimento financeiro das faturas de Cartão de Crédito
    --
    --   Atualizacao: 20/11/2013 - Conversao Progress => Oracle (Odirlei-AMcom)
    --..........................................................................

    vr_exc_erro      EXCEPTION;
    vr_vlremfat      NUMBER := 0;
    vr_dtdpagto      DATE;


  BEGIN
     
    --Buscar Lancamentos de cartão de crédito Cecred
    vr_vlremfat := 0;
    FOR rw_craplau IN cr_craplau_fatbra(pr_cdbccxlt => 85
                                       ,pr_dtmvtolt => pr_dtmvtolt
                                       ,pr_cdcooper => pr_cdcooper) LOOP
      vr_vlremfat := vr_vlremfat + nvl(rw_craplau.vllanaut,0);

    END LOOP;

    pc_grava_movimentacao(pr_cdcooper => pr_cdcooper   -- Codigo da Cooperativa
                         ,pr_dtmvtolt => pr_dtmvtolt   -- Data de movimento
                         ,pr_tpdmovto => 2             -- Tipo de movimento
                         ,pr_cdbccxlt => 85            -- Codigo do banco/caixa.
                         ,pr_tpdcampo => 10            -- Tipo de campo
                         ,pr_vldcampo => vr_vlremfat   -- Valor do campo
                         ,pr_dscritic => pr_dscritic);

    IF pr_dscritic <> 'OK' THEN
      RAISE vr_exc_erro;
    END IF;
    
    --Buscar Lancamentos de cartão de crédito Bancoob
    -- Repasses ocorrem somente dois dias após os pagamentos das faturas
    -- Como já recebemos d-1, então vamos diminuir mais um dia
    vr_dtdpagto := gene0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper
                                              ,pr_dtmvtolt => pr_dtmvtoan-1
                                              ,pr_tipo => 'A');
    vr_vlremfat := 0;
    FOR rw_craplcm IN cr_craplcm_parame(pr_cdbccxlt  => 756
                                       ,pr_dtmvtolt  => vr_dtdpagto
                                       ,pr_cdcooper  => pr_cdcooper
                                       ,pr_cdremessa => 10
                                       ,pr_tpfluxo   => 'S') LOOP
       vr_vlremfat := vr_vlremfat + nvl(rw_craplcm.vllanmto,0);
    END LOOP; -- Fim loop craplcm
    pc_grava_movimentacao(pr_cdcooper => pr_cdcooper   -- Codigo da Cooperativa
                         ,pr_dtmvtolt => pr_dtmvtolt   -- Data de movimento
                         ,pr_tpdmovto => 2             -- Tipo de movimento
                         ,pr_cdbccxlt => 756           -- Codigo do banco/caixa.
                         ,pr_tpdcampo => 10            -- Tipo de campo
                         ,pr_vldcampo => vr_vlremfat   -- Valor do campo
                         ,pr_dscritic => pr_dscritic);

    IF pr_dscritic <> 'OK' THEN
      RAISE vr_exc_erro;
    END IF;    

    pr_dscritic := 'OK';

  EXCEPTION
    WHEN vr_exc_erro THEN
        NULL;
    WHEN OTHERS THEN
      pr_dscritic := 'Erro na FLXF0001.pc_grava_mvt_fatura_cart_credi: '||SQLerrm;
  END pc_grava_mvt_fatura_cart_credi;
  
  -- Procedure para gravar movimento financeiro das faturas de Cartao de Credito
  PROCEDURE pc_grava_prj_fatura_cart_credi(pr_cdcooper  IN INTEGER      -- Codigo da Cooperativa
                                          ,pr_dtmvtolt  IN DATE         -- Data de movimento
                                          ,pr_flghistor IN BOOLEAN DEFAULT FALSE -- Flag para utilização da base histórica 
                                          ,pr_dscritic OUT VARCHAR2) AS -- Descrição da critica

    -- .........................................................................
    --
    --  Programa : pc_grava_prj_fatura_cart_credi          Antigo: b1wgen0131.p/pi_rem_fatura_bradesco_f
    --
    --
    --  Sistema  : Cred
    --  Sigla    : FLXF0001
    --  Autor    : Marcos Martini
    --  Data     : Novembro/2013.                   Ultima atualizacao: 
    --
    --  Dados referentes ao programa:
    --
    --   Objetivo  : Gravar movimento financeiro projetado das faturas de Cartão de Crédito
    --
    --   Atualizacao: 
    --..........................................................................

    vr_exc_erro      EXCEPTION;
    vr_dtmvtolt      DATE;
    vr_dtmvtopg      DATE;
    vr_dtmvtoan      DATE;
    vr_dtmvtovc      DATE;
    
    -- DAtas a projetar
    vr_tab_per_datas typ_tab_per_datas;
    vr_idx           VARCHAR2(15);
    
    -- DAdos para acumulo dos valores
    vr_contador NUMBER := 0;
    vr_vlrmedia NUMBER := 0;
    vr_vltotger NUMBER := 0;
    
    
  BEGIN
    -- Inicializar variaveis
    vr_contador := 0;
    vr_vlrmedia := 0;
    vr_vltotger := 0;
    
    -- Temos de garantir que o dia da busca seja um dia no passado, do contrário 
    -- não haverá valor realizado
    vr_dtmvtolt := pr_dtmvtolt;
    LOOP
      EXIT WHEN vr_dtmvtolt < SYSDATE;  
      vr_dtmvtolt := add_months(vr_dtmvtolt,-1);
    END LOOP;
    -- Garantir que o dia seja util, pois no add_months acima 
    -- podemos voltar em uma data feriado
    vr_dtmvtolt := gene0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper
                                              ,pr_dtmvtolt => vr_dtmvtolt);
    
    -- Iremos buscar a média dos lançamentos nos ultimos 12 meses para o mesmo dia do mês
    pc_gera_period_dia_mes(pr_cdcooper => pr_cdcooper   -- Codigo da Cooperativa
                          ,pr_dtmvtolt => vr_dtmvtolt   -- Data de movimento
                          ,pr_qtdmeses => 12            -- Numero de meses a procurar
                          ,pr_qtdocorr => 3             -- No maximo 3 ocorrências 
                          ,pr_fldiasem => FALSE         -- Considerar o dia da semana
                          ,pr_flprxant => FALSE         -- Considerar 1 dia para mais ou menos
                          ,pr_tab_per_datas => vr_tab_per_datas -- Tabela de datas
                          ,pr_dscritic  => pr_dscritic);    
    
    -- Ler todas as datas
    vr_idx := vr_tab_per_datas.first;
    LOOP
      EXIT WHEN vr_idx IS NULL;
      -- CAso utilizar base histórica
      IF pr_flghistor THEN 
        -- Buscar dos valores realizados e armazenados no fluxo financeiro 
        FOR rw_crapffm IN cr_crapffm_histor(pr_cdcooper => pr_cdcooper
                                           ,pr_dtmvtolt => vr_tab_per_datas(vr_idx).dtmvtolt
                                           ,pr_cdbccxlt => 85
                                           ,pr_tpdmovto => 2 --> Saida
                                           ,pr_tpdcampo => 10 --> VLCARCRE
                                           ) LOOP 
          vr_vltotger := vr_vltotger + nvl(rw_crapffm.vllanmto,0);
        END LOOP;
      ELSE 
        -- Buscar os valores pagos nos ultimos 6 meses, lembrando que a data deve ser util
        FOR rw_craplau IN cr_craplau_fatbra(pr_cdbccxlt => 85
                                           ,pr_dtmvtolt => vr_tab_per_datas(vr_idx).dtmvtolt
                                           ,pr_cdcooper => pr_cdcooper) LOOP
          vr_vltotger := vr_vltotger + nvl(rw_craplau.vllanaut,0);
        END LOOP;      
      END IF; 
       
      vr_contador := vr_contador + 1;
      
      vr_idx := vr_tab_per_datas.NEXT(vr_idx);
    END LOOP; --Fim loop periodo 
    
    -- Calcular a média 
    IF vr_contador > 0 THEN
      vr_vlrmedia := (vr_vltotger / vr_contador);
    ELSE
      vr_vlrmedia := 0;
    END IF;
    
    pc_grava_movimentacao(pr_cdcooper => pr_cdcooper   -- Codigo da Cooperativa
                         ,pr_dtmvtolt => pr_dtmvtolt   -- Data de movimento
                         ,pr_tpdmovto => 4             -- Tipo de movimento
                         ,pr_cdbccxlt => 85            -- Codigo do banco/caixa.
                         ,pr_tpdcampo => 10            -- Tipo de campo
                         ,pr_vldcampo => vr_vlrmedia   -- Valor do campo
                         ,pr_dscritic => pr_dscritic);

    IF pr_dscritic <> 'OK' THEN
      RAISE vr_exc_erro;
    END IF;
    
    
    -- Buscar Lancamentos de cartão de crédito Bancoob dos ultimos 6 meses
    vr_contador := 0;
    vr_vlrmedia := 0;
    vr_vltotger := 0;
    
    -- Repasse dos valores ocorre em D+2
    -- Buscar dois dias uteis antes do dia atual de busca    
    vr_dtmvtopg := vr_dtmvtolt;
    FOR vr_ind IN 1..2 LOOP
      vr_dtmvtopg := gene0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper
                                                ,pr_dtmvtolt => vr_dtmvtopg-1
                                                ,pr_tipo => 'A');
    END LOOP;   
    
    -- Buscar o dia util anterior ao dia de pagamento
    vr_dtmvtoan := gene0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper
                                              ,pr_dtmvtolt => vr_dtmvtopg-1
                                              ,pr_tipo => 'A');
    
    -- Buscar o vencimento mais próximo do pagamento
    IF to_char(vr_dtmvtopg,'dd') < 3 THEN 
      -- Vencimento dia 27 mês anterior 
      vr_dtmvtovc := to_date('27'||to_char(add_months(vr_dtmvtopg,-1),'mmrrrr'),'ddmmrrrr');
    ELSE
      -- Vencimento neste mês 
      IF to_char(vr_dtmvtopg,'dd') < 7 THEN 
        vr_dtmvtovc := to_date('03'||to_char(vr_dtmvtopg,'mmrrrr'),'ddmmrrrr');
      ELSIF to_char(vr_dtmvtopg,'dd') < 11 THEN 
        vr_dtmvtovc := to_date('07'||to_char(vr_dtmvtopg,'mmrrrr'),'ddmmrrrr');
      ELSIF to_char(vr_dtmvtopg,'dd') < 19 THEN 
        vr_dtmvtovc := to_date('11'||to_char(vr_dtmvtopg,'mmrrrr'),'ddmmrrrr');
      ELSIF to_char(vr_dtmvtopg,'dd') < 27 THEN 
        vr_dtmvtovc := to_date('19'||to_char(vr_dtmvtopg,'mmrrrr'),'ddmmrrrr');
      ELSE 
        vr_dtmvtovc := to_date('27'||to_char(vr_dtmvtopg,'mmrrrr'),'ddmmrrrr');
      END IF;
    END IF;
    
    -- Se o dia anterior ao movimento de pagamento não é util e o 
    -- vencimento fixo ocorreu após o ultimo dia util anterior 
    IF vr_dtmvtopg-1 != vr_dtmvtoan AND vr_dtmvtovc > vr_dtmvtoan AND vr_dtmvtovc < vr_dtmvtopg THEN   
      -- Gerar periodo de projeção usando o dia de vencimento:
      --   - retornar ultimos 12 meses
      --   - no máximo 3 ocorrências
      --   - De segunda a sexta
      pc_gera_period_dia_mes(pr_cdcooper => pr_cdcooper   -- Codigo da Cooperativa
                            ,pr_dtmvtolt => vr_dtmvtovc   -- Data de movimento
                            ,pr_qtdmeses => 12            -- Numero de meses a procurar
                            ,pr_qtdocorr => 3             -- No maximo 3 ocorrências 
                            ,pr_fldiasem => FALSE         -- Considerar o dia da semana
                            ,pr_flprxant => FALSE         -- Considerar 1 dia para mais ou menos
                            ,pr_listadia => '23456'       -- Segunda a sexta
                            ,pr_tab_per_datas => vr_tab_per_datas -- Tabela de datas
                            ,pr_dscritic  => pr_dscritic);
    ELSE 
      -- Gerar periodo de projeção usando o dia fixo do pagamento:
      --   - retornar ultimos 12 meses
      --   - no máximo 3 ocorrências
      --   - De terça a sexta
      pc_gera_period_dia_mes(pr_cdcooper => pr_cdcooper   -- Codigo da Cooperativa
                            ,pr_dtmvtolt => vr_dtmvtopg   -- Data de movimento
                            ,pr_qtdmeses => 12            -- Numero de meses a procurar
                            ,pr_qtdocorr => 3             -- No maximo 3 ocorrências 
                            ,pr_fldiasem => FALSE         -- Considerar o dia da semana
                            ,pr_flprxant => FALSE         -- Considerar 1 dia para mais ou menos
                            ,pr_listadia => '3456'        -- Terça a sexta
                            ,pr_tab_per_datas => vr_tab_per_datas -- Tabela de datas
                            ,pr_dscritic  => pr_dscritic);
    END IF;
    IF pr_dscritic <> 'OK' THEN
      RETURN;
    ELSE
      pr_dscritic := NULL;
    END IF;    
    
    -- Ler todas as datas
    vr_idx := vr_tab_per_datas.first;
    LOOP
      EXIT WHEN vr_idx IS NULL;
      
      -- Buscar os valores pagos nos ultimos 6 meses, lembrando que a data deve ser util
      FOR rw_craplcm IN cr_craplcm_parame(pr_cdbccxlt  => 756
                                         ,pr_dtmvtolt  => vr_tab_per_datas(vr_idx).dtmvtolt
                                         ,pr_cdcooper  => pr_cdcooper
                                         ,pr_cdremessa => 10
                                         ,pr_tpfluxo   => 'S') LOOP
         vr_vltotger := vr_vltotger + nvl(rw_craplcm.vllanmto,0);
      END LOOP; -- Fim loop craplcm
      
      vr_contador := vr_contador + 1;
      
      vr_idx := vr_tab_per_datas.NEXT(vr_idx);
    END LOOP; --Fim loop periodo 
         
    
    -- calcular a média 
    IF vr_contador > 0 THEN
      vr_vlrmedia := (vr_vltotger / vr_contador);
    ELSE
      vr_vlrmedia := 0;
    END IF;
    
    pc_grava_movimentacao(pr_cdcooper => pr_cdcooper   -- Codigo da Cooperativa
                         ,pr_dtmvtolt => pr_dtmvtolt   -- Data de movimento
                         ,pr_tpdmovto => 4             -- Tipo de movimento
                         ,pr_cdbccxlt => 756           -- Codigo do banco/caixa.
                         ,pr_tpdcampo => 10            -- Tipo de campo
                         ,pr_vldcampo => vr_vlrmedia   -- Valor do campo
                         ,pr_dscritic => pr_dscritic);

    IF pr_dscritic <> 'OK' THEN
      RAISE vr_exc_erro;
    END IF;    

    pr_dscritic := 'OK';

  EXCEPTION
    WHEN vr_exc_erro THEN
        NULL;
    WHEN OTHERS THEN
      pr_dscritic := 'Erro na FLXF0001.pc_grava_prj_fatura_cart_credi: '||SQLerrm;
  END pc_grava_prj_fatura_cart_credi;  

  -- Procedure para gravar movimento financeiro das Guias de recolhimento da Previdencia Social
  PROCEDURE pc_grava_mvt_grps ( pr_cdcooper  IN INTEGER      -- Codigo da Cooperativa
                               ,pr_dtmvtolt  IN DATE         -- Data de movimento
                               ,pr_dscritic OUT VARCHAR2) AS -- Descrição da critica

    -- .........................................................................
    --
    --  Programa : pc_grava_mvt_grps          Antigo: b1wgen0131.p/pi_gps_f
    --
    --
    --  Sistema  : Cred
    --  Sigla    : FLXF0001
    --  Autor    : Odirlei Busana
    --  Data     : novembro/2013.                   Ultima atualizacao: 20/11/2013
    --
    --  Dados referentes ao programa:
    --
    --   Objetivo  : Gravar movimento financeiro das Guias de recolhimento da Previdencia Social
    --
    --   Atualizacao: 20/11/2013 - Conversao Progress => Oracle (Odirlei-AMcom)
    --..........................................................................

    vr_exc_erro EXCEPTION;

  BEGIN

    --Buscar Lancamentos das Guias de recolhimento da Previdencia Social
    FOR rw_craplgp IN cr_craplgp(pr_dtmvtolt => pr_dtmvtolt
                                ,pr_cdcooper => pr_cdcooper) LOOP
      -- Acionar a gravação                                  
      pc_grava_movimentacao(pr_cdcooper => pr_cdcooper   -- Codigo da Cooperativa
                           ,pr_dtmvtolt => pr_dtmvtolt   -- Data de movimento
                           ,pr_tpdmovto => 2             -- Tipo de movimento
                           ,pr_cdbccxlt => rw_craplgp.cdbccxlt -- Codigo do banco/caixa.
                           ,pr_tpdcampo => 7                   -- Tipo de campo (GPS/INSS)
                           ,pr_vldcampo => rw_craplgp.vlrtotal -- Valor do campo
                           ,pr_dscritic => pr_dscritic);

      IF pr_dscritic <> 'OK' THEN
        RAISE vr_exc_erro;
      END IF;
    END LOOP;

    pr_dscritic := 'OK';

  EXCEPTION
    WHEN vr_exc_erro THEN
        NULL;
    WHEN OTHERS THEN
      pr_dscritic := 'Erro na FLXF0001.pc_grava_mvt_grps: '||SQLerrm;
  END pc_grava_mvt_grps;

  -- Procedure para gravar projeção movimento financeiro das GPS
  PROCEDURE pc_grava_prj_grps (pr_cdcooper  IN INTEGER      -- Codigo da Cooperativa
                              ,pr_dtmvtolt  IN DATE         -- Data de movimento
                              ,pr_flghistor IN BOOLEAN DEFAULT FALSE -- Flag para utilização da base histórica 
                              ,pr_dscritic OUT VARCHAR2) AS -- Descrição da critica

    -- .........................................................................
    --
    --  Programa : pc_grava_prj_grps
    --
    --  Sistema  : Cred
    --  Sigla    : FLXF0001
    --  Autor    : Marcos Martini
    --  Data     : Outubro/2016.                   Ultima atualizacao: 11/11/2013
    --
    --  Dados referentes ao programa:
    --
    --   Objetivo  : Gravar projeção financeira das GPSs
    --
    --   Atualizacao: 
    --..........................................................................

    vr_exc_erro      EXCEPTION;
    vr_tab_per_datas typ_tab_per_datas;
    
    -- variavel para calcular o movimento
    vr_contador      NUMBER;
    vr_vlrmedia_748  NUMBER;
    vr_vlrmedia_756  NUMBER;
    vr_vltotger_748  NUMBER;
    vr_vltotger_756  NUMBER;
    vr_idx           VARCHAR2(15);

  BEGIN
    
    -- Gerar os periodo de projeção 1 ano considerando dia do mês e dia da semana
    pc_gera_period_dia_mes(pr_cdcooper => pr_cdcooper   -- Codigo da Cooperativa
                          ,pr_dtmvtolt => pr_dtmvtolt   -- Data de movimento
                          ,pr_qtdmeses => 12            -- Numero de meses a procurar
                          ,pr_fldiasem => TRUE          -- Considerar o dia da semana
                          ,pr_flprxant => FALSE         -- Considerar 1 dia para mais ou menos
                          ,pr_tab_per_datas => vr_tab_per_datas -- Tabela de datas
                          ,pr_dscritic  => pr_dscritic);
    IF pr_dscritic <> 'OK' THEN
      RETURN;
    ELSE
      pr_dscritic := NULL;
    END IF;
    
    -- Se não for encontado algum dia para projeção
    IF vr_tab_per_datas.count() = 0 THEN
      -- Gerar os periodo de projeção 1 ano considerando somente dia do mês
      pc_gera_period_dia_mes(pr_cdcooper => pr_cdcooper   -- Codigo da Cooperativa
                            ,pr_dtmvtolt => pr_dtmvtolt   -- Data de movimento
                            ,pr_qtdmeses => 12            -- Numero de meses a procurar
                            ,pr_fldiasem => FALSE          -- Considerar o dia da semana
                            ,pr_flprxant => FALSE         -- Considerar 1 dia para mais ou menos
                            ,pr_tab_per_datas => vr_tab_per_datas -- Tabela de datas
                            ,pr_dscritic  => pr_dscritic);

      IF pr_dscritic <> 'OK' THEN
        RETURN;
      ELSE
        pr_dscritic := NULL;
      END IF;  
    END IF;
    

    -- Reiniciar valores para busca das Transferências
    vr_contador := 0;
    vr_vlrmedia_756 := 0;
    vr_vlrmedia_748 := 0;
    vr_vltotger_756 := 0;
    vr_vltotger_748 := 0;

    -- Ler todas as datas
    vr_idx := vr_tab_per_datas.first;
    LOOP
      EXIT WHEN vr_idx IS NULL;

      -- CAso utilizar base histórica
      IF pr_flghistor THEN 
        -- Buscar dos valores realizados e armazenados no fluxo financeiro Bancoob
        FOR rw_crapffm IN cr_crapffm_histor(pr_cdcooper => pr_cdcooper
                                           ,pr_dtmvtolt => vr_tab_per_datas(vr_idx).dtmvtolt
                                           ,pr_cdbccxlt => 756
                                           ,pr_tpdmovto => 2 --> Saida
                                           ,pr_tpdcampo => 7 --> VLTTINSS
                                           ) LOOP 
          vr_vltotger_756 := vr_vltotger_756 + nvl(rw_crapffm.vllanmto,0);
        END LOOP;
        -- Buscar dos valores realizados e armazenados no fluxo financeiro Sicredi
        FOR rw_crapffm IN cr_crapffm_histor(pr_cdcooper => pr_cdcooper
                                           ,pr_dtmvtolt => vr_tab_per_datas(vr_idx).dtmvtolt
                                           ,pr_cdbccxlt => 748
                                           ,pr_tpdmovto => 2 --> Saida
                                           ,pr_tpdcampo => 7 --> VLTTINSS
                                           ) LOOP 
          vr_vltotger_748 := vr_vltotger_748 + nvl(rw_crapffm.vllanmto,0);
        END LOOP;
      ELSE 
        --Buscar Lancamentos das Guias de recolhimento da Previdencia Social
        FOR rw_craplgp IN cr_craplgp(pr_dtmvtolt => vr_tab_per_datas(vr_idx).dtmvtolt
                                    ,pr_cdcooper => pr_cdcooper) LOOP
          -- Somar valores cfme IF
          IF rw_craplgp.cdbccxlt = 756 THEN 
            vr_vltotger_756 := vr_vltotger_756 + NVL(rw_craplgp.vlrtotal,0);
          ELSE  
            vr_vltotger_748 := vr_vltotger_748 + NVL(rw_craplgp.vlrtotal,0);
          END IF;  
        END LOOP;
      END IF;  
      
      vr_contador := vr_contador + 1;
      
      vr_idx := vr_tab_per_datas.NEXT(vr_idx);
    END LOOP; --Fim loop periodo

    -- calcular media mês de ambas IFs
    IF vr_contador > 0 THEN
      vr_vlrmedia_748 := (vr_vltotger_748 / vr_contador);
      vr_vlrmedia_756 := (vr_vltotger_756 / vr_contador);
    ELSE
      vr_vlrmedia_748 := 0;
      vr_vlrmedia_756 := 0;
    END IF;
    
    -- Enviar GPS Bancoob
    pc_grava_movimentacao(pr_cdcooper => pr_cdcooper     -- Codigo da Cooperativa
                         ,pr_dtmvtolt => pr_dtmvtolt     -- Data de movimento
                         ,pr_tpdmovto => 4               -- Tipo de movimento
                         ,pr_cdbccxlt => 756             -- Codigo do banco/caixa.
                         ,pr_tpdcampo => 7               -- Tipo de campo
                         ,pr_vldcampo => vr_vlrmedia_756 -- Valor do campo
                         ,pr_dscritic => pr_dscritic);

    IF pr_dscritic <> 'OK' THEN
      RAISE vr_exc_erro;   
    END IF;    
    
    -- Enviar GPS Sicredi
    pc_grava_movimentacao(pr_cdcooper => pr_cdcooper     -- Codigo da Cooperativa
                         ,pr_dtmvtolt => pr_dtmvtolt     -- Data de movimento
                         ,pr_tpdmovto => 4               -- Tipo de movimento
                         ,pr_cdbccxlt => 748             -- Codigo do banco/caixa.
                         ,pr_tpdcampo => 7               -- Tipo de campo
                         ,pr_vldcampo => vr_vlrmedia_748 -- Valor do campo
                         ,pr_dscritic => pr_dscritic);

    IF pr_dscritic <> 'OK' THEN
      RAISE vr_exc_erro;   
    END IF;    

    pr_dscritic := 'OK';

  EXCEPTION
    WHEN vr_exc_erro THEN
        NULL;
    WHEN OTHERS THEN
      pr_dscritic := 'Erro na FLXF0001.pc_grava_prj_grps: '||SQLerrm;
  END pc_grava_prj_grps;    


  -- Procedure para gravar movimento financeiro das movimentções de INSS
  PROCEDURE pc_grava_mvt_inss ( pr_cdcooper  IN INTEGER      -- Codigo da Cooperativa
                               ,pr_dtmvtolt  IN DATE         -- Data de movimento
                               ,pr_dscritic OUT VARCHAR2) AS -- Descrição da critica

    -- .........................................................................
    --
    --  Programa : pc_grava_mvt_inss          Antigo: b1wgen0131.p/pi_inss_f
    --
    --
    --  Sistema  : Cred
    --  Sigla    : FLXF0001
    --  Autor    : Odirlei Busana
    --  Data     : novembro/2013.                   Ultima atualizacao: 20/11/2013
    --
    --  Dados referentes ao programa:
    --
    --   Objetivo  : Gravar movimento financeiro das movimentções de INSS
    --
    --   Atualizacao: 20/11/2013 - Conversao Progress => Oracle (Odirlei-AMcom)
    --..........................................................................

    vr_exc_erro      EXCEPTION;
    vr_vltitrec      NUMBER := 0;

  BEGIN
    
    --Buscar Lancamentos de creditos de beneficios do INSS Bancoob
    vr_vltitrec := 0;
    FOR rw_craplbi IN cr_craplbi(pr_dtmvtolt => pr_dtmvtolt,
                                 pr_cdcooper => pr_cdcooper) LOOP
      vr_vltitrec := vr_vltitrec + nvl(rw_craplbi.vlliqcre,0);

    END LOOP;

    pc_grava_movimentacao(pr_cdcooper => pr_cdcooper   -- Codigo da Cooperativa
                         ,pr_dtmvtolt => pr_dtmvtolt   -- Data de movimento
                         ,pr_tpdmovto => 1             -- Tipo de movimento
                         ,pr_cdbccxlt => 756           -- Codigo do banco/caixa.
                         ,pr_tpdcampo => 7             -- Tipo de campo
                         ,pr_vldcampo => vr_vltitrec   -- Valor do campo
                         ,pr_dscritic => pr_dscritic);

    IF pr_dscritic <> 'OK' THEN
      RAISE vr_exc_erro;
    END IF;
    
    --ler lancamentos de INSS Sicredi 
    vr_vltitrec := 0;
    FOR rw_craplcm IN cr_craplcm_parame(pr_cdbccxlt => 748
                                       ,pr_dtmvtolt => pr_dtmvtolt
                                       ,pr_cdcooper => pr_cdcooper
                                       ,pr_cdremessa => 7
                                       ,pr_tpfluxo => 'E') LOOP
       vr_vltitrec := vr_vltitrec + nvl(rw_craplcm.vllanmto,0);
    END LOOP; -- Fim loop craplcm
    

    pc_grava_movimentacao(pr_cdcooper => pr_cdcooper   -- Codigo da Cooperativa
                         ,pr_dtmvtolt => pr_dtmvtolt   -- Data de movimento
                         ,pr_tpdmovto => 1             -- Tipo de movimento
                         ,pr_cdbccxlt => 748           -- Codigo do banco/caixa.
                         ,pr_tpdcampo => 7             -- Tipo de campo
                         ,pr_vldcampo => vr_vltitrec   -- Valor do campo
                         ,pr_dscritic => pr_dscritic);

    IF pr_dscritic <> 'OK' THEN
      RAISE vr_exc_erro;
    END IF;    

    pr_dscritic := 'OK';

  EXCEPTION
    WHEN vr_exc_erro THEN
        NULL;
    WHEN OTHERS THEN
      pr_dscritic := 'Erro na FLXF0001.pc_grava_mvt_inss: '||SQLerrm;
  END pc_grava_mvt_inss;
  
  -- Procedure para gravar projeção financeiro das movimentções de INSS
  PROCEDURE pc_grava_prj_inss (pr_cdcooper  IN INTEGER      -- Codigo da Cooperativa
                              ,pr_dtmvtolt  IN DATE         -- Data de movimento
                              ,pr_flghistor IN BOOLEAN DEFAULT FALSE -- Flag para utilização da base histórica 
                              ,pr_dscritic OUT VARCHAR2) AS -- Descrição da critica

    -- .........................................................................
    --
    --  Programa : pc_grava_prj_inss          
    --
    --
    --  Sistema  : Cred
    --  Sigla    : FLXF0001
    --  Autor    : Marcos Martini
    --  Data     : Outubro/2016.                   Ultima atualizacao: 
    --
    --  Dados referentes ao programa:
    --
    --   Objetivo  : Gravar projeção financeira das movimentções de INSS
    --
    --   Atualizacao: 
    --..........................................................................

    vr_exc_erro      EXCEPTION;
    vr_vltotger      NUMBER := 0;

    vr_tab_per_datas typ_tab_per_datas;
    -- variavel para calcular o movimento
    vr_contador      NUMBER;
    vr_vlrmedia      NUMBER;
    vr_idx           VARCHAR2(15);


  BEGIN
    
    -- Gerar os periodo de projeção ultimos 6 meses (dia util)
    pc_gera_period_diautil (pr_cdcooper => pr_cdcooper   -- Codigo da Cooperativa
                           ,pr_dtmvtolt => pr_dtmvtolt   -- Data de movimento
                           ,pr_qtdmeses => 6             -- Ultimos 6 meses
                           ,pr_qtdocorr => 0             -- Limite de datas encontradas (0 não há)
                           ,pr_fldiasem => FALSE         -- Não Considerar o dia da semana
                           --out
                           ,pr_tab_per_datas => vr_tab_per_datas -- Tabela de datas
                           ,pr_dscritic      => pr_dscritic);

    IF pr_dscritic <> 'OK' THEN
      RETURN;
    ELSE
      pr_dscritic := NULL;
    END IF;
    
    -- Se não for encontado algum dia para projeção
    IF vr_tab_per_datas.count() = 0 THEN
      -- Gerar os periodo de projeção 6 meses considerando dia do mês apenas
      pc_gera_period_dia_mes(pr_cdcooper => pr_cdcooper   -- Codigo da Cooperativa
                            ,pr_dtmvtolt => pr_dtmvtolt   -- Data de movimento
                            ,pr_qtdmeses => 6             -- Numero de meses a procurar
                            ,pr_fldiasem => FALSE         -- Considerar o dia da semana
                            ,pr_flprxant => FALSE         -- Considerar 1 dia para mais ou menos
                            ,pr_tab_per_datas => vr_tab_per_datas -- Tabela de datas
                            ,pr_dscritic  => pr_dscritic);
      IF pr_dscritic <> 'OK' THEN
        RETURN;
      ELSE
        pr_dscritic := NULL;
      END IF;
    END IF; 

    -- Reiniciar valores para busca INSS
    vr_contador := 0;
    vr_vlrmedia := 0;
    vr_vltotger := 0;

    -- Ler todas as datas
    vr_idx := vr_tab_per_datas.first;
    LOOP
      EXIT WHEN vr_idx IS NULL;

      -- CAso utilizar base histórica
      IF pr_flghistor THEN 
        -- Buscar dos valores realizados e armazenados no fluxo financeiro Bancoob
        FOR rw_crapffm IN cr_crapffm_histor(pr_cdcooper => pr_cdcooper
                                           ,pr_dtmvtolt => vr_tab_per_datas(vr_idx).dtmvtolt
                                           ,pr_cdbccxlt => 756
                                           ,pr_tpdmovto => 1 --> Entrada
                                           ,pr_tpdcampo => 7 --> VLTTINSS
                                           ) LOOP 
          vr_vltotger := vr_vltotger + nvl(rw_crapffm.vllanmto,0);
        END LOOP;
      ELSE
        --Buscar Lancamentos de creditos de beneficios do INSS Bancoob
        FOR rw_craplbi IN cr_craplbi(pr_dtmvtolt => vr_tab_per_datas(vr_idx).dtmvtolt,
                                     pr_cdcooper => pr_cdcooper) LOOP
          vr_vltotger := vr_vltotger + nvl(rw_craplbi.vlliqcre,0);

        END LOOP;
      END IF;  
      
      vr_contador := vr_contador + 1;
      
      vr_idx := vr_tab_per_datas.NEXT(vr_idx);
    END LOOP; --Fim loop periodo

    -- calcular media mês
    IF vr_contador > 0 THEN
      vr_vlrmedia := (vr_vltotger / vr_contador);
    ELSE
      vr_vlrmedia := 0;
    END IF;

    -- Enviar INSS BAncoob
    pc_grava_movimentacao(pr_cdcooper => pr_cdcooper    -- Codigo da Cooperativa
                         ,pr_dtmvtolt => pr_dtmvtolt    -- Data de movimento
                         ,pr_tpdmovto => 3              -- Tipo de movimento
                         ,pr_cdbccxlt => 756            -- Codigo do banco/caixa.
                         ,pr_tpdcampo => 7              -- Tipo de campo
                         ,pr_vldcampo => vr_vlrmedia    -- Valor do campo
                         ,pr_dscritic => pr_dscritic);

    IF pr_dscritic <> 'OK' THEN
      RAISE vr_exc_erro;   
    END IF;
 
    -- Reiniciar valores para busca das INSS Cecred
    vr_contador := 0;
    vr_vlrmedia := 0;
    vr_vltotger := 0;

    -- Ler todas as datas
    vr_idx := vr_tab_per_datas.first;
    LOOP
      EXIT WHEN vr_idx IS NULL;

      -- CAso utilizar base histórica
      IF pr_flghistor THEN 
        -- Buscar dos valores realizados e armazenados no fluxo financeiro Sicredi
        FOR rw_crapffm IN cr_crapffm_histor(pr_cdcooper => pr_cdcooper
                                           ,pr_dtmvtolt => vr_tab_per_datas(vr_idx).dtmvtolt
                                           ,pr_cdbccxlt => 748
                                           ,pr_tpdmovto => 1 --> Entrada
                                           ,pr_tpdcampo => 7 --> VLTTINSS
                                           ) LOOP 
          vr_vltotger := vr_vltotger + nvl(rw_crapffm.vllanmto,0);
        END LOOP;
      ELSE
        --Buscar Lancamentos de creditos de beneficios do INSS Sicredi
        FOR rw_craplcm IN cr_craplcm_parame(pr_cdbccxlt => 748
                                           ,pr_dtmvtolt => vr_tab_per_datas(vr_idx).dtmvtolt
                                           ,pr_cdcooper => pr_cdcooper
                                           ,pr_cdremessa => 7
                                           ,pr_tpfluxo => 'E') LOOP
           vr_vltotger := vr_vltotger + nvl(rw_craplcm.vllanmto,0);
        END LOOP;
      END IF;  
      
      vr_contador := vr_contador + 1;
      
      vr_idx := vr_tab_per_datas.NEXT(vr_idx);
    END LOOP; --Fim loop periodo

    -- calcular media mês
    IF vr_contador > 0 THEN
      vr_vlrmedia := (vr_vltotger / vr_contador);
    ELSE
      vr_vlrmedia := 0;
    END IF;

    -- Enviar INSS SIcredi
    pc_grava_movimentacao(pr_cdcooper => pr_cdcooper    -- Codigo da Cooperativa
                         ,pr_dtmvtolt => pr_dtmvtolt    -- Data de movimento
                         ,pr_tpdmovto => 3              -- Tipo de movimento
                         ,pr_cdbccxlt => 748            -- Codigo do banco/caixa.
                         ,pr_tpdcampo => 7              -- Tipo de campo
                         ,pr_vldcampo => vr_vlrmedia    -- Valor do campo
                         ,pr_dscritic => pr_dscritic);

    IF pr_dscritic <> 'OK' THEN
      RAISE vr_exc_erro;   
    END IF;

    pr_dscritic := 'OK';

  EXCEPTION
    WHEN vr_exc_erro THEN
        NULL;
    WHEN OTHERS THEN
      pr_dscritic := 'Erro na FLXF0001.pc_grava_prj_inss: '||SQLerrm;
  END pc_grava_prj_inss;  
  
  -- Procedure para gravar movimento financeiro do Recolhimento Numerário
  PROCEDURE pc_grava_mvt_recol_numerario(pr_cdcooper  IN INTEGER      -- Codigo da Cooperativa
                                        ,pr_dtmvtolt  IN DATE         -- Data de movimento
                                        ,pr_dscritic OUT VARCHAR2) AS -- Descrição da critica

    -- .........................................................................
    --
    --  Programa : pc_grava_mvt_recol_numerario
    --
    --
    --  Sistema  : Cred
    --  Sigla    : FLXF0001
    --  Autor    : Marcos Martini
    --  Data     : Outubro/2016.                   Ultima atualizacao: 
    --
    --  Dados referentes ao programa:
    --
    --   Objetivo  : Gravar movimento financeiro Recolhimento Numerário
    --
    --   Atualizacao: 
    --..........................................................................

    vr_exc_erro      EXCEPTION;
    vr_vlnumera      NUMBER := 0;

  BEGIN
    
    --ler lancamentos 
    vr_vlnumera := 0;
    FOR rw_craplcm IN cr_craplcm_numera(pr_cdbccxlt  => 85
                                       ,pr_dtmvtolt  => pr_dtmvtolt
                                       ,pr_cdcooper  => pr_cdcooper
                                       ,pr_tpfluxo   => 'E') LOOP
       vr_vlnumera := vr_vlnumera + nvl(rw_craplcm.vllanmto,0);
    END LOOP; -- Fim loop craplcm
    

    pc_grava_movimentacao(pr_cdcooper => pr_cdcooper   -- Codigo da Cooperativa
                         ,pr_dtmvtolt => pr_dtmvtolt   -- Data de movimento
                         ,pr_tpdmovto => 1             -- Tipo de movimento
                         ,pr_cdbccxlt => 85            -- Codigo do banco/caixa.
                         ,pr_tpdcampo => 13           -- Tipo de campo
                         ,pr_vldcampo => vr_vlnumera   -- Valor do campo
                         ,pr_dscritic => pr_dscritic);

    IF pr_dscritic <> 'OK' THEN
      RAISE vr_exc_erro;
    END IF;    

    pr_dscritic := 'OK';

  EXCEPTION
    WHEN vr_exc_erro THEN
        NULL;
    WHEN OTHERS THEN
      pr_dscritic := 'Erro na FLXF0001.pc_grava_mvt_recol_numerario: '||SQLerrm;
  END pc_grava_mvt_recol_numerario;    
  
  -- Procedure para gravar movimento financeiro referente ao recolhimento de numerários
  PROCEDURE pc_grava_prj_recol_numerario(pr_cdcooper  IN INTEGER      -- Codigo da Cooperativa
                                        ,pr_dtmvtolt  IN DATE         -- Data de movimento
                                        ,pr_flghistor IN BOOLEAN DEFAULT FALSE -- Flag para utilização da base histórica 
                                        ,pr_dscritic OUT VARCHAR2) AS -- Descrição da critica

    -- .........................................................................
    --
    --  Programa : pc_grava_prj_recol_numerario
    --
    --  Sistema  : Cred
    --  Sigla    : FLXF0001
    --  Autor    : Marcos Martini
    --  Data     : novembro/2016.                   Ultima atualizacao: 
    --
    --  Dados referentes ao programa:
    --
    --   Objetivo  : Gravar projeção movimento financeiro referente ao recolhimento numerário
    --
    --   Atualizacao: 
    --..........................................................................

    vr_exc_erro      EXCEPTION;
    vr_nrdiautil     PLS_INTEGER;    
    
    -- Variaveis para calculo do movimento
    vr_tab_per_datas typ_tab_per_datas;        
    vr_idx           VARCHAR2(15);
    vr_contador      NUMBER;
    vr_vlrmedia      NUMBER;
    vr_vltotger      NUMBER;    

  BEGIN
      
    -- Buscar o numero do dia util
    vr_nrdiautil := fn_retorna_numero_dia_util(pr_cdcooper   -- codigo da cooperativa
                                              ,pr_dtmvtolt); -- Data do periodo
    -- Para o 5º dia util 
    IF vr_nrdiautil = 5 THEN 
      -- Encontrar os ultimos três meses em que o 5º dia util caiu neste mesmo dia da semana
      pc_gera_period_diautil(pr_cdcooper => pr_cdcooper           -- Codigo da Cooperativa
                            ,pr_dtmvtolt => pr_dtmvtolt           -- Data de movimento
                            ,pr_qtdmeses => 12                    -- Numero de meses a procurar
                            ,pr_qtdocorr => 3                     -- Limite de dadas encontradas (0 não há)
                            ,pr_fldiasem => TRUE                  -- Considerar o dia da semana passado
                            ,pr_tab_per_datas => vr_tab_per_datas -- Tabela de datas
                            ,pr_dscritic      => pr_dscritic);    -- Descrição da critica
    ELSE
      -- Para os demais, utilizar a media dos ultimos 12 meses 
      -- considerando o dia da semana e dia do mês
      pc_gera_period_dia_mes(pr_cdcooper => pr_cdcooper   -- Codigo da Cooperativa
                            ,pr_dtmvtolt => pr_dtmvtolt   -- Data de movimento
                            ,pr_qtdmeses => 12            -- Numero de meses a procurar
                            ,pr_fldiasem => TRUE          -- Considerar o dia da semana
                            ,pr_flprxant => FALSE          -- Considerar 1 dia a mais ou menos
                            ,pr_tab_per_datas => vr_tab_per_datas -- Tabela de datas
                            ,pr_dscritic  => pr_dscritic);
    END IF;
    IF pr_dscritic <> 'OK' THEN
      RETURN;
    ELSE
      pr_dscritic := NULL;
    END IF;
    -- Se chegarmos neste ponto e não encontramos nenhuma data a projetar
    IF vr_tab_per_datas.count() = 0 THEN 
      -- Então buscaremos os ultimos 12 meses considerando o dia da semana e 1 dia do mês para mais ou para menos
      pc_gera_period_dia_mes(pr_cdcooper => pr_cdcooper   -- Codigo da Cooperativa
                            ,pr_dtmvtolt => pr_dtmvtolt   -- Data de movimento
                            ,pr_qtdmeses => 12            -- Numero de meses a procurar
                            ,pr_fldiasem => TRUE          -- Considerar o dia da semana
                            ,pr_flprxant => TRUE          -- Considerar 1 dia a mais ou menos
                            ,pr_tab_per_datas => vr_tab_per_datas -- Tabela de datas
                            ,pr_dscritic  => pr_dscritic);
      IF pr_dscritic <> 'OK' THEN
        RETURN;
      ELSE
        pr_dscritic := NULL;
      END IF;
    END IF;  
    
    -- Zerar valores para busca
    vr_contador := 0; 
    vr_vlrmedia := 0; 
    vr_vltotger := 0; 

    -- Ler todas as datas
    vr_idx := vr_tab_per_datas.first;
    LOOP
      EXIT WHEN vr_idx IS NULL;
        -- CAso utilizar base histórica
        IF pr_flghistor THEN 
          -- Buscar dos valores realizados e armazenados no fluxo financeiro 
          FOR rw_crapffm IN cr_crapffm_histor(pr_cdcooper => pr_cdcooper
                                             ,pr_dtmvtolt => vr_tab_per_datas(vr_idx).dtmvtolt
                                             ,pr_cdbccxlt => 85
                                             ,pr_tpdmovto => 1 --> Entrada
                                             ,pr_tpdcampo => 13 --> VLNUMERA
                                             ) LOOP 
            vr_vltotger := vr_vltotger + nvl(rw_crapffm.vllanmto,0);
          END LOOP;
        ELSE 
          -- Buscar recolhimento numerário do dia
          FOR rw_craplcm IN cr_craplcm_numera(pr_cdbccxlt  => 85
                                             ,pr_dtmvtolt  => vr_tab_per_datas(vr_idx).dtmvtolt
                                             ,pr_cdcooper  => pr_cdcooper
                                             ,pr_tpfluxo   => 'E') LOOP
             vr_vltotger := vr_vltotger + nvl(rw_craplcm.vllanmto,0);
          END LOOP; -- Fim loop craplcm
        END IF;  

      vr_contador := vr_contador + 1;
      
      vr_idx := vr_tab_per_datas.NEXT(vr_idx);
    END LOOP; --Fim loop periodo

    -- calcular media mês
    IF vr_contador > 0 THEN
      vr_vlrmedia := (vr_vltotger / vr_contador);
    ELSE
      vr_vlrmedia := 0;
    END IF;

    -- Ler os bancos e gravar os movimentos
    pc_grava_movimentacao(pr_cdcooper => pr_cdcooper   -- Codigo da Cooperativa
                         ,pr_dtmvtolt => pr_dtmvtolt   -- Data de movimento
                         ,pr_tpdmovto => 3             -- Tipo de movimento
                         ,pr_cdbccxlt => 85            -- Codigo do banco/caixa.
                         ,pr_tpdcampo => 13            -- Tipo de campo
                         ,pr_vldcampo => vr_vlrmedia   -- Valor do campo
                         ,pr_dscritic => pr_dscritic);

    IF pr_dscritic <> 'OK' THEN
      RAISE vr_exc_erro;
    END IF;

    pr_dscritic := 'OK';

  EXCEPTION
    WHEN vr_exc_erro THEN
        NULL;
    WHEN OTHERS THEN
      pr_dscritic := 'Erro na FLXF0001.pc_grava_prj_recol_numerario: '||SQLerrm;
  END pc_grava_prj_recol_numerario;    
  
  -- Procedure para gravar movimento financeiro do Suprimento Numerário
  PROCEDURE pc_grava_mvt_suprim_numerario(pr_cdcooper  IN INTEGER      -- Codigo da Cooperativa
                                         ,pr_dtmvtolt  IN DATE         -- Data de movimento
                                         ,pr_dscritic OUT VARCHAR2) AS -- Descrição da critica

    -- .........................................................................
    --
    --  Programa : pc_grava_mvt_suprim_numerario
    --
    --
    --  Sistema  : Cred
    --  Sigla    : FLXF0001
    --  Autor    : Marcos Martini
    --  Data     : Outubro/2016.                   Ultima atualizacao: 
    --
    --  Dados referentes ao programa:
    --
    --   Objetivo  : Gravar movimento financeiro SUprimento Numerário
    --
    --   Atualizacao: 
    --..........................................................................

    vr_exc_erro      EXCEPTION;
    vr_vlnumera      NUMBER := 0;

  BEGIN
    
    --ler lancamentos 
    vr_vlnumera := 0;
    FOR rw_craplcm IN cr_craplcm_numera(pr_cdbccxlt  => 85
                                       ,pr_dtmvtolt  => pr_dtmvtolt
                                       ,pr_cdcooper  => pr_cdcooper
                                       ,pr_tpfluxo   => 'S') LOOP
       vr_vlnumera := vr_vlnumera + nvl(rw_craplcm.vllanmto,0);
    END LOOP; -- Fim loop craplcm
    

    pc_grava_movimentacao(pr_cdcooper => pr_cdcooper   -- Codigo da Cooperativa
                         ,pr_dtmvtolt => pr_dtmvtolt   -- Data de movimento
                         ,pr_tpdmovto => 2             -- Tipo de movimento
                         ,pr_cdbccxlt => 85            -- Codigo do banco/caixa.
                         ,pr_tpdcampo => 13           -- Tipo de campo
                         ,pr_vldcampo => vr_vlnumera   -- Valor do campo
                         ,pr_dscritic => pr_dscritic);

    IF pr_dscritic <> 'OK' THEN
      RAISE vr_exc_erro;
    END IF;    

    pr_dscritic := 'OK';

  EXCEPTION
    WHEN vr_exc_erro THEN
        NULL;
    WHEN OTHERS THEN
      pr_dscritic := 'Erro na FLXF0001.pc_grava_mvt_suprim_numerario: '||SQLerrm;
  END pc_grava_mvt_suprim_numerario;  
  
  -- Procedure para gravar movimento financeiro referente ao suprimento de numerários
  PROCEDURE pc_grava_prj_suprim_numerario(pr_cdcooper  IN INTEGER      -- Codigo da Cooperativa
                                         ,pr_dtmvtolt  IN DATE         -- Data de movimento
                                         ,pr_flghistor IN BOOLEAN DEFAULT FALSE -- Flag para utilização da base histórica 
                                         ,pr_dscritic OUT VARCHAR2) AS -- Descrição da critica

    -- .........................................................................
    --
    --  Programa : pc_grava_prj_suprim_numerario
    --
    --  Sistema  : Cred
    --  Sigla    : FLXF0001
    --  Autor    : Marcos Martini
    --  Data     : novembro/2016.                   Ultima atualizacao: 
    --
    --  Dados referentes ao programa:
    --
    --   Objetivo  : Gravar projeção movimento financeiro referente ao suprimento numerário
    --
    --   Atualizacao: 
    --..........................................................................

    vr_exc_erro      EXCEPTION;
    vr_nrdiautil     PLS_INTEGER;    
    
    -- Variaveis para calculo do movimento
    vr_tab_per_datas typ_tab_per_datas;        
    vr_idx           VARCHAR2(15);
    vr_contador      NUMBER;
    vr_vlrmedia      NUMBER;
    vr_vltotger      NUMBER;    

  BEGIN
      
    -- Buscar o numero do dia util
    vr_nrdiautil := fn_retorna_numero_dia_util(pr_cdcooper   -- codigo da cooperativa
                                              ,pr_dtmvtolt); -- Data do periodo
    -- Para o 5º dia util 
    IF vr_nrdiautil = 5 THEN 
      -- Encontrar os ultimos três meses em que o 5º dia util caiu neste mesmo dia da semana
      pc_gera_period_diautil(pr_cdcooper => pr_cdcooper           -- Codigo da Cooperativa
                            ,pr_dtmvtolt => pr_dtmvtolt           -- Data de movimento
                            ,pr_qtdmeses => 12                    -- Numero de meses a procurar
                            ,pr_qtdocorr => 3                     -- Limite de dadas encontradas (0 não há)
                            ,pr_fldiasem => TRUE                  -- Considerar o dia da semana passado
                            ,pr_tab_per_datas => vr_tab_per_datas -- Tabela de datas
                            ,pr_dscritic      => pr_dscritic);    -- Descrição da critica
    ELSE
      -- Para os demais, utilizar a media dos ultimos 12 meses 
      -- considerando o dia da semana e dia do mês
      pc_gera_period_dia_mes(pr_cdcooper => pr_cdcooper   -- Codigo da Cooperativa
                            ,pr_dtmvtolt => pr_dtmvtolt   -- Data de movimento
                            ,pr_qtdmeses => 12            -- Numero de meses a procurar
                            ,pr_fldiasem => TRUE          -- Considerar o dia da semana
                            ,pr_flprxant => FALSE          -- Considerar 1 dia a mais ou menos
                            ,pr_tab_per_datas => vr_tab_per_datas -- Tabela de datas
                            ,pr_dscritic  => pr_dscritic);
    END IF;
    IF pr_dscritic <> 'OK' THEN
      RETURN;
    ELSE
      pr_dscritic := NULL;
    END IF;
    -- Se chegarmos neste ponto e não encontramos nenhuma data a projetar
    IF vr_tab_per_datas.count() = 0 THEN 
      -- Então buscaremos os ultimos 12 meses considerando o dia da semana e 1 dia do mês para mais ou para menos
      pc_gera_period_dia_mes(pr_cdcooper => pr_cdcooper   -- Codigo da Cooperativa
                            ,pr_dtmvtolt => pr_dtmvtolt   -- Data de movimento
                            ,pr_qtdmeses => 12            -- Numero de meses a procurar
                            ,pr_fldiasem => TRUE          -- Considerar o dia da semana
                            ,pr_flprxant => TRUE          -- Considerar 1 dia a mais ou menos
                            ,pr_tab_per_datas => vr_tab_per_datas -- Tabela de datas
                            ,pr_dscritic  => pr_dscritic);
      IF pr_dscritic <> 'OK' THEN
        RETURN;
      ELSE
        pr_dscritic := NULL;
      END IF;
    END IF;  
    
    -- Zerar valores para busca
    vr_contador := 0; 
    vr_vlrmedia := 0; 
    vr_vltotger := 0; 

    -- Ler todas as datas
    vr_idx := vr_tab_per_datas.first;
    LOOP
      EXIT WHEN vr_idx IS NULL;
        -- CAso utilizar base histórica
        IF pr_flghistor THEN 
          -- Buscar dos valores realizados e armazenados no fluxo financeiro 
          FOR rw_crapffm IN cr_crapffm_histor(pr_cdcooper => pr_cdcooper
                                             ,pr_dtmvtolt => vr_tab_per_datas(vr_idx).dtmvtolt
                                             ,pr_cdbccxlt => 85
                                             ,pr_tpdmovto => 2 --> Saida
                                             ,pr_tpdcampo => 13 --> VLNUMERA
                                             ) LOOP 
            vr_vltotger := vr_vltotger + nvl(rw_crapffm.vllanmto,0);
          END LOOP;
        ELSE 
          -- Buscar recolhimento numerário do dia
          FOR rw_craplcm IN cr_craplcm_numera(pr_cdbccxlt  => 85
                                             ,pr_dtmvtolt  => vr_tab_per_datas(vr_idx).dtmvtolt
                                             ,pr_cdcooper  => pr_cdcooper
                                             ,pr_tpfluxo   => 'S') LOOP
             vr_vltotger := vr_vltotger + nvl(rw_craplcm.vllanmto,0);
          END LOOP; -- Fim loop craplcm
        END IF;  
      vr_contador := vr_contador + 1;
      vr_idx := vr_tab_per_datas.NEXT(vr_idx);
    END LOOP; --Fim loop periodo

    -- calcular media mês
    IF vr_contador > 0 THEN
      vr_vlrmedia := (vr_vltotger / vr_contador);
    ELSE
      vr_vlrmedia := 0;
    END IF;

    -- Ler os bancos e gravar os movimentos
    pc_grava_movimentacao(pr_cdcooper => pr_cdcooper   -- Codigo da Cooperativa
                         ,pr_dtmvtolt => pr_dtmvtolt   -- Data de movimento
                         ,pr_tpdmovto => 4             -- Tipo de movimento
                         ,pr_cdbccxlt => 85            -- Codigo do banco/caixa.
                         ,pr_tpdcampo => 13            -- Tipo de campo
                         ,pr_vldcampo => vr_vlrmedia   -- Valor do campo
                         ,pr_dscritic => pr_dscritic);

    IF pr_dscritic <> 'OK' THEN
      RAISE vr_exc_erro;
    END IF;

    pr_dscritic := 'OK';

  EXCEPTION
    WHEN vr_exc_erro THEN
        NULL;
    WHEN OTHERS THEN
      pr_dscritic := 'Erro na FLXF0001.pc_grava_prj_suprim_numerario: '||SQLerrm;
  END pc_grava_prj_suprim_numerario;     


  -- Procedure para gravar movimento financeiro da devolucao de cheques ou taxa de devolucao.
  PROCEDURE pc_grava_mvt_dev_cheque_rem (pr_cdcooper  IN INTEGER      -- Codigo da Cooperativa
                                        ,pr_dtmvtolt  IN DATE         -- Data de movimento
                                        ,pr_nmdatela  IN VARCHAR2     -- Nome da tela
                                        ,pr_dtmvtoan  IN DATE         -- Data movimento anterior
                                        ,pr_dscritic OUT VARCHAR2) AS -- Descrição da critica
    -- .........................................................................
    --
    --  Programa : pc_grava_mvt_dev_cheque_rem          Antigo: b1wgen0131.p/pi_dev_cheques_rem_f
    --
    --
    --  Sistema  : Cred
    --  Sigla    : FLXF0001
    --  Autor    : Odirlei Busana
    --  Data     : novembro/2013.                   Ultima atualizacao: 20/11/2013
    --
    --  Dados referentes ao programa:
    --
    --   Objetivo  : Gravar movimento financeiro da devolucao de cheques ou taxa de devolucao.
    --
    --   Atualizacao: 20/11/2013 - Conversao Progress => Oracle (Odirlei-AMcom)
    --..........................................................................

    vr_exc_erro      EXCEPTION;
    vr_dstextab      CRAPTAB.Dstextab%type;
    vr_valorvlb      NUMBER := 0;
    vr_vlrttdev      NUMBER := 0;

    --Buscar Compensacao de Cheques Devolvidos da Central
    CURSOR cr_gncpdev (pr_dtmvtolt DATE,
                       pr_cdcooper NUMBER) IS
      SELECT vlcheque
        FROM gncpdev
       WHERE cdcooper  = pr_cdcooper
         AND dtmvtolt  = pr_dtmvtolt
         AND cdbanchq  = 85
         AND cdtipreg in (1,2);

    --Buscar Arquivo intermediario para a devolucao de cheques ou taxa de devolucao.
    CURSOR cr_crapdev (pr_cdbcoctl NUMBER,
                       pr_cdcooper NUMBER) IS
      SELECT vllanmto,
             indevarq,
             nrdconta,
             TRIM(cdpesqui) cdpesqui,
             nrcheque,
             cdcooper
        FROM crapdev
       WHERE crapdev.cdcooper = pr_cdcooper
         AND crapdev.cdbanchq = pr_cdbcoctl
         AND crapdev.insitdev = 1
         AND crapdev.cdhistor <> 46 /* TX.DEV.CHQ. */
         AND nvl(crapdev.cdalinea,0) > 0
       ORDER BY crapdev.nrctachq,
                crapdev.nrcheque;

    --Buscar contas transferidas entre cooperativas
    CURSOR cr_craptco (pr_cdcooper NUMBER,
                       pr_nrdconta NUMBER) IS
      SELECT cdcopant,
             nrctaant
        FROM craptco
       WHERE craptco.cdcopant = pr_cdcooper
         AND craptco.nrctaant = pr_nrdconta
         AND craptco.tpctatrf = 1 /* 1 = C/C */
         AND craptco.flgativo = 1; --TRUE
    rw_craptco cr_craptco%ROWTYPE;

    --Buscar ultimo registro na Compensacao de Cheques da Central
    CURSOR cr_gncpchq (pr_cdcooper NUMBER,
                       pr_dtmvtoan DATE,
                       pr_vllanmto NUMBER,
                       pr_cdbcoctl crapcop.cdbcoctl%type,
                       pr_cdagectl crapcop.cdagectl%type,
                       pr_nrdconta crapdev.nrdconta%type,
                       pr_nrcheque crapdev.nrcheque%type) IS
      SELECT 1
        FROM gncpchq g
       WHERE g.progress_recid =
             (SELECT max(g1.progress_recid)
                FROM gncpchq g1
               WHERE g1.cdcooper = pr_cdcooper
                 AND g1.dtmvtolt = pr_dtmvtoan
                 AND g1.cdbanchq = pr_cdbcoctl
                 AND g1.cdagechq = pr_cdagectl
                 AND g1.nrctachq = pr_nrdconta
                 AND g1.nrcheque = pr_nrcheque
                 AND g1.cdtipreg in ( 3, 4)
                 AND g1.vlcheque = pr_vllanmto);
    rw_gncpchq cr_gncpchq%ROWTYPE;

    /* Busca dos dados da cooperativa */
    CURSOR cr_crapcop(pr_cdcooper IN craptab.cdcooper%TYPE) IS
      SELECT cdbcoctl,
             cdagectl
        FROM crapcop cop
       WHERE cop.cdcooper = pr_cdcooper;
    rw_crapcop cr_crapcop%ROWTYPE;

  BEGIN

    vr_vlrttdev := 0;

    /* No processo executa após limpeza da crapdev usar este para o mesmo */
    IF nvl(pr_nmdatela,' ') <> 'FLUXOS' THEN
      --Buscar Compensacao de Cheques Devolvidos da Central
      FOR rw_gncpdev IN cr_gncpdev(pr_dtmvtolt => pr_dtmvtoan,
                                   pr_cdcooper => pr_cdcooper) LOOP

        vr_vlrttdev := vr_vlrttdev + nvl(rw_gncpdev.vlcheque,0);

      END LOOP;
    ELSE
      /* Cooperativa precisa saber o valor antes da criação do gncpdev
         Feito como no relatório 219 crps264 */

      -- Verifica se a cooperativa esta cadastrada
      OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
      FETCH cr_crapcop
       INTO rw_crapcop;
      -- Se nao encontrar
      IF cr_crapcop%NOTFOUND THEN
        -- Fechar o cursor pois havera raise
        CLOSE cr_crapcop;
        -- Montar mensagem de critica
        pr_dscritic := 'Cooperativa '||pr_cdcooper||' não localizada.';
        Return;
      ELSE
        -- Apenas fechar o cursor
        CLOSE cr_crapcop;
      END IF;

      -- Buscar informacoes CRAPTAB
      vr_dstextab := tabe0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                               ,pr_nmsistem => 'CRED'
                                               ,pr_tptabela => 'GENERI'
                                               ,pr_cdempres => 0
                                               ,pr_cdacesso => 'VALORESVLB'
                                               ,pr_tpregist => 0);
      IF vr_dstextab IS NOT NULL THEN
        vr_valorvlb := to_number(gene0002.fn_busca_entrada(2,vr_dstextab,';'));
      ELSE
        pr_dscritic := 'NOK';
        Return;
      END IF;

      --Ler Arquivo intermediario para a devolucao de cheques ou taxa de devolucao.
      FOR rw_crapdev IN cr_crapdev(pr_cdbcoctl => rw_crapcop.cdbcoctl,
                                   pr_cdcooper => pr_cdcooper) LOOP

        -- Se não foi informada a conta
        IF rw_crapdev.nrdconta = 0 THEN
          -- calcular valor de devolução
          CASE rw_crapdev.indevarq
            WHEN 1 THEN  -- devolução enviada pelo arquivo
              vr_vlrttdev := vr_vlrttdev + nvl(rw_crapdev.vllanmto,0);
            WHEN 2 THEN
              IF nvl(rw_crapdev.vllanmto,0) < vr_valorvlb THEN
                vr_vlrttdev := vr_vlrttdev + nvl(rw_crapdev.vllanmto,0);
              END IF;
          END CASE;
        ELSE
          IF rw_crapdev.cdpesqui is null THEN
            --Buscar ultimo registro na Compensacao de Cheques da Central
            OPEN cr_gncpchq (pr_cdcooper => pr_cdcooper,
                             pr_dtmvtoan => pr_dtmvtoan,
                             pr_vllanmto => rw_crapdev.vllanmto,
                             pr_cdbcoctl => rw_crapcop.cdbcoctl,
                             pr_cdagectl => rw_crapcop.cdagectl,
                             pr_nrdconta => rw_crapdev.nrdconta,
                             pr_nrcheque => rw_crapdev.nrcheque );
            FETCH cr_gncpchq
              INTO rw_gncpchq;
            IF cr_gncpchq%NOTFOUND THEN
              close cr_gncpchq;
              CONTINUE;
            END IF;
            close cr_gncpchq;
          ELSE
            IF rw_crapdev.cdpesqui = 'TCO' THEN /* Contas transferidas */
              /* Tabela de contas transferidas entre cooperativas */
              OPEN cr_craptco (pr_cdcooper => rw_crapdev.cdcooper,
                               pr_nrdconta => rw_crapdev.nrdconta);
              FETCH cr_craptco
                INTO rw_craptco;
              IF cr_craptco%NOTFOUND THEN
                close cr_craptco;
                continue;
              ELSE
                close cr_craptco;
                --Buscar ultimo registro na Compensacao de Cheques da Central
                OPEN cr_gncpchq (pr_cdcooper => rw_craptco.cdcopant,
                                 pr_dtmvtoan => pr_dtmvtoan,
                                 pr_vllanmto => rw_crapdev.vllanmto,
                                 pr_cdbcoctl => rw_crapcop.cdbcoctl,
                                 pr_cdagectl => rw_crapcop.cdagectl,
                                 pr_nrdconta => rw_craptco.nrctaant,
                                 pr_nrcheque => rw_crapdev.nrcheque);
                FETCH cr_gncpchq
                  INTO rw_gncpchq;
                IF cr_gncpchq%NOTFOUND THEN
                  close cr_gncpchq;
                  CONTINUE;
                END IF;
                close cr_gncpchq;
              END IF;

            END IF; -- Fim rw_crapdev.cdpesqui = 'TCO'
          END IF; -- Fim  rw_crapdev.cdpesqui is null
        END IF; -- Fim rw_crapdev.nrdconta = 0

        IF rw_crapdev.cdpesqui is not null AND
           rw_crapdev.cdpesqui <> 'TCO'    THEN
          continue;
        ELSE
          -- calcular valor de devolução
          CASE rw_crapdev.indevarq
            WHEN 1 THEN
              vr_vlrttdev := vr_vlrttdev + nvl(rw_crapdev.vllanmto,0);
            WHEN 2 THEN
              IF rw_crapdev.vllanmto < vr_valorvlb THEN
                vr_vlrttdev := vr_vlrttdev + nvl(rw_crapdev.vllanmto,0);
              END IF;
          END CASE;
        END IF;
      END LOOP; -- Fim loop cr_gncpdev

    END IF; -- Fim pr_nmdatela <> 'PREVIS'

    pc_grava_movimentacao(pr_cdcooper => pr_cdcooper   -- Codigo da Cooperativa
                         ,pr_dtmvtolt => pr_dtmvtolt   -- Data de movimento
                         ,pr_tpdmovto => 1             -- Tipo de movimento
                         ,pr_cdbccxlt => 85            -- Codigo do banco/caixa.
                         ,pr_tpdcampo => 5   /**VLDEVOLU*/   -- Tipo de campo
                         ,pr_vldcampo => vr_vlrttdev         -- Valor do campo
                         ,pr_dscritic => pr_dscritic);

    IF pr_dscritic <> 'OK' THEN
      RAISE vr_exc_erro;
    END IF;

    pr_dscritic := 'OK';

  EXCEPTION
    WHEN vr_exc_erro THEN
        NULL;
    WHEN OTHERS THEN
      pr_dscritic := 'Erro na FLXF0001.pc_grava_mvt_dev_cheque_rem: '||SQLerrm;
  END pc_grava_mvt_dev_cheque_rem;
  
  -- Procedure para gravar movimento financeiro das devoluções de cheques de outros bancos
  PROCEDURE pc_grava_prj_dev_cheque_rem (pr_cdcooper  IN INTEGER      -- Codigo da Cooperativa
                                        ,pr_nmdatela  IN VARCHAR2     -- Nome da tela
                                        ,pr_dtmvtolt  IN DATE         -- Data de movimento
                                        ,pr_dtmvtoan  IN DATE         -- Data de movimento anterior
                                        ,pr_flghistor IN BOOLEAN DEFAULT FALSE -- Flag para utilização da base histórica 
                                        ,pr_dscritic OUT VARCHAR2) AS -- Descrição da critica

    -- .........................................................................
    --
    --  Programa : pc_grava_prj_dev_cheque_rem
    --
    --
    --  Sistema  : Cred
    --  Sigla    : FLXF0001
    --  Autor    : Marcos Martini
    --  Data     : Outubro/2016.                   Ultima atualizacao: 
    --
    --  Dados referentes ao programa:
    --
    --   Objetivo  : Gravar projeção movimento financeiro das devoluções de cheques do Banco 85
    --
    --   Atualizacao: 
    --..........................................................................

    vr_exc_erro      EXCEPTION;
    vr_vldevchq      NUMBER;
    
  BEGIN

    vr_vldevchq := 0;
    
    -- Se houver base de calculo
    IF fn_parfluxofinan(5) > 0 THEN
      -- Quando a execução for do Processo Noturno 
      IF pr_nmdatela = 'CRPS624' AND NOT pr_flghistor THEN 
        --Buscar Lancamentos de Cheques do Banco 85
        FOR rw_crapchd IN cr_crapchd(pr_dtmvtoan
                                    ,pr_cdcooper
                                    ,1) LOOP
          vr_vldevchq := vr_vldevchq + nvl(rw_crapchd.vlcheque,0);
        END LOOP;
      ELSE   
        -- Buscar da projeção efetuada para SR Cheques no dia anterior 
        FOR rw_crapffm IN cr_crapffm_histor(pr_cdcooper => pr_cdcooper
                                           ,pr_dtmvtolt => pr_dtmvtoan
                                           ,pr_cdbccxlt => 85
                                           ,pr_tpdmovto => 2 --> Saida Realizado
                                           ,pr_tpdcampo => 1 --> VLCHEQUE
                                           ) LOOP 
          vr_vldevchq := vr_vldevchq + nvl(rw_crapffm.vllanmto,0);
        END LOOP;
      END IF;
      -- acrescentar percentual
      vr_vldevchq := (vr_vldevchq * fn_parfluxofinan(5));
    ELSE
      -- Gerar log de erro
      pr_dscritic := 'Base de calculo devolucao de cheques nao informada.';
      RETURN;
    END IF;

    pc_grava_movimentacao(pr_cdcooper => pr_cdcooper   -- Codigo da Cooperativa
                         ,pr_dtmvtolt => pr_dtmvtolt   -- Data de movimento
                         ,pr_tpdmovto => 3             -- Tipo de movimento
                         ,pr_cdbccxlt => 85            -- Codigo do banco/caixa.
                         ,pr_tpdcampo => 5 /**VLDEVOLU*/ -- Tipo de campo
                         ,pr_vldcampo => vr_vldevchq     -- Valor do campo
                         ,pr_dscritic => pr_dscritic);

    IF pr_dscritic <> 'OK' THEN
      RETURN;
    END IF;


    pr_dscritic := 'OK';

  EXCEPTION
    WHEN OTHERS THEN
      pr_dscritic := 'Erro na FLXF0001.pc_grava_prj_dev_cheque_rem: '||SQLerrm;
  END pc_grava_prj_dev_cheque_rem;    

  -- Procedure para gravar movimento financeiro dos Credito transferencia/tec salario intercooperativo
  PROCEDURE pc_grava_mvt_transf_ic (pr_cdcooper  IN INTEGER      -- Codigo da Cooperativa
                                   ,pr_dtmvtolt  IN DATE         -- Data de movimento
                                   ,pr_tpdmovto  IN INTEGER      -- Tipo de movimento (1-Entrada 2-saida)
                                   ,pr_dscritic OUT VARCHAR2) AS -- Descrição da critica

    -- .........................................................................
    --
    --  Programa : pc_grava_mvt_transf_ic          Antigo: b1wgen0131.p/1 - pi_rec_transf_dep_intercoop_f
    --                                                                       2 - pi_rem_transf_dep_intercoop_f
    --
    --  Sistema  : Cred
    --  Sigla    : FLXF0001
    --  Autor    : Odirlei Busana
    --  Data     : novembro/2013.                   Ultima atualizacao: 11/11/2013
    --
    --  Dados referentes ao programa:
    --
    --   Objetivo  : Gravar movimento financeiro dos Credito transferencia/tec salario intercooperativo
    --
    --   Atualizacao: 08/11/2013 - Conversao Progress => Oracle (Odirlei-AMcom)
    --..........................................................................

    vr_exc_erro EXCEPTION;
    vr_vlrtsfns NUMBER;              
    vr_tpdfluxo VARCHAR2(1);
    
  BEGIN

    vr_vlrtsfns := 0;
    IF pr_tpdmovto = 1 THEN
      vr_tpdfluxo := 'E';
    ELSE
      vr_tpdfluxo := 'S';
    END IF;

    -- buscar lançamentos
    FOR rw_craplcm IN cr_craplcm_parame(pr_cdbccxlt  => 85
                                       ,pr_dtmvtolt  => pr_dtmvtolt
                                       ,pr_cdcooper  => pr_cdcooper
                                       ,pr_cdremessa => 8
                                       ,pr_tpfluxo   => vr_tpdfluxo) LOOP
      -- Somar valores
      vr_vlrtsfns := NVL(vr_vlrtsfns,0) + NVL(rw_craplcm.vllanmto,0);
    END LOOP;

    pc_grava_movimentacao(pr_cdcooper => pr_cdcooper   -- Codigo da Cooperativa
                         ,pr_dtmvtolt => pr_dtmvtolt   -- Data de movimento
                         ,pr_tpdmovto => pr_tpdmovto   -- Tipo de movimento
                         ,pr_cdbccxlt => 85            -- Codigo do banco/caixa.
                         ,pr_tpdcampo => 8 /*VLTRFITC*/-- Tipo de campo
                         ,pr_vldcampo => vr_vlrtsfns   -- Valor do campo
                         ,pr_dscritic => pr_dscritic);

    IF pr_dscritic <> 'OK' THEN
      RAISE vr_exc_erro;
    END IF;

    pr_dscritic := 'OK';

  EXCEPTION
    WHEN vr_exc_erro THEN
        NULL;
    WHEN OTHERS THEN
      pr_dscritic := 'Erro na FLXF0001.pc_grava_mvt_transf_ic: '||SQLerrm;
  END pc_grava_mvt_transf_ic;
  
  -- Procedure para gravar projeção movimento financeiro dos Credito transferencia/tec salario intercooperativo
  PROCEDURE pc_grava_prj_transf_ic (pr_cdcooper  IN INTEGER      -- Codigo da Cooperativa
                                   ,pr_dtmvtolt  IN DATE         -- Data de movimento
                                   ,pr_tpdmovto  IN INTEGER      -- Tipo de movimento (1-Entrada 2-saida)
                                   ,pr_flghistor IN BOOLEAN DEFAULT FALSE -- Flag para utilização da base histórica 
                                   ,pr_dscritic OUT VARCHAR2) AS -- Descrição da critica

    -- .........................................................................
    --
    --  Programa : pc_grava_prj_transf_ic
    --
    --  Sistema  : Cred
    --  Sigla    : FLXF0001
    --  Autor    : Marcos Martini
    --  Data     : Outubro/2016.                   Ultima atualizacao: 11/11/2013
    --
    --  Dados referentes ao programa:
    --
    --   Objetivo  : Gravar projeção financeira dos Credito transferencia/tec salario intercooperativo
    --
    --   Atualizacao: 
    --..........................................................................

    vr_exc_erro      EXCEPTION;
    vr_tab_per_datas typ_tab_per_datas;
    -- variavel para calcular o movimento
    vr_contador      NUMBER;
    vr_vlrmedia      NUMBER;
    vr_vltotger      NUMBER;
    vr_idx           VARCHAR2(15);            
    vr_tpdfluxo VARCHAR2(1);

  BEGIN

    -- Gerar os periodo de projeção ultimos 6 meses (dia util)
    pc_gera_period_diautil (pr_cdcooper => pr_cdcooper   -- Codigo da Cooperativa
                           ,pr_dtmvtolt => pr_dtmvtolt   -- Data de movimento
                           ,pr_qtdmeses => 6             -- Ultimos 6 meses
                           ,pr_qtdocorr => 0             -- Limite de datas encontradas (0 não há)
                           ,pr_fldiasem => FALSE         -- Não Considerar o dia da semana
                           --out
                           ,pr_tab_per_datas => vr_tab_per_datas -- Tabela de datas
                           ,pr_dscritic      => pr_dscritic);

    IF pr_dscritic <> 'OK' THEN
      RETURN;
    ELSE
      pr_dscritic := NULL;
    END IF;
    
    -- Se não for encontado algum dia para projeção
    IF vr_tab_per_datas.count() = 0 THEN
      -- Gerar os periodo de projeção 6 meses considerando dia do mês apenas
      pc_gera_period_dia_mes(pr_cdcooper => pr_cdcooper   -- Codigo da Cooperativa
                            ,pr_dtmvtolt => pr_dtmvtolt   -- Data de movimento
                            ,pr_qtdmeses => 6             -- Numero de meses a procurar
                            ,pr_fldiasem => FALSE         -- Considerar o dia da semana
                            ,pr_flprxant => FALSE         -- Considerar 1 dia para mais ou menos
                            ,pr_tab_per_datas => vr_tab_per_datas -- Tabela de datas
                            ,pr_dscritic  => pr_dscritic);
      IF pr_dscritic <> 'OK' THEN
        RETURN;
      ELSE
        pr_dscritic := NULL;
      END IF;
    END IF;     

    -- Reiniciar valores para busca das Transferências
    vr_contador := 0;
    vr_vlrmedia := 0;
    vr_vltotger := 0;
    
    IF pr_tpdmovto = 1 THEN
      vr_tpdfluxo := 'E';
    ELSE
      vr_tpdfluxo := 'S';
    END IF;

    -- Ler todas as datas
    vr_idx := vr_tab_per_datas.first;
    LOOP
      EXIT WHEN vr_idx IS NULL;

      -- CAso utilizar base histórica
      IF pr_flghistor THEN 
        -- Buscar dos valores realizados e armazenados no fluxo financeiro 
        FOR rw_crapffm IN cr_crapffm_histor(pr_cdcooper => pr_cdcooper
                                           ,pr_dtmvtolt => vr_tab_per_datas(vr_idx).dtmvtolt
                                           ,pr_cdbccxlt => 85
                                           ,pr_tpdmovto => pr_tpdmovto
                                           ,pr_tpdcampo => 8 
                                           ) LOOP 
          vr_vltotger := vr_vltotger + nvl(rw_crapffm.vllanmto,0);
        END LOOP;
      ELSE 
        -- buscar lançamentos
        FOR rw_craplcm IN cr_craplcm_parame(pr_cdbccxlt  => 85
                                           ,pr_dtmvtolt  => vr_tab_per_datas(vr_idx).dtmvtolt
                                           ,pr_cdcooper  => pr_cdcooper
                                           ,pr_cdremessa => 8
                                           ,pr_tpfluxo   => vr_tpdfluxo) LOOP
          -- Somar valores
          vr_vltotger := vr_vltotger + NVL(rw_craplcm.vllanmto,0);
        END LOOP;
      END IF;  
      
      vr_contador := vr_contador + 1;
      
      vr_idx := vr_tab_per_datas.NEXT(vr_idx);
    END LOOP; --Fim loop periodo

    -- calcular media mês
    IF vr_contador > 0 THEN
      vr_vlrmedia := (vr_vltotger / vr_contador);
    ELSE
      vr_vlrmedia := 0;
    END IF;

    -- Enviar Transferências
    pc_grava_movimentacao(pr_cdcooper => pr_cdcooper    -- Codigo da Cooperativa
                         ,pr_dtmvtolt => pr_dtmvtolt    -- Data de movimento
                         ,pr_tpdmovto => pr_tpdmovto+2  -- Tipo de movimento
                         ,pr_cdbccxlt => 85             -- Codigo do banco/caixa.
                         ,pr_tpdcampo => 8 /*VLTRFITC*/ -- Tipo de campo
                         ,pr_vldcampo => vr_vlrmedia    -- Valor do campo
                         ,pr_dscritic => pr_dscritic);

    IF pr_dscritic <> 'OK' THEN
      RAISE vr_exc_erro;   
    END IF;    

    pr_dscritic := 'OK';

  EXCEPTION
    WHEN vr_exc_erro THEN
        NULL;
    WHEN OTHERS THEN
      pr_dscritic := 'Erro na FLXF0001.pc_grava_prj_transf_ic: '||SQLerrm;
  END pc_grava_prj_transf_ic;  
  
  -- Procedure para gravar movimento financeiro dos Credito deposito/transferencia/tec salario intercooperativo
  PROCEDURE pc_grava_mvt_dep_ic(pr_cdcooper  IN INTEGER      -- Codigo da Cooperativa
                               ,pr_dtmvtolt  IN DATE         -- Data de movimento
                               ,pr_tpdmovto  IN INTEGER      -- Tipo de movimento (1-Entrada 2-saida)
                               ,pr_dscritic OUT VARCHAR2) AS -- Descrição da critica

    -- .........................................................................
    --
    --  Programa : pc_grava_mvt_dep_ic          Antigo: b1wgen0131.p/1 - pi_rec_transf_dep_intercoop_f
    --                                                                2 - pi_rem_transf_dep_intercoop_f
    --
    --  Sistema  : Cred
    --  Sigla    : FLXF0001
    --  Autor    : Odirlei Busana
    --  Data     : novembro/2013.                   Ultima atualizacao: 11/11/2013
    --
    --  Dados referentes ao programa:
    --
    --   Objetivo  : Gravar movimento financeiro dos Credito deposito intercooperativo
    --
    --   Atualizacao: 08/11/2013 - Conversao Progress => Oracle (Odirlei-AMcom)
    --..........................................................................

    vr_exc_erro      EXCEPTION;
    vr_vlrtsfns      NUMBER;

  BEGIN

    vr_vlrtsfns := 0;

    -- buscar lançamentos
    FOR rw_craplcm IN cr_craplcm_dep_ic(pr_cdbccxlt => 85
                                       ,pr_dtmvtolt => pr_dtmvtolt
                                       ,pr_cdcooper => pr_cdcooper
                                       ,pr_tpdmovto => pr_tpdmovto) LOOP
      -- Somar valores
      vr_vlrtsfns := NVL(vr_vlrtsfns,0) + NVL(rw_craplcm.vllanmto,0);
    END LOOP;

    pc_grava_movimentacao(pr_cdcooper => pr_cdcooper   -- Codigo da Cooperativa
                         ,pr_dtmvtolt => pr_dtmvtolt   -- Data de movimento
                         ,pr_tpdmovto => pr_tpdmovto   -- Tipo de movimento
                         ,pr_cdbccxlt => 85            -- Codigo do banco/caixa.
                         ,pr_tpdcampo => 12 /*VLDEPITC*/-- Tipo de campo
                         ,pr_vldcampo => vr_vlrtsfns    -- Valor do campo
                         ,pr_dscritic => pr_dscritic);

    IF pr_dscritic <> 'OK' THEN
      RAISE vr_exc_erro;
    END IF;

    pr_dscritic := 'OK';

  EXCEPTION
    WHEN vr_exc_erro THEN
        NULL;
    WHEN OTHERS THEN
      pr_dscritic := 'Erro na FLXF0001.pc_grava_mvt_dep_ic: '||SQLerrm;
  END pc_grava_mvt_dep_ic;  
  
  -- Procedure para gravar projeção movimento financeiro dos Depositos intercooperativo
  PROCEDURE pc_grava_prj_dep_ic (pr_cdcooper  IN INTEGER      -- Codigo da Cooperativa
                                ,pr_dtmvtolt  IN DATE         -- Data de movimento
                                ,pr_tpdmovto  IN INTEGER      -- Tipo de movimento (1-Entrada 2-saida)
                                ,pr_flghistor IN BOOLEAN DEFAULT FALSE -- Flag para utilização da base histórica 
                                ,pr_dscritic OUT VARCHAR2) AS -- Descrição da critica

    -- .........................................................................
    --
    --  Programa : pc_grava_prj_dep_ic
    --
    --  Sistema  : Cred
    --  Sigla    : FLXF0001
    --  Autor    : Marcos Martini
    --  Data     : Outubro/2016.                   Ultima atualizacao: 11/11/2013
    --
    --  Dados referentes ao programa:
    --
    --   Objetivo  : Gravar projeção financeira dos Depositos intercooperativo
    --
    --   Atualizacao: 
    --..........................................................................

    vr_exc_erro      EXCEPTION;
    vr_tab_per_datas typ_tab_per_datas;
    -- variavel para calcular o movimento
    vr_contador      NUMBER;
    vr_vlrmedia      NUMBER;
    vr_vltotger      NUMBER;
    vr_idx           VARCHAR2(15);

  BEGIN

    -- Gerar os periodo de projeção 1 ano considerando dia do mês e dia da semana
    pc_gera_period_dia_mes(pr_cdcooper => pr_cdcooper   -- Codigo da Cooperativa
                          ,pr_dtmvtolt => pr_dtmvtolt   -- Data de movimento
                          ,pr_qtdmeses => 12            -- Numero de meses a procurar
                          ,pr_fldiasem => TRUE          -- Considerar o dia da semana
                          ,pr_flprxant => FALSE         -- Considerar 1 dia para mais ou menos
                          ,pr_tab_per_datas => vr_tab_per_datas -- Tabela de datas
                          ,pr_dscritic  => pr_dscritic);
    IF pr_dscritic <> 'OK' THEN
      RETURN;
    ELSE
      pr_dscritic := NULL;
    END IF;
    
    -- Se não for encontado algum dia para projeção
    IF vr_tab_per_datas.count() = 0 THEN
      -- Gerar os periodo de projeção ultimos 6 meses (dia util)
      pc_gera_period_diautil (pr_cdcooper => pr_cdcooper   -- Codigo da Cooperativa
                             ,pr_dtmvtolt => pr_dtmvtolt   -- Data de movimento
                             ,pr_qtdmeses => 12            -- Numero de meses a procurar
                             ,pr_qtdocorr => 0             -- Limite de datas encontradas (0 não há)
                             ,pr_fldiasem => FALSE         -- Não Considerar o dia da semana
                             --out
                             ,pr_tab_per_datas => vr_tab_per_datas -- Tabela de datas
                             ,pr_dscritic      => pr_dscritic);

      IF pr_dscritic <> 'OK' THEN
        RETURN;
      ELSE
        pr_dscritic := NULL;
      END IF;  
    END IF;
    

    -- Reiniciar valores para busca das Transferências
    vr_contador := 0;
    vr_vlrmedia := 0;
    vr_vltotger := 0;

    -- Ler todas as datas
    vr_idx := vr_tab_per_datas.first;
    LOOP
      EXIT WHEN vr_idx IS NULL;

      -- CAso utilizar base histórica
      IF pr_flghistor THEN 
        -- Buscar dos valores realizados e armazenados no fluxo financeiro 
        FOR rw_crapffm IN cr_crapffm_histor(pr_cdcooper => pr_cdcooper
                                           ,pr_dtmvtolt => vr_tab_per_datas(vr_idx).dtmvtolt
                                           ,pr_cdbccxlt => 85
                                           ,pr_tpdmovto => pr_tpdmovto
                                           ,pr_tpdcampo => 12 --> VLDEPITC
                                           ) LOOP 
          vr_vltotger := vr_vltotger + nvl(rw_crapffm.vllanmto,0);
        END LOOP;
      ELSE
        -- buscar lançamentos
        FOR rw_craplcm IN cr_craplcm_dep_ic(pr_cdbccxlt => 85
                                           ,pr_dtmvtolt => vr_tab_per_datas(vr_idx).dtmvtolt
                                           ,pr_cdcooper => pr_cdcooper
                                           ,pr_tpdmovto => pr_tpdmovto) LOOP
          -- Somar valores
          vr_vltotger := vr_vltotger + NVL(rw_craplcm.vllanmto,0);
        END LOOP;
      END IF;
        
      vr_contador := vr_contador + 1;
      
      vr_idx := vr_tab_per_datas.NEXT(vr_idx);
    END LOOP; --Fim loop periodo

    -- calcular media mês
    IF vr_contador > 0 THEN
      vr_vlrmedia := (vr_vltotger / vr_contador);
    ELSE
      vr_vlrmedia := 0;
    END IF;

    -- Enviar Transferências
    pc_grava_movimentacao(pr_cdcooper => pr_cdcooper    -- Codigo da Cooperativa
                         ,pr_dtmvtolt => pr_dtmvtolt    -- Data de movimento
                         ,pr_tpdmovto => pr_tpdmovto+2  -- Tipo de movimento
                         ,pr_cdbccxlt => 85             -- Codigo do banco/caixa.
                         ,pr_tpdcampo => 12             -- Tipo de campo
                         ,pr_vldcampo => vr_vlrmedia    -- Valor do campo
                         ,pr_dscritic => pr_dscritic);

    IF pr_dscritic <> 'OK' THEN
      RAISE vr_exc_erro;   
    END IF;    

    pr_dscritic := 'OK';

  EXCEPTION
    WHEN vr_exc_erro THEN
        NULL;
    WHEN OTHERS THEN
      pr_dscritic := 'Erro na FLXF0001.pc_grava_prj_dep_ic: '||SQLerrm;
  END pc_grava_prj_dep_ic;    

  -- Procedure para gravar movimento financeiro das devoluções de cheques de outros bancos
  PROCEDURE pc_grava_mvt_dev_cheque_rec (pr_cdcooper  IN INTEGER      -- Codigo da Cooperativa
                                        ,pr_dtmvtolt  IN DATE         -- Data de movimento
                                        ,pr_dscritic OUT VARCHAR2) AS -- Descrição da critica

    -- .........................................................................
    --
    --  Programa : pc_grava_mvt_dev_cheque_rec          
    --
    --
    --  Sistema  : Cred
    --  Sigla    : FLXF0001
    --  Autor    : Marcos Martini
    --  Data     : Novembro/2016.                   Ultima atualizacao: 
    --
    --  Dados referentes ao programa:
    --
    --   Objetivo  : Gravar movimento financeiro das devoluções de cheques de outros bancos
    --
    --   Atualizacao: 
    --..........................................................................

    vr_exc_erro      EXCEPTION;
    vr_vldevchq      NUMBER;
    
  BEGIN

    vr_vldevchq := 0;
    
    --Buscar Lancamentos em depositos a vista com devolução de cheques recebidos
    FOR rw_lcm IN cr_lcm_devchq_recebi(pr_cdbccxlt => 85
                                      ,pr_dtmvtolt => pr_dtmvtolt
                                      ,pr_cdcooper => pr_cdcooper) LOOP
      vr_vldevchq := vr_vldevchq + nvl(rw_lcm.vllanmto,0);
    END LOOP;    

    pc_grava_movimentacao(pr_cdcooper => pr_cdcooper   -- Codigo da Cooperativa
                         ,pr_dtmvtolt => pr_dtmvtolt   -- Data de movimento
                         ,pr_tpdmovto => 2             -- Tipo de movimento
                         ,pr_cdbccxlt => 85            -- Codigo do banco/caixa.
                         ,pr_tpdcampo => 5 /**VLDEVOLU*/ -- Tipo de campo
                         ,pr_vldcampo => vr_vldevchq     -- Valor do campo
                         ,pr_dscritic => pr_dscritic);

    IF pr_dscritic <> 'OK' THEN
      RETURN;
    END IF;

    pr_dscritic := 'OK';

  EXCEPTION
    WHEN OTHERS THEN
      pr_dscritic := 'Erro na FLXF0001.pc_grava_mvt_dev_cheque_rec: '||SQLerrm;
  END pc_grava_mvt_dev_cheque_rec;  
  
  -- Procedure para gravar movimento financeiro das devoluções de cheques de outros bancos
  PROCEDURE pc_grava_prj_dev_cheque_rec (pr_cdcooper  IN INTEGER      -- Codigo da Cooperativa
                                        ,pr_nmdatela  IN VARCHAR2     -- Nome da tela
                                        ,pr_dtmvtolt  IN DATE         -- Data de movimento
                                        ,pr_dtmvtoan  IN DATE         -- Data de movimento anterior
                                        ,pr_flghistor IN BOOLEAN DEFAULT FALSE -- Flag para utilização da base histórica 
                                        ,pr_dscritic OUT VARCHAR2) AS -- Descrição da critica

    -- .........................................................................
    --
    --  Programa : pc_grava_prj_dev_cheque_rec          Antigo: b1wgen0131.p/pi_dev_cheques_rec_f
    --
    --
    --  Sistema  : Cred
    --  Sigla    : FLXF0001
    --  Autor    : Odirlei Busana
    --  Data     : novembro/2013.                   Ultima atualizacao: 20/11/2013
    --
    --  Dados referentes ao programa:
    --
    --   Objetivo  : Gravar movimento financeiro das devoluções de cheques de outros bancos
    --
    --   Atualizacao: 20/11/2013 - Conversao Progress => Oracle (Odirlei-AMcom)
    --..........................................................................

    vr_exc_erro      EXCEPTION;
    vr_vldevchq      NUMBER;
    
  BEGIN

    vr_vldevchq := 0;
    
    -- Se houver base de calculo
    IF fn_parfluxofinan(5) > 0 THEN
      -- Quando a execução for do Processo Noturno 
      IF pr_nmdatela = 'CRPS624' AND NOT pr_flghistor THEN 
        -- Buscar Lancamentos de Cheques acolhidos para depositos nas contas dos associados.
        FOR rw_crapchd IN cr_crapchd(pr_dtmvtoan
                                    ,pr_cdcooper
                                    ,0) LOOP
          vr_vldevchq := vr_vldevchq + nvl(rw_crapchd.vlcheque,0);
        END LOOP;
      ELSE   
        -- Buscar da projeção efetuada para NR Cheques no dia anterior 
        FOR rw_crapffm IN cr_crapffm_histor(pr_cdcooper => pr_cdcooper
                                           ,pr_dtmvtolt => pr_dtmvtoan
                                           ,pr_cdbccxlt => 85 
                                           ,pr_tpdmovto => 1 --> Entrada Realizado
                                           ,pr_tpdcampo => 1 --> VLCHEQUE
                                           ) LOOP 
          vr_vldevchq := vr_vldevchq + nvl(rw_crapffm.vllanmto,0);
        END LOOP;
      END IF;
      -- acrescentar percentual
      vr_vldevchq := (vr_vldevchq * fn_parfluxofinan(5));

    ELSE
      -- Gerar log de erro
      pr_dscritic := 'Base de calculo devolucao de cheques nao informada.';
      RETURN;
    END IF;

    pc_grava_movimentacao(pr_cdcooper => pr_cdcooper   -- Codigo da Cooperativa
                         ,pr_dtmvtolt => pr_dtmvtolt   -- Data de movimento
                         ,pr_tpdmovto => 4             -- Tipo de movimento
                         ,pr_cdbccxlt => 85            -- Codigo do banco/caixa.
                         ,pr_tpdcampo => 5 /**VLDEVOLU*/ -- Tipo de campo
                         ,pr_vldcampo => vr_vldevchq     -- Valor do campo
                         ,pr_dscritic => pr_dscritic);

    IF pr_dscritic <> 'OK' THEN
      RETURN;
    END IF;


    pr_dscritic := 'OK';

  EXCEPTION
    WHEN OTHERS THEN
      pr_dscritic := 'Erro na FLXF0001.pc_grava_prj_dev_cheque_rec: '||SQLerrm;
  END pc_grava_prj_dev_cheque_rec;  
  

  -- Procedure para gravar movimento financeiro referente aos TEDs recebidos
  PROCEDURE pc_grava_mvt_srted(pr_cdcooper  IN INTEGER      -- Codigo da Cooperativa
                              ,pr_dtmvtolt  IN DATE         -- Data de movimento
                              ,pr_dscritic OUT VARCHAR2) AS -- Descrição da critica

    -- .........................................................................
    --
    --  Programa : pc_grava_mvt_srted         Antigo: b1wgen0131.p/pi_sr_ted_f
    --
    --
    --  Sistema  : Cred
    --  Sigla    : FLXF0001
    --  Autor    : Odirlei Busana
    --  Data     : novembro/2013.                   Ultima atualizacao: 14/12/2016
    --
    --  Dados referentes ao programa:
    --
    --   Objetivo  : Gravar movimento financeiro referente aos TEDs recebidos
    --
    --   Atualizacao: 25/11/2013 - Conversao Progress => Oracle (Odirlei-AMcom)
    --
    --                28/09/2016 - Passar novos parämetros na chamada a sspb0001 (Jonata-RKAM)
    -- 
  	--				        07/11/2016 - Ajuste para contabilizar as TED - SICREDI (Adriano - M211)
    --
    --                14/12/2016 - Ajuste para gravar movimentação de TED - SICREDI corretamente (Adriano - SD 577067)    
    --..........................................................................

    vr_exc_erro      EXCEPTION;
    vr_vlrtedsr      NUMBER;


  BEGIN

    vr_vlrtedsr := 0;

    -- Buscar TEDs Cecred
    FOR rw_lmt IN cr_craplmt(pr_cdcooper,pr_dtmvtolt,0) LOOP 
      vr_vlrtedsr := vr_vlrtedsr + rw_lmt.vldocmto;
    END LOOP;

    -- Enviar TEDs Cecred
    pc_grava_movimentacao(pr_cdcooper => pr_cdcooper    -- Codigo da Cooperativa
                         ,pr_dtmvtolt => pr_dtmvtolt    -- Data de movimento
                         ,pr_tpdmovto => 1              -- Tipo de movimento
                         ,pr_cdbccxlt => 85             -- Codigo do banco/caixa.
                         ,pr_tpdcampo => 3 /*VLTOTTED*/ -- Tipo de campo
                         ,pr_vldcampo => vr_vlrtedsr    -- Valor do campo
                         ,pr_dscritic => pr_dscritic);

    IF pr_dscritic <> 'OK' THEN
      RAISE vr_exc_erro;
    END IF;
    
    -- Buscar TEDs Sicredi
    vr_vlrtedsr := 0;

    -- Buscar TEDs Sicred
    FOR rw_lmt IN cr_craplmt(pr_cdcooper,pr_dtmvtolt,1) LOOP 
      vr_vlrtedsr := vr_vlrtedsr + rw_lmt.vldocmto;
    END LOOP;

    -- Enviar TEDs Cecred
    pc_grava_movimentacao(pr_cdcooper => pr_cdcooper    -- Codigo da Cooperativa
                         ,pr_dtmvtolt => pr_dtmvtolt    -- Data de movimento
                         ,pr_tpdmovto => 1              -- Tipo de movimento
                         ,pr_cdbccxlt => 748             -- Codigo do banco/caixa.
                         ,pr_tpdcampo => 3 /*VLTOTTED*/ -- Tipo de campo
                         ,pr_vldcampo => vr_vlrtedsr    -- Valor do campo
                         ,pr_dscritic => pr_dscritic);

    IF pr_dscritic <> 'OK' THEN
      RAISE vr_exc_erro;
    END IF;

    pr_dscritic := 'OK';

  EXCEPTION
    WHEN vr_exc_erro THEN
        NULL;
    WHEN OTHERS THEN
      pr_dscritic := 'Erro na FLXF0001.pc_grava_mvt_srted: '||SQLerrm;
  END pc_grava_mvt_srted;
  
  -- Procedure para gravar projeção da SR TED
  PROCEDURE pc_grava_prj_srted (pr_cdcooper IN INTEGER      -- Codigo da Cooperativa
                               ,pr_dtmvtolt  IN DATE         -- Data de movimento
                               ,pr_flghistor IN BOOLEAN DEFAULT FALSE -- Flag para utilização da base histórica 
                               ,pr_dscritic OUT VARCHAR2) AS -- Descrição da critica

    -- .........................................................................
    --
    --  Programa : pc_grava_prj_srted          
    --
    --
    --  Sistema  : Cred
    --  Sigla    : FLXF0001
    --  Autor    : Marcos Martini
    --  Data     : Outubro/2016.                   Ultima atualizacao: 
    --
    --  Dados referentes ao programa:
    --
    --   Objetivo  : Gravar projeção movimento financeiro das TEDs
    --
    --   Atualizacao: 
    --..........................................................................

    vr_exc_erro      EXCEPTION;
    vr_tab_per_datas typ_tab_per_datas;
    -- variavel para calcular o movimento
    vr_contador      NUMBER;
    vr_vlrmedia      NUMBER;
    vr_vltotger      NUMBER;
    vr_idx           VARCHAR2(15);
    
  BEGIN
    
    -- Gerar os periodo de projeção ultimos 6 meses (dia util)
    pc_gera_period_diautil (pr_cdcooper => pr_cdcooper   -- Codigo da Cooperativa
                           ,pr_dtmvtolt => pr_dtmvtolt   -- Data de movimento
                           ,pr_qtdmeses => 6             -- Ultimos 6 meses
                           ,pr_qtdocorr => 0             -- Limite de datas encontradas (0 não há)
                           ,pr_fldiasem => FALSE         -- Não Considerar o dia da semana
                           --out
                           ,pr_tab_per_datas => vr_tab_per_datas -- Tabela de datas
                           ,pr_dscritic      => pr_dscritic);

    IF pr_dscritic <> 'OK' THEN
      RETURN;
    ELSE
      pr_dscritic := NULL;
    END IF;
    
    -- Se não for encontado algum dia para projeção
    IF vr_tab_per_datas.count() = 0 THEN
      -- Gerar os periodo de projeção 6 meses considerando dia do mês apenas
      pc_gera_period_dia_mes(pr_cdcooper => pr_cdcooper   -- Codigo da Cooperativa
                            ,pr_dtmvtolt => pr_dtmvtolt   -- Data de movimento
                            ,pr_qtdmeses => 6             -- Numero de meses a procurar
                            ,pr_fldiasem => FALSE         -- Considerar o dia da semana
                            ,pr_flprxant => FALSE         -- Considerar 1 dia para mais ou menos
                            ,pr_tab_per_datas => vr_tab_per_datas -- Tabela de datas
                            ,pr_dscritic  => pr_dscritic);
      IF pr_dscritic <> 'OK' THEN
        RETURN;
      ELSE
        pr_dscritic := NULL;
      END IF;
    END IF;     

    -- Reiniciar valores para busca das TEDs
    vr_contador := 0;
    vr_vlrmedia := 0;
    vr_vltotger := 0;

    -- Ler todas as datas
    vr_idx := vr_tab_per_datas.first;
    LOOP
      EXIT WHEN vr_idx IS NULL;

      -- CAso utilizar base histórica
      IF pr_flghistor THEN 
        -- Buscar dos valores realizados e armazenados no fluxo financeiro Cecred
        FOR rw_crapffm IN cr_crapffm_histor(pr_cdcooper => pr_cdcooper
                                           ,pr_dtmvtolt => vr_tab_per_datas(vr_idx).dtmvtolt
                                           ,pr_cdbccxlt => 85 
                                           ,pr_tpdmovto => 1 --> Entrada
                                           ,pr_tpdcampo => 3 --> VLTOTTED
                                           ) LOOP 
          vr_vltotger := vr_vltotger + nvl(rw_crapffm.vllanmto,0);
        END LOOP;
      ELSE 
        -- Buscar TEDs Cecred
        FOR rw_lmt IN cr_craplmt(pr_cdcooper,vr_tab_per_datas(vr_idx).dtmvtolt,0) LOOP 
          vr_vltotger := vr_vltotger + rw_lmt.vldocmto;
        END LOOP;
      END IF;  
      
      vr_contador := vr_contador + 1;
      
      vr_idx := vr_tab_per_datas.NEXT(vr_idx);
    END LOOP; --Fim loop periodo

    -- calcular media mês
    IF vr_contador > 0 THEN
      vr_vlrmedia := (vr_vltotger / vr_contador);
    ELSE
      vr_vlrmedia := 0;
    END IF;

    -- Enviar TEDs Cecred
    pc_grava_movimentacao(pr_cdcooper => pr_cdcooper    -- Codigo da Cooperativa
                         ,pr_dtmvtolt => pr_dtmvtolt    -- Data de movimento
                         ,pr_tpdmovto => 3              -- Tipo de movimento
                         ,pr_cdbccxlt => 85             -- Codigo do banco/caixa.
                         ,pr_tpdcampo => 3 /*VLTOTTED*/ -- Tipo de campo
                         ,pr_vldcampo => vr_vlrmedia    -- Valor do campo
                         ,pr_dscritic => pr_dscritic);

    IF pr_dscritic <> 'OK' THEN
      RAISE vr_exc_erro;   
    END IF;
    
    -- Reiniciar valores para busca das TEDs Sicredi
    vr_contador := 0;
    vr_vlrmedia := 0;
    vr_vltotger := 0;

    -- Ler todas as datas
    vr_idx := vr_tab_per_datas.first;
    LOOP
      EXIT WHEN vr_idx IS NULL;

      -- CAso utilizar base histórica
      IF pr_flghistor THEN 
        -- Buscar dos valores realizados e armazenados no fluxo financeiro Cecred
        FOR rw_crapffm IN cr_crapffm_histor(pr_cdcooper => pr_cdcooper
                                           ,pr_dtmvtolt => vr_tab_per_datas(vr_idx).dtmvtolt
                                           ,pr_cdbccxlt => 748 
                                           ,pr_tpdmovto => 1 --> Entrada
                                           ,pr_tpdcampo => 3 --> VLTOTTED
                                           ) LOOP 
          vr_vltotger := vr_vltotger + nvl(rw_crapffm.vllanmto,0);
        END LOOP;
      ELSE 
        -- Buscar TEDs Sicredi
        FOR rw_lmt IN cr_craplmt(pr_cdcooper,vr_tab_per_datas(vr_idx).dtmvtolt,1) LOOP 
          vr_vltotger := vr_vltotger + rw_lmt.vldocmto;
        END LOOP;
      END IF;  
      
      vr_contador := vr_contador + 1;
      
      vr_idx := vr_tab_per_datas.NEXT(vr_idx);
    END LOOP; --Fim loop periodo

    -- calcular media mês
    IF vr_contador > 0 THEN
      vr_vlrmedia := (vr_vltotger / vr_contador);
    ELSE
      vr_vlrmedia := 0;
    END IF;

    -- Enviar TEDs Sicredi
    pc_grava_movimentacao(pr_cdcooper => pr_cdcooper    -- Codigo da Cooperativa
                         ,pr_dtmvtolt => pr_dtmvtolt    -- Data de movimento
                         ,pr_tpdmovto => 3              -- Tipo de movimento
                         ,pr_cdbccxlt => 748             -- Codigo do banco/caixa.
                         ,pr_tpdcampo => 3 /*VLTOTTED*/ -- Tipo de campo
                         ,pr_vldcampo => vr_vlrmedia    -- Valor do campo
                         ,pr_dscritic => pr_dscritic);

    IF pr_dscritic <> 'OK' THEN
      RAISE vr_exc_erro;   
    END IF;

    pr_dscritic := 'OK';

  EXCEPTION
    WHEN OTHERS THEN
      pr_dscritic := 'Erro na FLXF0001.pc_grava_prj_srted: '||SQLerrm;

  END pc_grava_prj_srted;  

  -- Procedure para gravar movimento financeiro dos TEDs e TECs
  PROCEDURE pc_grava_mvt_nrtedtec (pr_cdcooper  IN INTEGER      -- Codigo da Cooperativa
                                  ,pr_dtmvtolt  IN DATE         -- Data de movimento
                                  ,pr_dscritic OUT VARCHAR2) AS -- Descrição da critica

    -- .........................................................................
    --
    --  Programa : pc_grava_mvt_nrtedtec          Antigo: b1wgen0131.p/pi_tedtec_nr_f
    --
    --
    --  Sistema  : Cred
    --  Sigla    : FLXF0001
    --  Autor    : Odirlei Busana
    --  Data     : novembro/2013.                   Ultima atualizacao: 14/12/2016
    --
    --  Dados referentes ao programa:
    --
    --   Objetivo  : Gravar movimento financeiro dos TEDs e TECs
    --
    --   Atualizacao: 21/11/2013 - Conversao Progress => Oracle (Odirlei-AMcom)
    -- 
  	--				        07/11/2016 - Ajuste para contabilizar as TED - SICREDI (Adriano - M211)
    --
    --                14/12/2016 - Ajuste para gravar movimentação de TED - SICREDI corretamente (Adriano - SD 577067)    
    --..........................................................................

    vr_exc_erro      EXCEPTION;
    vr_vlrtednr      NUMBER;

  BEGIN

    vr_vlrtednr := 0;

    /* Verificar TED p/ estornos */
    FOR rw_craplcs IN cr_craplcs_tedtec(pr_cdbccxlt => 85
                                       ,pr_dtmvtolt => pr_dtmvtolt
                                       ,pr_cdcooper => pr_cdcooper) LOOP

      vr_vlrtednr := vr_vlrtednr + nvl(rw_craplcs.vllanmto,0);
    END LOOP;

    /* TED - Transferencias*/
    FOR rw_craptvl IN cr_craptvl(pr_dtmvtolt => pr_dtmvtolt,
                                 pr_cdcooper => pr_cdcooper) LOOP

      vr_vlrtednr := vr_vlrtednr + nvl(rw_craptvl.vldocrcb,0);

    END LOOP;

    /*** Desprezar TEC'S  e TED'S rejeitadas pela cabine da JD ***/
    FOR rw_craplcm IN cr_craplcm_parame(pr_cdbccxlt  => 85
                                       ,pr_dtmvtolt  => pr_dtmvtolt
                                       ,pr_cdcooper  => pr_cdcooper
                                       ,pr_cdremessa => 3
                                       ,pr_tpfluxo   => 'S') LOOP

      vr_vlrtednr := vr_vlrtednr - nvl(rw_craplcm.vllanmto,0);

    END LOOP;

    pc_grava_movimentacao(pr_cdcooper => pr_cdcooper   -- Codigo da Cooperativa
                         ,pr_dtmvtolt => pr_dtmvtolt   -- Data de movimento
                         ,pr_tpdmovto => 2             -- Tipo de movimento
                         ,pr_cdbccxlt => 85            -- Codigo do banco/caixa.
                         ,pr_tpdcampo => 3/*VLTOTTED*/ -- Tipo de campo
                         ,pr_vldcampo => vr_vlrtednr   -- Valor do campo
                         ,pr_dscritic => pr_dscritic);

    IF pr_dscritic <> 'OK' THEN
      RAISE vr_exc_erro;
    END IF;

    pr_dscritic := 'OK';

  EXCEPTION
    WHEN vr_exc_erro THEN
        NULL;
    WHEN OTHERS THEN
      pr_dscritic := 'Erro na FLXF0001.pc_grava_mvt_nrtedtec: '||SQLerrm;
	END pc_grava_mvt_nrtedtec;

  -- Procedure para gravar projeção movimento financeiro dos TEDs e TECs
  PROCEDURE pc_grava_prj_nrtedtec (pr_cdcooper  IN INTEGER      -- Codigo da Cooperativa
                                  ,pr_dtmvtolt  IN DATE         -- Data de movimento
                                  ,pr_flghistor IN BOOLEAN DEFAULT FALSE -- Flag para utilização da base histórica 
                                  ,pr_dscritic OUT VARCHAR2) AS -- Descrição da critica

    -- .........................................................................
    --
    --  Programa : pc_grava_mvt_nrtedtec          Antigo: b1wgen0131.p/pi_tedtec_nr_f
    --
    --
    --  Sistema  : Cred
    --  Sigla    : FLXF0001
    --  Autor    : Odirlei Busana
    --  Data     : novembro/2013.                   Ultima atualizacao: 21/11/2013
    --
    --  Dados referentes ao programa:
    --
    --   Objetivo  : Gravar movimento financeiro dos TEDs e TECs
    --
    --   Atualizacao: 21/11/2013 - Conversao Progress => Oracle (Odirlei-AMcom)
    --..........................................................................

    vr_exc_erro      EXCEPTION;
    vr_tab_per_datas typ_tab_per_datas;
    
    -- variavel para calcular o movimento
    vr_contador NUMBER := 0;
    vr_vlrmedia NUMBER;
    vr_vltotger NUMBER := 0;
    vr_idx      VARCHAR2(15);

  BEGIN

    -- Gerar periodo projeção considerando somente o dia util 
    pc_gera_period_diautil (pr_cdcooper => pr_cdcooper   -- Codigo da Cooperativa
                           ,pr_dtmvtolt => pr_dtmvtolt   -- Data de movimento
                           ,pr_qtdmeses => 6             -- Ultimos 12 meses
                           ,pr_qtdocorr => 0             -- Limite de datas encontradas (0 não há)
                           ,pr_fldiasem => FALSE         -- Não Considerar o dia da semana
                           --out
                           ,pr_tab_per_datas => vr_tab_per_datas -- Tabela de datas
                           ,pr_dscritic      => pr_dscritic);

    IF pr_dscritic <> 'OK' THEN
      RETURN;
    ELSE
      pr_dscritic := NULL;
    END IF;
    
    -- Se não for encontado algum dia para projeção
    IF vr_tab_per_datas.count() = 0 THEN
      -- Gerar os periodo de projeção 6  meses considerando dia do mês apenas
      pc_gera_period_dia_mes(pr_cdcooper => pr_cdcooper   -- Codigo da Cooperativa
                            ,pr_dtmvtolt => pr_dtmvtolt   -- Data de movimento
                            ,pr_qtdmeses => 6              -- Numero de meses a procurar
                            ,pr_fldiasem => FALSE         -- Considerar o dia da semana
                            ,pr_flprxant => FALSE         -- Considerar 1 dia para mais ou menos
                            ,pr_tab_per_datas => vr_tab_per_datas -- Tabela de datas
                            ,pr_dscritic  => pr_dscritic);
      IF pr_dscritic <> 'OK' THEN
        RETURN;
      ELSE
        pr_dscritic := NULL;
      END IF;
    END IF;     
    
    -- Ler todas as datas
    vr_idx := vr_tab_per_datas.first;
    LOOP
      EXIT WHEN vr_idx IS NULL;

      -- CAso utilizar base histórica
      IF pr_flghistor THEN 
        -- Buscar dos valores realizados e armazenados no fluxo financeiro 
        FOR rw_crapffm IN cr_crapffm_histor(pr_cdcooper => pr_cdcooper
                                           ,pr_dtmvtolt => vr_tab_per_datas(vr_idx).dtmvtolt
                                           ,pr_cdbccxlt => 85
                                           ,pr_tpdmovto => 2 --> Saida
                                           ,pr_tpdcampo => 3/*VLTOTTED*/
                                           ) LOOP 
          vr_vltotger := vr_vltotger + nvl(rw_crapffm.vllanmto,0);
        END LOOP;
      ELSE 
        
        /* Verificar TED p/ estornos */
        FOR rw_craplcs IN cr_craplcs_tedtec(pr_cdbccxlt => 85
                                           ,pr_dtmvtolt => vr_tab_per_datas(vr_idx).dtmvtolt
                                           ,pr_cdcooper => pr_cdcooper) LOOP

          vr_vltotger := vr_vltotger + nvl(rw_craplcs.vllanmto,0);
        END LOOP;

        /* TED - Transferencias*/
        FOR rw_craptvl IN cr_craptvl(pr_dtmvtolt => vr_tab_per_datas(vr_idx).dtmvtolt,
                                     pr_cdcooper => pr_cdcooper) LOOP

          vr_vltotger := vr_vltotger + nvl(rw_craptvl.vldocrcb,0);

        END LOOP;

        /*** Desprezar TEC'S  e TED'S rejeitadas pela cabine da JD ***/
        FOR rw_craplcm IN cr_craplcm_parame(pr_cdbccxlt  => 85
                                           ,pr_dtmvtolt  => vr_tab_per_datas(vr_idx).dtmvtolt
                                           ,pr_cdcooper  => pr_cdcooper
                                           ,pr_cdremessa => 3
                                           ,pr_tpfluxo   => 'S') LOOP
          vr_vltotger := vr_vltotger - nvl(rw_craplcm.vllanmto,0);
        END LOOP;  
      END IF;      
      
      vr_contador := vr_contador + 1;
      
      vr_idx := vr_tab_per_datas.NEXT(vr_idx);
    END LOOP; --Fim loop periodo

    -- calcular media mês de ambas IFs
    IF vr_contador > 0 THEN
      vr_vlrmedia := (vr_vltotger / vr_contador);
    ELSE
      vr_vlrmedia := 0;
    END IF;  

    pc_grava_movimentacao(pr_cdcooper => pr_cdcooper   -- Codigo da Cooperativa
                         ,pr_dtmvtolt => pr_dtmvtolt   -- Data de movimento
                         ,pr_tpdmovto => 4             -- Tipo de movimento
                         ,pr_cdbccxlt => 85            -- Codigo do banco/caixa.
                         ,pr_tpdcampo => 3/*VLTOTTED*/ -- Tipo de campo
                         ,pr_vldcampo => vr_vlrmedia   -- Valor do campo
                         ,pr_dscritic => pr_dscritic);

    IF pr_dscritic <> 'OK' THEN
      RAISE vr_exc_erro;
    END IF;

    pr_dscritic := 'OK';

  EXCEPTION
    WHEN vr_exc_erro THEN
        NULL;
    WHEN OTHERS THEN
      pr_dscritic := 'Erro na FLXF0001.pc_grava_prj_nrtedtec: '||SQLerrm;
	END pc_grava_prj_nrtedtec;

  -- Procedure para gravar movimento financeiro dos conveniados
  PROCEDURE pc_grava_mvt_convenios( pr_cdcooper  IN INTEGER      -- Codigo da Cooperativa
                                   ,pr_dtmvtolt  IN DATE         -- Data de movimento
                                   ,pr_dscritic OUT VARCHAR2) AS -- Descrição da critica

    -- .........................................................................
    --
    --  Programa : pc_grava_mvt_convenios          Antigo: b1wgen0131.p/pi_convenios_f
    --
    --
    --  Sistema  : Cred
    --  Sigla    : FLXF0001
    --  Autor    : Odirlei Busana
    --  Data     : novembro/2013.                   Ultima atualizacao: 25/01/2018
    --
    --  Dados referentes ao programa:
    --
    --   Objetivo  : Gravar movimento financeiro dos conveniados
    --
    --   Atualizacao: 22/11/2013 - Conversao Progress => Oracle (Odirlei-AMcom)
    --
    --                25/01/2018 - Ajustes devido a arrecadacao de convenios Bancoob
    --                             PRJ406-FGTS (Odirlei-AMcom)
    --..........................................................................

    vr_exc_erro      EXCEPTION;
    vr_vlrconve      NUMBER;


  BEGIN

    vr_vlrconve := 0;
    -- Lançamentos Faturas Cecred
    FOR rw_lft IN cr_craplft (pr_cdcooper => pr_cdcooper
                             ,pr_dtdpagto => pr_dtmvtolt
                             ,pr_tparrecd => 3) LOOP
      vr_vlrconve := vr_vlrconve + rw_lft.vldtotal;
    END LOOP;
    
    -- Ler convenios
    FOR rw_gnconve IN cr_gnconve(pr_cdcooper => pr_cdcooper) LOOP
      --ler lancamentos do convênio
      FOR rw_craplcm IN cr_craplcm_generi(pr_cdbccxlt => 85
                                         ,pr_dtmvtolt => pr_dtmvtolt
                                         ,pr_cdcooper => pr_cdcooper
                                         ,pr_cdhistor => rw_gnconve.cdhisdeb) LOOP

        vr_vlrconve := nvl(vr_vlrconve,0) + nvl(rw_craplcm.vllanmto,0);

      END LOOP; -- Fim loop craplcm
    END LOOP; -- Fim loop gncvcop

    -- Gravar convênios Cecred
    pc_grava_movimentacao(pr_cdcooper => pr_cdcooper    -- Codigo da Cooperativa
                         ,pr_dtmvtolt => pr_dtmvtolt    -- Data de movimento
                         ,pr_tpdmovto => 2              -- Tipo de movimento
                         ,pr_cdbccxlt => 85             -- Codigo do banco/caixa.
                         ,pr_tpdcampo => 11/*VLCONVEN*/ -- Tipo de campo
                         ,pr_vldcampo => vr_vlrconve    -- Valor do campo
                         ,pr_dscritic => pr_dscritic);

    IF pr_dscritic <> 'OK' THEN
      RAISE vr_exc_erro;
    END IF;
    
    -- Buscar convênios Sicredi
    vr_vlrconve := 0;

    -- Lançamentos Faturas Sicredi
    FOR rw_lft IN cr_craplft (pr_cdcooper => pr_cdcooper
                             ,pr_dtdpagto => pr_dtmvtolt
                             ,pr_tparrecd => 1) LOOP
      vr_vlrconve := vr_vlrconve + rw_lft.vldtotal;
    END LOOP;

    --ler lancamentos
    FOR rw_craplcm IN cr_craplcm_parame(pr_cdbccxlt  => 748
                                       ,pr_dtmvtolt  => pr_dtmvtolt
                                       ,pr_cdcooper  => pr_cdcooper
                                       ,pr_cdremessa => 11
                                       ,pr_tpfluxo   => 'S') LOOP
       vr_vlrconve := nvl(vr_vlrconve,0) + nvl(rw_craplcm.vllanmto,0);
    END LOOP; -- Fim loop craplcm

    -- Gravar convênios Cecred
    pc_grava_movimentacao(pr_cdcooper => pr_cdcooper    -- Codigo da Cooperativa
                         ,pr_dtmvtolt => pr_dtmvtolt    -- Data de movimento
                         ,pr_tpdmovto => 2              -- Tipo de movimento
                         ,pr_cdbccxlt => 748            -- Codigo do banco/caixa.
                         ,pr_tpdcampo => 11/*VLCONVEN*/ -- Tipo de campo
                         ,pr_vldcampo => vr_vlrconve    -- Valor do campo
                         ,pr_dscritic => pr_dscritic);

    IF pr_dscritic <> 'OK' THEN
      RAISE vr_exc_erro;
    END IF;
    
    -- Lançamentos Faturas BANCOOB
    vr_vlrconve := 0;
    FOR rw_lft IN cr_craplft (pr_cdcooper => pr_cdcooper
                             ,pr_dtdpagto => pr_dtmvtolt
                             ,pr_tparrecd => 2) LOOP --> Bancoob
      vr_vlrconve := vr_vlrconve + rw_lft.vldtotal;
    END LOOP;

    -- Gravar convênios BANCOOB
    pc_grava_movimentacao(pr_cdcooper => pr_cdcooper    -- Codigo da Cooperativa
                         ,pr_dtmvtolt => pr_dtmvtolt    -- Data de movimento
                         ,pr_tpdmovto => 2              -- Tipo de movimento
                         ,pr_cdbccxlt => 756            -- Codigo do banco/caixa.
                         ,pr_tpdcampo => 11/*VLCONVEN*/ -- Tipo de campo
                         ,pr_vldcampo => vr_vlrconve    -- Valor do campo
                         ,pr_dscritic => pr_dscritic);

    IF pr_dscritic <> 'OK' THEN
      RAISE vr_exc_erro;
    END IF;

    pr_dscritic := 'OK';

  EXCEPTION
    WHEN vr_exc_erro THEN
        NULL;
    WHEN OTHERS THEN
      pr_dscritic := 'Erro na FLXF0001.pc_grava_mvt_convenios: '||SQLerrm;
  END pc_grava_mvt_convenios;

  -- Procedure para gravar projeção movimento financeiro dos convenios
  PROCEDURE pc_grava_prj_convenios (pr_cdcooper  IN INTEGER      -- Codigo da Cooperativa
                                   ,pr_dtmvtolt  IN DATE         -- Data de movimento
                                   ,pr_flghistor IN BOOLEAN DEFAULT FALSE -- Flag para utilização da base histórica 
                                   ,pr_dscritic OUT VARCHAR2) AS -- Descrição da critica

    -- .........................................................................
    --
    --  Programa : pc_grava_prj_convenios          Antigo: Não há
    --
    --
    --  Sistema  : Cred
    --  Sigla    : FLXF0001
    --  Autor    : Marcos Martini
    --  Data     : Outubro/2016.                   Ultima atualizacao: 25/01/2018 
    --
    --  Dados referentes ao programa:
    --
    --   Objetivo  : Gravar projeção movimento financeiro dos convênios
    --
    --   Atualizacao: 25/01/2018 - Ajustes devido a arrecadacao de convenios Bancoob
    --                             PRJ406-FGTS (Odirlei-AMcom) 
    --..........................................................................

    vr_exc_erro      EXCEPTION;
    -- Variaveis para calculo do movimento
    vr_contador      NUMBER;
    vr_vlrmedia      NUMBER;
    vr_vltotger      NUMBER;
    vr_idx           VARCHAR2(15);
    vr_tab_per_datas typ_tab_per_datas;
    
  BEGIN
  
    -- gerar os periodo de projeção titulo
    pc_gera_periodo_projecao_tit (pr_cdcooper => pr_cdcooper   -- Codigo da Cooperativa
                                 ,pr_dtmvtolt => pr_dtmvtolt   -- Data de movimento
                                 ,pr_cdagrupa => 1             -- Código de agrupamento
                                 --out
                                 ,pr_tab_per_datas => vr_tab_per_datas -- Tabela de datas
                                 ,pr_dscritic      => pr_dscritic);

    IF pr_dscritic <> 'OK' THEN
      RETURN;
    ELSE
      pr_dscritic := NULL;
    END IF;

    -- Inicializar valores para busca dos convênios Cecred
    vr_contador := 0;
    vr_vlrmedia := 0;
    vr_vltotger := 0;
    
    vr_idx := vr_tab_per_datas.first;
    LOOP
      EXIT WHEN vr_idx IS NULL;
      
      -- CAso utilizar base histórica
      IF pr_flghistor THEN 
        -- Buscar dos valores realizados e armazenados no fluxo financeiro Cecred
        FOR rw_crapffm IN cr_crapffm_histor(pr_cdcooper => pr_cdcooper
                                           ,pr_dtmvtolt => vr_tab_per_datas(vr_idx).dtmvtolt
                                           ,pr_cdbccxlt => 85 
                                           ,pr_tpdmovto => 2 --> Saida
                                           ,pr_tpdcampo => 11 --> VLCONVEN
                                           ) LOOP 
          vr_vltotger := vr_vltotger + nvl(rw_crapffm.vllanmto,0);
        END LOOP;
      ELSE 
        -- Lançamentos Faturas Cecred 
        FOR rw_lft IN cr_craplft (pr_cdcooper => pr_cdcooper
                                 ,pr_dtdpagto => vr_tab_per_datas(vr_idx).dtmvtolt
                                 ,pr_tparrecd => 3) LOOP
          vr_vltotger := vr_vltotger + rw_lft.vldtotal;
        END LOOP;
        
        -- Ler convenios
        FOR rw_gnconve IN cr_gnconve(pr_cdcooper => pr_cdcooper) LOOP
          --ler lancamentos
          FOR rw_craplcm IN cr_craplcm_generi(pr_cdbccxlt => 85
                                             ,pr_dtmvtolt => vr_tab_per_datas(vr_idx).dtmvtolt
                                             ,pr_cdcooper => pr_cdcooper
                                             ,pr_cdhistor => rw_gnconve.cdhisdeb) LOOP

            vr_vltotger := nvl(vr_vltotger,0) + nvl(rw_craplcm.vllanmto,0);

          END LOOP; -- Fim loop craplcm
        END LOOP; -- Fim loop gncvcop
      END IF;  

      vr_contador := vr_contador + 1;

      vr_idx := vr_tab_per_datas.NEXT(vr_idx);
    END LOOP;
    
    -- Se encontramos alguma ocorrência
    IF vr_contador > 0 THEN 
      vr_vlrmedia := vr_vlrmedia + (vr_vltotger  / vr_contador);
    ELSE
      vr_vlrmedia := 0;
    END IF;  

    pc_grava_movimentacao(pr_cdcooper => pr_cdcooper     -- Codigo da Cooperativa
                         ,pr_dtmvtolt => pr_dtmvtolt     -- Data de movimento
                         ,pr_tpdmovto => 4               -- Tipo de movimento
                         ,pr_cdbccxlt => 85              -- Codigo do banco/caixa.
                         ,pr_tpdcampo => 11              -- Tipo de campo
                         ,pr_vldcampo => vr_vlrmedia     -- Valor do campo
                         ,pr_dscritic => pr_dscritic);

    IF pr_dscritic <> 'OK' THEN
      RETURN;
    END IF;
    
    -- Inicializar valores para busca dos convênios Sicredi
    vr_contador := 0;
    vr_vlrmedia := 0;
    vr_vltotger := 0;
    
    vr_idx := vr_tab_per_datas.first;
    LOOP
      EXIT WHEN vr_idx IS NULL;
      
      -- CAso utilizar base histórica
      IF pr_flghistor THEN 
        -- Buscar dos valores realizados e armazenados no fluxo financeiro Sicredi
        FOR rw_crapffm IN cr_crapffm_histor(pr_cdcooper => pr_cdcooper
                                           ,pr_dtmvtolt => vr_tab_per_datas(vr_idx).dtmvtolt
                                           ,pr_cdbccxlt => 748 
                                           ,pr_tpdmovto => 2 --> Saida
                                           ,pr_tpdcampo => 11 --> VLCONVEN
                                           ) LOOP 
          vr_vltotger := vr_vltotger + nvl(rw_crapffm.vllanmto,0);
        END LOOP;
      ELSE 
        -- Lançamentos Faturas Sicred 
        FOR rw_lft IN cr_craplft (pr_cdcooper => pr_cdcooper
                                 ,pr_dtdpagto => vr_tab_per_datas(vr_idx).dtmvtolt
                                 ,pr_tparrecd => 1) LOOP
          vr_vltotger := vr_vltotger + rw_lft.vldtotal;
        END LOOP;

        --ler lancamentos
        FOR rw_craplcm IN cr_craplcm_parame(pr_cdbccxlt  => 748
                                           ,pr_dtmvtolt  => pr_dtmvtolt
                                           ,pr_cdcooper  => pr_cdcooper
                                           ,pr_cdremessa => 11
                                           ,pr_tpfluxo   => 'S') LOOP

          vr_vltotger := nvl(vr_vltotger,0) + nvl(rw_craplcm.vllanmto,0);

        END LOOP; -- Fim loop craplcm
      END IF;  
      
      vr_contador := vr_contador + 1;

      vr_idx := vr_tab_per_datas.NEXT(vr_idx);
    END LOOP;
    
    -- Se encontramos alguma ocorrência
    IF vr_contador > 0 THEN 
      vr_vlrmedia := vr_vlrmedia + (vr_vltotger  / vr_contador);
    ELSE
      vr_vlrmedia := 0;
    END IF; 
    
    pc_grava_movimentacao(pr_cdcooper => pr_cdcooper     -- Codigo da Cooperativa
                         ,pr_dtmvtolt => pr_dtmvtolt     -- Data de movimento
                         ,pr_tpdmovto => 4               -- Tipo de movimento
                         ,pr_cdbccxlt => 748             -- Codigo do banco/caixa.
                         ,pr_tpdcampo => 11              -- Tipo de campo
                         ,pr_vldcampo => vr_vlrmedia     -- Valor do campo
                         ,pr_dscritic => pr_dscritic);

    IF pr_dscritic <> 'OK' THEN
      RETURN;
    END IF;
    --> Fim SICREDI
    
    -- Inicializar valores para busca dos convênios Bancoob
    vr_contador := 0;
    vr_vlrmedia := 0;
    vr_vltotger := 0;
    
    vr_idx := vr_tab_per_datas.first;
    LOOP
      EXIT WHEN vr_idx IS NULL;
      
      -- CAso utilizar base histórica
      IF pr_flghistor THEN 
        -- Buscar dos valores realizados e armazenados no fluxo financeiro BANCOOB
        FOR rw_crapffm IN cr_crapffm_histor(pr_cdcooper => pr_cdcooper
                                           ,pr_dtmvtolt => vr_tab_per_datas(vr_idx).dtmvtolt
                                           ,pr_cdbccxlt => 756 
                                           ,pr_tpdmovto => 2 --> Saida
                                           ,pr_tpdcampo => 11 --> VLCONVEN
                                           ) LOOP 
          vr_vltotger := vr_vltotger + nvl(rw_crapffm.vllanmto,0);
        END LOOP;
      ELSE 
        -- Lançamentos Faturas BANCOOB 
        FOR rw_lft IN cr_craplft (pr_cdcooper => pr_cdcooper
                                 ,pr_dtdpagto => vr_tab_per_datas(vr_idx).dtmvtolt
                                 ,pr_tparrecd => 2) LOOP --> BANCOOB
          vr_vltotger := vr_vltotger + rw_lft.vldtotal;
        END LOOP;
        
      END IF;  
      
      vr_contador := vr_contador + 1;

      vr_idx := vr_tab_per_datas.NEXT(vr_idx);
    END LOOP;
    
    -- Se encontramos alguma ocorrência
    IF vr_contador > 0 THEN 
      vr_vlrmedia := vr_vlrmedia + (vr_vltotger  / vr_contador);
    ELSE
      vr_vlrmedia := 0;
    END IF; 
    
    pc_grava_movimentacao(pr_cdcooper => pr_cdcooper     -- Codigo da Cooperativa
                         ,pr_dtmvtolt => pr_dtmvtolt     -- Data de movimento
                         ,pr_tpdmovto => 4               -- Tipo de movimento
                         ,pr_cdbccxlt => 756             -- Codigo do banco/caixa.
                         ,pr_tpdcampo => 11              -- Tipo de campo
                         ,pr_vldcampo => vr_vlrmedia     -- Valor do campo
                         ,pr_dscritic => pr_dscritic);

    IF pr_dscritic <> 'OK' THEN
      RETURN;
    END IF;
    --> Fim BANCOOB

    pr_dscritic := 'OK';

  EXCEPTION
    WHEN OTHERS THEN
      pr_dscritic := 'Erro na FLXF0001.pc_grava_prj_convenios: '||SQLerrm;

  END pc_grava_prj_convenios;  

  -- Procedure para gravar movimento financeiro referente aos saques no TAA das intercoop
  PROCEDURE pc_grava_mvt_saq_taa_ic(pr_cdcooper  IN INTEGER      -- Codigo da Cooperativa
                                   ,pr_dtmvtolt  IN DATE         -- Data de movimento
                                   ,pr_tpdmovto  IN INTEGER      -- Tipo de movimento (1-Entrada 2-saida)
                                   ,pr_dscritic OUT VARCHAR2) AS -- Descrição da critica

    -- .........................................................................
    --
    --  Programa : pc_grava_mvt_saq_taa_ic   Antigo: b1wgen0131.p/pi_rem_saq_taa_intercoop_f
    --                                                                   pi_rec_saq_taa_intercoop_f
    --
    --  Sistema  : Cred
    --  Sigla    : FLXF0001
    --  Autor    : Odirlei Busana
    --  Data     : novembro/2013.                   Ultima atualizacao: 22/11/2013
    --
    --  Dados referentes ao programa:
    --
    --   Objetivo  : Gravar movimento financeiro referente aos saques no TAA das intercoop
    --
    --   Atualizacao: 22/11/2013 - Conversao Progress => Oracle (Odirlei-AMcom)
    --..........................................................................

    vr_exc_erro      EXCEPTION;
    vr_vlsaqtaa      NUMBER;

  BEGIN

    vr_vlsaqtaa := 0;

    IF pr_tpdmovto = 1 THEN
      FOR rw_lcm IN cr_craplcm_cash(pr_cdbccxlt => 85
                                   ,pr_cdcoptfn => pr_cdcooper
                                   ,pr_dtmvtolt => pr_dtmvtolt) LOOP 
        vr_vlsaqtaa := vr_vlsaqtaa + rw_lcm.vllanmto;
      END LOOP;                             
    ELSE
      FOR rw_lcm IN cr_craplcm_cop(pr_cdbccxlt => 85
                                  ,pr_cdcooper => pr_cdcooper
                                  ,pr_dtmvtolt => pr_dtmvtolt) LOOP
        vr_vlsaqtaa := vr_vlsaqtaa + rw_lcm.vllanmto;                                  
      END LOOP;                            
    END IF;

    -- Ler os bancos e gravar os movimentos
    pc_grava_movimentacao(pr_cdcooper => pr_cdcooper   -- Codigo da Cooperativa
                         ,pr_dtmvtolt => pr_dtmvtolt   -- Data de movimento
                         ,pr_tpdmovto => pr_tpdmovto   -- Tipo de movimento
                         ,pr_cdbccxlt => 85            -- Codigo do banco/caixa.
                         ,pr_tpdcampo => 9 /*VLSATAIT*/-- Tipo de campo
                         ,pr_vldcampo => vr_vlsaqtaa   -- Valor do campo
                         ,pr_dscritic => pr_dscritic);

    IF pr_dscritic <> 'OK' THEN
      RAISE vr_exc_erro;
    END IF;

    pr_dscritic := 'OK';

  EXCEPTION
    WHEN vr_exc_erro THEN
        NULL;
    WHEN OTHERS THEN
      pr_dscritic := 'Erro na FLXF0001.pc_grava_mvt_saq_taa_ic: '||SQLerrm;
  END pc_grava_mvt_saq_taa_ic;
  
  -- Procedure para gravar movimento financeiro referente aos saques no TAA das intercoop
  PROCEDURE pc_grava_prj_saq_taa_ic(pr_cdcooper  IN INTEGER      -- Codigo da Cooperativa
                                   ,pr_dtmvtolt  IN DATE         -- Data de movimento
                                   ,pr_tpdmovto  IN INTEGER      -- Tipo de movimento (1-Entrada 2-saida)
                                   ,pr_flghistor IN BOOLEAN DEFAULT FALSE -- Flag para utilização da base histórica 
                                   ,pr_dscritic OUT VARCHAR2) AS -- Descrição da critica

    -- .........................................................................
    --
    --  Programa : pc_grava_prj_saq_taa_ic
    --
    --  Sistema  : Cred
    --  Sigla    : FLXF0001
    --  Autor    : Marcos Martini
    --  Data     : novembro/2016.                   Ultima atualizacao: 
    --
    --  Dados referentes ao programa:
    --
    --   Objetivo  : Gravar projeção movimento financeiro referente aos saques no TAA das intercoop
    --
    --   Atualizacao: 
    --..........................................................................

    vr_exc_erro      EXCEPTION;
    vr_nrdiautil     PLS_INTEGER;    
    
    -- Variaveis para calculo do movimento
    vr_tab_per_datas typ_tab_per_datas;        
    vr_idx           VARCHAR2(15);
    vr_contador      NUMBER;
    vr_vlrmedia      NUMBER;
    vr_vltotger      NUMBER;    

  BEGIN
      
    -- Buscar o numero do dia util
    vr_nrdiautil := fn_retorna_numero_dia_util(pr_cdcooper   -- codigo da cooperativa
                                              ,pr_dtmvtolt); -- Data do periodo
    -- Para o 5º dia util 
    IF vr_nrdiautil = 5 THEN 
      -- Encontrar os ultimos três meses em que o 5º dia util caiu neste mesmo dia da semana
      pc_gera_period_diautil(pr_cdcooper => pr_cdcooper           -- Codigo da Cooperativa
                            ,pr_dtmvtolt => pr_dtmvtolt           -- Data de movimento
                            ,pr_qtdmeses => 12                    -- Numero de meses a procurar
                            ,pr_qtdocorr => 3                     -- Limite de dadas encontradas (0 não há)
                            ,pr_fldiasem => TRUE                  -- Considerar o dia da semana passado
                            ,pr_tab_per_datas => vr_tab_per_datas -- Tabela de datas
                            ,pr_dscritic      => pr_dscritic);    -- Descrição da critica
    ELSE
      -- Para os demais, utilizar a media dos ultimos 12 meses 
      -- considerando o dia da semana e dia do mês
      pc_gera_period_dia_mes(pr_cdcooper => pr_cdcooper   -- Codigo da Cooperativa
                            ,pr_dtmvtolt => pr_dtmvtolt   -- Data de movimento
                            ,pr_qtdmeses => 12            -- Numero de meses a procurar
                            ,pr_fldiasem => TRUE          -- Considerar o dia da semana
                            ,pr_flprxant => FALSE          -- Considerar 1 dia a mais ou menos
                            ,pr_tab_per_datas => vr_tab_per_datas -- Tabela de datas
                            ,pr_dscritic  => pr_dscritic);
    END IF;
    IF pr_dscritic <> 'OK' THEN
      RETURN;
    ELSE
      pr_dscritic := NULL;
    END IF;
    
    -- Se chegarmos neste ponto e não encontramos nenhuma data a projetar
    IF vr_tab_per_datas.count() = 0 THEN 
      -- Então buscaremos os ultimos 12 meses considerando o dia da semana e 1 dia do mês para mais ou para menos
      pc_gera_period_dia_mes(pr_cdcooper => pr_cdcooper   -- Codigo da Cooperativa
                            ,pr_dtmvtolt => pr_dtmvtolt   -- Data de movimento
                            ,pr_qtdmeses => 12            -- Numero de meses a procurar
                            ,pr_fldiasem => TRUE          -- Considerar o dia da semana
                            ,pr_flprxant => TRUE          -- Considerar 1 dia a mais ou menos
                            ,pr_tab_per_datas => vr_tab_per_datas -- Tabela de datas
                            ,pr_dscritic  => pr_dscritic);
      IF pr_dscritic <> 'OK' THEN
        RETURN;
      ELSE
        pr_dscritic := NULL;
      END IF;
    END IF;  
    
    -- Zerar valores para busca
    vr_contador := 0; 
    vr_vlrmedia := 0; 
    vr_vltotger := 0; 

    -- Ler todas as datas
    vr_idx := vr_tab_per_datas.first;
    LOOP
      EXIT WHEN vr_idx IS NULL;

      -- CAso utilizar base histórica
      IF pr_flghistor THEN 
        -- Buscar dos valores realizados e armazenados no fluxo financeiro 
        FOR rw_crapffm IN cr_crapffm_histor(pr_cdcooper => pr_cdcooper
                                           ,pr_dtmvtolt => vr_tab_per_datas(vr_idx).dtmvtolt
                                           ,pr_cdbccxlt => 85
                                           ,pr_tpdmovto => pr_tpdmovto
                                           ,pr_tpdcampo => 9 --> VLSATAIT
                                           ) LOOP 
          vr_vltotger := vr_vltotger + nvl(rw_crapffm.vllanmto,0);
        END LOOP;
      ELSE
        -- Busca entrada ou saida conforme movimento 
        IF pr_tpdmovto = 1 THEN
          FOR rw_lcm IN cr_craplcm_cash(pr_cdbccxlt => 85
                                       ,pr_cdcoptfn => pr_cdcooper
                                       ,pr_dtmvtolt => vr_tab_per_datas(vr_idx).dtmvtolt) LOOP 
            vr_vltotger := vr_vltotger + rw_lcm.vllanmto;
          END LOOP;                             
        ELSE
          FOR rw_lcm IN cr_craplcm_cop(pr_cdbccxlt => 85
                                      ,pr_cdcooper => pr_cdcooper
                                      ,pr_dtmvtolt => vr_tab_per_datas(vr_idx).dtmvtolt) LOOP
            vr_vltotger := vr_vltotger + rw_lcm.vllanmto;                                  
          END LOOP;                            
        END IF;
      END IF;  

      vr_contador := vr_contador + 1;
      
      vr_idx := vr_tab_per_datas.NEXT(vr_idx);
    END LOOP; --Fim loop periodo

    -- calcular media mês
    IF vr_contador > 0 THEN
      vr_vlrmedia := (vr_vltotger / vr_contador);
    ELSE
      vr_vlrmedia := 0;
    END IF;

    -- Ler os bancos e gravar os movimentos
    pc_grava_movimentacao(pr_cdcooper => pr_cdcooper   -- Codigo da Cooperativa
                         ,pr_dtmvtolt => pr_dtmvtolt   -- Data de movimento
                         ,pr_tpdmovto => pr_tpdmovto+2 -- Tipo de movimento (+2 para projeção)
                         ,pr_cdbccxlt => 85            -- Codigo do banco/caixa.
                         ,pr_tpdcampo => 9 /*VLSATAIT*/-- Tipo de campo
                         ,pr_vldcampo => vr_vlrmedia   -- Valor do campo
                         ,pr_dscritic => pr_dscritic);

    IF pr_dscritic <> 'OK' THEN
      RAISE vr_exc_erro;
    END IF;

    pr_dscritic := 'OK';

  EXCEPTION
    WHEN vr_exc_erro THEN
        NULL;
    WHEN OTHERS THEN
      pr_dscritic := 'Erro na FLXF0001.pc_grava_prj_saq_taa_ic: '||SQLerrm;
  END pc_grava_prj_saq_taa_ic;  

  -- Procedure para gravar movimento financeiro consolidado do saldo do dia anterior
  PROCEDURE pc_saldo_consolid_dia_ant(pr_cdcooper  IN INTEGER                     -- Codigo da Cooperativa
                                     ,pr_cdoperad  IN crapope.cdoperad%type       -- Codigo do operador
                                     ,pr_dscritic OUT VARCHAR2) AS                -- Descrição da critica

    -- .........................................................................
    --
    --  Programa : pc_saldo_consolid_dia_ant     Antigo: b1wgen0131.p/pi_grava_consolidado_sld_dia_ant_f
    --
    --
    --  Sistema  : Cred
    --  Sigla    : FLXF0001
    --  Autor    : Odirlei Busana
    --  Data     : novembro/2013.                   Ultima atualizacao: 26/11/2013
    --
    --  Dados referentes ao programa:
    --
    --   Objetivo  : Gravar movimento financeiro consolidado do saldo do dia anterior
    --
    --   Atualizacao: 26/11/2013 - Conversao Progress => Oracle (Odirlei-AMcom)
    --..........................................................................

    vr_vlressal      NUMBER := 0;

    vr_tab_saldos    EXTR0001.typ_tab_saldos;
    vr_tab_erro      GENE0001.typ_tab_erro;
    rw_crapdat       btch0001.cr_crapdat%ROWTYPE;   

    /* Busca dos dados da cooperativa */
    CURSOR cr_crapcop(pr_cdcooper IN craptab.cdcooper%TYPE) IS
      SELECT cop.nrctactl
            ,ass.vllimcre
        FROM crapcop cop
            ,crapass ass
       WHERE cop.cdcooper = pr_cdcooper
         AND ass.cdcooper = 3
         AND ass.nrdconta = cop.nrctactl;
    rw_crapcop cr_crapcop%ROWTYPE;

  BEGIN

    -- Verifica se a cooperativa esta cadastrada
    OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
    FETCH cr_crapcop
     INTO rw_crapcop;
    -- Apenas fechar o cursor
    CLOSE cr_crapcop;
    
    -- Buscar calendário da central
    OPEN btch0001.cr_crapdat(3);
    FETCH btch0001.cr_crapdat 
     INTO rw_crapdat;
    CLOSE btch0001.cr_crapdat; 

    /* Procedure para obter saldo final da cooperativa */
    extr0001.pc_obtem_saldo_dia(pr_cdcooper   => 3                       -- Fixo na Central
                               ,pr_rw_crapdat => rw_crapdat              -- Calendario
                               ,pr_cdagenci   => 0                       -- Codigo da agencia
                               ,pr_nrdcaixa   => 0                       -- Numero da caixa
                               ,pr_cdoperad   => pr_cdoperad             -- Codigo do operador do caixa
                               ,pr_nrdconta   => rw_crapcop.nrctactl     -- Numero da conta do cooperado
                               ,pr_vllimcre   => rw_crapcop.vllimcre     -- Limite de credito
                               ,pr_dtrefere   => rw_crapdat.dtmvtolt     -- Data referencia
                               ,pr_flgcrass   => FALSE                   -- Não carregar a crapass inteira
                               ,pr_tipo_busca => 'A'                     -- Busca da SDA do dia anterior
                               ,pr_des_reto   => pr_dscritic
                               ,pr_tab_sald   => vr_tab_saldos
                               ,pr_tab_erro   => vr_tab_erro);
    
    --Buscar valores do saldo anterior
    IF vr_tab_saldos.count > 0 THEN
      vr_vlressal := nvl(vr_tab_saldos(vr_tab_saldos.first).vlsddisp,0);
    ELSE
      vr_vlressal := 0;
    END IF;

    -- Gravar Informacoes do fluxo financeiro consolidado.
    pc_grava_consolidado_singular
                           (pr_cdcooper => pr_cdcooper   -- Codigo da Cooperativa
                           ,pr_cdbccxlt => 0             -- GLobal
                           ,pr_dtmvtolt => rw_crapdat.dtmvtolt -- Data de movimento
                           ,pr_tpdcampo => 3             -- Tipo de campo
                           ,pr_vldcampo => vr_vlressal   -- Valor do campo
                           ,pr_cdoperad => '1'           -- Operador
                           ,pr_dscritic => pr_dscritic); -- Descrição da critica

    IF pr_dscritic <> 'OK' THEN
      RETURN;
    END IF;

    pr_dscritic := 'OK';

  EXCEPTION
    WHEN OTHERS THEN
      pr_dscritic := 'Erro na FLXF0001.pc_saldo_consolid_dia_ant: '||SQLerrm;
  END pc_saldo_consolid_dia_ant;

  -- Procedure para gravar movimento financeiro do fluxo de entrada
  PROCEDURE pc_grava_fluxo_entrada (pr_cdcooper  IN INTEGER      -- Codigo da Cooperativa
                                   ,pr_cdagenci  IN INTEGER      -- Codigo da agencia
                                   ,pr_nrdcaixa  IN INTEGER      -- Numero da caixa
                                   ,pr_dtmvtolt  IN DATE         -- Data de movimento
                                   ,pr_nmdatela  IN VARCHAR2     -- Nome da tela
                                   ,pr_dtmvtoan  IN DATE         -- Data de movimento anterior
                                   ,pr_cdremessa IN NUMBER DEFAULT 0 -- Tipo da remessa (0 para todas)
                                   ,pr_tab_erro OUT GENE0001.typ_tab_erro -- Tabela contendo os erros
                                   ,pr_dscritic OUT VARCHAR2) AS -- Descrição da critica

    -- .........................................................................
    --
    --  Programa : pc_grava_fluxo_entrada   Antigo: b1wgen0131.p/grava-fluxo-entrada
    --
    --
    --  Sistema  : Cred
    --  Sigla    : FLXF0001
    --  Autor    : Odirlei Busana
    --  Data     : novembro/2013.                   Ultima atualizacao: 25/11/2013
    --
    --  Dados referentes ao programa:
    --
    --   Objetivo  : Gravar movimento financeiro do fluxo de entrada
    --
    --   Atualizacao: 25/11/2013 - Conversao Progress => Oracle (Odirlei-AMcom)
    --..........................................................................

    vr_exc_erro      EXCEPTION;
    vr_dscritic      VARCHAR2(4000) ;
    vr_nrsequen      NUMBER;

  BEGIN
    vr_dscritic := null;

    -- Gravar movimento financeiro referente aos TEDs recebidos
    IF pr_cdremessa IN(0,3) THEN 
      pc_grava_mvt_srted(pr_cdcooper  => pr_cdcooper   -- Codigo da Cooperativa
                        ,pr_dtmvtolt  => pr_dtmvtolt   -- Data de movimento
                        ,pr_dscritic  => vr_dscritic);

      IF vr_dscritic <> 'OK' THEN
        vr_nrsequen := NVL(pr_tab_erro.COUNT,0)+ 1;
        vr_dscritic := 'Calculo do SR TED nao foi efetuado - '||pr_cdcooper||'.';

        GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper,
                              pr_cdagenci => pr_cdagenci,
                              pr_nrdcaixa => pr_nrdcaixa,
                              pr_nrsequen => vr_nrsequen,
                              pr_cdcritic => 0,
                              pr_dscritic => vr_dscritic,
                              pr_tab_erro => pr_tab_erro);
      END IF;
    END IF;  
    
    -- Gravar movimento dos DOCs do dia 
    IF pr_cdremessa IN(0,2) THEN 
      pc_grava_mvt_srdoc(pr_cdcooper => pr_cdcooper    -- Codigo da Cooperativa
                        ,pr_dtmvtolt => pr_dtmvtolt    -- Data de movimento
                        ,pr_dscritic => vr_dscritic);  -- Descrição da critica
      
      IF vr_dscritic <> 'OK' THEN
        vr_nrsequen := NVL(pr_tab_erro.COUNT,0)+ 1;
        vr_dscritic := 'Calculo do SR DOC nao foi efetuado - '||pr_cdcooper||'.';

        GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper,
                              pr_cdagenci => pr_cdagenci,
                              pr_nrdcaixa => pr_nrdcaixa,
                              pr_nrsequen => vr_nrsequen,
                              pr_cdcritic => 0,
                              pr_dscritic => vr_dscritic,
                              pr_tab_erro => pr_tab_erro);
      END IF;
    END IF;
        
    -- Gravar movimento financeiro das movimentções de Cheques acolhidos para depositos nas contas dos associados.
    IF pr_cdremessa IN(0,1) THEN 
      pc_grava_mvt_nrcheques( pr_cdcooper  => pr_cdcooper     -- Codigo da Cooperativa
                             ,pr_dtmvtolt  => pr_dtmvtolt     -- Data de movimento
                             ,pr_dscritic  => vr_dscritic);

      IF vr_dscritic <> 'OK' THEN
        vr_nrsequen := NVL(pr_tab_erro.COUNT,0)+ 1;
        vr_dscritic := 'Calculo do NR CHEQUES nao foi efetuado - '||pr_cdcooper||'.';

        GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper,
                              pr_cdagenci => pr_cdagenci,
                              pr_nrdcaixa => pr_nrdcaixa,
                              pr_nrsequen => vr_nrsequen,
                              pr_cdcritic => 0,
                              pr_dscritic => vr_dscritic,
                              pr_tab_erro => pr_tab_erro);
      END IF;
    END IF;
    
    -- Gravar movimento financeiro da devolucao de cheques ou taxa de devolucao.
    IF pr_cdremessa IN(0,5) THEN 
      pc_grava_mvt_dev_cheque_rem ( pr_cdcooper => pr_cdcooper     -- Codigo da Cooperativa
                                   ,pr_dtmvtolt => pr_dtmvtolt    -- Data de movimento
                                   ,pr_nmdatela => pr_nmdatela    -- Nome da tela
                                   ,pr_dtmvtoan => pr_dtmvtoan    -- Data movimento anterior
                                   ,pr_dscritic => vr_dscritic);

      IF vr_dscritic <> 'OK' THEN
        vr_nrsequen := NVL(pr_tab_erro.COUNT,0)+ 1;
        vr_dscritic := 'Calculo da Devolucao Cheques Remet. nao foi efetuado - '||pr_cdcooper||'.';

        GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper,
                              pr_cdagenci => pr_cdagenci,
                              pr_nrdcaixa => pr_nrdcaixa,
                              pr_nrsequen => vr_nrsequen,
                              pr_cdcritic => 0,
                              pr_dscritic => vr_dscritic,
                              pr_tab_erro => pr_tab_erro);
      END IF;
    END IF;  

    -- gravar movimento financeiro das movimentções de INSS
    IF pr_cdremessa IN(0,7) THEN 
      pc_grava_mvt_inss (  pr_cdcooper => pr_cdcooper -- Codigo da Cooperativa
                          ,pr_dtmvtolt => pr_dtmvtolt -- Data de movimento
                          ,pr_dscritic => vr_dscritic);

      IF vr_dscritic <> 'OK' THEN
        vr_nrsequen := NVL(pr_tab_erro.COUNT,0)+ 1;
        vr_dscritic := 'Calculo do INSS nao foi efetuado - '||pr_cdcooper||'.';

        GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper,
                              pr_cdagenci => pr_cdagenci,
                              pr_nrdcaixa => pr_nrdcaixa,
                              pr_nrsequen => vr_nrsequen,
                              pr_cdcritic => 0,
                              pr_dscritic => vr_dscritic,
                              pr_tab_erro => pr_tab_erro);
      END IF;
    END IF;
    
    -- gravar movimento financeiro dos Credito transferencia/tec salario intercooperativo
    IF pr_cdremessa IN(0,8) THEN 
      pc_grava_mvt_transf_ic (pr_cdcooper  => pr_cdcooper    -- Codigo da Cooperativa
                             ,pr_dtmvtolt  => pr_dtmvtolt     -- Data de movimento
                             ,pr_tpdmovto  => 1     -- Tipo de movimento (1-Entrada 2-saida)
                             ,pr_dscritic  => vr_dscritic);

      IF vr_dscritic <> 'OK' THEN
        vr_nrsequen := NVL(pr_tab_erro.COUNT,0)+ 1;
        vr_dscritic := 'Calculo da Transf Interc. nao foi efetuado - '||pr_cdcooper||'.';

        GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper,
                              pr_cdagenci => pr_cdagenci,
                              pr_nrdcaixa => pr_nrdcaixa,
                              pr_nrsequen => vr_nrsequen,
                              pr_cdcritic => 0,
                              pr_dscritic => vr_dscritic,
                              pr_tab_erro => pr_tab_erro);
      END IF;
    END IF;
    
    -- gravar movimento financeiro dos Credito deposito intercooperativo
    IF pr_cdremessa IN(0,12) THEN 
      pc_grava_mvt_dep_ic(pr_cdcooper  => pr_cdcooper    -- Codigo da Cooperativa
                         ,pr_dtmvtolt  => pr_dtmvtolt     -- Data de movimento
                         ,pr_tpdmovto  => 1     -- Tipo de movimento (1-Entrada 2-saida)
                         ,pr_dscritic  => vr_dscritic);

      IF vr_dscritic <> 'OK' THEN
        vr_nrsequen := NVL(pr_tab_erro.COUNT,0)+ 1;
        vr_dscritic := 'Calculo da Depos Interc. nao foi efetuado - '||pr_cdcooper||'.';

        GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper,
                              pr_cdagenci => pr_cdagenci,
                              pr_nrdcaixa => pr_nrdcaixa,
                              pr_nrsequen => vr_nrsequen,
                              pr_cdcritic => 0,
                              pr_dscritic => vr_dscritic,
                              pr_tab_erro => pr_tab_erro);
      END IF;
    END IF;
    
    -- gravar movimento financeiro dos SRtitulos
    IF pr_cdremessa IN(0,4) THEN 
      pc_grava_mvt_SRtitulos(pr_cdcooper  => pr_cdcooper    -- Codigo da Cooperativa
                            ,pr_nmdatela  => pr_nmdatela    -- Nome da tela
                            ,pr_dtmvtolt  => pr_dtmvtolt    -- Data de movimento
                            ,pr_dscritic  => vr_dscritic);

      IF vr_dscritic <> 'OK' THEN
        vr_nrsequen := NVL(pr_tab_erro.COUNT,0)+ 1;
        vr_dscritic := 'Nao foi possivel realizar o calculo do SR Titulos - '||pr_cdcooper||'.';

        GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper,
                              pr_cdagenci => pr_cdagenci,
                              pr_nrdcaixa => pr_nrdcaixa,
                              pr_nrsequen => vr_nrsequen,
                              pr_cdcritic => 0,
                              pr_dscritic => vr_dscritic,
                              pr_tab_erro => pr_tab_erro);
      END IF;
    END IF;
        
    -- Gravar movimento financeiro de Recolhimento Numerário
    IF pr_cdremessa IN(0,13) THEN 
      pc_grava_mvt_recol_numerario(pr_cdcooper  => pr_cdcooper     -- Codigo da Cooperativa
                                  ,pr_dtmvtolt  => pr_dtmvtolt     -- Data de movimento
                                  ,pr_dscritic  => vr_dscritic);
      IF vr_dscritic <> 'OK' THEN
        vr_nrsequen := NVL(pr_tab_erro.COUNT,0)+ 1;
        vr_dscritic := 'Calculo do Recolhimento Numerário nao foi efetuado - '||pr_cdcooper||'.';

        GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper,
                              pr_cdagenci => pr_cdagenci,
                              pr_nrdcaixa => pr_nrdcaixa,
                              pr_nrsequen => vr_nrsequen,
                              pr_cdcritic => 0,
                              pr_dscritic => vr_dscritic,
                              pr_tab_erro => pr_tab_erro);
      END IF;
    END IF;
    
    -- gravar movimento financeiro referente aos saques no TAA das intercoop
    IF pr_cdremessa IN(0,9) THEN 
      pc_grava_mvt_saq_taa_ic(pr_cdcooper  => pr_cdcooper     -- Codigo da Cooperativa
                             ,pr_dtmvtolt  => pr_dtmvtolt     -- Data de movimento
                             ,pr_tpdmovto  => 1               -- Tipo de movimento (1-Entrada 2-saida)
                             ,pr_dscritic  => vr_dscritic);

      IF vr_dscritic <> 'OK' THEN
        vr_nrsequen := NVL(pr_tab_erro.COUNT,0)+ 1;
        vr_dscritic := 'Calculo do Saque TAA Interc. nao foi efetuado - '||pr_cdcooper||'.';

        GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper,
                              pr_cdagenci => pr_cdagenci,
                              pr_nrdcaixa => pr_nrdcaixa,
                              pr_nrsequen => vr_nrsequen,
                              pr_cdcritic => 0,
                              pr_dscritic => vr_dscritic,
                              pr_tab_erro => pr_tab_erro);
      END IF;
    END IF;
        
    -- Gravar movimento financeiro das contas Itg - Entrada
    IF pr_cdremessa IN(0,6) THEN 
      pc_grava_mvt_conta_itg ( pr_cdcooper => pr_cdcooper           -- Codigo da Cooperativa
                              ,pr_dtmvtolt => pr_dtmvtolt           -- Data de movimento
                              ,pr_tpdmovto => 1                     -- tipo de movimento(1-entrada 2-saida)
                              ,pr_dscritic => vr_dscritic );

      IF vr_dscritic <> 'OK' THEN
        vr_nrsequen := NVL(pr_tab_erro.COUNT,0)+ 1;
        vr_dscritic := 'Nao foi possivel realizar o calculo do Mov. Conta ITG. - '||pr_cdcooper||'.';

        GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper,
                              pr_cdagenci => pr_cdagenci,
                              pr_nrdcaixa => pr_nrdcaixa,
                              pr_nrsequen => vr_nrsequen,
                              pr_cdcritic => 0,
                              pr_dscritic => vr_dscritic,
                              pr_tab_erro => pr_tab_erro);
      END IF;    
    END IF;  

    pr_dscritic := 'OK';

  END pc_grava_fluxo_entrada;

  -- Procedure para gravar movimento financeiro do fluxo de saida
  PROCEDURE pc_grava_fluxo_saida (pr_cdcooper  IN INTEGER      -- Codigo da Cooperativa
                                 ,pr_cdagenci  IN INTEGER      -- Codigo da agencia
                                 ,pr_nrdcaixa  IN INTEGER      -- Numero da caixa
                                 ,pr_dtmvtolt  IN DATE         -- Data de movimento
                                 ,pr_dtmvtoan  IN DATE         -- Data de movimento anterior
                                 ,pr_cdremessa IN NUMBER DEFAULT 0 -- Tipo da remessa (0 para todas)
                                 ,pr_tab_erro OUT GENE0001.typ_tab_erro -- Tabela contendo os erros
                                 ,pr_dscritic OUT VARCHAR2) AS -- Descrição da critica

    -- .........................................................................
    --
    --  Programa : pc_grava_fluxo_saida   Antigo: b1wgen0131.p/grava-fluxo-saida
    --
    --
    --  Sistema  : Cred
    --  Sigla    : FLXF0001
    --  Autor    : Odirlei Busana
    --  Data     : novembro/2013.                   Ultima atualizacao: 26/11/2013
    --
    --  Dados referentes ao programa:
    --
    --   Objetivo  : Gravar movimento financeiro do fluxo de saida
    --
    --   Atualizacao: 26/11/2013 - Conversao Progress => Oracle (Odirlei-AMcom)
    --..........................................................................

    vr_exc_erro      EXCEPTION;
    vr_dscritic      VARCHAR2(4000) ;
    vr_nrsequen      NUMBER;

  BEGIN

    vr_dscritic := null;

    -- Procedure para gravar movimento financeiro de cheques saida realizado
    IF pr_cdremessa IN(0,1) THEN 
      pc_grava_mvt_srcheques(pr_cdcooper  => pr_cdcooper    -- Codigo da Cooperativa
                            ,pr_dtmvtolt  => pr_dtmvtolt    -- Data de movimento
                            ,pr_dtmvtoan  => pr_dtmvtoan    -- Dia do movimento anterior
                            ,pr_dscritic  => vr_dscritic);

      IF vr_dscritic <> 'OK' THEN
        vr_nrsequen := NVL(pr_tab_erro.COUNT,0)+ 1;
        vr_dscritic := 'Calculo do NR Cheques nao foi efetuado - '||pr_cdcooper||'.';

        GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper,
                              pr_cdagenci => pr_cdagenci,
                              pr_nrdcaixa => pr_nrdcaixa,
                              pr_nrsequen => vr_nrsequen,
                              pr_cdcritic => 0,
                              pr_dscritic => vr_dscritic,
                              pr_tab_erro => pr_tab_erro);
      END IF;
    END IF;  
    
    -- Procedure para gravar movimento financeiro dos conveniados
    IF pr_cdremessa IN(0,11) THEN 
      pc_grava_mvt_convenios(pr_cdcooper  => pr_cdcooper      -- Codigo da Cooperativa
                            ,pr_dtmvtolt  => pr_dtmvtolt    -- Data de movimento
                            ,pr_dscritic  => vr_dscritic);

      IF vr_dscritic <> 'OK' THEN
        vr_nrsequen := NVL(pr_tab_erro.COUNT,0)+ 1;
        vr_dscritic := 'Calculo do convenio nao foi efetuado - '||pr_cdcooper||'.';

        GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper,
                              pr_cdagenci => pr_cdagenci,
                              pr_nrdcaixa => pr_nrdcaixa,
                              pr_nrsequen => vr_nrsequen,
                              pr_cdcritic => 0,
                              pr_dscritic => vr_dscritic,
                              pr_tab_erro => pr_tab_erro);
      END IF;
    END IF;  

    -- Procedure para gravar movimento financeiro das transferencias DOCs
    IF pr_cdremessa IN(0,2) THEN 
      pc_grava_mvt_nrdoc(pr_cdcooper => pr_cdcooper     -- Codigo da Cooperativa
                        ,pr_dtmvtolt => pr_dtmvtolt     -- Data de movimento
                        ,pr_dscritic => vr_dscritic);

      IF vr_dscritic <> 'OK' THEN
        vr_nrsequen := NVL(pr_tab_erro.COUNT,0)+ 1;
        vr_dscritic := 'Calculo do NR DOC nao foi efetuado - '||pr_cdcooper||'.';

        GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper,
                              pr_cdagenci => pr_cdagenci,
                              pr_nrdcaixa => pr_nrdcaixa,
                              pr_nrsequen => vr_nrsequen,
                              pr_cdcritic => 0,
                              pr_dscritic => vr_dscritic,
                              pr_tab_erro => pr_tab_erro);
      END IF;
    end if;  
    
    -- Gravar movimento financeiro das devoluções de cheques recebidos
    IF pr_cdremessa IN(0,5) THEN 
      pc_grava_mvt_dev_cheque_rec(pr_cdcooper => pr_cdcooper      -- Codigo da Cooperativa
                                 ,pr_dtmvtolt => pr_dtmvtolt     -- Data de movimento
                                 ,pr_dscritic => vr_dscritic);
      IF vr_dscritic <> 'OK' THEN
        vr_nrsequen := NVL(pr_tab_erro.COUNT,0)+ 1;
        vr_dscritic := 'Calculo da Dev Cheques Recebidos nao foi efetuado - '||pr_cdcooper||'.';

        GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper,
                              pr_cdagenci => pr_cdagenci,
                              pr_nrdcaixa => pr_nrdcaixa,
                              pr_nrsequen => vr_nrsequen,
                              pr_cdcritic => 0,
                              pr_dscritic => vr_dscritic,
                              pr_tab_erro => pr_tab_erro);
      END IF;
    END IF;  


    -- Gravar movimento financeiro dos TEDs e TECs
    IF pr_cdremessa IN(0,3) THEN 
      pc_grava_mvt_nrtedtec(pr_cdcooper => pr_cdcooper      -- Codigo da Cooperativa
                           ,pr_dtmvtolt => pr_dtmvtolt     -- Data de movimento
                           ,pr_dscritic => vr_dscritic);

      IF vr_dscritic <> 'OK' THEN
        vr_nrsequen := NVL(pr_tab_erro.COUNT,0)+ 1;
        vr_dscritic := 'Calculo do NR TED nao foi efetuado - '||pr_cdcooper||'.';

        GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper,
                              pr_cdagenci => pr_cdagenci,
                              pr_nrdcaixa => pr_nrdcaixa,
                              pr_nrsequen => vr_nrsequen,
                              pr_cdcritic => 0,
                              pr_dscritic => vr_dscritic,
                              pr_tab_erro => pr_tab_erro);
      END IF;
    END IF;
    
    -- Gravar movimento financeiro dos NR titulos
    IF pr_cdremessa IN(0,4) THEN 
      pc_grava_mvt_nrtitulos(pr_cdcooper => pr_cdcooper     -- Codigo da Cooperativa
                            ,pr_dtmvtolt => pr_dtmvtolt     -- Data de movimento
                            ,pr_dtmvtoan => pr_dtmvtoan     -- Data de movimento anterior
                            ,pr_dscritic => vr_dscritic);

      IF vr_dscritic <> 'OK' THEN
        vr_nrsequen := NVL(pr_tab_erro.COUNT,0)+ 1;
        vr_dscritic := 'Calculo do NR Titulos nao foi efetuado - '||pr_cdcooper||'.';

        GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper,
                              pr_cdagenci => pr_cdagenci,
                              pr_nrdcaixa => pr_nrdcaixa,
                              pr_nrsequen => vr_nrsequen,
                              pr_cdcritic => 0,
                              pr_dscritic => vr_dscritic,
                              pr_tab_erro => pr_tab_erro);
      END IF;
    END IF;  

    -- Procedure para gravar movimento financeiro das Guias de recolhimento da Previdencia Social
    IF pr_cdremessa IN(0,7) THEN     
      pc_grava_mvt_grps( pr_cdcooper => pr_cdcooper      -- Codigo da Cooperativa
                        ,pr_dtmvtolt => pr_dtmvtolt     -- Data de movimento
                        ,pr_dscritic => vr_dscritic);

      IF vr_dscritic <> 'OK' THEN
        vr_nrsequen := NVL(pr_tab_erro.COUNT,0)+ 1;
        vr_dscritic := 'Calculo do GPS nao foi efetuado - '||pr_cdcooper||'.';

        GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper,
                              pr_cdagenci => pr_cdagenci,
                              pr_nrdcaixa => pr_nrdcaixa,
                              pr_nrsequen => vr_nrsequen,
                              pr_cdcritic => 0,
                              pr_dscritic => vr_dscritic,
                              pr_tab_erro => pr_tab_erro);
      END IF;
    END IF; 
    
    -- Gravar movimento financeiro de Suprimento Numerário
    IF pr_cdremessa IN(0,13) THEN 
      pc_grava_mvt_suprim_numerario(pr_cdcooper  => pr_cdcooper     -- Codigo da Cooperativa
                                   ,pr_dtmvtolt  => pr_dtmvtolt     -- Data de movimento
                                   ,pr_dscritic  => vr_dscritic);
      IF vr_dscritic <> 'OK' THEN
        vr_nrsequen := NVL(pr_tab_erro.COUNT,0)+ 1;
        vr_dscritic := 'Calculo do Suprimento Numerário nao foi efetuado - '||pr_cdcooper||'.';

        GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper,
                              pr_cdagenci => pr_cdagenci,
                              pr_nrdcaixa => pr_nrdcaixa,
                              pr_nrsequen => vr_nrsequen,
                              pr_cdcritic => 0,
                              pr_dscritic => vr_dscritic,
                              pr_tab_erro => pr_tab_erro);
      END IF;
    END IF;
    
    -- Gravar movimento financeiro dos Credito transferencia/tec salario intercooperativo
    IF pr_cdremessa IN(0,8) THEN     
      pc_grava_mvt_transf_ic(pr_cdcooper => pr_cdcooper     -- Codigo da Cooperativa
                            ,pr_dtmvtolt => pr_dtmvtolt     -- Data de movimento
                            ,pr_tpdmovto => 2               -- Tipo de movimento (1-Entrada 2-saida)
                            ,pr_dscritic => vr_dscritic);

      IF vr_dscritic <> 'OK' THEN
        vr_nrsequen := NVL(pr_tab_erro.COUNT,0)+ 1;
        vr_dscritic := 'Calculo das Transf Interc. nao foi efetuado - '||pr_cdcooper||'.';

        GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper,
                              pr_cdagenci => pr_cdagenci,
                              pr_nrdcaixa => pr_nrdcaixa,
                              pr_nrsequen => vr_nrsequen,
                              pr_cdcritic => 0,
                              pr_dscritic => vr_dscritic,
                              pr_tab_erro => pr_tab_erro);
      END IF;
    END IF;  
    
    -- Gravar movimento financeiro dos Credito deposito intercooperativo
    IF pr_cdremessa IN(0,12) THEN     
      pc_grava_mvt_dep_ic(pr_cdcooper => pr_cdcooper     -- Codigo da Cooperativa
                         ,pr_dtmvtolt => pr_dtmvtolt     -- Data de movimento
                         ,pr_tpdmovto => 2               -- Tipo de movimento (1-Entrada 2-saida)
                         ,pr_dscritic => vr_dscritic);

      IF vr_dscritic <> 'OK' THEN
        vr_nrsequen := NVL(pr_tab_erro.COUNT,0)+ 1;
        vr_dscritic := 'Calculo das Depos Interc. nao foi efetuado - '||pr_cdcooper||'.';

        GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper,
                              pr_cdagenci => pr_cdagenci,
                              pr_nrdcaixa => pr_nrdcaixa,
                              pr_nrsequen => vr_nrsequen,
                              pr_cdcritic => 0,
                              pr_dscritic => vr_dscritic,
                              pr_tab_erro => pr_tab_erro);
      END IF;
    END IF;  

    -- Gravar movimento financeiro referente aos saques no TAA das intercoop
    IF pr_cdremessa IN(0,9) THEN 
      pc_grava_mvt_saq_taa_ic(pr_cdcooper => pr_cdcooper     -- Codigo da Cooperativa
                             ,pr_dtmvtolt => pr_dtmvtolt     -- Data de movimento
                             ,pr_tpdmovto => 2               -- Tipo de movimento (1-Entrada 2-saida)
                             ,pr_dscritic => vr_dscritic);


      IF vr_dscritic <> 'OK' THEN
        vr_nrsequen := NVL(pr_tab_erro.COUNT,0)+ 1;
        vr_dscritic := 'Calculo do Saque TAA Interc. nao foi efetuado - '||pr_cdcooper||'.';

        GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper,
                              pr_cdagenci => pr_cdagenci,
                              pr_nrdcaixa => pr_nrdcaixa,
                              pr_nrsequen => vr_nrsequen,
                              pr_cdcritic => 0,
                              pr_dscritic => vr_dscritic,
                              pr_tab_erro => pr_tab_erro);
      END IF;
    END IF;
    
    -- Gravar movimento financeiro das faturas do Cartão de Crédito
    IF pr_cdremessa IN(0,10) THEN     
      pc_grava_mvt_fatura_cart_credi(pr_cdcooper => pr_cdcooper     -- Codigo da Cooperativa
                                    ,pr_dtmvtolt => pr_dtmvtolt     -- Data de movimento
                                    ,pr_dtmvtoan => pr_dtmvtoan     -- Dia do movimento anterior
                                    ,pr_dscritic => vr_dscritic);

      IF vr_dscritic <> 'OK' THEN
        vr_nrsequen := NVL(pr_tab_erro.COUNT,0)+ 1;
        vr_dscritic := 'Calculo das faturas do cartão de crédito nao foi efetuado - '||pr_cdcooper||'.';

        GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper,
                              pr_cdagenci => pr_cdagenci,
                              pr_nrdcaixa => pr_nrdcaixa,
                              pr_nrsequen => vr_nrsequen,
                              pr_cdcritic => 0,
                              pr_dscritic => vr_dscritic,
                              pr_tab_erro => pr_tab_erro);
      END IF;
    END IF;
    
    -- Gravar movimento financeiro do cartão de debito
    IF pr_cdremessa IN(0,14) THEN 
      pc_grava_mvt_cart_debito(pr_cdcooper => pr_cdcooper     -- Codigo da Cooperativa
                              ,pr_dtmvtolt => pr_dtmvtolt     -- Data de movimento
                              ,pr_dscritic => vr_dscritic);

      IF vr_dscritic <> 'OK' THEN
        vr_nrsequen := NVL(pr_tab_erro.COUNT,0)+ 1;
        vr_dscritic := 'Calculo dos Lctos Cartão Debito nao foi efetuado - '||pr_cdcooper||'.';

        GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper,
                              pr_cdagenci => pr_cdagenci,
                              pr_nrdcaixa => pr_nrdcaixa,
                              pr_nrsequen => vr_nrsequen,
                              pr_cdcritic => 0,
                              pr_dscritic => vr_dscritic,
                              pr_tab_erro => pr_tab_erro);
      END IF;
    END IF;
    
    -- Gravar movimento financeiro das contas Itg - Saida
    IF pr_cdremessa IN(0,6) THEN     
      pc_grava_mvt_conta_itg ( pr_cdcooper => pr_cdcooper           -- Codigo da Cooperativa
                              ,pr_dtmvtolt => pr_dtmvtolt           -- Data de movimento
                              ,pr_tpdmovto => 2                     -- tipo de movimento(1-entrada 2-saida)
                              ,pr_dscritic => vr_dscritic );

      IF vr_dscritic <> 'OK' THEN
        vr_nrsequen := NVL(pr_tab_erro.COUNT,0)+ 1;
        vr_dscritic := 'Nao foi possivel realizar o calculo do Mov. Conta ITG. - '||pr_cdcooper||'.';

        GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper,
                              pr_cdagenci => pr_cdagenci,
                              pr_nrdcaixa => pr_nrdcaixa,
                              pr_nrsequen => vr_nrsequen,
                              pr_cdcritic => 0,
                              pr_dscritic => vr_dscritic,
                              pr_tab_erro => pr_tab_erro);
      END IF;
    END IF;
    
    pr_dscritic := 'OK';

  END pc_grava_fluxo_saida;
  
  -- Procedure para gravar movimento financeiro de Projeções
  PROCEDURE pc_grava_fluxo_projetado(pr_cdcooper  IN INTEGER      -- Codigo da Cooperativa
                                    ,pr_cdagenci  IN INTEGER      -- Codigo da agencia
                                    ,pr_nrdcaixa  IN INTEGER      -- Numero da caixa
                                    ,pr_nmdatela  IN VARCHAR2     -- Nome da tela em execução
                                    ,pr_dtmvtolt  IN DATE         -- Data do dial atual
                                    ,pr_dtmvtopr  IN DATE         -- Data de movimento anterior
                                    ,pr_cdremessa IN NUMBER DEFAULT 0 -- Tipo da remessa (0 para todas)
                                    ,pr_tpfluxo   IN NUMBER DEFAULT 0 -- TIpo do fluxo (0 para todos)
                                                                        ,pr_flghistor IN BOOLEAN DEFAULT FALSE -- Flag para utilização da base histórica 
                                    ,pr_tab_erro OUT GENE0001.typ_tab_erro -- Tabela contendo os erros
                                    ,pr_dscritic OUT VARCHAR2) AS -- Descrição da critica

    -- .........................................................................
    --
    --  Programa : pc_grava_fluxo_projetado
    --
    --
    --  Sistema  : Cred
    --  Sigla    : FLXF0001
    --  Autor    : Marcos Martini
    --  Data     : Outubro/2016.                   Ultima atualizacao: 
    --
    --  Dados referentes ao programa:
    --
    --   Objetivo  : Gravar movimento financeiro das Projeções
    --
    --   Atualizacao: 
    --..........................................................................

    vr_exc_erro      EXCEPTION;
    vr_dscritic      VARCHAR2(4000) ;
    vr_nrsequen      NUMBER;
    
    vr_tab_cdbccxlt  gene0002.typ_split;    
    
  BEGIN

    vr_dscritic := null;
    
    -- Garantir inicialização do registro CRAPFFM de todas as entidades para o próximo dia
    vr_tab_cdbccxlt := gene0002.fn_quebra_string('01,85,756,748',',');

    FOR idx IN vr_tab_cdbccxlt.first..vr_tab_cdbccxlt.last LOOP
      -- Gerar registro 1 - Entrada Realizado
      pc_grava_movimentacao(pr_cdcooper => pr_cdcooper   -- Codigo da Cooperativa
                           ,pr_dtmvtolt => pr_dtmvtopr   -- Data de movimento
                           ,pr_tpdmovto => 1             -- Tipo de movimento(E)
                           ,pr_cdbccxlt => vr_tab_cdbccxlt(idx)     -- Codigo do banco/caixa.
                           ,pr_tpdcampo => 0             -- Tipo de campo(0) pra criar o registro
                           ,pr_vldcampo => 0             -- Valor do campo
                           ,pr_dscritic => pr_dscritic);

      IF pr_dscritic <> 'OK' THEN
        RAISE vr_exc_erro;
      END IF;  
      -- Gerar registro 2 - Saída Realizado
      pc_grava_movimentacao(pr_cdcooper => pr_cdcooper   -- Codigo da Cooperativa
                           ,pr_dtmvtolt => pr_dtmvtopr   -- Data de movimento
                           ,pr_tpdmovto => 2             -- Tipo de movimento(E)
                           ,pr_cdbccxlt => vr_tab_cdbccxlt(idx)     -- Codigo do banco/caixa.
                           ,pr_tpdcampo => 0             -- Tipo de campo(0) pra criar o registro
                           ,pr_vldcampo => 0             -- Valor do campo
                           ,pr_dscritic => pr_dscritic);

      IF pr_dscritic <> 'OK' THEN
        RAISE vr_exc_erro;
      END IF;
      -- Gerar registro 3 - Entrada Projetada
      pc_grava_movimentacao(pr_cdcooper => pr_cdcooper   -- Codigo da Cooperativa
                           ,pr_dtmvtolt => pr_dtmvtopr   -- Data de movimento
                           ,pr_tpdmovto => 3             -- Tipo de movimento(E)
                           ,pr_cdbccxlt => vr_tab_cdbccxlt(idx)     -- Codigo do banco/caixa.
                           ,pr_tpdcampo => 0             -- Tipo de campo(0) pra criar o registro
                           ,pr_vldcampo => 0             -- Valor do campo
                           ,pr_dscritic => pr_dscritic);

      IF pr_dscritic <> 'OK' THEN
        RAISE vr_exc_erro;
      END IF;
      -- Gerar registro 4 - Saida Projetada
      pc_grava_movimentacao(pr_cdcooper => pr_cdcooper   -- Codigo da Cooperativa
                           ,pr_dtmvtolt => pr_dtmvtopr   -- Data de movimento
                           ,pr_tpdmovto => 4             -- Tipo de movimento(E)
                           ,pr_cdbccxlt => vr_tab_cdbccxlt(idx)     -- Codigo do banco/caixa.
                           ,pr_tpdcampo => 0             -- Tipo de campo(0) pra criar o registro
                           ,pr_vldcampo => 0             -- Valor do campo
                           ,pr_dscritic => pr_dscritic);

      IF pr_dscritic <> 'OK' THEN
        RAISE vr_exc_erro;
      END IF;            
    END LOOP;--Fim loop bancos
    
    -- Docs
    IF pr_cdremessa IN(0,2) THEN     
      
      IF pr_tpfluxo IN(0,3) THEN   
        -- Gravar movimento financeiro dos docs
        pc_grava_prj_srdoc(pr_cdcooper => pr_cdcooper             -- Codigo da Cooperativa
                          ,pr_dtmvtolt => pr_dtmvtopr             -- Data de movimento
                          ,pr_flghistor => pr_flghistor   -- Flag para utilização da base histórica 
                          ,pr_dscritic => vr_dscritic) ;

        IF vr_dscritic <> 'OK' THEN
          vr_nrsequen := NVL(pr_tab_erro.COUNT,0)+ 1;
          vr_dscritic := 'Nao foi possivel realizar o calculo do SR DOC. - '||pr_cdcooper||'.';

          GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper,
                                pr_cdagenci => pr_cdagenci,
                                pr_nrdcaixa => pr_nrdcaixa,
                                pr_nrsequen => vr_nrsequen,
                                pr_cdcritic => 0,
                                pr_dscritic => vr_dscritic,
                                pr_tab_erro => pr_tab_erro);
        END IF;
      END IF;  
      
      IF pr_tpfluxo IN(0,4) THEN 
        -- Gravar movimento financeiro dos docs
        pc_grava_prj_nrdoc(pr_cdcooper => pr_cdcooper     -- Codigo da Cooperativa
                          ,pr_dtmvtolt => pr_dtmvtopr     -- Data de movimento
                          ,pr_flghistor => pr_flghistor   -- Flag para utilização da base histórica 
                          ,pr_dscritic => vr_dscritic);

        IF vr_dscritic <> 'OK' THEN
          vr_nrsequen := NVL(pr_tab_erro.COUNT,0)+ 1;
          vr_dscritic := 'Calculo do NR DOC Projetado nao foi efetuado - '||pr_cdcooper||'.';

          GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper,
                                pr_cdagenci => pr_cdagenci,
                                pr_nrdcaixa => pr_nrdcaixa,
                                pr_nrsequen => vr_nrsequen,
                                pr_cdcritic => 0,
                                pr_dscritic => vr_dscritic,
                                pr_tab_erro => pr_tab_erro);
        END IF;
      END IF;
      
    END IF;  

    -- TED/TEC 
    IF pr_cdremessa in(0,3) THEN     
      
      IF pr_tpfluxo IN(0,3) THEN 
        -- Gravar projeção financeiro SRTED
        pc_grava_prj_srted(pr_cdcooper  => pr_cdcooper   -- Codigo da Cooperativa
                          ,pr_dtmvtolt  => pr_dtmvtopr   -- Data de movimento
                          ,pr_flghistor => pr_flghistor   -- Flag para utilização da base histórica 
                          ,pr_dscritic => vr_dscritic) ;

        IF vr_dscritic <> 'OK' THEN
          vr_nrsequen := NVL(pr_tab_erro.COUNT,0)+ 1;
          vr_dscritic := 'Nao foi possivel realizar o calculo do SR TED. - '||pr_cdcooper||'.';

          GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper,
                                pr_cdagenci => pr_cdagenci,
                                pr_nrdcaixa => pr_nrdcaixa,
                                pr_nrsequen => vr_nrsequen,
                                pr_cdcritic => 0,
                                pr_dscritic => vr_dscritic,
                                pr_tab_erro => pr_tab_erro);
        END IF;
      END IF;
      
      IF pr_tpfluxo in(0,4) THEN 
        -- Gerar projeção movimento financeiro das TEDs/TECs
        pc_grava_prj_nrtedtec (pr_cdcooper => pr_cdcooper           -- Codigo da Cooperativa
                              ,pr_dtmvtolt => pr_dtmvtopr           -- Data de movimento
                              ,pr_flghistor => pr_flghistor   -- Flag para utilização da base histórica 
                              ,pr_dscritic => vr_dscritic);

        IF vr_dscritic <> 'OK' THEN
          vr_nrsequen := NVL(pr_tab_erro.COUNT,0)+ 1;
          vr_dscritic := 'Nao foi possivel realizar o calculo Projetados das TEDs/TECs - '||pr_cdcooper||'.';

          GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper,
                                pr_cdagenci => pr_cdagenci,
                                pr_nrdcaixa => pr_nrdcaixa,
                                pr_nrsequen => vr_nrsequen,
                                pr_cdcritic => 0,
                                pr_dscritic => vr_dscritic,
                                pr_tab_erro => pr_tab_erro);
        END IF;  
      END IF;        
      
    END IF;  
    
    -- Titulos
    IF pr_cdremessa IN(0,4) THEN 
      
      IF pr_tpfluxo IN(0,3) THEN 
        -- Gravar movimento financeiro dos titulos nr
        pc_grava_prj_srtitulos(pr_cdcooper => pr_cdcooper              -- Codigo da Cooperativa
                              ,pr_dtmvtolt => pr_dtmvtopr              -- Data de movimento
                              ,pr_flghistor => pr_flghistor   -- Flag para utilização da base histórica 
                              ,pr_dscritic => vr_dscritic);

        IF vr_dscritic <> 'OK' THEN
          vr_nrsequen := NVL(pr_tab_erro.COUNT,0)+ 1;
          vr_dscritic := 'Nao foi possivel realizar o calculo do SR Titulos - '||pr_cdcooper||'.';

          GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper,
                                pr_cdagenci => pr_cdagenci,
                                pr_nrdcaixa => pr_nrdcaixa,
                                pr_nrsequen => vr_nrsequen,
                                pr_cdcritic => 0,
                                pr_dscritic => vr_dscritic,
                                pr_tab_erro => pr_tab_erro);
        END IF;
      END IF;
      
      IF pr_tpfluxo IN(0,4) THEN 
        -- Gravar movimento financeiro dos titulos sr
        pc_grava_prj_nrtitulos(pr_cdcooper => pr_cdcooper              -- Codigo da Cooperativa
                              ,pr_dtmvtolt => pr_dtmvtopr              -- Data de movimento
                              ,pr_flghistor => pr_flghistor   -- Flag para utilização da base histórica 
                              ,pr_dscritic => vr_dscritic);

        IF vr_dscritic <> 'OK' THEN
          vr_nrsequen := NVL(pr_tab_erro.COUNT,0)+ 1;
          vr_dscritic := 'Nao foi possivel realizar o calculo do SR Titulos - '||pr_cdcooper||'.';

          GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper,
                                pr_cdagenci => pr_cdagenci,
                                pr_nrdcaixa => pr_nrdcaixa,
                                pr_nrsequen => vr_nrsequen,
                                pr_cdcritic => 0,
                                pr_dscritic => vr_dscritic,
                                pr_tab_erro => pr_tab_erro);
        END IF;
      END IF;  
    END IF;
      

    -- Cheques
    IF pr_cdremessa IN(0,1) THEN 
      
      IF pr_tpfluxo IN(0,3) THEN 
        -- Procedure para gravar movimento financeiro de cheques saida
        pc_grava_prj_nrcheques (pr_cdcooper => pr_cdcooper           -- Codigo da Cooperativa
                               ,pr_dtmvtolt => pr_dtmvtopr           -- Data de movimento
                               ,pr_flghistor => pr_flghistor   -- Flag para utilização da base histórica 
                               ,pr_dscritic => vr_dscritic);

        IF vr_dscritic <> 'OK' THEN
          vr_nrsequen := NVL(pr_tab_erro.COUNT,0)+ 1;
          vr_dscritic := 'Nao foi possivel realizar o calculo do NR Cheques - '||pr_cdcooper||'.';

          GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper,
                                pr_cdagenci => pr_cdagenci,
                                pr_nrdcaixa => pr_nrdcaixa,
                                pr_nrsequen => vr_nrsequen,
                                pr_cdcritic => 0,
                                pr_dscritic => vr_dscritic,
                                pr_tab_erro => pr_tab_erro);
        END IF;   
      END IF;  
      
      IF pr_tpfluxo IN(0,4) THEN 
        -- Procedure para gravar movimento financeiro de cheques saida
        pc_grava_prj_srcheques (pr_cdcooper => pr_cdcooper           -- Codigo da Cooperativa
                               ,pr_dtmvtolt => pr_dtmvtopr           -- Data de movimento
                               ,pr_flghistor => pr_flghistor   -- Flag para utilização da base histórica 
                               ,pr_dscritic => vr_dscritic);

        IF vr_dscritic <> 'OK' THEN
          vr_nrsequen := NVL(pr_tab_erro.COUNT,0)+ 1;
          vr_dscritic := 'Nao foi possivel realizar o calculo do SR Cheques - '||pr_cdcooper||'.';

          GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper,
                                pr_cdagenci => pr_cdagenci,
                                pr_nrdcaixa => pr_nrdcaixa,
                                pr_nrsequen => vr_nrsequen,
                                pr_cdcritic => 0,
                                pr_dscritic => vr_dscritic,
                                pr_tab_erro => pr_tab_erro);
        END IF;
      END IF;  
    END IF;       
      
    -- Gerar projeção de Convênios
    IF pr_cdremessa in(0,11) AND pr_tpfluxo in(0,4) THEN 
      pc_grava_prj_convenios (pr_cdcooper => pr_cdcooper           -- Codigo da Cooperativa
                             ,pr_dtmvtolt => pr_dtmvtopr           -- Data de movimento
                             ,pr_flghistor => pr_flghistor   -- Flag para utilização da base histórica 
                             ,pr_dscritic => vr_dscritic);

      IF vr_dscritic <> 'OK' THEN
        vr_nrsequen := NVL(pr_tab_erro.COUNT,0)+ 1;
        vr_dscritic := 'Nao foi possivel realizar o calculo dos Convênios - '||pr_cdcooper||'.';

        GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper,
                              pr_cdagenci => pr_cdagenci,
                              pr_nrdcaixa => pr_nrdcaixa,
                              pr_nrsequen => vr_nrsequen,
                              pr_cdcritic => 0,
                              pr_dscritic => vr_dscritic,
                              pr_tab_erro => pr_tab_erro);
      END IF; 
    END IF;  
    
    -- Mvt Conta ITG
    IF pr_cdremessa IN(0,6) THEN 
      IF pr_tpfluxo IN(0,3) THEN
        -- Gravar movimento financeiro das contas Itg - Entrada
        pc_grava_prj_conta_itg (pr_cdcooper => pr_cdcooper           -- Codigo da Cooperativa
                               ,pr_dtmvtolt => pr_dtmvtopr           -- Data de movimento
                               ,pr_tpdmovto => 1                     -- tipo de movimento(1-entrada 2-saida)
                               ,pr_flghistor => pr_flghistor   -- Flag para utilização da base histórica                                
                               ,pr_dscritic => vr_dscritic );

        IF vr_dscritic <> 'OK' THEN
          vr_nrsequen := NVL(pr_tab_erro.COUNT,0)+ 1;
          vr_dscritic := 'Nao foi possivel realizar o calculo do Mov. Conta ITG. - '||pr_cdcooper||'.';

          GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper,
                                pr_cdagenci => pr_cdagenci,
                                pr_nrdcaixa => pr_nrdcaixa,
                                pr_nrsequen => vr_nrsequen,
                                pr_cdcritic => 0,
                                pr_dscritic => vr_dscritic,
                                pr_tab_erro => pr_tab_erro);
        END IF;
      END IF;  

      IF pr_tpfluxo IN(0,4) THEN 
        -- Procedure para gravar movimento financeiro das contas Itg -- Saida
        pc_grava_prj_conta_itg ( pr_cdcooper => pr_cdcooper           -- Codigo da Cooperativa
                                ,pr_dtmvtolt => pr_dtmvtopr           -- Data de movimento
                                ,pr_tpdmovto => 2                     -- tipo de movimento(1-entrada 2-saida)
                                ,pr_flghistor => pr_flghistor   -- Flag para utilização da base histórica 
                                ,pr_dscritic => vr_dscritic );

        IF vr_dscritic <> 'OK' THEN
          vr_nrsequen := NVL(pr_tab_erro.COUNT,0)+ 1;
          vr_dscritic := 'Nao foi possivel realizar o calculo do Mov. Conta ITG. - '||pr_cdcooper||'.';

          GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper,
                                pr_cdagenci => pr_cdagenci,
                                pr_nrdcaixa => pr_nrdcaixa,
                                pr_nrsequen => vr_nrsequen,
                                pr_cdcritic => 0,
                                pr_dscritic => vr_dscritic,
                                pr_tab_erro => pr_tab_erro);
        END IF;
      END IF;  
    END IF;
    
    -- Transf IC
    IF pr_cdremessa in(0,8) THEN 
      
      IF pr_tpfluxo in(0,3) THEN 
        -- Gravar projeção Transferencias IC - Entrada
        pc_grava_prj_transf_ic ( pr_cdcooper => pr_cdcooper           -- Codigo da Cooperativa
                                ,pr_dtmvtolt => pr_dtmvtopr           -- Data de movimento
                                ,pr_tpdmovto => 1                     -- tipo de movimento(1-entrada 2-saida)
                                ,pr_flghistor => pr_flghistor   -- Flag para utilização da base histórica 
                                ,pr_dscritic => vr_dscritic );

        IF vr_dscritic <> 'OK' THEN
          vr_nrsequen := NVL(pr_tab_erro.COUNT,0)+ 1;
          vr_dscritic := 'Nao foi possivel realizar o calculo do Transf IC - '||pr_cdcooper||'.';

          GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper,
                                pr_cdagenci => pr_cdagenci,
                                pr_nrdcaixa => pr_nrdcaixa,
                                pr_nrsequen => vr_nrsequen,
                                pr_cdcritic => 0,
                                pr_dscritic => vr_dscritic,
                                pr_tab_erro => pr_tab_erro);
        END IF;  
      END IF;  
      
      IF pr_tpfluxo IN(0,4) THEN
        -- Gravar projeção Transferencias IC - Saida
        pc_grava_prj_transf_ic (pr_cdcooper => pr_cdcooper           -- Codigo da Cooperativa
                               ,pr_dtmvtolt => pr_dtmvtopr           -- Data de movimento
                               ,pr_tpdmovto => 2                     -- tipo de movimento(1-entrada 2-saida)
                               ,pr_flghistor => pr_flghistor   -- Flag para utilização da base histórica 
                               ,pr_dscritic => vr_dscritic );

        IF vr_dscritic <> 'OK' THEN
          vr_nrsequen := NVL(pr_tab_erro.COUNT,0)+ 1;
          vr_dscritic := 'Nao foi possivel realizar o calculo do Transf IC - '||pr_cdcooper||'.';

          GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper,
                                pr_cdagenci => pr_cdagenci,
                                pr_nrdcaixa => pr_nrdcaixa,
                                pr_nrsequen => vr_nrsequen,
                                pr_cdcritic => 0,
                                pr_dscritic => vr_dscritic,
                                pr_tab_erro => pr_tab_erro);
        END IF;   
      END IF;  
    END IF;
    
    -- Depositos IC
    IF pr_cdremessa IN(0,12) THEN 
    
      IF pr_tpfluxo in(0,3) THEN 
        -- Gravar projeção Depósitos IC - Entrada
        pc_grava_prj_dep_ic (pr_cdcooper => pr_cdcooper           -- Codigo da Cooperativa
                            ,pr_dtmvtolt => pr_dtmvtopr           -- Data de movimento
                            ,pr_tpdmovto => 1                     -- tipo de movimento(1-entrada 2-saida)
                            ,pr_flghistor => pr_flghistor   -- Flag para utilização da base histórica 
                            ,pr_dscritic => vr_dscritic );

        IF vr_dscritic <> 'OK' THEN
          vr_nrsequen := NVL(pr_tab_erro.COUNT,0)+ 1;
          vr_dscritic := 'Nao foi possivel realizar o calculo do DEP IC. - '||pr_cdcooper||'.';

          GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper,
                                pr_cdagenci => pr_cdagenci,
                                pr_nrdcaixa => pr_nrdcaixa,
                                pr_nrsequen => vr_nrsequen,
                                pr_cdcritic => 0,
                                pr_dscritic => vr_dscritic,
                                pr_tab_erro => pr_tab_erro);
        END IF;  
      END IF;
      
      IF pr_tpfluxo IN(0,4) THEN   
        -- Gravar projeção Depositos IC - Saida
        pc_grava_prj_dep_ic (pr_cdcooper => pr_cdcooper           -- Codigo da Cooperativa
                            ,pr_dtmvtolt => pr_dtmvtopr           -- Data de movimento
                            ,pr_tpdmovto => 2                     -- tipo de movimento(1-entrada 2-saida)
                            ,pr_flghistor => pr_flghistor   -- Flag para utilização da base histórica                             
                            ,pr_dscritic => vr_dscritic );

        IF vr_dscritic <> 'OK' THEN
          vr_nrsequen := NVL(pr_tab_erro.COUNT,0)+ 1;
          vr_dscritic := 'Nao foi possivel realizar o calculo do Mov. DEP IC. - '||pr_cdcooper||'.';

          GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper,
                                pr_cdagenci => pr_cdagenci,
                                pr_nrdcaixa => pr_nrdcaixa,
                                pr_nrsequen => vr_nrsequen,
                                pr_cdcritic => 0,
                                pr_dscritic => vr_dscritic,
                                pr_tab_erro => pr_tab_erro);
        END IF;     
      END IF;
    END IF;  
    
    -- INSS / GPS 
    IF pr_cdremessa in(0,7) THEN 
      
      IF pr_tpfluxo IN(0,3) THEN 
        -- Gerar projeção de Benefícios INSS
        pc_grava_prj_inss (pr_cdcooper => pr_cdcooper           -- Codigo da Cooperativa
                          ,pr_dtmvtolt => pr_dtmvtopr           -- Data de movimento
                          ,pr_flghistor => pr_flghistor   -- Flag para utilização da base histórica 
                          ,pr_dscritic => vr_dscritic);

        IF vr_dscritic <> 'OK' THEN
          vr_nrsequen := NVL(pr_tab_erro.COUNT,0)+ 1;
          vr_dscritic := 'Nao foi possivel realizar o calculo dos Benefícios INSS - '||pr_cdcooper||'.';

          GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper,
                                pr_cdagenci => pr_cdagenci,
                                pr_nrdcaixa => pr_nrdcaixa,
                                pr_nrsequen => vr_nrsequen,
                                pr_cdcritic => 0,
                                pr_dscritic => vr_dscritic,
                                pr_tab_erro => pr_tab_erro);
        END IF;    
      END IF;  
      
      IF pr_tpfluxo IN(0,4) THEN 
        -- Gravar projeção GPS
        pc_grava_prj_grps(pr_cdcooper => pr_cdcooper           -- Codigo da Cooperativa
                         ,pr_dtmvtolt => pr_dtmvtopr           -- Data de movimento
                         ,pr_flghistor => pr_flghistor   -- Flag para utilização da base histórica 
                         ,pr_dscritic => vr_dscritic );

        IF vr_dscritic <> 'OK' THEN
          vr_nrsequen := NVL(pr_tab_erro.COUNT,0)+ 1;
          vr_dscritic := 'Nao foi possivel realizar o calculo do Mov. Proj GPS. - '||pr_cdcooper||'.';

          GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper,
                                pr_cdagenci => pr_cdagenci,
                                pr_nrdcaixa => pr_nrdcaixa,
                                pr_nrsequen => vr_nrsequen,
                                pr_cdcritic => 0,
                                pr_dscritic => vr_dscritic,
                                pr_tab_erro => pr_tab_erro);
        END IF;    
      END IF;  
    END IF;
    
    -- Devolução Cheques
    IF pr_cdremessa in(0,5) THEN  
      IF pr_tpfluxo IN(0,3) THEN 
        -- Procedure para gravar movimento financeiro das devoluções de cheques de outros bancos
        pc_grava_prj_dev_cheque_rem (pr_cdcooper => pr_cdcooper           -- Codigo da Cooperativa
                                    ,pr_nmdatela => pr_nmdatela           -- Tela solicitação 
                                    ,pr_dtmvtolt => pr_dtmvtopr           -- Data de movimento
                                    ,pr_dtmvtoan => pr_dtmvtolt           -- Dia anterior
                                    ,pr_flghistor => pr_flghistor   -- Flag para utilização da base histórica 
                                    ,pr_dscritic => vr_dscritic );

        IF vr_dscritic <> 'OK' THEN
          vr_nrsequen := NVL(pr_tab_erro.COUNT,0)+ 1;
          vr_dscritic := 'Nao foi possivel realizar o calculo da Dev Cheques Remetidos. - '||pr_cdcooper||'.';

          GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper,
                                pr_cdagenci => pr_cdagenci,
                                pr_nrdcaixa => pr_nrdcaixa,
                                pr_nrsequen => vr_nrsequen,
                                pr_cdcritic => 0,
                                pr_dscritic => vr_dscritic,
                                pr_tab_erro => pr_tab_erro);
        END IF;          
      END IF;
      
      IF pr_tpfluxo IN(0,4) THEN 
        -- Gravar movimento financeiro das devoluções de cheques de outros bancos
        pc_grava_prj_dev_cheque_rec(pr_cdcooper => pr_cdcooper      -- Codigo da Cooperativa
                                   ,pr_nmdatela => pr_nmdatela           -- Tela solicitação 
                                   ,pr_dtmvtolt => pr_dtmvtopr     -- Data de movimento
                                   ,pr_dtmvtoan => pr_dtmvtolt     -- Data de movimento anterior
                                   ,pr_flghistor => pr_flghistor   -- Flag para utilização da base histórica 
                                   ,pr_dscritic => vr_dscritic);

        IF vr_dscritic <> 'OK' THEN
          vr_nrsequen := NVL(pr_tab_erro.COUNT,0)+ 1;
          vr_dscritic := 'Calculo de devolucao de cheques recebidos nao foi efetuado - '||pr_cdcooper||'.';

          GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper,
                                pr_cdagenci => pr_cdagenci,
                                pr_nrdcaixa => pr_nrdcaixa,
                                pr_nrsequen => vr_nrsequen,
                                pr_cdcritic => 0,
                                pr_dscritic => vr_dscritic,
                                pr_tab_erro => pr_tab_erro);
        END IF;     
      END IF;
    END IF;
    
    -- Saques TAA
    IF pr_cdremessa in(0,9) THEN
      IF pr_tpfluxo IN (0,3) THEN    
        -- gravar movimento financeiro referente aos saques no TAA das intercoop
        pc_grava_prj_saq_taa_ic(pr_cdcooper  => pr_cdcooper     -- Codigo da Cooperativa
                               ,pr_dtmvtolt  => pr_dtmvtopr     -- Data de movimento
                               ,pr_tpdmovto  => 1               -- Tipo de movimento (1-Entrada 2-saida)
                               ,pr_flghistor => pr_flghistor   -- Flag para utilização da base histórica 
                               ,pr_dscritic  => vr_dscritic);

        IF vr_dscritic <> 'OK' THEN
          vr_nrsequen := NVL(pr_tab_erro.COUNT,0)+ 1;
          vr_dscritic := 'Calculo do Saque TAA Interc. Projetado nao foi efetuado - '||pr_cdcooper||'.';

          GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper,
                                pr_cdagenci => pr_cdagenci,
                                pr_nrdcaixa => pr_nrdcaixa,
                                pr_nrsequen => vr_nrsequen,
                                pr_cdcritic => 0,
                                pr_dscritic => vr_dscritic,
                                pr_tab_erro => pr_tab_erro);
        END IF;                
      END IF;  
    
      IF pr_tpfluxo IN (0,4) THEN    
        -- gravar movimento financeiro referente aos saques no TAA das intercoop
        pc_grava_prj_saq_taa_ic(pr_cdcooper  => pr_cdcooper     -- Codigo da Cooperativa
                               ,pr_dtmvtolt  => pr_dtmvtopr     -- Data de movimento
                               ,pr_tpdmovto  => 2               -- Tipo de movimento (1-Entrada 2-saida)
                               ,pr_flghistor => pr_flghistor   -- Flag para utilização da base histórica 
                               ,pr_dscritic  => vr_dscritic);

        IF vr_dscritic <> 'OK' THEN
          vr_nrsequen := NVL(pr_tab_erro.COUNT,0)+ 1;
          vr_dscritic := 'Calculo do Saque TAA Interc. Projetado nao foi efetuado - '||pr_cdcooper||'.';

          GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper,
                                pr_cdagenci => pr_cdagenci,
                                pr_nrdcaixa => pr_nrdcaixa,
                                pr_nrsequen => vr_nrsequen,
                                pr_cdcritic => 0,
                                pr_dscritic => vr_dscritic,
                                pr_tab_erro => pr_tab_erro);
        END IF;
      END IF;  
    END IF;      
    
    -- Recolhimento e Suprimentos numerários
    IF pr_cdremessa in(0,13) THEN
      -- Gravar movimento financeiro de Projetado de Recolhimento Numerário
      IF pr_tpfluxo IN (0,3) THEN     
        pc_grava_prj_recol_numerario(pr_cdcooper  => pr_cdcooper     -- Codigo da Cooperativa
                                    ,pr_dtmvtolt  => pr_dtmvtopr     -- Data de movimento
                                    ,pr_flghistor => pr_flghistor   -- Flag para utilização da base histórica 
                                    ,pr_dscritic  => vr_dscritic);
        IF vr_dscritic <> 'OK' THEN
          vr_nrsequen := NVL(pr_tab_erro.COUNT,0)+ 1;
          vr_dscritic := 'Calculo do Recolhimento Numerário Projetado nao foi efetuado - '||pr_cdcooper||'.';

          GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper,
                                pr_cdagenci => pr_cdagenci,
                                pr_nrdcaixa => pr_nrdcaixa,
                                pr_nrsequen => vr_nrsequen,
                                pr_cdcritic => 0,
                                pr_dscritic => vr_dscritic,
                                pr_tab_erro => pr_tab_erro);
        END IF;
      END IF;  
      
      -- Gravar movimento financeiro de Projetado de Suprimento Numerário
      IF pr_tpfluxo IN (0,4) THEN     
        pc_grava_prj_suprim_numerario(pr_cdcooper  => pr_cdcooper     -- Codigo da Cooperativa
                                     ,pr_dtmvtolt  => pr_dtmvtopr     -- Data de movimento
                                     ,pr_flghistor => pr_flghistor   -- Flag para utilização da base histórica 
                                     ,pr_dscritic  => vr_dscritic);
        IF vr_dscritic <> 'OK' THEN
          vr_nrsequen := NVL(pr_tab_erro.COUNT,0)+ 1;
          vr_dscritic := 'Calculo do Suprimento Numerário Projetado nao foi efetuado - '||pr_cdcooper||'.';

          GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper,
                                pr_cdagenci => pr_cdagenci,
                                pr_nrdcaixa => pr_nrdcaixa,
                                pr_nrsequen => vr_nrsequen,
                                pr_cdcritic => 0,
                                pr_dscritic => vr_dscritic,
                                pr_tab_erro => pr_tab_erro);
        END IF;  
      END IF;  
    END IF;
    
    -- Gravar movimento projetado financeiro das faturas do Cartão de Crédito
    IF pr_cdremessa in(0,10) AND pr_tpfluxo IN (0,4) THEN 
      pc_grava_prj_fatura_cart_credi(pr_cdcooper => pr_cdcooper     -- Codigo da Cooperativa
                                    ,pr_dtmvtolt => pr_dtmvtopr     -- Data de movimento
                                    ,pr_flghistor => pr_flghistor   -- Flag para utilização da base histórica 
                                    ,pr_dscritic => vr_dscritic);

      IF vr_dscritic <> 'OK' THEN
        vr_nrsequen := NVL(pr_tab_erro.COUNT,0)+ 1;
        vr_dscritic := 'Calculo projetado das faturas do cartão de crédito nao foi efetuado - '||pr_cdcooper||'.';

        GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper,
                              pr_cdagenci => pr_cdagenci,
                              pr_nrdcaixa => pr_nrdcaixa,
                              pr_nrsequen => vr_nrsequen,
                              pr_cdcritic => 0,
                              pr_dscritic => vr_dscritic,
                              pr_tab_erro => pr_tab_erro);
      END IF;
    END IF;  
    
    -- Procedure para gravar projeção movimento financeiro dos debitos de cartao de debito
    IF pr_cdremessa in(0,14) AND pr_tpfluxo IN (0,4) THEN 
      pc_grava_prj_cart_debito (pr_cdcooper => pr_cdcooper           -- Codigo da Cooperativa
                               ,pr_dtmvtolt => pr_dtmvtopr           -- Data de movimento
                               ,pr_flghistor => pr_flghistor   -- Flag para utilização da base histórica 
                               ,pr_dscritic => vr_dscritic );

      IF vr_dscritic <> 'OK' THEN
        vr_nrsequen := NVL(pr_tab_erro.COUNT,0)+ 1;
        vr_dscritic := 'Nao foi possivel realizar o calculo do Mov. Proj Cartão Débito. - '||pr_cdcooper||'.';

        GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper,
                              pr_cdagenci => pr_cdagenci,
                              pr_nrdcaixa => pr_nrdcaixa,
                              pr_nrsequen => vr_nrsequen,
                              pr_cdcritic => 0,
                              pr_dscritic => vr_dscritic,
                              pr_tab_erro => pr_tab_erro);
      END IF;    
    END IF;      
    
    pr_dscritic := 'OK';

  END pc_grava_fluxo_projetado;  

  -- Procedure para gravar Informacoes do fluxo financeiro consolidado de entrada ou saida
  PROCEDURE pc_gera_consolidado_singular (pr_cdcooper  IN INTEGER      -- Codigo da Cooperativa
                                         ,pr_dtmvtolt  IN DATE         -- Data de movimento
                                         ,pr_cdoperad  IN VARCHAR2     -- Codigo do operador
                                         ,pr_dscritic OUT VARCHAR2) AS -- Descrição da critica

    -- .........................................................................
    --
    --  Programa : pc_gera_consolidado_singular          Antigo: b1wgen0131.p/pi_grava_consolidado_singular_saida_f
    --                                                                         pi_grava_consolidado_singular_entrada_f
    --
    --  Sistema  : Cred
    --  Sigla    : FLXF0001
    --  Autor    : Odirlei Busana
    --  Data     : novembro/2013.                   Ultima atualizacao: 11/10/2016
    --
    --  Dados referentes ao programa:
    --
    --   Objetivo  : Gravar Informacoes do fluxo financeiro consolidado de entrada ou saida
    --
    --   Atualizacao: 20/11/2013 - Conversao Progress => Oracle (Odirlei-AMcom)
    --
    --                11/10/2016 - P313 - Alimentação de novas informações do Fluxo de Caixa 
    --                             (Marcos-Supero)
    --..........................................................................
    
    -- Busca do Fluxo do dia de Entrada
    CURSOR cr_entradas IS
      SELECT cdbccxlt
            ,max(decode(flxf0001.fn_tpfluxo_remessa(1,'E'),tpdmovto,vlcheque,0)) vlcheque
            ,max(decode(flxf0001.fn_tpfluxo_remessa(2,'E'),tpdmovto,vltotdoc,0)) vltotdoc
            ,max(decode(flxf0001.fn_tpfluxo_remessa(3,'E'),tpdmovto,vltotted,0)) vltotted
            ,max(decode(flxf0001.fn_tpfluxo_remessa(4,'E'),tpdmovto,vltottit,0)) vltottit
            ,max(decode(flxf0001.fn_tpfluxo_remessa(5,'E'),tpdmovto,vldevolu,0)) vldevolu
            ,max(decode(flxf0001.fn_tpfluxo_remessa(6,'E'),tpdmovto,vlmvtitg,0)) vlmvtitg
            ,max(decode(flxf0001.fn_tpfluxo_remessa(7,'E'),tpdmovto,vlttinss,0)) vlttinss
            ,max(decode(flxf0001.fn_tpfluxo_remessa(8,'E'),tpdmovto,vltrfitc,0)) vltrfitc
            ,max(decode(flxf0001.fn_tpfluxo_remessa(9,'E'),tpdmovto,vlsatait,0)) vlsatait
            ,max(decode(flxf0001.fn_tpfluxo_remessa(10,'E'),tpdmovto,vlcarcre,0)) vlcarcre
            ,max(decode(flxf0001.fn_tpfluxo_remessa(11,'E'),tpdmovto,vlconven,0)) vlconven
            ,max(decode(flxf0001.fn_tpfluxo_remessa(12,'E'),tpdmovto,vldepitc,0)) vldepitc
            ,max(decode(flxf0001.fn_tpfluxo_remessa(13,'E'),tpdmovto,vlnumera,0)) vlnumera
            ,max(decode(flxf0001.fn_tpfluxo_remessa(14,'E'),tpdmovto,vlcardeb,0)) vlcardeb
        FROM crapffm
       WHERE cdcooper = pr_cdcooper
         AND dtmvtolt = pr_dtmvtolt
         AND tpdmovto IN(1,3) -- Entrada Realizado e Projetado
         AND cdbccxlt IN(1,85,756,748) -- BB, Cecred, Bancoob e Sicredi
       GROUP BY cdbccxlt;   
       
    -- Busca do Fluxo do dia de Saida
    CURSOR cr_saidas IS
      SELECT cdbccxlt
            ,max(decode(flxf0001.fn_tpfluxo_remessa(1,'S'),tpdmovto,vlcheque,0)) vlcheque
            ,max(decode(flxf0001.fn_tpfluxo_remessa(2,'S'),tpdmovto,vltotdoc,0)) vltotdoc
            ,max(decode(flxf0001.fn_tpfluxo_remessa(3,'S'),tpdmovto,vltotted,0)) vltotted
            ,max(decode(flxf0001.fn_tpfluxo_remessa(4,'S'),tpdmovto,vltottit,0)) vltottit
            ,max(decode(flxf0001.fn_tpfluxo_remessa(5,'S'),tpdmovto,vldevolu,0)) vldevolu
            ,max(decode(flxf0001.fn_tpfluxo_remessa(6,'S'),tpdmovto,vlmvtitg,0)) vlmvtitg
            ,max(decode(flxf0001.fn_tpfluxo_remessa(7,'S'),tpdmovto,vlttinss,0)) vlttinss
            ,max(decode(flxf0001.fn_tpfluxo_remessa(8,'S'),tpdmovto,vltrfitc,0)) vltrfitc
            ,max(decode(flxf0001.fn_tpfluxo_remessa(9,'S'),tpdmovto,vlsatait,0)) vlsatait
            ,max(decode(flxf0001.fn_tpfluxo_remessa(10,'S'),tpdmovto,vlcarcre,0)) vlcarcre
            ,max(decode(flxf0001.fn_tpfluxo_remessa(11,'S'),tpdmovto,vlconven,0)) vlconven
            ,max(decode(flxf0001.fn_tpfluxo_remessa(12,'S'),tpdmovto,vldepitc,0)) vldepitc
            ,max(decode(flxf0001.fn_tpfluxo_remessa(13,'S'),tpdmovto,vlnumera,0)) vlnumera
            ,max(decode(flxf0001.fn_tpfluxo_remessa(14,'S'),tpdmovto,vlcardeb,0)) vlcardeb
        FROM crapffm
       WHERE cdcooper = pr_cdcooper
         AND dtmvtolt = pr_dtmvtolt
         AND tpdmovto IN(2,4) -- Saída Realizado e Saida Projetado
         AND cdbccxlt IN(1,85,756,748) -- BB, Cecred, Bancoob e Sicredi
       GROUP BY cdbccxlt;         
        
    -- Valor total   
    vr_vlregis NUMBER;
    vr_vltotal NUMBER;

  BEGIN
    -- Buscar valores de entrada
    vr_vltotal := 0;
    vr_vlregis := 0;
    FOR rw_entradas IN cr_entradas LOOP
      -- Somar todas as entradas 
      vr_vlregis := rw_entradas.vlcheque + rw_entradas.vltotdoc + rw_entradas.vltotted
                  + rw_entradas.vltottit + rw_entradas.vldevolu + rw_entradas.vlmvtitg
                  + rw_entradas.vlttinss + rw_entradas.vltrfitc + rw_entradas.vlsatait
                  + rw_entradas.vlcarcre + rw_entradas.vlconven + rw_entradas.vldepitc
                  + rw_entradas.vlnumera + rw_entradas.vlcardeb;
      -- Efetuar gravação por IF
      pc_grava_consolidado_singular
                             (pr_cdcooper => pr_cdcooper          -- Codigo da Cooperativa
                             ,pr_cdbccxlt => rw_entradas.cdbccxlt -- Instituição
                             ,pr_dtmvtolt => pr_dtmvtolt          -- Data de movimento
                             ,pr_tpdcampo => 1             -- Tipo de campo 1 - Entradas
                             ,pr_vldcampo => vr_vlregis    -- Valor do campo
                             ,pr_cdoperad => pr_cdoperad   -- Operador
                             ,pr_dscritic => pr_dscritic); -- Descrição da critica
      IF pr_dscritic <> 'OK' THEN
        RETURN;
      END IF;      
      -- Acumular para gravar o consolidado geral
      vr_vltotal := vr_vltotal + vr_vlregis;
    END LOOP;
    -- Efetuar gravação total
    pc_grava_consolidado_singular
                           (pr_cdcooper => pr_cdcooper          -- Codigo da Cooperativa
                           ,pr_cdbccxlt => 0                    -- Instituição (todas)
                           ,pr_dtmvtolt => pr_dtmvtolt          -- Data de movimento
                           ,pr_tpdcampo => 1             -- Tipo de campo 1 - Entradas
                           ,pr_vldcampo => vr_vltotal    -- Valor do campo
                           ,pr_cdoperad => pr_cdoperad   -- Operador                                    
                           ,pr_dscritic => pr_dscritic); -- Descrição da critica
    IF pr_dscritic <> 'OK' THEN
      RETURN;
    END IF;      
    
    -- Buscar valores de saida
    vr_vltotal := 0;
    vr_vlregis := 0;
    FOR rw_saidas IN cr_saidas LOOP
      -- Somar todas as entradas 
      vr_vlregis := rw_saidas.vlcheque + rw_saidas.vltotdoc + rw_saidas.vltotted
                  + rw_saidas.vltottit + rw_saidas.vldevolu + rw_saidas.vlmvtitg
                  + rw_saidas.vlttinss + rw_saidas.vltrfitc + rw_saidas.vlsatait
                  + rw_saidas.vlcarcre + rw_saidas.vlconven + rw_saidas.vldepitc
                  + rw_saidas.vlnumera + rw_saidas.vlcardeb;
      -- Efetuar gravação por IF
      pc_grava_consolidado_singular
                             (pr_cdcooper => pr_cdcooper        -- Codigo da Cooperativa
                             ,pr_cdbccxlt => rw_saidas.cdbccxlt -- Instituição
                             ,pr_dtmvtolt => pr_dtmvtolt        -- Data de movimento
                             ,pr_tpdcampo => 2             -- Tipo de campo 2 - Saídas
                             ,pr_vldcampo => vr_vlregis    -- Valor do campo
                             ,pr_cdoperad => pr_cdoperad   -- Operador                                      
                             ,pr_dscritic => pr_dscritic); -- Descrição da critica
      IF pr_dscritic <> 'OK' THEN
        RETURN;
      END IF;      
      -- Acumular para gravar o consolidado geral
      vr_vltotal := vr_vltotal + vr_vlregis;
    END LOOP;
    -- Efetuar gravação total
    pc_grava_consolidado_singular
                           (pr_cdcooper => pr_cdcooper          -- Codigo da Cooperativa
                           ,pr_cdbccxlt => 0                    -- Instituição (todas)
                           ,pr_dtmvtolt => pr_dtmvtolt          -- Data de movimento
                           ,pr_tpdcampo => 2             -- Tipo de campo 2 - Saidas
                           ,pr_vldcampo => vr_vltotal    -- Valor do campo
                           ,pr_cdoperad => pr_cdoperad   -- Operador                                    
                           ,pr_dscritic => pr_dscritic); -- Descrição da critica
    IF pr_dscritic <> 'OK' THEN
      RETURN;
    END IF;

    pr_dscritic := 'OK';

  EXCEPTION
    WHEN OTHERS THEN
      pr_dscritic := 'Erro na FLXF0001.pc_gera_consolidado_singular: '||SQLerrm;
  END pc_gera_consolidado_singular;

  -- Procedure para gravar movimento do fluxo financeiro
  PROCEDURE pc_grava_fluxo_financeiro ( pr_cdcooper  IN INTEGER      -- Codigo da Cooperativa
                                       ,pr_cdagenci  IN INTEGER      -- Codigo da agencia
                                       ,pr_nrdcaixa  IN INTEGER      -- Numero da caixa
                                       ,pr_cdoperad  IN crapope.cdoperad%type     -- Codigo do operador
                                       ,pr_dtmvtolt  IN DATE         -- Data de movimento
                                       ,pr_cdprogra  IN VARCHAR2     -- Nome da tela
                                       ,pr_dtmvtoan  IN DATE         -- Data de movimento anterior
                                       ,pr_dtmvtopr  IN DATE         -- Data do próximo dia util
                                       ,pr_cdremessa IN NUMBER DEFAULT 0 -- Tipo da remessa (0 para todas)
                                       ,pr_tpfluxo   IN NUMBER DEFAULT 0 -- TIpo do fluxo (0 para todos)
                                       ,pr_flghistor IN BOOLEAN DEFAULT FALSE -- Flag para utilização da base histórica 
                                       ,pr_tab_erro OUT GENE0001.typ_tab_erro -- Tabela contendo os erros
                                       ,pr_dscritic OUT VARCHAR2) AS -- Descrição da critica

    -- .........................................................................
    --
    --  Programa : pc_grava_fluxo_financeiro   Antigo: b1wgen0131.p/grava-fluxo-financeiro
    --
    --
    --  Sistema  : Cred
    --  Sigla    : FLXF0001
    --  Autor    : Odirlei Busana
    --  Data     : novembro/2013.                   Ultima atualizacao: 26/11/2013
    --
    --  Dados referentes ao programa:
    --
    --   Objetivo  : Gravar movimento do fluxo financeiro
    -- 
    --   Parametros : pr_cdremessa -> Conforme CDremessa da tabela TBFIN_REMESSA_FLUXO_FINAN (0 - Todas)
    --                               
    --                pr_tpfluxo   -> 0 para todos
    --                                1 - Entrada Realizado
    --                                2 - Saida Realizado
    --                                3 - Entrada Projetado
    --                                4 - Saida Projetado       
    --  
    --   Atualizacao: 26/11/2013 - Conversao Progress => Oracle (Odirlei-AMcom)
    --..........................................................................

    vr_exc_erro      EXCEPTION;
    vr_dscritic      VARCHAR2(4000) ;
    vr_nrsequen      NUMBER;

  BEGIN
    
    -- Gravar movimento financeiro do fluxo de entrada
    IF pr_tpfluxo IN(1,0) THEN 
      pc_grava_fluxo_entrada (pr_cdcooper => pr_cdcooper     -- Codigo da Cooperativa
                             ,pr_cdagenci => pr_cdagenci     -- Codigo da agencia
                             ,pr_nrdcaixa => pr_nrdcaixa     -- Numero da caixa
                             ,pr_dtmvtolt => pr_dtmvtolt     -- Data de movimento
                             ,pr_nmdatela => pr_cdprogra     -- Nome da tela
                             ,pr_dtmvtoan => pr_dtmvtoan     -- Data de movimento anterior
                             ,pr_tab_erro => pr_tab_erro     -- Tabela contendo os erros
                             ,pr_cdremessa => pr_cdremessa   -- Tipo da remessa (0 para todas)
                             ,pr_dscritic => vr_dscritic);

      IF vr_dscritic <> 'OK' THEN
        vr_nrsequen := NVL(pr_tab_erro.COUNT,0)+ 1;
        vr_dscritic := 'Calculo do fluxo de entrada nao foi efetuado planamente - '||pr_cdcooper||'.';

        GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper,
                              pr_cdagenci => pr_cdagenci,
                              pr_nrdcaixa => pr_nrdcaixa,
                              pr_nrsequen => vr_nrsequen,
                              pr_cdcritic => 0,
                              pr_dscritic => vr_dscritic,
                              pr_tab_erro => pr_tab_erro);
      END IF;
    END IF;
    
    -- Gravar movimento financeiro do fluxo de saida
    IF pr_tpfluxo IN(2,0) THEN     
      pc_grava_fluxo_saida ( pr_cdcooper => pr_cdcooper     -- Codigo da Cooperativa
                            ,pr_cdagenci => pr_cdagenci     -- Codigo da agencia
                            ,pr_nrdcaixa => pr_nrdcaixa     -- Numero da caixa
                            ,pr_dtmvtolt => pr_dtmvtolt     -- Data de movimento
                            ,pr_dtmvtoan => pr_dtmvtoan     -- Data de movimento anterior
                            ,pr_cdremessa => pr_cdremessa   -- Tipo da remessa (0 para todas)
                            ,pr_tab_erro => pr_tab_erro     -- Tabela contendo os erros
                            ,pr_dscritic => vr_dscritic);

      IF vr_dscritic <> 'OK' THEN
        vr_nrsequen := NVL(pr_tab_erro.COUNT,0)+ 1;
        vr_dscritic := 'Calculo do fluxo de saida nao foi efetuado plenamente - '||pr_cdcooper||'.';

        GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper,
                              pr_cdagenci => pr_cdagenci,
                              pr_nrdcaixa => pr_nrdcaixa,
                              pr_nrsequen => vr_nrsequen,
                              pr_cdcritic => 0,
                              pr_dscritic => vr_dscritic,
                              pr_tab_erro => pr_tab_erro);
      END IF;
    END IF;  
    
    -- Projeção será executada somente fora da tela
    IF pr_cdprogra NOT IN('FLUXOS','FLUXOD') THEN
      
      -- Gerar a projeção do próximo dia util
      IF pr_tpfluxo IN(3,4,0) THEN  
        
        -- Gravar movimento financeiro do fluxo Projetado
        pc_grava_fluxo_projetado (pr_cdcooper  => pr_cdcooper     -- Codigo da Cooperativa
                                 ,pr_cdagenci  => pr_cdagenci     -- Codigo da agencia
                                 ,pr_nrdcaixa  => pr_nrdcaixa     -- Numero da caixa
                                 ,pr_nmdatela  => pr_cdprogra     -- Nome da tela em execução 
                                 ,pr_dtmvtolt  => pr_dtmvtolt     -- Data do movimento atual
                                 ,pr_dtmvtopr  => pr_dtmvtopr     -- Data de movimento próximo
                                 ,pr_cdremessa => pr_cdremessa    -- Tipo da remessa (0 para todas)
                                 ,pr_tpfluxo   => pr_tpfluxo      -- TIpo do fluxo (0 para todos)
                                 ,pr_flghistor => pr_flghistor    -- Flag para utilização da base histórica 
                                 ,pr_tab_erro  => pr_tab_erro     -- Tabela contendo os erros
                                 ,pr_dscritic  => vr_dscritic);

        IF vr_dscritic <> 'OK' THEN
          vr_nrsequen := NVL(pr_tab_erro.COUNT,0)+ 1;
          vr_dscritic := 'Calculo do fluxo de Projeção nao foi efetuado plenamente - '||pr_cdcooper||'.';

          GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper,
                                pr_cdagenci => pr_cdagenci,
                                pr_nrdcaixa => pr_nrdcaixa,
                                pr_nrsequen => vr_nrsequen,
                                pr_cdcritic => 0,
                                pr_dscritic => vr_dscritic,
                                pr_tab_erro => pr_tab_erro);
        END IF;
      END IF;
    END IF;  
    
    -- Somente quando a execução é efetuada no processo ou através do fluxo do dia
    IF pr_cdprogra IN('CRPS624','FLUXOD') THEN   
      -- Gravar Informacoes do fluxo financeiro consolidado da Cooperativa para o dia do processo
      pc_gera_consolidado_singular( pr_cdcooper => pr_cdcooper     -- Codigo da Cooperativa
                                   ,pr_cdoperad => pr_cdoperad     -- Codigo do operador
                                   ,pr_dtmvtolt => pr_dtmvtolt     -- Data de movimento
                                   ,pr_dscritic => vr_dscritic);

      IF vr_dscritic <> 'OK' THEN
        vr_nrsequen := NVL(pr_tab_erro.COUNT,0)+ 1;
        vr_dscritic := 'Calculo das entradas/saidas nao foi efetuado - '||pr_cdcooper||'.';

        GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper,
                              pr_cdagenci => pr_cdagenci,
                              pr_nrdcaixa => pr_nrdcaixa,
                              pr_nrsequen => vr_nrsequen,
                              pr_cdcritic => 0,
                              pr_dscritic => vr_dscritic,
                              pr_tab_erro => pr_tab_erro);
      END IF;
    
      -- Gravar movimento financeiro consolidado do saldo do dia anterior
      pc_saldo_consolid_dia_ant(pr_cdcooper => pr_cdcooper   -- Codigo da Cooperativa
                               ,pr_cdoperad => pr_cdoperad   -- Codigo do operador
                               ,pr_dscritic => vr_dscritic);

      IF vr_dscritic <> 'OK' THEN
        vr_nrsequen := NVL(pr_tab_erro.COUNT,0)+ 1;
        vr_dscritic := 'Calculo do saldo do dia anterior nao foi efetuado - '||pr_cdcooper||'.';

        GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper,
                              pr_cdagenci => pr_cdagenci,
                              pr_nrdcaixa => pr_nrdcaixa,
                              pr_nrsequen => vr_nrsequen,
                              pr_cdcritic => 0,
                              pr_dscritic => vr_dscritic,
                              pr_tab_erro => pr_tab_erro);
      END IF;
        
    END IF;   
    
    pr_dscritic := 'OK';

  END pc_grava_fluxo_financeiro;
  
  -- Procedure para atualizar previsão futura 12 meses com base no dia anterior
  PROCEDURE pc_atualiza_projecao12m AS
    -- .........................................................................
    --
    --  Programa : pc_atualiza_projecao12m
    --
    --
    --  Sistema  : Cred
    --  Sigla    : FLXF0001
    --  Autor    : Marcos Martini
    --  Data     : novembro/2016                   Ultima atualizacao: 
    --
    --  Dados referentes ao programa:
    --
    --   Objetivo  : Atualizar projeção do mesmo dia anterior nos próximos 12 m
    --
    --   Atualizacao: 
    --..........................................................................
    
    -- Controle de erro
    vr_dscritic VARCHAR2(1000);
    vr_tab_erro gene0001.typ_tab_erro;
    vr_cdprogra VARCHAR2(100) := 'JOBFLX';
    
    -- Datas para processamento 
    vr_dtmvtolt DATE; 
    vr_dtmvtoan date;
    vr_dtmvtopr date;
    rw_crapdat btch0001.cr_crapdat%ROWTYPE;
    
    -- Cooperativas para processamento
    CURSOR cr_crapcop IS 
      SELECT cdcooper
        FROM crapcop 
       WHERE cdcooper <> 3
         AND flgativo = 1;
  BEGIN 
    -- Buscar data atual 
    OPEN btch0001.cr_crapdat(3);
    FETCH btch0001.cr_crapdat
     INTO rw_crapdat;
    CLOSE btch0001.cr_crapdat;
    
    -- Somente continuar se estivermos em execução no dia atual 
    IF trunc(SYSDATE) = rw_crapdat.dtmvtolt THEN  
      
      -- Iniciaremos com o dia anterior 
      vr_dtmvtopr  := rw_crapdat.dtmvtoan;  
      
      -- Atualizar LOG 
      btch0001.pc_gera_log_batch(pr_cdcooper     => 3
                                ,pr_ind_tipo_log => 1 -- apenas log
                                ,pr_nmarqlog     => 'fluxos'
                                ,pr_des_log      => to_char(rw_crapdat.dtmvtolt,'DD/MM/RRRR') ||' '||to_char(sysdate,'hh24:mi:ss')||
                                                    ' --> Iniciando atualizacao de projecao dos proximos 12 meses '||
                                                    'com base no dia '||TO_char(vr_dtmvtopr,'dd/mm/rrrr'));
      
    
      -- Iremos atualizar os próximos 12 meses
      FOR rw_mes IN 1..12 LOOP 
        -- Adicionar 1 mês
        vr_dtmvtopr := add_months(vr_dtmvtopr,1);
        -- Somente processar se o dia no próximo mês for o mesmo
        -- ou seja, o dia 31 só será atualizados em meses com 31 dias
        IF to_char(vr_dtmvtopr,'dd') = to_char(rw_crapdat.dtmvtoan,'dd') THEN
          -- Calcular dia atual e o anterior
          vr_dtmvtolt := gene0005.fn_valida_dia_util(3,vr_dtmvtopr-1,'A');
          vr_dtmvtoan := gene0005.fn_valida_dia_util(3,vr_dtmvtolt-1,'A');
          -- BUscar todas as coops com fluxo financeiro
          for rw_cop in cr_crapcop loop 
            -- Gravar movimento financeiro 
            FLXF0001.pc_grava_fluxo_financeiro(pr_cdcooper  => rw_cop.cdcooper -- Codigo da Cooperativa
                                              ,pr_cdagenci  => 0               -- Codigo da agencia
                                              ,pr_nrdcaixa  => 0               -- Numero da caixa
                                              ,pr_cdoperad  => '1'             -- Codigo do operador
                                              ,pr_dtmvtolt  => vr_dtmvtolt     -- Data de movimento
                                              ,pr_cdprogra  => vr_cdprogra     -- Nome da tela
                                              ,pr_dtmvtoan  => vr_dtmvtoan     -- Data de movimento anterior
                                              ,pr_dtmvtopr  => vr_dtmvtopr     -- Data do próximo dia util
                                              ,pr_cdremessa => 0               -- Tipo da remessa (0 para todas)
                                              ,pr_tpfluxo   => 3               -- TIpo do fluxo (0 para todos)
                                              ,pr_tab_erro => vr_tab_erro      -- Tabela contendo os erros
                                              ,pr_dscritic => vr_dscritic);    -- Descrição da critica
            -- Se houver erro
            IF vr_dscritic IS NOT NULL THEN 
              -- Adicionar ao LOG 
              btch0001.pc_gera_log_batch(pr_cdcooper     => 3
                                        ,pr_ind_tipo_log => 1 -- apenas log
                                        ,pr_nmarqlog     => 'fluxos'
                                        ,pr_des_log      => to_char(rw_crapdat.dtmvtolt,'DD/MM/RRRR') ||' '||to_char(sysdate,'hh24:mi:ss')||
                                                                  ' --> Erro na atualizacao de entrada projecao Coop: '||rw_cop.cdcooper||', Data: '||vr_dtmvtopr||'. Erro --> '||vr_dscritic);
            END IF;
            -- Gravar movimento financeiro dos Credito transferencia/tec salario intercooperativo
            FLXF0001.pc_grava_fluxo_financeiro(pr_cdcooper  => rw_cop.cdcooper -- Codigo da Cooperativa
                                              ,pr_cdagenci  => 0               -- Codigo da agencia
                                              ,pr_nrdcaixa  => 0               -- Numero da caixa
                                              ,pr_cdoperad  => '1'             -- Codigo do operador
                                              ,pr_dtmvtolt  => vr_dtmvtolt     -- Data de movimento
                                              ,pr_cdprogra  => vr_cdprogra     -- Nome da tela
                                              ,pr_dtmvtoan  => vr_dtmvtoan     -- Data de movimento anterior
                                              ,pr_dtmvtopr  => vr_dtmvtopr     -- Data do próximo dia util
                                              ,pr_cdremessa => 0               -- Tipo da remessa (0 para todas)
                                              ,pr_tpfluxo   => 4               -- TIpo do fluxo (0 para todos)
                                              ,pr_tab_erro => vr_tab_erro      -- Tabela contendo os erros
                                              ,pr_dscritic => vr_dscritic);    -- Descrição da critica                                          
            -- Se houver erro
            IF vr_dscritic IS NOT NULL THEN 
              -- Adicionar ao LOG 
              btch0001.pc_gera_log_batch(pr_cdcooper     => 3
                                        ,pr_ind_tipo_log => 1 -- apenas log
                                        ,pr_nmarqlog     => 'fluxos'
                                        ,pr_des_log      => to_char(rw_crapdat.dtmvtolt,'DD/MM/RRRR') ||' '||to_char(sysdate,'hh24:mi:ss')||
                                                                  ' --> Erro na atualizacao de saida projecao Coop: '||rw_cop.cdcooper||', Data: '||vr_dtmvtopr||'. Erro --> '||vr_dscritic);
            END IF;
          end loop;
          -- GRavação a cada iteração 
          COMMIT;
        END IF; -- Somente se estiver no mesmo dia 
      END LOOP; -- FIm laço 12 iterações 
      -- Finalização no LOG
      btch0001.pc_gera_log_batch(pr_cdcooper     => 3
                                ,pr_ind_tipo_log => 1 -- apenas log
                                ,pr_nmarqlog     => 'fluxos'
                                ,pr_des_log      => to_char(rw_crapdat.dtmvtolt,'DD/MM/RRRR') ||' '||to_char(sysdate,'hh24:mi:ss')||
                                                    ' --> atualizacao de projecao dos proximos 12 meses encerrada! ');
    END IF; -- Execução no dia atual 
    
  EXCEPTION
    WHEN OTHERS THEN 
      btch0001.pc_gera_log_batch(pr_cdcooper     => 3
                                ,pr_ind_tipo_log => 1 -- apenas log
                                ,pr_nmarqlog     => 'fluxos'
                                ,pr_des_log      => to_char(rw_crapdat.dtmvtolt,'DD/MM/RRRR') ||' '||to_char(sysdate,'hh24:mi:ss')||
                                                    ' --> Erro nao tratado na projecao dos proximos 12 meses: '||SQLERRM);      
  END;  

END FLXF0001;
/
