/* ............................................................................

   Programa: Fontes/contas_telefones.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Evandro
   Data    : Marco/2006                   Ultima Atualizacao: 22/09/2010

   Dados referentes ao programa:
   
   Frequencia: Diario (on-line)
   Objetivo  : Efetuar manutencao dos dados referentes aos telefones do
               Associado / Empresa.

   Alteracoes: 13/12/2006 - Efetuado acerto leitura tabela OPETELEFON(Mirtes)
   
               18/05/2010 - Utilizar BO b1wgen0070.p na rotina (David).
               
               22/09/2010 - Bloqueia edição em conta filha (Gabriel, DB1).
               
               01/02/2016 - Melhoria 147 - Adicionar Campos e Aprovacao de 
			                Transferencia entre PAs (Heitor - RKAM)

.............................................................................*/

{ sistema/generico/includes/b1wgen0070tt.i }
{ sistema/generico/includes/var_internet.i }
{ includes/var_online.i }
{ includes/var_contas.i }
{ sistema/generico/includes/b1wgenvlog.i &VAR-GERAL=SIM &SESSAO-DESKTOP=SIM }

DEF VAR reg_cddopcao AS CHAR EXTENT 3 INIT ["A","E","I"]               NO-UNDO.
DEF VAR reg_dsdopcao AS CHAR EXTENT 3 INIT ["Alterar",
                                            "Excluir",
                                            "Incluir"]                 NO-UNDO.
DEF VAR reg_contador AS INTE          INIT 3                           NO-UNDO.

DEF VAR tel_destptfc AS CHAR                                           NO-UNDO.
DEF VAR tel_nmopetfn AS CHAR                                           NO-UNDO.
DEF VAR tel_nrdddtfc LIKE craptfc.nrdddtfc                             NO-UNDO.
DEF VAR tel_nrtelefo LIKE craptfc.nrtelefo                             NO-UNDO.
DEF VAR tel_nrdramal LIKE craptfc.nrdramal                             NO-UNDO.
DEF VAR tel_nmpescto LIKE craptfc.nmpescto                             NO-UNDO.
DEF VAR tel_secpscto LIKE craptfc.secpscto                             NO-UNDO.

DEF VAR aux_lstpfone AS CHAR 
                     INIT "RESIDENCIAL,CELULAR,COMERCIAL,CONTATO"      NO-UNDO.
DEF VAR aux_lsfonass AS CHAR                                           NO-UNDO.
DEF VAR aux_tptelefo AS INTE                                           NO-UNDO.
DEF VAR aux_cdopetfn AS INTE                                           NO-UNDO.
DEF VAR aux_nrdlinha AS INTE                                           NO-UNDO.
DEF VAR aux_inpessoa AS INTE                                           NO-UNDO.
DEF VAR aux_flgerlog AS LOGI                                           NO-UNDO.
DEF VAR aux_nrdrowid AS ROWID                                          NO-UNDO.
DEF VAR aux_msgconta AS CHAR                                           NO-UNDO.
DEF VAR aux_msgrvcad AS CHAR                                           NO-UNDO.

DEF VAR h-b1wgen0070 AS HANDLE                                         NO-UNDO.

DEF QUERY q_telefones FOR tt-telefone-cooperado.
DEF QUERY q_operadora FOR tt-operadoras-celular.
    
DEF BROWSE b_telefones QUERY q_telefones
    DISP tt-telefone-cooperado.nmopetfn COLUMN-LABEL "Operadora"         
                                        FORMAT "x(12)"
         tt-telefone-cooperado.nrdddtfc COLUMN-LABEL "DDD"               
                                        FORMAT "999"
         tt-telefone-cooperado.nrtelefo COLUMN-LABEL "Telefone"          
                                        FORMAT "zzzzzzzzz9"
         tt-telefone-cooperado.nrdramal COLUMN-LABEL "Ramal"             
                                        FORMAT "zzzz"
         tt-telefone-cooperado.destptfc COLUMN-LABEL "Identificacao"     
                                        FORMAT "x(11)"
         tt-telefone-cooperado.secpscto COLUMN-LABEL "Setor"             
                                        FORMAT "x(08)"
         tt-telefone-cooperado.nmpescto COLUMN-LABEL "Pessoa de Contato" 
                                        FORMAT "x(17)"
         WITH 5 DOWN NO-BOX.

DEF BROWSE b_operadora QUERY q_operadora
    DISP tt-operadoras-celular.nmopetfn FORMAT "x(40)"
         WITH 4 DOWN NO-LABELS TITLE "OPERADORA".

FORM tel_destptfc AT 15 LABEL "Identificacao" FORMAT "x(11)"
                  HELP "Use as setas para selecionar o tipo de telefone"
     SKIP
     tel_nrdddtfc AT 25 LABEL "DDD"
                  HELP "Informe o codigo do DDD"
     SKIP
     tel_nrtelefo AT 20 LABEL "Telefone"
                  HELP "Informe o numero do telefone"
     SKIP
     tel_nmopetfn AT 19 LABEL "Operadora" FORMAT "x(14)"
                  HELP "Pressione F7 para informar a operadora"
     SKIP
     tel_nrdramal AT 23 LABEL "Ramal" FORMAT "zzzz"
                  HELP "Informe o numero do ramal"
     SKIP
     tel_secpscto AT 23 LABEL "Setor" FORMAT "x(08)"
                  HELP "Informe o setor do telefone"        
     SKIP
     tel_nmpescto AT 11 LABEL "Pessoa de Contato" FORMAT "x(30)"
                  HELP "Informe o nome da pessoa de contato"
     WITH ROW 12 COLUMN 2 WIDTH 78 OVERLAY SIDE-LABELS NO-BOX FRAME f_telefones.

FORM SKIP(8)
     reg_dsdopcao[1] AT 15 FORMAT "x(7)"
     reg_dsdopcao[2] AT 35 FORMAT "x(7)"
     reg_dsdopcao[3] AT 55 FORMAT "x(7)"
     WITH ROW 11 WIDTH 80 OVERLAY NO-LABEL TITLE " TELEFONES " FRAME f_regua.

FORM b_telefones HELP "Pressione ENTER para selecionar ou F4/END para sair."
     WITH ROW 12 COLUMN 2 OVERLAY NO-BOX NO-LABEL FRAME f_browse.

FORM b_operadora HELP "Pressione ENTER para selecionar ou F4/END para sair."
     WITH NO-BOX OVERLAY ROW 13 CENTERED FRAME f_zoom_operadora.

ON ANY-KEY OF b_telefones IN FRAME f_browse DO:
    
    HIDE MESSAGE NO-PAUSE.

    IF  KEY-FUNCTION(LASTKEY) = "CURSOR-RIGHT"  THEN
        DO:
            ASSIGN reg_contador = reg_contador + 1.

            IF  reg_contador > 3  THEN
                ASSIGN reg_contador = 1.
                 
            ASSIGN glb_cddopcao = reg_cddopcao[reg_contador].
        END.
    ELSE        
    IF  KEY-FUNCTION(LASTKEY) = "CURSOR-LEFT"  THEN
        DO:
            ASSIGN reg_contador = reg_contador - 1.

            IF  reg_contador < 1  THEN
                ASSIGN reg_contador = 3.
                 
            ASSIGN glb_cddopcao = reg_cddopcao[reg_contador].
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
                    IF  NOT AVAILABLE tt-telefone-cooperado  THEN
                        RETURN.

                    ASSIGN aux_nrdrowid = tt-telefone-cooperado.nrdrowid
                           aux_nrdlinha = CURRENT-RESULT-ROW("q_telefones").
                         
                    b_telefones:DESELECT-ROWS().
                END.
            ELSE
                ASSIGN aux_nrdrowid = ?
                       aux_nrdlinha = 0.
                         
            APPLY "GO".
        END.
    ELSE
        RETURN.
            
    CHOOSE FIELD reg_dsdopcao[reg_contador] PAUSE 0 WITH FRAME f_regua.

END.

ON RETURN OF b_operadora IN FRAME f_zoom_operadora DO:
       
    ASSIGN aux_cdopetfn = tt-operadoras-celular.cdopetfn
           tel_nmopetfn = tt-operadoras-celular.nmopetfn.

    DISPLAY tel_nmopetfn WITH FRAME f_telefones.

    APPLY "GO".

END.

ON LEAVE OF tel_destptfc IN FRAME f_telefones DO:

    RUN configura-edicao-campos.
    
END.

ON ENTRY OF tel_destptfc IN FRAME f_telefones DO:

    RUN configura-edicao-campos.
    
END.

ON ENTRY OF tel_nmopetfn IN FRAME f_telefones DO:

    RUN zoom_operadora.
    
END.

ASSIGN aux_flgerlog = TRUE.

DO WHILE TRUE:

    IF  NOT VALID-HANDLE(h-b1wgen0070)  THEN
        RUN sistema/generico/procedures/b1wgen0070.p 
            PERSISTENT SET h-b1wgen0070.

    ASSIGN glb_nmrotina = "TELEFONES"
           glb_cddopcao = reg_cddopcao[reg_contador].
    
    DISPLAY reg_dsdopcao WITH FRAME f_regua.
            
    CHOOSE FIELD reg_dsdopcao[reg_contador] PAUSE 0 WITH FRAME f_regua.
  
    RUN obtem-telefone-cooperado IN h-b1wgen0070 
                                (INPUT glb_cdcooper,
                                 INPUT 0,
                                 INPUT 0,
                                 INPUT glb_cdoperad,
                                 INPUT glb_nmdatela,
                                 INPUT 1,
                                 INPUT tel_nrdconta,
                                 INPUT tel_idseqttl,
                                 INPUT aux_flgerlog,
                                OUTPUT aux_msgconta,
                                OUTPUT TABLE tt-erro,
                                OUTPUT TABLE tt-telefone-cooperado).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            RUN mostra-critica.
            LEAVE.
        END.

    /** Gerar log somente na primeira leitura **/
    IF  aux_flgerlog  THEN
        ASSIGN aux_flgerlog = FALSE.
    ELSE
        CLOSE QUERY q_telefones.

    OPEN QUERY q_telefones FOR EACH tt-telefone-cooperado NO-LOCK.

    IF  aux_nrdlinha > 0  THEN
        DO:
            IF  aux_nrdlinha > NUM-RESULTS("q_telefones")  THEN
                ASSIGN aux_nrdlinha = NUM-RESULTS("q_telefones").

            REPOSITION q_telefones TO ROW(aux_nrdlinha).
        END.
                                          
    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

        UPDATE b_telefones WITH FRAME f_browse.
        LEAVE.

    END. /** Fim do DO WHILE TRUE **/
    
    IF  KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
        LEAVE.

    /*Alteração: Mostra critica se usuario titular em outra conta 
     (Gabriel/DB1)*/
    IF  aux_msgconta <> "" THEN
        DO:
           MESSAGE aux_msgconta. 
           NEXT.
        END.

    { includes/acesso.i }
  
    RUN obtem-dados-gerenciar-telefone IN h-b1wgen0070 
                                      (INPUT glb_cdcooper,
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
                                      OUTPUT aux_inpessoa,
                                      OUTPUT TABLE tt-erro,
                                      OUTPUT TABLE tt-operadoras-celular,
                                      OUTPUT TABLE tt-telefone-cooperado).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            RUN mostra-critica.
            NEXT.
        END.

    ASSIGN aux_tptelefo = 1
           aux_cdopetfn = 0
           tel_destptfc = ENTRY(aux_tptelefo,aux_lstpfone)
           tel_nmopetfn = ""
           tel_nrdddtfc = 0
           tel_nrtelefo = 0
           tel_nrdramal = 0
           tel_secpscto = ""
           tel_nmpescto = "".

    HIDE MESSAGE NO-PAUSE.

    IF  glb_cddopcao = "I"  THEN
        DO:
            ASSIGN aux_lsfonass = "".
  
            FOR EACH tt-telefone-cooperado NO-LOCK:

                ASSIGN aux_lsfonass = IF  aux_lsfonass = ""  THEN
                                          tt-telefone-cooperado.nrfonass
                                      ELSE
                                          aux_lsfonass + "/" + 
                                          tt-telefone-cooperado.nrfonass.

            END. /** Fim do FOR EACH tt-telefone-cooperado **/

            RUN mostra-fone-associado.
  
            RUN informa-dados.

            IF  RETURN-VALUE = "NOK"  THEN
                NEXT.
        END.
    ELSE
        DO: 
            FIND FIRST tt-telefone-cooperado NO-LOCK NO-ERROR.

            IF  AVAILABLE tt-telefone-cooperado  THEN
                ASSIGN tel_destptfc = tt-telefone-cooperado.destptfc
                       tel_nmopetfn = tt-telefone-cooperado.nmopetfn
                       tel_nrdddtfc = tt-telefone-cooperado.nrdddtfc
                       tel_nrtelefo = tt-telefone-cooperado.nrtelefo
                       tel_nrdramal = tt-telefone-cooperado.nrdramal
                       tel_secpscto = tt-telefone-cooperado.secpscto
                       tel_nmpescto = tt-telefone-cooperado.nmpescto
                       aux_tptelefo = tt-telefone-cooperado.tptelefo
                       aux_cdopetfn = tt-telefone-cooperado.cdopetfn.
        
            DISPLAY tel_destptfc
                    tel_nmopetfn
                    tel_nrdddtfc
                    tel_nrtelefo
                    tel_nrdramal
                    tel_secpscto
                    tel_nmpescto
                    WITH FRAME f_telefones.
             
            IF  glb_cddopcao = "A"  THEN
                DO:
                    RUN informa-dados.

                    IF  RETURN-VALUE = "NOK"  THEN
                        NEXT.
                END.
            ELSE 
            IF  glb_cddopcao = "E"  THEN
                DO:
                    RUN validar-dados-informados.

                    IF  RETURN-VALUE ="NOK"  THEN
                        NEXT.    
                END.
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
             
            HIDE FRAME f_telefones NO-PAUSE.

            NEXT.
        END.

    IF  VALID-HANDLE(h-b1wgen0070)  THEN
        DELETE OBJECT h-b1wgen0070.

    RUN sistema/generico/procedures/b1wgen0070.p PERSISTENT SET h-b1wgen0070.

    RUN gerenciar-telefone IN h-b1wgen0070 (INPUT glb_cdcooper,
                                            INPUT 0,
                                            INPUT 0,
                                            INPUT glb_cdoperad,
                                            INPUT glb_nmdatela,
                                            INPUT 1,
                                            INPUT tel_nrdconta,
                                            INPUT tel_idseqttl,
                                            INPUT glb_cddopcao,
                                            INPUT glb_dtmvtolt,
                                            INPUT aux_nrdrowid,
                                            INPUT aux_tptelefo,
                                            INPUT tel_nrdddtfc,
                                            INPUT tel_nrtelefo,
                                            INPUT tel_nrdramal,
                                            INPUT tel_secpscto,
                                            INPUT tel_nmpescto,
                                            INPUT aux_cdopetfn,
                                            INPUT "A",
                                            INPUT TRUE,
                                            INPUT 1,
                                            INPUT 2,
                                           OUTPUT aux_tpatlcad,
                                           OUTPUT aux_msgatcad,
                                           OUTPUT aux_chavealt,
                                           OUTPUT aux_msgrvcad,
                                           OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            RUN mostra-critica.
            HIDE FRAME f_telefones NO-PAUSE.
            NEXT.
        END.

    RUN proc_altcad (INPUT "b1wgen0070.p").

    IF  RETURN-VALUE <> "OK"  THEN
        NEXT.
    
    IF  VALID-HANDLE(h-b1wgen0070)  THEN
        DELETE OBJECT h-b1wgen0070.

    IF aux_msgrvcad <> "" THEN
       MESSAGE aux_msgrvcad.

    HIDE FRAME f_telefones NO-PAUSE.
    
END. /** Fim do DO WHILE TRUE **/

IF  VALID-HANDLE(h-b1wgen0070)  THEN
    DELETE PROCEDURE h-b1wgen0070.

HIDE MESSAGE NO-PAUSE.

/*...........................................................................*/

PROCEDURE informa-dados:

    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
             
        UPDATE tel_destptfc 
               tel_nrdddtfc 
               tel_nrtelefo 
               tel_nmopetfn 
               tel_nrdramal 
               tel_secpscto 
               tel_nmpescto
               WITH FRAME f_telefones
            
        EDITING:
        
            READKEY.

            IF  FRAME-FIELD = "tel_destptfc"  THEN
                DO:
                    IF  KEYFUNCTION(LASTKEY) = "CURSOR-UP"     OR
                        KEYFUNCTION(LASTKEY) = "CURSOR-RIGHT"  THEN
                        DO:
                            IF  aux_tptelefo > NUM-ENTRIES(aux_lstpfone)  THEN
                                aux_tptelefo = NUM-ENTRIES(aux_lstpfone).
                  
                            aux_tptelefo = aux_tptelefo - 1.
        
                            IF  aux_tptelefo = 0  THEN
                                aux_tptelefo = NUM-ENTRIES(aux_lstpfone).
                      
                            tel_destptfc = ENTRY(aux_tptelefo,aux_lstpfone).
                    
                            DISPLAY tel_destptfc WITH FRAME f_telefones.
                        END.
                    ELSE
                    IF  KEYFUNCTION(LASTKEY) = "CURSOR-DOWN"  OR
                        KEYFUNCTION(LASTKEY) = "CURSOR-LEFT"  THEN
                        DO:
                            aux_tptelefo = aux_tptelefo + 1.
        
                            IF  aux_tptelefo > NUM-ENTRIES(aux_lstpfone)  THEN
                                aux_tptelefo = 1.
        
                            tel_destptfc = ENTRY(aux_tptelefo,aux_lstpfone).
        
                            DISPLAY tel_destptfc WITH FRAME f_telefones.
                        END.
                    ELSE
                    IF  KEYFUNCTION(LASTKEY) = "RETURN"     OR
                        KEYFUNCTION(LASTKEY) = "BACK-TAB"   OR
                        KEYFUNCTION(LASTKEY) = "GO"         OR 
                        KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
                        APPLY LASTKEY.                    
                END.
            ELSE
            IF  FRAME-FIELD = "tel_nmopetfn"  THEN
                DO:
                    IF  LASTKEY = KEYCODE("F7")  THEN
                        DO:
                            RUN zoom_operadora.

                            IF  glb_cddopcao = "I"  THEN
                                MESSAGE "Telefones:" aux_lsfonass.
                        END.
                    ELSE
                    IF  KEYFUNCTION(LASTKEY) = "CURSOR-UP"     OR
                        KEYFUNCTION(LASTKEY) = "CURSOR-DOWN"   OR
                        KEYFUNCTION(LASTKEY) = "CURSOR-RIGHT"  OR
                        KEYFUNCTION(LASTKEY) = "CURSOR-LEFT"   OR 
                        KEYFUNCTION(LASTKEY) = "RETURN"        OR
                        KEYFUNCTION(LASTKEY) = "BACK-TAB"      OR
                        KEYFUNCTION(LASTKEY) = "GO"            OR 
                        KEYFUNCTION(LASTKEY) = "END-ERROR"     THEN
                        APPLY LASTKEY.
                END.
            ELSE
                APPLY LASTKEY.
           
        END. /** Fim do EDITING **/

        RUN validar-dados-informados.

        IF  RETURN-VALUE ="NOK"  THEN
            NEXT.

        LEAVE.

    END. /** Fim do DO WHILE TRUE **/

    IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
        DO:
            HIDE FRAME f_emails NO-PAUSE.
            RETURN "NOK".
        END.

    RETURN "OK".

END PROCEDURE.

PROCEDURE configura-edicao-campos:

    ENABLE ALL WITH FRAME f_telefones.

    IF  aux_inpessoa = 1                   AND   
        INPUT tel_destptfc <> "COMERCIAL"  THEN
        DO:
            ASSIGN tel_secpscto = "".

            DISPLAY tel_secpscto WITH FRAME f_telefones.

            DISABLE tel_secpscto WITH FRAME f_telefones.
        END.

    IF  INPUT tel_destptfc = "RESIDENCIAL"  THEN
        DO:
            ASSIGN aux_cdopetfn = 0
                   tel_nmopetfn = ""
                   tel_nrdramal = 0
                   tel_nmpescto = "".
                                            
            DISPLAY tel_nmopetfn tel_nrdramal tel_nmpescto
                    WITH FRAME f_telefones.
                                                   
            DISABLE tel_nmopetfn tel_nrdramal tel_nmpescto
                    WITH FRAME f_telefones.
        END.
    ELSE
    IF  INPUT tel_destptfc = "CELULAR"  THEN
        DO:
            ASSIGN tel_nrdramal = 0
                   tel_nmpescto = "".
                                           
            DISPLAY tel_nrdramal tel_nmpescto WITH FRAME f_telefones.
                                                  
            DISABLE tel_nrdramal tel_nmpescto WITH FRAME f_telefones.
        END.
    ELSE                                    
    IF  INPUT tel_destptfc = "COMERCIAL"  THEN
        DO:
            ASSIGN aux_cdopetfn = 0
                   tel_nmopetfn = "".
                     
            DISPLAY tel_nmopetfn WITH FRAME f_telefones.

            DISABLE tel_nmopetfn WITH FRAME f_telefones.
        END.
    ELSE                                    
    IF  INPUT tel_destptfc = "CONTATO"  THEN
        DO:
            ASSIGN aux_cdopetfn = 0
                   tel_nmopetfn = ""
                   tel_nrdramal = 0.
                                            
            DISPLAY tel_nmopetfn tel_nrdramal WITH FRAME f_telefones.
                                                    
            DISABLE tel_nmopetfn tel_nrdramal WITH FRAME f_telefones.
        END.

END PROCEDURE.

PROCEDURE validar-dados-informados:

    RUN validar-telefone IN h-b1wgen0070 (INPUT glb_cdcooper,
                                          INPUT 0,
                                          INPUT 0,
                                          INPUT glb_cdoperad,
                                          INPUT glb_nmdatela,
                                          INPUT 1,
                                          INPUT tel_nrdconta,
                                          INPUT tel_idseqttl,
                                          INPUT glb_cddopcao,
                                          INPUT aux_nrdrowid,
                                          INPUT aux_tptelefo,
                                          INPUT tel_nrdddtfc,
                                          INPUT tel_nrtelefo,
                                          INPUT tel_nrdramal,
                                          INPUT tel_secpscto,
                                          INPUT tel_nmpescto,
                                          INPUT aux_cdopetfn,
                                          INPUT TRUE,
                                          INPUT 0, /* Conta replicadora */
                                         OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            RUN mostra-critica.
            HIDE FRAME f_telefones NO-PAUSE.
            RETURN "NOK".
        END.

    RETURN "OK".

END PROCEDURE.
 
PROCEDURE zoom_operadora:
    
    IF  QUERY q_operadora:IS-OPEN  THEN
        CLOSE QUERY q_operadora.

    OPEN QUERY q_operadora FOR EACH tt-operadoras-celular NO-LOCK.
  
    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

        UPDATE b_operadora WITH FRAME f_zoom_operadora.
        LEAVE.

    END. /** Fim do DO WHILE TRUE **/
    
    HIDE FRAME f_zoom_operadora.

    RUN mostra-fone-associado.
    
END PROCEDURE.

PROCEDURE mostra-fone-associado:

    IF  glb_cddopcao <> "I"  THEN
        RETURN.

    IF  aux_lsfonass <> ""  THEN
        DO:
            IF  LENGTH(aux_lsfonass) > 55  THEN
                DO:
                    MESSAGE "Telefones:" SUBSTR(aux_lsfonass,1,55).
                    MESSAGE SUBSTR(aux_lsfonass,56,55).
                END.
            ELSE
                MESSAGE "Telefones:" aux_lsfonass.
        END.

END PROCEDURE.

PROCEDURE mostra-critica:

    FIND FIRST tt-erro NO-LOCK NO-ERROR.

    IF  AVAILABLE tt-erro  THEN
        DO:
            BELL.
            MESSAGE tt-erro.dscritic.
        END.

END PROCEDURE.

/*...........................................................................*/

