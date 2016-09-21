/* ............................................................................

   Programa: Fontes/previsp.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Eduardo       
   Data    : Outubro/2000                        Ultima atualizacao: 09/12/2011

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela PREVIS.

   Alteracao : 01/11/2000 - Erro ao calcular os totais e sub-totais (Eduardo).

               18/05/2001 - Acumular valores capturados dos titulos e cheques
                            acolhidos (Edson).
                            
               07/06/2001 - Incluir o KEYCODE(".") na digitacao dos valores.
                            (Ze Eduardo). 

               09/07/2001 - Alterado para ignorar os cheques com situacao igual
                            a 3 (comp. terceiros) - Edson.

               26/07/2001 - Alterado para tratar apenas os cheques de custodia
                            processados: insitchq = 2 (Edson).
               
               08/10/2004 - Tratar desconto de cheques (Edson).
               
               27/01/2005 - Mudado o HELP do campo "tel_cdagenci" de
                            "Informe a agencia" para "Informe o PAC";
                            VALIDATE de "015 - Agencia nao cadastrada." para
                            "015 - PAC nao cadastrado." (Evandro).

               05/07/2005 - Alimentado campo cdcooper da tabela crapprv (Diego).

               31/01/2006 - Unififcacao dos Bancos - SQLWorks - Fernando 

               16/03/2010 - Inclusao da opcao "F" e consultar deb/cre DEV, DOC,
                            TED/TEC, TIT e CHQ. (Guilherme/Supero)
                            Alterado para que, quando for F e Coop CECRED,
                            apresente os valores de 085 calculados para todas
                            as COOP, exceto 3. (Guilherme/Supero)
                            
               17/11/2010 - Incluir opcao "F" para consultas do PAC 90 e 91 (Ze)
                            Incluir opcao "L" (Guilherme/Supero).

               15/02/2011 - Opcao "L"  - Processar as mesmas tabelas que a 
                            opcao "F" (Guilherme/Supero).

               23/02/2011 - Opcao "F" - Incluir combo de Coop logada e Todas
                           (Guilherme/Supero).
               05/04/2011 - Acertar atualizacao das TECS, passar a somar
                            pelo historico quando nossa IF (Magui).
                            
               18/04/2011 - Eliminar na somatoria para opcao L as devolucoes nr
                            do BB e Bancoob (Ze).
                            
               20/07/2011 - Tratamento para a opcao L - Tarefa 41364 (Ze).
               
               03/11/2011 - Inclusão da moeda de R$ 1,00 e as cédulas de 
                            R$ 20,00 e R$ 100,00 (Isara - RKAM)
                            
               09/12/2011 - Incluido informacoes de transferencia entre 
                            cooperativas (Elton).
 ............................................................................ */

{ includes/var_online.i }

DEF    VAR tel_vldepesp AS DECIMAL           FORMAT "zzz,zzz,zz9.99" NO-UNDO.
DEF    VAR tel_vldvlnum AS DECIMAL           FORMAT "zzz,zzz,zz9.99" NO-UNDO.
DEF    VAR tel_vldvlbcb AS DECIMAL           FORMAT "zzz,zzz,zz9.99" NO-UNDO.
DEF    VAR tel_vlremdoc AS DECIMAL           FORMAT "zzz,zzz,zz9.99" NO-UNDO.
DEF    VAR tel_vlremtit AS DECIMAL           FORMAT "zzz,zzz,zz9.99" NO-UNDO.

DEF    VAR tel_qtremdoc AS INT               FORMAT "zzz,zz9"        NO-UNDO.
DEF    VAR tel_qtremtit AS INT               FORMAT "zzz,zz9"        NO-UNDO.
DEF    VAR tel_qtdvlbcb AS INT               FORMAT "zzz,zz9"        NO-UNDO.

DEF    VAR tel_qtmoedas AS INT     EXTENT 6  FORMAT "zz9"            NO-UNDO.
DEF    VAR tel_qtdnotas AS INT     EXTENT 6  FORMAT "zzz,zz9"        NO-UNDO.
DEF    VAR tel_dtmvtolt AS DATE              FORMAT "99/99/9999"     NO-UNDO.
DEF    VAR tel_cdagenci AS INT               FORMAT "z9"             NO-UNDO.
DEF    VAR tel_vlmoedas AS DECIMAL EXTENT 6  FORMAT "zzz,zz9.99"     NO-UNDO.
DEF    VAR tel_vldnotas AS DECIMAL EXTENT 6  FORMAT "zzz,zz9.99"     NO-UNDO.
DEF    VAR tel_submoeda AS DECIMAL EXTENT 6  FORMAT "zzz,zz9.99"     NO-UNDO.
DEF    VAR tel_subnotas AS DECIMAL EXTENT 6  FORMAT "zzz,zz9.99"     NO-UNDO.
DEF    VAR tel_totmoeda AS DECIMAL           FORMAT "zzz,zzz,zz9.99" NO-UNDO.
DEF    VAR tel_totnotas AS DECIMAL           FORMAT "zzz,zzz,zz9.99" NO-UNDO.
DEF    VAR tel_nmoperad AS CHAR              FORMAT "x(30)"          NO-UNDO.
DEF    VAR tel_hrtransa AS CHAR              FORMAT "x(08)"          NO-UNDO.  

DEF    VAR aux_qtmoepct AS INT     EXTENT 6  FORMAT "zz9"            NO-UNDO.
DEF    VAR aux_contador AS INT               FORMAT "z9"             NO-UNDO.
DEF    VAR aux_cddopcao AS CHAR                                      NO-UNDO.
DEF    VAR aux_cdagefim AS INT                                       NO-UNDO.
DEF    VAR aux_idbcoctl AS INT                                       NO-UNDO.
DEF    VAR tel_totaldeb AS DECIMAL EXTENT 3  FORMAT "zzz,zzz,zz9.99" NO-UNDO.
DEF    VAR tel_totalcre AS DECIMAL EXTENT 3  FORMAT "zzz,zzz,zz9.99" NO-UNDO.

DEF    VAR tel_vlcobbil AS DECIMAL FORMAT "zzz,zzz,zzz,zzz,zz9.99-"  NO-UNDO.
DEF    VAR tel_vlcobmlt AS DECIMAL FORMAT "zzz,zzz,zzz,zzz,zz9.99-"  NO-UNDO.
DEF    VAR tel_vlchqnot AS DECIMAL FORMAT "zzz,zzz,zzz,zzz,zz9.99-"  NO-UNDO.
DEF    VAR tel_vlchqdia AS DECIMAL FORMAT "zzz,zzz,zzz,zzz,zz9.99-"  NO-UNDO.

DEF    VAR tel_cdbcoval AS INT     EXTENT 3  FORMAT "999"            NO-UNDO.

DEF    VAR aux_dtliqd-1 AS DATE                                      NO-UNDO.
DEF    VAR aux_dtliqd-2 AS DATE                                      NO-UNDO.
DEF    VAR aux_valorvlb AS DECIMAL                                   NO-UNDO.
DEF    VAR aux_valorchq AS DECIMAL                                   NO-UNDO.
DEF    VAR aux_flferiad AS LOGICAL                                   NO-UNDO.

/* NR */
DEF    VAR tel_totdocnr AS DECIMAL EXTENT 3  FORMAT "zzz,zzz,zz9.99" NO-UNDO.
DEF    VAR tel_tottednr AS DECIMAL EXTENT 3  FORMAT "zzz,zzz,zz9.99" NO-UNDO.
DEF    VAR tel_tottitnr AS DECIMAL EXTENT 3  FORMAT "zzz,zzz,zz9.99" NO-UNDO.
DEF    VAR tel_totchqnr AS DECIMAL EXTENT 3  FORMAT "zzz,zzz,zz9.99" NO-UNDO.
DEF    VAR tel_totdevnr AS DECIMAL EXTENT 3  FORMAT "zzz,zzz,zz9.99" NO-UNDO.

DEF    VAR tel_tottrcop AS DECIMAL FORMAT "zzz,zzz,zz9.99"           NO-UNDO.

DEF    VAR aux_dsllabel AS CHAR                                      NO-UNDO.
DEF    VAR aux_nmcooper AS CHAR                                      NO-UNDO.
DEF    VAR aux_nmcoper2 AS CHAR                                      NO-UNDO.
DEF    VAR tel_cdcooper AS CHAR FORMAT "x(12)" VIEW-AS COMBO-BOX   
                                INNER-LINES 2                        NO-UNDO.
DEF    VAR tel_cdcoper2 AS CHAR FORMAT "x(12)" VIEW-AS COMBO-BOX   
                                INNER-LINES 12                       NO-UNDO.
                                

FORM SPACE(1)
     WITH ROW 4 OVERLAY 16 DOWN WIDTH 80 TITLE glb_tldatela FRAME f_moldura.

FORM glb_cddopcao  AT 4 LABEL "Opcao" AUTO-RETURN 
                   HELP "Entre com a opcao desejada (A,C,F,I,L)" 
                    VALIDATE(CAN-DO("A,C,F,I,L",glb_cddopcao),
                                   "014 - Opcao errada.")
    WITH ROW 6 COLUMN 2 SIDE-LABELS OVERLAY NO-BOX FRAME f_opcao.


FORM tel_cdcooper  AT 04 LABEL "Cooperativa" AUTO-RETURN
                         HELP "Selecione a Cooperativa"
    
     tel_dtmvtolt  AT 35 LABEL "Referencia" AUTO-RETURN
                   HELP "Entre com a data a que se refere a previsao."
                   VALIDATE (tel_dtmvtolt <> ? OR
                             tel_dtmvtolt <= glb_dtmvtolt, 
                             "013 - Data errada.")
     tel_cdagenci  AT 59 LABEL "Pac"                            
                   HELP "Informe o PAC ou nao preencha p/ saber o total."
                   VALIDATE ((tel_cdagenci = 0 AND glb_cddopcao = "C") OR
                            (tel_cdagenci = 0 AND glb_cddopcao = "F") OR
                            (glb_cdcooper = 3 AND glb_cddopcao = "F"  AND
                             (INPUT tel_cdagenci = 90 OR 
                              INPUT tel_cdagenci = 91)) OR 
                            CAN-FIND(crapage WHERE crapage.cdcooper = 
                                                   glb_cdcooper      AND 
                                                   crapage.cdagenci = 
                                                   INPUT tel_cdagenci),
                            "015 - PAC nao cadastrado.")
     WITH OVERLAY ROW 6 COLUMN 13 SIDE-LABEL NO-BOX FRAME f_previs_f.


FORM tel_dtmvtolt  AT 10 LABEL "Referencia" AUTO-RETURN
                   HELP "Entre com a data a que se refere a previsao."
                   VALIDATE (tel_dtmvtolt <> ? OR
                             tel_dtmvtolt <= glb_dtmvtolt,
                             "013 - Data errada.")
     tel_cdagenci  AT 48 LABEL "Pac"
                   HELP "Informe o PAC ou nao preencha p/ saber o total."
                   VALIDATE ((tel_cdagenci = 0 AND glb_cddopcao = "C") OR
                             (tel_cdagenci = 0 AND glb_cddopcao = "F") OR
                             (glb_cdcooper = 3 AND glb_cddopcao = "F"  AND
                             (INPUT tel_cdagenci = 90 OR
                              INPUT tel_cdagenci = 91)) OR
                              CAN-FIND(crapage WHERE crapage.cdcooper =
                                                     glb_cdcooper      AND
                                                     crapage.cdagenci =
                                                     INPUT tel_cdagenci),
                              "015 - PAC nao cadastrado.")
     WITH OVERLAY ROW 6 COLUMN 13 SIDE-LABEL NO-BOX FRAME f_previs_1.


FORM tel_dtmvtolt  AT  10 LABEL "Data de Liquidacao" AUTO-RETURN
                   HELP "Entre com a data de liquidacao."
                   VALIDATE (tel_dtmvtolt <> ? OR
                             tel_dtmvtolt <= glb_dtmvtolt, 
                             "013 - Data errada.")
    WITH OVERLAY ROW 6 COLUMN 13 SIDE-LABEL NO-BOX FRAME f_previs_2.

FORM SKIP(1)
     "DEVOLUCAO"   AT 4           
     tel_vldepesp  AT 15 LABEL "Deposito Cooper"
     "TITULOS"     AT 48            
     "Qtd.:"       AT 57
     tel_qtremtit  AT 70 NO-LABEL 
     SKIP
     tel_vldvlnum  AT 21 LABEL "Numerario"  
     tel_vlremtit  AT 56 LABEL "Valor"
     SKIP
     tel_vldvlbcb  AT 17 LABEL "Cheques COMPE"  
     SKIP(1)
     "SUPRIMENTOS" AT 04           
     "Moedas"      AT 18
     "Pacotes"     AT 26
     "Total"       AT 38
     "Notas"       AT 52 
     "Quantid"     AT 59
     "Total"       AT 72 
     SKIP
     tel_vlmoedas[1]  AT 13  NO-LABEL
     tel_qtmoedas[1]  AT 28  NO-LABEL
     tel_submoeda[1]  AT 33  NO-LABEL
     tel_vldnotas[1]  AT 47  NO-LABEL
     tel_qtdnotas[1]  AT 59  NO-LABEL
     tel_subnotas[1]  AT 67  NO-LABEL
     SKIP
     tel_vlmoedas[2]  AT 13  NO-LABEL
     tel_qtmoedas[2]  AT 28  NO-LABEL
     tel_submoeda[2]  AT 33  NO-LABEL
     tel_vldnotas[2]  AT 47  NO-LABEL
     tel_qtdnotas[2]  AT 59  NO-LABEL
     tel_subnotas[2]  AT 67  NO-LABEL
     SKIP     
     tel_vlmoedas[3]  AT 13  NO-LABEL
     tel_qtmoedas[3]  AT 28  NO-LABEL
     tel_submoeda[3]  AT 33  NO-LABEL
     tel_vldnotas[3]  AT 47  NO-LABEL
     tel_qtdnotas[3]  AT 59  NO-LABEL
     tel_subnotas[3]  AT 67  NO-LABEL
     SKIP     
     tel_vlmoedas[4]  AT 13  NO-LABEL
     tel_qtmoedas[4]  AT 28  NO-LABEL
     tel_submoeda[4]  AT 33  NO-LABEL
     tel_vldnotas[5]  AT 47  NO-LABEL
     tel_qtdnotas[5]  AT 59  NO-LABEL
     tel_subnotas[5]  AT 67  NO-LABEL
     SKIP
     tel_vlmoedas[5]  AT 13  NO-LABEL
     tel_qtmoedas[5]  AT 28  NO-LABEL
     tel_submoeda[5]  AT 33  NO-LABEL
     tel_vldnotas[4]  AT 47  NO-LABEL
     tel_qtdnotas[4]  AT 59  NO-LABEL
     tel_subnotas[4]  AT 67  NO-LABEL
     SKIP
     tel_vlmoedas[6]  AT 13  NO-LABEL
     tel_qtmoedas[6]  AT 28  NO-LABEL
     tel_submoeda[6]  AT 33  NO-LABEL
     tel_vldnotas[6]  AT 47  NO-LABEL
     tel_qtdnotas[6]  AT 59  NO-LABEL
     tel_subnotas[6]  AT 67  NO-LABEL
     SKIP
     "Totais:"      AT 04
     tel_totmoeda   AT 29 NO-LABEL
     tel_totnotas   AT 63 NO-LABEL
     SKIP
     tel_nmoperad   AT 04 LABEL "Operador" 
     tel_hrtransa   AT 58 NO-LABEL
     WITH ROW 7 COLUMN 2 OVERLAY SIDE-LABELS NO-BOX FRAME f_previs.
 
FORM SKIP(1)
     "DEBITOS"       AT 07
     tel_cdbcoval[1] AT 23 LABEL "BANCO"
     tel_cdbcoval[2] AT 42 LABEL "BANCO"
     tel_cdbcoval[3] AT 62 LABEL "BANCO"
     SKIP
     "DOC NR:"       AT 11
     tel_totdocnr[1] AT 20  NO-LABEL
     tel_totdocnr[2] AT 39  NO-LABEL
     tel_totdocnr[3] AT 58  NO-LABEL
     SKIP
     "TED/TEC NR:"   AT 07
     tel_tottednr[1] AT 20  NO-LABEL
     tel_tottednr[2] AT 39  NO-LABEL
     tel_tottednr[3] AT 58  NO-LABEL
     SKIP
     "Titulos NR:"   AT 07
     tel_tottitnr[1] AT 20  NO-LABEL
     tel_tottitnr[2] AT 39  NO-LABEL
     tel_tottitnr[3] AT 58  NO-LABEL
     SKIP
     "TRF.INTERCOOP:" AT 04
     tel_tottrcop     AT 58 NO-LABEL
     SKIP(1)
     "TOTAL:"        AT 12
     tel_totaldeb[1] AT 20  NO-LABEL
     tel_totaldeb[2] AT 39  NO-LABEL
     tel_totaldeb[3] AT 58  NO-LABEL
     SKIP(1)
     "CREDITOS"      AT 06
     SKIP
     "Cheques NR:"   AT 07
     tel_totchqnr[1] AT 20  NO-LABEL
     tel_totchqnr[2] AT 39  NO-LABEL
     tel_totchqnr[3] AT 58  NO-LABEL
     SKIP
     "Devolucao NR:" AT 05
     tel_totdevnr[1] AT 20  NO-LABEL
     tel_totdevnr[2] AT 39  NO-LABEL
     tel_totdevnr[3] AT 58  NO-LABEL
     SKIP(1)
     "TOTAL:"        AT 12
     tel_totalcre[1] AT 20  NO-LABEL
     tel_totalcre[2] AT 39  NO-LABEL
     tel_totalcre[3] AT 58  NO-LABEL
     WITH ROW 7 COLUMN 2 OVERLAY SIDE-LABELS NO-BOX FRAME f_previs_nr_sr.

FORM tel_cdcoper2  AT 04 LABEL "Cooperativa" AUTO-RETURN
                         HELP "Selecione a Cooperativa"
    
     tel_dtmvtolt  AT 35 LABEL "Referencia" AUTO-RETURN
                   HELP "Entre com a data a que se refere a previsao."
                   VALIDATE (tel_dtmvtolt <> ? OR
                             tel_dtmvtolt <= glb_dtmvtolt, 
                             "013 - Data errada.")
     WITH OVERLAY ROW 6 COLUMN 13 SIDE-LABEL NO-BOX FRAME f_previs_l_cabec.

FORM SKIP(1)
     "SILOC (Cobranca NR + DOC NR)"       AT 12
     SKIP(1)
     tel_vlcobbil         TO 60 LABEL "Cobranca/DOC Bilateral"
     tel_vlcobmlt         TO 60 LABEL "Cobranca/DOC Multilateral"
     SKIP(2)
     "COMPE (Cheques NR)"                 AT 12
     SKIP(1)
     tel_vlchqnot         TO 60  LABEL "Compensacao Noturna"
     tel_vlchqdia         TO 60  LABEL "Compensacao Diurna"
     WITH ROW 8 COLUMN 2 OVERLAY SIDE-LABELS NO-BOX FRAME f_previs_l.


IF   glb_cdcooper = 3 THEN
     ASSIGN aux_nmcooper = "TODAS,0".
ELSE
     ASSIGN aux_nmcooper = CAPS(glb_nmrescop) + "," + STRING(glb_cdcooper) +
                           ",TODAS,0".

FOR EACH crapcop WHERE crapcop.cdcooper <> 3 NO-LOCK BY crapcop.dsdircop:

    IF   aux_contador = 0 THEN
         ASSIGN aux_nmcoper2 = "TODAS,0," + CAPS(crapcop.dsdircop) + "," +
                               STRING(crapcop.cdcooper)
                aux_contador = 1.
    ELSE
          ASSIGN aux_nmcoper2 = aux_nmcoper2 + "," + CAPS(crapcop.dsdircop)
                                             + "," + STRING(crapcop.cdcooper).
END.

ASSIGN tel_cdcooper:LIST-ITEM-PAIRS = aux_nmcooper.

ON RETURN OF tel_cdcooper 
   DO:
       tel_cdcooper = tel_cdcooper:SCREEN-VALUE.
       APPLY "TAB".
   END.
   
ASSIGN tel_cdcoper2:LIST-ITEM-PAIRS = aux_nmcoper2.

ON RETURN OF tel_cdcoper2 
   DO:
       tel_cdcoper2 = tel_cdcoper2:SCREEN-VALUE.
       APPLY "TAB".
   END.

VIEW FRAME f_moldura.

glb_cddopcao = "C".

tel_dtmvtolt = glb_dtmvtolt.
          
PAUSE 0.

DO WHILE TRUE:

   CLEAR FRAME f_opcao.
   CLEAR FRAME f_previs_1.
   CLEAR FRAME f_previs_2.
   CLEAR FRAME f_previs_debre.
   CLEAR FRAME f_previs_f.
   CLEAR FRAME f_previs.
   
   RUN fontes/inicia.p.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      UPDATE glb_cddopcao WITH FRAME f_opcao.
      LEAVE.

   END.
   
   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
        DO:
            RUN fontes/novatela.p.
            IF   CAPS(glb_nmdatela) <> "PREVIS"   THEN
                 DO:
                     HIDE FRAME f_opcao.
                     HIDE FRAME f_previs.
                     HIDE FRAME f_previs_1.
                     HIDE FRAME f_previs_2.
                     HIDE FRAME f_previs_f.
                     HIDE FRAME f_previs_l_cabec.
                     HIDE FRAME f_previs_l.
                     HIDE FRAME f_previs_nr_sr.
                     HIDE FRAME f_moldura.
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
  
   glb_cdcritic = 0.

   ASSIGN tel_totdevnr = 0
          tel_totdocnr = 0
          tel_tottednr = 0
          tel_tottitnr = 0
          tel_totchqnr = 0
          tel_tottrcop = 0.

   CASE glb_cddopcao:

      WHEN "A" THEN
        DO:
            HIDE FRAME f_previs_nr_sr.
            HIDE FRAME f_previs.
            HIDE FRAME f_previs_l_cabec.
            HIDE FRAME f_previs_l.
            HIDE FRAME f_previs_1.
            HIDE FRAME f_previs_2.
            HIDE FRAME f_previs_f.

            RUN p_buscavls.
            
            tel_dtmvtolt = glb_dtmvtolt.
            
            DISPLAY tel_dtmvtolt WITH FRAME f_previs_1.
            
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
               
               UPDATE tel_cdagenci WITH FRAME f_previs_1.
             
               DO TRANSACTION ON ENDKEY UNDO, LEAVE:
              
                  FIND crapprv WHERE crapprv.cdcooper = glb_cdcooper  AND 
                                     crapprv.dtmvtolt = glb_dtmvtolt  AND
                                     crapprv.cdagenci = tel_cdagenci          
                                     EXCLUSIVE-LOCK NO-ERROR. 
                  IF   NOT AVAILABLE crapprv  THEN
                       DO:
                           IF   LOCKED crapprv  THEN
                                glb_cdcritic = 341. 
                           ELSE
                                glb_cdcritic = 694.

                           RUN fontes/critic.p. 
                           BELL.   
                           MESSAGE glb_dscritic. 
                           glb_cdcritic = 0.
                           NEXT.
                       END.
 
                  ASSIGN tel_vldepesp = crapprv.vldepesp
                         tel_vldvlnum = crapprv.vldvlnum
                         tel_vldvlbcb = crapprv.vldvlbcb
                         tel_vlremdoc = crapprv.vlremdoc
                         tel_qtremdoc = crapprv.qtremdoc
                         tel_totmoeda = 0
                         tel_totnotas = 0.
               
                  /*  Nome do Operador  */
                  /*FIND crapope OF crapprv NO-LOCK NO-ERROR.*/
                  FIND crapope WHERE crapope.cdcooper = glb_cdcooper AND
                                     crapope.cdoperad = crapprv.cdoperad
                                     NO-LOCK NO-ERROR.
    
                  IF   NOT AVAILABLE crapope   THEN
                       tel_nmoperad = " - NAO CADASTRADO.".
                  ELSE
                       tel_nmoperad = crapope.nmoperad.
 
                  DO aux_contador =  1 TO 6:
                     ASSIGN tel_qtmoedas[aux_contador] =
                                         crapprv.qtmoedas[aux_contador]
                            tel_submoeda[aux_contador] =
                                         tel_vlmoedas[aux_contador] *
                                         tel_qtmoedas[aux_contador] *
                                         aux_qtmoepct[aux_contador]
                            tel_totmoeda = tel_totmoeda + 
                                           tel_submoeda[aux_contador]
                            tel_qtdnotas[aux_contador] =
                                         crapprv.qtdnotas[aux_contador]
                            tel_subnotas[aux_contador] = 
                                         tel_vldnotas[aux_contador] *
                                         tel_qtdnotas[aux_contador]
                            tel_totnotas = tel_totnotas + 
                                           tel_subnotas[aux_contador].
                  END.  /*   fim do DO TO  */
             
                  DO aux_contador = 1 TO 6:
                     DISPLAY tel_vlmoedas[aux_contador]
                             tel_qtmoedas[aux_contador]
                             tel_submoeda[aux_contador]
                             tel_vldnotas[aux_contador] 
                             tel_qtdnotas[aux_contador]
                             tel_subnotas[aux_contador]
                             WITH FRAME f_previs.
                  END.

                  DISPLAY tel_vldepesp tel_vldvlnum  tel_nmoperad 
                       /* tel_vlremdoc tel_qtremdoc */ tel_totmoeda tel_totnotas
                          STRING(crapprv.hrtransa,"HH:MM:SS") @ tel_hrtransa
                          WITH FRAME f_previs.

                  DO WHILE TRUE:
                     UPDATE tel_vldepesp tel_vldvlnum 
                       /*   tel_qtremdoc tel_vlremdoc       */
                            tel_qtmoedas[1] tel_qtmoedas[2] tel_qtmoedas[3]
                            tel_qtmoedas[4] tel_qtmoedas[5] tel_qtmoedas[6]
                            tel_qtdnotas[1] tel_qtdnotas[2] tel_qtdnotas[3]
                            tel_qtdnotas[5] tel_qtdnotas[4] tel_qtdnotas[6]
                            WITH FRAME f_previs
                     EDITING:
                     /*   IF   FRAME-INDEX = 1 AND 
                               ((INPUT tel_vlremdoc = 0 AND
                                 INPUT tel_qtremdoc <> 0) OR
                               (INPUT tel_vlremdoc <> 0 AND 
                                INPUT tel_qtremdoc = 0)) THEN
                               DO:
                                  glb_cdcritic = 697.
                                  RUN fontes/critic.p.
                                  BELL.
                                  MESSAGE glb_dscritic.
                                  glb_cdcritic = 0.
                                  NEXT-PROMPT tel_qtremdoc WITH FRAME f_previs.
                               END.     */
                       /* 
                          Procedimento na qual totaliza de imediato os campos
                          qtmoedas e qtdnotas digitado pelo usuario.
                        */
                          
                          IF   FRAME-FIELD = "tel_vldepesp"  OR
                               FRAME-FIELD = "tel_vldvlnum"  THEN
                               IF   LASTKEY =  KEYCODE(".")  THEN
                                    APPLY 44.
                          
                          IF   FRAME-INDEX > 0 THEN
                               DO:
                                   aux_contador = FRAME-INDEX.
                                                               
                                   IF   FRAME-FIELD = "tel_qtmoedas" Then
                                        DO: 
                                            tel_submoeda[aux_contador] =
                                                tel_vlmoedas[aux_contador] * 
                                                aux_qtmoepct[aux_contador] *
                                                INPUT tel_qtmoedas[aux_contador].

                                             DISPLAY tel_submoeda[aux_contador] 
                                                     WITH FRAME f_previs.

                                            IF   aux_contador = 6 Then
                                                 DO:
                                                     tel_totmoeda =
                                                         tel_submoeda[1] +
                                                         tel_submoeda[2] +
                                                         tel_submoeda[3] +
                                                         tel_submoeda[4] +
                                                         tel_submoeda[5] +
                                                         tel_submoeda[6].

                                                     DISPLAY tel_totmoeda
                                                     WITH FRAME f_previs.
                                                 END.
                                        END.  /*   fim do if   */
                                   ELSE
                                        DO:
                                            tel_subnotas[aux_contador] =
                                                 tel_vldnotas[aux_contador] * 
                                                 INPUT tel_qtdnotas[aux_contador].

                                             DISPLAY tel_subnotas[aux_contador]
                                                 WITH FRAME f_previs.

                                            IF   aux_contador = 6 Then
                                                 DO:
                                                     tel_totnotas =
                                                          tel_subnotas[1] +
                                                          tel_subnotas[2] +
                                                          tel_subnotas[3] +
                                                          tel_subnotas[4] +
                                                          tel_subnotas[5] +
                                                          tel_subnotas[6].

                                                     DISPLAY tel_totnotas
                                                     WITH FRAME f_previs.
                                                 END.
                                        END. /*  fim do else  */  
                               END. /*  fim  do  if Frame-Index  */
                          READKEY.
                          APPLY LASTKEY.
                     END.  /*  fim do Editing   */

                     ASSIGN crapprv.vldepesp = tel_vldepesp
                            crapprv.vldvlnum = tel_vldvlnum
                            crapprv.vldvlbcb = tel_vldvlbcb
                            crapprv.vlremdoc = tel_vlremdoc
                            crapprv.qtremdoc = tel_qtremdoc
                            crapprv.cdoperad = glb_cdoperad
                            crapprv.hrtransa = TIME.
                           
                     DO aux_contador = 1 TO 6:
                        ASSIGN crapprv.qtmoedas[aux_contador] = 
                               tel_qtmoedas[aux_contador]
                               crapprv.qtdnotas[aux_contador] = 
                               tel_qtdnotas[aux_contador].
                     END.
                     LEAVE.
                  END.      /*  Fim do While True  */
               END.     /*  Fim da transacao */
               LEAVE.
            END.
           
            RELEASE crapprv.

            IF   KEYFUNCTION(LASTKEY) = "END-ERROR" THEN  /* F4 OU FIM */
                 NEXT.

            CLEAR FRAME f_previs NO-PAUSE.
            
            DISPLAY glb_cddopcao WITH FRAME f_opcao.
        
      END.  /*  END do WHEN "A" */

      
      WHEN "C" THEN 
        DO:
            HIDE FRAME f_previs_nr_sr.
            HIDE FRAME f_previs.
            HIDE FRAME f_previs_l_cabec.
            HIDE FRAME f_previs_l.
            HIDE FRAME f_previs_1.
            HIDE FRAME f_previs_2.
            HIDE FRAME f_previs_f.

            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
              
                UPDATE tel_dtmvtolt tel_cdagenci WITH FRAME f_previs_1.

                ASSIGN tel_vldvlbcb = 0.
            
                RUN p_buscavls.

                RUN p_titulos.
                RUN p_compel.
              
                IF   tel_cdagenci > 0 THEN  /* Consulta de um unico PAC */
                     DO:
                         FIND crapprv WHERE crapprv.cdcooper = glb_cdcooper AND
                                            crapprv.dtmvtolt = tel_dtmvtolt AND
                                            crapprv.cdagenci = tel_cdagenci
                                            NO-LOCK NO-ERROR NO-WAIT.
                         IF   NOT AVAILABLE crapprv   THEN
                              DO:
                                  glb_cdcritic = 694.
                                  RUN fontes/critic.p.
                                  BELL.
                                  MESSAGE glb_dscritic.
                                  CLEAR FRAME f_opcao.
                                  DISPLAY glb_cddopcao WITH FRAME f_opcao.
                                  glb_cdcritic = 0.
                                  NEXT.
                              END.

                         ASSIGN tel_vldepesp = crapprv.vldepesp
                                tel_vldvlnum = crapprv.vldvlnum
                           /*   tel_vldvlbcb = crapprv.vldvlbcb   */
                                tel_vlremdoc = crapprv.vlremdoc
                                tel_qtremdoc = crapprv.qtremdoc
                                tel_totmoeda = 0
                                tel_totnotas = 0.
                 
                         /*  Nome do Operador  */
                       
                        /* FIND crapope OF crapprv NO-LOCK NO-ERROR.*/
                         FIND crapope WHERE crapope.cdcooper = glb_cdcooper AND
                                            crapope.cdoperad = crapprv.cdoperad
                                            NO-LOCK NO-ERROR.
                         IF   NOT AVAILABLE crapope   THEN
                              tel_nmoperad = " - NAO CADASTRADO.".
                         ELSE
                              tel_nmoperad = crapope.nmoperad.
 
                         DO aux_contador = 1 TO 6:
                       
                            ASSIGN tel_qtmoedas[aux_contador] =
                                              crapprv.qtmoedas[aux_contador]
                                   tel_submoeda[aux_contador] =
                                              tel_vlmoedas[aux_contador] *
                                              tel_qtmoedas[aux_contador] *
                                              aux_qtmoepct[aux_contador]
                                   tel_totmoeda = tel_totmoeda +
                                              tel_submoeda[aux_contador]
                                   tel_qtdnotas[aux_contador] =
                                              crapprv.qtdnotas[aux_contador]
                                   tel_subnotas[aux_contador] = 
                                              tel_vldnotas[aux_contador] *
                                              tel_qtdnotas[aux_contador]
                                   tel_totnotas = tel_totnotas + 
                                              tel_subnotas[aux_contador].
                         END.  /*   fim do DO TO  */
             
                         DO aux_contador = 1 TO 6:
                          
                            DISPLAY tel_vlmoedas[aux_contador]
                                    tel_qtmoedas[aux_contador]
                                    tel_submoeda[aux_contador]
                                    tel_vldnotas[aux_contador] 
                                    tel_qtdnotas[aux_contador]
                                    tel_subnotas[aux_contador] 
                                    WITH FRAME f_previs.
                         END.

                         DISPLAY tel_vldepesp tel_vldvlnum tel_vldvlbcb  
                                 tel_vlremtit tel_qtremtit tel_totmoeda 
                                 tel_totnotas tel_nmoperad
                                 STRING(crapprv.hrtransa,"HH:MM:SS") @ 
                                 tel_hrtransa
                                 WITH FRAME f_previs.
                     END. /*  fim do IF cdagenci <> 0  */
                ELSE                                                    
                     DO:  /*  Consulta todos os PAC  */                   
                         ASSIGN tel_vldepesp = 0 tel_vldvlnum = 0 
                         /*     tel_vldvlbcb = 0 tel_vlremdoc = 0   
                                tel_qtremdoc = 0 */ 
                                tel_qtmoedas = 0                
                                tel_submoeda = 0 tel_totmoeda = 0 
                                tel_qtdnotas = 0 tel_subnotas = 0 
                                tel_totnotas = 0.
                   
                         FOR EACH crapprv WHERE 
                                  crapprv.cdcooper = glb_cdcooper  AND
                                  crapprv.dtmvtolt = tel_dtmvtolt  NO-LOCK:
                                
                             ASSIGN tel_vldepesp = tel_vldepesp +
                                                   crapprv.vldepesp
                                    tel_vldvlnum = tel_vldvlnum + 
                                                   crapprv.vldvlnum
                                    /*
                                    tel_vldvlbcb = tel_vldvlbcb +
                                                   crapprv.vldvlbcb
                                    */
                                    tel_vlremdoc = tel_vlremdoc +
                                                   crapprv.vlremdoc
                                    tel_qtremdoc = tel_qtremdoc +
                                                   crapprv.qtremdoc.
                       
                             DO aux_contador =  1 TO 6:
                                ASSIGN tel_qtmoedas[aux_contador] =
                                           tel_qtmoedas[aux_contador] +
                                           crapprv.qtmoedas[aux_contador]
                                       tel_submoeda[aux_contador] =
                                                  tel_vlmoedas[aux_contador] *
                                                  tel_qtmoedas[aux_contador] *
                                                  aux_qtmoepct[aux_contador]
                                       tel_qtdnotas[aux_contador] =
                                                  tel_qtdnotas[aux_contador] +
                                                  crapprv.qtdnotas[aux_contador]
                                       tel_subnotas[aux_contador] = 
                                                  tel_subnotas[aux_contador] +
                                                  (tel_vldnotas[aux_contador] * 
                                                crapprv.qtdnotas[aux_contador]).
                             END. /*   fim  do DO TO   */          
                         END. /*   fim  do  FOR EACH   */
                                 
                         DO aux_contador = 1 TO 6:
                            ASSIGN  tel_totmoeda = tel_totmoeda +
                                                   tel_submoeda[aux_contador]
                                    tel_totnotas = tel_totnotas + 
                                                   tel_subnotas[aux_contador].

                            DISPLAY tel_vlmoedas[aux_contador]
                                    tel_qtmoedas[aux_contador]
                                    tel_submoeda[aux_contador]
                                    tel_vldnotas[aux_contador] 
                                    tel_qtdnotas[aux_contador]
                                    tel_subnotas[aux_contador] 
                                    WITH FRAME f_previs.
                         END.
                         
                         DISPLAY tel_vldepesp tel_vldvlnum tel_vldvlbcb  
                                 tel_vlremtit tel_qtremtit tel_totmoeda 
                                 tel_totnotas WITH FRAME f_previs.
                     END.    /*  fim do Else  */
             END. /*   fim do  Do  While   */

             IF   KEYFUNCTION(LASTKEY) = "END-ERROR" THEN  /* F4 OU FIM */
                  NEXT.
      END.  /*  END do WHEN "C" */

      
      WHEN "I" THEN 
        DO:
            HIDE FRAME f_previs_nr_sr.
            HIDE FRAME f_previs.
            HIDE FRAME f_previs_l_cabec.
            HIDE FRAME f_previs_l.
            HIDE FRAME f_previs_1.
            HIDE FRAME f_previs_2.
            HIDE FRAME f_previs_f.
            
            RUN p_buscavls.
            
            ASSIGN tel_vldepesp = 0  
                   tel_vldvlnum = 0  
                   tel_vldvlbcb = 0                             
                   tel_vlremdoc = 0  
                   tel_qtremdoc = 0  
                   tel_qtmoedas = 0                             
                   tel_submoeda = 0  
                   tel_totmoeda = 0  
                   tel_qtdnotas = 0                             
                   tel_subnotas = 0                   
                   tel_totnotas = 0  
                   tel_cdagenci = 0
                   tel_dtmvtolt = glb_dtmvtolt.
            
            DISPLAY tel_dtmvtolt WITH FRAME f_previs_1.
             
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
               UPDATE tel_cdagenci WITH FRAME f_previs_1.
               LEAVE.
            END.
           
            IF   KEYFUNCTION(LASTKEY) = "END-ERROR" THEN  /* F4 OU FIM */
                 NEXT.
            
            IF   CAN-FIND(crapprv WHERE crapprv.cdcooper = glb_cdcooper  AND 
                                        crapprv.dtmvtolt = glb_dtmvtolt  AND
                                        crapprv.cdagenci = tel_cdagenci) THEN          
                 DO:
                     glb_cdcritic = 693. 
                     RUN fontes/critic.p.
                     BELL.
                     MESSAGE glb_dscritic.
                     CLEAR FRAME f_opcao.
                     CLEAR FRAME f_previs.
                     DISPLAY glb_cddopcao WITH FRAME f_opcao.
                     glb_cdcritic = 0.
                     NEXT.
                 END.

            DO TRANSACTION ON ERROR UNDO, LEAVE ON ENDKEY UNDO, LEAVE:

               DO aux_contador = 1 TO 6:
                  DISPLAY tel_vlmoedas[aux_contador]
                          tel_vldnotas[aux_contador] WITH FRAME f_previs.
               END.
               
               DO WHILE TRUE:

                  UPDATE tel_vldepesp tel_vldvlnum 
                     /*  tel_qtremdoc tel_vlremdoc      */
                         tel_qtmoedas[1] tel_qtmoedas[2] tel_qtmoedas[3]
                         tel_qtmoedas[4] tel_qtmoedas[5] tel_qtmoedas[6]
                         tel_qtdnotas[1] tel_qtdnotas[2] tel_qtdnotas[3]
                         tel_qtdnotas[5] tel_qtdnotas[4] tel_qtdnotas[6] 
                         WITH FRAME f_previs
                  EDITING:
                    /*  IF   FRAME-INDEX = 1 AND 
                            ((INPUT tel_vlremdoc = 0 AND 
                              INPUT tel_qtremdoc <> 0) OR
                            (INPUT tel_vlremdoc <> 0 AND 
                             INPUT tel_qtremdoc = 0)) THEN
                            DO:
                                glb_cdcritic = 697.
                                RUN fontes/critic.p.
                                BELL.
                                MESSAGE glb_dscritic.
                                glb_cdcritic = 0.
                                NEXT-PROMPT tel_qtremdoc WITH FRAME f_previs.
                            END.  */
                        /* 
                          Procedimento na qual totaliza de imediato os campos
                          qtmoedas e qtdnotas digitado pelo usuario.
                        */
                       
                       IF   FRAME-FIELD = "tel_vldepesp"  OR
                            FRAME-FIELD = "tel_vldvlnum"  THEN
                            IF   LASTKEY =  KEYCODE(".")  THEN
                                 APPLY 44.

                       IF   FRAME-INDEX > 0 THEN
                            DO:
                               aux_contador = FRAME-INDEX.
                                                              
                               IF   FRAME-FIELD = "tel_qtmoedas" Then
                                    DO: 
                                       tel_submoeda[aux_contador] =
                                            tel_vlmoedas[aux_contador] * 
                                            aux_qtmoepct[aux_contador] * 
                                            INPUT tel_qtmoedas[aux_contador].

                                            DISPLAY tel_submoeda[aux_contador] 
                                               WITH FRAME f_previs.
                                       IF   aux_contador = 6 Then
                                            DO:
                                               tel_totmoeda =
                                                    tel_submoeda[1] +
                                                    tel_submoeda[2] +
                                                    tel_submoeda[3] +
                                                    tel_submoeda[4] +
                                                    tel_submoeda[5] + 
                                                    tel_submoeda[6].

                                               DISPLAY tel_totmoeda
                                                       WITH FRAME f_previs.
                                            END.
                                    END.  
                               ELSE
                                    DO:
                                       tel_subnotas[aux_contador] =
                                            tel_vldnotas[aux_contador] * 
                                            INPUT tel_qtdnotas[aux_contador].  

                                            DISPLAY tel_subnotas[aux_contador]
                                                    WITH FRAME f_previs.
                                       
                                       IF   aux_contador = 6 Then
                                            DO:
                                               tel_totnotas =
                                                    tel_subnotas[1] +
                                                    tel_subnotas[2] +
                                                    tel_subnotas[3] +
                                                    tel_subnotas[4] +
                                                    tel_subnotas[5] +
                                                    tel_subnotas[6].

                                               DISPLAY tel_totnotas
                                                     WITH FRAME f_previs.
                                            END.
                                    END. /*  fim do else  */  
                            END. /*  fim  do  if Frame-Index  */
                       READKEY.
                       APPLY LASTKEY.
                  END.  /*  fim do Editing   */

                  CREATE crapprv.
               
                  ASSIGN crapprv.cdagenci = tel_cdagenci
                         crapprv.dtmvtolt = glb_dtmvtolt 
                         crapprv.vldepesp = tel_vldepesp
                         crapprv.vldvlnum = tel_vldvlnum
                         crapprv.vldvlbcb = tel_vldvlbcb
                         crapprv.vlremdoc = tel_vlremdoc
                         crapprv.qtremdoc = tel_qtremdoc
                         crapprv.cdoperad = glb_cdoperad
                         crapprv.hrtransa = TIME
                         crapprv.cdcooper = glb_cdcooper.
                         
                  DO aux_contador = 1 TO 6:
                     ASSIGN  crapprv.qtmoedas[aux_contador] =
                                 tel_qtmoedas[aux_contador]
                             crapprv.qtdnotas[aux_contador] =
                                 tel_qtdnotas[aux_contador].
                  END.
                  LEAVE.
                END. /*  Fim do While True  */

            END. /* Fim da transacao */

            RELEASE crapprv.

            IF   KEYFUNCTION(LASTKEY) = "END-ERROR" THEN  /* F4 OU FIM */
                 NEXT.

            CLEAR FRAME f_previs   NO-PAUSE.
            CLEAR FRAME f_opcao    NO-PAUSE.
            DISPLAY glb_cddopcao WITH FRAME f_opcao.

      END.  /*  END do WHEN "I" */


      WHEN "F" THEN 
        DO:
            HIDE FRAME f_previs_nr_sr.
            HIDE FRAME f_previs.
            HIDE FRAME f_previs_l_cabec.
            HIDE FRAME f_previs_l.
            HIDE FRAME f_previs_1.
            HIDE FRAME f_previs_2.
            HIDE FRAME f_previs_f.

            tel_dtmvtolt = glb_dtmvtolt.
            DISPLAY tel_dtmvtolt WITH FRAME f_previs_f.

            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

              UPDATE tel_cdcooper tel_dtmvtolt tel_cdagenci 
                     WITH FRAME f_previs_f.
              
              ASSIGN aux_cdagefim = IF   tel_cdagenci = 0 THEN 
                                         9999
                                    ELSE tel_cdagenci.
    
              ASSIGN tel_cdbcoval[1] = 1
                     tel_cdbcoval[2] = 756
                     tel_cdbcoval[3] = 85
                     tel_totdevnr = 0
                     tel_totdocnr = 0
                     tel_tottednr = 0
                     tel_tottitnr = 0
                     tel_tottrcop = 0
                     tel_totchqnr = 0
                     tel_qtdvlbcb = 0
                     tel_vldvlbcb = 0
                     tel_totaldeb = 0
                     tel_totalcre = 0.

              IF   INT(tel_cdcooper) = 0  THEN
                   DO:
                       IF   glb_dsdepart <> "TI"                    AND
                            glb_dsdepart <> "SUPORTE"               AND
                            glb_dsdepart <> "COORD.ADM/FINANCEIRO"  AND
                            glb_dsdepart <> "COORD.PRODUTOS"        AND
                            glb_dsdepart <> "COMPE"                 AND
                            glb_dsdepart <> "FINANCEIRO"            THEN
                            DO:
                                ASSIGN glb_cdcritic = 36.
                                RUN fontes/critic.p.
                                ASSIGN glb_cdcritic = 0.
                                BELL.
                                MESSAGE glb_dscritic.
                                NEXT.
                            END.
                       ELSE 
                            DO:
                                FOR EACH crapcop WHERE crapcop.cdcooper <> 3
                                                       NO-LOCK:
    
                                    RUN pi_devolu_nr(INPUT glb_cddopcao,
                                                     INPUT crapcop.cdcooper,
                                                     INPUT tel_dtmvtolt).
    
                                    RUN pi_doc_nr(INPUT glb_cddopcao,
                                                  INPUT crapcop.cdcooper,
                                                  INPUT tel_dtmvtolt).
    
                                    RUN pi_tedtec_nr.
    
                                    RUN pi_titulos_nr(INPUT glb_cddopcao,
                                                      INPUT crapcop.cdcooper,
                                                      INPUT tel_dtmvtolt).
    
                                    RUN pi_cheques_nr(INPUT glb_cddopcao,
                                                      INPUT crapcop.cdcooper,
                                                      INPUT tel_dtmvtolt).
                                        
                                    RUN pi_transf_coop(INPUT crapcop.cdcooper,
                                                       INPUT tel_dtmvtolt).
                                END.
                            END.
                   END.
              ELSE
                   DO:
                      FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper 
                                         NO-LOCK NO-ERROR.

                      RUN pi_devolu_nr (INPUT glb_cddopcao,
                                        INPUT crapcop.cdcooper,
                                        INPUT tel_dtmvtolt).

                      RUN pi_doc_nr (INPUT glb_cddopcao,
                                     INPUT crapcop.cdcooper,
                                     INPUT tel_dtmvtolt).

                      RUN pi_tedtec_nr.

                      RUN pi_titulos_nr (INPUT glb_cddopcao,
                                         INPUT crapcop.cdcooper,
                                         INPUT tel_dtmvtolt).

                      RUN pi_cheques_nr (INPUT glb_cddopcao,
                                         INPUT crapcop.cdcooper,
                                         INPUT tel_dtmvtolt).

                      RUN pi_transf_coop(INPUT crapcop.cdcooper,
                                         INPUT tel_dtmvtolt).
              END.

              ASSIGN tel_totaldeb[1] = tel_totaldeb[1] + tel_totdocnr[1]
                     tel_totaldeb[2] = tel_totaldeb[2] + tel_totdocnr[2]
                     tel_totaldeb[3] = tel_totaldeb[3] + tel_totdocnr[3]
                     tel_totaldeb[1] = tel_totaldeb[1] + tel_tottednr[1]
                     tel_totaldeb[2] = tel_totaldeb[2] + tel_tottednr[2]
                     tel_totaldeb[3] = tel_totaldeb[3] + tel_tottednr[3]
                     tel_totaldeb[1] = tel_totaldeb[1] + tel_tottitnr[1]
                     tel_totaldeb[2] = tel_totaldeb[2] + tel_tottitnr[2]
                     tel_totaldeb[3] = tel_totaldeb[3] + tel_tottitnr[3]
                     tel_totaldeb[3] = tel_totaldeb[3] + tel_tottrcop.
                     
              ASSIGN tel_totalcre[1] = tel_totalcre[1] + tel_totdevnr[1]
                     tel_totalcre[2] = tel_totalcre[2] + tel_totdevnr[2]
                     tel_totalcre[3] = tel_totalcre[3] + tel_totdevnr[3]
                     tel_totalcre[1] = tel_totalcre[1] + tel_totchqnr[1]
                     tel_totalcre[2] = tel_totalcre[2] + tel_totchqnr[2]
                     tel_totalcre[3] = tel_totalcre[3] + tel_totchqnr[3].
              
              DISPLAY tel_cdbcoval    tel_totdocnr     tel_tottednr
                      tel_tottitnr    tel_tottrcop     tel_totaldeb[1]  
                      tel_totaldeb[2] tel_totaldeb[3]  tel_totchqnr     
                      tel_totdevnr    tel_totalcre[1]  tel_totalcre[2]  
                      tel_totalcre[3] WITH FRAME f_previs_nr_sr.

            END. /*   fim do  Do  While   */

            IF   KEYFUNCTION(LASTKEY) = "END-ERROR" THEN  /* F4 OU FIM */
                 NEXT.
      END.
      
      WHEN "L" THEN 
        DO:
            HIDE FRAME f_previs_nr_sr.
            HIDE FRAME f_previs.
            HIDE FRAME f_previs_l_cabec.
            HIDE FRAME f_previs_l.
            HIDE FRAME f_previs_1.
            HIDE FRAME f_previs_2.
            HIDE FRAME f_previs_f.

            IF   glb_dsdepart <> "TI"                    AND
                 glb_dsdepart <> "SUPORTE"               AND
                 glb_dsdepart <> "COORD.ADM/FINANCEIRO"  AND
                 glb_dsdepart <> "COORD.PRODUTOS"        AND
                 glb_dsdepart <> "COMPE"                 AND
                 glb_dsdepart <> "FINANCEIRO"            THEN
                 DO:
                     glb_cdcritic = 36.
                     RUN fontes/critic.p.
                     BELL.
                     MESSAGE glb_dscritic.
                     glb_cdcritic = 0.
                     NEXT.
                 END.

            ASSIGN tel_dtmvtolt = glb_dtmvtolt.

            DISPLAY tel_dtmvtolt WITH FRAME f_previs_l_cabec.

            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

               UPDATE tel_cdcoper2 tel_dtmvtolt WITH FRAME f_previs_l_cabec.

               RUN pi_calcula_datas (INPUT  tel_dtmvtolt,
                                     OUTPUT aux_flferiad).

               IF   NOT aux_flferiad THEN
                    DO:          
                        ASSIGN aux_cdagefim = IF tel_cdagenci = 0 THEN 9999
                                              ELSE tel_cdagenci.

                        ASSIGN tel_vlcobbil = 0
                               tel_vlcobmlt = 0
                               tel_vlchqnot = 0
                               tel_vlchqdia = 0.

                        /********** BUSCA PARAMETROS **********/
                        FIND craptab WHERE craptab.cdcooper = glb_cdcooper  AND
                                           craptab.nmsistem = "CRED"        AND
                                           craptab.tptabela = "GENERI"      AND
                                           craptab.cdempres = 0             AND
                                           craptab.cdacesso = "VALORESVLB"  AND
                                           craptab.tpregist = 0
                                           USE-INDEX craptab1 NO-LOCK NO-ERROR.

                        IF   AVAILABLE craptab THEN
                             aux_valorvlb =
                                     DECIMAL(ENTRY(1,craptab.dstextab,";")).
                        ELSE
                             aux_valorvlb = 5000.

                        FIND craptab WHERE craptab.cdcooper = glb_cdcooper   AND
                                           craptab.nmsistem = "CRED"         AND
                                           craptab.tptabela = "USUARI"       AND
                                           craptab.cdempres = 11             AND
                                           craptab.cdacesso = "MAIORESCHQ"   AND
                                           craptab.tpregist = 001
                                           USE-INDEX craptab1 NO-LOCK NO-ERROR.
             
                        IF   AVAIL craptab THEN
                             aux_valorchq = 
                                    DECIMAL(SUBSTRING(craptab.dstextab,01,15)).
                        ELSE
                             aux_valorchq = 300.

                        FOR EACH crapcop WHERE (INT(tel_cdcoper2) = 0  AND
                                               crapcop.cdcooper <> 3)  OR
                                               crapcop.cdcooper =
                                                      INT(tel_cdcoper2)
                                               NO-LOCK:

                            HIDE MESSAGE NO-PAUSE.
                            MESSAGE "Aguarde....Processando Cooperativa: " +
                                    STRING(crapcop.nmrescop).

                            /******** CARGA VALORES DE COMPE *********/
                            RUN pi_devolu_nr (INPUT glb_cddopcao,
                                              INPUT crapcop.cdcooper,
                                              INPUT tel_dtmvtolt).

                            RUN pi_cheques_nr (INPUT glb_cddopcao,
                                               INPUT crapcop.cdcooper,
                                               INPUT tel_dtmvtolt).
                            /******** CARGA VALORES DE COMPE *********/

                            /***** CARGA VALORES DE COBRANCA ******/
                            RUN pi_doc_nr (INPUT glb_cddopcao,
                                           INPUT crapcop.cdcooper,
                                           INPUT tel_dtmvtolt).

                            RUN pi_titulos_nr (INPUT glb_cddopcao,
                                               INPUT crapcop.cdcooper,
                                               INPUT tel_dtmvtolt).
                            /***** CARGA VALORES DE COBRANCA ******/
                        END.
                    END.
               ELSE
                    ASSIGN tel_vlcobbil = 0
                           tel_vlcobmlt = 0
                           tel_vlchqnot = 0
                           tel_vlchqdia = 0.

               HIDE MESSAGE NO-PAUSE.

               DISPLAY tel_vlcobbil tel_vlcobmlt 
                       tel_vlchqnot tel_vlchqdia 
                       WITH FRAME f_previs_l.
            
            END. /* END do DO WHILE TRUE */

            IF   KEYFUNCTION(LASTKEY) = "END-ERROR" THEN  /* F4 OU FIM */
                 NEXT.

        END.
   
   END CASE.
        
   PAUSE 0.
END.

/*............................................................................*/

PROCEDURE p_buscavls:
/******* Atribui as var. auxiliares os valores das moedas e das notas *******/

    DO aux_contador =  1 TO 6:          /*   M O E D A S  */  
       FIND craptab WHERE craptab.cdcooper = glb_cdcooper   AND
                          craptab.nmsistem = "CRED"         AND
                          craptab.tptabela = "GENERI"       AND
                          craptab.cdempres = 00             AND
                          craptab.cdacesso = "VLORMOEDAS"   AND
                          craptab.tpregist = aux_contador   NO-LOCK NO-ERROR.
               
       IF   NOT AVAILABLE craptab THEN
            ASSIGN tel_vlmoedas[aux_contador] = 0
                   aux_qtmoepct[aux_contador] = 0.
       ELSE
            ASSIGN tel_vlmoedas[aux_contador] =
                   DECIMAL(SUBSTRING(craptab.dstextab,1,12))
                   aux_qtmoepct[aux_contador] = 
                               INTEGER(SUBSTRING(craptab.dstextab,14,6)).
           
       FIND craptab WHERE craptab.cdcooper = glb_cdcooper   AND 
                          craptab.nmsistem = "CRED"         AND
                          craptab.tptabela = "GENERI"       AND
                          craptab.cdempres = 00             AND
                          craptab.cdacesso = "VLORMOEDAS"   AND
                          craptab.tpregist = aux_contador   NO-LOCK NO-ERROR.
               
       IF   NOT AVAILABLE craptab THEN
            ASSIGN tel_vlmoedas[aux_contador] = 0
                   aux_qtmoepct[aux_contador] = 0.
       ELSE
            ASSIGN tel_vlmoedas[aux_contador] = 
                                DECIMAL(SUBSTRING(craptab.dstextab,1,12))
                   aux_qtmoepct[aux_contador] = 
                                INTEGER(SUBSTRING(craptab.dstextab,14,6)).
                                        
                                        /*   C E D U L A S   */
       FIND craptab WHERE craptab.cdcooper = glb_cdcooper   AND
                          craptab.nmsistem = "CRED"         AND
                          craptab.tptabela = "GENERI"       AND
                          craptab.cdempres = 00             AND
                          craptab.cdacesso = "VLRCEDULAS"   AND
                          craptab.tpregist = aux_contador   NO-LOCK NO-ERROR.
               
       IF   NOT AVAILABLE craptab THEN
            tel_vldnotas[aux_contador] = 0.
       ELSE
            DO:
                /*  Tratamento para substituir Nota de 1,00 para 2,00  */
                
                IF   aux_contador =  1          AND
                     glb_cddopcao =  "C"        AND
                     tel_dtmvtolt <= 12/13/2011 THEN
                     tel_vldnotas[aux_contador] = 1.
                ELSE
                     tel_vldnotas[aux_contador] = 
                         DECIMAL(SUBSTRING(craptab.dstextab,1,12)).
            END.
            
    END. /*   Fim do DO TO   */

END PROCEDURE. 

/*............................................................................*/

PROCEDURE p_titulos:

    ASSIGN tel_qtremtit = 0
           tel_vlremtit = 0.

    FOR EACH craplot WHERE craplot.cdcooper = glb_cdcooper   AND 
                           craplot.dtmvtolt = tel_dtmvtolt   AND
                           craplot.tplotmov = 20             NO-LOCK:
                           
        IF   tel_cdagenci > 0   THEN
             IF   craplot.cdagenci <> tel_cdagenci   THEN
                  NEXT.
                  
        FOR EACH craptit WHERE craptit.cdcooper = glb_cdcooper       AND 
                               craptit.dtmvtolt = craplot.dtmvtolt   AND
                               craptit.cdagenci = craplot.cdagenci   AND
                               craptit.cdbccxlt = craplot.cdbccxlt   AND
                               craptit.nrdolote = craplot.nrdolote   NO-LOCK:
                               
            ASSIGN tel_qtremtit = tel_qtremtit + 1
                   tel_vlremtit = tel_vlremtit + craptit.vldpagto.
                               
        END.  /*  Fim do FOR EACH  --  Leitura dos titulos  */
                           
    END.  /*  Fim do FOR EACH  --  Leitura dos titulos  */

    /*  Titulos enviados para ASBACE de forma convencional  */
    
    FOR EACH craplcx WHERE craplcx.cdcooper = glb_cdcooper  AND 
                           craplcx.dtmvtolt = tel_dtmvtolt  AND
                           craplcx.cdhistor = 707           NO-LOCK:

        IF   tel_cdagenci > 0   THEN
             IF   craplcx.cdagenci <> tel_cdagenci   THEN
                  NEXT.
                                
        ASSIGN tel_vlremtit = tel_vlremtit + craplcx.vldocmto
               tel_qtremtit = tel_qtremtit + 1.

    END.  /*  Fim do FOR EACH -- Leitura do craplcx  */

END PROCEDURE.

/*............................................................................*/

PROCEDURE p_compel:

    FOR EACH craplot WHERE craplot.cdcooper = glb_cdcooper  AND 
                           craplot.dtmvtolt = tel_dtmvtolt  AND
                          (craplot.cdbccxlt = 11            OR
                           craplot.cdbccxlt = 500)          AND
                          (craplot.tplotmov = 1             OR
                           craplot.tplotmov = 23            OR
                           craplot.tplotmov = 29)           NO-LOCK:
 
        IF   tel_cdagenci > 0   THEN
             IF   craplot.cdagenci <> tel_cdagenci   THEN
                  NEXT.
        
        FOR EACH crapchd WHERE crapchd.cdcooper = glb_cdcooper       AND 
                               crapchd.dtmvtolt = craplot.dtmvtolt   AND
                               crapchd.cdagenci = craplot.cdagenci   AND
                               crapchd.cdbccxlt = craplot.cdbccxlt   AND
                               crapchd.nrdolote = craplot.nrdolote   AND
                               crapchd.inchqcop = 0
                               USE-INDEX crapchd3 NO-LOCK:
                               
            ASSIGN tel_vldvlbcb = tel_vldvlbcb + crapchd.vlcheque
                   tel_qtdvlbcb = tel_qtdvlbcb + 1.
                      
        END.  /*  Fim do FOR EACH  --  Leitura dos cheques acolhidos  */
    
    END.  /*  Fim do FOR EACH  --  Leitura dos lotes  */

    /*  Cheques enviados para ASBACE de forma convencional  */
    
    FOR EACH craplcx WHERE craplcx.cdcooper = glb_cdcooper  AND  
                           craplcx.dtmvtolt = tel_dtmvtolt  AND
                           craplcx.cdhistor = 712           NO-LOCK:
    
        IF   tel_cdagenci > 0   THEN
             IF   craplcx.cdagenci <> tel_cdagenci   THEN
                  NEXT.
                                
        ASSIGN tel_vldvlbcb = tel_vldvlbcb + craplcx.vldocmto
               tel_qtdvlbcb = tel_qtdvlbcb + 1.

    END.  /*  Fim do FOR EACH -- Leitura do craplcx  */
    
    /*  Cheques de custodia/desconto  */
    FOR EACH crapchd WHERE crapchd.cdcooper = glb_cdcooper   AND 
                           crapchd.dtmvtolt = tel_dtmvtolt   AND
                          (crapchd.cdbccxlt = 600            OR
                           crapchd.cdbccxlt = 700)           AND
                           crapchd.insitchq = 2              AND
                           crapchd.inchqcop = 0
                           USE-INDEX crapchd3 NO-LOCK:
                               
        IF   tel_cdagenci > 0   THEN
             IF   crapchd.cdagenci <> tel_cdagenci   THEN
                  NEXT.
        
        ASSIGN tel_vldvlbcb = tel_vldvlbcb + crapchd.vlcheque
               tel_qtdvlbcb = tel_qtdvlbcb + 1.
                      
    END.  /*  Fim do FOR EACH -- Leitura dos cheques em custodia/desconto  */

END PROCEDURE.

/*............................................................................*/

PROCEDURE pi_devolu_nr:

    DEF INPUT PARAM par_cddopcao  AS CHAR                         NO-UNDO.
    DEF INPUT PARAM par_cdcooper  AS INT                          NO-UNDO.
    DEF INPUT PARAM par_dtdparam  AS DATE                         NO-UNDO.


    CASE par_cddopcao:
    
        WHEN "F" THEN 
             DO:
                 FOR EACH craplcm WHERE craplcm.cdcooper = par_cdcooper   AND
                                        craplcm.dtmvtolt = par_dtdparam   AND
                                        CAN-DO("47,191,338,573",
                                               STRING(craplcm.cdhistor))
                                        NO-LOCK:
               
                     IF   tel_cdagenci <> 0 THEN 
                          DO:
                              FIND crapass WHERE 
                                   crapass.cdcooper = craplcm.cdcooper AND
                                   crapass.nrdconta = craplcm.nrdconta
                                   NO-LOCK NO-ERROR.
        
                              IF   NOT AVAILABLE crapass THEN
                                   NEXT.
        
                              IF   crapass.cdagenci <> tel_cdagenci THEN
                                   NEXT.
                          END.
               
                     CASE craplcm.cdbanchq:
                          WHEN 1   THEN tel_totdevnr[1] = tel_totdevnr[1] +
                                                          craplcm.vllanmto.
                          WHEN 756 THEN tel_totdevnr[2] = tel_totdevnr[2] +
                                                          craplcm.vllanmto.
                          WHEN 85  THEN tel_totdevnr[3] = tel_totdevnr[3] +
                                                          craplcm.vllanmto.
                     END CASE.
                 END.

             END. /* END do WHEN "F" */


        WHEN "L" THEN 
             DO:
                            /*** COMPE NOTURNA - DEVOLU ***/
                 FOR EACH craplcm WHERE craplcm.cdcooper = par_cdcooper    AND
                                        craplcm.dtmvtolt = aux_dtliqd-1    AND
                                        CAN-DO("47,191,338,573",
                                               STRING(craplcm.cdhistor))
                                        NO-LOCK:

                     IF   craplcm.cdbanchq = 85                 AND 
                          craplcm.dsidenti = "1"  /* noturna */ THEN
                          tel_vlchqnot = tel_vlchqnot + craplcm.vllanmto.
        
                 END.
        
                            /*** COMPE DIRUNA - DEVOLU ***/
                 FOR EACH craplcm WHERE craplcm.cdcooper = par_cdcooper    AND
                                        craplcm.dtmvtolt = par_dtdparam    AND
                                        CAN-DO("47,191,338,573",
                                                STRING(craplcm.cdhistor))
                                        NO-LOCK:
        
                     CASE craplcm.cdbanchq:

                          WHEN 85 THEN
                               IF   craplcm.dsidenti = "2"   /* diurna */ THEN
                                    tel_vlchqdia = tel_vlchqdia +
                                                   craplcm.vllanmto.
                     END CASE.
                 END.

             END. /* END do WHEN "L" */

    END CASE.


END PROCEDURE.

/*............................................................................*/

PROCEDURE pi_doc_nr:

    DEF INPUT PARAM par_cddopcao  AS CHAR                         NO-UNDO.
    DEF INPUT PARAM par_cdcooper  AS INT                          NO-UNDO.
    DEF INPUT PARAM par_dtdparam  AS DATE                         NO-UNDO.


    CASE par_cddopcao:
    
        WHEN "F" THEN 
             DO:
                 FOR EACH craptvl WHERE craptvl.cdcooper  = par_cdcooper AND 
                                        craptvl.dtmvtolt  = par_dtdparam AND 
                                        craptvl.cdagenci >= tel_cdagenci AND 
                                        craptvl.cdagenci <= aux_cdagefim AND 
                                        craptvl.tpdoctrf <> 3 /* DOC */
                                        NO-LOCK:
            
                     CASE craptvl.cdbcoenv:
                          WHEN 1   THEN tel_totdocnr[1] = tel_totdocnr[1] + 
                                                          craptvl.vldocrcb.
                          WHEN 756 THEN tel_totdocnr[2] = tel_totdocnr[2] + 
                                                          craptvl.vldocrcb.
                          WHEN 85  THEN tel_totdocnr[3] = tel_totdocnr[3] + 
                                                          craptvl.vldocrcb.
                          WHEN 0   THEN 
                               DO:
                                   RUN pi_identifica_bcoctl(
                                                     INPUT craptvl.cdcooper,
                                                     INPUT craptvl.cdagenci,
                                                     INPUT "D").
                                   tel_totdocnr[aux_idbcoctl] =
                                                 tel_totdocnr[aux_idbcoctl] +
                                                 craptvl.vldocrcb.
                               END.
                     END CASE.
                 END.

             END. /* END do WHEN "F" */

        WHEN "L" THEN 
             DO:
                 FOR EACH craptvl WHERE craptvl.cdcooper  = par_cdcooper AND
                                        craptvl.dtmvtolt  = aux_dtliqd-1 AND
                                        craptvl.cdagenci >= tel_cdagenci AND
                                        craptvl.cdagenci <= aux_cdagefim AND
                                        craptvl.tpdoctrf <> 3 /* DOC */  
                                        NO-LOCK:

                     IF   craptvl.vldocrcb >= aux_valorvlb THEN
                          tel_vlcobbil = tel_vlcobbil + craptvl.vldocrcb.
                     ELSE
                          tel_vlcobmlt = tel_vlcobmlt + craptvl.vldocrcb.

                 END.
             END.

    END CASE.

END PROCEDURE.

/*............................................................................*/

PROCEDURE pi_tedtec_nr:

    /* Verificar TED p/ estornos */

    FOR EACH craplcs WHERE craplcs.cdcooper  = crapcop.cdcooper AND 
                           craplcs.dtmvtolt  = tel_dtmvtolt     AND 
                           craplcs.cdagenci >= tel_cdagenci     AND 
                           craplcs.cdagenci <= aux_cdagefim     NO-LOCK:
 
        CASE craplcs.cdbccxlt:
             WHEN 1   THEN tel_tottednr[1] = tel_tottednr[1] + 
                                             craplcs.vllanmto.
             WHEN 756 THEN tel_tottednr[2] = tel_tottednr[2] + 
                                             craplcs.vllanmto.
        END CASE.

        IF   craplcs.cdhistor = 827   THEN /* TEC ENVIADA PELA NOSSA IF */
             ASSIGN tel_tottednr[3] = tel_tottednr[3] + craplcs.vllanmto.
        
     END.
        
    /* TED */
    FOR EACH craptvl WHERE craptvl.cdcooper  = crapcop.cdcooper AND 
                           craptvl.dtmvtolt  = tel_dtmvtolt     AND 
                           craptvl.cdagenci >= tel_cdagenci     AND 
                           craptvl.cdagenci <= aux_cdagefim     AND 
                           craptvl.tpdoctrf = 3 /* TED */       NO-LOCK:
    
        CASE craptvl.cdbcoenv:
             WHEN 1   THEN tel_tottednr[1] = tel_tottednr[1] +
                                             craptvl.vldocrcb.
             WHEN 756 THEN tel_tottednr[2] = tel_tottednr[2] +
                                             craptvl.vldocrcb.
             WHEN 85  THEN tel_tottednr[3] = tel_tottednr[3] +
                                             craptvl.vldocrcb.
        END CASE.
    END.
    
    /*** Desprezar TEC'S  e TED'S rejeitadas pela cabine da JD ***/
    FOR EACH craplcm WHERE craplcm.cdcooper = glb_cdcooper   AND
                           craplcm.dtmvtolt = tel_dtmvtolt   AND
                           craplcm.cdhistor = 887   NO-LOCK:
        ASSIGN tel_tottednr[3] = tel_tottednr[3] - craplcm.vllanmto.                 END.
    
END PROCEDURE.

/*............................................................................*/

PROCEDURE pi_titulos_nr:

    DEF INPUT PARAM par_cddopcao  AS CHAR                         NO-UNDO.
    DEF INPUT PARAM par_cdcooper  AS INT                          NO-UNDO.
    DEF INPUT PARAM par_dtdparam  AS DATE                         NO-UNDO.


    CASE par_cddopcao:
    
        WHEN "F" THEN 
             DO:
                 FOR EACH craptit WHERE craptit.cdcooper  = par_cdcooper  AND 
                                        craptit.dtdpagto  = par_dtdparam  AND 
                                        craptit.cdagenci >= tel_cdagenci  AND 
                                        craptit.cdagenci <= aux_cdagefim  AND 
                                        craptit.tpdocmto  = 20            AND
                                        craptit.intitcop  = 0             AND
                                        CAN-DO("2,4",STRING(craptit.insittit))
                                        NO-LOCK:
            
                     CASE craptit.cdbcoenv:
                          WHEN 1   THEN tel_tottitnr[1] = tel_tottitnr[1] + 
                                                          craptit.vldpagto.
                          WHEN 756 THEN tel_tottitnr[2] = tel_tottitnr[2] + 
                                                          craptit.vldpagto.
                          WHEN 85  THEN tel_tottitnr[3] = tel_tottitnr[3] + 
                                                          craptit.vldpagto.
                          WHEN 0   THEN 
                               DO:
                                   RUN pi_identifica_bcoctl(
                                                       INPUT craptit.cdcooper,
                                                       INPUT craptit.cdagenci,
                                                       INPUT "T").
                                   tel_tottitnr[aux_idbcoctl] =
                                              tel_tottitnr[aux_idbcoctl] +
                                              craptit.vldpagto.
                               END.
                     END CASE.
                 END.
             END. /* END do WHEN "F" */

        WHEN "L" THEN 
             DO:
                 FOR EACH craptit WHERE craptit.cdcooper  = par_cdcooper  AND 
                                        craptit.dtdpagto  = aux_dtliqd-1  AND 
                                        craptit.cdagenci >= tel_cdagenci  AND 
                                        craptit.cdagenci <= aux_cdagefim  AND 
                                        craptit.tpdocmto  = 20            AND
                                        craptit.intitcop  = 0             AND
                                        CAN-DO("2,4",STRING(craptit.insittit))
                                        NO-LOCK:

                     IF   craptit.vldpagto >= aux_valorvlb THEN
                          tel_vlcobbil = tel_vlcobbil + craptit.vldpagto.
                     ELSE
                          tel_vlcobmlt = tel_vlcobmlt + craptit.vldpagto.
                 END.

             END. /* END do WHEN "L" */

    END CASE.

END PROCEDURE.

/*............................................................................*/

PROCEDURE pi_cheques_nr:

    DEF INPUT PARAM par_cddopcao  AS CHAR                         NO-UNDO.
    DEF INPUT PARAM par_cdcooper  AS INT                          NO-UNDO.
    DEF INPUT PARAM par_dtdparam  AS DATE                         NO-UNDO.


    CASE par_cddopcao:
    
        WHEN "F" THEN 
             DO:
                 FOR EACH crapchd WHERE crapchd.cdcooper  = par_cdcooper  AND 
                                        crapchd.dtmvtolt  = par_dtdparam  AND 
                                        crapchd.cdagenci >= tel_cdagenci  AND 
                                        crapchd.cdagenci <= aux_cdagefim  AND 
                                        CAN-DO("0,2",
                                               STRING(crapchd.insitchq))  AND
                                        crapchd.inchqcop  = 0
                                        NO-LOCK:
            
                     CASE crapchd.cdbcoenv:
                          WHEN 1   THEN tel_totchqnr[1] = tel_totchqnr[1] + 
                                                          crapchd.vlcheque.
                          WHEN 756 THEN tel_totchqnr[2] = tel_totchqnr[2] + 
                                                          crapchd.vlcheque.
                          WHEN 85  THEN tel_totchqnr[3] = tel_totchqnr[3] + 
                                                          crapchd.vlcheque.
                          WHEN 0   THEN 
                               DO:
                                   RUN pi_identifica_bcoctl(
                                                     INPUT crapchd.cdcooper,
                                                     INPUT crapchd.cdagenci,
                                                     INPUT "C").
                                   tel_totchqnr[aux_idbcoctl] = 
                                                tel_totchqnr[aux_idbcoctl] + 
                                                crapchd.vlcheque.
                               END.
                     END CASE.
                 END.
             END. /* END do WHEN "F" */

        WHEN "L" THEN 
             DO:
                 FIND FIRST crapage WHERE 
                            crapage.cdcooper = crapcop.cdcooper AND
                            crapage.flgdsede = YES 
                            NO-LOCK NO-ERROR.

                 /* Se nao houver Coop como Sede, NEXT */
                 IF   NOT AVAILABLE crapage THEN 
                      NEXT.

                               /*** COMPE 16 (D - 1) ***/
                 FOR EACH crapchd WHERE crapchd.cdcooper  = par_cdcooper  AND 
                                        crapchd.dtmvtolt  = aux_dtliqd-1  AND 
                                        crapchd.cdagenci >= tel_cdagenci  AND 
                                        crapchd.cdagenci <= aux_cdagefim  AND 
                                        CAN-DO("0,2",
                                               STRING(crapchd.insitchq))  AND
                                        crapchd.inchqcop  = 0
                                        NO-LOCK:

                     /* Se for DIFERENTE => NACIONAL (DESCONSIDERA) */
                     IF   crapage.cdcomchq <> crapchd.cdcmpchq THEN 
                          NEXT.
                
                     IF   crapchd.vlcheque >= aux_valorchq THEN
                          tel_vlchqnot = tel_vlchqnot + crapchd.vlcheque.
                     ELSE
                          tel_vlchqdia = tel_vlchqdia + crapchd.vlcheque.
                 END.
        

                            /*** COMPE NACIONAL (D - 2) ***/
                 FOR EACH crapchd WHERE crapchd.cdcooper  = par_cdcooper  AND
                                        crapchd.dtmvtolt  = aux_dtliqd-2  AND
                                        crapchd.cdagenci >= tel_cdagenci  AND 
                                        crapchd.cdagenci <= aux_cdagefim  AND 
                                        CAN-DO("0,2",
                                               STRING(crapchd.insitchq))  AND
                                        crapchd.inchqcop  = 0
                                        NO-LOCK:
        

                     /* Se for IGUAL => COMPE16 (DESCONSIDERA) */
                     IF   crapage.cdcomchq = crapchd.cdcmpchq THEN 
                          NEXT.

                     IF   crapchd.vlcheque >= aux_valorchq THEN
                          tel_vlchqnot = tel_vlchqnot + crapchd.vlcheque.
                     ELSE
                          tel_vlchqdia = tel_vlchqdia + crapchd.vlcheque.
                 END.
             END.

    END CASE.

END PROCEDURE.

/*............................................................................*/

PROCEDURE pi_identifica_bcoctl:

  DEF INPUT PARAM par_cdcooper     AS INT                       NO-UNDO.
  DEF INPUT PARAM par_cdagenci     AS INT                       NO-UNDO.
  DEF INPUT PARAM par_idtblida     AS CHAR                      NO-UNDO.

  DEFINE VARIABLE aux_cdbcoenv     AS INTEGER                   NO-UNDO.

  ASSIGN aux_idbcoctl = 0
         aux_cdbcoenv = 0.     

  FIND FIRST crapage WHERE crapage.cdcooper = par_cdcooper AND 
                           crapage.cdagenci = par_cdagenci NO-LOCK NO-ERROR.

  IF  AVAILABLE crapage THEN 
      DO:
          CASE par_idtblida:
               WHEN "T" THEN aux_cdbcoenv = crapage.cdbantit.
               WHEN "D" THEN aux_cdbcoenv = crapage.cdbandoc.
               WHEN "C" THEN aux_cdbcoenv = crapage.cdbanchq.
          END CASE.

          CASE aux_cdbcoenv:
               WHEN 1   THEN aux_idbcoctl = 1.
               WHEN 756 THEN aux_idbcoctl = 2.
               WHEN 85  THEN aux_idbcoctl = 3.
          END CASE.
      END.

END PROCEDURE.

/*............................................................................*/

PROCEDURE pi_calcula_datas:

    DEF INPUT  PARAM par_dtdatela  AS DATE                          NO-UNDO.
    DEF OUTPUT PARAM par_flferiad  AS LOGICAL                       NO-UNDO.

    IF   CAN-DO("1,7",STRING(WEEKDAY(par_dtdatela)))              OR
         CAN-FIND(crapfer WHERE crapfer.cdcooper = glb_cdcooper   AND
                                crapfer.dtferiad = par_dtdatela)  THEN
         par_flferiad = TRUE.
    ELSE
         DO:    
             ASSIGN par_flferiad = FALSE
                    aux_dtliqd-1 = par_dtdatela - 1.
    
             DO WHILE TRUE:
    
                IF  CAN-DO("1,7",STRING(WEEKDAY(aux_dtliqd-1)))             OR
                    CAN-FIND(crapfer WHERE crapfer.cdcooper = glb_cdcooper  AND
                                           crapfer.dtferiad = aux_dtliqd-1) THEN
                    DO:
                        ASSIGN aux_dtliqd-1 = aux_dtliqd-1 - 1.
                        NEXT.
                    END.
    
                LEAVE.
    
             END.   /* Fim do DO WHILE TRUE */
    
    
             ASSIGN aux_dtliqd-2 = aux_dtliqd-1 - 1.
    
             DO WHILE TRUE:
    
                IF  CAN-DO("1,7",STRING(WEEKDAY(aux_dtliqd-2)))             OR
                    CAN-FIND(crapfer WHERE crapfer.cdcooper = glb_cdcooper  AND
                                           crapfer.dtferiad = aux_dtliqd-2) THEN
                    DO:
                        ASSIGN aux_dtliqd-2 = aux_dtliqd-2 - 1.
                        NEXT.
                    END.
       
                LEAVE.
    
             END.   /* Fim do DO WHILE TRUE */
         END.    

END PROCEDURE.

/* .......................................................................... */


PROCEDURE pi_transf_coop:

    DEF INPUT PARAM par_cdcooper  AS INT                          NO-UNDO.
    DEF INPUT PARAM par_dtdparam  AS DATE                         NO-UNDO.
    
    FOR EACH craplcx WHERE  craplcx.cdcooper = par_cdcooper   AND
                            craplcx.dtmvtolt = par_dtdparam   AND
                            craplcx.cdagenci >= tel_cdagenci  AND 
                            craplcx.cdagenci <= aux_cdagefim  AND 
                            craplcx.cdhistor = 1016 NO-LOCK:
     
        ASSIGN tel_tottrcop = tel_tottrcop + craplcx.vldocmto.
    
    END.                                      

END PROCEDURE.
