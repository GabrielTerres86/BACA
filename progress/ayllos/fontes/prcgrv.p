/* .............................................................................

   Programa: Fontes/prcgrv.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Carlos/CECRED 
   Data    : Junho/2013                          Ultima alteracao: 06/12/2016 

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : PRCGRV - Alterar/consultar as sequencias dos lotes dos gravames.
   
   Alteraçao : 06/12/2016 - Alterado campo dsdepart para cddepart.
                            PRJ341 - BANCENJUD (Odirlei-AMcom)
............................................................................. */

{ includes/var_online.i }

/* Variaveis de Tela: */
DEF VAR tel_nrseqinc AS INT FORMAT "zzz,zzz,zz9" LABEL "Inclusao"     NO-UNDO.
DEF VAR tel_nrseqqui AS INT FORMAT "zzz,zzz,zz9" LABEL "Quitacao"     NO-UNDO.
DEF VAR tel_nrseqman AS INT FORMAT "zzz,zzz,zz9" LABEL "Manutencao"   NO-UNDO.
DEF VAR tel_nrseqcan AS INT FORMAT "zzz,zzz,zz9" LABEL "Cancelamento" NO-UNDO.

/* Variaveis de Log: */
DEF VAR log_nrseqinc AS INT  NO-UNDO.
DEF VAR log_nrseqqui AS INT  NO-UNDO.
DEF VAR log_nrseqman AS INT  NO-UNDO.
DEF VAR log_nrseqcan AS INT  NO-UNDO.

DEF VAR aux_cddopcao AS CHAR            NO-UNDO.
DEF VAR aux_confirma AS CHAR FORMAT "!" NO-UNDO.

FORM WITH ROW 4 COLUMN 1 OVERLAY TITLE glb_tldatela SIZE 80 BY 18 
     FRAME f_moldura.

FORM SKIP(1)
    glb_cddopcao AT 10 LABEL "Opcao" AUTO-RETURN FORMAT "!"
        HELP "Entre com a opcao desejada (A,C)."
        VALIDATE(CAN-DO("A,C",glb_cddopcao),
                "014 - Opcao errada.")
    SKIP(2)
    tel_nrseqinc AT 07 
        LABEL "Numero sequencial do lote de inclusao"
        HELP "Informe o numero sequencial do lote de inclusao."
        VALIDATE(tel_nrseqinc <> '' , "357 - O campo deve ser prenchido.")
    SKIP(1)
    tel_nrseqqui AT 07 
        LABEL "Numero sequencial do lote de quitacao"
        HELP "Informe o numero sequencial do lote de quitacao."
        VALIDATE (tel_nrseqqui <> '' , "357 - O campo deve ser prenchido.")
    SKIP(1)
    tel_nrseqman AT 05
        LABEL "Numero sequencial do lote de manutencao"      
        HELP "Informe o numero sequencial do lote de manutencao."
        VALIDATE (tel_nrseqman <> '' , "357 - O campo deve ser prenchido.")
    SKIP(1)
    tel_nrseqcan AT 03
        LABEL "Numero sequencial do lote de cancelamento"      
        HELP "Informe o numero sequencial do lote de cancelamento."
        VALIDATE (tel_nrseqcan <> '' , "357 - O campo deve ser prenchido.")
    
    WITH WIDTH 78 CENTERED ROW 5 OVERLAY NO-BOX SIDE-LABELS FRAME f_prcgrv.


ASSIGN glb_cddopcao = "C"
       glb_cdcritic = 0.
       
VIEW FRAME f_moldura.
PAUSE(0).

RUN fontes/inicia.p.

DO WHILE TRUE:
    
    IF glb_cdcritic <> 0  THEN
        DO:
            RUN fontes/critic.p.
            BELL.
            MESSAGE glb_dscritic.
            glb_cdcritic = 0.
        END.

    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
        UPDATE glb_cddopcao WITH FRAME f_prcgrv.
        LEAVE.
    END.

    IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
        DO:
            RUN fontes/novatela.p.
            IF   CAPS(glb_nmdatela) <> "prcgrv"   THEN
                 DO:
                     HIDE FRAME f_prcgrv.
                     HIDE FRAME f_moldura.
                     RETURN.
                 END.
            NEXT.
        END.

    IF  aux_cddopcao <> glb_cddopcao THEN 
        DO:
            { includes/acesso.i }
            aux_cddopcao = glb_cddopcao.
        END.


    /* Opcao = Consultar */
    IF  glb_cddopcao = "C" THEN 
        DO:
            FIND crapsqg WHERE crapsqg.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.

            IF AVAIL crapsqg THEN 
                DO:
                    ASSIGN tel_nrseqinc = crapsqg.nrseqinc
                           tel_nrseqqui = crapsqg.nrseqqui
                           tel_nrseqman = crapsqg.nrseqman
                           tel_nrseqcan = crapsqg.nrseqcan.
                END.
                ELSE
                DO:
                    MESSAGE "Informacoes nao encontradas.".
                    BELL.
                    PAUSE(2) NO-MESSAGE.
                    RETURN.
                END.

            /* Mostra os campos no frame */
            DISP tel_nrseqinc
                 tel_nrseqqui
                 tel_nrseqman
                 tel_nrseqcan
                 WITH FRAME f_prcgrv.

        END.
    ELSE
    
    /* Opcao = Alterar */
    IF  glb_cddopcao = "A" THEN 
        DO TRANSACTION:

            /* Permissoes de acesso */
            IF  glb_cddepart <> 20 AND  /* TI       */
                glb_cddepart <> 14 THEN /* PRODUTOS */
                DO:
                    glb_cdcritic = 36.
                    NEXT.
                END.
    
            FIND crapsqg WHERE crapsqg.cdcooper = glb_cdcooper EXCLUSIVE-LOCK NO-ERROR.

            IF  AVAIL crapsqg THEN 
                DO:
                    ASSIGN tel_nrseqinc = crapsqg.nrseqinc
                           tel_nrseqqui = crapsqg.nrseqqui
                           tel_nrseqman = crapsqg.nrseqman
                           tel_nrseqcan = crapsqg.nrseqcan
                           log_nrseqinc = crapsqg.nrseqinc
                           log_nrseqqui = crapsqg.nrseqqui
                           log_nrseqman = crapsqg.nrseqman
                           log_nrseqcan = crapsqg.nrseqcan.
    
                    DO ON ENDKEY UNDO, LEAVE:
                        UPDATE tel_nrseqinc
                               tel_nrseqqui
                               tel_nrseqman
                               tel_nrseqcan
                               WITH FRAME f_prcgrv.

                        IF  KEYFUNCTION(LASTKEY) = "END-ERROR" THEN  /*   F4 OU FIM */
                        NEXT.
                        
                        /* Se nao modificou nada ... NEXT */
                        IF  NOT (tel_nrseqinc <> log_nrseqinc OR 
                                 tel_nrseqqui <> log_nrseqqui OR
                                 tel_nrseqman <> log_nrseqman OR
                                 tel_nrseqcan <> log_nrseqcan) THEN
                        NEXT.
                              
                        RUN fontes/confirma.p (INPUT "",
                                               OUTPUT aux_confirma).
    
                        IF  aux_confirma <> "S"  THEN
                        NEXT.
        
                        ASSIGN crapsqg.nrseqinc = tel_nrseqinc
                               crapsqg.nrseqqui = tel_nrseqqui
                               crapsqg.nrseqman = tel_nrseqman
                               crapsqg.nrseqcan = tel_nrseqcan.
        
                        RUN gera_log (INPUT glb_cddopcao,
                                      INPUT tel_nrseqinc, 
                                      INPUT tel_nrseqqui, 
                                      INPUT tel_nrseqman,
                                      INPUT tel_nrseqcan,
    
                                      INPUT log_nrseqinc, 
                                      INPUT log_nrseqqui, 
                                      INPUT log_nrseqman, 
                                      INPUT log_nrseqcan).
                        LEAVE.
                    END.
                END. /* end if avail */
                ELSE
                DO:
                    MESSAGE "Informacoes nao encontradas.".
                    BELL.
                    PAUSE(2) NO-MESSAGE.
                    RETURN.
                END.         
        END. /* end opcao (A)lterar */
END. /* Fim DO WHILE TRUE  */

/* .......................................................................... */

PROCEDURE gera_log:

    DEF INPUT PARAM par_cddopcao LIKE glb_cddopcao  NO-UNDO.
    DEF INPUT PARAM par_nrseqinc AS INT             NO-UNDO.
    DEF INPUT PARAM par_nrseqqui AS INT             NO-UNDO.
    DEF INPUT PARAM par_nrseqman AS INT             NO-UNDO.
    DEF INPUT PARAM par_nrseqcan AS INT             NO-UNDO.

    DEF INPUT PARAM par_loseqinc AS INT             NO-UNDO.
    DEF INPUT PARAM par_loseqqui AS INT             NO-UNDO.
    DEF INPUT PARAM par_loseqman AS INT             NO-UNDO.
    DEF INPUT PARAM par_loseqcan AS INT             NO-UNDO.

    UNIX SILENT VALUE("echo " + STRING(glb_dtmvtolt,"99/99/9999") +
                      " "     + STRING(TIME,"HH:MM:SS")  + "' --> '"    +
                      " Operador " + glb_cdoperad + " - " + "Alterou: " +
                      (IF par_nrseqinc <> par_loseqinc THEN
                          " A sequencia de lote de inclusao de "     + STRING(par_loseqinc) +
                          " para " + STRING(par_nrseqinc) + "."
                       ELSE "") +
                      (IF par_nrseqqui <> par_loseqqui THEN
                          " A sequencia de lote de quitacao de "     + STRING(par_loseqqui) +
                          " para " + STRING(par_nrseqqui) + "."
                       ELSE "") +
                      (IF par_nrseqman <> par_loseqman THEN
                          " A sequencia de lote de manutencao de "   + STRING(par_loseqman) + 
                          " para " + STRING(par_nrseqman) + "."
                       ELSE "") +
                      (IF par_nrseqcan <> par_loseqcan THEN
                          " A sequencia de lote de cancelamento de " + STRING(par_loseqcan) +
                          " para " + STRING(par_nrseqcan) + "."
                       ELSE "") 
                      + " >> log/prcgrv.log").

END PROCEDURE.
