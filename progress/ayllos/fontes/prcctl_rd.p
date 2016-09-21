/* ..........................................................................

   Programa: Fontes/prcctl_rd.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Guilherme/Supero
   Data    : Maio/2010.                         Ultima atualizacao: 15/09/2014

   Dados referentes ao programa:

   Frequencia: Diario (ON-LINE).
   Objetivo  : Emitir relatorio dos DOC'S que foram p/Banco Brasil no dia (326).
               Exclusivo para CECRED, baseado no DOCTOS_R.P
               Detalhe nome: R = Relatorio
                             D = Doctos

   Alteracoes: 27/05/2010 - Mostrar nome cooperativa (Guilherme).

               28/05/2010 - Corrigida a extensao do arquivo. Atribuia extensao
                            para o arquivo a cada banco, sendo o correto, por
                            agencia. (Guilherme/Supero)
                            
               06/09/2013 - Nova forma de chamar as agências, de PAC agora 
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
               
               15/09/2014 - Alteração da Nomeclatura para PA (Vanessa).             
                                      
............................................................................. */

{ includes/var_online.i }

DEFINE TEMP-TABLE crattem                                               NO-UNDO
       FIELD cdseqarq AS INTEGER
       FIELD nrdolote AS INTEGER
       FIELD cddbanco AS INTEGER
       FIELD nrrectit AS RECID
       INDEX crattem1 cdseqarq nrdolote.

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

DEFINE TEMP-TABLE crattot                                               NO-UNDO
       FIELD cdagenci LIKE crapage.cdagenci
       FIELD cdbandoc LIKE crapage.cdbandoc
       FIELD dsbancmp AS CHAR    FORMAT "x(15)"
       FIELD qtdoctos AS INTEGER FORMAT "zzz9"
       FIELD vldoctos AS DECIMAL FORMAT "zzz,zzz,zz9.99"
       FIELD nrdocmto LIKE craptvl.nrdocmto.

DEF STREAM str_1.

DEF INPUT PARAM par_cdcooper AS INT                                  NO-UNDO.
DEF INPUT PARAM par_dtmvtolt AS DATE                                 NO-UNDO.
DEF INPUT PARAM par_cdagenci AS INT                                  NO-UNDO.
DEF INPUT PARAM par_flgenvio AS LOGICAL                              NO-UNDO.
DEF INPUT PARAM par_ted_doc  AS CHAR                                 NO-UNDO.
DEF INPUT PARAM par_recid    AS RECID                                NO-UNDO.
DEF INPUT PARAM TABLE FOR crawage.    
DEF INPUT PARAM par_flgimpri AS LOGICAL                              NO-UNDO.

DEF VAR par_flgrodar AS LOGICAL INIT TRUE                            NO-UNDO.
DEF VAR par_flgfirst AS LOGICAL INIT TRUE                            NO-UNDO.
DEF VAR par_flgcance AS LOGICAL                                      NO-UNDO.

DEF   VAR rel_nmempres     AS CHAR    FORMAT "x(15)"                 NO-UNDO.
DEF   VAR rel_nmrelato     AS CHAR    FORMAT "x(40)" EXTENT 5        NO-UNDO.

DEF   VAR rel_nrmodulo AS INT     FORMAT "9"                         NO-UNDO.
DEF   VAR rel_nmmodulo AS CHAR    FORMAT "x(15)" EXTENT 5
                               INIT ["DEP. A VISTA   ","CAPITAL        ",
                                     "EMPRESTIMOS    ","DIGITACAO      ",
                                     "GENERICO       "]              NO-UNDO.

DEF   VAR rel_nmmesano AS CHAR    FORMAT "x(09)"                     NO-UNDO.
DEF   VAR rel_dsbancmp AS CHAR    FORMAT "x(15)"                     NO-UNDO.

DEF   VAR res_nrctremp AS INT                                        NO-UNDO.
DEF   VAR res_dslinhas AS CHAR                                       NO-UNDO.

DEF   VAR tel_dsimprim AS CHAR    FORMAT "x(8)" INIT "Imprimir"      NO-UNDO.
DEF   VAR tel_dscancel AS CHAR    FORMAT "x(8)" INIT "Cancelar"      NO-UNDO.

DEF   VAR aux_nrdocmto LIKE craptvl.nrdocmto                         NO-UNDO.
DEF   VAR aux_extensao AS CHAR                                       NO-UNDO.
DEF   VAR aux_cdagefim LIKE craptvl.cdagenci                         NO-UNDO.
DEF   VAR aux_flgescra AS LOGICAL                                    NO-UNDO.
DEF   VAR aux_dscomand AS CHAR                                       NO-UNDO.
DEF   VAR aux_contador AS INT                                        NO-UNDO.
DEF   VAR aux_nmendter AS CHAR    FORMAT "x(20)"                     NO-UNDO.
DEF   VAR aux_nmarqimp AS CHAR                                       NO-UNDO.
DEF   VAR aux_nmarqpdf AS CHAR                                       NO-UNDO.
DEF   VAR aux_tpdoctrf AS CHAR                                       NO-UNDO.
DEF   VAR aux_nmoperad AS CHAR                                       NO-UNDO.
DEF   VAR aux_nmprimtl LIKE crapass.nmprimtl                         NO-UNDO.
DEF   VAR aux_nrcpfcgc AS CHAR  FORMAT "x(25)"                       NO-UNDO.
DEF   VAR aux_cpfcgrcb AS CHAR  FORMAT "x(25)"                       NO-UNDO.

DEF   VAR aux_cdfinrcb AS CHAR   FORMAT "x(34)"                      NO-UNDO.
DEF   VAR aux_tpdctacr AS CHAR   FORMAT "x(29)"                      NO-UNDO.
DEF   VAR aux_tpdctadb AS CHAR   FORMAT "x(29)"                      NO-UNDO.
DEF   VAR aux_cdacesso AS CHAR                                       NO-UNDO.

DEF   VAR aux_qtdoctos   AS INTE FORMAT "zzzz9"                      NO-UNDO.
DEF   VAR aux_qtdoctos_g AS INTE FORMAT "zzzz9"                      NO-UNDO.
DEF   VAR aux_vldoctos   AS DEC  FORMAT "zzz,zzz,zz9.99"             NO-UNDO.
DEF   VAR aux_vldoctos_g AS DEC  FORMAT "zzz,zzz,zz9.99"             NO-UNDO.
DEF   VAR aux_descricao  AS CHAR FORMAT "x(20)"                      NO-UNDO.

DEF   VAR aux_cdseqarq   AS INTE                                     NO-UNDO.
DEF   VAR aux_nrdolote   AS INTE                                     NO-UNDO.
DEF   VAR aux_qtdade     AS INTE FORMAT "zzz,zz9"                    NO-UNDO.
DEF   VAR aux_valor      AS DEC  FORMAT "zzzz,zzz,zz9.99"            NO-UNDO.
DEF   VAR aux_nmarquiv   AS CHAR FORMAT "x(24)"                      NO-UNDO.
DEF   VAR aux_mes        AS CHAR                                     NO-UNDO.
DEF   VAR aux_nmrescop   AS CHAR                                     NO-UNDO.
DEF   VAR aux_dscooper   AS CHAR                                     NO-UNDO.

DEF   VAR pac_dsdtraco AS CHAR    FORMAT "x(77)"                     NO-UNDO.

DEF   VAR pac_qtdarqui AS INT     FORMAT "zzz,zz9"                   NO-UNDO.
DEF   VAR pac_qtdoctos AS INT     FORMAT "zzz,zz9"                   NO-UNDO.
DEF   VAR pac_vldoctos AS DECIMAL FORMAT "zzzz,zzz,zz9.99"           NO-UNDO.

DEF   VAR pac_geral_qtdarqui AS INT     FORMAT "zzz,zz9"             NO-UNDO.
DEF   VAR pac_geral_qtdoctos AS INT     FORMAT "zzz,zz9"             NO-UNDO.
DEF   VAR pac_geral_vldoctos AS DECIMAL FORMAT "zzzz,zzz,zz9.99"     NO-UNDO.

DEF BUFFER crabcop FOR crapcop.

DEF   VAR h-b1wgen0024 AS HANDLE                                     NO-UNDO.

FORM rel_dsbancmp  AT   1   LABEL "--> BANCO COMPENSACAO"   FORMAT "x(15)"
     SKIP(1)
     par_dtmvtolt  AT   1   LABEL "REFERENCIA"              FORMAT "99/99/9999"
     " - "                                 
     aux_nmrescop           NO-LABEL                        FORMAT "x(32)"     
     SKIP(1)
     "PA      LOTE  OPERADOR         DOCTO       VALOR  TIPO_DOC"
     "  FINALIDADE                                CONTA CREDITO" 
     SKIP
     "               BCO  AGE   CONTA CC" 
     "NOME                                      CPF/CGC"
     "                  CONTA DEBITO"      
     SKIP(1)
     WITH SIDE-LABELS NO-BOX WIDTH 132 FRAME f_cab.
      
FORM SKIP(1)
     "ATENCAO!   Ligue a impressora e posicione o papel!" AT 3
     SKIP(1)
     tel_dsimprim AT 14
     tel_dscancel AT 29
     SKIP(1)
     WITH ROW 14 COLUMN 14 OVERLAY NO-LABELS WIDTH 56
          TITLE glb_nmformul FRAME f_atencao.

FORM SKIP(1)
     WITH NO-BOX FRAME f_linha WIDTH 132.
    
FORM craptvl.cdagenci
     SPACE(2)
     craptvl.nrdolote
     SPACE(2)
     aux_nmoperad     FORMAT "x(10)"
     SPACE(2)
     craptvl.nrdocmto
     SPACE(2)
     craptvl.vldocrcb FORMAT "zzz,zz9.99"
     SPACE(2)
     aux_tpdoctrf     FORMAT "x(04)"
     SPACE(7)
     aux_cdfinrcb     
     SPACE(8)
     aux_tpdctacr     
     WITH NO-BOX NO-LABELS DOWN FRAME f_lanctos WIDTH 132.

FORM "Remetente...:"    AT 1
     "    "             AT 14
     craptvl.cdagenci   AT 18 FORMAT "ZZZ9"
     craptvl.nrdconta   FORMAT "ZZZZZZZ,ZZZ,9"
     aux_nmprimtl       FORMAT "X(40)"
     aux_nrcpfcgc
     aux_tpdctadb        
     SKIP
     "Destinatario:"    AT 1
     craptvl.cdbccrcb   AT 14
     craptvl.cdagercb   AT 18 FORMAT "ZZZ9"
     craptvl.nrcctrcb   FORMAT "ZZZZZZZZZZZ9"
     craptvl.nmpesrcb   FORMAT "X(40)"
     aux_cpfcgrcb
     WITH NO-BOX NO-LABELS DOWN FRAME f_dados WIDTH 132.

FORM  SKIP(1)
      aux_descricao                 AT    1   FORMAT "x(27)"              
      "Qtdade "                     AT   31 
      aux_qtdoctos                  AT   38   
      "Valor  "                     AT   55 
      aux_vldoctos                  AT   66     
      WITH NO-LABELS NO-BOX WIDTH 132 FRAME f_total.

FORM rel_dsbancmp  AT   1   LABEL "--> BANCO COMPENSACAO"   FORMAT "x(15)"
     SKIP(1)
     par_dtmvtolt  AT   1   LABEL "REFERENCIA"              FORMAT "99/99/9999"
     " - "                                 
     aux_nmrescop           NO-LABEL                        FORMAT "x(32)"     
     SKIP(1)
     "PA    QTD. DOCTOS "       AT  1
     "VALOR   ARQUIVO"           AT 35       
     SKIP(1)
     WITH SIDE-LABELS NO-BOX WIDTH 132 FRAME f_cab_doctos.

FORM  pac_dsdtraco        AT    1               NO-LABEL 
      SKIP
      "TOTAL "            AT    1               
      pac_qtdoctos        AT   11               NO-LABEL
      pac_vldoctos        AT   26               NO-LABEL
      pac_qtdarqui        AT   45
      "Arquivos"          AT   55               
      SKIP(3)
      WITH NO-LABELS NO-BOX  WIDTH 80 FRAME f_tot_doctos.  
 
FORM  pac_dsdtraco        AT    1               NO-LABEL 
      SKIP
      "GERAL"             AT    1               
      pac_geral_qtdoctos  AT   11               NO-LABEL
      pac_geral_vldoctos  AT   26               NO-LABEL
      pac_geral_qtdarqui  AT   45
      "Arquivos"          AT   55               
      SKIP(3)
      WITH NO-LABELS NO-BOX  WIDTH 80 FRAME f_tot_geral_doctos.  
 
FORM  craptvl.cdagenci AT  1               
      aux_qtdade       AT 11               
      aux_valor        AT 26             
      aux_nmarquiv     AT 45           
      WITH NO-LABELS NO-BOX WIDTH 80 FRAME f_doctos.

/* inibe F4 */
ON "f4" ANYWHERE DO:
    RETURN NO-APPLY.
END.

/* Busca dados da cooperativa */
FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

IF   NOT AVAILABLE crapcop THEN
     DO:
         glb_cdcritic = 651.
         RUN fontes/critic.p.
         MESSAGE glb_dscritic.
         RETURN.
     END.

ASSIGN glb_cdcritic    = 0
       glb_nrdevias    = 1
       glb_cdempres    = 11
       glb_cdrelato[1] = 326
       aux_dscooper    = "/usr/coop/" + crapcop.dsdircop + "/"
       aux_cdagefim    = IF   par_cdagenci = 0  THEN 
                              9999
                         ELSE 
                              par_cdagenci
       glb_nmrescop    = IF   glb_nmrescop = ""  THEN
                              crapcop.nmrescop 
                         ELSE glb_nmrescop .

{ includes/cabrel132_1.i }

aux_nmarqimp = aux_dscooper + "rl/O326_" + STRING(TIME,"99999") + "_" +
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

PUT STREAM str_1 CONTROL "\0330\033x0\033\017" NULL.

VIEW STREAM str_1 FRAME f_cabrel132_1.

FIND crabcop WHERE crabcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.
                                   
IF  AVAIL crabcop  THEN
    aux_nmrescop = crabcop.nmrescop.
ELSE
    aux_nmrescop = "** COOPERATIVA NAO CADASTRADA **".

IF  par_ted_doc = "D" THEN
    DO:
       FOR EACH craptvl WHERE craptvl.cdcooper  = par_cdcooper     AND
                              craptvl.dtmvtolt  = par_dtmvtolt     AND
                              craptvl.cdagenci >= par_cdagenci     AND
                              craptvl.cdagenci <= aux_cdagefim     AND
                              craptvl.tpdoctrf <> 3                AND
                              craptvl.flgenvio  = par_flgenvio     NO-LOCK,
           EACH crawage WHERE crawage.cdcooper  = craptvl.cdcooper
                          AND crawage.cdagenci  = craptvl.cdagenci 
                          AND crawage.cdbandoc  = crapcop.cdbcoctl NO-LOCK
                              BREAK BY crawage.cdbandoc 
                                    BY craptvl.cdagenci
                                    BY craptvl.cdbccrcb:
            
           IF   FIRST-OF(crawage.cdbandoc)  THEN
                ASSIGN aux_qtdoctos   = 0
                       aux_qtdoctos_g = 0
                       aux_vldoctos   = 0
                       aux_vldoctos_g = 0
                       rel_dsbancmp   = "CECRED".
                       
           IF   FIRST-OF(craptvl.cdagenci)  THEN
                DO:
                    ASSIGN aux_nrdocmto = craptvl.nrdocmto.
                END.
                
           RUN lista_craptvl.

           ASSIGN aux_qtdoctos   = aux_qtdoctos   + 1
                  aux_qtdoctos_g = aux_qtdoctos_g + 1
                  aux_vldoctos   = aux_vldoctos   + craptvl.vldocrcb 
                  aux_vldoctos_g = aux_vldoctos_g + craptvl.vldocrcb.
           
           IF   LAST-OF(craptvl.cdagenci)  THEN
                DO:
                    CREATE crattot.
                    ASSIGN crattot.cdagenci = craptvl.cdagenci
                           crattot.cdbandoc = crawage.cdbandoc
                           crattot.dsbancmp = rel_dsbancmp
                           crattot.qtdoctos = aux_qtdoctos
                           crattot.vldoctos = aux_vldoctos
                           crattot.nrdocmto = aux_nrdocmto.
                    
                    ASSIGN aux_qtdoctos = 0
                           aux_vldoctos = 0
                           aux_nrdocmto = 0.
                END.
       
       END. /* Fim do FOR EACH */

       FOR EACH crattot NO-LOCK BREAK BY crattot.cdbandoc:
       
           IF   FIRST-OF(crattot.cdbandoc)  THEN
                ASSIGN aux_descricao = "TOTAL GERAL " + aux_nmrescop
                       aux_qtdoctos  = 0
                       aux_vldoctos  = 0.
                
           ASSIGN aux_qtdoctos = aux_qtdoctos + crattot.qtdoctos
                  aux_vldoctos = aux_vldoctos + crattot.vldoctos.

       END. /* Fim do FOR EACH */
 
       RUN finaliza_impressao.
    END.
ELSE
    DO:
       FOR EACH craptvl WHERE craptvl.cdcooper  = par_cdcooper   AND
                              craptvl.dtmvtolt  = par_dtmvtolt   AND
                              craptvl.cdagenci >= par_cdagenci   AND
                              craptvl.cdagenci <= aux_cdagefim   AND
                              craptvl.tpdoctrf  = 3              AND
                              craptvl.flgenvio = par_flgenvio    NO-LOCK
                              BREAK BY craptvl.cdagenci
                                    BY craptvl.cdbccrcb:

           RUN lista_craptvl.
       
           ASSIGN aux_qtdoctos   = aux_qtdoctos   + 1
                  aux_qtdoctos_g = aux_qtdoctos_g + 1
                  aux_vldoctos   = aux_vldoctos   + craptvl.vldocrcb 
                  aux_vldoctos_g = aux_vldoctos_g + craptvl.vldocrcb.

       END. /* Fim do FOR EACH */
 
       RUN finaliza_impressao.
    END.

/* .......................................................................... */

PROCEDURE lista_craptvl:

    ASSIGN aux_nmoperad = "**********"
           aux_nmprimtl = FILL("*",40)
           aux_nrcpfcgc = ""
           aux_cpfcgrcb = ""
           aux_tpdoctrf = IF   craptvl.tpdoctrf = 1  THEN
                               "DOC C"
                          ELSE
                          IF   craptvl.tpdoctrf = 2  THEN
                               "DOC D"
                          ELSE "TED".
    
    FIND craplot WHERE craplot.cdcooper = par_cdcooper       AND
                       craplot.dtmvtolt = craptvl.dtmvtolt   AND
                       craplot.cdagenci = craptvl.cdagenci   AND
                       craplot.cdbccxlt = craptvl.cdbccxlt   AND
                       craplot.nrdolote = craptvl.nrdolote   NO-LOCK NO-ERROR.
                       
    IF   AVAILABLE craplot   THEN                   
         DO:
             FIND crapope WHERE crapope.cdcooper = par_cdcooper     AND
                                crapope.cdoperad = craplot.cdoperad
                                NO-LOCK NO-ERROR.

             ASSIGN aux_nmoperad = IF   AVAILABLE crapope  THEN 
                                        crapope.nmoperad
                                   ELSE 
                                        "Nao cadas".
         END.

    FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                       crapass.nrdconta = craptvl.nrdconta NO-LOCK NO-ERROR.
                       
    IF   AVAILABLE crapass   THEN
         DO:
             ASSIGN aux_nmprimtl = crapass.nmprimtl.
             
             IF   crapass.inpessoa = 1 THEN
                  ASSIGN aux_nrcpfcgc = STRING(crapass.nrcpfcgc,"99999999999")
                         aux_nrcpfcgc = 
                             STRING(aux_nrcpfcgc,"    xxx.xxx.xxx-xx").
             ELSE
                  ASSIGN aux_nrcpfcgc = 
                             STRING(crapass.nrcpfcgc,"99999999999999")
                         aux_nrcpfcgc = 
                             STRING(aux_nrcpfcgc,"xx.xxx.xxx/xxxx-xx").
         END.                    
    ELSE
         DO:
             ASSIGN aux_nmprimtl = craptvl.nmpesemi.
             
             IF   LENGTH(STRING(craptvl.cpfcgemi)) <= 11 THEN
                  ASSIGN aux_nrcpfcgc = STRING(craptvl.cpfcgemi,"99999999999")
                         aux_nrcpfcgc =
                             STRING(aux_nrcpfcgc,"    xxx.xxx.xxx-xx").
             ELSE
                  ASSIGN aux_nrcpfcgc = 
                             STRING(craptvl.cpfcgemi,"99999999999999")
                         aux_nrcpfcgc = 
                             STRING(aux_nrcpfcgc,"xx.xxx.xxx/xxxx-xx").
     
         END.
      
    IF   LENGTH(STRING(craptvl.cpfcgrcb)) <= 11 THEN
         ASSIGN aux_cpfcgrcb = STRING(craptvl.cpfcgrcb,"99999999999")
                aux_cpfcgrcb = STRING(aux_cpfcgrcb,"    xxx.xxx.xxx-xx").
    ELSE
         ASSIGN aux_cpfcgrcb = STRING(craptvl.cpfcgrcb,"99999999999999")
                aux_cpfcgrcb = STRING(aux_cpfcgrcb,"xx.xxx.xxx/xxxx-xx").
                          
    IF  craptvl.tpdoctrf = 1 OR craptvl.tpdoctrf = 2 THEN
        aux_cdacesso = 'FINTRFDOCS'.
    ELSE
        aux_cdacesso = 'FINTRFTEDS'.
    
    FIND craptab NO-LOCK  WHERE  craptab.cdcooper  = par_cdcooper      AND
                                 craptab.nmsistem  = 'CRED'            AND
                                 craptab.tptabela  = 'GENERI'          AND
                                 craptab.cdempres  = 00                AND
                                 craptab.cdacesso  = aux_cdacesso      AND
                                 craptab.tpregist  = craptvl.cdfinrcb 
                                 NO-ERROR.           
    IF AVAIL craptab THEN
       ASSIGN aux_cdfinrcb = STRING(craptab.tpregist,"zzz99") + " - " +
                             craptab.dstextab.

    ASSIGN aux_cdacesso = "".
     
    IF  craptvl.tpdoctrf = 2 THEN
        aux_cdacesso = 'TPCTACRTRF'.
    ELSE
    IF  craptvl.tpdoctrf = 3 THEN
        aux_cdacesso = 'TPCTACRTED'.
    
    FIND craptab NO-LOCK  WHERE  craptab.cdcooper  = par_cdcooper      AND
                                 craptab.nmsistem  = 'CRED'            AND
                                 craptab.tptabela  = 'GENERI'          AND
                                 craptab.cdempres  = 00                AND
                                 craptab.cdacesso  = aux_cdacesso      AND
                                 craptab.tpregist  = craptvl.tpdctacr 
                                 NO-ERROR.           
    
    IF  AVAIL craptab THEN  
        DO:
            IF  craptab.tpregist = 0 THEN
                ASSIGN aux_tpdctacr = STRING(craptab.tpregist,"99") + " - " +
                                      "Nenhum".
            ELSE
                ASSIGN aux_tpdctacr = STRING(craptab.tpregist,"99") + " - " +
                                      craptab.dstextab.    
        END.
    ELSE
        ASSIGN aux_tpdctacr = "00 - Nenhum".
    
    
    ASSIGN aux_cdacesso = "".
     
    IF  craptvl.tpdoctrf = 2 THEN
        aux_cdacesso = 'TPCTADBTRF'.
    ELSE
    IF   craptvl.tpdoctrf = 3 THEN
         aux_cdacesso = 'TPCTADBTED'.
    
    FIND craptab NO-LOCK  WHERE  craptab.cdcooper  = par_cdcooper      AND
                                 craptab.nmsistem  = 'CRED'            AND
                                 craptab.tptabela  = 'GENERI'          AND
                                 craptab.cdempres  = 00                AND
                                 craptab.cdacesso  = aux_cdacesso      AND
                                 craptab.tpregist  = craptvl.tpdctadb 
                                 NO-ERROR.           
    
    IF  AVAIL craptab THEN  
        DO:
            IF  craptab.tpregist = 0 THEN
                ASSIGN aux_tpdctadb = STRING(craptab.tpregist,"99") + " - " +
                                     "Nenhum".
            ELSE
                ASSIGN aux_tpdctadb = STRING(craptab.tpregist,"99") + " - " +
                                      craptab.dstextab.    
        END.
    ELSE
        ASSIGN aux_tpdctadb = "00 - Nenhum".

END PROCEDURE.
        
PROCEDURE finaliza_impressao:

    ASSIGN pac_dsdtraco = FILL("-",77).
    
    PAGE STREAM str_1.
    
    IF   par_ted_doc = "D"  THEN
         RUN lista_arquivos_doctos.

    PUT STREAM str_1 CONTROL "\022\024\033\120" NULL.

    PUT STREAM str_1 CONTROL "\0330\033x0" NULL.

    OUTPUT STREAM str_1 CLOSE.

    IF   par_flgimpri THEN /* Efetua impressao pela PRCCTL */  
         DO:
             ASSIGN glb_nmformul = ""
                    glb_nrcopias = 1
                    glb_nmarqimp = aux_nmarqimp.
              
             FIND FIRST crapass WHERE crapass.cdcooper = par_cdcooper 
                  NO-LOCK NO-ERROR.
          
             { includes/impressao.i }
          
             HIDE MESSAGE NO-PAUSE.
          
             MESSAGE "Retire o relatorio da impressora!".
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
    
             UNIX SILENT VALUE("rm /micros/cecred/compel/0326_" + 
                               STRING(crapcop.cdagectl,"9999") + 
                               "* 2> /dev/null").
    
             ASSIGN aux_nmarqpdf = "/micros/cecred/compel/O326_"  +
                                   STRING(crapcop.cdagectl,"9999") + "_" + 
                                   STRING(TIME,"99999") + "_"     +
                                   STRING(crapcop.cdbcoctl,"999") + ".pdf".
    
             /* GERAR PDF */
             RUN gera-pdf-impressao IN h-b1wgen0024(INPUT aux_nmarqimp,
                                                    INPUT aux_nmarqpdf).
    
             DELETE PROCEDURE h-b1wgen0024.
         END.

END PROCEDURE.

PROCEDURE lista_arquivos_doctos:

    IF   MONTH(par_dtmvtolt) > 9 THEN
            CASE MONTH(par_dtmvtolt):
                 WHEN 10 THEN aux_mes = "O".
                 WHEN 11 THEN aux_mes = "N".
                 WHEN 12 THEN aux_mes = "D".
            END CASE.
       ELSE aux_mes = STRING(MONTH(par_dtmvtolt),"9").

    FOR EACH crattot NO-LOCK BREAK BY crattot.cdbandoc
                                   BY crattot.cdagenci:

       IF   FIRST-OF(crattot.cdbandoc)  THEN
            DO:
                ASSIGN pac_geral_qtdarqui = 0
                       pac_geral_qtdoctos = 0
                       pac_geral_vldoctos = 0
                       pac_qtdarqui       = 1
                       rel_dsbancmp       = crattot.dsbancmp.
                       

                DISPLAY STREAM str_1 par_dtmvtolt rel_dsbancmp aux_nmrescop
                               WITH FRAME f_cab_doctos.
            END.
                            
       ASSIGN pac_geral_qtdoctos = pac_geral_qtdoctos + crattot.qtdoctos
              pac_geral_vldoctos = pac_geral_vldoctos + crattot.vldoctos
              aux_extensao       = "." + STRING(crattot.cdagenci,"999")
              aux_nmarquiv       = "3" +
                                   STRING(crapcop.cdagectl,"9999")    +
                                   aux_mes                            + 
                                   STRING(DAY(par_dtmvtolt),"99") +
                                   aux_extensao.

       DISPLAY STREAM str_1  
                      crattot.cdagenci @  craptvl.cdagenci
                      crattot.qtdoctos @  aux_qtdade
                      crattot.vldoctos @  aux_valor 
                      aux_nmarquiv
                      WITH FRAME f_doctos.
            
       DOWN STREAM str_1 WITH FRAME f_doctos.
                
       CLEAR FRAME f_tot_doctos.
       
       DISPLAY STREAM str_1 
                      pac_dsdtraco
                      crattot.qtdoctos @  pac_qtdoctos
                      crattot.vldoctos @  pac_vldoctos
                      pac_qtdarqui
                      WITH FRAME f_tot_doctos. 

       IF   LAST-OF(crattot.cdagenci) THEN
            ASSIGN pac_geral_qtdarqui = pac_geral_qtdarqui + 1.

       IF   LAST-OF(crattot.cdbandoc)  THEN
            DO:
                CLEAR FRAME f_tot_geral_doctos.
       
                DISPLAY STREAM str_1 
                               pac_dsdtraco
                               pac_geral_qtdarqui 
                               pac_geral_qtdoctos 
                               pac_geral_vldoctos 
                               WITH FRAME f_tot_geral_doctos.

                DOWN STREAM str_1 WITH FRAME f_tot_geral_doctos.
                
                IF   NOT par_flgenvio  THEN
                     DO:
                         IF   LINE-COUNTER(str_1) > 80  THEN
                              DO:
                                  PAGE STREAM str_1.
                     
                                  DISPLAY STREAM str_1 
                                  par_dtmvtolt rel_dsbancmp aux_nmrescop
                                  WITH FRAME f_cab.
                              END.

                         DISPLAY STREAM str_1
                                        SKIP(4)
                                        "         ARQUIVO TRANSMITIDO" AT 44
                                        SKIP(3)
                                  "_____________________________________" AT 44
                                        SKIP
                                  "   CADASTRO E VISTO DO FUNCIONARIO   " AT 44
                                  WITH NO-LABELS NO-BOX WIDTH 80 FRAME f_visto.
                     END.
                     
                PAGE STREAM str_1.
            END.
            
   END. /* Fim do FOR EACH */

END PROCEDURE.

/* .......................................................................... */
