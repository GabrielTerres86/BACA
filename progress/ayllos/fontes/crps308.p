/*..............................................................................

   Programa: Fontes/crps308.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Ze Eduardo
   Data    : Abril/2001.                     Ultima atualizacao: 18/03/2008

   Dados referentes ao programa:

   Frequencia : Somente nas Segundas-feiras (Batch).
   Objetivo   : Atender a solicitacao 002 (Diario de relatorio).
                Gerar arquivo de Acompanhamento da Custodia.
                Emite relatorio 261 - 80 col.

   Alteracoes:  31/07/2001 - Alteracoes do campo nrdocmto para nrcheque (Ze).
   
                14/08/2001 - Alterar mensagem da transmissao de arquivo no
                             log do processo (Junior).
                             
               19/09/2002 - Alterado para enviar arquivo de acompanhamento de
                            custodia automaticamente (Junior).
                            
               22/11/2002 - Colocar "&" no final do comando "MT  SEND" (Junior).
               
               21/09/2005 - Modificado FIND FIRST para FIND na tabela 
                            crapcop.cdcooper = glb_cdcooper (Diego).  
                            
               16/10/2005 - Alteracao de crapchq p/ crapfdc (SQLWorks - Andre).
               
               25/11/2005 - Incluido o tipo do cheque na busca e label da
                            quantidade de cheques (Evandro).
               
               13/12/2005 - Leitura do crapfdc com erro (Magui).
               
               16/02/2006 - Unificacao dos bancos - SQLWorks - Eder

               30/08/2006 - Alterado envio de email pela BO b1wgen0011 (David).
               
               13/02/2007 - Alterar consultas com indice crapfdc1 (David).
               
               12/04/2007 - Retirar rotina de email em comentario (David).

               18/03/2008 - Retirado comentario da rotina de envio de email
                            (Sidnei - Precise)

.............................................................................*/

DEF STREAM str_1.  /* Para relatorio  */

{ includes/var_online.i "NEW" }
                                                                     
DEF TEMP-TABLE crawcus                                                 NO-UNDO
     FIELD cbanco LIKE crapcst.cdbanchq
     FIELD cagenc LIKE crapcst.cdagechq
     FIELD cconta LIKE crapcst.nrctachq
     FIELD cvalor LIKE crapcst.vlcheque 
     FIELD cliber LIKE crapcst.dtlibera
     INDEX cus1 AS PRIMARY
           cbanco cagenc cconta.
 
DEF BUFFER crawcut FOR crawcus.

DEF    VAR b1wgen0011     AS HANDLE                                    NO-UNDO.

DEF    VAR rel_nmempres   AS CHAR      FORMAT "x(15)"                  NO-UNDO.
DEF    VAR rel_nmresemp   AS CHAR      FORMAT "x(15)"                  NO-UNDO.
DEF    VAR rel_nmrelato   AS CHAR      FORMAT "x(40)"  EXTENT 5        NO-UNDO.
DEF    VAR rel_nrmodulo   AS INT       FORMAT "9"                      NO-UNDO.
DEF    VAR rel_nmmodulo   AS CHAR      FORMAT "x(15)"  EXTENT 5
                                       INIT ["DEP. A VISTA   ",
                                             "CAPITAL        ",
                                             "EMPRESTIMOS    ",
                                             "DIGITACAO      ",
                                             "GENERICO       "]        NO-UNDO.
DEF    VAR aux_cddbanco   AS INTEGER   FORMAT "zz9"                    NO-UNDO.
DEF    VAR aux_cdagenci   AS INTEGER   FORMAT "z,zz9"                  NO-UNDO.
DEF    VAR aux_nrdconta   AS DECIMAL   FORMAT "zzz,zzz,zzz,zzz,z"      NO-UNDO.
DEF    VAR aux_vlvalor1   AS DECIMAL   FORMAT "zzz,zzz,zzz,zzz.99"     NO-UNDO.
DEF    VAR aux_nrquante   AS INTEGER   FORMAT "z,zz9"                  NO-UNDO.
DEF    VAR aux_dtlibera   AS DATE      FORMAT "99/99/9999"             NO-UNDO.
DEF    VAR aux_vlvalor2   AS DECIMAL                                   NO-UNDO.
DEF    VAR aux_vlvalor3   AS DECIMAL                                   NO-UNDO.
DEF    VAR aux_nrsalmes   AS INTEGER                                   NO-UNDO.
DEF    VAR aux_primavez   AS LOGICAL                                   NO-UNDO.
DEF    VAR aux_salvacc1   AS DECIMAL                                   NO-UNDO.
DEF    VAR aux_contador   AS INTEGER                                   NO-UNDO.
DEF    VAR aux_flgexeok   AS LOGICAL                                   NO-UNDO.
DEF    VAR rel_qtcheque   AS INTEGER   FORMAT "zzz,zz9"                NO-UNDO.
DEF    VAR sub_vlcustod   AS DECIMAL   FORMAT "zzz,zzz,zzz,zzz.99"     NO-UNDO.
DEF    VAR tot_vlcustod   AS DECIMAL   FORMAT "zzz,zzz,zzz,zzz.99"     NO-UNDO.

ASSIGN glb_cdprogra = "crps308"
       glb_cdempres = 11.

RUN fontes/iniprg.p.

IF   glb_cdcritic > 0 THEN
     RETURN.

FORM SKIP 
     "   BANCO    AGENCIA          CONTA        QTD    "
     "           VALOR     LIBERACAO"
     "   -----   ---------    ----------     ------    "
     "    ------------    ----------"
     SKIP
     WITH FRAME f_titulo NO-BOX NO-LABELS PAGE-TOP WIDTH 100.
 
FORM SKIP
     crawcut.cbanco    FORMAT "zz9"          AT 04
     crawcut.cagenc    FORMAT "z,zz9"        AT 13
     crawcut.cconta    FORMAT "zzzzzz,zzz,9" AT 23
     rel_qtcheque      FORMAT "zz9"          AT 41
     aux_vlvalor2      FORMAT "z,zzz,zz9.99" AT 55    
     crawcut.cliber    FORMAT "99/99/9999"   AT 71
     WITH NO-BOX NO-LABELS PAGE-TOP DOWN FRAME f_rel WIDTH 100.
      
FORM "------------"    AT 55
     SKIP
     sub_vlcustod      FORMAT "zzz,zzz,zzz,zz9.99"  AT 49
     SKIP
     WITH NO-BOX DOWN NO-LABEL FRAME f_subtotal WIDTH 100.

FORM SKIP(1)                            
     tot_vlcustod      FORMAT "zzz,zzz,zz9.99"   AT 53 
     "TOTAL CONTA"     AT 70
     SKIP(1)
     WITH NO-BOX NO-LABEL DOWN FRAME f_totalger WIDTH 100.

{ includes/cabrel080_1.i }

OUTPUT STREAM str_1 TO rl/crrl261.lst PAGED PAGE-SIZE 84.

VIEW STREAM str_1 FRAME f_cabrel080_1.
VIEW STREAM str_1 FRAME f_titulo.
  
/* Busca dados da cooperativa */

FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.            
                                                 
IF   NOT AVAILABLE crapcop THEN                  
     DO:                                         
         glb_cdcritic = 651.
         RUN fontes/critic.p.
         UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                           " - " + glb_cdprogra + "' --> '"  +
                           glb_dscritic + " >> log/proc_batch.log").
         QUIT.
     END.

/*  Devera rodar somente para a cooperativa 01  */

IF   crapcop.cdcooper <> 1 THEN
     DO:
        RUN fontes/fimprg.p.
        RETURN.
     END.

/* Devera rodar somente as segundas-feiras ou no primeiro dia util da semana */
IF   WEEKDAY(glb_dtmvtoan) < WEEKDAY(glb_dtmvtolt) THEN
     DO:
         RUN fontes/fimprg.p.
         RETURN.
     END.

ASSIGN  aux_primavez = TRUE
        aux_flgexeok = FALSE
        aux_salvacc1 = 0
        sub_vlcustod = 0
        tot_vlcustod = 0
        rel_qtcheque = 0
        aux_nrsalmes = 0.

/*  Leitura da tabela  */

FIND craptab WHERE craptab.cdcooper = glb_cdcooper  AND
                   craptab.nmsistem = "CRED"        AND
                   craptab.tptabela = "USUARI"      AND
                   craptab.cdempres = 11            AND
                   craptab.cdacesso = "ACOMPCSTOD"  AND
                   craptab.tpregist = 1             NO-LOCK NO-ERROR.

IF   AVAILABLE craptab   THEN
     aux_vlvalor3 = DECIMAL(SUBSTR(craptab.dstextab,1,13)).
ELSE
     aux_vlvalor3 = 0.

FOR EACH crapcst WHERE crapcst.cdcooper = glb_cdcooper  AND
                       crapcst.dtlibera > glb_dtmvtolt  AND 
                       crapcst.dtdevolu = ?             AND 
                       crapcst.nrdconta = 85448         NO-LOCK:

    IF   crapcst.inchqcop = 1   AND   
         crapcst.cdbanchq = 1   THEN
         DO:
              FIND crapfdc WHERE crapfdc.cdcooper = glb_cdcooper     AND
                                 crapfdc.cdbanchq = crapcst.cdbanchq AND
                                 crapfdc.cdagechq = crapcst.cdagechq AND
                                 crapfdc.nrctachq = crapcst.nrctachq AND
                                 crapfdc.nrcheque = crapcst.nrcheque
                                 USE-INDEX crapfdc1 NO-LOCK NO-ERROR.
                                
             IF   NOT AVAILABLE crapfdc  THEN
                  DO:
                      glb_cdcritic = 244.
                      RUN fontes/critic.p.
                      UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + 
                               " - " + glb_cdprogra + "' --> '" + glb_dscritic +
                               "  Conta BB: " + STRING(crapcst.nrctachq) +
                               "  Cheque: " + STRING(crapcst.nrcheque) +
                               " >> log/proc_batch.log").
                      NEXT.
                  END.

             IF   crapfdc.tpcheque <> 1   THEN
                  DO:
                      glb_cdcritic = 513.
                      RUN fontes/critic.p.
                      UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + 
                               " - " + glb_cdprogra + "' --> '" + glb_dscritic +
                               "  Conta BB: " + STRING(crapcst.nrctachq) +
                               "  Cheque: " + STRING(crapcst.nrcheque) + 
                               " >> log/proc_batch.log").
                      NEXT.
                  END.

 
             aux_nrdconta = crapfdc.nrdconta.
         END.
    ELSE     
         aux_nrdconta = crapcst.nrctachq.
         
    CREATE crawcus.
    ASSIGN crawcus.cbanco = crapcst.cdbanchq
           crawcus.cagenc = crapcst.cdagechq
           crawcus.cconta = aux_nrdconta
           crawcus.cvalor = crapcst.vlcheque
           crawcus.cliber = dtlibera.
END.

FOR EACH crawcus NO-LOCK BREAK BY crawcus.cbanco 
                                 BY crawcus.cagenc
                                   BY crawcus.cconta
                                     BY crawcus.cliber:

    IF   aux_dtlibera <> crawcus.cliber   OR    
         aux_cddbanco <> crawcus.cbanco   OR
         aux_cdagenci <> crawcus.cagenc   OR
         aux_nrdconta <> crawcus.cconta   THEN
         IF   aux_nrdconta > 0   THEN
              DO:
                  IF   aux_vlvalor1 > aux_vlvalor3   THEN
                       DO:
                           aux_contador = 0.       
                           IF  aux_salvacc1 <> aux_nrdconta THEN
                               DO: 
                                   RUN lista.
                                   aux_salvacc1 = aux_nrdconta.
                                   IF   aux_flgexeok = FALSE THEN
                                        aux_flgexeok = TRUE.
                               END.
                       END.

                  ASSIGN aux_cddbanco = crawcus.cbanco
                         aux_cdagenci = crawcus.cagenc
                         aux_nrdconta = crawcus.cconta
                         aux_dtlibera = crawcus.cliber
                         aux_nrquante = 0
                         aux_vlvalor1 = 0.
              END.                      
         ELSE
              ASSIGN aux_nrdconta = crawcus.cconta
                     aux_vlvalor1 = 0.

    ASSIGN aux_vlvalor1 = aux_vlvalor1 + crawcus.cvalor
           aux_nrquante = aux_nrquante + 1.

END.   /*    Fim do For each   */

IF  aux_flgexeok THEN
    DO: 
        RUN sistema/generico/procedures/b1wgen0011.p
                                                  PERSISTENT SET b1wgen0011.
                              
        RUN converte_arquivo IN b1wgen0011
                              (INPUT glb_cdcooper,
                               INPUT "rl/crrl261.lst",
                               INPUT "crrl261.doc").

        RUN enviar_email IN b1wgen0011
                              (INPUT glb_cdcooper,
                               INPUT glb_cdprogra,
                               INPUT "adilson@coopermix.com.br",
                               INPUT "ACOMPANHAMENTO DE CUSTODIA DA " + 
                               crapcop.nmrescop,
                               INPUT "crrl261.doc",
                               INPUT false).
                       
        DELETE PROCEDURE b1wgen0011.
     END.
  
OUTPUT STREAM str_1 CLOSE.
            
RUN fontes/fimprg.p.
               
PROCEDURE lista:
   
    ASSIGN aux_contador = 0 
           sub_vlcustod = 0
           tot_vlcustod = 0.
    
    FOR EACH crawcut WHERE crawcut.cbanco = aux_cddbanco    AND
                           crawcut.cagenc = aux_cdagenci    AND
                           crawcut.cconta = aux_nrdconta    NO-LOCK
                           BREAK BY crawcut.cliber:
                         
        ASSIGN rel_qtcheque = rel_qtcheque + 1
               aux_vlvalor2 = aux_vlvalor2 + crawcut.cvalor.

        IF   LAST-OF (crawcut.cliber)   THEN
             DO:           
                  IF   NOT aux_primavez AND
                       (MONTH(crawcut.cliber) <> aux_nrsalmes) THEN
                       DO:
                           IF   aux_contador > 1 THEN
                                DO:
                                    CLEAR FRAME f_subtotal.
                             
                                    DISPLAY STREAM str_1  sub_vlcustod
                                            WITH FRAME f_subtotal.

                                    DOWN STREAM str_1 WITH FRAME f_subtotal.
                                END.
                                     
                           ASSIGN tot_vlcustod = tot_vlcustod + sub_vlcustod
                                  aux_contador = 0
                                  sub_vlcustod = 0.
                                  
                           CLEAR FRAME f_aa.
                            
                           DISPLAY STREAM str_1 SKIP WITH FRAME f_aa.
                                                                
                           DOWN STREAM str_1 WITH FRAME f_aa.
                       END.

                  CLEAR FRAME f_rel.

                  DISPLAY STREAM str_1
                          crawcut.cbanco     crawcut.cagenc 
                          crawcut.cconta     rel_qtcheque
                          aux_vlvalor2       crawcut.cliber
                          WITH FRAME f_rel.

                  DOWN STREAM str_1 WITH FRAME f_rel.

                  aux_contador = aux_contador + 1.
                  
                  ASSIGN sub_vlcustod = sub_vlcustod + aux_vlvalor2
                         aux_nrsalmes = MONTH(crawcut.cliber)
                         aux_primavez = FALSE
                         rel_qtcheque = 0
                         aux_vlvalor2 = 0.
             
                  IF   LINE-COUNTER(str_1) > PAGE-SIZE(str_1)   THEN
                       PAGE STREAM str_1.
             END.
    END.  /*      Fim do For each     */

    IF   aux_contador > 1 THEN
         DO:
             CLEAR FRAME f_subtotal.
                              
             DISPLAY STREAM str_1  sub_vlcustod  WITH FRAME f_subtotal.

             DOWN STREAM str_1 WITH FRAME f_subtotal.
         END.
    
    ASSIGN tot_vlcustod = tot_vlcustod + sub_vlcustod
           sub_vlcustod = 0.
         
    CLEAR FRAME f_totalger.
                           
    DISPLAY STREAM str_1  tot_vlcustod WITH FRAME f_totalger.

    DOWN STREAM str_1 WITH FRAME f_totalger.

END PROCEDURE.
/*............................................................................*/

