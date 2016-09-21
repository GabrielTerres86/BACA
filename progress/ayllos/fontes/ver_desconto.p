/*..............................................................................

   Programa: Fontes/ver_desconto.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : David
   Data    : Setembro/2009                     Ultima atualizacao: 00/00/0000

   Dados referentes ao programa:

   Frequencia: Sempre que chamado por outros programas.
   Objetivo  : Verifica se o cheque com contra-ordem esta em desconto.

   Alteracoes: 

..............................................................................*/

{ includes/var_online.i }

DEF  INPUT PARAM par_nrdconta AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_cdcmpchq LIKE crapfdc.cdcmpchq                    NO-UNDO.
DEF  INPUT PARAM par_nrctachq AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_nrcheque AS INTE                                  NO-UNDO.
DEF OUTPUT PARAM par_cdcritic AS INTE                                  NO-UNDO.

DEF VAR aux_cdpesqui AS CHAR FORMAT "x(50)"                            NO-UNDO.
DEF VAR aux_confirma AS CHAR FORMAT "!"                                NO-UNDO.

FORM SKIP(1)
     crapass.nrdconta LABEL "     Favorecido"
     crapass.nmprimtl NO-LABEL 
     " "     
     SKIP
     crapcdb.dtlibera LABEL " Liberacao para"  
     SKIP
     aux_cdpesqui     LABEL "    Digitado em"
     SKIP(1)
     WITH ROW 10 CENTERED OVERLAY NO-LABELS SIDE-LABELS 
          TITLE " Cheque em Desconto " FRAME f_desconto.
     
ASSIGN par_cdcritic = 0
       par_nrcheque = TRUNCATE(par_nrcheque / 10,0).

FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.

IF  NOT AVAILABLE crapcop  THEN
    DO:
        par_cdcritic = 651.
        RETURN.
    END.

IF  par_nrdconta <> par_nrctachq  THEN
    DO:
        FIND crapcdb WHERE crapcdb.cdcooper = glb_cdcooper AND
                           crapcdb.cdcmpchq = par_cdcmpchq AND
                           crapcdb.cdbanchq = 1            AND
                           crapcdb.cdagechq = 95           AND
                           crapcdb.nrctachq = par_nrctachq AND
                           crapcdb.nrcheque = par_nrcheque AND
                           crapcdb.dtdevolu = ?            NO-LOCK NO-ERROR.
                            
        IF  NOT AVAILABLE crapcdb  THEN
            FIND crapcdb WHERE crapcdb.cdcooper = glb_cdcooper AND
                               crapcdb.cdcmpchq = par_cdcmpchq AND
                               crapcdb.cdbanchq = 1            AND
                               crapcdb.cdagechq = 3420         AND
                               crapcdb.nrctachq = par_nrctachq AND
                               crapcdb.nrcheque = par_nrcheque AND
                               crapcdb.dtdevolu = ?           
                               NO-LOCK NO-ERROR.
                            
        IF  AVAILABLE crapcdb  THEN
            DO:
                FIND crapass WHERE crapass.cdcooper = glb_cdcooper     AND
                                   crapass.nrdconta = crapcdb.nrdconta
                                   NO-LOCK NO-ERROR.
                  
                FIND crapope WHERE crapope.cdcooper = glb_cdcooper     AND
                                   crapope.cdoperad = crapcdb.cdoperad
                                   NO-LOCK NO-ERROR.
                  
                aux_cdpesqui = STRING(crapcdb.dtmvtolt,"99/99/9999") + "-" +
                               STRING(crapcdb.cdagenci,"999") + "-" +
                               STRING(crapcdb.cdbccxlt,"999") + "-" +
                               STRING(crapcdb.nrdolote,"999999") + "-" +
                               ENTRY(1,crapope.nmoperad," ").
                   
                DISPLAY crapass.nrdconta crapass.nmprimtl
                        crapcdb.dtlibera aux_cdpesqui
                        WITH FRAME f_desconto.
            END.
    END.
ELSE
    DO:
        FIND crapcdb WHERE crapcdb.cdcooper = glb_cdcooper     AND
                           crapcdb.cdcmpchq = par_cdcmpchq     AND
                           crapcdb.cdbanchq = 756              AND
                           crapcdb.cdagechq = crapcop.cdagebcb AND
                           crapcdb.nrctachq = par_nrctachq     AND
                           crapcdb.nrcheque = par_nrcheque     AND
                           crapcdb.dtdevolu = ?                NO-LOCK NO-ERROR.
                            
        IF  AVAILABLE crapcdb  THEN
            DO:
                FIND crapass WHERE crapass.cdcooper = glb_cdcooper     AND
                                   crapass.nrdconta = crapcdb.nrdconta 
                                   NO-LOCK NO-ERROR.

                aux_cdpesqui = STRING(crapcdb.dtmvtolt,"99/99/9999") + "-" +
                               STRING(crapcdb.cdagenci,"999") + "-" +
                               STRING(crapcdb.cdbccxlt,"999") + "-" +
                               STRING(crapcdb.nrdolote,"999999") + "-" +
                               crapcdb.cdoperad.
                   
                DISPLAY crapass.nrdconta crapass.nmprimtl
                        crapcdb.dtlibera aux_cdpesqui
                        WITH FRAME f_desconto.
            END.
    END.     

IF  AVAILABLE crapcdb  THEN
    DO:
        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
     
            aux_confirma = "N".
            
            MESSAGE "Aceitar a contra-ordem (S/N)?:" UPDATE aux_confirma.     

            LEAVE.
         
        END.  
     
        IF  KEYFUNCTION(LASTKEY) = "END-ERROR" OR aux_confirma <> "S"  THEN
            par_cdcritic = 811.

        HIDE FRAME f_desconto NO-PAUSE.
    END.

/*............................................................................*/
