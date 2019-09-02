/* .............................................................................

   Programa: Fontes/hrcomp.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Tiago
   Data    : Fevereiro/2014                       Ultima Atualizacao: 02/12/2016

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela hrcomp que agenda os horarios de processamento
               dos arquivos automaticamente.

   Alteracoes: 25/07/2014 - Incluido opcao TODAS para alteração de horarios
                            para todas cooperativas de uma vez so 
                           (Tiago/Elton SD172634).
                           
               31/07/2015 - Ajuste para retirar o caminho absoluto na chamada
                            de fontes 
                           (Adriano - SD 314469).            
                           
               13/06/2016 - Incluir flgativo na busca das cooperativas na PROCEDURE
                            Busca_Cooperativas (Lucas Ranghetti #462237)
                            
               21/09/2016 - Incluir tratamento para poder alterar a cooperativa cecred e 
                            escolher o programa "DEVOLUCAO DOC" - Melhoria 316 
                            (Lucas Ranghetti #525623)
                            
               02/12/2016 - Alterado campo dsdepart para cddepart.
                            PRJ341 - BANCENJUD (Odirlei-AMcom)             
............................................................................. */

{ includes/var_online.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/b1wgen0183tt.i }

DEF VAR aux_cddopcao  AS CHAR                                          NO-UNDO.
DEF VAR aux_confirma  AS CHAR FORMAT "!(1)"                            NO-UNDO.

DEF VAR aux_nmcooper  AS CHAR                                          NO-UNDO.
DEF VAR tel_cdcooper  AS CHAR FORMAT "x(12)" VIEW-AS COMBO-BOX   
                              INNER-LINES 10                           NO-UNDO.

DEF VAR aux_flgativo  AS LOGICAL                                       NO-UNDO.
DEF VAR aux_ageinihr  AS INTE                                          NO-UNDO.
DEF VAR aux_ageinimm  AS INTE                                          NO-UNDO.
DEF VAR aux_agefimhr  AS INTE                                          NO-UNDO.
DEF VAR aux_agefimmm  AS INTE                                          NO-UNDO.


DEF VAR aux_contador  AS INT                                           NO-UNDO.

DEF VAR h-b1wgen0183  AS HANDLE.

FORM SKIP
     glb_cddopcao AT 5 LABEL "Opcao" AUTO-RETURN
         HELP "Entre com a opcao desejada (C ou A)"
         VALIDATE(CAN-DO("C,A",glb_cddopcao),"014 - Opcao errada.")
     tel_cdcooper AT 15 LABEL "Cooperativa"
     SKIP(15)
     WITH ROW 4 COLUMN 1 WIDTH 80 OVERLAY SIDE-LABELS NO-LABEL FRAME f_hrcomp.

DEF QUERY q_consulta   FOR tt-processos.

DEF BROWSE b_consulta QUERY q_consulta
    DISPLAY tt-processos.nmproces   COLUMN-LABEL "Processo"        FORMAT "x(35)"
            tt-processos.flgativo   COLUMN-LABEL "Ativo"           FORMAT "Sim/Nao"
            tt-processos.hrageini   COLUMN-LABEL "Horario inicial" FORMAT "x(5)"
            tt-processos.hragefim   COLUMN-LABEL "Horario final"   FORMAT "x(5)"
            WITH 10 DOWN CENTERED NO-BOX WIDTH 74.

FORM b_consulta
     HELP "Use as SETAS para navegar <F4> para sair."
     WITH ROW 7 CENTERED OVERLAY SIDE-LABELS NO-LABELS WIDTH 78
          TITLE " Arquivos Comp " FRAME f_browse.

FORM tt-processos.flgativo LABEL "Ativo" FORMAT "Sim/Nao"
     "Horario inicial"     
     tt-processos.ageinihr NO-LABEL FORMAT "99"
     ":"                   
     tt-processos.ageinimm NO-LABEL FORMAT "99"
     "Horario final"
     tt-processos.agefimhr NO-LABEL FORMAT "99"
     ":"                   
     tt-processos.agefimmm NO-LABEL FORMAT "99"
     WITH ROW 10 CENTERED SIDE-LABELS OVERLAY FRAME f_edita.

FORM tt-processos.flgativo WITH FRAME f_ativo.


/*ON LEAVE OF b_consulta IN FRAME f_browse DO:

    IF  NOT AVAILABLE tt-processos   THEN  
        RETURN.

END.*/


RUN Busca_Cooperativas (INPUT glb_cdcooper,
                        OUTPUT aux_nmcooper).

ASSIGN tel_cdcooper:LIST-ITEM-PAIRS = aux_nmcooper.

ON RETURN OF tel_cdcooper  IN FRAME f_hrcomp
   DO:
       tel_cdcooper = tel_cdcooper:SCREEN-VALUE.
       APPLY "GO".
   END.

ON RETURN OF b_consulta DO: 

    IF  glb_cddopcao = "A" THEN
        DO: 
            DO  WHILE TRUE:
            
                /* para a CECRED, somente permitir alteracao do processo "Devolucao Doc"  */ 
                IF  INT(tel_cdcooper) = 3 AND 
                    tt-processos.nmproces <> "DEVOLUCAO DOC" THEN
                    DO:
                        MESSAGE "Cooperativa nao permite alteracao.".
                        PAUSE 3 NO-MESSAGE.
                        b_consulta:REFRESH().                        
                        LEAVE.
                    END.

                ASSIGN aux_flgativo = tt-processos.flgativo
                       aux_ageinihr = tt-processos.ageinihr
                       aux_ageinimm = tt-processos.ageinimm
                       aux_agefimhr = tt-processos.agefimhr
                       aux_agefimmm = tt-processos.agefimmm.

                UPDATE tt-processos.flgativo
                       tt-processos.ageinihr 
                       tt-processos.ageinimm 
                       tt-processos.agefimhr
                       tt-processos.agefimmm
                       WITH FRAME f_edita.
        
                         
                ASSIGN aux_confirma = "N".

                RUN fontes/confirma.p(INPUT  "",
                                      OUTPUT aux_confirma).

                IF  aux_confirma = "S" THEN
                    DO: 
                        RUN grava_dados(INPUT glb_cdcooper,
                                        INPUT glb_cdagenci,
                                        INPUT 0,
                                        INPUT glb_cdoperad,
                                        INPUT glb_nmdatela,
                                        INPUT glb_cddepart,
                                        INPUT 1,
                                        INPUT glb_dtmvtolt,
                                        INPUT tel_cdcooper,
                                        INPUT tt-processos.nmproces,
                                        INPUT tt-processos.flgativo,
                                        INPUT tt-processos.ageinihr,
                                        INPUT tt-processos.ageinimm,
                                        INPUT tt-processos.agefimhr,
                                        INPUT tt-processos.agefimmm,
                                        OUTPUT TABLE tt-erro).

                        FIND FIRST tt-erro NO-LOCK NO-ERROR.

                        IF  AVAIL(tt-erro) THEN
                            DO:
                                ASSIGN tt-processos.flgativo = aux_flgativo
                                       tt-processos.ageinihr = aux_ageinihr
                                       tt-processos.ageinimm = aux_ageinimm
                                       tt-processos.agefimhr = aux_agefimhr 
                                       tt-processos.agefimmm = aux_agefimmm.
                            END.

                        ASSIGN tt-processos.hrageini = 
                               STRING(tt-processos.ageinihr,"99") + ":" +
                               STRING(tt-processos.ageinimm,"99")
                               tt-processos.hragefim = 
                               STRING(tt-processos.agefimhr,"99") + ":" +
                               STRING(tt-processos.agefimmm,"99").
                    END.
                ELSE /* Nao confirmou */
                    DO:
                        ASSIGN tt-processos.flgativo = aux_flgativo
                               tt-processos.ageinihr = aux_ageinihr
                               tt-processos.ageinimm = aux_ageinimm
                               tt-processos.agefimhr = aux_agefimhr 
                               tt-processos.agefimmm = aux_agefimmm.
                    END.
                           
                b_consulta:REFRESH().
                CLEAR FRAME f_edita.
                HIDE FRAME f_edita.
                LEAVE.
            END.
        END.
    
END.

RUN fontes/inicia.p. 

ASSIGN glb_cddopcao = "C"
       glb_cdcritic = 0.

VIEW FRAME f_hrcomp.
     
RUN cria_reg_proc.       

DO WHILE TRUE:

    DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:
        
        UPDATE glb_cddopcao
               tel_cdcooper
               WITH FRAME f_hrcomp.

        LEAVE.

    END.

    IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
        DO:
            RUN fontes/novatela.p.

            IF  CAPS(glb_nmdatela) <> "hrcomp"   THEN
                DO:
                    HIDE FRAME f_hrcomp.
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
            CLEAR FRAME f_hrcomp NO-PAUSE.
            glb_cdcritic = 0.
        END.
    
    RUN sistema/generico/procedures/b1wgen0183.p
        PERSISTENT SET h-b1wgen0183.

    RUN acesso_opcao IN h-b1wgen0183(INPUT  glb_cdcooper,
                                     INPUT  glb_cdagenci,
                                     INPUT  glb_cddepart,
                                     INPUT  glb_cddopcao,
                                     OUTPUT TABLE tt-erro).
    
    DELETE OBJECT h-b1wgen0183.

    FIND FIRST tt-erro NO-LOCK NO-ERROR.

    IF  AVAIL(tt-erro) THEN
        DO:
            MESSAGE tt-erro.dscritic.
            NEXT.
        END.

    RUN sistema/generico/procedures/b1wgen0183.p
        PERSISTENT SET h-b1wgen0183.

    RUN busca_dados IN h-b1wgen0183(INPUT  glb_cdcooper,
                                    INPUT  glb_cdagenci,
                                    INPUT  0,
                                    INPUT  glb_cdoperad,
                                    INPUT  glb_nmdatela,
                                    INPUT  glb_cddepart,
                                    INPUT  1,
                                    INPUT  glb_dtmvtolt,
                                    INPUT  tel_cdcooper,
                                    OUTPUT TABLE tt-processos,
                                    OUTPUT TABLE tt-erro).


    DELETE OBJECT h-b1wgen0183.

    FIND FIRST tt-erro NO-LOCK NO-ERROR.

    IF  AVAIL(tt-erro) THEN
        DO:
            MESSAGE tt-erro.dscritic.
            NEXT.
        END.
    ELSE
        DO:
            OPEN QUERY q_consulta 
                 FOR EACH tt-processos EXCLUSIVE-LOCK.

            DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:
                UPDATE b_consulta WITH FRAME f_browse.
                LEAVE.
            END.

            CLOSE QUERY q_consulta.
            CLEAR FRAME f_browse.
            CLEAR FRAME f_hrcomp.
            HIDE  FRAME f_browse.

        END.

END.

/* Buscar todas cooperativas ativas do sistema */
PROCEDURE Busca_Cooperativas:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  OUTPUT PARAM aux_nmcooper AS CHAR                          NO-UNDO.
    
    ASSIGN aux_nmcooper = CAPS("todas") + "," +
                          STRING(0).
    
    FOR EACH crapcop WHERE crapcop.flgativo = TRUE
                           NO-LOCK BY crapcop.dsdircop:
                           
             ASSIGN aux_nmcooper = aux_nmcooper + "," + CAPS(crapcop.dsdircop)
                                              + "," + STRING(crapcop.cdcooper).

    END. /* FIM FOR EACH crapcop  */

    RETURN "OK".
    
END PROCEDURE. /* Busca_Cooperativas */

PROCEDURE cria_reg_proc:


    EMPTY TEMP-TABLE tt-processos.
    EMPTY TEMP-TABLE tt-erro.

    RUN sistema/generico/procedures/b1wgen0183.p
        PERSISTENT SET h-b1wgen0183.


    RUN cria_reg_proc IN h-b1wgen0183(INPUT  glb_cdcooper,
                                      INPUT  glb_cdagenci,
                                      INPUT  0, /*nrdcaixa*/
                                      INPUT  glb_cdoperad,
                                      INPUT  glb_nmdatela,
                                      INPUT  glb_cddepart,
                                      INPUT  1, /*idorigem*/
                                      INPUT  glb_dtmvtolt,
                                      INPUT-OUTPUT TABLE tt-processos,
                                      OUTPUT TABLE tt-erro).

    DELETE OBJECT h-b1wgen0183.


    /*
    CREATE tt-processos.
    ASSIGN tt-processos.nmproces = "DEVOLUCAO VLB"
           tt-processos.hrageini = "00:00"
           tt-processos.hragefim = "00:00".

    CREATE tt-processos.
    ASSIGN tt-processos.nmproces = "ICF"
           tt-processos.hrageini = "00:00"
           tt-processos.hragefim = "00:00".

    CREATE tt-processos.
    ASSIGN tt-processos.nmproces = "TIC606"
           tt-processos.hrageini = "00:00"
           tt-processos.hragefim = "00:00".

    CREATE tt-processos.
    ASSIGN tt-processos.nmproces = "DEVOLUCAO DIURNA"
           tt-processos.hrageini = "00:00"
           tt-processos.hragefim = "00:00".

    CREATE tt-processos.
    ASSIGN tt-processos.nmproces = "DEVOLUCAO DOC"
           tt-processos.hrageini = "00:00"
           tt-processos.hragefim = "00:00".

    CREATE tt-processos.
    ASSIGN tt-processos.nmproces = "RELACIONAMENTO"
           tt-processos.hrageini = "00:00"
           tt-processos.hragefim = "00:00".

    CREATE tt-processos.
    ASSIGN tt-processos.nmproces = "CONTRA-ORDEM E CCF"
           tt-processos.hrageini = "00:00"
           tt-processos.hragefim = "00:00".

    CREATE tt-processos.
    ASSIGN tt-processos.nmproces = "DEVOLUCAO NOTURNA"
           tt-processos.hrageini = "00:00"
           tt-processos.hragefim = "00:00".

    CREATE tt-processos.
    ASSIGN tt-processos.nmproces = "IMPORTACAO FAC/ROC"
           tt-processos.hrageini = "00:00"
           tt-processos.hragefim = "00:00".

    CREATE tt-processos.
    ASSIGN tt-processos.nmproces = "ICFJUD"
           tt-processos.hrageini = "00:00"
           tt-processos.hragefim = "00:00".

    CREATE tt-processos.
    ASSIGN tt-processos.nmproces = "IMP CONTRA-ORDEM/CCF"
           tt-processos.hrageini = "00:00"
           tt-processos.hragefim = "00:00".

    CREATE tt-processos.
    ASSIGN tt-processos.nmproces = "TIC604"
           tt-processos.hrageini = "00:00"
           tt-processos.hragefim = "00:00".

    CREATE tt-processos.
    ASSIGN tt-processos.nmproces = "DEBSIC"
           tt-processos.hrageini = "00:00"
           tt-processos.hragefim = "00:00".

    CREATE tt-processos.
    ASSIGN tt-processos.nmproces = "ARQUIVOS NOTURNOS"
           tt-processos.hrageini = "00:00"
           tt-processos.hragefim = "00:00".

    CREATE tt-processos.
    ASSIGN tt-processos.nmproces = "REMCOB"
           tt-processos.hrageini = "00:00"
           tt-processos.hragefim = "00:00".

    CREATE tt-processos.
    ASSIGN tt-processos.nmproces = "DEBNET"
           tt-processos.hrageini = "00:00"
           tt-processos.hragefim = "00:00".


    CREATE tt-processos.
    ASSIGN tt-processos.nmproces = "TAA E INTERNET"
           tt-processos.hrageini = "00:00"
           tt-processos.hragefim = "00:00".
      */

    RETURN "OK".
END PROCEDURE.

PROCEDURE grava_dados:

    DEF INPUT  PARAM par_cdcooper    LIKE crapcop.cdcooper              NO-UNDO.
    DEF INPUT  PARAM par_cdagenci    LIKE crapope.cdagenci              NO-UNDO.
    DEF INPUT  PARAM par_nrdcaixa    AS   INT                           NO-UNDO.
    DEF INPUT  PARAM par_cdoperad    LIKE crapope.cdoperad              NO-UNDO.
    DEF INPUT  PARAM par_nmdatela    AS   CHAR                          NO-UNDO.
    DEF INPUT  PARAM par_cddepart    AS   CHAR                          NO-UNDO.
    DEF INPUT  PARAM par_idorigem    AS   INT                           NO-UNDO.
    DEF INPUT  PARAM par_dtmvtolt    AS   DATE                          NO-UNDO.
    DEF INPUT  PARAM par_cdcoopex    AS   INT                           NO-UNDO.
    DEF INPUT  PARAM par_dsprogra    AS   CHAR                          NO-UNDO.
    DEF INPUT  PARAM par_flgativo    AS   LOGICAL                       NO-UNDO.
    DEF INPUT  PARAM par_ageinihr    AS   INTE                          NO-UNDO.
    DEF INPUT  PARAM par_ageinimm    AS   INTE                          NO-UNDO.
    DEF INPUT  PARAM par_agefimhr    AS   INTE                          NO-UNDO.
    DEF INPUT  PARAM par_agefimmm    AS   INTE                          NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.


    RUN sistema/generico/procedures/b1wgen0183.p
        PERSISTENT SET h-b1wgen0183.
      
    RUN grava_dados IN h-b1wgen0183(INPUT  par_cdcooper,
                                    INPUT  par_cdagenci,
                                    INPUT  par_nrdcaixa,
                                    INPUT  par_cdoperad,
                                    INPUT  par_nmdatela,
                                    INPUT  par_cddepart,
                                    INPUT  par_idorigem,
                                    INPUT  par_dtmvtolt,
                                    INPUT  par_cdcoopex,
                                    INPUT  par_dsprogra,
                                    INPUT  par_flgativo,
                                    INPUT  par_ageinihr,
                                    INPUT  par_ageinimm,
                                    INPUT  par_agefimhr,
                                    INPUT  par_agefimmm,
                                    OUTPUT TABLE tt-erro).
    
    DELETE OBJECT h-b1wgen0183.

    FIND FIRST tt-erro NO-LOCK NO-ERROR.

    IF  AVAIL(tt-erro) THEN
        DO:
            MESSAGE tt-erro.dscritic.
            RETURN "OK".
        END.
    ELSE
        MESSAGE "Registro alterado com sucesso.".

    RETURN "OK".
END PROCEDURE.
