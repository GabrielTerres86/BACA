CREATE OR REPLACE PACKAGE CECRED.TELA_TITCTO IS
  /*---------------------------------------------------------------------------------------------------------------------
    Programa : TELA_TITCTO
    Sistema  : Ayllos Web
    Autor    : Luis Fernando (GFT)
    Data     : Março - 2018                 Ultima atualizacao: 08/03/2018

    Dados referentes ao programa:

    Objetivo  : Centralizar rotinas relacionadas a tela Acompanhamento do Desconto de Título
  */

  /* Tabela de retorno dos dados obticos na consulta */
  TYPE typ_reg_dados_titcto IS RECORD(
         dtlibbdt craptdb.dtlibbdt%TYPE,
         dtvencto craptdb.dtvencto%TYPE,
         nrborder craptdb.nrborder%TYPE,
         cdbandoc craptdb.cdbandoc%TYPE,
         nrcnvcob craptdb.nrcnvcob%TYPE,
         nrdocmto craptdb.nrdocmto%TYPE,
         vltitulo craptdb.vltitulo%TYPE,
         dtresgat craptdb.dtresgat%TYPE,
         cdoperad crapope.cdoperad%TYPE,
         nmoperad crapope.nmoperad%TYPE,
         dsoperes VARCHAR(300),
         tpcobran VARCHAR(12),
         nrdconta craptdb.nrdconta%TYPE,
         nmprimt  crapass.nmprimtl%TYPE);

  /* Definicao de tabela que compreende os registros acima declarados */
  TYPE typ_tab_dados_titcto IS TABLE OF typ_reg_dados_titcto INDEX BY BINARY_INTEGER;

  /* Tabela de retorno para o resumo do dia */
  TYPE typ_reg_resumo_dia IS RECORD(
         qtcredit INTEGER,
         vlcredit   NUMBER,
         qttitulo INTEGER,
         vltitulo   NUMBER,
         qtderesg INTEGER,
         vlderesg   NUMBER,
         qtdpagto INTEGER,
         vldpagto   NUMBER
  );
  TYPE typ_tab_resumo_dia IS TABLE OF typ_reg_resumo_dia INDEX BY BINARY_INTEGER;

  /* Tabela de retorno para conciliacao contabil */
  TYPE typ_reg_dados_conciliacao IS RECORD(
          dtvencto    DATE,
          qtsldant    INTEGER,
          vlsldant    NUMBER,
          qtderesg    INTEGER,
          vlderesg    NUMBER,
          qtvencid    INTEGER,
          vlvencid    NUMBER,
          qttitulo    INTEGER,
          vltitulo    NUMBER,
          qtcredit    INTEGER,
          vlcredit    NUMBER,
          qtprejui    INTEGER,
          vlprejui    NUMBER,
          qtestorn    INTEGER,
          vlestorn    NUMBER
          
  );
  TYPE typ_tab_dados_conciliacao IS TABLE OF typ_reg_dados_conciliacao INDEX BY BINARY_INTEGER;

  /* Tabela de retorno para dados do loteamento */
  TYPE typ_reg_dados_loteamento IS RECORD(
          dtlibbdt craptdb.dtlibbdt%TYPE,
          cdagenci crapbdt.cdagenci%TYPE,
          cdbccxlt crapbdt.cdbccxlt%TYPE,
          nrdolote crapbdt.nrdolote%TYPE,
          dtvencto craptdb.dtvencto%TYPE,
          cdbandoc craptdb.cdbandoc%TYPE,
          nrcnvcob craptdb.nrcnvcob%TYPE,
          nrdocmto craptdb.nrdocmto%TYPE,
          vltitulo craptdb.vltitulo%TYPE,
          tpcobran VARCHAR2(11)
  );
  TYPE typ_tab_dados_loteamento IS TABLE OF typ_reg_dados_loteamento INDEX BY BINARY_INTEGER;

  /* Tabela de retorno para dados do relatorio de lotes*/
  TYPE typ_reg_dados_lotes IS RECORD(
          dtmvtolt      DATE,
          cdagenci      INTEGER,
          nrdconta      INTEGER,
          nrborder      INTEGER,
          nrdolote      INTEGER,
          qttittot_cr   INTEGER,
          qttittot_sr   INTEGER,
          vltittot_cr   NUMBER,
          vltittot_sr   NUMBER,
          nmoperad      VARCHAR2(100)
  );
  TYPE typ_tab_dados_lotes IS TABLE OF typ_reg_dados_lotes INDEX BY BINARY_INTEGER;

   -- Tipo de registros
  TYPE typ_reg_crapage IS RECORD
    (nmresage crapage.nmresage%TYPE);

  -- Tipo de dados
  TYPE typ_tab_crapage  IS TABLE OF typ_reg_crapage INDEX BY PLS_INTEGER;

  PROCEDURE pc_obtem_dados_titcto (pr_cdcooper    IN crapcop.cdcooper%TYPE, --> Código da Cooperativa
                                    pr_nrdconta    IN crapass.nrdconta%TYPE, --> Número da Conta
                                    pr_tpcobran    IN CHAR,                  --> Filtro de tipo de cobranca
                                    pr_flresgat    IN CHAR,                  --> Filtro de Resgatados
                                    --> out
                                    pr_qtregist         out integer,         --> Quantidade de registros encontrados
                                    pr_tab_dados_titcto   out  typ_tab_dados_titcto, --> Tabela de retorno
                                    pr_cdcritic out number,                         --> codigo da critica
                                    pr_dscritic out varchar2                        --> descricao da critica.
                                );

  PROCEDURE pc_obtem_dados_titcto_web(
                                        pr_nrdconta in  crapass.nrdconta%type --> conta do associado
                                        ,pr_tpcobran    IN CHAR                  --> Filtro de tipo de cobranca
                                        ,pr_flresgat    IN CHAR                  --> Filtro de Resgatados
                                        ,pr_xmllog   IN VARCHAR2           --> XML com informações de LOG
                                        ,pr_cdcritic out pls_integer           --> codigo da critica
                                        ,pr_dscritic out varchar2              --> descricao da critica
                                        ,pr_retxml   in  out nocopy xmltype    --> arquivo de retorno do xml
                                        ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                                        ,pr_des_erro OUT VARCHAR2      --> Erros do processo
                                      );
  PROCEDURE pc_obtem_dados_resumo_dia (
                                        pr_cdcooper    IN crapcop.cdcooper%TYPE, --> Código da Cooperativa
                                        pr_nrdconta    IN crapass.nrdconta%TYPE, --> Número da Conta
                                        pr_tpcobran    IN CHAR,                  --> Filtro de tipo de cobranca
                                        pr_dtvencto    IN VARCHAR2,                  --> Data de vencimento
                                        pr_dtmvtolt    IN VARCHAR2,                  --> Data da movimentacao
                                        --> out
                                        pr_tab_resumo_dia   out  typ_tab_resumo_dia, --> Tabela de retorno
                                        pr_cdcritic out number,                         --> codigo da critica
                                        pr_dscritic out varchar2                        --> descricao da critica.
                                  );

  PROCEDURE pc_obtem_dados_resumo_dia_web(
                                        pr_nrdconta in  crapass.nrdconta%type --> conta do associado
                                        ,pr_tpcobran    IN CHAR                  --> Filtro de tipo de cobranca
                                        ,pr_dtvencto    IN VARCHAR2                  --> Data de vencimento
                                        ,pr_dtmvtolt    IN VARCHAR2                  --> Data da movimentacao
                                        ,pr_xmllog   IN VARCHAR2           --> XML com informações de LOG
                                        ,pr_cdcritic out pls_integer           --> codigo da critica
                                        ,pr_dscritic out varchar2              --> descricao da critica
                                        ,pr_retxml   in  out nocopy xmltype    --> arquivo de retorno do xml
                                        ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                                        ,pr_des_erro OUT VARCHAR2      --> Erros do processo
                                      );

  PROCEDURE pc_obtem_dados_conciliacao(pr_cdcooper IN crapcop.cdcooper%TYPE, --> Código da Cooperativa
                                       pr_tpcobran IN CHAR,                  --> Filtro de tipo de cobranca
                                       pr_dtvencto IN DATE,                  --> Data de vencimento
                                       pr_dtmvtolt IN DATE,                  --> Data da movimentacao
                                    --> out
                                    pr_tab_dados_conciliacao   out  typ_tab_dados_conciliacao, --> Tabela de retorno
                                    pr_cdcritic out number,                         --> codigo da critica
                                    pr_dscritic out varchar2                        --> descricao da critica.
                                );

  PROCEDURE pc_obtem_dados_conciliacao_web(pr_tpcobran    IN CHAR                  --> Filtro de tipo de cobranca
                                        ,pr_dtvencto    IN VARCHAR2                  --> Data de vencimento
                                        ,pr_dtmvtolt    IN VARCHAR2                  --> Data da movimentacao
                                        ,pr_xmllog   IN VARCHAR2           --> XML com informações de LOG
                                        ,pr_cdcritic out pls_integer           --> codigo da critica
                                        ,pr_dscritic out varchar2              --> descricao da critica
                                        ,pr_retxml   in  out nocopy xmltype    --> arquivo de retorno do xml
                                        ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                                        ,pr_des_erro OUT VARCHAR2      --> Erros do processo
                                      );

  PROCEDURE pc_obtem_dados_loteamento (pr_cdcooper    IN crapcop.cdcooper%TYPE, --> Código da Cooperativa
                                    pr_nrdconta    IN crapass.nrdconta%TYPE, --> Número da Conta
                                    pr_tpcobran    IN CHAR,                  --> Filtro de tipo de cobranca
                                    pr_tpdepesq    IN CHAR,                  --> Filtro de Situacao
                                    pr_nrdocmto    IN INTEGER,                  --> Numero do Boleto
                                    pr_vltitulo    IN NUMBER,                   --> Valor do titulo
                                    pr_dtmvtolt    IN VARCHAR2,                  --> Data da movimentacao
                                    --> out
                                    pr_qtregist         out integer,         --> Quantidade de registros encontrados
                                    pr_tab_dados_loteamento out  typ_tab_dados_loteamento, --> Tabela de retorno
                                    pr_cdcritic out number,                         --> codigo da critica
                                    pr_dscritic out varchar2                        --> descricao da critica.
                                );

PROCEDURE pc_obtem_dados_loteamento_web(pr_nrdconta    IN crapass.nrdconta%TYPE --> Número da Conta
                                        ,pr_tpcobran    IN CHAR                  --> Filtro de tipo de cobranca
                                        ,pr_tpdepesq    IN CHAR                  --> Filtro de Situacao
                                        ,pr_nrdocmto    IN INTEGER                  --> Numero do Boleto
                                        ,pr_vltitulo    IN NUMBER                   --> Valor do titulo
                                        ,pr_dtmvtolt    IN VARCHAR2                  --> Data da movimentacao
                                        ,pr_xmllog   IN VARCHAR2           --> XML com informações de LOG
                                        ,pr_cdcritic out pls_integer           --> codigo da critica
                                        ,pr_dscritic out varchar2              --> descricao da critica
                                        ,pr_retxml   in  out nocopy xmltype    --> arquivo de retorno do xml
                                        ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                                        ,pr_des_erro OUT VARCHAR2      --> Erros do processo
                                      );

PROCEDURE pc_obtem_dados_lotes (pr_cdcooper    IN crapcop.cdcooper%TYPE, --> Código da Cooperativa
                                    pr_dtmvtolt    IN VARCHAR2,                  --> Data da movimentacao
                                    pr_cdagenci    IN INTEGER,                   --> Numero do PA
                                    --> out
                                    pr_qtregist    OUT INTEGER,                  -- Quantidade de resultados
                                    pr_tab_dados_lotes   out  typ_tab_dados_lotes, --> Tabela de retorno
                                    pr_cdcritic out number,                         --> codigo da critica
                                    pr_dscritic out varchar2                        --> descricao da critica.
                                );

  PROCEDURE pc_gerar_impressao_titcto_b(pr_dtiniper   IN VARCHAR2              --> Data inicial
                                        ,pr_dtfimper   IN VARCHAR2              --> Data final
                                        ,pr_cdagenci   IN crapass.cdagenci%TYPE --> Numero do PA
                                        ,pr_nrdconta   IN crapass.nrdconta%TYPE --> Numero da Conta
                                        ,pr_nrborder   IN crapbdc.nrborder%TYPE --> Numero do bordero
                                        ,pr_xmllog     IN VARCHAR2              --> XML com informacoes de LOG
                                        ,pr_cdcritic  OUT PLS_INTEGER           --> Codigo da critica
                                        ,pr_dscritic  OUT VARCHAR2              --> Descricao da critica
                                        ,pr_retxml IN OUT NOCOPY xmltype        --> Arquivo de retorno do XML
                                        ,pr_nmdcampo  OUT VARCHAR2              --> Nome do campo com erro
                                        ,pr_des_erro  OUT VARCHAR2);

PROCEDURE pc_gerar_impressao_titcto_c(
                                        pr_nrdconta in  crapass.nrdconta%type --> conta do associado
                                        ,pr_tpcobran    IN CHAR                  --> Filtro de tipo de cobranca
                                        ,pr_flresgat    IN CHAR                  --> Filtro de Resgatados
                                        ,pr_dtmvtolt IN VARCHAR2
                                        ,pr_xmllog   IN VARCHAR2           --> XML com informações de LOG
                                        ,pr_cdcritic out pls_integer           --> codigo da critica
                                        ,pr_dscritic out varchar2              --> descricao da critica
                                        ,pr_retxml   in  out nocopy xmltype    --> arquivo de retorno do xml
                                        ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                                        ,pr_des_erro OUT VARCHAR2      --> Erros do processo
                                      );


  PROCEDURE pc_gerar_impressao_titcto_l(pr_dtmvtolt IN VARCHAR2
                                        ,pr_cdagenci IN INTEGER                   --> Numero do PA
                                        ,pr_xmllog   IN VARCHAR2           --> XML com informações de LOG
                                        ,pr_cdcritic out pls_integer           --> codigo da critica
                                        ,pr_dscritic out varchar2              --> descricao da critica
                                        ,pr_retxml   in  out nocopy xmltype    --> arquivo de retorno do xml
                                        ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                                        ,pr_des_erro OUT VARCHAR2      --> Erros do processo
                                      );
                                      
                                      
   PROCEDURE pc_consulta_pagador_remetente (pr_cdcooper    IN crapcop.cdcooper%TYPE, --> Código da Cooperativa
                                    pr_nrdconta    IN crapass.nrdconta%TYPE, --> Número da Conta
                                    pr_tpcobran    IN CHAR,                  --> Filtro de tipo de cobranca
                                    --> out
                                    pr_qtregist         out integer,         --> Quantidade de registros encontrados
                                    pr_tab_dados_titcto   out  typ_tab_dados_titcto, --> Tabela de retorno
                                    pr_cdcritic out number,                         --> codigo da critica
                                    pr_dscritic out varchar2                        --> descricao da critica.                    
                                );
                                
  PROCEDURE pc_consulta_pag_remetente_web(
                                        pr_nrdconta in  crapass.nrdconta%type --> conta do associado
                                        ,pr_tpcobran    IN CHAR                  --> Filtro de tipo de cobranca
                                        ,pr_xmllog   IN VARCHAR2           --> XML com informações de LOG
                                        ,pr_cdcritic out pls_integer           --> codigo da critica
                                        ,pr_dscritic out varchar2              --> descricao da critica
                                        ,pr_retxml   in  out nocopy xmltype    --> arquivo de retorno do xml
                                        ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                                        ,pr_des_erro OUT VARCHAR2      --> Erros do processo
                                      );                                   


END TELA_TITCTO;
/
CREATE OR REPLACE PACKAGE BODY CECRED.TELA_TITCTO IS

  /*---------------------------------------------------------------------------------------------------------------------
    Programa : TELA_TITCTO
    Sistema  : Ayllos Web
    Autor    : Luis Fernando (GFT)
    Data     : Março - 2018                 Ultima atualizacao: 08/03/2018

    Dados referentes ao programa:

    Objetivo  : Centralizar rotinas relacionadas a tela Acompanhamento do Desconto de Título

    Alteração : 22/10/2018 - Adicionado a procedure pc_obtem_dados_conciliacao_tit para gerar conciliação contábil com informações 
                             de lançamento dos borderôs da nova carteira de desconto de titulo. (Paulo Penteado GFT)
  */
  /* tratamento de erro */
  vr_exc_erro exception;

  /* descriçao e código da critica */
  vr_cdcritic crapcri.cdcritic%type;
  vr_dscritic varchar2(4000);

  PROCEDURE pc_obtem_dados_titcto (pr_cdcooper    IN crapcop.cdcooper%TYPE, --> Código da Cooperativa
                                    pr_nrdconta    IN crapass.nrdconta%TYPE, --> Número da Conta
                                    pr_tpcobran    IN CHAR,                  --> Filtro de tipo de cobranca
                                    pr_flresgat    IN CHAR,                  --> Filtro de Resgatados
                                    --> out
                                    pr_qtregist         out integer,         --> Quantidade de registros encontrados
                                    pr_tab_dados_titcto   out  typ_tab_dados_titcto, --> Tabela de retorno
                                    pr_cdcritic out number,                         --> codigo da critica
                                    pr_dscritic out varchar2                        --> descricao da critica.
                                ) is

    ----------------------------------------------------------------------------------
    --
    -- Procedure: pc_obtem_dados_titcto
    -- Sistema  : CRED
    -- Sigla    : TELA_TITCTO
    -- Autor    : Luis Fernando - Company: GFT
    -- Data     : Criação: 08/03/2018
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: Sempre que chamado
    -- Objetivo  : Trazer os acompanhamentos dos descontos de titulo
    ----------------------------------------------------------------------------------
    BEGIN
      DECLARE

       vr_idtabtitcto PLS_INTEGER;
       aux_flregis INTEGER;

       CURSOR cr_craptdb IS
          SELECT
             craptdb.dtlibbdt AS dtlibbdt,
             craptdb.dtvencto AS dtvencto,
             craptdb.nrborder AS nrborder,
             craptdb.cdbandoc AS cdbandoc,
             craptdb.nrcnvcob AS nrcnvcob,
             craptdb.nrdocmto AS nrdocmto,
             craptdb.vltitulo AS vltitulo,
             craptdb.dtresgat AS dtresgat,
             crapope.cdoperad AS cdoperad,
             crapope.nmoperad AS nmoperad,
             crapcob.flgregis AS flgregis,
             craptdb.nrdconta AS nrdconta,
             crapass.nmprimtl AS nmprimtl
          FROM
             craptdb
             INNER JOIN crapcob ON crapcob.cdcooper = craptdb.cdcooper AND
                                                    crapcob.cdbandoc = craptdb.cdbandoc AND
                                                    crapcob.nrdctabb = craptdb.nrdctabb AND
                                                    crapcob.nrdconta = craptdb.nrdconta AND
                                                    crapcob.nrcnvcob = craptdb.nrcnvcob AND
                                                    crapcob.nrdocmto = craptdb.nrdocmto  AND
                                                    (pr_tpcobran='T' OR crapcob.flgregis=aux_flregis)
             LEFT JOIN crapope ON crapope.cdcooper = craptdb.cdcooper AND crapope.cdoperad = craptdb.cdoperes
             LEFT JOIN crapass ON crapass.cdcooper = craptdb.cdcooper AND crapass.nrdconta = craptdb.nrdconta
          WHERE
             (craptdb.cdcooper = pr_cdcooper AND craptdb.nrdconta = pr_nrdconta)
             AND (
                     craptdb.insittit = 4
                     OR (craptdb.insittit = 1 AND pr_flresgat='S') -- RESGATADOS
                 )
          ORDER BY crapcob.flgregis DESC, crapcob.cdbandoc DESC, crapcob.nrdconta ASC ;
          rw_craptdb cr_craptdb%ROWTYPE;

    BEGIN
      -- Incluir nome do modulo logado
        GENE0001.pc_informa_acesso(pr_module => 'TELA_TITCTO'
                              ,pr_action => NULL);

      -- Começa a listagem da tabela
         pr_qtregist:= 0;
         IF (pr_tpcobran='S') THEN
           aux_flregis := 0;
         ELSE
           IF (pr_tpcobran='R') THEN
              aux_flregis := 1;
           ELSE
              aux_flregis := NULL;
           END IF;
         END IF;

         OPEN  cr_craptdb;
         LOOP
               FETCH cr_craptdb INTO rw_craptdb;
               EXIT  WHEN cr_craptdb%NOTFOUND;
               pr_qtregist := pr_qtregist+1;
               vr_idtabtitcto := pr_tab_dados_titcto.count + 1;
               pr_tab_dados_titcto(vr_idtabtitcto).dtlibbdt := rw_craptdb.dtlibbdt;
               pr_tab_dados_titcto(vr_idtabtitcto).dtvencto := rw_craptdb.dtvencto;
               pr_tab_dados_titcto(vr_idtabtitcto).nrborder := rw_craptdb.nrborder;
               pr_tab_dados_titcto(vr_idtabtitcto).cdbandoc := rw_craptdb.cdbandoc;
               pr_tab_dados_titcto(vr_idtabtitcto).nrcnvcob := rw_craptdb.nrcnvcob;
               pr_tab_dados_titcto(vr_idtabtitcto).nrdocmto := rw_craptdb.nrdocmto;
               pr_tab_dados_titcto(vr_idtabtitcto).vltitulo := rw_craptdb.vltitulo;
               pr_tab_dados_titcto(vr_idtabtitcto).dtresgat := rw_craptdb.dtresgat;
               pr_tab_dados_titcto(vr_idtabtitcto).cdoperad := rw_craptdb.cdoperad;
               pr_tab_dados_titcto(vr_idtabtitcto).nmoperad := rw_craptdb.nmoperad;
               IF (rw_craptdb.cdoperad IS NOT NULL) THEN
                  pr_tab_dados_titcto(vr_idtabtitcto).dsoperes := rw_craptdb.cdoperad || ' - ' ||rw_craptdb.nmoperad;
               ELSE
                 pr_tab_dados_titcto(vr_idtabtitcto).dsoperes := '';
               END IF;
               CASE WHEN (rw_craptdb.flgregis = 1  AND rw_craptdb.cdbandoc = 085) THEN
                         pr_tab_dados_titcto(vr_idtabtitcto).tpcobran := 'Coop. Emite';
                    WHEN (rw_craptdb.flgregis = 1  AND rw_craptdb.cdbandoc <> 085) THEN
                         pr_tab_dados_titcto(vr_idtabtitcto).tpcobran := 'Banco Emite';
                    WHEN (rw_craptdb.flgregis = 0) THEN
                         pr_tab_dados_titcto(vr_idtabtitcto).tpcobran := 'S/registro';
                    ELSE
                         pr_tab_dados_titcto(vr_idtabtitcto).tpcobran := ' ';
               END CASE;
               pr_tab_dados_titcto(vr_idtabtitcto).nrdconta := rw_craptdb.nrdconta;
               pr_tab_dados_titcto(vr_idtabtitcto).nmprimt  := rw_craptdb.nmprimtl;
         end   loop;

    END;
    EXCEPTION
      WHEN OTHERS THEN
           /* montar descriçao de erro nao tratado */
           pr_dscritic := 'erro nao tratado na TELA_TITCTO.pc_obtem_dados_titcto ' ||sqlerrm;
  END pc_obtem_dados_titcto;


  PROCEDURE pc_obtem_dados_titcto_web(
                                        pr_nrdconta in  crapass.nrdconta%type --> conta do associado
                                        ,pr_tpcobran    IN CHAR                  --> Filtro de tipo de cobranca
                                        ,pr_flresgat    IN CHAR                  --> Filtro de Resgatados
                                        ,pr_xmllog   IN VARCHAR2           --> XML com informações de LOG
                                        ,pr_cdcritic out pls_integer           --> codigo da critica
                                        ,pr_dscritic out varchar2              --> descricao da critica
                                        ,pr_retxml   in  out nocopy xmltype    --> arquivo de retorno do xml
                                        ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                                        ,pr_des_erro OUT VARCHAR2      --> Erros do processo
                                      ) is
    -- variaveis de retorno
    vr_tab_dados_titcto typ_tab_dados_titcto;

    vr_tab_erro         gene0001.typ_tab_erro;
    vr_qtregist         number;
    vr_des_reto varchar2(3);

    -- variaveis de entrada vindas no xml
    vr_cdcooper integer;
    vr_cdoperad varchar2(100);
    vr_nmdatela varchar2(100);
    vr_nmeacao  varchar2(100);
    vr_cdagenci varchar2(100);
    vr_nrdcaixa varchar2(100);
    vr_idorigem varchar2(100);

    -- variáveis para armazenar as informaçoes em xml
    vr_des_xml        clob;
    vr_texto_completo varchar2(32600);
    vr_index          PLS_INTEGER;

    procedure pc_escreve_xml( pr_des_dados in varchar2
                            , pr_fecha_xml in boolean default false
                            ) is
    begin
        gene0002.pc_escreve_xml( vr_des_xml
                               , vr_texto_completo
                               , pr_des_dados
                               , pr_fecha_xml );
    end;

    begin
      gene0004.pc_extrai_dados( pr_xml      => pr_retxml
                              , pr_cdcooper => vr_cdcooper
                              , pr_nmdatela => vr_nmdatela
                              , pr_nmeacao  => vr_nmeacao
                              , pr_cdagenci => vr_cdagenci
                              , pr_nrdcaixa => vr_nrdcaixa
                              , pr_idorigem => vr_idorigem
                              , pr_cdoperad => vr_cdoperad
                              , pr_dscritic => vr_dscritic);


      pc_obtem_dados_titcto( vr_cdcooper,
                                        pr_nrdconta,
                                        pr_tpcobran,
                                        pr_flresgat,
                                        --> out
                                        vr_qtregist,
                                        vr_tab_dados_titcto,
                                        pr_cdcritic,
                                        pr_dscritic
                               );

      if  vr_des_reto = 'NOK' then
          if  vr_tab_erro.exists(vr_tab_erro.first) then
              vr_dscritic := vr_tab_erro(vr_tab_erro.first).dscritic;
              vr_cdcritic := vr_tab_erro(vr_tab_erro.first).cdcritic;
          else
              vr_dscritic := 'nao foi possivel obter dados de titcto.';
          end if;
          raise vr_exc_erro;
      end if;

      -- inicializar o clob
      vr_des_xml := null;
      dbms_lob.createtemporary(vr_des_xml, true);
      dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
      -- inicilizar as informaçoes do xml
      vr_texto_completo := null;

      pc_escreve_xml('<?xml version="1.0" encoding="iso-8859-1" ?>'||
                     '<root><dados qtregist="' || vr_qtregist ||'" >');

      -- ler os registros de titcto e incluir no xml
      vr_index := vr_tab_dados_titcto.first;
      while vr_index is not null loop
            pc_escreve_xml('<inf>'||
                             '<dtlibbdt>' || to_char(vr_tab_dados_titcto(vr_index).dtlibbdt,'dd/mm/rrrr') || '</dtlibbdt>' ||
                             '<dtvencto>' || to_char(vr_tab_dados_titcto(vr_index).dtvencto,'dd/mm/rrrr') || '</dtvencto>' ||
                             '<nrborder>' || vr_tab_dados_titcto(vr_index).nrborder || '</nrborder>' ||
                             '<cdbandoc>' || vr_tab_dados_titcto(vr_index).cdbandoc || '</cdbandoc>' ||
                             '<nrcnvcob>' || vr_tab_dados_titcto(vr_index).nrcnvcob || '</nrcnvcob>' ||
                             '<nrdocmto>' || vr_tab_dados_titcto(vr_index).nrdocmto || '</nrdocmto>' ||
                             '<vltitulo>' || vr_tab_dados_titcto(vr_index).vltitulo || '</vltitulo>' ||
                             '<dtresgat>' || to_char(vr_tab_dados_titcto(vr_index).dtresgat,'dd/mm/rrrr') || '</dtresgat>' ||
                             '<cdoperad>' || vr_tab_dados_titcto(vr_index).cdoperad || '</cdoperad>' ||
                             '<nmoperad>' || vr_tab_dados_titcto(vr_index).nmoperad || '</nmoperad>' ||
                             '<dsoperes>' || vr_tab_dados_titcto(vr_index).dsoperes || '</dsoperes>' ||
                             '<tpcobran>' || vr_tab_dados_titcto(vr_index).tpcobran || '</tpcobran>' ||
                             '<nrdconta>' || TRIM(gene0002.fn_mask(vr_tab_dados_titcto(vr_index).nrdconta,'zzzz.zzz.z'))   || '</nrdconta>' ||
                             '<nmprimt>'  || vr_tab_dados_titcto(vr_index).nmprimt  || '</nmprimt>'  ||
                           '</inf>'
                          );
          /* buscar proximo */
          vr_index := vr_tab_dados_titcto.next(vr_index);
      end loop;
      pc_escreve_xml ('</dados></root>',true);
      pr_retxml := xmltype.createxml(vr_des_xml);

      /* liberando a memória alocada pro clob */
      dbms_lob.close(vr_des_xml);
      dbms_lob.freetemporary(vr_des_xml);
    exception
      when vr_exc_erro then
           /*  se foi retornado apenas código */
           if  nvl(vr_cdcritic,0) > 0 and vr_dscritic is null then
               /* buscar a descriçao */
               vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
           end if;
           /* variavel de erro recebe erro ocorrido */
           pr_cdcritic := nvl(vr_cdcritic,0);
           pr_dscritic := vr_dscritic;
      when others then
           /* montar descriçao de erro nao tratado */
           pr_dscritic := 'erro nao tratado na tela_titcto.pc_obtem_dados_titcto_web ' ||sqlerrm;
  END pc_obtem_dados_titcto_web;


  PROCEDURE pc_obtem_dados_resumo_dia (pr_cdcooper    IN crapcop.cdcooper%TYPE, --> Código da Cooperativa
                                    pr_nrdconta    IN crapass.nrdconta%TYPE, --> Número da Conta
                                    pr_tpcobran    IN CHAR,                  --> Filtro de tipo de cobranca
                                    pr_dtvencto    IN VARCHAR2,                  --> Data de vencimento
                                    pr_dtmvtolt    IN VARCHAR2,                  --> Data da movimentacao
                                    --> out
                                    pr_tab_resumo_dia   out  typ_tab_resumo_dia, --> Tabela de retorno
                                    pr_cdcritic out number,                         --> codigo da critica
                                    pr_dscritic out varchar2                        --> descricao da critica.
                                ) is

    ----------------------------------------------------------------------------------
    --
    -- Procedure: pc_obtem_dados_resumo_dia
    -- Sistema  : CRED
    -- Sigla    : TELA_TITCTO
    -- Autor    : Luis Fernando - Company: GFT
    -- Data     : Criação: 12/03/2018
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: Sempre que chamado
    -- Objetivo  : Trazer o resumo do dia das operacoes de desconto de titulo
    ----------------------------------------------------------------------------------
    BEGIN
      DECLARE

       vr_idtabtitcto INTEGER;
       aux_flregis INTEGER;
       vr_dtperant DATE;
       vr_dtvencto DATE;
       vr_dtmvtolt DATE;
       -- Verifica Conta (Cadastro de associados)
       CURSOR cr_crapass IS
         select nmprimtl
               ,inpessoa
               ,nrdconta
         from   crapass
         where
                crapass.cdcooper = pr_cdcooper
                AND crapass.nrdconta = pr_nrdconta;
       rw_crapass cr_crapass%rowtype;

       CURSOR cr_craptdb IS
        SELECT
          craptdb.insittit,
          craptdb.vltitulo
        FROM
          craptdb
          INNER JOIN crapcob ON crapcob.cdcooper = craptdb.cdcooper AND
                                                   crapcob.cdbandoc = craptdb.cdbandoc AND
                                                   crapcob.nrdctabb = craptdb.nrdctabb AND
                                                   crapcob.nrdconta = craptdb.nrdconta AND
                                                   crapcob.nrcnvcob = craptdb.nrcnvcob AND
                                                   crapcob.nrdocmto = craptdb.nrdocmto AND
                                                   (pr_tpcobran='T' OR crapcob.flgregis=aux_flregis)
        WHERE
          craptdb.cdcooper = pr_cdcooper
          AND ((craptdb.nrdconta = pr_nrdconta AND pr_nrdconta>0) OR (pr_nrdconta IS NULL OR pr_nrdconta=0)) -- se possui conta ou nao
          AND (
                (vr_dtvencto IS NOT NULL AND craptdb.dtvencto > (vr_dtperant) AND craptdb.dtvencto <= vr_dtvencto)
                 OR (craptdb.dtvencto  > vr_dtmvtolt AND vr_dtvencto IS NULL)
              )
          AND craptdb.dtlibbdt IS NOT NULL;
          rw_craptdb cr_craptdb%ROWTYPE;

       -- Variaveis de retorno
         vr_qtcredit  INTEGER;
         vr_vlcredit  NUMBER;
         vr_qttitulo  INTEGER;
         vr_vltitulo  NUMBER;
         vr_qtderesg  INTEGER;
         vr_vlderesg  NUMBER;
         vr_qtdpagto  INTEGER;
         vr_vldpagto  NUMBER;


    BEGIN
      -- Carrega dia anterior ao vencimento
      IF (pr_dtmvtolt IS NOT NULL ) THEN
        vr_dtmvtolt:=to_date(pr_dtmvtolt, 'DD/MM/RRRR');
      ELSE
        vr_dtmvtolt:=NULL;
      END IF;

      IF (pr_dtvencto IS NOT NULL ) THEN
         vr_dtvencto := to_date(pr_dtvencto, 'DD/MM/RRRR');
         vr_dtperant := gene0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper
                                             ,pr_dtmvtolt => vr_dtvencto-1
                                             ,pr_tipo     => 'A' );
      ELSE
        vr_dtvencto := NULL;
        vr_dtperant := NULL;
      END IF;
      -- Incluir nome do modulo logado
        GENE0001.pc_informa_acesso(pr_module => 'TELA_TITCTO'
                              ,pr_action => NULL);

      -- Começa a listagem da tabela
         vr_qtcredit := 0;
         vr_vlcredit := 0;
         vr_qttitulo := 0;
         vr_vltitulo := 0;
         vr_qtderesg := 0;
         vr_vlderesg := 0;
         vr_qtdpagto := 0;
         vr_vldpagto := 0;

         IF (pr_tpcobran='S') THEN
           aux_flregis := 0;
         ELSE
           IF (pr_tpcobran='R') THEN
              aux_flregis := 1;
           ELSE
              aux_flregis := NULL;
           END IF;
         END IF;

         OPEN cr_crapass;

         OPEN  cr_craptdb;
         LOOP
               FETCH cr_craptdb INTO rw_craptdb;
               EXIT  WHEN cr_craptdb%NOTFOUND;
                  vr_qttitulo := vr_qttitulo+1;
                  vr_vltitulo := vr_vltitulo + rw_craptdb.vltitulo;
                  IF (rw_craptdb.insittit=1) THEN
                    vr_qtderesg := vr_qtderesg + 1;
                    vr_vlderesg := vr_vlderesg + rw_craptdb.vltitulo;
                  END IF;
                  IF (rw_craptdb.insittit=2 OR rw_craptdb.insittit=3) THEN
                    vr_qtdpagto := vr_qtdpagto + 1;
                    vr_vldpagto := vr_vldpagto + rw_craptdb.vltitulo;
                  END IF;
         end   loop;

         vr_qtcredit := vr_qttitulo - vr_qtderesg - vr_qtdpagto;
         vr_vlcredit := vr_vltitulo - vr_vlderesg - vr_vldpagto;
         pr_tab_resumo_dia(0).qtcredit := vr_qtcredit;
         pr_tab_resumo_dia(0).vlcredit := vr_vlcredit;
         pr_tab_resumo_dia(0).qttitulo := vr_qttitulo;
         pr_tab_resumo_dia(0).vltitulo := vr_vltitulo;
         pr_tab_resumo_dia(0).qtderesg := vr_qtderesg;
         pr_tab_resumo_dia(0).vlderesg := vr_vlderesg;
         pr_tab_resumo_dia(0).qtdpagto := vr_qtdpagto;
         pr_tab_resumo_dia(0).vldpagto := vr_vldpagto;

    END;
    EXCEPTION
      WHEN OTHERS THEN
           /* montar descriçao de erro nao tratado */
           pr_dscritic := 'erro nao tratado na TELA_TITCTO.pc_obtem_dados_resumo_dia ' ||sqlerrm;
  END pc_obtem_dados_resumo_dia;

  PROCEDURE pc_obtem_dados_resumo_dia_web(
                                        pr_nrdconta in  crapass.nrdconta%type --> conta do associado
                                        ,pr_tpcobran    IN CHAR                  --> Filtro de tipo de cobranca
                                        ,pr_dtvencto    IN VARCHAR2                  --> Data de vencimento
                                        ,pr_dtmvtolt    IN VARCHAR2                  --> Data da movimentacao
                                        ,pr_xmllog   IN VARCHAR2           --> XML com informações de LOG
                                        ,pr_cdcritic out pls_integer           --> codigo da critica
                                        ,pr_dscritic out varchar2              --> descricao da critica
                                        ,pr_retxml   in  out nocopy xmltype    --> arquivo de retorno do xml
                                        ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                                        ,pr_des_erro OUT VARCHAR2      --> Erros do processo
                                      ) is
    -- variaveis de retorno
    vr_tab_resumo_dia typ_tab_resumo_dia;

    vr_tab_erro         gene0001.typ_tab_erro;
    vr_qtregist         number;

    -- variaveis de entrada vindas no xml
    vr_cdcooper integer;
    vr_cdoperad varchar2(100);
    vr_nmdatela varchar2(100);
    vr_nmeacao  varchar2(100);
    vr_cdagenci varchar2(100);
    vr_nrdcaixa varchar2(100);
    vr_idorigem varchar2(100);

    -- variáveis para armazenar as informaçoes em xml
    vr_des_xml        clob;
    vr_texto_completo varchar2(32600);
    vr_index          PLS_INTEGER;

    procedure pc_escreve_xml( pr_des_dados in varchar2
                            , pr_fecha_xml in boolean default false
                            ) is
    begin
        gene0002.pc_escreve_xml( vr_des_xml
                               , vr_texto_completo
                               , pr_des_dados
                               , pr_fecha_xml );
    end;

    begin
      gene0004.pc_extrai_dados( pr_xml      => pr_retxml
                              , pr_cdcooper => vr_cdcooper
                              , pr_nmdatela => vr_nmdatela
                              , pr_nmeacao  => vr_nmeacao
                              , pr_cdagenci => vr_cdagenci
                              , pr_nrdcaixa => vr_nrdcaixa
                              , pr_idorigem => vr_idorigem
                              , pr_cdoperad => vr_cdoperad
                              , pr_dscritic => vr_dscritic);


      pc_obtem_dados_resumo_dia( vr_cdcooper,
                                        pr_nrdconta,
                                        pr_tpcobran,
                                        pr_dtvencto,
                                        pr_dtmvtolt,
                                        --> out
                                        vr_tab_resumo_dia,
                                        pr_cdcritic,
                                        pr_dscritic
                               );


      -- inicializar o clob
      vr_des_xml := null;
      dbms_lob.createtemporary(vr_des_xml, true);
      dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
      -- inicilizar as informaçoes do xml
      vr_texto_completo := null;

      pc_escreve_xml('<?xml version="1.0" encoding="iso-8859-1" ?>'||
                     '<root><dados >');

      -- ler os registros de titcto e incluir no xml
      vr_index := vr_tab_resumo_dia.first;
      while vr_index is not null loop
            pc_escreve_xml('<inf>'||
                             '<qtcredit>' || vr_tab_resumo_dia(vr_index).qtcredit || '</qtcredit>' ||
                             '<vlcredit>' || vr_tab_resumo_dia(vr_index).vlcredit || '</vlcredit>' ||
                             '<qttitulo>' || vr_tab_resumo_dia(vr_index).qttitulo || '</qttitulo>' ||
                             '<vltitulo>' || vr_tab_resumo_dia(vr_index).vltitulo || '</vltitulo>' ||
                             '<qtderesg>' || vr_tab_resumo_dia(vr_index).qtderesg || '</qtderesg>' ||
                             '<vlderesg>' || vr_tab_resumo_dia(vr_index).vlderesg || '</vlderesg>' ||
                             '<qtdpagto>' || vr_tab_resumo_dia(vr_index).qtdpagto || '</qtdpagto>' ||
                             '<vldpagto>' || vr_tab_resumo_dia(vr_index).vldpagto || '</vldpagto>' ||
                           '</inf>'
                          );
          /* buscar proximo */
          vr_index := vr_tab_resumo_dia.next(vr_index);
      end loop;
      pc_escreve_xml ('</dados></root>',true);
      pr_retxml := xmltype.createxml(vr_des_xml);

      /* liberando a memória alocada pro clob */
      dbms_lob.close(vr_des_xml);
      dbms_lob.freetemporary(vr_des_xml);
    exception
      when vr_exc_erro then
           /*  se foi retornado apenas código */
           if  nvl(vr_cdcritic,0) > 0 and vr_dscritic is null then
               /* buscar a descriçao */
               vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
           end if;
           /* variavel de erro recebe erro ocorrido */
           pr_cdcritic := nvl(vr_cdcritic,0);
           pr_dscritic := vr_dscritic;
      when others then
           /* montar descriçao de erro nao tratado */
           pr_dscritic := 'erro nao tratado na tela_titcto.pc_obtem_dados_resumo_dia_web ' ||sqlerrm;
  END pc_obtem_dados_resumo_dia_web;

  PROCEDURE pc_obtem_dados_conciliacao(pr_cdcooper IN crapcop.cdcooper%TYPE, --> Código da Cooperativa
                                       pr_tpcobran IN CHAR,                  --> Filtro de tipo de cobranca
                                       pr_dtvencto IN DATE,                  --> Data de vencimento
                                       pr_dtmvtolt IN DATE,                  --> Data da movimentacao
                                    --> out
                                    pr_tab_dados_conciliacao   out  typ_tab_dados_conciliacao, --> Tabela de retorno
                                    pr_cdcritic out number,                         --> codigo da critica
                                    pr_dscritic out varchar2                        --> descricao da critica.
                                ) is

    ----------------------------------------------------------------------------------
    --
    -- Procedure: pc_obtem_dados_conciliacao
    -- Sistema  : CRED
    -- Sigla    : TELA_TITCTO
    -- Autor    : Luis Fernando - Company: GFT
    -- Data     : Criação: 13/03/2018
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: Sempre que chamado
    -- Objetivo  : Trazer o saldo para conciliacao bancaria
    ----------------------------------------------------------------------------------
    BEGIN
      DECLARE
       vr_idtabtitcto INTEGER;
       aux_flregis INTEGER;
       vr_dtvencto DATE;
       vr_dtmvtolt DATE;
       vr_dtmvtoan DATE;
       vr_dtrefere DATE;
       tmp_dtrefere DATE;
       tmp_utilante DATE;
       tmp_dtvencto DATE;
       tmp_diffdias INTEGER;

       /* Resgatados no dia */
       CURSOR cr_resgatados IS
         SELECT
              craptdb.insittit,
              craptdb.vltitulo
         FROM
              craptdb
              INNER JOIN crapbdt  ON crapbdt.cdcooper = craptdb.cdcooper AND crapbdt.nrborder = craptdb.nrborder
              INNER JOIN crapcob  ON crapcob.cdcooper = craptdb.cdcooper AND
                                                   crapcob.cdbandoc = craptdb.cdbandoc AND
                                                   crapcob.nrdctabb = craptdb.nrdctabb AND
                                                   crapcob.nrdconta = craptdb.nrdconta AND
                                                   crapcob.nrcnvcob = craptdb.nrcnvcob AND
                                                   crapcob.nrdocmto = craptdb.nrdocmto AND
                                                   (pr_tpcobran='T' OR crapcob.flgregis=aux_flregis)
         WHERE
             craptdb.cdcooper = pr_cdcooper
             AND craptdb.insittit = 1
             AND craptdb.dtresgat = pr_dtvencto
             AND crapbdt.flverbor = 0
         ;
       rw_resgatados cr_resgatados%ROWTYPE;

       /*Baixados sem pagamento no dia*/
       CURSOR cr_baixados_sem_pagamento IS
         SELECT
              craptdb.insittit,
              craptdb.vltitulo,
              craptdb.dtvencto
         FROM
              craptdb
              INNER JOIN crapbdt  ON crapbdt.cdcooper = craptdb.cdcooper AND crapbdt.nrborder = craptdb.nrborder
              INNER JOIN crapcob  ON crapcob.cdcooper = craptdb.cdcooper AND
                                                   crapcob.cdbandoc = craptdb.cdbandoc AND
                                                   crapcob.nrdctabb = craptdb.nrdctabb AND
                                                   crapcob.nrdconta = craptdb.nrdconta AND
                                                   crapcob.nrcnvcob = craptdb.nrcnvcob AND
                                                   crapcob.nrdocmto = craptdb.nrdocmto AND
                                                   (pr_tpcobran='T' OR crapcob.flgregis=aux_flregis)
         WHERE
             craptdb.cdcooper = pr_cdcooper
             AND craptdb.insittit = 3
             AND craptdb.dtdebito = pr_dtvencto
             AND crapbdt.flverbor = 0;
       rw_baixados_sem_pagamento cr_baixados_sem_pagamento%ROWTYPE;

       /* Pagos pelo Pagador - via COMPE... */
       CURSOR cr_pagos_compe IS
         SELECT
              craptdb.vltitulo
         FROM
              craptdb
              INNER JOIN crapbdt  ON crapbdt.cdcooper = craptdb.cdcooper AND crapbdt.nrborder = craptdb.nrborder
              INNER JOIN crapcob  ON crapcob.cdcooper = craptdb.cdcooper AND
                                                   crapcob.cdbandoc = craptdb.cdbandoc AND
                                                   crapcob.nrdctabb = craptdb.nrdctabb AND
                                                   crapcob.nrdconta = craptdb.nrdconta AND
                                                   crapcob.nrcnvcob = craptdb.nrcnvcob AND
                                                   crapcob.nrdocmto = craptdb.nrdocmto AND
                                                   (pr_tpcobran='T' OR crapcob.flgregis=aux_flregis)
         WHERE
              craptdb.cdcooper  = pr_cdcooper
              AND craptdb.dtdpagto  > vr_dtrefere
              AND craptdb.dtdpagto <= vr_dtmvtoan
              AND craptdb.insittit  = 2
              /*Apenas BB*/
              AND crapcob.indpagto = 0
              AND crapcob.cdbandoc = 001
              AND crapbdt.flverbor = 0
         ;
       rw_pagos_compe cr_pagos_compe%ROWTYPE;

       /* Pagos pelo Pagador - via CAIXA... */
       CURSOR cr_pagos_caixa IS
         SELECT
              craptdb.vltitulo
         FROM
              craptdb
              INNER JOIN crapbdt  ON crapbdt.cdcooper = craptdb.cdcooper AND crapbdt.nrborder = craptdb.nrborder
              INNER JOIN crapcob  ON crapcob.cdcooper = craptdb.cdcooper AND
                                                   crapcob.cdbandoc = craptdb.cdbandoc AND
                                                   crapcob.nrdctabb = craptdb.nrdctabb AND
                                                   crapcob.nrdconta = craptdb.nrdconta AND
                                                   crapcob.nrcnvcob = craptdb.nrcnvcob AND
                                                   crapcob.nrdocmto = craptdb.nrdocmto AND
                                                   (pr_tpcobran='T' OR crapcob.flgregis=aux_flregis)
         WHERE
              craptdb.cdcooper  = pr_cdcooper
              AND craptdb.dtdpagto  > vr_dtmvtoan
              AND craptdb.dtdpagto <= pr_dtvencto
              AND craptdb.insittit  = 2
              /* Pago pelo CAIXA, InternetBank ou TAA, e compe 085 */
              AND (
                crapcob.indpagto = 1
                OR crapcob.indpagto = 3
                OR crapcob.indpagto = 4 /**TAA**/
                OR (crapcob.indpagto = 0 AND crapcob.cdbandoc = 085)
              )
             AND crapbdt.flverbor = 0
         ;
       rw_pagos_caixa cr_pagos_caixa%ROWTYPE;

       /* Recebidos no dia */
       CURSOR cr_recebidos_dia IS
         SELECT
              craptdb.vltitulo
         FROM
              craptdb
              INNER JOIN crapbdt  ON crapbdt.cdcooper = craptdb.cdcooper AND crapbdt.nrborder = craptdb.nrborder
              INNER JOIN crapcob  ON crapcob.cdcooper = craptdb.cdcooper AND
                                                   crapcob.cdbandoc = craptdb.cdbandoc AND
                                                   crapcob.nrdctabb = craptdb.nrdctabb AND
                                                   crapcob.nrdconta = craptdb.nrdconta AND
                                                   crapcob.nrcnvcob = craptdb.nrcnvcob AND
                                                   crapcob.nrdocmto = craptdb.nrdocmto AND
                                                   (pr_tpcobran='T' OR crapcob.flgregis=aux_flregis)
         WHERE
              craptdb.cdcooper = pr_cdcooper
              AND craptdb.dtlibbdt = pr_dtvencto
              AND crapbdt.flverbor = 0
         ;
       rw_recebidos_dia cr_recebidos_dia%ROWTYPE;

       /* Saldo Anterior */
       CURSOR cr_saldo_anterior IS
         SELECT
              craptdb.vltitulo,
              craptdb.dtlibbdt,
              craptdb.insittit,
              crapcob.indpagto,
              crapcob.cdbandoc,
              craptdb.dtdpagto,
              craptdb.dtresgat,
              craptdb.dtvencto,
              craptdb.dtdebito
         FROM
              craptdb
              INNER JOIN crapbdt  ON crapbdt.cdcooper = craptdb.cdcooper AND crapbdt.nrborder = craptdb.nrborder
              INNER JOIN crapcob  ON crapcob.cdcooper = craptdb.cdcooper AND
                                                   crapcob.cdbandoc = craptdb.cdbandoc AND
                                                   crapcob.nrdctabb = craptdb.nrdctabb AND
                                                   crapcob.nrdconta = craptdb.nrdconta AND
                                                   crapcob.nrcnvcob = craptdb.nrcnvcob AND
                                                   crapcob.nrdocmto = craptdb.nrdocmto AND
                                                   (pr_tpcobran='T' OR crapcob.flgregis=aux_flregis)
         WHERE
              craptdb.cdcooper = pr_cdcooper
              AND crapbdt.flverbor = 0
         ;
       rw_saldo_anterior cr_saldo_anterior%ROWTYPE;


       -- Variaveis de retorno
         vr_qtderesg     INTEGER;
         vr_vlderesg     NUMBER;
         vr_qtvencid     INTEGER;
         vr_vlvencid     NUMBER;
         vr_qttitulo     INTEGER;
         vr_vltitulo     NUMBER;
         vr_qtliberado   INTEGER;
         vr_vlliberado   NUMBER;
         vr_qtsaldo      INTEGER;
         vr_vlsaldo      NUMBER;
         vr_qtpgdepois   INTEGER;
         vr_vlpgdepois   NUMBER;
         vr_qtrgdepois   INTEGER;
         vr_vlrgdepois   NUMBER;
         vr_qtbxdepois   INTEGER;
         vr_vlbxdepois   NUMBER;
         vr_qtsldant     INTEGER;
         vr_vlsldant     NUMBER;
         vr_qtcredit     INTEGER;
         vr_vlcredit     NUMBER;

    BEGIN
      -- Carrega dia anterior ao vencimento
      IF (pr_dtmvtolt IS NOT NULL ) THEN
        vr_dtmvtolt:=pr_dtmvtolt;
      ELSE
        vr_dtmvtolt:=NULL;
      END IF;

      IF (pr_dtvencto IS NOT NULL ) THEN
         vr_dtvencto := pr_dtvencto;
      ELSE
        vr_dtvencto := vr_dtmvtolt;
        --vr_dtperant := NULL;
      END IF;

      IF (vr_dtvencto > vr_dtmvtolt) THEN
         vr_cdcritic := 13;
        raise vr_exc_erro;
      END IF;

      -- Incluir nome do modulo logado
        GENE0001.pc_informa_acesso(pr_module => 'TELA_TITCTO'
                              ,pr_action => NULL);

      -- Começa a listagem da tabela
         vr_qtderesg := 0;
         vr_vlderesg := 0;
         vr_qtvencid := 0;
         vr_vlvencid := 0;
         vr_vltitulo := 0;
         vr_qttitulo := 0;
         vr_vlliberado := 0;
         vr_qtliberado := 0;
         vr_vlsaldo := 0;
         vr_qtsaldo := 0;
         vr_qtpgdepois := 0;
         vr_vlpgdepois := 0;
         vr_qtbxdepois := 0;
         vr_vlbxdepois := 0;
         vr_vlrgdepois := 0;
         vr_qtrgdepois := 0;
         IF (pr_tpcobran='S') THEN
           aux_flregis := 0;
         ELSE
           IF (pr_tpcobran='R') THEN
              aux_flregis := 1;
           ELSE
              aux_flregis := NULL;
           END IF;
         END IF;

         /*Calcula Resgatados*/
         OPEN  cr_resgatados;
         LOOP
               FETCH cr_resgatados INTO rw_resgatados;
               EXIT  WHEN cr_resgatados%NOTFOUND;
                 vr_qtderesg := vr_qtderesg - 1;
                 vr_vlderesg := vr_vlderesg - rw_resgatados.vltitulo;
         end   loop;

         /*Calcula data de referencia*/
         tmp_utilante := gene0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper
                                             ,pr_dtmvtolt => pr_dtvencto-1
                                             ,pr_tipo     => 'A' );
         tmp_dtrefere := gene0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper
                                             ,pr_dtmvtolt => tmp_utilante-1
                                             ,pr_tipo     => 'A' );
         IF (tmp_utilante - tmp_dtrefere) > 1 THEN
           vr_dtrefere := tmp_dtrefere;
         ELSE
           vr_dtrefere := tmp_utilante;
         END IF;
         /*Ultimo dia util*/
         vr_dtmvtoan := tmp_utilante;

         /*Calcula baixados sem pagamento dia*/
         OPEN  cr_baixados_sem_pagamento;
         LOOP
               FETCH cr_baixados_sem_pagamento INTO rw_baixados_sem_pagamento;
               EXIT  WHEN cr_baixados_sem_pagamento%NOTFOUND;
                 
                       vr_qtvencid := vr_qtvencid - 1;
                       vr_vlvencid := vr_vlvencid - rw_baixados_sem_pagamento.vltitulo;
                 
         end loop;

         vr_dtrefere := gene0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper
                                             ,pr_dtmvtolt => vr_dtmvtoan-1
                                             ,pr_tipo     => 'A' );

         /*Calcula pagos COMPE*/
         OPEN  cr_pagos_compe;
         LOOP
               FETCH cr_pagos_compe INTO rw_pagos_compe;
               EXIT  WHEN cr_pagos_compe%NOTFOUND;
                 vr_qtvencid := vr_qtvencid - 1;
                 vr_vlvencid := vr_vlvencid - rw_pagos_compe.vltitulo;
         end   loop;

         /*Calcula pagos CAIXA*/
         OPEN  cr_pagos_caixa;
         LOOP
               FETCH cr_pagos_caixa INTO rw_pagos_caixa;
               EXIT  WHEN cr_pagos_caixa%NOTFOUND;
                 vr_qtvencid := vr_qtvencid - 1;
                 vr_vlvencid := vr_vlvencid - rw_pagos_caixa.vltitulo;
         end   loop;

         /*Calcula recebidos no dia*/
         OPEN  cr_recebidos_dia;
         LOOP
               FETCH cr_recebidos_dia INTO rw_recebidos_dia;
               EXIT  WHEN cr_recebidos_dia%NOTFOUND;
                 vr_qttitulo := vr_qttitulo + 1;
                 vr_vltitulo := vr_vltitulo + rw_recebidos_dia.vltitulo;
         end   loop;

         /*Calcula Saldo Anterior*/
         OPEN  cr_saldo_anterior;
         LOOP
               FETCH cr_saldo_anterior INTO rw_saldo_anterior;
               EXIT  WHEN cr_saldo_anterior%NOTFOUND;
                  /* Utiliza essas duas variaveis para pegar TODOS os títulos LIBERADOS até a data informada, pois ele
                  subtrai TODOS os com data de liberação a partir da data informada (qtd_liberado) de todos os liberados
                  da craptdb (qtd_saldo)  */
                  IF (rw_saldo_anterior.dtlibbdt >= pr_dtvencto) THEN
                     vr_vlliberado := vr_vlliberado + rw_saldo_anterior.vltitulo;
                     vr_qtliberado := vr_qtliberado + 1;
                  END IF;
                  IF (rw_saldo_anterior.insittit = 4) THEN
                    vr_vlsaldo := vr_vlsaldo + rw_saldo_anterior.vltitulo;
                    vr_qtsaldo := vr_qtsaldo + 1;
                    CONTINUE;
                  END IF;
                  /* D + 1 para titulos pagos via COMPE */
                  /* apenas para titulos do BB */
                  IF (rw_saldo_anterior.indpagto = 0 AND rw_saldo_anterior.cdbandoc = 001) THEN
                    IF (rw_saldo_anterior.dtdpagto >= vr_dtmvtoan) THEN
                      vr_vlpgdepois := vr_vlpgdepois + rw_saldo_anterior.vltitulo;
                      vr_qtpgdepois := vr_qtpgdepois + 1;
                      CONTINUE;
                    END IF;
                  ELSE
                    IF (rw_saldo_anterior.dtdpagto >= pr_dtvencto) THEN
                      vr_vlpgdepois := vr_vlpgdepois + rw_saldo_anterior.vltitulo;
                      vr_qtpgdepois := vr_qtpgdepois + 1;
                      CONTINUE;
                    END IF;
                  END IF;

                  IF (rw_saldo_anterior.dtresgat >= pr_dtvencto) THEN
                    vr_vlrgdepois := vr_vlrgdepois + rw_saldo_anterior.vltitulo;
                    vr_qtrgdepois := vr_qtrgdepois + 1;
                    CONTINUE;
                  END IF;


                  tmp_diffdias := (vr_dtmvtoan - rw_saldo_anterior.dtvencto);
                  /* Quando a pessoa informa um dia que for terca feira
                     contabilizar os baixados sem pagamento do final de semana
                     passado na terca feira */
                  IF  (to_char(rw_saldo_anterior.dtvencto,'D') = 7  OR  to_char(rw_saldo_anterior.dtvencto,'D') = 1)
                      AND to_char(vr_dtmvtoan,'D') = 2 AND rw_saldo_anterior.insittit  = 3
                      AND tmp_diffdias IN (1,2,3) THEN
                      vr_vlbxdepois := vr_vlbxdepois + rw_saldo_anterior.vltitulo;
                      vr_qtbxdepois := vr_qtbxdepois +1;
                      CONTINUE;
                  END IF;

                  IF  (rw_saldo_anterior.insittit  = 3 AND (rw_saldo_anterior.dtdebito > vr_dtmvtoan OR (rw_saldo_anterior.dtdebito IS NULL AND rw_saldo_anterior.dtvencto >= vr_dtmvtoan))) THEN
                      vr_vlbxdepois := vr_vlbxdepois + rw_saldo_anterior.vltitulo;
                      vr_qtbxdepois := vr_qtbxdepois +1;
                  END IF;

         end   loop;
         vr_qtsldant := (vr_qtpgdepois + vr_qtrgdepois + vr_qtbxdepois) + (vr_qtsaldo - vr_qtliberado) ;
         vr_qtcredit := vr_qtsldant + vr_qtvencid +vr_qttitulo + vr_qtderesg ;
         vr_vlsldant := (vr_vlpgdepois + vr_vlrgdepois +vr_vlbxdepois)+ (vr_vlsaldo - vr_vlliberado) ;
         vr_vlcredit := vr_vlsldant + vr_vlvencid + vr_vltitulo + vr_vlderesg ;
         pr_tab_dados_conciliacao(0).dtvencto := pr_dtvencto;
         pr_tab_dados_conciliacao(0).qtsldant := vr_qtsldant; -- Saldo Anterior
         pr_tab_dados_conciliacao(0).vlsldant := vr_vlsldant; -- Saldo Anterior
         pr_tab_dados_conciliacao(0).qtderesg := vr_qtderesg; -- Titulos Resgatados
         pr_tab_dados_conciliacao(0).vlderesg := vr_vlderesg; -- Titulos Resgatados
         pr_tab_dados_conciliacao(0).qtvencid := vr_qtvencid; -- Vencimentos no dia
         pr_tab_dados_conciliacao(0).vlvencid := vr_vlvencid; -- Vencimentos no dia
         pr_tab_dados_conciliacao(0).qttitulo := vr_qttitulo; -- Titulos Recebidos
         pr_tab_dados_conciliacao(0).vltitulo := vr_vltitulo; -- Titulos Recebidos
         pr_tab_dados_conciliacao(0).qtcredit := vr_qtcredit; -- SALDO ATUAL
         pr_tab_dados_conciliacao(0).vlcredit := vr_vlcredit; -- SALDO ATUAL
    END;
    EXCEPTION
      when vr_exc_erro then
           /*  se foi retornado apenas código */
           if  nvl(vr_cdcritic,0) > 0 and vr_dscritic is null then
               /* buscar a descriçao */
               vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
           end if;
           /* variavel de erro recebe erro ocorrido */
           pr_cdcritic := nvl(vr_cdcritic,0);
           pr_dscritic := vr_dscritic;
      WHEN OTHERS THEN
           /* montar descriçao de erro nao tratado */
           pr_dscritic := 'erro nao tratado na TELA_TITCTO.pc_obtem_dados_conciliacao ' ||sqlerrm;
  END pc_obtem_dados_conciliacao;

  PROCEDURE pc_obtem_dados_conciliacao_tit(pr_cdcooper IN crapcop.cdcooper%TYPE --> Código da Cooperativa
                                          ,pr_dtvencto IN DATE                  --> Data de vencimento
                                          ,pr_dtmvtolt IN DATE                  --> Data da movimentacao
                                          ,pr_tab_dados_conciliacao OUT typ_tab_dados_conciliacao --> Tabela de retorno
                                          ,pr_cdcritic              OUT NUMBER                    --> codigo da critica
                                          ,pr_dscritic              OUT VARCHAR2                  --> descricao da critica.
                                          ) IS
    /*---------------------------------------------------------------------------------------------------------
      Programa : pc_obtem_dados_conciliacao_tit
      Sistema  : Ayllos
      Sigla    : 
      Autor    : Paulo Penteado (GFT)
      Data     : 17/10/2018
  
      Objetivo  : Gerar conciliação contábil com informações de lançamento dos borderôs da nova carteira de 
                  desconto de titulo.
                  
                  Opção S da tela TITCTO
  
      Alteração : 17/10/2018 - Criação (Paulo Penteado (GFT))
  
    ----------------------------------------------------------------------------------------------------------*/
  
    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic crapcri.dscritic%TYPE;
  
    -- Tratamento de erros
    vr_exc_erro EXCEPTION;

    vr_dtvencto DATE;
    vr_dtmvtolt DATE; 
    
    -- Variaveis de retorno
    vr_qtderesg NUMBER;
    vr_vlderesg NUMBER;
    vr_qtvencid NUMBER;
    vr_vlvencid NUMBER;
    vr_qttitulo NUMBER;
    vr_vltitulo NUMBER;
    vr_qtsldant NUMBER;
    vr_vlsldant NUMBER;
    vr_qtcredit NUMBER;
    vr_vlcredit NUMBER;
    vr_qtprejui NUMBER;
    vr_vlprejui NUMBER;
    vr_qtestorn NUMBER;
    vr_vlestorn NUMBER;
    
    vr_cdhisven VARCHAR2(1000);
    vr_cdhisant VARCHAR2(1000);
    vr_cdhisrec VARCHAR2(1000);
    vr_cdhisprj VARCHAR2(1000);
    vr_cdhisest VARCHAR2(1000);
    
    -- Resgatados no dia
    CURSOR cr_resgatados IS
    SELECT COUNT(1) qtderesg
          ,nvl(SUM(vllanmto),0) vlderesg
      FROM tbdsct_lancamento_bordero lcb 
     WHERE lcb.cdhistor = dsct0001.vr_cdhistordsct_resbaix --2678
       AND lcb.dtmvtolt = pr_dtvencto
       AND lcb.cdcooper = pr_cdcooper;
    rw_resgatados cr_resgatados%ROWTYPE;
    
    -- Vencidos no dia
    CURSOR cr_vencidos_no_dia IS
    SELECT COUNT(1) qtvencid
          ,nvl(SUM(vllanmto),0) vlvencid
      FROM tbdsct_lancamento_bordero lcb 
     WHERE lcb.cdhistor IN (SELECT to_number(regexp_substr(vr_cdhisven,'[^,]+', 1, LEVEL)) FROM dual
                            CONNECT BY regexp_substr(vr_cdhisven, '[^,]+', 1, LEVEL) IS NOT NULL)
       AND lcb.dtmvtolt = pr_dtvencto
       AND lcb.cdcooper = pr_cdcooper;
    rw_vencidos_no_dia cr_vencidos_no_dia%ROWTYPE;
    
    -- Prejuizo no dia
    CURSOR cr_prejuizo_no_dia IS
    SELECT COUNT(1) qtprejui
          ,nvl(SUM(vllanmto),0) vlprejui
      FROM tbdsct_lancamento_bordero lcb 
     WHERE lcb.cdhistor IN (SELECT to_number(regexp_substr(vr_cdhisprj,'[^,]+', 1, LEVEL)) FROM dual
                            CONNECT BY regexp_substr(vr_cdhisprj, '[^,]+', 1, LEVEL) IS NOT NULL)
       AND lcb.dtmvtolt = pr_dtvencto
       AND lcb.cdcooper = pr_cdcooper;
    rw_prejuizo_no_dia cr_prejuizo_no_dia%ROWTYPE;
    
    -- Estorno no dia
    CURSOR cr_estorno_no_dia IS
    SELECT COUNT(1) qtestorn
          ,nvl(SUM(vllanmto),0) vlestorn
      FROM tbdsct_lancamento_bordero lcb 
     WHERE lcb.cdhistor IN (SELECT to_number(regexp_substr(vr_cdhisest,'[^,]+', 1, LEVEL)) FROM dual
                            CONNECT BY regexp_substr(vr_cdhisest, '[^,]+', 1, LEVEL) IS NOT NULL)
       AND lcb.dtmvtolt = pr_dtvencto
       AND lcb.cdcooper = pr_cdcooper;
    rw_estorno_no_dia cr_estorno_no_dia%ROWTYPE;
    
    -- Recebidos no dia
    CURSOR cr_recebidos_dia IS
    SELECT SUM((SELECT COUNT(1)
                  FROM craptdb tdb
                 WHERE tdb.nrborder = lcb.nrborder
                   AND tdb.nrdconta = lcb.nrdconta
                   AND tdb.cdcooper = lcb.cdcooper)) qttitulo
          ,nvl(SUM(vllanmto),0) vltitulo
      FROM tbdsct_lancamento_bordero lcb 
     WHERE lcb.cdhistor IN (SELECT to_number(regexp_substr(vr_cdhisrec,'[^,]+', 1, LEVEL)) FROM dual
                            CONNECT BY regexp_substr(vr_cdhisrec, '[^,]+', 1, LEVEL) IS NOT NULL)
       AND lcb.dtmvtolt = pr_dtvencto
       AND lcb.cdcooper = pr_cdcooper;
    rw_recebidos_dia cr_recebidos_dia%ROWTYPE;
    
    -- Saldo anterior
    CURSOR cr_saldo_anterior IS
    SELECT nvl(SUM(CASE WHEN his.indebcre = 'D' THEN vllanmto ELSE 0 END) -
               SUM(CASE WHEN his.indebcre = 'C' THEN vllanmto ELSE 0 END),0) vlsldant
      FROM craphis his
          ,tbdsct_lancamento_bordero lcb 
     WHERE his.cdcooper = lcb.cdcooper
       AND his.cdhistor = lcb.cdhistor
       AND lcb.cdhistor IN (SELECT to_number(regexp_substr(vr_cdhisant,'[^,]+', 1, LEVEL)) FROM dual
                            CONNECT BY regexp_substr(vr_cdhisant, '[^,]+', 1, LEVEL) IS NOT NULL)
       AND lcb.dtmvtolt < pr_dtvencto
       AND lcb.cdcooper = pr_cdcooper;
    rw_saldo_anterior cr_saldo_anterior%ROWTYPE;
    
    CURSOR cr_saldo_ant_qtd IS
    SELECT COUNT(1)
      FROM crapbdt bdt
          ,craptdb tdb
     WHERE bdt.flverbor = 1
       AND bdt.nrborder = tdb.nrborder
       AND bdt.cdcooper = tdb.cdcooper
       AND (nvl(tdb.dtdpagto,tdb.dtdebito) >= pr_dtvencto OR tdb.dtresgat >= pr_dtvencto  OR tdb.insittit = 4 )
       AND tdb.dtlibbdt < pr_dtvencto
       AND tdb.cdcooper = pr_cdcooper;
     
  BEGIN
    vr_qtderesg := 0;
    vr_vlderesg := 0;
    vr_qtvencid := 0;
    vr_vlvencid := 0;
    vr_qttitulo := 0;
    vr_vltitulo := 0;
    vr_qtsldant := 0;
    vr_vlsldant := 0;
    
    -- Carrega dia anterior ao vencimento
    IF (pr_dtmvtolt IS NOT NULL ) THEN
      vr_dtmvtolt:=pr_dtmvtolt;
    ELSE
      vr_dtmvtolt:=NULL;
    END IF;

    IF (pr_dtvencto IS NOT NULL ) THEN
       vr_dtvencto := pr_dtvencto;
    ELSE
      vr_dtvencto := vr_dtmvtolt;
      --vr_dtperant := NULL;
    END IF;

    IF (vr_dtvencto > vr_dtmvtolt) THEN
       vr_cdcritic := 13;
      raise vr_exc_erro;
    END IF;

    -- Resgatados
    OPEN cr_resgatados;
    FETCH cr_resgatados INTO rw_resgatados;
    IF cr_resgatados%FOUND THEN
      vr_qtderesg := rw_resgatados.qtderesg * -1;
      vr_vlderesg := rw_resgatados.vlderesg * -1;
    END IF;
    CLOSE cr_resgatados;
    
    -- Vencidos no dia
    vr_cdhisven := dsct0003.vr_cdhistordsct_pgtoopc       ||','|| --2671
                   dsct0003.vr_cdhistordsct_pgtocompe     ||','|| --2672
                   dsct0003.vr_cdhistordsct_pgtocooper    ||','|| --2673
                   dsct0003.vr_cdhistordsct_pgtoavalopc   ||','|| --2675
                   dsct0003.vr_cdhistordsct_pgtomultaopc  ||','|| --2682
                   dsct0003.vr_cdhistordsct_pgtomultaavopc||','|| --2684
                   dsct0003.vr_cdhistordsct_pgtojurosopc  ||','|| --2686
                   dsct0003.vr_cdhistordsct_pgtojurosavopc;       --2688

    OPEN cr_vencidos_no_dia;
    FETCH cr_vencidos_no_dia INTO rw_vencidos_no_dia;
    IF cr_vencidos_no_dia%FOUND THEN
      vr_qtvencid := rw_vencidos_no_dia.qtvencid * -1;
      vr_vlvencid := rw_vencidos_no_dia.vlvencid * -1;
    END IF;
    CLOSE cr_vencidos_no_dia;
    
    -- Prejuizo no dia
    vr_cdhisprj := PREJ0005.vr_cdhistordsct_principal    ||','|| --2754
                   PREJ0005.vr_cdhistordsct_juros_60_rem ||','|| --2755
                   PREJ0005.vr_cdhistordsct_juros_60_mor ||','|| --2761
                   PREJ0005.vr_cdhistordsct_juros_60_mul;        --2879
  
    OPEN cr_prejuizo_no_dia;
    FETCH cr_prejuizo_no_dia INTO rw_prejuizo_no_dia;
    IF cr_prejuizo_no_dia%FOUND THEN
      vr_qtprejui := rw_prejuizo_no_dia.qtprejui * -1;
      vr_vlprejui := rw_prejuizo_no_dia.vlprejui * -1;
    END IF;
    CLOSE cr_prejuizo_no_dia;
    
    -- Estornado no dia
    vr_cdhisest := DSCT0003.vr_cdhistordsct_est_pgto       ||','|| --2811
                   DSCT0003.vr_cdhistordsct_est_multa      ||','|| --2812
                   DSCT0003.vr_cdhistordsct_est_juros      ||','|| --2813
                   DSCT0003.vr_cdhistordsct_est_pgto_ava   ||','|| --2814
                   DSCT0003.vr_cdhistordsct_est_multa_ava  ||','|| --2815
                   DSCT0003.vr_cdhistordsct_est_juros_ava  ||','|| --2816
                   DSCT0003.vr_cdhistordsct_est_apro_multa ||','|| --2880
                   DSCT0003.vr_cdhistordsct_est_apro_juros;        --2881
                   
    OPEN cr_estorno_no_dia;
    FETCH cr_estorno_no_dia INTO rw_estorno_no_dia;
    IF cr_estorno_no_dia%FOUND THEN
      vr_qtestorn := rw_estorno_no_dia.qtestorn;
      vr_vlestorn := rw_estorno_no_dia.vlestorn;
    END IF;
    CLOSE cr_estorno_no_dia;
    
    -- Recebidos no dia
    vr_cdhisrec := dsct0003.vr_cdhistordsct_liberacred    ||','|| --2665
                   dsct0003.vr_cdhistordsct_apropjurmra   ||','|| --2668
                   dsct0003.vr_cdhistordsct_apropjurmta   ||','|| --2669
                   dsct0003.vr_cdhistordsct_deboppagmaior ||','|| --2804
                   dsct0003.vr_cdhistordsct_iofcompleoper;        --2800
    
    OPEN cr_recebidos_dia;
    FETCH cr_recebidos_dia INTO rw_recebidos_dia;
    IF cr_recebidos_dia%FOUND THEN
      vr_qttitulo := rw_recebidos_dia.qttitulo;
      vr_vltitulo := rw_recebidos_dia.vltitulo;
    END IF;
    CLOSE cr_recebidos_dia;
    
    -- Saldo anterior
    vr_cdhisant := dsct0001.vr_cdhistordsct_resbaix||','||vr_cdhisrec||','||vr_cdhisven||','|| vr_cdhisprj ||',' || vr_cdhisest;
    
    OPEN cr_saldo_anterior;
    FETCH cr_saldo_anterior INTO rw_saldo_anterior;
    IF cr_saldo_anterior%FOUND THEN
      vr_vlsldant := rw_saldo_anterior.vlsldant;    
    END IF;
    CLOSE cr_saldo_anterior; 
    
    OPEN cr_saldo_ant_qtd;
    FETCH cr_saldo_ant_qtd INTO vr_qtsldant;
    CLOSE cr_saldo_ant_qtd;
    
    -- Saldo atual
    vr_qtcredit := vr_qtsldant + vr_qtvencid + vr_qttitulo + vr_qtderesg + vr_qtprejui + vr_qtestorn;
    vr_vlcredit := vr_vlsldant + vr_vlvencid + vr_vltitulo + vr_vlderesg + vr_vlprejui + vr_vlestorn ;

    pr_tab_dados_conciliacao(0).dtvencto := pr_dtvencto;
    pr_tab_dados_conciliacao(0).qtsldant := vr_qtsldant; -- Saldo Anterior
    pr_tab_dados_conciliacao(0).vlsldant := vr_vlsldant; -- Saldo Anterior
    pr_tab_dados_conciliacao(0).qtderesg := vr_qtderesg; -- Titulos Resgatados
    pr_tab_dados_conciliacao(0).vlderesg := vr_vlderesg; -- Titulos Resgatados
    pr_tab_dados_conciliacao(0).qtvencid := vr_qtvencid; -- Vencimentos no dia
    pr_tab_dados_conciliacao(0).vlvencid := vr_vlvencid; -- Vencimentos no dia
    pr_tab_dados_conciliacao(0).qttitulo := vr_qttitulo; -- Titulos Recebidos
    pr_tab_dados_conciliacao(0).vltitulo := vr_vltitulo; -- Titulos Recebidos
    pr_tab_dados_conciliacao(0).qtprejui := vr_qtprejui; -- Prejuizo no dia
    pr_tab_dados_conciliacao(0).vlprejui := vr_vlprejui; -- Prejuizo no dia
    pr_tab_dados_conciliacao(0).qtestorn := vr_qtestorn; -- Estorno no dia
    pr_tab_dados_conciliacao(0).vlestorn := vr_vlestorn; -- Estorno no dia
    pr_tab_dados_conciliacao(0).qtcredit := vr_qtcredit; -- SALDO ATUAL
    pr_tab_dados_conciliacao(0).vlcredit := vr_vlcredit; -- SALDO ATUAL

  EXCEPTION
    WHEN vr_exc_erro then
      IF vr_cdcritic <> 0 AND TRIM(vr_dscritic) IS NULL THEN
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
  
    WHEN OTHERS THEN
      pr_cdcritic := nvl(vr_cdcritic,0);
      pr_dscritic := 'Erro geral na rotina TELA_TITCTO.pc_obtem_dados_conciliacao_tit: '||SQLERRM;
  END pc_obtem_dados_conciliacao_tit;


  PROCEDURE pc_obtem_dados_conciliacao_web(pr_tpcobran    IN CHAR                  --> Filtro de tipo de cobranca
                                        ,pr_dtvencto    IN VARCHAR2                  --> Data de vencimento
                                        ,pr_dtmvtolt    IN VARCHAR2                  --> Data da movimentacao
                                        ,pr_xmllog   IN VARCHAR2           --> XML com informações de LOG
                                        ,pr_cdcritic out pls_integer           --> codigo da critica
                                        ,pr_dscritic out varchar2              --> descricao da critica
                                        ,pr_retxml   in  out nocopy xmltype    --> arquivo de retorno do xml
                                        ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                                        ,pr_des_erro OUT VARCHAR2      --> Erros do processo
                                      ) is
    -- variaveis de retorno
    vr_tab_dados_antigo typ_tab_dados_conciliacao;
    vr_tab_dados_novo typ_tab_dados_conciliacao;

    vr_tab_erro         gene0001.typ_tab_erro;
    vr_qtregist         number;

    -- variaveis de entrada vindas no xml
    vr_cdcooper integer;
    vr_cdoperad varchar2(100);
    vr_nmdatela varchar2(100);
    vr_nmeacao  varchar2(100);
    vr_cdagenci varchar2(100);
    vr_nrdcaixa varchar2(100);
    vr_idorigem varchar2(100);

    -- variáveis para armazenar as informaçoes em xml
    vr_des_xml        clob;
    vr_texto_completo varchar2(32600);
    vr_index          PLS_INTEGER;

    vr_dtvencto DATE;
    vr_dtmvtolt DATE;    

    procedure pc_escreve_xml( pr_des_dados in varchar2
                            , pr_fecha_xml in boolean default false
                            ) is
    begin
        gene0002.pc_escreve_xml( vr_des_xml
                               , vr_texto_completo
                               , pr_des_dados
                               , pr_fecha_xml );
    end;

    begin
      gene0004.pc_extrai_dados( pr_xml      => pr_retxml
                              , pr_cdcooper => vr_cdcooper
                              , pr_nmdatela => vr_nmdatela
                              , pr_nmeacao  => vr_nmeacao
                              , pr_cdagenci => vr_cdagenci
                              , pr_nrdcaixa => vr_nrdcaixa
                              , pr_idorigem => vr_idorigem
                              , pr_cdoperad => vr_cdoperad
                              , pr_dscritic => vr_dscritic);

      IF pr_dtmvtolt IS NOT NULL THEN
        vr_dtmvtolt := to_date(pr_dtmvtolt, 'DD/MM/RRRR');
      ELSE
        vr_dtmvtolt := NULL;
      END IF;

      IF pr_dtvencto IS NOT NULL THEN
        vr_dtvencto := to_date(pr_dtvencto, 'DD/MM/RRRR');
      ELSE
        vr_dtvencto := NULL;
      END IF;

      pc_obtem_dados_conciliacao( pr_cdcooper => vr_cdcooper,
                                        pr_tpcobran => pr_tpcobran,
                                 pr_dtvencto => vr_dtvencto,
                                 pr_dtmvtolt => vr_dtmvtolt,
                                        --> out
                                        pr_tab_dados_conciliacao => vr_tab_dados_antigo,
                                        pr_cdcritic => pr_cdcritic,
                                 pr_dscritic => pr_dscritic );

      -- Somente se selecionar o tipo de cobrança registrada ou todos
      IF pr_tpcobran <> 'S' THEN
        pc_obtem_dados_conciliacao_tit(pr_cdcooper => vr_cdcooper,
                                       pr_dtvencto => vr_dtvencto,
                                       pr_dtmvtolt => vr_dtmvtolt,
                                        --> out
                                        pr_tab_dados_conciliacao => vr_tab_dados_novo,
                                        pr_cdcritic => pr_cdcritic,
                                       pr_dscritic => pr_dscritic );
      END IF;

      -- inicializar o clob
      vr_des_xml := null;
      dbms_lob.createtemporary(vr_des_xml, true);
      dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
      -- inicilizar as informaçoes do xml
      vr_texto_completo := null;

      pc_escreve_xml('<?xml version="1.0" encoding="iso-8859-1" ?>'||
                     '<root><dados >');

      pc_escreve_xml('<antigo>'||
                        '<dtvencto>' || to_char(vr_tab_dados_antigo(0).dtvencto,'dd/mm/rrrr') || '</dtvencto>' ||
                        '<qtsldant>' || vr_tab_dados_antigo(0).qtsldant || '</qtsldant>' ||
                        '<vlsldant>' || vr_tab_dados_antigo(0).vlsldant || '</vlsldant>' ||
                        '<qtderesg>' || vr_tab_dados_antigo(0).qtderesg || '</qtderesg>' ||
                        '<vlderesg>' || vr_tab_dados_antigo(0).vlderesg || '</vlderesg>' ||
                        '<qtvencid>' || vr_tab_dados_antigo(0).qtvencid || '</qtvencid>' ||
                        '<vlvencid>' || vr_tab_dados_antigo(0).vlvencid || '</vlvencid>' ||
                        '<qttitulo>' || vr_tab_dados_antigo(0).qttitulo || '</qttitulo>' ||
                        '<vltitulo>' || vr_tab_dados_antigo(0).vltitulo || '</vltitulo>' ||
                        '<qtcredit>' || vr_tab_dados_antigo(0).qtcredit || '</qtcredit>' ||
                        '<vlcredit>' || vr_tab_dados_antigo(0).vlcredit || '</vlcredit>' ||
                     '</antigo>'
                          );

      IF vr_tab_dados_novo.count > 0 THEN
      pc_escreve_xml('<novo>'||
                        '<dtvencto>' || to_char(vr_tab_dados_novo(0).dtvencto,'dd/mm/rrrr') || '</dtvencto>' ||
                        '<qtsldant>' || vr_tab_dados_novo(0).qtsldant || '</qtsldant>' ||
                        '<vlsldant>' || vr_tab_dados_novo(0).vlsldant || '</vlsldant>' ||
                        '<qtderesg>' || vr_tab_dados_novo(0).qtderesg || '</qtderesg>' ||
                        '<vlderesg>' || vr_tab_dados_novo(0).vlderesg || '</vlderesg>' ||
                        '<qtvencid>' || vr_tab_dados_novo(0).qtvencid || '</qtvencid>' ||
                        '<vlvencid>' || vr_tab_dados_novo(0).vlvencid || '</vlvencid>' ||
                        '<qttitulo>' || vr_tab_dados_novo(0).qttitulo || '</qttitulo>' ||
                        '<vltitulo>' || vr_tab_dados_novo(0).vltitulo || '</vltitulo>' ||
                        '<qtcredit>' || vr_tab_dados_novo(0).qtcredit || '</qtcredit>' ||
                        '<vlcredit>' || vr_tab_dados_novo(0).vlcredit || '</vlcredit>' ||
                        '<qtprejui>' || vr_tab_dados_novo(0).qtprejui || '</qtprejui>' ||
                        '<vlprejui>' || vr_tab_dados_novo(0).vlprejui || '</vlprejui>' ||
                        '<qtestorn>' || vr_tab_dados_novo(0).qtestorn || '</qtestorn>' ||
                        '<vlestorn>' || vr_tab_dados_novo(0).vlestorn || '</vlestorn>' ||
                     '</novo>'
                          );
      END IF;
                          
      pc_escreve_xml ('</dados></root>',true);
      pr_retxml := xmltype.createxml(vr_des_xml);

      /* liberando a memória alocada pro clob */
      dbms_lob.close(vr_des_xml);
      dbms_lob.freetemporary(vr_des_xml);
    exception
      when vr_exc_erro then
           /*  se foi retornado apenas código */
           if  nvl(vr_cdcritic,0) > 0 and vr_dscritic is null then
               /* buscar a descriçao */
               vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
           end if;
           /* variavel de erro recebe erro ocorrido */
           pr_cdcritic := nvl(vr_cdcritic,0);
           pr_dscritic := vr_dscritic;
      when others then
           /* montar descriçao de erro nao tratado */
           pr_dscritic := 'erro nao tratado na tela_titcto.pc_obtem_dados_conciliacao_web ' ||sqlerrm;
  END pc_obtem_dados_conciliacao_web;

  PROCEDURE pc_obtem_dados_loteamento (pr_cdcooper    IN crapcop.cdcooper%TYPE, --> Código da Cooperativa
                                    pr_nrdconta    IN crapass.nrdconta%TYPE, --> Número da Conta
                                    pr_tpcobran    IN CHAR,                  --> Filtro de tipo de cobranca
                                    pr_tpdepesq    IN CHAR,                  --> Filtro de Situacao
                                    pr_nrdocmto    IN INTEGER,                  --> Numero do Boleto
                                    pr_vltitulo    IN NUMBER,                   --> Valor do titulo
                                    pr_dtmvtolt    IN VARCHAR2,                  --> Data da movimentacao
                                    --> out
                                    pr_qtregist         out integer,         --> Quantidade de registros encontrados
                                    pr_tab_dados_loteamento out  typ_tab_dados_loteamento, --> Tabela de retorno
                                    pr_cdcritic out number,                         --> codigo da critica
                                    pr_dscritic out varchar2                        --> descricao da critica.
                                ) is

    ----------------------------------------------------------------------------------
    --
    -- Procedure: pc_obtem_dados_loteamento
    -- Sistema  : CRED
    -- Sigla    : TELA_TITCTO
    -- Autor    : Luis Fernando - Company: GFT
    -- Data     : Criação: 13/03/2018
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: Sempre que chamado
    -- Objetivo  : Trazer o loteamento de titulos
    ----------------------------------------------------------------------------------
    BEGIN
      DECLARE

       vr_idtabtitcto INTEGER;
       aux_flregis INTEGER;
       vr_dtmvtoan  DATE;
       vr_dtmvtolt  DATE;

       -- Verifica Conta (Cadastro de associados)
       CURSOR cr_crapass IS
         select nmprimtl
               ,inpessoa
               ,nrdconta
         from   crapass
         where
                crapass.cdcooper = pr_cdcooper
                AND    crapass.nrdconta = pr_nrdconta;
       rw_crapass cr_crapass%rowtype;

       CURSOR cr_craptdb IS
          SELECT
            craptdb.dtlibbdt,
            crapbdt.cdagenci,
            crapbdt.cdbccxlt,
            crapbdt.nrdolote,
            craptdb.dtvencto,
            craptdb.cdbandoc,
            craptdb.nrcnvcob,
            craptdb.nrdocmto,
            craptdb.vltitulo,
            crapcob.flgregis
          FROM
              craptdb
              INNER JOIN crapcob ON crapcob.cdcooper = craptdb.cdcooper AND
                                                    crapcob.cdbandoc = craptdb.cdbandoc AND
                                                    crapcob.nrdctabb = craptdb.nrdctabb AND
                                                    crapcob.nrdconta = craptdb.nrdconta AND
                                                    crapcob.nrcnvcob = craptdb.nrcnvcob AND
                                                    crapcob.nrdocmto = craptdb.nrdocmto  AND
                                                    (pr_tpcobran='T' OR crapcob.flgregis=aux_flregis)
              INNER JOIN crapbdt ON crapbdt.cdcooper = craptdb.cdcooper AND crapbdt.nrborder = craptdb.nrborder
          WHERE
              (
                (craptdb.cdcooper = pr_cdcooper AND craptdb.nrdconta = pr_nrdconta AND craptdb.insittit = 2 AND (pr_tpdepesq='T' OR pr_tpdepesq='L'))
                OR (craptdb.cdcooper = pr_cdcooper AND craptdb.nrdconta = pr_nrdconta AND craptdb.insittit = 3 AND pr_tpdepesq='T')
                OR (craptdb.cdcooper = pr_cdcooper AND craptdb.nrdconta = pr_nrdconta AND craptdb.insittit = 4 AND (pr_tpdepesq='T' OR (pr_tpdepesq='A' AND craptdb.dtvencto > vr_dtmvtoan)))
              )
              AND (
                  ((pr_nrdocmto>0 AND pr_nrdocmto = craptdb.nrdocmto) OR nvl(pr_nrdocmto,0)=0) --caso tenha passado numero do boleto
                  AND ((pr_vltitulo>0 AND pr_vltitulo = craptdb.vltitulo) OR nvl(pr_vltitulo,0)=0) --caso tenha passado o valor
              )
          ORDER BY
              crapcob.flgregis DESC, crapcob.cdbandoc DESC, craptdb.nrdconta
         ;
         rw_craptdb cr_craptdb%ROWTYPE;

    BEGIN
      -- Incluir nome do modulo logado
        GENE0001.pc_informa_acesso(pr_module => 'TELA_TITCTO'
                              ,pr_action => NULL);

      -- Verifica se usuario selecionou ao menos um filtro para o boleto
         IF ((nvl(pr_nrdocmto,0)=0) AND (nvl(pr_vltitulo,0)=0)) THEN
           vr_dscritic := 'Informe ao menos uma selecao!';
           raise vr_exc_erro;
         END IF;

      -- Começa a listagem da tabela
         pr_qtregist:= 0;
         IF (pr_tpcobran='S') THEN
           aux_flregis := 0;
         ELSE
           IF (pr_tpcobran='R') THEN
              aux_flregis := 1;
           ELSE
              aux_flregis := NULL;
           END IF;
         END IF;

         IF (pr_dtmvtolt IS NOT NULL ) THEN
           vr_dtmvtolt := to_date(pr_dtmvtolt, 'DD/MM/RRRR');
           vr_dtmvtoan := gene0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper
                                             ,pr_dtmvtolt => vr_dtmvtolt-1
                                             ,pr_tipo     => 'A' );
         ELSE
           vr_dtmvtolt:=NULL;
         END IF;

         OPEN cr_crapass;

         OPEN  cr_craptdb;
         LOOP
               FETCH cr_craptdb INTO rw_craptdb;
               EXIT  WHEN cr_craptdb%NOTFOUND;
               pr_qtregist := pr_qtregist+1;
               vr_idtabtitcto := pr_tab_dados_loteamento.count + 1;
               pr_tab_dados_loteamento(vr_idtabtitcto).dtlibbdt := rw_craptdb.dtlibbdt;
               pr_tab_dados_loteamento(vr_idtabtitcto).cdagenci := rw_craptdb.cdagenci;
               pr_tab_dados_loteamento(vr_idtabtitcto).cdbccxlt := rw_craptdb.cdbccxlt;
               pr_tab_dados_loteamento(vr_idtabtitcto).nrdolote := rw_craptdb.nrdolote;
               pr_tab_dados_loteamento(vr_idtabtitcto).dtvencto := rw_craptdb.dtvencto;
               pr_tab_dados_loteamento(vr_idtabtitcto).cdbandoc := rw_craptdb.cdbandoc;
               pr_tab_dados_loteamento(vr_idtabtitcto).nrcnvcob := rw_craptdb.nrcnvcob;
               pr_tab_dados_loteamento(vr_idtabtitcto).nrdocmto := rw_craptdb.nrdocmto;
               pr_tab_dados_loteamento(vr_idtabtitcto).vltitulo := rw_craptdb.vltitulo;
               CASE WHEN (rw_craptdb.flgregis = 1  AND rw_craptdb.cdbandoc = 085) THEN
                        pr_tab_dados_loteamento(vr_idtabtitcto).tpcobran := 'Coop. Emite';
                   WHEN (rw_craptdb.flgregis = 1  AND rw_craptdb.cdbandoc <> 085) THEN
                        pr_tab_dados_loteamento(vr_idtabtitcto).tpcobran := 'Banco Emite';
                   WHEN (rw_craptdb.flgregis = 0) THEN
                        pr_tab_dados_loteamento(vr_idtabtitcto).tpcobran := 'S/registro';
                   ELSE
                        pr_tab_dados_loteamento(vr_idtabtitcto).tpcobran := ' ';
               END CASE;
         end   loop;

    END;
    EXCEPTION
      when vr_exc_erro then
           pr_dscritic := vr_dscritic;
      WHEN OTHERS THEN
           /* montar descriçao de erro nao tratado */
           pr_dscritic := 'erro nao tratado na TELA_TITCTO.pc_obtem_dados_loteamento ' ||sqlerrm;
  END pc_obtem_dados_loteamento;

  PROCEDURE pc_obtem_dados_loteamento_web(pr_nrdconta    IN crapass.nrdconta%TYPE --> Número da Conta
                                        ,pr_tpcobran    IN CHAR                  --> Filtro de tipo de cobranca
                                        ,pr_tpdepesq    IN CHAR                  --> Filtro de Situacao
                                        ,pr_nrdocmto    IN INTEGER                  --> Numero do Boleto
                                        ,pr_vltitulo    IN NUMBER                   --> Valor do titulo
                                        ,pr_dtmvtolt    IN VARCHAR2                  --> Data da movimentacao
                                        ,pr_xmllog   IN VARCHAR2           --> XML com informações de LOG
                                        ,pr_cdcritic out pls_integer           --> codigo da critica
                                        ,pr_dscritic out varchar2              --> descricao da critica
                                        ,pr_retxml   in  out nocopy xmltype    --> arquivo de retorno do xml
                                        ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                                        ,pr_des_erro OUT VARCHAR2      --> Erros do processo
                                      ) is
    -- variaveis de retorno
    vr_tab_dados_loteamento typ_tab_dados_loteamento;

    vr_tab_erro         gene0001.typ_tab_erro;
    vr_qtregist         number;

    -- variaveis de entrada vindas no xml
    vr_cdcooper integer;
    vr_cdoperad varchar2(100);
    vr_nmdatela varchar2(100);
    vr_nmeacao  varchar2(100);
    vr_cdagenci varchar2(100);
    vr_nrdcaixa varchar2(100);
    vr_idorigem varchar2(100);

    -- variáveis para armazenar as informaçoes em xml
    vr_des_xml        clob;
    vr_texto_completo varchar2(32600);
    vr_index          PLS_INTEGER;

    procedure pc_escreve_xml( pr_des_dados in varchar2
                            , pr_fecha_xml in boolean default false
                            ) is
    begin
        gene0002.pc_escreve_xml( vr_des_xml
                               , vr_texto_completo
                               , pr_des_dados
                               , pr_fecha_xml );
    end;

    begin
      gene0004.pc_extrai_dados( pr_xml      => pr_retxml
                              , pr_cdcooper => vr_cdcooper
                              , pr_nmdatela => vr_nmdatela
                              , pr_nmeacao  => vr_nmeacao
                              , pr_cdagenci => vr_cdagenci
                              , pr_nrdcaixa => vr_nrdcaixa
                              , pr_idorigem => vr_idorigem
                              , pr_cdoperad => vr_cdoperad
                              , pr_dscritic => vr_dscritic);

      pc_obtem_dados_loteamento( vr_cdcooper,
                                        pr_nrdconta,
                                        pr_tpcobran,
                                        pr_tpdepesq,
                                        pr_nrdocmto,
                                        pr_vltitulo,
                                        pr_dtmvtolt,
                                        --> out
                                        vr_qtregist,
                                        vr_tab_dados_loteamento,
                                        pr_cdcritic,
                                        pr_dscritic
                               );


      -- inicializar o clob
      vr_des_xml := null;
      dbms_lob.createtemporary(vr_des_xml, true);
      dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
      -- inicilizar as informaçoes do xml
      vr_texto_completo := null;

      pc_escreve_xml('<?xml version="1.0" encoding="iso-8859-1" ?>'||
                     '<root><dados >');

      -- ler os registros de titcto e incluir no xml
      vr_index := vr_tab_dados_loteamento.first;
      while vr_index is not null loop
            pc_escreve_xml('<inf>'||
                              '<dtlibbdt>' || to_char(vr_tab_dados_loteamento(vr_index).dtlibbdt,'dd/mm/rrrr') || '</dtlibbdt>' ||
                              '<cdagenci>' || vr_tab_dados_loteamento(vr_index).cdagenci || '</cdagenci>' ||
                              '<cdbccxlt>' || vr_tab_dados_loteamento(vr_index).cdbccxlt || '</cdbccxlt>' ||
                              '<nrdolote>' || vr_tab_dados_loteamento(vr_index).nrdolote || '</nrdolote>' ||
                              '<dtvencto>' || to_char(vr_tab_dados_loteamento(vr_index).dtvencto,'dd/mm/rrrr') || '</dtvencto>' ||
                              '<cdbandoc>' || vr_tab_dados_loteamento(vr_index).cdbandoc || '</cdbandoc>' ||
                              '<nrcnvcob>' || vr_tab_dados_loteamento(vr_index).nrcnvcob || '</nrcnvcob>' ||
                              '<nrdocmto>' || vr_tab_dados_loteamento(vr_index).nrdocmto || '</nrdocmto>' ||
                              '<vltitulo>' || vr_tab_dados_loteamento(vr_index).vltitulo || '</vltitulo>' ||
                              '<tpcobran>' || vr_tab_dados_loteamento(vr_index).tpcobran || '</tpcobran>' ||
                           '</inf>'
                          );
          /* buscar proximo */
          vr_index := vr_tab_dados_loteamento.next(vr_index);
      end loop;
      pc_escreve_xml ('</dados></root>',true);
      pr_retxml := xmltype.createxml(vr_des_xml);

      /* liberando a memória alocada pro clob */
      dbms_lob.close(vr_des_xml);
      dbms_lob.freetemporary(vr_des_xml);
    exception
      when vr_exc_erro then
           /*  se foi retornado apenas código */
           if  nvl(vr_cdcritic,0) > 0 and vr_dscritic is null then
               /* buscar a descriçao */
               vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
           end if;
           /* variavel de erro recebe erro ocorrido */
           pr_cdcritic := nvl(vr_cdcritic,0);
           pr_dscritic := vr_dscritic;
      when others then
           /* montar descriçao de erro nao tratado */
           pr_dscritic := 'erro nao tratado na tela_titcto.pc_obtem_dados_loteamento_web ' ||sqlerrm;
  END pc_obtem_dados_loteamento_web;

  PROCEDURE pc_obtem_dados_lotes (pr_cdcooper    IN crapcop.cdcooper%TYPE, --> Código da Cooperativa
                                    pr_dtmvtolt    IN VARCHAR2,                  --> Data da movimentacao
                                    pr_cdagenci    IN INTEGER,                   --> Numero do PA
                                    --> out
                                    pr_qtregist    OUT INTEGER,                  -- Quantidade de resultados
                                    pr_tab_dados_lotes   out  typ_tab_dados_lotes, --> Tabela de retorno
                                    pr_cdcritic out number,                         --> codigo da critica
                                    pr_dscritic out varchar2                        --> descricao da critica.
                                ) is

    ----------------------------------------------------------------------------------
    --
    -- Procedure: pc_obtem_dados_lotes
    -- Sistema  : CRED
    -- Sigla    : TELA_TITCTO
    -- Autor    : Luis Fernando - Company: GFT
    -- Data     : Criação: 15/03/2018
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: Sempre que chamado
    -- Objetivo  : Trazer listagem de lotes de desconto de titulos efetuados no dia
    ----------------------------------------------------------------------------------
    BEGIN
      DECLARE

       vr_idtabtitcto INTEGER;
       vr_dtmvtolt DATE;
       vr_dtinicio DATE;
       vr_dtpridia DATE;
       vr_dtultdia DATE;

       rw_crapdat btch0001.cr_crapdat%rowtype;

       CURSOR cr_lotes IS
         SELECT
           dtmvtolt,
           cdagenci,
           nrdconta,
           nrborder,
           nrdolote,
           sum((case when flgregis = 1 THEN quantidade ELSE 0 END)) AS qttittot_cr,
           sum((case when flgregis = 0 THEN quantidade ELSE 0 END)) AS qttittot_sr,
           sum((case when flgregis = 1 THEN valor ELSE 0 END)) AS vltittot_cr,
           sum((case when flgregis = 0 THEN valor ELSE 0 END)) AS vltittot_sr,
           nmoperad
          FROM
            (
              SELECT
                dtmvtolt,
                cdagenci,
                nrdolote,
                nrdconta,
                nrborder,
                flgregis,
                count(*) AS quantidade,
                sum(vltitulo) AS valor,
                nmoperad
              FROM (
                  select
                    crapbdt.dtmvtolt,
                    crapbdt.cdagenci,
                    craptdb.nrdconta,
                    crapbdt.nrdolote,
                    crapbdt.nrborder,
                    (CASE WHEN crapope.nmoperad is not null THEN (craptdb.cdoperad || ' - ' || crapope.nmoperad) ELSE craptdb.cdoperad END) AS nmoperad,
                    crapcob.flgregis,
                    craptdb.vltitulo
                  from
                    cecred.crapbdt
                    INNER JOIN craptdb ON craptdb.cdcooper = crapbdt.cdcooper AND
                                            craptdb.nrdconta = crapbdt.nrdconta AND
                                            craptdb.nrborder = crapbdt.nrborder
                    INNER JOIN crapcob ON crapcob.cdcooper = craptdb.cdcooper AND
                                            crapcob.nrdconta = craptdb.nrdconta AND
                                            crapcob.nrcnvcob = craptdb.nrcnvcob AND
                                            crapcob.nrdocmto = craptdb.nrdocmto AND
                                            crapcob.cdbandoc = craptdb.cdbandoc AND
                                            crapcob.nrdctabb = craptdb.nrdctabb
                    LEFT JOIN crapope ON crapope.cdoperad=craptdb.cdoperad AND crapope.cdcooper=craptdb.cdcooper

                  WHERE
                    crapbdt.cdcooper=pr_cdcooper
                    AND crapbdt.dtlibbdt >= vr_dtpridia
                    AND crapbdt.dtlibbdt <= vr_dtultdia
                    AND ((pr_cdagenci>0 AND crapbdt.cdagenci=pr_cdagenci) OR nvl(pr_cdagenci,0)=0)
                  order by crapbdt.cdagenci,crapbdt.dtmvtolt,craptdb.cdbandoc,crapbdt.nrdolote
                )
              group by cdagenci,dtmvtolt,nrdolote, nrdconta,nrborder,flgregis,nmoperad
            )
          group by cdagenci,dtmvtolt,nrdolote,nrdconta,nrborder,nmoperad
          order by cdagenci,dtmvtolt,nrdolote,nrdconta,nrborder,nmoperad;

       rw_lotes cr_lotes%ROWTYPE;


    BEGIN
      -- Carrega dia anterior ao vencimento
      IF (pr_dtmvtolt IS NOT NULL ) THEN
        vr_dtmvtolt := to_date(pr_dtmvtolt, 'DD/MM/RRRR');
        vr_dtpridia := vr_dtmvtolt;
        vr_dtultdia := vr_dtmvtolt;
      ELSE
        open  btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
        fetch btch0001.cr_crapdat into rw_crapdat;
        if    btch0001.cr_crapdat%notfound then
              close btch0001.cr_crapdat;
              vr_cdcritic := 1;
              raise vr_exc_erro;
        end   if;
        close btch0001.cr_crapdat;

        vr_dtpridia := to_date('01'|| '/' ||to_char(rw_crapdat.dtmvtolt,'MM')|| '/' || to_char(rw_crapdat.dtmvtolt,'YYYY'),'DD/MM/YYYY');
        vr_dtultdia := to_date(last_day(rw_crapdat.dtmvtolt) || '/' ||to_char(rw_crapdat.dtmvtolt,'MM')|| '/' || to_char(rw_crapdat.dtmvtolt,'YYYY'),'DD/MM/YYYY');
        vr_dtmvtolt:=NULL;

      END IF;

      -- Incluir nome do modulo logado
        GENE0001.pc_informa_acesso(pr_module => 'TELA_TITCTO'
                              ,pr_action => NULL);

      -- Começa a listagem da tabela
         pr_qtregist := 0;
         OPEN  cr_lotes;
         LOOP
               FETCH cr_lotes INTO rw_lotes;
               EXIT  WHEN cr_lotes%NOTFOUND;
                 pr_qtregist := pr_qtregist+1;
                 vr_idtabtitcto := pr_tab_dados_lotes.count + 1;
                 pr_tab_dados_lotes(vr_idtabtitcto).dtmvtolt := rw_lotes.dtmvtolt;
                 pr_tab_dados_lotes(vr_idtabtitcto).cdagenci := rw_lotes.cdagenci;
                 pr_tab_dados_lotes(vr_idtabtitcto).nrdconta := rw_lotes.nrdconta;
                 pr_tab_dados_lotes(vr_idtabtitcto).nrborder := rw_lotes.nrborder;
                 pr_tab_dados_lotes(vr_idtabtitcto).nrdolote := rw_lotes.nrdolote;
                 pr_tab_dados_lotes(vr_idtabtitcto).qttittot_cr := rw_lotes.qttittot_cr;
                 pr_tab_dados_lotes(vr_idtabtitcto).qttittot_sr := rw_lotes.qttittot_sr;
                 pr_tab_dados_lotes(vr_idtabtitcto).vltittot_cr := rw_lotes.vltittot_cr;
                 pr_tab_dados_lotes(vr_idtabtitcto).vltittot_sr := rw_lotes.vltittot_sr;
                 pr_tab_dados_lotes(vr_idtabtitcto).nmoperad := rw_lotes.nmoperad;
         end   loop;

    END;
    EXCEPTION
      WHEN OTHERS THEN
           /* montar descriçao de erro nao tratado */
           pr_dscritic := 'erro nao tratado na TELA_TITCTO.pc_obtem_dados_lotes ' ||sqlerrm;
  END pc_obtem_dados_lotes;




  /* .............................................................................

  Programa: pc_gerar_impressao_titcto_b
  Sistema : Ayllos Web
  Autor   :
  Data    : Abril/2018                 Ultima atualizacao: 11/04/2018

  Frequencia: Sempre que for chamado

  Objetivo  : Borderôs  de títulos não liberados
  Alteracoes: -----
  ..............................................................................*/
  PROCEDURE pc_gerar_impressao_titcto_b(pr_dtiniper   IN VARCHAR2              --> Data inicial
                                        ,pr_dtfimper   IN VARCHAR2              --> Data final
                                        ,pr_cdagenci   IN crapass.cdagenci%TYPE --> Numero do PA
                                        ,pr_nrdconta   IN crapass.nrdconta%TYPE --> Numero da Conta
                                        ,pr_nrborder   IN crapbdc.nrborder%TYPE --> Numero do bordero
                                        ,pr_xmllog     IN VARCHAR2              --> XML com informacoes de LOG
                                        ,pr_cdcritic  OUT PLS_INTEGER           --> Codigo da critica
                                        ,pr_dscritic  OUT VARCHAR2              --> Descricao da critica
                                        ,pr_retxml IN OUT NOCOPY xmltype        --> Arquivo de retorno do XML
                                        ,pr_nmdcampo  OUT VARCHAR2              --> Nome do campo com erro
                                        ,pr_des_erro  OUT VARCHAR2) IS          --> Erros do processo


    -- Vetor de memoria
    vr_tab_crapage  typ_tab_crapage;

    -- VARIAVEIS
    -- Variavel de criticas
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(10000);
    vr_des_reto VARCHAR2(100);
    vr_tab_erro GENE0001.typ_tab_erro;

    -- Tratamento de erros
    vr_exc_erro EXCEPTION;

    -- Variaveis de log
    vr_cdcooper INTEGER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cddagenc VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);

    -- Variaveis gerais
    vr_dtiniper crapbdt.dtmvtolt%TYPE;
    vr_dtfimper crapbdt.dtmvtolt%TYPE;
    vr_dstextab craptab.dstextab%TYPE;
    vr_cdagenci crapass.cdagenci%TYPE;
    vr_nrdconta crapass.nrdconta%TYPE;
    vr_nrborder crapbdt.nrborder%TYPE;
    vr_vltitulo NUMBER;
    vr_qt_titulo NUMBER;
    vr_vl_titulo NUMBER;


    vr_nmarquiv VARCHAR2(200);
    vr_dsdireto VARCHAR2(200);
    vr_dscomand VARCHAR2(4000);
    vr_typsaida VARCHAR2(100);


    vr_params VARCHAR2(4000);
    vr_dtacesso        VARCHAR2(10);
    vr_hracesso        VARCHAR2(10);
    vr_nmrescop        VARCHAR2(50);
    vr_nmmodulo        VARCHAR2(50);
    vr_nmrelato        VARCHAR2(50);

    -- variáveis para armazenar as informaçoes em xml
    vr_des_xml        clob;
    vr_txtcompl varchar2(32600);
    vr_index          PLS_INTEGER;

    vr_qtregist       INTEGER;


    vr_nmarqpdf        VARCHAR(400);
    vr_nmjasper        VARCHAR2(50);
    vr_dsxmlnode       VARCHAR2(50);


    -- Busca o nome das agencias
    CURSOR cr_crapage(pr_cdcooper IN crapage.cdcooper%TYPE) IS
     SELECT crapage.cdagenci,
            crapage.nmresage
       FROM crapage
      WHERE crapage.cdcooper = pr_cdcooper;


    -- CURSORES
    -- Buscar os dados
    CURSOR cr_dados(pr_cdcooper crapbdt.cdcooper%TYPE
                   ,pr_dtiniper DATE
                   ,pr_dtfimper DATE) IS
      SELECT bdt.dtmvtolt,
             ass.cdagenci,
             ass.nrdconta,
             bdt.nrborder,
             bdt.dtinsori,
             bdt.hrtransa,
             bdt.cdopeori,
             bdt.insitbdt,
             ope.nmoperad,
             DECODE(bdt.insitbdt, 1, 'EM ESTUDO', 'ANALISADO') dssitbdt,
             COUNT(1) over() qtregistro
        FROM crapbdt bdt,
             crapass ass,
             crapope ope

       WHERE bdt.cdcooper = ass.cdcooper
         AND bdt.nrdconta = ass.nrdconta
         AND bdt.cdcooper = ope.cdcooper(+)
         AND bdt.cdopeori = ope.cdoperad(+)
         AND bdt.cdcooper = pr_cdcooper
         AND bdt.insitbdt IN (1,2) -- 1–Estudo / 2–Analise
         AND bdt.dtmvtolt BETWEEN pr_dtiniper AND pr_dtfimper

    ORDER BY ass.cdagenci,
             bdt.dtmvtolt,
             ass.nrdconta;

    -- Buscar os títulos
    CURSOR cr_craptdb(pr_cdcooper craptdb.cdcooper%TYPE
                     ,pr_nrdconta craptdb.nrdconta%TYPE
                     ,pr_nrborder craptdb.nrborder%TYPE) IS
      SELECT --craptdb.cdbanchq,
             craptdb.vltitulo
        FROM craptdb
       WHERE craptdb.cdcooper = pr_cdcooper
         AND craptdb.nrdconta = pr_nrdconta
         AND craptdb.nrborder = pr_nrborder;

    -- Cursor da data
    rw_crapdat  BTCH0001.cr_crapdat%ROWTYPE;



    -- Subrotina para escrever texto na variável CLOB do XML
    PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR2,
                             pr_fecha_xml IN BOOLEAN DEFAULT FALSE) IS
    BEGIN
      gene0002.pc_escreve_xml(vr_des_xml, vr_txtcompl, pr_des_dados, pr_fecha_xml);
    END;


    begin

      -- Incluir nome do modulo logado
      GENE0001.pc_informa_acesso(pr_module => 'pc_gerar_impressao_titcto_b'
                                ,pr_action => NULL);

      gene0004.pc_extrai_dados( pr_xml      => pr_retxml
                              , pr_cdcooper => vr_cdcooper
                              , pr_nmdatela => vr_nmdatela
                              , pr_nmeacao  => vr_nmeacao
                              , pr_cdagenci => vr_cdagenci
                              , pr_nrdcaixa => vr_nrdcaixa
                              , pr_idorigem => vr_idorigem
                              , pr_cdoperad => vr_cdoperad
                              , pr_dscritic => vr_dscritic);




      -- Busca a data do sistema
      OPEN  BTCH0001.cr_crapdat(vr_cdcooper);
      FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
      CLOSE BTCH0001.cr_crapdat;

      -- Se NAO informou data inicial
      IF TRIM(pr_dtiniper) IS NULL THEN
        vr_cdcritic := 0;
        vr_dscritic := 'Período de Digitação deve ser informado.';
        RAISE vr_exc_erro;
      END IF;

      -- Se NAO informou data final
      IF TRIM(pr_dtfimper) IS NULL THEN
        vr_cdcritic := 0;
        vr_dscritic := 'Período de Digitação deve ser informado.';
        RAISE vr_exc_erro;
      END IF;

      -- Seta as datas
      vr_dtiniper := TO_DATE(pr_dtiniper, 'DD/MM/RRRR');
      vr_dtfimper := TO_DATE(pr_dtfimper, 'DD/MM/RRRR');

      -- Se foi informado intervalo superior a 60 dias
      IF (vr_dtiniper - vr_dtfimper) > 60 THEN
        vr_cdcritic := 0;
        vr_dscritic := 'Informe um intervalo de até 60 dias.';
        RAISE vr_exc_erro;
      END IF;


      -- Busca o nome das agencias
      FOR rw_crapage IN cr_crapage(pr_cdcooper => vr_cdcooper) LOOP
        vr_tab_crapage(rw_crapage.cdagenci).nmresage := rw_crapage.nmresage;
      END LOOP;

      -- Inicializar o CLOB
      vr_des_xml := NULL;
      dbms_lob.createtemporary(vr_des_xml, TRUE);
      dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);

      -- inicilizar as informaçoes do xml
      vr_txtcompl := null;

      -- Seta os valores
      vr_cdagenci := NVL(pr_cdagenci,0);
      vr_nrdconta := NVL(pr_nrdconta,0);
      vr_nrborder := NVL(pr_nrborder,0);

      ------------------------------------------------

      vr_qtregist := 0;


      -- Inicio
      pc_escreve_xml('<?xml version="1.0" encoding="utf-8"?><raiz>' ||
      '<Relat>');


       pc_escreve_xml(
              '<dtiniper>' ||  TO_CHAR(vr_dtiniper, 'DD/MM/RRRR')                || '</dtiniper>' ||
              '<dtfimper>' ||  TO_CHAR(vr_dtfimper, 'DD/MM/RRRR')                || '</dtfimper>' ||
              '<cdagenci>' ||  (CASE WHEN vr_cdagenci = 0 THEN '0 - TODOS' ELSE TO_CHAR(vr_cdagenci) END)             || '</cdagenci>' ||
              '<nrdconta>' ||  (CASE WHEN vr_nrdconta = 0 THEN '0 - TODAS' ELSE TRIM(GENE0002.fn_mask_conta(TO_CHAR(vr_nrdconta))) END) || '</nrdconta>' ||
              '<nrborder>' ||  (CASE WHEN vr_nrborder = 0 THEN '0 - TODOS' ELSE TRIM(GENE0002.fn_mask_contrato(TO_CHAR(vr_nrborder))) END)     || '</nrborder>'
      );

      -- Buscar os dados
      FOR rw_dados IN cr_dados(pr_cdcooper => vr_cdcooper
                              ,pr_dtiniper => vr_dtiniper
                              ,pr_dtfimper => vr_dtfimper) LOOP

        -- Se foi informado agencia e for diferente vai para o proximo
        IF vr_cdagenci > 0 AND vr_cdagenci <> rw_dados.cdagenci THEN
          CONTINUE;
        END IF;

        -- Se foi informado conta e for diferente vai para o proximo
        IF vr_nrdconta > 0 AND vr_nrdconta <> rw_dados.nrdconta THEN
          CONTINUE;
        END IF;

        -- Se foi informado bordero e for diferente vai para o proximo
        IF vr_nrborder > 0 AND vr_nrborder <> rw_dados.nrborder THEN
          CONTINUE;
        END IF;

        -- Reseta os valores
        vr_qt_titulo := 0;
        vr_vl_titulo := 0;


        -- Buscar os titulos
        FOR rw_craptdb IN cr_craptdb(pr_cdcooper => vr_cdcooper
                                    ,pr_nrdconta => rw_dados.nrdconta
                                    ,pr_nrborder => rw_dados.nrborder) LOOP

            vr_qt_titulo := vr_qt_titulo + 1;
            vr_vl_titulo := vr_vl_titulo + rw_craptdb.vltitulo;

        END LOOP;

        pc_escreve_xml('<Bordero>'||
                         '<dtmvtolt>'|| TO_CHAR(rw_dados.dtmvtolt, 'DD/MM/RRRR') ||'</dtmvtolt>'||
                         '<cdagenci>'|| rw_dados.cdagenci ||'</cdagenci>'||
                         '<nmresage>'|| vr_tab_crapage(rw_dados.cdagenci).nmresage ||'</nmresage>'||
                         '<nrdconta>'|| TRIM(GENE0002.fn_mask_conta(rw_dados.nrdconta)) ||'</nrdconta>'||
                         '<nrborder>'|| TRIM(GENE0002.fn_mask_contrato(rw_dados.nrborder)) ||'</nrborder>'||
                         '<dat_real>'|| TO_CHAR(NVL(rw_dados.dtinsori, rw_dados.dtmvtolt), 'DD/MM/RRRR') ||'</dat_real>'||
                         '<hor_real>'|| GENE0002.fn_converte_time_data(rw_dados.hrtransa) ||'</hor_real>'||
                         '<qt_titulo>'|| vr_qt_titulo ||'</qt_titulo>'||
                         '<vl_titulo>'|| TO_CHAR(vr_vl_titulo,'fm999G999G999G990D00') ||'</vl_titulo>'||
                         '<nmoperad>'|| SUBSTR(rw_dados.nmoperad, 1, 29) ||'</nmoperad>'||
                         '<dssitbdt>'|| rw_dados.dssitbdt ||'</dssitbdt>'||
                       '</Bordero>');


         vr_qtregist := vr_qtregist + 1;
    END LOOP;



    -- Final
    pc_escreve_xml('</Relat></raiz>',TRUE);

    -- Buscar diretorio da cooperativa
    vr_dsdireto := GENE0001.fn_diretorio(pr_tpdireto => 'C' --> cooper
                                        ,pr_cdcooper => vr_cdcooper
                                        ,pr_nmsubdir => '/rl');


    IF TRIM(vr_nmarquiv) IS NOT NULL THEN
      -- Remover arquivo existente
      vr_dscomand := 'rm '||vr_dsdireto||'/'||vr_nmarquiv||'* 2>/dev/null';

      -- Executar o comando no unix
      GENE0001.pc_OScommand(pr_typ_comando => 'S'
                           ,pr_des_comando => vr_dscomand
                           ,pr_typ_saida   => vr_typsaida
                           ,pr_des_saida   => vr_dscritic);
      -- Se ocorreu erro
      IF vr_typsaida = 'ERR' THEN
        vr_dscritic := 'Nao foi possivel remover arquivos: '||vr_dscomand||'. Erro: '||vr_dscritic;
        RAISE vr_exc_erro;
      END IF;
    END IF;

    vr_nmjasper := 'crrl802_titcto.jasper';
    vr_dsxmlnode := '/raiz';

    --> Montar nome do arquivo
    vr_nmarqpdf := vr_nmarquiv || gene0002.fn_busca_time || '.pdf';


    --> PARAMETROS
    vr_nmmodulo := 'GENÉRICO';
    vr_nmrelato := 'BORDERÔS NÃO LIBERADOS';
    vr_dtacesso := to_char(sysdate, 'DD/MM/RRRR');
    vr_hracesso := to_char(sysdate, 'HH24:MI');


    vr_params := 'PR_QTDREGISTRO##' || vr_qtregist || '@@' ||
                 'PR_NMRELATO##' || vr_nmrelato || '@@' ||
                 'PR_NMMODULO##' || vr_nmmodulo || '@@' ||
                 'PR_DTACESSO##' || vr_dtacesso || '@@' ||
                 'PR_HRACESSO##' || vr_hracesso || '@@' ||
                 'PR_DTINIPER##' || TO_CHAR(vr_dtiniper, 'DD/MM/RRRR') || '@@' ||
                 'PR_DTFIMPER##' || TO_CHAR(vr_dtfimper, 'DD/MM/RRRR') || '@@' ||
                 'PR_CDAGENCI##' || (CASE WHEN vr_cdagenci = 0 THEN '0 - TODOS' ELSE TO_CHAR(vr_cdagenci) END) || '@@' ||
                 'PR_NRDCONTA##' || (CASE WHEN vr_nrdconta = 0 THEN '0 - TODAS' ELSE TRIM(GENE0002.fn_mask_conta(TO_CHAR(vr_nrdconta))) END) || '@@' ||
                 'PR_NRBORDER##' || (CASE WHEN vr_nrborder = 0 THEN '0 - TODOS' ELSE TRIM(GENE0002.fn_mask_contrato(TO_CHAR(vr_nrborder))) END);

    --> Solicita geracao do PDF
    gene0002.pc_solicita_relato(pr_cdcooper   => vr_cdcooper
                               , pr_cdprogra  => 'TITCTO'
                               , pr_dtmvtolt  => rw_crapdat.dtmvtolt
                               , pr_dsxml     => vr_des_xml
                               , pr_dsxmlnode => vr_dsxmlnode
                               , pr_dsjasper  => vr_nmjasper
                               , pr_dsparams  => vr_params
                               , pr_dsarqsaid => vr_dsdireto || '/' || vr_nmarqpdf
                               , pr_cdrelato => 802
                               , pr_flg_gerar => 'S'
                               , pr_qtcoluna  => 234
                               , pr_sqcabrel  => 1
                               , pr_flg_impri => 'N'
                               , pr_nmformul  => ' '
                               , pr_nrcopias  => 1
                               , pr_nrvergrl  => 1
                               , pr_des_erro  => vr_dscritic);



      IF vr_dscritic IS NOT NULL THEN -- verifica retorno se houve erro
        RAISE vr_exc_erro; -- encerra programa
      END IF;

      IF vr_idorigem = 5 THEN

        -- Copia contrato PDF do diretorio da cooperativa para servidor WEB
        GENE0002.pc_efetua_copia_pdf(pr_cdcooper => vr_cdcooper
                                    ,pr_cdagenci => NULL
                                    ,pr_nrdcaixa => NULL
                                    ,pr_nmarqpdf => vr_dsdireto ||'/'||vr_nmarqpdf
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
                           ,pr_des_comando => 'rm '||vr_dsdireto ||'/'||vr_nmarqpdf
                           ,pr_typ_saida   => vr_typsaida
                           ,pr_des_saida   => vr_dscritic);


      -- Se retornou erro
      IF vr_typsaida = 'ERR' OR vr_dscritic IS NOT NULL THEN
        -- Concatena o erro que veio
        vr_dscritic := 'Erro ao remover arquivo: '||vr_dscritic;
        RAISE vr_exc_erro; -- encerra programa
      END IF;

      END IF; -- pr_idorigem = 5

      -- Criar cabecalho do XML
      pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');

      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Root'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'Dados'
                            ,pr_tag_cont => NULL
                            ,pr_des_erro => vr_dscritic);

      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Dados'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'nmarqpdf'
                            ,pr_tag_cont => vr_nmarqpdf
                            ,pr_des_erro => vr_dscritic);

    exception
      when vr_exc_erro then
           /*  se foi retornado apenas código */
           if  nvl(vr_cdcritic,0) > 0 and vr_dscritic is null then
               /* buscar a descriçao */
               vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
           end if;
           /* variavel de erro recebe erro ocorrido */
           pr_cdcritic := nvl(vr_cdcritic,0);
           pr_dscritic := vr_dscritic;
      when others then
           /* montar descriçao de erro nao tratado */
           pr_dscritic := 'erro nao tratado na tela_titcto.pc_gerar_impressao_titcto_b ' ||sqlerrm;
  END pc_gerar_impressao_titcto_b;


  PROCEDURE pc_gerar_impressao_titcto_c(
                                        pr_nrdconta in  crapass.nrdconta%type --> conta do associado
                                        ,pr_tpcobran    IN CHAR                  --> Filtro de tipo de cobranca
                                        ,pr_flresgat    IN CHAR                  --> Filtro de Resgatados
                                        ,pr_dtmvtolt IN VARCHAR2
                                        ,pr_xmllog   IN VARCHAR2           --> XML com informações de LOG
                                        ,pr_cdcritic out pls_integer           --> codigo da critica
                                        ,pr_dscritic out varchar2              --> descricao da critica
                                        ,pr_retxml   in  out nocopy xmltype    --> arquivo de retorno do xml
                                        ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                                        ,pr_des_erro OUT VARCHAR2      --> Erros do processo
                                      ) is

    -- variaveis de retorno
    vr_tab_dados_titcto typ_tab_dados_titcto;

    vr_tab_erro         gene0001.typ_tab_erro;
    vr_qtregist         number;
    vr_des_reto varchar2(3);

    -- variaveis de entrada vindas no xml
    vr_cdcooper integer;
    vr_cdoperad varchar2(100);
    vr_nmdatela varchar2(100);
    vr_nmeacao  varchar2(100);
    vr_cdagenci varchar2(100);
    vr_nrdcaixa varchar2(100);
    vr_idorigem varchar2(100);

    -- variáveis para armazenar as informaçoes em xml
    vr_des_xml        clob;
    vr_texto_completo varchar2(32600);
    vr_index          PLS_INTEGER;


    vr_dstitulo varchar2(300);
    vr_nmjasper        VARCHAR2(50);
    vr_dsxmlnode       VARCHAR2(50);
    vr_nmarquiv        Varchar2(200);
    vr_dsdireto        Varchar2(200);
    vr_dsmailcop       VARCHAR2(4000);
    vr_dsassmail       VARCHAR2(4000);
    vr_dscormail       VARCHAR2(4000);

    vr_nmarqpdf        VARCHAR(400);
    vr_typsaida        VARCHAR2(100);

    vr_params          VARCHAR2(4000);
    vr_nmtitula        VARCHAR2(200);
    vr_dtacesso        VARCHAR2(10);
    vr_hracesso        VARCHAR2(10);
    vr_nmrescop        VARCHAR2(50);
    vr_nmmodulo        VARCHAR2(50);
    vr_nmrelato        VARCHAR2(50);
    vr_qtdtotal        VARCHAR2(50);

    -- CURSOR PARA OBTER OS DADOS DO ASSOCIADO
    CURSOR cr_crapass IS
         select nmprimtl
               ,inpessoa
               ,nrdconta
               ,nrcpfcgc
         from   crapass
         where
                crapass.cdcooper = vr_cdcooper
                AND    crapass.nrdconta = pr_nrdconta;

       rw_crapass cr_crapass%rowtype;


     -- CURSOR PARA OBTER OS DADOS DA COOPERATIVA
    CURSOR cr_crapcop IS
      SELECT cop.nmrescop
            ,cop.nmextcop
            ,cop.nrdocnpj
            ,cop.dsendcop
            ,cop.nrendcop
            ,cop.nmbairro
            ,cop.nmcidade
            ,cop.cdufdcop
            ,cop.nrcepend
            ,cop.nrtelsac
            ,cop.nrtelouv
            ,cop.dsendweb
        FROM crapcop cop
       WHERE cop.cdcooper = vr_cdcooper;

    rw_crapcop cr_crapcop%ROWTYPE;

    procedure pc_escreve_xml( pr_des_dados in varchar2
                            , pr_fecha_xml in boolean default false
                            ) is
    begin
        gene0002.pc_escreve_xml( vr_des_xml
                               , vr_texto_completo
                               , pr_des_dados
                               , pr_fecha_xml );
    end;


    begin
      gene0004.pc_extrai_dados( pr_xml      => pr_retxml
                              , pr_cdcooper => vr_cdcooper
                              , pr_nmdatela => vr_nmdatela
                              , pr_nmeacao  => vr_nmeacao
                              , pr_cdagenci => vr_cdagenci
                              , pr_nrdcaixa => vr_nrdcaixa
                              , pr_idorigem => vr_idorigem
                              , pr_cdoperad => vr_cdoperad
                              , pr_dscritic => vr_dscritic);


      pc_obtem_dados_titcto( vr_cdcooper,
                                        pr_nrdconta,
                                        pr_tpcobran,
                                        pr_flresgat,
                                        --> out
                                        vr_qtregist,
                                        vr_tab_dados_titcto,
                                        pr_cdcritic,
                                        pr_dscritic
                               );

     OPEN cr_crapass;
     FETCH cr_crapass into rw_crapass;
     CLOSE cr_crapass;

     OPEN cr_crapcop;
     FETCH cr_crapcop into rw_crapcop;
     CLOSE cr_crapcop;


      if  vr_des_reto = 'NOK' then
          if  vr_tab_erro.exists(vr_tab_erro.first) then
              vr_dscritic := vr_tab_erro(vr_tab_erro.first).dscritic;
              vr_cdcritic := vr_tab_erro(vr_tab_erro.first).cdcritic;
          else
              vr_dscritic := 'nao foi possivel obter dados de titcto.';

          end if;

          raise vr_exc_erro;
      end if;


      -- inicializar o clob
      vr_des_xml := null;
      dbms_lob.createtemporary(vr_des_xml, true);
      dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
      -- inicilizar as informaçoes do xml
      vr_texto_completo := null;


      --> INICIO
      vr_nmmodulo := 'TITCTO';
      vr_nmrelato := 'Opção Consulta';
      vr_dstitulo := 'Consulta de títulos descontados que não foram pagos';
      vr_nmrescop := rw_crapcop.nmrescop;
      vr_dtacesso := to_char(sysdate, 'DD/MM/RRRR');
      vr_hracesso := to_char(sysdate, 'HH24:MI');

      pc_escreve_xml('<?xml version="1.0" encoding="utf-8"?><raiz>');
      pc_escreve_xml(
                            '<dtacesso>' ||  vr_dtacesso             || '</dtacesso>' ||
                            '<hracesso>' ||  vr_hracesso             || '</hracesso>' ||
                            '<dstitulo>' ||  vr_dstitulo             || '</dstitulo>' ||
                            '<nrdconta>' || TRIM(gene0002.fn_mask(pr_nrdconta,'zzzz.zzz.z')) || '</nrdconta>' ||
                            '<nmtitula>' || rw_crapass.nmprimtl     || '</nmtitula>' ||
                            '<nrcpfcgc>' || rw_crapass.nrcpfcgc     || '</nrcpfcgc>' ||
                            '<qtregist>' || vr_qtregist             || '</qtregist>'
      );

       -- ler os registros de titcto e incluir no xml
      vr_index := vr_tab_dados_titcto.first;

      while vr_index is not null loop

          pc_escreve_xml(
            '<titulo>' ||
                     '<dtlibbdt>' || to_char(vr_tab_dados_titcto(vr_index).dtlibbdt,'dd/mm/rrrr') || '</dtlibbdt>' ||
                     '<dtvencto>' || to_char(vr_tab_dados_titcto(vr_index).dtvencto,'dd/mm/rrrr') || '</dtvencto>' ||
                     '<nrborder>' || vr_tab_dados_titcto(vr_index).nrborder || '</nrborder>'      ||
                     '<cdbandoc>' || vr_tab_dados_titcto(vr_index).cdbandoc || '</cdbandoc>'      ||
                     '<nrcnvcob>' || vr_tab_dados_titcto(vr_index).nrcnvcob || '</nrcnvcob>'      ||
                     '<nrdocmto>' || vr_tab_dados_titcto(vr_index).nrdocmto || '</nrdocmto>'      ||
                     '<vltitulo>' || vr_tab_dados_titcto(vr_index).vltitulo || '</vltitulo>'      ||
                     '<dtresgat>' || to_char(vr_tab_dados_titcto(vr_index).dtresgat,'dd/mm/rrrr') || '</dtresgat>' ||
                     '<cdoperad>' || vr_tab_dados_titcto(vr_index).cdoperad || '</cdoperad>'      ||
                     '<nmoperad>' || vr_tab_dados_titcto(vr_index).nmoperad || '</nmoperad>'      ||
                     '<dsoperes>' || vr_tab_dados_titcto(vr_index).dsoperes || '</dsoperes>'      ||
                     '<tpcobran>' || vr_tab_dados_titcto(vr_index).tpcobran || '</tpcobran>'      ||
                     '<nrdconta>' || TRIM(gene0002.fn_mask(vr_tab_dados_titcto(vr_index).nrdconta,'zzzz.zzz.z'))  || '</nrdconta>'      ||
                     '<nmprimt>'  || vr_tab_dados_titcto(vr_index).nmprimt  || '</nmprimt>'       ||
            '</titulo>'
           );

           vr_qtdtotal := vr_qtdtotal + vr_tab_dados_titcto(vr_index).vltitulo;

          vr_index := vr_tab_dados_titcto.next(vr_index);
      end loop;
      pc_escreve_xml('</raiz>',TRUE);

      --Buscar diretorio da cooperativa
    vr_dsdireto := gene0001.fn_diretorio( pr_tpdireto => 'C' --> cooper
                                         ,pr_cdcooper => vr_cdcooper
                                         ,pr_nmsubdir => '/rl');

      vr_nmjasper := 'crrl800_titcto.jasper';
      vr_dsxmlnode := '/raiz';

    --> Montar nome do arquivo
    vr_nmarqpdf := vr_nmarquiv || gene0002.fn_busca_time || '.pdf';


    vr_params := 'PR_NMRESCOP##' || vr_nmrescop || '@@' ||
                 'PR_NMRELATO##' || vr_nmrelato || '@@' ||
                 'PR_DTMVTOLT##' || pr_dtmvtolt || '@@' ||
                 'PR_NMMODULO##' || vr_nmmodulo || '@@' ||
                 'PR_DTACESSO##' || vr_dtacesso || '@@' ||
                 'PR_HRACESSO##' || vr_hracesso || '@@' ||
                 'PR_QTREGIST##' || vr_qtregist || '@@' ||
                 'PR_VLRTOTAL##' || vr_qtdtotal;

      --> Solicita geracao do PDF
    gene0002.pc_solicita_relato(pr_cdcooper   => vr_cdcooper
                               , pr_cdprogra  => 'TITCTO'
                               , pr_dtmvtolt  => to_date(pr_dtmvtolt, 'DD/MM/RRRR') --> alterar para pegar param procedure
                               , pr_dsxml     => vr_des_xml
                               , pr_dsxmlnode => vr_dsxmlnode
                               , pr_dsjasper  => vr_nmjasper
                               , pr_dsparams  => vr_params
                               , pr_dsarqsaid => vr_dsdireto || '/' || vr_nmarqpdf
                               , pr_cdrelato => 800
                               , pr_flg_gerar => 'S'
                               , pr_qtcoluna  => 132 --> verificar esse param
                               , pr_sqcabrel  => 1
                               , pr_flg_impri => 'N'
                               , pr_nmformul  => ' '
                               , pr_nrcopias  => 1
                               , pr_nrvergrl  => 1
                               , pr_dsextmail => NULL
                               , pr_dsmailcop => vr_dsmailcop
                               , pr_dsassmail => vr_dsassmail
                               , pr_dscormail => vr_dscormail
                               , pr_des_erro  => vr_dscritic);

    IF vr_dscritic IS NOT NULL THEN -- verifica retorno se houve erro
      RAISE vr_exc_erro; -- encerra programa
    END IF;



    -- AXAO
    IF vr_idorigem = 5 THEN

        -- Copia contrato PDF do diretorio da cooperativa para servidor WEB
        GENE0002.pc_efetua_copia_pdf(pr_cdcooper => vr_cdcooper
                                    ,pr_cdagenci => NULL
                                    ,pr_nrdcaixa => NULL
                                    ,pr_nmarqpdf => vr_dsdireto ||'/'||vr_nmarqpdf
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
                             ,pr_des_comando => 'rm '||vr_dsdireto ||'/'||vr_nmarqpdf
                             ,pr_typ_saida   => vr_typsaida
                             ,pr_des_saida   => vr_dscritic);
        -- Se retornou erro
        IF vr_typsaida = 'ERR' OR vr_dscritic IS NOT NULL THEN
          -- Concatena o erro que veio
          vr_dscritic := 'Erro ao remover arquivo: '||vr_dscritic;
          RAISE vr_exc_erro; -- encerra programa
        END IF;

      END IF; -- pr_idorigem = 5




    -- Criar cabecalho do XML
      pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');

      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Root'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'Dados'
                            ,pr_tag_cont => NULL
                            ,pr_des_erro => vr_dscritic);

      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Dados'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'nmarqpdf'
                            ,pr_tag_cont => vr_nmarqpdf
                            ,pr_des_erro => vr_dscritic);

    exception
      when vr_exc_erro then
           /*  se foi retornado apenas código */
           if  nvl(vr_cdcritic,0) > 0 and vr_dscritic is null then
               /* buscar a descriçao */
               vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
           end if;
           /* variavel de erro recebe erro ocorrido */
           pr_cdcritic := nvl(vr_cdcritic,0);
           pr_dscritic := vr_dscritic;
      when others then
           /* montar descriçao de erro nao tratado */
           pr_dscritic := 'erro nao tratado na tela_titcto.pc_obtem_dados_titcto_web ' ||sqlerrm;
  END pc_gerar_impressao_titcto_c;

  PROCEDURE pc_gerar_impressao_titcto_l(pr_dtmvtolt IN VARCHAR2
                                        ,pr_cdagenci IN INTEGER                   --> Numero do PA
                                        ,pr_xmllog   IN VARCHAR2           --> XML com informações de LOG
                                        ,pr_cdcritic out pls_integer           --> codigo da critica
                                        ,pr_dscritic out varchar2              --> descricao da critica
                                        ,pr_retxml   in  out nocopy xmltype    --> arquivo de retorno do xml
                                        ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                                        ,pr_des_erro OUT VARCHAR2      --> Erros do processo
                                      ) is

    -- variaveis de retorno
    vr_tab_dados_titcto typ_tab_dados_lotes;

    vr_tab_erro         gene0001.typ_tab_erro;
    vr_qtregist         number;
    vr_des_reto varchar2(3);

    -- variaveis de entrada vindas no xml
    vr_cdcooper integer;
    vr_cdoperad varchar2(100);
    vr_nmdatela varchar2(100);
    vr_nmeacao  varchar2(100);
    vr_cdagenci varchar2(100);
    vr_nrdcaixa varchar2(100);
    vr_idorigem varchar2(100);

    -- variáveis para armazenar as informaçoes em xml
    vr_des_xml        clob;
    vr_texto_completo varchar2(32600);
    vr_index          PLS_INTEGER;


    vr_dstitulo varchar2(300);
    vr_nmjasper        VARCHAR2(50);
    vr_dsxmlnode       VARCHAR2(50);
    vr_nmarquiv        Varchar2(200);
    vr_dsdireto        Varchar2(200);
    vr_dsmailcop       VARCHAR2(4000);
    vr_dsassmail       VARCHAR2(4000);
    vr_dscormail       VARCHAR2(4000);

    vr_nmarqpdf        VARCHAR(400);
    vr_typsaida        VARCHAR2(100);

    vr_params          VARCHAR2(4000);
    vr_nmtitula        VARCHAR2(200);
    vr_dtacesso        VARCHAR2(10);
    vr_hracesso        VARCHAR2(10);
    vr_nmrescop        VARCHAR2(50);
    vr_nmmodulo        VARCHAR2(50);
    vr_nmrelato        VARCHAR2(50);
    vr_qtdtotal        VARCHAR2(50);

    vr_dtmvtsys        VARCHAR2(20);

     -- CURSOR PARA OBTER OS DADOS DA COOPERATIVA
    CURSOR cr_crapcop IS
      SELECT cop.nmrescop
            ,cop.nmextcop
            ,cop.nrdocnpj
            ,cop.dsendcop
            ,cop.nrendcop
            ,cop.nmbairro
            ,cop.nmcidade
            ,cop.cdufdcop
            ,cop.nrcepend
            ,cop.nrtelsac
            ,cop.nrtelouv
            ,cop.dsendweb
        FROM crapcop cop
       WHERE cop.cdcooper = vr_cdcooper;

    rw_crapcop cr_crapcop%ROWTYPE;

    rw_crapdat btch0001.cr_crapdat%rowtype;

    procedure pc_escreve_xml( pr_des_dados in varchar2
                            , pr_fecha_xml in boolean default false
                            ) is
    begin
        gene0002.pc_escreve_xml( vr_des_xml
                               , vr_texto_completo
                               , pr_des_dados
                               , pr_fecha_xml );
    end;


    begin
      gene0004.pc_extrai_dados( pr_xml      => pr_retxml
                              , pr_cdcooper => vr_cdcooper
                              , pr_nmdatela => vr_nmdatela
                              , pr_nmeacao  => vr_nmeacao
                              , pr_cdagenci => vr_cdagenci
                              , pr_nrdcaixa => vr_nrdcaixa
                              , pr_idorigem => vr_idorigem
                              , pr_cdoperad => vr_cdoperad
                              , pr_dscritic => vr_dscritic);


      pc_obtem_dados_lotes( vr_cdcooper
                           ,pr_dtmvtolt
                           ,pr_cdagenci
                           --> out
                           ,vr_qtregist
                           ,vr_tab_dados_titcto
                           ,pr_cdcritic
                           ,pr_dscritic);



     OPEN cr_crapcop;
     FETCH cr_crapcop into rw_crapcop;
     CLOSE cr_crapcop;


     OPEN  btch0001.cr_crapdat(pr_cdcooper => vr_cdcooper);
        FETCH btch0001.cr_crapdat into rw_crapdat;
        IF    btch0001.cr_crapdat%notfound then
              CLOSE btch0001.cr_crapdat;
              vr_cdcritic := 1;
              raise vr_exc_erro;
        END   IF;
        CLOSE btch0001.cr_crapdat;


     vr_dtmvtsys := to_char(rw_crapdat.dtmvtolt, 'DD/MM/RRRR');


      if  vr_des_reto = 'NOK' then
          if  vr_tab_erro.exists(vr_tab_erro.first) then
              vr_dscritic := vr_tab_erro(vr_tab_erro.first).dscritic;
              vr_cdcritic := vr_tab_erro(vr_tab_erro.first).cdcritic;
          else
              vr_dscritic := 'nao foi possivel obter dados de titcto.';

          end if;

          raise vr_exc_erro;
      end if;


      -- inicializar o clob
      vr_des_xml := null;
      dbms_lob.createtemporary(vr_des_xml, true);
      dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
      -- inicilizar as informaçoes do xml
      vr_texto_completo := null;


        --> INICIO
      vr_nmmodulo := 'TITCTO';
      vr_nmrelato := 'Opção Lotes';
      vr_dstitulo := 'Listagem de lotes de descontos de titulos efetuados na data';
      vr_nmrescop := rw_crapcop.nmrescop;
      vr_dtacesso := to_char(sysdate, 'DD/MM/RRRR');
      vr_hracesso := to_char(sysdate, 'HH24:MI');

      pc_escreve_xml('<?xml version="1.0" encoding="utf-8"?><raiz>');

      pc_escreve_xml('<cdagenci>' ||  pr_cdagenci || '</cdagenci>' ||
                     '<qtregist>' || vr_qtregist  || '</qtregist>'
                    );


       -- ler os registros de titcto e incluir no xml
      vr_index := vr_tab_dados_titcto.first;

      while vr_index is not null loop

          pc_escreve_xml(
            '<lote>' ||
                            '<dtmvtolt>'     ||  NVL(TO_CHAR(vr_tab_dados_titcto(vr_index).dtmvtolt,'DD/MM/RRRR'), '')       || '</dtmvtolt>'     ||
                            '<cdagenci>'    ||  vr_tab_dados_titcto(vr_index).cdagenci              || '</cdagenci>'         ||
                            '<nrdolote>'    ||  gene0002.fn_mask(to_char(vr_tab_dados_titcto(vr_index).nrdolote),'zzz.zz9') || '</nrdolote>'     ||
                            '<nrdconta>'    ||  TRIM(gene0002.fn_mask(vr_tab_dados_titcto(vr_index).nrdconta,'zzzz.zzz.z')) || '</nrdconta>'     ||
                            '<nrborder>'    ||  TRIM(GENE0002.fn_mask_contrato(vr_tab_dados_titcto(vr_index).nrborder))     || '</nrborder>'     ||
                            '<qttittot_cr>' ||  vr_tab_dados_titcto(vr_index).qttittot_cr           || '</qttittot_cr>'     ||
                            '<qttittot_sr>' ||  vr_tab_dados_titcto(vr_index).qttittot_sr           || '</qttittot_sr>'     ||
                            '<vltittot_cr>' ||  vr_tab_dados_titcto(vr_index).vltittot_cr           || '</vltittot_cr>'     ||
                            '<vltittot_sr>' ||  vr_tab_dados_titcto(vr_index).vltittot_sr           || '</vltittot_sr>'     ||
                            '<nmoperad>'    ||  vr_tab_dados_titcto(vr_index).nmoperad              || '</nmoperad>'        ||
            '</lote>'
           );

          vr_index := vr_tab_dados_titcto.next(vr_index);
      end loop;
      pc_escreve_xml('</raiz>',TRUE);

      --Buscar diretorio da cooperativa
    vr_dsdireto := gene0001.fn_diretorio( pr_tpdireto => 'C' --> cooper
                                         ,pr_cdcooper => vr_cdcooper
                                         ,pr_nmsubdir => '/rl');

      vr_nmjasper := 'crrl801_titcto.jasper';
      vr_dsxmlnode := '/raiz';

    --> Montar nome do arquivo
    vr_nmarqpdf := vr_nmarquiv || gene0002.fn_busca_time || '.pdf';


    vr_params := 'PR_NMRESCOP##' || vr_nmrescop || '@@' ||
                 'PR_NMRELATO##' || vr_nmrelato || '@@' ||
                 'PR_DTMVTOLT##' || vr_dtmvtsys || '@@' ||
                 'PR_NMMODULO##' || vr_nmmodulo || '@@' ||
                 'PR_DTACESSO##' || vr_dtacesso || '@@' ||
                 'PR_HRACESSO##' || vr_hracesso || '@@' ||
                 'PR_QTREGIST##' || vr_qtregist || '@@' ||
                 'PR_CDAGENCI##' || pr_cdagenci || '@@' ||
                 'PR_VLRTOTAL##' || vr_qtdtotal;

      --> Solicita geracao do PDF
    gene0002.pc_solicita_relato(pr_cdcooper   => vr_cdcooper
                               , pr_cdprogra  => 'TITCTO'
                               , pr_dtmvtolt  => to_date(pr_dtmvtolt, 'DD/MM/RRRR')
                               , pr_dsxml     => vr_des_xml
                               , pr_dsxmlnode => vr_dsxmlnode
                               , pr_dsjasper  => vr_nmjasper
                               , pr_dsparams  => vr_params
                               , pr_dsarqsaid => vr_dsdireto || '/' || vr_nmarqpdf
                               , pr_cdrelato => 800
                               , pr_flg_gerar => 'S'
                               , pr_qtcoluna  => 132 --> verificar esse param
                               , pr_sqcabrel  => 1
                               , pr_flg_impri => 'N'
                               , pr_nmformul  => ' '
                               , pr_nrcopias  => 1
                               , pr_nrvergrl  => 1
                               , pr_dsextmail => NULL
                               , pr_dsmailcop => vr_dsmailcop
                               , pr_dsassmail => vr_dsassmail
                               , pr_dscormail => vr_dscormail
                               , pr_des_erro  => vr_dscritic);

    IF vr_dscritic IS NOT NULL THEN -- verifica retorno se houve erro
      RAISE vr_exc_erro; -- encerra programa
    END IF;



    -- AXAO
    IF vr_idorigem = 5 THEN

        -- Copia contrato PDF do diretorio da cooperativa para servidor WEB
        GENE0002.pc_efetua_copia_pdf(pr_cdcooper => vr_cdcooper
                                    ,pr_cdagenci => NULL
                                    ,pr_nrdcaixa => NULL
                                    ,pr_nmarqpdf => vr_dsdireto ||'/'||vr_nmarqpdf
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
                             ,pr_des_comando => 'rm '||vr_dsdireto ||'/'||vr_nmarqpdf
                             ,pr_typ_saida   => vr_typsaida
                             ,pr_des_saida   => vr_dscritic);
        -- Se retornou erro
        IF vr_typsaida = 'ERR' OR vr_dscritic IS NOT NULL THEN
          -- Concatena o erro que veio
          vr_dscritic := 'Erro ao remover arquivo: '||vr_dscritic;
          RAISE vr_exc_erro; -- encerra programa
        END IF;

      END IF; -- pr_idorigem = 5




    -- Criar cabecalho do XML
      pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');

      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Root'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'Dados'
                            ,pr_tag_cont => NULL
                            ,pr_des_erro => vr_dscritic);

      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Dados'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'nmarqpdf'
                            ,pr_tag_cont => vr_nmarqpdf
                            ,pr_des_erro => vr_dscritic);

    exception
      when vr_exc_erro then
           /*  se foi retornado apenas código */
           if  nvl(vr_cdcritic,0) > 0 and vr_dscritic is null then
               /* buscar a descriçao */
               vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
           end if;
           /* variavel de erro recebe erro ocorrido */
           pr_cdcritic := nvl(vr_cdcritic,0);
           pr_dscritic := vr_dscritic;
      when others then
           /* montar descriçao de erro nao tratado */
           pr_dscritic := 'erro nao tratado na tela_titcto.pc_obtem_dados_titcto_web ' ||sqlerrm;
  END pc_gerar_impressao_titcto_l;
  
  
  PROCEDURE pc_consulta_pagador_remetente (pr_cdcooper    IN crapcop.cdcooper%TYPE, --> Código da Cooperativa
                                    pr_nrdconta    IN crapass.nrdconta%TYPE, --> Número da Conta
                                    pr_tpcobran    IN CHAR,                  --> Filtro de tipo de cobranca
                                    --> out
                                    pr_qtregist         out integer,         --> Quantidade de registros encontrados
                                    pr_tab_dados_titcto   out  typ_tab_dados_titcto, --> Tabela de retorno
                                    pr_cdcritic out number,                         --> codigo da critica
                                    pr_dscritic out varchar2                        --> descricao da critica.                    
                                ) is
    
    ----------------------------------------------------------------------------------
    --
    -- Procedure: pc_consulta_pagador_remetente
    -- Sistema  : CRED
    -- Sigla    : TELA_TITCTO
    -- Autor    : Luis Fernando - Company: GFT
    -- Data     : Criação: 04/04/2018    
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: Sempre que chamado
    -- Objetivo  : Trazer os titulos onde o cooperado é o pagador
    ----------------------------------------------------------------------------------
    
    vr_idtabtitcto PLS_INTEGER;
    aux_flregis INTEGER;
    /*Cursor dos titulos*/
    CURSOR cr_craptdb IS
      SELECT 
           craptdb.dtlibbdt AS dtlibbdt,
           craptdb.dtvencto AS dtvencto,
           craptdb.nrborder AS nrborder,
           craptdb.cdbandoc AS cdbandoc,
           craptdb.nrcnvcob AS nrcnvcob,
           craptdb.nrdocmto AS nrdocmto,
           craptdb.vltitulo AS vltitulo,
           crapcob.flgregis AS flgregis,
           craptdb.nrdconta AS nrdconta,
           crapass.nmprimtl AS nmprimtl
      FROM 
           craptdb 
           INNER JOIN crapcob ON craptdb.cdcooper = crapcob.cdcooper AND
                                             craptdb.cdbandoc = crapcob.cdbandoc AND
                                             craptdb.nrdctabb = crapcob.nrdctabb AND
                                             craptdb.nrcnvcob = crapcob.nrcnvcob AND
                                             craptdb.nrdconta = crapcob.nrdconta AND
                                             craptdb.nrdocmto = crapcob.nrdocmto AND
                                             (pr_tpcobran='T' OR crapcob.flgregis=aux_flregis)
           LEFT JOIN crapass ON crapass.nrdconta=craptdb.nrdconta AND crapass.cdcooper = craptdb.cdcooper
      WHERE 
           craptdb.nrinssac = (SELECT nrcpfcgc FROM crapass WHERE nrdconta = pr_nrdconta and cdcooper = pr_cdcooper) 
           AND craptdb.cdcooper = pr_cdcooper
           AND craptdb.insittit=4 -- apenas titulos liberados
      ORDER BY crapcob.flgregis DESC, crapcob.cdbandoc DESC, crapcob.nrdconta;
      
      rw_craptdb cr_craptdb%ROWTYPE;
    
    BEGIN
      -- Incluir nome do modulo logado
        GENE0001.pc_informa_acesso(pr_module => 'TELA_TITCTO'
                              ,pr_action => NULL);

      -- Começa a listagem da tabela
         pr_qtregist:= 0;
         IF (pr_tpcobran='S') THEN
           aux_flregis := 0;
         ELSE 
           IF (pr_tpcobran='R') THEN
              aux_flregis := 1;
           ELSE
              aux_flregis := NULL;
           END IF;
         END IF;
         
         OPEN  cr_craptdb;
         LOOP
               FETCH cr_craptdb INTO rw_craptdb;
               EXIT  WHEN cr_craptdb%NOTFOUND;
               pr_qtregist := pr_qtregist+1;
               vr_idtabtitcto := pr_tab_dados_titcto.count + 1;
               pr_tab_dados_titcto(vr_idtabtitcto).dtlibbdt := rw_craptdb.dtlibbdt;
               pr_tab_dados_titcto(vr_idtabtitcto).dtvencto := rw_craptdb.dtvencto;
               pr_tab_dados_titcto(vr_idtabtitcto).nrborder := rw_craptdb.nrborder;
               pr_tab_dados_titcto(vr_idtabtitcto).cdbandoc := rw_craptdb.cdbandoc;
               pr_tab_dados_titcto(vr_idtabtitcto).nrcnvcob := rw_craptdb.nrcnvcob;
               pr_tab_dados_titcto(vr_idtabtitcto).nrdocmto := rw_craptdb.nrdocmto;
               pr_tab_dados_titcto(vr_idtabtitcto).vltitulo := rw_craptdb.vltitulo;
               CASE WHEN (rw_craptdb.flgregis = 1  AND rw_craptdb.cdbandoc = 085) THEN
                         pr_tab_dados_titcto(vr_idtabtitcto).tpcobran := 'Coop. Emite';
                    WHEN (rw_craptdb.flgregis = 1  AND rw_craptdb.cdbandoc <> 085) THEN 
                         pr_tab_dados_titcto(vr_idtabtitcto).tpcobran := 'Banco Emite';
                    WHEN (rw_craptdb.flgregis = 0) THEN 
                         pr_tab_dados_titcto(vr_idtabtitcto).tpcobran := 'S/registro';
                    ELSE
                         pr_tab_dados_titcto(vr_idtabtitcto).tpcobran := ' ';
               END CASE;
               pr_tab_dados_titcto(vr_idtabtitcto).nrdconta := rw_craptdb.nrdconta;
               IF (rw_craptdb.nmprimtl IS NOT NULL) THEN
                  pr_tab_dados_titcto(vr_idtabtitcto).nmprimt := rw_craptdb.nmprimtl;
               ELSE
                 pr_tab_dados_titcto(vr_idtabtitcto).nmprimt := '';
               END IF;
         end   loop;
        
    EXCEPTION
      WHEN OTHERS THEN
           /* montar descriçao de erro nao tratado */
           pr_dscritic := 'erro nao tratado na TELA_TITCTO.pc_consulta_pagador_remetente ' ||sqlerrm;

  END pc_consulta_pagador_remetente;


  PROCEDURE pc_consulta_pag_remetente_web(
                                        pr_nrdconta in  crapass.nrdconta%type --> conta do associado
                                        ,pr_tpcobran    IN CHAR                  --> Filtro de tipo de cobranca
                                        ,pr_xmllog   IN VARCHAR2           --> XML com informações de LOG
                                        ,pr_cdcritic out pls_integer           --> codigo da critica
                                        ,pr_dscritic out varchar2              --> descricao da critica
                                        ,pr_retxml   in  out nocopy xmltype    --> arquivo de retorno do xml
                                        ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                                        ,pr_des_erro OUT VARCHAR2      --> Erros do processo
                                      ) is
    -- variaveis de retorno
    vr_tab_dados_titcto typ_tab_dados_titcto;

    vr_tab_erro         gene0001.typ_tab_erro;
    vr_qtregist         number;
    vr_des_reto varchar2(3);
    
    -- variaveis de entrada vindas no xml
    vr_cdcooper integer;
    vr_cdoperad varchar2(100);
    vr_nmdatela varchar2(100);
    vr_nmeacao  varchar2(100);
    vr_cdagenci varchar2(100);
    vr_nrdcaixa varchar2(100);
    vr_idorigem varchar2(100);

    -- variáveis para armazenar as informaçoes em xml
    vr_des_xml        clob;
    vr_texto_completo varchar2(32600);
    vr_index          PLS_INTEGER;

    procedure pc_escreve_xml( pr_des_dados in varchar2
                            , pr_fecha_xml in boolean default false
                            ) is
    begin
        gene0002.pc_escreve_xml( vr_des_xml
                               , vr_texto_completo
                               , pr_des_dados
                               , pr_fecha_xml );
    end;

    begin
      gene0004.pc_extrai_dados( pr_xml      => pr_retxml
                              , pr_cdcooper => vr_cdcooper
                              , pr_nmdatela => vr_nmdatela
                              , pr_nmeacao  => vr_nmeacao
                              , pr_cdagenci => vr_cdagenci
                              , pr_nrdcaixa => vr_nrdcaixa
                              , pr_idorigem => vr_idorigem
                              , pr_cdoperad => vr_cdoperad
                              , pr_dscritic => vr_dscritic);


      pc_consulta_pagador_remetente( vr_cdcooper,
                                        pr_nrdconta,
                                        pr_tpcobran,
                                        --> out
                                        vr_qtregist,
                                        vr_tab_dados_titcto,
                                        pr_cdcritic,
                                        pr_dscritic
                               );

      -- inicializar o clob
      vr_des_xml := null;
      dbms_lob.createtemporary(vr_des_xml, true);
      dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
      -- inicilizar as informaçoes do xml
      vr_texto_completo := null;

      pc_escreve_xml('<?xml version="1.0" encoding="iso-8859-1" ?>'||
                     '<root><dados qtregist="' || vr_qtregist ||'" >');

      -- ler os registros de titcto e incluir no xml
      vr_index := vr_tab_dados_titcto.first;
      while vr_index is not null loop
            pc_escreve_xml('<inf>'||
                             '<dtlibbdt>' || to_char(vr_tab_dados_titcto(vr_index).dtlibbdt,'dd/mm/rrrr') || '</dtlibbdt>' ||
                             '<dtvencto>' || to_char(vr_tab_dados_titcto(vr_index).dtvencto,'dd/mm/rrrr') || '</dtvencto>' ||
                             '<nrborder>' || vr_tab_dados_titcto(vr_index).nrborder || '</nrborder>' ||
                             '<cdbandoc>' || vr_tab_dados_titcto(vr_index).cdbandoc || '</cdbandoc>' ||
                             '<nrcnvcob>' || vr_tab_dados_titcto(vr_index).nrcnvcob || '</nrcnvcob>' ||
                             '<nrdocmto>' || vr_tab_dados_titcto(vr_index).nrdocmto || '</nrdocmto>' ||
                             '<vltitulo>' || vr_tab_dados_titcto(vr_index).vltitulo || '</vltitulo>' ||
                             '<cdoperad>' || vr_tab_dados_titcto(vr_index).cdoperad || '</cdoperad>' ||
                             '<tpcobran>' || vr_tab_dados_titcto(vr_index).tpcobran || '</tpcobran>' ||
                             '<nrdconta>' || TRIM(gene0002.fn_mask(vr_tab_dados_titcto(vr_index).nrdconta,'zzzz.zzz.z'))   || '</nrdconta>' ||
                             '<nmprimt>'  || vr_tab_dados_titcto(vr_index).nmprimt  || '</nmprimt>'  ||
                           '</inf>'
                          );
          /* buscar proximo */
          vr_index := vr_tab_dados_titcto.next(vr_index);
      end loop;
      pc_escreve_xml ('</dados></root>',true);
      pr_retxml := xmltype.createxml(vr_des_xml);

      /* liberando a memória alocada pro clob */
      dbms_lob.close(vr_des_xml);
      dbms_lob.freetemporary(vr_des_xml);
    exception
      when vr_exc_erro then
           /*  se foi retornado apenas código */
           if  nvl(vr_cdcritic,0) > 0 and vr_dscritic is null then
               /* buscar a descriçao */
               vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
           end if;
           /* variavel de erro recebe erro ocorrido */
           pr_cdcritic := nvl(vr_cdcritic,0);
           pr_dscritic := vr_dscritic;
      when others then
           /* montar descriçao de erro nao tratado */
           pr_dscritic := 'erro nao tratado na tela_titcto.pc_consulta_pagador_remetente_web' ||sqlerrm;
  END pc_consulta_pag_remetente_web;

END TELA_TITCTO;
/
