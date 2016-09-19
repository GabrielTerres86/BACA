/* .............................................................................

   Programa: Fontes/extrat.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Setembro/91.                        Ultima atualizacao: 30/05/2014

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela EXTRAT.

   Alteracoes: 03/11/94 - Alterado para criar variavel com os historicos refe-
                          rentes a cheques. (Deborah).

               06/05/96 - Alterado para mostrar o nome do segundo titular
                          (Edson).

               24/01/97 - Alterado para tratar o historico 191 da mesma forma
                          que o 47 (Deborah).

               22/01/99 - Tratar historico 313 (Odair).

               24/06/99 - Tratar historico 338,340 (Odair)

               02/08/99 - Alterado para ler a lista de historicos de uma tabela
                          (Edson).

             13/10/2000 - Inserir o campo PAC (cdagenci) na consulta (Eduardo)
             
             13/11/2000 - Alterar nrdolote p/6 posicoes (Margarete/Planner).

             04/01/2001 - Mostrar o periodo de apuracao do CPMF no lugar do
                          numero do documento. (Eduardo).
                          
             31/01/2005 - Modificados os termos "Agencia" ou "Ag" por "PAC"
                          (Evandro)
                                       
             21/06/2005 - Possibilitar pesquisa com mais de 2 meses(Mirtes).

             23/01/2006 - Unificacao dos bancos - SQLWorks - Luciane.

             15/07/2008 - Reestruturacao da tela - BO's(Guilherme).
             
             16/01/2009 - Alteracao cdempres (Diego).
             
             24/06/2010 - Nao compor o saldo com os depositos TAA (Evandro).
             
             27/07/2011 - Adaptado para uso de BO (Gabriel Capoia - DB1).
             
             28/09/2011 - Incluido campo de informacoes do TAA (Gabriel).
             
             31/07/2013 - Implementada opcao A da tela EXTRAT (Lucas).
             
             17/09/2013 - Incluida dentro da opcao A a opcao de imprimir
                         junto do extrato no arquivo os depositos de cheque
                         tambem (Tiago).
             
             12/11/2013 - Nova forma de chamar as agências, de PAC agora 
                          a escrita será PA (Guilherme Gielow)    
                          
             30/05/2014 - Concatena o numero do servidor no endereco do
                          terminal (Tiago-RKAM).
             
............................................................................. */
{ sistema/generico/includes/b1wgen0103tt.i }
{ sistema/generico/includes/b1wgen0001tt.i }
{ sistema/generico/includes/var_internet.i }
{ includes/var_online.i }

DEF        STREAM str_1.
DEF        VAR tel_nrdconta AS INT     FORMAT "zzzz,zzz,9"           NO-UNDO.
DEF        VAR tel_nmprimtl AS CHAR    FORMAT "x(30)"                NO-UNDO.
DEF        VAR tel_dtinimov AS DATE    FORMAT "99/99/9999"           NO-UNDO.
DEF        VAR tel_dtfimmov AS DATE    FORMAT "99/99/9999"           NO-UNDO.
DEF        VAR tel_cdagenc1 AS INT     FORMAT "zz9"                  NO-UNDO.
DEF        VAR tel_vllimcre AS DECI    FORMAT "zzz,zzz,zzz,zz9.99"   NO-UNDO.
DEF        VAR tel_dshistor AS CHAR                                  NO-UNDO.
DEF        VAR tel_nmdireto AS CHAR                                  NO-UNDO.
DEF        VAR tel_nmarquiv AS CHAR                                  NO-UNDO.
DEF        VAR tel_listachq AS LOGICAL FORMAT "S/N" INITIAL FALSE    NO-UNDO.
DEF        VAR aux_nmarqimp AS CHAR                                  NO-UNDO.

DEF        VAR aux_vllanmto AS CHAR                                  NO-UNDO.
DEF        VAR aux_vlsdtota AS CHAR                                  NO-UNDO.
DEF        VAR aux_cddopcao AS CHAR                                  NO-UNDO.
DEF        VAR aux_nrdconta AS INTE  FORMAT "zzzz,zzz,9"             NO-UNDO.
DEF        VAR aux_dshistor AS CHAR                                  NO-UNDO.
DEF        VAR aux_nmendter AS CHAR                                  NO-UNDO.
DEF        VAR aux_qtregist AS INTE                                  NO-UNDO.
DEF        VAR aux_flgfirst AS LOGICAL                               NO-UNDO.


DEF        VAR h-b1wgen0103 AS HANDLE                                NO-UNDO.
DEF        VAR h-b1wgen0001 AS HANDLE                                NO-UNDO.

DEF QUERY q_extrato FOR tt-extrato_conta.

DEF BROWSE b_extrato QUERY q_extrato DISPLAY
           tt-extrato_conta.dtmvtolt LABEL "Data"      FORMAT "99/99/9999"
           aux_dshistor              LABEL "Historico" FORMAT "x(18)"
           tt-extrato_conta.nrdocmto LABEL "Documento" FORMAT "x(12)"
           tt-extrato_conta.indebcre LABEL "D/C"       FORMAT " x "
           aux_vllanmto LABEL "Valor"                  FORMAT "x(12)"
           aux_vlsdtota LABEL "Saldo"                  FORMAT "x(14)"
           WITH 7 DOWN NO-BOX NO-LABEL.

FORM SPACE(1)
     WITH ROW 4 OVERLAY 16 DOWN WIDTH 80 TITLE glb_tldatela FRAME f_moldura.

FORM glb_cddopcao AT  2 LABEL "Opcao" FORMAT "!(1)"
                        HELP "Informe a opcao (A,T)."
                        VALIDATE (CAN-DO("A,T",glb_cddopcao), "014 - Opcao Errada")
     tel_nrdconta AT 16 LABEL "Conta/dv" AUTO-RETURN
                        HELP "Informe o numero da conta ou <F7> para pesquisar"
     tel_dtinimov AT 46 LABEL "Periodo" AUTO-RETURN
                        HELP "Entre com a data do movimento."
     "a"
     tel_dtfimmov AT 68 NO-LABEL  AUTO-RETURN
                        HELP "Entre com a data do movimento."
     SKIP
     tel_nmprimtl AT  2 LABEL "Tit."
     tel_vllimcre AT 38 LABEL " Limt.Cred." FORMAT "zzz,zzz,zz9.99"  
     tel_cdagenc1 AT 70 LABEL "PA"
     WITH SIDE-LABELS ROW 6 COLUMN 2 OVERLAY NO-BOX FRAME f_extrat.

FORM 
     "---------------------------------- Extrato ----------------------" AT 02
     SPACE(0)
     "-----------"
     SKIP
     b_extrato
     HELP "Utilize as setas para navegar ou pressione <F4> para voltar"
     SKIP
     "----------------------------------------------------------------" AT 03
     SPACE(0)
     "----------"
     SKIP
     tel_dshistor AT 03 LABEL "Historico" FORMAT "x(27)"
     tt-extrato_conta.dtliblan AT 57 LABEL "Dt.Libera" FORMAT  "x(9)"
     SKIP
     tt-extrato_conta.cdcoptfn AT 03 LABEL "COOP"      FORMAT "zz9"    
     tt-extrato_conta.cdagenci AT 14 LABEL "PA"         
     tt-extrato_conta.cdbccxlt AT 24 LABEL "Banco/Caixa"
     tt-extrato_conta.nrdolote AT 42 LABEL "Lote"        
     tt-extrato_conta.dsidenti AT 63 NO-LABEL          FORMAT "x(14)" 
     WITH ROW 8 CENTERED SIDE-LABELS OVERLAY WIDTH 78 NO-BOX FRAME f_extrato.

FORM "Listar cheques?" AT 12
     tel_listachq      AT 30
     HELP "(S)im/ (N)ao"
     SKIP(1)
     "Diretorio:" AT 12 
     tel_nmdireto AT 26 NO-LABEL                 FORMAT "x(21)"
     tel_nmarquiv       NO-LABEL                 FORMAT "x(20)"
                        HELP "Informe o nome do arquivo"
     WITH NO-LABEL SIDE-LABELS COLUMN 2 ROW 11 OVERLAY NO-BOX FRAME f_saida.


/* Quando entra e muda a posicao do registro do lancamento */
ON ENTRY, VALUE-CHANGED OF b_extrato DO:
   
    IF  AVAIL tt-extrato_conta   THEN
        DO:
            ASSIGN tel_dshistor =
                     (IF  tt-extrato_conta.cdhistor > 0  THEN
                          STRING(tt-extrato_conta.cdhistor,"9999") + " - "
                      ELSE
                          "") + tt-extrato_conta.dshistor.
                
            DISPLAY tel_dshistor
                    tt-extrato_conta.dsidenti  
                    tt-extrato_conta.dtliblan 
                    tt-extrato_conta.cdcoptfn
                    tt-extrato_conta.cdagenci
                    tt-extrato_conta.cdbccxlt
                    tt-extrato_conta.nrdolote
                    WITH FRAME f_extrato.   
        END.
END.

ON ROW-DISPLAY OF b_extrato IN FRAME f_extrato DO:

    ASSIGN aux_dshistor = IF  tt-extrato_conta.nrsequen = 0  THEN
                              tt-extrato_conta.dshistor
                          ELSE
                              STRING(tt-extrato_conta.cdhistor,"9999") + "-" + 
                              tt-extrato_conta.dshistor
        
           aux_vllanmto = IF  tt-extrato_conta.nrsequen = 0  THEN
                              "            "
                          ELSE
                              STRING(tt-extrato_conta.vllanmto,
                                     "zzzzz,zz9.99")

           aux_vlsdtota = IF  tt-extrato_conta.vlsdtota = 0  AND 
                              tt-extrato_conta.nrsequen > 0  THEN 
                              "               "
                          ELSE
                              STRING(tt-extrato_conta.vlsdtota,
                                     "zzzzzz,zz9.99-").

    ASSIGN aux_vllanmto:SCREEN-VALUE IN BROWSE b_extrato = aux_vllanmto 
           aux_vlsdtota:SCREEN-VALUE IN BROWSE b_extrato = aux_vlsdtota.
    
END.

VIEW FRAME f_moldura.

PAUSE(0).

RUN fontes/inicia.p.

ASSIGN glb_cddopcao = "T"
       glb_cdcritic = 0.

INICIO:
DO WHILE TRUE:

    HIDE FRAME f_saida.
    
    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
        
        UPDATE glb_cddopcao WITH FRAME f_extrat.
        LEAVE.
    
    END.

    HIDE MESSAGE NO-PAUSE.

    IF  KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN    /*   F4 OU FIM   */
        DO:
            RUN fontes/novatela.p.
            IF  glb_nmdatela <> "EXTRAT"   THEN
                DO:
                    IF  VALID-HANDLE(h-b1wgen0103) THEN
                        DELETE OBJECT h-b1wgen0103.

                    HIDE FRAME f_extrat.
                    HIDE FRAME f_moldura.
                    RETURN.
                END.
            ELSE
                NEXT.
        END.

    IF  aux_cddopcao <> glb_cddopcao   THEN
        DO:
            { includes/acesso.i }
            ASSIGN aux_cddopcao = glb_cddopcao.
        END.

    HIDE MESSAGE NO-PAUSE.

    PAUSE 0.

    IF  NOT VALID-HANDLE(h-b1wgen0103) THEN
        RUN sistema/generico/procedures/b1wgen0103.p
            PERSISTENT SET h-b1wgen0103.
        
    DO WHILE TRUE ON ENDKEY UNDO, NEXT INICIO:

        UPDATE tel_nrdconta tel_dtinimov tel_dtfimmov WITH FRAME f_extrat
        
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
                            DISPLAY tel_nrdconta WITH FRAME f_extrat.
                            PAUSE 0.
                            APPLY "RETURN".
                        END.
                END.
            ELSE
                APPLY LASTKEY.
            
        END.  /*  Fim do EDITING  */

        IF  glb_cddopcao = "A" THEN
            DO:

                FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper 
                                          NO-LOCK NO-ERROR NO-WAIT.
    
                ASSIGN tel_nmdireto = "/micros/" + crapcop.dsdircop + "/"
                       tel_nmarquiv = "".
                
                DISPLAY tel_listachq 
                        tel_nmdireto WITH FRAME f_saida.
                
                DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                    UPDATE tel_listachq tel_nmarquiv 
                           WITH FRAME f_saida.
                    LEAVE.
                
                END. /** Fim do DO WHILE TRUE **/
                
                IF  tel_nmarquiv = "" THEN
                    NEXT INICIO.                
            END.

        RUN Busca_Dados.

        IF  RETURN-VALUE <> "OK" THEN
            NEXT.

        LEAVE.

    END. /*  Fim do DO WHILE TRUE  */  

    IF  glb_cddopcao = "T" THEN
        DO:
            HIDE MESSAGE NO-PAUSE.

            OPEN QUERY q_extrato FOR EACH tt-extrato_conta NO-LOCK.
            
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
            
                UPDATE b_extrato WITH FRAME f_extrato.
                LEAVE.
            
            END. /** Fim do DO WHILE TRUE **/
            
            HIDE FRAME f_extrato.
            
            IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
                 NEXT INICIO.
        END.
END.    

IF  VALID-HANDLE(h-b1wgen0103) THEN
    DELETE OBJECT h-b1wgen0103.

/* ......................................................................... */

PROCEDURE Busca_Dados:

    DEF VAR aux_terminal AS CHAR FORMAT "x(20)"                     NO-UNDO.
    DEF VAR aux_qtregist AS INTE                                    NO-UNDO.
    DEF VAR aux_cdopcchq AS CHAR                                    NO-UNDO.


    INPUT THROUGH basename `tty` NO-ECHO.

        SET aux_terminal WITH FRAME f_lista.
            
    INPUT CLOSE.
    
    aux_nmendter = substr(glb_hostname,length(glb_hostname) - 1) +
                          aux_nmendter.

    EMPTY TEMP-TABLE tt-extrat.
    EMPTY TEMP-TABLE tt-extrato_conta.
    EMPTY TEMP-TABLE tt-erro.

    MESSAGE "Aguarde, listando extrato...".
    
    IF  tel_listachq = TRUE THEN
        aux_cdopcchq = "AC".
    ELSE
        aux_cdopcchq = glb_cddopcao.

    RUN Busca_Extrato IN h-b1wgen0103
        ( INPUT glb_cdcooper,
          INPUT 0,
          INPUT 0,
          INPUT glb_cdoperad,
          INPUT glb_nmoperad,
          INPUT glb_nmdatela,
          INPUT aux_cdopcchq,
          INPUT 1,
          INPUT glb_dtmvtolt,
          INPUT glb_dsdepart,
          INPUT tel_nrdconta,
          INPUT tel_dtinimov,
          INPUT tel_dtfimmov,
          INPUT aux_terminal,
          INPUT 0,
          INPUT 0,
          INPUT tel_nmarquiv,
          INPUT YES,
         OUTPUT aux_qtregist,
         OUTPUT tel_dtinimov,
         OUTPUT tel_dtfimmov,
         OUTPUT TABLE tt-extrat,
         OUTPUT TABLE tt-extrato_conta,
         OUTPUT TABLE tt-erro).

    FIND FIRST tt-extrat NO-ERROR.
    
    IF  AVAILABLE tt-extrat THEN
       ASSIGN tel_nmprimtl = tt-extrat.nmprimtl
              tel_vllimcre = tt-extrat.vllimcre
              tel_cdagenc1 = tt-extrat.cdagenci.
   
    DISPLAY tel_nmprimtl tel_vllimcre 
            tel_cdagenc1 tel_dtinimov
            tel_dtfimmov
            WITH FRAME f_extrat.

    IF  glb_cddopcao = "A" THEN
        MESSAGE "Arquivo gerado com sucesso.".
    
    IF  RETURN-VALUE <> "OK" OR TEMP-TABLE tt-erro:HAS-RECORDS THEN
        DO:
            HIDE MESSAGE NO-PAUSE.

            FIND FIRST tt-erro NO-ERROR.

            IF  AVAILABLE tt-erro THEN
                MESSAGE tt-erro.dscritic.
                   
            RETURN "NOK".  
        END.
    
    RETURN "OK".

END PROCEDURE. /* Busca_Dados */
