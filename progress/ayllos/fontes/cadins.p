/* ............................................................................

   Programa: Fontes/cadins.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Guilherme
   Data    : Outubro/2007                        Ultima alteracao: 29/05/2014

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela CADINS 
               Alteracoes de dados cadastrais e formas de pagamento ref. INSS 
   
   Alteracao : 08/02/2008 - Alterado para gerar log/cadins.log (Gabriel).

               24/03/2009 - Incluir opcao para impressao de declaracao com os
                            dados do cooperado (Gabriel)

               29/04/2009 - Arrumar impressao do termo (Gabriel).
               
               17/09/2010 - Alterar o nome do caminho de impressao do termo 
                            "arq/cadins.txt" p/ variável aux_nmarquiv (Vitor).
                            
               18/05/2011 - Adaptacao para uso de BO. (André - DB1)
               
               10/09/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).
                            
               29/05/2014 - Concatena o numero do servidor no endereco do
                            terminal (Tiago-RKAM)
............................................................................ */

{ includes/var_online.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/b1wgen0091tt.i }
{ sistema/generico/includes/b1wgen0059tt.i }

DEF VAR aux_confirma AS CHAR  FORMAT "!(1)"                      NO-UNDO.
DEF VAR aux_cddopcao AS CHAR                                     NO-UNDO.

DEF VAR tel_nrcpfcgc AS CHAR  FORMAT "x(18)"                     NO-UNDO.
DEF VAR tel_nmrecben          LIKE crapcbi.nmrecben              NO-UNDO.
DEF VAR tel_nrbenefi          LIKE crapcbi.nrbenefi              NO-UNDO.
DEF VAR tel_nrrecben          LIKE crapcbi.nrrecben              NO-UNDO.
DEF VAR tel_cdagenci          LIKE crapcbi.cdagenci              NO-UNDO.
DEF VAR tel_cdaginss          LIKE crapcbi.cdaginss              NO-UNDO.
DEF VAR tel_nrdconta          LIKE crapcbi.nrdconta              NO-UNDO.
DEF VAR tel_nrnovcta          LIKE crapcbi.nrnovcta              NO-UNDO.
DEF VAR tel_tpmepgto          LIKE crapcbi.tpmepgto              NO-UNDO.
DEF VAR tel_tpnovmpg          LIKE crapcbi.tpnovmpg              NO-UNDO.
DEF VAR tel_nmprimtl          LIKE crapass.nmprimtl              NO-UNDO.
DEF VAR tel_dsmepgto AS CHAR  FORMAT "x(13)"                     NO-UNDO.
DEF VAR tel_dsnovmpg AS CHAR  FORMAT "x(13)"                     NO-UNDO.
DEF VAR tel_cdaltera AS INT   FORMAT "99"                        NO-UNDO.
DEF VAR tel_dsaltera AS CHAR  FORMAT "x(63)"                     NO-UNDO.
DEF VAR tel_dtatucad          LIKE crapcbi.dtatucad              NO-UNDO.
DEF VAR tel_dtdenvio          LIKE crapcbi.dtdenvio              NO-UNDO.
DEF VAR aux_cdaltcad          LIKE crapcbi.cdaltcad              NO-UNDO.
DEF VAR rel_dtrefere AS CHAR  FORMAT "x(45)"                     NO-UNDO.

/* Variaveis para impressao */
DEF VAR tel_dsimprim AS CHAR  FORMAT "x(8)" INIT "Imprimir"      NO-UNDO.
DEF VAR tel_dscancel AS CHAR  FORMAT "x(8)" INIT "Cancelar"      NO-UNDO.

DEF VAR aux_contador AS INTE                                     NO-UNDO.
DEF VAR aux_nmendter AS CHAR                                     NO-UNDO.
DEF VAR aux_flgescra AS LOGI                                     NO-UNDO.
DEF VAR aux_dscomand AS CHAR                                     NO-UNDO.
DEF VAR aux_nmarqimp AS CHAR                                     NO-UNDO.
DEF VAR aux_nmarquiv AS CHAR                                     NO-UNDO.
DEF VAR par_flgrodar AS LOGI                                     NO-UNDO.
DEF VAR par_flgfirst AS LOGI                                     NO-UNDO.
DEF VAR par_flgcance AS LOGI                                     NO-UNDO.
DEF VAR par_qtregist AS INTE                                     NO-UNDO.
DEF VAR par_nmprimtl AS CHAR                                     NO-UNDO.
DEF VAR par_dsnovmpg AS CHAR                                     NO-UNDO.
DEF VAR par_nrnovcta AS INTE                                     NO-UNDO.
DEF VAR par_tpnovmpg AS INTE                                     NO-UNDO.
DEF VAR par_msgretor AS CHAR                                     NO-UNDO.
DEF VAR par_nmdcampo AS CHAR                                     NO-UNDO.
DEF VAR aux_nmarqpdf AS CHAR                                     NO-UNDO.
DEF VAR aux_qtregist AS INTE                                     NO-UNDO.

DEF VAR h-b1wgen0091 AS HANDLE                                   NO-UNDO.
DEF VAR h-b1wgen0059 AS HANDLE                                   NO-UNDO.

FORM SKIP(1)
     tel_cdagenci AT 2  LABEL "PA"
          HELP "Informe o numero do PA credenciado ao INSS."
     tel_nmrecben AT 25 LABEL "Nome do beneficiario"
          HELP "Informe o nome do beneficiario ou pressione <ENTER> p/ listar."
                        FORMAT "x(30)"
     SKIP(1)
     tel_nrbenefi AT 20 LABEL "NB"   
     tel_nrrecben AT 42 LABEL "NIT"
     SKIP 
     tel_cdaginss AT 4  LABEL "Agencia local INSS"
     tel_nrcpfcgc AT 42 LABEL "CPF"
     SKIP(1) 
     tel_cdaltera AT 2  LABEL "Opcoes"
          HELP "Informe o numero da opcao ou pressione <F7> para listar."  
                        AUTO-RETURN   
     " - "        AT 12
     tel_dsaltera AT 16 NO-LABEL
     SKIP(1)
     tel_nrdconta AT 8  LABEL "Conta corrente"
     tel_nrnovcta AT 42 LABEL "Nova conta corrente"
                        HELP "Informe a nova conta corrente do beneficiario "
     tel_nmprimtl AT 42 LABEL "Nome" 
                        FORMAT "x(30)"
     SKIP
     tel_dsmepgto AT 5  LABEL "Meio de pagamento"
     tel_dsnovmpg AT 42 LABEL "Novo meio de pagamento"
     SKIP(2)
     tel_dtatucad AT 3  LABEL "Data da solicitacao"
     tel_dtdenvio AT 42 LABEL "Data do envio"
     SKIP(1)
     WITH ROW 4 OVERLAY SIDE-LABELS WIDTH 80 TITLE glb_tldatela FRAME f_cadins.
        

DEF QUERY q_nome FOR tt-benefic.

DEF BROWSE b_nome QUERY q_nome
    DISP tt-benefic.nmrecben COLUMN-LABEL "Nome"        FORMAT "x(30)"
         tt-benefic.nrcpfcgc COLUMN-LABEL "CPF"       
         tt-benefic.nrbenefi COLUMN-LABEL "NB"
         tt-benefic.nrrecben COLUMN-LABEL "NIT"
         WITH 6 DOWN WIDTH 73 NO-BOX SCROLLBAR-VERTICAL.

DEF FRAME f_nome
          b_nome  
          HELP "Use as <SETAS> para navegar ou <ENTER> para selecionar"
    WITH CENTERED OVERLAY ROW 10 TITLE " Nomes ".     


ON  RETURN OF b_nome IN FRAME f_nome
    DO:                       
        DISABLE b_nome WITH FRAME f_nome.
        HIDE FRAME f_nome.
        
        ASSIGN tel_nrcpfcgc = STRING(tt-benefic.nrcpfcgc,"99999999999")
               tel_nrcpfcgc = STRING(tel_nrcpfcgc,"xxx.xxx.xxx-xx")
               tel_nmrecben = tt-benefic.nmrecben
               tel_cdaginss = tt-benefic.cdaginss
               tel_dtatucad = tt-benefic.dtatucad
               tel_dtdenvio = tt-benefic.dtdenvio
               tel_nrrecben = tt-benefic.nrrecben
               tel_nrbenefi = tt-benefic.nrbenefi
               aux_cdaltcad = tt-benefic.cdaltcad.
   
        DISPLAY tel_nrcpfcgc
                tel_nmrecben
                tel_cdaginss
                tel_dtatucad
                tel_dtdenvio
                tel_nrrecben
                tel_nrbenefi
                WITH FRAME f_cadins.
                
        APPLY "END-ERROR".
        
    END. /* Fim do ON ENTER */

ASSIGN glb_cddopcao = "A" 
       glb_cdcritic = 0.

RUN fontes/inicia.p.

VIEW FRAME f_moldura.

PAUSE 0.

IF  NOT VALID-HANDLE(h-b1wgen0091)  THEN
    RUN sistema/generico/procedures/b1wgen0091.p 
        PERSISTENT SET h-b1wgen0091.

INICIO: DO WHILE TRUE ON ENDKEY UNDO, LEAVE :

    HIDE tel_dsaltera tel_nmprimtl IN FRAME f_cadins.
    
    CLEAR FRAME f_cadins.
    
    RELEASE crapcbi.
    
    ASSIGN tel_nrcpfcgc = ""
           tel_nmrecben = ""
           tel_nrrecben = 0
           tel_nrbenefi = 0
           tel_cdaginss = 0
           tel_cdaltera = 0
           tel_nrnovcta = 0
           tel_tpnovmpg = 0.

    DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:
    
        UPDATE tel_cdagenci tel_nmrecben WITH FRAME f_cadins.
                          
        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
    
            RUN busca-benefic IN h-b1wgen0091
                ( INPUT glb_cdcooper,
                  INPUT 0,
                  INPUT 0,
                  INPUT tel_nmrecben,
                  INPUT tel_cdagenci,
                  INPUT 99999999,
                  INPUT 1,
                 OUTPUT aux_qtregist,
                 OUTPUT TABLE tt-erro,
                 OUTPUT TABLE tt-benefic ).
    
            IF  RETURN-VALUE <> "OK"  THEN
                DO:
                    FIND FIRST tt-erro NO-LOCK NO-ERROR.
                    IF  AVAIL tt-erro  THEN
                        DO:
                            MESSAGE tt-erro.dscritic.
                            LEAVE.
                        END.
                END.

            OPEN QUERY q_nome FOR EACH tt-benefic NO-LOCK.
    
            ENABLE b_nome WITH FRAME f_nome.
                  
            WAIT-FOR END-ERROR OF DEFAULT-WINDOW.

            HIDE FRAME f_nome.
              
            HIDE MESSAGE NO-PAUSE.
             
            LEAVE.
        END.  /*  Fim do DO WHILE TRUE  */
        LEAVE.
    END.

    IF  KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
        DO:
            RUN fontes/novatela.p.
            IF   CAPS(glb_nmdatela) <> "CADINS"   THEN
                 DO:
                     HIDE FRAME f_cadins.
                     HIDE FRAME f_moldura.
                     LEAVE.
                 END.
            ELSE
                 NEXT.
        END.

    IF  aux_cddopcao <> glb_cddopcao   THEN
        DO:
           { includes/acesso.i }
           ASSIGN aux_cddopcao = glb_cddopcao.
        END.

    IF  CAN-FIND(FIRST tt-benefic) THEN
        DO:
            ASSIGN tel_nrcpfcgc = STRING(tt-benefic.nrcpfcgc,"99999999999")
                   tel_nrcpfcgc = STRING(tel_nrcpfcgc,"xxx.xxx.xxx-xx")
                   tel_nmrecben = tt-benefic.nmrecben
                   tel_cdaginss = tt-benefic.cdaginss
                   tel_nrdconta = tt-benefic.nrdconta
                   tel_tpmepgto = tt-benefic.tpmepgto.
                   
            IF  tt-benefic.tpmepgto = 1   THEN
                ASSIGN tel_dsmepgto = "Cartao/Recibo".
            ELSE
                ASSIGN tel_dsmepgto = "Conta".
           
            DISPLAY tel_nrcpfcgc
                    tel_nmrecben
                    tel_cdaginss
                    tel_nrdconta
                    tel_dsmepgto
                    WITH FRAME f_cadins.
                  
            ASSIGN tel_nrnovcta = 0
                   tel_tpnovmpg = 0.
            
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
          
                UPDATE tel_cdaltera WITH FRAME f_cadins

                EDITING:

                    READKEY.

                    HIDE MESSAGE NO-PAUSE.

                    IF  LASTKEY = KEYCODE("F7") THEN 
                        DO:   
                            IF  FRAME-FIELD = "tel_cdaltera"  THEN
                                DO:
                                    RUN fontes/zoom_manutencao_inss.p
                                        ( INPUT 0,
                                          INPUT "CRED",
                                          INPUT "GENERI",
                                          INPUT 0,
                                          INPUT "DSCMANINSS",
                                         OUTPUT tel_cdaltera,
                                         OUTPUT tel_dsaltera ).

                                    DISPLAY tel_cdaltera tel_dsaltera
                                        WITH FRAME f_cadins.
            
                                    NEXT-PROMPT tel_cdaltera 
                                           WITH FRAME f_cadins.
                                END.
                        END.
                    ELSE
                        APPLY LASTKEY.

                    IF  GO-PENDING  THEN
                        DO:
                            ASSIGN INPUT tel_cdaltera.

                            RUN valida-opcao IN h-b1wgen0091
                                ( INPUT glb_cdcooper,
                                  INPUT 0,           
                                  INPUT 0,           
                                  INPUT glb_cdoperad,
                                  INPUT glb_nmdatela,
                                  INPUT 1,           
                                  INPUT tel_nrdconta,
                                  INPUT 0,           
                                  INPUT YES,
                                  INPUT glb_dtmvtolt,
                                  INPUT tel_nrrecben,
                                  INPUT tel_nrbenefi,
                                  INPUT tel_cdaltera,
                                 OUTPUT par_nmprimtl,
                                 OUTPUT par_dsnovmpg,
                                 OUTPUT par_nrnovcta,
                                 OUTPUT par_tpnovmpg,
                                 OUTPUT par_msgretor,
                                 OUTPUT tel_dsaltera, 
                                 OUTPUT par_nmdcampo,
                                 OUTPUT TABLE tt-erro ).

                            DISPLAY tel_dsaltera WITH FRAME f_cadins.
        
                            IF  RETURN-VALUE <> "OK"  THEN
                                DO:
                                    FIND FIRST tt-erro NO-LOCK NO-ERROR.
                                    IF  AVAIL tt-erro  THEN
                                        DO:
                                            MESSAGE tt-erro.dscritic.
                                            {sistema/generico/includes/foco_campo.i
                                                &VAR-GERAL="sim"
                                                &NOME-FRAME="f_cadins"
                                                &NOME-CAMPO=par_nmdcampo }
                                        END.
                                END.
                            
                        END.
                END. /* Fim do UPDATE EDITING */

                DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                    IF  tel_cdaltera = 91 THEN
                        DO:
                            ASSIGN tel_nrnovcta = par_nrnovcta
                                   tel_nmprimtl = par_nmprimtl
                                   tel_dsnovmpg = par_dsnovmpg.

                            DISPLAY tel_nrnovcta
                                    tel_nmprimtl
                                    tel_dsnovmpg
                                    WITH FRAME f_cadins.

                            LEAVE.
                        END.
                    ELSE
                    IF  tel_cdaltera = 93  THEN
                        DO:

                            RUN gera-declaracao IN h-b1wgen0091
                                ( INPUT glb_cdcooper,
                                  INPUT 0,
                                  INPUT 0,
                                  INPUT glb_cdoperad,
                                  INPUT glb_nmdatela,
                                  INPUT 1,
                                  INPUT tel_nrdconta,
                                  INPUT 1,
                                  INPUT TRUE,
                                  INPUT glb_dtmvtolt,
                                  INPUT tel_nmrecben,
                                  INPUT tel_nrbenefi,
                                  INPUT aux_nmendter,
                                  INPUT tel_cdagenci,
                                 OUTPUT aux_nmarqimp,
                                 OUTPUT aux_nmarqpdf,
                                 OUTPUT glb_cdrelato[1],
                                 OUTPUT TABLE tt-erro ).

                            IF  RETURN-VALUE <> "OK"  THEN
                                DO:
                                    FIND FIRST tt-erro 
                                               NO-LOCK NO-ERROR.
                                    IF  AVAIL tt-erro  THEN
                                        DO:
                                            MESSAGE tt-erro.dscritic.
                                            LEAVE.
                                        END.
                                END.

                            ASSIGN glb_nrdevias = 1
                                   par_flgrodar = TRUE
                                   glb_nmformul = "80col".
                        
                            RUN imprimir.

                            IF  KEYFUNCTION(LASTKEY) <> "END-ERROR" THEN
                                RUN gera_log_cdns IN h-b1wgen0091
                                    ( INPUT glb_cdcooper,
                                      INPUT glb_dtmvtolt,
                                      INPUT glb_cdoperad,
                                      INPUT tel_nrnovcta,
                                      INPUT tel_nmrecben,
                                      INPUT tel_nrbenefi,
                                      INPUT tel_nrrecben,
                                      "Imprimiu a declaracao de " +
                                      "recebimento de cartao de " +
                                      "beneficio" ).
                            LEAVE.
                        END.
                    ELSE
                    IF  tel_cdaltera = 02 OR tel_cdaltera = 09  THEN
                        DO:
                            IF  par_msgretor <> "" THEN
                                DO:
                                    MESSAGE par_msgretor.

                                    ASSIGN tel_nrnovcta = par_nrnovcta
                                           tel_nmprimtl = par_nmprimtl
                                           tel_dsnovmpg = par_dsnovmpg.

                                    DISPLAY tel_nrnovcta
                                            tel_nmprimtl
                                            tel_dsnovmpg
                                            WITH FRAME f_cadins.

                                    RUN confirma.
                                END.
                        END.
                    ELSE
                        RUN confirma.

                    IF  aux_confirma = "S" OR 
                        ((tel_cdaltera = 02 OR tel_cdaltera = 09) AND 
                        par_msgretor = "")  THEN
                        DO:

                            IF  tel_cdaltera = 02 THEN
                                DO:
                                    RUN opcao-02.

                                    IF  RETURN-VALUE <> "OK" THEN
                                        LEAVE.
                                END.

                            IF  tel_cdaltera = 09 THEN
                                DO:
                                    RUN opcao-09.

                                    IF  RETURN-VALUE <> "OK" THEN
                                        LEAVE.
                                END.

                            IF  tel_cdaltera <> 02 AND
                                tel_cdaltera <> 09 THEN
                                DO:
                                    RUN trata-opcao.

                                    IF  RETURN-VALUE <> "OK" THEN
                                        LEAVE.
                                END.

                            IF  tel_cdaltera = 90   THEN
                                DO:
                                    ASSIGN tel_tpnovmpg = 0
                                           tel_dtatucad = ?
                                           tel_nrnovcta = 0
                                           tel_dtdenvio = ?
                                           tel_nmprimtl = "".
                                    
                                    DISPLAY tel_nrnovcta
                                            tel_dtdenvio
                                            tel_dtatucad
                                            WITH FRAME f_cadins.
                                    
                                    HIDE tel_dsnovmpg IN FRAME f_cadins.
                                    HIDE tel_nmprimtl IN FRAME f_cadins.
                                    
                                END.   
                            ELSE
                            IF  tel_cdaltera = 92  THEN
                                DO:
                                    ASSIGN tel_dtatucad = glb_dtmvtolt.
                                           
                                    DISPLAY tel_dtatucad
                                            WITH FRAME f_cadins.
                                END.   
                            ELSE
                            IF  tel_cdaltera = 01   THEN
                                DO:

                                    ASSIGN tel_tpnovmpg = 1
                                           tel_dtatucad = glb_dtmvtolt
                                           tel_dsnovmpg = "Cartao/Recibo".
                                                                          
                                    DISPLAY tel_dsnovmpg
                                            tel_dtatucad
                                            WITH FRAME f_cadins.

                                    RUN imprimir.
                                                                    
                                END. /* Fim da OPCAO 1 */
                             
                        END. /* Fim do IF aux_confirma = "S" */

                    LEAVE.
               
                END. /* Fim do DO WHILE TRUE */

            END. /* Fim do DO WHILE TRUE */

            IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
                NEXT.
    
            LEAVE.
        
        END. /* Fim do CAN-FIND(FIRST tt-benefic) */
    
    RELEASE crapcbi.
    
    ASSIGN tel_nmprimtl = "".
           tel_tpnovmpg =  0.
           tel_nrnovcta =  0.
    
    CLEAR FRAME f_cadins.
 
END.

IF  VALID-HANDLE(h-b1wgen0091)  THEN
    DELETE PROCEDURE h-b1wgen0091.



/****** PROCEDURES ******/           
PROCEDURE confirma:

   /* Confirma */
    DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:
        ASSIGN aux_confirma = "N"
               glb_cdcritic = 78.
               RUN fontes/critic.p.
               glb_cdcritic = 0.
               BELL.
               MESSAGE COLOR NORMAL glb_dscritic UPDATE aux_confirma.
               LEAVE.
    END.  /*  Fim do DO WHILE TRUE  */
            
    IF  KEYFUNCTION(LASTKEY) = "END-ERROR"   OR   aux_confirma <> "S" THEN
        DO:
            glb_cdcritic = 79.
            RUN fontes/critic.p.
            glb_cdcritic = 0.
            BELL.
            MESSAGE glb_dscritic.
            NEXT.
        END. /* Mensagem de confirmacao */

END PROCEDURE.


PROCEDURE trata-opcao:

    INPUT THROUGH basename `tty` NO-ECHO.

    SET aux_nmendter WITH FRAME f_terminal.
    INPUT CLOSE.
    
    aux_nmendter = substr(glb_hostname,length(glb_hostname) - 1) +
                          aux_nmendter.

    RUN trata-opcao IN h-b1wgen0091
        ( INPUT glb_cdcooper,
          INPUT 0,           
          INPUT 0,           
          INPUT glb_cdoperad,
          INPUT glb_nmdatela,
          INPUT 1,           
          INPUT tel_nrdconta,
          INPUT 0,           
          INPUT YES,
          INPUT glb_dtmvtolt,
          INPUT tel_nrrecben,
          INPUT tel_nmrecben,
          INPUT tel_nrbenefi,
          INPUT tel_nrnovcta,
          INPUT tel_cdaltera,
          INPUT aux_nmendter,
          INPUT aux_cdaltcad,
         OUTPUT aux_nmarqimp,
         OUTPUT aux_nmarqpdf,
         OUTPUT TABLE tt-erro ).

    IF  RETURN-VALUE <> "OK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
            IF  AVAIL tt-erro  THEN
                DO:
                    MESSAGE tt-erro.dscritic.
                    RETURN "NOK".
                END.
        END.

    RETURN "OK".

END PROCEDURE.


PROCEDURE opcao-02:

    HIDE tel_dsnovmpg IN FRAME f_cadins.
            
    ASSIGN tel_dtatucad:LABEL = "Data da alteracao"
           tel_nrnovcta = 0.
    
    HIDE tel_nmprimtl IN FRAME f_cadins.

    DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:

        UPDATE tel_nrnovcta WITH FRAME f_cadins

        EDITING:
            READKEY.
            APPLY LASTKEY.

            IF  GO-PENDING  THEN
                DO:
                    ASSIGN INPUT tel_nrnovcta.

                    RUN valida-nvconta IN h-b1wgen0091
                        ( INPUT glb_cdcooper, 
                          INPUT 0,            
                          INPUT 0,            
                          INPUT glb_cdoperad, 
                          INPUT glb_nmdatela, 
                          INPUT 1,            
                          INPUT tel_nrdconta, 
                          INPUT 0,            
                          INPUT YES,          
                          INPUT tel_nrnovcta,
                         OUTPUT par_nmdcampo,
                         OUTPUT par_nmprimtl,
                         OUTPUT TABLE tt-erro ).

                    IF  RETURN-VALUE <> "OK" THEN
                        DO:
                            FIND FIRST tt-erro NO-LOCK NO-ERROR.
                            IF  AVAIL tt-erro  THEN
                                DO:
                                    MESSAGE tt-erro.dscritic.
                                    {sistema/generico/includes/foco_campo.i
                                        &NOME-FRAME="f_cadins"
                                        &NOME-CAMPO=par_nmdcampo }
                                END.
                        END.
                END.
        END.

        ASSIGN tel_tpnovmpg = 2
               tel_nmprimtl = par_nmprimtl
               tel_dsnovmpg = "Conta".
        
        DISPLAY tel_nmprimtl
                tel_dsnovmpg
                WITH FRAME f_cadins.

        RUN confirma.

        IF  aux_confirma = "S"  THEN
            DO:
                ASSIGN tel_dtdenvio = ?
                       tel_dtatucad = glb_dtmvtolt.
                               
                DISPLAY tel_dtdenvio
                        tel_dtatucad
                       WITH FRAME f_cadins.
                
                RUN trata-opcao.

                IF  RETURN-VALUE <> "OK" THEN
                    RETURN "NOK".

                RUN imprimir.

                LEAVE.
            END.
        ELSE
            DO:
                ASSIGN  tel_tpnovmpg = 0
                        tel_nrnovcta = 0
                        tel_nmprimtl = "".

                DISPLAY tel_nrnovcta WITH FRAME f_cadins.
                
                HIDE tel_dsnovmpg IN FRAME f_cadins.
                HIDE tel_nmprimtl IN FRAME f_cadins.
                
                LEAVE.
            END.
    END.

    RETURN "OK".
END PROCEDURE.


PROCEDURE opcao-09:

    ASSIGN tel_nrnovcta = 0.
    
    HIDE tel_nmprimtl IN FRAME f_cadins.
    
    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
    
        UPDATE tel_nrnovcta WITH FRAME f_cadins

        EDITING:
            READKEY.
            APPLY LASTKEY.

            IF  GO-PENDING  THEN
                DO:
                    ASSIGN INPUT tel_nrnovcta.

                    RUN valida-nvconta IN h-b1wgen0091
                        ( INPUT glb_cdcooper,     
                          INPUT 0,                
                          INPUT 0,                
                          INPUT glb_cdoperad,     
                          INPUT glb_nmdatela,     
                          INPUT 1,                
                          INPUT tel_nrdconta,     
                          INPUT 0,                
                          INPUT YES,              
                          INPUT tel_nrnovcta,
                         OUTPUT par_nmdcampo,
                         OUTPUT par_nmprimtl,
                         OUTPUT TABLE tt-erro ).

                    IF  RETURN-VALUE <> "OK" THEN
                        DO:
                            FIND FIRST tt-erro NO-LOCK NO-ERROR.
                            IF  AVAIL tt-erro  THEN
                                DO:
                                    MESSAGE tt-erro.dscritic.
                                    {sistema/generico/includes/foco_campo.i
                                        &NOME-FRAME="f_cadins"
                                        &NOME-CAMPO=par_nmdcampo }
                                END.
                        END.
                END.
        END.
                                        
        ASSIGN tel_tpnovmpg = 2
               tel_nmprimtl = par_nmprimtl
               tel_dsnovmpg = "Conta".
        
        DISPLAY tel_nmprimtl
                tel_dsnovmpg
                WITH FRAME f_cadins.
                
        RUN confirma.
                                        
        IF  aux_confirma = "S"   THEN
            DO:
                ASSIGN tel_dtdenvio = ?
                       tel_tpnovmpg = 2
                       tel_dtatucad = glb_dtmvtolt
                       tel_nmprimtl = par_nmprimtl
                       tel_dsnovmpg = "Conta".

                DISPLAY tel_dsnovmpg
                        tel_nmprimtl
                        tel_dtdenvio
                        tel_dtatucad
                        WITH FRAME f_cadins.

                RUN trata-opcao.

                IF  RETURN-VALUE <> "OK" THEN
                    RETURN "NOK".

                RUN imprimir.

                LEAVE.
                                                         
            END.           
        ELSE
            DO:
                ASSIGN  tel_tpnovmpg = 0
                        tel_nrnovcta = 0
                        tel_nmprimtl = "".

                DISPLAY tel_nrnovcta WITH FRAME f_cadins.
                
                HIDE tel_dsnovmpg IN FRAME f_cadins.
                HIDE tel_nmprimtl IN FRAME f_cadins.
                
                LEAVE.
            END.
    END.

    RETURN "OK".

END PROCEDURE.


PROCEDURE imprimir:

    FIND FIRST crapass WHERE  
               crapass.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.

    ASSIGN glb_nmformul = "80col"
           glb_nrdevias = 1
           par_flgrodar = TRUE.

    PAUSE 0.

    { includes/impressao.i }

END PROCEDURE.
                       

/* .......................................................................... */






