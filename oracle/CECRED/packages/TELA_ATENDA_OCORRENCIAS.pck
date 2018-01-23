CREATE OR REPLACE PACKAGE CECRED.TELA_ATENDA_OCORRENCIAS IS

  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : TELA_ATENDA_OCORRENCIAS
  --  Sistema  : Procedimentos para tela Atenda / Ocorrencias
  --  Sigla    : CRED
  --  Autor    : Jean Michel
  --  Data     : Setembro/2016.                
  --
  -- Frequencia: -----
  -- Objetivo  : Procedimentos para retorno das informações da Atenda Ocorrencias
  --
  -- Alterado: 23/01/2018 - Daniel AMcom
  -- Ajuste: Criada procedure pc_busca_dados_risco
  --
  ---------------------------------------------------------------------------------------------------------------
  
  /* Busca contratos de acordos do Cooperado */
  PROCEDURE pc_busca_ctr_acordos(pr_nrdconta   IN crapceb.nrdconta%TYPE --Número da conta solicitada;
                                ,pr_xmllog     IN VARCHAR2              --XML com informações de LOG
                                ,pr_cdcritic  OUT PLS_INTEGER           --Código da crítica
                                ,pr_dscritic  OUT VARCHAR2              --Descrição da crítica
                                ,pr_retxml     IN OUT NOCOPY XMLType    --Arquivo de retorno do XML
                                ,pr_nmdcampo  OUT VARCHAR2              --Nome do Campo
                                ,pr_des_erro  OUT VARCHAR2);            --Saida OK/NOK

  PROCEDURE pc_busca_dados_risco(pr_cpf_cnpj   IN NUMBER             --> Número do CNPJ ou CPF
                                ,pr_cdcooper   IN NUMBER             --> Código da cooperativa
                                ,pr_xmllog     IN VARCHAR2           --> XML com informações de LOG
                                ,pr_cdcritic   OUT PLS_INTEGER       --> Código da crítica
                                ,pr_dscritic   OUT VARCHAR2          --> Descrição da crítica
                                ,pr_retxml     IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                ,pr_nmdcampo   OUT VARCHAR2          --> Nome do campo com erro
                                ,pr_des_erro   OUT VARCHAR2);        --> Erros do processo                                                               

END TELA_ATENDA_OCORRENCIAS;
/
CREATE OR REPLACE PACKAGE BODY CECRED.TELA_ATENDA_OCORRENCIAS IS

  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : TELA_ATENDA_OCORRENCIAS
  --  Sistema  : Procedimentos para tela Atenda / Ocorrencias
  --  Sigla    : CRED
  --  Autor    : Jean Michel
  --  Data     : Setembro/2016.
  --
  -- Frequencia: -----
  -- Objetivo  : Procedimentos para retorno das informações da Atenda Seguros
  --
  -- Alterado: 23/01/2018 - Daniel AMcom
  -- Ajuste: Criada procedure pc_busca_dados_risco
  --
  ---------------------------------------------------------------------------------------------------------------

  /* Busca contratos de acordos do Cooperado */
  PROCEDURE pc_busca_ctr_acordos(pr_nrdconta   IN crapceb.nrdconta%TYPE --Número da conta solicitada;
                                ,pr_xmllog     IN VARCHAR2              --XML com informações de LOG
                                ,pr_cdcritic  OUT PLS_INTEGER           --Código da crítica
                                ,pr_dscritic  OUT VARCHAR2              --Descrição da crítica
                                ,pr_retxml     IN OUT NOCOPY XMLType    --Arquivo de retorno do XML
                                ,pr_nmdcampo  OUT VARCHAR2              --Nome do Campo
                                ,pr_des_erro  OUT VARCHAR2) IS          --Saida OK/NOK

  BEGIN

    /* .............................................................................

    Programa: pc_busca_ctr_acordos
    Sistema : Ayllos Web
    Autor   : Jean Michel
    Data    : Setembro/2016                 Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Retornar a listagem de contratos de acordos e riscos(Daniel AMcom).

    Alteracoes:
    ..............................................................................*/

    DECLARE

      -- Cursores

      -- Consulta de contratos de acordos ativos
      CURSOR cr_acordo(pr_cdcooper tbrecup_acordo.cdcooper%TYPE
                      ,pr_nrdconta tbrecup_acordo.nrdconta%TYPE
                      ,pr_cdsituacao tbrecup_acordo.cdsituacao%TYPE) IS
        SELECT tbrecup_acordo.cdcooper AS cdcooper
              ,tbrecup_acordo_contrato.nracordo AS nracordo
              ,tbrecup_acordo.nrdconta AS nrdconta
              ,tbrecup_acordo_contrato.nrctremp AS nrctremp
              ,DECODE(tbrecup_acordo_contrato.cdorigem,1,'Estouro de Conta',2,'Empréstimo',3,'Empréstimo','Inexistente') AS dsorigem
          FROM tbrecup_acordo_contrato
          JOIN tbrecup_acordo
            ON tbrecup_acordo.nracordo = tbrecup_acordo_contrato.nracordo
         WHERE tbrecup_acordo.cdcooper = pr_cdcooper
           AND tbrecup_acordo.nrdconta = pr_nrdconta
           AND tbrecup_acordo.cdsituacao = pr_cdsituacao;

      rw_acordo cr_acordo%ROWTYPE;
     
      -- Variavel de criticas
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      -- Variaveis de log
      vr_cdcooper INTEGER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);
      vr_contador INTEGER := 0;

    BEGIN
      -- Extrai os dados vindos do XML
      GENE0004.pc_extrai_dados(pr_xml      => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);
      -- Se encontrar erro
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;

      -- Criar cabeçalho do XML
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');

      -- Informacoes de cabecalho de pacote
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'acordos', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);

      FOR rw_acordo IN cr_acordo(pr_cdcooper   => vr_cdcooper
                                ,pr_nrdconta   => pr_nrdconta
                                ,pr_cdsituacao => 1) LOOP
        -- Informacoes de cabecalho de pacote
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'acordos', pr_posicao => 0, pr_tag_nova => 'acordo', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'acordo',   pr_posicao => vr_contador, pr_tag_nova => 'nracordo', pr_tag_cont => TO_CHAR(rw_acordo.nracordo), pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'acordo',   pr_posicao => vr_contador, pr_tag_nova => 'dsorigem', pr_tag_cont => TO_CHAR(rw_acordo.dsorigem), pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'acordo',   pr_posicao => vr_contador, pr_tag_nova => 'nrctremp', pr_tag_cont => GENE0002.fn_mask_contrato(rw_acordo.nrctremp), pr_des_erro => vr_dscritic);
        
        vr_contador := vr_contador + 1;
      END LOOP;    

      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'qtdregis', pr_tag_cont => TO_CHAR(vr_contador), pr_des_erro => vr_dscritic);


    EXCEPTION
      WHEN vr_exc_saida THEN
        pr_dscritic := 'Erro geral na rotina da tela TELA_ATENDA_OCORRENCIAS - pc_busca_ctr_acordos: ' ||vr_dscritic;
        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      WHEN OTHERS THEN
        pr_dscritic := 'Erro não tratado na rotina da tela TELA_ATENDA_OCORRENCIAS - pc_busca_ctr_acordos: ' || SQLERRM;
        -- Carregar XML padrão para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END;
  END pc_busca_ctr_acordos;

  PROCEDURE pc_busca_dados_risco(pr_cpf_cnpj   IN NUMBER             --> Número do CNPJ ou CPF
                                ,pr_cdcooper   IN NUMBER             --> Código da cooperativa
                                ,pr_xmllog   IN VARCHAR2           --> XML com informações de LOG
                                ,pr_cdcritic OUT PLS_INTEGER       --> Código da crítica
                                ,pr_dscritic OUT VARCHAR2          --> Descrição da crítica
                                ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                                ,pr_des_erro OUT VARCHAR2) IS      --> Erros do processo
    /* .............................................................................

        Programa: pc_busca_dados_risco
        Sistema : CECRED
        Sigla   : EMPR
        Autor   : Daniel/AMcom
        Data    : Janeiro/2018                 Ultima atualizacao:

        Dados referentes ao programa:
        Frequencia: Sempre que for chamado
        Objetivo  : Rotina para consultar dados de risco crédito
        Observacao: -----
        Alteracoes:
      ..............................................................................*/
      ----------->>> VARIAVEIS <<<--------
      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
      vr_dscritic VARCHAR2(1000);        --> Desc. Erro

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      vr_auxconta INTEGER := 0; -- Contador auxiliar p/ posicao no XML

      vr_dstextab craptab.dstextab%TYPE;

      -- Variaveis retornadas da gene0004.pc_extrai_dados
      vr_cdcooper INTEGER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);

      ---------->> CURSORES <<--------      
      CURSOR cr_consulta_dados_risco (pr_cdcooper IN crapass.cdcooper%TYPE
                                     ,pr_cpf_cnpj IN crapass.nrcpfcgc%TYPE) IS
      select distinct /*'TIT' ID*/
           , a.nrcpfcgc CPF_CNPJ
           , a.nrdconta conta
           , c.nrctremp contrato     
           , r.dsnivcal risco_contrato
           , r.dsnivori risco_inclusao
           , g.nrdgrupo grupo_economico
           , g.dsdrisgp risco_grupo
           , rat.indrisco risco_rating
           , (CASE WHEN ris.qtdiaatr <   15 THEN 'A'
                   WHEN ris.qtdiaatr <=  30 THEN 'B'
                   WHEN ris.qtdiaatr <=  60 THEN 'C'
                   WHEN ris.qtdiaatr <=  90 THEN 'D'
                   WHEN ris.qtdiaatr <= 120 THEN 'E'
                   WHEN ris.qtdiaatr <= 150 THEN 'F'
                   WHEN ris.qtdiaatr <= 180 THEN 'G'
              ELSE 'H' END) risco_atraso
           , r.dsnivris risco_melhora
           , decode(agr.cdnivel_risco
                   ,2,'A'
                   ,3,'B'
                   ,4,'C'
                   ,5,'D'
                   ,6,'E'
                   ,7,'F'
                   ,8,'G'
                   ,9,'H') risco_agravado
           , null risco_final_operacao
           , decode(ris.innivris
                   ,2,'A'
                   ,3,'B'
                   ,4,'C'
                   ,5,'D'
                   ,6,'E'
                   ,7,'F'
                   ,8,'G'
                   ,9,'H') risco_cpf
           , ris.dtdrisco data_risco
           , ris.dtrefere-ris.dtdrisco dias_risco
           , decode(ris.innivris
                   ,2,'A'
                   ,3,'B'
                   ,4,'C'
                   ,5,'D'
                   ,6,'E'
                   ,7,'F'
                   ,8,'G'
                   ,9,'H') risco_central -- Deve trazer o valor do parametro de data MÊS
        from crapass a
           , crapris ris
           , crapepr c
           , crawepr r
           , crapgrp g  
           , crapnrc rat
           , cecred.tbrisco_cadastro_conta agr   
       where a.cdcooper = pr_cdcooper --parametro
         and decode(length(gene0002.fn_mask(pr_cpf_cnpj, DECODE(a.inpessoa, 1, '99999999999', '99999999999999'))), 14
                   ,substr(gene0002.fn_mask(a.nrcpfcgc, DECODE(a.inpessoa, 1, '99999999999', '99999999999999')), 1, 8)
                   ,a.nrcpfcgc)  = pr_cpf_cnpj --parametro
         --Risco          
         and ris.cdcooper = a.cdcooper
         and ris.dtrefere = (SELECT dtmvtoan FROM crapdat WHERE cdcooper = pr_cdcooper)
         and ris.nrdconta = a.nrdconta
         and ris.inddocto = 1
         --Contrato
         and c.inliquid   = 0
         and c.cdcooper   = ris.cdcooper
         and c.nrdconta   = ris.nrdconta
         --Risco inclusao
         and r.cdcooper = c.cdcooper
         and r.nrdconta = c.nrdconta
         and r.nrctremp = c.nrctremp
         --Grupo Economico
         and g.cdcooper(+) = ris.cdcooper
         and g.nrdconta(+) = ris.nrdconta
         -- Rating
         and rat.cdcooper(+) = ris.cdcooper
         and rat.nrdconta(+) = ris.nrdconta
         and rat.insitrat(+) = 2
         -- Risco Agravado
         and agr.cdcooper(+) = ris.cdcooper
         and agr.nrdconta(+) = ris.nrdconta
      union
      select distinct /*'GRU' ID*/
           , a.nrcpfcgc CPF_CNPJ
           , a.nrdconta conta
           , c.nrctremp contrato     
           , r.dsnivcal risco_contrato
           , r.dsnivori risco_inclusao
           , g.nrdgrupo grupo_economico
           , g.dsdrisgp risco_grupo
           , rat.indrisco risco_rating
           , (CASE WHEN ris.qtdiaatr <   15 THEN 'A'
                   WHEN ris.qtdiaatr <=  30 THEN 'B'
                   WHEN ris.qtdiaatr <=  60 THEN 'C'
                   WHEN ris.qtdiaatr <=  90 THEN 'D'
                   WHEN ris.qtdiaatr <= 120 THEN 'E'
                   WHEN ris.qtdiaatr <= 150 THEN 'F'
                   WHEN ris.qtdiaatr <= 180 THEN 'G'
              ELSE 'H' END) risco_atraso
           , r.dsnivris risco_melhora
           , decode(agr.cdnivel_risco
                   ,2,'A'
                   ,3,'B'
                   ,4,'C'
                   ,5,'D'
                   ,6,'E'
                   ,7,'F'
                   ,8,'G'
                   ,9,'H') risco_agravado
           , null risco_final_operacao
           , decode(ris.innivris
                   ,2,'A'
                   ,3,'B'
                   ,4,'C'
                   ,5,'D'
                   ,6,'E'
                   ,7,'F'
                   ,8,'G'
                   ,9,'H') risco_cpf
           , ris.dtdrisco data_risco
           , ris.dtrefere-ris.dtdrisco dias_risco
           , decode(ris.innivris
                   ,2,'A'
                   ,3,'B'
                   ,4,'C'
                   ,5,'D'
                   ,6,'E'
                   ,7,'F'
                   ,8,'G'
                   ,9,'H') risco_central -- Deve trazer o valor do parametro de data MÊS
        from crapass a
           , crapris ris
           , crapepr c
           , crawepr r
           , crapgrp g  
           , crapnrc rat
           , cecred.tbrisco_cadastro_conta agr  
           , (select distinct g.nrdgrupo grupo_economico
                from crapass a
                   , crapris ris
                   , crapepr c
                   , crawepr r
                   , crapgrp g  
                   , crapnrc rat
                   , cecred.tbrisco_cadastro_conta agr   
               where a.cdcooper = pr_cdcooper --parametro
                 and decode(length(gene0002.fn_mask(pr_cpf_cnpj, DECODE(a.inpessoa, 1, '99999999999', '99999999999999'))), 14
                           ,substr(gene0002.fn_mask(a.nrcpfcgc, DECODE(a.inpessoa, 1, '99999999999', '99999999999999')), 1, 8)
                           ,a.nrcpfcgc)  = pr_cpf_cnpj --parametro
                 --Risco          
                 and ris.cdcooper = a.cdcooper
                 and ris.dtrefere = (SELECT dtmvtoan FROM crapdat WHERE cdcooper = pr_cdcooper)
                 and ris.nrdconta = a.nrdconta
                 and ris.inddocto = 1
                 --Contrato
                 and c.inliquid   = 0
                 and c.cdcooper   = ris.cdcooper
                 and c.nrdconta   = ris.nrdconta
                 --Risco inclusao
                 and r.cdcooper = c.cdcooper
                 and r.nrdconta = c.nrdconta
                 and r.nrctremp = c.nrctremp
                 --Grupo Economico
                 and g.cdcooper(+) = ris.cdcooper
                 and g.nrdconta(+) = ris.nrdconta
                 -- Rating
                 and rat.cdcooper(+) = ris.cdcooper
                 and rat.nrdconta(+) = ris.nrdconta
                 and rat.insitrat(+) = 2
                 -- Risco Agravado
                 and agr.cdcooper(+) = ris.cdcooper
                 and agr.nrdconta(+) = ris.nrdconta) agr 
       where a.cdcooper = pr_cdcooper --parametro
         and decode(length(gene0002.fn_mask(pr_cpf_cnpj, DECODE(a.inpessoa, 1, '99999999999', '99999999999999'))), 14
                   ,substr(gene0002.fn_mask(a.nrcpfcgc, DECODE(a.inpessoa, 1, '99999999999', '99999999999999')), 1, 8)
                   ,a.nrcpfcgc)  = pr_cpf_cnpj --parametro
         --Risco          
         and ris.cdcooper = a.cdcooper
         and ris.dtrefere = (SELECT dtmvtoan FROM crapdat WHERE cdcooper = pr_cdcooper)
         and ris.nrdconta = a.nrdconta
         and ris.inddocto = 1
         --Contrato
         and c.inliquid   = 0
         and c.cdcooper   = ris.cdcooper
         and c.nrdconta   = ris.nrdconta
         --Risco inclusao
         and r.cdcooper = c.cdcooper
         and r.nrdconta = c.nrdconta
         and r.nrctremp = c.nrctremp
         --Grupo Economico
         and g.cdcooper(+) = ris.cdcooper
         and g.nrdconta(+) = ris.nrdconta
         --
         and g.nrdgrupo = agr.grupo_economico
         -- Rating
         and rat.cdcooper(+) = ris.cdcooper
         and rat.nrdconta(+) = ris.nrdconta
         and rat.insitrat(+) = 2
         -- Risco Agravado
         and agr.cdcooper(+) = ris.cdcooper
         and agr.nrdconta(+) = ris.nrdconta;
    rw_consulta_dados_risco cr_consulta_dados_risco%ROWTYPE;
      
    BEGIN

      pr_des_erro := 'OK';
      -- Extrai dados do xml
      gene0004.pc_extrai_dados(pr_xml      => pr_retxml,
                               pr_cdcooper => vr_cdcooper,
                               pr_nmdatela => vr_nmdatela,
                               pr_nmeacao  => vr_nmeacao,
                               pr_cdagenci => vr_cdagenci,
                               pr_nrdcaixa => vr_nrdcaixa,
                               pr_idorigem => vr_idorigem,
                               pr_cdoperad => vr_cdoperad,
                               pr_dscritic => vr_dscritic);

      -- Se retornou alguma crítica
      IF TRIM(vr_dscritic) IS NOT NULL THEN
        -- Levanta exceção
        RAISE vr_exc_saida;
      END IF;

      -- PASSA OS DADOS PARA O XML RETORNO
      -- Criar cabeçalho do XML
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Root',
                             pr_posicao  => 0,
                             pr_tag_nova => 'Dados',
                             pr_tag_cont => NULL,
                             pr_des_erro => vr_dscritic);
      -- Insere as tags
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Dados',
                             pr_posicao  => 0,
                             pr_tag_nova => 'inf',
                             pr_tag_cont => NULL,
                             pr_des_erro => vr_dscritic);

      -- CAMPOS
      -- Busca os dados
      OPEN cr_consulta_dados_risco(vr_cdcooper, vr_cpf_cnpj);
     FETCH cr_consulta_dados_risco
      INTO rw_consulta_dados_risco;
     CLOSE cr_consulta_dados_risco;


      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'CPF_CNPJ',
                             pr_tag_cont => rw_consulta_dados_risco.CPF_CNPJ,
                             pr_des_erro => vr_dscritic);

      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'conta',
                             pr_tag_cont => rw_consulta_dados_risco.conta,
                             pr_des_erro => vr_dscritic);

      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'contrato',
                             pr_tag_cont => rw_consulta_dados_risco.contrato,
                             pr_des_erro => vr_dscritic);                             

      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'risco_contrato',
                             pr_tag_cont => rw_consulta_dados_risco.risco_contrato,
                             pr_des_erro => vr_dscritic);                             
                             
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'risco_inclusao',
                             pr_tag_cont => rw_consulta_dados_risco.risco_inclusao,
                             pr_des_erro => vr_dscritic);                             

      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'grupo_economico',
                             pr_tag_cont => rw_consulta_dados_risco.grupo_economico,
                             pr_des_erro => vr_dscritic);                                                                                                                    

      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'risco_grupo',
                             pr_tag_cont => rw_consulta_dados_risco.risco_grupo,
                             pr_des_erro => vr_dscritic);                                                                                                                    

      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'risco_rating',
                             pr_tag_cont => rw_consulta_dados_risco.risco_rating,
                             pr_des_erro => vr_dscritic);                                                                                                                    

      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'risco_atraso',
                             pr_tag_cont => rw_consulta_dados_risco.risco_atraso,
                             pr_des_erro => vr_dscritic);                                                                                                                    

      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'risco_melhora',
                             pr_tag_cont => rw_consulta_dados_risco.risco_melhora,
                             pr_des_erro => vr_dscritic);                                                                                                                    

      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'risco_agravado',
                             pr_tag_cont => rw_consulta_dados_risco.risco_agravado,
                             pr_des_erro => vr_dscritic);                                                                                                                    

      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'risco_cpf',
                             pr_tag_cont => rw_consulta_dados_risco.risco_cpf,
                             pr_des_erro => vr_dscritic);                                                                                                                    

      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'data_risco',
                             pr_tag_cont => rw_consulta_dados_risco.data_risco,
                             pr_des_erro => vr_dscritic);                                                                                                                    

      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'dias_risco',
                             pr_tag_cont => rw_consulta_dados_risco.dias_risco,
                             pr_des_erro => vr_dscritic);                                                                                                                    

      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'risco_central',
                             pr_tag_cont => rw_consulta_dados_risco.risco_central,
                             pr_des_erro => vr_dscritic);                                                                                                                    


  EXCEPTION
    WHEN vr_exc_saida THEN

      IF vr_cdcritic <> 0 THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSE
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      END IF;

      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;
    WHEN OTHERS THEN

      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral na rotina da tela ' || vr_nmdatela || ': ' || SQLERRM;
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;
  END pc_consultar_dados_risco;  

END TELA_ATENDA_OCORRENCIAS;
/
