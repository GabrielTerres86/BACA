/* ..........................................................................

   Programa: Fontes/titulo_r.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Edson
   Data    : Julho/2000.                     Ultima atualizacao: 02/06/2014

   Dados referentes ao programa:

   Frequencia: Diario (ON-LINE).
   Objetivo  : Emitir relatorio de lotes de titulos para envio ao BANCOOB
               (239).

   Alteracoes: 16/11/2000 - Alterar nrdolote p/6 posicoes (Margarete/Planner).
   
               10/01/2001 - Tratar somente tipo de lote 20 (Deborah).

               01/02/2001 - Acrescentar o NO-ERROR nos FIND's (Eduardo).
               
               01/09/2003 - Implementacao titulos do Banco do Brasil 
                            (Ze Eduardo).
                            
               29/01/2004 - Alterado p/ desprezar PAC selecionados(Mirtes)

               28/09/2005 - Modificado FIND FIRST para FIND na tabela 
                            crapcop.cdcooper = glb_cdcooper (Diego).
                            
               01/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando.
               
               09/02/2006 - Troca de WORKFILE para TEMP-TABLE e uso do 
                            comando EMPTY TEMP-TABLE - SQLWorks - Andre
                            
               23/02/2006 - Nao selecionar titulos da cooperativa
                            (Desprezar craptit.intitcop = 1)(Mirtes)

               05/04/2006 - Listar apenas titulos que nao sao da cooperativa,
                            inclusao do numero de lote (Julio)
                            
               03/11/2006 - Melhorar a performance do programa (Evandro).
               
               15/01/2007 - Modificada a temp-table crawage por causa da tela
                            titulo - BANCOOB;
                          - Tratamento para nome de arquivo BANCOOB (Evandro).

               05/09/2007 - Permitir PAC 90 somente separadamente (Evandro).

               20/08/2008 - Tratar praca de compensacao (Magui).
               
               11/09/2008 - Nao solicitar impressao quando arquivo estiver
                            vazio (Diego).

               04/11/2008 - Bloqueado a tecla "F4" (Martin).

               08/12/2008 - Chamar programa pcrap03.p no lugar do digm10.p
                            (David).
                            
               26/08/2009 - Substituicao do campo banco/agencia da COMPE, 
                            para o banco/agencia COMPE de TITULO (cdagetit e
                            cdbantit) - (Sidnei - Precise).
               01/10/2009 - Precise - Paulo - alterado para trabalhar com 
                            tabelas genericas.

               07/10/2009 - Precise - Guilherme. Alterado programa para nao  
                            se basear no codigo fixo 997 para CECRED, mas sim
                            utilizar o campo cdbcoctl da CRAPCOP

                          - Redefinir a crawage dos programas Titulo, Doctos,
                            Compel, para igualar a da BO b1wgen0012 
                            (Guilherme/Supero).

                          - Remover parte CECRED deste relatorio e repassar
                            para PRCCTL->B1WGEN0012->gerar_compel (19/05/2010)
                            (Guilherme/Supero)
                            
               15/06/2010 - Adaptacoes COMPE Nossa Remessa (Guilherme/Supero).
                          - Tratamento para PAC 91 - TAA (Elton).
                          
               02/06/2014 - Concatena o numero do servidor no endereco do
                            terminal (Tiago-RKAM).
               
............................................................................. */

DEF STREAM str_1.
DEF STREAM str_2.

DEF TEMP-TABLE crawage                                                  NO-UNDO
       FIELD  cdagenci      LIKE crapage.cdagenci
       FIELD  nmresage      LIKE crapage.nmresage
       FIELD  nmcidade      LIKE crapage.nmcidade 
       FIELD  cdbandoc      LIKE crapage.cdbandoc
       FIELD  cdbantit      LIKE crapage.cdbantit
       FIELD  cdagecbn      LIKE crapage.cdagecbn
       FIELD  cdbanchq      LIKE crapage.cdbanchq
       FIELD  cdcomchq      LIKE crapage.cdcomchq.
   
DEF INPUT PARAM par_dtmvtolt AS DATE                                 NO-UNDO.
DEF INPUT PARAM par_cdagenci AS INT                                  NO-UNDO.
DEF INPUT PARAM par_cdbccxlt AS INT                                  NO-UNDO.
DEF INPUT PARAM par_nrdolote AS INT                                  NO-UNDO.
DEF INPUT PARAM par_flgcontr AS LOGICAL                              NO-UNDO.
DEF INPUT PARAM TABLE FOR  crawage.    
DEF INPUT PARAM par_flgenvio AS LOGICAL                              NO-UNDO.
DEF INPUT PARAM par_flgenvi2 AS LOGICAL                              NO-UNDO.

DEF VAR par_flgrodar AS LOGICAL INIT TRUE                            NO-UNDO.
DEF VAR par_flgfirst AS LOGICAL INIT TRUE                            NO-UNDO.
DEF VAR par_flgcance AS LOGICAL                                      NO-UNDO.

DEF   VAR aux_cdagefim LIKE craptvl.cdagenci                         NO-UNDO.

DEF VAR aux_vltitulo AS DECIMAL                                      NO-UNDO.
DEF VAR aux_qttitulo AS INTEGER                                      NO-UNDO.

{ includes/var_online.i }

DEF TEMP-TABLE crawlot                                               NO-UNDO
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

DEF        VAR aux_nmendter AS CHAR    FORMAT "x(20)"                NO-UNDO.
DEF        VAR aux_nmarqimp AS CHAR                                  NO-UNDO.
DEF        VAR aux_dscomand AS CHAR                                  NO-UNDO.

DEF        VAR aux_confirma AS CHAR                                  NO-UNDO.

FORM par_dtmvtolt  AT   1   LABEL "REFERENCIA"   FORMAT "99/99/9999"
     SKIP(1)
     "PAC CXA    LOTE"           AT  1
     "   QTD.           VALOR"        
     "OPERADOR      ARQUIVO" 
     SKIP(1)
     WITH SIDE-LABELS NO-BOX WIDTH 132 FRAME f_cab.
      
FORM  crawlot.cdagenci AT  1               
      crawlot.cdbccxlt AT  5               
      crawlot.nrdolote AT  9 
      crawlot.qttitulo AT 17               
      crawlot.vltitulo AT 25             
      crawlot.nmoperad AT 41           
      crawlot.flgachou AT 52 FORMAT " /*"
      crawlot.nmarquiv AT 55 
      WITH NO-LABELS NO-BOX WIDTH 80 FRAME f_lotes.

FORM  SKIP(1)
      pac_qtdlotes        AT    9               NO-LABEL
      pac_qttitulo        AT   17               NO-LABEL
      pac_vltitulo        AT   26               NO-LABEL
      SKIP
      pac_dsdtraco        AT    4               NO-LABEL 
      WITH NO-LABELS NO-BOX  WIDTH 80 FRAME f_pac.
      
FORM  SKIP(1)
      "GERAL"             AT    1               
      tot_qtdlotes        AT    9               NO-LABEL
      tot_qttitulo        AT   17               NO-LABEL
      tot_vltitulo        AT   26               NO-LABEL
      WITH NO-LABELS NO-BOX WIDTH 80 FRAME f_tot.

FORM par_dtmvtolt  AT   1   LABEL "REFERENCIA"   FORMAT "99/99/9999"
     SKIP(1)
     "PAC  LOTE      QTD. TITULOS"         AT  1
     "VALOR   ARQUIVO"           AT 45       
     SKIP(1)
     WITH SIDE-LABELS NO-BOX WIDTH 132 FRAME f_cab_bbrasil.

FORM  crawlot.cdagenci AT  1 "|"           
      crawlot.nrdolote AT  6
      crawlot.qttitulo AT 21               
      crawlot.vltitulo AT 35             
      crawlot.flgachou AT 51 FORMAT " /*"
      crawlot.nmarquiv AT 53 
      WITH NO-LABELS NO-BOX WIDTH 80 FRAME f_lotes_bbrasil.
       
FORM  pac_dsdtraco        AT    1               NO-LABEL 
      SKIP
      pac_qtdlotes        AT    6               NO-LABEL
      pac_qttitulo        AT   21               NO-LABEL
      pac_vltitulo        AT   35               NO-LABEL
      SKIP(3)
      WITH NO-LABELS NO-BOX  WIDTH 80 FRAME f_pac_bbrasil.
 
FORM  SKIP(1)
      "TOTAL DO BANCO"    AT    1               
      tot_qttitulo        AT   21               NO-LABEL
      tot_vltitulo        AT   35               NO-LABEL
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
       glb_cdrelato[1] = 239
       pac_dsdtraco    = FILL("-",77)
       aux_flgexist    = FALSE.

ASSIGN aux_cdagefim    = IF par_cdagenci = 0  
                         THEN 9999
                         ELSE par_cdagenci.

{ includes/cabrel080_1.i }

aux_nmarqimp = "rl/O239_" + STRING(TIME,"99999") + ".lst".
       
HIDE MESSAGE NO-PAUSE.

/*  Gerenciamento da impressao  */

INPUT THROUGH basename `tty` NO-ECHO.

SET aux_nmendter WITH FRAME f_terminal.

INPUT CLOSE.

aux_nmendter = substr(glb_hostname,length(glb_hostname) - 1) +
                      aux_nmendter.

UNIX SILENT VALUE("rm rl/" + aux_nmendter + "* 2> /dev/null").
                            
OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGED PAGE-SIZE 84.
             
PUT STREAM str_1 CONTROL "\022\024\033\120" NULL.

PUT STREAM str_1 CONTROL "\0330\033x0" NULL.
                
VIEW STREAM str_1 FRAME f_cabrel080_1.

DO aux_contador = 1 TO 1:

   EMPTY TEMP-TABLE crawlot.

   FOR EACH craplot WHERE (craplot.cdcooper = glb_cdcooper     AND
                           craplot.dtmvtolt = par_dtmvtolt     AND
                           craplot.cdbccxlt = 11               AND 
                           craplot.tplotmov = 20               AND
                        (((craplot.cdagenci >= par_cdagenci    AND
                           craplot.cdagenci <= aux_cdagefim)   AND
                           craplot.cdagenci <> 90              AND
                           craplot.cdagenci <> 91)             OR
                          (craplot.cdagenci  = 90              AND
                           par_cdagenci      = 90)             OR
                          (craplot.cdagenci  = 91              AND
                           par_cdagenci      = 91)))                 OR
                          
                          (craplot.cdcooper = glb_cdcooper     AND
                           craplot.dtmvtopg = par_dtmvtolt     AND 
                           craplot.tplotmov = 20               AND
                        (((craplot.cdagenci >= par_cdagenci    AND
                           craplot.cdagenci <= aux_cdagefim)   AND
                           craplot.cdagenci <> 90              AND
                           craplot.cdagenci <> 91)             OR
                          (craplot.cdagenci  = 90              AND
                           par_cdagenci      = 90)             OR
                          (craplot.cdagenci  = 91              AND
                           par_cdagenci      = 91)))                  NO-LOCK,
                           
       EACH crawage WHERE  crawage.cdagenci  = craplot.cdagenci AND
                           crawage.cdbantit <> crapcop.cdbcoctl NO-LOCK
       BREAK BY craplot.cdagenci
                BY craplot.cdbccxlt
                   BY craplot.nrdolote:

       IF   par_cdbccxlt > 0   THEN
            IF   par_cdbccxlt <> craplot.cdbccxlt   THEN
                 NEXT.
 
       IF   par_nrdolote > 0   THEN
            IF   par_nrdolote <> craplot.nrdolote   THEN
                 NEXT.
     
       FIND crapope WHERE crapope.cdcooper = glb_cdcooper AND
                          crapope.cdoperad = craplot.cdoperad NO-LOCK NO-ERROR.
                          
       IF   NOT AVAILABLE crapope   THEN
            lot_nmoperad = craplot.cdoperad.
       ELSE
            lot_nmoperad = ENTRY(1,crapope.nmoperad," ").

       FIND crapage WHERE crapage.cdcooper = glb_cdcooper     AND
                          crapage.cdagenci = craplot.cdagenci NO-LOCK NO-ERROR.
       
       IF   NOT AVAILABLE crapage THEN
            DO:
                glb_cdcritic = 15.
                RUN fontes/critic.p.
                MESSAGE glb_dscritic.
                NEXT.
            END.
 
       IF  FIRST-OF(craplot.nrdolote) THEN       
           DO:

              ASSIGN aux_qttitulo = 0
                     aux_vltitulo = 0.

              FOR EACH craptit WHERE craptit.cdcooper = craplot.cdcooper    AND
                                     craptit.dtdpagto = craplot.dtmvtolt    AND
                                     CAN-DO("2,4",STRING(craptit.insittit)) AND
                                     craptit.tpdocmto = 20                  AND
                                     craptit.nrdolote = craplot.nrdolote    AND
                                     craptit.cdagenci = craplot.cdagenci    AND
                                     craptit.intitcop = 0
                                     NO-LOCK:

                  ASSIGN aux_vltitulo = aux_vltitulo + craptit.vldpagto
                         aux_qttitulo = aux_qttitulo + 1.
                         
              END.

           END.
       
       IF   MONTH(par_dtmvtolt) > 9 THEN
            CASE MONTH(par_dtmvtolt):
                 WHEN 10 THEN aux_mes = "O".
                 WHEN 11 THEN aux_mes = "N".
                 WHEN 12 THEN aux_mes = "D".
            END CASE.
       ELSE aux_mes = STRING(MONTH(par_dtmvtolt),"9").
       
       CREATE crawlot.
       
       ASSIGN crawlot.cdagenci = craplot.cdagenci
              crawlot.cdbccxlt = craplot.cdbccxlt
              crawlot.nrdolote = craplot.nrdolote
              crawlot.qttitulo = aux_qttitulo
              crawlot.vltitulo = aux_vltitulo
              crawlot.nmoperad = lot_nmoperad
              crawlot.cdbantit = crapage.cdbantit
              crawlot.nmarquiv = IF   crapage.cdbantit = 1   THEN /*BB*/
                                      "ti" +
                                      STRING(crapage.cdagetit, "99999") +
                                      STRING(DAY(par_dtmvtolt),"99") + 
                                      STRING(MONTH(par_dtmvtolt),"99") +
                                      STRING(craplot.cdagenci, "99") +
                                      "01.rem"
                                 ELSE
                                 IF   crapage.cdbantit = 756   THEN /*BANCOOB*/
                                      "ti" +
                                      STRING(crapcop.cdagebcb,"9999") + 
                                      STRING(MONTH(par_dtmvtolt),"99") +
                                      STRING(DAY(par_dtmvtolt),"99") + 
                                      STRING(crawlot.cdagenci,"999") +
                                      STRING(crawlot.nrdolote,"99999") + 
                                      ".CBE"
                                 ELSE "".

       IF   crapage.cdbantit = 1   THEN /*BB*/
            crawlot.flgachou = IF SEARCH("/micros/" + crapcop.dsdircop +
                                         "/compel/" + crawlot.nmarquiv) <> ?
                                         THEN TRUE
                                         ELSE FALSE.
       ELSE                                  
       IF   crapage.cdbantit = 756   THEN /*BANCOOB*/
            crawlot.flgachou = IF SEARCH("/micros/" + crapcop.dsdircop +
                                         "/bancoob/" + crawlot.nmarquiv) <> ?
                                         THEN TRUE
                                         ELSE FALSE.
       RUN proc_resgates.

   END.  /*  Fim do FOR EACH  --  Leitura dos lotes do dia  */    

   ASSIGN pac_qtdlotes = 0
          pac_qttitulo = 0
          pac_vltitulo = 0 
        
          tot_qtdlotes = 0 
          tot_qttitulo = 0
          tot_vltitulo = 0
          
          ger_qttitulo = 0
          ger_vltitulo = 0.
       
   IF   par_nrdolote > 0   THEN
        aux_flgabert = TRUE.
   ELSE
        aux_flgabert = FALSE.

   FOR EACH crawlot BREAK BY crawlot.cdbantit
                          BY crawlot.cdagenci
                          BY crawlot.cdbccxlt 
                          BY crawlot.nrdolote:
       
       ASSIGN aux_flgexist = TRUE.
       
       /* Nome de cada banco */
       IF   FIRST-OF(crawlot.cdbantit)   THEN
            DO:
                /* Se nao for o primeiro, quebra a pagina */
                IF   NOT FIRST(crawlot.cdbantit)   THEN
                     PAGE STREAM str_1.
                
                FIND crapban WHERE crapban.cdbccxlt = crawlot.cdbantit
                                   NO-LOCK NO-ERROR.
                                    
                DISPLAY STREAM str_1 crapban.cdbccxlt
                                     crapban.nmresbcc
                                     crapban.nmextbcc
                                     WITH FRAME f_banco.
                                     
                DISPLAY STREAM str_1 par_dtmvtolt WITH FRAME f_cab_bbrasil.
            END.
       
       /* Primeira iteracao do FOR EACH, coloca o cabecalho */
       IF   FIRST(crawlot.cdbantit)   THEN
            DISPLAY STREAM str_1 par_dtmvtolt WITH FRAME f_cab_bbrasil.
 
       IF   FIRST-OF(crawlot.cdagenci)   THEN
            DO:
                IF   LINE-COUNTER(str_1) > 70  THEN
                     DO:
                         PAGE STREAM str_1.
                       
                         DISPLAY STREAM str_1
                                      par_dtmvtolt WITH FRAME f_cab_bbrasil.
                     END.
            END.
   
       CLEAR FRAME f_lotes_bbrasil.
       
       DISPLAY STREAM str_1  
               crawlot.cdagenci  
               crawlot.nrdolote
               crawlot.qttitulo
               crawlot.vltitulo 
               crawlot.flgachou
               crawlot.nmarquiv
               WITH FRAME f_lotes_bbrasil.
            
       DOWN STREAM str_1 WITH FRAME f_lotes_bbrasil.
                   
       ASSIGN pac_qtdlotes = pac_qtdlotes + 1
              pac_qttitulo = pac_qttitulo + crawlot.qttitulo
              pac_vltitulo = pac_vltitulo + crawlot.vltitulo.

       IF   aux_flgabert   THEN
            DO:
                RUN proc_lista.
                LEAVE.
            END.
            
       IF   NOT LAST-OF(crawlot.cdagenci)   THEN
            NEXT.   
               
       CLEAR FRAME f_pac_bbrasil.

       DISPLAY STREAM str_1 
               pac_dsdtraco
               pac_qtdlotes  
               pac_qttitulo
               pac_vltitulo
               WITH FRAME f_pac_bbrasil.

       IF   LINE-COUNTER(str_1) > 70  THEN
            DO:
                PAGE STREAM str_1.
                       
                    /* DISPLAY STREAM str_1 par_dtmvtolt WITH FRAME f_cab.*/
                DISPLAY STREAM str_1 par_dtmvtolt WITH FRAME f_cab_bbrasil.
            END.
       
       ASSIGN tot_qtdlotes = tot_qtdlotes + pac_qtdlotes
              tot_qttitulo = tot_qttitulo + pac_qttitulo
              tot_vltitulo = tot_vltitulo + pac_vltitulo 

              ger_qttitulo = ger_qttitulo + pac_qttitulo
              ger_vltitulo = ger_vltitulo + pac_vltitulo
              
              pac_qtdlotes = 0
              pac_qttitulo = 0 
              pac_vltitulo = 0.
   
       IF   LAST-OF(crawlot.cdbantit)   THEN
            DO:
                IF   LINE-COUNTER(str_1) > 70  THEN
                     DO:
                         PAGE STREAM str_1.
                         
                         DISPLAY STREAM str_1 par_dtmvtolt 
                                      WITH FRAME f_cab_bbrasil.
                     END.

                CLEAR FRAME f_tot_bbrasil.
   
                DISPLAY STREAM str_1 
                        tot_qttitulo
                        tot_vltitulo
                        WITH FRAME f_tot_bbrasil.
                        
                ASSIGN tot_qttitulo = 0
                       tot_vltitulo = 0.
                       

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
   
   END.  /* FOR EACH crawlot */

   IF   NOT aux_flgabert   THEN
        DO:
            /* Total geral */
            IF   LINE-COUNTER(str_1) > 70  THEN
                 DO:
                     PAGE STREAM str_1.
                        
                     DISPLAY STREAM str_1 par_dtmvtolt 
                                    WITH FRAME f_cab_bbrasil.
                 END.

            IF   LINE-COUNTER(str_1) > 65  THEN
                 PAGE STREAM str_1.

            IF   par_cdagenci = 0   AND   par_flgcontr   THEN
                 DO:
                     RUN proc_conta_arq.
                 END.
        END.

   glb_cdcritic = 0.
   
   PAGE STREAM str_1.

END.  /* Fim do DO .. TO  */
                
PUT STREAM str_1 CONTROL "\022\024\033\120" NULL.

PUT STREAM str_1 CONTROL "\0330\033x0" NULL.
                      
OUTPUT  STREAM str_1 CLOSE.

ASSIGN glb_nmformul = ""
       glb_nrcopias = 1
       glb_nmarqimp = aux_nmarqimp.
                                    
IF   aux_flgexist  THEN 
     DO:          
         MESSAGE "AGUARDE... Imprimindo relatorio!".

         
         FIND FIRST crapass WHERE crapass.cdcooper = glb_cdcooper  
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

    FOR EACH craptit WHERE craptit.cdcooper =  glb_cdcooper       AND
                           craptit.dtmvtolt =  craplot.dtmvtolt   AND
                           craptit.cdagenci =  craplot.cdagenci   AND
                           craptit.cdbccxlt =  craplot.cdbccxlt   AND
                           craptit.nrdolote =  craplot.nrdolote   AND
                           craptit.dtdevolu <> ?                  AND
                           craptit.intitcop = 0                   AND
                          (craptit.flgenvio = par_flgenvio OR
                           craptit.flgenvio = par_flgenvi2) NO-LOCK:

        ASSIGN crawlot.qttitulo = crawlot.qttitulo - 1
               crawlot.vltitulo = crawlot.vltitulo - craptit.vldpagto.
    
    END.  /*  Fim do FOR EACH  -- craptit  */

END PROCEDURE.

PROCEDURE proc_conta_arq:

    DEF VAR aux_qtarquiv AS INT NO-UNDO.

    IF   glb_dtmvtolt <> par_dtmvtolt   THEN
         RETURN.
    
    
    /* INPUT STREAM str_2 THROUGH VALUE("ll /micros/" + crapcop.dsdircop +
                                          "/titulos*.CBE 2>/dev/null | " +
                                          "wc -l 2>/dev/null") NO-ECHO.
    */

    INPUT STREAM str_2 THROUGH VALUE("ll /micros/" + crapcop.dsdircop +
                                     "/compel/*.rem 2>/dev/null | " +
                                     "wc -l 2>/dev/null") NO-ECHO.

    
    DO WHILE TRUE ON ERROR UNDO, LEAVE ON ENDKEY UNDO, LEAVE:

       SET STREAM str_2
           aux_qtarquiv WITH NO-BOX NO-LABELS FRAME f_cbe.

    END.  /*  Fim do DO WHILE TRUE  */

    INPUT STREAM str_2 CLOSE.

END PROCEDURE.

PROCEDURE proc_lista:

    VIEW STREAM str_1 FRAME f_linha.
    
    FOR EACH craptit WHERE craptit.cdcooper = glb_cdcooper       AND
                           craptit.dtmvtolt = par_dtmvtolt       AND
                           craptit.cdagenci = crawlot.cdagenci   AND
                           craptit.cdbccxlt = crawlot.cdbccxlt   AND
                           craptit.nrdolote = crawlot.nrdolote   AND
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
                        
                 IF  glb_cdcooper = 4 THEN
                     DO:
                         DISPLAY STREAM str_1 par_dtmvtolt 
                                        WITH FRAME f_cab.
            
                         DISPLAY STREAM str_1  
                                 crawlot.cdagenci  crawlot.cdbccxlt  
                                 crawlot.nrdolote  crawlot.qttitulo
                                 crawlot.vltitulo  crawlot.nmoperad
                                 crawlot.flgachou  crawlot.nmarquiv
                                 WITH FRAME f_lotes.
                     END.
                 ELSE
                     DO:
                         DISPLAY STREAM str_1 par_dtmvtolt 
                                        WITH FRAME f_cab_bbrasil.
            
                         DISPLAY STREAM str_1  
                                 crawlot.cdagenci  crawlot.qttitulo
                                 crawlot.vltitulo  
                                 crawlot.flgachou  crawlot.nmarquiv
                                 WITH FRAME f_lotes_bbrasil.
                     END.
                     
                 VIEW STREAM str_1 FRAME f_linha.
             END.

    END.  /*  Fim do FOR EACH  */
    
    tel_dscodbar = "".

    VIEW STREAM str_1 FRAME f_linha.
    
END PROCEDURE.

/* .......................................................................... */

