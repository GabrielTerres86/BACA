/* ............................................................................

   Programa: Fontes/lislot_3.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : David Kruger
   Data    : Julho/2012                         Ultima atualizacao: 15/04/2015

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar informacoes na tela LISLOT.

   
   Alteracoes: 05/09/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).
                            
               28/03/2014 - Adaptado para a B1wgen0184.p - Jéssica Laverde (DB1)
               
               02/06/2014 - Concatena o numero do servidor no endereco do
                            terminal (Tiago-RKAM).
   
               15/04/2015 - Aumentar format do nrdocmto para 25 posicoes    
                            (Lucas Ranghetti #275848)       
............................................................................. */

{includes/var_online.i}

{ sistema/generico/includes/b1wgen0184tt.i }
{ sistema/generico/includes/var_internet.i }

DEF VAR h-b1wgen0184 AS HANDLE                                  NO-UNDO. 

DEF INPUT PARAM par_cdagenci AS INT FORMAT "zz9"                NO-UNDO.
DEF INPUT PARAM par_cdhistor AS INT FORMAT "zzz9"               NO-UNDO.
DEF INPUT PARAM par_dtinicio AS DATE FORMAT "99/99/9999"        NO-UNDO.
DEF INPUT PARAM par_dttermin AS DATE FORMAT "99/99/9999"        NO-UNDO. 
DEF INPUT PARAM par_cddopcao AS CHAR                            NO-UNDO.


DEF  VAR tel_tpdopcao AS CHAR FORMAT "x(9)" 
     VIEW-AS COMBO-BOX INNER-LINES 3 
     LIST-ITEMS "COOPERADO", "CAIXA" , "LOTE P/PA"
     INIT "CAIXA"                                               NO-UNDO.

DEF  VAR tel_nmdopcao   AS LOG FORMAT "ARQUIVO/IMPRESSAO" INIT TRUE NO-UNDO.

DEF  VAR par_nrdconta AS INTE                                    NO-UNDO. 

DEF  VAR tot_vllanmto AS  DECI                                    NO-UNDO.
DEF  VAR tot_registro AS  INTE                                    NO-UNDO.
DEF  VAR aux_nmendter   AS CHAR FORMAT "x(20)"                      NO-UNDO.

DEF  VAR aux_nmarqimp   AS CHAR                                     NO-UNDO.
DEF  VAR tel_nmdireto   AS CHAR  FORMAT "x(20)"                     NO-UNDO.
DEF  VAR aux_confirma   AS CHAR FORMAT "!(1)"                       NO-UNDO.  


         
/* Variaveis de Impressao */
DEF   VAR par_flgcance   AS LOGICAL                                  NO-UNDO.
DEF   VAR par_flgrodar   AS LOGICAL    INIT TRUE                     NO-UNDO.
DEF   VAR par_flgfirst   AS LOGICAL    INIT TRUE                     NO-UNDO.

DEF   VAR tel_dsimprim   AS CHAR  FORMAT "x(8)" INIT "Imprimir"      NO-UNDO.
DEF   VAR tel_dscancel   AS CHAR  FORMAT "x(8)" INIT "Cancelar"      NO-UNDO. 
DEF   VAR tel_nmarquiv   AS CHAR  FORMAT "x(25)"                     NO-UNDO. 

DEF   VAR aux_flgescra   AS LOGICAL                                  NO-UNDO.
DEF   VAR aux_dscomand   AS CHAR                                     NO-UNDO.
DEF   VAR aux_contador   AS INT                                      NO-UNDO.
DEF   VAR aux_dslog      AS CHAR                                     NO-UNDO.

DEF   VAR rel_nmempres   AS CHAR  FORMAT "x(15)"                     NO-UNDO.
DEF   VAR rel_nmrelato   AS CHAR  FORMAT "x(40)" EXTENT 5            NO-UNDO.
DEF   VAR rel_nrmodulo   AS INT   FORMAT "9"                         NO-UNDO.
DEF   VAR rel_nmmodulo   AS CHAR  FORMAT "x(15)" EXTENT 5
                                      INIT ["DEP. A VISTA   ",
                                            "CAPITAL        ",
                                            "EMPRESTIMOS    ",
                                            "DIGITACAO      ",
                                            "GENERICO       "]      NO-UNDO.

DEF  VAR aux_qtregist AS INTE                                       NO-UNDO. 
DEF  VAR aux_nmdcampo AS INTE                                       NO-UNDO. 
DEF  VAR aux_nmarqpdf AS CHAR                                       NO-UNDO.

DEF STREAM str_1.  

IF par_cddopcao = "T" THEN
   RUN lislot_terminal(INPUT par_cdagenci,
                       INPUT par_cdhistor,
                       INPUT par_dtinicio,
                       INPUT par_dttermin).
ELSE
   IF par_cddopcao = "I" THEN
      RUN gera_impressao_lislot(INPUT par_cdagenci,
                                INPUT par_cdhistor,
                                INPUT par_dtinicio,
                                INPUT par_dttermin).


/***********************************************************************
 Mostra informacoes na tela LISLOT referente ao Caixa-Online, tabela
 craplcx.          
************************************************************************/
PROCEDURE lislot_terminal.

   DEF INPUT PARAM par_cdagenci AS INT FORMAT "zz9"                NO-UNDO.
   DEF INPUT PARAM par_cdhistor AS INT FORMAT "zzz9"               NO-UNDO.
   DEF INPUT PARAM par_dtinicio AS DATE FORMAT "99/99/9999"        NO-UNDO.
   DEF INPUT PARAM par_dttermin AS DATE FORMAT "99/99/9999"        NO-UNDO.

   DEF QUERY q-historico FOR tt-craplcx.
   
   DEF BROWSE b-historico QUERY q-historico
       DISPLAY tt-craplcx.dtmvtolt COLUMN-LABEL "Data"
               SPACE(7)
               tt-craplcx.cdagenci COLUMN-LABEL "PA"
               tt-craplcx.nrdcaixa COLUMN-LABEL "Caixa"
               tt-craplcx.nrdocmto COLUMN-LABEL "Documento"
               FORMAT "zzz,zzz,zzz,zzz,zzz,zzz,zzz,zz9"
               SPACE(10)
               tt-craplcx.vldocmto COLUMN-LABEL "Valor"
               WITH WIDTH 78 5 DOWN SCROLLBAR-VERTICAL.
   
   FORM   b-historico  HELP "Use as SETAS para navegar ou <F4> para sair." SKIP
          "Quantidade de Registros:" AT 1
          tot_registro               AT 25 NO-LABEL FORMAT ">>>>>>>>9"             
          "Valor Total:"             AT 37
          tot_vllanmto               AT 49 NO-LABEL FORMAT ">>>,>>>,>>9.99"
          WITH  NO-BOX CENTERED OVERLAY ROW 10 FRAME f-historico.
   
   MESSAGE "PESQUISANDO...".
   
   RUN Busca_Dados.

   IF RETURN-VALUE <> "OK" THEN
       NEXT.
   
   OPEN QUERY q-historico                                                         
   FOR EACH tt-craplcx. 
   QUERY q-historico:GET-FIRST().
   
   HIDE MESSAGE NO-PAUSE.
   
   ENABLE b-historico WITH FRAME f-historico.             
   DISPLAY tot_registro 
           tot_vllanmto
   WITH  FRAME f-historico.
   
   WAIT-FOR END-ERROR OF DEFAULT-WINDOW.
   HIDE FRAME f-historico.

   RETURN "OK".

END PROCEDURE.


/***********************************************************************************
Gera impressao das informacoes consultadas na tela lislot referente ao caixa-online
tabela craplcx.
***********************************************************************************/
PROCEDURE gera_impressao_lislot.

   DEF INPUT PARAM par_cdagenci AS INT FORMAT "zz9"                     NO-UNDO.
   DEF INPUT PARAM par_cdhistor AS INT FORMAT "zzz9"                    NO-UNDO.
   DEF INPUT PARAM par_dtinicio AS DATE FORMAT "99/99/9999"             NO-UNDO.
   DEF INPUT PARAM par_dttermin AS DATE FORMAT "99/99/9999"             NO-UNDO. 

   FORM 
       "Saida:"           
       tel_nmdopcao       HELP "(A)rquivo ou (I)mpressao."
       WITH FRAME f_dados_1 OVERLAY ROW 8 NO-LABEL NO-BOX COLUMN 58.
   
   FORM
       "Diretorio:   "     AT 5
       tel_nmdireto
       tel_nmarquiv        HELP "Informe o nome do arquivo."
       WITH OVERLAY ROW 10 NO-LABEL NO-BOX COLUMN 2 FRAME f_diretorio.
   

   UPDATE tel_nmdopcao WITH FRAME f_dados_1.
   
   INPUT THROUGH basename `tty` NO-ECHO.

   SET aux_nmendter WITH FRAME f_terminal.

   INPUT CLOSE.

   aux_nmendter = substr(glb_hostname,length(glb_hostname) - 1) +
                         aux_nmendter.
   
   IF  tel_nmdopcao  THEN
       DO:
           ASSIGN tel_nmdireto = UPPER("/micros/") + glb_nmrescop + "/".

           DISP tel_nmdireto WITH FRAME f_diretorio.    

           UPDATE tel_nmarquiv WITH FRAME f_diretorio.
           
           ASSIGN aux_nmendter = tel_nmarquiv.
       END.

   RUN Gera_Impressao.

   HIDE FRAME f_diretorio. 
   HIDE FRAME f_dados_1.   
                           
   CLEAR FRAME f_diretorio.
   CLEAR FRAME f_dados_1.  

   IF RETURN-VALUE <> "OK" THEN
       NEXT.
   
 
END PROCEDURE.


PROCEDURE confirma:

      /* Confirma */
      DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
         ASSIGN aux_confirma = "N"
                glb_cdcritic = 78.
                RUN fontes/critic.p.
                glb_cdcritic = 0.
                BELL.
                MESSAGE COLOR NORMAL glb_dscritic UPDATE aux_confirma.
                LEAVE.
      END.  /*  Fim do DO WHILE TRUE  */

      IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   OR   aux_confirma <> "S" THEN
           DO:
               glb_cdcritic = 79.
               RUN fontes/critic.p.
               glb_cdcritic = 0.
               BELL.
               MESSAGE glb_dscritic.
               PAUSE 2 NO-MESSAGE.
               CLEAR FRAME f_cadgps.
           END. /* Mensagem de confirmacao */

END PROCEDURE.

/*........................................................................... */

/* -------------------------------------------------------------------------- */
/*                      EFETUA A PESQUISA DOS HISTORICOS                      */
/* -------------------------------------------------------------------------- */
PROCEDURE Busca_Dados:

    EMPTY TEMP-TABLE tt-retorno.
    EMPTY TEMP-TABLE tt-craplcx.
    EMPTY TEMP-TABLE tt-craplcm.
    EMPTY TEMP-TABLE tt-erro.

    RUN conecta_handle.

    RUN Busca_Dados IN h-b1wgen0184
                  (  INPUT glb_cdcooper,
                     INPUT par_cdagenci,
                     INPUT 0,
                     INPUT glb_cdoperad,
                     INPUT glb_nmdatela,
                     INPUT 1, /* idorigem */
                     INPUT glb_dsdepart,
                     INPUT glb_dtmvtolt,
                     INPUT glb_cddopcao,
                     INPUT tel_tpdopcao,
                     INPUT par_cdhistor,
                     INPUT par_nrdconta,
                     INPUT par_dtinicio,
                     INPUT par_dttermin,
                     INPUT 0, /* nrregist */
                     INPUT 0, /* nriniseq */
                     INPUT TRUE, /* flgerlog */
                    OUTPUT aux_qtregist,
                    OUTPUT aux_nmdcampo,
                    OUTPUT tot_vllanmto,
                    OUTPUT tot_registro,
                    OUTPUT TABLE tt-lislot,
                    OUTPUT TABLE tt-lislot-aux,
                    OUTPUT TABLE tt-retorno,
                    OUTPUT TABLE tt-craplcx,
                    OUTPUT TABLE tt-craplcx-aux,
                    OUTPUT TABLE tt-craplcm,
                    OUTPUT TABLE tt-craplcm-aux,
                    OUTPUT TABLE tt-erro) NO-ERROR.

    RUN desconecta_handle.

    IF  ERROR-STATUS:ERROR THEN
        DO:
           MESSAGE ERROR-STATUS:GET-MESSAGE(1).
           RETURN "NOK".
        END.

    IF  RETURN-VALUE <> "OK" OR TEMP-TABLE tt-erro:HAS-RECORDS THEN
        DO:
            FIND FIRST tt-erro NO-ERROR.

            IF  AVAILABLE tt-erro THEN
                MESSAGE tt-erro.dscritic.

            RETURN "NOK".
        END.

    RETURN "OK".

END PROCEDURE. /* Busca_Dados */

/* -------------------------------------------------------------------------- */
/*                      EFETUA A IMPRESSãO DOS HISTORICOS                     */
/* -------------------------------------------------------------------------- */
PROCEDURE Gera_Impressao:

    EMPTY TEMP-TABLE tt-erro.
    
    RUN conecta_handle.

    RUN Gera_Impressao IN h-b1wgen0184                           
                    (   INPUT glb_cdcooper,                  
                        INPUT par_cdagenci,                             
                        INPUT 0,                             
                        INPUT glb_cdoperad,                  
                        INPUT glb_nmdatela,                                                         
                        INPUT 1, /*idorigem*/             
                        INPUT glb_dsdepart,
                        INPUT glb_dtmvtolt,               
                        INPUT glb_cddopcao,               
                        INPUT tel_tpdopcao,               
                        INPUT par_nrdconta,               
                        INPUT par_dtinicio,               
                        INPUT par_dttermin,               
                        INPUT TRUE,                       
                        INPUT aux_nmendter,               
                        INPUT tel_nmdopcao,               
                        INPUT par_cdhistor,                                                         
                       OUTPUT aux_nmarqimp,                  
                       OUTPUT aux_nmarqpdf,
                       OUTPUT tel_nmdireto,
                       OUTPUT TABLE tt-erro) NO-ERROR.           
                                                                 
    RUN desconecta_handle. 

    HIDE FRAME f_diretorio.
    HIDE FRAME f_dados_1.

    CLEAR FRAME f_diretorio.
    CLEAR FRAME f_dados_1.

                                                                   
    IF  ERROR-STATUS:ERROR THEN                                  
        DO:                                                      
           MESSAGE ERROR-STATUS:GET-MESSAGE(1).
           RETURN "NOK".
        END.

    IF  RETURN-VALUE <> "OK" OR TEMP-TABLE tt-erro:HAS-RECORDS THEN
        DO:
            FIND FIRST tt-erro NO-ERROR.

            IF  AVAILABLE tt-erro THEN
                MESSAGE tt-erro.dscritic.

            RETURN "NOK".
        END.

    IF  tel_nmdopcao  THEN DO:
        BELL.
        MESSAGE "Arquivo gerado com sucesso no diretorio: " + tel_nmdireto.
        PAUSE 3 NO-MESSAGE.
    END.
    ELSE DO:
        RUN confirma.
                     
        IF  aux_confirma = "S"  THEN 
            DO:
        
                FIND FIRST crapass WHERE crapass.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.
                                                                                      
                { includes/impressao.i }                                                  
    
            END.
    
    END.
    
    HIDE MESSAGE NO-PAUSE.

    RETURN "OK".

END PROCEDURE. /* Gera_Impressao*/

/*----------------------------------------------------------------------------*/
PROCEDURE conecta_handle:

    IF  NOT VALID-HANDLE(h-b1wgen0184) THEN
            RUN sistema/generico/procedures/b1wgen0184.p
                PERSISTENT SET h-b1wgen0184.
END PROCEDURE.

PROCEDURE desconecta_handle:

    IF  VALID-HANDLE(h-b1wgen0184) THEN
            DELETE OBJECT h-b1wgen0184.
END PROCEDURE.


