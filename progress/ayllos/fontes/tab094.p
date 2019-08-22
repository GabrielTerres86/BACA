/*.............................................................................

  Programa: Fontes/tab094.p
  Sistema : Conta-Corrente - Cooperativa de Credito
  Sigla   : CRED
  Autor   : Tiago
  Data    : Julho/12                            Ultima alteracao: 31/07/2015

  Objetivo  : Mostrar a tela tab094 - Parametros para fluxo financeiro.

  Alteracao : 25/06/2013 - Adicionado os campos Margem Cta Itg BB Credito e
                           Margem Cta Itg BB Debito (Reinert)

  Alteracao : 13/06/2014 - Correcao da ordem dos parametros passados para a
                           procedure grava_dados -  167998 (Carlos Rafael Tanholi)
                           
              31/07/2015 - Ajuste para retirar o caminho absoluto na chamada
                           de fontes (Adriano - SD 314469).              
  
              08/12/2016 - P341-Automatização BACENJUD - Realizar a validação 
			               do departamento pelo código do mesmo (Renato Darosci)
............................................................................ */

{ includes/var_online.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/b1wgen0139tt.i }

DEF VAR aux_cddopcao  AS CHAR                                          NO-UNDO.
DEF VAR aux_confirma  AS CHAR FORMAT "!(1)"                            NO-UNDO.

DEF VAR tel_mrgsrdoc  AS DECI   FORMAT "-zz9.99%"                      NO-UNDO.
DEF VAR tel_mrgsrchq  AS DECI   FORMAT "-zz9.99%"                      NO-UNDO.
DEF VAR tel_mrgnrtit  AS DECI   FORMAT "-zz9.99%"                      NO-UNDO.
DEF VAR tel_mrgsrtit  AS DECI   FORMAT "-zz9.99%"                      NO-UNDO.
DEF VAR tel_caldevch  AS DECI   FORMAT " zz9.99%"                      NO-UNDO.
DEF VAR tel_mrgitgcr  AS DECI   FORMAT "-zz9.99%"                      NO-UNDO.
DEF VAR tel_mrgitgdb  AS DECI   FORMAT "-zz9.99%"                      NO-UNDO.
DEF VAR tel_horabloq  AS DECI   FORMAT "99"                            NO-UNDO.
DEF VAR tel_minubloq  AS DECI   FORMAT "99"                            NO-UNDO.
DEF VAR aux_nmcooper  AS CHAR                                          NO-UNDO.
DEF VAR tel_cdcooper  AS CHAR FORMAT "x(12)" VIEW-AS COMBO-BOX   
                              INNER-LINES 10                           NO-UNDO.
DEF VAR aux_contador  AS INT                                           NO-UNDO.


DEF VAR h-b1wgen0139  AS HANDLE.

FORM SKIP(1)
     glb_cddopcao AT 5 LABEL "Opcao" AUTO-RETURN
         HELP "Entre com a opcao desejada (C ou A)"
         VALIDATE(CAN-DO("C,A",glb_cddopcao),"014 - Opcao errada.")
     tel_cdcooper AT 15 LABEL "Cooperativa"
     SKIP(2)
     tel_mrgsrdoc AT 31 LABEL "MARGEM SR DOC"
     tel_mrgsrchq AT 27 LABEL "MARGEM SR CHEQUES"
     tel_mrgnrtit AT 27 LABEL "MARGEM NR TITULOS"
     tel_mrgsrtit AT 27 LABEL "MARGEM SR TITULOS"
     tel_caldevch AT 5  LABEL "BASE DE CALCULO DEVOLUCAO CHEQUES RECEB"
     tel_mrgitgcr AT 19 LABEL "MARGEM CTA ITG BB CREDITO"
     tel_mrgitgdb AT 20 LABEL "MARGEM CTA ITG BB DEBITO"
     
     "HORARIO DE BLOQUEIO:" AT 25
     tel_horabloq AT 47 NO-LABEL 
     tel_minubloq AT COL 50 ROW 12 NO-LABEL
     ":" AT COL 49 ROW 12
     SKIP(6)
     WITH ROW 4 COLUMN 1 WIDTH 80 OVERLAY SIDE-LABELS NO-LABEL FRAME f_tab094.


RUN Busca_Cooperativas (INPUT glb_cdcooper,
                        OUTPUT aux_nmcooper).

ASSIGN tel_cdcooper:LIST-ITEM-PAIRS = aux_nmcooper.

ON RETURN OF tel_cdcooper  IN FRAME f_tab094
   DO:
       tel_cdcooper = tel_cdcooper:SCREEN-VALUE.
       APPLY "GO".
   END.


RUN fontes/inicia.p. 

ASSIGN glb_cddopcao = "C"
       glb_cdcritic = 0.

VIEW FRAME f_tab094.
PAUSE(0).

DO WHILE TRUE:

    DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:
        
        UPDATE glb_cddopcao
               tel_cdcooper
               WITH FRAME f_tab094.

        LEAVE.

    END.

    IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
        DO:
            RUN fontes/novatela.p.

            IF  CAPS(glb_nmdatela) <> "tab094"   THEN
                DO:
                    HIDE FRAME f_tab094.
                    RETURN.
                END.
            ELSE
                NEXT.
        END.

    IF  aux_cddopcao <> glb_cddopcao   THEN
        DO:
            { includes/acesso.i } 
            aux_cddopcao = glb_cddopcao.
        END.
        
    IF  glb_cdcritic > 0   THEN
        DO:
            RUN fontes/critic.p.
            BELL.
            MESSAGE glb_dscritic.
            CLEAR FRAME f_tab094 NO-PAUSE.
            glb_cdcritic = 0.
        END.
    
    RUN sistema/generico/procedures/b1wgen0139.p
        PERSISTENT SET h-b1wgen0139.

    RUN acesso_opcao IN h-b1wgen0139(INPUT  glb_cdcooper,
                                     INPUT  glb_cdagenci,
                                     INPUT  glb_cddepart,
                                     INPUT  glb_cddopcao,
                                     OUTPUT TABLE tt-erro).
    
    DELETE OBJECT h-b1wgen0139.

    FIND FIRST tt-erro NO-LOCK NO-ERROR.

    IF  AVAIL(tt-erro) THEN
        DO:
            MESSAGE tt-erro.dscritic.
            NEXT.
        END.

    CASE glb_cddopcao:
        WHEN "C" THEN 
            DO: 

                RUN sistema/generico/procedures/b1wgen0139.p
                    PERSISTENT SET h-b1wgen0139.
                                                             
                RUN busca_dados IN h-b1wgen0139(INPUT  glb_cdcooper,
                                                INPUT  glb_cdagenci,
                                                INPUT  0,
                                                INPUT  glb_cdoperad,
                                                INPUT  tel_cdcooper,
                                                OUTPUT TABLE tt-fluxo-fin,
                                                OUTPUT TABLE tt-erro).
                                                               
                DELETE OBJECT h-b1wgen0139.

                FIND FIRST tt-erro NO-LOCK NO-ERROR.

                IF  AVAIL(tt-erro) THEN
                    DO:
                        MESSAGE tt-erro.dscritic.
                        NEXT.
                    END.
                ELSE
                    DO:
                        FIND FIRST tt-fluxo-fin NO-LOCK NO-ERROR.

                        ASSIGN tel_mrgsrdoc = tt-fluxo-fin.mrgsrdoc
                               tel_mrgsrchq = tt-fluxo-fin.mrgsrchq
                               tel_mrgnrtit = tt-fluxo-fin.mrgnrtit
                               tel_mrgsrtit = tt-fluxo-fin.mrgsrtit
                               tel_caldevch = tt-fluxo-fin.caldevch
                               tel_mrgitgcr = tt-fluxo-fin.mrgitgcr
                               tel_mrgitgdb = tt-fluxo-fin.mrgitgdb
                               tel_horabloq = 
                                 DECI(ENTRY(1,tt-fluxo-fin.horabloq,":"))
                               tel_minubloq = 
                                 DECI(ENTRY(2,tt-fluxo-fin.horabloq,":")).
                               

                    END.

            END.
        WHEN "A" THEN 
            DO:

                RUN sistema/generico/procedures/b1wgen0139.p
                    PERSISTENT SET h-b1wgen0139.

                RUN busca_dados IN h-b1wgen0139(INPUT  glb_cdcooper,
                                                INPUT  glb_cdagenci,
                                                INPUT  0,
                                                INPUT  glb_cdoperad,
                                                INPUT  tel_cdcooper,
                                                OUTPUT TABLE tt-fluxo-fin,
                                                OUTPUT TABLE tt-erro).

                DELETE OBJECT h-b1wgen0139.

                FIND FIRST tt-erro NO-LOCK NO-ERROR.

                IF  AVAIL(tt-erro) THEN
                    DO:
                        MESSAGE tt-erro.dscritic.
                        NEXT.
                    END.
                ELSE                   
                    DO:
                        FIND FIRST tt-fluxo-fin NO-LOCK NO-ERROR.

                        ASSIGN  tel_mrgsrdoc = tt-fluxo-fin.mrgsrdoc
                                tel_mrgsrchq = tt-fluxo-fin.mrgsrchq
                                tel_mrgnrtit = tt-fluxo-fin.mrgnrtit
                                tel_mrgsrtit = tt-fluxo-fin.mrgsrtit
                                tel_caldevch = tt-fluxo-fin.caldevch
                                tel_mrgitgcr = tt-fluxo-fin.mrgitgcr
                                tel_mrgitgdb = tt-fluxo-fin.mrgitgdb

                                tel_horabloq = 
                                  DECI(ENTRY(1,tt-fluxo-fin.horabloq,":"))
                                tel_minubloq = 
                                  DECI(ENTRY(2,tt-fluxo-fin.horabloq,":")).
                    END.

                DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                    UPDATE tel_mrgsrdoc tel_mrgsrchq
                           tel_mrgnrtit tel_mrgsrtit
                           tel_caldevch tel_mrgitgcr
                           tel_mrgitgdb tel_horabloq
                           tel_minubloq
                           WITH FRAME f_tab094.

                    LEAVE.

                END.

                ASSIGN aux_confirma = "N".

                RUN fontes/confirma.p(INPUT  "",
                                      OUTPUT aux_confirma).

                IF  aux_confirma = "S" THEN
                    DO:
                        RUN sistema/generico/procedures/b1wgen0139.p
                            PERSISTENT SET h-b1wgen0139.

                        RUN grava_dados IN h-b1wgen0139
                                        (INPUT  glb_cdcooper,
                                         INPUT  glb_cdagenci,
                                         INPUT  0,
                                         INPUT  glb_cdoperad,
                                         INPUT  glb_nmdatela,
                                         INPUT  glb_cddepart,
                                         INPUT  1,
                                         INPUT  glb_dtmvtolt,
                                         INPUT  tel_mrgsrdoc,
                                         INPUT  tel_mrgsrchq,
                                         INPUT  tel_mrgnrtit,
                                         INPUT  tel_mrgsrtit,
                                         INPUT  tel_caldevch,
                                         INPUT  tel_mrgitgcr,
                                         INPUT  tel_mrgitgdb,
                                         INPUT STRING(tel_horabloq,"99") + 
                                               ":" + STRING(tel_minubloq,"99"),
                                         INPUT tel_cdcooper,
                                         OUTPUT TABLE tt-erro).

                        DELETE OBJECT h-b1wgen0139.

                        FIND FIRST tt-erro NO-LOCK NO-ERROR.
    
                        IF  AVAIL(tt-erro) THEN
                            DO:
                                MESSAGE tt-erro.dscritic.
                                NEXT.
                            END.
                        ELSE
                            DO:
                                MESSAGE "Registro alterado com sucesso.".
                                NEXT.
                            END.

                     END.

            END.
    END CASE.

    DISPLAY tel_mrgsrdoc
            tel_mrgsrchq
            tel_mrgnrtit
            tel_mrgsrtit
            tel_caldevch
            tel_mrgitgcr
            tel_mrgitgdb
            tel_horabloq
            tel_minubloq
            WITH FRAME f_tab094.

END.



PROCEDURE Busca_Cooperativas:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  OUTPUT PARAM aux_nmcooper AS CHAR                          NO-UNDO.
    
    ASSIGN aux_contador = 0.

    FOR EACH crapcop WHERE crapcop.cdcooper <> 3 
                           NO-LOCK BY crapcop.dsdircop:

        IF  aux_contador = 0 THEN
            ASSIGN aux_nmcooper = CAPS(crapcop.dsdircop) + "," +
                                  STRING(crapcop.cdcooper)
                   aux_contador = 1.
        ELSE
            ASSIGN aux_nmcooper = aux_nmcooper + "," + CAPS(crapcop.dsdircop)
                                              + "," + STRING(crapcop.cdcooper).

    END. /* FIM FOR EACH crapcop  */

    RETURN "OK".
    
END PROCEDURE. /* Busca_Cooperativas */
