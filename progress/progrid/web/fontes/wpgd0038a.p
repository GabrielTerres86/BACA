/*****************************************************************************
 Programa wpgd0038a.p - Listagem de fechamento (chamado a partir dos dados de wpgd0038)

 Alterações: 23/02/2007 - cfe tarefa 10307
 
             17/12/2007 - Modificado For Each da tabela crapidp para melhorar
                                    performance (Diego).   
                                                                 
             03/11/2008 - Inclusao widget-pool (martin)

             10/12/2008 - Melhoria de performance para a tabela gnapses (Evandro).
             
             16/03/2009 - Inclusão de linhas correspondente a participacao da comunidade ou cooperados (Martin).
             
             22/01/2010 - Incluido campos "Eventos previstos, "Eventos cancelados" e 
                          "Eventos cancelados";
                        - Incluido na soma dos questionarios devolvidos os questionarios 
                          referente aos pacs que estao agrupados. (Elton).
                          
             03/09/2010 - Lista no "Total PAC" e no "TOTAL GERAL" as informaces detalahadas 
                          referente aos eventos cancelados e realizados (Elton).
                          
             30/06/2011 - Quando o evento for do tipo Assembléia quebrar a quantidade de 
                          inscrição por PAC (Isara - RKAM).  

                         05/06/2012 - Adaptação dos fontes para projeto Oracle. Alterado
                                                  busca na gnapses de CONTAINS para MATCHES (Guilherme Maba).

             28/11/2012 - Substituir tabela "gncoper" por "crapcop"
                          (David Kruger).
                          
             04/04/2013 - Alteração para receber logo na alto vale,
                          recebendo nome de viacrediav e buscando com
                          o respectivo nome (David Kruger).          
                          
             09/09/2013 - Ajustes na impressao do relatorio - Softdesk 
                          tarefa 80943 (Lucas R.).
                          
             05/10/2015 - Incluida verificacao de qtmaxtur na crapeap antes
                          da atribuicao da crapedp Projeto 229 (Jean Michel).
                          
             29/02/2016 - Incluido novo filtro "Tipo de Eventos" na tela.
                          Projeto 229 - Melhorias OQS (Lombardi)
              
             01/03/2016 - Alterado para a coluna "VO" apresentar sempre 1 quando 
                          o tipo de evento for EAD. Projeto 229 - Melhorias OQS (Lombardi)

             09/05/2016 - Correcao do erro no carregamento de relatorios sem filtro de PA
                          isso ocorria devido a nao utilizacao do comando NO-ERROR no FIND 
                          sobre a crabedp. (Carlos Rafael Tanholi).

             11/05/2016 - Corrigi o carregamento do campo VO(vagas ofertadas no evento)
                          que nao estava sendo carregado quando o filtro Todos era usado
                          (Carlos Rafael Tanholi).

             06/06/2016 - Ajustado somatorio total ocorrido na quebra por PA.
                          PRJ229 - Melhorias OQS (Odirlei-AMcom)
                          
             31/01/2017 - Ajustes no totalizadores de eventos, máscaras de valores e datas,
                          Prj. 229-5 (Jean Michel).
                          
**************************************************************************** */

CREATE WIDGET-POOL.

DEFINE TEMP-TABLE ttCrapadp NO-UNDO LIKE Crapadp
    FIELD NomeDoEvento         AS CHARACTER
    FIELD NomeDoPac            AS CHARACTER
    FIELD Sequenciador         AS INTEGER
    FIELD Ano                  AS INTEGER
    FIELD Auxiliar1            AS CHARACTER
    FIELD SobreNomeDoEvento1   AS CHARACTER
    FIELD SobreNomeDoEvento2   AS CHARACTER
    FIELD Periodo              AS CHARACTER  
    FIELD StatusDoEvento       AS CHARACTER
    FIELD MaximoPorTurma       AS INTEGER
    FIELD MinimoPorTurma       AS INTEGER
    FIELD Inscritos            AS INTEGER EXTENT 8
    FIELD InscCoop             AS INTEGER EXTENT 8
    FIELD InscComu             AS INTEGER EXTENT 8
    FIELD TpEvento             AS INTEGER
    FIELD TipoDoEvento         AS CHARACTER.

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
DEFINE VARIABLE tpEvento                     AS INTEGER.
DEFINE VARIABLE consideraEventosForaDaAgenda AS LOGICAL.
DEFINE VARIABLE nomeDoRelatorio              AS CHARACTER.

DEFINE VARIABLE imagemDoProgrid              AS CHARACTER.
DEFINE VARIABLE imagemDaCooperativa          AS CHARACTER.
DEFINE VARIABLE nomeDaCooperativa            AS CHARACTER.

DEFINE VARIABLE auxiliar                     AS CHARACTER.
DEFINE VARIABLE facilitador                  AS CHARACTER.
DEFINE VARIABLE facilitadores                AS CHARACTER.
DEFINE VARIABLE nomeDaAgencia                AS CHARACTER.
DEFINE VARIABLE localDoEvento1               AS CHARACTER.
DEFINE VARIABLE localDoEvento2               AS CHARACTER.

DEFINE VARIABLE ajuste                       AS INTEGER.
DEFINE VARIABLE conta                        AS INTEGER.
DEFINE VARIABLE conta2                       AS INTEGER.
DEFINE VARIABLE corEmUso                     AS CHARACTER.
DEFINE VARIABLE mes                          AS CHARACTER INITIAL ["JANEIRO,FEVEREIRO,MARÇO,ABRIL,MAIO,JUNHO,JULHO,AGOSTO,SETEMBRO,OUTUBRO,NOVEMBRO,DEZEMBRO"].
DEFINE VARIABLE situacao                     AS CHARACTER INITIAL ["Pendente,Confirmado,Desistente,Excedente,Cancelado"].
DEFINE VARIABLE sobreNomeDoEvento            AS CHARACTER.
DEFINE VARIABLE valorDaVerba                 AS DECIMAL.
DEFINE VARIABLE totalVagas                   AS INT.
DEFINE VARIABLE totalVagasCanc               AS INT. 
DEFINE VARIABLE totalVagasReal               AS INT. 
DEFINE VARIABLE geralVagas                   AS INT.
DEFINE VARIABLE geralVagasCanc               AS INT. 
DEFINE VARIABLE geralVagasReal               AS INT. 

DEFINE VARIABLE iQtQstDevolvido              AS INT NO-UNDO.
DEFINE VARIABLE iQtQstDevolTotal             AS INT NO-UNDO.
DEFINE VARIABLE frequenciaMinima             LIKE crapedp.prfreque.
DEFINE VARIABLE aux_existpac                 AS LOGICAL. 
/* Contabiliza as inscrições de Assembléia por Pac */
DEFINE VARIABLE aux_assembl                  AS LOGICAL  NO-UNDO.
/* Quando o primeiro registro do relatório é Assembléia e o seus
   respectivos valores estão zerados, então não mostra este registro */
DEFINE VARIABLE aux_contador                 AS INTEGER   NO-UNDO.
DEFINE VARIABLE aux_controle AS LOGICAL INIT FALSE        NO-UNDO.
DEFINE VARIABLE aux_nmrescop                 AS CHARACTER NO-UNDO.

DEFINE VARIABLE aux_qtmaxtur AS INTEGER.

DEFINE BUFFER bfCraptab  FOR Craptab.
DEFINE BUFFER bfCrapadp  FOR Crapadp.
DEFINE BUFFER bttcrapadp FOR ttcrapadp.
DEFINE BUFFER crabedp FOR crapedp.                 

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

FUNCTION fn-qstDevolvidos RETURNS INTEGER(pAgencia AS INT,dtaInicial AS DATE, dtaFinal AS DATE):
    DEF VAR devolvidos AS INTEGER NO-UNDO.
       
    FOR EACH crapagp NO-LOCK WHERE  crapagp.idevento = idEvento AND
                                    crapagp.cdcooper = cdCooper AND
                                    crapagp.dtanoage = dtAnoAge AND
                                    crapagp.cdageagr = pAgencia:
                   
        FOR EACH crapkbq WHERE crapkbq.idevento = /* idEvento */ crapagp.idevento
                           AND crapkbq.cdcooper = /* cdCooper */ crapagp.cdcooper
                           AND crapkbq.cdagenci = /* pAgencia */ crapagp.cdagenci 
                           AND crapkbq.tpdeitem = 3
                           AND crapkbq.dtdenvio >= dtaInicial
                           AND crapkbq.dtdenvio <= dtaFinal
                         NO-LOCK:
            ASSIGN devolvidos = devolvidos + crapkbq.qtdenvio.
        END.
    END. 
    RETURN devolvidos.
END.

FUNCTION inscricoesNosEventosPorPac RETURNS LOGICAL ():
    
    DEFINE VARIABLE inscricoesPorPac        AS INTEGER EXTENT 8.
    DEFINE VARIABLE inscCancPorPac          AS INTEGER EXTENT 8. 
    DEFINE VARIABLE inscRealPorPac          AS INTEGER EXTENT 8. 
    DEFINE VARIABLE inscComuPorPac          AS INTEGER EXTENT 8.
    DEFINE VARIABLE inscCoopPorPac          AS INTEGER EXTENT 8.
    DEFINE VARIABLE geralPorPac             AS INTEGER EXTENT 8.
    DEFINE VARIABLE gerComuPorPac           AS INTEGER EXTENT 8.
    DEFINE VARIABLE gerCoopPorPac           AS INTEGER EXTENT 8.
    
    DEFINE VARIABLE geralPorPacCanc         AS INTEGER EXTENT 8. 
    DEFINE VARIABLE geralPorPacReal         AS INTEGER EXTENT 8. 

    DEFINE VARIABLE totalDeEventosDoPac     AS INTEGER.
    DEFINE VARIABLE totalDeEventosDaCoop    AS INTEGER.
    
    DEFINE VARIABLE qtdevenCanceladosPac    AS INTEGER.
    DEFINE VARIABLE totalEventosCancelados  AS INTEGER.
    DEFINE VARIABLE qtdevenRealizadosPac    AS INTEGER.
    DEFINE VARIABLE totalEventosRealizados  AS INTEGER.

    {&out} '   <table border="0" cellspacing="0" cellpadding="0" width="100%">' SKIP.
    {&out} '      <tr>' SKIP
           '         <td class="tdCab1" colspan="11">Eventos por PA</td>' SKIP
           '      </tr>' SKIP.

    ASSIGN corEmUso = "#FFFFFF"
           totalDeEventosDoPac = 0.
       
    FOR EACH ttCrapadp WHERE ttCrapadp.CdAgenci <> 0 NO-LOCK
        BREAK BY ttCrapadp.IdEvento 
              BY ttCrapadp.CdCooper 
              BY ttCrapadp.CdAgenci 
              BY ttcrapadp.nrmeseve
              BY ttCrapadp.Periodo
              BY ttCrapadp.nomedoevento:

        /* Inicializar contador quando mudar agencia */                
        IF FIRST-OF(ttCrapadp.CdAgenci) THEN          
          ASSIGN totalVagas = 0. 
        
        ASSIGN inscricoesPorPac[1] = inscricoesPorPac[1] + ttCrapadp.Inscritos[1]
               inscricoesPorPac[2] = inscricoesPorPac[2] + ttCrapadp.Inscritos[2]
               inscricoesPorPac[3] = inscricoesPorPac[3] + ttCrapadp.Inscritos[3]
               inscricoesPorPac[4] = inscricoesPorPac[4] + ttCrapadp.Inscritos[4]
               inscricoesPorPac[5] = inscricoesPorPac[5] + ttCrapadp.Inscritos[5]
               inscricoesPorPac[6] = inscricoesPorPac[6] + ttCrapadp.Inscritos[6]
               inscricoesPorPac[7] = inscricoesPorPac[7] + ttCrapadp.Inscritos[7]
               inscricoesPorPac[8] = inscricoesPorPac[8] + ttCrapadp.Inscritos[1] + ttCrapadp.Inscritos[2] + ttCrapadp.Inscritos[3] 
               
               inscComuPorPac[1] = inscComuPorPac[1] + ttCrapadp.InscComu[1]
               inscComuPorPac[2] = inscComuPorPac[2] + ttCrapadp.InscComu[2]
               inscComuPorPac[3] = inscComuPorPac[3] + ttCrapadp.InscComu[3]
               inscComuPorPac[4] = inscComuPorPac[4] + ttCrapadp.InscComu[4]
               inscComuPorPac[5] = inscComuPorPac[5] + ttCrapadp.InscComu[5]
               inscComuPorPac[6] = inscComuPorPac[6] + ttCrapadp.InscComu[6]
               inscComuPorPac[7] = inscComuPorPac[7] + ttCrapadp.InscComu[7]
               inscComuPorPac[8] = inscComuPorPac[8] + ttCrapadp.InscComu[1] + ttCrapadp.InscComu[2] + ttCrapadp.InscComu[3] 

               inscCoopPorPac[1] = inscCoopPorPac[1] + ttCrapadp.InscCoop[1]
               inscCoopPorPac[2] = inscCoopPorPac[2] + ttCrapadp.InscCoop[2]
               inscCoopPorPac[3] = inscCoopPorPac[3] + ttCrapadp.InscCoop[3]
               inscCoopPorPac[4] = inscCoopPorPac[4] + ttCrapadp.InscCoop[4]
               inscCoopPorPac[5] = inscCoopPorPac[5] + ttCrapadp.InscCoop[5]
               inscCoopPorPac[6] = inscCoopPorPac[6] + ttCrapadp.InscCoop[6]
               inscCoopPorPac[7] = inscCoopPorPac[7] + ttCrapadp.InscCoop[7]
               inscCoopPorPac[8] = inscCoopPorPac[8] + ttCrapadp.InscCoop[1] + ttCrapadp.InscCoop[2] + ttCrapadp.InscCoop[3]

               geralPorPac[1] = geralPorPac[1] + ttCrapadp.Inscritos[1]
               geralPorPac[2] = geralPorPac[2] + ttCrapadp.Inscritos[2]
               geralPorPac[3] = geralPorPac[3] + ttCrapadp.Inscritos[3]
               geralPorPac[6] = geralPorPac[6] + ttCrapadp.Inscritos[6]
               geralPorPac[7] = geralPorPac[7] + ttCrapadp.Inscritos[7]
               geralPorPac[8] = geralPorPac[8] + ttCrapadp.Inscritos[1] + ttCrapadp.Inscritos[2] + ttCrapadp.Inscritos[3] 
               
               gerComuPorPac[1] = gerComuPorPac[1] + ttCrapadp.InscComu[1]
               gerComuPorPac[2] = gerComuPorPac[2] + ttCrapadp.InscComu[2]
               gerComuPorPac[3] = gerComuPorPac[3] + ttCrapadp.InscComu[3]
               gerComuPorPac[6] = gerComuPorPac[6] + ttCrapadp.InscComu[6]
               gerComuPorPac[7] = gerComuPorPac[7] + ttCrapadp.InscComu[7]
               gerComuPorPac[8] = gerComuPorPac[8] + ttCrapadp.InscComu[1] + ttCrapadp.InscComu[2] + ttCrapadp.InscComu[3] 
                   
               gerCoopPorPac[1] = gerCoopPorPac[1] + ttCrapadp.InscCoop[1]
               gerCoopPorPac[2] = gerCoopPorPac[2] + ttCrapadp.InscCoop[2]
               gerCoopPorPac[3] = gerCoopPorPac[3] + ttCrapadp.InscCoop[3]
               gerCoopPorPac[6] = gerCoopPorPac[6] + ttCrapadp.InscCoop[6]
               gerCoopPorPac[7] = gerCoopPorPac[7] + ttCrapadp.InscCoop[7]
               gerCoopPorPac[8] = gerCoopPorPac[8] + ttCrapadp.InscCoop[1] + ttCrapadp.InscCoop[2] + ttCrapadp.InscCoop[3]
                
               totalVagas           = totalVagas + ttCrapadp.MaximoPorTurma
               geralVagas           = geralVagas + ttCrapadp.MaximoPorTurma.
        
               If ttcrapadp.idstaeve <> 2 Then
                 ASSIGN totalDeEventosDoPac  = totalDeEventosDoPac + 1
                 totalDeEventosDaCoop = totalDeEventosDaCoop + 1.
        
        IF  ttcrapadp.idstaeve = 2 THEN  /**Cancelados**/
            DO:
                ASSIGN  inscCancPorPac[1] = inscCancPorPac[1] + ttCrapadp.Inscritos[1]      
                        inscCancPorPac[2] = inscCancPorPac[2] + ttCrapadp.Inscritos[2]
                        inscCancPorPac[3] = inscCancPorPac[3] + ttCrapadp.Inscritos[3]
                        inscCancPorPac[4] = inscCancPorPac[4] + ttCrapadp.Inscritos[4]
                        inscCancPorPac[5] = inscCancPorPac[5] + ttCrapadp.Inscritos[5]
                        inscCancPorPac[6] = inscCancPorPac[6] + ttCrapadp.Inscritos[6]
                        inscCancPorPac[7] = inscCancPorPac[7] + ttCrapadp.Inscritos[7]
                        inscCancPorPac[8] = inscCancPorPac[8] + ttCrapadp.Inscritos[1] + ttCrapadp.Inscritos[2] + ttCrapadp.Inscritos[3]
        
                        geralPorPacCanc[1] = geralPorPacCanc[1] + ttCrapadp.Inscritos[1]
                        geralPorPacCanc[2] = geralPorPacCanc[2] + ttCrapadp.Inscritos[2]
                        geralPorPacCanc[3] = geralPorPacCanc[3] + ttCrapadp.Inscritos[3]
                        geralPorPacCanc[6] = geralPorPacCanc[6] + ttCrapadp.Inscritos[6]
                        geralPorPacCanc[7] = geralPorPacCanc[7] + ttCrapadp.Inscritos[7]
                        geralPorPacCanc[8] = geralPorPacCanc[8] + ttCrapadp.Inscritos[1] + ttCrapadp.Inscritos[2] + ttCrapadp.Inscritos[3]

                        qtdevenCanceladosPac   =  qtdevenCanceladosPac + 1
                        TotalEventosCancelados = totalEventosCancelados + 1
                        totalVagasCanc         = totalVagasCanc + ttCrapadp.MaximoPorTurma
                        geralVagasCanc         = geralVagasCanc + ttCrapadp.MaximoPorTurma.  
            END.     
       ELSE
            DO:
                ASSIGN  inscRealPorPac[1] = inscRealPorPac[1] + ttCrapadp.Inscritos[1]  
                        inscRealPorPac[2] = inscRealPorPac[2] + ttCrapadp.Inscritos[2]
                        inscRealPorPac[3] = inscRealPorPac[3] + ttCrapadp.Inscritos[3]
                        inscRealPorPac[4] = inscRealPorPac[4] + ttCrapadp.Inscritos[4]
                        inscRealPorPac[5] = inscRealPorPac[5] + ttCrapadp.Inscritos[5]
                        inscRealPorPac[6] = inscRealPorPac[6] + ttCrapadp.Inscritos[6]
                        inscRealPorPac[7] = inscRealPorPac[7] + ttCrapadp.Inscritos[7]
                        inscRealPorPac[8] = inscRealPorPac[8] + ttCrapadp.Inscritos[1] + ttCrapadp.Inscritos[2] + ttCrapadp.Inscritos[3]
                        
                        geralPorPacReal[1] = geralPorPacReal[1] + ttCrapadp.Inscritos[1]
                        geralPorPacReal[2] = geralPorPacReal[2] + ttCrapadp.Inscritos[2]
                        geralPorPacReal[3] = geralPorPacReal[3] + ttCrapadp.Inscritos[3]
                        geralPorPacReal[6] = geralPorPacReal[6] + ttCrapadp.Inscritos[6]
                        geralPorPacReal[7] = geralPorPacReal[7] + ttCrapadp.Inscritos[7]
                        geralPorPacReal[8] = geralPorPacReal[8] + ttCrapadp.Inscritos[1] + ttCrapadp.Inscritos[2] + ttCrapadp.Inscritos[3].

                If ttcrapadp.idstaeve = 4 Then
                 assign qtdevenRealizadosPac   = qtdevenRealizadosPac + 1                          
                  TotalEventosRealizados = totalEventosRealizados + 1.
                          
               ASSIGN totalVagasReal         = totalVagasReal + ttCrapadp.MaximoPorTurma
                        geralVagasReal         = geralVagasReal + ttCrapadp.MaximoPorTurma.  
            END.

        ASSIGN aux_contador = aux_contador + 1.

        IF FIRST-OF(ttCrapadp.CdAgenci) THEN 
        DO:
           
           IF NOT(ttCrapadp.CdAgenci = 0  AND
                  aux_contador       = 1) THEN
           DO: 
              IF   ttCrapadp.Cdagenci <> 0   THEN   
                
               {&out} '      <tr>' SKIP 
                      '         <td class="tdCab2" colspan="11">PA: ' ttCrapadp.CdAgenci ' - '  ttCrapadp.NomeDoPac '</td>' SKIP
                      '      </tr>' SKIP.
    
               {&out} '      <tr class="tdCab3">' SKIP
                      '         <td>Descrição do evento</td>' SKIP
                      '         <td align="center" title="Tipo do evento">Tipo</td>' SKIP
                      '         <td align="center" title="Período de realização do evento">Período</td>' SKIP
                      '         <td align="center" title="Situação do evento">Situação</td>' SKIP
                      '         <td align="center" title="Vagas ofertadas no evento">VO</td>' SKIP
                      '         <td align="center" title="Pré-Inscritos">PI</td>' SKIP     
                      '         <td align="center" title="Pendentes de confirmação">PE</td>' SKIP
                      '         <td align="center" title="Desistentes">DE</td>' SKIP   
                      '         <td align="center" title="Confirmadas">CO</td>' SKIP
                      '         <td align="center" title="Faltantes">FA</td>' SKIP
                      '         <td align="center" title="Compareceram">CE</td>' SKIP
                      '      </tr>' SKIP.
           END.
        END.

        IF NOT(ttCrapadp.CdAgenci = 0 AND
               aux_contador = 1) THEN
        DO: 
            {&out} '      <tr bgcolor="' corEmUso '">' SKIP
                   '         <td width="35%">' ttCrapadp.NomeDoEvento '</td>' SKIP
                   '         <td align="center" title="Tipo do evento" width="11%">' substring(ttCrapadp.TipoDoEvento,1,10) '</td>' SKIP
                   '         <td align="center" title="Período de realização do evento" width="11%">' ttCrapadp.Periodo '</td>' SKIP
                   '         <td align="center" title="Situação do evento" width="11%">' ttCrapadp.StatusDoEvento '</td>' SKIP
                   '         <td align="center" title="Vagas ofertadas no evento">' ttCrapadp.MaximoPorTurma '</td>' SKIP
                   '         <td align="center" title="Pré-Inscritos">' ttCrapadp.Inscritos[1] + ttCrapadp.Inscritos[2] + ttCrapadp.Inscritos[3] '</td>' SKIP
                   '         <td align="center" title="Pendentes de confirmação">' ttCrapadp.Inscritos[1] '</td>' SKIP
                   '         <td align="center" title="Desistentes">' ttCrapadp.Inscritos[3] '</td>' SKIP
                   '         <td align="center" title="Confirmadas">' ttCrapadp.Inscritos[2] '</td>' SKIP
                   '         <td align="center" title="Faltantes">' ttCrapadp.Inscritos[6] '</td>' SKIP
                   '         <td align="center" title="Compareceram">' ttCrapadp.Inscritos[7] '</td>' SKIP
                   '      </tr>' SKIP.
            
            /** COOPERADOS **/
            {&out} '      <tr bgcolor="' corEmUso '">' SKIP
                   '         <td>Participação de Cooperados</td>' SKIP
                   '         <td align="center">&nbsp;</td>' SKIP
                   '         <td align="center">&nbsp;</td>' SKIP
                   '         <td align="center">&nbsp;</td>' SKIP
                   '         <td align="center">&nbsp;</td>' SKIP
                   '         <td align="center" title="Pré-Inscritos">' ttCrapadp.InscCoop[1] + ttCrapadp.InscCoop[2] + ttCrapadp.InscCoop[3] '</td>' SKIP
                   '         <td align="center" title="Pendentes de confirmação">' ttCrapadp.InscCoop[1] '</td>' SKIP
                   '         <td align="center" title="Desistentes">' ttCrapadp.InscCoop[3] '</td>' SKIP
                   '         <td align="center" title="Confirmadas">' ttCrapadp.InscCoop[2] '</td>' SKIP
                   '         <td align="center" title="Faltantes">' ttCrapadp.InscCoop[6] '</td>' SKIP
                   '         <td align="center" title="Compareceram">' ttCrapadp.InscCoop[7] '</td>' SKIP
                   '      </tr>' SKIP.
            
            /** COMUNIDADE **/
            {&out} '      <tr bgcolor="' corEmUso '">' SKIP
                   '         <td>Participação da Comunidade</td>' SKIP
                   '         <td align="center">&nbsp;</td>' SKIP
                   '         <td align="center">&nbsp;</td>' SKIP
                   '         <td align="center">&nbsp;</td>' SKIP
                   '         <td align="center">&nbsp;</td>' SKIP
                   '         <td align="center" title="Pré-Inscritos">' ttCrapadp.InscComu[1] + ttCrapadp.InscComu[2] + ttCrapadp.InscComu[3] '</td>' SKIP
                   '         <td align="center" title="Pendentes de confirmação">' ttCrapadp.InscComu[1] '</td>' SKIP
                   '         <td align="center" title="Desistentes">' ttCrapadp.InscComu[3] '</td>' SKIP
                   '         <td align="center" title="Confirmadas">' ttCrapadp.InscComu[2] '</td>' SKIP
                   '         <td align="center" title="Faltantes">' ttCrapadp.InscComu[6] '</td>' SKIP
                   '         <td align="center" title="Compareceram">' ttCrapadp.InscComu[7] '</td>' SKIP
                   '      </tr>' SKIP.

            /** Espaçamento **/
            {&out} '      <tr bgcolor="' corEmUso '">' SKIP
                   '         <td colspan="11">&nbsp;</td>' SKIP
                   '      </tr>' SKIP.
            
            IF corEmUso = "#FFFFFF" THEN
               ASSIGN corEmUso = "#F5F5F5".
            ELSE
               ASSIGN corEmUso = "#FFFFFF".                        

            IF LAST-OF(ttCrapadp.CdAgenci) THEN 
            DO:
               ASSIGN iQtQstDevolvido = fn-qstDevolvidos(ttCrapadp.CdAgenci, datainicial, datafinal).
               
               {&out} '      <tr><td colspan="11" align="center"> &nbsp; </td></tr>' SKIP 
                      '      <tr><td colspan="11" align="center" height="1%" bgColor="black"></td></tr>' SKIP.
               {&out} '      <tr class="tdCab3">' SKIP.
               
               /** Eventos Programados **/
               IF ttCrapadp.Cdagenci <> 0   THEN 
                  {&out} '         <td>Total PA - Eventos programados: ' totalDeEventosDoPac '</td>' SKIP.
               /* Assembléia */
               ELSE
                    {&out} '         <td>Totais</td>' SKIP.
                       
               {&out} '         <td align="center" title="Período de realização do evento">&nbsp;</td>' SKIP
                      '         <td align="center" title="Tipo"> &nbsp; </td>' SKIP
                      '         <td align="center" title="Situação do evento"> &nbsp; </td>' SKIP
                      '         <td align="center" title="Vagas ofertadas no evento">' totalVagas FORMAT "zzzzz9" ' </td>' SKIP
                      '         <td align="center" title="Pré-Inscritos">' inscricoesPorPac[8] FORMAT "zzzzz9" '</td>' SKIP
                      '         <td align="center" title="Pendentes de confirmação">' inscricoesPorPac[1] FORMAT "zzzzz9" '</td>' SKIP
                      '         <td align="center" title="Desistentes">' inscricoesPorPac[3] FORMAT "zzzzz9" '</td>' SKIP   
                      '         <td align="center" title="Confirmadas">' inscricoesPorPac[2] FORMAT "zzzzz9" '</td>' SKIP
                      '         <td align="center" title="Faltantes">' inscricoesPorPac[6] FORMAT "zzzzz9" '</td>' SKIP
                      '         <td align="center" title="Compareceram">' inscricoesPorPac[7] FORMAT "zzzzz9" '</td>' SKIP
                      '      </tr>' SKIP.
               
               /** Eventos Cancelados **/
               {&out} '      <tr class="tdCab3">' SKIP
                      '         <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                                    Eventos cancelados&nbsp;&nbsp;&nbsp;&nbsp;: ' qtdevenCanceladosPac ' </td>' SKIP
                      '         <td align="center">&nbsp;</td>' SKIP
                      '         <td align="center">&nbsp;</td>' SKIP
                      '         <td align="center">&nbsp;</td>' SKIP
                      '         <td align="center" title="Vagas ofertadas no evento">' totalVagasCanc FORMAT "zzzzz9" ' </td>' SKIP 
                      '         <td align="center" title="Pré-Inscritos">' inscCancPorPac[8] FORMAT "zzzzz9" '</td>' SKIP
                      '         <td align="center" title="Pendentes de confirmação">' inscCancPorPac[1] FORMAT "zzzzz9" '</td>' SKIP
                      '         <td align="center" title="Desistentes">' inscCancPorPac[3] FORMAT "zzzzz9" '</td>' SKIP   
                      '         <td align="center" title="Confirmadas">' inscCancPorPac[2] FORMAT "zzzzz9" '</td>' SKIP
                      '         <td align="center" title="Faltantes">' inscCancPorPac[6] FORMAT "zzzzz9" '</td>' SKIP
                      '         <td align="center" title="Compareceram">' inscCancPorPac[7] FORMAT "zzzzz9" '</td>' SKIP.
               
               /** Eventos Realizados **/
               {&out} '      <tr class="tdCab3">' SKIP
                      '         <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                                    Eventos realizados&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;: ' qtdevenRealizadosPac ' </td>' SKIP
                      '         <td align="center">&nbsp;</td>' SKIP
                      '         <td align="center">&nbsp;</td>' SKIP
                      '         <td align="center">&nbsp;</td>' SKIP
                      '         <td align="center" title="Vagas ofertadas no evento">' totalVagasReal FORMAT "zzzzz9" ' </td>' SKIP 
                      '         <td align="center" title="Pré-Inscritos">' inscRealPorPac[8] FORMAT "zzzzz9" '</td>' SKIP
                      '         <td align="center" title="Pendentes de confirmação">' inscRealPorPac[1] FORMAT "zzzzz9" '</td>' SKIP
                      '         <td align="center" title="Desistentes">' inscRealPorPac[3] FORMAT "zzzzz9" '</td>' SKIP   
                      '         <td align="center" title="Confirmadas">' inscRealPorPac[2] FORMAT "zzzzz9" '</td>' SKIP
                      '         <td align="center" title="Faltantes">' inscRealPorPac[6] FORMAT "zzzzz9" '</td>' SKIP
                      '         <td align="center" title="Compareceram">' inscRealPorPac[7] FORMAT "zzzzz9" '</td>' SKIP.
               
               /** COOPERADOS **/
               {&out} '      <tr class="tdCab3">' SKIP
                      '         <td>Totais da Participação de Cooperados</td>' SKIP
                      '         <td align="center">&nbsp;</td>' SKIP
                      '         <td align="center">&nbsp;</td>' SKIP
                      '         <td align="center">&nbsp;</td>' SKIP
                      '         <td align="center">&nbsp;</td>' SKIP
                      '         <td align="center" title="Pré-Inscritos">' inscCoopPorPac[8] FORMAT "zzzzz9" '</td>' SKIP
                      '         <td align="center" title="Pendentes de confirmação">' inscCoopPorPac[1] FORMAT "zzzzz9" '</td>' SKIP
                      '         <td align="center" title="Desistentes">' inscCoopPorPac[3] FORMAT "zzzzz9" '</td>' SKIP   
                      '         <td align="center" title="Confirmadas">' inscCoopPorPac[2] FORMAT "zzzzz9" '</td>' SKIP
                      '         <td align="center" title="Faltantes">' inscCoopPorPac[6] FORMAT "zzzzz9" '</td>' SKIP
                      '         <td align="center" title="Compareceram">' inscCoopPorPac[7] FORMAT "zzzzz9" '</td>' SKIP
                      '      </tr>' SKIP.
               
               /** COMUNIDADE **/
               {&out} '      <tr class="tdCab3">' SKIP
                      '         <td>Totais da Participação da Comunidade</td>' SKIP
                      '         <td align="center">&nbsp;</td>' SKIP
                      '         <td align="center">&nbsp;</td>' SKIP
                      '         <td align="center">&nbsp;</td>' SKIP
                      '         <td align="center">&nbsp;</td>' SKIP
                      '         <td align="center" title="Pré-Inscritos">' inscComuPorPac[8] FORMAT "zzzzz9" '</td>' SKIP
                      '         <td align="center" title="Pendentes de confirmação">' inscComuPorPac[1] FORMAT "zzzzz9" '</td>' SKIP
                      '         <td align="center" title="Desistentes">' inscComuPorPac[3] FORMAT "zzzzz9" '</td>' SKIP   
                      '         <td align="center" title="Confirmadas">' inscComuPorPac[2] FORMAT "zzzzz9" '</td>' SKIP
                      '         <td align="center" title="Faltantes">' inscComuPorPac[6] FORMAT "zzzzz9" '</td>' SKIP
                      '         <td align="center" title="Compareceram">' inscComuPorPac[7] FORMAT "zzzzz9" '</td>' SKIP
                      '      </tr>' SKIP.
               
               {&out} '      <tr class="tdCab3"><td colspan="11" align="Left">Questionários devolvidos: ' iQtQstDevolvido FORMAT ">>>,>>9" '</td></tr>' SKIP.
               {&out} '      <tr><td colspan="11" align="center"> &nbsp; </td></tr>' SKIP.

                /*** Linha separando os pa's ***/
               {&out} '      <tr class="tdlinha" >' SKIP
                      '         <td colspan="11"> <hr> <br> </td>' SKIP  
                      '      </tr>' SKIP.
              
               ASSIGN /*totalVagas          = 0*/
                      totalVagasCanc      = 0  
                      totalVagasReal      = 0  
                      inscricoesPorPac[1] = 0
                      inscricoesPorPac[2] = 0
                      inscricoesPorPac[3] = 0
                      inscricoesPorPac[6] = 0
                      inscricoesPorPac[7] = 0
                      inscricoesPorPac[8] = 0
                   
                      inscComuPorPac[1] = 0
                      inscComuPorPac[2] = 0
                      inscComuPorPac[3] = 0
                      inscComuPorPac[6] = 0
                      inscComuPorPac[7] = 0
                      inscComuPorPac[8] = 0
                                       
                      inscCoopPorPac[1] = 0
                      inscCoopPorPac[2] = 0
                      inscCoopPorPac[3] = 0
                      inscCoopPorPac[6] = 0
                      inscCoopPorPac[7] = 0
                      inscCoopPorPac[8] = 0
                              
                      inscCancPorPac[1] = 0
                      inscCancPorPac[2] = 0
                      inscCancPorPac[3] = 0
                      inscCancPorPac[6] = 0
                      inscCancPorPac[7] = 0
                      inscCancPorPac[8] = 0
                   
                      inscRealPorPac[1] = 0
                      inscRealPorPac[2] = 0
                      inscRealPorPac[3] = 0
                      inscRealPorPac[6] = 0
                      inscRealPorPac[7] = 0
                      inscRealPorPac[8] = 0.
    
               ASSIGN iQtQstDevolTotal     = iQtQstDevolTotal + iQtQstDevolvido
                      totalDeEventosDoPac  = 0
                      qtdevenCanceladosPac = 0
                      qtdevenRealizadosPac = 0.
            END.
            
        END.

        /* TOTAL GERAL */
        IF LAST-OF(ttCrapadp.Cdcooper) THEN DO: 

           {&out} '      <tr><td colspan="12" align="center"> &nbsp; </td></tr>' SKIP.
           
           {&out} '      <tr class="tdCab3">' SKIP
                  '         <td>TOTAL GERAL </td>' SKIP
                  '         <td align="center">&nbsp;</td>' SKIP
                  '         <td align="center">&nbsp;</td>' SKIP
                  '         <td align="center">&nbsp;</td>' SKIP
                  '         <td align="center">&nbsp;</td>' SKIP
                  '         <td align="center">&nbsp;</td>' SKIP
                  '         <td align="center">&nbsp;</td>' SKIP
                  '         <td align="center">&nbsp;</td>' SKIP
                  '         <td align="center">&nbsp;</td>' SKIP
                  '         <td align="center">&nbsp;</td>' SKIP
                  '         <td align="center">&nbsp;</td>' SKIP
                  '      </tr>' SKIP.

           /*** Eventos Programados ***/
           {&out} '      <tr class="tdCab3">' SKIP
                  '         <td>Eventos programados:  ' totalDeEventosDaCoop '</td>' SKIP
                  '         <td align="center" title="Tipo">&nbsp;</td>' SKIP
                  '         <td align="center" title="Período de realização do evento">&nbsp;</td>' SKIP
                  '         <td align="center" title="Situação do evento"> &nbsp; </td>' SKIP
                  '         <td align="center" title="Vagas ofertadas no evento">' geralVagas FORMAT "zzzzz9" ' </td>' SKIP
                  '         <td align="center" title="Pré-Inscritos">'geralPorPac[8] FORMAT "zzzzz9" '</td>' SKIP
                  '         <td align="center" title="Pendentes de confirmação">'geralPorPac[1] FORMAT "zzzzz9" '</td>' SKIP
                  '         <td align="center" title="Desistentes">' geralPorPac[3] FORMAT "zzzzz9" '</td>' SKIP   
                  '         <td align="center" title="Confirmadas">' geralPorPac[2] FORMAT "zzzzz9" '</td>' SKIP
                  '         <td align="center" title="Faltantes">' geralPorPac[6] FORMAT "zzzzz9" '</td>' SKIP
                  '         <td align="center" title="Compareceram">' geralPorPac[7] FORMAT "zzzzz9" '</td>' SKIP.

           /*** Eventos Cancelados ***/
           {&out} '      <tr class="tdCab3">' SKIP
                  '         <td>Eventos cancelados &nbsp;&nbsp;&nbsp;&nbsp;: ' totalEventosCancelados ' </td>'              SKIP
                  '         <td align="center">&nbsp;</td>' SKIP
                  '         <td align="center">&nbsp;</td>' SKIP
                  '         <td align="center">&nbsp;</td>' SKIP
                  '         <td align="center" title="Vagas ofertadas no evento">' geralVagasCanc FORMAT "zzzzz9" ' </td>' SKIP
                  '         <td align="center" title="Pré-Inscritos">'geralPorPacCanc[8] FORMAT "zzzzz9" '</td>'             SKIP
                  '         <td align="center" title="Pendentes de confirmação">'geralPorPacCanc[1] FORMAT "zzzzz9" '</td>'   SKIP
                  '         <td align="center" title="Desistentes">' geralPorPacCanc[3] FORMAT "zzzzz9" '</td>'               SKIP   
                  '         <td align="center" title="Confirmadas">' geralPorPacCanc[2] FORMAT "zzzzz9" '</td>'              SKIP
                  '         <td align="center" title="Faltantes">' geralPorPacCanc[6] FORMAT "zzzzz9" '</td>'                 SKIP
                  '         <td align="center" title="Compareceram">' geralPorPacCanc[7] FORMAT "zzzzz9" '</td>'             SKIP.

           /*** Eventos Realizados ***/
           {&out} '      <tr class="tdCab3">' SKIP
                  '         <td>Eventos realizados &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;: ' totalEventosRealizados ' </td>' SKIP
                  '         <td align="center">&nbsp;</td>' SKIP
                  '         <td align="center">&nbsp;</td>' SKIP
                  '         <td align="center">&nbsp;</td>' SKIP
                  '         <td align="center" title="Vagas ofertadas no evento">' geralVagasReal FORMAT "zzzzz9" ' </td>' SKIP
                  '         <td align="center" title="Pré-Inscritos">'geralPorPacReal[8] FORMAT "zzzzz9" '</td>'             SKIP
                  '         <td align="center" title="Pendentes de confirmação">'geralPorPacReal[1] FORMAT "zzzzz9" '</td>'   SKIP
                  '         <td align="center" title="Desistentes">' geralPorPacReal[3] FORMAT "zzzzz9" '</td>'               SKIP   
                  '         <td align="center" title="Confirmadas">' geralPorPacReal[2] FORMAT "zzzzz9" '</td>'              SKIP
                  '         <td align="center" title="Faltantes">' geralPorPacReal[6] FORMAT "zzzz9" '</td>'                 SKIP
                  '         <td align="center" title="Compareceram">' geralPorPacReal[7] FORMAT "zzzzz9" '</td>'             SKIP.


           /** COOPERADOS **/
           {&out} '      <tr class="tdCab3">' SKIP
                  '         <td>TOTAL GERAL - Cooperados</td>' SKIP
                  '         <td align="center">&nbsp;</td>' SKIP
                  '         <td align="center">&nbsp;</td>' SKIP
                  '         <td align="center">&nbsp;</td>' SKIP
                  '         <td align="center">&nbsp;</td>' SKIP
                  '         <td align="center" title="Pré-Inscritos">'gerCoopPorPac[8] FORMAT "zzzzz9" '</td>'   SKIP
                  '         <td align="center" title="Pendentes de confirmação">'gerCoopPorPac[1] FORMAT "zzzzz9" '</td>' SKIP
                  '         <td align="center" title="Desistentes">' gerCoopPorPac[3] FORMAT "zzzzz9" '</td>' SKIP   
                  '         <td align="center" title="Confirmadas">' gerCoopPorPac[2] FORMAT "zzzzz9" '</td>' SKIP
                  '         <td align="center" title="Faltantes">' gerCoopPorPac[6] FORMAT "zzzzz9" '</td>' SKIP
                  '         <td align="center" title="Compareceram">' gerCoopPorPac[7] FORMAT "zzzzz9" '</td>' SKIP
                  '      </tr>' SKIP.

           /** COMUNIDADE **/
           {&out} '      <tr class="tdCab3">' SKIP
                  '         <td>TOTAL GERAL - Comunidade</td>' SKIP
                  '         <td align="center">&nbsp;</td>' SKIP
                  '         <td align="center">&nbsp;</td>' SKIP
                  '         <td align="center">&nbsp;</td>' SKIP
                  '         <td align="center">&nbsp;</td>' SKIP
                  '         <td align="center" title="Pré-Inscritos">'gerComuPorPac[8] FORMAT "zzzzz9" '</td>' SKIP
                  '         <td align="center" title="Pendentes de confirmação">'gerComuPorPac[1] FORMAT "zzzzz9" '</td>' SKIP
                  '         <td align="center" title="Desistentes">' gerComuPorPac[3] FORMAT "zzzzz9" '</td>' SKIP   
                  '         <td align="center" title="Confirmadas">' gerComuPorPac[2] FORMAT "zzzzz9" '</td>' SKIP
                  '         <td align="center" title="Faltantes">' gerComuPorPac[6] FORMAT "zzzzz9" '</td>' SKIP
                  '         <td align="center" title="Compareceram">' gerComuPorPac[7] FORMAT "zzzzz9" '</td>' SKIP
                  '      </tr>' SKIP.

           {&out} '      <tr class="tdCab3"><td colspan="11" align="Left">Questionários devolvidos: ' iQtQstDevolTotal FORMAT ">>>,>>9" '</td></tr>' SKIP.

           /** RODAPÉ **/
           {&out} '      <tr><td colspan="11" align="center"> &nbsp; </td></tr>' SKIP
                  '      <tr class="tdCab3">' SKIP
                  '         <td colspan="11"> VO-Vagas ofertadas; PI-Pré-Inscritos; PE-Pendentes de confirmação; DE-Desistentes; CO-Confirmadas; FA-Faltantes; CE-Compareceram.</td>' SKIP
                  '      </tr>' SKIP.
        END.

    END. /* FOR EACH ttCrapcdp  */
    
    {&out} '   </table>' SKIP.

    RETURN TRUE.

END FUNCTION. /* inscricoesNosEventosPorPac RETURNS LOGICAL () */

FUNCTION montaTela RETURNS LOGICAL ():

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
           '         <td class="tdprogra" colspan="5" align="right">wpgd0038a - ' TODAY '</td>' SKIP
           '   </table>' SKIP. 

    /* *** Logo *** */
    {&out} '   <table border="0" cellspacing="0" cellpadding="0" width="100%" class="tab1">' SKIP
           '      <tr>' SKIP
           '         <td align="center"><img src="' imagemDoProgrid '" border="0"></td>' SKIP
           '         <td class="tdTitulo1" colspan="4" align="center">' nomeDaCooperativa ' - Fechamento - ' dtAnoAge '</td>' SKIP
           '         <td align="center"><img src="' imagemDaCooperativa '" border="0"></td>' SKIP
           '      </tr>' SKIP
           '      <tr>' SKIP
           '         <td align="center" colspan="6"> &nbsp; </td>' SKIP
           '      </tr>' SKIP
           '      <tr>' SKIP
           '         <td align="center" colspan="6">Periodo de ' STRING(dataInicial,"99/99/9999") ' a ' STRING(dataFinal,"99/99/9999")  nomeDoRelatorio  '</td>' SKIP
           '      </tr>' SKIP
           '   </table>' SKIP. 

    {&out} '<br>' SKIP.

    FIND FIRST ttCrapadp NO-LOCK NO-ERROR.
    IF AVAILABLE ttCrapadp
       THEN
           DO:
              CASE tipoDeRelatorio:
                 WHEN 3 THEN
                       inscricoesNosEventosPorPac().
                  OTHERWISE
                      ASSIGN msgsDeErro = msgsDeErro + "-> Tipo de relatório ainda não implementado.<br>".
              END CASE.
           END.

    IF msgsDeErro <> ""
       THEN
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

EMPTY TEMP-TABLE ttCrapadp.

IF permiteExecutar = "1" OR 
   permiteExecutar = "2" THEN
   erroNaValidacaoDoLogin(permiteExecutar).
ELSE DO:
   ASSIGN idEvento                     = INTEGER(GET-VALUE("parametro1"))
          cdCooper                     = INTEGER(GET-VALUE("parametro2"))
          cdAgenci                     = INTEGER(GET-VALUE("parametro3"))
          dtAnoAge                     = INTEGER(GET-VALUE("parametro4"))
          cdEvento                     = INTEGER(GET-VALUE("parametro5"))
          nrSeqEve                     = INTEGER(GET-VALUE("parametro6"))
          dataInicial                  = DATE(GET-VALUE("parametro7"))
          dataFinal                    = DATE(GET-VALUE("parametro8")) 
          consideraEventosForaDaAgenda = IF GET-VALUE("parametro9") = "SIM" THEN YES ELSE NO
          tipoDeRelatorio              = INTEGER(GET-VALUE("parametro10"))
          tpEvento                     = INTEGER(GET-VALUE("parametro11"))
          NO-ERROR. 
   
   /* *** Localiza os eventos que satisfazem ao filtro (apenas custos diretos) *** */
   IF cdAgenci = 0  THEN /* Todos os PA´s */
      /*IF cdEvento = 0  /* Todos os eventos */ */
      IF nrSeqEve = 0  THEN DO: /* Todos os eventos */ 
         FOR EACH Crapadp WHERE Crapadp.IdEvento = idEvento  AND
                                Crapadp.CdCooper = cdCooper  AND
                               (Crapadp.CdAgenci > 0   OR
                                idevento         = 2)        AND
                                Crapadp.DtAnoAge = dtAnoAge  AND
                                Crapadp.CdEvento > 0         AND
                                Crapadp.NrSeqDig > 0         NO-LOCK,
            FIRST crapedp WHERE crapedp.cdcooper = Crapadp.cdcooper AND
                                crapedp.idevento = Crapadp.idevento AND
                                crapedp.cdevento = Crapadp.cdevento AND
                                crapedp.dtanoage = Crapadp.dtanoage AND
                              ((idEvento = 1                        AND
                               (tpEvento = 0                        OR
                               (tpEvento = 1                        AND
                                crapedp.tpevento = 10)              OR
                               (tpEvento = 2                        AND
                                crapedp.tpevento <> 10)))           OR
                               (idEvento = 2                        AND
                               (tpEvento = 0                        OR
                               (tpEvento = 1                        and
                                crapedp.tpevento = 11)              OR
                               (tpEvento = 2                        AND
                                crapedp.tpevento <> 11))))          NO-LOCK:
             IF (Crapadp.DtFinEve >= dataInicial AND 
                 Crapadp.DtFinEve <= dataFinal) OR
                (crapadp.dtinieve = ? AND
                 crapadp.dtfineve = ? AND
                 crapadp.nrmeseve >= MONTH(datainicial) AND
                 crapadp.nrmeseve <= MONTH(datafinal)   AND
                 consideraEventosForaDaAgenda) THEN DO:
                 CREATE ttCrapadp.
                 BUFFER-COPY Crapadp TO ttCrapadp.
                 /* carrega a quantidade max por turma do evento  */
                 ttCrapadp.MaximoPorTurma =  crapedp.qtmaxtur.
             END.
         END.
      END.
      ELSE DO: 
         FIND FIRST Crapadp WHERE Crapadp.IdEvento = idEvento    AND
                                  Crapadp.CdCooper = cdCooper    AND
                                  Crapadp.DtAnoAge = dtAnoAge    AND
                                  Crapadp.NrSeqDig = nrseqeve    NO-LOCK.
         FOR EACH bfCrapadp WHERE bfCrapadp.IdEvento = IdEvento          AND
                                  bfCrapadp.CdCooper = CdCooper          AND
                                 (bfCrapadp.CdAgenci > 0   OR
                                  idevento           = 2)                AND
                                  bfCrapadp.DtAnoAge = DtAnoAge          AND
                                  bfCrapadp.CdEvento = Crapadp.cdEvento  NO-LOCK:
          
             IF (bfCrapadp.DtFinEve >= dataInicial AND 
                 bfCrapadp.DtFinEve <= dataFinal) OR
                (bfCrapadp.dtinieve = ? AND
                 bfCrapadp.dtfineve = ? AND
                 bfCrapadp.nrmeseve >= MONTH(datainicial) AND
                 bfCrapadp.nrmeseve <= MONTH(datafinal)   AND
                 consideraEventosForaDaAgenda) THEN DO:
                 
                CREATE ttCrapadp.
                BUFFER-COPY bfCrapadp TO ttCrapadp.
             END.
         END.
      END.
   ELSE IF nrseqeve = 0 THEN DO: /* Todos os eventos */

      FOR EACH Crapadp WHERE Crapadp.IdEvento = idEvento      AND
                             Crapadp.CdCooper = cdCooper      AND
                            (Crapadp.CdAgenci = cdAgenci  OR
                             crapadp.cdagenci = 0)            AND
                             Crapadp.DtAnoAge = dtAnoAge      AND
                             Crapadp.CdEvento > 0             AND
                             Crapadp.NrSeqDig > 0             NO-LOCK,
         FIRST crapedp WHERE crapedp.cdcooper = Crapadp.cdcooper AND
                             crapedp.idevento = Crapadp.idevento AND
                             crapedp.cdevento = Crapadp.cdevento AND
                             crapedp.dtanoage = Crapadp.dtanoage AND
                           ((idEvento = 1                        AND
                            (tpEvento = 0                        OR
                            (tpEvento = 1                        AND
                             crapedp.tpevento = 10)              OR
                            (tpEvento = 2                        AND
                             crapedp.tpevento <> 10)))           OR
                            (idEvento = 2                        AND
                            (tpEvento = 0                        OR
                            (tpEvento = 1                        and
                             crapedp.tpevento = 11)              OR
                            (tpEvento = 2                        AND
                             crapedp.tpevento <> 11))))          NO-LOCK:
 
          IF (Crapadp.DtFinEve >= dataInicial AND 
              Crapadp.DtFinEve <= dataFinal) OR
             (crapadp.dtinieve = ? AND
              crapadp.dtfineve = ? AND
              crapadp.nrmeseve >= MONTH(datainicial) AND
              crapadp.nrmeseve <= MONTH(datafinal)   AND
              consideraEventosForaDaAgenda) THEN DO:
              CREATE ttCrapadp.
              BUFFER-COPY Crapadp TO ttCrapadp.
              /* carrega a quantidade max por turma do evento  */
              ttCrapadp.MaximoPorTurma =  crapedp.qtmaxtur.
          END.
      END.
   END.
   ELSE DO:

      FIND FIRST Crapadp WHERE Crapadp.IdEvento = idEvento      AND
                               Crapadp.CdCooper = cdCooper      AND
                              (Crapadp.CdAgenci = cdAgenci  OR
                               crapadp.cdagenci = 0)            AND
                               Crapadp.DtAnoAge = dtAnoAge      AND
                               Crapadp.NrSeqDig = nrSeqEve      NO-LOCK.
 
      FOR EACH bfCrapadp WHERE bfCrapadp.IdEvento = idEvento          AND
                               bfcrapadp.CdCooper = cdCooper          AND
                              (bfCrapadp.CdAgenci = cdAgenci  OR
                               bfcrapadp.cdagenci = 0)                AND
                               bfCrapadp.DtAnoAge = dtAnoAge          AND
                               bfCrapadp.CdEvento = crapadp.cdEvento  NO-LOCK:

          IF (bfCrapadp.DtFinEve >= dataInicial AND 
              bfCrapadp.DtFinEve <= dataFinal) OR
             (bfCrapadp.dtinieve = ? AND
              bfCrapadp.dtfineve = ? AND
              bfCrapadp.nrmeseve >= MONTH(datainicial) AND
              bfCrapadp.nrmeseve <= MONTH(datafinal)   AND
              consideraEventosForaDaAgenda) THEN DO:
              CREATE ttCrapadp.
              BUFFER-COPY bfCrapadp TO ttCrapadp.
          END.
      END.
   END.

   /* *** Varre a temp para carregar a descriçao da agencia, do evento e o tipo e status do evento *** */
   FIND Craptab   WHERE Craptab.cdcooper = 0                 AND
                        Craptab.NmSistem = "CRED"            AND
                        Craptab.TpTabela = "CONFIG"          AND
                        Craptab.CdEmpres = 0                 AND
                        Craptab.CdAcesso = "PGSTEVENTO"      AND
                        Craptab.TpRegist = 0                 NO-LOCK NO-ERROR.

   FIND bfCraptab WHERE bfCraptab.cdcooper = 0               AND
                        bfCraptab.NmSistem = "CRED"          AND
                        bfCraptab.TpTabela = "CONFIG"        AND 
                        bfCraptab.CdEmpres = 0               AND 
                        bfCraptab.CdAcesso = "PGTPEVENTO"    AND
                        bfCraptab.TpRegist = 0               NO-LOCK NO-ERROR.

   /*****************************************************************************************************/

   /* Assembleia Geral - devera aparecer agrupado por Agencia de Inscricao - Joao(RKAM) - 30/11/2010 */
   IF idEvento = 2  THEN
   DO:
       FOR EACH ttcrapadp EXCLUSIVE-LOCK
          WHERE ttcrapadp.idevento = idEvento AND
                ttcrapadp.cdcooper = cdCooper AND
                ttcrapadp.cdagenci = 0,
           FIRST crapedp NO-LOCK 
           WHERE crapedp.idEvento = ttcrapadp.idevento AND
                 crapedp.cdCooper = ttcrapadp.cdcooper AND
                 crapedp.dtAnoAge = ttcrapadp.dtanoage AND
                 crapedp.cdEvento = ttcrapadp.cdevento AND
                 crapedp.tpevento = 7 ON ERROR UNDO, LEAVE:

           FOR EACH crapidp NO-LOCK
              WHERE crapidp.idevento = idevento           AND
                    crapidp.cdcooper = ttcrapadp.cdcooper AND 
                    crapidp.dtanoage = ttcrapadp.dtanoage AND 
                    crapidp.cdagenci = ttcrapadp.cdagenci AND 
                    crapidp.cdevento = ttcrapadp.cdevento AND 
                    crapidp.nrseqeve = ttcrapadp.nrseqdig AND
                   (cdagenci         = 0                  OR
                    crapidp.cdageins = cdagenci)

              BREAK BY crapidp.idevento
                    BY crapidp.cdcooper
                    BY crapidp.dtanoage
                    BY crapidp.cdageins ON ERROR UNDO, LEAVE:

               IF FIRST-OF(crapidp.cdageins) THEN
               DO:
                   CREATE bttcrapadp.
                   BUFFER-COPY ttcrapadp EXCEPT cdagenci TO bttcrapadp.
                   ASSIGN bttcrapadp.cdagenci = crapidp.cdageins
                          aux_assembl         = YES.
               END.
           END.
       END. /* FOR EACH */
   END. /* idEvento = 2 */ 
   /*****************************************************************************************************/
                                                                      
   ASSIGN conta = 0. 

   FOR EACH ttCrapadp:
         
       /* *** Nome e dados extras do evento *** */
       FIND FIRST Crapedp WHERE Crapedp.IdEvento = ttCrapadp.IdEvento AND
                                Crapedp.CdCooper = ttCrapadp.CdCooper AND
                                Crapedp.DtAnoAge = ttCrapadp.DtAnoAge AND
                                Crapedp.CdEvento = ttCrapadp.CdEvento NO-LOCK NO-ERROR.
                                
       IF AVAILABLE Crapedp THEN DO:
          ASSIGN frequenciaMinima = crapedp.prfreque. 
          ASSIGN ttCrapadp.NomeDoEvento   = Crapedp.NmEvento
                 ttCrapadp.MinimoPorTurma = Crapedp.QtMinTur
                 ttCrapadp.TpEvento       = Crapedp.TpEvento.
       END.
       ELSE
          ASSIGN ttCrapadp.NomeDoEvento   = "Evento " + STRING(ttCrapadp.CdEvento,"99")
                 ttCrapadp.MinimoPorTurma = 0
                 ttCrapadp.TpEvento       = 0.
                
       IF ttCrapadp.TpEvento <> 10 AND ttCrapadp.TpEvento <> 11 THEN DO:
         FIND FIRST crapeap WHERE crapeap.cdcooper = ttcrapadp.cdcooper AND
                           crapeap.idevento = ttcrapadp.idevento AND                                     
                           crapeap.cdevento = ttcrapadp.cdevento AND
                           crapeap.dtanoage = ttcrapadp.dtanoage AND
                           crapeap.cdagenci = ttcrapadp.cdagenci NO-LOCK NO-ERROR.
               
              IF AVAILABLE crapeap THEN
                DO:
                  IF crapeap.qtmaxtur > 0 THEN
                      ASSIGN ttCrapadp.MaximoPorTurma = crapeap.qtmaxtur.
                  ELSE
                    DO:
                      /* para a frequencia minima */
                      FIND FIRST crabedp WHERE crabedp.idevento = crapadp.idevento AND 
                                               crabedp.cdcooper = crapadp.cdcooper AND
                                               crabedp.dtanoage = crapadp.dtanoage AND 
                                               crabedp.cdevento = crapadp.cdevento NO-LOCK NO-ERROR. 
                      IF AVAILABLE crabedp THEN
                        DO:
                          IF crabedp.qtmaxtur > 0 THEN
                            ASSIGN ttCrapadp.MaximoPorTurma = ttCrapadp.MaximoPorTurma + crabedp.qtmaxtur.
                          ELSE
                            DO:
                              FIND FIRST crabedp WHERE crabedp.idevento = crapadp.idevento AND 
                                                   crabedp.cdcooper = 0 AND
                                                   crabedp.dtanoage = 0 AND 
                                                   crabedp.cdevento = crapadp.cdevento NO-LOCK NO-ERROR.
                                                  
                              IF AVAILABLE crabedp THEN
                                ASSIGN ttCrapadp.MaximoPorTurma = ttCrapadp.MaximoPorTurma + crabedp.qtmaxtur.
                            END.
                        END.
                    END.
                END.
              ELSE
                DO:
                  /* para a frequencia minima */
                  FIND FIRST crabedp WHERE crabedp.idevento = crapadp.idevento AND 
                                           crabedp.cdcooper = crapadp.cdcooper AND
                                           crabedp.dtanoage = crapadp.dtanoage AND 
                                           crabedp.cdevento = crapadp.cdevento NO-LOCK NO-ERROR. 
                  IF AVAILABLE crabedp THEN
                    DO:
                      IF crabedp.qtmaxtur > 0 THEN
                        ASSIGN ttCrapadp.MaximoPorTurma = ttCrapadp.MaximoPorTurma + crabedp.qtmaxtur.
                      ELSE
                        DO:
                          FIND FIRST crabedp WHERE crabedp.idevento = crapadp.idevento AND 
                                               crabedp.cdcooper = 0 AND
                                               crabedp.dtanoage = 0 AND 
                                               crabedp.cdevento = crapadp.cdevento NO-LOCK NO-ERROR.
                                              
                          IF AVAILABLE crabedp THEN
                            ASSIGN ttCrapadp.MaximoPorTurma = ttCrapadp.MaximoPorTurma + crabedp.qtmaxtur.
                        END.
                    END.
                END.
        END.
       ELSE
         ttCrapadp.MaximoPorTurma = 1. 
        /****************/
       
       /* *** Descricao do status do evento *** */
       IF AVAILABLE CrapTab THEN
          IF Craptab.DsTexTab = "" THEN
              ASSIGN ttCrapadp.StatusDoEvento = " - ".
          ELSE IF NUM-ENTRIES(Craptab.DsTexTab) >= 2 THEN DO:
              ASSIGN ttCrapadp.StatusDoEvento = " - ".
              DO conta = 2 TO NUM-ENTRIES(Craptab.DsTexTab) BY 2:
                 IF INTEGER(ENTRY(conta,Craptab.DsTexTab)) = ttCrapadp.IdStaEve THEN
                    ASSIGN ttCrapadp.StatusDoEvento = ENTRY(conta - 1,Craptab.DsTexTab).
                               
              END.
          END.
          ELSE
              ASSIGN ttCrapadp.StatusDoEvento = " - ".
       ELSE
          ASSIGN ttCrapadp.StatusDoEvento = " - ".
              
       /* *** Descricao do tipo do evento *** */
       IF AVAILABLE bfCrapTab THEN
          IF bfCraptab.DsTexTab = "" THEN
             ASSIGN ttCrapadp.TipoDoEvento = " - ".
          ELSE IF NUM-ENTRIES(bfCraptab.DsTexTab) >= 2 THEN DO:
             ASSIGN ttCrapadp.TipoDoEvento = " - ".
             DO conta = 2 TO NUM-ENTRIES(bfCraptab.DsTexTab) BY 2:
                IF INTEGER(ENTRY(conta,bfCraptab.DsTexTab)) = ttCrapadp.TpEvento THEN
                   ASSIGN ttCrapadp.TipoDoEvento = ENTRY(conta - 1,bfCraptab.DsTexTab).
             END.
          END.
          ELSE
             ASSIGN ttCrapadp.TipoDoEvento = " - ".
       ELSE
          ASSIGN ttCrapadp.TipoDoEvento = " - ".

       /* *** Nome do PA *** */
       ASSIGN aux_existpac = FALSE.
       FOR EACH crapagp WHERE  crapagp.cdcooper = ttcrapadp.cdcooper AND
                               crapagp.idevento = ttcrapadp.idevento AND
                               crapagp.dtanoage = ttcrapadp.dtanoage AND
                               crapagp.cdageagr = ttcrapadp.cdagenci NO-LOCK:

           FIND Crapage WHERE Crapage.CdCooper = ttCrapadp.CdCooper AND Crapage.CdAgenci = crapagp.CdAgenci NO-LOCK NO-ERROR.
           IF  AVAILABLE Crapage THEN
               DO:
                  ASSIGN  ttCrapadp.NomeDoPac = ttCrapadp.NomeDoPac + Crapage.NmResAge + "/"
                          aux_existpac = TRUE.   
               END.    
       END.
          
       IF  aux_existpac = FALSE  THEN
           DO:
               /* 23/11/2010 */
               FOR FIRST Crapage FIELDS(nmresage) WHERE Crapage.CdCooper = ttCrapadp.CdCooper   AND 
                                                        Crapage.CdAgenci = ttCrapadp.CdAgenci NO-LOCK: 
                   ASSIGN ttCrapadp.NomeDoPac = crapage.nmresage.
               END.
           END.
       ELSE
           ASSIGN ttCrapadp.NomeDoPac = SUBSTRING(ttCrapadp.NomeDoPac,1,LENGTH(ttCrapadp.NomeDoPac) - 1).
       
       FOR EACH crapidp NO-LOCK
          WHERE crapidp.idevento = idevento                     
            AND crapidp.cdcooper = ttCrapadp.CdCooper           
            AND crapidp.dtanoage = ttCrapadp.DtAnoAge           
            AND crapidp.cdagenci = ttCrapadp.cdagenci           
            AND crapidp.cdevento = ttCrapadp.cdevento           
            AND crapidp.nrseqeve = ttCrapadp.nrSeqDig           
            AND (idevento         = 1                            
            OR   cdagenci         = 0                  
            OR   crapidp.cdageins = cdagenci),
          FIRST crapedp NO-LOCK 
          WHERE crapedp.idEvento     = crapidp.idevento 
            AND crapedp.cdCooper     = crapidp.cdcooper 
            AND crapedp.dtAnoAge     = crapidp.dtanoage 
            AND crapedp.cdEvento     = crapidp.cdevento 
            AND NOT crapedp.tpevento = 7 
            BREAK BY crapidp.idstains: 

           IF Crapidp.IdStaIns > 0 AND Crapidp.IdStaIns < 6 THEN DO:
               ASSIGN ttCrapadp.Inscritos[Crapidp.IdStaIns] = ttCrapadp.Inscritos[Crapidp.IdStaIns] + 1.
    
               IF crapidp.tpinseve = 1 THEN
                   ASSIGN ttCrapadp.InscCoop[Crapidp.IdStaIns] = ttCrapadp.InscCoop[Crapidp.IdStaIns] + 1.
               ELSE 
                   ASSIGN ttCrapadp.InscComu[Crapidp.IdStaIns] = ttCrapadp.InscComu[Crapidp.IdStaIns] + 1.
           END.

           /* *** Se inscricao cofirmada e inscricoes encerradas e evento NAO CANCELADO, verifica faltas ****/
           IF Crapidp.IdStaIns = 2  AND Crapidp.QtFalEve > 0 AND ttCrapadp.idstaeve <> 2 /*Cancelado*/ THEN DO:
              IF ((crapidp.qtfaleve * 100) / ttCrapadp.QtDiaEve) > (100 - frequenciaMinima) THEN DO:
                  ASSIGN ttCrapadp.Inscritos[6] = ttCrapadp.Inscritos[6] + 1.
    
                  IF crapidp.tpinseve = 1 THEN
                      ASSIGN ttCrapadp.InscCoop[6] = ttCrapadp.InscCoop[6] + 1.
                  ELSE 
                      ASSIGN ttCrapadp.InscComu[6] = ttCrapadp.InscComu[6] + 1.
              END.
           END.
       END. /* FOR EACH crapidp */
       
       IF aux_assembl THEN
       DO: 
           /* Contabiliza as inscrições de Assembléia por Pa */
           FOR EACH crapidp NO-LOCK
              WHERE crapidp.idevento = idevento            
                AND crapidp.cdcooper = ttCrapadp.CdCooper  
                AND crapidp.dtanoage = ttCrapadp.DtAnoAge  
                AND crapidp.cdagenci = 0                   
                AND crapidp.cdevento = ttCrapadp.cdevento  
                AND crapidp.nrseqeve = ttCrapadp.nrSeqDig  
                AND ((cdagenci         = 0
                AND   crapidp.cdageins = ttCrapadp.cdagenci)
                 OR   crapidp.cdageins = cdagenci)
              BREAK BY crapidp.idstains:
              
               IF Crapidp.IdStaIns > 0 AND Crapidp.IdStaIns < 6 THEN DO:
                   ASSIGN ttCrapadp.Inscritos[Crapidp.IdStaIns] = ttCrapadp.Inscritos[Crapidp.IdStaIns] + 1.
                          
                   IF crapidp.tpinseve = 1 THEN
                       ASSIGN ttCrapadp.InscCoop[Crapidp.IdStaIns] = ttCrapadp.InscCoop[Crapidp.IdStaIns] + 1.
                   ELSE
                       ASSIGN ttCrapadp.InscComu[Crapidp.IdStaIns] = ttCrapadp.InscComu[Crapidp.IdStaIns] + 1.
               END.

               /* *** Se inscricao cofirmada e inscricoes encerradas e evento NAO CANCELADO, verifica faltas ****/
               IF Crapidp.IdStaIns = 2  AND Crapidp.QtFalEve > 0 AND ttCrapadp.idstaeve <> 2 /*Cancelado*/ THEN DO:
                  IF ((crapidp.qtfaleve * 100) / ttCrapadp.QtDiaEve) > (100 - frequenciaMinima) THEN DO:
                      ASSIGN ttCrapadp.Inscritos[6] = ttCrapadp.Inscritos[6] + 1.

                      IF crapidp.tpinseve = 1 THEN
                          ASSIGN ttCrapadp.InscCoop[6] = ttCrapadp.InscCoop[6] + 1.
                      ELSE
                          ASSIGN ttCrapadp.InscComu[6] = ttCrapadp.InscComu[6] + 1.
                  END.
               END.
           END. /* FOR EACH crapidp */
       END.
              
       /* Se o evento já ocorreu e NAO FOI CANCELADO, conta os que COMPARECERAM */
       IF ttcrapadp.dtfineve  < TODAY AND
          ttcrapadp.idstaeve <> 2     THEN DO:
          ASSIGN ttCrapadp.Inscritos[7] = ttCrapadp.Inscritos[2] - ttCrapadp.Inscritos[6]
                 ttCrapadp.InscCoop[7]  = ttCrapadp.InscCoop[2] - ttCrapadp.inscCoop[6]
                 ttCrapadp.InscComu[7]  = ttCrapadp.InscComu[2] - ttCrapadp.inscComu[6].
       END.

       /* *** Complemento para o nome do evento *** */
       IF (ttCrapadp.DtFinEve - ttCrapadp.DtIniEve) = 0 THEN
          ASSIGN ttCrapadp.SobreNomeDoEvento1 = ' (' + STRING(ttCrapadp.DtIniEve,"99/99/9999") + ')'
                 ttCrapadp.SobreNomeDoEvento2 = ' (' + STRING(ttCrapadp.DtIniEve,"99/99/9999") + ')'
                 ttCrapadp.Periodo            = STRING(ttCrapadp.DtIniEve,"99/99/9999").
       ELSE
          IF (ttCrapadp.DtFinEve - ttCrapadp.DtIniEve) > 0 THEN
              ASSIGN ttCrapadp.SobreNomeDoEvento1 = ' (período de ' + STRING(ttCrapadp.DtIniEve,"99/99/9999") + ' a ' + STRING(ttCrapadp.DtFinEve,"99/99/9999") + ')'
                     ttCrapadp.SobreNomeDoEvento2 = ' (' + STRING(ttCrapadp.DtIniEve,"99/99/9999") + ' a ' + STRING(ttCrapadp.DtFinEve,"99/99/9999") + ')'
                     ttCrapadp.Periodo            = STRING(ttCrapadp.DtIniEve,"99/99/9999") + ' a ' + STRING(ttCrapadp.DtFinEve,"99/99/9999").
          ELSE DO:
              IF ttCrapadp.NrMesEve > 0 AND ttCrapadp.NrMesEve < 13 THEN
                 ASSIGN ttCrapadp.SobreNomeDoEvento1 = ' (mês de ' + ENTRY(ttCrapadp.NrMesEve,mes) + ')'
                        ttCrapadp.SobreNomeDoEvento2 = ' (' + ENTRY(ttCrapadp.NrMesEve,mes) + ')'
                        ttCrapadp.Periodo            = ENTRY(ttCrapadp.NrMesEve,mes).
              ELSE
                 ASSIGN ttCrapadp.SobreNomeDoEvento1 = ' (' + STRING(ttCrapadp.Sequenciador,"Z9") + ')'
                        ttCrapadp.SobreNomeDoEvento2 = ' (' + STRING(ttCrapadp.Sequenciador,"Z9") + ')'
                        ttCrapadp.Periodo            = ' - '.
          END.
          
          
   END. /* FOR EACH ttCrapadp */

   /* *** Cria valor auxiliar1 para faciliar break by da impressão baseado na data*** */
   FOR EACH ttCrapadp WHERE ttCrapadp.DtIniEve <> ?:
       ASSIGN ttCrapadp.Auxiliar1 = STRING(ttCrapadp.CdEvento,"99999") + STRING(YEAR(ttCrapadp.DtIniEve),"9999") + STRING(MONTH(ttCrapadp.DtIniEve),"99") + STRING(DAY(ttCrapadp.DtIniEve),"99")
              ttCrapadp.Ano       = YEAR(ttCrapadp.DtIniEve).
   END.
   FIND FIRST ttCrapadp NO-LOCK NO-ERROR.
   IF NOT AVAILABLE ttCrapadp THEN
      ASSIGN msgsDeErro = msgsDeErro + "-> Não existe movimento para os dados informados.<br>".

   FIND crapcop WHERE crapcop.cdcooper = cdCooper NO-LOCK NO-ERROR.

   IF AVAILABLE crapcop THEN
      DO:
          ASSIGN imagemDoProgrid      = "/cecred/images/geral/logo_cecred.gif"
                 nomeDaCooperativa    = TRIM(crapcop.nmrescop).

          IF INDEX(crapcop.nmrescop, " ") <> 0  THEN
             DO: 
                aux_nmrescop = LC(TRIM(crapcop.nmrescop)).
                SUBSTRING( aux_nmrescop, (INDEX(aux_nmrescop, " ")),1) = "_".
                imagemDaCooperativa =  "/cecred/images/admin/logo_" +  aux_nmrescop.
             END.
          ELSE
             imagemDaCooperativa  = "/cecred/images/admin/logo_" + TRIM(LC(crapcop.nmrescop)) + ".gif" .
            
      END.
          
   IF tipoDeRelatorio = 1 THEN
      ASSIGN nomeDoRelatorio = " - Situação dos Eventos por PA".
   ELSE IF tipoDeRelatorio = 2 THEN
      ASSIGN nomeDoRelatorio = " - Quantidade de Eventos por PA ". 
   ELSE
      ASSIGN nomeDoRelatorio = " - Inscrições nos Eventos por PA". 
  
   montaTela(). 
END.
          
PROCEDURE PermissaoDeAcesso :
    {includes/wpgd0009.i} 
END PROCEDURE.
