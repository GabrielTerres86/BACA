CREATE OR REPLACE PACKAGE CECRED.EMPR0003 AS

  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : EMPR0003
  --  Sistema  : Impress�o de contratos de emprestimos
  --  Sigla    : EMPR
  --  Autor    : Andrino Carlos de Souza Junior (RKAM)
  --  Data     : agosto/2014.                   Ultima atualizacao: 20/06/2016
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Agrupar rotinas para impress�o de contratos de emprestimos
  --
  -- Alteracoes: 05/11/2014 - Incluir temp-table com os intevenientes garantidores (Andrino-RKAM)
  --
  --             05/01/2015 - (Chamado 229247) - Novo relatorio incluido nos contratos de emprestimos (Tiago Castro - RKAM).
  --
  --             03/08/2015 - Incluir verifica��o para que se o documento for de portabilidade ent�o � usado ou o relat�rio 
  --                          'crrl100_18_portab' ou 'crrl100_05_portab'.(Lombardi)
  --
  --             26/11/2015 - Adicionado nova validacao de origem "MICROCREDITO PNMPO BNDES CECRED" na procedure 
  --                          pc_imprime_contrato_xml conforme solicitado no chamado 360165 (Kelvin)  
  --
  --             20/06/2016 - Correcao para o uso correto do indice da CRAPTAB na function fn_verifica_interv 
  --                          desta package.(Carlos Rafael Tanholi).  
  --
  ---------------------------------------------------------------------------------------------------------------

  -- Verifica da TAB016 se o interveniente esta habilitado
  FUNCTION fn_verifica_interv(pr_cdagenci IN crapass.cdagenci%TYPE
                             ,pr_cdcooper IN crapcop.cdcooper%TYPE
                             ) RETURN VARCHAR2;

  /* Verifica se o CPF/CNPJ informado como sendo proprietario do bem, faz
        parte do contrato sendo CONTRATANTE OU INTERVENIENTE ANUENTE */

  PROCEDURE pc_dados_proprietario (pr_nrcpfbem   IN crapass.nrcpfcgc%TYPE
                                  ,pr_cdcooper   IN crapcop.cdcooper%TYPE
                                  ,pr_nrdconta   IN crapass.nrdconta%TYPE
                                  ,pr_nrctremp   IN crawepr.nrctremp%TYPE
                                  ,pr_nmdavali   OUT VARCHAR2
                                  ,pr_dados_pess OUT VARCHAR2
                                  ,pr_dsendere   OUT VARCHAR2
                                  ,pr_nrnmconjug OUT VARCHAR2
                                  );

  PROCEDURE pc_busca_avalista (pr_cdcooper IN crapcop.cdcooper%TYPE
                              ,pr_nrdconta IN crapepr.nrdconta%TYPE
                              ,pr_nrctremp IN crapepr.nrctremp%TYPE
                              ,pr_nrseqava IN INTEGER
                              ,pr_nmdavali OUT crapavt.nmdavali%TYPE
                              ,pr_nrcpfcgc OUT VARCHAR2
                              ,pr_dsendres OUT VARCHAR2
                              ,pr_nrfonres OUT crapavt.nrfonres%TYPE
                              ,pr_nmconjug OUT crapavt.nmconjug%TYPE
                              ,pr_nrcpfcjg OUT VARCHAR2
                              );

  FUNCTION fn_verifica_cdc(pr_cdcooper IN crapcop.cdcooper%TYPE
                          ,pr_dslcremp IN craplcr.dslcremp%TYPE)
                           RETURN VARCHAR2;

  PROCEDURE pc_busca_bens (pr_cdcooper IN crapcop.cdcooper%TYPE
                          ,pr_nrdconta IN crapass.nrdconta%TYPE
                          ,pr_nrctremp IN crawepr.nrctremp%TYPE
                          ,pr_cdagenci IN crapass.cdagenci%TYPE
                          );

  /* Rotina para impressao de contratos de emprestimo */
  PROCEDURE pc_imprime_contrato_xml(pr_cdcooper IN crapcop.cdcooper%TYPE              --> Codigo da Cooperativa
                                   ,pr_nrdconta IN crapepr.nrdconta%TYPE              --> Numero da conta do emprestimo
                                   ,pr_nrctremp IN crapepr.nrctremp%TYPE              --> Numero do contrato de emprestimo
                                   ,pr_inimpctr IN INTEGER DEFAULT 0                  --> Impressao de contratos nao negociaveis
                                   ,pr_xmllog   IN VARCHAR2                           --> XML com informa��es de LOG
                                   ,pr_cdcritic OUT crapcri.cdcritic%TYPE             --> Codigo da critica
                                   ,pr_dscritic OUT VARCHAR2                          --> Descricao da critica
                                   ,pr_retxml   IN OUT NOCOPY XMLType                 --> Arquivo de retorno do XML
                                   ,pr_nmdcampo OUT VARCHAR2                          --> Nome do campo com erro
                                   ,pr_des_erro OUT VARCHAR2);                        --> Erros do processo

  /* Rotina para impressao do relatorio  crrl_42 */
  PROCEDURE pc_gera_perfil_empr(pr_cdcooper IN crawepr.cdcooper%TYPE  --> C�digo da cooperativa
                                ,pr_nrdconta IN crawepr.nrdconta%TYPE --> Numero da conta
                                ,pr_nrctremp IN crawepr.nrctremp%TYPE --> nro do contrato
                                ,pr_cdcritic OUT PLS_INTEGER          --> C�digo da cr�tica
                                ,pr_dscritic OUT VARCHAR2             --> Descri��o da cr�tica
                                ,pr_retxml   IN OUT CLOB              --> Arquivo de retorno do XML
                                );

  /* Imprime o demonstrativo do contrato de emprestimo pre-aprovado */
  PROCEDURE pc_gera_demonst_pre_aprovado(pr_cdcooper IN crawepr.cdcooper%TYPE --> C�digo da Cooperativa
                                        ,pr_cdagenci IN crawepr.nrdconta%TYPE --> C�digo da Agencia
                                        ,pr_nrdcaixa IN INTEGER               --> Numero do Caixa                                        
                                        ,pr_cdoperad IN crapope.cdoperad%TYPE --> C�digo do Operador
                                        ,pr_cdprogra IN crapprg.cdprogra%TYPE --> C�digo do Programa
                                        ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE --> Data do Movimento
                                        ,pr_nmarqimp IN VARCHAR2              --> Caminho do arquivo 
                                        ,pr_nmarqpdf OUT VARCHAR2             --> Nome Arquivo PDF
                                        ,pr_des_reto OUT VARCHAR2);           --> Descri��o do retorno


END EMPR0003;
/
CREATE OR REPLACE PACKAGE BODY CECRED.EMPR0003 AS

  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : EMPR0003
  --  Sistema  : Impress�o de contratos de emprestimos
  --  Sigla    : EMPR
  --  Autor    : Andrino Carlos de Souza Junior (RKAM)
  --  Data     : agosto/2014.                   Ultima atualizacao: 20/06/2016
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Agrupar rotinas para impress�o de contratos de emprestimos
  --
  -- Alteracoes: 05/11/2014 - Incluir temp-table com os intevenientes garantidores (Andrino-RKAM)
  --
  --             05/01/2015 - (Chamado 229247) - Novo relatorio incluido nos contratos de emprestimos (Tiago Castro - RKAM).
  --
  --             03/08/2015 - Incluir verifica��o para que se o documento for de portabilidade ent�o � usado ou o relat�rio 
  --                          'crrl100_18_portab' ou 'crrl100_05_portab'.(Lombardi)
  --
  --             26/11/2015 - Adicionado nova validacao de origem "MICROCREDITO PNMPO BNDES CECRED" na procedure 
  --                          pc_imprime_contrato_xml conforme solicitado no chamado 360165 (Kelvin)                
  --
  --             20/01/2016 - Adicionei o parametro pr_idorigem na chamada da procedure pc_imprime_emprestimos_cet
  --                          dentro da procedure pc_imprime_contrato_xml.
  --                          (Carlos Rafael Tanholi - Projeto 261 Pr�-aprovado fase 2)                          
  --
  --             20/06/2016 - Correcao para o uso correto do indice da CRAPTAB na function fn_verifica_interv 
  --                          desta package.(Carlos Rafael Tanholi).
  --
  ---------------------------------------------------------------------------------------------------------------


   ---------------------------- ESTRUTURAS DE REGISTRO ---------------------
      --guarda informacoes dos bens para xml
      TYPE typ_reg_bens IS
        RECORD ( nrcpfbem  crapbpr.nrcpfbem%TYPE
                ,dsbem     crapbpr.dsbemfin%TYPE
                ,dschassi  VARCHAR2(200)
                ,nrdplaca  VARCHAR2(15)
                ,nrrenava  VARCHAR2(40)
                ,dsanomod  VARCHAR2(40)
                ,dscorbem  VARCHAR2(150)
                ,avaliacao crapbpr.vlmerbem%TYPE
                ,proprietario   VARCHAR2(200)
                ,dados_pessoais VARCHAR2(200)
                ,endereco       VARCHAR2(300)
                ,conjuge        VARCHAR2(300)
                ,dscatbem  crapbpr.dscatbem%TYPE
                );
      TYPE typ_tab_bens IS
        TABLE OF typ_reg_bens
          INDEX BY VARCHAR2(163); --> 27 CPF do bem + 35 Chassi + 101 Bem
      vr_tab_bens typ_tab_bens;

      --guarda informacoes dos intervenientes garantidores
      TYPE typ_reg_interv IS
        RECORD ( inprimei VARCHAR2(01),
                 insegund VARCHAR2(02)
                );
      TYPE typ_tab_interv IS
        TABLE OF typ_reg_interv
          INDEX BY PLS_INTEGER;
      vr_tab_interv typ_tab_interv;

      vr_des_chave  VARCHAR2(163);
      vr_des_chave_interv PLS_INTEGER := 0;
      -- Tratamento de erros
      vr_exc_saida  EXCEPTION;
      vr_cdcritic   PLS_INTEGER;
      vr_dscritic   VARCHAR2(4000);
      vr_flginterv  VARCHAR2(1) := '';

  FUNCTION fn_verifica_interv(pr_cdagenci IN crapass.cdagenci%TYPE
                             ,pr_cdcooper IN crapcop.cdcooper%TYPE
                             ) RETURN VARCHAR2 IS

  /* .............................................................................

       Programa: fn_verifica_interv
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Tiago Castro (RKAM)
       Data    : Agosto/2014.                         Ultima atualizacao: 26/01/2015

       Dados referentes ao programa:

       Frequencia: Sempre que for chamado.
       Objetivo  : Verifica da TAB016 se o interveniente esta habilitado

       Alteracoes: 26/01/2015 - Alterado o formato do campo nrctremp para 8
                                caracters (Kelvin - 233714)

    ............................................................................. */

  -- tabela generica para busca de interveniente habilitado
  CURSOR cr_craptab IS
    SELECT  decode(substr(craptab.dstextab,56,03),'yes', 'TRUE', 'FALSE') habilitado
    FROM    craptab
    WHERE   craptab.cdcooper = pr_cdcooper
    AND     UPPER(craptab.nmsistem) = 'CRED'
    AND     UPPER(craptab.tptabela) = 'USUARI'
    AND     craptab.cdempres = 11
    AND     UPPER(craptab.cdacesso) = 'PROPOSTEPR'
    AND     craptab.tpregist IN (pr_cdagenci,0);

    vr_flg_inter VARCHAR2(5);-- flag de interveniente habilitado

  BEGIN
    OPEN cr_craptab; -- busca informacoes se interveniente esta habilitado
    FETCH cr_craptab INTO vr_flg_inter;
    CLOSE cr_craptab;
    RETURN nvl(vr_flg_inter, 'FALSE'); -- retorna true ou false

  END fn_verifica_interv;

  PROCEDURE pc_dados_proprietario (pr_nrcpfbem   IN crapass.nrcpfcgc%TYPE
                                  ,pr_cdcooper   IN crapcop.cdcooper%TYPE
                                  ,pr_nrdconta   IN crapass.nrdconta%TYPE
                                  ,pr_nrctremp   IN crawepr.nrctremp%TYPE
                                  ,pr_nmdavali   OUT VARCHAR2
                                  ,pr_dados_pess OUT VARCHAR2
                                  ,pr_dsendere   OUT VARCHAR2
                                  ,pr_nrnmconjug OUT VARCHAR2
                                  ) IS

  /* .............................................................................

       Programa: pc_dados_proprietario
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Tiago Castro (RKAM)
       Data    : Agosto/2014.                         Ultima atualizacao:

       Dados referentes ao programa:

       Frequencia: Sempre que for chamado.
       Objetivo  : Verifica se o CPF/CNPJ informado como sendo proprietario do bem, faz
                   parte do contrato sendo CONTRATANTE OU INTERVENIENTE ANUENTE,
                   retorna os dados do interveniente e conjuge

       Alteracoes:

    ............................................................................. */



    -- busca nome do associado
  CURSOR cr_crapass(pr_cursor INTEGER) IS
    SELECT  'Nome Propriet�rio (interveniente garantidor): '||crapass.nmprimtl nmprimtl,
            'Dados pessoais: '||decode(crapass.inpessoa,1,'CPF','CNPJ')||
            ' n.� '||gene0002.fn_mask_cpf_cnpj(crapass.nrcpfcgc, crapass.inpessoa)||
            decode(crapass.inpessoa,1,' RG n.� '||crapass.nrdocptl||decode(trim(gnetcvl.rsestcvl), NULL, NULL ,', com o estado civil ')||
                                      gnetcvl.rsestcvl,'') dados_pessoais,
            'Endere�o: '||crapenc.dsendere||', n� '||crapenc.nrendere||', bairro '||crapenc.nmbairro ||', da cidade de '||
            crapenc.nmcidade||'/'||crapenc.cdufende||', CEP '||gene0002.fn_mask_cep(crapenc.nrcepend) dsendere,
            DECODE(nvl(crapass_2.nmprimtl,TRIM(crapcje.nmconjug)),NULL,NULL,'C�njuge: '||nvl(crapass_2.nmprimtl,crapcje.nmconjug)) ||
            DECODE(nvl(crapass_2.nrcpfcgc,NVL(crapcje.nrcpfcjg,0)),0,'',' CPF n.� '||gene0002.fn_mask_cpf_cnpj(nvl(crapass_2.nrcpfcgc,crapcje.nrcpfcjg),1))||
            DECODE(nvl(crapass_2.tpdocptl,crapcje.tpdoccje),'CI',' RG n.� '|| nvl(crapass_2.nrdocptl,crapcje.nrdoccje),'')  nrnmconjug
    FROM  crapass crapass_2, -- Dados do conjuge
          crapcje,
          gnetcvl,
          crapttl,
          crapenc,
          crapass
    WHERE crapass.cdcooper = pr_cdcooper
    AND crapass.nrdconta = pr_nrdconta
    AND crapass.nrcpfcgc = pr_nrcpfbem
    AND crapenc.cdcooper (+) = crapass.cdcooper
    AND crapenc.nrdconta (+) = crapass.nrdconta
    AND crapenc.idseqttl (+) = 1
    AND crapenc.tpendass (+) = decode(crapass.inpessoa,1,10,9)
    AND crapttl.cdcooper (+) = crapass.cdcooper
    AND crapttl.nrdconta (+) = crapass.nrdconta
    AND crapttl.idseqttl (+) = 1
    AND gnetcvl.cdestcvl (+) = crapttl.cdestcvl
    AND crapcje.cdcooper (+) = crapttl.cdcooper
    AND crapcje.nrdconta (+) = crapttl.nrdconta
    AND crapcje.idseqttl (+) = crapttl.idseqttl
    AND crapass_2.cdcooper (+) = nvl(crapcje.cdcooper,0)
    AND crapass_2.nrdconta (+) = crapcje.nrctacje
    AND pr_cursor            = 1
    UNION
    SELECT  'Nome Propriet�rio (interveniente garantidor): '||crapass.nmprimtl nmprimtl,
            'Dados pessoais: '||decode(crapass.inpessoa,1,'CPF','CNPJ')||
            ' n.� '||gene0002.fn_mask_cpf_cnpj(crapass.nrcpfcgc, crapass.inpessoa)||
            decode(crapass.inpessoa,1,' RG n.� '||crapass.nrdocptl||decode(trim(gnetcvl.rsestcvl), NULL, NULL ,', com o estado civil ')||
                                      gnetcvl.rsestcvl,'') dados_pessoais,
            'Endere�o: '||crapenc.dsendere||', n� '||crapenc.nrendere||', bairro '||crapenc.nmbairro ||', da cidade de '||
            crapenc.nmcidade||'/'||crapenc.cdufende||', CEP '||gene0002.fn_mask_cep(crapenc.nrcepend) dsendere,
            DECODE(nvl(crapass_2.nmprimtl,TRIM(crapcje.nmconjug)),NULL,NULL,'C�njuge: '||nvl(crapass_2.nmprimtl,crapcje.nmconjug)) ||
            DECODE(nvl(crapass_2.nrcpfcgc,NVL(crapcje.nrcpfcjg,0)),0,'',' CPF n.� '||gene0002.fn_mask_cpf_cnpj(nvl(crapass_2.nrcpfcgc,crapcje.nrcpfcjg),1))||
            DECODE(nvl(crapass_2.tpdocptl,crapcje.tpdoccje),'CI',' RG n.� '|| nvl(crapass_2.nrdocptl,crapcje.nrdoccje),'')  nrnmconjug
    FROM  crapass crapass_2, -- Dados do conjuge
          crapcje,
          gnetcvl,
          crapttl,
          crapenc,
          crapass
    WHERE crapass.cdcooper = pr_cdcooper
    AND crapass.nrdconta = pr_nrdconta
    AND crapenc.cdcooper (+) = crapass.cdcooper
    AND crapenc.nrdconta (+) = crapass.nrdconta
    AND crapenc.idseqttl (+) = 1
    AND crapenc.tpendass (+) = decode(crapass.inpessoa,1,10,9)
    AND crapttl.cdcooper (+) = crapass.cdcooper
    AND crapttl.nrdconta (+) = crapass.nrdconta
    AND crapttl.idseqttl (+) = 1
    AND gnetcvl.cdestcvl (+) = crapttl.cdestcvl
    AND crapcje.cdcooper (+) = crapttl.cdcooper
    AND crapcje.nrdconta (+) = crapttl.nrdconta
    AND crapcje.idseqttl (+) = crapttl.idseqttl
    AND crapass_2.cdcooper (+) = nvl(crapcje.cdcooper,0)
    AND crapass_2.nrdconta (+) = crapcje.nrctacje
    AND pr_cursor            = 2;
  rw_crapass cr_crapass%ROWTYPE;

    -- busca nome do avalista
    CURSOR cr_crapavt IS
       SELECT 'Nome Propriet�rio (interveniente garantidor): '||crapavt.nmdavali nmdavali,
              DECODE(NVL(crapass.inpessoa,1),1,
                  'CPF n.�'||gene0002.fn_mask_cpf_cnpj(crapavt.nrcpfcgc, 1)||
                      ' RG n.� '||crapavt.nrdocava||decode(nvl(trim(gnetcvl.dsestcvl),trim(gnetcvl_2.dsestcvl))
                                  ,NULL, NULL, ', com o estado civil ')||nvl(trim(gnetcvl.dsestcvl),trim(gnetcvl_2.dsestcvl)),
                  'CNPJ n.� '||gene0002.fn_mask_cpf_cnpj(crapavt.nrcpfcgc, 2)) dados_pessoais,
              'Endere�o: '||crapavt.dsendres##1||', bairro '||crapavt.dsendres##2||
              ', da cidade de '||crapavt.nmcidade||'/'||crapavt.cdufresd||', CEP '||gene0002.fn_mask_cep(crapavt.nrcepend) dsendere,
              DECODE(TRIM(crapavt.nmconjug),NULL,NULL,'C�njuge: '||crapavt.nmconjug) ||
              DECODE(NVL(crapavt.nrcpfcjg,0),0,'',' CPF n.� '||gene0002.fn_mask_cpf_cnpj(crapavt.nrcpfcjg,1))||
              DECODE(crapavt.tpdoccjg,'CI',' RG n.� '|| crapavt.nrdoccjg,'')  nrnmconjug
      FROM  gnetcvl,
            gnetcvl gnetcvl_2,
            crapttl,
            crapass,
            crapavt
      WHERE gnetcvl.cdestcvl (+) = crapttl.cdestcvl
      AND   gnetcvl_2.cdestcvl (+) = crapavt.cdestcvl
      AND   crapavt.cdcooper = pr_cdcooper
      AND   crapavt.nrcpfcgc = pr_nrcpfbem
      AND   crapavt.nrdconta = pr_nrdconta
      AND   crapavt.nrctremp = pr_nrctremp
      AND   crapavt.tpctrato = 9
      AND   crapass.cdcooper (+) = crapavt.cdcooper
      AND   crapass.nrcpfcgc (+) = crapavt.nrcpfcgc
      AND   crapttl.cdcooper (+) = crapass.cdcooper
      AND   crapttl.nrdconta (+) = crapass.nrdconta
      AND   crapttl.idseqttl (+) = 1;
    rw_crapavt cr_crapavt%ROWTYPE;

  BEGIN
    -- busca nome do associado proprietario do bem
    OPEN cr_crapass(1);
    FETCH cr_crapass INTO rw_crapass;
    IF cr_crapass%FOUND THEN -- verifica se encontrou
      CLOSE cr_crapass;
      pr_nmdavali   := rw_crapass.nmprimtl;
      pr_dados_pess := rw_crapass.dados_pessoais;
      pr_dsendere   := rw_crapass.dsendere;
      pr_nrnmconjug := rw_crapass.nrnmconjug;
    ELSE -- se nao encontrou proprietario do bem, busca nome do proprietario da conta
      CLOSE cr_crapass;--busca nome do associado
      OPEN cr_crapavt; -- busca nome do avalista
      FETCH cr_crapavt INTO rw_crapavt;
      IF cr_crapavt%FOUND THEN -- verifica se encontrou avalista
        CLOSE cr_crapavt;

        -- Se ja passou uma vez, entao pode inserir na temp-table
        IF nvl(vr_flginterv,'N') = 'S' THEN

          -- Se ja existiu inclusao
          IF vr_tab_interv.first IS NOT NULL THEN
            -- Verifica se o indicador de segundo esta marcado
            IF vr_tab_interv(vr_tab_interv.last).insegund IS NULL THEN
              vr_tab_interv(vr_tab_interv.last).insegund := 'S';
            ELSE
              vr_tab_interv(vr_tab_interv.last+1).inprimei := 'S';
              vr_tab_interv(vr_tab_interv.last).insegund   := '';
            END IF;
          ELSE
            vr_tab_interv(1).inprimei := 'S';
            vr_tab_interv(1).insegund := '';
          END IF;
        END IF;
        vr_flginterv  := 'S';
        pr_nmdavali   := rw_crapavt.nmdavali;
        pr_dados_pess := rw_crapavt.dados_pessoais;
        pr_dsendere   := rw_crapavt.dsendere;
        pr_nrnmconjug := rw_crapavt.nrnmconjug;

      ELSE -- se nao tiver avalista busca associado
        CLOSE cr_crapavt;
        OPEN cr_crapass(2);-- busca nome do associado
        FETCH cr_crapass INTO rw_crapass;
        IF cr_crapass%FOUND THEN
          CLOSE cr_crapass;
          pr_nmdavali   := rw_crapass.nmprimtl;
          pr_dados_pess := rw_crapass.dados_pessoais;
          pr_dsendere   := rw_crapass.dsendere;
          pr_nrnmconjug := rw_crapass.nrnmconjug;
        ELSE
          CLOSE cr_crapass;
          -- retorna nullo se nao encontrar dados
          pr_nmdavali   := NULL;
          pr_dados_pess := NULL;
          pr_dsendere   := NULL;
          pr_nrnmconjug := NULL;
        END IF;
      END IF;
    END IF;

  END pc_dados_proprietario;

  PROCEDURE pc_busca_avalista (pr_cdcooper IN crapcop.cdcooper%TYPE
                              ,pr_nrdconta IN crapepr.nrdconta%TYPE
                              ,pr_nrctremp IN crapepr.nrctremp%TYPE
                              ,pr_nrseqava IN INTEGER
                              ,pr_nmdavali OUT crapavt.nmdavali%TYPE
                              ,pr_nrcpfcgc OUT VARCHAR2
                              ,pr_dsendres OUT VARCHAR2
                              ,pr_nrfonres OUT crapavt.nrfonres%TYPE
                              ,pr_nmconjug OUT crapavt.nmconjug%TYPE
                              ,pr_nrcpfcjg OUT VARCHAR2
                              )IS

  -- Busca os dados sobre a tabela de avalistas
  CURSOR cr_crapavt IS
    SELECT crapavt.nmdavali,
           gene0002.fn_mask_cpf_cnpj(crapavt.nrcpfcgc,crapavt.inpessoa) nrcpfcgc,
           crapavt.dsendres##1 ||' '||crapavt.nrendere||', '||decode(trim(crapavt.complend),null,'',crapavt.complend||', ')||
                  crapavt.dsendres##2||' - '||crapavt.nmcidade||' - '||gene0002.fn_mask_cep(crapavt.nrcepend)||' - '||
                  crapavt.cdufresd dsendres,
           crapavt.nrfonres,
           crapavt.nmconjug,
           crapavt.nrcpfcjg
      FROM crapavt
    WHERE cdcooper = pr_cdcooper
      AND nrdconta = pr_nrdconta
      AND nrctremp = pr_nrctremp
      AND tpctrato = 1; -- avalista

  CURSOR cr_crawepr_av IS
    SELECT nvl(crapass.nmprimtl,crawepr.nmdaval1) nmdaval1,
           gene0002.fn_mask_cpf_cnpj(crapass.nrcpfcgc, crapass.inpessoa) dscpfav1,
           decode(crapass.nrdconta,NULL,
              crawepr.dsendav1##1||', '||crawepr.dsendav1##2,
              crapenc.dsendere||', n� '||crapenc.nrendere||', bairro '||crapenc.nmbairro ||', da cidade de '||
                crapenc.nmcidade||'/'||crapenc.cdufende||', CEP '||gene0002.fn_mask_cep(crapenc.nrcepend)) dsendres_1,
           (SELECT craptfc.nrdddtfc||craptfc.nrtelefo FROM craptfc
                                          WHERE cdcooper = crapass.cdcooper
                                            AND nrdconta = crapass.nrdconta
                                            AND idseqttl = 1
                                            AND cdseqtfc = (SELECT MIN(cdseqtfc)
                                                              FROM craptfc
                                                             WHERE cdcooper = crapass.cdcooper
                                                               AND nrdconta = crapass.nrdconta
                                                               AND idseqttl = 1)) nrtelefo,
           nvl(nvl(crapass_cje.nmprimtl,crapcje.nmconjug),crawepr.nmcjgav1) nmcjgav1,
           gene0002.fn_mask_cpf_cnpj(nvl(crapass_cje.nrcpfcgc,crapcje.nrcpfcjg),1) nrcpfcjg_1,
           nvl(crapass_2.nmprimtl,crawepr.nmdaval2) nmdaval2,
           gene0002.fn_mask_cpf_cnpj(crapass_2.nrcpfcgc, crapass_2.inpessoa) dscpfav2,
           decode(crapass_2.nrdconta,NULL,
              crawepr.dsendav2##1||', '||crawepr.dsendav2##2,
              crapenc_2.dsendere||', n� '||crapenc_2.nrendere||', bairro '||crapenc_2.nmbairro ||', da cidade de '||
                crapenc_2.nmcidade||'/'||crapenc_2.cdufende||', CEP '||gene0002.fn_mask_cep(crapenc_2.nrcepend)) dsendres_2,
           (SELECT craptfc.nrdddtfc||craptfc.nrtelefo FROM craptfc
                                          WHERE cdcooper = crapass_2.cdcooper
                                            AND nrdconta = crapass_2.nrdconta
                                            AND idseqttl = 1
                                            AND cdseqtfc = (SELECT MIN(cdseqtfc)
                                                              FROM craptfc
                                                             WHERE cdcooper = crapass_2.cdcooper
                                                               AND nrdconta = crapass_2.nrdconta
                                                               AND idseqttl = 1)) nrtelefo_2,
           nvl(nvl(crapass_cje_2.nmprimtl,crapcje_2.nmconjug),crawepr.nmcjgav2) nmcjgav2,
           gene0002.fn_mask_cpf_cnpj(nvl(crapass_cje_2.nrcpfcgc,crapcje_2.nrcpfcjg),1) nrcpfcjg_2
      FROM crapenc crapenc_2, -- endereco do avalista 1
           crapass crapass_cje_2, -- Conjuge do associado quando o mesmo possui conta
           crapcje crapcje_2, -- conjuge do avalista 2
           crapass crapass_2, -- Associado do avalista 2
           crapass crapass_cje, -- Conjuge do associado quando o mesmo possui conta
           crapenc, -- endereco do avalista 1
           crapcje, -- conjuge do avalista 1
           crapass, -- Associado do avalista 1
           crawepr
     WHERE crawepr.cdcooper = pr_cdcooper
       AND crawepr.nrdconta = pr_nrdconta
       AND crawepr.nrctremp = pr_nrctremp
       AND crapass.cdcooper (+) = crawepr.cdcooper
       AND crapass.nrdconta (+) = crawepr.nrctaav1
       AND crapcje.cdcooper (+) = crawepr.cdcooper
       AND crapcje.nrdconta (+) = crawepr.nrctaav1
       AND crapcje.idseqttl (+) = 1
       AND crapenc.cdcooper (+) = crapass.cdcooper
       AND crapenc.nrdconta (+) = crapass.nrdconta
       AND crapenc.idseqttl (+) = 1
       AND crapenc.tpendass (+) = decode(crapass.inpessoa,1,10,9)
       AND crapass_cje.cdcooper (+) = crapcje.cdcooper
       AND crapass_cje.nrdconta (+) = crapcje.nrctacje
       AND crapass_2.cdcooper (+) = crawepr.cdcooper
       AND crapass_2.nrdconta (+) = crawepr.nrctaav2
       AND crapcje_2.cdcooper (+) = crawepr.cdcooper
       AND crapcje_2.nrdconta (+) = crawepr.nrctaav2
       AND crapcje_2.idseqttl (+) = 1
       AND crapass_cje_2.cdcooper (+) = crapcje_2.cdcooper
       AND crapass_cje_2.nrdconta (+) = crapcje_2.nrctacje
       AND crapenc_2.cdcooper (+) = crapass_2.cdcooper
       AND crapenc_2.nrdconta (+) = crapass_2.nrdconta
       AND crapenc_2.idseqttl (+) = 1
       AND crapenc_2.tpendass (+) = decode(crapass_2.inpessoa,1,10,9);
  rw_crawepr_av cr_crawepr_av%ROWTYPE;

  ww_nmdavali_org crapavt.nmdavali%TYPE;

BEGIN
  FOR rw_crapavt IN cr_crapavt LOOP
    ww_nmdavali_org := rw_crapavt.nmdavali;
    IF pr_nrseqava = cr_crapavt%ROWCOUNT THEN
      pr_nmdavali := rw_crapavt.nmdavali;
      pr_nrcpfcgc := rw_crapavt.nrcpfcgc;
      pr_dsendres := rw_crapavt.dsendres;
      pr_nrfonres := rw_crapavt.nrfonres;
      pr_nmconjug := rw_crapavt.nmconjug;
      pr_nrcpfcjg := rw_crapavt.nrcpfcjg;
    END IF;
  END LOOP;

  -- Se nao encontrou, busca direto na tabela de emprestimos
  IF pr_nmdavali IS NULL THEN
    OPEN cr_crawepr_av;
    FETCH cr_crawepr_av INTO rw_crawepr_av;
    IF cr_crawepr_av%FOUND THEN
      IF (pr_nrseqava = 1 AND
          trim(rw_crawepr_av.nmdaval1) IS NOT NULL AND
          rw_crawepr_av.nmdaval1 <> nvl(ww_nmdavali_org,' ')) OR
         (pr_nrseqava = 2 AND
          trim(rw_crawepr_av.nmdaval2) IS NOT NULL AND
          trim(rw_crawepr_av.nmdaval1) IS NOT NULL AND
          rw_crawepr_av.nmdaval1 <> nvl(ww_nmdavali_org,' ') AND
          rw_crawepr_av.nmdaval2 = nvl(ww_nmdavali_org,' ')) THEN
        pr_nmdavali := rw_crawepr_av.nmdaval1;
        pr_nrcpfcgc := rw_crawepr_av.dscpfav1;
        pr_dsendres := rw_crawepr_av.dsendres_1;
        pr_nrfonres := rw_crawepr_av.nrtelefo;
        pr_nmconjug := rw_crawepr_av.nmcjgav1;
        pr_nrcpfcjg := rw_crawepr_av.nrcpfcjg_1;
      ELSIF rw_crawepr_av.nmdaval2 IS NOT NULL AND
         rw_crawepr_av.nmdaval2 <> nvl(ww_nmdavali_org,' ') THEN
        pr_nmdavali := rw_crawepr_av.nmdaval2;
        pr_nrcpfcgc := rw_crawepr_av.dscpfav2;
        pr_dsendres := rw_crawepr_av.dsendres_2;
        pr_nrfonres := rw_crawepr_av.nrtelefo_2;
        pr_nmconjug := rw_crawepr_av.nmcjgav2;
        pr_nrcpfcjg := rw_crawepr_av.nrcpfcjg_2;
      END IF;
    END IF;
    CLOSE cr_crawepr_av;
  END IF;

  END pc_busca_avalista;

  FUNCTION fn_verifica_cdc(pr_cdcooper IN crapcop.cdcooper%TYPE
                          ,pr_dslcremp IN craplcr.dslcremp%TYPE)
                           RETURN VARCHAR2 IS
   /* .............................................................................

       Programa: fn_verifica_cdc
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Tiago Castro (RKAM)
       Data    : Junho/2015.                         Ultima atualizacao: 11/06/2015

       Dados referentes ao programa:

       Frequencia: Sempre que for chamado.
       Objetivo  : Verificar se linha credito do contrato existe no cadastro de
                   parametros CDC.

       Alteracoes:

    ............................................................................. */

    v_linhacdc VARCHAR2(1000);
    vr_busca  VARCHAR2(100);
    vr_idx      NUMBER;
    vr_cdc VARCHAR2(1);

  BEGIN
    -- Busca o texto de linha CDC
    v_linhacdc := gene0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                            pr_cdcooper =>  pr_cdcooper,
                                            pr_cdacesso =>  'LINHA_CDC')||';';

    IF v_linhacdc IS NOT NULL THEN
      LOOP
        -- Identifica ponto de quebra inicial
        vr_idx := instr(v_linhacdc, ';');
        -- Clausula de sa�da para o loop
        exit WHEN nvl(vr_idx, 0) = 0 OR vr_cdc = 'S';
        -- valor da string para pesquisa
        vr_busca := trim(substr(v_linhacdc, 1, vr_idx - 1));
        -- verifica se encontrou linha de credito existe no cadastro de CDC
        vr_cdc := gene0002.fn_contem(pr_dstexto => pr_dslcremp
                                   , pr_dsprocu => vr_busca);
        -- Atualiza a vari�vel com a string integral eliminando o bloco quebrado
        v_linhacdc := substr(v_linhacdc, vr_idx + LENGTH(';'));
      END LOOP;
    END IF;
    -- retorna se linha eh CDC ou nao
    RETURN vr_cdc;

  END fn_verifica_cdc;


/* 27/03/2015 - Ajustado para utilizar o progress_recid da crapbpr em variavel de indice de ARRAY
                que guarda os bens alienados. (Jorge/Gielow) */

  PROCEDURE pc_busca_bens (pr_cdcooper IN crapcop.cdcooper%TYPE
                          ,pr_nrdconta IN crapass.nrdconta%TYPE
                          ,pr_nrctremp IN crawepr.nrctremp%TYPE
                          ,pr_cdagenci IN crapass.cdagenci%TYPE
                          ) IS
  -- cursor sobre o cadastro de bens do associado
    CURSOR cr_crapbpr IS
      SELECT  crapbpr.nrcpfbem,
              crapbpr.dschassi dschassi2,
              crapbpr.dsbemfin,
              crapbpr.vlmerbem,
              crapbpr.dscatbem,
              'Renavan: '||crapbpr.nrrenava nrrenava,
              decode(crapbpr.dscatbem,'TERRENO','Endereco: ' ||crapbpr.dscorbem,
                                      'CASA','Endereco: ' ||crapbpr.dscorbem,
                                      'APARTAMENTO','Endereco: ' ||crapbpr.dscorbem,
                                      'MAQUINA DE COSTURA','Chassi/N S�rie: '||crapbpr.dschassi,
                                      'EQUIPAMENTO','Chassi/N S�rie: '||crapbpr.dschassi,
                                                    'Chassi: '||crapbpr.dschassi) dschassi,
              crapbpr.tpchassi,
              crapbpr.ufdplaca,
              'Placa: '||crapbpr.nrdplaca nrdplaca,
              crapbpr.uflicenc,
              'Ano: '||crapbpr.nranobem||' Modelo: '||crapbpr.nrmodbem dsanomod,
              'Cor: '||crapbpr.dscorbem dscorbem,
              progress_recid
      FROM    crapbpr
      WHERE   crapbpr.cdcooper = pr_cdcooper
      AND     crapbpr.nrdconta = pr_nrdconta
      AND     crapbpr.nrctrpro = pr_nrctremp
      AND     crapbpr.tpctrpro = 90
      AND     crapbpr.flgalien = 1
      ORDER BY crapbpr.progress_recid;

  vr_proprietario   VARCHAR2(120);
  vr_dados_pessoais VARCHAR2(110);
  vr_endereco       VARCHAR2(200);
  vr_conjuge        VARCHAR2(200);
  vr_flg_inter      VARCHAR2(5);    --> flag verificar de interveniente esta habilitado
  BEGIN
      -- busca bens da proposta
      FOR rw_crapbpr IN cr_crapbpr
      LOOP
        vr_proprietario   := NULL;
        vr_dados_pessoais := NULL;
        vr_endereco       := NULL;
        vr_conjuge        := NULL;

        -- Verifica se o CPF/CNPJ informado como sendo proprietario do bem, faz
        -- parte do contrato sendo CONTRATANTE OU INTERVENIENTE ANUENTE
        pc_dados_proprietario(pr_nrcpfbem    => rw_crapbpr.nrcpfbem
                           , pr_cdcooper    => pr_cdcooper
                           , pr_nrdconta    => pr_nrdconta
                           , pr_nrctremp    => pr_nrctremp
                           , pr_nmdavali    => vr_proprietario
                           , pr_dados_pess  => vr_dados_pessoais
                           , pr_dsendere    => vr_endereco
                           , pr_nrnmconjug  => vr_conjuge
                           );

        IF vr_proprietario IS NULL THEN -- caso nao encontr o proprietario
          /* verifica se o interveniente esta habilitado */
          vr_flg_inter := fn_verifica_interv(pr_cdagenci => pr_cdagenci --rw_crapavi_01.cdagenci
                                           , pr_cdcooper => pr_cdcooper
                                            );
          IF vr_flg_inter = 'FALSE' THEN -- nao encontrou ou interveniente nao nao faz parte do contrato
            vr_dscritic := 'O Proprietario do bem '||
                           TRIM(substr(rw_crapbpr.dsbemfin, 1, 18))||
                           'nao faz parte do contrato.'; --monta critica
            RAISE vr_exc_saida; -- encerra programa e retorna critica
          END IF;
        END IF;
        --popula temp table bens
        --vr_des_chave := lpad(rw_crapbpr.nrcpfbem,27,'0')||lpad(rw_crapbpr.dschassi2,35,'0')||lpad(rw_crapbpr.dsbemfin, 101, '0');
        vr_des_chave := rw_crapbpr.progress_recid;
        vr_tab_bens(vr_des_chave).nrcpfbem        := rw_crapbpr.nrcpfbem;
        vr_tab_bens(vr_des_chave).dsbem           := rw_crapbpr.dsbemfin;
        vr_tab_bens(vr_des_chave).dschassi        := rw_crapbpr.dschassi;
        vr_tab_bens(vr_des_chave).nrdplaca        := rw_crapbpr.nrdplaca;
        vr_tab_bens(vr_des_chave).nrrenava        := rw_crapbpr.nrrenava;
        vr_tab_bens(vr_des_chave).dsanomod        := rw_crapbpr.dsanomod;
        vr_tab_bens(vr_des_chave).dscorbem        := rw_crapbpr.dscorbem;
        vr_tab_bens(vr_des_chave).avaliacao       := rw_crapbpr.vlmerbem;
        vr_tab_bens(vr_des_chave).proprietario    := vr_proprietario;
        vr_tab_bens(vr_des_chave).dados_pessoais  := vr_dados_pessoais;
        vr_tab_bens(vr_des_chave).endereco        := vr_endereco;
        vr_tab_bens(vr_des_chave).conjuge         := vr_conjuge;
        vr_tab_bens(vr_des_chave).dscatbem        := rw_crapbpr.dscatbem;
      END LOOP;

  END pc_busca_bens;



  /* Busca dos pagamentos das parcelas de empr�stimo */
  PROCEDURE pc_imprime_contrato_xml(pr_cdcooper IN crapcop.cdcooper%TYPE              --> Codigo da Cooperativa
                                   ,pr_nrdconta IN crapepr.nrdconta%TYPE              --> Numero da conta do emprestimo
                                   ,pr_nrctremp IN crapepr.nrctremp%TYPE              --> Numero do contrato de emprestimo
                                   ,pr_inimpctr IN INTEGER DEFAULT 0                  --> Impressao de contratos nao negociaveis
                                   ,pr_xmllog   IN VARCHAR2                           --> XML com informa��es de LOG
                                   ,pr_cdcritic OUT crapcri.cdcritic%TYPE             --> Codigo da critica
                                   ,pr_dscritic OUT VARCHAR2                          --> Descricao da critica
                                   ,pr_retxml   IN OUT NOCOPY XMLType                 --> Arquivo de retorno do XML
                                   ,pr_nmdcampo OUT VARCHAR2                          --> Nome do campo com erro
                                   ,pr_des_erro OUT VARCHAR2) IS                      --> Erros do processo
    /* .............................................................................

       Programa: pc_imprime_contrato_xml
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Tiago Castro (RKAM)
       Data    : Agosto/2014.                         Ultima atualizacao: 26/11/2015

       Dados referentes ao programa:

       Frequencia: Sempre que for chamado.
       Objetivo  : Efetuar a impressao do contrato de emprestimo

       Alteracoes: 05/01/2015 - (Chamado 229247) - Novo relatorio incluido nos
                                contratos de emprestimos (Tiago Castro - RKAM).
                                
                   09/06/2015 - (Projeto 209)
                                - Bloquear impressao de contratos
                                  com linha de credito CDC.
                                - Inluido contador de impressoes de contratos.
                                - Incluido novo parametro para impressao de contratos
                                  nao negociaveis.
                                - Inclusao de novo campo no XML dos contratos para
                                  ser enviado o valor do novo parametro.
                                  (Tiago Castro - RKAM)
                                  
                   26/11/2015 - Adicionado nova validacao de origem 
                                "MICROCREDITO PNMPO BNDES CECRED" conforme solicitado
                                no chamado 360165 (Kelvin)             

    ............................................................................. */

      -- Cursor sobre as informacoes de emprestimo
      CURSOR cr_crawepr IS
        SELECT crawepr.cdlcremp,
               crawepr.dtmvtolt,
               crawepr.vlemprst,
               crawepr.qtpreemp,
               crawepr.vlpreemp,
               crawepr.dtvencto,
               crawepr.qttolatr,
               crawepr.percetop,
               crawepr.nrctaav1,
               crawepr.nrctaav2,
               crapass.inpessoa,
               crapass.nrcpfcgc,
               crapass.nrdocptl,
               crapass.cdagenci,
               crapass.nmprimtl,
               crawepr.tpemprst,
               crawepr.flgpagto,
               add_months(crawepr.dtvencto,crawepr.qtpreemp -1) dtultpag,
               crawepr.dtlibera,
               crawepr.dtdpagto,
               crawepr.txmensal,
               crapage.nmcidade,
               crapage.cdufdcop,
               crawepr.nrseqrrq
          FROM crapage,
               crapass,
               crawepr
         WHERE crawepr.cdcooper = pr_cdcooper
           AND crawepr.nrdconta = pr_nrdconta
           AND crawepr.nrctremp = pr_nrctremp
           AND crapass.cdcooper = crawepr.cdcooper
           AND crapass.nrdconta = crawepr.nrdconta
           AND crapage.cdcooper = crapass.cdcooper
           AND crapage.cdagenci = crapass.cdagenci;

      rw_crawepr cr_crawepr%ROWTYPE;--armazena informacoes do cursor cr_crawepr

      -- Cursor sobre as informacoes de emprestimo
      CURSOR cr_crapepr IS
        SELECT dtmvtolt
          FROM crapepr
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta
           AND nrctremp = pr_nrctremp;

      rw_crapepr cr_crapepr%ROWTYPE;--armazena informacoes do cursor cr_crapepr

      --cursor para buscar estado civil da pessoa fisica, jurida nao tem
      CURSOR cr_gnetcvl IS
          SELECT gnetcvl.rsestcvl
          FROM  crapttl,
                gnetcvl
          WHERE crapttl.cdcooper = pr_cdcooper
          AND crapttl.nrdconta = pr_nrdconta
          AND crapttl.idseqttl = 1 -- Primeiro Titular
          AND gnetcvl.cdestcvl = crapttl.cdestcvl;
      rw_gnetcvl cr_gnetcvl%ROWTYPE;--armazena informacoes do cursor cr_gnetcvl

      -- Cursor sobre o cadastro de linhas de credito (tela LCREDI)
      CURSOR cr_craplcr(pr_cdlcremp craplcr.cdlcremp%TYPE) IS
        SELECT dsoperac,
               dslcremp,
               tplcremp,
               tpdescto,
               decode(cdusolcr,2,0,cdusolcr) cdusolcr, -- Se for Epr/Boletos, considera como normal
               txminima,
               ROUND((POWER(1 + (txminima / 100),12) - 1) * 100,2) prjurano,
               perjurmo,
               dsorgrec,
               tpctrato,
               txjurfix,
               flgcobmu
          FROM craplcr
         WHERE cdcooper = pr_cdcooper
           AND cdlcremp = pr_cdlcremp;
      rw_craplcr cr_craplcr%ROWTYPE;--armazena informacoes do cursor cr_craplcr

      -- Cursor sobre o endereco do associado
      CURSOR cr_crapenc(pr_inpessoa crapass.inpessoa%TYPE) IS
        SELECT crapenc.dsendere,
               crapenc.nrendere,
               crapenc.nmbairro,
               crapenc.nmcidade,
               crapenc.cdufende,
               crapenc.nrcepend
          FROM crapenc
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta
           AND idseqttl = 1
           AND tpendass = CASE
                          WHEN pr_inpessoa = 1 THEN
                            10 --Residencial
                          ELSE
                            9 -- Comercial
                          END;
      rw_crapenc cr_crapenc%ROWTYPE;--armazena informacoes do cursor cr_crapenc

      -- Busca dos dados da cooperativa
      CURSOR cr_crapcop IS
        SELECT cop.nmextcop
              ,cop.nmrescop
              ,cop.nrdocnpj
              ,cop.dsendcop
              ,cop.nrendcop
              ,cop.nmbairro
              ,cop.nrcepend
              ,cop.nmcidade
              ,cop.cdufdcop
              ,cop.nrtelura
              ,cop.nrtelouv
              ,cop.dsendweb
              ,cop.dsdircop
          FROM crapcop cop
         WHERE cop.cdcooper = pr_cdcooper;
      rw_crapcop cr_crapcop%ROWTYPE; --armazena informacoes do cursor cr_crapcop

      -- Cursor sobre os associados para buscar os dados do avalista
      CURSOR cr_crapass(pr_nrdconta crapass.nrdconta%TYPE
                       ,pr_inpessoa crapass.inpessoa%TYPE) IS
        SELECT crapass.nmprimtl,
               crapass.inpessoa,
               decode(crapass.inpessoa,1,'CPF:','CNPJ:') dspessoa,
               crapass.nrcpfcgc,
               crapenc.dsendere ||' no. '||crapenc.nrendere||', bairro ' ||rw_crapenc.nmbairro||
                 ', '||crapenc.nmcidade||'-'||crapenc.cdufende ||'-'||'CEP '||crapenc.nrcepend dsendere,
               crapass.nrfonemp,
              (SELECT craptfc.nrdddtfc||' '||craptfc.nrtelefo FROM craptfc
                                          WHERE cdcooper = crapass.cdcooper
                                            AND nrdconta = crapass.nrdconta
                                            AND idseqttl = 1
                                            AND cdseqtfc = (SELECT MIN(cdseqtfc)
                                                              FROM craptfc
                                                             WHERE cdcooper = crapass.cdcooper
                                                               AND nrdconta = crapass.nrdconta
                                                               AND idseqttl = 1)) nrtelefo,
               crapass.cdagenci,
               crapcje.nmconjug ,
               crapcje.nrcpfcjg cpfcjg
          FROM crapenc,
               crapass,
               crapcje
         WHERE crapass.cdcooper = pr_cdcooper
           AND crapass.nrdconta = pr_nrdconta
           AND crapenc.cdcooper = crapass.cdcooper
           AND crapenc.nrdconta = crapass.nrdconta
           AND crapcje.cdcooper (+) = crapass.cdcooper
           AND crapcje.nrdconta (+)= crapass.nrdconta
           AND crapenc.idseqttl = 1
           AND crapcje.idseqttl(+) = 1
           AND crapenc.tpendass = CASE
                                  WHEN pr_inpessoa = 1 THEN
                                    10  -- Residencial
                                  ELSE
                                    9 -- comercial
                                  END;
      rw_crapavi_01 cr_crapass%ROWTYPE; --armazena informacoes do cursor cr_crapass para avalista 1
      rw_crapavi_02 cr_crapass%ROWTYPE; --armazena informacoes do cursor cr_crapass para avalista 2

      -- Tratamento de erros
      vr_exc_saida  EXCEPTION;
      vr_cdcritic   PLS_INTEGER;
      vr_dscritic   VARCHAR2(4000);

      -- Variaveis que serao convertidas para TAGs no XML
      vr_dstitulo   VARCHAR2(200);  --> Titulo do contrato
      vr_campo_01   VARCHAR2(500);  --> Campo com os dados do emitente
      vr_emitente   VARCHAR2(500);  --> Endereco do emitente da cooperativa
      vr_coment01   VARCHAR2(2000); --> Comentario 01
      vr_campo_02   VARCHAR2(2000); --> comentario 02
      vr_nmarqim    VARCHAR2(50);   --> nome do arquivo PDF
      vr_bens       INTEGER := 1; --> para listar informacoes de veiculos

      -- Variaveis gerais
      vr_texto_completo VARCHAR2(32600);           --> Vari�vel para armazenar os dados do XML antes de incluir no CLOB
      vr_des_xml        CLOB;                      --> XML do relatorio
      vr_des_xml2       CLOB;                      --> XML do relatorio CCET
      vr_nmarqimp       VARCHAR2(15);              --> retorno da CCET
      vr_tppessoa       VARCHAR2(04);              --> Tipo de documento: CPF ou CNPJ
      vr_prmulta        number(7,2);               --> Percentual de multa
      vr_digitalizacao  VARCHAR2(80);              --> Para uso da digitalizacao
      vr_cdprogra       VARCHAR2(10) := 'EMPR0003';--> Nome do programa
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;      --> Cursor gen�rico de calend�rio
      vr_nom_direto     VARCHAR2(200);             --> Diret�rio para grava��o do arquivo
      vr_dsjasper       VARCHAR2(100);              --> nome do jasper a ser usado
      vr_taxjream       NUMBER;                    --> juros remuneratorios 30d
      vr_taxjrean       NUMBER;                    --> juros remuneratorios 365d
      vr_dados_coop     VARCHAR(290);              --> dados de contato da coop, para uso na clausula "Solucao Amigavel"
      vr_dtlibera       DATE;                      --> Data de liberacao do contrato
      vr_cdc            crapprm.dsvlrprm%TYPE;     --> String com valores de linha CDC
      vr_negociavel     VARCHAR2(1);               --> Identificados para impressao dos textos "Para uso da digitalizacao" e "nao negociavel"

      -- Vari�veis de portabilidade
      nrcnpjbase_if_origem VARCHAR2(100);
      nrcontrato_if_origem VARCHAR2(100);
      nomcredora_if_origem VARCHAR2(100);
      vr_retxml            xmltype;
      vr_portabilidade     BOOLEAN := FALSE;
      
      -- avalista e conjuge 1
      vr_nmdavali1      crapavt.nmdavali%TYPE;
      vr_nrcpfcgc1      VARCHAR2(50);
      vr_dsendres1      VARCHAR2(200);
      vr_nrfonres1      crapavt.nrfonres%TYPE;
      vr_nmconjug1      crapavt.nmconjug%TYPE;
      vr_nrcpfcjg1      VARCHAR2(50);
      --avalista e conjuge 2
      vr_nmdavali2      crapavt.nmdavali%TYPE;
      vr_nrcpfcgc2      VARCHAR2(50);
      vr_dsendres2      VARCHAR2(200);
      vr_nrfonres2      crapavt.nrfonres%TYPE;
      vr_nmconjug2      crapavt.nmconjug%TYPE;
      vr_nrcpfcjg2      VARCHAR2(50);

      -- variaveis de cr�ticas
      vr_tab_erro       GENE0001.typ_tab_erro;
      vr_des_reto       VARCHAR2(10);
      vr_typ_saida      VARCHAR2(3);

    BEGIN

      -- Leitura do calend�rio da cooperativa
      OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH btch0001.cr_crapdat INTO rw_crapdat;
      CLOSE btch0001.cr_crapdat;
      -- Inicializar o CLOB
      vr_des_xml := NULL;
      vr_texto_completo := NULL;
      dbms_lob.createtemporary(vr_des_xml, TRUE);
      dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);

      -- Abre o cursor com as informacoes do emprestimo
      OPEN cr_crawepr;
      FETCH cr_crawepr INTO rw_crawepr;
      -- Se nao encontrar o emprestimo finaliza o programa
      IF cr_crawepr%NOTFOUND THEN
        vr_dscritic := 'Emprestimo '||nvl(pr_nrctremp,0) ||' nao encontrado para impressao'; --monta critica
        CLOSE cr_crawepr;
        RAISE vr_exc_saida; -- encerra programa e retorna critica
      END IF;
      CLOSE cr_crawepr;

      -- Abre o cursor com as informacoes do emprestimo
      OPEN cr_crapepr;
      FETCH cr_crapepr INTO rw_crapepr;
      -- Se nao encontrar o emprestimo finaliza o programa
      CLOSE cr_crapepr;

      -- Busca os dados do cadastro de linhas de credito
      OPEN cr_craplcr(rw_crawepr.cdlcremp);
      FETCH cr_craplcr INTO rw_craplcr;
      -- Se nao encontrar o emprestimo finaliza o programa
      IF cr_craplcr%NOTFOUND THEN
        vr_dscritic := 'Linha de credito nao encontrada para impressao'; -- monta critica
        CLOSE cr_craplcr;
        RAISE vr_exc_saida;--encerra programa e retorna critica
      END IF;
      CLOSE cr_craplcr;

      vr_cdc := fn_verifica_cdc(pr_cdcooper => pr_cdcooper
                               ,pr_dslcremp => rw_craplcr.dslcremp);
      
      IF vr_cdc = 'S' THEN
        vr_dscritic := 'Impressao de CCB nao permitida para linhas de CDC'; -- monta critica
        RAISE vr_exc_saida;--encerra programa e retorna critica
      END IF;

      -- Verifica se a cooperativa esta cadastrada
      OPEN cr_crapcop;
      FETCH cr_crapcop INTO rw_crapcop;
      -- Se n�o encontrar
      IF cr_crapcop%NOTFOUND THEN
        -- Fechar o cursor pois haver� raise
        CLOSE cr_crapcop;
        -- Montar mensagem de critica
        vr_cdcritic := 651;
        RAISE vr_exc_saida; -- encerra programa e retorna critica 651
      ELSE
        -- Apenas fechar o cursor
        CLOSE cr_crapcop;
      END IF;

      -- Busca os dados do endereco residencial do associado
      OPEN cr_crapenc(rw_crawepr.inpessoa);
      FETCH cr_crapenc INTO rw_crapenc;
      -- Se nao encontrar o endereco finaliza o programa
      IF cr_crapenc%NOTFOUND THEN
        vr_dscritic := 'Endereco do associado nao encontrada para impressao'; -- monta critica
        CLOSE cr_crapenc;
        RAISE vr_exc_saida; -- encerra programa e retorna critica
      END IF;
      CLOSE cr_crapenc;
      -- Busca o avalista 1
      pc_busca_avalista(pr_cdcooper => pr_cdcooper
                      , pr_nrdconta => pr_nrdconta
                      , pr_nrctremp => pr_nrctremp
                      , pr_nrseqava => 1
                      , pr_nmdavali => vr_nmdavali1
                      , pr_nrcpfcgc => vr_nrcpfcgc1
                      , pr_dsendres => vr_dsendres1
                      , pr_nrfonres => vr_nrfonres1
                      , pr_nmconjug => vr_nmconjug1
                      , pr_nrcpfcjg => vr_nrcpfcjg1);

      -- Busca o avalista 2
      pc_busca_avalista(pr_cdcooper => pr_cdcooper
                      , pr_nrdconta => pr_nrdconta
                      , pr_nrctremp => pr_nrctremp
                      , pr_nrseqava => 2
                      , pr_nmdavali => vr_nmdavali2
                      , pr_nrcpfcgc => vr_nrcpfcgc2
                      , pr_dsendres => vr_dsendres2
                      , pr_nrfonres => vr_nrfonres2
                      , pr_nmconjug => vr_nmconjug2
                      , pr_nrcpfcjg => vr_nrcpfcjg2);

      -- Buscar dados de portabilidade
      CECRED.empr0006.pc_consulta_portabil_crt(pr_cdcooper   => pr_cdcooper
                                              ,pr_nrdconta   => pr_nrdconta
                                              ,pr_nrctremp   => pr_nrctremp
                                              ,pr_tpoperacao => 1
                                              ,pr_cdcritic   => vr_cdcritic
                                              ,pr_dscritic   => vr_dscritic
                                              ,pr_retxml     => vr_retxml);
                                               
      IF vr_retxml.existsNode('/Dados/inf/nrcnpjbase_if_origem') > 0 AND
         vr_retxml.existsNode('/Dados/inf/nrcontrato_if_origem') > 0 THEN
        vr_portabilidade := TRUE;
        nrcnpjbase_if_origem := TRIM(vr_retxml.extract('/Dados/inf/nrcnpjbase_if_origem/text()').getstringval());
        nrcontrato_if_origem := TRIM(vr_retxml.extract('/Dados/inf/nrcontrato_if_origem/text()').getstringval());
        nomcredora_if_origem := TRIM(vr_retxml.extract('/Dados/inf/nmif_origem/text()').getstringval());
      ELSE
        nrcnpjbase_if_origem := '';
        nrcontrato_if_origem := '';
        nomcredora_if_origem := '';
      END IF;
      
      -- Inicializa o XML
      gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo,'<?xml version="1.0" encoding="utf-8"?><contrato>');

      /*IF rw_craplcr.tplcremp <> 1 THEN  -- tipo de linha de credito <> 1=Normal
          vr_dscritic := 'Contrato fora do layout padrao';
          RAISE vr_exc_saida; -- encerra programa e retorna critica
      END IF ;*/
      -- Verifica se o documento eh um CPF ou CNPJ
      IF rw_crawepr.inpessoa = 1 THEN
        vr_tppessoa := 'CPF';
        OPEN cr_gnetcvl; -- busca estado civil
        FETCH cr_gnetcvl INTO rw_gnetcvl;
        CLOSE cr_gnetcvl;
              -- monta descricao para o relatorio com os dados do emitente
        vr_campo_01 := 'inscrito no '||vr_tppessoa||' n.� '|| gene0002.fn_mask_cpf_cnpj(rw_crawepr.nrcpfcgc, rw_crawepr.inpessoa)||
                     ' e portador do RG n.� '||rw_crawepr.nrdocptl||', com o estado civil '||rw_gnetcvl.rsestcvl||
                     ', residente e domiciliado na '||rw_crapenc.dsendere||', n.� '||rw_crapenc.nrendere||
                     ', bairro '||rw_crapenc.nmbairro|| ', da cidade de '||rw_crapenc.nmcidade||'/'||rw_crapenc.cdufende||
                     ', CEP '||gene0002.fn_mask_cep(rw_crapenc.nrcepend)||', tamb�m  qualificado na proposta de abertura de conta corrente indicada no subitem 1.1, designado Emitente.';
      ELSE -- pessoa juridica nao tem estado civil
        vr_tppessoa := 'CNPJ';
        -- monta descricao para o relatorio com os dados do emitente
        vr_campo_01 := 'inscrita no '||vr_tppessoa||' sob n.� '|| gene0002.fn_mask_cpf_cnpj(rw_crawepr.nrcpfcgc, rw_crawepr.inpessoa)||
                     ' com sede na '||rw_crapenc.dsendere||', n.� '||rw_crapenc.nrendere||
                     ', bairro '||rw_crapenc.nmbairro|| ', da cidade de '||rw_crapenc.nmcidade||'/'||rw_crapenc.cdufende||
                     ', CEP '||gene0002.fn_mask_cep(rw_crapenc.nrcepend)||', tamb�m  qualificado na proposta de abertura de conta corrente indicada no subitem 1.1, designado Emitente.';
      END IF;

      IF rw_craplcr.flgcobmu = 1 THEN
        -- Busca o percentual de multa
        vr_prmulta := gene0002.fn_char_para_number(substr(tabe0001.fn_busca_dstextab( pr_cdcooper => 3
                                                                                     ,pr_nmsistem => 'CRED'
                                                                                     ,pr_tptabela => 'USUARI'
                                                                                     ,pr_cdempres => 11
                                                                                     ,pr_cdacesso => 'PAREMPCTL'
                                                                                     ,pr_tpregist => 1),1,5));
      ELSE
        vr_prmulta := 0;

      END IF;

      -- Busca os dados do emitente
      vr_emitente := rw_crapcop.nmextcop||' - '||rw_crapcop.nmrescop||', sociedade cooperativa de cr�dito, inscrita no CNPJ sob no. '||
                     gene0002.fn_mask_cpf_cnpj(rw_crapcop.nrdocnpj,2)||', estabelecida na '||
                     rw_crapcop.dsendcop||' no. ' ||rw_crapcop.nrendcop|| ', bairro ' ||rw_crapcop.nmbairro||
                     ', CEP: '||gene0002.fn_mask_cep(rw_crapcop.nrcepend)||', cidade de '||rw_crapcop.nmcidade||
                     '-'||rw_crapcop.cdufdcop;
     IF rw_crawepr.tpemprst = 0 THEN /* P�s-fixado */
        vr_taxjream := rw_craplcr.txjurfix;
     ELSIF  rw_crawepr.tpemprst = 1 THEN /* Pr�-fixado */
        vr_taxjream := rw_craplcr.perjurmo;
     END IF;
     IF  vr_taxjream > 0 THEN -- taxa juros > 0
        vr_taxjrean := ROUND((POWER(1 + (vr_taxjream / 100),12) - 1) * 100,2);--calculo juros ano
     ELSE
        vr_taxjrean := 0;
     END IF;
     -- relatorio crrl100_03
     IF rw_craplcr.tpctrato = 1 AND -- modelo = 1 NORMAL
        rw_craplcr.cdusolcr = 0 AND -- codigo de uso = 0 Normal
        rw_crawepr.tpemprst = 1 AND -- Tipo PP
        rw_crawepr.inpessoa = 2 THEN -- pessoa juridica
        -- clausula 2 do relatorio
        vr_coment01 := '2. Empr�stimo - O cr�dito ora aberto e aceito pelo Emitente � um empr�stimo em dinheiro, tendo como origem recursos ' ||
                       'de fontes de Dep�sitos Interfinanceiros de Repasses � DIM , com pagamento em parcelas, na quantidade ' ||
                       'e valor contratados pelo Emitente, pelo que o Emitente.';
           vr_nmarqim := '/crrl100_03_'||pr_nrdconta||pr_nrctremp||'.pdf';   -- nome do relatorio + nr contrato
            -- titulo do relatorio
           vr_dstitulo := 'C�DULA DE CR�DITO BANC�RIO - EMPR�STIMO AO COOPERADO No. '||gene0002.fn_mask(pr_nrctremp,'99.999.999') ;
           vr_dsjasper := 'crrl100_14.jasper'; -- nome do jasper
     -- relatorio crrl100_04
     ELSIF rw_craplcr.tpctrato = 1 AND -- MODELO: = 1 NORMAL
        rw_craplcr.cdusolcr = 0 AND -- codigo de uso = 0 Normal
        rw_crawepr.tpemprst = 1 AND -- Tipo PP
        rw_crawepr.inpessoa = 1 THEN -- pessoa fisica
        vr_coment01 := '2. Empr�stimo - O cr�dito ora aberto e aceito pelo Emitente � um empr�stimo em dinheiro, tendo como origem recursos ' ||
                      'de fontes de Dep�sitos Interfinanceiros de Repasses � DIM , com pagamento em parcelas, na quantidade ' ||
                      'e valor contratados pelo Emitente, pelo que o Emitente.';
        vr_nmarqim := '/crrl100_04_'||pr_nrdconta||pr_nrctremp||'.pdf';   -- nome do relatorio + nr contrato
        -- titulo do relatorio
        vr_dstitulo := 'C�DULA DE CR�DITO BANC�RIO - EMPR�STIMO AO COOPERADO No. '||gene0002.fn_mask(pr_nrctremp,'99.999.999') ;
		-- Se for um contrato de portabilidade
        IF vr_portabilidade = TRUE THEN
          vr_dsjasper := 'crrl100_18_portab.jasper'; -- nome do jasper
        ELSE
		    vr_dsjasper := 'crrl100_18.jasper'; -- nome do jasper
        END IF;
     -- relatorios crrl100_11 / crrl100_10 ou crrl100_14
     ELSIF rw_craplcr.tpctrato = 1 AND -- MODELO: = 1 NORMAL
        rw_craplcr.cdusolcr = 0 AND -- codigo de uso = 0 Normal
        rw_crawepr.tpemprst = 0 THEN -- Tipo TR
        IF rw_crawepr.flgpagto <> 1 THEN -- consignado
           IF rw_craplcr.tpdescto = 2 THEN -- desconto = em folha
             vr_nmarqim := '/crrl100_11_'||pr_nrdconta||pr_nrctremp||'.pdf'; -- nome do relatorio + nr contrato
             -- titulo do relatorio
             vr_dstitulo := 'C�DULA DE CR�DITO BANC�RIO-EMPR�STIMO AO COOPERADO�CONSIGNADO�COM INDEXADOR�No. '||gene0002.fn_mask(pr_nrctremp,'99.999.999') ;
             vr_dsjasper := 'crrl100_07.jasper'; -- nome do jasper
           ELSE -- desconto = conta corrente
             vr_nmarqim := '/crrl100_10_'||pr_nrdconta||pr_nrctremp||'.pdf'; -- nome do relatorio + nr contrato
             -- titulo do relatorio
             vr_dstitulo := 'C�DULA DE CR�DITO BANC�RIO - EMPR�STIMO AO COOPERADO � COM INDEXADOR � No. '||gene0002.fn_mask(pr_nrctremp,'99.999.999') ;
             vr_dsjasper := 'crrl100_06.jasper'; -- nome do jasper
           END IF;
        ELSE -- folha
          vr_nmarqim := '/crrl100_14_'||pr_nrdconta||pr_nrctremp||'.pdf'; -- nome do relatorio + nr contrato
          -- titulo do relatorio
          vr_dstitulo := 'C�DULA DE CR�DITO BANC�RIO-EMPR�STIMO AO COOPERADO � SAL�RIO � COM INDEXADOR�No. '||gene0002.fn_mask(pr_nrctremp,'99.999.999') ;
          vr_dsjasper := 'crrl100_09.jasper'; -- nome do jasper
        END IF;
     -- relatorios crrl100_12 ou crrl100_13
     ELSIF rw_craplcr.tpctrato = 1 AND -- MODELO: = 1 NORMAL
        rw_craplcr.cdusolcr = 1 AND -- codigo de uso = 1 Microcredito
        rw_crawepr.tpemprst = 0 THEN -- Tipo TR
        IF rw_craplcr.dsorgrec IN ('MICROCREDITO PNMPO BNDES','MICROCREDITO PNMPO BRDE', 'MICROCREDITO PNMPO BNDES CECRED') THEN -- Origem do recurso
            vr_nmarqim := '/crrl100_12_'||pr_nrdconta||pr_nrctremp||'.pdf'; -- nome do relatorio + nr contrato
            vr_dstitulo := 'C�DULA DE CR�DITO BANC�RIO - EMPR�STIMO AO COOPERADO � MICROCR�DITO � COM INDEXADOR No. '||gene0002.fn_mask(pr_nrctremp,'99.999.999');
            vr_dsjasper := 'crrl100_08.jasper'; -- nome do jasper
        ELSE
           vr_nmarqim := '/crrl100_13_'||pr_nrdconta||pr_nrctremp||'.pdf'; -- nome do relatorio + nr contrato
           -- titulo do relatorio
           vr_dstitulo := 'C�DULA DE CR�DITO BANC�RIO - EMPR�STIMO AO COOPERADO � MICROCR�DITO � COM INDEXADOR No. '||gene0002.fn_mask(pr_nrctremp,'99.999.999');
           vr_dsjasper := 'crrl100_17.jasper';  -- nome do jasper
        END IF;

     -- relatorios crrl100_02 e crrl100_09 e crrl100_16
     ELSIF rw_craplcr.tpctrato = 2 AND -- MODELO: 2 ALIENA��O
           rw_craplcr.cdusolcr = 0 THEN -- Cod Uso = NORMAL
        pc_busca_bens(pr_cdcooper => pr_cdcooper
                    , pr_nrdconta => pr_nrdconta
                    , pr_nrctremp => pr_nrctremp
                    , pr_cdagenci => rw_crapavi_01.cdagenci
                    );
        IF rw_crawepr.tpemprst = 1 THEN -- Tipo PP
          -- Se for bens m�veis
          IF vr_tab_bens.exists(vr_tab_bens.first) AND
            vr_tab_bens(vr_tab_bens.first).dscatbem IN ('MAQUINA DE COSTURA','EQUIPAMENTO') THEN
            -- clausula 2 do relatorio
            vr_coment01 := '2. Financiamento - O cr�dito ora aberto e aceito pelo Emitente � um empr�stimo em dinheiro, com pagamento em parcelas,'||
                           ' na quantidade e valor contratados pelo Emitente.';
            vr_nmarqim := '/crrl100_05_'||pr_nrdconta||pr_nrctremp||'.pdf'; -- nome do relatorio + nr contrato
            -- titulo do relatorio
            vr_dstitulo := 'C�DULA DE CR�DITO BANC�RIO-FINANCIAMENTO COM ALIENA��O FIDUCI�RIA DE BENS M�VEIS No. '||gene0002.fn_mask(pr_nrctremp,'99.999.999') ;
            vr_dsjasper := 'crrl100_02.jasper'; -- nome do jasper
            vr_bens := NULL;
           ELSE -- Se for veiculos
             vr_nmarqim := '/crrl100_09_'||pr_nrdconta||pr_nrctremp||'.pdf'; -- nome do relatorio + nr contrato
			 -- Se for de portabilidade
             IF vr_portabilidade THEN
             -- Titulo do relatorio
                vr_dstitulo := 'C�DULA DE CR�DITO BANC�RIO-EMPR�STIMO COM ALIENA��O FIDUCI�RIA DE VE�CULO No. '||gene0002.fn_mask(pr_nrctremp,'99.999.999');
                -- nome do jasper
                vr_dsjasper := 'crrl100_05_portab.jasper';
             ELSE
                -- Titulo do relatorio
             vr_dstitulo := 'C�DULA DE CR�DITO BANC�RIO-FINANCIAMENTO COM ALIENA��O FIDUCI�RIA DE VE�CULO No. '||gene0002.fn_mask(pr_nrctremp,'99.999.999');
             -- nome do jasper
             vr_dsjasper := 'crrl100_05.jasper'; -- nome do jasper             
           END IF;
           END IF;
        ELSE -- TR
           vr_nmarqim := '/crrl100_16_'||pr_nrdconta||pr_nrctremp||'.pdf'; -- nome do relatorio + nr contrato
           -- Titulo do relatorio
           vr_dstitulo := 'C�DULA DE CR�DITO BANC�RIO-FINANCIAMENTO COM ALIENA��O FIDUCI�RIA DE VE�CULO�COM INDEXADOR No. '||gene0002.fn_mask(pr_nrctremp,'99.999.999');
           vr_dsjasper := 'crrl100_11.jasper'; -- nome do jasper
        END IF;

     -- relatorio crrl100_06
     ELSIF rw_craplcr.tpctrato = 3 AND -- MODELO: = 3 Hipoteca
        rw_craplcr.cdusolcr = 0 AND -- codigo de uso = 0 Normal
        rw_crawepr.tpemprst = 1 THEN -- Tipo PP
        -- clausula 2 do relatorio
        vr_coment01 := '2. Financiamento - O cr�dito ora aberto e aceito pelo Emitente � um empr�stimo em dinheiro, com pagamento em parcelas,'||
                       ' na quantidade e valor contratados pelo Emitente.';
        vr_nmarqim := '/crrl100_06_'||pr_nrdconta||pr_nrctremp||'.pdf'; -- nome do relatorio + nr contrato
        -- titulo do relatorio
        vr_dstitulo := 'C�DULA DE CR�DITO BANC�RIO-FINANCIAMENTO COM ALIENA��O FIDUCI�RIA DE IM�VEL No. '||gene0002.fn_mask(pr_nrctremp,'99.999.999') ;
        vr_dsjasper := 'crrl100_03.jasper'; -- nome do jasper
        vr_bens := NULL;

        pc_busca_bens(pr_cdcooper => pr_cdcooper
                    , pr_nrdconta => pr_nrdconta
                    , pr_nrctremp => pr_nrctremp
                    , pr_cdagenci => rw_crapavi_01.cdagenci
                    );

     -- relatorio crrl100_07, crrl100_08, crrl100_17 ou crrl100_18
     ELSIF rw_craplcr.tpctrato = 2 AND -- MODELO: 2 ALIENA��O
           rw_craplcr.cdusolcr = 1 THEN -- Cod Uso = MICROCR�DITO
       IF rw_crawepr.tpemprst = 1 THEN -- Tipo PP
           IF rw_craplcr.dsorgrec IN ('MICROCREDITO PNMPO BNDES','MICROCREDITO PNMPO BRDE', 'MICROCREDITO PNMPO BNDES CECRED') THEN -- Origem do recurso
             vr_nmarqim := '/crrl100_07_'||pr_nrdconta||pr_nrctremp||'.pdf';  -- nome do relatorio + nr contrato
             -- titulo do relatorio
             vr_dstitulo := 'C�DULA DE CR�DITO BANC�RIO-FINANCIAMENTO COM ALIENA��O FIDUCI�RIA DE VE�CULO MICROCR�DITO No. '||gene0002.fn_mask(pr_nrctremp,'99.999.999');
             vr_dsjasper := 'crrl100_04.jasper'; -- nome jasper
           ELSE
             vr_nmarqim := '/crrl100_08_'||pr_nrdconta||pr_nrctremp||'.pdf';  -- nome do relatorio + nr contrato
             -- titulo do relatorio
             vr_dstitulo := 'C�DULA DE CR�DITO BANC�RIO-FINANCIAMENTO COM ALIENA��O FIDUCI�RIA DE VE�CULO MICROCR�DITO No. '||gene0002.fn_mask(pr_nrctremp,'99.999.999');
             vr_dsjasper := 'crrl100_16.jasper'; -- nome jasper
           END IF;
       ELSE -- Tipo TR
          IF rw_craplcr.dsorgrec IN ('MICROCREDITO PNMPO BNDES','MICROCREDITO PNMPO BRDE', 'MICROCREDITO PNMPO BNDES CECRED') THEN -- Origem do recurso
              vr_nmarqim := '/crrl100_18_'||pr_nrdconta||pr_nrctremp||'.pdf';  -- nome do relatorio + nr contrato
              -- Titulo do relatorio
              vr_dstitulo := 'C�DULA DE CR�DITO BANC�RIO-FINANCIAMENTO COM ALIENA��O FIDUCI�RIA DE VE�CULO MICROCR�DITO�COM INDEXADOR No. '||gene0002.fn_mask(pr_nrctremp,'99.999.999');
              vr_dsjasper := 'crrl100_13.jasper'; -- nome do jasper
          ELSE
              vr_nmarqim := '/crrl100_17_'||pr_nrdconta||pr_nrctremp||'.pdf'; -- nome do relatorio + nr contrato
              -- Titulo do relatorio
              vr_dstitulo := 'C�DULA DE CR�DITO BANC�RIO-FINANCIAMENTO COM ALIENA��O FIDUCI�RIA DE VE�CULO MICROCR�DITO�COM INDEXADOR No. '||gene0002.fn_mask(pr_nrctremp,'99.999.999');
              vr_dsjasper := 'crrl100_12.jasper'; -- nome do jasper
          END IF;
       END IF;

       pc_busca_bens(pr_cdcooper => pr_cdcooper
                   , pr_nrdconta => pr_nrdconta
                   , pr_nrctremp => pr_nrctremp
                   , pr_cdagenci => rw_crapavi_01.cdagenci
                   );

     -- relatorio crrl100_15
     ELSIF rw_craplcr.tpctrato = 3 AND -- MODELO: = 3 Hipoteca
        rw_craplcr.cdusolcr = 0 AND -- codigo de uso = 0 Normal
        rw_crawepr.tpemprst = 0 THEN -- Tipo TR
        vr_nmarqim := '/crrl100_15_'||pr_nrdconta||pr_nrctremp||'.pdf';  -- nome do relatorio + nr contrato
        -- Titulo do relatorio
        vr_dstitulo := 'C�DULA DE CR�DITO BANC�RIO-FINANCIAMENTO COM ALIENA��O FIDUCI�RIA DE IM�VEL � COM INDEXADOR No. '||gene0002.fn_mask(pr_nrctremp,'99.999.999');
        vr_dsjasper := 'crrl100_10.jasper'; -- nome do jasper
        vr_bens := NULL;
        pc_busca_bens(pr_cdcooper => pr_cdcooper
                    , pr_nrdconta => pr_nrdconta
                    , pr_nrctremp => pr_nrctremp
                    , pr_cdagenci => rw_crapavi_01.cdagenci
                    );

     -- relatorio crrl100_01
     ELSIF  rw_craplcr.tpctrato = 1 AND -- MODELO: = 1 NORMAL
        rw_crawepr.tpemprst = 1 AND -- Tipo PP
        rw_craplcr.cdusolcr = 1 AND -- codigo de uso = 1 Microcreditorw_craplcr.dsoperac IN ('FINANCIAMENTO', 'EMPRESTIMO') AND
        rw_craplcr.dsorgrec IN ('MICROCREDITO PNMPO BNDES','MICROCREDITO PNMPO BRDE', 'MICROCREDITO PNMPO BNDES CECRED') THEN -- Origem do recurso
       vr_nmarqim := '/crrl100_01_'||pr_nrdconta||pr_nrctremp||'.pdf';  -- nome do relatorio + nr contrato
       vr_dstitulo := 'C�DULA DE CR�DITO BANC�RIO - EMPR�STIMO AO COOPERADO MICROCR�DITO No. '||gene0002.fn_mask(pr_nrctremp,'99.999.999');
       vr_dsjasper := 'crrl100_01.jasper';--nome do jasper

     -- relatorio crrl100_02
     ELSIF rw_craplcr.tpctrato = 1 AND -- MODELO: = 1 NORMAL
        rw_crawepr.tpemprst = 1 AND -- Tipo PP
        rw_craplcr.cdusolcr = 1 THEN -- codigo de uso = 1 Microcredito
       vr_nmarqim := '/crrl100_02_'||pr_nrdconta||pr_nrctremp||'.pdf'; -- nome do relatorio + nr contrato
       -- titulo do relatorio
       vr_dstitulo := 'C�DULA DE CR�DITO BANC�RIO - EMPR�STIMO AO COOPERADO MICROCR�DITO No. '||gene0002.fn_mask(pr_nrctremp,'99.999.999');
       vr_dsjasper := 'crrl100_15.jasper'; -- nome do jasper
     END IF;

      IF vr_nmarqim IS NULL OR vr_dsjasper IS NULL THEN -- se nome do relatorio for nullo, contrato esta fora do novo padrao
        vr_dscritic := 'Conta/Contrato fora do padrao de layout';--monta critica
        RAISE vr_exc_saida; -- encerra programa e retorna critica
      ELSE
          -- Busca a descricao do titulo e gera o arquivo XML ----------
          vr_digitalizacao := 'Conta: '   ||gene0002.fn_mask_conta(pr_nrdconta)  ||
                              '     Contrato: '||gene0002.fn_mask(pr_nrctremp,'99.999.999')||
                              '     C�d. Doc: '||lpad(rw_crawepr.cdagenci,3,'0');
          -- dados de atendimento da cooperativa, para uso na clausula de solucao amigavel do relatorio.
          vr_dados_coop := 'respons�vel pela sua conta. Est� ainda � sua disposi��o o tele atendimento('||rw_crapcop.nrtelura||')'||', e o website ('||rw_crapcop.dsendweb||').'||
                           'Se n�o for solucionado o conflito, o Emitente poder� recorrer � Ouvidoria '||
                           rw_crapcop.nmrescop||'('||rw_crapcop.nrtelouv||'), em dias �teis(08h00min �s 17h00min).';

          -- clausulas 1 para relatorio por cooperativa
          IF rw_crawepr.tpemprst = 1 THEN -- PP
            vr_campo_02 := 'Nas condi��es de vencimento indicadas nos subitens 1.9. e 1.10, '||
                           'o Emitente pagar� por esta C�dula de Cr�dito Banc�rio, � '||rw_crapcop.nmextcop||' - '||rw_crapcop.nmrescop||
                           ', sociedade cooperativa de cr�dito, inscrita no CNPJ sob n.� '||gene0002.fn_mask_cpf_cnpj(rw_crapcop.nrdocnpj,2)||
                           ', estabelecida na ' ||rw_crapcop.dsendcop||', n.� '||rw_crapcop.nrendcop||', bairro '||rw_crapcop.nmbairro||
                           ', CEP: '||gene0002.fn_mask_cep(rw_crapcop.nrcepend)||', cidade de '||rw_crapcop.nmcidade||'-'||rw_crapcop.cdufdcop||
                           ', designada Cooperativa, a d�vida em dinheiro, certa, l�quida e exig�vel correspondente ao '||
                           'valor total emprestado (subitem 1.3.).';
         ELSE
           vr_campo_02 := 'O Emitente pagar� por esta C�dula de Cr�dito Banc�rio, � '||rw_crapcop.nmextcop||' - '||rw_crapcop.nmrescop||
                           ', sociedade cooperativa de cr�dito, inscrita no CNPJ sob n.� '||gene0002.fn_mask_cpf_cnpj(rw_crapcop.nrdocnpj,2)||
                           ', estabelecida na ' ||rw_crapcop.dsendcop||', n.� '||rw_crapcop.nrendcop||', bairro '||rw_crapcop.nmbairro||
                           ', CEP: '||gene0002.fn_mask_cep(rw_crapcop.nrcepend)||', cidade de '||rw_crapcop.nmcidade||'-'||rw_crapcop.cdufdcop||
                           ', designada Cooperativa, a d�vida em dinheiro, certa, l�quida e exig�vel correspondente ao '||
                           'valor total emprestado (subitem 1.3.).';
          END IF;

          -- Incluir nome do modulo logado
          GENE0001.pc_informa_acesso(pr_module => 'ATENDA'
						                        ,pr_action => 'EMPR0003.pc_imprime_contrato_xml'
                                    );

          -- busca primeiro registro quando houver bem
          vr_des_chave := vr_tab_bens.first;
          -- Verifica se relatorio possui bens
          IF vr_des_chave IS NOT NULL THEN
            gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo, '<bens>');
            WHILE vr_des_chave IS NOT NULL LOOP  -- varre temp table de bens
              -- gera xml para cada bem encontrado
              gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo,
                                      '<bem>'||
                                      '  <veiculos>'      ||vr_bens                                 ||'</veiculos>'||
                                      '  <chassi>'        ||vr_tab_bens(vr_des_chave).dschassi      ||'</chassi>'||
                                      '  <placa>'         ||vr_tab_bens(vr_des_chave).nrdplaca      ||'</placa>'||
                                      '  <renavan>'       ||vr_tab_bens(vr_des_chave).nrrenava      ||'</renavan>'||
                                      '  <anomod>'        ||vr_tab_bens(vr_des_chave).dsanomod      ||'</anomod>'||
                                      '  <cor>'           ||vr_tab_bens(vr_des_chave).dscorbem      ||'</cor>'||
                                      '  <dsbem>'         ||'Descri��o do bem: '||vr_tab_bens(vr_des_chave).dscatbem || ' ' ||
                                                             vr_tab_bens(vr_des_chave).dsbem        ||'</dsbem>'||
                                      '  <proprietario>'  ||vr_tab_bens(vr_des_chave).proprietario                 ||'</proprietario>'||
                                      '  <dados_pessoais>'||vr_tab_bens(vr_des_chave).dados_pessoais               ||'</dados_pessoais>'||
                                      '  <endereco>'      ||vr_tab_bens(vr_des_chave).endereco                     ||'</endereco>'||
                                      '  <conjuge>'       ||vr_tab_bens(vr_des_chave).conjuge                      ||'</conjuge>'||
                                      '  <avaliacao>'     ||'Avalia��o: R$ '||to_char(vr_tab_bens(vr_des_chave).avaliacao,'FM999G999G999G990D00')||'</avaliacao>'||
                                      '</bem>');
              -- Buscar o proximo
              vr_des_chave := vr_tab_bens.NEXT(vr_des_chave);
              IF vr_des_chave IS NULL THEN
                gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo, '</bens>');
              END IF;
            END LOOP;
          END IF;

          -- Verifica se relatorio possui mais de um interveniente
          vr_des_chave_interv := vr_tab_interv.first;
          IF vr_des_chave_interv IS NOT NULL THEN
            gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo, '<intervenientes>');
            WHILE vr_des_chave_interv IS NOT NULL LOOP  -- varre temp table de bens
              -- gera xml para cada bem encontrado
              gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo,
                                      '<interveniente>'||
                                      '  <inprimei>'||vr_tab_interv(vr_des_chave_interv).inprimei||'</inprimei>'||
                                      '  <insegund>'||vr_tab_interv(vr_des_chave_interv).insegund||'</insegund>'||
                                      '</interveniente>');
              -- Buscar o proximo
              vr_des_chave_interv := vr_tab_interv.NEXT(vr_des_chave_interv);
              IF vr_des_chave_interv IS NULL THEN
                gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo, '</intervenientes>');
              END IF;
            END LOOP;
          END IF;
          -- verificacao para impressao dos textos "nao negociavel" e "para uso da digitalizacao"
          IF nvl(pr_inimpctr,0) = 0 THEN
            vr_negociavel := 'N'; -- imprime "para uso da digitalizacao" e nao imprime "nao negociavel"
          ELSE
            vr_negociavel := 'S'; -- nao imprime "para uso da digitalizacao" e imprime "nao negociavel"
          END IF;
          -- gera corpo do xml
          gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo,
                                 '<digitalizacao>' ||vr_digitalizacao                        ||'</digitalizacao>'||
                                 '<titulo>'        ||vr_dstitulo                             || '</titulo>'||
                                 '<nmemitente>'    ||rw_crawepr.nmprimtl                     ||'</nmemitente>'||
                                 '<campo_01>'      ||vr_campo_01                             ||'</campo_01>'||
                                 '<campo_02>'||vr_campo_02                                   ||'</campo_02>'||
                                 '<pa>'      ||rw_crawepr.cdagenci                           ||'</pa>'||
                                 '<conta>'   ||gene0002.fn_mask_conta(pr_nrdconta)           ||'</conta>'||
                                 '<nrcnpjbase>'    ||nrcnpjbase_if_origem                                           ||'</nrcnpjbase>'||
                                 '<nrctrprt>'      ||nrcontrato_if_origem                                           ||'</nrctrprt>'||
                                 '<nmcredora>'     ||nomcredora_if_origem                    ||'</nmcredora>'||
                                 '<cnpjdacop>'     ||GENE0002.fn_mask_cpf_cnpj(rw_crapcop.nrdocnpj, 2)              ||'</cnpjdacop>'||
                                 '<dtmvtolt>'||to_char(rw_crawepr.dtmvtolt,'dd/mm/yyyy')     ||'</dtmvtolt>'||
                                 '<vlemprst>'||'R$ '||to_char(rw_crawepr.vlemprst,'FM99G999G990D00')||'</vlemprst>'||
                                 '<txminima>'||to_char(rw_craplcr.txminima,'FM990D00')||' %' ||'</txminima>'||  --% juros remuneratorios ao mes
                                 '<prjurano>'||to_char(rw_craplcr.prjurano ,'FM990D00')||' %'||'</prjurano>'|| --% juros remuneratorios ao ano
                                 '<dsperiod>'||'MENSAL'                                      ||'</dsperiod>'||
                                 '<taxjream>'||to_char(vr_taxjream, 'FM990D00')        ||' %'||'</taxjream>'||-- juros encargos mes
                                 '<taxjrean>'||to_char(vr_taxjrean, 'FM990D00')        ||' %'||'</taxjrean>'|| -- juros encargos ano
                                 '<dsatumon>'||'INPC/IBGE'                                   ||'</dsatumon>'||-- Atualiza��o monet�ria por estimativa e projetada
                                 '<dslcremp>'||rw_craplcr.dslcremp||' ('||rw_crawepr.cdlcremp ||')'||'</dslcremp>'|| -- Linha de credito
                                 '<qtpreemp>'||rw_crawepr.qtpreemp                           ||'</qtpreemp>'||
                                 '<vlpreemp>'||'R$ '||to_char(rw_crawepr.vlpreemp,'fm99G999G990D00')||'</vlpreemp>'||
                                 '<diavenct>'||to_char(rw_crawepr.dtvencto,'DD')            ||'</diavenct>'||
                                 '<dtvencto>'||to_char(rw_crawepr.dtvencto,'DD/MM/YYYY')     ||'</dtvencto>'||
                                 '<ultvenct>'||to_char(add_months(rw_crawepr.dtvencto,rw_crawepr.qtpreemp -1),'dd/mm/yyyy')||'</ultvenct>'||
                                 '<perjurmo>'||to_char(rw_craplcr.perjurmo,'FM990D00')||' % ao m�s' ||'</perjurmo>'||  --% juros moratorios
                                 '<prdmulta>'||to_char(vr_prmulta,'fm990d00')||' % sobre o valor da parcela vencida'||'</prdmulta>'|| -- % Multa sobre o valor da parcela vencida
                                 '<qttolatr>'||rw_crawepr.qttolatr||' dias corridos, contados do vencimento da parcela n�o paga'||'</qttolatr>'|| -- Dias de tolerancia de atraso
                                 '<origem>'  ||rw_crawepr.nmcidade||'-'||rw_crawepr.cdufdcop ||'</origem>'  || -- Local Origem
                                 '<destino>' ||rw_crawepr.nmcidade||'-'||rw_crawepr.cdufdcop ||'</destino>' || -- Local destino
                                 '<percetop>'||to_char(rw_crawepr.percetop,'fm990d00')||' %' ||'</percetop>'|| -- Custo efetivo total ao ano
                                 '<emitente>'||vr_emitente                                   ||'</emitente>'||
                                 '<coment01>'||vr_coment01                                   ||'</coment01>'||
                                 '<nrtelura>'||rw_crapcop.nrtelura                           ||'</nrtelura>'|| -- Telefone Atendimento
                                 '<nmrescop>'||rw_crapcop.nmrescop                           ||'</nmrescop>'|| -- Nome curto da empresa
                                 '<nrtelouv>'||rw_crapcop.nrtelouv                           ||'</nrtelouv>'|| -- Telefone ouvidoria
                                 '<dsendweb>'||rw_crapcop.dsendweb                           ||'</dsendweb>'|| -- Endereco web
                                 '<nmaval01>'||vr_nmdavali1                                  ||'</nmaval01>'|| -- Nome do avalista 1
                                 '<docava01>'||rw_crapavi_01.dspessoa                        ||'</docava01>'|| -- Tipo do documento(CPF ou CNPJ)
                                 '<cpfava01>'||vr_nrcpfcgc1                                  ||'</cpfava01>'|| -- cpf do avalista 1
                                 '<endava01>'||vr_dsendres1                                  ||'</endava01>'|| -- Endereco avalista 1
                                 '<celava01>'||vr_nrfonres1                                  ||'</celava01>'|| -- Telefone avalista 1
                                 '<nmaval02>'||trim(vr_nmdavali2)                            ||'</nmaval02>'|| -- Nome do avalista 2
                                 '<docava02>'||rw_crapavi_02.dspessoa                        ||'</docava02>'|| -- Tipo do documento(CPF ou CNPJ)
                                 '<cpfava02>'||vr_nrcpfcgc2                                  ||'</cpfava02>'||-- cpf do avalista 2
                                 '<endava02>'||vr_dsendres2                                  ||'</endava02>'|| -- Endereco avalista 2
                                 '<celava02>'||vr_nrfonres2                                  ||'</celava02>'||  -- Telefone avalista 2
                                 '<nmcjg01>'||trim(vr_nmconjug1)                             ||'</nmcjg01>'||  -- nome do conjuge 1
                                 '<cpfcjg01>'||vr_nrcpfcjg1                                  ||'</cpfcjg01>'|| -- cpf conjuge 1
                                 '<endcjg01>'||vr_dsendres1                                  ||'</endcjg01>'|| -- endereco conjuge 1
                                 '<celcjg01>'||vr_nrfonres1                                  ||'</celcjg01>'|| -- telefone conjuge 1
                                 '<nmcjg02>'||trim(vr_nmconjug2)                             ||'</nmcjg02>'||  -- nome do conjuge 2
                                 '<cpfcjg02>'||vr_nrcpfcjg2                                  ||'</cpfcjg02>'|| -- cpf conjuge 2
                                 '<endcjg02>'||vr_dsendres2                                  ||'</endcjg02>'|| -- endereco conjuge 2
                                 '<celcjg02>'||vr_nrfonres2                                  ||'</celcjg02>'|| -- telefone conjuge 2
                                 '<nrctremp>'||gene0002.fn_mask(pr_nrctremp,'99.999.999')    ||'</nrctremp>'|| -- contrato
                                 '<amigalvel>'||vr_dados_coop                                ||'</amigalvel>'|| -- dados de atendimento da coop para clausula de solucao amigavel
                                 '<flginterv>'||vr_flginterv                                 ||'</flginterv>'|| -- Indica se deve ou nao imprimir a linha de assinatura do interveniente
                                 '<negociavel>'||vr_negociavel                               ||'</negociavel>' -- Indicador de impressao do texto "nao negociavel"
                                 );

          vr_dtlibera := nvl(nvl(rw_crapepr.dtmvtolt, rw_crawepr.dtlibera),rw_crapdat.dtmvtolt);
          -- chama rotina CCET
          ccet0001.pc_imprime_emprestimos_cet(pr_cdcooper => pr_cdcooper
                                            , pr_dtmvtolt => rw_crapdat.dtmvtolt
                                            , pr_cdprogra => vr_cdprogra
                                            , pr_nrdconta => pr_nrdconta
                                            , pr_inpessoa => rw_crawepr.inpessoa
                                            , pr_cdusolcr => 0 -- Segundo o Lucas, deve ser passado zero
                                            , pr_cdlcremp => rw_crawepr.cdlcremp
                                            , pr_tpemprst => rw_crawepr.tpemprst
                                            , pr_nrctremp => pr_nrctremp
                                            , pr_dtlibera => vr_dtlibera
                                            , pr_dtultpag => trunc(SYSDATE)
                                            , pr_vlemprst => rw_crawepr.vlemprst
                                            , pr_txmensal => rw_crawepr.txmensal
                                            , pr_vlpreemp => rw_crawepr.vlpreemp
                                            , pr_qtpreemp => rw_crawepr.qtpreemp
                                            , pr_dtdpagto => rw_crawepr.dtdpagto
                                            , pr_nmarqimp => vr_nmarqimp
                                            , pr_des_xml  => vr_des_xml2
                                            , pr_cdcritic => vr_cdcritic
                                            , pr_dscritic => vr_dscritic
                                            );
          IF nvl(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_saida;
          END IF;

          gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo,
                     '', TRUE);

          -- concatena xml retornado CCET com xml contratos
          dbms_lob.append(vr_des_xml, vr_des_xml2);
          dbms_lob.freetemporary(vr_des_xml2);
          vr_des_xml2 := NULL;
          dbms_lob.createtemporary(vr_des_xml2, TRUE);
          dbms_lob.open(vr_des_xml2, dbms_lob.lob_readwrite);

          IF rw_crawepr .nrseqrrq <> 0 THEN -- somenmte se for microcredito
            -- chama rotinar para geracao de questionario
            empr0003.pc_gera_perfil_empr(pr_cdcooper => pr_cdcooper
                                       , pr_nrdconta => pr_nrdconta
                                       , pr_nrctremp => pr_nrctremp
                                       , pr_cdcritic => vr_cdcritic
                                       , pr_dscritic => vr_dscritic
                                       , pr_retxml   => vr_des_xml2
                                       );
            -- concatena xml retornado empr0005 com xml contratos
            dbms_lob.append(vr_des_xml, vr_des_xml2);
            dbms_lob.freetemporary(vr_des_xml2);
          END IF;
          dbms_lob.writeappend(vr_des_xml, length('</contrato>'), '</contrato>');
      END IF;

      IF vr_dscritic IS NOT NULL THEN -- verifica erro na finalizacao do xml
        RAISE vr_exc_saida; -- encerra programa
      END IF;

      --busca diretorio padrao da cooperativa
      vr_nom_direto := gene0001.fn_diretorio(pr_tpdireto => 'C' --> /usr/coop
                                            ,pr_cdcooper => pr_cdcooper
                                            ,pr_nmsubdir => 'rl');

      --Gerar Arquivo XML Fisico
      gene0002.pc_XML_para_arquivo(pr_XML      => vr_des_xml     --> Inst�ncia do XML Type
                                  ,pr_caminho  => vr_nom_direto  --> Diret�rio para sa�da
                                  ,pr_arquivo  => '/teste.xml'    --> Nome do arquivo de sa�da
                                  ,pr_des_erro => vr_dscritic);  --> Retorno de erro, caso ocorra
      --Se ocorreu erro
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;


      -- Solicita geracao do PDF
      gene0002.pc_solicita_relato(pr_cdcooper   => pr_cdcooper
                                 , pr_cdprogra  => vr_cdprogra
                                 , pr_dtmvtolt  => rw_crapdat.dtmvtolt
                                 , pr_dsxml     => vr_des_xml
                                 , pr_dsxmlnode => '/contrato'
                                 , pr_dsjasper  => vr_dsjasper
                                 , pr_dsparams  => null
                                 , pr_dsarqsaid => vr_nom_direto||vr_nmarqim
                                 , pr_flg_gerar => 'S'
                                 , pr_qtcoluna  => 234
                                 , pr_sqcabrel  => 1
                                 , pr_flg_impri => 'S'
                                 , pr_nmformul  => ' '
                                 , pr_nrcopias  => 1
                                 , pr_des_erro  => vr_dscritic);


      IF vr_dscritic IS NOT NULL THEN -- verifica retorno se houve erro
        RAISE vr_exc_saida; -- encerra programa
      END IF;

      -- copia contrato pdf do diretorio da cooperativa para servidor web
      gene0002.pc_efetua_copia_pdf(pr_cdcooper => pr_cdcooper
                                 , pr_cdagenci => NULL
                                 , pr_nrdcaixa => NULL
                                 , pr_nmarqpdf => vr_nom_direto||vr_nmarqim
                                 , pr_des_reto => vr_des_reto
                                 , pr_tab_erro => vr_tab_erro
                                 );

      -- caso apresente erro na opera��o
      IF nvl(vr_des_reto,'OK') <> 'OK' THEN
        IF vr_tab_erro.COUNT > 0 THEN -- verifica pl-table se existe erros
          vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic; -- busca primeira critica
          vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic; -- busca primeira descricao da critica
          RAISE vr_exc_saida; -- encerra programa
        END IF;
      END IF;

      -- Remover relatorio do diretorio padrao da cooperativa
      gene0001.pc_OScommand(pr_typ_comando => 'S'
                           ,pr_des_comando => 'rm '||vr_nom_direto||vr_nmarqim
                           ,pr_typ_saida   => vr_typ_saida
                           ,pr_des_saida   => vr_dscritic);

      -- Se retornou erro
      IF vr_typ_saida = 'ERR' OR vr_dscritic IS NOT null THEN
        -- Concatena o erro que veio
        vr_dscritic := 'Erro ao remover arquivo: '||vr_dscritic;
        RAISE vr_exc_saida; -- encerra programa
      END IF;
      -- Liberando a mem�ria alocada pro CLOB
      dbms_lob.close(vr_des_xml);
      dbms_lob.freetemporary(vr_des_xml);
      vr_nmarqim := substr(vr_nmarqim, 2);-- retornar somente o nome do PDF sem a barra"/"
      -- Criar XML de retorno para uso na Web
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><nmarqpdf>' || vr_nmarqim|| '</nmarqpdf>');
      -- atualiza quantidade de impressoes realizadas do contrato do tipo negociavel
      IF vr_negociavel = 'N' THEN
        BEGIN
          UPDATE crapepr
          SET    crapepr.qtimpctr = NVL(qtimpctr,0) + 1
          WHERE  crapepr.cdcooper = pr_cdcooper
          AND    crapepr.nrdconta = pr_nrdconta
          AND    crapepr.nrctremp = pr_nrctremp;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao atualizar quantidade de impressao na crapepr'||SQLERRM;
          RAISE vr_exc_saida; -- encerra programa
        END;
      END IF;
    COMMIT;

    EXCEPTION
      WHEN vr_exc_saida THEN
        -- Se foi retornado apenas c�digo
        IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
          -- Buscar a descri��o
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;
        -- Devolvemos c�digo e critica encontradas das variaveis locais
        pr_cdcritic := NVL(vr_cdcritic,0);
        pr_dscritic := vr_dscritic;

        -- Carregar XML padr�o para vari�vel de retorno n�o utilizada.
        -- Existe para satisfazer exig�ncia da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || upper(pr_dscritic) || '</Erro></Root>');
        ROLLBACK;
      WHEN OTHERS THEN
        -- Efetuar retorno do erro n�o tratado
        pr_cdcritic := 0;
        pr_dscritic := sqlerrm;
        -- Carregar XML padr�o para vari�vel de retorno n�o utilizada.
        -- Existe para satisfazer exig�ncia da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' ||upper(pr_dscritic) ||'</Erro></Root>');
        ROLLBACK;

    END pc_imprime_contrato_xml;

    PROCEDURE pc_gera_perfil_empr(pr_cdcooper IN crawepr.cdcooper%TYPE --> C�digo da cooperativa
                                 ,pr_nrdconta IN crawepr.nrdconta%TYPE --> Numero da conta
                                 ,pr_nrctremp IN crawepr.nrctremp%TYPE --> nro do contrato
                                 ,pr_cdcritic OUT PLS_INTEGER          --> C�digo da cr�tica
                                 ,pr_dscritic OUT VARCHAR2             --> Descri��o da cr�tica
                                 ,pr_retxml   IN OUT CLOB              --> Arquivo de retorno do XML
                                 ) IS
  /* .............................................................................

       Programa: pc_gera_perfil_empr
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Tiago Castro (RKAM)
       Data    : Dezembro/2014.                         Ultima atualizacao:

       Dados referentes ao programa:

       Frequencia: Sempre que for chamado.
       Objetivo  : Gera o relatorio crrl_042 ( PERFIL SOCIO-ECONOMICO DO MICROEMPREENDEDOR)

       Alteracoes:

    ............................................................................. */

    -- busca nome do cooperado
    CURSOR cr_crapass IS
      SELECT  crapass.nmprimtl
      FROM    crapass
      WHERE   crapass.cdcooper = pr_cdcooper
      AND     crapass.nrdconta = pr_nrdconta;
    rw_crapass cr_crapass%ROWTYPE;

    -- busca nome da cooperativa
    CURSOR cr_crapcop IS
      SELECT  crapcop.nmextcop
      FROM    crapcop
      WHERE   crapcop.cdcooper = pr_cdcooper;
    rw_crapcop  cr_crapcop%ROWTYPE;

    -- dados do contrato de emprestimo
    CURSOR cr_crawepr IS
      SELECT  crawepr.nrseqrrq
      FROM    crawepr
      WHERE   crawepr.cdcooper = pr_cdcooper
      AND     crawepr.nrdconta = pr_nrdconta
      AND     crawepr.nrctremp = pr_nrctremp;
    rw_crawepr cr_crawepr%ROWTYPE;


    vr_cabecalho      VARCHAR2(3000);  --> Cabecalho do relatorio
    vr_des_xml        CLOB;            --> XML do relatorio
    vr_campo          VARCHAR2(20);    --> campo xml com erro
    vr_des_erro       VARCHAR2(4000);  --> erro empr0005

    BEGIN
      -- busca informacao do cooperado
      OPEN cr_crapass;
      FETCH cr_crapass INTO rw_crapass;
      CLOSE cr_crapass;
      -- busca informacao da cooperativa
      OPEN cr_crapcop;
      FETCH cr_crapcop INTO rw_crapcop;
      CLOSE cr_crapcop;
      --busca informacao do contrato de emprestimo
      OPEN cr_crawepr;
      FETCH cr_crawepr INTO rw_crawepr;
      CLOSE cr_crawepr;
      -- monta cabecalho do relatorio
      vr_cabecalho := 'Eu '||rw_crapass.nmprimtl ||' conta corrente no. '||trim(gene0002.fn_mask_conta(pr_nrdconta))||' declaro para'||chr(13)||
                      'os devidos fins, que os procedimentos operacionais referentes ao'||chr(13)||
                      'processo de concessao de microcredito produtivo e orientado foram'||chr(13)||
                      'desenvolvidos pela '||rw_crapcop.nmextcop||' atraves'||chr(13)||
                      'de metodologia baseada no relacionamento direto com o empreendedor e'||chr(13)||
                      'prestando orientacao financeira. Me comprometo a utilizar de forma'||chr(13)||
                      'produtiva a totalidade dos recursos captados, conforme finalidade'||chr(13)||
                      'descrita no contrato no. '||trim(gene0002.fn_mask(pr_nrctremp,'99.999.999'))||', firmado com a '||rw_crapcop.nmextcop||'.';

      -- inicia variavel clob
      vr_des_xml := NULL;
      dbms_lob.createtemporary(vr_des_xml, TRUE);
      dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
      -- insere cabecalho do relatorio no xml retornado da empr0005
      dbms_lob.writeappend(vr_des_xml,length('<empr0005>'),'<empr0005>');
      dbms_lob.writeappend(vr_des_xml,length('  <cabecalho>'||vr_cabecalho||'</cabecalho>'),'  <cabecalho>'||vr_cabecalho||'</cabecalho>');

      -- busca xml do questionario de perfil socio economico
      empr0005.pc_retorna_perguntas(pr_cdcooper => pr_cdcooper         --> C�digo da cooperativa
                                  , pr_nrdconta => pr_nrdconta         --> Numero da conta
                                  , pr_nrseqrrq => rw_crawepr.nrseqrrq --> Numero sequencial do retorno das respostas do questionario
                                  , pr_inregcal => 1                   --> Indicador se deve ou nao exibir registros que sao calculados
                                  , pr_retxml   => vr_des_xml         --> Arquivo de retorno do XML
                                  , pr_cdcritic => vr_cdcritic         --> C�digo da cr�tica
                                  , pr_dscritic => vr_dscritic);

      -- fecha tag empr0005
      dbms_lob.writeappend(vr_des_xml,length('</empr0005>'),'</empr0005>');
      -- retorna xmls concatenados com
      pr_retxml := vr_des_xml;
    END pc_gera_perfil_empr;


    
    /* Imprime o demonstrativo do contrato de emprestimo pre-aprovado */
    PROCEDURE pc_gera_demonst_pre_aprovado(pr_cdcooper IN crawepr.cdcooper%TYPE --> C�digo da Cooperativa
                                          ,pr_cdagenci IN crawepr.nrdconta%TYPE --> C�digo da Agencia
                                          ,pr_nrdcaixa IN INTEGER               --> Numero do Caixa
                                          ,pr_cdoperad IN crapope.cdoperad%TYPE --> C�digo do Operador
                                          ,pr_cdprogra IN crapprg.cdprogra%TYPE --> C�digo do Programa
                                          ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE --> Data do Movimento
                                          ,pr_nmarqimp IN VARCHAR2              --> Caminho do arquivo 
                                          ,pr_nmarqpdf OUT VARCHAR2             --> Nome Arquivo PDF
                                          ,pr_des_reto OUT VARCHAR2) IS         --> Descri��o do retorno
    BEGIN
      /* .............................................................................

         Programa: pc_gera_demonstrativo_pre_aprovado
         Sistema : Conta-Corrente - Cooperativa de Credito
         Sigla   : CRED
         Autor   : Carlos Rafael Tanholi
         Data    : Janeiro/2016.                         Ultima atualizacao:

         Dados referentes ao programa:

         Frequencia: Sempre que for chamado.
         Objetivo  : Gera o relatorio crrl_711 (Demonstrativo de contrato de emprestimo pre-aprovado)

         Alteracoes:

      ............................................................................. */

      DECLARE

        -- caminho e nome do arquivo a ser gerado
        vr_nmdireto VARCHAR(150);
        vr_nmrquivo VARCHAR2(100);
        -- caminho e nome do arquivo a ser consultado
        vr_endereco VARCHAR(150);
        vr_arqnome  VARCHAR2(100);        

        -- arquivo que sera trabalhado
        vr_arquivo utl_file.file_type;  
        -- linha com o conteudo do arquivo
        vr_setlinha varchar2(2000);
        -- Numero da linha no arquivo
        vr_nrlinha  PLS_INTEGER := 0;
        vr_des_linha VARCHAR2(1000); 
        vr_des_linha_ant VARCHAR2(1000); 
        -- array com parts do enderco do arquivo
        vr_caminho gene0002.typ_split;
        -- Variaveis de Excecoes
        vr_exc_erro EXCEPTION;    
        vr_dscritic VARCHAR2(10000);
        -- Tabela de erros
        vr_tab_erro GENE0001.typ_tab_erro;
        -- CLOB de Dados
        vr_clobxml711  CLOB;
        vr_dstexto711  VARCHAR2(32600); 
        
        vr_contador INTEGER;       
    
      BEGIN
        -- Busca do diret�rio base da cooperativa para a gera��o de relat�rios
        vr_nmdireto:= gene0001.fn_diretorio(pr_tpdireto => 'C'         --> /usr/coop
                                           ,pr_cdcooper => pr_cdcooper --> Cooperativa
                                           ,pr_nmsubdir => 'rl');      --> Utilizaremos o rl        

        -- quebra caminho do arquivo e separa caminho e nome                
        vr_caminho := gene0002.fn_quebra_string(pr_string => pr_nmarqimp, pr_delimit => '/');
              
        IF NVL(vr_caminho.count(),0) > 0 THEN    
          -- recupera so o nome do arquivo .ex
          vr_arqnome := vr_caminho(vr_caminho.LAST);  
          -- recupera o endereco do arquivo .ex
          vr_endereco := REPLACE(pr_nmarqimp, vr_arqnome, ''); 
          -- armazena o nome do arquivo destino (PDF)
          vr_nmrquivo := REPLACE(vr_arqnome, '.ex', '.pdf');      
        END IF;      
        
        -- criar handle de arquivo de Saldo Dispon�vel dos Associados
        GENE0001.pc_abre_arquivo(pr_nmdireto => vr_endereco   --> Diretorio do arquivo
                                ,pr_nmarquiv => vr_arqnome    --> Nome do arquivo
                                ,pr_tipabert => 'R'           --> modo de abertura (r,w,a)
                                ,pr_utlfileh => vr_arquivo    --> handle do arquivo aberto
                                ,pr_des_erro => vr_dscritic); --> erro
        -- em caso de cr�tica
        IF vr_dscritic IS NOT NULL THEN
          vr_dscritic:= 'Erro ao abrir arquivo de origem';
          --levantar excecao
          RAISE vr_exc_erro;
        END IF;      
        
        -- Inicializar as informa��es do XML de dados para o relat�rio
        dbms_lob.createtemporary(vr_clobxml711, TRUE, dbms_lob.CALL);
        dbms_lob.open(vr_clobxml711, dbms_lob.lob_readwrite);
        --Escrever no arquivo XML
        gene0002.pc_escreve_xml(vr_clobxml711,vr_dstexto711,'<?xml version="1.0" encoding="UTF-8"?><crrl711>');        
        
        -- Se o arquivo estiver aberto
        IF  utl_file.IS_OPEN(vr_arquivo) THEN
           -- Percorrer as linhas do arquivo
          BEGIN
            vr_contador := 0;
            LOOP        
              gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_arquivo,pr_des_text => vr_des_linha);        

              IF vr_contador = 0 AND vr_des_linha IS NOT NULL THEN
                 gene0002.pc_escreve_xml(vr_clobxml711,vr_dstexto711,'<cabecalho>');
                 --Escreve o cabecalho do arquivo no XML de dados do relatorio
                 gene0002.pc_escreve_xml(vr_clobxml711, vr_dstexto711, vr_des_linha,TRUE);                 
                 gene0002.pc_escreve_xml(vr_clobxml711,vr_dstexto711,'</cabecalho><conteudo>');
              ELSE   
              
                IF ( vr_des_linha IS NULL AND vr_contador > 1 ) THEN
                  vr_des_linha := '#br#';
                END IF;                  
              
                IF ( NOT vr_des_linha IS NULL ) THEN
                  --Escreve o conteudo do arquivo no XML de dados do relatorio
                  gene0002.pc_escreve_xml(vr_clobxml711, vr_dstexto711, vr_des_linha,TRUE);                  
                END IF;
                
              END IF;
              
              vr_contador := vr_contador+1;
              
            END LOOP; -- Fim LOOP linhas do arquivo
          EXCEPTION
            WHEN no_data_found THEN
              NULL;
          END;
        END IF;
        
        --Finaliza TAG Extratos e Conta
        gene0002.pc_escreve_xml(vr_clobxml711, vr_dstexto711, '</conteudo></crrl711>',TRUE);        
        
        -- Fechar o arquivo
        GENE0001.pc_fecha_arquivo(pr_utlfileh => vr_arquivo);        
        
      	  -- Gera relat�rio 711
        gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper                   --> Cooperativa conectada
                                   ,pr_cdprogra  => pr_cdprogra                   --> Programa chamador
                                   ,pr_dtmvtolt  => pr_dtmvtolt                   --> Data do movimento atual
                                   ,pr_dsxml     => vr_clobxml711                 --> Arquivo XML de dados
                                   ,pr_dsxmlnode => '/crrl711'                   --> N� base do XML para leitura dos dados
                                   ,pr_dsjasper  => 'crrl711.jasper'              --> Arquivo de layout do iReport
                                   ,pr_dsparams  => NULL                          --> Sem par�metros
                                   ,pr_cdrelato  => 711                           --> C�digo fixo para o relat�rio (nao busca pelo sqcabrel)                                       
                                   ,pr_dsarqsaid => vr_nmdireto||'/'||vr_nmrquivo --> Arquivo final com o path
                                   ,pr_qtcoluna  => 80                            --> Colunas do relatorio
                                   ,pr_flg_gerar => 'S'                           --> Gera�ao na hora
                                   ,pr_flg_impri => 'N'                           --> Chamar a impress�o (Imprim.p)
                                   ,pr_nmformul  => NULL                          --> Nome do formul�rio para impress�o
                                   ,pr_nrcopias  => 1                             --> N�mero de c�pias
                                   ,pr_sqcabrel  => 1                             --> Qual a seq do cabrel
                                   ,pr_flappend  => 'N'                           --> Fazer append do relatorio se ja existir
                                   ,pr_des_erro  => vr_dscritic);                 --> Sa�da com erro
                    
        --Se ocorreu erro no relatorio
        IF vr_dscritic IS NOT NULL THEN
          --Levantar Excecao
          RAISE vr_exc_erro;
        END IF;         
                

        GENE0002.pc_efetua_copia_pdf(pr_cdcooper => pr_cdcooper, --Codigo Cooperativa
                                     pr_cdagenci => pr_cdagenci, --Codigo Agencia
                                     pr_nrdcaixa => pr_nrdcaixa, --Numero do Caixa
                                     pr_nmarqpdf => vr_nmdireto||'/'||vr_nmrquivo, --Nome Arquivo PDF
                                     pr_des_reto => pr_des_reto, --Retorno OK/NOK
                                     pr_tab_erro => vr_tab_erro);--tabela erro

        --Se ocorreu erro
        IF pr_des_reto <> 'OK' THEN
          --Se tem erro na tabela 
          IF vr_tab_erro.COUNT > 0 THEN
            vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic;
          ELSE
            vr_dscritic:= 'Erro ao copiar arquivo para web.';  
          END IF; 
          --Sair 
          RAISE vr_exc_erro;
        END IF; 
                  
        -- Arquivo final com o path    
        pr_nmarqpdf := vr_nmrquivo;
        
        EXCEPTION
          WHEN vr_exc_erro THEN
            pr_des_reto := vr_dscritic;
          WHEN OTHERS THEN
            pr_des_reto:= 'NOK';
        END;

    END pc_gera_demonst_pre_aprovado;

END EMPR0003;
/
