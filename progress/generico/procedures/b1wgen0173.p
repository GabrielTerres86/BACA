/*.............................................................................

    Programa: sistema/generico/procedures/b1wgen0173.p
    Autor   : Oliver Fagionato (GATI)
    Data    : Agosto/2013                       Ultima Atualizacao: 18/12/2014

    Objetivo  : Possuir todas as regras de negocio da tela CLDSED.

    Alteracoes: 
               26/12/2013 - Adequação aos padrões CECRED de indentação e
                            desenvolvimento (Leonardo - GATI).
                            
               06/03/2014 - Incluso VALIDATE (Daniel). 
               
               27/06/2014 - Gravar zeros no indicador crapcld.flextjus 
                            quando cddjusti igual a 8 independente de possuir
                            texto de justificativa (Chamado 143945) - 
                           (Jonata - RKAM).
                           
               17/12/2014 - #228751 Inclusao de clausula crapcld.cdtipcld = 1 
                            (controle diario) na procedure carrega_pesquisa (Carlos)

               18/12/2014 - Remover a condição de crapass.cdagenci da 
                            Carrega_creditos. Adicionado a include das 
                            temp-table da BO173. Validação das funcionalidades
                            para conversão WEB (Douglas - Chamado 143945)
.............................................................................*/

/* Variaveis globais mantidas devido a impressão */
{ includes/var_online.i "NEW" }

{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/gera_erro.i }
{ sistema/generico/includes/gera_log.i }
{ sistema/generico/includes/b1wgen0173tt.i }

/*............................. DEFINICOES ..................................*/
DEFINE VARIABLE h-b1wgen0024 AS HANDLE      NO-UNDO.
/* Variaveis para a include cabrel132_1.i */
DEF   VAR rel_nmempres   AS CHAR  FORMAT "x(15)"                   NO-UNDO.
DEF   VAR rel_nmrelato   AS CHAR  FORMAT "x(40)" EXTENT 5          NO-UNDO.
DEF   VAR rel_nrmodulo   AS INT   FORMAT "9"                       NO-UNDO.
DEF   VAR rel_nmmodulo   AS CHAR  FORMAT "x(15)" EXTENT 5
                                       INIT ["DEP. A VISTA   ",
                                             "CAPITAL        ",
                                             "EMPRESTIMOS    ",
                                             "DIGITACAO      ",
                                             "GENERICO       "]     NO-UNDO.

DEF VAR aux_dscritic    AS CHAR                                     NO-UNDO.
DEF VAR aux_cdcritic    AS INTE                                     NO-UNDO.
DEF VAR aux_dsstatus    AS CHAR                                     NO-UNDO.
DEF VAR aux_linharel    AS CHAR                                     NO-UNDO.
DEF VAR aux_nmarqimp    AS CHAR                                     NO-UNDO.
DEF VAR aux_nmendter    AS CHAR                                     NO-UNDO.
DEF VAR aux_flgescra    AS LOGICAL                                  NO-UNDO.
DEF VAR aux_dscomand    AS CHAR                                     NO-UNDO.
DEF VAR aux_contador    AS INT                                      NO-UNDO.
DEF VAR tel_dsimprim    AS CHAR    FORMAT "x(08)" INIT "Imprimir"   NO-UNDO.
DEF VAR tel_dscancel    AS CHAR    FORMAT "x(08)" INIT "Cancelar"   NO-UNDO.
DEF VAR par_flgrodar    AS LOGICAL                                  NO-UNDO.
DEF VAR par_flgfirst    AS LOGICAL                                  NO-UNDO.
DEF VAR par_flgcance    AS LOGICAL                                  NO-UNDO.

DEF STREAM str_1. 

FORM "PA"               AT 01
     "Data"             AT 11
     "Conta/DV"         AT 18
     "Renda"            AT 34
     "Creditos"         AT 50
     "Creditos/Renda"   AT 59
     "Status"           AT 79
     "COAF"             AT 95      
     SKIP
     "---"
     "----------"
     "----------"
     "------------"
     "------------------"
     "--------------"
     "-----------"
     "-------------"
     WITH WIDTH 132 NO-BOX NO-LABEL FRAME f_retorno_tit.

FORM tt-atividade.cdagenci                       FORMAT "zz9"
     tt-atividade.dtmvtolt                       FORMAT "99/99/9999"
     tt-atividade.nrdconta
     tt-atividade.vlrendim
     tt-atividade.vltotcre
     tt-atividade.qtultren   AT 63
     tt-atividade.dsstatus                       FORMAT "x(12)"
     tt-atividade.infrepcf                       FORMAT "x(15)"
     SKIP
     "     Justificativa:" tt-atividade.dsdjusti
     SKIP
     "        Comp.Justi:" tt-atividade.dsobserv 
     SKIP
     "      Parecer Sede:" tt-atividade.dsobsctr
     SKIP
     "           Vinculo:" tt-atividade.tpvincul
     SKIP(1)
     WITH WIDTH 132 DOWN NO-BOX NO-LABEL FRAME f_atividade_retorno.

FORM tt-pesquisa.cdagenci                       FORMAT "zz9"
     tt-pesquisa.dtmvtolt                       FORMAT "99/99/9999"
     tt-pesquisa.nrdconta
     tt-pesquisa.vlrendim
     tt-pesquisa.vltotcre
     tt-pesquisa.qtultren   AT 63
     tt-pesquisa.dsstatus                       FORMAT "x(12)"
     tt-pesquisa.infrepcf   FORMAT "x(15)"
     SKIP
     "     Justificativa:" tt-pesquisa.dsdjusti
     WITH WIDTH 132 DOWN NO-BOX NO-LABEL FRAME f_pesquisa_retorno.

PROCEDURE Valida_nao_justificado:

    DEFINE INPUT  PARAMETER par_cdcooper AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdagenci AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrdcaixa AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdoperad AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_teldtmvt AS DATE        NO-UNDO.
    DEFINE INPUT  PARAMETER par_dtmvtolt AS DATE        NO-UNDO.
    DEFINE INPUT  PARAMETER par_idorigem AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_nmdatela AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdprogra AS CHARACTER   NO-UNDO.

    DEFINE OUTPUT PARAMETER TABLE FOR tt-erro.

    DEFINE VARIABLE aux_ffechrea AS LOGICAL NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.

    FIND FIRST crapcld  WHERE
               crapcld.cdcooper = par_cdcooper  AND
               crapcld.dtmvtolt = par_teldtmvt  AND
               crapcld.cdtipcld = 1 /* DIARIO*/ AND
               crapcld.flextjus = FALSE    
               NO-LOCK NO-ERROR.

    IF AVAIL crapcld THEN
        DO:
            ASSIGN aux_dscritic = "Existem registros sem justificativa.".
        
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 0,
                           INPUT 0,
                           INPUT-OUTPUT aux_dscritic).
            RETURN "NOK".
        END.
    ELSE 
        DO:
            RUN Valida_fechamento ( INPUT par_cdcooper, 
                                    INPUT par_cdagenci, 
                                    INPUT par_nrdcaixa, 
                                    INPUT par_cdoperad,
                                    INPUT par_teldtmvt,
                                    INPUT par_dtmvtolt,
                                    INPUT par_idorigem, 
                                    INPUT par_nmdatela, 
                                   OUTPUT aux_ffechrea,
                                   OUTPUT TABLE tt-erro).

            IF aux_ffechrea THEN 
                RETURN "NOK".
       END.
   RETURN "OK".
END PROCEDURE.

PROCEDURE Valida_COAF:

    DEFINE INPUT  PARAMETER par_cdcooper AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdagenci AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrdcaixa AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdoperad AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_dtmvtolt AS DATE        NO-UNDO.
    DEFINE INPUT  PARAMETER par_idorigem AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_nmdatela AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdprogra AS CHARACTER   NO-UNDO.
    DEFINE OUTPUT PARAMETER par_infocoat AS CHAR        NO-UNDO.
    DEFINE OUTPUT PARAMETER TABLE FOR tt-erro.
    

    FIND FIRST crapcld  WHERE
               crapcld.cdcooper = par_cdcooper AND
               crapcld.dtmvtolt = par_dtmvtolt AND
               crapcld.infrepcf = 1 
               NO-LOCK NO-ERROR.
    IF AVAIL crapcld THEN
        ASSIGN par_infocoat = "Existem informacoes que "+
                              "serao passadas ao COAF, confirma" +
                              " a operacao?".
   RETURN "OK".                       

END PROCEDURE.

PROCEDURE Valida_fechamento:

    DEFINE INPUT  PARAMETER par_cdcooper    AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdagenci    AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrdcaixa    AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdoperad    AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_teldtmvt    AS DATE        NO-UNDO.
    DEFINE INPUT  PARAMETER par_dtmvtolt    AS DATE        NO-UNDO.
    DEFINE INPUT  PARAMETER par_idorigem    AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_nmdatela    AS CHARACTER   NO-UNDO.
    DEFINE OUTPUT PARAMETER par_ffechrea    AS LOGICAL NO-UNDO.
    DEFINE OUTPUT PARAMETER TABLE FOR tt-erro.

    EMPTY TEMP-TABLE tt-erro.

    /* Validar se a data informada em tela é superior a data do sistema 
       Se for, não deixa realizar o fechamento */
    IF par_teldtmvt > par_dtmvtolt THEN
        DO:
            ASSIGN aux_dscritic = "A data de fechamento informada eh superior a " +
                                  "data do sistema.".
            RUN gera_erro (INPUT par_cdcooper,        
                           INPUT par_cdagenci,        
                           INPUT par_nrdcaixa,        
                           INPUT 0,                   
                           INPUT 0,                  
                           INPUT-OUTPUT aux_dscritic).
            RETURN "NOK".
        END.

    FIND crapfld NO-LOCK WHERE
         crapfld.cdcooper = par_cdcooper AND
         crapfld.dtmvtolt = par_teldtmvt AND
         crapfld.cdtipcld = 1 /* DIARIO COOP */ NO-ERROR.
    
    ASSIGN par_ffechrea = AVAIL crapfld.
    
    IF par_ffechrea THEN
        DO:
            ASSIGN aux_dscritic = "Fechamento para esta data " +
                                  "ja realizado".
            RUN gera_erro (INPUT par_cdcooper,        
                           INPUT par_cdagenci,        
                           INPUT par_nrdcaixa,        
                           INPUT 0,                   
                           INPUT 0,                  
                           INPUT-OUTPUT aux_dscritic).
            RETURN "NOK".
        END.

     RETURN "OK".

END PROCEDURE.

PROCEDURE Carrega_pesquisa:

    DEFINE INPUT  PARAMETER par_cdcooper    AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdagenci    AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrdcaixa    AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdoperad    AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_dtmvtolt    AS DATE        NO-UNDO.
    DEFINE INPUT  PARAMETER par_idorigem    AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_nmdatela    AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdprogra    AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrdconta    AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdincoaf    AS INT         NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdstatus    AS INT         NO-UNDO.
    DEFINE INPUT  PARAMETER par_dtrefini    AS DATE        NO-UNDO.
    DEFINE INPUT  PARAMETER par_dtreffim    AS DATE        NO-UNDO.
    DEFINE OUTPUT PARAMETER TABLE FOR tt-pesquisa.
    DEFINE OUTPUT PARAMETER TABLE FOR tt-erro.

    EMPTY TEMP-TABLE tt-pesquisa.
    EMPTY TEMP-TABLE tt-erro.

    FOR EACH crapcld WHERE 
             crapcld.cdcooper = par_cdcooper  AND
             crapcld.cdtipcld = 1             AND /* controle diario */
             (par_cdincoaf = 1                 OR
             crapcld.infrepcf = par_cdincoaf) AND
             crapcld.dtmvtolt >= par_dtrefini AND
             crapcld.dtmvtolt <= par_dtreffim AND
             (par_nrdconta     = 0             OR
             crapcld.nrdconta = par_nrdconta)
             NO-LOCK:

        FIND crapfld WHERE 
             crapfld.cdcooper = par_cdcooper      AND
             crapfld.dtmvtolt = crapcld.dtmvtolt  AND
             crapfld.cdtipcld = 1 /* DIARIO COOP */
             NO-LOCK NO-ERROR.

        IF  AVAIL crapfld THEN
            DO:
                IF  par_cdstatus = 2 THEN
                    NEXT.

                ASSIGN aux_dsstatus = "Fechado".
            END.
        ELSE
            DO:
                IF  par_cdstatus = 3 THEN
                    NEXT.

                ASSIGN aux_dsstatus = "Em analise".
            END.

        CREATE tt-pesquisa.
        ASSIGN tt-pesquisa.cdagenci = crapcld.cdagenci
               tt-pesquisa.dtmvtolt = crapcld.dtmvtolt
               tt-pesquisa.nrdconta = crapcld.nrdconta
               tt-pesquisa.vlrendim = crapcld.vlrendim
               tt-pesquisa.vltotcre = crapcld.vltotcre
               tt-pesquisa.qtultren = IF crapcld.vlrendim > 0 THEN
                                         crapcld.vltotcre / crapcld.vlrendim   
                                      ELSE
                                         0
               tt-pesquisa.dsstatus = aux_dsstatus
               tt-pesquisa.dsdjusti = crapcld.dsdjusti
               tt-pesquisa.infrepcf = IF crapcld.infrepcf = 0 THEN
                                         "Nao Informar"
                                      ELSE
                                      IF crapcld.infrepcf = 1 THEN
                                         "Informar"
                                      ELSE 
                                      IF crapcld.infrepcf = 2 THEN
                                         "Ja informado"
                                      ELSE
                                         "".

    END. /* FIM FOR EACH crapcld */

    FIND FIRST tt-pesquisa NO-ERROR.
    IF  NOT AVAIL tt-pesquisa THEN
       DO:
        RUN gera_erro (INPUT par_cdcooper,
                       INPUT par_cdagenci,
                       INPUT par_nrdcaixa,
                       INPUT 1,
                       INPUT 11,
                       INPUT-OUTPUT aux_dscritic).
        RETURN "NOK".
       END.

    RETURN "OK".

END PROCEDURE.

PROCEDURE Gera_imprime_arq_pesquisa:
    
    DEFINE INPUT  PARAMETER par_cdcooper    AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdagenci    AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrdcaixa    AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdoperad    AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_dtmvtolt    AS DATE        NO-UNDO.
    DEFINE INPUT  PARAMETER par_idorigem    AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_nmdatela    AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdprogra    AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_tpdsaida    AS CHAR        NO-UNDO.
    DEFINE INPUT  PARAMETER TABLE FOR tt-pesquisa.
    DEFINE INPUT-OUTPUT PARAMETER par_nmarquiv AS CHAR     NO-UNDO.
    DEFINE OUTPUT PARAMETER par_nmarqpdf AS CHAR     NO-UNDO.

    DEFINE OUTPUT PARAMETER TABLE FOR tt-erro.

    EMPTY TEMP-TABLE tt-erro.
    
    DEFINE VARIABLE c-branco AS CHARACTER   NO-UNDO.

    IF par_tpdsaida = "A" THEN DO:
        RUN Dados_cooperativa(INPUT  par_cdcooper,
                              INPUT  par_cdagenci,
                              INPUT  par_nrdcaixa,
                              INPUT  par_cdoperad,
                              INPUT  par_dtmvtolt,
                              INPUT  par_idorigem,
                              INPUT  par_nmdatela,
                              INPUT  par_cdprogra,
                              OUTPUT TABLE tt-crapcop,
                              OUTPUT TABLE tt-erro).

        FIND FIRST tt-crapcop NO-LOCK NO-ERROR.
        ASSIGN par_nmarquiv = "/micros/" + tt-crapcop.dsdircop + "/" + 
                              par_nmarquiv.
    
        OUTPUT STREAM str_1 TO VALUE (par_nmarquiv).
    
        ASSIGN aux_linharel = "Pa;Data;Conta/dv;Rendimento;Credito;" + 
                              "Credito/renda;Status;Justificativa;Coaf;".

        PUT STREAM str_1 aux_linharel FORMAT "x(80)"       
            SKIP.
    
        FOR EACH tt-pesquisa NO-LOCK BY tt-pesquisa.cdagenci
            BY tt-pesquisa.dtmvtolt
            BY tt-pesquisa.nrdconta:
    
            ASSIGN aux_linharel = STRING(tt-pesquisa.cdagenci) + 
                                  ";" +
                                  STRING(tt-pesquisa.dtmvtolt) +
                                  ";" + 
                                  STRING(tt-pesquisa.nrdconta, "zzzz,zzz,9") +
                                  ";" + 
                                  STRING(tt-pesquisa.vlrendim, "zzzzz,zz9.99") + 
                                  ";" + 
                                  STRING(tt-pesquisa.vltotcre, "zzzzz,zz9.99") + 
                                  ";" + 
                                  STRING(tt-pesquisa.qtultren) + 
                                  ";" + 
                                  tt-pesquisa.dsstatus + 
                                  ";" + 
                                  tt-pesquisa.dsdjusti + 
                                  ";" + 
                                  tt-pesquisa.infrepcf + 
                                  ";".
    
            PUT STREAM str_1 aux_linharel FORMAT "x(200)"
                SKIP.
    
        END.
    
        OUTPUT STREAM str_1 CLOSE.
    END.
    ELSE DO:
        RUN Dados_cooperativa(INPUT  par_cdcooper,
                              INPUT  par_cdagenci,
                              INPUT  par_nrdcaixa,
                              INPUT  par_cdoperad,
                              INPUT  par_dtmvtolt,
                              INPUT  par_idorigem,
                              INPUT  par_nmdatela,
                              INPUT  par_cdprogra,
                              OUTPUT TABLE tt-crapcop,
                              OUTPUT TABLE tt-erro).

        FIND FIRST tt-crapcop NO-ERROR.
        /* Inicializa Variaveis Relatorio */
        ASSIGN glb_cdempres = 11
               glb_cdrelato[1] = 610
               par_nmarquiv = "/micros/" + tt-crapcop.dsdircop + 
                              "/cld_" + STRING(TIME) + ".ex".

        { includes/cabrel132_1.i }

        OUTPUT STREAM str_1 TO VALUE (par_nmarquiv) PAGED PAGE-SIZE 84.

        VIEW STREAM str_1 FRAME f_cabrel132_1.
        VIEW STREAM str_1 FRAME f_retorno_tit.

        FOR EACH tt-pesquisa NO-LOCK BY tt-pesquisa.cdagenci
                                     BY tt-pesquisa.dtmvtolt
                                     BY tt-pesquisa.nrdconta:

            DISP STREAM str_1 tt-pesquisa.cdagenci
                              tt-pesquisa.dtmvtolt
                              tt-pesquisa.nrdconta
                              tt-pesquisa.vlrendim
                              tt-pesquisa.vltotcre
                              tt-pesquisa.qtultren
                              tt-pesquisa.dsstatus
                              tt-pesquisa.dsdjusti
                              tt-pesquisa.infrepcf
                              WITH FRAME f_pesquisa_retorno.

            DOWN STREAM str_1 WITH FRAME f_pesquisa_retorno.
        END.

        OUTPUT STREAM str_1 CLOSE.

        IF  par_idorigem = 5  THEN  /** Ayllos Web **/
        DO:
            RUN sistema/generico/procedures/b1wgen0024.p PERSISTENT
                SET h-b1wgen0024.

            IF  NOT VALID-HANDLE(h-b1wgen0024)  THEN
                DO:
                    ASSIGN aux_dscritic = "Handle invalido para BO " +
                                          "b1wgen0024.".
                END.

            RUN envia-arquivo-web IN h-b1wgen0024 ( INPUT par_cdcooper,
                                                    INPUT par_cdagenci,
                                                    INPUT par_nrdcaixa,
                                                    INPUT par_nmarquiv,
                                                    OUTPUT par_nmarqpdf,
                                                    OUTPUT TABLE tt-erro ).

            IF  VALID-HANDLE(h-b1wgen0024)  THEN
                DELETE PROCEDURE h-b1wgen0024.

            IF  RETURN-VALUE <> "OK" THEN
                RETURN 'NOK'.
        END.  
    END.

    RETURN 'OK'.


END PROCEDURE.

PROCEDURE Gera_imprime_arq_atividade:

    DEFINE INPUT PARAMETER par_cdcooper     AS INTEGER     NO-UNDO.
    DEFINE INPUT PARAMETER par_cdagenci     AS INTEGER     NO-UNDO.
    DEFINE INPUT PARAMETER par_nrdcaixa     AS INTEGER     NO-UNDO.
    DEFINE INPUT PARAMETER par_cdoperad     AS CHARACTER   NO-UNDO.
    DEFINE INPUT PARAMETER par_dtmvtolt     AS DATE        NO-UNDO.
    DEFINE INPUT PARAMETER par_idorigem     AS INTEGER     NO-UNDO.
    DEFINE INPUT PARAMETER par_nmdatela     AS CHARACTER   NO-UNDO.
    DEFINE INPUT PARAMETER par_cdprogra     AS CHARACTER   NO-UNDO.
    DEFINE INPUT PARAMETER par_tpdsaida     AS CHAR        NO-UNDO.
    DEFINE INPUT PARAMETER par_gerexcel     AS CHAR        NO-UNDO.
    DEFINE INPUT PARAMETER TABLE FOR tt-atividade.
    DEFINE INPUT-OUTPUT PARAM par_nmarquiv AS CHAR         NO-UNDO.
    DEFINE OUTPUT PARAMETER par_nmarqpdf AS CHAR     NO-UNDO.
    DEFINE OUTPUT PARAMETER TABLE FOR tt-erro.

    DEFINE VARIABLE c-branco AS CHARACTER   NO-UNDO.
    
    /* Inicializa Variaveis Relatorio */
    ASSIGN glb_cdempres = 11
           glb_cdrelato[1] = 611.

    { includes/cabrel132_1.i }

    RUN Dados_cooperativa(INPUT  par_cdcooper,
                          INPUT  par_cdagenci,
                          INPUT  par_nrdcaixa,
                          INPUT  par_cdoperad,
                          INPUT  par_dtmvtolt,
                          INPUT  par_idorigem,
                          INPUT  par_nmdatela,
                          INPUT  par_cdprogra,
                          OUTPUT TABLE tt-crapcop,
                          OUTPUT TABLE tt-erro).

    IF RETURN-VALUE <> "OK" THEN
       RETURN "NOK".
      

    FIND FIRST tt-crapcop NO-ERROR.
    IF NOT par_nmarquiv MATCHES "*/micros*" THEN DO:
       IF par_nmarquiv <> "" THEN
          ASSIGN par_nmarquiv = "/micros/" + tt-crapcop.dsdircop + "/" + 
                                par_nmarquiv.
       else 
          ASSIGN par_nmarquiv = "/micros/" + tt-crapcop.dsdircop + "/" + 
                                "cld_" + STRING(TIME) + ".ex".
    END.

    OUTPUT STREAM str_1 TO VALUE (par_nmarquiv) 
        PAGED PAGE-SIZE 84.

    IF   par_gerexcel <> "S" THEN
        DO:
            VIEW STREAM str_1 FRAME f_cabrel132_1.
            VIEW STREAM str_1 FRAME f_retorno_tit.
        END.
    ELSE
        DO:
            ASSIGN aux_linharel = "Pa;Data;Conta/dv;Rendimento;Credito;" + 
                                  "Credito/renda;Status;Coaf;Vinculo;" + 
                                  "Justificativa;Comp.Justi;Parecer Sede;". 

            PUT STREAM str_1 aux_linharel FORMAT "x(300)"
                SKIP.
        END.

    FOR EACH tt-atividade NO-LOCK 
        BY tt-atividade.cdagenci
        BY tt-atividade.dtmvtolt
        BY tt-atividade.nrdconta:
    
    IF   par_gerexcel <> "S" THEN
        DO:
            DISP STREAM str_1 tt-atividade.cdagenci
                        tt-atividade.dtmvtolt
                        tt-atividade.nrdconta
                        tt-atividade.vlrendim
                        tt-atividade.vltotcre
                        tt-atividade.qtultren
                        tt-atividade.dsstatus
                        tt-atividade.dsdjusti
                        tt-atividade.dsobserv
                        tt-atividade.dsobsctr
                        tt-atividade.tpvincul
                        tt-atividade.infrepcf
                WITH FRAME f_atividade_retorno.

            DOWN STREAM str_1 WITH 
                FRAME f_atividade_retorno.
        END.                
    ELSE
        DO:
            ASSIGN aux_linharel = STRING(tt-atividade.cdagenci) + ";" +
                                  STRING(tt-atividade.dtmvtolt) + ";" +
                                  STRING(tt-atividade.nrdconta,
                                         "zzzz,zzz,9") + ";" +
                                  STRING(tt-atividade.vlrendim,
                                         "zzzzz,zz9.99") + ";" +
                                  STRING(tt-atividade.vltotcre,
                                         "zzzzz,zz9.99") + ";" +
                                  STRING(tt-atividade.qtultren) + ";" +
                                  tt-atividade.dsstatus + ";" +
                                  tt-atividade.infrepcf + ";" +
                                  tt-atividade.tpvincul + ";" +
                                  tt-atividade.dsdjusti + ";" +
                                  tt-atividade.dsobserv + ";" +
                                  tt-atividade.dsobsctr + ";".

            PUT STREAM str_1 aux_linharel FORMAT "x(300)"
                SKIP.
        
        END.
    END.

    OUTPUT STREAM str_1 CLOSE.

    IF  par_idorigem = 5 AND par_tpdsaida = "I" THEN  /** Ayllos Web **/
        DO:
            RUN sistema/generico/procedures/b1wgen0024.p PERSISTENT
                SET h-b1wgen0024.

            IF  NOT VALID-HANDLE(h-b1wgen0024)  THEN
                DO:
                    ASSIGN aux_dscritic = "Handle invalido para BO " +
                                          "b1wgen0024.".
                END.

            RUN envia-arquivo-web IN h-b1wgen0024 ( INPUT par_cdcooper,
                                                    INPUT par_cdagenci,
                                                    INPUT par_nrdcaixa,
                                                    INPUT par_nmarquiv,
                                                    OUTPUT par_nmarqpdf,
                                                    OUTPUT TABLE tt-erro ).

            IF  VALID-HANDLE(h-b1wgen0024)  THEN
                DELETE PROCEDURE h-b1wgen0024.

            IF  RETURN-VALUE <> "OK" THEN
                RETURN 'NOK'.
        END.  
     
    RETURN "OK".

END PROCEDURE.

PROCEDURE Carrega_atividade:

    DEFINE INPUT  PARAMETER par_cdcooper    AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdagenci    AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrdcaixa    AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdoperad    AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_dtmvtolt    AS DATE        NO-UNDO.
    DEFINE INPUT  PARAMETER par_idorigem    AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_nmdatela    AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdprogra    AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_dtrefini    AS DATE        NO-UNDO.
    DEFINE INPUT  PARAMETER par_dtreffim    AS DATE        NO-UNDO.
    DEFINE OUTPUT PARAM TABLE FOR tt-atividade.
    DEFINE OUTPUT PARAMETER TABLE FOR tt-erro.
    
    DEFINE VARIABLE aux_ffechrea AS LOGICAL NO-UNDO.
    DEFINE VARIABLE aux_dsstatus AS CHARACTER   NO-UNDO.

    EMPTY TEMP-TABLE tt-atividade.
    EMPTY TEMP-TABLE tt-erro.

    FOR EACH crapcld WHERE 
             crapcld.cdcooper = par_cdcooper  AND
             crapcld.dtmvtolt >= par_dtrefini AND
             crapcld.dtmvtolt <= par_dtreffim 
             NO-LOCK:

        RUN Valida_fechamento ( INPUT par_cdcooper, 
                                INPUT par_cdagenci, 
                                INPUT par_nrdcaixa, 
                                INPUT par_cdoperad,
                                INPUT crapcld.dtmvtolt,
                                INPUT crapcld.dtmvtolt,
                                INPUT par_idorigem, 
                                INPUT par_nmdatela, 
                                OUTPUT aux_ffechrea,
                                OUTPUT TABLE tt-erro).

        EMPTY TEMP-TABLE tt-erro.

        IF aux_ffechrea THEN
            ASSIGN aux_dsstatus = "Fechado".
        ELSE
            ASSIGN aux_dsstatus = "Em analise".

        FIND crapass WHERE 
             crapass.cdcooper = crapcld.cdcooper AND
             crapass.nrdconta = crapcld.nrdconta 
             NO-LOCK NO-ERROR.

        IF  AVAIL crapass THEN
            DO:
                IF  crapass.tpvincul = "FU" OR   /* funcionario da cooperativa*/
                    crapass.tpvincul = "CA" OR   /* conselho de administracao */
                    crapass.tpvincul = "CF" OR   /* conselho fiscal */
                    crapass.tpvincul = "CC" OR   /* conselho da central */
                    crapass.tpvincul = "CO" OR   /* comite cooperativa */
                    crapass.tpvincul = "FC" OR   /* funcionario da central */
                    crapass.tpvincul = "FO" OR   /* funcionario de outras coop*/
                    crapass.tpvincul = "ET" THEN /* estagiario terceiro */ 
                    DO:

                        CREATE tt-atividade.
                        ASSIGN tt-atividade.nrdconta = crapcld.nrdconta
                               tt-atividade.dtmvtolt = crapcld.dtmvtolt
                               tt-atividade.tpvincul = crapass.tpvincul
                               tt-atividade.cdagenci = crapcld.cdagenci
                               tt-atividade.vlrendim = crapcld.vlrendim
                               tt-atividade.vltotcre = crapcld.vltotcre
                               tt-atividade.qtultren = crapcld.vltotcre / 
                                                       crapcld.vlrendim
                               tt-atividade.cddjusti = crapcld.cddjusti   
                               tt-atividade.dsdjusti = crapcld.dsdjusti  
                               tt-atividade.infrepcf = 
                                            IF  crapcld.infrepcf = 0 THEN
                                                "Nao Informar"
                                            ELSE
                                            IF  crapcld.infrepcf = 1 THEN
                                                "Informar"
                                            ELSE 
                                            IF  crapcld.infrepcf = 2 THEN
                                                "Ja informado"
                                            ELSE
                                                ""
                               tt-atividade.dsobserv = crapcld.dsobserv
                               tt-atividade.dsobsctr = crapcld.dsobsctr
                               tt-atividade.dsstatus = aux_dsstatus.
                            
                        ASSIGN aux_dsstatus = "".

                    END.
            END. /*FIM IF AVAIL */
        ELSE
            NEXT.

    END. /* FIM FOR EACH crapcld */

    FIND FIRST tt-atividade NO-ERROR.
    IF  NOT AVAIL tt-atividade THEN
       DO:
        RUN gera_erro (INPUT par_cdcooper,
                       INPUT par_cdagenci,
                       INPUT par_nrdcaixa,
                       INPUT 1,
                       INPUT 11,
                       INPUT-OUTPUT aux_dscritic).
        RETURN "NOK".
       END.

    RETURN "OK".

END PROCEDURE.

PROCEDURE Gera_log:

    DEF INPUT PARAM par_cddopcao    AS CHAR NO-UNDO.
    DEF INPUT PARAM par_teldtmvtolt AS CHAR NO-UNDO.
    DEF INPUT PARAM par_registro    AS CHAR NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt    AS DATE NO-UNDO.
    DEF INPUT PARAM par_cdoperad    AS CHAR NO-UNDO.

    UNIX SILENT VALUE("echo " + STRING(par_dtmvtolt,"99/99/9999") + " "        +
                      STRING(TIME,"HH:MM:SS") + "' -->' " + " Operador "       +
                      par_cdoperad + " '-->' Utilizou a opcao " + par_cddopcao +
                      " no dia " + par_teldtmvtolt + " e alterou o registro "     + 
                      par_registro + " >> log/cldsed.log").
END PROCEDURE.

PROCEDURE Justifica_movimento:

    DEFINE INPUT  PARAMETER par_cdcooper    AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdagenci    AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrdcaixa    AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdoperad    AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_dtmvtolt    AS DATE        NO-UNDO.
    DEFINE INPUT  PARAMETER par_idorigem    AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_nmdatela    AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdprogra    AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrdrowid    AS ROWID       NO-UNDO.
    DEFINE INPUT  PARAMETER par_cddjusti    AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_dsdjusti    AS CHAR        NO-UNDO.
    DEFINE INPUT  PARAMETER par_dsobsctr    AS CHAR        NO-UNDO.
    DEFINE INPUT  PARAMETER par_opeenvcf    AS CHAR        NO-UNDO.
    DEFINE INPUT  PARAMETER par_infrepcf    AS CHAR        NO-UNDO.
    DEFINE INPUT  PARAMETER par_teldtmvtolt AS DATE        NO-UNDO.
    DEFINE OUTPUT PARAMETER TABLE FOR tt-erro.

    DEFINE VARIABLE aux_contador            AS INTEGER     NO-UNDO.

    DO aux_contador = 1 TO 10:
    
        FIND crapcld WHERE ROWID(crapcld) = par_nrdrowid
            EXCLUSIVE-LOCK NO-ERROR.
    
        IF NOT AVAIL(crapcld)  THEN
           DO:
             IF LOCKED(crapcld) THEN
                DO:
                   IF aux_contador = 10 THEN
                      DO:
                         RUN gera_erro (INPUT par_cdcooper,        
                                        INPUT par_cdagenci,
                                        INPUT par_nrdcaixa, 
                                        INPUT 1, /* sequencia */
                                        INPUT 77,        
                                        INPUT-OUTPUT aux_dscritic).
                         RETURN "NOK".
                      END.
                   ELSE
                      DO:
                         PAUSE 1 NO-MESSAGE.
                         NEXT.
                      END.
                END.
           END.
        ELSE
           DO:
              ASSIGN crapcld.flextjus = IF par_cddjusti = 8  THEN NO
                                        ELSE YES
                     crapcld.cddjusti = par_cddjusti 
                     crapcld.dsdjusti = par_dsdjusti 
                     crapcld.dsobsctr = par_dsobsctr
                     crapcld.opeenvcf = par_opeenvcf.
                
              IF  par_infrepcf =  "Nao Informar" THEN
                  ASSIGN crapcld.infrepcf = 0.
              ELSE
              IF  par_infrepcf =  "Informar" THEN
                  ASSIGN crapcld.infrepcf = 1.
              ELSE
              IF  par_infrepcf =  "Ja Informado" THEN
                  ASSIGN crapcld.infrepcf = 2.
            
              RUN Gera_log(INPUT "Status COAF",
                           INPUT par_teldtmvtolt,
                           INPUT STRING(par_nrdrowid),
                           INPUT par_dtmvtolt,
                           INPUT par_cdoperad).
              RETURN "OK".
           END.
    END.
    RETURN "OK".

END PROCEDURE.

PROCEDURE Cancela_fechamento:

    DEFINE INPUT  PARAMETER par_cdcooper    AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdagenci    AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrdcaixa    AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdoperad    AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_dtmvtolt    AS DATE        NO-UNDO.
    DEFINE INPUT  PARAMETER par_idorigem    AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_nmdatela    AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdprogra    AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_teldtmvtolt AS DATE        NO-UNDO.
    DEFINE OUTPUT PARAMETER TABLE FOR tt-erro.

    ASSIGN aux_dscritic = "".
    DEFINE VARIABLE aux_contador AS INTEGER     NO-UNDO.

    DO aux_contador = 1 TO 10:
        
        FIND crapfld WHERE
             crapfld.cdcooper = par_cdcooper    AND
             crapfld.dtmvtolt = par_teldtmvtolt AND
             crapfld.cdtipcld = 1 /* DIARIO COOP */ 
             EXCLUSIVE-LOCK NO-ERROR.

        IF  AVAIL crapfld THEN
            DO:
                IF crapfld.dtdenvcf <> ? THEN
                    DO:
                        ASSIGN aux_dscritic = "Informacoes ja enviadas ao COAF".
                        RUN gera_erro (INPUT par_cdcooper,
                                       INPUT par_cdagenci,
                                       INPUT par_nrdcaixa,
                                       INPUT 0,
                                       INPUT 0,
                                       INPUT-OUTPUT aux_dscritic).
                        RETURN "NOK".
                    END.
                ELSE
                    DO:
                        RUN Gera_log(INPUT "Defazer Creditos",
                                     INPUT par_teldtmvtolt,
                                     INPUT "TODOS",
                                     INPUT par_dtmvtolt,
                                     INPUT par_cdoperad).
            
                        DELETE crapfld.
                        RETURN "OK".
                    END.
            END.
        ELSE
           DO:
              IF LOCKED(crapfld) THEN
                DO:
                   IF aux_contador = 10 THEN
                      DO:
                         RUN gera_erro (INPUT par_cdcooper,        
                                        INPUT par_cdagenci,
                                        INPUT par_nrdcaixa, 
                                        INPUT 1, /* sequencia */
                                        INPUT 77,        
                                        INPUT-OUTPUT aux_dscritic).
                         RETURN "NOK".
                      END.
                   ELSE
                      DO:
                        PAUSE 1 NO-MESSAGE.
			   	      	NEXT. 
                      END.
                END.
              ELSE
                 DO:
                    ASSIGN aux_dscritic = "Nao foi realizado o fechamento nesta data.".
                    RUN gera_erro (INPUT par_cdcooper,         
                                   INPUT par_cdagenci,         
                                   INPUT par_nrdcaixa,         
                                   INPUT 0,                    
                                   INPUT 0,                    
                                   INPUT-OUTPUT aux_dscritic). 
                    RETURN "NOK".
                 END.
           END.
   
    END.
    RETURN "OK".

END PROCEDURE.

PROCEDURE Efetiva_fechamento:

    DEFINE INPUT  PARAMETER par_cdcooper    AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdagenci    AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrdcaixa    AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdoperad    AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_dtmvtolt    AS DATE        NO-UNDO.
    DEFINE INPUT  PARAMETER par_idorigem    AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_nmdatela    AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdprogra    AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_teldtmvtolt AS DATE        NO-UNDO.
    DEFINE OUTPUT PARAMETER TABLE FOR tt-erro.

    EMPTY TEMP-TABLE tt-erro.    

    FOR EACH crapcld WHERE
             crapcld.cdcooper = par_cdcooper AND
             crapcld.dtmvtolt = par_dtmvtolt
             NO-LOCK:
    
        RUN Gera_log(INPUT "Fechamento Credito",
                     INPUT par_teldtmvtolt,
                     INPUT STRING(ROWID(crapcld)),
                     INPUT par_dtmvtolt,
                     INPUT par_cdoperad).
      
    END.

    Grava: 
    DO TRANSACTION
          ON ERROR  UNDO Grava, LEAVE Grava
          ON QUIT   UNDO Grava, LEAVE Grava
          ON STOP   UNDO Grava, LEAVE Grava
          ON ENDKEY UNDO Grava, LEAVE Grava:

        CREATE crapfld.
        ASSIGN crapfld.cdcooper = par_cdcooper
               crapfld.dtmvtolt = par_teldtmvtolt
               crapfld.cdoperad = par_cdoperad
               crapfld.cdtipcld = 1 /* DIARIO COOP */
               crapfld.hrtransa = TIME
               crapfld.dttransa = TODAY.
        VALIDATE crapfld.

        RETURN "OK".
    END.

END PROCEDURE.

PROCEDURE Carrega_justificativas:

    DEFINE INPUT  PARAMETER par_cdcooper    AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdagenci    AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrdcaixa    AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdoperad    AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_dtmvtolt    AS DATE        NO-UNDO.
    DEFINE INPUT  PARAMETER par_idorigem    AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_nmdatela    AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdprogra    AS CHARACTER   NO-UNDO.
    DEFINE OUTPUT PARAMETER par_nrdjusti    AS INTEGER     NO-UNDO.
    DEFINE OUTPUT PARAMETER TABLE FOR tt-just.
    DEFINE OUTPUT PARAMETER TABLE FOR tt-erro. 

    EMPTY TEMP-TABLE tt-just.
    EMPTY TEMP-TABLE tt-erro.

    ASSIGN par_nrdjusti = 0.

    FOR EACH craptab WHERE 
             craptab.cdcooper = par_cdcooper AND
             craptab.nmsistem = "JDP"        AND
             craptab.tptabela = "CONFIG"     AND
             craptab.cdempres = 0            AND
             craptab.cdacesso = "JUSTDEPOS"  
             NO-LOCK:

        CREATE tt-just.
        ASSIGN tt-just.cddjusti = craptab.tpregist        
               tt-just.dsdjusti = craptab.dstextab        
               par_nrdjusti     = par_nrdjusti + 1.       
    END.

    RETURN "OK".
END PROCEDURE.

PROCEDURE Dados_cooperativa:
    
    DEFINE INPUT  PARAMETER par_cdcooper    AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdagenci    AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrdcaixa    AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdoperad    AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_dtmvtolt    AS DATE        NO-UNDO.
    DEFINE INPUT  PARAMETER par_idorigem    AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_nmdatela    AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdprogra    AS CHARACTER   NO-UNDO.
    DEFINE OUTPUT PARAMETER TABLE FOR tt-crapcop.
    DEFINE OUTPUT PARAMETER TABLE FOR tt-erro.

    EMPTY TEMP-TABLE tt-erro.

    FIND FIRST crapcop WHERE 
               crapcop.cdcooper = par_cdcooper 
               NO-LOCK NO-ERROR.
    IF NOT AVAIL crapcop THEN DO:
        RUN gera_erro (INPUT par_cdcooper,
                       INPUT par_cdagenci,
                       INPUT par_nrdcaixa,
                       INPUT 1,
                       INPUT 794,
                       INPUT-OUTPUT aux_dscritic).
        RETURN 'NOK'.
    END.
    ELSE DO:
        CREATE tt-crapcop.
        ASSIGN tt-crapcop.cdcooper = crapcop.cdcooper
               tt-crapcop.dsdircop = crapcop.dsdircop.
    END.

    RETURN "OK".
END PROCEDURE.

PROCEDURE Carrega_creditos:

    DEFINE INPUT  PARAMETER par_cdcooper    AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdagenci    AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrdcaixa    AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdoperad    AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_dtmvtolt    AS DATE        NO-UNDO.
    DEFINE INPUT  PARAMETER par_idorigem    AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_nmdatela    AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdprogra    AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_flextjus    AS LOGICAL     NO-UNDO.
    DEFINE OUTPUT PARAM TABLE FOR tt-creditos.
    DEFINE OUTPUT PARAM TABLE FOR tt-erro.

    DEFINE VARIABLE aux_dsstatus AS CHARACTER   NO-UNDO.

    EMPTY TEMP-TABLE tt-creditos.

    FIND crapfld WHERE 
         crapfld.cdcooper = par_cdcooper AND
         crapfld.dtmvtolt = par_dtmvtolt AND
         crapfld.cdtipcld = 1 /* DIARIO COOP */
         NO-LOCK NO-ERROR.

    IF  AVAIL crapfld THEN
        ASSIGN aux_dsstatus = "Fechado".
    ELSE
        ASSIGN aux_dsstatus = "Em analise".

    FOR EACH crapcld WHERE 
             crapcld.cdcooper = par_cdcooper AND
             crapcld.dtmvtolt = par_dtmvtolt AND
             crapcld.cdtipcld = 1            AND
             crapcld.flextjus = par_flextjus 
             NO-LOCK:

        FIND crapass WHERE 
             crapass.cdcooper = crapcld.cdcooper AND
             crapass.nrdconta = crapcld.nrdconta
             NO-LOCK NO-ERROR.

        CREATE tt-creditos.                              
        ASSIGN tt-creditos.nrdconta = crapcld.nrdconta   
               tt-creditos.cdagenci = crapcld.cdagenci
               tt-creditos.dtmvtolt = crapcld.dtmvtolt
               tt-creditos.vlrendim = crapcld.vlrendim   
               tt-creditos.vltotcre = crapcld.vltotcre   
               tt-creditos.qtultren = IF crapcld.vlrendim > 0 THEN
                                         crapcld.vltotcre / crapcld.vlrendim   
                                      ELSE
                                         0
               tt-creditos.cddjusti = crapcld.cddjusti   
               tt-creditos.dsdjusti = crapcld.dsdjusti  
               tt-creditos.flextjus = crapcld.flextjus
               tt-creditos.cdoperad = crapcld.cdoperad 
               tt-creditos.infrepcf = IF crapcld.infrepcf = 0 THEN
                                         "Nao Informar"
                                      ELSE
                                      IF crapcld.infrepcf = 1 THEN
                                         "Informar"
                                      ELSE 
                                      IF crapcld.infrepcf = 2 THEN
                                         "Ja informado"
                                      ELSE
                                         ""
               tt-creditos.opeenvcf = crapcld.opeenvcf
               tt-creditos.dsobserv = crapcld.dsobserv
               tt-creditos.dsobsctr = crapcld.dsobsctr
               tt-creditos.dsstatus = aux_dsstatus
               tt-creditos.nrdrowid = ROWID(crapcld).    
                                                         
        IF  AVAIL crapass THEN
            DO:
                ASSIGN tt-creditos.nmprimtl = crapass.nmprimtl 
                       tt-creditos.inpessoa = IF crapass.inpessoa = 1 THEN
                                                STRING(crapass.inpessoa) + 
                                                "-FISICA"
                                              ELSE
                                                STRING(crapass.inpessoa) + 
                                                "-JURIDICA".
            END.

    END.

    FIND FIRST tt-creditos NO-LOCK NO-ERROR.

    IF  NOT AVAIL tt-creditos THEN
       DO:
        RUN gera_erro (INPUT par_cdcooper,
                       INPUT par_cdagenci,
                       INPUT par_nrdcaixa,
                       INPUT 1,
                       INPUT 11,
                       INPUT-OUTPUT aux_dscritic).
        RETURN "NOK".
       END.
    

    RETURN "OK".

END PROCEDURE.

