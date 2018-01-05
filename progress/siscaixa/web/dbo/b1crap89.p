/*..............................................................................

Programa: siscaixa/web/dbo/b1crap89.p
Autor   : Andre Santos - SUPERO
Sistema : CAIXA ON-LINE
Sigla   : CRED                               Ultima atualizacao: 20/06/2016

Dados referentes ao programa:

Objetivo  : Validacoes de Arrecadacoes GPS SICREDI - Faturas.

Alteracoes: 20/06/2016 - Incluida validacao da conta para verificar se esta
                         possui INTERNET ativa, caso contrario, nao segue
						 (Guilherme/SUPERO)

            12/09/2017 - Ajustes melhoria 397 - Rafael (Mouts)

            03/01/2018 - M307 - Solicitaçao de senha do coordenador quando 
                         valor do pagamento for superior ao limite cadastrado 
                         na CADCOP / CADPAC
                        (Diogo - MoutS)
..............................................................................*/

{dbo/bo-erro1.i}
DEFINE VARIABLE i-cod-erro    AS INT                 NO-UNDO.
DEFINE VARIABLE c-desc-erro   AS CHAR                NO-UNDO.
DEFINE VARIABLE p-nro-digito  AS INTE                NO-UNDO.
DEFINE VARIABLE p-retorno     AS LOG                 NO-UNDO.
DEFINE VARIABLE de-valor-calc AS DEC                 NO-UNDO.


/* Validacoes da GPS */
PROCEDURE validar-conta:
    /** VALIDAR STATUS DA INTERNET DA CONTA **/
    DEF INPUT  PARAM p-cooper          AS CHAR                    NO-UNDO.
    DEF INPUT  PARAM p-cod-agencia     AS INTE                    NO-UNDO.
    DEF INPUT  PARAM p-nro-caixa       AS INTE                    NO-UNDO.
    DEF INPUT  PARAM p-conta           AS DECI                    NO-UNDO.
    DEF OUTPUT PARAM p-focoCampo       AS CHAR                    NO-UNDO.

    FIND FIRST crapcop WHERE crapcop.nmrescop = p-cooper NO-LOCK.


    IF p-conta > 0 THEN DO:

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
        ELSE DO:

            /*** Situacao de acesso a conta via internet ***/
            IF crapass.idastcjt = 0 THEN DO:
                FIND crapsnh WHERE crapsnh.cdcooper = crapass.cdcooper
                               AND crapsnh.nrdconta = crapass.nrdconta
							   AND crapsnh.tpdsenha = 1 /*Internet*/
                               AND crapsnh.idseqttl = 1 /*1o TIT*/
                  NO-LOCK NO-ERROR.

                IF  NOT AVAILABLE crapsnh
                OR  crapsnh.cdsitsnh <> 1 THEN DO:

                    ASSIGN i-cod-erro  = 0
                           c-desc-erro = "Agendamento não permitido - "  +
                                         "Favor habilitar a Internet e " +
                                         "cadastrar limite diário! " +
                                         "Conta/DV: " + STRING(p-conta)
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
            ELSE DO:
                FOR EACH crappod
                   WHERE crappod.cdcooper = crapass.cdcooper
                     AND crappod.nrdconta = crapass.nrdconta
                     AND crappod.cddpoder = 10
                     AND crappod.flgconju = TRUE NO-LOCK:

                    FOR FIRST crapsnh
                        WHERE crapsnh.cdcooper = crappod.cdcooper
                          AND crapsnh.nrdconta = crappod.nrdconta
                          AND crapsnh.tpdsenha = 1
                          AND crapsnh.nrcpfcgc = crappod.nrcpfpro NO-LOCK:
                    END.

                    IF  NOT AVAIL crapsnh
                    OR  crapsnh.cdsitsnh <> 1 THEN DO:

                        ASSIGN i-cod-erro  = 0
                               c-desc-erro = "Agendamento não permitido - "  +
                                             "Favor habilitar a Internet e " +
                                             "cadastrar limite diário! " +
                                             "Conta/DV: " + STRING(p-conta)
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
            END.
        END.
    END.

    RETURN "OK".

END PROCEDURE.

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
    DEF INPUT  PARAM p-diadebito       AS CHAR                    NO-UNDO.
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


    IF p-conta > 0 THEN DO:
        
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

        IF  p-competencia = "" OR p-competencia = "0" THEN DO:
            ASSIGN i-cod-erro  = 0
                   c-desc-erro = "Compentência (Mes/Ano) é obrigatório preenchimento!"
                   p-focoCampo = "22".
    
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
                       p-focoCampo = "22".
    
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
                       p-focoCampo = "22".
    
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

            IF  aux_compete1 < (MONTH(crapdat.dtmvtolt) - 1) THEN DO:
                ASSIGN i-cod-erro  = 0
                       c-desc-erro = "Agendamento não permitido para competências anteriores. " +
                                     "Para efetivar o pagamento utilize a rotina de Pagamento de GPS!"
                       p-focoCampo = "21".
    
                RUN cria-erro (INPUT p-cooper,
                               INPUT p-cod-agencia,
                               INPUT p-nro-caixa,
                               INPUT i-cod-erro,
                               INPUT c-desc-erro,
                               INPUT YES).
                
                RETURN "NOK".
            END.

            IF  aux_compete2 <> YEAR(crapdat.dtmvtolt) THEN DO:
                ASSIGN i-cod-erro  = 0
                       c-desc-erro = "Agendamento não permitido para competências anteriores. " +
                                     "Para efetivar o pagamento utilize a rotina de Pagamento de GPS!"
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
                   p-focoCampo = "23".
    
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
                   p-focoCampo = "24".
            
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

        IF  INTE(SUBSTR(aux_codbarra,42,2)) < (MONTH(crapdat.dtmvtolt) - 1) THEN DO:
            ASSIGN i-cod-erro  = 0
                   c-desc-erro = "Agendamento não permitido para competências anteriores. " +
                                 "Para efetivar o pagamento utilize a rotina de Pagamento de GPS!"
                   p-focoCampo = "21".

            RUN cria-erro (INPUT p-cooper,
                           INPUT p-cod-agencia,
                           INPUT p-nro-caixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
            
            RETURN "NOK".
        END.

        IF  INTE(SUBSTR(aux_codbarra,38,4)) <> YEAR(crapdat.dtmvtolt) THEN DO:
            ASSIGN i-cod-erro  = 0
                   c-desc-erro = "Agendamento não permitido para competências anteriores. " +
                                 "Para efetivar o pagamento utilize a rotina de Pagamento de GPS!"
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


    /* Validação data do Debito */
    DATE(p-diadebito) NO-ERROR.
    
    IF  ERROR-STATUS:ERROR THEN DO:
    
        ASSIGN i-cod-erro  = 0
               c-desc-erro = "Data do débito está incorreta!"
               p-focoCampo = "28".
    
        RUN cria-erro (INPUT p-cooper,
                       INPUT p-cod-agencia,
                       INPUT p-nro-caixa,
                       INPUT i-cod-erro,
                       INPUT c-desc-erro,
                       INPUT YES).
        
        RETURN "NOK".
    END.
    IF  DATE(p-diadebito) = ? THEN DO:
    
        ASSIGN i-cod-erro  = 0
               c-desc-erro = "Data do débito é obrigatório preenchimento!"
               p-focoCampo = "28".
    
        RUN cria-erro (INPUT p-cooper,
                       INPUT p-cod-agencia,
                       INPUT p-nro-caixa,
                       INPUT i-cod-erro,
                       INPUT c-desc-erro,
                       INPUT YES).
        
        RETURN "NOK".
    END.

    IF  DATE(p-diadebito) > DATE(p-vencimento)
    AND p-tipo = 2  THEN DO:
        ASSIGN i-cod-erro  = 0
               c-desc-erro = "Guia vencida não pode ser agendada!".

               p-focoCampo = "19".
    
        RUN cria-erro (INPUT p-cooper,
                       INPUT p-cod-agencia,
                       INPUT p-nro-caixa,
                       INPUT i-cod-erro,
                       INPUT c-desc-erro,
                       INPUT YES).
        
        RETURN "NOK".
    END.
    
    IF  DATE(p-diadebito) = crapdat.dtmvtolt THEN DO:
        ASSIGN i-cod-erro  = 0
               c-desc-erro = "Data do debito deve ser maior que a data atual! Para " +
                             "pagamentos no dia, deve ser utilizado a Rotina 87!".

               p-focoCampo = "28".
    
        RUN cria-erro (INPUT p-cooper,
                       INPUT p-cod-agencia,
                       INPUT p-nro-caixa,
                       INPUT i-cod-erro,
                       INPUT c-desc-erro,
                       INPUT YES).
        
        RETURN "NOK".
    END.

    IF  DATE(p-diadebito) < crapdat.dtmvtolt THEN DO:
        ASSIGN i-cod-erro  = 0
               c-desc-erro = "Data do debito deve ser maior que a data atual!".

               p-focoCampo = "28".
    
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
               p-focoCampo = "29".
    
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


PROCEDURE pc-efetua-agendamento-gps:

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
    DEF INPUT PARAM p-dtdebito  AS CHAR                               NO-UNDO.
    DEF INPUT PARAM p-idfisjur  AS INTE                               NO-UNDO.
    DEF OUTPUT PARAM p-dslitera AS CHAR                               NO-UNDO.
    DEF OUTPUT PARAM p-nrultaut AS INTE                               NO-UNDO.

    DEF VAR aux_codbarra AS CHAR                                      NO-UNDO.
    DEF VAR aux_lindigit AS CHAR                                      NO-UNDO.
    DEF VAR aux_dtcompet AS CHAR                                      NO-UNDO.
    DEF VAR aux_cdcritic AS INTE                                      NO-UNDO.
    DEF VAR aux_dscritic AS CHAR                                      NO-UNDO.
    DEF VAR aux_dslitera AS LONGCHAR                                  NO-UNDO.
    DEF VAR aux_nrultaut AS INTE                                      NO-UNDO.


    FIND FIRST crapcop WHERE nmrescop = p-cdcooper NO-LOCK.

    /* Se o tamanho do cod.barras for 55 - Monta a Linha Digitavel */
    IF  LENGTH(p-cdbarras) = 55 THEN DO:
        /* Removendo o format para enviar a linha digitavel com 48 posicoes*/
        ASSIGN aux_lindigit = REPLACE(REPLACE(p-cdbarras,"-","")," ","")
               aux_codbarra = "".
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

    RUN STORED-PROCEDURE pc_gps_agmto_novo aux_handproc = PROC-HANDLE NO-ERROR
                        (INPUT crapcop.cdcooper,
                         INPUT p-nrdconta,
                         INPUT p-tpdpagto,
                         INPUT p-cdagenci,
                         INPUT p-nrdcaixa,
                         INPUT 1,          /* par_idseqttl */
                         INPUT 2,          /* par_idorigem */
                         INPUT p-cdoperad,
                         INPUT "CRAP089" , /* nmdatela */
                         INPUT p-idleitur, /* leitura 1-leitora / 0-manual */
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
                         INPUT p-dtdebito,
                         INPUT 0,
                         INPUT 0,
                         INPUT "",
                         OUTPUT "",
                         OUTPUT "",
                         OUTPUT 0,
                         OUTPUT "").

    CLOSE STORED-PROC pc_gps_agmto_novo aux_statproc = PROC-STATUS
          WHERE PROC-HANDLE = aux_handproc.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_dslitera = ""
           aux_nrultaut = 0
           aux_dslitera = pc_gps_agmto_novo.pr_dslitera
                          WHEN pc_gps_agmto_novo.pr_dslitera <> ?
           aux_nrultaut = pc_gps_agmto_novo.pr_cdultseq
                          WHEN pc_gps_agmto_novo.pr_cdultseq <> ?
           aux_dscritic = pc_gps_agmto_novo.pr_dscritic
                          WHEN pc_gps_agmto_novo.pr_dscritic <> ?.
 
    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

    IF  aux_dscritic <> "" THEN DO:

        ASSIGN p-dslitera = ''
               p-nrultaut = 0.

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
    DEF OUTPUT PARAM par_des_erro AS CHARACTER                       NO-UNDO.
    DEF OUTPUT PARAM par_dscritic AS CHARACTER                       NO-UNDO.
    DEF OUTPUT PARAM par_inssenha AS INTEGER                         NO-UNDO.

    DEF VAR aux_inssenha          AS INTEGER                         NO-UNDO.
    DEF VAR h_b1crap14            AS HANDLE                          NO-UNDO.
    
    
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
                       INPUT SUBSTRING(par_dscritic, 1, 200),
                       INPUT YES).
        RETURN "NOK".
     END.
     
    RETURN "OK".

END PROCEDURE.
