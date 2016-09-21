/* .............................................................................

   Programa: Fontes/seguro_a.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Junho/97.                           Ultima atualizacao: 12/08/2015

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Rotina para tratamento da alteracao da proposta de seguro.

   Alteracoes: 19/08/97 - Alterado para tratar seguro auto em mais de uma segu-
                          radora e tratar pagto com parcela unica (Edson).

               12/09/97 - Alterado para deixar passar valores de verba especial
                          e danos morais iguais a tabela (Deborah).

               30/10/97 - Alterado para nao criticar o dia do debito para os
                          seguros com parcela unica (Edson).

               06/11/97 - Alterado para tratar coberturas extras e data de
                          inicio de vigencia retroativa (Edson).

               08/04/99 - Alterado para tratar o ano bisexto (Edson).

               02/08/1999 - Tratar seguro de vida em grupo (Deborah).
               
               02/07/2001 - Inclusao dos campos Total do Premio e Qtde. de
                            parcelas na opcao alterar (Junior).

               21/09/2001 - Seguro Residencial (Ze Eduardo).
               
               03/01/2002 - Acertos no seguro residencial (Ze Eduardo).
               
               30/03/2005 - Acertos para novo modelo de cadastramento de
                            seguro - Unibanco (Evandro).
                            
               01/12/2005 - Tratamento para seguro SUL AMERICA-CASA (Evandro).
               
               01/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando.
               
               21/06/2006 - Incluidos campos referente Local do Risco para
                            seguro tipo CASA (Diego).
                            
               01/09/2008 - Alteracao CDEMPRES (Kbase) - Eduardo Silva.
               
               22/04/2009 - Retirar tudo o que for relacionado ao SEGURO AUTO
                            (Gabriel).
                       
               25/07/2013 - Incluido o campo Complemento no endereco. (James)
               
               12/08/2015 - Projeto Reformulacao cadastral
                            Eliminado o campo nmdsecao (Tiago Castro - RKAM).
                            
.............................................................................*/

DEF INPUT PARAM par_recidseg AS INT                                  NO-UNDO.

{ includes/var_online.i }
{ includes/var_atenda.i }
{ includes/var_seguro.i }

DO WHILE TRUE TRANSACTION ON ENDKEY UNDO, LEAVE:

   DO WHILE TRUE:

      FIND crawseg WHERE RECID(crawseg) = par_recidseg
                         EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

      IF   NOT AVAILABLE crawseg   THEN
           IF   LOCKED crawseg   THEN
                DO:
                    PAUSE 2 NO-MESSAGE.
                    NEXT.
                END.
           ELSE
                DO:
                    glb_cdcritic = 535.
                    RUN fontes/critic.p.
                    BELL.
                    MESSAGE glb_dscritic.
                    glb_cdcritic = 0.
                    RETURN.
                END.

      LEAVE.

   END.  /*  Fim do DO WHILE TRUE  */

  /*FIND crapass OF crawseg NO-LOCK NO-ERROR.*/
   FIND crapass WHERE crapass.cdcooper = glb_cdcooper AND
                      crapass.nrdconta = crawseg.nrdconta
                      NO-LOCK NO-ERROR.

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

   IF   NOT AVAILABLE crapass   THEN
        DO:
            glb_cdcritic = 9.
            RETURN.
        END.

   IF   TRIM(crawseg.lsctrant) <> ""   THEN
        RETURN.

   /*FIND crapemp OF crapass NO-LOCK NO-ERROR.*/
   FIND crapemp WHERE crapemp.cdcooper = glb_cdcooper AND
                      crapemp.cdempres = aux_cdempres
                      NO-LOCK NO-ERROR.

   IF   NOT AVAILABLE crapemp   THEN
        DO:
            glb_cdcritic = 40.
            RETURN.
        END.

   /*FIND crapcsg OF crawseg NO-LOCK NO-ERROR.*/
   FIND crapcsg WHERE crapcsg.cdcooper = glb_cdcooper AND
                      crapcsg.cdsegura = crawseg.cdsegura
                      NO-LOCK NO-ERROR.

   IF   NOT AVAILABLE crapcsg   THEN
        DO:
            glb_cdcritic = 556.
            RETURN.
        END.

   /* tratamento para o novo modelo de seguro */
   IF   crawseg.tpseguro = 11   THEN
        DO:
            RUN seguro_casa.
            RETURN.
        END.
   
   ASSIGN seg_nmresseg = crapcsg.nmresseg

          seg_tpseguro = crawseg.tpseguro
          
          seg_dstipseg = IF  crawseg.tpseguro = 1
                             THEN "CASA"
                         ELSE "VIDA"

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
          seg_complend = crawseg.complend

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
          seg_nrctrato = crawseg.nrctrato
          seg_nmsegant = crawseg.nmsegant
          seg_flgdutil = crawseg.flgdutil
          seg_flgvisto = crawseg.flgvisto
          seg_flgunica = crawseg.flgunica
          seg_flgnotaf = crawseg.flgnotaf
          seg_flgapant = crawseg.flgapant
          seg_flgrepgr = crawseg.flgrepgr

          seg_dtinivig = crawseg.dtinivig
          seg_dtfimvig = crawseg.dtfimvig
          seg_vlpreseg = crawseg.vlpreseg
          seg_cdcalcul = crawseg.cdcalcul
          seg_vltotpre = crawseg.vlpremio
          seg_qtparseg = crawseg.qtparcel
          seg_tpplaseg = crawseg.tpplaseg
          seg_vlseguro = crawseg.vlseguro
          seg_vldfranq = crawseg.vldfranq

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
          seg_ddvencto = DAY(crawseg.dtdebito).

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      IF   glb_cdcritic > 0   THEN
           DO:
               RUN fontes/critic.p.
               BELL.
               MESSAGE glb_dscritic.
               glb_cdcritic = 0.
           END.

      DISPLAY seg_nmresseg WITH FRAME f_seguro_1.

      UPDATE seg_dstipseg seg_nmdsegur seg_nrcpfcgc
             WITH FRAME f_seguro_1.

      IF   seg_tpseguro = 1  THEN                  /*  SEGURO  CASA  */
           DO:
               DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                  UPDATE seg_nmbenefi seg_vlbenefi seg_dsendres  
                         seg_nrfonres seg_complend seg_nmbairro 
                         seg_nmcidade seg_cdufresd seg_nrcepend 
                         WITH FRAME f_seguro_casa_2.

                  IF   (TRIM(seg_nmbenefi) <> ""  AND seg_vlbenefi = 0)  OR
                       (TRIM(seg_nmbenefi) =  ""  AND seg_vlbenefi > 0)  THEN
                       DO:
                          glb_cdcritic = 375.
                    
                          IF   seg_vlbenefi = 0   THEN
                               NEXT-PROMPT seg_vlbenefi 
                                           WITH FRAME f_seguro_casa_2.
                          ELSE
                               NEXT-PROMPT seg_nmbenefi 
                                           WITH FRAME f_seguro_casa_2.
                    
                          NEXT.
                       END.

                  DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                     IF   glb_cdcritic > 0   THEN
                          DO:
                              RUN fontes/critic.p.
                              BELL.
                              MESSAGE glb_dscritic.
                              glb_cdcritic = 0.
                          END.
/*.............................................................................
                              
                               A T E N C A O

                  No seguro residencial alguns campos foram
                  reaproveitados para nao criar mais campos

                  crawseg.flgcasap = "Casa/Apartamento" 
                  crawseg.flgaluga = "Proprio/Alugado"  
                  crawseg.flgstrut = "Alvenaria/Madeira-Mista"
                  crawseg.flgandar = "Terreo/Superior"  
                  crawseg.flghabit = "Habitual/Veraneio"
                  crawseg.flgconte = "Sim/Nao"   
                  crawseg.flgpredi = "Sim/Nao"   
                  
                  ******** Tabela 090 (Miro) ********
                  crawseg.vlappinv = crapcsc.vlacipes
                  crawseg.vlappmor = crapcsc.vldanele
                  crawseg.vldanmat = crapcsc.vldesmor
                  crawseg.vldanmor = crapcsc.vldiaria
                  crawseg.vldanpes = crapcsc.vldrcfam
                  crawseg.vldcasco = crapcsc.vldvento
                  crawseg.vldfranq = crapcsc.vlvidros
                  crawseg.vldifseg = crapcsc.vlrouboe
                  crawseg.vlfrqobr = crapcsc.vlroubop 
                  crawseg.vlverbae = crapcsc.vlrouboq
...........................................................................*/                 
                     UPDATE  seg_flgapant   seg_flgassis 
                             seg_flgcurso   seg_flgdnovo
                             seg_flgnotaf   seg_flgrenov
                             seg_flgrepgr   WITH FRAME f_seguro_casa_3.
                          
                     DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                        IF   glb_cdcritic > 0   THEN
                             DO:
                                 RUN fontes/critic.p.
                                 BELL.
                                 MESSAGE glb_dscritic.
                                 glb_cdcritic = 0.
                             END.                  
                  
                        FIND craptsg WHERE craptsg.cdcooper = glb_cdcooper AND 
                                           craptsg.tpseguro = 1            AND 
                                           craptsg.tpplaseg = seg_tpplaseg
                                           NO-LOCK NO-ERROR.

                        IF   NOT AVAILABLE craptsg   THEN
                             DO:
                                 glb_cdcritic = 200.
                                 NEXT-PROMPT seg_tpplaseg 
                                             WITH FRAME f_seguro_casa_4.
                                 NEXT.
                             END.
     
                        FIND craptsg WHERE 
                             craptsg.cdcooper = glb_cdcooper AND
                             craptsg.tpseguro = 1            AND 
                             craptsg.tpplaseg = crawseg.tpplaseg
                             NO-LOCK NO-ERROR.

                        IF   AVAILABLE craptsg   THEN            
                             DO:
                                IF   craptsg.inplaseg = 2 THEN  /*  ESPECIAL  */
                                     DO:
                                        ASSIGN tel_vlacipes = crawseg.vlappinv
                                               tel_vldanele = crawseg.vlappmor 
                                               tel_vldiaria = crawseg.vldanmor
                                               tel_vldesmor = crawseg.vldanmat 
                                               tel_vlvidros = crawseg.vldfranq 
                                               tel_vldrcfam = crawseg.vldanpes
                                               tel_vlrouboe = crawseg.vldifseg 
                                               tel_vlroubop = crawseg.vlfrqobr 
                                               tel_vlrouboq = crawseg.vlverbae
                                               tel_vldvento = crawseg.vldcasco
                                               tel_vlmorada = tel_vlacipes +
                                                              tel_vldanele +
                                                              tel_vldiaria +
                                                              tel_vldesmor +
                                                              tel_vlvidros +
                                                              tel_vldrcfam +
                                                              tel_vlrouboe +
                                                              tel_vlroubop +
                                                              tel_vlrouboq +
                                                              tel_vldvento.
                                     END.
                                ELSE
                                     DO:
                                        /*FIND crapcsc OF craptsg NO-LOCK 
                                                                 NO-ERROR.*/
                                        FIND crapcsc WHERE 
                                             crapcsc.cdcooper = glb_cdcooper AND
                                             crapcsc.nrtabela = craptsg.nrtabela
                                             NO-LOCK NO-ERROR.

                                         IF   NOT AVAILABLE crapcsc   THEN
                                              DO:
                                                 glb_cdcritic = 200.
                                                 NEXT-PROMPT seg_tpplaseg 
                                                     WITH FRAME f_seguro_casa_4.
                                                 NEXT.
                                              END.
                                         ELSE
                                              ASSIGN 
                                                tel_vlacipes = crapcsc.vlacipes
                                                tel_vldanele = crapcsc.vldanele
                                                tel_vldesmor = crapcsc.vldesmor
                                                tel_vldiaria = crapcsc.vldiaria
                                                tel_vlmorada = crapcsc.vlmorada
                                                tel_vlvidros = crapcsc.vlvidros
                                                tel_vldrcfam = crapcsc.vldrcfam
                                                tel_vlrouboe = crapcsc.vlrouboe
                                                tel_vlroubop = crapcsc.vlroubop
                                                tel_vlrouboq = crapcsc.vlrouboq
                                                tel_vldvento = crapcsc.vldvento.
                                     END.
                             END.  
                           
                        DISP tel_vldesmor  tel_vlroubop  tel_vlrouboe
                             tel_vldvento  tel_vlvidros  tel_vldanele
                             tel_vldiaria  tel_vlrouboq  tel_vldrcfam
                             tel_vlacipes  tel_vlmorada
                             WITH FRAME f_seguro_casa_4.
           
                        UPDATE seg_tpplaseg WITH FRAME f_seguro_casa_4.

                        FIND craptsg WHERE craptsg.cdcooper = glb_cdcooper AND
                                           craptsg.tpseguro = 1            AND 
                                           craptsg.tpplaseg = seg_tpplaseg
                                           NO-LOCK NO-ERROR.

                        IF   NOT AVAILABLE craptsg   OR
                             (craptsg.cdsitpsg <> 1) THEN
                             DO:
                                 glb_cdcritic = 200.
                                 NEXT-PROMPT seg_tpplaseg 
                                             WITH FRAME f_seguro_casa_4.
                                 NEXT.
                             END.
     
                        IF   craptsg.inplaseg = 2 THEN  /*  ESPECIAL  */
                             DO:
                                DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                              
                                   UPDATE  tel_vldesmor  tel_vlroubop  
                                           tel_vlrouboe  tel_vldvento  
                                           tel_vlvidros  tel_vldanele
                                           tel_vldiaria  tel_vlrouboq  
                                           tel_vldrcfam  tel_vlacipes  
                                           WITH FRAME f_seguro_casa_4.
                                   LEAVE.
                                
                                END. 
                              
                                IF   KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
                                     DO:
                                         glb_cdcritic = 79.
                                         NEXT.
                                     END.

                                tel_vlmorada = tel_vlacipes + tel_vldanele + 
                                               tel_vldiaria + tel_vldesmor +
                                               tel_vlvidros + tel_vldrcfam +
                                               tel_vlrouboe + tel_vlroubop +
                                               tel_vlrouboq + tel_vldvento.
                             
                             DISPLAY tel_vlmorada WITH FRAME f_seguro_casa_4.
                                                          
                             ASSIGN seg_vlappinv = tel_vlacipes
                                    seg_vlappmor = tel_vldanele
                                    seg_vldanmat = tel_vldesmor
                                    seg_vldanmor = tel_vldiaria
                                    seg_vldanpes = tel_vldrcfam
                                    seg_vldcasco = tel_vldvento
                                    seg_vldfranq = tel_vlvidros
                                    seg_vldifseg = tel_vlrouboe
                                    seg_vlfrqobr = tel_vlroubop 
                                    seg_vlverbae = tel_vlrouboq.
                          END.      
                     ELSE
                          DO:
                              /*FIND crapcsc OF craptsg NO-LOCK NO-ERROR.*/
                              FIND crapcsc WHERE crapcsc.cdcooper = glb_cdcooper
                                   AND crapcsc.nrtabela = craptsg.nrtabela
                                   NO-LOCK NO-ERROR.
                              
                              IF   (NOT AVAILABLE crapcsc)       OR
                                   (NOT CAN-DO(crapcsc.lsplaseg,
                                          STRING(seg_tpplaseg))) THEN
                                   DO:
                                       glb_cdcritic = 200.
                                       NEXT-PROMPT seg_tpplaseg 
                                                   WITH FRAME f_seguro_casa_4.
                                       NEXT.
                                   END.
                     
                              ASSIGN tel_vlacipes = crapcsc.vlacipes
                                     tel_vldanele = crapcsc.vldanele
                                     tel_vldiaria = crapcsc.vldiaria
                                     tel_vldesmor = crapcsc.vldesmor
                                     tel_vlvidros = crapcsc.vlvidros
                                     tel_vldrcfam = crapcsc.vldrcfam
                                     tel_vlrouboe = crapcsc.vlrouboe
                                     tel_vlroubop = crapcsc.vlroubop
                                     tel_vlrouboq = crapcsc.vlrouboq
                                     tel_vldvento = crapcsc.vldvento
                                     tel_vlmorada = crapcsc.vlmorada.
                     
                              DISP tel_vldesmor  tel_vlroubop  tel_vlrouboe
                                   tel_vldvento  tel_vlvidros  tel_vldanele
                                   tel_vldiaria  tel_vlrouboq  tel_vldrcfam
                                   tel_vlacipes  tel_vlmorada
                                   WITH FRAME f_seguro_casa_4.
                          
                          END.   /* Fim do Else */
                                 
                        /*FIND crapcsg OF craptsg NO-LOCK NO-ERROR. */
                        FIND crapcsg WHERE crapcsg.cdcooper = glb_cdcooper AND
                                           crapcsg.cdsegura = craptsg.cdsegura
                                           NO-LOCK NO-ERROR.

                        IF   NOT AVAILABLE crapcsg   THEN
                             DO:
                                 glb_cdcritic = 556.
                                 NEXT.
                             END.    

                        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                           ASSIGN aux_confirma = "N"
                                  glb_cdcritic = 78.
                             
                           RUN fontes/critic.p.
                           BELL.
                           glb_cdcritic = 0.
                           MESSAGE COLOR NORMAL glb_dscritic 
                                                UPDATE aux_confirma.
                           LEAVE.

                        END.  /*  Fim do DO WHILE TRUE  */
                     
                        IF   KEYFUNCTION(LASTKEY) = "END-ERROR" OR 
                             aux_confirma <> "S" THEN
                             DO:
                                 glb_cdcritic = 79.
                                 RUN fontes/critic.p.
                                 BELL.
                                 MESSAGE glb_dscritic.
                                 glb_cdcritic = 0.
                                 PAUSE 5 NO-MESSAGE.
                                 NEXT.
                             END.
                     
                        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                           IF   glb_cdcritic > 0   THEN
                                DO:
                                    RUN fontes/critic.p.
                                    BELL.
                                    MESSAGE glb_dscritic.
                                    glb_cdcritic = 0.
                                END.

                           IF   craptsg.inplaseg = 2 THEN  /*  ESPECIAL  */
                                DO:
                                    seg_vlpreseg = crawseg.vlpreseg.

                                    UPDATE seg_dtinivig seg_ddvencto 
                                           seg_vlpreseg
                                           WITH FRAME f_seguro_casa_5.
                                END.
                           ELSE
                                DO:
                                    seg_vlpreseg = craptsg.vlplaseg.
                     
                                    DISPLAY seg_vlpreseg WITH 
                                            FRAME f_seguro_casa_5.

                                    UPDATE seg_dtinivig seg_ddvencto
                                           WITH FRAME f_seguro_casa_5.
                                END. 
                         
                           RUN fontes/calcdata.p (seg_dtinivig, 1, "A", 0, 
                                                  OUTPUT seg_dtfimvig).
                                               
                           IF   seg_dtinivig > (glb_dtmvtolt + 10)   OR
                                seg_dtinivig < (glb_dtmvtolt - 10)   THEN
                                DO:
                                    glb_cdcritic = 13.
                                    NEXT-PROMPT seg_dtinivig
                                                WITH FRAME f_seguro_casa_5.
                                    NEXT.
                                END.

                           aux_dtprideb = seg_dtinivig.

                           DO WHILE TRUE:

                              IF  CAN-DO("1,7",STRING(WEEKDAY(aux_dtprideb))) OR
                                  CAN-FIND(crapfer WHERE                      
                                           crapfer.cdcooper = glb_cdcooper  AND
                                           crapfer.dtferiad = aux_dtprideb) THEN
                                  DO:
                                      aux_dtprideb = aux_dtprideb - 1.
                                      NEXT.
                                  END.

                              LEAVE.

                           END.  /*  Fim do DO WHILE TRUE  */

                           IF   aux_dtprideb < glb_dtmvtolt   THEN
                                aux_dtprideb = glb_dtmvtolt.

                           IF   seg_ddvencto > 28   THEN
                                DO:
                                    glb_cdcritic = 13.
                                    NEXT-PROMPT seg_ddvencto
                                                WITH FRAME f_seguro_casa_5.
                                    NEXT.
                                END.

                           aux_dtdebito = IF MONTH(seg_dtinivig) = 12
                                             THEN DATE(01,seg_ddvencto,
                                                  YEAR(seg_dtinivig) + 1)
                                             ELSE 
                                                  DATE(MONTH(seg_dtinivig) 
                                                       + 1, seg_ddvencto,
                                                       YEAR(seg_dtinivig)).

                           IF   DAY(seg_dtinivig) > 10   THEN
                                DO:
                                    IF  (aux_dtdebito - seg_dtinivig) > 31 THEN
                                        DO:
                                            glb_cdcritic = 13.
                                            NEXT-PROMPT seg_ddvencto
                                                   WITH FRAME f_seguro_casa_5.
                                            NEXT.
                                        END.
                                END.
                           ELSE
                                IF   seg_ddvencto > 10   THEN
                                     DO:
                                         glb_cdcritic = 13.
                                         NEXT-PROMPT seg_ddvencto
                                                    WITH FRAME f_seguro_casa_5.
                                         NEXT.
                                     END.
                           
                           ASSIGN seg_cdsegura = craptsg.cdsegura
                                  seg_flgunica = craptsg.flgunica
                                  seg_nrctrato = crapcsg.nrctrato.
                           
                           PAUSE 0.

                           LEAVE.

                        END.  /*  Fim do DO WHILE TRUE  */

                        IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
                             DO:
                                 HIDE FRAME f_seguro_casa_5.
                                 NEXT.
                             END.
                     
                        LEAVE.

                     END.
                  
                     IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
                          DO:
                              HIDE FRAME f_seguro_casa_4.
                              NEXT.
                          END.   
                       
                     LEAVE.
               
                  END.  /*  Fim do DO WHILE TRUE  */

                  IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
                       DO:
                           HIDE FRAME f_seguro_casa_3.
                           NEXT.
                       END.
                
                  LEAVE.

              END.   

              IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN   /* F4 OU FIM */
                   DO:
                       HIDE FRAME f_seguro_casa_2.
                       NEXT.
                   END.   
              
              LEAVE.
                  
           END. /*  FIM DO  IF  SEGURO CASA  */

      PAUSE 0.
      
      LEAVE.

   END.  /*  Fim do DO WHILE TRUE  */

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
        DO:
            HIDE FRAME f_seguro_1 NO-PAUSE.
            
            IF   seg_tpseguro = 1 THEN   /* SEGURO CASA */
                 DO:
                     HIDE FRAME f_seguro_casa_2 NO-PAUSE.
                     HIDE FRAME f_seguro_casa_3 NO-PAUSE.
                     HIDE FRAME f_seguro_casa_4 NO-PAUSE.
                     HIDE FRAME f_seguro_casa_5 NO-PAUSE.
                 END.

            RETURN.
        END.

   /*  Confirmacao dos dados  */

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      aux_confirma = "N".

      glb_cdcritic = 78.
      RUN fontes/critic.p.
      BELL.
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
            BELL.
            MESSAGE glb_dscritic.

            HIDE FRAME f_seguro_1 NO-PAUSE.
            
            IF   seg_tpseguro = 1 THEN   /* SEGURO CASA */
                 DO:
                     HIDE FRAME f_seguro_casa_2 NO-PAUSE.
                     HIDE FRAME f_seguro_casa_3 NO-PAUSE.
                     HIDE FRAME f_seguro_casa_4 NO-PAUSE.
                     HIDE FRAME f_seguro_casa_5 NO-PAUSE.
                 END.

            NEXT.
        END.

   ASSIGN crawseg.tpseguro = seg_tpseguro 

          crawseg.cdsegura = crapcsg.cdsegura
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
          crawseg.complend = CAPS(seg_complend)

          crawseg.dsmarvei = CAPS(seg_dsmarvei)
          crawseg.dstipvei = CAPS(seg_dstipvei)
          crawseg.nranovei = seg_nranovei
          crawseg.nrmodvei = seg_nrmodvei
          crawseg.nrdplaca = CAPS(seg_nrdplaca)
          crawseg.qtpasvei = seg_qtpassag
          crawseg.dschassi = CAPS(seg_dschassi)
          crawseg.ppdbonus = seg_ppdbonus
          crawseg.flgdnovo = seg_flgdnovo
          crawseg.flgrenov = IF seg_tpseguro = 1 THEN seg_flgrenov
                             ELSE
                                IF TRIM(seg_cdapoant) <> ""
                                THEN TRUE
                                ELSE FALSE
          crawseg.cdapoant = CAPS(seg_cdapoant)
          crawseg.nmsegant = CAPS(seg_nmsegant)
          crawseg.nrctrato = seg_nrctrato
          crawseg.flgdutil = seg_flgdutil
          crawseg.flgvisto = seg_flgvisto
          crawseg.flgunica = seg_flgunica
          crawseg.flgnotaf = seg_flgnotaf
          crawseg.flgapant = seg_flgapant
          crawseg.flgrepgr = seg_flgrepgr
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
          crawseg.dtdebito = aux_dtdebito
          crawseg.dtiniseg = seg_dtinivig

          crawseg.dtprideb = aux_dtprideb
          crawseg.vldifseg = IF crawseg.tpseguro = 1 
                                THEN seg_vldifseg
                                ELSE 0
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

          s_chlist[s_choice[s_chcnt]] = " " +
                   STRING(crawseg.dtiniseg,"99/99/9999")     + " " +
                   STRING(crawseg.nrctrseg,"zzz,zzz,zz9")        + "  " +
                   STRING(DAY(crawseg.dtdebito),"99")        + " " +
                   (IF crawseg.tpseguro = 1 THEN "CASA" ELSE "AUTO") + "  " +
                   STRING(crawseg.vlpreseg,"zzz,zzz,zz9.99") + " " +
                   STRING(crawseg.dtinivig,"99/99/9999") + "  Em estudo"

          s_nrctrseg[s_choice[s_chcnt]] = crawseg.nrctrseg
          s_tpseguro[s_choice[s_chcnt]] = crawseg.tpseguro
          s_cdtiparq[s_choice[s_chcnt]] = 1
          s_recid[s_choice[s_chcnt]]    = INTEGER(RECID(crawseg)).

   RUN fontes/seguro_m.p (INPUT INTEGER(RECID(crawseg))).

   LEAVE.

END.  /*  Fim do DO WHILE TRUE  */

HIDE FRAME f_seguro_1 NO-PAUSE.
            
IF   seg_tpseguro = 1 THEN   /* SEGURO CASA */
     DO:
         HIDE FRAME f_seguro_casa_2 NO-PAUSE.
         HIDE FRAME f_seguro_casa_3 NO-PAUSE.
         HIDE FRAME f_seguro_casa_4 NO-PAUSE.
         HIDE FRAME f_seguro_casa_5 NO-PAUSE.
     END.
     
/* tratamento para o novo modelo de seguro */
PROCEDURE seguro_casa.

    ASSIGN seg_nmresseg = crapcsg.nmsegura
           seg_dstipseg = IF crawseg.tpseguro = 11 THEN
                             "CASA"
                          ELSE
                             ""
           seg_nrctrseg = crawseg.nrctrseg
           seg_tpplaseg = crawseg.tpplaseg
           seg_ddvencto = DAY(crawseg.dtdebito)
           seg_vlpreseg = crawseg.vlpreseg
           seg_vltotpre = crawseg.vlpremio
           seg_dtinivig = crawseg.dtinivig
           seg_dtfimvig = crawseg.dtfimvig
           seg_dtcancel = ?
           seg_ddpripag = DAY(crawseg.dtprideb)
           seg_qtmaxpar = crawseg.qtparcel
           seg_dsendres = crawseg.dsendres
           seg_nrendere = crawseg.nrendres
           seg_nmcidade = crawseg.nmcidade
           seg_nmbairro = crawseg.nmbairro
           seg_cdufresd = crawseg.cdufresd
           seg_nrcepend = crawseg.nrcepend
           seg_complend = crawseg.complend

           /* codigo e tipo do seguro */
           seg_cdsegura = crapcsg.cdsegura
           seg_cdtipseg = crawseg.tpseguro.
    
    { includes/seg_simples.i }

    HIDE FRAME f_seg_simples NO-PAUSE.

END PROCEDURE.

/* .......................................................................... */


