/* ..........................................................................

   Programa: Fontes/crps309.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Edson 
   Data    : Maio/2001.                         Ultima atualizacao: 24/11/2017

   Dados referentes ao programa:

   Frequencia: Diario (Batch).
   Objetivo  : Atende a solicitacao 005.
               Criar base da comp. eletronica dos cheques em custodia.

   Alteracoes: 07/06/2001 - Alterado para tratar tabela de custodia
                            (CRED-CUSTOD-00-nnnnnnnnnn-000) - Edson.
                            
               11/07/2001 - Alterado para adaptar o nome de campo (Edson).
               
               14/08/2001 - Alterar mensagem da transmissao no log do processo
                            (Junior).
                            
               21/01/2002 - Incluir a data no nome do arquivo de cheques para
                            o banco Safra (Junior).

               25/04/2002 - Criar crapchd para os cheques CREDIHERING (Edson).

               13/05/2002 - Mover o arquivo para o salvar ao inves de copia-lo
                            (Deborah).

               25/09/2002 - Alterado para enviar arquivos de custodia da Cooper
                            automaticamente (Junior).
                            
               22/11/2002 - Colocar "&" no final do comando "MT  SEND" (Junior).

               30/06/2005 - Alimentado campo cdcooper da tabela crapchd (Diego).

               21/09/2005 - Modificado FIND FIRST para FIND na tabela 
                            crapcop.cdcooper = glb_cdcooper (Diego).
                            
               16/02/2006 - Unificacao dos bancos - SQLWorks - Eder      
                      
               30/08/2006 - Alterado envio de email pela BO b1wgen0011 (David).
               
               12/04/2007 - Retirar rotina de email em comentario (David).
               
               18/03/2008 - Retirado comentario da rotina de envio de email
                            (Sidnei - Precise)
                            
               20/01/2014 - Incluir VALIDATE crapchd (Lucas R.)
               
               22/05/2014 - Atualiza a situacao previa da tabela crapchd
                            com a mesma da crapcst.insitprv 
                            (Tiago/Rodrigo SD158725).
                            
               04/11/2016 - Cheques custodiados deverao ter o numero do bordero
                            igual a zero. (Projeto 300 - Rafael)
                            
               24/11/2017 - Retirado (nrborder = 0) e feita validacao para verificar
                            se o cheque esta em bordero de desconto efetivado
                            antes de prosseguir com a custodia(Tiago/Adriano #766582)                            
............................................................................. */

DEF STREAM str_1.

{ includes/var_batch.i }

DEF VAR b1wgen0011   AS HANDLE                                       NO-UNDO.

DEF VAR tab_vlchqmai AS DECIMAL                                      NO-UNDO.
DEF VAR tab_nrctadep AS DECIMAL                                      NO-UNDO.

DEF VAR tab_intracst AS INTEGER                                      NO-UNDO.
DEF VAR tab_inchqcop AS INTEGER                                      NO-UNDO.
DEF VAR tab_incrdcta AS INTEGER                                      NO-UNDO.
DEF VAR tab_cdbanapr AS INTEGER                                      NO-UNDO.
DEF VAR tab_cdageapr AS INTEGER                                      NO-UNDO.
DEF VAR tab_cdagedep AS INTEGER                                      NO-UNDO.

DEF VAR tab_dvbanapr AS CHAR                                         NO-UNDO.
DEF VAR tab_nmarquiv AS CHAR                                         NO-UNDO.
DEF VAR tab_dsendele AS CHAR                                         NO-UNDO.

DEF VAR mov_dtmvtopr AS DATE                                         NO-UNDO.
  
DEF VAR aux_tpdmovto AS INTEGER                                      NO-UNDO.

DEF VAR aux_lsdigctr AS CHAR                                         NO-UNDO.
DEF VAR aux_nmarquiv AS CHAR                                         NO-UNDO.

DEF VAR aux_dtmvtolt AS CHAR                                         NO-UNDO.
DEF VAR aux_dtmvtopr AS CHAR                                         NO-UNDO.
DEF VAR aux_dtmvtoax AS CHAR                                         NO-UNDO.
DEF VAR aux_totqtchq AS INT                                          NO-UNDO.
DEF VAR aux_totvlchq AS DECIMAL                                      NO-UNDO.
DEF VAR aux_nrseqarq AS INT                                          NO-UNDO.

glb_cdprogra = "crps309".

RUN fontes/iniprg.p.

IF   glb_cdcritic > 0 THEN
     RETURN.

/* Busca dados da cooperativa */

FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.

IF   NOT AVAILABLE crapcop THEN
     DO:
         glb_cdcritic = 651.
         RUN fontes/critic.p.
         UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                           " - " + glb_cdprogra + "' --> '"  +
                           glb_dscritic + " >> log/proc_batch.log").
         RETURN.
     END.

/*  Tabela com valores dos maiores cheques  */

FIND craptab WHERE craptab.cdcooper = glb_cdcooper  AND
                   craptab.nmsistem = "CRED"        AND
                   craptab.tptabela = "USUARI"      AND
                   craptab.cdempres = 11            AND
                   craptab.cdacesso = "MAIORESCHQ"  AND
                   craptab.tpregist = 001           NO-LOCK NO-ERROR.

IF   NOT AVAILABLE craptab THEN
     DO:
         glb_cdcritic = 55.
         RUN fontes/critic.p.
         UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                           " - " + glb_cdprogra + "' --> '" + glb_dscritic +
                           " CRED-USUARI-11-MAIORESCHQ-001" + 
                           " >> log/proc_batch.log").
         glb_cdcritic = 0.
         RETURN.
     END.

tab_vlchqmai = DECIMAL(SUBSTR(craptab.dstextab,1,15)).

IF   glb_inrestar = 0 THEN
     glb_nrctares = 0.

FOR EACH crapcst WHERE crapcst.cdcooper  = glb_cdcooper     AND
                       crapcst.dtlibera  > glb_dtmvtolt     AND
                       crapcst.dtlibera <= glb_dtmvtopr     AND
                       crapcst.insitchq  = 2                AND
                       crapcst.dtdevolu  = ?                AND
                       RECID(crapcst)    > glb_nrctares
                       USE-INDEX crapcst3 TRANSACTION
                       BY RECID(crapcst):

    IF crapcst.nrborder <> 0 THEN
       DO:
          /*Se estiver em um bordero de descto efetivado nao 
            considerar para a custodia*/
          FIND crapcdb
            WHERE crapcdb.cdcooper = crapcst.cdcooper
              AND crapcdb.nrdconta = crapcst.nrdconta
              AND crapcdb.dtlibera = crapcst.dtlibera
              AND crapcdb.dtlibbdc <> ?
              AND crapcdb.cdcmpchq = crapcst.cdcmpchq
              AND crapcdb.cdbanchq = crapcst.cdbanchq
              AND crapcdb.cdagechq = crapcst.cdagechq
              AND crapcdb.nrctachq = crapcst.nrctachq
              AND crapcdb.nrcheque = crapcst.nrcheque
              AND crapcdb.dtdevolu = ?  
              AND crapcdb.nrborder = crapcst.nrborder NO-LOCK NO-ERROR.
              
          IF AVAILABLE(crapcdb) THEN
             NEXT.
       END.    

    IF   tab_vlchqmai <= crapcst.vlcheque THEN
         aux_tpdmovto = 1.
    ELSE        
         aux_tpdmovto = 2. 
         
    RUN fontes/dig_cmc7.p (INPUT  crapcst.dsdocmc7,
                           OUTPUT glb_nrcalcul,
                           OUTPUT aux_lsdigctr).
 
    FIND craptab WHERE craptab.cdcooper = glb_cdcooper              AND
                       craptab.nmsistem = "CRED"                    AND
                       craptab.tptabela = "CUSTOD"                  AND
                       craptab.cdempres = 00                        AND
                       craptab.cdacesso = STRING(crapcst.nrdconta,
                                                 "9999999999")      AND
                       craptab.tpregist = 0
                       NO-LOCK NO-ERROR.

    IF   NOT AVAILABLE craptab   THEN
         ASSIGN tab_incrdcta = 1
                tab_intracst = 1            /*  Tratamento comp. CREDIHERING  */
                tab_inchqcop = 1.
    ELSE
         ASSIGN tab_incrdcta = INT(SUBSTR(craptab.dstextab,05,01))
                tab_intracst = INT(SUBSTR(craptab.dstextab,07,01))
                tab_inchqcop = INT(SUBSTR(craptab.dstextab,09,01)).
     
    /*  ** 25/04/2002  EDSON  */
    
    IF   crapcst.inchqcop = 1   THEN            /*  Cheque CREDIHERING  */
         IF   tab_incrdcta = 2   THEN           /*  Nao Credita em CC  */
              IF   tab_intracst = 2   THEN      /*  Comp. Terceiros  */
                   IF   tab_inchqcop = 1   THEN /*  Nao trata chq CREDIHERING */
                        NEXT.
                   ELSE .
              ELSE
                   NEXT.

    /*   FORA DE USO ** EDSON    25/04/2002 **********************************
    
    IF   tab_intracst = 1   THEN                       /*  Comp. CREDIHERING  */
         DO:
             IF   crapcst.inchqcop = 1   THEN    /*  Ignora CHQ. CREDIHERING  */
                  NEXT.
         END.
    ELSE
    IF   tab_intracst = 2   THEN                    /*  Gera COMP. TERCEIROS  */
         DO:
             IF   tab_inchqcop = 1   AND      /*  Nao TRATA CHQ. CREDIHERING  */
                  crapcst.inchqcop = 1   THEN                                  
                  NEXT.
         END.
    ELSE
         DO:
             glb_cdcritic = 513.
             RUN fontes/critic.p.
             UNIX SILENT VALUE ("echo " + 
                                STRING(TIME,"HH:MM:SS")  + " - " + 
                                glb_cdprogra + "' --> '" + glb_dscritic +
                                "Registro no crapcst - RECID: " +
                                STRING(RECID(crapcst)) +
                                " >> log/proc_batch.log").
             RETURN.
         END.
    
    **** EDSON *****************************************************  */
    
    CREATE crapchd.
    ASSIGN crapchd.cdagechq = crapcst.cdagechq
           crapchd.cdagenci = 1
           crapchd.cdbanchq = crapcst.cdbanchq 
           crapchd.cdbccxlt = crapcst.cdbccxlt           
           crapchd.cdcmpchq = crapcst.cdcmpchq           
           crapchd.cdoperad = crapcst.cdoperad
           crapchd.cdsitatu = 1
           crapchd.dsdocmc7 = crapcst.dsdocmc7           
           crapchd.dtmvtolt = glb_dtmvtopr
           crapchd.inchqcop = crapcst.inchqcop           
           crapchd.cdcooper = glb_cdcooper
           crapchd.insitchq = IF tab_intracst = 2
                                 THEN IF crapcst.inchqcop = 1
                                         THEN IF tab_inchqcop = 1 
                                                 THEN crapcst.insitchq
                                                 ELSE 3
                                         ELSE 3
                                 ELSE crapcst.insitchq           
           crapchd.nrcheque = crapcst.nrcheque
           crapchd.nrctachq = IF crapcst.cdbanchq = 1
                                 THEN DECIMAL(SUBSTRING(crapcst.dsdocmc7,23,10))
                                 ELSE crapcst.nrctachq
           crapchd.nrdconta = crapcst.nrdconta
           crapchd.nrddigc1 = crapcst.nrddigc1
           crapchd.nrddigc2 = crapcst.nrddigc2
           crapchd.nrddigc3 = crapcst.nrddigc3
           crapchd.nrddigv1 = INT(ENTRY(1,aux_lsdigctr))            
           crapchd.nrddigv2 = INT(ENTRY(2,aux_lsdigctr)) 
           crapchd.nrddigv3 = INT(ENTRY(3,aux_lsdigctr))
           crapchd.nrdocmto = crapcst.nrdocmto
           crapchd.nrdolote = 999999
           crapchd.nrseqdig = crapcst.nrseqdig
           crapchd.nrterfin = 0               
           crapchd.cdtipchq = INT(SUBSTRING(crapcst.dsdocmc7,20,1))
           crapchd.tpdmovto = aux_tpdmovto
           crapchd.vlcheque = crapcst.vlcheque
           crapchd.insitprv = crapcst.insitprv.

    VALIDATE crapchd.

    DO WHILE TRUE:
  
       FIND crapres WHERE crapres.cdcooper = glb_cdcooper   AND
                          crapres.cdprogra = glb_cdprogra
                          EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

       IF   NOT  AVAILABLE crapres   THEN
            IF   LOCKED crapres   THEN
                 DO:
                     PAUSE 1 NO-MESSAGE.
                     NEXT.
                 END.
            ELSE
                 DO:
                     glb_cdcritic = 151.
                     RUN fontes/critic.p.
                     UNIX SILENT VALUE ("echo " + 
                                        STRING(TIME,"HH:MM:SS")  +
                                        " - " + glb_cdprogra + "' --> '" +
                                        glb_dscritic +
                                        " >> log/proc_batch.log").
                     RETURN.
                 END.

       LEAVE.

    END.  /*  Fim do DO WHILE TRUE  */
    
    crapres.nrdconta = INT(RECID(crapcst)).
       
END.  /*  Fim do FOR EACH e da transacao  */

/*  Gera arquivo de compensacao para terceiros .............................  */

ASSIGN aux_dtmvtolt = STRING(DAY(glb_dtmvtopr),"99") +
                      STRING(MONTH(glb_dtmvtopr),"99") +
                      STRING(YEAR(glb_dtmvtopr),"9999")
       
       mov_dtmvtopr = glb_dtmvtopr.

DO WHILE TRUE:          /*  Procura pela proxima data de movimento */

   mov_dtmvtopr = mov_dtmvtopr + 1.

   IF   LOOKUP(STRING(WEEKDAY(mov_dtmvtopr)),"1,7") <> 0   THEN
        NEXT.

   IF   CAN-FIND(crapfer WHERE crapfer.cdcooper = glb_cdcooper  AND
                               crapfer.dtferiad = mov_dtmvtopr) THEN
        NEXT.

   LEAVE.

END.  /*  Fim do DO WHILE TRUE  */

aux_dtmvtopr = STRING(DAY(mov_dtmvtopr),"99") +
               STRING(MONTH(mov_dtmvtopr),"99") + 
               STRING(YEAR(mov_dtmvtopr),"9999").

/*  Leitura dos cheques que devem ser gravados nos arquivos  */

FOR EACH crapchd WHERE crapchd.cdcooper = glb_cdcooper  AND
                       crapchd.dtmvtolt = glb_dtmvtopr  AND
                       crapchd.insitchq = 3             NO-LOCK
                       BREAK BY crapchd.nrdconta
                                BY crapchd.tpdmovto
                                   BY crapchd.cdbanchq 
                                      BY crapchd.cdagechq
                                         BY crapchd.nrctachq:
                        
    IF   FIRST-OF(crapchd.tpdmovto)   THEN
         DO:
             IF   FIRST-OF(crapchd.nrdconta)   THEN
                  DO:
                      aux_nrseqarq = 0.                  
                      
                      FIND craptab WHERE craptab.cdcooper = glb_cdcooper    AND
                                         craptab.nmsistem = "CRED"          AND
                                         craptab.tptabela = "CUSTOD"        AND
                                         craptab.cdempres = 00              AND
                                         craptab.cdacesso =
                                                   STRING(crapchd.nrdconta,
                                                          "9999999999")     AND
                                         craptab.tpregist = 0
                                         NO-LOCK NO-ERROR.

                      IF   NOT AVAILABLE craptab   THEN
                           DO:
                               tab_intracst = 1.
                               NEXT.
                           END.
             
                      ASSIGN tab_intracst = INT(SUBSTR(craptab.dstextab,07,01))
                             tab_inchqcop = INT(SUBSTR(craptab.dstextab,09,01))
                             tab_cdbanapr = INT(SUBSTR(craptab.dstextab,11,03))
                             tab_dvbanapr = SUBSTR(craptab.dstextab,15,01)
                             tab_cdageapr = INT(SUBSTR(craptab.dstextab,17,04))
                             tab_cdagedep = INT(SUBSTR(craptab.dstextab,22,04))
                             tab_nrctadep = DEC(SUBSTR(craptab.dstextab,27,12))
                             tab_nmarquiv = LC(SUBSTR(craptab.dstextab,40,20))
                             tab_dsendele = LC(SUBSTR(craptab.dstextab,61,40)).
                  END.

             ASSIGN aux_nrseqarq = aux_nrseqarq + 1
                    aux_dtmvtoax = STRING(DAY(glb_dtmvtolt),"99") +
                                   STRING(MONTH(glb_dtmvtolt),"99") +
                                   STRING(YEAR(glb_dtmvtolt),"9999").
 
             
             IF   crapchd.tpdmovto = 1 THEN
                  aux_nmarquiv = TRIM(tab_nmarquiv) + "_" + aux_dtmvtoax + "_"
                                 + STRING(crapchd.tpdmovto,"9") + ".sup".
             ELSE
                  aux_nmarquiv = TRIM(tab_nmarquiv) + "_" + aux_dtmvtoax + "_"
                                 + STRING(crapchd.tpdmovto,"9") + ".inf".
             
             OUTPUT STREAM str_1 TO VALUE("arq/" + aux_nmarquiv).
                     
             IF   crapchd.tpdmovto = 1   THEN
                  PUT STREAM str_1  "0S"  
                                    aux_dtmvtolt FORMAT "x(08)"  
                                    tab_cdbanapr FORMAT "999" 
                                    tab_dvbanapr FORMAT "x(1)"
                                    aux_nrseqarq FORMAT "999"
                                    FILL(" ",54) FORMAT "x(54)"     /* FILLER */
                                    SKIP.
             ELSE
                  PUT STREAM str_1  "0I"  
                                    aux_dtmvtopr FORMAT "x(08)"
                                    tab_cdbanapr FORMAT "999" 
                                    tab_dvbanapr FORMAT "x(1)"
                                    aux_nrseqarq FORMAT "999"
                                    FILL(" ",54) FORMAT "x(54)"     /* FILLER */
                                    SKIP.
             
             ASSIGN aux_totqtchq = 0
                    aux_totvlchq = 0.

         END.  /*  Fim  do  FIRST-OF()  */

    IF   tab_intracst = 2   THEN
         DO:
             PUT STREAM str_1  "1"
                        tab_cdbanapr             FORMAT "999"  
                        tab_cdageapr             FORMAT "9999"
                        crapchd.cdbanchq         FORMAT "999"
                        crapchd.cdagechq         FORMAT "9999"
                        crapchd.nrctachq         FORMAT "9999999999"
                        crapchd.nrcheque         FORMAT "999999"
                        crapchd.nrddigv2         FORMAT "9"
                        crapchd.cdcmpchq         FORMAT "999"
                        crapchd.cdtipchq         FORMAT "9"
                        crapchd.nrddigv1         FORMAT "9"
                        crapchd.nrddigv3         FORMAT "9"
                       (crapchd.vlcheque * 100)  FORMAT "99999999999999999"
                        tab_cdagedep             FORMAT "9999"
                        tab_nrctadep             FORMAT "999999999999"  SKIP.
                
             ASSIGN aux_totqtchq = aux_totqtchq + 1
                    aux_totvlchq = aux_totvlchq + (crapchd.vlcheque * 100).
         END.
         
    IF   LAST-OF(crapchd.tpdmovto) THEN
         DO:
             PUT STREAM str_1 "2"  
                              aux_totqtchq  FORMAT "99999"
                              aux_totvlchq  FORMAT "99999999999999999"
                              FILL(" ",48)  FORMAT "x(48)" /* FILLER */ SKIP.

             OUTPUT STREAM str_1 CLOSE.

             IF   aux_totqtchq = 0   THEN
                  NEXT.

             RUN sistema/generico/procedures/b1wgen0011.p
                                                     PERSISTENT SET b1wgen0011.
                                   
             RUN converte_arquivo IN b1wgen0011
                                 (INPUT glb_cdcooper,
                                  INPUT "arq/" + aux_nmarquiv,
                                  INPUT aux_nmarquiv).

             RUN enviar_email IN b1wgen0011
                                 (INPUT glb_cdcooper,
                                  INPUT glb_cdprogra,
                                  INPUT tab_dsendele,
                                  INPUT "ARQUIVO DE CUSTODIA DA COOPER",
                                  INPUT aux_nmarquiv,
                                  INPUT false).
                       
             DELETE PROCEDURE b1wgen0011.

             UNIX SILENT VALUE("mv arq/" + aux_nmarquiv + 
                               " salvar 2>/dev/null"). 
         END.  /*  Fim do LAST-OF()  */
                       
END.  /*  Fim do FOR EACH -- Leitura do crapchd  */

RUN fontes/fimprg.p.

/* .......................................................................... */

