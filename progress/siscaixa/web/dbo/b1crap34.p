/*---------------------------------------------------------------------------
    
    b1crap34.p - Gera Arquivo Texto(Autenticacoes)
    
    Ultima Atualizacao: 20/10/2010
    
    Alteracoes:
                23/02/2006 - Unificacao dos bancos - SQLWorks - Eder
                
                20/10/2010 - Incluido caminho completo nas referencias do 
                             diretorio spool (Elton).
                             
                30/09/2011 - Alterar diretorio spool para
                             /usr/coop/sistema/siscaixa/web/spool (Fernando).
----------------------------------------------------------------------------*/

DEF VAR r-registro  AS ROWID.
DEF VAR p-literal   AS CHAR.
DEF VAR da-today    AS DATE                         NO-UNDO.
DEF VAR i-dia-hoje  AS INTE                         NO-UNDO.
DEF VAR i-dias      AS INTE                         NO-UNDO.
DEF VAR da-data     AS DATE                         NO-UNDO.
DEF VAR c-arquivo   AS CHAR                         NO-UNDO.
DEF VAR i-dia       AS INTE                         NO-UNDO.
DEF VAR c-dia       AS CHAR FORMAT "X(03)" EXTENT 7 NO-UNDO.
DEF VAR c-literal2  AS CHAR FORMAT "x(48)"          NO-UNDO.

DEF VAR h-b1crap00  AS HANDLE                       NO-UNDO.

ASSIGN c-dia[1] = "DOM"
       c-dia[2] = "SEG"
       c-dia[3] = "TER"
       c-dia[4] = "QUA"
       c-dia[5] = "QUI".
       c-dia[6] = "SEX".
       c-dia[7] = "SAB".

PROCEDURE gera-arquivo-texto:
    DEF INPUT  PARAM p-cooper        AS CHAR.
    DEF INPUT  PARAM p-cod-agencia   AS INTE.
    DEF INPUT  PARAM p-nro-caixa     AS INTE.
    DEF INPUT  PARAM p-opcao         AS INTE.
    DEF OUTPUT PARAM p-arquivo       AS CHAR.
    
    FIND crapcop WHERE crapcop.nmrescop = p-cooper  NO-LOCK NO-ERROR.
 
    FIND FIRST crapdat WHERE crapdat.cdcooper = crapcop.cdcooper
                             NO-LOCK NO-ERROR.
                             
    ASSIGN da-today   =  crapdat.dtmvtolt.
    ASSIGN i-dia-hoje =  WEEKDAY(da-today). 

    /*----------Gera Arquivo Texto------*/
    IF  p-opcao = i-dia-hoje THEN 
        DO:
            ASSIGN i-dias = 0.
        END.
    ELSE 
        DO:
            IF  p-opcao < i-dia-hoje  THEN 
                DO:
                    ASSIGN i-dias = i-dia-hoje - p-opcao. 
                END.
             ELSE 
                DO:
                    ASSIGN i-dias   = p-opcao   - i-dia-hoje.
                    ASSIGN da-today = (da-today + i-dias).
                    ASSIGN i-dias   = 7.
                END.
        END.

    ASSIGN da-data   = da-today - i-dias.
    ASSIGN i-dia     =  WEEKDAY(da-data).  
    ASSIGN c-arquivo = "/usr/coop/sistema/siscaixa/web/spool/" +
                       crapcop.dsdircop + 
                       STRING(p-cod-agencia,"999") + 
                       STRING(p-nro-caixa,"999") + c-dia[i-dia] + 
                       ".txt".  /* Nome Fixo  */
                       
    ASSIGN p-arquivo = "spool/"  + crapcop.dsdircop + 
                       STRING(p-cod-agencia,"999") + 
                       STRING(p-nro-caixa,"999") + c-dia[i-dia] + ".txt".  


    OUTPUT TO VALUE(c-arquivo).

    PUT UNFORMATTED 
        'Sigl Seq. Dt.Movto.               Valor   Cx Ag.   '
        'Identif.                  Saldo Ini       Tot. Pago       Tot. Rec.      Valor Rec.' SKIP
        '---- ---- --------------- -------------   -- ---   '
        '-------------------- -------------- --------------- --------------- ---------------' SKIP.

    RUN dbo/b1crap00.p PERSISTENT SET h-b1crap00.
    
    FOR EACH crapaut WHERE crapaut.cdcooper = crapcop.cdcooper  AND
                           crapaut.cdagenci    = p-cod-agencia  AND
                           crapaut.nrdcaixa    = p-nro-caixa    AND
                           crapaut.dtmvtolt    = da-data        NO-LOCK:

        ASSIGN r-registro = ROWID(crapaut).
        RUN obtem-literal-autenticacao IN h-b1crap00 (INPUT p-cooper, 
                                                      INPUT r-registro,
                                                      OUTPUT p-literal).

        ASSIGN c-literal2 = STRING(crapaut.blidenti, 'x(20)')           + " "  +
                            STRING(crapaut.blsldini,"zzz,zzz,zz9.99-")  + " "  +
                            STRING(crapaut.bltotpag,"zzz,zzz,zz9.99-")  + " "  +
                            STRING(crapaut.bltotrec,"zzz,zzz,zz9.99-")  + " "  +
                            STRING(crapaut.blvalrec,"zzz,zzz,zz9.99-").

        PUT UNFORMATTED
             p-literal  /*FORMAT "x(48)" */
             " - " 
             c-literal2 /*FORMAT "x(48)" */ SKIP.
        
    END.
    DELETE PROCEDURE h-b1crap00.
    
    OUTPUT CLOSE.
    
    RETURN "OK".
END PROCEDURE.
    
/* b1crap34.p */

/* .......................................................................... */

