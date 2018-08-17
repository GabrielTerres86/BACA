CREATE OR REPLACE PACKAGE CECRED.PREJ0004 AS

  /*..............................................................................

     Programa: PREJ0004                       Antigo: Nao ha
     Sistema : Cred
     Sigla   : CRED
     Autor   : Odirlei Busana - AMCom
     Data    : Junho/2018                      Ultima atualizacao:

     Dados referentes ao programa:

     Frequencia: Diária (sempre que chamada)
     Objetivo  : Rotinas genericas para geração de extrato dos lançamentos bloqueado por prejuizo.

     Alteracoes: Criado a procedure para imprimir o extrato web (pc_extrato_lanc_prej_web)
				 PJ 450 - Diego Simas - AMcom

  ..............................................................................*/

  TYPE typ_rec_lancto
    IS RECORD(tpregistro VARCHAR2(2), --> Tipo de registro SI-Saldo inicial, SD-Saldo dia, L -Lancamento
              dsextrato VARCHAR2(40), --> apresentará o termo, Saldo Inicial, ou a data
              dtmvtolt  DATE,
              nrdocmto  tbcc_prejuizo_lancamento.nrdocmto%TYPE,
              cdhistor  craphis.cdhistor%TYPE,
              dshistor  craphis.dshistor%TYPE,
              indebcre  craphis.indebcre%TYPE,
              vllamnto  tbcc_prejuizo_lancamento.vllanmto%TYPE,
              vlslddia  NUMBER
             );

  TYPE typ_tab_lanctos IS TABLE OF typ_rec_lancto
       INDEX BY PLS_INTEGER;

  PROCEDURE pc_extrato_lanc_prej_relat (pr_cdcooper IN crapcop.cdcooper%TYPE         --> Coop conectada
                                       ,pr_nrdconta IN crapass.nrdconta%TYPE         --> Numero da conta
                                       ,pr_dtiniper IN DATE                          --> Data incio do periodo do prejuizo
                                       ,pr_dtfimper IN DATE                          --> Data final do periodo do prejuizo
                                       ,pr_nmdirimp OUT VARCHAR2                     --> Retornar diretorio da impressao
                                       ,pr_nmarqimp OUT VARCHAR2                     --> Retorna nome do relatorio
                                       ,pr_cdcritic OUT crapcri.cdcritic%TYPE        --> Critica encontrada
                                       ,pr_dscritic OUT VARCHAR2 );
                                       
  PROCEDURE pc_extrato_lanc_prej_relat_web(pr_nrdconta          IN crapass.nrdconta%TYPE   --> Numero da conta
                                          ,pr_dtiniper          IN VARCHAR2                    --> Data incio do periodo do prejuizo
                                          ,pr_dtfimper          IN VARCHAR2                    --> Data final do periodo do prejuizo
                                          ,pr_xmllog            IN VARCHAR2                --> XML com informacoes de LOG
                                          ,pr_cdcritic          OUT PLS_INTEGER            --> Codigo da critica
                                          ,pr_dscritic          OUT VARCHAR2               --> Descricao da critica
                                          ,pr_retxml         IN OUT NOCOPY xmltype         --> Arquivo de retorno do XML
                                          ,pr_nmdcampo          OUT VARCHAR2               --> Nome do campo com erro
                                          ,pr_des_erro          OUT VARCHAR2);                                         

  PROCEDURE pc_extrato_lanc_prej_web(pr_cdcooper          IN crapcop.cdcooper%TYPE   --> Coop conectada
                                    ,pr_nrdconta          IN crapass.nrdconta%TYPE   --> Numero da conta
                                    ,pr_dtiniper          IN VARCHAR2            --> Data incio do periodo do prejuizo
                                    ,pr_dtfimper          IN VARCHAR2             --> Data final do periodo do prejuizo
                                    ,pr_xmllog            IN VARCHAR2                --> XML com informacoes de LOG
                                    ,pr_cdcritic          OUT PLS_INTEGER            --> Codigo da critica
                                    ,pr_dscritic          OUT VARCHAR2               --> Descricao da critica
                                    ,pr_retxml         IN OUT NOCOPY xmltype         --> Arquivo de retorno do XML
                                    ,pr_nmdcampo          OUT VARCHAR2               --> Nome do campo com erro
                                    ,pr_des_erro          OUT VARCHAR2);             --> Erros do processo


end PREJ0004;
/
CREATE OR REPLACE PACKAGE BODY CECRED.PREJ0004 AS
/*..............................................................................

   Programa: PREJ0004                       Antigo: Nao ha
   Sistema : Cred
   Sigla   : CRED
   Autor   : Odirlei Busana - AMCom
   Data    : Junho/2018                      Ultima atualizacao:

   Dados referentes ao programa:

   Frequencia: Diária (sempre que chamada)
   Objetivo  : Rotinas genericas para geração de extrato dos lançamentos bloqueado por prejuizo.

   Alteracoes:
..............................................................................*/



  PROCEDURE pc_retorna_lancamentos_prej ( pr_cdcooper IN crapcop.cdcooper%TYPE         --> Coop conectada
                                         ,pr_nrdconta IN crapass.nrdconta%TYPE         --> Numero da conta
                                         ,pr_dtiniper IN DATE                          --> Data incio do periodo do prejuizo
                                         ,pr_dtfimper IN DATE                          --> Data final do periodo do prejuizo
                                         ,pr_tab_lanctos OUT typ_tab_lanctos
                                         ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                                         ,pr_dscritic OUT VARCHAR2 ) is
    /* .............................................................................

    Programa: pc_transfere_prejuizo_cc
    Sistema :
    Sigla   : PREJ
    Autor   : Odirlei Busana - AMcom
    Data    : Maio/2018.                  Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Retornar tabela com os lançamentos para extrado bloqueado do prejuizo

    Alteracoes:

    ..............................................................................*/

    ---->> CURSORES <<-----
    --> Listar lancamentos bloqueados em prejuizo
    CURSOR cr_lanc(pr_cdcooper IN crapass.cdcooper%TYPE,
                   pr_nrdconta IN crapass.nrdconta%TYPE,
                   pr_dtiniper IN DATE,
                   pr_dtfimper IN DATE ) IS
      SELECT t.idlancto_prejuizo,
             t.dtmvtolt,
             t.nrdocmto,
             t.cdhistor,
             t.dshistor,
             t.indebcre,
             abs(t.vllanmto) vllanmto,
             SUM(SUM(t.vllanmto)) OVER(ORDER BY idlancto_prejuizo ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) vlsaldo,
             COUNT(1) OVER (PARTITION BY t.dtmvtolt ) nrregtot,
             row_number() OVER (PARTITION BY t.dtmvtolt ORDER BY t.idlancto_prejuizo ) nrregist
        FROM (SELECT lan.idlancto_prejuizo,
                     lan.dtmvtolt,
                     lan.nrdocmto,
                     his.cdhistor,
                     his.dshistor,
                     his.indebcre,
                     decode(his.indebcre,'D',lan.vllanmto*-1,lan.vllanmto) vllanmto
                FROM tbcc_prejuizo_lancamento lan,
                     craphis his
               WHERE lan.cdcooper = his.cdcooper
                 AND lan.cdhistor = his.cdhistor
                 AND lan.cdcooper = pr_cdcooper
                 AND lan.nrdconta = pr_nrdconta
                 AND lan.dtmvtolt BETWEEN pr_dtiniper AND pr_dtfimper) t
        -- Group apenas para acrescentar campo com sumarização - vlsaldo
        GROUP BY t.idlancto_prejuizo
                ,t.dtmvtolt
                ,t.nrdocmto
                ,t.cdhistor
                ,t.dshistor
                ,t.indebcre
                ,t.vllanmto
        ORDER BY t.idlancto_prejuizo;


    ---->> VARIAVEIS <<-----
     vr_cdcritic    NUMBER(3);
     vr_dscritic    VARCHAR2(1000);
     vr_exc_erro    EXCEPTION;

     rw_crapdat     btch0001.cr_crapdat%ROWTYPE;
     vr_tab_lanctos typ_tab_lanctos;
     vr_idx         PLS_INTEGER;
     vr_dtmvtoan    DATE;
     vr_vlsldini    NUMBER;

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
      RAISE vr_exc_erro;
    ELSE
      -- Apenas fechar o cursor
      CLOSE btch0001.cr_crapdat;
    END IF;


    --->> BUSCAR SALDO INICIAL <<---
    vr_dtmvtoan := gene0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper,
                                               pr_dtmvtolt => pr_dtiniper - 1 ,
                                               pr_tipo     => 'A');


    --> obtem saldo do dia anterior
    PREJ0003.pc_ret_saldo_dia_prej (pr_cdcooper  => pr_cdcooper        --> Coop conectada
                                   ,pr_nrdconta  => pr_nrdconta        --> Numero da conta
                                   ,pr_dtmvtolt  => vr_dtmvtoan        --> Data incio do periodo do prejuizo
                                   ,pr_vldsaldo  => vr_vlsldini         --> Retorna valor do saldo
                                   ,pr_cdcritic  => vr_cdcritic         --> Critica encontrada
                                   ,pr_dscritic  => vr_dscritic);

    IF nvl(vr_cdcritic,0) > 0 OR
       TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;

    --> Incluir saldo inicial
    vr_idx := vr_tab_lanctos.count + 1;

    vr_tab_lanctos(vr_idx).tpregistro := 'SI'; --> SALDO INICIAL
    vr_tab_lanctos(vr_idx).dsextrato := 'SALDO ANTERIOR';
    vr_tab_lanctos(vr_idx).dtmvtolt  := vr_dtmvtoan;
    vr_tab_lanctos(vr_idx).cdhistor  := NULL;
    vr_tab_lanctos(vr_idx).dshistor  := NULL;
    vr_tab_lanctos(vr_idx).indebcre  := NULL;
    vr_tab_lanctos(vr_idx).vllamnto  := NULL;
    vr_tab_lanctos(vr_idx).vlslddia  := vr_vlsldini;
    --->> FIM BUSCAR SALDO INICIAL <<---

    --> Listar lancamentos bloqueados em prejuizo
    FOR rw_lanc IN cr_lanc(pr_cdcooper => pr_cdcooper,
                           pr_nrdconta => pr_nrdconta,
                           pr_dtiniper => pr_dtiniper,
                           pr_dtfimper => pr_dtfimper) LOOP
      vr_idx := vr_tab_lanctos.count + 1;

      --> Incluir lancamento
      vr_tab_lanctos(vr_idx).tpregistro := 'L'; --> Lancamento
      vr_tab_lanctos(vr_idx).dsextrato := rw_lanc.dshistor;
      vr_tab_lanctos(vr_idx).dtmvtolt  := rw_lanc.dtmvtolt;
      vr_tab_lanctos(vr_idx).nrdocmto  := rw_lanc.nrdocmto;
      vr_tab_lanctos(vr_idx).cdhistor  := rw_lanc.cdhistor;
      vr_tab_lanctos(vr_idx).dshistor  := rw_lanc.dshistor;
      vr_tab_lanctos(vr_idx).indebcre  := rw_lanc.indebcre;
      vr_tab_lanctos(vr_idx).vllamnto  := rw_lanc.vllanmto;


      IF rw_lanc.nrregtot = rw_lanc.nrregist THEN

        --> Informar valor na coluna de saldo, incrementando valor do saldo inicial
        vr_tab_lanctos(vr_idx).vlslddia  := rw_lanc.vlsaldo + vr_vlsldini;

        --> Incluir saldo do dia
        vr_idx := vr_tab_lanctos.count + 1;

        vr_tab_lanctos(vr_idx).tpregistro := 'SD';
        vr_tab_lanctos(vr_idx).dsextrato := to_char(rw_lanc.dtmvtolt,'DD/MM/RRRR');
        vr_tab_lanctos(vr_idx).dtmvtolt  := rw_lanc.dtmvtolt;
        vr_tab_lanctos(vr_idx).cdhistor  := NULL;
        vr_tab_lanctos(vr_idx).dshistor  := NULL;
        vr_tab_lanctos(vr_idx).indebcre  := NULL;
        vr_tab_lanctos(vr_idx).vllamnto  := NULL;
        vr_tab_lanctos(vr_idx).vlslddia  := rw_lanc.vlsaldo + vr_vlsldini;

      END IF;

    END LOOP;

    pr_tab_lanctos := vr_tab_lanctos;

  EXCEPTION
    WHEN vr_exc_erro THEN
      IF nvl(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      END IF;

      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;

    WHEN OTHERS THEN
      ROLLBACK;
      -- Efetuar retorno do erro não tratado
      pr_cdcritic := 0;
      pr_dscritic := 'Erro ao buscar lancamentos: ' ||SQLERRM;

  END pc_retorna_lancamentos_prej;
--

  PROCEDURE pc_extrato_lanc_prej_relat (pr_cdcooper IN crapcop.cdcooper%TYPE         --> Coop conectada
                                       ,pr_nrdconta IN crapass.nrdconta%TYPE         --> Numero da conta
                                       ,pr_dtiniper IN DATE                          --> Data incio do periodo do prejuizo
                                       ,pr_dtfimper IN DATE                          --> Data final do periodo do prejuizo
                                       ,pr_nmdirimp OUT VARCHAR2                     --> Retornar diretorio da impressao
                                       ,pr_nmarqimp OUT VARCHAR2                     --> Retorna nome do relatorio
                                       ,pr_cdcritic OUT crapcri.cdcritic%TYPE        --> Critica encontrada
                                       ,pr_dscritic OUT VARCHAR2 ) is
    /* .............................................................................

    Programa: pc_gerar_extrato_lanc_prej
    Sistema :
    Sigla   : PREJ
    Autor   : Odirlei Busana - AMcom
    Data    : Maio/2018.                  Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para gerar o relatorio do extrato.

    Alteracoes:

    ..............................................................................*/

    ---->> CURSORES <<-----
    --> Buscar dados do associado
    CURSOR cr_crapass (pr_cdcooper IN crapass.cdcooper%TYPE,
                       pr_nrdconta IN crapass.nrdconta%TYPE)IS
      SELECT ass.nmprimtl
        FROM crapass ass
       WHERE ass.cdcooper = pr_cdcooper
         AND ass.nrdconta = pr_nrdconta;
    rw_crapass cr_crapass%ROWTYPE;

    ---->> VARIAVEIS <<-----
    vr_cdcritic    NUMBER(3);
    vr_dscritic    VARCHAR2(1000);
    vr_exc_erro    EXCEPTION;

    rw_crapdat     btch0001.cr_crapdat%ROWTYPE;
    vr_tab_lanctos typ_tab_lanctos;

    vr_nmdireto  VARCHAR2(100);

    -- Variáveis para armazenar as informações em XML
    vr_des_xml         CLOB;
    -- Variável para armazenar os dados do XML antes de incluir no CLOB
    vr_texto_completo  VARCHAR2(32600);

    --------------------------- SUBROTINAS INTERNAS --------------------------
    -- Subrotina para escrever texto na variável CLOB do XML
    PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR2,
                             pr_fecha_xml IN BOOLEAN DEFAULT FALSE) IS
    BEGIN
      gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo, pr_des_dados, pr_fecha_xml);
    END;

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
      RAISE vr_exc_erro;
    ELSE
      -- Apenas fechar o cursor
      CLOSE btch0001.cr_crapdat;
    END IF;

    --> Buscar dados do associado
    OPEN cr_crapass (pr_cdcooper => pr_cdcooper,
                     pr_nrdconta => pr_nrdconta);
    FETCH cr_crapass INTO rw_crapass;
    IF cr_crapass%NOTFOUND THEN
      vr_cdcritic := 9;
      CLOSE cr_crapass;
      RAISE vr_exc_erro;

    ELSE
      CLOSE cr_crapass;
    END IF;

    pc_retorna_lancamentos_prej ( pr_cdcooper    => pr_cdcooper         --> Coop conectada
                                 ,pr_nrdconta    => pr_nrdconta         --> Numero da conta
                                 ,pr_dtiniper    => pr_dtiniper         --> Data incio do periodo do prejuizo
                                 ,pr_dtfimper    => pr_dtfimper         --> Data final do periodo do prejuizo
                                 ,pr_tab_lanctos => vr_tab_lanctos
                                 ,pr_cdcritic    => vr_cdcritic         --> Critica encontrada
                                 ,pr_dscritic    => vr_dscritic);

    IF nvl(vr_cdcritic,0) > 0 OR
       TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;


    -- Leitura da PL/Table e geração do arquivo XML
    -- Inicializar o CLOB
    vr_des_xml := NULL;
    dbms_lob.createtemporary(vr_des_xml, TRUE);
    dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);

    -- Inicilizar as informações do XML
    vr_texto_completo := NULL;
    pc_escreve_xml('<?xml version="1.0" encoding="utf-8"?><root nmprimtl="'||rw_crapass.nmprimtl||'" '||
                                                              ' nrdconta="'||gene0002.fn_mask_conta(pr_nrdconta)||'" '||
                                                              '>');

    pc_escreve_xml('<lancamentos>');

    IF vr_tab_lanctos.count > 0 THEN
      FOR idx IN vr_tab_lanctos.first..vr_tab_lanctos.last LOOP
        IF vr_tab_lanctos(idx).tpregistro = 'SD' THEN
          continue;
        END IF;

        pc_escreve_xml('<lancamento>' ||
                           '<tpregistro>'|| vr_tab_lanctos(idx).tpregistro  ||'</tpregistro>' ||
                           '<dsextrato>' || vr_tab_lanctos(idx).dsextrato    ||'</dsextrato>' ||
                           '<dtmvtolt>'  || to_char(vr_tab_lanctos(idx).dtmvtolt,'DD/MM/RR')           ||'</dtmvtolt>'  ||
                           '<nrdocmto>'  || gene0002.fn_mask_contrato(vr_tab_lanctos(idx).nrdocmto)    ||'</nrdocmto>'  ||
                           '<cdhistor>'  || vr_tab_lanctos(idx).cdhistor     ||'</cdhistor>'  ||
                           '<dshistor>'  || vr_tab_lanctos(idx).dshistor     ||'</dshistor>'  ||
                           '<indebcre>'  || vr_tab_lanctos(idx).indebcre     ||'</indebcre>'  ||
                           '<vllamnto>'  || to_char(vr_tab_lanctos(idx).vllamnto,'999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS='',.''')    ||'</vllamnto>'  ||
                           '<vlslddia>'  || to_char(vr_tab_lanctos(idx).vlslddia,'999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS='',.''')    ||'</vlslddia>'  ||
                       '</lancamento>');
      END LOOP;

    END IF;

    pc_escreve_xml('</lancamentos></root>',TRUE);

    pr_nmarqimp := 'crrl743_'||pr_nrdconta||'.pdf';

    -- Busca do diretório base da cooperativa para PDF
    vr_nmdireto := gene0001.fn_diretorio(pr_tpdireto => 'C' -- /usr/coop
                                          ,pr_cdcooper => pr_cdcooper
                                          ,pr_nmsubdir => '/rl'); --> Utilizaremos o rl
    pr_nmdirimp := vr_nmdireto;
    -- Efetuar solicitação de geração de relatório --
    gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper         --> Cooperativa conectada
                               ,pr_cdprogra  => 'ATENDA'            --> Programa chamador
                               ,pr_dtmvtolt  => rw_crapdat.dtmvtolt --> Data do movimento atual
                               ,pr_dsxml     => vr_des_xml          --> Arquivo XML de dados
                               ,pr_dsxmlnode => '/root/lancamentos/lancamento'    --> Nó base do XML para leitura dos dados
                               ,pr_dsjasper  => 'crrl743.jasper'    --> Arquivo de layout do iReport
                               ,pr_cdrelato  => 743
                               ,pr_dsparams  => NULL                --> Sem parametros
                               ,pr_dsarqsaid => vr_nmdireto||'/'||pr_nmarqimp --> Arquivo final com código da agência
                               ,pr_qtcoluna  => 80                  --> 132 colunas
                               ,pr_sqcabrel  => 1                   --> Sequencia do Relatorio {includes/cabrel132_5.i}
                               ,pr_flg_impri => 'S'                 --> Chamar a impressão (Imprim.p)
                               ,pr_nmformul  => '80col'             --> Nome do formulário para impressão
                               ,pr_nrcopias  => 1                   --> Número de cópias
                               ,pr_flg_gerar => 'S'                 --> gerar PDF
                               ,pr_nrvergrl  => 1                   --> versao do gerador de relatorio
                               ,pr_des_erro  => vr_dscritic);       --> Saída com erro
    -- Testar se houve erro
    IF vr_dscritic IS NOT NULL THEN
      -- Gerar exceção
      RAISE vr_exc_erro;
    END IF;

    -- Liberando a memória alocada pro CLOB
    dbms_lob.close(vr_des_xml);
    dbms_lob.freetemporary(vr_des_xml);

  EXCEPTION
    WHEN vr_exc_erro THEN
      IF nvl(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      END IF;

      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;

    WHEN OTHERS THEN
      ROLLBACK;
      -- Efetuar retorno do erro não tratado
      pr_cdcritic := 0;
      pr_dscritic := 'Erro ao gerar extrato em relatorio: ' ||SQLERRM;

  END pc_extrato_lanc_prej_relat;
--
PROCEDURE pc_extrato_lanc_prej_relat_web ( pr_nrdconta          IN crapass.nrdconta%TYPE   --> Numero da conta
                                          ,pr_dtiniper          IN VARCHAR2                    --> Data incio do periodo do prejuizo
                                          ,pr_dtfimper          IN VARCHAR2                    --> Data final do periodo do prejuizo
                                          ,pr_xmllog            IN VARCHAR2                --> XML com informacoes de LOG
                                          ,pr_cdcritic          OUT PLS_INTEGER            --> Codigo da critica
                                          ,pr_dscritic          OUT VARCHAR2               --> Descricao da critica
                                          ,pr_retxml         IN OUT NOCOPY xmltype         --> Arquivo de retorno do XML
                                          ,pr_nmdcampo          OUT VARCHAR2               --> Nome do campo com erro
                                          ,pr_des_erro          OUT VARCHAR2) IS           --> Erros do processo
    /* .............................................................................

    Programa: pc_extrato_lanc_prej_relat_web
    Sistema :
    Sigla   : PREJ
    Autor   : Odirlei Busana - AMcom
    Data    : Maio/2018.                  Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para gerar o relatorio do extrato(Versao chamada web).

    Alteracoes:

    ..............................................................................*/

    ---->> CURSORES <<-----

    ---->> VARIAVEIS <<-----
    vr_cdcritic    NUMBER(3);
    vr_dscritic    VARCHAR2(1000);
    vr_des_reto    VARCHAR2(100);
    vr_tab_erro    GENE0001.typ_tab_erro;
    vr_exc_erro    EXCEPTION;

    rw_crapdat     btch0001.cr_crapdat%ROWTYPE;

    vr_dscomand    VARCHAR2(4000);
    vr_typsaida    VARCHAR2(100);
    vr_nmdirimp    VARCHAR2(100);
    vr_nmarqimp    VARCHAR2(100);

    -- Variaveis de log
    vr_cdcooper INTEGER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);


    --------------------------- SUBROTINAS INTERNAS --------------------------


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

    -- Leitura do calendário da cooperativa
    OPEN btch0001.cr_crapdat(pr_cdcooper => vr_cdcooper);
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


    pc_extrato_lanc_prej_relat (pr_cdcooper => vr_cdcooper        --> Coop conectada
                               ,pr_nrdconta => pr_nrdconta        --> Numero da conta
                               ,pr_dtiniper => to_date(pr_dtiniper, 'DD/MM/YYYY') --> Data incio do periodo do prejuizo
                               ,pr_dtfimper => to_date(pr_dtfimper, 'DD/MM/YYYY') --> Data final do periodo do prejuizo
                               ,pr_nmdirimp => vr_nmdirimp        --> Retornar diretorio da impressao
                               ,pr_nmarqimp => vr_nmarqimp        --> Retorna nome do relatorio
                               ,pr_cdcritic => vr_cdcritic        --> Critica encontrada
                               ,pr_dscritic => vr_dscritic);


    IF nvl(vr_cdcritic,0) > 0 OR
       TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;

    IF vr_idorigem = 5  THEN
      -- Copia PDF do diretorio da cooperativa para servidor WEB
      GENE0002.pc_efetua_copia_pdf(pr_cdcooper => vr_cdcooper
                                  ,pr_cdagenci => vr_cdagenci
                                  ,pr_nrdcaixa => vr_nrdcaixa
                                  ,pr_nmarqpdf => vr_nmdirimp ||'/'||vr_nmarqimp
                                  ,pr_des_reto => vr_des_reto
                                  ,pr_tab_erro => vr_tab_erro);
      -- Se retornou erro
      IF NVL(vr_des_reto,'OK') <> 'OK' THEN
        IF vr_tab_erro.COUNT > 0 THEN -- verifica pl-table se existe erros
          vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic; -- busca primeira critica
          vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic; -- busca primeira descricao da critica
          RAISE vr_exc_erro; -- encerra programa
        END IF;
      END IF;

      -- Remover relatorio do diretorio padrao da cooperativa
      GENE0001.pc_OScommand(pr_typ_comando => 'S'
                           ,pr_des_comando => 'rm '||vr_nmdirimp ||'/'||vr_nmarqimp
                           ,pr_typ_saida   => vr_typsaida
                           ,pr_des_saida   => vr_dscritic);
      -- Se retornou erro
      IF vr_typsaida = 'ERR' OR vr_dscritic IS NOT NULL THEN
        -- Concatena o erro que veio
        vr_dscritic := 'Erro ao remover arquivo: '||vr_dscritic;
        RAISE vr_exc_erro; -- encerra programa
      END IF;
    END IF;

    -- Criar cabeçalho do XML
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');
    gene0007.pc_insere_tag( pr_xml      => pr_retxml,
                            pr_tag_pai  => 'Dados',
                            pr_posicao  => 0,
                            pr_tag_nova => 'nmarqpdf',
                            pr_tag_cont => vr_nmarqimp,
                            pr_des_erro => vr_dscritic);


  EXCEPTION
    WHEN vr_exc_erro THEN
      IF nvl(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      END IF;

      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;

    WHEN OTHERS THEN
      ROLLBACK;
      -- Efetuar retorno do erro não tratado
      pr_cdcritic := 0;
      pr_dscritic := 'Erro ao gerar extrato em relatorio(web): ' ||SQLERRM;

  END pc_extrato_lanc_prej_relat_web;

--

  PROCEDURE pc_extrato_lanc_prej_web(pr_cdcooper          IN crapcop.cdcooper%TYPE   --> Coop conectada
                                    ,pr_nrdconta          IN crapass.nrdconta%TYPE   --> Numero da conta
                                    ,pr_dtiniper          IN VARCHAR2                    --> Data incio do periodo do prejuizo
                                    ,pr_dtfimper          IN VARCHAR2                    --> Data final do periodo do prejuizo
                                    ,pr_xmllog            IN VARCHAR2                --> XML com informacoes de LOG
                                    ,pr_cdcritic          OUT PLS_INTEGER            --> Codigo da critica
                                    ,pr_dscritic          OUT VARCHAR2               --> Descricao da critica
                                    ,pr_retxml         IN OUT NOCOPY xmltype         --> Arquivo de retorno do XML
                                    ,pr_nmdcampo          OUT VARCHAR2               --> Nome do campo com erro
                                    ,pr_des_erro          OUT VARCHAR2) IS           --> Erros do processo
    /* .............................................................................

    Programa: pc_extrato_lanc_prej_web
    Sistema :
    Sigla   : PREJ
    Autor   : Diego Simas - AMcom
    Data    : Julho/2018.                  Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para listar os lançamentos da Conta Transitória (Versao chamada web).

    Alteracoes:

    ..............................................................................*/

    ---->> CURSORES <<-----
    --> Buscar dados do associado
    CURSOR cr_crapass (pr_cdcooper IN crapass.cdcooper%TYPE,
                       pr_nrdconta IN crapass.nrdconta%TYPE)IS
      SELECT ass.nmprimtl
        FROM crapass ass
       WHERE ass.cdcooper = pr_cdcooper
         AND ass.nrdconta = pr_nrdconta;
    rw_crapass cr_crapass%ROWTYPE;

    ---->> VARIAVEIS <<-----
    vr_cdcritic    NUMBER(3);
    vr_dscritic    VARCHAR2(1000);
    vr_des_reto    VARCHAR2(100);
    vr_tab_erro    GENE0001.typ_tab_erro;
    vr_exc_erro    EXCEPTION;

    rw_crapdat     btch0001.cr_crapdat%ROWTYPE;

    vr_dscomand    VARCHAR2(4000);
    vr_typsaida    VARCHAR2(100);
    vr_nmdirimp    VARCHAR2(100);
    vr_nmarqimp    VARCHAR2(100);
    vr_tab_lanctos typ_tab_lanctos;
    -- Variáveis para armazenar as informações em XML
    vr_des_xml         CLOB;
    -- Variável para armazenar os dados do XML antes de incluir no CLOB
    vr_texto_completo  VARCHAR2(32600);
    vr_contador INTEGER := 0;

    -- Variaveis de log
    vr_cdcooper INTEGER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);

    --------------------------- SUBROTINAS INTERNAS --------------------------

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

    pc_retorna_lancamentos_prej(pr_cdcooper    => pr_cdcooper         --> Coop conectada
                               ,pr_nrdconta    => pr_nrdconta         --> Numero da conta
                               ,pr_dtiniper    => to_date(pr_dtiniper, 'DD/MM/YYYY') --> Data incio do periodo do prejuizo
                               ,pr_dtfimper    => to_date(pr_dtfimper, 'DD/MM/YYYY') --> Data final do periodo do prejuizo
                               ,pr_tab_lanctos => vr_tab_lanctos      --> Temp Table
                               ,pr_cdcritic    => vr_cdcritic         --> Critica encontrada
                               ,pr_dscritic    => vr_dscritic);

    IF nvl(vr_cdcritic,0) > 0 OR
       TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;

    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao  => 0, pr_tag_nova => 'lancamentos', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);

    IF vr_tab_lanctos.count > 0 THEN
      FOR idx IN vr_tab_lanctos.first..vr_tab_lanctos.last LOOP

        IF vr_tab_lanctos(idx).tpregistro = 'SD' THEN
          continue;
        END IF;

        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'lancamentos', pr_posicao  => 0, pr_tag_nova => 'lancamento', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'lancamento', pr_posicao  => vr_contador, pr_tag_nova => 'tpregistro', pr_tag_cont => vr_tab_lanctos(idx).tpregistro, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'lancamento', pr_posicao  => vr_contador, pr_tag_nova => 'dsextrato', pr_tag_cont => vr_tab_lanctos(idx).dsextrato, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'lancamento', pr_posicao  => vr_contador, pr_tag_nova => 'dtmvtolt', pr_tag_cont => to_char(vr_tab_lanctos(idx).dtmvtolt,'DD/MM/RR'), pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'lancamento', pr_posicao  => vr_contador, pr_tag_nova => 'nrdocmto', pr_tag_cont => gene0002.fn_mask_contrato(vr_tab_lanctos(idx).nrdocmto), pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'lancamento', pr_posicao  => vr_contador, pr_tag_nova => 'cdhistor', pr_tag_cont => vr_tab_lanctos(idx).cdhistor, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'lancamento', pr_posicao  => vr_contador, pr_tag_nova => 'dshistor', pr_tag_cont => vr_tab_lanctos(idx).dshistor, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'lancamento', pr_posicao  => vr_contador, pr_tag_nova => 'indebcre', pr_tag_cont => vr_tab_lanctos(idx).indebcre, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'lancamento', pr_posicao  => vr_contador, pr_tag_nova => 'vllamnto', pr_tag_cont => to_char(vr_tab_lanctos(idx).vllamnto,'999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS='',.'''), pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'lancamento', pr_posicao  => vr_contador, pr_tag_nova => 'vlslddia', pr_tag_cont => to_char(vr_tab_lanctos(idx).vlslddia,'999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS='',.'''), pr_des_erro => vr_dscritic);
        vr_contador := vr_contador + 1;

      END LOOP;
    END IF;

  EXCEPTION
    WHEN vr_exc_erro THEN
      IF nvl(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      END IF;

      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;

    WHEN OTHERS THEN
      ROLLBACK;
      -- Efetuar retorno do erro não tratado
      pr_cdcritic := 0;
      pr_dscritic := 'Erro ao gerar extrato em relatorio(web): ' ||SQLERRM;

  END pc_extrato_lanc_prej_web;

END PREJ0004;
/
