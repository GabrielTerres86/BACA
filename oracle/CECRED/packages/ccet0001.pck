CREATE OR REPLACE PACKAGE CECRED.CCET0001 IS

-- contaMeses
FUNCTION fn_qtd_meses(pr_data_1 IN DATE
                     ,pr_data_2 IN DATE)
                      RETURN NUMBER;

-- getAniversarioContrato
FUNCTION fn_aniversario_contrato(pr_data_contrato    IN DATE
                                ,pr_primeira_parcela IN DATE)
                                RETURN DATE;

-- getUltimoDiaAno
FUNCTION fn_ultimo_dia_ano(pr_data IN DATE)
                           RETURN DATE;

-- calculaDiferencaEntreDatas
FUNCTION fn_diff_datas(pr_data_i IN DATE
                      ,pr_data_f IN DATE )
                       RETURN NUMBER;

-- verProximaData
FUNCTION fn_proximo_vcto(pr_data_vnto IN DATE)
                         RETURN DATE;

-- calculaJurosCET
FUNCTION fn_calcula_juros_cet(pr_nro_parcelas   IN NUMBER   -- Numero de Parcelas
                              ,pr_juros_ano      IN NUMBER
                              ,pr_juros_mes      IN NUMBER
                              ,pr_primeiro_vcto  IN DATE    -- Vencimento Primeira vr_vcto_parcela
                              ,pr_data_contrato  IN DATE    -- Data do Contrato
                              ,pr_vlr_financiado IN NUMBER  -- Valor Financiado
                              ,pr_vlr_prestacao  IN NUMBER)
                              RETURN NUMBER; -- Valor da Prestação

PROCEDURE pc_juros_cet(pr_nro_parcelas   IN NUMBER
                      ,pr_vlr_prestacao  IN DECIMAL
                      ,pr_vlr_financiado IN DECIMAL
                      ,pr_data_contrato  IN DATE
                      ,pr_primeiro_vcto  IN DATE
                      ,pr_valorcet      OUT NUMBER
                      ,pr_tx_cet_ano    OUT NUMBER
                      ,pr_tx_cet_mes    OUT NUMBER
                      ,pr_cdcritic      OUT INTEGER
                      ,pr_dscritic      OUT VARCHAR2);

  -- Calcular IOF
  PROCEDURE pc_calcula_iof(pr_cdcooper  IN crapcop.cdcooper%TYPE -- Cooperativa
                          ,pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE -- Data Movimento
                          ,pr_vlemprst  IN crapepr.vlemprst%TYPE -- Valor emprestado
                          ,pr_cdprogra  IN VARCHAR2              -- Programa chamador
                          ,pr_cdlcremp  IN craplim.cddlinha%TYPE -- Linha de credio
                          ,pr_inpessoa  IN crapass.inpessoa%TYPE
                          ,pr_dtinivig  IN craplim.dtinivig%TYPE
                          ,pr_qtdiavig  IN NUMBER
                          ,pr_vllanmto OUT craplcm.vllanmto%TYPE -- Valor calculado com o iof
                          ,pr_txccdiof OUT NUMBER -- Taxa do IOF
                          ,pr_cdcritic OUT INTEGER
                          ,pr_dscritic OUT VARCHAR2);

   PROCEDURE pc_calcula_tarifa_cadastro(pr_cdcooper  IN crapcop.cdcooper%TYPE -- Cooperativa
                                      ,pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE -- Data Movimento
                                      ,pr_vlemprst  IN crapepr.vlemprst%TYPE -- Valor emprestado
                                      ,pr_cdbattar  IN VARCHAR2              -- Codigo Tarifa
                                      ,pr_cdprogra  IN VARCHAR2              -- Codigo Programa
                                      ,pr_cdusolcr  IN craplcr.cdusolcr%TYPE -- Codigo uso Linha Credito
                                      ,pr_inpessoa  IN INTEGER               -- Tipo de pessoa
                                      ,pr_cdlcremp  IN INTEGER               -- Codigo linha credio
                                      ,pr_tpctrato  IN craplcr.tpctrato%TYPE -- Tipo do contrato
                                      ,pr_nrdconta  IN crapass.nrdconta%type -- Numero da conta
                                      ,pr_nrctremp  IN NUMBER                -- Numero do Emprestimo
                                      ,pr_vltottar OUT NUMBER                -- Valor Tarifa
                                      ,pr_cdcritic OUT INTEGER
                                      ,pr_dscritic OUT VARCHAR2);


 PROCEDURE pc_calc_taxa_juros(pr_cdcooper  IN crapcop.cdcooper%TYPE -- Cooperativa
                             ,pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE -- Data Movimento
                             ,pr_tpdjuros  IN INTEGER               -- Tipo do juros
                             ,pr_vllanmto  IN NUMBER                -- Valor a calcular
                             ,pr_txmensal  IN NUMBER                -- Taxa Juros
                             ,pr_cddlinha  IN craplim.cddlinha%TYPE -- Codigo Linha credito
                             ,pr_tpctrlim  IN craplim.tpctrlim%TYPE -- Tipo de Limite
                             ,pr_vlrjuros OUT NUMBER                -- Valor Juros
                             ,pr_cdcritic OUT INTEGER
                             ,pr_dscritic OUT VARCHAR2);

  PROCEDURE pc_imprime_limites_cet(pr_cdcooper  IN crapcop.cdcooper%TYPE -- Cooperativa
                                  ,pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE -- Data Movimento
                                  ,pr_cdprogra  IN VARCHAR2              -- Programa chamador
                                  ,pr_nrdconta  IN craplim.nrdconta%TYPE -- Conta/dv
                                  ,pr_inpessoa  IN crapass.inpessoa%TYPE -- Indicativo de pessoa
                                  ,pr_cdusolcr  IN craplcr.cdusolcr%TYPE -- Codigo de uso da linha de credito
                                  ,pr_cdlcremp  IN craplim.cddlinha%TYPE -- Linha de credio
                                  ,pr_tpctrlim  IN craplim.tpctrlim%TYPE -- Tipo da operacao
                                  ,pr_nrctrlim  IN craplim.nrctrlim%TYPE -- Contrato
                                  ,pr_dtinivig  IN craplim.dtinivig%TYPE -- Data liberacao
                                  ,pr_qtdiavig  IN craplrt.qtdiavig%TYPE -- Dias de vigencia
                                  ,pr_vlemprst  IN crapepr.vlemprst%TYPE -- Valor emprestado
                                  ,pr_txmensal  IN craplrt.txmensal%TYPE -- Taxa mensal
                                  ,pr_flretxml  IN INTEGER DEFAULT 0     -- Indicador se deve apenas retornar o XML da impressao
                                  ,pr_des_xml  OUT CLOB                  -- XML
                                  ,pr_nmarqimp OUT VARCHAR2              -- Nome do arquivo
                                  ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                  ,pr_dscritic OUT VARCHAR2);            --> Descrição da crítica

  -- Imprimir contrato de emprestimos do CET
  PROCEDURE pc_imprime_emprestimos_cet(pr_cdcooper  IN crapcop.cdcooper%TYPE -- Cooperativa
                                      ,pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE -- Data Movimento
                                      ,pr_cdprogra  IN VARCHAR2              -- Programa chamador
                                      ,pr_nrdconta  IN crapass.nrdconta%TYPE -- Conta/dv
                                      ,pr_inpessoa  IN crapass.inpessoa%TYPE -- Indicativo de pessoa
                                      ,pr_cdusolcr  IN craplcr.cdusolcr%TYPE -- Codigo de uso da linha de credito
                                      ,pr_cdlcremp  IN craplcr.cdlcremp%TYPE -- Linha de credio
                                      ,pr_tpemprst  IN crapepr.tpemprst%TYPE -- Tipo da operacao
                                      ,pr_nrctremp  IN crapepr.nrctremp%TYPE -- Contrato
                                      ,pr_dtlibera  IN crawepr.dtlibera%TYPE -- Data liberacao
                                      ,pr_dtultpag  IN crapepr.dtultpag%TYPE -- Data ultimo pagamento
                                      ,pr_vlemprst  IN crapepr.vlemprst%TYPE -- Valor emprestado
                                      ,pr_txmensal  IN crapepr.txmensal%TYPE -- Taxa mensal
                                      ,pr_vlpreemp  IN crapepr.vlpreemp%TYPE -- Valor Parcela
                                      ,pr_qtpreemp  IN crapepr.qtpreemp%TYPE -- Parcelas
                                      ,pr_dtdpagto  IN crapepr.dtdpagto%TYPE -- Data Pagamento
                                      ,pr_nmarqimp OUT VARCHAR2              -- Nome do arquivo
                                      ,pr_des_xml  OUT CLOB                  -- XML
                                      ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                      ,pr_dscritic OUT VARCHAR2);            --> Descrição da crítica

  -- Retornar calculo do cet dos limites
  PROCEDURE pc_calculo_cet_limites(pr_cdcooper  IN crapcop.cdcooper%TYPE -- Cooperativa
                                  ,pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE -- Data Movimento
                                  ,pr_cdprogra  IN VARCHAR2              -- Programa chamador
                                  ,pr_nrdconta  IN craplim.nrdconta%TYPE -- Conta/dv
                                  ,pr_inpessoa  IN crapass.inpessoa%TYPE -- Indicativo de pessoa
                                  ,pr_cdusolcr  IN craplcr.cdusolcr%TYPE -- Codigo de uso da linha de credito
                                  ,pr_cdlcremp  IN craplim.cddlinha%TYPE -- Linha de credio
                                  ,pr_tpctrlim  IN craplim.tpctrlim%TYPE -- Tipo da operacao
                                  ,pr_nrctrlim  IN craplim.nrctrlim%TYPE -- Contrato
                                  ,pr_dtinivig  IN craplim.dtinivig%TYPE -- Data liberacao
                                  ,pr_qtdiavig  IN craplrt.qtdiavig%TYPE -- Dias de vigencia                                      
                                  ,pr_vlemprst  IN crapepr.vlemprst%TYPE -- Valor emprestado
                                  ,pr_txmensal  IN craplrt.txmensal%TYPE -- Taxa mensal                                                               
                                  ,pr_txcetano OUT NUMBER                -- Taxa cet ano
                                  ,pr_txcetmes OUT NUMBER                -- Taxa cet mes 
                                  ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                  ,pr_dscritic OUT VARCHAR2);                                      

  PROCEDURE pc_calculo_cet_emprestimos(pr_cdcooper  IN crapcop.cdcooper%TYPE -- Cooperativa
                                      ,pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE -- Data Movimento
                                      ,pr_nrdconta  IN crapass.nrdconta%TYPE -- Conta/dv
                                      ,pr_cdprogra  IN VARCHAR2              -- Programa chamador
                                      ,pr_inpessoa  IN crapass.inpessoa%TYPE -- Indicativo de pessoa
                                      ,pr_cdusolcr  IN craplcr.cdusolcr%TYPE -- Codigo de uso da linha de credito
                                      ,pr_cdlcremp  IN craplcr.cdlcremp%TYPE -- Linha de credio
                                      ,pr_tpemprst  IN crapepr.tpemprst%TYPE -- Tipo da operacao
                                      ,pr_nrctremp  IN crapepr.nrctremp%TYPE -- Contrato
                                      ,pr_dtlibera  IN crawepr.dtlibera%TYPE -- Data liberacao
                                      ,pr_vlemprst  IN crapepr.vlemprst%TYPE -- Valor emprestado
                                      ,pr_txmensal  IN crapepr.txmensal%TYPE -- Taxa mensal 
                                      ,pr_vlpreemp  IN crapepr.vlpreemp%TYPE -- Valor Parcela
                                      ,pr_qtpreemp  IN crapepr.qtpreemp%TYPE -- Parcelas
                                      ,pr_dtdpagto  IN crapepr.dtdpagto%TYPE -- Data Pagamento
                                      ,pr_cdfinemp  IN crapepr.cdfinemp%TYPE -- Finalidade de Emprestimo
                                      ,pr_txcetano OUT NUMBER                -- Taxa cet ano
                                      ,pr_txcetmes OUT NUMBER                -- Taxa cet mes 
                                      ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                      ,pr_dscritic OUT VARCHAR2);            --> Descrição da crítica
                                      
END CCET0001;
/
create or replace package body cecred.CCET0001 is

  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : CCET0001
  --  Sistema  : Rotinas referentes ao calculo do CET (Custo Efetivo Total)
  --  Sigla    : CCET
  --  Autor    : Lucas Ranghetti
  --  Data     : Julho/2014.                   Ultima atualizacao: 23/12/2016
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Agrupar Relacionadas ao Custo Efetivo Total (CET)

  -- Alteracoes: 29/11/2014 - Incluido tratamento para o programa nao ficar em loop (Andrino-RKAM)
  
  --             21/01/2015 - Alterado o formato do campo nrctremp para 8 
  --                          caracters (Kelvin - 233714)
  
  --              05/05/2015 - Alterado o campo flg_impri da procedure pc_solicita_relato de 'S' para 'N'
  --                           para não gerar o arquivo pdf no diretório audit_pdf (Lucas Ranghetti #281494)
  --
  --              12/11/2015 - Criada validacao do tipo de contrato de emprestimo para Portabilidade, neste caso
  --                           nao calculando taxa de IOF (Carlos Rafael Tanholi - Projeto Portabilidade).             
  --
  --              17/11/2015 - Criacao do parametro cdfinemp na pc_calcula_cet_emprestimos, para tratamento
  --                           do IOF sobre emprestimos de Portabilidade.(Carlos Rafael Tanholi - Projeto Portabilidade).
  --
  --              23/12/2016 - Ajuste para aumentar o tamanho do campo que recebe o nome da cooperativa
  --                           pois estava estourando o format
  --                          (Adriano - SD 582204).
  --
  --              05/10/2017 - Correcao no calculo realizado para o valor da tarifa do CET, quando a proposta ainda nao esta
  --                           efetivada. Heitor (Mouts) - Chamado 746478.
  ---------------------------------------------------------------------------------------------------------------

  pr_cdcritic NUMBER;
  pr_dscritic VARCHAR2(4000); 

  -- Contar os meses
  FUNCTION fn_qtd_meses(pr_data_1 IN DATE
                       ,pr_data_2 IN DATE)
                        RETURN NUMBER IS
  /* .............................................................................

    Programa: fn_qtd_meses                 
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Daniel Zimermann
    Data    : Julho/2014                        Ultima atualizacao: 00/00/0000

    Dados referentes ao programa:

    Frequencia: Diaria - Sempre que for chamada
    Objetivo  : Rotina para contar os meses de acordo com o parametro informado

    Alteracoes:                  
  ............................................................................. */

    vr_qtd_meses NUMBER := 0;
    
    vr_mes_1 NUMBER;
    vr_mes_2 NUMBER;

  BEGIN

    vr_mes_1 := to_number(to_char(pr_data_1,'MM'));
    vr_mes_2 := to_number(to_char(pr_data_2,'MM'));
    
    IF vr_mes_1 > vr_mes_2 THEN
      vr_mes_1 := vr_mes_1 -12;
    END IF;
    
    vr_qtd_meses := vr_mes_2 - vr_mes_1;

    -- Quantidade de Meses
    RETURN vr_qtd_meses;

  EXCEPTION
    WHEN OTHERS THEN
      pr_dscritic := 'Erro fn_qtd_meses : ' || SQLERRM;

  END fn_qtd_meses;

  -- Retornar o aniversario do contrato
  FUNCTION fn_aniversario_contrato(pr_data_contrato    IN DATE
                                  ,pr_primeira_parcela IN DATE)
                                  RETURN DATE IS
  /* .............................................................................

    Programa: fn_aniversario_contrato                 
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Daniel Zimermann
    Data    : Julho/2014                        Ultima atualizacao: 00/00/0000

    Dados referentes ao programa:

    Frequencia: Diaria - Sempre que for chamada
    Objetivo  : Rotina para retornar o aniversario do contrato

    Alteracoes:                  
  ............................................................................. */  

    vr_dia_contrato VARCHAR2(2);
    vr_dia_parcela  VARCHAR2(2);
    vr_mes_contrato VARCHAR2(2);
    vr_ano_contrato VARCHAR2(4);

    vr_mes_aniversario  NUMBER;
    vr_data_aniversario DATE;

    aux_data VARCHAR2(10);

  BEGIN

    vr_dia_parcela  := to_char(pr_primeira_parcela,'DD');

    vr_dia_contrato := to_char(pr_data_contrato,'DD');
    vr_mes_contrato := to_char(pr_data_contrato,'MM');
    vr_ano_contrato := to_char(pr_data_contrato,'YYYY'); 
   

    -- Mes do Aniversario do Contrato
    vr_mes_aniversario  := TO_NUMBER(vr_mes_contrato);

    IF (TO_NUMBER(vr_dia_contrato) > TO_NUMBER(vr_dia_parcela)) THEN
        vr_mes_aniversario := vr_mes_aniversario + 1;
    END IF;

    IF (TO_NUMBER(vr_mes_aniversario) > 12) THEN
      vr_ano_contrato    := TO_NUMBER(vr_ano_contrato) + 1;
      vr_mes_aniversario := TO_NUMBER(vr_mes_aniversario) - 12;
    END IF;

    -- Monta data do ANiversario Contrato
    aux_data := vr_dia_parcela || '/' || to_char(vr_mes_aniversario) || '/' || vr_ano_contrato;

    vr_data_aniversario :=  TO_DATE(aux_data,'DD/MM/RRRR');
       
    RETURN vr_data_aniversario;

  EXCEPTION
    WHEN OTHERS THEN
      pr_dscritic := 'Erro fn_aniversario_contrato : ' || SQLERRM;

  END fn_aniversario_contrato;

  -- Retorna ultimo dia do ano
  FUNCTION fn_ultimo_dia_ano(pr_data IN DATE)
     RETURN DATE IS
  /* .............................................................................

    Programa: fn_ultimo_dia_ano                 
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Daniel Zimermann
    Data    : Julho/2014                        Ultima atualizacao: 00/00/0000

    Dados referentes ao programa:

    Frequencia: Diaria - Sempre que for chamada
    Objetivo  : Rotina para retornar o ultimo dia do ano

    Alteracoes:                  
  ............................................................................. */
    vr_data DATE;

    BEGIN

      vr_data := LAST_DAY( ADD_MONTHS(pr_data,12));

      RETURN vr_data;

    EXCEPTION
      WHEN OTHERS THEN
        pr_dscritic := 'Erro fn_ultimo_dia_ano : ' || SQLERRM;

  END fn_ultimo_dia_ano;

  -- Calcula Diferenca Entre Datas
  FUNCTION fn_diff_datas(pr_data_i IN DATE
                        ,pr_data_f IN DATE ) RETURN NUMBER IS
  /* .............................................................................

    Programa: fn_diff_datas                 
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Daniel Zimermann
    Data    : Julho/2014                        Ultima atualizacao: 00/00/0000

    Dados referentes ao programa:

    Frequencia: Diaria - Sempre que for chamada
    Objetivo  : Rotina para calcular a diferenca entre datas

    Alteracoes:                  
  ............................................................................. */

    vr_diferenca NUMBER := 0;

    BEGIN

      vr_diferenca := pr_data_f - pr_data_i;

      RETURN vr_diferenca;

    EXCEPTION
      WHEN OTHERS THEN
        pr_dscritic := 'Erro fn_diff_datas : ' || SQLERRM;

  END fn_diff_datas;

  -- Ver Proxima Data vencimento
  FUNCTION fn_proximo_vcto(pr_data_vnto IN DATE)
     RETURN DATE IS
  /* .............................................................................

    Programa: fn_proximo_vcto                 
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Daniel Zimermann
    Data    : Julho/2014                        Ultima atualizacao: 00/00/0000

    Dados referentes ao programa:

    Frequencia: Diaria - Sempre que for chamada
    Objetivo  : Rotina para calcular o proximo vencimento

    Alteracoes:                  
  ............................................................................. */

    vr_data DATE;

    BEGIN

      vr_data := ADD_MONTHS(pr_data_vnto,1);

      RETURN vr_data;

    EXCEPTION
      WHEN OTHERS THEN
        pr_dscritic := 'Erro fn_proximo_vencimento : ' || SQLERRM;

  END fn_proximo_vcto;

  -- Calcular Juros do CET
  FUNCTION fn_calcula_juros_cet(pr_nro_parcelas   IN NUMBER  -- Numero de Parcelas
                               ,pr_juros_ano      IN NUMBER
                               ,pr_juros_mes      IN NUMBER
                               ,pr_primeiro_vcto  IN DATE    -- Vencimento Primeira vr_vcto_parcela
                               ,pr_data_contrato  IN DATE    -- Data do Contrato
                               ,pr_vlr_financiado IN NUMBER  -- Valor Financiado
                               ,pr_vlr_prestacao  IN NUMBER) -- Valor da Prestação
                               RETURN NUMBER IS
  /* .............................................................................

    Programa: fn_calcula_juros_cet                 
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Daniel Zimermann
    Data    : Julho/2014                        Ultima atualizacao: 00/00/0000

    Dados referentes ao programa:

    Frequencia: Diaria - Sempre que for chamada
    Objetivo  : Rotina para calcular o juros do CET

    Alteracoes:                  
  ............................................................................. */
  
    -- VARIAVEIS
    pr_vjur_fin         NUMBER :=0;
    vr_proximo_vcto     DATE;
    vr_primeira_parcela DATE;
    vr_dt_niver_cntr    DATE;
    vr_vcto_parcela     DATE;

    vr_vlr_total_old NUMBER := 0;
    vr_aux_b         NUMBER := 0;
    vr_juros_fin     NUMBER := 0;
    vr_juros_fin_1   NUMBER := 1;
    vr_juros_fin_2   NUMBER := 0;
    vr_aux_igual     NUMBER := 0;
    vr_aux_repete    NUMBER := 0;
    vr_juros_fin_old NUMBER := 0;
    vr_juros_dia     NUMBER := 0;
    vr_vlr_fin_old   NUMBER := 0;
    vr_vlr_total     NUMBER := 0;

    vr_mes_contrato  VARCHAR2(2);
    vr_ano_contrato  VARCHAR2(4);

    vr_diff_data   NUMBER;
    vvlr_novo      NUMBER := 0;
    vr_contador    NUMBER;
    vr_vlr_desc    NUMBER;
    vr_valor_aux_1 NUMBER;
    vr_valor_aux_2 NUMBER;
    vr_vlr_desc_1  NUMBER;
    vr_dias_padrao NUMBER;
    vr_diff_data_1 NUMBER := 0;

    vr_aux_idx        NUMBER;
    vr_qtd_diff_meses NUMBER;
    vr_diff_dt_cntr   NUMBER := 0;

    vr_adiff_dc   NUMBER;
    vr_adif_dc_2  NUMBER;
    vr_adif_dc    NUMBER := 0;
    vr_adif_dc_1  NUMBER := 0;

    BEGIN

      vr_vcto_parcela     := pr_primeiro_vcto;
      vr_juros_fin         := pr_juros_ano;
      vr_primeira_parcela := vr_vcto_parcela;

      vr_juros_dia   := (((POWER(1 + (pr_juros_mes),(1/30)))- 1)/100) * 100;
      vr_vlr_fin_old := pr_vlr_financiado;
      
      WHILE (ABS(pr_vlr_financiado - vr_aux_b) > 0.00001) LOOP
             
        vr_vlr_total      := 0;
        vr_vcto_parcela   := vr_primeira_parcela;
        vr_dt_niver_cntr := fn_aniversario_contrato(pr_data_contrato,vr_primeira_parcela);
        vr_diff_dt_cntr  := fn_diff_datas(pr_data_contrato,vr_primeira_parcela);

        vr_mes_contrato  := to_char(pr_data_contrato,'MM');
        vr_ano_contrato  := to_char(pr_data_contrato,'YYYY');

        vr_adiff_dc   := 0;
        vr_diff_data  := 0;
        vvlr_novo     := 0;
        
        vr_dias_padrao := to_char(last_day(pr_data_contrato),'DD');
        

        IF (vr_diff_dt_cntr > vr_dias_padrao) THEN -- Mais de 31 dias

          vr_adif_dc_1      := fn_diff_datas(pr_data_contrato,vr_dt_niver_cntr);
          vr_adif_dc_2      := fn_diff_datas(pr_data_contrato,vr_primeira_parcela);
          vr_qtd_diff_meses := fn_qtd_meses(vr_dt_niver_cntr,vr_primeira_parcela) - 1;
          vr_adif_dc        := vr_qtd_diff_meses + (vr_adif_dc_1 / vr_dias_padrao);
          vr_aux_idx        := 0;
 
          IF (pr_vlr_financiado = vr_vlr_fin_old) THEN
            vr_adiff_dc    := vr_adif_dc;
            vr_valor_aux_1 := (1 + vr_juros_dia);
            vr_valor_aux_2 := ABS(vr_adif_dc_1);
            vr_vlr_desc_1  := POWER(vr_valor_aux_1,vr_valor_aux_2);
            vr_vlr_desc    := ROUND((pr_vlr_financiado * (vr_vlr_desc_1)),2);
            vvlr_novo      := vr_vlr_desc;
            vr_aux_idx     := vr_aux_idx + 1;
          END IF;

          vr_vlr_total_old := vr_vlr_total;
        END IF;

        vr_contador := 0;

        WHILE vr_contador < (pr_nro_parcelas) LOOP

          IF ( vr_contador <> 0) THEN
            vr_proximo_vcto := fn_proximo_vcto(vr_proximo_vcto);
            vr_diff_data_1  := fn_diff_datas(vr_vcto_parcela,vr_proximo_vcto);
          ELSE
            vr_proximo_vcto := vr_vcto_parcela;
            vr_diff_data_1  := vr_diff_dt_cntr;
          END IF;

          IF ((vr_vlr_total <> 0) AND (vr_contador = 0) ) THEN
            vr_vlr_desc     := ROUND(vr_vlr_total,2);
            vr_vcto_parcela := vr_proximo_vcto;
            vr_diff_data    := vr_diff_data_1;
          ELSE
            vr_diff_data    := vr_diff_data + vr_diff_data_1;
            vr_valor_aux_1  := (1+vr_juros_fin/100);
            vr_valor_aux_2  := ABS(vr_diff_data)/(365);
            vr_vlr_desc_1   := POWER(vr_valor_aux_1,vr_valor_aux_2);
            vr_vlr_desc     := ROUND((pr_vlr_prestacao / vr_vlr_desc_1),2);
            vr_vlr_total    := vr_vlr_total + vr_vlr_desc;
            vr_vcto_parcela := vr_proximo_vcto;
          END IF;

          vr_contador :=  vr_contador + 1;
        END LOOP;

        vr_aux_b := vr_vlr_total;

        IF (vr_aux_b < pr_vlr_financiado) THEN
          vr_juros_fin_1 := vr_juros_fin;
        ELSE
          vr_juros_fin_2 := vr_juros_fin;
        END IF;

        vr_juros_fin := ( vr_juros_fin_1 + vr_juros_fin_2)/2;

        IF (vr_juros_fin_old = vr_juros_fin) THEN
          vr_aux_igual := vr_aux_igual + 1;
        ELSE
          vr_aux_igual := 0;
        END IF;

        vr_juros_fin_old := vr_juros_fin;

        IF (vr_aux_igual = 10) THEN

          IF (vr_aux_repete = 0) THEN
            vr_juros_fin_1 := pr_juros_ano * 2;
            vr_aux_repete  := 1;
            vr_aux_igual   := 0;
          ELSE
            EXIT;

          END IF;
        END IF;

      END LOOP;
      
      pr_vjur_fin     := ROUND(vr_juros_fin,5);

      RETURN pr_vjur_fin;

    EXCEPTION
    WHEN OTHERS THEN
     pr_dscritic := 'Erro pc_calcula_juros_cet : ' || SQLERRM;

  END fn_calcula_juros_cet;

  -- Mostra juros
  PROCEDURE pc_juros_cet(pr_nro_parcelas   IN NUMBER               --> Numero de Parcelas
                        ,pr_vlr_prestacao  IN DECIMAL              --> Valor da Parcela
                        ,pr_vlr_financiado IN DECIMAL              --> Valor Emprestado
                        ,pr_data_contrato  IN DATE                 --> Data do contrato
                        ,pr_primeiro_vcto  IN DATE                 --> Primeiro vencimento
                        ,pr_valorcet      OUT NUMBER               --> Valor calculado do CET
                        ,pr_tx_cet_ano    OUT NUMBER               --> Taxa do cet Anual
                        ,pr_tx_cet_mes    OUT NUMBER               --> Taxa cet Mensal
                        ,pr_cdcritic      OUT INTEGER              --> Codigo da critica
                        ,pr_dscritic      OUT VARCHAR2) IS
  /* .............................................................................

    Programa: pc_juros_cet                 
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Daniel Zimermann
    Data    : Julho/2014                        Ultima atualizacao: 00/00/0000

    Dados referentes ao programa:

    Frequencia: Diaria - Sempre que for chamada
    Objetivo  : Rotina para retornar o juros calculado do CET

    Alteracoes:                  
  ............................................................................. */
    BEGIN

      DECLARE

        vr_cdcritic  NUMBER         := 0;
        vr_dscritic  VARCHAR2(4000) := ' ';
        vr_exc_saida EXCEPTION;

        vr_aux_v2 NUMBER;
        vr_aux_a  NUMBER := 0;
        vr_aux_b  NUMBER := 0;
        vr_aux_p  NUMBER := 0;

        vr_vlr_total   NUMBER := 0;
        vr_aux_n       NUMBER := 0;
        vr_vjur1       NUMBER;
        vr_vjur2       NUMBER;
        vjur_fin1      NUMBER;
        vjur_fin2      NUMBER;
        vr_juros       NUMBER;
        vr_juros_fin   NUMBER;
        vjuranox_fin   NUMBER;
        vr_adiff_dc    NUMBER;
        vr_diff_data   NUMBER;
        vr_i_acerto    NUMBER;
        vr_contador    NUMBER;
        vr_prox_data   DATE;
        vr_vlr_desc    NUMBER;
        vr_vlr_desc1   NUMBER;
        vr_juros_cet   NUMBER;
        vr_aux_v1      NUMBER;
        vr_dif_dc      NUMBER;
        vr_aux_idx     NUMBER;
        vr_aux_i       NUMBER;
        vr_parcela     DATE ;

        vr_primera_parcela DATE;
        vr_ultimo_dia_ano  DATE;
        vr_vlr_prestacao   NUMBER ;
        vr_vlr_financiado  NUMBER;

        TYPE tt_adif_dc IS RECORD(valor NUMBER);
        TYPE adif_dc_lista IS TABLE of tt_adif_dc INDEX BY BINARY_INTEGER;
        adif_dc adif_dc_lista;

        vr_dif_data NUMBER;
        vr_dif_ano NUMBER;
        
        vr_vlrfinan NUMBER;

      BEGIN

        vr_parcela        := pr_primeiro_vcto;
        vr_vlr_prestacao  := pr_vlr_prestacao;
        vr_vlr_financiado := pr_vlr_financiado;

        -- Incluir validação se não valores validos
        IF NVL(pr_nro_parcelas,0)   = 0 OR
           NVL(vr_vlr_prestacao,0)  = 0 OR
           NVL(vr_vlr_financiado,0) = 0 OR 
           pr_data_contrato IS NULL     OR
           pr_primeiro_vcto IS NULL THEN          
          vr_dscritic := 'Valores nao Informados!';
          RAISE vr_exc_saida;
        END IF;

        vr_vlrfinan := vr_vlr_prestacao * pr_nro_parcelas;
        
        IF vr_vlrfinan < vr_vlr_financiado THEN         
          vr_dscritic := 'Total de Prestacoes menor que valor Principal!';
          RAISE vr_exc_saida;
        END IF;
       
        -- Se o valor financiado liquido for inferior a metade do valor da prestacao,
        -- nao pode deixar continuar
        IF (vr_vlr_financiado < vr_vlr_prestacao / 2) THEN   
					vr_dscritic := 'Impossivel calcular o CET com os valores informados.';
					RAISE vr_exc_saida;
        END IF; 
  
        vr_aux_v2 := TO_NUMBER(vr_vlr_financiado);
        vr_aux_a  := 0;
        vr_aux_b  := 0;
        vr_aux_p  := vr_vlr_prestacao;
        vr_primera_parcela := vr_parcela;
        vr_vlr_total := 0;

        vr_aux_n := (pr_nro_parcelas * (-1));
        vr_vjur1 := 1;
        vr_vjur2 := 0;
        vjur_fin1 := 1;
        vjur_fin2 := 0 ;
        vr_juros := 0.5;
        vr_juros_fin := 0.5;
        vjuranox_fin := 0;
        vr_contador := 0;

        LOOP
          vr_contador := vr_contador + 1;
          vr_aux_a := vr_aux_p * ((1-(POWER((1+vr_juros),vr_aux_n)))/vr_juros);

          IF (vr_aux_a < vr_aux_v2) THEN
            vr_vjur1 := vr_juros;
          ELSE
            vr_vjur2 := vr_juros;
          END IF;

          vr_juros  := (vr_vjur1+vr_vjur2)/2;

          EXIT WHEN (ABS(vr_aux_v2-vr_aux_a) <= 0.00001);

          IF vr_contador > 5000 THEN
            vr_dscritic := 'Impossivel calcular o CET com os valores informados.';
            RAISE vr_exc_saida;
					END IF;

        END LOOP;

        vr_juros := ROUND((vr_juros * 100),5);

        WHILE (ABS(vr_vlr_financiado - vr_aux_b) > 0.00001) LOOP

          vr_aux_b := vr_aux_p * ((1-(POWER((1+vr_juros_fin),vr_aux_n)))/vr_juros_fin);

          IF (vr_aux_b < vr_vlr_financiado) THEN
            vjur_fin1 := vr_juros_fin;
          ELSE
            vjur_fin2 := vr_juros_fin;
          END IF;

          vr_juros_fin := (vjur_fin1+vjur_fin2)/2;

        END LOOP;
       
        vjuranox_fin := ROUND(((POWER((1 + vr_juros_fin),12)-1) * 100),5);
        vr_juros_fin     := ROUND((vr_juros_fin * 100),5);

        vr_vlr_prestacao := ROUND(vr_vlr_prestacao,2);
        vr_vlr_financiado := ROUND(vr_vlr_financiado,2);
        
        --vr_dscritic := NULL;       
        
     --   IF TRIM(vr_dscritic) IS NULL THEN

          -- Lógica e cálculos das datas da tabela
          vr_vlr_total       := 0;
          vr_primera_parcela := vr_parcela;
          vr_ultimo_dia_ano  := fn_ultimo_dia_ano(pr_data_contrato);
          vr_dif_ano         := fn_diff_datas(pr_data_contrato,vr_ultimo_dia_ano);
          vr_dif_dc          := fn_diff_datas(pr_data_contrato,vr_parcela);
          vr_adiff_dc        := 0;
          vr_diff_data        := 0;
          vr_i_acerto        := 0;
          
          IF (vr_dif_dc > 30) THEN -- Se mais de 30 dias

            vr_i_acerto := 1;
            adif_dc(0).valor := vr_dif_dc - 30;
            adif_dc(1).valor := 30;

            IF (adif_dc(0).valor > 30) THEN -- Se mais de 60 dias
              vr_i_acerto      := 2;
              adif_dc(2).valor := adif_dc(0).valor - 30;
              adif_dc(3).valor := 0;
              adif_dc(4).valor := 30;
            END IF;

            vr_aux_idx := 0;
            vr_aux_i   := 0;

            WHILE (vr_aux_i < adif_dc.count) LOOP
              vr_adiff_dc   := vr_adiff_dc + adif_dc(vr_aux_i).valor;
              vr_aux_v1     := (1+vjuranox_fin/100);
              vr_aux_v2     := ABS(vr_adiff_dc)/(365);
              vr_vlr_desc1  := POWER(vr_aux_v1,vr_aux_v2);
              vr_vlr_desc   := ROUND((vr_vlr_prestacao / vr_vlr_desc1),2);
              vr_vlr_total  := vr_vlr_total + vr_vlr_desc;
              vr_aux_idx     := vr_aux_idx + 1;
              vr_aux_i       := vr_aux_i + vr_i_acerto;
            END LOOP;

              vr_vlr_total := ((vr_vlr_total)/(vr_i_acerto + 1));

          END IF;
          
          vr_contador := 0;
          WHILE ( vr_contador < pr_nro_parcelas) LOOP

            IF (vr_contador <> 0) THEN
              vr_prox_data := fn_proximo_vcto(vr_prox_data);
              vr_dif_data  := fn_diff_datas(vr_parcela,vr_prox_data);
            ELSE
              vr_prox_data := vr_parcela;
              vr_dif_data  := vr_dif_dc;
            END IF;

            IF ((vr_vlr_total <> 0) AND (vr_contador = 0) ) THEN
              vr_vlr_desc  := vr_vlr_total;
              vr_vlr_desc  := ROUND(vr_vlr_desc,2);
              vr_parcela   := vr_prox_data;
            ELSE
              vr_diff_data := vr_diff_data + vr_dif_data;
              vr_aux_v1    := (1+vjuranox_fin/100);
              vr_aux_v2    := ABS(vr_diff_data)/(vr_dif_ano);
              vr_vlr_desc1 := POWER(vr_aux_v1,vr_aux_v2);
              vr_vlr_desc  := vr_vlr_prestacao / vr_vlr_desc1;
              vr_vlr_desc  := ROUND(vr_vlr_desc,2);
              vr_vlr_total := vr_vlr_total + vr_vlr_desc;
              vr_parcela   := vr_prox_data;
            END IF;

            vr_contador := vr_contador + 1;
          END LOOP;
          
          vr_juros_cet := fn_calcula_juros_cet(pr_nro_parcelas
                                              ,vjuranox_fin
                                              ,vr_juros
                                              ,vr_primera_parcela
                                              ,pr_data_contrato
                                              ,vr_vlr_financiado
                                              ,vr_vlr_prestacao);                         
                                                                              
          vr_juros_fin   := (POWER(1+ (vr_juros_cet/100),(1/12))-1)*100;

          pr_valorcet   := ROUND(vr_juros_cet,2);
          pr_tx_cet_ano := vr_juros_cet;
          pr_tx_cet_mes := vr_juros_fin;         
          
     /*   ELSE -- IF TRIM(vr_dscritic) IS NULL THEN
          RAISE vr_exc_saida;
        END IF;*/

      EXCEPTION
        WHEN vr_exc_saida THEN
          pr_cdcritic := NVL(vr_cdcritic,0);
          pr_dscritic := vr_dscritic;
        WHEN OTHERS THEN
          pr_cdcritic := NVL(vr_cdcritic,0);
          pr_dscritic := 'Erro pc_juros_cet : ' || SQLERRM;
    END;
  END pc_juros_cet;  

  -- Calcular IOF
  PROCEDURE pc_calcula_iof(pr_cdcooper  IN crapcop.cdcooper%TYPE -- Cooperativa
                          ,pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE -- Data Movimento
                          ,pr_vlemprst  IN crapepr.vlemprst%TYPE -- Valor emprestado
                          ,pr_cdprogra  IN VARCHAR2              -- Programa chamador
                          ,pr_cdlcremp  IN craplim.cddlinha%TYPE -- Linha de credio
                          ,pr_inpessoa  IN crapass.inpessoa%TYPE
                          ,pr_dtinivig  IN craplim.dtinivig%TYPE
                          ,pr_qtdiavig  IN NUMBER
                          ,pr_vllanmto OUT craplcm.vllanmto%TYPE -- Valor calculado com o iof
                          ,pr_txccdiof OUT NUMBER -- Taxa do IOF
                          ,pr_cdcritic OUT INTEGER
                          ,pr_dscritic OUT VARCHAR2) IS 
  BEGIN
  /* .............................................................................

  Programa: pc_calcula_iof                 
  Sistema : Conta-Corrente - Cooperativa de Credito
  Sigla   : CRED
  Autor   : Lucas Ranghetti
  Data    : Julho/2014                        Ultima atualizacao: 00/00/0000

  Dados referentes ao programa:

  Frequencia: Diaria - Sempre que for chamada
  Objetivo  : Rotina para calcular o IOF

  Alteracoes:                  
  ............................................................................. */
    DECLARE
    
      -- VARIAVEIS
      vr_txccdiof NUMBER;
      vr_dstextab VARCHAR2(500);
      
      -- Busca os dados da linha de credito
      CURSOR cr_craplcr IS
        SELECT flgtaiof 
          FROM craplcr 
         WHERE cdcooper = pr_cdcooper
           AND cdlcremp = pr_cdlcremp;
      rw_craplcr cr_craplcr%ROWTYPE;
      
      vr_qtdiavig NUMBER := 0;
      vr_vliofcal NUMBER := 0;
      vr_periofop NUMBER := 0;
      
    BEGIN
      -- Busca o indicador de IOF na linha de credito
      OPEN cr_craplcr;
      FETCH cr_craplcr INTO rw_craplcr;
      CLOSE cr_craplcr;  
    
      -- Se o indicador de IOF for isento, entao nao deve-se calcular
      IF nvl(rw_craplcr.flgtaiof,1) = 0 THEN
        vr_txccdiof := 0;
      ELSE
        -- Buscar taxa de iof
        -- Buscar dados de CPMF na tabela de parametros
        vr_dstextab := TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                                 ,pr_nmsistem => 'CRED'
                                                 ,pr_tptabela => 'USUARI'
                                                 ,pr_cdempres => 11
                                                 ,pr_cdacesso => 'VLIOFOPFIN'
                                                 ,pr_tpregist => 1);

        IF vr_dstextab IS NOT NULL THEN
          -- Povoar as informacões conforme as regras da versão anterior
          IF pr_dtmvtolt BETWEEN  TO_DATE(SUBSTR(vr_dstextab,1,10),'DD/MM/YYYY') AND 
                                  TO_DATE(SUBSTR(vr_dstextab,12,10),'DD/MM/YYYY') THEN
            vr_txccdiof := SUBSTR(vr_dstextab,23,14); --GENE0002.fn_char_para_number(SUBSTR(vr_dstextab,23,14));
          ELSE
            vr_txccdiof := 0;
          END IF;
        ELSE
          -- Montar retorno de erro
          pr_cdcritic := 915;
          pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 915);
          RETURN;
        END IF;

      END IF;

      -- Calcula o valor emprestado com a taxa de IOF
      pr_vllanmto := ROUND(pr_vlemprst * vr_txccdiof,2);
     
      IF pr_dtinivig >= to_date('03/04/2017','DD/MM/YYYY') AND pr_vllanmto > 0 THEN
      
        IF pr_qtdiavig > 365 THEN
          vr_qtdiavig := 365;
        ELSE
          vr_qtdiavig := pr_qtdiavig;
        END IF;  
            
        IF pr_inpessoa = 1 THEN
          -- IOF Operacacao PF
          vr_periofop := vr_qtdiavig * 0.0082;
        ELSE  
          -- IOF Operacacao PJ
          vr_periofop := vr_qtdiavig * 0.0041;
        END IF;  

        -- Calculo IOF Adicional
        vr_vliofcal := ROUND((pr_vlemprst * vr_periofop) / 100,2); 
        
        pr_vllanmto := pr_vllanmto + vr_vliofcal;  
   
      END IF;      
     
    -- Caso ocorra erro
    EXCEPTION
      WHEN OTHERS THEN
        pr_cdcritic := 0;
        pr_dscritic := 'Erro pc_calcula_iof : ' || SQLERRM;
        
    END; 
  END pc_calcula_iof;
  
  -- Calcular a tarifa de cadastro 
  PROCEDURE pc_calcula_tarifa_cadastro(pr_cdcooper  IN crapcop.cdcooper%TYPE -- Cooperativa
                                      ,pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE -- Data Movimento
                                      ,pr_vlemprst  IN crapepr.vlemprst%TYPE -- Valor emprestado
                                      ,pr_cdbattar  IN VARCHAR2              -- Codigo Tarifa
                                      ,pr_cdprogra  IN VARCHAR2              -- Codigo Programa
                                      ,pr_cdusolcr  IN craplcr.cdusolcr%TYPE -- Codigo uso Linha Credito
                                      ,pr_inpessoa  IN INTEGER               -- Tipo de pessoa
                                      ,pr_cdlcremp  IN INTEGER               -- Codigo linha credio
                                      ,pr_tpctrato  IN craplcr.tpctrato%TYPE -- Tipo do contrato
                                      ,pr_nrdconta  IN crapass.nrdconta%type -- Numero da conta
                                      ,pr_nrctremp  IN NUMBER                -- Numero do Emprestimo
                                      ,pr_vltottar OUT NUMBER                -- Valor Tarifa
                                      ,pr_cdcritic OUT INTEGER
                                      ,pr_dscritic OUT VARCHAR2) IS
  BEGIN
  /* .............................................................................

  Programa: pc_calcula_tarifa_cadastro                 
  Sistema : Conta-Corrente - Cooperativa de Credito
  Sigla   : CRED
  Autor   : Lucas Ranghetti
  Data    : Julho/2014                        Ultima atualizacao: 00/00/0000

  Dados referentes ao programa:

  Frequencia: Diaria - Sempre que for chamada
  Objetivo  : Rotina para calcular a tarifa de cadastro para o CET

  Alteracoes:                  
  ............................................................................. */
    DECLARE
      cursor cr_crapbpr is
        select count(*)
          from crapbpr
         where cdcooper = pr_cdcooper
           and nrdconta = pr_nrdconta
           and tpctrpro = 90
           and nrctrpro = pr_nrctremp
           and flgalien = 1;
    
      vr_cdhistor INTEGER;
      vr_cdhisest INTEGER;
      vr_vlrtarif NUMBER;
      vr_vltrfesp NUMBER;
      vr_dtdivulg DATE;
      vr_dtvigenc DATE;
      vr_cdfvlcop INTEGER;
      vr_vltarbem NUMBER;
      vr_cdbattar VARCHAR2(15);      
      vr_qttarbem NUMBER(3) := 1;    
    
      -- Variaveis de erro
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic crapcri.dscritic%TYPE;
      -- tabela de erros
      vr_tab_erro   GENE0001.typ_tab_erro;
    
      -- Variavel exceção
      vr_exc_erro EXCEPTION;
    
    BEGIN            
      -- craplcr.cdusolcr 1/CDC 
      IF  pr_cdusolcr = 1 THEN
              
        -- Buscar tarifa vigente
        TARI0001.pc_carrega_dados_tar_vigente(pr_cdcooper => pr_cdcooper
                                             ,pr_cdbattar => pr_cdbattar
                                             ,pr_vllanmto => pr_vlemprst
                                             ,pr_cdprogra => pr_cdprogra
                                             ,pr_cdhistor => vr_cdhistor
                                             ,pr_cdhisest => vr_cdhisest
                                             ,pr_vltarifa => vr_vlrtarif
                                             ,pr_dtdivulg => vr_dtdivulg
                                             ,pr_dtvigenc => vr_dtvigenc
                                             ,pr_cdfvlcop => vr_cdfvlcop
                                             ,pr_cdcritic => vr_cdcritic
                                             ,pr_dscritic => vr_dscritic
                                             ,pr_tab_erro => vr_tab_erro);
                                                                  
        IF vr_cdcritic IS NOT NULL OR TRIM(vr_dscritic) IS NOT NULL THEN
          
          --Se possui erro no vetor
          IF vr_tab_erro.Count > 0 THEN
            vr_cdcritic:= vr_tab_erro(1).cdcritic;
            vr_dscritic:= vr_tab_erro(1).dscritic;              
          ELSE
            vr_cdcritic:= 0;
            vr_dscritic:= 'Nao foi possivel carregar a tarifa.';
          END IF;
          
          RAISE vr_exc_erro;
          
        END IF;     
      ELSE 

        -- Buscar tarifa emprestimo
        TARI0001.pc_carrega_dados_tarifa_empr(pr_cdcooper => pr_cdcooper
                                             ,pr_cdlcremp => pr_cdlcremp
                                             ,pr_cdmotivo => 'EM'
                                             ,pr_inpessoa => pr_inpessoa
                                             ,pr_vllanmto => pr_vlemprst
                                             ,pr_cdprogra => pr_cdprogra
                                             ,pr_cdhistor => vr_cdhistor
                                             ,pr_cdhisest => vr_cdhisest
                                             ,pr_vltarifa => vr_vlrtarif
                                             ,pr_dtdivulg => vr_dtdivulg
                                             ,pr_dtvigenc => vr_dtvigenc
                                             ,pr_cdfvlcop => vr_cdfvlcop
                                             ,pr_cdcritic => vr_cdcritic
                                             ,pr_dscritic => vr_dscritic
                                             ,pr_tab_erro => vr_tab_erro);                                                                                            
        
        IF vr_cdcritic IS NOT NULL OR TRIM(vr_dscritic) IS NOT NULL THEN                    
          RAISE vr_exc_erro;
        END IF;   
        
         -- Buscar tarifa emprestimo Especial
        TARI0001.pc_carrega_dados_tarifa_empr(pr_cdcooper => pr_cdcooper
                                             ,pr_cdlcremp => pr_cdlcremp
                                             ,pr_cdmotivo => 'ES'
                                             ,pr_inpessoa => pr_inpessoa
                                             ,pr_vllanmto => pr_vlemprst
                                             ,pr_cdprogra => pr_cdprogra
                                             ,pr_cdhistor => vr_cdhistor
                                             ,pr_cdhisest => vr_cdhisest
                                             ,pr_vltarifa => vr_vltrfesp
                                             ,pr_dtdivulg => vr_dtdivulg
                                             ,pr_dtvigenc => vr_dtvigenc
                                             ,pr_cdfvlcop => vr_cdfvlcop
                                             ,pr_cdcritic => vr_cdcritic
                                             ,pr_dscritic => vr_dscritic
                                             ,pr_tab_erro => vr_tab_erro);                                                                                            
        
        IF vr_cdcritic IS NOT NULL OR TRIM(vr_dscritic) IS NOT NULL THEN                    
          RAISE vr_exc_erro;
        END IF;                               
      END IF;
      
      /* 2 - Avaliacao de garantia de bem movel  */
      /* 3 - Avaliacao de garantia de bem imovel */
      IF ( pr_tpctrato = 2 ) OR ( pr_tpctrato = 3 ) THEN       
        IF pr_tpctrato = 2 THEN /* Bens Moveis */
          /* Verifica qual tarifa deve ser cobrada com base tipo pessoa */
          IF pr_inpessoa = 1 THEN /* Fisica */
             vr_cdbattar := 'AVALBMOVPF';
          ELSE
              vr_cdbattar := 'AVALBMOVPJ';
          END IF;
        ELSE /* Bens Imoveis */
          IF pr_inpessoa = 1 THEN /* Fisica */
              vr_cdbattar := 'AVALBIMVPF';
          ELSE
              vr_cdbattar := 'AVALBIMVPJ';
          END IF;
        END IF;        
        -- Buscar tarifa vigente
        TARI0001.pc_carrega_dados_tar_vigente(pr_cdcooper => pr_cdcooper
                                             ,pr_cdbattar => vr_cdbattar
                                             ,pr_vllanmto => pr_vlemprst
                                             ,pr_cdprogra => pr_cdprogra
                                             ,pr_cdhistor => vr_cdhistor
                                             ,pr_cdhisest => vr_cdhisest
                                             ,pr_vltarifa => vr_vltarbem
                                             ,pr_dtdivulg => vr_dtdivulg
                                             ,pr_dtvigenc => vr_dtvigenc
                                             ,pr_cdfvlcop => vr_cdfvlcop
                                             ,pr_cdcritic => vr_cdcritic
                                             ,pr_dscritic => vr_dscritic
                                             ,pr_tab_erro => vr_tab_erro);
                                               
           
                                
                                                                    
        IF vr_cdcritic IS NOT NULL OR TRIM(vr_dscritic) IS NOT NULL THEN             
          --Se possui erro no vetor
          IF vr_tab_erro.Count > 0 THEN
            vr_cdcritic:= vr_tab_erro(1).cdcritic;
            vr_dscritic:= vr_tab_erro(1).dscritic;              
          ELSE
            vr_cdcritic:= 0;
            vr_dscritic:= 'Nao foi possivel carregar a tarifa.';
          END IF;
            
          RAISE vr_exc_erro;
            
        END IF;
      END IF;
      
     if pr_tpctrato = 2 then
       open cr_crapbpr;
       fetch cr_crapbpr into vr_qttarbem;
       close cr_crapbpr;
       
       if vr_qttarbem > 1 then
         vr_vltarbem := nvl(vr_vltarbem,0) * vr_qttarbem;
       end if;
     end if;

     -- calcular a tarifa de cadastro + a tarifa do bem alienado se tiver
     pr_vltottar := nvl(vr_vlrtarif,0) + nvl(vr_vltarbem,0) + nvl(vr_vltrfesp,0);
          
     -- Caso ocorra erro
    EXCEPTION
      WHEN vr_exc_erro THEN        
        -- Monta mensagem de erro
        pr_cdcritic := NVL(vr_cdcritic,0);
        pr_dscritic := vr_dscritic;
      WHEN OTHERS THEN
        pr_cdcritic := 0;
        pr_dscritic := 'Erro pc_calcula_tarifa_cadastro : ' || SQLERRM;
        
    END;  
  END pc_calcula_tarifa_cadastro;
  
  -- Calcular a taxa de juros
  PROCEDURE pc_calc_taxa_juros(pr_cdcooper  IN crapcop.cdcooper%TYPE -- Cooperativa
                              ,pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE -- Data Movimento
                              ,pr_tpdjuros  IN INTEGER               -- Tipo do juros
                              ,pr_vllanmto  IN NUMBER                -- Valor a calcular
                              ,pr_txmensal  IN NUMBER                -- Taxa Juros
                              ,pr_cddlinha  IN craplim.cddlinha%TYPE -- Codigo Linha credito
                              ,pr_tpctrlim  IN craplim.tpctrlim%TYPE -- Tipo de Limite
                              ,pr_vlrjuros OUT NUMBER                -- Valor Juros
                              ,pr_cdcritic OUT INTEGER
                              ,pr_dscritic OUT VARCHAR2) IS
  BEGIN
  /* .............................................................................

  Programa: pc_calc_taxa_juros
  Sistema : Conta-Corrente - Cooperativa de Credito
  Sigla   : CRED
  Autor   : Lucas Ranghetti
  Data    : Julho/2014                        Ultima atualizacao: 00/00/0000

  Dados referentes ao programa:

  Frequencia: Diaria - Sempre que for chamada
  Objetivo  : Rotina para calcular a taxa juros

  Alteracoes:                  
  ............................................................................. */
    DECLARE
    
    -- Variaveis de erro
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic crapcri.dscritic%TYPE;    
    
    -- Variavel exceção
    vr_exc_erro EXCEPTION;

    -- CURSORES
    CURSOR cr_craplrt IS
    SELECT txmensal FROM craplrt
     WHERE craplrt.cdcooper = pr_cdcooper
       AND craplrt.cddlinha = pr_cddlinha;
    rw_craplrt cr_craplrt%ROWTYPE;
    
    CURSOR cr_crapldc IS
    SELECT txmensal FROM crapldc
     WHERE crapldc.cdcooper = pr_cdcooper
       AND crapldc.cddlinha = pr_cddlinha
       AND crapldc.tpdescto = pr_tpctrlim;
    rw_crapldc cr_crapldc%ROWTYPE;   
    
    BEGIN
      -- 0 = Taxa Anual/ 1 = Taxa mensal buscada da craplrt
      IF pr_tpdjuros = 1 THEN
        -- abre cursor da tabela
        IF pr_tpctrlim = 1 THEN
          -- Para limite de credito
          OPEN cr_craplrt;
          FETCH cr_craplrt INTO rw_craplrt;
          
          -- se achou registro
          IF cr_craplrt%FOUND THEN
            CLOSE cr_craplrt;
            -- calcular valor do juros 
            pr_vlrjuros := (pr_vllanmto * (rw_craplrt.txmensal / 100)); 

          ELSE
            -- fechar cursor
            CLOSE cr_craplrt;
            -- gravar critica
            vr_cdcritic := 0;
            vr_dscritic := 'Registro nao encontrado na tabela craplrt.';
            -- Levantar excessao
            RAISE vr_exc_erro;
          END IF;   
        ELSE
          -- Para descontos
          OPEN cr_crapldc;
          FETCH cr_crapldc INTO rw_crapldc;
          
          -- se achou registro
          IF cr_crapldc%FOUND THEN
            CLOSE cr_crapldc;
            -- calcular valor do juros 
            pr_vlrjuros := (pr_vllanmto * (rw_crapldc.txmensal / 100)); 

          ELSE
            -- fechar cursor
            CLOSE cr_craplrt;
            -- gravar critica
            vr_cdcritic := 0;
            vr_dscritic := 'Registro nao encontrado na tabela crapldc.';
            -- Levantar excessao
            RAISE vr_exc_erro;
          END IF;
        END IF;
      ELSE
        -- Calculo da taxa anual
        pr_vlrjuros := ROUND((POWER(1 + (NVL(pr_txmensal,0) / 100),12) - 1) * 100,2);
      END IF;
      
    -- Caso ocorra erro
    EXCEPTION
      WHEN vr_exc_erro THEN        
        -- Monta mensagem de erro
        pr_cdcritic := NVL(vr_cdcritic,0);
        pr_dscritic := vr_dscritic;
      WHEN OTHERS THEN
        pr_cdcritic := 0;
        pr_dscritic := 'Erro pc_calc_taxa_juros : ' || SQLERRM;
        
    END;  
  END pc_calc_taxa_juros;
  
  -- Imprimir contrato de limites do CET
  PROCEDURE pc_imprime_limites_cet(pr_cdcooper  IN crapcop.cdcooper%TYPE -- Cooperativa
                                  ,pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE -- Data Movimento
                                  ,pr_cdprogra  IN VARCHAR2              -- Programa chamador
                                  ,pr_nrdconta  IN craplim.nrdconta%TYPE -- Conta/dv
                                  ,pr_inpessoa  IN crapass.inpessoa%TYPE -- Indicativo de pessoa
                                  ,pr_cdusolcr  IN craplcr.cdusolcr%TYPE -- Codigo de uso da linha de credito
                                  ,pr_cdlcremp  IN craplim.cddlinha%TYPE -- Linha de credio
                                  ,pr_tpctrlim  IN craplim.tpctrlim%TYPE -- Tipo da operacao
                                  ,pr_nrctrlim  IN craplim.nrctrlim%TYPE -- Contrato
                                  ,pr_dtinivig  IN craplim.dtinivig%TYPE -- Data liberacao
                                  ,pr_qtdiavig  IN craplrt.qtdiavig%TYPE -- Dias de vigencia                                      
                                  ,pr_vlemprst  IN crapepr.vlemprst%TYPE -- Valor emprestado
                                  ,pr_txmensal  IN craplrt.txmensal%TYPE -- Taxa mensal                                                               
                                  ,pr_flretxml  IN INTEGER DEFAULT 0     -- Indicador se deve apenas retornar o XML da impressao
                                  ,pr_des_xml  OUT CLOB                  -- XML
                                  ,pr_nmarqimp OUT VARCHAR2              -- Nome do arquivo
                                  ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                  ,pr_dscritic OUT VARCHAR2) IS          --> Descrição da crítica
  BEGIN
  /* .............................................................................

  Programa: pc_imprime_limites_cet                 
  Sistema : Conta-Corrente - Cooperativa de Credito
  Sigla   : CRED
  Autor   : Lucas Ranghetti
  Data    : Julho/2014                        Ultima atualizacao: 23/12/2016

  Dados referentes ao programa:

  Frequencia: Diaria - Sempre que for chamada
  Objetivo  : Rotina para gerar planilha de demonstracao do CET, limites

  Alteracoes: 18/02/2015 - Alterado rotina para calcular a quantidade de meses de vigencia,
                           agora calcula a quantidade de dias dividido por 30 (Lucas R. #251487)
              
              05/05/2015 - Alterado o campo flg_impri da procedure pc_solicita_relato de 'S' para 'N'
                           para não gerar o arquivo pdf no diretório audit_pdf (Lucas Ranghetti #281494)
              
              13/09/2016 - Incluido parametros para permitir retornar o XML de geração do relatorio
                           para ser adicionado em outros relatorios. 
                           PRJ314-Indexação centralizada (Odirlei-AMcom)             
                           
              23/12/2016 - Ajuste para aumentar o tamanho do campo que recebe o nome da cooperativa
                           pois estava estourando o format
                           (Adriano - SD 582204).                                       
  ............................................................................. */
    DECLARE
    
      vr_qtdparce NUMBER;                     -- Quantidade de parcelas
      vr_vlrprest NUMBER := 0;                -- Valor da prestacao
      vr_vlrdocet NUMBER := 0;                -- Valor do CET
      -- Variaveis de erro
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic crapcri.dscritic%TYPE; 
      
      -- VARIAVEIS A ENVIAR PARA O XML
      vr_nmoperac VARCHAR2(20);          -- Operacao, 1 Lim. Cre, 2 Desc. Cheque, 3 Desc. Titulo
      vr_dtvencto DATE;                  -- Data vencto Contrato, dtinivig + qtdiavig
      vr_txmensal craplrt.txmensal%TYPE := 0; -- Taxa mensal
      vr_txdjuros NUMBER := 0;                -- Taxa anual
      vr_vllimite craplim.vllimite%TYPE := 0; -- Valor limite
      vr_vlrdoiof NUMBER := 0;                -- IOF calculado
      vr_txjuriof NUMBER := 0;                -- Taxa do IOF
      vr_vlrtarif NUMBER := 0;                -- Valor Tar. Cadastro
      vr_txjurtar NUMBER := 0;                -- Taxa Tar. Cadastro
      vr_vlrdsegu NUMBER := 0;                -- Valor Seg. prestamista
      vr_txjurseg NUMBER := 0;                -- Taxa Seg. prestamista
      vr_vlemprst NUMBER := 0;                -- Valor total emprestado, calculado
      vr_txjuremp NUMBER := 0;                -- Taxa do valor emprestado
      vr_txanocet NUMBER := 0;                -- taxa anual do cet
      vr_txmescet NUMBER := 0;                -- taxa mensal do cet
      vr_txjurlim NUMBER := 0;                -- Taxa juros limite
      vr_cdbattar VARCHAR2(15);               -- CODIGO DA TARIFA
      vr_txadoiof NUMBER := 0;                -- Taxa do iof
      vr_vljurrem NUMBER := 0;                -- Valor de juros remunerados
      vr_txjurrem NUMBER := 0;                -- Taxa de juros remunerados
      vr_dsdprazo VARCHAR2(20);               -- Prazo do contrato
      vr_vltaxa_iof_principal NUMBER(25,8);
      vr_dscooper VARCHAR2(70);               -- Descrição da cooperativa
            
      -- Variavel exceção
      vr_exc_erro EXCEPTION;      
      
      vr_ind      VARCHAR2(100);
      
      -- Variável de Controle de XML
      vr_des_xml      CLOB;
      vr_path_arquivo VARCHAR2(1000);
      vr_dspathcop    VARCHAR2(4000);

      vr_tab_erro GENE0001.typ_tab_erro; --> Tabela com erros
      -- Variaveis pdf
      vr_nmarqpdf VARCHAR2(100) := '';
      vr_nmauxpdf VARCHAR2(100) := '';
      vr_nmarqimp VARCHAR2(100) := '';
      vr_cdhistor NUMBER; -- historico de lançamento
      
      vr_vliofpri NUMBER;
      vr_vliofadi NUMBER;
      vr_vliofcpl NUMBER;
      vr_flgimune BOOLEAN;
      vr_tpproduto NUMBER;
      vr_natjurid NUMBER := 0;
      vr_tpregtrb NUMBER := 0;
      -- CURSORES PARA UTILIZAR NA PACKAGE
      CURSOR cr_crapcop IS 
      SELECT cop.nmextcop,
             cop.nmrescop
        FROM crapcop cop
       WHERE cop.cdcooper = pr_cdcooper;
       rw_crapcop cr_crapcop%ROWTYPE;
      
      CURSOR cr_craplat(pr_cdcooper IN crapcop.cdcooper%TYPE
                       ,pr_nrdconta IN crapass.nrdconta%TYPE
                       ,pr_dtinivig IN crapdat.dtmvtolt%TYPE
                       ,pr_cdhistor IN craphis.cdhistor%TYPE) IS
        SELECT lat.vltarifa
          FROM craplat lat
          WHERE lat.cdcooper = pr_cdcooper
            AND lat.nrdconta = pr_nrdconta
            AND lat.dtmvtolt = pr_dtinivig
            AND lat.cdhistor = pr_cdhistor;
        rw_craplat cr_craplat%ROWTYPE; 
      CURSOR cr_crapjur(pr_cdcooper IN crapjur.cdcooper%TYPE
                          ,pr_nrdconta IN crapjur.nrdconta%TYPE) IS
       SELECT crapjur.natjurid, crapjur.tpregtrb
       FROM crapjur 
       WHERE crapjur.natjurid = pr_cdcooper AND crapjur.nrdconta = pr_nrdconta;
      rw_crapjur cr_crapjur%ROWTYPE;
        
      --Procedure que escreve linha no arquivo CLOB
      PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR2) IS
      BEGIN

        --Escrever no arquivo CLOB
        dbms_lob.writeappend(vr_des_xml,length(pr_des_dados),pr_des_dados);
      END;
    
    BEGIN            
      -- Buscar descrição da cooperativa
      OPEN cr_crapcop;
      FETCH cr_crapcop INTO rw_crapcop;
      
      -- Se achou cooperativa 
      IF cr_crapcop%FOUND THEN
        CLOSE cr_crapcop;
        -- Grava nome completo mais o resumido
        vr_dscooper := TRIM(rw_crapcop.nmextcop) || ' - ' || TRIM(rw_crapcop.nmrescop);    
      END IF;    
    
      -- NOME DA OPERACAO
      IF pr_tpctrlim = 1 THEN
        vr_nmoperac := 'LIMITE DE CREDITO';
      ELSIF pr_tpctrlim = 2 THEN
        vr_nmoperac := 'DESCONTO DE CHEQUE';
      ELSIF pr_tpctrlim = 3 THEN
        vr_nmoperac := 'DESCONTO DE TITULO';
      END IF;
      
      -- Prazo do contrato, rotina para calcluar a quantidade de meses de vigencia, 
      -- a divisão será sempre por 30 dias
      vr_dsdprazo := round(to_char(pr_qtdiavig/30)) || ' MESES';
      
      -- Data do vencimento do credito  
      vr_dtvencto := pr_dtinivig + pr_qtdiavig; 
      
      -- Taxa de juros remunerados mensal
      vr_txmensal := pr_txmensal;
      
      -- Calcular taxa de juros anual
      CCET0001.pc_calc_taxa_juros(pr_cdcooper => pr_cdcooper
                                 ,pr_dtmvtolt => pr_dtmvtolt
                                 ,pr_tpdjuros => 0 -- Anual
                                 ,pr_vllanmto => 0 -- Anual passa zero
                                 ,pr_txmensal => pr_txmensal
                                 ,pr_cddlinha => 0
                                 ,pr_tpctrlim => pr_tpctrlim 
                                 ,pr_vlrjuros => vr_txdjuros -- Taxa anual
                                 ,pr_cdcritic => vr_cdcritic
                                 ,pr_dscritic => vr_dscritic);      
      -- VERIFICA SE OCORREU UMA CRITICA
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;        
      END IF;                                                                                                                         

      
      -- gravar codigo da tarifa e historico de lançamento
      IF pr_inpessoa = 1 THEN -- Fisica
        IF pr_tpctrlim = 1 THEN /* limcre */
          vr_cdbattar := 'COLIMCHQPF';
          vr_cdhistor := 1481;
          vr_tpproduto := 4;
        ELSIF pr_tpctrlim = 3 THEN /* desctit */
          vr_cdbattar := 'DSTCONTRPF';
          vr_cdhistor := 1429;
          vr_tpproduto := 2;
        ELSIF pr_tpctrlim = 2 THEN /* DESCCHQ */
          vr_cdbattar := 'DSCCHQCTPF';
          vr_cdhistor := 1423;
          vr_tpproduto := 3;
        END IF;
      ELSE -- Juridica
        IF pr_tpctrlim = 1 THEN /* limcre */
          vr_cdbattar := 'COLIMCHQPJ';
          vr_cdhistor := 1479;
          vr_tpproduto := 4;
        ELSIF pr_tpctrlim = 3 THEN /* desctit */
          vr_cdbattar := 'DSTCONTRPJ'; 
          vr_cdhistor := 1453;
          vr_tpproduto := 2;
        ELSIF pr_tpctrlim = 2 THEN /* DESCCHQ */
          vr_cdbattar := 'DSCCHQCTPJ';
          vr_cdhistor := 1447;
          vr_tpproduto := 3;
        END IF;           
      END IF;
      OPEN cr_crapjur(pr_cdcooper => pr_cdcooper
                     ,pr_nrdconta => pr_nrdconta);
      FETCH cr_crapjur INTO rw_crapjur;
      IF cr_crapjur%FOUND THEN
         vr_natjurid := rw_crapjur.natjurid;
         vr_tpregtrb := rw_crapjur.tpregtrb;
      END IF;
      CLOSE cr_crapjur;
      --Novo cálculo do IOF
      TIOF0001.pc_calcula_valor_iof(pr_tpproduto  => vr_tpproduto --> Tipo do Produto (1-> Emprestimo, 2-> Desconto Titulo, 3-> Desconto Cheque, 4-> Limite de Credito, 5-> Adiantamento Depositante)
                                   ,pr_tpoperacao => 1 --> Tipo da Operacao (1-> Calculo IOF/Atraso, 2-> Calculo Pagamento em Atraso)
                                   ,pr_cdcooper   => pr_cdcooper --> Código da cooperativa
                                   ,pr_nrdconta   => pr_nrdconta --> Número da conta
                                   ,pr_inpessoa   => pr_inpessoa --> Tipo de Pessoa
                                   ,pr_natjurid   => vr_natjurid --> Natureza Juridica
                                   ,pr_tpregtrb   => vr_tpregtrb --> Tipo de Regime Tributario
                                   ,pr_dtmvtolt   => pr_dtmvtolt --> Data do movimento para busca na tabela de IOF
                                   ,pr_qtdiaiof   => pr_qtdiavig --> Qde dias em atraso (cálculo IOF atraso)
                                   ,pr_vloperacao => pr_vlemprst --> Valor total da operação (pode ser negativo também)
                                   ,pr_vltotalope => pr_vlemprst --> Valor total da operação (pode ser negativo também)
                                   ,pr_vliofpri   => vr_vliofpri   --> Retorno do valor do IOF principal
                                   ,pr_vliofadi   => vr_vliofadi   --> Retorno do valor do IOF adicional
                                   ,pr_vliofcpl   => vr_vliofcpl   --> Retorno do valor do IOF complementar
                                   ,pr_vltaxa_iof_principal => vr_vltaxa_iof_principal
                                   ,pr_dscritic   => vr_dscritic);                                   
      vr_vlrdoiof := NVL(vr_vliofpri,0) + NVL(vr_vliofadi,0);
      -- VERIFICA SE OCORREU UMA CRITICA
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;        
      END IF;
      
      -- abre cursor da tabela
      OPEN cr_craplat(pr_cdcooper => pr_cdcooper,
                      pr_nrdconta => pr_nrdconta,
                      pr_dtinivig => pr_dtinivig,
                      pr_cdhistor => vr_cdhistor);
      FETCH cr_craplat INTO rw_craplat;
        
      -- se achou registro
      IF cr_craplat%FOUND THEN
        CLOSE cr_craplat;
        -- se encontrou lancamento da tarifa
        vr_vlrtarif := ROUND(nvl(rw_craplat.vltarifa,0),2);       
        
      ELSE -- se nao encontrou lançamento de tarifa busca a tarifa vigente
        -- Fechar cursor
        CLOSE cr_craplat; 
        
        -- buscar tarifa de cadastro linha de credito
        CCET0001.pc_calcula_tarifa_cadastro(pr_cdcooper => pr_cdcooper
                                           ,pr_dtmvtolt => pr_dtmvtolt
                                           ,pr_vlemprst => pr_vlemprst
                                           ,pr_cdbattar => vr_cdbattar
                                           ,pr_cdprogra => pr_cdprogra
                                           ,pr_cdusolcr => pr_cdusolcr 
                                           ,pr_inpessoa => pr_inpessoa
                                           ,pr_cdlcremp => pr_cdlcremp
                                           ,pr_tpctrato => 0
                                           ,pr_nrdconta => pr_nrdconta
                                           ,pr_nrctremp => pr_nrctrlim
                                           ,pr_vltottar => vr_vlrtarif
                                           ,pr_cdcritic => vr_cdcritic
                                           ,pr_dscritic => vr_dscritic);
                                                               
        -- VERIFICA SE OCORREU UMA CRITICA
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;        
        END IF;                                                                                      
      END IF;           
                            
      -- Valor juros remunerados
      vr_vljurrem := (pr_vlemprst * nvl(vr_txmensal,0) ) / 100;
      
      -- valor total emprestado tarifado e com o iof
      vr_vlemprst := nvl(pr_vlemprst,0) + nvl(vr_vlrdoiof,0) + nvl(vr_vlrtarif,0) + nvl(vr_vljurrem,0);
                           
      -- Quantidade de parcelas
      IF pr_tpctrlim IN(1,2,3) THEN
        vr_qtdparce := 1;
      END IF;
      
      -- Calcular taxa de juros MENSAL
      CCET0001.pc_calc_taxa_juros(pr_cdcooper => pr_cdcooper
                                 ,pr_dtmvtolt => pr_dtmvtolt
                                 ,pr_tpdjuros => 1 -- Mensal
                                 ,pr_vllanmto => pr_vlemprst
                                 ,pr_txmensal => pr_txmensal
                                 ,pr_cddlinha => pr_cdlcremp
                                 ,pr_tpctrlim => pr_tpctrlim
                                 ,pr_vlrjuros => vr_vlrprest -- Prestacao com juros
                                 ,pr_cdcritic => vr_cdcritic
                                 ,pr_dscritic => vr_dscritic);
      -- VERIFICA SE OCORREU UMA CRITICA
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;        
      END IF;                                 
            
      -- Porcentagem do valor do limite
      vr_txjurlim := ((nvl(pr_vlemprst,0) - nvl(vr_vlrdoiof,0) - nvl(vr_vlrtarif,0) - nvl(vr_vljurrem,0) ) * 100) / pr_vlemprst;
            
      -- Taxa de juros do iof
      vr_txjuriof := round((vr_vlrdoiof * 100) / pr_vlemprst,2);
            
      -- Taxa de juros da tarifa
      vr_txjurtar := round((vr_vlrtarif * 100) / pr_vlemprst,2);       
      
      -- Taxa do juros remunerados
      vr_txjurrem := round((vr_vljurrem * 100) / pr_vlemprst,2);
      
      -- Porcentagem  do valor total
      vr_txjuremp := 100;
      
      -- Taxa Mensal
      vr_txmescet := nvl(pr_txmensal,0) + nvl(vr_txjuriof,0) + nvl(vr_txjurtar,0);
      vr_txmescet := ROUND((POWER(1 + (nvl(vr_txmescet,0) / 100),1) - 1) * 100,2);       
      -- Taxa Anual
      vr_txanocet := ROUND((POWER(1 + (NVL(vr_txmescet,0) / 100),12) - 1) * 100,2);
            
      -- Inicializar o CLOB
      dbms_lob.createtemporary(vr_des_xml, TRUE, dbms_lob.CALL);
      dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
                  
      -------------------------------------------
      -- Iniciando a geração do XML
      -------------------------------------------
      --> Verificar se é apenas para gerar o XML
      IF pr_flretxml <> 1 THEN
        pc_escreve_xml('<?xml version="1.0" encoding="utf-8"?>');
      END IF;
      
      pc_escreve_xml('<cet>');
      
      -- informacoes para impressao
      pc_escreve_xml('<cdcooper>' || pr_cdcooper || '</cdcooper>' ||
                     '<nrdconta>' || gene0002.fn_mask_conta(pr_nrdconta) || '</nrdconta>' ||
                     '<nmoperac>' || vr_nmoperac || '</nmoperac>' ||
                     '<nrctrlim>' || to_char(pr_nrctrlim,'fm9999G990') || '</nrctrlim>' ||
                     '<dtinivig>' || to_char(pr_dtinivig,'dd/mm/rrrr') || '</dtinivig>' ||
                     '<dtvencto>' || to_char(vr_dtvencto,'dd/mm/rrrr') || '</dtvencto>' || 
                     '<txmensal>' || to_char(nvl(vr_txmensal,0),'fm990D00') || '</txmensal>' ||
                     '<txdjuros>' || to_char(nvl(vr_txdjuros,0),'fm990D00') || '</txdjuros>' ||
                     '<vllimite>' || to_char(nvl(pr_vlemprst,0),'fm999G999G990D00') || '</vllimite>' ||
                     '<vlrdoiof>' || to_char(nvl(vr_vlrdoiof,0),'fm999G990D00') || '</vlrdoiof>' ||
                  --   '<txjuriof>' || to_char(nvl(vr_txjuriof,0),'fm990D00') || '</txjuriof>' ||
                     '<vlrtarif>' || to_char(nvl(vr_vlrtarif,0),'fm999G990D00') || '</vlrtarif>' ||
                     '<txjurtar>' || to_char(nvl(vr_txjurtar,0),'fm990D00') || '</txjurtar>' ||
                     '<vlrdsegu>' || to_char(nvl(vr_vlrdsegu,0),'fm999G990D00') || '</vlrdsegu>' ||
                     '<txjurseg>' || to_char(nvl(vr_txjurseg,0),'fm990D00') || '</txjurseg>' ||
                     '<vlemprst>' || to_char(nvl(vr_vlemprst,0),'fm999G999G990D00') || '</vlemprst>' ||
                     '<txjuremp>' || to_char(nvl(vr_txjuremp,0),'fm990D00') || '</txjuremp>' ||
                     '<txanocet>' || to_char(nvl(vr_txanocet,0),'fm990D00') || '</txanocet>' ||
                     '<txmescet>' || to_char(nvl(vr_txmescet,0),'fm990D00') || '</txmescet>' ||
                     '<txjurlim>' || to_char(nvl(vr_txjurlim,0),'fm990D00') || '</txjurlim>' ||
                     '<vljurrem>' || to_char(nvl(vr_vljurrem,0),'fm999G990D00') || '</vljurrem>' ||
                     '<txjurrem>' || to_char(nvl(vr_txjurrem,0),'fm990D00') || '</txjurrem>' ||
                     '<dtmvtolt>' || to_char(pr_dtmvtolt,'dd/mm/rrrr') || '</dtmvtolt>' ||
                     '<dsdprazo>' || to_char(trim(vr_dsdprazo)) || '</dsdprazo>' ||
                     '<dscooper>' || vr_dscooper || '</dscooper>');
      -- Finalizar o arquivo xml                     
      pc_escreve_xml('</cet>');                         

      --> Verificar se é apenas para gerar o XML
      IF pr_flretxml = 0 THEN
      -- buscar time da operacao
      vr_nmarqimp := gene0002.fn_busca_time;
      pr_nmarqimp := vr_nmarqimp;
           
      -- Busca do diretório base da cooperativa e a subpasta de relatórios
      vr_path_arquivo := gene0001.fn_diretorio( pr_tpdireto => 'C' -- /usr/coop
                                               ,pr_cdcooper => pr_cdcooper
                                               ,pr_nmsubdir => '/rl'); --> Gerado no diretorio /rl        
                                             
      -- Gerando o relatório nas pastas /rl                                              
      gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper
                                 ,pr_cdprogra  => 'atenda'
                                 ,pr_dtmvtolt  => pr_dtmvtolt
                                 ,pr_dsxml     => vr_des_xml
                                 ,pr_dsxmlnode => '/cet'
                                 ,pr_dsjasper  => 'cet_limites.jasper'
                                 ,pr_dsparams  => NULL
                                 ,pr_dsarqsaid => vr_path_arquivo || '/' || vr_nmarqimp || '.ex'
                                 ,pr_flg_gerar => 'S'
                                 ,pr_cdrelato  => '663'
                                 ,pr_qtcoluna  => 80
                                 ,pr_sqcabrel  => 1
                                 ,pr_flg_impri => 'N'
                                 ,pr_nmformul  => '80col'
                                 ,pr_nrcopias  => 1
                                   ,pr_nrvergrl  => 1
                                 ,pr_des_erro  => vr_dscritic);

      -- VERIFICA SE OCORREU UMA CRITICA
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;        
        END IF;
      ELSE
        pr_des_xml := vr_des_xml;
      END IF;
      
      -- Liberando a memória alocada pro CLOB
      dbms_lob.close(vr_des_xml);
      dbms_lob.freetemporary(vr_des_xml);      
    
    EXCEPTION
      WHEN vr_exc_erro THEN        
        -- Monta mensagem de erro
        pr_cdcritic := NVL(vr_cdcritic,0);
        pr_dscritic := vr_dscritic;
      WHEN OTHERS THEN
        pr_cdcritic := 0;
        pr_dscritic := 'Erro pc_imprime_limites_cet : ' || SQLERRM;
    END;        
  END pc_imprime_limites_cet;
  
  -- Imprimir contrato de emprestimos do CET
  PROCEDURE pc_imprime_emprestimos_cet(pr_cdcooper  IN crapcop.cdcooper%TYPE -- Cooperativa
                                      ,pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE -- Data Movimento
                                      ,pr_cdprogra  IN VARCHAR2              -- Programa chamador
                                      ,pr_nrdconta  IN crapass.nrdconta%TYPE -- Conta/dv
                                      ,pr_inpessoa  IN crapass.inpessoa%TYPE -- Indicativo de pessoa
                                      ,pr_cdusolcr  IN craplcr.cdusolcr%TYPE -- Codigo de uso da linha de credito
                                      ,pr_cdlcremp  IN craplcr.cdlcremp%TYPE -- Linha de credio
                                      ,pr_tpemprst  IN crapepr.tpemprst%TYPE -- Tipo da operacao
                                      ,pr_nrctremp  IN crapepr.nrctremp%TYPE -- Contrato
                                      ,pr_dtlibera  IN crawepr.dtlibera%TYPE -- Data liberacao
                                      ,pr_dtultpag  IN crapepr.dtultpag%TYPE -- Data ultimo pagamento                                   
                                      ,pr_vlemprst  IN crapepr.vlemprst%TYPE -- Valor emprestado
                                      ,pr_txmensal  IN crapepr.txmensal%TYPE -- Taxa mensal 
                                      ,pr_vlpreemp  IN crapepr.vlpreemp%TYPE -- Valor Parcela
                                      ,pr_qtpreemp  IN crapepr.qtpreemp%TYPE -- Parcelas
                                      ,pr_dtdpagto  IN crapepr.dtdpagto%TYPE -- Data Pagamento
                                      ,pr_nmarqimp OUT VARCHAR2              -- Nome do arquivo
                                      ,pr_des_xml  OUT CLOB                  -- XML
                                      ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                      ,pr_dscritic OUT VARCHAR2) IS          --> Descrição da crítica                                 
                          
  BEGIN
  /* .............................................................................

  Programa: pc_imprime_emprestimos_cet                 
  Sistema : Conta-Corrente - Cooperativa de Credito
  Sigla   : CRED
  Autor   : Lucas Ranghetti
  Data    : Julho/2014                        Ultima atualizacao: 23/12/2016

  Dados referentes ao programa:

  Frequencia: Diaria - Sempre que for chamada
  Objetivo  : Rotina para gerar planilha de demonstracao do CET, emprestimos

  Alteracoes: 04/11/2014 - Alterado format dos valores para suportar milhoes (Lucas R.)
  
              05/05/2015 - Alterado o campo flg_impri da procedure pc_solicita_relato de 'S' para 'N'
                           para não gerar o arquivo pdf no diretório audit_pdf (Lucas Ranghetti #281494)
              
              12/11/2015 - Criada validacao do tipo de contrato de emprestimo para Portabilidade, neste caso
                           nao calculando taxa de IOF (Carlos Rafael Tanholi - Projeto Portabilidade).             
                  
              13/09/2016 - Alterado para gerar o relatorio com a nova versão do Gera relatorio.
                           PRJ314 - Indexação Centralizada (Odirlei-AMcom)         

              07/11/2016 - Alterado cursor cr_craplat_bem para buscar somatória das tarifas.
                           Buscava apenas o primeiro e quanto o empréstimo possui mais de 1 bem
                           alienado não fechava o valor da tarifa cobrada na conta e impressa no CET.
                           (SD#551769 - AJFink)

              23/12/2016 - Ajuste para aumentar o tamanho do campo que recebe o nome da cooperativa
                           pois estava estourando o format
                           (Adriano - SD 582204).
  ............................................................................. */
    DECLARE
    
      vr_vlrprest NUMBER := 0;                -- Valor da prestacao
      vr_vlrdocet NUMBER := 0;                -- Valor do CET
      -- Variaveis de erro
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic crapcri.dscritic%TYPE; 
      
      -- VARIAVEIS A ENVIAR PARA O XML
      vr_nmoperac VARCHAR2(20);               -- Operacao
      vr_dtvencto DATE;                       -- Data vencto Contrato.
      vr_txmensal craplrt.txmensal%TYPE := 0; -- Taxa mensal
      vr_txdjuros NUMBER := 0;                -- Taxa anual
      vr_vlrdoiof NUMBER := 0;                -- IOF calculado
      vr_txjuriof NUMBER := 0;                -- Taxa do IOF
      vr_vlrtarif NUMBER := 0;                -- Valor Tar. Cadastro
      vr_txjurtar NUMBER := 0;                -- Taxa Tar. Cadastro
      vr_vlrdsegu NUMBER := 0;                -- Valor Seg. prestamista
      vr_txjurseg NUMBER := 0;                -- Taxa Seg. prestamista
      vr_vlemprst NUMBER := 0;                -- Valor total emprestado, calculado
      vr_txjuremp NUMBER := 0;                -- Taxa do valor emprestado
      vr_txanocet NUMBER := 0;                -- taxa anual do cet
      vr_txmescet NUMBER := 0;                -- taxa mensal do cet
      vr_txjurlim NUMBER := 0;                -- Taxa juros limite
      vr_cdbattar VARCHAR2(15);               -- CODIGO DA TARIFA
      vr_dsdprazo VARCHAR2(20);               -- Parazo Contrato
      vr_vltotdiv NUMBER := 0;                -- Valor total da divida
      vr_tpctrato NUMBER := 0;                -- Tipo de contrato
      vr_cdhisbem NUMBER := 0;                -- Hostorico do bem
      vr_vltarbem NUMBER := 0;                -- Valor tarifa bem
      vr_cdhistor NUMBER := 0;                -- Historico
      vr_cdusolcr NUMBER := 0;                -- Uso linha de credito
      vr_qtdiavig INTEGER;
      
      vr_dscooper VARCHAR2(70);               -- Descrição da cooperativa
      
      -- Variavel exceção
      vr_exc_erro EXCEPTION;      
      
      vr_ind      VARCHAR2(100);
      
      -- Variável de Controle de XML
      vr_des_xml      CLOB;
      vr_path_arquivo VARCHAR2(1000);
      vr_dspathcop    VARCHAR2(4000);

      vr_tab_erro GENE0001.typ_tab_erro; --> Tabela com erros
      -- Variaveis pdf
      vr_nmarqpdf VARCHAR2(100) := '';
      vr_nmauxpdf VARCHAR2(100) := '';
      vr_nmarqimp VARCHAR2(100) := '';
            
      vr_des_reto CHAR;
      vr_err_efet PLS_INTEGER;
      
      -- CURSORES
      CURSOR cr_crapcop IS 
      SELECT cop.nmextcop,
             cop.nmrescop
        FROM crapcop cop
       WHERE cop.cdcooper = pr_cdcooper;
       rw_crapcop cr_crapcop%ROWTYPE;
                   
      CURSOR cr_craplcr IS
      SELECT lcr.txmensal, 
             lcr.tpctrato,
             lcr.cdusolcr
        FROM craplcr lcr
       WHERE lcr.cdcooper = pr_cdcooper
         AND lcr.cdlcremp = pr_cdlcremp;
      rw_craplcr cr_craplcr%ROWTYPE;
    
    -- CURSORES PARA UTILIZAR NA PACKAGE
    CURSOR cr_craplat(pr_cdcooper IN crapcop.cdcooper%TYPE
                     ,pr_nrdconta IN crapass.nrdconta%TYPE
                     ,pr_nrctremp IN crapepr.nrctremp%TYPE
                     ,pr_cdhistor IN craplat.cdhistor%TYPE) IS
      SELECT lat.vltarifa
        FROM craplat lat
        WHERE lat.cdcooper = pr_cdcooper
          AND lat.nrdconta = pr_nrdconta
          AND lat.nrdocmto = pr_nrctremp
          AND lat.cdhistor = pr_cdhistor;
      rw_craplat cr_craplat%ROWTYPE; 
      
      -- CURSORES PARA UTILIZAR NA PACKAGE
    CURSOR cr_craplat_bem(pr_cdcooper IN crapcop.cdcooper%TYPE
                         ,pr_nrdconta IN crapass.nrdconta%TYPE
                         ,pr_nrctremp IN crapepr.nrctremp%TYPE
                         ,pr_cdhistor IN craplat.cdhistor%TYPE) IS
      SELECT nvl(sum(lat.vltarifa),0) vltarifa --SD#551769
        FROM craplat lat
        WHERE lat.cdcooper = pr_cdcooper
          AND lat.nrdconta = pr_nrdconta
          AND lat.nrdocmto = pr_nrctremp
          AND lat.cdhistor = pr_cdhistor;
      rw_craplat_bem cr_craplat_bem%ROWTYPE; 
      --Procedure que escreve linha no arquivo CLOB
      PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR2) IS
      BEGIN

        --Escrever no arquivo CLOB
        dbms_lob.writeappend(vr_des_xml,length(pr_des_dados),pr_des_dados);
      END;
    
    BEGIN

      -- Buscar descrição da cooperativa
      OPEN cr_crapcop;
      FETCH cr_crapcop INTO rw_crapcop;
      
      -- Se achou cooperativa 
      IF cr_crapcop%FOUND THEN
        CLOSE cr_crapcop;
        -- Grava nome completo mais o resumido
        vr_dscooper := TRIM(rw_crapcop.nmextcop) || ' - ' || TRIM(rw_crapcop.nmrescop);    
      END IF;

      -- NOME DA OPERACAO
      IF pr_tpemprst = 0 THEN
        vr_nmoperac := 'PRICE TR';
      ELSIF pr_tpemprst = 1 THEN
        vr_nmoperac := 'PRICE PRE-FIXADO';      
      END IF;
   
      -- Data do vencimento do emprestimo        
      vr_dtvencto := add_months(pr_dtdpagto,(pr_qtpreemp - 1));

      -- Buscar a taxa de juros
      OPEN cr_craplcr;
        FETCH cr_craplcr INTO rw_craplcr;
        
        -- se achou registro
        IF cr_craplcr%FOUND THEN
          CLOSE cr_craplcr;
          -- Taxa de juros remunerados mensal
          vr_txmensal := ROUND((POWER(1 + (nvl(rw_craplcr.txmensal,0) / 100),1) - 1) * 100,2);
          -- Taxa anual
          vr_txdjuros := ROUND((POWER(1 + (nvl(rw_craplcr.txmensal,0) / 100),12) - 1) * 100,2);
          -- Tipo de contrato
          vr_tpctrato := rw_craplcr.tpctrato; 
          vr_cdusolcr := rw_craplcr.cdusolcr;
          
        END IF;       
                                                                                             
      -- Prazo do contrato        
      IF pr_qtpreemp > 1 THEN                             
        vr_dsdprazo := TO_CHAR(pr_qtpreemp) || ' MESES';
      ELSE
        vr_dsdprazo := TO_CHAR(pr_qtpreemp) || ' MES';
      END IF; 
      
      -- verifica se o contrato eh de Portabilidade
      EMPR0006.pc_possui_portabilidade(pr_cdcooper => pr_cdcooper, 
                                       pr_nrdconta => pr_nrdconta, 
                                       pr_nrctremp => pr_nrctremp, 
                                       pr_err_efet => vr_err_efet, 
                                       pr_des_reto => vr_des_reto, 
                                       pr_cdcritic => vr_cdcritic, 
                                       pr_dscritic => vr_dscritic);

      -- VERIFICA SE OCORREU UMA CRITICA
      IF vr_dscritic IS NOT NULL THEN
         RAISE vr_exc_erro;        
      END IF;                

      -- calcula IOF apenas para emprestimos que nao sao de portabilidade
      IF vr_des_reto = 'N' THEN      
        -- Quantidade de dias de vigencia
        vr_qtdiavig := add_months(pr_dtdpagto,pr_qtpreemp - 1) - pr_dtmvtolt;      
        -- Buscar iof
        EMPR0001.pc_calcula_iof_epr(pr_cdcooper => pr_cdcooper
                                   ,pr_nrdconta => pr_nrdconta
                                   ,pr_dtmvtolt => pr_dtmvtolt
                                   ,pr_inpessoa => pr_inpessoa
                                   ,pr_cdlcremp => pr_cdlcremp
                                   ,pr_qtpreemp => pr_qtpreemp
                                   ,pr_vlpreemp => pr_vlpreemp
                                   ,pr_vlemprst => pr_vlemprst
                                   ,pr_dtdpagto => pr_dtdpagto
                                   ,pr_dtlibera => pr_dtlibera
                                   ,pr_tpemprst => pr_tpemprst
                                   ,pr_valoriof => vr_vlrdoiof
                                   ,pr_dscritic => vr_dscritic);
                                   
        -- VERIFICA SE OCORREU UMA CRITICA
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
      
      END IF;

      /* 2 - Avaliacao de garantia de bem movel  */
      /* 3 - Avaliacao de garantia de bem imovel */
      IF ( vr_tpctrato = 2 ) OR ( vr_tpctrato = 3 ) THEN       
        IF vr_tpctrato = 2 THEN /* Bens Moveis */
          /* Verifica qual tarifa deve ser cobrada com base tipo pessoa */
          IF pr_inpessoa = 1 THEN /* Fisica */             
            vr_cdhisbem := 1443;
          ELSE              
            vr_cdhisbem := 1467;
          END IF;
        ELSE /* Bens Imoveis */
          IF pr_inpessoa = 1 THEN /* Fisica */            
            vr_cdhisbem := 1445;              
          ELSE
            vr_cdhisbem := 1469;
          END IF;          
        END IF;       
        
        -- abre cursor da tabela
        OPEN cr_craplat_bem(pr_cdcooper => pr_cdcooper,
                            pr_nrdconta => pr_nrdconta,
                            pr_nrctremp => pr_nrctremp,
                            pr_cdhistor => vr_cdhisbem);
        FETCH cr_craplat_bem INTO rw_craplat_bem;
            
        -- se achou registro
        IF cr_craplat_bem%FOUND THEN
          CLOSE cr_craplat_bem;
          -- se encontrou lancamento da tarifa
          vr_vltarbem := ROUND(nvl(rw_craplat_bem.vltarifa,0),2);
        ELSE
          CLOSE cr_craplat_bem;
        END IF;        
      END IF;
      
      IF pr_inpessoa = 1 THEN /* Fisica */
        vr_cdhistor := 1481;
      ELSE /* Juridica */
        vr_cdhistor := 1479;        
      END IF;
        
      -- abre cursor da tabela
      OPEN cr_craplat(pr_cdcooper => pr_cdcooper,
                      pr_nrdconta => pr_nrdconta,
                      pr_nrctremp => pr_nrctremp,
                      pr_cdhistor => vr_cdhistor);
      FETCH cr_craplat INTO rw_craplat;
        
      -- se achou registro
      IF cr_craplat%FOUND THEN
        CLOSE cr_craplat;
        -- se encontrou lancamento da tarifa
        vr_vlrtarif := ROUND(nvl(rw_craplat.vltarifa,0),2) + nvl(vr_vltarbem,0);
      ELSE -- se nao encontrou lançamento de tarifa busca a tarifa vigente
        -- Fechar cursor
        CLOSE cr_craplat;   
        
        IF vr_cdusolcr = 1 THEN
          IF pr_inpessoa = 1 THEN /* Fisica */
            vr_cdbattar := 'MICROCREPF';
          ELSE
            vr_cdbattar := 'MICROCREPJ';
          END IF;             
        END IF;
        
        -- buscar tarifa de cadastro linha de credito
        CCET0001.pc_calcula_tarifa_cadastro(pr_cdcooper => pr_cdcooper
                                           ,pr_dtmvtolt => pr_dtmvtolt
                                           ,pr_vlemprst => pr_vlemprst
                                           ,pr_cdbattar => vr_cdbattar
                                           ,pr_cdprogra => pr_cdprogra
                                           ,pr_cdusolcr => vr_cdusolcr 
                                           ,pr_inpessoa => pr_inpessoa
                                           ,pr_cdlcremp => pr_cdlcremp
                                           ,pr_tpctrato => vr_tpctrato
                                           ,pr_nrdconta => pr_nrdconta
                                           ,pr_nrctremp => pr_nrctremp
                                           ,pr_vltottar => vr_vlrtarif
                                           ,pr_cdcritic => vr_cdcritic
                                           ,pr_dscritic => vr_dscritic);

         -- VERIFICA SE OCORREU UMA CRITICA
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;        
        END IF;                  
      END IF;     
                                                         
      -- valor total emprestado
      vr_vlemprst := nvl(pr_vlemprst,0) - nvl(vr_vlrdoiof,0) - nvl(vr_vlrtarif,0);      
                                                    
      -- Porcentagem do valor do limite
      vr_txjurlim := ((nvl(pr_vlemprst,0) - nvl(vr_vlrdoiof,0) - nvl(vr_vlrtarif,0)) * 100) / pr_vlemprst;
            
      -- Taxa de juros do iof
      vr_txjuriof := (vr_vlrdoiof * 100) / pr_vlemprst;
      
      -- Taxa de juros da tarifa
      vr_txjurtar := (vr_vlrtarif * 100) / pr_vlemprst;

      -- Valor total da divida
      vr_vltotdiv := round(nvl(pr_qtpreemp,0) * nvl(pr_vlpreemp,0),2);
      
      -- Porcentagem  do valor total
      vr_txjuremp := 100;
      
      -- Busca juros do cet
      CCET0001.pc_juros_cet(pr_nro_parcelas   => pr_qtpreemp
                           ,pr_vlr_prestacao  => pr_vlpreemp
                           ,pr_vlr_financiado => vr_vlemprst
                           ,pr_data_contrato  => pr_dtlibera
                           ,pr_primeiro_vcto  => pr_dtdpagto
                           ,pr_valorcet       => vr_vlrdocet
                           ,pr_tx_cet_ano     => vr_txanocet
                           ,pr_tx_cet_mes     => vr_txmescet
                           ,pr_cdcritic       => vr_cdcritic
                           ,pr_dscritic       => vr_dscritic);
       -- VERIFICA SE OCORREU UMA CRITICA
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;        
      END IF;       
      
      -- Inicializar o CLOB
      dbms_lob.createtemporary(vr_des_xml, TRUE, dbms_lob.CALL);
      dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
                  
      -------------------------------------------
      -- Iniciando a geração do XML
      -------------------------------------------
      IF pr_cdprogra = 'EMPR0003' THEN
        pc_escreve_xml('<cet>');
      ELSE
        pc_escreve_xml('<?xml version="1.0" encoding="utf-8"?><cet>');
      END IF;
                
      -- informacoes para impressao
      pc_escreve_xml('<cdcooper>' || pr_cdcooper || '</cdcooper>' ||
                     '<nrdconta>' || gene0002.fn_mask_conta(pr_nrdconta) || '</nrdconta>' ||
                     '<nmoperac>' || vr_nmoperac || '</nmoperac>' ||
                     '<nrctremp>' || to_char(pr_nrctremp,'fm99G999G990') || '</nrctremp>' ||
                     '<dtlibera>' || to_char(pr_dtlibera,'dd/mm/rrrr') || '</dtlibera>' ||
                     '<dtvencto>' || to_char(vr_dtvencto,'dd/mm/rrrr') || '</dtvencto>' || 
                     '<txmensal>' || to_char(nvl(vr_txmensal,0),'fm990D00') || '</txmensal>' ||
                     '<txdjuros>' || to_char(nvl(vr_txdjuros,0),'fm990D00') || '</txdjuros>' ||
                     '<vlliquid>' || to_char(nvl(vr_vlemprst,0),'999G999G990D00') || '</vlliquid>' ||
                     '<vlrdoiof>' || to_char(nvl(vr_vlrdoiof,0),'999G999G990D00') || '</vlrdoiof>' ||
                     '<txjuriof>' || to_char(nvl(vr_txjuriof,0),'990D00') || '</txjuriof>' ||
                     '<vlrtarif>' || to_char(nvl(vr_vlrtarif,0),'999G999G990D00') || '</vlrtarif>' ||
                     '<txjurtar>' || to_char(nvl(vr_txjurtar,0),'990D00') || '</txjurtar>' ||
                     '<vlrdsegu>' || to_char(nvl(vr_vlrdsegu,0),'999G999G990D00') || '</vlrdsegu>' ||
                     '<txjurseg>' || to_char(nvl(vr_txjurseg,0),'990D00') || '</txjurseg>' ||
                     '<vlemprst>' || to_char(nvl(pr_vlemprst,0),'999G999G990D00') || '</vlemprst>' ||
                     '<txjuremp>' || to_char(nvl(vr_txjuremp,0),'990D00') || '</txjuremp>' ||
                     '<txanocet>' || to_char(nvl(vr_txanocet,0),'fm990D00') || '</txanocet>' ||
                     '<txmescet>' || to_char(nvl(vr_txmescet,0),'fm990D00') || '</txmescet>' ||
                     '<txjurlim>' || to_char(nvl(vr_txjurlim,0),'990D00') || '</txjurlim>' ||
                     '<dtmvtolt>' || to_char(pr_dtmvtolt,'dd/mm/rrrr') || '</dtmvtolt>'||
                     '<dsdprazo>' || to_char(trim(vr_dsdprazo)) || '</dsdprazo>' ||
                     '<vlparemp>' || to_char(nvl(pr_vlpreemp,0),'fm999G990D00') || '</vlparemp>' ||
                     '<vltotemp>' || to_char(nvl(vr_vltotdiv,0),'fm999G999G990D00') || '</vltotemp>' ||
                     '<dtpripag>' || to_char(pr_dtdpagto,'dd/mm/rrrr') || '</dtpripag>' ||
                     '<dscooper>' || vr_dscooper || '</dscooper>');
      -- Finalizar o arquivo xml                     
      pc_escreve_xml('</cet>');                     

      -- Se  não for EMPR0001 gera o relatorio normal
      IF pr_cdprogra <> 'EMPR0003' THEN       
        -- buscar time da operacao
        vr_nmarqimp := gene0002.fn_busca_time;
        pr_nmarqimp := vr_nmarqimp;
             
        -- Busca do diretório base da cooperativa e a subpasta de relatórios
        vr_path_arquivo := gene0001.fn_diretorio( pr_tpdireto => 'C' -- /usr/coop
                                                 ,pr_cdcooper => pr_cdcooper
                                                 ,pr_nmsubdir => '/rl'); --> Gerado no diretorio /rl
                         
        -- Gerando o relatório nas pastas /rl                                              
        gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper
                                   ,pr_cdprogra  => 'atenda'
                                   ,pr_dtmvtolt  => pr_dtmvtolt
                                   ,pr_dsxml     => vr_des_xml
                                   ,pr_dsxmlnode => '/cet'
                                   ,pr_dsjasper  => 'cet_emprestimos.jasper'
                                   ,pr_dsparams  => NULL
                                   ,pr_dsarqsaid => vr_path_arquivo || '/' || vr_nmarqimp || '.ex'
                                   ,pr_flg_gerar => 'S'
                                   ,pr_cdrelato  => '663'
                                   ,pr_qtcoluna  => 80
                                   ,pr_sqcabrel  => 1
                                   ,pr_flg_impri => 'N'
                                   ,pr_nmformul  => '80col'
                                   ,pr_nrcopias  => 1
                                   ,pr_nrvergrl  => 1
                                   ,pr_des_erro  => vr_dscritic);                                

        -- VERIFICA SE OCORREU UMA CRITICA
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;        
        END IF;
      END IF;      
      
      -- Liberando a memória alocada pro CLOB
      dbms_lob.close(vr_des_xml);
      
      -- XML do cet
      pr_des_xml := vr_des_xml;
      
      dbms_lob.freetemporary(vr_des_xml);      
          
    EXCEPTION
      WHEN vr_exc_erro THEN        
        -- Monta mensagem de erro
        pr_cdcritic := NVL(vr_cdcritic,0);
        pr_dscritic := vr_dscritic;
      WHEN OTHERS THEN
        pr_cdcritic := 0;
        pr_dscritic := 'Erro pc_imprime_emprestimos_cet : ' || SQLERRM;
    END;        
  END pc_imprime_emprestimos_cet; 
  
  PROCEDURE pc_calculo_cet_limites(pr_cdcooper  IN crapcop.cdcooper%TYPE -- Cooperativa
                                  ,pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE -- Data Movimento
                                  ,pr_cdprogra  IN VARCHAR2              -- Programa chamador
                                  ,pr_nrdconta  IN craplim.nrdconta%TYPE -- Conta/dv
                                  ,pr_inpessoa  IN crapass.inpessoa%TYPE -- Indicativo de pessoa
                                  ,pr_cdusolcr  IN craplcr.cdusolcr%TYPE -- Codigo de uso da linha de credito
                                  ,pr_cdlcremp  IN craplim.cddlinha%TYPE -- Linha de credio
                                  ,pr_tpctrlim  IN craplim.tpctrlim%TYPE -- Tipo da operacao
                                  ,pr_nrctrlim  IN craplim.nrctrlim%TYPE -- Contrato
                                  ,pr_dtinivig  IN craplim.dtinivig%TYPE -- Data liberacao
                                  ,pr_qtdiavig  IN craplrt.qtdiavig%TYPE -- Dias de vigencia                                      
                                  ,pr_vlemprst  IN crapepr.vlemprst%TYPE -- Valor emprestado
                                  ,pr_txmensal  IN craplrt.txmensal%TYPE -- Taxa mensal                                                               
                                  ,pr_txcetano OUT NUMBER                -- Taxa cet ano
                                  ,pr_txcetmes OUT NUMBER                -- Taxa cet mes 
                                  ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                  ,pr_dscritic OUT VARCHAR2) IS          --> Descrição da crítica
  BEGIN
  /* .............................................................................

  Programa: pc_calculo_cet_limites                 
  Sistema : Conta-Corrente - Cooperativa de Credito
  Sigla   : CRED
  Autor   : Lucas R.
  Data    : Setembro/2014                        Ultima atualizacao: 00/00/0000

  Dados referentes ao programa:

  Frequencia: Diaria - Sempre que for chamada
  Objetivo  : Rotina para calcular o Custo Efetivo Total(CET) dos limites de credito, 
              descontos de cheque e titulo.

  Alteracoes:                  
  ............................................................................. */
    DECLARE
    
      vr_vlrdoiof NUMBER := 0;                -- IOF calculado
      vr_txjuriof NUMBER := 0;                -- Taxa do IOF
      vr_vlrtarif NUMBER := 0;                -- Valor Tar. Cadastro
      vr_txjurtar NUMBER := 0;                -- Taxa Tar. Cadastro         
      vr_txanocet NUMBER := 0;                -- taxa anual do cet
      vr_txmescet NUMBER := 0;                -- taxa mensal do cet
      vr_cdbattar VARCHAR2(15);               -- CODIGO DA TARIFA
      vr_txadoiof NUMBER := 0;                -- Taxa do iof
      vr_vljurrem NUMBER := 0;                -- Valor de juros remunerados
      vr_txjurrem NUMBER := 0;                -- Taxa de juros remunerados                                                                                 
      vr_cdhistor NUMBER := 0;                -- Historico
      vr_qtdparce NUMBER := 0;                -- Quantidade de parcelas
      vr_vltaxa_iof_principal NUMBER(25,8);
      
      vr_vliofpri NUMBER;
      vr_vliofadi NUMBER;
      vr_vliofcpl NUMBER;
      vr_flgimune BOOLEAN;
      vr_tpproduto NUMBER;
      vr_natjurid NUMBER := 0;
      vr_tpregtrb NUMBER := 0;
      -- Variaveis de erro
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic crapcri.dscritic%TYPE; 
      
      -- Variavel exceção
      vr_exc_erro EXCEPTION;      
      
      vr_ind      VARCHAR2(100);
      
      vr_tab_erro GENE0001.typ_tab_erro; --> Tabela com erros
  
      -- CURSORES PARA UTILIZAR NA PACKAGE
      CURSOR cr_craplat(pr_cdcooper IN crapcop.cdcooper%TYPE
                       ,pr_nrdconta IN crapass.nrdconta%TYPE
                       ,pr_dtinivig IN crapdat.dtmvtolt%TYPE
                       ,pr_cdhistor IN craphis.cdhistor%TYPE) IS
        SELECT lat.vltarifa
          FROM craplat lat
          WHERE lat.cdcooper = pr_cdcooper
            AND lat.nrdconta = pr_nrdconta
            AND lat.dtmvtolt = pr_dtinivig
            AND lat.cdhistor = pr_cdhistor;
        rw_craplat cr_craplat%ROWTYPE; 
  
     CURSOR cr_crapjur(pr_cdcooper IN crapjur.cdcooper%TYPE
                          ,pr_nrdconta IN crapjur.nrdconta%TYPE) IS
       SELECT crapjur.natjurid, crapjur.tpregtrb
       FROM crapjur 
       WHERE crapjur.natjurid = pr_cdcooper AND crapjur.nrdconta = pr_nrdconta;
      rw_crapjur cr_crapjur%ROWTYPE;
    BEGIN
    
      
      -- gravar codigo da tarifa e historico de lançamento
      IF pr_inpessoa = 1 THEN -- Fisica
        IF pr_tpctrlim = 1 THEN /* limcre */
          vr_cdbattar := 'COLIMCHQPF';
          vr_cdhistor := 1481;
          vr_tpproduto := 4;
        ELSIF pr_tpctrlim = 3 THEN /* desctit */
          vr_cdbattar := 'DSTCONTRPF';
          vr_cdhistor := 1429;
          vr_tpproduto := 2;
        ELSIF pr_tpctrlim = 2 THEN /* DESCCHQ */
          vr_cdbattar := 'DSCCHQCTPF';
          vr_cdhistor := 1423;
          vr_tpproduto := 3;
        END IF;
      ELSE -- Juridica
        IF pr_tpctrlim = 1 THEN /* limcre */
          vr_cdbattar := 'COLIMCHQPJ';
          vr_cdhistor := 1479;
          vr_tpproduto := 4;
        ELSIF pr_tpctrlim = 3 THEN /* desctit */
          vr_cdbattar := 'DSTCONTRPJ'; 
          vr_cdhistor := 1453;
          vr_tpproduto := 2;
        ELSIF pr_tpctrlim = 2 THEN /* DESCCHQ */
          vr_cdbattar := 'DSCCHQCTPJ';
          vr_cdhistor := 1447;
          vr_tpproduto := 3;
        END IF;           
      END IF;
      OPEN cr_crapjur(pr_cdcooper => pr_cdcooper
                     ,pr_nrdconta => pr_nrdconta);
      FETCH cr_crapjur INTO rw_crapjur;
      IF cr_crapjur%FOUND THEN
         vr_natjurid := rw_crapjur.natjurid;
         vr_tpregtrb := rw_crapjur.tpregtrb;
      END IF;
      CLOSE cr_crapjur;
      --Novo cálculo do IOF
      TIOF0001.pc_calcula_valor_iof(pr_tpproduto  => vr_tpproduto --> Tipo do Produto (1-> Emprestimo, 2-> Desconto Titulo, 3-> Desconto Cheque, 4-> Limite de Credito, 5-> Adiantamento Depositante)
                                   ,pr_tpoperacao => 1 --> Tipo da Operacao (1-> Calculo IOF/Atraso, 2-> Calculo Pagamento em Atraso)
                                   ,pr_cdcooper   => pr_cdcooper --> Código da cooperativa
                                   ,pr_nrdconta   => pr_nrdconta --> Número da conta
                                   ,pr_inpessoa   => pr_inpessoa --> Tipo de Pessoa
                                   ,pr_natjurid   => vr_natjurid --> Natureza Juridica
                                   ,pr_tpregtrb   => vr_tpregtrb --> Tipo de Regime Tributario
                                   ,pr_dtmvtolt   => pr_dtmvtolt --> Data do movimento para busca na tabela de IOF
                                   ,pr_qtdiaiof   => pr_qtdiavig --> Qde dias em atraso (cálculo IOF atraso)
                                   ,pr_vloperacao => pr_vlemprst --> Valor total da operação (pode ser negativo também)
                                   ,pr_vltotalope => pr_vlemprst
                                   ,pr_vliofpri   => vr_vliofpri   --> Retorno do valor do IOF principal
                                   ,pr_vliofadi   => vr_vliofadi   --> Retorno do valor do IOF adicional
                                   ,pr_vliofcpl   => vr_vliofcpl   --> Retorno do valor do IOF complementar
                                   ,Pr_vltaxa_iof_principal => vr_vltaxa_iof_principal
                                   ,pr_dscritic   => vr_dscritic);                                   
      vr_vlrdoiof := NVL(vr_vliofpri,0) + NVL(vr_vliofadi,0);
      
      -- abre cursor da tabela
      OPEN cr_craplat(pr_cdcooper => pr_cdcooper,
                      pr_nrdconta => pr_nrdconta,
                      pr_dtinivig => pr_dtinivig,
                      pr_cdhistor => vr_cdhistor);
      FETCH cr_craplat INTO rw_craplat;
        
      -- se achou registro
      IF cr_craplat%FOUND THEN
        CLOSE cr_craplat;
        -- se encontrou lancamento da tarifa
        vr_vlrtarif := ROUND(nvl(rw_craplat.vltarifa,0),2);       
        
      ELSE -- se nao encontrou lançamento de tarifa busca a tarifa vigente
        -- Fechar cursor
        CLOSE cr_craplat; 
        
        -- buscar tarifa de cadastro linha de credito
        CCET0001.pc_calcula_tarifa_cadastro(pr_cdcooper => pr_cdcooper
                                           ,pr_dtmvtolt => pr_dtmvtolt
                                           ,pr_vlemprst => pr_vlemprst
                                           ,pr_cdbattar => vr_cdbattar
                                           ,pr_cdprogra => pr_cdprogra
                                           ,pr_cdusolcr => pr_cdusolcr 
                                           ,pr_inpessoa => pr_inpessoa
                                           ,pr_cdlcremp => pr_cdlcremp
                                           ,pr_tpctrato => 0
                                           ,pr_nrdconta => pr_nrdconta
                                           ,pr_nrctremp => pr_nrctrlim
                                           ,pr_vltottar => vr_vlrtarif
                                           ,pr_cdcritic => vr_cdcritic
                                           ,pr_dscritic => vr_dscritic);
                                                               
        -- VERIFICA SE OCORREU UMA CRITICA
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;        
        END IF;                                                                                      
      END IF;           
      -- Valor juros remunerados
      vr_vljurrem := (pr_vlemprst * nvl(pr_txmensal,0) ) / 100;     
                           
      -- Quantidade de parcelas
      IF pr_tpctrlim IN(1,2,3) THEN
        vr_qtdparce := 1;
      END IF;     
            
      -- Taxa de juros do iof
      vr_txjuriof := round((vr_vlrdoiof * 100) / pr_vlemprst,2);
            
      -- Taxa de juros da tarifa
      vr_txjurtar := round((vr_vlrtarif * 100) / pr_vlemprst,2);       
      
      -- Taxa do juros remunerados
      vr_txjurrem := round((vr_vljurrem * 100) / pr_vlemprst,2);      
      
      -- Taxa Mensal do cet
      vr_txmescet := nvl(pr_txmensal,0) + nvl(vr_txjuriof,0) + nvl(vr_txjurtar,0);
      vr_txmescet := ROUND((POWER(1 + (nvl(vr_txmescet,0) / 100),1) - 1) * 100,2);       
      -- Taxa Anual do cet
      vr_txanocet := ROUND((POWER(1 + (NVL(vr_txmescet,0) / 100),12) - 1) * 100,2);    

      pr_txcetmes := vr_txmescet;      
      pr_txcetano := vr_txanocet;
    
    EXCEPTION
      WHEN vr_exc_erro THEN        
        -- Monta mensagem de erro
        pr_cdcritic := NVL(vr_cdcritic,0);
        pr_dscritic := vr_dscritic;
      WHEN OTHERS THEN
        pr_cdcritic := 0;
        pr_dscritic := 'Erro pc_calculo_cet_limites : ' || SQLERRM;
    END;
  END pc_calculo_cet_limites;                   
  
  PROCEDURE pc_calculo_cet_emprestimos(pr_cdcooper  IN crapcop.cdcooper%TYPE -- Cooperativa
                                      ,pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE -- Data Movimento
                                      ,pr_nrdconta  IN crapass.nrdconta%TYPE -- Conta/dv
                                      ,pr_cdprogra  IN VARCHAR2              -- Programa chamador
                                      ,pr_inpessoa  IN crapass.inpessoa%TYPE -- Indicativo de pessoa
                                      ,pr_cdusolcr  IN craplcr.cdusolcr%TYPE -- Codigo de uso da linha de credito
                                      ,pr_cdlcremp  IN craplcr.cdlcremp%TYPE -- Linha de credio
                                      ,pr_tpemprst  IN crapepr.tpemprst%TYPE -- Tipo da operacao
                                      ,pr_nrctremp  IN crapepr.nrctremp%TYPE -- Contrato
                                      ,pr_dtlibera  IN crawepr.dtlibera%TYPE -- Data liberacao
                                      ,pr_vlemprst  IN crapepr.vlemprst%TYPE -- Valor emprestado
                                      ,pr_txmensal  IN crapepr.txmensal%TYPE -- Taxa mensal 
                                      ,pr_vlpreemp  IN crapepr.vlpreemp%TYPE -- Valor Parcela
                                      ,pr_qtpreemp  IN crapepr.qtpreemp%TYPE -- Parcelas
                                      ,pr_dtdpagto  IN crapepr.dtdpagto%TYPE -- Data Pagamento
                                      ,pr_cdfinemp  IN crapepr.cdfinemp%TYPE -- Finalidade de Emprestimo
                                      ,pr_txcetano OUT NUMBER                -- Taxa cet ano
                                      ,pr_txcetmes OUT NUMBER                -- Taxa cet mes 
                                      ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                      ,pr_dscritic OUT VARCHAR2) IS          --> Descrição da crítica
  BEGIN
  /* .............................................................................

  Programa: pc_calculo_cet_emprestimos                 
  Sistema : Conta-Corrente - Cooperativa de Credito
  Sigla   : CRED
  Autor   : Lucas R.
  Data    : Setembro/2014                        Ultima atualizacao: 07/11/2016

  Dados referentes ao programa:

  Frequencia: Diaria - Sempre que for chamada
  Objetivo  : Rotina para calcular o Custo Efetivo Total(CET) dos Emprestimos.

  Alteracoes: 07/11/2016 - Alterado cursor cr_craplat_bem para buscar somatória das tarifas.
                           Buscava apenas o primeiro e quanto o empréstimo possui mais de 1 bem
                           alienado não fechava o valor da tarifa cobrada na conta e impressa no CET.
                           (SD#551769 - AJFink)

  ............................................................................. */
    DECLARE
      vr_vlrdocet NUMBER;                -- Valor do CET
      -- Variaveis de erro
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic crapcri.dscritic%TYPE; 
      
      -- VARIAVEIS A ENVIAR PARA O XML
      vr_vlrdoiof NUMBER := 0;                -- IOF calculado
      vr_txjuriof NUMBER := 0;                -- Taxa do IOF
      vr_vlrtarif NUMBER := 0;                -- Valor Tar. Cadastro
      vr_txjurtar NUMBER := 0;                -- Taxa Tar. Cadastro         
      vr_txanocet NUMBER := 0;                -- taxa anual do cet
      vr_txmescet NUMBER := 0;                -- taxa mensal do cet
      vr_cdbattar VARCHAR2(15);               -- CODIGO DA TARIFA
      vr_txadoiof NUMBER := 0;                -- Taxa do iof
      vr_vlemprst NUMBER := 0;                -- Valor do emprestim
      vr_tpctrato NUMBER := 0;                -- Tipo de contrato
      vr_cdhisbem NUMBER := 0;                -- Hostorico do bem
      vr_vltarbem NUMBER := 0;                -- Valor tarifa bem
      vr_cdhistor NUMBER := 0;                -- Historico
      vr_qtdiavig NUMBER := 0;                -- Quantidade de Dias de Vigencia
      vr_data_contrato DATE;
      vr_cdusolcr NUMBER := 0;                -- Uso da Linha de Credito
      -- Variavel exceção
      vr_exc_erro EXCEPTION;          
      vr_ind      VARCHAR2(100);     
      vr_tab_erro GENE0001.typ_tab_erro; --> Tabela com erros
      -- Tipo da finalidade
      vr_tpfinali crapfin.tpfinali%TYPE := 0;
      
      --CURSORES
      CURSOR cr_craplcr IS
      SELECT lcr.txmensal, 
             lcr.tpctrato,
             lcr.cdusolcr
        FROM craplcr lcr
       WHERE lcr.cdcooper = pr_cdcooper
         AND lcr.cdlcremp = pr_cdlcremp;
      rw_craplcr cr_craplcr%ROWTYPE;
    
    -- CURSORES PARA UTILIZAR NA PACKAGE
    CURSOR cr_craplat(pr_cdcooper IN crapcop.cdcooper%TYPE
                     ,pr_nrdconta IN crapass.nrdconta%TYPE
                     ,pr_nrctremp IN crapepr.nrctremp%TYPE
                     ,pr_cdhistor IN craplat.cdhistor%TYPE) IS
      SELECT lat.vltarifa
        FROM craplat lat
        WHERE lat.cdcooper = pr_cdcooper
          AND lat.nrdconta = pr_nrdconta
          AND lat.nrdocmto = pr_nrctremp
          AND lat.cdhistor = pr_cdhistor
          AND lat.nrdocmto <> 0;
      rw_craplat cr_craplat%ROWTYPE; 
      
      -- CURSORES PARA UTILIZAR NA PACKAGE
    CURSOR cr_craplat_bem(pr_cdcooper IN crapcop.cdcooper%TYPE
                         ,pr_nrdconta IN crapass.nrdconta%TYPE
                         ,pr_nrctremp IN crapepr.nrctremp%TYPE
                         ,pr_cdhistor IN craplat.cdhistor%TYPE) IS
      SELECT nvl(sum(lat.vltarifa),0) vltarifa --SD#551769
        FROM craplat lat
        WHERE lat.cdcooper = pr_cdcooper
          AND lat.nrdconta = pr_nrdconta
          AND lat.nrdocmto = pr_nrctremp
          AND lat.cdhistor = pr_cdhistor
          AND nvl(lat.nrdocmto,0) <> 0;
      rw_craplat_bem cr_craplat_bem%ROWTYPE; 
         
      /* cursor para saber o tipo da finalidade */
      CURSOR cr_crapfin(pr_cdcooper IN crapcop.cdcooper%TYPE
                       ,pr_cdfinemp IN crapfin.cdfinemp%TYPE) IS
        SELECT fin.tpfinali
          FROM crapfin fin
         WHERE fin.cdcooper = pr_cdcooper
           AND fin.cdfinemp = pr_cdfinemp;            
      rw_crapfin cr_crapfin%ROWTYPE;       
      
    BEGIN   
      -- Buscar a tipo de contrato
      OPEN cr_craplcr;
        FETCH cr_craplcr INTO rw_craplcr;
        
        -- se achou registro
        IF cr_craplcr%FOUND THEN
          CLOSE cr_craplcr;          
          -- Tipo de contrato
          vr_tpctrato := rw_craplcr.tpctrato; 
          vr_cdusolcr := rw_craplcr.cdusolcr;
        END IF;       
    
      -- Busca o tipo da finalidade      
      OPEN cr_crapfin(pr_cdcooper => pr_cdcooper
                     ,pr_cdfinemp => pr_cdfinemp);
        FETCH cr_crapfin INTO rw_crapfin;          
                         
        IF cr_crapfin%FOUND THEN
          CLOSE cr_crapfin;
          -- tipo da finalidade
          vr_tpfinali := rw_crapfin.tpfinali;
        END IF;
    
      EMPR0001.pc_calcula_iof_epr(pr_cdcooper => pr_cdcooper
                                 ,pr_nrdconta => pr_nrdconta
                                 ,pr_dtmvtolt => pr_dtmvtolt
                                 ,pr_inpessoa => pr_inpessoa
                                 ,pr_cdlcremp => pr_cdlcremp
                                 ,pr_qtpreemp => pr_qtpreemp
                                 ,pr_vlpreemp => pr_vlpreemp
                                 ,pr_vlemprst => pr_vlemprst
                                 ,pr_dtdpagto => pr_dtdpagto
                                 ,pr_dtlibera => pr_dtlibera
                                 ,pr_tpemprst => pr_tpemprst
                                 ,pr_valoriof => vr_vlrdoiof
                                 ,pr_dscritic => vr_dscritic);
                                   
      -- VERIFICA SE OCORREU UMA CRITICA
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;        
      END IF;             

      /* 2 - Avaliacao de garantia de bem movel  */
      /* 3 - Avaliacao de garantia de bem imovel */
      IF ( vr_tpctrato = 2 ) OR ( vr_tpctrato = 3 ) THEN       
        IF vr_tpctrato = 2 THEN /* Bens Moveis */
          /* Verifica qual tarifa deve ser cobrada com base tipo pessoa */
          IF pr_inpessoa = 1 THEN /* Fisica */             
            vr_cdhisbem := 1443;
          ELSE              
            vr_cdhisbem := 1467;
          END IF;
        ELSE /* Bens Imoveis */
          IF pr_inpessoa = 1 THEN /* Fisica */            
            vr_cdhisbem := 1445;              
          ELSE
            vr_cdhisbem := 1469;
          END IF;          
        END IF;       
        
        -- abre cursor da tabela
        OPEN cr_craplat_bem(pr_cdcooper => pr_cdcooper,
                            pr_nrdconta => pr_nrdconta,
                            pr_nrctremp => pr_nrctremp,
                            pr_cdhistor => vr_cdhisbem);
        FETCH cr_craplat_bem INTO rw_craplat_bem;
            
        -- se achou registro
        IF cr_craplat_bem%FOUND THEN
          CLOSE cr_craplat_bem;
          -- se encontrou lancamento da tarifa
          vr_vltarbem := ROUND(nvl(rw_craplat_bem.vltarifa,0),2);
        ELSE
          CLOSE cr_craplat_bem;
        END IF;        
      END IF;
      
      IF pr_inpessoa = 1 THEN /* Fisica */
        vr_cdhistor := 1481;
      ELSE /* Juridica */
        vr_cdhistor := 1479;        
      END IF;
        
      -- abre cursor da tabela
      OPEN cr_craplat(pr_cdcooper => pr_cdcooper,
                      pr_nrdconta => pr_nrdconta,
                      pr_nrctremp => pr_nrctremp,
                      pr_cdhistor => vr_cdhistor);
      FETCH cr_craplat INTO rw_craplat;
        
      -- se achou registro
      IF cr_craplat%FOUND THEN
        CLOSE cr_craplat;
        -- se encontrou lancamento da tarifa
        vr_vlrtarif := ROUND(nvl(rw_craplat.vltarifa,0),2) + nvl(vr_vltarbem,0);
      ELSE -- se nao encontrou lançamento de tarifa busca a tarifa vigente
        -- Fechar cursor
        CLOSE cr_craplat;                
        
        IF vr_cdusolcr = 1 THEN
          IF pr_inpessoa = 1 THEN /* Fisica */
            vr_cdbattar := 'MICROCREPF';
          ELSE
            vr_cdbattar := 'MICROCREPJ';
          END IF;             
        END IF;
        
        -- buscar tarifa de cadastro linha de credito
        CCET0001.pc_calcula_tarifa_cadastro(pr_cdcooper => pr_cdcooper
                                           ,pr_dtmvtolt => pr_dtmvtolt
                                           ,pr_vlemprst => pr_vlemprst
                                           ,pr_cdbattar => vr_cdbattar
                                           ,pr_cdprogra => pr_cdprogra
                                           ,pr_cdusolcr => vr_cdusolcr 
                                           ,pr_inpessoa => pr_inpessoa
                                           ,pr_cdlcremp => pr_cdlcremp
                                           ,pr_tpctrato => vr_tpctrato
                                           ,pr_nrdconta => pr_nrdconta
                                           ,pr_nrctremp => pr_nrctremp
                                           ,pr_vltottar => vr_vlrtarif
                                           ,pr_cdcritic => vr_cdcritic
                                           ,pr_dscritic => vr_dscritic);

         -- VERIFICA SE OCORREU UMA CRITICA
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;        
        END IF;                        
      END IF;                                      
      
      -- se tipo de finalidade for portabilidade
      -- não deduz o IOF do valor total para calculo do CET
      IF vr_tpfinali = 2 THEN
        -- valor total emprestado
        vr_vlemprst := nvl(pr_vlemprst,0) - nvl(vr_vlrtarif,0);        
      ELSE
        -- valor total emprestado
        vr_vlemprst := nvl(pr_vlemprst,0) - nvl(vr_vlrdoiof,0) - nvl(vr_vlrtarif,0);
      END IF;
      
      vr_data_contrato := nvl(pr_dtlibera,pr_dtmvtolt);                
        
      -- Busca juros do cet
      CCET0001.pc_juros_cet(pr_nro_parcelas   => pr_qtpreemp
                           ,pr_vlr_prestacao  => pr_vlpreemp
                           ,pr_vlr_financiado => vr_vlemprst
                           ,pr_data_contrato  => vr_data_contrato
                           ,pr_primeiro_vcto  => pr_dtdpagto
                           ,pr_valorcet       => vr_vlrdocet
                           ,pr_tx_cet_ano     => vr_txanocet
                           ,pr_tx_cet_mes     => vr_txmescet
                           ,pr_cdcritic       => vr_cdcritic
                           ,pr_dscritic       => vr_dscritic);
       -- VERIFICA SE OCORREU UMA CRITICA
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;        
      END IF;   

      pr_txcetmes := vr_txmescet;      
      pr_txcetano := ROUND(vr_txanocet,2);
    
    EXCEPTION
      WHEN vr_exc_erro THEN        
        -- Monta mensagem de erro
        pr_cdcritic := NVL(vr_cdcritic,0);
        pr_dscritic := vr_dscritic;
      WHEN OTHERS THEN
        pr_cdcritic := 0;
        pr_dscritic := 'Erro pc_calculo_cet_emprestimos : ' || SQLERRM;
    END;
  END pc_calculo_cet_emprestimos;                   
                         
end CCET0001;
/
