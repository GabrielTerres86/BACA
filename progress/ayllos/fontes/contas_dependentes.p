/*.............................................................................

   Programa: Fontes/contas_dependentes.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Diego
   Data    : Setembro/2006                   Ultima Atualizacao: 22/09/2010

   Dados referentes ao programa:
   
   Frequencia: Diario (on-line)
   Objetivo  : Efetuar manutencao dos dados referentes aos dependentes do
               Associado pela tela CONTAS (Pessoa Fisica).
               
   Alteracoes: 26/05/2008 - Efetuado acerto na listagem de dependentes (Diego).
   
               18/11/2009 - Utilizar BO b1wgen0047.p (David).
               
               22/09/2010 - Bloqueia edição em conta filha (Gabriel, DB1).
               
.............................................................................*/

{ sistema/generico/includes/b1wgen0047tt.i}
{ sistema/generico/includes/var_internet.i }
{ includes/var_online.i }  
{ includes/var_contas.i }
{ sistema/generico/includes/b1wgenvlog.i &VAR-GERAL=SIM &SESSAO-DESKTOP=SIM }

DEF VAR tel_nmdepend LIKE crapdep.nmdepend                             NO-UNDO.
DEF VAR tel_dtnascto LIKE crapdep.dtnascto                             NO-UNDO.
DEF VAR tel_cdtipdep LIKE crapdep.tpdepend                             NO-UNDO.
DEF VAR tel_dstipdep AS CHAR FORMAT "x(15)"                            NO-UNDO.

DEF VAR reg_cddopcao AS CHAR EXTENT 3 INIT ["A","E","I"]               NO-UNDO.
DEF VAR reg_dsdopcao AS CHAR EXTENT 3 INIT ["Alterar",
                                            "Excluir",
                                            "Incluir"]                 NO-UNDO.
DEF VAR reg_iddopcao AS INTE          INIT 1                           NO-UNDO.

DEF VAR aux_nrdlinha AS INTE                                           NO-UNDO.
DEF VAR aux_nrdrowid AS ROWID                                          NO-UNDO.
DEF VAR aux_flgerlog AS LOGI                                           NO-UNDO.
DEF VAR aux_msgconta AS CHARACTER                                      NO-UNDO.
DEF VAR aux_mvgrecad AS CHARACTER                                      NO-UNDO.

DEF VAR h-b1wgen0047 AS HANDLE                                         NO-UNDO.

DEF QUERY q_dependentes FOR tt-dependente.
DEF QUERY q_tipos       FOR tt-tipos-dependente.

DEF BROWSE b_dependentes QUERY q_dependentes
    DISPLAY tt-dependente.nmdepend NO-LABEL   
            tt-dependente.dtnascto NO-LABEL     
            tt-dependente.dstipdep NO-LABEL     
            WITH 8 DOWN NO-BOX.

DEF BROWSE b_tipos QUERY q_tipos
    DISPLAY tt-tipos-dependente.cdtipdep NO-LABEL FORMAT "z9"  
            tt-tipos-dependente.dstipdep NO-LABEL FORMAT "x(15)" 
            WITH 5 DOWN NO-BOX.

FORM SKIP(2)
     tel_nmdepend LABEL "                   Nome"
         HELP "Informe o nome do dependente"
     SKIP(1)
     tel_dtnascto LABEL "        Data Nascimento" 
         HELP "Informe a data de nascimento"
     SKIP(1)
     tel_cdtipdep LABEL "        Tipo Dependente"  
         HELP "Informe o tipo de dependente ou pressione F7 para listar"
     tel_dstipdep NO-LABEL
     SKIP(1)
     WITH ROW 11 WIDTH 70 OVERLAY CENTERED SIDE-LABELS NO-BOX  
          FRAME f_dependente.
               
FORM "  Nome"   
     "Dt.Nasc."        AT 44
     "Tipo Dependente" AT 55
     SKIP(8)
     reg_dsdopcao[1]   AT 17 NO-LABEL FORMAT "x(7)"
     reg_dsdopcao[2]   AT 32 NO-LABEL FORMAT "x(7)"
     reg_dsdopcao[3]   AT 47 NO-LABEL FORMAT "x(7)"
     WITH ROW 10 COLUMN 4 WIDTH 73 OVERLAY SIDE-LABELS TITLE " DEPENDENTES " 
          FRAME f_regua.

FORM b_dependentes 
     HELP "Pressione ENTER para selecionar ou F4/END para sair"
     WITH ROW 12 COLUMN 5 OVERLAY NO-BOX FRAME f_browse.
          
FORM b_tipos  
     HELP "Pressione ENTER para selecionar ou F4/END para sair"
     WITH ROW 12 COLUMN 31 OVERLAY FRAME f_tipos_dep.

ON RETURN OF b_tipos DO:
   
    IF  AVAILABLE tt-tipos-dependente  THEN
        DO:
            ASSIGN tel_cdtipdep = tt-tipos-dependente.cdtipdep
                   tel_dstipdep = tt-tipos-dependente.dstipdep.
                   
            DISPLAY tel_cdtipdep tel_dstipdep WITH FRAME f_dependente.
        END.
       
   APPLY "GO".

END.

ON ANY-KEY OF b_dependentes IN FRAME f_browse DO:
    
    HIDE MESSAGE NO-PAUSE.

    IF  KEY-FUNCTION(LASTKEY) = "GO"  THEN
        RETURN NO-APPLY.

    IF  KEY-FUNCTION(LASTKEY) = "CURSOR-RIGHT"  THEN
        DO:
            ASSIGN reg_iddopcao = reg_iddopcao + 1.
    
            IF  reg_iddopcao > 3  THEN
                ASSIGN reg_iddopcao = 1.
                
            ASSIGN glb_cddopcao = reg_cddopcao[reg_iddopcao].
        END.
    ELSE        
    IF  KEY-FUNCTION(LASTKEY) = "CURSOR-LEFT"  THEN
        DO:
            ASSIGN reg_iddopcao = reg_iddopcao - 1.

            IF  reg_iddopcao < 1  THEN
                ASSIGN reg_iddopcao = 3.
                 
            ASSIGN glb_cddopcao = reg_cddopcao[reg_iddopcao].
        END.
    ELSE
    IF  KEY-FUNCTION(LASTKEY) = "HELP"  THEN
        APPLY LASTKEY.
    ELSE
    IF  KEY-FUNCTION(LASTKEY) = "RETURN"  THEN
        DO: 
            IF  glb_cddopcao = "A"  OR
                glb_cddopcao = "E"  THEN
                DO:
                    IF  NOT AVAILABLE tt-dependente  THEN
                        RETURN.

                    ASSIGN aux_nrdrowid = tt-dependente.nrdrowid
                           aux_nrdlinha = CURRENT-RESULT-ROW("q_dependentes").
                         
                    b_dependentes:DESELECT-ROWS().
                END.
            ELSE
                ASSIGN aux_nrdrowid = ?
                       aux_nrdlinha = 0.
            
            APPLY "GO".
        END.
    ELSE
        RETURN.
            
    CHOOSE FIELD reg_dsdopcao[reg_iddopcao] PAUSE 0 WITH FRAME f_regua.

END.

ASSIGN aux_flgerlog = TRUE.

DO WHILE TRUE:

    IF  NOT VALID-HANDLE(h-b1wgen0047)  THEN
        RUN sistema/generico/procedures/b1wgen0047.p 
            PERSISTENT SET h-b1wgen0047.

    ASSIGN glb_nmrotina = "DEPENDENTES"
           glb_cddopcao = reg_cddopcao[reg_iddopcao].

    HIDE FRAME f_dependente NO-PAUSE.
   
    DISPLAY reg_dsdopcao WITH FRAME f_regua.
           
    CHOOSE FIELD reg_dsdopcao[reg_iddopcao] PAUSE 0 WITH FRAME f_regua.
    
    RUN obtem-dependentes IN h-b1wgen0047 (INPUT glb_cdcooper, 
                                           INPUT 0,            
                                           INPUT 0,            
                                           INPUT glb_cdoperad, 
                                           INPUT glb_nmdatela, 
                                           INPUT 1,            
                                           INPUT tel_nrdconta, 
                                           INPUT tel_idseqttl, 
                                           INPUT aux_flgerlog,
                                          OUTPUT aux_msgconta,
                                          OUTPUT TABLE tt-dependente).

    /** Gerar log somente na primeira leitura **/
    IF  aux_flgerlog  THEN
        ASSIGN aux_flgerlog = FALSE.
    ELSE
        CLOSE QUERY q_dependentes.
   
    OPEN QUERY q_dependentes FOR EACH tt-dependente NO-LOCK.

    IF  aux_nrdlinha > 0  THEN
        DO:
            IF  aux_nrdlinha > NUM-RESULTS("q_dependentes")  THEN
                ASSIGN aux_nrdlinha = NUM-RESULTS("q_dependentes").

            REPOSITION q_dependentes TO ROW(aux_nrdlinha). 
        END.

    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
    
        UPDATE b_dependentes WITH FRAME f_browse.
        LEAVE.

    END. /** Fim do DO WHILE TRUE **/
   
    IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
        LEAVE.
        
    /*Alteração: Mostra critica se usuario titular em outra conta 
     (Gabriel/DB1)*/
    IF  aux_msgconta <> "" THEN
        DO:
           MESSAGE aux_msgconta. 
           NEXT.
        END.

    { includes/acesso.i }

    RUN obtem-dados-operacao IN h-b1wgen0047 (INPUT glb_cdcooper, 
                                              INPUT 0,            
                                              INPUT 0,            
                                              INPUT glb_cdoperad, 
                                              INPUT glb_nmdatela, 
                                              INPUT 1,            
                                              INPUT tel_nrdconta, 
                                              INPUT tel_idseqttl, 
                                              INPUT glb_cddopcao,
                                              INPUT aux_nrdrowid,
                                              INPUT TRUE,
                                             OUTPUT TABLE tt-dependente,
                                             OUTPUT TABLE tt-tipos-dependente,
                                             OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            RUN mostra-critica.
            NEXT.
        END.

    ASSIGN tel_nmdepend = ""
           tel_dtnascto = ?
           tel_cdtipdep = 0
           tel_dstipdep = "".

    FIND FIRST tt-dependente NO-LOCK NO-ERROR.

    IF  AVAILABLE tt-dependente  THEN
        ASSIGN tel_nmdepend = tt-dependente.nmdepend
               tel_dtnascto = tt-dependente.dtnascto
               tel_cdtipdep = tt-dependente.cdtipdep
               tel_dstipdep = tt-dependente.dstipdep.
   
    DISPLAY tel_nmdepend tel_dtnascto tel_cdtipdep tel_dstipdep
            WITH FRAME f_dependente.

    HIDE MESSAGE NO-PAUSE.
   
    IF  glb_cddopcao <> "E"  THEN 
        DO:  
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
            
                UPDATE tel_nmdepend WHEN glb_cddopcao = "I"
                       tel_dtnascto 
                       tel_cdtipdep
                       WITH FRAME f_dependente

                EDITING:
               
                    READKEY.
                  
                    IF  LASTKEY = KEYCODE("F7")       AND
                        FRAME-FIELD = "tel_cdtipdep"  THEN
                        DO:
                            OPEN QUERY q_tipos 
                                 FOR EACH tt-tipos-dependente NO-LOCK.
                                                
                            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                                UPDATE b_tipos WITH FRAME f_tipos_dep.
                                LEAVE.

                            END. /** Fim do DO WHILE TRUE **/

                            HIDE FRAME f_tipos_dep.
                        END.
                    ELSE            
                        APPLY LASTKEY.  
                 
                END. /** Fim do EDITING **/   

                FIND tt-tipos-dependente WHERE 
                     tt-tipos-dependente.cdtipdep = tel_cdtipdep 
                     NO-LOCK NO-ERROR.
                        
                ASSIGN tel_dstipdep = IF  AVAILABLE tt-tipos-dependente  THEN
                                          tt-tipos-dependente.dstipdep
                                      ELSE
                                          "".
                    
                DISPLAY tel_dstipdep WITH FRAME f_dependente.

                RUN valida-operacao IN h-b1wgen0047 (INPUT glb_cdcooper,
                                                     INPUT 0,            
                                                     INPUT 0,            
                                                     INPUT glb_cdoperad, 
                                                     INPUT glb_nmdatela, 
                                                     INPUT 1,            
                                                     INPUT tel_nrdconta, 
                                                     INPUT tel_idseqttl, 
                                                     INPUT glb_dtmvtolt,
                                                     INPUT glb_cddopcao,
                                                     INPUT aux_nrdrowid,
                                                     INPUT tel_nmdepend,
                                                     INPUT tel_dtnascto,
                                                     INPUT tel_cdtipdep,
                                                     INPUT TRUE,
                                                    OUTPUT TABLE tt-erro).
                                                    
                IF  RETURN-VALUE = "NOK"  THEN 
                    DO:
                        RUN mostra-critica.
                        NEXT.
                    END.

                LEAVE.

            END. /** Fim do DO WHILE TRUE **/

            IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
                NEXT.
        END.

    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
            
        ASSIGN aux_confirma = "N"
               glb_cdcritic = 78.
        RUN fontes/critic.p.
        ASSIGN glb_cdcritic = 0.

        BELL.
        MESSAGE COLOR NORMAL glb_dscritic UPDATE aux_confirma.
          
        LEAVE.
        
    END. /** Fim do DO WHILE TRUE **/

    IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  OR
        aux_confirma <> "S"                 THEN
        DO:
            ASSIGN glb_cdcritic = 79.
            RUN fontes/critic.p.
            ASSIGN glb_cdcritic = 0.

            BELL.
            MESSAGE glb_dscritic.
            
            NEXT.
        END.    
    
    IF  VALID-HANDLE(h-b1wgen0047) THEN
        DELETE PROCEDURE h-b1wgen0047.

    RUN sistema/generico/procedures/b1wgen0047.p PERSISTENT SET h-b1wgen0047.

    RUN gerenciar-dependente IN h-b1wgen0047 (INPUT glb_cdcooper,
                                              INPUT 0,
                                              INPUT 0,
                                              INPUT glb_cdoperad,
                                              INPUT glb_nmdatela,
                                              INPUT 1,
                                              INPUT tel_nrdconta,
                                              INPUT tel_idseqttl,
                                              INPUT glb_dtmvtolt,
                                              INPUT glb_cddopcao,
                                              INPUT aux_nrdrowid,
                                              INPUT tel_nmdepend,
                                              INPUT tel_dtnascto,
                                              INPUT tel_cdtipdep,
                                              INPUT TRUE,
                                             OUTPUT aux_tpatlcad,
                                             OUTPUT aux_msgatcad,
                                             OUTPUT aux_chavealt,
                                             OUTPUT aux_mvgrecad,
                                             OUTPUT TABLE tt-erro).
    
    IF  RETURN-VALUE = "NOK"  THEN 
        DO:
            RUN mostra-critica.
            NEXT.
        END.

    IF  aux_mvgrecad <> "" THEN
        MESSAGE aux_mvgrecad.

    IF  glb_cddopcao <> "I"  THEN
        RUN proc_altcad (INPUT "b1wgen0047.p").
    
    ASSIGN glb_dscritic = "Dependente " + (IF  glb_cddopcao = "A"  THEN
                                               "alterado"
                                           ELSE
                                           IF  glb_cddopcao = "E"  THEN
                                               "excluido"
                                           ELSE
                                               "cadastrado") + " com sucesso!".
    MESSAGE glb_dscritic.
    
    IF  VALID-HANDLE(h-b1wgen0047) THEN
        DELETE PROCEDURE h-b1wgen0047.

END. /** Fim do DO WHILE TRUE **/

HIDE FRAME f_dependente NO-PAUSE.

IF  VALID-HANDLE(h-b1wgen0047) THEN
    DELETE PROCEDURE h-b1wgen0047.

/*...........................................................................*/

PROCEDURE mostra-critica:

    FIND FIRST tt-erro NO-LOCK NO-ERROR.

    IF  AVAILABLE tt-erro  THEN
        DO:
            BELL.
            MESSAGE tt-erro.dscritic.
        END.

END PROCEDURE.

/*...........................................................................*/
