/******************************************************************************
                 ATENCAO!    CONVERSAO PROGRESS - ORACLE
            ESTE FONTE ESTA ENVOLVIDO NA MIGRACAO PROGRESS->ORACLE!
  +---------------------------------+-----------------------------------+
  | Rotina Progress                 | Rotina Oracle PLSQL               |
  +---------------------------------+-----------------------------------+
  | fontes/crps249_4.p              | pc_crps249_4                      |
  +---------------------------------+-----------------------------------+

  TODA E QUALQUER ALTERACAO EFETUADA NESSE FONTE A PARTIR DE 20/NOV/2012 DEVERA
  SER REPASSADA PARA ESTA MESMA ROTINA NO ORACLE, CONFORME DADOS ACIMA.

  PARA DETALHES DE COMO PROCEDER, FAVOR ENTRAR EM CONTATO COM AS SEGUINTES
  PESSOAS:
   - GUILHERME STRUBE    (CECRED)
   - MARCOS MARTINI      (SUPERO)

*******************************************************************************/




/* ..........................................................................

   Programa: Fontes/crps249_4.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autora  : Mirtes
   Data    : Fevereiro/2004                  Ultima atualizacao: 19/02/2014

   Dados referentes ao programa:

   Frequencia: Diario. Exclusivo.
   Objetivo  : Atende a solicitacao 76.
               Gerar arquivo para contabilidade.
               Ordem do programa na solicitacao 1.(DOC/TED - Arq.Craptvl)
               
   Alteracoes: 30/06/2005 - Alimentado cdcooper da tabela craprej (Diego). 

               15/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando. 
               
               23/03/2007 - Tratamento p/ hist. 542 e 549 - Bancoob (Ze).
               
               12/06/2007 - Acerto na composicao dos lancamentos (Ze).
               
               30/08/2007 - Acerto no hist. 549 e 558 (TED BANCOOB) (Ze).

               26/08/2009 - Substituicao do campo banco/agencia da COMPE, 
                            para o banco/agencia COMPE de DOC (cdagedoc e
                            cdbandoc) - (Sidnei - Precise).
               
               15/10/2009 - Inclusao de tratamento para banco CECRED junto com
                            BB e Bancoob. (Guilherme - Precise)

               21/05/2010 - Ajustes na contabilizacao da nossa IF (Magui).
               
               22/10/2013 - Ajuste de PA de 2 para 3 digitos.
                            (Andre Santos - SUPERO)
                            
               03/01/2014 - Trocar critica 15 Agencia nao cadastrada por 
                            962 PA nao cadastrado 
                            
               16/01/2014 - Inclusao de VALIDATE craprej (Carlos)
               
               19/02/2014 - Ajustado contadores para nao incluirem PA 999.
                            (Reinert)                            
............................................................................ */

{ includes/var_batch.i }

glb_cdprogra = "crps249".  /* igual ao origem */

DEF   VAR aux_vlccuage  AS DECI   EXTENT 999               NO-UNDO.
DEF   VAR aux_vlcxaage  AS DECI   EXTENT 999               NO-UNDO.
DEF   VAR aux_qtccuage  AS INT    EXTENT 999               NO-UNDO.
DEF   VAR aux_qtcxaage  AS INT    EXTENT 999               NO-UNDO.
DEF   VAR aux_contador  AS INT                             NO-UNDO.    
DEF   VAR aux_vltarifa  AS DECI                            NO-UNDO.
DEF   VAR aux_cdhistor  LIKE craphis.cdhistor              NO-UNDO.
DEF   VAR aux_tpdoctrf1 LIKE craptvl.tpdoctrf              NO-UNDO.
DEF   VAR aux_tpdoctrf2 LIKE craptvl.tpdoctrf              NO-UNDO.

DEF   VAR aux_cdagenci  AS INT                             NO-UNDO.
DEF   VAR aux_nrmaxpas  AS INT                             NO-UNDO.

/* Busca numero maximo de PA's */
FIND LAST crapage WHERE crapage.cdcooper = glb_cdcooper
                        NO-LOCK NO-ERROR.
IF  AVAIL crapage THEN
    ASSIGN aux_nrmaxpas = crapage.cdagenci.


aux_vltarifa = DECI("{5}").
aux_cdhistor = {2}.

FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.
/* AQUI */
IF  CAN-DO("523,549,558",STRING(aux_cdhistor)) THEN           /* TED */
    ASSIGN aux_tpdoctrf1 = 3
           aux_tpdoctrf2 = 3.  /* TED */
ELSE
    IF  CAN-DO("828,542,557",STRING(aux_cdhistor)) THEN       /* DOC */
        ASSIGN aux_tpdoctrf1 = 1   /* DOC C */
               aux_tpdoctrf2 = 2.  /* DOC D */

FOR EACH {1} WHERE {1}.cdcooper = glb_cdcooper AND
                   {1}.dtmvtolt = glb_dtmvtolt AND
                  ({1}.tpdoctrf = aux_tpdoctrf1 OR
                   {1}.tpdoctrf = aux_tpdoctrf2):
    
    ASSIGN aux_cdagenci = {1}.cdagenci.
           
    FIND crapage WHERE crapage.cdcooper = glb_cdcooper  AND
                       crapage.cdagenci = aux_cdagenci  NO-LOCK NO-ERROR.
   
    IF   NOT AVAIL crapage THEN
         DO:
             glb_cdcritic = 962.
             RUN fontes/critic.p.
             UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                               " - " + glb_cdprogra + "' --> '"  +
                               glb_dscritic + " >> log/proc_batch.log").
             RETURN.
         END.
    
    IF   craptvl.tpdoctrf = 3   THEN  /* TEDS */
         DO:
             IF  crapcop.flgopstr  THEN
                 DO:
                     IF CAN-DO("558,549",STRING(aux_cdhistor)) THEN /*IF 85 */
                        NEXT.
                 END.
             ELSE
                 IF aux_cdhistor = 523 THEN
                    NEXT.
         END.
    
    IF   CAN-DO("557,558",STRING(aux_cdhistor)) THEN /*BANCO DO BRASIL*/
         IF   crapage.cdbandoc <>  1  THEN
              NEXT.
              
    IF   CAN-DO("542,549",STRING(aux_cdhistor)) THEN /*BANCOOB DOC*/
         IF   crapage.cdbandoc <>  756  THEN
              NEXT.

    IF   aux_cdhistor = 828 THEN     /*  CECRED DOC  */
         IF   crapage.cdbandoc <>  crapcop.cdbcoctl  THEN
              NEXT.
          
    ASSIGN aux_vlcxaage[999]  = aux_vlcxaage[999]  + {1}.vldocrcb
           aux_qtcxaage[999]  = aux_qtcxaage[999]  + 1
    
           aux_vlcxaage[{1}.cdagenci] = aux_vlcxaage[{1}.cdagenci] +
                                        {1}.vldocrcb
           aux_qtcxaage[{1}.cdagenci] = aux_qtcxaage[{1}.cdagenci] + 1.
                               
END.    
/*----------------------------------------------------------------------------*/
IF   aux_vlcxaage[999] > 0 THEN
     DO  TRANSACTION ON ERROR UNDO, RETURN:

         IF   {3} = 2 OR {3} = 3 THEN  /* Detalhamento por agencia */
              DO  aux_contador = 1 TO 998:

                  IF   aux_vlcxaage[aux_contador] > 0 THEN
                       DO:
                           
                           CREATE craprej.
                           ASSIGN craprej.cdpesqbb = glb_cdprogra  
                                  craprej.cdagenci = aux_contador  
                                  craprej.cdhistor = aux_cdhistor
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
                       craprej.cdhistor = aux_cdhistor
                       craprej.dtmvtolt = glb_dtmvtolt
                       craprej.vllanmto = aux_vlcxaage[999]
                       craprej.nrseqdig = aux_qtcxaage[999]
                       craprej.dtrefere = "{1}"
                       craprej.cdcooper = glb_cdcooper.
                VALIDATE craprej.
            END.
                
     END.   /* transaction */

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
            crapres.nrdconta = aux_cdhistor.
            LEAVE.
        END.
        
END.  /*  Fim do DO WHILE TRUE  */

/* .......................................................................... */


