/* ..........................................................................

   Programa: Fontes/crps010_1.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Abril/95.                           Ultima atualizacao: 14/02/2006

   Dados referentes ao programa:

   Frequencia: Mensal (Batch - Background).
   Objetivo  : Monta nome dos meses e inicializa resumo do capital.

   Alteracoes: 09/04/2001 - Tratar a tabela de VALORBAIXA somente nos meses
                            6 e 12 (Deborah).
                            
               14/02/2006 - Unificacao dos bancos - SQLWorks - Eder             
............................................................................. */

{ includes/var_batch.i }

{ includes/var_crps010.i }

IF   MONTH(glb_dtmvtolt) = 1   THEN
     ASSIGN rel_nomemes1 = aux_nmmesano[01]
            rel_nomemes2 = aux_nmmesano[12]
            rel_nomemes3 = aux_nmmesano[11].
ELSE
IF   MONTH(glb_dtmvtolt) = 2   THEN
     ASSIGN rel_nomemes1 = aux_nmmesano[02]
            rel_nomemes2 = aux_nmmesano[01]
            rel_nomemes3 = aux_nmmesano[12].
ELSE
IF   MONTH(glb_dtmvtolt) = 3   THEN
     ASSIGN rel_nomemes1 = aux_nmmesano[03]
            rel_nomemes2 = aux_nmmesano[02]
            rel_nomemes3 = aux_nmmesano[01].
ELSE
IF   MONTH(glb_dtmvtolt) = 4   THEN
     ASSIGN rel_nomemes1 = aux_nmmesano[04]
            rel_nomemes2 = aux_nmmesano[03]
            rel_nomemes3 = aux_nmmesano[02].
ELSE
IF   MONTH(glb_dtmvtolt) = 5   THEN
     ASSIGN rel_nomemes1 = aux_nmmesano[05]
            rel_nomemes2 = aux_nmmesano[04]
            rel_nomemes3 = aux_nmmesano[03].
ELSE
IF   MONTH(glb_dtmvtolt) = 6   THEN
     ASSIGN rel_nomemes1 = aux_nmmesano[06]
            rel_nomemes2 = aux_nmmesano[05]
            rel_nomemes3 = aux_nmmesano[04].
ELSE
IF   MONTH(glb_dtmvtolt) = 7   THEN
     ASSIGN rel_nomemes1 = aux_nmmesano[07]
            rel_nomemes2 = aux_nmmesano[06]
            rel_nomemes3 = aux_nmmesano[05].
ELSE
IF   MONTH(glb_dtmvtolt) = 8   THEN
     ASSIGN rel_nomemes1 = aux_nmmesano[08]
            rel_nomemes2 = aux_nmmesano[07]
            rel_nomemes3 = aux_nmmesano[06].
ELSE
IF   MONTH(glb_dtmvtolt) = 9   THEN
     ASSIGN rel_nomemes1 = aux_nmmesano[09]
            rel_nomemes2 = aux_nmmesano[08]
            rel_nomemes3 = aux_nmmesano[07].
ELSE
IF   MONTH(glb_dtmvtolt) = 10   THEN
     ASSIGN rel_nomemes1 = aux_nmmesano[10]
            rel_nomemes2 = aux_nmmesano[09]
            rel_nomemes3 = aux_nmmesano[08].
ELSE
IF   MONTH(glb_dtmvtolt) = 11   THEN
     ASSIGN rel_nomemes1 = aux_nmmesano[11]
            rel_nomemes2 = aux_nmmesano[10]
            rel_nomemes3 = aux_nmmesano[09].
ELSE
IF   MONTH(glb_dtmvtolt) = 12   THEN
     ASSIGN rel_nomemes1 = aux_nmmesano[12]
            rel_nomemes2 = aux_nmmesano[11]
            rel_nomemes3 = aux_nmmesano[10].

FIND FIRST crapmat WHERE crapmat.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.

IF   NOT AVAILABLE crapmat   THEN
     DO:
         glb_cdcritic = 71.
         RUN fontes/critic.p.
         UNIX SILENT VALUE ("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                            glb_cdprogra + "' --> '" + glb_dscritic +
                            " >> log/proc_batch.log").
         QUIT.
     END.

ASSIGN tot_nmresage = ""
       aux_dsdtraco = FILL("_",132)
       aux_dstraco2 = FILL("-",132)

       res_qtassati     = crapmat.qtassati
       res_qtassdem     = crapmat.qtassdem
       res_qtassmes     = crapmat.qtassmes
       res_qtdemmes_ati = crapmat.qtdemmes
       res_qtdemmes_dem = crapmat.qtdemmes
       res_qtassbai     = crapmat.qtassbai
       res_qtdesmes_ati = crapmat.qtdesmes
       res_qtdesmes_dem = crapmat.qtdesmes

       tot_qtassati = crapmat.qtassati +
                      crapmat.qtassmes +
                      crapmat.qtdesmes -
                      crapmat.qtdemmes

       tot_qtassdem = crapmat.qtassdem +
                      crapmat.qtdemmes -
                      crapmat.qtdesmes -
                      crapmat.qtassbai

       tot_qtassexc = crapmat.qtassbai.

RELEASE crapmat.

IF   CAN-DO("6,12",STRING(MONTH(glb_dtmvtolt)))   THEN
     DO:
         /*  Leitura da tabela com os valores do capital baixado  */

         FIND craptab WHERE craptab.cdcooper = glb_cdcooper  AND
                            craptab.nmsistem = "CRED"        AND
                            craptab.tptabela = "GENERI"      AND
                            craptab.cdempres = 0             AND
                            craptab.cdacesso = "VALORBAIXA"  AND
                            craptab.tpregist = 0             NO-LOCK NO-ERROR.

         IF   NOT AVAILABLE craptab   THEN
              DO:
                  glb_cdcritic = 409.
                  RUN fontes/critic.p.
                  UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                                    glb_cdprogra + "' --> '" + glb_dscritic +
                                    " >> log/proc_batch.log").
                  QUIT.
              END.

         ASSIGN res_vlcapcrz_exc = DECIMAL(SUBSTR(craptab.dstextab,001,016))
                res_vlcmicot_exc = DECIMAL(SUBSTR(craptab.dstextab,018,016))
                res_vlcmmcot_exc = DECIMAL(SUBSTR(craptab.dstextab,035,016))
                res_vlcapmfx_exc = DECIMAL(SUBSTR(craptab.dstextab,052,016))

                res_qtcotist_exc = tot_qtassexc

                res_vlcapcrz_tot = res_vlcapcrz_exc
                res_vlcmicot_tot = res_vlcmicot_exc
                res_vlcmmcot_tot = res_vlcmmcot_exc
                res_vlcapmfx_tot = res_vlcapmfx_exc

                res_qtcotist_tot = tot_qtassexc.
     END.
ELSE
     ASSIGN res_vlcapcrz_exc = 0
            res_vlcmicot_exc = 0
            res_vlcmmcot_exc = 0
            res_vlcapmfx_exc = 0
            res_qtcotist_exc = 0

            res_vlcapcrz_tot = 0
            res_vlcmicot_tot = 0
            res_vlcmmcot_tot = 0
            res_vlcapmfx_tot = 0
            res_qtcotist_tot = 0.

/* .......................................................................... */

