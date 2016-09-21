/* .............................................................................

   Programa: Fontes/ver_capital.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Ze Eduardo/Edson
   Data    : Dezembro/2001.                    Ultima atualizacao: 18/06/2014
   
   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Verificar se o associado possui capital.

               par_nrdconta = Conta do associado em questao
               par_vllanmto = Se maior que 0, verifica de pode sacar o valor
                              se for 0, apenas testa se o associado possui
                              capital suficiente para efetuar a operacao.
    
   Alteracoes: 28/02/2002 - Incluir espaco no par_dscritic (Ze Eduardo).
   
               01/04/2004 - Ajustes para a Credifiesc (Deborah).

               17/06/2004 - Tratar tempo minimo de sociedade (Edson).

               02/07/2004 - Tratar melhor critica 735(qdo associado for   
                            admitido no mes corrente)(Mirtes)
               
               22/09/2004 - Incluidos historicos 492/494/496(CI)(Mirtes)

               27/09/2005 - Saldo das aplicacoes rdca nao enxergavar imposto.
                            Usado saldo_rdca_resgate (Margarete).

               28/09/2005 - Modificado FIND FIRST para FIND na tabela 
                            crapcop.cdcooper = glb_cdcooper (Diego).
                            
               10/10/2005 - Alteracao de crapchq p/ crapfdc (SQLWorks - Andre).
  
               24/01/2006 - Unificacao dos Bancos - SQLWorks - Fernando
               
               22/06/2007 - Entre as aplicacoes somente verifica RDCA30 e RDCA60
                            (Elton).

               30/07/2007 - Tratamento para aplicacoes RDC (David).

               15/10/2008 - Tratamento para desconto de titulos (David).
               
               02/06/2011 - Estanciado a b1wgen0004 para o inicio do programa
                            e deletado ao final para ganho de performance
                            (Adriano).
                            
               16/09/2013 - Tratamento para Imunidade Tributaria (Ze).
               
               18/06/2014 - Exclusao do uso da tabela crapcar.
                            (Tiago Castro - Tiago RKAM)
............................................................................. */

{ includes/var_online.i }

{ includes/var_rdca2.i }

DEF INPUT  PARAMETER par_nrdconta AS INT                         NO-UNDO.
DEF INPUT  PARAMETER par_vllanmto AS DEC                         NO-UNDO.
DEF INPUT  PARAMETER par_dtmvtolt AS DATE                        NO-UNDO.
DEF OUTPUT PARAMETER par_cdcritic AS INT                         NO-UNDO.
DEF OUTPUT PARAMETER par_dscritic AS CHAR                        NO-UNDO.

DEF        VAR aux_contador AS INTE                                  NO-UNDO.
DEF        VAR aux_diasmini AS INTE                                  NO-UNDO.

DEF        VAR aux_data     AS DATE                                  NO-UNDO.

DEF        VAR aux_sldresga AS DECI                                  NO-UNDO.
DEF        VAR aux_vlsldrdc AS DECI DECIMALS 8                       NO-UNDO.
DEF        VAR aux_perirrgt AS DECI DECIMALS 2                       NO-UNDO.
DEF        VAR aux_vlcapmin AS DECI                                  NO-UNDO.
DEF        VAR aux_vldsaldo AS DECI                                  NO-UNDO.

DEF        VAR aux_vlrvtfim LIKE craplap.vllanmto                    NO-UNDO.
DEF        VAR aux_vlrrgtot LIKE craplap.vllanmto                    NO-UNDO.
DEF        VAR aux_vlirftot LIKE craplap.vllanmto                    NO-UNDO.
DEF        VAR aux_vlrendmm LIKE craplap.vlrendmm                    NO-UNDO.

DEF        VAR h-b1wgen0004 AS HANDLE                                NO-UNDO.

DEF TEMP-TABLE craterr LIKE craperr.

{ includes/var_faixas_ir.i "NEW"}

ASSIGN par_cdcritic = 0
       par_dscritic = "".

RUN sistema/generico/procedures/b1wgen0004.p PERSISTENT SET h-b1wgen0004.

FIND FIRST crapdat WHERE crapdat.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.

/*  Le registro de matricula  */

FIND FIRST crapmat WHERE crapmat.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.

/*  Le registro no crapcop  */

FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.

/*  Le tabela de valor minimo do capital  */

FIND craptab WHERE craptab.cdcooper = glb_cdcooper   AND
                   craptab.nmsistem = "CRED"         AND
                   craptab.tptabela = "USUARI"       AND
                   craptab.cdempres = 11             AND
                   craptab.cdacesso = "VLRUNIDCAP"   AND
                   craptab.tpregist = 1              NO-LOCK NO-ERROR.

IF   NOT AVAILABLE craptab   THEN
     aux_vlcapmin = crapmat.vlcapini.
ELSE
     aux_vlcapmin = DECIMAL(craptab.dstextab).

/*
IF   aux_vlcapmin < crapmat.vlcapini   THEN
     IF   crapcop.cdcooper <> 6 THEN
          aux_vlcapmin = crapmat.vlcapini.
*/

FIND crapass WHERE crapass.cdcooper = glb_cdcooper  AND
                   crapass.nrdconta = par_nrdconta  NO-LOCK NO-ERROR.

IF   NOT AVAILABLE crapass THEN
     DO:
         par_cdcritic = 9.
         RETURN.
     END.

IF   crapass.inpessoa = 3 THEN  
     DO:
         par_cdcritic = 0.
         RETURN.
     END.

/*  Tabela com o prazo minimo de sociedade .................................. */

FIND craptab WHERE craptab.cdcooper = glb_cdcooper      AND
                   craptab.nmsistem = "CRED"            AND
                   craptab.tptabela = "USUARI"          AND
                   craptab.cdempres = 11                AND
                   craptab.cdacesso = "PROPOSTEPR"      AND
                   craptab.tpregist = crapass.cdagenci  NO-LOCK NO-ERROR.

IF   NOT AVAILABLE craptab   THEN
     DO:
         FIND craptab WHERE craptab.cdcooper = glb_cdcooper   AND
                            craptab.nmsistem = "CRED"         AND
                            craptab.tptabela = "USUARI"       AND
                            craptab.cdempres = 11             AND
                            craptab.cdacesso = "PROPOSTEPR"   AND
                            craptab.tpregist = 0              NO-LOCK NO-ERROR.

         IF   NOT AVAILABLE craptab   THEN
              DO:     
                  par_cdcritic = 55.
                  RETURN.
              END.  
     END.

aux_diasmini = INTEGER(SUBSTRING(craptab.dstextab,36,03)).
       
/*  Le registro de capital  */

FIND crapcot WHERE crapcot.cdcooper = glb_cdcooper  AND
                   crapcot.nrdconta = par_nrdconta  NO-LOCK NO-ERROR. 
        
IF   NOT AVAILABLE crapcot THEN
     DO:
         par_cdcritic = 169.   
         RETURN.
     END.
     
IF   par_vllanmto = 0   THEN                
     DO:
         /*  Verifica tempo de sociedade  */
         /*
         IF   crapcop.cdcooper = 1   THEN   
         IF  (crapass.dtadmiss + aux_diasmini) > par_dtmvtolt   THEN
              DO:
                  par_cdcritic = 674.
                  RETURN.
              END.
         */
         /*  Verifica se ha capital suficiente  */
         
         IF   crapcot.vldcotas < aux_vlcapmin   THEN
              DO:
                /*  FIND crapadm OF crapcot NO-LOCK NO-ERROR. */
                
                 FIND crapadm WHERE crapadm.cdcooper = glb_cdcooper     AND
                                    crapadm.nrdconta = crapcot.nrdconta
                                    NO-LOCK NO-ERROR.
                  
                  IF   NOT AVAILABLE crapadm   THEN
                       DO:
                          IF   crapass.dtdemiss = ?   THEN  
                               DO:
                            
                                  ASSIGN aux_data = crapdat.dtmvtolt 
                                                  - DAY(crapdat.dtmvtolt).
                                  ASSIGN aux_data = aux_data - DAY(aux_data).
                        
                                  IF  crapass.dtadmiss <= aux_data 
                                  THEN 
                                      par_cdcritic = 735.
                                  ELSE
                                      par_cdcritic = 0.
                               END.
                          ELSE
                               par_cdcritic = 0.
                       END.
                  ELSE
                       par_cdcritic = 0.
              END.
         ELSE
              par_cdcritic = 0.        
     END.
ELSE
     DO: 
         IF   crapcot.vldcotas <> par_vllanmto   OR
              crapass.dtdemiss = ?               THEN
              DO:
                  IF  (crapcot.vldcotas - par_vllanmto) < aux_vlcapmin   THEN
                       par_cdcritic = 630.

                  RETURN.
              END.

         RUN ver_saldos.    /*  Nao permite sacar o capital se houver saldos  */
     END.

DELETE PROCEDURE h-b1wgen0004.

RETURN.

/* .......................................................................... */

PROCEDURE ver_saldos:

    par_cdcritic = 736.
    
    FIND FIRST crapepr WHERE crapepr.cdcooper = glb_cdcooper  AND
                             crapepr.nrdconta = par_nrdconta  AND
                             crapepr.inliquid = 0             NO-LOCK NO-ERROR.
                             
    IF   AVAILABLE crapepr   THEN
         DO:
            par_dscritic = " EMPRESTIMO COM SALDO DEVEDOR.".
            RETURN.
         END.
         
    FIND FIRST crappla WHERE crappla.cdcooper = glb_cdcooper  AND
                             crappla.nrdconta = par_nrdconta  AND
                             crappla.cdsitpla = 1             NO-LOCK NO-ERROR.
                             
    IF   AVAILABLE crappla   THEN
         DO:
             par_dscritic = " PLANO DE CAPITAL ATIVO.".
             RETURN.
         END.
         
    IF   crapass.vllimcre > 0   THEN
         DO:
             par_dscritic = " LIMITE DE CREDITO EM CONTA-CORRENTE.".
             RETURN.
         END.
         
    FIND FIRST crapcrd WHERE crapcrd.cdcooper = glb_cdcooper  AND
                             crapcrd.nrdconta = par_nrdconta  AND
                             crapcrd.dtcancel = ?             NO-LOCK NO-ERROR.
                             
    IF   AVAILABLE crapcrd   THEN
         DO:
             par_dscritic = " CARTAO DE CREDITO ATIVO.".
             RETURN.
         END.
    
    ASSIGN aux_vldsaldo = 0.

    TRANS_1:

    FOR EACH craprda WHERE craprda.cdcooper = glb_cdcooper AND
                           craprda.nrdconta = par_nrdconta AND
                           craprda.insaqtot = 0            AND
                          (craprda.tpaplica = 3            OR 
                           craprda.tpaplica = 5)           NO-LOCK
                           USE-INDEX craprda6:
        
        IF   craprda.tpaplica = 3 THEN
             DO:
                 { includes/aplicacao.i }
             END.
        ELSE
             DO:
                 { includes/rdca2s.i }
             END.

        ASSIGN aux_sldresga = aux_sldpresg.
        
        IF   aux_sldresga = ?   THEN 
             ASSIGN aux_sldresga = IF   craprda.tpaplica = 3 THEN 
                                        aux_vlsdrdca
                                   ELSE
                                   IF   craprda.tpaplica = 5 THEN 
                                        rd2_vlsdrdca
                                   ELSE
                                        0. 
        
        ASSIGN aux_vldsaldo = aux_vldsaldo + aux_sldresga.
    
    END.  /*  Fim do FOR EACH -- Leitura do craprda  */
    
    IF   aux_vldsaldo > 0   THEN
         DO:
             par_dscritic = " SALDO EM APLICACAO RDCA.".
             RETURN.
         END.

    FOR EACH crapdtc WHERE crapdtc.cdcooper = glb_cdcooper AND
                          (crapdtc.tpaplrdc = 1            OR
                           crapdtc.tpaplrdc = 2)           NO-LOCK,
        EACH craprda WHERE craprda.cdcooper = glb_cdcooper     AND
                           craprda.nrdconta = par_nrdconta     AND
                           craprda.insaqtot = 0                AND
                           craprda.tpaplica = crapdtc.tpaplica NO-LOCK
                           USE-INDEX craprda6: 
        
        IF  crapdtc.tpaplrdc = 1  THEN
            DO:
                ASSIGN aux_sldresga = craprda.vlsdrdca.
            END.
        ELSE
        IF  crapdtc.tpaplrdc = 2  THEN
            DO:
                FOR EACH craterr:
                    DELETE craterr.
                END.
                
                IF  VALID-HANDLE(h-b1wgen0004)  THEN
                    DO:
                        ASSIGN aux_vlrrgtot = 0
                               aux_sldresga = 0.       
                                 
                        RUN saldo_rgt_rdc_pos IN h-b1wgen0004
                                                   (INPUT glb_cdcooper,
                                                    INPUT craprda.nrdconta,
                                                    INPUT craprda.nraplica,
                                                    INPUT glb_dtmvtolt,
                                                    INPUT glb_dtmvtolt,
                                                    INPUT 0,
                                                    INPUT FALSE,
                                                    OUTPUT aux_sldpresg,
                                                    OUTPUT aux_vlrenrgt,
                                                    OUTPUT aux_vlrdirrf,
                                                    OUTPUT aux_perirrgt,
                                                    OUTPUT aux_vlrrgtot,
                                                    OUTPUT aux_vlirftot,
                                                    OUTPUT aux_vlrendmm,
                                                    OUTPUT aux_vlrvtfim,
                                                    OUTPUT TABLE craterr).
                         
                        
                                  
                        IF  RETURN-VALUE = "NOK"  THEN
                            DO:
                                FIND FIRST craterr NO-LOCK NO-ERROR.
                                  
                                IF  AVAILABLE craterr  THEN
                                    glb_cdcritic = craterr.cdcritic.

                                RETURN.   
                            END.

                        aux_sldresga = IF  aux_vlrrgtot > 0  THEN
                                           aux_vlrrgtot
                                       ELSE
                                           craprda.vlsdrdca.
                    END.
            END.

        ASSIGN aux_vldsaldo = aux_vldsaldo + aux_sldresga.
    
    END.  /*  Fim do FOR EACH -- Leitura do craprda  */
    
    IF  aux_vldsaldo > 0  THEN
        DO:
            par_dscritic = " SALDO EM APLICACAO RDC.".
            RETURN.
        END.     

    FIND FIRST crapseg WHERE crapseg.cdcooper = glb_cdcooper  AND
                             crapseg.nrdconta = par_nrdconta  AND
                             crapseg.dtfimvig > TODAY         AND
                             crapseg.dtcancel = ?             NO-LOCK NO-ERROR.
                             
    IF   AVAILABLE crapseg   THEN
         DO:
             par_dscritic = " SEGURO ATIVO.".
             RETURN.
         END.
         
    FIND FIRST crapatr WHERE crapatr.cdcooper = glb_cdcooper  AND
                             crapatr.nrdconta = par_nrdconta  AND
                             crapatr.dtfimatr = ?             NO-LOCK NO-ERROR.

    IF   AVAILABLE crapatr   THEN
         DO:
             par_dscritic = " AUTORIZACAO DE DEBITO EM CONTA-CORRENTE.".
             RETURN.
         END.
         
    FOR EACH craprpp WHERE craprpp.cdcooper = glb_cdcooper   AND
                           craprpp.nrdconta = par_nrdconta   AND
                          (craprpp.vlsdrdpp > 0              OR
                           craprpp.dtcancel = ?)             NO-LOCK:
        
        aux_vldsaldo = craprpp.vlsdrdpp.
        
        FOR EACH craplpp WHERE craplpp.cdcooper = glb_cdcooper       AND
                               craplpp.nrdconta = craprpp.nrdconta   AND
                               craplpp.nrctrrpp = craprpp.nrctrrpp   AND
                              (craplpp.cdhistor = 158                OR
                               craplpp.cdhistor = 496)               NO-LOCK:
                               
            aux_vldsaldo = aux_vldsaldo - craplpp.vllanmto.                   
        
        END.  /*  Fim do FOR EACH -- Leitura do craplpp  */
         
        IF   aux_vldsaldo > 0   THEN
             DO:
                 par_dscritic = " POUPANCA PROGRAMADA COM SALDO.".
                 RETURN.
             END.
    
    END.  /*  Fim do FOR EACH -- Leitura do craprpp  */
         
    FOR EACH crapfdc WHERE crapfdc.cdcooper = glb_cdcooper   AND
                           crapfdc.nrdconta = par_nrdconta   AND
                           crapfdc.dtretchq <> ?             NO-LOCK:
                           
        IF   crapfdc.incheque = 0   THEN
             DO:
                 IF   crapfdc.tpcheque = 1   THEN
                      par_dscritic = " TALAO DE CHEQUES EM USO.".
                 ELSE
                 IF   crapfdc.tpcheque = 2   THEN
                      par_dscritic = " TALAO DE CHEQUES TB EM USO.".
                 ELSE
                 IF   crapfdc.tpcheque = 3   THEN
                      par_dscritic = " CHEQUE SALARIO EM USO.".
                      
                 RETURN.
             END.
                           
    END.  /*  Fim do FOR EACH -- Leitura do crapfdc  */                       

    FIND FIRST crapcst WHERE crapcst.cdcooper = glb_cdcooper  AND
                             crapcst.nrdconta = par_nrdconta  AND
                             crapcst.dtlibera > par_dtmvtolt  AND
                             crapcst.dtdevolu = ?             NO-LOCK NO-ERROR.
                             
    IF   AVAILABLE crapcst   THEN
         DO:
             par_dscritic = " CHEQUES EM CUSTODIA NAO RESGATADOS.".
             RETURN.
         END.

    FIND FIRST crapcdb WHERE crapcdb.cdcooper = glb_cdcooper  AND
                             crapcdb.nrdconta = par_nrdconta  AND
                             crapcdb.dtlibera > par_dtmvtolt  AND
                             crapcdb.dtdevolu = ?             NO-LOCK NO-ERROR.
                             
    IF   AVAILABLE crapcdb   THEN
         DO:
             par_dscritic = " CHEQUES DESCONTADOS NAO RESGATADOS.".
             RETURN.
         END.
         
    FIND FIRST craptdb WHERE craptdb.cdcooper = glb_cdcooper AND
                             craptdb.nrdconta = par_nrdconta AND
                             craptdb.insittit = 4            AND
                             craptdb.dtvencto > par_dtmvtolt NO-LOCK NO-ERROR.
                             
    IF   AVAILABLE craptdb   THEN
         DO:
             par_dscritic = " TITULOS DESCONTADOS NAO RESGATADOS.".
             RETURN.
         END.              

    FIND FIRST craptit WHERE craptit.cdcooper = glb_cdcooper  AND
                             craptit.nrdconta = par_nrdconta  AND
                             craptit.dtdpagto > par_dtmvtolt  AND
                             craptit.dtdevolu = ?             NO-LOCK NO-ERROR.

    IF   AVAILABLE craptit   THEN
         DO:
             par_dscritic = " TITULOS PROGRAMADOS NAO RESGATADOS.".
             RETURN.
         END.

    par_cdcritic = 0.

END PROCEDURE.

/*............................................................................*/



