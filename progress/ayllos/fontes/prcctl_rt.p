/* ..........................................................................

   Programa: Fontes/prcctl_rt.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Guilherme/Supero
   Data    : Maio/2010.                         Ultima atualizacao: 15/09/2014

   Dados referentes ao programa:

   Frequencia: Diario (ON-LINE).
   Objetivo  : Emitir relatorio de lotes de titulos para envio ao BANCOOB
               (239).
               Exclusivo para CECRED, baseado no TITULO_R.P
               Detalhe nome: R = Relatorio
                             T = Titulo

   Alteracoes: 27/05/2010 - Mostrar nome da cooperativa (Guilherme).

               28/05/2010 - Mostrar indicador de Superior e Inferior ao lado
                            do nome do arquivo e exibir Totais de Inferior e
                            Superior (Guilherme/Supero).
                            
               15/06/2010 - Tratamento para PA 91 - TAA (Elton).

               02/01/2012 - Alteracao Temporario para enviar os titulos pagos
                            no dia 30/12/2011 no TAA. No dia 03/01 voltei a
                            versao anterior (Ze).
                            
               22/04/2013 - Inserir total de arquivos (Trf. 53072) - Ze.
               
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
                       
               26/12/2018 - Efetuar copia de arquivo txt para diretorio micros.
                            Chamado SCTASK0036838 - Gabriel Marcos (Mouts).  
                           
............................................................................. */

{ includes/var_online.i }

DEF STREAM str_1.
DEF STREAM str_2.

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

DEF VAR par_flgrodar AS LOGICAL INIT TRUE                            NO-UNDO.
DEF VAR par_flgfirst AS LOGICAL INIT TRUE                            NO-UNDO.
DEF VAR par_flgcance AS LOGICAL                                      NO-UNDO.

DEF VAR aux_cdagefim LIKE craptvl.cdagenci                           NO-UNDO.
DEF VAR aux_valorvlb AS DEC                                          NO-UNDO.

DEF VAR aux_vltitulo AS DECIMAL                                      NO-UNDO.
DEF VAR aux_qttitulo AS INTEGER                                      NO-UNDO.

DEF VAR aux_vltitvlb AS DECIMAL                                      NO-UNDO.
DEF VAR aux_qttitvlb AS INTEGER                                      NO-UNDO.
DEF VAR aux_vltitinf AS DECIMAL                                      NO-UNDO.
DEF VAR aux_qttitinf AS INTEGER                                      NO-UNDO.
DEF VAR aux_nmrescop AS CHAR                                         NO-UNDO.

DEF TEMP-TABLE crawtit                                               NO-UNDO
    FIELD cdagenci AS INT     FORMAT "zz9"
    FIELD cdbccxlt AS INT     FORMAT "zz9"
    FIELD nrdolote AS INT     FORMAT "zz,zz9"
    FIELD qttitulo AS INT     FORMAT "zzz,zz9"
    FIELD vltitulo AS DECIMAL FORMAT "zzzz,zzz,zz9.99"
    FIELD nmoperad AS CHAR    FORMAT "x(10)"
    FIELD nmarquiv AS CHAR    FORMAT "x(26)"
    FIELD flgachou AS LOGICAL
    FIELD cdbantit LIKE crapage.cdbantit.
             
DEF        VAR rel_nmresemp AS CHAR    FORMAT "x(15)"                NO-UNDO.
DEF        VAR rel_nmrelato AS CHAR    FORMAT "x(40)" EXTENT 5       NO-UNDO.

DEF        VAR rel_nrmodulo AS INT     FORMAT "9"                    NO-UNDO.
DEF        VAR rel_nmmodulo AS CHAR    FORMAT "x(15)" EXTENT 5
                               INIT ["DEP. A VISTA   ","CAPITAL        ",
                                     "EMPRESTIMOS    ","DIGITACAO      ",
                                     "GENERICO       "]              NO-UNDO.

DEF   VAR pac_dsdtraco AS CHAR    FORMAT "x(77)"                     NO-UNDO.

DEF   VAR pac_qtdlotes AS INT     FORMAT "zz,zz9"                    NO-UNDO.
DEF   VAR pac_qttitulo AS INT     FORMAT "zzz,zz9"                   NO-UNDO.
DEF   VAR pac_vltitulo AS DECIMAL FORMAT "zzzz,zzz,zz9.99"           NO-UNDO.

DEF   VAR tot_qtdlotes AS INT     FORMAT "zzz,zz9"                   NO-UNDO.
DEF   VAR tot_qttitulo AS INT     FORMAT "zzz,zz9"                   NO-UNDO.
DEF   VAR tot_vltitulo AS DECIMAL FORMAT "zzzz,zzz,zz9.99"           NO-UNDO.

DEF   VAR tot_qttitinf AS INT     FORMAT "zzz,zz9"                   NO-UNDO.
DEF   VAR tot_vltitinf AS DECIMAL FORMAT "zzzz,zzz,zz9.99"           NO-UNDO.
DEF   VAR tot_qttitvlb AS INT     FORMAT "zzz,zz9"                   NO-UNDO.
DEF   VAR tot_vltitvlb AS DECIMAL FORMAT "zzzz,zzz,zz9.99"           NO-UNDO.
                                                             
DEF   VAR ger_qttitulo AS INT     FORMAT "zzz,zz9"                   NO-UNDO.
DEF   VAR ger_vltitulo AS DECIMAL FORMAT "zzzz,zzz,zz9.99"           NO-UNDO.

DEF   VAR lot_nmoperad AS CHAR                                       NO-UNDO.

DEF   VAR tel_dsimprim AS CHAR    FORMAT "x(8)" INIT "Imprimir"      NO-UNDO.
DEF   VAR tel_dscancel AS CHAR    FORMAT "x(8)" INIT "Cancelar"      NO-UNDO.

DEF   VAR tel_dsdlinha AS CHAR                                       NO-UNDO.
DEF   VAR tel_dscodbar AS CHAR    FORMAT "x(44)"                     NO-UNDO.

DEF   VAR tel_nrcampo1 AS DECIMAL FORMAT "9999999999"                NO-UNDO.
DEF   VAR tel_nrcampo2 AS DECIMAL FORMAT "99999999999"               NO-UNDO.
DEF   VAR tel_nrcampo3 AS DECIMAL FORMAT "99999999999"               NO-UNDO.
DEF   VAR tel_nrcampo4 AS INT     FORMAT "9"                         NO-UNDO.
DEF   VAR tel_nrcampo5 AS DECIMAL FORMAT "zzzzzzzzzzz999"            NO-UNDO.

DEF   VAR aux_flgfirst AS LOGICAL                                    NO-UNDO.
DEF   VAR aux_regexist AS LOGICAL                                    NO-UNDO.
DEF   VAR aux_flgescra AS LOGICAL                                    NO-UNDO.
DEF   VAR aux_flgabert AS LOGICAL                                    NO-UNDO.
DEF   VAR aux_flgexist AS LOGICAL                                    NO-UNDO.
DEF   VAR aux_mes      AS CHAR                                       NO-UNDO.

DEF   VAR aux_contador AS INT                                        NO-UNDO.

DEF   VAR aux_nmendter AS CHAR    FORMAT "x(20)"                     NO-UNDO.
DEF   VAR aux_nmarqimp AS CHAR                                       NO-UNDO.
DEF   VAR aux_nmarqpdf AS CHAR                                       NO-UNDO.
DEF   VAR aux_dscomand AS CHAR                                       NO-UNDO.

DEF   VAR aux_confirma AS CHAR                                       NO-UNDO.
DEF   VAR aux_dscooper AS CHAR                                       NO-UNDO.

DEF   VAR tot_qtarquiv AS INT     FORMAT "zzz,zz9"                   NO-UNDO.

DEF BUFFER crabcop FOR crapcop.

DEF   VAR h-b1wgen0024 AS HANDLE                                     NO-UNDO.

FORM par_dtmvtolt  AT   1   LABEL "REFERENCIA"   FORMAT "99/99/9999"
     SKIP(1)
     "PA  CXA    LOTE"           AT  1
     "   QTD.           VALOR"        
     "OPERADOR      ARQUIVO" 
     SKIP(1)
     WITH SIDE-LABELS NO-BOX WIDTH 132 FRAME f_cab.
      
FORM  crawtit.cdagenci AT  1               
      crawtit.cdbccxlt AT  5               
      crawtit.nrdolote AT  9 
      crawtit.qttitulo AT 17               
      crawtit.vltitulo AT 25             
      crawtit.nmoperad AT 41           
      crawtit.flgachou AT 52 FORMAT " /*"
      crawtit.nmarquiv AT 55 
      WITH NO-LABELS NO-BOX WIDTH 80 FRAME f_lotes.

FORM  SKIP(1)
      "GERAL"             AT    1               
      tot_qtdlotes        AT    9               NO-LABEL
      tot_qttitulo        AT   17               NO-LABEL
      tot_vltitulo        AT   26               NO-LABEL
      WITH NO-LABELS NO-BOX WIDTH 80 FRAME f_tot.

FORM par_dtmvtolt  AT   1   LABEL "REFERENCIA"   FORMAT "99/99/9999"
     " - "                                 
     aux_nmrescop       NO-LABEL             FORMAT "x(32)"
     SKIP(1)
     "PA      QTD. TITULOS"     AT  1
     "VALOR   ARQUIVO"           AT 33
     SKIP(1)
     WITH SIDE-LABELS NO-BOX WIDTH 132 FRAME f_cab_bbrasil.

FORM  crawtit.cdagenci AT  1
      crawtit.qttitulo AT 12
      crawtit.vltitulo AT 23             
      crawtit.flgachou AT 39 FORMAT " /*"
      crawtit.nmarquiv AT 41 
      WITH NO-LABELS NO-BOX WIDTH 80 FRAME f_totais_bbrasil.
       
FORM  pac_dsdtraco        AT    1               NO-LABEL 
      SKIP(3)
      WITH NO-LABELS NO-BOX  WIDTH 80 FRAME f_pac_bbrasil.
 
FORM  SKIP(1)
      "TOTAL VLB"         AT    1               
      tot_qttitvlb        AT   21               NO-LABEL
      tot_vltitvlb        AT   35               NO-LABEL
      SKIP
      "TOTAL INF"         AT    1               
      tot_qttitinf        AT   21               NO-LABEL
      tot_vltitinf        AT   35               NO-LABEL
      SKIP
      "TOTAL DO BANCO"    AT    1               
      tot_qttitulo        AT   21               NO-LABEL
      tot_vltitulo        AT   35               NO-LABEL
      SKIP(2)
      "TOTAL DE ARQUIVOS" AT    1
      tot_qtarquiv        AT   21               NO-LABEL
      SKIP
      WITH NO-LABELS NO-BOX WIDTH 80 FRAME f_tot_bbrasil.
      
FORM  SKIP(1)
      "TOTAL GERAL"       AT    1               
      ger_qttitulo        AT   21               NO-LABEL
      ger_vltitulo        AT   35               NO-LABEL
      WITH NO-LABELS NO-BOX WIDTH 80 FRAME f_ger_bbrasil.
      

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
    
FORM tel_dsdlinha     FORMAT "x(56)"          LABEL "Linha digitavel"
     craptit.vldpagto FORMAT "zzzzzz,zz9.99"  LABEL "Valor Pago"
     craptit.nrseqdig FORMAT "zzzz9"          LABEL "Seq."
     WITH COLUMN 4 NO-LABEL NO-BOX DOWN FRAME f_lanctos.
     
FORM crapban.cdbccxlt
     "-"
     crapban.nmresbcc
     "-"
     crapban.nmextbcc
     SKIP(2)
     WITH COLUMN 10 NO-LABEL NO-BOX DOWN FRAME f_banco.
     

/** Bloqueia F4 **/
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
       glb_cdrelato[1] = 239
       pac_dsdtraco    = FILL("-",77)
       aux_flgexist    = FALSE
       aux_dscooper    = "/usr/coop/" + crapcop.dsdircop + "/"
       glb_nmrescop    = IF   glb_nmrescop = ""  THEN
                              crapcop.nmrescop 
                         ELSE glb_nmrescop .

ASSIGN aux_cdagefim    = IF par_cdagenci = 0  
                         THEN 9999
                         ELSE par_cdagenci.

{ includes/cabrel080_1.i }

aux_nmarqimp = aux_dscooper + "rl/O239_" + STRING(TIME,"99999") + "_" +
               STRING(crapcop.cdbcoctl,"999") + ".lst".
       

HIDE MESSAGE NO-PAUSE.


/*  Gerenciamento da impressao  */
INPUT THROUGH basename `tty` NO-ECHO.

SET aux_nmendter WITH FRAME f_terminal.

INPUT CLOSE.

aux_nmendter = substr(glb_hostname,length(glb_hostname) - 1) +
                      aux_nmendter.

UNIX SILENT VALUE("rm " + aux_dscooper + "rl/" + aux_nmendter + "* 2> /dev/null").
                            
OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGED PAGE-SIZE 84.
             
PUT STREAM str_1 CONTROL "\022\024\033\120" NULL.

PUT STREAM str_1 CONTROL "\0330\033x0" NULL.
                
VIEW STREAM str_1 FRAME f_cabrel080_1.


/* BUSCAR VALORESVLB DOS TITULOS */ 
FIND craptab WHERE craptab.cdcooper = par_cdcooper
              AND craptab.nmsistem = "CRED"
              AND craptab.tptabela = "GENERI"
              AND craptab.cdempres = 00
              AND craptab.cdacesso = "VALORESVLB"
              AND craptab.tpregist = 0
          NO-LOCK NO-ERROR.
IF AVAILABLE craptab   THEN
  aux_valorvlb = DEC(ENTRY(1,craptab.dstextab,";")).
ELSE
  aux_valorvlb = 0.


DO aux_contador = 1 TO 1:

   EMPTY TEMP-TABLE crawtit.

   FIND crabcop WHERE crabcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.
                                   
   IF  AVAIL crabcop  THEN
       aux_nmrescop = crabcop.nmrescop.
   ELSE
       aux_nmrescop = "** COOPERATIVA NAO CADASTRADA **".

   ASSIGN pac_qtdlotes = 0
          pac_qttitulo = 0
          pac_vltitulo = 0 

          tot_qtdlotes = 0 
          tot_qttitulo = 0
          tot_vltitulo = 0
          tot_qttitinf = 0
          tot_vltitinf = 0
          tot_qttitvlb = 0
          tot_vltitvlb = 0

          ger_qttitulo = 0
          ger_vltitulo = 0.

    FOR EACH craptit WHERE (craptit.cdcooper = par_cdcooper     AND
                           craptit.dtdpagto  = par_dtmvtolt     AND 
                           craptit.tpdocmto  = 20               AND
                        (((craptit.cdagenci >= par_cdagenci     AND
                           craptit.cdagenci <= aux_cdagefim)    AND
                           craptit.cdagenci <> 90               AND
                           craptit.cdagenci <> 91)              OR
                          (craptit.cdagenci  = 90               AND
                           par_cdagenci      = 90)              OR
                          (craptit.cdagenci  = 91               AND
                           par_cdagenci      = 91))             AND
                           craptit.intitcop  = 0                AND
                           craptit.cdbcoenv  = crapcop.cdbcoctl AND
                           craptit.flgenvio  = TRUE)            NO-LOCK,

        EACH crawage WHERE crawage.cdcooper = craptit.cdcooper  AND
                           crawage.cdagenci = craptit.cdagenci  NO-LOCK
                  BREAK BY craptit.cdagenci:



       FIND crapope WHERE crapope.cdcooper = par_cdcooper AND
                          crapope.cdoperad = glb_cdoperad NO-LOCK NO-ERROR.

       IF   NOT AVAILABLE crapope   THEN
            lot_nmoperad = "OPERAD NAO ENCONTRADO".
       ELSE
            lot_nmoperad = ENTRY(1,crapope.nmoperad," ").

       FIND crapage WHERE crapage.cdcooper = craptit.cdcooper     AND
                          crapage.cdagenci = craptit.cdagenci NO-LOCK NO-ERROR.

       IF   NOT AVAILABLE crapage THEN
            DO:
                glb_cdcritic = 15.
                RUN fontes/critic.p.
                MESSAGE glb_dscritic.
                NEXT.
            END.


       IF  FIRST-OF(craptit.cdagenci) THEN
           ASSIGN aux_qttitulo = 0
                  aux_vltitulo = 0.

       ASSIGN aux_vltitulo = aux_vltitulo + craptit.vldpagto
              aux_qttitulo = aux_qttitulo + 1.

       IF  craptit.vldpagto > aux_valorvlb THEN
           ASSIGN tot_qttitvlb = tot_qttitvlb + 1
                  tot_vltitvlb = tot_vltitvlb + craptit.vldpagto.
       ELSE
          ASSIGN tot_qttitinf = tot_qttitinf + 1
                 tot_vltitinf = tot_vltitinf + craptit.vldpagto.


       IF   MONTH(par_dtmvtolt) > 9 THEN
            CASE MONTH(par_dtmvtolt):
                 WHEN 10 THEN aux_mes = "O".
                 WHEN 11 THEN aux_mes = "N".
                 WHEN 12 THEN aux_mes = "D".
            END CASE.
       ELSE aux_mes = STRING(MONTH(par_dtmvtolt),"9").

       CREATE crawtit.

       ASSIGN crawtit.cdagenci = craptit.cdagenci
              crawtit.cdbccxlt = craptit.cdbccxlt
              crawtit.qttitulo = aux_qttitulo
              crawtit.vltitulo = aux_vltitulo
              crawtit.nmoperad = lot_nmoperad
              crawtit.cdbantit = crapage.cdbantit
              crawtit.nmarquiv = IF   crapage.cdbantit = crapcop.cdbcoctl THEN
                                      "2" +
                                      STRING(crapcop.cdagectl,"9999") + 
                                      STRING(aux_mes,"x(1)") +
                                      STRING(DAY(par_dtmvtolt),"99") + "." +
                                      STRING(crawtit.cdagenci,"999")
                                 ELSE "".

       IF   crapage.cdbantit = crapcop.cdbcoctl THEN
            crawtit.flgachou = IF SEARCH("/micros/" + crapcop.dsdircop +
                                         "/abbc/" + crawtit.nmarquiv) <> ?
                                         THEN TRUE
                                         ELSE FALSE.
       
       IF  LAST-OF(craptit.cdagenci) THEN
           ASSIGN tot_qtarquiv = tot_qtarquiv + 1.

       RUN proc_resgates.
   
   END.  /*  Fim do FOR EACH  --  Leitura dos lotes do dia  */    
    

   FOR EACH crawtit BREAK BY crawtit.cdbantit
                          BY crawtit.cdagenci
                          BY crawtit.cdbccxlt:
       
       ASSIGN aux_flgexist = TRUE.
       
       /* Nome de cada banco */
       IF   FIRST-OF(crawtit.cdbantit)   THEN
            DO:
                /* Se nao for o primeiro, quebra a pagina */
                IF   NOT FIRST(crawtit.cdbantit)   THEN
                     PAGE STREAM str_1.
                
                FIND crapban WHERE crapban.cdbccxlt = crawtit.cdbantit
                                   NO-LOCK NO-ERROR.
                                    
                DISPLAY STREAM str_1 crapban.cdbccxlt
                                     crapban.nmresbcc
                                     crapban.nmextbcc
                                     WITH FRAME f_banco.
                                     
                DISPLAY STREAM str_1 par_dtmvtolt aux_nmrescop
                          WITH FRAME f_cab_bbrasil.
            END.
       
       /* Primeira iteracao do FOR EACH, coloca o cabecalho */
       IF   FIRST(crawtit.cdbantit)   THEN
            DISPLAY STREAM str_1 par_dtmvtolt aux_nmrescop
                      WITH FRAME f_cab_bbrasil.
 
       IF   FIRST-OF(crawtit.cdagenci)   THEN
            DO:
                IF   LINE-COUNTER(str_1) > 70  THEN
                     DO:
                         PAGE STREAM str_1.
                       
                         DISPLAY STREAM str_1 par_dtmvtolt
                                              aux_nmrescop
                                   WITH FRAME f_cab_bbrasil.
                     END.
            END.
   

       ASSIGN pac_qtdlotes = pac_qtdlotes + 1
              pac_qttitulo = pac_qttitulo + crawtit.qttitulo
              pac_vltitulo = pac_vltitulo + crawtit.vltitulo.


       IF   aux_flgabert   THEN
            DO:
                RUN proc_lista.
                LEAVE.
            END.
            
       IF   NOT LAST-OF(crawtit.cdagenci)   THEN
            NEXT.   
               
       CLEAR FRAME f_pac_bbrasil.

       IF   LINE-COUNTER(str_1) > 70  THEN
            DO:
                PAGE STREAM str_1.

                DISPLAY STREAM str_1 par_dtmvtolt
                                     aux_nmrescop
                          WITH FRAME f_cab_bbrasil.
            END.

       ASSIGN tot_qttitulo = tot_qttitulo + crawtit.qttitulo
              tot_vltitulo = tot_vltitulo + crawtit.vltitulo 

              tot_qtdlotes = tot_qtdlotes + pac_qtdlotes

              ger_qttitulo = ger_qttitulo + pac_qttitulo
              ger_vltitulo = ger_vltitulo + pac_vltitulo

              pac_qtdlotes = 0
              pac_qttitulo = 0 
              pac_vltitulo = 0.

       IF  LAST-OF(crawtit.cdagenci) THEN DO:
           CLEAR FRAME f_totais_bbrasil.
           
           DISPLAY STREAM str_1  
                   crawtit.cdagenci  
                   crawtit.qttitulo
                   crawtit.vltitulo 
                   crawtit.flgachou
                   crawtit.nmarquiv
                   WITH FRAME f_totais_bbrasil.
           DOWN STREAM str_1 WITH FRAME f_totais_bbrasil.
       END.

       IF   LAST-OF(crawtit.cdbantit)   THEN
            DO:
                IF   LINE-COUNTER(str_1) > 70  THEN
                     DO:
                         PAGE STREAM str_1.
                         
                         DISPLAY STREAM str_1 par_dtmvtolt
                                              aux_nmrescop
                                   WITH FRAME f_cab_bbrasil.
                     END.

                CLEAR FRAME f_tot_bbrasil.

                DISPLAY STREAM str_1
                            tot_qttitvlb
                            tot_vltitvlb
                            tot_qttitinf
                            tot_vltitinf
                            tot_qttitulo
                            tot_vltitulo
                            tot_qtarquiv
                            WITH FRAME f_tot_bbrasil.
    
                ASSIGN tot_qttitulo = 0
                       tot_vltitulo = 0
                       tot_qttitvlb = 0
                       tot_vltitvlb = 0
                       tot_qttitinf = 0
                       tot_vltitinf = 0
                       tot_qtarquiv = 0.


                /* Assinatura */
                DISPLAY STREAM str_1
                        SKIP(2)
                        "                ARQUIVOS TRANSMITIDOS" AT 44
                        SKIP(5)
                        "_____________________________________" AT 44
                        SKIP
                        "   CADASTRO E VISTO DO FUNCIONARIO   " AT 44
                        WITH NO-LABELS NO-BOX WIDTH 80 FRAME f_visto.
            END.

   END.  /* FOR EACH crawtit */

   IF   NOT aux_flgabert   THEN
        DO:
            /* Total geral */
            IF   LINE-COUNTER(str_1) > 70  THEN
                 DO:
                     PAGE STREAM str_1.
                        
                     DISPLAY STREAM str_1 par_dtmvtolt 
                                          aux_nmrescop
                               WITH FRAME f_cab_bbrasil.
                 END.

            IF   LINE-COUNTER(str_1) > 65  THEN
                 PAGE STREAM str_1.
        END.

   glb_cdcritic = 0.

   PAGE STREAM str_1.

END.  /* Fim do DO .. TO  */

PUT STREAM str_1 CONTROL "\022\024\033\120" NULL.

PUT STREAM str_1 CONTROL "\0330\033x0" NULL.

OUTPUT  STREAM str_1 CLOSE.

IF   par_flgimpri THEN  /* Efetua impressao pela PRCCTL */  
     DO:
         IF  aux_flgexist  THEN 
             DO:          
                ASSIGN glb_nmformul = ""
                       glb_nrcopias = 1
                       glb_nmarqimp = aux_nmarqimp.

                MESSAGE "AGUARDE... Gerando relatorio... - COOPERATIVA: "
                          CAPS(crapcop.nmrescop).
                PAUSE 1 NO-MESSAGE.
            
                FIND FIRST crapass WHERE crapass.cdcooper = par_cdcooper  
                     NO-LOCK NO-ERROR.
            
                { includes/impressao.i }
            
                HIDE MESSAGE NO-PAUSE.
            
                IF   NOT par_flgcance   THEN
                     MESSAGE "Retire o relatorio da impressora!".
                ELSE
                     MESSAGE "Impressao cancelada!".
             END.                                
         ELSE
             DO:
                 ASSIGN glb_cdcritic = 263.
                 RUN fontes/critic.p.
                 BELL.
                 MESSAGE glb_dscritic " - COOPERATIVA: " CAPS(crapcop.nmrescop).
                 PAUSE 2 NO-MESSAGE.
                 HIDE MESSAGE.
                 ASSIGN glb_cdcritic = 0.
             END.
     END.
ELSE
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

         ASSIGN aux_nmarqpdf = "/micros/cecred/compel/O239_" + 
                               STRING(crapcop.cdagectl,"9999") + "_" +    
                               STRING(TIME,"99999") + "_" +
                               STRING(crapcop.cdbcoctl,"999") + ".pdf".

         /*** copiar arquivo para o diretorio 'compel' ***/
         UNIX SILENT VALUE("cp " + aux_nmarqimp + " " + "/micros/cecred/compel/" + 
                           REPLACE(SUBSTRING(aux_nmarqpdf,R-INDEX(aux_nmarqpdf,"/") + 1,
                           LENGTH(aux_nmarqpdf) - R-INDEX(aux_nmarqpdf,"/")),"pdf","txt")).

         UNIX SILENT VALUE("rm /micros/cecred/compel/0239_" + 
                           STRING(crapcop.cdagectl,"9999") + "* 2> /dev/null").

         /* GERAR PDF */
         RUN gera-pdf-impressao IN h-b1wgen0024(INPUT aux_nmarqimp,
                                                INPUT aux_nmarqpdf).

         DELETE PROCEDURE h-b1wgen0024.
     END.

/* .......................................................................... */

PROCEDURE mostra_dados:

    DEF VAR aux_nrdigito AS INT                                      NO-UNDO.

    /*  Compoe a linha digitavel atraves do codigo de barras  */

    ASSIGN tel_nrcampo1 = DECIMAL(SUBSTRING(tel_dscodbar,01,04) +
                                  SUBSTRING(tel_dscodbar,20,01) +
                                  SUBSTRING(tel_dscodbar,21,04) + "0")
                                  
           tel_nrcampo2 = DECIMAL(SUBSTRING(tel_dscodbar,25,10) + "0")
           tel_nrcampo3 = DECIMAL(SUBSTRING(tel_dscodbar,35,10) + "0")
           tel_nrcampo4 = INTEGER(SUBSTRING(tel_dscodbar,05,01))
           tel_nrcampo5 = DECIMAL(SUBSTRING(tel_dscodbar,06,14)).
           
    RUN dbo/pcrap03.p (INPUT-OUTPUT tel_nrcampo1,      
                       INPUT        TRUE,              /* Validar zeros */
                             OUTPUT aux_nrdigito,      /* Sem uso       */
                             OUTPUT glb_stsnrcal).

    RUN dbo/pcrap03.p (INPUT-OUTPUT tel_nrcampo2,      
                       INPUT        FALSE,             /* Validar zeros */
                             OUTPUT aux_nrdigito,      /* Sem uso       */
                             OUTPUT glb_stsnrcal).

    RUN dbo/pcrap03.p (INPUT-OUTPUT tel_nrcampo3,      
                       INPUT        FALSE,             /* Validar zeros */
                             OUTPUT aux_nrdigito,      /* Sem uso       */
                             OUTPUT glb_stsnrcal).

    tel_dsdlinha = STRING(tel_nrcampo1,"99999,99999")  + " " +
                   STRING(tel_nrcampo2,"99999,999999") + " " +
                   STRING(tel_nrcampo3,"99999,999999") + " " +
                   STRING(tel_nrcampo4,"9")            + " " +
                   STRING(tel_nrcampo5,"zzzzzzzzzzz999").

END PROCEDURE.

PROCEDURE proc_resgates:

    FOR EACH craptit WHERE craptit.cdcooper =  par_cdcooper       AND
                           craptit.dtmvtolt =  craplot.dtmvtolt   AND
                           craptit.cdagenci =  craplot.cdagenci   AND
                           craptit.cdbccxlt =  craplot.cdbccxlt   AND
                           craptit.nrdolote =  craplot.nrdolote   AND
                           craptit.dtdevolu <> ?                  AND
                           craptit.intitcop = 0                   AND
                          (craptit.flgenvio = par_flgenvio OR
                           craptit.flgenvio = par_flgenvi2) NO-LOCK:

        ASSIGN crawtit.qttitulo = crawtit.qttitulo - 1
               crawtit.vltitulo = crawtit.vltitulo - craptit.vldpagto.
    
    END.  /*  Fim do FOR EACH  -- craptit  */

END PROCEDURE.


PROCEDURE proc_lista:

    VIEW STREAM str_1 FRAME f_linha.
    
    FOR EACH craptit WHERE craptit.cdcooper = par_cdcooper       AND
                           craptit.dtmvtolt = par_dtmvtolt       AND
                           craptit.cdagenci = crawtit.cdagenci   AND
                           craptit.cdbccxlt = crawtit.cdbccxlt   AND
                           craptit.nrdolote = crawtit.nrdolote   AND
                           craptit.intitcop = 0                  AND
                          (craptit.flgenvio = par_flgenvio OR
                           craptit.flgenvio = par_flgenvi2)
                           USE-INDEX craptit2 NO-LOCK:

        aux_regexist = TRUE.
        
        tel_dscodbar = craptit.dscodbar.

        RUN mostra_dados.

        DISPLAY STREAM str_1 
                tel_dsdlinha 
                craptit.vldpagto 
                craptit.nrseqdig
                WITH FRAME f_lanctos.

        DOWN STREAM str_1 WITH FRAME f_lanctos.

        IF   LINE-COUNTER(str_1) > 70  THEN
             DO:
                 PAGE STREAM str_1.
                        
                 IF  par_cdcooper = 4 THEN
                     DO:
                         DISPLAY STREAM str_1 par_dtmvtolt
                                   WITH FRAME f_cab.
            
                         DISPLAY STREAM str_1  
                                 crawtit.cdagenci  crawtit.cdbccxlt  
                                 crawtit.nrdolote  crawtit.qttitulo
                                 crawtit.vltitulo  crawtit.nmoperad
                                 crawtit.flgachou  crawtit.nmarquiv
                                 WITH FRAME f_lotes.
                     END.
                 ELSE
                     DO:
                         DISPLAY STREAM str_1 par_dtmvtolt
                                              aux_nmrescop
                                   WITH FRAME f_cab_bbrasil.
            
                         DISPLAY STREAM str_1  
                                 crawtit.cdagenci  crawtit.qttitulo
                                 crawtit.vltitulo  
                                 crawtit.flgachou  crawtit.nmarquiv
                                 WITH FRAME f_totais_bbrasil.
                     END.
                     
                 VIEW STREAM str_1 FRAME f_linha.
             END.

    END.  /*  Fim do FOR EACH  */
    
    tel_dscodbar = "".

    VIEW STREAM str_1 FRAME f_linha.
    
END PROCEDURE.

/* .......................................................................... */

