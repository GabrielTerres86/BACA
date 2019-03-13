/*..............................................................................

Programa: siscaixa/web/dbo/b1crap87.p
Autor   : Andre Santos - SUPERO
Sistema : CAIXA ON-LINE
Sigla   : CRED                               Ultima atualizacao: 25/01/2019

Dados referentes ao programa:

Objetivo  : Validacoes de Arrecadacoes GPS SICREDI - Faturas.

Alteracoes: 12/09/2017 - Ajustes melhoria 397 - Rafael (Mouts)

            03/01/2018 - M307 - Solicitaçao de senha do coordenador quando 
                         valor do pagamento for superior ao limite cadastrado 
                         na CADCOP / CADPAC
                         (Diogo - MoutS)
                         
            06/06/2018 - Alteracoes para usar as rotinas mesmo com o processo 
                         norturno rodando (Douglas Pagel - AMcom).
                         
            25/01/2019 - P510 - Obrigar selecionar Conta ou Especie, verificar
                         valor maximo legal em especie e propagar para o Oracle (Marcos-Envolti)            
                         
.............................................................................. **/

{dbo/bo-erro1.i}

DEFINE VARIABLE i-cod-erro    AS INT                 NO-UNDO.
DEFINE VARIABLE c-desc-erro   AS CHAR                NO-UNDO.
DEFINE VARIABLE p-nro-digito  AS INTE                NO-UNDO.
DEFINE VARIABLE p-retorno     AS LOG                 NO-UNDO.
DEFINE VARIABLE de-valor-calc AS DEC                 NO-UNDO.

/* Validacoes da GPS */
PROCEDURE validar-gps:
    
    DEF INPUT  PARAM p-cooper          AS CHAR                    NO-UNDO.
    DEF INPUT  PARAM p-cod-agencia     AS INTE                    NO-UNDO.
    DEF INPUT  PARAM p-nro-caixa       AS INTE                    NO-UNDO.
    DEF INPUT  PARAM p-conta           AS DECI                    NO-UNDO.
    DEF INPUT  PARAM p-codbarras       AS CHAR                    NO-UNDO.
    DEF INPUT  PARAM p-tipo            AS INTE                    NO-UNDO.
    DEF INPUT  PARAM p-identificador   AS CHAR                    NO-UNDO.
    DEF INPUT  PARAM p-codigo          AS INTE                    NO-UNDO.
    DEF INPUT  PARAM p-competencia     AS CHAR                    NO-UNDO.
    DEF INPUT  PARAM p-radioTipoPessoa AS INTE                    NO-UNDO.
    DEF INPUT  PARAM p-vencimento      AS CHAR                    NO-UNDO.
    DEF INPUT  PARAM p-vlrdinss        AS DECI                    NO-UNDO.
    DEF INPUT  PARAM p-vloutend        AS DECI                    NO-UNDO.
    DEF INPUT  PARAM p-vlrjuros        AS DECI                    NO-UNDO.
    DEF INPUT  PARAM p-vlrtotal        AS DECI                    NO-UNDO.
    DEF OUTPUT PARAM p-focoCampo       AS CHAR                    NO-UNDO.

    
    DEF VAR aux_lindigit AS CHAR                                  NO-UNDO.
    DEF VAR aux_codbarra AS CHAR                                  NO-UNDO.
    DEF VAR aux_vlrdsoma AS DECI                                  NO-UNDO.
    DEF VAR aux_compete1 AS INTE                                  NO-UNDO.
    DEF VAR aux_compete2 AS INTE                                  NO-UNDO.


    FIND FIRST crapcop WHERE crapcop.nmrescop = p-cooper NO-LOCK.

    FIND FIRST crapdat WHERE crapdat.cdcooper = crapcop.cdcooper NO-LOCK.


    IF  p-conta > 0 THEN DO:
        
        FIND FIRST crapass WHERE crapass.cdcooper = crapcop.cdcooper
                             AND crapass.nrdconta = p-conta
                             NO-LOCK NO-ERROR.
    
        IF  NOT AVAIL crapass THEN DO:
            ASSIGN i-cod-erro  = 9
                   c-desc-erro = ""
                   p-focoCampo = "13".
        
            RUN cria-erro (INPUT p-cooper,
                           INPUT p-cod-agencia,
                           INPUT p-nro-caixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
            
            RETURN "NOK".
        END.

    END.

    IF  p-tipo = 2 THEN DO: /* S/ COD.BARRAS */

        /* Validação Dt. vencimento */
        DATE(p-vencimento) NO-ERROR.
    
        IF  ERROR-STATUS:ERROR THEN DO:
    
            ASSIGN i-cod-erro  = 0
                   c-desc-erro = "Data de vencimento inválida!"
                   p-focoCampo = "19".
    
            RUN cria-erro (INPUT p-cooper,
                           INPUT p-cod-agencia,
                           INPUT p-nro-caixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
            
            RETURN "NOK".
        END.
        IF  DATE(p-vencimento) = ? THEN DO:
    
            ASSIGN i-cod-erro  = 0
                   c-desc-erro = "Data de vencimento é obrigatório preenchimento!"
                   p-focoCampo = "19".
    
            RUN cria-erro (INPUT p-cooper,
                           INPUT p-cod-agencia,
                           INPUT p-nro-caixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
            
            RETURN "NOK".
        END.

    
        IF  DATE(p-vencimento) < crapdat.dtmvtocd THEN DO:
            ASSIGN i-cod-erro  = 0
                   c-desc-erro = "Guia vencida nao pode ser paga!"
                   p-focoCampo = "19".
    
            RUN cria-erro (INPUT p-cooper,
                           INPUT p-cod-agencia,
                           INPUT p-nro-caixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
            
            RETURN "NOK".
        END.

        IF  p-codigo = 0 THEN DO:
            ASSIGN i-cod-erro  = 0
                   c-desc-erro = "Código de pagamento é obrigatório preenchimento!"
                   p-focoCampo = "20".
            
            RUN cria-erro (INPUT p-cooper,
                           INPUT p-cod-agencia,
                           INPUT p-nro-caixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
            
            RETURN "NOK".
        END.

        IF  LENGTH(TRIM(STRING(p-codigo))) < 4 THEN DO:
            ASSIGN i-cod-erro  = 0
                   c-desc-erro = "Código de pagamento inválido!"
                   p-focoCampo = "20".
            
            RUN cria-erro (INPUT p-cooper,
                           INPUT p-cod-agencia,
                           INPUT p-nro-caixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
            
            RETURN "NOK".
        END.

        IF  p-competencia = "" THEN DO:
            ASSIGN i-cod-erro  = 0
                   c-desc-erro = "Compentência (Mes/Ano) é obrigatório preenchimento!"
                   p-focoCampo = "21".
    
            RUN cria-erro (INPUT p-cooper,
                           INPUT p-cod-agencia,
                           INPUT p-nro-caixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
            
            RETURN "NOK".
        END.
        ELSE DO:

            IF  LENGTH(p-competencia) <> 7 THEN DO:
                ASSIGN i-cod-erro  = 0
                       c-desc-erro = "Compentencia invalida!"
                       p-focoCampo = "21".
    
                RUN cria-erro (INPUT p-cooper,
                               INPUT p-cod-agencia,
                               INPUT p-nro-caixa,
                               INPUT i-cod-erro,
                               INPUT c-desc-erro,
                               INPUT YES).
                
                RETURN "NOK".
            END.

            IF  NUM-ENTRIES(p-competencia,"/") <> 2 THEN DO:
                ASSIGN i-cod-erro  = 0
                       c-desc-erro = "Compentencia invalida!"
                       p-focoCampo = "21".
    
                RUN cria-erro (INPUT p-cooper,
                               INPUT p-cod-agencia,
                               INPUT p-nro-caixa,
                               INPUT i-cod-erro,
                               INPUT c-desc-erro,
                               INPUT YES).
                
                RETURN "NOK".
            END.

            ASSIGN aux_compete1 = INTE(ENTRY(1,p-competencia,"/"))
                   aux_compete2 = INTE(ENTRY(2,p-competencia,"/")).

            IF  aux_compete1 < 1 AND aux_compete1 > 13 THEN DO:
                ASSIGN i-cod-erro  = 0
                       c-desc-erro = "Compentencia invalida!"
                       p-focoCampo = "21".
    
                RUN cria-erro (INPUT p-cooper,
                               INPUT p-cod-agencia,
                               INPUT p-nro-caixa,
                               INPUT i-cod-erro,
                               INPUT c-desc-erro,
                               INPUT YES).
                
                RETURN "NOK".
            END.

        END.


        IF  p-identificador = "" THEN DO:
            ASSIGN i-cod-erro  = 0
                   c-desc-erro = "Identificador é obrigatório preenchimento!"
                   p-focoCampo = "22".
    
            RUN cria-erro (INPUT p-cooper,
                           INPUT p-cod-agencia,
                           INPUT p-nro-caixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
            
            RETURN "NOK".
        END.

        ASSIGN aux_vlrdsoma = p-vlrdinss  /* Valor INSS */
                            + p-vloutend  /* Valor de Outras Entidades */
                            + p-vlrjuros. /* Valor de Multa e Juros */
    
        IF  p-vlrtotal <> aux_vlrdsoma THEN DO:
            ASSIGN i-cod-erro  = 0
                   c-desc-erro = "Informacao divergente no Valor Total!"
                   p-focoCampo = "23".
            
            RUN cria-erro (INPUT p-cooper,
                           INPUT p-cod-agencia,
                           INPUT p-nro-caixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
            
            RETURN "NOK".
        END.

    END.
    ELSE DO: /* C/ COD.BARRAS */

        IF  p-codbarras = ""          OR
            LENGTH(p-codbarras) <> 55 AND
            LENGTH(p-codbarras) <> 44 THEN DO:
            ASSIGN i-cod-erro  = 0
                   c-desc-erro = "Codigo de Barras e/ou Linha Digitavel esta incompleta ou invalida!"
                   p-focoCampo = "18".
        
            RUN cria-erro (INPUT p-cooper,
                           INPUT p-cod-agencia,
                           INPUT p-nro-caixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
            
            RETURN "NOK".
        END.

        /* Se o tamanho do cod.barras for 55 - Monta a Linha Digitavel */
        IF  LENGTH(p-codbarras) = 55 THEN DO:
            ASSIGN aux_lindigit = REPLACE(REPLACE(p-codbarras,"-","")," ","")
                   aux_codbarra = SUBSTR(aux_lindigit,1,11)
                                + SUBSTR(aux_lindigit,13,11)
                                + SUBSTR(aux_lindigit,25,11)
                                + SUBSTR(aux_lindigit,37,11).
                            
        END.
        ELSE
        IF  LENGTH(p-codbarras) = 44 THEN DO:
            ASSIGN aux_lindigit = p-codbarras
                   aux_codbarra = p-codbarras.
        END.

        /* Verifica se é uma guia da previdência social */
        IF  INTE(SUBSTR(aux_codbarra,1,3)) <> 858 THEN DO:
            ASSIGN i-cod-erro  =  0
                   c-desc-erro = "Rotina exclusiva para arrecadação de GPS!"
                   p-focoCampo = "18".
        
            RUN cria-erro (INPUT p-cooper,
                           INPUT p-cod-agencia,
                           INPUT p-nro-caixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
            RETURN "NOK".
        END.

        /* Verifica se é uma guia da previdência social */
        IF  INTE(SUBSTR(aux_codbarra,16,4)) <> 0270 THEN DO:
            ASSIGN i-cod-erro  =  0
                   c-desc-erro = "Rotina exclusiva para arrecadação de GPS!"
                   p-focoCampo = "18".
        
            RUN cria-erro (INPUT p-cooper,
                           INPUT p-cod-agencia,
                           INPUT p-nro-caixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
            RETURN "NOK".
        END.

    END.


    IF  p-vlrtotal = 0 THEN DO:
        ASSIGN i-cod-erro  =  0
               c-desc-erro = "Ao menos um dos campos de valor deve ser informado!"
               p-focoCampo = "23".
    
        RUN cria-erro (INPUT p-cooper,
                       INPUT p-cod-agencia,
                       INPUT p-nro-caixa,
                       INPUT i-cod-erro,
                       INPUT c-desc-erro,
                       INPUT YES).
        RETURN "NOK".
    END.

    IF  p-radioTipoPessoa <> 1  AND
        p-radioTipoPessoa <> 2  THEN DO:
        
        ASSIGN i-cod-erro  =  0
               c-desc-erro = "Escolha o tipo de pessoa!"
               p-focoCampo = "27".
    
        RUN cria-erro (INPUT p-cooper,
                       INPUT p-cod-agencia,
                       INPUT p-nro-caixa,
                       INPUT i-cod-erro,
                       INPUT c-desc-erro,
                       INPUT YES).
        RETURN "NOK".
    END.

    p-focoCampo = "13".
    RETURN "OK".
END.


PROCEDURE valida-cdbarras-lindigit.

    DEF INPUT  PARAM p-cooper        AS CHAR                         NO-UNDO.
    DEF INPUT  PARAM p-cod-agencia   AS INTE                         NO-UNDO.
    DEF INPUT  PARAM p-nro-caixa     AS INTE                         NO-UNDO.
    DEF INPUT  PARAM p-codigo-barras AS CHAR                         NO-UNDO.
    DEF INPUT  PARAM p-controle      AS INTE                         NO-UNDO.
    DEF OUTPUT PARAM aux_codbarra    AS CHAR                         NO-UNDO.

    DEF VAR aux_lindigit AS CHAR                                     NO-UNDO.
    DEF VAR aux_lindigi1 AS DECI                                     NO-UNDO.
    DEF VAR aux_lindigi2 AS DECI                                     NO-UNDO.
    DEF VAR aux_lindigi3 AS DECI                                     NO-UNDO.
    DEF VAR aux_lindigi4 AS DECI                                     NO-UNDO.
    DEF VAR aux_nrdigito AS INTE                                     NO-UNDO.

    /* 1-Controle de Agendamento
	   2-Controle de Pagamento */

    FIND FIRST crapcop WHERE crapcop.nmrescop = p-cooper NO-LOCK.

    FIND FIRST crapdat WHERE crapdat.cdcooper = crapcop.cdcooper NO-LOCK.

    /* Verifica se o codigo de barra foi informado */
    IF  p-codigo-barras = ""          OR
        LENGTH(p-codigo-barras) <> 44 AND
        LENGTH(p-codigo-barras) <> 55 THEN DO:

        ASSIGN i-cod-erro  =  0
               c-desc-erro = "Codigo de Barras e/ou Linha Digitavel esta incompleta ou invalida!".
    
        RUN cria-erro (INPUT p-cooper,
                       INPUT p-cod-agencia,
                       INPUT p-nro-caixa,
                       INPUT i-cod-erro,
                       INPUT c-desc-erro,
                       INPUT YES).
        RETURN "NOK".
    END.

    /* Se o tamanho do cod.barras for 55 - Monta a Linha Digitavel */
    IF  LENGTH(p-codigo-barras) = 55 THEN DO:
        ASSIGN aux_lindigit = REPLACE(REPLACE(p-codigo-barras,"-","")," ","")
               aux_lindigi1 = DECI(SUBSTR(aux_lindigit,1,11))
               aux_lindigi2 = DECI(SUBSTR(aux_lindigit,13,11))
               aux_lindigi3 = DECI(SUBSTR(aux_lindigit,25,11))
               aux_lindigi4 = DECI(SUBSTR(aux_lindigit,37,11))
               aux_codbarra = SUBSTR(aux_lindigit,1,11)
                            + SUBSTR(aux_lindigit,13,11)
                            + SUBSTR(aux_lindigit,25,11)
                            + SUBSTR(aux_lindigit,37,11).
    END.
    ELSE
    IF  LENGTH(p-codigo-barras) = 44 THEN DO:
        ASSIGN aux_codbarra = p-codigo-barras
               aux_lindigi1 = 0
               aux_lindigi2 = 0
               aux_lindigi3 = 0
               aux_lindigi4 = 0.
    END.

    /* Verifica se é uma guia da previdência social */
    IF  INTE(SUBSTR(aux_codbarra,1,3)) <> 858 THEN DO:
        ASSIGN i-cod-erro  =  0
               c-desc-erro = "Rotina exclusiva para arrecadação de GPS!".    
        RUN cria-erro (INPUT p-cooper,
                       INPUT p-cod-agencia,
                       INPUT p-nro-caixa,
                       INPUT i-cod-erro,
                       INPUT c-desc-erro,
                       INPUT YES).
        RETURN "NOK".
    END.

    /* Verifica se é uma guia da previdência social */
    IF  INTE(SUBSTR(aux_codbarra,16,4)) <> 0270 THEN DO:
        ASSIGN i-cod-erro  =  0
               c-desc-erro = "Rotina exclusiva para arrecadação de GPS!".
    
        RUN cria-erro (INPUT p-cooper,
                       INPUT p-cod-agencia,
                       INPUT p-nro-caixa,
                       INPUT i-cod-erro,
                       INPUT c-desc-erro,
                       INPUT YES).
        RETURN "NOK".
    END.

    IF  p-controle = 1 THEN DO:

        IF  INTE(SUBSTR(aux_codbarra,42,2)) < INTE(MONTH(crapdat.dtmvtocd) - 1) THEN DO:
            ASSIGN i-cod-erro  = 0
                   c-desc-erro = "Agendamento não permitido para competências anteriores. " +
                                 "Para efetivar o pagamento utilize a rotina de Pagamento de GPS!".
    
            RUN cria-erro (INPUT p-cooper,
                           INPUT p-cod-agencia,
                           INPUT p-nro-caixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
            
            RETURN "NOK".
        END.
    
        IF  INTE(SUBSTR(aux_codbarra,38,4)) <> INTE(YEAR(crapdat.dtmvtocd)) THEN DO:
            ASSIGN i-cod-erro  = 0
                   c-desc-erro = "Agendamento não permitido para competências anteriores. " +
                                 "Para efetivar o pagamento utilize a rotina de Pagamento de GPS!".
    
            RUN cria-erro (INPUT p-cooper,
                           INPUT p-cod-agencia,
                           INPUT p-nro-caixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
            
            RETURN "NOK".
        END.

    END.

    /* Se for Linha Digitavel */
    IF  aux_lindigi1 <> 0 OR
        aux_lindigi2 <> 0 OR
        aux_lindigi3 <> 0 OR
        aux_lindigi4 <> 0 THEN DO:
        /* Valida os campos manuais */

        /* Campo 1 */
        ASSIGN aux_nrdigito = INTE(SUBSTR(aux_lindigit,12,1)).

        /*** Verificacao pelo modulo 11 ***/
        RUN verifica_digito (INPUT  aux_lindigi1,
                             OUTPUT p-nro-digito).

        IF  p-nro-digito <> aux_nrdigito THEN DO: 
            ASSIGN i-cod-erro  = 8           
                   c-desc-erro = "".
                
            RUN cria-erro (INPUT p-cooper,
                           INPUT p-cod-agencia,
                           INPUT p-nro-caixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).

            RETURN "NOK".

        END.

        /* Campo 2 */
        ASSIGN aux_nrdigito = INTE(SUBSTR(aux_lindigit,24,1)).
          
        /***  Verificacao pelo MODULO 11  ***/
        RUN verifica_digito (INPUT aux_lindigi2,
                             OUTPUT p-nro-digito).

        IF  p-nro-digito <> aux_nrdigito  THEN DO: 
            ASSIGN i-cod-erro  = 8           
                   c-desc-erro = "".
                
            RUN cria-erro (INPUT p-cooper,
                           INPUT p-cod-agencia,
                           INPUT p-nro-caixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).

            RETURN "NOK".

        END.
                  
        /* Campo 3 */
        ASSIGN aux_nrdigito = INTE(SUBSTR(aux_lindigit,36,1)).
          
        /*** Verificacao do digito pelo modulo 11 ***/
        RUN verifica_digito (INPUT aux_lindigi3,
                             OUTPUT p-nro-digito).

        IF  p-nro-digito <> aux_nrdigito  THEN DO:
            ASSIGN i-cod-erro  = 8
                   c-desc-erro = "".

            RUN cria-erro (INPUT p-cooper,
                           INPUT p-cod-agencia,
                           INPUT p-nro-caixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).

            RETURN "NOK".
        END.

        /* Campo 4 */
        ASSIGN aux_nrdigito = INTE(SUBSTR(aux_lindigit,48,1)).

        /*** Verificacao do digito pelo modulo 11 ***/
        RUN verifica_digito (INPUT aux_lindigi4,
                            OUTPUT p-nro-digito).
        
        IF  p-nro-digito <> aux_nrdigito  THEN DO: 
            ASSIGN i-cod-erro  = 8           
                   c-desc-erro = "".
            
            RUN cria-erro (INPUT p-cooper,
                           INPUT p-cod-agencia,
                           INPUT p-nro-caixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
           
            RETURN "NOK".

        END.

    END.
    ELSE DO:
    
        /*** Verificacao do digito no modulo 11 ***/
        RUN dbo/pcrap14.p (INPUT-OUTPUT aux_codbarra,
                           OUTPUT p-nro-digito,
                           OUTPUT p-retorno).
    
        IF  NOT p-retorno THEN DO:
            ASSIGN i-cod-erro  = 8
                  c-desc-erro = "".
    
           RUN cria-erro (INPUT p-cooper,
                          INPUT p-cod-agencia,
                          INPUT p-nro-caixa,
                          INPUT i-cod-erro,
                          INPUT c-desc-erro,
                          INPUT YES).
    
            RETURN "NOK".
    
        END.
    END.

    RETURN "OK".

END PROCEDURE.


PROCEDURE verifica_digito:

  /**********************************************************************
   Procedure para calcular e conferir o digito verificador pelo modulo onze 
   das faturas de arrecadacao pagas manualmente - GNRE.
  **********************************************************************/
    DEF INPUT  PARAM par_nrcalcul AS DECI                            NO-UNDO.
    DEF OUTPUT PARAM par_nrdigito AS INTE                            NO-UNDO.
                                                                    
                                               
    DEF VAR aux_posicao  AS INT INIT 0                               NO-UNDO.
    DEF VAR aux_peso     AS INT INIT 2                               NO-UNDO.
    DEF VAR aux_calculo  AS INT INIT 0                               NO-UNDO.
    DEF VAR aux_resto    AS INT INIT 0                               NO-UNDO.
    
    DO aux_posicao = LENGTH(STRING(par_nrcalcul)) TO 1 BY -1:

       ASSIGN aux_calculo = aux_calculo + 
                           (INTEGER(SUBSTRING(STRING(par_nrcalcul),
                                    aux_posicao,1)) * aux_peso)
              aux_peso = aux_peso + 1.

       IF aux_peso > 9   THEN
          ASSIGN aux_peso = 2.

    END.  /*  Fim do DO .. TO  */
    
    ASSIGN aux_resto = aux_calculo MODULO 11.
    
    IF aux_resto > 9   THEN
       par_nrdigito = 1. 
    ELSE 
    IF aux_resto = 1 OR 
       aux_resto = 0 THEN
       ASSIGN par_nrdigito = 0.    
    ELSE                      
       ASSIGN par_nrdigito = 11 - aux_resto.

    RETURN "OK".

END PROCEDURE.


PROCEDURE pc-efetua-gps-pagamento:

    DEF INPUT PARAM p-cdcooper  AS CHAR                               NO-UNDO.
    DEF INPUT PARAM p-cdagenci  AS INTE                               NO-UNDO.
    DEF INPUT PARAM p-nrdcaixa  AS INTE                               NO-UNDO.
    DEF INPUT PARAM p-cdoperad  AS CHAR                               NO-UNDO.
    DEF INPUT PARAM p-nrdconta  LIKE crapass.nrdconta                 NO-UNDO.
    DEF INPUT PARAM p-tpdpagto  AS INTE                               NO-UNDO.
    DEF INPUT PARAM p-idleitur  AS INTE                               NO-UNDO.
    DEF INPUT PARAM p-cdbarras  AS CHAR                               NO-UNDO.
    DEF INPUT PARAM p-cdpagmto  AS INTE                               NO-UNDO.
    DEF INPUT PARAM p-dtcompet  AS CHAR                               NO-UNDO.
    DEF INPUT PARAM p-dsidenti  AS CHAR                               NO-UNDO.
    DEF INPUT PARAM p-vldoinss  AS DECI                               NO-UNDO.
    DEF INPUT PARAM p-vloutent  AS DECI                               NO-UNDO.
    DEF INPUT PARAM p-vlatmjur  AS DECI                               NO-UNDO.
    DEF INPUT PARAM p-vlrtotal  AS DECI                               NO-UNDO.
    DEF INPUT PARAM p-dtvencim  AS CHAR                               NO-UNDO.
    DEF INPUT PARAM p-idfisjur  AS INTE                               NO-UNDO.
    DEF INPUT PARAM p-tppagmto  AS INTE                               NO-UNDO.
    
    DEF OUTPUT PARAM p-dslitera AS CHAR                               NO-UNDO.
    DEF OUTPUT PARAM p-nrultaut AS INTE                               NO-UNDO.


    DEF VAR aux_codbarra AS CHAR                                     NO-UNDO.
    DEF VAR aux_lindigit AS CHAR                                     NO-UNDO.
    DEF VAR aux_dtcompet AS CHAR                                     NO-UNDO.
    DEF VAR aux_cdcritic AS INTE                                     NO-UNDO.
    DEF VAR aux_dscritic AS CHAR                                     NO-UNDO.
    DEF VAR aux_dslitera AS CHAR                                     NO-UNDO.
    DEF VAR aux_nrultaut AS INTE                                     NO-UNDO.


    FIND FIRST crapcop WHERE nmrescop = p-cdcooper NO-LOCK.

    /* Se o tamanho do cod.barras for 55 - Monta a Linha Digitavel */
    IF  LENGTH(p-cdbarras) = 55 THEN DO:
        /* Removendo o format para enviar a linha digitavel com 48 posicoes*/
        ASSIGN aux_lindigit = REPLACE(REPLACE(p-cdbarras,"-","")," ","")
               aux_codbarra = SUBSTR(aux_lindigit,1,11)
                            + SUBSTR(aux_lindigit,13,11)
                            + SUBSTR(aux_lindigit,25,11)
                            + SUBSTR(aux_lindigit,37,11).
    END.
    ELSE
    IF  LENGTH(p-cdbarras) = 44 THEN DO: /* Com codigo de barras - via leitora */
        ASSIGN aux_lindigit = ""
               aux_codbarra = p-cdbarras.
    END.
    ELSE DO:
        IF  p-tpdpagto = 1 THEN DO:
            ASSIGN i-cod-erro  = 0
                   c-desc-erro = "Codigo de Barras e/ou Linha Digitavel "
                               + "esta incompleta ou invalida! ".
            RUN cria-erro (INPUT p-cdcooper,
                           INPUT p-cdagenci,
                           INPUT p-nrdcaixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
            RETURN "NOK".
        END.
    END.

    aux_dtcompet = SUBSTR(p-dtcompet,4,4) + SUBSTR(p-dtcompet,1,2).
    
    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

    RUN STORED-PROCEDURE pc_gps_pagamento aux_handproc = PROC-HANDLE NO-ERROR
                        (INPUT crapcop.cdcooper,
                         INPUT p-nrdconta,
                         INPUT p-cdagenci,
                         INPUT p-nrdcaixa,
                         INPUT 1,
                         INPUT p-tpdpagto,
                         INPUT 2,          /* par_idorigem */
                         INPUT p-cdoperad,
                         INPUT "CRAP087" , /* nmdatela */
                         INPUT p-idleitur, /* indicador de leitura 1-leitora / 0-manual */
                         INPUT 1,          /* par_inproces */
                         INPUT aux_codbarra,
                         INPUT aux_lindigit,
                         INPUT p-cdpagmto,
                         INPUT aux_dtcompet,
                         INPUT p-dsidenti,
                         INPUT p-vldoinss,
                         INPUT p-vloutent,
                         INPUT p-vlatmjur,
                         INPUT p-vlrtotal,
                         INPUT p-dtvencim,
                         INPUT p-idfisjur,
                         INPUT 0, /* NRSEQAGP */ 
                         INPUT 0,
						 INPUT 0, /* Mobile */
						 INPUT "", /* pr_dshistor */
                         INPUT "", /* pr_iptransa */
                         INPUT "", /* pr_iddispos */
                         INPUT p-tppagmto,
						 OUTPUT "", /* protocolo */
                         OUTPUT "",
                         OUTPUT 0,
                         OUTPUT "").

    CLOSE STORED-PROC pc_gps_pagamento aux_statproc = PROC-STATUS
          WHERE PROC-HANDLE = aux_handproc.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_dslitera = ""
           aux_nrultaut = 0
           aux_dslitera = pc_gps_pagamento.pr_dslitera
                          WHEN pc_gps_pagamento.pr_dslitera <> ?
           aux_nrultaut = pc_gps_pagamento.pr_cdultseq
                          WHEN pc_gps_pagamento.pr_cdultseq <> ?
           aux_dscritic = pc_gps_pagamento.pr_dscritic
                          WHEN pc_gps_pagamento.pr_dscritic <> ?.
 
    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

    IF  aux_dscritic <> "" THEN DO:
        ASSIGN i-cod-erro  = aux_cdcritic
               c-desc-erro = aux_dscritic.

        RUN cria-erro (INPUT p-cdcooper,
                       INPUT p-cdagenci,
                       INPUT p-nrdcaixa,
                       INPUT i-cod-erro,
                       INPUT c-desc-erro,
                       INPUT YES).
        RETURN "NOK".
    END.
    
    ASSIGN p-dslitera = aux_dslitera 
           p-nrultaut = aux_nrultaut.

    RETURN "OK".

END PROCEDURE.


PROCEDURE validar-valor-limite:

    DEF INPUT PARAM par_nmrescop  AS CHARACTER                       NO-UNDO.
    DEF INPUT PARAM par_cdoperad  AS CHARACTER                       NO-UNDO.
    DEF INPUT PARAM par_cdagenci  AS INTEGER                         NO-UNDO.
    DEF INPUT PARAM par_nrocaixa  AS INTEGER                         NO-UNDO.
    DEF INPUT PARAM par_vltitfat  AS DECIMAL                         NO-UNDO.
    DEF INPUT PARAM par_senha     AS CHARACTER                       NO-UNDO.
    DEF INPUT PARAM par_tppagmto  AS INTEGER                         NO-UNDO.
    DEF OUTPUT PARAM par_des_erro AS CHARACTER                       NO-UNDO.
    DEF OUTPUT PARAM par_dscritic AS CHARACTER                       NO-UNDO.
    DEF OUTPUT PARAM par_inssenha AS INTEGER                         NO-UNDO.

    DEF VAR aux_inssenha          AS INTEGER                         NO-UNDO.
    DEF VAR h_b1crap14            AS HANDLE                          NO-UNDO.
    
    DEF VAR aux_dscritic            AS CHARACTER                NO-UNDO.
          DEF VAR aux_cdcritic            AS INTEGER                  NO-UNDO.
          DEF VAR aux_vllimite_especie    AS DECIMAL                  NO-UNDO.
    
    FIND crapcop WHERE crapcop.nmrescop = par_nmrescop NO-LOCK NO-ERROR.
    IF NOT AVAILABLE crapcop THEN
      DO: 
        RUN cria-erro (INPUT par_nmrescop,
                       INPUT par_cdagenci,
                       INPUT par_nrocaixa,
                       INPUT 0,
                       INPUT "Cooperativa nao encontrada.",
                       INPUT YES).
        RETURN "NOK".
      END.
      
    
    /* Buscar valor limite de pagamentos em especie */
    IF  par_tppagmto = 1 THEN DO:        
        
        { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
        RUN STORED-PROCEDURE pc_lim_pagto_especie_pld
          aux_handproc = PROC-HANDLE NO-ERROR
          (INPUT crapcop.cdcooper,
           OUTPUT 0,
           OUTPUT 0,
           OUTPUT "").

        CLOSE STORED-PROC pc_lim_pagto_especie_pld
            aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

        { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
        
        ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_vllimite_especie = 0
           aux_cdcritic = pc_lim_pagto_especie_pld.pr_cdcritic 
                    WHEN pc_lim_pagto_especie_pld.pr_cdcritic <> ?
           aux_dscritic = pc_lim_pagto_especie_pld.pr_dscritic 
                    WHEN pc_lim_pagto_especie_pld.pr_dscritic <> ?
           aux_vllimite_especie = pc_lim_pagto_especie_pld.pr_vllimite_pagto_especie 
                    WHEN pc_lim_pagto_especie_pld.pr_vllimite_pagto_especie <> ?.
        
        /* Se o valor ultrapassa o limite */
        IF aux_vllimite_especie <= par_vltitfat THEN
        DO:

            RUN cria-erro (INPUT par_nmrescop,
                           INPUT par_cdagenci,
                           INPUT par_nrocaixa,
                           INPUT 0,
                           INPUT "Valor de pagamento excede o permitido para a operação em espécie. Serão aceitos somente pagamentos inferiores a R$ " 
                               + TRIM(STRING(aux_vllimite_especie,'zzz,zzz,zz9.99')) + " (Resolução CMN 4.648/18).",
                           INPUT YES).
                           
            RUN cria-erro (INPUT par_nmrescop,
                           INPUT par_cdagenci,
                           INPUT par_nrocaixa,
                           INPUT 0,
                           INPUT "Necessário depositar o recurso em conta e após isso proceder com o pagamento nos canais digitais ou no caixa online - Rotina 87 opção ~"Conta~".",
                           INPUT YES).               
                           
            RETURN "NOK".
        END.
        
      END.
      
    
    RUN dbo/b1crap14.p PERSISTENT SET h_b1crap14.
                           
    RUN valida-valor-limite IN h_b1crap14(INPUT crapcop.cdcooper,
                                          INPUT par_cdoperad,
                                          INPUT par_cdagenci,
                                          INPUT par_nrocaixa,
                                          INPUT par_vltitfat,
                                          INPUT par_senha,
                                          OUTPUT par_des_erro,
                                          OUTPUT par_dscritic,
                                          OUTPUT par_inssenha).
    DELETE PROCEDURE h_b1crap14.
    
    IF RETURN-VALUE = 'NOK' THEN  
     DO:
        RUN cria-erro (INPUT par_nmrescop,
                       INPUT par_cdagenci,
                       INPUT par_nrocaixa,
                       INPUT 0,
                       INPUT par_dscritic,
                       INPUT YES).
        RETURN "NOK".
     END.
     
    RETURN "OK".

END PROCEDURE.
