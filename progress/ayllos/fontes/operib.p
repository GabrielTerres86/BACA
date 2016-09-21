/*..............................................................................

   Programa: fontes/operib.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : David
   Data    : Novembro/2008                     Ultima atualizacao: 29/05/2014

   Dados referentes ao programa:

   Frequencia: Diario (On-Line).
   Objetivo  : Mostrar Tela OPERIB. Gerenciamento de operadores do InternetBank.
   
   Alteracoes: 29/05/2014 - Concatena o numero do servidor no endereco do
                            terminal (Tiago-RKAM).

..............................................................................*/

{ includes/var_online.i }
{ sistema/generico/includes/gera_log.i }

DEF STREAM str_1.

DEF VAR rel_nmresemp AS CHAR FORMAT "x(15)"                            NO-UNDO.
DEF VAR rel_nmrelato AS CHAR FORMAT "x(40)" EXTENT 5                   NO-UNDO.
DEF VAR rel_nmmodulo AS CHAR FORMAT "x(15)" EXTENT 5
                             INIT ["DEP. A VISTA   ","CAPITAL        ",
                                   "EMPRESTIMOS    ","DIGITACAO      ",
                                   "GENERICO       "]                  NO-UNDO.

DEF VAR rel_nrmodulo AS INTE FORMAT "9"                                NO-UNDO.
                                     
DEF VAR aux_confirma AS CHAR FORMAT "!(1)"                             NO-UNDO.
DEF VAR aux_cddopcao AS CHAR                                           NO-UNDO.
DEF VAR aux_hrultace AS CHAR                                           NO-UNDO.

DEF VAR aux_contador AS INTE                                           NO-UNDO.
DEF VAR aux_ultlinha AS INTE                                           NO-UNDO.

DEF VAR aux_nrdrowid AS ROWID                                          NO-UNDO.

DEF VAR aux_nmitmpri LIKE crapmni.nmdoitem                             NO-UNDO.

DEF VAR tel_nrdconta LIKE crapopi.nrdconta                             NO-UNDO.
DEF VAR tel_nrcpfope LIKE crapopi.nrcpfope                             NO-UNDO.

DEF VAR tel_nmprimtl AS CHAR                                           NO-UNDO.
DEF VAR tel_operador AS CHAR                                           NO-UNDO.

DEF VAR tel_flgimpre AS LOGI                                           NO-UNDO.

/** Variaveis para impressao on-line **/
DEF VAR aux_flgescra AS LOGI                                           NO-UNDO.

DEF VAR aux_nmendter AS CHAR FORMAT "x(20)"                            NO-UNDO.
DEF VAR aux_dscomand AS CHAR                                           NO-UNDO.
DEF VAR aux_nmarqimp AS CHAR FORMAT "x(40)"                            NO-UNDO.

DEF VAR tel_dsimprim AS CHAR FORMAT "x(8)" INIT "Imprimir"             NO-UNDO.
DEF VAR tel_dscancel AS CHAR FORMAT "x(8)" INIT "Cancelar"             NO-UNDO.

DEF VAR par_flgfirst AS LOGI INIT TRUE                                 NO-UNDO.
DEF VAR par_flgcance AS LOGI                                           NO-UNDO.
DEF VAR par_flgrodar AS LOGI INIT TRUE                                 NO-UNDO.

DEF VAR tel_dsrelato AS CHAR VIEW-AS EDITOR SIZE 250 BY 15 PFCOLOR 0   NO-UNDO.

DEF BUFFER crabmni FOR crapmni.
DEF BUFFER crabopi FOR crapopi.

DEF TEMP-TABLE w_permis                                                NO-UNDO
    FIELD nrcpfope LIKE crapopi.nrcpfope
    FIELD nmoperad LIKE crapopi.nmoperad
    FIELD flgsitop LIKE crapopi.flgsitop
    FIELD cditemmn LIKE crapmni.cditemmn
    FIELD cdsubitm LIKE crapmni.cdsubitm
    FIELD nmdoitem LIKE crapmni.nmdoitem
    FIELD nmitmpri LIKE crapmni.nmdoitem
    FIELD flgacebl LIKE crapaci.flgacebl.
    
DEF QUERY q_crapopi       FOR crapopi.
DEF QUERY q_zoom_operador FOR crapopi.
DEF QUERY q_itens         FOR w_permis.
    
DEF BROWSE b_crapopi QUERY q_crapopi
    DISP crapopi.nrcpfope COLUMN-LABEL "CPF"      FORMAT "999,999,999,99"
         crapopi.nmoperad COLUMN-LABEL "Nome"     FORMAT "x(45)"
         crapopi.flgsitop COLUMN-LABEL "Situacao" FORMAT "Liberado/Bloqueado" 
         WITH NO-BOX 7 DOWN.
                        
DEF BROWSE b_zoom_operador QUERY q_zoom_operador
    DISP crapopi.nrcpfope COLUMN-LABEL "CPF"      FORMAT "999,999,999,99"
         crapopi.nmoperad COLUMN-LABEL "Nome"     FORMAT "x(40)"
         WITH NO-BOX 8 DOWN.

DEF BROWSE b_itens QUERY q_itens
    DISP w_permis.nmdoitem COLUMN-LABEL "Item do Menu"   FORMAT "x(29)"
         w_permis.nmitmpri COLUMN-LABEL "Item Principal" FORMAT "x(29)"
         SPACE(1)
         w_permis.flgacebl COLUMN-LABEL "Situacao" FORMAT "Liberado/Bloqueado"
         WITH NO-BOX 8 DOWN.
            
FORM 
    WITH NO-LABEL TITLE COLOR MESSAGE glb_tldatela
    ROW 4 COLUMN 1 OVERLAY SIZE 80 BY 18 FRAME f_moldura.

FORM 
    glb_cddopcao AT 03 LABEL "Opcao"        FORMAT "!(1)"
                 HELP "Informe a opcao (C,B,R)."
                 VALIDATE (CAN-DO("C,B,R",glb_cddopcao),"014 - Opcao Errada")
    tel_nrdconta AT 14 LABEL "Conta/dv"     FORMAT "zzzz,zzz,9"
                 HELP "Informe a conta/dv"
                 VALIDATE(CAN-FIND(crapass WHERE
                                   crapass.cdcooper = glb_cdcooper AND
                                   crapass.nrdconta = tel_nrdconta),
                          "009 - Associado nao cadastrado.")         
    tel_nmprimtl AT 35 NO-LABEL             FORMAT "x(43)"
    WITH NO-LABEL SIDE-LABELS COLUMN 2 ROW 6 OVERLAY NO-BOX FRAME f_opcao.
                 
FORM
    SKIP(1)
    tel_operador AT 03 LABEL "Operador" FORMAT "x(57)"
    WITH NO-LABEL SIDE-LABELS CENTERED ROW 7 OVERLAY NO-BOX SIZE 78 BY 14
         FRAME f_operador.
         
FORM
    tel_nrcpfope LABEL "    CPF Operador" FORMAT "999,999,999,99"
        HELP "Informe o CPF do operador, <F7> para listar, 0 para todos"
    SKIP
    tel_flgimpre LABEL "Formato de Saida" FORMAT "Terminal/Impressora"
        HELP "Informe o formato de saida (Terminal/Impressora)"
    WITH NO-LABEL SIDE-LABELS CENTERED ROW 12 OVERLAY NO-BOX FRAME f_relatorio.
              
FORM 
    tel_dsrelato 
    HELP "Use as setas para navegar ou <END> para voltar." 
    WITH SIZE 76 BY 15 ROW 6 COLUMN 3 USE-TEXT NO-BOX NO-LABELS OVERLAY
         FRAME f_rel_terminal.
    
FORM 
    b_crapopi                                         
    WITH ROW 7 OVERLAY CENTERED FRAME f_crapopi.
    
FORM 
    b_zoom_operador 
    HELP "Setas para navegar, <ENTER> para selecionar, <END>/<F4> para sair."
    WITH ROW 8 OVERLAY CENTERED TITLE "OPERADORES" FRAME f_zoom_operador.

FORM 
    b_itens 
    HELP "Use as setas para navegar ou <END> para voltar."
    WITH ROW 9 OVERLAY CENTERED FRAME f_itens.    

FORM
    crapopi.dtultalt AT 03 LABEL "Ultima Alteracao"    FORMAT "99/99/9999"
    crapopi.dtultace AT 47 LABEL "Data Ultimo Acesso"  FORMAT "99/99/9999"
    SKIP
    crapopi.dsdcargo AT 03 LABEL "           Cargo"    FORMAT "x(20)"
    aux_hrultace     AT 47 LABEL "Hora Ultimo Acesso"  FORMAT "x(8)"
    crapopi.dsdemail AT 03 LABEL "          E-Mail"    FORMAT "x(40)"
    WITH ROW 18 COLUMN 2 OVERLAY NO-BOX SIDE-LABELS FRAME f_detalhes.
    
FORM
    SKIP(1)
    tel_nrdconta      LABEL "Conta/dv" FORMAT "zzzz,zzz,9"
    tel_nmprimtl      NO-LABEL         FORMAT "x(43)"
    WITH PAGE-TOP NO-BOX NO-LABEL SIDE-LABELS WIDTH 80 FRAME f_cab_conta.
    
FORM 
    SKIP(1)
    w_permis.nrcpfope LABEL "Operador" FORMAT "999,999,999,99"
    "-"
    w_permis.nmoperad NO-LABEL         FORMAT "x(33)"
    w_permis.flgsitop LABEL "Situacao" FORMAT "LIBERADO/BLOQUEADO"
    SKIP(1)
    WITH NO-BOX NO-LABEL SIDE-LABELS WIDTH 80 FRAME f_cab_operador.
    
FORM 
    w_permis.nmdoitem LABEL "Item"            FORMAT "x(25)"
    w_permis.nmitmpri LABEL "Sub-Item"        FORMAT "x(25)"
    w_permis.flgacebl LABEL "Situacao Acesso" FORMAT "Liberado/Bloqueado" 
    WITH NO-BOX NO-LABEL DOWN WIDTH 80 FRAME f_rel_permissoes.
    
ON VALUE-CHANGED, ENTRY OF b_crapopi DO:

    ASSIGN aux_hrultace = STRING(crapopi.hrultace,"HH:MM:SS").
    
    DISPLAY crapopi.dtultace aux_hrultace crapopi.dtultalt crapopi.dsdcargo 
            crapopi.dsdemail WITH FRAME f_detalhes.

END.

ON RETURN OF b_zoom_operador DO:

    HIDE MESSAGE NO-PAUSE.
    
    ASSIGN tel_nrcpfope = crapopi.nrcpfope.
           
    DISPLAY tel_nrcpfope WITH FRAME f_relatorio.
           
    APPLY "GO".
    
END.

ON RETURN OF b_crapopi DO:

    HIDE MESSAGE NO-PAUSE.
    
    IF  glb_cddopcao = "C"  THEN
        DO:
            RUN obtem-permissoes (INPUT crapopi.nrcpfope).
            
            OPEN QUERY q_itens FOR EACH w_permis NO-LOCK
                                   BY w_permis.cditemmn BY w_permis.cdsubitm.
            
            IF  QUERY q_itens:NUM-RESULTS = 0  THEN
                DO:
                    BELL.
                    MESSAGE "Nenhuma permissao foi cadastrada.".
                    
                    CLOSE QUERY q_itens.
                    
                    RETURN.
                END.

            ASSIGN tel_operador = STRING(STRING(crapopi.nrcpfope,"99999999999"),
                                  "xxx.xxx.xxx-xx") + " - " + crapopi.nmoperad.

            DISPLAY tel_operador WITH FRAME f_operador.
            
            PAUSE(0).
            
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
            
                UPDATE b_itens WITH FRAME f_itens.
                
                LEAVE.
                
            END.

            CLOSE QUERY q_itens.
            
            HIDE FRAME f_operador NO-PAUSE.
            HIDE FRAME f_itens    NO-PAUSE.
        END.
    ELSE
    IF  glb_cddopcao = "B"  THEN
        DO:
            DO TRANSACTION:
                
                DO aux_contador = 1 TO 10:
                 
                    MESSAGE "Aguarde ...".
                    
                    ASSIGN glb_dscritic = "".
                    
                    FIND CURRENT crapopi EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                    
                    IF  NOT AVAILABLE crapopi  THEN
                        DO:
                            IF  LOCKED crapopi  THEN
                                DO:
                                    glb_dscritic = "Registro do operador ja " +
                                                   "esta sendo alterado.".
                                    PAUSE 1 NO-MESSAGE.
                                    NEXT.               
                                END.
                            ELSE    
                                glb_dscritic = "Operador nao cadastrado.".
                        END.

                    LEAVE.

                END. /** Fim do DO .. TO **/
    
                HIDE MESSAGE NO-PAUSE.
                
                IF  glb_dscritic <> ""  THEN
                    DO:
                        BELL.
                        MESSAGE glb_dscritic.
                        
                        UNDO, RETURN.
                    END.

                ASSIGN aux_confirma = "N".
            
                DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
            
                    BELL.
                    MESSAGE "Confirma bloqueio do operador? (S/N):" 
                            UPDATE aux_confirma.
                
                    LEAVE.

                END.

                IF  aux_confirma <> "S"                  OR
                    KEY-FUNCTION(LASTKEY) = "END-ERROR"  THEN
                    DO:
                        ASSIGN glb_cdcritic = 79.
                        RUN fontes/critic.p.
                        ASSIGN glb_cdcritic = 0.
                    
                        BELL.
                        MESSAGE glb_dscritic.
                    
                        UNDO, RETURN.
                    END.
                    
                ASSIGN crapopi.flgsitop = FALSE
                       crapopi.dtultalt = glb_dtmvtolt.

                RUN proc_gerar_log (INPUT glb_cdcooper,
                                    INPUT glb_cdoperad,
                                    INPUT "",
                                    INPUT "AYLLOS",
                                    INPUT "Bloqueio de Operador da Conta " +
                                          "On-Line",
                                    INPUT TRUE,
                                    INPUT 1,
                                    INPUT glb_nmdatela,
                                    INPUT tel_nrdconta,
                                   OUTPUT aux_nrdrowid).
                                   
                RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                         INPUT "CPF Operador",
                                         INPUT "",
                                         INPUT STRING(STRING(crapopi.nrcpfope,
                                                      "99999999999"),
                                                      "xxx.xxx.xxx-xx")). 

                RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                         INPUT "Nome Operador",
                                         INPUT "",
                                         INPUT crapopi.nmoperad).

            END. /** Fim do DO TRANSACTION **/    
        
            ASSIGN aux_ultlinha = CURRENT-RESULT-ROW("q_crapopi").
            
            CLOSE QUERY q_crapopi.
            
            OPEN QUERY q_crapopi FOR EACH crapopi WHERE 
                                          crapopi.cdcooper = glb_cdcooper AND
                                          crapopi.nrdconta = tel_nrdconta 
                                          NO-LOCK BY crapopi.nmoperad.

            REPOSITION q_crapopi TO ROW aux_ultlinha.
        END.

END.

VIEW FRAME f_moldura.

PAUSE(0).

ASSIGN glb_cddopcao    = "C"
       glb_cdempres    = 11
       glb_cdrelato[1] = 498
       glb_nrdevias    = 1
       glb_nmformul    = "80col".

DO WHILE TRUE:

    RUN fontes/inicia.p.
    
    ASSIGN tel_nrdconta = 0
           tel_nmprimtl = "".
           
    DISPLAY glb_cddopcao tel_nrdconta tel_nmprimtl WITH FRAME f_opcao.       
    
    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
        
        UPDATE glb_cddopcao tel_nrdconta WITH FRAME f_opcao.
    
        LEAVE.
    
    END.
    
    IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
        DO:
            RUN fontes/novatela.p.
            
            IF  CAPS(glb_nmdatela) <> "OPERIB"  THEN
                DO:
                    HIDE FRAME f_moldura NO-PAUSE.
                    HIDE FRAME f_opcao   NO-PAUSE.
        
                    RETURN.
                END.
            ELSE
                NEXT.
        END.

    IF  aux_cddopcao <> INPUT glb_cddopcao  THEN
        DO:
            { includes/acesso.i }

            ASSIGN aux_cddopcao = INPUT glb_cddopcao.
        END.
        
    FIND crapass WHERE crapass.cdcooper = glb_cdcooper AND
                       crapass.nrdconta = tel_nrdconta NO-LOCK NO-ERROR.

    IF  NOT AVAILABLE crapass  THEN
        DO:
            ASSIGN glb_cdcritic = 9.
            RUN fontes/critic.p.
            ASSIGN glb_cdcritic = 0.
            
            BELL.
            MESSAGE glb_dscritic.
            
            NEXT.
        END.

    ASSIGN tel_nmprimtl = "- " + crapass.nmprimtl.
    
    DISPLAY tel_nmprimtl WITH FRAME f_opcao.
                                       
    IF  CAN-DO("C,B",glb_cddopcao)  THEN
        DO:
            IF  glb_cddopcao = "C"  THEN
                OPEN QUERY q_crapopi 
                     FOR EACH crapopi WHERE crapopi.cdcooper = glb_cdcooper AND
                                            crapopi.nrdconta = tel_nrdconta 
                                            NO-LOCK BY crapopi.nmoperad.
            ELSE
                OPEN QUERY q_crapopi
                     FOR EACH crapopi WHERE crapopi.cdcooper = glb_cdcooper AND
                                            crapopi.nrdconta = tel_nrdconta AND
                                            crapopi.flgsitop = TRUE
                                            NO-LOCK BY crapopi.nmoperad.
                                              
            IF  QUERY q_crapopi:NUM-RESULTS = 0  THEN
                DO:
                    BELL.
                    MESSAGE "Nenhum operador foi cadastrado.".
                    
                    CLOSE QUERY q_crapopi.
                    
                    NEXT.
                END.
                
            IF  glb_cddopcao = "C"  THEN
                b_crapopi:HELP = "Setas para navegar, <ENTER> para permissoes" +
                                 ", <END> para sair.".
            ELSE
            IF  glb_cddopcao = "B"  THEN
                b_crapopi:HELP = "Setas para navegar, <ENTER> bloquear, " +
                                 "<END> para sair.".
                                                    
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
           
                UPDATE b_crapopi WITH FRAME f_crapopi.
                
                LEAVE.

            END.

            CLOSE QUERY q_crapopi.
        
            HIDE FRAME f_crapopi  NO-PAUSE.
            HIDE FRAME f_detalhes NO-PAUSE.
        END.
    ELSE
    IF  glb_cddopcao = "R"  THEN
        DO:
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
            
                FIND FIRST crapopi WHERE crapopi.cdcooper = glb_cdcooper AND
                                         crapopi.nrdconta = tel_nrdconta
                                         NO-LOCK NO-ERROR.
                                     
                IF  NOT AVAILABLE crapopi  THEN
                    DO:
                        BELL.
                        MESSAGE "Nenhum operador foi cadastrado.".

                        LEAVE.
                    END.
                
                ASSIGN tel_nrcpfope = 0
                       tel_flgimpre = TRUE.
            
                DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
            
                    UPDATE tel_nrcpfope tel_flgimpre WITH FRAME f_relatorio
                
                    EDITING:
                
                        READKEY.
                    
                        IF  FRAME-FIELD = "tel_nrcpfope"  AND
                            LASTKEY = KEYCODE("F7")       THEN
                            DO:
                                OPEN QUERY q_zoom_operador 
                                  FOR EACH crapopi WHERE
                                           crapopi.cdcooper = glb_cdcooper AND
                                           crapopi.nrdconta = tel_nrdconta
                                           NO-LOCK BY crapopi.nmoperad.
     
                                DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                             
                                    UPDATE b_zoom_operador 
                                           WITH FRAME f_zoom_operador.
                        
                                    LEAVE.
                            
                                END. /** Fim do DO WHILE TRUE **/
                        
                                CLOSE QUERY q_zoom_operador.
                            
                                HIDE FRAME f_zoom_operador NO-PAUSE.
                            END.
                        ELSE
                            APPLY LASTKEY.
                  
                    END. /** Fim do EDITING **/

                    IF  tel_nrcpfope > 0  THEN
                        DO:
                            FIND crapopi WHERE 
                                 crapopi.cdcooper = glb_cdcooper AND
                                 crapopi.nrdconta = tel_nrdconta AND
                                 crapopi.nrcpfope = tel_nrcpfope
                                 NO-LOCK NO-ERROR.
                                           
                            IF  NOT AVAILABLE crapopi  THEN
                                DO:
                                    BELL.
                                    MESSAGE "Operador nao cadastrado.".
                                                    
                                    NEXT.                
                                END.
                        END.
                    
                    LEAVE.
            
                END. /** Fim do DO WHILE TRUE **/
            
                IF  KEY-FUNCTION(LASTKEY) = "END-ERROR"  THEN
                    LEAVE.
                
                RUN obtem-permissoes (INPUT tel_nrcpfope).
        
                FIND FIRST w_permis NO-LOCK NO-ERROR.
            
                IF  NOT AVAILABLE w_permis  THEN
                    DO:
                        BELL.
                        MESSAGE "Nenhuma permissao foi cadastrada".
                    
                        LEAVE.
                    END.
                
                RUN efetua-impressao. 
            
            END. /** Fim do DO WHILE TRUE **/
            
            HIDE FRAME f_relatorio NO-PAUSE.
        END.
    
END. /** Fim do DO WHILE TRUE **/

PROCEDURE obtem-permissoes:

    DEF  INPUT PARAM par_nrcpfope LIKE crapopi.nrcpfope             NO-UNDO.

    EMPTY TEMP-TABLE w_permis.
    
    FOR EACH crabopi WHERE (crabopi.cdcooper = glb_cdcooper AND
                            crabopi.nrdconta = tel_nrdconta AND 
                            crabopi.nrcpfope = par_nrcpfope AND
                            par_nrcpfope     > 0)           OR
                           (crabopi.cdcooper = glb_cdcooper AND
                            crabopi.nrdconta = tel_nrdconta AND
                            par_nrcpfope     = 0)           NO-LOCK,
        EACH crapaci WHERE crapaci.cdcooper = glb_cdcooper     AND
                           crapaci.nrdconta = tel_nrdconta     AND
                           crapaci.nrcpfope = crabopi.nrcpfope NO-LOCK,
            FIRST crapmni WHERE crapmni.cdcooper = glb_cdcooper     AND
                                crapmni.cditemmn = crapaci.cditemm  AND
                                crapmni.cdsubitm = crapaci.cdsubitm NO-LOCK:
                            
        ASSIGN aux_nmitmpri = "".
        
        IF  crapaci.cdsubitm > 0  THEN
            DO:
                FIND crabmni WHERE crabmni.cdcooper = glb_cdcooper     AND
                                   crabmni.cditemmn = crapaci.cditemmn AND
                                   crabmni.cdsubitm = 0
                                   NO-LOCK NO-ERROR.
            
                IF  AVAILABLE crabmni  THEN
                    ASSIGN aux_nmitmpri = crabmni.nmdoitem.
            END.
        
        CREATE w_permis.
        ASSIGN w_permis.nrcpfope = crabopi.nrcpfope
               w_permis.nmoperad = crabopi.nmoperad
               w_permis.cditemmn = crapaci.cditemmn
               w_permis.cdsubitm = crapaci.cdsubitm
               w_permis.nmdoitem = crapmni.nmdoitem
               w_permis.nmitmpri = aux_nmitmpri
               w_permis.flgacebl = crapaci.flgacebl.
    
    END. /** Fim do FOR EACH crapaci **/                       

END PROCEDURE.

PROCEDURE efetua-impressao:

    MESSAGE "Aguarde ...".    

    /** Gerenciamento da impressao **/
    INPUT THROUGH basename `tty` NO-ECHO.

    SET aux_nmendter WITH FRAME f_terminal.

    INPUT CLOSE.
    
    aux_nmendter = substr(glb_hostname,length(glb_hostname) - 1) +
                          aux_nmendter.

    ASSIGN aux_nmarqimp = "rl/O498_" + STRING(TIME,"99999") + ".lst".
            
    { includes/cabrel080_1.i }
            
    IF  tel_flgimpre  THEN
        OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp).
    ELSE
        DO:
            OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGE-SIZE 80.

            VIEW STREAM str_1 FRAME f_cabrel080_1.

            DISPLAY STREAM str_1 tel_nrdconta tel_nmprimtl
                                 WITH FRAME f_cab_conta.
        END.
            
    FOR EACH w_permis NO-LOCK BREAK BY w_permis.nrcpfope
                                       BY w_permis.cditemmn 
                                          BY w_permis.cdsubitm:
            
        IF  FIRST-OF(w_permis.nrcpfope)  THEN
            DO:
                IF (LINE-COUNTER(str_1) + 5) > PAGE-SIZE(str_1)  AND
                    NOT tel_flgimpre                             THEN
                    PAGE STREAM str_1.
                
                DISPLAY STREAM str_1 w_permis.nrcpfope
                                     w_permis.nmoperad
                                     w_permis.flgsitop
                                     WITH FRAME f_cab_operador.
            END.
            
        IF (LINE-COUNTER(str_1) + 1) > PAGE-SIZE(str_1)  AND
            NOT tel_flgimpre                             THEN
            DO:
                PAGE STREAM str_1.
                
                DISPLAY STREAM str_1 w_permis.nrcpfope
                                     w_permis.nmoperad
                                     w_permis.flgsitop
                                     WITH FRAME f_cab_operador.
            END.
                    
        IF  w_permis.cdsubitm = 0  THEN
            DO:
                DISPLAY STREAM str_1 w_permis.nmdoitem
                                     w_permis.flgacebl
                                     WITH FRAME f_rel_permissoes.

                DOWN STREAM str_1 WITH FRAME f_rel_permissoes.
            END.
        ELSE
            DO:
                DISPLAY STREAM str_1 w_permis.nmdoitem @ w_permis.nmitmpri
                                     w_permis.flgacebl
                                     WITH FRAME f_rel_permissoes.

                DOWN STREAM str_1 WITH FRAME f_rel_permissoes.
            END.
                    
        IF (LINE-COUNTER(str_1) + 1) > PAGE-SIZE(str_1)  AND
            NOT tel_flgimpre                        THEN
            DO:
                PAGE STREAM str_1.
                        
                DISPLAY STREAM str_1 w_permis.nrcpfope
                                     w_permis.nmoperad
                                     w_permis.flgsitop
                                     WITH FRAME f_cab_operador.    
            END.
            
        IF  LAST-OF(w_permis.cditemmn)  THEN
            DOWN 1 STREAM str_1 WITH FRAME f_rel_permissoes.
    
    END. /** Fim do FOR w_permis **/
                
    OUTPUT STREAM str_1 CLOSE.
            
    HIDE MESSAGE NO-PAUSE.

    IF  tel_flgimpre  THEN
        DO:
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                                                                               
                ENABLE tel_dsrelato WITH FRAME f_rel_terminal.

                tel_dsrelato:READ-ONLY IN FRAME f_rel_terminal = YES.
                tel_dsrelato:INSERT-FILE(aux_nmarqimp).
                tel_dsrelato:CURSOR-LINE IN FRAME f_rel_terminal = 1.

                WAIT-FOR GO OF tel_dsrelato IN FRAME f_rel_terminal. 
  
            END.

            tel_dsrelato:SCREEN-VALUE = "".
                    
            HIDE FRAME f_rel_terminal NO-PAUSE.
        END.
    ELSE
        DO:
            { includes/impressao.i }
        END.
            
    HIDE FRAME f_relatorio NO-PAUSE.

END PROCEDURE.

/*............................................................................*/
