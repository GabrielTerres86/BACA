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
