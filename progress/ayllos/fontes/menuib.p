/*..............................................................................

   Programa: fontes/menuib.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : David
   Data    : Novembro/2008                     Ultima atualizacao: 05/12/2016

   Dados referentes ao programa:

   Frequencia: Diario (On-Line).
   Objetivo  : Mostrar Tela MENUIB. Gerenciamento de menu do InternetBank.
   
   Alteracoes: 25/05/2009 - Alteracao CDOPERAD (Kbase).
   
               29/09/2011 - Adicionado opcao de Dispon. Operador (Jorge).
               
               16/12/2013 - Inclusao de VALIDATE crapmni (Carlos)

               05/12/2016 - Alterado campo dsdepart para cddepart.
                            PRJ341 - BANCENJUD (Odirlei-AMcom)

..............................................................................*/

{ includes/var_online.i }

DEF TEMP-TABLE cratmni                                                  NO-UNDO
    FIELD cditemmn AS INTE
    FIELD nmitmpri AS CHAR                   
    FIELD cdsubitm AS INTE
    FIELD nmdoitem AS CHAR
    FIELD dsurlace AS CHAR
    FIELD flgitmbl AS LOGI
    FIELD nrorditm AS INTE
    FIELD dstipitm AS CHAR
    FIELD flgopepj AS LOGI.    

DEF BUFFER crabmni FOR crapmni.

DEF VAR aux_confirma AS CHAR FORMAT "!(1)"                             NO-UNDO.
DEF VAR aux_cddopcao AS CHAR                                           NO-UNDO.
DEF VAR aux_nmitmpri AS CHAR                                           NO-UNDO.

DEF VAR aux_cditemmn AS INTE                                           NO-UNDO.
DEF VAR aux_cdsubitm AS INTE                                           NO-UNDO.
DEF VAR aux_contador AS INTE                                           NO-UNDO.
DEF VAR aux_ultlinha AS INTE                                           NO-UNDO.

DEF VAR tel_nmitmpri AS CHAR                                           NO-UNDO.

DEF VAR tel_flgitmbl AS LOGI                                           NO-UNDO.
DEF VAR tel_fltipitm AS LOGI                                           NO-UNDO.
DEF VAR tel_flgopepj AS LOGI                                           NO-UNDO.

DEF VAR tel_nmdoitem AS CHAR                                           NO-UNDO.
DEF VAR tel_dsurlac1 AS CHAR                                           NO-UNDO.
DEF VAR tel_dsurlac2 AS CHAR                                           NO-UNDO.

DEF VAR tel_cditmpri AS INTE                                           NO-UNDO.
DEF VAR tel_nrorditm AS INTE                                           NO-UNDO.
DEF VAR tel_intipitm AS INTE                                           NO-UNDO.

DEF QUERY q_zoom_item FOR crapmni.
DEF QUERY q_cratmni   FOR cratmni.

DEF BROWSE b_zoom_item QUERY q_zoom_item
    DISPLAY crapmni.cditemmn COLUMN-LABEL "Codigo" FORMAT "zz9"
            crapmni.nmdoitem COLUMN-LABEL "Item"   FORMAT "x(25)"
            WITH NO-BOX 5 DOWN.
            
DEF BROWSE b_cratmni QUERY q_cratmni
    DISPLAY cratmni.nmdoitem COLUMN-LABEL "Item Menu"      FORMAT "x(25)"
            SPACE(1)
            cratmni.nmitmpri COLUMN-LABEL "Item Principal" FORMAT "x(25)"
            SPACE(2)
            cratmni.nrorditm COLUMN-LABEL "Ordem"          FORMAT "zz9"
            SPACE(1)
            cratmni.flgitmbl COLUMN-LABEL "Situacao" FORMAT "Liberado/Bloqueado"
            WITH NO-BOX 8 DOWN.
    
FORM 
    WITH NO-LABEL TITLE COLOR MESSAGE glb_tldatela
    ROW 4 COLUMN 1 OVERLAY SIZE 80 BY 18 FRAME f_moldura.

FORM 
    glb_cddopcao AT 03 LABEL "Opcao" FORMAT "!(1)"
                 HELP "Informe a opcao (A,C,E,I)."
                 VALIDATE (CAN-DO("A,C,E,I",glb_cddopcao),"014 - Opcao Errada")
    WITH NO-LABEL SIDE-LABELS COLUMN 2 ROW 6 OVERLAY NO-BOX FRAME f_opcao.
                 
FORM
    tel_fltipitm AT 01 LABEL "Tipo de Item do Menu" FORMAT "Item/Sub-Item"
                 HELP "Informe o tipo de item para inclusao (Item/Sub-Item)"
    WITH NO-LABEL SIDE-LABELS COLUMN 15 ROW 6 OVERLAY NO-BOX FRAME f_tipo_item.
    
FORM 
    b_zoom_item 
    HELP "Setas para navegar, <ENTER> para selecionar, <END> para sair."
    WITH ROW 10 OVERLAY COLUMN 26 TITLE "ITENS PRINCIPAIS" FRAME f_zoom_item.

FORM 
    b_cratmni 
    WITH ROW 7 OVERLAY COLUMN 3 FRAME f_cratmni.

FORM 
    cratmni.dsurlace AT 03 LABEL "URL Acesso     " FORMAT "x(55)"
    SKIP
    cratmni.dstipitm AT 03 LABEL "Visualizam Item" FORMAT "x(20)"
    WITH ROW 19 COLUMN 2 OVERLAY SIDE-LABELS NO-BOX FRAME f_detalhes.
    
FORM
    tel_nmdoitem AT 05 LABEL "Nome do Item      " FORMAT "x(25)"
        HELP "Informe o nome do item de menu"
        VALIDATE (tel_nmdoitem <> "","Nome do item invalido.")
    SKIP
    tel_dsurlac1 AT 05 LABEL "URL Acesso        " FORMAT "x(50)"
        HELP "Informe a URL de acesso do item de menu"
        VALIDATE (tel_dsurlac1 <> "","URL Acesso invalida.")
    SKIP
    tel_dsurlac2 AT 25 NO-LABEL                   FORMAT "x(50)"
        HELP "Informe a URL de acesso do item de menu"
    tel_nrorditm AT 05 LABEL "Ordem Visualizacao" FORMAT "zz9"
        HELP "Informe a ordem de visualizacao do item de menu"
    SKIP
    tel_intipitm AT 05 LABEL "Visualizam o Item " FORMAT "9"
        HELP "Informe o tipo de conta: 0-Todos/ 1-Pessoa Fisica/ 2-P.Juridica"
        VALIDATE (CAN-DO("0,1,2",STRING(tel_intipitm)),
                  "Tipo de conta invalida.")
    SKIP
    tel_flgitmbl AT 05 LABEL "Situacao do Item  " FORMAT "Liberado/Bloqueado"
        HELP "Informe a situacao do item de menu (Liberado/Bloqueado)"
    SKIP
    tel_flgopepj AT 05 LABEL "Dispon. Operadores" FORMAT "SIM/NAO"
        HELP "Informe a dispon. para operadores do item de menu (SIM/NAO)"
    WITH ROW 11 COLUMN 2 OVERLAY NO-BOX SIDE-LABELS FRAME f_item.
    
FORM
    tel_cditmpri AT 05 LABEL "Item Principal    " FORMAT "zz9"
        HELP "Informe o codigo do item principal ou <F7> para selecionar"
        VALIDATE(CAN-FIND(crapmni WHERE crapmni.cdcooper = glb_cdcooper AND
                                        crapmni.cditemmn = tel_cditmpri AND
                                        crapmni.cdsubitm = 0),
                 "Codigo do item principal invalido.")
    tel_nmitmpri AT 29 NO-LABEL                   FORMAT "x(25)"
    SKIP
    tel_nmdoitem AT 05 LABEL "Nome do Item      " FORMAT "x(25)"
        HELP "Informe o nome do item de menu"
        VALIDATE (tel_nmdoitem <> "","Nome do item invalido.")
    SKIP
    tel_dsurlac1 AT 05 LABEL "URL Acesso        " FORMAT "x(50)"
        HELP "Informe a URL de acesso do item de menu"
        VALIDATE (tel_dsurlac1 <> "","URL Acesso invalida.")
    SKIP
    tel_dsurlac2 AT 25 NO-LABEL                   FORMAT "x(50)"
        HELP "Informe a URL de acesso do item de menu"
    SKIP
    tel_nrorditm AT 05 LABEL "Ordem Visualizacao" FORMAT "zz9"
        HELP "Informe a ordem de visualizacao do item de menu"
    SKIP
    tel_intipitm AT 05 LABEL "Visualizam o Item " FORMAT "9"
        HELP "Informe o tipo de conta: 0-Todos/ 1-Pessoa Fisica/ 2-P.Juridica"
        VALIDATE (CAN-DO("0,1,2",STRING(tel_intipitm)),
                  "Tipo de conta invalida.")
    SKIP
    tel_flgitmbl AT 05 LABEL "Situacao do Item  " FORMAT "Liberado/Bloqueado"
        HELP "Informe a situacao do item de menu (Liberado/Bloqueado)"
    SKIP
    tel_flgopepj AT 05 LABEL "Dispon. Operadores" FORMAT "SIM/NAO"
        HELP "Informe a dispon. para operadores do item de menu (SIM/NAO)"
    WITH ROW 10 COLUMN 2 OVERLAY NO-BOX SIDE-LABELS FRAME f_sub_item.
    
FORM
    WITH ROW 7 COLUMN 3 SIZE 76 BY 14 OVERLAY NO-BOX FRAME f_esconde.
    
ON LEAVE OF tel_cditmpri IN FRAME f_sub_item DO:

    FIND crapmni WHERE crapmni.cdcooper = glb_cdcooper       AND
                       crapmni.cditemmn = INPUT tel_cditmpri AND
                       crapmni.cdsubitm = 0                  NO-LOCK NO-ERROR.
                       
    IF  AVAILABLE crapmni  THEN
        DO:
            ASSIGN tel_nmitmpri = "- " + crapmni.nmdoitem.
        
            DISPLAY tel_nmitmpri WITH FRAME f_sub_item.
        END.
    
END.

ON RETURN OF b_zoom_item DO:

    HIDE MESSAGE NO-PAUSE.
    
    ASSIGN tel_cditmpri = crapmni.cditemmn
           tel_nmitmpri = "- " + crapmni.nmdoitem.
           
    DISPLAY tel_cditmpri tel_nmitmpri WITH FRAME f_sub_item.
           
    APPLY "GO".
    
END.

ON VALUE-CHANGED, ENTRY OF b_cratmni DO:

    DISPLAY cratmni.dsurlace cratmni.dstipitm WITH FRAME f_detalhes.

END.

ON RETURN OF b_cratmni DO:

    HIDE MESSAGE NO-PAUSE.
    
    IF  glb_cddopcao = "C"  THEN
        RETURN.
    ELSE    
    IF  glb_cddopcao = "A"  THEN
        DO:
            DO TRANSACTION:
            
                DO aux_contador = 1 TO 10:
            
                    MESSAGE "Aguarde ...".
                    
                    ASSIGN glb_dscritic = "".
                    
                    FIND crapmni WHERE crapmni.cdcooper = glb_cdcooper     AND
                                       crapmni.cditemmn = cratmni.cditemmn AND
                                       crapmni.cdsubitm = cratmni.cdsubitm 
                                       EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
            
                    IF  NOT AVAILABLE crapmni  THEN
                        DO:
                            IF  LOCKED crapmni  THEN
                                DO:
                                    glb_dscritic = "Registro da tela ja " +
                                                   "esta sendo alterado.".
                                    PAUSE 1 NO-MESSAGE.
                                    NEXT.
                                END.
                            ELSE
                                glb_dscritic = "Registro da tela nao " +
                                               "encontrado.".
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
                
                ASSIGN tel_nmdoitem = crapmni.nmdoitem
                       tel_dsurlac1 = SUBSTR(crapmni.dsurlace,1,50)
                       tel_dsurlac2 = SUBSTR(crapmni.dsurlace,51)
                       tel_nrorditm = crapmni.nrorditm
                       tel_intipitm = crapmni.intipitm
                       tel_flgitmbl = crapmni.flgitmbl
                       tel_flgopepj = crapmni.flgopepj.
                       
                VIEW FRAME f_esconde.
                
                PAUSE(0).
                
                IF  crapmni.cdsubitm > 0  THEN
                    DO:
                        FIND crabmni WHERE 
                             crabmni.cdcooper = glb_cdcooper     AND
                             crabmni.cditemmn = crapmni.cditemmn AND
                             crabmni.cdsubitm = 0                
                             NO-LOCK NO-ERROR.
                
                        IF  NOT AVAILABLE crabmni  THEN
                            DO:
                                BELL.
                                MESSAGE "Registro da tela principal nao"
                                        "encontrado".

                                HIDE FRAME f_esconde NO-PAUSE.
                                
                                UNDO, RETURN.
                            END.
                        
                        ASSIGN tel_cditmpri = crapmni.cditemmn
                               tel_nmitmpri = "- " + crabmni.nmdoitem.  
                             
                        DISPLAY tel_cditmpri tel_nmitmpri tel_nmdoitem 
                                tel_dsurlac1 tel_dsurlac2 tel_nrorditm 
                                tel_intipitm tel_flgitmbl tel_flgopepj
                                WITH FRAME f_sub_item.
                
                        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
            
                            UPDATE tel_nmdoitem tel_dsurlac1 tel_dsurlac2
                                   tel_nrorditm tel_intipitm tel_flgitmbl
                                   tel_flgopepj WITH FRAME f_sub_item.
            
                            LEAVE.
                
                        END.
                    END.                       
                ELSE
                    DO:
                        DISPLAY tel_nmdoitem tel_dsurlac1 tel_dsurlac2
                                tel_nrorditm tel_intipitm tel_flgitmbl 
                                tel_flgopepj WITH FRAME f_item. 
                    
                        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
            
                            UPDATE tel_nmdoitem tel_dsurlac1 tel_dsurlac2
                                   tel_nrorditm tel_intipitm tel_flgitmbl 
                                   tel_flgopepj WITH FRAME f_item.
            
                            LEAVE.
                
                        END.
                    END.
                
                IF  KEY-FUNCTION(LASTKEY) = "END-ERROR"  THEN
                    DO:
                        HIDE FRAME f_esconde  NO-PAUSE.
                        HIDE FRAME f_item     NO-PAUSE.
                        HIDE FRAME f_sub_item NO-PAUSE.
                    
                        UNDO, RETURN.
                    END.

                ASSIGN aux_confirma = "N".
            
                DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
            
                    ASSIGN glb_cdcritic = 78.
                    RUN fontes/critic.p.
                    ASSIGN glb_cdcritic = 0.
                
                    BELL.
                    MESSAGE glb_dscritic UPDATE aux_confirma.
                
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
                    
                        HIDE FRAME f_esconde  NO-PAUSE.
                        HIDE FRAME f_item     NO-PAUSE.
                        HIDE FRAME f_sub_item NO-PAUSE.
                    
                        UNDO, RETURN.
                    END.
                    
                ASSIGN crapmni.nmdoitem = tel_nmdoitem
                       crapmni.dsurlace = tel_dsurlac1 + tel_dsurlac2
                       crapmni.nrorditm = tel_nrorditm
                       crapmni.intipitm = tel_intipitm
                       crapmni.flgitmbl = tel_flgitmbl
                       crapmni.flgopepj = tel_flgopepj.
        
            END. /** Fim do DO TRANSACTION **/
                
            HIDE FRAME f_esconde  NO-PAUSE.
            HIDE FRAME f_item     NO-PAUSE.
            HIDE FRAME f_sub_item NO-PAUSE.
        END.
    ELSE
    IF  glb_cddopcao = "E"  THEN
        DO:
            /** Verifica se ja existe permissao cadastrada para o item **/
            FIND FIRST crapaci WHERE crapaci.cdcooper = glb_cdcooper     AND
                                     crapaci.cditemmn = cratmni.cditemmn AND
                                     crapaci.cdsubitm = cratmni.cdsubitm 
                                     NO-LOCK NO-ERROR.

            IF  AVAILABLE crapaci  THEN
                DO:
                    BELL.
                    MESSAGE "Permissoes ja cadastradas para o item.".
                    
                    RETURN.
                END.

            DO TRANSACTION:
            
                DO aux_contador = 1 TO 10:
            
                    MESSAGE "Aguarde ...".
                    
                    ASSIGN glb_dscritic = "".
                    
                    FIND crapmni WHERE crapmni.cdcooper = glb_cdcooper     AND
                                       crapmni.cditemmn = cratmni.cditemmn AND
                                       crapmni.cdsubitm = cratmni.cdsubitm 
                                       EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
            
                    IF  NOT AVAILABLE crapmni  THEN
                        DO:
                            IF  LOCKED crapmni  THEN
                                DO:
                                    glb_dscritic = "Registro da tela ja " +
                                                   "esta sendo alterado.".
                                    PAUSE 1 NO-MESSAGE.
                                    NEXT.
                                END.
                            ELSE
                                glb_dscritic = "Registro da tela nao " +
                                               "encontrado.".
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
            
                    ASSIGN glb_cdcritic = 78.
                    RUN fontes/critic.p.
                    ASSIGN glb_cdcritic = 0.
                
                    BELL.
                    MESSAGE glb_dscritic UPDATE aux_confirma.
                
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

                DELETE crapmni. 
                   
                IF  cratmni.cdsubitm = 0  THEN
                    DO:
                        FOR EACH crapmni WHERE 
                                 crapmni.cdcooper = glb_cdcooper     AND
                                 crapmni.cditemmn = cratmni.cditemmn AND
                                 crapmni.cdsubitm > 0                
                                 EXCLUSIVE-LOCK:
                                 
                            DELETE crapmni.
                        
                        END.         
                    END.
                    
            END. /** Fim do DO TRANSACTION **/
        END.

    ASSIGN aux_ultlinha = CURRENT-RESULT-ROW("q_cratmni").
    
    CLOSE QUERY q_cratmni.
    
    RUN obtem-itens-menu.
    
    OPEN QUERY q_cratmni FOR EACH cratmni WHERE NO-LOCK 
                                          BY cratmni.cditemmn
                                             BY cratmni.cdsubitm
                                                BY cratmni.nrorditm.

    IF  QUERY q_cratmni:NUM-RESULTS = 0  THEN
        APPLY "GO".
                    
    REPOSITION q_cratmni TO ROW aux_ultlinha.

    APPLY "ENTRY".
    
END.
    
VIEW FRAME f_moldura.

PAUSE(0).

ASSIGN glb_cddopcao = "C".

DO WHILE TRUE:

    RUN fontes/inicia.p.
    
    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
        
        UPDATE glb_cddopcao WITH FRAME f_opcao.
    
        LEAVE.
    
    END.
    
    IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
        DO:
            RUN fontes/novatela.p.
            
            IF  CAPS(glb_nmdatela) <> "MENUIB"  THEN
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

    IF  glb_cddepart <> 20 THEN /* TI */
        DO:
            BELL.
            MESSAGE "Acesso negado. Restrito ao SUPER-USUARIO.".
            
            NEXT.
        END.
        
    IF  CAN-DO("A,C,E",glb_cddopcao)  THEN
        DO:
            RUN obtem-itens-menu.
            
            OPEN QUERY q_cratmni FOR EACH cratmni WHERE NO-LOCK
                                                  BY cratmni.cditemmn
                                                     BY cratmni.cdsubitm
                                                        BY cratmni.nrorditm.
                                              
            IF  QUERY q_cratmni:NUM-RESULTS = 0  THEN
                DO:
                    BELL.
                    MESSAGE "Nenhuma tela foi cadastrada.".
                    
                    CLOSE QUERY q_cratmni.
                    
                    NEXT.
                END.
                
            IF  glb_cddopcao = "A"  THEN
                b_cratmni:HELP = "Setas para navegar, <ENTER> para alterar, " +
                                 "<END> para sair.".
            ELSE
            IF  glb_cddopcao = "C"  THEN
                b_cratmni:HELP = "Use as setas para navegar ou <END> para " +
                                 "sair.".
            ELSE
            IF  glb_cddopcao = "E"  THEN
                b_cratmni:HELP = "Setas para navegar, <ENTER> para excluir, " +
                                 "<END> para sair.".  
                                                    
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
           
                UPDATE b_cratmni WITH FRAME f_cratmni.
                
                LEAVE.

            END.

            CLOSE QUERY q_cratmni.
        
            HIDE FRAME f_cratmni  NO-PAUSE.
            HIDE FRAME f_detalhes NO-PAUSE.
        END.
    ELSE
    IF  glb_cddopcao = "I"  THEN
        DO:
            ASSIGN tel_fltipitm = TRUE.
            
            FIND FIRST crapmni WHERE crapmni.cdcooper = glb_cdcooper AND
                                     crapmni.cdsubitm = 0 
                                     NO-LOCK NO-ERROR.
                                     
            IF  AVAILABLE crapmni  THEN                         
                DO:
                    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
            
                        UPDATE tel_fltipitm WITH FRAME f_tipo_item.
                    
                        LEAVE.
                
                    END.
                    
                    IF  KEY-FUNCTION(LASTKEY) = "END-ERROR"  THEN
                        DO:
                            HIDE FRAME f_tipo_item NO-PAUSE.
                            
                            NEXT.
                        END.
                END.
                
            ASSIGN tel_cditmpri = 0
                   tel_nmitmpri = ""
                   tel_nmdoitem = ""
                   tel_dsurlac1 = ""
                   tel_dsurlac2 = ""
                   tel_nrorditm = 0
                   tel_intipitm = 0
                   tel_flgitmbl = FALSE
                   tel_flgopepj = FALSE.
                
            IF  tel_fltipitm  THEN
                DO:
                    DISPLAY tel_nmdoitem tel_dsurlac1 tel_dsurlac2 
                            tel_nrorditm tel_intipitm tel_flgitmbl 
                            tel_flgopepj WITH FRAME f_item.
                            
                    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                
                        UPDATE tel_nmdoitem tel_dsurlac1 tel_dsurlac2
                               tel_nrorditm tel_intipitm tel_flgitmbl 
                               tel_flgopepj WITH FRAME f_item.
                       
                        FIND LAST crabmni WHERE crabmni.cdcooper = glb_cdcooper
                                                EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                                                
                        IF  NOT AVAILABLE crabmni  THEN
                            DO:
                                IF  LOCKED crabmni  THEN
                                    DO:
                                        BELL.
                                        MESSAGE "Registro atual esta sendo"
                                                "alterado. Tente novamente.".
                                        NEXT.
                                    END.
                                ELSE
                                    ASSIGN aux_cditemmn = 1
                                           aux_cdsubitm = 0.
                            END.
                        ELSE
                            ASSIGN aux_cditemmn = crabmni.cditemmn + 1
                                   aux_cdsubitm = 0.
                            
                        LEAVE.     
                
                    END. /** Fim do DO WHILE TRUE **/        
                
                    IF  KEY-FUNCTION(LASTKEY) = "END-ERROR"  THEN
                        DO:
                            HIDE FRAME f_tipo_item NO-PAUSE.
                            HIDE FRAME f_item      NO-PAUSE.
                    
                            NEXT.
                        END.
                END.
            ELSE
                DO:
                    DISPLAY tel_cditmpri tel_nmitmpri tel_nmdoitem tel_dsurlac1
                            tel_dsurlac2 tel_nrorditm tel_intipitm tel_flgitmbl
                            tel_flgopepj WITH FRAME f_sub_item.    
                
                    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                
                        UPDATE tel_cditmpri tel_nmdoitem tel_dsurlac1
                               tel_dsurlac2 tel_nrorditm tel_intipitm 
                               tel_flgitmbl tel_flgopepj WITH FRAME f_sub_item
                       
                        EDITING:
                       
                            READKEY.     
                            
                            IF  FRAME-FIELD = "tel_cditmpri"  AND
                                LASTKEY = KEYCODE("F7")       THEN
                                DO:
                                    OPEN QUERY q_zoom_item 
                                    FOR EACH crapmni WHERE
                                        crapmni.cdcooper = glb_cdcooper AND
                                        crapmni.cdsubitm = 0           
                                        NO-LOCK BY crapmni.cditemmn.
     
                                    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                             
                                        UPDATE b_zoom_item 
                                               WITH FRAME f_zoom_item.
                        
                                        LEAVE.
                            
                                    END.
                        
                                    CLOSE QUERY q_zoom_item.
                            
                                    HIDE FRAME f_zoom_item NO-PAUSE.
                                END.
                            ELSE 
                                APPLY LASTKEY.
                
                        END. /** Fim do EDITING **/  
                     
                        FIND LAST crabmni WHERE 
                                  crabmni.cdcooper = glb_cdcooper AND
                                  crabmni.cditemmn = tel_cditmpri
                                  EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                                                
                        IF  NOT AVAILABLE crabmni  THEN
                            DO:
                                IF  LOCKED crabmni  THEN
                                    DO:
                                        BELL.
                                        MESSAGE "Registro atual esta sendo"
                                                "alterado. Tente novamente.".
                                        NEXT.
                                    END.
                                ELSE
                                    ASSIGN aux_cditemmn = tel_cditmpri
                                           aux_cdsubitm = 1.
                            END.
                        ELSE
                            ASSIGN aux_cditemmn = crabmni.cditemmn
                                   aux_cdsubitm = crabmni.cdsubitm + 1.
                                   
                        LEAVE.     
                
                    END. /** Fim do DO WHILE TRUE **/

                    IF  KEY-FUNCTION(LASTKEY) = "END-ERROR"  THEN
                        DO:
                            HIDE FRAME f_tipo_item NO-PAUSE.
                            HIDE FRAME f_sub_item  NO-PAUSE.
                    
                            NEXT.
                        END.
                END.    
            
            ASSIGN aux_confirma = "N".
            
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
            
                ASSIGN glb_cdcritic = 78.
                RUN fontes/critic.p.
                ASSIGN glb_cdcritic = 0.
                
                BELL.
                MESSAGE glb_dscritic UPDATE aux_confirma.
                
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
                    
                    HIDE FRAME f_tipo_item NO-PAUSE.
                    HIDE FRAME f_item      NO-PAUSE.
                    HIDE FRAME f_sub_item  NO-PAUSE.
                    
                    NEXT.
                END.
                    
            DO TRANSACTION:
            
                CREATE crapmni.
                ASSIGN crapmni.cdcooper = glb_cdcooper
                       crapmni.cditemmn = aux_cditemmn
                       crapmni.cdsubitm = aux_cdsubitm
                       crapmni.nmdoitem = tel_nmdoitem
                       crapmni.dsurlace = tel_dsurlac1 + tel_dsurlac2
                       crapmni.nrorditm = tel_nrorditm
                       crapmni.intipitm = tel_intipitm
                       crapmni.flgitmbl = tel_flgitmbl
                       crapmni.flgopepj = tel_flgopepj.
                VALIDATE crapmni.
            
            END. /** Fim do DO TRANSACTION **/
            
            HIDE FRAME f_tipo_item NO-PAUSE.
            HIDE FRAME f_item      NO-PAUSE.
            HIDE FRAME f_sub_item  NO-PAUSE.             
        END.
    
END. /** Fim do DO WHILE TRUE **/

PROCEDURE obtem-itens-menu:

    EMPTY TEMP-TABLE cratmni.
    
    FOR EACH crapmni WHERE crapmni.cdcooper = glb_cdcooper NO-LOCK:
    
        ASSIGN aux_nmitmpri = "".
        
        IF  crapmni.cdsubitm > 0  THEN
            DO:
                FIND crabmni WHERE crabmni.cdcooper = glb_cdcooper     AND
                                   crabmni.cditemmn = crapmni.cditemmn AND
                                   crabmni.cdsubitm = 0 
                                   NO-LOCK NO-ERROR.
                                   
                IF  AVAILABLE crabmni  THEN
                    ASSIGN aux_nmitmpri = crabmni.nmdoitem.
            END.
            
        CREATE cratmni.
        ASSIGN cratmni.cditemmn = crapmni.cditemmn
               cratmni.nmitmpri = aux_nmitmpri                  
               cratmni.cdsubitm = crapmni.cdsubitm
               cratmni.nmdoitem = crapmni.nmdoitem
               cratmni.dsurlace = crapmni.dsurlace
               cratmni.flgitmbl = crapmni.flgitmbl
               cratmni.flgopepj = crapmni.flgopepj
               cratmni.nrorditm = crapmni.nrorditm
               cratmni.dstipitm = STRING(crapmni.intipitm) + 
                                 (IF  crapmni.intipitm = 0  THEN
                                      " - Fisica/Juridica"
                                  ELSE
                                  IF  crapmni.intipitm = 1  THEN
                                      " - Fisica"
                                  ELSE
                                  IF  crapmni.intipitm = 2  THEN
                                      " - Juridica"
                                  ELSE
                                      "").
                                                              
    END. /** Fim do FOR EACH crapmni **/

END PROCEDURE.

/*............................................................................*/
