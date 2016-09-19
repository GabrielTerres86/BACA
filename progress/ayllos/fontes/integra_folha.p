/******************************************************************************
                 ATENCAO!    CONVERSAO PROGRESS - ORACLE
            ESTE FONTE ESTA ENVOLVIDO NA MIGRACAO PROGRESS->ORACLE!
  +---------------------------------+-----------------------------------+
  | Rotina Progress                 | Rotina Oracle PLSQL               |
  +---------------------------------+-----------------------------------+
  | fontes/integra_folha.p          | pc_crps120                        |
  +---------------------------------+-----------------------------------+

  TODA E QUALQUER ALTERACAO EFETUADA NESSE FONTE A PARTIR DE 20/NOV/2012 DEVERA
  SER REPASSADA PARA ESTA MESMA ROTINA NO ORACLE, CONFORME DADOS ACIMA.

  PARA DETALHES DE COMO PROCEDER, FAVOR ENTRAR EM CONTATO COM AS SEGUINTES
  PESSOAS:
   - GUILHERME STRUBE    (CECRED)
   - MARCOS MARTINI      (SUPERO)
   - LUCAS LOMBARDI      (CECRED)

*******************************************************************************/











/* ..........................................................................

   Programa: Fontes/integra_folha.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Junho/95.                           Ultima atualizacao: 01/09/2008
   
   Dados referentes ao programa:

   Frequencia: Diario (Batch).
   Objetivo  : Atender a solicitacao 062.
               Processar as integracoes de credito de pagamento e efetuar os
               debitos de cotas e emprestimos.
               Emite relatorio 98, 99 e 114.
-- ANTIGO CRPS120 ------------------------------------------------------------

   Alteracoes: 17/11/95 - Alterado para tratar debito do convenio de DENTISTAS
                          para a CEVAL JARAGUA DO SUL (Edson).

               18/11/96 - Alterado para marcar o indicador de integracao de
                          folha de pagto com feito (Edson).

               12/02/97 - Tratar CPMF (Odair).

               21/02/97 - Tratar convenio saude Bradesco (Odair).

               21/05/97 - Alterado para tratar demais convenios (Edson).

               05/06/97 - Criar tabela para descontar emprestimos e capital apos
                          a ultima folha da empresa (Odair).

               25/06/97 - Alterado para eliminar a leitura da tabela de histori-
                          cos de dentistas (Deborah).

               10/07/97 - Tratar historicos de saude bradesco cnv 14 (Odair)

               13/11/97 - Tratar convenio 18 e 19 (Odair).

               27/04/98 - Tratamento para milenio e troca para V8 (Margarete).
               
               22/11/98 - Tratar atendimento noturno (Deborah).
               
               26/02/99 - Tratar arquivos nao encontrados (Odair) 

             23/03/2003 - Incluir tratamento da Concredi (Margarete).

             29/06/2005 - Alimentado campo cdcooper da tabela craptab (Diego).
             
             16/02/2006 - Unificacao dos Bancos de Dados - SQLWorks - Andre

             05/06/2006 - Criar crapfol zerado para quem tem aviso de debito de 
                          emprestimo mas nao teve credito da folha (Julio)

             30/08/2006 - Somente criar crapfol se for integracao de credito 
                          de salario mensal (Julio)

             20/12/2007 - Remover arquivo de folha para o salvar apenas apos 
                          a solicitacao passar para status "processada" (Julio)
                          
             01/09/2008 - Alteracao CDEMPRES (Kbase).
             
             01/10/2013 - Renomeado "aux_nmarqimp" (EXTENT) para "aux_nmarquiv", 
                          pois aux_nmarqimp eh usado na impressao.i (Carlos)
                          
             25/10/2013 - Copia relatorio para o diretorio rlnsv (Carlos)
             
             29/10/2013 - Incluida var aux_flarqden para saber se copia o 
                          rel crrl114 para o dir rlnsv na sol062.p (Carlos)
-- ANTIGO CRPS120 ------------------------------------------------------------

-- INTEGRA FOLHA -------------------------------------------------------------

             08/10/2015 - Migração do conteúdo em progress do fonte crps120.p para 
                          integra_folha.p. O fonte crps120.p ficou apenas para 
                          chamar a rotina em ORACLE. 
                        - Ainda foram feitas alteracoes para que seja processado 
                          apenas o arquivo que foi pedido em tela, evitando 
                          duplicidades de registros.
                        - Criado novo estado para as solicitações: 3 - Abortado
                          para quando ocorrer algum erro durante o processo.
                          Chamado 306243 (Lombardi)

............................................................................. */
{ includes/var_online.i }

DEF  INPUT PARAM par_nrseqsol LIKE crapsol.nrseqsol                    NO-UNDO.

{ includes/var_crps120.i "new" }

ASSIGN glb_cdprogra = "crps120"
       glb_flgbatch = FALSE
       glb_cdcritic = 0
       glb_dscritic = "".

RUN fontes/iniprg.p.
            
IF  glb_cdcritic > 0 THEN DO:
    RETURN.
END.


IF   glb_inrestar > 0   AND   glb_nrctares = 0   THEN
     ASSIGN glb_inrestar = 0
            rel_qttarifa = 0
            aux_indmarca = 0.
ELSE
     ASSIGN rel_qttarifa = INTEGER(SUBSTRING(glb_dsrestar,1,6))
            aux_indmarca = INTEGER(SUBSTRING(glb_dsrestar,8,1)).

ASSIGN aux_regexist = FALSE
       aux_dtintegr = IF   glb_inproces > 2 THEN
                           glb_dtmvtopr
                      ELSE
                           IF   glb_inproces = 1 THEN
                                glb_dtmvtolt 
                           ELSE
                                ?

       aux_dtmvtolt = aux_dtintegr.

IF   aux_dtintegr = ?  THEN
     DO:
         glb_cdcritic = 138.
         RUN fontes/critic.p.
         UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                            glb_cdprogra + "' --> '" +
                            glb_dscritic + " >> log/proc_batch.log").
         RETURN.
     END.
           
/*  Leitura do cadastro de agencias  */

FOR EACH crapage WHERE crapage.cdcooper = glb_cdcooper NO-LOCK:

    rel_dsagenci[crapage.cdagenci] = STRING(crapage.cdagenci,"999") + " - " +
                                     crapage.nmresage.

END.  /*  Fim do FOR EACH -- Leitura do cadastro de agencias  */

/*  Leitura do indicador de uso da tabela de taxa de juros  */

FIND craptab WHERE craptab.cdcooper = glb_cdcooper AND
                   craptab.nmsistem = "CRED"       AND
                   craptab.tptabela = "USUARI"     AND
                   craptab.cdempres = 11           AND
                   craptab.cdacesso = "TAXATABELA" AND
                   craptab.tpregist = 0 NO-LOCK NO-ERROR.

IF   NOT AVAILABLE craptab   THEN
     tab_inusatab = FALSE.
ELSE
     tab_inusatab = IF SUBSTRING(craptab.dstextab,1,1) = "0"
                       THEN FALSE
                       ELSE TRUE.

/*  Historicos do convenio 14 - Plano de saude Bradesco ..................... */

FIND crapcnv WHERE crapcnv.cdcooper = glb_cdcooper AND
                   crapcnv.nrconven = 14           NO-LOCK NO-ERROR.

IF   NOT AVAILABLE crapcnv THEN
     aux_lshstsau = "".
ELSE
     aux_lshstsau = TRIM(crapcnv.lshistor).

/*  Historicos do convenio 10 e 15 - Hering e ADM diversos .................. */

FIND crapcnv WHERE crapcnv.cdcooper = glb_cdcooper AND
                   crapcnv.nrconven = 10           NO-LOCK NO-ERROR.

IF   NOT AVAILABLE crapcnv THEN
     aux_lshstdiv = "".
ELSE
     aux_lshstdiv = TRIM(crapcnv.lshistor).

FIND crapcnv WHERE crapcnv.cdcooper = glb_cdcooper AND
                   crapcnv.nrconven = 15           NO-LOCK NO-ERROR.

IF   AVAILABLE crapcnv THEN
     DO:
         IF   TRIM(crapcnv.lshistor) <> aux_lshstdiv   THEN
              aux_lshstdiv = aux_lshstdiv + "," + TRIM(crapcnv.lshistor).
     END.

FIND crapcnv WHERE crapcnv.cdcooper = glb_cdcooper AND
                   crapcnv.nrconven = 18           NO-LOCK NO-ERROR.

IF   NOT AVAILABLE crapcnv THEN
     aux_lshstfun = "".
ELSE
     aux_lshstfun = TRIM(crapcnv.lshistor).

FIND crapcnv WHERE crapcnv.cdcooper = glb_cdcooper AND
                   crapcnv.nrconven = 19           NO-LOCK NO-ERROR.

IF   AVAILABLE crapcnv THEN
     DO:
         IF   TRIM(crapcnv.lshistor) <> aux_lshstfun   THEN
              aux_lshstfun = aux_lshstfun + "," + TRIM(crapcnv.lshistor).
     END.

DO TRANSACTION:
    FIND crapsol WHERE crapsol.cdcooper = glb_cdcooper   AND
                       crapsol.dtrefere = glb_dtmvtolt   AND
                       crapsol.nrsolici = 62             AND
                       crapsol.nrseqsol = par_nrseqsol   AND
                       crapsol.insitsol = 1
                       EXCLUSIVE-LOCK  NO-ERROR NO-WAIT.
    IF  AVAILABLE crapsol   THEN
        DO:
            ASSIGN crapsol.insitsol = 3.
        END.
    ELSE
      IF   LOCKED crapsol   THEN
            DO: 
                
                MESSAGE "Este processo já esta sendo executado.".
                UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                                    glb_cdprogra + "' --> '" +
                                    "Este processo já esta sendo executado." + 
                                    " >> log/proc_batch.log").
                 RETURN.
            END.
            
            
END.

DO TRANSACTION ON ERROR UNDO, RETURN:
  /*  Leitura das solicitacoes de integracao  */

  find crapsol WHERE crapsol.cdcooper = glb_cdcooper   AND
                     crapsol.dtrefere = glb_dtmvtolt   AND
                     crapsol.nrsolici = 62             AND
                     SUBSTRING(crapsol.dsparame,15,1) = "2" AND
                     crapsol.nrseqsol = par_nrseqsol
                     USE-INDEX crapsol2
                     EXCLUSIVE-LOCK NO-ERROR.
  IF   AVAILABLE crapsol   THEN
     DO: 
        IF   glb_inrestar = 0 THEN
             rel_qttarifa = 0.
        
        aux_contador = 0.
     
        ASSIGN glb_cdcritic = 0
               glb_cdempres = 11
               glb_nrdevias = crapsol.nrdevias

               aux_cdempsol = crapsol.cdempres

               aux_regexist = TRUE
               aux_flgfirst = TRUE
               aux_flglotes = TRUE

               aux_nrlotfol = 0
               aux_nrlotcot = 0
               aux_nrlotemp = 0

               aux_flgclote = IF glb_inrestar = 0
                                 THEN TRUE
                                 ELSE FALSE

               aux_flgestou = IF SUBSTRING(crapsol.dsparame,17,1) = "1"
                                 THEN TRUE
                                 ELSE FALSE

               aux_nrseqsol = SUBSTRING(STRING(crapsol.nrseqsol,"9999"),3,2)

               aux_contaarq = aux_contaarq + 1
               aux_nmarquiv[aux_contaarq] = "rl/crrl098_" + aux_nrseqsol + ".lst"
               aux_nmarqest[aux_contaarq] = "rl/crrl099_" + aux_nrseqsol + ".lst"
               aux_nmarqden[aux_contaarq] = "rl/crrl114_" + aux_nrseqsol + ".lst"

               aux_nrdevias[aux_contaarq] = crapsol.nrdevias

               aux_dtrefere = DATE(INTEGER(SUBSTRING(crapsol.dsparame,4,2)),
                                   INTEGER(SUBSTRING(crapsol.dsparame,1,2)),
                                   INTEGER(SUBSTRING(crapsol.dsparame,7,4)))

               aux_nmarqint = "integra/f" +                         
                              STRING(crapsol.cdempres,"99999") +   
                              STRING(DAY(aux_dtrefere),"99") +
                              STRING(MONTH(aux_dtrefere),"99") +
                              STRING(YEAR(aux_dtrefere),"9999") + "." +
                              SUBSTRING(crapsol.dsparame,12,2).
        
        /*FIND crapemp OF crapsol NO-LOCK NO-ERROR.*/
        FIND crapemp WHERE crapemp.cdcooper = glb_cdcooper     AND
                           crapemp.cdempres = crapsol.cdempres NO-LOCK NO-ERROR.

        IF   NOT AVAILABLE crapemp   THEN
             ASSIGN rel_dsempres = STRING(crapsol.cdempres,"99999") + " - " +
                                   "NAO CADASTRADA"
                    aux_cdempfol = 0.
        ELSE
             ASSIGN rel_dsempres = STRING(crapemp.cdempres,"99999") + " - " +
                                   crapemp.nmresemp
                    aux_cdempfol = crapemp.cdempfol.
        
        /*  Verifica se o arquivo a ser integrado existe em disco  */
        IF  SEARCH(aux_nmarqint) = ?     THEN
             DO:
                 IF LENGTH(STRING(crapsol.cdempres)) < 3 THEN
                    DO:
                       ASSIGN aux_nmarqint = "integra/f" +
                                             STRING(crapsol.cdempres,"99") +   
                                             STRING(DAY(aux_dtrefere),"99") +
                                             STRING(MONTH(aux_dtrefere),"99") +
                                             STRING(YEAR(aux_dtrefere),"9999") + "." +
                                             SUBSTRING(crapsol.dsparame,12,2).
                                             
                       IF   SEARCH(aux_nmarqint) = ?   THEN
                            DO:

                                glb_cdcritic = 182.
                                RUN fontes/critic.p.
                                MESSAGE glb_dscritic.
                                UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + 
                                                  " - " +  glb_cdprogra + "' --> '" +
                                                  glb_dscritic + "' --> '" + 
                                                  aux_nmarqint +
                                                  " >> log/proc_batch.log").
                                                  
                                LEAVE.
                            END.
                    END.
                 ELSE
                    DO:
                        glb_cdcritic = 182.
                        RUN fontes/critic.p.
                        MESSAGE glb_dscritic.
                        UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + 
                                          " - " +  glb_cdprogra + "' --> '" +
                                          glb_dscritic + "' --> '" + 
                                          aux_nmarqint +
                                          " >> log/proc_batch.log").
                                          
                        LEAVE.
                    END.
             END.
                 
        /*  Inicializa flag de atualizacao do fator salarial  */

        FIND FIRST crapavs WHERE crapavs.cdcooper = glb_cdcooper   AND
                                 crapavs.dtrefere = aux_dtrefere   AND
                                 crapavs.tpdaviso = 1 NO-LOCK NO-ERROR.

        IF   NOT AVAILABLE crapavs   THEN
             aux_flgatual = FALSE.
        ELSE
             aux_flgatual = TRUE.

        IF   crapsol.cdempres = 11 OR
             crapsol.cdempres = 99 THEN
             aux_flgatual = FALSE.

        RUN fontes/crps120_3.p.
        
        IF   glb_cdcritic > 0 THEN
             RETURN.

        /*  Tratamento de ESTOUROS  */

        IF   aux_flgestou   THEN
             RUN fontes/crps120_e.p (INPUT crapsol.cdempres).

        ASSIGN glb_nrctares = 0
               glb_inrestar = 0
               rel_qttarifa = 0.

        DO WHILE TRUE ON ERROR UNDO, RETURN:

           IF   aux_indmarca = 1   THEN
                DO:
                    FIND craptab WHERE craptab.cdcooper = glb_cdcooper      AND
                                       craptab.nmsistem = "CRED"            AND
                                       craptab.tptabela = "GENERI"          AND
                                       craptab.cdempres = 0                 AND
                                       craptab.cdacesso = "DIADOPAGTO"      AND
                                       craptab.tpregist = crapsol.cdempres
                                       EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                    IF   NOT AVAILABLE craptab   THEN
                         IF   LOCKED craptab   THEN
                              DO:
                                  PAUSE 2 NO-MESSAGE.
                                  NEXT.
                              END.
                         ELSE .
                    ELSE
                         craptab.dstextab = SUBSTRING(craptab.dstextab,1,13) + "1".

                END.

           /*  Atualiza controle de convenios integrados na ultima folha  */

           IF   aux_flgestou   THEN
                DO:
                    IF   aux_dtrefere = glb_dtultdma   OR /*Somente criar crapfol*/
                         aux_dtrefere = glb_dtultdia   THEN /*se for folha mensal*/
                         FOR EACH crapavs WHERE 
                                          crapavs.cdcooper = glb_cdcooper     AND
                                          crapavs.cdempres = crapemp.cdempres AND
                                          crapavs.dtrefere = aux_dtrefere     AND
                                          crapavs.tpdaviso = 1                AND
                                          crapavs.insitavs = 0                AND
                                          crapavs.cdhistor = 108         NO-LOCK:

                             IF   NOT CAN-FIND(crapfol WHERE 
                                          crapfol.cdcooper = glb_cdcooper      AND
                                          crapfol.cdempres = crapavs.cdempres  AND
                                          crapfol.dtrefere = crapavs.dtrefere  AND
                                          crapfol.nrdconta = crapavs.nrdconta) THEN
                                  DO:
                                      CREATE crapfol.
                                      ASSIGN crapfol.cdcooper = glb_cdcooper
                                             crapfol.cdempres = crapavs.cdempres
                                             crapfol.dtrefere = crapavs.dtrefere
                                             crapfol.nrdconta = crapavs.nrdconta.
                                  END.
                         END. /* FOR EACH crapavs ..... */

                    FIND craptab WHERE craptab.cdcooper = glb_cdcooper      AND
                                       craptab.nmsistem = "CRED"            AND
                                       craptab.tptabela = "USUARI"          AND
                                       craptab.cdempres = crapemp.cdempres  AND
                                       craptab.cdacesso = "EXECDEBEMP"      AND
                                       craptab.tpregist = 0
                                       EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                    IF   NOT AVAILABLE craptab   THEN
                         IF   LOCKED craptab   THEN
                              DO:
                                  PAUSE 2 NO-MESSAGE.
                                  NEXT.
                              END.
                         ELSE
                              DO:
                                  CREATE craptab.
                                  ASSIGN craptab.nmsistem = "CRED"
                                         craptab.tptabela = "USUARI"
                                         craptab.cdempres = crapemp.cdempres
                                         craptab.cdacesso = "EXECDEBEMP"
                                         craptab.tpregist = 0
                                         craptab.cdcooper = glb_cdcooper.
                              END.

                    craptab.dstextab = STRING(aux_dtrefere,"99/99/9999") + " " +
                                       STRING(aux_dtintegr + 1,"99/99/9999") + " 0".

                    aux_dtsegdeb = glb_dtmvtopr.

                    IF   glb_inproces > 2   THEN
                         DO WHILE TRUE:

                            aux_dtsegdeb = aux_dtsegdeb + 1.

                            IF   CAN-DO("1,7",STRING(WEEKDAY(aux_dtsegdeb)))  OR
                                 CAN-FIND(crapfer WHERE
                                          crapfer.cdcooper = glb_cdcooper  AND
                                          crapfer.dtferiad = aux_dtsegdeb)   THEN
                                 NEXT.

                            LEAVE.

                         END.  /*  Fim do DO WHILE TRUE  */

                    FOR EACH crapepc WHERE crapepc.cdcooper = glb_cdcooper       AND
                                           crapepc.cdempres = crapsol.cdempres   AND
                                           crapepc.dtrefere = aux_dtrefere
                                           EXCLUSIVE-LOCK ON ERROR UNDO, RETRY:

                        IF   crapepc.incvfol1 = 1   THEN
                             ASSIGN crapepc.incvfol1 = 2
                                    crapepc.dtcvfol1 = glb_dtmvtolt
                                    crapepc.incvfol2 = 1
                                    crapepc.dtcvfol2 = aux_dtsegdeb.

                    END.  /*  Fim do FOR EACH  --  Leitura do crapepc  */
                END.
          
           ASSIGN crapsol.insitsol = 2
                  aux_indmarca     = 0.
           
           /*  Move arquivo integrado para o diretorio salvar  */
           UNIX SILENT VALUE("mv " + aux_nmarqint + " salvar").
           
           /* Copia relatorios para o diretorio rlnsv */
           UNIX SILENT VALUE("cp " + aux_nmarquiv[aux_contaarq] + " rlnsv").
           
           IF   (SUBSTRING(crapsol.dsparame,17,1)) = "1"  THEN
                UNIX SILENT VALUE("cp " + aux_nmarqest[aux_contaarq] + " rlnsv").
           
           /* Se tem registros, copia arquivo do rl para o dir rlnsv */
           IF  aux_flarqden THEN
               UNIX SILENT VALUE("cp " + aux_nmarqden[aux_contaarq] + " rlnsv").
           
           LEAVE.
           
        END.  /*  Fim do DO WHILE TRUE e da transacao  */
    END.  /*  Fim do FIND  -- Leitura da solicitacao --  */
END. /* Transaction */

IF   NOT aux_regexist   THEN
     DO:
         glb_cdcritic = 157.
         RUN fontes/critic.p.

         UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                           glb_cdprogra + "' --> '" + glb_dscritic +
                           " - SOL062" + " >> log/proc_batch.log").
         RETURN.
     END.

RUN fontes/fimprg.p.

/* .......................................................................... */
