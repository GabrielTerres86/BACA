
/*---------------------------------------------------------------*/
/*  b1crap40.p - Importacao Autenticacoes OFF-LINE               */
/*---------------------------------------------------------------*/

{dbo/bo-erro1.i}

DEF VAR i-cod-erro  AS INTEGER.
DEF VAR c-desc-erro AS CHAR.

DEF VAR l-teve-movtos AS LOG NO-UNDO.

DEF STREAM s-imp.

DEF VAR h-b1crap00 AS HANDLE     NO-UNDO.

DEF TEMP-TABLE tt-crapaut
    FIELD cdcooper LIKE crapaut.cdcooper
    FIELD cdagenci LIKE crapaut.cdagenci
    FIELD nrdcaixa LIKE crapaut.nrdcaixa
    FIELD dtmvtolt LIKE crapaut.dtmvtolt
    FIELD nrsequen LIKE crapaut.nrsequen
    FIELD cdopecxa LIKE crapaut.cdopecxa
    FIELD hrautent LIKE crapaut.hrautent
    FIELD vldocmto LIKE crapaut.vldocmto
    FIELD nrdocmto LIKE crapaut.nrdocmto
    FIELD tpoperac LIKE crapaut.tpoperac
    FIELD cdstatus LIKE crapaut.cdstatus
    FIELD estorno  LIKE crapaut.estorno
    FIELD nrseqaut LIKE crapaut.nrseqaut
    FIELD blidenti LIKE crapaut.blidenti
    FIELD cdhistor LIKE crapaut.cdhistor.

 
DEF VAR in01             AS INTE NO-UNDO.
DEF VAR c-dia            AS CHAR FORMAT "X(03)" EXTENT 7 NO-UNDO.
DEF VAR c-arquivo        AS CHAR FORMAT "x(30)" NO-UNDO.
DEF VAR c-arquivo-backup AS CHAR FORMAT "x(30)" NO-UNDO.
DEF VAR p-literal        AS CHAR NO-UNDO.
DEF VAR p-ult-sequencia  AS INTE NO-undo.
DEF VAR p-registro       AS RECID NO-UNDO.
DEF VAR c-diretorio      AS CHAR NO-UNDO.


ASSIGN c-dia[1] = "dom"
       c-dia[2] = "seg"
       c-dia[3] = "ter"
       c-dia[4] = "qua"
       c-dia[5] = "qui"
       c-dia[6] = "sex"
       c-dia[7] = "sab".


PROCEDURE importacao.
    DEF INPUT  PARAM p-cooper              AS CHAR.
    DEF INPUT  PARAM p-cod-agencia         AS INTE.
    DEF INPUT  PARAM p-nro-caixa           AS INTE.
    
    FIND crapcop WHERE crapcop.nmrescop = p-cooper NO-LOCK NO-ERROR.

    RUN elimina-erro (INPUT p-cooper,
                      INPUT p-cod-agencia,
                      INPUT p-nro-caixa).
    
    ASSIGN c-diretorio = crapcop.nmdireto.

    FOR EACH tt-crapaut:
        DELETE tt-crapaut.
    END.

    in01 = 1.  
    DO  WHILE in01 LE 7:

        ASSIGN c-arquivo       
           = c-diretorio + "/off-line/" +  string(p-cod-agencia,"999") +            string(p-nro-caixa,"999") + 
           c-dia[in01] + ".txt".  /* Nome Fixo  */
        
        ASSIGN c-arquivo-backup = c-diretorio + "/backup/"   + 
         string(p-cod-agencia,"999") + 
         string(p-nro-caixa,"999") + 
         c-dia[in01] + STRING(TIME) + ".txt".  /* Nome Fixo  */

        IF  SEARCH (c-arquivo) <> ?  THEN DO:
          
            ASSIGN c-arquivo = SEARCH(c-arquivo).
            
            input STREAM s-imp from VALUE(c-arquivo).
            
            repeat:
                  CREATE tt-crapaut.
                  import  STREAM s-imp DELIMITER ";" 
                          tt-crapaut.cdcooper
                          tt-crapaut.cdagenci
                          tt-crapaut.nrdcaixa
                          tt-crapaut.dtmvtolt
                          tt-crapaut.nrsequen
                          tt-crapaut.cdopecxa
                          tt-crapaut.hrautent
                          tt-crapaut.vldocmto
                          tt-crapaut.nrdocmto
                          tt-crapaut.tpoperac
                          tt-crapaut.cdstatus
                          tt-crapaut.estorno
                          tt-crapaut.nrseqaut
                          tt-crapaut.blidenti
                          tt-crapaut.cdhistor.
 
            END. /* repeat */
            
            
            OS-COPY VALUE(c-arquivo)  VALUE(c-arquivo-backup).
            OS-DELETE VALUE(c-arquivo).
        END.
        ASSIGN in01 = in01 + 1.
    END.
    
    ASSIGN l-teve-movtos = NO.
    RUN dbo/b1crap00.p PERSISTENT SET h-b1crap00.
    FOR EACH tt-crapaut :
        IF  tt-crapaut.cdagenci  = 0  and
            tt-crapaut.nrdcaixa  = 0  THEN   NEXT.
       
        ASSIGN l-teve-movtos = YES.
        ASSIGN tt-crapaut.vldocmto = tt-crapaut.vldocmto / 100.
        RUN grava-autenticacao-offline
               IN h-b1crap00 (INPUT p-cooper,
                              INPUT tt-crapaut.cdagenci,
                              INPUT tt-crapaut.nrdcaixa,
                              INPUT tt-crapaut.cdopecxa,
                              INPUT tt-crapaut.vldocmto,
                              INPUT dec(tt-crapaut.nrdocmto),
                              INPUT tt-crapaut.tpoperac, /* YES(PG),NO(REC) */
                              INPUT "2",        /* Off-line       */         
                              INPUT tt-crapaut.estorno,
                              INPUT tt-crapaut.blidenti,
                              INPUT tt-crapaut.cdhistor,
                              INPUT tt-crapaut.dtmvtolt,
                              INPUT tt-crapaut.nrsequen,
                              INPUT tt-crapaut.hrautent,
                              INPUT tt-crapaut.nrseqaut,
                              OUTPUT p-literal,
                              OUTPUT p-ult-sequencia,
                              OUTPUT p-registro).
    END.
    DELETE PROCEDURE h-b1crap00. 

    IF  l-teve-movtos = NO  THEN  DO:
        
        ASSIGN i-cod-erro  = 0
               c-desc-erro =  "Nao existem arquivos pendentes(Importacao)".
        RUN cria-erro (INPUT p-cooper,
                       INPUT p-cod-agencia,
                       INPUT p-nro-caixa,
                       INPUT i-cod-erro,
                       INPUT c-desc-erro,
                       INPUT YES).
        RETURN "NOK". 
    END.

    ELSE
         DO:
               ASSIGN i-cod-erro  = 0
                      c-desc-erro =  "Arquivo Importado com SUCESSO".
               RUN cria-erro (INPUT p-cooper,
                              INPUT p-cod-agencia,
                              INPUT p-nro-caixa,
                              INPUT i-cod-erro,
                              INPUT c-desc-erro,
                              INPUT YES).
               RETURN "OK".
         END.
END PROCEDURE.

 
/* b1crap40.p */
    
       
