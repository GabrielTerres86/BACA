/* ..........................................................................
   Programa: Fontes/crps198.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Odair
   Data    : Junho/97                        Ultima atualizacao: 03/06/2016

   Dados referentes ao programa:

   Frequencia: Diario.
   Objetivo  : Atende a solicitacao 001.
               Debitar em conta corrente as prestacoes de emprestimos nao
               cobrados na folha de pagamento
               Emite relatorio 156.

   Alteracoes: 04/08/97 - Alterado para ler pela empresa do convenio (Deborah)

               27/08/97 - Alterado para tratar crapavs.flgproce (Deborah).

               16/02/98 - Alterar a data final do CPMF (Odair)

               19/02/98 - Alterado para nao listar os debitos a menor (Edson).

               17/03/98 - Colocado o codigo da empresa no relatorio (Deborah).

               27/04/98 - Tratamento para milenio e troca para V8 (Margarete).

               29/06/98 - Alterado para NAO tratar o historico 289 (Edson).

               09/12/98 - Eliminado erro de execucao (array 0). Nao verificava
                          se haviam avisos de debito e indexava com agencia 0.
                          (Deborah).

               07/06/1999 - Tratar CPMF (Deborah).

               26/03/2003 - Incluir tratamento da Concredi (Margarete).

               22/09/2004 - Incluidos historicos 498/500(CI)(Mirtes)

               30/06/2005 - Alimentado campo cdcooper das tabelas craplot
                            e craplcm (Diego).

               15/07/2005 - Calculo do abono da cpmf deve enxergar a data
                            de inicio, tab_dtiniabo. Usa craplcm.dtrefere
                            com craprda.dtmvtolt para pegar se lancamento com
                            abono ou nao (Margarete).

               10/12/2005 - Atualizar craplcm.nrdctitg (Magui).
               
               16/02/2006 - Unificacao dos bancos - SQLWorks - Eder

               27/04/2006 - Alterado para tentar debitar todos os dias da conta
                            corrente do associado (Julio).
                          
               11/05/2006 - Alteracao do relatorio. Sair por PAC para aparecer
                            na IMPREL. "156_99" mandar para a fila de impressao
                            (Julio)

               18/05/2006 - Ajustes no relatorio, setar flgproce sempre TRUE 
                            para os crapavs.cdhistor = 108 (Julio)
                            
               06/06/2006 - Alimentar campo cdcooper da tabela crapemp (David).
               
               26/01/2007 - Nao verificar mais 
                            "SUBSTR(craptab.dstextab,23,01) = 0" para craptab
                            EXECDEBEMP, pois quando o credito do salario
                            ocorria nos ultimos dias do mes, depois da virada, 
                            o sistema nao debitava mais emprestimos
                            em atraso para funcionarios desta empresa. (Julio)
                             
               01/02/2007 - Ajustes no calculo do saldo do dia (Julio)
               
               22/05/2007 - Somente apresentar no relatorio de atrasos, 
                            emprestimos com crapavs.insitavs = 0 (Julio).

               22/02/2008 - Alterado para mostrar turno a partir de 
                            crapttl.cdturnos (Gabriel).
                                       
               08/05/2008 - Ajuste comando FIND(craphis) utilizava FOR p/ acesso
                            (Sidnei - Precise)
                            
               20/06/2008 - Incluído a chave de acesso (craphis.cdcooper = 
                            glb_cdcooper) no "find" da tabela CRAPHIS. 
                          - Kbase IT Solutions - Paulo Ricardo Maciel.
                          
               01/09/2008 - Alteracao CDEMPRES (Kbase).
               
               19/10/2009 - Alteracao Codigo Historico (Kbase).
               
               21/12/2011 - Aumentado o format do campo cdhistor
                            de "999" para "9999" (Tiago).
               
               15/08/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).
                            
               20/08/2013 - Este programa nao efetuara mais debito de cotas
                            (historico 127). Tratado tambem no relatorio 156
                            para nao listar mais estouro de cotas. (Fabricio)
                            
               29/10/2013 - Alterado totalizador de 99 para 999. (Reinert)
               
               16/01/2014 - Inclusao de VALIDATE craplot e craplcm (Carlos)
               
               03/06/2016 - Ajuste feito para carregar o nome das empresas
                            em uma temp table ao inves de carregar em um
                            array do tipo CHAR pelo fato de estar estourado
                            o valor total de 32000, conforme solicitado no
                            chamado 459142 (Kelvin).

               24/04/2017 - Nao considerar valores bloqueados na composicao de saldo disponivel
                            Heitor (Mouts) - Melhoria 440

               11/06/2018 - Ajuste para usar procedure que centraliza lancamentos na CRAPLCM 
                            [gerar_lancamento_conta_comple]. (PRJ450 - Teobaldo J - AMcom)
                            
............................................................................. */

DEF STREAM str_1.      /*  Para relatorio de rejeitados  */

{ includes/var_batch.i {1} } 

{ includes/var_cpmf.i } 

{ sistema/generico/includes/b1wgen0200tt.i }

DEF        VAR rel_nrmodulo AS INT     FORMAT "9"                     NO-UNDO.
DEF        VAR rel_nmmodulo AS CHAR    FORMAT "x(15)" EXTENT 5
                                       INIT ["DEP. A VISTA   ",
                                             "CAPITAL        ",
                                             "EMPRESTIMOS    ",
                                             "DIGITACAO      ",
                                             "GENERICO       "]       NO-UNDO.

DEF        VAR rel_nmempres AS CHAR    FORMAT "x(15)"                 NO-UNDO.
DEF        VAR rel_nmrelato AS CHAR    FORMAT "x(40)" EXTENT 5        NO-UNDO.

DEF        VAR aux_dtrefere AS DATE    FORMAT "99/99/9999"            NO-UNDO.
DEF        VAR aux_vlsldtot AS DECIMAL                                NO-UNDO.
DEF        VAR aux_cdhistor AS INT                                    NO-UNDO.
DEF        VAR aux_inhistor AS INT                                    NO-UNDO.

DEF        VAR aux_indoipmf AS INT                                    NO-UNDO.
DEF        VAR aux_vlalipmf AS DECIMAL                                NO-UNDO.
DEF        VAR aux_cfrvipmf AS DECIMAL                                NO-UNDO.

DEF        VAR aux_nmarqimp AS CHAR                                   NO-UNDO.

DEF        VAR ant_nrdconta AS INTEGER                                NO-UNDO.

DEF        VAR rel_cdturnos AS INT                                    NO-UNDO.
DEF        VAR rel_nrramemp AS INT                                    NO-UNDO.

DEF        VAR rel_nmprimtl AS CHAR                                   NO-UNDO.
DEF        VAR rel_dsempres AS CHAR    FORMAT "x(40)"  EXTENT 2000    NO-UNDO.

DEF        VAR tab_inusatab AS LOGICAL                                NO-UNDO.
DEF        VAR aux_vlabatim AS DECIMAL                                NO-UNDO.
DEF        VAR aux_vldebito AS DECIMAL                                NO-UNDO.
DEF        VAR aux_vlestdif AS DECIMAL                                NO-UNDO.
DEF        VAR aux_vldoipmf AS DECIMAL                                NO-UNDO.
DEF        VAR est_flgsomar AS LOGICAL                                NO-UNDO.
DEF        VAR est_regexist AS LOGICAL                                NO-UNDO.
DEF        VAR rel_dsagenci AS CHAR  EXTENT  1000                     NO-UNDO.

DEF        VAR aux_vldescto AS DECI                                   NO-UNDO.
DEF        VAR ass_vlestdif AS DECIMAL                                NO-UNDO.
DEF        VAR ass_vlestemp AS DECIMAL                                NO-UNDO.
DEF        VAR rel_cdagenci AS INT                                    NO-UNDO.
DEF        VAR rel_cdempres AS INT                                    NO-UNDO.
DEF        VAR rel_dshistor AS CHAR                                   NO-UNDO.
DEF        VAR avs_vlestdif AS DECI                                   NO-UNDO.

DEF        VAR rel_vlestdif AS DECIMAL                                NO-UNDO.
DEF        VAR rel_dscritic AS CHAR                                   NO-UNDO.

DEF        VAR aux_flgimpri AS LOGICAL                                NO-UNDO.
DEF        VAR aux_lsempres AS CHAR                                   NO-UNDO.
DEF        VAR aux_dsempres as CHAR   FORMAT "x(40)"                  NO-UNDO.

DEF        VAR tot_qtestemp AS INTEGER                                NO-UNDO.
DEF        VAR tot_vlestemp AS DECIMAL                                NO-UNDO.
DEF        VAR tot_vlantemp AS DECIMAL                                NO-UNDO.
DEF        VAR tot_vlavsemp AS DECIMAL                                NO-UNDO.
DEF        VAR tot_vldebemp AS DECIMAL                                NO-UNDO.                          

DEF        VAR h-b1wgen0200 AS HANDLE                                 NO-UNDO.
DEF        VAR aux_incrineg AS INT                                    NO-UNDO.
DEF        VAR aux_cdcritic AS INT                                    NO-UNDO.
DEF        VAR aux_dscritic AS CHAR                                   NO-UNDO.

DEFINE TEMP-TABLE cratest FIELD cdempres AS INTEGER
                          FIELD cdagenci AS INTEGER
                          FIELD qtestemp AS INTEGER
                          FIELD vlestemp AS DECIMAL
                          FIELD vlantemp AS DECIMAL
                          FIELD vlavsemp AS DECIMAL
                          FIELD vldebemp AS DECIMAL.                           
                          
DEF TEMP-TABLE tt-empres NO-UNDO
    FIELD cdempres  LIKE crapemp.cdempres
    FIELD dsempres  AS CHAR FORMAT "x(40)".
        
FORM rel_dsagenci[rel_cdagenci] AT   1 FORMAT "x(25)" LABEL "PA"
     aux_dtrefere               AT  53 FORMAT "99/99/9999"
                                       LABEL "DATA DE REFERENCIA"
     SKIP(1)
     WITH NO-BOX SIDE-LABELS WIDTH 132 FRAME f_agencia.

FORM " "  WITH NO-BOX NO-LABELS FRAME f_linha.

FORM "CONTA/DV   EMP RAM. TU NOME"                            AT   3
     "HISTORICO        DOCMTO SEQ.        AVISO       DEBITO" AT  56
     "ESTOURO/DIF CRITICA"                                    AT 112
     SKIP
     "----------   --- ---- -- -----------------------------"     
     "---------------- ------ ---- ------------ ------------" AT  56
     "----------- ---------"                                  AT 112 
     SKIP(1)             
     WITH NO-BOX NO-LABELS WIDTH 132 FRAME f_label_aviso.

FORM crapavs.nrdconta        FORMAT "zzzz,zzz,9"
     crapavs.cdempcnv        FORMAT "zzzz9"
     rel_nrramemp            FORMAT "zzz9"
     rel_cdturnos            FORMAT "zz"
     rel_nmprimtl            FORMAT "x(29)"
     rel_dshistor            FORMAT "x(13)"
     crapavs.nrdocmto        FORMAT "z,zzz,zz9"
     crapavs.nrseqdig        FORMAT "zzz9"
     crapavs.vllanmto        FORMAT "zzzzz,zz9.99"
     crapavs.vldebito        FORMAT "zzzzz,zz9.99"
     rel_vlestdif            FORMAT "zzzzz,zz9.99"
     rel_dscritic            FORMAT "x(9)"
     WITH NO-BOX NO-LABELS WIDTH 132 FRAME f_aviso.

FORM "------------" AT 109
     SKIP
     ass_vlestdif   AT 109 FORMAT "zzzzz,zz9.99"
     SKIP(1)
     WITH NO-BOX NO-LABELS WIDTH 132 FRAME f_total_ass.

FORM SKIP(1)
     tot_qtestemp AT  16 FORMAT "zzz,zz9"
                      LABEL "CONTAS COM ESTOURO EMPRESTIMO"
     tot_vlestemp AT  76 FORMAT "zzzzzz,zz9.99"
                      LABEL "TOTAL DO ESTOURO EMPRESTIMO"
     WITH NO-BOX SIDE-LABELS WIDTH 132 FRAME f_total_age.

FORM "EMPRESA"            AT   1
     "ESTOURO EMPRESTIMO" AT  36
     SKIP(1)
     WITH NO-BOX WIDTH 132 FRAME f_label_total.

FORM aux_dsempres                   AT   1 FORMAT "x(25)"
     cratest.qtestemp               AT  28 FORMAT "zzz,zz9"
     cratest.vlestemp               AT  37 FORMAT "zzz,zzz,zz9.99"
     WITH NO-BOX NO-LABELS WIDTH 132 FRAME f_total_ger.
     
FORM "-------  --------------" AT 28
     SKIP
     tot_qtestemp AT  28 FORMAT "zzz,zz9"         NO-LABEL
     tot_vlestemp AT  37 FORMAT "zzz,zzz,zz9.99"  NO-LABEL
     SKIP(1)
     tot_vlavsemp AT  28 FORMAT "zzz,zzz,zz9.99"  LABEL "AVISADO"
     SKIP
     tot_vldebemp AT  27 FORMAT "zzz,zzz,zz9.99"  LABEL "DEBITADO"
     SKIP
     tot_vlantemp AT  25 FORMAT "zzz,zzz,zz9.99-" LABEL "ABATIMENTO"
     WITH NO-BOX SIDE-LABELS WIDTH 132 FRAME f_total.

glb_cdprogra = "crps198".


RUN fontes/iniprg.p.

{ includes/cabrel132_1.i }          /*  Monta cabecalho do relatorio  */

IF   glb_cdcritic > 0 THEN
     RETURN.

PROCEDURE p_totaliza_pac:

  ASSIGN tot_qtestemp = 0
         tot_vlestemp = 0.  

  FOR EACH cratest WHERE cratest.cdagenci = crapavs.cdagenci  AND
                         cratest.qtestemp > 0                 NO-LOCK:
  
      ASSIGN tot_qtestemp = tot_qtestemp + cratest.qtestemp 
             tot_vlestemp = tot_vlestemp + cratest.vlestemp.
  END.
                        
  IF   LINE-COUNTER(str_1) > (PAGE-SIZE(str_1) - 2)   THEN
       DO:
           PAGE STREAM str_1.
 
           DISPLAY STREAM str_1 rel_dsagenci[rel_cdagenci]
                                aux_dtrefere WITH FRAME f_agencia.
       END.

  DISPLAY STREAM str_1 tot_qtestemp
                       tot_vlestemp WITH FRAME f_total_age.
                        
  OUTPUT STREAM str_1 CLOSE.

END. /* Procedure p_totaliza_pac */

IF    glb_dtmvtolt > 01/22/1997 AND glb_dtmvtolt < 01/24/1999 THEN
      ASSIGN aux_cfrvipmf = glb_cfrvipmf
             aux_vlalipmf = glb_vlalipmf.
ELSE
      ASSIGN aux_cfrvipmf = 1
             aux_vlalipmf = 0.

{ includes/cpmf.i } 

/*  Leitura do indicador de uso da tabela de taxa de juros para emprestimos */

FIND craptab WHERE craptab.cdcooper = glb_cdcooper  AND
                   craptab.nmsistem = "CRED"        AND
                   craptab.tptabela = "USUARI"      AND
                   craptab.cdempres = 11            AND
                   craptab.cdacesso = "TAXATABELA"  AND
                   craptab.tpregist = 0             NO-LOCK NO-ERROR.

IF   NOT AVAILABLE craptab   THEN
     tab_inusatab = FALSE.
ELSE
     tab_inusatab = IF SUBSTRING(craptab.dstextab,1,1) = "0"
                       THEN FALSE
                       ELSE TRUE.
                       
/* Verifica se lote de emprestimo e cotas existe senao cria */

FIND craplot WHERE craplot.cdcooper = glb_cdcooper  AND
                   craplot.dtmvtolt = glb_dtmvtolt  AND
                   craplot.cdagenci = 1             AND
                   craplot.cdbccxlt = 100           AND
                   craplot.nrdolote = 8453          /* EMPRESTIMOS */
                   NO-LOCK NO-ERROR .

IF   NOT AVAILABLE craplot   THEN
     DO TRANSACTION:

         CREATE craplot.
         ASSIGN craplot.dtmvtolt = glb_dtmvtolt
                craplot.cdagenci = 1
                craplot.cdbccxlt = 100
                craplot.nrdolote = 8453
                craplot.tplotmov = 5
                craplot.nrseqdig = 0
                craplot.vlcompcr = 0
                craplot.vlinfocr = 0
                craplot.cdhistor = 0
                craplot.cdoperad = "1"
                craplot.dtmvtopg = ?
                craplot.cdcooper = glb_cdcooper.
         VALIDATE craplot.

     END.

FOR EACH crapage WHERE crapage.cdcooper = glb_cdcooper NO-LOCK:

    rel_dsagenci[crapage.cdagenci] = STRING(crapage.cdagenci,"999") + " - " +
                                     crapage.nmresage.

END.  /*  Fim do FOR EACH -- Leitura do cadastro de agencias  */

FOR EACH craptab WHERE craptab.cdcooper        = glb_cdcooper   AND
                       craptab.nmsistem        = "CRED"         AND
                       craptab.tptabela        = "USUARI"       AND
                       craptab.cdacesso        = "EXECDEBEMP"   AND
                       craptab.tpregist        = 0:              

    IF   (DATE(INT(SUBSTR(craptab.dstextab,15,2)),
               INT(SUBSTR(craptab.dstextab,12,2)),
               INT(SUBSTR(craptab.dstextab,18,4))) > glb_dtmvtolt) OR
         (DATE(INT(SUBSTR(craptab.dstextab,04,2)),
               INT(SUBSTR(craptab.dstextab,01,2)),
               INT(SUBSTR(craptab.dstextab,07,4))) < glb_dtultdma) THEN
         NEXT.
  
    ASSIGN aux_dtrefere = DATE(INT(SUBSTR(craptab.dstextab,04,2)),
                              INT(SUBSTR(craptab.dstextab,01,2)),
                              INT(SUBSTR(craptab.dstextab,07,4)))
           aux_lsempres = aux_lsempres + "," + 
                          STRING(craptab.cdempres,"99999").  


    /* 11/06/20108 - TJ - Verificar se pode realizar o debito  */
    IF  NOT VALID-HANDLE(h-b1wgen0200) THEN
        RUN sistema/generico/procedures/b1wgen0200.p 
        PERSISTENT SET h-b1wgen0200.


    TRANS_1:

    FOR EACH crapavs WHERE crapavs.cdcooper = glb_cdcooper      AND
                           crapavs.dtrefere = aux_dtrefere      AND
                           crapavs.cdempcnv = craptab.cdempres  AND
                           crapavs.tpdaviso = 1                 AND
                           crapavs.insitavs = 0                 AND
                           crapavs.cdhistor = 108
                           TRANSACTION
                           BY crapavs.nrdconta
                              BY crapavs.cdhistor:

        aux_vldescto = 0.

        IF   ant_nrdconta <> crapavs.nrdconta THEN
             DO:

                 ASSIGN ant_nrdconta = crapavs.nrdconta.

                 /* Calcula o Saldo */

                 /* FIND crapsld OF crapavs NO-LOCK NO-ERROR. */
                 FIND crapsld WHERE crapsld.cdcooper = glb_cdcooper     AND
                                    crapsld.nrdconta = crapavs.nrdconta
                                    NO-LOCK NO-ERROR.

                 IF   NOT AVAILABLE crapsld THEN
                      DO:
                          glb_cdcritic = 10.
                          RUN fontes/critic.p.
                          UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                      " - " + glb_cdprogra + "' --> '" +
                                      glb_dscritic + " Conta : " +
                                      STRING(crapavs.nrdconta,"zzzz,zz9,9") +
                                      " >> log/proc_batch.log").
                          glb_cdcritic = 0.
                          RETURN.
                      END.

                 /* FIND crapass OF crapavs NO-LOCK NO-ERROR. */
                 FIND crapass WHERE crapass.cdcooper = glb_cdcooper     AND
                                    crapass.nrdconta = crapavs.nrdconta
                                    NO-LOCK NO-ERROR.

                 IF   NOT AVAILABLE crapass THEN
                      DO:
                          glb_cdcritic = 251.
                          RUN fontes/critic.p.
                          UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                     " - " + glb_cdprogra + "' --> '" +
                                     glb_dscritic + " Conta : " +
                                     STRING(crapavs.nrdconta,"zzzz,zz9,9") +
                                     " >> log/proc_batch.log").
                          glb_cdcritic = 0.
                          RETURN.
                      END.

                 aux_vlsldtot = crapsld.vlsddisp + crapass.vllimcre.

                 IF    crapsld.vlipmfap > 0   THEN
                       ASSIGN aux_vlsldtot = aux_vlsldtot - crapsld.vlipmfap.
                       
                 IF    crapsld.vlipmfpg > 0   THEN
                       ASSIGN aux_vlsldtot = aux_vlsldtot - crapsld.vlipmfpg.

                 FOR EACH craplcm WHERE craplcm.cdcooper = glb_cdcooper     AND
                                        craplcm.nrdconta = crapavs.nrdconta AND
                                        craplcm.dtmvtolt = glb_dtmvtolt     AND
                                        craplcm.cdhistor <> 289
                                        USE-INDEX craplcm2 NO-LOCK:

                     IF   aux_cdhistor <> craplcm.cdhistor THEN
                          DO:
                              FIND craphis WHERE
                                   craphis.cdcooper = glb_cdcooper AND 
                                   craphis.cdhistor = craplcm.cdhistor
                                   USE-INDEX craphis1 NO-LOCK NO-ERROR.

                              IF   NOT AVAILABLE craphis THEN
                                   DO:
                                       glb_cdcritic = 83.
                                       RUN fontes/critic.p.
                                       UNIX SILENT VALUE("echo " +
                                                  STRING(TIME,"HH:MM:SS") +
                                              " - " + glb_cdprogra + "' --> '" +
                                            STRING(craphis.cdhistor,"zz99")
                                             + "' '" + glb_dscritic +
                                              " >> log/proc_batch.log").

                                       ASSIGN aux_cdhistor = craplcm.cdhistor
                                              aux_inhistor = 0
                                              aux_indoipmf = 0
                                              glb_cdcritic = 0 .
                                   END.
                             ELSE
                                   DO:
                                       ASSIGN aux_cdhistor = craphis.cdhistor
                                              aux_inhistor = craphis.inhistor
                                              aux_indoipmf = craphis.indoipmf.

                                       IF   tab_indabono = 0   AND
                                            CAN-DO("0114,0160,0177",
                                            STRING(craphis.cdhistor,"9999")) 
                                            THEN
                                            aux_indoipmf = 1.
                                   END.
                          END.

                     IF tab_indabono     = 0                 AND 
                        tab_dtiniabo    <= craplcm.dtrefere  AND
                       (craplcm.cdhistor = 186               OR
                        craplcm.cdhistor = 498               OR
                        craplcm.cdhistor = 187               OR
                        craplcm.cdhistor = 500)              THEN
                        aux_vlsldtot = aux_vlsldtot -
                              (TRUNCATE((craplcm.vllanmto * tab_txcpmfcc),2)).

                     IF   aux_inhistor = 1 THEN

                          /* Inicia tratamento CPMF */

                          IF   aux_indoipmf = 2 THEN
                               aux_vlsldtot = aux_vlsldtot +
                                         (TRUNCATE(craplcm.vllanmto *
                                          (1 + tab_txcpmfcc ),2)).
                          ELSE
                                /* Termina tratamento CPMF */

                               aux_vlsldtot = aux_vlsldtot + craplcm.vllanmto.

                     IF   aux_inhistor = 11 THEN

                          /* Inicia tratamento CPMF */

                          IF   aux_indoipmf = 2  THEN
                               aux_vlsldtot = aux_vlsldtot -
                                          (TRUNCATE(craplcm.vllanmto *
                                           (1 + tab_txcpmfcc),2)).
                          ELSE
                               /* Termina tratamento CPMF */

                               aux_vlsldtot = aux_vlsldtot - craplcm.vllanmto.

                 END.  /* For each craplcm */

             END. /*  DO ant_nrdconta  <> crapavs.nrdconta */

        /*  Emprestimos  */

        IF   crapavs.cdhistor = 108   THEN
             DO:
                 ASSIGN aux_vlsldtot = TRUNCATE(tab_txrdcpmf * aux_vlsldtot,2).
                        
                 IF   aux_vlsldtot > 0   THEN
                      DO:

                          RUN fontes/crps120_1.p
                              (INPUT  crapavs.nrdconta,
                               INPUT  crapavs.nrdocmto, /* contrato */
                               INPUT  8453,    /* lote emprestimo */
                               INPUT  tab_inusatab,
                               INPUT  crapavs.vllanmto - crapavs.vldebito,
                               INPUT  aux_vlsldtot,  /* saldo */
                               INPUT  glb_dtmvtolt,   /* data do lote */
                               INPUT  95,   /* historico */
                               OUTPUT crapavs.insitavs,
                               OUTPUT aux_vldebito,
                               OUTPUT aux_vlestdif,
                               OUTPUT crapavs.flgproce).

                          IF   glb_cdcritic > 0   THEN
                               UNDO TRANS_1, RETURN.

                          aux_vlabatim = crapavs.vllanmto + aux_vlestdif -
                                         crapavs.vldebito - aux_vldebito.

                          ASSIGN crapavs.vldebito = crapavs.vldebito +
                                                    aux_vldebito
                                 crapavs.vlestdif = IF crapavs.insitavs = 0
                                                    THEN (crapavs.vllanmto -
                                                          crapavs.vldebito -
                                                          aux_vlabatim) * -1
                                                    ELSE crapavs.vllanmto -
                                                         crapavs.vldebito
                                 aux_vlsldtot     = aux_vlsldtot - 
                                                    ROUND(((1 + tab_txcpmfcc) * 
                                                            aux_vldebito),2)
                                 aux_vldescto     = aux_vldebito.
                      END.
                      
                 ASSIGN crapavs.flgproce = TRUE.                      
             END.

        IF   aux_vldescto > 0 THEN
             DO:
                 FIND craplot WHERE craplot.cdcooper = glb_cdcooper  AND 
                                    craplot.dtmvtolt = glb_dtmvtolt  AND
                                    craplot.cdagenci = 1             AND
                                    craplot.cdbccxlt = 100           AND
                                    craplot.nrdolote = 8458
                                    EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                 IF   NOT AVAILABLE craplot   THEN
                      DO:

                          CREATE craplot.
                          ASSIGN craplot.dtmvtolt = glb_dtmvtolt
                                 craplot.cdagenci = 1
                                 craplot.cdbccxlt = 100
                                 craplot.nrdolote = 8458
                                 craplot.tplotmov = 1
                                 craplot.nrseqdig = 0
                                 craplot.vlcompcr = 0
                                 craplot.vlinfocr = 0
                                 craplot.cdhistor = 0
                                 craplot.cdoperad = "1"
                                 craplot.dtmvtopg = ?
                                 craplot.cdcooper = glb_cdcooper.
                          VALIDATE craplot.

                      END.

                 ASSIGN craplot.nrseqdig = craplot.nrseqdig + 1
                        craplot.qtcompln = craplot.qtcompln + 1
                        craplot.qtinfoln = craplot.qtcompln
                        craplot.vlcompdb = craplot.vlcompdb + aux_vldescto
                        craplot.vlinfodb = craplot.vlcompdb.

                      
                 /* 11/06/2018 - TJ - BLOCO DA INSERÇAO DA CRAPLCM */
                 RUN gerar_lancamento_conta_comple IN h-b1wgen0200 
                   (INPUT glb_dtmvtolt                         /* par_dtmvtolt */
                   ,INPUT craplot.cdagenci                     /* par_cdagenci */
                   ,INPUT craplot.cdbccxlt                     /* par_cdbccxlt */
                   ,INPUT craplot.nrdolote                     /* par_nrdolote */
                   ,INPUT crapavs.nrdconta                     /* par_nrdconta */
                   ,INPUT crapavs.nrdocmto                     /* par_nrdocmto */
                   ,INPUT crapavs.cdhistor                     /* par_cdhistor */
                   ,INPUT craplot.nrseqdig                     /* par_nrseqdig */
                   ,INPUT aux_vldescto                         /* par_vllanmto */
                   ,INPUT crapavs.nrdconta                     /* par_nrdctabb */
                   ,INPUT ""                                   /* par_cdpesqbb */
                   ,INPUT 0                                    /* par_vldoipmf */
                   ,INPUT 0                                    /* par_nrautdoc */
                   ,INPUT 0                                    /* par_nrsequni */
                   ,INPUT 0                                    /* par_cdbanchq */
                   ,INPUT 0                                    /* par_cdcmpchq */
                   ,INPUT 0                                    /* par_cdagechq */
                   ,INPUT 0                                    /* par_nrctachq */
                   ,INPUT 0                                    /* par_nrlotchq */
                   ,INPUT 0                                    /* par_sqlotchq */
                   ,INPUT ""                                   /* par_dtrefere */
                   ,INPUT ""                                   /* par_hrtransa */
                   ,INPUT 0                                    /* par_cdoperad */
                   ,INPUT 0                                    /* par_dsidenti */
                   ,INPUT glb_cdcooper                         /* par_cdcooper */
                   ,INPUT STRING(crapavs.nrdconta,"99999999")  /* par_nrdctitg */
                   ,INPUT ""                                   /* par_dscedent */
                   ,INPUT 0                                    /* par_cdcoptfn */
                   ,INPUT 0                                    /* par_cdagetfn */
                   ,INPUT 0                                    /* par_nrterfin */
                   ,INPUT 0                                    /* par_nrparepr */
                   ,INPUT 0                                    /* par_nrseqava */
                   ,INPUT 0                                    /* par_nraplica */
                   ,INPUT 0                                    /* par_cdorigem */
                   ,INPUT 0                                    /* par_idlautom */
                   /* CAMPOS OPCIONAIS DO LOTE                                                                  */ 
                   ,INPUT 0                                    /* Processa lote                                 */
                   ,INPUT 0                                    /* Tipo de lote a movimentar                     */
                   /* CAMPOS DE SAIDA                                                                           */                                            
                   ,OUTPUT TABLE tt-ret-lancto                 /* Collection que contém o retorno do lançamento */
                   ,OUTPUT aux_incrineg                        /* Indicador de crítica de negócio               */
                   ,OUTPUT aux_cdcritic                        /* Código da crítica                             */
                   ,OUTPUT aux_dscritic).                      /* Descriçao da crítica                          */
                   
                 IF aux_cdcritic > 0 OR aux_dscritic <> "" THEN 
                 DO:   
					 RUN fontes/critic.p.

					 glb_dscritic = aux_dscritic.

                     UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                       " - " + glb_cdprogra + "' --> '" +
                                       glb_dscritic + " Conta : " +
                                       STRING(crapavs.nrdconta,"zzzz,zz9,9") +
                                       " >> log/proc_batch.log").
                     glb_cdcritic = 0.

                     NEXT.                      
             END.
                   
             END. /* fim aux_vldescto > 0 */

    END.  /* FOR EACH crapavs TRANSACTION */

    DO TRANSACTION ON ERROR UNDO, LEAVE.
       IF   MONTH(glb_dtmvtolt) <> MONTH(glb_dtmvtopr)    THEN
            craptab.dstextab = SUBSTR(craptab.dstextab,1,22) + "1".
    END.     

    /* 11/06/2018 - TJ - Apagar handle associado antes do For Each crapavs */
    IF  VALID-HANDLE(h-b1wgen0200) THEN
        DELETE PROCEDURE h-b1wgen0200.

END.    /* FOR EACH craptab */

FOR EACH crapavs WHERE crapavs.cdcooper = glb_cdcooper                      AND
                       crapavs.dtrefere = aux_dtrefere                      AND
                       CAN-DO(aux_lsempres, 
                              STRING(crapavs.cdempcnv,"99999"))             AND
                       crapavs.tpdaviso = 1                                 AND
                       crapavs.cdhistor = 108                               AND
                       crapavs.insitavs = 0
                       NO-LOCK BREAK BY crapavs.cdagenci
                                        BY crapavs.cdempcnv
                                           BY crapavs.nrdconta
                                              BY crapavs.cdhistor:

    FIND cratest WHERE cratest.cdagenci = crapavs.cdagenci AND
                       cratest.cdempres = crapavs.cdempcnv NO-ERROR.
                       
    IF   NOT AVAILABLE cratest   THEN
         DO:                           
             CREATE cratest.
             ASSIGN cratest.cdagenci = crapavs.cdagenci
                    cratest.cdempres = crapavs.cdempcnv.
         END.

    IF   FIRST-OF(crapavs.cdagenci)   THEN
         DO:
             aux_nmarqimp = "rl/crrl156_" + 
                            STRING(crapavs.cdagenci,"999") + ".lst".

             OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGED PAGE-SIZE 84.

             VIEW STREAM str_1 FRAME f_cabrel132_1.

             ASSIGN ant_nrdconta = 0
                    est_flgsomar = TRUE
                    est_regexist = FALSE

                    ass_vlestdif = 0   
                    ass_vlestemp = 0   
                    rel_cdagenci = crapavs.cdagenci.

             DISPLAY STREAM str_1 rel_dsagenci[rel_cdagenci]
                                  aux_dtrefere
                                  WITH FRAME f_agencia.

             VIEW STREAM str_1 FRAME f_label_aviso.

         END. /* FIRST-OF cdagenci */

    FIND craphis NO-LOCK WHERE craphis.cdcooper = crapavs.cdcooper AND 
                               craphis.cdhistor = crapavs.cdhistor NO-ERROR.
    IF   NOT AVAILABLE craphis   THEN
         rel_dshistor = "N/CADASTRADO".
    ELSE               
         rel_dshistor = craphis.dshistor.

    IF   crapavs.vldebito = 0   AND   crapavs.vlestdif = 0   THEN
         avs_vlestdif = crapavs.vllanmto * -1.
    ELSE
         avs_vlestdif = crapavs.vlestdif.

    /*  Acumula total geral dos aviso  */

    IF   crapavs.cdhistor = 108   THEN
         DO:
             ASSIGN cratest.vlavsemp = cratest.vlavsemp + crapavs.vllanmto
                    cratest.vldebemp = cratest.vldebemp + crapavs.vldebito.

             IF   avs_vlestdif > 0   THEN
                  cratest.vlantemp = cratest.vlantemp + avs_vlestdif.
             ELSE
             IF   avs_vlestdif < 0   THEN
                  cratest.vlantemp = cratest.vlantemp + (crapavs.vllanmto +
                                     avs_vlestdif - crapavs.vldebito).
         END.

    IF   crapavs.vldebito = crapavs.vllanmto   THEN
         DO:
             IF   LAST-OF(crapavs.cdagenci)   THEN
                  RUN p_totaliza_pac.
                  
             NEXT.
         END.

    IF   ant_nrdconta <> crapavs.nrdconta   THEN
         DO:
             IF   est_regexist   THEN
                  DO:
                      IF   ass_vlestdif <> ass_vlestemp   THEN
                           DO:
                               IF   LINE-COUNTER(str_1) >
                                    (PAGE-SIZE(str_1) - 4) THEN
                                    DO:
                                        PAGE STREAM str_1.

                                        DISPLAY STREAM str_1
                                                rel_dsagenci[rel_cdagenci]
                                                aux_dtrefere
                                                WITH FRAME f_agencia.

                                        VIEW STREAM str_1 FRAME f_label_aviso.

                                    END.

                               DISPLAY STREAM str_1 ass_vlestdif
                                              WITH FRAME f_total_ass.
                           END.
                      ELSE
                           DO:
                               IF  (LINE-COUNTER(str_1) + 2) >
                                   PAGE-SIZE(str_1)  THEN
                                   DO:
                                       PAGE STREAM str_1.

                                       DISPLAY STREAM str_1
                                               rel_dsagenci[rel_cdagenci]
                                               aux_dtrefere
                                               WITH FRAME f_agencia.

                                       VIEW STREAM str_1 FRAME
                                                    f_label_aviso.
                                   END.
                               ELSE
                                   VIEW STREAM str_1 FRAME f_linha.
                           END.
                  END.

             FIND crapass WHERE crapass.cdcooper = glb_cdcooper      AND
                                crapass.nrdconta = crapavs.nrdconta
                                NO-LOCK NO-ERROR.

             IF  NOT AVAILABLE crapass THEN
                 DO:
                     glb_cdcritic = 9.
                     RUN fontes/critic.p.

                     UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                       " - " + glb_cdprogra + "' --> '" +
                                       glb_dscritic + " Conta : " +
                                       STRING(crapavs.nrdconta,"zzzz,zz9,9") +
                                       " >> log/proc_batch.log").
                     glb_cdcritic = 0.
                     RETURN.
                 END.

             FIND crapttl NO-LOCK WHERE
                  crapttl.cdcooper = glb_cdcooper       AND
                  crapttl.nrdconta = crapass.nrdconta   AND
                  crapttl.idseqttl = 1 NO-ERROR.
                  
             IF   AVAILABLE crapttl   THEN
                  rel_cdturnos = crapttl.cdturnos.
             ELSE
                  rel_cdturnos = 0.
             
             ASSIGN rel_nmprimtl = crapass.nmprimtl
                    rel_nrramemp = crapass.nrramemp
                    est_flgsomar = TRUE
                    ass_vlestdif = 0
                    ass_vlestemp = 0
                    est_regexist = FALSE
                    ant_nrdconta = crapavs.nrdconta
                    aux_flgimpri = TRUE.
         END.

    IF   avs_vlestdif > 0   THEN
         DO:
             ASSIGN  rel_vlestdif = avs_vlestdif
                     rel_dscritic = "DEB.MENOR".
                     
             IF   LAST-OF(crapavs.cdagenci)   THEN
                  RUN p_totaliza_pac.
                  
             NEXT.                          
         END.
    ELSE
    IF   avs_vlestdif < 0   THEN
         DO:
             ASSIGN rel_vlestdif = avs_vlestdif * -1
                    rel_dscritic = "ESTOURO".
         END.
         
    IF   crapavs.cdhistor = 108   THEN
         ASSIGN cratest.qtestemp = cratest.qtestemp + IF est_flgsomar 
                                                         THEN 1 ELSE 0
                cratest.vlestemp = cratest.vlestemp + rel_vlestdif
                ass_vlestemp     = rel_vlestdif
                ass_vlestdif     = ass_vlestdif + rel_vlestdif
                est_flgsomar     = FALSE.

    IF   LINE-COUNTER(str_1) > PAGE-SIZE(str_1)   THEN
         DO:
             PAGE STREAM str_1.

             DISPLAY STREAM str_1
                     rel_dsagenci[rel_cdagenci]
                     aux_dtrefere
                     WITH FRAME f_agencia.

             VIEW STREAM str_1 FRAME f_label_aviso.
         END.

    IF   aux_flgimpri   THEN
         DO:
             DISPLAY STREAM str_1
                     crapavs.nrdconta  
                     crapavs.cdempcnv
                     rel_nrramemp
                     rel_cdturnos      
                     rel_nmprimtl
                     WITH FRAME f_aviso.

             aux_flgimpri = FALSE.
         END.

    DISPLAY STREAM str_1
            rel_dshistor      crapavs.nrdocmto  crapavs.nrseqdig
            crapavs.vllanmto  crapavs.vldebito  rel_vlestdif  
            rel_dscritic      WITH FRAME f_aviso.

    DOWN STREAM str_1 WITH FRAME f_aviso.

    ASSIGN est_regexist = TRUE.

    IF   LAST-OF(crapavs.cdagenci)   THEN
         RUN p_totaliza_pac.
         
END.  /* for each crapavs.... */

EMPTY TEMP-TABLE tt-empres.

FOR EACH crapemp NO-LOCK WHERE crapemp.cdcooper = glb_cdcooper:
                                
    CREATE tt-empres.                            
    ASSIGN tt-empres.cdempres = crapemp.cdempres
           tt-empres.dsempres = STRING(crapemp.cdempres, "99999") + " - " 
                                + crapemp.nmresemp.
                                
    VALIDATE tt-empres.                            
END.

ASSIGN aux_nmarqimp = "rl/crrl156_999.lst".

OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGED PAGE-SIZE 84.

VIEW STREAM str_1 FRAME f_cabrel132_1.

FOR EACH cratest NO-LOCK BREAK BY cratest.cdagenci 
                                  BY cratest.cdempres:


    IF   FIRST-OF(cratest.cdagenci)               OR
         LINE-COUNTER(str_1) > PAGE-SIZE(str_1)   THEN
         DO:
             IF   FIRST-OF(cratest.cdagenci)  THEN             
                  ASSIGN rel_cdagenci = cratest.cdagenci
                         tot_qtestemp = 0
                         tot_vlestemp = 0
                         tot_vlantemp = 0
                         tot_vlavsemp = 0
                         tot_vldebemp = 0.

             PAGE STREAM str_1.

             DISPLAY STREAM str_1 rel_dsagenci[rel_cdagenci]
                                  aux_dtrefere WITH FRAME f_agencia.
             
             VIEW STREAM str_1 FRAME f_label_total.
         END.

    ASSIGN rel_cdempres = cratest.cdempres
           tot_qtestemp = tot_qtestemp + cratest.qtestemp
           tot_vlestemp = tot_vlestemp + cratest.vlestemp
           tot_vlantemp = tot_vlantemp + cratest.vlantemp
           tot_vlavsemp = tot_vlavsemp + cratest.vlavsemp
           tot_vldebemp = tot_vldebemp + cratest.vldebemp.

    IF   cratest.qtestemp > 0   THEN
         DO:        
             FIND tt-empres WHERE tt-empres.cdempres = rel_cdempres NO-LOCK NO-ERROR.
                
               IF AVAIL(tt-empres) THEN 
                 ASSIGN aux_dsempres = tt-empres.dsempres.
                            
               DISPLAY STREAM str_1 aux_dsempres  
                                  cratest.qtestemp
                                  cratest.vlestemp
                                  WITH FRAME f_total_ger.
                         
             DOWN STREAM str_1 WITH FRAME f_total_ger.
         END.
         
    IF   LAST-OF(cratest.cdagenci)  THEN
         DO:
             DISPLAY STREAM str_1 tot_qtestemp  
                                  tot_vlestemp  
                                  tot_vlavsemp
                                  tot_vldebemp  
                                  tot_vlantemp  WITH FRAME f_total.

         END.
             
END.  /*  Fim do FOR EACH cratest.....  */

OUTPUT STREAM str_1 CLOSE.

ASSIGN glb_nrcopias = 1
       glb_nmformul = "132col"
       glb_nmarqimp = aux_nmarqimp.

RUN fontes/imprim.p.      
     
RUN fontes/fimprg.p.

/* .......................................................................... */

