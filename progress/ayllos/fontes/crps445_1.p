/******************************************************************************
                 ATENCAO!    CONVERSAO PROGRESS - ORACLE
            ESTE FONTE ESTA ENVOLVIDO NA MIGRACAO PROGRESS->ORACLE!
  +---------------------------------+-----------------------------------+
  | Rotina Progress                 | Rotina Oracle PLSQL               |
  +---------------------------------+-----------------------------------+
  | fontes/crps445_1.p              | pc_crps445                        |
  +---------------------------------+-----------------------------------+

  TODA E QUALQUER ALTERACAO EFETUADA NESSE FONTE A PARTIR DE 20/NOV/2012 DEVERA
  SER REPASSADA PARA ESTA MESMA ROTINA NO ORACLE, CONFORME DADOS ACIMA.

  PARA DETALHES DE COMO PROCEDER, FAVOR ENTRAR EM CONTATO COM AS SEGUINTES
  PESSOAS:
   - GUILHERME STRUBE    (CECRED)
   - MARCOS MARTINI      (SUPERO)

*******************************************************************************/



/*.............................................................................

   Programa: Fontes/crps445_1.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Evandro
   Data    : Julho/2011.                     Ultima atualizacao: 04/08/2014

   Dados referentes ao programa: Fonte extraido e adaptado para execucao em
                                 paralelo. Fonte original crps445.p.

   Frequencia: Sempre que for chamado.
   Objetivo  : Gerar planilha Operacoes de Credito -  Utilizado no CORVU
               Solicitacao 2 - Ordem 37.

   Alteracoes: 10/08/2011 - Retirado LOG de inicio de execucao, ficou no
                            programa principal (Evandro).
                            
               13/09/2011 - Incluida informacoes para novos campos da tabela
                            crapsda (Elton).
                            
               10/02/2012 - Utilizar variavel glb_flgresta para nao efetuar
                            controle de restart (David).
                            
               16/09/2013 - Tratamento para Imunidade Tributaria (Ze).
               
               30/10/2013 - Incluir chamada da procedure controla_imunidade
                            (Lucas R.)
                            
               05/11/2013 - Instanciado h-b1wgen0159 fora da poupanca.i
                            (Lucas R.)         
                            
               18/12/2013 - Removido linha crapscd.dscpfcgc = crapass.dscpfcgc
                            (Lucas R.)
                            
               03/02/2014 - Remover a chamada da procedure "saldo_epr.p".
                            (James)
                            
               04/08/2014 - Alteração da Nomeclatura para PA (Vanessa).
.............................................................................*/

/******************************************************************************
    Para restart eh necessario eliminar as tabelas crapscd e crapsdv e 
    rodar novamente
******************************************************************************/

{ includes/var_batch.i "NEW" } 

/* Calcula aplicacoes RDCA30 e RDCA60 por PA */

{ includes/var_atenda.i "NEW"}
{ includes/var_rdca2.i "NEW" }


/* Variaveis para controle da execucao em paralelo */
DEF VAR aux_idparale        AS INT                                   NO-UNDO.
DEF VAR aux_idprogra        AS INT                                   NO-UNDO.
DEF VAR aux_cdagenci        AS INT                                   NO-UNDO.
DEF VAR h_paralelo          AS HANDLE                                NO-UNDO.
                        

 
DEF VAR aux_vlsdeved_limite_conta AS DEC                             NO-UNDO.
DEF VAR aux_descricao_linha AS CHAR                                  NO-UNDO.
DEF VAR aux_descricao_finalidade AS CHAR                             NO-UNDO.
DEF VAR aux_vlbloque        AS DEC                                   NO-UNDO.
DEF VAR aux_nrctrato        LIKE crapsdv.nrctrato                    NO-UNDO.
DEF VAR aux_tpdsaldo        LIKE crapsdv.tpdsaldo                    NO-UNDO.
DEF VAR aux_cdlcremp        LIKE crapsdv.cdlcremp                    NO-UNDO.
    
DEF VAR aux_tot_vlemprst    AS DEC                                   NO-UNDO.
DEF VAR aux_tot_vldeschq    AS DEC                                   NO-UNDO.
DEF VAR aux_tot_vldestit    AS DEC                                   NO-UNDO.
DEF VAR aux_tot_vllimutl    AS DEC                                   NO-UNDO.
DEF VAR aux_tot_vldclutl    AS DEC                                   NO-UNDO.
DEF VAR aux_tot_vlsdrdca    AS DEC                                   NO-UNDO.
DEF VAR aux_tot_vlsdrdpp    AS DEC                                   NO-UNDO.
DEF VAR aux_tot_vllimdsc    AS DEC                                   NO-UNDO.
DEF VAR aux_tot_vllimtit    AS DEC                                   NO-UNDO.
DEF VAR aux_tot_vlprepla    AS DEC                                   NO-UNDO.
DEF VAR aux_tot_vlprerpp    AS DEC                                   NO-UNDO.
DEF VAR aux_tot_vlcrdsal    AS DEC                                   NO-UNDO.
DEF VAR aux_tot_qtchqliq    AS INTE                                  NO-UNDO.
DEF VAR aux_tot_qtchqass    AS INTE                                  NO-UNDO.

DEF VAR aux_tot_vltotpar    AS DEC                                   NO-UNDO.
DEF VAR aux_tot_vlopcdia    AS DEC                                   NO-UNDO.
DEF VAR aux_tot_qtdevolu    AS DEC                                   NO-UNDO.
DEF VAR aux_tot_vltotren    AS DEC                                   NO-UNDO.


DEF VAR aux_tot_vlcheque    AS DEC                                   NO-UNDO.

DEF VAR aux_vlsldrdc        AS DEC  DECIMALS 8                       NO-UNDO.
DEF VAR aux_perirrgt        AS DEC  DECIMALS 2                       NO-UNDO.

DEF VAR h-b1wgen0004        AS HANDLE                                NO-UNDO.

DEF TEMP-TABLE craterr NO-UNDO LIKE craperr.

/******************* Variaveis RDCA para BO *******************************/

DEF        BUFFER crablap5 FOR craplap.

DEF        VAR aux_ttrenrgt AS DECIMAL DECIMALS 8                    NO-UNDO.
/* total dos rendimentos resgatados no periodo com ajuste no dia do aniver */
                                  
DEF        VAR aux_vlrenrgt AS DECIMAL DECIMALS 8                    NO-UNDO.
                               /* rendimento resgatado periodo */
DEF        VAR aux_ajtirrgt AS DECIMAL DECIMALS 8                    NO-UNDO.
                              /* IRRF pago do que foi resgatado no periodo */
DEF        VAR aux_vlrentot AS DECIMAL DECIMALS 8                    NO-UNDO.
DEF        VAR aux_vlrendim AS DECIMAL DECIMALS 8                    NO-UNDO.
DEF        VAR aux_vldperda AS DECIMAL DECIMALS 8                    NO-UNDO.
DEF        VAR aux_vlsdrdca AS DECIMAL DECIMALS 8                    NO-UNDO.
DEF        VAR aux_vlsdrdat AS DECIMAL DECIMALS 8                    NO-UNDO.
DEF        VAR aux_vlsdresg AS DECIMAL DECIMALS 8                    NO-UNDO.
DEF        VAR aux_vlprovis AS DECIMAL DECIMALS 8                    NO-UNDO.
DEF        VAR aux_vlajuste AS DECIMAL                               NO-UNDO.
DEF        VAR aux_vllan117 AS DECIMAL                               NO-UNDO.
DEF        VAR aux_txaplica AS DECIMAL DECIMALS 8                    NO-UNDO.
DEF        VAR aux_txaplmes AS DECIMAL DECIMALS 8                    NO-UNDO.

DEF        VAR aux_vlsrdc30 AS DECIMAL                               NO-UNDO.
DEF        VAR aux_vlsrdc60 AS DECIMAL                               NO-UNDO.
DEF        VAR aux_vlsrdcpr AS DECIMAL                               NO-UNDO.
DEF        VAR aux_vlsrdcpo AS DECIMAL                               NO-UNDO.

DEF        VAR aux_vlsdempr AS DECIMAL                               NO-UNDO.
DEF        VAR aux_vlsdfina AS DECIMAL                               NO-UNDO.

DEF        VAR aux_dtcalajt AS DATE                                  NO-UNDO.
DEF        VAR aux_dtcalcul AS DATE                                  NO-UNDO.
DEF        VAR aux_dtmvtolt AS DATE                                  NO-UNDO.
DEF        VAR aux_dtdolote AS DATE                                  NO-UNDO.
DEF        VAR aux_dtultdia AS DATE                                  NO-UNDO.
DEF        VAR aux_dtrefere AS DATE                                  NO-UNDO.

DEF        VAR aux_cdbccxlt AS INT     INIT 100                      NO-UNDO.
DEF        VAR aux_nrdolote AS INT                                   NO-UNDO.
DEF        VAR aux_cdhistor AS INT                                   NO-UNDO.
DEF        VAR aux_vlajtsld AS DEC                                   NO-UNDO.

DEF        VAR aux_flglanca AS LOGICAL                               NO-UNDO.
DEF        VAR aux_vlabcpmf AS DEC                                   NO-UNDO.
DEF        VAR aux_flgncalc AS LOG                                   NO-UNDO.
DEF        VAR aux_sldcaren AS DECIMAL DECIMALS 8                    NO-UNDO.

DEF        VAR aux_dtpropos AS DATE                                  NO-UNDO.
DEF        VAR aux_dtefetiv AS DATE                                  NO-UNDO.

DEF        VAR dup_vlsdrdca AS DECIMAL DECIMALS 8                    NO-UNDO.
DEF        VAR dup_dtcalcul AS DATE                                  NO-UNDO.
DEF        VAR dup_dtmvtolt AS DATE                                  NO-UNDO.
DEF        VAR dup_vlrentot AS DECIMAL DECIMALS 8                    NO-UNDO.

DEF        VAR aux_inprejuz LIKE crapsdv.inprejuz                    NO-UNDO.
DEF        VAR aux_qtpreemp LIKE crapsdv.qtpreemp                    NO-UNDO.
DEF        VAR aux_vlemprst LIKE crapsdv.vlemprst                    NO-UNDO.
DEF        VAR aux_cdfinemp LIKE crapsdv.cdfinemp                    NO-UNDO.
DEF        VAR aux_dtdpagto LIKE crapsdv.dtdpagto                    NO-UNDO.
DEF        VAR aux_cdageepr LIKE crapsdv.cdageepr                    NO-UNDO.
DEF        VAR aux_flgareal LIKE crapsdv.flgareal                    NO-UNDO.

DEF        VAR p-cdcooper   AS INTE                                  NO-UNDO.
DEF        VAR p-cod-agencia AS INTE                                 NO-UNDO.
DEF        VAR p-nro-caixa  AS INTE                                  NO-UNDO.
DEF        VAR p-cdprogra   AS CHAR                                  NO-UNDO.
           
DEF        VAR aux_sequen   AS INTE                                  NO-UNDO.
DEF        VAR i-cod-erro   AS INTE                                  NO-UNDO.
DEF        VAR c-dsc-erro   AS CHAR                                  NO-UNDO.
DEF        VAR aux_dsmsgerr AS CHAR                                  NO-UNDO.
DEF        VAR aux_dataano  AS CHAR  FORMAT "X(2)"                   NO-UNDO.
   
DEFINE VARIABLE h-b1wgen05   AS HANDLE                                NO-UNDO.
DEFINE VARIABLE h-b1wgen0159 AS HANDLE                                NO-UNDO.

{ sistema/generico/includes/var_internet.i }

/******************************************************/

/* recebe os parametros de sessao (criterio de separacao */
ASSIGN glb_cdprogra = "crps445"
       glb_flgresta = FALSE  /* Sem controle de restart */
       aux_idparale = INT(ENTRY(1,SESSION:PARAMETER))
       aux_idprogra = INT(ENTRY(2,SESSION:PARAMETER))
       aux_cdagenci = aux_idprogra.
                   
RUN fontes/iniprg.p.

IF   glb_cdcritic > 0 THEN
     QUIT.  

{ includes/var_faixas_ir.i "NEW" }

/********** leituras para include da BO de Aplicacao *******/
FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper
                   NO-LOCK NO-ERROR.

FIND FIRST crapdat WHERE crapdat.cdcooper = crapcop.cdcooper
                         NO-LOCK NO-ERROR.
                
ASSIGN p-cdcooper    = crapcop.cdcooper
       p-cod-agencia = 0
       p-nro-caixa   = 0 
       p-cdprogra    = glb_cdprogra.

RUN sistema/generico/procedures/b1wgen0004.p
                    PERSISTENT SET h-b1wgen0004.
                
IF  NOT VALID-HANDLE(h-b1wgen0004)  THEN
    DO:
        UNIX SILENT VALUE("echo " + 
                           STRING(TIME,"HH:MM:SS") +
                           " - " + glb_cdprogra + "' --> '" +
                           "Handle Invalido para BO b1wgen0004" +
                           " >> log/proc_batch.log").
                                           
         QUIT.
     END.
                
/* instancia b1wgen0159 */ 
RUN controla_imunidade IN h-b1wgen0004 
                      (INPUT TRUE, /* instancia */
                       INPUT FALSE, /* deleta */
                       INPUT glb_cdprogra).

IF  NOT VALID-HANDLE(h-b1wgen0159) THEN
    RUN sistema/generico/procedures/b1wgen0159.p 
        PERSISTENT SET h-b1wgen0159.

/*  Leitura do cadastro de cooperados do PA ............................... */
FOR EACH crapass WHERE crapass.cdcooper = glb_cdcooper   AND
                       crapass.cdagenci = aux_cdagenci   AND
                       crapass.dtelimin = ?              NO-LOCK:
                      
    FIND crapsld WHERE crapsld.cdcooper = glb_cdcooper   AND
                       crapsld.nrdconta = crapass.nrdconta 
                       USE-INDEX crapsld1 NO-LOCK NO-ERROR.
    
    IF   NOT AVAILABLE crapsld   THEN
         NEXT.
    
    FOR EACH crapepr NO-LOCK WHERE crapepr.cdcooper = glb_cdcooper   AND
                                   crapepr.nrdconta = crapass.nrdconta
                                   USE-INDEX crapepr2.

        IF  crapepr.inliquid = 1 THEN DO:
            IF  crapepr.inprejuz  = 1   THEN
                DO:
                    IF   crapepr.vlsdprej <= 0   THEN
                         NEXT.
                END.
            ELSE
                NEXT.
        END.
 
        ASSIGN aux_vlsdeved = 0
               aux_dtpropos = ?
               aux_dtefetiv = ?
               aux_inprejuz = 0  
               aux_qtpreemp = 0
               aux_vlemprst = 0
               aux_cdfinemp = 0
               aux_dtdpagto = ?
               aux_cdageepr = 0
               aux_flgareal = FALSE. 
               

        IF  (MONTH(glb_dtmvtolt) <> MONTH(glb_dtmvtopr))  THEN /* Mensal */
             ASSIGN aux_vlsdeved = crapepr.vlsdeved. /* Saldo calc.pelo 78*/
        ELSE         
           DO:
               /* Saldo calculado pelo crps616.p/crps665.p */
               IF crapepr.inliquid = 0 THEN
                  ASSIGN aux_vlsdeved = crapepr.vlsdevat.
               ELSE
                  ASSIGN aux_vlsdeved = 0.
           END.

        IF  crapepr.inprejuz  = 0   AND
            aux_vlsdeved     <= 0   THEN
            NEXT.
        ELSE
        IF  crapepr.inprejuz  = 1   THEN
            ASSIGN aux_vlsdeved = 0.

        ASSIGN aux_descricao_linha = " ".
        
        FIND craplcr NO-LOCK WHERE craplcr.cdcooper  = glb_cdcooper AND
                                   craplcr.cdlcremp  = crapepr.cdlcremp
                                   NO-ERROR.

        IF   AVAILABLE craplcr   THEN
             ASSIGN aux_descricao_linha = craplcr.dslcremp.
           
        ASSIGN aux_descricao_finalidade = " ".
        
        FIND crapfin NO-LOCK WHERE crapfin.cdcooper  = glb_cdcooper     AND
                                   crapfin.cdfinemp  = crapepr.cdfinemp
                                   NO-ERROR.

        IF   AVAILABLE crapfin   THEN
             ASSIGN aux_descricao_finalidade = crapfin.dsfinemp.
           
        FIND crawepr WHERE crawepr.cdcooper = glb_cdcooper      AND
                           crawepr.nrdconta = crapepr.nrdconta  AND
                           crawepr.nrctremp = crapepr.nrctremp
                           NO-LOCK NO-ERROR.
                           
        IF   AVAIL crawepr  THEN
             ASSIGN aux_dtpropos = crawepr.dtmvtolt.
        
        ASSIGN aux_tpdsaldo = 1  /* Emprestimo */
               aux_nrctrato = crapepr.nrctremp
               aux_cdlcremp = crapepr.cdlcremp
               aux_dtefetiv = crapepr.dtmvtolt
               aux_inprejuz = crapepr.inprejuz
               aux_qtpreemp = crapepr.qtpreemp
               aux_vlemprst = crapepr.vlemprst
               aux_cdfinemp = crapepr.cdfinemp
               aux_dtdpagto = crapepr.dtdpagto 
               aux_cdageepr = crapepr.cdagenci. 
             
        IF   craplcr.tpctrato = 2  OR     /** Alienacao **/
             craplcr.tpctrato = 3  THEN   /** Hipoteca **/ 
             ASSIGN aux_flgareal = TRUE.   
        
        DO TRANSACTION ON ERROR UNDO, RETURN:
           
           RUN atualiza_crapsdv. 
       
        END.
        
        IF  craplcr.dsoperac = "EMPRESTIMO" THEN       
            ASSIGN aux_vlsdempr = aux_vlsdempr + aux_vlsdeved.
        ELSE /** Financiamento **/
            ASSIGN aux_vlsdfina = aux_vlsdfina + aux_vlsdeved.
        
        ASSIGN aux_tot_vlemprst = aux_tot_vlemprst + aux_vlsdeved
 
        /* Total de prestacoes em aberto */
               aux_tot_vltotpar = aux_tot_vltotpar + crapepr.vlpreemp.
        
        /* Total de operacoes contratadas no dia */
        IF glb_dtmvtolt = crapepr.dtmvtolt THEN
           ASSIGN aux_tot_vlopcdia = aux_tot_vlopcdia + crapepr.vlemprst.
        
    END.  /*  Fim do FOR EACH crapepr  */

    
    /*  DESCONTO DE CHEQUES ................................................. */
       
    ASSIGN aux_vlsdeved = 0
           aux_nrctrato = 0
           aux_cdlcremp = 0
           aux_dtpropos = ?
           aux_dtefetiv = ?
           aux_inprejuz = 0
           aux_qtpreemp = 0
           aux_vlemprst = 0
           aux_cdfinemp = 0
           aux_dtdpagto = ?
           aux_cdageepr = 0
           aux_flgareal = FALSE. 
           
    FIND FIRST craplim WHERE craplim.cdcooper = glb_cdcooper       AND
                             craplim.nrdconta = crapass.nrdconta   AND
                             craplim.tpctrlim = 2                  AND
                             craplim.insitlim = 2
                             NO-LOCK NO-ERROR.
                                
    IF   AVAILABLE craplim   THEN
         ASSIGN aux_tot_vllimdsc = craplim.vllimite
                aux_nrctrato     = craplim.nrctrlim.
                 
    FOR EACH crapcdb WHERE crapcdb.cdcooper = glb_cdcooper       AND
                           crapcdb.nrdconta = crapass.nrdconta   AND
                           crapcdb.insitchq = 2                  AND
                           crapcdb.dtlibera > glb_dtmvtolt       NO-LOCK:
    
        ASSIGN aux_vlsdeved = aux_vlsdeved + crapcdb.vlcheque.
        
        IF   NOT AVAILABLE craplim   THEN
             ASSIGN aux_nrctrato = crapcdb.nrctrlim.

    END.  /*  Fim do FOR EACH crapcdb  */
    
    /* Total de operacoes contratadas no dia */
    IF AVAILABLE craplim THEN
       IF glb_dtmvtolt = craplim.dtpropos THEN
          ASSIGN aux_tot_vlopcdia = aux_tot_vlopcdia + craplim.vllimite.
    
    IF   aux_vlsdeved > 0   THEN
         DO:
             FIND craplim WHERE craplim.cdcooper = glb_cdcooper       AND
                                craplim.nrdconta = crapass.nrdconta   AND
                                craplim.tpctrlim = 2                  AND
                                craplim.nrctrlim = aux_nrctrato
                                NO-LOCK NO-ERROR.
                                
             IF   NOT AVAILABLE craplim   THEN
                  ASSIGN aux_descricao_linha = " ".

             ELSE
                  DO:
                      FIND crapldc WHERE 
                           crapldc.cdcooper = glb_cdcooper       AND
                           crapldc.cddlinha = craplim.cddlinha   AND
                           crapldc.tpdescto = 2 
                           NO-LOCK NO-ERROR.
        
                      IF   AVAILABLE crapldc   THEN
                           DO:
                                ASSIGN  aux_descricao_linha = crapldc.dsdlinha
                                        aux_cdlcremp        = crapldc.cddlinha.
                           END.
                           
                      ASSIGN aux_dtpropos = craplim.dtpropos
                             aux_dtefetiv = craplim.dtinivig.

                  END.
             
             ASSIGN aux_tpdsaldo = 2 /* Desconto de Cheques */
                    aux_descricao_finalidade = " ".
 
             DO TRANSACTION ON ERROR UNDO, RETURN:
 
                RUN atualiza_crapsdv.
             
             END.
             
             ASSIGN aux_tot_vldeschq = aux_tot_vldeschq + aux_vlsdeved.
                         
         END.
         
    /*  DESCONTO DE TITULOS ................................................. */
       
    ASSIGN aux_vlsdeved = 0
           aux_nrctrato = 0
           aux_cdlcremp = 0
           aux_dtpropos = ?
           aux_dtefetiv = ?.

    FIND FIRST craplim WHERE craplim.cdcooper = glb_cdcooper       AND
                             craplim.nrdconta = crapass.nrdconta   AND
                             craplim.tpctrlim = 3                  AND
                             craplim.insitlim = 2
                             NO-LOCK NO-ERROR.
                                
    IF   AVAILABLE craplim   THEN
         ASSIGN aux_tot_vllimtit = craplim.vllimite
                aux_nrctrato     = craplim.nrctrlim.

    FOR EACH craptdb WHERE (craptdb.cdcooper =  glb_cdcooper     AND
                            craptdb.nrdconta =  crapass.nrdconta AND
                            craptdb.insittit =  4                AND
                            craptdb.dtvencto >= glb_dtmvtolt)
                           OR
                           (craptdb.cdcooper = glb_cdcooper     AND
                            craptdb.nrdconta = crapass.nrdconta AND
                            craptdb.insittit = 2                AND
                            craptdb.dtdpagto = glb_dtmvtolt) NO-LOCK:
    
        FIND crapcob WHERE crapcob.cdcooper = glb_cdcooper     AND
                           crapcob.cdbandoc = craptdb.cdbandoc AND
                           crapcob.nrdctabb = craptdb.nrdctabb AND
                           crapcob.nrcnvcob = craptdb.nrcnvcob AND
                           crapcob.nrdconta = craptdb.nrdconta AND
                           crapcob.nrdocmto = craptdb.nrdocmto 
                           NO-LOCK NO-ERROR.
                               
        IF   NOT AVAILABLE crapcob   THEN
             DO:
                 UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + 
                                   " - " + glb_cdprogra + "' --> '" + 
                                   "'Titulo em desconto nao encontrado" +
                                   " no crapcob - ROWID(craptdb) = " +
                                   STRING(ROWID(craptdb)) +
                                   "' >> log/proc_batch.log").
                 NEXT.
             END.
        
        /*  Se foi pago via CAIXA, InternetBank ou TAA
            Despreza, pois ja esta pago, o dinheiro 
            ja entrou para a cooperativa */
        IF  craptdb.insittit = 2  AND
           (crapcob.indpagto = 1  OR
            crapcob.indpagto = 3  OR
            crapcob.indpagto = 4) THEN /** TAA **/
            NEXT.        
    
        ASSIGN aux_vlsdeved = aux_vlsdeved + craptdb.vltitulo.
        
        IF   NOT AVAILABLE craplim   THEN
             ASSIGN aux_nrctrato = craptdb.nrctrlim.

    END.  /*  Fim do FOR EACH craptdb  */
    
    /* Total de operacoes contratadas no dia */
    IF  AVAILABLE craplim  THEN
        IF  glb_dtmvtolt = craplim.dtpropos  THEN
            ASSIGN aux_tot_vlopcdia = aux_tot_vlopcdia + craplim.vllimite.
    
    IF   aux_vlsdeved > 0   THEN
         DO:
             FIND craplim WHERE craplim.cdcooper = glb_cdcooper       AND
                                craplim.nrdconta = crapass.nrdconta   AND
                                craplim.tpctrlim = 3                  AND
                                craplim.nrctrlim = aux_nrctrato
                                NO-LOCK NO-ERROR.
                                
             IF   NOT AVAILABLE craplim   THEN
                  ASSIGN aux_descricao_linha = " ".
             ELSE
                  DO:
                      FIND crapldc WHERE 
                           crapldc.cdcooper = glb_cdcooper       AND
                           crapldc.cddlinha = craplim.cddlinha   AND
                           crapldc.tpdescto = 3 
                           NO-LOCK NO-ERROR.
        
                      IF   AVAILABLE crapldc   THEN
                           ASSIGN  aux_descricao_linha = crapldc.dsdlinha
                                   aux_cdlcremp        = crapldc.cddlinha.
                                   
                      ASSIGN aux_dtpropos = craplim.dtpropos
                             aux_dtefetiv = craplim.dtinivig.
                  END.
             
             ASSIGN aux_tpdsaldo = 3  /* Desconto de Titulos */
                    aux_descricao_finalidade = " ".
 
             DO TRANSACTION ON ERROR UNDO, RETURN:
 
                RUN atualiza_crapsdv.
             
             END.
             
             ASSIGN aux_tot_vldestit = aux_tot_vldestit + aux_vlsdeved.
         END.     

    /* LIMITE DE CREDITO .................................................... */
    
    ASSIGN aux_vlbloque = crapsld.vlsdchsl + crapsld.vlsddisp
           aux_dtpropos = ?
           aux_dtefetiv = ?.
 
    IF   aux_vlbloque < 0   THEN
         DO:
             FIND FIRST craplim WHERE craplim.cdcooper = glb_cdcooper       AND
                                      craplim.nrdconta = crapass.nrdconta   AND
                                      craplim.tpctrlim = 1                  AND
                                      craplim.insitlim = 2 USE-INDEX craplim1
                                      NO-LOCK NO-ERROR.
    
             IF   AVAILABLE craplim   THEN
                  DO:
                      IF  (aux_vlbloque * -1 ) > craplim.vllimite   THEN
                           ASSIGN aux_vlsdeved = craplim.vllimite.   
                      ELSE
                           ASSIGN aux_vlsdeved = aux_vlbloque * -1.
           
                      ASSIGN aux_descricao_linha = "LIMITE DE CREDITO"
                             aux_tpdsaldo = 6 /* Limite de Credito */
                             aux_nrctrato = craplim.nrctrlim
                             aux_descricao_finalidade = " "
                             aux_cdlcremp = 0
                      
                             aux_dtpropos = craplim.dtpropos
                             aux_dtefetiv = craplim.dtinivig.

                      DO TRANSACTION ON ERROR UNDO, RETURN:
                         
                         RUN atualiza_crapsdv.
                      
                      END.
                        
                     ASSIGN aux_tot_vllimutl = aux_tot_vllimutl + aux_vlsdeved.                      
                      /* Total de operacoes contratadas no dia */
                      IF glb_dtmvtolt = craplim.dtpropos THEN
                         ASSIGN aux_tot_vlopcdia = aux_tot_vlopcdia + 
                                                   craplim.vllimite.
                END.
         END.

    /* ADIANTAMENTO A DEPOSITANTES .......................................... */
            
    ASSIGN aux_vlsdeved              = 0
           aux_vlsdeved_limite_conta = 0
           aux_dtpropos              = ?
           aux_dtefetiv              = ?.
                 
    IF   crapass.vllimcre > 0   THEN
         ASSIGN aux_vlsdeved_limite_conta = aux_vlsdeved_limite_conta + 
                                                         crapass.vllimcre.
                 
    ASSIGN aux_vlbloque = crapsld.vlsddisp + crapsld.vlsdchsl.
       
    IF   aux_vlbloque < 0   THEN
         DO:
             IF  (aux_vlbloque  * -1 ) >  aux_vlsdeved_limite_conta   THEN
                  ASSIGN aux_vlsdeved =  (aux_vlbloque * -1) - 
                                            aux_vlsdeved_limite_conta.
             ELSE
                  ASSIGN aux_vlsdeved = 0.
    
             IF   aux_vlsdeved > 0   THEN 
                  DO:
                      ASSIGN aux_descricao_linha = "ADIANTAMENTO A DEPOSITANTES"
                             aux_tpdsaldo = 5  /* Credito em Liquidacao */
                             aux_nrctrato = crapass.nrdconta 
                             aux_descricao_finalidade = " "
                             aux_cdlcremp = 0.

                      DO TRANSACTION ON ERROR UNDO, RETURN:
    
                         RUN atualiza_crapsdv.
                         
                      END.

                      ASSIGN aux_tot_vldclutl = aux_tot_vldclutl + aux_vlsdeved.
                  END.
         END.
        
    /* APLICACOES ........................................................... */
    TRANS_1:

    FOR EACH craprda WHERE craprda.cdcooper = glb_cdcooper     AND
                           craprda.insaqtot = 0                AND
                           craprda.cdageass = crapass.cdagenci AND
                           craprda.nrdconta = crapass.nrdconta
                           NO-LOCK TRANSACTION ON ERROR UNDO, RETURN:
                 
        
        /* Calcular o Saldo da aplicacao ate a data do movimento */

        IF  craprda.tpaplica = 3  THEN
            DO:
                { sistema/generico/includes/b1wgen0004.i }
                
                IF  aux_vlsdrdca <= 0  THEN
                    NEXT.

                ASSIGN aux_descricao_linha = "APLICACAO RDCA"
                       aux_vlsdeved        = aux_vlsdrdca
                       aux_vlsrdc30        = aux_vlsrdc30 + aux_vlsdrdca.
            END.
        ELSE
        IF  craprda.tpaplica = 5  THEN
            DO:
                { sistema/generico/includes/b1wgen0004a.i }
            
                IF  rd2_vlsdrdca <= 0  THEN
                    NEXT.
                    
                ASSIGN aux_descricao_linha = "APLICACAO RDCA60"
                       aux_vlsdeved        = rd2_vlsdrdca
                       aux_vlsrdc60        = aux_vlsrdc60 + rd2_vlsdrdca.  
            END.         
        ELSE
            DO:
                FIND crapdtc WHERE crapdtc.cdcooper = glb_cdcooper     AND
                                   crapdtc.tpaplica = craprda.tpaplica
                                   NO-LOCK NO-ERROR.

                IF  NOT AVAILABLE crapdtc  THEN
                    DO:
                        ASSIGN glb_cdcritic = 346.
                        RUN fontes/critic.p.
                         
                        UNIX SILENT VALUE("echo " + 
                                        STRING(TIME,"HH:MM:SS") +
                                        " - " + glb_cdprogra + "' --> '" +
                                        glb_dscritic + " Conta/dv: " +
                                        STRING(craprda.nrdconta,"zzzz,zzz,9") +
                                        " Nr.Aplicacao: " +
                                        STRING(craprda.nraplica,"zzz,zz9") +
                                        " >> log/proc_batch.log").
                        
                        ASSIGN glb_cdcritic = 0.
                        UNDO TRANS_1, RETURN.      
                    END.
                
                EMPTY TEMP-TABLE craterr.
                              
                ASSIGN aux_vlsldrdc = 0.    

                IF  crapdtc.tpaplrdc = 1  THEN /* RDCPRE */
                    DO:
                        ASSIGN aux_descricao_linha = "APLICACAO RDCPRE".
                        
                        RUN saldo_rdc_pre IN h-b1wgen0004 
                                                    (INPUT glb_cdcooper,
                                                     INPUT craprda.nrdconta,
                                                     INPUT craprda.nraplica,
                                                     INPUT glb_dtmvtolt,
                                                     INPUT ?,
                                                     INPUT ?,
                                                     INPUT 0,
                                                     INPUT FALSE,
                                                     INPUT-OUTPUT aux_vlsldrdc,
                                                     OUTPUT aux_vlrdirrf,
                                                     OUTPUT aux_perirrgt,
                                                     OUTPUT TABLE craterr).
                     
                        IF  RETURN-VALUE = "NOK"  THEN
                            DO:
                                FIND FIRST craterr NO-LOCK NO-ERROR.
                                  
                                IF  AVAILABLE craterr  THEN
                                    glb_dscritic = craterr.dscritic.

                                UNIX SILENT VALUE("echo " + 
                                           STRING(TIME,"HH:MM:SS") +
                                           " - " + glb_cdprogra + "' --> '" +
                                           glb_dscritic + " Conta/dv: " +
                                           STRING(craprda.nrdconta,"zzzz,zzz,9")
                                           + " Nr.Aplicacao: " +
                                           STRING(craprda.nraplica,"zzz,zz9") +
                                           " >> log/proc_batch.log").
                                UNDO TRANS_1, RETURN.
                            END.

                        IF  aux_vlsldrdc > 0  THEN
                            ASSIGN aux_vlsrdcpr = aux_vlsrdcpr + aux_vlsldrdc. 

                    END.
                ELSE
                IF  crapdtc.tpaplrdc = 2  THEN /* RDCPOS */
                    DO:
                        ASSIGN aux_descricao_linha = "APLICACAO RDCPOS".
                        
                        RUN saldo_rdc_pos IN h-b1wgen0004
                                                 (INPUT glb_cdcooper,
                                                  INPUT craprda.nrdconta,
                                                  INPUT craprda.nraplica,
                                                  INPUT glb_dtmvtolt,
                                                  INPUT glb_dtmvtolt,
                                                  INPUT FALSE,
                                                  INPUT FALSE,
                                                  OUTPUT aux_vlsldrdc,
                                                  OUTPUT aux_vlrentot,
                                                  OUTPUT aux_vlrdirrf,
                                                  OUTPUT aux_perirrgt,
                                                  OUTPUT TABLE craterr).
                                                                               
                        IF  RETURN-VALUE = "NOK"  THEN
                            DO:
                                FIND FIRST craterr NO-LOCK NO-ERROR.
                                  
                                IF  AVAILABLE craterr  THEN
                                    glb_dscritic = craterr.dscritic.

                                UNIX SILENT VALUE("echo " + 
                                           STRING(TIME,"HH:MM:SS") +
                                           " - " + glb_cdprogra + "' --> '" +
                                           glb_dscritic + " Conta/dv: " +
                                           STRING(craprda.nrdconta,"zzzz,zzz,9")
                                           + " Nr.Aplicacao: " +
                                           STRING(craprda.nraplica,"zzz,zz9") +
                                           " >> log/proc_batch.log").          
                                UNDO TRANS_1, RETURN.   
                            END.  
                        
                        IF  aux_vlsldrdc > 0  THEN
                            ASSIGN aux_vlsrdcpo = aux_vlsrdcpo + aux_vlsldrdc. 
                    
                    END.

                IF  aux_vlsldrdc <= 0  THEN
                    NEXT.
                    
                ASSIGN aux_vlsdeved = aux_vlsldrdc.
            END.
            
        ASSIGN aux_tpdsaldo             = 7 /* Aplicacao */
               aux_nrctrato             = craprda.nraplica
               aux_cdlcremp             = 0
               aux_descricao_finalidade = " "
               aux_tot_vlsdrdca         = aux_tot_vlsdrdca + aux_vlsdeved
               aux_dtpropos             = craprda.dtmvtolt
               aux_dtefetiv             = craprda.dtmvtolt.

        RUN atualiza_crapsdv.
    
    END. /* Fim do FOR EACH craprda */
   
    /* POUPANCA PROGRAMADA .................................................. */

    TRANS_POUP:

    FOR EACH craprpp WHERE craprpp.cdcooper = glb_cdcooper   AND
                           craprpp.nrdconta = crapass.nrdconta
                           USE-INDEX craprpp1 NO-LOCK
                           TRANSACTION ON ERROR UNDO, RETURN:

        IF   craprpp.cdsitrpp = 1   THEN
             ASSIGN aux_tot_vlprerpp = aux_tot_vlprerpp + craprpp.vlprerpp.

        /* Calcular o Saldo ate a data do movimento */
            
        { includes/poupanca.i }

        IF   rpp_vlsdrdpp <= 0   THEN
             NEXT.
        
        ASSIGN  aux_vlsdeved = rpp_vlsdrdpp
       
                aux_descricao_linha = "POUPANCA PROGRAMADA"
            
                aux_tpdsaldo = 8 /* Poupanca Progr.  */
                aux_nrctrato = craprpp.nrctrrpp
                aux_descricao_finalidade = " "
                aux_cdlcremp = 0
        
                aux_dtpropos = craprpp.dtmvtolt
                aux_dtefetiv = craprpp.dtmvtolt.
        
        RUN atualiza_crapsdv.
                                                      
        ASSIGN aux_tot_vlsdrdpp = aux_tot_vlsdrdpp + aux_vlsdeved.
         
    END.  /*  Fim do FOR EACH craprpp  */
    
    DO TRANSACTION ON ERROR UNDO, RETURN:
       
       RUN atualiza_crapsda.
    
    END.
    
    /*  CUSTODIA ........................................................... */
    ASSIGN aux_tot_vlcheque = 0.    
    FOR EACH crapcst NO-LOCK WHERE crapcst.cdcooper  = glb_cdcooper      AND
                                   crapcst.dtlibera >= glb_dtmvtolt      AND
                                   crapcst.nrdconta  = crapass.nrdconta  AND
                                   crapcst.dtdevolu  = ?
                     BREAK BY crapcst.dtlibera: 
        
        ASSIGN aux_tot_vlcheque = aux_tot_vlcheque + crapcst.vlcheque.
           
        IF LAST-OF(crapcst.dtlibera) THEN
          DO:
            ASSIGN aux_dataano = STRING(crapcst.dtlibera)
                   aux_dataano = SUBSTRING(aux_dataano,R-INDEX(aux_dataano,"/") + 1,
                                           LENGTH(aux_dataano)) 
                   aux_nrdconta             = crapass.nrdconta 
                   aux_tpdsaldo             = 9 /* Custodia */
                   aux_nrctrato             = 
                   INTE(aux_dataano +
                        STRING(MONTH(crapcst.dtlibera),"99")  +
                        STRING(DAY(crapcst.dtlibera),"99"))
                   aux_vlsdeved             = aux_tot_vlcheque
                   aux_descricao_linha      = "CUSTODIA"
                   aux_descricao_finalidade = " " 
                   aux_cdlcremp             = 0 
                   aux_dtpropos             = ? 
                   aux_dtefetiv             = crapcst.dtlibera 
                   aux_inprejuz             = 0 
                   aux_qtpreemp             = 0 
                   aux_vlemprst             = 0 
                   aux_cdfinemp             = 0 
                   aux_dtdpagto             = ? 
                   aux_cdageepr             = 0 
                   aux_flgareal             = False.
     
            RUN atualiza_crapsdv.
            ASSIGN aux_tot_vlcheque = 0.
          END.
    END. /* Fim do FOR EACH crapcst */
    

END.  /*  Fim do FOR EACH crapass  */

/* deleta instancia da  b1wgen0159 */ 
RUN controla_imunidade IN h-b1wgen0004 
                      (INPUT FALSE, /* instancia */
                       INPUT TRUE, /* deleta */
                       INPUT glb_cdprogra).

IF  VALID-HANDLE(h-b1wgen0159) THEN
    DELETE PROCEDURE h-b1wgen0159.

DELETE PROCEDURE h-b1wgen0004.

RUN sistema/generico/procedures/bo_paralelo.p PERSISTENT SET h_paralelo.
    
RUN finaliza_paralelo IN h_paralelo (INPUT aux_idparale,
                                     INPUT aux_idprogra).
    
DELETE PROCEDURE h_paralelo.

UNIX SILENT VALUE("echo " + 
                  STRING(glb_dtmvtolt,"99/99/9999") + " - " +
                  STRING(TIME,"HH:MM:SS") +
                  " - " + glb_cdprogra + "' -->    '" +
                  "Fim da Execucao Paralela - Programa 1 - PA: " +
                  STRING(aux_cdagenci,"zz9") +
                  " >> log/crps445.log").

QUIT.



/* .......................................................................... */

PROCEDURE atualiza_crapsdv.

   CREATE crapsdv.
   ASSIGN crapsdv.cdcooper = glb_cdcooper
          crapsdv.nrdconta = crapass.nrdconta
          crapsdv.tpdsaldo = aux_tpdsaldo
          crapsdv.nrctrato = aux_nrctrato
          crapsdv.vldsaldo = aux_vlsdeved
          crapsdv.dtmvtolt = glb_dtmvtolt
          crapsdv.dsdlinha = aux_descricao_linha
          crapsdv.dsfinali = aux_descricao_finalidade
          crapsdv.cdlcremp = aux_cdlcremp
          crapsdv.dtpropos = aux_dtpropos
          crapsdv.dtefetiv = aux_dtefetiv
          crapsdv.inprejuz = aux_inprejuz
          crapsdv.qtpreemp = aux_qtpreemp
          crapsdv.vlemprst = aux_vlemprst
          crapsdv.cdfinemp = aux_cdfinemp
          crapsdv.dtdpagto = aux_dtdpagto
          crapsdv.cdageepr = aux_cdageepr
          crapsdv.flgareal = aux_flgareal.
          
END PROCEDURE.

PROCEDURE atualiza_crapsda.
    
    /* Plano Capital ........................................................ */
    
    FIND FIRST crappla WHERE crappla.cdcooper = glb_cdcooper       AND
                             crappla.nrdconta = crapass.nrdconta   AND
                             crappla.tpdplano = 1                  AND
                             crappla.cdsitpla = 1
                             USE-INDEX crappla3 NO-LOCK NO-ERROR.

    IF   AVAILABLE crappla THEN
         ASSIGN aux_tot_vlprepla = crappla.vlprepla.
/*    
    /* Credito Salario ...................................................... */

    FIND LAST craplcm USE-INDEX craplcm2 NO-LOCK WHERE
              craplcm.cdcooper = glb_cdcooper      AND
              craplcm.nrdconta = crapass.nrdconta  AND
              craplcm.cdhistor = 8 NO-ERROR.
    
    IF   AVAILABLE craplcm   THEN                            
         ASSIGN aux_tot_vlcrdsal = craplcm.vllanmto.
*/    
    /*  Cheques liquidados .................................................. */
    FOR EACH crapfdc WHERE (crapfdc.cdcooper = glb_cdcooper      AND
                            crapfdc.nrdconta = crapass.nrdconta  AND
                            crapfdc.incheque = 0)                OR

                           (crapfdc.cdcooper = glb_cdcooper      AND
                            crapfdc.nrdconta = crapass.nrdconta  AND
                            crapfdc.incheque = 2)                OR

                           (crapfdc.cdcooper = glb_cdcooper      AND
                            crapfdc.nrdconta = crapass.nrdconta  AND
                            crapfdc.incheque = 5                 AND
                            crapfdc.dtliqchq = glb_dtmvtolt) NO-LOCK:
               
        IF   crapfdc.dtretchq = ?              OR
            (crapfdc.dtliqchq <> ?             AND
             crapfdc.dtliqchq < glb_dtmvtolt)  THEN
             NEXT.
        
        IF   crapfdc.dtliqchq = glb_dtmvtolt   AND
             crapfdc.incheque = 5              THEN
             ASSIGN aux_tot_qtchqliq = aux_tot_qtchqliq + 1.
    
        IF   crapfdc.incheque = 0   OR
             crapfdc.incheque = 2   THEN
             ASSIGN aux_tot_qtchqass = aux_tot_qtchqass + 1.

    END.  /*  Fim do FOR EACH crapfdc  */
 
    /* Devolucoes */ 
    FOR EACH crapneg WHERE crapneg.cdcooper = glb_cdcooper     AND
                           crapneg.nrdconta = crapass.nrdconta AND
                           crapneg.dtiniest >= glb_dtmvtolt - 180 
                           /* Ultimos 6 meses */
                           USE-INDEX crapneg2 NO-LOCK:
        /*
        ASSIGN aux_tot_qtdevolu = aux_tot_qtdevolu + crapneg.vlestour.
        */
        ASSIGN aux_tot_qtdevolu = aux_tot_qtdevolu + 1.
    END.
    
    /* Total de rendimentos do titular - pessoa fisica*/ 
    IF crapass.inpessoa = 1 THEN
    DO:
        FOR EACH crapttl WHERE crapttl.cdcooper = glb_cdcooper       AND
                               crapttl.nrdconta = crapass.nrdconta   NO-LOCK:
       
            ASSIGN aux_tot_vltotren = aux_tot_vltotren    + crapttl.vlsalari +
                                      crapttl.vldrendi[1] + crapttl.vldrendi[2]+
                                      crapttl.vldrendi[3] + crapttl.vldrendi[4]+
                                      crapttl.vldrendi[5] + crapttl.vldrendi[6].

        END.  
          
    END.
    
    DO WHILE TRUE:
    
       FIND crapsda WHERE crapsda.cdcooper = glb_cdcooper       AND
                          crapsda.nrdconta = crapass.nrdconta   AND
                          crapsda.dtmvtolt = glb_dtmvtolt
                          USE-INDEX crapsda1
                          EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                          
       IF   AVAILABLE crapsda    THEN
            DO:
                ASSIGN crapsda.vlsdeved = aux_tot_vlemprst
                       crapsda.vldeschq = aux_tot_vldeschq
                       crapsda.vldestit = aux_tot_vldestit
                       crapsda.vllimutl = aux_tot_vllimutl
                       crapsda.vladdutl = aux_tot_vldclutl
                       crapsda.vlsdrdca = aux_tot_vlsdrdca
                       crapsda.vlsdrdpp = aux_tot_vlsdrdpp
                       crapsda.vllimdsc = aux_tot_vllimdsc
                       crapsda.vllimtit = aux_tot_vllimtit
                       crapsda.vlprepla = aux_tot_vlprepla
                       crapsda.vlprerpp = aux_tot_vlprerpp
                       crapsda.vlcrdsal = aux_tot_vlcrdsal 
                       crapsda.qtchqliq = aux_tot_qtchqliq
                       crapsda.qtchqass = aux_tot_qtchqass
                       crapsda.vltotpar = aux_tot_vltotpar
                       crapsda.vlopcdia = aux_tot_vlopcdia
                       crapsda.qtdevolu = aux_tot_qtdevolu
                       crapsda.vltotren = aux_tot_vltotren
                       crapsda.vlsrdc30 = aux_vlsrdc30  
                       crapsda.vlsrdc60 = aux_vlsrdc60
                       crapsda.vlsrdcpr = aux_vlsrdcpr
                       crapsda.vlsrdcpo = aux_vlsrdcpo
                       crapsda.vlsdempr = aux_vlsdempr 
                       crapsda.vlsdfina = aux_vlsdfina.
                
                DO WHILE TRUE:
                
                   FIND crapscd WHERE crapscd.cdcooper = glb_cdcooper     AND
                                      crapscd.nrcpfcgc = crapass.nrcpfcgc AND
                                      crapscd.dtmvtolt = glb_dtmvtolt 
                                      EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
               
                   IF   NOT AVAILABLE crapscd  THEN
                        IF   LOCKED crapscd   THEN
                             DO:
                                 PAUSE 2 NO-MESSAGE.
                                 NEXT.
                             END.
                        ELSE
                             DO:
                                 CREATE crapscd.
                                 ASSIGN crapscd.cdcooper = glb_cdcooper 
                                        crapscd.nrcpfcgc = crapass.nrcpfcgc
                                        crapscd.dtmvtolt = glb_dtmvtolt.
                             END.         
                   LEAVE.
                
                END.  /*  Fim do DO WHILE TRUE  */
                
                ASSIGN crapscd.vlsddisp = crapscd.vlsddisp + crapsda.vlsddisp
                       crapscd.vlsdchsl = crapscd.vlsdchsl + crapsda.vlsdchsl
                       crapscd.vlsdbloq = crapscd.vlsdbloq + crapsda.vlsdbloq
                       crapscd.vlsdblpr = crapscd.vlsdblpr + crapsda.vlsdblpr
                       crapscd.vlsdblfp = crapscd.vlsdblfp + crapsda.vlsdblfp
                       crapscd.vlsdindi = crapscd.vlsdindi + crapsda.vlsdindi
                       crapscd.vllimcre = crapscd.vllimcre + crapsda.vllimcre

                       crapscd.vlsdeved = crapscd.vlsdeved + crapsda.vlsdeved
                       crapscd.vldeschq = crapscd.vldeschq + crapsda.vldeschq
                       crapscd.vllimutl = crapscd.vllimutl + crapsda.vllimutl
                       crapscd.vladdutl = crapscd.vladdutl + crapsda.vladdutl
                       crapscd.vlsdrdca = crapscd.vlsdrdca + crapsda.vlsdrdca
                       crapscd.vlsdrdpp = crapscd.vlsdrdpp + crapsda.vlsdrdpp
                       crapscd.vllimdsc = crapscd.vllimdsc + crapsda.vllimdsc
                       crapscd.vllimtit = crapscd.vllimtit + crapsda.vllimtit
                       crapscd.vldestit = crapscd.vldestit + crapsda.vldestit
                       crapscd.vlprepla = crapscd.vlprepla + crapsda.vlprepla
                       crapscd.vlprerpp = crapscd.vlprerpp + crapsda.vlprerpp
                       crapscd.vlcrdsal = crapscd.vlcrdsal + crapsda.vlcrdsal
                       crapscd.qtchqliq = crapscd.qtchqliq + crapsda.qtchqliq
                       crapscd.qtchqass = crapscd.qtchqass + crapsda.qtchqass.
            END.
       ELSE
       IF   LOCKED crapsda   THEN
            DO:
                PAUSE 2 NO-MESSAGE.
                NEXT.
            END.

       LEAVE.
    
    END.  /*  Fim do DO WHILE TRUE  */

    ASSIGN aux_tot_vlemprst = 0
           aux_tot_vldeschq = 0
           aux_tot_vldestit = 0
           aux_tot_vllimutl = 0
           aux_tot_vldclutl = 0
           aux_tot_vlsdrdca = 0
           aux_tot_vlsdrdpp = 0
           aux_tot_vllimdsc = 0
           aux_tot_vllimtit = 0
           aux_tot_vlprepla = 0
           aux_tot_vlprerpp = 0  
           aux_tot_vlcrdsal = 0 
           aux_tot_qtchqliq = 0
           aux_tot_qtchqass = 0
           aux_tot_vltotpar = 0
           aux_tot_vlopcdia = 0
           aux_tot_qtdevolu = 0
           aux_tot_vltotren = 0
               aux_vlsdfina = 0  
               aux_vlsdempr = 0 
               aux_vlsrdc30 = 0
               aux_vlsrdc60 = 0
               aux_vlsrdcpr = 0
               aux_vlsrdcpo = 0.

END PROCEDURE.


/* .......................................................................... */

