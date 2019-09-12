/* .............................................................................

   Programa: includes/proc_tratar_crapcch.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Margarete
   Data    : Setembro/2004                   Ultima atualizacao: 12/12/2013

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Procedures para tratar crapcch.
               Controles da Dctror e Mantal para enviar ao Banco do Brasil.

   Alteracoes: 19/04/2005 - Nao deixar gravar a tabela crapcch com 
                            crapcch.dtmvtolt = ?;
                            Comentarios na procedure grava_crapcch(Evandro).
                            
               08/06/2005 - Incluidos tipos de conta 17 e 18(Mirtes).

               06/07/2005 - Alimentado campo cdcooper da tabela crapcch (Diego).

               09/10/2005 - Alteracao de crapchq p/ crapfdc (SQLWorks - Andre).
               
               31/10/2005 - Alimentar o campo crapcch.nrdctitg (Edson).
               
               26/01/2006 - Unificacao dos Bancos - SQLWorks - Andre
               
               16/06/2006 - Nao eliminar crapcch(baixa contra-ordens e
                            cancelmaneto de cheques no mesmo dia(Mirtes).
                            
               13/02/2007 - Modificada variavel tel_nrdctabb para tel_nrctachq
                            (Diego).
                            
               02/03/2007 - Alteracao na crapcch para o BANCOOB (Evandro).

               08/03/2007 - Ajustes para o Bancoob (Magui).
               
               15/01/2009 - Alterado controle de envio de inclusao se houver
                            exclusao anterior e vice-versa para o Bancoob
                            (Evandro).
                            
               16/03/2010 - Mesmo tratamento para cheque do BANCOOB e CECRED
                            (Guilherme).
                            
               12/12/2013 - Alteracao referente a integracao Progress X 
                            Dataserver Oracle 
                            Inclusao do VALIDATE ( André Euzébio / SUPERO)               
............................................................................. */

PROCEDURE critica_conta_integracao:

   IF   glb_cdcritic = 0        AND
        crapass.cdtipcta > 11   AND
        crapass.cdtipcta < 19   AND
        crapass.flgctitg = 2    THEN
        DO:
            FIND FIRST crapcch WHERE crapcch.cdcooper = glb_cdcooper     AND
                                     crapcch.nrdconta = crapfdc.nrdconta AND
                                     crapcch.nrdctabb = crapfdc.nrdctabb AND
                                     crapcch.nrchqini = aux_nrchqini     AND
                                     crapcch.nrchqfim = aux_nrchqini     AND 
                                     crapcch.cdhistor <> 0               AND 
                                    (crapcch.flgctitg = 1                OR
                                     crapcch.flgctitg = 4)               AND
                                     crapcch.cdbanchq = 1 /* BB */
                                     NO-LOCK NO-ERROR.
            IF   AVAILABLE crapcch   THEN
                 ASSIGN glb_cdcritic = 219.
        END.

END PROCEDURE.

PROCEDURE grava_crapcch:

   /* Essa procedure faz a inclusao e a exclusao de registros na crapcch,
      as variaveis "aux_stlcmexc" e "aux_stlcmcad" recebem valores de acordo
      com o que sera feito(inclusao/exclusao).
      Se for uma INCLUSAO de contra-ordem no BB, ela verifica se ja existe uma
      EXCLUSAO da mesma contra-ordem que ainda NAO FOI ENVIADA, se houver, 
      entao essa exclusao sera deletada.
      Casa nao for encontrada essa EXCLUSAO NAO ENVIADA, ela verifica se ja
      houve uma INCLUSAO dessa MESMA contra-ordem, se houve, ela ATUALIZA os
      campos para ser enviada novamente, senao eh CRIADO um novo registro para
      fazer a INCLUSAO da contra-ordem no BB.
      No caso de uma EXCLUSAO o procedimento eh o mesmo de acordo com os 
      valores das variaveis "aux_stlcmexc" e "aux_stlcmcad" */
      
   /* Banco do Brasil */
   IF   crapfdc.cdbanchq = 1   THEN
        DO:    
            FIND FIRST crapcch WHERE crapcch.cdcooper = glb_cdcooper     AND
                                     crapcch.nrdconta = crapfdc.nrdconta AND
                                     crapcch.nrdctabb = crapfdc.nrdctabb AND
                                     crapcch.nrchqini = aux_nrchqini     AND 
                                     crapcch.nrchqfim = aux_nrchqini     AND 
                                     crapcch.cdhistor <> 0               AND 
                                     crapcch.cdhistor = aux_cdhistor     AND
                                     crapcch.tpopelcm = aux_stlcmexc     AND
                                     crapcch.flgctitg = 0                AND
                                     crapcch.cdbanchq = 1
                                     EXCLUSIVE-LOCK NO-ERROR.
                                     
            IF   AVAILABLE crapcch   THEN 
                 DELETE crapcch.
            ELSE 
                 DO:
                     FIND FIRST crapcch WHERE
                                crapcch.cdcooper = glb_cdcooper       AND
                                crapcch.nrdconta = crapfdc.nrdconta   AND
                                crapcch.nrdctabb = crapfdc.nrdctabb   AND
                                crapcch.nrchqini = aux_nrchqini       AND
                                crapcch.nrchqfim = aux_nrchqini       AND
                                crapcch.cdhistor <> 0                 AND
                                crapcch.tpopelcm = aux_stlcmcad       AND
                                crapcch.cdbanchq = 1
                                EXCLUSIVE-LOCK NO-ERROR.
                                
                     IF   AVAILABLE crapcch   THEN
                          DO:
                              IF   crapcch.flgctitg = 2   THEN
                                   ASSIGN crapcch.flgctitg = 0
                                          crapcch.nrseqarq = 0
                                          crapcch.cdhistor = aux_cdhistor.  
                              ELSE
                                   ASSIGN crapcch.cdhistor = aux_cdhistor.
                          END.
                     ELSE 
                          DO:    
                             CREATE crapcch.
                             ASSIGN crapcch.dtmvtolt = IF aux_dtemscch = ? THEN
                                                          glb_dtmvtolt
                                                       ELSE
                                                          aux_dtemscch
                                    crapcch.nrdconta = tel_nrdconta
                                    crapcch.nrdctabb = tel_nrctachq
                                    crapcch.nrdctitg = crapfdc.nrdctitg
                                    crapcch.nrtalchq = crapfdc.nrseqems
                                    crapcch.cdhistor = aux_cdhistor
                                    crapcch.nrchqini = aux_nrchqini
                                    crapcch.nrchqfim = aux_nrchqini 
                                    crapcch.tpopelcm = aux_stlcmcad
                                    crapcch.cdcooper = glb_cdcooper
                                    crapcch.cdbanchq = crapfdc.cdbanchq
                                    crapcch.cdagechq = crapfdc.cdagechq
                                    crapcch.nrctachq = tel_nrctachq.
                            VALIDATE crapcch.      
                          END.
                 END.
                 
            RELEASE crapcch.         
        END.
   ELSE
        /* BANCOOB e CECRED tem o mesmo tratamento */
        DO:
            /* Verifica qual foi a ultima movimentacao */
            FIND LAST crapcch WHERE crapcch.cdcooper = glb_cdcooper     AND
                                    crapcch.nrdconta = crapfdc.nrdconta AND
                                    crapcch.nrdctabb = crapfdc.nrdctabb AND
                                    crapcch.nrchqini = aux_nrchqini     AND 
                                    crapcch.nrchqfim = aux_nrchqini     AND 
                                    crapcch.cdhistor <> 0               AND 
                                    crapcch.cdhistor = aux_cdhistor     AND
                                    crapcch.cdbanchq = crapfdc.cdbanchq
                                    EXCLUSIVE-LOCK NO-ERROR.
                                     
            IF   AVAILABLE crapcch   THEN
                 DO:
                     /* Se tem um movimento anterior de exclusao nao enviado,
                        somente deleta esse registro */
                     IF   crapcch.tpopelcm = aux_stlcmexc   AND
                          crapcch.flgctitg = 0              THEN
                          DELETE crapcch.
                     ELSE
                     IF   crapcch.tpopelcm = aux_stlcmcad   THEN
                          /* Nao reenvia a inclusao */
                          ASSIGN crapcch.cdhistor = aux_cdhistor
                                 crapcch.tpopelcm = "3".
                     ELSE
                          DO:
                             CREATE crapcch.
                             ASSIGN crapcch.dtmvtolt = IF aux_dtemscch = ? THEN
                                                          glb_dtmvtolt
                                                       ELSE
                                                          aux_dtemscch
                                    crapcch.nrdconta = tel_nrdconta
                                    crapcch.nrdctabb = tel_nrctachq
                                    crapcch.nrdctitg = crapfdc.nrdctitg
                                    crapcch.nrtalchq = crapfdc.nrseqems
                                    crapcch.cdhistor = aux_cdhistor
                                    crapcch.nrchqini = aux_nrchqini
                                    crapcch.nrchqfim = aux_nrchqini 
                                    crapcch.tpopelcm = aux_stlcmcad
                                    crapcch.cdcooper = glb_cdcooper
                                    crapcch.cdbanchq = crapfdc.cdbanchq
                                    crapcch.cdagechq = crapfdc.cdagechq
                                    crapcch.nrctachq = tel_nrctachq.
                            VALIDATE crapcch.  
                          END.
                 END.
            ELSE
                 DO:
                     CREATE crapcch.
                     ASSIGN crapcch.dtmvtolt = IF aux_dtemscch = ? THEN
                                                  glb_dtmvtolt
                                               ELSE
                                                  aux_dtemscch
                            crapcch.nrdconta = tel_nrdconta
                            crapcch.nrdctabb = tel_nrctachq
                            crapcch.nrdctitg = crapfdc.nrdctitg
                            crapcch.nrtalchq = crapfdc.nrseqems
                            crapcch.cdhistor = aux_cdhistor
                            crapcch.nrchqini = aux_nrchqini
                            crapcch.nrchqfim = aux_nrchqini 
                            crapcch.tpopelcm = aux_stlcmcad
                            crapcch.cdcooper = glb_cdcooper
                            crapcch.cdbanchq = crapfdc.cdbanchq
                            crapcch.cdagechq = crapfdc.cdagechq
                            crapcch.nrctachq = tel_nrctachq.
                     VALIDATE crapcch.  
                 END.
            
            RELEASE crapcch.
        END.

END PROCEDURE.
 
 
                              
