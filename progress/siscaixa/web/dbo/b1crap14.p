/******************************************************************************
                ATENCAO!    CONVERSAO PROGRESS - ORACLE
           ESTE FONTE ESTA ENVOLVIDO NA MIGRACAO PROGRESS->ORACLE!
 +---------------------------------------+------------------------------------+
 | Rotina Progress                       | Rotina Oracle PLSQL                |
 +---------------------------------------+------------------------------------+
 | dbo/b1crap14.p                        | CXON0014                           |
 |  verifica_digito                      | CXON0014.pc_verifica_digito        |
 |  valida-codigo-barras                 | CXON0014.pc_valida_codigo_barras   |
 |  retorna-valores-fatura               | CXON0014.pc_retorna_valores_fatura |
 |  busca_sequencial_fatura              | CXON0014.pc_busca_sequencial_fatura|
 |  validacoes-sicredi                   | CXON0014.pc_validacoes_sicredi     |
 |  busca_sequencial_fatura              | CXON0014.pc_busca_sequencial_fatura|
 |  retorna-ano-cdbarras                 | CXON0014.fn_retorna_ano_cdbarras   |
 |  retorna-data-dias                    | CXON0014.fn_retorna_data_dias      |
 |  gera_faturas                         | CXON0014.pc_gera_faturas           |
 |  gera-recibo-darf                     | CXON0014.pc_gera_recibo_darf       |
 +---------------------------------------+------------------------------------+
  
 TODA E QUALQUER ALTERACAO EFETUADA NESSE FONTE A PARTIR DE 20/NOV/2012 DEVERA
 SER REPASSADA PARA ESTA MESMA ROTINA NO ORACLE, CONFORME DADOS ACIMA.
  
 PARA DETALHES DE COMO PROCEDER, FAVOR ENTRAR EM CONTATO COM AS SEGUINTES
 PESSOAS:
  - GUILHERME STRUBE    (CECRED)
  - MARCOS MARTINI      (SUPERO)

******************************************************************************/





/* ............................................................................
 
   Programa: siscaixa/web/dbo/b1crap14.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Mirtes.
   Data    : Marco/2001                      Ultima atualizacao: 26/05/2017

   Dados referentes ao programa:

   Frequencia: Diario (Caixa Online).
   Objetivo  : Tratar Arrecadacao de Faturas com codigo de barras

   Alteracoes: 22/04/2005 - Tratamento para Casa Feliz, nao aveitar faturas 
                            com data inferior a 17/10/2005 (Julio)

               02/05/2005 - Alteracao do historico da SAMAE Blumenau 
                            306 -> 644 (Julio)

               17/06/2005 - Tratamento para Aguas de Itapema -> 456 (Julio)
               
               13/09/2005 - Tratar Identificacao do segmento no codigo de 
                            barras (Pos. 2 - 2) (Julio)
                            
               28/10/2005 - Alterar tratamento de sequencial para CELESC (625)
                            (Julio)

               08/11/2005 - Alterar tratamento de sequencial para SAMAE
                            POMERODE -> 618 (Julio)
   
               12/01/2006 - Tratamento para P.M.Itajai -> 659 (Julio)

               03/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando.
               
               17/04/2006 - Tratamento para Casa Feliz, nao aceitar faturas 
                            com data inferior a 17/04/2005 (Julio)
                            
               11/08/2006 - Tratamento para P.M.Pomerode -> 663 (Julio)
               
               11/10/2006 - Tratamento para CELESC Distribuição -> 666 (Julio)
               
               31/01/2007 - Tratamento para DAE Navegantes -> 671 (Elton).
               
               09/02/2007 - Nao aceitar faturas de IPTU de Itajai que passarem
                            do prazo de vencimento (Elton).

               15/08/2007 - Alterado para usar a data com crapdat.dtmvtocd,
                            verificar pagamento da fatura sem considerar a
                            conta e tratamento para os erros da internet
                            (Evandro).
                            
               10/01/2008 - Tratamento para novo convênio da P.M.Blumenau
                            337 (Julio)              

               30/04/2008 - Validar digito verificador quando linha digitavel
                            for informada (David).

               19/05/2008 - Tratamento para SEMASA Itajai --> 675 (Elton).
               
               20/05/2009 - Alterar tratamento para verificacao de registros
                            que estao com EXCLUSIVE-LOCK (David).
                            
               14/06/2010 - Tratamento para convênio Aguas de Presidente 
                            Getulio --> 464;
                          - Tratamento para PA 91, conforme PA 90 (Elton).  
                          
               01/10/2010 - Tratamento para Samae Rio Negrinho --> 899 (Elton).
               
               20/10/2010 - Inclusao de parametros na procedure gera-faturas
                            (Vitor).
                            
               05/04/2011 - Tratamento para CERSAD -> 929 
                          - Tratamento para Foz do Brasil -> 963 
                          - Tratamento para Aguas de Massaranduba -> 964 (Elton).
                          
               20/01/2012 - Tratamento para codigo de barras com digito 
                            verificador no modulo 11 - GNRE 
                          - Tratamento para DARE -> 1063 e GNRE -> 1065 (Elton).
                          
               14/05/2012 - Acerto no campo craplft.nrseqfat da DARE -> 1063 e
                            GNRE -> 1065 para gravar 25 posicoes (Elton).
                            
               31/07/2012 - Critica para as faturas da Foz do Brasil que forem 
                            capturadas com problemas;
                          - Ajuste para que novos convenios nao necessitem 
                            de tratamento especifico (Elton).
                            
               08/02/2013 - Criado procedure busca_sequencial_fatura e 
                            incluso chamada da mesma na procdedure
                            retorna-valores-fatura (Daniel).  
                            
               20/02/2013 - Gravar campos cdempcon e cdsegmto da craplft
                            (Lucas).
               
               27/02/2013 - Incluir verificacao para so fazer modulo 11 se
                            crapcon.cdhistor = 1065 (Lucas R.)
                            
              18/04/2013 - Alterações para Validações e Pagamentos
                           de Conv. SICREDI (Lucas).
                           
              06/05/2013 - Não aceitar pagamentos de DAS (Lucas).
              
              21/05/2013 - Pagamento de DARFs (Lucas).
              
              22/05/2013 - Chamada procedure para de calculo de DV do
                           CPF/CNPJ nos Cod. Barras das DARFs e correção
                           comprovante (Lucas).
                           
              28/05/2013 - Cod. Seq. da Fatura aumentado para 40 posições
                           para DARFs (Lucas).
                           
              28/05/2013 - Correção dígito do CNPJ (Lucas).
              
              03/06/2013 - Validação para não aceitar DARFs menores
                           do que R$10,00 (Lucas).
                           
              11/06/2013 - Correções e considerar DARF NUMERADA como 
                           Tipo de Fatura 2, fazendo parte o arquivo 
                           .arf de exportação (Lucas).
                           
              27/08/2013 - Correção linha comprovante pagamento DARF NUMERADA (Lucas).
              
              14/10/2013 - Ajuste posicao do ano no cod. barras para DARF NUMERADA
                           e para DAS (Lucas).
              
              30/04/2014 - Ajuste migracao Oracle (Elton).

              29/05/2014 - Removido as validacoes para Sicredi (1154), Samae 
                           Jaragua (396), DARE Sefaz (1063). Alterado o tamanho do
                           substr do codigo de barras. (Douglas - Chamado 128278)

              09/06/2014 - Removido as validacoes para GNRE - SEFAZ (1065).
                           (Douglas - Chamado 128278)
                           
              05/08/2014 - Alteração da Nomeclatura para PA (Vanessa).
              
              25/11/2014 - Ajuste rotina para separar registros de Debaut e
                           registros de pagamento regular de convênios (Lunelli)
                           
              16/03/2015 - Adicionada validação por meio de arrecadação pelo 
                           campo crapscn.dsoparre para Conv. Sicredi (Lunelli SD 234418)
                           
              11/03/2015 - Adicionada verificação pelo dígito 8 no início do cdbarra
                           de faturas na rotina 'pc_retorna_valores_fatura' (Lunelli SD 245425).
                           
              23/03/2015 - Adicionado procedures calcula_dv_numero_das e
                           calcula_dv_adicional, para calcular os DV's
                           adicionais presentes no codigo de barras de guias
                           de DAS. (Chamado 230862) - (Fabricio)
                                                     
              01/06/2015 - Incluir validacao na procedure gera-faturas para nao 
                           aceitar pagamento da guia "DARF PRETO EUROPA" pois o 
                           sicredi não aceita esta guia (Lucas Ranghetti #289895)
                           
              03/06/2015 - Remover validacao para o convenio 963 Foz do brasil
                           (Lucas Ranghetti #292200)
                           
              27/07/2015 - #308980 Procedure retorna-valores-fatura - Valida o 
                           pagamento em duplicidade dos convenios SICREDI 
                           verificando os últimos 5 anos da craplft, assim como o
                           sicredi, que também valida os últimos 5 anos (Carlos)
              
              19/08/2015 - Incluido parametro par_tpcptdoc(1-leitora 2-linha digitave) 
                            na rotina gera-fatura (odirlei-AMcom)
                            
              23/11/2015 - Incluido Validate (Lucas Lunelli SD 338687).
                           
              05/05/2016 - Incluir transacao na criacao da craplft na procedure
                           gera-faturas (Lucas Ranghetti #436077)

			        13/01/2017 - Incluir chamada da procedure pc_ret_ano_barras_darf_car
                           para a nova regra de validacao das DARFs
                           (Lucas Ranghetti #588835)

              07/02/2017 - Ajustes para verificar vencimento da P.M. PRES GETULIO, 
			                     P.M. GUARAMIRIM e SANEPAR (Tiago/Fabricio SD593203)    
                           
             20/03/2017 - Ajuste para verificar vencimento da P.M. TIMBO, DEFESA CIVIL TIMBO  
                          MEIO AMBIENTE DE TIMBO, TRANSITO DE TIMBO (Lucas Ranghetti #630176)
                          
             07/02/2017 - Ajustes para verificar vencimento da P.M. TROMBUDO CENTRAL 
                          e FMS TROMBUDO CENTRAL (Tiago/Fabricio SD653830)

	         26/05/2017 - Ajustes para verificar vencimento da P.M. AGROLANDIA (Tiago/Fabricio #647174
           
           08/12/2017 - Melhoria 458, adicionado campo tppagmto na procedure gera-faturas
                        Antonio R. Jr (mouts)
	        			 
			 03/01/2018 - M307 Solicitação de senha e limite para pagamento (Diogo / MoutS)
............................................................................ */

{dbo/bo-erro1.i}

DEF VAR i-cod-erro         AS INTEGER.
DEF VAR c-desc-erro        AS CHAR.
                                           
DEF VAR de-valor-calc      AS DEC  NO-UNDO.
DEF VAR p-nro-digito       AS INTE NO-UNDO.
DEF VAR p-retorno          AS LOG  NO-UNDO.
DEF VAR i-nro-lote    LIKE craplft.nrdolote NO-UNDO.

DEF VAR h-b1crap00         AS HANDLE  NO-UNDO.

DEF VAR p-literal          AS CHAR  NO-UNDO.
DEF VAR p-ult-sequencia    AS INTE  NO-UNDO.
DEF var p-registro         AS RECID NO-UNDO.

DEF VAR aux_dtmvtoan       AS CHAR  NO-UNDO.

DEF   VAR h-b1wgen9998 AS HANDLE                                      NO-UNDO.

PROCEDURE valida-valor.

    DEF INPUT PARAM p-cooper       AS CHAR.
    DEF INPUT PARAM p-cod-agencia  AS INTE.
    DEF INPUT PARAM p-cod-caixa    AS INTE.
    DEF INPUT PARAM p-valor        AS DEC.
    
    FIND crapcop WHERE crapcop.nmrescop = p-cooper NO-LOCK NO-ERROR.

    RUN elimina-erro (INPUT p-cooper,
                      INPUT p-cod-agencia,
                      INPUT p-cod-caixa).
    IF p-valor = 0 THEN
    DO:
        ASSIGN i-cod-erro  = 0
               c-desc-erro = "Valor deve ser informado".
        RUN cria-erro (INPUT p-cooper,
                       INPUT p-cod-agencia,
                       INPUT p-cod-caixa,
                       INPUT i-cod-erro,
                       INPUT c-desc-erro,
                       INPUT YES).
        RETURN "NOK".
    END.

    RETURN "OK".

END PROCEDURE.

PROCEDURE valida-codigo-barras.
    DEF INPUT         PARAM p-cooper         AS CHAR                   NO-UNDO.
    DEF INPUT         PARAM p-nrdconta       LIKE crapttl.nrdconta     NO-UNDO.
    DEF INPUT         PARAM p-idseqttl       LIKE crapttl.idseqttl     NO-UNDO.
    DEF INPUT         PARAM p-cod-operador   AS CHAR                   NO-UNDO.
    DEF INPUT         PARAM p-cod-agencia    AS INTE                   NO-UNDO.
    DEF INPUT         PARAM p-nro-caixa      AS INTE                   NO-UNDO.
    DEF INPUT         PARAM p-codigo-barras  AS CHAR                   NO-UNDO.
    
    DEF                 VAR aux_nrdcaixa     LIKE crapaut.nrdcaixa     NO-UNDO.
    
    /* Tratamento de erros para internet e TAA */
    IF   p-cod-agencia = 90   OR    /** Internet **/
         p-cod-agencia = 91   THEN  /** TAA **/
         aux_nrdcaixa = INT(STRING(p-nrdconta) + STRING(p-idseqttl)).
    ELSE
         aux_nrdcaixa = p-nro-caixa.
    
    FIND crapcop WHERE crapcop.nmrescop = p-cooper NO-LOCK NO-ERROR.

    RUN elimina-erro (INPUT p-cooper,
                      INPUT p-cod-agencia,
                      INPUT aux_nrdcaixa).

    IF  p-codigo-barras <>  " "  THEN 
        DO:
            IF   LENGTH(p-codigo-barras) <> 44 THEN DO:
                 ASSIGN p-codigo-barras = " ".
                 /* Erro de Leitura. Passe Novamente */
                 ASSIGN i-cod-erro  = 666           
                        c-desc-erro = " ".
                 RUN cria-erro (INPUT p-cooper,
                                INPUT p-cod-agencia,
                                INPUT aux_nrdcaixa,
                                INPUT i-cod-erro,
                                INPUT c-desc-erro,
                                INPUT YES).
                 RETURN "NOK".
        END.
    END.
    RETURN "OK".

END PROCEDURE.

PROCEDURE retorna-valores-fatura.       
    /*  Listar   Valor/Sequencia/Digito/Codigo de Barras  */
                                          
    DEF INPUT         PARAM p-cooper        AS CHAR                    NO-UNDO.
    DEF INPUT         PARAM p-nrdconta      AS INTE                    NO-UNDO.
    DEF INPUT         PARAM p-idseqttl      LIKE crapttl.idseqttl      NO-UNDO.
    DEF INPUT         PARAM p-cod-operador  AS CHAR                    NO-UNDO.
    DEF INPUT         PARAM p-cod-agencia   AS INTE                    NO-UNDO.
    DEF INPUT         PARAM p-nro-caixa     AS INTE                    NO-UNDO.
    DEF INPUT         PARAM p-fatura1       AS DEC                     NO-UNDO.
    DEF INPUT         PARAM p-fatura2       AS DEC                     NO-UNDO.
    DEF INPUT         PARAM p-fatura3       AS DEC                     NO-UNDO.
    DEF INPUT         PARAM p-fatura4       AS DEC                     NO-UNDO.
    DEF INPUT-OUTPUT  PARAM p-codigo-barras AS CHAR                    NO-UNDO.
    DEF OUTPUT        PARAM p-cdseqfat      AS DEC                     NO-UNDO.
    DEF OUTPUT        PARAM p-vlfatura      AS DEC                     NO-UNDO.
    DEF OUTPUT        PARAM p-nrdigfat      AS INTE                    NO-UNDO.
    DEF OUTPUT        PARAM p-iptu          AS LOG                     NO-UNDO.

    DEF                 VAR aux_nrdcaixa    LIKE crapaut.nrdcaixa      NO-UNDO.
    DEF                 VAR aux_lindigit    AS DECI                    NO-UNDO.
    DEF                 VAR aux_nrdigito    AS INTE                    NO-UNDO.
    DEF                 VAR aux_idagenda    AS INTE                    NO-UNDO.
    DEF                 VAR aux_flgpgag    AS LOGI                    NO-UNDO.

    /* Tratamento de erros para internet e TAA */
    IF   p-cod-agencia = 90   OR    /** Internet **/
         p-cod-agencia = 91   THEN  /** TAA **/
         aux_nrdcaixa = INT(STRING(p-nrdconta) + STRING(p-idseqttl)).
    ELSE
         aux_nrdcaixa = p-nro-caixa.

    /* Utiliza operador 1000 para agendamentos */
    ASSIGN aux_idagenda = IF p-cod-operador = "1000" THEN 2 ELSE 1.

    /* Utiliza operador 1001 para Pagto de agendamentos
                , com o objeitvo de não validar horário de limite de pagamento SICREDI */
    ASSIGN aux_flgpgag = IF p-cod-operador = "1001" THEN TRUE ELSE FALSE.

    FIND crapcop WHERE crapcop.nmrescop = p-cooper NO-LOCK NO-ERROR.

    RUN elimina-erro (INPUT p-cooper,
                      INPUT p-cod-agencia,
                      INPUT aux_nrdcaixa).

    FIND FIRST crapdat WHERE crapdat.cdcooper = crapcop.cdcooper
                             NO-LOCK NO-ERROR.
        
    ASSIGN p-iptu     = NO
           p-cdseqfat = 0
           p-vlfatura = 0
           p-nrdigfat = 0.

    /* Identificação de Fatura */
    IF  SUBSTRING(p-codigo-barras,1,1) <> "8"  THEN 
        DO: 
            ASSIGN i-cod-erro  = 8           
                   c-desc-erro = " ".
            
            RUN cria-erro (INPUT p-cooper,
                           INPUT p-cod-agencia,
                           INPUT aux_nrdcaixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).

            RETURN "NOK".
        END.

    FIND crapcon WHERE
         crapcon.cdcooper = crapcop.cdcooper                   AND
         crapcon.cdempcon = inte(SUBSTR(p-codigo-barras,16,4)) AND
         crapcon.cdsegmto = inte(SUBSTR(p-codigo-barras,2,1)) 
         NO-LOCK NO-ERROR.

    IF  NOT AVAIL crapcon THEN
        DO:
            ASSIGN i-cod-erro  = 0           
                   c-desc-erro = "Empresa nao Conveniada " +
                                 SUBSTR(p-codigo-barras,2,1) + "/" +
                                 SUBSTR(p-codigo-barras,16,4).
            RUN cria-erro (INPUT p-cooper,
                           INPUT p-cod-agencia,
                           INPUT aux_nrdcaixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
            RETURN "NOK".
        END.

    IF  p-fatura1 <> 0 OR
        p-fatura2 <> 0 OR
        p-fatura3 <> 0 OR
        p-fatura4 <> 0 THEN  
        DO:
            /* Valida os campos manuais */
            /* Campo 1 */
            ASSIGN aux_lindigit = DECI(SUBSTR(STRING(p-fatura1,
                                                     "999999999999"),1,11))
                   aux_nrdigito = INTE(SUBSTR(STRING(p-fatura1,
                                                     "999999999999"),12,11)).
              
            IF  SUBSTR(p-codigo-barras, 3, 1) = "6" OR
                SUBSTR(p-codigo-barras, 3, 1) = "7" THEN
                DO: /** Verificacao pelo modulo 10**/       
                    RUN dbo/pcrap04.p (INPUT-OUTPUT aux_lindigit,
                                       OUTPUT       p-nro-digito,
                                       OUTPUT       p-retorno).
                END. 
            ELSE
                DO: 
                    /*** Verificacao pelo modulo 11 ***/
                    RUN verifica_digito (INPUT aux_lindigit,
                                         OUTPUT p-nro-digito).
                END. 
            
            IF  p-nro-digito <> aux_nrdigito  THEN 
                DO: 
                    ASSIGN i-cod-erro  = 8           
                           c-desc-erro = " ".
                    
                    RUN cria-erro (INPUT p-cooper,
                                   INPUT p-cod-agencia,
                                   INPUT aux_nrdcaixa,
                                   INPUT i-cod-erro,
                                   INPUT c-desc-erro,
                                   INPUT YES).

                    RETURN "NOK".
                END.
              
            /* Campo 2 */
            ASSIGN aux_lindigit = DECI(SUBSTR(STRING(p-fatura2,
                                                     "999999999999"),1,11))
                   aux_nrdigito = INTE(SUBSTR(STRING(p-fatura2,
                                                     "999999999999"),12,11)).
            
            IF  SUBSTR(p-codigo-barras, 3, 1) = "6" OR
                SUBSTR(p-codigo-barras, 3, 1) = "7" THEN
                DO: /*** Verificacao pelo MODULO 10 ***/
                    RUN dbo/pcrap04.p (INPUT-OUTPUT aux_lindigit,
                                       OUTPUT       p-nro-digito,
                                       OUTPUT       p-retorno).
                END.
            ELSE
                DO:
                    /***  Verificacao pelo MODULO 11  ***/
                    RUN verifica_digito (INPUT aux_lindigit,
                                         OUTPUT p-nro-digito).
                END.

            IF  p-nro-digito <> aux_nrdigito  THEN 
                DO: 
                    ASSIGN i-cod-erro  = 8           
                           c-desc-erro = " ".
                    
                    RUN cria-erro (INPUT p-cooper,
                                   INPUT p-cod-agencia,
                                   INPUT aux_nrdcaixa,
                                   INPUT i-cod-erro,
                                   INPUT c-desc-erro,
                                   INPUT YES).

                    RETURN "NOK".
                END.
                    
            /* Campo 3 */
            ASSIGN aux_lindigit = DECI(SUBSTR(STRING(p-fatura3,
                                                     "999999999999"),1,11))
                   aux_nrdigito = INTE(SUBSTR(STRING(p-fatura3,
                                                     "999999999999"),12,11)).

            
            IF  SUBSTR(p-codigo-barras, 3, 1) = "6" OR
                SUBSTR(p-codigo-barras, 3, 1) = "7" THEN
                DO: 
                    /*** Verificacao do digito pelo modulo 10 ***/
                    RUN dbo/pcrap04.p (INPUT-OUTPUT aux_lindigit,
                                       OUTPUT       p-nro-digito,
                                       OUTPUT       p-retorno).
                END.
            ELSE
                DO:
                    /*** Verificacao do digito pelo modulo 11 ***/
                    RUN verifica_digito (INPUT aux_lindigit,
                                         OUTPUT p-nro-digito).
                END.    

            IF  p-nro-digito <> aux_nrdigito  THEN 
                DO: 
                    ASSIGN i-cod-erro  = 8           
                           c-desc-erro = " ".
                    
                    RUN cria-erro (INPUT p-cooper,
                                   INPUT p-cod-agencia,
                                   INPUT aux_nrdcaixa,
                                   INPUT i-cod-erro,
                                   INPUT c-desc-erro,
                                   INPUT YES).

                    RETURN "NOK".
                END.
                    
            /* Campo 4 */
            ASSIGN aux_lindigit = DECI(SUBSTR(STRING(p-fatura4,
                                                     "999999999999"),1,11))
                   aux_nrdigito = INTE(SUBSTR(STRING(p-fatura4,
                                                     "999999999999"),12,11)).
                   
            /*** Verificacao do digito pelo modulo 10 ***/
            IF  SUBSTR(p-codigo-barras, 3, 1) = "6" OR
                SUBSTR(p-codigo-barras, 3, 1) = "7" THEN
                DO:
                    RUN dbo/pcrap04.p (INPUT-OUTPUT aux_lindigit,
                                       OUTPUT       p-nro-digito,
                                       OUTPUT       p-retorno).
                END.
            ELSE
                DO:
                    /*** Verificacao do digito pelo modulo 11 ***/
                    RUN verifica_digito (INPUT aux_lindigit,
                                        OUTPUT p-nro-digito).
                END.

            IF  p-nro-digito <> aux_nrdigito  THEN 
                DO: 
                    ASSIGN i-cod-erro  = 8           
                           c-desc-erro = " ".
                    
                    RUN cria-erro (INPUT p-cooper,
                                   INPUT p-cod-agencia,
                                   INPUT aux_nrdcaixa,
                                   INPUT i-cod-erro,
                                   INPUT c-desc-erro,
                                   INPUT YES).

                    RETURN "NOK".
                END.
            
            ASSIGN de-valor-calc  =
             DEC(SUBSTR(STRING(p-fatura1,"999999999999"),1,11) + 
                 SUBSTR(STRING(p-fatura2,"999999999999"),1,11) + 
                 SUBSTR(STRING(p-fatura3,"999999999999"),1,11) + 
                 SUBSTR(STRING(p-fatura4,"999999999999"),1,11)).
                                                    
            ASSIGN p-codigo-barras = string(de-valor-calc).
        END.
    
    ASSIGN de-valor-calc = DEC(p-codigo-barras).
    
    IF  SUBSTR(p-codigo-barras, 3, 1) = "6" OR
        SUBSTR(p-codigo-barras, 3, 1) = "7" THEN
        DO:     
            /*** Calculo digito verificador pelo modulo 10 ***/
            RUN dbo/pcrap04.p (INPUT-OUTPUT de-valor-calc,
                               OUTPUT p-nro-digito,
                               OUTPUT p-retorno).
        END.  
    ELSE
        DO:
            /*** Verificacao do digito no modulo 11 ***/
            RUN dbo/pcrap14.p (INPUT-OUTPUT de-valor-calc,
                               OUTPUT p-nro-digito,
                               OUTPUT p-retorno).
        END.
    
    IF  p-retorno = NO  THEN 
        DO:
            ASSIGN i-cod-erro  = 8           
                   c-desc-erro = " ".
            RUN cria-erro (INPUT p-cooper,
                           INPUT p-cod-agencia,
                           INPUT aux_nrdcaixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).

            RETURN "NOK".
        END.
     
    /* validacoes relativas aos convenios SICREDI */
    IF  crapcon.flgcnvsi THEN
        DO:
            RUN validacoes-sicredi (INPUT p-cooper,
                                    INPUT p-cod-agencia,
                                    INPUT p-nrdconta,
                                    INPUT p-idseqttl,
                                    INPUT p-nro-caixa,
                                    INPUT p-codigo-barras,
                                    INPUT aux_idagenda,
                                    INPUT aux_flgpgag).

            IF  RETURN-VALUE = "NOK" THEN
                RETURN "NOK".
        END.

    IF   crapcon.cdempcon = 8359 AND crapcon.cdsegmto = 6   THEN /* CASA FELIZ */
         DO:
             /* Nao permitir faturas da promocao antiga (menor que 20/10/2006) */
             IF  SUBSTR(p-codigo-barras,24,8) <= "20061020"  THEN
                 DO:
                     ASSIGN i-cod-erro  = 0           
                            c-desc-erro = "Esta promocao nao eh mais valida!".

                     RUN cria-erro (INPUT p-cooper,
                                    INPUT p-cod-agencia,
                                    INPUT aux_nrdcaixa,
                                    INPUT i-cod-erro,
                                    INPUT c-desc-erro,
                                    INPUT YES).
                     RETURN "NOK".
                 END.
         END.      

    IF  ((crapcon.cdempcon = 2044 AND crapcon.cdsegmto = 1) OR    /* P.M. ITAJAI */
	      (crapcon.cdempcon = 3493 AND crapcon.cdsegmto = 1)  OR    /* P.M. PRES GETULIO */
	      (crapcon.cdempcon = 1756 AND crapcon.cdsegmto = 1)  OR    /* P.M. GUARAMIRIM */
        (crapcon.cdempcon = 4539 AND crapcon.cdsegmto = 1)  OR    /* P.M. TIMBO */
        (crapcon.cdempcon = 4594 AND crapcon.cdsegmto = 1)  OR    /* P.M. TROMBUDO CENTRAL */
		(crapcon.cdempcon = 0040 AND crapcon.cdsegmto = 1)  OR    /* P.M. AGROLANDIA */
        (crapcon.cdempcon = 0562 AND crapcon.cdsegmto = 5)  OR    /* DEFESA CIVIL TIMBO */
        (crapcon.cdempcon = 0563 AND crapcon.cdsegmto = 5)  OR    /* MEIO AMBIENTE DE TIMBO */
        (crapcon.cdempcon = 0564 AND crapcon.cdsegmto = 5)  OR    /* TRANSITO DE TIMBO */
        (crapcon.cdempcon = 0524 AND crapcon.cdsegmto = 5)        /* F.M.S TROMBUDO CENTRAL */ 
        ) THEN  
         DO:
             aux_dtmvtoan = STRING(YEAR(crapdat.dtmvtoan),"9999") +
                            STRING(MONTH(crapdat.dtmvtoan),"99")  +
                            STRING(DAY(crapdat.dtmvtoan),"99").
                          
             IF  SUBSTR(p-codigo-barras,20,8) <= aux_dtmvtoan  THEN
                 DO:
                     ASSIGN i-cod-erro  = 0           
                            c-desc-erro = "Nao eh possivel efetuar esta " +
                                        "operacao, pois a fatura esta vencida.".                                          
                     RUN cria-erro (INPUT p-cooper,
                                    INPUT p-cod-agencia,
                                    INPUT aux_nrdcaixa,
                                    INPUT i-cod-erro,
                                    INPUT c-desc-erro,
                                    INPUT YES).
                     RETURN "NOK".
                 END.
         END.

    IF   crapcon.cdempcon = 0109 AND crapcon.cdsegmto = 2   THEN /* SANEPAR */
         DO:
             aux_dtmvtoan = STRING(YEAR(crapdat.dtmvtocd - 25),"9999") +
                            STRING(MONTH(crapdat.dtmvtocd - 25),"99")  +
                            STRING(DAY(crapdat.dtmvtocd - 25),"99").
                          
             IF  SUBSTR(p-codigo-barras,20,8) <= aux_dtmvtoan  THEN
                 DO:
                     ASSIGN i-cod-erro  = 0           
                            c-desc-erro = "Nao eh possivel efetuar esta " +
                                        "operacao, pois a fatura esta vencida.".                                          
                     RUN cria-erro (INPUT p-cooper,
                                    INPUT p-cod-agencia,
                                    INPUT aux_nrdcaixa,
                                    INPUT i-cod-erro,
                                    INPUT c-desc-erro,
                                    INPUT YES).
                     RETURN "NOK".
                 END.
         END.
         
    RUN busca_sequencial_fatura (INPUT crapcon.cdhistor,
                                 INPUT p-codigo-barras,
                                 OUTPUT p-cdseqfat).

    ASSIGN p-vlfatura     =  DECIMAL(SUBSTR(p-codigo-barras,5,11)) / 100.
                                        
    IF  crapcon.cdhistor  = 644  OR
        crapcon.cdhistor  = 307  OR
        crapcon.cdhistor  = 348  THEN
        ASSIGN p-nrdigfat = INTEGER(SUBSTR(p-codigo-barras,43,02)).
    ELSE
        ASSIGN p-nrdigfat = 0.                   
    
    /* Lote - 15000 --- Tipo 13 --- FATURAS ---*/
    ASSIGN i-nro-lote = 15000 + p-nro-caixa.

    FIND craplft WHERE
         craplft.cdcooper = crapcop.cdcooper  AND
         craplft.dtmvtolt = crapdat.dtmvtocd  AND
         craplft.cdagenci = p-cod-agencia     AND
         craplft.cdbccxlt = 11                AND
         craplft.nrdolote = i-nro-lote        AND
         /** Nao considerar a conta **
             craplft.nrdconta = p-nrdconta        AND
         **/
         craplft.cdseqfat = p-cdseqfat
         USE-INDEX craplft1 NO-LOCK NO-ERROR.
    
    

    IF  AVAIL craplft THEN  
    DO:
       ASSIGN i-cod-erro  = 92           
              c-desc-erro = " ".
       RUN cria-erro (INPUT p-cooper,
                      INPUT p-cod-agencia,
                      INPUT aux_nrdcaixa,
                      INPUT i-cod-erro,
                      INPUT c-desc-erro,
                      INPUT YES).
       RETURN "NOK".
    END.

    RETURN "OK".
END PROCEDURE.

PROCEDURE validacoes-sicredi:

    DEF INPUT  PARAM p-cooper            AS CHAR                     NO-UNDO.
    DEF INPUT  PARAM p-cod-agencia       AS INTE                     NO-UNDO.
    DEF INPUT  PARAM p-nrdconta          AS INTE                     NO-UNDO.
    DEF INPUT  PARAM p-idseqttl          LIKE crapttl.idseqttl       NO-UNDO.
    DEF INPUT  PARAM p-nro-caixa         AS INTE                     NO-UNDO.
    DEF INPUT  PARAM p-codigo-barras     AS CHAR                     NO-UNDO.
    DEF INPUT  PARAM par_idagenda        AS INTE                     NO-UNDO.
    DEF INPUT  PARAM par_flgpgag         AS LOGI                     NO-UNDO.
                                                                     
    DEF VAR aux_hhsicini AS INTE                                     NO-UNDO.
    DEF VAR aux_hhsicfim AS INTE                                     NO-UNDO.
    DEF VAR aux_contador AS INTE                                     NO-UNDO.
    DEF VAR aux_dttolera AS DATE                                     NO-UNDO.
    DEF VAR aux_inanocal AS INTE                                     NO-UNDO.

    DEF VAR aux_nrdcaixa LIKE crapaut.nrdcaixa                       NO-UNDO.    

    /* Tratamento de erros para internet e TAA */
    IF   p-cod-agencia = 90   OR    /** Internet **/
         p-cod-agencia = 91   THEN  /** TAA **/
         aux_nrdcaixa = INT(STRING(p-nrdconta) + STRING(p-idseqttl)).
    ELSE
         aux_nrdcaixa = p-nro-caixa.

    /* Se não for Agendamento nem Pagto de Agendamento */
    IF  par_idagenda <> 2 AND
        NOT par_flgpgag   THEN
        DO:
            /* Validação de horários de convenios SICREDI */
            FIND craptab WHERE craptab.cdcooper = crapcop.cdcooper  AND
                               craptab.nmsistem = "CRED"            AND
                               craptab.tptabela = "GENERI"          AND
                               craptab.cdempres = 00                AND
                               craptab.cdacesso = "HRPGSICRED"      AND
                               craptab.tpregist = p-cod-agencia 
                               NO-LOCK NO-ERROR.
            
            IF  NOT AVAIL craptab  THEN
                DO:
                    ASSIGN i-cod-erro  = 0 
                           c-desc-erro = "Parametros de Horario nao cadastrados.".
        
                    RUN cria-erro (INPUT p-cooper,
                                   INPUT p-cod-agencia,
                                   INPUT aux_nrdcaixa,
                                   INPUT i-cod-erro,
                                   INPUT c-desc-erro,
                                   INPUT YES).
                    RETURN "NOK".
                END.
        
            ASSIGN aux_hhsicini = INT(ENTRY(1,craptab.dstextab," "))
                   aux_hhsicfim = INT(ENTRY(2,craptab.dstextab," ")).
        
            IF  TIME < aux_hhsicini OR
                TIME > aux_hhsicfim THEN
                DO:
                    IF  p-cod-agencia = 91 OR   /* TAA */
                        p-cod-agencia = 90 THEN /* Internet */
                        DO:
                            ASSIGN i-cod-erro  = 0
                                   c-desc-erro = "Esse convenio e aceito ate as " + STRING(aux_hhsicfim,"HH:MM") + 
                                                 "h. O pagamento pode ser agendado para o proximo dia util.".
                        END.
                    ELSE
                        DO:
                            ASSIGN i-cod-erro  = 676
                                   c-desc-erro = "".
                        END.

                    RUN cria-erro (INPUT p-cooper,
                                   INPUT p-cod-agencia,
                                   INPUT aux_nrdcaixa,
                                   INPUT i-cod-erro,
                                   INPUT c-desc-erro,
                                   INPUT YES).
                    RETURN "NOK".
                END.
        END.

    /* Procura cod. da empresa do convenio SICREDI em cada campo de Num. do Cod. Barras */
    FIND FIRST crapscn WHERE crapscn.cdempcon  = INTE(SUBSTR(p-codigo-barras,16,4)) AND
                             crapscn.cdsegmto  = SUBSTR(p-codigo-barras,2 ,1)       AND
                             crapscn.dsoparre <> "E"                                AND /* Debaut */
                             crapscn.dtencemp  = ?                        
                                                 NO-LOCK NO-ERROR NO-WAIT.

    IF  NOT AVAIL crapscn THEN
        DO:
            FIND FIRST crapscn WHERE crapscn.cdempco2  = INTE(SUBSTR(p-codigo-barras,16,4)) AND
                                     crapscn.cdsegmto  = SUBSTR(p-codigo-barras,2 ,1)       AND
                                     crapscn.dsoparre <> "E"                                AND /* Debaut */
                                     crapscn.dtencemp  = ?                      
                                                         NO-LOCK NO-ERROR NO-WAIT.
            IF  NOT AVAIL crapscn THEN
                DO:
                    FIND FIRST crapscn WHERE crapscn.cdempco3  = INTE(SUBSTR(p-codigo-barras,16,4)) AND
                                             crapscn.cdsegmto  = SUBSTR(p-codigo-barras,2 ,1)       AND
                                             crapscn.dsoparre <> "E"                                AND /* Debaut */
                                             crapscn.dtencemp  = ?                      
                                                                 NO-LOCK NO-ERROR NO-WAIT.
                    IF  NOT AVAIL crapscn THEN
                        DO:
                            FIND FIRST crapscn WHERE crapscn.cdempco4  = INTE(SUBSTR(p-codigo-barras,16,4)) AND
                                                     crapscn.cdsegmto  = SUBSTR(p-codigo-barras,2 ,1)       AND
                                                     crapscn.dsoparre <> "E"                                AND /* Debaut */
                                                     crapscn.dtencemp  = ?                      
                                                                         NO-LOCK NO-ERROR NO-WAIT.
                            IF  NOT AVAIL crapscn THEN
                                DO:
                                    FIND FIRST crapscn WHERE crapscn.cdempco5  = INTE(SUBSTR(p-codigo-barras,16,4)) AND
                                                             crapscn.cdsegmto  = SUBSTR(p-codigo-barras,2 ,1)       AND
                                                             crapscn.dsoparre <> "E"                                AND /* Debaut */
                                                             crapscn.dtencemp  = ?                      
                                                                                 NO-LOCK NO-ERROR NO-WAIT.
                                    IF  NOT AVAIL crapscn THEN
                                        DO:
                                            ASSIGN i-cod-erro  = 0 
                                                   c-desc-erro = "Documento nao aceito. Procure seu Posto de Atendimento para maiores informacoes.".
                                         
                                            RUN cria-erro (INPUT p-cooper,
                                                           INPUT p-cod-agencia,
                                                           INPUT aux_nrdcaixa,
                                                           INPUT i-cod-erro,
                                                           INPUT c-desc-erro,
                                                           INPUT YES).
                                            RETURN "NOK".
                                        END.
                                END.
                        END.
                END.
        END.

    /* Validação para saber se o convenio possui o meio de arrecadacao utilizado */
    IF  p-cod-agencia = 90   THEN
        DO:
            /* INTERNET */    
            IF  crapscn.dsoparre MATCHES "*D*" THEN
                DO:
                    FIND FIRST crapstn WHERE crapstn.cdempres = crapscn.cdempres AND
                                             crapstn.tpmeiarr = "D"  
                                             NO-LOCK NO-ERROR.

                    IF  NOT AVAIL crapstn THEN
                        ASSIGN i-cod-erro  = 0 
                               c-desc-erro = "Convenio nao disponivel para esse meio de arrecadacao.".
                END.
            ELSE
                DO:
                    ASSIGN i-cod-erro  = 0 
                               c-desc-erro = "Convenio nao disponivel para esse meio de arrecadacao.".
                END.
        END.
    ELSE
    IF  p-cod-agencia = 91 THEN
        DO:
            /* TAA */
            IF  crapscn.dsoparre MATCHES "*A*" THEN
                DO:
                    FIND FIRST crapstn WHERE crapstn.cdempres = crapscn.cdempres AND
                                             crapstn.tpmeiarr = "A" 
                                             NO-LOCK NO-ERROR.
        
                    IF  NOT AVAIL crapstn THEN
                        ASSIGN i-cod-erro  = 0 
                               c-desc-erro = "Convenio nao disponivel para esse meio de arrecadacao.".
                END.
            ELSE
                DO:
                    ASSIGN i-cod-erro  = 0 
                           c-desc-erro = "Convenio nao disponivel para esse meio de arrecadacao.".
                END.
        END.
    ELSE
        DO:
            /* CAIXA */
            IF  crapscn.dsoparre MATCHES "*C*" THEN
                DO:
                    FIND FIRST crapstn WHERE crapstn.cdempres = crapscn.cdempres AND
                                             crapstn.tpmeiarr = "C" 
                                             NO-LOCK NO-ERROR.
        
                    IF  NOT AVAIL crapstn THEN
                        ASSIGN i-cod-erro  = 0 
                               c-desc-erro = "Convenio nao disponivel para esse meio de arrecadacao.".
                END.
            ELSE
                DO:
                    ASSIGN i-cod-erro  = 0 
                           c-desc-erro = "Convenio nao disponivel para esse meio de arrecadacao.".
                END.
        END.

    IF  i-cod-erro   > 0    OR
        c-desc-erro <> ""   THEN
        DO:
            RUN cria-erro (INPUT p-cooper,
                           INPUT p-cod-agencia,
                           INPUT aux_nrdcaixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
            RETURN "NOK".
        END.

    /* Validação para nao aceitar DARFs e DAS na Internet/TAA/ */
    IF  p-cod-agencia = 91 OR   /* TAA */
        p-cod-agencia = 90 THEN /* Internet */
        IF  crapstn.dstipdrf <> ""  OR
            crapscn.cdempres = "K0" THEN
            DO:
                ASSIGN i-cod-erro  = 0 
                       c-desc-erro = "Nao permitido o pagamento deste tipo de guia.".
            
                RUN cria-erro (INPUT p-cooper,
                               INPUT p-cod-agencia,
                               INPUT aux_nrdcaixa,
                               INPUT i-cod-erro,
                               INPUT c-desc-erro,
                               INPUT YES).
                RETURN "NOK".
            END.

    FIND FIRST crapdat WHERE crapdat.cdcooper = crapcop.cdcooper
                              NO-LOCK NO-ERROR.

    /* Não repete validação já realizada se for Agendamento */
    IF  par_idagenda <> 2 THEN
        DO:
            /* Validação referente aos dias de tolerancia */
            IF (crapscn.nrtolera <> 99) THEN /* Se não for tolerancia ilimitada */
                DO:
                    IF  crapstn.dstipdrf <> ""  OR
                        crapscn.cdempres = "K0" THEN
                        DO: 
                            /* DARF PRETO EUROPA */
                            IF (crapcon.cdempcon = 64  AND  /* DARFC0064 */
                                crapcon.cdsegmto = 5 ) OR  
                               (crapcon.cdempcon = 153 AND  /* DARFC0153 */
                                crapcon.cdsegmto = 5 ) THEN
                                DO:
                                    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

                                    /* Efetuar a chamada a rotina Oracle CXON0014.pc_ret_ano_barras_darf_car */ 
                                    RUN STORED-PROCEDURE pc_ret_ano_barras_darf_car
                                     aux_handproc = PROC-HANDLE NO-ERROR (INPUT INT(SUBSTR(p-codigo-barras,20,1)), /* pr_innumano*/
                                                                         OUTPUT 0).                /* pr_outnumano */                                                                         
                                    
                                    /* Fechar o procedimento para buscarmos o resultado */ 
                                    CLOSE STORED-PROC pc_ret_ano_barras_darf_car
                                        aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 

                                    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

                                    ASSIGN aux_inanocal = pc_ret_ano_barras_darf_car.pr_outnumano
                                                             WHEN pc_ret_ano_barras_darf_car.pr_outnumano <> ?.       
  
                                    RUN retorna-data-dias (INPUT INT(SUBSTR(p-codigo-barras,21,3)),
                                                           INPUT aux_inanocal,
                                                          OUTPUT aux_dttolera).
                                END.

                            /* DARF NUMERADO / DAS */
                            IF (crapcon.cdempcon = 385  AND  /* DARFC0385 */
                                crapcon.cdsegmto = 5  ) OR
                               (crapcon.cdempcon = 328  AND  /* DAS - SIMPLES NACIONAL */
                                crapcon.cdsegmto = 5  )THEN
                                DO:
                                    RUN retorna-ano-cdbarras (INPUT INT(SUBSTR(p-codigo-barras,20,2)),
                                                              INPUT TRUE, /* DARF NUMERADO / DAS */
                                                             OUTPUT aux_inanocal).

                                    RUN retorna-data-dias (INPUT INT(SUBSTR(p-codigo-barras,22,3)),
                                                           INPUT aux_inanocal,
                                                          OUTPUT aux_dttolera).
                                END.
                            
                            IF  crapdat.dtmvtocd > aux_dttolera THEN
                                DO:
                                    ASSIGN i-cod-erro  = 0 
                                           c-desc-erro = "Prazo para pagamento apos o vencimento excedido.".
                                
                                    RUN cria-erro (INPUT p-cooper,
                                                   INPUT p-cod-agencia,
                                                   INPUT aux_nrdcaixa,
                                                   INPUT i-cod-erro,
                                                   INPUT c-desc-erro,
                                                   INPUT YES).
                                    RETURN "NOK".
                                END.
                        END.
                    ELSE /* Não é DARF/DAS */
                        DO:
                            DATE(STRING(SUBSTR(p-codigo-barras,26,2),"99"  )  + "/" +
                                 STRING(SUBSTR(p-codigo-barras,24,2),"99"  )  + "/" +
                                 STRING(SUBSTR(p-codigo-barras,20,4),"9999")) NO-ERROR.
                            
                            IF  NOT ERROR-STATUS:ERROR THEN /* Verifica se não houve erro na conversão para data */
                                DO:
                                    ASSIGN aux_dttolera = DATE(STRING(SUBSTR(p-codigo-barras,26,2),"99"  )  + "/" +
                                                               STRING(SUBSTR(p-codigo-barras,24,2),"99"  )  + "/" +
                                                               STRING(SUBSTR(p-codigo-barras,20,4),"9999"))
                                           aux_contador = 1.
                            
                                    IF  crapscn.dsdiatol = "U" THEN /* Dias úteis */
                                        DO:
                                            DO WHILE TRUE:
                                        
                                                ASSIGN aux_dttolera = aux_dttolera + 1.
                                        
                                                IF   CAN-DO("1,7",STRING(WEEKDAY(aux_dttolera)))                OR
                                                     CAN-FIND(crapfer WHERE crapfer.cdcooper = crapcop.cdcooper AND
                                                                            crapfer.dtferiad = aux_dttolera)    THEN
                                                     NEXT.
                                        
                                                IF  aux_contador = crapscn.nrtolera THEN
                                                    LEAVE.
                                        
                                                ASSIGN aux_contador = aux_contador + 1.
                                        
                                            END.
                                        END.
                                    ELSE   /* Dias corridos */
                                        DO:
                                            ASSIGN aux_dttolera = aux_dttolera + crapscn.nrtolera.
                                        
                                            DO WHILE TRUE:
                            
                                                IF   NOT CAN-DO("1,7",STRING(WEEKDAY(aux_dttolera)))                AND
                                                     NOT CAN-FIND(crapfer WHERE crapfer.cdcooper = crapcop.cdcooper AND
                                                                                crapfer.dtferiad = aux_dttolera)    THEN
                                                     LEAVE.
                                            
                                                ASSIGN aux_dttolera = aux_dttolera + 1.
                                            
                                            END.
                                        END.

                                    IF  YEAR(aux_dttolera) >= 2010 THEN
                                        IF  crapdat.dtmvtocd > aux_dttolera THEN
                                            DO:
                                                ASSIGN i-cod-erro  = 0 
                                                       c-desc-erro = "Prazo para pagamento apos o vencimento excedido.".
                                            
                                                RUN cria-erro (INPUT p-cooper,
                                                               INPUT p-cod-agencia,
                                                               INPUT aux_nrdcaixa,
                                                               INPUT i-cod-erro,
                                                               INPUT c-desc-erro,
                                                               INPUT YES).
                                                RETURN "NOK".
                                            END.
                                END.

                        END. /* IF FIM */
                END.
        END.


    /* validacao duplicidade de pagamento de fatura */
    ASSIGN i-cod-erro  = 0.
    
    FOR FIRST craplft FIELDS(dtvencto) WHERE 
    craplft.cdcooper = crapcop.cdcooper  AND
    craplft.cdbarras = p-codigo-barras   AND 
    craplft.cdhistor = 1154  AND 
    craplft.tpfatura <> 2                AND
    craplft.dtvencto > ADD-INTERVAL(TODAY, -5, "years") 
    /* Verifica os últimos 5 anos pois o sicredi também 
       valida os pagamentos feitos em até 5 anos */
    USE-INDEX craplft5 
    NO-LOCK 
    BREAK BY craplft.dtvencto DESC: END.


    IF  AVAIL craplft THEN
    DO: 
        ASSIGN c-desc-erro = "Fatura ja arrecadada dia " + STRING(craplft.dtvencto) + ".".

        /* Se encontrar a fatura e o pagamento for no caixa on-line gerar a crítica */
        IF  p-cod-agencia <> 90 AND 
            p-cod-agencia <> 91 THEN
            ASSIGN c-desc-erro = c-desc-erro +
            " Para consultar o canal de recebimento, verificar na tela PESQTI.".
        ELSE
        DO: /* internet/mobile (cdagenci = 90) ou TA (cdagenci = 91) */ 
            IF par_flgpgag = FALSE THEN
            DO:                
                ASSIGN c-desc-erro = c-desc-erro +
                " Duvidas entrar em contato com o SAC pelo telefone " +
                crapcop.nrtelsac + ".".
            END.
        END.

        RUN cria-erro (INPUT p-cooper,
               INPUT p-cod-agencia,
               INPUT aux_nrdcaixa,
               INPUT i-cod-erro,
               INPUT c-desc-erro,
               INPUT YES).

        RETURN "NOK".
    END.
    /* fim validacao de duplicidade de pagamento de fatura */



    RETURN "OK".

END PROCEDURE.

PROCEDURE gera-faturas.
    
    DEF INPUT  PARAM p-cooper            AS CHAR                       NO-UNDO.
    DEF INPUT  PARAM p-nrdconta          AS INTE                       NO-UNDO.
    DEF INPUT  PARAM p-idseqttl          LIKE crapttl.idseqttl         NO-UNDO.
    DEF INPUT  PARAM p-cod-operador      AS char                       NO-UNDO.
    DEF INPUT  PARAM p-cod-agencia       AS INTE                       NO-UNDO.
    DEF INPUT  PARAM p-nro-caixa         AS INTE                       NO-UNDO.
    DEF INPUT  PARAM p-codigo-barras     AS CHAR                       NO-UNDO.
    DEF INPUT  PARAM p-cdseqfat          AS DEC                        NO-UNDO.
    DEF INPUT  PARAM p-vlfatura          AS DEC                        NO-UNDO.
    DEF INPUT  PARAM p-nrdigfat          AS inte                       NO-UNDO.
    DEF INPUT  PARAM p-valorinf          AS DEC                        NO-UNDO.
    DEF INPUT  PARAM par_cdcoptfn        AS INTE                       NO-UNDO.
    DEF INPUT  PARAM par_cdagetfn        AS INTE                       NO-UNDO.
    DEF INPUT  PARAM par_nrterfin        AS INTE                       NO-UNDO.
    /* Tipo de captura 1-codbarra 2- linha digitavel*/
    DEF INPUT  PARAM par_tpcptdoc        AS INTE                       NO-UNDO. 
    DEF INPUT  PARAM p-tppagmto          AS INTE                       NO-UNDO. /** 0 - Conta / 1 - Especie **/
                                                                     
    DEF OUTPUT PARAM p-histor            AS INTE                       NO-UNDO.
    DEF OUTPUT PARAM p-pg                AS LOG                        NO-UNDO.
    DEF OUTPUT PARAM p-docto             AS DEC                        NO-UNDO.
    DEF OUTPUT PARAM p-literal-r         AS CHAR                       NO-UNDO.
    DEF OUTPUT PARAM p-ult-sequencia-r   AS INTE                       NO-UNDO.
        
    DEF          VAR aux_nrdcaixa        LIKE crapaut.nrdcaixa         NO-UNDO.    
    DEF          VAR aux_contador        AS INTE                       NO-UNDO.
    DEF          VAR aux_inanocal        AS INTE                       NO-UNDO.
    DEF          VAR aux_dtapurac        AS DATE                       NO-UNDO.
    DEF          VAR aux_dtlimite        AS DATE                       NO-UNDO.
    DEF          VAR aux_cdempres        AS CHAR                       NO-UNDO.
    DEF          VAR aux_nrdigito        AS INTE                       NO-UNDO.
    DEF          VAR aux_numerdas        AS CHAR                       NO-UNDO.
    DEF          VAR aux_dvnrodas        AS INTE                       NO-UNDO.
    DEF          VAR aux_poslimit        AS INTE                       NO-UNDO.
    DEF          VAR aux_dvadicio        AS INTE                       NO-UNDO.

    /* Tratamento de erros para internet e TAA */
    IF   p-cod-agencia = 90   OR    /** Internet **/
         p-cod-agencia = 91   THEN  /** TAA **/
         aux_nrdcaixa = INT(STRING(p-nrdconta) + STRING(p-idseqttl)).
    ELSE
         aux_nrdcaixa = p-nro-caixa.

    FIND crapcop WHERE crapcop.nmrescop = p-cooper NO-LOCK NO-ERROR.

    RUN elimina-erro (INPUT p-cooper,
                      INPUT p-cod-agencia,
                      INPUT aux_nrdcaixa).

    IF  p-cod-agenciA   = 0   OR
        P-nro-caixa     = 0   OR
        P-cod-operador  = ""  THEN
        DO:
            ASSIGN i-cod-erro  = 0           
                   c-desc-erro = 
                          "ERRO! PA ZERADO. FECHE O CAIXA E AVISE O CPD ".
            RUN cria-erro (INPUT p-cooper,
                           INPUT p-cod-agencia,
                           INPUT aux_nrdcaixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
            RETURN "NOK".
        END.

    IF  p-vlfatura = 0 AND p-valorinf = 0 THEN 
        DO:
            ASSIGN i-cod-erro  = 0
                   c-desc-erro = "Valor deve ser informado".
            RUN cria-erro (INPUT p-cooper,
                           INPUT p-cod-agencia,
                           INPUT aux_nrdcaixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
            RETURN "NOK".
        END.

    /* Lote - 15000 --- Tipo 13 --- FATURAS ---*/
    ASSIGN i-nro-lote = 15000 + p-nro-caixa. 

    FIND FIRST crapdat WHERE crapdat.cdcooper = crapcop.cdcooper
                             NO-LOCK NO-ERROR.

    FIND crapcon WHERE
         crapcon.cdcooper = crapcop.cdcooper                    AND
         crapcon.cdempcon = inte(SUBSTR(p-codigo-barras,16,4))  AND
         crapcon.cdsegmto = inte(SUBSTR(p-codigo-barras,2,1)) 
         NO-LOCK NO-ERROR.
         
    IF  NOT AVAIL crapcon THEN  
        DO:
            ASSIGN i-cod-erro  = 0           
                   c-desc-erro = "Empresa nao Conveniada".
            RUN cria-erro (INPUT p-cooper,
                           INPUT p-cod-agencia,
                           INPUT aux_nrdcaixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
            RETURN "NOK".
        END.

    IF  crapcon.flgcnvsi THEN
        DO:
            /* Procura cod. da empresa do convenio SICREDI em cada campo de Num. do Cod. Barras */
            FIND FIRST crapscn WHERE crapscn.cdempcon  = crapcon.cdempcon         AND
                                     crapscn.cdsegmto  = STRING(crapcon.cdsegmto) AND
                                     crapscn.dtencemp  = ?   
                                                         NO-LOCK NO-ERROR NO-WAIT.
            
            IF  NOT AVAIL crapscn THEN
                DO:
                    FIND FIRST crapscn WHERE crapscn.cdempco2  = crapcon.cdempcon         AND
                                             crapscn.cdsegmto  = STRING(crapcon.cdsegmto) AND
                                             crapscn.dtencemp  = ? 
                                                                 NO-LOCK NO-ERROR NO-WAIT.
                    IF  NOT AVAIL crapscn THEN
                        DO:
                            ASSIGN i-cod-erro  = 0 
                                   c-desc-erro = "Falta registro de Conv. SICREDI.".
                            
                            RUN cria-erro (INPUT p-cooper,
                                           INPUT p-cod-agencia,
                                           INPUT aux_nrdcaixa,
                                           INPUT i-cod-erro,
                                           INPUT c-desc-erro,
                                           INPUT YES).
                            RETURN "NOK".

                        END.
                END.

            /* Validação para nao aceitar DARFs menor que R$10,00 */
            IF  crapscn.cdempres = "K0"  OR   /* DAS - SIMPLES NACIONAL        */
                crapscn.cdempres = "147" OR   /* DARFC0064 - DARF PRETO EUROPA */
                crapscn.cdempres = "149" OR   /* DARFC0153 - DARF PRETO EUROPA */
                crapscn.cdempres = "145" OR   /* DARFS0154 - DARF SIMPLES      */
                crapscn.cdempres = "608" THEN /* DARFC0385 (DARF NUMERADO)     */
                DO: 
                    IF  p-vlfatura < 10 THEN
                        DO:
                            ASSIGN i-cod-erro  = 0
                                    c-desc-erro = "Pagamento deve ser maior ou igual a R$10,00.".
                    
                            RUN cria-erro (INPUT p-cooper,
                                           INPUT p-cod-agencia,
                                           INPUT aux_nrdcaixa,
                                           INPUT i-cod-erro,
                                           INPUT c-desc-erro,
                                           INPUT YES).
                                          
                            RETURN "NOK".
                    
                        END.

                    /* DAS - SIMPLES NACIONAL */
                    IF crapscn.cdempres = "K0" THEN
                    DO:
                        ASSIGN aux_numerdas = SUBSTR(p-codigo-barras, 25, 16)
                               aux_dvnrodas = INTE(SUBSTR(p-codigo-barras, 41, 1)).

                        RUN calcula_dv_numero_das(INPUT  aux_numerdas,
                                                  INPUT  aux_dvnrodas,
                                                  OUTPUT p-retorno).

                        IF p-retorno = FALSE THEN 
                        DO:
                            ASSIGN i-cod-erro  = 8           
                                   c-desc-erro = " ".

                            RUN cria-erro (INPUT p-cooper,
                                           INPUT p-cod-agencia,
                                           INPUT aux_nrdcaixa,
                                           INPUT i-cod-erro,
                                           INPUT c-desc-erro,
                                           INPUT YES).

                            RETURN "NOK".
                        END.

                        DO aux_poslimit = 42 TO 44:

                            ASSIGN aux_dvadicio = INTE(SUBSTR(p-codigo-barras, 
                                                              aux_poslimit, 1)).

                            RUN calcula_dv_adicional (INPUT  p-codigo-barras,
                                                      INPUT  aux_poslimit - 5,
                                                      INPUT  aux_dvadicio,
                                                      OUTPUT p-retorno).

                            IF p-retorno = FALSE THEN 
                            DO:
                                ASSIGN i-cod-erro  = 8           
                                       c-desc-erro = " ".

                                RUN cria-erro (INPUT p-cooper,
                                               INPUT p-cod-agencia,
                                               INPUT aux_nrdcaixa,
                                               INPUT i-cod-erro,
                                               INPUT c-desc-erro,
                                               INPUT YES).

                                RETURN "NOK".
                            END.
                        END.
                    END.
                END.
        END.

    /* DARF PRETO EUROPA */
    IF (crapcon.cdempcon = 64  AND  /* DARFC0064 */
        crapcon.cdsegmto = 5 ) OR  
       (crapcon.cdempcon = 153 AND  /* DARFC0153 */
        crapcon.cdsegmto = 5 ) THEN
        DO:
            /* Validação Cd. Tributo */
            FIND crapstb WHERE crapstb.cdtribut = INTE(SUBSTR(p-codigo-barras,37,4)) NO-LOCK NO-ERROR.

            IF  NOT AVAIL crapstb THEN
                DO:
                    ASSIGN i-cod-erro  = 0
                           c-desc-erro = "Tributo nao cadastrado.".

                    RUN cria-erro (INPUT p-cooper,
                                   INPUT p-cod-agencia,
                                   INPUT aux_nrdcaixa,
                                   INPUT i-cod-erro,
                                   INPUT c-desc-erro,
                                   INPUT YES).

                    RETURN "NOK".
                END.

            /* DARF PRETO EUROPA */
            IF  crapstb.cdtribut <> 6106 THEN 
                IF  SUBSTRING(crapstb.dsrestri,9,1) = "N" THEN
                    DO:

                        ASSIGN i-cod-erro  = 0
                               c-desc-erro = "Pagamento dessa guia nao permitido".

                        RUN cria-erro (INPUT p-cooper,
                                       INPUT p-cod-agencia,
                                       INPUT aux_nrdcaixa,
                                       INPUT i-cod-erro,
                                       INPUT c-desc-erro,
                                       INPUT YES).

                        RETURN "NOK".
                END.
        END.

    TRANS_FAT:
    DO TRANSACTION ON ERROR  UNDO TRANS_FAT, LEAVE TRANS_FAT
                   ON ENDKEY UNDO TRANS_FAT, LEAVE TRANS_FAT:

    DO aux_contador = 1 TO 10:
        
        c-desc-erro = "".
        
        FIND craplot WHERE craplot.cdcooper = crapcop.cdcooper AND
                           craplot.dtmvtolt = crapdat.dtmvtocd AND
                           craplot.cdagenci = p-cod-agencia    AND
                           craplot.cdbccxlt = 11               AND
                           craplot.nrdolote = i-nro-lote       
                           EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

        IF  NOT AVAILABLE craplot  THEN 
            DO:
                IF  LOCKED craplot  THEN
                    DO:
                        c-desc-erro = "Registro de lote em uso. Tente " +
                                      "novamente.".
                        PAUSE 1 NO-MESSAGE.
                        NEXT.                  
                    END.
                ELSE
                    DO:    
                        CREATE craplot.
                        ASSIGN craplot.cdcooper = crapcop.cdcooper
                               craplot.dtmvtolt = crapdat.dtmvtocd
                               craplot.cdagenci = p-cod-agencia   
                               craplot.cdbccxlt = 11              
                               craplot.nrdolote = i-nro-lote
                               craplot.tplotmov = 13
                               craplot.cdoperad = p-cod-operador
                               craplot.cdhistor = 0 /* crapcon.cdhistor */
                               craplot.nrdcaixa = p-nro-caixa
                               craplot.cdopecxa = p-cod-operador.
                    END.
            END.
            
        LEAVE.
                
    END. /* Fim do DO ... TO */
    
    IF  c-desc-erro <> ""  THEN
        DO:
            i-cod-erro = 0.
            
            RUN cria-erro (INPUT p-cooper,
                           INPUT p-cod-agencia,
                           INPUT aux_nrdcaixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
                           
                UNDO TRANS_FAT, RETURN "NOK".
        END.
        
    CREATE craplft.
    ASSIGN craplft.cdcooper = crapcop.cdcooper
           craplft.nrdconta = p-nrdconta
           craplft.dtmvtolt = craplot.dtmvtolt
           craplft.cdagenci = craplot.cdagenci
           craplft.cdbccxlt = craplot.cdbccxlt
           craplft.nrdolote = craplot.nrdolote
           craplft.cdseqfat = p-cdseqfat
           craplft.vllanmto = p-vlfatura
           craplft.cdhistor = crapcon.cdhistor
           craplft.nrseqdig = craplot.nrseqdig + 1
           craplft.nrdigfat = p-nrdigfat
           craplft.dtvencto = crapdat.dtmvtocd
           craplft.cdbarras = p-codigo-barras
           craplft.insitfat = 1    
           craplft.cdempcon = crapcon.cdempcon
           craplft.cdsegmto = crapcon.cdsegmto
           craplft.tpcptdoc = par_tpcptdoc
           craplft.tppagmto = p-tppagmto
           craplot.nrseqdig = craplot.nrseqdig + 1
           craplot.qtcompln = craplot.qtcompln + 1
           craplot.qtinfoln = craplot.qtinfoln + 1
           craplot.vlcompcr = craplot.vlcompcr + p-vlfatura
           craplot.vlinfocr = craplot.vlinfocr + p-vlfatura.
    VALIDATE craplot.

    /* Dados do TAA */                    
    ASSIGN craplft.cdcoptfn = par_cdcoptfn 
           craplft.cdagetfn = par_cdagetfn 
           craplft.nrterfin = par_nrterfin.

    /* DARF PRETO EUROPA */
    IF (crapcon.cdempcon = 64  AND  /* DARFC0064 */
        crapcon.cdsegmto = 5 ) OR  
       (crapcon.cdempcon = 153 AND  /* DARFC0153 */
        crapcon.cdsegmto = 5 ) THEN
        DO:
            /* Calculo da Data Limite */
            { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

            /* Efetuar a chamada a rotina Oracle CXON0014.pc_ret_ano_barras_darf_car */ 
            RUN STORED-PROCEDURE pc_ret_ano_barras_darf_car
             aux_handproc = PROC-HANDLE NO-ERROR (INPUT INT(SUBSTR(p-codigo-barras,20,1)), /* pr_innumano*/
                                                 OUTPUT 0).                /* pr_outnumano */                                                                         
            
            /* Fechar o procedimento para buscarmos o resultado */ 
            CLOSE STORED-PROC pc_ret_ano_barras_darf_car
                aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 

            { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

            ASSIGN aux_inanocal = pc_ret_ano_barras_darf_car.pr_outnumano
                                     WHEN pc_ret_ano_barras_darf_car.pr_outnumano <> ?.

            RUN retorna-data-dias (INPUT INT(SUBSTR(p-codigo-barras,21,3)),
                                   INPUT aux_inanocal,
                                  OUTPUT aux_dtlimite).

            /* Calculo do Periodo de Apuracao */
            { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

            /* Efetuar a chamada a rotina Oracle CXON0014.pc_ret_ano_barras_darf_car */ 
            RUN STORED-PROCEDURE pc_ret_ano_barras_darf_car
             aux_handproc = PROC-HANDLE NO-ERROR (INPUT INT(SUBSTR(p-codigo-barras,41,1)), /* pr_innumano*/
                                                 OUTPUT 0).                /* pr_outnumano */                                                                         
            
            /* Fechar o procedimento para buscarmos o resultado */ 
            CLOSE STORED-PROC pc_ret_ano_barras_darf_car
                aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 

            { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

            ASSIGN aux_inanocal = pc_ret_ano_barras_darf_car.pr_outnumano
                                     WHEN pc_ret_ano_barras_darf_car.pr_outnumano <> ?.

            RUN retorna-data-dias (INPUT INT(SUBSTR(p-codigo-barras,42,3)),
                                   INPUT aux_inanocal,
                                  OUTPUT aux_dtapurac).

            ASSIGN craplft.tpfatura = 2  /* ( Darf – ARF) */
                   craplft.dtlimite = aux_dtlimite
                   craplft.dtapurac = aux_dtapurac
                   craplft.cdtribut = SUBSTR(p-codigo-barras,37,4).

            /* Grava CPF ou CNPJ dependendo da posição 24 */
            IF  INTE(SUBSTR(p-codigo-barras,24,1)) = 0 THEN
                ASSIGN craplft.nrcpfcgc = SUBSTR(p-codigo-barras,25,11).
            ELSE
            IF  INTE(SUBSTR(p-codigo-barras,24,1)) = 1 THEN
                DO:
                    RUN sistema/generico/procedures/b1wgen9998.p PERSISTEN SET h-b1wgen9998.
                    RUN retorna-digito-cnpj IN h-b1wgen9998 (INPUT DECI(SUBSTR(p-codigo-barras,25,12)),
                                                            OUTPUT aux_nrdigito).
            
                    DELETE PROCEDURE h-b1wgen9998.
            
                    ASSIGN craplft.nrcpfcgc = STRING(SUBSTR(p-codigo-barras,25,12) + "" + STRING(aux_nrdigito, "99")).
                END.
        END.

    /* DARF SIMPLES */
    IF (crapcon.cdempcon = 154  AND  /* DARFS0154 */
        crapcon.cdsegmto = 5  ) THEN 
        DO: 

            RUN retorna-ano-cdbarras (INPUT INT(SUBSTR(p-codigo-barras,20,1)),
                                      INPUT FALSE, /* DARF SIMPLES */
                                     OUTPUT aux_inanocal).

            RUN retorna-data-dias (INPUT INT(SUBSTR(p-codigo-barras,21,3)),
                                   INPUT aux_inanocal,
                                  OUTPUT aux_dtapurac).

            ASSIGN craplft.dtapurac = aux_dtapurac
                   craplft.nrcpfcgc = SUBSTR(p-codigo-barras,24,8)
                   craplft.vlrecbru = DECI(SUBSTR(p-codigo-barras,32,9))
                   craplft.vlpercen = DECI(SUBSTR(p-codigo-barras,41,4))
                   craplft.tpfatura = 2.
        END.

    /* DARFC0385 (DARF NUMERADO) */
    IF (crapcon.cdempcon = 385  AND
        crapcon.cdsegmto = 5  ) THEN
        DO:
            /* Calculo da Data Limite */
            RUN retorna-ano-cdbarras (INPUT INT(SUBSTR(p-codigo-barras,20,2)),
                                      INPUT TRUE, /* DARF NUMERADO / DAS */
                                     OUTPUT aux_inanocal).

            RUN retorna-data-dias (INPUT INT(SUBSTR(p-codigo-barras,22,3)),
                                   INPUT aux_inanocal,
                                  OUTPUT aux_dtlimite).

            ASSIGN craplft.dtlimite = aux_dtlimite
                   craplft.tpfatura = 2.

        END.

    /* DAS - SIMPLES NACIONAL */
    IF (crapcon.cdempcon = 328  AND
        crapcon.cdsegmto = 5  )THEN
        DO:
            /* Calculo da Data Limite */
            RUN retorna-ano-cdbarras (INPUT INT(SUBSTR(p-codigo-barras,20,2)),
                                      INPUT TRUE, /* DARF NUMERADO / DAS */
                                     OUTPUT aux_inanocal).

            RUN retorna-data-dias (INPUT INT(SUBSTR(p-codigo-barras,22,3)),
                                   INPUT aux_inanocal,
                                  OUTPUT aux_dtlimite).

            ASSIGN craplft.dtlimite = aux_dtlimite
                   craplft.tpfatura = 1.
        END.

    IF  craplft.tpfatura = 1    OR
      ((craplft.cdempcon = 64   AND  /* DARF PRETO EUROPA - DARFC0064 */
        craplft.cdsegmto = 5)   OR
       (craplft.cdempcon = 153  AND  /* DARF PRETO EUROPA - DARFC0153 */
        craplft.cdsegmto = 5)   OR
       (craplft.cdempcon = 385  AND  /* DARFC0385 (DARF NUMERADO) */
        craplft.cdsegmto = 5)   OR
       (craplft.cdempcon = 154  AND  /* DARF SIMPLES - DARFS0154 */
        craplft.cdsegmto = 5))  THEN 
        ASSIGN aux_cdempres = crapscn.cdempres WHEN AVAIL crapscn.
    ELSE 
        ASSIGN aux_cdempres = "".

    ASSIGN p-pg     = NO
           p-docto  = craplft.nrseqdig
           p-histor = craplft.cdhistor.

    RUN dbo/b1crap00.p PERSISTENT SET h-b1crap00.
    RUN grava-autenticacao-internet IN h-b1crap00
                                         (INPUT p-cooper,
                                          INPUT p-nrdconta,
                                          INPUT p-idseqttl,
                                          INPUT p-cod-agencia,
                                          INPUT p-nro-caixa,
                                          INPUT p-cod-operador,
                                          INPUT DEC(p-vlfatura),
                                          INPUT p-docto, 
                                          INPUT p-pg, /* YES (PG), NO (REC) */
                                          INPUT "1",  /* On-line            */
                                          INPUT NO,   /* Nao estorno        */
                                          INPUT p-histor, 
                                          INPUT ?, /* Data off-line */
                                          INPUT 0, /* Sequencia off-line */
                                          INPUT 0, /* Hora off-line */
                                          INPUT 0, /* Seq.orig.Off-line */
                                          INPUT aux_cdempres,
                                         OUTPUT p-literal,
                                         OUTPUT p-ult-sequencia,
                                         OUTPUT p-registro).

    DELETE PROCEDURE h-b1crap00.

    IF  RETURN-VALUE = "NOK" THEN
            UNDO TRANS_FAT, RETURN "NOK".

    IF  aux_cdempres <> "" THEN
        RUN gera-recibo-darf (INPUT p-cooper,
                              INPUT p-cod-agencia,
                              INPUT p-nro-caixa,
                              INPUT crapcon.cdempcon,
                              INPUT crapcon.cdsegmto,
                              INPUT p-literal,
                              INPUT p-registro,
                             OUTPUT p-literal).

    IF  RETURN-VALUE = "NOK" THEN
            UNDO TRANS_FAT, RETURN "NOK".

    /* Atualiza sequencia Autenticacao */
    ASSIGN craplft.nrautdoc = p-ult-sequencia.

        VALIDATE craplft.    

    END.

    ASSIGN p-ult-sequencia-r = p-ult-sequencia
           p-literal-r       = p-literal.

    RELEASE craplft NO-ERROR.
    RELEASE craplot NO-ERROR.

    RETURN "OK".

END PROCEDURE.


PROCEDURE verifica_digito:

  /**********************************************************************
   Procedure para calcular e conferir o digito verificador pelo modulo onze 
   das faturas de arrecadacao pagas manualmente - GNRE.
  **********************************************************************/
    DEF        INPUT  PARAM par_nrcalcul AS DECI                        NO-UNDO.
    DEF        OUTPUT PARAM par_nrdigito AS INTE                        NO-UNDO.
                                                                       
    
    DEF        VAR aux_posicao  AS INT     INIT 0                      NO-UNDO.
    DEF        VAR aux_peso     AS INT     INIT 2                      NO-UNDO.
    DEF        VAR aux_calculo  AS INT     INIT 0                      NO-UNDO.
    DEF        VAR aux_resto    AS INT     INIT 0                      NO-UNDO.
    
    DO  aux_posicao = LENGTH(STRING(par_nrcalcul)) TO 1 BY -1:

        aux_calculo = aux_calculo + (INTEGER(SUBSTRING(STRING(par_nrcalcul),
                                                aux_posicao,1)) * aux_peso).

        aux_peso = aux_peso + 1.

        IF   aux_peso > 9   THEN
             aux_peso = 2.

    END.  /*  Fim do DO .. TO  */
    
    ASSIGN aux_resto = aux_calculo MODULO 11.
    
    IF  aux_resto > 9   THEN
        par_nrdigito = 1. 
    ELSE 
    IF  aux_resto = 1 OR 
        aux_resto = 0 THEN
        par_nrdigito = 0.    
    ELSE                      
        ASSIGN par_nrdigito = 11 - aux_resto.

    RETURN "OK".

END PROCEDURE.


PROCEDURE busca_sequencial_fatura:

    DEF INPUT  PARAM par_cdhistor     LIKE crapcon.cdhistor                 NO-UNDO.
    DEF INPUT  PARAM p-codigo-barras  AS CHAR                               NO-UNDO.
    DEF OUTPUT PARAM p-cdseqfat       AS DEC                                NO-UNDO.

    IF  par_cdhistor  = 308  THEN  /*  Telesc Brasil Telecom  */
        ASSIGN p-cdseqfat = DECIMAL(SUBSTR(p-codigo-barras,20,20)).
    ELSE
    IF  par_cdhistor  = 374 THEN     /*  Embratel  */
        ASSIGN p-cdseqfat =  DECIMAL(SUBSTR(p-codigo-barras,21,13)).
    ELSE
    IF  par_cdhistor = 398   OR   /* Prefeitura Gaspar */
        par_cdhistor = 663   THEN /* Prefeitura de Pomerode */
        ASSIGN p-cdseqfat = DECIMAL(SUBSTR(p-codigo-barras,20,25)). 
    ELSE
    IF  par_cdhistor = 456  OR   /* Aguas Itapema */
        par_cdhistor = 964  THEN /* Aguas de Massaranduba */
        ASSIGN p-cdseqfat = DECIMAL(SUBSTR(p-codigo-barras,30,13)). 
    ELSE
    IF  par_cdhistor = 618 OR   /* Samae Pomerode */
        par_cdhistor = 899 THEN /* Samae Rio Negrinho */
        ASSIGN p-cdseqfat = DECIMAL(SUBSTR(p-codigo-barras,25,14)). 
    ELSE     
    IF  par_cdhistor = 625   OR 
        par_cdhistor = 666   THEN   /* CELESC */
    ASSIGN p-cdseqfat = DECIMAL(SUBSTR(p-codigo-barras,27,16)). 
    ELSE
    IF  par_cdhistor = 659   OR   /* P.M.Itajai */
        par_cdhistor = 464   OR   /* Aguas Pres.Getulio */
        par_cdhistor = 929   OR   /* CERSAD */ 
        par_cdhistor = 963   THEN /* Foz do Brasil */ 
        ASSIGN p-cdseqfat = DECIMAL(SUBSTR(p-codigo-barras,28, 17)).
    ELSE
    IF  par_cdhistor = 671 THEN  /**DAE Navegantes**/
        ASSIGN p-cdseqfat = DECIMAL(SUBSTR(p-codigo-barras,29,14)).
    ELSE 
    IF  par_cdhistor = 373 THEN  /**IPTU Blumenau**/
        ASSIGN p-cdseqfat = DECIMAL(SUBSTR(p-codigo-barras,28,15)).
    ELSE  
    IF  par_cdhistor = 675 THEN  /** SEMASA Itajai **/
        ASSIGN p-cdseqfat = DECIMAL(SUBSTR(p-codigo-barras,30,14)).
    ELSE /*  Casan e outros */
        ASSIGN p-cdseqfat =  DECIMAL(SUBSTR(p-codigo-barras,7,38)).

    RETURN "OK".

END PROCEDURE.

PROCEDURE retorna-data-dias:

  /************************************************************************
   Procedure para calcular a data do ano com base no nro. de dias passados
  *************************************************************************/

    DEF        INPUT  PARAM par_nrdedias AS INTE                       NO-UNDO.
    DEF        INPUT  PARAM par_inanocal AS INTE                       NO-UNDO.
    DEF        OUTPUT PARAM par_datadano AS DATE                       NO-UNDO.
    
    DEF        VAR aux_contador AS INTE    INIT 0                      NO-UNDO.
    DEF        VAR aux_dtinican AS DATE                                NO-UNDO.

    ASSIGN aux_dtinican = DATE(1,1,par_inanocal).

    IF  par_nrdedias <= 0 THEN
        RETURN "NOK".

    DO WHILE aux_contador <> par_nrdedias:

        ASSIGN aux_dtinican = aux_dtinican + 1
               aux_contador = aux_contador + 1.

    END.

    ASSIGN par_datadano = (aux_dtinican - 1).
    
    RETURN "OK".

END PROCEDURE.

PROCEDURE retorna-ano-cdbarras:

  /************************************************************************
             Procedure para calcular o ano com base no Cod. barras
  *************************************************************************/
    DEF        INPUT  PARAM par_innumano AS INTE                       NO-UNDO.
    DEF        INPUT  PARAM par_darfndas AS LOGI                       NO-UNDO.
    DEF        OUTPUT PARAM par_inanocal AS INTE                       NO-UNDO.

    IF  par_darfndas THEN
        DO:
            ASSIGN par_inanocal = 2000 + par_innumano.
            RETURN "OK".
        END.

    IF  par_innumano >= 1 AND
        par_innumano <= 6 THEN
        ASSIGN par_inanocal = 2010 + par_innumano.
    ELSE
    IF  par_innumano >= 7 AND
        par_innumano <= 9 THEN
        ASSIGN par_inanocal = 2000 + par_innumano.
    ELSE
    IF  par_innumano = 0  THEN
        ASSIGN par_inanocal = 2010.
    
    RETURN "OK".

END PROCEDURE.

PROCEDURE gera-recibo-darf:

    DEF    INPUT  PARAM p-cooper              AS CHAR                       NO-UNDO.
    DEF    INPUT  PARAM p-cod-agencia         AS INTE                       NO-UNDO.
    DEF    INPUT  PARAM p-nro-caixa           AS INTE                       NO-UNDO.
    DEF    INPUT  PARAM par_cdempcon          AS INTE                       NO-UNDO.
    DEF    INPUT  PARAM par_cdsegmto          AS INTE                       NO-UNDO.
    DEF    INPUT  PARAM p-lit-autent          AS CHAR                       NO-UNDO.
    DEF    INPUT  PARAM p-registro            AS RECID                      NO-UNDO.
                                                        
    DEF   OUTPUT  PARAM p-literal-comprovante AS CHAR                       NO-UNDO.

    DEF VAR c-literal            AS CHAR    FORMAT "x(48)" EXTENT 100.
    DEF VAR p-literal-autentica  AS CHAR                               NO-UNDO.
    DEF VAR iLnAut               AS INTE                               NO-UNDO.
    DEF VAR iContLn              AS INTE                               NO-UNDO.
    DEF VAR aux_tpdarf           AS INTE                               NO-UNDO.
    DEF VAR in99                 AS INTE                               NO-UNDO.
    DEF VAR aux_cdseqfat         AS CHAR                               NO-UNDO.
    
    FIND crapcop WHERE crapcop.nmrescop = p-cooper NO-LOCK NO-ERROR.

    FIND FIRST crapdat WHERE crapdat.cdcooper = crapcop.cdcooper
                             NO-LOCK NO-ERROR.

    ASSIGN aux_cdseqfat = FILL("0", 17 - LENGTH(STRING(craplft.cdseqfat))) +
                                           TRIM(SUBSTR(STRING(craplft.cdseqfat),1,17)).

    /* DARF PRETO EUROPA */
    IF (par_cdempcon = 64  AND  /* DARFC0064 */
        par_cdsegmto = 5 ) OR  
       (par_cdempcon = 153 AND  /* DARFC0153 */
        par_cdsegmto = 5 ) THEN
        ASSIGN aux_tpdarf = 1.

    
    /* DARF SIMPLES */
     IF (par_cdempcon = 154  AND  /* DARFS0154 */
         par_cdsegmto = 5  ) OR
        (par_cdempcon = 328  AND  /* DAS - SIMPLES NACIONAL */
         par_cdsegmto = 5  ) THEN
         ASSIGN aux_tpdarf = 2.
    
    
    /* DARF NUMERADO / DAS */
     IF (par_cdempcon = 385  AND  /* DARFC0385 */
         par_cdsegmto = 5  ) THEN
         ASSIGN aux_tpdarf = 3.    

    ASSIGN c-literal  = "". /* Limpa o conteudo do vetor */

    ASSIGN iLnAut = 1   
           c-literal[iLnAut] = IF  aux_tpdarf = 2 THEN "        COMPROVANTE DE PAGAMENTO DE DAS         "
                               ELSE                    "          COMPROVANTE DE PAGAMENTO DE           ".

    ASSIGN iLnAut = iLnAut + 1
           c-literal[iLnAut] = IF  aux_tpdarf = 2 THEN "               SIMPLES NACIONAL                 "
                               ELSE                    "               DARF/DARF SIMPLES                ".

    ASSIGN iLnAut = iLnAut + 1
           c-literal[iLnAut] = "          AGENTE ARRECADADOR: CNC 748           ".

    ASSIGN iLnAut = iLnAut + 1
           c-literal[iLnAut] = "         BANCO COOPERATIVO SICREDI S.A.         ".

    ASSIGN iLnAut = iLnAut + 1
           c-literal[iLnAut] = "     DATA DO PAGAMENTO: " + STRING(crapdat.dtmvtocd) + " " +
                               STRING(TIME, "HH:MM:SS") + "     ".

    ASSIGN iLnAut = iLnAut + 1
           c-literal[iLnAut] = "------------------------------------------------".

    ASSIGN iLnAut = iLnAut + 1
           c-literal[iLnAut] = "               CODIGO DE BARRAS                 ".

    ASSIGN iLnAut = iLnAut + 1
           c-literal[iLnAut] = "            " + SUBSTR(craplft.cdbarras,1,11) + " " +
                               SUBSTR(craplft.cdbarras,12,11) + "             ".

    ASSIGN iLnAut = iLnAut + 1
           c-literal[iLnAut] = "            " + SUBSTR(craplft.cdbarras,23,11) + " " +
                               SUBSTR(craplft.cdbarras,34,11) + "             ".

    ASSIGN iLnAut = iLnAut + 1
           c-literal[iLnAut] = "                                                ".
                               

    ASSIGN iLnAut = iLnAut + 1
           c-literal[iLnAut] = IF  aux_tpdarf = 1 THEN "    VALOR TOTAL (R$):      "   +
                               STRING(DECI(craplft.vllanmto + craplft.vlrjuros     +
                                           craplft.vlrmulta),"zzz,zzz,zzz,zz9.99") + "    "
                               ELSE                    "    N. DO DOCUMENTO:    "  + 
                               STRING(aux_cdseqfat, "99.99.99999.9999999-9") + "    ".

    ASSIGN iLnAut = iLnAut + 1
           c-literal[iLnAut] = IF  aux_tpdarf = 1 THEN "                                                "
                               ELSE             "    VALOR TOTAL (R$):      "      +
                               STRING(DECI(craplft.vllanmto + craplft.vlrjuros +
                                           craplft.vlrmulta),"zzz,zzz,zzz,zz9.99") + "    ".

    ASSIGN iLnAut = iLnAut + 1
           c-literal[iLnAut] = IF  aux_tpdarf = 1 THEN "    MODELO APROVADO PELA SRF - ADE CONJUNTO     "
                               ELSE IF  aux_tpdarf = 2 THEN "------------------------------------------------"
                               ELSE "                                                ".

    ASSIGN iLnAut = iLnAut + 1
           c-literal[iLnAut] = IF  aux_tpdarf = 1 THEN      "            CORAT/COTEC N. 001/2006             "
                               ELSE IF  aux_tpdarf = 2 THEN "                  AUTENTICACAO                  "
                               ELSE "    MODELO APROVADO PELA SRF - ADE CONJUNTO     ".

    ASSIGN iLnAut = iLnAut + 1
           c-literal[iLnAut] = IF  aux_tpdarf = 1 THEN "------------------------------------------------"
                               ELSE IF  aux_tpdarf = 2 THEN SUBSTR(p-lit-autent,1,48)
                               ELSE "            CORAT/COTEC N. 001/2006             ".
    
    ASSIGN iLnAut = iLnAut + 1
           c-literal[iLnAut] = IF  aux_tpdarf = 1 THEN "                  AUTENTICACAO                 "
                               ELSE IF  aux_tpdarf = 2 THEN SUBSTR(p-lit-autent,49)
                               ELSE "------------------------------------------------".

    ASSIGN iLnAut = iLnAut + 1
           c-literal[iLnAut] = IF  aux_tpdarf = 1 THEN SUBSTR(p-lit-autent,1,48)
                               ELSE IF  aux_tpdarf = 2 THEN "------------------------------------------------"
                               ELSE "                  AUTENTICACAO                  ".

    ASSIGN iLnAut = iLnAut + 1
           c-literal[iLnAut] = IF  aux_tpdarf = 1 THEN SUBSTR(p-lit-autent,49)
                               ELSE IF  aux_tpdarf = 2 THEN "      GUARDE ESTE COMPROVANTE JUNTO COM O       "
                               ELSE SUBSTR(p-lit-autent,1,48).

    ASSIGN iLnAut = iLnAut + 1
           c-literal[iLnAut] = IF  aux_tpdarf = 1 THEN "------------------------------------------------"
                               ELSE IF  aux_tpdarf = 2 THEN "            DAS - SIMPLES NACIONAL              "
                               ELSE SUBSTR(p-lit-autent,49).

    ASSIGN iLnAut = iLnAut + 1
           c-literal[iLnAut] = IF  aux_tpdarf = 1 THEN "      GUARDE ESTE COMPROVANTE JUNTO COM O       "
                               ELSE IF  aux_tpdarf = 2 THEN "________________________________________________"
                               ELSE "------------------------------------------------".

    IF  (aux_tpdarf = 1) OR 
        (aux_tpdarf = 3) THEN
        DO:
            ASSIGN iLnAut = iLnAut + 1
                   c-literal[iLnAut] = IF  aux_tpdarf = 1 THEN "               DARF/DARF SIMPLES                "
                                       ELSE "      GUARDE ESTE COMPROVANTE JUNTO COM O       ".

            ASSIGN iLnAut = iLnAut + 1
                   c-literal[iLnAut] = IF  aux_tpdarf = 1 THEN "________________________________________________"
                                       ELSE "               DARF/DARF SIMPLES                ".

            IF  aux_tpdarf = 3 THEN
                ASSIGN iLnAut = iLnAut + 1
                   c-literal[iLnAut] = "________________________________________________".

        END.

    ASSIGN iLnAut = iLnAut + 1
           c-literal[iLnAut] = "                                                ".
    ASSIGN iLnAut = iLnAut + 1
           c-literal[iLnAut] = "                                                ".
    ASSIGN iLnAut = iLnAut + 1
           c-literal[iLnAut] = "                                                ".
    ASSIGN iLnAut = iLnAut + 1
           c-literal[iLnAut] = "                                                ".
    ASSIGN iLnAut = iLnAut + 1
           c-literal[iLnAut] = "                                                ".
    ASSIGN iLnAut = iLnAut + 1
           c-literal[iLnAut] = "                                                ".
    ASSIGN iLnAut = iLnAut + 1
           c-literal[iLnAut] = "                                                ".

    ASSIGN p-literal-comprovante = "".

    DO iContLn = 1 TO iLnAut:
        ASSIGN p-literal-comprovante = p-literal-comprovante +
                                     STRING(c-literal[iContLn],"x(48)").
    END.
    
    /* Autenticacao REC */
    ASSIGN in99 = 0. 
    DO  WHILE TRUE:
        
        ASSIGN in99 = in99 + 1.
        FIND crapaut WHERE RECID(crapaut) = p-registro 
                           EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

        IF  NOT AVAIL crapaut THEN  
            DO:
                IF  LOCKED crapaut  THEN 
                    DO:
                        IF  in99 < 10  THEN 
                            DO:
                                PAUSE 1 NO-MESSAGE.
                                NEXT.
                            END.
                        ELSE 
                            DO:
                                ASSIGN i-cod-erro  = 0
                                       c-desc-erro = "Tabela CRAPAUT em uso ".
                                RUN cria-erro (INPUT p-cooper,
                                               INPUT p-cod-agencia,
                                               INPUT p-nro-caixa,
                                               INPUT i-cod-erro,
                                               INPUT c-desc-erro,
                                               INPUT YES).
                                RETURN "NOK".
                            END.
                    END.
                ELSE 
                    DO:
                        ASSIGN i-cod-erro  = 0
                               c-desc-erro = 
                                    "Erro Sistema - CRAPAUT nao Encontrado ".
                        RUN cria-erro (INPUT p-cooper,        
                                       INPUT p-cod-agencia,
                                       INPUT p-nro-caixa,
                                       INPUT i-cod-erro,
                                       INPUT c-desc-erro,
                                       INPUT YES).
                        RETURN "NOK".
                    END.
            END.
        ELSE 
            DO:
                ASSIGN  crapaut.dslitera = p-literal-comprovante.
                RELEASE crapaut.
                LEAVE.
            END.
    END. /* fim do DO WHILE */


END PROCEDURE.

/* Procedures para calculo de DV do numero da DAS e DV's adicionais da DAS */

PROCEDURE calcula_dv_numero_das:

    DEF INPUT  PARAM par_numerdas AS CHAR NO-UNDO.
    DEF INPUT  PARAM par_dvnrodas AS INTE NO-UNDO.
    DEF OUTPUT PARAM par_flagdvok AS LOGI NO-UNDO.

    DEF VAR aux_posicao AS INTE INIT 0 NO-UNDO.
    DEF VAR aux_peso    AS INTE INIT 2 NO-UNDO.
    DEF VAR aux_calculo AS INTE INIT 0 NO-UNDO.
    DEF VAR aux_resto   AS INTE INIT 0 NO-UNDO.
    DEF VAR aux_digito  AS INTE INIT 0 NO-UNDO.

    DO aux_posicao = (LENGTH(par_numerdas)) TO 1 BY -1:
        ASSIGN aux_calculo = aux_calculo + 
                             INTE(SUBSTR(par_numerdas, aux_posicao, 1)) * 
                             aux_peso
               aux_peso    = IF aux_peso = 9 THEN
                                 2
                             ELSE
                                 aux_peso + 1.
    END.

    ASSIGN aux_resto = aux_calculo MODULO 11.

    CASE aux_resto:

        WHEN  0  THEN  ASSIGN aux_digito = 0.
        WHEN  1  THEN  ASSIGN aux_digito = 0.
        WHEN  10 THEN  ASSIGN aux_digito = 1.
    END CASE.
    
    IF aux_resto <> 0  AND
       aux_resto <> 1  AND
       aux_resto <> 10 THEN
        ASSIGN aux_digito = 11 - aux_resto.

    IF aux_digito = par_dvnrodas THEN
        ASSIGN par_flagdvok = TRUE.
    ELSE
        ASSIGN par_flagdvok = FALSE.

END PROCEDURE.

PROCEDURE calcula_dv_adicional:

    DEF INPUT  PARAM par_cdbarras AS CHAR NO-UNDO.
    DEF INPUT  PARAM par_poslimit AS INTE NO-UNDO.
    DEF INPUT  PARAM par_nrdigito AS INTE NO-UNDO.
    DEF OUTPUT PARAM par_flagdvok AS LOGI NO-UNDO.

    DEF VAR aux_digito  AS INT INIT 0 NO-UNDO.
    DEF VAR aux_posicao AS INT INIT 0 NO-UNDO.
    DEF VAR aux_peso    AS INT INIT 2 NO-UNDO.
    DEF VAR aux_calculo AS INT INIT 0 NO-UNDO.
    DEF VAR aux_resto   AS INT INIT 0 NO-UNDO.
    DEF VAR aux_strnume AS CHAR       NO-UNDO.

    ASSIGN aux_strnume = SUBSTR(par_cdbarras, 1, 3) + 
                         SUBSTR(par_cdbarras, 5, par_poslimit).

    DO aux_posicao = (LENGTH(STRING(aux_strnume))) TO 1 BY -1:
        ASSIGN aux_calculo = aux_calculo + 
               INTEGER(SUBSTRING(aux_strnume, aux_posicao, 1)) * aux_peso
               /* Para o calculo do segundo dv adicional (par_poslimit = 38)
                  deve-se utilizar peso de 2 a 42. */
               aux_peso    = IF aux_peso = 9 AND par_poslimit <> 38 THEN
                                 2
                             ELSE 
                                 aux_peso + 1.
    END.

    ASSIGN aux_resto = aux_calculo MODULO 11.

    CASE aux_resto:

        WHEN  0  THEN  ASSIGN aux_digito = 0.
        WHEN  1  THEN  ASSIGN aux_digito = 0.
        WHEN  10 THEN  ASSIGN aux_digito = 1.
    END CASE.
    
    IF aux_resto <> 0  AND
       aux_resto <> 1  AND
       aux_resto <> 10 THEN
        ASSIGN aux_digito = 11 - aux_resto.

    IF aux_digito = par_nrdigito THEN
        ASSIGN par_flagdvok = TRUE.
    ELSE
        ASSIGN par_flagdvok = FALSE.

END PROCEDURE.


/* valida o valor recebido como parâmetro com o limite da agencia / cooperativa e solicita senha do coordenador se for maior */
PROCEDURE valida-valor-limite:

    DEF INPUT PARAM par_cdcooper  AS INTEGER                         NO-UNDO. /* Cooperativa */
    DEF INPUT PARAM par_cdoperad  AS CHARACTER                       NO-UNDO. /* Codigo do coordenador */
    DEF INPUT PARAM par_cdagenci  AS INTEGER                         NO-UNDO. /* PA */
    DEF INPUT PARAM par_nrocaixa  AS INTEGER                         NO-UNDO. /* Caixa */
    DEF INPUT PARAM par_vltitfat  AS DECIMAL                         NO-UNDO. /* Valor a ser comparado com o limite */
    DEF INPUT PARAM par_senha     AS CHARACTER                       NO-UNDO. /* Senha do coordenador */
    DEF OUTPUT PARAM par_des_erro AS CHARACTER                       NO-UNDO. /* Descriçao do erro */
    DEF OUTPUT PARAM par_dscritic AS CHARACTER                       NO-UNDO. /* Descriçao da critica */
    DEF OUTPUT PARAM par_inssenha AS INTEGER                         NO-UNDO. /* Retorna 1 se foi inserida senha do coordenador e passou e 0 se nao precisou inserir a senha - valor abaixo do limite*/

    DEF VARIABLE aux_valorlimite AS DECIMAL                         NO-UNDO.
  
  
    ASSIGN aux_valorlimite = 0
           par_inssenha = 0.
    
    /* Verifica o limite da agencia primeiro */
    FIND crapage WHERE crapage.cdagenci = par_cdagenci 
                       AND crapage.cdcooper = par_cdcooper
                       NO-LOCK NO-ERROR.
    IF AVAILABLE crapage AND crapage.vllimpag > 0 THEN
      DO:
        ASSIGN aux_valorlimite = crapage.vllimpag.
      END.
    ELSE
      /* Se nao tiver, verifica o limite da cooperativa */
      DO:
        FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.
        IF AVAILABLE crapcop AND crapcop.vllimpag > 0 THEN
          DO:
            ASSIGN aux_valorlimite = crapcop.vllimpag.
          END.
      END.
    
    /* Se o valor encontrado (parametrizado) for maior que zero e menor que o valor do título, solicita senha */ 
    IF aux_valorlimite > 0 AND par_vltitfat > aux_valorlimite THEN
      DO:
        IF par_cdoperad = "" THEN
          DO:
            ASSIGN par_des_erro = "Operaçao acima do limite. Informe código e senha do coordenador."
                   par_dscritic = "Operaçao acima do limite. Informe código e senha do coordenador.".
            RETURN "NOK".
          END.
             
        /* Valida o operador */
        FIND crapope WHERE crapope.cdcooper = par_cdcooper   AND
                           crapope.cdoperad = par_cdoperad 
                           NO-LOCK NO-ERROR.
   
        IF NOT AVAILABLE crapope THEN
         DO:
             ASSIGN par_des_erro = "Coordenador nao localizado."
                    par_dscritic = "Coordenador nao localizado.".
             RETURN "NOK".
         END.
        
        IF  crapope.cddsenha <> par_senha THEN
         DO:
             ASSIGN par_des_erro = "Senha inválida."
                    par_dscritic = "Senha inválida.".
             RETURN "NOK".
         END.

        
        /* Nivel 2-Coordenador / 3-Gerente */        
        IF crapope.nvoperad < 2 THEN
           DO:
               ASSIGN par_des_erro = "Usuário nao é coordenador."
                      par_dscritic = "Usuário nao é coordenador.".
               RETURN "NOK".
           END.
           
           ASSIGN par_inssenha = 1.
           
        END. /* aux_valorlimite */
      
    RETURN "OK".
END PROCEDURE.

/* b1crap14.p */

/* ......................................................................... */
