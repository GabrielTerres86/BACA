
/* ............................................................................

   Programa: Fontes/crps551.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Guilherme/Supero
   Data    : Janeiro/2010.                    Ultima atualizacao: 08/03/2018 

   Dados referentes ao programa:

   Frequencia: Diario (Batch).
   Objetivo  : Cria lancamentos e Estatistico das Tarifas - Compe/SPB
               Gera Relatorio 541.

   Observacoes: - Executado no processo diario. Cadeia Exclusiva.
                  Solicitacao => 1 Ordem => 13 (Somente processo da Cecred).

   Alteracoes: 20/04/2009 - Solicitado pela Karina o tratamento de novas
                            mensagens:
                            STR0005R2,STR0007R2,STR0025R2,STR0028R2,STR0034R2
                            STR0006R2 e PAG0105R2
                            PAG0107R2,PAG0106R2,PAG0121R2,PAG0124R2,PAG0134R2
                            STR0006,STR0025,STR0028,STR0034
                            PAG0105,PAG0121,PAG0124,PAG0134
                            (Guilherme).

               24/05/2010 - Corrigido para gerar tarifa somente em devolucoes
                            SUA REMESSA (Diego).

               04/06/2010 - Alteracao de historicos de devolucoes chq.
                            De Remetido para Recebido e Alinea (Ze).

               17/06/2010 - Tratamento para dtliquid (Ze).

               28/07/2010 - Retirada cobranca de TIB para as mensagens STR0010,
                            PAG0111, STR0010R2 e PAG0111R2 (Diego).

               02/08/2010 - Dividindo atualizacao no banco Generico, para nao
                            ocorrer o erro de -L (Ze).

               04/08/2010 - Incluir Tarifa do Cheque Roubado (Ze). 

               13/09/2010 - Acerto p/ gerar relatorio no diretorio rlnsv 
                            (Vitor)

               18/11/2010 - Considerar para tarifas as alineas 11,12,13,14,20,
                            20,21,22,23,24 e 25 (Ze).

               17/05/2011 - Inclusao de tratamento para Titulos SR
                            (Guilherme/Supero)

               25/05/2011 - Incluidos lancamentos com historicos 802,803,
                            884,884 ref. devolucoes recebidas e enviadas
                            (Diego).

               10/06/2011 - Usar historico 812 para tarifas cob reg, solicitado
                            pelo Rafael (Guilherme).

               13/07/2011 - Incluir no processamento dos titulos SR, o 
                            lancamento do credito do titulo (valor pago) na 
                            conta da cooperativa com código de histórico 989 
                            gncptit.cdtipreg = 4 (gerado no crps538)
                            (Guilherme).

               01/08/2011 - Incluir no processamentos dos titulos SR, o
                            lancamento da tarifa TIB dos titulos na conta
                            da cooperativa com histórico 812 (Rafael).

               02/08/2011 - Incluir glb_flgbatch p/ rodar no COMPEFORA (Ze).

               03/08/2011 - Retirado lancamento da tarifa TIB - hist 812
                            na central. Lancto deve ser realizado apenas
                            no ultimo dia util do mes (Rafael).

               19/09/2011 - Incluido tratamento para mensagens isentas da tarifa
                            TIB (Henrique).

               17/10/2011 - Tratamento mensagem PAG0143R2 solicitada pelo
                            Jonathan (Diego).

               27/10/2011 - Isentar tarifa das mensagens STR0025/STR0025R2 
                           (Diego).

               27/02/2012 - Retirar mensagens nao mais necessarias (Gabriel)

               09/03/2012 - Tratamento do Cheque Roubado (Ze).

               03/04/2012 - TIB DDA - Criacao tarifa DDA (Guilherme/Supero)
                            Desconsiderar TEC e DOC OBT nos DOCs SR para os
                            lancamentos na TIB (Ze).
                            
               04/04/2012 - Alteração do campo cdfinmsg para dsfinmsg
                            (David Kruger).
                            
               30/04/2012 - Ajuste no Cheque Roubado (Ze).             
               
               19/06/2012 - Isentar cobranca de TIB para PAG0143R2 enviada pelo
                            banco 104 com as finalidades 22,28,29,36 e 37 
                          - Tratar mensagens STR0039R2(sem TIB) e PAG0142R2
                            (Diego).
                  
               02/07/2012 - Substituido 'gncoper' por 'crapcop' (Tiago).             
               
               16/08/2012 - Ajuste na rotina de lancamento de tarifas 
                            para D+1 (Rafael).
                            
               31/08/2012 - Ajuste na rotina de lancamento de tarifas - as 
                            tarifas SPB são D+0 e as demais D+1. (Rafael)
                            
               03/09/2012 - Gerar lançamento da TIC no gntarcp (Ze).
               
               13/03/2013 - Retirar STR0028,STR0028R2,PAG0124,PAG0124R2.
                            (Gabriel).
                            
               08/05/2013 - Incluir ajustes referentes ao Projeto Tarifas -
                            Fase 2 (Lucas R.)
               
               24/07/2013 - Incluida a procedure pi_processa_vr_boleto para 
                            processar os registros da gnmvspb com STR0026 
                            (VR Boletos enviados ou pagos) e STR0026R2 
                            (VR Boletos recebidos) (Carlos)
                            
               11/10/2013 - Incluido parametro cdprogra para as procedures
                            da b1wgen0153 que carregam dados de tarifa(Tiago).
                            
               21/10/2013 - Tratamento campo gnmvspb.dsfinmsg (Diego).
               
               13/01/2014 - Alteracao referente a integracao Progress X 
                            Dataserver Oracle 
                            Inclusao do VALIDATE ( Andre Euzebio / SUPERO) 
                            
               05/02/2014 - Alteração para processar somente para as
                            cooperativas ativas (Lucas).
                            
               27/02/2014 - Creditar conta da singular ref. a titulos da
                            sua remessa, mesmo quando integrados com erro
                            (gncptit.cdtipreg = 3). (Rafael).
               
               03/04/2014 - Incluida procedure e chamda da pi_processa_dev_doc
                            projeto automatiza compe (Tiago/Aline).             
                            
               19/05/2014 - Retirado Return NOK para nao parar o processo
                            (Tiago/Rodrigo).
                            
               04/08/2014 - Usando variavel de data aux_dtleiarq ao inves de
                            glb_dtmvtoan para chamada da procedure
                            pi_processa_dev_doc (Tiago/Aline).              
                            
               07/04/2015 - Desviado log do proc_batch para o proc_message
                            (SD273364 - Tiago).
                            
               09/07/2015 - Incluida a procedure pi_processa_portabilidade
                            para processar os registros da gnmvspb com STR0047.
                            (Jaison/Diego - SD: 290027)
                            
               02/10/2015 - Criado procedures pi_processa_tit_sua_epr e 
                            pi_processa_tit_sua_epr_dda. (Reinert)

			   14/12/2015 - Ajustes referente ao projeto estado de crise. 
			                Utilizar a gnmvspb.dtmvtolt ao inves da 
							gnmvspb.dtmensag (Andrino-RKAM)
                            
               24/03/2017 - Lancar debito de devolucao de titulos 085
                            na conta da filiada na central.
                            (Projeto 340 - Fase SILOC - Rafael).


               17/11/2016 - Na procedure pi_processa_ted_tec a mensagem 
                            STR0008 originada pelo sistema MATERA somarizar
                            valor e lancar debito na conta da filiada.
                            (Jaison/Diego - SD: 556800)

               21/06/2017 - removida leitura da craptab e campos qtd_lancainf e 
                            vlr_lantotin na procedure pi_processa_chq_sua. 
                            PRJ367 - Compe Sessao Unica (Lombardi)

			   08/03/2018 - Removida separacao de cheques inferiore e superiores
			                no processamento pi_processa_chq_nossa (Diego).
                            
............................................................................. */

DEF STREAM str_1.   /* Relatorio */

{ includes/var_batch.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/var_oracle.i }

DEF        VAR rel_nmempres AS CHAR    FORMAT "x(15)"                NO-UNDO.
DEF        VAR rel_nmrelato AS CHAR    FORMAT "x(40)" EXTENT 5       NO-UNDO.
DEF        VAR rel_nrmodulo AS INT     FORMAT "9"                    NO-UNDO.
DEF        VAR rel_nmmodulo AS CHAR    FORMAT "x(15)" EXTENT 5
                               INIT ["DEP. A VISTA   ","CAPITAL        ",
                                     "EMPRESTIMOS    ","DIGITACAO      ",
                                     "GENERICO       "]              NO-UNDO.
                                     
DEF        VAR aux_nmarqimp AS CHAR                                  NO-UNDO.
DEF        VAR aux_nmarquiv AS CHAR                                  NO-UNDO.
DEF        VAR aux_cdagenci AS INT     INIT 1                        NO-UNDO.
DEF        VAR aux_cdbccxlt AS INT                                   NO-UNDO.
DEF        VAR aux_tplotmov AS INT     INIT 1                        NO-UNDO.
DEF        VAR aux_nrdolote AS INT     INIT 7101                     NO-UNDO.
DEF        VAR aux_nrdocmto AS INT                                   NO-UNDO.
DEF        VAR aux_vllandeb AS CHAR                                  NO-UNDO.
DEF        VAR aux_vllancre AS CHAR                                  NO-UNDO.
DEF        VAR aux_tplanmto AS CHAR                                  NO-UNDO.
DEF        VAR aux_temassoc AS LOG                                   NO-UNDO.
DEF        VAR aux_flgfirst AS LOGI     INIT TRUE                    NO-UNDO.
DEF        VAR aux_dtleiarq AS DATE                                  NO-UNDO.

DEF        VAR qtd_lancasup AS INT                                   NO-UNDO.
DEF        VAR qtd_lancainf AS INT                                   NO-UNDO.
DEF        VAR qtd_chqrouba AS INT                                   NO-UNDO.

DEF        VAR tot_vllandeb AS DEC                                   NO-UNDO.
DEF        VAR tot_vllancre AS DEC                                   NO-UNDO.
DEF        VAR tot_vllanmto AS DEC                                   NO-UNDO.

DEF        VAR vlr_lantotin AS DEC                                   NO-UNDO.
DEF        VAR vlr_lantotsu AS DEC                                   NO-UNDO.

DEF        VAR sub_vllandeb AS DEC                                   NO-UNDO.
DEF        VAR sub_vllancre AS DEC                                   NO-UNDO.

DEF        VAR h-b1wgen0153 AS HANDLE                                NO-UNDO.
DEF        VAR aux_cdhistor AS INTE                                  NO-UNDO.
DEF        VAR aux_cdhisest AS INTE                                  NO-UNDO.
DEF        VAR aux_dtdivulg AS DATE                                  NO-UNDO.
DEF        VAR aux_dtvigenc AS DATE                                  NO-UNDO.
DEF        VAR aux_cdtarifa AS CHAR                                  NO-UNDO.
DEF        VAR par_dscritic LIKE crapcri.dscritic                    NO-UNDO.
DEF        VAR aux_vltaripj AS DECIMAL FORMAT "zz9.99"               NO-UNDO.
DEF        VAR aux_vltaripf AS DECIMAL FORMAT "zz9.99"               NO-UNDO.
DEF        VAR aux_cdhistpj AS INTE                                  NO-UNDO.
DEF        VAR aux_cdhistpf AS INTE                                  NO-UNDO.
DEF        VAR aux_cdfvlcpf AS INTE                                  NO-UNDO.
DEF        VAR aux_cdfvlcpj AS INTE                                  NO-UNDO.

DEF BUFFER bgncpchq FOR gncpchq.
DEF BUFFER bgncpdev FOR gncpdev.
DEF BUFFER bgncptit FOR gncptit.
DEF BUFFER bgncpdoc FOR gncpdoc.
DEF BUFFER bgnmvspb FOR gnmvspb.
DEF BUFFER bgncpicf FOR gncpicf.
DEF BUFFER crabcop  FOR crapcop.

DEF TEMP-TABLE w-acumular                                            NO-UNDO
    FIELD cdlanmto  AS INTEGER
    FIELD nrdconta  AS INTEGER
    FIELD tplanmto  AS CHAR     /* Debito, Credito */
    FIELD nmprimtl  AS CHAR
    FIELD dshistor  AS CHAR
    FIELD vllanmto  AS DEC
    FIELD vllandeb  AS DEC
    FIELD vllancre  AS DEC
    INDEX w-acumular1 AS PRIMARY cdlanmto.

DEF TEMP-TABLE tt-agenciccf NO-UNDO
    FIELD cdagenci LIKE crapass.cdagenci.

FORM SKIP(1)
     "LANCAMENTOS INTEGRADOS EM: " glb_dtmvtolt FORMAT "99/99/9999"
     SKIP(2)
     "CONTA/DV"                         AT 03
     "NOME"                             AT 13
     "HISTORICO"                        AT 45
     "DOCUMENTO"                        AT 64
     "VALOR DEBITO"                     AT 81
     "VALOR CREDITO"                    AT 100 SKIP
     "----------"                       AT 01
     "------------------------------"   AT 13
     "-----------------"                AT 45
     "---------"                        AT 64
     "------------------"               AT 75
     "------------------"               AT 95  
     WITH NO-BOX NO-LABELS WIDTH 132 FRAME f_cab_integrados.

FORM w-acumular.nrdconta   FORMAT "zzzz,zzz,9"  
     w-acumular.nmprimtl   FORMAT "x(30)"       AT 13
     w-acumular.dshistor   FORMAT "x(17)"       AT 45
     w-acumular.cdlanmto   FORMAT "zzzz,zzz9"   AT 64
     aux_vllandeb          FORMAT "x(18)"       AT 75
     aux_vllancre          FORMAT "x(18)"       AT 95
     WITH NO-BOX NO-LABELS DOWN WIDTH 132 FRAME f_integrados.
     
FORM "------------------"                          AT 75
     "------------------"                          AT 95 SKIP
     sub_vllandeb   FORMAT "zzz,zzz,zzz,zz9.99"    AT 75
     sub_vllancre   FORMAT "zzz,zzz,zzz,zz9.99"    AT 95 SKIP(1)
     WITH NO-BOX NO-LABELS DOWN WIDTH 132 FRAME f_total_lancamento.

FORM "TOTAL GERAL"                                 AT 59
     tot_vllandeb   FORMAT "zzz,zzz,zzz,zz9.99"    AT 75
     tot_vllancre   FORMAT "zzz,zzz,zzz,zz9.99"    AT 95 SKIP(1)
     WITH NO-BOX NO-LABELS DOWN WIDTH 132 FRAME f_totalgeral_lancamento.

ASSIGN glb_cdprogra = "crps551"
       glb_flgbatch = false.
       
RUN fontes/iniprg.p.

IF   glb_cdcritic > 0 THEN
     RETURN.
          
/* Busca dados da cooperativa */
FIND crabcop WHERE crabcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.

IF   NOT AVAILABLE crabcop THEN
     DO:
         glb_cdcritic = 651.
         RUN fontes/critic.p.
         UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                            glb_cdprogra + "' --> '" + glb_dscritic +
                            " >> log/proc_batch.log").
         RETURN.
     END.
     
ASSIGN aux_cdbccxlt = crabcop.cdbcoctl.


/*  Utilizado para data de referencia na CRAPLCM  */

IF   glb_nmtelant = "COMPEFORA"   THEN
     ASSIGN aux_dtleiarq = glb_dtmvtoan.
ELSE
     ASSIGN aux_dtleiarq = glb_dtmvtolt.

TRANS_1:
DO TRANSACTION ON ERROR UNDO TRANS_1, RETURN:

    /* Busca valores das tarifas */
    FIND FIRST gncdtrf NO-LOCK NO-ERROR.

    /* Processa todas cooperativas ativas, exceto 3 [Cecred] */
    FOR EACH crapcop  WHERE crapcop.cdcooper <> 3 AND 
                            crapcop.flgativo      NO-LOCK:
        
        FIND crapass WHERE crapass.cdcooper = glb_cdcooper      AND
                           crapass.nrdconta = crapcop.nrctactl
                           NO-LOCK NO-ERROR.

        IF  NOT AVAIL crapass  THEN
            aux_temassoc = FALSE.
        ELSE
            aux_temassoc = TRUE.
    
        /* Leitura de CHEQUES */
        RUN pi_processa_chq_nossa (INPUT aux_temassoc).
        RUN pi_processa_chq_sua   (INPUT aux_temassoc).

        /* Leitura de Titulos */
        RUN pi_processa_tit_nossa (INPUT aux_temassoc).
        RUN pi_processa_tit_sua   (INPUT aux_temassoc).
        RUN pi_processa_tit_sua_epr(INPUT aux_temassoc).

        /* Leitura de Doctos  */
        RUN pi_processa_doc_nossa (INPUT aux_temassoc).
        RUN pi_processa_doc_sua   (INPUT aux_temassoc).

        /* Leitura de DDAs */
        RUN pi_processa_tit_nossa_dda (INPUT aux_temassoc).
        RUN pi_processa_tit_sua_dda   (INPUT aux_temassoc).
        RUN pi_processa_tit_sua_epr_dda(INPUT aux_temassoc).

        /* Leitura de DEVOLUCOES */

        /* Sua remessa - Dev boletos 085 */
        RUN pi_processa_tit_dev_sua.

        /* Sua Remessa - gera tarifa ref. devolucoes */
        RUN pi_processa_dev_sua (INPUT aux_temassoc).

        RUN pi_processa_dev_nossa (INPUT aux_temassoc).

        /* Leitura de ICF */
        RUN pi_processa_icf       (INPUT aux_temassoc).

        /* Leitura TED/TEC */
        RUN pi_processa_ted_tec   (INPUT aux_temassoc).

        /* Leitura CCF */
        RUN pi_processa_ccf.

        /* Lanca os totais de vr boletos pagos e recebidos no dia para a cooperativa*/
        RUN pi_processa_vr_boleto.

        /* Lanca valor da soma dos lancamentos da gncpddc*/
        RUN pi_processa_dev_doc(INPUT crapcop.cdcooper, 
                                INPUT glb_dtmvtoan).

        IF  RETURN-VALUE = "NOK"  THEN
            UNDO TRANS_1, RETURN.

        /* Leitura TIC */
        RUN pi_processa_tic(INPUT crapcop.cdcooper).
    END.

    /* Processa os lancamentos correspondente a pagamento de portabilidade */
    RUN pi_processa_portabilidade.

END. /* DO TRANSACTION */

UNIX SILENT VALUE("echo " + STRING(TODAY,"99/99/9999") + " - "
                  + STRING(TIME,"HH:MM:SS")  +  " - "  + glb_cdprogra 
                  + "' --> '" + "Atualizando registros nas tabelas genericas... "
                  + " >> log/proc_message.log").

RUN atualiza_registros.

UNIX SILENT VALUE("echo " + STRING(TODAY,"99/99/9999") + " - "
                  + STRING(TIME,"HH:MM:SS") + " - " + glb_cdprogra 
                  + "' --> '" + "Gerando relatorio... "
                  + " >> log/proc_message.log").


/* GERAR RELATORIO */

ASSIGN aux_nmarqimp    = "rl/crrl541.lst"
       glb_cdrelato[2] = 541
       glb_cdempres    = 11.
       
{ includes/cabrel132_1.i }

OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGED PAGE-SIZE 84.

VIEW STREAM str_1 FRAME f_cabrel132_1.

DISPLAY STREAM str_1 glb_dtmvtolt  WITH FRAME f_cab_integrados.

ASSIGN tot_vllancre = 0
       tot_vllandeb = 0.

FOR EACH w-acumular BREAK BY w-acumular.nrdconta
                          BY w-acumular.cdlanmto:

     IF   w-acumular.vllandeb > 0 THEN
          ASSIGN aux_vllandeb = STRING(w-acumular.vllandeb,
                                           "zzz,zzz,zzz,zz9.99").
     ELSE
          ASSIGN aux_vllandeb = "".

     IF   w-acumular.vllancre > 0 THEN
          ASSIGN aux_vllancre = STRING(w-acumular.vllancre,
                                           "zzz,zzz,zzz,zz9.99").
     ELSE
          aux_vllancre = "".
                                           
     DISPLAY STREAM str_1 w-acumular.nrdconta  w-acumular.nmprimtl
                          w-acumular.dshistor  w-acumular.cdlanmto
                          aux_vllandeb         aux_vllancre
                          WITH FRAME f_integrados.
     
     DOWN STREAM str_1 WITH FRAME f_integrados.
               
     IF   w-acumular.tplanmto = "D" THEN
          ASSIGN sub_vllandeb = sub_vllandeb + w-acumular.vllanmto
                 tot_vllandeb = tot_vllandeb + w-acumular.vllanmto.
     ELSE            
          ASSIGN sub_vllancre = sub_vllancre + w-acumular.vllanmto
                 tot_vllancre = tot_vllancre + w-acumular.vllanmto.


     IF   LAST-OF(w-acumular.nrdconta) THEN
          DO:
              DISPLAY STREAM str_1 sub_vllandeb sub_vllancre
                  WITH FRAME f_total_lancamento.

              ASSIGN sub_vllancre = 0
                     sub_vllandeb = 0.
          END.

END. /* END FOREACH */

DISPLAY STREAM str_1 tot_vllandeb tot_vllancre 
        WITH FRAME f_totalgeral_lancamento.

OUTPUT STREAM str_1 CLOSE.

/*  Salvar copia relatorio para "/rlnsv"  */
IF   glb_nmtelant = "COMPEFORA"   THEN
     UNIX SILENT VALUE("cp " + aux_nmarqimp + " rlnsv").
                            
ASSIGN glb_nrcopias = 1
       glb_nmformul = "132col"
       glb_nmarqimp = aux_nmarqimp.
              
RUN fontes/imprim.p.

RUN fontes/fimprg.p.

/*............................................................................*/
PROCEDURE pi_processa_chq_nossa:
/* NOSSA REMESSA  */
   DEF INPUT PARAM par_temassoc AS LOG                   NO-UNDO.

   /* Zerar variaveis */
   ASSIGN vlr_lantotsu = 0.

   /* Acumular variaveis */
   FOR EACH gncpchq WHERE gncpchq.cdcooper = crapcop.cdcooper AND
                          gncpchq.dtliquid = glb_dtmvtolt     AND
                          gncpchq.cdtipreg = 2                AND
                          gncpchq.flgpcctl = FALSE            NO-LOCK
                          BREAK BY gncpchq.cdagenci:

       IF   FIRST-OF(gncpchq.cdagenci) THEN
            ASSIGN qtd_lancasup = 0       
                   qtd_chqrouba = 0.

       IF   par_temassoc THEN 
            DO:
                /*   TARIFAS - Tratamento do Cheque Roubado  */
                IF   CAN-DO("75,76,77,90,94,95",string(gncpchq.cdtipdoc)) THEN
                     ASSIGN qtd_chqrouba = qtd_chqrouba + 1.
                ELSE 
                     DO: /* Cheque Normal */
                         ASSIGN qtd_lancasup = qtd_lancasup + 1.
                     END.
                     
                ASSIGN vlr_lantotsu = vlr_lantotsu + gncpchq.vlcheque.
            END.
       ELSE 
            DO:
                FIND bgncpchq WHERE RECID(bgncpchq) = RECID(gncpchq) 
                                    EXCLUSIVE-LOCK NO-ERROR.
                IF   AVAILABLE bgncpchq THEN 
                     DO:
                         ASSIGN  bgncpchq.cdcrictl = 9. 
                         RELEASE bgncpchq.
                     END.
            END.

       IF   LAST-OF(gncpchq.cdagenci) THEN 
            DO:
                IF   qtd_lancasup <> 0  THEN
                     RUN pi_cria_tab_tarifas
                               (INPUT gncpchq.cdagenci,
                                INPUT 2, /* 02 - Cheque Superior N R */
                                INPUT qtd_lancasup,
                                INPUT qtd_lancasup * gncdtrf.vltrfchq,
                                INPUT 0,
                                INPUT gncdtrf.vltrfchq).

                IF   qtd_chqrouba <> 0  THEN
                     RUN pi_cria_tab_tarifas
                               (INPUT gncpchq.cdagenci,
                                INPUT 11, /* 11 - Cheque Roubado N R */
                                INPUT qtd_chqrouba,
                                INPUT qtd_chqrouba * gncdtrf.vlchqrob,
                                INPUT 0,
                                INPUT gncdtrf.vlchqrob).

            END. /* END do LAST-OF */
   END. /* END do FOREACH */

   /* Criando LCM para valor SUP */

   IF   vlr_lantotsu <> 0  THEN
        RUN pi_cria_craplcm(INPUT vlr_lantotsu,
                            INPUT 791).
   
END PROCEDURE.

/*............................................................................*/

PROCEDURE pi_processa_chq_sua:

   /* SUA REMESSA */
   DEF INPUT PARAM par_temassoc AS LOG                   NO-UNDO.

   /* Zerar variaveis */
   ASSIGN vlr_lantotsu = 0.

   /* Acumular variaveis */
   FOR EACH gncpchq WHERE gncpchq.cdcooper = crapcop.cdcooper  AND
                          gncpchq.dtliquid = glb_dtmvtolt      AND
                         (gncpchq.cdtipreg = 4                 OR
                          gncpchq.cdtipreg = 3)                AND
                          gncpchq.flgpcctl = FALSE             NO-LOCK
                          BREAK BY gncpchq.cdagenci:

       IF   FIRST-OF(gncpchq.cdagenci) THEN
            ASSIGN qtd_lancasup = 0
                   qtd_chqrouba = 0.

       IF   par_temassoc THEN 
            DO:
               /*   TARIFA - Tratamento do Cheque Roubado  */
               IF   CAN-DO("75,76,77,90,94,95",string(gncpchq.cdtipdoc)) THEN
                    ASSIGN qtd_chqrouba = qtd_chqrouba + 1.
               ELSE 
                    DO: /* CHQ NORMAL */
                       ASSIGN qtd_lancasup = qtd_lancasup + 1.
                    END.
                    
               ASSIGN vlr_lantotsu = vlr_lantotsu + gncpchq.vlcheque.
            END.
       ELSE 
            DO:
                FIND bgncpchq WHERE RECID(bgncpchq) = RECID(gncpchq) 
                                    EXCLUSIVE-LOCK NO-ERROR.
                IF   AVAILABLE bgncpchq THEN 
                     DO:
                         ASSIGN  bgncpchq.cdcrictl = 9.
                         RELEASE bgncpchq.
                      END.
            END.
            IF   LAST-OF(gncpchq.cdagenci) THEN 
                 DO:
                     IF   qtd_lancasup <> 0  THEN
                          RUN pi_cria_tab_tarifas 
                                    (INPUT gncpchq.cdagenci,
                                     INPUT 7, /* 07 - Cheque Superior S R*/
                                     INPUT qtd_lancasup,
                                     INPUT qtd_lancasup * gncdtrf.vltrfchq,
                                     INPUT 0,
                                     INPUT gncdtrf.vltrfchq).

                     IF   qtd_chqrouba <> 0  THEN
                          RUN pi_cria_tab_tarifas 
                                    (INPUT gncpchq.cdagenci,
                                     INPUT 12, /* 12 - Cheque Roubado S R*/
                                     INPUT qtd_chqrouba,
                                     INPUT qtd_chqrouba * gncdtrf.vlchqrob,
                                     INPUT 0,
                                         INPUT gncdtrf.vlchqrob).
       END. /* END do LAST-OF */
   END. /* END do FOREACH */

   IF   vlr_lantotsu <> 0  THEN
        /* Criando LCM para valor SUP */
        RUN pi_cria_craplcm (INPUT vlr_lantotsu,
                             INPUT 784).

END PROCEDURE.

/*............................................................................*/

PROCEDURE pi_processa_tit_nossa:
/* NOSSA REMESSA */
   DEF INPUT PARAM par_temassoc AS LOG                   NO-UNDO.

   DEF         VAR aux_valorvlb AS DEC                   NO-UNDO.
   /* Variaveis: Lancamentos  Sup  */
   DEF         VAR qtd_totenvsu AS INT                   NO-UNDO.
   DEF         VAR qtd_totdevsu AS INT                   NO-UNDO.
   /* Variaveis: Lancamentos  Inf  */
   DEF         VAR qtd_totenvin AS INT                   NO-UNDO.
   DEF         VAR qtd_totdevin AS INT                   NO-UNDO.
   /* Variaveis: Totais gerais Envio - Dev [Inf/Sup]  */
   DEF         VAR vlr_totenvio AS DEC                   NO-UNDO.
   DEF         VAR vlr_totdevol AS DEC                   NO-UNDO.
   
   /* BUSCAR VALORESVLB DOS TITULOS */ 
   FIND craptab WHERE craptab.cdcooper = glb_cdcooper    AND 
                      craptab.nmsistem = "CRED"          AND 
                      craptab.tptabela = "GENERI"        AND 
                      craptab.cdempres = 00              AND 
                      craptab.cdacesso = "VALORESVLB"    AND 
                      craptab.tpregist = 0               NO-LOCK NO-ERROR.

   IF   AVAILABLE craptab   THEN
        aux_valorvlb = DEC(ENTRY(1,craptab.dstextab,";")).
   ELSE
        aux_valorvlb = 5000.
      
   /* Zerar variaveis - Gerais */
   ASSIGN vlr_totenvio = 0
          vlr_totdevol = 0.

   /* Acumular variaveis */
   FOR EACH gncptit WHERE gncptit.cdcooper = crapcop.cdcooper  AND
                          gncptit.dtliquid = glb_dtmvtolt      AND
                          gncptit.cdtipreg = 2                 AND
                          gncptit.flgpcctl = FALSE             AND
                          gncptit.flgpgdda = FALSE             NO-LOCK
                          BREAK BY gncptit.cdagenci:

       IF   FIRST-OF(gncptit.cdagenci) THEN
            /* Zerar variaveis - Por cdAgenci */
            ASSIGN qtd_totenvsu = 0
                   qtd_totdevsu = 0
                   qtd_totenvin = 0
                   qtd_totdevin = 0.
    
       IF   par_temassoc THEN
            IF   gncptit.cdmotdev = 0 THEN 
                 DO:            /* ENVIO TITULOS */
                     IF   gncptit.vldpagto > aux_valorvlb THEN
                          ASSIGN qtd_totenvsu = qtd_totenvsu + 1
                                 vlr_totenvio = vlr_totenvio + gncptit.vldpagto.
                     ELSE
                          ASSIGN qtd_totenvin = qtd_totenvin + 1
                                 vlr_totenvio = vlr_totenvio + gncptit.vldpagto.
                 END. /* FIM - IF gncptit.cdmotdev = 0 */
            ELSE 
                 DO:
                    IF   gncptit.vldpagto > aux_valorvlb THEN /* DEV.TITULOS */
                         ASSIGN qtd_totdevsu = qtd_totdevsu + 1
                                vlr_totdevol = vlr_totdevol + gncptit.vldpagto.
                    ELSE
                         ASSIGN qtd_totdevin = qtd_totdevin + 1
                                vlr_totdevol = vlr_totdevol + gncptit.vldpagto.
                 END. /* FIM - ELSE do gncptit.cdmotdev = 0 */
       ELSE 
            DO:
                FIND bgncptit WHERE RECID(bgncptit) = RECID(gncptit) 
                                    EXCLUSIVE-LOCK NO-ERROR.
                IF   AVAILABLE bgncptit   THEN 
                     DO:
                         /* Critica Associado nao Existe */
                         ASSIGN  bgncptit.cdcrictl = 9.
                         RELEASE bgncptit.
                     END.
            END.

       IF   LAST-OF(gncptit.cdagenci) THEN 
            DO:
                IF   qtd_totenvin <> 0  THEN
                     RUN pi_cria_tab_tarifas(INPUT gncptit.cdagenci,
                                             INPUT 3, /* 03 - Titulo NR   */
                                             INPUT qtd_totenvin,
                                             INPUT qtd_totenvin *
                                                   gncdtrf.vltrftit,
                                             INPUT 0,
                                             INPUT gncdtrf.vltrftit).
        
                IF   qtd_totenvsu <> 0  THEN
                     RUN pi_cria_tab_tarifas(INPUT gncptit.cdagenci,
                                             INPUT 4, /* 04 - Titulo VLB NR */
                                             INPUT qtd_totenvsu,
                                             INPUT qtd_totenvsu *
                                                   gncdtrf.vltrftit,
                                             INPUT 0,
                                             INPUT gncdtrf.vltrftit).

           END. /* END do LAST-OF */
   END. /* END do FOREACH */

   IF   vlr_totenvio <> 0  THEN
        /* Criando LCM para valor somado - Titulo Nossa Remessa */
        RUN pi_cria_craplcm (INPUT vlr_totenvio,
                             INPUT 782).

   IF   vlr_totdevol <> 0  THEN
        /* Criando LCM para valor somado - Devolucao Titulo */
        RUN pi_cria_craplcm (INPUT vlr_totdevol,
                             INPUT 793).

END PROCEDURE.

/*............................................................................*/

PROCEDURE pi_processa_tit_sua:
/* SUA REMESSA */
   DEF INPUT PARAM par_temassoc AS LOG                   NO-UNDO.

   DEF         VAR aux_valorvlb AS DEC                   NO-UNDO.
   /* Variaveis: Lancamentos  Sup  */
   DEF         VAR qtd_totenvsu AS INT                   NO-UNDO.
   DEF         VAR qtd_totdevsu AS INT                   NO-UNDO.
   /* Variaveis: Lancamentos  Inf  */
   DEF         VAR qtd_totenvin AS INT                   NO-UNDO.
   DEF         VAR qtd_totdevin AS INT                   NO-UNDO.
   /* Variaveis: Totais gerais Envio - Dev [Inf/Sup]  */
   DEF         VAR vlr_totenvio AS DEC                   NO-UNDO.
   DEF         VAR vlr_totdevol AS DEC                   NO-UNDO.
   
   /* Variaveis: Totais gerais por Credito p/ cooperativa */
   DEF         VAR vlr_totcredi AS DEC                   NO-UNDO.

   /* BUSCAR VALORESVLB DOS TITULOS */ 
   FIND craptab WHERE craptab.cdcooper = glb_cdcooper    AND 
                      craptab.nmsistem = "CRED"          AND 
                      craptab.tptabela = "GENERI"        AND 
                      craptab.cdempres = 00              AND 
                      craptab.cdacesso = "VALORESVLB"    AND 
                      craptab.tpregist = 0               NO-LOCK NO-ERROR.

   IF   AVAILABLE craptab   THEN
        aux_valorvlb = DEC(ENTRY(1,craptab.dstextab,";")).
   ELSE
        aux_valorvlb = 5000.
      
   /* Zerar variaveis - Gerais */
   ASSIGN vlr_totenvio = 0
          vlr_totdevol = 0.

   /* Acumular variaveis */
   FOR EACH gncptit WHERE gncptit.cdcooper = crapcop.cdcooper  AND
                          gncptit.dtliquid = glb_dtmvtolt      AND
                         (gncptit.cdtipreg = 4                 OR
                          gncptit.cdtipreg = 3)                AND
                          gncptit.flgpcctl = FALSE             AND
                          gncptit.flgpgdda = FALSE             NO-LOCK
                          BREAK BY gncptit.cdagenci:

       IF   FIRST-OF(gncptit.cdagenci) THEN
            /* Zerar variaveis - Por cdAgenci */
            ASSIGN qtd_totenvsu = 0
                   qtd_totdevsu = 0
                   qtd_totenvin = 0
                   qtd_totdevin = 0.

       IF   par_temassoc THEN
       DO:
            ASSIGN vlr_totcredi = vlr_totcredi + gncptit.vldpagto.

            IF   gncptit.cdmotdev = 0 THEN
                 DO:            /* ENVIO TITULOS */
                     IF   gncptit.vldpagto > aux_valorvlb THEN
                          ASSIGN qtd_totenvsu = qtd_totenvsu + 1
                                 vlr_totenvio = vlr_totenvio + gncptit.vldpagto.
                     ELSE
                          ASSIGN qtd_totenvin = qtd_totenvin + 1
                                 vlr_totenvio = vlr_totenvio + gncptit.vldpagto.
                 END. /* FIM - IF gncptit.cdmotdev = 0 */
            ELSE
                 DO:
                    IF   gncptit.vldpagto > aux_valorvlb THEN /* DEV.TITULOS */
                         ASSIGN qtd_totdevsu = qtd_totdevsu + 1
                                vlr_totdevol = vlr_totdevol + gncptit.vldpagto.
                    ELSE
                         ASSIGN qtd_totdevin = qtd_totdevin + 1
                                vlr_totdevol = vlr_totdevol + gncptit.vldpagto.
                 END. /* FIM - ELSE do gncptit.cdmotdev = 0 */
       END.
       ELSE
            DO:
                FIND bgncptit WHERE RECID(bgncptit) = RECID(gncptit)
                                    EXCLUSIVE-LOCK NO-ERROR.
                IF   AVAILABLE bgncptit   THEN
                     DO:
                         /* Critica Associado nao Existe */
                         ASSIGN  bgncptit.cdcrictl = 9.
                         RELEASE bgncptit.
                     END.
            END.

       IF   LAST-OF(gncptit.cdagenci) THEN
            DO:
                IF   qtd_totenvin <> 0  THEN
                     RUN pi_cria_tab_tarifas(INPUT gncptit.cdagenci,
                                             INPUT 19, /* 19 - Titulo SR   */
                                             INPUT qtd_totenvin,
                                             INPUT qtd_totenvin *
                                                   gncdtrf.vltrftit,
                                             INPUT 0,
                                             INPUT gncdtrf.vltrftit).

                IF   qtd_totenvsu <> 0  THEN
                     RUN pi_cria_tab_tarifas(INPUT gncptit.cdagenci,
                                             INPUT 20, /* 20 - Titulo VLB SR */
                                             INPUT qtd_totenvsu,
                                             INPUT qtd_totenvsu *
                                                   gncdtrf.vltrftit,
                                             INPUT 0,
                                             INPUT gncdtrf.vltrftit).

           END. /* END do LAST-OF */
   END. /* END do FOREACH */

   
   IF   vlr_totcredi <> 0  THEN
        /* Criando LCM para valor somado de Creditos - Titulo Sua Remessa */
        RUN pi_cria_craplcm (INPUT vlr_totcredi,
                             INPUT 989).


END PROCEDURE.

/*............................................................................*/

PROCEDURE pi_processa_tit_sua_epr:
/* SUA REMESSA */
   DEF INPUT PARAM par_temassoc AS LOG                   NO-UNDO.

   DEF         VAR aux_valorvlb AS DEC                   NO-UNDO.
   /* Variaveis: Lancamentos  Sup  */
   DEF         VAR qtd_totenvsu AS INT                   NO-UNDO.
   DEF         VAR qtd_totdevsu AS INT                   NO-UNDO.
   /* Variaveis: Lancamentos  Inf  */
   DEF         VAR qtd_totenvin AS INT                   NO-UNDO.
   DEF         VAR qtd_totdevin AS INT                   NO-UNDO.
   /* Variaveis: Totais gerais Envio - Dev [Inf/Sup]  */
   DEF         VAR vlr_totenvio AS DEC                   NO-UNDO.
   DEF         VAR vlr_totdevol AS DEC                   NO-UNDO.
   
   /* Variaveis: Totais gerais por Credito p/ cooperativa */
   DEF         VAR vlr_totcredi AS DEC                   NO-UNDO.

   /* BUSCAR VALORESVLB DOS TITULOS */ 
   FIND craptab WHERE craptab.cdcooper = glb_cdcooper    AND 
                      craptab.nmsistem = "CRED"          AND 
                      craptab.tptabela = "GENERI"        AND 
                      craptab.cdempres = 00              AND 
                      craptab.cdacesso = "VALORESVLB"    AND 
                      craptab.tpregist = 0               NO-LOCK NO-ERROR.

   IF   AVAILABLE craptab   THEN
        aux_valorvlb = DEC(ENTRY(1,craptab.dstextab,";")).
   ELSE
        aux_valorvlb = 5000.
      
   /* Zerar variaveis - Gerais */
   ASSIGN vlr_totenvio = 0
          vlr_totdevol = 0.

   /* Acumular variaveis */
   FOR EACH gncptit WHERE gncptit.cdcooper = crapcop.cdcooper  AND
                          gncptit.dtliquid = glb_dtmvtolt      AND
                          gncptit.cdtipreg = 5                 AND
                          gncptit.flgpcctl = FALSE             AND
                          gncptit.flgpgdda = FALSE             NO-LOCK
                          BREAK BY gncptit.cdagenci:

       IF   FIRST-OF(gncptit.cdagenci) THEN
            /* Zerar variaveis - Por cdAgenci */
            ASSIGN qtd_totenvsu = 0
                   qtd_totdevsu = 0
                   qtd_totenvin = 0
                   qtd_totdevin = 0.

       IF   par_temassoc THEN
       DO:
            ASSIGN vlr_totcredi = vlr_totcredi + gncptit.vldpagto.

            IF   gncptit.cdmotdev = 0 THEN
                 DO:            /* ENVIO TITULOS */
                     IF   gncptit.vldpagto > aux_valorvlb THEN
                          ASSIGN qtd_totenvsu = qtd_totenvsu + 1
                                 vlr_totenvio = vlr_totenvio + gncptit.vldpagto.
                     ELSE
                          ASSIGN qtd_totenvin = qtd_totenvin + 1
                                 vlr_totenvio = vlr_totenvio + gncptit.vldpagto.
                 END. /* FIM - IF gncptit.cdmotdev = 0 */
            ELSE
                 DO:
                    IF   gncptit.vldpagto > aux_valorvlb THEN /* DEV.TITULOS */
                         ASSIGN qtd_totdevsu = qtd_totdevsu + 1
                                vlr_totdevol = vlr_totdevol + gncptit.vldpagto.
                    ELSE
                         ASSIGN qtd_totdevin = qtd_totdevin + 1
                                vlr_totdevol = vlr_totdevol + gncptit.vldpagto.
                 END. /* FIM - ELSE do gncptit.cdmotdev = 0 */
       END.
       ELSE
            DO:
                FIND bgncptit WHERE RECID(bgncptit) = RECID(gncptit)
                                    EXCLUSIVE-LOCK NO-ERROR.
                IF   AVAILABLE bgncptit   THEN
                     DO:
                         /* Critica Associado nao Existe */
                         ASSIGN  bgncptit.cdcrictl = 9.
                         RELEASE bgncptit.
                     END.
            END.

       IF   LAST-OF(gncptit.cdagenci) THEN
            DO:
                IF   qtd_totenvin <> 0  THEN
                     RUN pi_cria_tab_tarifas(INPUT gncptit.cdagenci,
                                             INPUT 26, /* 26 - Titulo SR Epr   */
                                             INPUT qtd_totenvin,
                                             INPUT qtd_totenvin *
                                                   gncdtrf.vltrftit,
                                             INPUT 0,
                                             INPUT gncdtrf.vltrftit).

                IF   qtd_totenvsu <> 0  THEN
                     RUN pi_cria_tab_tarifas(INPUT gncptit.cdagenci,
                                             INPUT 27, /* 27 - Titulo VLB SR Epr */
                                             INPUT qtd_totenvsu,
                                             INPUT qtd_totenvsu *
                                                   gncdtrf.vltrftit,
                                             INPUT 0,
                                             INPUT gncdtrf.vltrftit).

           END. /* END do LAST-OF */
   END. /* END do FOREACH */

   
   IF   vlr_totcredi <> 0  THEN
        /* Criando LCM para valor somado de Creditos - Titulo Sua Remessa */
        RUN pi_cria_craplcm (INPUT vlr_totcredi,
                             INPUT 1997).


END PROCEDURE.

/*............................................................................*/

PROCEDURE pi_processa_doc_nossa:
/* NOSSA REMESSA */
   DEF INPUT PARAM par_temassoc AS LOG                   NO-UNDO.

   /* Variaveis: Lancamentos - Envio/Devolu    */
   DEF         VAR vlr_totenvio AS DEC                   NO-UNDO.
   DEF         VAR qtd_totenvio AS INT                   NO-UNDO.
   DEF         VAR vlr_totdevol AS DEC                   NO-UNDO.
   DEF         VAR qtd_totdevol AS INT                   NO-UNDO.
   /* Variaveis: Totais gerais - Envio/Devolu  */
   DEF         VAR vlr_totgeren AS DEC                   NO-UNDO.
   DEF         VAR vlr_totgerdv AS DEC                   NO-UNDO.

        
   /* Zerar variaveis - Gerais */
   ASSIGN vlr_totgeren = 0
          vlr_totgerdv = 0.

   /* Acumular variaveis */
   FOR EACH gncpdoc WHERE gncpdoc.cdcooper = crapcop.cdcooper  AND
                          gncpdoc.dtliquid = glb_dtmvtolt      AND
                          gncpdoc.cdtipreg = 2                 AND
                          gncpdoc.flgpcctl = FALSE             NO-LOCK
                          BREAK BY gncpdoc.cdagenci:

       IF   FIRST-OF(gncpdoc.cdagenci) THEN
            /* Zerar variaveis */
            ASSIGN vlr_totenvio = 0
                   vlr_totdevol = 0
                   qtd_totenvio = 0
                   qtd_totdevol = 0.

       IF   par_temassoc THEN 
            DO:
                IF   gncpdoc.cdmotdev = 0 THEN /* ENVIO DOC */
                     ASSIGN vlr_totenvio = vlr_totenvio + gncpdoc.vldocmto
                            qtd_totenvio = qtd_totenvio + 1
                            vlr_totgeren = vlr_totgeren + gncpdoc.vldocmto.
                ELSE 
                     DO:                     /* DEVOLU DOC */
                         ASSIGN vlr_totdevol = vlr_totdevol + gncpdoc.vldocmto
                                qtd_totdevol = qtd_totdevol + 1
                                vlr_totgerdv = vlr_totgerdv + gncpdoc.vldocmto.
                     END.
            END.
       ELSE 
            DO:
                FIND bgncpdoc WHERE RECID(bgncpdoc) = RECID(gncpdoc) 
                                    EXCLUSIVE-LOCK NO-ERROR.
                IF   AVAILABLE bgncpdoc   THEN 
                     DO:
                         ASSIGN  bgncpdoc.cdcrictl = 9.
                         RELEASE bgncpdoc.
                     END.
            END.

       IF   LAST-OF(gncpdoc.cdagenci) THEN 
            DO:
                IF   qtd_totenvio <> 0  THEN
                     RUN pi_cria_tab_tarifas(INPUT gncpdoc.cdagenci,
                                             INPUT 5, /* 05 - DOC NR  */
                                             INPUT qtd_totenvio,
                                             INPUT qtd_totenvio *
                                                   gncdtrf.vltrfdoc,
                                             INPUT 0,
                                             INPUT gncdtrf.vltrfdoc).
            END. /* END do LAST-OF */
   END. /* END do FOREACH */

   IF   vlr_totgeren <> 0  THEN
        /* Criando LCM para valor somado - Envio DOC */
        RUN pi_cria_craplcm (INPUT vlr_totgeren,
                             INPUT 783).

   IF   vlr_totgerdv <> 0  THEN
        /* Criando LCM para valor somado - Devolucao DOC */
        RUN pi_cria_craplcm (INPUT vlr_totgerdv,
                             INPUT 794).

END PROCEDURE.

/*............................................................................*/

PROCEDURE pi_processa_doc_sua:
/* SUA REMESSA */
   DEF INPUT PARAM par_temassoc AS LOG                   NO-UNDO.

   ASSIGN vlr_lantotin = 0
          vlr_lantotsu = 0.

   /* Acumular variaveis */
   FOR EACH gncpdoc WHERE gncpdoc.cdcooper = crapcop.cdcooper  AND 
                          gncpdoc.dtliquid = glb_dtmvtolt      AND
                         (gncpdoc.cdtipreg = 4                 OR
                          gncpdoc.cdtipreg = 3)                AND
                          gncpdoc.flgpcctl = FALSE             NO-LOCK
                          BREAK BY gncpdoc.cdagenci:

       IF   FIRST-OF(gncpdoc.cdagenci) THEN
            /* Zerar variaveis */
            ASSIGN qtd_lancasup = 0
                   qtd_lancainf = 0.

       IF   par_temassoc THEN
            DO:
                IF   gncpdoc.tpdoctrf <> "2" AND
                     gncpdoc.tpdoctrf <> "9" THEN
                     ASSIGN qtd_lancasup = qtd_lancasup + 1.
                            
                ASSIGN vlr_lantotsu = vlr_lantotsu + gncpdoc.vldocmto.
            END.                
       ELSE 
            DO:
                FIND bgncpdoc WHERE RECID(bgncpdoc) = RECID(gncpdoc) 
                                    EXCLUSIVE-LOCK NO-ERROR.
                IF   AVAILABLE bgncpdoc   THEN 
                     DO:
                         ASSIGN  bgncpdoc.cdcrictl = 9.
                         RELEASE bgncpdoc.
                     END.
            END.
       
       IF   LAST-OF(gncpdoc.cdagenci) THEN 
            DO:
                IF   qtd_lancasup <> 0  THEN
                     RUN pi_cria_tab_tarifas(INPUT gncpdoc.cdagenci,
                                             INPUT 8, /* 08 - DOC SR */
                                             INPUT qtd_lancasup,
                                             INPUT qtd_lancasup *
                                                   gncdtrf.vltrfdoc,
                                             INPUT 0,
                                             INPUT gncdtrf.vltrfdoc).
            END. /* END do LAST-OF */
   END. /* END do FOREACH */

   IF   vlr_lantotsu <> 0  THEN
        /* Criando LCM para valor somado */
        RUN pi_cria_craplcm (INPUT vlr_lantotsu,
                             INPUT 786).

END PROCEDURE.

/*............................................................................*/

PROCEDURE pi_processa_tit_nossa_dda:
/* NOSSA REMESSA */
   DEF INPUT PARAM par_temassoc AS LOG                   NO-UNDO.

   DEF         VAR aux_valorvlb AS DEC                   NO-UNDO.
   /* Variaveis: Lancamentos  Sup  */
   DEF         VAR qtd_totenvsu AS INT                   NO-UNDO.
   DEF         VAR qtd_totdevsu AS INT                   NO-UNDO.
   /* Variaveis: Lancamentos  Inf  */
   DEF         VAR qtd_totenvin AS INT                   NO-UNDO.
   DEF         VAR qtd_totdevin AS INT                   NO-UNDO.
   /* Variaveis: Totais gerais Envio - Dev [Inf/Sup]  */
   DEF         VAR vlr_totenvio AS DEC                   NO-UNDO.
   DEF         VAR vlr_totdevol AS DEC                   NO-UNDO.
   
   /* BUSCAR VALORESVLB DOS TITULOS */ 
   FIND craptab WHERE craptab.cdcooper = glb_cdcooper    AND 
                      craptab.nmsistem = "CRED"          AND 
                      craptab.tptabela = "GENERI"        AND 
                      craptab.cdempres = 00              AND 
                      craptab.cdacesso = "VALORESVLB"    AND 
                      craptab.tpregist = 0               NO-LOCK NO-ERROR.

   IF   AVAILABLE craptab   THEN
        aux_valorvlb = DEC(ENTRY(1,craptab.dstextab,";")).
   ELSE
        aux_valorvlb = 5000.
      
   /* Zerar variaveis - Gerais */
   ASSIGN vlr_totenvio = 0
          vlr_totdevol = 0.

   /* Acumular variaveis */
   FOR EACH gncptit WHERE gncptit.cdcooper = crapcop.cdcooper  AND
                          gncptit.dtliquid = glb_dtmvtolt      AND
                          gncptit.cdtipreg = 2                 AND
                          gncptit.flgpcctl = FALSE             AND
                          gncptit.flgpgdda = TRUE              NO-LOCK
                          BREAK BY gncptit.cdagenci:

       IF   FIRST-OF(gncptit.cdagenci) THEN
            /* Zerar variaveis - Por cdAgenci */
            ASSIGN qtd_totenvsu = 0
                   qtd_totdevsu = 0
                   qtd_totenvin = 0
                   qtd_totdevin = 0.
    
       IF   par_temassoc THEN
            IF   gncptit.cdmotdev = 0 THEN 
                 DO:            /* ENVIO TITULOS */
                     IF   gncptit.vldpagto > aux_valorvlb THEN
                          ASSIGN qtd_totenvsu = qtd_totenvsu + 1
                                 vlr_totenvio = vlr_totenvio + gncptit.vldpagto.
                     ELSE
                          ASSIGN qtd_totenvin = qtd_totenvin + 1
                                 vlr_totenvio = vlr_totenvio + gncptit.vldpagto.
                 END. /* FIM - IF gncptit.cdmotdev = 0 */
            ELSE 
                 DO:
                    IF   gncptit.vldpagto > aux_valorvlb THEN /* DEV.TITULOS */
                         ASSIGN qtd_totdevsu = qtd_totdevsu + 1
                                vlr_totdevol = vlr_totdevol + gncptit.vldpagto.
                    ELSE
                         ASSIGN qtd_totdevin = qtd_totdevin + 1
                                vlr_totdevol = vlr_totdevol + gncptit.vldpagto.
                 END. /* FIM - ELSE do gncptit.cdmotdev = 0 */
       ELSE 
            DO:
                FIND bgncptit WHERE RECID(bgncptit) = RECID(gncptit) 
                                    EXCLUSIVE-LOCK NO-ERROR.
                IF   AVAILABLE bgncptit   THEN 
                     DO:
                         /* Critica Associado nao Existe */
                         ASSIGN  bgncptit.cdcrictl = 9.
                         RELEASE bgncptit.
                     END.
            END.

       IF   LAST-OF(gncptit.cdagenci) THEN 
            DO:
                IF   qtd_totenvin <> 0  THEN
                     RUN pi_cria_tab_tarifas(INPUT gncptit.cdagenci,
                                             INPUT 21, /* 21 - Titulo NR DDA  */
                                             INPUT qtd_totenvin,
                                             INPUT qtd_totenvin *
                                                   gncdtrf.vltrfdda,
                                             INPUT 0,
                                             INPUT gncdtrf.vltrfdda).
        
                IF   qtd_totenvsu <> 0  THEN
                     RUN pi_cria_tab_tarifas(INPUT gncptit.cdagenci,
                                             INPUT 22, /* 22 - Titulo VLB NR DDA*/
                                             INPUT qtd_totenvsu,
                                             INPUT qtd_totenvsu *
                                                   gncdtrf.vltrfdda,
                                             INPUT 0,
                                             INPUT gncdtrf.vltrfdda).

           END. /* END do LAST-OF */
   END. /* END do FOREACH */

   IF   vlr_totenvio <> 0  THEN
        /* Criando LCM para valor somado - Titulo Nossa Remessa */
        RUN pi_cria_craplcm (INPUT vlr_totenvio,
                             INPUT 782).

   IF   vlr_totdevol <> 0  THEN
        /* Criando LCM para valor somado - Devolucao Titulo */
        RUN pi_cria_craplcm (INPUT vlr_totdevol,
                             INPUT 793).

END PROCEDURE.

/*............................................................................*/

PROCEDURE pi_processa_tit_sua_dda:
/* SUA REMESSA */
   DEF INPUT PARAM par_temassoc AS LOG                   NO-UNDO.

   DEF         VAR aux_valorvlb AS DEC                   NO-UNDO.
   /* Variaveis: Lancamentos  Sup  */
   DEF         VAR qtd_totenvsu AS INT                   NO-UNDO.
   DEF         VAR qtd_totdevsu AS INT                   NO-UNDO.
   /* Variaveis: Lancamentos  Inf  */
   DEF         VAR qtd_totenvin AS INT                   NO-UNDO.
   DEF         VAR qtd_totdevin AS INT                   NO-UNDO.
   /* Variaveis: Totais gerais Envio - Dev [Inf/Sup]  */
   DEF         VAR vlr_totenvio AS DEC                   NO-UNDO.
   DEF         VAR vlr_totdevol AS DEC                   NO-UNDO.
   
   /* Variaveis: Totais gerais por Credito p/ cooperativa */
   DEF         VAR vlr_totcredi AS DEC                   NO-UNDO.

   /* BUSCAR VALORESVLB DOS TITULOS */ 
   FIND craptab WHERE craptab.cdcooper = glb_cdcooper    AND 
                      craptab.nmsistem = "CRED"          AND 
                      craptab.tptabela = "GENERI"        AND 
                      craptab.cdempres = 00              AND 
                      craptab.cdacesso = "VALORESVLB"    AND 
                      craptab.tpregist = 0               NO-LOCK NO-ERROR.

   IF   AVAILABLE craptab   THEN
        aux_valorvlb = DEC(ENTRY(1,craptab.dstextab,";")).
   ELSE
        aux_valorvlb = 5000.
      
   /* Zerar variaveis - Gerais */
   ASSIGN vlr_totenvio = 0
          vlr_totdevol = 0.

   /* Acumular variaveis */
   FOR EACH gncptit WHERE gncptit.cdcooper = crapcop.cdcooper  AND
                          gncptit.dtliquid = glb_dtmvtolt      AND
                         (gncptit.cdtipreg = 4                 OR
                          gncptit.cdtipreg = 3)                AND
                          gncptit.flgpcctl = FALSE             AND
                          gncptit.flgpgdda = TRUE              NO-LOCK
                          BREAK BY gncptit.cdagenci:

       IF   FIRST-OF(gncptit.cdagenci) THEN
            /* Zerar variaveis - Por cdAgenci */
            ASSIGN qtd_totenvsu = 0
                   qtd_totdevsu = 0
                   qtd_totenvin = 0
                   qtd_totdevin = 0.

       IF   par_temassoc THEN
       DO:
            ASSIGN vlr_totcredi = vlr_totcredi + gncptit.vldpagto.

            IF   gncptit.cdmotdev = 0 THEN
                 DO:            /* ENVIO TITULOS */
                     IF   gncptit.vldpagto > aux_valorvlb THEN
                          ASSIGN qtd_totenvsu = qtd_totenvsu + 1
                                 vlr_totenvio = vlr_totenvio + gncptit.vldpagto.
                     ELSE
                          ASSIGN qtd_totenvin = qtd_totenvin + 1
                                 vlr_totenvio = vlr_totenvio + gncptit.vldpagto.
                 END. /* FIM - IF gncptit.cdmotdev = 0 */
            ELSE
                 DO:
                    IF   gncptit.vldpagto > aux_valorvlb THEN /* DEV.TITULOS */
                         ASSIGN qtd_totdevsu = qtd_totdevsu + 1
                                vlr_totdevol = vlr_totdevol + gncptit.vldpagto.
                    ELSE
                         ASSIGN qtd_totdevin = qtd_totdevin + 1
                                vlr_totdevol = vlr_totdevol + gncptit.vldpagto.
                 END. /* FIM - ELSE do gncptit.cdmotdev = 0 */
       END.
       ELSE
            DO:
                FIND bgncptit WHERE RECID(bgncptit) = RECID(gncptit)
                                    EXCLUSIVE-LOCK NO-ERROR.
                IF   AVAILABLE bgncptit   THEN
                     DO:
                         /* Critica Associado nao Existe */
                         ASSIGN  bgncptit.cdcrictl = 9.
                         RELEASE bgncptit.
                     END.
            END.

       IF   LAST-OF(gncptit.cdagenci) THEN
            DO:
                IF   qtd_totenvin <> 0  THEN
                     RUN pi_cria_tab_tarifas(INPUT gncptit.cdagenci,
                                             INPUT 23, /* 23 - Titulo SR DDA */
                                             INPUT qtd_totenvin,
                                             INPUT qtd_totenvin *
                                                   gncdtrf.vltrfdda,
                                             INPUT 0,
                                             INPUT gncdtrf.vltrfdda).

                IF   qtd_totenvsu <> 0  THEN
                     RUN pi_cria_tab_tarifas(INPUT gncptit.cdagenci,
                                             INPUT 24, /* 24 - Titulo VLB SR DDA */
                                             INPUT qtd_totenvsu,
                                             INPUT qtd_totenvsu *
                                                   gncdtrf.vltrfdda,
                                             INPUT 0,
                                             INPUT gncdtrf.vltrfdda).

           END. /* END do LAST-OF */
   END. /* END do FOREACH */

   
   IF   vlr_totcredi <> 0  THEN
        /* Criando LCM para valor somado de Creditos - Titulo Sua Remessa */
        RUN pi_cria_craplcm (INPUT vlr_totcredi,
                             INPUT 989).


END PROCEDURE.

/*............................................................................*/

PROCEDURE pi_processa_tit_sua_epr_dda:
/* SUA REMESSA */
   DEF INPUT PARAM par_temassoc AS LOG                   NO-UNDO.

   DEF         VAR aux_valorvlb AS DEC                   NO-UNDO.
   /* Variaveis: Lancamentos  Sup  */
   DEF         VAR qtd_totenvsu AS INT                   NO-UNDO.
   DEF         VAR qtd_totdevsu AS INT                   NO-UNDO.
   /* Variaveis: Lancamentos  Inf  */
   DEF         VAR qtd_totenvin AS INT                   NO-UNDO.
   DEF         VAR qtd_totdevin AS INT                   NO-UNDO.
   /* Variaveis: Totais gerais Envio - Dev [Inf/Sup]  */
   DEF         VAR vlr_totenvio AS DEC                   NO-UNDO.
   DEF         VAR vlr_totdevol AS DEC                   NO-UNDO.
   
   /* Variaveis: Totais gerais por Credito p/ cooperativa */
   DEF         VAR vlr_totcredi AS DEC                   NO-UNDO.

   /* BUSCAR VALORESVLB DOS TITULOS */ 
   FIND craptab WHERE craptab.cdcooper = glb_cdcooper    AND 
                      craptab.nmsistem = "CRED"          AND 
                      craptab.tptabela = "GENERI"        AND 
                      craptab.cdempres = 00              AND 
                      craptab.cdacesso = "VALORESVLB"    AND 
                      craptab.tpregist = 0               NO-LOCK NO-ERROR.

   IF   AVAILABLE craptab   THEN
        aux_valorvlb = DEC(ENTRY(1,craptab.dstextab,";")).
   ELSE
        aux_valorvlb = 5000.
      
   /* Zerar variaveis - Gerais */
   ASSIGN vlr_totenvio = 0
          vlr_totdevol = 0.

   /* Acumular variaveis */
   FOR EACH gncptit WHERE gncptit.cdcooper = crapcop.cdcooper  AND
                          gncptit.dtliquid = glb_dtmvtolt      AND
                          gncptit.cdtipreg = 5                 AND
                          gncptit.flgpcctl = FALSE             AND
                          gncptit.flgpgdda = TRUE              NO-LOCK
                          BREAK BY gncptit.cdagenci:

       IF   FIRST-OF(gncptit.cdagenci) THEN
            /* Zerar variaveis - Por cdAgenci */
            ASSIGN qtd_totenvsu = 0
                   qtd_totdevsu = 0
                   qtd_totenvin = 0
                   qtd_totdevin = 0.

       IF   par_temassoc THEN
       DO:
            ASSIGN vlr_totcredi = vlr_totcredi + gncptit.vldpagto.

            IF   gncptit.cdmotdev = 0 THEN
                 DO:            /* ENVIO TITULOS */
                     IF   gncptit.vldpagto > aux_valorvlb THEN
                          ASSIGN qtd_totenvsu = qtd_totenvsu + 1
                                 vlr_totenvio = vlr_totenvio + gncptit.vldpagto.
                     ELSE
                          ASSIGN qtd_totenvin = qtd_totenvin + 1
                                 vlr_totenvio = vlr_totenvio + gncptit.vldpagto.
                 END. /* FIM - IF gncptit.cdmotdev = 0 */
            ELSE
                 DO:
                    IF   gncptit.vldpagto > aux_valorvlb THEN /* DEV.TITULOS */
                         ASSIGN qtd_totdevsu = qtd_totdevsu + 1
                                vlr_totdevol = vlr_totdevol + gncptit.vldpagto.
                    ELSE
                         ASSIGN qtd_totdevin = qtd_totdevin + 1
                                vlr_totdevol = vlr_totdevol + gncptit.vldpagto.
                 END. /* FIM - ELSE do gncptit.cdmotdev = 0 */
       END.
       ELSE
            DO:
                FIND bgncptit WHERE RECID(bgncptit) = RECID(gncptit)
                                    EXCLUSIVE-LOCK NO-ERROR.
                IF   AVAILABLE bgncptit   THEN
                     DO:
                         /* Critica Associado nao Existe */
                         ASSIGN  bgncptit.cdcrictl = 9.
                         RELEASE bgncptit.
                     END.
            END.

       IF   LAST-OF(gncptit.cdagenci) THEN
            DO:
                IF   qtd_totenvin <> 0  THEN
                     RUN pi_cria_tab_tarifas(INPUT gncptit.cdagenci,
                                             INPUT 28, /* 28 - Titulo SR Epr DDA */
                                             INPUT qtd_totenvin,
                                             INPUT qtd_totenvin *
                                                   gncdtrf.vltrfdda,
                                             INPUT 0,
                                             INPUT gncdtrf.vltrfdda).

                IF   qtd_totenvsu <> 0  THEN
                     RUN pi_cria_tab_tarifas(INPUT gncptit.cdagenci,
                                             INPUT 29, /* 29 - Titulo VLB SR Epr DDA */
                                             INPUT qtd_totenvsu,
                                             INPUT qtd_totenvsu *
                                                   gncdtrf.vltrfdda,
                                             INPUT 0,
                                             INPUT gncdtrf.vltrfdda).

           END. /* END do LAST-OF */
   END. /* END do FOREACH */

   
   IF   vlr_totcredi <> 0  THEN
        /* Criando LCM para valor somado de Creditos - Titulo Sua Remessa */
        RUN pi_cria_craplcm (INPUT vlr_totcredi,
                             INPUT 1997).


END PROCEDURE.

/*............................................................................*/

/* Sua remessa - Dev boletos 085 */
PROCEDURE pi_processa_tit_dev_sua:

  DEF VAR aux_ponteiro    AS INT                                      NO-UNDO.
  DEF VAR vlr_totdevol    AS DEC INIT 0                               NO-UNDO.

  { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
                
  RUN STORED-PROC {&sc2_dboraayl}.send-sql-statement
     aux_ponteiro = PROC-HANDLE
             ("SELECT NVL(sum(dvc.vlliquid),0) 
                 FROM gncpdvc dvc
                WHERE dvc.cdcooper = " + STRING(crapcop.cdcooper) + "
                  AND dvc.dtmvtolt = TO_DATE('" + 
                            STRING(glb_dtmvtolt,'99/99/9999') + "','DD/MM/RRRR')
                  AND dvc.flgconci = 1
                  AND dvc.flgpcctl = 0").
            
  FOR EACH {&sc2_dboraayl}.proc-text-buffer WHERE PROC-HANDLE = aux_ponteiro:
      ASSIGN vlr_totdevol = DEC(proc-text). 
  END.

  CLOSE STORED-PROC {&sc2_dboraayl}.send-sql-statement
        WHERE PROC-HANDLE = aux_ponteiro.
                               
  { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

   IF   vlr_totdevol <> 0  THEN
        /* Criando LCM para Debitar os títulos 085 devolvidos no dia anterior */
        RUN pi_cria_craplcm (INPUT vlr_totdevol,
                             INPUT 2270).

END PROCEDURE.

/*............................................................................*/

PROCEDURE pi_processa_dev_sua:
   /* SUA REMESSA - Cheques das cooperativas depositados em outros bancos.
                    Conta do associado nao possui saldo e coop. gera 
                    devolucao */   
                    
   DEF INPUT PARAM par_temassoc AS LOG                   NO-UNDO.

   /* Soma Noturna  */
   DEF         VAR qtd_snoturna AS INT                   NO-UNDO.
   /* Soma Diurna   */
   DEF         VAR vlr_sgdiurna AS DEC                   NO-UNDO.
   DEF         VAR qtd_sgdiurna AS INT                   NO-UNDO.
   /* Totais gerais Devolu [Diurna/Noturna]  */
   DEF         VAR vlr_totalnot AS DEC                   NO-UNDO.
   DEF         VAR vlr_totaldiu AS DEC                   NO-UNDO.

   /* Zerar variaveis */
   ASSIGN vlr_totalnot = 0
          vlr_totaldiu = 0.

   /* Acumular variaveis */
   FOR EACH gncpdev WHERE gncpdev.cdcooper = crapcop.cdcooper  AND
                          gncpdev.dtliquid = glb_dtmvtolt      AND
                          gncpdev.cdtipreg = 2                 AND
                          gncpdev.cdalinea <> 0                AND
                          gncpdev.flgpcctl = FALSE             NO-LOCK
                          BREAK BY gncpdev.cdagenci:

       IF   FIRST-OF(gncpdev.cdagenci) THEN
            /* Zerar variaveis */
            ASSIGN qtd_snoturna = 0
                   qtd_sgdiurna = 0.

       IF   par_temassoc THEN 
            DO:
                IF   gncpdev.cdperdev = 1 THEN /* Noturna = 1 */
                     DO:
                         IF   CAN-DO("11,12,13,14,20,21,22,23,24,25",
                                     STRING(gncpdev.cdalinea)) THEN
                              qtd_snoturna = qtd_snoturna + 1.
                              
                         vlr_totalnot = vlr_totalnot + gncpdev.vlcheque.
                     END.       
                ELSE
                     IF   gncpdev.cdperdev = 2 THEN /* Diurna  = 2 */
                          DO:
                              IF   CAN-DO("11,12,13,14,20,21,22,23,24,25",
                                          STRING(gncpdev.cdalinea)) THEN
                                   qtd_sgdiurna = qtd_sgdiurna + 1.
                           
                              vlr_totaldiu = vlr_totaldiu + gncpdev.vlcheque.
                          END.
            END.
       ELSE 
            DO:
                FIND bgncpdev WHERE RECID(bgncpdev) = RECID(gncpdev) 
                                    EXCLUSIVE-LOCK NO-ERROR.
                IF   AVAILABLE bgncpdev   THEN 
                     DO:
                         ASSIGN  bgncpdev.cdcrictl = 9. 
                         RELEASE bgncpdev.
                     END.
            END.

       IF   LAST-OF(gncpdev.cdagenci) THEN 
            DO:
                IF   qtd_snoturna <> 0  THEN
                     RUN pi_cria_tab_tarifas(INPUT gncpdev.cdagenci,
                                             INPUT 9, /* 09 - Dev SR Not  */
                                             INPUT qtd_snoturna,
                                             INPUT qtd_snoturna *
                                                   gncdtrf.vltrfdev,
                                             INPUT 0,
                                             INPUT gncdtrf.vltrfdev).
        
                IF   qtd_sgdiurna <> 0  THEN
                     RUN pi_cria_tab_tarifas(INPUT gncpdev.cdagenci,
                                             INPUT 10, /* 10 - Dev SR Diu */
                                             INPUT qtd_sgdiurna,
                                             INPUT qtd_sgdiurna *
                                                   gncdtrf.vltrfdev,
                                             INPUT 0,
                                             INPUT gncdtrf.vltrfdev).
            END. /* END do LAST-OF */
   END. /* END do FOREACH */

   IF   vlr_totaldiu <> 0  THEN
        /* Criando LCM para valor  Diurna - Remetida */
        RUN pi_cria_craplcm (INPUT vlr_totaldiu,
                             INPUT 787).

   IF   vlr_totalnot <> 0  THEN
        /* Criando LCM para valor Noturna - Remetida */
        RUN pi_cria_craplcm (INPUT vlr_totalnot,
                             INPUT 788).
       
          
END PROCEDURE.

/*............................................................................*/

PROCEDURE pi_processa_dev_nossa:
   /** NOSSA REMESSA - lancamento de devolucao na conta movimento (craplcm),
                       ref. cheques de outros bancos sem fundo depositados nas
                       cooperativas **/
                 
   DEF INPUT PARAM par_temassoc AS LOG                   NO-UNDO.

   /* Soma Noturna  */
   DEF         VAR qtd_snoturna AS INT                   NO-UNDO.
   /* Soma Diurna   */
   DEF         VAR vlr_sgdiurna AS DEC                   NO-UNDO.
   DEF         VAR qtd_sgdiurna AS INT                   NO-UNDO.
   /* Totais gerais Devolu [Diurna/Noturna]  */
   DEF         VAR vlr_totalnot AS DEC                   NO-UNDO.
   DEF         VAR vlr_totaldiu AS DEC                   NO-UNDO.

   /* Zerar variaveis */
   ASSIGN vlr_totalnot = 0
          vlr_totaldiu = 0.

   /* Acumular variaveis */
   FOR EACH gncpdev WHERE gncpdev.cdcooper = crapcop.cdcooper  AND
                          gncpdev.dtliquid = glb_dtmvtolt      AND
                         (gncpdev.cdtipreg = 4                 OR
                          gncpdev.cdtipreg = 3)                AND
                          gncpdev.cdalinea <> 0                AND
                          gncpdev.flgpcctl = FALSE             NO-LOCK
                          BREAK BY gncpdev.cdagenci:

       IF   par_temassoc THEN 
            DO:
                IF   gncpdev.cdperdev = 1 THEN /* Noturna = 1 */
                     ASSIGN qtd_snoturna = qtd_snoturna + 1
                            vlr_totalnot = vlr_totalnot + gncpdev.vlcheque.
                ELSE
                     IF   gncpdev.cdperdev = 2 THEN /* Diurna  = 2 */
                          ASSIGN qtd_sgdiurna = qtd_sgdiurna + 1
                                 vlr_totaldiu = vlr_totaldiu + gncpdev.vlcheque.
            END.
       ELSE 
            DO:
                FIND bgncpdev WHERE RECID(bgncpdev) = RECID(gncpdev) 
                                    EXCLUSIVE-LOCK NO-ERROR.
                IF   AVAILABLE bgncpdev   THEN 
                     DO:
                         ASSIGN  bgncpdev.cdcrictl = 9. 
                         RELEASE bgncpdev.
                     END.
            END.

   END. /* END do FOREACH */

   IF   vlr_totaldiu <> 0  THEN
        /* Criando LCM para valor  Diurna - Recebida */
        RUN pi_cria_craplcm (INPUT vlr_totaldiu,
                             INPUT 789).

   IF   vlr_totalnot <> 0  THEN
        /* Criando LCM para valor Noturna - Recebida */
        RUN pi_cria_craplcm (INPUT vlr_totalnot,
                             INPUT 790).

END PROCEDURE.

/*............................................................................*/

PROCEDURE pi_processa_ted_tec:

   DEF INPUT PARAM par_temassoc AS LOG                   NO-UNDO.

   /* Variaveis: TED/TEC Credito-Debito */
   DEF         VAR qtd_strcredi AS INT                   NO-UNDO.
   DEF         VAR qtd_strdebit AS INT                   NO-UNDO.
   
   DEF         VAR qtd_pagcredi AS INT                   NO-UNDO.
   DEF         VAR qtd_pagdebit AS INT                   NO-UNDO.
   
   /* Variaveis: Totais TED/TEC */
   DEF         VAR tot_strcredi AS DEC                   NO-UNDO.
   DEF         VAR tot_strdebit AS DEC                   NO-UNDO.
   DEF         VAR tot_strdevcr AS DEC                   NO-UNDO.
   DEF         VAR tot_strdevdb AS DEC                   NO-UNDO.
   DEF         VAR tot_pagcredi AS DEC                   NO-UNDO.
   DEF         VAR tot_pagdebit AS DEC                   NO-UNDO.
   DEF         VAR tot_pagdevcr AS DEC                   NO-UNDO.
   DEF         VAR tot_pagdevdb AS DEC                   NO-UNDO.
   DEF         VAR tot_vldebmat AS DEC                   NO-UNDO.

   DEF         VAR aux_cdfinmsg AS INT                   NO-UNDO.

   ASSIGN tot_strcredi = 0
          tot_strdebit = 0
          tot_vldebmat = 0
          tot_strdevcr = 0   /* devolucoes recebidas */ 
          tot_strdevdb = 0   /* devolucoes enviadas */
          tot_pagcredi = 0
          tot_pagdebit = 0
          tot_pagdevcr = 0   /* devolucoes recebidas */
          tot_pagdevdb = 0.  /* devolucoes enviadas */
   
   FOR EACH gnmvspb WHERE gnmvspb.cdcooper = crapcop.cdcooper AND
                          gnmvspb.dtmvtolt = glb_dtmvtolt     NO-LOCK
                          BREAK BY gnmvspb.cdagenci:

       IF   FIRST-OF(gnmvspb.cdagenci) THEN
            ASSIGN qtd_strcredi = 0
                   qtd_strdebit = 0
                   qtd_pagcredi = 0
                   qtd_pagdebit = 0.

       IF   par_temassoc THEN 
            DO:
                ASSIGN aux_cdfinmsg = INT(gnmvspb.dsfinmsg) NO-ERROR.

                IF   ERROR-STATUS:ERROR THEN
                     ASSIGN aux_cdfinmsg = 0 .

                /* TED/TEC  Recebidos STR  */
                IF   CAN-DO("STR0008R2,STR0037R2," +
                            "STR0005R2,STR0007R2,STR0025R2," +
                            "STR0034R2,STR0006R2,STR0039R2",gnmvspb.dsmensag)  
                         THEN 
                     DO:
                        ASSIGN tot_strcredi = tot_strcredi + gnmvspb.vllanmto.

                        /* Despreza mensagens isentas de TIB */
                        IF NOT (gnmvspb.dsmensag = "STR0007R2"      AND 
                                gnmvspb.dsinstdb = "00360305"       AND
                               (aux_cdfinmsg = 22  OR
                                aux_cdfinmsg = 28  OR
                                aux_cdfinmsg = 29  OR
                                aux_cdfinmsg = 36  OR
                                aux_cdfinmsg = 37))                 AND
                           NOT (gnmvspb.dsmensag = "STR0008R2"      AND 
                                gnmvspb.dsinstdb = "00000000"       AND
                               (aux_cdfinmsg = 300 OR
                                aux_cdfinmsg = 301))                AND
                           NOT (gnmvspb.dsmensag = "STR0025R2")     AND
                           NOT (gnmvspb.dsmensag = "STR0039R2")   THEN
                           ASSIGN qtd_strcredi = qtd_strcredi + 1.  
                    END.
                ELSE
                IF   CAN-DO("STR0010R2",gnmvspb.dsmensag)  THEN
                     ASSIGN tot_strdevcr = tot_strdevcr + gnmvspb.vllanmto.
                ELSE 
                                          
                /* TED/TEC  Recebidos PAG  */
                IF   CAN-DO("PAG0108R2,PAG0137R2," +
                            "PAG0107R2,PAG0121R2," +
                            "PAG0134R2,PAG0142R2,PAG0143R2",gnmvspb.dsmensag)
                              THEN  
                    DO:
                        ASSIGN tot_pagcredi = tot_pagcredi + gnmvspb.vllanmto.
                        
                        /* Despreza mensagens isentas de TIB */
                        IF NOT (gnmvspb.dsmensag = "PAG0108R2"  AND 
                                gnmvspb.dsinstdb = "00000000"   AND
                               (aux_cdfinmsg = 300  OR
                                aux_cdfinmsg = 301))        
                              AND
                           NOT (gnmvspb.dsmensag = "PAG0143R2"  AND 
                                gnmvspb.dsinstdb = "00360305"   AND
                               (aux_cdfinmsg = 22  OR
                                aux_cdfinmsg = 28  OR
                                aux_cdfinmsg = 29  OR
                                aux_cdfinmsg = 36  OR
                                aux_cdfinmsg = 37))   THEN
                            ASSIGN qtd_pagcredi = qtd_pagcredi + 1.      
                    END.
                ELSE
                IF   CAN-DO("PAG0111R2",gnmvspb.dsmensag)  THEN
                     ASSIGN tot_pagdevcr = tot_pagdevcr + gnmvspb.vllanmto. 
                ELSE
                
                /* TED/TEC Enviados STR */
                IF   CAN-DO("STR0008,STR0005,STR0037," +
                            "STR0006,STR0025,STR0034",
                            gnmvspb.dsmensag)  THEN
                     DO:
                         IF   gnmvspb.dsareneg = "MATERA" THEN
                              ASSIGN tot_vldebmat = tot_vldebmat + gnmvspb.vllanmto.
                         ELSE
                         ASSIGN tot_strdebit = tot_strdebit + gnmvspb.vllanmto.

                         IF   gnmvspb.dsmensag <> "STR0025" THEN
                              ASSIGN qtd_strdebit = qtd_strdebit + 1.
                     END.
                ELSE
                IF   CAN-DO("STR0010",gnmvspb.dsmensag)  THEN
                    ASSIGN tot_strdevdb = tot_strdevdb + gnmvspb.vllanmto.
                    
                ELSE
                
                /* TED/TEC Enviados PAG */
                IF   CAN-DO("PAG0108,PAG0107,PAG0137," +
                            "PAG0121,PAG0134",
                             gnmvspb.dsmensag)  THEN  
                     ASSIGN tot_pagdebit = tot_pagdebit + gnmvspb.vllanmto
                            qtd_pagdebit = qtd_pagdebit + 1.
                ELSE
                IF   CAN-DO("PAG0111",gnmvspb.dsmensag)  THEN
                     ASSIGN tot_pagdevdb = tot_pagdevdb + gnmvspb.vllanmto.
            END.

       IF   LAST-OF(gnmvspb.cdagenci) THEN 
            DO:
                IF   qtd_strcredi + qtd_pagcredi <> 0  THEN
                     RUN pi_cria_tab_tarifas(INPUT gnmvspb.cdagenci,
                                             INPUT 14, /* 14 - TED/TEC Cred */
                                             INPUT qtd_strcredi + qtd_pagcredi,
                                             INPUT (qtd_strcredi + 
                                                    qtd_pagcredi) * 
                                                    gncdtrf.vltedtec,
                                             INPUT 0,
                                             INPUT gncdtrf.vltedtec).
                
                IF   qtd_strdebit + qtd_pagdebit <> 0  THEN
                     RUN pi_cria_tab_tarifas(INPUT gnmvspb.cdagenci,
                                             INPUT 15, /* 15 - TED/TEC Deb  */
                                             INPUT qtd_strdebit + qtd_pagdebit,
                                             INPUT (qtd_strdebit + 
                                                    qtd_pagdebit) * 
                                                    gncdtrf.vltedtec,
                                             INPUT 0,
                                             INPUT gncdtrf.vltedtec).
                
            END. /* END do LAST-OF */
   END. /* END do FOREACH */

   /* Criando LCM para valor somado 
      Cooperativa RECEBE pelas mensagens recebidas e PAGA pelas enviadas */
   IF   tot_strcredi <> 0  THEN
        RUN pi_cria_craplcm (INPUT tot_strcredi,
                             INPUT 797).
                             
   /* Devolucoes recebidas */ 
   IF   tot_strdevcr <> 0 THEN   
        RUN pi_cria_craplcm (INPUT tot_strdevcr,
                             INPUT 802).                          
                        
   IF   tot_strdebit <> 0  THEN
        RUN pi_cria_craplcm (INPUT tot_strdebit,
                             INPUT 795).
                             
   IF   tot_vldebmat <> 0  THEN
        RUN pi_processa_matera(INPUT tot_vldebmat).
                             
   /* Devolucoes enviadas */ 
   IF   tot_strdevdb <> 0 THEN   
        RUN pi_cria_craplcm (INPUT tot_strdevdb,
                             INPUT 884).                          
                        
   IF   tot_pagcredi <> 0  THEN
        RUN pi_cria_craplcm (INPUT tot_pagcredi,
                             INPUT 798).
                             
   /* Devolucoes recebidas */ 
   IF   tot_pagdevcr <> 0 THEN   
        RUN pi_cria_craplcm (INPUT tot_pagdevcr,
                             INPUT 803). 
                                                       
   IF   tot_pagdebit <> 0  THEN
        RUN pi_cria_craplcm (INPUT tot_pagdebit,
                             INPUT 796).
                             
   /* Devolucoes enviadas */ 
   IF   tot_pagdevdb <> 0 THEN   
        RUN pi_cria_craplcm (INPUT tot_pagdevdb,
                             INPUT 885).                          

END PROCEDURE.

/*............................................................................*/

PROCEDURE pi_processa_icf:

   DEF INPUT PARAM par_temassoc AS LOG                   NO-UNDO.

   DEF         VAR qtd_totalicf AS INT                   NO-UNDO.

           
   /* Acumular variaveis */
   FOR EACH gncpicf WHERE gncpicf.cdcooper = crapcop.cdcooper  AND
                          gncpicf.dtmvtolt = glb_dtmvtolt NO-LOCK
                          BREAK BY gncpicf.cdagenci:

       IF   FIRST-OF(gncpicf.cdagenci) THEN
            ASSIGN qtd_totalicf = 0.
    
       IF   par_temassoc THEN
            ASSIGN qtd_totalicf = qtd_totalicf + 1.
       ELSE 
            DO:
                FIND bgncpicf WHERE RECID(bgncpicf) = RECID(gncpicf) 
                                    EXCLUSIVE-LOCK NO-ERROR.
              
                IF   AVAILABLE bgncpicf   THEN 
                     DO:
                         ASSIGN  bgncpicf.cdcrictl = 9.
                         RELEASE bgncpicf.
                     END.
            END.

       IF   LAST-OF(gncpicf.cdagenci) THEN 
            DO:
                IF   qtd_totalicf <> 0  THEN
                     RUN pi_cria_tab_tarifas(INPUT gncpicf.cdagenci,
                                             INPUT 13, /* 13 - ICF   */
                                             INPUT qtd_totalicf,
                                             INPUT qtd_totalicf *
                                                   gncdtrf.vltrficf,
                                             INPUT 0,
                                             INPUT gncdtrf.vltrficf).
            END. /* END do LAST-OF */
   END. /* END do FOREACH */


END PROCEDURE.
              
/*............................................................................*/

PROCEDURE pi_processa_ccf:

    DEFINE VARIABLE aux_qtpacccf AS INTEGER     NO-UNDO.
    DEFINE VARIABLE aux_qttotccf AS INTEGER     NO-UNDO.
    
    EMPTY TEMP-TABLE tt-agenciccf.

    ASSIGN aux_qttotccf = 0.

    IF  NOT VALID-HANDLE(h-b1wgen0153) THEN
        RUN sistema/generico/procedures/b1wgen0153.p
            PERSISTENT SET h-b1wgen0153.

    RUN carrega_dados_tarifa_vigente IN h-b1wgen0153
                                    (INPUT  crapcop.cdcooper,
                                     INPUT  "EXCLUCCFPJ", /*Juridica*/
                                     INPUT  1, /*vllanmto*/
                                     INPUT  glb_cdprogra, /* cdprogra */
                                     OUTPUT aux_cdhistpj,
                                     OUTPUT aux_cdhisest,
                                     OUTPUT aux_vltaripj,
                                     OUTPUT aux_dtdivulg,
                                     OUTPUT aux_dtvigenc,
                                     OUTPUT aux_cdfvlcpj,
                                     OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
           FIND FIRST tt-erro NO-LOCK NO-ERROR.

           IF AVAIL tt-erro THEN 
              UNIX SILENT VALUE("echo " + STRING(TODAY,"99/99/9999") +
                                " - "   + STRING(TIME,"HH:MM:SS")    +
                                " - "   + glb_cdprogra + "' --> '"   + 
                                tt-erro.dscritic + " >> log/proc_message.log").
        END.

    RUN carrega_dados_tarifa_vigente IN h-b1wgen0153
                                    (INPUT  crapcop.cdcooper,
                                     INPUT  "EXCLUCCFPF", /*Fisica */
                                     INPUT  1, /*vllanmto*/
                                     INPUT  glb_cdprogra, /* cdprogra */
                                     OUTPUT aux_cdhistpf,
                                     OUTPUT aux_cdhisest,
                                     OUTPUT aux_vltaripf,
                                     OUTPUT aux_dtdivulg,
                                     OUTPUT aux_dtvigenc,
                                     OUTPUT aux_cdfvlcpf,
                                     OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
           FIND FIRST tt-erro NO-LOCK NO-ERROR.
   
           IF AVAIL tt-erro THEN
              UNIX SILENT VALUE("echo " + STRING(TODAY,"99/99/9999") +
                                " - "   + STRING(TIME,"HH:MM:SS")    +
                                " - "   + glb_cdprogra + "' --> '"   +
                                tt-erro.dscritic + " >> log/proc_message.log").
        END.

    IF  VALID-HANDLE(h-b1wgen0153) THEN
        DELETE OBJECT h-b1wgen0153.
   
    FOR EACH craplcm WHERE (craplcm.cdcooper = crapcop.cdcooper AND
                            craplcm.dtmvtolt = glb_dtmvtolt     AND
                            craplcm.cdhistor = aux_cdhistpf)    OR
                           (craplcm.cdcooper = crapcop.cdcooper AND
                            craplcm.dtmvtolt = glb_dtmvtolt     AND
                            craplcm.cdhistor = aux_cdhistpj)    
                            NO-LOCK,
        FIRST crapass WHERE crapass.cdcooper = craplcm.cdcooper AND
                            crapass.nrdconta = craplcm.nrdconta NO-LOCK:
        
        CREATE tt-agenciccf.
        ASSIGN tt-agenciccf.cdagenci = crapass.cdagenci.

    END.
     
    FOR EACH tt-agenciccf NO-LOCK BREAK BY tt-agenciccf.cdagenci:
   
        IF  FIRST-OF(tt-agenciccf.cdagenci)  THEN
            ASSIGN aux_qtpacccf = 0.
     
        ASSIGN aux_qtpacccf = aux_qtpacccf + 1
               aux_qttotccf = aux_qttotccf + 1.
     
        IF  LAST-OF(tt-agenciccf.cdagenci)  THEN 
            DO:
                IF  aux_qtpacccf > 0  THEN
                    RUN pi_cria_tab_tarifas (INPUT tt-agenciccf.cdagenci,
                                             INPUT 18, /* 18 - CCF */
                                             INPUT aux_qtpacccf,
                                             INPUT aux_qtpacccf *
                                                   gncdtrf.vltrfccf,
                                             INPUT 0,
                                             INPUT gncdtrf.vltrfccf).
            END.
   
    END.
    
    RETURN "OK".

END PROCEDURE.

/*............................................................................*/

PROCEDURE pi_processa_tic:

    DEF INPUT PARAM par_cdcooper    LIKE    crapcop.cdcooper        NO-UNDO.

    DEFINE VARIABLE aux_qtpactic AS INTEGER     NO-UNDO.
           
    FOR EACH gncptic WHERE gncptic.cdcooper = par_cdcooper     AND
                           gncptic.dttransa = glb_dtmvtolt     AND
                           gncptic.cdtipreg = 1                AND /* NR */
                           gncptic.cdtipdoc = 960          NO-LOCK /* Inclusao */
                           BREAK BY gncptic.cdagenci:
    
        IF   FIRST-OF(gncptic.cdagenci)  THEN
             ASSIGN aux_qtpactic = 0.
    
        ASSIGN aux_qtpactic = aux_qtpactic + 1.
    
        IF   LAST-OF(gncptic.cdagenci)  THEN 
             DO:
                 IF   aux_qtpactic > 0  THEN
                      RUN pi_cria_tab_tarifas(INPUT gncptic.cdagenci,
                                              INPUT 25, /* 25 - TIC */
                                              INPUT aux_qtpactic,
                                              INPUT aux_qtpactic *
                                                    gncdtrf.vltrftic,
                                              INPUT 0,
                                              INPUT gncdtrf.vltrftic).
                     
             END. /* END do LAST-OF */
    END. /* END do FOREACH */
    
END PROCEDURE.

/*............................................................................*/

PROCEDURE pi_cria_craplcm:

   DEF INPUT PARAM par_vlrlamto AS DEC                       NO-UNDO.
   DEF INPUT PARAM par_cdhistor AS INT                       NO-UNDO.

   IF  aux_flgfirst  THEN DO:

       FIND craplot WHERE craplot.cdcooper = crabcop.cdcooper AND
                          craplot.dtmvtolt = glb_dtmvtolt     AND
                          craplot.cdagenci = aux_cdagenci     AND
                          craplot.cdbccxlt = aux_cdbccxlt     AND
                          craplot.nrdolote = aux_nrdolote
                          USE-INDEX craplot1 NO-LOCK NO-ERROR.
    
       IF   NOT AVAIL craplot  THEN
            DO:
                CREATE craplot.
                ASSIGN craplot.cdcooper = crabcop.cdcooper
                       craplot.dtmvtolt = glb_dtmvtolt
                       craplot.cdagenci = aux_cdagenci
                       craplot.cdbccxlt = aux_cdbccxlt
                       craplot.nrdolote = aux_nrdolote
                       craplot.tplotmov = aux_tplotmov.
                VALIDATE craplot.
            END.
           
       ASSIGN aux_flgfirst = FALSE.

   END. /* FIM do IF flgfirst */
   
   FIND craplot WHERE craplot.cdcooper = crabcop.cdcooper AND
                      craplot.dtmvtolt = glb_dtmvtolt     AND
                      craplot.cdagenci = aux_cdagenci     AND
                      craplot.cdbccxlt = aux_cdbccxlt     AND
                      craplot.nrdolote = aux_nrdolote
                      USE-INDEX craplot1 EXCLUSIVE-LOCK NO-ERROR.

   /* Verifica se possui outro lancamento com o mesmo nro documento */
   ASSIGN aux_nrdocmto = crapcop.cdagectl.

   DO WHILE TRUE:

     FIND craplcm WHERE craplcm.cdcooper = crabcop.cdcooper  AND
                        craplcm.dtmvtolt = craplot.dtmvtolt  AND
                        craplcm.cdagenci = craplot.cdagenci  AND
                        craplcm.cdbccxlt = craplot.cdbccxlt  AND
                        craplcm.nrdolote = craplot.nrdolote  AND
                        craplcm.nrdctabb = crapcop.nrctacmp  AND
                        craplcm.nrdocmto = aux_nrdocmto    
                        USE-INDEX craplcm1 NO-LOCK NO-ERROR.

     IF   AVAILABLE craplcm THEN
          DO:
              ASSIGN aux_nrdocmto = aux_nrdocmto + 1000.   
              NEXT.
          END.
     ELSE
          LEAVE.
   END.  /*  Fim do DO WHILE TRUE  */

   CREATE craplcm.
   ASSIGN craplcm.cdcooper = crabcop.cdcooper 
          craplcm.nrdconta = crapcop.nrctacmp
          craplcm.nrdctabb = crapcop.nrctacmp
          craplcm.dtmvtolt = craplot.dtmvtolt
          craplcm.dtrefere = aux_dtleiarq
          craplcm.cdagenci = craplot.cdagenci
          craplcm.cdbccxlt = craplot.cdbccxlt
          craplcm.nrdolote = craplot.nrdolote
          craplcm.nrdocmto = aux_nrdocmto
          craplcm.cdhistor = par_cdhistor
          craplcm.vllanmto = par_vlrlamto
          craplcm.nrseqdig = craplot.nrseqdig + 1.
   VALIDATE craplcm.
       
   ASSIGN craplot.qtinfoln = craplot.qtinfoln + 1
          craplot.qtcompln = craplot.qtcompln + 1
          craplot.nrseqdig = craplcm.nrseqdig.
   

   /* Historicos para Sua Remessa */
   IF   (par_cdhistor = 786) OR (par_cdhistor = 791) OR (par_cdhistor = 792) OR
        (par_cdhistor = 793) OR (par_cdhistor = 794) OR (par_cdhistor = 797) OR
        (par_cdhistor = 798) OR (par_cdhistor = 802) OR (par_cdhistor = 803)
          THEN
        ASSIGN craplot.vlinfocr = craplot.vlinfocr + craplcm.vllanmto
               craplot.vlcompcr = craplot.vlcompcr + craplcm.vllanmto.
   ELSE 
        ASSIGN craplot.vlinfodb = craplot.vlinfodb + craplcm.vllanmto
               craplot.vlcompdb = craplot.vlcompdb + craplcm.vllanmto.
             
   /* Cria Temp-Table para Relatorio */
   RUN pi_cria_tt (INPUT par_vlrlamto,
                   INPUT par_cdhistor).

END PROCEDURE.

/*............................................................................*/

PROCEDURE pi_cria_tab_tarifas:

   DEF INPUT PARAM par_cdagenci AS INT                       NO-UNDO.
   DEF INPUT PARAM par_cdtipdoc AS INT                       NO-UNDO.
   DEF INPUT PARAM par_qtdocmto AS INT                       NO-UNDO.
   DEF INPUT PARAM par_vldocmto AS DEC                       NO-UNDO.
   DEF INPUT PARAM par_cdalinea AS INT                       NO-UNDO.
   DEF INPUT PARAM par_vltarifa AS DEC                       NO-UNDO.

   DEF         VAR aux_tplanmto AS CHAR                      NO-UNDO.
   DEF         VAR aux_dtmvttar AS DATE                      NO-UNDO.

   /* tarifas SPB - D+0 (14, 15, 16 e 17) */
   IF  par_cdtipdoc >= 14 AND par_cdtipdoc <= 17 THEN
       DO:
           IF  glb_nmtelant = "COMPEFORA"   THEN
               ASSIGN aux_dtmvttar = glb_dtmvtoan.
           ELSE
               ASSIGN aux_dtmvttar = glb_dtmvtolt.          
       END.
   ELSE
       DO:
           /* as demais tarifas D+1 */
            IF  glb_nmtelant = "COMPEFORA"   THEN
                ASSIGN aux_dtmvttar = glb_dtmvtolt.
            ELSE
                ASSIGN aux_dtmvttar = glb_dtmvtopr.          
       END.                   

   FIND gntarcp WHERE gntarcp.cdcooper = crapcop.cdcooper AND 
                      gntarcp.dtmvtolt = aux_dtmvttar     AND
                      gntarcp.cdtipdoc = par_cdtipdoc     AND
                      gntarcp.cdagenci = par_cdagenci     AND
                      gntarcp.cdagectl = crapcop.cdagectl AND
                      gntarcp.cdalinea = par_cdalinea
                      EXCLUSIVE-LOCK NO-ERROR.
                      
   IF   NOT AVAILABLE gntarcp THEN
        DO:
            CREATE gntarcp.
            ASSIGN gntarcp.cdcooper = crapcop.cdcooper
                   gntarcp.dtmvtolt = aux_dtmvttar
                   gntarcp.cdagenci = par_cdagenci
                   gntarcp.cdagectl = crapcop.cdagectl
                   gntarcp.cdtipdoc = par_cdtipdoc
                   gntarcp.cdalinea = par_cdalinea.
        END.              
   
   ASSIGN gntarcp.qtdocmto = gntarcp.qtdocmto + par_qtdocmto
          gntarcp.vldocmto = gntarcp.vldocmto + par_vldocmto
          gntarcp.vltarifa = gntarcp.vltarifa + par_vltarifa.
   VALIDATE gntarcp.
    /* GNTARCP - Valores possiveis para cdtipdoc */
    /* Para os lançamentos das Tarifas (gntarcp) */
    /* 01 - Cheque Inferior Nossa Remessa        */
    /* 02 - Cheque Superior Nossa Remessa        */
    /* 03 - Titulo/Cobrança Nossa Remessa        */
    /* 04 - Titulo/Cobrança VLB Nossa Remessa    */
    /* 05 - DOC Nossa Remessa                    */
    /* 06 - Cheque Inferior Sua Remessa          */
    /* 07 - Cheque Superior Sua Remessa          */
    /* 08 - DOC Sua Remessa                      */
    /* 09 - Devolução Nossa Remessa Noturna      */
    /* 10 - Devolução Nossa Remessa Diurna       */
    /* 11 - Cheque Roubado Nossa Remessa         */
    /* 12 - Cheque Roubado Sua Remessa           */
    /* 13 - ICF                                  */
    /* 14 - TED/TEC Credito                      */
    /* 15 - TED/TEC Debito                       */
    /* 16 - DEV TED/TEC Credito - ??????????     */
    /* 17 - DEV TED/TEC Debito  - ??????????     */
    /* 18 - CCF                                  */
    /* 19 - Titulo/Cobranca Sua Remessa          */
    /* 20 - Titulo/Cobranca VLB Sua Remessa      */
    /* 21 - Titulo/Cobranca NR DDA               */
    /* 22 - Titulo/Cobranca VLB NR DDA           */
    /* 23 - Titulo/Cobranca SR DDA               */
    /* 24 - Titulo/Cobranca VLB SR DDA           */
    /* 25 - TIC                                  */
    /* 26 - Titulo SR Epr                        */
    /* 27 - Titulo VLB SR Epr                    */
    /* 28 - Titulo SR Epr DDA                    */
    /* 29 - Titulo VLB SR Epr DDA                */

END PROCEDURE.

/* ......................................................................... */

PROCEDURE pi_cria_tt:

   DEF INPUT PARAM par_vlrlamto AS DEC                       NO-UNDO.
   DEF INPUT PARAM par_cdhistor AS INT                       NO-UNDO.

   DEF         VAR aux_dshistor AS CHAR                      NO-UNDO.

   FIND craphis WHERE craphis.cdcooper = glb_cdcooper AND 
                      craphis.cdhistor = par_cdhistor NO-LOCK NO-ERROR.

   IF   NOT AVAIL craphis THEN
        ASSIGN aux_dshistor = STRING(par_cdhistor) + "-" +
                              "Historico nao encontrado".
   ELSE
        ASSIGN aux_dshistor = STRING(craphis.cdhistor) + "-" + craphis.dshistor.

   CREATE w-acumular.
   ASSIGN w-acumular.cdlanmto = aux_nrdocmto
          w-acumular.nrdconta = crapcop.nrctacmp
          w-acumular.tplanmto = craphis.indebcre   
          w-acumular.nmprimtl = crapass.nmprimtl
          w-acumular.dshistor = aux_dshistor
          w-acumular.vllanmto = par_vlrlamto

          w-acumular.vllancre = IF   craphis.indebcre = "C" THEN
                                     par_vlrlamto
                                ELSE 0
          w-acumular.vllandeb = IF   craphis.indebcre = "D" THEN
                                     par_vlrlamto
                                ELSE 0.
END.


PROCEDURE atualiza_registros:

    DEF VAR aux_ponteiro    AS INT                                      NO-UNDO.

    /* Atualiza todas cooperativas ativas, exceto 3 [Cecred] */
     FOR EACH crapcop  WHERE crapcop.cdcooper <> 3 AND 
                             crapcop.flgativo      NO-LOCK:

         FOR EACH gncpchq WHERE gncpchq.cdcooper = crapcop.cdcooper AND
                                gncpchq.dtliquid = glb_dtmvtolt     AND
                                gncpchq.cdtipreg = 2                AND
                                gncpchq.flgpcctl = FALSE            
                                EXCLUSIVE-LOCK TRANSACTION ON ERROR UNDO, RETRY:

             ASSIGN gncpchq.flgpcctl = TRUE.
         END.

         FOR EACH gncpchq WHERE gncpchq.cdcooper = crapcop.cdcooper AND
                                gncpchq.dtliquid = glb_dtmvtolt     AND
                               (gncpchq.cdtipreg = 4                OR
                                gncpchq.cdtipreg = 3)               AND
                                gncpchq.flgpcctl = FALSE
                                EXCLUSIVE-LOCK TRANSACTION ON ERROR UNDO, RETRY:

             ASSIGN gncpchq.flgpcctl = TRUE.
         END.

         FOR EACH gncptit WHERE gncptit.cdcooper = crapcop.cdcooper AND
                                gncptit.dtliquid = glb_dtmvtolt     AND
                                gncptit.cdtipreg = 2                AND
                                gncptit.flgpcctl = FALSE            
                                EXCLUSIVE-LOCK TRANSACTION ON ERROR UNDO, RETRY:

             ASSIGN gncptit.flgpcctl = TRUE.
         END.

         FOR EACH gncpdoc WHERE gncpdoc.cdcooper = crapcop.cdcooper AND
                                gncpdoc.dtliquid = glb_dtmvtolt     AND
                                gncpdoc.cdtipreg = 2                AND
                                gncpdoc.flgpcctl = FALSE
                                EXCLUSIVE-LOCK TRANSACTION ON ERROR UNDO, RETRY:

             ASSIGN gncpdoc.flgpcctl = TRUE.
         END.

         FOR EACH gncpdoc WHERE gncpdoc.cdcooper = crapcop.cdcooper AND
                                gncpdoc.dtliquid = glb_dtmvtolt     AND
                               (gncpdoc.cdtipreg = 4                OR
                                gncpdoc.cdtipreg = 3)               AND
                                gncpdoc.flgpcctl = FALSE            
                                EXCLUSIVE-LOCK TRANSACTION ON ERROR UNDO, RETRY:

             ASSIGN gncpdoc.flgpcctl = TRUE.
         END.

         FOR EACH gncpdev WHERE gncpdev.cdcooper = crapcop.cdcooper AND
                                gncpdev.dtliquid = glb_dtmvtolt     AND
                                gncpdev.cdtipreg = 2                AND
                                gncpdev.cdalinea <> 0               AND
                                gncpdev.flgpcctl = FALSE            
                                EXCLUSIVE-LOCK TRANSACTION ON ERROR UNDO, RETRY:

             ASSIGN gncpdev.flgpcctl = TRUE.
         END.

         FOR EACH gncpdev WHERE gncpdev.cdcooper = crapcop.cdcooper AND
                                gncpdev.dtliquid = glb_dtmvtolt     AND
                               (gncpdev.cdtipreg = 4                OR
                                gncpdev.cdtipreg = 3)               AND
                                gncpdev.cdalinea <> 0               AND
                                gncpdev.flgpcctl = FALSE            
                                EXCLUSIVE-LOCK TRANSACTION ON ERROR UNDO, RETRY:

             ASSIGN gncpdev.flgpcctl = TRUE.
         END.
         
         { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
                        
         RUN STORED-PROC {&sc2_dboraayl}.send-sql-statement
             aux_ponteiro = PROC-HANDLE
                     ("UPDATE gncpdvc dvc SET dvc.flgpcctl = 1
                        WHERE dvc.cdcooper = " + STRING(crapcop.cdcooper) + "
                          AND dvc.dtmvtolt = TO_DATE('" + 
                                    STRING(glb_dtmvtolt,'99/99/9999') + "','DD/MM/RRRR')
                          AND dvc.flgconci = 1
                          AND dvc.flgpcctl = 0").                    
                                                    
         CLOSE STORED-PROC {&sc2_dboraayl}.send-sql-statement
               WHERE PROC-HANDLE = aux_ponteiro.
                                       
         { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
         
     END.
END.

/* .......................................................................... */

/* Para os registros da gnmvspb com STR0026 (VR Boletos enviados ou pagos) e
STR0026R2 (VR Boletos recebidos), totalizar os valores e chamar a procedure
pi_cria_craplcm */
PROCEDURE pi_processa_vr_boleto:

    DEF VAR tot_strenvvr AS DECI INIT 0 NO-UNDO.
    DEF VAR tot_strrecvr AS DECI INIT 0 NO-UNDO.

    FOR EACH gnmvspb WHERE gnmvspb.cdcooper = crapcop.cdcooper AND
                          (gnmvspb.dsmensag = "STR0026" OR 
                           gnmvspb.dsmensag = "STR0026R2")     AND 
                           gnmvspb.dtmvtolt = glb_dtmvtolt     NO-LOCK:

        IF gnmvspb.dsmensag = "STR0026" THEN
            tot_strenvvr = tot_strenvvr + gnmvspb.vllanmto.
        ELSE
            tot_strrecvr = tot_strrecvr + gnmvspb.vllanmto.

    END.

    IF  tot_strenvvr > 0  THEN
        RUN pi_cria_craplcm (INPUT tot_strenvvr,
                             INPUT 1156).

    IF  tot_strrecvr > 0  THEN
        RUN pi_cria_craplcm (INPUT tot_strrecvr,
                             INPUT 1157).

END PROCEDURE.


/* ....................................................................... */
/*               Soma os lancamentos de devolucao de DOC                   */
/* ....................................................................... */
PROCEDURE pi_processa_dev_doc:
    
    DEF INPUT PARAM par_cdcooper        AS  INTE                    NO-UNDO.
    DEF INPUT PARAM par_dtmvtoan        AS  DATE                    NO-UNDO.

    DEF VAR aux_vltotlan        AS  DECI                            NO-UNDO.

    ASSIGN aux_vltotlan = 0.

    /*mensagem pra ver que data esta pegando quando rodar o processo*/
    UNIX SILENT VALUE("echo " + STRING(TODAY,"99/99/9999") + 
                       " - "  + STRING(TIME,"HH:MM:SS")  + 
                       " - "  + glb_cdprogra + "' --> '" + 
                       " Procurando dados na gncpddc com a data " +
                       STRING(par_dtmvtoan,"99/99/9999") + " glb_dtmvtoan: " +
                       STRING(glb_dtmvtoan,"99/99/9999") +
                       " >> log/proc_message.log").


    FOR EACH gncpddc WHERE gncpddc.cdcooper = par_cdcooper AND
                           gncpddc.dtmvtolt = par_dtmvtoan AND
                           gncpddc.cdtipreg = 2       NO-LOCK:
        ASSIGN aux_vltotlan = aux_vltotlan + gncpddc.vldocmto.
    END.

    IF  aux_vltotlan > 0  THEN
        RUN pi_cria_craplcm (INPUT aux_vltotlan, /*total lanc.*/
                             INPUT 574).         /*cdhistor*/

    RETURN "OK".
END PROCEDURE.


/* ....................................................................... */
/*               Processa os lancamentos de Portabilidade                  */
/* ....................................................................... */
PROCEDURE pi_processa_portabilidade:

    ASSIGN aux_cdbccxlt = 85
           aux_nrdolote = 600030
           aux_cdhistor = 1917.

    FIND craplot WHERE craplot.cdcooper = crabcop.cdcooper AND
                       craplot.dtmvtolt = glb_dtmvtolt     AND
                       craplot.cdagenci = aux_cdagenci     AND
                       craplot.cdbccxlt = aux_cdbccxlt   AND
                       craplot.nrdolote = aux_nrdolote
                       USE-INDEX craplot1 NO-LOCK NO-ERROR.

    IF   NOT AVAIL craplot  THEN
         DO:
             CREATE craplot.
             ASSIGN craplot.cdcooper = crabcop.cdcooper
                    craplot.dtmvtolt = glb_dtmvtolt
                    craplot.cdagenci = aux_cdagenci
                    craplot.cdbccxlt = aux_cdbccxlt
                    craplot.nrdolote = aux_nrdolote
                    craplot.tplotmov = aux_tplotmov.
             VALIDATE craplot.
         END.

    FIND craplot WHERE craplot.cdcooper = crabcop.cdcooper AND
                       craplot.dtmvtolt = glb_dtmvtolt     AND
                       craplot.cdagenci = aux_cdagenci     AND
                       craplot.cdbccxlt = aux_cdbccxlt     AND
                       craplot.nrdolote = aux_nrdolote
                       USE-INDEX craplot1 EXCLUSIVE-LOCK NO-ERROR.

    FOR EACH gnmvspb WHERE gnmvspb.cdcooper = crabcop.cdcooper  AND 
                           gnmvspb.dsmensag = "STR0047"         AND 
                           gnmvspb.dtmvtolt = glb_dtmvtolt      NO-LOCK:

         CREATE craplcm.
         ASSIGN craplcm.cdcooper = crabcop.cdcooper
                craplcm.cdagenci = aux_cdagenci
                craplcm.cdbccxlt = aux_cdbccxlt
                craplcm.nrdolote = aux_nrdolote
                craplcm.cdhistor = aux_cdhistor
                craplcm.dtrefere = aux_dtleiarq
                craplcm.vllanmto = gnmvspb.vllanmto
                craplcm.nrdconta = INTE(gnmvspb.dscntadb)
                craplcm.nrdctabb = INTE(gnmvspb.dscntadb)
                craplcm.dtmvtolt = craplot.dtmvtolt
                craplcm.nrdocmto = craplot.nrseqdig + 1
                craplcm.nrseqdig = craplot.nrseqdig + 1.
          VALIDATE craplcm.
       
          ASSIGN craplot.qtinfoln = craplot.qtinfoln + 1
                 craplot.qtcompln = craplot.qtcompln + 1
                 craplot.nrseqdig = craplcm.nrseqdig
                 craplot.vlinfodb = craplot.vlinfodb + craplcm.vllanmto
                 craplot.vlcompdb = craplot.vlcompdb + craplcm.vllanmto.

    END.

END PROCEDURE.


/* ....................................................................... */
/*               Processa o lancamento do Sistema MATERA                   */
/* ....................................................................... */
PROCEDURE pi_processa_matera:

   DEF INPUT PARAM par_vlrlamto AS DEC                       NO-UNDO.

    ASSIGN aux_cdbccxlt = 85
           aux_nrdolote = 600034
           aux_cdhistor = 2217.

    FIND craplot WHERE craplot.cdcooper = crabcop.cdcooper AND
                       craplot.dtmvtolt = glb_dtmvtolt     AND
                       craplot.cdagenci = aux_cdagenci     AND
                       craplot.cdbccxlt = aux_cdbccxlt   AND
                       craplot.nrdolote = aux_nrdolote
                       USE-INDEX craplot1 NO-LOCK NO-ERROR.

    IF   NOT AVAIL craplot  THEN
         DO:
             CREATE craplot.
             ASSIGN craplot.cdcooper = crabcop.cdcooper
                    craplot.dtmvtolt = glb_dtmvtolt
                    craplot.cdagenci = aux_cdagenci
                    craplot.cdbccxlt = aux_cdbccxlt
                    craplot.nrdolote = aux_nrdolote
                    craplot.tplotmov = aux_tplotmov.
             VALIDATE craplot.
         END.

    FIND craplot WHERE craplot.cdcooper = crabcop.cdcooper AND
                       craplot.dtmvtolt = glb_dtmvtolt     AND
                       craplot.cdagenci = aux_cdagenci     AND
                       craplot.cdbccxlt = aux_cdbccxlt     AND
                       craplot.nrdolote = aux_nrdolote
                       USE-INDEX craplot1 EXCLUSIVE-LOCK NO-ERROR.

    CREATE craplcm.
    ASSIGN craplcm.cdcooper = crabcop.cdcooper
           craplcm.cdagenci = aux_cdagenci
           craplcm.cdbccxlt = aux_cdbccxlt
           craplcm.nrdolote = aux_nrdolote
           craplcm.cdhistor = aux_cdhistor
           craplcm.dtrefere = aux_dtleiarq
           craplcm.vllanmto = par_vlrlamto
           craplcm.nrdconta = INTE(gnmvspb.dscntadb)
           craplcm.nrdctabb = INTE(gnmvspb.dscntadb)
           craplcm.dtmvtolt = craplot.dtmvtolt
           craplcm.nrdocmto = craplot.nrseqdig + 1
           craplcm.nrseqdig = craplot.nrseqdig + 1.
    VALIDATE craplcm.

    ASSIGN craplot.qtinfoln = craplot.qtinfoln + 1
           craplot.qtcompln = craplot.qtcompln + 1
           craplot.nrseqdig = craplcm.nrseqdig
           craplot.vlinfodb = craplot.vlinfodb + craplcm.vllanmto
           craplot.vlcompdb = craplot.vlcompdb + craplcm.vllanmto.

END PROCEDURE.

