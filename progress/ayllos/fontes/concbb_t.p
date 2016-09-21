/* ..........................................................................

   Programa: Fontes/concbb_t.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autora  : Mirtes         
   Data    : Agosto/2004                     Ultima atualizacao: 29/05/2014

   Dados referentes ao programa:

   Frequencia: Diario (ON-LINE).
   Objetivo  : Tratamento de arquivo de retorno Correspondente Bancario.       

   Alteracoes: 13/12/2004 - Mudado o format da Hora Trans para HH:MM:SS
                            (Evandro).

               25/01/2005 - Perguntar se o arquivo foi recebido pelo 
                            GERENCIADOR FINANCEIRO (Edson).
               
               31/01/2004 - Alterado nome arquivo CBF800 - no diretorio salvar
                           (Incluido data - Se proveniente Gerenciador)(Mirtes)
                           
               27/06/2005 - Alimentado campo cdcooper da tabela craprcb        
                            (Diego).

               20/09/2005 - Modificado FIND FIRST para FIND na tabela 
                            crapcop.cdcooper = glb_cdcooper (Diego).

              10/11/2005 - Desprezar tipo docto 3 - Recebto INSS(Mirtes)

              11/01/2006 - Tratar tipo docto 3- Recebto INSS(Mirtes)
              
              26/01/2006 - Unificacao dos Bancos - SQLWorks - Fernando
              
              28/08/2009 - Mostrar diferencas do BB em relacao a               
                           cooperativa (Guilherme).
                           
              11/08/2011 - Adaptado para uso de BO (Gabriel Capoia - DB1)
              
              24/05/2012 - Inclusão de tratamento para DELETE de handle preso
                           BO b1wgen0108.p (Lucas R.)
                           
              29/05/2014 - Concatena o numero do servidor no endereco do
                            terminal (Tiago-RKAM).
                            
............................................................................ */
{ sistema/generico/includes/b1wgen0108tt.i }
{ sistema/generico/includes/var_internet.i }
{ includes/var_online.i }
                                                                      
DEF STREAM str_1.
DEF STREAM str_2.

DEF        VAR aux_confirma AS CHAR    FORMAT "!"                    NO-UNDO.

DEF INPUT PARAM par_dtmvtolt AS DATE   FORMAT "99/99/9999"           NO-UNDO.
DEF INPUT PARAM par_cdagenci AS INT                                  NO-UNDO.
DEF INPUT PARAM par_nrdcaixa AS INT                                  NO-UNDO.

DEF VAR h-b1wgen0108 AS HANDLE                                       NO-UNDO.
DEF VAR aux_flggeren AS LOGI                                         NO-UNDO.
DEF VAR aux_mrsgetor AS CHAR                                         NO-UNDO.
DEF VAR aux_msgprint AS CHAR                                         NO-UNDO.

DEF VAR aux_nmarqimp AS CHAR                                         NO-UNDO.
DEF VAR aux_nmarqpdf AS CHAR                                         NO-UNDO.
DEF VAR aux_nmendter AS CHAR    FORMAT "x(20)"                       NO-UNDO.
DEF VAR par_flgrodar AS LOGI INIT TRUE                               NO-UNDO.
DEF VAR aux_flgescra AS LOGI                                         NO-UNDO.
DEF VAR aux_dscomand AS CHAR                                         NO-UNDO.
DEF VAR par_flgfirst AS LOG INIT TRUE                                NO-UNDO.
DEF VAR aux_contador AS INT                                          NO-UNDO.
DEF VAR tel_dsimprim AS CHAR    FORMAT "x(8)" INIT "Imprimir"        NO-UNDO.
DEF VAR tel_dscancel AS CHAR    FORMAT "x(8)" INIT "Cancelar"        NO-UNDO.
DEF VAR par_flgcance AS LOG                                          NO-UNDO.

/* Variaveis para impressao */
DEF  VAR rel_nmrelato     AS CHAR    FORMAT "x(40)" EXTENT 5         NO-UNDO.
DEF  VAR rel_nmempres     AS CHAR    FORMAT "x(15)"                  NO-UNDO.
DEF  VAR rel_nrmodulo     AS INT     FORMAT "9"                      NO-UNDO.
DEF  VAR rel_nmmodulo     AS CHAR    FORMAT "x(15)" EXTENT 5
                               INIT ["DEP. A VISTA   ","CAPITAL        ",
                                     "EMPRESTIMOS    ","DIGITACAO      ",
                                     "GENERICO       "]              NO-UNDO.


DEF  VAR aux_qttitrec AS DECI   FORMAT "zzz,zz9"                     NO-UNDO.
DEF  VAR aux_vltitrec AS DECI   FORMAT "zzz,zzz,zz9.99"              NO-UNDO.
DEF  VAR aux_qttitliq AS DECI   FORMAT "zzz,zz9"                     NO-UNDO.
DEF  VAR aux_vltitliq AS DECI   FORMAT "zzz,zzz,zz9.99"              NO-UNDO.
DEF  VAR aux_qttitcan AS DECI   FORMAT "zzz,zz9"                     NO-UNDO.
DEF  VAR aux_vltitcan AS DECI   FORMAT "zzz,zzz,zz9.99"              NO-UNDO.
DEF  VAR aux_qtfatrec AS DECI   FORMAT "zzz,zz9"                     NO-UNDO.
DEF  VAR aux_vlfatrec AS DECI   FORMAT "zzz,zzz,zz9.99"              NO-UNDO.
DEF  VAR aux_qtfatliq AS DECI   FORMAT "zzz,zz9"                     NO-UNDO.
DEF  VAR aux_vlfatliq AS DECI   FORMAT "zzz,zzz,zz9.99"              NO-UNDO.
DEF  VAR aux_qtfatcan AS DECI   FORMAT "zzz,zz9"                     NO-UNDO.
DEF  VAR aux_vlfatcan AS DECI   FORMAT "zzz,zzz,zz9.99"              NO-UNDO.
DEF  VAR aux_qtdinhei AS DECI   FORMAT "zzz,zz9"                     NO-UNDO.
DEF  VAR aux_vldinhei AS DECI   FORMAT "zzz,zzz,zz9.99"              NO-UNDO.
DEF  VAR aux_qtcheque AS DECI   FORMAT "zzz,zz9"                     NO-UNDO.
DEF  VAR aux_vlcheque AS DECI   FORMAT "zzz,zzz,zz9.99"              NO-UNDO.
DEF  VAR aux_qtinss   AS DECI   FORMAT "zzz,zz9"                     NO-UNDO.
DEF  VAR aux_vlinss   AS DECI   FORMAT "zzz,zzz,zz9.99"              NO-UNDO.
DEF  VAR aux_vlrepasse  AS DEC NO-UNDO.

FORM "Qtd.               Valor" AT 36 
     aux_qttitrec AT 12 FORMAT "zzz,zz9" LABEL  "Titulos  Recebidos"
     aux_vltitrec AT 46 FORMAT "zzz,zzz,zz9.99" NO-LABEL
            
     aux_qttitliq AT 12 FORMAT "zzz,zz9-" LABEL "Titulos Liquidados"
     aux_vltitliq AT 46 FORMAT "zzz,zzz,zz9.99-" NO-LABEL
               
     aux_qttitcan AT 12 FORMAT "zzz,zz9-" LABEL "Titulos Cancelados"
     aux_vltitcan AT 46 FORMAT "zzz,zzz,zz9.99-" NO-LABEL
               
     aux_qtfatrec AT 12 FORMAT "zzz,zz9" LABEL  "Faturas  Recebidas"
     aux_vlfatrec AT 46 FORMAT "zzz,zzz,zz9.99" NO-LABEL
            
     aux_qtfatliq AT 12 FORMAT "zzz,zz9-" LABEL "Faturas Liquidadas"
     aux_vlfatliq AT 46 FORMAT "zzz,zzz,zz9.99-" NO-LABEL
                
     aux_qtfatcan AT 12 FORMAT "zzz,zz9-" LABEL "Faturas Canceladas"
     aux_vlfatcan AT 46 FORMAT "zzz,zzz,zz9.99-" NO-LABEL

     aux_qtinss   AT 12 FORMAT "zzz,zz9-" LABEL "Qtd.INSS          "
     aux_vlinss   AT 46 FORMAT "zzz,zzz,zz9.99-" NO-LABEL
     SKIP(1)
     aux_qtdinhei AT 12 FORMAT "zzz,zz9" LABEL  "Pago  Dinheiro"             
     aux_vldinhei AT 46 FORMAT "zzz,zzz,zz9.99" NO-LABEL
     aux_qtcheque AT 12 FORMAT "zzz,zz9" LABEL  "Pago    Cheque"             
     aux_vlcheque AT 46 FORMAT "zzz,zzz,zz9.99" NO-LABEL
     SKIP(1)
     "REPASSE" AT 12
     aux_vlrepasse AT 46 FORMAT "zzz,zzz,zz9.99"  NO-LABEL
     SKIP
     WITH ROW 8 COLUMN 10 NO-BOX OVERLAY SIDE-LABELS FRAME f_total.

HIDE MESSAGE NO-PAUSE.

ASSIGN aux_confirma = "N".
   
DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

  MESSAGE "O arquivo foi recebido pelo GERENCIADOR FINANCEIRO? (S/N):"
          UPDATE aux_confirma.

  LEAVE.

END.  /*  Fim do DO WHILE TRUE  */

ASSIGN aux_flggeren = IF   aux_confirma = "S" THEN 
                           TRUE
                      ELSE FALSE.

RUN Busca_Movimento.

IF  RETURN-VALUE <> "OK" THEN
    NEXT.

FIND FIRST tt-total NO-ERROR.

IF  AVAIL tt-total THEN
    ASSIGN aux_qttitrec  = tt-total.qttitrec 
           aux_vltitrec  = tt-total.vltitrec 
           aux_qttitliq  = tt-total.qttitliq 
           aux_vltitliq  = tt-total.vltitliq 
           aux_qttitcan  = tt-total.qttitcan 
           aux_vltitcan  = tt-total.vltitcan 
           aux_qtfatrec  = tt-total.qtfatrec 
           aux_vlfatrec  = tt-total.vlfatrec 
           aux_qtfatliq  = tt-total.qtfatliq 
           aux_vlfatliq  = tt-total.vlfatliq 
           aux_qtfatcan  = tt-total.qtfatcan 
           aux_vlfatcan  = tt-total.vlfatcan 
           aux_qtinss    = tt-total.qtinss   
           aux_vlinss    = tt-total.vlinss   
           aux_qtdinhei  = tt-total.qtdinhei 
           aux_vldinhei  = tt-total.vldinhei 
           aux_qtcheque  = tt-total.qtcheque 
           aux_vlcheque  = tt-total.vlcheque 
           aux_vlrepasse = tt-total.vlrepasse.
ELSE
    ASSIGN aux_qttitrec  = 0
           aux_vltitrec  = 0
           aux_qttitliq  = 0
           aux_vltitliq  = 0
           aux_qttitcan  = 0
           aux_vltitcan  = 0
           aux_qtfatrec  = 0
           aux_vlfatrec  = 0
           aux_qtfatliq  = 0
           aux_vlfatliq  = 0
           aux_qtfatcan  = 0
           aux_vlfatcan  = 0
           aux_qtinss    = 0
           aux_vlinss    = 0
           aux_qtdinhei  = 0
           aux_vldinhei  = 0
           aux_qtcheque  = 0
           aux_vlcheque  = 0
           aux_vlrepasse = 0.

DISPLAY aux_qttitrec
        aux_vltitrec
        aux_qttitliq
        aux_vltitliq
        aux_qttitcan
        aux_vltitcan
        aux_qtfatrec
        aux_vlfatrec
        aux_qtfatliq
        aux_vlfatliq
        aux_qtfatcan
        aux_vlfatcan
        aux_qtinss
        aux_vlinss
        aux_qtdinhei
        aux_vldinhei
        aux_qtcheque
        aux_vlcheque
        aux_vlrepasse
        WITH FRAME f_total.

IF  aux_mrsgetor <> "" THEN
    MESSAGE aux_mrsgetor.

IF  TEMP-TABLE tt-mensagens:HAS-RECORDS THEN
    DO:
        FOR EACH tt-mensagens BY tt-mensagens.nrsequen:
            MESSAGE tt-mensagens.dsmensag VIEW-AS ALERT-BOX.
        END.
    END.

DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

    ASSIGN aux_confirma = "N".
    MESSAGE COLOR NORMAL aux_msgprint UPDATE aux_confirma.
    LEAVE.

END. /* fim do DO WHILE */
                            
IF  KEYFUNCTION(LASTKEY) = "END-ERROR"   OR
    aux_confirma <> "S" THEN
    NEXT.

RUN Lista_Faturas.

ASSIGN glb_nrdevias = 1
       par_flgrodar = TRUE.

FIND FIRST crapass WHERE crapass.cdcooper = glb_cdcooper   NO-LOCK NO-ERROR.

{ includes/impressao.i }

/* ........................................................................  */

PROCEDURE Busca_Movimento:
    
    EMPTY TEMP-TABLE tt-total.
    EMPTY TEMP-TABLE tt-mensagens.
    EMPTY TEMP-TABLE tt-erro.

    IF  NOT VALID-HANDLE(h-b1wgen0108) THEN
        RUN sistema/generico/procedures/b1wgen0108.p
            PERSISTENT SET h-b1wgen0108.

    RUN Busca_Movimento IN h-b1wgen0108
        ( INPUT glb_cdcooper,
          INPUT 0,
          INPUT 0,
          INPUT glb_dtmvtolt,
          INPUT par_cdagenci,
          INPUT par_nrdcaixa,
          INPUT par_dtmvtolt,
          INPUT aux_flggeren,
         OUTPUT aux_mrsgetor,
         OUTPUT aux_msgprint,
         OUTPUT TABLE tt-total,
         OUTPUT TABLE tt-mensagens,
         OUTPUT TABLE tt-erro).
    
    IF VALID-HANDLE( h-b1wgen0108) THEN
       DELETE PROCEDURE h-b1wgen0108.
        
    IF  RETURN-VALUE <> "OK" OR TEMP-TABLE tt-erro:HAS-RECORDS THEN
        DO:
            FIND FIRST tt-erro NO-ERROR.

            IF  AVAILABLE tt-erro THEN
                MESSAGE tt-erro.dscritic.
                   
            RETURN "NOK".  
        END.

    RETURN "OK".

END PROCEDURE. /* Busca_Movimento */

PROCEDURE Lista_Faturas:

    INPUT THROUGH basename `tty` NO-ECHO.
    SET aux_nmendter WITH FRAME f_terminal.
    INPUT CLOSE.
    
    aux_nmendter = substr(glb_hostname,length(glb_hostname) - 1) +
                          aux_nmendter.
    
    IF  NOT VALID-HANDLE(h-b1wgen0108) THEN
        RUN sistema/generico/procedures/b1wgen0108.p
            PERSISTENT SET h-b1wgen0108.

    RUN Lista_Faturas IN h-b1wgen0108
        ( INPUT glb_cdcooper,
          INPUT 0,
          INPUT 0,
          INPUT 1,
          INPUT glb_dtmvtolt,
          INPUT aux_nmendter,
          INPUT par_cdagenci,
          INPUT par_nrdcaixa,
          INPUT par_dtmvtolt,
         OUTPUT aux_nmarqimp,
         OUTPUT aux_nmarqpdf,
         OUTPUT TABLE tt-erro).

    IF VALID-HANDLE(h-b1wgen0108) THEN
       DELETE PROCEDURE h-b1wgen0108.
    
    IF  RETURN-VALUE <> "OK" OR TEMP-TABLE tt-erro:HAS-RECORDS THEN
        DO:
            FIND FIRST tt-erro NO-ERROR.

            IF  AVAILABLE tt-erro THEN
                MESSAGE tt-erro.dscritic.
                   
            RETURN "NOK".  
        END.

    RETURN "OK".

END PROCEDURE. /* Lista_Faturas */

/* ......................................................................... */
