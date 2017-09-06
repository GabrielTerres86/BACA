CREATE OR REPLACE PACKAGE CECRED.NPCB0001 is
  /* ---------------------------------------------------------------------------------------------------------------

      Programa : NPCB0001
      Sistema  : Rotinas referentes a Nova Plataforma de Cobrança de Boletos
      Sigla    : NPCB
      Autor    : Odirlei Busana - AMcom
      Data     : Dezembro/2016.                   Ultima atualizacao: 16/12/2016

      Dados referentes ao programa:

      Frequencia: -----
      Objetivo  : Rotinas referentes a Nova Plataforma de Cobrança de Boletos

      Alteracoes:

  ---------------------------------------------------------------------------------------------------------------*/
  
  /**** ESTRUTURA DOS TITULOS CIP ****/
  -- Registro dos descontos 
  TYPE typ_reg_DesctTit IS RECORD 
                 (DtDesctTit              DATE             -- Data Desconto Título
                 ,CodDesctTit             VARCHAR2(1)      -- Código Desconto Título
                 ,Vlr_PercDesctTit        NUMBER(17,5));   -- Valor ou Percentual Desconto Título                 
  -- Tabela de registros de desconto do título - CADA TÍTULO CIP PODE TER ATÉ 3 REGISTROS DE DESCONTO
  TYPE typ_tab_DesctTit IS TABLE OF typ_reg_DesctTit INDEX BY BINARY_INTEGER;
  -----------------------------------------------------------------------------------------------------
  -- Registros de calculos do título
  TYPE typ_reg_CalcTit IS RECORD 
                 (CdMunicipio             NUMBER(20)       -- Codigo do municipio do calculo
                 ,DtCalcdVencTit          DATE             -- Data de vencimento do calculo
                 ,VlrCalcdAbatt           NUMBER(19,2)     -- Valor Calculado do abatimento
                 ,VlrCalcdJuros           NUMBER(19,2)     -- Valor Calculado Juros
                 ,VlrCalcdMulta           NUMBER(19,2)     -- Valor Calculado Multa
                 ,VlrCalcdDesct           NUMBER(19,2)     -- Valor Calculado Desconto
                 ,VlrTotCobrar            NUMBER(19,2)     -- Valor Total a Cobrar
                 ,VlrCalcdMin             NUMBER(19,2)     -- Valor Calculado para minimo
                 ,VlrCalcdMax             NUMBER(19,2)     -- Valor Calculado para maximo
                 ,DtValiddCalc            DATE);           -- Data Validade Cálculo
  -- Tabela de registros de calculos do título - CADA TÍTULO CIP PODE TER VÁRIOS 
  -- CALCULOS DE VALORES, SENDO QUE CADA UM DELES POSSUI UMA DATA DE VALIDADE
  TYPE typ_tab_CalcTit IS TABLE OF typ_reg_CalcTit INDEX BY BINARY_INTEGER; 
  -----------------------------------------------------------------------------------------------------
  -- Registros de baixas operacionais do título
  TYPE typ_reg_BaixaOperac IS RECORD 
                 (NumIdentcBaixaOperac    NUMBER(19)       -- Número Identificação Baixa Operacional
                 ,NumRefAtlBaixaOperac    NUMBER(19)       -- Número Referência Atual Baixa Operacional
                 ,NumSeqAtlzBaixaOperac   NUMBER(19)       -- Número Sequência Atualização Baixa Operacional
                 ,DtProcBaixaOperac       DATE             -- Data Processamento Baixa Operacional
                 ,DtHrProcBaixaOperac     DATE             -- Data Hora Processamento Baixa Operacional
                 ,DtHrSitBaixaOperac      DATE             -- Data Hora Situação Baixa Operacional
                 ,VlrBaixaOperacTit       NUMBER(19,2)     -- Valor Baixa Operacional Título
                 ,NumCodBarrasBaixaOperac VARCHAR2(44));   -- Número Código de Barras Baixa Operacional
  -- Tabela de registros de baixas operacionais do título - CADA TÍTULO CIP PODE TER VÁRIOS 
  -- REGISTROS DE BAIXA OPERACIONAL
  TYPE typ_tab_BaixaOperac IS TABLE OF typ_reg_BaixaOperac INDEX BY BINARY_INTEGER; 
  -----------------------------------------------------------------------------------------------------
  -- Registros de baixas efetivas do título
  TYPE typ_reg_BaixaEft IS RECORD 
                 (NumIdentcBaixaEft      NUMBER(19)        -- Número Identificação Baixa Efetiva
                 ,NumRefAtlBaixaEft      NUMBER(19)        -- Número Referência Atual Baixa Efetiva
                 ,NumSeqAtlzBaixaEft     NUMBER(19)        -- Número Sequência Atualização Baixa Efetiva
                 ,DtProcBaixaEft         DATE              -- Data Processamento Baixa Efetiva
                 ,DtHrProcBaixaEft       DATE              -- Data Hora Processamento Baixa
                 ,VlrBaixaEftTit         NUMBER(19,2)      -- Valor Baixa Efetiva Título
                 ,NumCodBarrasBaixaEft   VARCHAR2(44)      -- Número Código de Barras Baixa Efetiva
                 ,CanPgto                NUMBER(1)         -- Canal de Pagamento
                 ,MeioPgto               NUMBER(1)         -- Meio de Pagamento
                 ,DtHrSitBaixaEft        VARCHAR2(14));    -- Data Hora Situação Baixa Efetiva
  -- Tabela de registros de baixas efetivas do título - CADA TÍTULO CIP PODE TER VÁRIOS 
  -- REGISTROS DE BAIXA EFETIVAS
  TYPE typ_tab_BaixaEft IS TABLE OF typ_reg_BaixaEft INDEX BY BINARY_INTEGER; 
  -----------------------------------------------------------------------------------------------------
  -- ESTRUTURA DOS TITULOS CIP QUE SERÁ CARREGADA COM INFORMAÇÕES DO XML 
  TYPE typ_reg_TituloCIP IS RECORD 
                 -- RequisitarTituloCIP - Tags 
                 (NumCtrlPart             VARCHAR2(20)     -- Número de controle Participante
                 ,ISPBPartRecbdrPrincipal NUMBER(8)        -- ISPB Participante Recebedor Principal
                 ,ISPBPartRecebdrAdmtd    NUMBER(8)        -- ISPB Participante Recebedor Administrado
                 ,NumIdentcTit            NUMBER(19)       -- Número Identificação Titulo
                 ,NumRefAtlCadTit         NUMBER(19)       -- Número Referência Atual Cadastro Título
                 ,NumSeqAtlzCadTit        NUMBER(19)       -- Número Sequência Atualização Cadastro Título
                 ,DtHrSitTit              DATE             -- Data Hora Situação Título
                 ,ISPBPartDestinatario    NUMBER(8)        -- ISPB Participante Destinatário
                 ,CodPartDestinatario     VARCHAR2(3)      -- Código Participante Destinatário
                 ,TpPessoaBenfcrioOr      VARCHAR2(1)      -- Tipo Pessoa Beneficiário Original
                 ,CNPJ_CPFBenfcrioOr      NUMBER(14)       -- CNPJ ou CPF Beneficiário Original
                 ,Nom_RzSocBenfcrioOr     VARCHAR2(50)     -- Nome ou Razão Social Beneficiário Original
                 ,NomFantsBenfcrioOr      VARCHAR2(80)     -- Nome Fantasia Beneficiário Original
                 ,LogradBenfcrioOr        VARCHAR2(40)     -- Logradouro Beneficiário Original
                 ,CidBenfcrioOr           VARCHAR2(50)     -- Cidade do Beneficiário Original
                 ,UFBenfcrioOr            VARCHAR2(2)      -- UF Beneficiário Original
                 ,CEPBenfcrioOr           NUMBER(8)        -- CEP Beneficiário Original
                 ,TpPessoaBenfcrioFinl    VARCHAR2(1)      -- Tipo Pessoa Beneficiário Final
                 ,CNPJ_CPFBenfcrioFinl    NUMBER(14)       -- CNPJ ou CPF Beneficiário Final
                 ,Nom_RzSocBenfcrioFinl   VARCHAR2(50)     -- Nome ou Razão Social Beneficiário Final
                 ,NomFantsBenfcrioFinl    VARCHAR2(80)     -- Nome Fantasia Beneficiário Final
                 ,TpPessoaPagdr           VARCHAR2(1)      -- Tipo Pessoa Pagador
                 ,CNPJ_CPFPagdr           NUMBER(14)       -- CNPJ ou CPF Pagador
                 ,Nom_RzSocPagdr          VARCHAR2(50)     -- Nome ou Razão Social Pagador
                 ,NomFantsPagdr           VARCHAR2(80)     -- Nome Fantasia Pagador
                 ,CodMoedaCNAB            VARCHAR2(2)      -- Código Moeda CNAB
                 ,NumCodBarras            VARCHAR2(44)     -- Número Código de Barras
                 ,NumLinhaDigtvl          VARCHAR2(47)     -- Número Linha Digitável
                 ,DtVencTit               DATE             -- Data Vencimento Titulo
                 ,VlrTit                  NUMBER(19,2)     -- Valor Título
                 ,CodEspTit               VARCHAR2(2)      -- Código Espécie Título
                 ,QtdDiaPrott             NUMBER(6)        -- Quantidade Dias Protesto
                 ,DtLimPgtoTit            DATE              -- Data Limite Pagamento Título
                 ,IndrBloqPgto            VARCHAR2(1)      -- Indicador Bloqueio Pagamento
                 ,IndrPgtoParcl           VARCHAR2(1)      -- Indicador Pagamento Parcial
                 ,QtdPgtoParcl            NUMBER(3)        -- Quantidade Pagamento Parcial
                 ,VlrAbattTit             NUMBER(19,2)     -- Valor Abatimento Título
                 -- JurosTit - Tags 
                 ,DtJurosTit              DATE             -- Data Juros Título
                 ,CodJurosTit             VARCHAR2(1)      -- Código Juros Título
                 ,Vlr_PercJurosTit        NUMBER(17,5)     -- Valor ou Percentual Juros Título
                 -- MultaTit - Tags 
                 ,DtMultaTit              DATE             -- Data Multa Título
                 ,CodMultaTit             VARCHAR2(1)      -- Código Multa Título
                 ,Vlr_PercMultaTit        NUMBER(17,5)     -- Valor ou Percentual Multa Título
                 -- RepetDesctTit - DesctTit (1..3)
                 ,TabDesctTit             typ_tab_DesctTit
                 ,IndrVlr_PercMinTit      VARCHAR2(1)      -- Indicador Valor ou Percentual Mínimo Título
                 ,Vlr_PercMinTit          NUMBER(17,5)     -- Valor ou Percentual Mínimo do Título
                 ,IndrVlr_PercMaxTit      VARCHAR2(1)      -- Indicador Valor ou Percentual Máximo Título
                 ,Vlr_PercMaxTit          NUMBER(17,5)     -- Valor ou Percentual Máximo do Título
                 ,TpModlCalc              VARCHAR2(2)      -- Tipo Modelo Cálculo
                 ,TpAutcRecbtVlrDivgte    VARCHAR2(1)      -- Tipo Autorização Recebimento Valor Divergente
	               -- RepetCalcTit  - CalcTit (n)
                 ,TabCalcTit              typ_tab_CalcTit
                 ,QtdPgtoParclRegtd       NUMBER(3)        -- Quantidade Pagamento Parcial Registrado
                 ,VlrSldTotAtlPgtoTit     NUMBER(19,2)     -- Valor Saldo Total Atual Pagamento Título
                 -- RepetBaixaOperac - BaixaOperac (n)
	               ,TabBaixaOperac          typ_tab_BaixaOperac
                 -- RepetBaixaEft - BaixaEft (n)
			           ,TabBaixaEft             typ_tab_BaixaEft   
                 ,SitTitPgto              VARCHAR2(2)      -- Situação Título Pagamento
                 -- JDCalcTit - Tags
                 ,DtValiddCalcJD          DATE             -- Data Validade Cálculo
                 ,VlrCalcdJDAbatt         NUMBER(19,2)     -- Valor Abatimento Título
                 ,VlrCalcdJDJuros         NUMBER(19,2)     -- Valor Calculado Juros
                 ,VlrCalcdJDMulta         NUMBER(19,2)     -- Valor Calculado Multa
                 ,VlrCalcdJDDesct         NUMBER(19,2)     -- Valor Calculado Desconto
                 ,VlrCalcdJDTotCobrar     NUMBER(19,2)     -- Valor Total a Cobrar
                 ,VlrCalcdJDMin           NUMBER(17,5)     -- Valor ou Percentual mínimo do Título
                 ,VlrCalcdJDMax           NUMBER(17,5));   -- Valor ou Percentual máximo do Título
  -- Criar o tipo da tabela para o registro, caso faça necessário guardar mais de um boleto
  --TYPE typ_tab_TituloCIP IS TABLE OF typ_reg_TituloCIP INDEX BY BINARY_INTEGER;
  /**********************************/
  
  -- TempTable para armazenar as situações do titulo no NPC
  TYPE typ_rec_SitTitPgto_NPC
       IS RECORD(dssituac VARCHAR2(1000),
                 dscritic VARCHAR2(1000),
                 flgpagto INTEGER);  --> Permite Pagamento               
  TYPE typ_tab_SitTitPgto_NPC IS TABLE OF typ_rec_SitTitPgto_NPC
       INDEX BY PLS_INTEGER;
  vr_tab_SitTitPgto_NPC  typ_tab_SitTitPgto_NPC;
  
  --> Função para montar o número de controle do participante - NUMCTRLPART
  FUNCTION fn_montar_NumCtrlPart(pr_cdbarras   IN VARCHAR2
                                ,pr_cdagenci   IN NUMBER
                                ,pr_flmobile   IN NUMBER) RETURN VARCHAR2;
  
  -- Função para converter os valores numéricos recebidos no XML para o padrão oracle
  FUNCTION fn_convert_number(pr_dsnumber  IN VARCHAR2) RETURN NUMBER;
    
  --> Rotina para verificar rollout da plataforma de cobrança
  FUNCTION fn_verifica_rollout ( pr_cdcooper     IN crapcop.cdcooper%TYPE, --> Codigo da cooperativa
                                 pr_dtmvtolt     IN crapdat.dtmvtolt%TYPE, --> Data do movimento
                                 pr_vltitulo     IN crapcob.vltitulo%TYPE, --> Valor do titulo
                                 pr_tpdregra     IN INTEGER)               --> Tipo de regra de rollout(1-registro,2-pagamento)
                                 RETURN INTEGER;
  
  --> Rotina para retornar valor limite de pagamento em contigencia na cip
  FUNCTION fn_vlcontig_cip ( pr_cdcooper     IN crapcop.cdcooper%TYPE) --> Codigo da cooperativa)               --> Tipo de regra de rollout(1-registro,2-pagamento)
                             RETURN NUMBER;
  
  --> Rotina para verificar e montar o código de barras ou a linha digitavel
  PROCEDURE pc_linha_codigo_barras(pr_titulo1  IN OUT NUMBER     --> Campo 1 da linha digitável
                                  ,pr_titulo2  IN OUT NUMBER     --> Campo 2 da linha digitável
                                  ,pr_titulo3  IN OUT NUMBER     --> Campo 3 da linha digitável
                                  ,pr_titulo4  IN OUT NUMBER     --> Campo 4 da linha digitável
                                  ,pr_titulo5  IN OUT NUMBER     --> Campo 5 da linha digitável
                                  ,pr_codbarra IN OUT VARCHAR2   --> Código de barras completo
                                  ,pr_cdcritic    OUT NUMBER     --> Retorno do código de crítica
                                  ,pr_dscritic    OUT VARCHAR2); --> Retorno da descrição da crítica
         
  --> Rotina para gerar log das rotinas NPC
  PROCEDURE pc_gera_log_npc ( pr_cdcooper     IN crapcop.cdcooper%TYPE --> Codigo da cooperativa)  
                             ,pr_nmrotina     IN VARCHAR2              --> Nome da rotina que esta gerando log
                             ,pr_dsdolog      IN VARCHAR2);            --> Descrição do log
                             
  --> Rotina para pre-validação do boleto na Nova plataforma de cobrança 
  PROCEDURE pc_valid_titulo_npc ( pr_cdcooper     IN crapcop.cdcooper%TYPE --> Codigo da cooperativa
                                 ,pr_dtmvtolt     IN crapdat.dtmvtolt%TYPE --> Data de movimento
                                 ,pr_cdctrlcs     IN tbcobran_consulta_titulo.cdctrlcs%TYPE --> Numero de controle da consulta no NPC
                                 ,pr_tbtitulocip  IN NPCB0001.typ_reg_titulocip --> Registro com os dados do titulo
                                 ,pr_flcontig     IN INTEGER DEFAULT 0     --> Indicador de contigencia     
                                 ,pr_cdcritic    OUT INTEGER               --> Codigo da critico
                                 ,pr_dscritic    OUT VARCHAR2              --> Descrição da critica
                                 );
                           
  --> Validar se valor esta entre maximo e minimo
  FUNCTION fn_valid_max_min_valor (pr_vltitulo IN NUMBER   --> Valor do titulo
                                  ,pr_vldpagto IN NUMBER   --> Valor do pagamento
                                  ,pr_tpmaxpgt IN VARCHAR2 --> Tipo de calculo valor maximo(P-Percentual, V-Valor)
                                  ,pr_vlmaxpgt IN NUMBER   --> Valor maximo de pagamento
                                  ,pr_tpminpgt IN VARCHAR2 --> Tipo de calculo valor maximo(P-Percentual, V-Valor)
                                  ,pr_vlminpgt IN NUMBER   --> Valor maximo de pagamento
                                   ) RETURN INTEGER;                                   
  
  --> Rotina para retornar valor do titulo calculado pela NPC
  FUNCTION fn_valor_calc_titulo_npc (pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE --> Data de movimento                                                                     
                                    ,pr_tbtitulo  IN typ_reg_TituloCIP     --> Regras de calculo de juros                            
                                    ) RETURN NUMBER ; --> Retornar valor que deve ser cobrado conforme a data de pagamentp                                  
  
  --> Rotina para retornar valor do titulo calculado pela NPC e demais valores
  PROCEDURE pc_valor_calc_titulo_npc(pr_dtmvtolt   IN crapdat.dtmvtolt%TYPE --> Data de movimento
                                    ,pr_tbtitulo   IN typ_reg_TituloCIP     --> Regras de calculo de juros 
                                    ,pr_vlrtitulo OUT NUMBER       --> Retornar valor conforme a data de pagamento
                                    ,pr_vlrjuros  OUT NUMBER       --> Retornar os juros conforme a data de pagamento
                                    ,pr_vlrmulta  OUT NUMBER       --> Retornar os multa conforme a data de pagamento
                                    ,pr_vlrdescto OUT NUMBER );    --> Retornar os desconto conforme a data de pagamento
                                  
  --> Rotina para validação do pagamento do boleto na Nova plataforma de cobrança 
  PROCEDURE pc_valid_pagamento_npc (pr_cdcooper     IN crapcop.cdcooper%TYPE --> Codigo da cooperativa
                                   ,pr_dtmvtolt     IN crapdat.dtmvtolt%TYPE --> Data de movimento                                   
                                   ,pr_cdctrlcs     IN tbcobran_consulta_titulo.cdctrlcs%TYPE --> Numero de controle da consulta no NPC
                                   ,pr_dtagenda     IN craptit.dtdpagto%TYPE --> Data de agendamento
                                   ,pr_vldpagto     IN craptit.vldpagto%TYPE --> Valor a ser pago
                                   ,pr_vltitulo    OUT craptit.vltitulo%TYPE --> Valor do titulo
                                   ,pr_nridenti    OUT NUMBER                --> Retornar numero de identificacao do titulo
                                   ,pr_tpdbaixa    OUT INTEGER               --> Retornar tipo de baixa
                                   ,pr_flcontig    OUT INTEGER               --> Retornar inf que a CIP esta em modo de contigencia
                                   ,pr_cdcritic    OUT INTEGER               --> Codigo da critico
                                   ,pr_dscritic    OUT VARCHAR2);            --> Descrição da critica
  
  --> Rotina para retornar o codigo do canal de pagamento do NPC
  FUNCTION fn_canal_pag_NPC( pr_cdagenci     IN crapage.cdagenci%TYPE --> Codigo da agencia
                            ,pr_idtitdda     IN INTEGER               --> Indicador se foi pago pelo sistema de DDDA
                            ) RETURN INTEGER ; --> Retornar codigo do canal de pagamento no NPC
  
  --> Rotina para retornar se NPC esta em contigencia
  FUNCTION fn_contigencia_NPC ( pr_cdcooper   IN INTEGER, --> Codigo da cooperativa
                                pr_idorigem   IN INTEGER  --> Origem da transacao
                              ) RETURN VARCHAR2; --> Retornar S-Em contigencia, N-Não esta em contigencia                                                                   
END NPCB0001;
/
CREATE OR REPLACE PACKAGE BODY CECRED.NPCB0001 is
  /* ---------------------------------------------------------------------------------------------------------------

      Programa : NPCB0001
      Sistema  : Rotinas referentes a Nova Plataforma de Cobrança de Boletos
      Sigla    : NPCB
      Autor    : Odirlei Busana - AMcom
      Data     : Dezembro/2016.                   Ultima atualizacao: 16/12/2016

      Dados referentes ao programa:

      Frequencia: -----
      Objetivo  : Rotinas GERAIS referentes a Nova Plataforma de Cobrança de Boletos

      Alteracoes:

  ---------------------------------------------------------------------------------------------------------------*/
  -- Campos com os valores do rollout, guardados como global para nao serem buscados 
  -- toda vez que a rotina ser chamada, visto que os valores nao são alterados frequentemente
  TYPE typ_tab_dstextab IS TABLE OF craptab.dstextab%TYPE
       INDEX BY PLS_INTEGER;
  vr_dstextab_rollout_pag     typ_tab_dstextab;
  vr_dstextab_rollout_reg     typ_tab_dstextab;
  
  --> Para garantir o valor atualizado, informação será buscada a cada hora
  vr_nrctrlhr        NUMBER;
  
  --> Declaração geral de exception
  vr_exc_erro        EXCEPTION;
   
  --> Nome do arquivo de log mensal
  vr_dsarqlg         CONSTANT VARCHAR2(20) := 'npc_'||to_char(SYSDATE,'RRRRMM')||'.log'; 
   
  --> Função para montar o número de controle do participante - NUMCTRLPART
  FUNCTION fn_montar_NumCtrlPart(pr_cdbarras   IN VARCHAR2
                                ,pr_cdagenci   IN NUMBER
                                ,pr_flmobile   IN NUMBER) RETURN VARCHAR2 IS
    -- Variáveis
    vr_dssufixo     VARCHAR2(2) := 'XX';
    vr_idtitdda     NUMBER;
          
  BEGIN
    
     -- Verificar se é um titulo DDDA
     BEGIN
        vr_idtitdda := TO_NUMBER(GENE0002.fn_busca_entrada(2,pr_cdbarras,';'));
     EXCEPTION
        WHEN OTHERS THEN
           vr_idtitdda:= 0;
     END;
     
     -- Se o indicador de titulo ddda for maior que zero
     IF vr_idtitdda > 0 THEN
       vr_dssufixo := 'DD'; -- Indica título DDA
     ELSE
       IF pr_flmobile = 1 THEN
         vr_dssufixo := 'MO'; -- Indica MOBILE
       ELSE
         IF pr_cdagenci NOT IN (90,91) THEN
           vr_dssufixo := 'CX'; -- Indica CAIXA ON LINE
         ELSE 
           IF pr_cdagenci = 90 THEN
             vr_dssufixo := 'IB'; -- Indica INTERNET BANKING
           ELSIF pr_cdagenci = 91 THEN
             vr_dssufixo := 'TA'; -- Indica TAA
           END IF;
         END IF; 
       END IF;
     END IF;
     
     -- Retorna a chave referente ao NumCtrlPart
     RETURN TO_CHAR(SYSTIMESTAMP, 'YYYYMMDDHH24MISSFF4')||vr_dssufixo;
     
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001,'Erro ao configurar NumCtrlPart: '||SQLERRM);
  END fn_montar_NumCtrlPart;
  
  -- Função para converter os valores numéricos recebidos no XML para o padrão oracle
  FUNCTION fn_convert_number(pr_dsnumber  IN VARCHAR2) RETURN NUMBER IS
    -- Variáveis
    vr_dsmascara  VARCHAR2(100);
  BEGIN
    
    -- Se o valor informado possui algum ponto 
    IF INSTR(pr_dsnumber,'.') > 0 THEN
      -- Define a máscara que será utilizada
      vr_dsmascara := LPAD('9',LENGTH(SUBSTR(pr_dsnumber,0,INSTR(pr_dsnumber,'.')-1)), '9')||'D'||
                      LPAD('9',LENGTH(SUBSTR(pr_dsnumber  ,INSTR(pr_dsnumber,'.')+1)), '9');
    
      RETURN TO_NUMBER(pr_dsnumber,vr_dsmascara,'NLS_NUMERIC_CHARACTERS=''.,''');
    ELSE 
      RETURN TO_NUMBER(pr_dsnumber);
    END IF;
    
  END fn_convert_number;
  
  --> Rotina para verificar rollout da plataforma de cobrança
  FUNCTION fn_verifica_rollout ( pr_cdcooper     IN crapcop.cdcooper%TYPE, --> Codigo da cooperativa
                                 pr_dtmvtolt     IN crapdat.dtmvtolt%TYPE, --> Data de movimento
                                 pr_vltitulo     IN crapcob.vltitulo%TYPE, --> Valor do titulo
                                 pr_tpdregra     IN INTEGER)               --> Tipo de regra de rollout(1-registro,2-pagamento)
                                 RETURN INTEGER IS
  /* ..........................................................................
    
      Programa : fn_verifica_rollout        
      Sistema  : Conta-Corrente - Cooperativa de Credito
      Sigla    : CRED
      Autor    : Odirlei Busana(Amcom)
      Data     : Dezembro/2016.                   Ultima atualizacao: 31/07/2017
    
      Dados referentes ao programa:
    
      Frequencia: Sempre que for chamado
      Objetivo  : Rotina para verificar rollout da plataforma de cobrança
      Alteração : 31/07/2017 - Ajustado rotina para buscar a faixa de rollout
                               completa de todas as datas. (Rafael)            
        
    ..........................................................................*/
    -----------> CURSORES <-----------
    ----------> VARIAVEIS <-----------
    vr_dstextab     craptab.dstextab%TYPE;  
    vr_tab_campos   gene0002.typ_split;  
    vr_cdacesso     craptab.cdacesso%TYPE;
    vr_index        INTEGER;
    
  BEGIN   
  
     --> Definir cdacesso conforme tipo de rollout
     IF pr_tpdregra = 1 THEN
       vr_cdacesso := 'ROLLOUT_CIP_REG';
       IF vr_dstextab_rollout_reg.exists(pr_cdcooper) THEN
         vr_dstextab := vr_dstextab_rollout_reg(pr_cdcooper);
       END IF;
     ELSE
       vr_cdacesso := 'ROLLOUT_CIP_PAG';
       IF vr_dstextab_rollout_pag.exists(pr_cdcooper) THEN
         vr_dstextab := vr_dstextab_rollout_pag(pr_cdcooper);
       END IF;
     END IF;  
     
     -- Se ainda nao possui o valor da craptab
     IF vr_dstextab is NULL OR 
        -- ou passou a hora
        to_char(SYSDATE,'HH24') <> vr_nrctrlhr THEN
     
       vr_nrctrlhr := to_char(SYSDATE,'HH24');
     
       --> Buscar dados
       vr_dstextab := TABE0001.fn_busca_dstextab
                                       (pr_cdcooper => pr_cdcooper
                                       ,pr_nmsistem => 'CRED'
                                       ,pr_tptabela => 'GENERI'
                                       ,pr_cdempres => 0
                                       ,pr_cdacesso => vr_cdacesso
                                       ,pr_tpregist => 0); 
      
        --> Guardar valores 
        IF pr_tpdregra = 1 THEN
          vr_dstextab_rollout_reg(pr_cdcooper) := vr_dstextab;
        ELSE
          vr_dstextab_rollout_pag(pr_cdcooper) := vr_dstextab;
        END IF; 
      END IF;
      
      vr_tab_campos:= gene0002.fn_quebra_string(vr_dstextab,';');
      
      --> senao nao encontrar os parametros do rollout, retornar como nao esta na faixa
      IF vr_tab_campos.count = 0 THEN
        RETURN 0; 
      END IF;
      
/*      --> Validar data
      IF pr_dtmvtolt >= to_date(vr_tab_campos(1),'DD/MM/RRRR')  THEN
        --> Validar valor
        IF pr_vltitulo >= gene0002.fn_char_para_number(vr_tab_campos(2)) THEN
          --> Retornar 1 - ja esta na faixa de rollout
          RETURN 1;
        END IF;
      END IF; */
      
      --> Validar data
      FOR vr_index IN 1..vr_tab_campos.count LOOP
        IF vr_index MOD 2 = 0 THEN 
          IF pr_dtmvtolt >= to_date(vr_tab_campos(vr_index-1),'DD/MM/RRRR')  THEN
            --> Validar valor
            IF pr_vltitulo >= gene0002.fn_char_para_number(vr_tab_campos(vr_index)) THEN
              --> Retornar 1 - ja esta na faixa de rollout
              RETURN 1;
            END IF;
          END IF;
        END IF;
      END LOOP;      
      
      RETURN 0;
      
  EXCEPTION 
    WHEN OTHERS THEN
      RETURN 0;      
  END fn_verifica_rollout;
  
  --> Rotina para retornar valor limite de pagamento em contigencia na cip
  FUNCTION fn_vlcontig_cip ( pr_cdcooper     IN crapcop.cdcooper%TYPE) --> Codigo da cooperativa)               --> Tipo de regra de rollout(1-registro,2-pagamento)
                             RETURN NUMBER IS
  /* ..........................................................................
    
      Programa : fn_vlcontig_cip        
      Sistema  : Conta-Corrente - Cooperativa de Credito
      Sigla    : CRED
      Autor    : Odirlei Busana(Amcom)
      Data     : Agosto/2017.                   Ultima atualizacao: 
    
      Dados referentes ao programa:
    
      Frequencia: Sempre que for chamado
      Objetivo  : Rotina para  retornar valor limite de pagamento em contigencia na cip
      Alteração : 
        
    ..........................................................................*/
    -----------> CURSORES <-----------
    ----------> VARIAVEIS <-----------
    vr_dstextab     craptab.dstextab%TYPE;  
  BEGIN   
            
    vr_dstextab := tabe0001.fn_busca_dstextab( pr_cdcooper => pr_cdcooper
                                              ,pr_nmsistem => 'CRED'
                                              ,pr_tptabela => 'GENERI'
                                              ,pr_cdempres => 0
                                              ,pr_cdacesso => 'VLCONTIG_CIP'
                                              ,pr_tpregist => 0);  
                                              
    RETURN gene0002.fn_char_para_number(vr_dstextab);
      
  EXCEPTION 
    WHEN OTHERS THEN
      RETURN 0;      
  END fn_vlcontig_cip;
  
  --> Rotina para verificar e montar o código de barras ou a linha digitavel
  PROCEDURE pc_linha_codigo_barras(pr_titulo1  IN OUT NUMBER
                                  ,pr_titulo2  IN OUT NUMBER
                                  ,pr_titulo3  IN OUT NUMBER
                                  ,pr_titulo4  IN OUT NUMBER
                                  ,pr_titulo5  IN OUT NUMBER
                                  ,pr_codbarra IN OUT VARCHAR2
                                  ,pr_cdcritic    OUT NUMBER
                                  ,pr_dscritic    OUT VARCHAR2) IS
  /* ..........................................................................
    
      Programa : pc_linha_codigo_barras        
      Sistema  : Conta-Corrente - Cooperativa de Credito
      Sigla    : CRED
      Autor    : Renato Darosci(Supero)
      Data     : Dezembro/2016.                   Ultima atualizacao: --/--/----
    
      Dados referentes ao programa:
    
      Frequencia: Sempre que for chamado
      Objetivo  : Rotina para verificar e montar o código de barras pela linha
                  digitável e vice-versa
                  
      Alteração : 05/06/2017 - Incluido validação do digito do codigo de barras.
                               PRJ340 - NPC (Odirlei-AMcom)
        
        
    ..........................................................................*/
    -----------> CURSORES <-----------
    
    ----------> VARIAVEIS <-----------
    vr_de_valor_calc   VARCHAR2(100);
    vr_flg_zeros       BOOLEAN;
    vr_nro_digito      NUMBER;
    vr_retorno         BOOLEAN; 
    vr_flg_cdbarerr    BOOLEAN;   
    
  BEGIN   
     -- Se foi informado a linha digitável
     IF NVL(pr_titulo1,0) <> 0 OR
        NVL(pr_titulo2,0) <> 0 OR
        NVL(pr_titulo3,0) <> 0 OR
        NVL(pr_titulo4,0) <> 0 OR
        NVL(pr_titulo5,0) <> 0 THEN

        -- Validar os digitos das 3 primeiras partes da linha digitavel
        FOR idx IN 1..3 LOOP
           -- Determinar a parte que será validada
           CASE idx
              WHEN 1 THEN
                 vr_de_valor_calc:= pr_titulo1;
                 vr_flg_zeros:= TRUE;
              WHEN 2 THEN
                 vr_de_valor_calc:= pr_titulo2;
                 vr_flg_zeros:= FALSE;
              WHEN 3 THEN
                 vr_de_valor_calc:= pr_titulo3;
                 vr_flg_zeros:= FALSE;
           END CASE;
           
           -- Calcular digito verificado
           CXON0000.pc_calc_digito_verif(pr_valor        => vr_de_valor_calc   --> Valor Calculado
                                        ,pr_valida_zeros => vr_flg_zeros       --> Validar Zeros
                                        ,pr_nro_digito   => vr_nro_digito      --> Digito Verificador
                                        ,pr_retorno      => vr_retorno);       --> Retorno digito correto
           
           -- Se não retornou o dígito verificador
           IF NOT vr_retorno THEN
              -- Retornar a crítica 
              pr_cdcritic := 8;
              pr_dscritic := NULL;
              RAISE vr_exc_erro;
           END IF;
        END LOOP; --For idx 1..3 

        -- Compor o codigo de barras atraves da linha digitavel
        pr_codbarra := SUBSTR(gene0002.fn_mask(pr_titulo1,'9999999999'),1,4)||
                       gene0002.fn_mask(pr_titulo4,'9')  ||
                       gene0002.fn_mask(pr_titulo5,'99999999999999')  ||
                       SUBSTR(gene0002.fn_mask(pr_titulo1,'9999999999'),5,1)||
                       SUBSTR(gene0002.fn_mask(pr_titulo1,'9999999999'),6,4)||
                       SUBSTR(gene0002.fn_mask(pr_titulo2,'99999999999'),1,10)||
                       SUBSTR(gene0002.fn_mask(pr_titulo3,'99999999999'),1,10);
     ELSE
        -- Compoe a Linha Digitavel atraves do Codigo de Barras 
          
        -- Validar tamanho de 44 caracteres no codigo de barras e
        -- somente aceitar algarismo 0-9 
        vr_flg_cdbarerr := gene0002.fn_numerico(pr_codbarra) = FALSE;

        -- Se o codigo barras for diferente 44 posicoes
        IF LENGTH(pr_codbarra) != 44 THEN
           vr_flg_cdbarerr:= TRUE;
        END IF;

        -- Se o codigo barras estiver errado
        IF  vr_flg_cdbarerr THEN
           -- Retornar a crítica 
           pr_cdcritic := 0;
           pr_dscritic := 'Codigo de Barras invalido.';
           RAISE vr_exc_erro;
        END IF;
         
        -- Montar parametros saida
        pr_titulo1 := TO_NUMBER(SUBSTR(pr_codbarra,01,04)||
                                SUBSTR(pr_codbarra,20,01)||
                                SUBSTR(pr_codbarra,21,04)|| '0');
        pr_titulo2 := TO_NUMBER(SUBSTR(pr_codbarra,25,10)|| '0');
        pr_titulo3 := TO_NUMBER(SUBSTR(pr_codbarra,35,10)|| '0');
        pr_titulo4 := TO_NUMBER(SUBSTR(pr_codbarra,05,01));
        pr_titulo5 := TO_NUMBER(SUBSTR(pr_codbarra,06,14));
 
        /**- VALIDACAO DE LINHA DIGITAVEL -*/
        FOR idx IN 1..3 LOOP
           -- Determinar a parte que será validada
           CASE idx
              WHEN 1 THEN
                 vr_de_valor_calc:= pr_titulo1;
                 vr_flg_zeros:= TRUE;
              WHEN 2 THEN
                 vr_de_valor_calc:= pr_titulo2;
                 vr_flg_zeros:= FALSE;
              WHEN 3 THEN
                 vr_de_valor_calc:= pr_titulo3;
                 vr_flg_zeros:= FALSE;
           END CASE;
           
           -- Calcular digito verificador
           --  Calcula digito - campo da linha digitavel 
           CXON0000.pc_calc_digito_verif (pr_valor        => vr_de_valor_calc   --> Valor Calculado
                                         ,pr_valida_zeros => vr_flg_zeros       --> Validar Zeros
                                         ,pr_nro_digito   => vr_nro_digito      --> Digito Verificador
                                         ,pr_retorno      => vr_retorno);       --> Retorno digito correto
           
           -- Determinar a parte que sera retornada
           CASE idx
              WHEN 1 THEN pr_titulo1 := TO_NUMBER(vr_de_valor_calc);
              WHEN 2 THEN pr_titulo2 := TO_NUMBER(vr_de_valor_calc);
              WHEN 3 THEN pr_titulo3 := TO_NUMBER(vr_de_valor_calc);
           END CASE;
           
        END LOOP; --For idx 1..3
     END IF; -- Se foi informado a linha digitável
           
     vr_retorno := TRUE;
     -- Calculo do Digito Verificador  - Titulo
     vr_de_valor_calc:= pr_codbarra;
     --Executar rotina calculo digito titulo
     CXON0000.pc_calc_digito_titulo (pr_valor   => vr_de_valor_calc --> Valor Calculado
                                    ,pr_retorno => vr_retorno);     --> Retorno digito correto
     --Se retornou erro
     -- Se não retornou o dígito verificador
     IF NOT vr_retorno THEN
       -- Retornar a crítica 
       pr_cdcritic := 8;
       pr_dscritic := NULL;
       RAISE vr_exc_erro;
     END IF;     
  
  EXCEPTION 
     WHEN vr_exc_erro THEN
        -- Se foi retornado apenas código
        IF pr_cdcritic > 0 AND pr_dscritic IS NULL THEN
          -- Buscar a descrição
          pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic);
        END IF;
     WHEN OTHERS THEN
        -- Efetuar retorno do erro não tratado
        pr_cdcritic := 0;
        pr_dscritic := SQLERRM;
  END pc_linha_codigo_barras;
  
  --> Rotina para gerar log das rotinas NPC
  PROCEDURE pc_gera_log_npc ( pr_cdcooper     IN crapcop.cdcooper%TYPE --> Codigo da cooperativa)  
                             ,pr_nmrotina     IN VARCHAR2              --> Nome da rotina que esta gerando log
                             ,pr_dsdolog      IN VARCHAR2) IS          --> Descrição do log
  /* ..........................................................................
    
      Programa : pc_gera_log_npc        
      Sistema  : Conta-Corrente - Cooperativa de Credito
      Sigla    : CRED
      Autor    : Odirlei Busana(Amcom)
      Data     : Agosto/2017.                   Ultima atualizacao: 
    
      Dados referentes ao programa:
    
      Frequencia: Sempre que for chamado
      Objetivo  : Rotina para gerar log das rotinas NPC
      Alteração : 
        
    ..........................................................................*/
    -----------> CURSORES <-----------
    ----------> VARIAVEIS <-----------

  BEGIN   
            
    BTCH0001.pc_gera_log_batch( pr_cdcooper     => pr_cdcooper
                               ,pr_ind_tipo_log => 2 -- Erro tratato
                               ,pr_des_log      => to_char(sysdate,'DD/MM/YYYY - HH24:MI:SS')||' - '
                                                || pr_nmrotina ||' --> '
                                                || pr_dsdolog
                               ,pr_nmarqlog     => vr_dsarqlg);
  EXCEPTION 
    WHEN OTHERS THEN
      NULL;      
  END pc_gera_log_npc;
  
  --> Rotina para pre-validação do boleto na Nova plataforma de cobrança 
  PROCEDURE pc_valid_titulo_npc ( pr_cdcooper     IN crapcop.cdcooper%TYPE --> Codigo da cooperativa
                                 ,pr_dtmvtolt     IN crapdat.dtmvtolt%TYPE --> Data de movimento
                                 ,pr_cdctrlcs     IN tbcobran_consulta_titulo.cdctrlcs%TYPE --> Numero de controle da consulta no NPC
                                 ,pr_tbtitulocip  IN NPCB0001.typ_reg_titulocip --> Registro com os dados do titulo
                                 ,pr_flcontig     IN INTEGER DEFAULT 0     --> Indicador de contigencia     
                                 ,pr_cdcritic    OUT INTEGER               --> Codigo da critico
                                 ,pr_dscritic    OUT VARCHAR2              --> Descrição da critica
                                 ) IS
  /* ..........................................................................
    
      Programa : pc_valid_titulo_npc        
      Sistema  : Conta-Corrente - Cooperativa de Credito
      Sigla    : CRED
      Autor    : Odirlei Busana(Amcom)
      Data     : Dezembro/2016.                   Ultima atualizacao: 04/09/2017
    
      Dados referentes ao programa:
    
      Frequencia: Sempre que for chamado
      Objetivo  : Rotina para pre-validação do boleto na Nova plataforma de cobrança 
      Alteração : 
      
      04/09/2017 - Verificar se a data do pagamento excedeu ao próximo dia util
                   da data limite de pagamento. (SD#747481 - Rafael).
        
    ..........................................................................*/
    -----------> CURSORES <-----------
    --> Buscar dados da consulta
    CURSOR cr_cons_titulo (pr_cdctrlcs IN tbcobran_consulta_titulo.cdctrlcs%TYPE ) IS
      SELECT con.dsxml
             ,con.vltitulo 
             ,con.dscodbar
             ,con.flgcontingencia 
        FROM tbcobran_consulta_titulo con
       WHERE con.cdctrlcs = pr_cdctrlcs;
       
    rw_cons_titulo cr_cons_titulo%ROWTYPE;
    
    ----------> VARIAVEIS <-----------
    vr_xmltitulo      XMLTYPE;
    vr_tbtitulo       NPCB0001.typ_reg_TituloCIP;
    
    vr_dscritic       VARCHAR2(4000);
    vr_des_erro       VARCHAR2(3);
    vr_cdcritic       INTEGER;
    
    vr_SitTitPg_npc   INTEGER;
    vr_DtLimPgt_npc   DATE;
    vr_IdBloqPg_npc   VARCHAR2(10);
    vr_vlcontig       NUMBER;
    vr_de_campo       NUMBER;
    vr_dtvencto       DATE;
    
    
  BEGIN     
  
    -- Se não foram recebidos as informações no registro
    IF pr_tbtitulocip.NumCtrlPart IS NULL THEN
      --> Buscar dados da consulta
      OPEN cr_cons_titulo (pr_cdctrlcs => pr_cdctrlcs);
      FETCH cr_cons_titulo INTO rw_cons_titulo;
      
      IF cr_cons_titulo%NOTFOUND THEN
        CLOSE cr_cons_titulo;
        vr_dscritic := 'Não foi possivel localizar consulta NPC '||pr_cdctrlcs;    
        RAISE vr_exc_erro;  
      ELSE
        CLOSE cr_cons_titulo;
      END IF;
      
      --> Apenas se não for contigencia
      IF pr_flcontig <> 1 THEN
      
        BEGIN
          -- Criar um XMLTYPE à partir do CLOB retornado
          vr_xmltitulo := xmltype.createxml(rw_cons_titulo.dsxml);
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao ler XML do titulo: '||pr_cdctrlcs;
            RAISE vr_exc_erro; 
        END;
      
       BEGIN
          -- BLOCO PARA TRATAR ERROS DE LEITURA DE XML - CASO ROTINA SAIA VIA EXCEPTION OTHERS
    
          --> Rotina para retornar dados do XML para temptable
          NPCB0003.pc_xmlsoap_extrair_titulo(pr_dsxmltit => vr_xmltitulo.getClobVal()
                                            ,pr_tbtitulo => vr_tbtitulo
                                            ,pr_des_erro => vr_des_erro
                                            ,pr_dscritic => vr_dscritic);
      
          -- Se for retornado um erro
          IF vr_des_erro = 'NOK' THEN
            RAISE vr_exc_erro; 
          END IF;    
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao validar titulo CIP: '||pr_cdctrlcs;
            RAISE vr_exc_erro; 
        END;
      END IF;
      
    ELSE
      -- Utiliza as informações recebidas por parametro
      vr_tbtitulo := pr_tbtitulocip;
    END IF;
    
    --> Se estiver em contigencia somente precisar
    IF pr_flcontig = 1 THEN
      vr_vlcontig := fn_vlcontig_cip(pr_cdcooper => pr_cdcooper);
      
      --> Validar valor limite de contigencia
      IF rw_cons_titulo.vltitulo > vr_vlcontig THEN
        vr_dscritic := 'Sistema temporariamente indisponível para pagamento de boleto de '||
                       'valor superior a R$'||to_char(vr_vlcontig,'fm999G999G990D00')||'.';
        RAISE vr_exc_erro;
      END IF;
      
      vr_de_campo     := SUBSTR(rw_cons_titulo.dscodbar,6,4);
      cxon0014.pc_calcula_data_vencimento 
                            ( pr_dtmvtolt => pr_dtmvtolt
                             ,pr_de_campo => vr_de_campo
                             ,pr_dtvencto => vr_dtvencto
                             ,pr_cdcritic => vr_cdcritic          -- Codigo da Critica
                             ,pr_dscritic => vr_dscritic);        -- Descricao da Critica
      
      
      --> Verificar se o boleto excedeu a data limite de pagto
      IF nvl(vr_dtvencto,SYSDATE-365) < pr_dtmvtolt THEN
        vr_dscritic := 'Atenção boleto vencido: Sistema temporariamente indisponível para esta operação.';
        RAISE vr_exc_erro;
      END IF;
      
      --> Não precisa realizar demais validações
      RETURN;
    
    END IF;
        
    ----------> VALIDACOES <---------
    vr_SitTitPg_npc := vr_tbtitulo.SitTitPgto;
    vr_DtLimPgt_npc := vr_tbtitulo.DtLimPgtoTit;
    vr_IdBloqPg_npc := vr_tbtitulo.IndrBloqPgto;
    
         
    IF vr_tab_SitTitPgto_NPC.exists(vr_SitTitPg_npc) THEN
      IF vr_tab_SitTitPgto_NPC(vr_SitTitPg_npc).flgpagto = 0 THEN
        vr_dscritic := nvl(vr_tab_SitTitPgto_NPC(vr_SitTitPg_npc).dscritic,'Situacao do titulo da NPC invalida.');
        RAISE vr_exc_erro;
      END IF;     
    ELSE
      vr_dscritic := 'Situacao do titulo da NPC invalida.';
      RAISE vr_exc_erro;
    END IF;
    
    --> Verificar se o boleto excedeu a data limite de pagto
    vr_DtLimPgt_npc := gene0005.fn_valida_dia_util( pr_cdcooper  => pr_cdcooper, 
                                                    pr_dtmvtolt  => vr_DtLimPgt_npc, 
                                                    pr_tipo      => 'P');    
    IF vr_DtLimPgt_npc < pr_dtmvtolt THEN
		  vr_dscritic := 'Boleto excedeu a data limite de pagamento.';
      RAISE vr_exc_erro;
    END IF;
    
    --> Verificar se titulo esta bloqueado  
		IF vr_IdBloqPg_npc = 'S' THEN
      vr_dscritic := 'Boleto bloqueado.';
      RAISE vr_exc_erro;
    END IF;
    	  
    
  EXCEPTION 
    WHEN vr_exc_erro THEN
    
      IF vr_cdcritic <> 0 AND 
         TRIM(vr_dscritic) IS NULL THEN
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      END IF;  
      
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      
    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_dscritic := 'Nao foi possivel validar titulo NPC: '||SQLERRM;  
  END pc_valid_titulo_npc;  
  
  --> Validar se valor esta entre maximo e minimo
  FUNCTION fn_valid_max_min_valor (pr_vltitulo IN NUMBER   --> Valor do titulo
                                  ,pr_vldpagto IN NUMBER   --> Valor do pagamento
                                  ,pr_tpmaxpgt IN VARCHAR2 --> Tipo de calculo valor maximo(P-Percentual, V-Valor)
                                  ,pr_vlmaxpgt IN NUMBER   --> Valor maximo de pagamento
                                  ,pr_tpminpgt IN VARCHAR2 --> Tipo de calculo valor maximo(P-Percentual, V-Valor)
                                  ,pr_vlminpgt IN NUMBER   --> Valor maximo de pagamento
                                   ) RETURN INTEGER IS --1-OK, 0-NOK
  
  /* ..........................................................................
    
      Programa : fn_valid_max_min_valor        
      Sistema  : Conta-Corrente - Cooperativa de Credito
      Sigla    : CRED
      Autor    : Odirlei Busana(Amcom)
      Data     : Dezembro/2016.                   Ultima atualizacao: 16/12/2016
    
      Dados referentes ao programa:
    
      Frequencia: Sempre que for chamado
      Objetivo  : Validar se valor esta entre maximo e minimo
      Alteração : 
        
    ..........................................................................*/
    -----------> CURSORES <-----------
    ----------> VARIAVEIS <-----------
  
    vr_vlmaxpgt   NUMBER;
    vr_vlminpgt   NUMBER;
    
  BEGIN
  
    vr_vlmaxpgt := pr_vlmaxpgt;
    IF pr_tpmaxpgt = 'P' THEN
      vr_vlmaxpgt := pr_vltitulo /100*pr_vlmaxpgt;      
    END IF;
    
    vr_vlminpgt := pr_vlminpgt;
    IF pr_tpminpgt = 'P' THEN
      vr_vlminpgt := pr_vltitulo /100*pr_vlminpgt;      
    END IF;
  
    IF pr_vldpagto BETWEEN vr_vlminpgt AND  vr_vlmaxpgt THEN
      RETURN 1; --Está entre valor maximo e minimo
    END IF;
  
    RETURN 0;
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20501,'Erro ao validar valor max. e min.: '||SQLERRM);
  END fn_valid_max_min_valor;
  
  --> Rotina para retornar valor do titulo calculado pela NPC
  FUNCTION fn_valor_calc_titulo_npc( pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE --> Data de movimento                                                                   
                                    ,pr_tbtitulo  IN typ_reg_TituloCIP     --> Regras de calculo de juros                                 
                                    ) RETURN NUMBER IS --> Retornar valor que deve ser cobrado conforme a data de pagamentp  
  
  /* ..........................................................................
    
      Programa : fn_valor_calc_titulo_npc        
      Sistema  : Conta-Corrente - Cooperativa de Credito
      Sigla    : CRED
      Autor    : Odirlei Busana(Amcom)
      Data     : Dezembro/2016.                   Ultima atualizacao: 16/12/2016
    
      Dados referentes ao programa:
    
      Frequencia: Sempre que for chamado
      Objetivo  : Rotina para retornar valor do titulo calculado pela NPC
      Alteração : 
        
    ..........................................................................*/
  
    vr_VlrTotCobrar  NUMBER;
    vr_VlrCalcdJuros NUMBER;
    vr_VlrCalcdMulta NUMBER;
    vr_VlrCalcdDesct NUMBER;
  
  BEGIN
    
    -- Chamar a rotina para buscar os valores
    pc_valor_calc_titulo_npc(pr_dtmvtolt  => pr_dtmvtolt
                            ,pr_tbtitulo  => pr_tbtitulo
                            ,pr_vlrtitulo => vr_VlrTotCobrar  
                            ,pr_vlrjuros  => vr_VlrCalcdJuros 
                            ,pr_vlrmulta  => vr_VlrCalcdMulta 
                            ,pr_vlrdescto => vr_VlrCalcdDesct );
    
    -- Retorna apenas o valor calculado
    RETURN vr_VlrTotCobrar;
    
  END;
  
  --> Rotina para retornar valor do titulo calculado pela NPC e demais valores
  PROCEDURE pc_valor_calc_titulo_npc(pr_dtmvtolt   IN crapdat.dtmvtolt%TYPE --> Data de movimento
                                    ,pr_tbtitulo   IN typ_reg_TituloCIP     --> Regras de calculo de juros 
                                    ,pr_vlrtitulo OUT NUMBER       --> Retornar valor conforme a data de pagamento
                                    ,pr_vlrjuros  OUT NUMBER       --> Retornar os juros conforme a data de pagamento
                                    ,pr_vlrmulta  OUT NUMBER       --> Retornar os multa conforme a data de pagamento
                                    ,pr_vlrdescto OUT NUMBER ) IS  --> Retornar os desconto conforme a data de pagamento
                                    
  /* ..........................................................................
    
      Programa : pc_valor_calc_titulo_npc        
      Sistema  : Conta-Corrente - Cooperativa de Credito
      Sigla    : CRED
      Autor    : Odirlei Busana(Amcom)
      Data     : Janeiro/2017.                   Ultima atualizacao: --/--/----
    
      Dados referentes ao programa:
    
      Frequencia: Sempre que for chamado
      Objetivo  : Rotina para retornar os valores do titulo calculado pela NPC
      Alteração : 
        
    ..........................................................................*/
    
    vr_VlrTotCobrar  NUMBER;
    vr_VlrCalcdJuros NUMBER;
    vr_VlrCalcdMulta NUMBER;
    vr_VlrCalcdDesct NUMBER;
    vr_dtValiddCalc  DATE := to_date('25/04/2049','DD/MM/RRRR'); -- RC7
    vr_data DATE;
  BEGIN    
    
    IF pr_tbtitulo.TabCalcTit.count <> 0 THEN
      FOR idx IN pr_tbtitulo.TabCalcTit.first..pr_tbtitulo.TabCalcTit.last LOOP
        
      vr_data := pr_tbtitulo.TabCalcTit(idx).dtValiddCalc;
      
        --> utilizar o valor se a data do movimento for menor que a dta de validade
        --> e se for a menor data encontrada.. caso a temptable nao esteja ordenada
        IF pr_dtmvtolt <= pr_tbtitulo.TabCalcTit(idx).dtValiddCalc    AND 
           pr_tbtitulo.TabCalcTit(idx).dtValiddCalc < vr_dtValiddCalc THEN 
          vr_VlrTotCobrar  := pr_tbtitulo.TabCalcTit(idx).VlrTotCobrar;
          vr_dtValiddCalc  := pr_tbtitulo.TabCalcTit(idx).dtValiddCalc; 
          vr_VlrCalcdJuros := pr_tbtitulo.TabCalcTit(idx).VlrCalcdJuros;
          vr_VlrCalcdMulta := pr_tbtitulo.TabCalcTit(idx).VlrCalcdMulta;
          vr_VlrCalcdDesct := pr_tbtitulo.TabCalcTit(idx).VlrCalcdDesct;
        END IF;
      
      END LOOP;
      
    END IF;
    
    -- Retornar os valores encontrados
    pr_vlrtitulo := nvl(vr_VlrTotCobrar,pr_tbtitulo.VlrTit); -- RC7
    pr_vlrjuros  := vr_VlrCalcdJuros;
    pr_vlrmulta  := vr_VlrCalcdMulta;
    pr_vlrdescto := vr_VlrCalcdDesct;
    
  END pc_valor_calc_titulo_npc;  
  
  --> Rotina para validação do pagamento do boleto na Nova plataforma de cobrança 
  PROCEDURE pc_valid_pagamento_npc (pr_cdcooper     IN crapcop.cdcooper%TYPE --> Codigo da cooperativa
                                   ,pr_dtmvtolt     IN crapdat.dtmvtolt%TYPE --> Data de movimento                                   
                                   ,pr_cdctrlcs     IN tbcobran_consulta_titulo.cdctrlcs%TYPE --> Numero de controle da consulta no NPC
                                   ,pr_dtagenda     IN craptit.dtdpagto%TYPE --> Data de agendamento
                                   ,pr_vldpagto     IN craptit.vldpagto%TYPE --> Valor a ser pago
                                   ,pr_vltitulo    OUT craptit.vltitulo%TYPE --> Valor do titulo
                                   ,pr_nridenti    OUT NUMBER                --> Retornar numero de identificacao do titulo
                                   ,pr_tpdbaixa    OUT INTEGER               --> Retornar tipo de baixa
                                   ,pr_flcontig    OUT INTEGER               --> Retornar inf que a CIP esta em modo de contigencia
                                   ,pr_cdcritic    OUT INTEGER               --> Codigo da critico
                                   ,pr_dscritic    OUT VARCHAR2              --> Descrição da critica
                                   ) IS
  /* ..........................................................................
    
      Programa : pc_valid_pagamento_npc        
      Sistema  : Conta-Corrente - Cooperativa de Credito
      Sigla    : CRED
      Autor    : Odirlei Busana(Amcom)
      Data     : Dezembro/2016.                   Ultima atualizacao: 12/07/2017
    
      Dados referentes ao programa:
    
      Frequencia: Sempre que for chamado
      Objetivo  : Rotina para validação do pagamento do boleto na Nova plataforma de cobrança 
      Alteração : 12/07/2017 - Alterado parametro de data da procedure fn_valor_calc_titulo_npc
                               para correção de pagamentos DDA, Prj. 340 - NPC (Jean Michel)
        
    ..........................................................................*/
    -----------> CURSORES <-----------
    --> Buscar dados da consulta
    CURSOR cr_cons_titulo (pr_cdctrlcs IN tbcobran_consulta_titulo.cdctrlcs%TYPE ) IS
      SELECT con.dsxml
            ,con.dtmvtolt
            ,con.vltitulo
            ,con.dscodbar
            ,con.flgcontingencia
        FROM tbcobran_consulta_titulo con
       WHERE con.cdctrlcs = pr_cdctrlcs;
       
    rw_cons_titulo cr_cons_titulo%ROWTYPE;
    
    ----------> VARIAVEIS <-----------
    vr_des_erro       VARCHAR2(3);
    vr_dscritic       VARCHAR2(4000);
    vr_cdcritic       INTEGER;
    
    vr_vltitcal       craptit.vltitulo%TYPE;
    vr_tituloCIP      typ_reg_TituloCIP;
    vr_dtvencto       DATE;
    vr_de_campo       NUMBER;
    
  BEGIN     
  
    --> Buscar dados da consulta
    OPEN cr_cons_titulo (pr_cdctrlcs => pr_cdctrlcs);
    FETCH cr_cons_titulo INTO rw_cons_titulo;
    
    IF cr_cons_titulo%NOTFOUND THEN
      CLOSE cr_cons_titulo;
      vr_dscritic := 'Não foi possivel localizar consulta NPC '||pr_cdctrlcs;    
      RAISE vr_exc_erro;  
    ELSE
      CLOSE cr_cons_titulo;
    END IF;
    
    --> Setar contigencia
    pr_flcontig := rw_cons_titulo.flgcontingencia; 
    
    --> Somente ler  dados do xml se nao estiver em contigencia
    IF pr_flcontig <> 1 THEN    
      --> Rotina para retornar dados do XML para temptable
      NPCB0003.pc_xmlsoap_extrair_titulo(pr_dsxmltit => rw_cons_titulo.dsxml
                                        ,pr_tbtitulo => vr_tituloCIP
                                        ,pr_des_erro => vr_des_erro
                                        ,pr_dscritic => vr_dscritic);
    
      -- Se houve retorno de erro
      IF vr_dscritic IS NOT NULL OR vr_des_erro = 'NOK' THEN	  
        RAISE vr_exc_erro;       
      END IF;  
    ELSE
      --> Calcular vencimento em cima do codigo de barras
      vr_de_campo     := SUBSTR(rw_cons_titulo.dscodbar,6,4);
      cxon0014.pc_calcula_data_vencimento 
                            ( pr_dtmvtolt => pr_dtmvtolt
                             ,pr_de_campo => vr_de_campo
                             ,pr_dtvencto => vr_tituloCIP.DtVencTit
                             ,pr_cdcritic => vr_cdcritic          -- Codigo da Critica
                             ,pr_dscritic => vr_dscritic);        -- Descricao da Critica
    
      vr_tituloCIP.VlrTit := rw_cons_titulo.vltitulo;      
      vr_tituloCIP.TpAutcRecbtVlrDivgte := 1; -- qlqr valor 
      
      IF pr_dtagenda IS NOT NULL THEN
        vr_dscritic := 'Sistema temporariamente indisponível para esta operação.';
        RAISE vr_exc_erro;      
      END IF;
      
    
    END IF;
     
    ----------> VALIDACOES <---------
    
    --> Pre-validação do boleto na Nova plataforma de cobrança 
    pc_valid_titulo_npc ( pr_cdcooper    => pr_cdcooper   --> Codigo da cooperativa
                         ,pr_dtmvtolt    => pr_dtmvtolt   --> Data de movimento
                         ,pr_cdctrlcs    => pr_cdctrlcs   --> Numero de controle da consulta no NPC
                         ,pr_tbtitulocip => vr_tituloCIP  --> Dados consultados na CIP
                         ,pr_flcontig    => pr_flcontig   --> Indicativo de contigencia
                         ,pr_cdcritic    => vr_cdcritic   --> Codigo da critico
                         ,pr_dscritic    => vr_dscritic); --> Descrição da critica
                         
    IF vr_dscritic IS NOT NULL OR
       nvl(vr_cdcritic,0) <> 0 THEN	  
      RAISE vr_exc_erro;       
    END IF;  
    
    pr_nridenti := vr_tituloCIP.NumIdentcTit;
    pr_vltitulo := vr_tituloCIP.VlrTit;
    
    --FOR idx IN vr_tab_TituloCIP.first..vr_tab_TituloCIP.last LOOP
    
    --> Verificar se o valor para pagamento está de acordo com as regras NPC:
      
    --> Se o boleto permite pagto divergente 
      
    CASE vr_tituloCIP.TpAutcRecbtVlrDivgte
      WHEN 1 THEN --> 1 - qualquer valor
        --> não precisará verificar se o boleto é a vencer ou vecido,simplesmente acata o valor do pagamento;
        NULL;
          
      WHEN 2 THEN --> 2 - entre o mínimo e o máximo   
        --> Validar se valor esta entre maximo e minimo
        IF 0 = fn_valid_max_min_valor 
                                (pr_vltitulo => vr_tituloCIP.VlrTit             --> Valor do titulo
                                ,pr_vldpagto => pr_vldpagto                              --> Valor do pagamento
                                ,pr_tpmaxpgt => vr_tituloCIP.IndrVlr_PercMaxTit --> Tipo de calculo valor maximo(P-Percentual, V-Valor)
                                ,pr_vlmaxpgt => vr_tituloCIP.Vlr_PercMaxTit     --> Valor maximo de pagamento
                                ,pr_tpminpgt => vr_tituloCIP.IndrVlr_PercMinTit --> Tipo de calculo valor maximo(P-Percentual, V-Valor)
                                ,pr_vlminpgt => vr_tituloCIP.Vlr_PercMinTit     --> Valor maximo de pagamento
                                 ) THEN
          vr_dscritic := 'Valor não permitido para pagamento.';
          RAISE vr_exc_erro;
        END IF;  
          
      WHEN 3 THEN --> 3 -- não aceita pagar valor divergente;
        --> Retornar valor do titulo calculado pela NPC
        vr_vltitcal := fn_valor_calc_titulo_npc
                                 ( pr_dtmvtolt  => rw_cons_titulo.dtmvtolt --> Data de movimento                                                                   
                                  ,pr_tbtitulo  => vr_tituloCIP);          --> Regras de calculo de juros                                 
                                    
        --> Se valor estiver diferente retornar critica		
        IF vr_vltitcal IS NULL THEN
          vr_dscritic := 'Problemas ao buscar valor do titulo.';
          RAISE vr_exc_erro;
        ELSIF pr_vldpagto < vr_vltitcal THEN
          vr_dscritic := 'Cob. Reg. - Valor informado '||
                         to_char(pr_vldpagto, 'fm999g999g990d00')||
                         ' menor que valor doc. '|| to_char(vr_vltitcal,'fm999g999g990D00');
          RAISE vr_exc_erro;               
          
        END IF;
		
		
          
      WHEN 4 THEN --> 2 - Somente valor mínimo
        --> Validar se valor esta entre maximo e minimo
        IF 0 = fn_valid_max_min_valor 
                                (pr_vltitulo => vr_tituloCIP.VlrTit             --> Valor do titulo
                                ,pr_vldpagto => pr_vldpagto                              --> Valor do pagamento
                                ,pr_tpmaxpgt => 'V'                                      --> Tipo de calculo valor maximo(P-Percentual, V-Valor)
                                ,pr_vlmaxpgt => vr_tituloCIP.VlrTit             --> Valor maximo de pagamento
                                ,pr_tpminpgt => vr_tituloCIP.IndrVlr_PercMinTit --> Tipo de calculo valor maximo(P-Percentual, V-Valor)
                                ,pr_vlminpgt => vr_tituloCIP.Vlr_PercMinTit     --> Valor maximo de pagamento
                                 ) THEN
          vr_dscritic := 'Valor não permitido para pagamento.';
          RAISE vr_exc_erro;
        END IF;  
    END CASE;   
      
    vr_dtvencto := gene0005.fn_valida_dia_util( pr_cdcooper  => pr_cdcooper, 
                                                pr_dtmvtolt  => vr_tituloCIP.DtVencTit, 
                                                pr_tipo      => 'P');
    
    --> verificar se for agendamento, se a data está dentro do prazo de vencimento
    IF pr_dtagenda IS NOT NULL AND pr_dtagenda > vr_dtvencto THEN
      vr_dscritic := 'Agendamento posterior ao vencimento não permitido.';
      RAISE vr_exc_erro;
    END IF;
    
    
    --> DEFINIR BAIXA OPERACIONAL
    --> Verificar se boleto possui valor de saldo
    IF vr_tituloCIP.VlrSldTotAtlPgtoTit > 0 THEN
 
      IF pr_vldpagto >= vr_tituloCIP.VlrSldTotAtlPgtoTit THEN
        IF substr(vr_tituloCIP.NumCodBarras,1,3) <> '085' THEN
          pr_tpdbaixa := 0; -- Baixa Operacional Integral Interbancária
        ELSE
          pr_tpdbaixa := 1; -- Baixa Operacional Integral Intrabancária
        END IF;
        
      ELSE
        IF substr(vr_tituloCIP.NumCodBarras,1,3) <> '085' THEN
          pr_tpdbaixa := 2; -- Baixa Operacional Parcial Interbancária
        ELSE
          pr_tpdbaixa := 3; -- Baixa Operacional Parcial Intrabancária
        END IF;        
      END IF;   
           
    ELSE
      IF substr(vr_tituloCIP.NumCodBarras,1,3) <> '085' THEN
        pr_tpdbaixa := 0; -- Baixa Operacional Integral Interbancária
      ELSE
        pr_tpdbaixa := 1; -- Baixa Operacional Integral Intrabancária
      END IF;      
    END IF;
     
    --END LOOP;
  EXCEPTION 
    WHEN vr_exc_erro THEN
    
      IF vr_cdcritic <> 0 AND 
         TRIM(vr_dscritic) IS NULL THEN
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      END IF;  
      
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      
    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_dscritic := 'Nao foi possivel validar pagamento do titulo NPC: '||SQLERRM;  
  END pc_valid_pagamento_npc;  
  
  --> Rotina para retornar o codigo do canal de pagamento do NPC
  FUNCTION fn_canal_pag_NPC( pr_cdagenci     IN crapage.cdagenci%TYPE --> Codigo da agencia
                            ,pr_idtitdda     IN INTEGER               --> Indicador se foi pago pelo sistema de DDDA
                            ) RETURN INTEGER IS --> Retornar codigo do canal de pagamento no NPC
  
  
  /* ..........................................................................
    
      Programa : fn_canal_pag_NPC        
      Sistema  : Conta-Corrente - Cooperativa de Credito
      Sigla    : CRED
      Autor    : Odirlei Busana(Amcom)
      Data     : Dezembro/2016.                   Ultima atualizacao: 16/12/2016
    
      Dados referentes ao programa:
    
      Frequencia: Sempre que for chamado
      Objetivo  : Rotina para retornar o codigo do canal de pagamento do NPC
      Alteração : 
        
    ..........................................................................*/
        
    
  BEGIN    
    
    /* DOMINIO: Canal Pagamento. 
        1 – Agencias – Posto tradicionais
        2 – Terminal de Auto-Atendimento
        3 – Internet (home/office banking)
        5 – Correspondente Bancário
        6 – Central de Atendimento (call center)
        7 – Arquivo Eletronico
        8 – DDA */
        
    IF nvl(pr_idtitdda,0) > 0 THEN
      RETURN 8; --> DDA
    
    ELSE
      CASE pr_cdagenci 
        WHEN 91 THEN RETURN 2; --> Terminal de Auto-Atendimento
        WHEN 90 THEN RETURN 3; --> Internet (home/office banking)
        ELSE RETURN 1; --> Agencias – Posto tradicionais
      END CASE;  
    END IF;
    
    RETURN 1;
  
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20500,'Erro ao identificar canal NPC: '||SQLERRM);
  END fn_canal_pag_NPC;    
  
  --> Rotina para retornar se NPC esta em contigencia
  FUNCTION fn_contigencia_NPC ( pr_cdcooper   IN INTEGER, --> Codigo da cooperativa
                                pr_idorigem   IN INTEGER  --> Origem da transacao
                              ) RETURN VARCHAR2 IS --> Retornar S-Em contigencia, N-Não esta em contigencia
  
  
  /* ..........................................................................
    
      Programa : fn_contigencia_NPC        
      Sistema  : Conta-Corrente - Cooperativa de Credito
      Sigla    : CRED
      Autor    : Odirlei Busana(Amcom)
      Data     : Maio/2017.                   Ultima atualizacao: 
    
      Dados referentes ao programa:
    
      Frequencia: Sempre que for chamado
      Objetivo  : Rotina para retornar se NPC esta em contigencia
      Alteração : 
        
    ..........................................................................*/
    vr_exc_erro  EXCEPTION;
    vr_dscritic  VARCHAR2(1000);
    vr_cdacesso  VARCHAR2(100);
    
  BEGIN    
  
    SELECT CASE pr_idorigem
             WHEN 3  THEN 'FLGPAGCONT_IB'
             WHEN 4  THEN 'FLGPAGCONT_TAA'
             WHEN 2  THEN 'FLGPAGCONT_CX'
             WHEN 10 THEN 'FLGPAGCONT_MOB'
             ELSE
               NULL
           END  
      INTO vr_cdacesso
      FROM dual;
      
    IF TRIM(vr_cdacesso) IS NULL THEN
      vr_dscritic := 'Origem da transação invalido';
    END IF;
   
    RETURN tabe0001.fn_busca_dstextab( pr_cdcooper => pr_cdcooper
                                      ,pr_nmsistem => 'CRED'
                                      ,pr_tptabela => 'GENERI'
                                      ,pr_cdempres => 0
                                      ,pr_cdacesso => vr_cdacesso
                                      ,pr_tpregist => 0);
  
  
  EXCEPTION
    WHEN vr_exc_erro THEN
      raise_application_error(-20500,'Erro ao verificar contigencia NPC: '||vr_dscritic);
    WHEN OTHERS THEN
      raise_application_error(-20500,'Erro ao verificar contigencia NPC: '||SQLERRM);
  END fn_contigencia_NPC;  
  
  
BEGIN

  --> Carregar temptable com as situações dos titulos no NPC
  IF vr_tab_SitTitPgto_NPC.count() = 0 THEN
      
    --> Boleto já baixado
    vr_tab_SitTitPgto_NPC(01).dssituac := 'Boleto já baixado';
    vr_tab_SitTitPgto_NPC(01).dscritic := 'Boleto já baixado';
    vr_tab_SitTitPgto_NPC(01).flgpagto := 0;
      
    --> Boleto bloqueado para pagamento
    vr_tab_SitTitPgto_NPC(02).dssituac := 'Boleto bloqueado para pagamento';
    vr_tab_SitTitPgto_NPC(02).dscritic := 'Boleto bloqueado';
    vr_tab_SitTitPgto_NPC(02).flgpagto := 0;
				
    --> 03	Boleto encontrado na base centralizada e Cliente Beneficiário inapto na Instituição emissora do título.
    vr_tab_SitTitPgto_NPC(03).dssituac := 'Boleto encontrado na base centralizada e Cliente Beneficiário inapto na Instituição emissora do título.';
    vr_tab_SitTitPgto_NPC(03).dscritic := 'Boleto não permitido para pagamento';
    vr_tab_SitTitPgto_NPC(03).flgpagto := 0;
			
    --> 04	Boleto encontrado na base e cliente Beneficiário sem cadastro
    vr_tab_SitTitPgto_NPC(04).dssituac := 'Boleto encontrado na base e cliente Beneficiário sem cadastro';
    vr_tab_SitTitPgto_NPC(04).dscritic := 'Boleto não permitido para pagamento';
    vr_tab_SitTitPgto_NPC(04).flgpagto := 0;
      
    --> 05 Boleto encontrado na base centralizada e Cliente Beneficiário em análise na Instituição emissora do título
    vr_tab_SitTitPgto_NPC(05).dssituac := 'Boleto encontrado na base centralizada e Cliente Beneficiário em análise na Instituição emissora do título';
    vr_tab_SitTitPgto_NPC(05).dscritic := NULL;
    vr_tab_SitTitPgto_NPC(05).flgpagto := 1;
			
    --> 06	Boleto excedeu o limite de pagamentos parciais
    vr_tab_SitTitPgto_NPC(06).dssituac := 'Boleto excedeu o limite de pagamentos parciais';
    vr_tab_SitTitPgto_NPC(06).dscritic := 'Boleto excedeu o limite de pagamentos parciais';
    vr_tab_SitTitPgto_NPC(06).flgpagto := 0;
			
    --> 07	Baixa operacional em duplicidade para título que não permite pagamento parcial
    vr_tab_SitTitPgto_NPC(07).dssituac := 'Baixa operacional integral já registrada';
    vr_tab_SitTitPgto_NPC(07).dscritic := 'Pagamento já registrado';
    vr_tab_SitTitPgto_NPC(07).flgpagto := 0;
      
    --> 08	Baixa operacional já registrada para título que não permite pagamento parcial
    vr_tab_SitTitPgto_NPC(08).dssituac := 'Baixa operacional já registrada para título que não permite pagamento parcial';
    vr_tab_SitTitPgto_NPC(08).dscritic := 'Boleto pago pendente de processamento';
    vr_tab_SitTitPgto_NPC(08).flgpagto := 0;
			
    --> 09	Boleto excedeu o valor de saldo para pagamento parcial para o tipo de modelo de cálculo 04
    vr_tab_SitTitPgto_NPC(09).dssituac := 'Boleto excedeu o valor de saldo para pagamento parcial para o tipo de modelo de cálculo 04';
    vr_tab_SitTitPgto_NPC(09).dscritic := NULL;
    vr_tab_SitTitPgto_NPC(09).flgpagto := 1;            
      
    --> 10	Boleto encontrado na base centralizada e Cliente Beneficiário inapto em Instituição diferente da emissora.
    vr_tab_SitTitPgto_NPC(10).dssituac := 'Boleto encontrado na base centralizada e Cliente Beneficiário inapto em Instituição diferente da emissora.';
    vr_tab_SitTitPgto_NPC(10).dscritic := 'Boleto não permitido para pagamento';
    vr_tab_SitTitPgto_NPC(10).flgpagto := 0;
      
    --> 11	Boleto encontrado na base centralizada e Cliente Beneficiário em análise em Instituição diferente da emissora.
    vr_tab_SitTitPgto_NPC(11).dssituac := 'Boleto encontrado na base centralizada e Cliente Beneficiário em análise em Instituição diferente da emissora.';
    vr_tab_SitTitPgto_NPC(11).dscritic := NULL;
    vr_tab_SitTitPgto_NPC(11).flgpagto := 1;
		
    --> 12	Boleto encontrado na base centralizada e Cliente Beneficiário apto.
    vr_tab_SitTitPgto_NPC(12).dssituac := 'Boleto encontrado na base centralizada e Cliente Beneficiário apto.';
    vr_tab_SitTitPgto_NPC(12).dscritic := NULL;
    vr_tab_SitTitPgto_NPC(12).flgpagto := 1;    
    
  END IF;    
  
END NPCB0001;
/
