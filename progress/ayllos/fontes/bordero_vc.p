/* .............................................................................

   Programa: Fontes/bordero_vc.p
   Sistema : Conta-Corrente - Cooperativa 
   Sigla   : CRED
   Autor   : Edson
   Data    : Marco/2003                          Ultima atualizacao: 29/05/2014

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Rotina para visualizar os cheques associados ao bordero.

   Alteracoes: 20/09/2005 - Alterado para ler tbm codigo da cooperativa na
                            tabela crapabc (Diego).
    
               03/02/2006 - Unificacao dos Bancos - SQLWorks - Luciane.
               
               29/05/2014 - Concatena o numero do servidor no endereco do
                            terminal (Andrino-RKAM)
               
............................................................................. */

DEF INPUT PARAM par_recid    AS INT                                 NO-UNDO.

DEF STREAM str_1.

{ includes/var_online.i }

DEF VAR rel_nmcheque AS CHAR FORMAT "x(40)"                         NO-UNDO.
DEF VAR rel_dscpfcgc AS CHAR FORMAT "x(19)"                         NO-UNDO.

DEF VAR aux_nmendter AS CHAR                                        NO-UNDO.
DEF VAR aux_nmarqimp AS CHAR                                        NO-UNDO.
DEF VAR aux_dsdtraco AS CHAR                                        NO-UNDO.

DEF VAR aux_vltotchq AS DECIMAL                                     NO-UNDO.
DEF VAR aux_qttotchq AS INT                                         NO-UNDO.

DEF VAR tel_dsvisual AS CHAR VIEW-AS EDITOR SIZE 80 BY 15 PFCOLOR 0 NO-UNDO.    

DEF FRAME f_visualiza
    tel_dsvisual HELP "Pressione <F4> ou <END> para finalizar" 
    WITH SIZE 78 BY 15 ROW 6 COLUMN 2 USE-TEXT NO-BOX NO-LABELS OVERLAY.

DEF FRAME f_label
    "Cmp Bco Ag.  C1    Conta/Nome C2  Cheque C3" AT  2
    "Valor"                                       AT 55
    "CPF/CNPJ"                                    AT 62
    SKIP(1)
    WITH NO-BOX.

DEF FRAME f_cheques
    crapcdb.cdcmpchq AT  2 FORMAT "999"
    crapcdb.cdbanchq AT  6 FORMAT "999"
    crapcdb.cdagechq AT 10 FORMAT "9999"
    crapcdb.nrddigc1 AT 16 FORMAT "9"
    crapcdb.nrctachq AT 18 FORMAT "zzzzzzz,zzz,9"
    crapcdb.nrddigc2 AT 33 FORMAT "9"
    crapcdb.nrcheque AT 35 FORMAT "zzz,zz9"
    crapcdb.nrddigc3 AT 44 FORMAT "9"
    crapcdb.vlcheque AT 46 FORMAT "zzz,zzz,zz9.99"
    rel_dscpfcgc     AT 62 FORMAT "x(19)"
    SKIP
    crapcdb.dtlibera AT  2 FORMAT "99/99/9999"
    rel_nmcheque     AT 18 FORMAT "x(40)"
    WITH NO-BOX NO-LABELS DOWN.

DEF FRAME f_total
    "TOTAL ==>"      AT 18
    aux_qttotchq           FORMAT "z,zz9" "CHEQUES"
    aux_vltotchq     AT 46 FORMAT "zzz,zzz,zz9.99"
    WITH NO-BOX NO-LABELS DOWN.

FORM " ===>"
     crapabc.dsrestri FORMAT "x(60)"
/*   "Obs.:"
     crapabc.dsobserv FORMAT "x(25)"   */
     WITH NO-LABELS DOWN FRAME f_restricoes.

DEF FRAME f_traco
    aux_dsdtraco FORMAT "x(80)"
    WITH NO-BOX NO-LABELS.

/* .......................................................................... */

FIND crapbdc WHERE RECID(crapbdc) = par_recid NO-LOCK NO-ERROR.

IF   NOT AVAILABLE crapbdc   THEN
     RETURN.

INPUT THROUGH basename `tty` NO-ECHO.

SET aux_nmendter WITH FRAME f_terminal.

INPUT CLOSE.

aux_nmendter = substr(glb_hostname,length(glb_hostname) - 1) +
                      aux_nmendter.

UNIX SILENT VALUE("rm rl/" + aux_nmendter + "* 2> /dev/null").

ASSIGN aux_nmarqimp = "rl/" + aux_nmendter + STRING(TIME) + ".ex"
       aux_dsdtraco = FILL("-",80).

OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp).            

VIEW STREAM str_1 FRAME f_label.
/* 
FOR EACH crapcdb WHERE crapcdb.cdcooper = glb_cdcooper       AND
                       crapcdb.dtmvtolt = crapbdc.dtmvtolt   AND
                       crapcdb.cdagenci = crapbdc.cdagenci   AND
                       crapcdb.cdbccxlt = crapbdc.cdbccxlt   AND
                       crapcdb.nrdolote = crapbdc.nrdolote   NO-LOCK
                       USE-INDEX crapcdb4:
*/
FOR EACH crapcdb WHERE crapcdb.cdcooper = glb_cdcooper       AND
                       crapcdb.nrborder = crapbdc.nrborder   NO-LOCK:
    
    FIND FIRST crapcec WHERE crapcec.cdcooper = glb_cdcooper       AND
                             crapcec.cdcmpchq = crapcdb.cdcmpchq   AND
                             crapcec.cdbanchq = crapcdb.cdbanchq   AND
                             crapcec.cdagechq = crapcdb.cdagechq   AND
                             crapcec.nrctachq = crapcdb.nrctachq   AND
                             crapcec.nrcpfcgc = crapcdb.nrcpfcgc    
                             NO-LOCK NO-ERROR.
 
    IF   NOT AVAILABLE crapcec   THEN
         ASSIGN rel_dscpfcgc = "NAO CADASTRADO"
                rel_nmcheque = "NAO CADASTRADO".
    ELSE
         RUN p_monta_cpfcgc.
   
    ASSIGN aux_vltotchq = aux_vltotchq + crapcdb.vlcheque
           aux_qttotchq = aux_qttotchq + 1.
       
    DISPLAY STREAM str_1
            crapcdb.cdcmpchq crapcdb.cdbanchq crapcdb.cdagechq
            crapcdb.nrddigc1 crapcdb.nrctachq crapcdb.nrddigc2
            crapcdb.nrcheque crapcdb.nrddigc3 crapcdb.vlcheque
            rel_dscpfcgc     crapcdb.dtlibera rel_nmcheque
            WITH FRAME f_cheques.
                
    DOWN STREAM str_1 WITH FRAME f_cheques.

    /*  Leitura das restricoes para o cheque  */

    FOR EACH crapabc WHERE crapabc.cdcooper = glb_cdcooper       AND
                           crapabc.nrborder = crapbdc.nrborder   AND
                           crapabc.cdagechq = crapcdb.cdagechq   AND
                           crapabc.cdbanchq = crapcdb.cdbanchq   AND
                           crapabc.cdcmpchq = crapcdb.cdcmpchq   AND
                           crapabc.nrctachq = crapcdb.nrctachq   AND
                           crapabc.nrcheque = crapcdb.nrcheque   NO-LOCK:

        DISPLAY STREAM str_1 
                       crapabc.dsrestri /* crapabc.dsobserv  */
                       WITH FRAME f_restricoes.

        DOWN STREAM str_1 WITH FRAME f_restricoes.
        
    END.  /*  Fim do FOR EACH -- Leitura das restricoes  */

    DISPLAY STREAM str_1 aux_dsdtraco WITH FRAME f_traco.                       
                           
END.  /*  Fim do FOR EACH  */                       

/*  Restricoes GERAIS ....................................................... */
       
FOR EACH crapabc WHERE crapabc.cdcooper = glb_cdcooper       AND
                       crapabc.nrborder = crapbdc.nrborder   AND
                       crapabc.cdcmpchq = 888                AND
                       crapabc.cdagechq = 8888               AND
                       crapabc.cdbanchq = 888                AND
                       crapabc.nrctachq = 8888888888         AND
                       crapabc.nrcheque = 888888             NO-LOCK:

    DISPLAY STREAM str_1 
                   crapabc.dsrestri /* crapabc.dsobserv  */
                   WITH FRAME f_restricoes.

    DOWN STREAM str_1 WITH FRAME f_restricoes.
         
END.  /*  Fim do FOR EACH -- Leitura das restricoes GERAIS  */

DISPLAY STREAM str_1 aux_qttotchq aux_vltotchq WITH FRAME f_total.     

OUTPUT STREAM str_1 CLOSE.

DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

   ENABLE tel_dsvisual WITH FRAME f_visualiza.
   DISPLAY tel_dsvisual WITH FRAME f_visualiza.
   ASSIGN tel_dsvisual:READ-ONLY IN FRAME f_visualiza = YES.

   IF   tel_dsvisual:INSERT-FILE(aux_nmarqimp)   THEN
        DO:
            ASSIGN tel_dsvisual:cursor-line in frame f_visualiza = 1.
            WAIT-FOR GO OF tel_dsvisual IN FRAME f_visualiza.
        END.
   
   LEAVE.
     
END.  /*  Fim do DO WHILE TRUE  */

HIDE FRAME f_visualiza NO-PAUSE.

/* .......................................................................... */

PROCEDURE p_monta_cpfcgc:

    ASSIGN glb_nrcalcul = crapcec.nrcpfcgc
           rel_nmcheque = 
               TRIM(crapcec.nmcheque) + 
               (IF crapcec.nrdconta > 0
                   THEN " (" + TRIM(STRING(crapcec.nrdconta,"zzzz,zzz,9")) + ")"
                   ELSE "").
         
    IF   LENGTH(STRING(crapcec.nrcpfcgc)) > 11   THEN
         DO:
             ASSIGN rel_dscpfcgc = STRING(crapcec.nrcpfcgc,"99999999999999")
                    rel_dscpfcgc = STRING(rel_dscpfcgc,"xx.xxx.xxx/xxxx-xx").

             RETURN.
         END.
    
    RUN fontes/cpffun.p.
           
    IF   glb_stsnrcal   THEN
         ASSIGN rel_dscpfcgc = STRING(crapcec.nrcpfcgc,"99999999999")
                rel_dscpfcgc = STRING(rel_dscpfcgc,"xxx.xxx.xxx-xx").
    ELSE
         ASSIGN rel_dscpfcgc = STRING(crapcec.nrcpfcgc,"99999999999999")
                rel_dscpfcgc = STRING(rel_dscpfcgc,"xx.xxx.xxx/xxxx-xx").
                     
END PROCEDURE.

/* .......................................................................... */


