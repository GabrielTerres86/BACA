/******************************************************************************
  Programa wpgd0043c.p - Listagem de fechamento final (chamado a partir dos
                          dados de wpgd0043)

  Alteracoes: 03/11/2008 - Incluido widget-pool.

              10/12/2008 - Melhoria de performance para a tabela gnapses
                          (Evandro).
              
              19/12/2009 - Troca da coluna realizados por colunas cooperados
                           comunidade e total.
              
              09/06/2011 - Correção da quebra de página (Isara - RKAM).

              05/06/2012 - Adaptação dos fontes para projeto Oracle. Alterado
                           busca na gnapses de CONTAINS para MATCHES
                           (Guilherme Maba).
                           
              04/04/2013 - Alteração para receber logo na alto vale,
                           recebendo nome de viacrediav e buscando com
                           o respectivo nome (David Kruger).
              
              11/09/2013 - Nova forma de chamar as agências, de PAC agora 
                           a escrita será PA (André Euzébio - Supero).             
               
              23/06/2015 - Inclusao de tratamento para todas as cooperativas e 
                           criacao de novas funcoes para melhorar o
                           codigo(Jean Michel).
                           
              05/10/2015 - Incluida verificacao de qtmaxtur na crapeap antes
                           da atribuicao da crapedp Projeto 229 (Jean Michel). 
                           
              25/04/2016 - Correcao na mascara dos campos de percentual.  
                           (Carlos Rafael Tanholi)
                           
              27/04/2016 - Correcao do erro que estava preenchendo o LOG, informando
                           que o evento selecionado nao existia, decorrende da falta
                           de uso do AVAIL no comando FIND. (Carlos Rafael Tanholi)                       
                           
              31/05/2016 - Ajustes exibicao de todas as agencias dos eventos EAD por PA
                           PRJ229 - Melhorias OQS(Odirlei-AMcom)
                           
              06/06/2016 - Ajustado detalhado para exibir os todos os eventos,
                           mesmo os que ainda apensa estao previstos.
                           PRJ229 - Melhorias OQS(Odirlei-AMcom)
                           
              30/08/2017 - Inclusao do filtro por Programa,Prj. 322 (Jean Michel).             
                         
******************************************************************************/

create widget-pool.

/*****************************************************************************/
/*   Bloco de variaveis                                                      */
/*****************************************************************************/

DEFINE VARIABLE cookieEmUso                  AS CHARACTER NO-UNDO.
DEFINE VARIABLE permiteExecutar              AS CHARACTER NO-UNDO.
DEFINE VARIABLE IdentificacaoDaSessao        AS CHARACTER NO-UNDO.
DEFINE VARIABLE msgsDeErro                   AS CHARACTER NO-UNDO.
DEFINE VARIABLE cdcooper                     AS CHARACTER NO-UNDO.
DEFINE VARIABLE eventoDetelhe				         AS CHARACTER NO-UNDO.
DEFINE VARIABLE aux_nmrescop                 AS CHARACTER NO-UNDO.
DEFINE VARIABLE imagemDaCooperativa          AS CHARACTER NO-UNDO.
DEFINE VARIABLE nomeDaCooperativa            AS CHARACTER NO-UNDO.

DEFINE VARIABLE detalhar                     AS LOGICAL   NO-UNDO.

DEFINE VARIABLE idEvento                     AS INTEGER NO-UNDO.
DEFINE VARIABLE dtAnoAge                     AS INTEGER NO-UNDO.

DEFINE VARIABLE aux_contador                 AS INTEGER NO-UNDO.
DEFINE VARIABLE aux_qtmaxtur                 AS INTEGER NO-UNDO.

DEFINE VARIABLE tur_ttprevis                 AS INTEGER NO-UNDO.
DEFINE VARIABLE tur_ttprevis_ead             AS INTEGER NO-UNDO.
DEFINE VARIABLE tur_ttcancel                 AS INTEGER NO-UNDO.
DEFINE VARIABLE tur_ttcancel_ead             AS INTEGER NO-UNDO.
DEFINE VARIABLE tur_ttrecebi                 AS INTEGER NO-UNDO.
DEFINE VARIABLE tur_ttrecebi_ead             AS INTEGER NO-UNDO.
DEFINE VARIABLE tur_ttacresc                 AS INTEGER NO-UNDO.
DEFINE VARIABLE tur_ttacresc_ead             AS INTEGER NO-UNDO.
DEFINE VARIABLE tur_tttransf                 AS INTEGER NO-UNDO.
DEFINE VARIABLE tur_tttransf_ead             AS INTEGER NO-UNDO.
DEFINE VARIABLE tur_ttrealiz                 AS INTEGER NO-UNDO.
DEFINE VARIABLE tur_ttrealiz_ead             AS INTEGER NO-UNDO.

DEFINE VARIABLE prt_qtrealiz                 AS INTEGER NO-UNDO.
DEFINE VARIABLE prt_qtrealiz_ead             AS INTEGER NO-UNDO.
DEFINE VARIABLE prt_qtrecoop                 AS INTEGER NO-UNDO.
DEFINE VARIABLE prt_qtrecoop_ead             AS INTEGER NO-UNDO.
DEFINE VARIABLE prt_qtrecomu                 AS INTEGER NO-UNDO.
DEFINE VARIABLE prt_qtrecomu_ead             AS INTEGER NO-UNDO.
DEFINE VARIABLE prt_ttprevis                 AS INTEGER NO-UNDO.
DEFINE VARIABLE prt_ttprevis_ead             AS INTEGER NO-UNDO.
DEFINE VARIABLE prt_ttrealiz                 AS INTEGER NO-UNDO.
DEFINE VARIABLE prt_ttrealiz_ead             AS INTEGER NO-UNDO.
DEFINE VARIABLE prt_ttrecoop                 AS INTEGER NO-UNDO.
DEFINE VARIABLE prt_ttrecoop_ead             AS INTEGER NO-UNDO.
DEFINE VARIABLE prt_ttrecomu                 AS INTEGER NO-UNDO.
DEFINE VARIABLE prt_ttrecomu_ead             AS INTEGER NO-UNDO.

DEFINE VARIABLE aux_nmresage LIKE crapage.nmresage NO-UNDO.
DEFINE VARIABLE aux_nmevento LIKE crapedp.nmevento NO-UNDO.

DEFINE VARIABLE aux_tpevento                 AS CHARACTER NO-UNDO.
DEFINE VARIABLE aux_cdtpeven                 AS INTEGER NO-UNDO.
DEFINE VARIABLE nrseqpgm                     AS INTEGER NO-UNDO.

/* Turmas */
DEFINE TEMP-TABLE turmas
  FIELD cdagenci AS INTEGER
  FIELD qtprevis AS INTEGER
  FIELD qtcancel AS INTEGER
  FIELD qtacresc AS INTEGER
  FIELD qttransf AS INTEGER /* pode ser transferido e/ou recebido */
  FIELD qtrealiz AS INTEGER
  FIELD tpevento AS INTEGER
  FIELD percentu AS DECIMAL
  FIELD nmresage AS CHARACTER.
  
/* Turmas EAD */
DEFINE TEMP-TABLE turmasEAD
  FIELD cdagenci AS INTEGER
  FIELD qtprevis AS INTEGER
  FIELD qtcancel AS INTEGER
  FIELD qtacresc AS INTEGER
  FIELD qttransf AS INTEGER /* pode ser transferido e/ou recebido */
  FIELD qtrealiz AS INTEGER
  FIELD tpevento AS INTEGER
  FIELD percentu AS DECIMAL
  FIELD nmresage AS CHARACTER.  
  
/* Participantes */
DEFINE TEMP-TABLE participantes
  FIELD cdagenci AS INTEGER
  FIELD qtprevis AS INTEGER
  FIELD qtrecoop AS INTEGER
  FIELD qtrecomu AS INTEGER
  FIELD qtrealiz AS INTEGER
  FIELD tpevento AS INTEGER
  FIELD precentu AS DECIMAL
  FIELD nmresage AS CHARACTER.
  
/* Participantes EAD */
DEFINE TEMP-TABLE participantesEAD
  FIELD cdagenci AS INTEGER
  FIELD qtprevis AS INTEGER
  FIELD qtrecoop AS INTEGER
  FIELD qtrecomu AS INTEGER
  FIELD qtrealiz AS INTEGER
  FIELD tpevento AS INTEGER
  FIELD precentu AS DECIMAL
  FIELD nmresage AS CHARACTER.

DEFINE BUFFER crabage FOR crapage.
DEFINE BUFFER crabedp FOR crapedp.

/* Turmas */
DEFINE TEMP-TABLE turmasDetalhado
  FIELD cdcooper AS INTEGER
  FIELD nrseqdig AS INTEGER
  FIELD cdagenci AS INTEGER
  FIELD nmresage AS CHARACTER
  FIELD cdevento AS INTEGER
  FIELD nmevento AS CHARACTER
  FIELD dscddata AS CHARACTER
  FIELD idstaeve AS INTEGER
  FIELD tpevento AS CHARACTER
  FIELD qtprevis AS INTEGER
  FIELD qtrecoop AS INTEGER
  FIELD qtrecomu AS INTEGER
  FIELD qtrealiz AS INTEGER.

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

    {&out} '<br><table class="tab2" border="1" cellspacing="0" cellpadding="0" width="700px" style="float:left;">' SKIP
           '     <tr>' SKIP
           '       <td class="td2" align="center" valign="middle" colspan="8">' SKIP
           '         TURMAS - PRESENCIAL' SKIP
           '       </td>' SKIP
           '     </tr>' SKIP
           '     <tr>' SKIP
           '       <td class="td2" align="center">' SKIP
           '         PA' SKIP
           '       </td>' SKIP
           '       <td class="td2" align="center">' SKIP
           '         PREVISTO' SKIP
           '       </td>' SKIP
           '       <td class="td2" align="center">' SKIP
           '         CANCELADO' SKIP
           '       </td>' SKIP
           '       <td class="td2" align="center">' SKIP
           '         ACRESCIDO' SKIP
           '       </td>' SKIP
           '       <td class="td2" align="center">' SKIP
           '         TRANSFERIDO/RECEBIDO' SKIP
           '       </td>' SKIP
           '       <td class="td2" align="center">' SKIP
           '         REALIZADO' SKIP
           '       </td>' SKIP
           '       <td class="td2" align="center">' SKIP
           '         %' SKIP
           '       </td>' SKIP
           '     </tr>' SKIP.

    ASSIGN tur_ttprevis = 0
           tur_ttcancel = 0
           tur_ttacresc = 0
           tur_tttransf = 0
           tur_ttrealiz = 0.

    FOR EACH turmas NO-LOCK BY turmas.nmresage:

        {&out} '     <tr>' SKIP
               '       <td class="td2" align="left">' SKIP
                         turmas.nmresage SKIP
               '       </td>' SKIP
               '       <td class="tdDados2" align="center">' SKIP
                         turmas.qtprevis SKIP
               '       </td>' SKIP
               '       <td class="tdDados2" align="center">' SKIP
                         turmas.qtcancel SKIP
               '       </td>' SKIP
               '       <td class="tdDados2" align="center">' SKIP
                         turmas.qtacresc SKIP
               '       </td>' SKIP
               '       <td class="tdDados2" align="center">' SKIP
                         turmas.qttransf SKIP
               '       </td>' SKIP
               '       <td class="tdDados2" align="center">' SKIP
                         turmas.qtrealiz SKIP
               '       </td>' SKIP
               '       <td class="tdDados2" align="center">' SKIP.

        IF   turmas.qtprevis <> 0   THEN
             {&out} '&nbsp;' STRING(ROUND((turmas.qtrealiz * 100) / turmas.qtprevis,2),"zzz9.99") '%&nbsp;' SKIP.
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
    
    {&out} '     <tr>' SKIP
           '       <td class="td2" align="left">' SKIP
           '         TOTAL' SKIP
           '       </td>' SKIP
           '       <td class="tdDados2" align="center">' SKIP
                     tur_ttprevis SKIP
           '       </td>' SKIP
           '       <td class="tdDados2" align="center">' SKIP
                     tur_ttcancel SKIP
           '       </td>' SKIP
           '       <td class="tdDados2" align="center">' SKIP
                     tur_ttacresc SKIP
           '       </td>' SKIP
           '       <td class="tdDados2" align="center">' SKIP
                     tur_tttransf SKIP
           '       </td>' SKIP
           '       <td class="tdDados2" align="center">' SKIP
                     tur_ttrealiz SKIP
           '       </td>' SKIP
           '       <td class="tdDados2" align="center">' SKIP.

    IF   tur_ttprevis <> 0   THEN
         {&out} '&nbsp;' STRING(ROUND((tur_ttrealiz * 100) / tur_ttprevis,2),"zzzz9.99") '%&nbsp;' SKIP.
    ELSE
         {&out} '&nbsp;0,00%&nbsp;' SKIP.

    {&out} '       </td>' SKIP
           '     </tr>' SKIP
           '   </table>' SKIP.
END FUNCTION. /* fim turmas */

FUNCTION turmasEAD RETURNS LOGICAL ():

    {&out} '<br><table class="tab2" border="1" cellspacing="0" cellpadding="0" width="700px" style="float:left;">' SKIP
           '     <tr>' SKIP
           '       <td class="td2" align="center" valign="middle" colspan="8">' SKIP
           '         TURMAS - EAD' SKIP
           '       </td>' SKIP
           '     </tr>' SKIP
           '     <tr>' SKIP
           '       <td class="td2" align="center">' SKIP
           '         PA' SKIP
           '       </td>' SKIP
           '       <td class="td2" align="center">' SKIP
           '         PREVISTO' SKIP
           '       </td>' SKIP
           '       <td class="td2" align="center">' SKIP
           '         CANCELADO' SKIP
           '       </td>' SKIP
           '       <td class="td2" align="center">' SKIP
           '         ACRESCIDO' SKIP
           '       </td>' SKIP
           '       <td class="td2" align="center">' SKIP
           '         TRANSFERIDO/RECEBIDO' SKIP
           '       </td>' SKIP
           '       <td class="td2" align="center">' SKIP
           '         REALIZADO' SKIP
           '       </td>' SKIP
           '       <td class="td2" align="center">' SKIP
           '         %' SKIP
           '       </td>' SKIP
           '     </tr>' SKIP.

    ASSIGN tur_ttprevis_ead = 0
           tur_ttcancel_ead = 0
           tur_ttacresc_ead = 0
           tur_tttransf_ead = 0
           tur_ttrealiz_ead = 0.

    FOR EACH turmasEAD NO-LOCK BY turmasEAD.nmresage:

        {&out} '<tr>' SKIP
               '  <td class="td2" align="left">' SKIP
                    turmasEAD.nmresage SKIP
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

        IF turmasEAD.qtprevis <> 0   THEN
             {&out} '&nbsp;' STRING(ROUND((turmasEAD.qtrealiz * 100) / turmasEAD.qtprevis,2),"zzzz9.99") '%&nbsp;' SKIP.
        ELSE
             {&out} '&nbsp;0,00%&nbsp' SKIP.

        {&out} '  </td>' SKIP
               '</tr>' SKIP.
     
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
         {&out} '&nbsp;' STRING(ROUND((tur_ttrealiz_ead * 100) / tur_ttprevis_ead,2),"zzzz9.99") '%&nbsp;' SKIP.
    ELSE
         {&out} '&nbsp;0,00%&nbsp;' SKIP.

    {&out} '    </td>' SKIP
           '  </tr>' SKIP
           '</table><br>' SKIP.
           
END FUNCTION. /* fim turmasEAD */

FUNCTION participantes RETURNS LOGICAL ():
    
    /*{&out} '<br><table class="tab2" border="1" cellspacing="0" cellpadding="0" width="600px" align="left" style="float:left;" > ' SKIP*/
    {&out} '<br><table class="tab2" border="1" cellspacing="0" cellpadding="0" width="700px" style="float:left;">' SKIP
           '     <tr>' SKIP
           '       <td class="td2" align="center" valign="middle" colspan="8">' SKIP
           '         PARTICIPANTES - PRESENCIAL' SKIP
           '       </td>' SKIP
           '     </tr>' SKIP
           '     <tr>' SKIP
           '       <td class="td2" align="left">' SKIP
           '         PA' SKIP
           '       </td>' SKIP
           '       <td class="td2" align="center">' SKIP
           '         PREVISTO' SKIP
           '       </td>' SKIP
           '       <td class="td2" align="center">' SKIP
           '         COOPERADO' SKIP
           '       </td>' SKIP
           '       <td class="td2" align="center">' SKIP
           '         COMUNIDADE' SKIP
           '       </td>' SKIP
           '       <td class="td2" align="center">' SKIP
           '         TOTAL' SKIP
           '       </td>' SKIP
           '       <td class="td2" align="center">' SKIP
           '         %' SKIP
           '       </td>' SKIP
           '     </tr>' SKIP.

    ASSIGN prt_ttprevis = 0
           prt_ttrecoop = 0
           prt_ttrecomu = 0
           prt_ttrealiz = 0.
    
    FOR EACH participantes NO-LOCK BY participantes.nmresage:

        {&out} '     <tr>' SKIP
               '       <td class="td2" align="left">' SKIP
                         participantes.nmresage SKIP
               '       </td>' SKIP
               '       <td class="tdDados2" align="center">' SKIP
                         participantes.qtprevis SKIP
               '       </td>' SKIP
               '       <td class="tdDados2" align="center">' SKIP
                         participantes.qtrecoop SKIP
               '       </td>' SKIP
               '       <td class="tdDados2" align="center">' SKIP
                         participantes.qtrecomu SKIP
               '       </td>' SKIP
               '       <td class="tdDados2" align="center">' SKIP
                         participantes.qtrealiz SKIP
               '       </td>' SKIP
               '       <td class="tdDados2" align="center">' SKIP.

        
                IF   participantes.qtprevis <> 0   THEN
             {&out} '&nbsp;' STRING(ROUND((participantes.qtrealiz * 100) / participantes.qtprevis,2),"zzzz9.99") '%&nbsp;' SKIP.
        ELSE
             {&out} '&nbsp;0,00%&nbsp;' SKIP.

        {&out} '       </td>' SKIP
               '     </tr>' SKIP.
     
        ASSIGN prt_ttprevis = prt_ttprevis + participantes.qtprevis
               prt_ttrecoop = prt_ttrecoop + participantes.qtrecoop
               prt_ttrecomu = prt_ttrecomu + participantes.qtrecomu
               prt_ttrealiz = prt_ttrealiz + participantes.qtrealiz.
    END.
    
    {&out} '     <tr>' SKIP
           '       <td class="td2" align="left">' SKIP
           '         TOTAL' SKIP
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
           '       <td class="tdDados2" align="center">' SKIP.

    IF   prt_ttprevis <> 0   THEN
         {&out} '&nbsp;' STRING(ROUND((prt_ttrealiz * 100) / prt_ttprevis,2),"zzzz9.99") '%&nbsp;' SKIP.
    ELSE
         {&out} '&nbsp;0,00%&nbsp;' SKIP.

    {&out} '       </td>' SKIP
           '     </tr>' SKIP
           '   </table><br>' SKIP.

END FUNCTION. /* fim participantes */

FUNCTION participantesEAD RETURNS LOGICAL ():
    
    {&out} '<br><table class="tab2" border="1" cellspacing="0" cellpadding="0" width="700px" align="left" style="float:left;" > ' SKIP
           '     <tr>' SKIP
           '       <td class="td2" align="center" valign="middle" colspan="8">' SKIP
           '         PARTICIPANTES - EAD' SKIP
           '       </td>' SKIP
           '     </tr>' SKIP
           '     <tr>' SKIP
           '       <td class="td2" align="left">' SKIP
           '         PA' SKIP
           '       </td>' SKIP
           '       <td class="td2" align="center">' SKIP
           '         PREVISTO' SKIP
           '       </td>' SKIP
           '       <td class="td2" align="center">' SKIP
           '         COOPERADO' SKIP
           '       </td>' SKIP
           '       <td class="td2" align="center">' SKIP
           '         COMUNIDADE' SKIP
           '       </td>' SKIP
           '       <td class="td2" align="center">' SKIP
           '         TOTAL' SKIP
           '       </td>' SKIP
           '       <td class="td2" align="center">' SKIP
           '         %' SKIP
           '       </td>' SKIP
           '     </tr>' SKIP.

    ASSIGN prt_ttprevis_ead = 0
           prt_ttrecoop_ead = 0
           prt_ttrecomu_ead = 0
           prt_ttrealiz_ead = 0.
    
    FOR EACH participantesEAD NO-LOCK BY participantesEAD.nmresage:

        {&out} '     <tr>' SKIP
               '       <td class="td2" align="left">' SKIP
                         participantesEAD.nmresage SKIP
               '       </td>' SKIP
               '       <td class="tdDados2" align="center">' SKIP
                         participantesEAD.qtprevis SKIP
               '       </td>' SKIP
               '       <td class="tdDados2" align="center">' SKIP
                         participantesEAD.qtrecoop SKIP
               '       </td>' SKIP
               '       <td class="tdDados2" align="center">' SKIP
                         participantesEAD.qtrecomu SKIP
               '       </td>' SKIP
               '       <td class="tdDados2" align="center">' SKIP
                         participantesEAD.qtrealiz SKIP
               '       </td>' SKIP
               '       <td class="tdDados2" align="center">' SKIP.
        
        IF participantesEAD.qtprevis <> 0 THEN
          {&out} '&nbsp;' STRING(ROUND((participantesEAD.qtrealiz * 100) / participantesEAD.qtprevis,2),"zzzz9.99") '%&nbsp;' SKIP.
        ELSE
          {&out} '&nbsp;0,00%&nbsp;' SKIP.

        {&out} '       </td>' SKIP
               '     </tr>' SKIP.
     
        ASSIGN prt_ttprevis_ead = prt_ttprevis_ead + participantesEAD.qtprevis
               prt_ttrecoop_ead = prt_ttrecoop_ead + participantesEAD.qtrecoop
               prt_ttrecomu_ead = prt_ttrecomu_ead + participantesEAD.qtrecomu
               prt_ttrealiz_ead = prt_ttrealiz_ead + participantesEAD.qtrealiz.
    END.
    
    {&out} '     <tr>' SKIP
           '       <td class="td2" align="left">' SKIP
           '         TOTAL' SKIP
           '       </td>' SKIP
           '       <td class="tdDados2" align="center">' SKIP
                     prt_ttprevis_ead SKIP
           '       </td>' SKIP
           '       <td class="tdDados2" align="center">' SKIP
                     prt_ttrecoop_ead SKIP
           '       </td>' SKIP
           '       <td class="tdDados2" align="center">' SKIP
                     prt_ttrecomu_ead SKIP
           '       </td>' SKIP
           '       <td class="tdDados2" align="center">' SKIP
                     prt_ttrealiz_ead SKIP
           '       </td>' SKIP
           '       <td class="tdDados2" align="center">' SKIP.

    IF   prt_ttprevis_ead <> 0   THEN
         {&out} '&nbsp;' STRING(ROUND((prt_ttrealiz_ead * 100) / prt_ttprevis_ead,2),"zzzz9.99") '%&nbsp;' SKIP.
    ELSE
         {&out} '&nbsp;0,00%&nbsp;' SKIP.

    {&out} '       </td>' SKIP
           '     </tr>' SKIP
           '   </table><br>' SKIP.

END FUNCTION. /* fim participantes EAD*/

FUNCTION montaCabecalho RETURNS LOGICAL():

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
           
           '   .tab2        ~{ border-color:black;}' SKIP
           '   .td2         ~{ border-color:black }' SKIP
           '   .tdDados2    ~{ font-family: Arial, Helvetica, sans-serif; font-size: 11px; font-weight: normal; border-color:black}' SKIP
           '</style>' SKIP.

    {&out} '</head>' SKIP
           '<body bgcolor="#FFFFFF" topmargin="0" marginwidth="0" marginheight="0">' SKIP
           '<div align="left">' SKIP.
    
    /* *** Botoes de fechar e imprimir *** */
    {&out} '<div align="right" id="botoes">' SKIP
           '   <table border="0" cellspacing="0" cellpadding="0" width="800px" style="float:left;">' SKIP
           '      <tr>' SKIP
           '         <td align="right">' SKIP
           '            <img src="/cecred/images/botoes/btn_fechar.gif" alt="Fechar esta janela" style="cursor: hand" onClick="top.close()">' SKIP
           '            <img src="/cecred/images/botoes/btn_imprimir.gif" alt="Imprimir" style="cursor: hand" onClick="document.all.botoes.style.visibility = ~'hidden~'; print(); document.all.botoes.style.visibility = ~'visible~';">' SKIP
           '         </td>' SKIP
           '      </tr>' SKIP
           '   </table>' SKIP
           '</div>' SKIP.

    {&out} '   <table border="0" cellspacing="0" cellpadding="0" width="800px" style="float:left;">' SKIP
           '      <tr>' SKIP
           '         <td class="tdprogra" colspan="5" align="right">wpgd0043c - ' TODAY '</td>' SKIP
           '   </table>' SKIP. 
		   
	/* *** Logo Cecred *** */
    {&out} '   <table border="0" cellspacing="0" cellpadding="0" width="800px" style="float:left;">' SKIP
           '      <tr>' SKIP
           '         <td align="center" width="25%"><img src="/cecred/images/geral/logo_cecred.gif" border="0"></td>' SKIP
           '         <td class="tdTitulo1" align="center">Fechamento Geral - ' dtAnoAge '</td>' SKIP
           '      </tr>' SKIP
           '      <tr>' SKIP
		   '         <td align="center" width="25%">&nbsp;</td>' SKIP
           '         <td class="tdTitulo2" align="center">POR PA' eventoDetelhe '</td>' SKIP
           '      </tr>' SKIP
           '   </table>' SKIP.
		   
	{&out} '<br>' SKIP.

	RETURN TRUE.
	
END FUNCTION.

FUNCTION montaTela RETURNS LOGICAL ():            
  
    /* Eventos */
    FOR EACH crapadp WHERE crapadp.idevento = idevento
                       AND crapadp.cdcooper = crapcop.cdcooper
                       AND crapadp.dtanoage = dtanoage NO-LOCK,
      EACH crapedp WHERE crapedp.cdevento = crapadp.cdevento
                     AND crapedp.cdcooper = 0
                     AND crapedp.dtanoage = 0
                     AND crapedp.idevento = idevento
                     AND (crapedp.nrseqpgm = INT(nrseqpgm)      
                      OR INT(nrseqpgm) = 0) NO-LOCK:
      
			ASSIGN aux_cdtpeven = crapedp.tpevento.
            
      IF aux_cdtpeven <> 10 THEN      
        DO:
          /* Turmas */
          FIND turmas WHERE turmas.cdagenci = crapadp.cdagenci EXCLUSIVE-LOCK NO-ERROR.

          IF NOT AVAILABLE turmas   THEN
            DO:
              CREATE turmas.
              ASSIGN turmas.cdagenci = crapadp.cdagenci.
            END.

          /* Participantes */
          FIND participantes WHERE participantes.cdagenci = crapadp.cdagenci EXCLUSIVE-LOCK NO-ERROR.

          IF NOT AVAILABLE participantes   THEN
            DO:
              CREATE participantes.
              ASSIGN participantes.cdagenci = crapadp.cdagenci
                     aux_qtmaxtur = 0.
            END.      
        END.
      ELSE /* EAD */
        DO:
          /* Turmas */
          FIND turmasEAD WHERE turmasEAD.cdagenci = crapadp.cdagenci EXCLUSIVE-LOCK NO-ERROR.

          IF NOT AVAILABLE turmasEAD THEN
            DO:
              CREATE turmasEAD.
              ASSIGN turmasEAD.cdagenci = crapadp.cdagenci.
            END.

          /* Participantes */
          FIND participantesEAD WHERE participantesEAD.cdagenci = crapadp.cdagenci EXCLUSIVE-LOCK NO-ERROR.

          IF NOT AVAILABLE participantesEAD   THEN
            DO:
              CREATE participantesEAD.
              ASSIGN participantesEAD.cdagenci = crapadp.cdagenci
                     aux_qtmaxtur = 0.
            END.      
        END.
        
        
        IF CAN-FIND(FIRST craphep WHERE craphep.idevento = 0               
                                    AND craphep.cdcooper = 0               
                                    AND craphep.dtanoage = 0               
                                    AND craphep.cdevento = 0               
                                    AND craphep.cdagenci = crapadp.nrseqdig 
                                    AND craphep.dshiseve MATCHES "*acrescido*" NO-LOCK) THEN
          /* acrescido */ 
          IF aux_cdtpeven <> 10 THEN
            turmas.qtacresc = turmas.qtacresc + 1.
          ELSE
            turmasEAD.qtacresc = turmasEAD.qtacresc + 1.
        ELSE
          DO:
            IF aux_cdtpeven <> 10 THEN
              /* previsto */
              turmas.qtprevis = turmas.qtprevis + 1.            
          END.
        /* transferido e/ou recebido */
        IF crapadp.nrmesage <> crapadp.nrmeseve THEN
          DO:
            IF aux_cdtpeven <> 10 THEN
              turmas.qttransf = turmas.qttransf + 1.
            ELSE
              turmasEAD.qttransf = turmasEAD.qttransf + 1.
          END.
                    
        /* cancelado */
        IF crapadp.idstaeve = 2 THEN
          DO:
            IF aux_cdtpeven <> 10 THEN
              turmas.qtcancel = turmas.qtcancel + 1.
            ELSE
              turmasEAD.qtcancel = turmasEAD.qtcancel + 1.
          END.
        ELSE
          DO:
            /* realizado */
            IF crapadp.dtfineve < TODAY THEN
              DO:
                IF aux_cdtpeven <> 10 THEN
                  turmas.qtrealiz = turmas.qtrealiz + 1.
                ELSE
                  turmasEAD.qtrealiz = turmasEAD.qtrealiz + 1.
              END.
          END.
        
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
                                   crapeap.cdagenci = crapadp.cdagenci NO-LOCK NO-ERROR NO-WAIT.
           
          IF AVAILABLE crapeap THEN
            DO:
              IF crapeap.qtmaxtur > 0 THEN
                DO:
                  IF aux_cdtpeven <> 10 THEN
                    ASSIGN participantes.qtprevis = participantes.qtprevis + crapeap.qtmaxtur.
                END.
              ELSE
                DO:
                  /* para a frequencia minima */
                  FIND FIRST crabedp WHERE crabedp.idevento = crapadp.idevento AND 
                                           crabedp.cdcooper = crapadp.cdcooper AND
                                           crabedp.dtanoage = crapadp.dtanoage AND 
                                           crabedp.cdevento = crapadp.cdevento AND
                                          (crabedp.nrseqpgm = INT(nrseqpgm)    OR
                                           INT(nrseqpgm) = 0) NO-LOCK NO-ERROR NO-WAIT. 
                  IF AVAILABLE crabedp THEN
                    DO:
                      IF crabedp.qtmaxtur > 0 THEN
                        DO:
                          IF aux_cdtpeven <> 10 THEN
                            ASSIGN participantes.qtprevis = participantes.qtprevis + crabedp.qtmaxtur.
                          
                        END.
                      ELSE
                        DO:
                          FIND FIRST crabedp WHERE crabedp.idevento = crapadp.idevento AND 
                                                   crabedp.cdcooper = 0 AND
                                                   crabedp.dtanoage = 0 AND 
                                                   crabedp.cdevento = crapadp.cdevento AND
                                                  (crabedp.nrseqpgm = INT(nrseqpgm)   OR
                                                   INT(nrseqpgm) = 0) NO-LOCK NO-ERROR NO-WAIT.
                                              
                          IF AVAILABLE crabedp THEN
                            DO:
                              IF aux_cdtpeven <> 10 THEN
                                ASSIGN participantes.qtprevis = participantes.qtprevis + crabedp.qtmaxtur. 
                              
                            END.
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
                                      (crabedp.nrseqpgm = INT(nrseqpgm)   OR
                                       INT(nrseqpgm) = 0) NO-LOCK NO-ERROR NO-WAIT. 
                                       
              IF AVAILABLE crabedp THEN
                DO:
                  IF crabedp.qtmaxtur > 0 THEN
                    DO:
                      IF aux_cdtpeven <> 10 THEN
                        ASSIGN participantes.qtprevis = participantes.qtprevis + crabedp.qtmaxtur.  
                      
                    END.
                  ELSE
                    DO:
                      FIND FIRST crabedp WHERE crabedp.idevento = crapadp.idevento AND 
                                               crabedp.cdcooper = 0 AND
                                               crabedp.dtanoage = 0 AND 
                                               crabedp.cdevento = crapadp.cdevento AND
                                              (crabedp.nrseqpgm = INT(nrseqpgm)    OR
                                               INT(nrseqpgm) = 0) NO-LOCK NO-ERROR NO-WAIT.
                                          
                      IF AVAILABLE crabedp THEN
                        DO:
                          IF aux_cdtpeven <> 10 THEN
                            ASSIGN participantes.qtprevis = participantes.qtprevis + crabedp.qtmaxtur. 
                          
                        END.
                    END.
                END.
              ELSE
                DO:
                  FIND FIRST crabedp WHERE crabedp.idevento = crapadp.idevento AND 
                                           crabedp.cdcooper = 0 AND
                                           crabedp.dtanoage = 0 AND 
                                           crabedp.cdevento = crapadp.cdevento AND
                                          (crabedp.nrseqpgm = INT(nrseqpgm)    OR
                                          INT(nrseqpgm) = 0) NO-LOCK NO-ERROR NO-WAIT.
                                      
                  IF AVAILABLE crabedp THEN
                    DO:
                      IF aux_cdtpeven <> 10 THEN
                        ASSIGN participantes.qtprevis = participantes.qtprevis + crabedp.qtmaxtur. 
                    END.  
                END.
            END.
        END. /* Fim IF CRAPHEP */
        
        /* para a frequencia minima */
        /*FIND FIRST crapedp WHERE crapedp.idevento = crapadp.idevento   AND 
                                 crapedp.cdcooper = crapadp.cdcooper AND
                                 crapedp.dtanoage = crapadp.dtanoage AND 
                                 crapedp.cdevento = crapadp.cdevento AND
                                (crapedp.nrseqpgm = INT(nrseqpgm)    OR
                                INT(nrseqpgm) = 0) NO-LOCK. */
                                 
        /* Participantes realizados */
        FOR EACH crapidp WHERE crapidp.idevento = crapadp.idevento
                           AND crapidp.cdcooper = crapadp.cdcooper
                           AND crapidp.dtanoage = crapadp.dtanoage
                           AND crapidp.cdagenci = crapadp.cdagenci
                           AND crapidp.cdevento = crapadp.cdevento
                           AND crapidp.nrseqeve = crapadp.nrseqdig
                           AND crapidp.idstains = 2 /*Confirmado*/ NO-LOCK:
           
            /* Se o evento já ocorreu e NAO FOI CANCELADO, conta os que COMPARECERAM */
            IF crapadp.dtfineve  < TODAY AND
               crapadp.idstaeve <> 2	 THEN
                 DO:    
                    IF AVAILABLE crapidp AND AVAILABLE crapadp AND AVAILABLE crapedp THEN                 
                    DO:
                      /* Se percentual de faltas for suficiente em relacao ao percentual mínimo exigido */
                      IF  ((crapidp.qtfaleve * 100) / crapadp.qtdiaeve) <= (100 - crapedp.prfreque) THEN
                        DO:
                          IF aux_cdtpeven <> 10 THEN
                            DO:
                              participantes.qtrealiz = participantes.qtrealiz + 1.

                              IF crapidp.tpinseve = 1 THEN 
                                 participantes.qtrecoop = participantes.qtrecoop + 1.
                              ELSE
                                 participantes.qtrecomu = participantes.qtrecomu + 1.
                            END.
                          ELSE
                            DO:
                              participantesEAD.qtrealiz = participantesEAD.qtrealiz + 1.

                              IF crapidp.tpinseve = 1 THEN 
                                 participantesEAD.qtrecoop = participantesEAD.qtrecoop + 1.
                              ELSE
                                 participantesEAD.qtrecomu = participantesEAD.qtrecomu + 1.
                            END.
                        END.
                    END.                      
                 END.
        END.

        FIND crapage WHERE crapage.cdcooper = crapadp.cdcooper
                       AND crapage.cdagenci = crapadp.cdagenci NO-LOCK NO-ERROR.

        /* Monta o nome do PA com os PA'S agrupados, caso houver */
        ASSIGN aux_nmresage = crapage.nmresage.

        FOR EACH crapagp WHERE crapagp.cdcooper  = crapadp.cdcooper AND
                               crapagp.idevento  = crapadp.idevento AND
                               crapagp.dtanoage  = crapadp.dtanoage AND
                               crapagp.cdageagr  = crapadp.cdagenci AND
                               crapagp.cdageagr <> crapagp.cdagenci NO-LOCK, 
           FIRST crabage WHERE crabage.cdcooper  = crapagp.cdcooper AND
                               crabage.cdagenci  = crapagp.cdagenci NO-LOCK
                               BY crabage.nmresage:

            aux_nmresage = aux_nmresage + " / " + crabage.nmresage.
        END.

        IF aux_cdtpeven <> 10 THEN
          ASSIGN turmas.nmresage        = aux_nmresage
                 participantes.nmresage = aux_nmresage.
                 
        ELSE
          ASSIGN turmasEAD.nmresage        = aux_nmresage
                 participantesEAD.nmresage = aux_nmresage.
        
    END.
    /* FIM - Eventos */
    
    /*Buscar eventos para garantir que sejam apresentados
      todos os PAs para o EAD*/
    FOR EACH crapced WHERE crapced.idevento = idevento
                       AND crapced.dtanoage = dtanoage
                       AND crapced.cdcooper = crapcop.cdcooper NO-LOCK:
                     
        FOR FIRST crapedp WHERE crapedp.cdevento = crapced.cdevento
                            AND crapedp.cdcooper = 0
                            AND crapedp.dtanoage = 0
                            AND crapedp.idevento = crapced.idevento 
                            AND (crapedp.nrseqpgm = INT(nrseqpgm)
                             OR INT(nrseqpgm) = 0) NO-LOCK. END.
      
        IF NOT AVAILABLE crapedp THEN
          ASSIGN aux_cdtpeven = 0.
        ELSE
          ASSIGN aux_cdtpeven = crapedp.tpevento.
        /* Somente atualiza previsto dos EAD*/
        IF aux_cdtpeven = 10 THEN    
          DO:
            /* Turmas */
            FIND turmasEAD WHERE turmasEAD.cdagenci = crapced.cdagenci EXCLUSIVE-LOCK NO-ERROR.

            IF NOT AVAILABLE turmasEAD THEN
              DO:
                CREATE turmasEAD.
                ASSIGN turmasEAD.cdagenci = crapced.cdagenci.
              END.

            /* Participantes */
            FIND participantesEAD WHERE participantesEAD.cdagenci = crapced.cdagenci EXCLUSIVE-LOCK NO-ERROR.

            IF NOT AVAILABLE participantesEAD   THEN
              DO:
                CREATE participantesEAD.
                ASSIGN participantesEAD.cdagenci = crapced.cdagenci
                       aux_qtmaxtur = 0.
              END.      
          
            ASSIGN participantesEAD.qtprevis = participantesEAD.qtprevis + (crapced.qtocoeve * crapced.qtpareve)
                   turmasEAD.qtprevis = turmasEAD.qtprevis + crapced.qtocoeve.
        
            FIND crapage WHERE crapage.cdcooper = crapced.cdcooper
                           AND crapage.cdagenci = crapced.cdagenci NO-LOCK NO-ERROR.

            /* Monta o nome do PA com os PA'S agrupados, caso houver */
            ASSIGN turmasEAD.nmresage        = crapage.nmresage
                   participantesEAD.nmresage = crapage.nmresage.
          END.
  END. /* Fim crapced */
   
  /* *** Logo Cooperativa *** */
  {&out} '   <br><div width="800px" style="text-align:left; float:left; padding-top:10px;"><table border="0" cellspacing="0" cellpadding="0" style="float:left;">' SKIP
         '      <tr>' SKIP
         '         <td align="left">&nbsp;&nbsp;&nbsp;<img src="' imagemDaCooperativa '" border="0"></td>' SKIP
         '         <td class="tdTitulo1" align="left">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;' nomeDaCooperativa '</td>' SKIP
         '      </tr>' SKIP
         '   </table><div>' SKIP. 

  {&out} '<br>' SKIP.

  turmas().
  {&out} '<div style="clear:both"></div>' skip.
                
  /*{&out} '<br><br><br>' SKIP.*/
  
  turmasEAD().
  {&out} '<div style="clear:both"></div>' skip.    
  participantes().
 
  {&out} '<div style="clear:both"></div>' skip.  
 
  participantesEAD().

	{&out} '<br>' SKIP.
	
  IF msgsDeErro <> "" THEN
    {&out} '   <table border="0" cellspacing="1" cellpadding="1">' SKIP
           '      <tr>' SKIP
           '         <td>' msgsDeErro '</td>' SKIP
           '      </tr>' SKIP
           '   </table>' SKIP.

  {&out} '<br>' SKIP.
  
  RETURN TRUE.

END FUNCTION. /* montaTela RETURNS LOGICAL () */

FUNCTION exibeTelaDetalhado RETURNS LOGICAL ():

	  /* *** Logo Cooperativa *** */
    {&out} ' <br><div width="800px" style="text-align:left;float:left;"><table border="0" cellspacing="0" cellpadding="0" style=" float:left;" >' SKIP
           '      <tr>' SKIP
		   '         <td align="left">&nbsp;&nbsp;&nbsp;<img src="' imagemDaCooperativa '" border="0"></td>' SKIP
		   '         <td class="tdTitulo1" align="left">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;' nomeDaCooperativa '</td>' SKIP
		   '      </tr>' SKIP
           '   </table><div>' SKIP. 
           
   
	  {&out} '<br>' SKIP.	
	
    FOR EACH turmasDetalhado NO-LOCK
         BREAK BY turmasDetalhado.nmresage
                BY turmasDetalhado.tpevento desc 
                 BY turmasDetalhado.nmevento:
                 
    
      IF FIRST-OF(turmasDetalhado.nmresage) THEN      
        DO:
          {&out} '<div style="clear:both"></div><br>' skip.   
          {&out} 	SKIP SKIP SKIP '  <font align="left" style="font-family: Arial, Helvetica, sans-serif; font-size: 11px; font-weight: bold; float: left;">' SKIP
                  turmasDetalhado.nmresage SKIP
                   '  </font>' SKIP.
          {&out} '<div style="clear:both"></div><br>' skip.   
              
        END.
        
      IF FIRST-OF(turmasDetalhado.tpevento) THEN
        DO:         
          ASSIGN prt_ttprevis = 0
                 prt_ttrealiz = 0
                 prt_ttrecoop = 0
                 prt_ttrecomu = 0.   
                                  
                 {&out}  '   <table class="tab2" border="1" cellspacing="0" cellpadding="0" width="850px" align="center" style="float:left;">' SKIP.
                     
                 {&out}  '     <tr>' SKIP
                         '       <td class="td2" align="center" width="40%">' SKIP
                         '         EVENTO ' turmasDetalhado.tpevento SKIP
                         '       </td>' SKIP
                         '       <td class="td2" align="center" width="16%">' SKIP
                         '         DATA' SKIP
                         '       </td>' SKIP
                         '       <td class="td2" align="center" width="11%">' SKIP
                         '         PREVISTO' SKIP
                         '       </td>' SKIP
                         '       <td class="td2" align="center" width="11%">' SKIP
                         '         COOP.' SKIP
                         '       </td>' SKIP
                         '       <td class="td2" align="center" width="11%">' SKIP
                         '         COMU.' SKIP
                         '       </td>' SKIP
                         '       <td class="td2" align="center" width="11%">' SKIP
                         '         TOTAL' SKIP
                         '       </td>' SKIP
                         '     </tr>' SKIP.
        
        END.
    
      /* Nome do evento */
      IF FIRST-OF(turmasDetalhado.nmevento)   THEN   
        aux_nmevento = UPPER(turmasDetalhado.nmevento).
      ELSE
        aux_nmevento = "&nbsp;".

      {&out} '     <tr>' SKIP
             '       <td class="td2" align="left">' SKIP
                       aux_nmevento SKIP
             '       </td>' SKIP
             '       <td class="tdDados2" align="center">'
             turmasDetalhado.dscddata  ' </td>' SKIP.
                  
      {&out} '       <td class="tdDados2" align="center">'
             turmasDetalhado.qtprevis ' </td>' SKIP.
      
      IF turmasDetalhado.idstaeve = 2 THEN  /* Cancelado */
			DO:
				{&out} '       <td class="tdDados2" align="center" colspan="3">' SKIP
					   'CANCELADO </td>' SKIP.
			END.
        ELSE
        DO:
          {&out} '       <td class="tdDados2" align="center">' SKIP
               turmasDetalhado.qtrecoop SKIP
               '       </td>' SKIP.
          {&out} '       <td class="tdDados2" align="center">' SKIP
               turmasDetalhado.qtrecomu SKIP
               '       </td>' SKIP.
          {&out} '       <td class="tdDados2" align="center">' SKIP
               turmasDetalhado.qtrealiz SKIP
               '       </td>' SKIP.
		    END.
        
      {&out} '     </tr>' SKIP.  
      
      ASSIGN prt_ttrealiz = prt_ttrealiz + turmasDetalhado.qtrealiz
             prt_ttrecoop = prt_ttrecoop + turmasDetalhado.qtrecoop
             prt_ttrecomu = prt_ttrecomu + turmasDetalhado.qtrecomu
             prt_ttprevis = prt_ttprevis + turmasDetalhado.qtprevis.
      
      IF LAST-OF(turmasDetalhado.tpevento)THEN
        DO:
         {&out} '     <tr>' SKIP
                '       <td class="td2" align="left">' SKIP
                '         TOTAL' SKIP
                '       </td>' SKIP
                '       <td class="td2" align="left">' SKIP
                '         &nbsp;' SKIP
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
                {&out}  '<div style="clear:both"></div><br>' skip.   
        END.
    
    END.         
    /** Fim exibe detalhe **/
	
    RETURN TRUE.

END FUNCTION. /* exibeTelaDetalhado RETURNS LOGICAL () */

FUNCTION montaTelaDetalhado RETURNS LOGICAL ():

    /* Eventos */
    FOR EACH crapadp WHERE crapadp.idevento = idevento         
                       AND crapadp.cdcooper = crapcop.cdcooper
                       AND crapadp.dtanoage = dtanoage           NO-LOCK,
						   
		FIRST crapedp WHERE crapedp.idevento = crapadp.idevento
                    AND crapedp.cdcooper = crapadp.cdcooper
                    AND crapedp.dtanoage = crapadp.dtanoage
                    AND crapedp.cdevento = crapadp.cdevento 
                    AND (crapedp.nrseqpgm = INT(nrseqpgm)    
                     OR INT(nrseqpgm) = 0) NO-LOCK, 
							
        FIRST crapage WHERE crapage.cdcooper = crapadp.cdcooper
                        AND crapage.cdagenci = crapadp.cdagenci NO-LOCK
                          BREAK BY crapage.nmresage 
                                 BY crapedp.tpevento
                                  BY crapedp.nmevento:
        
        
        FIND FIRST turmasDetalhado  
          WHERE turmasDetalhado.cdcooper = crapadp.cdcooper
            AND turmasDetalhado.cdevento = crapadp.cdevento
            AND turmasDetalhado.cdagenci = crapadp.cdagenci
            AND turmasDetalhado.nrseqdig = crapadp.nrseqdig
            NO-LOCK NO-ERROR.
            
        IF NOT avail turmasDetalhado THEN    
          CREATE turmasDetalhado.
        
        /* Monta o nome do PAC com os PACS agrupados, caso houver */
        IF FIRST-OF(crapage.nmresage)    THEN
          DO:
            ASSIGN aux_qtmaxtur = 0
                   aux_nmresage = crapage.nmresage.

            FOR EACH crapagp  WHERE crapagp.cdcooper  = crapadp.cdcooper   
                                AND crapagp.idevento  = crapadp.idevento   
                                AND crapagp.dtanoage  = crapadp.dtanoage   
                                AND crapagp.cdageagr  = crapadp.cdagenci   
                                AND crapagp.cdageagr <> crapagp.cdagenci NO-LOCK,
                         
              FIRST crabage WHERE crabage.cdcooper = crapagp.cdcooper
                              AND crabage.cdagenci = crapagp.cdagenci NO-LOCK
                               BY crabage.nmresage:

              aux_nmresage = aux_nmresage + " / " + crabage.nmresage.
            END.
          END.        
          
        IF crapedp.tpevento = 10 THEN /* EVENTOS EAD */
          DO:
            ASSIGN aux_tpevento = 'EAD'.
          END.
        ELSE 
          DO:
            ASSIGN aux_tpevento = 'PRESENCIAL'.
          END.
          
         
        ASSIGN turmasDetalhado.tpevento = aux_tpevento
               turmasDetalhado.nrseqdig = crapadp.nrseqdig 
               turmasDetalhado.cdagenci = crapadp.cdagenci
               turmasDetalhado.nmresage = aux_nmresage
               turmasDetalhado.cdevento = crapedp.cdevento
               turmasDetalhado.cdcooper = crapadp.cdcooper
               turmasDetalhado.nmevento = UPPER(crapedp.nmevento).
          
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
                           AND crapidp.idstains = 2 /*Confirmado*/   NO-LOCK:

            /* Se o evento já ocorreu e NAO FOI CANCELADO, conta os que COMPARECERAM */
            IF crapadp.dtfineve  < TODAY AND
               crapadp.idstaeve <> 2     THEN DO:    
                 /* Se percentual de faltas for suficiente em relacao ao percentual mínimo exigido */
                 IF ((crapidp.qtfaleve * 100) / crapadp.qtdiaeve) <= (100 - crapedp.prfreque) THEN DO:
                    prt_qtrealiz = prt_qtrealiz + 1.
                    IF crapidp.tpinseve = 1 THEN 
                       prt_qtrecoop = prt_qtrecoop + 1.
                    ELSE
                       prt_qtrecomu = prt_qtrecomu + 1.
                 END.
            END.
                        
        END.
       
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
              FIND FIRST crapeap WHERE crapeap.cdcooper = crapadp.cdcooper 
                                   AND crapeap.idevento = crapadp.idevento                                      
                                   AND crapeap.cdevento = crapadp.cdevento 
                                   AND crapeap.dtanoage = crapadp.dtanoage 
                                   AND crapeap.cdagenci = crapadp.cdagenci NO-LOCK.
               
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
          END. /*Fim IF CRAPHEP */   
        ELSE
          DO:
            FOR FIRST crapced WHERE crapced.dtanoage = crapadp.dtanoage
                                AND crapced.cdcooper = crapadp.cdcooper
                                AND crapced.cdagenci = crapadp.cdagenci
                                AND crapced.cdevento = crapadp.cdevento NO-LOCK. END.
                                                 
            IF AVAILABLE crapced THEN                                      
              ASSIGN aux_qtmaxtur = aux_qtmaxtur + (crapced.qtocoeve * crapced.qtpareve).
              
          END.        
        
        /****************/
        
			
        IF crapadp.dtinieve = ? THEN
          ASSIGN turmasDetalhado.dscddata = 'INDEFINIDO'.
        ELSE IF crapadp.dtinieve = crapadp.dtfineve   THEN
          ASSIGN turmasDetalhado.dscddata = STRING(crapadp.dtinieve).
        ELSE
          ASSIGN turmasDetalhado.dscddata = STRING(crapadp.dtinieve) +  
                                            ' a ' + STRING(crapadp.dtfineve).
        
      
        ASSIGN turmasDetalhado.qtprevis = aux_qtmaxtur.
        ASSIGN turmasDetalhado.idstaeve = crapadp.idstaeve.   			
        ASSIGN turmasDetalhado.qtrecoop = prt_qtrecoop
               turmasDetalhado.qtrecomu = prt_qtrecomu
               turmasDetalhado.qtrealiz = prt_qtrealiz.              

    END.
    /* FIM - Eventos */
    
    /*Buscar eventos para garantir que sejam apresentados
      todos os PAs para o EAD*/
    FOR EACH crapced WHERE crapced.idevento = idevento
                       AND crapced.dtanoage = dtanoage
                       AND crapced.cdcooper = crapcop.cdcooper NO-LOCK:
                     
      FOR FIRST crapedp WHERE crapedp.cdevento = crapced.cdevento
                          AND crapedp.cdcooper = 0
                          AND crapedp.dtanoage = 0
                          AND crapedp.idevento = crapced.idevento 
                          AND (crapedp.nrseqpgm = INT(nrseqpgm)   
                           OR INT(nrseqpgm) = 0) NO-LOCK. END.
    
      IF NOT AVAILABLE crapedp THEN
        ASSIGN aux_cdtpeven = 0.
      ELSE
        ASSIGN aux_cdtpeven = crapedp.tpevento.
      /* Somente atualiza previsto dos EAD*/
      IF aux_cdtpeven = 10 THEN    
        DO:
          
          FIND FIRST turmasDetalhado  
            WHERE turmasDetalhado.cdcooper = crapced.cdcooper
              AND turmasDetalhado.cdevento = crapced.cdevento
              AND turmasDetalhado.cdagenci = crapced.cdagenci
              NO-LOCK NO-ERROR.
              
          IF NOT avail turmasDetalhado THEN    
          DO:            
            CREATE turmasDetalhado.
          END.
          ELSE
          DO:
             NEXT.
          END.
          
          ASSIGN turmasDetalhado.qtprevis = turmasDetalhado.qtprevis + 
                                            (crapced.qtocoeve * crapced.qtpareve).
      
          FIND crapage WHERE crapage.cdcooper = crapced.cdcooper
                         AND crapage.cdagenci = crapced.cdagenci NO-LOCK NO-ERROR.

          /* Monta o nome do PA com os PA'S agrupados, caso houver */
          ASSIGN turmasDetalhado.nmresage  = crapage.nmresage
                 turmasDetalhado.tpevento  = "EAD"
                 turmasDetalhado.dscddata  = 'INDEFINIDO'
                 turmasDetalhado.cdagenci  = crapage.cdagenci
                 turmasDetalhado.cdevento  = crapedp.cdevento
                 turmasDetalhado.nmevento  = UPPER(crapedp.nmevento).
        END.    
    
    END.
    
    exibeTelaDetalhado().
    
    IF msgsDeErro <> "" THEN
	   {&out} '   <table border="0" cellspacing="1" cellpadding="1">' SKIP
			  '      <tr>' SKIP
			  '         <td>' msgsDeErro '</td>' SKIP
			  '      </tr>' SKIP
			  '   </table><br><br>' SKIP.
	
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

/* Usado FOR EACH para poder utilizar o CONTAINS e WORD-INDEX. alterado para MATCHES */
FOR EACH gnapses WHERE gnapses.idsessao MATCHES "*" + cookieEmUso + "*" NO-LOCK:
    LEAVE.
END.

RUN PermissaoDeAcesso("", OUTPUT IdentificacaoDaSessao, OUTPUT permiteExecutar).

  IF permiteExecutar = "1" OR permiteExecutar = "2" THEN
    erroNaValidacaoDoLogin(permiteExecutar).
  ELSE
    DO:
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
						
						imagemDaCooperativa = "/cecred/images/admin/logo_" +  aux_nmrescop.
					END.
				ELSE
					imagemDaCooperativa = "/cecred/images/admin/logo_" + TRIM(LC(crapcop.nmrescop)) + ".gif" .
				
				IF detalhar THEN
					montaTelaDetalhado().
				ELSE
					montatela().
          
			  {&out} '<div style="clear:both"></div>' skip.  
      END.
      
			montaRodape().
		END.
          
PROCEDURE PermissaoDeAcesso:
  {includes/wpgd0009.i}
END PROCEDURE.