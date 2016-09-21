/* .............................................................................

   Programa: Fontes/sldcor.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Janeiro/97.                     Ultima atualizacao: 08/12/2011

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Rotina para totalizar a quantidade de contra-ordens do associado
               e mostra-las em tela.

   Alteracoes: 16/04/98 - Tratamento para milenio e troca para V8 (Margarete).

               10/11/2005 - Tratar o campo cdcooper na leitura da tabela
                            crapcor (Edson).

               09/05/2006 - Alterado tamanho do form (Magui).

               30/01/2007 - Mostrar campo crapcor.dtmvtolt no form (David).
               
               05/03/2007 - Ajustes para o Bancoob (Magui).

               18/12/2007 - Incluido campo OPE (Gabriel).

               13/05/2008 - Ajuste comando FIND(craphis) utilizava FOR p/ acesso
                            (Sidnei - Precise)

               25/05/2009 - Alteracao CDOPERAD (Kbase).
               
               23/11/2009 - Alteracao Codigo Historico (Kbase).
               
               08/12/2011 - Sustação provisória (André R./Supero).
               
............................................................................. */

{ includes/var_online.i }

{ includes/var_atenda.i }

DEF INPUT  PARAM par_flgextra AS LOGICAL                             NO-UNDO.

DEF VAR tel_dshistor AS CHAR    FORMAT "x(40)"                       NO-UNDO.

DEF VAR aux_regexist AS LOGICAL                                      NO-UNDO.
DEF VAR aux_flgretor AS LOGICAL                                      NO-UNDO.

FORM crapcor.cdbanchq LABEL "Bco"       FORMAT "zz9"
     crapcor.cdagechq LABEL "Age"       FORMAT "zzz9"
     crapcor.nrctachq LABEL "Cta.Chq"   FORMAT "zzzz,zzz,9" 
     crapcor.cdoperad LABEL "OPE"       FORMAT "x(10)"
     crapcor.nrcheque LABEL "Cheque"
     crapcor.dtemscor LABEL "Emissao"   FORMAT "99/99/99"
     crapcor.dtmvtolt LABEL "Inclusao"  FORMAT "99/99/99"  
     craphis.dshistor LABEL "Historico" FORMAT "x(17)"
     WITH ROW 9 OVERLAY 9 DOWN CENTERED COLUMN 2 WIDTH 80
          TITLE " Contra-Ordens nos Cheques " NO-LABELS FRAME f_contra.

ASSIGN glb_cdcritic = 0
       aux_qtctrord = 0
       aux_contador = 0.

FOR EACH crapcor WHERE crapcor.cdcooper = glb_cdcooper   AND
                       crapcor.nrdconta = tel_nrdconta   AND 
                       crapcor.flgativo = TRUE           NO-LOCK:

    aux_qtctrord = aux_qtctrord + 1.

    IF   NOT par_flgextra   THEN
         NEXT.

    ASSIGN aux_regexist = TRUE
           aux_contador = aux_contador + 1.

    IF   aux_contador = 1 THEN
         IF   aux_flgretor  THEN
              DO:
                  PAUSE MESSAGE
                        "Tecle <Entra> para continuar ou <Fim> para encerrar".
                  CLEAR FRAME f_contra ALL NO-PAUSE.
              END.
         ELSE
              aux_flgretor = TRUE.

    FIND craphis NO-LOCK WHERE craphis.cdcooper = crapcor.cdcooper AND 
                               craphis.cdhistor = crapcor.cdhistor NO-ERROR.

    IF   NOT AVAILABLE craphis   THEN
         tel_dshistor = STRING(crapcor.cdhistor).
    ELSE
         tel_dshistor = STRING(craphis.cdhistor,"9999") + "-" +
                        craphis.dshistor.

    PAUSE(0).

    DISPLAY crapcor.cdbanchq crapcor.cdagechq crapcor.nrctachq
            crapcor.cdoperad crapcor.nrcheque crapcor.dtemscor 
            crapcor.dtmvtolt tel_dshistor @ craphis.dshistor
            WITH FRAME f_contra.

    IF   aux_contador = 9   THEN
         aux_contador = 0.
    ELSE
         DOWN WITH FRAME f_contra.

END.  /*  Fim do FOR EACH  --  crapcor  */

IF   glb_cdcritic > 0   OR   NOT par_flgextra   THEN
     DO:
         HIDE FRAME f_contra NO-PAUSE.
         RETURN.
     END.

IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN    /*   F4 OU FIM   */
     DO:
         HIDE FRAME f_contra NO-PAUSE.
         RETURN.
     END.

IF   aux_contador <= 9   THEN
     DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

        PAUSE MESSAGE "Tecle <Fim> para encerrar".
        LEAVE.

     END.  /*  Fim do DO WHILE TRUE  */

HIDE FRAME f_contra NO-PAUSE.

/* .......................................................................... */

