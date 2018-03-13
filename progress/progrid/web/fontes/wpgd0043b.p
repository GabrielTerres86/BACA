/***********************************************************************************************
  Programa wpgd0043b.p - Listagem de fechamento Geral (chamado a partir dos dados de wpgd0043)

  Alteracoes: 03/11/2008 - Incluido widget-pool.

              10/12/2008 - Melhoria de performance para a tabela gnapses (Evandro).
              
              19/12/2009 - Quebra da coluna realizado em Coop, Comu e Total (martin)
              
              09/06/2011 - Correção da quebra de página (Isara - RKAM).
        
              05/06/2012 - Adaptação dos fontes para projeto Oracle. Alterado
                           busca na gnapses de CONTAINS para MATCHES (Guilherme Maba).
                           
              04/04/2013 - Alteração para receber logo na alto vale,
                           recebendo nome de viacrediav e buscando com
                           o respectivo nome (David Kruger).
                           
              04/09/2013 - Nova forma de chamar as agências, de PAC agora 
                           a escrita será PA (André Euzébio - Supero). 
               
              23/06/2015 - Inclusao de tratamento para todas as cooperativas e 
                           criacao de novas funcoes para melhorar o codigo(Jean Michel).
                           
              05/10/2015 - Incluida verificacao de qtmaxtur na crapeap antes
                           da atribuicao da crapedp Projeto 229 (Jean Michel).             
                           
              24/03/2016 - Inclusao de EAD, Projeto 229 (Jean Michel).     
              
              25/04/2016 - Correcao na mascara dos campos de percentual. 
                           (Carlos Rafael Tanholi)
              
              26/04/2016 - Alteracao nos cabecalhos de tabelas totalizadoras e
                           tambem criacao de colunas. Criacao do total geral de 
                           participantes.(Carlos Rafael Tanholi)     
                           
              27/04/2016 - Correcao do erro que estava preenchendo o LOG, informando
                           que o evento selecionado nao existia, decorrende da falta
                           de uso do AVAIL no comando FIND. (Carlos Rafael Tanholi)
                           
              30/05/2016 - Correcao na listagem de eventos EAD que nao apresentavam
                           descricao nas tabelas de TURMAS EAD e PARTICIPANTES EAD.
                           (Carlos Rafael Tanholi).
                           
              31/05/2016 - Ajustado numero de participantes previstos EAD
                           PRJ229 - Melhorias EAD (Odirlei-AMcom)
                           
              30/08/2017 - Inclusao do filtro por Programa,Prj. 322 (Jean Michel).             
            
***********************************************************************************************/
create widget-pool.
/*****************************************************************************/
/*   Bloco de variaveis                                                      */
/*****************************************************************************/

DEFINE VARIABLE cookieEmUso           AS CHARACTER NO-UNDO.
DEFINE VARIABLE permiteExecutar       AS CHARACTER NO-UNDO.
DEFINE VARIABLE IdentificacaoDaSessao AS CHARACTER NO-UNDO.
DEFINE VARIABLE msgsDeErro            AS CHARACTER NO-UNDO.
DEFINE VARIABLE cdcooper              AS CHARACTER NO-UNDO.
DEFINE VARIABLE eventoDetelhe		      AS CHARACTER NO-UNDO.
DEFINE VARIABLE aux_nmrescop          AS CHARACTER NO-UNDO.
DEFINE VARIABLE imagemDoProgrid       AS CHARACTER NO-UNDO.
DEFINE VARIABLE imagemDaCooperativa   AS CHARACTER NO-UNDO.
DEFINE VARIABLE nomeDaCooperativa     AS CHARACTER NO-UNDO.

DEFINE VARIABLE detalhar              AS LOGICAL NO-UNDO.

DEFINE VARIABLE idEvento              AS INTEGER NO-UNDO.
DEFINE VARIABLE dtAnoAge              AS INTEGER NO-UNDO.
DEFINE VARIABLE aux_contador          AS INTEGER NO-UNDO.
DEFINE VARIABLE aux_qtmaxtur          AS INTEGER NO-UNDO.

DEFINE VARIABLE tur_ttprevis          AS INTEGER NO-UNDO.
DEFINE VARIABLE tur_ttprevis_ead      AS INTEGER NO-UNDO.
DEFINE VARIABLE tot_tur_ttprevis      AS INTEGER NO-UNDO.
DEFINE VARIABLE tot_tur_ttprevis_ead  AS INTEGER NO-UNDO.

DEFINE VARIABLE tur_ttcancel          AS INTEGER NO-UNDO.
DEFINE VARIABLE tur_ttcancel_ead      AS INTEGER NO-UNDO.
DEFINE VARIABLE tot_tur_ttcancel      AS INTEGER NO-UNDO.
DEFINE VARIABLE tot_tur_ttcancel_ead  AS INTEGER NO-UNDO.

DEFINE VARIABLE tur_ttrecebi          AS INTEGER NO-UNDO.
DEFINE VARIABLE tur_ttrecebi_ead      AS INTEGER NO-UNDO.
DEFINE VARIABLE tot_tur_ttrecebi      AS INTEGER NO-UNDO.
DEFINE VARIABLE tot_tur_ttrecebi_ead  AS INTEGER NO-UNDO.

DEFINE VARIABLE tur_ttacresc          AS INTEGER NO-UNDO.
DEFINE VARIABLE tur_ttacresc_ead      AS INTEGER NO-UNDO.
DEFINE VARIABLE tot_tur_ttacresc      AS INTEGER NO-UNDO.
DEFINE VARIABLE tot_tur_ttacresc_ead  AS INTEGER NO-UNDO.

DEFINE VARIABLE tur_tttransf          AS INTEGER NO-UNDO.
DEFINE VARIABLE tur_tttransf_ead      AS INTEGER NO-UNDO.
DEFINE VARIABLE tot_tur_tttransf      AS INTEGER NO-UNDO.
DEFINE VARIABLE tot_tur_tttransf_ead  AS INTEGER NO-UNDO.

DEFINE VARIABLE tur_ttrealiz          AS INTEGER NO-UNDO.
DEFINE VARIABLE tur_ttrealiz_ead      AS INTEGER NO-UNDO.
DEFINE VARIABLE tot_tur_ttrealiz      AS INTEGER NO-UNDO.
DEFINE VARIABLE tot_tur_ttrealiz_ead  AS INTEGER NO-UNDO.

DEFINE VARIABLE prt_qtrealiz          AS INTEGER NO-UNDO.
DEFINE VARIABLE prt_qtrealiz_ead      AS INTEGER NO-UNDO.
DEFINE VARIABLE tot_prt_qtrealiz      AS INTEGER NO-UNDO.
DEFINE VARIABLE tot_prt_qtrealiz_ead  AS INTEGER NO-UNDO.

DEFINE VARIABLE prt_qtrecoop          AS INTEGER NO-UNDO.
DEFINE VARIABLE prt_qtrecoop_ead      AS INTEGER NO-UNDO.
DEFINE VARIABLE tot_prt_qtrecoop      AS INTEGER NO-UNDO.
DEFINE VARIABLE tot_prt_qtrecoop_ead  AS INTEGER NO-UNDO.

DEFINE VARIABLE prt_qtrecomu          AS INTEGER NO-UNDO.
DEFINE VARIABLE prt_qtrecomu_ead      AS INTEGER NO-UNDO.
DEFINE VARIABLE tot_prt_qtrecomu      AS INTEGER NO-UNDO.
DEFINE VARIABLE tot_prt_qtrecomu_ead  AS INTEGER NO-UNDO.

DEFINE VARIABLE prt_ttprevis          AS INTEGER NO-UNDO.
DEFINE VARIABLE prt_ttprevis_ead      AS INTEGER NO-UNDO.
DEFINE VARIABLE tot_prt_ttprevis      AS INTEGER NO-UNDO.
DEFINE VARIABLE tot_prt_ttprevis_ead  AS INTEGER NO-UNDO.

DEFINE VARIABLE prt_ttrecoop          AS INTEGER NO-UNDO.
DEFINE VARIABLE prt_ttrecoop_ead      AS INTEGER NO-UNDO.
DEFINE VARIABLE tot_prt_ttrecoop      AS INTEGER NO-UNDO.
DEFINE VARIABLE tot_prt_ttrecoop_ead  AS INTEGER NO-UNDO.

DEFINE VARIABLE prt_ttrecomu          AS INTEGER NO-UNDO.
DEFINE VARIABLE prt_ttrecomu_ead      AS INTEGER NO-UNDO.
DEFINE VARIABLE tot_prt_ttrecomu      AS INTEGER NO-UNDO.
DEFINE VARIABLE tot_prt_ttrecomu_ead  AS INTEGER NO-UNDO.

DEFINE VARIABLE prt_ttrealiz          AS INTEGER NO-UNDO.
DEFINE VARIABLE prt_ttrealiz_ead      AS INTEGER NO-UNDO.
DEFINE VARIABLE tot_prt_ttrealiz      AS INTEGER NO-UNDO.
DEFINE VARIABLE tot_prt_ttrealiz_ead  AS INTEGER NO-UNDO.

DEFINE VARIABLE aux_nmresage LIKE crapage.nmresage NO-UNDO.

DEFINE VARIABLE aux_tpevento AS INTEGER NO-UNDO.
DEFINE VARIABLE nrseqpgm     AS INTEGER NO-UNDO.

DEFINE BUFFER crabage FOR crapage.
DEFINE BUFFER crabedp FOR crapedp.

/* Turmas */
DEFINE TEMP-TABLE turmas
  FIELD cdevento AS INTEGER
  FIELD qtprevis AS INTEGER
  FIELD qtcancel AS INTEGER
  FIELD qtacresc AS INTEGER
  FIELD qttransf AS INTEGER /* pode ser transferido e/ou recebido */
  FIELD qtrealiz AS INTEGER
  FIELD tpevento AS INTEGER
  FIELD percentu AS DECIMAL
  FIELD nmevento AS CHARACTER.
  
/* Turmas EAD */
DEFINE TEMP-TABLE turmasEAD
  FIELD cdevento AS INTEGER
  FIELD qtprevis AS INTEGER
  FIELD qtcancel AS INTEGER
  FIELD qtacresc AS INTEGER
  FIELD qttransf AS INTEGER /* pode ser transferido e/ou recebido */
  FIELD qtrealiz AS INTEGER
  FIELD tpevento AS INTEGER
  FIELD percentu AS DECIMAL
  FIELD nmevento AS CHARACTER.  

/* Participantes */
DEFINE TEMP-TABLE participantes
  FIELD cdevento AS INTEGER
  FIELD qtprevis AS INTEGER
  FIELD qtrecoop AS INTEGER
  FIELD qtrecomu AS INTEGER 
  FIELD qtrealiz AS INTEGER
  FIELD tpevento AS INTEGER
  FIELD precentu AS DECIMAL
  FIELD nmevento AS CHARACTER.
  
/* Participantes EAD */
DEFINE TEMP-TABLE participantesEAD
  FIELD cdevento AS INTEGER
  FIELD qtprevis AS INTEGER
  FIELD qtrecoop AS INTEGER
  FIELD qtrecomu AS INTEGER 
  FIELD qtrealiz AS INTEGER
  FIELD tpevento AS INTEGER
  FIELD precentu AS DECIMAL
  FIELD nmevento AS CHARACTER.

/* TurmasTotal */
DEFINE TEMP-TABLE turmasTotal
  FIELD cdevento AS INTEGER
  FIELD qtprevis AS INTEGER
  FIELD qtcancel AS INTEGER
  FIELD qtacresc AS INTEGER
  FIELD qttransf AS INTEGER /* pode ser transferido e/ou recebido */
  FIELD qtrealiz AS INTEGER
  FIELD tpevento AS INTEGER
  FIELD percentu AS DECIMAL
  FIELD nmevento AS CHARACTER.

/* Turmas Total EAD*/
DEFINE TEMP-TABLE turmasTotalEAD
  FIELD cdevento AS INTEGER
  FIELD qtprevis AS INTEGER
  FIELD qtcancel AS INTEGER
  FIELD qtacresc AS INTEGER
  FIELD qttransf AS INTEGER /* pode ser transferido e/ou recebido */
  FIELD qtrealiz AS INTEGER
  FIELD tpevento AS INTEGER
  FIELD percentu AS DECIMAL
  FIELD nmevento AS CHARACTER.
  
/* ParticipantesTotal */
DEFINE TEMP-TABLE participantesTotal
  FIELD cdevento AS INTEGER
  FIELD qtprevis AS INTEGER
  FIELD qtrecoop AS INTEGER
  FIELD qtrecomu AS INTEGER 
  FIELD qtrealiz AS INTEGER
  FIELD tpevento AS INTEGER
  FIELD precentu AS DECIMAL
  FIELD nmevento AS CHARACTER.
  
/* ParticipantesTotalEAD */
DEFINE TEMP-TABLE participantesTotalEAD
  FIELD cdevento AS INTEGER
  FIELD qtprevis AS INTEGER
  FIELD qtrecoop AS INTEGER
  FIELD qtrecomu AS INTEGER 
  FIELD qtrealiz AS INTEGER
  FIELD tpevento AS INTEGER
  FIELD precentu AS DECIMAL
  FIELD nmevento AS CHARACTER.  

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

FUNCTION turmas RETURNS LOGICAL ():

    {&out} '<table class="tab2" border="1" cellspacing="0" cellpadding="0" width="100%" style="paddin-top:10px; float:left;">' SKIP
           '  <tr>' SKIP
           '    <td class="td2" align="center" valign="middle" colspan="8">' SKIP
           '      TURMAS - PRESENCIAL' SKIP
           '    </td>' SKIP
           '  </tr>' SKIP
           '  <tr>' SKIP
           '    <td class="td2" align="center" width="42%">' SKIP
           '      EVENTO' SKIP
           '    </td>' SKIP
           '    <td class="td2" align="center">' SKIP
           '      PREVISTO' SKIP
           '    </td>' SKIP
           '    <td class="td2" align="center">' SKIP
           '      CANCELADO' SKIP
           '    </td>' SKIP
           '    <td class="td2" align="center">' SKIP
           '      ACRESCIDO' SKIP
           '    </td>' SKIP
           '    <td class="td2" align="center">' SKIP
           '      TRANSFERIDO/RECEBIDO' SKIP
           '    </td>' SKIP
           '    <td class="td2" align="center">' SKIP
           '      REALIZADO' SKIP
           '    </td>' SKIP
           '    <td class="td2" align="center">' SKIP
           '      %' SKIP
           '    </td>' SKIP
           '  </tr>' SKIP.

    ASSIGN tur_ttprevis = 0
           tur_ttcancel = 0
           tur_ttacresc = 0
           tur_tttransf = 0
           tur_ttrealiz = 0.

    FOR EACH turmas NO-LOCK BY TRIM(turmas.nmevento):

  
        {&out} '<tr>' SKIP
               '  <td class="td2" align="left">' SKIP
                    UPPER(TRIM(turmas.nmevento)) SKIP
               '  </td>' SKIP
               '  <td class="tdDados2" align="center">' SKIP
                    turmas.qtprevis SKIP
               '  </td>' SKIP
               '  <td class="tdDados2" align="center">' SKIP
                    turmas.qtcancel SKIP
               '  </td>' SKIP
               '  <td class="tdDados2" align="center">' SKIP
                    turmas.qtacresc SKIP
               '  </td>' SKIP
               '  <td class="tdDados2" align="center">' SKIP
                    turmas.qttransf SKIP
               '  </td>' SKIP
               '  <td class="tdDados2" align="center">' SKIP
                    turmas.qtrealiz SKIP
               '  </td>' SKIP
               '  <td class="tdDados2" align="center">' SKIP.

        IF   turmas.qtprevis <> 0   THEN
             {&out} '&nbsp;' STRING(ROUND((turmas.qtrealiz * 100) / turmas.qtprevis,2),"zz9.99") '%&nbsp;' SKIP.
        ELSE
             {&out} '&nbsp;0,00%&nbsp' SKIP.

        {&out} '       </td>' SKIP
               '     </tr>' SKIP.
		
        ASSIGN tur_ttprevis = tur_ttprevis + turmas.qtprevis
               tur_ttcancel = tur_ttcancel + turmas.qtcancel
               tur_ttacresc = tur_ttacresc + turmas.qtacresc
               tur_tttransf = tur_tttransf + turmas.qttransf
               tur_ttrealiz = tur_ttrealiz + turmas.qtrealiz.
    END.
    
    {&out} '<tr>' SKIP
           '  <td class="td2" align="left">' SKIP
           '    TOTAL' SKIP
           '  </td>' SKIP
           '  <td class="tdDados2" align="center">' SKIP
                tur_ttprevis SKIP
           '  </td>' SKIP
           '  <td class="tdDados2" align="center">' SKIP
                tur_ttcancel SKIP
           '  </td>' SKIP
           '  <td class="tdDados2" align="center">' SKIP
                tur_ttacresc SKIP
           '  </td>' SKIP
           '  <td class="tdDados2" align="center">' SKIP
                tur_tttransf SKIP
           '  </td>' SKIP
           '  <td class="tdDados2" align="center">' SKIP
                tur_ttrealiz SKIP
           '  </td>' SKIP
           '  <td class="tdDados2" align="center">' SKIP.

    IF tur_ttprevis <> 0   THEN
      {&out} '&nbsp;' STRING(ROUND((tur_ttrealiz * 100) / tur_ttprevis,2),"zz9.99") '%&nbsp;' SKIP.
    ELSE
      {&out} '&nbsp;0,00%&nbsp;' SKIP.

    {&out} '       </td>' SKIP
           '     </tr>' SKIP
           '   </table>'.

END FUNCTION. /* fim turmas */

FUNCTION turmasEAD RETURNS LOGICAL ():

    {&out} '<table class="tab2" border="1" cellspacing="0" cellpadding="0" width="100%" style="paddin-top:10px; float:left;">' SKIP
           '  <tr>' SKIP
           '    <td class="td2" align="center" valign="middle" colspan="8">' SKIP
           '      TURMAS - EAD' SKIP
           '    </td>' SKIP
           '  </tr>' SKIP
           '  <tr>' SKIP
           '    <td class="td2" align="center" width="42%">' SKIP
           '      EVENTO' SKIP
           '    </td>' SKIP
           '    <td class="td2" align="center">' SKIP
           '      PREVISTO' SKIP
           '    </td>' SKIP
           '    <td class="td2" align="center">' SKIP
           '      CANCELADO' SKIP
           '    </td>' SKIP
           '    <td class="td2" align="center">' SKIP
           '      ACRESCIDO' SKIP
           '    </td>' SKIP
           '    <td class="td2" align="center">' SKIP
           '      TRANSFERIDO/RECEBIDO' SKIP
           '    </td>' SKIP
           '    <td class="td2" align="center">' SKIP
           '      REALIZADO' SKIP
           '    </td>' SKIP
           '    <td class="td2" align="center">' SKIP
           '      %' SKIP
           '    </td>' SKIP
           '  </tr>' SKIP.

    ASSIGN tur_ttprevis_ead = 0
           tur_ttcancel_ead = 0
           tur_ttacresc_ead = 0
           tur_tttransf_ead = 0
           tur_ttrealiz_ead = 0.

    FOR EACH turmasEAD NO-LOCK BY TRIM(turmasEAD.nmevento):

        {&out} '<tr>' SKIP
               '  <td class="td2" align="left">' SKIP
                    UPPER(TRIM(turmasEAD.nmevento)) SKIP
               '  </td>' SKIP
               '  <td class="tdDados2" align="center">' SKIP
                    turmasEAD.qtprevis SKIP
               '  </td>' SKIP
               '  <td class="tdDados2" align="center">' SKIP
                    turmasEAD.qtcancel SKIP
               '  </td>' SKIP
               '  <td class="tdDados2" align="center">' SKIP
                    turmasEAD.qtacresc SKIP
               '  </td>' SKIP
               '  <td class="tdDados2" align="center">' SKIP
                    turmasEAD.qttransf SKIP
               '  </td>' SKIP
               '  <td class="tdDados2" align="center">' SKIP
                    turmasEAD.qtrealiz SKIP
               '  </td>' SKIP
               '  <td class="tdDados2" align="center">' SKIP.
	
        IF   turmasEAD.qtprevis <> 0   THEN
             {&out} '&nbsp;' STRING(ROUND((turmasEAD.qtrealiz * 100) / turmasEAD.qtprevis,2),"zz9.99") '%&nbsp;' SKIP.
        ELSE
             {&out} '&nbsp;0,00%&nbsp' SKIP.

        {&out} '       </td>' SKIP
               '     </tr>' SKIP.
		
        ASSIGN tur_ttprevis_ead = tur_ttprevis_ead + turmasEAD.qtprevis
               tur_ttcancel_ead = tur_ttcancel_ead + turmasEAD.qtcancel
               tur_ttacresc_ead = tur_ttacresc_ead + turmasEAD.qtacresc
               tur_tttransf_ead = tur_tttransf_ead + turmasEAD.qttransf
               tur_ttrealiz_ead = tur_ttrealiz_ead + turmasEAD.qtrealiz.
    END.
    
    {&out} '<tr>' SKIP
           '  <td class="td2" align="left">' SKIP
           '    TOTAL' SKIP
           '  </td>' SKIP
           '  <td class="tdDados2" align="center">' SKIP
                tur_ttprevis_ead SKIP
           '  </td>' SKIP
           '  <td class="tdDados2" align="center">' SKIP
                tur_ttcancel_ead SKIP
           '  </td>' SKIP
           '  <td class="tdDados2" align="center">' SKIP
                tur_ttacresc_ead SKIP
           '  </td>' SKIP
           '  <td class="tdDados2" align="center">' SKIP
                tur_tttransf_ead SKIP
           '  </td>' SKIP
           '  <td class="tdDados2" align="center">' SKIP
                tur_ttrealiz_ead SKIP
           '  </td>' SKIP
           '  <td class="tdDados2" align="center">' SKIP.

    IF   tur_ttprevis_ead <> 0   THEN
         {&out} '&nbsp;' STRING(ROUND((tur_ttrealiz_ead * 100) / tur_ttprevis_ead,2),"zz9.99") '%&nbsp;' SKIP.
    ELSE
         {&out} '&nbsp;0,00%&nbsp;' SKIP.

    {&out} '       </td>' SKIP
           '     </tr>' SKIP
           '   </table>'.

END FUNCTION. /* fim turmas EAD */

FUNCTION turmasTotal RETURNS LOGICAL ():

    {&out} '<table class="tab2" border="1" cellspacing="0" cellpadding="0" width="100%" style="paddin-top:10px; float:left;">' SKIP
           '  <tr>' SKIP
           '    <td class="td2" align="center" valign="middle" colspan="8">' SKIP
           '      TURMAS - PRESENCIAL' SKIP
           '    </td>' SKIP
           '  </tr>' SKIP
           '  <tr>' SKIP
           '    <td class="td2" align="center">' SKIP
           '      EVENTO' SKIP
           '    </td>' SKIP
           '    <td class="td2" align="center">' SKIP
           '      PREVISTO' SKIP
           '    </td>' SKIP
           '    <td class="td2" align="center">' SKIP
           '      CANCELADO' SKIP
           '    </td>' SKIP
           '    <td class="td2" align="center">' SKIP
           '      ACRESCIDO' SKIP
           '    </td>' SKIP
           '    <td class="td2" align="center">' SKIP
           '      TRANSFERIDO/RECEBIDO' SKIP
           '    </td>' SKIP
           '    <td class="td2" align="center">' SKIP
           '      REALIZADO' SKIP
           '    </td>' SKIP
           '    <td class="td2" align="center">' SKIP
           '      %' SKIP
           '    </td>' SKIP
           '  </tr>' SKIP.

	/* Reinicializa variaveis totalizadoras */
	ASSIGN tot_tur_ttprevis = 0
	       tot_tur_ttcancel = 0
	       tot_tur_ttacresc = 0
	       tot_tur_tttransf = 0
	       tot_tur_ttrealiz = 0.
		   
	FOR EACH turmasTotal NO-LOCK BY TRIM(turmasTotal.nmevento):
        {&out} '<tr>' SKIP
               '  <td class="td2" align="left">' SKIP
                    UPPER(TRIM(turmasTotal.nmevento)) SKIP
               '  </td>' SKIP
               '  <td class="tdDados2" align="center">' SKIP
                    turmasTotal.qtprevis SKIP
               '  </td>' SKIP
               '  <td class="tdDados2" align="center">' SKIP
                    turmasTotal.qtcancel SKIP
               '  </td>' SKIP
               '  <td class="tdDados2" align="center">' SKIP
                    turmasTotal.qtacresc SKIP
               '  </td>' SKIP
               '  <td class="tdDados2" align="center">' SKIP
                    turmasTotal.qttransf SKIP
               '  </td>' SKIP
               '  <td class="tdDados2" align="center">' SKIP
                    turmasTotal.qtrealiz SKIP
               '  </td>' SKIP
               '  <td class="tdDados2" align="center">' SKIP.

        IF   turmasTotal.qtprevis <> 0   THEN
             {&out} '&nbsp;' STRING(ROUND((turmasTotal.qtrealiz * 100) / turmasTotal.qtprevis,2),"zz9.99") '%&nbsp;' SKIP.
        ELSE
             {&out} '&nbsp;0,00%&nbsp' SKIP.

        {&out} '       </td>' SKIP
               '     </tr>' SKIP.
    
		ASSIGN tot_tur_ttprevis = tot_tur_ttprevis + turmasTotal.qtprevis
           tot_tur_ttcancel = tot_tur_ttcancel + turmasTotal.qtcancel
           tot_tur_ttacresc = tot_tur_ttacresc + turmasTotal.qtacresc
           tot_tur_tttransf = tot_tur_tttransf + turmasTotal.qttransf
           tot_tur_ttrealiz = tot_tur_ttrealiz + turmasTotal.qtrealiz.
    END.
    	
    {&out} '<tr>' SKIP
           '  <td class="td2" align="left">' SKIP
           '    TOTAL' SKIP
           '  </td>' SKIP
           '  <td class="tdDados2" align="center">' SKIP
                tot_tur_ttprevis SKIP
           '  </td>' SKIP
           '  <td class="tdDados2" align="center">' SKIP
                tot_tur_ttcancel SKIP
           '  </td>' SKIP
           '  <td class="tdDados2" align="center">' SKIP
                tot_tur_ttacresc SKIP
           '  </td>' SKIP
           '  <td class="tdDados2" align="center">' SKIP
                tot_tur_tttransf SKIP
           '  </td>' SKIP
           '  <td class="tdDados2" align="center">' SKIP
                tot_tur_ttrealiz SKIP
           '  </td>' SKIP
           '  <td class="tdDados2" align="center">' SKIP.

    IF   tot_tur_ttprevis <> 0   THEN
         {&out} '&nbsp;' STRING(ROUND((tot_tur_ttrealiz * 100) / tot_tur_ttprevis,2),"zz9.99") '%&nbsp;' SKIP.
    ELSE
         {&out} '&nbsp;0,00%&nbsp;' SKIP.

    {&out} '       </td>' SKIP
           '     </tr>' SKIP
           '   </table>'.

END FUNCTION. /* fim turmasTotal */

FUNCTION turmasTotalEAD RETURNS LOGICAL ():

    {&out} '<table class="tab2" border="1" cellspacing="0" cellpadding="0" width="100%" style="paddin-top:10px; float:left;">' SKIP
           '  <tr>' SKIP
           '    <td class="td2" align="center" valign="middle" colspan="8">' SKIP
           '      TURMAS - EAD' SKIP
           '    </td>' SKIP
           '  </tr>' SKIP
           '  <tr>' SKIP
           '    <td class="td2" align="center" width="42%" >' SKIP
           '      EVENTO' SKIP
           '    </td>' SKIP
           '    <td class="td2" align="center">' SKIP
           '      PREVISTO' SKIP
           '    </td>' SKIP
           '    <td class="td2" align="center">' SKIP
           '      CANCELADO' SKIP
           '    </td>' SKIP
           '    <td class="td2" align="center">' SKIP
           '      ACRESCIDO' SKIP
           '    </td>' SKIP
           '    <td class="td2" align="center">' SKIP
           '      TRANSFERIDO/RECEBIDO' SKIP
           '    </td>' SKIP
           '    <td class="td2" align="center">' SKIP
           '      REALIZADO' SKIP
           '    </td>' SKIP
           '    <td class="td2" align="center">' SKIP
           '      %' SKIP
           '    </td>' SKIP
           '  </tr>' SKIP.

	/* Reinicializa variaveis totalizadoras */
	ASSIGN tot_tur_ttprevis_ead = 0
	       tot_tur_ttcancel_ead = 0
	       tot_tur_ttacresc_ead = 0
	       tot_tur_tttransf_ead = 0
	       tot_tur_ttrealiz_ead = 0.
		   
	FOR EACH turmasTotalEAD NO-LOCK BY TRIM(turmasTotalEAD.nmevento):
        {&out} '<tr>' SKIP
               '  <td class="td2" align="left">' SKIP
                    UPPER(TRIM(turmasTotalEAD.nmevento)) SKIP
               '  </td>' SKIP
               '  <td class="tdDados2" align="center">' SKIP
                    turmasTotalEAD.qtprevis SKIP
               '  </td>' SKIP
               '  <td class="tdDados2" align="center">' SKIP
                    turmasTotalEAD.qtcancel SKIP
               '  </td>' SKIP
               '  <td class="tdDados2" align="center">' SKIP
                    turmasTotalEAD.qtacresc SKIP
               '  </td>' SKIP
               '  <td class="tdDados2" align="center">' SKIP
                    turmasTotalEAD.qttransf SKIP
               '  </td>' SKIP
               '  <td class="tdDados2" align="center">' SKIP
                    turmasTotalEAD.qtrealiz SKIP
               '  </td>' SKIP
               '  <td class="tdDados2" align="center">' SKIP.

        IF   turmasTotalEAD.qtprevis <> 0   THEN
             {&out} '&nbsp;' STRING(ROUND((turmasTotalEAD.qtrealiz * 100) / turmasTotalEAD.qtprevis,2),"zz9.99") '%&nbsp;' SKIP.
        ELSE
             {&out} '&nbsp;0,00%&nbsp' SKIP.

        {&out} '       </td>' SKIP
               '     </tr>' SKIP.
    
		ASSIGN tot_tur_ttprevis_ead = tot_tur_ttprevis_ead + turmasTotalEAD.qtprevis
           tot_tur_ttcancel_ead = tot_tur_ttcancel_ead + turmasTotalEAD.qtcancel
           tot_tur_ttacresc_ead = tot_tur_ttacresc_ead + turmasTotalEAD.qtacresc
           tot_tur_tttransf_ead = tot_tur_tttransf_ead + turmasTotalEAD.qttransf
           tot_tur_ttrealiz_ead = tot_tur_ttrealiz_ead + turmasTotalEAD.qtrealiz.
    END.
    	
    {&out} '<tr>' SKIP
           '  <td class="td2" align="left">' SKIP
           '    TOTAL' SKIP
           '  </td>' SKIP
           '  <td class="tdDados2" align="center">' SKIP
                tot_tur_ttprevis_ead SKIP
           '  </td>' SKIP
           '  <td class="tdDados2" align="center">' SKIP
                tot_tur_ttcancel_ead SKIP
           '  </td>' SKIP
           '  <td class="tdDados2" align="center">' SKIP
                tot_tur_ttacresc_ead SKIP
           '  </td>' SKIP
           '  <td class="tdDados2" align="center">' SKIP
                tot_tur_tttransf_ead SKIP
           '  </td>' SKIP
           '  <td class="tdDados2" align="center">' SKIP
                tot_tur_ttrealiz_ead SKIP
           '  </td>' SKIP
           '  <td class="tdDados2" align="center">' SKIP.

    IF   tot_tur_ttprevis_ead <> 0   THEN
         {&out} '&nbsp;' STRING(ROUND((tot_tur_ttrealiz_ead * 100) / tot_tur_ttprevis_ead,2),"zz9.99") '%&nbsp;' SKIP.
    ELSE
         {&out} '&nbsp;0,00%&nbsp;' SKIP.

    {&out} '       </td>' SKIP
           '     </tr>' SKIP
           '   </table>'.

END FUNCTION. /* fim turmasTotalEAD */

FUNCTION geralTurmas RETURNS LOGICAL ():

    {&out} '<table class="tab2" border="1" cellspacing="0" cellpadding="0" width="100%" style="paddin-top:10px; float:left;">' SKIP
           '  <tr>' SKIP
           '    <td class="td2" align="center" valign="middle" colspan="8">' SKIP
           '      TOTAL DE TURMAS - (PRESENCIAL + EAD)' SKIP
           '    </td>' SKIP
           '  </tr>' SKIP
           '  <tr>' SKIP
           '    <td class="td2" align="center">' SKIP
           '      &nbsp;' SKIP
           '    </td>' SKIP
           '    <td class="td2" align="center">' SKIP
           '      PREVISTO' SKIP
           '    </td>' SKIP
           '    <td class="td2" align="center">' SKIP
           '      CANCELADO' SKIP
           '    </td>' SKIP
           '    <td class="td2" align="center">' SKIP
           '      ACRESCIDO' SKIP
           '    </td>' SKIP
           '    <td class="td2" align="center">' SKIP
           '      TRANSFERIDO/RECEBIDO' SKIP
           '    </td>' SKIP
           '    <td class="td2" align="center">' SKIP
           '      REALIZADO' SKIP
           '    </td>' SKIP
           '    <td class="td2" align="center">' SKIP
           '      %' SKIP
           '    </td>' SKIP
           '  </tr>' SKIP    
           '  <tr>' SKIP
           '    <td class="td2" align="center">' SKIP
           '      GERAL TURMAS' SKIP
           '    </td>' SKIP
           '    <td class="tdDados2" align="center">' SKIP
                  tur_ttprevis + tur_ttprevis_ead SKIP
           '    </td>' SKIP
           '    <td class="tdDados2" align="center">' SKIP
                  tur_ttcancel + tur_ttcancel_ead SKIP
           '    </td>' SKIP
           '    <td class="tdDados2" align="center">' SKIP
                  tur_ttacresc + tur_ttacresc_ead SKIP
           '    </td>' SKIP
           '    <td class="tdDados2" align="center">' SKIP
                  tur_tttransf + tur_tttransf_ead SKIP
           '    </td>' SKIP
           '    <td class="tdDados2" align="center">' SKIP
                  tur_ttrealiz + tur_ttrealiz_ead SKIP
           '    </td>' SKIP
           '    <td class="tdDados2" align="center">' SKIP.

    IF (tur_ttprevis + tur_ttprevis_ead) <> 0   THEN
      {&out} '&nbsp;' STRING(ROUND(((tur_ttrealiz + tur_ttrealiz_ead) * 100) / (tur_ttprevis + tur_ttprevis_ead),2),"zz9.99") '%&nbsp;' SKIP.
    ELSE
      {&out} '&nbsp;0,00%&nbsp;' SKIP.

    {&out} '    </td>' SKIP
           '  </tr>' SKIP
           '</table>'.

END FUNCTION. /* fim geralTurmas */

FUNCTION geralTurmasTotal RETURNS LOGICAL ():

    {&out} '<table class="tab2" border="1" cellspacing="0" cellpadding="0" width="100%" style="paddin-top:10px; float:left;">' SKIP
           '  <tr>' SKIP
           '    <td class="td2" align="center" valign="middle" colspan="8">' SKIP
           '      TOTAL DE TURMAS - (PRESENCIAL + EAD)' SKIP
           '    </td>' SKIP
           '  </tr>' SKIP
           '  <tr>' SKIP
           '    <td class="td2" align="center">' SKIP
           '      &nbsp;' SKIP
           '    </td>' SKIP
           '    <td class="td2" align="center">' SKIP
           '      PREVISTO' SKIP
           '    </td>' SKIP
           '    <td class="td2" align="center">' SKIP
           '      CANCELADO' SKIP
           '    </td>' SKIP
           '    <td class="td2" align="center">' SKIP
           '      ACRESCIDO' SKIP
           '    </td>' SKIP
           '    <td class="td2" align="center">' SKIP
           '      TRANSFERIDO/RECEBIDO' SKIP
           '    </td>' SKIP
           '    <td class="td2" align="center">' SKIP
           '      REALIZADO' SKIP
           '    </td>' SKIP
           '    <td class="td2" align="center">' SKIP
           '      %' SKIP
           '    </td>' SKIP
           '  </tr>' SKIP        
           '  <tr>' SKIP
           '    <td class="td2" align="center">' SKIP
           '      GERAL TURMAS' SKIP
           '    </td>' SKIP
           '  <td class="tdDados2" align="center">' SKIP
                tot_tur_ttprevis + tot_tur_ttprevis_ead SKIP
           '  </td>' SKIP
           '  <td class="tdDados2" align="center">' SKIP
                tot_tur_ttcancel + tot_tur_ttcancel_ead SKIP
           '  </td>' SKIP
           '  <td class="tdDados2" align="center">' SKIP
                tot_tur_ttacresc + tot_tur_ttacresc_ead SKIP
           '  </td>' SKIP
           '  <td class="tdDados2" align="center">' SKIP
                tot_tur_tttransf + tot_tur_tttransf_ead SKIP
           '  </td>' SKIP
           '  <td class="tdDados2" align="center">' SKIP
                tot_tur_ttrealiz + tot_tur_ttrealiz_ead SKIP
           '  </td>' SKIP
           '  <td class="tdDados2" align="center">' SKIP.

    IF (tot_tur_ttprevis + tot_tur_ttprevis_ead) <> 0   THEN
         {&out} '&nbsp;' STRING(ROUND(((tot_tur_ttrealiz + tot_tur_ttrealiz_ead) * 100) / (tot_tur_ttprevis + tot_tur_ttprevis_ead),2),"zz9.99") '%&nbsp;' SKIP.
    ELSE
         {&out} '&nbsp;0,00%&nbsp;' SKIP.

    {&out} '       </td>' SKIP
           '     </tr>' SKIP
           '   </table>'.

END FUNCTION. /* fim geralTurmasTotal */

FUNCTION participantes RETURNS LOGICAL ():

    {&out} '   <table class="tab2" border="1" cellspacing="0" cellpadding="0" width="100%" align="left" style="paddin-top:10px; float:left;">' SKIP
           '   <tr>' SKIP
           '     <td class="td2" align="center" valign="middle" colspan="8">' SKIP
           '       PARTICIPANTES - PRESENCIAL' SKIP
           '     </td>' SKIP
           '   </tr>' SKIP
           '   <tr>' SKIP
           '     <td class="td2" align="left" width="42%">' SKIP
           '       EVENTO' SKIP
           '     </td>' SKIP
           '     <td class="td2" align="center">' SKIP
           '       PREVISTO' SKIP
           '     </td>' SKIP
           '     <td class="td2" align="center">' SKIP
           '       COOPERADOS' SKIP
           '     </td>' SKIP
           '     <td class="td2" align="center">' SKIP
           '       COMUNIDADE' SKIP
           '     </td>' SKIP
           '     <td class="td2" align="center">' SKIP
           '       TOTAL' SKIP
           '     </td>' SKIP
           '     <td class="td2" align="center">' SKIP
           '       %' SKIP
           '     </td>' SKIP
           '   </tr>' SKIP.

    ASSIGN prt_ttprevis = 0
           prt_ttrealiz = 0
           prt_ttrecoop = 0
           prt_ttrecomu = 0.
    
    FOR EACH participantes NO-LOCK BY TRIM(participantes.nmevento):

        {&out} '<tr>' SKIP
               '  <td class="td2" align="left">' SKIP
                    UPPER(TRIM(participantes.nmevento)) SKIP
               '  </td>' SKIP
               '  <td class="tdDados2" align="center">' SKIP
                    participantes.qtprevis SKIP
               '  </td>' SKIP
               '  <td class="tdDados2" align="center">' SKIP
                    participantes.qtrecoop SKIP
               '  </td>' SKIP
               '  <td class="tdDados2" align="center">' SKIP
                    participantes.qtrecomu SKIP
               '  </td>' SKIP
               '  <td class="tdDados2" align="center">' SKIP
                    participantes.qtrealiz SKIP
               '  </td>' SKIP
               '  <td class="tdDados2" align="center">' SKIP.

        IF   participantes.qtprevis <> 0   THEN
             {&out} '&nbsp;' STRING(ROUND((participantes.qtrealiz * 100) / participantes.qtprevis,2),"zz9.99") '%&nbsp;' SKIP.
        ELSE
             {&out} '&nbsp;0,00%&nbsp;' SKIP.

        {&out} '       </td>' SKIP
               '     </tr>' SKIP.
     
        ASSIGN prt_ttprevis = prt_ttprevis + participantes.qtprevis
               prt_ttrealiz = prt_ttrealiz + participantes.qtrealiz
               prt_ttrecoop = prt_ttrecoop + participantes.qtrecoop
               prt_ttrecomu = prt_ttrecomu + participantes.qtrecomu.
    END.
    
    {&out} '<tr>' SKIP
           '  <td class="td2" align="left">' SKIP
           '    TOTAL' SKIP
           '  </td>' SKIP
           '  <td class="tdDados2" align="center">' SKIP
                prt_ttprevis SKIP
           '  </td>' SKIP
           '  <td class="tdDados2" align="center">' SKIP
                prt_ttrecoop SKIP
           '  </td>' SKIP
           '  <td class="tdDados2" align="center">' SKIP
                prt_ttrecomu SKIP
           '  </td>' SKIP
           '  <td class="tdDados2" align="center">' SKIP
                prt_ttrealiz SKIP
           '  </td>' SKIP
           '  <td class="tdDados2" align="center">' SKIP.

    IF   prt_ttprevis <> 0   THEN
         {&out} '&nbsp;' STRING(ROUND((prt_ttrealiz * 100) / prt_ttprevis,2),"zz9.99") '%&nbsp;' SKIP.
    ELSE
         {&out} '&nbsp;0,00%&nbsp;' SKIP.

    {&out} '       </td>' SKIP
           '     </tr>' SKIP
           '   </table>'.

END FUNCTION. /* fim participantes */

FUNCTION participantesEAD RETURNS LOGICAL ():

    {&out} '  <table class="tab2" border="1" cellspacing="0" cellpadding="0" width="100%" align="left" style="paddin-top:10px; float:left;">' SKIP
           '   <tr>' SKIP
           '     <td class="td2" align="center" valign="middle" colspan="8">' SKIP
           '       PARTICIPANTES - EAD' SKIP
           '     </td>' SKIP
           '   </tr>' SKIP
           '   <tr>' SKIP
           '     <td class="td2" align="left" width="42%">' SKIP
           '       EVENTO' SKIP
           '     </td>' SKIP
           '     <td class="td2" align="center">' SKIP
           '       PREVISTO' SKIP
           '     </td>' SKIP
           '     <td class="td2" align="center">' SKIP
           '       COOPERADOS' SKIP
           '     </td>' SKIP
           '     <td class="td2" align="center">' SKIP
           '       COMUNIDADE' SKIP
           '     </td>' SKIP
           '     <td class="td2" align="center">' SKIP
           '       TOTAL' SKIP
           '     </td>' SKIP
           '     <td class="td2" align="center">' SKIP
           '       %' SKIP
           '     </td>' SKIP
           '   </tr>' SKIP.

    ASSIGN prt_ttprevis_ead = 0
           prt_ttrealiz_ead = 0
           prt_ttrecoop_ead = 0
           prt_ttrecomu_ead = 0.
    
    FOR EACH participantesEAD NO-LOCK BY TRIM(participantesEAD.nmevento):

        {&out} '<tr>' SKIP
               '  <td class="td2" align="left">' SKIP
                    UPPER(TRIM(participantesEAD.nmevento)) SKIP
               '  </td>' SKIP
               '  <td class="tdDados2" align="center">' SKIP
                    participantesEAD.qtprevis SKIP
               '  </td>' SKIP
               '  <td class="tdDados2" align="center">' SKIP
                    participantesEAD.qtrecoop SKIP
               '  </td>' SKIP
               '  <td class="tdDados2" align="center">' SKIP
                    participantesEAD.qtrecomu SKIP
               '  </td>' SKIP
               '  <td class="tdDados2" align="center">' SKIP
                    participantesEAD.qtrealiz SKIP
               '  </td>' SKIP
               '  <td class="tdDados2" align="center">' SKIP.

        IF   participantesEAD.qtprevis <> 0   THEN
             {&out} '&nbsp;' STRING(ROUND((participantesEAD.qtrealiz * 100) / participantesEAD.qtprevis,2),"zz9.99") '%&nbsp;' SKIP.
        ELSE
             {&out} '&nbsp;0,00%&nbsp;' SKIP.

        {&out} '       </td>' SKIP
               '     </tr>' SKIP.
     
        ASSIGN prt_ttprevis_ead = prt_ttprevis_ead + participantesEAD.qtprevis
               prt_ttrealiz_ead = prt_ttrealiz_ead + participantesEAD.qtrealiz
               prt_ttrecoop_ead = prt_ttrecoop_ead + participantesEAD.qtrecoop
               prt_ttrecomu_ead = prt_ttrecomu_ead + participantesEAD.qtrecomu.
    END.
    
    {&out} '<tr>' SKIP
           '  <td class="td2" align="left">' SKIP
           '    TOTAL' SKIP
           '  </td>' SKIP
           '  <td class="tdDados2" align="center">' SKIP
                prt_ttprevis_ead SKIP
           '  </td>' SKIP
           '  <td class="tdDados2" align="center">' SKIP
                prt_ttrecoop_ead SKIP
           '  </td>' SKIP
           '  <td class="tdDados2" align="center">' SKIP
                prt_ttrecomu_ead SKIP
           '  </td>' SKIP
           '  <td class="tdDados2" align="center">' SKIP
                prt_ttrealiz_ead SKIP
           '  </td>' SKIP
           '  <td class="tdDados2" align="center">' SKIP.

    IF   prt_ttprevis_ead <> 0   THEN
         {&out} '&nbsp;' STRING(ROUND((prt_ttrealiz_ead * 100) / prt_ttprevis_ead,2),"zz9.99") '%&nbsp;' SKIP.
    ELSE
         {&out} '&nbsp;0,00%&nbsp;' SKIP.

    {&out} '       </td>' SKIP
           '     </tr>' SKIP
           '   </table>'.

END FUNCTION. /* fim participantes EAD */

FUNCTION participantesTotal RETURNS LOGICAL ():

    {&out} '<br><table class="tab2" border="1" cellspacing="0" cellpadding="0" width="100%" align="left" style="paddin-top:10px; float:left;">' SKIP
           '    <tr>' SKIP
           '      <td class="td2" align="center" valign="middle" colspan="8">' SKIP
           '        PARTICIPANTES - PRESENCIAL' SKIP
           '      </td>' SKIP
           '    </tr>' SKIP
           '    <tr>' SKIP
           '      <td class="td2" align="left">' SKIP
           '        EVENTO' SKIP
           '      </td>' SKIP
           '      <td class="td2" align="center">' SKIP
           '        PREVISTO' SKIP
           '      </td>' SKIP
           '      <td class="td2" align="center">' SKIP
           '        COOPERADOS' SKIP
           '      </td>' SKIP
           '      <td class="td2" align="center">' SKIP
           '        COMUNIDADE' SKIP
           '      </td>' SKIP
           '      <td class="td2" align="center">' SKIP
           '        TOTAL' SKIP
           '      </td>' SKIP
           '      <td class="td2" align="center">' SKIP
           '        %' SKIP
           '      </td>' SKIP
           '    </tr>' SKIP.
    
	/* Reinicializa variaveis */
	ASSIGN tot_prt_ttprevis = 0
	       tot_prt_ttrealiz = 0
	       tot_prt_ttrecoop = 0
	       tot_prt_ttrecomu = 0.
		   
	FOR EACH participantesTotal NO-LOCK BY TRIM(participantesTotal.nmevento):
	
        {&out} '<tr>' SKIP
               '  <td class="td2" align="left">' SKIP
                    UPPER(TRIM(participantesTotal.nmevento)) SKIP
               '  </td>' SKIP
               '  <td class="tdDados2" align="center">' SKIP
                    participantesTotal.qtprevis SKIP
               '  </td>' SKIP
               '  <td class="tdDados2" align="center">' SKIP
                    participantesTotal.qtrecoop SKIP
               '  </td>' SKIP
               '  <td class="tdDados2" align="center">' SKIP
                    participantesTotal.qtrecomu SKIP
               '  </td>' SKIP
               '  <td class="tdDados2" align="center">' SKIP
                    participantesTotal.qtrealiz SKIP
               '  </td>' SKIP
               '  <td class="tdDados2" align="center">' SKIP.

        IF participantesTotal.qtprevis <> 0 THEN
			{&out} '&nbsp;' STRING(ROUND((participantesTotal.qtrealiz * 100) / participantesTotal.qtprevis,2),"zz9.99") '%&nbsp;' SKIP.
        ELSE
			{&out} '&nbsp;0,00%&nbsp;' SKIP.

        {&out} '       </td>' SKIP
               '     </tr>' SKIP.
     
        ASSIGN tot_prt_ttprevis = tot_prt_ttprevis + participantesTotal.qtprevis
               tot_prt_ttrealiz = tot_prt_ttrealiz + participantesTotal.qtrealiz
               tot_prt_ttrecoop = tot_prt_ttrecoop + participantesTotal.qtrecoop
               tot_prt_ttrecomu = tot_prt_ttrecomu + participantesTotal.qtrecomu.
    END.
    
    {&out} '<tr>' SKIP
           '  <td class="td2" align="left">' SKIP
           '    TOTAL' SKIP
           '  </td>' SKIP
           '  <td class="tdDados2" align="center">' SKIP
                tot_prt_ttprevis SKIP
           '  </td>' SKIP
           '  <td class="tdDados2" align="center">' SKIP
                tot_prt_ttrecoop SKIP
           '  </td>' SKIP
           '  <td class="tdDados2" align="center">' SKIP
                tot_prt_ttrecomu SKIP
           '  </td>' SKIP
           '  <td class="tdDados2" align="center">' SKIP
                tot_prt_ttrealiz SKIP
           '  </td>' SKIP
           '  <td class="tdDados2" align="center">' SKIP.

    IF tot_prt_ttprevis <> 0 THEN
		{&out} '&nbsp;' STRING(ROUND((tot_prt_ttrealiz * 100) / tot_prt_ttprevis,2),"zz9.99") '%&nbsp;' SKIP.
    ELSE
		{&out} '&nbsp;0,00%&nbsp;' SKIP.

    {&out} '       </td>' SKIP
           '     </tr>' SKIP
           '   </table>'.

END FUNCTION. /* fim participantesTotal */

FUNCTION participantesTotalEAD RETURNS LOGICAL ():

    {&out} '<br><table class="tab2" border="1" cellspacing="0" cellpadding="0" width="100%" align="left" style="paddin-top:10px; float:left;">' SKIP
           '    <tr>' SKIP
           '      <td class="td2" align="center" valign="middle" colspan="8">' SKIP
           '        PARTICIPANTES - EAD' SKIP
           '      </td>' SKIP
           '    </tr>' SKIP
           '    <tr>' SKIP
           '      <td class="td2" align="left">' SKIP
           '        EVENTO' SKIP
           '      </td>' SKIP
           '      <td class="td2" align="center">' SKIP
           '        PREVISTO' SKIP
           '      </td>' SKIP
           '      <td class="td2" align="center">' SKIP
           '        COOPERADOS' SKIP
           '      </td>' SKIP
           '      <td class="td2" align="center">' SKIP
           '        COMUNIDADE' SKIP
           '      </td>' SKIP
           '      <td class="td2" align="center">' SKIP
           '        TOTAL' SKIP
           '      </td>' SKIP
           '      <td class="td2" align="center">' SKIP
           '        %' SKIP
           '      </td>' SKIP
           '    </tr>' SKIP.
    
	/* Reinicializa variaveis */
	ASSIGN tot_prt_ttprevis_ead = 0
	       tot_prt_ttrealiz_ead = 0
	       tot_prt_ttrecoop_ead = 0
	       tot_prt_ttrecomu_ead = 0.
		   
	FOR EACH participantesTotalEAD NO-LOCK BY TRIM(participantesTotalEAD.nmevento):
	
        {&out} '<tr>' SKIP
               '  <td class="td2" align="left">' SKIP
                    UPPER(TRIM(participantesTotalEAD.nmevento)) SKIP
               '  </td>' SKIP
               '  <td class="tdDados2" align="center">' SKIP
                    participantesTotalEAD.qtprevis SKIP
               '  </td>' SKIP
               '  <td class="tdDados2" align="center">' SKIP
                    participantesTotalEAD.qtrecoop SKIP
               '  </td>' SKIP
               '  <td class="tdDados2" align="center">' SKIP
                    participantesTotalEAD.qtrecomu SKIP
               '  </td>' SKIP
               '  <td class="tdDados2" align="center">' SKIP
                    participantesTotalEAD.qtrealiz SKIP
               '  </td>' SKIP
               '  <td class="tdDados2" align="center">' SKIP.

        IF participantesTotalEAD.qtprevis <> 0 THEN
			{&out} '&nbsp;' STRING(ROUND((participantesTotalEAD.qtrealiz * 100) / participantesTotalEAD.qtprevis,2),"zz9.99") '%&nbsp;' SKIP.
        ELSE
			{&out} '&nbsp;0,00%&nbsp;' SKIP.

        {&out} '       </td>' SKIP
               '     </tr>' SKIP.
     
        ASSIGN tot_prt_ttprevis_ead = tot_prt_ttprevis_ead + participantesTotalEAD.qtprevis
               tot_prt_ttrealiz_ead = tot_prt_ttrealiz_ead + participantesTotalEAD.qtrealiz
               tot_prt_ttrecoop_ead = tot_prt_ttrecoop_ead + participantesTotalEAD.qtrecoop
               tot_prt_ttrecomu_ead = tot_prt_ttrecomu_ead + participantesTotalEAD.qtrecomu.
    END.
    
    {&out} '<tr>' SKIP
           '  <td class="td2" align="left">' SKIP
           '    TOTAL' SKIP
           '  </td>' SKIP
           '  <td class="tdDados2" align="center">' SKIP
                tot_prt_ttprevis_ead SKIP
           '  </td>' SKIP
           '  <td class="tdDados2" align="center">' SKIP
                tot_prt_ttrecoop_ead SKIP
           '  </td>' SKIP
           '  <td class="tdDados2" align="center">' SKIP
                tot_prt_ttrecomu_ead SKIP
           '  </td>' SKIP
           '  <td class="tdDados2" align="center">' SKIP
                tot_prt_ttrealiz_ead SKIP
           '  </td>' SKIP
           '  <td class="tdDados2" align="center">' SKIP.

    IF tot_prt_ttprevis_ead <> 0 THEN
		{&out} '&nbsp;' STRING(ROUND((tot_prt_ttrealiz_ead * 100) / tot_prt_ttprevis_ead,2),"zz9.99") '%&nbsp;' SKIP.
    ELSE
		{&out} '&nbsp;0,00%&nbsp;' SKIP.

    {&out} '       </td>' SKIP
           '     </tr>' SKIP
           '   </table>'.

END FUNCTION. /* fim participantesTotal EAD*/

FUNCTION geralParticipantes RETURNS LOGICAL ():

    {&out} '<table class="tab2" border="1" cellspacing="0" cellpadding="0" width="100%" style="paddin-top:10px; float:left;">' SKIP    
           '    <tr>' SKIP
           '      <td class="td2" align="center" valign="middle" colspan="8">' SKIP
           '        TOTAL DE PARTICIPANTES - (PRESENCIAL + EAD)' SKIP
           '      </td>' SKIP
           '    </tr>' SKIP
           '    <tr>' SKIP
           '      <td class="td2" align="left">' SKIP
           '        &nbsp' SKIP
           '      </td>' SKIP
           '      <td class="td2" align="center">' SKIP
           '        PREVISTO' SKIP
           '      </td>' SKIP
           '      <td class="td2" align="center">' SKIP
           '        COOPERADOS' SKIP
           '      </td>' SKIP
           '      <td class="td2" align="center">' SKIP
           '        COMUNIDADE' SKIP
           '      </td>' SKIP
           '      <td class="td2" align="center">' SKIP
           '        TOTAL' SKIP
           '      </td>' SKIP
           '      <td class="td2" align="center">' SKIP
           '        %' SKIP
           '      </td>' SKIP
           '    </tr>' SKIP    
           '  <tr>' SKIP
           '    <td class="td2" align="center">' SKIP
           '      GERAL PARTICIPANTES' SKIP
           '    </td>' SKIP
           '  <td class="tdDados2" align="center">' SKIP
                prt_ttprevis + prt_ttprevis_ead SKIP
           '  </td>' SKIP
           '  <td class="tdDados2" align="center">' SKIP
                prt_ttrecoop + prt_ttrecoop_ead SKIP
           '  </td>' SKIP
           '  <td class="tdDados2" align="center">' SKIP
                prt_ttrecomu + prt_ttrecomu_ead SKIP
           '  </td>' SKIP
           '  <td class="tdDados2" align="center">' SKIP
                prt_ttrealiz + prt_ttrealiz_ead SKIP
           '  </td>' SKIP
           '  <td class="tdDados2" align="center">' SKIP.

    IF (prt_ttprevis + prt_ttprevis_ead) <> 0   THEN
         {&out} '&nbsp;' STRING(ROUND(((prt_ttrealiz + prt_ttrealiz_ead) * 100) / (prt_ttprevis + prt_ttprevis_ead),2),"zz9.99") '%&nbsp;' SKIP.
    ELSE
         {&out} '&nbsp;0,00%&nbsp;' SKIP.

    {&out} '       </td>' SKIP
           '     </tr>' SKIP
           '   </table>'.

END FUNCTION. /* fim geralParticipantes */

FUNCTION geralParticipantesTotal RETURNS LOGICAL ():

    {&out} '<table class="tab2" border="1" cellspacing="0" cellpadding="0" width="100%" style="paddin-top:10px; float:left;">' SKIP
           '    <tr>' SKIP
           '      <td class="td2" align="center" valign="middle" colspan="8">' SKIP
           '        TOTAL DE PARTICIPANTES - (PRESENCIAL + EAD)' SKIP
           '      </td>' SKIP
           '    </tr>' SKIP
           '    <tr>' SKIP
           '      <td class="td2" align="left">' SKIP
           '        &nbsp' SKIP
           '      </td>' SKIP
           '      <td class="td2" align="center">' SKIP
           '        PREVISTO' SKIP
           '      </td>' SKIP
           '      <td class="td2" align="center">' SKIP
           '        COOPERADOS' SKIP
           '      </td>' SKIP
           '      <td class="td2" align="center">' SKIP
           '        COMUNIDADE' SKIP
           '      </td>' SKIP
           '      <td class="td2" align="center">' SKIP
           '        TOTAL' SKIP
           '      </td>' SKIP
           '      <td class="td2" align="center">' SKIP
           '        %' SKIP
           '      </td>' SKIP
           '    </tr>' SKIP      
           '  <tr>' SKIP
           '    <td class="td2" align="center">' SKIP
           '      GERAL PARTICIPANTES' SKIP
           '    </td>' SKIP           
           '  <td class="tdDados2" align="center">' SKIP
                tot_prt_ttprevis + tot_prt_ttprevis_ead SKIP
           '  </td>' SKIP
           '  <td class="tdDados2" align="center">' SKIP
               tot_prt_ttrecoop + tot_prt_ttrecoop_ead SKIP
           '  </td>' SKIP
           '  <td class="tdDados2" align="center">' SKIP
               tot_prt_ttrecomu + tot_prt_ttrecomu_ead SKIP
           '  </td>' SKIP
           '  <td class="tdDados2" align="center">' SKIP
               tot_prt_ttrealiz + tot_prt_ttrealiz_ead SKIP
           '  </td>' SKIP
           '  <td class="tdDados2" align="center">' SKIP.

            IF (tot_prt_ttprevis + tot_prt_ttprevis_ead) <> 0   THEN
                 {&out} '&nbsp;' STRING(ROUND(((tot_prt_ttrealiz + tot_prt_ttrealiz_ead) * 100) / (tot_prt_ttprevis + tot_prt_ttprevis_ead),2),"zz9.99") '%&nbsp;' SKIP.
            ELSE
                 {&out} '&nbsp;0,00%&nbsp;' SKIP.
           {&out} '    </td>' SKIP
           '  </tr>' SKIP
           '</table>'.

END FUNCTION. /* fim geralParticipantesTotal */

FUNCTION montaDadosTotal RETURNS LOGICAL ():
	
	/** TOTAL DE TURMAS **/
	/* Inicializa variaveis totalizadoras */
	ASSIGN tot_tur_ttprevis = 0
	       tot_tur_ttcancel = 0
	       tot_tur_ttacresc = 0
	       tot_tur_tttransf = 0
	       tot_tur_ttrealiz = 0.
		
    FOR EACH turmas NO-LOCK BREAK BY turmas.cdevento:
		
      FIND turmasTotal WHERE turmasTotal.cdevento = turmas.cdevento EXCLUSIVE-LOCK NO-ERROR.
      
      /*IF FIRST-OF(turmas.cdevento) THEN*/
      IF NOT AVAIL turmasTotal THEN
        DO:
          /* Zera variaveis */
          ASSIGN tot_tur_ttprevis = 0
                 tot_tur_ttcancel = 0
                 tot_tur_ttacresc = 0
                 tot_tur_tttransf = 0
                 tot_tur_ttrealiz = 0.
               
          FIND FIRST crapedp WHERE crapedp.cdcooper = 0
                               AND crapedp.cdevento = turmas.cdevento
                               AND (crapedp.nrseqpgm = INT(nrseqpgm)      
                                OR INT(nrseqpgm) = 0) NO-LOCK NO-ERROR NO-WAIT.
          
          CREATE turmasTotal.
          ASSIGN turmasTotal.cdevento = turmas.cdevento
                 turmasTotal.nmevento = UPPER(TRIM(crapedp.nmevento))
                 turmasTotal.tpevento = crapedp.tpevento.
        END.
              
      ASSIGN turmasTotal.qtprevis = turmasTotal.qtprevis + turmas.qtprevis
             turmasTotal.qtcancel = turmasTotal.qtcancel + turmas.qtcancel
             turmasTotal.qtacresc = turmasTotal.qtacresc + turmas.qtacresc
             turmasTotal.qttransf = turmasTotal.qttransf + turmas.qttransf
             turmasTotal.qtrealiz = turmasTotal.qtrealiz + turmas.qtrealiz.
            
    END.
    /** FIM TOTAL TURMA **/
  
  /** TOTAL DE TURMAS EAD**/
	/* Inicializa variaveis totalizadoras */
	ASSIGN tot_tur_ttprevis_ead = 0
	       tot_tur_ttcancel_ead = 0
	       tot_tur_ttacresc_ead = 0
	       tot_tur_tttransf_ead = 0
	       tot_tur_ttrealiz_ead = 0.
		
    FOR EACH turmasEAD NO-LOCK BREAK BY turmasEAD.cdevento:
		
		FIND turmasTotalEAD WHERE turmasTotalEAD.cdevento = turmasEAD.cdevento EXCLUSIVE-LOCK NO-ERROR.
		
		/*IF FIRST-OF(turmas.cdevento) THEN*/
		IF NOT AVAILABLE turmasTotalEAD THEN
			DO:
				/* Zera variaveis */
				ASSIGN tot_tur_ttprevis_ead = 0
					     tot_tur_ttcancel_ead = 0
					     tot_tur_ttacresc_ead = 0
					     tot_tur_tttransf_ead = 0
					     tot_tur_ttrealiz_ead = 0.
					   
				FIND FIRST crapedp WHERE crapedp.cdcooper = 0
                             AND crapedp.cdevento = turmasEAD.cdevento
                             AND (crapedp.nrseqpgm = INT(nrseqpgm)      
                              OR INT(nrseqpgm) = 0) NO-LOCK NO-ERROR NO-WAIT.
				
				CREATE turmasTotalEAD.
				ASSIGN turmasTotalEAD.cdevento = turmasEAD.cdevento
               turmasTotalEAD.nmevento = UPPER(TRIM(crapedp.nmevento))
               turmasTotalEAD.tpevento = crapedp.tpevento.
			END.
						
		ASSIGN turmasTotalEAD.qtprevis = turmasTotalEAD.qtprevis + turmasEAD.qtprevis
           turmasTotalEAD.qtcancel = turmasTotalEAD.qtcancel + turmasEAD.qtcancel
           turmasTotalEAD.qtacresc = turmasTotalEAD.qtacresc + turmasEAD.qtacresc
           turmasTotalEAD.qttransf = turmasTotalEAD.qttransf + turmasEAD.qttransf
           turmasTotalEAD.qtrealiz = turmasTotalEAD.qtrealiz + turmasEAD.qtrealiz.
					
	END.
	/** FIM TOTAL TURMA EAD **/
	
	/** TOTAL PARTICIPANTES **/
	/* Inicializa variaveis */
	ASSIGN tot_prt_ttprevis = 0
	       tot_prt_ttrealiz = 0
	       tot_prt_ttrecoop = 0
	       tot_prt_ttrecomu = 0.
	
    FOR EACH participantes NO-LOCK BREAK BY participantes.cdevento:
		
		FIND FIRST participantesTotal WHERE participantesTotal.cdevento = participantes.cdevento EXCLUSIVE-LOCK NO-ERROR.
		
		/*IF FIRST-OF(participantes.cdevento) THEN*/
		IF NOT AVAIL participantesTotal THEN
			DO:
				/* Zera variaveis */
				ASSIGN tot_prt_ttprevis = 0
               tot_prt_ttrealiz = 0
               tot_prt_ttrecoop = 0
               tot_prt_ttrecomu = 0.
		   
				FIND crapedp WHERE crapedp.cdcooper = 0
                       AND crapedp.cdevento = participantes.cdevento
                       AND (crapedp.nrseqpgm = INT(nrseqpgm)      
                        OR INT(nrseqpgm) = 0) NO-LOCK NO-ERROR NO-WAIT.
				
				CREATE participantesTotal.
				ASSIGN participantesTotal.cdevento = participantes.cdevento
               participantesTotal.nmevento = UPPER(TRIM(crapedp.nmevento))
               participantesTotal.tpevento = crapedp.tpevento.
			END.
		
		ASSIGN participantesTotal.qtprevis = participantesTotal.qtprevis + participantes.qtprevis
           participantesTotal.qtrealiz = participantesTotal.qtrealiz + participantes.qtrealiz
           participantesTotal.qtrecoop = participantesTotal.qtrecoop + participantes.qtrecoop
           participantesTotal.qtrecomu = participantesTotal.qtrecomu + participantes.qtrecomu.
			   
	END.
	/** FIM TOTAL PARTICIPANTE **/
  
  /** TOTAL PARTICIPANTES EAD**/
	/* Inicializa variaveis */
	ASSIGN tot_prt_ttprevis_ead = 0
	       tot_prt_ttrealiz_ead = 0
	       tot_prt_ttrecoop_ead = 0
	       tot_prt_ttrecomu_ead = 0.
	
    FOR EACH participantesEAD NO-LOCK BREAK BY participantesEAD.cdevento:
		
		FIND FIRST participantesTotalEAD WHERE participantesTotalEAD.cdevento = participantesEAD.cdevento EXCLUSIVE-LOCK NO-ERROR.
		
		/*IF FIRST-OF(participantes.cdevento) THEN*/
		IF NOT AVAILABLE participantesTotalEAD THEN
			DO:
				/* Zera variaveis */
				ASSIGN tot_prt_ttprevis_ead = 0
               tot_prt_ttrealiz_ead = 0
               tot_prt_ttrecoop_ead = 0
               tot_prt_ttrecomu_ead = 0.
		   
				FIND crapedp WHERE crapedp.cdcooper = 0
                       AND crapedp.cdevento = participantesEAD.cdevento
                       AND (crapedp.nrseqpgm = INT(nrseqpgm)      
                        OR INT(nrseqpgm) = 0) NO-LOCK NO-ERROR NO-WAIT.
				
				CREATE participantesTotalEAD.
				ASSIGN participantesTotalEAD.cdevento = participantesEAD.cdevento
               participantesTotalEAD.nmevento = UPPER(TRIM(crapedp.nmevento))
               participantesTotalEAD.tpevento = crapedp.tpevento.
			END.
		
		ASSIGN participantesTotalEAD.qtprevis = participantesTotalEAD.qtprevis + participantesEAD.qtprevis
           participantesTotalEAD.qtrealiz = participantesTotalEAD.qtrealiz + participantesEAD.qtrealiz
           participantesTotalEAD.qtrecoop = participantesTotalEAD.qtrecoop + participantesEAD.qtrecoop
           participantesTotalEAD.qtrecomu = participantesTotalEAD.qtrecomu + participantesEAD.qtrecomu.
			   
	END.
	/** FIM TOTAL PARTICIPANTE EAD **/
	RETURN TRUE.
	
END FUNCTION. /* Fim montaDadosTotal */

FUNCTION montaCabecalho RETURNS LOGICAL ():

	{&out} '<html>' SKIP
           '<head>' SKIP
           '<title>Progrid - Fechamento Geral</title>' SKIP.

    {&out} '<style>' SKIP
           '   body         ~{ background-color: #FFFFFF; }' SKIP
           '   td           ~{ font-family: Arial, Helvetica, sans-serif; font-size: 11px; font-weight: bold; }' SKIP
           '   .tdCab1      ~{ background-color: #B1B1B1; font-family: Arial, Helvetica, sans-serif; font-size: 14px; font-weight: bold; }' SKIP
           '   .tdCab2      ~{ background-color: #C6C6C6; font-family: Arial, Helvetica, sans-serif; font-size: 12px; font-weight: bold; }' SKIP
           '   .tdCab3      ~{ background-color: #DBDBDB; font-family: Arial, Helvetica, sans-serif; font-size: 11px; font-weight: bold; }' SKIP
           '   .tdLabel     ~{ font-family: Arial, Helvetica, sans-serif; font-size: 11px; font-weight: bold; }' SKIP
           '   .tdDados     ~{ font-family: Arial, Helvetica, sans-serif; font-size: 11px; font-weight: normal; border-bottom: #000000 0px solid }' SKIP
           '   .tdTitulo1   ~{ font-family: Verdana; font-size: 24px; font-weight: normal;}' SKIP
           '   .tdTitulo2   ~{ font-family: Verdana; font-size: 18px; font-weight: bold;}' SKIP
           '   .tab1        ~{ border-collapse:collapse; border-top: #000000 1px solid; border-bottom: #000000 1px solid; border-right: #000000 1px solid; border-left: #000000 1px solid; }' SKIP
           
           '   .tab2        ~{ border-color:black }' SKIP
           '   .td2         ~{ border-color:black }' SKIP
           '   .tdDados2    ~{ font-family: Arial, Helvetica, sans-serif; font-size: 11px; font-weight: normal; border-color:black}' SKIP
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
           '         <td class="tdprogra" colspan="5" align="right">wpgd0043b - ' TODAY '</td>' SKIP
           '   </table>' SKIP. 
	
	/* *** Cabecalho padrao com logo CECRED *** */
    {&out} '<table border="0" cellspacing="0" cellpadding="0" width="100%" >' SKIP
           '   <tr>' SKIP
           '      <td align="center" width="25%"><img src="/cecred/images/geral/logo_cecred.gif" border="0"></td>' SKIP
           '      <td class="tdTitulo1" align="center">Fechamento Geral - ' dtAnoAge '</td>' SKIP
           '   </tr>' SKIP
           '   <tr>' SKIP
           '      <td align="center" colspan="2">&nbsp;</td>' SKIP
           '   </tr>' SKIP
           '   <tr>' SKIP
		   '      <td align="center" width="25%">&nbsp;</td>' SKIP
           '      <td class="tdTitulo2" align="center">POR EVENTO' eventoDetelhe '</td>' SKIP
           '   </tr>' SKIP
           '</table>' SKIP.
	
	RETURN TRUE.
	
END FUNCTION.

FUNCTION montaTela RETURNS LOGICAL ():

    FOR EACH crapced WHERE crapced.dtanoage = dtanoage
                       AND crapced.cdcooper = crapcop.cdcooper NO-LOCK:
              
      /* Turmas EAD */
      FIND turmasEAD WHERE turmasEAD.cdevento = crapced.cdevento EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

      IF NOT AVAILABLE turmasEAD THEN
        DO:
          CREATE turmasEAD.
          ASSIGN turmasEAD.cdevento = crapced.cdevento.
          
          /* Alimenta o nome do evento caso nao haja nenhum registro para o evento da CRAPADP */
          FIND FIRST crapedp WHERE crapedp.idevento = 1 
                               AND crapedp.cdcooper = 0
                               AND crapedp.dtanoage = 0
                               AND crapedp.cdevento = crapced.cdevento
                               AND (crapedp.nrseqpgm = INT(nrseqpgm)      
                                OR INT(nrseqpgm) = 0) NO-LOCK NO-ERROR NO-WAIT.
                             
          IF AVAILABLE crapedp THEN     
          DO:     
            IF crapedp.tpevento = 10 THEN 
              ASSIGN turmasEAD.nmevento = UPPER(TRIM(crapedp.nmevento)).
          END.          
          
          
        END.
              
      ASSIGN turmasEAD.qtprevis = turmasEAD.qtprevis + crapced.qtocoeve.
         
      /* Participantes EAD */
      FIND participantesEAD WHERE participantesEAD.cdevento = crapced.cdevento EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
      
      IF NOT AVAILABLE participantesEAD THEN
        DO:
          CREATE participantesEAD.
          ASSIGN participantesEAD.cdevento = crapced.cdevento.
          
          
          /* Alimenta o nome do evento caso nao haja nenhum registro para o evento da CRAPADP */
          FIND FIRST crapedp WHERE crapedp.idevento = 1 
                               AND crapedp.cdcooper = 0
                               AND crapedp.dtanoage = 0
                               AND crapedp.cdevento = crapced.cdevento
                               AND (crapedp.nrseqpgm = INT(nrseqpgm)      
                                OR INT(nrseqpgm) = 0) NO-LOCK NO-ERROR NO-WAIT.
                             
          IF AVAILABLE crapedp THEN     
          DO:     
            IF crapedp.tpevento = 10 THEN 
              ASSIGN participantesEAD.nmevento = UPPER(TRIM(crapedp.nmevento)).
          END.                 
        END.
      
      ASSIGN participantesEAD.qtprevis = participantesEAD.qtprevis + (crapced.qtocoeve * crapced.qtpareve).
      
      RELEASE turmasEAD.
      RELEASE participantesEAD.
    END.

    /* Eventos */
    FOR EACH crapadp WHERE crapadp.idevento = idevento   	  
                       AND crapadp.cdcooper = crapcop.cdcooper
                       AND crapadp.dtanoage = dtanoage NO-LOCK,
        each crapedp  WHERE crapedp.cdevento = crapadp.cdevento
                                                      AND crapedp.cdcooper = 0
                                                      AND crapedp.dtanoage = 0
                                                      AND crapedp.idevento = idevento
                                                      AND (crapedp.nrseqpgm = INT(nrseqpgm)      
                                                       OR INT(nrseqpgm) = 0) NO-LOCK:

        /*IF NOT AVAILABLE crapedp THEN
          ASSIGN aux_tpevento = 0.
        ELSE*/
          ASSIGN aux_tpevento = crapedp.tpevento. 
          
  
				IF aux_tpevento = 10 THEN
					DO:
						/* Turmas EAD */
						FIND turmasEAD WHERE turmasEAD.cdevento = crapadp.cdevento EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
		
						IF NOT AVAILABLE turmasEAD THEN
							DO:
								CREATE turmasEAD.
								ASSIGN turmasEAD.cdevento = crapadp.cdevento.
							END.
					END.
				ELSE
					DO:
						/* Turmas */
						FIND turmas WHERE turmas.cdevento = crapadp.cdevento EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
		
						IF NOT AVAILABLE turmas THEN
							DO:
								CREATE turmas.
								ASSIGN turmas.cdevento = crapadp.cdevento.
							END.
					END.
        
				IF aux_tpevento = 10 THEN
					DO:
						/* Participantes EAD */
						FIND participantesEAD WHERE participantesEAD.cdevento = crapadp.cdevento EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
						
						IF NOT AVAILABLE participantesEAD THEN
							DO:
								CREATE participantesEAD.
								ASSIGN participantesEAD.cdevento = crapadp.cdevento.
							END.
					END.
				ELSE
					DO:
						/* Participantes */
						FIND participantes WHERE participantes.cdevento = crapadp.cdevento EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
						
						IF NOT AVAILABLE participantes THEN
							DO:
								CREATE participantes.
								ASSIGN participantes.cdevento = crapadp.cdevento.
							END.
					END.

        IF CAN-FIND(FIRST craphep WHERE craphep.idevento = 0
                                    AND craphep.cdcooper = 0 
                                    AND craphep.dtanoage = 0
                                    AND craphep.cdevento = 0
                                    AND craphep.cdagenci = crapadp.nrseqdig
                                    AND craphep.dshiseve MATCHES "*acrescido*" NO-LOCK)   THEN
					DO:
             /* Acrescido */ 
						 IF aux_tpevento = 10 THEN
							 ASSIGN turmasEAD.qtacresc = turmasEAD.qtacresc + 1.
             ELSE
               ASSIGN turmas.qtacresc = turmas.qtacresc + 1.
          END.
        ELSE
          DO:
						/* Previsto */
            IF aux_tpevento <> 10 THEN
              DO:
                ASSIGN turmas.qtprevis = turmas.qtprevis + 1.              
              END.    							
          END.

        /* Transferido e/ou Recebido */
        IF crapadp.nrmesage <> crapadp.nrmeseve THEN
          DO:
            IF aux_tpevento = 10 THEN
              ASSIGN turmasEAD.qttransf = turmasEAD.qttransf + 1.
            ELSE
              ASSIGN turmas.qttransf = turmas.qttransf + 1.
          END. 
          /* Cancelado */
          IF crapadp.idstaeve = 2 THEN
            DO:
              IF aux_tpevento = 10 THEN
                ASSIGN turmasEAD.qtcancel = turmasEAD.qtcancel + 1.
              ELSE
                ASSIGN turmas.qtcancel = turmas.qtcancel + 1.
            END.
          ELSE
            DO:
              /* Realizado */
              IF crapadp.dtfineve < TODAY THEN
                DO:
                  IF aux_tpevento = 10 THEN
                    ASSIGN turmasEAD.qtrealiz = turmasEAD.qtrealiz + 1.
                  ELSE
                    ASSIGN turmas.qtrealiz = turmas.qtrealiz + 1.
                END.
            END.

        ASSIGN aux_qtmaxtur = 0.
        
        /* Participantes previstos (desconsidera eventos acrescidos) - vagas ofertadas */
        IF   NOT CAN-FIND(FIRST craphep WHERE craphep.idevento = 0                 AND
                                              craphep.cdcooper = 0                 AND
                                              craphep.dtanoage = 0                 AND
                                              craphep.cdevento = 0                 AND
                                              craphep.cdagenci = crapadp.nrseqdig  AND 
                                              craphep.dshiseve MATCHES "*acrescido*" NO-LOCK) THEN DO:
                                              
          FIND FIRST crapeap WHERE crapeap.cdcooper = crapadp.cdcooper
                               AND crapeap.idevento = crapadp.idevento
                               AND crapeap.cdevento = crapadp.cdevento
                               AND crapeap.dtanoage = crapadp.dtanoage
                               AND crapeap.cdagenci = crapadp.cdagenci NO-LOCK NO-ERROR NO-WAIT.
           
          IF AVAILABLE crapeap THEN
            DO:
              IF crapeap.qtmaxtur > 0 THEN
                DO:
                  ASSIGN aux_qtmaxtur = aux_qtmaxtur + crapeap.qtmaxtur.
                
                  IF aux_tpevento <> 10 THEN
                    ASSIGN participantes.qtprevis = participantes.qtprevis + crapeap.qtmaxtur.
                END.
              ELSE
                DO:
                  /* para a frequencia minima */
                  FIND FIRST crabedp WHERE crabedp.idevento = crapadp.idevento
                                       AND crabedp.cdcooper = crapadp.cdcooper
                                       AND crabedp.dtanoage = crapadp.dtanoage
                                       AND crabedp.cdevento = crapadp.cdevento
                                       AND (crabedp.nrseqpgm = INT(nrseqpgm)      
                                        OR INT(nrseqpgm) = 0) NO-LOCK NO-ERROR NO-WAIT. 
                                       
                  IF AVAILABLE crabedp THEN
                    DO:
                      IF crabedp.qtmaxtur > 0 THEN
                        DO:
                          ASSIGN aux_qtmaxtur = aux_qtmaxtur + crabedp.qtmaxtur.
                          
                          IF aux_tpevento <> 10 THEN
                            ASSIGN participantes.qtprevis = participantes.qtprevis + crabedp.qtmaxtur.
                        END.
                      ELSE
                        DO:
                          FIND FIRST crabedp WHERE crabedp.idevento = crapadp.idevento
                                               AND crabedp.cdcooper = 0
                                               AND crabedp.dtanoage = 0
                                               AND crabedp.cdevento = crapadp.cdevento
                                               AND (crabedp.nrseqpgm = INT(nrseqpgm)      
                                                OR INT(nrseqpgm) = 0) NO-LOCK NO-ERROR NO-WAIT.
                                              
                          IF AVAILABLE crabedp THEN
                            DO:
                              ASSIGN aux_qtmaxtur = aux_qtmaxtur + crabedp.qtmaxtur.
                              
                              IF aux_tpevento <> 10 THEN
                                 ASSIGN participantes.qtprevis = participantes.qtprevis + crabedp.qtmaxtur. 
                            END.
                        END.

                    END.
                END.
            END.
          ELSE
            DO:
              /* para a frequencia minima */
              FIND FIRST crabedp WHERE crabedp.idevento = crapadp.idevento
                                   AND crabedp.cdcooper = crapadp.cdcooper
                                   AND crabedp.dtanoage = crapadp.dtanoage
                                   AND crabedp.cdevento = crapadp.cdevento
                                   AND (crabedp.nrseqpgm = INT(nrseqpgm)      
                                    OR INT(nrseqpgm) = 0) NO-LOCK NO-ERROR NO-WAIT. 
                                   
              IF AVAILABLE crabedp THEN
                DO:
                  IF crabedp.qtmaxtur > 0 THEN
                    DO:
                      ASSIGN aux_qtmaxtur = aux_qtmaxtur + crabedp.qtmaxtur.
                      
                      IF aux_tpevento <> 10 THEN
                        ASSIGN participantes.qtprevis = participantes.qtprevis + crabedp.qtmaxtur.
                    END.
                  ELSE
                    DO:
                      FIND FIRST crabedp WHERE crabedp.idevento = crapadp.idevento
                                           AND crabedp.cdcooper = 0
                                           AND crabedp.dtanoage = 0
                                           AND crabedp.cdevento = crapadp.cdevento
                                           AND (crabedp.nrseqpgm = INT(nrseqpgm)      
                                            OR INT(nrseqpgm) = 0) NO-LOCK NO-ERROR NO-WAIT.
                                          
                      IF AVAILABLE crabedp THEN
                        DO:
                          ASSIGN aux_qtmaxtur = aux_qtmaxtur + crabedp.qtmaxtur.
                          
                          IF aux_tpevento <> 10 THEN
                            ASSIGN participantes.qtprevis = participantes.qtprevis + crabedp.qtmaxtur.  
                        END.
                    END.
                END.
            END.
        END. /*Fim IF craphep */  
        
        /*FIND FIRST crapedp WHERE crapedp.idevento = crapadp.idevento 
                             AND crapedp.cdcooper = crapadp.cdcooper
                             AND crapedp.dtanoage = crapadp.dtanoage 
                             AND crapedp.cdevento = crapadp.cdevento
                             AND (crapedp.nrseqpgm = INT(nrseqpgm)      
                              OR INT(nrseqpgm) = 0) NO-LOCK NO-ERROR NO-WAIT.
                             
        IF AVAILABLE crapedp THEN     
					DO:     */
						IF aux_tpevento = 10 THEN 
							ASSIGN turmasEAD.nmevento = UPPER(TRIM(crapedp.nmevento))
										 participantesEAD.nmevento = UPPER(TRIM(crapedp.nmevento)).
						ELSE
							ASSIGN turmas.nmevento = UPPER(TRIM(crapedp.nmevento))
										 participantes.nmevento = UPPER(TRIM(crapedp.nmevento)).
					/*END.*/
                         
        /* Participantes realizados */
        FOR EACH crapidp WHERE crapidp.idevento = crapadp.idevento
                           AND crapidp.cdcooper = crapadp.cdcooper
                           AND crapidp.dtanoage = crapadp.dtanoage
                           AND crapidp.cdagenci = crapadp.cdagenci
                           AND crapidp.cdevento = crapadp.cdevento
                           AND crapidp.nrseqeve = crapadp.nrseqdig
                           AND crapidp.idstains = 2 /*Confirmado*/   NO-LOCK:

          /* Se o evento já ocorreu e NAO FOI CANCELADO, conta os que COMPARECERAM */
          IF crapadp.dtfineve < TODAY AND
             crapadp.idstaeve <> 2 THEN DO:    
             
             IF AVAILABLE crapidp AND AVAILABLE crapadp AND AVAILABLE crapedp THEN
             DO:
              /* Se percentual de faltas for suficiente em relacao ao percentual mínimo exigido */
              IF ((crapidp.qtfaleve * 100) / crapadp.qtdiaeve) <= (100 - crapedp.prfreque) THEN
                DO:
                  IF aux_tpevento = 10 THEN
                    ASSIGN participantesEAD.qtrealiz = participantesEAD.qtrealiz + 1.
                  ELSE
                    ASSIGN participantes.qtrealiz = participantes.qtrealiz + 1.
                    
                  IF crapidp.tpinseve = 1 THEN
                    DO:
                      IF aux_tpevento = 10 THEN
                        ASSIGN participantesEAD.qtrecoop = participantesEAD.qtrecoop + 1.
                      ELSE
                        ASSIGN participantes.qtrecoop = participantes.qtrecoop + 1.
                    END.
                  ELSE 
                    DO:
                      IF aux_tpevento = 10 THEN
                        ASSIGN participantesEAD.qtrecomu = participantesEAD.qtrecomu + 1.
                      ELSE
                        ASSIGN participantes.qtrecomu = participantes.qtrecomu + 1.
                    END.
                END.
              END.  
          END. 
        END.      
          
    END.

    /* FIM - Eventos */
	
	  /**** Logo Cooperativa *** */
    {&out} '<div width="100%" style="text-align:left;"><table border="0" cellspacing="0" style="padding-top:50px; float:left;" cellpadding="0" >' SKIP
           '   <tr>' SKIP
           '      <td align="left">&nbsp;&nbsp;&nbsp;<img src="' imagemDaCooperativa '" border="0"></td>' SKIP
		       '      <td class="tdTitulo1" align="left">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;' nomeDaCooperativa '</td>' SKIP		   
           '   </tr>' SKIP
           '</table><div>' SKIP. 
	
    {&out} '<br>' SKIP.     

    turmas().
    
    {&out} '<div style="clear:both"></div><br>' SKIP.	   

    turmasEAD().

    {&out} '<div style="clear:both"></div><br>' SKIP.
    
    geralTurmas().

    {&out} '<div style="clear:both"></div><br><br>' SKIP.
                               
    participantes().    

    {&out} '<div style="clear:both"></div><br>' SKIP.
                               
    participantesEAD().
	
    {&out} '<div style="clear:both"></div><br>' SKIP.
    
    geralParticipantes().
    
    {&out} '<div style="clear:both"></div><br>' SKIP.
    
    IF msgsDeErro <> ""
       THEN
           {&out} '<table border="0" cellspacing="1" cellpadding="1">' SKIP
                  '   <tr>' SKIP
                  '      <td>' msgsDeErro '</td>' SKIP
                  '   </tr>' SKIP
                  '</table>' SKIP.
		
    RETURN TRUE.

END FUNCTION. /* montaTela RETURNS LOGICAL () */

FUNCTION montaTelaTotal RETURNS LOGICAL ():
	
	/* *** Logo Cooperativa *** */
    {&out} '<br><div width="100%" style="text-align:left;"><table border="0" cellspacing="0" style="padding-top:20px; float:left;" cellpadding="0" >' SKIP
           '   <tr>' SKIP
           '      <td align="left">&nbsp;&nbsp;&nbsp;<img src="/cecred/images/geral/logo_cecred.gif" border="0"></td>' SKIP
           '      <td class="tdTitulo1" align="left">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; TOTAL GERAL</td>' SKIP		   
           '   </tr>' SKIP
           '</table><div>' SKIP. 
	
    {&out} '<br>' SKIP.	   

    turmasTotal().
    
    {&out} '<br><br>' SKIP.	   

    turmasTotalEAD().

    {&out} '<br><br>' SKIP.
       
    geralTurmasTotal().
    
    {&out} '<br>' SKIP.
    
    participantesTotal().    

    {&out} '<br>' SKIP.
                               
    participantesTotalEAD().
	
    {&out} '<br><br>' SKIP.
    
    geralParticipantesTotal().
        
    {&out} '<br>' SKIP.
    
    IF msgsDeErro <> ""
       THEN
           {&out} '<table border="0" cellspacing="1" cellpadding="1">' SKIP
                  '   <tr>' SKIP
                  '      <td>' msgsDeErro '</td>' SKIP
                  '   </tr>' SKIP
                  '</table>' SKIP.
		
    RETURN TRUE.

END FUNCTION. /* montaTelaTotal RETURNS LOGICAL () */

FUNCTION montaTelaDetalhado RETURNS LOGICAL ():
   	
	/* *** Logo Cooperativa *** */
  {&out} '<div width="100%" style="text-align:left;"><table border="0" cellspacing="0" cellpadding="0" style="padding-top:20px;" >' SKIP
         '   <tr>' SKIP
         '      <td class="tdTitulo1" align="left">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;' nomeDaCooperativa ' - Fechamento Geral - ' dtAnoAge '</td>' SKIP
         '      <td align="left">&nbsp;&nbsp;&nbsp;<img src="' imagemDaCooperativa '" border="0"></td>' SKIP
         '   </tr>' SKIP
         '</table><div>' SKIP. 
		   
	{&out} '<br>' SKIP.	   
	  
  /* Eventos PROGRID / EAD */	
  FOR EACH crapadp  WHERE crapadp.idevento = idevento         AND
                          crapadp.cdcooper = crapcop.cdcooper AND
                          crapadp.dtanoage = dtanoage NO-LOCK,
      FIRST crapedp WHERE crapedp.idevento = crapadp.idevento   AND 
                          crapedp.cdcooper = crapadp.cdcooper   AND
                          crapedp.dtanoage = crapadp.dtanoage   AND 
                          crapedp.cdevento = crapadp.cdevento   AND
                          (crapedp.nrseqpgm = INT(nrseqpgm)     OR
                          INT(nrseqpgm) = 0) NO-LOCK,
      FIRST crapage WHERE crapage.cdcooper = crapadp.cdcooper   AND
                          crapage.cdagenci = crapadp.cdagenci   NO-LOCK
                          BREAK BY crapedp.nmevento
                                BY crapage.nmresage:

      IF FIRST-OF(crapedp.nmevento) THEN
        DO:
              
          {&out} '   <font align="left" style="font-family: Arial, Helvetica, sans-serif; font-size: 11px; font-weight: bold;">' SKIP.
          
          IF crapedp.tpevento = 10 THEN
            DO:
              {&out} ' EAD - '.
            END.
           
          {&out} UPPER(TRIM(crapedp.nmevento)) SKIP
                 '   </font>' SKIP.

          ASSIGN prt_ttprevis = 0
                 prt_ttrealiz = 0
                 prt_ttrecoop = 0
                 prt_ttrecomu = 0.
              

              {&out} '<br>' SKIP
                     '<br>' SKIP
                     '<table class="tab2" border="1" cellspacing="0" cellpadding="0" width="100%" align="center">' SKIP
                     '  <tr>' SKIP
                     '    <td class="td2" align="center" width="40%">' SKIP
                     '      PA' SKIP
                     '    </td>' SKIP
                     '    <td class="td2" align="center" width="15%">' SKIP
                     '      DATA' SKIP
                     '    </td>' SKIP
                     '    <td class="td2" align="center" width="12%">' SKIP
                     '      PREV.' SKIP
                     '    </td>' SKIP
                     '    <td class="td2" align="center" width="11%">' SKIP
                     '      COOP.' SKIP
                     '    </td>' SKIP
                     '    <td class="td2" align="center" width="11%">' SKIP
                     '      COMU.' SKIP
                     '    </td>' SKIP
                     '    <td class="td2" align="center" width="11%">' SKIP
                     '      TOTAL' SKIP
                     '    </td>' SKIP
                     '  </tr>' SKIP.

        END.

      /* Monta o nome do PA com os PA'S agrupados, caso houver */
      IF FIRST-OF(crapage.nmresage) THEN
        DO:
          ASSIGN aux_qtmaxtur = 0
                 aux_nmresage = crapage.nmresage.

          FOR EACH crapagp  WHERE crapagp.cdcooper  = crapadp.cdcooper AND
                                  crapagp.idevento  = crapadp.idevento AND
                                  crapagp.dtanoage  = crapadp.dtanoage AND
                                  crapagp.cdageagr  = crapadp.cdagenci AND
                                  crapagp.cdageagr <> crapagp.cdagenci   NO-LOCK, 
            FIRST crabage WHERE crabage.cdcooper  = crapagp.cdcooper   AND
                      crabage.cdagenci  = crapagp.cdagenci   NO-LOCK
                      BY crabage.nmresage:

            aux_nmresage = aux_nmresage + " / " + crabage.nmresage.
          END.
        END.
          ELSE
            aux_nmresage = "&nbsp;".
      
      ASSIGN aux_qtmaxtur = 0.
      
      IF crapedp.tpevento <> 10 THEN
        DO:
          /* Participantes previstos (desconsidera eventos acrescidos) - vagas ofertadas */
          IF   NOT CAN-FIND(FIRST craphep WHERE craphep.idevento = 0                 AND
                                                craphep.cdcooper = 0                 AND
                                                craphep.dtanoage = 0                 AND
                                                craphep.cdevento = 0                 AND
                                                craphep.cdagenci = crapadp.nrseqdig  AND 
                                                craphep.dshiseve MATCHES "*acrescido*" NO-LOCK)   THEN DO:
                                                
            FIND FIRST crapeap WHERE crapeap.cdcooper = crapadp.cdcooper AND
                                     crapeap.idevento = crapadp.idevento AND                                     
                                     crapeap.cdevento = crapadp.cdevento AND
                                     crapeap.dtanoage = crapadp.dtanoage AND
                                     crapeap.cdagenci = crapadp.cdagenci NO-LOCK.
             
            IF AVAILABLE crapeap THEN
              DO:
                IF crapeap.qtmaxtur > 0 THEN
                  ASSIGN aux_qtmaxtur = aux_qtmaxtur + crapeap.qtmaxtur.
                ELSE
                  DO:
                    /* para a frequencia minima */
                    FIND FIRST crabedp WHERE crabedp.idevento = crapadp.idevento AND 
                                             crabedp.cdcooper = crapadp.cdcooper AND
                                             crabedp.dtanoage = crapadp.dtanoage AND 
                                             crabedp.cdevento = crapadp.cdevento AND
                                            (crabedp.nrseqpgm = INT(nrseqpgm)    OR
                                             INT(nrseqpgm) = 0) NO-LOCK. 
                    IF AVAILABLE crabedp THEN
                      DO:
                        IF crabedp.qtmaxtur > 0 THEN
                          ASSIGN aux_qtmaxtur = aux_qtmaxtur + crabedp.qtmaxtur.
                        ELSE
                          DO:
                            FIND FIRST crabedp WHERE crabedp.idevento = crapadp.idevento AND 
                                                     crabedp.cdcooper = 0 AND
                                                     crabedp.dtanoage = 0 AND 
                                                     crabedp.cdevento = crapadp.cdevento AND
                                                    (crabedp.nrseqpgm = INT(nrseqpgm)    OR
                                                    INT(nrseqpgm) = 0) NO-LOCK.
                                                
                            IF AVAILABLE crabedp THEN
                              ASSIGN aux_qtmaxtur = aux_qtmaxtur + crabedp.qtmaxtur. 
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
                                         crabedp.cdevento = crapadp.cdevento AND
                                        (crabedp.nrseqpgm = INT(nrseqpgm)    OR
                                         INT(nrseqpgm) = 0) NO-LOCK. 
                IF AVAILABLE crabedp THEN
                  DO:
                    IF crabedp.qtmaxtur > 0 THEN
                      ASSIGN aux_qtmaxtur = aux_qtmaxtur + crabedp.qtmaxtur.
                    ELSE
                      DO:
                        FIND FIRST crabedp WHERE crabedp.idevento = crapadp.idevento
                                             AND crabedp.cdcooper = 0
                                             AND crabedp.dtanoage = 0
                                             AND crabedp.cdevento = crapadp.cdevento
                                             AND (crabedp.nrseqpgm = INT(nrseqpgm)      
                                              OR INT(nrseqpgm) = 0) NO-LOCK.
                                            
                        IF AVAILABLE crabedp THEN
                          ASSIGN aux_qtmaxtur = aux_qtmaxtur + crabedp.qtmaxtur. 
                      END.
                  END.
              END.
          END. /* Fim IF CRAPHEP */  
        END.
      ELSE
        DO:
          FOR FIRST crapced FIELDS(qtpareve) WHERE crapced.dtanoage = crapadp.dtanoage
                                               AND crapced.cdcooper = crapadp.cdcooper
                                               AND crapced.cdagenci = crapadp.cdagenci
                                               AND crapced.cdevento = crapadp.cdevento NO-LOCK. END.
                                               
          IF AVAILABLE crapced THEN                                      
            ASSIGN aux_qtmaxtur = aux_qtmaxtur + crapced.qtpareve.
            
        END.       
          
      /* Participantes realizados */
      ASSIGN prt_qtrealiz = 0
             prt_qtrecoop = 0
             prt_qtrecomu = 0.
       
      FOR EACH crapidp WHERE crapidp.idevento = crapadp.idevento
                         AND crapidp.cdcooper = crapadp.cdcooper
                         AND crapidp.dtanoage = crapadp.dtanoage
                         AND crapidp.cdagenci = crapadp.cdagenci
                         AND crapidp.cdevento = crapadp.cdevento
                         AND crapidp.nrseqeve = crapadp.nrseqdig
                         AND crapidp.idstains = 2 /*Confirmado*/ NO-LOCK:

          /* Se o evento já ocorreu e NAO FOI CANCELADO, conta os que COMPARECERAM */
          IF crapadp.dtfineve < TODAY AND
             crapadp.idstaeve <> 2 THEN
            DO:    
              /* Se percentual de faltas for suficiente em relacao ao percentual mínimo exigido */
              IF ((crapidp.qtfaleve * 100) / crapadp.qtdiaeve) <= (100 - crapedp.prfreque) THEN
                DO:
                  ASSIGN prt_qtrealiz = prt_qtrealiz + 1.
                  
                  IF crapidp.tpinseve = 1 THEN
                    ASSIGN prt_qtrecoop = prt_qtrecoop + 1.
                  ELSE 
                    ASSIGN prt_qtrecomu = prt_qtrecomu + 1.
                END.
                                                      
            END.
      END.

      {&out} '<tr>' SKIP
             '  <td class="td2" align="left">' SKIP
                  aux_nmresage SKIP
             '  </td>' SKIP
             '  <td class="tdDados2" align="center">' SKIP.

      IF   crapadp.dtinieve = ?   THEN
           {&out} 'INDEFINIDO' SKIP.
      ELSE
      IF   crapadp.dtinieve = crapadp.dtfineve   THEN
           {&out} crapadp.dtinieve SKIP.
      ELSE
           {&out} crapadp.dtinieve ' a ' crapadp.dtfineve SKIP.

      {&out} '</td>' SKIP
             '<td class="tdDados2" align="center">' SKIP.

      prt_ttprevis = prt_ttprevis + aux_qtmaxtur.
      
      {&out} aux_qtmaxtur SKIP.
    
      IF crapadp.idstaeve = 2   THEN /* Cancelado */
        DO:
          {&out} '       </td>' SKIP
               '       <td class="tdDados2" align="center" colspan="3">' SKIP.
          {&out} 'CANCELADO' SKIP.
          {&out} '       </td>' SKIP
                         '     </tr>' SKIP.
        END.
      ELSE
        DO:
          {&out} '       </td>' SKIP
               '       <td class="tdDados2" align="center">' SKIP
               prt_qtrecoop SKIP
               '       </td>' SKIP
               '       <td class="tdDados2" align="center">' SKIP
               prt_qtrecomu SKIP
               '       </td>' SKIP
               '       <td class="tdDados2" align="center">' SKIP
               prt_qtrealiz SKIP
               '       </td>' SKIP
               '     </tr>' SKIP.
        END.

      ASSIGN prt_ttrealiz = prt_ttrealiz + prt_qtrealiz
             prt_ttrecoop = prt_ttrecoop + prt_qtrecoop
             prt_ttrecomu = prt_ttrecomu + prt_qtrecomu.               

      IF LAST-OF(crapedp.nmevento) THEN
        DO:
          {&out} 	'     <tr>' SKIP
              '       <td class="td2" align="left">' SKIP
              '       TOTAL' SKIP
              '       </td>' SKIP
              '       <td class="td2" align="left">' SKIP
              '       &nbsp;' SKIP
              '       </td>' SKIP
              '       <td class="tdDados2" align="center">' SKIP
              prt_ttprevis SKIP
              '       </td>' SKIP
              '       <td class="tdDados2" align="center">' SKIP
              prt_ttrecoop SKIP
              '       </td>' SKIP
              '       <td class="tdDados2" align="center">' SKIP
              prt_ttrecomu SKIP
              '       </td>' SKIP
              '       <td class="tdDados2" align="center">' SKIP
              prt_ttrealiz SKIP
              '       </td>' SKIP
              '     </tr>' SKIP
              '   </table>' SKIP
              '   <br>' SKIP.                 
        END.
    END.
    /* FIM - Eventos */
	
  IF msgsDeErro <> ""
     THEN
         {&out} '<table border="0" cellspacing="1" cellpadding="1">' SKIP
                '   <tr>' SKIP
                '      <td>' msgsDeErro '</td>' SKIP
                '   </tr>' SKIP
                '</table>' SKIP.
		
  RETURN TRUE.

END FUNCTION. /* montaTelaDetalhado RETURNS LOGICAL () */

FUNCTION montaRodape RETURNS LOGICAL ():

	{&out} '</div>' SKIP
		   '</body>' SKIP
		   '</html>' SKIP.

    RETURN TRUE.

END FUNCTION. /* montaRodape RETURNS LOGICAL () */

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
ELSE
	DO:
		EMPTY TEMP-TABLE turmas.
    EMPTY TEMP-TABLE turmasEAD.
    EMPTY TEMP-TABLE participantes.
    EMPTY TEMP-TABLE participantesEAD.
    EMPTY TEMP-TABLE turmasTotal.
    EMPTY TEMP-TABLE turmasTotalEAD.
    EMPTY TEMP-TABLE participantesTotal.
    EMPTY TEMP-TABLE participantesTotalEAD.
    	
		ASSIGN idevento = INTEGER(GET-VALUE("parametro1"))
           cdcooper =  STRING(GET-VALUE("parametro2"))
           dtanoage = INTEGER(GET-VALUE("parametro3")) 
           detalhar = LOGICAL(GET-VALUE("parametro4"))
           nrseqpgm = INTEGER(GET-VALUE("parametro5")) NO-ERROR.          

		IF detalhar THEN
			ASSIGN eventoDetelhe = ' - DETALHADO'.
			
		montaCabecalho().
			
		FOR EACH crapcop 
       WHERE CAN-DO(cdcooper,STRING(crapcop.cdcooper)) NO-LOCK
       BY crapcop.nmrescop:	
		
			/* Limpa os dados por cooperativa */
			EMPTY TEMP-TABLE turmas.	
			EMPTY TEMP-TABLE participantes.
      EMPTY TEMP-TABLE turmasEAD.	
			EMPTY TEMP-TABLE participantesEAD.
			
			FIND LAST gnpapgd WHERE gnpapgd.idevento = idevento
                          AND gnpapgd.cdcooper = crapcop.cdcooper
                          AND gnpapgd.dtanonov = dtanoage NO-LOCK NO-ERROR.
		  
			ASSIGN nomedacooperativa = TRIM(crapcop.nmrescop).
		
			IF INDEX(crapcop.nmrescop, " ") <> 0 THEN
				DO: 
					aux_nmrescop = LC(TRIM(crapcop.nmrescop)).
					SUBSTRING( aux_nmrescop, (INDEX(aux_nmrescop, " ")),1) = "_".
					imagemDaCooperativa =  "/cecred/images/admin/logo_" +  aux_nmrescop.
				END.
			ELSE
				imagemDaCooperativa  = "/cecred/images/admin/logo_" + TRIM(LC(crapcop.nmrescop)) + ".gif" .				
						
			IF detalhar THEN
				DO:
					montatelaDetalhado().
				END.
			ELSE
				DO:
					montatela().
					montaDadosTotal().
				END.
				
		END. /* For Each crapcop*/
		
		IF R-INDEX(cdcooper,",") > 0 AND
		   NOT(detalhar)THEN
			DO:
				montaTelaTotal().
			END.			
		montaRodape().
	END.
          
/*******************************/
/*   Bloco de procdures        */
/*******************************/
PROCEDURE PermissaoDeAcesso:
    {includes/wpgd0009.i}
END PROCEDURE.