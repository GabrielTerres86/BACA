CREATE OR REPLACE PACKAGE CECRED.CXON0041 AS

/*..............................................................................

   Programa: CXON0041                        Antigo: dbo/b1crap41.p
   Sistema : Caixa On-line
   Sigla   : CRED
   Autor   : Lucas Lunelli
   Data    : Maio/2013                  Ultima atualizacao: 30/09/2015

   Dados referentes ao programa:

   Frequencia: Diario (Caixa Online).
   Objetivo  : Tratar validaçăo e pagamento de DARFs sem Cod de Barras
 
   Alteracoes: 22/05/2013 - Bloqueio pagamento DARFs (Lucas).
    
               31/05/2013 - Năo permitir pagamento de DARFs abaixo de
                            R$ 10,00 (Lucas).
                            
               12/06/2013 - Incluir Multa e Juros ao gravar valores
                            na craplot (Lucas).
                            
               19/06/2013 - Tratamento para foco e criaçăo da procedure
                            "valida-cpfcnpj-cdtrib" para validaçăo de 
                            CPF/CNPJ de acordo com o Tp de Tributo (Lucas).
                            
               02/07/2013 - Adicionado valores ao sequencial da fatura 
                          - Validaçăo para năo permitir data vecmto. 
                            menor que 01/01/1950 (Lucas).
                            
               05/08/2013 - Alterada composiçăo do sequencial da fatura (Lucas).
               
               02/10/2013 - Corrigido erro de validaçăo de Nr. de Referencia e 
                            limitar Seq. de Fat. a 38 posiçőes (Lucas).
                            
               14/10/2013 - Correçăo na validaçăo de Digitos da Opçăo B da
                            verificaçăo dos Número de Refencia (Lucas).
               
               16/12/2013 - Adicionado validate para as tabelas craplot,
                            craplft (Tiago). 
                            
               30/09/2015 - Alterada para Oracle a consulta da craplft na procedure 
                           'retorna-valores-fatura' pois DataServer năo suporta as mais
                            de 34 posiçőes do campo cdseqfat (Lunelli - SD. 328945)

               11/07/2016 - Conversão das rotinas valida-pagamento-darf e paga-darf,
                            Prj. 338 - Arrecadação DARF/DAS via Internet (Jean Michel).

..............................................................................*/

  /* Buscar Sequencial da fatura */
  FUNCTION fn_busca_sequencial_darf(pr_dtapurac IN crapdat.dtmvtolt%TYPE -- Data da Apuracao
                                   ,pr_nrcpfcgc IN craplft.nrcpfcgc%TYPE -- CPF/CNPJ
                                   ,pr_cdtribut IN craplft.cdtribut%TYPE -- Codigo do Tributo
                                   ,pr_dtlimite IN crapdat.dtmvtolt%TYPE -- Data de Limite
                                   ,pr_vlrtotal IN craplft.vllanmto%TYPE -- Valor Total
                                   ) RETURN NUMBER;
                                   
  /* Buscar Sequencial da fatura */
  PROCEDURE pc_busca_sequencial_darf(pr_dtapurac IN crapdat.dtmvtolt%TYPE -- Data da Apuracao
                                    ,pr_nrcpfcgc IN craplft.nrcpfcgc%TYPE -- CPF/CNPJ
                                    ,pr_cdtribut IN craplft.cdtribut%TYPE -- Codigo do Tributo
                                    ,pr_dtlimite IN crapdat.dtmvtolt%TYPE -- Data de Limite
                                    ,pr_vlrtotal IN craplft.vllanmto%TYPE -- Valor Total
                                    ,pr_cdseqfat OUT NUMBER               -- Sequencial da Fatura
                                    ,pr_cdcritic OUT INTEGER              -- Codigo do erro
                                    ,pr_dscritic OUT VARCHAR2             -- Descricao do erro
                                    );

  /* Procedure para verificacao de numero de referencia da DARF */
  PROCEDURE pc_verif_dig_num_ref_darf(pr_cdcooper IN crapcop.cdcooper%TYPE -- Codigo Cooperativa
                                     ,pr_cdagenci IN crapage.cdagenci%TYPE -- Codigo do PA
                                     ,pr_nrdcaixa IN craplot.nrdcaixa%TYPE -- Numero do Caixa
                                     ,pr_cdrefere IN INTEGER               -- Codigo do Tributo
                                     ,pr_foco     OUT VARCHAR2             --
                                     ,pr_cdcritic OUT INTEGER              -- Codigo do erro
                                     ,pr_dscritic OUT VARCHAR2);           -- Descricao do erro

  /* Procedure para validacao de digito de receita da DARF */
  PROCEDURE pc_verif_dig_receita_darf(pr_cdcooper IN crapcop.cdcooper%TYPE -- Codigo Cooperativa
                                     ,pr_cdagenci IN crapage.cdagenci%TYPE -- Codigo do PA
                                     ,pr_nrdcaixa IN craplot.nrdcaixa%TYPE -- Numero do Caixa
                                     ,pr_cdtribut IN craplft.cdtribut%TYPE -- Codigo do Tributo
                                     ,pr_foco     OUT VARCHAR2             --
                                     ,pr_cdcritic OUT INTEGER              -- Codigo do erro
                                     ,pr_dscritic OUT VARCHAR2);           -- Descricao do erro

  /* Procedure para validacao de pagamento DARF */
  PROCEDURE pc_valida_pagamento_darf(pr_cdcooper IN crapcop.cdcooper%TYPE -- Codigo Cooperativa
                                    ,pr_cdagenci IN crapage.cdagenci%TYPE -- Codigo do PA
                                    ,pr_nrdcaixa IN craplot.nrdcaixa%TYPE -- Numero do Caixa
                                    ,pr_cdtribut IN craplft.cdtribut%TYPE -- Codigo do Tributo
                                    ,pr_nrcpfcgc IN craplft.nrcpfcgc%TYPE -- Numero do CPF/CNPJ
                                    ,pr_dtapurac IN crapdat.dtmvtolt%TYPE -- Data de Apuracao
                                    ,pr_dtlimite IN crapdat.dtmvtolt%TYPE -- Data Limite
                                    ,pr_cdrefere IN craplft.nrrefere%TYPE -- Codigo de Referencia
                                    ,pr_vlrecbru IN craplcm.vllanmto%TYPE -- Valor da receita bruta acumulada.
                                    ,pr_vlpercen IN craplcm.vllanmto%TYPE -- Valor Percentual da guia
                                    ,pr_vllanmto IN craplcm.vllanmto%TYPE -- Valor de Lancamento
                                    ,pr_vlrmulta IN craplcm.vllanmto%TYPE -- Valor de Multa
                                    ,pr_vlrjuros IN craplcm.vllanmto%TYPE -- Valor de Juros
                                    ,pr_idagenda IN INTEGER               -- Indentificador de Agendamento
                                    ,pr_foco     OUT VARCHAR2             --
                                    ,pr_cdseqfat OUT NUMBER               -- Codigo Sequencial da DARF
                                    ,pr_cdcritic OUT INTEGER              -- Codigo do erro
                                    ,pr_dscritic OUT VARCHAR2);           -- Descricao do erro

  /* Procedure de pagamento da DARF */
  PROCEDURE pc_paga_darf(pr_cdcooper IN crapcop.cdcooper%TYPE -- Codigo Cooperativa
                        ,pr_nrdconta IN crapass.nrdconta%TYPE -- Numero da Conta
                        ,pr_idseqttl IN crapttl.idseqttl%TYPE -- Sequencial do Titular
                        ,pr_cdagenci IN crapage.cdagenci%TYPE -- Codigo do PA
                        ,pr_nrdcaixa IN craplot.nrdcaixa%TYPE -- Numero do Caixa
                        ,pr_cdoperad IN crapope.cdoperad%TYPE -- Codigo do Operados
                        ,pr_dtapurac IN crapdat.dtmvtolt%TYPE -- Data da Apuracao
                        ,pr_nrcpfcgc IN craplft.nrcpfcgc%TYPE -- CPF/CNPJ
                        ,pr_cdtribut IN craplft.cdtribut%TYPE -- Codigo do Tributo
                        ,pr_cdrefere IN craplft.nrrefere%TYPE -- Codigo de Referencia
                        ,pr_dtlimite IN crapdat.dtmvtolt%TYPE -- Data de Limite
                        ,pr_vlrecbru IN craplft.vlrecbru%TYPE -- Valor da receita bruta acumulada.
                        ,pr_vlpercen IN craplft.vlpercen%TYPE -- Percentual da guia.
                        ,pr_vllanmto IN craplft.vllanmto%TYPE -- Valor da fatura
                        ,pr_vlrmulta IN craplft.vlrmulta%TYPE -- Valor da multa
                        ,pr_vlrjuros IN craplft.vlrjuros%TYPE -- Valor dos juros  
                        ,pr_dsnomfon IN craplft.dsnomfon%TYPE -- Nome / Telefone  
                        ,pr_foco     OUT VARCHAR2             --
                        ,pr_dscliter OUT VARCHAR2             --
                        ,pr_cdultseq OUT INTEGER              --
                        ,pr_cdcritic OUT INTEGER              -- Codigo do erro
                        ,pr_dscritic OUT VARCHAR2);           -- Descricao do erro
                                                  
END CXON0041;
/
CREATE OR REPLACE PACKAGE BODY CECRED.CXON0041 AS

  /*---------------------------------------------------------------------------------------------------------------

    Programa : CXON0041                           Antigo: siscaixa/web/dbo/b1crap41.p
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Jean Michel
    Data     : Maio/2013                   Ultima atualizacao: 03/04/2017
  
    Dados referentes ao programa:
  
    Frequencia: Diario (Caixa Online).
    Objetivo  : Tratar validação e pagamento de DARFs sem Cod de Barras
    
    Alteracoes: 22/05/2013 - Bloqueio pagamento DARFs (Lucas).
    
               31/05/2013 - Não permitir pagamento de DARFs abaixo de
                            R$ 10,00 (Lucas).
                            
               12/06/2013 - Incluir Multa e Juros ao gravar valores
                            na craplot (Lucas).
                            
               19/06/2013 - Tratamento para foco e criação da procedure
                            "valida-cpfcnpj-cdtrib" para validação de 
                            CPF/CNPJ de acordo com o Tp de Tributo (Lucas).
                            
               02/07/2013 - Adicionado valores ao sequencial da fatura 
                          - Validação para não permitir data vecmto. 
                            menor que 01/01/1950 (Lucas).
                            
               05/08/2013 - Alterada composição do sequencial da fatura (Lucas).
               
               02/10/2013 - Corrigido erro de validação de Nr. de Referencia e 
                            limitar Seq. de Fat. a 38 posições (Lucas).
                            
               14/10/2013 - Correção na validação de Digitos da Opção B da
                            verificação dos Número de Refencia (Lucas).
               
               16/12/2013 - Adicionado validate para as tabelas craplot,
                            craplft (Tiago). 
                            
               30/09/2015 - Alterada para Oracle a consulta da craplft na procedure 
                           'retorna-valores-fatura' pois DataServer não suporta as mais
                            de 34 posições do campo cdseqfat (Lunelli - SD. 328945)

               11/07/2016 - Conversão das rotinas valida-pagamento-darf e paga-darf,
                            Prj. 338 - Arrecadação DARF/DAS via Internet (Jean Michel).            
    
               03/04/2017 - Retirar a soma do nrseqdig do craplot desta rotina pois ja esta
                            sendo efetuado na LOTE0001.pc_insere_lote (Lucas Ranghetti #633737)
                            
               14/02/2018 - Projeto Ligeirinho. Alterado para gravar na tabela de lotes (craplot) somente no final
                            da execução do CRPS509 => INTERNET E TAA. (Fabiano Girardi AMcom)                            
    
  ---------------------------------------------------------------------------------------------------------------*/
  
  /* Busca dos dados da cooperativa */
  CURSOR cr_crapcop(pr_cdcooper IN craptab.cdcooper%TYPE) IS
    SELECT crapcop.cdcooper
          ,crapcop.nmrescop
          ,crapcop.nrtelura
          ,crapcop.dsdircop
          ,crapcop.cdbcoctl
          ,crapcop.cdagectl
          ,crapcop.flgoppag
          ,crapcop.flgopstr
          ,crapcop.inioppag
          ,crapcop.fimoppag
          ,crapcop.iniopstr
          ,crapcop.fimopstr
          ,crapcop.cdagebcb
          ,crapcop.dssigaut
          ,crapcop.cdagesic
          ,crapcop.nrtelsac
      FROM crapcop
     WHERE crapcop.cdcooper = pr_cdcooper;
     
  rw_crapcop cr_crapcop%ROWTYPE;

  /* Buscar Sequencial da fatura */
  FUNCTION fn_busca_sequencial_darf(pr_dtapurac IN crapdat.dtmvtolt%TYPE -- Data da Apuracao
                                   ,pr_nrcpfcgc IN craplft.nrcpfcgc%TYPE -- CPF/CNPJ
                                   ,pr_cdtribut IN craplft.cdtribut%TYPE -- Codigo do Tributo
                                   ,pr_dtlimite IN crapdat.dtmvtolt%TYPE -- Data de Limite
                                   ,pr_vlrtotal IN craplft.vllanmto%TYPE -- Valor Total
                                   ) RETURN NUMBER IS
  --------------------------------------------------------------------------------------------------------------
  --
  --  Programa : fn_busca_sequencial_darf             Antigo: dbo/b1crap14.p/busca_sequencial_fatura
  --  Sistema  : Buscar Sequencial da DARF
  --  Sigla    : CXON
  --  Autor    : Jean Michel
  --  Data     : Julho/2016.                   Ultima atualizacao:
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Buscar Sequencial da DARF

  -- Alteracoes: 
  ---------------------------------------------------------------------------------------------------------------
    -- Variaveis Locais
    vr_cdseqfat VARCHAR(100);
  BEGIN

    vr_cdseqfat := TO_CHAR(pr_dtapurac,'ddMMRRRR') ||
                   TO_CHAR(pr_nrcpfcgc) ||
                   LPAD(pr_cdtribut,4,'0') ||
                   TO_CHAR(pr_dtlimite,'ddMMRRRR') ||
                   TRIM(REPLACE(TO_CHAR(pr_vlrtotal),',',''));

    RETURN TO_NUMBER(SUBSTR(vr_cdseqfat, 1, 38));

  EXCEPTION
     WHEN OTHERS THEN
       RETURN NULL;
  END fn_busca_sequencial_darf;
  
  /* Buscar Sequencial da fatura */
  PROCEDURE pc_busca_sequencial_darf(pr_dtapurac IN crapdat.dtmvtolt%TYPE -- Data da Apuracao
                                    ,pr_nrcpfcgc IN craplft.nrcpfcgc%TYPE -- CPF/CNPJ
                                    ,pr_cdtribut IN craplft.cdtribut%TYPE -- Codigo do Tributo
                                    ,pr_dtlimite IN crapdat.dtmvtolt%TYPE -- Data de Limite
                                    ,pr_vlrtotal IN craplft.vllanmto%TYPE -- Valor Total
                                    ,pr_cdseqfat OUT NUMBER               -- Sequencial da Fatura
                                    ,pr_cdcritic OUT INTEGER              -- Codigo do erro
                                    ,pr_dscritic OUT VARCHAR2             -- Descricao do erro
                                    ) IS
  --------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_busca_sequencial_darf             Antigo: dbo/b1crap14.p/busca_sequencial_fatura
  --  Sistema  : Buscar Sequencial da DARF
  --  Sigla    : CXON
  --  Autor    : Dionathan
  --  Data     : Julho/2016.                   Ultima atualizacao:
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Buscar Sequencial da DARF (Chama a function acima)

  -- Alteracoes: 
  ---------------------------------------------------------------------------------------------------------------

  -- Variáveis de exceção
  vr_exc_erro EXCEPTION;
  BEGIN
   
    -- Busca o sequencial a partir da funcion
    pr_cdseqfat := CXON0041.fn_busca_sequencial_darf(pr_dtapurac => pr_dtapurac
                                                    ,pr_nrcpfcgc => pr_nrcpfcgc
                                                    ,pr_cdtribut => pr_cdtribut
                                                    ,pr_dtlimite => pr_dtlimite
                                                    ,pr_vlrtotal => pr_vlrtotal);
    
    IF pr_cdseqfat IS NULL THEN
      RAISE vr_exc_erro;
    END IF;
      
  EXCEPTION
     WHEN OTHERS THEN
       pr_cdcritic:= 0;
       pr_dscritic:= 'Erro ao processar rotina CXON0014.fn_busca_sequencial_darf. '||SQLERRM;
  END pc_busca_sequencial_darf;
  
  /* Procedure para verificacao de numero de referencia da DARF */
  PROCEDURE pc_verif_dig_num_ref_darf(pr_cdcooper IN crapcop.cdcooper%TYPE -- Codigo Cooperativa
                                     ,pr_cdagenci IN crapage.cdagenci%TYPE -- Codigo do PA
                                     ,pr_nrdcaixa IN craplot.nrdcaixa%TYPE -- Numero do Caixa
                                     ,pr_cdrefere IN INTEGER               -- Codigo do Tributo
                                     ,pr_foco     OUT VARCHAR2             --
                                     ,pr_cdcritic OUT INTEGER              -- Codigo do erro
                                     ,pr_dscritic OUT VARCHAR2) IS         -- Descricao do erro
  
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_verif_dig_num_ref_darf             Antigo: dbo/b1crap41.p/verifica-digito-num-referencia-darf
  --  Sistema  : Procedure para verificacao de numero de referencia da DARF
  --  Sigla    : CRED
  --  Autor    : Jean Michel
  --  Data     : Julho/2016.                   Ultima atualizacao: --/--/----
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Procedure para verificacao de numero de referencia da DARF
  --
  -- Alteracoes:
  --
  ---------------------------------------------------------------------------------------------------------------
  BEGIN
    DECLARE
  
      --Variaveis de Erro
      vr_cdcritic crapcri.cdcritic%TYPE := NULL;
      vr_dscritic VARCHAR2(4000)        := NULL;
      
      --Variaveis Excecao
      vr_exc_erro EXCEPTION;
      vr_exc_null EXCEPTION;
      -- Tipo de Dados para cursor data
      rw_crapdat  BTCH0001.cr_crapdat%ROWTYPE;

      -- Variaveis locais
      vr_vlrcalcu NUMBER(20,5) := 0;
      vr_cddigito NUMBER(20,5) := 0;
      vr_vlorpeso NUMBER(20,5) := 2;
      vr_cdrefere NUMBER(20,5) := 0;
    BEGIN
      -- Inicializar variaveis retorno
      pr_cdcritic:= NULL;
      pr_dscritic:= NULL;
      
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
        RAISE vr_exc_erro;
      ELSE
        -- Apenas fechar o cursor
        CLOSE btch0001.cr_crapdat;
      END IF;

      -- Opçao A
      FOR vr_vlrconta IN REVERSE 1..(LENGTH(pr_cdrefere) - 1) LOOP
        vr_vlrcalcu := vr_vlrcalcu + (TO_NUMBER(SUBSTR(TO_CHAR(pr_cdrefere),vr_vlrconta,1)) * vr_vlorpeso);
        vr_vlorpeso := vr_vlorpeso + 1;

        IF vr_vlorpeso > 9   THEN
          vr_vlorpeso := 2;
        END IF;
      END LOOP;

      vr_cddigito := 11 - MOD(vr_vlrcalcu,11);

      IF MOD(vr_vlrcalcu,11) = 0 OR 
        MOD(vr_vlrcalcu,11) = 1 THEN
        vr_cddigito := 0;
      END IF;

      IF TO_NUMBER(SUBSTR(pr_cdrefere,LENGTH(TO_CHAR(pr_cdrefere)),1)) = vr_cddigito THEN
        RAISE vr_exc_null;
      END IF;

      -- Opçăo B
      vr_vlrcalcu := 0;
      vr_vlorpeso := 2;
      vr_cddigito := 0;

    FOR vr_vlrconta IN REVERSE 1..(LENGTH(pr_cdrefere)-2) LOOP
      vr_vlrcalcu  := vr_vlrcalcu + (TO_NUMBER(SUBSTR(TO_CHAR(pr_cdrefere),vr_vlrconta,1)) * vr_vlorpeso);
      vr_vlorpeso := vr_vlorpeso + 1;
    END LOOP;

    vr_cddigito := 11 - MOD(vr_vlrcalcu,11);

    -- Valida o primeiro Digito
    IF (TO_NUMBER(SUBSTR(pr_cdrefere,LENGTH(TO_CHAR(pr_cdrefere)) - 1,1)) <> vr_cddigito) THEN
      vr_cdcritic := 0;
      vr_dscritic := 'Digito do Numero de Referencia incorreto.';
      pr_foco     := '12';
      RAISE vr_exc_erro;            
    END IF;    
    
    vr_vlrcalcu := 0;
    vr_vlorpeso := 2;
    vr_cdrefere := SUBSTR(TO_CHAR(pr_cdrefere),1,LENGTH(TO_CHAR(pr_cdrefere)) - 2);
    vr_cdrefere := vr_cdrefere || vr_cddigito;

    FOR vr_vlrconta IN REVERSE 1..LENGTH(vr_cdrefere) LOOP
      vr_vlrcalcu := vr_vlrcalcu + (TO_NUMBER(SUBSTR(TO_CHAR(vr_cdrefere),vr_vlrconta,1)) * vr_vlorpeso);
      vr_vlorpeso := vr_vlorpeso + 1;
    END LOOP;

    vr_cddigito := 11 - MOD(vr_vlrcalcu,11);

    IF MOD(vr_vlrcalcu,11) = 1  THEN
      vr_cddigito := 0;
    END IF;

    IF MOD(vr_vlrcalcu,11) = 0  THEN
      vr_cddigito := 1;
    END IF;
 
    IF TO_NUMBER(SUBSTR(pr_cdrefere,LENGTH(TO_CHAR(pr_cdrefere)),1)) = vr_cddigito THEN
      RAISE vr_exc_null;
    ELSE
      vr_cdcritic := 0;
      vr_dscritic := 'Digito do Numero de Referencia incorreto.';
      pr_foco     := '12';
      RAISE vr_exc_erro;            
    END IF;

    EXCEPTION
      WHEN vr_exc_null THEN
        pr_cdcritic := 0;
        pr_dscritic := NULL;

      WHEN vr_exc_erro THEN
        -- Se foi retornado apenas código
        IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
          -- Buscar a descrição
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;
        
        -- Devolvemos código e critica encontradas
        pr_cdcritic := NVL(vr_cdcritic,0);
        pr_dscritic := vr_dscritic;
        
        -- Efetuar ROLLBACK
        ROLLBACK;
       WHEN OTHERS THEN
        pr_cdcritic:= 0;
        pr_dscritic:= 'Erro na rotina CXON0041.pc_verif_dig_num_ref_darf. Erro: ' || SQLERRM;
    END;
  END pc_verif_dig_num_ref_darf;

  /* Procedure para validacao de digito de receita da DARF */
  PROCEDURE pc_verif_dig_receita_darf(pr_cdcooper IN crapcop.cdcooper%TYPE -- Codigo Cooperativa
                                     ,pr_cdagenci IN crapage.cdagenci%TYPE -- Codigo do PA
                                     ,pr_nrdcaixa IN craplot.nrdcaixa%TYPE -- Numero do Caixa
                                     ,pr_cdtribut IN craplft.cdtribut%TYPE -- Codigo do Tributo
                                     ,pr_foco     OUT VARCHAR2             --
                                     ,pr_cdcritic OUT INTEGER              -- Codigo do erro
                                     ,pr_dscritic OUT VARCHAR2) IS         -- Descricao do erro
  
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_verif_dig_receita_darf             Antigo: dbo/b1crap41.p/verifica-digito-receita-darf
  --  Sistema  : Procedure para validacao de digito de receita da DARF
  --  Sigla    : CRED
  --  Autor    : Jean Michel
  --  Data     : Julho/2016.                   Ultima atualizacao: --/--/----
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Procedure para validacao de digito de receita da DARF
  --
  -- Alteracoes:
  --
  ---------------------------------------------------------------------------------------------------------------
  BEGIN
    DECLARE
  
      --Variaveis de Erro
      vr_cdcritic crapcri.cdcritic%TYPE := NULL;
      vr_dscritic VARCHAR2(4000)        := NULL;
      
      --Variaveis Excecao
      vr_exc_erro EXCEPTION;
      vr_exc_null EXCEPTION;
      
      --Tipo de Dados para cursor data
      rw_crapdat  BTCH0001.cr_crapdat%ROWTYPE;

      -- Variaveis locais
      vr_vlrcalcu NUMBER(20,5) := 0;
      vr_cddigito NUMBER(20,5) := 0;
      vr_vlrresto NUMBER(20,5) := 0;
    BEGIN
      -- Inicializar variaveis retorno
      pr_cdcritic:= NULL;
      pr_dscritic:= NULL;
      
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
        RAISE vr_exc_erro;
      ELSE
        -- Apenas fechar o cursor
        CLOSE btch0001.cr_crapdat;
      END IF;

      -- Módulo 11 (842)
      vr_vlrcalcu := ((TO_NUMBER(SUBSTR(pr_cdtribut,1,1) * 8)) +
                      (TO_NUMBER(SUBSTR(pr_cdtribut,2,1) * 4)) +
                      (TO_NUMBER(SUBSTR(pr_cdtribut,3,1) * 2)));
      vr_vlrresto := MOD(vr_vlrcalcu,11);
      vr_cddigito := 11 - vr_vlrresto;

      IF vr_vlrresto = 0 OR vr_vlrresto = 1 THEN
        vr_cddigito := 0;
      END IF;

      IF (NVL(TO_NUMBER(SUBSTR(pr_cdtribut,4,1)),0) = vr_cddigito) THEN
        RAISE vr_exc_null;
      END IF;    

      -- Módulo 11 (248)
      vr_vlrcalcu := ((TO_NUMBER(SUBSTR(pr_cdtribut,1,1)) * 2) +
                      (TO_NUMBER(SUBSTR(pr_cdtribut,2,1)) * 4) +
                      (TO_NUMBER(SUBSTR(pr_cdtribut,3,1)) * 8));
      vr_vlrresto := MOD(vr_vlrcalcu,11);
      vr_cddigito := 11 - vr_vlrresto;

      IF vr_vlrresto = 0 OR vr_vlrresto = 1 THEN
        vr_cddigito := 0;
      END IF;

      IF (NVL(TO_NUMBER(SUBSTR(pr_cdtribut,4,1)),0) = vr_cddigito) THEN
        RAISE vr_exc_null;
      END IF; 

      -- Módulo 11 (134)
      vr_vlrcalcu := ((TO_NUMBER(SUBSTR(pr_cdtribut,1,1)) * 1) +
                      (TO_NUMBER(SUBSTR(pr_cdtribut,2,1)) * 3) +
                      (TO_NUMBER(SUBSTR(pr_cdtribut,3,1)) * 4));
      vr_vlrresto := MOD(vr_vlrcalcu,11);
      vr_cddigito := 11 - vr_vlrresto;

      IF vr_vlrresto = 0 OR vr_vlrresto = 1 THEN
        vr_cddigito := 0;
      END IF;

      IF (NVL(TO_NUMBER(SUBSTR(pr_cdtribut,4,1)),0) = vr_cddigito) THEN
        RAISE vr_exc_null;
      ELSE
        vr_cdcritic := 0;
        vr_dscritic := 'Digito do Codigo Receita incorreto.';
        pr_foco     := '11';
        RAISE vr_exc_erro;
      END IF;

    EXCEPTION
      WHEN vr_exc_null THEN
        pr_cdcritic := 0;
        pr_dscritic := NULL;
      WHEN vr_exc_erro THEN
        -- Se foi retornado apenas código
        IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
          -- Buscar a descrição
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;
        
        -- Devolvemos código e critica encontradas
        pr_cdcritic := NVL(vr_cdcritic,0);
        pr_dscritic := vr_dscritic;
        
        -- Efetuar ROLLBACK
        ROLLBACK;

      WHEN OTHERS THEN
        pr_cdcritic:= 0;
        pr_dscritic:= 'Erro na rotina CXON0041.pc_verif_dig_receita_darf. Erro: ' || SQLERRM;
    END;
  END pc_verif_dig_receita_darf;

  /* Procedure para validacao de pagamento DARF */
  PROCEDURE pc_valida_pagamento_darf(pr_cdcooper IN crapcop.cdcooper%TYPE -- Codigo Cooperativa
                                    ,pr_cdagenci IN crapage.cdagenci%TYPE -- Codigo do PA
                                    ,pr_nrdcaixa IN craplot.nrdcaixa%TYPE -- Numero do Caixa
                                    ,pr_cdtribut IN craplft.cdtribut%TYPE -- Codigo do Tributo
                                    ,pr_nrcpfcgc IN craplft.nrcpfcgc%TYPE -- Numero do CPF/CNPJ
                                    ,pr_dtapurac IN crapdat.dtmvtolt%TYPE -- Data de Apuracao
                                    ,pr_dtlimite IN crapdat.dtmvtolt%TYPE -- Data Limite
                                    ,pr_cdrefere IN craplft.nrrefere%TYPE -- Codigo de Referencia
                                    ,pr_vlrecbru IN craplcm.vllanmto%TYPE -- Valor da receita bruta acumulada.
                                    ,pr_vlpercen IN craplcm.vllanmto%TYPE -- Valor Percentual da guia
                                    ,pr_vllanmto IN craplcm.vllanmto%TYPE -- Valor de Lancamento
                                    ,pr_vlrmulta IN craplcm.vllanmto%TYPE -- Valor de Multa
                                    ,pr_vlrjuros IN craplcm.vllanmto%TYPE -- Valor de Juros
                                    ,pr_idagenda IN INTEGER               -- Indentificador de Agendamento
                                    ,pr_foco     OUT VARCHAR2             --
                                    ,pr_cdseqfat OUT NUMBER               -- Codigo Sequencial da DARF
                                    ,pr_cdcritic OUT INTEGER              -- Codigo do erro
                                    ,pr_dscritic OUT VARCHAR2) IS         -- Descricao do erro
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_valida_pagamento_darf             Antigo: dbo/b1crap41.p/valida-pagamento-darf
  --  Sistema  : Procedure para buscar validar pagamento de DARF
  --  Sigla    : CRED
  --  Autor    : Jean Michel
  --  Data     : Julho/2016.                   Ultima atualizacao: --/--/----
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Procedure para validar pagamento de DARF
  --
  -- Alteracoes:
  --
  ---------------------------------------------------------------------------------------------------------------
  BEGIN
    DECLARE
      CURSOR cr_craplft(pr_cdcooper craplft.cdcooper%TYPE
                       ,pr_dtmvtocd craplft.dtmvtolt%TYPE
                       ,pr_cdagenci craplft.cdagenci%TYPE
                       ,pr_cdbccxlt craplft.cdbccxlt%TYPE
                       ,pr_nrdolote craplft.nrdolote%TYPE
                       ,pr_cdseqfat craplft.cdseqfat%TYPE) IS

        SELECT /*+ index (CRAPLFT CRAPLFT##CRAPLFT1) */
               lft.nrseqdig
              ,lft.cdhistor
          FROM craplft lft
         WHERE lft.cdcooper = pr_cdcooper     
           AND lft.dtmvtolt = pr_dtmvtocd      
           AND lft.cdagenci = pr_cdagenci          
           AND lft.cdbccxlt = pr_cdbccxlt         
           AND lft.nrdolote = pr_nrdolote          
           AND lft.cdseqfat = pr_cdseqfat;

      rw_craplft cr_craplft%ROWTYPE;

      CURSOR cr_crapstb IS
        SELECT stb.dsaretrb
              ,stb.cdtribut
              ,stb.dstribut 
              ,stb.dsrestri
        FROM crapstb stb
       WHERE stb.cdtribut = pr_cdtribut;
      
      rw_crapstb cr_crapstb%ROWTYPE;
  
      --Variaveis de Erro
      vr_cdcritic crapcri.cdcritic%TYPE := NULL;
      vr_dscritic VARCHAR2(4000)        := NULL;
      
      --Variaveis Excecao
      vr_exc_erro EXCEPTION;
      
      --Tipo de Dados para cursor data
      rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;

      -- Variaveis Locais
      vr_foco     VARCHAR2(10)  := '';
      vr_dstextab VARCHAR2(500) := '';
      vr_hhsicini VARCHAR2(500) := '';
      vr_hhsicfim VARCHAR2(500) := '';
      vr_timepgto NUMBER(10,5)  := 0;
      vr_vlrtotal NUMBER(20,2)  := 0;
      vr_stsnrcal BOOLEAN       := FALSE;
      vr_inpessoa INTEGER       := 0;
      vr_nrdolote craplot.nrdolote%TYPE := 0;
      vr_cdseqfat NUMBER        := 0;

    BEGIN
      -- Inicializar variaveis retorno
      pr_cdcritic:= NULL;
      pr_dscritic:= NULL;
      
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
        RAISE vr_exc_erro;
      ELSE
        -- Apenas fechar o cursor
        CLOSE btch0001.cr_crapdat;
      END IF;

      CXON0000.pc_elimina_erro(pr_cooper      => pr_cdcooper   -- Codigo cooperativa
                              ,pr_cod_agencia => pr_cdagenci   -- Codigo agencia
                              ,pr_nro_caixa   => pr_nrdcaixa   -- Numero Caixa
                              ,pr_cdcritic    => vr_cdcritic   -- Codigo do erro
                              ,pr_dscritic    => vr_dscritic); -- Descricao do erro

      -- Se ocorreu erro
      IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
        -- Levantar Excecao
        RAISE vr_exc_erro;
      END IF;

      vr_vlrtotal := (pr_vllanmto + pr_vlrmulta + pr_vlrjuros);

      -- Consulta de sequencial único para DARFs
      CXON0041.pc_busca_sequencial_darf(pr_dtapurac => pr_dtapurac
                                       ,pr_nrcpfcgc => pr_nrcpfcgc
                                       ,pr_cdtribut => pr_cdtribut
                                       ,pr_dtlimite => pr_dtlimite
                                       ,pr_vlrtotal => vr_vlrtotal
                                       ,pr_cdseqfat => vr_cdseqfat
                                       ,pr_cdcritic => vr_cdcritic
                                       ,pr_dscritic => vr_dscritic);

      IF vr_dscritic IS NOT NULL OR
        NVL(vr_cdcritic,0) > 0 THEN
        RAISE vr_exc_erro;   
      END IF;
	  
	  pr_cdseqfat := vr_cdseqfat;

      vr_dstextab := tabe0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                               ,pr_nmsistem => 'CRED'
                                               ,pr_tptabela => 'GENERI'
                                               ,pr_cdempres => 0
                                               ,pr_cdacesso => 'HRPGSICRED'
                                               ,pr_tpregist => pr_cdagenci);

      IF vr_dstextab IS NULL THEN
        vr_cdcritic := 0;
        vr_dscritic := 'Parametros de Horario nao cadastrados.';
        RAISE vr_exc_erro;
      END IF;
      
      vr_hhsicini := GENE0002.fn_busca_entrada(1,vr_dstextab,' ');
      vr_hhsicfim := GENE0002.fn_busca_entrada(2,vr_dstextab,' ');
      vr_timepgto := GENE0002.fn_busca_time;

      IF pr_idagenda <> 2 THEN
        IF vr_timepgto < vr_hhsicini OR
           vr_timepgto > vr_hhsicfim THEN
          
          vr_cdcritic := 0;
          vr_dscritic := 'Esse pagamento deve ser aceito ate as ' ||
          GENE0002.fn_converte_time_data(pr_nrsegs => gene0002.fn_busca_time) || 'h.';

          RAISE vr_exc_erro;
        END IF;
      END IF;

      vr_nrdolote := 15000 + pr_nrdcaixa;

      -- Verifica se exite lançamento já existente
      OPEN cr_craplft(pr_cdcooper => pr_cdcooper
                     ,pr_dtmvtocd => rw_crapdat.dtmvtocd
                     ,pr_cdagenci => pr_cdagenci
                     ,pr_cdbccxlt => 11 
                     ,pr_nrdolote => vr_nrdolote
                     ,pr_cdseqfat => vr_cdseqfat);

      FETCH cr_craplft INTO rw_craplft;

      IF cr_craplft%FOUND THEN
        CLOSE cr_craplft;
        vr_cdcritic := 92;
        vr_dscritic := '';
        RAISE vr_exc_erro;
      ELSE
        CLOSE cr_craplft;
      END IF;
      
      -- Validaçăo Dt. Apuração
      IF pr_dtapurac IS NULL THEN
        vr_dscritic := 0;
        vr_dscritic := 'Periodo de apuracao incorreto.';
        pr_foco     := '9';
        
        RAISE vr_exc_erro;
      END IF;

      -- Validaçăo Cd. Tributo
      IF pr_cdtribut = '0' THEN
      
        vr_dscritic := 0;
        vr_dscritic := 'Tributo nao informado.';
        pr_foco     := '11';
        
        RAISE vr_exc_erro;
      END IF;

      OPEN cr_crapstb;
      FETCH cr_crapstb INTO rw_crapstb;

      IF cr_crapstb%NOTFOUND THEN
        vr_cdcritic := 0;
        vr_dscritic := 'Tributo nao cadastrado.';
        pr_foco     := '11';
        CLOSE cr_crapstb;
		RAISE  vr_exc_erro;
	  ELSE
		CLOSE cr_crapstb;
      END IF;

      
      -- Validaçao Dt.Vencto. Para todas as DARFs
      IF pr_dtlimite IS NULL  AND 
	     pr_cdtribut <> '6106'THEN
        vr_dscritic := 0;
        vr_dscritic := 'Data de vencimento invalida.';
        pr_foco     := '13';
        
        RAISE vr_exc_erro;
      END IF;

      -- Validação para não aceitar faturas com Datas Vencto. inferiores a 01/01/1950
      IF pr_dtlimite < TO_DATE('01/01/1950','MM/dd/RRRR') THEN
      
        vr_cdcritic := 0;
        vr_dscritic := 'Data de vencimento invalida.';
        pr_foco     := '13';

        RAISE vr_exc_erro;
      END IF;

      vr_vlrtotal := pr_vllanmto + pr_vlrmulta + pr_vlrjuros;

      -- Năo permitido pagamento de DARFs com valor abaixo de R$10,00
      IF vr_vlrtotal < 10 THEN
         
        vr_cdcritic := 0;
        vr_dscritic := 'Pagamento deve ser maior ou igual a R$10,00.';
        pr_foco     := '14';

        RAISE vr_exc_erro;                                          
      END IF;

      -- DARF-SIMPLES
      IF pr_cdtribut = '6106' THEN
        IF (pr_dtapurac < TO_DATE('01/01/1980','MM/dd/RRRR')) OR 
           (pr_dtapurac > TO_DATE('06/30/2007','MM/dd/RRRR')) THEN
           
          vr_cdcritic := 0;
          vr_dscritic := 'Periodo de apuracao incorreto.';
          pr_foco     := '9';

          RAISE vr_exc_erro;

        END IF;

        IF pr_vlrecbru = 0 THEN
           
          vr_cdcritic := 0;
          vr_dscritic := 'Receita Bruta Acumulada nao pode ser vazia.';
          pr_foco     := '17';

          RAISE vr_exc_erro;
                    
        END IF;

        IF(pr_vlpercen = 0)            OR
          ((pr_vlpercen * 100) < 300)  OR 
          ((pr_vlpercen * 100) > 2928) THEN
                
          vr_cdcritic := 0;
          vr_dscritic := 'Valor do Percentual invalido.';
          pr_foco     := '18';

          RAISE vr_exc_erro;
        END IF;

        -- FIM DARF-SIMPLES
      ELSE -- DARF PRETO EUROPA
        IF pr_dtapurac < TO_DATE('01/01/1980','MM/dd/RRRR') OR
           pr_dtapurac > (ADD_MONTHS(rw_crapdat.dtmvtocd,60)) THEN

          vr_cdcritic := 0;
          vr_dscritic := 'Periodo de apuracao incorreto.';
          pr_foco     := '9';

          RAISE vr_exc_erro;
        END IF;

        CXON0041.pc_verif_dig_receita_darf(pr_cdcooper => pr_cdcooper   -- Codigo Cooperativa
                                          ,pr_cdagenci => pr_cdagenci   -- Codigo do PA
                                          ,pr_nrdcaixa => pr_nrdcaixa   -- Numero do Caixa
                                          ,pr_cdtribut => pr_cdtribut   -- Codigo do Tributo
                                          ,pr_foco     => vr_foco       --
                                          ,pr_cdcritic => vr_cdcritic   -- Codigo do erro
                                          ,pr_dscritic => vr_dscritic); -- Descricao do erro

        IF vr_dscritic IS NOT NULL OR
           NVL(vr_cdcritic,0) > 0 THEN
          RAISE vr_exc_erro;   
        END IF;                         
        
        IF (pr_cdtribut = '9139' OR
            pr_cdtribut = '9141' OR
            pr_cdtribut = '9154' OR
            pr_cdtribut = '9167' OR
            pr_cdtribut = '9170' OR
            pr_cdtribut = '9182')           AND
            pr_nrcpfcgc <> '00360305000104' THEN
            
          vr_cdcritic := 0;
          vr_dscritic := 'Documento nao pode ser ser acolhido por esse CPF/CNPJ.';
          pr_foco     := '10';

          RAISE vr_exc_erro;
        END IF;

        IF pr_cdtribut = '4584' AND
           pr_nrcpfcgc <> '00000000000191' THEN

          vr_cdcritic := 0;
          vr_dscritic := 'Documento nao pode ser ser acolhido por esse CPF/CNPJ.';
          pr_foco     := '10';

          RAISE vr_exc_erro;
        END IF;

        IF pr_vlrecbru <> 0 THEN
                 
          vr_cdcritic := 0;
          vr_dscritic := 'Receita Bruta Acumulada nao deve ser preenchida.';
          pr_foco     := '17';

          RAISE vr_exc_erro;
        END IF;

        IF pr_vlpercen <> 0 THEN
        
          vr_cdcritic := 0;
          vr_dscritic := 'O Percentual nao deve estar preenchido.';
          pr_foco     := '18';
             
          RAISE vr_exc_erro;
        END IF;

      END IF;  -- DARF PRETO EUROPA
      
      IF pr_vllanmto = 0 THEN 
        
        vr_cdcritic := 0;
        vr_dscritic := 'Valor deve ser informado.';
        pr_foco     := '14';
           
        RAISE vr_exc_erro;
      END IF;

      IF UPPER(SUBSTR(rw_crapstb.dsrestri,1,1)) = 'S' THEN
       
        IF pr_cdrefere IS NULL OR pr_cdrefere = 0 THEN

          vr_cdcritic := 0;
          vr_dscritic := 'Numero de Referencia deve ser preenchido.';
          pr_foco     := '12';
           
          RAISE vr_exc_erro;
        ELSE
          CXON0041.pc_verif_dig_num_ref_darf(pr_cdcooper => pr_cdcooper   -- Codigo Cooperativa
                                            ,pr_cdagenci => pr_cdagenci   -- Codigo do PA
                                            ,pr_nrdcaixa => pr_nrdcaixa   -- Numero do Caixa
                                            ,pr_cdrefere => pr_cdrefere   -- Codigo do Tributo
                                            ,pr_foco     => vr_foco       --
                                            ,pr_cdcritic => vr_cdcritic   -- Codigo do erro
                                            ,pr_dscritic => vr_dscritic); -- Descricao do erro

          IF vr_dscritic IS NOT NULL OR
            NVL(vr_cdcritic,0) > 0 THEN
            RAISE vr_exc_erro;   
          END IF;

        END IF;
      END IF;

      -- Valida CPF/CNPJ
      GENE0005.pc_valida_cpf_cnpj(pr_nrcalcul => pr_nrcpfcgc
                                 ,pr_stsnrcal => vr_stsnrcal
                                 ,pr_inpessoa => vr_inpessoa);

      IF NOT(vr_stsnrcal) THEN
        vr_cdcritic := 27;
        vr_dscritic := '';
        pr_foco     := '10';
        RAISE vr_exc_erro;
      END IF;

      IF SUBSTR(rw_crapstb.dsrestri,2,1) <> 'S' THEN
        IF pr_nrcpfcgc = '00000000000191' THEN
          vr_cdcritic := 0;
          vr_dscritic := 'Documento nao pode possuir esse CNPJ.';
          pr_foco     := '10';
          RAISE vr_exc_erro;              
        END IF;
      END IF;
      
      IF SUBSTR(rw_crapstb.dsrestri,3,1) = 'S' THEN
        IF pr_dtapurac <> TO_DATE('01/01/1980','MM/dd/RRRR') AND
           pr_dtapurac <> TO_DATE('08/08/1980','MM/dd/RRRR') THEN

          IF vr_inpessoa <> 1 THEN
            
            vr_cdcritic := 0;
            vr_dscritic := 'Numero de digitos do CPF incorreto.';
            pr_foco     := '10';
            RAISE vr_exc_erro;
          END IF;  
        END IF;
      END IF;

      IF SUBSTR(rw_crapstb.dsrestri,4,1) = 'S' THEN
        IF (pr_dtapurac <> TO_DATE('01/01/1980','MM/dd/RRRR')  AND
            pr_dtapurac <> TO_DATE('07/07/1980','MM/dd/RRRR')  AND
            pr_dtapurac <> TO_DATE('08/08/1980','MM/dd/RRRR')) THEN

          IF vr_inpessoa <> 2 THEN

            vr_cdcritic := 0;
            vr_dscritic := 'Numero de digitos do CNPJ incorreto.';
            pr_foco     := '10';
            RAISE vr_exc_erro;

          END IF;
        END IF;
      END IF;

      IF SUBSTR(rw_crapstb.dsrestri,7,1) = 'S' THEN
        IF vr_vlrtotal < 10 THEN
          vr_cdcritic := 0;
          vr_dscritic := 'Pagamento deve ser maior ou igual a R$10,00.';
          pr_foco     := '14';
          RAISE vr_exc_erro;
        END IF;
      END IF;
      
      -- DARF PRETO EUROPA
      IF pr_cdtribut <> '6106' THEN 
        IF SUBSTR(rw_crapstb.dsrestri,9,1) = 'N' THEN
          vr_cdcritic := 0;
          vr_dscritic := 'Pagamento dessa guia nao permitido.';
          RAISE vr_exc_erro;
        END IF;
      END IF;

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
         pr_foco     := vr_foco;

         -- Efetuar ROLLBACK
         ROLLBACK;

       WHEN OTHERS THEN
         pr_cdcritic:= 0;
         pr_dscritic:= 'Erro na rotina CXON0041.pc_valida_pagamento_darf. Erro: ' || SQLERRM;
    END;
  END pc_valida_pagamento_darf;

  /* Procedure de pagamento da DARF */
  PROCEDURE pc_paga_darf(pr_cdcooper IN crapcop.cdcooper%TYPE -- Codigo Cooperativa
                        ,pr_nrdconta IN crapass.nrdconta%TYPE -- Numero da Conta
                        ,pr_idseqttl IN crapttl.idseqttl%TYPE -- Sequencial do Titular
                        ,pr_cdagenci IN crapage.cdagenci%TYPE -- Codigo do PA
                        ,pr_nrdcaixa IN craplot.nrdcaixa%TYPE -- Numero do Caixa
                        ,pr_cdoperad IN crapope.cdoperad%TYPE -- Codigo do Operados
                        ,pr_dtapurac IN crapdat.dtmvtolt%TYPE -- Data da Apuracao
                        ,pr_nrcpfcgc IN craplft.nrcpfcgc%TYPE -- CPF/CNPJ
                        ,pr_cdtribut IN craplft.cdtribut%TYPE -- Codigo do Tributo
                        ,pr_cdrefere IN craplft.nrrefere%TYPE -- Codigo de Referencia
                        ,pr_dtlimite IN crapdat.dtmvtolt%TYPE -- Data de Limite
                        ,pr_vlrecbru IN craplft.vlrecbru%TYPE -- Valor da receita bruta acumulada.
                        ,pr_vlpercen IN craplft.vlpercen%TYPE -- Percentual da guia.
                        ,pr_vllanmto IN craplft.vllanmto%TYPE -- Valor da fatura
                        ,pr_vlrmulta IN craplft.vlrmulta%TYPE -- Valor da multa
                        ,pr_vlrjuros IN craplft.vlrjuros%TYPE -- Valor dos juros   
                        ,pr_dsnomfon IN craplft.dsnomfon%TYPE -- Nome / Telefone 
                        ,pr_foco     OUT VARCHAR2             --                        
                        ,pr_dscliter OUT VARCHAR2             --
                        ,pr_cdultseq OUT INTEGER              --
                        ,pr_cdcritic OUT INTEGER              -- Codigo do erro
                        ,pr_dscritic OUT VARCHAR2) IS         -- Descricao do erro
  
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_paga_darf             Antigo: dbo/b1crap41.p/paga-darf
  --  Sistema  : Procedure de pagamento da DARF
  --  Sigla    : CRED
  --  Autor    : Jean Michel
  --  Data     : Julho/2016.                   Ultima atualizacao: 03/04/2017
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Procedure de pagamento da DARF
  --
  -- Alteracoes: 03/04/2017 - Retirar a soma do nrseqdig do craplot desta rotina pois ja esta
  --                          sendo efetuado na LOTE0001.pc_insere_lote (Lucas Eduardo Ranghetti #633737)
  --
  ---------------------------------------------------------------------------------------------------------------
  BEGIN
    DECLARE
  
      rw_craplot LOTE0001.cr_craplot%ROWTYPE;
   
      CURSOR cr_crapscn(pr_cdempres crapscn.cdempres%TYPE) IS
        SELECT scn.cdempres
          FROM crapscn scn
         WHERE scn.cdempres = pr_cdempres;
      
      rw_crapscn cr_crapscn%ROWTYPE;
      
      --Variaveis de Erro
      vr_cdcritic crapcri.cdcritic%TYPE := NULL;
      vr_dscritic VARCHAR2(4000)        := NULL;
      
      --Variaveis Excecao
      vr_exc_erro EXCEPTION;
      vr_exc_null EXCEPTION;
      
      --Tipo de Dados para cursor data
      rw_crapdat  BTCH0001.cr_crapdat%ROWTYPE;

      -- Variaveis Locais
	  vr_cdrefere craplft.nrrefere%TYPE;
      vr_vlrtotal NUMBER(20,5) := 0;
      vr_cdseqfat NUMBER       := 0;
      vr_nrdolote craplot.nrdolote%TYPE := 0;
      vr_cdempres crapscn.cdempres%TYPE := 0;
      vr_registro ROWID;
      vr_progress_recid_lft craplft.progress_recid%TYPE;
      
    BEGIN

      -- Inicializar variaveis retorno
      pr_cdcritic:= NULL;
      pr_dscritic:= NULL;
      
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
        RAISE vr_exc_erro;
      ELSE
        -- Apenas fechar o cursor
        CLOSE btch0001.cr_crapdat;
      END IF;

      CXON0000.pc_elimina_erro(pr_cooper      => pr_cdcooper   -- Codigo cooperativa
                              ,pr_cod_agencia => pr_cdagenci   -- Codigo agencia
                              ,pr_nro_caixa   => pr_nrdcaixa   -- Numero Caixa
                              ,pr_cdcritic    => vr_cdcritic   -- Codigo do erro
                              ,pr_dscritic    => vr_dscritic); -- Descricao do erro

      -- Se ocorreu erro
      IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
        -- Levantar Excecao
        RAISE vr_exc_erro;
      END IF;

      vr_vlrtotal := (pr_vllanmto + pr_vlrmulta + pr_vlrjuros);
     
      -- Consulta de sequencial único para DARFs
      CXON0041.pc_busca_sequencial_darf(pr_dtapurac => pr_dtapurac
                                       ,pr_nrcpfcgc => pr_nrcpfcgc
                                       ,pr_cdtribut => pr_cdtribut
                                       ,pr_dtlimite => pr_dtlimite
                                       ,pr_vlrtotal => vr_vlrtotal
                                       ,pr_cdseqfat => vr_cdseqfat
                                       ,pr_cdcritic => vr_cdcritic
                                       ,pr_dscritic => vr_dscritic);
      
      -- Se ocorreu erro
      IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
        -- Levantar Excecao
        RAISE vr_exc_erro;
      END IF;

      IF pr_vllanmto = 0 AND vr_vlrtotal = 0 THEN  
        vr_cdcritic := 0;
        vr_dscritic := 'Valor deve ser informado.';
        pr_foco     := '14';
        RAISE vr_exc_erro;
      END IF;

      vr_nrdolote := 15000 + pr_nrdcaixa;
      /*[PROJETO LIGEIRINHO] Esta função retorna verdadeiro, quando o processo foi iniciado pela rotina:
       PAGA0001.pc_efetua_debitos_ligeir, que é chamada na rotina PC_CRPS509. Tem por finalidade definir
       se grava na tabela CRAPLOT no momento em que esta rodando a esta rotina OU somente no final da execucação
       da PC_CRPS509, para evitar o erro de lock da tabela, pois esta gravando a agencia 90,91 ou 1 ao inves de gravar
       a agencia do cooperado*/
      if not paga0001.fn_processo_ligeir then
        LOTE0001.pc_insere_lote(pr_cdcooper => pr_cdcooper
                               ,pr_dtmvtolt => rw_crapdat.dtmvtocd
                               ,pr_cdagenci => pr_cdagenci
                               ,pr_cdbccxlt => 11
                               ,pr_nrdolote => vr_nrdolote
                               ,pr_cdoperad => pr_cdoperad
                               ,pr_nrdcaixa => pr_nrdcaixa
                               ,pr_tplotmov => 13
                               ,pr_cdhistor => 1154
                               ,pr_craplot => rw_craplot
                               ,pr_dscritic => vr_dscritic);

        -- Se ocorreu erro
        IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
          -- Levantar Excecao
          RAISE vr_exc_erro;
        END IF;
      
      else
        paga0001.pc_insere_lote_wrk (pr_cdcooper => pr_cdcooper,
                                     pr_dtmvtolt => rw_crapdat.dtmvtocd,
                                     pr_cdagenci => pr_cdagenci,
                                     pr_cdbccxlt => 11,
                                     pr_nrdolote => vr_nrdolote,
                                     pr_cdoperad => pr_cdoperad,
                                     pr_nrdcaixa => pr_nrdcaixa,
                                     pr_tplotmov => 13,
                                     pr_cdhistor => 1154,
                                     pr_cdbccxpg => null,
                                     pr_nmrotina => 'CXON0041.PC_PAGA_DARF');
                            
        rw_craplot.cdcooper := pr_cdcooper;                   
        rw_craplot.dtmvtolt := rw_crapdat.dtmvtocd;                  
        rw_craplot.cdagenci := pr_cdagenci;                   
        rw_craplot.cdbccxlt := 11;                  
        rw_craplot.nrdolote := vr_nrdolote;                   
        rw_craplot.cdoperad := pr_cdoperad;  
        rw_craplot.tplotmov := 13;                   
        rw_craplot.cdhistor := 1154;
        rw_craplot.nrseqdig := paga0001.fn_seq_parale_craplcm();  
      end if;
      
      
      IF pr_cdtribut = '6106' THEN -- DARF SIMPLES
        
        OPEN cr_crapscn(pr_cdempres => 'DO');

        FETCH cr_crapscn INTO rw_crapscn;

        IF cr_crapscn%NOTFOUND THEN
          CLOSE cr_crapscn;
        ELSE
          CLOSE cr_crapscn;
          vr_cdempres := rw_crapscn.cdempres;
        END IF;
        
      ELSE -- DARF PRETO EUROPA
        OPEN cr_crapscn(pr_cdempres => 'AO');

        FETCH cr_crapscn INTO rw_crapscn;

        IF cr_crapscn%NOTFOUND THEN
          CLOSE cr_crapscn;
        ELSE
          CLOSE cr_crapscn;
          vr_cdempres := rw_crapscn.cdempres;
        END IF;
      END IF;
	  
	  IF pr_cdrefere = '0' THEN
	     vr_cdrefere := '';
      ELSE
         vr_cdrefere := pr_cdrefere;  
	  END IF;

     INSERT INTO craplft(cdcooper
		                ,nrdconta
                        ,dtapurac
                        ,nrcpfcgc
                        ,cdtribut
                        ,nrrefere
                        ,dtlimite
                        ,vlrecbru
                        ,vlpercen
                        ,vllanmto
                        ,vlrmulta
                        ,vlrjuros
                        ,tpfatura
                        ,cdempcon
                        ,cdsegmto
                        ,dtmvtolt
                        ,cdagenci
                        ,cdbccxlt
                        ,nrdolote
                        ,dtvencto
                        ,nrseqdig
                        ,cdseqfat
                        ,insitfat
                        ,cdhistor
                        ,dsnomfon)
            VALUES(pr_cdcooper
				  ,pr_nrdconta
                  ,pr_dtapurac
                  ,pr_nrcpfcgc
                  ,LPAD(pr_cdtribut,4,'0')
                  ,vr_cdrefere
                  ,pr_dtlimite
                  ,pr_vlrecbru
                  ,pr_vlpercen 
                  ,pr_vllanmto
                  ,pr_vlrmulta
                  ,pr_vlrjuros
                  ,2  
                  ,0 
                  ,6
                  ,rw_craplot.dtmvtolt
                  ,rw_craplot.cdagenci
                  ,rw_craplot.cdbccxlt
                  ,rw_craplot.nrdolote
                  ,rw_crapdat.dtmvtocd
                  ,rw_craplot.nrseqdig
                  ,vr_cdseqfat
                  ,1
                  ,1154
                  ,pr_dsnomfon)
        RETURNING progress_recid INTO vr_progress_recid_lft;
      
     
      /*[PROJETO LIGEIRINHO] Esta função retorna verdadeiro, quando o processo foi iniciado pela rotina:
      PAGA0001.pc_efetua_debitos_ligeir, que é chamada na rotina PC_CRPS509. Tem por finalidade definir se este update
      deve ser feito agora ou somente no final. da execução da PC_CRPS509 (chamada da paga0001.pc_atualiz_lote)*/
      if not paga0001.fn_processo_ligeir then
        UPDATE craplot
           SET craplot.qtcompln = rw_craplot.qtcompln + 1
              ,craplot.qtinfoln = rw_craplot.qtinfoln + 1
              ,craplot.vlcompcr = rw_craplot.vlcompcr + (pr_vllanmto + pr_vlrmulta + pr_vlrjuros)
              ,craplot.vlinfocr = rw_craplot.vlinfocr + (pr_vllanmto + pr_vlrmulta + pr_vlrjuros)
         WHERE craplot.ROWID = rw_craplot.rowid;
      end if;
      
      CXON0000.pc_grava_autenticacao_internet(pr_cooper => pr_cdcooper
                                             ,pr_nrdconta => pr_nrdconta
                                             ,pr_idseqttl => pr_idseqttl     
                                             ,pr_cod_agencia => pr_cdagenci
                                             ,pr_nro_caixa => pr_nrdcaixa
                                             ,pr_cod_operador => pr_cdoperad
                                             ,pr_valor => vr_vlrtotal
                                             ,pr_docto => rw_craplot.nrseqdig
                                             ,pr_operacao => FALSE
                                             ,pr_status => '1'
                                             ,pr_estorno => FALSE
                                             ,pr_histor => 1154 -- = craplft.cdhistor
                                             ,pr_data_off => NULL
                                             ,pr_sequen_off => 0
                                             ,pr_hora_off => 0
                                             ,pr_seq_aut_off => 0
                                             ,pr_cdempres => vr_cdempres
                                             ,pr_literal => pr_dscliter
                                             ,pr_sequencia => pr_cdultseq
                                             ,pr_registro =>  vr_registro
                                             ,pr_cdcritic => vr_cdcritic
                                             ,pr_dscritic => vr_dscritic);

      -- Se ocorreu erro
      IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
        -- Levantar Excecao
        RAISE vr_exc_erro;
      END IF;

      -- Atualiza sequencia Autenticacao
      UPDATE craplft
         SET craplft.nrautdoc = pr_cdultseq
       WHERE craplft.progress_recid = vr_progress_recid_lft;

    EXCEPTION
      WHEN vr_exc_null THEN
        pr_cdcritic := 0;
        pr_dscritic := NULL;
      WHEN vr_exc_erro THEN
        -- Se foi retornado apenas código
        IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
          -- Buscar a descrição
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;
        
        -- Devolvemos código e critica encontradas
        pr_cdcritic := NVL(vr_cdcritic,0);
        pr_dscritic := vr_dscritic;
        
        -- Efetuar ROLLBACK
        ROLLBACK;

      WHEN OTHERS THEN
        pr_cdcritic:= 0;
        pr_dscritic:= 'Erro na rotina CXON0041.pc_paga_darf. Erro: ' || SQLERRM;
    END;
  END pc_paga_darf;

END CXON0041;
/
