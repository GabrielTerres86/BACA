/* .............................................................................

   Programa: Fontes/contas_contatos_juridica.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Evandro
   Data    : Maio/2006                   Ultima Atualizacao: 11/04/2011

   Dados referentes ao programa:
   
   Frequencia: Diario (on-line)
   Objetivo  : Efetuar manutencao dos dados referentes aos contatos do
               Associado pela tela CONTAS (Pessoa Juridica).
               
   Observacao: O campo "crapavt.nrctremp" eh usado para sequencial de inclusao
               de registro (usa incremento de 1).

   Alteracoes: 20/03/2007 - Alterado posicao no frame f_contatos_juridica do
                            campo tel_dsdemail (Elton).

               31/07/2007 - Aumentado o tamanho do e-mail para 40 caracteres
                            (Evandro).
                            
               19/11/2009 - Utilizar a BO b1wgen0049.p (David). 
               
               01/07/2010 - Ajuste da alteracao acima (David).
               
               11/04/2011 - Inclusão de CEP integrado. (André - DB1).
               
..............................................................................*/

{ sistema/generico/includes/b1wgen0049tt.i}
{ sistema/generico/includes/b1wgen0038tt.i}
{ sistema/generico/includes/var_internet.i}
{ includes/var_online.i }
{ includes/var_contas.i }
{ sistema/generico/includes/b1wgenvlog.i &VAR-GERAL=SIM &SESSAO-DESKTOP=SIM }

DEF VAR reg_cddopcao AS CHAR EXTENT 4 INIT ["A","C","E","I"]           NO-UNDO.
DEF VAR reg_dsdopcao AS CHAR EXTENT 4 INIT ["Alterar",
                                            "Consultar",
                                            "Excluir",
                                            "Incluir"]                 NO-UNDO.
DEF VAR reg_iddopcao AS INTE                                           NO-UNDO.

DEF VAR tel_nrdctato LIKE crapavt.nrdctato                             NO-UNDO.
DEF VAR tel_nmextemp LIKE crapavt.nmextemp                             NO-UNDO.
DEF VAR tel_cddbanco LIKE crapavt.cddbanco                             NO-UNDO.
DEF VAR tel_cdageban LIKE crapavt.cdagenci                             NO-UNDO.
DEF VAR tel_dsproftl LIKE crapavt.dsproftl                             NO-UNDO.
DEF VAR tel_nrcepend LIKE crapavt.nrcepend                             NO-UNDO.
DEF VAR tel_dsendere LIKE crapavt.dsendres[1]                          NO-UNDO.
DEF VAR tel_nrendere LIKE crapavt.nrendere                             NO-UNDO.
DEF VAR tel_complend LIKE crapavt.complend                             NO-UNDO.
DEF VAR tel_nmbairro AS CHAR FORMAT "X(40)"                            NO-UNDO.
DEF VAR tel_nmcidade AS CHAR FORMAT "X(25)"                            NO-UNDO.
DEF VAR tel_cdufende LIKE crapavt.cdufresd                             NO-UNDO.
DEF VAR tel_nrcxapst LIKE crapavt.nrcxapst                             NO-UNDO.
DEF VAR tel_nrtelefo LIKE crapavt.nrtelefo                             NO-UNDO.

DEF VAR aux_nrdrowid AS ROWID                                          NO-UNDO.
DEF VAR aux_nrdlinha AS INTE                                           NO-UNDO.
DEF VAR aux_flgerlog AS LOGI                                           NO-UNDO.

DEF VAR h-b1wgen0049 AS HANDLE                                         NO-UNDO.

DEF QUERY q_contatos FOR tt-contato-juridica.

DEF BROWSE b_contatos QUERY q_contatos
    DISPLAY tt-contato-juridica.nrdctato LABEL "Conta/dv" FORMAT "zzzz,zzz,9"
            tt-contato-juridica.nmdavali LABEL "Nome"     FORMAT "x(20)"
            tt-contato-juridica.nrtelefo LABEL "Telefone" FORMAT "x(15)"
            tt-contato-juridica.dsdemail LABEL "E-Mail"   FORMAT "x(26)"
            WITH NO-LABEL 8 DOWN NO-BOX.

FORM SKIP(1)
     tel_nrdctato AT 01 LABEL "Conta/dv"
                        HELP "Informe a conta ou 0 para nao cooperado"
     tel_nmdavali AT 27 LABEL "Nome"
                        HELP "Informe o nome"
     SKIP
     tel_nmextemp AT 02 LABEL "Empresa" 
                        HELP "Informe o nome da empresa"
     tel_cddbanco AT 47 LABEL "Banco"      
                        HELP "Informe o codigo do banco"
     tel_cdageban AT 60 LABEL "Agencia"
                        HELP "Informe o codigo da agencia do banco"
     SKIP
     tel_dsproftl AT 04 LABEL "Cargo"
                        HELP "Informe o cargo"
     SKIP(1)
     tel_nrcepend AT 04 LABEL "CEP" FORMAT "99999,999"
                HELP "Informe o CEP do endereco ou pressiona F7 para pesquisar"
     tel_dsendere AT 28 LABEL "Endereco"
                        HELP "Informe o endereco"
     SKIP
     tel_nrendere AT 03 LABEL "Nro."
                        HELP "Informe o numero do endereco"
     tel_complend AT 25 LABEL "Complemento"
                        HELP "Informe o complemento do endereco"
     SKIP
     tel_nmbairro AT 01 LABEL "Bairro"
                        HELP "Informe o bairro do endereco"
    
     tel_nrcxapst AT 50 LABEL "Caixa Postal"
                        HELP "Informe o numero da caixa postal"
     SKIP
     tel_nmcidade AT 01 LABEL "Cidade"
                        HELP "Informe a cidade do endereco"
     tel_cdufende AT 50 LABEL "U.F."       
                        HELP "Informe o Estado do endereco"
     SKIP
     tel_nrtelefo AT 01 LABEL "Telefones"
                        HELP "Informe o(s) telefone(s)"
     SKIP
     tel_dsdemail AT 04 LABEL "E-Mail"
                        HELP "Informe o e-mail"
     WITH ROW 8 WIDTH 78 OVERLAY SIDE-LABELS NO-BOX CENTERED 
          FRAME f_contatos_juridica.
          
FORM SKIP(12)
     reg_dsdopcao[1] AT 15 NO-LABEL FORMAT "x(7)"
     reg_dsdopcao[2] AT 28 NO-LABEL FORMAT "x(9)"
     reg_dsdopcao[3] AT 43 NO-LABEL FORMAT "x(7)"
     reg_dsdopcao[4] AT 56 NO-LABEL FORMAT "x(7)"
     WITH ROW 7 WIDTH 80 OVERLAY SIDE-LABELS TITLE  
          " REFERENCIAS (PESSOAIS/COMERCIAIS/BANCARIAS) " 
          FRAME f_regua.

FORM b_contatos 
     HELP "Pressione ENTER para selecionar / F4 ou END para sair"
     WITH ROW 9 COLUMN 2 OVERLAY NO-BOX FRAME f_browse.

/* Inclusão de CEP integrado. (André - DB1) */
ON GO, LEAVE OF tel_nrcepend IN FRAME f_contatos_juridica DO:
    IF  INPUT tel_nrcepend = 0  THEN
        RUN Limpa_Endereco.
END.

ON RETURN OF tel_nrcepend IN FRAME f_contatos_juridica DO:

    HIDE MESSAGE NO-PAUSE.

    ASSIGN INPUT tel_nrcepend.

    IF  tel_nrcepend <> 0  THEN 
        DO:
            RUN fontes/zoom_endereco.p (INPUT tel_nrcepend,
                                        OUTPUT TABLE tt-endereco).
    
            FIND FIRST tt-endereco NO-LOCK NO-ERROR.
    
            IF  AVAIL tt-endereco THEN
                DO:
                    ASSIGN tel_nrcepend = tt-endereco.nrcepend 
                           tel_dsendere = tt-endereco.dsendere 
                           tel_nmbairro = tt-endereco.nmbairro 
                           tel_nmcidade = tt-endereco.nmcidade 
                           tel_cdufende = tt-endereco.cdufende.
                END.
            ELSE
                DO:
                    IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
                        RETURN NO-APPLY.
                        
                    MESSAGE "CEP nao cadastrado.".
                    RUN Limpa_Endereco.
                    RETURN NO-APPLY.
                END.
        END.
    ELSE
        RUN Limpa_Endereco.

    DISPLAY tel_nrcepend  tel_dsendere
            tel_nmbairro  tel_nmcidade
            tel_cdufende
            WITH FRAME f_contatos_juridica.

    NEXT-PROMPT tel_nrendere WITH FRAME f_contatos_juridica.
END.

ON ANY-KEY OF b_contatos IN FRAME f_browse DO:

    IF  KEYFUNCTION(LASTKEY) = "GO"  THEN
        RETURN NO-APPLY.

    IF  KEY-FUNCTION(LASTKEY) = "CURSOR-RIGHT"  THEN
        DO:
            ASSIGN reg_iddopcao = reg_iddopcao + 1.
    
            IF  reg_iddopcao > 4  THEN
                ASSIGN reg_iddopcao = 1.
                
            ASSIGN glb_cddopcao = reg_cddopcao[reg_iddopcao].
        END.
    ELSE        
    IF  KEY-FUNCTION(LASTKEY) = "CURSOR-LEFT"  THEN
        DO:
            ASSIGN reg_iddopcao = reg_iddopcao - 1.

            IF  reg_iddopcao < 1  THEN
                ASSIGN reg_iddopcao = 4.
                
            ASSIGN glb_cddopcao = reg_cddopcao[reg_iddopcao].
        END.
    ELSE
    IF  KEY-FUNCTION(LASTKEY) = "HELP"  THEN
        APPLY LASTKEY.
    ELSE
    IF  KEY-FUNCTION(LASTKEY) = "RETURN"  THEN
        DO:
            IF  glb_cddopcao <> "I"  THEN
                DO:
                    IF  NOT AVAILABLE tt-contato-juridica  THEN
                        RETURN.

                    ASSIGN aux_nrdrowid = tt-contato-juridica.nrdrowid
                           aux_nrdlinha = CURRENT-RESULT-ROW("q_contatos").
                         
                    /* Desmarca todas as linhas do browse para poder remarcar*/
                    b_contatos:DESELECT-ROWS().
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

ASSIGN reg_iddopcao = 2
       aux_flgerlog = TRUE. 

DO WHILE TRUE:

    IF  NOT VALID-HANDLE(h-b1wgen0049)  THEN
        RUN sistema/generico/procedures/b1wgen0049.p 
            PERSISTENT SET h-b1wgen0049.
       
    ASSIGN glb_nmrotina = "REFERENCIAS"
           glb_cddopcao = reg_cddopcao[reg_iddopcao].
    
    HIDE FRAME f_contatos_juridica NO-PAUSE.

    DISPLAY reg_dsdopcao WITH FRAME f_regua.
   
    CHOOSE FIELD reg_dsdopcao[reg_iddopcao] PAUSE 0 WITH FRAME f_regua.

    RUN obtem-contatos IN h-b1wgen0049 (INPUT glb_cdcooper, 
                                        INPUT 0,            
                                        INPUT 0,            
                                        INPUT glb_cdoperad, 
                                        INPUT glb_nmdatela, 
                                        INPUT 1,            
                                        INPUT tel_nrdconta, 
                                        INPUT tel_idseqttl, 
                                        INPUT aux_flgerlog, 
                                       OUTPUT TABLE tt-contato-juridica,
                                       OUTPUT TABLE tt-erro).
     
    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            RUN mostra-critica.
            LEAVE.
        END.

    IF  aux_flgerlog  THEN
        ASSIGN aux_flgerlog = FALSE.
    ELSE
        CLOSE QUERY q_contatos.

    OPEN QUERY q_contatos FOR EACH tt-contato-juridica NO-LOCK. 

    IF  aux_nrdlinha > 0  THEN
        DO:
            IF  aux_nrdlinha > NUM-RESULTS("q_contatos")  THEN
                ASSIGN aux_nrdlinha = NUM-RESULTS("q_contatos").

            REPOSITION q_contatos TO ROW(aux_nrdlinha). 
        END.        

    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

        UPDATE b_contatos WITH FRAME f_browse.
        LEAVE.

    END. /** Fim do DO WHILE TRUE **/
   
    IF  KEY-FUNCTION(LASTKEY) = "END-ERROR"  THEN
        LEAVE.
   
    { includes/acesso.i }

    ASSIGN tel_nrdctato = 0
           tel_nmdavali = ""
           tel_nmextemp = ""
           tel_cddbanco = 0
           tel_cdageban = 0
           tel_dsproftl = ""
           tel_dsendere = ""
           tel_nrendere = 0
           tel_complend = ""
           tel_nrcepend = 0
           tel_nrcxapst = 0
           tel_nmbairro = ""
           tel_nmcidade = ""
           tel_cdufende = ""
           tel_nrtelefo = ""
           tel_dsdemail = "".
        
    IF  glb_cddopcao <> "I"  THEN
        DO:
            RUN consultar-dados-contato IN h-b1wgen0049
                                       (INPUT glb_cdcooper, 
                                        INPUT 0,            
                                        INPUT 0,            
                                        INPUT glb_cdoperad, 
                                        INPUT glb_nmdatela, 
                                        INPUT 1,            
                                        INPUT tel_nrdconta, 
                                        INPUT tel_idseqttl, 
                                        INPUT aux_nrdrowid,
                                        INPUT glb_cddopcao,
                                        INPUT TRUE,
                                       OUTPUT TABLE tt-contato-jur,
                                       OUTPUT TABLE tt-erro).
        
            IF  RETURN-VALUE = "NOK"  THEN
                DO:
                    RUN mostra-critica.
                    NEXT.
                END.

            RUN carrega-dados.
        END.

    RUN mostra-dados.

    IF  glb_cddopcao = "A"  THEN
        DO:
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
           
                UPDATE tel_nmdavali tel_nmextemp tel_cddbanco
                       tel_cdageban tel_dsproftl tel_nrcepend
                       tel_nrendere tel_complend
                       tel_nrcxapst tel_nrtelefo tel_dsdemail
                       WITH FRAME f_contatos_juridica

                EDITING:

                    READKEY.
                    HIDE MESSAGE NO-PAUSE.

                    IF  LASTKEY = KEYCODE("F7")  THEN
                        DO:
                            /* Inclusão de CEP integrado. (André - DB1) */
                            IF  FRAME-FIELD = "tel_nrcepend"  THEN
                                DO:
                                    
                                    RUN fontes/zoom_endereco.p 
                                                    (INPUT 0,
                                                     OUTPUT TABLE tt-endereco).
                         
                                    FIND FIRST tt-endereco NO-LOCK NO-ERROR.
            
                                    IF  AVAIL tt-endereco  THEN
                                        ASSIGN tel_nrcepend = 
                                                          tt-endereco.nrcepend
                                               tel_dsendere = 
                                                          tt-endereco.dsendere
                                               tel_nmbairro = 
                                                          tt-endereco.nmbairro
                                               tel_nmcidade =
                                                          tt-endereco.nmcidade
                                               tel_cdufende = 
                                                          tt-endereco.cdufende.
                                                              
                                    DISPLAY tel_nrcepend    
                                            tel_dsendere
                                            tel_nmbairro
                                            tel_nmcidade
                                            tel_cdufende
                                            WITH FRAME f_contatos_juridica.

                                    IF  KEYFUNCTION(LASTKEY) <> "END-ERROR" THEN
                                        NEXT-PROMPT tel_nrendere 
                                             WITH FRAME f_contatos_juridica.
                                END.
                        END.
                    ELSE
                        APPLY LASTKEY.
                END.
              
                RUN validar-dados.

                IF  RETURN-VALUE = "NOK"  THEN
                    NEXT.

                LEAVE.

            END. /** Fim do DO WHILE TRUE **/

            IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
                NEXT.
        END.
    ELSE
    IF  glb_cddopcao = "C"  THEN
        DO:
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                
                PAUSE MESSAGE "Pressione <END> ou <F4> para retornar.".
                LEAVE.

            END. /** Fim do DO WHILE TRUE **/

            NEXT.
        END.
    ELSE
    IF  glb_cddopcao = "I"  THEN
        DO:                         
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
            
                UPDATE tel_nrdctato WITH FRAME f_contatos_juridica.

                IF  tel_nrdctato = 0  THEN
                    DO:
                        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                  
                            UPDATE tel_nmdavali tel_nmextemp tel_cddbanco
                                   tel_cdageban tel_dsproftl tel_nrcepend
                                   tel_nrendere tel_complend
                                   tel_nrcxapst tel_nrtelefo tel_dsdemail
                                   WITH FRAME f_contatos_juridica

                            EDITING:

                                READKEY.
                                HIDE MESSAGE NO-PAUSE.

                                    IF  LASTKEY = KEYCODE("F7")  THEN
                                        DO:
                                        /* Inclusão de CEP integrado. 
                                           (André - DB1) */
                                            IF  FRAME-FIELD = "tel_nrcepend"  THEN
                                                DO:
                                    
                                                    RUN fontes/zoom_endereco.p 
                                                       (INPUT 0,
                                                       OUTPUT TABLE tt-endereco).
                         
                                                    FIND FIRST tt-endereco 
                                                               NO-LOCK NO-ERROR.
            
                                                    IF  AVAIL tt-endereco  THEN
                                                        ASSIGN 
                                                          tel_nrcepend = 
                                                            tt-endereco.nrcepend
                                                          tel_dsendere = 
                                                            tt-endereco.dsendere
                                                          tel_nmbairro = 
                                                            tt-endereco.nmbairro
                                                          tel_nmcidade =
                                                            tt-endereco.nmcidade
                                                          tel_cdufende = 
                                                            tt-endereco.cdufende.
                                                              
                                                        DISPLAY tel_nrcepend    
                                                                tel_dsendere
                                                                tel_nmbairro
                                                                tel_nmcidade
                                                                tel_cdufende
                                                        WITH FRAME 
                                                            f_contatos_juridica.

                                                        IF  KEYFUNCTION(LASTKEY)
                                                             <> "END-ERROR" THEN
                                                            NEXT-PROMPT 
                                                              tel_nrendere 
                                                              WITH FRAME 
                                                              f_contatos_juridica.
                                                END.
                                        END.
                                    ELSE
                                        APPLY LASTKEY.
                            END.

                            RUN validar-dados.

                            IF  RETURN-VALUE = "NOK"  THEN 
                                NEXT.
    
                            LEAVE.
    
                        END. /** Fim do DO WHILE TRUE **/
    
                        IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
                            NEXT.
                    END.
                ELSE
                    DO:
                        RUN consultar-dados-cooperado-contato IN h-b1wgen0049
                                                (INPUT glb_cdcooper,
                                                 INPUT 0, 
                                                 INPUT 0, 
                                                 INPUT glb_cdoperad, 
                                                 INPUT glb_nmdatela, 
                                                 INPUT 1, 
                                                 INPUT tel_nrdconta, 
                                                 INPUT tel_idseqttl, 
                                                 INPUT tel_nrdctato, 
                                                 INPUT TRUE, 
                                                OUTPUT TABLE tt-contato-jur,
                                                OUTPUT TABLE tt-erro).

                        IF  RETURN-VALUE = "NOK"  THEN
                            DO:
                                RUN mostra-critica.
                                NEXT.
                            END.

                        RUN carrega-dados.      
                        RUN mostra-dados.
                        RUN validar-dados.

                        IF  RETURN-VALUE = "NOK"  THEN
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

    IF  VALID-HANDLE(h-b1wgen0049) THEN
        DELETE OBJECT h-b1wgen0049.

    RUN sistema/generico/procedures/b1wgen0049.p PERSISTENT SET h-b1wgen0049.

    RUN gerenciar-contato IN h-b1wgen0049 (INPUT glb_cdcooper,
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
                                           INPUT tel_nrdctato,
                                           INPUT tel_nmdavali,
                                           INPUT tel_nmextemp,
                                           INPUT tel_cddbanco,
                                           INPUT tel_cdageban,
                                           INPUT tel_dsproftl,
                                           INPUT tel_dsendere,
                                           INPUT tel_nrendere,
                                           INPUT tel_complend,
                                           INPUT tel_nrcepend,
                                           INPUT tel_nrcxapst,
                                           INPUT tel_nmbairro,
                                           INPUT tel_nmcidade,
                                           INPUT tel_cdufende,
                                           INPUT tel_nrtelefo,
                                           INPUT tel_dsdemail,
                                           INPUT TRUE,
                                          OUTPUT aux_tpatlcad,
                                          OUTPUT aux_msgatcad,
                                          OUTPUT aux_chavealt,
                                          OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE = "NOK"  THEN 
        DO:
            RUN mostra-critica.
            NEXT.
        END.

    IF  glb_cddopcao = "A"  OR
        glb_cddopcao = "E"  THEN
        DO:
            RUN proc_altcad (INPUT "b1wgen0049.p").
            IF  RETURN-VALUE <> "OK" THEN
                NEXT.
        END.

    DELETE PROCEDURE h-b1wgen0049.

    ASSIGN glb_dscritic = "Contato " + (IF  glb_cddopcao = "A"  THEN
                                               "alterado"
                                           ELSE
                                           IF  glb_cddopcao = "E"  THEN
                                               "excluido"
                                           ELSE
                                               "cadastrado") + " com sucesso!".
    MESSAGE glb_dscritic.
   
END. /** Fim do DO WHILE TRUE **/

HIDE FRAME f_contatos_juridica NO-PAUSE.

IF  VALID-HANDLE(h-b1wgen0049)  THEN
    DELETE PROCEDURE h-b1wgen0049.

/*............................................................................*/

PROCEDURE mostra-critica:

    FIND FIRST tt-erro NO-LOCK NO-ERROR.

    IF  AVAILABLE tt-erro  THEN
        DO:
            BELL.
            MESSAGE tt-erro.dscritic.
        END.

END PROCEDURE.

PROCEDURE carrega-dados:

    FIND FIRST tt-contato-jur NO-LOCK NO-ERROR.

    IF  AVAILABLE tt-contato-jur  THEN
        ASSIGN tel_nmdavali = tt-contato-jur.nmdavali
               tel_nmextemp = tt-contato-jur.nmextemp
               tel_cddbanco = tt-contato-jur.cddbanco
               tel_cdageban = tt-contato-jur.cdageban
               tel_dsproftl = tt-contato-jur.dsproftl
               tel_dsendere = tt-contato-jur.dsendere
               tel_nrendere = tt-contato-jur.nrendere
               tel_complend = tt-contato-jur.complend
               tel_nrcepend = tt-contato-jur.nrcepend
               tel_nrcxapst = tt-contato-jur.nrcxapst
               tel_nmbairro = tt-contato-jur.nmbairro
               tel_nmcidade = tt-contato-jur.nmcidade
               tel_cdufende = tt-contato-jur.cdufende
               tel_nrtelefo = tt-contato-jur.nrtelefo
               tel_dsdemail = tt-contato-jur.dsdemail.

END PROCEDURE.

PROCEDURE mostra-dados:

    DISPLAY tel_nrdctato tel_nmdavali tel_nmextemp tel_cddbanco
            tel_cdageban tel_dsproftl tel_dsendere tel_nrendere
            tel_complend tel_nrcepend tel_nrcxapst tel_nmbairro
            tel_nmcidade tel_cdufende tel_nrtelefo tel_dsdemail
            WITH FRAME f_contatos_juridica.

END PROCEDURE.

PROCEDURE validar-dados:

    RUN validar-dados-contato IN h-b1wgen0049 (INPUT glb_cdcooper,
                                               INPUT 0,
                                               INPUT 0,
                                               INPUT glb_cdoperad,
                                               INPUT glb_nmdatela,
                                               INPUT 1,
                                               INPUT tel_nrdconta,
                                               INPUT tel_idseqttl,
                                               INPUT tel_nrdctato,
                                               INPUT tel_nmdavali,
                                               INPUT tel_nmextemp,
                                               INPUT tel_cddbanco,
                                               INPUT tel_cdageban,
                                               INPUT tel_nrtelefo,
                                               INPUT tel_dsdemail,
                                               INPUT glb_cddopcao,
                                               INPUT TRUE,
                                               INPUT tel_nrcepend,
                                               INPUT tel_dsendere,
                                              OUTPUT TABLE tt-erro).
              
    IF  RETURN-VALUE = "NOK"  THEN 
        DO:
            RUN mostra-critica.
            RETURN "NOK".
        END.

    RETURN "OK".

END PROCEDURE.

PROCEDURE Limpa_Endereco:
    ASSIGN tel_nrcepend = 0  
           tel_dsendere = ""  
           tel_nmbairro = "" 
           tel_nmcidade = ""  
           tel_cdufende = ""
           tel_nrendere = 0
           tel_complend = ""
           tel_nrcxapst = 0.

    DISPLAY tel_nrcepend  tel_dsendere
            tel_nmbairro  tel_nmcidade
            tel_cdufende  tel_nrendere
            tel_complend  tel_nrcxapst WITH FRAME f_contatos_juridica.
END PROCEDURE.

/*...........................................................................*/
