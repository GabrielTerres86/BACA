/* .............................................................................

   Programa: Procedures/saldo_ass.p
   Sistema : Cash Dispenser - Cooperativa de Credito
   Sigla   : CASH
   Autor   : Edson
   Data    : Novembro/1999.                     Ultima atualizacao: 13/05/2008

   Dados referentes ao programa:

   Frequencia: Sempre que for chamado
   Objetivo  : Compor o saldo do associado. Utilizado somente para o CASH

   Alteracoes: 13/05/2008 - Ajuste comando FIND(craphis) utilizava FOR p/ acesso
                            (Sidnei - Precise)

............................................................................. */

DEF INPUT  PARAM par_cdcooper AS INT                              NO-UNDO.
DEF INPUT  PARAM par_nrdconta AS INT                              NO-UNDO.
DEF INPUT  PARAM par_inpessoa AS INT                              NO-UNDO.
DEF INPUT  PARAM par_dtmvtolt AS DATE                             NO-UNDO.
DEF INPUT  PARAM par_dtmvtobd AS DATE                             NO-UNDO.
DEF INPUT  PARAM par_vllimcre AS DECIMAL                          NO-UNDO.

DEF OUTPUT PARAM par_vlsddisp AS DECIMAL                          NO-UNDO.
DEF OUTPUT PARAM par_vldebprg AS DECIMAL                          NO-UNDO.
DEF OUTPUT PARAM par_cdcritic AS INT                              NO-UNDO.

DEF VAR rda_txiofrda AS DECIMAL                                  NO-UNDO.

DEF VAR cpm_txrdcpmf AS DECIMAL                                  NO-UNDO.
DEF VAR cpm_txcpmfcc AS DECIMAL                                  NO-UNDO.
DEF VAR epr_txiofepr AS DECIMAL                                  NO-UNDO.
DEF VAR cpf_txiofcct AS DECIMAL                                  NO-UNDO.
DEF VAR cpj_txiofjur AS DECIMAL                                  NO-UNDO.

DEF VAR cpm_dtinipmf AS DATE                                     NO-UNDO.
DEF VAR cpm_dtfimpmf AS DATE                                     NO-UNDO.

DEF VAR epr_dtiniiof AS DATE                                     NO-UNDO.
DEF VAR epr_dtfimiof AS DATE                                     NO-UNDO.

DEF VAR cpf_dtiniiof AS DATE                                     NO-UNDO.
DEF VAR cpf_dtfimiof AS DATE                                     NO-UNDO.

DEF VAR cpj_dtiniiof AS DATE                                     NO-UNDO.
DEF VAR cpj_dtfimiof AS DATE                                     NO-UNDO.

DEF VAR rda_dtiniiof AS DATE                                     NO-UNDO.
DEF VAR rda_dtfimiof AS DATE                                     NO-UNDO.

DEF VAR aux_vlutiliz AS DECIMAL                                  NO-UNDO.
DEF VAR aux_vlantuti AS DECIMAL                                  NO-UNDO.
DEF VAR aux_vliofant AS DECIMAL                                  NO-UNDO.
DEF VAR aux_vliofatu AS DECIMAL                                  NO-UNDO.
DEF VAR aux_vlcobsld AS DECIMAL                                  NO-UNDO.
DEF VAR aux_vlcobiof AS DECIMAL                                  NO-UNDO.

DEF VAR aux_vldebprg AS DECIMAL                                  NO-UNDO.
DEF VAR aux_vlipmfap AS DECIMAL                                  NO-UNDO.
DEF VAR aux_vllautom AS DECIMAL                                  NO-UNDO.

DEF VAR aux_vlsddisp AS DECIMAL                                  NO-UNDO.
DEF VAR aux_vlsdbloq AS DECIMAL                                  NO-UNDO.
DEF VAR aux_vlsdblpr AS DECIMAL                                  NO-UNDO.
DEF VAR aux_vlsdblfp AS DECIMAL                                  NO-UNDO.
DEF VAR aux_vlsdchsl AS DECIMAL                                  NO-UNDO.
DEF VAR aux_vlestorn AS DECIMAL                                  NO-UNDO.

DEF VAR aux_vlestabo AS DECIMAL                                  NO-UNDO.
DEF VAR aux_vlacerto AS DECIMAL                                  NO-UNDO.
DEF VAR aux_vlcpmdis AS DECIMAL                                  NO-UNDO.

DEF VAR aux_indoipmf AS INT                                      NO-UNDO.

DEF VAR aux_flgerros AS LOGICAL                                  NO-UNDO.

/* ........................................................................... */

RUN inicia_var.    /*  Inicializa as variáveis    */

RUN tabelas.       /*  Le tabelas da CPMF e IOF  */

/*  Saldo do associado  */

FIND banco.crapsld WHERE banco.crapsld.cdcooper = par_cdcooper   AND
                         banco.crapsld.nrdconta = par_nrdconta NO-LOCK NO-ERROR.
   
IF   NOT AVAILABLE banco.crapsld   THEN
     RETURN.
    
FIND banco.crapass WHERE banco.crapass.cdcooper = banco.crapsld.cdcooper   AND 
                         banco.crapass.nrdconta = banco.crapsld.nrdconta
                         NO-LOCK NO-ERROR.

IF   NOT AVAILABLE banco.crapass   THEN
     RETURN.

ASSIGN aux_vlsddisp = banco.crapsld.vlsddisp
       aux_vlsdbloq = banco.crapsld.vlsdbloq
       aux_vlsdblpr = banco.crapsld.vlsdblpr
       aux_vlsdblfp = banco.crapsld.vlsdblfp
       aux_vlsdchsl = banco.crapsld.vlsdchsl
       
       aux_vlantuti = banco.crapsld.vlsdblfp + banco.crapsld.vlsdbloq +
                      banco.crapsld.vlsdblpr + banco.crapsld.vlsdchsl +
                      banco.crapsld.vlsddisp 
                      
       aux_vlantuti = IF aux_vlantuti < 0 
                         THEN aux_vlantuti * -1
                         ELSE 0
                         
       aux_vliofant = banco.crapsld.vlsddisp + banco.crapsld.vlsdbloq + 
                      banco.crapsld.vlsdchsl
                      
       aux_vliofant = IF aux_vliofant < 0
                         THEN aux_vliofant * -1
                         ELSE 0.
           
IF   par_dtmvtolt <> par_dtmvtobd   THEN
     DO:
     
         IF  banco.crapsld.dtrefere <> par_dtmvtobd THEN /* Nao rodou crps001 */
             DO:
                RUN Le_movto (par_dtmvtobd).

                IF   par_cdcritic <> 0   THEN
                     RETURN NO-APPLY.
             END.        
     END.

RUN Le_movto (par_dtmvtolt).
    
IF   par_cdcritic <> 0   THEN
     RETURN.

RUN Programados.

IF   aux_flgerros   THEN
     RETURN.
         
IF   aux_vllautom < 0 THEN
     aux_vllautom = TRUNCATE(aux_vllautom * (1 + cpm_txcpmfcc),2).
ELSE
     aux_vllautom = TRUNCATE(aux_vllautom * cpm_txrdcpmf,2).
         
IF   aux_vlsdbloq > 0   THEN
     DO:
         FOR EACH banco.crapdpb WHERE banco.crapdpb.cdcooper = par_cdcooper    AND
                                      banco.crapdpb.nrdconta = par_nrdconta    AND
                                     (banco.crapdpb.dtliblan >= par_dtmvtobd   AND
                                      banco.crapdpb.dtliblan <= par_dtmvtolt)  AND
                                      banco.crapdpb.cdhistor = 2               AND
                                      banco.crapdpb.inlibera = 1
                                      USE-INDEX crapdpb2 NO-LOCK:
         
             IF   aux_vlsdbloq >= banco.crapdpb.vllanmto   THEN
                  ASSIGN aux_vlsddisp = aux_vlsddisp + banco.crapdpb.vllanmto
                         aux_vlsdbloq = aux_vlsdbloq - banco.crapdpb.vllanmto.
         
         END.  /*  Fim do FOR EACH  --  Leitura do crapdpb  */
     END.

ASSIGN aux_vlestabo = TRUNCATE(aux_vlestabo * rda_txiofrda,2)

       aux_vldebprg = (aux_vllautom * -1) + aux_vlestabo     + 
                       crapsld.vlipmfap   + crapsld.vlipmfpg + aux_vlipmfap +
                       aux_vlcobiof

       aux_vlsddisp = aux_vlsddisp - aux_vldebprg
       
       aux_vlutiliz = aux_vlsdblfp + aux_vlsdbloq + aux_vlsdblpr +
                      aux_vlsdchsl + aux_vlsddisp
                      
       aux_vlutiliz = IF aux_vlutiliz < 0 
                         THEN aux_vlutiliz * -1
                         ELSE 0
                         
       aux_vliofatu = aux_vlsddisp + aux_vlsdbloq + aux_vlsdchsl
       
       aux_vliofatu = IF aux_vliofatu < 0
                         THEN aux_vliofatu * -1
                         ELSE 0.

/*  CPMF sobre a cobertura de saldo  */
                         
IF   par_dtmvtolt >= cpm_dtinipmf   AND
     par_dtmvtolt <= cpm_dtfimpmf   THEN
     IF   aux_vlutiliz < aux_vlantuti   THEN
          DO:
              ASSIGN aux_vlcobsld = TRUNCATE((aux_vlantuti - aux_vlutiliz) *
                                              cpm_txcpmfcc,2)
                     aux_vlsddisp = aux_vlsddisp - aux_vlcobsld
                     aux_vldebprg = aux_vldebprg + aux_vlcobsld.
          END.
          
/*  CPMF para acerto de conta  */

ASSIGN aux_vlcpmdis = IF (aux_vlsddisp + par_vllimcre) > 0
                          THEN TRUNCATE((aux_vlsddisp + par_vllimcre) *
                                         cpm_txrdcpmf,2)
                          ELSE 0
       
       aux_vlcpmdis = IF aux_vlcpmdis > 0
                         THEN (aux_vlsddisp + par_vllimcre - aux_vlcpmdis)
                         ELSE 0
                         
       aux_vlsddisp = aux_vlsddisp - aux_vlcpmdis
       aux_vldebprg = aux_vldebprg + aux_vlcpmdis

       par_vlsddisp = aux_vlsddisp
       par_vldebprg = aux_vldebprg
       par_cdcritic = 0.

/* =========================================================================== */

PROCEDURE Le_movto:
    
    DEF INPUT PARAM mov_dtmvtolt AS DATE                  NO-UNDO.

    par_cdcritic = 0.

    /*  Leitura dos lancamentos do dia  */

    FOR EACH banco.craplcm WHERE 
             banco.craplcm.cdcooper = banco.crapsld.cdcooper   AND
             banco.craplcm.nrdconta = banco.crapsld.nrdconta   AND
             banco.craplcm.dtmvtolt = mov_dtmvtolt             AND
             banco.craplcm.cdhistor <> 289                     
             USE-INDEX craplcm2 NO-LOCK:

        IF  banco.craplcm.nrdolote = 4500 OR     /* Despreza Custodia         */
            banco.craplcm.nrdolote = 4501 THEN   /* Despreza Desconto Cheques */
            NEXT.  

        FIND banco.craphis NO-LOCK WHERE 
                   banco.craphis.cdcooper = banco.craplcm.cdcooper AND 
                   banco.craphis.cdhistor = banco.craplcm.cdhistor NO-ERROR.

        IF   NOT AVAILABLE banco.craphis   THEN
             DO:
                 par_cdcritic = -1.
                 RETURN.
             END.

        ASSIGN aux_indoipmf = IF CAN-DO("114,117,127,160",STRING(craplcm.cdhistor))
                                 THEN 1
                                 ELSE craphis.indoipmf.

        IF   banco.craphis.inhistor = 1   THEN
             aux_vlsddisp = aux_vlsddisp + banco.craplcm.vllanmto.
        ELSE
        IF   banco.craphis.inhistor = 2   THEN
             aux_vlsdchsl = aux_vlsdchsl + banco.craplcm.vllanmto.
        ELSE
        IF   banco.craphis.inhistor = 3   THEN
             aux_vlsdbloq = aux_vlsdbloq + banco.craplcm.vllanmto.
        ELSE
        IF   banco.craphis.inhistor = 4   THEN
             aux_vlsdblpr = aux_vlsdblpr + banco.craplcm.vllanmto.
        ELSE
        IF   banco.craphis.inhistor = 5   THEN
             aux_vlsdblfp = aux_vlsdblfp + banco.craplcm.vllanmto.
        ELSE
        IF   banco.craphis.inhistor = 11   THEN
             aux_vlsddisp = aux_vlsddisp - banco.craplcm.vllanmto.
        ELSE
        IF   banco.craphis.inhistor = 12   THEN
             aux_vlsdchsl = aux_vlsdchsl - banco.craplcm.vllanmto.
        ELSE
        IF   banco.craphis.inhistor = 13   THEN
             aux_vlsdbloq = aux_vlsdbloq - banco.craplcm.vllanmto.
        ELSE
        IF   banco.craphis.inhistor = 14   THEN
             aux_vlsdblpr = aux_vlsdblpr - banco.craplcm.vllanmto.
        ELSE
        IF   banco.craphis.inhistor = 15   THEN
             aux_vlsdblfp = aux_vlsdblfp - banco.craplcm.vllanmto.
        ELSE
             NEXT.
             
        /*  Calcula CPMF para os lancamentos  */

        IF   aux_indoipmf > 1   THEN
             IF   craphis.indebcre = "D"   THEN
                  aux_vlipmfap = aux_vlipmfap + (TRUNCATE(craplcm.vllanmto * cpm_txcpmfcc,2)).
             ELSE
             IF   craphis.indebcre = "C"   THEN
                  aux_vlipmfap = aux_vlipmfap - (TRUNCATE(craplcm.vllanmto * cpm_txcpmfcc,2)).
             ELSE .
        ELSE
        IF   craphis.inhistor = 12 THEN
             DO:      /*
                 FIND crapchs WHERE crapchs.nrdconta = craplcm.nrdconta AND
                                    crapchs.nrdocmto = craplcm.nrdocmto
                                    USE-INDEX crapchs2 NO-LOCK NO-ERROR.
        
                 IF   NOT AVAILABLE crapchs   THEN
                      IF   craplcm.nrdctabb = 978809   THEN
                           DO:
                               par_cdcritic = 286.
                               aux_flgerros = TRUE.
                               LEAVE.
                           END.
                      ELSE      
                      IF   craplcm.cdhistor <> 43 THEN
                           ASSIGN aux_vlsdchsl = aux_vlsdchsl - (TRUNCATE(craplcm.vllanmto * cpm_txcpmfcc,2))
                                  aux_vlsddisp = aux_vlsddisp + (TRUNCATE(craplcm.vllanmto * cpm_txcpmfcc,2))
                                  aux_vlipmfap = aux_vlipmfap + (TRUNCATE(craplcm.vllanmto * cpm_txcpmfcc,2)).
                      ELSE .
                 ELSE
                      ASSIGN aux_vlsdchsl = aux_vlsdchsl - crapchs.vldoipmf
                             aux_vlsddisp = aux_vlsddisp + crapchs.vldoipmf
                             aux_vlipmfap = aux_vlipmfap + crapchs.vldoipmf.
                             */
                 IF   craplcm.cdhistor <> 43 THEN
                           ASSIGN aux_vlsdchsl = aux_vlsdchsl - (TRUNCATE(craplcm.vllanmto * cpm_txcpmfcc,2))
                                  aux_vlsddisp = aux_vlsddisp + (TRUNCATE(craplcm.vllanmto * cpm_txcpmfcc,2))
                                  aux_vlipmfap = aux_vlipmfap + (TRUNCATE(craplcm.vllanmto * cpm_txcpmfcc,2)).

             END.

        IF   CAN-DO("186,187",STRING(craplcm.cdhistor))   THEN      /*  RDCA  */
             ASSIGN aux_vlestorn = TRUNCATE(craplcm.vllanmto * cpm_txcpmfcc,2)
                    aux_vlipmfap = aux_vlipmfap + aux_vlestorn + TRUNCATE(aux_vlestorn * cpm_txcpmfcc,2)
                    aux_vlestabo = aux_vlestabo + craplcm.vllanmto
             
                    aux_vlcobiof = aux_vlcobiof +
                                   TRUNCATE(craplcm.vllanmto * rda_txiofrda,2).
             
    END.  /*  Fim do FOR EACH -- Leitura dos lancamentos do dia  */

END PROCEDURE.

/* ........................................................................... */

PROCEDURE tabelas:

    /*  Tabela com o período de vigência e taxa do CPMF ...................... */

    FIND banco.craptab WHERE banco.craptab.cdcooper = par_cdcooper       AND
                             banco.craptab.nmsistem = "CRED"             AND
                             banco.craptab.tptabela = "USUARI"           AND
                             banco.craptab.cdempres = 11                 AND
                             banco.craptab.cdacesso = "CTRCPMFCCR"       AND
                             banco.craptab.tpregist = 1
                             USE-INDEX craptab1 NO-LOCK NO-ERROR.

    IF   NOT AVAILABLE banco.craptab   THEN
         DO:
             par_cdcritic = 641.
             RETURN.
         END.

    ASSIGN cpm_dtinipmf = DATE(INT(SUBSTRING(banco.craptab.dstextab,4,2)),
                               INT(SUBSTRING(banco.craptab.dstextab,1,2)),
                               INT(SUBSTRING(banco.craptab.dstextab,7,4)))
                               
           cpm_dtfimpmf = DATE(INT(SUBSTRING(banco.craptab.dstextab,15,2)),
                               INT(SUBSTRING(banco.craptab.dstextab,12,2)),
                               INT(SUBSTRING(banco.craptab.dstextab,18,4)))
                           
           cpm_txcpmfcc = IF par_dtmvtolt >= cpm_dtinipmf AND
                             par_dtmvtolt <= cpm_dtfimpmf
                             THEN DECIMAL(SUBSTR(banco.craptab.dstextab,23,13))
                             ELSE 0
                         
           cpm_txrdcpmf = IF par_dtmvtolt >= cpm_dtinipmf AND
                             par_dtmvtolt <= cpm_dtfimpmf
                             THEN DECIMAL(SUBSTR(banco.craptab.dstextab,38,13))
                             ELSE 1.


    /*  Tabela com o período de vigência e taxa do IOF para EMPRÉSTIMOS ...... */

    FIND craptab WHERE craptab.cdcooper = par_cdcooper       AND 
                       craptab.nmsistem = "CRED"             AND
                       craptab.tptabela = "USUARI"           AND
                       craptab.cdempres = 11                 AND
                       craptab.cdacesso = "CTRIOFEMPR"       AND
                       craptab.tpregist = 1
                       USE-INDEX craptab1 NO-LOCK NO-ERROR.

    IF   NOT AVAILABLE craptab   THEN
         DO:
             par_cdcritic = 626.
             RETURN.
         END.

    ASSIGN epr_dtiniiof = DATE(INT(SUBSTRING(craptab.dstextab,4,2)),
                               INT(SUBSTRING(craptab.dstextab,1,2)),
                               INT(SUBSTRING(craptab.dstextab,7,4)))
                           
           epr_dtfimiof = DATE(INT(SUBSTRING(craptab.dstextab,15,2)),
                               INT(SUBSTRING(craptab.dstextab,12,2)),
                               INT(SUBSTRING(craptab.dstextab,18,4)))
                           
           epr_txiofepr = IF par_dtmvtolt >= epr_dtiniiof   AND
                             par_dtmvtolt <= epr_dtfimiof 
                             THEN DECIMAL(SUBSTRING(craptab.dstextab,23,16))
                             ELSE 0.

    /*  Tabela com o período de vigência e taxa do IOF para PESSOA FÍSICA .... */

    FIND craptab WHERE craptab.cdcooper = par_cdcooper       AND 
                       craptab.nmsistem = "CRED"             AND
                       craptab.tptabela = "USUARI"           AND
                       craptab.cdempres = 11                 AND
                       craptab.cdacesso = "CTRIOFCCPF"       AND
                       craptab.tpregist = 1
                       USE-INDEX craptab1 NO-LOCK NO-ERROR.

    IF   NOT AVAILABLE craptab   THEN
         DO:
             par_cdcritic = 626.
             RETURN.
         END.

    ASSIGN cpf_dtiniiof = DATE(INT(SUBSTRING(craptab.dstextab,4,2)),
                               INT(SUBSTRING(craptab.dstextab,1,2)),
                               INT(SUBSTRING(craptab.dstextab,7,4)))
                           
           cpf_dtfimiof = DATE(INT(SUBSTRING(craptab.dstextab,15,2)),
                               INT(SUBSTRING(craptab.dstextab,12,2)),
                               INT(SUBSTRING(craptab.dstextab,18,4)))
                           
           cpf_txiofcct = IF par_dtmvtolt >= cpf_dtiniiof   AND
                             par_dtmvtolt <= cpf_dtfimiof   
                             THEN DECIMAL(SUBSTRING(craptab.dstextab,23,16))
                             ELSE 0.


    /*  Tabela com o período de vigência e taxa do IOF para PESSOA JURÍDICA .. */

    FIND craptab WHERE craptab.cdcooper = par_cdcooper       AND
                       craptab.nmsistem = "CRED"             AND
                       craptab.tptabela = "USUARI"           AND
                       craptab.cdempres = 11                 AND
                       craptab.cdacesso = "CTRIOFCCPJ"       AND
                       craptab.tpregist = 1
                       USE-INDEX craptab1 NO-LOCK NO-ERROR.

    IF   NOT AVAILABLE craptab   THEN
         DO:
             par_cdcritic = 626.
             RETURN.
         END.

    ASSIGN cpj_dtiniiof = DATE(INT(SUBSTRING(craptab.dstextab,4,2)),
                               INT(SUBSTRING(craptab.dstextab,1,2)),
                               INT(SUBSTRING(craptab.dstextab,7,4)))
                           
           cpj_dtfimiof = DATE(INT(SUBSTRING(craptab.dstextab,15,2)),
                               INT(SUBSTRING(craptab.dstextab,12,2)),
                               INT(SUBSTRING(craptab.dstextab,18,4)))
                           
           cpj_txiofjur = IF par_dtmvtolt >= cpj_dtiniiof   AND
                             par_dtmvtolt <= cpj_dtfimiof 
                             THEN DECIMAL(SUBSTR(craptab.dstextab,23,16))
                             ELSE 0.

    /*  Tabela com o período de vigência e taxa do IOF para APLICAÇÕES RDCA .. */

    FIND craptab WHERE craptab.cdcooper = par_cdcooper       AND
                       craptab.nmsistem = "CRED"             AND
                       craptab.tptabela = "USUARI"           AND
                       craptab.cdempres = 11                 AND
                       craptab.cdacesso = "CTRIOFRDCA"       AND
                       craptab.tpregist = 1
                       USE-INDEX craptab1 NO-LOCK NO-ERROR.

    IF   NOT AVAILABLE craptab   THEN
         DO:
             par_cdcritic = 626.
             RETURN.
         END.

    ASSIGN rda_dtiniiof = DATE(INT(SUBSTRING(craptab.dstextab,4,2)),
                               INT(SUBSTRING(craptab.dstextab,1,2)),
                               INT(SUBSTRING(craptab.dstextab,7,4)))
                           
           rda_dtfimiof = DATE(INT(SUBSTRING(craptab.dstextab,15,2)),
                               INT(SUBSTRING(craptab.dstextab,12,2)),
                               INT(SUBSTRING(craptab.dstextab,18,4)))
                           
           rda_txiofrda = IF   par_dtmvtolt >= rda_dtiniiof AND
                               par_dtmvtolt <= rda_dtfimiof
                               THEN DECIMAL(SUBSTRING(banco.craptab.dstextab,23,16))
                               ELSE 0.

END PROCEDURE.

/* ........................................................................... */

PROCEDURE Programados:

    /*  Não calcula programados para quem movimenta com talão de cheques  */
    
    IF   CAN-DO('1,2,3,4,8,9,10,11',STRING(banco.crapass.cdtipcta))   AND
         banco.crapass.cdsitdct = 1    THEN
         RETURN.

    /*  Para associados sem talão de cheques e sem o crédito da folha no mes  */

    IF   banco.crapsld.vltsallq = 0   THEN
         DO:
             FIND FIRST banco.craplcm WHERE 
                        banco.craplcm.cdcooper = par_cdcooper   AND
                        banco.craplcm.nrdconta = par_nrdconta   AND
                        banco.craplcm.dtmvtolt = par_dtmvtolt   AND
                       (banco.craplcm.cdhistor = 7   OR
                        banco.craplcm.cdhistor = 8)
                        USE-INDEX craplcm2 NO-LOCK NO-ERROR.
                        
             IF   NOT AVAILABLE banco.craplcm   THEN
                  RETURN.
         END.

    /*  Parcela de seguro  */

    FOR EACH crapseg WHERE crapseg.cdcooper = par_cdcooper       AND
                           crapseg.nrdconta = par_nrdconta       AND
                           crapseg.indebito = 0                  AND
                           crapseg.cdsitseg = 1                  AND
                           MONTH(crapseg.dtdebito) = MONTH(par_dtmvtolt)  AND
                            YEAR(crapseg.dtdebito) =  YEAR(par_dtmvtolt)  NO-LOCK:

        aux_vllautom = aux_vllautom - crapseg.vlpreseg.

    END.  /* FOR EACH SEGURO */

    /*  Parcela de poupança programada  */

    FOR EACH craprpp WHERE craprpp.cdcooper = par_cdcooper       AND
                           craprpp.nrdconta = par_nrdconta       AND
                          (craprpp.cdsitrpp = 1                  OR
                          (craprpp.cdsitrpp = 2                  AND
                           craprpp.dtrnirpp = craprpp.dtdebito)) AND
                           MONTH(craprpp.dtdebito) = MONTH(par_dtmvtolt) AND
                            YEAR(craprpp.dtdebito) =  YEAR(par_dtmvtolt)  NO-LOCK:

        aux_vllautom = aux_vllautom - craprpp.vlprerpp.

    END. /* FOR EACH POUPANCA PROGRAMADA */

    /*  Parcela do plano de capital  */

    FOR EACH crappla WHERE crappla.cdcooper  = par_cdcooper AND
                           crappla.nrdconta  = par_nrdconta AND
                           crappla.tpdplano  = 1            AND
                           crappla.cdsitpla  = 1            AND
                           crappla.flgpagto  = FALSE        AND
                           crappla.indpagto  = 0            AND
                           MONTH(crappla.dtdpagto) = MONTH(par_dtmvtolt) AND
                            YEAR(crappla.dtdpagto) =  YEAR(par_dtmvtolt)  NO-LOCK:

        aux_vllautom = aux_vllautom - crappla.vlprepla.
    
    END.

    IF   aux_flgerros   THEN
         RETURN.

END PROCEDURE.

/* ........................................................................... */

PROCEDURE inicia_var:

    ASSIGN par_cdcritic = 1
    
           aux_vldebprg = 0
           aux_vlipmfap = 0
           aux_vllautom = 0
           aux_vlsddisp = 0
           aux_vlsdbloq = 0
           aux_vlsdblpr = 0
           aux_vlsdblfp = 0
           aux_vlsdchsl = 0
           aux_vlestorn = 0

           aux_vlestabo = 0
           aux_vlacerto = 0
           aux_vlcpmdis = 0

           aux_indoipmf = 0
           aux_vlutiliz = 0
           aux_vlantuti = 0
           aux_vliofant = 0
           aux_vliofatu = 0
           aux_vlcobsld = 0
           aux_vlcobiof = 0.
           
END PROCEDURE.
