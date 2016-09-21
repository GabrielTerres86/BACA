/* .............................................................................

   Programa: Fontes/saldos.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Setembro/91.                    Ultima atualizacao: 18/06/2014

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela SALDOS.

   Alteracao : 16/11/94 - Alterado para incluir a media de saque s/bloqueado
                          crapsld.vlsmnblq (Odair).

               16/01/97 - Tratar CPMF (Odair).

               25/02/97 - Tratar estorno do abono da CPMF (Edson).

               16/02/98 - Alterar data final da CPMF (Odair)

               08/04/98 - Tratamento para milenio e troca para V8 (Magui).

               29/06/98 - Alterado para NAO tratar o historico 289 (Edson).

               09/11/98 - Tratar situacao em prejuizo (Deborah).
               
               15/04/1999 - Tratar recuperacao do abono de IOF s/aplicacaoes
                            (Deborah).
             
               09/06/1999 - Tratar CPMF (Deborah).
               
               24/10/2000 - Desmembrar a critica 95 conforme a situacao do
                            titular (Eduardo).

               26/03/2003 - Incluir tratamento da Concredi (Magui).

               15/07/2003 - Inserido o codigo para verificar, apartir do tipo de
                            registro do cadastro de tabelas, com qual numero de
                            conta que se esta trabalhando. O numero sera  
                            armazenado na variavel aux_lsconta3 (Julio).

               22/09/2004 - Incluidos historicos 498/500(CI)(Mirtes)

               15/07/2005 - Calculo do abono da cpmf deve enxergar a data
                            de inicio, tab_dtiniabo. Usa craplcm.dtrefere
                            com craprda.dtmvtolt para pegar se lancamento com
                            abono ou nao (Magui).
                            
               09/12/2005 - Cheque salario nao existe mais (Magui).       
                     
               01/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando.  
               
               09/06/2008 - Incluído a chave de acesso (craphis.cdcooper = 
                            glb_cdcooper) no "find" da tabela CRAPHIS.   
                          - Kbase IT Solutions - Eduardo Silva.
                          
               12/01/2011 - Incluido format para acomodar o campo nmprimtl 
               
               15/05/2012 - substituiçao do FIND craptab para os registros 
                            CONTACONVE pela chamada do fontes ver_ctace.p
                            (Lucas R.)                
               
               13/08/2013 - Incluido campo "Bloqueio Judicial" (Daniele).
               
               18/06/2014 - Exclusao do uso da tabela crapcar.
                            (Tiago Castro - Tiago RKAM)
               
............................................................................. */

{ includes/var_online.i  }

{ includes/var_cpmf.i } 

DEF VAR h-b1wgen0155 AS HANDLE                                         NO-UNDO.

DEF  VAR tel_nrdconta AS INT     FORMAT "zzzz,zzz,9"                   NO-UNDO.
DEF  VAR tel_vlsmdtri AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99-"          NO-UNDO.
DEF  VAR tel_vlsmdsem AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99-"          NO-UNDO.
DEF  VAR tel_vlsaqmax AS DECIMAL FORMAT "zzzz,zzz,zzz,zz9.99-"         NO-UNDO.
DEF  VAR tel_vlacerto AS DECIMAL FORMAT "zzzz,zzz,zzz,zz9.99-"         NO-UNDO.
DEF  VAR tel_vlsddisp AS DECIMAL FORMAT "zzzz,zzz,zzz,zz9.99-"         NO-UNDO.
DEF  VAR tel_vlsdbloq AS DECIMAL FORMAT "zzzz,zzz,zzz,zz9.99-"         NO-UNDO.
DEF  VAR tel_vlsdblpr AS DECIMAL FORMAT "zzzz,zzz,zzz,zz9.99-"         NO-UNDO.
DEF  VAR tel_vlsdblfp AS DECIMAL FORMAT "zzzz,zzz,zzz,zz9.99-"         NO-UNDO.
DEF  VAR tel_vlsdchsl AS DECIMAL FORMAT "zzzz,zzz,zzz,zz9.99-"         NO-UNDO.
DEF  VAR tel_vlstotal AS DECIMAL FORMAT "zzzz,zzz,zzz,zz9.99-"         NO-UNDO.
DEF  VAR tel_vlblqjud AS DECIMAL FORMAT "zzzz,zzz,zzz,zz9.99-"         NO-UNDO. 
DEF  VAR tel_vlsmdpos AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99" EXTENT 7  NO-UNDO.

DEF  VAR tel_nmmesano AS CHAR    FORMAT "x(15)" EXTENT 7               NO-UNDO.
DEF  VAR tel_dstemcar AS CHAR    FORMAT "x(35)"                        NO-UNDO.
DEF  VAR tel_dslimcre AS CHAR    FORMAT "x(2)"                         NO-UNDO.

DEF  VAR aux_insaqmax AS DECIMAL                                       NO-UNDO.
DEF  VAR aux_txdoipmf AS DECIMAL                                       NO-UNDO.
DEF  VAR aux_vlipmfap AS DECIMAL                                       NO-UNDO.
DEF  VAR aux_vlalipmf AS DECIMAL                                       NO-UNDO.
DEF  VAR aux_vlestorn AS DECIMAL                                       NO-UNDO.
DEF  VAR aux_vlestabo AS DECIMAL                                       NO-UNDO.
DEF  VAR aux_vlresblq AS DECIMAL                                       NO-UNDO. 

DEF  VAR aux_nrmesano AS INT                                           NO-UNDO.
DEF  VAR aux_contador AS INT                                           NO-UNDO.
DEF  VAR aux_nrindice AS INT                                           NO-UNDO.
DEF  VAR aux_inmesano AS INT                                           NO-UNDO.
DEF  VAR aux_indoipmf AS INT                                           NO-UNDO.
DEF  VAR aux_stimeout AS INT                                           NO-UNDO.

DEF  VAR aux_flgerros AS LOGICAL                                       NO-UNDO.

DEF  VAR aux_cddopcao AS CHAR                                          NO-UNDO.
DEF  VAR aux_nranoatu AS CHAR                                          NO-UNDO.
DEF  VAR aux_nranoant AS CHAR                                          NO-UNDO.

DEF  VAR aux_nmmesano AS CHAR    EXTENT 12
                                 INIT ["  Janeiro/","Fevereiro/",
                                       "    Marco/","    Abril/",
                                       "     Maio/","    Junho/",
                                       "    Julho/","   Agosto/",
                                       " Setembro/","  Outubro/",
                                       " Novembro/"," Dezembro/"]      NO-UNDO.

DEF  VAR tab_dtiniiof AS DATE                                          NO-UNDO.
DEF  VAR tab_dtfimiof AS DATE                                          NO-UNDO.
DEF  VAR tab_txiofapl AS DECIMAL FORMAT "zzzzzzzz9,999999"             NO-UNDO.

DEF  VAR aux_lsconta3 AS CHAR                                          NO-UNDO.

FORM 
     tel_nrdconta       AT  2 LABEL "Conta/dv" AUTO-RETURN
                              HELP "Informe o numero da conta do associado"
     crapass.nmprimtl         LABEL "Titular"   FORMAT "x(46)"
     SKIP (1)
     tel_vlsaqmax       AT  6 LABEL "SAQUE MAXIMO"
     "Medias Positivas"  AT 55
     tel_vlacerto       AT  3 LABEL "ACERTO DE CONTA"
     tel_nmmesano[1]    AT 44 NO-LABEL
     tel_vlsmdpos[1]    AT 60 NO-LABEL
     SKIP
     tel_vlsddisp       AT  8 LABEL "Disponivel"
     tel_nmmesano[2]    AT 44 NO-LABEL
     tel_vlsmdpos[2]    AT 60 NO-LABEL
     SKIP
     tel_vlsdbloq       AT  9 LABEL "Bloqueado"
     tel_nmmesano[3]    AT 44 NO-LABEL
     tel_vlsmdpos[3]    AT 60 NO-LABEL
     SKIP
     tel_vlsdblpr       AT  7 LABEL "Bloq. Praca"
     tel_nmmesano[4]    AT 44 NO-LABEL
     tel_vlsmdpos[4]    AT 60 NO-LABEL
     SKIP
     tel_vlsdblfp       AT  2 LABEL "Bloq. Fora Praca"
     tel_nmmesano[5]    AT 44 NO-LABEL
     tel_vlsmdpos[5]    AT 60 NO-LABEL
     SKIP
     tel_vlsdchsl       AT  4 LABEL "Cheque Salario"
     tel_nmmesano[6]    AT 44 NO-LABEL
     tel_vlsmdpos[6]    AT 60 NO-LABEL
     SKIP
     tel_vlblqjud       AT 4 LABEL  "Bloq. Judicial"  
     tel_nmmesano[7]    AT 44 NO-LABEL 
     tel_vlsmdpos[7]    AT 60 NO-LABEL 
     SKIP
     tel_vlstotal       AT  7 LABEL "Saldo Total"
     SKIP
     "Limite Credito:"  AT  4
     tel_dslimcre       AT 20 FORMAT "x(2)" NO-LABEL
     crapass.vllimcre   AT 23 FORMAT "z,zzz,zzz,zz9.99" NO-LABEL
     tel_dstemcar       AT  4 NO-LABEL  
     tel_vlsmdtri       AT 49 LABEL "Trimestre"
     SKIP
     crapsld.vlsmnmes   AT  2 FORMAT "zzz,zzz,zz9.99-"
                              LABEL "Media Negativa do Mes"
     tel_vlsmdsem       AT 50 LABEL "Semestre"
     SKIP
     crapsld.vlsmnesp   AT  2 FORMAT "zzz,zzz,zz9.99-"
                              LABEL "Media Neg.Esp. do Mes"
     crapsld.qtsmamfx   AT 46 LABEL "SM Anual MFX"
     SKIP
     crapsld.vlsmnblq   AT  2 FORMAT "zzz,zzz,zz9.99-"
                              LABEL "Med.Saque s/Bloqueado"
     crapsld.vlipmfpg   AT 46 LABEL "Prox.Db.CPMF"
     WITH ROW 4 NO-LABELS SIDE-LABELS TITLE glb_tldatela OVERLAY WIDTH 80
          FRAME f_saldos.

glb_cddopcao = "C".

IF   glb_dtmvtolt > 01/22/1997 AND glb_dtmvtolt < 01/24/1999 THEN
     ASSIGN aux_insaqmax = glb_cfrvipmf
            aux_vlalipmf = glb_vlalipmf.
ELSE
     ASSIGN aux_insaqmax = 1
            aux_vlalipmf = 0.

{ includes/cpmf.i } 

/*  Leitura da tabela de parametros para indentificar o Nro. da conta  */

RUN fontes/ver_ctace.p(INPUT glb_cdcooper,
                       INPUT 3,
                       OUTPUT aux_lsconta3).
                   
/*   FIM DA LEITURA DA TABELA DE PARAMETROS   */

/*  Tabela com a taxa do IOF */

FIND craptab WHERE craptab.cdcooper = glb_cdcooper  AND 
                   craptab.nmsistem = "CRED"        AND
                   craptab.tptabela = "USUARI"      AND
                   craptab.cdempres = 11            AND
                   craptab.cdacesso = "CTRIOFRDCA"  AND
                   craptab.tpregist = 1
                   USE-INDEX craptab1 NO-LOCK NO-ERROR.

IF   NOT AVAILABLE craptab   THEN
     DO:
         glb_cdcritic = 626.
         RUN fontes/critic.p.
         BELL.
         MESSAGE glb_dscritic.
         NEXT.
     END.

ASSIGN tab_dtiniiof = DATE(INT(SUBSTRING(craptab.dstextab,4,2)),
                           INT(SUBSTRING(craptab.dstextab,1,2)),
                           INT(SUBSTRING(craptab.dstextab,7,4)))
       tab_dtfimiof = DATE(INT(SUBSTRING(craptab.dstextab,15,2)),
                           INT(SUBSTRING(craptab.dstextab,12,2)),
                           INT(SUBSTRING(craptab.dstextab,18,4)))
       tab_txiofapl = IF   glb_dtmvtolt >= tab_dtiniiof AND
                           glb_dtmvtolt <= tab_dtfimiof 
                           THEN DECIMAL(SUBSTR(craptab.dstextab,23,16))
                           ELSE 0.
 
DO WHILE TRUE:

   RUN fontes/inicia.p.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      UPDATE tel_nrdconta WITH FRAME f_saldos

      EDITING:

         aux_stimeout = 0.

         DO WHILE TRUE:

            READKEY PAUSE 1.

            IF   LASTKEY = -1   THEN
                 DO:
                     aux_stimeout = aux_stimeout + 1.

                     IF   aux_stimeout > glb_stimeout   THEN
                          QUIT.

                     NEXT.
                 END.

            APPLY LASTKEY.

            LEAVE.

         END.  /*  Fim do DO WHILE TRUE  */

      END.  /*  Fim do EDITING  */

      ASSIGN glb_nrcalcul = tel_nrdconta
             glb_cdcritic = 0.

      RUN fontes/digfun.p.
      IF   NOT glb_stsnrcal   THEN
           DO:
               glb_cdcritic = 8.
               RUN fontes/critic.p.
               BELL.
               MESSAGE glb_dscritic.
               CLEAR FRAME f_saldos NO-PAUSE.
               NEXT.
           END.

      LEAVE.

   END.  /*  Fim do WHILE TRUE  */

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN    /*   F4 OU FIM   */
        DO:
            RUN fontes/novatela.p.
            IF   glb_nmdatela <> "SALDOS"   THEN
                 DO:
                     HIDE FRAME f_saldos.
                     RETURN.
                 END.
            ELSE
                 NEXT.
        END.

   IF   aux_cddopcao <> glb_cddopcao   THEN
        DO:
            { includes/acesso.i}
            aux_cddopcao = glb_cddopcao.
        END.

   FIND crapass WHERE crapass.cdcooper = glb_cdcooper   AND
                      crapass.nrdconta = tel_nrdconta   NO-LOCK NO-ERROR.

   IF   NOT AVAILABLE crapass   THEN
        DO:
            glb_cdcritic = 9.
            RUN fontes/critic.p.
            BELL.
            MESSAGE glb_dscritic.
            CLEAR FRAME f_saldos.
            NEXT.
        END.

   FIND crapsld WHERE crapsld.cdcooper = glb_cdcooper   AND
                      crapsld.nrdconta = tel_nrdconta   NO-LOCK NO-ERROR.

   IF   NOT AVAILABLE crapsld   THEN
        DO:
            glb_cdcritic = 10.
            RUN fontes/critic.p.
            BELL.
            MESSAGE glb_dscritic.
            CLEAR FRAME f_saldos.
            NEXT.
        END.

   ASSIGN tel_vlsddisp = crapsld.vlsddisp
          tel_vlsdbloq = crapsld.vlsdbloq
          tel_vlsdblpr = crapsld.vlsdblpr
          tel_vlsdblfp = crapsld.vlsdblfp
          tel_vlsdchsl = crapsld.vlsdchsl
          tel_vlblqjud = crapsld.vlblqjud

          tel_dslimcre = IF crapass.tplimcre = 1
                            THEN "CP"
                            ELSE IF crapass.tplimcre = 2
                                    THEN "SM"
                                    ELSE ""

          aux_vlipmfap = 0
          aux_flgerros = FALSE
          aux_vlestabo = 0.

   /*  Leitura dos lancamentos do dia  */

   FOR EACH craplcm WHERE craplcm.cdcooper = glb_cdcooper       AND
                          craplcm.nrdconta = crapsld.nrdconta   AND
                          craplcm.dtmvtolt = glb_dtmvtolt       AND
                          craplcm.cdhistor <> 289               
                          USE-INDEX craplcm2 NO-LOCK:

       FIND craphis WHERE
            craphis.cdcooper = glb_cdcooper AND
            craphis.cdhistor = craplcm.cdhistor NO-LOCK NO-ERROR.

       IF   NOT AVAILABLE craphis   THEN
            DO:
                glb_cdcritic = 80.
                aux_flgerros = TRUE.
                LEAVE.
            END.
       
       ASSIGN aux_txdoipmf = tab_txcpmfcc              

              aux_indoipmf = IF tab_indabono = 0   AND
                                CAN-DO("114,117,127,160",
                                       STRING(craplcm.cdhistor))
                                THEN 1
                                ELSE craphis.indoipmf.

       IF   craphis.inhistor = 1   THEN
            tel_vlsddisp = tel_vlsddisp + craplcm.vllanmto.
       ELSE
       IF   craphis.inhistor = 2   THEN
            tel_vlsdchsl = tel_vlsdchsl + craplcm.vllanmto.
       ELSE
       IF   craphis.inhistor = 3   THEN
            tel_vlsdbloq = tel_vlsdbloq + craplcm.vllanmto.
       ELSE
       IF   craphis.inhistor = 4   THEN
            tel_vlsdblpr = tel_vlsdblpr + craplcm.vllanmto.
       ELSE
       IF   craphis.inhistor = 5   THEN
            tel_vlsdblfp = tel_vlsdblfp + craplcm.vllanmto.
       ELSE
       IF   craphis.inhistor = 11   THEN
            tel_vlsddisp = tel_vlsddisp - craplcm.vllanmto.
       ELSE
       IF   craphis.inhistor = 12   THEN
            tel_vlsdchsl = tel_vlsdchsl - craplcm.vllanmto.
       ELSE
       IF   craphis.inhistor = 13   THEN
            tel_vlsdbloq = tel_vlsdbloq - craplcm.vllanmto.
       ELSE
       IF   craphis.inhistor = 14   THEN
            tel_vlsdblpr = tel_vlsdblpr - craplcm.vllanmto.
       ELSE
       IF   craphis.inhistor = 15   THEN
            tel_vlsdblfp = tel_vlsdblfp - craplcm.vllanmto.
       ELSE
            DO:
                glb_cdcritic = 83.
                aux_flgerros = TRUE.
                LEAVE.
            END.

       /*  Calcula IPMF para os lancamentos  */

       IF   aux_indoipmf > 1   THEN
            IF   craphis.indebcre = "D"   THEN
                 aux_vlipmfap = aux_vlipmfap +
                             (TRUNCATE(craplcm.vllanmto * aux_txdoipmf,2)).
            ELSE
                 IF   craphis.indebcre = "C"   THEN
                      aux_vlipmfap = aux_vlipmfap -
                             (TRUNCATE(craplcm.vllanmto * aux_txdoipmf,2)).
                 ELSE .
       ELSE
       IF   craphis.inhistor = 12 THEN
            DO:
                /*** Magui desativado em 09/12/2005
                FIND crapchs WHERE crapchs.cdcooper = glb_cdcooper       AND
                                   crapchs.nrdconta = craplcm.nrdconta   AND
                                   crapchs.nrdocmto = craplcm.nrdocmto
                                   USE-INDEX crapchs2 NO-LOCK NO-ERROR.

                IF   NOT AVAILABLE crapchs   THEN
                     IF   CAN-DO(aux_lsconta3, STRING(craplcm.nrdctabb))   THEN
                          DO:
                              glb_cdcritic = 286.
                              aux_flgerros = TRUE.
                              LEAVE.
                          END.
                     ELSE
                          IF   craplcm.cdhistor <> 43 THEN
                               ASSIGN tel_vlsdchsl = tel_vlsdchsl -
                                  (TRUNCATE(craplcm.vllanmto * aux_txdoipmf,2))
                                      tel_vlsddisp = tel_vlsddisp +
                                  (TRUNCATE(craplcm.vllanmto * aux_txdoipmf,2))
                                      aux_vlipmfap = aux_vlipmfap +
                                  (TRUNCATE(craplcm.vllanmto * aux_txdoipmf,2)).
                          ELSE
                          .
                ELSE
                     ASSIGN tel_vlsdchsl = tel_vlsdchsl - crapchs.vldoipmf
                            tel_vlsddisp = tel_vlsddisp + crapchs.vldoipmf
                            aux_vlipmfap = aux_vlipmfap + crapchs.vldoipmf.
                **************************/
                /*** Magui em substituicao ao cheque salario ***/
                IF   craplcm.cdhistor <> 43 THEN
                     ASSIGN tel_vlsdchsl = tel_vlsdchsl -
                                 (TRUNCATE(craplcm.vllanmto * aux_txdoipmf,2))
                            tel_vlsddisp = tel_vlsddisp +
                                  (TRUNCATE(craplcm.vllanmto * aux_txdoipmf,2))
                            aux_vlipmfap = aux_vlipmfap +
                                  (TRUNCATE(craplcm.vllanmto * aux_txdoipmf,2)).
            END.

       IF   tab_indabono = 0   AND
            tab_dtiniabo <= craplcm.dtrefere AND
            CAN-DO("186,187,498,500",STRING(craplcm.cdhistor))   THEN
            ASSIGN aux_vlestorn = TRUNCATE(craplcm.vllanmto * tab_txcpmfcc,2)

                   aux_vlipmfap = aux_vlipmfap + aux_vlestorn +
                                  TRUNCATE(aux_vlestorn * tab_txcpmfcc,2)
                   aux_vlestabo = aux_vlestabo + craplcm.vllanmto.

   END.  /*  Fim do FOR EACH -- Leitura dos lancamentos do dia  */

   IF   aux_flgerros   THEN
        DO:
            RUN fontes/critic.p.
            BELL.
            MESSAGE glb_dscritic.
            NEXT.
        END.
   
   aux_vlestabo = TRUNCATE(aux_vlestabo * tab_txiofapl,2).
    
   ASSIGN tel_vlstotal = tel_vlsddisp + tel_vlsdbloq + tel_vlsdblpr +
                         tel_vlsdblfp + tel_vlsdchsl + tel_vlblqjud

          tel_vlacerto = tel_vlsddisp - crapsld.vlipmfap -
                                        crapsld.vlipmfpg -
                                        aux_vlipmfap - aux_vlestabo

          tel_vlsaqmax = IF tel_vlacerto <= 0
                            THEN 0
                            ELSE TRUNCATE (tel_vlacerto * tab_txrdcpmf,2)

          tel_vlacerto = tel_vlacerto + tel_vlsdbloq + tel_vlsdblpr +
                         tel_vlsdblfp

          tel_vlacerto = IF tel_vlacerto < 0 
                            THEN TRUNCATE(tel_vlacerto * (1 + tab_txcpmfcc),2)
                            ELSE tel_vlacerto
          
          aux_nrmesano = IF MONTH(glb_dtmvtolt) > 6
                            THEN MONTH(glb_dtmvtolt) - 6
                            ELSE MONTH(glb_dtmvtolt).

   IF   aux_nrmesano = 1   THEN        /*  Meses 1 ou 7  */
        tel_vlsmdtri = (crapsld.vlsmstre[6] + crapsld.vlsmstre[5] +
                        crapsld.vlsmstre[4]) / 3.
   ELSE
   IF   aux_nrmesano = 2   THEN        /*  Meses 2 ou 8  */
        tel_vlsmdtri = (crapsld.vlsmstre[1] + crapsld.vlsmstre[6] +
                        crapsld.vlsmstre[5]) / 3.
   ELSE
   IF   aux_nrmesano = 3   THEN        /*  Meses 3 ou 9  */
        tel_vlsmdtri = (crapsld.vlsmstre[2] + crapsld.vlsmstre[1] +
                        crapsld.vlsmstre[6]) / 3.
   ELSE
   IF   aux_nrmesano = 4   THEN        /*  Meses 4 ou 10  */
        tel_vlsmdtri = (crapsld.vlsmstre[3] + crapsld.vlsmstre[2] +
                        crapsld.vlsmstre[1]) / 3.
   ELSE
   IF   aux_nrmesano = 5   THEN        /*  Meses 5 ou 11  */
        tel_vlsmdtri = (crapsld.vlsmstre[4] + crapsld.vlsmstre[3] +
                        crapsld.vlsmstre[2]) / 3.
   ELSE
   IF   aux_nrmesano = 6   THEN        /*  Meses 6 ou 12  */
        tel_vlsmdtri = (crapsld.vlsmstre[5] + crapsld.vlsmstre[4] +
                        crapsld.vlsmstre[3]) / 3.

   ASSIGN tel_vlsmdsem = (crapsld.vlsmstre[1] + crapsld.vlsmstre[2] +
                          crapsld.vlsmstre[3] + crapsld.vlsmstre[4] +
                          crapsld.vlsmstre[5] + crapsld.vlsmstre[6]) / 6

          tel_vlsmdpos[1] = crapsld.vlsmstre[aux_nrmesano]

          tel_vlsmdpos[2] = crapsld.vlsmstre[IF (aux_nrmesano + 1) > 6
                                                 THEN (aux_nrmesano + 1) - 6
                                                 ELSE (aux_nrmesano + 1)]

          tel_vlsmdpos[3] = crapsld.vlsmstre[IF (aux_nrmesano + 2) > 6
                                                 THEN (aux_nrmesano + 2) - 6
                                                 ELSE (aux_nrmesano + 2)]

          tel_vlsmdpos[4] = crapsld.vlsmstre[IF (aux_nrmesano + 3) > 6
                                                 THEN (aux_nrmesano + 3) - 6
                                                 ELSE (aux_nrmesano + 3)]

          tel_vlsmdpos[5] = crapsld.vlsmstre[IF (aux_nrmesano + 4) > 6
                                                 THEN (aux_nrmesano + 4) - 6
                                                 ELSE (aux_nrmesano + 4)]

          tel_vlsmdpos[6] = crapsld.vlsmstre[IF (aux_nrmesano + 5) > 6
                                                 THEN (aux_nrmesano + 5) - 6
                                                 ELSE (aux_nrmesano + 5)]

          tel_vlsmdpos[7] = crapsld.vlsmpmes

          aux_nranoatu = string(YEAR(glb_dtmvtolt),"9999")
          aux_nranoant = string(YEAR(glb_dtmvtolt) - 1,"9999")

          aux_nrmesano = MONTH(glb_dtmvtolt)
          aux_inmesano = 0.

   DO aux_contador = aux_nrmesano TO aux_nrmesano + 6:

      ASSIGN aux_nrindice = 6 + aux_contador

             aux_nrindice = IF aux_nrindice > 12
                               THEN aux_nrindice - 12
                               ELSE aux_nrindice

             aux_inmesano = aux_inmesano + 1

             tel_nmmesano[aux_inmesano] = aux_nmmesano[aux_nrindice]

             tel_nmmesano[aux_inmesano] = tel_nmmesano[aux_inmesano] +
                                          IF aux_nrindice > MONTH(glb_dtmvtolt)
                                             THEN aux_nranoant + ":"
                                             ELSE aux_nranoatu + ":".

   END.  /*  Fim do DO .. TO  */

   ASSIGN tel_nmmesano[7] = aux_nmmesano[MONTH(glb_dtmvtolt)] +
                            aux_nranoatu + ":".

   IF   CAN-DO("5,6,7,8",STRING(crapass.cdsitdtl))   THEN
        DO:
            glb_cdcritic = 695.
            RUN fontes/critic.p.
            BELL.
            MESSAGE glb_dscritic.
            glb_cdcritic = 0.
        END.

   IF   CAN-DO("2,4,6,8",STRING(crapass.cdsitdtl))   THEN
        DO:
            glb_cdcritic = 95.
            RUN fontes/critic.p.
            BELL.
            MESSAGE glb_dscritic.
            glb_cdcritic = 0.
        END.

   DISPLAY crapass.nmprimtl  tel_vlsddisp      tel_vlsdbloq  
           tel_vlsdblpr      tel_vlsdblfp      tel_vlsdchsl
           tel_vlstotal      crapass.vllimcre  tel_dstemcar
           tel_vlsmdtri      crapsld.vlsmnmes  tel_vlsmdsem
           crapsld.vlsmnesp  crapsld.qtsmamfx  tel_nmmesano
           tel_vlsmdpos      crapsld.vlsmnblq  tel_vlsaqmax
           tel_vlacerto      crapsld.vlipmfpg  tel_dslimcre
           tel_vlblqjud 
           WITH FRAME f_saldos.

   RELEASE crapass.
   RELEASE crapsld.

END.  /*  Fim do DO WHILE TRUE  */

/* .......................................................................... */



