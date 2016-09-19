/*.............................................................................
   
   Programa: Fontes/bcaixa.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Margarete/Planner
   Data    : Fevereiro/2001.                  Ultima atualizacao: 12/03/2015

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela BCAIXA.

   Alteracoes: 10/12/2004 - Verificar Pendencias COBAN antes do Fechamento
                            (Mirtes).
                            
               24/02/2005 - Nao permitir data menor que o 1o dia do mes
                            anterior a data atual (Evandro).
                            
               01/07/2005 - Mudado a data de restricao para 01/04/05 (Evandro).
                            
               20/07/2007 - Nao permitir opcoes diferentes de "C" ou "S" para o
                            caixa da internet, pac 90, caixa 900, operador 996
                            (Evandro).
                            
               14/07/2009 - Alteracao CDOPERAD (Diego).
               
               14/06/2010 - Tratamento para PAC 91 - TAA (Elton).
               
               15/04/2011 - Desenvolvimento da opcao T - Consulta de saldo na 
                            tela (GATI - Diego)
               
               31/10/2011 - Adaptado para uso de BO (Gabriel Capoia - DB1).
             
               23/04/2013 - Incluir ajustes referentes ao Projeto Sangria de
                            Caixa, incluido combo box na opcao T e incluir
                            rotina de impressao para opcao T (Lucas R.)

               30/08/2013 - Criado o campo dtrefere para a opcao T.
                            Mostrar o campo da data apenas quando o tipo for 
                            CAIXA (Carlos)
                            
               24/09/2013 - Incluido  parametro dtrefere na procedure
                            imprime_caixa_cofre (Carlos)
                            
               29/05/2014 - Concatena o numero do servidor no endereco do
                            terminal (Andrino-RKAM)
               
               12/03/2015 - Incluir novo tipo tpcaicof = "TOTAL" 
                            (Lucas R. #245838 )
.............................................................................*/

DEF STREAM str_1.

DEF VAR p-autchave   AS INTE    NO-UNDO.
DEF VAR p-cdchave    AS CHAR    NO-UNDO.
DEF VAR h-b1crap80   AS HANDLE  NO-UNDO.

/* variaveis para impressao */
DEF VAR aux_nmendter    AS CHAR FORMAT "x(20)"                         NO-UNDO.
DEF VAR par_flgrodar    AS LOGI INIT TRUE                              NO-UNDO.
DEF VAR aux_flgescra    AS LOGI                                        NO-UNDO.
DEF VAR aux_dscomand    AS CHAR                                        NO-UNDO.
DEF VAR par_flgfirst    AS LOGI INIT TRUE                              NO-UNDO.
DEF VAR tel_dsimprim    AS CHAR FORMAT "x(8)" INIT "Imprimir"          NO-UNDO.
DEF VAR tel_dscancel    AS CHAR FORMAT "x(8)" INIT "Cancelar"          NO-UNDO.
DEF VAR par_flgcance    AS LOGI                                        NO-UNDO.
DEF VAR aux_contador    AS INT                                         NO-UNDO.

{ includes/var_online.i }
{ sistema/generico/includes/b1wgen0096tt.i }
{ sistema/generico/includes/var_internet.i }
{ includes/var_bcaixa.i "NEW"}

DEF VAR aux_msgsenha AS CHAR                                        NO-UNDO.
DEF VAR aux_nmdcampo AS CHAR                                        NO-UNDO.
DEF VAR aux_msgretor AS CHAR                                        NO-UNDO.
DEF VAR aux_nrdrecid AS RECID                                       NO-UNDO.
DEF VAR aux_nrdlacre AS INTE                                        NO-UNDO.
DEF VAR aux_indcompl AS INTE                                        NO-UNDO.
DEF VAR aux_cdoplanc AS CHAR                                        NO-UNDO.
DEF VAR aux_dsdcompl AS CHAR                                        NO-UNDO.
DEF VAR aux_vldocmto AS DECI                                        NO-UNDO.
DEF VAR aux_tpcaicof AS CHAR                                        NO-UNDO.
DEF VAR aux_nmarqpdf AS CHAR                                        NO-UNDO.
DEF VAR aux_confirm1 AS CHAR FORMAT "!"                             NO-UNDO.

FORM "Aguarde... Gerando Boletim!"
     WITH ROW 14 CENTERED OVERLAY ATTR-SPACE FRAME f_aguarde.

FORM SKIP(1)
     "ATENCAO!   Ligue a impressora e posicione o papel!" AT 3
     SKIP(1)
     tel_dsimprim AT 14
     tel_dscancel AT 29
     SKIP(1)
     WITH ROW 14 COLUMN 14 OVERLAY NO-LABELS WIDTH 56
          TITLE glb_nmformul FRAME f_atencao.

ASSIGN glb_cdprogra    = "bcaixa"
       glb_flgbatch    = FALSE
       par_flgrodar    = TRUE.


ON TAB OF tel_tpcaicof 
DO:
    APPLY "RETURN".
END.
ON RETURN OF tel_tpcaicof DO:
    /* Mostrar data apenas quando o tipo for CAIXA e TOTAL*/
    IF tel_tpcaicof:SCREEN-VALUE = "COFRE" THEN
        ASSIGN tel_dtrefere:SENSITIVE IN FRAME f_caicof = NO
               tel_dtrefere:HIDDEN    IN FRAME f_caicof = YES.
    ELSE
        ASSIGN tel_dtrefere:SENSITIVE IN FRAME f_caicof = YES
               tel_dtrefere:HIDDEN    IN FRAME f_caicof = NO.

    APPLY "TAB".
END.

RUN fontes/inicia.p.

ON  'VALUE-CHANGED':U OF glb_cddopcao IN FRAME f_opcao 
    DO:
        ASSIGN INPUT FRAME f_opcao glb_cddopcao.

        HIDE MESSAGE NO-PAUSE.

        IF  glb_cddopcao = "T" THEN
            DO:
                ASSIGN tel_dtmvtolt:SENSITIVE IN FRAME f_opcao = NO
                       tel_nrdcaixa:SENSITIVE IN FRAME f_opcao = NO
                       tel_cdopecxa:SENSITIVE IN FRAME f_opcao = NO
                       tel_cdagenci:SENSITIVE IN FRAME f_opcao = NO
                       tel_dtmvtolt:HIDDEN    IN FRAME f_opcao = YES
                       tel_nrdcaixa:HIDDEN    IN FRAME f_opcao = YES
                       tel_cdopecxa:HIDDEN    IN FRAME f_opcao = YES
                       tel_cdagenci:HIDDEN    IN FRAME f_opcao = YES.
                       tel_tpcaicof = "CAIXA".
                APPLY "entry" TO tel_cdagenci IN FRAME f_opcao.
            END.
        ELSE 
            DO:
                ASSIGN tel_dtmvtolt:SENSITIVE IN FRAME f_opcao = YES
                       tel_nrdcaixa:SENSITIVE IN FRAME f_opcao = YES
                       tel_cdopecxa:SENSITIVE IN FRAME f_opcao = YES
                       tel_dtmvtolt:HIDDEN    IN FRAME f_opcao = NO
                       tel_nrdcaixa:HIDDEN    IN FRAME f_opcao = NO
                       tel_cdopecxa:HIDDEN    IN FRAME f_opcao = NO.
                APPLY "entry" TO tel_dtmvtolt IN FRAME f_opcao.
            END.
    END. /* ON   'VALUE-CHANGED':U OF glb_cddopcao */

VIEW FRAME f_moldura.
PAUSE(0).
VIEW FRAME f_bcaixa.

RUN fontes/inicia.p.

ASSIGN glb_cddopcao = "I"
       tel_dtmvtolt = glb_dtmvtolt
       tel_cdagenci = glb_cdagenci
       tel_cdopecxa = glb_cdoperad
       glb_cdcritic = 0.

PAUSE(0).

DISPLAY glb_cddopcao tel_dtmvtolt tel_cdagenci tel_nrdcaixa tel_cdopecxa
        WITH FRAME f_opcao.

CLEAR FRAME f_bcaixa ALL.
HIDE MESSAGE NO-PAUSE.

DO WHILE TRUE:

    HIDE FRAME f_boletim NO-PAUSE.
    HIDE FRAME f_bcaixa.

    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

       UPDATE glb_cddopcao tel_dtmvtolt tel_cdagenci tel_nrdcaixa 
              tel_cdopecxa WITH FRAME f_opcao KEEP-TAB-ORDER.

        HIDE MESSAGE NO-PAUSE.

        IF  NOT CAN-DO("L,K,T",glb_cddopcao) THEN
            DO:
                RUN Busca_Dados.
                
                IF  RETURN-VALUE <> "OK" THEN
                    NEXT.
            END.
        
        LEAVE.

    END.  /*  Fim do DO WHILE TRUE  */

    IF  KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
        DO:
            VIEW FRAME f_moldura.
            PAUSE(0).
            VIEW FRAME f_opcao.
            RUN fontes/novatela.p.
            IF  CAPS(glb_nmdatela) <> "BCAIXA" THEN
                DO:
                    IF  VALID-HANDLE(h-b1wgen0120)  THEN
                        DELETE PROCEDURE h-b1wgen0120.
                    
                    HIDE FRAME f_moldura.
                    HIDE FRAME f_opcao.
                    HIDE FRAME f_bcaixa.
                    HIDE FRAME f_boletim.
                    HIDE FRAME f_lancamentos.
                    HIDE FRAME f_moldura_extra.
                    HIDE FRAME f_moldura_especial.
                    HIDE FRAME f_extra.
                    HIDE FRAME fra_boletim.
                    HIDE FRAME f_caicof.
                    RETURN.
                 END.
            ELSE
                DO:
                    ASSIGN glb_cdcritic = 0.
                    NEXT.
                END.
        END.

    IF  aux_cddopcao <> glb_cddopcao THEN
        DO:
            { includes/acesso.i }      
            ASSIGN aux_cddopcao = glb_cddopcao.   
        END.

    ASSIGN aux_flgretor = TRUE.

    CASE glb_cddopcao:
        WHEN "C" THEN
            DO WHILE TRUE ON ENDKEY UNDO,LEAVE:
                { includes/bcaixac.i }
                LEAVE.
            END.
        WHEN "F" THEN
            DO:
                ASSIGN aux_flgfecha = NO.
                { includes/bcaixaf.i }
            END.
        WHEN "I" THEN
            DO:
                ASSIGN tel_nrdmaqui = 0
                       tel_vldsdini = 0.
                { includes/bcaixai.i }
            END.
        WHEN "K" THEN
            DO:
                { includes/bcaixak.i }
            END.
        WHEN "L" THEN
            DO:
                { includes/bcaixal.i }
            END.
        WHEN "S" THEN
            DO:
                { includes/bcaixas.i }
            END.
        WHEN "T" THEN
            DO: 
                ASSIGN tel_cddopcao = glb_cddopcao
                       tel_dtrefere = glb_dtmvtolt.

                UPDATE tel_cddopcao tel_tpcaicof tel_cdagenci tel_dtrefere
                       WITH FRAME f_caicof.

                IF  tel_tpcaicof:SCREEN-VALUE = "CAIXA" THEN
                    ASSIGN aux_tpcaicof = "CAIXA".
                ELSE IF  tel_tpcaicof:SCREEN-VALUE = "TOTAL" THEN
                    ASSIGN aux_tpcaicof = "TOTAL".
                ELSE
                    ASSIGN aux_tpcaicof = "COFRE".

                RUN Busca_Dados.

                IF  RETURN-VALUE <> "OK" THEN
                    DO:
                        ASSIGN glb_cddopcao = "I".
                        NEXT.
                    END.
                
                { includes/bcaixat.i } 

                ASSIGN glb_cddopcao = "I".    
                           
                CLEAR FRAME f_caicof.

                IF  NOT VALID-HANDLE(h-b1wgen0120) THEN 
                    RUN sistema/generico/procedures/b1wgen0120.p
                        PERSISTENT SET h-b1wgen0120. 


                INPUT THROUGH basename `tty` NO-ECHO.
                SET aux_nmendter WITH FRAME f_terminal.
                INPUT CLOSE. 

                aux_nmendter = substr(glb_hostname,length(glb_hostname) - 1) +
                               aux_nmendter.

                ASSIGN aux_confirm1 = "N".

                RUN fontes/confirma.p (INPUT "Confirma Impressao de "
                                           + "relatorio? (SIM/NAO)",
                                       OUTPUT aux_confirm1).
                
                IF aux_confirm1 <> "S" THEN 
                   NEXT.

                MESSAGE "Aguarde Imprimindo...".
                
                RUN imprime_caixa_cofre IN h-b1wgen0120
                                       (INPUT glb_cdcooper,
                                        INPUT glb_dtmvtolt,
                                        INPUT 1,
                                        INPUT tel_cdagenci,
                                        INPUT tel_dtrefere,
                                        INPUT glb_cdoperad,
                                        INPUT glb_cdprogra,
                                        INPUT aux_nmendter,
                                        INPUT aux_tpcaicof,
                                        OUTPUT aux_nmarqimp,
                                        OUTPUT aux_nmarqpdf,
                                        OUTPUT TABLE tt-msg-confirma).

                IF  VALID-HANDLE(h-b1wgen0120) THEN
                    DELETE PROCEDURE h-b1wgen0120.

                HIDE MESSAGE NO-PAUSE.

                RUN impressao.
            
            END.
      END CASE.
            
END.

IF  VALID-HANDLE(h-b1wgen0120)  THEN
    DELETE PROCEDURE h-b1wgen0120.

PROCEDURE Busca_Dados:

    EMPTY TEMP-TABLE tt-boletimcx.
    EMPTY TEMP-TABLE tt-lanctos.
    EMPTY TEMP-TABLE tt_crapbcx.
    EMPTY TEMP-TABLE tt-erro.

    ASSIGN aux_msgretor = "".

    INPUT THROUGH basename `tty` NO-ECHO.
    SET aux_nmendter WITH FRAME f_terminal.
    INPUT CLOSE.

    aux_nmendter = substr(glb_hostname,length(glb_hostname) - 1) +
                          aux_nmendter.

    IF  NOT VALID-HANDLE(h-b1wgen0120) THEN 
        RUN sistema/generico/procedures/b1wgen0120.p
            PERSISTENT SET h-b1wgen0120.

    RUN Busca_Dados IN h-b1wgen0120
        ( INPUT glb_cdcooper,
          INPUT 0,
          INPUT 0,
          INPUT glb_cdoperad,
          INPUT glb_cdprogra,
          INPUT 1, /* idorigem */
          INPUT glb_dtmvtolt,
          INPUT glb_dtmvtopr,
          INPUT glb_nmdatela,
          INPUT aux_nmendter,
          INPUT glb_cddopcao,
          INPUT tel_cdopecxa,
          INPUT tel_dtmvtolt,
          INPUT tel_cdagenci,
          INPUT tel_nrdcaixa,
          INPUT tel_dtrefere,
          INPUT aux_cdoplanc,
          INPUT TRUE, /* flgerlog */
          INPUT aux_tpcaicof,
         OUTPUT aux_msgsenha,
         OUTPUT aux_msgretor,
         OUTPUT aux_flgsemhi,
         OUTPUT tot_saldot,
         OUTPUT TABLE tt-boletimcx,
         OUTPUT TABLE tt-lanctos,
         OUTPUT TABLE tt_crapbcx,
         OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE <> "OK" OR TEMP-TABLE tt-erro:HAS-RECORDS THEN
        DO:
            FIND FIRST tt-erro NO-ERROR.

            IF  AVAILABLE tt-erro THEN
                MESSAGE tt-erro.dscritic.
                   
            RETURN "NOK".  
        END.

    RETURN "OK".

END PROCEDURE. /* Busca_Dados */

PROCEDURE Gera_Boletim:

    DEF VAR aux_nmarqpdf AS CHAR NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.

    INPUT THROUGH basename `tty` NO-ECHO.
    SET aux_nmendter WITH FRAME f_terminal.
    INPUT CLOSE.

    aux_nmendter = substr(glb_hostname,length(glb_hostname) - 1) +
                          aux_nmendter.

    IF  NOT VALID-HANDLE(h-b1wgen0120) THEN 
        RUN sistema/generico/procedures/b1wgen0120.p
            PERSISTENT SET h-b1wgen0120.

    RUN Gera_Boletim IN h-b1wgen0120
        ( INPUT glb_cdcooper,
          INPUT 0,
          INPUT 0,
          INPUT 1, /* idorigem */
          INPUT glb_nmdatela,
          INPUT glb_dtmvtolt,       
          INPUT aux_nmendter,
          INPUT aux_tipconsu,
          INPUT aux_recidbol,
         OUTPUT aux_flgsemhi,
         OUTPUT aux_vldsdfin,
         OUTPUT aux_vlrttcrd,
         OUTPUT aux_vlrttdeb,
         OUTPUT aux_nmarqimp,
         OUTPUT aux_nmarqpdf,
         OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE <> "OK" OR TEMP-TABLE tt-erro:HAS-RECORDS THEN
        DO:
            FIND FIRST tt-erro NO-ERROR.

            IF  AVAILABLE tt-erro THEN
                MESSAGE tt-erro.dscritic.
                   
            RETURN "NOK".  
        END.

    IF  NOT aux_tipconsu   THEN
        DO:
            /*** nao necessario ao programa somente para nao dar erro 
                          de compilacao na rotina de impressao ****/
            FIND FIRST crapass WHERE crapass.cdcooper = glb_cdcooper 
                                                     NO-LOCK NO-ERROR.

            { includes/impressao.i }

            HIDE MESSAGE NO-PAUSE.
        END.

    RETURN "OK".

END PROCEDURE. /* Gera_Boletim */

PROCEDURE Gera_Termo:

    DEF VAR aux_nmarqpdf AS CHAR NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.

    INPUT THROUGH basename `tty` NO-ECHO.
    SET aux_nmendter WITH FRAME f_terminal.
    INPUT CLOSE.

    aux_nmendter = substr(glb_hostname,length(glb_hostname) - 1) +
                          aux_nmendter.

    IF  NOT VALID-HANDLE(h-b1wgen0120) THEN   
        RUN sistema/generico/procedures/b1wgen0120.p
            PERSISTENT SET h-b1wgen0120.

    RUN Gera_Termo IN h-b1wgen0120
        ( INPUT glb_cdcooper,
          INPUT 0,
          INPUT 0,
          INPUT 1, /* idorigem */   
          INPUT glb_dtmvtolt,
          INPUT glb_cddopcao,
          INPUT aux_nmendter,
          INPUT aux_recidbol,
          INPUT ant_nrdlacre,
         OUTPUT aux_nmarqimp,
         OUTPUT aux_nmarqpdf,
         OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE <> "OK" OR TEMP-TABLE tt-erro:HAS-RECORDS THEN
        DO:
            FIND FIRST tt-erro NO-ERROR.

            IF  AVAILABLE tt-erro THEN
                MESSAGE tt-erro.dscritic.
                   
            RETURN "NOK".  
        END.

    /*** nao necessario ao programa somente para nao dar erro 
                          de compilacao na rotina de impressao ****/
    FIND FIRST crapass WHERE crapass.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.

    { includes/impressao.i }

    HIDE MESSAGE NO-PAUSE.
    
    RETURN "OK".

END PROCEDURE. /* Gera_Termo */

PROCEDURE Gera_Fita_Caixa:

    DEF VAR aux_nmarqpdf AS CHAR NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.

    INPUT THROUGH basename `tty` NO-ECHO.
    SET aux_nmendter WITH FRAME f_terminal.
    INPUT CLOSE.

    aux_nmendter = substr(glb_hostname,length(glb_hostname) - 1) +
                          aux_nmendter.
 
    IF  NOT VALID-HANDLE(h-b1wgen0120) THEN 
        RUN sistema/generico/procedures/b1wgen0120.p
            PERSISTENT SET h-b1wgen0120.

    RUN Gera_Fita_Caixa IN h-b1wgen0120
        ( INPUT glb_cdcooper,
          INPUT 0,
          INPUT 0,
          INPUT 1, /* idorigem */
          INPUT glb_nmdatela,
          INPUT glb_dtmvtolt,
          INPUT glb_cddopcao,
          INPUT aux_nmendter,
          INPUT aux_recidbol,
          INPUT aux_tipconsu,
         OUTPUT aux_nmarqimp,
         OUTPUT aux_nmarqpdf,
         OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE <> "OK" OR TEMP-TABLE tt-erro:HAS-RECORDS THEN
        DO:
            FIND FIRST tt-erro NO-ERROR.

            IF  AVAILABLE tt-erro THEN
                MESSAGE tt-erro.dscritic.
                   
            RETURN "NOK".  
        END.

    IF  NOT aux_tipconsu   THEN
        DO:
            /*** nao necessario ao programa somente para nao dar erro 
                          de compilacao na rotina de impressao ****/
            FIND FIRST crapass WHERE crapass.cdcooper = glb_cdcooper 
                                                     NO-LOCK NO-ERROR.

            { includes/impressao.i }

            HIDE MESSAGE NO-PAUSE.
        END.
    
    RETURN "OK".

END PROCEDURE. /* Gera_Fita_Caixa */

PROCEDURE Gera_Depositos_Saques:

    DEF VAR aux_nmarqpdf AS CHAR NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.

    INPUT THROUGH basename `tty` NO-ECHO.
    SET aux_nmendter WITH FRAME f_terminal.
    INPUT CLOSE.

    aux_nmendter = substr(glb_hostname,length(glb_hostname) - 1) +
                          aux_nmendter.

    IF  NOT VALID-HANDLE(h-b1wgen0120) THEN 
        RUN sistema/generico/procedures/b1wgen0120.p
            PERSISTENT SET h-b1wgen0120.

    RUN Gera_Depositos_Saques IN h-b1wgen0120
        ( INPUT glb_cdcooper,
          INPUT 0,
          INPUT 0,
          INPUT 1, /* idorigem */
          INPUT glb_nmdatela,
          INPUT glb_dtmvtolt,
          INPUT glb_cddopcao,
          INPUT aux_nmendter,
          INPUT aux_recidbol,
          INPUT aux_tipconsu,
         OUTPUT aux_nmarqimp,
         OUTPUT aux_nmarqpdf,
         OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE <> "OK" OR TEMP-TABLE tt-erro:HAS-RECORDS THEN
        DO:
            FIND FIRST tt-erro NO-ERROR.

            IF  AVAILABLE tt-erro THEN
                MESSAGE tt-erro.dscritic.
                   
            RETURN "NOK".  
        END.

    IF  NOT aux_tipconsu   THEN
        DO:
            /*** nao necessario ao programa somente para nao dar erro 
                          de compilacao na rotina de impressao ****/
            FIND FIRST crapass WHERE crapass.cdcooper = glb_cdcooper 
                                                     NO-LOCK NO-ERROR.

            { includes/impressao.i }

            HIDE MESSAGE NO-PAUSE.
        END.
    
    RETURN "OK".

END PROCEDURE. /* Gera_Depositos_Saques */

PROCEDURE Valida_Dados:

    EMPTY TEMP-TABLE tt-boletimcx.
    EMPTY TEMP-TABLE tt-erro.

    DO WITH FRAME f_bcaixa:
        ASSIGN tel_vldentra
               tel_vldsaida.

    END.

    INPUT THROUGH basename `tty` NO-ECHO.
    SET aux_nmendter WITH FRAME f_terminal.
    INPUT CLOSE.

    aux_nmendter = substr(glb_hostname,length(glb_hostname) - 1) +
                          aux_nmendter.

    IF  NOT VALID-HANDLE(h-b1wgen0120) THEN 
        RUN sistema/generico/procedures/b1wgen0120.p
            PERSISTENT SET h-b1wgen0120.

    RUN Valida_Dados IN h-b1wgen0120
        ( INPUT glb_cdcooper,
          INPUT 0,
          INPUT 0,
          INPUT glb_cdoperad,
          INPUT 1, /* idorigem */
          INPUT glb_dtmvtolt,
          INPUT glb_dtmvtopr,
          INPUT glb_nmdatela,
          INPUT aux_nmendter,
          INPUT glb_cddopcao,
          INPUT tel_cdopecxa,
          INPUT tel_dtmvtolt,
          INPUT tel_cdagenci,
          INPUT tel_nrdcaixa,
          INPUT tel_vldentra,
          INPUT tel_vldsaida,
          INPUT aux_cdoplanc,
          INPUT tel_cdhistor,
          INPUT tel_nrdocmto,
          INPUT tel_nrseqdig,
          INPUT tel_vldocmto,
          INPUT TRUE, /* flgerlog */
         OUTPUT aux_nmdcampo,
         OUTPUT aux_msgretor,
         OUTPUT aux_vlrttcrd,
         OUTPUT aux_vldsdfin,
         OUTPUT aux_nrctadeb,
         OUTPUT aux_nrctacrd,
         OUTPUT aux_cdhistor,
         OUTPUT aux_dshistor,
         OUTPUT aux_dsdcompl,
         OUTPUT aux_vldocmto,
         OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE <> "OK" OR TEMP-TABLE tt-erro:HAS-RECORDS THEN
        DO:
            FIND FIRST tt-erro NO-ERROR.

            IF  AVAILABLE tt-erro THEN
                MESSAGE tt-erro.dscritic.

            IF  aux_msgretor <> "" THEN
                MESSAGE aux_msgretor.

            RETURN "NOK".  
        END.

    RETURN "OK".

END PROCEDURE. /* Valida_Dados */

PROCEDURE Valida_Historico:

    EMPTY TEMP-TABLE tt-erro.

    IF  NOT VALID-HANDLE(h-b1wgen0120) THEN 
        RUN sistema/generico/procedures/b1wgen0120.p
            PERSISTENT SET h-b1wgen0120.

    RUN Valida_Historico IN h-b1wgen0120
        ( INPUT glb_cdcooper,
          INPUT 0,
          INPUT 0,
          INPUT glb_cdoperad,
          INPUT 1,  /* idorigem */
          INPUT "", /*cddopcao */
          INPUT tel_cdagenci,
          INPUT tel_cdhistor,
          INPUT tel_nrdocmto,
          INPUT tel_nrseqdig,
         OUTPUT aux_nrctadeb,
         OUTPUT aux_nrctacrd,
         OUTPUT aux_cdhistor,
         OUTPUT aux_dshistor,
         OUTPUT aux_indcompl,
         OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE <> "OK" OR TEMP-TABLE tt-erro:HAS-RECORDS THEN
        DO:
            FIND FIRST tt-erro NO-ERROR.

            IF  AVAILABLE tt-erro THEN
                MESSAGE tt-erro.dscritic.

            RETURN "NOK".  
        END.

    RETURN "OK".

END PROCEDURE. /* Valida_Historico */

PROCEDURE Grava_Dados:

    EMPTY TEMP-TABLE tt-erro.

    IF  NOT VALID-HANDLE(h-b1wgen0120) THEN 
        RUN sistema/generico/procedures/b1wgen0120.p
            PERSISTENT SET h-b1wgen0120.

    RUN Grava_Dados IN h-b1wgen0120
        ( INPUT glb_cdcooper,
          INPUT 0,
          INPUT 0,
          INPUT glb_cdoperad,
          INPUT 1, /* idorigem */
          INPUT glb_dtmvtolt,
          INPUT glb_cddopcao,
          INPUT aux_cdoplanc,
          INPUT tel_cdagenci,
          INPUT tel_nrdcaixa,
          INPUT tel_cdopecxa,
          INPUT tel_nrdlacre,
          INPUT tel_qtautent,
          INPUT tel_vldentra,
          INPUT tel_vldsaida,
          INPUT tel_vldsdini,
          INPUT tel_nrdmaqui,
          INPUT tel_nrdocmto,
          INPUT tel_nrseqdig,
          INPUT tel_cdhistor,
          INPUT tel_dsdcompl,
          INPUT tel_vldocmto,
          INPUT TRUE, /* flgerlog */
         OUTPUT aux_nrdrecid,
         OUTPUT aux_nrdlacre,
         OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE <> "OK" OR TEMP-TABLE tt-erro:HAS-RECORDS THEN
        DO:
            FIND FIRST tt-erro NO-ERROR.

            IF  AVAILABLE tt-erro THEN
                MESSAGE tt-erro.dscritic.
            
            RETURN "NOK".  
        END.
        
    IF  VALID-HANDLE(h-b1wgen0120)  THEN
        DELETE PROCEDURE h-b1wgen0120.

    RETURN "OK".

END PROCEDURE. /* Valida_Dados */

PROCEDURE impressao:

 FIND FIRST crapass 
          WHERE crapass.cdcooper = glb_cdcooper       
                NO-LOCK NO-ERROR.
     
     { includes/impressao.i }

END PROCEDURE.

/* .......................................................................... */


