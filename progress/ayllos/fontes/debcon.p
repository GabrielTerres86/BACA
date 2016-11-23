/*.............................................................................

   Programa: fontes/debcon.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Lucas Ranghetti
   Data    : Junho/2014                        Ultima atualizacao: 25/10/2016

   Dados referentes ao programa:

   Frequencia: Diario (On-Line).
   Objetivo  : Listar todos os debitos automaticos dos convenios do Sicredi 
               que nao tiveram saldo no processo noturno anterior para realizar
               o lancamento do debito.
   
   Alteracoes: 23/12/2014 - Incluir glb_cddopcao = "@" acesso (Lucas R. # 236989)
   
               09/03/2015 - Removido parametro de historico da stored procedure
                            pc_consulta_convenios_wt.
                            Motivo: Esta tela, alem de listar os debitos
                            automaticos Sicredi (1019) passara a listar tambem
                            os lancamentos de debito automatico de convenios
                            nossos (CECRED) nao debitados no processo noturno.
                            (Chamado 229249 # PRJ Melhoria) - (Fabricio)
   
               31/05/2016 - Alteraçoes Oferta DEBAUT Sicredi
                            (Lucas Lunelli - [PROJ320])

               18/08/2016 - Remocao temporaria da coluna "Pendencia" ate que
                            todas as criticas tenham sido mapeadas.

               25/10/2016 - SD509982 - Ajuste coluna Pendencia e Criticas
                            (Guilherme/SUPERO)
............................................................................*/

{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/gera_erro.i }
{ sistema/generico/includes/gera_log.i }
{ sistema/generico/includes/var_oracle.i }
{ includes/var_online.i }

DEF VAR tel_nrdconta LIKE crapass.nrdconta                             NO-UNDO.
DEF VAR tel_nmprimtl LIKE crapass.nmprimtl                             NO-UNDO.
DEF VAR p-progres-recid AS INTE                                        NO-UNDO.
DEF VAR aux_query AS CHAR                                              NO-UNDO.

DEF VAR aux_flconfir AS LOGI FORMAT "S/N"                              NO-UNDO.

DEF TEMP-TABLE w_convenios
    FIELD cdcooper AS INTE  FORMAT "z9"
    FIELD cdagenci AS INTE  FORMAT "zz9"
    FIELD nrdconta AS INTE  FORMAT "zzzz,zzz,9"
    FIELD vllanaut AS DECI  FORMAT "zzz,zzz,zz9.99"
    FIELD cdhistor LIKE craphis.cdhistor
    FIELD dtmvtolt AS DATE FORMAT "99/99/9999"
    FIELD nrdocmto AS CHAR  FORMAT "x(20)"
    FIELD cdempres LIKE crapscn.cdempres
    FIELD nmempres AS CHAR FORMAT "x(21)"
    FIELD nmpendem AS CHAR FORMAT "x(18)".

DEF QUERY q_convenios FOR w_convenios.

DEF BROWSE b_convenios QUERY q_convenios 
    DISPLAY w_convenios.cdagenci COLUMN-LABEL "PA"
            w_convenios.nrdconta COLUMN-LABEL "Conta/dv"
            w_convenios.nrdocmto COLUMN-LABEL "Fatura"
            w_convenios.nmempres COLUMN-LABEL "Convenio"
            w_convenios.nmpendem COLUMN-LABEL "Pendencia"
            w_convenios.vllanaut COLUMN-LABEL "Valor"            
            WITH NO-BOX 10 DOWN WIDTH 78 SCROLLBAR-VERTICAL.

FORM 
    WITH NO-LABEL TITLE COLOR MESSAGE glb_tldatela
    ROW 4 COLUMN 1 OVERLAY SIZE 80 BY 18 FRAME f_moldura.

FORM tel_nrdconta AT 03 LABEL "Conta/dv" AUTO-RETURN
     HELP "Informe o numero da conta ou '0' para listar todas."
     tel_nmprimtl AT 25  
     WITH NO-LABEL SIDE-LABELS COLUMN 2 ROW 6 OVERLAY NO-BOX FRAME f_opcao.

FORM b_convenios HELP "Use <ENTER> para selecionar ou <END>/<F4> para sair."
     WITH ROW 7 OVERLAY WIDTH 105 TITLE COLOR NORMAL " AGENDAMENTOS "
     FRAME f_b_convenios.

VIEW FRAME f_moldura.

PAUSE(0).

RUN fontes/inicia.p.
                  
DO  WHILE TRUE:

    CLEAR FRAME f_opcao NO-PAUSE.

    /* seleciona linha com os registros com o botao enter */
    ON  RETURN OF b_convenios IN FRAME f_b_convenios DO:

        DO WHILE TRUE:

            HIDE MESSAGE NO-PAUSE.
            
            ASSIGN aux_flconfir = FALSE.

            RUN confirma_debito (OUTPUT aux_flconfir).

            IF  NOT aux_flconfir THEN
                LEAVE.

            /* EFETUAR LANCAMENTO DE DEBITO */
            RUN cria_lancamentos_debitos (INPUT w_convenios.cdcooper, 
                                          INPUT w_convenios.dtmvtolt,   
                                          INPUT w_convenios.cdhistor,
                                          INPUT w_convenios.cdagenci,
                                          INPUT w_convenios.nrdconta,
                                          INPUT w_convenios.vllanaut,
                                          INPUT STRING(w_convenios.nrdocmto)).
            
            /* BUSCAR REGISTROS DE DEBITO AUTOMATICO */
            RUN consulta_convenios.     

            QUERY q_convenios:QUERY-CLOSE().
            QUERY q_convenios:QUERY-PREPARE(aux_query).
            
            QUERY q_convenios:QUERY-OPEN().

            APPLY "RETURN".

            LEAVE.
        END.

    END. /* final do MUDULO ENTER */

    IF  KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
        DO:
             
           RUN fontes/novatela.p.
              
           IF  CAPS(glb_nmdatela) <> "DEBCON"  THEN
               DO:
                   CLEAR FRAME f_opcao  NO-PAUSE.
                   HIDE FRAME f_moldura NO-PAUSE.
                   HIDE FRAME f_opcao   NO-PAUSE.
                   HIDE FRAME f_b_convenios NO-PAUSE.
                   RETURN.
               END.
           ELSE
               NEXT.
        END.

    glb_cddopcao = "@". /* Acesso */

    { includes/acesso.i }
    
    Conta:
    DO  WHILE TRUE:
        UPDATE tel_nrdconta WITH FRAME f_opcao.

        /* BUSCAR REGISTROS DE DEBITO AUTOMATICO */
        RUN consulta_convenios.

        IF  tel_nrdconta <> 0   THEN
            DO:                  
                /* se for informada conta, entao buscara registro pela mesma informada */
                aux_query = "FOR EACH w_convenios WHERE w_convenios.nrdconta = "
                            + STRING(tel_nrdconta).
                
                FIND crapass WHERE crapass.cdcooper = glb_cdcooper AND
                                   crapass.nrdconta = tel_nrdconta 
                                   NO-LOCK NO-ERROR.
               
                IF  NOT AVAILABLE crapass   THEN
                    DO:         
                        glb_cdcritic = 9.
                        RUN fontes/critic.p.
                        BELL.
                        MESSAGE glb_dscritic.
                        CLEAR FRAME f_opcao.
                        DISPLAY tel_nrdconta WITH FRAME f_opcao.
                        NEXT Conta.
                    END.
                ELSE
                    ASSIGN tel_nmprimtl = crapass.nmprimtl.
            END. 
        ELSE
            ASSIGN tel_nmprimtl = " "  /* inicia vazia */
                   aux_query = "FOR EACH w_convenios".
    
        DISPLAY tel_nmprimtl WITH FRAME f_opcao.
       
       QUERY q_convenios:QUERY-CLOSE().
       QUERY q_convenios:QUERY-PREPARE(aux_query).
       
       QUERY q_convenios:QUERY-OPEN().
       
       IF  NUM-RESULTS("q_convenios") = 0  THEN
           DO:
               BELL.
               MESSAGE "Nao foram encontrados lancamentos pendentes.".
               CLOSE QUERY q_convenios.
               NEXT Conta.
           END. 
    
       HIDE MESSAGE NO-PAUSE.
       
       ENABLE b_convenios WITH FRAME f_b_convenios.
       
       WAIT-FOR END-ERROR OF DEFAULT-WINDOW.
       
       HIDE FRAME f_b_convenios.
       
       HIDE MESSAGE NO-PAUSE.
    
       IF  KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
           NEXT Conta.
    
       PAUSE(0).
    
       LEAVE Conta.
    END.
    LEAVE.
END.
                            
PROCEDURE consulta_convenios:

    DEF VAR aux_cdcritic AS INTE                                       NO-UNDO.
    DEF VAR aux_dscritic AS CHAR                                       NO-UNDO.
    
    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
    
    RUN STORED-PROCEDURE pc_consulta_convenios_wt 
        aux_handproc = PROC-HANDLE NO-ERROR
                         (INPUT glb_cdcooper,
                          INPUT glb_dtmvtolt,
                         OUTPUT 0,               
                         OUTPUT "").
    
    CLOSE STORED-PROC pc_consulta_convenios_wt 
          aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.     
    
    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
    
    ASSIGN aux_cdcritic = 0
           aux_dscritic = "".

    ASSIGN aux_cdcritic = pc_consulta_convenios_wt.pr_cdcritic
                          WHEN pc_consulta_convenios_wt.pr_cdcritic <> ?. 
    ASSIGN aux_dscritic = pc_consulta_convenios_wt.pr_dscritic
                          WHEN pc_consulta_convenios_wt.pr_dscritic <> ?.
    
    IF  aux_cdcritic <> 0   OR
        aux_dscritic <> ""  THEN
        DO:
            BELL.
            MESSAGE aux_dscritic.
        END.
    
    EMPTY TEMP-TABLE w_convenios.
    
    FOR EACH wt_convenios_debitos NO-LOCK 
                                  BY wt_convenios.cdagenci 
                                  BY wt_convenios.nrdconta:
        
        CREATE w_convenios.
        ASSIGN w_convenios.cdcooper = wt_convenios.cdcooper
               w_convenios.cdagenci = wt_convenios.cdagenci
               w_convenios.nrdconta = wt_convenios.nrdconta
               w_convenios.nrdocmto = STRING(wt_convenios.nrdocmto)
               w_convenios.cdhistor = wt_convenios.cdhistor
               w_convenios.cdempres = wt_convenios.cdempres
               w_convenios.nmempres = wt_convenios.nmempres
               w_convenios.vllanaut = wt_convenios.vllanmto
               w_convenios.dtmvtolt = wt_convenios.dtmvtolt.

        CASE INTE(wt_convenios_debitos.cdcritic):
          WHEN 967 THEN /*967 - Valor do debito excede valor limite aprovado.*/
            ASSIGN w_convenios.nmpendem = "LIMITE EXCEDIDO".
          WHEN 717 THEN /*717 - Nao ha saldo suficiente para a operacao.*/
            ASSIGN w_convenios.nmpendem = "SALDO INSUFICIENTE".
          WHEN 964 THEN /*964 - Lancamento bloqueado.*/
            ASSIGN w_convenios.nmpendem = "LANCTO.BLOQUEADO".
        END CASE.

    END. 
END.

PROCEDURE cria_lancamentos_debitos:
    
    DEF INPUT PARAM p-cdcooper AS INTE                                 NO-UNDO.
    DEF INPUT PARAM p-dtmvtolt AS DATE                                 NO-UNDO.
    DEF INPUT PARAM p-cdhistor AS INTE                                 NO-UNDO.
    DEF INPUT PARAM p-cdagenci AS INTE                                 NO-UNDO.
    DEF INPUT PARAM p-nrdconta AS INTE                                 NO-UNDO.
    DEF INPUT PARAM p-vllanaut AS DECI                                 NO-UNDO.
    DEF INPUT PARAM p-nrdocmto AS CHAR                                 NO-UNDO.

    DEF VAR aux_cdcritic AS DECI                                       NO-UNDO.
    DEF VAR aux_dscritic AS CHAR FORMAT "x(50)"                        NO-UNDO.

    BELL.
    MESSAGE "Aguarde processando dados...".
    PAUSE 2 NO-MESSAGE.

    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

    RUN STORED-PROCEDURE pc_cria_lancamentos_deb
        aux_handproc = PROC-HANDLE NO-ERROR
                         (INPUT p-cdcooper,  
                          INPUT p-dtmvtolt,    
                          INPUT p-cdhistor, 
                          INPUT p-cdagenci, 
                          INPUT p-nrdconta, 
                          INPUT p-vllanaut,
                          INPUT p-nrdocmto,
                          OUTPUT 0,               
                          OUTPUT "").

    CLOSE STORED-PROC pc_cria_lancamentos_deb
          aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_cdcritic = pc_cria_lancamentos_deb.pr_cdcritic 
                          WHEN pc_cria_lancamentos_deb.pr_cdcritic <> ?
           aux_dscritic = pc_cria_lancamentos_deb.pr_dscritic 
                          WHEN pc_cria_lancamentos_deb.pr_dscritic <> ?.
        
    IF  aux_cdcritic <> 0   OR
        aux_dscritic <> ""  THEN
        DO:
            BELL.
            MESSAGE aux_dscritic. 
        END.
    ELSE
        DO:  
            HIDE MESSAGE NO-PAUSE.

            BELL.
            MESSAGE "Transacao efetuada com sucesso! ".
            PAUSE 2 NO-MESSAGE.

            /* se nao gerou critica entao gera log dizendo que efetuou debito */
            UNIX SILENT VALUE( " echo " +
                STRING(glb_dtmvtolt,"99/99/9999") + " " + STRING(TIME,"hh:mm:ss") + 
                "' --> ' Operador " + STRING(glb_cdoperad) + 
                " realizou o debito do convenio " + STRING(w_convenios.cdempres) + 
                " " + w_convenios.nmempres + " na conta: " + 
                STRING(w_convenios.nrdconta) + " do documento " + 
                STRING(w_convenios.nrdocmto) + " no valor de " + 
                STRING(w_convenios.vllanaut,"zzz,zzz,zz9.99") + 
                " >> log/debcon.log"). 
            
        END.
END.

PROCEDURE confirma_debito:
    
    DEF OUTPUT PARAM par_flgconfi AS LOG                               NO-UNDO.

    par_flgconfi = TRUE.

    DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:
        ASSIGN glb_cdcritic = 78.
        RUN fontes/critic.p.    
        BELL.
        MESSAGE COLOR NORMAL glb_dscritic UPDATE aux_flconfir.
        ASSIGN glb_cdcritic = 0.
        LEAVE.
    END.
    
    IF  NOT aux_flconfir OR KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
        DO:
            par_flgconfi = FALSE.
            ASSIGN glb_cdcritic = 79.
            RUN fontes/critic.p.
            BELL.
            MESSAGE glb_dscritic.
            ASSIGN glb_cdcritic = 0.
        END.

END.
