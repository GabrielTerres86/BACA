/*..............................................................................
   
   Programa: fontes/caddrm.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : David
   Data    : Setembro/2008                     Ultima atualizacao: 08/10/2008

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela CADDRM

   Alteracoes: 08/10/2008 - Acerto na validacao da data de referencia (David).

..............................................................................*/


/*................................ DEFINICOES ................................*/


{ includes/var_online.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/b1wgen0034.i }

DEF VAR aux_cddopcao AS CHAR                                           NO-UNDO.
DEF VAR aux_desditem AS CHAR                                           NO-UNDO.
DEF VAR aux_confirma AS CHAR FORMAT "!(1)"                             NO-UNDO.
DEF VAR aux_dsdirdrm AS CHAR                                           NO-UNDO.
DEF VAR aux_cdoperad AS CHAR                                           NO-UNDO.

DEF VAR aux_contador AS INTE                                           NO-UNDO.
DEF VAR aux_cdseqdrm AS INTE                                           NO-UNDO.
DEF VAR aux_ultlinha AS INTE                                           NO-UNDO.

DEF VAR aux_flgsenha AS LOGI                                           NO-UNDO.

DEF VAR aux_dtmvtolt AS DATE                                           NO-UNDO.

DEF VAR tel_btaltera AS CHAR INIT "Alterar"                            NO-UNDO.
DEF VAR tel_btexclui AS CHAR INIT "Excluir"                            NO-UNDO.
DEF VAR tel_btinclui AS CHAR INIT "Incluir"                            NO-UNDO.
DEF VAR tel_dsditdrm AS CHAR                                           NO-UNDO.
DEF VAR tel_cdfatris AS CHAR                                           NO-UNDO.

DEF VAR tel_vllanmto AS INTE                                           NO-UNDO.
DEF VAR tel_qtdiauti AS INTE                                           NO-UNDO.
DEF VAR tel_cdlocreg AS INTE                                           NO-UNDO.

DEF VAR tel_dtmvtolt AS DATE                                           NO-UNDO.
DEF VAR tel_dtvencto AS DATE                                           NO-UNDO.

DEF VAR h-b1wgen0034 AS HANDLE                                         NO-UNDO.

DEF BUFFER crabtab FOR craptab.
DEF BUFFER crabdrm FOR crapdrm.

DEF QUERY q_audite  FOR craptab.
DEF QUERY q_ftrmse  FOR crabtab.
DEF QUERY q_excluir FOR crapdrm.
DEF QUERY q_alterar FOR crapdrm.
DEF QUERY q_crapdrm FOR crapdrm.

DEF BROWSE b_audite QUERY q_audite
    DISP craptab.cdacesso COLUMN-LABEL "Cod." FORMAT "x(3)"
         SPACE(3)
         craptab.dstextab COLUMN-LABEL "Descricao" FORMAT "x(65)"
    WITH NO-BOX OVERLAY 9 DOWN.
    
DEF BROWSE b_ftrmse QUERY q_ftrmse
    DISP crabtab.cdacesso COLUMN-LABEL "Cod." FORMAT "x(3)"
         SPACE(3)
         crabtab.dstextab COLUMN-LABEL "Descricao" FORMAT "x(65)"
    WITH NO-BOX OVERLAY 9 DOWN.    

DEF BROWSE b_excluir QUERY q_excluir
    DISP crapdrm.cdditdrm COLUMN-LABEL "Cod."      FORMAT "x(3)"
         crapdrm.cdseqdrm COLUMN-LABEL "Seq."      FORMAT "9999"
         crapdrm.dsditdrm COLUMN-LABEL "Descricao" FORMAT "x(27)"
         crapdrm.qtdiauti COLUMN-LABEL "Dias Ut."  FORMAT "zzz9"
         crapdrm.cdlocreg COLUMN-LABEL "Local"     FORMAT "99"
         crapdrm.cdfatris COLUMN-LABEL "Fat.Risco" FORMAT "x(3)"
         crapdrm.vllanmto COLUMN-LABEL "Vlr.Risco" FORMAT "zzz,zz9"
    WITH OVERLAY NO-BOX 9 DOWN.
    
DEF BROWSE b_alterar QUERY q_alterar
    DISP crapdrm.cdditdrm COLUMN-LABEL "Cod."      FORMAT "x(3)"
         crapdrm.cdseqdrm COLUMN-LABEL "Seq."      FORMAT "9999"
         crapdrm.dsditdrm COLUMN-LABEL "Descricao" FORMAT "x(27)"
         crapdrm.qtdiauti COLUMN-LABEL "Dias Ut."  FORMAT "zzz9"
         crapdrm.cdlocreg COLUMN-LABEL "Local"     FORMAT "99"
         crapdrm.cdfatris COLUMN-LABEL "Fat.Risco" FORMAT "x(3)"
         crapdrm.vllanmto COLUMN-LABEL "Vlr.Risco" FORMAT "zzz,zz9"
    WITH OVERLAY NO-BOX 9 DOWN.
        
DEF BROWSE b_crapdrm QUERY q_crapdrm
    DISP crapdrm.cdditdrm COLUMN-LABEL "Cod."      FORMAT "x(3)"
         crapdrm.cdseqdrm COLUMN-LABEL "Seq."      FORMAT "9999"
         crapdrm.dsditdrm COLUMN-LABEL "Descricao" FORMAT "x(25)"
         crapdrm.qtdiauti COLUMN-LABEL "Dias Ut."  FORMAT "zzz9"
         crapdrm.cdlocreg COLUMN-LABEL "Local"     FORMAT "99"
         crapdrm.cdfatris COLUMN-LABEL "Fat.Risco" FORMAT "x(3)"
         crapdrm.vllanmto COLUMN-LABEL "Vlr.Risco" FORMAT "zzz,zz9"
    WITH OVERLAY NO-BOX 10 DOWN.        
    
FORM WITH ROW 4 COLUMN 1 OVERLAY SIZE 80 BY 18 TITLE glb_tldatela 
     FRAME f_moldura.

FORM glb_cddopcao AT  3 LABEL "Opcao" FORMAT "!(1)"       AUTO-RETURN
     HELP "Informe a opcao (C=consulta,B=geracao,L=lancamentos,X=desfazer)"
                        VALIDATE (CAN-DO("C,B,L,X",glb_cddopcao),
                                  "014 - Opcao errada.")
     tel_dtmvtolt AT 15 LABEL "Data Referencia"  FORMAT "99/99/9999" AUTO-RETURN
                        HELP "Informe a data de movimento"
                        VALIDATE (tel_dtmvtolt <> ?,"Informe a data.")
     WITH ROW 6 COLUMN 2 OVERLAY SIDE-LABELS NO-BOX FRAME f_opcao.

FORM WITH ROW 7 COLUMN 2 OVERLAY SIZE 78 BY 13 FRAME f_browse.
     
FORM b_audite
     HELP "Use as setas para navegar ou <END>/<F4> para sair."
     WITH ROW 8 NO-BOX CENTERED OVERLAY FRAME f_audite.
     
FORM b_ftrmse
     HELP "Use as setas para navegar ou <END>/<F4> para sair."
     WITH ROW 8 NO-BOX CENTERED OVERLAY FRAME f_ftrmse.

FORM b_crapdrm
     HELP "Use as setas para navegar ou <END>/<F4> para sair."
     WITH ROW 7 CENTERED OVERLAY FRAME f_crapdrm.
          
FORM b_excluir
     HELP "Setas para navegar, <DELETE> para excluir, <END>/<F4> para sair."
     WITH ROW 8 NO-BOX CENTERED OVERLAY FRAME f_excluir.
      
FORM b_alterar
     HELP "Setas para navegar, <ENTER> para alterar, <END>/<F4> para sair."
     WITH ROW 8 NO-BOX CENTERED OVERLAY FRAME f_alterar.      
     
FORM tel_btaltera
     SPACE(5)
     tel_btexclui
     SPACE(5)
     tel_btinclui
     WITH ROW 20 CENTERED OVERLAY NO-BOX NO-LABEL FRAME f_botoes.
    
FORM SKIP(1)
     aux_desditem AT 02 LABEL "Item"               FORMAT "x(66)"
     SKIP
     aux_cdseqdrm AT 02 LABEL "Seq."               FORMAT "9999"
     SKIP
     tel_dsditdrm AT 02 LABEL "Descricao"          FORMAT "x(61)"
         HELP "Informe a descricao do item"
     SKIP
     tel_qtdiauti AT 02 LABEL "Qtd. Dias Uteis  "  FORMAT "zzz9"
         HELP "Informe a quantidade de dias uteis"
     tel_dtvencto AT 28 LABEL "Data de Vencimento" FORMAT "99/99/9999"
         HELP "Informe a data de vencimento"
     SKIP
     tel_cdfatris AT 02 LABEL "Fator Risco      "  FORMAT "x(3)"
         HELP "Informe o codigo do fator de risco ou <F7> para selecionar"
     SKIP
     tel_cdlocreg AT 02 LABEL "Local de Registro"  FORMAT "99"
         HELP "01-Pais em central de custodia ou no SCR, 02-Pais, 03-Exterior"
     SKIP
     tel_vllanmto AT 02 LABEL "Valor Risco      "  FORMAT "zzz,zz9"
         HELP "Informe o valor do fator de risco"
     SKIP(1)
     WITH ROW 8 WIDTH 76 CENTERED OVERLAY SIDE-LABELS FRAME f_item.
     

/*................................. TRIGGERS .................................*/


ON LEAVE OF tel_qtdiauti IN FRAME f_item DO:

    IF  INPUT tel_qtdiauti > 0  THEN
        DO:
            RUN calcula-data-vencto (INPUT INPUT tel_qtdiauti).
            DISPLAY tel_dtvencto WITH FRAME f_item.
        END.
    ELSE
    IF  INPUT tel_dtvencto <> ?  THEN
        DO:
            RUN calcula-dias-uteis (INPUT INPUT tel_dtvencto).
            DISPLAY tel_qtdiauti WITH FRAME f_item.
        END.

END.

ON LEAVE OF tel_dtvencto IN FRAME f_item DO:

    IF  INPUT tel_dtvencto <> ?  THEN
        DO:
            RUN calcula-dias-uteis (INPUT INPUT tel_dtvencto).
            DISPLAY tel_qtdiauti WITH FRAME f_item.
        END.
    ELSE
    IF  INPUT tel_qtdiauti > 0  THEN
        DO:
            RUN calcula-data-vencto (INPUT INPUT tel_qtdiauti).
            DISPLAY tel_dtvencto WITH FRAME f_item.
        END.

END.

ON RETURN OF b_ftrmse IN FRAME f_ftrmse DO:

    ASSIGN tel_cdfatris = crabtab.cdacesso.
    
    DISPLAY tel_cdfatris WITH FRAME f_item.
    
    APPLY "GO".
    
END.

ON RETURN OF b_audite IN FRAME f_audite DO:

    HIDE MESSAGE NO-PAUSE.

    FIND LAST crabdrm WHERE crabdrm.cdcooper = glb_cdcooper     AND
                            crabdrm.dtmvtolt = tel_dtmvtolt     AND
                            crabdrm.cdditdrm = craptab.cdacesso 
                            EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                                
    IF  NOT AVAILABLE crabdrm  THEN
        DO:
            IF  LOCKED crabdrm  THEN
                DO:
                    ASSIGN glb_dscritic = "Registro da tabela DRM em uso. " +
                                          "Tente novamente.".
                    BELL.
                    MESSAGE glb_dscritic.
                    
                    RETURN.
                END.
            ELSE    
                ASSIGN aux_cdseqdrm = 1.
        END.
    ELSE
        ASSIGN aux_cdseqdrm = crabdrm.cdseqdrm + 1.

    ASSIGN tel_dsditdrm = ""
           tel_qtdiauti = 0
           tel_dtvencto = ?
           tel_cdlocreg = 0
           tel_cdfatris = ""
           tel_vllanmto = 0
           aux_desditem = craptab.cdacesso + " - " + craptab.dstextab.
        
    IF  craptab.cdacesso = "A50"  THEN
        DO:
            ASSIGN tel_qtdiauti = 2520.
            RUN calcula-data-vencto (INPUT tel_qtdiauti).
        END.
        
    DISPLAY aux_desditem aux_cdseqdrm tel_dsditdrm tel_qtdiauti tel_dtvencto 
            tel_cdlocreg tel_cdfatris tel_vllanmto WITH FRAME f_item.
                
    ASSIGN glb_dscritic = "".
    
    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
        
        IF  glb_dscritic <> ""  THEN
            DO:
                BELL.
                MESSAGE glb_dscritic.
            END.
            
        UPDATE tel_dsditdrm 
               tel_qtdiauti WHEN craptab.cdacesso <> "A50" 
               tel_dtvencto WHEN craptab.cdacesso <> "A50"
               tel_cdfatris 
               tel_cdlocreg
               tel_vllanmto WITH FRAME f_item
               
        EDITING:
        
            READKEY.
            
            IF  FRAME-VALUE = tel_cdfatris  THEN
                DO:
                    IF  LASTKEY = KEYCODE("F7")  THEN
                        DO:
                            OPEN QUERY q_ftrmse 
                                 FOR EACH crabtab WHERE
                                          crabtab.cdcooper = glb_cdcooper AND
                                          crabtab.nmsistem = "DRM"        AND
                                          crabtab.tptabela = "FTRSME"     AND
                                          crabtab.cdempres = 0            AND
                                          crabtab.tpregist = 0            
                                          NO-LOCK BY crabtab.cdacesso.
                                      
                            IF  QUERY q_ftrmse:NUM-RESULTS = 0  THEN
                                DO:
                                    CLOSE QUERY q_ftrmse.
                                    glb_dscritic = "Itens da tabela AUDITE " +
                                                   "nao foram cadastrados.".
                                    BELL.
                                    MESSAGE glb_dscritic.
                                    RETURN.
                                END.
                        
                            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                                                        
                                UPDATE b_ftrmse WITH FRAME f_ftrmse.
                                LEAVE.
                                
                            END.    
                                      
                            CLOSE QUERY q_ftrmse.

                            HIDE FRAME f_ftrmse NO-PAUSE.
                        END.
                    ELSE
                        APPLY LASTKEY.
                END.
            ELSE
                APPLY LASTKEY.
        
        END. /** Fim do EDITING **/
                    
        IF  tel_dsditdrm = ""  THEN
            DO:
                ASSIGN glb_dscritic = "Descricao do item invalida.".
                NEXT-PROMPT tel_dsditdrm WITH FRAME f_item.
                NEXT.                
            END.

        IF  tel_qtdiauti = 0  THEN
            DO:
                ASSIGN glb_dscritic = "Quantidade de dias uteis invalida.".
                NEXT-PROMPT tel_qtdiauti WITH FRAME f_item.
                NEXT.                
            END.
            
        IF  NOT CAN-FIND(craptab WHERE
                         craptab.cdcooper = glb_cdcooper   AND
                         craptab.nmsistem = "DRM"          AND
                         craptab.tptabela = "FTRSME"       AND
                         craptab.cdempres = 0              AND
                         craptab.tpregist = 0              AND
                         craptab.cdacesso = tel_cdfatris)  THEN
            DO:
                ASSIGN glb_dscritic = "Fator de risco invalido.".
                NEXT-PROMPT tel_cdfatris WITH FRAME f_item.
                NEXT.                
            END.
                   
        IF  NOT CAN-DO("1,2,3",STRING(tel_cdlocreg))  THEN
            DO:
                ASSIGN glb_dscritic = "Local de registro invalido.".
                NEXT-PROMPT tel_cdlocreg WITH FRAME f_item.
                NEXT.                
            END.
            
        IF  tel_vllanmto = 0  THEN
            DO:
                ASSIGN glb_dscritic = "Valor do fator de risco invalido.".
                NEXT-PROMPT tel_vllanmto WITH FRAME f_item.
                NEXT.                
            END.                   

        LEAVE.            
        
    END.

    IF  KEY-FUNCTION(LASTKEY) = "END-ERROR"  THEN
        DO:
            RELEASE crabdrm.
            HIDE FRAME f_item NO-PAUSE.
            
            RETURN.    
        END.

    ASSIGN aux_confirma = "N".
    
    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
    
        ASSIGN glb_cdcritic = 78.
        RUN fontes/critic.p.
        BELL.
        MESSAGE glb_dscritic UPDATE aux_confirma.
        LEAVE.
    
    END.

    IF  KEY-FUNCTION(LASTKEY) = "END-ERROR" OR aux_confirma <> "S"  THEN
        DO:
            ASSIGN glb_cdcritic = 79.
            RUN fontes/critic.p.
            BELL.
            MESSAGE glb_dscritic.
            
            RELEASE crabdrm.
            HIDE FRAME f_item NO-PAUSE.
                
            RETURN.
        END.
    
    CREATE crapdrm.
    ASSIGN crapdrm.cdcooper = glb_cdcooper
           crapdrm.dtmvtolt = tel_dtmvtolt
           crapdrm.cdditdrm = craptab.cdacesso
           crapdrm.cdseqdrm = aux_cdseqdrm
           crapdrm.dsditdrm = CAPS(tel_dsditdrm)
           crapdrm.cdfatris = CAPS(tel_cdfatris)
           crapdrm.qtdiauti = tel_qtdiauti
           crapdrm.vllanmto = tel_vllanmto
           crapdrm.cdlocreg = tel_cdlocreg.
        
    RELEASE crabdrm.
    HIDE FRAME f_item NO-PAUSE.
    
END.

ON "RETURN" OF b_alterar IN FRAME f_alterar DO:

    IF  NOT AVAILABLE crapdrm  THEN
        RETURN.
        
    HIDE MESSAGE NO-PAUSE.
    
    ASSIGN glb_dscritic = "".
    
    FIND CURRENT crapdrm EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                
    IF  NOT AVAILABLE crapdrm  THEN
        DO:
            IF  LOCKED crapdrm  THEN
                ASSIGN glb_dscritic = "Registro da tabela DRM em uso. " +
                                      "Tente novamente.".
            ELSE
                ASSIGN glb_dscritic = "Registro da tabela DRM nao " +
                                      "encontrado.".
        END.
    
    IF  glb_dscritic <> ""  THEN
        DO:
            BELL.
            MESSAGE glb_dscritic.
            RETURN.
        END.            
           
    FIND craptab WHERE craptab.cdcooper = glb_cdcooper     AND
                       craptab.nmsistem = "DRM"            AND
                       craptab.tptabela = "AUDITE"         AND
                       craptab.cdempres = 0                AND
                       craptab.tpregist = 0                AND
                       craptab.cdacesso = crapdrm.cdditdrm NO-LOCK NO-ERROR.
                       
    IF  NOT AVAILABLE craptab  THEN
        DO:
            ASSIGN glb_dscritic = "Item nao cadastrado na tabela AUDITE.".
            BELL.
            MESSAGE glb_dscritic.
            RETURN.
        END.
        
    ASSIGN aux_desditem = craptab.cdacesso + " - " + craptab.dstextab
           aux_cdseqdrm = crapdrm.cdseqdrm
           tel_dsditdrm = crapdrm.dsditdrm
           tel_qtdiauti = crapdrm.qtdiauti
           tel_cdlocreg = crapdrm.cdlocreg
           tel_cdfatris = crapdrm.cdfatris
           tel_vllanmto = crapdrm.vllanmto
           tel_dtvencto = crapdrm.dtmvtolt - 1
           aux_contador = 0.
           
    RUN calcula-data-vencto (INPUT tel_qtdiauti).
                
    DISPLAY aux_desditem aux_cdseqdrm tel_dsditdrm tel_qtdiauti tel_dtvencto 
            tel_cdlocreg tel_cdfatris tel_vllanmto WITH FRAME f_item.
                
    ASSIGN glb_dscritic = "".
    
    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
        
        IF  glb_dscritic <> ""  THEN
            DO:
                BELL.
                MESSAGE glb_dscritic.
            END.
            
        UPDATE tel_dsditdrm 
               tel_qtdiauti WHEN crapdrm.cdditdrm <> "A50"
               tel_dtvencto WHEN crapdrm.cdditdrm <> "A50"
               tel_cdfatris 
               tel_cdlocreg
               tel_vllanmto WITH FRAME f_item
               
        EDITING:
        
            READKEY.
            
            IF  FRAME-VALUE = tel_cdfatris  THEN
                DO:
                    IF  LASTKEY = KEYCODE("F7")  THEN
                        DO:
                            OPEN QUERY q_ftrmse 
                                 FOR EACH crabtab WHERE
                                          crabtab.cdcooper = glb_cdcooper AND
                                          crabtab.nmsistem = "DRM"        AND
                                          crabtab.tptabela = "FTRSME"     AND
                                          crabtab.cdempres = 0            AND
                                          crabtab.tpregist = 0            
                                          NO-LOCK BY crabtab.cdacesso.
                                      
                            IF  QUERY q_ftrmse:NUM-RESULTS = 0  THEN
                                DO:
                                    CLOSE QUERY q_ftrmse.
                                    glb_dscritic = "Itens da tabela AUDITE " +
                                                   "nao foram cadastrados.".
                                    BELL.
                                    MESSAGE glb_dscritic.
                                    RETURN.
                                END.
                        
                            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                                                        
                                UPDATE b_ftrmse WITH FRAME f_ftrmse.
                                LEAVE.
                                
                            END.    
                                      
                            CLOSE QUERY q_ftrmse.

                            HIDE FRAME f_ftrmse NO-PAUSE.
                        END.
                    ELSE
                        APPLY LASTKEY.
                END.
            ELSE
                APPLY LASTKEY.
        
        END. /** Fim do EDITING **/
                    
        IF  tel_dsditdrm = ""  THEN
            DO:
                ASSIGN glb_dscritic = "Descricao do item invalida.".
                NEXT-PROMPT tel_dsditdrm WITH FRAME f_item.
                NEXT.                
            END.

        IF  tel_qtdiauti = 0  THEN
            DO:
                ASSIGN glb_dscritic = "Quantidade de dias uteis invalida.".
                NEXT-PROMPT tel_qtdiauti WITH FRAME f_item.
                NEXT.                
            END.
            
        IF  NOT CAN-FIND(craptab WHERE
                         craptab.cdcooper = glb_cdcooper   AND
                         craptab.nmsistem = "DRM"          AND
                         craptab.tptabela = "FTRSME"       AND
                         craptab.cdempres = 0              AND
                         craptab.tpregist = 0              AND
                         craptab.cdacesso = tel_cdfatris)  THEN
            DO:
                ASSIGN glb_dscritic = "Fator de risco invalido.".
                NEXT-PROMPT tel_cdfatris WITH FRAME f_item.
                NEXT.                
            END.
                   
        IF  NOT CAN-DO("1,2,3",STRING(tel_cdlocreg))  THEN
            DO:
                ASSIGN glb_dscritic = "Local de registro invalido.".
                NEXT-PROMPT tel_cdlocreg WITH FRAME f_item.
                NEXT.                
            END.
            
        IF  tel_vllanmto = 0  THEN
            DO:
                ASSIGN glb_dscritic = "Valor do fator de risco invalido.".
                NEXT-PROMPT tel_vllanmto WITH FRAME f_item.
                NEXT.                
            END.                   

        LEAVE.            
        
    END.

    IF  KEY-FUNCTION(LASTKEY) = "END-ERROR"  THEN
        DO:
            RELEASE crapdrm.
            HIDE FRAME f_item NO-PAUSE.
            RETURN.    
        END.
                   
    ASSIGN aux_confirma = "N".
    
    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
    
        ASSIGN glb_cdcritic = 78.
        RUN fontes/critic.p.
        BELL.
        MESSAGE glb_dscritic UPDATE aux_confirma.
        LEAVE.
    
    END.

    IF  KEY-FUNCTION(LASTKEY) = "END-ERROR" OR aux_confirma <> "S"  THEN
        DO:
            ASSIGN glb_cdcritic = 79.
            RUN fontes/critic.p.
            BELL.
            MESSAGE glb_dscritic.
            
            RELEASE crapdrm.
            HIDE FRAME f_item NO-PAUSE.    
            RETURN.
        END.

    ASSIGN crapdrm.dsditdrm = tel_dsditdrm
           crapdrm.qtdiauti = tel_qtdiauti
           crapdrm.cdfatris = tel_cdfatris
           crapdrm.cdlocreg = tel_cdlocreg
           crapdrm.vllanmto = tel_vllanmto.

    RELEASE crapdrm.
    HIDE FRAME f_item NO-PAUSE.
                    
    CLOSE QUERY q_alterar.
    OPEN QUERY q_alterar FOR EACH crapdrm WHERE 
                                  crapdrm.cdcooper = glb_cdcooper AND
                                  crapdrm.dtmvtolt = tel_dtmvtolt NO-LOCK
                                  BY crapdrm.cdditdrm BY crapdrm.cdseqdrm.
                                      
END.

ON "DELETE" OF b_excluir IN FRAME f_excluir DO:

    IF  NOT AVAILABLE crapdrm  THEN
        RETURN.
        
    HIDE MESSAGE NO-PAUSE.
    
    ASSIGN glb_dscritic = "".
    
    FIND CURRENT crapdrm EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                
    IF  NOT AVAILABLE crapdrm  THEN
        DO:
            IF  LOCKED crapdrm  THEN
                ASSIGN glb_dscritic = "Registro da tabela DRM em uso. " +
                                      "Tente novamente.".
            ELSE
                ASSIGN glb_dscritic = "Registro da tabela DRM nao " +
                                      "encontrado.".
        END.
    
    IF  glb_dscritic <> ""  THEN
        DO:
            BELL.
            MESSAGE glb_dscritic.
            RETURN.
        END.            
           
    ASSIGN aux_confirma = "N".
    
    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
    
        ASSIGN glb_cdcritic = 78.
        RUN fontes/critic.p.
        BELL.
        MESSAGE glb_dscritic UPDATE aux_confirma.
        LEAVE.
    
    END.

    IF  KEY-FUNCTION(LASTKEY) = "END-ERROR" OR aux_confirma <> "S"  THEN
        DO:
            ASSIGN glb_cdcritic = 79.
            RUN fontes/critic.p.
            BELL.
            MESSAGE glb_dscritic.
            
            RELEASE crapdrm.
            RETURN.
        END.
                    
    DELETE crapdrm.
    
    ASSIGN aux_ultlinha = CURRENT-RESULT-ROW("q_excluir").
    
    CLOSE QUERY q_excluir.
    OPEN QUERY q_excluir FOR EACH crapdrm WHERE 
                                  crapdrm.cdcooper = glb_cdcooper AND
                                  crapdrm.dtmvtolt = tel_dtmvtolt NO-LOCK
                                  BY crapdrm.cdditdrm BY crapdrm.cdseqdrm.
                                      
    REPOSITION q_excluir TO ROW aux_ultlinha.

END.


/*................................. PRINCIPAL ................................*/


VIEW FRAME f_moldura.

PAUSE(0).

ASSIGN glb_cddopcao = "C".

DISPLAY glb_cddopcao WITH FRAME f_opcao.

DO WHILE TRUE:
                        
    RUN fontes/inicia.p.

    ASSIGN tel_dtmvtolt = ?.
  
    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
     
        UPDATE glb_cddopcao tel_dtmvtolt WITH FRAME f_opcao.
        LEAVE.

    END.  

    IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
        DO:
            RUN fontes/novatela.p.
            
            IF  CAPS(glb_nmdatela) <> "CADDRM"  THEN
                DO:
                    HIDE FRAME f_moldura NO-PAUSE.
                    HIDE FRAME f_opcao   NO-PAUSE.
                    
                    RETURN.
                END.
            ELSE
                NEXT.
        END.

    IF  aux_cddopcao <> glb_cddopcao  THEN
        DO:
            { includes/acesso.i }
            aux_cddopcao = glb_cddopcao.
        END.

    IF  MONTH(tel_dtmvtolt) = 12  THEN
        ASSIGN aux_dtmvtolt = DATE(1,1,YEAR(tel_dtmvtolt) + 1) - 1.
    ELSE
        ASSIGN aux_dtmvtolt = DATE(MONTH(tel_dtmvtolt) + 1,1,
                                   YEAR(tel_dtmvtolt)) - 1.
    
    DO WHILE TRUE:
    
        IF  CAN-DO("1,7",STRING(WEEKDAY(aux_dtmvtolt)))              OR
            CAN-FIND(crapfer WHERE crapfer.cdcooper = glb_cdcooper   AND
                                   crapfer.dtferiad = aux_dtmvtolt)  THEN
            DO:
                ASSIGN aux_dtmvtolt = aux_dtmvtolt - 1.
                NEXT.
            END.

        LEAVE.

    END. /** Fim do DO WHILE TRUE **/

    IF  tel_dtmvtolt <> aux_dtmvtolt  THEN
        DO:
            ASSIGN glb_dscritic = "Data invalida. Deve ser o ultimo dia util " +
                                  "do mes.".
            BELL.
            MESSAGE glb_dscritic.
            NEXT-PROMPT tel_dtmvtolt WITH FRAME f_opcao.
            NEXT.
        END.
    
    IF  glb_cddopcao = "C"  THEN
        DO:
            HIDE MESSAGE NO-PAUSE.
                
            OPEN QUERY q_crapdrm FOR EACH crapdrm WHERE 
                                          crapdrm.cdcooper = glb_cdcooper AND
                                          crapdrm.dtmvtolt = tel_dtmvtolt 
                                          NO-LOCK BY crapdrm.cdditdrm 
                                                     BY crapdrm.cdseqdrm.

            IF  QUERY q_crapdrm:NUM-RESULTS = 0  THEN
                DO:
                    CLOSE QUERY q_crapdrm.
                    ASSIGN glb_dscritic = "Nenhum item cadastrado.".
                    BELL.
                    MESSAGE glb_dscritic.
                    NEXT.
                END.
                        
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                        
                UPDATE b_crapdrm WITH FRAME f_crapdrm.
                LEAVE.
                                     
            END.
                        
            CLOSE QUERY q_crapdrm.

            HIDE FRAME f_crapdrm NO-PAUSE.
        END.
    ELSE
    IF  glb_cddopcao = "B"  THEN
        DO:            
            HIDE MESSAGE NO-PAUSE.

            FIND FIRST crapdrm WHERE crapdrm.cdcooper = glb_cdcooper AND
                                     crapdrm.dtmvtolt = tel_dtmvtolt 
                                     NO-LOCK NO-ERROR.
                                     
            IF  NOT AVAILABLE crapdrm  THEN
                DO:
                    glb_dscritic = "Nenhum item cadastrado na tabela DRM.".
                    BELL.
                    MESSAGE glb_dscritic.
                    NEXT.
                END.
                
            IF  crapdrm.flgenvio  THEN
                DO:
                    glb_dscritic = "Arquivo DRM referente a " +
                                   STRING(tel_dtmvtolt,"99/99/9999") + 
                                   " ja foi gerado.".
                    BELL.
                    MESSAGE glb_dscritic.
                    NEXT.
                END.

            ASSIGN aux_confirma = "N".
    
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
    
                ASSIGN glb_cdcritic = 78.
                RUN fontes/critic.p.
                BELL.
                MESSAGE glb_dscritic UPDATE aux_confirma.
                LEAVE.
    
            END.

            IF  KEY-FUNCTION(LASTKEY) = "END-ERROR" OR aux_confirma <> "S"  THEN
                DO:
                    ASSIGN glb_cdcritic = 79.
                    RUN fontes/critic.p.
                    BELL.
                    MESSAGE glb_dscritic.
                    NEXT.
                END.
            
            RUN sistema/generico/procedures/b1wgen0034.p PERSISTENT 
                SET h-b1wgen0034.
                
            IF  NOT VALID-HANDLE(h-b1wgen0034)  THEN
                DO:
                    ASSIGN glb_dscritic = "Handle invalido para BO b1wgen0034.".
                    BELL.
                    MESSAGE glb_dscritic.
                    NEXT.
                END.

            MESSAGE "Aguarde, gerando arquivo DRM2040 ...".

            RUN gera_table_drm IN h-b1wgen0034 (INPUT glb_cdcooper,
                                                INPUT tel_dtmvtolt,
                                               OUTPUT TABLE w_drm,
                                               OUTPUT TABLE tt-erro).
        
            IF  RETURN-VALUE = "NOK"  THEN
                DO:
                    DELETE PROCEDURE h-b1wgen0034.
                    
                    FIND FIRST tt-erro NO-LOCK NO-ERROR.
                    
                    IF  AVAILABLE tt-erro  THEN
                        ASSIGN glb_dscritic = tt-erro.dscritic.
                    ELSE
                        ASSIGN glb_dscritic = "Erro na geracao do arquivo.".
                        
                    HIDE MESSAGE NO-PAUSE.        
                    BELL.
                    MESSAGE glb_dscritic.
                    NEXT.
                END.

            RUN gera_arquivo_drm IN h-b1wgen0034 (INPUT glb_cdcooper,
                                                  INPUT tel_dtmvtolt,
                                                  INPUT TABLE w_drm,
                                                 OUTPUT aux_dsdirdrm,
                                                 OUTPUT TABLE tt-erro).
                                                  
            DELETE PROCEDURE h-b1wgen0034.                          
                   
            IF  RETURN-VALUE = "NOK"  THEN
                DO:
                    FIND FIRST tt-erro NO-LOCK NO-ERROR.
                    
                    IF  AVAILABLE tt-erro  THEN
                        ASSIGN glb_dscritic = tt-erro.dscritic.
                    ELSE
                        ASSIGN glb_dscritic = "Erro na geracao do arquivo.".
                        
                    HIDE MESSAGE NO-PAUSE.
                    BELL.
                    MESSAGE glb_dscritic.
                    NEXT.
                END.
                         
            FOR EACH crapdrm WHERE crapdrm.cdcooper = glb_cdcooper AND
                                   crapdrm.dtmvtolt = tel_dtmvtolt 
                                   EXCLUSIVE-LOCK:
 
                ASSIGN crapdrm.flgenvio = TRUE.                       
            
            END.
                                   
            HIDE MESSAGE NO-PAUSE.
            ASSIGN glb_dscritic = "Arquivo gerado em " + aux_dsdirdrm. 
            BELL.
            MESSAGE glb_dscritic.
        END.
    ELSE
    IF  glb_cddopcao = "L"  THEN
        DO:
            FIND FIRST crapdrm WHERE crapdrm.cdcooper = glb_cdcooper AND
                                     crapdrm.dtmvtolt = tel_dtmvtolt AND
                                     crapdrm.flgenvio = TRUE         
                                     NO-LOCK NO-ERROR.
                                     
            IF  AVAILABLE crapdrm  THEN
                DO:
                    glb_dscritic = "Arquivo DRM referente a " +
                                   STRING(tel_dtmvtolt,"99/99/9999") + 
                                   " ja foi gerado.".
                    BELL.
                    MESSAGE glb_dscritic.
                    NEXT.
                END.
                
            VIEW FRAME f_browse.
            
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                
                DISPLAY tel_btaltera tel_btexclui tel_btinclui 
                        WITH FRAME f_botoes.
                    
                CHOOSE FIELD tel_btaltera tel_btexclui tel_btinclui 
                             WITH FRAME f_botoes.

                HIDE MESSAGE NO-PAUSE.
                
                IF  FRAME-VALUE = tel_btaltera  THEN
                    DO:
                        OPEN QUERY q_alterar
                             FOR EACH crapdrm WHERE 
                                      crapdrm.cdcooper = glb_cdcooper AND
                                      crapdrm.dtmvtolt = tel_dtmvtolt NO-LOCK
                                      BY crapdrm.cdditdrm BY crapdrm.cdseqdrm.

                        IF  QUERY q_alterar:NUM-RESULTS = 0  THEN
                            DO:
                                CLOSE QUERY q_alterar.
                                ASSIGN glb_dscritic = "Nenhum item cadastrado.".
                                BELL.
                                MESSAGE glb_dscritic.
                                NEXT.
                            END.
                        
                        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                        
                            UPDATE b_alterar WITH FRAME f_alterar.
                            LEAVE.
                                     
                        END.
                        
                        CLOSE QUERY q_alterar.

                        HIDE FRAME f_alterar NO-PAUSE.
                    END.
                ELSE
                IF  FRAME-VALUE = tel_btinclui  THEN
                    DO:
                        OPEN QUERY q_audite 
                             FOR EACH craptab WHERE
                                      craptab.cdcooper = glb_cdcooper AND
                                      craptab.nmsistem = "DRM"        AND
                                      craptab.tptabela = "AUDITE"     AND
                                      craptab.cdempres = 0            AND
                                      craptab.tpregist = 0            NO-LOCK
                                      BY craptab.cdacesso.
                                      
                        IF  QUERY q_audite:NUM-RESULTS = 0  THEN
                            DO:
                                CLOSE QUERY q_audite.
                                ASSIGN glb_dscritic = "Itens da tabela AUDITE" +
                                                      " nao foram cadastrados.".
                                BELL.
                                MESSAGE glb_dscritic.
                                NEXT.
                            END.
                        
                        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                        
                            UPDATE b_audite WITH FRAME f_audite.
                            LEAVE.
                                     
                        END.
                        
                        CLOSE QUERY q_audite.

                        HIDE FRAME f_audite NO-PAUSE.
                    END.
                ELSE
                IF  FRAME-VALUE = tel_btexclui  THEN
                    DO:
                        OPEN QUERY q_excluir
                             FOR EACH crapdrm WHERE 
                                      crapdrm.cdcooper = glb_cdcooper AND
                                      crapdrm.dtmvtolt = tel_dtmvtolt NO-LOCK
                                      BY crapdrm.cdditdrm BY crapdrm.cdseqdrm.
                                      
                        IF  QUERY q_excluir:NUM-RESULTS = 0  THEN
                            DO:
                                CLOSE QUERY q_excluir.
                                ASSIGN glb_dscritic = "Nenhum item cadastrado.".
                                BELL.
                                MESSAGE glb_dscritic.
                                NEXT.
                            END.
                        
                        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                        
                            UPDATE b_excluir WITH FRAME f_excluir.
                            LEAVE.
                                     
                        END.
                        
                        CLOSE QUERY q_excluir.

                        HIDE FRAME f_excluir NO-PAUSE.
                    END.
                
            END. /** Fim do DO WHILE TRUE **/
            
            IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
                DO:
                    HIDE MESSAGE NO-PAUSE.
                    
                    HIDE FRAME f_browse NO-PAUSE.
                    HIDE FRAME f_botoes NO-PAUSE.
                
                    NEXT.
                END.    
        END.
    ELSE
    IF  glb_cddopcao = "X"  THEN
        DO:
            MESSAGE "Peca a liberacao ao Coordenador/Gerente...".
            PAUSE 2 NO-MESSAGE.

            RUN fontes/pedesenha.p (INPUT glb_cdcooper,  
                                    INPUT 2, 
                                   OUTPUT aux_flgsenha,
                                   OUTPUT aux_cdoperad).
             
            IF  KEY-FUNCTION(LASTKEY) = "END-ERROR"  THEN
                NEXT.
                
            IF  NOT aux_flgsenha  THEN
                NEXT.
                
            ASSIGN aux_confirma = "N".
    
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
    
                ASSIGN glb_cdcritic = 78.
                RUN fontes/critic.p.
                BELL.
                MESSAGE glb_dscritic UPDATE aux_confirma.
                LEAVE.
    
            END.

            IF  KEY-FUNCTION(LASTKEY) = "END-ERROR" OR aux_confirma <> "S"  THEN
                DO:
                    ASSIGN glb_cdcritic = 79.
                    RUN fontes/critic.p.
                    BELL.
                    MESSAGE glb_dscritic.
                    NEXT.
                END.
                                
            FOR EACH crapdrm WHERE crapdrm.cdcooper = glb_cdcooper AND
                                   crapdrm.dtmvtolt = tel_dtmvtolt AND
                                   crapdrm.flgenvio = TRUE
                                   EXCLUSIVE-LOCK:
 
                ASSIGN crapdrm.flgenvio = FALSE.                       
            
            END.                                
        END.

END. /** Fim do DO WHILE TRUE **/


/*................................ PROCEDURES ................................*/


PROCEDURE calcula-data-vencto:

    DEF  INPUT PARAM par_qtdiauti AS INTE                           NO-UNDO.

    ASSIGN tel_dtvencto = tel_dtmvtolt - 1
           aux_contador = 0.

    DO WHILE aux_contador <= par_qtdiauti:
        
        ASSIGN tel_dtvencto = tel_dtvencto + 1.
                
        IF  CAN-DO("1,7",STRING(WEEKDAY(tel_dtvencto)))              OR
            CAN-FIND(crapfer WHERE crapfer.cdcooper = glb_cdcooper   AND
                                   crapfer.dtferiad = tel_dtvencto)  THEN
            NEXT.

        ASSIGN aux_contador = aux_contador + 1.
                
    END.

END PROCEDURE.

PROCEDURE calcula-dias-uteis:

    DEF  INPUT PARAM par_dtvencto AS DATE                           NO-UNDO.

    ASSIGN tel_qtdiauti = 0
           aux_dtmvtolt = par_dtvencto.
            
    DO WHILE tel_dtmvtolt < aux_dtmvtolt:
        
        ASSIGN aux_dtmvtolt = aux_dtmvtolt - 1.
                
        IF  CAN-DO("1,7",STRING(WEEKDAY(aux_dtmvtolt)))              OR
            CAN-FIND(crapfer WHERE crapfer.cdcooper = glb_cdcooper   AND
                                   crapfer.dtferiad = aux_dtmvtolt)  THEN
            NEXT.
            
        ASSIGN tel_qtdiauti = tel_qtdiauti + 1.
        
    END.

END PROCEDURE.


/*............................................................................*/
