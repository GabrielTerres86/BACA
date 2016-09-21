/*
 * Programa wpgd0048a.p - Listagem de Inscriçoes e participacoes (chamado a partir dos dados de wpgd0048)
 
   Alterações:  04/08/2009 - Incluída coluna "Contatos", e alterados relatórios  
                             Questionários entregues e devolvidos/Questionários entregues e não devolvidos, para
                                                         considerar somente 1º titular (Diego).
                                                         
                13/08/2009 - No relatório "Cooperados Sem Integração", tratar cada titular individualmente (Diego).
                
                10/09/2009 - Acerto nos totais de questionários entregues e devolvidos (Diego).
                
                19/02/2010 - No relatório "Cooperados Sem Integração", retirada condição 
                             crapidp.cdagenci = crapass.cdagenci (Diego).                                  
                             
                30/06/2010 - Somente lista no relatorio "Cooperados Sem Integracao" os cooperados que nao foram
                             demitidos (Elton).
                             
                23/11/2010 - Incluir coluna "Digitacao" no relatorio de questionario entregues e devolvidos
                             (Joao-RKAM)
                                                         
                05/06/2012 - Adaptação dos fontes para projeto Oracle. Alterado
                             busca na gnapses de CONTAINS para MATCHES (Guilherme Maba).                                                
                             
                28/11/2012 - Substituir tabela "gncoper" por "crapcop"
                             (David Kruger).
                             
                04/04/2013 - Alteração para receber logo na alto vale,
                             recebendo nome de viacrediav e buscando com
                             o respectivo nome (David Kruger).             
                             
                07/04/2014 - Incluir condicao crapass.dtdevqst = ? na function 
                             coopSemInteg(), nao deve listar estes registros (Lucas R.)
                             
                21/08/2014 - Alterado l-semInteg para iniciar como true para nao retornar sempre verdadeiro
                             mesmo que nao encontre registros na funcao ttlSemIntegracao (Lucas R. Softdesk 161454)
                                        
                
*/

CREATE WIDGET-POOL.

DEFINE VARIABLE cookieEmUso                  AS CHARACTER.
DEFINE VARIABLE permiteExecutar              AS CHARACTER.
DEFINE VARIABLE IdentificacaoDaSessao        AS CHARACTER.
DEFINE VARIABLE msgsDeErro                   AS CHARACTER.

DEFINE VARIABLE idEvento                     AS INTEGER.
DEFINE VARIABLE cdCooper                     AS INTEGER.
DEFINE VARIABLE cdAgenci                     AS INTEGER.
DEFINE VARIABLE dtAnoAge                     AS INTEGER.
DEFINE VARIABLE cdEvento                     AS INTEGER.
DEFINE VARIABLE nrSeqEve                     AS INTEGER.
DEFINE VARIABLE dataInicial                  AS DATE.
DEFINE VARIABLE dataFinal                    AS DATE.
DEFINE VARIABLE tipoDeRelatorio              AS INTEGER.
DEFINE VARIABLE consideraEventosForaDaAgenda AS LOGICAL.
DEFINE VARIABLE nomeDoRelatorio              AS CHARACTER INIT "Inscrições/Participações".

DEFINE VARIABLE imagemDoProgrid              AS CHARACTER.
DEFINE VARIABLE imagemDaCooperativa          AS CHARACTER.
DEFINE VARIABLE nomeDaCooperativa            AS CHARACTER.

DEFINE VARIABLE auxiliar                     AS CHARACTER.
DEFINE VARIABLE facilitador                  AS CHARACTER.
DEFINE VARIABLE facilitadores                AS CHARACTER.
DEFINE VARIABLE nomeDaAgencia                AS CHARACTER.
DEFINE VARIABLE localDoEvento1               AS CHARACTER.
DEFINE VARIABLE localDoEvento2               AS CHARACTER.
DEFINE VARIABLE aux_telefone                 AS CHARACTER         NO-UNDO.

DEFINE VARIABLE ajuste                       AS INTEGER.
DEFINE VARIABLE conta                        AS INTEGER.
DEFINE VARIABLE conta2                       AS INTEGER.
DEFINE VARIABLE corEmUso                     AS CHARACTER.
DEFINE VARIABLE mes                          AS CHARACTER INITIAL ["JANEIRO,FEVEREIRO,MARÇO,ABRIL,MAIO,JUNHO,JULHO,AGOSTO,SETEMBRO,OUTUBRO,NOVEMBRO,DEZEMBRO"].
DEFINE VARIABLE situacao                     AS CHARACTER INITIAL ["Pendente,Confirmado,Desistente,Excedente,Cancelado"].
DEFINE VARIABLE sobreNomeDoEvento            AS CHARACTER.
DEFINE VARIABLE valorDaVerba                 AS DECIMAL.
DEFINE VARIABLE totalVagas                   AS INT.
DEFINE VARIABLE geralVagas                   AS INT.

DEFINE VARIABLE iQtQstDevolvido              AS INT NO-UNDO.
DEFINE VARIABLE iQtQstDevolTotal             AS INT NO-UNDO.

DEFINE VARIABLE iEvento  AS INT NO-UNDO.

DEFINE VARIABLE iVlrCoop AS INT EXTENT 6 NO-UNDO.
DEFINE VARIABLE iVlrComu AS INT EXTENT 6 NO-UNDO.
DEFINE VARIABLE iValores AS INT EXTENT 6 NO-UNDO.

DEFINE VARIABLE iInsCoop      AS INT NO-UNDO.
DEFINE VARIABLE iCmpCoop      AS INT NO-UNDO.
DEFINE VARIABLE iInsComu      AS INT NO-UNDO.
DEFINE VARIABLE iCmpComu      AS INT NO-UNDO.
DEFINE VARIABLE iInscricao    AS INT NO-UNDO.
DEFINE VARIABLE iCompareceram AS INT NO-UNDO.

DEFINE VARIABLE iTotInsCoop      AS INT NO-UNDO.
DEFINE VARIABLE iTotCmpCoop      AS INT NO-UNDO.
DEFINE VARIABLE iTotInsComu      AS INT NO-UNDO.
DEFINE VARIABLE iTotCmpComu      AS INT NO-UNDO.
DEFINE VARIABLE iTotInscricao    AS INT NO-UNDO.
DEFINE VARIABLE iTotCompareceram AS INT NO-UNDO.

DEFINE VARIABLE aux_nmrescop     AS CHARACTER NO-UNDO.
                           
/*****************************************************************************/
/*   Bloco de temp-tables                                                    */
/*****************************************************************************/

DEF TEMP-TABLE ttCrapedp NO-UNDO
    FIELD cdeixtem LIKE crapedp.cdeixtem
    FIELD valores    AS INT EXTENT 6
    FIELD vlrcoop    AS INT EXTENT 6
    FIELD vlrcomu    AS INT EXTENT 6
    INDEX idx1 cdeixtem.

DEF TEMP-TABLE ttCrapass NO-UNDO
    FIELD cdagenci LIKE crapass.cdagenci
    FIELD dtadmiss LIKE crapass.dtadmiss
    FIELD nrdconta LIKE crapass.nrdconta
    FIELD nmextttl LIKE crapttl.nmextttl
    FIELD idseqttl LIKE crapttl.idseqttl
    FIELD dtentqst LIKE crapass.dtentqst
    FIELD dtdevqst LIKE crapass.dtdevqst
    FIELD dtcadqst LIKE crapass.dtcadqst /* Joao - 23/11/2010 */
    INDEX idx1 cdagenci dtadmiss nrdconta.



/*****************************************************************************/
/*   Bloco de includes                                                       */
/*****************************************************************************/

{src/web/method/wrap-cgi.i}

/*****************************************************************************/
/*   Bloco de funçoes                                                        */
/*****************************************************************************/

FUNCTION erroNaValidacaoDoLogin RETURNS LOGICAL (opcao AS CHARACTER):

    IF opcao = "1" THEN /* get-cookie em usuario-em-uso voltou valor nulo */
       {&out} '<script language="Javascript">' SKIP
              '   top.close(); ' SKIP
              '   window.open("falha","janela_principal","toolbar=yes,location=yes,diretories=no,status=yes,menubar=yes,scrollbars=yes,resizable=yes");' SKIP
              '</script>' SKIP.

    IF opcao = "2" THEN /* identificacao vinda do cookie bao existe na tabela de log de sessao */ 
       DO: 
          DELETE-COOKIE("cookie-usuario-em-uso",?,?).
          {&out} '<script language="Javascript">' SKIP
                 '   top.close(); ' SKIP
                 '   window.open("falha","janela_principal","toolbar=yes,location=yes,diretories=no,status=yes,menubar=yes,scrollbars=yes,resizable=yes");' SKIP
                 '</script>' SKIP.
       END.

    RETURN TRUE.

END FUNCTION. /* erroNaValidacaoDoLogin RETURNS LOGICAL () */

FUNCTION ttlSemIntegracao RETURNS LOGICAL(p-nrConta AS INT, p-idseqttl AS INT):
    DEF VAR l-semInteg AS LOG INIT TRUE NO-UNDO.
        
    FOR EACH crapidp WHERE crapidp.idevento = 1               AND
                           crapidp.cdcooper = CdCooper        AND 
                           crapidp.cdevento = 13              AND 
                           crapidp.nrdconta = p-nrConta       AND
                           crapidp.idseqttl = p-idseqttl  
                           NO-LOCK USE-INDEX crapidp6: 

        FIND crapadp WHERE crapadp.idEvento = crapidp.idEvento
                       AND crapadp.cdcooper = crapidp.cdCooper
                       AND crapadp.dtanoage = crapidp.dtanoage
                       AND crapadp.cdagenci = crapidp.cdagenci
                       AND crapadp.cdevento = crapidp.cdevento
                       AND crapadp.nrseqdig = crapidp.nrseqeve
                     NO-LOCK NO-ERROR.
                                         
        FIND FIRST Crapedp WHERE Crapedp.IdEvento = crapidp.IdEvento AND
                                 Crapedp.CdCooper = crapidp.CdCooper AND
                                 Crapedp.DtAnoAge = crapidp.DtAnoAge AND
                                 Crapedp.CdEvento = crapidp.CdEvento NO-LOCK NO-ERROR.
       
        /* confirmado */
        IF  Crapidp.IdStaIns = 2  AND crapadp.idstaeve <> 2 /*Cancelado*/ THEN 
            DO:
                IF  ((crapidp.qtfaleve * 100) / crapadp.QtDiaEve) > (100 - crapedp.prfreque) THEN 
                     ASSIGN l-semInteg = TRUE.
                ELSE 
                    ASSIGN l-semInteg = FALSE.
            END.   
        ELSE 
            ASSIGN l-semInteg = TRUE.
        
        IF  l-semInteg = FALSE THEN 
            DO:
                IF crapadp.dtfineve <> ? AND crapadp.dtfineve < TODAY THEN 
                   LEAVE.
                ELSE
                    ASSIGN l-semInteg = TRUE.
            END.
    END.

    RETURN l-semInteg.
END.   


FUNCTION viaInternet RETURNS LOGICAL():
    DEF VAR contador AS INT NO-UNDO.
    DEF VAR descAgencia AS CHAR NO-UNDO.
    DEF VAR agencias AS CHAR NO-UNDO.

    {&out} '   <table border="0" cellspacing="0" cellpadding="0" width="100%">' SKIP.
    IF cdAgenci = 0 THEN DO:
       {&out} '      <tr>' SKIP
              '         <td class="tdCab1" colspan="4">Via Internet - Todos os PAs</td>' SKIP
              '      </tr>' SKIP.
       DO iEvento = 1 TO 2:
          ASSIGN corEmUso = "#F5F5F5"
                 iValores = 0
                 iVlrCoop = 0
                 iVlrComu = 0.
          FOR EACH Crapadp WHERE Crapadp.IdEvento = iEvento  AND
                                 Crapadp.CdCooper = cdCooper AND
                                 Crapadp.DtAnoAge = dtAnoAge NO-LOCK:
              IF (Crapadp.DtFinEve >= dataInicial AND Crapadp.DtFinEve <= dataFinal) THEN DO:
                  FIND FIRST Crapedp WHERE Crapedp.IdEvento = Crapadp.IdEvento AND
                                           Crapedp.CdCooper = Crapadp.CdCooper AND
                                           Crapedp.DtAnoAge = Crapadp.DtAnoAge AND
                                           Crapedp.CdEvento = Crapadp.CdEvento NO-LOCK NO-ERROR.
                  FOR EACH crapidp WHERE crapidp.idevento = Crapadp.idevento  AND
                                         crapidp.cdcooper = Crapadp.CdCooper  AND 
                                         crapidp.dtanoage = Crapadp.DtAnoAge  AND 
                                         crapidp.cdagenci = Crapadp.cdagenci  AND 
                                         crapidp.cdevento = Crapadp.cdevento  AND 
                                         crapidp.nrseqeve = Crapadp.nrSeqDig  AND  
                                         crapidp.cdageins = Crapadp.cdagenci  NO-LOCK: 
                      IF crapidp.IdStaIns > 0 AND crapidp.IdStaIns < 6 THEN DO:
                          ASSIGN iValores[Crapidp.IdStaIns] = iValores[Crapidp.IdStaIns] + 1.
                          /* COMUNIDADE E COOPERATIVA */
                          IF crapidp.tpinseve = 1 THEN
                              ASSIGN iVlrCoop[Crapidp.IdStaIns] = iVlrCoop[Crapidp.IdStaIns] + 1.
                          ELSE 
                              ASSIGN iVlrComu[Crapidp.IdStaIns] = iVlrComu[Crapidp.IdStaIns] + 1.
                      END.
                      /* *** Se incricao cofirmada e inscricoes encerradas e evento NAO CANCELADO, verifica faltas ****/
                      IF Crapidp.IdStaIns = 2  AND Crapidp.QtFalEve > 0 AND Crapadp.idstaeve <> 2 /*Cancelado*/ THEN DO:
                         IF ((crapidp.qtfaleve * 100) / crapadp.QtDiaEve) > (100 - crapedp.prfreque) THEN DO:
                            ASSIGN iValores[6] = iValores[6] + 1.
                            IF crapidp.tpinseve = 1 THEN
                                ASSIGN iVlrCoop[6] = iVlrCoop[6] + 1.
                            ELSE 
                                ASSIGN iVlrComu[6] = iVlrComu[6] + 1.
                         END.
                      END.    
                  END.
              END.
          END.
          RUN telaViaInternet.
       END.
    END.
    ELSE DO:
       FIND Crapage WHERE Crapage.CdCooper = CdCooper AND Crapage.CdAgenci = CdAgenci NO-LOCK NO-ERROR.
       RUN agrupaAgencias((IF AVAILABLE Crapage THEN trim(crapage.NmResAge) ELSE ("Agencia " + STRING(Cdagenci,"999"))),
                          OUTPUT descAgencia, OUTPUT agencias).
       {&out} '      <tr>' SKIP
              '         <td class="tdCab1" colspan="4">Via Internet - PA: ' cdagenci ' - ' descAgencia '</td>' SKIP
              '      </tr>' SKIP.
       DO iEvento = 1 TO 2:
          ASSIGN corEmUso = "#F5F5F5"
                 iValores = 0
                 iVlrCoop = 0
                 iVlrComu = 0.
          DO contador = 1 TO NUM-ENTRIES(agencias):
              FOR EACH Crapadp WHERE Crapadp.IdEvento = iEvento  AND
                                     Crapadp.CdCooper = cdCooper AND
                                     crapadp.cdagenci = INT(ENTRY(contador,agencias)) AND
                                     Crapadp.DtAnoAge = dtAnoAge NO-LOCK:
                  IF (Crapadp.DtFinEve >= dataInicial AND Crapadp.DtFinEve <= dataFinal) THEN DO:
                      FIND FIRST Crapedp WHERE Crapedp.IdEvento = Crapadp.IdEvento AND
                                               Crapedp.CdCooper = Crapadp.CdCooper AND
                                               Crapedp.DtAnoAge = Crapadp.DtAnoAge AND
                                               Crapedp.CdEvento = Crapadp.CdEvento NO-LOCK NO-ERROR.
                      FOR EACH crapidp WHERE crapidp.idevento = Crapadp.idevento  AND
                                             crapidp.cdcooper = Crapadp.CdCooper  AND 
                                             crapidp.dtanoage = Crapadp.DtAnoAge  AND 
                                             crapidp.cdagenci = Crapadp.cdagenci  AND 
                                             crapidp.cdevento = Crapadp.cdevento  AND 
                                             crapidp.nrseqeve = Crapadp.nrSeqDig  AND  
                                             crapidp.cdageins = Crapadp.cdagenci  AND
                                             crapidp.flginsin = YES NO-LOCK: 
                          IF crapidp.IdStaIns > 0 AND crapidp.IdStaIns < 6  THEN DO:
                              ASSIGN iValores[Crapidp.IdStaIns] = iValores[Crapidp.IdStaIns] + 1.
                              /* COMUNIDADE E COOPERATIVA */
                              IF crapidp.tpinseve = 1 THEN
                                  ASSIGN iVlrCoop[Crapidp.IdStaIns] = iVlrCoop[Crapidp.IdStaIns] + 1.
                              ELSE 
                                  ASSIGN iVlrComu[Crapidp.IdStaIns] = iVlrComu[Crapidp.IdStaIns] + 1.
                          END.
                          /* *** Se incricao cofirmada e inscricoes encerradas e evento NAO CANCELADO, verifica faltas ****/
                          IF Crapidp.IdStaIns = 2  AND  Crapidp.QtFalEve > 0 AND Crapadp.idstaeve <> 2 /*Cancelado*/ THEN DO:
                             IF ((crapidp.qtfaleve * 100) / crapadp.QtDiaEve) > (100 - crapedp.prfreque) THEN DO:
                                ASSIGN iValores[6] = iValores[6] + 1.
                              /* COMUNIDADE E COOPERATIVA */
                                IF crapidp.tpinseve = 1 THEN
                                    ASSIGN iVlrCoop[6] = iVlrCoop[6] + 1.
                                ELSE 
                                    ASSIGN iVlrComu[6] = iVlrComu[6] + 1.
                             END.
                          END.    
                      END.
                  END.
              END.
          END.
          RUN telaViaInternet.
       END.
    END.
    {&out} '   </table>' SKIP.
    RETURN TRUE.
END FUNCTION. /* viaInternet RETURNS LOGICAL () */

FUNCTION eixoTematico RETURNS LOGICAL ():
    DEF VAR contador AS INT NO-UNDO.
    DEF VAR descAgencia AS CHAR NO-UNDO.
    DEF VAR agencias AS CHAR NO-UNDO.

    {&out} '   <table border="0" cellspacing="0" cellpadding="0" width="100%">' SKIP.
    {&out} '      <tr>' SKIP
           '         <td class="tdCab1" colspan="4">Eixo Tematico</td>' SKIP
           '      </tr>' SKIP.
    IF cdAgenci = 0 THEN DO:
       {&out} '      <tr>' SKIP
              '         <td class="tdCab2" colspan="4">Todos os PAs</td>' SKIP
              '      </tr>' SKIP.
    END. 
    ELSE DO:
        FIND Crapage WHERE Crapage.CdCooper = CdCooper AND Crapage.CdAgenci = CdAgenci NO-LOCK NO-ERROR.
        RUN agrupaAgencias((IF AVAILABLE Crapage THEN trim(crapage.NmResAge) ELSE ("Agencia " + STRING(Cdagenci,"999"))),
                           OUTPUT descAgencia, OUTPUT agencias).
        {&out} '      <tr>' SKIP
               '         <td class="tdCab2" colspan="4">PA: ' cdagenci ' - ' crapage.nmResAge '</td>' SKIP
               '      </tr>' SKIP.
    END.
    FOR EACH Crapedp WHERE Crapedp.IdEvento = 1                AND
                           Crapedp.CdCooper = CdCooper AND
                           Crapedp.DtAnoAge = DtAnoAge NO-LOCK:
        FIND FIRST ttCrapedp WHERE ttCrapedp.cdeixtem = crapedp.cdeixtem NO-LOCK NO-ERROR.
        IF NOT AVAIL ttCrapedp THEN DO:
           CREATE ttCrapedp.
           ASSIGN ttCrapedp.cdeixtem = crapedp.cdeixtem.
        END.
        IF  cdAgenci = 0 THEN DO:
            FOR EACH crapidp WHERE crapidp.idevento = Crapedp.idevento  AND
                                   crapidp.cdcooper = Crapedp.CdCooper  AND 
                                   crapidp.dtanoage = Crapedp.DtAnoAge  AND 
                                   crapidp.cdevento = Crapedp.cdevento  NO-LOCK:
                IF crapidp.IdStaIns > 0 AND crapidp.IdStaIns < 6 THEN DO:
                    ASSIGN ttcrapedp.valores[Crapidp.IdStaIns] = ttcrapedp.valores[Crapidp.IdStaIns] + 1.
                    /* COMUNIDADE E COOPERATIVA */
                    IF crapidp.tpinseve = 1 THEN
                        ASSIGN ttcrapedp.vlrCoop[Crapidp.IdStaIns] = ttcrapedp.vlrCoop[Crapidp.IdStaIns] + 1.
                    ELSE 
                        ASSIGN ttcrapedp.vlrComu[Crapidp.IdStaIns] = ttcrapedp.vlrComu[Crapidp.IdStaIns] + 1.
                END.
            END.
        END.
        ELSE DO:
            DO contador = 1 TO NUM-ENTRIES(agencias):
                FOR EACH crapidp WHERE crapidp.idevento = Crapedp.idevento  AND
                                       crapidp.cdcooper = Crapedp.CdCooper  AND 
                                       crapidp.dtanoage = Crapedp.DtAnoAge  AND 
                                       crapidp.cdagenci = INT(ENTRY(contador,agencias))  AND 
                                       crapidp.cdevento = Crapedp.cdevento  NO-LOCK:
                    IF crapidp.IdStaIns > 0 AND crapidp.IdStaIns < 6 THEN DO:
                        ASSIGN ttcrapedp.valores[Crapidp.IdStaIns] = ttcrapedp.valores[Crapidp.IdStaIns] + 1.
                        /* COMUNIDADE E COOPERATIVA */
                        IF crapidp.tpinseve = 1 THEN
                            ASSIGN ttcrapedp.vlrCoop[Crapidp.IdStaIns] = ttcrapedp.vlrCoop[Crapidp.IdStaIns] + 1.
                        ELSE 
                            ASSIGN ttcrapedp.vlrComu[Crapidp.IdStaIns] = ttcrapedp.vlrComu[Crapidp.IdStaIns] + 1.
                    END.
                END.
            END.
        END.
    END.
    RUN telaEixoTematico.
    {&out} '   </table>' SKIP.
    RETURN TRUE.
END FUNCTION. /* eixoTematico RETURNS LOGICAL () */


FUNCTION coopSemInteg RETURNS LOGICAL ():
    DEF VAR contador AS INT NO-UNDO.
    DEF VAR descAgencias AS CHAR NO-UNDO.
    DEF VAR agencias AS CHAR NO-UNDO.
        
    {&out} '   <table border="0" cellspacing="0" cellpadding="0" width="100%">' SKIP.
    {&out} '      <tr>' SKIP
           '         <td class="tdCab1" colspan="5">Cooperados Sem Integração</td>' SKIP
           '      </tr>' SKIP.
    
    IF cdagenci <> 0 THEN DO:
        RUN agrupaAgencias(INPUT "", OUTPUT descAgencias, OUTPUT agencias).
        DO contador = 1 TO NUM-ENTRIES(agencias):
            FOR EACH crapass WHERE crapass.cdcooper = cdcooper
                               AND crapass.cdagenci = int(entry(contador,agencias))
                               AND crapass.dtadmiss >= datainicial
                               AND crapass.dtadmiss <= datafinal
                               AND crapass.dtdemiss = ?
                               AND crapass.dtdevqst = ?
                             NO-LOCK,
                EACH crapttl WHERE crapttl.cdcooper = crapass.cdcooper
                               AND crapttl.nrdconta = crapass.nrdconta
                             NO-LOCK:
                                
                IF  ttlSemIntegracao(crapass.nrdconta, crapttl.idseqttl) THEN 
                    DO:
                       CREATE ttCrapass.
                       ASSIGN ttCrapass.cdagenci = crapass.cdagenci
                              ttCrapass.dtadmiss = crapass.dtadmiss
                              ttCrapass.nrdconta = crapass.nrdconta
                              ttCrapass.nmextttl = crapttl.nmextttl
                              ttCrapass.idseqttl = crapttl.idseqttl.
                    END.
            END.
        END.
    END.
    ELSE DO:
        FOR EACH crapass WHERE crapass.cdcooper = cdcooper
                           AND crapass.dtadmiss >= datainicial
                           AND crapass.dtadmiss <= datafinal
                           AND crapass.dtdemiss = ? 
                           AND crapass.dtdevqst = ?
                         NO-LOCK,
            EACH crapttl WHERE crapttl.cdcooper = crapass.cdcooper
                           AND crapttl.nrdconta = crapass.nrdconta
                         NO-LOCK:

            IF  ttlSemIntegracao(crapass.nrdconta, crapttl.idseqttl) THEN 
                DO:
                    CREATE ttCrapass.
                    ASSIGN ttCrapass.cdagenci = crapass.cdagenci
                           ttCrapass.dtadmiss = crapass.dtadmiss
                           ttCrapass.nrdconta = crapass.nrdconta
                           ttCrapass.nmextttl = crapttl.nmextttl
                           ttCrapass.idseqttl = crapttl.idseqttl.
                END.
        END.
    END.
    RUN telaCoopSemInt.
    {&out} '   </table>' SKIP.
    RETURN TRUE.

END FUNCTION.  /* coopSemInteg */


FUNCTION questEntDev RETURNS LOGICAL (tipoRelat AS INT):
    DEF VAR contador AS INT NO-UNDO.
    DEF VAR descAgencias AS CHAR NO-UNDO.
    DEF VAR agencias AS CHAR NO-UNDO.

    {&out} '   <table border="0" cellspacing="0" cellpadding="0" width="100%">' SKIP.
    {&out} '      <tr>' SKIP.
    IF tipoRelat = 1 THEN
       {&out} '         <td class="tdCab1" colspan="7">Questionários entregues e devolvidos</td>' SKIP.
    ELSE
       {&out} '         <td class="tdCab1" colspan="7">Questionários entregues e não devolvidos</td>' SKIP.
    {&out} '      </tr>' SKIP.
    IF cdagenci <> 0 THEN DO:
       RUN agrupaAgencias(INPUT "", OUTPUT descAgencias, OUTPUT agencias).
       DO contador = 1 TO NUM-ENTRIES(agencias):
           FOR EACH crapass WHERE crapass.cdcooper = cdcooper
                             AND crapass.cdagenci = int(ENTRY(contador,agencias))
                              AND crapass.dtadmiss >= datainicial
                              AND crapass.dtadmiss <= datafinal
                            NO-LOCK,
               EACH crapttl WHERE crapttl.cdcooper = crapass.cdcooper
                              AND crapttl.nrdconta = crapass.nrdconta
                                                          AND crapttl.idseqttl = 1
                            NO-LOCK:
               
               IF  tipoRelat = 2   THEN
                   DO:
                       IF  crapass.dtentqst = ?  THEN
                           NEXT.
                       ELSE
                       IF  crapass.dtdevqst <> ? THEN
                           NEXT.
                   END.
                                                    
               

               CREATE ttCrapass.
               ASSIGN ttCrapass.cdagenci = crapass.cdagenci
                      ttCrapass.dtadmiss = crapass.dtadmiss
                      ttCrapass.nrdconta = crapass.nrdconta
                      ttCrapass.nmextttl = crapttl.nmextttl
                      ttCrapass.dtentqst = crapass.dtentqst
                      ttCrapass.dtdevqst = crapass.dtdevqst
                      ttCrapass.dtcadqst = crapass.dtcadqs. /* 23/11/2010 */
           END.
       END.
    END.
    ELSE DO:
        FOR EACH crapass WHERE crapass.cdcooper = cdcooper
                           AND crapass.dtadmiss >= datainicial
                           AND crapass.dtadmiss <= datafinal
                         NO-LOCK,
            EACH crapttl WHERE crapttl.cdcooper = crapass.cdcooper
                           AND crapttl.nrdconta = crapass.nrdconta
                                                   AND crapttl.idseqttl = 1
                         NO-LOCK:
                        
                        IF tipoRelat = 2   THEN
                              IF   crapass.dtentqst = ?  THEN
                                       NEXT.
                                  ELSE
                                       IF  crapass.dtdevqst <> ? THEN
                                               NEXT.
                                                   
            CREATE ttCrapass.
            ASSIGN ttCrapass.cdagenci = crapass.cdagenci
                   ttCrapass.dtadmiss = crapass.dtadmiss
                   ttCrapass.nrdconta = crapass.nrdconta
                   ttCrapass.nmextttl = crapttl.nmextttl
                   ttCrapass.dtentqst = crapass.dtentqst
                   ttCrapass.dtdevqst = crapass.dtdevqst
                   ttCrapass.dtcadqst = crapass.dtcadqs. /* 23/11/2010 */
        END.
    END.
    RUN telaQuestEntDev (tipoRelat).
    {&out} '   </table>' SKIP.
    RETURN TRUE.
END.   /* questionarios entregues, devolvidos ou não devovidos */

FUNCTION montaTela RETURNS LOGICAL():

    FIND crapcop WHERE crapcop.cdcooper = cdCooper NO-LOCK NO-ERROR.

    IF AVAILABLE crapcop THEN
       DO:
          ASSIGN imagemDoProgrid      = "/cecred/images/geral/logo_cecred.gif"
                 nomedacooperativa    = TRIM(crapcop.nmrescop).
         
          IF INDEX(crapcop.nmrescop, " ") <> 0  THEN
             DO: 
                aux_nmrescop = LC(TRIM(crapcop.nmrescop)).
                SUBSTRING( aux_nmrescop, (INDEX(aux_nmrescop, " ")),1) = "_".
                imagemDaCooperativa =  "/cecred/images/admin/logo_" +  aux_nmrescop.
             END.
          ELSE
             imagemDaCooperativa  = "/cecred/images/admin/logo_" + TRIM(LC(crapcop.nmrescop)) + ".gif" .
            
       END.

    
    {&out} '<html>' SKIP
           '<head>' SKIP
           '<title>Progrid - Orçamento</title>' SKIP.

    {&out} '<style>' SKIP
           '   body         ~{ background-color: #FFFFFF; }' SKIP
           '   td           ~{ font-family: Arial, Helvetica, sans-serif; font-size: 11px; font-weight: bold; }' SKIP
           '   .tdCab1      ~{ background-color: #B1B1B1; font-family: Arial, Helvetica, sans-serif; font-size: 14px; font-weight: bold; }' SKIP
           '   .tdCab2      ~{ background-color: #C6C6C6; font-family: Arial, Helvetica, sans-serif; font-size: 12px; font-weight: bold; }' SKIP
           '   .tdCab3      ~{ background-color: #DBDBDB; font-family: Arial, Helvetica, sans-serif; font-size: 11px; font-weight: bold; }' SKIP
           '   .tdLabel     ~{ font-family: Arial, Helvetica, sans-serif; font-size: 11px; font-weight: bold; }' SKIP
           '   .tdDados     ~{ font-family: Arial, Helvetica, sans-serif; font-size: 11px; font-weight: normal; border-bottom: #000000 0px solid }' SKIP
           '   .tdTitulo1   ~{ font-family: Verdana; font-size: 24px; font-weight: normal;}' SKIP
           '   .tab1        ~{ border-collapse:collapse; border-top: #000000 1px solid; border-bottom: #000000 1px solid; border-right: #000000 1px solid; border-left: #000000 1px solid; }' SKIP
           '</style>' SKIP.

    {&out} '</head>' SKIP
           '<body bgcolor="#FFFFFF" topmargin="0" marginwidth="0" marginheight="0">' SKIP
           '<div align="center">' SKIP.
    
    /* *** Botoes de fechar e imprimir *** */
    {&out} '<div align="right" id="botoes">' SKIP
           '   <table border="0" cellspacing="0" cellpadding="0" width="100%">' SKIP
           '      <tr>' SKIP
           '         <td align="right">' SKIP
           '            <img src="/cecred/images/botoes/btn_fechar.gif" alt="Fechar esta janela" style="cursor: hand" onClick="top.close()">' SKIP
           '            <img src="/cecred/images/botoes/btn_imprimir.gif" alt="Imprimir" style="cursor: hand" onClick="document.all.botoes.style.visibility = ~'hidden~'; print(); document.all.botoes.style.visibility = ~'visible~';">' SKIP
           '         </td>' SKIP
           '      </tr>' SKIP
           '   </table>' SKIP
           '</div>' SKIP.

    {&out} '   <table border="0" cellspacing="0" cellpadding="0" width="100%">' SKIP
           '      <tr>' SKIP
           '         <td class="tdprogra" colspan="5" align="right">wpgd0048a - ' TODAY '</td>' SKIP
           '   </table>' SKIP. 

    /* *** Logo *** */
    {&out} '   <table border="0" cellspacing="0" cellpadding="0" width="100%" class="tab1">' SKIP
           '      <tr>' SKIP
           '         <td align="center"><img src="' imagemDoProgrid '" border="0"></td>' SKIP
           '         <td class="tdTitulo1" colspan="4" align="center">' nomeDaCooperativa ' - ' dtAnoAge '</td>' SKIP
           '         <td align="center"><img src="' imagemDaCooperativa '" border="0"></td>' SKIP
           '      </tr>' SKIP
           '      <tr>' SKIP
           '         <td align="center" colspan="6"> &nbsp; </td>' SKIP
           '      </tr>' SKIP
           '      <tr>' SKIP
           '         <td align="center" colspan="6">Periodo de ' STRING(dataInicial,"99/99/9999") ' a ' STRING(dataFinal,"99/99/9999") '&nbsp;&nbsp;' nomeDoRelatorio  '</td>' SKIP
           '      </tr>' SKIP
           '   </table>' SKIP. 

    {&out} '<br>' SKIP.

    CASE tipoDeRelatorio:
       WHEN 1 THEN
         viaInternet().
       WHEN 2 THEN
         eixoTematico().
       WHEN 3 THEN
          coopSemInteg().
       WHEN 4 THEN
          questEntDev(1).
       WHEN 5 THEN
          questEntDev(2).
       OTHERWISE
         ASSIGN msgsDeErro = msgsDeErro + "-> Tipo de relatório ainda não implementado.<br>".
    END CASE.

    IF msgsDeErro <> "" THEN
       {&out} '   <table border="0" cellspacing="1" cellpadding="1">' SKIP
              '      <tr>' SKIP
              '         <td>' msgsDeErro '</td>' SKIP
              '      </tr>' SKIP
              '   </table>' SKIP.

    {&out} '</div>' SKIP
           '</body>' SKIP
           '</html>' SKIP.

    RETURN TRUE.

END FUNCTION. /* montaTela RETURNS LOGICAL () */

/*****************************************************************************/
/*   Bloco de principal do programa                                          */
/*****************************************************************************/

output-content-type("text/html").

ASSIGN cookieEmUso = GET-COOKIE("cookie-usuario-em-uso").

/* Usado FOR EACH para poder utilizar o CONTAINS e WORD-INDEX, alterado para MATCHES */
FOR EACH gnapses WHERE gnapses.idsessao MATCHES "*" + cookieEmUso + "*" NO-LOCK:
    LEAVE.
END.

RUN PermissaoDeAcesso("", OUTPUT IdentificacaoDaSessao, OUTPUT permiteExecutar).

IF permiteExecutar = "1" OR permiteExecutar = "2" THEN
   erroNaValidacaoDoLogin(permiteExecutar).
ELSE DO:
   ASSIGN idEvento                     = INTEGER(GET-VALUE("parametro1"))
          cdCooper                     = INTEGER(GET-VALUE("parametro2"))
          cdAgenci                     = INTEGER(GET-VALUE("parametro3"))
          dtAnoAge                     = INTEGER(GET-VALUE("parametro4"))
          cdEvento                     = 0 /* INTEGER(GET-VALUE("parametro5")) */
          nrSeqEve                     = 0 /* INTEGER(GET-VALUE("parametro6")) */
          dataInicial                  = DATE(GET-VALUE("parametro7"))
          dataFinal                    = DATE(GET-VALUE("parametro8")) 
          consideraEventosForaDaAgenda = NO /* IF GET-VALUE("parametro9") = "SIM" THEN YES ELSE NO */
          tipoDeRelatorio              = INTEGER(GET-VALUE("parametro10"))
          NO-ERROR.          
   /* *** Localiza os eventos que satisfazem ao filtro (apenas custos diretos) *** */

   montaTela().
   
END.
          
/*****************************************************************************/
/*                                                                           */
/*   Bloco de procdures                                                      */
/*                                                                           */
/*****************************************************************************/

PROCEDURE PermissaoDeAcesso :

    {includes/wpgd0009.i}

END PROCEDURE.

PROCEDURE agrupaAgencias:
    DEF INPUT PARAM descEntrada AS CHAR NO-UNDO.
    DEF OUTPUT PARAM descSaida  AS CHAR NO-UNDO.
    DEF OUTPUT PARAM codAgencias AS CHAR NO-UNDO.

    /* Agrupa agencias */
    ASSIGN descSaida = descEntrada
           codAgencias = STRING(cdagenci). 
    IF CAN-FIND(FIRST crapadp WHERE crapadp.idevento = 1                  AND
                                    crapadp.cdcooper = cdCooper AND
                                    crapadp.dtanoage = dtAnoAge           AND 
                                    crapadp.cdagenci = cdagenci)  THEN DO:
       FOR EACH crapadp WHERE crapadp.idevento = 1                  AND
                crapadp.cdcooper = cdCooper AND
                crapadp.dtanoage = dtAnoAge AND 
                crapadp.cdagenci = cdagenci  NO-LOCK:
           IF CAN-FIND(FIRST crapagp WHERE crapagp.idevento  = crapadp.idevento AND
                                           crapagp.cdcooper  = crapadp.cdcooper  AND
                                           crapagp.dtanoage  = crapadp.dtanoage  AND
                                           crapagp.cdagenci <> crapagp.cdageagr  AND
                                           crapagp.cdageagr  = crapadp.cdagenci) THEN DO:
              FOR EACH crapagp WHERE crapagp.idevento  = crapadp.idevento  AND
                                     crapagp.cdcooper  = crapadp.cdcooper  AND
                                     crapagp.dtanoage  = crapadp.dtanoage  AND
                                     crapagp.cdagenci <> crapagp.cdageagr  AND
                                     crapagp.cdageagr  = crapadp.cdagenci  NO-LOCK:
                  FIND crapage WHERE crapage.cdcooper = crapagp.cdcooper   AND
                                     crapage.cdagenci = crapagp.cdagenci   NO-LOCK NO-ERROR.
                  ASSIGN descSaida = descSaida + "~/" + crapage.nmresage
                         codAgencias = codAgencias + "," + string(crapage.cdagenci).
              END.
              LEAVE.
           END.
       END.
    END.
END.

PROCEDURE faltasAss:
   DEFINE INPUT PARAM p-cdagenci AS INT NO-UNDO.
   ASSIGN iValores = 0.
   FOR EACH Crapadp WHERE Crapadp.IdEvento = 1  AND
                          Crapadp.CdCooper = cdCooper AND
                          crapadp.cdagenci = p-cdAgenci AND
                          Crapadp.DtAnoAge = dtAnoAge AND 
                          crapadp.cdEvento = 13 NO-LOCK:
       IF (Crapadp.DtFinEve >= dataInicial AND Crapadp.DtFinEve <= dataFinal) THEN DO:
           FIND FIRST Crapedp WHERE Crapedp.IdEvento = Crapadp.IdEvento AND
                                    Crapedp.CdCooper = Crapadp.CdCooper AND
                                    Crapedp.DtAnoAge = Crapadp.DtAnoAge AND
                                    Crapedp.CdEvento = Crapadp.CdEvento NO-LOCK NO-ERROR.
           FOR EACH crapidp WHERE crapidp.idevento = Crapadp.idevento  AND
                                  crapidp.cdcooper = Crapadp.CdCooper  AND 
                                  crapidp.dtanoage = Crapadp.DtAnoAge  AND 
                                  crapidp.cdagenci = Crapadp.cdagenci  AND 
                                  crapidp.cdevento = crapadp.cdevento  AND 
                                  crapidp.nrdconta = Crapass.nrdconta  AND  
                                  crapidp.cdageins = Crapadp.cdagenci  NO-LOCK: 
               IF crapidp.IdStaIns > 0 AND crapidp.IdStaIns < 6 THEN DO:
                   ASSIGN iValores[Crapidp.IdStaIns] = iValores[Crapidp.IdStaIns] + 1.
               END.
               /* *** Se incricao cofirmada e inscricoes encerradas e evento NAO CANCELADO, verifica faltas ****/
               IF Crapidp.IdStaIns = 2  AND Crapidp.QtFalEve > 0 AND Crapadp.idstaeve <> 2 /*Cancelado*/ THEN DO:
                  IF ((crapidp.qtfaleve * 100) / crapadp.QtDiaEve) > (100 - crapedp.prfreque) THEN DO:
                     ASSIGN iValores[6] = iValores[6] + 1.
                  END.
               END.    
           END.
       END.
   END.
END.

PROCEDURE telaViaInternet:
    /** atribui valores as variaveis do display **/
    ASSIGN iInsCoop = iVlrCoop[1] + iVlrCoop[2] + iVlrCoop[3]
           iCmpCoop = iVlrCoop[2] - iVlrCoop[6]
           iInsComu = iVlrComu[1] + iVlrComu[2] + iVlrComu[3]
           iCmpComu = iVlrComu[2] - iVlrComu[6]
           iInscricao = iValores[1] + iValores[2] + iValores[3]
           iCompareceram = iValores[2] - iValores[6]. 

    /** Imprime Estatística **/
    IF  iEvento = 1 THEN DO:
        {&out} '      <tr>' SKIP
               '         <td class="tdCab2" colspan="4">PROGRID</td>' SKIP
               '      </tr>' SKIP.

        {&out} '      <tr class="tdCab3">' SKIP
               '         <td width="35%">&nbsp;</td>' SKIP
               '         <td align="center">Cooperados</td>' SKIP
               '         <td align="center">Comunidade</td>' SKIP
               '         <td align="center">Total</td>' SKIP
               '      </tr>' SKIP.

        {&out} '      <tr bgcolor="' corEmUso '">' SKIP
               '         <td width="35%" align="right">Inscrições:</td>' SKIP
               '         <td align="center">' iInsCoop FORMAT ">>>,>>9" '</td>' SKIP
               '         <td align="center">' iInsComu FORMAT ">>>,>>9" '</td>' SKIP
               '         <td align="center">' iInscricao FORMAT ">>>,>>9" '</td>' SKIP
               '      </tr>' SKIP.

        IF corEmUso = "#FFFFFF" THEN
           ASSIGN corEmUso = "#F5F5F5".
        ELSE
           ASSIGN corEmUso = "#FFFFFF".

        {&out} '      <tr bgcolor="' corEmUso '">' SKIP
               '         <td width="35%" align="right">Compareceram:</td>' SKIP
               '         <td align="center">' iCmpCoop FORMAT ">>>,>>9" '</td>' SKIP
               '         <td align="center">' iCmpComu FORMAT ">>>,>>9" '</td>' SKIP
               '         <td align="center">' iCompareceram FORMAT ">>>,>>9" '</td>' SKIP
               '      </tr>' SKIP.

        {&out} '      <tr bgcolor="' corEmUso '">' SKIP
               '         <td>&nbsp;</td>' SKIP
               '      </tr>' SKIP.

       /** Totaliza **/
       ASSIGN iTotInsCoop      = iTotInsCoop      + iInsCoop     
              iTotCmpCoop      = iTotCmpCoop      + iCmpCoop     
              iTotInsComu      = iTotInsComu      + iInsComu     
              iTotCmpComu      = iTotCmpComu      + iCmpComu     
              iTotInscricao    = iTotInscricao    + iInscricao   
              iTotCompareceram = iTotCompareceram + iCompareceram.
    END.
    ELSE DO:
        {&out} '      <tr>' SKIP
               '         <td class="tdCab2" colspan="4">Pré-assembléias e Assembléias</td>' SKIP
               '      </tr>' SKIP.

        {&out} '      <tr class="tdCab3">' SKIP
               '         <td width="35%">&nbsp;</td>' SKIP
               '         <td align="center">Cooperados</td>' SKIP
               '         <td align="center">Comunidade</td>' SKIP
               '         <td align="center">Total</td>' SKIP
               '      </tr>' SKIP.

        {&out} '      <tr bgcolor="' corEmUso '">' SKIP
               '         <td width="35%" align="right">Inscrições:</td>' SKIP
               '         <td align="center">' iInsCoop FORMAT ">>>,>>9" '</td>' SKIP
               '         <td align="center">' iInsComu FORMAT ">>>,>>9" '</td>' SKIP
               '         <td align="center">' iInscricao FORMAT ">>>,>>9" '</td>' SKIP
               '      </tr>' SKIP.

        IF corEmUso = "#FFFFFF" THEN
           ASSIGN corEmUso = "#F5F5F5".
        ELSE
           ASSIGN corEmUso = "#FFFFFF".

        {&out} '      <tr bgcolor="' corEmUso '">' SKIP
               '         <td width="35%" align="right">Compareceram:</td>' SKIP
               '         <td align="center">' iCmpCoop FORMAT ">>>,>>9" '</td>' SKIP
               '         <td align="center">' iCmpComu FORMAT ">>>,>>9" '</td>' SKIP
               '         <td align="center">' iCompareceram FORMAT ">>>,>>9" '</td>' SKIP
               '      </tr>' SKIP.
       {&out} '      <tr bgcolor="' corEmUso '">' SKIP
              '         <td>&nbsp;</td>' SKIP
              '      </tr>' SKIP.
       /** Totaliza **/
       ASSIGN iTotInsCoop      = iTotInsCoop      + iInsCoop     
              iTotCmpCoop      = iTotCmpCoop      + iCmpCoop     
              iTotInsComu      = iTotInsComu      + iInsComu     
              iTotCmpComu      = iTotCmpComu      + iCmpComu     
              iTotInscricao    = iTotInscricao    + iInscricao   
              iTotCompareceram = iTotCompareceram + iCompareceram.
       /** Imprime totais */
       {&out} '      <tr>' SKIP
              '         <td class="tdCab2" colspan="4">TOTAIS</td>' SKIP
              '      </tr>' SKIP.

       {&out} '      <tr class="tdCab3">' SKIP
              '         <td width="35%">&nbsp;</td>' SKIP
              '         <td align="center">Cooperados</td>' SKIP
              '         <td align="center">Comunidade</td>' SKIP
              '         <td align="center">Total</td>' SKIP
              '      </tr>' SKIP.

       {&out} '      <tr bgcolor="' corEmUso '">' SKIP
              '         <td width="35%" align="right">Inscrições:</td>' SKIP
              '         <td align="center">' iTotInsCoop FORMAT ">>>,>>9" '</td>' SKIP
              '         <td align="center">' iTotInsComu FORMAT ">>>,>>9" '</td>' SKIP
              '         <td align="center">' iTotInscricao FORMAT ">>>,>>9" '</td>' SKIP
              '      </tr>' SKIP.

       IF corEmUso = "#FFFFFF" THEN
          ASSIGN corEmUso = "#F5F5F5".
       ELSE
          ASSIGN corEmUso = "#FFFFFF".

       {&out} '      <tr bgcolor="' corEmUso '">' SKIP
              '         <td width="35%" align="right">Compareceram:</td>' SKIP
              '         <td align="center">' iTotCmpCoop FORMAT ">>>,>>9" '</td>' SKIP
              '         <td align="center">' iTotCmpComu FORMAT ">>>,>>9" '</td>' SKIP
              '         <td align="center">' iTotCompareceram FORMAT ">>>,>>9" '</td>' SKIP
              '      </tr>' SKIP.
    END.
END.


PROCEDURE telaEixoTematico:
    ASSIGN corEmUso = "#F5F5F5".
    /** Imprime Estatística **/
    {&out} '      <tr class="tdCab3">' SKIP
           '         <td width="35%" align="center">Eixo</td>' SKIP
           '         <td align="center">Cooperados</td>' SKIP
           '         <td align="center">Comunidade</td>' SKIP
           '         <td align="center">Total</td>' SKIP
           '      </tr>' SKIP.
    FOR EACH ttcrapedp:
        FIND FIRST gnapetp WHERE gnapetp.idevento = 1
                       AND gnapetp.cdcooper = 0
                       AND gnapetp.cdeixtem = ttcrapedp.cdeixtem
                   NO-LOCK NO-ERROR.
        IF corEmUso = "#FFFFFF" THEN
           ASSIGN corEmUso = "#F5F5F5".
        ELSE
           ASSIGN corEmUso = "#FFFFFF".
        ASSIGN iInsCoop   = ttcrapedp.vlrCoop[1] + ttcrapedp.vlrCoop[2] + ttcrapedp.vlrCoop[3]  
               iInsComu   = ttcrapedp.vlrComu[1] + ttcrapedp.vlrComu[2] + ttcrapedp.vlrComu[3]  
               iInscricao = ttcrapedp.valores[1] + ttcrapedp.valores[2] + ttcrapedp.valores[3].
        {&out} '      <tr bgcolor="' corEmUso '">' SKIP
               '         <td width="35%" align="left">' (IF AVAIL gnapetp THEN gnapetp.dseixtem ELSE 'Eixo temático sem descrição') '</td>' SKIP
               '         <td align="center">' iInsCoop   FORMAT ">>>,>>9" '</td>' SKIP
               '         <td align="center">' iInsComu   FORMAT ">>>,>>9" '</td>' SKIP
               '         <td align="center">' iInscricao FORMAT ">>>,>>9" '</td>' SKIP
               '      </tr>' SKIP.
        ASSIGN iTotInsCoop   = iTotInsCoop   + iInsCoop  
               iTotInsComu   = iTotInsComu   + iInsComu  
               iTotInscricao = iTotInscricao + iInscricao.
    END.
    {&out} '      <tr bgcolor="' corEmUso '"><td>&nbsp;</td></tr>' SKIP
           '      <tr class="tdCab3">' SKIP
           '         <td width="35%" align="right">Total Geral:</td>' SKIP
           '         <td align="center">' iTotInsCoop   FORMAT ">>>,>>9" '</td>' SKIP
           '         <td align="center">' iTotInsComu   FORMAT ">>>,>>9" '</td>' SKIP
           '         <td align="center">' iTotInscricao FORMAT ">>>,>>9" '</td>' SKIP
           '      </tr>' SKIP.
END.


PROCEDURE telaCoopSemInt:
    DEF VAR iTotalAgencia AS INT NO-UNDO.
    DEF VAR iTotalGeral   AS INT NO-UNDO.

    /** Imprime Estatística **/
    FOR EACH ttcrapass BREAK BY ttcrapass.cdagenci BY ttcrapass.dtadmiss:
        IF FIRST-OF(ttcrapass.cdagenci) THEN DO:
            FIND Crapage WHERE Crapage.CdCooper = CdCooper AND Crapage.CdAgenci = ttcrapass.CdAgenci NO-LOCK NO-ERROR.
            {&out} '      <tr>' SKIP
                   '         <td class="tdCab2" colspan="5">PA: ' ttcrapass.cdagenci ' - ' crapage.nmResAge '</td>' SKIP
                   '      </tr>' SKIP.
            {&out} '      <tr class="tdCab3">' SKIP
                   '         <td align="center">Admissão</td>' SKIP
                   '         <td align="center">C/C</td>' SKIP
                   '         <td width="35%" align="center">Cooperado</td>' SKIP
                   '         <td align="center">Titularidade</td>' SKIP
                                   '         <td align="center">Contatos</td>' 
                   '      </tr>' SKIP.
            ASSIGN corEmUso = "#F5F5F5".
        END.
        IF corEmUso = "#FFFFFF" THEN
           ASSIGN corEmUso = "#F5F5F5".
        ELSE
           ASSIGN corEmUso = "#FFFFFF".
        {&out} '      <tr bgcolor="' corEmUso '">' SKIP
               '         <td align="center">' ttcrapass.dtadmiss '</td>' SKIP
               '         <td align="center">' string(string(ttcrapass.nrdconta,">>>>>>>9"),"xxxxxxx-x") '</td>' SKIP
               '         <td align="center">' ttcrapass.nmextttl '</td>' SKIP
               '         <td align="center">' ttcrapass.idseqttl '</td>' SKIP.
        
                
                ASSIGN aux_telefone = " ".
                
                FIND  FIRST craptfc NO-LOCK WHERE
                    craptfc.cdcooper = CdCooper            AND
                    craptfc.nrdconta = ttCrapass.nrdconta  AND
                    craptfc.idseqttl = 1                   AND
                    craptfc.tptelefo = 2  NO-ERROR.   /* Celular */ 
                                        
        IF   AVAIL craptfc  THEN
                     ASSIGN aux_telefone = "(" + STRING(craptfc.nrdddtfc) + ") " +  STRING(craptfc.nrtelefo).   
                   
                FIND  FIRST craptfc NO-LOCK WHERE
                    craptfc.cdcooper = CdCooper            AND
                    craptfc.nrdconta = ttCrapass.nrdconta  AND
                    craptfc.idseqttl = 1                   AND
                    craptfc.tptelefo = 1  NO-ERROR.   /* Residencial */  
                                        
            IF   AVAIL craptfc  THEN
                     ASSIGN aux_telefone = IF   aux_telefone = "" THEN
                                                    "(" + STRING(craptfc.nrdddtfc) + ") " +  STRING(craptfc.nrtelefo)  + " residencial"
                                                                   ELSE
                                                                        aux_telefone + "  /  " + "(" + STRING(craptfc.nrdddtfc) + ") " +  STRING(craptfc.nrtelefo)  + " residencial".
                ELSE
                     DO:
                             FIND  FIRST craptfc NO-LOCK WHERE
                             craptfc.cdcooper = CdCooper            AND
                             craptfc.nrdconta = ttCrapass.nrdconta  AND
                             craptfc.idseqttl = 1                   AND
                             craptfc.tptelefo = 3  NO-ERROR.   /* Comercial */  
                                        
                             IF   AVAIL craptfc  THEN
                              ASSIGN aux_telefone = IF   aux_telefone = "" THEN
                                                             "(" + STRING(craptfc.nrdddtfc) + ") " +  STRING(craptfc.nrtelefo)  + " comercial"
                                                                    ELSE
                                                                                 aux_telefone + " / " + "(" + STRING(craptfc.nrdddtfc) + ") " +  STRING(craptfc.nrtelefo)  + " comercial".
                                                                                                
                     END.        
                         
                {&out} '         <td align="center">' aux_telefone '</td>' .        
                {&out} '      </tr>' SKIP.             
                           
        ASSIGN iTotalAgencia = iTotalAgencia + 1  
               iTotalGeral   = iTotalGeral   + 1.
        IF LAST-OF(ttcrapass.cdagenci) THEN DO:
            FIND Crapage WHERE Crapage.CdCooper = CdCooper AND Crapage.CdAgenci = ttcrapass.CdAgenci NO-LOCK NO-ERROR.
            {&out} '      <tr><td colspan="5" align="center"> &nbsp; </td></tr>' SKIP 
                   '      <tr><td colspan="5" align="center" height="1%" bgColor="black"></td></tr>' SKIP.
            {&out} '      <tr class="tdCab3">' SKIP
                   '         <td colspan="5" align="left">Total do PA ' ttcrapass.cdagenci ' - ' crapage.nmResAge ': ' string(iTotalAgencia,">,>>>,>>9") '</td>' SKIP
                   '      </tr>' SKIP.
            {&out} '      <tr><td colspan="5" align="center"> &nbsp; </td></tr>' SKIP.
            ASSIGN iTotalAgencia = 0.
        END.
    END.
    {&out} '      <tr bgcolor="' corEmUso '"><td colspan="5">&nbsp;</td></tr>' SKIP
           '      <tr class="tdCab3">' SKIP
           '         <td colspan="5" align="left">Total Geral: ' string(iTotalGeral,">>>,>>>,>>9") '</td>' SKIP
           '      </tr>' SKIP.
END.


PROCEDURE telaQuestEntDev:
    DEF INPUT PARAM tipoRelat AS INT NO-UNDO.

    DEF VAR iTotalAgencia  AS INT NO-UNDO.
    DEF VAR iTotalGeral    AS INT NO-UNDO.
    DEF VAR iTotalAgenEnt  AS INT NO-UNDO.
    DEF VAR iTotalGeralEnt AS INT NO-UNDO.
    DEF VAR iTotalAgenDev  AS INT NO-UNDO.
    DEF VAR iTotalGeralDev AS INT NO-UNDO.

    /** Imprime Estatística **/
    FOR EACH ttcrapass BREAK BY ttcrapass.cdagenci BY ttcrapass.dtadmiss:

        IF FIRST-OF(ttcrapass.cdagenci) THEN DO:
            FIND Crapage WHERE Crapage.CdCooper = CdCooper AND Crapage.CdAgenci = ttcrapass.CdAgenci NO-LOCK NO-ERROR.
            {&out} '      <tr>' SKIP
                   '         <td class="tdCab2" colspan="7">PA: ' ttcrapass.cdagenci ' - ' crapage.nmResAge '</td>' SKIP
                   '      </tr>' SKIP.
            {&out} '      <tr class="tdCab3">' SKIP
                   '         <td align="center">Admissão</td>' SKIP
                   '         <td align="center">C/C</td>' SKIP
                   '         <td width="35%" align="center">Cooperado</td>' SKIP
                   '         <td align="center">Entregue</td>' SKIP.
            IF tipoRelat = 1 THEN
               {&out} '         <td align="center">Devolvido</td>' SKIP
                      '         <td align="center">Digitacao</td>' SKIP. /* 23/11/2010 */
            ELSE 
               {&out} '         <td align="center">&nbsp;</td>' SKIP
                      '         <td align="center">&nbsp;</td>' SKIP.

                           {&out} '         <td align="center">Contatos</td>' SKIP.
                           
            {&out} '      </tr>' SKIP.
            ASSIGN corEmUso = "#F5F5F5".
        END.
        IF corEmUso = "#FFFFFF" THEN
           ASSIGN corEmUso = "#F5F5F5".
        ELSE
           ASSIGN corEmUso = "#FFFFFF".
        {&out} '      <tr bgcolor="' corEmUso '">' SKIP
               '         <td align="center">' ttcrapass.dtadmiss '</td>' SKIP
               '         <td align="center">' string(string(ttcrapass.nrdconta,">>>>>>>9"),"xxxxxxx-x") '</td>' SKIP
               '         <td align="center">' ttcrapass.nmextttl '</td>' SKIP.
        IF ttcrapass.dtentqst = ? THEN
           {&out} '         <td align="center">&nbsp;</td>' SKIP.
        ELSE
           {&out} '         <td align="center">' string(ttcrapass.dtentqst,"99/99/9999") '</td>' SKIP.
        IF tipoRelat = 1 THEN DO:
           IF ttcrapass.dtdevqst = ? THEN 
              {&out} '         <td align="center">&nbsp;</td>' SKIP.
           ELSE
              {&out} '         <td align="center">' STRING(ttcrapass.dtdevqst,"99/99/9999") '</td>' SKIP.

           /* 23/11/2010 */
           IF ttcrapass.dtcadqst = ? THEN
              {&out} '         <td align="center">&nbsp;</td>' SKIP.
           ELSE
              {&out} '         <td align="center">' string(ttcrapass.dtcadqst,"99/99/9999") '</td>' SKIP.
        END.
        ELSE
           {&out} '         <td align="center">&nbsp;</td>' SKIP
                  '         <td align="center">&nbsp;</td>' SKIP.

                ASSIGN aux_telefone = " ".
                
                FIND  FIRST craptfc NO-LOCK WHERE
                    craptfc.cdcooper = CdCooper            AND
                    craptfc.nrdconta = ttcrapass.nrdconta  AND
                    craptfc.idseqttl = 1                   AND
                    craptfc.tptelefo = 2  NO-ERROR.   /* Celular */ 
                                        
        IF   AVAIL craptfc  THEN
                     ASSIGN aux_telefone = "(" + STRING(craptfc.nrdddtfc) + ") " +  STRING(craptfc.nrtelefo).   
                   
                FIND  FIRST craptfc NO-LOCK WHERE
                    craptfc.cdcooper = CdCooper            AND
                    craptfc.nrdconta = ttcrapass.nrdconta  AND
                    craptfc.idseqttl = 1                   AND
                    craptfc.tptelefo = 1  NO-ERROR.   /* Residencial */  
                                        
            IF   AVAIL craptfc  THEN
                     ASSIGN aux_telefone = IF   aux_telefone = "" THEN
                                                    "(" + STRING(craptfc.nrdddtfc) + ") " +  STRING(craptfc.nrtelefo)  + " residencial"
                                                                   ELSE
                                                                        aux_telefone + "  /  " + "(" + STRING(craptfc.nrdddtfc) + ") " +  STRING(craptfc.nrtelefo)  + " residencial".
                ELSE
                     DO:
                             FIND  FIRST craptfc NO-LOCK WHERE
                             craptfc.cdcooper = CdCooper            AND
                             craptfc.nrdconta = ttcrapass.nrdconta  AND
                             craptfc.idseqttl = 1                   AND
                             craptfc.tptelefo = 3  NO-ERROR.   /* Comercial */  
                                        
                             IF   AVAIL craptfc  THEN
                              ASSIGN aux_telefone = IF   aux_telefone = "" THEN
                                                             "(" + STRING(craptfc.nrdddtfc) + ") " +  STRING(craptfc.nrtelefo)  + " comercial"
                                                                    ELSE
                                                                                 aux_telefone + " / " + "(" + STRING(craptfc.nrdddtfc) + ") " +  STRING(craptfc.nrtelefo)  + " comercial".
                                                                                                
                     END.
                         
                {&out} '         <td align="center">' aux_telefone '</td>' SKIP.         
                   
        {&out} '      </tr>' SKIP.
        ASSIGN iTotalAgencia  = iTotalAgencia  + 1  
               iTotalGeral    = iTotalGeral    + 1
               iTotalAgenEnt  = iTotalAgenEnt  + (IF ttcrapass.dtentqst = ? THEN 0 ELSE 1)
               iTotalGeralEnt = iTotalGeralEnt + (IF ttcrapass.dtentqst = ? THEN 0 ELSE 1)
               iTotalAgenDev  = iTotalAgenDev  + (IF ttcrapass.dtdevqst = ? THEN 0 ELSE 1)
               iTotalGeralDev = iTotalGeralDev + (IF ttcrapass.dtdevqst = ? THEN 0 ELSE 1).
        IF LAST-OF(ttcrapass.cdagenci) THEN DO:
            FIND Crapage WHERE Crapage.CdCooper = CdCooper AND Crapage.CdAgenci = ttcrapass.CdAgenci NO-LOCK NO-ERROR.
            {&out} '      <tr><td colspan="7" align="center"> &nbsp; </td></tr>' SKIP 
                   '      <tr><td colspan="7" align="center" height="1%" bgColor="black"></td></tr>' SKIP.
            {&out} '      <tr class="tdCab3">' SKIP
                   '         <td colspan="7" align="left">Total do PA ' ttcrapass.cdagenci ' - ' crapage.nmResAge ':<br>Novos Sócios:' string(iTotalAgencia,">,>>>,>>>9") '<br>Questionários Entregues: ' string(iTotalAgenEnt,">,>>>,>>>9").
            IF tipoRelat = 1 THEN
               {&out} '&nbsp;-&nbsp;Questonários Devolvidos: ' string(iTotalAgenDev,">,>>>,>>9").
            {&out} '</td>' SKIP
                   '      </tr>' SKIP.
            {&out} '      <tr><td colspan="7" align="center"> &nbsp; </td></tr>' SKIP.
            ASSIGN iTotalAgencia = 0
                               iTotalAgenEnt = 0
                                   iTotalAgenDev = 0.
        END.
    END.
    {&out} '      <tr bgcolor="' corEmUso '"><td colspan="7">&nbsp;</td></tr>' SKIP
           '      <tr class="tdCab3">' SKIP
           '         <td colspan="7" align="left">Total Geral Novos Sócios: ' string(iTotalGeral,">>>,>>>,>>9") '<br>Questionários Entregues: ' string(iTotalGeralEnt,">,>>>,>>>9").
    IF tipoRelat = 1 THEN 
       {&out} '&nbsp;-&nbsp;Questonários Devolvidos: ' string(iTotalGeralDev,">,>>>,>>>9").
    {&out} '</td>' SKIP
           '      </tr>' SKIP.
END.
