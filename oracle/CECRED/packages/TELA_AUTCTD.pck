CREATE OR REPLACE PACKAGE CECRED.TELA_AUTCTD AS
---------------------------------------------------------------------------------------------------------------
--
--    Programa: TELA_AUTCTD
--    Sistema : CECRED
--    Autor   : Rubens Lima (Mouts)
--    Data    : Dezembro/2018                   Ultima Atualizacao:
--
--    Dados referentes ao programa:
--
--    Objetivo  : Objetivo  : Centralizar rotinas relacionadas a Tela AUTCTD
--
--    Alteracoes:
--
---------------------------------------------------------------------------------------------------------------
  --PL/TABLE que contém os registros das contas e do tipo de pessoa
  TYPE typ_reg_pr_pre_postos IS
    RECORD (nrdconta NUMBER
           ,inpessoa VARCHAR2(1)
           ,nmprimtl VARCHAR2(100)
           ,nrcpfcgc VARCHAR2(100));

  --Tipo de tabela de memoria para registros de conta
  TYPE typ_tap_pr_pre_postos IS TABLE OF typ_reg_pr_pre_postos INDEX BY PLS_INTEGER;

  vr_tab_pre_postos typ_tap_pr_pre_postos;

  PROCEDURE PC_VER_CARTAO_MAG (pr_nrdconta IN crapass.nrdconta%TYPE --> Numero da conta
                              ,pr_tpcontrato IN tbgar_cobertura_operacao.tpcontrato%TYPE --> Tipo do contrato
                              ,pr_nrcontrato IN NUMBER --> Número do contrato
                              ,pr_vlcontrato IN NUMBER --> Valor do contrato
                              ,pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
                              ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                              ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                              ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                              ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                              ,pr_des_erro OUT VARCHAR2);
END;
/
CREATE OR REPLACE PACKAGE BODY CECRED.TELA_AUTCTD AS
---------------------------------------------------------------------------------------------------------------
--
--    Programa: TELA_AUTCTD
--    Sistema : CECRED
--    Autor   : Rubens Lima (Mouts)
--    Data    : Dezembro/2018                   Ultima Atualizacao:
--
--    Dados referentes ao programa:
--
--    Objetivo  : Objetivo  : Centralizar rotinas relacionadas a Tela AUTCTD
--
--    Alteracoes:
--
---------------------------------------------------------------------------------------------------------------
  PROCEDURE PC_VER_CARTAO_MAG (pr_nrdconta IN crapass.nrdconta%TYPE --> Numero da conta
                              ,pr_tpcontrato IN tbgar_cobertura_operacao.tpcontrato%TYPE --> Tipo do contrato
                              ,pr_nrcontrato IN NUMBER --> Número do contrato
                              ,pr_vlcontrato IN NUMBER --> Valor do contrato
                              ,pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
                              ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                              ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                              ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                              ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                              ,pr_des_erro OUT VARCHAR2) IS

    /* .............................................................................

        Programa: pc_ver_cartao_mag
        Sistema : CECRED
        Autor   : Rubens/Mouts
        Data    : Dezembro/2018                 Ultima atualizacao:

        Dados referentes ao programa:

        Frequencia: Sempre que for chamado

        Objetivo  : Verificar se o cooperado possui cartao magnetico

        Alteracoes:
    ..............................................................................*/

    ----------->>> VARIAVEIS <<<-----------
    vr_dstextab   craptab.dstextab%TYPE;
    vr_nrdconta   crapass.nrdconta%TYPE;
    vr_vlmincnt   NUMBER := 0;
    vr_inpessoa   crapass.inpessoa%TYPE;
    vr_idastcjt   crapass.idastcjt%TYPE;
    vr_index      NUMBER:=0;
    vr_qtcartoes  NUMBER:=0;
    vr_auxconta   PLS_INTEGER := 0;
    vr_inpreapv   VARCHAR2(1) := 'N';
    vr_ingarantia NUMBER;
    vr_inavalista NUMBER;
    vr_vlpreapv   crapcpa.vllimdis%TYPE := 0;
    vr_tab_dados_cpa empr0002.typ_tab_dados_cpa;
    vr_tab_erro      gene0001.typ_tab_erro;

    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%TYPE := 0;
    vr_dscritic VARCHAR2(4000);
    vr_exc_saida EXCEPTION;

    -- Variaveis de log
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem NUMBER;
    vr_dsorigem VARCHAR2(1000);

    ----------->>> CURSORES <<<-----------
   --Cursor para tipo de pessoa (1-PF 2-PJ)
   CURSOR cr_crapass (pr_cdcooper IN crapcop.cdcooper%TYPE,
                      pr_nrdconta IN crapass.nrdconta%TYPE) IS
      SELECT inpessoa
            ,idastcjt
      FROM crapass c
      WHERE c.cdcooper = pr_cdcooper
      AND c.nrdconta = pr_nrdconta;

   --Cursor para buscar numero da conta pessoa fisica
   CURSOR cr_nrdconta (pr_cdcooper IN crapcop.cdcooper%TYPE,
                       pr_nrdconta IN crapass.nrdconta%TYPE) IS
    SELECT DISTINCT a.nrdconta
                   ,a.inpessoa
                   ,gene0002.fn_mask_cpf_cnpj(a.nrcpfcgc, a.inpessoa) nrcpfcgc
                   ,a.nmprimtl
    FROM crapass a
    WHERE a.cdcooper = pr_cdcooper
    AND   a.nrdconta = pr_nrdconta;

   --Cursor para buscar contas de pessoa juridica
   CURSOR cr_nrctapro (pr_cdcooper IN crapcop.cdcooper%TYPE,
                       pr_nrdconta IN crapass.nrdconta%TYPE) IS
     SELECT DISTINCT a.nrctapro
                    ,c.inpessoa
                    ,NVL(TRIM(b.nmdavali),c.nmprimtl) nmprimtl
                    ,gene0002.fn_mask_cpf_cnpj(b.nrcpfcgc, c.inpessoa) nrcpfcgc
      FROM crappod a
          ,crapavt b
          ,crapass c
      WHERE a.cdcooper = pr_cdcooper
      AND a.nrdconta = pr_nrdconta
      AND a.nrctapro = b.nrdctato
      AND a.cddpoder = 10
      AND b.cdcooper = a.cdcooper
      AND b.nrdconta = a.nrdconta
      AND c.cdcooper = a.cdcooper
      AND c.nrdconta = a.nrctapro;

   --Cursor para buscar garantia do contrato 
   CURSOR cr_garantia (pr_cdcooper   IN crapcop.cdcooper%TYPE,
                       pr_nrdconta   IN crapass.nrdconta%TYPE,
                       pr_nrcontrato IN NUMBER) IS
     SELECT DISTINCT 1
       FROM TBGAR_COBERTURA_OPERACAO
      WHERE cdcooper   = pr_cdcooper
        AND nrdconta   = pr_nrdconta
        AND nrcontrato = pr_nrcontrato
        AND perminimo  > 0;

   --Cursor para buscar avalista/fiador 
   CURSOR cr_avalista (pr_cdcooper   IN crapcop.cdcooper%TYPE,
                       pr_nrdconta   IN crapass.nrdconta%TYPE,
                       pr_nrcontrato IN NUMBER) IS
     SELECT DISTINCT retorno
       FROM (SELECT DISTINCT 1 retorno
               FROM craplim
              WHERE cdcooper = pr_cdcooper
                AND nrdconta = pr_nrdconta
                AND nrctrlim = pr_nrcontrato
                AND nrctaav1 + nrctaav2 > 0
             UNION
             SELECT DISTINCT 1
               FROM crawlim
              WHERE cdcooper = pr_cdcooper
                AND nrdconta = pr_nrdconta
                AND nrctrlim = pr_nrcontrato
                AND nrctaav1 + nrctaav2 > 0);

BEGIN
    --Inicializa a conta
    vr_nrdconta := pr_nrdconta;

    gene0001.pc_informa_acesso(pr_module => 'TELA_AUTCTD');

    -- Extrai os dados vindos do XML
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml,
                             pr_cdcooper => vr_cdcooper,
                             pr_nmdatela => vr_nmdatela,
                             pr_nmeacao  => vr_nmeacao,
                             pr_cdagenci => vr_cdagenci,
                             pr_nrdcaixa => vr_nrdcaixa,
                             pr_idorigem => vr_idorigem,
                             pr_cdoperad => vr_cdoperad,
                             pr_dscritic => vr_dscritic);

    IF vr_dscritic IS NOT NULL THEN
      vr_cdcooper := 1;
      vr_idorigem := 5;
    END IF;

    vr_dsorigem := gene0001.vr_vet_des_origens(vr_idorigem);

    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');

   --Buscar Tipo de Pessoa
   OPEN cr_crapass(pr_cdcooper => vr_cdcooper,
                   pr_nrdconta => vr_nrdconta);
   FETCH cr_crapass
   INTO vr_inpessoa
       ,vr_idastcjt;
   CLOSE cr_crapass;

    vr_vlmincnt := 999999999999;
    vr_vlpreapv := 999999999999;
    vr_inpreapv := 'N';
    
    IF (pr_tpcontrato in (26,27,28,29)) THEN
      --Buscar parametro de credito
      vr_dstextab := TABE0001.fn_busca_dstextab(pr_cdcooper => vr_cdcooper
                                               ,pr_nmsistem => 'CRED'
                                               ,pr_tptabela => 'GENERI'
                                               ,pr_cdempres => 0
                                               ,pr_cdacesso => 'PARCONTRATO'
                                               ,pr_tpregist => 01);
      vr_inpreapv := SUBSTR(vr_dstextab,1,1);
      vr_vlmincnt := gene0002.fn_char_para_number(SUBSTR(vr_dstextab,3,12));

    --Consulta se deve buscar valor pre aprovado do cooperado, senão Zero
    IF (vr_inpreapv = 'N') THEN
        vr_vlpreapv := 0;
    ELSIF (vr_inpreapv = 'S') THEN
      empr0002.pc_busca_dados_cpa(pr_cdcooper => vr_cdcooper
                                 ,pr_cdagenci => 1
                                 ,pr_nrdcaixa => 1
                                 ,pr_cdoperad => 1
                                 ,pr_nmdatela => 'AUTCTD'
                                 ,pr_idorigem => 0
                                 ,pr_nrdconta => vr_nrdconta
                                 ,pr_idseqttl => 1
                                 ,pr_nrcpfope => 0
                                 ,pr_tab_dados_cpa => vr_tab_dados_cpa
                                 ,pr_des_reto => vr_dscritic
                                 ,pr_tab_erro => vr_tab_erro);
      IF vr_dscritic = 'NOK' THEN
        vr_dscritic := vr_tab_erro(1).erro;
        RAISE vr_exc_saida;
      END IF;
      vr_dscritic := NULL;
      --
      IF vr_tab_dados_cpa.count() > 0 THEN
        vr_vlpreapv := vr_tab_dados_cpa(1).vldiscrd;
        ELSE
          vr_vlpreapv := 0;
      END IF;
    END IF;

   --Verifica se o valor do contrato excede o Maior Valor entre (Minimo do contrato e Pre Aprovado)
   IF (NVL(pr_vlcontrato,0) > GREATEST(vr_vlmincnt, vr_vlpreapv)) THEN
      --Escreve o XML
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'qtcartoes', pr_tag_cont => to_char(vr_qtcartoes), pr_des_erro => vr_dscritic);
      --Finalizou com sucesso
      pr_des_erro := 'OK';
     --Sair do programa
      RETURN;
      END IF; 
   END IF;

   --Buscar se a cooperativa/conta do parâmetro tem cartão de acordo com o tipo de pessoa (1-PF, 2-PJ)
   IF (vr_inpessoa = 1)
   OR (vr_inpessoa = 2 AND vr_idastcjt = 0)
   THEN
     FOR rw_nrdconta in cr_nrdconta (pr_cdcooper => vr_cdcooper,
                                     pr_nrdconta => vr_nrdconta) LOOP
       vr_index := vr_index + 1;
       --Alimenta vetor com os dados da conta do associado
       vr_tab_pre_postos(vr_index).nrdconta := rw_nrdconta.nrdconta;
       vr_tab_pre_postos(vr_index).inpessoa := rw_nrdconta.inpessoa;
       vr_tab_pre_postos(vr_index).nmprimtl := rw_nrdconta.nmprimtl;
       vr_tab_pre_postos(vr_index).nrcpfcgc := rw_nrdconta.nrcpfcgc;
     END LOOP;
   ELSE
     FOR rw_nrdconta in cr_nrctapro (pr_cdcooper => vr_cdcooper,
                                     pr_nrdconta => vr_nrdconta) LOOP
       vr_index := vr_index + 1;
       --Alimenta vetor com os dados dos associados
       vr_tab_pre_postos(vr_index).nrdconta := rw_nrdconta.nrctapro;
       vr_tab_pre_postos(vr_index).inpessoa := rw_nrdconta.inpessoa;
       vr_tab_pre_postos(vr_index).nmprimtl := rw_nrdconta.nmprimtl;
       vr_tab_pre_postos(vr_index).nrcpfcgc := rw_nrdconta.nrcpfcgc;
     END LOOP;
   END IF; 
  
   -- Verificar se o contrato tem garantia ou avalista/fiador
   -- Caso tenha deve passar a quantidade de cartões como 0 (Zero)
   IF vr_index > 0 THEN
     vr_ingarantia := 0;
     vr_inavalista := 0;
     IF pr_tpcontrato in (27 -- Limite de Desc. Chq. (Contrato)
                         ,28 -- Limite de Desc. Tit. (Contrato)
                         ,29 -- Limite de Crédito (Contrato)
                         ) THEN
       -- Verificar se tem garantias
       OPEN cr_garantia(pr_cdcooper => vr_cdcooper,
                        pr_nrdconta => vr_nrdconta,
                        pr_nrcontrato => pr_nrcontrato);
       FETCH cr_garantia
        INTO vr_ingarantia;
       CLOSE cr_garantia;
       -- Verificar se tem garantias
       OPEN cr_avalista(pr_cdcooper => vr_cdcooper,
                        pr_nrdconta => vr_nrdconta,
                        pr_nrcontrato => pr_nrcontrato);
       FETCH cr_avalista
        INTO vr_inavalista;
       CLOSE cr_avalista;
       --
       IF vr_ingarantia = 1
       OR vr_inavalista = 1 THEN
         --Escreve o XML
         gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
         gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'qtcartoes', pr_tag_cont => to_char(vr_qtcartoes), pr_des_erro => vr_dscritic);
         --Finalizou com sucesso
         pr_des_erro := 'OK';  
         --Sair do programa
         RETURN;
       END IF;
     END IF;
   END IF;

   vr_qtcartoes := vr_index;

   --Escreve o XML
   gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);

   FOR i in 1 .. vr_index LOOP
       gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'contas', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
      --Grava a conta
      gene0007.pc_insere_tag(pr_xml => pr_retxml,
                             pr_tag_pai => 'contas',
                             pr_posicao => vr_auxconta,
                             pr_tag_nova => 'nrdconta',
                             pr_tag_cont => to_char(vr_tab_pre_postos(i).nrdconta),
                             pr_des_erro => vr_dscritic);
      --Grava o tipo de pessoa
      gene0007.pc_insere_tag(pr_xml => pr_retxml,
                             pr_tag_pai => 'contas',
                             pr_posicao => vr_auxconta,
                             pr_tag_nova => 'inpessoa',
                             pr_tag_cont => to_char(vr_tab_pre_postos(i).inpessoa),
                             pr_des_erro => vr_dscritic);
      --Grava o nome de pessoa
      gene0007.pc_insere_tag(pr_xml => pr_retxml,
                             pr_tag_pai => 'contas',
                             pr_posicao => vr_auxconta,
                             pr_tag_nova => 'nmprimtl',
                             pr_tag_cont => to_char(vr_tab_pre_postos(i).nmprimtl),
                             pr_des_erro => vr_dscritic);
      --Grava o cpf/cgc de pessoa
      gene0007.pc_insere_tag(pr_xml => pr_retxml,
                             pr_tag_pai => 'contas',
                             pr_posicao => vr_auxconta,
                             pr_tag_nova => 'nrcpfcgc',
                             pr_tag_cont => to_char(vr_tab_pre_postos(i).nrcpfcgc),
                             pr_des_erro => vr_dscritic);

      vr_auxconta := nvl(vr_auxconta,0) + 1;

   END LOOP;

   gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'qtcartoes', pr_tag_cont => to_char(vr_qtcartoes), pr_des_erro => vr_dscritic);
   gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'inpessoa', pr_tag_cont => vr_inpessoa, pr_des_erro => vr_dscritic);

   --Finalizou com sucesso
   pr_des_erro := 'OK';

   EXCEPTION
     WHEN vr_exc_saida THEN

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
     WHEN OTHERS THEN
      cecred.pc_internal_exception(3);
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral em TELA_AUTCTD.PC_VER_CARTAO_MAG';
      pr_des_erro := 'NOK';

      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic ||
                                     '</Erro></Root>');

  END;

END TELA_AUTCTD;
/
