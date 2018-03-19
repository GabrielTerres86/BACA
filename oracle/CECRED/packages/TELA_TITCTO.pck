CREATE OR REPLACE PACKAGE CECRED.TELA_TITCTO IS
  /*---------------------------------------------------------------------------------------------------------------------
    Programa : TELA_TITCTO
    Sistema  : Ayllos Web
    Autor    : Luis Fernando (GFT)
    Data     : Mar�o - 2018                 Ultima atualizacao: 08/03/2018

    Dados referentes ao programa:

    Objetivo  : Centralizar rotinas relacionadas a tela Acompanhamento do Desconto de T�tulo
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
          vlcredit    NUMBER
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
  
  PROCEDURE pc_obtem_dados_titcto (pr_cdcooper    IN crapcop.cdcooper%TYPE, --> C�digo da Cooperativa
                                    pr_nrdconta    IN crapass.nrdconta%TYPE, --> N�mero da Conta
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
                                        ,pr_xmllog   IN VARCHAR2           --> XML com informa��es de LOG
                                        ,pr_cdcritic out pls_integer           --> codigo da critica
                                        ,pr_dscritic out varchar2              --> descricao da critica
                                        ,pr_retxml   in  out nocopy xmltype    --> arquivo de retorno do xml
                                        ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                                        ,pr_des_erro OUT VARCHAR2      --> Erros do processo
                                      );
  PROCEDURE pc_obtem_dados_resumo_dia (
                                        pr_cdcooper    IN crapcop.cdcooper%TYPE, --> C�digo da Cooperativa
                                        pr_nrdconta    IN crapass.nrdconta%TYPE, --> N�mero da Conta
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
                                        ,pr_xmllog   IN VARCHAR2           --> XML com informa��es de LOG
                                        ,pr_cdcritic out pls_integer           --> codigo da critica
                                        ,pr_dscritic out varchar2              --> descricao da critica
                                        ,pr_retxml   in  out nocopy xmltype    --> arquivo de retorno do xml
                                        ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                                        ,pr_des_erro OUT VARCHAR2      --> Erros do processo
                                      );

  PROCEDURE pc_obtem_dados_conciliacao (pr_cdcooper    IN crapcop.cdcooper%TYPE, --> C�digo da Cooperativa
                                    pr_tpcobran    IN CHAR,                  --> Filtro de tipo de cobranca
                                    pr_dtvencto    IN VARCHAR2,                  --> Data de vencimento
                                    pr_dtmvtolt    IN VARCHAR2,                  --> Data da movimentacao
                                    --> out
                                    pr_tab_dados_conciliacao   out  typ_tab_dados_conciliacao, --> Tabela de retorno
                                    pr_cdcritic out number,                         --> codigo da critica
                                    pr_dscritic out varchar2                        --> descricao da critica.                    
                                );
                                
  PROCEDURE pc_obtem_dados_conciliacao_web(pr_tpcobran    IN CHAR                  --> Filtro de tipo de cobranca
                                        ,pr_dtvencto    IN VARCHAR2                  --> Data de vencimento
                                        ,pr_dtmvtolt    IN VARCHAR2                  --> Data da movimentacao
                                        ,pr_xmllog   IN VARCHAR2           --> XML com informa��es de LOG
                                        ,pr_cdcritic out pls_integer           --> codigo da critica
                                        ,pr_dscritic out varchar2              --> descricao da critica
                                        ,pr_retxml   in  out nocopy xmltype    --> arquivo de retorno do xml
                                        ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                                        ,pr_des_erro OUT VARCHAR2      --> Erros do processo
                                      );
                                      
  PROCEDURE pc_obtem_dados_loteamento (pr_cdcooper    IN crapcop.cdcooper%TYPE, --> C�digo da Cooperativa
                                    pr_nrdconta    IN crapass.nrdconta%TYPE, --> N�mero da Conta
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
                                
PROCEDURE pc_obtem_dados_loteamento_web(pr_nrdconta    IN crapass.nrdconta%TYPE --> N�mero da Conta
                                        ,pr_tpcobran    IN CHAR                  --> Filtro de tipo de cobranca
                                        ,pr_tpdepesq    IN CHAR                  --> Filtro de Situacao
                                        ,pr_nrdocmto    IN INTEGER                  --> Numero do Boleto
                                        ,pr_vltitulo    IN NUMBER                   --> Valor do titulo
                                        ,pr_dtmvtolt    IN VARCHAR2                  --> Data da movimentacao
                                        ,pr_xmllog   IN VARCHAR2           --> XML com informa��es de LOG
                                        ,pr_cdcritic out pls_integer           --> codigo da critica
                                        ,pr_dscritic out varchar2              --> descricao da critica
                                        ,pr_retxml   in  out nocopy xmltype    --> arquivo de retorno do xml
                                        ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                                        ,pr_des_erro OUT VARCHAR2      --> Erros do processo
                                      );
                                      
PROCEDURE pc_obtem_dados_lotes (pr_cdcooper    IN crapcop.cdcooper%TYPE, --> C�digo da Cooperativa
                                    pr_dtmvtolt    IN VARCHAR2,                  --> Data da movimentacao
                                    pr_cdagenci    IN INTEGER,                   --> Numero do PA
                                    --> out
                                    pr_qtregist    OUT INTEGER,                  -- Quantidade de resultados
                                    pr_tab_dados_lotes   out  typ_tab_dados_lotes, --> Tabela de retorno
                                    pr_cdcritic out number,                         --> codigo da critica
                                    pr_dscritic out varchar2                        --> descricao da critica.                    
                                );
                                
PROCEDURE pc_gerar_impressao_titcto_c(
                                        pr_nrdconta in  crapass.nrdconta%type --> conta do associado
                                        ,pr_tpcobran    IN CHAR                  --> Filtro de tipo de cobranca
                                        ,pr_flresgat    IN CHAR                  --> Filtro de Resgatados
                                        ,pr_dtmvtolt IN VARCHAR2
                                        ,pr_xmllog   IN VARCHAR2           --> XML com informa��es de LOG
                                        ,pr_cdcritic out pls_integer           --> codigo da critica
                                        ,pr_dscritic out varchar2              --> descricao da critica
                                        ,pr_retxml   in  out nocopy xmltype    --> arquivo de retorno do xml
                                        ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                                        ,pr_des_erro OUT VARCHAR2      --> Erros do processo
                                      );
                                      
                                      
  PROCEDURE pc_gerar_impressao_titcto_l(pr_dtmvtolt IN VARCHAR2
                                        ,pr_cdagenci IN INTEGER                   --> Numero do PA
                                        ,pr_xmllog   IN VARCHAR2           --> XML com informa��es de LOG
                                        ,pr_cdcritic out pls_integer           --> codigo da critica
                                        ,pr_dscritic out varchar2              --> descricao da critica
                                        ,pr_retxml   in  out nocopy xmltype    --> arquivo de retorno do xml
                                        ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                                        ,pr_des_erro OUT VARCHAR2      --> Erros do processo
                                      );
END TELA_TITCTO;
/CREATE OR REPLACE PACKAGE BODY CECRED.TELA_TITCTO IS
  /*---------------------------------------------------------------------------------------------------------------------
    Programa : TELA_TITCTO
    Sistema  : Ayllos Web
    Autor    : Luis Fernando (GFT)
    Data     : Mar�o - 2018                 Ultima atualizacao: 08/03/2018

    Dados referentes ao programa:

    Objetivo  : Centralizar rotinas relacionadas a tela Acompanhamento do Desconto de T�tulo
  */
  /* tratamento de erro */
  vr_exc_erro exception;

  /* descri�ao e c�digo da critica */
  vr_cdcritic crapcri.cdcritic%type;
  vr_dscritic varchar2(4000);
  
  PROCEDURE pc_obtem_dados_titcto (pr_cdcooper    IN crapcop.cdcooper%TYPE, --> C�digo da Cooperativa
                                    pr_nrdconta    IN crapass.nrdconta%TYPE, --> N�mero da Conta
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
    -- Data     : Cria��o: 08/03/2018    
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

      -- Come�a a listagem da tabela
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
           /* montar descri�ao de erro nao tratado */
           pr_dscritic := 'erro nao tratado na TELA_TITCTO.pc_obtem_dados_titcto ' ||sqlerrm;
  END pc_obtem_dados_titcto;
  

  PROCEDURE pc_obtem_dados_titcto_web(
                                        pr_nrdconta in  crapass.nrdconta%type --> conta do associado
                                        ,pr_tpcobran    IN CHAR                  --> Filtro de tipo de cobranca
                                        ,pr_flresgat    IN CHAR                  --> Filtro de Resgatados
                                        ,pr_xmllog   IN VARCHAR2           --> XML com informa��es de LOG
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

    -- vari�veis para armazenar as informa�oes em xml
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
      -- inicilizar as informa�oes do xml
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

      /* liberando a mem�ria alocada pro clob */
      dbms_lob.close(vr_des_xml);
      dbms_lob.freetemporary(vr_des_xml);
    exception
      when vr_exc_erro then
           /*  se foi retornado apenas c�digo */
           if  nvl(vr_cdcritic,0) > 0 and vr_dscritic is null then
               /* buscar a descri�ao */
               vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
           end if;
           /* variavel de erro recebe erro ocorrido */
           pr_cdcritic := nvl(vr_cdcritic,0);
           pr_dscritic := vr_dscritic;
      when others then
           /* montar descri�ao de erro nao tratado */
           pr_dscritic := 'erro nao tratado na tela_titcto.pc_obtem_dados_titcto_web ' ||sqlerrm;
  END pc_obtem_dados_titcto_web;
  
  
  PROCEDURE pc_obtem_dados_resumo_dia (pr_cdcooper    IN crapcop.cdcooper%TYPE, --> C�digo da Cooperativa
                                    pr_nrdconta    IN crapass.nrdconta%TYPE, --> N�mero da Conta
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
    -- Data     : Cria��o: 12/03/2018
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
      
      -- Come�a a listagem da tabela
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
           /* montar descri�ao de erro nao tratado */
           pr_dscritic := 'erro nao tratado na TELA_TITCTO.pc_obtem_dados_resumo_dia ' ||sqlerrm;
  END pc_obtem_dados_resumo_dia;
  
  PROCEDURE pc_obtem_dados_resumo_dia_web(
                                        pr_nrdconta in  crapass.nrdconta%type --> conta do associado
                                        ,pr_tpcobran    IN CHAR                  --> Filtro de tipo de cobranca
                                        ,pr_dtvencto    IN VARCHAR2                  --> Data de vencimento
                                        ,pr_dtmvtolt    IN VARCHAR2                  --> Data da movimentacao
                                        ,pr_xmllog   IN VARCHAR2           --> XML com informa��es de LOG
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

    -- vari�veis para armazenar as informa�oes em xml
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
      -- inicilizar as informa�oes do xml
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

      /* liberando a mem�ria alocada pro clob */
      dbms_lob.close(vr_des_xml);
      dbms_lob.freetemporary(vr_des_xml);
    exception
      when vr_exc_erro then
           /*  se foi retornado apenas c�digo */
           if  nvl(vr_cdcritic,0) > 0 and vr_dscritic is null then
               /* buscar a descri�ao */
               vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
           end if;
           /* variavel de erro recebe erro ocorrido */
           pr_cdcritic := nvl(vr_cdcritic,0);
           pr_dscritic := vr_dscritic;
      when others then
           /* montar descri�ao de erro nao tratado */
           pr_dscritic := 'erro nao tratado na tela_titcto.pc_obtem_dados_resumo_dia_web ' ||sqlerrm;
  END pc_obtem_dados_resumo_dia_web;
  
  PROCEDURE pc_obtem_dados_conciliacao (pr_cdcooper    IN crapcop.cdcooper%TYPE, --> C�digo da Cooperativa
                                    pr_tpcobran    IN CHAR,                  --> Filtro de tipo de cobranca
                                    pr_dtvencto    IN VARCHAR2,                  --> Data de vencimento
                                    pr_dtmvtolt    IN VARCHAR2,                  --> Data da movimentacao
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
    -- Data     : Cria��o: 13/03/2018
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
             AND craptdb.dtresgat = vr_dtvencto
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
             AND craptdb.dtdebito = vr_dtvencto;
       rw_baixados_sem_pagamento cr_baixados_sem_pagamento%ROWTYPE;
       
       /* Pagos pelo Pagador - via COMPE... */
       CURSOR cr_pagos_compe IS
         SELECT 
              craptdb.vltitulo
         FROM 
              craptdb 
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
         ;       
       rw_pagos_compe cr_pagos_compe%ROWTYPE; 
       
       /* Pagos pelo Pagador - via CAIXA... */
       CURSOR cr_pagos_caixa IS
         SELECT 
              craptdb.vltitulo
         FROM 
              craptdb 
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
              AND craptdb.dtdpagto <= vr_dtvencto
              AND craptdb.insittit  = 2
              /* Pago pelo CAIXA, InternetBank ou TAA, e compe 085 */
              AND (
                crapcob.indpagto = 1
                OR crapcob.indpagto = 3
                OR crapcob.indpagto = 4 /**TAA**/
                OR (crapcob.indpagto = 0 AND crapcob.cdbandoc = 085) 
              )
         ;       
       rw_pagos_caixa cr_pagos_caixa%ROWTYPE;        
       
       /* Recebidos no dia */
       CURSOR cr_recebidos_dia IS
         SELECT 
              craptdb.vltitulo
         FROM 
              craptdb 
              INNER JOIN crapcob  ON crapcob.cdcooper = craptdb.cdcooper AND
                                                   crapcob.cdbandoc = craptdb.cdbandoc AND
                                                   crapcob.nrdctabb = craptdb.nrdctabb AND
                                                   crapcob.nrdconta = craptdb.nrdconta AND
                                                   crapcob.nrcnvcob = craptdb.nrcnvcob AND
                                                   crapcob.nrdocmto = craptdb.nrdocmto AND
                                                   (pr_tpcobran='T' OR crapcob.flgregis=aux_flregis)
         WHERE
              craptdb.cdcooper = pr_cdcooper
              AND craptdb.dtlibbdt = vr_dtvencto
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
              INNER JOIN crapcob  ON crapcob.cdcooper = craptdb.cdcooper AND
                                                   crapcob.cdbandoc = craptdb.cdbandoc AND
                                                   crapcob.nrdctabb = craptdb.nrdctabb AND
                                                   crapcob.nrdconta = craptdb.nrdconta AND
                                                   crapcob.nrcnvcob = craptdb.nrcnvcob AND
                                                   crapcob.nrdocmto = craptdb.nrdocmto AND
                                                   (pr_tpcobran='T' OR crapcob.flgregis=aux_flregis)
         WHERE
              craptdb.cdcooper = pr_cdcooper
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
        vr_dtmvtolt:=to_date(pr_dtmvtolt, 'DD/MM/RRRR');
      ELSE
        vr_dtmvtolt:=NULL;
      END IF;

      IF (pr_dtvencto IS NOT NULL ) THEN
         vr_dtvencto := to_date(pr_dtvencto, 'DD/MM/RRRR');
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
      
      -- Come�a a listagem da tabela
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
                                             ,pr_dtmvtolt => vr_dtvencto-1
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
                 /* No caso de fim de semana e feriado, nao pega os titulos que ja foram pegos no dia anterior a ontem */
                 IF (vr_dtrefere <> vr_dtmvtoan AND rw_baixados_sem_pagamento.dtvencto  = vr_dtrefere) THEN
                   CONTINUE;
                 ELSE
                   /*Verifica se vencimento cai em dia nao util e considera o proximo caso ocorra*/
                   tmp_dtvencto := gene0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper
                                             ,pr_dtmvtolt => rw_baixados_sem_pagamento.dtvencto
                                             ,pr_tipo     => 'A' );
                   /* Nao contabilizar os titulos que vencem no final de semana ou feriado no primeiro dia util seguinte, por causa da
                           postergacao de data */
                   IF (tmp_dtvencto<>rw_baixados_sem_pagamento.dtvencto AND  (vr_dtvencto - vr_dtrefere > 1  AND vr_dtvencto - vr_dtmvtoan > 1)    ) THEN
                       CONTINUE;
                   ELSE
                       vr_qtvencid := vr_qtvencid - 1;
                       vr_vlvencid := vr_vlvencid - rw_baixados_sem_pagamento.vltitulo;
                   END IF;
                 END IF;
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
                 vr_vltitulo := vr_vltitulo - rw_recebidos_dia.vltitulo;
         end   loop;
         
         /*Calcula Saldo Anterior*/
         OPEN  cr_saldo_anterior;
         LOOP
               FETCH cr_saldo_anterior INTO rw_saldo_anterior;
               EXIT  WHEN cr_saldo_anterior%NOTFOUND;
                  /* Utiliza essas duas variaveis para pegar TODOS os t�tulos LIBERADOS at� a data informada, pois ele 
                  subtrai TODOS os com data de libera��o a partir da data informada (qtd_liberado) de todos os liberados 
                  da craptdb (qtd_saldo)  */
                  IF (rw_saldo_anterior.dtlibbdt >= vr_dtvencto) THEN
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
                    IF (rw_saldo_anterior.dtdpagto >= vr_dtvencto) THEN
                      vr_vlpgdepois := vr_vlpgdepois + rw_saldo_anterior.vltitulo;
                      vr_qtpgdepois := vr_qtpgdepois + 1;
                      CONTINUE;
                    END IF;
                  END IF;
                  
                  IF (rw_saldo_anterior.dtresgat >= vr_dtvencto) THEN
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
         pr_tab_dados_conciliacao(0).dtvencto := vr_dtvencto;
         pr_tab_dados_conciliacao(0).qtsldant := vr_qtsldant;
         pr_tab_dados_conciliacao(0).vlsldant := vr_vlsldant;
         pr_tab_dados_conciliacao(0).qtderesg := vr_qtderesg;
         pr_tab_dados_conciliacao(0).vlderesg := vr_vlderesg;
         pr_tab_dados_conciliacao(0).qtvencid := vr_qtvencid;
         pr_tab_dados_conciliacao(0).vlvencid := vr_vlvencid;
         pr_tab_dados_conciliacao(0).qttitulo := vr_qttitulo;
         pr_tab_dados_conciliacao(0).vltitulo := vr_vltitulo;
         pr_tab_dados_conciliacao(0).qtcredit := vr_qtcredit;
         pr_tab_dados_conciliacao(0).vlcredit := vr_vlcredit;
    END;
    EXCEPTION
      WHEN OTHERS THEN
           /* montar descri�ao de erro nao tratado */
           pr_dscritic := 'erro nao tratado na TELA_TITCTO.pc_obtem_dados_conciliacao ' ||sqlerrm;
  END pc_obtem_dados_conciliacao;
  
  PROCEDURE pc_obtem_dados_conciliacao_web(pr_tpcobran    IN CHAR                  --> Filtro de tipo de cobranca
                                        ,pr_dtvencto    IN VARCHAR2                  --> Data de vencimento
                                        ,pr_dtmvtolt    IN VARCHAR2                  --> Data da movimentacao
                                        ,pr_xmllog   IN VARCHAR2           --> XML com informa��es de LOG
                                        ,pr_cdcritic out pls_integer           --> codigo da critica
                                        ,pr_dscritic out varchar2              --> descricao da critica
                                        ,pr_retxml   in  out nocopy xmltype    --> arquivo de retorno do xml
                                        ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                                        ,pr_des_erro OUT VARCHAR2      --> Erros do processo
                                      ) is
    -- variaveis de retorno
    vr_tab_dados_conciliacao typ_tab_dados_conciliacao;

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

    -- vari�veis para armazenar as informa�oes em xml
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


      pc_obtem_dados_conciliacao( vr_cdcooper,
                                        pr_tpcobran,
                                        pr_dtvencto,
                                        pr_dtmvtolt,
                                        --> out
                                        vr_tab_dados_conciliacao,
                                        pr_cdcritic,
                                        pr_dscritic
                               );


      -- inicializar o clob
      vr_des_xml := null;
      dbms_lob.createtemporary(vr_des_xml, true);
      dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
      -- inicilizar as informa�oes do xml
      vr_texto_completo := null;

      pc_escreve_xml('<?xml version="1.0" encoding="iso-8859-1" ?>'||
                     '<root><dados >');

      -- ler os registros de titcto e incluir no xml
      vr_index := vr_tab_dados_conciliacao.first;
      while vr_index is not null loop
            pc_escreve_xml('<inf>'||
                              '<dtvencto>' || to_char(vr_tab_dados_conciliacao(vr_index).dtvencto,'dd/mm/rrrr') || '</dtvencto>' ||
                              '<qtsldant>' || vr_tab_dados_conciliacao(vr_index).qtsldant || '</qtsldant>' ||
                              '<vlsldant>' || vr_tab_dados_conciliacao(vr_index).vlsldant || '</vlsldant>' ||
                              '<qtderesg>' || vr_tab_dados_conciliacao(vr_index).qtderesg || '</qtderesg>' ||
                              '<vlderesg>' || vr_tab_dados_conciliacao(vr_index).vlderesg || '</vlderesg>' ||
                              '<qtvencid>' || vr_tab_dados_conciliacao(vr_index).qtvencid || '</qtvencid>' ||
                              '<vlvencid>' || vr_tab_dados_conciliacao(vr_index).vlvencid || '</vlvencid>' ||
                              '<qttitulo>' || vr_tab_dados_conciliacao(vr_index).qttitulo || '</qttitulo>' ||
                              '<vltitulo>' || vr_tab_dados_conciliacao(vr_index).vltitulo || '</vltitulo>' ||
                              '<qtcredit>' || vr_tab_dados_conciliacao(vr_index).qtcredit || '</qtcredit>' ||
                              '<vlcredit>' || vr_tab_dados_conciliacao(vr_index).vlcredit || '</vlcredit>' ||
                           '</inf>'
                          );
          /* buscar proximo */
          vr_index := vr_tab_dados_conciliacao.next(vr_index);
      end loop;
      pc_escreve_xml ('</dados></root>',true);
      pr_retxml := xmltype.createxml(vr_des_xml);

      /* liberando a mem�ria alocada pro clob */
      dbms_lob.close(vr_des_xml);
      dbms_lob.freetemporary(vr_des_xml);
    exception
      when vr_exc_erro then
           /*  se foi retornado apenas c�digo */
           if  nvl(vr_cdcritic,0) > 0 and vr_dscritic is null then
               /* buscar a descri�ao */
               vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
           end if;
           /* variavel de erro recebe erro ocorrido */
           pr_cdcritic := nvl(vr_cdcritic,0);
           pr_dscritic := vr_dscritic;
      when others then
           /* montar descri�ao de erro nao tratado */
           pr_dscritic := 'erro nao tratado na tela_titcto.pc_obtem_dados_conciliacao_web ' ||sqlerrm;
  END pc_obtem_dados_conciliacao_web;
  
  PROCEDURE pc_obtem_dados_loteamento (pr_cdcooper    IN crapcop.cdcooper%TYPE, --> C�digo da Cooperativa
                                    pr_nrdconta    IN crapass.nrdconta%TYPE, --> N�mero da Conta
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
    -- Data     : Cria��o: 13/03/2018    
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
         
      -- Come�a a listagem da tabela
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
           /* montar descri�ao de erro nao tratado */
           pr_dscritic := 'erro nao tratado na TELA_TITCTO.pc_obtem_dados_loteamento ' ||sqlerrm;
  END pc_obtem_dados_loteamento;
  
  PROCEDURE pc_obtem_dados_loteamento_web(pr_nrdconta    IN crapass.nrdconta%TYPE --> N�mero da Conta
                                        ,pr_tpcobran    IN CHAR                  --> Filtro de tipo de cobranca
                                        ,pr_tpdepesq    IN CHAR                  --> Filtro de Situacao
                                        ,pr_nrdocmto    IN INTEGER                  --> Numero do Boleto
                                        ,pr_vltitulo    IN NUMBER                   --> Valor do titulo
                                        ,pr_dtmvtolt    IN VARCHAR2                  --> Data da movimentacao
                                        ,pr_xmllog   IN VARCHAR2           --> XML com informa��es de LOG
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

    -- vari�veis para armazenar as informa�oes em xml
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
      -- inicilizar as informa�oes do xml
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

      /* liberando a mem�ria alocada pro clob */
      dbms_lob.close(vr_des_xml);
      dbms_lob.freetemporary(vr_des_xml);
    exception
      when vr_exc_erro then
           /*  se foi retornado apenas c�digo */
           if  nvl(vr_cdcritic,0) > 0 and vr_dscritic is null then
               /* buscar a descri�ao */
               vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
           end if;
           /* variavel de erro recebe erro ocorrido */
           pr_cdcritic := nvl(vr_cdcritic,0);
           pr_dscritic := vr_dscritic;
      when others then
           /* montar descri�ao de erro nao tratado */
           pr_dscritic := 'erro nao tratado na tela_titcto.pc_obtem_dados_loteamento_web ' ||sqlerrm;
  END pc_obtem_dados_loteamento_web;
  
  PROCEDURE pc_obtem_dados_lotes (pr_cdcooper    IN crapcop.cdcooper%TYPE, --> C�digo da Cooperativa
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
    -- Data     : Cria��o: 15/03/2018
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
      
      -- Come�a a listagem da tabela
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
           /* montar descri�ao de erro nao tratado */
           pr_dscritic := 'erro nao tratado na TELA_TITCTO.pc_obtem_dados_lotes ' ||sqlerrm;
  END pc_obtem_dados_lotes;
  
  
  
  PROCEDURE pc_gerar_impressao_titcto_c(
                                        pr_nrdconta in  crapass.nrdconta%type --> conta do associado
                                        ,pr_tpcobran    IN CHAR                  --> Filtro de tipo de cobranca
                                        ,pr_flresgat    IN CHAR                  --> Filtro de Resgatados
                                        ,pr_dtmvtolt IN VARCHAR2
                                        ,pr_xmllog   IN VARCHAR2           --> XML com informa��es de LOG
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

    -- vari�veis para armazenar as informa�oes em xml
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
      -- inicilizar as informa�oes do xml
      vr_texto_completo := null;
      
      
        --> INICIO
      vr_nmmodulo := 'TITCTO';
      vr_nmrelato := 'Op��o Consulta';
      vr_dstitulo := 'Consulta de t�tulos descontados que n�o foram pagos';
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
           /*  se foi retornado apenas c�digo */
           if  nvl(vr_cdcritic,0) > 0 and vr_dscritic is null then
               /* buscar a descri�ao */
               vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
           end if;
           /* variavel de erro recebe erro ocorrido */
           pr_cdcritic := nvl(vr_cdcritic,0);
           pr_dscritic := vr_dscritic;
      when others then
           /* montar descri�ao de erro nao tratado */
           pr_dscritic := 'erro nao tratado na tela_titcto.pc_obtem_dados_titcto_web ' ||sqlerrm;
  END pc_gerar_impressao_titcto_c;
  
  PROCEDURE pc_gerar_impressao_titcto_l(pr_dtmvtolt IN VARCHAR2
                                        ,pr_cdagenci IN INTEGER                   --> Numero do PA
                                        ,pr_xmllog   IN VARCHAR2           --> XML com informa��es de LOG
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

    -- vari�veis para armazenar as informa�oes em xml
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
      -- inicilizar as informa�oes do xml
      vr_texto_completo := null;
      
      
        --> INICIO
      vr_nmmodulo := 'TITCTO';
      vr_nmrelato := 'Op��o Lotes';
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
           /*  se foi retornado apenas c�digo */
           if  nvl(vr_cdcritic,0) > 0 and vr_dscritic is null then
               /* buscar a descri�ao */
               vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
           end if;
           /* variavel de erro recebe erro ocorrido */
           pr_cdcritic := nvl(vr_cdcritic,0);
           pr_dscritic := vr_dscritic;
      when others then
           /* montar descri�ao de erro nao tratado */
           pr_dscritic := 'erro nao tratado na tela_titcto.pc_obtem_dados_titcto_web ' ||sqlerrm;
  END pc_gerar_impressao_titcto_l;
  
END TELA_TITCTO;

/
