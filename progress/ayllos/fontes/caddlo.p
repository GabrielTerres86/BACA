/*..............................................................................
   
   Programa: fontes/caddlo.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : David
   Data    : Setembro/2008                   Ultima atualizacao: 07/03/2014

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela CADDLO

   Alteracoes: 08/10/2008 - Acerto na validacao da data de referencia (David).
   
               29/04/2009 - Acerto na verificacao de registro preso (Magui).   
                                
               07/08/2009 - Nova opcao "S" (David).                       
               
               13/05/2010 - Alteracoes na estrutura do arquivo (David).
                      
               16/04/2012 - Fonte substituido por caddlop.p (Tiago).
               
               14/05/2012 - Incluido opcao I para importacao de arquivo e
                            criado a procedure proc_importacao (Tiago).
               
               02/07/2012 - Substituido 'gncoper' por 'crapcop' (Tiago).
               
               29/11/2013 - Inclusao de VALIDATE crapdlo, crapddo e crapedd 
                            (Carlos)
                            
               07/03/2014 - Incluido elemento 3 (Percentuais aplicaveis ao 
                            capital) para o detalhamento de contas DLO e opcao
                            "X" agora remove registros da CRAPDLO, CRAPDDO e 
                            CRAPEDD (Reinert).
                            
..............................................................................*/


/*................................ DEFINICOES ................................*/

{ includes/var_online.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/b1wgen0035.i }

DEF VAR h-b1wgen0035 AS HANDLE                                         NO-UNDO.

DEF VAR aux_cddopcao AS CHAR                                           NO-UNDO.
DEF VAR aux_confirma AS CHAR FORMAT "!(1)"                             NO-UNDO.
DEF VAR aux_dsdconta AS CHAR EXTENT 4                                  NO-UNDO.
DEF VAR aux_cdoperad AS CHAR                                           NO-UNDO.
DEF VAR aux_dsdirdlo AS CHAR                                           NO-UNDO.
DEF VAR aux_dsformat AS CHAR                                           NO-UNDO.
DEF VAR aux_cdopclcm AS CHAR                                           NO-UNDO.

DEF VAR aux_cddconta AS DECI                                           NO-UNDO.
DEF VAR aux_ultlinha AS DECI                                           NO-UNDO.
DEF VAR aux_contador AS INTE                                           NO-UNDO. 
DEF VAR aux_idelemen AS INTE                                           NO-UNDO. 
DEF VAR aux_idextent AS INTE                                           NO-UNDO. 
DEF VAR aux_nrseqdet AS INTE                                           NO-UNDO. 

DEF VAR aux_dtmvtolt AS DATE                                           NO-UNDO.

DEF VAR aux_flgsenha AS LOGI                                           NO-UNDO.

DEF VAR tel_btaltera AS CHAR INIT "Alterar"                            NO-UNDO.
DEF VAR tel_btexclui AS CHAR INIT "Excluir"                            NO-UNDO.
DEF VAR tel_btinclui AS CHAR INIT "Incluir"                            NO-UNDO.
DEF VAR tel_dselemen AS CHAR EXTENT 6                                  NO-UNDO.

DEF VAR tel_cdcooper AS INTE                                           NO-UNDO. 
DEF VAR tel_cdelemen AS INTE EXTENT 6                                  NO-UNDO. 

DEF VAR tel_nmarqimp AS CHAR                                           NO-UNDO.
DEF VAR tel_nmdireto AS CHAR                                           NO-UNDO.

DEF VAR tel_vllanmto AS DECI                                           NO-UNDO.
DEF VAR tel_vllandet AS DECI                                           NO-UNDO.
DEF VAR tel_vlelemen AS DECI EXTENT 6                                  NO-UNDO.

DEF VAR tel_dtmvtolt AS DATE                                           NO-UNDO.

DEF STREAM   str_1.

DEF BUFFER crabtab FOR craptab.
DEF BUFFER crabcop FOR crapcop.
DEF BUFFER crabddo FOR crapddo.

DEF TEMP-TABLE tt-contas                                        NO-UNDO
    FIELD cddconta AS DECI 
    FIELD cdlimite AS INTE 
    FIELD dsdconta AS CHAR.

DEF TEMP-TABLE tt-detalhe                                       NO-UNDO
    FIELD idelemen AS INTE
    FIELD cdelemen AS INTE
    FIELD dselemen AS CHAR
    FIELD vlelemen AS DECI
    FIELD dsformat AS CHAR
    FIELD flgdfixo AS LOGI.

DEF TEMP-TABLE tt-crapddo NO-UNDO LIKE crapddo.
DEF TEMP-TABLE tt-crapedd NO-UNDO LIKE crapedd.

DEF QUERY q_contas   FOR tt-contas.
DEF QUERY q_consulta FOR crapdlo, tt-contas.
DEF QUERY q_detalhe  FOR crapddo.

DEF BROWSE b_contas QUERY q_contas
    DISP tt-contas.cddconta LABEL "Conta"     FORMAT "zzzzzzzzzzzz9"
         tt-contas.dsdconta LABEL "Descricao" FORMAT "x(57)"
         WITH NO-BOX OVERLAY 9 DOWN.

DEF BROWSE b_consulta QUERY q_consulta
    DISP tt-contas.cddconta LABEL "Conta"     FORMAT "zzzzzzzzzzzz9"
         tt-contas.dsdconta LABEL "Descricao" FORMAT "x(34)"
         crapdlo.vllanmto   LABEL "Valor"     FORMAT "zz,zzz,zzz,zzz,zz9.99-"
         WITH OVERLAY NO-BOX 9 DOWN.                        

DEF BROWSE b_detalhe QUERY q_detalhe
    DISP crapddo.cddconta LABEL "Conta"         FORMAT "zzzzzzzzzzzz9"
         crapddo.nrseqdet LABEL "Seq.Detalhe"   FORMAT "zz9"
         crapddo.vllanmto LABEL "Valor Detalhe" FORMAT "zz,zzz,zzz,zzz,zz9.99-"
         WITH OVERLAY NO-LABEL 7 DOWN.

FORM WITH ROW 4 COLUMN 1 OVERLAY SIZE 80 BY 18 TITLE glb_tldatela 
     FRAME f_moldura.

FORM glb_cddopcao AT  3 LABEL "Opcao"           FORMAT "!(1)"       AUTO-RETURN 
      HELP "C=consultar,B=geracao,I=importacao,X=desfazer"
      VALIDATE (CAN-DO("C,B,X,I",glb_cddopcao),"014 - Opcao errada.")
     tel_dtmvtolt AT 15 LABEL "Data Referencia" FORMAT "99/99/9999" AUTO-RETURN 
      HELP "Informe a data de movimento"
      VALIDATE (tel_dtmvtolt <> ?,"Informe a data.")
     tel_cdcooper AT 46 LABEL "Cooperativa"     FORMAT "99"         AUTO-RETURN
      HELP "Informe o codigo da cooperativa"
      VALIDATE (CAN-FIND(crapcop WHERE crapcop.cdcooper = tel_cdcooper),
                "794 - Cooperativa Invalida")
     crapcop.nmrescop AT 62 NO-LABEL            FORMAT "x(15)"
     WITH ROW 6 COLUMN 2 OVERLAY SIDE-LABELS NO-BOX FRAME f_opcao.

FORM tel_nmdireto FORMAT "x(40)" AT 01
     tel_nmarqimp FORMAT "x(25)" AT 42
     ".txt"                      AT 68
     WITH ROW 12 COLUMN 2 NO-LABELS WIDTH 78 OVERLAY NO-BOX 
          CENTERED FRAME f_arquivo.

FORM WITH ROW 7 COLUMN 2 OVERLAY SIZE 78 BY 13 FRAME f_browse.
     
FORM b_contas
     HELP "Setas para navegar, <ENTER> para incluir, <END>/<F4> para sair."
     WITH ROW 8 NO-BOX CENTERED OVERLAY FRAME f_contas.
     
FORM b_consulta
     HELP "Use as setas para navegar ou <END>/<F4> para sair."
     WITH ROW 7 CENTERED OVERLAY FRAME f_consulta.

FORM b_detalhe
     HELP "Setas para navegar, <DELETE> para excluir, <END>/<F4> para sair."
     WITH ROW 8 NO-BOX CENTERED OVERLAY FRAME f_excluir_detalhe.

FORM tel_btaltera
     SPACE(5)
     tel_btexclui
     SPACE(5)
     tel_btinclui
     WITH ROW 20 CENTERED OVERLAY NO-BOX NO-LABEL FRAME f_botoes.
    
FORM SKIP(1)
     aux_cddconta    AT 04 LABEL "Conta"       FORMAT "zzzzzzzzzzzz9"
     SKIP                                      
     aux_dsdconta[1] AT 04 LABEL "Desc."       FORMAT "x(61)"
     SKIP                                      
     aux_dsdconta[2] AT 11 NO-LABEL            FORMAT "x(61)"
     SKIP                                      
     aux_dsdconta[3] AT 11 NO-LABEL            FORMAT "x(61)"
     SKIP
     aux_dsdconta[4] AT 11 NO-LABEL            FORMAT "x(61)"
     SKIP(1)
     tel_vllanmto    AT 04 LABEL "Valor Conta" FORMAT "zz,zzz,zzz,zzz,zz9.99-"
                     HELP "Informe o valor da conta"
     SKIP(1)
     WITH ROW 8 WIDTH 76 CENTERED OVERLAY SIDE-LABELS FRAME f_valor.

FORM WITH ROW 7 SIZE 78 BY 13 CENTERED OVERLAY FRAME f_moldura_detalhe.

FORM aux_cddconta LABEL "        Conta" FORMAT "zzzzzzzzzzzz9"
     SKIP
     tel_vllandet LABEL "Valor Detalhe" FORMAT "zz,zzz,zzz,zzz,zz9.99-"
                  HELP "Informe o valor de detalhe."
     WITH ROW 9 COL 6 OVERLAY NO-BOX SIDE-LABELS FRAME f_detalhe.
                                   
FORM tel_cdelemen[1] AT 01 FORMAT "z9,"
     tel_dselemen[1] AT 05 FORMAT "x(54)"
     tel_vlelemen[1] AT 60 FORMAT "zzz,zzz,zz9.99-"
     SKIP
     tel_cdelemen[2] AT 01 FORMAT "z9,"
     tel_dselemen[2] AT 05 FORMAT "x(54)"
     tel_vlelemen[2] AT 60 FORMAT "zzz,zzz,zz9.99-"
     SKIP
     tel_cdelemen[3] AT 01 FORMAT "z9,"
     tel_dselemen[3] AT 05 FORMAT "x(54)"
     tel_vlelemen[3] AT 60 FORMAT "zzz,zzz,zz9.99-"
     SKIP
     tel_cdelemen[4] AT 01 FORMAT "z9,"
     tel_dselemen[4] AT 05 FORMAT "x(54)"
     tel_vlelemen[4] AT 60 FORMAT "zzz,zzz,zz9.99-"
     SKIP
     tel_cdelemen[5] AT 01 FORMAT "z9,"
     tel_dselemen[5] AT 05 FORMAT "x(54)"
     tel_vlelemen[5] AT 60 FORMAT "zzz,zzz,zz9.99-"
     SKIP
     tel_cdelemen[6] AT 01 FORMAT "z9,"
     tel_dselemen[6] AT 05 FORMAT "x(54)"
     tel_vlelemen[6] AT 60 FORMAT "zzz,zzz,zz9.99-"
     WITH ROW 12 COL 4 CENTERED OVERLAY NO-LABEL NO-BOX FRAME f_elemento.


/*................................. TRIGGERS .................................*/


ON RETURN OF b_contas IN FRAME f_contas DO:

    HIDE MESSAGE NO-PAUSE.

    DO TRANSACTION ON ERROR UNDO, LEAVE ON ENDKEY UNDO, LEAVE:

        FIND crapdlo WHERE crapdlo.cdcooper = tel_cdcooper             AND
                           crapdlo.dtmvtolt = tel_dtmvtolt             AND
                           crapdlo.cddconta = tt-contas.cddconta
                           EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
    
        IF  LOCKED crapdlo  THEN
            DO:
                BELL.
                MESSAGE "Registro da tabela DLO em uso. Tente novamente.".
                UNDO, LEAVE.
            END.
    
        ASSIGN tel_vllanmto    = IF  AVAILABLE crapdlo  THEN
                                     crapdlo.vllanmto
                                 ELSE
                                     0
               aux_cddconta    = tt-contas.cddconta
               aux_dsdconta[1] = SUBSTR(tt-contas.dsdconta,1,61)
               aux_dsdconta[2] = SUBSTR(tt-contas.dsdconta,62,61)
               aux_dsdconta[3] = SUBSTR(tt-contas.dsdconta,123,61)
               aux_dsdconta[4] = SUBSTR(tt-contas.dsdconta,184,61).
            
        DISPLAY aux_cddconta aux_dsdconta tel_vllanmto WITH FRAME f_valor.
                    
        DO WHILE TRUE:
            
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
    
                UPDATE tel_vllanmto WITH FRAME f_valor.
                LEAVE.
    
            END. /** Fim do DO WHILE TRUE **/
    
            IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
                DO:
                    FIND CURRENT crapdlo NO-LOCK NO-ERROR.
                    HIDE FRAME f_valor NO-PAUSE.
                    UNDO, LEAVE.
                END.

            IF  AVAILABLE crapdlo  THEN
                RUN atualizar-detalhamento.
            ELSE
                RUN cadastrar-detalhamento (INPUT FALSE).
    
            IF  RETURN-VALUE = "NOK"  THEN
                NEXT.
            
            LEAVE.            
            
        END. /** Fim do DO WHILE TRUE **/
        
        RUN confirma-operacao.
    
        IF  RETURN-VALUE = "NOK"  THEN
            DO:
                FIND CURRENT crapdlo NO-LOCK NO-ERROR.
                HIDE FRAME f_valor NO-PAUSE.
                UNDO, LEAVE.
            END.
        
        IF  AVAILABLE crapdlo  THEN
            RUN grava-atualizacao-dlo.
        ELSE
            RUN grava-cadastramento-dlo.
            
        HIDE FRAME f_valor NO-PAUSE.

    END. /** Fim do DO TRANSACTION **/

END.

ON "RETURN" OF b_consulta IN FRAME f_consulta DO:

    IF  glb_cddopcao <> "L"    OR 
        NOT AVAILABLE crapdlo  THEN
        RETURN.
        
    HIDE MESSAGE NO-PAUSE.
    
    IF  aux_cdopclcm = "A"  THEN
        DO:
            ASSIGN glb_dscritic = "".

            DO TRANSACTION ON ERROR UNDO, LEAVE ON ENDKEY UNDO, LEAVE:

                FIND CURRENT crapdlo EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                        
                IF  NOT AVAILABLE crapdlo  THEN
                    DO:
                        IF  LOCKED crapdlo  THEN
                            ASSIGN glb_dscritic = "Registro da tabela DLO em " +
                                                  "uso. Tente novamente.".
                        ELSE
                            ASSIGN glb_dscritic = "Registro da tabela DLO " +
                                                  "nao encontrado.".
                    END.
                
                IF  glb_dscritic <> ""  THEN
                    DO:
                        BELL.
                        MESSAGE glb_dscritic.
                        UNDO, LEAVE.
                    END.            
    
                FIND tt-contas WHERE tt-contas.cddconta = crapdlo.cddconta 
                                     NO-LOCK NO-ERROR.
    
                IF  NOT AVAILABLE tt-contas  THEN
                    DO:
                        BELL.
                        MESSAGE "Conta nao cadastrada na tabela CONTASDLO.".
                        UNDO, LEAVE.
                    END.
                    
                ASSIGN aux_cddconta    = tt-contas.cddconta
                       aux_dsdconta[1] = SUBSTR(tt-contas.dsdconta,1,61)
                       aux_dsdconta[2] = SUBSTR(tt-contas.dsdconta,62,61)
                       aux_dsdconta[3] = SUBSTR(tt-contas.dsdconta,123,61)
                       aux_dsdconta[4] = SUBSTR(tt-contas.dsdconta,184,61)
                       tel_vllanmto    = crapdlo.vllanmto.
                       
                DISPLAY aux_cddconta aux_dsdconta tel_vllanmto WITH FRAME f_valor.
                            
                DO WHILE TRUE:
                    
                    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
            
                        UPDATE tel_vllanmto WITH FRAME f_valor.
                        LEAVE.
            
                    END. /** Fim do DO WHILE TRUE **/
            
                    IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
                        DO:
                            FIND CURRENT crapdlo NO-LOCK NO-ERROR.
                            HIDE FRAME f_valor NO-PAUSE.
                            UNDO, LEAVE.
                        END.
            
                    RUN atualizar-detalhamento.
            
                    IF  RETURN-VALUE = "NOK"  THEN
                        NEXT.
            
                    LEAVE.            
                    
                END. /** Fim do DO WHILE TRUE **/
    
                RUN confirma-operacao.
    
                IF  RETURN-VALUE = "NOK"  THEN
                    DO:
                        FIND CURRENT crapdlo NO-LOCK NO-ERROR.
                        HIDE FRAME f_valor NO-PAUSE.
                        UNDO, LEAVE.
                    END.
            
                RUN grava-atualizacao-dlo.
            
                HIDE FRAME f_valor NO-PAUSE.                      
            
                RUN carrega-query-consulta (INPUT FALSE).

            END. /** Fim do DO TRANSACTION **/
        END.
    ELSE
    IF  aux_cdopclcm = "E"  THEN
        DO:
            RUN carrega-query-detalhe.       
        
            IF  QUERY q_detalhe:NUM-RESULTS = 0  THEN
                DO:
                    CLOSE QUERY q_detalhe.
                    RETURN.
                END.
        
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
        
                UPDATE b_detalhe WITH FRAME f_excluir_detalhe.
                LEAVE.
        
            END. /** Fim do DO WHILE TRUE **/
        
            HIDE FRAME f_excluir_detalhe.
        
            CLOSE QUERY q_detalhe.
        END.

END.
               
ON "DELETE" OF b_consulta IN FRAME f_consulta DO:
                               
    IF  glb_cddopcao <> "L"    OR 
        aux_cdopclcm <> "E"    OR
        NOT AVAILABLE crapdlo  THEN
        RETURN.
        
    HIDE MESSAGE NO-PAUSE.
    
    ASSIGN glb_dscritic = "".

    DO TRANSACTION ON ERROR UNDO, LEAVE ON ENDKEY UNDO, LEAVE:

        FIND CURRENT crapdlo EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                
        IF  NOT AVAILABLE crapdlo  THEN
            DO:
                IF  LOCKED crapdlo  THEN
                    ASSIGN glb_dscritic = "Registro da tabela DLO em uso. " +
                                          "Tente novamente.".
                ELSE
                    ASSIGN glb_dscritic = "Registro da tabela DLO nao " +
                                          "encontrado.".
            END.
        
        IF  glb_dscritic <> ""  THEN
            DO:
                BELL.
                MESSAGE glb_dscritic.
                UNDO, LEAVE.
            END.            
               
        RUN confirma-operacao.
    
        IF  RETURN-VALUE = "NOK"  THEN
            DO:
                FIND CURRENT crapdlo NO-LOCK NO-ERROR.
                UNDO, LEAVE.
            END.
    
        FOR EACH crapedd WHERE crapedd.cdcooper = crapdlo.cdcooper AND
                               crapedd.dtmvtolt = crapdlo.dtmvtolt AND
                               crapedd.cddconta = crapdlo.cddconta EXCLUSIVE-LOCK:
    
            DELETE crapedd.
    
        END. /** Fim do FOR EACH crapedd **/
    
        FOR EACH crapddo WHERE crapddo.cdcooper = crapdlo.cdcooper AND
                               crapddo.dtmvtolt = crapdlo.dtmvtolt AND
                               crapddo.cddconta = crapdlo.cddconta EXCLUSIVE-LOCK:
    
            DELETE crapddo.
    
        END. /** Fim do FOR EACH crapddo **/
                        
        DELETE crapdlo.
        
        RUN carrega-query-consulta (INPUT FALSE).
    
        IF  QUERY q_consulta:NUM-RESULTS = 0  THEN
            DO:
                CLOSE QUERY q_consulta.
                APPLY "GO".
            END.

    END. /** Fim do DO TRANSACTION **/

END.

ON DELETE OF b_detalhe IN FRAME f_excluir_detalhe DO:

    IF  NOT AVAILABLE crapddo  THEN
        RETURN.

    HIDE MESSAGE NO-PAUSE.

    ASSIGN glb_dscritic = "".
    
    DO TRANSACTION ON ERROR UNDO, LEAVE ON ENDKEY UNDO, LEAVE:

        FIND CURRENT crapdlo EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
        
        IF  NOT AVAILABLE crapdlo  THEN
            DO:
                IF  LOCKED crapdlo  THEN
                    ASSIGN glb_dscritic = "Registro da tabela DLO em uso. " +
                                          "Tente novamente.".
                ELSE
                    ASSIGN glb_dscritic = "Registro da tabela DLO nao " +
                                          "encontrado.".
            END.
        
        IF  glb_dscritic <> ""  THEN
            DO:
                BELL.
                MESSAGE glb_dscritic.
                UNDO, LEAVE.
            END.
    
        FIND CURRENT crapddo EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                    
        IF  NOT AVAILABLE crapddo  THEN
            DO:
                IF  LOCKED crapddo  THEN
                    ASSIGN glb_dscritic = "Registro da tabela DDO em uso. " +
                                          "Tente novamente.".
                ELSE
                    ASSIGN glb_dscritic = "Registro da tabela DDO nao " +
                                          "encontrado.".
            END.
        
        IF  glb_dscritic <> ""  THEN
            DO:
                BELL.
                MESSAGE glb_dscritic.
                UNDO, LEAVE.
            END.            
               
        RUN confirma-operacao.
    
        IF  RETURN-VALUE = "NOK"  THEN
            DO:
                FIND CURRENT crapdlo NO-LOCK NO-ERROR.
                FIND CURRENT crapddo NO-LOCK NO-ERROR.
                UNDO, LEAVE.
            END.
    
        FOR EACH crapedd WHERE crapedd.cdcooper = crapddo.cdcooper AND
                               crapedd.dtmvtolt = crapddo.dtmvtolt AND
                               crapedd.cddconta = crapddo.cddconta AND
                               crapedd.nrseqdet = crapddo.nrseqdet EXCLUSIVE-LOCK:
    
            DELETE crapedd.
    
        END. /** Fim do FOR EACH crapedd **/
    
        DELETE crapddo.
    
        RUN carrega-query-detalhe.
            
        IF  QUERY q_detalhe:NUM-RESULTS = 0  THEN
            DO:
                CLOSE QUERY q_detalhe.
                DELETE crapdlo.       
                RUN carrega-query-consulta (INPUT FALSE).
                APPLY "GO".
            END.
        ELSE
            FIND CURRENT crapdlo NO-LOCK NO-ERROR.

    END. /** Fim do DO TRANSACTION **/
        
END.


/*................................. PRINCIPAL ................................*/

VIEW FRAME f_moldura.

PAUSE(0).

EMPTY TEMP-TABLE tt-contas.

FOR EACH craptab WHERE craptab.cdcooper = glb_cdcooper AND
                       craptab.nmsistem = "DLO"        AND
                       craptab.tptabela = "CONFIG"     AND
                       craptab.cdempres = 0            AND
                       craptab.cdacesso = "CONTASDLO"  NO-LOCK:

    CREATE tt-contas.
    ASSIGN tt-contas.cddconta = craptab.tpregist
           tt-contas.cdlimite = INTE(SUBSTR(craptab.dstextab,1,1))
           tt-contas.dsdconta = SUBSTR(craptab.dstextab,3).

END.

ASSIGN glb_cddopcao = "C".

DISPLAY glb_cddopcao WITH FRAME f_opcao.

DO WHILE TRUE:
                        
    RUN fontes/inicia.p.

    CLEAR FRAME f_opcao ALL NO-PAUSE.
                                    
    ASSIGN tel_dtmvtolt = ?
           tel_cdcooper = 0.
                                      
    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
     
        UPDATE glb_cddopcao tel_dtmvtolt tel_cdcooper 
               WITH FRAME f_opcao.
        
        LEAVE.

    END. /** Fim do DO WHILE TRUE **/

    IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
        DO:
            RUN fontes/novatela.p.
            
            IF  CAPS(glb_nmdatela) <> "CADDLO"  THEN
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
            BELL.
            MESSAGE "Data invalida. Deve ser o ultimo dia util do mes.".
            NEXT-PROMPT tel_dtmvtolt WITH FRAME f_opcao.
            NEXT.
        END.
    
    FIND crapcop WHERE crapcop.cdcooper = tel_cdcooper NO-LOCK NO-ERROR.
    
    IF  AVAILABLE crapcop  THEN
        DISPLAY crapcop.nmrescop WITH FRAME f_opcao.
        
    IF  glb_cddopcao = "C"  THEN
        DO:
            HIDE MESSAGE NO-PAUSE.
                
            RUN carrega-query-consulta (INPUT TRUE). 

            IF  RETURN-VALUE = "NOK"  THEN
                NEXT.
                
            RUN atribui-help.
     
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                        
                UPDATE b_consulta WITH FRAME f_consulta.
                LEAVE.
                                     
            END. /** Fim do DO WHILE TRUE **/
                        
            CLOSE QUERY q_consulta.

            HIDE FRAME f_consulta NO-PAUSE.
        END.
    ELSE
    IF  glb_cddopcao = "B"  THEN
        DO:            
            HIDE MESSAGE NO-PAUSE.

            FIND FIRST crapdlo WHERE crapdlo.cdcooper = tel_cdcooper AND
                                     crapdlo.dtmvtolt = tel_dtmvtolt 
                                     NO-LOCK NO-ERROR.
                                     
            IF  NOT AVAILABLE crapdlo  THEN
                DO:
                    BELL.
                    MESSAGE "Nenhuma conta cadastrada na tabela DLO.".
                    NEXT.
                END.
                
            IF  crapdlo.flgenvio  THEN
                DO:
                    glb_dscritic = "Arquivo DLO referente a " +
                                   STRING(tel_dtmvtolt,"99/99/9999") + 
                                   " ja foi gerado.".
                    BELL.
                    MESSAGE glb_dscritic.
                    NEXT.
                END.

            ASSIGN aux_confirma = "N".
    
            RUN confirma-operacao.
                
            IF  RETURN-VALUE = "NOK"  THEN
                NEXT.
            
            RUN proc_geracao.                  
        END.
    ELSE
    /* --- Desativada em 03/2014, pois com a criacao da opcao "I" esta opcao
    nao eh mais utilizada ---
    IF  glb_cddopcao = "L"  THEN
        DO:               
            FIND FIRST crapdlo WHERE crapdlo.cdcooper = tel_cdcooper AND
                                     crapdlo.dtmvtolt = tel_dtmvtolt AND
                                     crapdlo.flgenvio = TRUE         
                                     NO-LOCK NO-ERROR.
                                     
            IF  AVAILABLE crapdlo  THEN
                DO:
                    glb_dscritic = "Arquivo DLO referente a " +
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
                        ASSIGN aux_cdopclcm = "A".

                        RUN carrega-query-consulta (INPUT TRUE).

                        IF  RETURN-VALUE = "NOK"  THEN
                            NEXT.

                        RUN atribui-help.
                        
                        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                        
                            UPDATE b_consulta WITH FRAME f_consulta.
                            LEAVE.
                                     
                        END. /** Fim do DO WHILE TRUE **/
                        
                        CLOSE QUERY q_consulta.

                        HIDE FRAME f_consulta NO-PAUSE.
                    END.
                ELSE
                IF  FRAME-VALUE = tel_btinclui  THEN
                    DO:
                        ASSIGN aux_cdopclcm = "I".

                        OPEN QUERY q_contas FOR EACH tt-contas 
                                                BY STRING(tt-contas.cddconta).
                                      
                        IF  QUERY q_contas:NUM-RESULTS = 0  THEN
                            DO:
                                CLOSE QUERY q_contas.
                                BELL.
                                MESSAGE "Itens da tabela CONTASDLO nao foram"
                                        "cadastrados.".
                                NEXT.
                            END.

                        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                        
                            UPDATE b_contas WITH FRAME f_contas.
                            LEAVE.
                                     
                        END. /** Fim do DO WHILE TRUE **/
                        
                        CLOSE QUERY q_contas.

                        HIDE FRAME f_contas NO-PAUSE.
                    END.
                ELSE
                IF  FRAME-VALUE = tel_btexclui  THEN
                    DO:
                        ASSIGN aux_cdopclcm = "E".

                        RUN carrega-query-consulta (INPUT TRUE).

                        IF  RETURN-VALUE = "NOK"  THEN
                            NEXT.

                        RUN atribui-help.

                        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                        
                            UPDATE b_consulta WITH FRAME f_consulta.
                            LEAVE.
                                     
                        END. /** Fim do DO WHILE TRUE **/
                        
                        CLOSE QUERY q_consulta.

                        HIDE FRAME f_consulta NO-PAUSE.
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
    */
    IF  glb_cddopcao = "I"  THEN
        DO:
            RUN proc_importacao(INPUT tel_cdcooper,
                                INPUT tel_dtmvtolt).
            
            IF  RETURN-VALUE = "NOK" THEN
                MESSAGE glb_dscritic VIEW-AS ALERT-BOX.
            ELSE
                MESSAGE "Arquivo importado com sucesso." VIEW-AS ALERT-BOX.

        END.
    ELSE
    IF  glb_cddopcao = "X"  THEN /* Elimina os registros de data especifica */ 
        RUN proc_desfazer.
        
END. /** Fim do DO WHILE TRUE **/

PROCEDURE carrega-query-consulta:
    
    DEF  INPUT PARAM par_flgresul AS LOGI                            NO-UNDO.

    ASSIGN aux_ultlinha = 0.

    IF  QUERY q_consulta:IS-OPEN  THEN
        DO:
            ASSIGN aux_ultlinha = QUERY q_consulta:CURRENT-RESULT-ROW.
            CLOSE QUERY q_consulta.
        END.
                        
    OPEN QUERY q_consulta 
         FOR EACH crapdlo WHERE crapdlo.cdcooper = tel_cdcooper AND
                                crapdlo.dtmvtolt = tel_dtmvtolt NO-LOCK,
             FIRST tt-contas WHERE tt-contas.cddconta = crapdlo.cddconta NO-LOCK
                                   BY STRING(crapdlo.cddconta).       

    IF  par_flgresul  THEN
        DO:
            IF  QUERY q_consulta:NUM-RESULTS = 0  THEN
                DO:
                    CLOSE QUERY q_consulta.
                    
                    BELL.
                    MESSAGE "Nenhuma conta cadastrada.".

                    RETURN "NOK".
                END.
        END.

    IF  aux_ultlinha > QUERY q_consulta:NUM-RESULTS  THEN
        ASSIGN aux_ultlinha = QUERY q_consulta:NUM-RESULTS.

    IF  aux_ultlinha > 0  THEN
        REPOSITION q_consulta TO ROW aux_ultlinha.

    RETURN "OK".

END PROCEDURE.

PROCEDURE carrega-query-detalhe:

    ASSIGN aux_ultlinha = 0.

    IF  QUERY q_detalhe:IS-OPEN  THEN
        DO:
            ASSIGN aux_ultlinha = QUERY q_detalhe:CURRENT-RESULT-ROW.
            CLOSE QUERY q_detalhe.
        END.

    OPEN QUERY q_detalhe
         FOR EACH crapddo WHERE crapddo.cdcooper = crapdlo.cdcooper AND
                                crapddo.dtmvtolt = crapdlo.dtmvtolt AND
                                crapddo.cddconta = crapdlo.cddconta 
                                NO-LOCK BY crapddo.nrseqdet.

    IF  aux_ultlinha > QUERY q_detalhe:NUM-RESULTS  THEN
        ASSIGN aux_ultlinha = QUERY q_detalhe:NUM-RESULTS.

    IF  aux_ultlinha > 0  THEN
        REPOSITION q_detalhe TO ROW aux_ultlinha.
    
END PROCEDURE.

PROCEDURE proc_importacao:
    
    DEF INPUT PARAM par_cdcooper LIKE crapcop.cdcooper              NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt LIKE crapdat.dtmvtolt              NO-UNDO.

    DEF VARIABLE aux_nmarqimp    AS    CHAR                         NO-UNDO.
    DEF VARIABLE aux_nmarquiv    AS    CHAR                         NO-UNDO.
    DEF VARIABLE aux_linhaarq    AS    CHAR                         NO-UNDO.
    
    DEF VARIABLE aux_cddconta    AS    DECI                         NO-UNDO.
    DEF VARIABLE aux_cdponder    AS    INTE                         NO-UNDO.
    DEF VARIABLE aux_porcsbcp    AS    INTE                         NO-UNDO.
    DEF VARIABLE aux_vldexpos    AS    DECI                         NO-UNDO.
    DEF VARIABLE aux_vldaeprs    AS    DECI                         NO-UNDO.

    DEF VARIABLE aux_flgarqvl    AS    LOG                          NO-UNDO.
    DEF VARIABLE aux_flgdesph    AS    LOG                          NO-UNDO.
    DEF VARIABLE aux_flagerro    AS    LOG                          NO-UNDO.

    ASSIGN glb_dscritic = "Arquivo importado com sucesso.".

    FIND FIRST crapdlo WHERE crapdlo.cdcooper = par_cdcooper AND
                             crapdlo.dtmvtolt = par_dtmvtolt AND
                             crapdlo.flgenvio = TRUE         
                             NO-LOCK NO-ERROR.
                             
    IF  AVAILABLE crapdlo  THEN
        DO:
            glb_dscritic = "Arquivo DLO referente a " +
                           STRING(par_dtmvtolt,"99/99/9999") + 
                           " ja foi gerado.".
            
            RETURN "NOK".
        END.

    /* tratamento para busca do arquivo a ser importado */
    FIND crabcop WHERE crabcop.cdcooper = tel_cdcooper NO-LOCK NO-ERROR.

    IF  NOT AVAIL(crabcop) THEN
        RETURN "NOK".

    ASSIGN  aux_nmarqimp = "/micros/" + TRIM(crabcop.dsdircop) +
                           "/contab/DLO/"
            tel_nmdireto = "Arquivo: " + aux_nmarqimp
            tel_nmdireto = FILL(" ",40 - LENGTH(tel_nmdireto)) + 
                           tel_nmdireto.

    DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:
        
        DISPLAY tel_nmdireto WITH FRAME f_arquivo.
        UPDATE  tel_nmarqimp WITH FRAME f_arquivo.

        IF  tel_nmarqimp = ""   THEN
            DO:
                MESSAGE "Arquivo nao informado.".
                NEXT.
            END.

        ASSIGN aux_nmarquiv = aux_nmarqimp + tel_nmarqimp + ".txt".

        IF  SEARCH(aux_nmarquiv) = ? THEN
            DO:
                MESSAGE "Arquivo invalido.".
                aux_flgarqvl = FALSE.
                NEXT.
            END.
        ELSE
            aux_flgarqvl = TRUE.

        LEAVE.
    END.

    HIDE FRAME f_arquivo.

    IF  NOT aux_flgarqvl THEN
        RETURN "NOK".

    INPUT STREAM str_1 
          FROM VALUE(aux_nmarquiv) NO-ECHO.

    ASSIGN aux_flgdesph = FALSE.

    importa_arquivo:         
    DO TRANSACTION ON ERROR UNDO, LEAVE ON ENDKEY UNDO, LEAVE:
        /* Processamento do arquivo a ser importado */
        DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:  
    
            IMPORT STREAM str_1 UNFORMATTED aux_linhaarq. 

            IF  aux_flgdesph = FALSE THEN /*desprezando primeira linha do arq*/
                DO:
                    ASSIGN aux_flgdesph = TRUE.
                    NEXT.
                END.

            /* formato da linha do arquivo: 
               CONTA;CODIGO PONDERACAO;VALOR EXPOSICAO;VALOR DA EPRS */
            ASSIGN aux_cddconta = DECI( ENTRY(1, aux_linhaarq, ";") )
                   aux_cdponder = INTE( ENTRY(2, aux_linhaarq, ";") )
                   aux_porcsbcp = INTE( ENTRY(3, aux_linhaarq, ";") )
                   aux_vldexpos = DECI( ENTRY(4, aux_linhaarq, ";") )
                   aux_vldaeprs = DECI( ENTRY(5, aux_linhaarq, ";") ).
    
            /* Quando ambas colunas VALOR EXPOSICAO e VALOR DA EPRS vierem 
               zeradas, a linha deve ser desprezada no arquivo.  */
            IF  aux_vldexpos = 0 AND
                aux_vldaeprs = 0 THEN
                NEXT.
            ELSE
                DO:
                    FIND FIRST tt-contas WHERE tt-contas.cddconta = aux_cddconta
                                               NO-LOCK NO-ERROR.
    
                    IF  NOT AVAIL(tt-contas) THEN
                        DO:
                            BELL.
                            MESSAGE "Conta " aux_cddconta " nao cadastrada na "
                                    "tabela CONTASDLO.".
                            UNDO importa_arquivo, LEAVE importa_arquivo.
                        END.

                    /* O valor da coluna VALOR DA EPRS deverá ser gravado nas 
                       tabelas crapdlo e crapddo, sendo que na crapddo somente 
                       será gravado quando VALOR EXPOSICAO <> 0 */

                    FIND crapdlo WHERE crapdlo.cdcooper = par_cdcooper AND
                                       crapdlo.dtmvtolt = par_dtmvtolt AND
                                       crapdlo.cddconta = aux_cddconta
                                       EXCLUSIVE-LOCK NO-ERROR.
    
                    IF  NOT AVAIL(crapdlo) THEN
                        DO: 
                            CREATE crapdlo.
                            ASSIGN crapdlo.cdcooper = par_cdcooper
                                   crapdlo.dtmvtolt = par_dtmvtolt
                                   crapdlo.cddconta = aux_cddconta
                                   crapdlo.cdlimite = tt-contas.cdlimite
                                   crapdlo.vllanmto = IF   aux_vldaeprs <> 0  THEN
                                                           aux_vldaeprs
                                                      ELSE 0.
                            
                            VALIDATE crapdlo.
                        END.


                    IF   aux_vldexpos <> 0 THEN
                         DO:        
                            RUN verifica_elementos(INPUT  glb_cdcooper,
                                                   INPUT  aux_cddconta,
                                                   INPUT  2,
                                                   INPUT  0,
                                                   INPUT  0,
                                                   OUTPUT aux_flagerro).
                                                               
                            IF  RETURN-VALUE = "NOK" AND
                                aux_flagerro         THEN
                                UNDO importa_arquivo, LEAVE importa_arquivo.
                            ELSE
                                IF  RETURN-VALUE = "NOK" AND 
                                    aux_flagerro = FALSE THEN
                                    NEXT.

                            FIND LAST crapddo WHERE crapddo.cdcooper = par_cdcooper AND
                                                    crapddo.dtmvtolt = par_dtmvtolt AND
                                                    crapddo.cddconta = aux_cddconta 
                                                    EXCLUSIVE-LOCK NO-ERROR.
        
                            IF  NOT AVAIL(crapddo) THEN
                                DO:
                                    CREATE crapddo.
                                    ASSIGN crapddo.cdcooper = par_cdcooper
                                           crapddo.dtmvtolt = par_dtmvtolt
                                           crapddo.cddconta = aux_cddconta
                                           crapddo.nrseqdet = 1
                                           crapddo.vllanmto = aux_vldaeprs.
                                           
                                    VALIDATE crapddo.                                           
                                END.
                            ELSE                                
                                DO:
                                    CREATE crabddo.
                                    ASSIGN crabddo.cdcooper = par_cdcooper
                                           crabddo.dtmvtolt = par_dtmvtolt
                                           crabddo.cddconta = aux_cddconta
                                           crabddo.nrseqdet = crapddo.nrseqdet + 1
                                           crabddo.vllanmto = aux_vldaeprs.
                                           
                                    VALIDATE crabddo.                                           
                                    
                                END.                                                                       

                            /* Cria Elemento */  
                            FIND crapedd WHERE 
                                 crapedd.cdcooper = par_cdcooper     AND
                                 crapedd.dtmvtolt = par_dtmvtolt     AND
                                 crapedd.cddconta = aux_cddconta     AND
                                 crapedd.nrseqdet = crapddo.nrseqdet AND
                                 crapedd.cdelemen = 2
                                 EXCLUSIVE-LOCK NO-ERROR.
            
                            IF  NOT AVAIL(crapedd) THEN
                                DO:
                                    CREATE crapedd.
                                    
                                    ASSIGN crapedd.cdcooper = par_cdcooper
                                           crapedd.dtmvtolt = par_dtmvtolt
                                           crapedd.cddconta = aux_cddconta
                                           crapedd.nrseqdet = crapddo.nrseqdet
                                          /* 2. Vlr contabil/vlr de exposicao(Vlr.+) */
                                           crapedd.cdelemen = 2
                                           crapedd.vlelemen = aux_vldexpos.
                                           
                                    VALIDATE crapedd.
                                END.
                                
                            /* Somente existirá valor na coluna PERCENTUAL 
                               SOBRE CAPITAL, quando VALOR EXPOSICAO <> 0 */

                            IF  aux_porcsbcp <> 0 THEN
                                DO:                                
                                    RUN verifica_elementos(INPUT  glb_cdcooper,
                                                   INPUT  aux_cddconta,
                                                   INPUT  3,
                                                   INPUT  0,
                                                   INPUT  0,
                                                   OUTPUT aux_flagerro).
                                                                     
                                    IF  RETURN-VALUE = "NOK" AND
                                        aux_flagerro         THEN
                                        UNDO importa_arquivo, LEAVE importa_arquivo.
                                    ELSE
                                        IF  RETURN-VALUE = "NOK" AND 
                                            aux_flagerro = FALSE THEN
                                            NEXT.
                                    
                                    /* Cria Elemento */  
                                    FIND crapedd WHERE 
                                         crapedd.cdcooper = par_cdcooper     AND
                                         crapedd.dtmvtolt = par_dtmvtolt     AND
                                         crapedd.cddconta = aux_cddconta     AND
                                         crapedd.nrseqdet = crapddo.nrseqdet AND
                                         crapedd.cdelemen = 3
                                         EXCLUSIVE-LOCK NO-ERROR.
                    
                                    IF  NOT AVAIL(crapedd) THEN
                                        DO:
                                            CREATE crapedd.
                                            ASSIGN crapedd.cdcooper = par_cdcooper
                                                   crapedd.dtmvtolt = par_dtmvtolt
                                                   crapedd.cddconta = aux_cddconta
                                                   crapedd.nrseqdet = crapddo.nrseqdet
                                                  /* 3. Percentuais aplicaveis ao capital */ 
                                                   crapedd.cdelemen = 3
                                                   crapedd.vlelemen = aux_porcsbcp.
                                                   
                                            VALIDATE crapedd.
                                        END.
                                END.                            

                            /* Somente existirá valor na coluna CODIGO 
                               PONDERACAO, quando VALOR EXPOSICAO <> 0 */ 
                              
                             IF  aux_cdponder <> 0 THEN
                                DO:                              
                                    RUN verifica_elementos(INPUT  glb_cdcooper,
                                                           INPUT  aux_cddconta,
                                                           INPUT  41,
                                                           INPUT  0,
                                                           INPUT  0,
                                                           OUTPUT aux_flagerro).
                                                                 
                                    IF  RETURN-VALUE = "NOK" AND
                                        aux_flagerro         THEN
                                        UNDO importa_arquivo, LEAVE importa_arquivo.
                                    ELSE
                                        IF  RETURN-VALUE = "NOK" AND 
                                            aux_flagerro = FALSE THEN
                                            NEXT.
                                    
                                    FIND crapedd WHERE 
                                         crapedd.cdcooper = par_cdcooper     AND
                                         crapedd.dtmvtolt = par_dtmvtolt     AND
                                         crapedd.cddconta = aux_cddconta     AND
                                         crapedd.nrseqdet = crapddo.nrseqdet AND
                                         crapedd.cdelemen = 41
                                         EXCLUSIVE-LOCK NO-ERROR.
                
                                    IF  NOT AVAIL(crapedd) THEN
                                        DO:
                                            CREATE crapedd.
                                            
                                            ASSIGN crapedd.cdcooper = par_cdcooper
                                                   crapedd.dtmvtolt = par_dtmvtolt
                                                   crapedd.cddconta = aux_cddconta
                                                   crapedd.nrseqdet = crapddo.nrseqdet
                                /* 41. Codigo do fator de ponderacao de exposicao(Tabela 010)*/
                                                   crapedd.cdelemen = 41
                                                   crapedd.vlelemen = aux_cdponder.
                    
                                            VALIDATE crapedd.
                                        END.
                                END.
                         END.                
                END.   

            NEXT.

        END.
                
    END.

    RETURN "OK".

END PROCEDURE.

PROCEDURE verifica_elementos:

    DEF INPUT  PARAM par_cdcooper AS INT             NO-UNDO.
    DEF INPUT  PARAM par_cddconta AS DEC             NO-UNDO.
    DEF INPUT  PARAM par_tpregis1 AS INT             NO-UNDO.
    DEF INPUT  PARAM par_tpregis2 AS INT             NO-UNDO.
    DEF INPUT  PARAM par_tpregis3 AS INT             NO-UNDO.

    DEF OUTPUT PARAM par_flagerro AS LOG             NO-UNDO.

    par_flagerro = FALSE.

    FIND FIRST craptab WHERE craptab.cdcooper = par_cdcooper AND
                             craptab.nmsistem = "DLO"        AND
                             craptab.tptabela = "CONFIG"     AND
                             craptab.cdempres = par_cddconta AND
                             craptab.cdacesso = "DETCTADLO"  NO-LOCK NO-ERROR.

    IF  NOT AVAIL(craptab) THEN
        RETURN "NOK".

    FIND crabtab WHERE crabtab.cdcooper = par_cdcooper     AND
                       crabtab.nmsistem = "DLO"            AND
                       crabtab.tptabela = "CONFIG"         AND
                       crabtab.cdempres = 0                AND
                       crabtab.cdacesso = "ELEMENDLO"      AND
                       crabtab.tpregist = par_tpregis1
                       NO-LOCK NO-ERROR.
    
    IF  NOT AVAIL(crabtab) THEN
        DO:
            ASSIGN par_flagerro = TRUE
                   glb_dscritic = 'Erro de sistema. '              +
                                  'Falta registro "ELEMENDLO". '   + 
                                  'Conta: ' + STRING(par_cddconta) + 
                                  'Tipo elemento: '                + 
                                  STRING(par_tpregis1).

            RETURN "NOK".
        END. 

    IF   par_tpregis2 <> 0 THEN
         DO:
             FIND crabtab WHERE crabtab.cdcooper = par_cdcooper     AND
                                crabtab.nmsistem = "DLO"            AND
                                crabtab.tptabela = "CONFIG"         AND
                                crabtab.cdempres = 0                AND
                                crabtab.cdacesso = "ELEMENDLO"      AND
                                crabtab.tpregist = par_tpregis2
                                NO-LOCK NO-ERROR.
    
             IF  NOT AVAIL(crabtab) THEN
                 DO:
                     ASSIGN par_flagerro = TRUE
                            glb_dscritic = 'Erro de sistema. '              +
                                           'Falta registro "ELEMENDLO". '   + 
                                           'Conta: ' + STRING(par_cddconta) + 
                                           'Tipo elemento: '                + 
                                           STRING(par_tpregis2).
          
                     RETURN "NOK".
                 END. 

         END.

    IF   par_tpregis3 <> 0 THEN
         DO:
             FIND crabtab WHERE crabtab.cdcooper = par_cdcooper     AND
                                crabtab.nmsistem = "DLO"            AND
                                crabtab.tptabela = "CONFIG"         AND
                                crabtab.cdempres = 0                AND
                                crabtab.cdacesso = "ELEMENDLO"      AND
                                crabtab.tpregist = par_tpregis3
                                NO-LOCK NO-ERROR.
    
             IF  NOT AVAIL(crabtab) THEN
                 DO:
                     ASSIGN par_flagerro = TRUE
                            glb_dscritic = 'Erro de sistema. '              +
                                           'Falta registro "ELEMENDLO". '   + 
                                           'Conta: ' + STRING(par_cddconta) + 
                                           'Tipo elemento: '                + 
                                           STRING(par_tpregis3).
          
                     RETURN "NOK".
                 END. 

         END.

    RETURN "OK".

END PROCEDURE.


PROCEDURE proc_desfazer:

    HIDE MESSAGE NO-PAUSE.

    FIND FIRST crapdlo WHERE crapdlo.cdcooper = tel_cdcooper AND
                             crapdlo.dtmvtolt = tel_dtmvtolt NO-LOCK NO-ERROR.
                                     
    IF  NOT AVAILABLE crapdlo  THEN
        DO:
            BELL.
            MESSAGE "Nenhuma conta cadastrada na tabela DLO.".
            RETURN "NOK".
        END.

    MESSAGE "Peca a liberacao ao Coordenador/Gerente...".
    PAUSE 2 NO-MESSAGE.

    RUN fontes/pedesenha.p (INPUT glb_cdcooper,  
                            INPUT 2, 
                           OUTPUT aux_flgsenha,
                           OUTPUT aux_cdoperad).
             
    IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  OR
        NOT aux_flgsenha                     THEN
        RETURN "NOK".
                
    RUN confirma-operacao.

    IF  RETURN-VALUE = "NOK"  THEN
        RETURN "NOK".
                                
    FOR EACH crapdlo WHERE crapdlo.cdcooper = tel_cdcooper AND
                           crapdlo.dtmvtolt = tel_dtmvtolt EXCLUSIVE-LOCK:
 
        FOR EACH crapddo WHERE crapddo.cdcooper = crapdlo.cdcooper AND
                               crapddo.dtmvtolt = crapdlo.dtmvtolt AND 
                               crapddo.cddconta = crapdlo.cddconta EXCLUSIVE-LOCK:
            
            DELETE crapddo.

        END.

        FOR EACH crapedd WHERE crapedd.cdcooper = crapdlo.cdcooper AND
                               crapedd.dtmvtolt = crapdlo.dtmvtolt AND
                               crapedd.cddconta = crapdlo.cddconta EXCLUSIVE-LOCK:

            DELETE crapedd.

        END.

        DELETE crapdlo.
            
    END. /** Fim do FOR EACH crapdlo **/    

    RETURN "OK".

END PROCEDURE.

PROCEDURE proc_geracao:

    RUN sistema/generico/procedures/b1wgen0035.p PERSISTENT SET h-b1wgen0035.
                
    IF  NOT VALID-HANDLE(h-b1wgen0035)  THEN
        DO:
            BELL.
            MESSAGE "Handle invalido para BO b1wgen0035.".
            RETURN "NOK".
        END.

    MESSAGE "Aguarde, gerando arquivo DLO ...".

    RUN gera_arquivo_dlo IN h-b1wgen0035 (INPUT glb_cdcooper,
                                          INPUT crapcop.cdcooper,
                                          INPUT crapcop.nrdocnpj,
                                          INPUT crapcop.dsdircop,
                                          INPUT crapcop.nmctrcop,      
                                          INPUT tel_dtmvtolt,
                                          INPUT "I",
                                         OUTPUT aux_dsdirdlo,
                                         OUTPUT TABLE tt-erro).
                                                  
    DELETE PROCEDURE h-b1wgen0035.                          
                   
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
            
            RETURN "NOK".
        END.
                         
    FOR EACH crapdlo WHERE crapdlo.cdcooper = tel_cdcooper AND
                           crapdlo.dtmvtolt = tel_dtmvtolt EXCLUSIVE-LOCK:
 
        ASSIGN crapdlo.flgenvio = TRUE.                       
            
    END. /** Fim do FOR EACH crapdlo **/
            
    HIDE MESSAGE NO-PAUSE.
    BELL.
    MESSAGE "Arquivo gerado em" aux_dsdirdlo.

    RETURN "OK".
    
END PROCEDURE.

PROCEDURE cadastrar-detalhamento:

    DEF  INPUT PARAM par_flatuali AS LOGI                            NO-UNDO.

    IF  par_flatuali  THEN
        DO:
            FIND LAST tt-crapddo NO-LOCK NO-ERROR.

            IF  AVAILABLE tt-crapddo  THEN
                ASSIGN aux_nrseqdet = tt-crapddo.nrseqdet.
        END.
    ELSE
        DO:
            EMPTY TEMP-TABLE tt-crapddo.
            EMPTY TEMP-TABLE tt-crapedd.

            ASSIGN aux_nrseqdet = 0.
        END. 

    FIND FIRST craptab WHERE craptab.cdcooper = glb_cdcooper AND
                             craptab.nmsistem = "DLO"        AND
                             craptab.tptabela = "CONFIG"     AND
                             craptab.cdempres = aux_cddconta AND
                             craptab.cdacesso = "DETCTADLO"  NO-LOCK NO-ERROR.

    IF  NOT AVAILABLE craptab  THEN
        RETURN "OK".
    
    RUN carrega-elementos.

    IF  RETURN-VALUE = "NOK"  THEN
        RETURN "NOK".
    
    VIEW FRAME f_moldura_detalhe.                                  
    PAUSE(0).

    DISPLAY aux_cddconta WITH FRAME f_detalhe.
        
    ASSIGN tel_vllandet = 0.

    DETALHAMENTO:

    DO WHILE TRUE:

        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

            UPDATE tel_vllandet WITH FRAME f_detalhe.
            LEAVE.

        END. /** Fim do DO WHILE TRUE **/
        
        IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
            LEAVE.
        
        ASSIGN aux_contador = 0
               aux_nrseqdet = aux_nrseqdet + 1.

        CLEAR FRAME f_elemento ALL NO-PAUSE.

        FOR EACH tt-detalhe WHERE tt-detalhe.flgdfixo = FALSE NO-LOCK 
                                  BY tt-detalhe.idelemen:
                         
            ASSIGN aux_contador               = aux_contador + 1
                   tel_cdelemen[aux_contador] = tt-detalhe.cdelemen
                   tel_dselemen[aux_contador] = tt-detalhe.dselemen
                   tel_vlelemen[aux_contador] = 0.
                     
            RUN atribui-formato.
                       
            IF  aux_contador < 6                    AND 
                tt-detalhe.idelemen < aux_idelemen  THEN
                NEXT.
    
            RUN informa-dados-detalhe.             

            IF  RETURN-VALUE = "NOK"  THEN
                DO:
                    FOR EACH tt-crapedd WHERE 
                             tt-crapedd.cdcooper = tel_cdcooper AND
                             tt-crapedd.dtmvtolt = tel_dtmvtolt AND
                             tt-crapedd.cddconta = aux_cddconta AND
                             tt-crapedd.nrseqdet = aux_nrseqdet EXCLUSIVE-LOCK:
                
                        DELETE tt-crapedd.
        
                    END. /** Fim do FOR EACH tt-crapedd **/
        
                    ASSIGN aux_nrseqdet = aux_nrseqdet - 1.
                    
                    NEXT DETALHAMENTO.
                END.
    
            DO aux_idextent = 1 TO aux_contador:
    
                CREATE tt-crapedd.
                ASSIGN tt-crapedd.cdcooper = tel_cdcooper
                       tt-crapedd.dtmvtolt = tel_dtmvtolt
                       tt-crapedd.cddconta = aux_cddconta
                       tt-crapedd.nrseqdet = aux_nrseqdet
                       tt-crapedd.cdelemen = tel_cdelemen[aux_idextent]
                       tt-crapedd.vlelemen = tel_vlelemen[aux_idextent].
    
            END. /** Fim do DO ... TO **/
    
            ASSIGN aux_contador = 0.
        
            CLEAR FRAME f_elemento ALL NO-PAUSE.
                       
        END. /** Fim do FOR EACH tt-detalhe **/
                                             
        FOR EACH tt-detalhe WHERE tt-detalhe.flgdfixo = TRUE NO-LOCK:

            CREATE tt-crapedd.
            ASSIGN tt-crapedd.cdcooper = tel_cdcooper
                   tt-crapedd.dtmvtolt = tel_dtmvtolt
                   tt-crapedd.cddconta = aux_cddconta
                   tt-crapedd.nrseqdet = aux_nrseqdet
                   tt-crapedd.cdelemen = tt-detalhe.cdelemen
                   tt-crapedd.vlelemen = tt-detalhe.vlelemen.

        END. /** Fim do FOR EACH tt-detalhe **/

        CREATE tt-crapddo.
        ASSIGN tt-crapddo.cdcooper = tel_cdcooper
               tt-crapddo.dtmvtolt = tel_dtmvtolt
               tt-crapddo.cddconta = aux_cddconta
               tt-crapddo.nrseqdet = aux_nrseqdet
               tt-crapddo.vllanmto = tel_vllandet
               tel_vllandet        = 0.

        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

            ASSIGN aux_confirma = "N".

            BELL.
            MESSAGE "Deseja continuar cadastrando detalhamento? (S/N)" 
                    UPDATE aux_confirma.

            LEAVE.

        END. /** Fim do DO WHILE TRUE **/

        IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  OR
            aux_confirma <> "S"                 THEN
            LEAVE.
        
    END. /** Fim do DO WHILE TRUE **/

    HIDE FRAME f_elemento        NO-PAUSE.
    HIDE FRAME f_detalhe         NO-PAUSE.
    HIDE FRAME f_moldura_detalhe NO-PAUSE.                                            
          
    FIND FIRST tt-crapddo NO-LOCK NO-ERROR.

    IF  NOT AVAILABLE tt-crapddo  THEN
        RETURN "NOK".

    RETURN "OK".

END PROCEDURE.

PROCEDURE atualizar-detalhamento:

    EMPTY TEMP-TABLE tt-crapddo.
    EMPTY TEMP-TABLE tt-crapedd.

    FIND FIRST craptab WHERE craptab.cdcooper = glb_cdcooper AND
                             craptab.nmsistem = "DLO"        AND
                             craptab.tptabela = "CONFIG"     AND
                             craptab.cdempres = aux_cddconta AND
                             craptab.cdacesso = "DETCTADLO"  NO-LOCK NO-ERROR.
        
    IF  NOT AVAILABLE craptab  THEN
        RETURN "OK".
    
    FOR EACH crapddo WHERE crapddo.cdcooper = crapdlo.cdcooper AND
                           crapddo.dtmvtolt = crapdlo.dtmvtolt AND
                           crapddo.cddconta = crapdlo.cddconta NO-LOCK:

        CREATE tt-crapddo.
        BUFFER-COPY crapddo TO tt-crapddo.

    END. /** Fim do FOR EACH crapddo **/

    FOR EACH crapedd WHERE crapedd.cdcooper = crapdlo.cdcooper AND
                           crapedd.dtmvtolt = crapdlo.dtmvtolt AND
                           crapedd.cddconta = crapdlo.cddconta NO-LOCK:

        CREATE tt-crapedd.
        BUFFER-COPY crapedd TO tt-crapedd.
        
    END. /** Fim do FOR EACH crapedd **/ 

    RUN carrega-elementos.

    IF  RETURN-VALUE = "NOK"  THEN
        RETURN "NOK".

    VIEW FRAME f_moldura_detalhe.                                  
    PAUSE(0).

    DISPLAY aux_cddconta WITH FRAME f_detalhe.

    FOR EACH tt-crapddo EXCLUSIVE-LOCK BY tt-crapddo.nrseqdet:

        ASSIGN tel_vllandet = tt-crapddo.vllanmto.

        DETALHAMENTO:

        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

            UPDATE tel_vllandet WITH FRAME f_detalhe.

            ASSIGN aux_contador = 0.

            CLEAR FRAME f_elemento ALL NO-PAUSE.

            FOR EACH tt-detalhe WHERE tt-detalhe.flgdfixo = FALSE 
                                      NO-LOCK BY tt-detalhe.idelemen:
                             
                FIND tt-crapedd WHERE 
                     tt-crapedd.cdcooper = tt-crapddo.cdcooper AND
                     tt-crapedd.dtmvtolt = tt-crapddo.dtmvtolt AND
                     tt-crapedd.cddconta = tt-crapddo.cddconta AND
                     tt-crapedd.nrseqdet = tt-crapddo.nrseqdet AND
                     tt-crapedd.cdelemen = tt-detalhe.cdelemen NO-LOCK NO-ERROR.
    
                IF  NOT AVAILABLE tt-crapedd  THEN
                    DO:
                        BELL.
                        MESSAGE "Elemento nao cadastrado para o detalhe.".
    
                        HIDE FRAME f_elemento        NO-PAUSE.
                        HIDE FRAME f_detalhe         NO-PAUSE.
                        HIDE FRAME f_moldura_detalhe NO-PAUSE.
    
                        RETURN "NOK".
                    END.
    
                ASSIGN aux_contador               = aux_contador + 1
                       tel_cdelemen[aux_contador] = tt-detalhe.cdelemen
                       tel_dselemen[aux_contador] = tt-detalhe.dselemen
                       tel_vlelemen[aux_contador] = tt-crapedd.vlelemen.
                         
                RUN atribui-formato.
                           
                IF  aux_contador < 6                    AND 
                    tt-detalhe.idelemen < aux_idelemen  THEN
                    NEXT.
        
                RUN informa-dados-detalhe.             
    
                IF  RETURN-VALUE = "NOK"  THEN
                    NEXT DETALHAMENTO.    
        
                DO aux_idextent = 1 TO aux_contador:
        
                    FIND tt-crapedd WHERE 
                         tt-crapedd.cdcooper = tt-crapddo.cdcooper        AND
                         tt-crapedd.dtmvtolt = tt-crapddo.dtmvtolt        AND
                         tt-crapedd.cddconta = tt-crapddo.cddconta        AND
                         tt-crapedd.nrseqdet = tt-crapddo.nrseqdet        AND
                         tt-crapedd.cdelemen = tel_cdelemen[aux_idextent]
                         EXCLUSIVE-LOCK NO-ERROR.

                    ASSIGN tt-crapedd.vlelemen = tel_vlelemen[aux_idextent].
        
                END. /** Fim do DO ... TO **/
        
                ASSIGN aux_contador = 0.
            
                CLEAR FRAME f_elemento ALL NO-PAUSE.
                           
            END. /** Fim do FOR EACH tt-detalhe **/

            LEAVE.

        END. /** Fim do DO WHILE TRUE **/

        IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
            LEAVE.

        ASSIGN tt-crapddo.vllanmto = tel_vllandet.

    END. /** Fim do FOR EACH tt-crapddo **/        
    
    HIDE FRAME f_elemento        NO-PAUSE.
    HIDE FRAME f_detalhe         NO-PAUSE.
    HIDE FRAME f_moldura_detalhe NO-PAUSE.

    IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
        RETURN "NOK".
        
    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

        ASSIGN aux_confirma = "N".

        BELL.
        MESSAGE "Deseja cadastrar novo detalhamento? (S/N)" 
                UPDATE aux_confirma.

        LEAVE.

    END. /** Fim do DO WHILE TRUE **/

    IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  OR
        aux_confirma <> "S"                 THEN
        RETURN "OK".

    RUN cadastrar-detalhamento (INPUT TRUE).

    RETURN "OK".

END PROCEDURE.

PROCEDURE carrega-elementos:

    EMPTY TEMP-TABLE tt-detalhe.
    
    ASSIGN aux_idelemen = 0.

    FOR EACH craptab WHERE craptab.cdcooper = glb_cdcooper AND
                           craptab.nmsistem = "DLO"        AND
                           craptab.tptabela = "CONFIG"     AND
                           craptab.cdempres = aux_cddconta AND
                           craptab.cdacesso = "DETCTADLO"  
                           NO-LOCK BY craptab.tpregist:

        FIND crabtab WHERE crabtab.cdcooper = glb_cdcooper     AND
                           crabtab.nmsistem = "DLO"            AND
                           crabtab.tptabela = "CONFIG"         AND
                           crabtab.cdempres = 0                AND
                           crabtab.cdacesso = "ELEMENDLO"      AND
                           crabtab.tpregist = craptab.tpregist 
                           NO-LOCK NO-ERROR.

        IF  NOT AVAILABLE crabtab  THEN
            DO:
                BELL.
                MESSAGE 'Erro de sistema. Falta registro "ELEMENDLO".'.
                RETURN "NOK".
            END.
            
        CREATE tt-detalhe.
        ASSIGN tt-detalhe.cdelemen = crabtab.tpregist
               tt-detalhe.dselemen = ENTRY(3,crabtab.dstextab,";")
               tt-detalhe.vlelemen = DECI(TRIM(craptab.dstextab))
               tt-detalhe.dsformat = ENTRY(2,crabtab.dstextab,";")
               tt-detalhe.flgdfixo = (TRIM(craptab.dstextab) <> "").

        IF  NOT tt-detalhe.flgdfixo  THEN
            ASSIGN aux_idelemen        = aux_idelemen + 1
                   tt-detalhe.idelemen = aux_idelemen.

    END. /** Fim do FOR EACH craptab **/

    RETURN "OK".

END PROCEDURE.

PROCEDURE atribui-formato:

    CASE aux_contador:
        WHEN 1 THEN tel_vlelemen[1]:FORMAT 
                    IN FRAME f_elemento = tt-detalhe.dsformat.
        WHEN 2 THEN tel_vlelemen[2]:FORMAT 
                    IN FRAME f_elemento = tt-detalhe.dsformat.
        WHEN 3 THEN tel_vlelemen[3]:FORMAT 
                    IN FRAME f_elemento = tt-detalhe.dsformat.
        WHEN 4 THEN tel_vlelemen[4]:FORMAT 
                    IN FRAME f_elemento = tt-detalhe.dsformat.
        WHEN 5 THEN tel_vlelemen[5]:FORMAT 
                    IN FRAME f_elemento = tt-detalhe.dsformat.
        WHEN 6 THEN tel_vlelemen[6]:FORMAT 
                    IN FRAME f_elemento = tt-detalhe.dsformat.
    END.

END PROCEDURE.

PROCEDURE informa-dados-detalhe:

    DISPLAY tel_cdelemen[1] WHEN aux_contador >= 1
            tel_dselemen[1] WHEN aux_contador >= 1
            tel_vlelemen[1] WHEN aux_contador >= 1
            tel_cdelemen[2] WHEN aux_contador >= 2
            tel_dselemen[2] WHEN aux_contador >= 2
            tel_vlelemen[2] WHEN aux_contador >= 2
            tel_cdelemen[3] WHEN aux_contador >= 3
            tel_dselemen[3] WHEN aux_contador >= 3
            tel_vlelemen[3] WHEN aux_contador >= 3
            tel_cdelemen[4] WHEN aux_contador >= 4
            tel_dselemen[4] WHEN aux_contador >= 4
            tel_vlelemen[4] WHEN aux_contador >= 4
            tel_cdelemen[5] WHEN aux_contador >= 5
            tel_dselemen[5] WHEN aux_contador >= 5
            tel_vlelemen[5] WHEN aux_contador >= 5
            tel_cdelemen[6] WHEN aux_contador >= 6
            tel_dselemen[6] WHEN aux_contador >= 6
            tel_vlelemen[6] WHEN aux_contador >= 6
            WITH FRAME f_elemento.

    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

        UPDATE tel_vlelemen[1] WHEN aux_contador >= 1
               tel_vlelemen[2] WHEN aux_contador >= 2
               tel_vlelemen[3] WHEN aux_contador >= 3
               tel_vlelemen[4] WHEN aux_contador >= 4
               tel_vlelemen[5] WHEN aux_contador >= 5
               tel_vlelemen[6] WHEN aux_contador >= 6
               WITH FRAME f_elemento.

        LEAVE.

    END. /** Fim do DO WHILE TRUE **/

    IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
        DO: 
            HIDE FRAME f_elemento NO-PAUSE.

            RETURN "NOK".
        END.
            
    RETURN "OK".

END PROCEDURE.

PROCEDURE grava-cadastramento-dlo:

    CREATE crapdlo.
    ASSIGN crapdlo.cdcooper = tel_cdcooper
           crapdlo.dtmvtolt = tel_dtmvtolt
           crapdlo.cddconta = DECI(tt-contas.cddconta)
           crapdlo.cdlimite = tt-contas.cdlimite
           crapdlo.vllanmto = tel_vllanmto.

    VALIDATE crapdlo.

    FOR EACH tt-crapddo NO-LOCK:

        CREATE crapddo.
        BUFFER-COPY tt-crapddo TO crapddo.
        
        VALIDATE crapddo.

    END. /** Fim do FOR EACH tt-crapddo **/

    FOR EACH tt-crapedd NO-LOCK:

        CREATE crapedd.
        BUFFER-COPY tt-crapedd TO crapedd.

        VALIDATE crapedd.

    END. /** Fim do FOR EACH tt-crapedd **/

    FIND CURRENT crapdlo NO-LOCK NO-ERROR.
    FIND CURRENT crapddo NO-LOCK NO-ERROR.
    FIND CURRENT crapedd NO-LOCK NO-ERROR.

END PROCEDURE.

PROCEDURE grava-atualizacao-dlo:

    ASSIGN crapdlo.vllanmto = tel_vllanmto.

    FOR EACH tt-crapddo NO-LOCK:

        FIND crapddo WHERE crapddo.cdcooper = tt-crapddo.cdcooper AND
                           crapddo.dtmvtolt = tt-crapddo.dtmvtolt AND
                           crapddo.cddconta = tt-crapddo.cddconta AND
                           crapddo.nrseqdet = tt-crapddo.nrseqdet
                           EXCLUSIVE-LOCK NO-ERROR.

        IF  AVAILABLE crapddo  THEN
            ASSIGN crapddo.vllanmto = tt-crapddo.vllanmto.
        ELSE
            DO:
                CREATE crapddo.
                BUFFER-COPY tt-crapddo TO crapddo.

                VALIDATE crapddo.

            END.

    END. /** Fim do FOR EACH tt-crapddo **/

    FOR EACH tt-crapedd NO-LOCK:

        FIND crapedd WHERE crapedd.cdcooper = tt-crapedd.cdcooper AND
                           crapedd.dtmvtolt = tt-crapedd.dtmvtolt AND
                           crapedd.cddconta = tt-crapedd.cddconta AND
                           crapedd.nrseqdet = tt-crapedd.nrseqdet AND
                           crapedd.cdelemen = tt-crapedd.cdelemen
                           EXCLUSIVE-LOCK NO-ERROR.

        IF  AVAILABLE crapedd  THEN
            ASSIGN crapedd.vlelemen = tt-crapedd.vlelemen.
        ELSE
            DO:
                CREATE crapedd.
                BUFFER-COPY tt-crapedd TO crapedd.

                VALIDATE crapedd.

            END.

    END.

    FIND CURRENT crapdlo NO-LOCK NO-ERROR.
    FIND CURRENT crapddo NO-LOCK NO-ERROR.
    FIND CURRENT crapedd NO-LOCK NO-ERROR.

END PROCEDURE.

PROCEDURE confirma-operacao:

    ASSIGN aux_confirma = "N".
    
    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
    
        ASSIGN glb_cdcritic = 78.
        RUN fontes/critic.p.
        BELL.
        MESSAGE glb_dscritic UPDATE aux_confirma.
        LEAVE.
    
    END. /** Fim do DO WHILE TRUE **/

    IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  OR 
        aux_confirma <> "S"                 THEN
        DO:
            ASSIGN glb_cdcritic = 79.
            RUN fontes/critic.p.
            BELL.
            MESSAGE glb_dscritic.
            
            RETURN "NOK".
        END.

    RETURN "OK".

END PROCEDURE.

PROCEDURE atribui-help:

    DEF VAR aux_desdhelp AS CHAR                                    NO-UNDO.
    
    ASSIGN aux_desdhelp = "".

    IF  glb_cddopcao = "C"  THEN
        ASSIGN aux_desdhelp = "Use as setas para navegar ou <END>/<F4> " +
                              "para sair.".
    ELSE
    IF  glb_cddopcao = "L"  THEN
        DO: 
            IF  aux_cdopclcm = "A"  THEN
                ASSIGN aux_desdhelp = "Setas para navegar, <ENTER> para " +
                                      "alterar, <END>/<F4> para sair.".
            ELSE
            IF  aux_cdopclcm = "E"  THEN
                ASSIGN aux_desdhelp = "<ENTER> para detalhes, <DELETE> " +
                                      "para excluir, <END>/<F4> para sair.".
        END.

    /** Atribui HELP ao browse referente a operacao **/
    b_consulta:HELP IN FRAME f_consulta = aux_desdhelp.

END PROCEDURE.


/*............................................................................*/

