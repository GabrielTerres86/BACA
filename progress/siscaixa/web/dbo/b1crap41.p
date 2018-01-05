/* ............................................................................
 
   Programa: siscaixa/web/dbo/b1crap41.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Lucas Lunelli
   Data    : Maio/2013                       Ultima atualizacao: 05/09/2016

   Dados referentes ao programa:

   Frequencia: Diario (Caixa Online).
   Objetivo  : Tratar validação e pagamento de DARFs sem Cod de Barras

   Alteracoes: 22/05/2013 - Bloqueio pagamento DARFs (Lucas).
    
               31/05/2013 - Não permitir pagamento de DARFs abaixo de
                            R$ 10,00 (Lucas).
                            
               12/06/2013 - Incluir Multa e Juros ao gravar valores
                            na craplot (Lucas).
                            
               19/06/2013 - Tratamento para foco e criação da procedure
                            "valida-cpfcnpj-cdtrib" para validação de 
                            CPF/CNPJ de acordo com o Tp de Tributo (Lucas).
                            
               02/07/2013 - Adicionado valores ao sequencial da fatura 
                          - Validação para não permitir data vecmto. 
                            menor que 01/01/1950 (Lucas).
                            
               05/08/2013 - Alterada composição do sequencial da fatura (Lucas).
               
               02/10/2013 - Corrigido erro de validação de Nr. de Referencia e 
                            limitar Seq. de Fat. a 38 posições (Lucas).
                            
               14/10/2013 - Correção na validação de Digitos da Opção B da
                            verificação dos Número de Refencia (Lucas).
               
               16/12/2013 - Adicionado validate para as tabelas craplot,
                            craplft (Tiago). 
                            
               30/09/2015 - Alterada para Oracle a consulta da craplft na procedure 
                           'retorna-valores-fatura' pois DataServer não suporta as mais
                            de 34 posições do campo cdseqfat (Lunelli - SD. 328945)
               
               05/09/2016 - Incluir validacao de cpf/cnpj aqui nesta rotina e nao mais na 
                            pcrap06.p como fazia antes (Lucas Ranghetti #503544)

               03/01/2018 - M307 - Solicitaçao de senha do coordenador quando 
                             valor do pagamento for superior ao limite cadastrado 
                             na CADCOP / CADPAC
                            (Diogo - MoutS)
                                 
............................................................................ */

{dbo/bo-erro1.i}

DEF VAR i-cod-erro         AS INTEGER.
DEF VAR c-desc-erro        AS CHAR.
DEF VAR p-literal          AS CHAR                       NO-UNDO.
DEF VAR p-ult-sequencia    AS INTE                       NO-UNDO.
DEF var p-registro         AS RECID                      NO-UNDO.

DEFINE VARIABLE h-b1crap00 AS HANDLE                     NO-UNDO.
DEF    VAR iHandle         AS INTEGER                    NO-UNDO.

DEF TEMP-TABLE tt-erro NO-UNDO LIKE craperr.

PROCEDURE msg-inicial:

    DEF INPUT PARAM par_nmrescop   AS CHAR               NO-UNDO.
    DEF INPUT PARAM par_cdagenci   AS INTE               NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa   AS INTE               NO-UNDO.

    RUN elimina-erro (INPUT par_nmrescop,
                      INPUT par_cdagenci,
                      INPUT par_nrdcaixa).

    ASSIGN i-cod-erro  = 0 
           c-desc-erro = "ATENCAO - utilize essa rotina apenas para efetuar " +
                         "pagamento de DARFs sem código de barras. Esta guia deve conter duas autenticações.". 

    RUN cria-erro (INPUT par_nmrescop,
                   INPUT par_cdagenci,
                   INPUT par_nrdcaixa,
                   INPUT i-cod-erro,
                   INPUT c-desc-erro,
                   INPUT YES).
    RETURN "MAX".

END PROCEDURE.

PROCEDURE valida-cpfcnpj-cdtrib:

    DEF INPUT  PARAM par_nmrescop   AS CHAR               NO-UNDO.
    DEF INPUT  PARAM par_cdagenci   AS INTE               NO-UNDO.
    DEF INPUT  PARAM par_nrdcaixa   AS INTE               NO-UNDO.
    DEF INPUT  PARAM par_cdtribut   AS CHAR               NO-UNDO.
    DEF INPUT  PARAM par_nrcpfcgc   AS CHAR               NO-UNDO.
    DEF OUTPUT PARAM par_foco       AS CHAR               NO-UNDO.

    DEF VAR aux_flgretor          AS LOGI                 NO-UNDO.
    DEF VAR aux_tppessoa          AS INTE                 NO-UNDO.    

    RUN elimina-erro (INPUT par_nmrescop,
                      INPUT par_cdagenci,
                      INPUT par_nrdcaixa).

    /* Verifica o número de digitos do CPF/CNPJ */
    IF  LENGTH(par_nrcpfcgc) <> 11 AND
        LENGTH(par_nrcpfcgc) <> 14 THEN
        DO:
            ASSIGN i-cod-erro  = 27
                   c-desc-erro = ""
                   par_foco    = "10".

            RUN cria-erro (INPUT par_nmrescop,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).

            RETURN "NOK".
        END.
    
    FIND crapstb WHERE crapstb.cdtribut = INTE(par_cdtribut) NO-LOCK NO-ERROR.

    IF  NOT AVAIL crapstb THEN
        DO:
            ASSIGN i-cod-erro  = 0
                   c-desc-erro = "Tributo nao cadastrado."
                   par_foco    = "11".

            RUN cria-erro (INPUT par_nmrescop,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).

            RETURN "NOK".
        END.

    IF  SUBSTRING(crapstb.dsrestri,3,1) = "S" THEN
        DO:
            IF  LENGTH(par_nrcpfcgc) <> 11 THEN
                DO:
                    ASSIGN i-cod-erro  = 0
                           c-desc-erro = "Numero de digitos do CPF incorreto."
                           par_foco    = "10".
                
                    RUN cria-erro (INPUT par_nmrescop,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT i-cod-erro,
                                   INPUT c-desc-erro,
                                   INPUT YES).
                
                    RETURN "NOK".
                END.
        END.

    IF  SUBSTRING(crapstb.dsrestri,4,1) = "S" THEN
        DO:
            IF  LENGTH(par_nrcpfcgc) <> 14 THEN
                DO:
                    ASSIGN i-cod-erro  = 0
                           c-desc-erro = "Numero de digitos do CNPJ incorreto."
                           par_foco    = "10".
                
                    RUN cria-erro (INPUT par_nmrescop,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT i-cod-erro,
                                   INPUT c-desc-erro,
                                   INPUT YES).
                
                    RETURN "NOK".
                END.
        END.

     /* Valida CPF/CNPJ 
       Rotina do programa - pcrap06.p */
    IF  DEC(par_nrcpfcgc) = 9571   THEN
        ASSIGN aux_flgretor = FALSE
               aux_tppessoa  = 1.       /*  Valor default  */      

    IF  LENGTH(par_nrcpfcgc) = 11 OR LENGTH(par_nrcpfcgc) = 10 OR
        LENGTH(par_nrcpfcgc) =  9 OR LENGTH(par_nrcpfcgc) =  8 OR
        LENGTH(par_nrcpfcgc) =  7 THEN 
        DO:
            ASSIGN aux_tppessoa = 1.          /*  Pessoa fisica  */
            RUN dbo/pcrap07.p (INPUT DEC(par_nrcpfcgc),
                              OUTPUT aux_flgretor).

            IF  NOT aux_flgretor THEN 
                DO:
                   ASSIGN aux_tppessoa = 2.                      
                   RUN dbo/pcrap08.p (INPUT DEC(par_nrcpfcgc),
                                     OUTPUT aux_flgretor).
             
                END.
        END.
        ELSE
        DO:        
             IF  LENGTH(STRING(par_nrcpfcgc)) < 15 AND
                 LENGTH(STRING(par_nrcpfcgc)) > 2   THEN  
                 DO:             
                     ASSIGN aux_tppessoa = 2.   /*  Pessoa juridica  */                 
                     RUN dbo/pcrap08.p (INPUT DEC(par_nrcpfcgc),
                                       OUTPUT aux_flgretor).
                 END.
             ELSE
                 ASSIGN aux_flgretor = FALSE
                        aux_tppessoa = 1.       /*  Valor default  */
        END.
    /* pcrap06.p */
    
    IF  NOT aux_flgretor THEN
        DO:
            ASSIGN i-cod-erro  = 27
                   par_foco    = "10".
        
            RUN cria-erro (INPUT par_nmrescop,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
        
            RETURN "NOK".
        END.

    RETURN "OK".

END PROCEDURE.

PROCEDURE valida-pagamento-darf:

    DEF INPUT PARAM par_nmrescop   AS CHAR               NO-UNDO.
    DEF INPUT PARAM par_cdagenci   AS INTE               NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa   AS INTE               NO-UNDO.
    DEF INPUT PARAM par_cdtribut   AS CHAR               NO-UNDO.
    DEF INPUT PARAM par_nrcpfcgc   AS CHAR               NO-UNDO.
    DEF INPUT PARAM par_dtapurac   AS CHAR               NO-UNDO.
    DEF INPUT PARAM par_dtlimite   AS CHAR               NO-UNDO.
    DEF INPUT PARAM par_cdrefere   AS CHAR               NO-UNDO.
    DEF INPUT PARAM par_vlrecbru   AS DECI               NO-UNDO.
    DEF INPUT PARAM par_vlpercen   AS DECI FORMAT "9999" NO-UNDO.
    DEF INPUT PARAM par_vllanmto   AS DECI               NO-UNDO.
    DEF INPUT PARAM par_vlrmulta   AS DECI               NO-UNDO.
    DEF INPUT PARAM par_vlrjuros   AS DECI               NO-UNDO.
    DEF OUTPUT PARAM par_foco      AS CHAR               NO-UNDO.

    DEF VAR aux_flgretor          AS LOGI                NO-UNDO.
    DEF VAR aux_tppessoa          AS INTE                NO-UNDO.
    DEF VAR aux_dtapurac          AS DATE                NO-UNDO.
    DEF VAR aux_vlrtotal          AS DECI                NO-UNDO.
    DEF VAR aux_hhsicini          AS INTE                NO-UNDO.
    DEF VAR aux_hhsicfim          AS INTE                NO-UNDO.

    RUN elimina-erro (INPUT par_nmrescop,
                      INPUT par_cdagenci,
                      INPUT par_nrdcaixa).

    FIND crapcop WHERE crapcop.nmrescop = par_nmrescop NO-LOCK NO-ERROR.

    FIND crapdat WHERE crapdat.cdcooper = crapcop.cdcooper NO-LOCK NO-ERROR.
    
    /* Validação horários de pagamento SICREDi */
    FIND craptab WHERE craptab.cdcooper = crapcop.cdcooper  AND
                       craptab.nmsistem = "CRED"            AND
                       craptab.tptabela = "GENERI"          AND
                       craptab.cdempres = 00                AND
                       craptab.cdacesso = "HRPGSICRED"      AND
                       craptab.tpregist = par_cdagenci 
                       NO-LOCK NO-ERROR.
    
    IF  NOT AVAIL craptab  THEN
        DO:
            ASSIGN i-cod-erro  = 0 
                   c-desc-erro = "Parametros de Horario nao cadastrados.".
    
            RUN cria-erro (INPUT par_nmrescop,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
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
            ASSIGN i-cod-erro  = 0
                   c-desc-erro = "Esse pagamento deve ser aceito ate as " + 
                                  STRING(aux_hhsicfim,"HH:MM") + "h.".

            RUN cria-erro (INPUT par_nmrescop,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
            RETURN "NOK".
        END.

    /* Validação Dt. Apuração */
    DATE(par_dtapurac) NO-ERROR.

    IF  ERROR-STATUS:ERROR OR
        par_dtapurac = ""   THEN
        DO:
            ASSIGN i-cod-erro  = 0
                   c-desc-erro = "Periodo de apuracao incorreto.".
                   par_foco    = "9". 

            RUN cria-erro (INPUT par_nmrescop,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
  
            RETURN "NOK".
        END.

    ASSIGN aux_dtapurac = DATE(par_dtapurac).

    /* Validação Cd. Tributo */
    IF  INTE(par_cdtribut) = 0 THEN
        DO:
            ASSIGN i-cod-erro  = 0
                   c-desc-erro = "Tributo nao informado."
                   par_foco    = "11".
  
            RUN cria-erro (INPUT par_nmrescop,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
  
            RETURN "NOK".
        END.

    FIND crapstb WHERE crapstb.cdtribut = INTE(par_cdtribut) NO-LOCK NO-ERROR.

    IF  NOT AVAIL crapstb THEN
        DO:
            ASSIGN i-cod-erro  = 0
                   c-desc-erro = "Tributo nao cadastrado."
                   par_foco    = "11".

            RUN cria-erro (INPUT par_nmrescop,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).

            RETURN "NOK".
        END.

    /* Validação Dt.Vencto. Para todas as DARFs */
    DATE(par_dtlimite) NO-ERROR.

    IF  ERROR-STATUS:ERROR OR
        par_dtlimite = ""   THEN
        DO:
            ASSIGN i-cod-erro  = 0
                   c-desc-erro = "Data de vencimento invalida.".
                   par_foco    = "13".

            RUN cria-erro (INPUT par_nmrescop,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
  
            RETURN "NOK".
        END.

    /* Validação para não aceitar faturas com Datas Vencto. inferiores a 01/01/1950 */
    IF (DATE(par_dtlimite) < 01/01/1950) THEN
        DO:
            ASSIGN i-cod-erro  = 0
                   c-desc-erro = "Data de vencimento invalida.".
                   par_foco    = "13".

            RUN cria-erro (INPUT par_nmrescop,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
  
            RETURN "NOK".
        END.
        
    ASSIGN aux_vlrtotal = (par_vllanmto + par_vlrmulta + par_vlrjuros).

    /* Não permitido pagamento de DARFs com valor abaixo de R$10,00 */
    IF  aux_vlrtotal < 10 THEN
        DO:
            ASSIGN i-cod-erro  = 0
                   c-desc-erro = "Pagamento deve ser maior ou igual a R$10,00."
                   par_foco    = "14".

            RUN cria-erro (INPUT par_nmrescop,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).

            RETURN "NOK".                                           
        END.                                                          

    IF  par_cdtribut = "6106" THEN /* DARF-SIMPLES */
        DO:
            IF  (aux_dtapurac < 01/01/1980) OR 
                (aux_dtapurac > 06/30/2007) THEN
                DO:
                    ASSIGN i-cod-erro  = 0
                           c-desc-erro = "Periodo de apuracao incorreto.".
                           par_foco    = "9". 

                    RUN cria-erro (INPUT par_nmrescop,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT i-cod-erro,
                                   INPUT c-desc-erro,
                                   INPUT YES).

                    RETURN "NOK".
                END.

            IF  par_vlrecbru = 0 THEN
                DO:
                    ASSIGN i-cod-erro  = 0
                           c-desc-erro = "Receita Bruta Acumulada nao pode ser vazia."
                           par_foco    = "17". 

                    RUN cria-erro (INPUT par_nmrescop,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT i-cod-erro,
                                   INPUT c-desc-erro,
                                   INPUT YES).

                    RETURN "NOK".
                END.

            IF (par_vlpercen = 0)            OR
               ((par_vlpercen * 100) < 300)  OR 
               ((par_vlpercen * 100) > 2928) THEN
                DO:
                    ASSIGN i-cod-erro  = 0
                           c-desc-erro = "Valor do Percentual invalido."
                           par_foco    = "18".

                    RUN cria-erro (INPUT par_nmrescop,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT i-cod-erro,
                                   INPUT c-desc-erro,
                                   INPUT YES).

                    RETURN "NOK".
                END.

        END. /* DARF-SIMPLES */
    ELSE    /* DARF PRETO EUROPA */
        DO:
            IF  (aux_dtapurac < 01/01/1980) OR
                (aux_dtapurac > DATE(SUBSTR(STRING(crapdat.dtmvtocd),1,6) + STRING(YEAR(crapdat.dtmvtocd) + 5))) THEN
                DO:
                    ASSIGN i-cod-erro  = 0
                           c-desc-erro = "Periodo de apuracao incorreto.".
                           par_foco    = "9". 

                    RUN cria-erro (INPUT par_nmrescop,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT i-cod-erro,
                                   INPUT c-desc-erro,
                                   INPUT YES).

                    RETURN "NOK".
                END.

            RUN verifica-digito-receita-darf (INPUT par_nmrescop,
                                              INPUT par_cdagenci,
                                              INPUT par_nrdcaixa,
                                              INPUT par_cdtribut,
                                             OUTPUT par_foco).
                     
            IF  RETURN-VALUE = "NOK" THEN
                RETURN "NOK".

            IF (par_cdtribut = "9139"            OR
                par_cdtribut = "9141"            OR
                par_cdtribut = "9154"            OR
                par_cdtribut = "9167"            OR
                par_cdtribut = "9170"            OR
                par_cdtribut = "9182")           AND
                par_nrcpfcgc <> "00360305000104" THEN
                DO:
                    ASSIGN i-cod-erro  = 0
                           c-desc-erro = "Documento nao pode ser ser acolhido por esse CPF/CNPJ."
                           par_foco    = "10".

                    RUN cria-erro (INPUT par_nmrescop,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT i-cod-erro,
                                   INPUT c-desc-erro,
                                   INPUT YES).

                    RETURN "NOK".
                END.

            IF (par_cdtribut = "4584")           AND
                par_nrcpfcgc <> "00000000000191" THEN
                DO:
                    ASSIGN i-cod-erro  = 0
                           c-desc-erro = "Documento nao pode ser ser acolhido por esse CPF/CNPJ."
                           par_foco    = "10".

                    RUN cria-erro (INPUT par_nmrescop,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT i-cod-erro,
                                   INPUT c-desc-erro,
                                   INPUT YES).

                    RETURN "NOK".
                END.

             IF  par_vlrecbru <> 0 THEN
                 DO:
                     ASSIGN i-cod-erro  = 0
                            c-desc-erro = "Receita Bruta Acumulada nao deve ser preenchida."
                            par_foco    = "17".
                 
                     RUN cria-erro (INPUT par_nmrescop,
                                    INPUT par_cdagenci,
                                    INPUT par_nrdcaixa,
                                    INPUT i-cod-erro,
                                    INPUT c-desc-erro,
                                    INPUT YES).
                 
                     RETURN "NOK".
                 END.

             IF  par_vlpercen <> 0  THEN
                 DO:
                    ASSIGN i-cod-erro  = 0
                           c-desc-erro = "O Percentual nao deve estar preenchido."
                           par_foco    = "18". 
             
                    RUN cria-erro (INPUT par_nmrescop,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT i-cod-erro,
                                   INPUT c-desc-erro,
                                   INPUT YES).
             
                    RETURN "NOK".
                 END.

        END.  /* DARF PRETO EUROPA */

    IF  par_vllanmto = 0 THEN 
        DO:
            ASSIGN i-cod-erro  = 0
                   c-desc-erro = "Valor deve ser informado."
                   par_foco    = "14".

            RUN cria-erro (INPUT par_nmrescop,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
            RETURN "NOK".
        END.

    IF  SUBSTRING(crapstb.dsrestri,1,1) = "S" THEN
        IF  par_cdrefere = "" THEN
            DO:
                ASSIGN i-cod-erro  = 0
                       c-desc-erro = "Numero de Referencia deve ser preenchido."
                       par_foco    = "12".

                RUN cria-erro (INPUT par_nmrescop,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT i-cod-erro,
                               INPUT c-desc-erro,
                               INPUT YES).
    
                RETURN "NOK".
            END.
        ELSE
            DO:
                RUN verifica-digito-num-referencia-darf (INPUT par_nmrescop,
                                                         INPUT par_cdagenci,
                                                         INPUT par_nrdcaixa,
                                                         INPUT par_cdrefere,
                                                        OUTPUT par_foco).

                IF  RETURN-VALUE = "NOK" THEN
                    RETURN "NOK".
            END.

    /* Verifica o número de digitos do CPF/CNPJ */
    IF  LENGTH(par_nrcpfcgc) <> 11 AND
        LENGTH(par_nrcpfcgc) <> 14 THEN
        DO:
            ASSIGN i-cod-erro  = 27
                   c-desc-erro = ""
                   par_foco    = "10".

            RUN cria-erro (INPUT par_nmrescop,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).

            RETURN "NOK".
        END.

    IF  SUBSTRING(crapstb.dsrestri,2,1) <> "S" THEN
        IF  par_nrcpfcgc = "00000000191" THEN
            DO:
                ASSIGN i-cod-erro  = 0
                       c-desc-erro = "Documento nao pode possuir esse CNPJ."
                       par_foco    = "10".

                RUN cria-erro (INPUT par_nmrescop,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT i-cod-erro,
                               INPUT c-desc-erro,
                               INPUT YES).
    
                RETURN "NOK".
            END.

    IF  SUBSTRING(crapstb.dsrestri,3,1) = "S" THEN
        IF (aux_dtapurac <> 01/01/1980  AND
            aux_dtapurac <> 08/08/1980) THEN
            DO:
                IF  LENGTH(par_nrcpfcgc) <> 11 THEN
                    DO:
                        ASSIGN i-cod-erro  = 0
                               c-desc-erro = "Numero de digitos do CPF incorreto."
                               par_foco    = "10".
                    
                        RUN cria-erro (INPUT par_nmrescop,
                                       INPUT par_cdagenci,
                                       INPUT par_nrdcaixa,
                                       INPUT i-cod-erro,
                                       INPUT c-desc-erro,
                                       INPUT YES).
                    
                        RETURN "NOK".
                    END.
            END.

    IF  SUBSTRING(crapstb.dsrestri,4,1) = "S" THEN
        IF (aux_dtapurac <> 01/01/1980  AND
            aux_dtapurac <> 07/07/1980  AND
            aux_dtapurac <> 08/08/1980) THEN
            DO:
                IF  LENGTH(par_nrcpfcgc) <> 14 THEN
                    DO:
                        ASSIGN i-cod-erro  = 0
                               c-desc-erro = "Numero de digitos do CNPJ incorreto."
                               par_foco    = "10".
                    
                        RUN cria-erro (INPUT par_nmrescop,
                                       INPUT par_cdagenci,
                                       INPUT par_nrdcaixa,
                                       INPUT i-cod-erro,
                                       INPUT c-desc-erro,
                                       INPUT YES).
                    
                        RETURN "NOK".
                    END.
            END.

    /* Valida CPF/CNPJ 
       Rotina do programa - pcrap06.p */
    IF  DEC(par_nrcpfcgc) = 9571   THEN
        ASSIGN aux_flgretor = FALSE
               aux_tppessoa  = 1.       /*  Valor default  */      

    IF  LENGTH(par_nrcpfcgc) = 11 OR LENGTH(par_nrcpfcgc) = 10 OR
        LENGTH(par_nrcpfcgc) =  9 OR LENGTH(par_nrcpfcgc) =  8 OR
        LENGTH(par_nrcpfcgc) =  7 THEN 
        DO:
            ASSIGN aux_tppessoa = 1.          /*  Pessoa fisica  */
            RUN dbo/pcrap07.p (INPUT DEC(par_nrcpfcgc),
                              OUTPUT aux_flgretor).

            IF  NOT aux_flgretor THEN 
                DO:
                   ASSIGN aux_tppessoa = 2.                      
                   RUN dbo/pcrap08.p (INPUT DEC(par_nrcpfcgc),
                                     OUTPUT aux_flgretor).
             
                END.
        END.
        ELSE
        DO:        
             IF  LENGTH(STRING(par_nrcpfcgc)) < 15 AND
                 LENGTH(STRING(par_nrcpfcgc)) > 2   THEN  
                 DO:             
                     ASSIGN aux_tppessoa = 2.   /*  Pessoa juridica  */                 
                     RUN dbo/pcrap08.p (INPUT DEC(par_nrcpfcgc),
                                       OUTPUT aux_flgretor).
                 END.
             ELSE
                 ASSIGN aux_flgretor = FALSE
                        aux_tppessoa = 1.       /*  Valor default  */
        END.
    /* pcrap06.p */
    
    IF  NOT aux_flgretor THEN 
        DO:
            ASSIGN i-cod-erro  = 27
                   c-desc-erro = ""
                   par_foco    = "10". 

            RUN cria-erro (INPUT par_nmrescop,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).

            RETURN "NOK".
        END.

   IF  SUBSTRING(crapstb.dsrestri,7,1) = "S" THEN
        IF  aux_vlrtotal < 10 THEN
            DO:
                ASSIGN i-cod-erro  = 0
                       c-desc-erro = "Pagamento deve ser maior ou igual a R$10,00."
                       par_foco    = "14".

                RUN cria-erro (INPUT par_nmrescop,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT i-cod-erro,
                               INPUT c-desc-erro,
                               INPUT YES).
    
                RETURN "NOK".
            END.

    IF  par_cdtribut <> "6106" THEN /* DARF PRETO EUROPA */
        IF  SUBSTRING(crapstb.dsrestri,9,1) = "N" THEN
            DO:
                ASSIGN i-cod-erro  = 0
                       c-desc-erro = "Pagamento dessa guia nao permitido".
    
                RUN cria-erro (INPUT par_nmrescop,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT i-cod-erro,
                               INPUT c-desc-erro,
                               INPUT YES).
    
                RETURN "NOK".
            END.

    RETURN "OK".

END PROCEDURE.


PROCEDURE verifica-digito-num-referencia-darf:

    DEF        INPUT PARAM par_nmrescop   AS CHAR                      NO-UNDO.
    DEF        INPUT PARAM par_cdagenci   AS INTE                      NO-UNDO.
    DEF        INPUT PARAM par_nrdcaixa   AS INTE                      NO-UNDO.
    DEF        INPUT PARAM par_cdrefere   AS CHAR                      NO-UNDO.
    DEF        OUTPUT PARAM par_foco      AS CHAR                      NO-UNDO.

    DEF        VAR aux_posicao  AS INT     INIT 0                      NO-UNDO.
    DEF        VAR aux_digito   AS INT     INIT 0                      NO-UNDO.
    DEF        VAR aux_calculo  AS INT     INIT 0                      NO-UNDO.
    DEF        VAR aux_resto    AS INT     INIT 0                      NO-UNDO.
    DEF        VAR aux_peso     AS INT     INIT 2                      NO-UNDO.
    DEF        VAR aux_cdrefere AS CHAR    INIT 0                      NO-UNDO.

    /*  Opção A */
    DO  aux_posicao = (LENGTH(STRING(par_cdrefere)) - 1) TO 1 BY -1:

        aux_calculo = aux_calculo + (INTEGER(SUBSTRING(STRING(par_cdrefere),aux_posicao,1)) * aux_peso).

        aux_peso = aux_peso + 1.

        IF   aux_peso > 9   THEN
             aux_peso = 2.

    END.  /*  Fim do DO .. TO  */

    ASSIGN aux_resto = aux_calculo MODULO 11
           aux_digito = 11 - aux_resto.

    IF  aux_resto = 0 OR 
        aux_resto = 1 THEN
        ASSIGN aux_digito = 0.

    IF (INTEGER(SUBSTRING(par_cdrefere,LENGTH(STRING(par_cdrefere)),1)) = aux_digito) THEN
        RETURN "OK".

    /*  Opção B */
    ASSIGN aux_calculo = 0
           aux_peso    = 2
           aux_digito  = 0
           aux_resto   = 0.

    DO  aux_posicao = (LENGTH(STRING(par_cdrefere)) - 2) TO 1 BY -1:

        ASSIGN aux_calculo  = aux_calculo + (INTEGER(SUBSTRING(STRING(par_cdrefere),aux_posicao,1)) * aux_peso).

        aux_peso = aux_peso + 1.

    END.  /*  Fim do DO .. TO  */

    ASSIGN aux_resto   = aux_calculo MODULO 11
           aux_digito   = 11 - aux_resto.

    /* Valida o primeiro Digito */
    IF (INTEGER(SUBSTRING(par_cdrefere,LENGTH(STRING(par_cdrefere)) - 1,1)) <> aux_digito) THEN
        DO:
            ASSIGN i-cod-erro  = 0
                   c-desc-erro = "Digito do Numero de Referencia incorreto."
                   par_foco    = "12". 

            RUN cria-erro (INPUT par_nmrescop,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).

            RETURN "NOK".
        END.
    

    ASSIGN aux_calculo  = 0
           aux_peso     = 2
           aux_cdrefere = SUBSTRING(STRING(par_cdrefere),1,LENGTH(STRING(par_cdrefere)) - 2)
           aux_cdrefere = aux_cdrefere + STRING(aux_digito).

    DO aux_posicao = (LENGTH(STRING(aux_cdrefere))) TO 1 BY -1:

        ASSIGN aux_calculo = aux_calculo + (INTEGER(SUBSTRING(STRING(aux_cdrefere),aux_posicao,1)) * aux_peso)
               aux_peso = aux_peso + 1.

    END.  /*  Fim do DO .. TO  */

    ASSIGN aux_resto   = aux_calculo MODULO 11
           aux_digito  = 11 - aux_resto.

    IF  aux_resto = 1  THEN
        ASSIGN aux_digito = 0.

    IF  aux_resto = 0  THEN
        ASSIGN aux_digito = 1.

    IF (INTEGER(SUBSTRING(par_cdrefere,LENGTH(STRING(par_cdrefere)),1)) = aux_digito) THEN
        RETURN "OK".
    ELSE
        DO:
            ASSIGN i-cod-erro  = 0
                   c-desc-erro = "Digito do Numero de Referencia incorreto."
                   par_foco    = "12". 

            RUN cria-erro (INPUT par_nmrescop,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).

            RETURN "NOK".
        END.

END PROCEDURE.

PROCEDURE verifica-digito-receita-darf:

    DEF        INPUT PARAM par_nmrescop   AS CHAR                      NO-UNDO.
    DEF        INPUT PARAM par_cdagenci   AS INTE                      NO-UNDO.
    DEF        INPUT PARAM par_nrdcaixa   AS INTE                      NO-UNDO.
    DEF        INPUT PARAM par_cdtribut   AS CHAR                      NO-UNDO.
    DEF        OUTPUT PARAM par_foco      AS CHAR                      NO-UNDO.

    DEF        VAR aux_digito   AS INT     INIT 0                      NO-UNDO.
    DEF        VAR aux_calculo  AS INT     INIT 0                      NO-UNDO.
    DEF        VAR aux_resto    AS INT     INIT 0                      NO-UNDO.

    /*  Módulo 11 (842) */
    ASSIGN aux_calculo = ((INTEGER(SUBSTRING(par_cdtribut,1,1)) * 8) +
                          (INTEGER(SUBSTRING(par_cdtribut,2,1)) * 4) +
                          (INTEGER(SUBSTRING(par_cdtribut,3,1)) * 2))
           aux_resto   = aux_calculo MOD 11
           aux_digito  = 11 - aux_resto.

     IF  aux_resto = 0 OR 
         aux_resto = 1 THEN
         ASSIGN aux_digito = 0.

    IF (INTEGER(SUBSTRING(par_cdtribut,4,1)) = aux_digito) THEN
        RETURN "OK".

    /*  Módulo 11 (248) */
    ASSIGN aux_calculo = ((INTEGER(SUBSTRING(par_cdtribut,1,1)) * 2) +
                          (INTEGER(SUBSTRING(par_cdtribut,2,1)) * 4) +
                          (INTEGER(SUBSTRING(par_cdtribut,3,1)) * 8))
           aux_resto   = aux_calculo MOD 11
           aux_digito  = 11 - aux_resto.

    IF  aux_resto = 0 OR 
        aux_resto = 1 THEN
        ASSIGN aux_digito = 0.

    IF (INTEGER(SUBSTRING(par_cdtribut,4,1)) = aux_digito) THEN
        RETURN "OK".

    /*  Módulo 11 (134) */
    ASSIGN aux_calculo = ((INTEGER(SUBSTRING(par_cdtribut,1,1)) * 1) +
                          (INTEGER(SUBSTRING(par_cdtribut,2,1)) * 3) +
                          (INTEGER(SUBSTRING(par_cdtribut,3,1)) * 4))
           aux_resto   = aux_calculo MOD 11
           aux_digito  = 11 - aux_resto.

    IF  aux_resto = 0 OR 
        aux_resto = 1 THEN
        ASSIGN aux_digito = 0.
    
    IF (INTEGER(SUBSTRING(par_cdtribut,4,1)) = aux_digito) THEN
        RETURN "OK".
    ELSE
        DO:
            ASSIGN i-cod-erro  = 0
                   c-desc-erro = "Digito do Codigo Receita incorreto."
                   par_foco    = "11". 

            RUN cria-erro (INPUT par_nmrescop,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).

            RETURN "NOK".
        END.

END PROCEDURE.
                                                          
PROCEDURE paga-darf:                                      
                                                          
    DEF INPUT PARAM par_nmrescop   AS CHAR                NO-UNDO.
    DEF INPUT PARAM par_nrdconta   AS INTE                NO-UNDO.
    DEF INPUT PARAM par_idseqttl   AS INTE                NO-UNDO.
    DEF INPUT PARAM par_cdagenci   AS INTE                NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa   AS INTE                NO-UNDO.
    DEF INPUT PARAM par_cdoperad   AS CHAR                NO-UNDO.
    DEF INPUT PARAM par_dtapurac   AS DATE                NO-UNDO.
    DEF INPUT PARAM par_nrcpfcgc   AS CHAR                NO-UNDO.
    DEF INPUT PARAM par_cdtribut   AS CHAR                NO-UNDO.
    DEF INPUT PARAM par_cdrefere   AS CHAR                NO-UNDO.
    DEF INPUT PARAM par_dtlimite   AS DATE                NO-UNDO.
    DEF INPUT PARAM par_vlrecbru   AS DECI                NO-UNDO.
    DEF INPUT PARAM par_vlpercen   AS DECI                NO-UNDO.
    DEF INPUT PARAM par_vllanmto   AS DECI                NO-UNDO.
    DEF INPUT PARAM par_vlrmulta   AS DECI                NO-UNDO.
    DEF INPUT PARAM par_vlrjuros   AS DECI                NO-UNDO.
                                                          
    DEF OUTPUT PARAM par_foco      AS CHAR                NO-UNDO.
    DEF OUTPUT PARAM p-literal-r   AS CHAR                NO-UNDO.
    DEF OUTPUT PARAM p-ult-sequencia-r AS INTE            NO-UNDO.
                                                          
    DEF        VAR  aux_nrdolote       AS INTE            NO-UNDO.
    DEF        VAR  aux_contador       AS INTE            NO-UNDO.
    DEF        VAR  p-histor           AS INTE            NO-UNDO.
    DEF        VAR  p-pg               AS LOGI            NO-UNDO.
    DEF        VAR  p-docto            AS DECI            NO-UNDO.
    DEF        VAR  aux_vlrtotal       AS DECI            NO-UNDO.
    DEF        VAR  aux_cdseqfat       AS DECI            NO-UNDO.
    DEF        VAR  aux_dtapurac       AS CHAR            NO-UNDO.
    DEF        VAR  aux_dtlimite       AS CHAR            NO-UNDO.
    DEF        VAR  aux_vlrmulta       AS CHAR            NO-UNDO.
    DEF        VAR  aux_vllanmto       AS CHAR            NO-UNDO.
    DEF        VAR  aux_vlrjuros       AS CHAR            NO-UNDO.
    DEF        VAR  aux_cdempres       AS CHAR            NO-UNDO.
    DEF        VAR  aux_dsconsul       AS CHAR            NO-UNDO.
    DEF        VAR  aux_dsmvtocd       AS CHAR            NO-UNDO.
    DEF        VAR  aux_flgfatex       AS LOGI INIT FALSE NO-UNDO.

    FIND crapcop WHERE crapcop.nmrescop = par_nmrescop NO-LOCK NO-ERROR.

    RUN elimina-erro (INPUT par_nmrescop,
                      INPUT par_cdagenci,
                      INPUT par_nrdcaixa).

    IF  par_cdtribut <> "" THEN
        ASSIGN par_cdtribut = FILL("0", 4 - LENGTH(STRING(par_cdtribut))) + 
                              par_cdtribut.

    ASSIGN aux_vlrtotal = (par_vllanmto + par_vlrmulta + par_vlrjuros)
           aux_dtapurac = TRIM(REPLACE(STRING(par_dtapurac, "99/99/9999"),"/", ""))
           aux_dtlimite = TRIM(REPLACE(STRING(par_dtlimite, "99/99/9999"),"/", ""))
           aux_vlrmulta = TRIM(REPLACE(STRING(par_vlrmulta, "zzz,zzz,zz9.99"),",", ""))
           aux_vlrjuros = TRIM(REPLACE(STRING(par_vlrjuros, "zzz,zzz,zz9.99"),",", ""))
           aux_vllanmto = TRIM(REPLACE(STRING(par_vllanmto, "zzz,zzz,zzz,zz9.99"),",", "")).

    /* Criação de Valor sequencial único para DARFs */
    ASSIGN aux_cdseqfat = DECI(aux_dtapurac + "" + STRING(par_nrcpfcgc) + "" +
                          STRING(par_cdtribut) + "" + aux_dtlimite + "" +  
                          TRIM(REPLACE(STRING(aux_vlrtotal, "zzz,zzz,zzz,zz9.99"),",", "")))
           aux_cdseqfat = DECI(SUBSTRING(STRING(aux_cdseqfat), 1, 38)).

    IF  par_vllanmto = 0 AND aux_vlrtotal = 0 THEN 
        DO:
            ASSIGN i-cod-erro  = 0
                   c-desc-erro = "Valor deve ser informado."
                   par_foco    = "14".

            RUN cria-erro (INPUT par_nmrescop,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
            RETURN "NOK".
        END.

    ASSIGN aux_nrdolote = 15000 + par_nrdcaixa. 

    FIND FIRST crapdat WHERE crapdat.cdcooper = crapcop.cdcooper
                             NO-LOCK NO-ERROR.

    /* Verifica se exite lançamento já existente */
    FIND craplft WHERE
         craplft.cdcooper = crapcop.cdcooper      AND
         craplft.dtmvtolt = crapdat.dtmvtocd      AND
         craplft.cdagenci = par_cdagenci          AND
         craplft.cdbccxlt = 11                    AND
         craplft.nrdolote = aux_nrdolote          AND 
         craplft.cdseqfat = aux_cdseqfat
         USE-INDEX craplft1 NO-LOCK NO-ERROR.

    IF  AVAIL craplft   THEN  
        DO:
           ASSIGN i-cod-erro  = 92           
                  c-desc-erro = " (001)".

           RUN cria-erro (INPUT par_nmrescop,
                          INPUT par_cdagenci,
                          INPUT par_nrdcaixa,
                          INPUT i-cod-erro,
                          INPUT c-desc-erro,
                          INPUT YES).
           RETURN "NOK".
        END.
    ELSE
        DO:
            /* Tratamento para consulta Oracle, pois DataServer não suporta as mais de 34 posições do campo cdseqfat */
            ASSIGN aux_dsmvtocd = STRING(DAY(crapdat.dtmvtocd),"99")    +
                                  STRING(MONTH(crapdat.dtmvtocd),"99")  +
                                  STRING(YEAR(crapdat.dtmvtocd),"9999").

            ASSIGN aux_dsconsul = "SELECT craplft.vllanmto FROM craplft WHERE craplft.cdcooper = "  + STRING(crapcop.cdcooper)   + " AND " +
                                                                             "craplft.dtmvtolt = to_date('" + STRING(aux_dsmvtocd) + "', 'dd/mm/yyyy') AND " +
                                                                             "craplft.cdagenci = "  + STRING(par_cdagenci)       + " AND " +
                                                                             "craplft.cdbccxlt = 11                                  AND " +
                                                                             "craplft.nrdolote = "  + STRING(aux_nrdolote)       + " AND " +
                                                                             "craplft.cdseqfat = "  + STRING(aux_cdseqfat).

            { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
        
            RUN STORED-PROC {&sc2_dboraayl}.send-sql-statement iHandle = PROC-HANDLE NO-ERROR(aux_dsconsul).
        
            FOR EACH {&sc2_dboraayl}.proc-text-buffer WHERE PROC-HANDLE = iHandle:
                /* Registro existe */
                ASSIGN aux_flgfatex = TRUE.
            END.
            
            CLOSE STORED-PROC send-sql-statement WHERE PROC-HANDLE = iHandle.
        
            { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

            IF  aux_flgfatex THEN
                DO:
                    ASSIGN i-cod-erro  = 92           
                           c-desc-erro = " (002)".
                 
                    RUN cria-erro (INPUT par_nmrescop,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT i-cod-erro,
                                   INPUT c-desc-erro,
                                   INPUT YES).
                    RETURN "NOK".
                END.
        END.

    DO aux_contador = 1 TO 10:
        
        c-desc-erro = "".
        
        FIND craplot WHERE craplot.cdcooper = crapcop.cdcooper AND
                           craplot.dtmvtolt = crapdat.dtmvtocd AND
                           craplot.cdagenci = par_cdagenci     AND
                           craplot.cdbccxlt = 11               AND
                           craplot.nrdolote = aux_nrdolote       
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
                               craplot.cdagenci = par_cdagenci   
                               craplot.cdbccxlt = 11              
                               craplot.nrdolote = aux_nrdolote
                               craplot.tplotmov = 13
                               craplot.cdoperad = par_cdoperad
                               craplot.cdhistor = 1154
                               craplot.nrdcaixa = par_nrdcaixa
                               craplot.cdopecxa = par_cdoperad.
                    END.
            END.
            
        LEAVE.
                
    END. /* Fim do DO ... TO */

    IF  par_cdtribut = "6106" THEN /* DARF SIMPLES */
        DO:
            FIND FIRST crapscn WHERE crapscn.cdempres = "D0"
                                    NO-LOCK NO-ERROR NO-WAIT.

            IF  AVAIL crapscn THEN
                ASSIGN aux_cdempres = crapscn.cdempres.
        END.
    ELSE
        DO: /* DARF PRETO EUROPA */
            FIND FIRST crapscn WHERE crapscn.cdempres = "A0"
                                    NO-LOCK NO-ERROR NO-WAIT.

            IF  AVAIL crapscn THEN
                ASSIGN aux_cdempres = crapscn.cdempres.
        END.

    IF  c-desc-erro <> ""  THEN
        DO:
            i-cod-erro = 0.
            
            RUN cria-erro (INPUT par_nmrescop,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
                           
            RETURN "NOK".
        END.

    CREATE craplft.
    ASSIGN craplft.cdcooper = crapcop.cdcooper
           craplft.dtapurac = par_dtapurac
           craplft.nrcpfcgc = par_nrcpfcgc
           craplft.cdtribut = STRING(par_cdtribut, "9999")
           craplft.nrrefere = par_cdrefere
           craplft.dtlimite = par_dtlimite
           craplft.vlrecbru = par_vlrecbru
           craplft.vlpercen = par_vlpercen 
           craplft.vllanmto = par_vllanmto
           craplft.vlrmulta = par_vlrmulta
           craplft.vlrjuros = par_vlrjuros
           craplft.tpfatura = 2  
           craplft.cdempcon = 0 
           craplft.cdsegmto = 6
           craplft.dtmvtolt = craplot.dtmvtolt
           craplft.cdagenci = craplot.cdagenci
           craplft.cdbccxlt = craplot.cdbccxlt
           craplft.nrdolote = craplot.nrdolote
           craplft.dtvencto = crapdat.dtmvtocd
           craplft.nrseqdig = craplot.nrseqdig + 1
           craplft.cdseqfat = aux_cdseqfat
           craplft.insitfat = 1
           craplft.cdhistor = 1154

           craplot.nrseqdig = craplot.nrseqdig + 1
           craplot.qtcompln = craplot.qtcompln + 1
           craplot.qtinfoln = craplot.qtinfoln + 1
           craplot.vlcompcr = craplot.vlcompcr + (par_vllanmto + par_vlrmulta + par_vlrjuros)
           craplot.vlinfocr = craplot.vlinfocr + (par_vllanmto + par_vlrmulta + par_vlrjuros).
    VALIDATE craplot.
    

    ASSIGN p-pg     = NO
           p-docto  = craplft.nrseqdig
           p-histor = craplft.cdhistor.

    RUN dbo/b1crap00.p PERSISTENT SET h-b1crap00.
    RUN grava-autenticacao-internet IN h-b1crap00
                                         (INPUT par_nmrescop,
                                          INPUT par_nrdconta,
                                          INPUT par_idseqttl,
                                          INPUT par_cdagenci,
                                          INPUT par_nrdcaixa,
                                          INPUT par_cdoperad,
                                          INPUT DEC(aux_vlrtotal),
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
        RETURN "NOK".

    /* Atualiza sequencia Autenticacao */
    ASSIGN craplft.nrautdoc = p-ult-sequencia.
    VALIDATE craplft.

    ASSIGN p-ult-sequencia-r = p-ult-sequencia
           p-literal-r       = p-literal.

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
                       INPUT par_dscritic,
                       INPUT YES).
        RETURN "NOK".
     END.
     
    RETURN "OK".

END PROCEDURE.
