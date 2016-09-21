/* .............................................................................

   Programa: Fontes/captal.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Julho/92.                       Ultima atualizacao: 28/08/2013

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela CAPTAL.

   Alteracoes: 09/09/94 - Alterado valor da moeda para 8 casas decimais
                          (Deborah).

               10/03/95 - Alterado para remover a utilizacao da rotina
                          includes/lelct.i (Edson).

               22/03/95 - Alterado para nao mostrar o capital em moeda fixa
                          (Deborah)

               26/03/98 - Tratamento para milenio e troca para V8 (Margarete).
               
               31/01/2005 - Modificados os termos "Agencia" ou "Ag" por "PAC"
                            (Evandro).

               25/01/2006 - Unificacao dos Bancos - SQLWorks - Fernando
               
               02/10/2006 - Retirar campo nivel (Magui).
               
               02/10/2006 - Alterado help do campo "Conta/dv" (Elton).
               
               09/02/2007 - Exclusao do campo tel_vlcmecot (Diego).
               
               07/04/2008 - Alterado o formato da variável "tel_qtprepag" para "zz9" 
                          - Kbase IT Solutions - Paulo Ricardo Maciel.
                          
               03/06/2013 - Busca Saldo Bloqueio Judicial
                            (Andre Santos - SUPERO)
               
               28/08/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).
............................................................................. */

{ includes/var_online.i }

DEF        VAR tel_nrdconta AS INT     FORMAT "zzzz,zzz,9"           NO-UNDO.
DEF        VAR tel_aarefere AS INT     FORMAT "zzz9"                 NO-UNDO.

DEF        VAR tel_vldcotas AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99-"  NO-UNDO.
DEF        VAR tel_vlcmicot AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99-"  NO-UNDO.

DEF        VAR tel_vlmoefix AS DECIMAL FORMAT "zzzzz,zz9.99999999"   NO-UNDO.
DEF        VAR tel_vlcaptal AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99-"  NO-UNDO.
DEF        VAR tel_qtcotmfx AS DECIMAL FORMAT "zzzz,zzz,zz9.9999-"   NO-UNDO.

DEF        VAR tel_nrctrpla AS INT     FORMAT "zzz,zzz"              NO-UNDO.
DEF        VAR tel_qtprepag AS INT     FORMAT "zz9"                  NO-UNDO.
DEF        VAR tel_vlprepla AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99"   NO-UNDO.
DEF        VAR tel_dtinipla AS DATE    FORMAT "99/99/9999"           NO-UNDO.

DEF        VAR tel_dsmoefix AS CHAR    FORMAT "x(20)" INIT "UFIR"    NO-UNDO.

DEF        VAR aux_qtcotmfx AS DECIMAL                               NO-UNDO.
DEF        VAR aux_vldcotas AS DECIMAL                               NO-UNDO.
DEF        VAR aux_vlcmecot AS DECIMAL                               NO-UNDO.
DEF        VAR aux_vlcmicot AS DECIMAL                               NO-UNDO.
DEF        VAR aux_vlcmmcot AS DECIMAL                               NO-UNDO.
DEF        VAR aux_vllanmfx AS DECIMAL                               NO-UNDO.

DEF        VAR aux_dtrefcot AS DATE    FORMAT "99/99/9999"           NO-UNDO.

DEF        VAR aux_nrdconta AS INT                                   NO-UNDO.
DEF        VAR aux_stimeout AS INT                                   NO-UNDO.
DEF        VAR aux_cddopcao AS CHAR                                  NO-UNDO.

DEF        VAR aux_flgerros AS LOGICAL                               NO-UNDO.
DEF        VAR aux_flgdodia AS LOGICAL INIT TRUE  /* MFX do dia */   NO-UNDO.

DEF        VAR tel_vlblqjud AS DECI FORMAT "zzz,zzz,zzz,zz9.99"      NO-UNDO.
DEF        VAR aux_vlblqjud AS DECI FORMAT "zzzzz,zz9.99"            NO-UNDO.
DEF        VAR aux_vlresblq AS DECI FORMAT "zzz,zzz,zzz,zz9.99"      NO-UNDO.

DEF VAR h-b1wgen0155 AS HANDLE                                       NO-UNDO.

FORM SKIP(1)
     tel_nrdconta     AT  2 LABEL "Conta/dv" AUTO-RETURN
                            HELP "Informe o numero da conta."
     crapass.nrmatric AT 25 LABEL "Matricula"
     crapass.cdagenci AT 47 LABEL "PA"
     crapass.dtadmiss AT 55 LABEL "Admitido em" FORMAT "99/99/9999"
     SKIP(1)
     crapass.nmprimtl AT  4 LABEL "Titular"
     SKIP(1)
     tel_vlcaptal     AT  4 LABEL "Total do Capital"
  /* tel_qtcotmfx     AT 44 LABEL "Capital em MFX" */
     tel_vlblqjud     AT  44 LABEL "Valor Bloq Jud"  
     SKIP(1)
     tel_vldcotas     AT  5 LABEL "Valor das Cotas"
     "Dados referente a " AT 47
     tel_aarefere     AT 65 NO-LABEL
     "em MFX:"        AT 70
     SKIP
     crapcot.qtraimfx AT 47 LABEL "Juros Pagos"
     SKIP
     crapcot.qtsanmfx AT 47 LABEL "Saldo Medio"
     SKIP
     tel_vlcmicot     AT  6 LABEL "C.M. Acumulada"
     SKIP(1)
     "Plano"          AT  3
     tel_nrctrpla     AT  9 NO-LABEL
     tel_vlprepla     AT 18 LABEL "Vl"
     tel_qtprepag     AT 41 LABEL "Prest. Pagas"
     tel_dtinipla     AT 60 LABEL "Inicio"
     SKIP(1)
     tel_vlmoefix     AT  3 LABEL "Moeda Fixa: Valor"
     tel_dsmoefix     AT 44 LABEL "Descricao"
     SKIP(1)
     WITH ROW 4 OVERLAY WIDTH 80 SIDE-LABELS TITLE glb_tldatela FRAME f_captal.

ASSIGN glb_cddopcao = "C"
       glb_cdcritic = 0
       tel_aarefere = YEAR(glb_dtmvtolt) - 1
       aux_dtrefcot = DATE(MONTH(glb_dtmvtolt),01,YEAR(glb_dtmvtolt)).

DISPLAY tel_aarefere WITH FRAME f_captal.

DO WHILE TRUE:

   RUN fontes/inicia.p.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      UPDATE tel_nrdconta WITH FRAME f_captal

      EDITING:

         aux_stimeout = 0.

         DO WHILE TRUE:

            READKEY PAUSE 1.

            IF   LASTKEY = -1   THEN
                 DO:
                     aux_stimeout = aux_stimeout + 1.

                     IF   aux_stimeout > glb_stimeout   THEN
                          QUIT.

                     NEXT.
                 END.

            APPLY LASTKEY.

            LEAVE.

         END.  /*  Fim do DO WHILE TRUE  */

      END.  /*  Fim do EDITING  */

      FIND crapmfx WHERE crapmfx.cdcooper = glb_cdcooper   AND 
                         crapmfx.dtmvtolt = glb_dtmvtolt   AND
                         crapmfx.tpmoefix = 2 NO-LOCK NO-ERROR.

      IF   NOT AVAILABLE crapmfx   THEN
           DO:
               glb_cdcritic = 140.
               RUN fontes/critic.p.
               BELL.
               MESSAGE glb_dscritic + ": " + tel_dsmoefix.
               CLEAR FRAME f_captal NO-PAUSE.
               DISPLAY tel_nrdconta WITH FRAME f_captal.
               NEXT.
           END.

      LEAVE.

   END.

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN    /*   F4 OU FIM   */
        DO:
            RUN fontes/novatela.p.
            IF   glb_nmdatela <> "CAPTAL"   THEN
                 DO:
                     HIDE FRAME f_captal.
                     RETURN.
                 END.
            ELSE
                 NEXT.
        END.

    IF   aux_cddopcao <> glb_cddopcao   THEN
         DO:
             { includes/acesso.i}
             aux_cddopcao = glb_cddopcao.
         END.

    ASSIGN aux_nrdconta = tel_nrdconta
           glb_nrcalcul = tel_nrdconta
           glb_cdcritic = 0.

    RUN fontes/digfun.p.
    IF   NOT glb_stsnrcal   THEN
         DO:
             glb_cdcritic = 8.
             RUN fontes/critic.p.
             BELL.
             MESSAGE glb_dscritic.
             CLEAR FRAME f_captal NO-PAUSE.
             DISPLAY tel_nrdconta WITH FRAME f_captal.
             NEXT.
         END.

    FIND crapass WHERE crapass.cdcooper = glb_cdcooper AND
                       crapass.nrdconta = tel_nrdconta NO-LOCK NO-ERROR.

    IF   NOT AVAILABLE crapass   THEN
         DO:
             glb_cdcritic = 9.
             RUN fontes/critic.p.
             BELL.
             MESSAGE glb_dscritic.
             CLEAR FRAME f_captal.
             DISPLAY tel_nrdconta WITH FRAME f_captal.
             NEXT.
         END.

    FIND crapcot WHERE crapcot.cdcooper = glb_cdcooper     AND
                       crapcot.nrdconta = crapass.nrdconta NO-LOCK NO-ERROR.

    IF   NOT AVAILABLE crapcot   THEN
         DO:
             glb_cdcritic = 169.
             RUN fontes/critic.p.
             BELL.
             MESSAGE glb_dscritic.
             NEXT.
         END.

    /*          fora de uso desde 10/03/95  - Edson

    ASSIGN aux_qtcotmfx = crapcot.qtcotmfx
           aux_vldcotas = crapcot.vldcotas
           aux_vlcmicot = crapcot.vlcmicot.

    { includes/lelct.i }   /* Rotina de calculo do capital */

    IF   glb_cdcritic > 0   THEN
         DO:
             RUN fontes/critic.p.
             BELL.
             MESSAGE glb_dscritic.
             CLEAR FRAME f_captal.
             DISPLAY tel_nrdconta WITH FRAME f_captal.
             NEXT.
         END.
    */

    ASSIGN tel_vldcotas = crapcot.vldcotas
           tel_vlcmicot = crapcot.vlcmicot
           tel_qtprepag = crapcot.qtprpgpl
        /* tel_qtcotmfx = ROUND(crapcot.vldcotas / crapmfx.vlmoefix,4) */

           tel_vlcaptal = tel_vldcotas

           tel_vlmoefix = crapmfx.vlmoefix.

    FIND FIRST crappla WHERE crappla.cdcooper = glb_cdcooper   AND
                             crappla.nrdconta = tel_nrdconta   AND
                             crappla.tpdplano = 1              AND
                             crappla.cdsitpla = 1
                             USE-INDEX crappla3 NO-LOCK NO-ERROR.

    IF   NOT AVAILABLE crappla   THEN
         ASSIGN tel_nrctrpla = 0
                tel_vlprepla = 0
                tel_dtinipla = ?.
    ELSE
         ASSIGN tel_nrctrpla = crappla.nrctrpla
                tel_vlprepla = crappla.vlprepla
                tel_dtinipla = crappla.dtinipla.

    
    /*** Busca Saldo Bloqueio Judicial ***/
    ASSIGN aux_vlblqjud = 0
           aux_vlresblq = 0.

    RUN sistema/generico/procedures/b1wgen0155.p 
                   PERSISTENT SET h-b1wgen0155.

    RUN retorna-valor-blqjud IN h-b1wgen0155(INPUT glb_cdcooper,
                                             INPUT tel_nrdconta,
                                             INPUT 0, /* fixo - nrcpfcgc */
                                             INPUT 3, /* Bloq. Capital   */
                                             INPUT 4, /* 4 - CAPITAL     */
                                             INPUT glb_dtmvtolt,
                                             OUTPUT aux_vlblqjud,
                                             OUTPUT aux_vlresblq).

    tel_vlblqjud = aux_vlblqjud.

    DELETE PROCEDURE h-b1wgen0155.
    /*** Fim Busca Saldo Bloqueado Judicial ***/


    DISPLAY tel_nrdconta      crapass.nrmatric  crapass.cdagenci
            crapass.dtadmiss  crapass.nmprimtl  
            tel_vlcaptal      tel_vldcotas      tel_vlblqjud /* tel_qtcotmfx */
            tel_aarefere      tel_vlcmicot      crapcot.qtraimfx
            crapcot.qtsanmfx  tel_nrctrpla      tel_vlprepla
            tel_qtprepag      tel_dtinipla      tel_vlmoefix
            tel_dsmoefix
            WITH FRAME f_captal.

    RELEASE crapass.
    RELEASE crapcot.
    RELEASE crappla.

END.

/* .......................................................................... */
