/* .............................................................................

   Programa: Fontes/ver_custodia.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Edson
   Data    : Junho/2003.                     Ultima atualizacao: 20/08/2008

   Dados referentes ao programa:

   Frequencia: Sempre que chamado por outros programas.
   Objetivo  : Verifica se ha custodia para o cheque com contra-ordem (Edson).

   Alteracoes: 28/09/2005 - Modificado FIND FIRST para FIND na tabela 
                            crapcop.cdcooper = glb_cdcooper (Diego).
                            
               26/01/2006 - Unificacao dos Bancos - SQLWorks - Andre

               20/08/2008 - Tratar praca de compensacao (Magui).
............................................................................. */

{ includes/var_online.i }

DEF INPUT  PARAM par_nrdconta AS INT                                 NO-UNDO.
DEF INPUT  PARAM par_cdcmpchq LIKE crapfdc.cdcmpchq                  NO-UNDO.
DEF INPUT  PARAM par_nrdctabb AS INT                                 NO-UNDO.
DEF INPUT  PARAM par_nrcheque AS INT                                 NO-UNDO.
DEF OUTPUT PARAM par_cdcritic AS INT                                 NO-UNDO.

DEF VAR aux_cdpesqui AS CHAR FORMAT "x(50)"                          NO-UNDO.
DEF VAR aux_confirma AS CHAR FORMAT "!"                              NO-UNDO.

FORM SKIP(1)
     crapass.nrdconta LABEL "     Favorecido"
     crapass.nmprimtl NO-LABEL " "     SKIP
     crapcst.dtlibera LABEL " Liberacao para"  SKIP
     aux_cdpesqui     LABEL "    Digitado em"
     SKIP(1)
     WITH ROW 10 CENTERED OVERLAY NO-LABELS SIDE-LABELS 
          TITLE " Cheque em custodia " FRAME f_custodia.
     
par_cdcritic = 0.
par_nrcheque = TRUNC(par_nrcheque / 10,0).

FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.

IF   NOT AVAILABLE crapcop   THEN
     DO:
         par_cdcritic = 651.
         RETURN.
     END.

IF   par_nrdconta <> par_nrdctabb   THEN
     DO:
         FIND crapcst WHERE crapcst.cdcooper = glb_cdcooper   AND
                            crapcst.cdcmpchq = par_cdcmpchq   AND
                            crapcst.cdbanchq = 1              AND
                            crapcst.cdagechq = 95             AND
                            crapcst.nrctachq = par_nrdctabb   AND
                            crapcst.nrcheque = par_nrcheque   AND
                            crapcst.dtdevolu = ?              NO-LOCK NO-ERROR.
                            
         IF   NOT AVAILABLE crapcst   THEN
              FIND crapcst WHERE crapcst.cdcooper = glb_cdcooper   AND
                                 crapcst.cdcmpchq = par_cdcmpchq   AND
                                 crapcst.cdbanchq = 1              AND
                                 crapcst.cdagechq = 3420           AND
                                 crapcst.nrctachq = par_nrdctabb   AND
                                 crapcst.nrcheque = par_nrcheque   AND
                                 crapcst.dtdevolu = ?           
                                 NO-LOCK NO-ERROR.
                            
         IF   AVAILABLE crapcst   THEN
              DO:
                  /*FIND crapass OF crapcst NO-LOCK NO-ERROR.*/
                  FIND crapass WHERE crapass.cdcooper = glb_cdcooper     AND
                                     crapass.nrdconta = crapcst.nrdconta
                                     NO-LOCK NO-ERROR.
                  
                  /*FIND crapope OF crapcst NO-LOCK NO-ERROR.*/
                  FIND crapope WHERE crapope.cdcooper = glb_cdcooper     AND
                                     crapope.cdoperad = crapcst.cdoperad
                                     NO-LOCK NO-ERROR.
                  

                  aux_cdpesqui = STRING(crapcst.dtmvtolt,"99/99/9999") + "-" +
                                 STRING(crapcst.cdagenci,"999") + "-" +
                                 STRING(crapcst.cdbccxlt,"999") + "-" +
                                 STRING(crapcst.nrdolote,"999999") + "-" +
                                 ENTRY(1,crapope.nmoperad," ").
                   
                  DISPLAY crapass.nrdconta crapass.nmprimtl
                          crapcst.dtlibera aux_cdpesqui
                          WITH FRAME f_custodia.
              END.
     END.
ELSE
     DO:
         FIND crapcst WHERE crapcst.cdcooper = glb_cdcooper       AND
                            crapcst.cdcmpchq = par_cdcmpchq       AND
                            crapcst.cdbanchq = 756                AND
                            crapcst.cdagechq = crapcop.cdagebcb   AND
                            crapcst.nrctachq = par_nrdctabb       AND
                            crapcst.nrcheque = par_nrcheque       AND
                            crapcst.dtdevolu = ?                 
                            NO-LOCK NO-ERROR.
                            
         IF   AVAILABLE crapcst   THEN
              DO:
                  /*FIND crapass OF crapcst NO-LOCK NO-ERROR.*/
                  FIND crapass WHERE crapass.cdcooper = glb_cdcooper     AND
                                     crapass.nrdconta = crapcst.nrdconta 
                                     NO-LOCK NO-ERROR.

                  aux_cdpesqui = STRING(crapcst.dtmvtolt,"99/99/9999") + "-" +
                                 STRING(crapcst.cdagenci,"999") + "-" +
                                 STRING(crapcst.cdbccxlt,"999") + "-" +
                                 STRING(crapcst.nrdolote,"999999") + "-" +
                                 crapcst.cdoperad.
                   
                  DISPLAY crapass.nrdconta crapass.nmprimtl
                          crapcst.dtlibera aux_cdpesqui
                          WITH FRAME f_custodia.
              END.
     END.     

IF   AVAILABLE crapcst   THEN
     DO:
         DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
     
            aux_confirma = "N".
            
            MESSAGE "Aceitar a contra-ordem (S/N)?:" UPDATE aux_confirma.     

            LEAVE.
         
         END.  /*  Fim do DO WHILE TRUE  */
     
         IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   OR
              aux_confirma <> "S"                  THEN
              par_cdcritic = 757.

         HIDE FRAME f_custodia NO-PAUSE.
     END.

/* .......................................................................... */


