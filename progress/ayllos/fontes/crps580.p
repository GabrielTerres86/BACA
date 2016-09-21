/* .............................................................................

   Programa: Fontes/crps580.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Guilherme / Supero
   Data    : Outubro/2010.                   Ultima atualizacao: 14/01/2014
                                                                          
   Dados referentes ao programa:

   Frequencia: Diario (Batch).
   Objetivo  : TAA - Gerar lancamentos financeiros das filiadas na Central
               
   Alteracoes: 19/10/2012 - Incluido include b1wgen0025tt.i (Oscar).
               
               14/01/2014 - Alteracao referente a integracao Progress X 
                            Dataserver Oracle 
                            Inclusao do VALIDATE ( Andre Euzebio / SUPERO) 
............................................................................. */


{ sistema/generico/includes/b1wgen0025tt.i }
{ includes/var_batch.i }


DEF VAR aux_contador AS INT                                          NO-UNDO.
DEF VAR aux_contado2 AS INT                                          NO-UNDO.


DEF VAR aux_vlcheque AS DECI                                         NO-UNDO.
DEF VAR aux_nmarqimp AS CHAR                                         NO-UNDO.
DEF VAR rel_dspesqbb AS CHAR                                         NO-UNDO.
DEF VAR aux_vlchqsup AS DECI                                         NO-UNDO.
DEF VAR aux_flgfirst AS LOGI    INIT TRUE                            NO-UNDO.

DEF VAR aux_cdagenci AS INTE                                         NO-UNDO.
DEF VAR aux_cdbccxlt AS INTE                                         NO-UNDO.
DEF VAR aux_tplotmov AS INTE    INIT 1                               NO-UNDO.
                                                   
DEF VAR aux_nrdocmto AS INTE                                         NO-UNDO.
DEF VAR aux_nrdolote AS INTE                                         NO-UNDO.
DEF VAR aux_nrctadeb AS DECI                                         NO-UNDO.
DEF VAR aux_nrctacre AS DECI                                         NO-UNDO.

DEF BUFFER bcrapcop FOR crapcop.

DEF VAR h-b1wgen0025 AS HANDLE                                       NO-UNDO.

ASSIGN glb_cdprogra = "crps580"
       glb_flgbatch = FALSE.

RUN fontes/iniprg.p.

IF   glb_cdcritic > 0 THEN
     RETURN.
     


/* Instancia a BO */
RUN sistema/generico/procedures/b1wgen0025.p 
    PERSISTENT SET h-b1wgen0025.

IF  NOT VALID-HANDLE (h-b1wgen0025)  THEN
    DO:
        UNIX SILENT VALUE("echo "
                  + STRING(TIME,"HH:MM:SS") + " - "
                  + glb_cdprogra + "' --> '"
                  + "Handle invalido para h-b1wgen0025."
                  + " >> log/proc_batch.log").
        DELETE PROCEDURE h-b1wgen0025.
        RETURN.
    END.

DO TRANSACTION ON ERROR UNDO, RETURN:

    /* Busca dados da cooperativa */
    FOR EACH crapcop WHERE crapcop.cdcooper <> 3 NO-LOCK:

        aux_nrctacre = crapcop.nrctactl.
    
        RUN busca_movto_saque_cooperativa
             IN h-b1wgen0025 ( INPUT 0,    /* Saques de meus Ass. outros TAAs */
                               INPUT crapcop.cdcooper,   /* Saques no meu TAA */
                               INPUT glb_dtmvtolt,
                               INPUT glb_dtmvtolt,
                               INPUT 1,
                              OUTPUT TABLE tt-lancamentos).
    
        /** Cria LCM para a cooperativa processada **/
        RUN pi_cria_lancamentos.
    
    
    END.
END. /* do DO TRANSACTION */

DELETE PROCEDURE h-b1wgen0025.




RUN fontes/fimprg.p.


/*............................................................................*/

PROCEDURE pi_cria_lancamentos:

    DEF VAR tot_vlrtotal            AS DECI                       NO-UNDO.
    DEF VAR tot_vlrtarif            AS DECI                       NO-UNDO.


    FOR EACH tt-lancamentos NO-LOCK
       BREAK BY cdcooper
             BY nrdconta:


        IF FIRST-OF(tt-lancamentos.cdcooper) THEN DO:
            ASSIGN tot_vlrtotal = 0.
            FIND FIRST bcrapcop
                 WHERE bcrapcop.cdcooper = tt-lancamentos.cdcoptfn
                NO-LOCK NO-ERROR.

            IF AVAIL bcrapcop THEN
                aux_nrctacre = bcrapcop.nrctactl.
        END.


        tot_vlrtotal = tot_vlrtotal + tt-lancamentos.vlrtotal.



        IF LAST-OF(tt-lancamentos.cdcooper) THEN DO:
           /**** Cria LCM ****/

            FIND FIRST bcrapcop
                 WHERE bcrapcop.cdcooper = tt-lancamentos.cdcooper
               NO-LOCK NO-ERROR.

            IF AVAIL bcrapcop THEN
                aux_nrctadeb = bcrapcop.nrctactl.


            /*** Lancamento de Debito ***/
            RUN pi_cria_craplcm (INPUT aux_nrctadeb,
                                 INPUT tot_vlrtotal,
                                 INPUT 903,
                                 INPUT aux_nrctacre /* p/ nrdocmto */).

            /*** Lancamento de Credito ***/
            RUN pi_cria_craplcm (INPUT aux_nrctacre,
                                 INPUT tot_vlrtotal,
                                 INPUT 904,
                                 INPUT aux_nrctadeb /* p/ nrdocmto */).

        END.

    END.


END PROCEDURE.

/*............................................................................*/

PROCEDURE pi_cria_craplcm:

   DEF INPUT PARAM par_nrdconta AS INT                       NO-UNDO.
   DEF INPUT PARAM par_vlrlamto AS DEC                       NO-UNDO.
   DEF INPUT PARAM par_cdhistor AS INT                       NO-UNDO.
   DEF INPUT PARAM par_nrdocmto AS INT                       NO-UNDO.

   ASSIGN   aux_nrdolote = 7103
            aux_cdagenci = 1   
            aux_cdbccxlt = 85
            aux_nrdocmto = INT(STRING(par_nrdocmto) + STRING("001")).

   
   IF  aux_flgfirst  THEN 
       DO:
           FIND  craplot WHERE craplot.cdcooper = glb_cdcooper AND
                               craplot.dtmvtolt = glb_dtmvtolt AND 
                               craplot.cdagenci = aux_cdagenci AND
                               craplot.cdbccxlt = aux_cdbccxlt AND
                               craplot.nrdolote = aux_nrdolote
                               USE-INDEX craplot1 NO-LOCK NO-ERROR.
           
           IF  NOT AVAIL craplot THEN
               DO:
                   CREATE craplot.
                   ASSIGN craplot.cdcooper = glb_cdcooper
                          craplot.dtmvtolt = glb_dtmvtolt 
                          craplot.cdagenci = aux_cdagenci
                          craplot.cdbccxlt = aux_cdbccxlt
                          craplot.nrdolote = aux_nrdolote
                          craplot.tplotmov = aux_tplotmov.
                   VALIDATE craplot.
               END.                 

           ASSIGN aux_flgfirst = FALSE.

       END. /* FIM do IF flgfirst */

   FIND craplot WHERE craplot.cdcooper = glb_cdcooper AND
                      craplot.dtmvtolt = glb_dtmvtolt AND 
                      craplot.cdagenci = aux_cdagenci AND
                      craplot.cdbccxlt = aux_cdbccxlt AND
                      craplot.nrdolote = aux_nrdolote
                      USE-INDEX craplot1 EXCLUSIVE-LOCK NO-ERROR.

   DO WHILE TRUE:

     FIND craplcm WHERE craplcm.cdcooper = glb_cdcooper      AND
                        craplcm.dtmvtolt = craplot.dtmvtolt  AND
                        craplcm.cdagenci = craplot.cdagenci  AND
                        craplcm.cdbccxlt = craplot.cdbccxlt  AND
                        craplcm.nrdolote = craplot.nrdolote  AND
                        craplcm.nrdctabb = par_nrdconta      AND  
                        craplcm.nrdocmto = aux_nrdocmto
                        USE-INDEX craplcm1 NO-LOCK NO-ERROR.

     IF   AVAILABLE craplcm THEN
          aux_nrdocmto = (aux_nrdocmto + 1).
     ELSE
          LEAVE.
   END.  /*  Fim do DO WHILE TRUE  */


   CREATE craplcm.
   ASSIGN craplcm.cdcooper = glb_cdcooper
          craplcm.nrdconta = par_nrdconta 
          craplcm.nrdctabb = par_nrdconta 
          craplcm.dtmvtolt = craplot.dtmvtolt
          craplcm.dtrefere = craplot.dtmvtolt
          craplcm.cdagenci = craplot.cdagenci
          craplcm.cdbccxlt = craplot.cdbccxlt
          craplcm.nrdolote = craplot.nrdolote
          craplcm.nrdocmto = aux_nrdocmto
          craplcm.cdhistor = par_cdhistor
          craplcm.vllanmto = par_vlrlamto
          craplcm.nrseqdig = craplot.nrseqdig + 1.
   VALIDATE craplcm.

   ASSIGN craplot.qtinfoln = craplot.qtinfoln + 1
          craplot.qtcompln = craplot.qtcompln + 1
          craplot.nrseqdig = craplcm.nrseqdig.
   
   
   IF CAN-DO("904",STRING(par_cdhistor))  THEN
      ASSIGN craplot.vlinfocr = craplot.vlinfocr + craplcm.vllanmto
             craplot.vlcompcr = craplot.vlcompcr + craplcm.vllanmto.
   ELSE
      ASSIGN craplot.vlinfodb = craplot.vlinfodb + craplcm.vllanmto
             craplot.vlcompdb = craplot.vlcompdb + craplcm.vllanmto.
  
END PROCEDURE.

/*............................................................................*/

