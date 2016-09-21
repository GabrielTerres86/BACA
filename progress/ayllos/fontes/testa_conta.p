/* .............................................................................

   Programa: Fontes/testa_conta.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Edson
   Data    : Maio/2003.                          Ultima atualizacao: 23/08/2006

   Dados referentes ao programa:

   Frequencia: Sempre que chamado por outros programas.
   Objetivo  : Verificar a transf. de valores entre contas (Edson).
   
   Alteracoes: 27/01/2006 - Unificacao dos Bancos - SQLWorks - Andre
   
               13/02/2006 - Inclusao do parametro par_cdcooper para unificacao
                            dos bancos de dados - SQLWorks - Andre

               23/08/2006 - Criticar conta eliminada(Mirtes)
............................................................................. */

DEF INPUT  PARAM par_cdcooper AS INT                                 NO-UNDO.
DEF INPUT  PARAM par_nrdconta AS INT                                 NO-UNDO.
DEF INPUT  PARAM par_nrctatrf AS INT                                 NO-UNDO.
DEF INPUT  PARAM par_cdhistor AS INT                                 NO-UNDO.
DEF OUTPUT PARAM par_cdcritic AS INT                                 NO-UNDO.

DEF BUFFER crabass FOR crapass.

DEF SHARED VAR glb_nrcalcul AS DECIMAL FORMAT ">>>>>>>>>>>>>9"       NO-UNDO.
DEF SHARED VAR glb_stsnrcal AS LOGICAL                               NO-UNDO.

DEF        VAR pri_nrcpfcgc AS DECIMAL                               NO-UNDO.
DEF        VAR seg_nrcpfcgc AS DECIMAL                               NO-UNDO.

par_cdcritic = 0.

/*  Verifica conta favorecida ............................................... */

glb_nrcalcul = par_nrctatrf.

RUN fontes/digfun.p.

IF   NOT glb_stsnrcal   THEN
     DO:
         par_cdcritic = 8.
         RETURN.
     END.

FIND crabass WHERE crabass.cdcooper = par_cdcooper AND
                   crabass.nrdconta = par_nrctatrf NO-LOCK NO-ERROR.

IF   NOT AVAILABLE crabass   THEN
     DO:
         par_cdcritic = 9.
         RETURN.
     END.

IF  crabass.dtelimin <> ? THEN
    DO:
       par_cdcritic = 410.
       RETURN.
    END.   

/*  Testa TITULARIDADE ...................................................... */

IF   par_cdhistor <> 104   THEN
     RETURN.

FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                   crapass.nrdconta = par_nrdconta NO-LOCK NO-ERROR.

IF   NOT AVAILABLE crapass   THEN
     DO:
         par_cdcritic = 9.
         RETURN.
     END.
                                                                     
IF   CAN-DO("2,3",STRING(crapass.inpessoa))   AND
     CAN-DO("2,3",STRING(crabass.inpessoa))   THEN
     DO:
         ASSIGN pri_nrcpfcgc = DECIMAL(SUBSTR(STRING
                                      (crapass.nrcpfcgc,"99999999999999"),1,8))
                
                seg_nrcpfcgc = DECIMAL(SUBSTR(STRING
                                      (crabass.nrcpfcgc,"99999999999999"),1,8)).
                                  
         IF   pri_nrcpfcgc <> seg_nrcpfcgc   THEN
              par_cdcritic = 755.
     END.
ELSE
     DO:
         IF   crapass.nrcpfcgc = crabass.nrcpfcgc   AND
              crapass.nrcpfstl = crabass.nrcpfstl   THEN.
         ELSE
         IF   crapass.nrcpfstl = crabass.nrcpfcgc   AND     
              crapass.nrcpfcgc = crabass.nrcpfstl   THEN.
         ELSE
         IF   crapass.nrcpfcgc = crabass.nrcpfcgc   AND
              crabass.nrcpfstl = 0                  THEN.
         ELSE
         IF   crapass.nrcpfstl = crabass.nrcpfcgc   AND
              crabass.nrcpfstl = 0                  THEN.
         ELSE
              par_cdcritic = 755.
     END.

/* .......................................................................... */

