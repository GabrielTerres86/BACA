/* .............................................................................

   Programa: Fontes/seguro_s.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Julho/97.                           Ultima atualizacao: 12/08/2015
   
   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Rotina para tratamento da substituicao da proposta de seguro.

   Alteracoes: 19/08/97 - Alterado para tratar seguro auto em mais de uma segu-
                          radora e tratar pagto com parcela unica (Edson).

               12/09/97 - Alterado para deixar passar valores de verba especial
                          e danos morais iguais a tabela (Deborah).

               05/11/97 - Alterado para permitir substituicao de seguro auto
                          com pagamento unico e coberturas extras (Edson).

               02/08/1999 - Tratar seguro de vida em grupo (Deborah).
               
               15/03/2002 - Tratamento de valores parcelados (Ze Eduardo).

               19/07/2004 - Tirado consistencia da flgunica (Deborah).

               30/03/2005 - Acertos para novo modelo de cadastramento de
                            seguro - Unibanco (Evandro).
               
               20/04/2005 - Retirada a critica para o seguro do tipo 11        
                            (Diego).
                            
               05/07/2005 - Alimentado campo cdcooper da tabela crawseg (Diego)
               
               13/09/2005 - Liberar acerto para Concredi (Edson).
               
               01/12/2005 - Tratamento para seguro SUL AMERICA-CASA (Evandro).

               21/12/2005 - Liberado opcao "Acerto" para Operadores 
                            105 e 199(CHAMADO 14860) (Mirtes)               

               01/02/2006 - Unificacao dos Bancos - SQLWorks - Luciane.
               
               01/09/2008 - Alteracao CDEMPRES (Kbase) - Eduardo Silva.

               22/04/2009 - Retirado tudo o que for do seguro AUTO (Gabriel).
               
               14/12/2009 - Nao permitir substituicao para seguros residenciais
                            (David).
                            
               12/08/2015 - Projeto Reformulacao cadastral
                            Eliminado o campo nmdsecao (Tiago Castro - RKAM).
                            
............................................................................. */

DEF INPUT PARAM par_recidseg AS INT                                  NO-UNDO.

{ includes/var_online.i }
{ includes/var_atenda.i }
{ includes/var_seguro.i }

DEF VAR tel_dsacerto AS CHAR INIT "Acerto"                           NO-UNDO.
DEF VAR tel_dssubsti AS CHAR INIT "Substituicao"                     NO-UNDO.

DEF VAR aux_dsnaoinf AS CHAR INIT "** NAO INFORMADO **"              NO-UNDO.
DEF VAR aux_lsoperad AS CHAR INIT "1,30,49"                          NO-UNDO.
DEF VAR aux_lsctrant AS CHAR                                         NO-UNDO.

DEF VAR aux_vlpreseg AS DECIMAL                                      NO-UNDO.
DEF VAR aux_vldifseg AS DECIMAL                                      NO-UNDO.

DEF VAR aux_flgacert AS LOGICAL                                      NO-UNDO.

FORM " "
     tel_dssubsti FORMAT "x(12)" " "
     tel_dsacerto FORMAT "x(6)" " "
     WITH ROW 15 CENTERED OVERLAY NO-LABELS FRAME f_acerto.

DO WHILE TRUE TRANSACTION ON ENDKEY UNDO, LEAVE:

   DO WHILE TRUE:

      FIND crapseg WHERE RECID(crapseg) = par_recidseg NO-LOCK NO-ERROR.

      IF   NOT AVAILABLE crapseg   THEN
           DO:
               glb_cdcritic = 524.
               RETURN.
           END.

      IF   crapseg.tpseguro = 1    OR    /** CASA **/
           crapseg.tpseguro = 11   OR    /** CASA **/
           crapseg.tpseguro = 3    THEN  /** VIDA **/
           DO:
               MESSAGE "ROTINA NAO DISPONIVEL PARA ESSE SEGURO.".
               PAUSE 2 NO-MESSAGE.
               RETURN.
           END.

      IF   crapseg.cdsitseg <> 1   THEN
           DO:
               glb_cdcritic = IF crapseg.cdsitseg = 2
                                 THEN 525
                                 ELSE 574.
               RETURN.
           END.

      /* tratamento para o novo modelo de seguro */
      IF   crapseg.tpseguro = 11   THEN
           DO:
               RUN seguro_casa.
               RETURN.
           END.

      IF   crapseg.flgunica   THEN
           DO WHILE TRUE ON ENDKEY UNDO, RETRY:

              DISPLAY tel_dssubsti tel_dsacerto WITH FRAME f_acerto.

              CHOOSE FIELD tel_dssubsti tel_dsacerto WITH FRAME f_acerto.

              IF   FRAME-VALUE = tel_dsacerto   THEN
                   DO:
                       IF   glb_cdcooper = 1       AND 
                           (glb_cdoperad =  "1"    OR
                            glb_cdoperad = "30"    OR
                            glb_cdoperad = "49"    OR  
                            glb_cdoperad = "106"   OR
                            glb_cdoperad = "105"   OR
                            glb_cdoperad = "199"   OR
                            glb_cdoperad = "85")   THEN
                            .
                       ELSE
                       IF   glb_cdcooper = 4     AND
                            glb_cdoperad = "2"   THEN
                            .
                       ELSE
                            DO:
                                MESSAGE "036 - Operacao nao autorizada.".
                                NEXT.
                            END.

                       aux_flgacert = TRUE.
                   END.
              ELSE
              IF   FRAME-VALUE = tel_dssubsti   THEN
                   aux_flgacert = FALSE.

              LEAVE.

           END.  /*  Fim do DO WHILE TRUE  */

      HIDE FRAME f_acerto NO-PAUSE.
      HIDE MESSAGE NO-PAUSE.

      IF   NOT aux_flgacert   AND
           crapseg.dtinivig > glb_dtmvtolt   THEN
           DO:
               glb_cdcritic = 999.
               RETURN.
           END.

      FIND crawseg WHERE crawseg.cdcooper = glb_cdcooper        AND
                         crawseg.nrdconta = crapseg.nrdconta    AND
                         crawseg.nrctrseg = crapseg.nrctrseg
                         NO-LOCK NO-ERROR.

      IF   NOT AVAILABLE crawseg   THEN
           DO:
               CREATE crawseg.
               ASSIGN crawseg.dtmvtolt = crapseg.dtmvtolt
                      crawseg.nrdconta = crapseg.nrdconta
                      crawseg.nrctrseg = crapseg.nrctrseg

                      crawseg.tpseguro = crapseg.tpseguro

                      crawseg.cdsegura = crapseg.cdsegura
                      crawseg.nmdsegur = aux_dsnaoinf
                      crawseg.nrcpfcgc = aux_dsnaoinf
                      crawseg.nmcpveic = ""
                      crawseg.nmbenefi = ""
                      crawseg.vlbenefi = 0

                      crawseg.nmempres = aux_dsnaoinf
                      crawseg.nrcadast = 0
                      crawseg.nrfonemp = ""
                      crawseg.dsendres = aux_dsnaoinf
                      crawseg.nrfonres = ""
                      crawseg.nmbairro = aux_dsnaoinf
                      crawseg.nmcidade = aux_dsnaoinf
                      crawseg.cdufresd = ""
                      crawseg.nrcepend = 0

                      crawseg.dsmarvei = aux_dsnaoinf
                      crawseg.dstipvei = aux_dsnaoinf
                      crawseg.nranovei = 0
                      crawseg.nrmodvei = 0
                      crawseg.nrdplaca = ""
                      crawseg.qtpasvei = 0
                      crawseg.dschassi = aux_dsnaoinf
                      crawseg.ppdbonus = 0
                      crawseg.nrctrato = 0

                      crawseg.flgdnovo = FALSE
                      crawseg.flgrenov = FALSE
                      crawseg.flgunica = FALSE
                      crawseg.flgvisto = FALSE

                      crawseg.cdapoant = ""
                      crawseg.nmsegant = ""
                      crawseg.dscobext = ""
                      crawseg.flgdutil = TRUE
                      crawseg.flgnotaf = FALSE
                      crawseg.flgapant = FALSE

                      crawseg.dtprideb = crapseg.dtinivig
                      crawseg.dtinivig = crapseg.dtinivig
                      crawseg.dtfimvig = crapseg.dtfimvig
                      crawseg.vlpreseg = crapseg.vlpreseg
                      crawseg.cdcalcul = crapseg.nrctrseg
                      crawseg.tpplaseg = crapseg.tpplaseg
                      crawseg.vlseguro = 0
                      crawseg.vldfranq = 0

                      crawseg.vldcasco = 0
                      crawseg.vlverbae = 0
                      crawseg.flgassis = TRUE
                      crawseg.vldanmat = 0
                      crawseg.vldanpes = 0
                      crawseg.vldanmor = 0
                      crawseg.vlappmor = 0
                      crawseg.vlappinv = 0
                      crawseg.flgcurso = TRUE
                      crawseg.dtdebito = crapseg.dtdebito
                      crawseg.dtiniseg = crapseg.dtinivig
                      crawseg.cdcooper = glb_cdcooper

                      seg_cdsegura     = crapseg.cdsegura.
           END.

      LEAVE.

   END.  /*  Fim do DO WHILE TRUE  */

 /*FIND crapass OF crawseg NO-LOCK NO-ERROR. */

   FIND crapass WHERE crapass.cdcooper = glb_cdcooper      AND
                      crapass.nrdconta = crawseg.nrdconta  NO-LOCK NO-ERROR.

   IF  AVAILABLE crapass  THEN
       DO:
           IF   crapass.inpessoa = 1   THEN 
                DO:
                    FIND crapttl WHERE 
                         crapttl.cdcooper = glb_cdcooper       AND
                         crapttl.nrdconta = crapass.nrdconta   AND
                         crapttl.idseqttl = 1 NO-LOCK NO-ERROR.

                    IF   AVAIL crapttl  THEN
                         ASSIGN aux_cdempres = crapttl.cdempres.
                END.
           ELSE
                DO:
                    FIND crapjur WHERE crapjur.cdcooper = glb_cdcooper  AND
                                       crapjur.nrdconta = crapass.nrdconta
                                       NO-LOCK NO-ERROR.

                    IF   AVAIL crapjur  THEN
                         ASSIGN aux_cdempres = crapjur.cdempres.
                END.
       END.

/*   IF   NOT AVAILABLE crapass   THEN
        DO:
            glb_cdcritic = 9.
            RETURN.
        END.
*/

/*   FIND crapemp OF crapass NO-LOCK NO-ERROR. */
     FIND crapemp WHERE crapemp.cdcooper = glb_cdcooper      AND
                        crapemp.cdempres = aux_cdempres    NO-LOCK NO-ERROR.  
   
/*
   IF   NOT AVAILABLE crapemp   THEN
        DO:
            glb_cdcritic = 40.
            RETURN.
        END.
*/

/* FIND crapcsg OF crawseg NO-LOCK NO-ERROR.*/
   FIND crapcsg WHERE crapcsg.cdcooper = glb_cdcooper      AND
                      crapcsg.cdsegura = crawseg.cdsegura  NO-LOCK NO-ERROR.
   
/*
   IF   NOT AVAILABLE crapcsg   THEN
        DO:
            glb_cdcritic = 556.
            RETURN.
        END.
*/
   ASSIGN seg_nmresseg = crapcsg.nmresseg
          seg_nrctrato = crapcsg.nrctrato

          seg_tpseguro = crawseg.tpseguro 

          seg_cdsegura = crawseg.cdsegura
          seg_nmdsegur = crawseg.nmdsegur
          seg_nrcpfcgc = crawseg.nrcpfcgc
          seg_nmcpveic = crawseg.nmcpveic
          seg_nmbenefi = crawseg.nmbenefi
          seg_vlbenefi = crawseg.vlbenefi

          seg_nmempres = crawseg.nmempres
          seg_nrcadast = crawseg.nrcadast          
          seg_nrfonemp = crawseg.nrfonemp
          seg_dsendres = crawseg.dsendres
          seg_nrfonres = crawseg.nrfonres
          seg_nmbairro = crawseg.nmbairro
          seg_nmcidade = crawseg.nmcidade
          seg_cdufresd = crawseg.cdufresd
          seg_nrcepend = crawseg.nrcepend

          seg_dsmarvei = crawseg.dsmarvei
          seg_dstipvei = crawseg.dstipvei
          seg_nranovei = crawseg.nranovei
          seg_nrmodvei = crawseg.nrmodvei
          seg_nrdplaca = crawseg.nrdplaca
          seg_qtpassag = crawseg.qtpasvei
          seg_dschassi = crawseg.dschassi
          seg_ppdbonus = crawseg.ppdbonus
          seg_flgdnovo = crawseg.flgdnovo
          seg_flgrenov = crawseg.flgrenov
          seg_cdapoant = crawseg.cdapoant
          seg_nmsegant = crawseg.nmsegant
          seg_flgdutil = crawseg.flgdutil
          seg_flgvisto = crawseg.flgvisto
          seg_flgunica = crawseg.flgunica
          seg_flgnotaf = crawseg.flgnotaf
          seg_flgapant = crawseg.flgapant

          seg_dtinivig = IF crawseg.dtinivig > glb_dtmvtolt
                            THEN crawseg.dtinivig
                            ELSE glb_dtmvtolt

          seg_dtfimvig = crawseg.dtfimvig
          seg_vlpreseg = crawseg.vlpreseg
          seg_cdcalcul = 0
          seg_tpplaseg = crawseg.tpplaseg
          seg_vlseguro = crawseg.vlseguro
          seg_vldfranq = crawseg.vldfranq

          seg_vldcasco = crawseg.vldcasco
          seg_vlverbae = crawseg.vlverbae
          seg_flgassis = crawseg.flgassis
          seg_vldanmat = crawseg.vldanmat
          seg_vldanpes = crawseg.vldanpes
          seg_vldanmor = crawseg.vldanmor
          seg_vlappmor = crawseg.vlappmor
          seg_vlappinv = crawseg.vlappinv
          seg_flgcurso = crawseg.flgcurso
          seg_dtdebito = crawseg.dtdebito
          seg_ddvencto = DAY(crawseg.dtdebito)

          seg_dscobext[1] = crawseg.dscobext[1]
          seg_dscobext[2] = crawseg.dscobext[2]
          seg_dscobext[3] = crawseg.dscobext[3]
          seg_dscobext[4] = crawseg.dscobext[4]
          seg_dscobext[5] = crawseg.dscobext[5]

          seg_vlcobext[1] = crawseg.vlcobext[1]
          seg_vlcobext[2] = crawseg.vlcobext[2]
          seg_vlcobext[3] = crawseg.vlcobext[3]
          seg_vlcobext[4] = crawseg.vlcobext[4]
          seg_vlcobext[5] = crawseg.vlcobext[5]

          aux_lsctrant = crawseg.lsctrant +
                        (IF TRIM(crawseg.lsctrant) = "" THEN "" ELSE ",") +
                         STRING(crawseg.nrctrseg)

          aux_vlpreseg = crawseg.vlpreseg
          aux_dtprideb = crawseg.dtprideb.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      IF   glb_cdcritic > 0   THEN
           DO:
               RUN fontes/critic.p.
               MESSAGE glb_dscritic.
               glb_cdcritic = 0.
           END.

      seg_dstipseg = IF (seg_tpseguro = 1 OR
                         seg_tpseguro = 11)
                        THEN "CASA" 
                        ELSE "VIDA".

      DISPLAY seg_dstipseg seg_nmresseg WITH FRAME f_seguro_1.

      UPDATE seg_nmdsegur seg_nrcpfcgc WITH FRAME f_seguro_1.

      PAUSE 0.

      seg_nrctrseg = 0.

      LEAVE.

   END.  /*  Fim do DO WHILE TRUE  */

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
        DO:
            HIDE FRAME f_seguro_1      NO-PAUSE.
            RETURN.
        END.

   /*  Confirmacao dos dados  */

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      aux_confirma = "N".

      glb_cdcritic = 78.
      RUN fontes/critic.p.
      glb_cdcritic = 0.
      MESSAGE COLOR NORMAL glb_dscritic UPDATE aux_confirma.
      LEAVE.

   END.  /*  Fim do DO WHILE TRUE  */

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   OR
        aux_confirma <> "S" THEN
        DO:
            glb_cdcritic = 79.
            RUN fontes/critic.p.
            glb_cdcritic = 0.
            MESSAGE glb_dscritic.
            HIDE FRAME f_seguro_1      NO-PAUSE.
            NEXT.
        END.

   DO WHILE seg_nrctrseg = 0:

      FIND crapcsg WHERE crapcsg.cdcooper = glb_cdcooper  AND
                         crapcsg.cdsegura = seg_cdsegura
                         EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

      IF   NOT AVAILABLE crapcsg   THEN
           IF   LOCKED crapcsg   THEN
                DO:
                    PAUSE 2 NO-MESSAGE.
                    NEXT.
                END.
           ELSE
                DO:
                    glb_cdcritic = 556.
                    RUN fontes/critic.p.
                    MESSAGE glb_dscritic.
                    PAUSE 5 NO-MESSAGE.
                    glb_cdcritic = 0.
                    RETURN.
                END.

      IF   crapcsg.nrlimprc <= crapcsg.nrultprc   THEN
           DO:
               glb_cdcritic = 582.
               RUN fontes/critic.p.
               MESSAGE glb_dscritic "para proposta de seguro CASA.".
               PAUSE 5 NO-MESSAGE.
               glb_cdcritic = 0.
               RETURN.
           END.
      ELSE
           ASSIGN crapcsg.nrultprc = crapcsg.nrultprc + 1
                  seg_nrctrseg     = crapcsg.nrultprc.

      LEAVE.

   END.  /*  Fim do DO WHILE TRUE  */

   CREATE crawseg.

   ASSIGN crawseg.dtmvtolt = glb_dtmvtolt
          crawseg.nrdconta = tel_nrdconta
          crawseg.nrctrseg = seg_nrctrseg

          crawseg.tpseguro = seg_tpseguro

          crawseg.cdsegura = crapseg.cdsegura
          crawseg.lsctrant = aux_lsctrant
          crawseg.nmdsegur = CAPS(seg_nmdsegur)
          crawseg.nrcpfcgc = seg_nrcpfcgc
          crawseg.nmcpveic = CAPS(seg_nmcpveic)
          crawseg.nmbenefi = CAPS(seg_nmbenefi)
          crawseg.vlbenefi = seg_vlbenefi

          crawseg.nmempres = CAPS(seg_nmempres)
          crawseg.nrcadast = seg_nrcadast          
          crawseg.nrfonemp = seg_nrfonemp
          crawseg.dsendres = CAPS(seg_dsendres)
          crawseg.nrfonres = seg_nrfonres
          crawseg.nmbairro = CAPS(seg_nmbairro)
          crawseg.nmcidade = CAPS(seg_nmcidade)
          crawseg.cdufresd = seg_cdufresd
          crawseg.nrcepend = seg_nrcepend

          crawseg.dsmarvei = CAPS(seg_dsmarvei)
          crawseg.dstipvei = CAPS(seg_dstipvei)
          crawseg.nranovei = seg_nranovei
          crawseg.nrmodvei = seg_nrmodvei
          crawseg.nrdplaca = CAPS(seg_nrdplaca)
          crawseg.qtpasvei = seg_qtpassag
          crawseg.dschassi = CAPS(seg_dschassi)
          crawseg.ppdbonus = seg_ppdbonus
          crawseg.flgdnovo = seg_flgdnovo
          crawseg.flgrenov = IF TRIM(seg_cdapoant) <> ""
                                THEN TRUE
                                ELSE FALSE
          crawseg.cdapoant = CAPS(seg_cdapoant)
          crawseg.nmsegant = CAPS(seg_nmsegant)
          crawseg.flgdutil = seg_flgdutil
          crawseg.flgvisto = seg_flgvisto
          crawseg.flgunica = seg_flgunica
          crawseg.flgnotaf = seg_flgnotaf
          crawseg.flgapant = seg_flgapant

          crawseg.dtinivig = seg_dtinivig
          crawseg.dtfimvig = seg_dtfimvig
          crawseg.vlpreseg = seg_vlpreseg
          crawseg.vlpremio = seg_vltotpre
          crawseg.qtparcel = seg_qtparseg
          crawseg.cdcalcul = seg_cdcalcul
          crawseg.tpplaseg = seg_tpplaseg
          crawseg.vlseguro = seg_vlseguro
          crawseg.vldfranq = seg_vldfranq

          crawseg.vldcasco = seg_vldcasco
          crawseg.vlverbae = seg_vlverbae
          crawseg.flgassis = seg_flgassis
          crawseg.vldanmat = seg_vldanmat
          crawseg.vldanpes = seg_vldanpes
          crawseg.vldanmor = seg_vldanmor
          crawseg.vlappmor = seg_vlappmor
          crawseg.vlappinv = seg_vlappinv
          crawseg.flgcurso = seg_flgcurso
          crawseg.nrctrato = seg_nrctrato
          crawseg.dtdebito = aux_dtdebito
          crawseg.dtiniseg = seg_dtinivig

          crawseg.dscobext[1] = CAPS(seg_dscobext[1])
          crawseg.dscobext[2] = CAPS(seg_dscobext[2])
          crawseg.dscobext[3] = CAPS(seg_dscobext[3])
          crawseg.dscobext[4] = CAPS(seg_dscobext[4])
          crawseg.dscobext[5] = CAPS(seg_dscobext[5])

          crawseg.vlcobext[1] = seg_vlcobext[1]
          crawseg.vlcobext[2] = seg_vlcobext[2]
          crawseg.vlcobext[3] = seg_vlcobext[3]
          crawseg.vlcobext[4] = seg_vlcobext[4]
          crawseg.vlcobext[5] = seg_vlcobext[5]
          crawseg.cdcooper    = glb_cdcooper.

   IF   seg_flgunica   THEN
        DO:
            IF   crapseg.indebito > 0   THEN
                 crawseg.vldifseg = IF aux_flgacert
                                       THEN crawseg.vlpreseg - aux_vlpreseg
                                       ELSE crawseg.vlpreseg.
            ELSE
                 crawseg.vldifseg = crawseg.vlpreseg.
        END.
   ELSE
        crawseg.vldifseg = 0.

   ASSIGN crawseg.dtprideb = aux_dtprideb

          s_chextent = s_chextent + 1

          s_chlist[s_chextent] = " " +
                   STRING(crawseg.dtiniseg,"99/99/9999")     + " " +
                   STRING(crawseg.nrctrseg,"zzz,zzz,zz9")        + "  " +
                   STRING(DAY(crawseg.dtdebito),"99")        + " " +
                   (IF crawseg.tpseguro = 1 THEN "CASA" ELSE "AUTO") + "  " +
                   STRING(crawseg.vlpreseg,"zzz,zzz,zz9.99") + " " +
                   STRING(crawseg.dtinivig,"99/99/9999") + "  PS" +
                   TRIM(STRING(INT(ENTRY(NUM-ENTRIES(crawseg.lsctrant),
                                         crawseg.lsctrant)),"zzzzz,zz9"))

          s_nrctrseg[s_chextent] = crawseg.nrctrseg
          s_tpseguro[s_chextent] = crawseg.tpseguro
          s_cdtiparq[s_chextent] = 1
          s_recid[s_chextent]    = INTEGER(RECID(crawseg)).

   RUN fontes/seguro_m.p (INPUT INTEGER(RECID(crawseg))).

   LEAVE.

END.  /*  Fim do DO WHILE TRUE  */

HIDE FRAME f_seguro_1      NO-PAUSE.

/* tratamento para o novo modelo de seguro */
PROCEDURE seguro_casa:
        
    FIND crapcsg WHERE crapcsg.cdcooper = glb_cdcooper      AND
                       crapcsg.cdsegura = crapseg.cdsegura  NO-LOCK NO-ERROR.
    
    ASSIGN seg_nmresseg = crapcsg.nmsegura
           seg_dstipseg = IF crapseg.tpseguro = 11 THEN
                             "CASA"
                          ELSE
                             ""
           seg_nrctrseg = crapseg.nrctrseg
           seg_tpplaseg = crapseg.tpplaseg
           seg_ddvencto = DAY(crapseg.dtdebito)
           seg_vlpreseg = crapseg.vlpreseg
           seg_dtinivig = crapseg.dtinivig
           seg_dtfimvig = crapseg.dtfimvig
           seg_dtcancel = ?
           seg_ddpripag = DAY(crapseg.dtprideb)
           seg_qtmaxpar = crapseg.qtparcel

           /* codigo e tipo do seguro */
           seg_cdsegura = crapcsg.cdsegura
           seg_cdtipseg = crapseg.tpseguro.
    
    { includes/seg_simples.i }
    
    HIDE FRAME f_seg_simples NO-PAUSE.

END PROCEDURE.

/* .......................................................................... */


