/* .............................................................................

   Programa: Fontes/extrda.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Odair
   Data    : Dezembro/94.                    Ultima atualizacao: 13/08/2013

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela EXTRDA -- Mostrar os lancamentos do contrato de
               aplicacao.

   Alteracoes: 11/10/95 - Alterado para incluir historicos 143 e 144 na lista
                          (Deborah).

               17/10/95 - Alterado para mostrar o literal "Dispon." (Deborah).

               26/11/96 - Tratar RDCAII (Odair).

               27/03/98 - Tratamento para milenio e troca para V8 (Margarete).

               13/11/00 - Alterar nrdolote p/6 posicoes (Margarete/Planner).
               
               09/12/2003 - Incluir histor IRRF (Margarete).

               08/01/2004 - Aumentar tabela de numero de aplicacoes (Margarete).
             
               27/01/2004 - Incluir histor de abono e IR de abono (Margarete).

               22/09/2004 - Incluidos historicos 492/493/494/495(CI)(Mirtes).
             
               13/12/2004 - Incluido campo Saldo p/Resgate.
                            Incluidos historicos  875/876/877(Mirtes/Magui)
                          
               31/01/2005 - Modificados os termos "Agencia" ou "Ag" por "PAC"
                            (Evandro).
               
               23/01/2006 - Unificacao dos Bancos - SQLWorks - Andre
               
               15/05/2007 - Adequacao para a aplicacao RDCPRE e RDCPOS(Evandro).

               27/11/2007 - Usar txaplmes quando RDCA30 (Magui).

               06/02/2008 - Aumentar tamanho do array "rda_nraplica" (David).
               
               31/03/2008 - Incluir campo craprda.vlpvtrgt no extrato quando
                            for aplicacao RDCPOS (David).
               
               10/04/2008 - Incluido campos Prazo e Carencia na consulta das
                            aplicacoes (Elton)
                             
               13/05/2008 - Ajuste comando FIND(craphis) utilizava FOR p/ acesso
                            (Sidnei - Precise)
                            
               15/08/2008 - Alterado campo 'Carencia' para 'Qt.Uteis' quando 
                            RDCPRE (Gabriel).
                            
               20/05/2009 - Alteracao CDOPERAD (Kbase).
               
               17/06/2010 - Inclusão do campo Ope.Apl para mostrar o código do
                            operador (Adriano).
                            
               27/10/2010 - Alteracao para buscar o operador na craprda e caso 
                            nao encontre utilizar o operador da craplot. 
                            (Henrique).
                            
               10/11/2010 - Incluir campos Taxa Minima e Taxa Contratada para
                            aplicacoes RDCPOS (Henrique).
                            
               17/12/2010 - Incluir his 923 e 924, sobreposicao (Magui).
               
               02/06/2011 - Estanciado a b1wgen0004 para o inicio do programa
                            e deletado ao final para ganho de performance
                            (Adriano).
                            
               01/08/2011 - Adaptado para uso de BO (Gabriel Capoia - DB1).
               
               13/08/2013 - Nova forma de chamar as agências, alterado para
                          "Posto de Atendimento" (PA). (André Santos - SUPERO)
               
............................................................................. */
{ sistema/generico/includes/b1wgen0103tt.i }
{ sistema/generico/includes/b1wgen0081tt.i }
{ sistema/generico/includes/b1wgen0004tt.i }
{ sistema/generico/includes/var_internet.i }
{ includes/var_online.i }

DEF        VAR tel_nrdconta AS INT     FORMAT "zzzz,zzz,9"           NO-UNDO.
DEF        VAR tel_nraplica AS INT     FORMAT "zzz,zz9"              NO-UNDO.
DEF        VAR tel_nmprimtl AS CHAR    FORMAT "x(40)"                NO-UNDO.
DEF        VAR tel_vlsdrdca AS DECIMAL FORMAT "zzz,zzz,zz9.99-"      NO-UNDO.
DEF        VAR tel_vlsdrdad AS DECIMAL FORMAT "zzz,zzz,zz9.99-"      NO-UNDO.
DEF        VAR tel_vlsdresg AS DECIMAL FORMAT "zzz,zzz,zz9.99-"      NO-UNDO.
DEF        VAR tel_dsdispon AS CHAR    FORMAT "x(07)"                NO-UNDO.
DEF        VAR tel_dshistor AS CHAR    FORMAT "x(13)"                NO-UNDO.
DEF        VAR tel_indebcre AS CHAR    FORMAT "x"                    NO-UNDO.
DEF        VAR tel_dsaplica AS CHAR    FORMAT "x(06)"                NO-UNDO.
DEF        VAR tel_qtdiaapl AS INT     FORMAT "zzz9"                 NO-UNDO.
DEF        VAR tel_qtdiauti AS INT     FORMAT "zzz9"                 NO-UNDO.
DEF        VAR tel_txminima AS DECI    FORMAT "zz9.99"               NO-UNDO.
DEF        VAR tel_txcntrat AS DECI    FORMAT "zz9.99"               NO-UNDO.
DEF        VAR tel_cdoperad LIKE craplot.cdoperad                    NO-UNDO. 

DEF        VAR tel_dtmvtolt AS DATE    FORMAT "99/99/9999"           NO-UNDO.
DEF        VAR tel_cdagenci AS INTE    FORMAT "zz9"                  NO-UNDO.
DEF        VAR tel_nrdocmto AS INTE    FORMAT "zz,zzz,zz9"           NO-UNDO.
DEF        VAR tel_vllanmto AS DECI    FORMAT "zzz,zzz,zzz,zz9.99-"  NO-UNDO.
DEF        VAR tel_txaplica AS DECI    FORMAT "zz9.999999"           NO-UNDO.
DEF        VAR tel_vlpvlrgt AS CHAR    FORMAT "x(12)"                NO-UNDO.

DEF        VAR aux_nraplica AS INT                                   NO-UNDO.
DEF        VAR aux_contador AS INT                                   NO-UNDO.
DEF        VAR aux_flgretor AS LOGICAL                               NO-UNDO.
DEF        VAR aux_tpaplrdc AS LOGICAL                               NO-UNDO.
DEF        VAR aux_cddopcao AS CHAR                                  NO-UNDO.

DEF        VAR aux_nrdconta AS INT                                   NO-UNDO.
DEF        VAR aux_nraplicx AS INT                                   NO-UNDO.
DEF        VAR h-b1wgen0103 AS HANDLE                                NO-UNDO.

FORM SPACE(1)
     WITH ROW 4 OVERLAY 16 DOWN WIDTH 80 TITLE glb_tldatela FRAME f_moldura.

FORM tel_nrdconta AT  3 LABEL "Conta/dv" AUTO-RETURN
                        HELP "Informe o numero da conta ou <F7> para pesquisar"

     tel_nmprimtl AT 24 LABEL "Titular"
     SKIP
     tel_nraplica AT  2 LABEL "Aplic" AUTO-RETURN
                  HELP "Informe o numero da aplicacao ou Tecle F7 para listar."

     tel_dsaplica AT 17 NO-LABEL
     tel_vlsdrdad AT 24 LABEL "Saldo dia"
     tel_vlsdrdca AT 51 LABEL "d+1" 
     tel_dsdispon AT 72 NO-LABEL
     tel_cdoperad AT 2  LABEL "Ope.Apl"
     tel_vlsdresg AT 21 LABEL "Saldo p/Resg."
     tel_qtdiaapl AT 51 LABEL "Prazo"       
     tel_qtdiauti AT 63 LABEL "Carencia" 
     SKIP
     tel_txcntrat AT  2 LABEL "Taxa Contratada"
     tel_txminima AT 30 LABEL "Taxa Minima"
     SKIP
     "Data    PA  Historico      Documento"   AT  4
     "         Valor       Taxa   Vl.Pvl.Rgt"               
     WITH ROW 6 COLUMN 2 SIDE-LABELS OVERLAY NO-BOX FRAME f_extrda.
    
FORM tel_dtmvtolt AT  1 FORMAT "99/99/9999"
     tel_cdagenci AT 12
     tel_dshistor     
     tel_nrdocmto 
     tel_indebcre     
     tel_vllanmto FORMAT "zzzzz,zz9.99"
     tel_txaplica 
     tel_vlpvlrgt
     WITH ROW 12 COLUMN 2 OVERLAY 9 DOWN NO-LABEL NO-BOX FRAME f_lanctos.

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
     
        UPDATE tel_nrdconta WITH FRAME f_extrda
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
                            DISPLAY tel_nrdconta WITH FRAME f_extrda.
                            PAUSE 0.
                            APPLY "RETURN".
                        END.
                END.
            ELSE
                APPLY LASTKEY.

        END.  /*  Fim do EDITING  */

        RUN Busca_Dados.
        
        IF  RETURN-VALUE = "OK" THEN
            DO:
                CLEAR FRAME f_lanctos ALL NO-PAUSE.
                LEAVE.
            END.

    END.  /*  Fim do DO WHILE TRUE  */

    IF  KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN    /*   F4 OU FIM   */
        DO:
            RUN fontes/novatela.p.
            IF  glb_nmdatela <> "extrda"   THEN
                DO:
                    IF  VALID-HANDLE(h-b1wgen0103) THEN
                        DELETE OBJECT h-b1wgen0103.

                    HIDE FRAME f_extrda.
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

    Extrato: DO WHILE TRUE ON ERROR UNDO:

        IF  aux_nraplica = 0 THEN
            DO:
                
                UPDATE tel_nraplica WITH FRAME f_extrda
                EDITING:
                    
                    READKEY.
                    IF  LASTKEY = KEYCODE("F7")   THEN
                        DO:

                            RUN fontes/zoom_aplicacoes.p 
                                ( INPUT glb_cdcooper,
                                  INPUT 0,           
                                  INPUT 0,           
                                  INPUT glb_cdoperad,
                                  INPUT glb_cdprogra,
                                  INPUT tel_nrdconta,
                                 OUTPUT aux_nraplicx ).
               
                            IF  aux_nraplicx > 0   THEN
                                DO:
                                    ASSIGN tel_nraplica = aux_nraplicx.
                                    DISPLAY tel_nraplica WITH FRAME f_extrda.
                                    PAUSE 0.
                                    APPLY "RETURN".
                                END.

                        END.
                    ELSE
                        APPLY LASTKEY.

                END.  /*  Fim do EDITING  */

            END.

        RUN Busca_Aplicacoes.

        IF  RETURN-VALUE <> "OK" THEN
            DO:
                IF  aux_nraplica = 0 THEN
                     NEXT Extrato.
                ELSE LEAVE Extrato.
            END.

        ASSIGN aux_flgretor = FALSE
               aux_contador = 0.

        CLEAR FRAME f_lanctos ALL NO-PAUSE.

        FOR EACH tt-extr-rdca:

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

            ASSIGN tel_dtmvtolt = tt-extr-rdca.dtmvtolt
                   tel_cdagenci = tt-extr-rdca.cdagenci
                   tel_dshistor = tt-extr-rdca.dshistor
                   tel_nrdocmto = tt-extr-rdca.nrdocmto
                   tel_indebcre = tt-extr-rdca.indebcre
                   tel_vllanmto = tt-extr-rdca.vllanmto
                   tel_txaplica = tt-extr-rdca.txaplica 
                   tel_vlpvlrgt = tt-extr-rdca.vlpvlrgt.


            DISPLAY tel_dtmvtolt tel_cdagenci tel_dshistor tel_nrdocmto
                    tel_indebcre tel_vllanmto 
                    tel_txaplica WHEN tel_txaplica > 0
                    tel_vlpvlrgt
                    WITH FRAME f_lanctos.

            IF  aux_contador = 9   THEN 
                ASSIGN aux_contador = 0.
            ELSE
                DOWN WITH FRAME f_lanctos.

        END. /* FOR EACH tt-extr-rdca */

        IF  aux_nraplica <> 0   THEN
            LEAVE Extrato.
    
    END. /* Extrato */

END.  /*  Fim do DO WHILE TRUE  */

IF  VALID-HANDLE(h-b1wgen0103) THEN
    DELETE OBJECT h-b1wgen0103.
/* ......................................................................... */

PROCEDURE Busca_Dados:

    EMPTY TEMP-TABLE tt-infoass.
    EMPTY TEMP-TABLE tt-erro.
    
    RUN Busca_Extrda IN h-b1wgen0103
        ( INPUT glb_cdcooper,
          INPUT 0,           
          INPUT 0,           
          INPUT glb_cdoperad,
          INPUT glb_nmdatela,
          INPUT 1,           
          INPUT tel_nrdconta,
          INPUT YES,
         OUTPUT aux_nraplica,
         OUTPUT TABLE tt-infoass,
         OUTPUT TABLE tt-erro).
    
    FIND FIRST tt-infoass NO-ERROR.

    IF  AVAILABLE tt-infoass THEN
        ASSIGN tel_nrdconta = tt-infoass.nrdconta
               tel_nmprimtl = tt-infoass.nmprimtl
               tel_nraplica = aux_nraplica.

    CLEAR FRAME f_extrda NO-PAUSE.
    
    DISPLAY tel_nrdconta tel_nmprimtl tel_nraplica 
                                        WITH FRAME f_extrda.
    
    IF  RETURN-VALUE <> "OK" OR TEMP-TABLE tt-erro:HAS-RECORDS THEN
        DO:
            FIND FIRST tt-erro NO-ERROR.

            IF  AVAILABLE tt-erro THEN
                MESSAGE tt-erro.dscritic.
                   
            RETURN "NOK".  
        END.
    
    RETURN "OK".

END PROCEDURE. /* Busca_Dados */

PROCEDURE Busca_Aplicacoes:

    EMPTY TEMP-TABLE tt-saldo-rdca.
    EMPTY TEMP-TABLE tt-extr-rdca.
    EMPTY TEMP-TABLE tt-erro.

    DO WITH FRAME f_extrda:
        ASSIGN tel_nraplica.
    END.

    ASSIGN tel_dsaplica = ""
           tel_vlsdrdad = 0
           tel_vlsdrdca = 0
           tel_dsdispon = ""
           tel_cdoperad = ""
           tel_vlsdresg = 0
           tel_qtdiaapl = 0
           tel_qtdiauti = 0
           tel_txcntrat = 0
           tel_txminima = 0
           aux_tpaplrdc = FALSE.
    
    RUN Busca_Aplicacoes IN h-b1wgen0103
        ( INPUT glb_cdcooper,
          INPUT 0,
          INPUT 0,
          INPUT glb_cdoperad,
          INPUT glb_cdprogra,
          INPUT glb_nmdatela,
          INPUT 1,
          INPUT glb_dtmvtolt,
          INPUT tel_nrdconta,
          INPUT tel_nraplica,
          INPUT 1, /*idseqttl*/
          INPUT YES,
         OUTPUT TABLE tt-saldo-rdca,
         OUTPUT TABLE tt-extr-rdca,
         OUTPUT TABLE tt-erro).

    FIND FIRST tt-saldo-rdca NO-ERROR.

    IF  AVAIL tt-saldo-rdca THEN
        DO:
            ASSIGN tel_dsaplica = tt-saldo-rdca.dsaplica
                   tel_vlsdrdad = tt-saldo-rdca.vlsdrdad
                   tel_vlsdrdca = tt-saldo-rdca.vllanmto
                   tel_dsdispon = tt-saldo-rdca.indebcre
                   tel_cdoperad = tt-saldo-rdca.cdoperad
                   tel_vlsdresg = tt-saldo-rdca.sldresga
                   tel_qtdiaapl = tt-saldo-rdca.qtdiaapl
                   tel_qtdiauti = tt-saldo-rdca.qtdiauti
                   tel_txcntrat = TRUNCATE(DECI(tt-saldo-rdca.txaplmax),2) 
                   tel_txminima = TRUNCATE(DECI(tt-saldo-rdca.txaplmin),2)
                   aux_tpaplrdc = IF   tt-saldo-rdca.tpaplrdc = 0 THEN
                                       FALSE
                                  ELSE TRUE.
            
            IF  tt-saldo-rdca.tpaplica = 7 THEN 
                tel_qtdiauti:LABEL = "Qt.Uteis". 
            ELSE
                tel_qtdiauti:LABEL = "Carencia".
            

        END.
    
    /* Mostra a data de vencimento no lugar do D+1 */
    IF  aux_tpaplrdc THEN
        DISPLAY tt-saldo-rdca.dtvencto @ tel_vlsdrdca WITH FRAME f_extrda.


    DISPLAY tel_vlsdrdad tel_dsaplica tel_vlsdrdca WHEN NOT aux_tpaplrdc
            tel_dsdispon tel_vlsdresg
            tel_qtdiaapl tel_qtdiauti tel_txminima tel_txcntrat tel_cdoperad
            WITH FRAME f_extrda.
    
    IF  RETURN-VALUE <> "OK" OR TEMP-TABLE tt-erro:HAS-RECORDS THEN
        DO:
            CLEAR FRAME f_lanctos ALL NO-PAUSE.    

            FIND FIRST tt-erro NO-ERROR.

            IF  AVAILABLE tt-erro THEN
                MESSAGE tt-erro.dscritic.
            
            RETURN "NOK".  
        END.
    
    RETURN "OK".

END PROCEDURE. /* Busca_Aplicacoes */

/* ......................................................................... */
