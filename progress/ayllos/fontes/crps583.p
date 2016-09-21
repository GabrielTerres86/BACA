/* ............................................................................

   Programa: Fontes/crps583.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Guilherme/Supero
   Data    : Novembro/2010                      Ultima atualizacao: 07/06/2011

   Dados referentes ao programa:

   Frequencia: Mensal.
   Objetivo  : Atualiza os cheques "crapchd" como digitalizado - Truncagem de
               Cheques. Inicializa pelo script abbc_executa_atualizado_dig.sh
   
   Alteracoes: 23/03/2011 - Incluir as atualizacoes do crapcst e crapcdb (Ze).
   
               13/05/2011 - Acerto para selecionar a data do sistema (Ze).
               
               02/06/2011 - Tratamento para o Grupo SETEC - BB (Ze).
               
               07/06/2011 - Desprezar o crapchd para banco/caixa 600 e 700 e
                            nao atualizar caso ja esta como processado (Ze).
............................................................................. */

{ includes/var_batch.i "NEW" }

DEF STREAM str_1.

DEF TEMP-TABLE tt-arquivos
    FIELD nmarquiv AS CHAR.


DEF VAR aux_nmarquiv      AS CHAR    FORMAT "x(100)"                NO-UNDO.
DEF VAR aux_contador      AS INT                                    NO-UNDO.
DEF VAR aux_cdbanchq      AS INT                                    NO-UNDO.
DEF VAR aux_cdagechq      AS INT                                    NO-UNDO.
DEF VAR aux_cdcmpchq      AS INT                                    NO-UNDO.
DEF VAR aux_nrcheque      AS INT                                    NO-UNDO.
DEF VAR aux_nrctachq      AS DECI                                   NO-UNDO.
DEF VAR aux_setlinha      AS CHAR    FORMAT "x(60)"                 NO-UNDO.
DEF VAR aux_dsdocmc7      AS CHAR                                   NO-UNDO.
DEF VAR aux_flgachou      AS LOGICAL                                NO-UNDO.

ASSIGN glb_cdprogra = "crps583".

/* Executa para todas as cooperativas */
FOR EACH crapcop WHERE crapcop.cdcooper <> 3 NO-LOCK:

    /*  Le data do sistema  */
        
    FIND FIRST crapdat WHERE crapdat.cdcooper = crapcop.cdcooper
                             NO-LOCK NO-ERROR NO-WAIT.
                                         
    IF   NOT AVAILABLE crapdat THEN
         DO:
             UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                               glb_cdprogra + "' --> '" + "Cooperativa: " +
                               STRING(crapcop.nmrescop) +
                               " - Sem data de sistema (crapdat) " +
                               " >> log/proc_batch.log").
             NEXT.
         END.
    
    
    EMPTY TEMP-TABLE tt-arquivos.
    
    /******* ALTERAR O NOME DO ARQUIVO A SER LIDO *********/
    ASSIGN aux_nmarquiv = "/usr/coop/" + TRIM(STRING(crapcop.dsdircop)) +
                          "/integra/truncagem_nr_"                      +
                          STRING(YEAR(crapdat.dtmvtolt),"9999")         +
                          STRING(MONTH(crapdat.dtmvtolt),"99")          +
                          STRING(DAY(crapdat.dtmvtolt),"99")            +
                          "*.txt"
           aux_contador = 0.
    
    
    INPUT STREAM str_1 THROUGH VALUE("ls " + aux_nmarquiv) NO-ECHO.
    
    DO WHILE TRUE ON ERROR UNDO, LEAVE ON ENDKEY UNDO, LEAVE:
    
       IMPORT STREAM str_1 UNFORMATTED aux_setlinha.

       CREATE tt-arquivos.
       ASSIGN tt-arquivos.nmarquiv = aux_setlinha.
       
    END.
       
    INPUT STREAM str_1 CLOSE.

    FOR EACH tt-arquivos:
    
        ASSIGN aux_contador = 0.
        
        INPUT STREAM str_1 FROM VALUE(tt-arquivos.nmarquiv) NO-ECHO.
    
        DO WHILE TRUE ON ERROR UNDO, LEAVE ON ENDKEY UNDO, LEAVE:
    
           IMPORT STREAM str_1 UNFORMATTED aux_setlinha.

           IF   SUBSTR(aux_setlinha,31,1) = "V" THEN
                NEXT.
           
           ASSIGN aux_contador = aux_contador + 1
                  aux_flgachou = FALSE.
       
           /* 01 a 03   - Numero do Banco   */
           /* 04 a 07   - Numero da Agencia */
           /* 09 a 11   - Codigo da Compe   */
           /* 12 a 17   - Numero do Cheque  */
           /* 20 a 29   - Numero da Conta   */
    
           ASSIGN aux_cdbanchq = INT(SUBSTR(aux_setlinha,01,3))
                  aux_cdagechq = INT(SUBSTR(aux_setlinha,04,4))
                  aux_cdcmpchq = INT(SUBSTR(aux_setlinha,09,3))
                  aux_nrcheque = INT(SUBSTR(aux_setlinha,12,6))
                  aux_nrctachq = DECIMAL(SUBSTR(aux_setlinha,20,10)).
    
           RUN verifica_cheque.
           
           IF   aux_flgachou = FALSE THEN
                DO:
                    IF   aux_cdbanchq = 1 THEN
                         DO:
                             aux_nrctachq = DECIMAL(SUBSTR(aux_setlinha,22,08)).
                             RUN verifica_cheque.
                         END.
                END.
           
       END.  /*  Fim do DO WHILE TRUE  */

       INPUT STREAM str_1 CLOSE.
    
       IF   aux_contador = 0 THEN
            UNIX SILENT VALUE("rm " + tt-arquivos.nmarquiv + " 2> /dev/null").
       ELSE
            /* Eliminar arquivos diretorio */
            UNIX SILENT VALUE("mv " + tt-arquivos.nmarquiv + " " + 
                              "/usr/coop/" + TRIM(STRING(crapcop.dsdircop)) + 
                              "/salvar").

    END.   /*  Fim do For Each  */
    
     
END. /* END do FOR EACH crapcop */    

QUIT.


PROCEDURE verifica_cheque:
           
   DO TRANSACTION ON ERROR UNDO, LEAVE:
    
      FIND LAST crapchd WHERE crapchd.cdcooper = crapcop.cdcooper AND
                              crapchd.dtmvtolt = crapdat.dtmvtolt AND
                              crapchd.cdcmpchq = aux_cdcmpchq     AND
                              crapchd.cdbanchq = aux_cdbanchq     AND
                              crapchd.cdagechq = aux_cdagechq     AND
                              crapchd.nrctachq = aux_nrctachq     AND
                              crapchd.nrcheque = aux_nrcheque     AND
                              crapchd.cdbccxlt <> 600             AND
                              crapchd.cdbccxlt <> 700
                              EXCLUSIVE-LOCK NO-ERROR.
    
      IF   AVAILABLE crapchd THEN
           DO:
               ASSIGN aux_flgachou = TRUE.
               
               IF   crapchd.insitprv <> 3 THEN
                    ASSIGN crapchd.insitprv = 2.
           END.       
      ELSE
           DO:
               ASSIGN aux_dsdocmc7 = "<" +
                               SUBSTR(aux_setlinha,01,08) + "<" +
                               SUBSTR(aux_setlinha,09,10) + ">" +
                               SUBSTR(aux_setlinha,19,12) + ":". 
                                
               FIND LAST crapcdb WHERE 
                         crapcdb.cdcooper = crapcop.cdcooper AND
                         crapcdb.dsdocmc7 = aux_dsdocmc7
                         USE-INDEX crapcdb9 EXCLUSIVE-LOCK NO-ERROR.
    
               IF   AVAILABLE crapcdb THEN
                    DO:
                        ASSIGN aux_flgachou = TRUE.
                        
                        IF   crapcdb.insitprv <> 3 THEN
                             crapcdb.insitprv = 2.
                    END.       
               ELSE
                    DO:
                        FIND LAST crapcst WHERE 
                                  crapcst.cdcooper = crapcop.cdcooper AND
                                  crapcst.dsdocmc7 = aux_dsdocmc7
                                  USE-INDEX crapcst7 EXCLUSIVE-LOCK NO-ERROR.
    
                        IF   AVAILABLE crapcst THEN
                             DO:
                                 ASSIGN aux_flgachou = TRUE.
                                 
                                 IF   crapcst.insitprv <> 3 THEN
                                      crapcst.insitprv = 2.
                             END.         
                    END.
           END.
    
   END. /* END do TRANSACTION*/

END PRoCEDURE.   
    
/* .......................................................................... */
