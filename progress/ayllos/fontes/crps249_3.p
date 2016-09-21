/******************************************************************************
                 ATENCAO!    CONVERSAO PROGRESS - ORACLE
            ESTE FONTE ESTA ENVOLVIDO NA MIGRACAO PROGRESS->ORACLE!
  +---------------------------------+-----------------------------------+
  | Rotina Progress                 | Rotina Oracle PLSQL               |
  +---------------------------------+-----------------------------------+
  | fontes/crps249_3.p              | pc_crps249_3                      |
  +---------------------------------+-----------------------------------+

  TODA E QUALQUER ALTERACAO EFETUADA NESSE FONTE A PARTIR DE 20/NOV/2012 DEVERA
  SER REPASSADA PARA ESTA MESMA ROTINA NO ORACLE, CONFORME DADOS ACIMA.

  PARA DETALHES DE COMO PROCEDER, FAVOR ENTRAR EM CONTATO COM AS SEGUINTES
  PESSOAS:
   - GUILHERME STRUBE    (CECRED)
   - MARCOS MARTINI      (SUPERO)

*******************************************************************************/




/* ..........................................................................

   Programa: Fontes/crps249_3.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Odair
   Data    : Novembro/98                     Ultima atualizacao: 19/02/2014

   Dados referentes ao programa:

   Frequencia: Diario. Exclusivo.
   Objetivo  : Atende a solicitacao 76.
               Gerar arquivo para contabilidade.
               Ordem do programa na solicitacao 1.

   Alteracoes: 13/06/2000 - Tratar lancamentos por PAC (Odair)

               22/08/2000 - Tratar cheque salario Bancoob (Deborah). 

               25/04/2001 - Tratar pac ate 99 (Edson).
               
               21/06/2005 - Mudar para conta 1179 (CTITG) - Ze Eduardo
                            Somente Credifiesc, Cecrisacred e Credcrea. 

               07/07/2005 - Alimentado campo cdcooper tabela craprej (Diego).
               
               10/12/2005 - Atualizar craprej.nrdctitg (Magui).
               
               25/01/2006 - Efetuar unico lancamento para CTA ITG (Ze).

               15/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando. 
               
               15/12/2008 - Substituir a tab "ContaConve" pela gnctace (Ze).
               
               18/05/2011 - Ajuste para contabilizar a quantidade de boletos
                            atraves do dsidendi na craplcm (Gabriel)
                            
               22/10/2013 - Ajuste de PA de 2 para 3 digitos.
                            (Andre Santos - SUPERO)
                            
               16/01/2014 - Inclusao de VALIDATE craprej (Carlos)
               
               19/02/2014 - Ajustado contadores para nao incluirem PA 999.
                            (Reinert)                            
                                                        
............................................................................. */

{ includes/var_batch.i } 

glb_cdprogra = "crps249".  /* igual ao origem */

DEF   VAR aux_vldctabb  AS DECI                            NO-UNDO.
DEF   VAR aux_qtdctabb  AS INT                             NO-UNDO.
DEF   VAR aux_vlccuage  AS DECI   EXTENT 999               NO-UNDO.
DEF   VAR aux_qtccuage  AS INT    EXTENT 999               NO-UNDO.

DEF   VAR aux_contador  AS INT                             NO-UNDO.

DEF   VAR rel_nrdctabb  AS INT                             NO-UNDO.
DEF   VAR aux_lscontas  AS CHAR                            NO-UNDO.
DEF   VAR aux_lsconta4  AS CHAR                            NO-UNDO.
DEF   VAR aux_nrdconta  AS INT                             NO-UNDO.
DEF   VAR aux_nrmaxpas  AS INTE                            NO-UNDO.

DEF TEMP-TABLE crawtot FIELD cdbccxlt AS INT
                       FIELD nrdctabb AS INT
                       FIELD vldctabb AS DECIMAL
                       FIELD qtdctabb AS INT
                       FIELD vlccuage AS DECIMAL  EXTENT 999
                       FIELD qtccuage AS INT      EXTENT 999
                       INDEX crawtot1 AS PRIMARY cdbccxlt nrdctabb.



  /********   FUNCAO PARA VERIFICAR A ULTIMA CONTACONVE CADASTRADA   *******/

  FUNCTION f_ultctaconve RETURNS CHAR(INPUT par_dstextab AS CHAR).

     IF   (R-INDEX(par_dstextab, ",") = LENGTH(TRIM(par_dstextab)))   THEN
          DO:
               par_dstextab = SUBSTR(par_dstextab, 1, 
                                     LENGTH(TRIM(par_dstextab)) - 1).
               par_dstextab = SUBSTR(par_dstextab, 
                                   R-INDEX(par_dstextab, ",") + 1, 10).
          END.
     ELSE
     IF  (R-INDEX(par_dstextab, ",") > 0)   THEN
         par_dstextab = SUBSTR(par_dstextab, R-INDEX(par_dstextab,",") + 1,10). 
 
     RETURN par_dstextab.

  END FUNCTION.


/* Busca numero maximo de PA's */
FIND LAST crapage WHERE crapage.cdcooper = glb_cdcooper
                        NO-LOCK NO-ERROR.
IF  AVAIL crapage THEN
    ASSIGN aux_nrmaxpas = crapage.cdagenci.


/*  Le tabela com as contas convenio do Banco do Brasil   */
RUN fontes/ver_ctace.p(INPUT glb_cdcooper,
                       INPUT 0,
                       OUTPUT aux_lscontas).

IF   aux_lscontas = "" THEN
     DO:
         glb_cdcritic = 393.
         RUN fontes/critic.p.
         UNIX SILENT VALUE ("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                             glb_cdprogra + "' --> '" + glb_dscritic +
                             " >> log/proc_batch.log").
         RETURN.
     END.

RUN fontes/ver_ctace.p(INPUT glb_cdcooper,
                       INPUT 4,
                       OUTPUT aux_lsconta4).

IF   aux_lsconta4 = "" THEN
     DO:
         glb_cdcritic = 393.
         RUN fontes/critic.p.
         UNIX SILENT VALUE ("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                             glb_cdprogra + "' --> '" + glb_dscritic +
                             " >> log/proc_batch.log").
         RETURN.
     END.
ELSE
     ASSIGN rel_nrdctabb = INT(f_ultctaconve(aux_lsconta4)).

FOR EACH {1} WHERE  {1}.cdcooper = glb_cdcooper AND
                    {1}.dtmvtolt = glb_dtmvtolt AND 
                    {1}.cdhistor = {2},

    EACH crapass WHERE crapass.cdcooper = glb_cdcooper AND
                       crapass.nrdconta = {1}.nrdconta NO-LOCK 
                       BREAK BY {1}.cdbccxlt 
                                BY {1}.nrdctabb:
         
    IF   "{2}" <> "266"   THEN
         ASSIGN aux_qtdctabb = aux_qtdctabb + 1

                aux_qtccuage[999] =
                        aux_qtccuage[999] + 1

                aux_qtccuage[crapass.cdagenci] = 
                        aux_qtccuage[crapass.cdagenci] + 1.
                
    ASSIGN aux_vldctabb = aux_vldctabb + {1}.vllanmto
           
           aux_vlccuage[crapass.cdagenci] = aux_vlccuage[crapass.cdagenci] +
                                            {1}.vllanmto
                                 
           aux_vlccuage[999] = aux_vlccuage[999] + {1}.vllanmto.

    IF   LAST-OF({1}.cdbccxlt) OR
         LAST-OF({1}.nrdctabb) THEN
         DO:
             IF   NOT CAN-DO(aux_lscontas,STRING({1}.nrdctabb))   AND
                  glb_cdcooper <> 3                               THEN
                  aux_nrdconta = rel_nrdctabb.
             ELSE 
                  aux_nrdconta = {1}.nrdctabb.
                                        
             FIND crawtot WHERE crawtot.cdbccxlt = {1}.cdbccxlt AND
                                crawtot.nrdctabb = aux_nrdconta NO-ERROR.

             IF   NOT AVAILABLE crawtot THEN
                  DO:
                      CREATE crawtot.
                      ASSIGN crawtot.cdbccxlt = {1}.cdbccxlt
                             crawtot.nrdctabb = aux_nrdconta.
                  END. 
                      
             ASSIGN crawtot.vldctabb = crawtot.vldctabb + aux_vldctabb
                    crawtot.qtdctabb = crawtot.qtdctabb + aux_qtdctabb.
                      
             DO aux_contador = 1 TO 999 /*aux_nrmaxpas*/ :
                IF   aux_vlccuage[aux_contador] > 0 THEN
                     DO:
                         ASSIGN crawtot.vlccuage[aux_contador] = 
                                        crawtot.vlccuage[aux_contador] +
                                        aux_vlccuage[aux_contador]
                                crawtot.qtccuage[aux_contador] = 
                                        crawtot.qtccuage[aux_contador] +
                                        aux_qtccuage[aux_contador].
                     END.
             END.
           
             ASSIGN aux_vldctabb = 0
                    aux_qtdctabb = 0 
                    aux_vlccuage = 0
                    aux_qtccuage = 0.     
         END.
END.


IF   "{2}" = "266"   THEN
     DO:
         FOR EACH craplcm WHERE  craplcm.cdcooper = glb_cdcooper   AND
                                 craplcm.dtmvtolt = glb_dtmvtolt   AND
                                 craplcm.cdhistor = 266            NO-LOCK,
             
             FIRST crapass WHERE crapass.cdcooper = glb_cdcooper   AND
                                 crapass.nrdconta = craplcm.nrdconta NO-LOCK
                                 BREAK BY craplcm.cdbccxlt 
                                          BY craplcm.nrdctabb:

             IF   TRIM(craplcm.dsidenti) = ""   THEN
                  ASSIGN aux_qtdctabb = aux_qtdctabb + 1

                         aux_qtccuage[999] = aux_qtccuage[999] + 1
                         
                         aux_qtccuage[crapass.cdagenci] = 
                                      aux_qtccuage[crapass.cdagenci] + 1.
             ELSE
                  ASSIGN aux_qtdctabb = aux_qtdctabb + INTE(craplcm.dsidenti)
                
                         aux_qtccuage[999] = aux_qtccuage[999] + 
                                            INTE(craplcm.dsidenti)
                
                         aux_qtccuage[crapass.cdagenci] = 
                                      aux_qtccuage[crapass.cdagenci] + 
                                      INTE(craplcm.dsidenti).
                 
             ASSIGN aux_vlccuage[crapass.cdagenci] = 
                                 aux_vlccuage[crapass.cdagenci] +
                                 craplcm.vllanmto

                    aux_vlccuage[999] = aux_vlccuage[999] + craplcm.vllanmto.

             IF   LAST-OF(craplcm.cdbccxlt) OR
                  LAST-OF(craplcm.nrdctabb) THEN
                  DO:
                      IF   NOT CAN-DO(aux_lscontas,STRING(craplcm.nrdctabb)) AND
                           glb_cdcooper <> 3                                 THEN
                           aux_nrdconta = rel_nrdctabb.
                      ELSE 
                           aux_nrdconta = craplcm.nrdctabb.

                      FIND crawtot WHERE crawtot.cdbccxlt = craplcm.cdbccxlt AND
                                         crawtot.nrdctabb = aux_nrdconta 
                                         NO-ERROR.

                      IF   NOT AVAILABLE crawtot THEN
                           DO:
                               CREATE crawtot.
                               ASSIGN crawtot.cdbccxlt = craplcm.cdbccxlt
                                      crawtot.nrdctabb = aux_nrdconta.
                           END. 

                      ASSIGN crawtot.qtdctabb = crawtot.qtdctabb + aux_qtdctabb.

                      DO aux_contador = 1 TO 999 /*aux_nrmaxpas*/ :

                         IF   aux_vlccuage[aux_contador] > 0 THEN
                              DO:
                                  ASSIGN crawtot.qtccuage[aux_contador] = 
                                            crawtot.qtccuage[aux_contador] +
                                            aux_qtccuage[aux_contador].
                              END.
                      END.
           
                      ASSIGN aux_qtdctabb = 0 
                             aux_qtccuage = 0
                             aux_vlccuage = 0.    
                               
                  END.
         END.   
     
     END.
   
FOR EACH crawtot BREAK BY crawtot.cdbccxlt BY crawtot.nrdctabb:
    
    DO  TRANSACTION ON ERROR UNDO, RETURN:

        CREATE craprej.
        ASSIGN craprej.cdpesqbb = glb_cdprogra  
               craprej.cdagenci = 99  
               craprej.cdhistor = {2}          
               craprej.dtmvtolt = glb_dtmvtolt 
               craprej.vllanmto = crawtot.vldctabb
               craprej.nrseqdig = crawtot.qtdctabb
               craprej.dtrefere = "compbb"
               craprej.nrdctabb = crawtot.nrdctabb
               craprej.cdbccxlt = crawtot.cdbccxlt
               craprej.cdcooper = glb_cdcooper.
        VALIDATE craprej.

        /* Formata conta integracao */
        RUN fontes/digbbx.p (INPUT  crawtot.nrdctabb,
                             OUTPUT glb_dsdctitg,
                             OUTPUT glb_stsnrcal).
        
        ASSIGN craprej.nrdctitg = glb_dsdctitg.

        DO  aux_contador = 1 TO 998:

            IF   crawtot.vlccuage[aux_contador] > 0 THEN
                 DO:
                     CREATE craprej.
                     ASSIGN craprej.cdpesqbb = glb_cdprogra
                            craprej.cdagenci = aux_contador
                            craprej.cdhistor = {2}
                            craprej.dtmvtolt = glb_dtmvtolt
                            craprej.vllanmto = crawtot.vlccuage[aux_contador]
                            craprej.nrseqdig = crawtot.qtccuage[aux_contador]
                            craprej.nrdctabb = crawtot.nrdctabb
                            craprej.dtrefere = "tarifa"
                            craprej.cdbccxlt = crawtot.cdbccxlt
                            craprej.cdcooper = glb_cdcooper.
                     VALIDATE craprej.
                 END.   
        END.            
         
        CREATE craprej.
        ASSIGN craprej.cdpesqbb = glb_cdprogra
               craprej.cdagenci = 0
               craprej.cdhistor = {2}
               craprej.dtmvtolt = glb_dtmvtolt
               craprej.vllanmto = crawtot.vlccuage[999]
               craprej.nrseqdig = crawtot.qtccuage[999]
               craprej.nrdctabb = crawtot.nrdctabb
               craprej.dtrefere = "tarifa"
               craprej.cdbccxlt = crawtot.cdbccxlt
               craprej.cdcooper = glb_cdcooper.
        VALIDATE craprej.
    END.    
             
END.    
    
DO WHILE TRUE TRANSACTION: 
   
   FIND crapres WHERE crapres.cdcooper = glb_cdcooper AND
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
