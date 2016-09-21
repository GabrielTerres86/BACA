/* .............................................................................

   Programa: Fontes/extemp.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Dezembro/93.                        Ultima atualizacao: 21/01/2015

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela EXTEMP -- Mostrar os lancamentos do contrato de
               emprestimo.

   Alteracoes: 22/06/94 - Alterado para permitir utilizar a taxa do mes na li-
                          quidacao do emprestimo (Edson).

               02/03/95 - Alterado para mostrar o campo craplem.txjurepr no
                          layout da tela (Odair).

               26/06/96 - Alterado para mudar layout mostrando a quantidade
                          calculada de prestacoes (Odair).

               20/11/96 - Alterar a mascara do campo nrctremp (Odair).

               27/03/98 - Tratamento para milenio e troca para V8 (Margarete).
               
               13/11/00 - Alterar nrdolote p/6 posicoes (Margarete/Planner).

             23/03/2003 - Incluir tratamento da Concredi (Margarete).

             26/01/2006 - Unificacao dos Bancos - SQLWorks - Fernando
             
             08/04/2008 - Alterado o formato do campo "crapepr.qtpreemp" de 
                          "z9 " para "zz9" 
                        - Kbase IT Solutions - Paulo Ricardo Maciel. 
                        
             31/10/2008 - Alteracao CDEMPRES (Kbase) - Eduardo Silva.
             
             01/12/2010 - 001 / Alterado Format "x(40)" para Format "x(50)" (Danielle/Kbase)
             
             22/12/2010 - Feito correcao da quebra de linha devido ao campo
                          campo tel_nmprimtl estar grande demais. Alterado o
                          formato de "x(50)" para "x(48)" (Adriano).
                          
             11/04/2011 - Incluido os campos valor do emp., valor da parcela, data do
                          primeiro pagto no cabecalho (Adriano).
                          
             28/07/2011 - Adaptado para uso de BO (Gabriel Capoia - DB1). 
             
             05/10/2011 - Incluida possibilidade de visualizar extrato de
                          emprestimos tipo Price Pre-Fixado, em tela.
                          (GATI - Oliver)
                          
             04/04/2012 - Modificado a chamada da imprime_extrato da b1wgen084
                          para a gera-impextepr b1wgen0112. (Tiago)
                          
             13/08/2013 - Nova forma de chamar as agências, alterado para
                          "Posto de Atendimento" (PA). (André Santos - SUPERO)   
                          
             30/05/2014 - Concatena o numero do servidor no endereco do
                          terminal (Tiago-RKAM).
                          
             31/10/2014 - Alterado a chamada da procedure gera-impextepr para
                          Gera_Impressao (Jean Michel).             
                          
             21/01/2015 - Inclusao do parametro tel_intpextr na chamada da funcao
                          Gera_Impressao para ser usado na pc_gera_impressao_car
                          servindo para indicar o tipo de extrato a ser gerado.
                          (Carlos Rafael Tanholi - Projeto Captacao)                           
                          
............................................................................ */
{ sistema/generico/includes/b1wgen0103tt.i }
{ sistema/generico/includes/b1wgen0002tt.i }
{ sistema/generico/includes/var_internet.i }
{ includes/var_online.i }

DEF        VAR tel_nrdconta AS INT     FORMAT "zzzz,zzz,9"           NO-UNDO.
DEF        VAR tel_nrctremp AS INT     FORMAT "zz,zzz,zz9"           NO-UNDO.
DEF        VAR tel_nmprimtl AS CHAR    FORMAT "x(48)"                NO-UNDO.
DEF        VAR tel_vlsdeved AS DECIMAL FORMAT "zzz,zzz,zz9.99-"      NO-UNDO.
DEF        VAR tel_vljuracu AS DECIMAL FORMAT "zzz,zzz,zz9.99-"      NO-UNDO.
DEF        VAR tel_dshistor AS CHAR    FORMAT "x(13)"                NO-UNDO.
DEF        VAR tel_indebcre AS CHAR    FORMAT "x"                    NO-UNDO.
DEF        VAR tel_qtpresta AS DECIMAL                               NO-UNDO.
DEF        VAR tel_vlemprst AS DECI                                  NO-UNDO.
DEF        VAR tel_vlpreemp AS DECI                                  NO-UNDO.
DEF        VAR tel_dtdpagto AS DATE    FORMAT "99/99/9999"           NO-UNDO.

DEF        VAR tel_dtmvtolt AS DATE    FORMAT "99/99/9999"           NO-UNDO.
DEF        VAR tel_cdagenci AS INTE    FORMAT "zz9"                  NO-UNDO.
DEF        VAR tel_cdbccxlt AS INTE    FORMAT "zz9"                  NO-UNDO.
DEF        VAR tel_nrdolote AS INTE    FORMAT "zzz,zz9"              NO-UNDO.
DEF        VAR tel_nrdocmto AS DECI    FORMAT "zzzzzzz9"             NO-UNDO.
DEF        VAR tel_vllanmto AS DECI    FORMAT "zzzz,zz9.99"          NO-UNDO.
DEF        VAR tel_txjurepr AS DECI DECIMALS 7 FORMAT "z9.999999"    NO-UNDO.

DEF        VAR aux_nrdconta AS INT                                   NO-UNDO.
DEF        VAR aux_nrctremp AS INT                                   NO-UNDO.
DEF        VAR aux_nrctremx AS INT                                   NO-UNDO.
DEF        VAR aux_contador AS INT                                   NO-UNDO.
DEF        VAR aux_flgretor AS LOGICAL                               NO-UNDO.
DEF        VAR aux_cddopcao AS CHAR                                  NO-UNDO.
DEF        VAR h-b1wgen0103 AS HANDLE                                NO-UNDO.
DEF        VAR h-b1wgen0112 AS HANDLE                                NO-UNDO.
DEF        VAR aux_nmendter AS CHAR  FORMAT "x(20)"                  NO-UNDO.
DEF        VAR aux_nmarqimp AS CHAR                                  NO-UNDO.
DEF        VAR aux_nmarqpdf AS CHAR                                  NO-UNDO.
DEF        VAR tel_intpextr AS INT                                   NO-UNDO.
DEF        VAR aux_intpextr AS CHAR                                  NO-UNDO.

FORM SPACE(1)
     WITH ROW 4 OVERLAY 16 DOWN WIDTH 80 TITLE glb_tldatela FRAME f_moldura.

FORM tel_nrdconta AT  1 LABEL "Conta/dv" AUTO-RETURN
                        HELP "Informe o numero da conta ou <F7> para pesquisar"

     tel_nmprimtl AT 22 LABEL "Titular"
     SKIP (1)
     tel_nrctremp AT  1 LABEL "Contrato" AUTO-RETURN
                        HELP "Informe o numero do contrato ou F7 para listar."

     "Saldo Devedor:" AT 22
     tel_vlsdeved     NO-LABEL AT 38
     tel_vljuracu     AT 57 LABEL "Juros"
     SKIP
     tel_vlemprst LABEL "Emprestado" FORMAT "zzz,zzz,zz9.99"
     tel_vlpreemp LABEL "Parcelas"   FORMAT "zzz,zzz,zz9.99"
     tel_dtdpagto     AT 55 LABEL "Data Pagto."
    /*
     SKIP (1)
     "Data    PA  Bcx    Lote Historico   Docto"      AT  4
     "Valor      Taxa  Qtd.Pr."                       AT 55*/
     WITH ROW 6 COLUMN 2 SIDE-LABELS OVERLAY NO-BOX FRAME f_extemp.

FORM 
     "Data    PA  Bcx    Lote Historico   Docto"      AT  4
     "Valor      Taxa  Qtd.Pr."                       AT 55
    WITH ROW 11 COLUMN 2 SIDE-LABELS OVERLAY NO-BOX FRAME f_extemp_2.

FORM tel_dtmvtolt AT  1 FORMAT "99/99/9999"
     tel_cdagenci AT 12 FORMAT "zz9"
     tel_cdbccxlt AT 16 FORMAT "zz9"
     tel_nrdolote AT 20 FORMAT "zzz,zz9"
     tel_dshistor AT 28 FORMAT "x(09)"
     tel_nrdocmto AT 38 FORMAT "zzzzzzz9"
     tel_indebcre AT 47 FORMAT "x(01)"
     tel_vllanmto AT 49 FORMAT "zzzz,zz9.99"
     tel_txjurepr AT 61 FORMAT "z9.999999"
     tel_qtpresta AT 71 FORMAT "zz9.9999"
     WITH ROW 13 COLUMN 2 OVERLAY 8 DOWN NO-LABEL NO-BOX FRAME f_lanctos.

FORM
    tel_intpextr LABEL "Tipo" FORMAT "9"
                 HELP "1 - Simplificado, 2 - Detalhado"
                 VALIDATE(CAN-DO("1,2",tel_intpextr),
                                 "014 - Opcao errada.")
    "  "
    aux_intpextr FORMAT "x(12)"
    WITH SIDE-LABELS ROW 14 COLUMN 25
    OVERLAY NO-LABELS WIDTH 27 FRAME f_tipo_extrato_novo.

VIEW FRAME f_moldura.

PAUSE(0).

RUN fontes/inicia.p.

ASSIGN glb_cddopcao = "C"
       glb_cdcritic = 0.

DO WHILE TRUE:
    
    IF  NOT VALID-HANDLE(h-b1wgen0103) THEN
        RUN sistema/generico/procedures/b1wgen0103.p
            PERSISTENT SET h-b1wgen0103.

    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

        UPDATE tel_nrdconta WITH FRAME f_extemp
        EDITING:
            READKEY.
            IF  FRAME-FIELD = "tel_nrdconta"   AND
                LASTKEY = KEYCODE("F7")        THEN
                DO: 
                    RUN fontes/zoom_associados.p (INPUT  glb_cdcooper,
                                                  OUTPUT aux_nrdconta).
       
                    IF  aux_nrdconta > 0   THEN
                        DO:
                            ASSIGN tel_nrdconta = aux_nrdconta.
                            DISPLAY tel_nrdconta WITH FRAME f_extemp.
                            PAUSE 0.
                            APPLY "RETURN".
                        END.
                END.
            ELSE
                APPLY LASTKEY.

        END.  /*  Fim do EDITING  */

        CLEAR FRAME f_lanctos ALL NO-PAUSE.
        CLEAR FRAME f_extemp ALL NO-PAUSE.

        RUN Busca_Dados.
        
        IF  RETURN-VALUE = "OK"  THEN
            DO:
                CLEAR FRAME f_lanctos ALL NO-PAUSE.
                LEAVE.
            END.

    END.  /*  Fim do DO WHILE TRUE  */

    IF  KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN    /*   F4 OU FIM   */
        DO:
            RUN fontes/novatela.p.
            IF  glb_nmdatela <> "extemp"   THEN
                DO:

                    IF  VALID-HANDLE(h-b1wgen0103) THEN
                        DELETE OBJECT h-b1wgen0103.

                    HIDE FRAME f_extemp.
                    HIDE FRAME f_extemp_2.
                    HIDE FRAME f_lanctos.
                    HIDE FRAME f_moldura.
                    RETURN.
                END.
            ELSE
                NEXT.
        END.

    IF  aux_cddopcao <> glb_cddopcao   THEN
        DO:
            { includes/acesso.i}
            ASSIGN aux_cddopcao = glb_cddopcao.
        END.

    CLEAR FRAME f_lanctos ALL NO-PAUSE.

    Emprestimos: DO WHILE TRUE:
        
        IF  aux_nrctremp = 0 THEN
            DO:
                
                UPDATE tel_nrctremp WITH FRAME f_extemp
                EDITING:
                    
                    READKEY.
                    IF  LASTKEY = KEYCODE("F7")   THEN
                        DO:
                            RUN fontes/zoom_emprestimos.p 
                                ( INPUT glb_cdcooper,
                                  INPUT 0,           
                                  INPUT 0,           
                                  INPUT glb_cdoperad,
                                  INPUT tel_nrdconta,
                                  INPUT glb_dtmvtolt,
                                  INPUT glb_dtmvtopr,
                                  INPUT glb_inproces,
                                 OUTPUT aux_nrctremx ).
               
                            IF  aux_nrctremx > 0   THEN
                                DO:
                                    ASSIGN tel_nrctremp = aux_nrctremx.
                                    DISPLAY tel_nrctremp WITH FRAME f_extemp.
                                    PAUSE 0.
                                    APPLY "RETURN".
                                END.
                        END.
                    ELSE
                        APPLY LASTKEY.

                END.  /*  Fim do EDITING  */

            END.

        FIND FIRST crapepr NO-LOCK WHERE
                   crapepr.cdcooper = glb_cdcooper  AND
                   crapepr.nrdconta = tel_nrdconta  AND
                   crapepr.nrctremp = tel_nrctremp  NO-ERROR.

        IF crapepr.tpemprst = 1 THEN
            DO:
                HIDE FRAME f_extemp_2.
                HIDE FRAME f_lanctos.

                UPDATE tel_intpextr
                    WITH FRAME f_tipo_extrato_novo
                EDITING:
                    DO WHILE TRUE:
                        READKEY.
                        APPLY LASTKEY.

                        CASE INPUT tel_intpextr:
                            WHEN 1 THEN
                                ASSIGN aux_intpextr:SCREEN-VALUE =
                                   "Simplificado".
                            WHEN 2 THEN
                                ASSIGN aux_intpextr:SCREEN-VALUE =
                                       "Detalhado".
                            OTHERWISE
                                ASSIGN aux_intpextr:SCREEN-VALUE =
                                       "".
                        END CASE.
                        LEAVE.
                    END. /* DO WHILE TRUE: */
                END. /* EDITING */

                HIDE FRAME f_tipo_extrato_novo NO-PAUSE.

                INPUT THROUGH basename `tty` NO-ECHO.

                SET aux_nmendter WITH FRAME f_terminal.

                INPUT CLOSE.
                
                aux_nmendter = substr(glb_hostname,length(glb_hostname) - 1) +
                                      aux_nmendter.

                UNIX SILENT VALUE("rm rl/" + aux_nmendter + "* 2> /dev/null").

                RUN sistema/generico/procedures/b1wgen0112.p 
                    PERSISTENT SET h-b1wgen0112.

                RUN Gera_Impressao IN h-b1wgen0112
                  (INPUT glb_cdcooper,
                   INPUT tel_cdagenci,
                   INPUT 0, /* nrdcaixa */
                   INPUT 1, /* idorigem */
                   INPUT glb_nmdatela,
                   INPUT glb_dtmvtolt,
                   INPUT glb_dtmvtopr,
                   INPUT glb_nmdatela,
                   INPUT glb_inproces,
                   INPUT glb_cdoperad,
                   INPUT aux_nmendter, /* dsiduser */
                   INPUT TRUE,
                   INPUT tel_nrdconta,
                   INPUT 1,     /* idseqttl */
                   INPUT 3,     /* par_tpextrat */
    
                   INPUT ?,     /* par_dtrefere */
                   INPUT ?,     /* par_dtreffim */
                   INPUT FALSE, /* par_flgtarif */
                   INPUT 0,     /* par_inrelext */
                   INPUT 1,     /* par_inselext */
                   INPUT tel_nrctremp, /* par_nrctremp */
                   INPUT 0,     /* par_nraplica */
                   INPUT 0,     /* par_nranoref */
                   INPUT FALSE, /* par_flgerlog */
                   INPUT tel_intpextr,                   
                   OUTPUT aux_nmarqimp,
                   OUTPUT aux_nmarqpdf,
                   OUTPUT TABLE tt-erro).

                DELETE PROCEDURE h-b1wgen0112.

                RUN fontes/visrel.p (INPUT aux_nmarqimp).

            END. /* crapepr.tpemprst = 1 */
        ELSE
            DO:
                RUN Busca_Emprestimo.

                IF  RETURN-VALUE <> "OK" THEN
                    DO:
                        IF  aux_nrctremp = 0 THEN
                             NEXT Emprestimos.
                        ELSE LEAVE Emprestimos.
                    END.
                
                ASSIGN aux_flgretor = FALSE
                       aux_contador = 0.
        
                CLEAR FRAME f_lanctos ALL NO-PAUSE.

                DISPLAY WITH FRAME f_extemp_2.
        
                FOR EACH tt-extrato_epr:
        
                    ASSIGN aux_contador = aux_contador + 1.
        
                    IF  aux_contador = 1   THEN
                        IF  aux_flgretor   THEN
                            DO:
                                PAUSE MESSAGE
                                "Tecle <Entra> para continuar ou <Fim> para encerrar".
                                CLEAR FRAME f_lanctos ALL NO-PAUSE.
                            END.
                        ELSE
                            ASSIGN aux_flgretor = TRUE.
                    
                    ASSIGN tel_dtmvtolt = tt-extrato_epr.dtmvtolt
                           tel_nrdolote = tt-extrato_epr.nrdolote
                           tel_indebcre = tt-extrato_epr.indebcre
                           tel_txjurepr = tt-extrato_epr.txjurepr
                           tel_qtpresta = tt-extrato_epr.qtpresta
                           tel_cdagenci = tt-extrato_epr.cdagenci
                           tel_dshistor = tt-extrato_epr.dshistoi
                           tel_vllanmto = tt-extrato_epr.vllanmto
                           tel_cdbccxlt = tt-extrato_epr.cdbccxlt
                           tel_nrdocmto = tt-extrato_epr.nrdocmto.
        
                    DISPLAY tel_dtmvtolt  tel_cdagenci  tel_cdbccxlt
                            tel_nrdolote  tel_dshistor  tel_nrdocmto
                            tel_indebcre  tel_vllanmto
                            tel_txjurepr  WHEN tel_txjurepr > 0
                            tel_qtpresta  WHEN tel_qtpresta > 0
                            WITH FRAME f_lanctos.
        
                    IF  aux_contador = 8   THEN 
                        ASSIGN aux_contador = 0.
                    ELSE
                        DOWN WITH FRAME f_lanctos.  
        
                END. /* FOR EACH tt-extrato_epr */
            END. /* crapepr.tpemprst <> 1 */

        IF  aux_nrctremp <> 0   THEN
            LEAVE Emprestimos.

    END.  /*  Emprestimos  */

END.  /*  Fim do DO WHILE TRUE  */

IF  VALID-HANDLE(h-b1wgen0103) THEN
    DELETE OBJECT h-b1wgen0103.

/* .......................................................................... */

PROCEDURE Busca_Dados:

    EMPTY TEMP-TABLE tt-infoass.
    EMPTY TEMP-TABLE tt-erro.
    
    RUN Busca_Extemp IN h-b1wgen0103
        ( INPUT glb_cdcooper,
          INPUT 0,           
          INPUT 0,           
          INPUT glb_cdoperad,
          INPUT glb_nmdatela,
          INPUT 1,           
          INPUT tel_nrdconta,
          INPUT YES,
         OUTPUT aux_nrctremp,
         OUTPUT TABLE tt-infoass,
         OUTPUT TABLE tt-erro).
    
    FIND FIRST tt-infoass NO-ERROR.

    IF  AVAILABLE tt-infoass THEN
        ASSIGN tel_nrdconta = tt-infoass.nrdconta
               tel_nmprimtl = tt-infoass.nmprimtl
               tel_nrctremp = aux_nrctremp.

    CLEAR FRAME f_extemp NO-PAUSE.
    
    DISPLAY tel_nrdconta tel_nmprimtl tel_nrctremp 
                                        WITH FRAME f_extemp.
    
    IF  RETURN-VALUE <> "OK" OR TEMP-TABLE tt-erro:HAS-RECORDS THEN
        DO:
            FIND FIRST tt-erro NO-ERROR.

            IF  AVAILABLE tt-erro THEN
                MESSAGE tt-erro.dscritic.
                   
            RETURN "NOK".  
        END.
    
    RETURN "OK".

END PROCEDURE. /* Busca_Dados */

PROCEDURE Busca_Emprestimo:

    EMPTY TEMP-TABLE tt-dados-epr.
    EMPTY TEMP-TABLE tt-extrato_epr.
    EMPTY TEMP-TABLE tt-erro.

    DO WITH FRAME f_extemp:
        ASSIGN tel_nrctremp.
    END.
    
    RUN Busca_Emprestimo IN h-b1wgen0103
        ( INPUT glb_cdcooper,
          INPUT 0,
          INPUT 0,
          INPUT glb_cdoperad,
          INPUT glb_cdprogra,
          INPUT glb_inproces,
          INPUT glb_nmdatela,
          INPUT 1,
          INPUT glb_dtmvtolt,
          INPUT glb_dtmvtopr,
          INPUT tel_nrdconta,
          INPUT tel_nrctremp,
          INPUT 1, /*idseqttl*/
          INPUT YES,
         OUTPUT TABLE tt-dados-epr,
         OUTPUT TABLE tt-extrato_epr,
         OUTPUT TABLE tt-erro).
                                    
    IF  RETURN-VALUE <> "OK" OR TEMP-TABLE tt-erro:HAS-RECORDS THEN
        DO:
            CLEAR FRAME f_lanctos ALL NO-PAUSE.    

            FIND FIRST tt-erro NO-ERROR.

            IF  AVAILABLE tt-erro THEN
                MESSAGE tt-erro.dscritic.
            
            RETURN "NOK".  
        END.

    FIND FIRST tt-dados-epr NO-ERROR. 
    
    IF  AVAILABLE tt-dados-epr THEN
        ASSIGN tel_vlsdeved = tt-dados-epr.vlsdeved
               tel_vljuracu = tt-dados-epr.vljuracu
               tel_vlemprst = tt-dados-epr.vlemprst
               tel_vlpreemp = tt-dados-epr.vlpreemp
               tel_dtdpagto = tt-dados-epr.dtpripgt.

    DISPLAY tel_nrctremp tel_vlsdeved tel_vljuracu tel_vlemprst
            tel_vlpreemp tel_dtdpagto WITH FRAME f_extemp.
    
    RETURN "OK".

END PROCEDURE. /* Busca_Emprestimo */
/* ......................................................................... */
