/* ..........................................................................

   Programa: Fontes/titcto_lote.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Guilherme
   Data    : Setembro/2008.                  Ultima atualizacao: 02/06/2014 

   Dados referentes ao programa:

   Frequencia: Diario (ON-LINE).
   Objetivo  : Gerar relatorio de lotes de titulos descontados.

   Alteracoes: 24/08/2012 - Alterações para apresentar resultados
                            de acordo com o Tipo de Cobrança (Lucas).
               
               15/08/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).  
                            
               02/06/2014 - Concatena o numero do servidor no endereco do
                            terminal (Tiago-RKAM).

............................................................................. */

{ includes/var_online.i }
  
DEF   STREAM str_1.

DEF INPUT PARAM par_dtmvtolt AS DATE                                 NO-UNDO.
DEF INPUT PARAM par_cdagenci AS INT                                  NO-UNDO.

DEF   VAR par_flgrodar AS LOG  INIT TRUE                             NO-UNDO.
DEF   VAR par_flgfirst AS LOG  INIT TRUE                             NO-UNDO.
DEF   VAR par_flgcance AS LOG                                        NO-UNDO.

DEF TEMP-TABLE crawlot                                               NO-UNDO
    FIELD dtmvtolt AS DATE       FORMAT "99/99/9999"
    FIELD cdagenci AS INT        FORMAT "zzz9"
    FIELD nrdconta AS INT        FORMAT "zzzz,zzz,9"
    FIELD nrborder AS INT        FORMAT "z,zzz,zz9"
    FIELD nrdolote AS INT        FORMAT "zzz,zz9"
    FIELD qttittot_cr AS INT     FORMAT "zz9"
    FIELD qttittot_sr AS INT     FORMAT "zz9"
    FIELD vltittot_cr AS DECIMAL FORMAT "zzz,zzz,zz9.99"
    FIELD vltittot_sr AS DECIMAL FORMAT "zzz,zzz,zz9.99"
    FIELD nmoperad AS CHAR       FORMAT "x(15)"
    INDEX crawlot1 dtmvtolt cdagenci nrdolote.
                                                                     
DEF   VAR rel_nmempres AS CHAR FORMAT "x(15)"                        NO-UNDO.
DEF   VAR rel_nmrelato AS CHAR FORMAT "x(40)" EXTENT 5               NO-UNDO.

DEF   VAR rel_nrmodulo AS INT  FORMAT "9"                            NO-UNDO.
DEF   VAR rel_nmmodulo AS CHAR FORMAT "x(15)" EXTENT 5
                               INIT ["DEP. A VISTA   ","CAPITAL        ",
                                     "EMPRESTIMOS    ","DIGITACAO      ",
                                     "GENERICO       "]              NO-UNDO.

DEF   VAR rel_dsdsaldo AS CHAR                                       NO-UNDO.

DEF   VAR pac_vltittot_sr AS DECI FORMAT "zzz,zzz,zz9.99"               NO-UNDO.
DEF   VAR pac_vltittot_cr AS DECI FORMAT "zzz,zzz,zz9.99"               NO-UNDO.
DEF   VAR tot_vltittot_sr AS DECI FORMAT "zzz,zzz,zz9.99"               NO-UNDO.
DEF   VAR tot_vltittot_cr AS DECI FORMAT "zzz,zzz,zz9.99"               NO-UNDO.
DEF   VAR pac_qttittot_sr AS INT  FORMAT "zzz9"                         NO-UNDO.
DEF   VAR pac_qttittot_cr AS INT  FORMAT "zzz9"                         NO-UNDO.
DEF   VAR tot_qttittot_sr AS INT  FORMAT "zzz9"                         NO-UNDO.
DEF   VAR tot_qttittot_cr AS INT  FORMAT "zzz9"                         NO-UNDO.


DEF   VAR pac_qtdlotes AS INT  FORMAT "zz9"                          NO-UNDO.
DEF   VAR tot_qtdlotes AS INT  FORMAT "zz9"                          NO-UNDO.

DEF   VAR pac_dsdtraco AS CHAR FORMAT "X(132)"                       NO-UNDO.
DEF   VAR lot_nmoperad AS CHAR FORMAT "x(10)"                        NO-UNDO.

DEF   VAR tel_dsimprim AS CHAR FORMAT "x(8)" INIT "Imprimir"         NO-UNDO.
DEF   VAR tel_dscancel AS CHAR FORMAT "x(8)" INIT "Cancelar"         NO-UNDO.

DEF   VAR aux_flgfirst AS LOG                                        NO-UNDO.
DEF   VAR aux_regexist AS LOG                                        NO-UNDO.
DEF   VAR aux_flgescra AS LOG                                        NO-UNDO.

DEF   VAR aux_contador AS INT                                        NO-UNDO.

DEF   VAR aux_nmendter AS CHAR FORMAT "x(20)"                        NO-UNDO.
DEF   VAR aux_nmarqimp AS CHAR                                       NO-UNDO.
DEF   VAR aux_dscomand AS CHAR                                       NO-UNDO.

DEF   VAR aux_dtpridia AS DATE                                       NO-UNDO.
DEF   VAR aux_dtultdia AS DATE                                       NO-UNDO.
DEF   VAR aux_nmmesref AS CHAR                                       NO-UNDO.
DEF   VAR rel_nmmesref AS CHAR FORMAT "x(15)"                        NO-UNDO.

FORM par_dtmvtolt  AT   1   LABEL "REFERENCIA"   FORMAT "99/99/9999"
     rel_dsdsaldo  AT  30   NO-LABEL             FORMAT "x(25)"
     SKIP(1)
     SKIP
     "DIGITADO EM PA    LOTE   CONTA/DV   BORDERO QTD.REG QTD.S/REG    VALOR REG.  VALOR S/REG."
     "OPERADOR" 
     SKIP
     "----------- --- ------- ---------- --------- ------- --------- ------------- -------------"
     "----------------"
     SKIP
     WITH SIDE-LABELS NO-BOX WIDTH 132 FRAME f_cab.
      
FORM  crawlot.dtmvtolt      AT 1      
      crawlot.cdagenci      AT 12                    
      crawlot.nrdolote      AT 17       
      crawlot.nrdconta      AT 25
      crawlot.nrborder      AT 36
      crawlot.qttittot_cr   AT 50
      crawlot.qttittot_sr   AT 60
      crawlot.vltittot_cr   AT 63
      crawlot.vltittot_sr   AT 77
      crawlot.nmoperad                      
      WITH NO-LABELS NO-BOX WIDTH 132 FRAME f_lotes.
      
FORM  SKIP(1)
      "TOTAL DO PA ==>"  AT    1               
      pac_qtdlotes        AT   21               NO-LABEL "LOTE(S)"
      pac_qttittot_cr     AT   49               NO-LABEL
      pac_qttittot_sr     AT   59               NO-LABEL
      pac_vltittot_cr     AT   63               NO-LABEL
      pac_vltittot_sr     AT   77               NO-LABEL
      SKIP(1)
      pac_dsdtraco        AT    1               NO-LABEL 
      SKIP(1)
      WITH NO-LABELS NO-BOX WIDTH 132 FRAME f_pac.
      
FORM  SKIP
      "TOTAL GERAL ==>"   AT    1               
      tot_qtdlotes        AT   21               NO-LABEL "LOTE(S)"
      tot_qttittot_cr     AT   49               NO-LABEL
      tot_qttittot_sr     AT   59               NO-LABEL
      tot_vltittot_cr     AT   63               NO-LABEL
      tot_vltittot_sr     AT   77               NO-LABEL
      WITH NO-LABELS NO-BOX WIDTH 132 FRAME f_tot.

FORM SKIP(1)
     "ATENCAO!   Ligue a impressora e posicione o papel!" AT 3
     SKIP(1)
     tel_dsimprim AT 14
     tel_dscancel AT 29
     SKIP(1)
     WITH ROW 14 COLUMN 14 OVERLAY NO-LABELS WIDTH 56
          TITLE glb_nmformul FRAME f_atencao.

FORM HEADER   glb_nmrescop               AT   1 FORMAT "x(15)"
              "-"                        AT  16
              "Opcao Lotes"              AT  18 
              "- REF."                   AT  58
              glb_dtmvtolt               AT  65 FORMAT "99/99/99"
              "TITCTO/"                  AT  86
              glb_progerad               AT  94 FORMAT "x(03)"
              "EM"                       AT  98
              TODAY                      AT 101 FORMAT "99/99/99"
              "AS"                       AT 110
              STRING(TIME,"HH:MM")       AT 113 FORMAT "x(5)"
              "HR PAG.:"                 AT 119
              PAGE-NUMBER(str_1)         AT 127 FORMAT "zzzz9"
              SKIP(2)
            "Listagem de lotes de descontos de titulos efetuados na data" AT 37
            "-----------------------------------------------------------" AT 37
            WITH PAGE-TOP NO-BOX NO-ATTR-SPACE WIDTH 132 FRAME f_cabecalho.

ASSIGN glb_cdcritic    = 0
       pac_dsdtraco    = FILL("-",132).

HIDE MESSAGE NO-PAUSE.

/*  Gerenciamento da impressao  */

INPUT THROUGH basename `tty` NO-ECHO.

SET aux_nmendter WITH FRAME f_terminal.

INPUT CLOSE.

aux_nmendter = substr(glb_hostname,length(glb_hostname) - 1) +
                      aux_nmendter.

ASSIGN aux_nmarqimp = "rl/" + aux_nmendter + STRING(TIME,"99999") + ".ex".

UNIX SILENT VALUE("rm rl/" + aux_nmendter + "* 2> /dev/null").

MESSAGE "AGUARDE... IMPRIMINDO RELATORIO!".

ASSIGN glb_cdrelato[1] = 539
       glb_cdempres    = 11.

OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGED PAGE-SIZE 84.

VIEW STREAM str_1 FRAME f_cabecalho.
 
DO aux_contador = 1 TO 1:

   rel_dsdsaldo = IF par_cdagenci > 0   
                     THEN "    ** DO PA " + STRING(par_cdagenci,"zz9") +
                          " **"
                     ELSE "      ** GERAL **".

   EMPTY TEMP-TABLE crawlot.  
     
   IF  par_dtmvtolt = ?  THEN
       DO:
           ASSIGN aux_dtpridia = DATE(MONTH(glb_dtmvtolt),01,YEAR(glb_dtmvtolt))
                  aux_dtultdia = ((DATE(MONTH(glb_dtmvtolt),28,
                                         YEAR(glb_dtmvtolt)) + 4) -
                                            DAY(DATE(MONTH(glb_dtmvtolt),28,
                                                     YEAR(glb_dtmvtolt)) + 4))
                  aux_nmmesref = "JANEIRO/,FEVEREIRO/,MARCO/," +
                                 "ABRIL/,MAIO/,JUNHO/," +
                                 "JULHO/,AGOSTO/,SETEMBRO/,OUTUBRO/," +
                                 "NOVEMBRO/,DEZEMBRO/"              
                  rel_nmmesref = ENTRY(MONTH(glb_dtmvtolt),aux_nmmesref) +
                                      STRING(YEAR(glb_dtmvtolt),"9999").

           DISPLAY STREAM str_1 rel_nmmesref @ par_dtmvtolt 
                                rel_dsdsaldo WITH FRAME f_cab.

       END.
   ELSE
       DO:
           ASSIGN aux_dtpridia = par_dtmvtolt
                  aux_dtultdia = par_dtmvtolt.

           DISPLAY STREAM str_1 par_dtmvtolt rel_dsdsaldo WITH FRAME f_cab.
       END.
   
   FOR EACH crapbdt NO-LOCK WHERE crapbdt.cdcooper  = glb_cdcooper  AND
                                  crapbdt.dtlibbdt >= aux_dtpridia  AND
                                  crapbdt.dtlibbdt <= aux_dtultdia, 
       EACH craptdb WHERE craptdb.cdcooper = crapbdt.cdcooper AND
                          craptdb.nrdconta = crapbdt.nrdconta AND
                          craptdb.nrborder = crapbdt.nrborder NO-LOCK,
       EACH crapcob WHERE crapcob.cdcooper = craptdb.cdcooper AND
                          crapcob.nrdconta = craptdb.nrdconta AND
                          crapcob.nrcnvcob = craptdb.nrcnvcob AND
                          crapcob.nrdocmto = craptdb.nrdocmto NO-LOCK
                          BREAK BY crapbdt.dtmvtolt
                                  BY crapbdt.cdagenci
                                    BY craptdb.cdbandoc
                                      BY crapbdt.nrdolote:
       
       IF   par_cdagenci > 0   THEN
            IF   crapbdt.cdagenci <> par_cdagenci   THEN
                 NEXT.
       
       FIND crawlot WHERE crawlot.dtmvtolt = crapbdt.dtmvtolt   AND
                          crawlot.cdagenci = crapbdt.cdagenci   AND
                          crawlot.nrdolote = crapbdt.nrdolote   NO-ERROR.
       
       IF   NOT AVAILABLE crawlot   THEN
            DO:
               FIND crapope WHERE crapope.cdcooper = glb_cdcooper       AND
                                  crapope.cdoperad = craptdb.cdoperad      
                                  NO-LOCK NO-ERROR.
    
                IF   NOT AVAILABLE crapope   THEN
                     lot_nmoperad = craptdb.cdoperad.
                ELSE
                     lot_nmoperad = crapope.cdoperad + "-" +
                                    ENTRY(1,crapope.nmoperad," ").

                CREATE crawlot.      
                ASSIGN crawlot.dtmvtolt = crapbdt.dtmvtolt
                       crawlot.cdagenci = crapbdt.cdagenci
                       crawlot.nrdconta = craptdb.nrdconta
                       crawlot.nrdolote = crapbdt.nrdolote
                       crawlot.nrborder = crapbdt.nrborder
                       crawlot.nmoperad = lot_nmoperad.
            END.

       IF  crapcob.flgregis = TRUE  THEN        
           ASSIGN crawlot.qttittot_cr = crawlot.qttittot_cr + 1
                  crawlot.vltittot_cr = crawlot.vltittot_cr + craptdb.vltitulo.
       ELSE
       IF  crapcob.flgregis = FALSE THEN
           ASSIGN crawlot.qttittot_sr = crawlot.qttittot_sr + 1
                  crawlot.vltittot_sr = crawlot.vltittot_sr + craptdb.vltitulo.
              
   END.  /*  Fim do FOR EACH  --  Leitura dos lotes do dia  */    

   ASSIGN pac_qtdlotes = 0
          pac_qttittot_sr = 0 
          pac_qttittot_cr = 0
          pac_vltittot_sr = 0
          pac_vltittot_cr = 0
          tot_qttittot_sr = 0
          tot_qttittot_cr = 0
          tot_vltittot_sr = 0
          tot_vltittot_cr = 0
          tot_qtdlotes = 0.

   FOR EACH crawlot BREAK BY crawlot.cdagenci
                             BY crawlot.dtmvtolt
                                BY crawlot.nrdolote:

       IF   FIRST-OF(crawlot.cdagenci)   THEN
            DO:
                IF   LINE-COUNTER(str_1) > 80  THEN
                     DO:
                         PAGE STREAM str_1.
                       
                         IF  par_dtmvtolt = ?  THEN
                             DISPLAY STREAM str_1 rel_nmmesref @ par_dtmvtolt 
                                                  rel_dsdsaldo WITH FRAME f_cab.
                         ELSE
                             DISPLAY STREAM str_1 par_dtmvtolt rel_dsdsaldo 
                                                  WITH FRAME f_cab.            
                     END.
            END.
   
       CLEAR FRAME f_lotes.
       
       DISPLAY STREAM str_1  
               crawlot.dtmvtolt
               crawlot.cdagenci  
               crawlot.nrdconta  
               crawlot.nrborder
               crawlot.nrdolote 
               crawlot.qttittot_cr
               crawlot.qttittot_sr 
               crawlot.vltittot_cr 
               crawlot.vltittot_sr 
               crawlot.nmoperad
               WITH FRAME f_lotes.

       ASSIGN pac_qtdlotes = pac_qtdlotes + 1.

       ASSIGN pac_qttittot_cr = pac_qttittot_cr + crawlot.qttittot_cr
              pac_vltittot_cr = pac_vltittot_cr + crawlot.vltittot_cr
              pac_qttittot_sr = pac_qttittot_sr + crawlot.qttittot_sr
              pac_vltittot_sr = pac_vltittot_sr + crawlot.vltittot_sr.

       DOWN STREAM str_1 WITH FRAME f_lotes.                      

       IF   NOT LAST-OF(crawlot.cdagenci)   THEN
            NEXT.   
               
       CLEAR FRAME f_pac.
       
       DISPLAY STREAM str_1 
               pac_qtdlotes  
               pac_qttittot_sr  
               pac_qttittot_cr  
               pac_vltittot_sr
               pac_vltittot_cr
               pac_dsdtraco
               WITH FRAME f_pac.

       IF   LINE-COUNTER(str_1) > 80  THEN
            DO:
                PAGE STREAM str_1.
            
                IF  par_dtmvtolt = ?  THEN
                    DISPLAY STREAM str_1 rel_nmmesref @ par_dtmvtolt 
                                    rel_dsdsaldo WITH FRAME f_cab.
                ELSE
                    DISPLAY STREAM str_1 par_dtmvtolt rel_dsdsaldo 
                                    WITH FRAME f_cab.             
            END.
       
       ASSIGN tot_qtdlotes = tot_qtdlotes + pac_qtdlotes
              tot_qttittot_sr = tot_qttittot_sr + pac_qttittot_sr
              tot_qttittot_cr = tot_qttittot_cr + pac_qttittot_cr
              tot_vltittot_sr = tot_vltittot_sr + pac_vltittot_sr
              tot_vltittot_cr = tot_vltittot_cr + pac_vltittot_cr
              pac_qtdlotes = 0
              pac_qttittot_sr = 0 
              pac_qttittot_cr = 0 
              pac_vltittot_sr = 0
              pac_vltittot_cr = 0.
                     
   END.  /* FOR EACH crawlot */   
   
   IF   LINE-COUNTER(str_1) > 80  THEN
        DO:
            PAGE STREAM str_1.
                     
            IF  par_dtmvtolt = ?  THEN
                DISPLAY STREAM str_1 rel_nmmesref @ par_dtmvtolt 
                                     rel_dsdsaldo WITH FRAME f_cab.
            ELSE
                DISPLAY STREAM str_1 par_dtmvtolt rel_dsdsaldo WITH FRAME f_cab.
        END.

   CLEAR FRAME f_tot.
   
   DISPLAY STREAM str_1 
                  tot_qtdlotes  
                  tot_qttittot_cr
                  tot_qttittot_sr  
                  tot_vltittot_cr  
                  tot_vltittot_sr  
                  WITH FRAME f_tot.

   IF   LINE-COUNTER(str_1) > 65  THEN
        PAGE STREAM str_1.

   DISPLAY STREAM str_1
           SKIP(5)
           "____________________________________" AT 50 SKIP
           "  CADASTRO E VISTO DO FUNCIONARIO   " AT 50
           WITH NO-LABELS NO-BOX WIDTH 120 FRAME f_visto.
 
   PAGE STREAM str_1.

END.  /*  Fim do DO .. TO  */

OUTPUT  STREAM str_1 CLOSE.

ASSIGN glb_nmformul = "132col"
       glb_nrcopias = 1
       glb_nmarqimp = aux_nmarqimp.

FIND FIRST crapass WHERE crapass.cdcooper = glb_cdcooper  NO-LOCK NO-ERROR.

{ includes/impressao.i }

HIDE MESSAGE NO-PAUSE.

IF   NOT par_flgcance   THEN
     MESSAGE "RETIRE O RELATORIO DA IMPRESSORA!".
ELSE
     MESSAGE "IMPRESSAO CANCELADA!".

/* .......................................................................... */
