CREATE OR REPLACE PACKAGE CECRED.RATI0003 IS

   ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : RATI0003                     Antiga:
  --  Sistema  : Rotinas para Rating dos Produtos
  --  Sigla    : RATI
  --  Autor    : Anderson Luiz Heckmann - AMcom
  --  Data     : Fevereiro/2019.                   Ultima atualizacao: 26/02/2019
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Rotinas para Rating dos Produtos.
  --
  -- Alteracao:
  --
  ---------------------------------------------------------------------------------------------------------------

---------------------------- ESTRUTURAS DE REGISTRO ---------------------
    -- Definicao do tipo da tabela para linhas de credito
    TYPE typ_reg_risco_op IS
     RECORD(cdlcremp         craplcr.cdlcremp%TYPE,
            dslcremp         craplcr.dslcremp%TYPE,
            flgstlcr         craplcr.flgstlcr%TYPE,
            nrgrplcr         craplcr.nrgrplcr%TYPE,
            txmensal         craplcr.txmensal%TYPE,
            txdiaria         craplcr.txdiaria%TYPE,
            txjurfix         craplcr.txjurfix%TYPE,
            rowid_aux        rowid);

    TYPE typ_tab_risco_op IS
      TABLE OF typ_reg_risco_op
        INDEX BY PLS_INTEGER; -- Codigo da conta
    -- Vetor para armazenar os dados de Linha de Credito
    vr_tab_risco_op typ_tab_risco_op;


  --> Rotina para retornar quantidade de dias em atraso
  FUNCTION fn_obter_qtd_atr_Ext (pr_vl_prejuizo_ult48m IN NUMBER  --> Valor prejuizo 48 m
                                ,pr_vl_venc_180d       IN NUMBER  --> Valor vencimento 180 d
                                ,pr_vl_venc_120d       IN NUMBER  --> Valor vencimento 120 d
                                ,pr_vl_venc_90d        IN NUMBER  --> Valor vencimento 90 d
                                ,pr_vl_venc_60d        IN NUMBER  --> Valor vencimento 60 d
                                ,pr_vl_venc_30d        IN NUMBER  --> Valor vencimento 30 d
                                ,pr_vl_venc_15d        IN NUMBER) --> Valor vencimento 15 d
                                RETURN NUMBER;

  --> Rotina para retornar o percentual do limite de crédito utilizado
  FUNCTION fn_obter_Pc_Utiliz_limite (pr_vl_limite            IN NUMBER  --> Valor do limite utilizado
                                     ,pr_vl_limite_disponivel IN NUMBER) --> Valor do limite disponível
                                      RETURN NUMBER;

  --> Rotina para retornar o percentual do limite de crédito rotativo utilizado
  FUNCTION fn_obter_Pc_Utiliz_lim_Rot (pr_vl_limite          IN NUMBER  --> Valor do limite utilizado
                                      ,pr_vl_saldo_devedor   IN NUMBER) --> Valor do saldo devedor
                                       RETURN NUMBER;
 

  --> Procedure para montar o JSON do Rating com as variáveis internas
  PROCEDURE pc_json_variaveis_rating(pr_cdcooper  IN crapass.cdcooper%TYPE --> Código da cooperativa
                                    ,pr_nrdconta  IN crapass.nrdconta%TYPE --> Numero da conta do emprestimo
                                    ,pr_nrctremp  IN crapepr.nrctremp%TYPE --> Numero do contrato de emprestimo
                                    ,pr_flprepon  IN BOOLEAN DEFAULT FALSE --> Flag Repon
                                    ,pr_vlsalari  IN NUMBER  DEFAULT 0 --> Valor do Salario Associado
                                    ,pr_persocio  IN NUMBER  DEFAULT 0 --> Percential do sócio
                                    ,pr_dtadmsoc  IN DATE    DEFAULT NULL --> Data Admissãio do Sócio
                                    ,pr_dtvigpro  IN DATE    DEFAULT NULL --> Data Vigência do Produto
                                    ,pr_tpprodut  IN NUMBER  DEFAULT 0  --> Tipo de Produto
                                    ,pr_dsjsonvar OUT json --> Retorno Variáveis Json
                                    ,pr_cdcritic  OUT NUMBER --> Código de critica encontrada
                                    ,pr_dscritic  OUT VARCHAR2);

end RATI0003;
/
create or replace package body cecred.RATI0003 IS



  --> Rotina para retornar quantidade de dias em atraso
  FUNCTION fn_obter_qtd_atr_Ext (pr_vl_prejuizo_ult48m IN NUMBER  --> Valor prejuizo 48 m
                                ,pr_vl_venc_180d       IN NUMBER  --> Valor vencimento 180 d
                                ,pr_vl_venc_120d       IN NUMBER  --> Valor vencimento 120 d
                                ,pr_vl_venc_90d        IN NUMBER  --> Valor vencimento 90 d
                                ,pr_vl_venc_60d        IN NUMBER  --> Valor vencimento 60 d
                                ,pr_vl_venc_30d        IN NUMBER  --> Valor vencimento 30 d
                                ,pr_vl_venc_15d        IN NUMBER) --> Valor vencimento 15 d
                                RETURN NUMBER IS
  /* ..........................................................................
      Programa : fn_obter_qtd_atr_Ext
      Sistema  : Conta-Corrente - Cooperativa de Credito
      Sigla    : CRED
      Autor    : Mário Bernat (Amcom)
      Data     : Março/2019.                   Ultima atualizacao: 08/03/2019

      Dados referentes ao programa:

      Frequencia: Sempre que for chamado
      Objetivo  : Rotina para retornar quantidade de dias em atraso

      Alteração :
    ..........................................................................*/
    vr_fn_qtd_atr_Ext NUMBER(3);

    BEGIN
      if    nvl(pr_vl_prejuizo_ult48m,0) > 0 then  vr_fn_qtd_atr_Ext := 999;
      elsif nvl(pr_vl_venc_180d,0) > 0 then vr_fn_qtd_atr_Ext := 181;
      elsif nvl(pr_vl_venc_120d,0) > 0 then vr_fn_qtd_atr_Ext := 121;
      elsif nvl(pr_vl_venc_90d,0)  > 0 then vr_fn_qtd_atr_Ext := 91;
      elsif nvl(pr_vl_venc_60d,0)  > 0 then vr_fn_qtd_atr_Ext := 61;
      elsif nvl(pr_vl_venc_30d,0)  > 0 then vr_fn_qtd_atr_Ext := 31;
      elsif nvl(pr_vl_venc_15d,0)  > 0 then vr_fn_qtd_atr_Ext := 15;
      else                                  vr_fn_qtd_atr_Ext := 0;
      end if;

      RETURN vr_fn_qtd_atr_Ext;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END fn_obter_qtd_atr_Ext;

  --> Rotina para retornar o percentual do limite de crédito utilizado
  FUNCTION fn_obter_Pc_Utiliz_limite (pr_vl_limite            IN NUMBER  --> Valor do limite utilizado
                                     ,pr_vl_limite_disponivel IN NUMBER) --> Valor do limite disponível
                                      RETURN NUMBER IS
  /* ..........................................................................
      Programa : fn_obter_Pc_Utiliz_limite
      Sistema  : Conta-Corrente - Cooperativa de Credito
      Sigla    : CRED
      Autor    : Mário Bernat (Amcom)
      Data     : Março/2019.                   Ultima atualizacao: 08/03/2019

      Dados referentes ao programa:

      Frequencia: Sempre que for chamado
      Objetivo  : Rotina para retornar o percentual do limite de crédito utilizado

      Alteração :
    ..........................................................................*/
    vr_Pc_Utiliz_limite NUMBER(18,6);

    BEGIN
      if pr_vl_limite > 0 then
         vr_Pc_Utiliz_limite := trunc((pr_vl_limite - nvl(pr_vl_limite_disponivel,0)) / pr_vl_limite,4);
      else
         vr_Pc_Utiliz_limite := 0;
      end if;
      RETURN vr_Pc_Utiliz_limite;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END fn_obter_Pc_Utiliz_limite;


  --> Rotina para retornar o percentual do limite de crédito rotativo utilizado
  FUNCTION fn_obter_Pc_Utiliz_lim_Rot (pr_vl_limite          IN NUMBER  --> Valor do limite utilizado
                                      ,pr_vl_saldo_devedor   IN NUMBER) --> Valor do saldo devedor
                                       RETURN NUMBER IS
  /* ..........................................................................
      Programa : fn_obter_Pc_Utiliz_limite
      Sistema  : Conta-Corrente - Cooperativa de Credito
      Sigla    : CRED
      Autor    : Mário Bernat (Amcom)
      Data     : Março/2019.                   Ultima atualizacao: 08/03/2019

      Dados referentes ao programa:

      Frequencia: Sempre que for chamado
      Objetivo  : Rotina para retornar o percentual do saldo devedor rotativo utilizado

      Alteração :
    ..........................................................................*/
    vr_Pc_Utiliz_saldo NUMBER(18,6);

    BEGIN
      if pr_vl_limite > 0 then
         vr_Pc_Utiliz_saldo := trunc((nvl(pr_vl_saldo_devedor,0) * 100 / pr_vl_limite) ,2);
      else
         vr_Pc_Utiliz_saldo := 0;
      end if;
      RETURN vr_Pc_Utiliz_saldo;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END fn_obter_Pc_Utiliz_lim_Rot;



  --> Procedure para montar o JSON do Rating com as variáveis internas
  PROCEDURE pc_json_variaveis_rating(pr_cdcooper  IN crapass.cdcooper%TYPE
                                    ,pr_nrdconta  IN crapass.nrdconta%TYPE
                                    ,pr_nrctremp  IN crapepr.nrctremp%TYPE
                                    ,pr_flprepon  IN BOOLEAN DEFAULT FALSE
                                    ,pr_vlsalari  IN NUMBER  DEFAULT 0
                                    ,pr_persocio  IN NUMBER  DEFAULT 0
                                    ,pr_dtadmsoc  IN DATE    DEFAULT NULL
                                    ,pr_dtvigpro  IN DATE    DEFAULT NULL
                                    ,pr_tpprodut  IN NUMBER  DEFAULT 0
                                    ,pr_dsjsonvar OUT json
                                    ,pr_cdcritic  OUT NUMBER
                                    ,pr_dscritic  OUT VARCHAR2) IS
  BEGIN
    /* ..........................................................................

        Programa : pc_gera_json_pessoa_ass
        Sistema  : Conta-Corrente - Cooperativa de Credito
        Sigla    : CRED
        Autor    : Mario Bernadt (AMcom)
        Data     : Maio/2019.                    Ultima atualizacao: 08/05/2019

        Dados referentes ao programa:

        Frequencia: Sempre que for chamado
        Objetivo  : Rotina responsavel por buscar todas as informações cadastrais
                    e das operações da conta parametrizada.

                    pr_tpprodut --> Tipo de produto (0 - Empréstimos e Financiamentos
                                                     1 - Desconto de Títulos
                                                     4 - Cartão de Crédito)

                   JSON   --> padrão para todos os ambientes, exceto o DEV2
                   PLJSON --> utilizar no ambiente DEV2

        Alteração : 23/01/2019 - P450 - Novas variaveis internas para o Json - Ailos X Ibratan
                                 relacionado ao empréstimo - (Fabio Adriano - AMcom)

                    28/01/2019 - P450 - Novas variaveis internas para o Json - Ailos X Ibratan
                                 relacionado ao desconto de título - (Fabio Adriano - AMcom)

                    13/03/2019 - P450 - Novas variaveis internas para o Json - Ailos X Ibratan
                                 utilizando CNPJ Raiz, Informação do BI e
                                 Geração de todas variáveis - (Mário Bernat - AMcom)

                    27/03/2019 - P450 - Novas variaveis internas para o Json - Ailos X Ibratan
                                 Inclusão das VARIAVEIS: qtatr_udmAvp12, Pc_CarRot_LimQo12 (Mário Bernat - AMcom)

                    17/04/2019 - P450 - Validações de todas as variáveis internas JSON juntamente
                                 com Usuário Diego Gomes - (Mário Bernat - AMcom)

                    25/04/2019 - P450 - Validações variáveis internas JSON referente Sócios/Risco 30 dias
                                 com Usuário Diego Gomes - (Mário Bernat - AMcom)

                    08/05/2019 - P450 - Validações variáveis internas JSON validar atraso independente da cooperativa
                                 com Usuário Diego Gomes - (Mário Bernat - AMcom)

    ..........................................................................*/
    DECLARE
      -- Variáveis para exceções
      vr_cdcritic PLS_INTEGER;
      vr_dscritic VARCHAR2(4000);
      vr_dscritaux VARCHAR2(200);
      vr_exc_saida EXCEPTION;
      vr_des_reto VARCHAR2(3);
      vr_tab_erro GENE0001.typ_tab_erro;
      vr_exc_erro EXCEPTION;

      -- Declarar objetos Json necessários:
      vr_obj_generico  json := json();
      vr_obj_generic4  json := json(); -- Variáveis internas

      -- Variáveis auxiliares
      vr_dstextab craptab.dstextab%TYPE;
      vr_vlendivi NUMBER := 0;
      vr_qtprecal NUMBER(10) := 0;
      vr_inusatab BOOLEAN;
      vr_vltotpre NUMBER(25,4) := 0;
      vr_dtrefere_ris DATE;
      vr_ind     NUMBER(5) := 0;
      vr_nrdivisor NUMBER(2);
      vr_vlfatano NUMBER(18,4);
      vr_persocio   crapavt.persocio%TYPE;
      vr_qtdsocio   NUMBER(3);
      vr_nrcpf_socio_1 NUMBER(16) := 0;
      vr_nrcpf_socio_2 NUMBER(16) := 0;
      vr_nrcpf_socio_3 NUMBER(16) := 0;
      vr_nrcpf_socio_4 NUMBER(16) := 0;
      vr_nrcpf_socio_5 NUMBER(16) := 0;

      /* Tipo que compreende o registro da IBRATAN */
      vr_vl_max_limite            NUMBER(18,4);  --
      vr_qt_CarRotO12             NUMBER(5);     --
      vr_qt_totalQo12             NUMBER(8);     --
      vr_qt_CarRotQmp12           NUMBER(5);     --
      vr_qtd_atr_ExtQo3           NUMBER(5);     --
      vr_Pc_Utiliz_limiteAvg3     NUMBER(18,6);  --
      vr_PcQoPriOcCarRot_12       NUMBER(18,6);  --
      vr_Pc_CarRot_LimQo12        NUMBER(18,6);  --
      vr_qtatr_udmAvp12           NUMBER(18,6);  --

      vr_Pc_Utiliz_limiteMax12    NUMBER(18,6);  --
      vr_Pc_CarRot_LimAvg3        NUMBER(18,6);  --
      vr_Pc_CarRot_LimMax12       NUMBER(18,6);  --
      vr_vl_sld_devedor_totalNd3  NUMBER(18,4);  --
      vr_vl_sld_devedor_totalNd6  NUMBER(18,4);  --
      vr_vl_sld_devedor_totalNd12 NUMBER(18,4);  --
      vr_qtd_atr_ExtMax6          NUMBER(18,4);  --
      vr_qtd_atr_ExtMax12         NUMBER(18,4);  --
      vr_qtd_atr_ExtQo12          NUMBER(18,4);  --
      vr_qtatr_udmMax12           NUMBER(18,4);  --
      vr_qtatr_udmQo12            NUMBER(18,4);  --

      type vr_vl_limite_array          IS VARRAY(12) OF NUMBER(18,6);
      vr_vl_limite                     vr_vl_limite_array;

      type vr_Pc_Utiliz_limite_array   IS VARRAY(12) OF NUMBER(18,6);
      vr_Pc_Utiliz_limite              vr_Pc_Utiliz_limite_array;

      type vr_Pc_Utiliz_lim_CarRot_array IS VARRAY(12) OF NUMBER(18,6);
      vr_Pc_Utiliz_limite_CarRot       vr_Pc_Utiliz_lim_CarRot_array;

      type vr_vl_sld_devedor_rot_array IS VARRAY(12) OF  NUMBER(18,6);
      vr_vl_sld_devedor_Rot            vr_vl_sld_devedor_rot_array;

      type vr_vl_sld_devedor_carrot_array IS VARRAY(12) OF  NUMBER(18,6);
      vr_vl_sld_devedor_CarRot         vr_vl_sld_devedor_carrot_array;

      type vr_qtd_atr_Ext_array        IS VARRAY(12) OF  NUMBER(3);
      vr_qtd_atr_Ext                   vr_qtd_atr_Ext_array;

      type vr_vl_sld_devedor_total_array IS VARRAY(12) OF  NUMBER(18,6);
      vr_vl_sld_devedor_total          vr_vl_sld_devedor_total_array;

      type vr_qtatr_udm_array          IS VARRAY(12) OF  NUMBER(18,6);
      vr_qtatr_udm                     vr_qtatr_udm_array;

      --Tipo de registro do tipo data
      rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;

      -- Busca no cadastro do associado:
      CURSOR cr_crapass IS
        SELECT ass.nrdconta
              ,ass.nrcpfcgc
              ,ass.cdagenci
              ,ass.dtnasctl
              ,ass.nrmatric
              ,ass.cdtipcta
              ,ass.cdsitdct
              ,ass.dtcnsscr
              ,ass.inlbacen
              ,decode(ass.incadpos,1,'Nao Autorizado',2,'Autorizado','Cancelado') incadpos
              ,ass.dtelimin
              ,ass.inccfcop
              ,ass.dtcnsspc
              ,ass.dtdsdspc
              ,ass.inadimpl
              ,ass.cdsitdtl
              ,ass.inpessoa
              ,ass.dtcnscpf
              ,ass.cdsitcpf
              ,ass.cdclcnae
              ,ass.vllimcre
              ,ass.nmprimtl
              ,ass.dtmvtolt
              ,ass.dtadmiss
              ,ass.nrcpfcnpj_base
              ,decode(ass.inpessoa,1,'PF','PJ') dspessoa
          FROM crapass ass
         WHERE ass.cdcooper = pr_cdcooper
           AND ass.nrdconta = pr_nrdconta;
      rw_crapass cr_crapass%ROWTYPE;

      -- Buscar as informações do Arquivo SCR
      -- Conforme Orientação do Usuário Diego Gomes - abril/2019
      CURSOR cr_crapopf IS
        SELECT max(dtrefere) dtrefere
          FROM crapopf;
/*
       -- Não considerar CPF em função das contas inativas
       -- Conforme Orientação do Usuário Diego Gomes - abril/2019
        SELECT qtopesfn
              ,qtifssfn
              ,dtrefere
          FROM crapopf
         WHERE nrcpfcgc = rw_crapass.nrcpfcgc
         ORDER BY dtrefere DESC;
*/
      rw_crapopf cr_crapopf%ROWTYPE;

      -- Buscar os valores para as variáveis internas
      CURSOR cr_crapvopvi(pr_nrcpfcgc IN crapass.nrcpfcgc%TYPE,
                          pr_dtrefere IN crapvop.dtrefere%TYPE) IS
        SELECT SUM(CASE
                     WHEN cdvencto BETWEEN 310 AND 320 THEN
                      vlvencto
                     ELSE
                      0
                   END) vl_prejuizo_ult48m --Soma dos valores com fluxo de vencimento entre 310 e 320
              ,SUM(CASE
                     WHEN cdvencto BETWEEN 255 AND 290 THEN
                      vlvencto
                     ELSE
                      0
                   END) vl_venc_180d --Soma dos valores com fluxo de vencimento entre 255 e 290
              ,SUM(CASE
                     WHEN cdvencto BETWEEN 245 AND 290 THEN
                      vlvencto
                     ELSE
                      0
                   END) vl_venc_120d --Soma dos valores com fluxo de vencimento entre 245 e 290
              ,SUM(CASE
                     WHEN cdvencto BETWEEN 240 AND 290 THEN
                      vlvencto
                     ELSE
                      0
                   END) vl_venc_90d --Soma dos valores com fluxo de vencimento entre 240 e 290
              ,SUM(CASE
                     WHEN cdvencto BETWEEN 230 AND 290 THEN
                      vlvencto
                     ELSE
                      0
                   END) vl_venc_60d --Soma dos valores com fluxo de vencimento entre 230 e 290
              ,SUM(CASE
                     WHEN cdvencto BETWEEN 220 AND 290 THEN
                      vlvencto
                     ELSE
                      0
                   END) vl_venc_30d --Soma dos valores com fluxo de vencimento entre 220 e 290
              ,SUM(CASE
                     WHEN cdvencto BETWEEN 210 AND 290 THEN
                      vlvencto
                     ELSE
                      0
                   END) vl_venc_15d --Soma dos valores com fluxo de vencimento entre 210 e 290
              ,SUM(CASE
                     WHEN ((cdvencto BETWEEN 60 AND 199) OR (cdvencto BETWEEN 205 AND 290)) THEN
                      vlvencto
                     ELSE
                      0
                   END) vl_sld_devedor_total --Soma dos valores com fluxo de vencimento entre 60 e 199 ou 205 e 290
              ,SUM(CASE
                     WHEN ((cdvencto BETWEEN 20 AND 40) AND (cdmodali = 1901)) THEN
                      vlvencto
                     ELSE
                      0
                   END) vl_limite_disponivel --Soma dos valores com fluxo de vencimento entre 20 e 40 da modalidade 1901
              ,SUM(CASE
                     WHEN (((cdvencto BETWEEN 60 AND 199) OR (cdvencto BETWEEN 205 AND 290)) AND (cdmodali IN (101, 201, 213, 214, 204, 218, 210, 406, 1304))) THEN
                      vlvencto
                     ELSE
                      0
                   END) vl_sld_devedor_total_Rot --Soma dos valores com fluxo de vencimento entre 60 e 199 ou 205 e 290 das modalidades 101 201 213 214 204 218 210 406 1304
              ,SUM(CASE
                     WHEN (((cdvencto BETWEEN 60 AND 199) OR (cdvencto BETWEEN 205 AND 290)) AND (cdmodali IN (204, 218))) THEN
                      vlvencto
                     ELSE
                      0
                   END) vl_sld_devedor_total_CarRot --Soma dos valores com fluxo de vencimento entre 60 e 199 ou 205 e 290 das modalidade 204 218
          FROM crapvop
         WHERE nrcpfcgc = pr_nrcpfcgc
           AND dtrefere = pr_dtrefere; -- Conforme a necessidade de buscar as informações de meses anteriores, passar na variável ao abrir o cursor a data referência - 1 mês, - 2 meses, ...
      rw_crapvopvi     cr_crapvopvi%ROWTYPE;

      -- PJ/PF - Buscar o maior tempo de conta do sistema Ailos (CNPJ RAIZ)
      CURSOR cr_qtconta(pr_cdcooper IN crapass.cdcooper%TYPE
                       ,pr_nrdconta IN crapass.nrdconta%TYPE
                       ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE) IS
        SELECT FLOOR((pr_dtmvtolt - (ass.dtmvtolt ))/30) qtconta  --ass.dtabtcct
              ,nvl(ass.dtelimin,trunc(sysdate)) dtelimin
          FROM crapass ass
         WHERE ass.cdcooper = pr_cdcooper
           AND ass.nrcpfcnpj_base IN (SELECT nrcpfcnpj_base
                                        FROM crapass x
                                       WHERE x.cdcooper = ass.cdcooper
                                         AND x.nrdconta = pr_nrdconta)
         ORDER BY dtelimin DESC, qtconta DESC;
      rw_qtconta cr_qtconta%ROWTYPE;

      -- PJ - Buscar o fatuamento para PJ do sistema Ailos (CNPJ RAIZ)
      -- Conforme Orientação do Usuário Diego Gomes - abril/2019
      CURSOR cr_vlfaturamento(pr_cdcooper IN crapass.cdcooper%TYPE
                             ,pr_nrdconta IN crapass.nrdconta%TYPE
                             ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE) IS
        SELECT COUNT(*) qt, SUM(y.vl) vl_tot FROM (
          SELECT x.dt, x.vl
            FROM (SELECT LAST_DAY(to_date('01'||TO_CHAR(MESFTBRU##1,'00')||TO_CHAR(ANOFTBRU##1,'0000'),'ddmmrrrr')) dt,VLRFTBRU##1 vl
                    FROM crapjfn ff
                   WHERE ff.cdcooper=pr_cdcooper AND ff.nrdconta=pr_nrdconta AND MESFTBRU##1 > 0
            UNION SELECT LAST_DAY(to_date('01'||TO_CHAR(MESFTBRU##2,'00')||TO_CHAR(ANOFTBRU##2,'0000'),'ddmmrrrr')) ,VLRFTBRU##2
                    FROM crapjfn ff
                   WHERE ff.cdcooper=pr_cdcooper AND ff.nrdconta=pr_nrdconta AND MESFTBRU##2 > 0
            UNION SELECT LAST_DAY(to_date('01'||TO_CHAR(MESFTBRU##3,'00')||TO_CHAR(ANOFTBRU##3,'0000'),'ddmmrrrr')) ,VLRFTBRU##3
                    FROM crapjfn ff
                   WHERE ff.cdcooper=pr_cdcooper AND ff.nrdconta=pr_nrdconta AND MESFTBRU##3 > 0
            UNION SELECT LAST_DAY(to_date('01'||TO_CHAR(MESFTBRU##4,'00')||TO_CHAR(ANOFTBRU##4,'0000'),'ddmmrrrr')) ,VLRFTBRU##4
                    FROM crapjfn ff
                   WHERE ff.cdcooper=pr_cdcooper AND ff.nrdconta=pr_nrdconta AND MESFTBRU##4 > 0
            UNION SELECT LAST_DAY(to_date('01'||TO_CHAR(MESFTBRU##5,'00')||TO_CHAR(ANOFTBRU##5,'0000'),'ddmmrrrr')) ,VLRFTBRU##5
                    FROM crapjfn ff
                   WHERE ff.cdcooper=pr_cdcooper AND ff.nrdconta=pr_nrdconta AND MESFTBRU##5 > 0
            UNION SELECT LAST_DAY(to_date('01'||TO_CHAR(MESFTBRU##6,'00')||TO_CHAR(ANOFTBRU##6,'0000'),'ddmmrrrr')) ,VLRFTBRU##6
                    FROM crapjfn ff
                   WHERE ff.cdcooper=pr_cdcooper AND ff.nrdconta=pr_nrdconta AND MESFTBRU##6 > 0
            UNION SELECT LAST_DAY(to_date('01'||TO_CHAR(MESFTBRU##7,'00')||TO_CHAR(ANOFTBRU##7,'0000'),'ddmmrrrr')) ,VLRFTBRU##7
                    FROM crapjfn ff
                   WHERE ff.cdcooper=pr_cdcooper AND ff.nrdconta=pr_nrdconta AND MESFTBRU##7 > 0
            UNION SELECT LAST_DAY(to_date('01'||TO_CHAR(MESFTBRU##8,'00')||TO_CHAR(ANOFTBRU##8,'0000'),'ddmmrrrr')) ,VLRFTBRU##8
                    FROM crapjfn ff
                   WHERE ff.cdcooper=pr_cdcooper AND ff.nrdconta=pr_nrdconta AND MESFTBRU##8 > 0
            UNION SELECT LAST_DAY(to_date('01'||TO_CHAR(MESFTBRU##9,'00')||TO_CHAR(ANOFTBRU##9,'0000'),'ddmmrrrr')) ,VLRFTBRU##9
                    FROM crapjfn ff
                   WHERE ff.cdcooper=pr_cdcooper AND ff.nrdconta=pr_nrdconta AND MESFTBRU##9 > 0
            UNION SELECT LAST_DAY(to_date('01'||TO_CHAR(MESFTBRU##10,'00')||TO_CHAR(ANOFTBRU##10,'0000'),'ddmmrrrr')) ,VLRFTBRU##10
                    FROM crapjfn ff
                   WHERE ff.cdcooper=pr_cdcooper AND ff.nrdconta=pr_nrdconta AND MESFTBRU##10 > 0
            UNION SELECT LAST_DAY(to_date('01'||TO_CHAR(MESFTBRU##11,'00')||TO_CHAR(ANOFTBRU##11,'0000'),'ddmmrrrr')) ,VLRFTBRU##11
                    FROM crapjfn ff
                   WHERE ff.cdcooper=pr_cdcooper AND ff.nrdconta=pr_nrdconta AND MESFTBRU##11 > 0
            UNION SELECT LAST_DAY(to_date('01'||TO_CHAR(MESFTBRU##12,'00')||TO_CHAR(ANOFTBRU##12,'0000'),'ddmmrrrr')) ,VLRFTBRU##12
                    FROM crapjfn ff
                   WHERE ff.cdcooper=pr_cdcooper AND ff.nrdconta=pr_nrdconta AND MESFTBRU##12 > 0 ) x
          WHERE x.dt > ADD_MONTHS(pr_dtmvtolt, -36)
            AND x.vl > 100) y;
      rw_vlfaturamento cr_vlfaturamento%ROWTYPE;

      -- PJ/PF - Busca Quantidade maxima de dias de atraso nos ultimos 30 dias anteriores ao dia proposta
      -- Encaminhar para BI atualizar Coluna
/*
      --
      -- Query para efetuar carga no na tabela: TBCC_ASSOCIADOS
      --                                coluna: qtmax_atraso
      --
        select x.cdcooper
              ,x.qtmax_atraso
              ,x.nrdconta
              ,x.nrcpfcnpj_base
          from
               (select y.qtatr_max_ult30d  qtmax_atraso
                      ,y.nrdconta
                      ,y.nrcpfcnpj_base
                      ,y.cdcooper
                      ,row_number() over (partition By y.nrcpfcnpj_base, y.cdcooper
                                              order by y.qtatr_max_ult30d DESC) nrseqreg
                  from
                       (select max(ris.qtdiaatr) qtatr_max_ult30d
                              ,ris.nrdconta
                              ,ass.nrcpfcnpj_base
                              ,ass.cdcooper
                          FROM crapass  ass
                              ,crapris  ris
                              ,crapdat  dat
                         WHERE dat.cdcooper = 3
                           and ris.dtrefere between add_months(dat.dtmvtolt,-1) and dat.dtmvtolt
                           and ris.nrdconta = ass.nrdconta
                           and ris.cdcooper = ass.cdcooper
                         GROUP BY  nrcpfcnpj_base
                                  ,ris.nrdconta
                                  ,ass.cdcooper
                        having max(ris.qtdiaatr) > 0) y
               ) x
         where x.nrseqreg  = 1;
      -- ----------------------------------------
*/

      -- PJ/PF - Busca Quantidade maxima de dias de atraso nos ultimos 30 dias anteriores ao dia proposta
      CURSOR cr_qtatr_max_ult30d (pr_cdcooper IN crapass.cdcooper%TYPE
                                 ,pr_nrcpfcnpj_base IN crapass.nrcpfcnpj_base%TYPE) IS
      select nvl(max(qtmax_atraso),0)  qtatr_max_ult30d
        FROM crapass          ass
            ,tbcc_associados  tbcc
       WHERE ass.cdcooper > 0
         and ass.nrcpfcnpj_base = pr_nrcpfcnpj_base
         and tbcc.nrdconta = ass.nrdconta
         and tbcc.cdcooper = ass.cdcooper;
      rw_qtatr_max_ult30d cr_qtatr_max_ult30d%ROWTYPE;

      -- PF - Busca Idade / Diferença entre a data de nascimento do cadastro e a data da proposta em dias
      CURSOR cr_qtidade (pr_cdcooper IN crapass.cdcooper%TYPE
                        ,pr_nrcpfcgc IN crapass.NRCPFCGC%TYPE
                        ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE) IS
        select pr_dtmvtolt - ass.dtnasctl qtidade
          from crapass ass
         where ass.cdcooper = pr_cdcooper
           and ass.nrcpfcgc = pr_nrcpfcgc
           and ass.inpessoa = 1
         order by 1 desc;
      rw_qtidade cr_qtidade%ROWTYPE;

      -- PF - Busca Quantidade de dias de atraso do ultimo dia do mês da ultima data base disponivel
      CURSOR cr_qtatr_udm (pr_nrcpfcgc   IN crapris.NRCPFCGC%TYPE
                          ,pr_dtbasedisp IN crapsda.dtmvtolt%type) IS
        select ris.dtrefere
              ,max(ris.qtdiaatr) qtatr_udm
          from crapris ris
              ,crapass ass
          where
               ass.nrcpfcgc = pr_nrcpfcgc
           and ass.inpessoa = 1
           --
           and ris.cdcooper = ass.cdcooper
           and ris.nrdconta = ass.nrdconta
           AND ris.dtrefere between last_day(add_months(pr_dtbasedisp,-12)) and pr_dtbasedisp
           and ris.qtdiaatr > 0
         group by ris.dtrefere
         order by ris.dtrefere desc;
      rw_qtatr_udm cr_qtatr_udm%ROWTYPE;

      -- flag_manutencao e flag_originação
      -- proposta de EMPRESTIMO
      CURSOR cr_flag_manut_orig (pr_cdcooper IN crapass.cdcooper%TYPE
                                ,pr_nrdconta IN crapass.nrdconta%TYPE
                                ,pr_nrctremp IN crapepr.nrctremp%TYPE) IS
        select emp.dtmvtolt - epr.dtmvtolt qtdiasflag
          from crapepr emp
             , crawepr epr
          where emp.nrctremp = epr.nrctremp
            and emp.nrdconta = epr.nrdconta
            and emp.cdcooper = epr.cdcooper
            and emp.nrctremp = pr_nrctremp
            and emp.nrdconta = pr_nrdconta
            and emp.cdcooper = pr_cdcooper;
      rw_flag_manut_orig cr_flag_manut_orig%ROWTYPE;

      -- flag_manutencao e flag_originação
      -- proposta de DESCONTO DE TITULO
      CURSOR cr_flag_manut_orig_t (pr_cdcooper IN crapass.cdcooper%TYPE
                                  ,pr_nrdconta IN crapass.nrdconta%TYPE
                                  ,pr_nrctrlim IN craplim.nrctrlim%TYPE) IS
        select lim.dtpropos - pli.dtpropos qtdiasflag
          from craplim lim
             , crawlim pli
          where lim.nrctrlim = pli.nrctrlim
            and lim.nrdconta = pli.nrdconta
            and lim.cdcooper = pli.cdcooper
            and lim.nrctrlim = pr_nrctrlim
            and lim.nrdconta = pr_nrdconta
            and lim.cdcooper = pr_cdcooper;
      rw_flag_manut_orig_t cr_flag_manut_orig_t%ROWTYPE;

      -- PJ - Valor do ultimo faturamento anual disponivel
      CURSOR cr_crapjur_ibr (pr_cdcooper       IN crapass.cdcooper%TYPE
                            ,pr_nrcpfcnpj_base IN crapass.nrcpfcnpj_base%TYPE) IS
        SELECT  max(jur.vlfatano) vlfatano
          FROM  crapjur jur
               ,crapass ass
         WHERE
               ass.cdcooper = pr_cdcooper
           and ass.nrcpfcnpj_base = pr_nrcpfcnpj_base
           and ass.inpessoa = 2
           and jur.cdcooper = ass.cdcooper
           and jur.nrdconta = ass.nrdconta;
      rw_crapjur_ibr cr_crapjur_ibr%ROWTYPE;

      -- Buscar o maximo da quantidade de dias de atraso nos ultimos 30 dias anteriores
      --   ao dia proposta entre ate os 5 socios com maior participacao
      CURSOR cr_socqtatrmaxult30d(pr_cdcooper IN crapass.cdcooper%TYPE
                                 ,pr_nrcpfcgc_base_1 IN crapass.nrcpfcnpj_base%TYPE
                                 ,pr_nrcpfcgc_base_2 IN crapass.nrcpfcnpj_base%TYPE
                                 ,pr_nrcpfcgc_base_3 IN crapass.nrcpfcnpj_base%TYPE
                                 ,pr_nrcpfcgc_base_4 IN crapass.nrcpfcnpj_base%TYPE
                                 ,pr_nrcpfcgc_base_5 IN crapass.nrcpfcnpj_base%TYPE) IS
         SELECT nvl(max(tbcc.qtmax_atraso),0) qtdiaatr
                  FROM TBCC_ASSOCIADOS tbcc
                     , crapass ass
          WHERE ass.cdcooper > 0
            and ass.inpessoa = 1
            and ass.nrcpfcnpj_base in (pr_nrcpfcgc_base_1,pr_nrcpfcgc_base_2,pr_nrcpfcgc_base_3
                                      ,pr_nrcpfcgc_base_4,pr_nrcpfcgc_base_5)
                   and tbcc.nrdconta = ass.nrdconta
            and tbcc.cdcooper = ass.cdcooper;
       rw_socqtatrmaxult30d cr_socqtatrmaxult30d%ROWTYPE;

        -- Buscar o CPF do socio com maior participacao
       CURSOR cr_cpfsocio (pr_cdcooper IN crapass.cdcooper%TYPE
                          ,pr_nrcpfcgc IN crapris.nrcpfcgc%TYPE) IS
        SELECT x.persocio
             , x.nrcpfcgc
             , ROW_NUMBER() OVER (PARTITION BY x.persocio ORDER BY x.persocio DESC) nrseqreg
          FROM (SELECT distinct
                       avt.persocio
                     , avt.nrcpfcgc
                  FROM crapavt avt
                      ,crapass ass
                 WHERE
                       ass.cdcooper = pr_cdcooper
                   and ass.inpessoa = 2
                   and ass.nrcpfcnpj_base = substr(to_char(pr_nrcpfcgc,'FM00000000000000'),1,8)
                   --
                   AND avt.cdcooper = ass.cdcooper
                   and avt.nrdconta = ass.nrdconta
                   and avt.persocio > 0
                   AND avt.tpctrato = 6
                   AND avt.nrctremp = 0  -- Deve ser zero para pegar a sociedade, se for diferente de zero é avalista
               ) x
           ORDER BY x.persocio DESC, nrseqreg;
       rw_cpfsocio cr_cpfsocio%ROWTYPE;

    -- ---------------------------------------------------------------
    BEGIN

      --Verificar se a data existe
      OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
      -- Se não encontrar
      IF BTCH0001.cr_crapdat%NOTFOUND THEN
        -- Montar mensagem de critica
        vr_cdcritic:= 1;
        CLOSE BTCH0001.cr_crapdat;
        RAISE vr_exc_saida;
      ELSE
        -- Apenas fechar o cursor
        CLOSE BTCH0001.cr_crapdat;
      END IF;

      -- Buscar informações cadastrais da conta
      OPEN cr_crapass;
      FETCH cr_crapass
        INTO rw_crapass;

      -- Se não encontrar registro
      IF cr_crapass%NOTFOUND THEN
        CLOSE cr_crapass;
        -- Sair acusando critica 9
        vr_cdcritic := 9;
        RAISE vr_exc_saida;
      ELSE
        CLOSE cr_crapass;
      END IF;

      -- Complemento de mensagem
      vr_dscritaux := 'Chama funcao juros';

      --Verificar se usa tabela juros
      vr_dstextab:= TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                              ,pr_nmsistem => 'CRED'
                                              ,pr_tptabela => 'USUARI'
                                              ,pr_cdempres => 11
                                              ,pr_cdacesso => 'TAXATABELA'
                                              ,pr_tpregist => 0);
      -- Se a primeira posição do campo
      -- dstextab for diferente de zero
      vr_inusatab:= SUBSTR(vr_dstextab,1,1) != '0';

      -- Buscar saldo devedor
      EMPR0001.pc_saldo_devedor_epr (pr_cdcooper   => pr_cdcooper     --> Cooperativa conectada
                                    ,pr_cdagenci   => 1               --> Codigo da agencia
                                    ,pr_nrdcaixa   => 0               --> Numero do caixa
                                    ,pr_cdoperad   => '1'             --> Codigo do operador
                                    ,pr_nmdatela   => 'ATENDA'        --> Nome datela conectada
                                    ,pr_idorigem   => 1 --Ayllos--    --> Indicador da origem da chamada
                                    ,pr_nrdconta   => pr_nrdconta     --> Conta do associado
                                    ,pr_idseqttl   => 1               --> Sequencia de titularidade da conta
                                    ,pr_rw_crapdat => rw_crapdat      --> Vetor com dados de parametro (CRAPDAT)
                                    ,pr_nrctremp   => 0               --> Numero contrato emprestimo
                                    ,pr_cdprogra   => 'B1WGEN0001'    --> Programa conectado
                                    ,pr_inusatab   => vr_inusatab     --> Indicador de utilizacão da tabela
                                    ,pr_flgerlog   => 'N'             --> Gerar log S/N
                                    ,pr_vlsdeved   => vr_vlendivi     --> Saldo devedor calculado
                                    ,pr_vltotpre   => vr_vltotpre     --> Valor total das prestacães
                                    ,pr_qtprecal   => vr_qtprecal     --> Parcelas calculadas
                                    ,pr_des_reto   => vr_des_reto     --> Retorno OK / NOK
                                    ,pr_tab_erro   => vr_tab_erro);   --> Tabela com possives erros

      -- Se houve retorno de erro
      IF vr_des_reto = 'NOK' THEN
        -- Extrair o codigo e critica de erro da tabela de erro
        vr_cdcritic := vr_tab_erro(vr_tab_erro.first).cdcritic;
        vr_dscritic := vr_tab_erro(vr_tab_erro.first).dscritic;

        -- Limpar tabela de erros
        vr_tab_erro.DELETE;

        RAISE vr_exc_saida;
      END IF;

      -- Novas variaveis internas para o Json
      vr_obj_generic4 := json();

      --Inicializa array
      vr_qtd_atr_Ext := vr_qtd_atr_Ext_array (0,0,0,0,0,0,0,0,0,0,0,0);
      vr_vl_limite   := vr_vl_limite_array   (0,0,0,0,0,0,0,0,0,0,0,0);
      vr_Pc_Utiliz_limite := vr_Pc_Utiliz_limite_array (0,0,0,0,0,0,0,0,0,0,0,0);
      vr_Pc_Utiliz_limite_CarRot := vr_Pc_Utiliz_lim_CarRot_array (0,0,0,0,0,0,0,0,0,0,0,0);
      vr_vl_sld_devedor_Rot    := vr_vl_sld_devedor_rot_array    (0,0,0,0,0,0,0,0,0,0,0,0);
      vr_vl_sld_devedor_CarRot := vr_vl_sld_devedor_carrot_array (0,0,0,0,0,0,0,0,0,0,0,0);
      vr_vl_sld_devedor_total  := vr_vl_sld_devedor_total_array  (0,0,0,0,0,0,0,0,0,0,0,0);
      vr_qtatr_udm := vr_qtatr_udm_array (0,0,0,0,0,0,0,0,0,0,0,0);

      -- Variável Auxiliar utilizada somente em testes
      /*
      vr_obj_generic4.put('ID', 'VarInt' ||'_'|| pr_cdcooper
                                         ||'_'|| rw_crapass.dspessoa
                                         ||'_'|| rw_crapass.nrcpfcnpj_base
                                         ||'_'|| rw_crapass.nrdconta);
      */

      -- PF/PJ - Buscar o maior tempo de conta do sistema Ailos
      OPEN cr_qtconta(pr_cdcooper   --Cooperativa
                     ,rw_crapass.nrdconta
                     ,rw_crapdat.dtmvtolt);
      FETCH cr_qtconta
       INTO rw_qtconta;
      CLOSE cr_qtconta;
      vr_obj_generic4.put('QtConta',NVL(rw_qtconta.qtconta,0));

      IF to_char(rw_crapdat.dtmvtoan, 'MM') <> to_char(rw_crapdat.dtmvtolt, 'MM') THEN
         -- Utilizar o final do mês como data
         vr_dtrefere_ris := rw_crapdat.dtultdma;
      ELSE
         -- Utilizar a data atual
         --vr_dtrefere_ris := rw_crapdat.dtmvtoan;

         -- Utilizar somente posição de mês fechado,
         -- Conforme Orientação do Usuário Diego Gomes - abril/2019
         vr_dtrefere_ris := last_day(add_months(rw_crapdat.dtmvtolt,-1));
      END IF;

      -- Complemento de mensagem
      vr_dscritaux := 'Busca qtd maxima atraso';

      -- Buscar as informações do Arquivo SCR
      OPEN cr_crapopf;
      FETCH cr_crapopf
        INTO rw_crapopf;
      CLOSE cr_crapopf;

      -- PF/PJ - Busca Quantidade maxima de dias de atraso nos ultimos 30 dias anteriores ao dia proposta
      OPEN cr_qtatr_max_ult30d(pr_cdcooper
                              ,rw_crapass.nrcpfcnpj_base);
      FETCH cr_qtatr_max_ult30d
       INTO rw_qtatr_max_ult30d;
      CLOSE cr_qtatr_max_ult30d;
      vr_obj_generic4.put('qtatr_Max_Ult30d',NVL(rw_qtatr_max_ult30d.qtatr_max_ult30d,0));

      -- PF - Para Pessoas Fisicas
      IF rw_crapass.inpessoa = 1 THEN
        --Busca Idade / Diferença entre a data de nascimento do cadastro e a data da proposta em dias
        OPEN cr_qtidade(pr_cdcooper
                       ,rw_crapass.nrcpfcgc
                       ,rw_crapdat.dtmvtolt);
        FETCH cr_qtidade
         INTO rw_qtidade;
        CLOSE cr_qtidade;
        vr_obj_generic4.put('QtIdade',NVL(rw_qtidade.qtidade,0));

      -- Para Pessoas Juridicas
      ELSE
         -- PJ - Valor do ultimo faturamento anual disponivel
         --      Retirado Conforme Orientação do Usuário Diego Gomes - abril/2019
         /*
         OPEN cr_crapjur_ibr(pr_cdcooper,rw_crapass.nrcpfcnpj_base);
         FETCH cr_crapjur_ibr
          INTO rw_crapjur_ibr;
         CLOSE cr_crapjur_ibr;
         vr_obj_generic4.put('vl_faturamento_anual',este0001.fn_decimal_ibra(NVL(rw_crapjur_ibr.vlfatano,0)));
         */

         -- PJ - Buscar o valor do faturamento do sistema Ailos
         --      Conforme Orientação do Usuário Diego Gomes - abril/2019
         OPEN cr_vlfaturamento(pr_cdcooper
                              ,rw_crapass.nrdconta
                              ,rw_crapdat.dtmvtolt);
         FETCH cr_vlfaturamento
          INTO rw_vlfaturamento;
         CLOSE cr_vlfaturamento;

         if nvl(rw_vlfaturamento.qt,0) = 0 then
            vr_vlfatano := 0;
         else
            if nvl(rw_vlfaturamento.qt,0) = 12 then
               vr_vlfatano := nvl(rw_vlfaturamento.vl_tot,0);
            else
               vr_vlfatano := trunc(nvl(rw_vlfaturamento.vl_tot,0)
                                + ((nvl(rw_vlfaturamento.vl_tot,0) / nvl(rw_vlfaturamento.qt,0))
                                * (12 - nvl(rw_vlfaturamento.qt,0))),2);
            end if;
         end if;
         vr_obj_generic4.put('vl_faturamento_anual',este0001.fn_decimal_ibra(NVL(vr_vlfatano,0)));

         -- PJ - Buscar o CPF do socio com maior participacao
         vr_persocio := 0;
         vr_qtdsocio := 0;
         vr_nrcpf_socio_1 := 0;
         vr_nrcpf_socio_2 := 0;
         vr_nrcpf_socio_3 := 0;
         vr_nrcpf_socio_4 := 0;
         vr_nrcpf_socio_5 := 0;

         FOR rw_cpfsocio IN cr_cpfsocio (pr_cdcooper
                                        ,rw_crapass.nrcpfcgc) LOOP
           CASE
             WHEN rw_cpfsocio.nrseqreg = 1 and vr_persocio = 0 THEN
                vr_obj_generic4.put('cpf_socio_1',NVL(rw_cpfsocio.nrcpfcgc,0));
                vr_persocio := NVL(rw_cpfsocio.persocio,0);
                vr_nrcpf_socio_1 := NVL(rw_cpfsocio.nrcpfcgc,0);
                vr_qtdsocio := 1;
             WHEN rw_cpfsocio.nrseqreg = 2 THEN
               IF vr_persocio = NVL(rw_cpfsocio.persocio,0) THEN
                 vr_obj_generic4.put('cpf_socio_2',NVL(rw_cpfsocio.nrcpfcgc,0));
                 vr_nrcpf_socio_2 := NVL(rw_cpfsocio.nrcpfcgc,0);
                 vr_qtdsocio := 2;
               END IF;
             WHEN rw_cpfsocio.nrseqreg = 3 THEN
               IF vr_persocio = NVL(rw_cpfsocio.persocio,0) THEN
                 vr_obj_generic4.put('cpf_socio_3',NVL(rw_cpfsocio.nrcpfcgc,0));
                 vr_nrcpf_socio_3 := NVL(rw_cpfsocio.nrcpfcgc,0);
                 vr_qtdsocio := 3;
               END IF;
             WHEN rw_cpfsocio.nrseqreg = 4 THEN
               IF vr_persocio = NVL(rw_cpfsocio.persocio,0) THEN
                 vr_obj_generic4.put('cpf_socio_4',NVL(rw_cpfsocio.nrcpfcgc,0));
                 vr_nrcpf_socio_4 := NVL(rw_cpfsocio.nrcpfcgc,0);
                 vr_qtdsocio := 4;
               END IF;
             WHEN rw_cpfsocio.nrseqreg = 5 THEN
               IF vr_persocio = NVL(rw_cpfsocio.persocio,0) THEN
                 vr_obj_generic4.put('cpf_socio_5',NVL(rw_cpfsocio.nrcpfcgc,0));
                 vr_nrcpf_socio_5 := NVL(rw_cpfsocio.nrcpfcgc,0);
                 vr_qtdsocio := 5;
               END IF;
             ELSE  NULL;
           END CASE;
         END LOOP;

         -- Utilizado apenas para teste pois Diego importa aruivo Json em planinha excel
         /*
         if vr_qtdsocio = 0 then
            vr_obj_generic4.put('cpf_socio_1',0);
            vr_obj_generic4.put('cpf_socio_2',0);
            vr_obj_generic4.put('cpf_socio_3',0);
            vr_obj_generic4.put('cpf_socio_4',0);
            vr_obj_generic4.put('cpf_socio_5',0);
         end if;
         if vr_qtdsocio = 1 then
            vr_obj_generic4.put('cpf_socio_2',0);
            vr_obj_generic4.put('cpf_socio_3',0);
            vr_obj_generic4.put('cpf_socio_4',0);
            vr_obj_generic4.put('cpf_socio_5',0);
         end if;
         if vr_qtdsocio = 2 then
            vr_obj_generic4.put('cpf_socio_3',0);
            vr_obj_generic4.put('cpf_socio_4',0);
            vr_obj_generic4.put('cpf_socio_5',0);
         end if;
         if vr_qtdsocio = 3 then
            vr_obj_generic4.put('cpf_socio_4',0);
            vr_obj_generic4.put('cpf_socio_5',0);
         end if;
         if vr_qtdsocio = 4 then
            vr_obj_generic4.put('cpf_socio_5',0);
         end if;
     */
         -- PJ - Buscar o maximo da quantidade de dias de atraso nos ultimos 30 dias anteriores
         --      ao dia proposta entre ate os 5 socios com maior participacao
         OPEN cr_socqtatrmaxult30d(pr_cdcooper
                                  ,vr_nrcpf_socio_1,vr_nrcpf_socio_2
                                  ,vr_nrcpf_socio_3,vr_nrcpf_socio_4,vr_nrcpf_socio_5);
         FETCH cr_socqtatrmaxult30d
          INTO rw_socqtatrmaxult30d;
         CLOSE cr_socqtatrmaxult30d;
         vr_obj_generic4.put('SocQtatrMaxUlt30d', este0001.fn_decimal_ibra(NVL(rw_socqtatrmaxult30d.qtdiaatr,0)));
      END IF;

      -- Buscar os valores dos vencimentos para alimentar as variáveis internas
      OPEN cr_crapvopvi(rw_crapass.nrcpfcgc, rw_crapopf.dtrefere);
      FETCH cr_crapvopvi
       INTO rw_crapvopvi;
      CLOSE cr_crapvopvi;

      -- Complemento de mensagem
      vr_dscritaux := 'Busca variaveis H';


      -- Buscar as informações para as variáveis H0

      -- udm somente para Pessoas Fisicas
      IF rw_crapass.inpessoa = 1 THEN

         -- PF - Busca Quantidade de dias de atraso do ultimo dia do mês da ultima data base disponivel
         FOR rw_qtatr_udm IN cr_qtatr_udm(rw_crapass.nrcpfcgc
                                         ,vr_dtrefere_ris) LOOP
           vr_ind := 0;
           IF    rw_qtatr_udm.dtrefere = vr_dtrefere_ris     THEN  vr_ind := 1;
           ELSIF rw_qtatr_udm.dtrefere = last_day(add_months(vr_dtrefere_ris,-1))  THEN  vr_ind := 2;
           ELSIF rw_qtatr_udm.dtrefere = last_day(add_months(vr_dtrefere_ris,-2))  THEN  vr_ind := 3;
           ELSIF rw_qtatr_udm.dtrefere = last_day(add_months(vr_dtrefere_ris,-3))  THEN  vr_ind := 4;
           ELSIF rw_qtatr_udm.dtrefere = last_day(add_months(vr_dtrefere_ris,-4))  THEN  vr_ind := 5;
           ELSIF rw_qtatr_udm.dtrefere = last_day(add_months(vr_dtrefere_ris,-5))  THEN  vr_ind := 6;
           ELSIF rw_qtatr_udm.dtrefere = last_day(add_months(vr_dtrefere_ris,-6))  THEN  vr_ind := 7;
           ELSIF rw_qtatr_udm.dtrefere = last_day(add_months(vr_dtrefere_ris,-7))  THEN  vr_ind := 8;
           ELSIF rw_qtatr_udm.dtrefere = last_day(add_months(vr_dtrefere_ris,-8))  THEN  vr_ind := 9;
           ELSIF rw_qtatr_udm.dtrefere = last_day(add_months(vr_dtrefere_ris,-9))  THEN  vr_ind := 10;
           ELSIF rw_qtatr_udm.dtrefere = last_day(add_months(vr_dtrefere_ris,-10)) THEN  vr_ind := 11;
           ELSIF rw_qtatr_udm.dtrefere = last_day(add_months(vr_dtrefere_ris,-11)) THEN  vr_ind := 12;
           END IF;
           --
           if vr_ind > 0 THEN
              vr_qtatr_udm(vr_ind) := nvl(rw_qtatr_udm.qtatr_udm,0);
           END IF;
         END LOOP;
         vr_obj_generic4.put('qtatr_udm_h0',  este0001.fn_decimal_ibra(nvl(vr_qtatr_udm(1),0)));
      END IF;

      vr_obj_generic4.put('vl_prejuizo_ult48m_h0', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_prejuizo_ult48m,0)));
      vr_obj_generic4.put('vl_venc_180d_h0', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_venc_180d,0)));
      vr_obj_generic4.put('vl_venc_120d_h0', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_venc_120d,0)));
      vr_obj_generic4.put('vl_venc_90d_h0', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_venc_90d,0)));
      vr_obj_generic4.put('vl_venc_60d_h0', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_venc_60d,0)));
      vr_obj_generic4.put('vl_venc_30d_h0', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_venc_30d,0)));
      vr_obj_generic4.put('vl_venc_15d_h0', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_venc_15d,0)));
      vr_obj_generic4.put('vl_sld_devedor_total_h0', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_sld_devedor_total,0)));
      vr_obj_generic4.put('vl_limite_disponivel_h0', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_limite_disponivel,0)));
      vr_obj_generic4.put('vl_sld_devedor_total_Rot_h0', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_sld_devedor_total_Rot,0)));
      vr_obj_generic4.put('vl_sld_devedor_total_CarRot_h0', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_sld_devedor_total_CarRot,0)));

      --qtd_atr_Ext_h0

       vr_qtd_atr_Ext(1) := fn_obter_qtd_atr_Ext(rw_crapvopvi.vl_prejuizo_ult48m
                                               ,rw_crapvopvi.vl_venc_180d
                                               ,rw_crapvopvi.vl_venc_120d
                                               ,rw_crapvopvi.vl_venc_90d
                                               ,rw_crapvopvi.vl_venc_60d
                                               ,rw_crapvopvi.vl_venc_30d
                                               ,rw_crapvopvi.vl_venc_15d);
      vr_obj_generic4.put('qtd_atr_Ext_h0', este0001.fn_decimal_ibra(vr_qtd_atr_Ext(1)));

      vr_vl_limite(1) := nvl(rw_crapvopvi.vl_limite_disponivel,0)
                       + nvl(rw_crapvopvi.vl_sld_devedor_total_Rot,0);
      vr_obj_generic4.put('vl_limite_h0', este0001.fn_decimal_ibra(vr_vl_limite(1)));

      vr_Pc_Utiliz_limite(1) := fn_obter_Pc_Utiliz_limite(vr_vl_limite(1),rw_crapvopvi.vl_limite_disponivel);
      vr_obj_generic4.put('Pc_Utiliz_limite_h0', este0001.fn_decimal_ibra(vr_Pc_Utiliz_limite(1)));

      vr_Pc_Utiliz_limite_CarRot(1) := fn_obter_Pc_Utiliz_lim_Rot(vr_vl_limite(1)
                                                                 ,rw_crapvopvi.vl_sld_devedor_total_CarRot);

      vr_vl_sld_devedor_total(1)  := nvl(rw_crapvopvi.vl_sld_devedor_total,0);
      vr_vl_sld_devedor_Rot(1)    := nvl(rw_crapvopvi.vl_sld_devedor_total_Rot,0);
      vr_vl_sld_devedor_CarRot(1) := nvl(rw_crapvopvi.vl_sld_devedor_total_CarRot,0);


      -- Buscar as informações para as variáveis H1

      -- udm somente para Pessoas Fisicas
      IF rw_crapass.inpessoa = 1 THEN
         vr_obj_generic4.put('qtatr_udm_h1',  este0001.fn_decimal_ibra(vr_qtatr_udm(2)));
      END IF;

      OPEN cr_crapvopvi(rw_crapass.nrcpfcgc, add_months(rw_crapopf.dtrefere,-1));
      FETCH cr_crapvopvi
       INTO rw_crapvopvi;
      CLOSE cr_crapvopvi;

      vr_obj_generic4.put('vl_prejuizo_ult48m_h1', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_prejuizo_ult48m,0)));
      vr_obj_generic4.put('vl_venc_180d_h1', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_venc_180d,0)));
      vr_obj_generic4.put('vl_venc_120d_h1', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_venc_120d,0)));
      vr_obj_generic4.put('vl_venc_90d_h1', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_venc_90d,0)));
      vr_obj_generic4.put('vl_venc_60d_h1', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_venc_60d,0)));
      vr_obj_generic4.put('vl_venc_30d_h1', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_venc_30d,0)));
      vr_obj_generic4.put('vl_venc_15d_h1', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_venc_15d,0)));
      vr_obj_generic4.put('vl_sld_devedor_total_h1', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_sld_devedor_total,0)));
      vr_obj_generic4.put('vl_limite_disponivel_h1', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_limite_disponivel,0)));
      vr_obj_generic4.put('vl_sld_devedor_total_Rot_h1', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_sld_devedor_total_Rot,0)));
      vr_obj_generic4.put('vl_sld_devedor_total_CarRot_h1', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_sld_devedor_total_CarRot,0)));

      vr_qtd_atr_Ext(2) := fn_obter_qtd_atr_Ext(rw_crapvopvi.vl_prejuizo_ult48m
                                               ,rw_crapvopvi.vl_venc_180d
                                               ,rw_crapvopvi.vl_venc_120d
                                               ,rw_crapvopvi.vl_venc_90d
                                               ,rw_crapvopvi.vl_venc_60d
                                               ,rw_crapvopvi.vl_venc_30d
                                               ,rw_crapvopvi.vl_venc_15d);
      vr_obj_generic4.put('qtd_atr_Ext_h1', este0001.fn_decimal_ibra(vr_qtd_atr_Ext(2)));

      vr_vl_limite(2) := nvl(rw_crapvopvi.vl_limite_disponivel,0)
                       + nvl(rw_crapvopvi.vl_sld_devedor_total_Rot,0);
      vr_obj_generic4.put('vl_limite_h1', este0001.fn_decimal_ibra(vr_vl_limite(2)));

      vr_Pc_Utiliz_limite_CarRot(2) := fn_obter_Pc_Utiliz_lim_Rot(vr_vl_limite(2)
                                                                 ,rw_crapvopvi.vl_sld_devedor_total_CarRot);

      vr_Pc_Utiliz_limite(2) := fn_obter_Pc_Utiliz_limite(vr_vl_limite(2),rw_crapvopvi.vl_limite_disponivel);
      vr_obj_generic4.put('Pc_Utiliz_limite_h1', este0001.fn_decimal_ibra(vr_Pc_Utiliz_limite(2)));

      vr_vl_sld_devedor_total(2)  := nvl(rw_crapvopvi.vl_sld_devedor_total,0);
      vr_vl_sld_devedor_Rot(2)    := nvl(rw_crapvopvi.vl_sld_devedor_total_Rot,0);
      vr_vl_sld_devedor_CarRot(2) := nvl(rw_crapvopvi.vl_sld_devedor_total_CarRot,0);


      -- Buscar as informações para as variáveis H2

      -- udm somente para Pessoas Fisicas
      IF rw_crapass.inpessoa = 1 THEN
         vr_obj_generic4.put('qtatr_udm_h2',  este0001.fn_decimal_ibra(vr_qtatr_udm(3)));
      END IF;

      OPEN cr_crapvopvi(rw_crapass.nrcpfcgc, add_months(rw_crapopf.dtrefere,-2));
      FETCH cr_crapvopvi
       INTO rw_crapvopvi;
      CLOSE cr_crapvopvi;

      vr_obj_generic4.put('vl_prejuizo_ult48m_h2', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_prejuizo_ult48m,0)));
      vr_obj_generic4.put('vl_venc_180d_h2', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_venc_180d,0)));
      vr_obj_generic4.put('vl_venc_120d_h2', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_venc_120d,0)));
      vr_obj_generic4.put('vl_venc_90d_h2', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_venc_90d,0)));
      vr_obj_generic4.put('vl_venc_60d_h2', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_venc_60d,0)));
      vr_obj_generic4.put('vl_venc_30d_h2', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_venc_30d,0)));
      vr_obj_generic4.put('vl_venc_15d_h2', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_venc_15d,0)));
      vr_obj_generic4.put('vl_sld_devedor_total_h2', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_sld_devedor_total,0)));
      vr_obj_generic4.put('vl_limite_disponivel_h2', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_limite_disponivel,0)));
      vr_obj_generic4.put('vl_sld_devedor_total_Rot_h2', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_sld_devedor_total_Rot,0)));
      vr_obj_generic4.put('vl_sld_devedor_total_CarRot_h2', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_sld_devedor_total_CarRot,0)));

      vr_qtd_atr_Ext(3) := fn_obter_qtd_atr_Ext(rw_crapvopvi.vl_prejuizo_ult48m
                                               ,rw_crapvopvi.vl_venc_180d
                                               ,rw_crapvopvi.vl_venc_120d
                                               ,rw_crapvopvi.vl_venc_90d
                                               ,rw_crapvopvi.vl_venc_60d
                                               ,rw_crapvopvi.vl_venc_30d
                                               ,rw_crapvopvi.vl_venc_15d);
      vr_obj_generic4.put('qtd_atr_Ext_h2', este0001.fn_decimal_ibra(vr_qtd_atr_Ext(3)));

      vr_vl_limite(3) := nvl(rw_crapvopvi.vl_limite_disponivel,0)
                       + nvl(rw_crapvopvi.vl_sld_devedor_total_Rot,0);
      vr_obj_generic4.put('vl_limite_h2', este0001.fn_decimal_ibra(vr_vl_limite(3)));

      vr_Pc_Utiliz_limite_CarRot(3) := fn_obter_Pc_Utiliz_lim_Rot(vr_vl_limite(3)
                                                                 ,rw_crapvopvi.vl_sld_devedor_total_CarRot);

      vr_Pc_Utiliz_limite(3) := fn_obter_Pc_Utiliz_limite(vr_vl_limite(3),rw_crapvopvi.vl_limite_disponivel);
      vr_obj_generic4.put('Pc_Utiliz_limite_h2', este0001.fn_decimal_ibra(vr_Pc_Utiliz_limite(3)));

      vr_vl_sld_devedor_total(3)  := nvl(rw_crapvopvi.vl_sld_devedor_total,0);
      vr_vl_sld_devedor_Rot(3)    := nvl(rw_crapvopvi.vl_sld_devedor_total_Rot,0);
      vr_vl_sld_devedor_CarRot(3) := nvl(rw_crapvopvi.vl_sld_devedor_total_CarRot,0);


      -- Buscar as informações para as variáveis H3

      -- udm somente para Pessoas Fisicas
      IF rw_crapass.inpessoa = 1 THEN
         vr_obj_generic4.put('qtatr_udm_h3',  este0001.fn_decimal_ibra(vr_qtatr_udm(4)));
      END IF;

      OPEN cr_crapvopvi(rw_crapass.nrcpfcgc, add_months(rw_crapopf.dtrefere,-3));
      FETCH cr_crapvopvi
       INTO rw_crapvopvi;
      CLOSE cr_crapvopvi;

      vr_obj_generic4.put('vl_prejuizo_ult48m_h3', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_prejuizo_ult48m,0)));
      vr_obj_generic4.put('vl_venc_180d_h3', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_venc_180d,0)));
      vr_obj_generic4.put('vl_venc_120d_h3', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_venc_120d,0)));
      vr_obj_generic4.put('vl_venc_90d_h3', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_venc_90d,0)));
      vr_obj_generic4.put('vl_venc_60d_h3', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_venc_60d,0)));
      vr_obj_generic4.put('vl_venc_30d_h3', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_venc_30d,0)));
      vr_obj_generic4.put('vl_venc_15d_h3', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_venc_15d,0)));
      vr_obj_generic4.put('vl_sld_devedor_total_h3', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_sld_devedor_total,0)));
      vr_obj_generic4.put('vl_limite_disponivel_h3', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_limite_disponivel,0)));
      vr_obj_generic4.put('vl_sld_devedor_total_Rot_h3', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_sld_devedor_total_Rot,0)));
      vr_obj_generic4.put('vl_sld_devedor_total_CarRot_h3', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_sld_devedor_total_CarRot,0)));

      vr_qtd_atr_Ext(4) := fn_obter_qtd_atr_Ext(rw_crapvopvi.vl_prejuizo_ult48m
                                               ,rw_crapvopvi.vl_venc_180d
                                               ,rw_crapvopvi.vl_venc_120d
                                               ,rw_crapvopvi.vl_venc_90d
                                               ,rw_crapvopvi.vl_venc_60d
                                               ,rw_crapvopvi.vl_venc_30d
                                               ,rw_crapvopvi.vl_venc_15d);
      vr_obj_generic4.put('qtd_atr_Ext_h3', este0001.fn_decimal_ibra(vr_qtd_atr_Ext(4)));

      vr_vl_limite(4) := nvl(rw_crapvopvi.vl_limite_disponivel,0)
                       + nvl(rw_crapvopvi.vl_sld_devedor_total_Rot,0);
      vr_obj_generic4.put('vl_limite_h3', este0001.fn_decimal_ibra(vr_vl_limite(4)));

      vr_Pc_Utiliz_limite_CarRot(4) := fn_obter_Pc_Utiliz_lim_Rot(vr_vl_limite(4)
                                                                 ,rw_crapvopvi.vl_sld_devedor_total_CarRot);

      vr_Pc_Utiliz_limite(4) := fn_obter_Pc_Utiliz_limite(vr_vl_limite(4),rw_crapvopvi.vl_limite_disponivel);
      vr_obj_generic4.put('Pc_Utiliz_limite_h3', este0001.fn_decimal_ibra(vr_Pc_Utiliz_limite(4)));

      vr_vl_sld_devedor_total(4)  := nvl(rw_crapvopvi.vl_sld_devedor_total,0);
      vr_vl_sld_devedor_Rot(4)    := nvl(rw_crapvopvi.vl_sld_devedor_total_Rot,0);
      vr_vl_sld_devedor_CarRot(4) := nvl(rw_crapvopvi.vl_sld_devedor_total_CarRot,0);


      -- Buscar as informações para as variáveis H4

      -- udm somente para Pessoas Fisicas
      IF rw_crapass.inpessoa = 1 THEN
         vr_obj_generic4.put('qtatr_udm_h4',  este0001.fn_decimal_ibra(vr_qtatr_udm(5)));
      END IF;

      OPEN cr_crapvopvi(rw_crapass.nrcpfcgc, add_months(rw_crapopf.dtrefere,-4));
      FETCH cr_crapvopvi
       INTO rw_crapvopvi;
      CLOSE cr_crapvopvi;

      vr_obj_generic4.put('vl_prejuizo_ult48m_h4', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_prejuizo_ult48m,0)));
      vr_obj_generic4.put('vl_venc_180d_h4', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_venc_180d,0)));
      vr_obj_generic4.put('vl_venc_120d_h4', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_venc_120d,0)));
      vr_obj_generic4.put('vl_venc_90d_h4', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_venc_90d,0)));
      vr_obj_generic4.put('vl_venc_60d_h4', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_venc_60d,0)));
      vr_obj_generic4.put('vl_venc_30d_h4', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_venc_30d,0)));
      vr_obj_generic4.put('vl_venc_15d_h4', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_venc_15d,0)));
      vr_obj_generic4.put('vl_sld_devedor_total_h4', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_sld_devedor_total,0)));
      vr_obj_generic4.put('vl_limite_disponivel_h4', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_limite_disponivel,0)));
      vr_obj_generic4.put('vl_sld_devedor_total_Rot_h4', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_sld_devedor_total_Rot,0)));
      vr_obj_generic4.put('vl_sld_devedor_total_CarRot_h4', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_sld_devedor_total_CarRot,0)));

      vr_qtd_atr_Ext(5) := fn_obter_qtd_atr_Ext(rw_crapvopvi.vl_prejuizo_ult48m
                                               ,rw_crapvopvi.vl_venc_180d
                                               ,rw_crapvopvi.vl_venc_120d
                                               ,rw_crapvopvi.vl_venc_90d
                                               ,rw_crapvopvi.vl_venc_60d
                                               ,rw_crapvopvi.vl_venc_30d
                                               ,rw_crapvopvi.vl_venc_15d);
      vr_obj_generic4.put('qtd_atr_Ext_h4', este0001.fn_decimal_ibra(vr_qtd_atr_Ext(5)));

      vr_vl_limite(5) := nvl(rw_crapvopvi.vl_limite_disponivel,0)
                       + nvl(rw_crapvopvi.vl_sld_devedor_total_Rot,0);
      vr_obj_generic4.put('vl_limite_h4', este0001.fn_decimal_ibra(vr_vl_limite(5)));

      vr_Pc_Utiliz_limite_CarRot(5) := fn_obter_Pc_Utiliz_lim_Rot(vr_vl_limite(5)
                                                                 ,rw_crapvopvi.vl_sld_devedor_total_CarRot);

      vr_Pc_Utiliz_limite(5) := fn_obter_Pc_Utiliz_limite(vr_vl_limite(5),rw_crapvopvi.vl_limite_disponivel);
      vr_obj_generic4.put('Pc_Utiliz_limite_h4', este0001.fn_decimal_ibra(vr_Pc_Utiliz_limite(5)));

      vr_vl_sld_devedor_total(5)  := nvl(rw_crapvopvi.vl_sld_devedor_total,0);
      vr_vl_sld_devedor_Rot(5)    := nvl(rw_crapvopvi.vl_sld_devedor_total_Rot,0);
      vr_vl_sld_devedor_CarRot(5) := nvl(rw_crapvopvi.vl_sld_devedor_total_CarRot,0);


      -- Buscar as informações para as variáveis H5

      -- udm somente para Pessoas Fisicas
      IF rw_crapass.inpessoa = 1 THEN
         vr_obj_generic4.put('qtatr_udm_h5',  este0001.fn_decimal_ibra(vr_qtatr_udm(6)));
      END IF;

      OPEN cr_crapvopvi(rw_crapass.nrcpfcgc, add_months(rw_crapopf.dtrefere,-5));
      FETCH cr_crapvopvi
       INTO rw_crapvopvi;
      CLOSE cr_crapvopvi;

      vr_obj_generic4.put('vl_prejuizo_ult48m_h5', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_prejuizo_ult48m,0)));
      vr_obj_generic4.put('vl_venc_180d_h5', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_venc_180d,0)));
      vr_obj_generic4.put('vl_venc_120d_h5', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_venc_120d,0)));
      vr_obj_generic4.put('vl_venc_90d_h5', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_venc_90d,0)));
      vr_obj_generic4.put('vl_venc_60d_h5', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_venc_60d,0)));
      vr_obj_generic4.put('vl_venc_30d_h5', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_venc_30d,0)));
      vr_obj_generic4.put('vl_venc_15d_h5', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_venc_15d,0)));
      vr_obj_generic4.put('vl_sld_devedor_total_h5', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_sld_devedor_total,0)));
      vr_obj_generic4.put('vl_limite_disponivel_h5', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_limite_disponivel,0)));
      vr_obj_generic4.put('vl_sld_devedor_total_Rot_h5', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_sld_devedor_total_Rot,0)));
      vr_obj_generic4.put('vl_sld_devedor_total_CarRot_h5', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_sld_devedor_total_CarRot,0)));

      vr_qtd_atr_Ext(6) := fn_obter_qtd_atr_Ext(rw_crapvopvi.vl_prejuizo_ult48m
                                               ,rw_crapvopvi.vl_venc_180d
                                               ,rw_crapvopvi.vl_venc_120d
                                               ,rw_crapvopvi.vl_venc_90d
                                               ,rw_crapvopvi.vl_venc_60d
                                               ,rw_crapvopvi.vl_venc_30d
                                               ,rw_crapvopvi.vl_venc_15d);
      vr_obj_generic4.put('qtd_atr_Ext_h5', este0001.fn_decimal_ibra(vr_qtd_atr_Ext(6)));

      vr_vl_limite(6) := nvl(rw_crapvopvi.vl_limite_disponivel,0)
                       + nvl(rw_crapvopvi.vl_sld_devedor_total_Rot,0);
      vr_obj_generic4.put('vl_limite_h5', este0001.fn_decimal_ibra(vr_vl_limite(6)));

      vr_Pc_Utiliz_limite_CarRot(6) := fn_obter_Pc_Utiliz_lim_Rot(vr_vl_limite(6)
                                                                 ,rw_crapvopvi.vl_sld_devedor_total_CarRot);

      vr_Pc_Utiliz_limite(6) := fn_obter_Pc_Utiliz_limite(vr_vl_limite(6),rw_crapvopvi.vl_limite_disponivel);
      vr_obj_generic4.put('Pc_Utiliz_limite_h5', este0001.fn_decimal_ibra(vr_Pc_Utiliz_limite(6)));

      vr_vl_sld_devedor_total(6)  := nvl(rw_crapvopvi.vl_sld_devedor_total,0);
      vr_vl_sld_devedor_Rot(6)    := nvl(rw_crapvopvi.vl_sld_devedor_total_Rot,0);
      vr_vl_sld_devedor_CarRot(6) := nvl(rw_crapvopvi.vl_sld_devedor_total_CarRot,0);


      -- Buscar as informações para as variáveis H6

      -- udm somente para Pessoas Fisicas
      IF rw_crapass.inpessoa = 1 THEN
         vr_obj_generic4.put('qtatr_udm_h6',  este0001.fn_decimal_ibra(vr_qtatr_udm(7)));
      END IF;

      OPEN cr_crapvopvi(rw_crapass.nrcpfcgc, add_months(rw_crapopf.dtrefere,-6));
      FETCH cr_crapvopvi
       INTO rw_crapvopvi;
      CLOSE cr_crapvopvi;

      vr_obj_generic4.put('vl_prejuizo_ult48m_h6', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_prejuizo_ult48m,0)));
      vr_obj_generic4.put('vl_venc_180d_h6', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_venc_180d,0)));
      vr_obj_generic4.put('vl_venc_120d_h6', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_venc_120d,0)));
      vr_obj_generic4.put('vl_venc_90d_h6', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_venc_90d,0)));
      vr_obj_generic4.put('vl_venc_60d_h6', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_venc_60d,0)));
      vr_obj_generic4.put('vl_venc_30d_h6', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_venc_30d,0)));
      vr_obj_generic4.put('vl_venc_15d_h6', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_venc_15d,0)));
      vr_obj_generic4.put('vl_sld_devedor_total_h6', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_sld_devedor_total,0)));
      vr_obj_generic4.put('vl_limite_disponivel_h6', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_limite_disponivel,0)));
      vr_obj_generic4.put('vl_sld_devedor_total_Rot_h6', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_sld_devedor_total_Rot,0)));
      vr_obj_generic4.put('vl_sld_devedor_total_CarRot_h6', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_sld_devedor_total_CarRot,0)));

      vr_qtd_atr_Ext(7) := fn_obter_qtd_atr_Ext(rw_crapvopvi.vl_prejuizo_ult48m
                                               ,rw_crapvopvi.vl_venc_180d
                                               ,rw_crapvopvi.vl_venc_120d
                                               ,rw_crapvopvi.vl_venc_90d
                                               ,rw_crapvopvi.vl_venc_60d
                                               ,rw_crapvopvi.vl_venc_30d
                                               ,rw_crapvopvi.vl_venc_15d);
      vr_obj_generic4.put('qtd_atr_Ext_h6', este0001.fn_decimal_ibra(vr_qtd_atr_Ext(7)));

      vr_vl_limite(7) := nvl(rw_crapvopvi.vl_limite_disponivel,0)
                       + nvl(rw_crapvopvi.vl_sld_devedor_total_Rot,0);
      vr_obj_generic4.put('vl_limite_h6', este0001.fn_decimal_ibra(vr_vl_limite(7)));

      vr_Pc_Utiliz_limite_CarRot(7) := fn_obter_Pc_Utiliz_lim_Rot(vr_vl_limite(7)
                                                                 ,rw_crapvopvi.vl_sld_devedor_total_CarRot);

      vr_Pc_Utiliz_limite(7) := fn_obter_Pc_Utiliz_limite(vr_vl_limite(7),rw_crapvopvi.vl_limite_disponivel);
      vr_obj_generic4.put('Pc_Utiliz_limite_h6', este0001.fn_decimal_ibra(vr_Pc_Utiliz_limite(7)));

      vr_vl_sld_devedor_total(7)  := nvl(rw_crapvopvi.vl_sld_devedor_total,0);
      vr_vl_sld_devedor_Rot(7)    := nvl(rw_crapvopvi.vl_sld_devedor_total_Rot,0);
      vr_vl_sld_devedor_CarRot(7) := nvl(rw_crapvopvi.vl_sld_devedor_total_CarRot,0);


      -- Buscar as informações para as variáveis H7

      -- udm somente para Pessoas Fisicas
      IF rw_crapass.inpessoa = 1 THEN
         vr_obj_generic4.put('qtatr_udm_h7',  este0001.fn_decimal_ibra(vr_qtatr_udm(8)));
      END IF;

      OPEN cr_crapvopvi(rw_crapass.nrcpfcgc, add_months(rw_crapopf.dtrefere,-7));
      FETCH cr_crapvopvi
       INTO rw_crapvopvi;
      CLOSE cr_crapvopvi;

      vr_obj_generic4.put('vl_prejuizo_ult48m_h7', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_prejuizo_ult48m,0)));
      vr_obj_generic4.put('vl_venc_180d_h7', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_venc_180d,0)));
      vr_obj_generic4.put('vl_venc_120d_h7', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_venc_120d,0)));
      vr_obj_generic4.put('vl_venc_90d_h7', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_venc_90d,0)));
      vr_obj_generic4.put('vl_venc_60d_h7', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_venc_60d,0)));
      vr_obj_generic4.put('vl_venc_30d_h7', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_venc_30d,0)));
      vr_obj_generic4.put('vl_venc_15d_h7', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_venc_15d,0)));
      vr_obj_generic4.put('vl_sld_devedor_total_h7', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_sld_devedor_total,0)));
      vr_obj_generic4.put('vl_limite_disponivel_h7', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_limite_disponivel,0)));
      vr_obj_generic4.put('vl_sld_devedor_total_Rot_h7', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_sld_devedor_total_Rot,0)));
      vr_obj_generic4.put('vl_sld_devedor_total_CarRot_h7', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_sld_devedor_total_CarRot,0)));

      vr_qtd_atr_Ext(8) := fn_obter_qtd_atr_Ext(rw_crapvopvi.vl_prejuizo_ult48m
                                               ,rw_crapvopvi.vl_venc_180d
                                               ,rw_crapvopvi.vl_venc_120d
                                               ,rw_crapvopvi.vl_venc_90d
                                               ,rw_crapvopvi.vl_venc_60d
                                               ,rw_crapvopvi.vl_venc_30d
                                               ,rw_crapvopvi.vl_venc_15d);
      vr_obj_generic4.put('qtd_atr_Ext_h7', este0001.fn_decimal_ibra(vr_qtd_atr_Ext(8)));

      vr_vl_limite(8) := nvl(rw_crapvopvi.vl_limite_disponivel,0)
                       + nvl(rw_crapvopvi.vl_sld_devedor_total_Rot,0);
      vr_obj_generic4.put('vl_limite_h7', este0001.fn_decimal_ibra(vr_vl_limite(8)));

      vr_Pc_Utiliz_limite_CarRot(8) := fn_obter_Pc_Utiliz_lim_Rot(vr_vl_limite(8)
                                                                 ,rw_crapvopvi.vl_sld_devedor_total_CarRot);

      vr_Pc_Utiliz_limite(8) := fn_obter_Pc_Utiliz_limite(vr_vl_limite(8),rw_crapvopvi.vl_limite_disponivel);
      vr_obj_generic4.put('Pc_Utiliz_limite_h7', este0001.fn_decimal_ibra(vr_Pc_Utiliz_limite(8)));

      vr_vl_sld_devedor_total(8)  := nvl(rw_crapvopvi.vl_sld_devedor_total,0);
      vr_vl_sld_devedor_Rot(8)    := nvl(rw_crapvopvi.vl_sld_devedor_total_Rot,0);
      vr_vl_sld_devedor_CarRot(8) := nvl(rw_crapvopvi.vl_sld_devedor_total_CarRot,0);


      -- Buscar as informações para as variáveis H8

      -- udm somente para Pessoas Fisicas
      IF rw_crapass.inpessoa = 1 THEN
         vr_obj_generic4.put('qtatr_udm_h8',  este0001.fn_decimal_ibra(vr_qtatr_udm(9)));
      END IF;

      OPEN cr_crapvopvi(rw_crapass.nrcpfcgc, add_months(rw_crapopf.dtrefere,-8));
      FETCH cr_crapvopvi
       INTO rw_crapvopvi;
      CLOSE cr_crapvopvi;

      vr_obj_generic4.put('vl_prejuizo_ult48m_h8', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_prejuizo_ult48m,0)));
      vr_obj_generic4.put('vl_venc_180d_h8', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_venc_180d,0)));
      vr_obj_generic4.put('vl_venc_120d_h8', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_venc_120d,0)));
      vr_obj_generic4.put('vl_venc_90d_h8', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_venc_90d,0)));
      vr_obj_generic4.put('vl_venc_60d_h8', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_venc_60d,0)));
      vr_obj_generic4.put('vl_venc_30d_h8', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_venc_30d,0)));
      vr_obj_generic4.put('vl_venc_15d_h8', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_venc_15d,0)));
      vr_obj_generic4.put('vl_sld_devedor_total_h8', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_sld_devedor_total,0)));
      vr_obj_generic4.put('vl_limite_disponivel_h8', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_limite_disponivel,0)));
      vr_obj_generic4.put('vl_sld_devedor_total_Rot_h8', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_sld_devedor_total_Rot,0)));
      vr_obj_generic4.put('vl_sld_devedor_total_CarRot_h8', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_sld_devedor_total_CarRot,0)));

      vr_qtd_atr_Ext(9) := fn_obter_qtd_atr_Ext(rw_crapvopvi.vl_prejuizo_ult48m
                                               ,rw_crapvopvi.vl_venc_180d
                                               ,rw_crapvopvi.vl_venc_120d
                                               ,rw_crapvopvi.vl_venc_90d
                                               ,rw_crapvopvi.vl_venc_60d
                                               ,rw_crapvopvi.vl_venc_30d
                                               ,rw_crapvopvi.vl_venc_15d);
      vr_obj_generic4.put('qtd_atr_Ext_h8', este0001.fn_decimal_ibra(vr_qtd_atr_Ext(9)));

      vr_vl_limite(9) := nvl(rw_crapvopvi.vl_limite_disponivel,0)
                       + nvl(rw_crapvopvi.vl_sld_devedor_total_Rot,0);
      vr_obj_generic4.put('vl_limite_h8', este0001.fn_decimal_ibra(vr_vl_limite(9)));

      vr_Pc_Utiliz_limite_CarRot(9) := fn_obter_Pc_Utiliz_lim_Rot(vr_vl_limite(9)
                                                                 ,rw_crapvopvi.vl_sld_devedor_total_CarRot);

      vr_Pc_Utiliz_limite(9) := fn_obter_Pc_Utiliz_limite(vr_vl_limite(9),rw_crapvopvi.vl_limite_disponivel);
      vr_obj_generic4.put('Pc_Utiliz_limite_h8', este0001.fn_decimal_ibra(vr_Pc_Utiliz_limite(9)));

      vr_vl_sld_devedor_total(9)  := nvl(rw_crapvopvi.vl_sld_devedor_total,0);
      vr_vl_sld_devedor_Rot(9)    := nvl(rw_crapvopvi.vl_sld_devedor_total_Rot,0);
      vr_vl_sld_devedor_CarRot(9) := nvl(rw_crapvopvi.vl_sld_devedor_total_CarRot,0);


      -- Buscar as informações para as variáveis H9

      -- udm somente para Pessoas Fisicas
      IF rw_crapass.inpessoa = 1 THEN
         vr_obj_generic4.put('qtatr_udm_h9',  este0001.fn_decimal_ibra(vr_qtatr_udm(10)));
      END IF;

      OPEN cr_crapvopvi(rw_crapass.nrcpfcgc, add_months(rw_crapopf.dtrefere,-9));
      FETCH cr_crapvopvi
       INTO rw_crapvopvi;
      CLOSE cr_crapvopvi;

      vr_obj_generic4.put('vl_prejuizo_ult48m_h9', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_prejuizo_ult48m,0)));
      vr_obj_generic4.put('vl_venc_180d_h9', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_venc_180d,0)));
      vr_obj_generic4.put('vl_venc_120d_h9', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_venc_120d,0)));
      vr_obj_generic4.put('vl_venc_90d_h9', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_venc_90d,0)));
      vr_obj_generic4.put('vl_venc_60d_h9', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_venc_60d,0)));
      vr_obj_generic4.put('vl_venc_30d_h9', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_venc_30d,0)));
      vr_obj_generic4.put('vl_venc_15d_h9', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_venc_15d,0)));
      vr_obj_generic4.put('vl_sld_devedor_total_h9', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_sld_devedor_total,0)));
      vr_obj_generic4.put('vl_limite_disponivel_h9', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_limite_disponivel,0)));
      vr_obj_generic4.put('vl_sld_devedor_total_Rot_h9', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_sld_devedor_total_Rot,0)));
      vr_obj_generic4.put('vl_sld_devedor_total_CarRot_h9', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_sld_devedor_total_CarRot,0)));

      vr_qtd_atr_Ext(10) := fn_obter_qtd_atr_Ext(rw_crapvopvi.vl_prejuizo_ult48m
                                                ,rw_crapvopvi.vl_venc_180d
                                                ,rw_crapvopvi.vl_venc_120d
                                                ,rw_crapvopvi.vl_venc_90d
                                                ,rw_crapvopvi.vl_venc_60d
                                                ,rw_crapvopvi.vl_venc_30d
                                                ,rw_crapvopvi.vl_venc_15d);
      vr_obj_generic4.put('qtd_atr_Ext_h9', este0001.fn_decimal_ibra(vr_qtd_atr_Ext(10)));

      vr_vl_limite(10) := nvl(rw_crapvopvi.vl_limite_disponivel,0)
                        + nvl(rw_crapvopvi.vl_sld_devedor_total_Rot,0);
      vr_obj_generic4.put('vl_limite_h9', este0001.fn_decimal_ibra(vr_vl_limite(10)));

      vr_Pc_Utiliz_limite_CarRot(10) := fn_obter_Pc_Utiliz_lim_Rot(vr_vl_limite(10)
                                                                 ,rw_crapvopvi.vl_sld_devedor_total_CarRot);

      vr_Pc_Utiliz_limite(10) := fn_obter_Pc_Utiliz_limite(vr_vl_limite(10),rw_crapvopvi.vl_limite_disponivel);
      vr_obj_generic4.put('Pc_Utiliz_limite_h9', este0001.fn_decimal_ibra(vr_Pc_Utiliz_limite(10)));

      vr_vl_sld_devedor_total(10)  := nvl(rw_crapvopvi.vl_sld_devedor_total,0);
      vr_vl_sld_devedor_Rot(10)    := nvl(rw_crapvopvi.vl_sld_devedor_total_Rot,0);
      vr_vl_sld_devedor_CarRot(10) := nvl(rw_crapvopvi.vl_sld_devedor_total_CarRot,0);


      -- Buscar as informações para as variáveis H10

      -- udm somente para Pessoas Fisicas
      IF rw_crapass.inpessoa = 1 THEN
         vr_obj_generic4.put('qtatr_udm_h10',  este0001.fn_decimal_ibra(vr_qtatr_udm(11)));
      END IF;

      OPEN cr_crapvopvi(rw_crapass.nrcpfcgc, add_months(rw_crapopf.dtrefere,-10));
      FETCH cr_crapvopvi
       INTO rw_crapvopvi;
      CLOSE cr_crapvopvi;

      vr_obj_generic4.put('vl_prejuizo_ult48m_h10', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_prejuizo_ult48m,0)));
      vr_obj_generic4.put('vl_venc_180d_h10', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_venc_180d,0)));
      vr_obj_generic4.put('vl_venc_120d_h10', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_venc_120d,0)));
      vr_obj_generic4.put('vl_venc_90d_h10', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_venc_90d,0)));
      vr_obj_generic4.put('vl_venc_60d_h10', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_venc_60d,0)));
      vr_obj_generic4.put('vl_venc_30d_h10', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_venc_30d,0)));
      vr_obj_generic4.put('vl_venc_15d_h10', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_venc_15d,0)));
      vr_obj_generic4.put('vl_sld_devedor_total_h10', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_sld_devedor_total,0)));
      vr_obj_generic4.put('vl_limite_disponivel_h10', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_limite_disponivel,0)));
      vr_obj_generic4.put('vl_sld_devedor_total_Rot_h10', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_sld_devedor_total_Rot,0)));
      vr_obj_generic4.put('vl_sld_devedor_total_CarRot_h10', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_sld_devedor_total_CarRot,0)));

      vr_qtd_atr_Ext(11) := fn_obter_qtd_atr_Ext(rw_crapvopvi.vl_prejuizo_ult48m
                                                ,rw_crapvopvi.vl_venc_180d
                                                ,rw_crapvopvi.vl_venc_120d
                                                ,rw_crapvopvi.vl_venc_90d
                                                ,rw_crapvopvi.vl_venc_60d
                                                ,rw_crapvopvi.vl_venc_30d
                                                ,rw_crapvopvi.vl_venc_15d);
      vr_obj_generic4.put('qtd_atr_Ext_h10', este0001.fn_decimal_ibra(vr_qtd_atr_Ext(11)));

      vr_vl_limite(11) := nvl(rw_crapvopvi.vl_limite_disponivel,0)
                        + nvl(rw_crapvopvi.vl_sld_devedor_total_Rot,0);
      vr_obj_generic4.put('vl_limite_h10', este0001.fn_decimal_ibra(vr_vl_limite(11)));

      vr_Pc_Utiliz_limite_CarRot(11) := fn_obter_Pc_Utiliz_lim_Rot(vr_vl_limite(11)
                                                                 ,rw_crapvopvi.vl_sld_devedor_total_CarRot);

      vr_Pc_Utiliz_limite(11) := fn_obter_Pc_Utiliz_limite(vr_vl_limite(11),rw_crapvopvi.vl_limite_disponivel);
      vr_obj_generic4.put('Pc_Utiliz_limite_h10', este0001.fn_decimal_ibra(vr_Pc_Utiliz_limite(11)));

      vr_vl_sld_devedor_total(11)  := nvl(rw_crapvopvi.vl_sld_devedor_total,0);
      vr_vl_sld_devedor_Rot(11)    := nvl(rw_crapvopvi.vl_sld_devedor_total_Rot,0);
      vr_vl_sld_devedor_CarRot(11) := nvl(rw_crapvopvi.vl_sld_devedor_total_CarRot,0);


      -- Buscar as informações para as variáveis H11

      -- udm somente para Pessoas Fisicas
      IF rw_crapass.inpessoa = 1 THEN
         vr_obj_generic4.put('qtatr_udm_h11',  este0001.fn_decimal_ibra(vr_qtatr_udm(12)));
      END IF;

      OPEN cr_crapvopvi(rw_crapass.nrcpfcgc, add_months(rw_crapopf.dtrefere,-11));
      FETCH cr_crapvopvi
       INTO rw_crapvopvi;
      CLOSE cr_crapvopvi;

      vr_obj_generic4.put('vl_prejuizo_ult48m_h11', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_prejuizo_ult48m,0)));
      vr_obj_generic4.put('vl_venc_180d_h11', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_venc_180d,0)));
      vr_obj_generic4.put('vl_venc_120d_h11', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_venc_120d,0)));
      vr_obj_generic4.put('vl_venc_90d_h11', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_venc_90d,0)));
      vr_obj_generic4.put('vl_venc_60d_h11', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_venc_60d,0)));
      vr_obj_generic4.put('vl_venc_30d_h11', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_venc_30d,0)));
      vr_obj_generic4.put('vl_venc_15d_h11', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_venc_15d,0)));
      vr_obj_generic4.put('vl_sld_devedor_total_h11', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_sld_devedor_total,0)));
      vr_obj_generic4.put('vl_limite_disponivel_h11', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_limite_disponivel,0)));
      vr_obj_generic4.put('vl_sld_devedor_total_Rot_h11', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_sld_devedor_total_Rot,0)));
      vr_obj_generic4.put('vl_sld_devedor_total_CarRot_h11', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_sld_devedor_total_CarRot,0)));

      vr_qtd_atr_Ext(12) := fn_obter_qtd_atr_Ext(rw_crapvopvi.vl_prejuizo_ult48m
                                                ,rw_crapvopvi.vl_venc_180d
                                                ,rw_crapvopvi.vl_venc_120d
                                                ,rw_crapvopvi.vl_venc_90d
                                                ,rw_crapvopvi.vl_venc_60d
                                                ,rw_crapvopvi.vl_venc_30d
                                                ,rw_crapvopvi.vl_venc_15d);
      vr_obj_generic4.put('qtd_atr_Ext_h11', este0001.fn_decimal_ibra(vr_qtd_atr_Ext(12)));

      vr_vl_limite(12) := nvl(rw_crapvopvi.vl_limite_disponivel,0)
                        + nvl(rw_crapvopvi.vl_sld_devedor_total_Rot,0);
      vr_obj_generic4.put('vl_limite_h11', este0001.fn_decimal_ibra(vr_vl_limite(12)));

      vr_Pc_Utiliz_limite_CarRot(12) := fn_obter_Pc_Utiliz_lim_Rot(vr_vl_limite(12)
                                                                 ,rw_crapvopvi.vl_sld_devedor_total_CarRot);

      vr_Pc_Utiliz_limite(12) := fn_obter_Pc_Utiliz_limite(vr_vl_limite(12),rw_crapvopvi.vl_limite_disponivel);
      vr_obj_generic4.put('Pc_Utiliz_limite_h11', este0001.fn_decimal_ibra(vr_Pc_Utiliz_limite(12)));

      vr_vl_sld_devedor_total(12)  := nvl(rw_crapvopvi.vl_sld_devedor_total,0);
      vr_vl_sld_devedor_CarRot(12) := nvl(rw_crapvopvi.vl_sld_devedor_total_CarRot,0);

      -- Complemento de mensagem
      vr_dscritaux := 'Calcula indicadores';

      --Quantidade de meses com meses com ocorrencia de saldo devedor total de produtos com
      --caracteristica de rotativo (cheque especial, cartão, conta garantida, adp) nos últimos 12 meses
      vr_qt_CarRotO12 := 0;
      if vr_vl_sld_devedor_CarRot(01) > 0 then vr_qt_CarRotO12 := vr_qt_CarRotO12 +1; end if;
      if vr_vl_sld_devedor_CarRot(02) > 0 then vr_qt_CarRotO12 := vr_qt_CarRotO12 +1; end if;
      if vr_vl_sld_devedor_CarRot(03) > 0 then vr_qt_CarRotO12 := vr_qt_CarRotO12 +1; end if;
      if vr_vl_sld_devedor_CarRot(04) > 0 then vr_qt_CarRotO12 := vr_qt_CarRotO12 +1; end if;
      if vr_vl_sld_devedor_CarRot(05) > 0 then vr_qt_CarRotO12 := vr_qt_CarRotO12 +1; end if;
      if vr_vl_sld_devedor_CarRot(06) > 0 then vr_qt_CarRotO12 := vr_qt_CarRotO12 +1; end if;
      if vr_vl_sld_devedor_CarRot(07) > 0 then vr_qt_CarRotO12 := vr_qt_CarRotO12 +1; end if;
      if vr_vl_sld_devedor_CarRot(08) > 0 then vr_qt_CarRotO12 := vr_qt_CarRotO12 +1; end if;
      if vr_vl_sld_devedor_CarRot(09) > 0 then vr_qt_CarRotO12 := vr_qt_CarRotO12 +1; end if;
      if vr_vl_sld_devedor_CarRot(10) > 0 then vr_qt_CarRotO12 := vr_qt_CarRotO12 +1; end if;
      if vr_vl_sld_devedor_CarRot(11) > 0 then vr_qt_CarRotO12 := vr_qt_CarRotO12 +1; end if;
      if vr_vl_sld_devedor_CarRot(12) > 0 then vr_qt_CarRotO12 := vr_qt_CarRotO12 +1; end if;
         vr_obj_generic4.put('vl_sld_devedor_total_CarRotQo12', este0001.fn_decimal_ibra(vr_qt_CarRotO12));

      --Quantidade de meses com meses desde a primeira ocorrencia de saldo devedor total de produtos com
      --caracteristica de rotativo (cheque especial, cartão, conta garantida, adp) nos últimos 12 meses
      if    vr_vl_sld_devedor_CarRot(12) > 0 then vr_qt_CarRotQmp12 := 12;
      elsif vr_vl_sld_devedor_CarRot(11) > 0 then vr_qt_CarRotQmp12 := 11;
      elsif vr_vl_sld_devedor_CarRot(10) > 0 then vr_qt_CarRotQmp12 := 10;
      elsif vr_vl_sld_devedor_CarRot(09) > 0 then vr_qt_CarRotQmp12 := 9;
      elsif vr_vl_sld_devedor_CarRot(08) > 0 then vr_qt_CarRotQmp12 := 8;
      elsif vr_vl_sld_devedor_CarRot(07) > 0 then vr_qt_CarRotQmp12 := 7;
      elsif vr_vl_sld_devedor_CarRot(06) > 0 then vr_qt_CarRotQmp12 := 6;
      elsif vr_vl_sld_devedor_CarRot(05) > 0 then vr_qt_CarRotQmp12 := 5;
      elsif vr_vl_sld_devedor_CarRot(04) > 0 then vr_qt_CarRotQmp12 := 4;
      elsif vr_vl_sld_devedor_CarRot(03) > 0 then vr_qt_CarRotQmp12 := 3;
      elsif vr_vl_sld_devedor_CarRot(02) > 0 then vr_qt_CarRotQmp12 := 2;
      elsif vr_vl_sld_devedor_CarRot(01) > 0 then vr_qt_CarRotQmp12 := 1;
      else  vr_qt_CarRotQmp12 := 0;
      end if;
      vr_obj_generic4.put('vl_sld_devedor_total_CarRotQmp12', este0001.fn_decimal_ibra(vr_qt_CarRotQmp12));

      --Quantidade de meses com meses com ocorrencia de saldo devedor total de rotativo de cartão de
      --credito nos últimos 12 meses
       vr_qt_totalQo12 := 0;
      if vr_vl_sld_devedor_total(01) > 0 then vr_qt_totalQo12 := vr_qt_totalQo12 +1; end if;
      if vr_vl_sld_devedor_total(02) > 0 then vr_qt_totalQo12 := vr_qt_totalQo12 +1; end if;
      if vr_vl_sld_devedor_total(03) > 0 then vr_qt_totalQo12 := vr_qt_totalQo12 +1; end if;
      if vr_vl_sld_devedor_total(04) > 0 then vr_qt_totalQo12 := vr_qt_totalQo12 +1; end if;
      if vr_vl_sld_devedor_total(05) > 0 then vr_qt_totalQo12 := vr_qt_totalQo12 +1; end if;
      if vr_vl_sld_devedor_total(06) > 0 then vr_qt_totalQo12 := vr_qt_totalQo12 +1; end if;
      if vr_vl_sld_devedor_total(07) > 0 then vr_qt_totalQo12 := vr_qt_totalQo12 +1; end if;
      if vr_vl_sld_devedor_total(08) > 0 then vr_qt_totalQo12 := vr_qt_totalQo12 +1; end if;
      if vr_vl_sld_devedor_total(09) > 0 then vr_qt_totalQo12 := vr_qt_totalQo12 +1; end if;
      if vr_vl_sld_devedor_total(10) > 0 then vr_qt_totalQo12 := vr_qt_totalQo12 +1; end if;
      if vr_vl_sld_devedor_total(11) > 0 then vr_qt_totalQo12 := vr_qt_totalQo12 +1; end if;
      if vr_vl_sld_devedor_total(12) > 0 then vr_qt_totalQo12 := vr_qt_totalQo12 +1; end if;

      if vr_qt_totalQo12 = 0 then
        vr_qt_totalQo12 := -100;
      end if;
      vr_obj_generic4.put('vl_sld_devedor_totalQo12', este0001.fn_decimal_ibra(vr_qt_totalQo12));

      --Maximo do valor do limite dos últimos 12 meses
      vr_vl_max_limite := greatest(vr_vl_limite(01),vr_vl_limite(02),vr_vl_limite(03)
                                  ,vr_vl_limite(04),vr_vl_limite(05),vr_vl_limite(06)
                                  ,vr_vl_limite(07),vr_vl_limite(08),vr_vl_limite(09)
                                  ,vr_vl_limite(10),vr_vl_limite(11),vr_vl_limite(12));
      vr_obj_generic4.put('vl_limiteMax12', este0001.fn_decimal_ibra(vr_vl_max_limite));

      --Pc_Utiliz_limiteAvg3
      --Percentual de utilização do limite  - média nos últimos 3 meses
      if greatest(vr_vl_sld_devedor_total(1),vr_vl_sld_devedor_total(2),vr_vl_sld_devedor_total(3))<=0 then
         vr_Pc_Utiliz_limiteAvg3 := -100;
      else
         if greatest(vr_vl_limite(1),vr_vl_limite(2),vr_vl_limite(3)) <= 0 then
            vr_Pc_Utiliz_limiteAvg3 := -101;
         else
            vr_Pc_Utiliz_limiteAvg3 := TRUNC( ( vr_Pc_Utiliz_limite(1)
                                       + vr_Pc_Utiliz_limite(2)
                                              + vr_Pc_Utiliz_limite(3)) /3 ,4);
         end if;
      end if;
      vr_obj_generic4.put('Pc_Utiliz_limiteAvg3', este0001.fn_decimal_ibra(vr_Pc_Utiliz_limiteAvg3));

      IF rw_crapass.inpessoa = 1 THEN --PF

         --Pc_Utiliz_limiteMax12
         --Percentual de utilização do limite  - máximo nos últimos 12 meses
         if vr_qt_totalQo12 <= 0 then
            vr_Pc_Utiliz_limiteMax12 := -100;
         elsif vr_vl_max_limite <= 0 then
            vr_Pc_Utiliz_limiteMax12 := -101;
         else
            vr_Pc_Utiliz_limiteMax12 := greatest(vr_Pc_Utiliz_limite(1),vr_Pc_Utiliz_limite(2),vr_Pc_Utiliz_limite(3)
                                                ,vr_Pc_Utiliz_limite(4),vr_Pc_Utiliz_limite(5),vr_Pc_Utiliz_limite(6)
                                                ,vr_Pc_Utiliz_limite(7),vr_Pc_Utiliz_limite(8),vr_Pc_Utiliz_limite(9)
                                                ,vr_Pc_Utiliz_limite(10),vr_Pc_Utiliz_limite(11),vr_Pc_Utiliz_limite(12));
         end if;
         vr_obj_generic4.put('Pc_Utiliz_limiteMax12', este0001.fn_decimal_ibra(vr_Pc_Utiliz_limiteMax12));

         --Pc_CarRot_LimAvg3
         --Percentual de rotativo cartão pelo limite - média nos últimos 3 meses
         if greatest( vr_vl_sld_devedor_total(1), vr_vl_sld_devedor_total(2), vr_vl_sld_devedor_total(3)) <= 0 then
            vr_Pc_CarRot_LimAvg3 := -100;
         elsif greatest(vr_vl_limite(1),vr_vl_limite(2),vr_vl_limite(3)) <= 0 then
            vr_Pc_CarRot_LimAvg3 := -101;
       --Utilizado regra do DIEGO (Planilha a regra está diferente)
       --elsif greatest(vr_vl_sld_devedor_Rot(1),vr_vl_sld_devedor_Rot(2),vr_vl_sld_devedor_Rot(3)) <= 0 then
       --   vr_Pc_CarRot_LimAvg3 := -99;
         else
            vr_nrdivisor := 0;
           if vr_Pc_Utiliz_limite_CarRot(1) <> 0 then  vr_nrdivisor :=  vr_nrdivisor +1; end if;
           if vr_Pc_Utiliz_limite_CarRot(2) <> 0 then  vr_nrdivisor :=  vr_nrdivisor +1; end if;
           if vr_Pc_Utiliz_limite_CarRot(3) <> 0 then  vr_nrdivisor :=  vr_nrdivisor +1; end if;

           IF vr_nrdivisor = 0 THEN
            vr_Pc_CarRot_LimAvg3 := -99;
           ELSE
              vr_Pc_CarRot_LimAvg3 := round(  (vr_Pc_Utiliz_limite_CarRot(1)
                                             + vr_Pc_Utiliz_limite_CarRot(2)
                                             + vr_Pc_Utiliz_limite_CarRot(3))
                                             /  vr_nrdivisor  ,4) ;
           END IF;
         --
         end if;
         vr_obj_generic4.put('Pc_CarRot_LimAvg3', este0001.fn_decimal_ibra(vr_Pc_CarRot_LimAvg3));

         --Pc_CarRot_LimMax12 -Linha 193
         --Percentual de rotativo cartão pelo limite - máximo nos últimos 12 meses
         if vr_qt_totalQo12 <=0 then
            vr_Pc_CarRot_LimMax12 := -100;
         elsif vr_vl_max_limite <=0 then
            vr_Pc_CarRot_LimMax12 := -101;
         elsif vr_qt_CarRotO12 <= 0 then
            vr_Pc_CarRot_LimMax12 := -99;
         else vr_Pc_CarRot_LimMax12 :=
                             greatest( vr_Pc_Utiliz_limite_CarRot(1) , vr_Pc_Utiliz_limite_CarRot(2) ,
                                       vr_Pc_Utiliz_limite_CarRot(3) , vr_Pc_Utiliz_limite_CarRot(4) ,
                                       vr_Pc_Utiliz_limite_CarRot(5) , vr_Pc_Utiliz_limite_CarRot(6) ,
                                       vr_Pc_Utiliz_limite_CarRot(7) , vr_Pc_Utiliz_limite_CarRot(8) ,
                                       vr_Pc_Utiliz_limite_CarRot(9) , vr_Pc_Utiliz_limite_CarRot(10) ,
                                       vr_Pc_Utiliz_limite_CarRot(11), vr_Pc_Utiliz_limite_CarRot(12));
         end if;
         vr_obj_generic4.put('Pc_CarRot_LimMax12', este0001.fn_decimal_ibra(vr_Pc_CarRot_LimMax12));

         --vl_sld_devedor_totalNd3
         --Saldo devedor total - número de decrescimos nos últimos 3 meses
         vr_vl_sld_devedor_totalNd3 := 0;
         if greatest(vr_vl_sld_devedor_total(1),vr_vl_sld_devedor_total(2),vr_vl_sld_devedor_total(3)) <= 0 then
            vr_vl_sld_devedor_totalNd3 := -100;
         else
            if vr_vl_sld_devedor_total(1) < vr_vl_sld_devedor_total(2) and vr_vl_sld_devedor_total(2) > 0 then
               vr_vl_sld_devedor_totalNd3 := 1;
            end if;
            if vr_vl_sld_devedor_total(2) < vr_vl_sld_devedor_total(3) and vr_vl_sld_devedor_total(3) > 0 then
               vr_vl_sld_devedor_totalNd3 := vr_vl_sld_devedor_totalNd3 + 1;
            end if;
         end if;
         vr_obj_generic4.put('vl_sld_devedor_totalNd3', este0001.fn_decimal_ibra(vr_vl_sld_devedor_totalNd3));

         --vl_sld_devedor_totalNd6
         --Saldo devedor total - número de decrescimos nos últimos 6 meses
         vr_vl_sld_devedor_totalNd6 := 0;
         if greatest(vr_vl_sld_devedor_total(1),vr_vl_sld_devedor_total(2),vr_vl_sld_devedor_total(3)
                    ,vr_vl_sld_devedor_total(4),vr_vl_sld_devedor_total(5),vr_vl_sld_devedor_total(6)) <=0 then
            vr_vl_sld_devedor_totalNd6 := -100;
         else
            if vr_vl_sld_devedor_total(1) < vr_vl_sld_devedor_total(2) and vr_vl_sld_devedor_total(2) > 0 then
               vr_vl_sld_devedor_totalNd6 := vr_vl_sld_devedor_totalNd6 +1;
            end if;
            if vr_vl_sld_devedor_total(2) < vr_vl_sld_devedor_total(3) and vr_vl_sld_devedor_total(3) > 0 then
               vr_vl_sld_devedor_totalNd6 := vr_vl_sld_devedor_totalNd6 +1;
            end if;
            if vr_vl_sld_devedor_total(3) < vr_vl_sld_devedor_total(4) and vr_vl_sld_devedor_total(4) > 0 then
               vr_vl_sld_devedor_totalNd6 := vr_vl_sld_devedor_totalNd6 +1;
            end if;
            if vr_vl_sld_devedor_total(4) < vr_vl_sld_devedor_total(5) and vr_vl_sld_devedor_total(5) > 0 then
               vr_vl_sld_devedor_totalNd6 := vr_vl_sld_devedor_totalNd6 +1;
            end if;
            if vr_vl_sld_devedor_total(5) < vr_vl_sld_devedor_total(6) and vr_vl_sld_devedor_total(6) > 0 then
               vr_vl_sld_devedor_totalNd6 := vr_vl_sld_devedor_totalNd6 +1;
            end if;
         end if;
         vr_obj_generic4.put('vl_sld_devedor_totalNd6', este0001.fn_decimal_ibra(vr_vl_sld_devedor_totalNd6));

         --vl_sld_devedor_totalNd12
         --Saldo devedor total - número de decrescimos nos últimos 12 meses
         vr_vl_sld_devedor_totalNd12 := 0;
         if vr_qt_totalQo12 <=0 then
            vr_vl_sld_devedor_totalNd12 := -100;
         else
            if vr_vl_sld_devedor_total(1) < vr_vl_sld_devedor_total(2) and vr_vl_sld_devedor_total(2) > 0 then
                vr_vl_sld_devedor_totalNd12 := vr_vl_sld_devedor_totalNd12 +1;
            end if;
            if vr_vl_sld_devedor_total(2) < vr_vl_sld_devedor_total(3) and vr_vl_sld_devedor_total(3) > 0 then
                vr_vl_sld_devedor_totalNd12 := vr_vl_sld_devedor_totalNd12 +1;
            end if;
            if vr_vl_sld_devedor_total(3) < vr_vl_sld_devedor_total(4) and vr_vl_sld_devedor_total(4) > 0 then
                vr_vl_sld_devedor_totalNd12 := vr_vl_sld_devedor_totalNd12 +1;
            end if;
            if vr_vl_sld_devedor_total(4) < vr_vl_sld_devedor_total(5) and vr_vl_sld_devedor_total(5) > 0 then
                vr_vl_sld_devedor_totalNd12 := vr_vl_sld_devedor_totalNd12 +1;
            end if;
            if vr_vl_sld_devedor_total(5) < vr_vl_sld_devedor_total(6) and vr_vl_sld_devedor_total(6) > 0 then
                vr_vl_sld_devedor_totalNd12 := vr_vl_sld_devedor_totalNd12 +1;
            end if;
            if vr_vl_sld_devedor_total(6) < vr_vl_sld_devedor_total(7) and vr_vl_sld_devedor_total(7) > 0 then
                vr_vl_sld_devedor_totalNd12 := vr_vl_sld_devedor_totalNd12 +1;
            end if;
            if vr_vl_sld_devedor_total(7) < vr_vl_sld_devedor_total(8) and vr_vl_sld_devedor_total(8) > 0 then
                vr_vl_sld_devedor_totalNd12 := vr_vl_sld_devedor_totalNd12 +1;
            end if;
            if vr_vl_sld_devedor_total(8) < vr_vl_sld_devedor_total(9) and vr_vl_sld_devedor_total(9) > 0 then
                vr_vl_sld_devedor_totalNd12 := vr_vl_sld_devedor_totalNd12 +1;
            end if;
            if vr_vl_sld_devedor_total(9) < vr_vl_sld_devedor_total(10) and vr_vl_sld_devedor_total(10) > 0 then
                vr_vl_sld_devedor_totalNd12 := vr_vl_sld_devedor_totalNd12 +1;
            end if;
            if vr_vl_sld_devedor_total(10) < vr_vl_sld_devedor_total(11) and vr_vl_sld_devedor_total(11) > 0 then
                vr_vl_sld_devedor_totalNd12 := vr_vl_sld_devedor_totalNd12 +1;
            end if;
            if vr_vl_sld_devedor_total(11) < vr_vl_sld_devedor_total(12) and vr_vl_sld_devedor_total(12) > 0 then
                vr_vl_sld_devedor_totalNd12 := vr_vl_sld_devedor_totalNd12 +1;
            end if;
         end if;
         vr_obj_generic4.put('vl_sld_devedor_totalNd12', este0001.fn_decimal_ibra(vr_vl_sld_devedor_totalNd12));

         --qtd_atr_ExtMax6
         --  Quantidade de dias de atraso externo  - máximo nos últimos 6 meses
         if greatest(vr_vl_sld_devedor_total(1),vr_vl_sld_devedor_total(2),vr_vl_sld_devedor_total(3)
                    ,vr_vl_sld_devedor_total(4),vr_vl_sld_devedor_total(5),vr_vl_sld_devedor_total(6)) <= 0
         and greatest(vr_vl_limite(1),vr_vl_limite(2),vr_vl_limite(3)
                     ,vr_vl_limite(4),vr_vl_limite(5),vr_vl_limite(6)) <= 0
         and greatest(vr_qtd_atr_Ext(1),vr_qtd_atr_Ext(2),vr_qtd_atr_Ext(3)
                     ,vr_qtd_atr_Ext(4),vr_qtd_atr_Ext(5),vr_qtd_atr_Ext(6)) <= 0 then
            vr_qtd_atr_ExtMax6 := -102;
         else
            vr_qtd_atr_ExtMax6 := greatest(vr_qtd_atr_Ext(1),vr_qtd_atr_Ext(2),vr_qtd_atr_Ext(3)
                                          ,vr_qtd_atr_Ext(4),vr_qtd_atr_Ext(5),vr_qtd_atr_Ext(6));
         end if;
         vr_obj_generic4.put('qtd_atr_ExtMax6', este0001.fn_decimal_ibra(vr_qtd_atr_ExtMax6));

         --qtd_atr_ExtMax12
         --Quantidade de dias de atraso externo  - máximo nos últimos 12 meses
         if vr_qt_totalQo12 <= 0
         and vr_vl_max_limite <= 0
         and  greatest(vr_qtd_atr_Ext(1),vr_qtd_atr_Ext(2),vr_qtd_atr_Ext(3),vr_qtd_atr_Ext(4)
                      ,vr_qtd_atr_Ext(5),vr_qtd_atr_Ext(6),vr_qtd_atr_Ext(7),vr_qtd_atr_Ext(8)
                      ,vr_qtd_atr_Ext(9),vr_qtd_atr_Ext(10),vr_qtd_atr_Ext(11),vr_qtd_atr_Ext(12)) <= 0 then
            vr_qtd_atr_ExtMax12 := -102;
         else
            vr_qtd_atr_ExtMax12 := greatest(vr_qtd_atr_Ext(1),vr_qtd_atr_Ext(2),vr_qtd_atr_Ext(3),vr_qtd_atr_Ext(4)
                                           ,vr_qtd_atr_Ext(5),vr_qtd_atr_Ext(6),vr_qtd_atr_Ext(7),vr_qtd_atr_Ext(8)
                                           ,vr_qtd_atr_Ext(9),vr_qtd_atr_Ext(10),vr_qtd_atr_Ext(11),vr_qtd_atr_Ext(12));
         end if;
         vr_obj_generic4.put('qtd_atr_ExtMax12', este0001.fn_decimal_ibra(vr_qtd_atr_ExtMax12));

         --qtd_atr_ExtQo12
         --Quantidade de meses com meses com ocorrencia de atraso externo nos últimos 12 meses
         vr_qtd_atr_ExtQo12 := 0;
         if vr_qt_totalQo12 <= 0
         and vr_vl_max_limite <= 0
         and vr_qtd_atr_ExtMax12 <= 0 then
           vr_qtd_atr_ExtQo12 := -102;
         else
            if vr_qtd_atr_Ext(1) > 0 then  vr_qtd_atr_ExtQo12 := vr_qtd_atr_ExtQo12 +1;  end if;
            if vr_qtd_atr_Ext(2) > 0 then  vr_qtd_atr_ExtQo12 := vr_qtd_atr_ExtQo12 +1;  end if;
            if vr_qtd_atr_Ext(3) > 0 then  vr_qtd_atr_ExtQo12 := vr_qtd_atr_ExtQo12 +1;  end if;
            if vr_qtd_atr_Ext(4) > 0 then  vr_qtd_atr_ExtQo12 := vr_qtd_atr_ExtQo12 +1;  end if;
            if vr_qtd_atr_Ext(5) > 0 then  vr_qtd_atr_ExtQo12 := vr_qtd_atr_ExtQo12 +1;  end if;
            if vr_qtd_atr_Ext(6) > 0 then  vr_qtd_atr_ExtQo12 := vr_qtd_atr_ExtQo12 +1;  end if;
            if vr_qtd_atr_Ext(7) > 0 then  vr_qtd_atr_ExtQo12 := vr_qtd_atr_ExtQo12 +1;  end if;
            if vr_qtd_atr_Ext(8) > 0 then  vr_qtd_atr_ExtQo12 := vr_qtd_atr_ExtQo12 +1;  end if;
            if vr_qtd_atr_Ext(9) > 0 then  vr_qtd_atr_ExtQo12 := vr_qtd_atr_ExtQo12 +1;  end if;
            if vr_qtd_atr_Ext(10) > 0 then vr_qtd_atr_ExtQo12 := vr_qtd_atr_ExtQo12 +1;  end if;
            if vr_qtd_atr_Ext(11) > 0 then vr_qtd_atr_ExtQo12 := vr_qtd_atr_ExtQo12 +1;  end if;
            if vr_qtd_atr_Ext(12) > 0 then vr_qtd_atr_ExtQo12 := vr_qtd_atr_ExtQo12 +1;  end if;
         end if;
         vr_obj_generic4.put('qtd_atr_ExtQo12', este0001.fn_decimal_ibra(vr_qtd_atr_ExtQo12));

         --qtatr_udmMax12
         --Quantidade de dias de atraso interno  - máximo nos últimos 12 meses
         vr_qtatr_udmMax12 := greatest(vr_qtatr_udm(1),vr_qtatr_udm(2),vr_qtatr_udm(3),vr_qtatr_udm(4)
                                      ,vr_qtatr_udm(5),vr_qtatr_udm(6),vr_qtatr_udm(7),vr_qtatr_udm(8)
                                      ,vr_qtatr_udm(9),vr_qtatr_udm(10),vr_qtatr_udm(11),vr_qtatr_udm(12));
         vr_obj_generic4.put('qtatr_udmMax12', este0001.fn_decimal_ibra(vr_qtatr_udmMax12));

         --qtatr_udmQo12
         --Quantidade de meses com meses com ocorrencia de atraso interno nos últimos 12 meses
         vr_qtatr_udmQo12 := 0;
         if vr_qtatr_udm(1) > 0 then  vr_qtatr_udmQo12 := vr_qtatr_udmQo12 +1;  end if;
         if vr_qtatr_udm(2) > 0 then  vr_qtatr_udmQo12 := vr_qtatr_udmQo12 +1;  end if;
         if vr_qtatr_udm(3) > 0 then  vr_qtatr_udmQo12 := vr_qtatr_udmQo12 +1;  end if;
         if vr_qtatr_udm(4) > 0 then  vr_qtatr_udmQo12 := vr_qtatr_udmQo12 +1;  end if;
         if vr_qtatr_udm(5) > 0 then  vr_qtatr_udmQo12 := vr_qtatr_udmQo12 +1;  end if;
         if vr_qtatr_udm(6) > 0 then  vr_qtatr_udmQo12 := vr_qtatr_udmQo12 +1;  end if;
         if vr_qtatr_udm(7) > 0 then  vr_qtatr_udmQo12 := vr_qtatr_udmQo12 +1;  end if;
         if vr_qtatr_udm(8) > 0 then  vr_qtatr_udmQo12 := vr_qtatr_udmQo12 +1;  end if;
         if vr_qtatr_udm(9) > 0 then  vr_qtatr_udmQo12 := vr_qtatr_udmQo12 +1;  end if;
         if vr_qtatr_udm(10) > 0 then vr_qtatr_udmQo12 := vr_qtatr_udmQo12 +1;  end if;
         if vr_qtatr_udm(11) > 0 then vr_qtatr_udmQo12 := vr_qtatr_udmQo12 +1;  end if;
         if vr_qtatr_udm(12) > 0 then vr_qtatr_udmQo12 := vr_qtatr_udmQo12 +1;  end if;
         vr_obj_generic4.put('qtatr_udmQo12', este0001.fn_decimal_ibra(vr_qtatr_udmQo12));

         --qtatr_udmAvp12
         --Quantidade de dias de atraso interno ultimo dia do mes  - máximo nos últimos 12 meses
         IF vr_qtatr_udmMax12 > 0 THEN
           vr_qtatr_udmAvp12 := 1;
         ELSE
            IF vr_qtatr_udmMax12 = 0 THEN
              vr_qtatr_udmAvp12 := 0;
            ELSE
              vr_qtatr_udmAvp12 := 0;

              --> Gerar informaçoes do log
              /*GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                                  ,pr_cdoperad => 'AILOS'
                                  ,pr_dscritic => 'Erro ao gerar a VARIAVEL INTERNA: qtatr_udmAvp12. Valor Maior que ZEROS.'
                                  ,pr_dsorigem => 'RATI003'
                                  ,pr_dstransa => 'JSON Rating - variáveis internas'
                                  ,pr_dttransa => TRUNC(SYSDATE)
                                  ,pr_flgtrans => 1 --> FALSE
                                  ,pr_hrtransa => gene0002.fn_busca_time
                                  ,pr_idseqttl => 1
                                  ,pr_nmdatela => 'JOB'
                                  ,pr_nrdconta => pr_nrdconta
                                  ,pr_nrdrowid => 0);*/
            END IF;
         END IF;
         vr_obj_generic4.put('qtatr_udmAvp12', este0001.fn_decimal_ibra(vr_qtatr_udmAvp12));
      ELSE
         --qtd_atr_ExtQo3
         --Quantidade de meses com meses com ocorrencia de atraso nos últimos 3 meses
         vr_qtd_atr_ExtQo3 := 0;
         if  greatest(vr_vl_sld_devedor_total(1), vr_vl_sld_devedor_total(2),vr_vl_sld_devedor_total(3)) <= 0
         and greatest(vr_vl_limite(1), vr_vl_limite(2), vr_vl_limite(3)) <= 0
         and greatest(vr_qtd_atr_Ext(1), vr_qtd_atr_Ext(2), vr_qtd_atr_Ext(3)) <= 0 then
            vr_qtd_atr_ExtQo3 := -102;
         else
            if vr_qtd_atr_Ext(1) > 0 then vr_qtd_atr_ExtQo3 := vr_qtd_atr_ExtQo3 +1; end if;
            if vr_qtd_atr_Ext(2) > 0 then vr_qtd_atr_ExtQo3 := vr_qtd_atr_ExtQo3 +1; end if;
            if vr_qtd_atr_Ext(3) > 0 then vr_qtd_atr_ExtQo3 := vr_qtd_atr_ExtQo3 +1; end if;
         end if;
         vr_obj_generic4.put('qtd_atr_ExtQo3', este0001.fn_decimal_ibra(vr_qtd_atr_ExtQo3));

         --PcQoPriOcCarRot_12
         --Percentual da quantidade de meses com ocorrencias de rotativo cartao desde a primeira ocorrencia
         --de rotativo cartao nos ultimos 12 meses
         vr_PcQoPriOcCarRot_12 := 0;
         if vr_qt_CarRotO12 <= 0 then
            vr_PcQoPriOcCarRot_12 := -99;
         end if;
         if least(vr_Pc_Utiliz_limite_CarRot(1) , vr_Pc_Utiliz_limite_CarRot(2) ,
                  vr_Pc_Utiliz_limite_CarRot(3) , vr_Pc_Utiliz_limite_CarRot(4) ,
                  vr_Pc_Utiliz_limite_CarRot(5) , vr_Pc_Utiliz_limite_CarRot(6) ,
                  vr_Pc_Utiliz_limite_CarRot(7) , vr_Pc_Utiliz_limite_CarRot(8) ,
                  vr_Pc_Utiliz_limite_CarRot(9) , vr_Pc_Utiliz_limite_CarRot(10) ,
                  vr_Pc_Utiliz_limite_CarRot(11), vr_Pc_Utiliz_limite_CarRot(12)) <= 0 then
            vr_PcQoPriOcCarRot_12 := -100;
         end if;
         if vr_qt_totalQo12 <= 0 then
            vr_PcQoPriOcCarRot_12 := -100;
         else
            if vr_vl_max_limite <= 0 then
               vr_PcQoPriOcCarRot_12 := -101;
            else
               if vr_qt_CarRotQmp12 <> 0 and vr_qt_CarRotO12 <> 0 then
                  vr_PcQoPriOcCarRot_12 := trunc(100 * vr_qt_CarRotO12 / vr_qt_CarRotQmp12, 4);
               end if;
            end if;
         end if;
         vr_obj_generic4.put('PcQoPriOcCarRot_12', este0001.fn_decimal_ibra(vr_PcQoPriOcCarRot_12));

         --Pc_CarRot_LimQo12
         --Percentual da quantidade de meses com ocorrencias de rotativo cartao desde a primeira ocorrencia
         --de rotativo cartao nos ultimos 12 meses
         if  vr_qt_totalQo12 <= 0 then
            vr_Pc_CarRot_LimQo12 := -100;
         else
            if vr_vl_max_limite <= 0 then
               vr_Pc_CarRot_LimQo12 := -101;
            else
               vr_Pc_CarRot_LimQo12 := 0;
            end if;
         end if;
         vr_obj_generic4.put('Pc_CarRot_LimQo12', este0001.fn_decimal_ibra(vr_Pc_CarRot_LimQo12));
      end if;

      -- flag_manutencao e flag_originação
      -- EMPRESTIMO
      OPEN cr_flag_manut_orig(pr_cdcooper
                             ,pr_nrdconta
                             ,pr_nrctremp);
      FETCH cr_flag_manut_orig
       INTO rw_flag_manut_orig;
      CLOSE cr_flag_manut_orig;
      IF NVL(rw_flag_manut_orig.qtdiasflag,0) <> 0 then
         if NVL(rw_flag_manut_orig.qtdiasflag,0) > 90 then
            vr_obj_generic4.put('flag_manutencao',1);
            vr_obj_generic4.put('flag_originacao',0);
         else
            vr_obj_generic4.put('flag_manutencao',0);
            vr_obj_generic4.put('flag_originacao',1);
         end if;
      else
         -- flag_manutencao e flag_originação
         -- DESCONTO DE TITULO
         OPEN cr_flag_manut_orig_t(pr_cdcooper
                                  ,pr_nrdconta
                                  ,pr_nrctremp);
         FETCH cr_flag_manut_orig_t
          INTO rw_flag_manut_orig_t;
         CLOSE cr_flag_manut_orig_t;
         if NVL(rw_flag_manut_orig_t.qtdiasflag,0) > 90 then
            vr_obj_generic4.put('flag_manutencao',1);
            vr_obj_generic4.put('flag_originacao',0);
         else
            vr_obj_generic4.put('flag_manutencao',0);
            vr_obj_generic4.put('flag_originacao',1);
         end if;
      end if;

      vr_obj_generic4.put('dt_op_sol_manutencao'
                           ,ESTE0002.fn_Data_ibra_motor(rw_crapdat.dtmvtolt));

      -- Ao final copiamos o json montado ao retornado
      pr_dsjsonvar := vr_obj_generic4;

    EXCEPTION
      WHEN vr_exc_saida THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritaux||' - '||vr_dscritic;

      WHEN OTHERS THEN
        IF SQLCODE < 0 THEN
          -- Caso ocorra exception gerar o código do erro com a linha do erro
          vr_dscritic:= vr_dscritaux||' - '||vr_dscritic ||
                        dbms_utility.format_error_backtrace;

        END IF;

        -- Montar a mensagem final do erro
        vr_dscritic:= vr_dscritaux||' - '||
                     'Erro na montagem dos dados para análise automática da proposta (2.): ' ||
                       vr_dscritic || ' -- SQLERRM: ' || SQLERRM;

        -- Remover as ASPAS que quebram o texto
        vr_dscritic:= replace(vr_dscritic,'"', '');
        vr_dscritic:= replace(vr_dscritic,'''','');
        -- Remover as quebras de linha
        vr_dscritic:= replace(vr_dscritic,chr(10),'');
        vr_dscritic:= replace(vr_dscritic,chr(13),'');

        pr_cdcritic := 0;
        pr_dscritic := vr_dscritic;
    END;
  END pc_json_variaveis_rating;

END RATI0003;
/
