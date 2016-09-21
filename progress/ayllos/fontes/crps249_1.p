/******************************************************************************
                 ATENCAO!    CONVERSAO PROGRESS - ORACLE
            ESTE FONTE ESTA ENVOLVIDO NA MIGRACAO PROGRESS->ORACLE!
  +---------------------------------+-----------------------------------+
  | Rotina Progress                 | Rotina Oracle PLSQL               |
  +---------------------------------+-----------------------------------+
  | fontes/crps249_1.p              | pc_crps249_1                      |
  +---------------------------------+-----------------------------------+

  TODA E QUALQUER ALTERACAO EFETUADA NESSE FONTE A PARTIR DE 20/NOV/2012 DEVERA
  SER REPASSADA PARA ESTA MESMA ROTINA NO ORACLE, CONFORME DADOS ACIMA.

  PARA DETALHES DE COMO PROCEDER, FAVOR ENTRAR EM CONTATO COM AS SEGUINTES
  PESSOAS:
   - GUILHERME STRUBE    (CECRED)
   - MARCOS MARTINI      (SUPERO)

*******************************************************************************/




/* ..........................................................................

   Programa: Fontes/crps249_1.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Odair
   Data    : Novembro/98                         Ultima atualizacao: 19/02/2014

   Dados referentes ao programa:

   Frequencia: Diario. Exclusivo.
   Objetivo  : Atende a solicitacao 76.
               Gerar arquivo para contabilidade.
               Ordem do programa na solicitacao 1.

   Alteracoes: 13/06/2000 - Tratar a quantidade dos lancamentos (Odair)
   
               25/04/2001 - Tratar pac ate 99 (Edson).
    
               03/09/2001 - Nao contabilizar contratos de emprestimos
                            em PREJUIZO C/C (Edson).
                            
               14/10/2003 - Inibicao da parte que trata o historico 270 (Julio)
               
               30/06/2005 - Alimentado campo cdcooper da tabela craprej (Diego).

               15/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando. 
                    
               22/03/2006 - Contabilizar qdo linha de credito nao creditar
                            em conta corrente - historico 699(Mirtes)
                            
               22/03/2006 - Contabilizar os historicos do Bancoob (Ze).
               
               04/12/2007 - Acerto para hist. do RDC para Conta Gerencial (Ze).
               
               09/06/2008 - Retirado historico 532(Mirtes)
               
               18/02/2011 - Tratamento para o historico 896 (Ze).
               
               01/09/2011 - Tratamento do histórico 98 e 277
                            Juros e Estorno sobre EMPREST X FINANC (Irlan)
                            
               07/10/2011 - Tratamento no historico 99 - Trf. 42879 (Ze).
               
               26/10/2011 - Retirar crawepr.qtdialib para o hist. 99 - 
                            Trf. 43206 (Ze).
                            
               22/10/2013 - Ajuste de PA de 2 para 3 digitos.
                           (Andre Santos - SUPERO)
                           
               16/01/2014 - Inclusao de VALIDATE craprej (Carlos)
               
               19/02/2014 - Ajustado contadores para nao incluirem PA 999.
                            (Reinert)                            
                                         
............................................................................. */

{ includes/var_batch.i }

glb_cdprogra = "crps249".  /* igual ao origem */

DEF   VAR aux_vlccuage   AS DECI   EXTENT 999               NO-UNDO.
DEF   VAR aux_vlcxaage   AS DECI   EXTENT 999               NO-UNDO.
DEF   VAR aux_qtccuage   AS INT    EXTENT 999               NO-UNDO.
DEF   VAR aux_qtcxaage   AS INT    EXTENT 999               NO-UNDO.
DEF   VAR aux_contador   AS INT                             NO-UNDO.    
DEF   VAR aux_vltarifa   AS DECI                            NO-UNDO.
DEF   VAR aux_nrmaxpas   AS INTE                            NO-UNDO.

DEF   VAR aux_vlccuage_no   AS DECI   EXTENT 999            NO-UNDO.
DEF   VAR aux_vlcxaage_no   AS DECI   EXTENT 999            NO-UNDO.
DEF   VAR aux_qtccuage_no   AS INT    EXTENT 999            NO-UNDO.
DEF   VAR aux_qtcxaage_no   AS INT    EXTENT 999            NO-UNDO.

DEF   VAR aux_vlccuage_499  AS DECI   EXTENT 999            NO-UNDO.
DEF   VAR aux_vlcxaage_499  AS DECI   EXTENT 999            NO-UNDO.
DEF   VAR aux_qtccuage_499  AS INT    EXTENT 999            NO-UNDO.
DEF   VAR aux_qtcxaage_499  AS INT    EXTENT 999            NO-UNDO.
DEF   VAR aux_dtrefere      AS CHAR                         NO-UNDO.

DEF   VAR aux_flgcrcta     AS LOGICAL                       NO-UNDO.
DEF   VAR aux_cdhistor     AS INT                           NO-UNDO.
DEF   VAR in01             AS INT                           NO-UNDO.

/* Busca numero maximo de PA's */
FIND LAST crapage WHERE crapage.cdcooper = glb_cdcooper
                        NO-LOCK NO-ERROR.
IF  AVAIL crapage THEN
    ASSIGN aux_nrmaxpas = crapage.cdagenci.


aux_vltarifa = DECI("{5}").

ASSIGN aux_dtrefere = "{1}".

FOR EACH {1} WHERE {1}.cdcooper = glb_cdcooper AND
                   {1}.dtmvtolt = glb_dtmvtolt AND 
                   {1}.cdhistor = {2},
  /* EACH crapass of {1} NO-LOCK:*/
    EACH crapass WHERE crapass.cdcooper = glb_cdcooper AND
                       crapass.nrdconta = {1}.nrdconta
                       NO-LOCK:
    
 /* IF   {1}.cdhistor = 270   THEN                 /*  Ignora DESCTO CHEQUES  */
         IF   {1}.cdagenci = 1      AND
              {1}.cdbccxlt = 100    AND
              {1}.nrdolote = 8477   THEN
              NEXT.
 */
    ASSIGN aux_flgcrcta = YES.
    
    IF   "{1}" = "craplem"   AND 
         "{2}" = "99"        THEN
         DO:
             FIND crapepr WHERE crapepr.cdcooper  = glb_cdcooper   AND
                                crapepr.nrdconta  = {1}.nrdconta   AND
                           DECI(crapepr.nrctremp) = {1}.nrdocmto
                                NO-LOCK NO-ERROR.
                                
             IF   NOT AVAILABLE crapepr   THEN
                  NEXT.

             IF   crapepr.cdlcremp = 100   THEN
                  NEXT.
                  
             FIND craplcr NO-LOCK WHERE
                  craplcr.cdcooper = glb_cdcooper     AND
                  craplcr.cdlcremp = crapepr.cdlcremp NO-ERROR.
                  
             IF  NOT AVAIL craplcr THEN
                 NEXT.
             
             FIND crawepr WHERE crawepr.cdcooper  = glb_cdcooper   AND
                                crawepr.nrdconta  = {1}.nrdconta   AND
                           DECI(crawepr.nrctremp) = {1}.nrdocmto
                                NO-LOCK NO-ERROR.
                                
             IF   NOT AVAILABLE crawepr   THEN
                  NEXT.

             ASSIGN aux_flgcrcta = craplcr.flgcrcta.
         END.
         
     IF  aux_flgcrcta = NO THEN
         DO:
 
            ASSIGN aux_vlccuage_no[999]  = aux_vlccuage_no[999]  + {1}.vllanmto
                  
                   aux_qtccuage_no[999]  = aux_qtccuage_no[999]  + 1
                   
                   aux_vlcxaage_no[{1}.cdagenci] =
                                          aux_vlcxaage_no[{1}.cdagenci] +
                                          {1}.vllanmto
                   aux_qtcxaage_no[{1}.cdagenci] =
                                          aux_qtcxaage_no[{1}.cdagenci] + 1
                   
                   aux_vlccuage_no[crapass.cdagenci] =
                                          aux_vlccuage_no[crapass.cdagenci] +
                                               {1}.vllanmto
                   aux_qtccuage_no[crapass.cdagenci] =
                                      aux_qtccuage_no[crapass.cdagenci] + 1.
         
         END.

     ELSE    
     DO:
         IF  "{1}" = "craplem"   AND 
             ( "{2}" = "98"  OR  "{2}" = "277" ) THEN

             DO:

                 FIND crapepr WHERE crapepr.cdcooper  = glb_cdcooper   AND
                                    crapepr.nrdconta  = {1}.nrdconta   AND
                               DECI(crapepr.nrctremp) = {1}.nrdocmto
                                    NO-LOCK NO-ERROR.

                 IF  NOT AVAILABLE crapepr   THEN
                     NEXT.

                 FIND craplcr NO-LOCK WHERE
                      craplcr.cdcooper = glb_cdcooper     AND
                      craplcr.cdlcremp = crapepr.cdlcremp NO-ERROR.
                      
                 IF  NOT AVAIL craplcr THEN
                     NEXT.
                 
                 IF  craplcr.dsoperac = "FINANCIAMENTO" THEN
                     DO:
                         ASSIGN aux_vlccuage_499[999]  = aux_vlccuage_499[999]  + {1}.vllanmto
                                aux_qtccuage_499[999]  = aux_qtccuage_499[999]  + 1
                                aux_vlcxaage_499[{1}.cdagenci] = aux_vlcxaage_499[{1}.cdagenci] +
                                    {1}.vllanmto
                                aux_qtcxaage_499[{1}.cdagenci] = aux_qtcxaage_499[{1}.cdagenci] + 1
                                aux_vlccuage_499[crapass.cdagenci] =
                                aux_vlccuage_499[crapass.cdagenci] +
                                    {1}.vllanmto
                                aux_qtccuage_499[crapass.cdagenci] =
                                    aux_qtccuage_499[crapass.cdagenci] + 1.
                     END.

                 ELSE  /* Emprestimo */
                     DO:
                         ASSIGN aux_vlccuage[999]  = aux_vlccuage[999]  + {1}.vllanmto
                                aux_qtccuage[999]  = aux_qtccuage[999]  + 1
                                aux_vlcxaage[{1}.cdagenci] = aux_vlcxaage[{1}.cdagenci] +
                                    {1}.vllanmto
                                aux_qtcxaage[{1}.cdagenci] = aux_qtcxaage[{1}.cdagenci] + 1
                                aux_vlccuage[crapass.cdagenci] =
                                aux_vlccuage[crapass.cdagenci] +
                                    {1}.vllanmto
                                aux_qtccuage[crapass.cdagenci] =
                                    aux_qtccuage[crapass.cdagenci] + 1.
                     END.

             END. /* Fim separar juros de empréstimos e juros de financiamento */

             ELSE
                ASSIGN aux_vlccuage[999]  = aux_vlccuage[999]  + {1}.vllanmto
                       aux_qtccuage[999]  = aux_qtccuage[999]  + 1
                       aux_vlcxaage[{1}.cdagenci] = aux_vlcxaage[{1}.cdagenci] +
                                                   {1}.vllanmto
                       aux_qtcxaage[{1}.cdagenci] = aux_qtcxaage[{1}.cdagenci] + 1
                       aux_vlccuage[crapass.cdagenci] =
                                    aux_vlccuage[crapass.cdagenci] +
                                                   {1}.vllanmto
                       aux_qtccuage[crapass.cdagenci] =
                                   aux_qtccuage[crapass.cdagenci] + 1.
     END.                               
END.    

DO  TRANSACTION ON ERROR UNDO, RETURN:
    aux_cdhistor = {2}.
    RUN cria_craprej.

    IF  "{1}" = "craplem" AND  ( "{2}" = "98" OR "{2}" = "277" ) THEN
        /* Juros e estorno sobre emprestimos (Tratar Financiamentos) */
        DO:
            IF  "{2}" = "98" THEN
                ASSIGN aux_dtrefere = "craplem_499".
            ELSE
            IF  "{2}" = "277" THEN
                ASSIGN aux_dtrefere = "craplem_estfin".
            
            in01 = 1.
            DO  WHILE in01 <= 999 /*aux_nrmaxpas*/ :
                ASSIGN aux_vlccuage[in01] = aux_vlccuage_499[in01] 
                       aux_vlcxaage[in01] = aux_vlcxaage_499[in01] 
                       aux_qtccuage[in01] = aux_qtccuage_499[in01] 
                       aux_qtcxaage[in01] = aux_qtcxaage_499[in01].
                in01 = in01 + 1.
            END.
            RUN cria_craprej.
            ASSIGN aux_dtrefere = "{1}".
        END.

    in01 = 1.
    DO  WHILE in01 <= 999 /*aux_nrmaxpas*/ :
        ASSIGN aux_vlccuage[in01] = aux_vlccuage_no[in01]                
               aux_vlcxaage[in01] = aux_vlcxaage_no[in01]                   
               aux_qtccuage[in01] = aux_qtccuage_no[in01]                   
               aux_qtcxaage[in01] = aux_qtcxaage_no[in01].                  
        in01 = in01 + 1.
    END.

    IF   ({2} <> 340  AND  {2} <> 313  AND  {2} <> 345  AND  {2} <> 445  AND
          {2} <> 097  AND  {2} <> 319  AND  {2} <> 339  AND  {2} <> 351  AND
          {2} <> 024  AND  {2} <> 027  AND  {2} <> 342  AND  {2} <> 463  AND
          {2} <> 475  AND  {2} <> 532) THEN
         DO:
             aux_cdhistor = 699.
             RUN cria_craprej.
         END.

END.

/*----------------
IF   aux_vlccuage[999] > 0 THEN
     DO  TRANSACTION ON ERROR UNDO, RETURN:

         IF   {3} = 2 OR {3} = 3 THEN  /* Detalhamento por agencia */
              DO  aux_contador = 1 to aux_nrmaxpas:

                  IF   aux_vlcxaage[aux_contador] > 0 THEN
                       DO:
                           CREATE craprej.
                           ASSIGN craprej.cdpesqbb = glb_cdprogra  
                                  craprej.cdagenci = aux_contador  
                                  craprej.cdhistor = {2}          
                                  craprej.dtmvtolt = glb_dtmvtolt 
                                  craprej.vllanmto = aux_vlcxaage[aux_contador]
                                  craprej.nrseqdig = aux_qtcxaage[aux_contador]
                                  craprej.dtrefere = "{1}"
                                  craprej.cdcooper = glb_cdcooper.
                       END.   
              END.           
          
         /* Detalhamento por centro de custo ou por tarifas  */
         IF   {4} = 1 OR  aux_vltarifa > 0 THEN
                             /* tratamento por agencia e tarifa */
           /* por tarifas para nao criar registro duplicado no tipo caixa) */
              DO  aux_contador = 1 to 998:

                  IF   aux_vlccuage[aux_contador] > 0 THEN
                       DO:
                          
                           CREATE craprej.
                           ASSIGN craprej.cdpesqbb = glb_cdprogra
                                  craprej.cdagenci = aux_contador
                                  craprej.cdhistor = {2}
                                  craprej.dtmvtolt = glb_dtmvtolt
                                  craprej.vllanmto = aux_vlccuage[aux_contador]
                                  craprej.nrseqdig = aux_qtccuage[aux_contador]
                                  craprej.dtrefere = "{1}"
                                  craprej.cdcooper = glb_cdcooper.
                       END.   
              END.           
         
         IF {3} <> 2 AND {3} <> 3 THEN 
            DO:
                CREATE craprej.
                ASSIGN craprej.cdpesqbb = glb_cdprogra
                       craprej.cdagenci = 0
                       craprej.cdhistor = {2}
                       craprej.dtmvtolt = glb_dtmvtolt
                       craprej.vllanmto = aux_vlccuage[999]
                       craprej.nrseqdig = aux_qtccuage[999]
                       craprej.dtrefere = "{1}"
                       craprej.cdcooper = glb_cdcooper.
            END.
                
     END.   /* transaction */
---------------------*/



DO WHILE TRUE TRANSACTION: 
   
   FIND crapres WHERE crapres.cdcooper = glb_cdcooper  AND
                      crapres.cdprogra = glb_cdprogra
                      EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

   IF   NOT AVAILABLE crapres   THEN
        IF   LOCKED crapres   THEN
             DO:
                 PAUSE 1 NO-MESSAGE.
                 NEXT.
             END.
        ELSE
             DO:
                 glb_cdcritic = 151.
                 RUN fontes/critic.p.
                 UNIX SILENT VALUE("echo " +
                                   STRING(TIME,"HH:MM:SS") +
                                   " - " + glb_cdprogra + "' --> '" +
                                    glb_dscritic +
                                   " >> log/proc_batch.log").
                 UNDO, RETURN.
             END.
   ELSE
        DO:
            crapres.nrdconta = {2}.
            LEAVE.
        END.
        
END.  /*  Fim do DO WHILE TRUE  */


PROCEDURE cria_craprej.

IF   aux_vlccuage[999] > 0 THEN
     DO  TRANSACTION ON ERROR UNDO, RETURN:

         IF   {3} = 2 OR {3} = 3 THEN  /* Detalhamento por agencia */
              DO  aux_contador = 1 TO 998:

                  IF   aux_vlcxaage[aux_contador] > 0 THEN
                       DO:
                           
                           CREATE craprej.
                           ASSIGN craprej.cdpesqbb = glb_cdprogra  
                                  craprej.cdagenci = aux_contador  
                                  craprej.cdhistor = aux_cdhistor /*{2}*/          
                                  craprej.dtmvtolt = glb_dtmvtolt 
                                  craprej.vllanmto = aux_vlcxaage[aux_contador]
                                  craprej.nrseqdig = aux_qtcxaage[aux_contador]
                                  craprej.dtrefere = aux_dtrefere
                                  craprej.cdcooper = glb_cdcooper.
                           VALIDATE craprej.
                       END.   
              END.           
          
         
         
         /* Detalhamento por centro de custo ou por tarifas  */
         IF   {4} = 1 OR  aux_vltarifa > 0 THEN
                             /* tratamento por agencia e tarifa */
           /* por tarifas para nao criar registro duplicado no tipo caixa) */
              DO  aux_contador = 1 TO 998:

                  IF   aux_vlccuage[aux_contador] > 0 THEN
                       DO:
                          
                           CREATE craprej.
                           ASSIGN craprej.cdpesqbb = glb_cdprogra
                                  craprej.cdagenci = aux_contador
                                  craprej.cdhistor = aux_cdhistor /*{2}*/
                                  craprej.dtmvtolt = glb_dtmvtolt
                                  craprej.vllanmto = aux_vlccuage[aux_contador]
                                  craprej.nrseqdig = aux_qtccuage[aux_contador]
                                  craprej.dtrefere = aux_dtrefere
                                  craprej.cdcooper = glb_cdcooper.
                           VALIDATE craprej.
                       END.   
              END.           
         
         
         IF {3} <> 2 AND {3} <> 3 THEN 
            DO:
                
                CREATE craprej.
                ASSIGN craprej.cdpesqbb = glb_cdprogra
                       craprej.cdagenci = 0
                       craprej.cdhistor = aux_cdhistor /*{2}*/
                       craprej.dtmvtolt = glb_dtmvtolt
                       craprej.vllanmto = aux_vlccuage[999]
                       craprej.nrseqdig = aux_qtccuage[999]
                       craprej.dtrefere = aux_dtrefere
                       craprej.cdcooper = glb_cdcooper.
                VALIDATE craprej.
                       
                IF  aux_cdhistor = 896 THEN 
                    DO  aux_contador = 1 TO 998:

                        IF   aux_vlcxaage[aux_contador] > 0 THEN
                             DO:
                                 CREATE craprej.
                                 ASSIGN craprej.cdpesqbb = glb_cdprogra  
                                        craprej.cdagenci = aux_contador  
                                        craprej.cdhistor = aux_cdhistor /*{2}*/
                                        craprej.dtmvtolt = glb_dtmvtolt 
                                        craprej.vllanmto = 
                                                    aux_vlcxaage[aux_contador]
                                        craprej.nrseqdig = 
                                                    aux_qtcxaage[aux_contador]
                                        craprej.dtrefere = aux_dtrefere
                                        craprej.cdcooper = glb_cdcooper.
                                 VALIDATE craprej.
                             END.
                    END.       
            END.
                
     END.   /* transaction */
END PROCEDURE.

