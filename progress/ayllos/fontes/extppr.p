/* .............................................................................
   
   Programa: Fontes/extppr.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Odair/Edson
   Data    : Abril/96.                       Ultima atualizacao: 05/08/2014

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela EXTPPR -- Mostrar os lancamentos da poupanca
               programada.

   Alteracoes: 27/03/1998 - Tratamento para milenio e troca para V8 (Margarete).

               13/11/2000 - Alterar nrdolote p/6 posicoes (Margarete/Planner).
               
               08/12/2003 - Incluido histor IRRF (Margarete).

               28/01/2004 - Incluir histor de abono da cpmf (Margarete).

               22/09/2004 - Incluido historico 496(CI)(Mirtes)
               
               23/01/2006 - Unificacao dos Bancos - SQLWorks - Andre

               24/04/2008 - Incluido campo Data de vencimento (Gabriel).
               
               24/07/2008 - Incluido campos "Data Inicial" e "Data Final" e
                            incluido na listagem o saldo anterior do extrato
                            com valor do saldo proveniente da BO b1wgen0006
                            (Elton).
               
               06/01/2009 - Mostra somente os lancamentos em que a data for
                            maior do que a data inicial informada (Elton).
                            
               20/05/2009 - Alteracao CDOPERAD (Kbase).
               
               16/12/2010 - Incluir his 925, sobreposicao Pa's (Magui).
               
               26/07/2011 - Adaptado para uso de BO (Gabriel Capoia - DB1).
               
               03/06/2013 - Busca Saldo Bloqueio Judicial 
                           (Andre Santos - SUPERO)
               
               05/08/2014 - Alteração da Nomeclatura para PA (Vanessa).
............................................................................. */

{ sistema/generico/includes/b1wgen0103tt.i }
{ sistema/generico/includes/b1wgen0006tt.i }
{ sistema/generico/includes/var_internet.i }
{ includes/var_online.i }

{ includes/aplrda.i "NEW" }

DEF        VAR tel_nrdconta AS INT     FORMAT "zzzz,zzz,9"           NO-UNDO.
DEF        VAR tel_nraplica AS INT     FORMAT "z,zzz,zz9"            NO-UNDO.
DEF        VAR tel_dddebito AS INT     FORMAT "99"                   NO-UNDO.
DEF        VAR tel_nmprimtl AS CHAR    FORMAT "x(26)"                NO-UNDO.
DEF        VAR tel_vlrdcapp AS DECIMAL FORMAT "-zz,zzz,zz9.99"       NO-UNDO.
DEF        VAR tel_dshistor AS CHAR    FORMAT "x(13)"                NO-UNDO.
DEF        VAR tel_indebcre AS CHAR    FORMAT "x"                    NO-UNDO.
DEF        VAR tel_dtvctopp AS DATE    FORMAT "99/99/9999"           NO-UNDO.

DEF        VAR tel_dtmvtolt AS DATE FORMAT "99/99/9999"              NO-UNDO.
DEF        VAR tel_cdagenci AS INTE FORMAT "zz9"                     NO-UNDO.
DEF        VAR tel_cdbccxlt AS INTE FORMAT "zz9"                     NO-UNDO.
DEF        VAR tel_nrdolote AS INTE FORMAT "zzz,zz9"                 NO-UNDO.
DEF        VAR tel_nrdocmto AS INTE FORMAT "zzz,zzz,zz9"             NO-UNDO.
DEF        VAR tel_vllanmto AS DECI FORMAT "zzz,zz9.99"              NO-UNDO.
DEF        VAR tel_txaplica AS DECI DECIMALS 6 FORMAT "zz9.999999"   NO-UNDO.
DEF        VAR tel_dtiniper AS DATE   FORMAT "99/99/9999"            NO-UNDO.
DEF        VAR tel_dtfimper AS DATE   FORMAT "99/99/9999"            NO-UNDO.

DEF        VAR aux_flgfirst AS LOGICAL                               NO-UNDO.
DEF        VAR aux_contador AS INT                                   NO-UNDO.
DEF        VAR aux_flgretor AS LOGICAL                               NO-UNDO.

DEF        VAR aux_cddopcao AS CHAR                                  NO-UNDO.

DEF        VAR aux_nrdconta AS INTE  FORMAT "zzzz,zzz,9"             NO-UNDO.
DEF        VAR aux_nrctrrpp AS INTE                                  NO-UNDO.
DEF        VAR aux_nrctrrpa AS INTE                                  NO-UNDO.
DEF        VAR h-b1wgen0103 AS HANDLE                                NO-UNDO.

DEF        VAR tel_vlblqjud AS DECI  FORMAT "zzz,zzz,zz9.99"         NO-UNDO.
DEF        VAR aux_vlblqjud AS DECI  FORMAT "zzz,zzz,zz9.99"         NO-UNDO.
DEF        VAR aux_vlresblq AS DECI                                  NO-UNDO.

DEF        VAR h-b1wgen0155 AS HANDLE                                NO-UNDO.


FORM SPACE(1)
     WITH ROW 4 OVERLAY 16 DOWN WIDTH 80 TITLE glb_tldatela FRAME f_moldura.

FORM tel_nrdconta AT  3 LABEL "Conta/dv" AUTO-RETURN
                        HELP "Informe o numero da conta ou <F7> para pesquisar"

     tel_nmprimtl AT 24 LABEL "Titular"
     
     tel_nraplica AT 60 LABEL "Contrato" AUTO-RETURN
         HELP "Informe o numero da poupanca programada ou Tecle F7 paralistar."
     SKIP                                   
     tel_dtvctopp AT 03 LABEL "Data de Vcto"
     tel_dddebito AT 28 LABEL "Dia do Debito"
     tel_vlblqjud AT 49 LABEL "Saldo Bloq Jud"
     SKIP
     tel_dtiniper AT 03 LABEL "Data Inicial"
     HELP "Informe a data inicial do extrato."
     tel_dtfimper AT 28 LABEL "Data Final"
     tel_vlrdcapp AT 52 LABEL "Saldo Atual"
     HELP "Informe a data final do extrato."
     SKIP(1)
     "Data      PA Bcx   Lote Historico"  AT  5
     "Documento        Valor       Taxa"   AT 45      
     WITH ROW 6 COLUMN 2 SIDE-LABELS OVERLAY NO-BOX  FRAME f_extppr.

FORM tel_dtmvtolt AT 2
     tel_cdagenci AT 13
     tel_cdbccxlt AT 17
     tel_nrdolote AT 22
     tel_dshistor     
     tel_nrdocmto
     tel_indebcre     
     tel_vllanmto
     tel_txaplica
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

        UPDATE tel_nrdconta WITH FRAME f_extppr
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
                            DISPLAY tel_nrdconta WITH FRAME f_extppr.
                            PAUSE 0.
                            APPLY "RETURN".
                        END.
                END.
            ELSE
                APPLY LASTKEY.

        END.  /*  Fim do EDITING  */

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
            IF  glb_nmdatela <> "extppr"   THEN
                DO:
                    IF  VALID-HANDLE(h-b1wgen0103) THEN
                        DELETE OBJECT h-b1wgen0103.

                    HIDE FRAME f_extppr.
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
            aux_cddopcao = glb_cddopcao.
        END.

    TRANS_POUP:

    DO WHILE TRUE ON ERROR UNDO:

        IF  aux_nrctrrpp = 0 THEN
            DO:
                
                UPDATE tel_nraplica WITH FRAME f_extppr
                EDITING:
                    
                    READKEY.
                    IF  LASTKEY = KEYCODE("F7")   THEN
                        DO:
                            RUN fontes/zoom_poupanca.p 
                                ( INPUT glb_cdcooper,
                                  INPUT 0,
                                  INPUT 0,
                                  INPUT glb_cdoperad,
                                  INPUT glb_nmdatela,
                                  INPUT 1,
                                  INPUT tel_nrdconta,
                                  INPUT 1, /*idseqttl*/
                                  INPUT glb_dtmvtolt,
                                  INPUT glb_dtmvtopr,
                                  INPUT glb_inproces,
                                  INPUT glb_cdprogra,
                                 OUTPUT aux_nrctrrpa ).
               
                            IF  aux_nrctrrpa > 0   THEN
                                DO:
                                    ASSIGN tel_nraplica = aux_nrctrrpa.
                                    DISPLAY tel_nraplica WITH FRAME f_extppr.
                                    PAUSE 0.
                                    APPLY "RETURN".
                                END.
                        END.
                    ELSE
                        APPLY LASTKEY.

                END.  /*  Fim do EDITING  */

            END.

        RUN Busca_Poupanca.

        IF  RETURN-VALUE <> "OK" THEN
            DO:
                IF  aux_nrctrrpp = 0 THEN
                     NEXT TRANS_POUP.
                ELSE LEAVE TRANS_POUP.
            END.
        
        CLEAR FRAME f_lanctos ALL NO-PAUSE.

        DO WHILE TRUE ON ERROR UNDO:

            UPDATE tel_dtiniper tel_dtfimper WITH FRAME f_extppr.
    
            RUN Busca_Lancamentos.

            IF  RETURN-VALUE <> "OK" THEN
                NEXT.

            LEAVE.

        END.

        ASSIGN aux_contador = 0
               aux_flgretor = TRUE
               aux_flgfirst = TRUE.
        
        FOR EACH tt-extr-rpp :

            ASSIGN aux_contador = aux_contador + 1.
          
            IF   aux_contador = 1 AND NOT aux_flgfirst THEN
                 IF   aux_flgretor   THEN
                      DO:      
                          PAUSE MESSAGE
                            "Tecle <Entra> para continuar ou <Fim> para encerrar".
                          CLEAR FRAME f_lanctos ALL NO-PAUSE.
                      END.
                 ELSE
                      aux_flgretor = TRUE.
          
            ASSIGN tel_dtmvtolt = tt-extr-rpp.dtmvtolt
                   tel_cdagenci = tt-extr-rpp.cdagenci
                   tel_cdbccxlt = tt-extr-rpp.cdbccxlt
                   tel_nrdolote = tt-extr-rpp.nrdolote
                   tel_dshistor = tt-extr-rpp.dshistor
                   tel_nrdocmto = tt-extr-rpp.nrdocmto
                   tel_indebcre = tt-extr-rpp.indebcre
                   tel_vllanmto = tt-extr-rpp.vllanmto
                   tel_txaplica = tt-extr-rpp.txaplica.
            
            DISPLAY tel_dtmvtolt
                    tel_cdagenci WHEN (NOT aux_flgfirst)
                    tel_cdbccxlt WHEN (NOT aux_flgfirst)
                    tel_nrdolote WHEN (NOT aux_flgfirst)
                    tel_dshistor 
                    tel_nrdocmto WHEN (NOT aux_flgfirst)
                    tel_indebcre WHEN (NOT aux_flgfirst)
                    tel_vllanmto
                    tel_txaplica WHEN ( tel_txaplica > 0 AND NOT aux_flgfirst )
                    WITH FRAME f_lanctos.
          
            IF   aux_contador = 9   THEN
                 aux_contador = 0.
            ELSE
                 DOWN WITH FRAME f_lanctos.

            ASSIGN aux_flgfirst = FALSE.
                                        
        END.  /*  Fim do FOR EACH  --  Leitura dos lancamentos do contrato  */

        IF  aux_nrctrrpp > 0   THEN
            LEAVE.

    END.  /*  Fim do DO WHILE TRUE  */

END. /*  Fim do DO WHILE TRUE  */

IF  VALID-HANDLE(h-b1wgen0103) THEN
    DELETE OBJECT h-b1wgen0103.

/* ......................................................................... */

PROCEDURE Busca_Dados:

    EMPTY TEMP-TABLE tt-infoass.
    EMPTY TEMP-TABLE tt-erro.
    
    RUN Busca_Extppr IN h-b1wgen0103
        ( INPUT glb_cdcooper,
          INPUT 0,           
          INPUT 0,           
          INPUT glb_cdoperad,
          INPUT glb_nmdatela,
          INPUT 1,           
          INPUT tel_nrdconta,
          INPUT YES,
         OUTPUT aux_nrctrrpp,
         OUTPUT TABLE tt-infoass,
         OUTPUT TABLE tt-erro).
    
    FIND FIRST tt-infoass NO-ERROR.

    IF  AVAILABLE tt-infoass THEN
        ASSIGN tel_nrdconta = tt-infoass.nrdconta
               tel_nmprimtl = tt-infoass.nmprimtl
               tel_nraplica = aux_nrctrrpp
               tel_vlrdcapp = 0
               tel_dddebito = 0.

    CLEAR FRAME f_extppr NO-PAUSE.

    DISPLAY tel_nrdconta tel_nmprimtl tel_vlrdcapp tel_dddebito tel_nraplica
                                                           WITH FRAME f_extppr.
    
    IF  RETURN-VALUE <> "OK" OR TEMP-TABLE tt-erro:HAS-RECORDS THEN
        DO:
            FIND FIRST tt-erro NO-ERROR.

            IF  AVAILABLE tt-erro THEN
                MESSAGE tt-erro.dscritic.
                   
            RETURN "NOK".  
        END.
    
    RETURN "OK".

END PROCEDURE. /* Busca_Dados */

PROCEDURE Busca_Poupanca:

    EMPTY TEMP-TABLE tt-poupanca.
    EMPTY TEMP-TABLE tt-erro.

    DO WITH FRAME f_extppr:
        ASSIGN tel_nraplica.
    END.
    
    RUN Busca_Poupanca IN h-b1wgen0103
        ( INPUT glb_cdcooper,
          INPUT 0,
          INPUT 0,
          INPUT glb_cdoperad,
          INPUT glb_nmdatela,
          INPUT 1,
          INPUT glb_dtmvtolt,
          INPUT glb_dtmvtopr,
          INPUT glb_inproces,
          INPUT glb_cdprogra,
          INPUT tel_nrdconta,
          INPUT 1, /*idseqttl*/
          INPUT tel_nraplica,
          INPUT YES,
         OUTPUT TABLE tt-poupanca,   
         OUTPUT TABLE tt-erro).     
                                    
    FIND FIRST tt-poupanca NO-ERROR. 
                                    
    IF  AVAILABLE tt-poupanca THEN   
        ASSIGN tel_nraplica = tt-poupanca.nrctrrpp
               tel_vlrdcapp = tt-poupanca.vlrdcapp
               tel_dddebito = tt-poupanca.dddebito
               tel_dtvctopp = tt-poupanca.dtvctopp
               tel_dtiniper = tt-poupanca.dtiniper
               tel_dtfimper = tt-poupanca.dtfimper.

    /*** Busca Saldo Bloqueado Judicial ***/
    ASSIGN aux_vlblqjud = 0
           aux_vlresblq = 0.
    
    RUN sistema/generico/procedures/b1wgen0155.p 
                   PERSISTENT SET h-b1wgen0155.

    RUN retorna-valor-blqjud IN h-b1wgen0155(INPUT glb_cdcooper,
                                             INPUT tel_nrdconta,
                                             INPUT 0, /* fixo - nrcpfcgc */
                                             INPUT 1, /* Bloqueio        */
                                             INPUT 3, /* 3-Poup.Prog     */
                                             INPUT glb_dtmvtolt,
                                             OUTPUT aux_vlblqjud,
                                             OUTPUT aux_vlresblq).

    tel_vlblqjud = aux_vlblqjud.

    DELETE PROCEDURE h-b1wgen0155.
    /*** Fim Busca Saldo Bloqueado Judicial ***/
    
    DISPLAY tel_nraplica tel_vlblqjud
            tel_dddebito tel_dtvctopp
            tel_vlrdcapp WITH FRAME f_extppr.
    
    IF  RETURN-VALUE <> "OK" OR TEMP-TABLE tt-erro:HAS-RECORDS THEN
        DO:
            FIND FIRST tt-erro NO-ERROR.

            IF  AVAILABLE tt-erro THEN
                MESSAGE tt-erro.dscritic.
                   
            RETURN "NOK".  
        END.
    
    RETURN "OK".

END PROCEDURE. /* Busca_Poupanca */

PROCEDURE Busca_Lancamentos:

    EMPTY TEMP-TABLE tt-extr-rpp.
    EMPTY TEMP-TABLE tt-erro.
    
    DO WITH FRAME f_extppr:
        ASSIGN tel_nraplica
               tel_dtiniper
               tel_dtfimper.
    END.
    
    RUN Busca_Lancamentos IN h-b1wgen0103
        ( INPUT glb_cdcooper,
          INPUT 0,
          INPUT 0,
          INPUT glb_cdoperad,
          INPUT glb_nmdatela,
          INPUT 1,
          INPUT tel_nrdconta,
          INPUT 1, /*idseqttl*/
          INPUT tel_nraplica,
          INPUT tel_dtiniper,
          INPUT tel_dtfimper,
          INPUT YES,
         OUTPUT TABLE tt-extr-rpp,   
         OUTPUT TABLE tt-erro).
    
    IF  RETURN-VALUE <> "OK" OR TEMP-TABLE tt-erro:HAS-RECORDS THEN
        DO:
            FIND FIRST tt-erro NO-ERROR.

            IF  AVAILABLE tt-erro THEN
                MESSAGE tt-erro.dscritic.
                   
            RETURN "NOK".  
        END.
    
    RETURN "OK".

END PROCEDURE. /* Busca_Lancamentos */

/* .......................................................................... */
