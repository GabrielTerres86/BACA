/*.............................................................................

   Programa: Fontes/parlav.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : HENRIQUE
   Data    : MAIO/2011                          Ultima Atualizacao:

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Controle de Registros cadastrados no COAF.
..............................................................................*/

{ includes/var_online.i }

DEF TEMP-TABLE tt-crapcld NO-UNDO
    FIELD cdcooper LIKE crapcld.cdcooper
    FIELD dscooper AS   CHAR                COLUMN-LABEL "Cooperativa"
    FIELD dtmvtolt LIKE crapcld.dtmvtolt
    FIELD cdagenci LIKE crapcld.cdagenci
    FIELD nrdconta LIKE crapcld.nrdconta
    FIELD vlrendim LIKE crapcld.vlrendim    COLUMN-LABEL "Rendimento"
    FIELD vltotcre LIKE crapcld.vltotcre    COLUMN-LABEL "Credito"
    FIELD cddjusti LIKE crapcld.cddjusti
    FIELD dsdjusti LIKE crapcld.dsdjusti
    FIELD dsobserv LIKE crapcld.dsobserv
    FIELD nrdrowid AS ROWID. 
    
DEF QUERY q-crapcld FOR tt-crapcld.

DEF BROWSE b-crapcld QUERY q-crapcld
    DISP tt-crapcld.dscooper FORMAT "x(16)"
         tt-crapcld.dtmvtolt
         tt-crapcld.cdagenci
         tt-crapcld.nrdconta
         tt-crapcld.vlrendim
         tt-crapcld.vltotcre                  
    WITH 07 DOWN NO-BOX.
    
DEF VAR aux_contador AS  INTE                                           NO-UNDO.
DEF VAR aux_confirma AS  CHAR   FORMAT "(!)"                            NO-UNDO.
DEF VAR aux_fldeerro AS  LOGICAL                                        NO-UNDO.

DEF VAR tel_cddjusti AS  INTE                                           NO-UNDO.
DEF VAR tel_dsdjusti AS  CHAR                                           NO-UNDO.
DEF VAR tel_dsobserv AS  CHAR                                           NO-UNDO.

FORM SPACE (1)
     WITH ROW 4 OVERLAY 16 DOWN WIDTH 80 
     TITLE " Controle de Registros cadastrados no COAF  " FRAME f_moldura.

FORM SKIP 
     glb_cddopcao LABEL "Opcao" AUTO-RETURN
        HELP "(C - Consulta, F - Fechamento, T - Atualiza Todos)"
        VALIDATE (CAN-DO("C,F,T",glb_cddopcao),"014 - Opcao Errada.") AT 3
     WITH ROW 5 COLUMN 2 NO-BOX SIDE-LABELS OVERLAY FRAME f_rgcoaf.

FORM b-crapcld
     WITH  ROW 6 OVERLAY WIDTH 78 CENTERED FRAME f_browse.
     
FORM "Justificativa:" tel_cddjusti          FORMAT "z9"
      " - "  tel_dsdjusti                   FORMAT "x(55)"
     SKIP
     "   Observacao:" tel_dsobserv          FORMAT "x(60)"
     WITH OVERLAY ROW 18 COLUMN 2 NO-BOX NO-LABEL FRAME f_detalhes.

ON "ENTRY" OF b-crapcld DO:
    APPLY "VALUE-CHANGED" TO b-crapcld.
END.

ON "RETURN" OF b-crapcld DO:

    IF  glb_cddopcao = "F" THEN
        DO:
            FIND crapfld WHERE crapfld.cdcooper = tt-crapcld.cdcooper
                           AND crapfld.dtmvtolt = tt-crapcld.dtmvtolt
                           AND crapfld.cdtipcld = 1 /* DIARIO COOP */
                           NO-LOCK NO-ERROR.

            IF  NOT AVAIL crapfld THEN
                DO:
                    MESSAGE "Fechamento nao realizado pela cooperativa.".
                END.
            ELSE
                DO:
                    IF  crapfld.dtdenvcf = ? THEN
                        DO:
                            MESSAGE "Registro em analise pela cooperativa.".
                        END.
                    ELSE
                    DO:
                        RUN fontes/confirma.p (INPUT  "",
                                               OUTPUT aux_confirma).
                        
                        IF aux_confirma = "S" THEN
                        DO:
                            FIND crapcld WHERE 
                                 ROWID(crapcld) = tt-crapcld.nrdrowid
                                 EXCLUSIVE-LOCK NO-ERROR.
                            
                            IF  AVAIL crapcld THEN
                                DO:
                                    ASSIGN crapcld.infrepcf = 2.
                                    DELETE tt-crapcld.
                            
                                    DISP "" @ tel_cddjusti  
                                         "" @ tel_dsdjusti
                                         "" @ tel_dsobserv
                                         WITH FRAME f_detalhes.
                            
                                    b-crapcld:REFRESH().
                                END.
                        END.
                END.
            END.
        END.  /* FIM OPCAO F */
    ELSE
    IF  glb_cddopcao = "T" THEN
        DO:
            ASSIGN aux_fldeerro = FALSE.

            RUN fontes/confirma.p (INPUT  "Deseja atualizar todos os registros?",
                                   OUTPUT aux_confirma).

            IF  aux_confirma = "S" THEN
                DO:
                    FOR EACH tt-crapcld EXCLUSIVE-LOCK:
                    
                        FIND crapfld WHERE crapfld.cdcooper = tt-crapcld.cdcooper
                                       AND crapfld.dtmvtolt = tt-crapcld.dtmvtolt
                                       AND crapfld.cdtipcld = 1 /* DIARIO COOP */
                                       NO-LOCK NO-ERROR.
                        
                        IF  NOT AVAIL crapfld THEN
                            DO:
                                MESSAGE "Fechamento nao realizado " +
                                        "pela cooperativa.".
                            END.
                        ELSE
                            DO:
                                IF  crapfld.dtdenvcf = ? THEN
                                    DO:
                                        ASSIGN aux_fldeerro = TRUE.
                                    END.
                                ELSE
                                    DO:
                                    
                                        FIND crapcld WHERE 
                                            ROWID(crapcld) = tt-crapcld.nrdrowid 
                                            EXCLUSIVE-LOCK NO-ERROR.
                    
                                        IF  AVAIL crapcld THEN
                                            DO:
                                                ASSIGN crapcld.infrepcf = 2.
                                                DELETE tt-crapcld.
                                            END.
                                    END.
                            END.
                    END.

                    IF  aux_fldeerro THEN
                        MESSAGE "Existem registros que nao puderam ser "
                                + "atualizados. Verifique a opcao C".
                    ELSE
                        MESSAGE "Todos os registros foram atualizados.".

                    APPLY "GO" TO b-crapcld.

                END.
            ELSE
                DO:
                    APPLY "GO" TO b-crapcld.
                END.
                
        END. /* FIM OPCAO T */
END. /* FIM ON RETURN */

ON "VALUE-CHANGED" OF b-crapcld DO:
    ASSIGN tel_cddjusti = tt-crapcld.cddjusti
           tel_dsdjusti = tt-crapcld.dsdjusti
           tel_dsobserv = tt-crapcld.dsobserv.
    

    DISP tel_cddjusti  
         tel_dsdjusti
         tel_dsobserv
         WITH FRAME f_detalhes.
END.

VIEW FRAME f_moldura.
PAUSE(0).
VIEW FRAME f_rgcoaf.
PAUSE(0).

ASSIGN glb_cddopcao = "C".

DO WHILE TRUE:

    RUN fontes/inicia.p.

    DO WHILE TRUE ON ENDKEY UNDO,LEAVE:

        UPDATE glb_cddopcao WITH FRAME f_rgcoaf.

        { includes/acesso.i }

        LEAVE.

    END.

    IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN     /*   F4 OU FIM   */
        DO:
           RUN fontes/novatela.p.
           IF  CAPS(glb_nmdatela) <> "RGCOAF"  THEN
               DO:
                  HIDE FRAME f_rgcoaf.
                  HIDE FRAME f_browse.
                  HIDE FRAME f_moldura.
                  HIDE FRAME f_detalhes.
                  RETURN.
               END.
        END.

    IF  glb_cddopcao = "C" THEN
        DO:
            b-crapcld:HELP = "Tecle <F4> para sair.".
        END.
    ELSE
    IF  glb_cddopcao = "F" THEN
        DO:
            b-crapcld:HELP = "Tecle ENTER para selecionar o registro" + 
                             " e <F4> para sair.".
        END.
    ELSE
    IF  glb_cddopcao = "T" THEN
        DO:
            b-crapcld:HELP = "Tecle ENTER para atualizar todos os registros" + 
                             " e <F4> para sair.".
        END.

    RUN carrega-dados.
    
    HIDE FRAME f_detalhes NO-PAUSE.
    HIDE FRAME f_browse NO-PAUSE. 
    

END. /* FIM DO WHILE TRUE */

PROCEDURE carrega-dados:

    CLOSE QUERY q-crapcld.
    EMPTY TEMP-TABLE tt-crapcld.
    
    FOR EACH crapcld WHERE crapcld.infrepcf = 1 NO-LOCK.

        FIND crapcop WHERE crapcop.cdcooper = crapcld.cdcooper NO-LOCK NO-ERROR.

        CREATE tt-crapcld.
        ASSIGN tt-crapcld.cdcooper = crapcld.cdcooper
               tt-crapcld.dscooper = STRING(crapcld.cdcooper) + " - " +
                                     crapcop.nmrescop
               tt-crapcld.dtmvtolt = crapcld.dtmvtolt
               tt-crapcld.cdagenci = crapcld.cdagenci
               tt-crapcld.nrdconta = crapcld.nrdconta
               tt-crapcld.vlrendim = crapcld.vlrendim
               tt-crapcld.vltotcre = crapcld.vltotcre 
               tt-crapcld.cddjusti = crapcld.cddjusti
               tt-crapcld.dsdjusti = crapcld.dsdjusti
               tt-crapcld.dsobserv = crapcld.dsobserv
               tt-crapcld.nrdrowid = ROWID(crapcld).
    END.

    FIND FIRST tt-crapcld NO-LOCK NO-ERROR.

    IF  AVAIL tt-crapcld THEN
        DO:
            OPEN QUERY q-crapcld FOR EACH tt-crapcld.

            UPDATE b-crapcld WITH FRAME f_browse.
        END.
    ELSE
        MESSAGE "Nao existem lancamentos a serem listados.".
    

END PROCEDURE. /* FIM carrega-dados */
