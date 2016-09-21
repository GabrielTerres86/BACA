/* .............................................................................

   Programa: Fontes/aliena.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Marco/97.                           Ultima atualizacao: 20/01/2015

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela ALIENA -- Manutencao dos comprovantes das
               alienacoes fiduciarias.

   Alteracoes: 24/06/1999 - Alterado para tratar a data de vencimento do
                            seguro do bem alienado (Edson).

               26/06/2002 - Criar opcao S para regularizar somente o seguro
                            (Deborah).

               15/08/2002 - Nao permitir alterar seguro se nao e neces
                            sario (Margarete).

               14/06/2004 - Incluido campo LIB.SEG (Evandro).

               07/10/2005 - Acrescentado campo "Registro" na tela (Diego).

               25/01/2006 - Unificacao dos Bancos - SQLWorks - Luciane.

               06/03/2009 - Criado log/aliena.log (Gabriel).

               17/09/2010 - Alterada a estrutura dos bens para a crapbpr
                            (Gabriel).

               13/01/2011 - Alterado format do campo tel_nmprimtl para x(50)
                            (Henrique).

               24/08/2011 - Adaptado para uso de BO (Gabriel Capoia - DB1).

               21/11/2013 - Novos campos GRAVAMES em tela (Guilherme/SUPERO)
               
               20/01/2015 - Alterado o formato do campo nrctremp para 8 
                            caracters (Kelvin - 233714)

............................................................................. */

{ sistema/generico/includes/b1wgen0102tt.i }
{ sistema/generico/includes/var_internet.i }
{ includes/var_online.i }

DEF VAR tel_nrdconta AS INTE FORMAT "zzzz,zzz,9"                      NO-UNDO.
DEF VAR tel_nrctremp AS INTE FORMAT "zz,zzz,zz9"                       NO-UNDO.
DEF VAR tel_nmprimtl AS CHAR FORMAT "x(50)"                           NO-UNDO.
DEF VAR tel_dtmvtolt AS DATE FORMAT "99/99/9999"                      NO-UNDO.

DEF VAR tel_dsaliena AS CHAR FORMAT "x(28)"                           NO-UNDO.
DEF VAR tel_dtatugrv AS DATE FORMAT "99/99/99"                        NO-UNDO.
DEF VAR tel_tpinclus AS CHAR FORMAT "x(1)"                            NO-UNDO.
DEF VAR tel_flgalfid AS LOGI FORMAT "Ok/Pend."                        NO-UNDO.
DEF VAR tel_dtvigseg AS DATE FORMAT "99/99/99"                        NO-UNDO.
DEF VAR tel_flglbseg AS LOGI FORMAT "Sim/Nao"                         NO-UNDO.
DEF VAR tel_flgrgcar AS LOGI FORMAT "Sim/Nao"                         NO-UNDO.

DEF VAR aux_cdsitgrv AS INTE                                          NO-UNDO.
DEF VAR aux_contareg AS INTE                                          NO-UNDO.
DEF VAR aux_flgretor AS LOGI                                          NO-UNDO.
DEF VAR aux_contador AS INTE FORMAT "99"                              NO-UNDO.
DEF VAR aux_stimeout AS INTE                                          NO-UNDO.
DEF VAR aux_cddopcao AS CHAR                                          NO-UNDO.
DEF VAR aux_confirma AS CHAR FORMAT "!"                               NO-UNDO.

DEF VAR aux_nrdconta AS INTE  FORMAT "zzzz,zzz,9"                     NO-UNDO.
DEF VAR aux_nrctremp AS INTE                                          NO-UNDO.
DEF VAR h-b1wgen0102 AS HANDLE                                        NO-UNDO.


FORM SKIP(1)
     glb_cddopcao AT  6 LABEL "Opcao" FORMAT "!"
                        HELP "Opcoes: Alteracao, Consulta, Seguro."
     tel_nmprimtl AT 19 LABEL "Titular"
     SKIP(1)
     tel_nrdconta AT  3 LABEL "Conta/dv" AUTO-RETURN
                        HELP "Informe o numero da conta ou <F7> para pesquisar."
     tel_nrctremp AT 26 LABEL "Contrato" AUTO-RETURN
                        HELP "Informe o numero do contrato ou F7 para listar."
     tel_dtmvtolt AT 48 LABEL "Data" FORMAT "99/99/9999"

     SKIP(1)
     " BEM FINANCIADO / GARANTIA        ALIEN. DT ALIEN. REG. VENC.SEG. L.SEG R.CART"
     SKIP (10)
     WITH ROW 4 SIDE-LABELS OVERLAY TITLE glb_tldatela WIDTH 80 FRAME f_aliena.

FORM tel_dsaliena AT 02
     tel_flgalfid AT 35
         HELP "Entre com (O)k ou (P)endente para atualizar."
     tel_dtatugrv AT 42
     tel_tpinclus AT 53
     tel_dtvigseg AT 57
         HELP "Entre com a data de vencimento do seguro."
     tel_flglbseg AT 68
         HELP "Entre com (S)im ou (N)ao para atualizar."
     tel_flgrgcar AT 74
         HELP "Entre com (S)im ou (N)ao para atualizar."
     WITH CENTERED WIDTH 78 7 DOWN NO-BOX ROW 12 NO-LABELS OVERLAY FRAME f_aliena_2.


RUN fontes/inicia.p.

ASSIGN glb_cddopcao = "C"
       glb_cdcritic = 0.

INICIO:
DO WHILE TRUE:

   IF  NOT VALID-HANDLE(h-b1wgen0102) THEN
       RUN sistema/generico/procedures/b1wgen0102.p
           PERSISTENT SET h-b1wgen0102.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      NEXT-PROMPT tel_nrdconta WITH FRAME f_aliena.

      UPDATE glb_cddopcao tel_nrdconta tel_nrctremp WITH FRAME f_aliena
      EDITING:
          READKEY /* PAUSE 1 */ .
            IF LASTKEY = KEYCODE("F7")  THEN
                DO:
                    IF  FRAME-FIELD = "tel_nrdconta" THEN
                        DO:
                            RUN fontes/zoom_associados.p (INPUT  glb_cdcooper,
                                                          OUTPUT aux_nrdconta).

                            IF  aux_nrdconta > 0   THEN
                                DO:
                                    ASSIGN tel_nrdconta = aux_nrdconta.
                                    DISPLAY tel_nrdconta WITH FRAME f_aliena.
                                    PAUSE 0.
                                    APPLY "RETURN".
                                END.
                        END.
                    ELSE
                        IF  FRAME-FIELD = "tel_nrctremp" THEN
                            DO:
                                RUN fontes/zoom_emprestimos.p
                                    ( INPUT glb_cdcooper,
                                      INPUT 0,
                                      INPUT 0,
                                      INPUT glb_cdoperad,
                                      INPUT INPUT tel_nrdconta,
                                      INPUT glb_dtmvtolt,
                                      INPUT glb_dtmvtopr,
                                      INPUT glb_inproces,
                                     OUTPUT aux_nrctremp ).

                                IF  aux_nrctremp > 0   THEN
                                    DO:
                                        ASSIGN tel_nrctremp = aux_nrctremp.
                                        DISPLAY tel_nrctremp WITH FRAME f_aliena.
                                        PAUSE 0.
                                        APPLY "RETURN".
                                    END.
                            END.

                    END.
                ELSE
                    APPLY LASTKEY.


      END.  /*  Fim do EDITING  */

      RUN Busca_Dados.

      IF  RETURN-VALUE <> "OK" THEN
          NEXT.

      LEAVE.

   END.  /*  Fim do DO WHILE TRUE  */

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN    /*   F4 OU FIM   */
        DO:
            RUN fontes/novatela.p.
            IF   glb_nmdatela <> "ALIENA"   THEN
                 DO:
                    IF  VALID-HANDLE(h-b1wgen0102) THEN
                        DELETE OBJECT h-b1wgen0102.

                     HIDE FRAME f_aliena.
                     RETURN.
                 END.
            NEXT.
        END.

   IF   aux_cddopcao <> glb_cddopcao   THEN
        DO:
            { includes/acesso.i}
            aux_cddopcao = glb_cddopcao.
        END.

   PAUSE 0.

   ASSIGN aux_contareg = 0
          aux_flgretor = FALSE.

   CLEAR FRAME f_aliena_2 ALL NO-PAUSE.

   HIDE MESSAGE NO-PAUSE.

   /* Bens alienados */
   FOR EACH tt-aliena NO-LOCK:

       ASSIGN aux_contareg = aux_contareg + 1

              tel_dsaliena = tt-aliena.dscatbem + " " + tt-aliena.dsbemfin
              tel_flgalfid = tt-aliena.flgalfid
              tel_dtvigseg = tt-aliena.dtvigseg
              tel_flglbseg = tt-aliena.flglbseg
              tel_flgrgcar = tt-aliena.flgrgcar
              tel_tpinclus = tt-aliena.tpinclus
              tel_dtatugrv = tt-aliena.dtatugrv
              aux_cdsitgrv = tt-aliena.cdsitgrv.

       PAUSE 0.

       IF   aux_contareg = 1  THEN
            IF  aux_flgretor  THEN
                DO:
                    PAUSE MESSAGE
                    "Tecle <Entra> para continuar ou <Fim> para encerrar".

                    CLEAR FRAME f_aliena_2 ALL NO-PAUSE.

                    ASSIGN aux_flgretor = FALSE.
                END.

       /* Mostrar dados  */
       RUN proc_opcao_c.

       /* Opcoes da tela */
       IF  glb_cddopcao = "A"   THEN
           RUN proc_opcao_a.
       ELSE
       IF  glb_cddopcao = "S"   THEN
           RUN proc_opcao_s.

       IF  glb_cdcritic > 0 THEN
           LEAVE.

       /* Tratar critica */
       IF   RETURN-VALUE <> "OK"   THEN
            LEAVE.

       IF   aux_contareg = 7   THEN
            DO:
                ASSIGN aux_contareg = 0
                       aux_flgretor = TRUE.
            END.
       ELSE
             DOWN WITH FRAME f_aliena_2.

   END. /* Fim Listagem */

   IF   glb_cdcritic > 0 THEN
        NEXT.

   IF   RETURN-VALUE <> "OK"   THEN
        NEXT.

   DO ON ENDKEY UNDO, NEXT INICIO:

       PAUSE MESSAGE "Tecle <Entra> para continuar ou <Fim> para encerrar".
       aux_contareg = 0.

   END.

END.  /*  Fim do DO WHILE TRUE  */

IF  VALID-HANDLE(h-b1wgen0102) THEN
    DELETE OBJECT h-b1wgen0102.

/* ......................................................................... */

PROCEDURE proc_opcao_c:

    DISPLAY tel_dsaliena
            tel_flgalfid
            tel_tpinclus 
            tel_dtatugrv 
            tel_dtvigseg
            tel_flglbseg
            tel_flgrgcar WITH FRAME f_aliena_2.

    RETURN "OK".

END PROCEDURE.


PROCEDURE proc_opcao_a:

    Altera: DO WHILE TRUE ON ENDKEY UNDO, LEAVE:


       IF  tt-aliena.cdsitgrv <> 2 THEN
           UPDATE tel_flgalfid
             WITH FRAME f_aliena_2.

       IF  NOT tt-aliena.flgperte THEN
           DO:
               UPDATE tel_dtvigseg
                      tel_flglbseg
                      tel_flgrgcar
                      WITH FRAME f_aliena_2.
           END.

       RUN Valida_Dados.

       IF  RETURN-VALUE = "NOK" THEN
           DO:
               DO WHILE TRUE ON ENDKEY UNDO,LEAVE:
                   PAUSE 2 NO-MESSAGE.
                   LEAVE.
               END.

               LEAVE Altera.
           END.

       FOR EACH tt-mensagens BY tt-mensagens.nrsequen:

            RUN fontes/confirma.p
                ( INPUT tt-mensagens.dsmensag,
                 OUTPUT aux_confirma).

            IF  aux_confirma <> "S"  THEN
                NEXT Altera.

       END.

       LEAVE Altera.

    END. /* Fim do DO WHILE TRUE */

    IF   KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
         RETURN "NOK".

    IF  NOT RETURN-VALUE = "NOK" THEN
        DO:
            RUN Grava_Dados.

            IF  RETURN-VALUE = "NOK" THEN
                RETURN "NOK".

        END.

    RETURN "OK".

END PROCEDURE.


PROCEDURE proc_opcao_s:

    Seguro: DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

        UPDATE tel_dtvigseg
               WITH FRAME f_aliena_2.

        RUN Valida_Dados.

        IF  RETURN-VALUE = "NOK" THEN
            DO:
                ASSIGN tel_dtvigseg = tt-aliena.dtvigseg.

                DO WHILE TRUE ON ENDKEY UNDO,LEAVE:
                   PAUSE 2 NO-MESSAGE.
                   LEAVE.
                END.

                DISPLAY tel_dtvigseg WITH FRAME f_aliena_2.

                LEAVE Seguro.
            END.

        FOR EACH tt-mensagens BY tt-mensagens.nrsequen:

            RUN fontes/confirma.p
                ( INPUT tt-mensagens.dsmensag,
                 OUTPUT aux_confirma).

            IF  aux_confirma <> "S"  THEN
                NEXT Seguro.

        END.

        LEAVE Seguro.

    END. /* Fim do DO WHILE TRUE */

    IF   KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
         RETURN "NOK".

    IF  NOT RETURN-VALUE = "NOK" THEN
        DO:
            RUN Grava_Dados.

            IF  RETURN-VALUE = "NOK" THEN
                RETURN "NOK".

        END.

    RETURN "OK".

END PROCEDURE.

PROCEDURE Busca_Dados:

    EMPTY TEMP-TABLE tt-infoepr.
    EMPTY TEMP-TABLE tt-aliena.
    EMPTY TEMP-TABLE tt-erro.

    IF  NOT VALID-HANDLE(h-b1wgen0102) THEN
        RUN sistema/generico/procedures/b1wgen0102.p
            PERSISTENT SET h-b1wgen0102.

    RUN Busca_Dados IN h-b1wgen0102
        ( INPUT glb_cdcooper,
          INPUT 0,
          INPUT 0,
          INPUT glb_cdoperad,
          INPUT glb_nmdatela,
          INPUT 1,
          INPUT tel_nrdconta,
          INPUT glb_cddopcao,
          INPUT tel_nrctremp,
          INPUT YES,
         OUTPUT TABLE tt-infoepr,
         OUTPUT TABLE tt-aliena,
         OUTPUT TABLE tt-erro).

    FIND FIRST tt-infoepr NO-ERROR.

    IF  AVAILABLE tt-infoepr THEN
        ASSIGN tel_nmprimtl = tt-infoepr.nmprimtl
               tel_dtmvtolt = tt-infoepr.dtmvtolt.

    CLEAR FRAME f_aliena NO-PAUSE.

    DISPLAY glb_cddopcao tel_nrdconta tel_nrctremp
            tel_nmprimtl tel_dtmvtolt WITH FRAME f_aliena.

    IF  RETURN-VALUE <> "OK" OR TEMP-TABLE tt-erro:HAS-RECORDS THEN
        DO:
            FIND FIRST tt-erro NO-ERROR.

            IF  AVAILABLE tt-erro THEN
                MESSAGE tt-erro.dscritic.

            RETURN "NOK".
        END.

    RETURN "OK".

END PROCEDURE. /* Busca_Dados */

PROCEDURE Valida_Dados:

    EMPTY TEMP-TABLE tt-mensagens.
    EMPTY TEMP-TABLE tt-erro.

    IF  NOT VALID-HANDLE(h-b1wgen0102) THEN
        RUN sistema/generico/procedures/b1wgen0102.p
            PERSISTENT SET h-b1wgen0102.

    RUN Valida_Dados IN h-b1wgen0102
        ( INPUT glb_cdcooper,
          INPUT 0,
          INPUT 0,
          INPUT glb_cdoperad,
          INPUT glb_nmdatela,
          INPUT 1,
          INPUT glb_dtmvtolt,
          INPUT glb_cddopcao,
          INPUT tel_nrdconta,
          INPUT tel_nrctremp,
          INPUT tt-aliena.idseqbem,
          INPUT tel_flgalfid,
          INPUT tt-aliena.flgperte,
          INPUT tel_dtvigseg,
         OUTPUT TABLE tt-mensagens,
         OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE <> "OK" OR TEMP-TABLE tt-erro:HAS-RECORDS THEN
        DO:
            FIND FIRST tt-erro NO-ERROR.

            IF  AVAILABLE tt-erro THEN
                MESSAGE tt-erro.dscritic.

            RETURN "NOK".
        END.

    RETURN "OK".

END PROCEDURE. /* Valida_Dados */

PROCEDURE Grava_Dados:

    EMPTY TEMP-TABLE tt-erro.

    IF  NOT VALID-HANDLE(h-b1wgen0102) THEN
        RUN sistema/generico/procedures/b1wgen0102.p
            PERSISTENT SET h-b1wgen0102.

    RUN Grava_Dados IN h-b1wgen0102
        ( INPUT glb_cdcooper,
          INPUT 0,
          INPUT 0,
          INPUT glb_cdoperad,
          INPUT glb_nmdatela,
          INPUT 1,
          INPUT glb_dtmvtolt,
          INPUT glb_cddopcao,
          INPUT tel_nrdconta,
          INPUT 1, /* idseqttl */
          INPUT tel_nrctremp,
          INPUT tt-aliena.idseqbem,
          INPUT tel_flgalfid,
          INPUT tel_dtvigseg,
          INPUT tel_flglbseg,
          INPUT tel_flgrgcar,
          INPUT tt-aliena.flgperte,
          INPUT TRUE, /* flgerlog */
         OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE <> "OK" OR TEMP-TABLE tt-erro:HAS-RECORDS THEN
        DO:
            FIND FIRST tt-erro NO-ERROR.

            IF  AVAILABLE tt-erro THEN
                MESSAGE tt-erro.dscritic.

            RETURN "NOK".
        END.

    IF  VALID-HANDLE(h-b1wgen0102) THEN
        DELETE OBJECT h-b1wgen0102.

    RETURN "OK".

END PROCEDURE. /* Grava_Dados */

/* .......................................................................... */


