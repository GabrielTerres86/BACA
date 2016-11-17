/*.............................................................................
 Programa: Fontes/CONCST.p
 Sistema : Conta-Corrente - Cooperativa de Credito
 Sigla   : CRED
 Autor   : Fernando
 Data    : MAR/2009                            Ultima alteracao:  12/01/2015

 Dados referentes ao programa:

 Frequencia: Diario (on-line)
 Objetivo  : Consulta custodia.
        
 Alteracoes: 02/06/2009 - Listar cheques da Cooperativa - crapcst.inchqcop = 1
                          (Fernando).
                          
             15/09/2010 - Substituido crapcop.nmrescop por crapcop.dsdircop na 
                          leitura e gravacao dos arquivos (Elton).
                          
             29/05/2014 - Concatena o numero do servidor no endereco do
                          terminal (Tiago-RKAM).
                          
             12/01/2015 - Inclusao de SUBSTR na impressao do nome cooperado
                          junto ao FRAME f_concst. (Jaison - SD: 241518)
                          
............................................................................*/
{ includes/var_online.i }

DEF STREAM str_1.

DEF    VAR   tel_dtinicio  AS DATE   FORMAT "99/99/9999"               NO-UNDO.
DEF    VAR   tel_dttermin  AS DATE   FORMAT "99/99/9999"               NO-UNDO.

DEF    VAR   tel_nrdconta  LIKE crapass.nrdconta                       NO-UNDO.

DEF    VAR   tel_nmdopcao  AS LOG FORMAT "ARQUIVO/IMPRESSAO" INIT TRUE NO-UNDO.

DEF    VAR   tel_nmarquiv  AS CHAR   FORMAT "x(25)"                    NO-UNDO.
DEF    VAR   tel_nmdireto  AS CHAR   FORMAT "x(20)"                    NO-UNDO.

DEF    VAR   aux_nmarqimp  AS CHAR                                     NO-UNDO.
DEF    VAR   aux_confirma  AS CHAR   FORMAT "!(1)"                     NO-UNDO.
DEF    VAR   aux_cddopcao  AS CHAR                                     NO-UNDO.
DEF    VAR   aux_nmprimtl  AS CHAR   FORMAT "x(41)"                    NO-UNDO.

DEF  TEMP-TABLE w-custodia                                             NO-UNDO
     FIELD  cdagenci      LIKE crapage.cdagenci
     FIELD  qtdcustd      AS INT 
     FIELD  ttvalcop      AS DEC
     FIELD  ttvalban      AS DEC
     FIELD  chqcoope      AS INT
     FIELD  chqbanco      AS INT
     FIELD  valtotal      AS DEC.

DEF  QUERY q-custodia FOR w-custodia.

DEF BROWSE  b-custodia QUERY q-custodia 
    DISPLAY w-custodia.cdagenci                                  
            w-custodia.chqcoope LABEL "Quantidade" FORMAT "zzz,zzz"
            w-custodia.ttvalcop LABEL "Valor"      FORMAT "zzz,zzz,zz9.99"
            w-custodia.chqbanco LABEL "Quantidade" FORMAT "zzz,zzz"
            w-custodia.ttvalban LABEL "Valor"      FORMAT "zzz,zzz,zz9.99"
            WITH NO-BOX 5 DOWN.

FORM SPACE (1)
     WITH ROW 4 DOWN WIDTH 80 WITH TITLE glb_tldatela FRAME f_moldura.

FORM SKIP(1)
     "Opcao:"                                                        AT 05
     glb_cddopcao       AT 12 NO-LABEL AUTO-RETURN
                        HELP "Informe a opcao desejada (T ou I)."
                        VALIDATE (glb_cddopcao = "T" OR glb_cddopcao = "I",
                                  "014 - Opcao errada.")

     tel_nrdconta          LABEL "Conta"                             AT 18
     HELP "Informe o numero da conta."
     aux_nmprimtl          NO-LABEL                                  AT 38
     SKIP(1)
     tel_dtinicio          LABEL "Data Inicial"                      AT 05
     HELP "Informe a data incial."
     tel_dttermin          LABEL "Data Final"                        AT 31
     HELP "Informe a data final."
     tel_nmdopcao          LABEL "Saida"
     HELP "(A)rquivo ou (I)mpressao."                                AT 54
     WITH ROW 04 OVERLAY SIDE-LABELS DOWN WIDTH 80
     WITH TITLE glb_tldatela FRAME f_concst.
     
FORM
    w-custodia.qtdcustd LABEL "Qtd. Total" FORMAT "zzz,zzz"          AT 10
    w-custodia.valtotal LABEL "Vl. Total"  FORMAT "zzz,zzz,zz9.99"   AT 36
    WITH ROW 20 CENTERED OVERLAY  NO-BOX SIDE-LABELS WIDTH 70 FRAME f_totais.

FORM
    "Chq. da Cooperativa"                                            AT 14
    "Chq. Outros Bancos"                                             AT 40
    WITH ROW 10 CENTERED OVERLAY NO-BOX SIDE-LABELS WIDTH 70 FRAME f_desc.
    
FORM
    "Diretorio:   "                                                  AT 05
    tel_nmdireto
    tel_nmarquiv        HELP "Informe o nome do arquivo."
    WITH OVERLAY ROW 10 NO-LABEL NO-BOX COLUMN 2 FRAME f_diretorio.

FORM b-custodia HELP "Use as SETAS para navegar ou F4 para sair."    AT 02
    WITH ROW 11 CENTERED OVERLAY WIDTH 63 FRAME f_query.


                       /*** FORMS PARA O RELATORIO 503 ***/

FORM  
    w-custodia.cdagenci                                              
    w-custodia.chqcoope LABEL "Quantidade" FORMAT "zzz,zzz"
    w-custodia.ttvalcop LABEL "Valor"      FORMAT "zzz,zzz,zz9.99"
    w-custodia.chqbanco LABEL "Quantidade" FORMAT "zzz,zzz"
    w-custodia.ttvalban LABEL "Valor"      FORMAT "zzz,zzz,zz9.99"
    w-custodia.qtdcustd LABEL "Qtd. Total" FORMAT "zzz,zzz"
    w-custodia.valtotal LABEL "Vl. Total"  FORMAT "zzz,zzz,zz9.99"
    WITH DOWN COLUMN 20 WIDTH 132 FRAME f_dados.

FORM 
    crapass.nmprimtl       LABEL "Associado"
    SKIP(1)
    tel_dtinicio           LABEL "De"
    tel_dttermin           LABEL "Ate"                               AT 25
    SKIP(2)
    WITH SIDE-LABELS WIDTH 132 FRAME f_dados2.

FORM
    "Chq. da Cooperativa"                                            AT 26
    "Chq. Outros Bancos"                                             AT 55
    "Totais"                                                         AT 85
    WITH ROW 10 SIDE-LABELS WIDTH 132 FRAME f_desc_rel.

ON VALUE-CHANGED OF b-custodia
   DO:
      DISPLAY w-custodia.qtdcustd w-custodia.valtotal WITH FRAME f_totais.
   END.

VIEW FRAME f_moldura.
PAUSE (0).

RUN fontes/inicia.p.

ASSIGN glb_cddopcao = "T".

DO WHILE TRUE:
 
   IF  glb_cdcritic <> 0 THEN
       DO:
          RUN fontes/critic.p.
          MESSAGE glb_dscritic.
          glb_cdcritic = 0.
       END.
   
   EMPTY TEMP-TABLE w-custodia.
   
   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
   
      tel_nmdopcao:VISIBLE IN FRAME f_concst = FALSE.

      UPDATE  glb_cddopcao WITH FRAME f_concst.
      LEAVE.
      
   END.

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN   /***  F4 OU FIM ***/
        DO:
           RUN fontes/novatela.p.
           IF   glb_nmdatela <> "CONCST"   THEN
                DO:
                   HIDE FRAME f_query.
                   HIDE FRAME f_concst NO-PAUSE.
                   RETURN.
                END.
           ELSE
                NEXT.
        END.

   IF   aux_cddopcao <> glb_cddopcao THEN
        DO:
              
            { includes/acesso.i }
            aux_cddopcao = glb_cddopcao.
                       
        END.
    

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
      
      ASSIGN tel_dtinicio = ?
             tel_dttermin = ?.
      
      UPDATE tel_nrdconta WITH FRAME f_concst.
      
      FIND crapass WHERE crapass.cdcooper = glb_cdcooper  AND
                         crapass.nrdconta = tel_nrdconta  NO-LOCK NO-ERROR.
       
      IF   NOT AVAILABLE crapass   THEN
           DO:
              glb_cdcritic = 09.
              LEAVE.
           END.
      
      ASSIGN aux_nmprimtl = SUBSTR(crapass.nmprimtl,1,41).

      DISPLAY aux_nmprimtl WITH FRAME f_concst.
      PAUSE (0).

      UPDATE tel_dtinicio tel_dttermin WITH FRAME f_concst.
      
      IF   glb_cddopcao = "I"   THEN
           UPDATE tel_nmdopcao WITH FRAME f_concst.
       
      IF   tel_dttermin = ?   THEN
           tel_dttermin  = glb_dtmvtolt.
      
   
      MESSAGE "PROCESSANDO...".
   
      FOR EACH crapcst WHERE crapcst.cdcooper  = glb_cdcooper     AND
                             crapcst.dtmvtolt >= tel_dtinicio     AND
                             crapcst.dtmvtolt <= tel_dttermin     AND
                             crapcst.nrdconta  = tel_nrdconta     NO-LOCK 
                             USE-INDEX crapcst1 BREAK BY (crapcst.cdagenci):
        
          IF   FIRST-OF (crapcst.cdagenci)   THEN
               DO:
                  CREATE w-custodia.
                  ASSIGN w-custodia.cdagenci = crapcst.cdagenci
                         w-custodia.qtdcustd = 1
                         w-custodia.valtotal = crapcst.vlcheque.
                         
                  IF   crapcst.inchqcop = 0   THEN
                       ASSIGN w-custodia.chqbanco = 1
                              w-custodia.ttvalban = crapcst.vlcheque.
                  ELSE
                       ASSIGN w-custodia.chqcoope = 1
                              w-custodia.ttvalcop = crapcst.vlcheque.
               END.
          ELSE
               DO:
                  FIND w-custodia WHERE w-custodia.cdagenci = crapcst.cdagenci 
                                        EXCLUSIVE-LOCK NO-ERROR.
               
                  ASSIGN w-custodia.qtdcustd = w-custodia.qtdcustd + 1
                         w-custodia.valtotal = w-custodia.valtotal + 
                                               crapcst.vlcheque.
                                               
                  IF   crapcst.inchqcop = 0   THEN
                       ASSIGN w-custodia.chqbanco = w-custodia.chqbanco + 1
                              w-custodia.ttvalban = w-custodia.ttvalban + 
                                                    crapcst.vlcheque.
                  ELSE
                       ASSIGN w-custodia.chqcoope = w-custodia.chqcoope + 1
                              w-custodia.ttvalcop = w-custodia.ttvalcop +
                                                    crapcst.vlcheque.
               END.
      END.
   
      HIDE MESSAGE NO-PAUSE.
   
      FIND FIRST w-custodia NO-LOCK NO-ERROR. 
   
      IF   NOT AVAILABLE w-custodia  THEN
           DO:
              Message "Nao existem cheques no periodo informado.".
              PAUSE 2 NO-MESSAGE.
           END.
      ELSE  
           DO:
              IF   glb_cddopcao = "T"   THEN
                   DO:
                      OPEN QUERY q-custodia FOR EACH w-custodia NO-LOCK.
                  
                      VIEW FRAME f_desc.
                      
                      DISPLAY w-custodia.qtdcustd w-custodia.valtotal 
                              WITH FRAME f_totais.
                      
                      DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                   
                         UPDATE b-custodia WITH FRAME f_query.
                         LEAVE.                       
 
                      END.
                   END.
              ELSE
                   DO:
                      FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper 
                                         NO-LOCK NO-ERROR.

                      IF   tel_nmdopcao  THEN
                           DO:
                              ASSIGN tel_nmdireto = "/micros/" + 
                                                    crapcop.dsdircop + "/".

                              DISPLAY tel_nmdireto WITH FRAME f_diretorio.
            
                              DO WHILE TRUE ON ENDKEY UNDO, LEAVE:  
                                 
                                 UPDATE tel_nmarquiv WITH FRAME f_diretorio.
                                 LEAVE.

                              END.
                              
                              IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
                                   LEAVE.
                              
                              ASSIGN aux_nmarqimp = tel_nmdireto + tel_nmarquiv.
                           END.
                      ELSE
                           ASSIGN aux_nmarqimp = "rl/crrl503.lst".

                      RUN proc_opcaoi.
                   END.
           END.
      LEAVE.
   END.                
                   
END. /*** fim do DO WHILE TRUE ***/


/*******************************************************************************
                                    PROCEDURES
*******************************************************************************/

PROCEDURE proc_opcaoi:

DEF  VAR aux_dscomand   AS CHAR                                        NO-UNDO.
 
DEF  VAR par_flgrodar   AS LOGICAL    INIT TRUE                        NO-UNDO.
DEF  VAR aux_flgescra   AS LOGICAL                                     NO-UNDO.
DEF  VAR par_flgfirst   AS LOGICAL    INIT TRUE                        NO-UNDO.
DEF  VAR par_flgcance   AS LOGICAL                                     NO-UNDO.
DEF  VAR aux_contador   AS INT                                         NO-UNDO.

DEF  VAR tel_dsimprim   AS CHAR  FORMAT "x(8)" INIT "Imprimir"         NO-UNDO.
DEF  VAR tel_dscancel   AS CHAR  FORMAT "x(8)" INIT "Cancelar"         NO-UNDO.
DEF  VAR tel_nmarquiv   AS CHAR  FORMAT "x(25)"                        NO-UNDO.
DEF  VAR tel_nmdireto   AS CHAR  FORMAT "x(20)"                        NO-UNDO. 
DEF  VAR aux_nmendter   AS CHAR  FORMAT "x(20)"                        NO-UNDO.

DEF   VAR rel_nmresemp   AS CHAR                                       NO-UNDO.
DEF   VAR rel_nmempres   AS CHAR  FORMAT "x(15)"                       NO-UNDO.
DEF   VAR rel_nmrelato   AS CHAR  FORMAT "x(40)" EXTENT 5              NO-UNDO.
DEF   VAR rel_nrmodulo   AS INT   FORMAT "9"                           NO-UNDO.
DEF   VAR rel_nmmodulo   AS CHAR  FORMAT "x(15)" EXTENT 5              NO-UNDO.

 INPUT THROUGH basename `tty` NO-ECHO.
 SET aux_nmendter WITH FRAME f_terminal.
 INPUT CLOSE.
 
 aux_nmendter = substr(glb_hostname,length(glb_hostname) - 1) +
                       aux_nmendter.
 
 /* Inicializa Variaveis Relatorio */
 ASSIGN glb_cdcritic    = 0
        glb_cdrelato[1] = 503
        glb_cdempres    = 11
        glb_nmformul    = "132col"
        rel_nmrelato[1] = "Cheque Custodia".
  
 OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGED PAGE-SIZE 63.

 { includes/cabrel132_1.i }
 
 VIEW STREAM str_1 FRAME f_cabrel132_1.
 
 DISPLAY STREAM str_1  crapass.nmprimtl   tel_dtinicio  
                       tel_dttermin       WITH FRAME f_dados2.
                       
 VIEW STREAM str_1 FRAME f_desc_rel.                      
 
 FOR EACH w-custodia NO-LOCK:
     
     DISPLAY STREAM str_1 w-custodia.cdagenci w-custodia.chqcoope 
                          w-custodia.ttvalcop w-custodia.chqbanco 
                          w-custodia.ttvalban w-custodia.qtdcustd
                          w-custodia.valtotal WITH FRAME f_dados.
                          
     DOWN STREAM str_1 WITH FRAME f_dados.
 END.

 OUTPUT STREAM str_1 CLOSE.
 
 IF   tel_nmdopcao   THEN
      DO:
         UNIX SILENT VALUE("cp " + aux_nmarqimp + " " + aux_nmarqimp + "_copy").
                         
         UNIX SILENT VALUE("ux2dos " + aux_nmarqimp + "_copy" +
                           ' | tr -d "\032" > ' + aux_nmarqimp +
                           " 2>/dev/null").
                                                            
         UNIX SILENT VALUE("rm " + aux_nmarqimp + "_copy").

         MESSAGE "Arquivo gerado com sucesso no diretorio: " + aux_nmarqimp.
         PAUSE 3 NO-MESSAGE.
      END.
 ELSE
     DO:
        RUN confirma.
        IF  aux_confirma = "S"  THEN
            DO:
               ASSIGN  glb_nrcopias = 1
                       glb_nmarqimp = aux_nmarqimp.

                
               FIND FIRST crapass NO-LOCK WHERE                                                          crapass.cdcooper = glb_cdcooper NO-ERROR.

               { includes/impressao.i }
            END.
     END.

END PROCEDURE.

PROCEDURE confirma.

   /* Confirma */
      DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
         ASSIGN aux_confirma = "N"
         glb_cdcritic = 78.
         RUN fontes/critic.p.
         glb_cdcritic = 0.
         MESSAGE COLOR NORMAL glb_dscritic UPDATE aux_confirma.
         LEAVE.
      END.  /*  Fim do DO WHILE TRUE  */
      
     IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   OR   aux_confirma <> "S" THEN
          DO:
             glb_cdcritic = 79.
             RUN fontes/critic.p.
             glb_cdcritic = 0.
             MESSAGE glb_dscritic.
             PAUSE 2 NO-MESSAGE.
          END. /* Mensagem de confirmacao */
                                
END PROCEDURE.
