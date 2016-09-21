/* ..........................................................................

   Programa: Fontes/crps295.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Margarete/Planner
   Data    : Setembro/2000                    Ultima atualizacao:

   Dados referentes ao programa:

   Frequencia: Diario (Batch - Background).
   Objetivo  : Ordena arquivos txt de extratos antes de enviar para Xerox.

   Alteracoes:

............................................................................. */

DEF INPUT PARAM par_qtlinext AS INT     FORMAT "999".
DEF INPUT PARAM par_nrseqavs AS INT     FORMAT "999999". 
DEF INPUT PARAM par_nmarqimp AS CHAR    FORMAT "x(20)".
DEF INPUT PARAM par_nmarqdat AS CHAR    FORMAT "x(20)".

DEF STREAM str_1.     /* Arquivo para leitura ate a metade  */
DEF STREAM str_2.     /* Arquivo para leitura do meio ate o final*/

DEF        VAR aux_nmarqquo AS CHAR     FORMAT "x(20)"               NO-UNDO.
DEF        VAR aux_nmarqspl AS CHAR     FORMAT "x(20)"               NO-UNDO.
DEF        VAR aux_metaqext AS INT                                   NO-UNDO.
DEF        VAR aux_lininiar AS CHAR                                  NO-UNDO.
DEF        VAR aux_linfimar AS CHAR                                  NO-UNDO.
DEF        VAR aux_inleiext AS LOG                                   NO-UNDO.
DEF        VAR aux_tmlinext AS INT                                   NO-UNDO.

ASSIGN aux_nmarqquo = substring(par_nmarqdat,1,15) + "d"
       aux_nmarqspl = substring(par_nmarqdat,1,14)
       aux_metaqext = par_nrseqavs / 2
       aux_metaqext = aux_metaqext * par_qtlinext
       aux_inleiext = yes.

UNIX SILENT VALUE("quoter " + par_nmarqdat + " > " + aux_nmarqquo).
UNIX SILENT VALUE("split -" + STRING(aux_metaqext) + " " + aux_nmarqquo +
                  " " + aux_nmarqspl).

INPUT STREAM str_1 FROM VALUE(aux_nmarqspl + "aa") NO-ECHO.
INPUT STREAM str_2 FROM VALUE(aux_nmarqspl + "ab") NO-ECHO.

OUTPUT TO VALUE(par_nmarqimp).

REPEAT:

   IMPORT STREAM str_1 aux_lininiar.
   IMPORT STREAM str_2 aux_linfimar.

   IF   aux_inleiext  THEN
        ASSIGN aux_tmlinext = LENGTH(aux_lininiar)
               aux_inleiext = no.
   
   PUT UNFORMATTED
       SUBSTRING(aux_lininiar,1,aux_tmlinext)   
       SUBSTRING(aux_linfimar,1,aux_tmlinext)   
       SKIP. 
             
END.

OUTPUT CLOSE.

UNIX SILENT VALUE("rm " + aux_nmarqspl + "aa" + " " + aux_nmarqspl + "ab" + 
                    " " + par_nmarqdat + " " + aux_nmarqquo + 
                    " 2> /dev/null").
/* .......................................................................... */
