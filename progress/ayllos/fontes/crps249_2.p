/******************************************************************************
                 ATENCAO!    CONVERSAO PROGRESS - ORACLE
            ESTE FONTE ESTA ENVOLVIDO NA MIGRACAO PROGRESS->ORACLE!
  +---------------------------------+-----------------------------------+
  | Rotina Progress                 | Rotina Oracle PLSQL               |
  +---------------------------------+-----------------------------------+
  | fontes/crps249_2.p              | pc_crps249_2                      |
  +---------------------------------+-----------------------------------+

  TODA E QUALQUER ALTERACAO EFETUADA NESSE FONTE A PARTIR DE 20/NOV/2012 DEVERA
  SER REPASSADA PARA ESTA MESMA ROTINA NO ORACLE, CONFORME DADOS ACIMA.

  PARA DETALHES DE COMO PROCEDER, FAVOR ENTRAR EM CONTATO COM AS SEGUINTES
  PESSOAS:
   - GUILHERME STRUBE    (CECRED)
   - MARCOS MARTINI      (SUPERO)

*******************************************************************************/




/* ..........................................................................

   Programa: Fontes/crps249_2.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Odair
   Data    : Novembro/98                         Ultima atualizacao: 19/02/2014

   Dados referentes ao programa:

   Frequencia: Diario. Exclusivo.
   Objetivo  : Atende a solicitacao .
               Gerar arquivo para contabilidade.
               Ordem do programa na solicitacao .

   Alteracoes: 13/06/2000 - Tratar quantidade dos lancamentos (Odair)

               25/04/2001 - Tratar pac ate 99 (Edson).

               30/06/2005 - Alimentado campo cdcooper da tabela craprej (Diego).

               15/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando.
               
               22/10/2013 - Ajuste de PA de 2 para 3 digitos.
                           (Andre Santos - SUPERO)
                           
               16/01/2014 - Inclusao de VALIDATE craprej (Carlos)
               
               19/02/2014 - Ajustado contadores para nao incluirem PA 999.
                            (Reinert)                            
                            
............................................................................. */


{ includes/var_batch.i } 

glb_cdprogra = "crps249".  /* igual ao origem */
                                         
DEF   VAR aux_vlccuage  AS DECI   EXTENT 999                NO-UNDO.
DEF   VAR aux_vlcxaage  AS DECI   EXTENT 999                NO-UNDO.
DEF   VAR aux_qtccuage  AS INT    EXTENT 999                NO-UNDO.
DEF   VAR aux_qtcxaage  AS INT    EXTENT 999                NO-UNDO.
DEF   VAR aux_contador  AS INT                              NO-UNDO.
DEF   VAR aux_nrmaxpas  AS INTE                             NO-UNDO.

/* Busca numero maximo de PA's */
FIND LAST crapage WHERE crapage.cdcooper = glb_cdcooper
                        NO-LOCK NO-ERROR.
IF  AVAIL crapage THEN
    ASSIGN aux_nrmaxpas = crapage.cdagenci.

FOR EACH {1} WHERE {1}.cdcooper = glb_cdcooper AND
                   {1}.dtmvtolt = glb_dtmvtolt AND 
                   {1}.cdhistor = {2}          NO-LOCK:
      
    ASSIGN aux_vlccuage[999]  = aux_vlccuage[999]  + {1}.vllanmto
           aux_qtccuage[999]  = aux_qtccuage[999]  + 1
           aux_vlcxaage[{1}.cdagenci] = aux_vlcxaage[{1}.cdagenci] +
                                        {1}.vllanmto
           aux_qtcxaage[{1}.cdagenci] = aux_qtcxaage[{1}.cdagenci] + 1.
                                         
END.    
    
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
                           VALIDATE craprej.
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
                VALIDATE craprej.
            END.
                
     END.   /* transaction */

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

