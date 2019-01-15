/* ..........................................................................

   Programa: Fontes/prcctl_rc.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Guilherme/Supero
   Data    : Maio/2010.                         Ultima atualizacao: 28/08/2015

   Dados referentes ao programa:

   Frequencia: Diario (ON-LINE).
   Objetivo  : Emitir relatorio de lotes de titulos da compensacao
               eletronica (262).
               Exclusivo para CECRED, baseado no COMPEL_R.P
               Detalhe nome: R = Relatorio
                             C = Compel

   Alteracoes: 27/05/2010 - Mostrar nome da cooperativa (Guilherme).

               28/05/2010 - Mostrar indicador de Superior e Inferior ao lado
                            do nome do arquivo e exibir Totais de Inferior e
                            Superior (Guilherme/Supero)

               28/09/2011 - Aplicacao de testes de digitalizacao para cheques
                            da propria cooperativa - Somente Coop. 4 (Ze).
                            
               13/02/2012 - Alteracao para que todas as coops possam digitalizar
                            cheques da propria cooperativa (ZE).
               
               14/08/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).             
                            
               14/05/2014 - Gerar arquivo PDF do relatorio gerado para o 
                            caminho /micros/cecred/. (Tiago/Aline Prj AUT COMP).
                            
               03/06/2014 - Concatena o numero do servidor no endereco do
                            terminal (Tiago-RKAM).
                            
               30/06/2014 - Retirado impressao.i (Tiago/Aline Prj AUT COMP).
               
               01/07/2014 - Incluido parametro para impressao do relatorio
                            (Diego).                   
                            
               07/07/2014 - Alimentar glb_nmrescop quando executado pelo script
                            (Diego).                
               
               28/08/2015 - Incluir criticas no log do prcctl 319730 (Odirlei-AMcom)                    
............................................................................. */

{ includes/var_online.i }

DEF TEMP-TABLE crawage                                                  NO-UNDO
       FIELD  cdcooper      LIKE crapage.cdcooper
       FIELD  cdagenci      LIKE crapage.cdagenci
       FIELD  nmresage      LIKE crapage.nmresage
       FIELD  nmcidade      LIKE crapage.nmcidade
       FIELD  cdbandoc      LIKE crapage.cdbandoc
       FIELD  cdbantit      LIKE crapage.cdbantit
       FIELD  cdagecbn      LIKE crapage.cdagecbn
       FIELD  cdbanchq      LIKE crapage.cdbanchq
       FIELD  cdcomchq      LIKE crapage.cdcomchq.

DEF INPUT PARAM par_cdcooper AS INT                                  NO-UNDO.
DEF INPUT PARAM par_dtmvtolt AS DATE                                 NO-UNDO.
DEF INPUT PARAM par_cdagenci AS INT                                  NO-UNDO.
DEF INPUT PARAM par_cdbccxlt AS INT                                  NO-UNDO.
DEF INPUT PARAM par_nrdolote AS INT                                  NO-UNDO.
DEF INPUT PARAM par_flgcontr AS LOGICAL                              NO-UNDO.
DEF INPUT PARAM TABLE FOR  crawage.    
DEF INPUT PARAM par_flgenvio AS LOGICAL                              NO-UNDO.
DEF INPUT PARAM par_flgenvi2 AS LOGICAL                              NO-UNDO.
DEF INPUT PARAM par_flgimpri AS LOGICAL                              NO-UNDO.

DEF STREAM str_1.
DEF STREAM str_2.

DEF   VAR par_flgrodar AS LOGICAL INIT TRUE                          NO-UNDO.
DEF   VAR par_flgfirst AS LOGICAL INIT TRUE                          NO-UNDO.
DEF   VAR par_flgcance AS LOGICAL                                    NO-UNDO.

DEF   VAR aux_cdagefim LIKE craptvl.cdagenci                         NO-UNDO.
DEF   VAR aux_vlsuper  AS INTE                                       NO-UNDO.
DEF   VAR aux_vlinfer  AS INTE                                       NO-UNDO.
DEF   VAR aux_nmrescop AS CHAR                                       NO-UNDO.
DEF   VAR aux_mes      AS CHAR                                       NO-UNDO.
DEF   VAR aux_dscooper AS CHAR                                       NO-UNDO.
        
DEF   VAR aux_cidadepac AS CHAR EXTENT 99.
DEF   VAR aux_codigopac AS INTE EXTENT 99.

DEF TEMP-TABLE crawpla                                               NO-UNDO
    FIELD cdagenci AS INT     FORMAT "zz9"          
    FIELD vlsuperi AS DEC 
    FIELD vlinferi AS DEC.

DEF TEMP-TABLE crawchd                                               NO-UNDO
    FIELD cdagenci AS INT     FORMAT "zz9"
    FIELD cdbanchq AS INT     FORMAT "zz9" 
    FIELD cdbccxlt AS INT     FORMAT "zz9"
    FIELD nrdolote AS INT     FORMAT "zzz,zz9"
    FIELD tpdmovto AS INT     FORMAT "9"
    FIELD qtchdrec AS INT     FORMAT "zzz,zz9"
    FIELD vlchdrec AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99"
    FIELD nmoperad AS CHAR    FORMAT "x(10)"
    FIELD nmarquiv AS CHAR    FORMAT "x(18)"
    FIELD flgachou AS LOGICAL
    FIELD flginfer AS LOGICAL.
             
DEF        VAR rel_nmresemp AS CHAR    FORMAT "x(15)"                NO-UNDO.
DEF        VAR rel_nmrelato AS CHAR    FORMAT "x(40)" EXTENT 5       NO-UNDO.

DEF        VAR rel_nrmodulo AS INT     FORMAT "9"                    NO-UNDO.
DEF        VAR rel_nmmodulo AS CHAR    FORMAT "x(15)" EXTENT 5
                               INIT ["DEP. A VISTA   ","CAPITAL        ",
                                     "EMPRESTIMOS    ","DIGITACAO      ",
                                     "GENERICO       "]              NO-UNDO.

DEF   VAR pac_dsdtraco AS CHAR    FORMAT "x(80)"                     NO-UNDO.

DEF   VAR pac_qtdlotes AS INT     FORMAT "zzz,zz9"                   NO-UNDO.
DEF   VAR pac_qtchdrec AS INT     FORMAT "zzz,zz9"                   NO-UNDO.
DEF   VAR pac_vlchdrec AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99"        NO-UNDO.

DEF   VAR tot_qtdlotes AS INT     FORMAT "zzz,zz9"                   NO-UNDO.
DEF   VAR tot_qtchdrec AS INT     FORMAT "zzz,zz9"                   NO-UNDO.
DEF   VAR tot_vlchdrec AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99"        NO-UNDO.
DEF   VAR tot_qtchdinf AS INT     FORMAT "zzz,zz9"                   NO-UNDO.
DEF   VAR tot_vlchdinf AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99"        NO-UNDO.
DEF   VAR tot_qtchdsup AS INT     FORMAT "zzz,zz9"                   NO-UNDO.
DEF   VAR tot_vlchdsup AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99"        NO-UNDO.

DEF   VAR tot_dsarquiv AS CHAR    FORMAT "x(30)"                     NO-UNDO.

DEF   VAR lot_nmoperad AS CHAR                                       NO-UNDO.

DEF   VAR tel_dsimprim AS CHAR    FORMAT "x(8)" INIT "Imprimir"      NO-UNDO.
DEF   VAR tel_dscancel AS CHAR    FORMAT "x(8)" INIT "Cancelar"      NO-UNDO.

DEF   VAR aux_flgfirst AS LOGICAL                                    NO-UNDO.
DEF   VAR aux_regexist AS LOGICAL                                    NO-UNDO.
DEF   VAR aux_flgescra AS LOGICAL                                    NO-UNDO.
DEF   VAR aux_flgabert AS LOGICAL                                    NO-UNDO.
DEF   VAR aux_flgregvl AS LOGICAL                                    NO-UNDO.

DEF   VAR aux_contador AS INT                                        NO-UNDO.

DEF   VAR aux_nmendter AS CHAR    FORMAT "x(20)"                     NO-UNDO.
DEF   VAR aux_nmarqimp AS CHAR                                       NO-UNDO.
DEF   VAR aux_nmarqpdf AS CHAR                                       NO-UNDO.
DEF   VAR aux_exarquiv AS CHAR                                       NO-UNDO.
DEF   VAR aux_dscomand AS CHAR                                       NO-UNDO.

DEF   VAR aux_confirma AS CHAR                                       NO-UNDO.
DEF   VAR aux_qtchdrec AS INTE                                       NO-UNDO.
DEF   VAR aux_vlchdrec AS DECIMAL                                    NO-UNDO.

DEF   VAR aux_vlrtotal AS DECIMAL                                    NO-UNDO.
DEF   VAR aux_tot_inf  AS DECIMAL                                    NO-UNDO.
DEF   VAR aux_tot_sup  AS DECIMAL                                    NO-UNDO.
DEF   VAR aux_totvlchq AS DECIMAL                                    NO-UNDO.
DEF   VAR aux_cdseqarq AS INTE                                       NO-UNDO.

DEF BUFFER crabcop FOR crapcop.

DEF   VAR h-b1wgen0024 AS HANDLE                                     NO-UNDO.

FORM par_dtmvtolt  AT   1   LABEL "REFERENCIA"   FORMAT "99/99/9999"
     " - "                                 
     aux_nmrescop       NO-LABEL             FORMAT "x(32)"
     SKIP(1)
     "PA  QTD. CHEQUES"         AT  1
     "VALOR     ARQUIVO"         AT 33       
     SKIP(1)
     WITH SIDE-LABELS NO-BOX WIDTH 132 FRAME f_cab.
      
FORM  crawchd.cdagenci AT  1
      crawchd.qtchdrec AT 11               
      crawchd.vlchdrec AT 20             
      crawchd.flgachou AT 41 FORMAT " /*"
      crawchd.nmarquiv AT 43 
      crawchd.flginfer AT 62 FORMAT "Inferior/Superior"
      WITH NO-LABELS NO-BOX WIDTH 80 FRAME f_lotes.
      
FORM  SKIP(1)
      pac_qtchdrec        AT   11               NO-LABEL
      pac_vlchdrec        AT   20               NO-LABEL
      SKIP
      pac_dsdtraco        AT    1               NO-LABEL 
      WITH NO-LABELS NO-BOX  WIDTH 80 FRAME f_pac.
      
FORM  SKIP(1)
      "GERAL"             AT    1               
      tot_qtchdrec        AT   11               NO-LABEL
      tot_vlchdrec        AT   20               NO-LABEL
      tot_dsarquiv        AT   43               NO-LABEL
      WITH NO-LABELS NO-BOX WIDTH 80 FRAME f_tot.

FORM  SKIP(1)
      "TOTAL SUP"         AT    1               
      tot_qtchdsup        AT   11               NO-LABEL
      tot_vlchdsup        AT   20               NO-LABEL
      SKIP
      "TOTAL INF"         AT    1               
      tot_qtchdinf        AT   11               NO-LABEL
      tot_vlchdinf        AT   20               NO-LABEL
      WITH NO-LABELS NO-BOX WIDTH 80 FRAME f_tot_sup_inf.


FORM SKIP(1)
     "ATENCAO!   Ligue a impressora e posicione o papel!" AT 3
     SKIP(1)
     tel_dsimprim AT 14
     tel_dscancel AT 29
     SKIP(1)
     WITH ROW 14 COLUMN 14 OVERLAY NO-LABELS WIDTH 56
          TITLE glb_nmformul FRAME f_atencao.

FORM SKIP(1)
     WITH NO-BOX FRAME f_linha.

FORM crapchd.nrdconta FORMAT "zzzz,zzz,9"   LABEL "Conta/DV"
     crapchd.nrdocmto FORMAT "zzzzzzzz,zz9" LABEL "Docmto"
     crapchd.cdcmpchq FORMAT "999"          LABEL "Cmp"
     crapchd.cdbanchq FORMAT "999"          LABEL "Bco"
     crapchd.cdagechq FORMAT "9999"         LABEL "Ag."
     crapchd.nrddigv1 FORMAT "Z9"           LABEL "C1"
     crapchd.nrctachq FORMAT "ZZZZZZZZZ9"   LABEL "Conta"
     crapchd.nrddigv2 FORMAT "Z9"           LABEL "C2"
     crapchd.nrcheque FORMAT "999999"       LABEL "Cheque"
     crapchd.nrddigv3 FORMAT "Z9"           LABEL "C3"
     crapchd.vlcheque FORMAT "ZZZZZ,ZZ9.99" LABEL "Valor"
     crapchd.nrseqdig FORMAT "ZZ9"          LABEL "Seq"
     WITH NO-BOX NO-LABELS DOWN FRAME f_lanctos.

/* Bloqueia teclas que cancelam relatorio */
ON "END-ERROR" ANYWHERE DO:
    RETURN NO-APPLY.
END.

/* Busca dados da cooperativa */
FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

IF   NOT AVAILABLE crapcop THEN
     DO:
         glb_cdcritic = 651.
         RUN fontes/critic.p.
         MESSAGE glb_dscritic.
         /* Gerar log da critica */
         RUN gera_log_execucao(par_cdcooper,
                               glb_dscritic).
         RETURN.
     END.

ASSIGN glb_cdcritic    = 0
       glb_nrdevias    = 1
       glb_cdempres    = 11
       glb_cdrelato[1] = 262
       pac_dsdtraco    = FILL("-",80)
       aux_dscooper    = "/usr/coop/" + crapcop.dsdircop + "/"
       glb_nmrescop    = IF   glb_nmrescop = ""  THEN
                              crapcop.nmrescop 
                         ELSE glb_nmrescop .
                         
                          
ASSIGN aux_cdagefim    = IF par_cdagenci = 0  
                         THEN 9999
                         ELSE par_cdagenci.

{ includes/cabrel080_1.i }

aux_nmarqimp = aux_dscooper + "rl/crrl262_" + 
               STRING(glb_cdagenci) + STRING(TIME,"99999") + "_" +
               STRING(crapcop.cdbcoctl,"999") + ".lst".

HIDE MESSAGE NO-PAUSE.

/*  Gerenciamento da impressao  */
INPUT THROUGH basename `tty` NO-ECHO.

SET aux_nmendter WITH FRAME f_terminal.

INPUT CLOSE.

aux_nmendter = substr(glb_hostname,length(glb_hostname) - 1) +
                      aux_nmendter.

UNIX SILENT VALUE("rm " + aux_dscooper + "rl/" + aux_nmendter + "* 2> /dev/null").

MESSAGE "AGUARDE... Gerando relatorio... - COOPERATIVA: "
          CAPS(crapcop.nmrescop).
PAUSE 1 NO-MESSAGE.

OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGED PAGE-SIZE 84.

PUT STREAM str_1 CONTROL "\022\024\033\120" NULL.

PUT STREAM str_1 CONTROL "\0330\033x0" NULL.

VIEW STREAM str_1 FRAME f_cabrel080_1.

DO aux_contador = 1 TO 1:

   EMPTY TEMP-TABLE crawchd.

   EMPTY TEMP-TABLE crawpla.

   FIND craptab WHERE craptab.cdcooper = par_cdcooper  AND
                      craptab.nmsistem = "CRED"        AND
                      craptab.tptabela = "CONFIG"      AND
                      craptab.cdempres = 00            AND
                      craptab.cdacesso = "COMPELBBCH"  AND
                      craptab.tpregist = 000 NO-LOCK NO-ERROR NO-WAIT.

   IF  NOT AVAILABLE craptab   THEN
       DO:
           glb_cdcritic = 393.
           RUN fontes/critic.p.
           /* Gerar log da critica */
           RUN gera_log_execucao(par_cdcooper,
                                 glb_dscritic).
           RETURN.
       END.    

   /*   Valor total na qual o arquivo pode agrupar  */
   ASSIGN aux_vlrtotal = DECIMAL(SUBSTR(craptab.dstextab,01,15))
          aux_totvlchq = 0
          aux_cdseqarq = 1
          aux_qtchdrec = 0
          aux_vlchdrec = 0
          lot_nmoperad = "".

   FIND crabcop WHERE crabcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.
                                   
   IF  AVAIL crabcop  THEN
       aux_nmrescop = crabcop.nmrescop.
   ELSE
       aux_nmrescop = "** COOPERATIVA NAO CADASTRADA **".
   
   FOR EACH crapchd WHERE crapchd.cdcooper  = par_cdcooper       AND
                          crapchd.dtmvtolt  = par_dtmvtolt       AND
                          crapchd.cdagenci >= par_cdagenci       AND
                          crapchd.cdagenci <= aux_cdagefim       AND 
                          CAN-DO("0,2",STRING(crapchd.insitchq)) AND
                        ((crapchd.nrdolote  = par_nrdolote AND
                          par_nrdolote      > 0)                 OR
                         (crapchd.nrdolote  > 0            AND
                          par_nrdolote      = 0))                AND
                         (crapchd.flgenvio  = par_flgenvio OR
                          crapchd.flgenvio  = par_flgenvi2)      NO-LOCK,
       EACH crawage WHERE crawage.cdcooper  = crapchd.cdcooper   AND
                          crawage.cdagenci  = crapchd.cdagenci   AND
                          crawage.cdbanchq  = crapcop.cdbcoctl   NO-LOCK
                          BREAK BY crapchd.tpdmovto
                                BY crapchd.cdagenci:

       IF  crapchd.tpdmovto   = 1  THEN  
           ASSIGN aux_vlsuper = aux_vlsuper + 1.
       ELSE               
           ASSIGN aux_vlinfer = aux_vlinfer + 1.

       ASSIGN aux_qtchdrec = aux_qtchdrec + 1
              aux_totvlchq = aux_totvlchq + crapchd.vlcheque.

       IF  LAST-OF(crapchd.cdagenci)  THEN 
           DO:
               CREATE crawpla.
               ASSIGN crawpla.cdagenci = crapchd.cdagenci
                      crawpla.vlsuperi = aux_vlsuper
                      crawpla.vlinferi = aux_vlinfer.

               ASSIGN aux_vlsuper = 0
                      aux_vlinfer = 0.

               RUN proc_auxiliar_cecred.

               ASSIGN aux_totvlchq = 0
                      aux_qtchdrec = 0.
           END.       

   END. /* Fim do FOR EACH -- Leitura dos cheques acolhidos do dia */

   ASSIGN pac_qtdlotes = 0
          pac_qtchdrec = 0
          pac_vlchdrec = 0 
          tot_qtdlotes = 0 
          tot_qtchdrec = 0
          tot_vlchdrec = 0
          tot_qtchdinf = 0
          tot_vlchdinf = 0
          tot_qtchdsup = 0
          tot_vlchdsup = 0.

   IF   par_nrdolote > 0   THEN
        aux_flgabert = TRUE.
   ELSE
        aux_flgabert = FALSE.

   FOR EACH crawchd BREAK BY crawchd.cdbanchq
                          BY crawchd.cdagenci
                          BY crawchd.cdbccxlt 
                          BY crawchd.nrdolote
                          BY crawchd.tpdmovto:

       IF   FIRST-OF(crawchd.cdbanchq)   THEN
            DISPLAY STREAM str_1 par_dtmvtolt aux_nmrescop WITH FRAME f_cab.

       IF   FIRST-OF(crawchd.cdagenci)   THEN
            DO:
                IF   LINE-COUNTER(str_1) > 70  THEN
                     DO:
                         PAGE STREAM str_1.

                         DISPLAY STREAM str_1
                                 par_dtmvtolt aux_nmrescop WITH FRAME f_cab.
                     END.
            END.

       CLEAR FRAME f_lotes.

       DISPLAY STREAM str_1  
               crawchd.cdagenci  
               crawchd.qtchdrec
               crawchd.vlchdrec 
               WITH FRAME f_lotes.

       IF   par_nrdolote = 0   THEN
            DISPLAY STREAM str_1
                    crawchd.flgachou
                    crawchd.nmarquiv
                    crawchd.flginfer
                    WITH FRAME f_lotes.
       ELSE
            DISPLAY STREAM str_1
                    STRING(par_dtmvtolt,"99/99/9999") + "-" +
                    STRING(par_cdagenci,"999") + "-" +
                    STRING(par_cdbccxlt,"999") + "-" +
                    STRING(par_nrdolote,"999999") @ crawchd.nmarquiv
                    crawchd.flginfer
                    WITH FRAME f_lotes.            

       ASSIGN pac_qtchdrec = pac_qtchdrec + crawchd.qtchdrec
              pac_vlchdrec = pac_vlchdrec + crawchd.vlchdrec
              pac_qtdlotes = pac_qtdlotes + 1.

       IF  crawchd.flginfer THEN
           ASSIGN tot_qtchdinf = tot_qtchdinf + crawchd.qtchdrec
                  tot_vlchdinf = tot_vlchdinf + crawchd.vlchdrec.
       ELSE
           ASSIGN tot_qtchdsup = tot_qtchdsup + crawchd.qtchdrec
                  tot_vlchdsup = tot_vlchdsup + crawchd.vlchdrec.

       DOWN STREAM str_1 WITH FRAME f_lotes.                      

       IF   aux_flgabert   THEN
            DO:
                RUN proc_lista.
                PAGE STREAM str_1.
                DISPLAY STREAM str_1 par_dtmvtolt aux_nmrescop 
                                     WITH FRAME f_cab.
            END.

       IF  LAST-OF(crawchd.cdagenci)   THEN DO:
/*            ASSIGN tot_qtdlotes = tot_qtdlotes + pac_qtdlotes. */
           ASSIGN tot_qtdlotes = tot_qtdlotes + 1.
       END.

       IF   NOT LAST-OF(crawchd.cdagenci)   THEN
            NEXT.

       CLEAR FRAME f_pac.

       DISPLAY STREAM str_1 
               pac_qtchdrec
               pac_vlchdrec
               pac_dsdtraco
               WITH FRAME f_pac.

       IF   LINE-COUNTER(str_1) > 70  THEN
            DO:
                PAGE STREAM str_1.
                       
                DISPLAY STREAM str_1 par_dtmvtolt aux_nmrescop
                                     WITH FRAME f_cab.
            END.

       ASSIGN tot_qtchdrec = tot_qtchdrec + pac_qtchdrec
              tot_vlchdrec = tot_vlchdrec + pac_vlchdrec 

              pac_qtdlotes = 0
              pac_qtchdrec = 0 
              pac_vlchdrec = 0.

       IF   NOT aux_flgabert AND LAST-OF(crawchd.cdbanchq)   THEN
            DO:
                IF   LINE-COUNTER(str_1) > 70  THEN
                     DO:
                         PAGE STREAM str_1.
                     
                         DISPLAY STREAM str_1 par_dtmvtolt aux_nmrescop
                                              WITH FRAME f_cab.
                     END.

                CLEAR FRAME f_tot.

                DISPLAY STREAM str_1 
                               tot_qtchdrec
                               tot_vlchdrec
                               TRIM(STRING(tot_qtdlotes)) + " arquivos" 
                               @ tot_dsarquiv
                               WITH FRAME f_tot.
                
                DISPLAY STREAM str_1 
                               tot_qtchdsup
                               tot_vlchdsup
                               tot_qtchdinf
                               tot_vlchdinf
                               WITH FRAME f_tot_sup_inf.

                ASSIGN tot_qtchdrec = 0
                       tot_vlchdrec = 0
                       tot_qtdlotes = 0.

                IF   LINE-COUNTER(str_1) > 65  THEN
                     PAGE STREAM str_1.

                IF   (par_cdagenci = 0   AND   par_flgcontr) or
                     (par_cdcooper = 2)  or
                     (par_cdcooper = 6)  or
                     (par_cdcooper = 1)  THEN
                     DO:
                         RUN proc_conta_arq.

                         IF   glb_cdcritic = 0   THEN
                              DISPLAY STREAM str_1
                                  SKIP(2)
                                  "                ARQUIVOS TRANSMITIDOS" AT 44
                                  SKIP(5)
                                  "_____________________________________" AT 44
                                  SKIP
                                  "   CADASTRO E VISTO DO FUNCIONARIO   " AT 44
                                  WITH NO-LABELS NO-BOX WIDTH 80 FRAME f_visto.
                     END.

                PAGE STREAM str_1.
            END.

   END.  /* FOR EACH crawchd */

   glb_cdcritic = 0.

   PAGE STREAM str_1.

END.  /* Fim do DO .. TO  */

PUT STREAM str_1 CONTROL "\022\024\033\120" NULL.

PUT STREAM str_1 CONTROL "\0330\033x0" NULL.

OUTPUT  STREAM str_1 CLOSE.

/*** copiar arquivo para o diretorio 'rlnsv' ***/
UNIX SILENT VALUE("cp " + aux_nmarqimp + " " + aux_dscooper + "rlnsv/" +
                  SUBSTRING(aux_nmarqimp,R-INDEX(aux_nmarqimp,"/") + 1,
                  LENGTH(aux_nmarqimp) - R-INDEX(aux_nmarqimp,"/"))).

IF   par_flgimpri THEN /* Efetua impressao pela PRCCTL */  
     DO:
         ASSIGN glb_nmformul = ""
                glb_nrcopias = 1
                glb_nmarqimp = aux_nmarqimp.

         FIND FIRST crapass 
              WHERE crapass.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

         { includes/impressao.i }

         HIDE MESSAGE NO-PAUSE.

         IF   NOT par_flgcance   THEN
              MESSAGE "Retire o relatorio da impressora!".
         ELSE
              MESSAGE "Impressao cancelada!".
     END.
ELSE      /* Gera PDF no CRPS662 */ 
     DO:

         /* Instancia a BO */
         RUN sistema/generico/procedures/b1wgen0024.p 
             PERSISTENT SET h-b1wgen0024.

         IF   NOT VALID-HANDLE(h-b1wgen0024)  THEN
              DO:
                glb_nmdatela = "PRCCTL".
                ASSIGN glb_dscritic = "Handle invalido para BO b1wgen0024.".
                RUN gera_critica_procbatch.
                RETURN "NOK".
              END.

         UNIX SILENT VALUE("rm /micros/cecred/compel/crrl262_" + 
                           STRING(crapcop.cdagectl,"9999") + 
                           "* 2> /dev/null").

         ASSIGN aux_nmarqpdf = "/micros/cecred/compel/crrl262_" + 
                               STRING(crapcop.cdagectl,"9999") + "_" + 
                               STRING(glb_cdagenci) + STRING(TIME,"99999") + 
                               "_" + STRING(crapcop.cdbcoctl,"999") + ".pdf".

         /* GERAR PDF */
         RUN gera-pdf-impressao IN h-b1wgen0024(INPUT aux_nmarqimp,
                                                INPUT aux_nmarqpdf).

         DELETE PROCEDURE h-b1wgen0024.
     END.
     
IF  crapcop.cdcooper = 1 THEN /* Viacredi */
    RUN gera_planilha.

/* .......................................................................... */

PROCEDURE proc_auxiliar_cecred:

    FIND crapage WHERE crapage.cdcooper = par_cdcooper     AND
                       crapage.cdagenci = crapchd.cdagenci 
                       NO-LOCK NO-ERROR NO-WAIT.
       
    IF   NOT AVAILABLE crapage THEN
         DO:
             glb_cdcritic = 015.
             RUN fontes/critic.p.
             BELL.
             MESSAGE glb_dscritic.
             /* Gerar log da critica */
             RUN gera_log_execucao(par_cdcooper,
                                   glb_dscritic).

             LEAVE.
         END.
         
    IF   crapchd.tpdmovto = 1   THEN
         ASSIGN aux_exarquiv = "1_sup".
    ELSE
         ASSIGN aux_exarquiv = "2_inf".
            
    IF   MONTH(par_dtmvtolt) > 9 THEN
         CASE MONTH(par_dtmvtolt):
              WHEN 10 THEN aux_mes = "O".
              WHEN 11 THEN aux_mes = "N".
              WHEN 12 THEN aux_mes = "D".
         END CASE.
    ELSE aux_mes = STRING(MONTH(par_dtmvtolt),"9").

    CREATE crawchd.

    ASSIGN crawchd.cdagenci = crapchd.cdagenci
           crawchd.cdbanchq = crapage.cdbanchq
           crawchd.cdbccxlt = crapchd.cdbccxlt
           crawchd.nrdolote = crapchd.nrdolote
           crawchd.tpdmovto = crapchd.tpdmovto
           crawchd.qtchdrec = aux_qtchdrec
           crawchd.vlchdrec = aux_totvlchq
           crawchd.nmoperad = lot_nmoperad
           crawchd.flginfer = IF   crapchd.tpdmovto = 1   THEN FALSE ELSE TRUE 
           crawchd.nmarquiv = IF   crapage.cdbanchq = crapcop.cdbcoctl THEN
                                   "1" +
                                   STRING(crapcop.cdagectl,"9999") + 
                                   STRING(aux_mes,"x(1)") +
                                   STRING(DAY(par_dtmvtolt),"99") + "." +
                                   STRING(crapchd.cdagenci,"999")
                              ELSE "".

       IF   crapage.cdbanchq = crapcop.cdbcoctl THEN
            crawchd.flgachou = IF SEARCH("/micros/" + crapcop.dsdircop +
                                         "/abbc/" + crawchd.nmarquiv) <> ?
                                         THEN TRUE
                                         ELSE FALSE.
END PROCEDURE.
/* FIM proc_auxiliar_cecred */

PROCEDURE proc_conta_arq:
    
    DEF VAR aux_qtarquiv AS INT NO-UNDO.

    IF   glb_dtmvtolt <> par_dtmvtolt   THEN
         RETURN.
    
    INPUT STREAM str_2 THROUGH VALUE("ll /micros/" + crapcop.dsdircop +
                                     "/abbc/1" + 
                                     STRING(crapcop.cdagectl,"9999") + 
                                     STRING(aux_mes,"x(1)") +
                                     STRING(DAY(par_dtmvtolt),"99") + "." +
                                     STRING(crawchd.cdagenci,"999") +
                                     " 2>/dev/null | " +
                                     "wc -l 2>/dev/null") NO-ECHO.

    DO WHILE TRUE ON ERROR UNDO, LEAVE ON ENDKEY UNDO, LEAVE:

       SET STREAM str_2
           aux_qtarquiv WITH NO-BOX NO-LABELS FRAME f_cbe.

    END.  /*  Fim do DO WHILE TRUE  */

    INPUT STREAM str_2 CLOSE.

END PROCEDURE.

PROCEDURE proc_lista:

    VIEW STREAM str_1 FRAME f_linha.
    
    FOR EACH crapchd WHERE crapchd.cdcooper = par_cdcooper       AND
                           crapchd.dtmvtolt = par_dtmvtolt       AND
                           crapchd.cdagenci = crawchd.cdagenci   AND
                           crapchd.cdbccxlt = crawchd.cdbccxlt   AND
                           crapchd.nrdolote = crawchd.nrdolote   AND
                          (crapchd.flgenvio = par_flgenvio OR
                           crapchd.flgenvio = par_flgenvi2)
                           USE-INDEX crapchd3 NO-LOCK
                           BY crapchd.nrseqdig:
        
        ASSIGN aux_regexist = TRUE.
        
        DISPLAY STREAM str_1 
                crapchd.nrdconta
                crapchd.nrdocmto
                crapchd.cdcmpchq
                crapchd.cdbanchq
                crapchd.cdagechq
                crapchd.nrddigv1
                crapchd.nrctachq
                crapchd.nrddigv2
                crapchd.nrcheque
                crapchd.nrddigv3
                crapchd.vlcheque
                crapchd.nrseqdig
                WITH FRAME f_lanctos.

        DOWN STREAM str_1 WITH FRAME f_lanctos.

        IF   LINE-COUNTER(str_1) > 70  THEN
             DO:
                 PAGE STREAM str_1.
                        
                 DISPLAY STREAM str_1 par_dtmvtolt aux_nmrescop
                                      WITH FRAME f_cab.
            
                 DISPLAY STREAM str_1  
                         crawchd.cdagenci  crawchd.qtchdrec
                         crawchd.vlchdrec  crawchd.flgachou  
                         crawchd.nmarquiv  crawchd.flginfer
                         WITH FRAME f_lotes.
                 
                 VIEW STREAM str_1 FRAME f_linha.
             END.

    END.  /*  Fim do FOR EACH  */
    
    VIEW STREAM str_1 FRAME f_linha.
    
END PROCEDURE.

PROCEDURE gera_planilha:

    RUN inicializa_tabela.

    ASSIGN aux_nmarqimp = "/micros/" + crapcop.dsdircop + "/planilha/" +
                          STRING(DAY(glb_dtmvtolt),"99")    + 
                          STRING(MONTH(glb_dtmvtolt),"99")  + 
                          STRING(YEAR(glb_dtmvtolt),"9999") + 
                          STRING(crapcop.cdbcoctl,"999") +
                          ".txt".

    OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp).

    FOR EACH crawpla NO-LOCK BREAK BY crawpla.cdagenci:
        ASSIGN aux_vlrtotal = crawpla.vlsuperi + crawpla.vlinferi
               aux_tot_inf  = aux_tot_inf      + crawpla.vlinferi
               aux_tot_sup  = aux_tot_sup      + crawpla.vlsuperi.
        
        PUT STREAM str_1         
            aux_cidadepac[crawpla.cdagenci] format "x(35)"
            ";"
            aux_codigopac[crawpla.cdagenci] format "zzz9"
            ";"
            crawpla.cdagenci format "zz9"
            ";"
            crawpla.vlinferi
            ";"
            crawpla.vlsuperi
            ";"
            aux_vlrtotal  SKIP.
    END.
        
    PUT STREAM str_1         
            "TOTAL "
            ";"
            " "
            ";"
            " "
            ";"
            aux_tot_inf
            ";"
            aux_tot_sup
            ";"
            " "  SKIP.

    OUTPUT  STREAM str_1 CLOSE.

END PROCEDURE.

PROCEDURE inicializa_tabela:

    ASSIGN aux_cidadepac[1]  = "BLUMENAU - SC"
           aux_codigopac[1]  = 3420
           aux_cidadepac[2]  = "BLUMENAU - SC"
           aux_codigopac[2]  = 2999
           aux_cidadepac[3]  = "BLUMENAU - SC"
           aux_codigopac[3]  = 2999
           aux_cidadepac[8]  = "BLUMENAU - SC"
           aux_codigopac[8]  = 3154
           aux_cidadepac[17] = "BLUMENAU - SC"
           aux_codigopac[17] = 3126
           aux_cidadepac[19] = "BLUMENAU - SC"
           aux_codigopac[19] = 3420
        
           aux_cidadepac[4]  = "INDAIAL - SC"
           aux_codigopac[4]  = 928
           aux_cidadepac[18] = "INDAIAL - SC"
           aux_codigopac[18] = 928

           aux_cidadepac[5]  = "RODEIO - SC"
           aux_codigopac[5]  = 2549
           aux_cidadepac[20] = "RODEIO - SC"
           aux_codigopac[20] = 2549

           aux_cidadepac[7]  = "IBIRAMA - SC"
           aux_codigopac[7]  = 96

           aux_cidadepac[9]  = "GASPAR - SC"
           aux_codigopac[9]  = 921
           aux_cidadepac[22] = "GASPAR - SC"
           aux_codigopac[22]  = 921

           aux_cidadepac[14] = "JARAGUA DO SUL - SC"
           aux_codigopac[14] = 405
           aux_cidadepac[21] = "JARAGUA DO SUL - SC"
           aux_codigopac[21] = 405

           aux_cidadepac[15] = "ITAJAI - SC"
           aux_codigopac[15] = 305.

END PROCEDURE.

/* LOG de execuaco dos programas */
PROCEDURE gera_log_execucao:
    
    DEF INPUT PARAM par_cdcooper    AS  INT         NO-UNDO.
    DEF INPUT PARAM par_dscritic    AS  CHAR        NO-UNDO.
    
    DEF VAR aux_nmarqlog            AS  CHAR        NO-UNDO.

    ASSIGN aux_nmarqlog = "/usr/coop/cecred/log/prcctl_" +
                          STRING(YEAR(glb_dtmvtolt),"9999") +
                          STRING(MONTH(glb_dtmvtolt),"99") +
                          STRING(DAY(glb_dtmvtolt),"99") + ".log".
    
    UNIX SILENT VALUE("echo prcctl_rc - " + 
                      STRING(TIME,"HH:MM:SS") + "' --> '"  +
                      "Coop.:" + STRING(par_cdcooper) + " - " +  
                      par_dscritic +  
                      " >> " + aux_nmarqlog).

    RETURN "OK".  
END PROCEDURE.


/* .......................................................................... */
