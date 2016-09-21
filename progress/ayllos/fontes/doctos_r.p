/* ..........................................................................

   Programa: Fontes/doctos_r.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Mirtes
   Data    : Janeiro/2004.                   Ultima atualizacao: 30/05/2014
            
   Dados referentes ao programa:

   Frequencia: Diario (ON-LINE).
   Objetivo  : Emitir relatorio dos DOC'S que foram p/Banco Brasil no dia (326).

   Alteracoes: 27/01/2006 - Unificacao dos Bancos - SQLWorks - Andre
                
               23/02/2007 - Separar DOC's Banco do Brasil/BANCOOB (David).

               08/02/2008 - Permitir imprimir TED's (Sidnei - Precise)
               
               30/06/2008 - Incluidos campos Finalidade, Conta Credito e 
                            Conta Debito no relatorio 326 (Elton).

               19/08/2008 - Tratar praca de compensacao (Magui).

               04/11/2008 - Inibicao da tecla F4 (Martin)

               28/08/2009 - Substituicao do campo banco/agencia da COMPE, 
                            para o banco/agencia COMPE de DOC (cdagedoc e
                            cdbandoc) - (Sidnei - Precise).
               01/10/2009 - Precise - Paulo - alterado para trablhar com 
                            tabela generica no caso da CECRED.

               07/10/2009 - Alterado programa para nao se basear no codigo
                            fixo 997 para CECRED, mas sim utilizar o campo
                            cdbcoctl da CRAPCOP (Guilherme/Supero)

                          - Redefinir a crawage dos programas Titulo, Doctos,
                            Compel, para igualar a da BO b1wgen0012 
                            (Guilherme/Supero).

                          - Remover parte CECRED deste relatorio e repassar
                            para PRCCTL->B1WGEN0012->gerar_compel (19/05/2010)
                            (Guilherme/Supero)
                            
               11/08/2010 - Acerto na Impressao do Rel. Qdo selec. o PAC (Ze).
               
               13/08/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).
                            
               13/11/2013 - Alterado totalizador de PAs de 99 para 999.
                            (Reinert)                            
                            
               13/12/2013 - Alterado form f_cab de "CPF/CGC" para "CPF/CNPJ".
                            (Reinert)
                            
               30/05/2014 - Concatena o numero do servidor no endereco do
                            terminal (Tiago-RKAM).
............................................................................. */

DEFINE TEMP-TABLE crattem                                               NO-UNDO
       FIELD cdseqarq AS INTEGER
       FIELD nrdolote AS INTEGER
       FIELD cddbanco AS INTEGER
       FIELD nrrectit AS RECID
       INDEX crattem1 cdseqarq nrdolote.

DEF TEMP-TABLE crawage                                                  NO-UNDO
       FIELD  cdagenci      LIKE crapage.cdagenci
       FIELD  nmresage      LIKE crapage.nmresage
       FIELD  nmcidade      LIKE crapage.nmcidade 
       FIELD  cdbandoc      LIKE crapage.cdbandoc
       FIELD  cdbantit      LIKE crapage.cdbantit
       FIELD  cdagecbn      LIKE crapage.cdagecbn
       FIELD  cdbanchq      LIKE crapage.cdbanchq
       FIELD  cdcomchq      LIKE crapage.cdcomchq.

DEFINE TEMP-TABLE crattot                                            NO-UNDO
       FIELD cdagenci LIKE crapage.cdagenci
       FIELD cdbandoc LIKE crapage.cdbandoc
       FIELD dsbancmp AS CHAR    FORMAT "x(15)"
       FIELD qtdoctos AS INTEGER FORMAT "zzz9"
       FIELD vldoctos AS DECIMAL FORMAT "zzz,zzz,zz9.99"
       FIELD nrdocmto LIKE craptvl.nrdocmto.
       
DEF STREAM str_1.
                     
DEF INPUT PARAM par_dtmvtolt AS DATE                                 NO-UNDO.
DEF INPUT PARAM par_cdagenci AS INT                                  NO-UNDO.
DEF INPUT PARAM par_flgenvio AS LOGICAL                              NO-UNDO.
DEF INPUT PARAM par_ted_doc  AS CHAR                                 NO-UNDO.
DEF INPUT PARAM par_recid    AS RECID                                NO-UNDO.
DEF INPUT PARAM TABLE FOR crawage.    

DEF VAR par_flgrodar AS LOGICAL INIT TRUE                            NO-UNDO.
DEF VAR par_flgfirst AS LOGICAL INIT TRUE                            NO-UNDO.
DEF VAR par_flgcance AS LOGICAL                                      NO-UNDO.
  
{ includes/var_online.i }

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

DEF   VAR pac_dsdtraco AS CHAR    FORMAT "x(77)"                     NO-UNDO.

DEF   VAR pac_qtdarqui AS INT     FORMAT "zzz,zz9"                   NO-UNDO.
DEF   VAR pac_qtdoctos AS INT     FORMAT "zzz,zz9"                   NO-UNDO.
DEF   VAR pac_vldoctos AS DECIMAL FORMAT "zzzz,zzz,zz9.99"           NO-UNDO.

DEF   VAR pac_geral_qtdarqui AS INT     FORMAT "zzz,zz9"             NO-UNDO.
DEF   VAR pac_geral_qtdoctos AS INT     FORMAT "zzz,zz9"             NO-UNDO.
DEF   VAR pac_geral_vldoctos AS DECIMAL FORMAT "zzzz,zzz,zz9.99"     NO-UNDO.

FORM rel_dsbancmp  AT   1   LABEL "--> BANCO COMPENSACAO"   FORMAT "x(15)"
     SKIP(1)
     par_dtmvtolt  AT   1   LABEL "REFERENCIA"              FORMAT "99/99/9999"
     SKIP(1)
     "PA      LOTE  OPERADOR         DOCTO       VALOR  TIPO_DOC"
     "  FINALIDADE                                CONTA CREDITO" 
     SKIP
     "               BCO  AGE   CONTA CC" 
     "NOME                                      CPF/CNPJ"
     "                 CONTA DEBITO"      
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
     SKIP(1)
     "PA     QTD. DOCTOS "       AT  1
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

FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.

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
       aux_cdagefim    = IF   par_cdagenci = 0  THEN 
                              9999
                         ELSE 
                              par_cdagenci.
                         
{ includes/cabrel132_1.i }

aux_nmarqimp = "rl/O326_" + STRING(TIME,"99999") + ".lst".
       
HIDE MESSAGE NO-PAUSE.

/*  Gerenciamento da impressao  */

INPUT THROUGH basename `tty` NO-ECHO.

SET aux_nmendter WITH FRAME f_terminal.

INPUT CLOSE.

aux_nmendter = substr(glb_hostname,length(glb_hostname) - 1) +
                      aux_nmendter. 

UNIX SILENT VALUE("rm rl/" + aux_nmendter + "* 2> /dev/null").
  
MESSAGE "AGUARDE... Imprimindo relatorio!".

OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGED PAGE-SIZE 84.

PUT STREAM str_1 CONTROL "\022\024\033\120" NULL.

PUT STREAM str_1 CONTROL "\0330\033x0\033\017" NULL.

VIEW STREAM str_1 FRAME f_cabrel132_1.

IF  par_ted_doc = "D" THEN
    DO:
       FOR EACH craptvl WHERE craptvl.cdcooper  = glb_cdcooper   AND
                              craptvl.dtmvtolt  = par_dtmvtolt   AND
                              craptvl.cdagenci >= par_cdagenci   AND
                              craptvl.cdagenci <= aux_cdagefim   AND
                              craptvl.tpdoctrf <> 3              AND
                              craptvl.flgenvio = par_flgenvio    NO-LOCK,
           EACH crawage WHERE crawage.cdagenci  = craptvl.cdagenci NO-LOCK
                              BREAK BY crawage.cdbandoc 
                                    BY craptvl.cdagenci
                                    BY craptvl.cdbccrcb:
            
           IF   FIRST-OF(crawage.cdbandoc)  THEN
                ASSIGN aux_qtdoctos   = 0
                       aux_qtdoctos_g = 0
                       aux_vldoctos   = 0
                       aux_vldoctos_g = 0
                       rel_dsbancmp   = IF   crawage.cdbandoc = 1  THEN
                                             "BANCO DO BRASIL"
                                        ELSE
                                        IF   crawage.cdbandoc = 756  THEN
                                             "BANCOOB"
                                        ELSE
                                             "".
                       
           IF   FIRST-OF(craptvl.cdagenci)  THEN
                DO:
                    ASSIGN aux_nrdocmto = craptvl.nrdocmto.
                    
                    DISPLAY STREAM str_1 rel_dsbancmp par_dtmvtolt 
                            WITH FRAME f_cab.
                END.
                
           RUN lista_craptvl.

           ASSIGN aux_qtdoctos   = aux_qtdoctos   + 1
                  aux_qtdoctos_g = aux_qtdoctos_g + 1
                  aux_vldoctos   = aux_vldoctos   + craptvl.vldocrcb 
                  aux_vldoctos_g = aux_vldoctos_g + craptvl.vldocrcb.
           
           IF   LAST-OF(craptvl.cdagenci)  THEN
                DO:
                    ASSIGN aux_descricao = "TOTAL PA ".
       
                    DISPLAY STREAM str_1
                            aux_descricao
                            aux_qtdoctos 
                            aux_vldoctos 
                            WITH FRAME f_total. 
                    
                    DOWN STREAM str_1 WITH FRAME f_total.         
                    
                    PAGE STREAM str_1.

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
                ASSIGN aux_descricao = "TOTAL GERAL " + crattot.dsbancmp
                       aux_qtdoctos  = 0
                       aux_vldoctos  = 0.
                
           ASSIGN aux_qtdoctos = aux_qtdoctos + crattot.qtdoctos
                  aux_vldoctos = aux_vldoctos + crattot.vldoctos.
                  
           IF   LAST-OF(crattot.cdbandoc)   THEN
                DO:
                    DISPLAY STREAM str_1
                                   aux_descricao
                                   aux_qtdoctos 
                                   aux_vldoctos 
                                   WITH FRAME f_total. 
       
                    DOWN STREAM str_1 WITH FRAME f_total.
                END.
                
       END. /* Fim do FOR EACH */
 
       RUN finaliza_impressao.
    END.
ELSE
    DO:
       FOR EACH craptvl WHERE craptvl.cdcooper  = glb_cdcooper   AND
                              craptvl.dtmvtolt  = par_dtmvtolt   AND
                              craptvl.cdagenci >= par_cdagenci   AND
                              craptvl.cdagenci <= aux_cdagefim   AND
                              craptvl.tpdoctrf  = 3              AND
                              craptvl.flgenvio = par_flgenvio    NO-LOCK
                              BREAK BY craptvl.cdagenci
                                    BY craptvl.cdbccrcb:
            
           IF   FIRST-OF(craptvl.cdagenci)  THEN
                DO:
                    ASSIGN rel_dsbancmp = "BANCO DO BRASIL".
                    
                    DISPLAY STREAM str_1 par_dtmvtolt rel_dsbancmp
                            WITH FRAME f_cab.
                    
                    DISPLAY STREAM str_1 craptvl.cdagenci 
                            WITH FRAME f_lanctos.
                END.
                
           RUN lista_craptvl.
       
           ASSIGN aux_qtdoctos   = aux_qtdoctos   + 1
                  aux_qtdoctos_g = aux_qtdoctos_g + 1
                  aux_vldoctos   = aux_vldoctos   + craptvl.vldocrcb 
                  aux_vldoctos_g = aux_vldoctos_g + craptvl.vldocrcb.
           
           IF   LAST-OF(craptvl.cdagenci)  THEN
                DO:
                    ASSIGN aux_descricao = "TOTAL PA ".
               
                    DISPLAY STREAM str_1
                            aux_descricao
                            aux_qtdoctos 
                            aux_vldoctos 
                            WITH FRAME f_total. 
                    
                    DOWN STREAM str_1 WITH FRAME f_total.         
                    
                    PAGE STREAM str_1.
                    
                    ASSIGN aux_qtdoctos = 0
                           aux_vldoctos = 0.
                END.

       END. /* Fim do FOR EACH */

       ASSIGN aux_descricao = "TOTAL GERAL ".

       DISPLAY STREAM str_1
                      aux_descricao
                      aux_qtdoctos_g  @  aux_qtdoctos   
                      aux_vldoctos_g  @  aux_vldoctos 
                      WITH FRAME f_total. 
       
       DOWN STREAM str_1 WITH FRAME f_total.         
 
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
    
    FIND craplot WHERE craplot.cdcooper = glb_cdcooper       AND
                       craplot.dtmvtolt = craptvl.dtmvtolt   AND
                       craplot.cdagenci = craptvl.cdagenci   AND
                       craplot.cdbccxlt = craptvl.cdbccxlt   AND
                       craplot.nrdolote = craptvl.nrdolote   NO-LOCK NO-ERROR.
                       
    IF   AVAILABLE craplot   THEN                   
         DO:
             FIND crapope WHERE crapope.cdcooper = glb_cdcooper     AND
                                crapope.cdoperad = craplot.cdoperad
                                NO-LOCK NO-ERROR.

             ASSIGN aux_nmoperad = IF   AVAILABLE crapope  THEN 
                                        crapope.nmoperad
                                   ELSE 
                                        "Nao cadas".
         END.

    FIND crapass WHERE crapass.cdcooper = glb_cdcooper AND
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
    
    FIND craptab NO-LOCK  WHERE  craptab.cdcooper  = glb_cdcooper      AND
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
    
    FIND craptab NO-LOCK  WHERE  craptab.cdcooper  = glb_cdcooper      AND
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
    
    FIND craptab NO-LOCK  WHERE  craptab.cdcooper  = glb_cdcooper      AND
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
    
    
    DISPLAY STREAM str_1
            craptvl.cdagenci
            craptvl.nrdolote
            aux_nmoperad
            craptvl.nrdocmto
            craptvl.vldocrcb
            aux_tpdoctrf
            aux_cdfinrcb  
            aux_tpdctacr  
            WITH FRAME f_lanctos.

    DOWN STREAM str_1 WITH FRAME f_lanctos.
                        
    DISPLAY STREAM str_1
            craptvl.cdagenci
            craptvl.nrdconta
            aux_nmprimtl
            aux_nrcpfcgc
            aux_tpdctadb   
            craptvl.cdbccrcb
            craptvl.cdagercb
            craptvl.nrcctrcb  FORMAT ">>>>>>>>>>>>9"
            craptvl.nmpesrcb
            aux_cpfcgrcb
            WITH FRAME f_dados.
    
    DOWN STREAM str_1 WITH FRAME f_dados.         
                                     
    DISPLAY STREAM str_1 WITH FRAME f_linha.
    
    DOWN STREAM str_1 WITH FRAME f_linha.
       
    IF   LINE-COUNTER(str_1) > 80  THEN
         DO:
             PAGE STREAM str_1.
                       
             DISPLAY STREAM str_1 
                     par_dtmvtolt rel_dsbancmp WITH FRAME f_cab.
         END.

END PROCEDURE.
        
PROCEDURE finaliza_impressao:

    ASSIGN pac_dsdtraco = FILL("-",77).
    
    PAGE STREAM str_1.
    
    IF   par_ted_doc = "D"  THEN
         RUN lista_arquivos_doctos.
    ELSE
         RUN lista_arquivos.

    PUT STREAM str_1 CONTROL "\022\024\033\120" NULL.

    PUT STREAM str_1 CONTROL "\0330\033x0" NULL.

    OUTPUT STREAM str_1 CLOSE.

    ASSIGN glb_nmformul = ""
           glb_nrcopias = 1
           glb_nmarqimp = aux_nmarqimp.
     
    FIND FIRST crapass WHERE crapass.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.

    { includes/impressao.i }

    HIDE MESSAGE NO-PAUSE.

    MESSAGE "Retire o relatorio da impressora!".

END PROCEDURE.

PROCEDURE lista_arquivos_doctos:

   FOR EACH crattot NO-LOCK BREAK BY crattot.cdbandoc
                                      BY crattot.cdagenci:
                                      
       IF   FIRST-OF(crattot.cdbandoc)  THEN
            DO:
                ASSIGN pac_geral_qtdarqui = 0
                       pac_geral_qtdoctos = 0
                       pac_geral_vldoctos = 0
                       pac_qtdarqui       = 1
                       rel_dsbancmp       = crattot.dsbancmp
                       aux_extensao       = IF   crattot.cdbandoc = 1  THEN
                                                 ".rem"
                                            ELSE
                                            IF   crattot.cdbandoc = 756  THEN
                                                 ".CBE"
                                            ELSE
                                                 "".
            
            
                DISPLAY STREAM str_1 par_dtmvtolt rel_dsbancmp 
                               WITH FRAME f_cab_doctos.
            END.
                            
       ASSIGN pac_geral_qtdarqui = pac_geral_qtdarqui + 1
              pac_geral_qtdoctos = pac_geral_qtdoctos + crattot.qtdoctos
              pac_geral_vldoctos = pac_geral_vldoctos + crattot.vldoctos
              aux_nmarquiv       = "dc" + STRING(crattot.nrdocmto,"9999999") +
                                   STRING(DAY(glb_dtmvtolt),"99") + 
                                   STRING(MONTH(glb_dtmvtolt),"99") +
                                   STRING(crattot.cdagenci, "999") + 
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
                     
                                  DISPLAY STREAM str_1 par_dtmvtolt rel_dsbancmp
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

PROCEDURE lista_arquivos:

   ASSIGN rel_dsbancmp = "BANCO DO BRASIL".
   
   DISPLAY STREAM str_1 par_dtmvtolt rel_dsbancmp WITH FRAME f_cab_doctos.
      
   EMPTY TEMP-TABLE crattem.
   
   ASSIGN aux_cdseqarq = 0.
   
   FOR EACH craptvl WHERE craptvl.cdcooper = glb_cdcooper  AND
                          craptvl.dtmvtolt = par_dtmvtolt  AND
                          craptvl.flgenvio = par_flgenvio  AND  
                          craptvl.tpdoctrf = 3             AND
                          craptvl.cdagenci >= par_cdagenci AND
                          craptvl.cdagenci <= aux_cdagefim NO-LOCK,
       EACH crawage WHERE crawage.cdagenci = craptvl.cdagenci NO-LOCK
                          BREAK BY craptvl.cdagenci:
    
       IF   FIRST-OF(craptvl.cdagenci) THEN
            ASSIGN aux_cdseqarq = aux_cdseqarq  + 1
                   aux_nrdolote = 1.
       
       CREATE crattem.
       ASSIGN crattem.cdseqarq = aux_cdseqarq
              crattem.nrdolote = aux_nrdolote
              crattem.cddbanco = 1
              crattem.nrrectit = RECID(craptvl).
   END. 
       
   FOR EACH crattem USE-INDEX crattem1 NO-LOCK 
                    BREAK BY crattem.cdseqarq BY crattem.nrdolote:

       FIND craptvl WHERE RECID(craptvl) = crattem.nrrectit NO-LOCK NO-ERROR.

       FIND crapage WHERE crapage.cdcooper = glb_cdcooper     AND
                          crapage.cdagenci = craptvl.cdagenci NO-LOCK NO-ERROR.
       
       ASSIGN aux_valor  = aux_valor + craptvl.vldocrcb
              aux_qtdade = aux_qtdade + 1.
   
       ASSIGN pac_qtdoctos = pac_qtdoctos + 1
              pac_vldoctos = pac_vldoctos + craptvl.vldocrcb.
              
       ASSIGN pac_geral_qtdoctos = pac_geral_qtdoctos + 1
              pac_geral_vldoctos = pac_geral_vldoctos + craptvl.vldocrcb.
              
       IF   FIRST-OF(crattem.cdseqarq)  THEN
            DO:
               aux_nmarquiv = IF   crapage.cdbantit = 1   THEN /*BB*/
                                   "dc" +
                                   STRING(craptvl.nrdocmto,"9999999") +
                                   STRING(DAY(glb_dtmvtolt),"99") + 
                                   STRING(MONTH(glb_dtmvtolt),"99") +
                                   STRING(craptvl.cdagenci, "999") +
                                   ".rem"
                              ELSE
                              IF   crapage.cdbantit = 756   THEN /*BANCOOB*/
                                   "dc" +
                                   STRING(craptvl.nrdocmto,"9999999") +
                                   STRING(DAY(glb_dtmvtolt),"99") + 
                                   STRING(MONTH(glb_dtmvtolt),"99") +
                                   STRING(craptvl.cdagenci, "999") +
                                   ".CBE"   
                              ELSE "".
               
               ASSIGN pac_qtdarqui = pac_qtdarqui + 1.
               ASSIGN pac_geral_qtdarqui = pac_geral_qtdarqui + 1.
            END.

       IF   LAST-OF(crattem.cdseqarq) THEN
            DO:
                DISPLAY STREAM str_1  
                        craptvl.cdagenci  
                        aux_qtdade
                        aux_valor 
                        aux_nmarquiv
                        WITH FRAME f_doctos.
            
                DOWN STREAM str_1 WITH FRAME f_doctos.
                
                ASSIGN aux_valor  = 0
                       aux_qtdade = 0.
   
                CLEAR FRAME f_tot_doctos.
       
                DISPLAY STREAM str_1 
                               pac_dsdtraco
                               pac_qtdarqui  
                               pac_qtdoctos
                               pac_vldoctos
                               WITH FRAME f_tot_doctos. 

                ASSIGN pac_qtdarqui = 0
                       pac_qtdoctos = 0
                       pac_vldoctos = 0.
            END.
   END.
 
   CLEAR FRAME f_tot_geral_doctos.
       
   DISPLAY STREAM str_1 
           pac_dsdtraco
           pac_geral_qtdarqui 
           pac_geral_qtdoctos 
           pac_geral_vldoctos 
           WITH FRAME f_tot_geral_doctos. 

   IF   NOT par_flgenvio  THEN
        DO:
            IF   LINE-COUNTER(str_1) > 80  THEN
                 DO:
                     PAGE STREAM str_1.
                     
                     DISPLAY STREAM str_1 par_dtmvtolt rel_dsbancmp
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

END PROCEDURE.

/* .......................................................................... */
