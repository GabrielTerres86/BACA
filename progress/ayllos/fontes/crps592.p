/* ..........................................................................

   Programa: Fontes/crps592.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Elton
   Data    : Marco/2011                        Ultima atualizacao: 24/05/2011

   Dados referentes ao programa:

   Frequencia: Diario (Batch).
   Objetivo  : Atende a solicitacao 001.
               Integrar Arquivos de Critica da ABBC (COMPE IMAGEM).      
               
   Alteracoes: 24/05/2011 - Alteracao de Layout do arquivo (Ze).

.............................................................................*/

{ includes/var_batch.i }


DEF VAR aux_setlinha        AS CHAR FORMAT "x(250)"                   NO-UNDO.
DEF VAR aux_dsdocmc7        AS CHAR FORMAT "x(34)"                    NO-UNDO.

DEF VAR aux_nmarqint        AS CHAR                                   NO-UNDO.
DEF VAR aux_cdbanchq        AS INTE                                   NO-UNDO.
DEF VAR aux_cdagechq        AS INTE                                   NO-UNDO.
DEF VAR aux_cdcmpchq        AS INTE                                   NO-UNDO.
DEF VAR aux_nrcheque        AS INTE                                   NO-UNDO.
DEF VAR aux_nrctachq        AS DECI                                   NO-UNDO.

DEF STREAM str_1.
DEF STREAM str_2.

ASSIGN glb_cdprogra = "crps592".

RUN fontes/iniprg.p.

IF  glb_cdcritic > 0 THEN
    RETURN.


FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.

IF   NOT AVAILABLE crapcop  THEN
     DO:
         glb_cdcritic = 651.
         RUN fontes/critic.p.
         UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                           " - " + glb_cdprogra + "' --> '"  +
                           glb_dscritic + " >> log/proc_batch.log").
         RETURN.  
     END.


ASSIGN aux_nmarqint = "compabbc/E*.PRN".    

INPUT STREAM str_1 THROUGH VALUE("ls " + aux_nmarqint + " 2> /dev/null") 
             NO-ECHO.
                
DO WHILE TRUE ON ERROR UNDO, LEAVE ON ENDKEY UNDO, LEAVE:   
                                             
   SET STREAM str_1 aux_nmarqint FORMAT "x(40)" .
      
   UNIX SILENT VALUE("quoter " + aux_nmarqint + " > " + aux_nmarqint + ".q").
           
   INPUT STREAM str_2 FROM VALUE(aux_nmarqint + ".q") NO-ECHO.
                           
   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                                  
      SET STREAM str_2 aux_setlinha WITH FRAME AA WIDTH 350.

      IF  SUBSTR(aux_setlinha,1,27) = "Imagem Verso nao Localizado" THEN
          DO: 
              ASSIGN aux_dsdocmc7 = SUBSTR(aux_setlinha,137,30).

              ASSIGN aux_dsdocmc7 = "<" +
                               SUBSTR(aux_setlinha,137,08) + "<" +
                               SUBSTR(aux_setlinha,145,10) + ">" +
                               SUBSTR(aux_setlinha,155,12) + ":". 
                                
              FIND LAST crapcst WHERE crapcst.cdcooper = glb_cdcooper AND
                                      crapcst.dsdocmc7 = aux_dsdocmc7
                                      USE-INDEX crapcst7 
                                      EXCLUSIVE-LOCK NO-ERROR.
                                                 
              IF   AVAILABLE crapcst THEN                      
                   ASSIGN crapcst.insitprv = 0
                          crapcst.dtprevia = ?.
              ELSE
                   DO:  
                       FIND LAST crapcdb WHERE 
                                         crapcdb.cdcooper = glb_cdcooper AND
                                         crapcdb.dsdocmc7 = aux_dsdocmc7
                                         USE-INDEX crapcdb9 
                                         EXCLUSIVE-LOCK NO-ERROR.
    
                       IF   AVAILABLE crapcdb THEN  
                            ASSIGN crapcdb.insitprv = 0 
                                   crapcdb.dtprevia = ?.
                   END.
          END.

      ELSE
      IF  SUBSTR(aux_setlinha,1,22) = "Registro nao Existente" THEN
          DO:         
              ASSIGN aux_cdbanchq = INT(SUBSTR(aux_setlinha,64,3))
                     aux_cdagechq = INT(SUBSTR(aux_setlinha,67,4))
                     aux_cdcmpchq = INT(SUBSTR(aux_setlinha,61,3))
                     aux_nrcheque = INT(SUBSTR(aux_setlinha,85,6))
                     aux_nrctachq = DECIMAL(SUBSTR(aux_setlinha,72,12)). 
                      
              FIND LAST crapcst WHERE    /** Custodia **/
                                 crapcst.cdcooper = glb_cdcooper     AND
                                 crapcst.cdcmpchq = aux_cdcmpchq     AND
                                 crapcst.cdbanchq = aux_cdbanchq     AND
                                 crapcst.cdagechq = aux_cdagechq     AND
                                 crapcst.nrctachq = aux_nrctachq     AND
                                 crapcst.nrcheque = aux_nrcheque     
                                 EXCLUSIVE-LOCK NO-ERROR.
                 
              IF   AVAIL crapcst THEN                
                   ASSIGN crapcst.insitprv = 0
                          crapcst.dtprevia = ?.
              ELSE
                   DO:
                      FIND LAST crapcdb WHERE  /** Desconto de Cheque **/
                                     crapcdb.cdcooper = glb_cdcooper     AND
                                     crapcdb.cdcmpchq = aux_cdcmpchq     AND
                                     crapcdb.cdbanchq = aux_cdbanchq     AND
                                     crapcdb.cdagechq = aux_cdagechq     AND
                                     crapcdb.nrctachq = aux_nrctachq     AND
                                     crapcdb.nrcheque = aux_nrcheque
                                     EXCLUSIVE-LOCK NO-ERROR.
                                                            
                      IF  AVAIL crapcdb THEN               
                          ASSIGN crapcdb.insitprv = 0
                                 crapcdb.dtprevia = ?.
                      ELSE
                          DO:
                             IF  aux_cdbanchq = 1 THEN
                                 DO:
                                    aux_nrctachq = 
                                           DECIMAL(SUBSTR(aux_setlinha,76,08)).
  
                                    FIND LAST crapcst WHERE
                                         crapcst.cdcooper = glb_cdcooper AND
                                         crapcst.cdcmpchq = aux_cdcmpchq AND
                                         crapcst.cdbanchq = aux_cdbanchq AND
                                         crapcst.cdagechq = aux_cdagechq AND
                                         crapcst.nrctachq = aux_nrctachq AND
                                         crapcst.nrcheque = aux_nrcheque
                                         EXCLUSIVE-LOCK NO-ERROR.
                 
                                    IF  AVAIL crapcst THEN
                                        ASSIGN crapcst.insitprv = 0
                                               crapcst.dtprevia = ?.
                                    ELSE
                                         DO:
                                           FIND LAST crapcdb WHERE
                                             crapcdb.cdcooper = glb_cdcooper AND
                                             crapcdb.cdcmpchq = aux_cdcmpchq AND
                                             crapcdb.cdbanchq = aux_cdbanchq AND
                                             crapcdb.cdagechq = aux_cdagechq AND
                                             crapcdb.nrctachq = aux_nrctachq AND
                                             crapcdb.nrcheque = aux_nrcheque
                                             EXCLUSIVE-LOCK NO-ERROR.
                                                            
                                           IF   AVAIL crapcdb THEN
                                                ASSIGN crapcdb.insitprv = 0
                                                       crapcdb.dtprevia = ?.
                                         END.
                                 END.   
                          END.
                   END.    
          END.              
   END.

   /* Remover arquivo quoter */
   UNIX SILENT VALUE("rm " + aux_nmarqint + ".q" + " 2>/dev/null").
      
   /* Mover arquivo da ABBC do integra pra o salvar */
   UNIX SILENT VALUE("mv " + aux_nmarqint + " salvar" + " 2>/dev/null").

END.

OUTPUT STREAM str_1 CLOSE.
OUTPUT STREAM str_2 CLOSE.

         
RUN fontes/fimprg.p.
         
/* .......................................................................... */