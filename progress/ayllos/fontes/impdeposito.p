/* .............................................................................

   Programa: Fontes/Impdeposito.p
   Sistema : Conta-Corrente - Cooperativa 
   Sigla   : CRED
   Autor   : Edson
   Data    : Novembro/2004                    Ultima atualizacao: 15/09/2014
   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Rotina para imprimir os depositos recebidos no caixa on-line.

   Alteracoes: 28/09/2005 - Modificado FIND FIRST para FIND na tabela 
                            crapcop.cdcooper = glb_cdcooper (Diego).
                            
               24/01/2006 - Unificacao dos Bancos - SQLWorks - Andre

               13/05/2008 - Ajuste comando FIND(craphis) utilizava FOR p/ acesso
                            (Sidnei - Precise)
                            
               14/07/2009 - Alteracao CDOPERAD (Diego).
               
               13/01/2011 - Incluido o format de 40 para o nmprimtl
                            (Kbase - Gilnei)
                            
               15/09/2014 - Alteração da Nomeclatura para PA (Vanessa).
............................................................................. */

{ includes/var_online.i }
{ includes/var_bcaixa.i }

DEF STREAM str_1.

/* utilizados pelo includes impressao.i */

DEF VAR tel_dsimprim AS CHAR    FORMAT "x(8)" INIT "Imprimir"        NO-UNDO.
DEF VAR tel_dscancel AS CHAR    FORMAT "x(8)" INIT "Cancelar"        NO-UNDO.

DEF VAR par_flgrodar AS LOGI                                         NO-UNDO.
DEF VAR par_flgfirst AS LOGI                                         NO-UNDO.
DEF VAR par_flgcance AS LOGI                                         NO-UNDO.
DEF VAR aux_dscomand AS CHAR                                         NO-UNDO.

DEF VAR rel_nmresage AS CHAR                                         NO-UNDO.
DEF VAR rel_nmrelato AS CHAR    FORMAT "x(40)" EXTENT 5              NO-UNDO.
DEF VAR rel_nmempres AS CHAR    FORMAT "x(15)"                       NO-UNDO.
DEF VAR rel_nrmodulo AS INT     FORMAT "9"                           NO-UNDO.
DEF VAR rel_nmmodulo AS CHAR    FORMAT "x(15)" EXTENT 5
                        INIT ["DEP. A VISTA   ","CAPITAL        ",
                              "EMPRESTIMOS    ","DIGITACAO      ",
                              "GENERICO       "]                     NO-UNDO.
DEF VAR aux_nmendter AS CHAR                                         NO-UNDO.
DEF VAR aux_contador AS INT                                          NO-UNDO.

DEF VAR rel_dsfechad AS CHAR                                         NO-UNDO.

DEF VAR rel_dtmvtolt LIKE crapbcx.dtmvtolt                           NO-UNDO.
DEF VAR rel_cdagenci LIKE crapbcx.cdagenci                           NO-UNDO.
DEF VAR rel_cdopecxa LIKE crapbcx.cdopecxa                           NO-UNDO. 
DEF VAR rel_nmoperad LIKE crapope.nmoperad                           NO-UNDO.
DEF VAR rel_nrdcaixa LIKE crapbcx.nrdcaixa                           NO-UNDO. 
DEF VAR rel_nrdmaqui like crapbcx.nrdmaqui                           NO-UNDO.
DEF VAR rel_nrdlacre like crapbcx.nrdlacre                           NO-UNDO.
DEF VAR rel_vldsdini LIKE crapbcx.vldsdini                           NO-UNDO.
DEF VAR rel_qtautent LIKE crapbcx.qtautent                           NO-UNDO.

DEF VAR aux_flgescra AS LOGICAL                                      NO-UNDO.
DEF VAR aux_flgouthi AS LOGICAL                                      NO-UNDO.
DEF VAR aux_opcimpri AS LOGICAL                                      NO-UNDO.

DEF VAR aux_qtlanmto AS INT                                          NO-UNDO.
DEF VAR aux_vllanmto AS DECIMAL                                      NO-UNDO.

DEF VAR aux_nrcoluna AS INT                                          NO-UNDO.

FORM HEADER
     "REFERENCIA:" rel_dtmvtolt 
     SKIP(1)
     "PA :" rel_cdagenci FORMAT "ZZ9" "-" rel_nmresage FORMAT "x(18)" SPACE(1)
     "OPERADOR:" rel_cdopecxa FORMAT "x(10)" "-" rel_nmoperad FORMAT "x(20)"
     SKIP(1)
     "CAIXA:" rel_nrdcaixa FORMAT "ZZ9" "AUTENTICADORA:" AT 16 rel_nrdmaqui
     FORMAT "ZZ9" "QTD. AUT.:" AT 39 rel_qtautent "LACRE:" AT 61 rel_nrdlacre
     SKIP(1)
     FILL("=",128)  FORMAT "x(128)"
     SKIP(1)
     WITH NO-BOX COLUMN aux_nrcoluna
          NO-LABELS PAGE-TOP WIDTH 128 FRAME f_cabec_boletim.
     
FORM HEADER     
     "SALDO INICIAL" FILL(".",96) FORMAT "x(96)" ":" rel_vldsdini
     SKIP(1)
     FILL("-",128) FORMAT "x(128)"
     WITH NO-BOX COLUMN aux_nrcoluna NO-LABELS WIDTH 128 FRAME f_inicio_boletim.
 
FORM HEADER
     "SALDO FINAL" FILL(".",98) FORMAT "x(98)" ":"
     aux_vldsdfin  FORMAT "zzz,zzz,zz9.99-" SKIP(1)
     FILL("=",128) FORMAT "x(128)"
     WITH NO-BOX COLUMN aux_nrcoluna NO-LABELS WIDTH 128 FRAME f_saldo_final.

FORM craplcm.nrdconta LABEL "CONTA/DV"  AT 10
     crapass.nmprimtl LABEL "NOME" FORMAT "x(40)"
     craplcm.nrautdoc LABEL "AUT"
     craplcm.nrdocmto LABEL "DOCUMENTO"
     craplcm.cdhistor LABEL "COD."
     craphis.dshistor LABEL "HISTORICO" FORMAT "x(15)"
     craplcm.vllanmto LABEL "VALOR"
     WITH NO-BOX COLUMN aux_nrcoluna DOWN NO-LABELS 
          WIDTH 128 FRAME f_depositos.

FORM HEADER
     FILL("-",128) FORMAT "x(128)" SKIP
     WITH NO-BOX COLUMN aux_nrcoluna DOWN WIDTH 128 FRAME f_traco.

FORM  SKIP(1)
      "VISTOS: "  
      rel_dsfechad AT 108 FORMAT "x(21)" NO-LABEL
      SKIP(4)
      "----------------------------"
      "----------------------------"
      "----------------------------"
      "-----------------------------"
      SKIP   
      SPACE(12) "CAIXA" SPACE(21) "COORDENADOR" SPACE(18) "TESOURARIA"
      SPACE(18) "CONTABILIDADE"
      WITH NO-BOX COLUMN aux_nrcoluna NO-LABELS WIDTH 128 FRAME f_vistos .

FORM SKIP(1)
     WITH NO-BOX COLUMN aux_nrcoluna NO-LABELS WIDTH 128 FRAME f_linha_branco.
     
FORM "Aguarde... Gerando relatorio de depositos!"
     WITH ROW 14 CENTERED OVERLAY ATTR-SPACE FRAME f_aguarde.

FORM SKIP(1)
     "ATENCAO!   Ligue a impressora e posicione o papel!" AT 3
     SKIP(1)
     tel_dsimprim AT 14
     tel_dscancel AT 29
     SKIP(1)
     WITH ROW 14 COLUMN 14 OVERLAY NO-LABELS WIDTH 56
          TITLE glb_nmformul FRAME f_atencao.

FORM SKIP(1)
     " ATENCAO!    AVISE A INFORMATICA URGENTE " 
     SKIP(1)
     "    HA LANCAMENTOS NOVOS NO CRAPHIS      "          
     SKIP(1)
     WITH ROW 10 OVERLAY NO-LABELS CENTERED FRAME f_novo_histor.

FORM SKIP(1)
     "RELACAO PARA SIMPLES CONFERENCIA DOS DEPOSITOS ACOLHIDOS" AT 40
     SKIP(1)
     WITH COLUMN aux_nrcoluna NO-BOX NO-LABELS WIDTH 128 FRAME f_label.

ASSIGN glb_cdprogra    = "bcaixa"
       glb_flgbatch    = FALSE
       glb_nrdevias    = 1
       glb_cdempres    = 11
       glb_cdrelato[1] = 258
       par_flgrodar    = TRUE.
       
INPUT THROUGH basename `tty` NO-ECHO.

SET aux_nmendter WITH FRAME f_terminal.

INPUT CLOSE.

UNIX SILENT VALUE("rm rl/" + aux_nmendter + "* 2> /dev/null").

ASSIGN aux_nmarqimp = "rl/" + aux_nmendter + STRING(TIME) + ".ex".

IF   NOT aux_tipconsu   THEN
     DO:
         { includes/cabrel132_1.i }  /* Monta cabecalho do relatorio */

         aux_nrcoluna = 5.
         
         OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGED PAGE-SIZE 84.
        
         VIEW STREAM str_1 FRAME f_cabrel132_1.
             
         /*  Configura a impressora para 1/8" - 17cpi */
         
         PUT STREAM str_1 CONTROL "\022\024\017" NULL.

         PUT STREAM str_1 CONTROL "\0330\033x0" NULL.
         
      END.
ELSE
      DO:
          aux_nrcoluna = 1.
          
          OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp). /* visualiza nao pode ter
                                                       caracteres de controle */
      END.
      
ASSIGN glb_cdcritic = 0
       aux_vlrttcrd = 0
       aux_vlrttdeb = 0.

/* Busca dados da cooperativa */

FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.

IF   NOT AVAILABLE crapcop THEN
     DO:
         glb_cdcritic = 651.
         RUN  fontes/critic.p.
         BELL.
         MESSAGE glb_dscritic.
         RETURN.
     END.

FIND crapbcx WHERE RECID(crapbcx) = aux_recidbol NO-LOCK NO-ERROR.

IF   NOT AVAILABLE crapbcx   THEN
     DO:
         ASSIGN glb_cdcritic = 11.
         RUN  fontes/critic.p.
         BELL.
         MESSAGE glb_dscritic.
         RETURN.
     END.

FIND crapage WHERE crapage.cdcooper = glb_cdcooper      AND
                   crapage.cdagenci = crapbcx.cdagenci  NO-LOCK NO-ERROR.

IF   NOT AVAILABLE crapage   THEN
     DO:
         ASSIGN glb_cdcritic = 15.
         RUN  fontes/critic.p.
         BELL.
         MESSAGE glb_dscritic.
         LEAVE.
     END.

FIND crapope WHERE crapope.cdcooper = glb_cdcooper      AND
                   crapope.cdoperad = crapbcx.cdopecxa  NO-LOCK NO-ERROR.

IF   NOT AVAILABLE crapope   THEN
     DO:
         ASSIGN glb_cdcritic = 702.
         RUN  fontes/critic.p.
         BELL.
         MESSAGE glb_dscritic.
         LEAVE.
     END.

ASSIGN rel_dtmvtolt = crapbcx.dtmvtolt 
       rel_cdagenci = crapbcx.cdagenci
       rel_nmresage = crapage.nmresage
       rel_cdopecxa = crapbcx.cdopecxa 
       rel_nmoperad = crapope.nmoperad
       rel_nrdcaixa = crapbcx.nrdcaixa
       rel_nrdmaqui = crapbcx.nrdmaqui
       rel_qtautent = crapbcx.qtautent
       rel_nrdlacre = crapbcx.nrdlacre
       rel_vldsdini = crapbcx.vldsdini
       aux_vldsdfin = crapbcx.vldsdfin
       aux_flgsemhi = no.

VIEW STREAM str_1 FRAME f_cabec_boletim.

VIEW STREAM str_1 FRAME f_inicio_boletim.

VIEW STREAM str_1 FRAME f_label.

FOR EACH craplcm WHERE craplcm.cdcooper = glb_cdcooper                AND
                       craplcm.dtmvtolt = crapbcx.dtmvtolt            AND
                       craplcm.cdagenci = crapbcx.cdagenci            AND
                       craplcm.nrdolote = (11000 + crapbcx.nrdcaixa)  AND 
                      (craplcm.cdhistor = 1                           OR
                       craplcm.cdhistor = 3                           OR
                       craplcm.cdhistor = 4                           OR 
                       craplcm.cdhistor = 386                         OR
                       craplcm.cdhistor = 372)                        NO-LOCK
                       USE-INDEX craplcm3
                       BY craplcm.nrautdoc
                          BY craplcm.nrdocmto:
                          
   FIND craphis NO-LOCK WHERE craphis.cdcooper = craplcm.cdcooper AND 
                              craphis.cdhistor = craplcm.cdhistor NO-ERROR.
   
   FIND crapass WHERE crapass.cdcooper = glb_cdcooper       AND
                      crapass.nrdconta = craplcm.nrdconta   NO-LOCK NO-ERROR.
   
   DISPLAY STREAM str_1
           craplcm.nrdconta
           crapass.nmprimtl
           craplcm.nrautdoc
           craplcm.nrdocmto
           craplcm.cdhistor
           craphis.dshistor
           craplcm.vllanmto 
           WITH FRAME f_depositos.

   DOWN STREAM str_1 WITH FRAME f_depositos.
   
   IF   LINE-COUNTER(str_1) > PAGE-SIZE(str_1)  THEN
        DO:
            VIEW STREAM str_1 FRAME f_cabec_boletim.

            VIEW STREAM str_1 FRAME f_inicio_boletim.

            VIEW STREAM str_1 FRAME f_label.
        END.

   ASSIGN aux_qtlanmto = aux_qtlanmto + 1
          aux_vllanmto = aux_vllanmto + craplcm.vllanmto.

END.  /*  Fim do FOR EACH -- craplcm  */

DISPLAY STREAM str_1
        SKIP(1)
        aux_qtlanmto AT  10 "DEPOSITOS"
        aux_vllanmto AT 105 FORMAT "zzz,zzz,zz9.99"
        SKIP(1)
        WITH COLUMN aux_nrcoluna NO-BOX NO-LABELS WIDTH 128 FRAME f_total.

VIEW STREAM str_1 FRAME f_traco.
 
VIEW STREAM str_1 FRAME f_saldo_final.
/*
IF   NOT aux_tipconsu   THEN
     DO:
         IF   LINE-COUNTER(str_1) > 72   THEN
              PAGE STREAM str_1.

         IF   crapbcx.cdsitbcx = 2   THEN
              rel_dsfechad = "  ** CAIXA FECHADO **".
         ELSE
              rel_dsfechad = "   ** CAIXA ABERTO **".

         DISPLAY STREAM str_1 rel_dsfechad WITH FRAME f_vistos.        
     END.
*/
OUTPUT STREAM str_1 CLOSE.

IF   aux_flgsemhi   THEN
     DO:
         HIDE FRAME f_novo_histor.
         RETURN.
     END.

VIEW FRAME f_aguarde.

PAUSE 3 NO-MESSAGE.

HIDE FRAME f_aguarde NO-PAUSE.

IF   NOT aux_tipconsu   THEN
     DO:
         /*** nao necessario ao programa somente para nao dar erro 
              de compilacao na rotina de impressao ****/
         FIND FIRST crapass WHERE crapass.cdcooper = glb_cdcooper
                                  NO-LOCK NO-ERROR.

         { includes/impressao.i } 

         HIDE MESSAGE NO-PAUSE.

     END.

/* .......................................................................... */

