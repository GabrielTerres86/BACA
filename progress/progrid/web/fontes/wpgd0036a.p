/* .............................................................................

  Programa wpgd0036a.p - Listagem de orçamento (chamado a partir dos dados de wpgd0036)

  Alterações: 03/11/2008 - Inclusao widget-pool (martin)

              10/12/2008 - Melhoria de performance para a tabela gnapses (Evandro).
                          
              05/06/2012 - Adaptação dos fontes para projeto Oracle. Alterado
                           busca na gnapses de CONTAINS para MATCHES (Guilherme Maba).
              
              28/11/2012 - Substituir tabela "gncoper" por "crapcop"
                           (David Kruger).
                           
              04/04/2013 - Alteração para receber logo na alto vale,
                           recebendo nome de viacrediav e buscando com
                           o respectivo nome (David Kruger).              
              
              29/08/2013 - Nova forma de chamar as agências, de PAC agora 
                           a escrita será PA (André Euzébio - Supero).
                             
              29/08/2017 - Inclusao do filtro por Programa,Prj. 322 (Jean Michel).
             
............................................................................. */

create widget-pool.

DEFINE TEMP-TABLE ttCrapcdp LIKE Crapcdp
    FIELD NrSeqDig            AS INTEGER
    FIELD DtIniEve            AS DATE
    FIELD DtFinEve            AS DATE
    FIELD NomeDoEvento        AS CHARACTER
    FIELD NomeDoPac           AS CHARACTER
    FIELD NomeDoTipoDoCusto   AS CHARACTER
    FIELD ValorRealizado      AS DECIMAL
    FIELD ValorDiferenca      AS DECIMAL
    FIELD PercentualDiferenca AS DECIMAL
    FIELD Sequenciador        AS INTEGER
    FIELD Mes                 AS INTEGER
    FIELD Ano                 AS INTEGER
    FIELD Auxiliar1           AS CHARACTER
    FIELD sobreNomeDoEvento1  AS CHARACTER
    FIELD sobreNomeDoEvento2  AS CHARACTER
    INDEX ttCrapcdp1 AS PRIMARY UNIQUE idevento cdcooper cdagenci dtanoage tpcuseve cdevento cdcuseve nrseqdig.



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
DEFINE VARIABLE nrseqpgm                     AS INTEGER.
DEFINE VARIABLE consideraEventosForaDaAgenda AS LOGICAL.

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
DEFINE VARIABLE corEmUso                     AS CHARACTER.
DEFINE VARIABLE mes                          AS CHARACTER INITIAL ["janeiro,fevereiro,março,abril,maio,junho,julho,agosto,setembro,outubro,novembro,dezembro"].
DEFINE VARIABLE sobreNomeDoEvento            AS CHARACTER.
DEFINE VARIABLE valorDaVerba                 AS DECIMAL.
DEFINE VARIABLE aux_nmrescop                 AS CHARACTER.


/*****************************************************************************/
/*                                                                           */
/*   Bloco de includes                                                       */
/*                                                                           */
/*****************************************************************************/

{src/web/method/wrap-cgi.i}


/*****************************************************************************/
/*                                                                           */
/*   Bloco de funçoes                                                        */
/*                                                                           */
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


FUNCTION montaTelaAnalitico RETURNS LOGICAL ():

    DEFINE VARIABLE totalPrevisto        AS DECIMAL.
    DEFINE VARIABLE totalRealizado       AS DECIMAL.
    DEFINE VARIABLE totalDiferenca       AS DECIMAL.
    DEFINE VARIABLE totalPercentual      AS DECIMAL.
    DEFINE VARIABLE totalDoPacPrevisto   AS DECIMAL.
    DEFINE VARIABLE totalDoPacRealizado  AS DECIMAL.
    DEFINE VARIABLE totalDoPacDiferenca  AS DECIMAL.
    DEFINE VARIABLE totalDoPacPercentual AS DECIMAL.
    
    {&out} '   <table border="0" cellspacing="0" cellpadding="0" width="100%">' SKIP.
    ASSIGN corEmUso = "#FFFFFF".

    FOR EACH ttCrapcdp WHERE ttCrapcdp.TpCusEve = 1 NO-LOCK 
                             BREAK BY ttCrapcdp.IdEvento 
                                   BY ttCrapcdp.CdCooper 
                                   BY ttCrapcdp.CdAgenci 
                                   BY ttCrapcdp.Auxiliar1 
                                   BY ttCrapcdp.CdCusEve:

        IF FIRST-OF(ttCrapcdp.CdAgenci) THEN DO:
            
            {&out} '      <tr>' SKIP
                   '         <td class="tdCab1" colspan="5">Pa: ' ttCrapcdp.CdAgenci ' - '  ttCrapcdp.NomeDoPac '</td>' SKIP
                   '      </tr>' SKIP.
            ASSIGN totalDoPacPrevisto   = 0
                   totalDoPacRealizado  = 0
                   totalDoPacDiferenca  = 0
                   totalDoPacPercentual = 0.
        END.

        IF FIRST-OF(ttCrapcdp.Auxiliar1) THEN DO:
            {&out} '      <tr>' SKIP
                 '         <td class="tdCab2" colspan="5">Evento: ' ttCrapcdp.CdEvento ' - '  ttCrapcdp.NomeDoEvento ttCrapcdp.SobreNomeDoEvento1 '</td>' SKIP
                 '      </tr>' SKIP.
                       
            {&out} '      <tr class="tdCab3">'                            SKIP
                 '         <td>Tipo de despesa</td>'                      SKIP
                 '         <td align="right">Previsto</td>'               SKIP
                 '         <td align="right">Realizado</td>'              SKIP
                 '         <td align="right">Saldo</td>'                  SKIP
                 '         <td align="right">%Gasto</td>'                  SKIP
                 '      </tr>'                                            SKIP.
            
            ASSIGN totalPrevisto   = 0
                   totalRealizado  = 0
                   totalDiferenca  = 0
                   totalPercentual = 0.
        END.

        
        ASSIGN totalPrevisto        = totalPrevisto        + ttCrapcdp.VlCusEve
               totalRealizado       = totalRealizado       + ttCrapcdp.ValorRealizado
               totalDiferenca       = totalDiferenca       + ttCrapcdp.ValorDiferenca
               totalPercentual      = ((totalRealizado  / totalPrevisto) * 100)

               totalDoPacPrevisto   = totalDoPacPrevisto   + ttCrapcdp.VlCusEve
               totalDoPacRealizado  = totalDoPacRealizado  + ttCrapcdp.ValorRealizado
               totalDoPacDiferenca  = totalDoPacDiferenca  + ttCrapcdp.ValorDiferenca
               totalDoPacPercentual = ((totalDoPacRealizado / totalDoPacPrevisto) * 100).
        
               
    
        {&out} '      <tr bgcolor="' corEmUso '">' SKIP
               '         <td>' ttCrapcdp.CdCusEve ' - '  ttCrapcdp.NomeDoTipoDoCusto '</td>' SKIP
               '         <td align="right">' ttCrapcdp.VlCusEve FORMAT "-zzz,zzz,zz9.99" '&nbsp;&nbsp;</td>' SKIP
               '         <td align="right">' ttCrapcdp.ValorRealizado FORMAT "-zzz,zzz,zz9.99" '&nbsp;&nbsp;</td>' SKIP
               '         <td align="right"' IF ttCrapcdp.ValorDiferenca < 0 THEN ' style="color: #AA0000"' ELSE '' '>' ttCrapcdp.ValorDiferenca FORMAT "-zzz,zzz,zz9.99" '&nbsp;&nbsp;</td>' SKIP
               '         <td align="right"' IF ttCrapcdp.PercentualDiferenca < 0 THEN ' style="color: #AA0000"' ELSE '' '>' ttCrapcdp.PercentualDiferenca FORMAT "-z,zz9.99%" '&nbsp;&nbsp;</td>' SKIP
               '      </tr>' SKIP.
    
        IF corEmUso = "#FFFFFF" THEN
            ASSIGN corEmUso = "#F5F5F5".
        ELSE
            ASSIGN corEmUso = "#FFFFFF".
    
        IF LAST-OF(ttCrapcdp.Auxiliar1) THEN
            {&out} '      <tr bgcolor="' corEmUso '">' SKIP
                  '         <td> &nbsp; </td>' SKIP
                  '         <td align="right" style="border-top: 1px #000000 solid">' totalPrevisto FORMAT "-zzz,zzz,zz9.99" '&nbsp;&nbsp;</td>' SKIP
                  '         <td align="right" style="border-top: 1px #000000 solid">' totalRealizado FORMAT "-zzz,zzz,zz9.99" '&nbsp;&nbsp;</td>' SKIP
                  '         <td align="right"' IF totalDiferenca < 0 THEN ' style="color: #AA0000; border-top: 1px #000000 solid"' ELSE ' style="border-top: 1px #000000 solid"' '>' totalDiferenca FORMAT "-zzz,zzz,zz9.99" '&nbsp;&nbsp;</td>' SKIP
                  '         <td align="right"' IF totalPercentual < 0 THEN ' style="color: #AA0000; border-top: 1px #000000 solid"' ELSE ' style="border-top: 1px #000000 solid"' '>' totalPercentual FORMAT "-z,zz9.99%" '&nbsp;&nbsp;</td>' SKIP
                  '      </tr>' SKIP
                  '      <tr><td colspan="5" align="center"> &nbsp; </td></tr>' SKIP.
    
        IF LAST-OF(ttCrapcdp.CdAgenci) THEN DO:

              /* *** Busca verba para o Pa *** */
              FIND Crapvdp WHERE Crapvdp.IdEvento = ttCrapcdp.IdEvento AND
                                 Crapvdp.CdCooper = ttCrapcdp.CdCooper AND
                                 Crapvdp.CdAgenci = ttCrapcdp.CdAgenci AND
                                 Crapvdp.DtAnoAge = ttCrapcdp.DtAnoAge NO-LOCK NO-ERROR.
              IF AVAILABLE Crapvdp THEN
                  ASSIGN valorDaVerba = Crapvdp.VlVerbaT.
              ELSE
                  ASSIGN valorDaVerba = ?.

              {&out} '      <tr class="tdCab3">' SKIP
                     '         <td>Totais para o Pa: ' ttCrapcdp.CdAgenci ' - '  ttCrapcdp.NomeDoPac ' (Verba = ' valorDaVerba FORMAT "R$ ->>>,>>>,>>9.99" ')</td>' SKIP
                     '         <td align="right" style="border-top: 1px #000000 solid">' totalDoPacPrevisto FORMAT "-zzz,zzz,zz9.99" '&nbsp;&nbsp;</td>' SKIP
                     '         <td align="right" style="border-top: 1px #000000 solid">' totalDoPacRealizado FORMAT "-zzz,zzz,zz9.99" '&nbsp;&nbsp;</td>' SKIP
                     '         <td align="right"' IF totalDoPacDiferenca < 0 THEN ' style="color: #AA0000; border-top: 1px #000000 solid"' ELSE ' style="border-top: 1px #000000 solid"' '>' totalDoPacDiferenca FORMAT "-zzz,zzz,zz9.99" '&nbsp;&nbsp;</td>' SKIP
                     '         <td align="right"' IF totalDoPacPercentual < 0 THEN ' style="color: #AA0000; border-top: 1px #000000 solid"' ELSE ' style="border-top: 1px #000000 solid"' '>' totalDoPacPercentual FORMAT "-z,zz9.99%" '&nbsp;&nbsp;</td>' SKIP
                     '      </tr>' SKIP
                     '      <tr><td colspan="5" align="center"> &nbsp; </td></tr>' SKIP
                     '      <tr><td colspan="5" align="center"><hr></td></tr>' SKIP
                     '      <tr><td colspan="5" align="center"> &nbsp; </td></tr>' SKIP.
           END.

        END. /* FOR EACH ttCrapcdp  */
    
        {&out} '   </table>' SKIP.

    RETURN TRUE.

END FUNCTION. /* montaTelaAnalitico RETURNS LOGICAL () */


FUNCTION montaTelaSinteticoPorPac RETURNS LOGICAL ():

    DEFINE VARIABLE totalPrevisto        AS DECIMAL.
    DEFINE VARIABLE totalRealizado       AS DECIMAL.
    DEFINE VARIABLE totalDiferenca       AS DECIMAL.
    DEFINE VARIABLE totalPercentual      AS DECIMAL.
    DEFINE VARIABLE totalDoPacPrevisto   AS DECIMAL.
    DEFINE VARIABLE totalDoPacRealizado  AS DECIMAL.
    DEFINE VARIABLE totalDoPacDiferenca  AS DECIMAL.
    DEFINE VARIABLE totalDoPacPercentual AS DECIMAL.
    
    {&out} '   <table border="0" cellspacing="0" cellpadding="1" width="100%">' SKIP.
    ASSIGN corEmUso = "#FFFFFF".

    FOR EACH ttCrapcdp WHERE ttCrapcdp.TpCusEve = 1 NO-LOCK BREAK BY ttCrapcdp.IdEvento BY ttCrapcdp.CdCooper BY ttCrapcdp.CdAgenci BY ttCrapcdp.Auxiliar1:

        IF FIRST-OF(ttCrapcdp.CdAgenci) 
           THEN
               DO:
                  {&out} '      <tr>' SKIP
                         '         <td class="tdCab1" colspan="5">Pa: ' ttCrapcdp.CdAgenci ' - '  ttCrapcdp.NomeDoPac '</td>' SKIP
                         '      </tr>' SKIP
                         '      <tr class="tdCab3">' SKIP
                         '         <td>Evento</td>' SKIP
                         '         <td align="right">Previsto</td>' SKIP
                         '         <td align="right">Realizado</td>' SKIP
                         '         <td align="right">Saldo</td>' SKIP
                         '         <td align="right">% Gasto</td>' SKIP
                         '      </tr>' SKIP.
                  
                  ASSIGN totalDoPacPrevisto   = 0
                         totalDoPacRealizado  = 0
                         totalDoPacDiferenca  = 0
                         totalDoPacPercentual = 0.
               END.

        IF FIRST-OF(ttCrapcdp.Auxiliar1) 
           THEN
               ASSIGN totalPrevisto   = 0
                      totalRealizado  = 0
                      totalDiferenca  = 0
                      totalPercentual = 0.
    
        ASSIGN totalPrevisto        = totalPrevisto        + ttCrapcdp.VlCusEve
               totalRealizado       = totalRealizado       + ttCrapcdp.ValorRealizado
               totalDiferenca       = totalDiferenca       + ttCrapcdp.ValorDiferenca
               totalPercentual      = ((totalRealizado / totalPrevisto) * 100)

               totalDoPacPrevisto   = totalDoPacPrevisto   + ttCrapcdp.VlCusEve
               totalDoPacRealizado  = totalDoPacRealizado  + ttCrapcdp.ValorRealizado
               totalDoPacDiferenca  = totalDoPacDiferenca  + ttCrapcdp.ValorDiferenca
               totalDoPacPercentual = ((totalDoPacRealizado / totalDoPacPrevisto) * 100).
                   
        IF LAST-OF(ttCrapcdp.Auxiliar1)
           THEN
               DO:
                  IF corEmUso = "#FFFFFF"
                     THEN
                         ASSIGN corEmUso = "#F5F5F5".
                     ELSE
                         ASSIGN corEmUso = "#FFFFFF".

                  {&out} '      <tr bgcolor="' corEmUso '">' SKIP
                         '         <td>' ttCrapcdp.CdEvento ' - '  ttCrapcdp.NomeDoEvento ttCrapcdp.SobreNomeDoEvento2 '</td>' 
                         '         <td align="right">' totalPrevisto FORMAT "-zzz,zzz,zz9.99" '&nbsp;&nbsp;</td>' SKIP
                         '         <td align="right">' totalRealizado FORMAT "-zzz,zzz,zz9.99" '&nbsp;&nbsp;</td>' SKIP
                         '         <td align="right"' IF totalDiferenca < 0 THEN ' style="color: #AA0000"' ELSE '' '>' totalDiferenca FORMAT "-zzz,zzz,zz9.99" '&nbsp;&nbsp;</td>' SKIP
                         '         <td align="right"' IF totalPercentual < 0 THEN ' style="color: #AA0000"' ELSE '' '>' totalPercentual FORMAT "-z,zz9.99%" '&nbsp;&nbsp;</td>' SKIP
                         '      </tr>' SKIP.
               END.

        IF LAST-OF(ttCrapcdp.CdAgenci) 
           THEN
               DO:
                  /* *** Busca verba para o Pa *** */
                  FIND Crapvdp WHERE Crapvdp.IdEvento = ttCrapcdp.IdEvento AND
                                     Crapvdp.CdCooper = ttCrapcdp.CdCooper AND
                                     Crapvdp.CdAgenci = ttCrapcdp.CdAgenci AND
                                     Crapvdp.DtAnoAge = ttCrapcdp.DtAnoAge NO-LOCK NO-ERROR.
                  IF AVAILABLE Crapvdp
                     THEN
                         ASSIGN valorDaVerba = Crapvdp.VlVerbaT.
                     ELSE
                         ASSIGN valorDaVerba = ?.
                  {&out} '      <tr class="tdCab3">' SKIP
                         '         <td>Totais para o Pa: ' ttCrapcdp.CdAgenci ' - '  ttCrapcdp.NomeDoPac ' (Verba = ' valorDaVerba FORMAT "R$ ->>>,>>>,>>9.99" ')</td>' SKIP
                         '         <td align="right" style="border-top: 1px #000000 solid">' totalDoPacPrevisto FORMAT "-zzz,zzz,zz9.99" '&nbsp;&nbsp;</td>' SKIP
                         '         <td align="right" style="border-top: 1px #000000 solid">' totalDoPacRealizado FORMAT "-zzz,zzz,zz9.99" '&nbsp;&nbsp;</td>' SKIP
                         '         <td align="right"' IF totalDoPacDiferenca < 0 THEN ' style="color: #AA0000; border-top: 1px #000000 solid"' ELSE ' style="border-top: 1px #000000 solid"' '>' totalDoPacDiferenca FORMAT "-zzz,zzz,zz9.99" '&nbsp;&nbsp;</td>' SKIP
                         '         <td align="right"' IF totalDoPacPercentual < 0 THEN ' style="color: #AA0000; border-top: 1px #000000 solid"' ELSE ' style="border-top: 1px #000000 solid"' '>' totalDoPacPercentual FORMAT "-z,zz9.99%" '&nbsp;&nbsp;</td>' SKIP
                         '      </tr>' SKIP
                         '      <tr><td colspan="5" align="center"> &nbsp; </td></tr>' SKIP
                         '      <tr><td colspan="5" align="center"><hr></td></tr>' SKIP
                         '      <tr><td colspan="5" align="center"> &nbsp; </td></tr>' SKIP.
               END.

    END. /* FOR EACH ttCrapcdp */
    
    {&out} '   </table>' SKIP.

    RETURN TRUE.

END FUNCTION. /* montaTelaSinteticoPorPac RETURNS LOGICAL () */


FUNCTION montaTelaSinteticoPorEvento RETURNS LOGICAL ():

    DEFINE VARIABLE totalPrevisto           AS DECIMAL.
    DEFINE VARIABLE totalRealizado          AS DECIMAL.
    DEFINE VARIABLE totalDiferenca          AS DECIMAL.
    DEFINE VARIABLE totalPercentual         AS DECIMAL.
    DEFINE VARIABLE totalDoEventoPrevisto   AS DECIMAL.
    DEFINE VARIABLE totalDoEventoRealizado  AS DECIMAL.
    DEFINE VARIABLE totalDoEventoDiferenca  AS DECIMAL.
    DEFINE VARIABLE totalDoEventoPercentual AS DECIMAL.
    
    {&out} '   <table border="0" cellspacing="0" cellpadding="1" width="100%">' SKIP.
    ASSIGN corEmUso = "#FFFFFF".

    FOR EACH ttCrapcdp WHERE ttCrapcdp.TpCusEve = 1 NO-LOCK BREAK BY ttCrapcdp.CdEvento BY ttCrapcdp.CdAgenci BY ttCrapcdp.Auxiliar1:

        IF FIRST-OF(ttCrapcdp.CdEvento) 
           THEN
               DO:
                  {&out} '      <tr>' SKIP
                         '         <td class="tdCab1" colspan="5">Evento: ' ttCrapcdp.CdEvento ' - '  ttCrapcdp.NomeDoEvento '</td>' SKIP
                         '      </tr>' SKIP
                         '      <tr class="tdCab3">' SKIP
                         '         <td>PA</td>' SKIP
                         '         <td align="right">Previsto</td>' SKIP
                         '         <td align="right">Realizado</td>' SKIP
                         '         <td align="right">Saldo</td>' SKIP
                         '         <td align="right">% Gasto</td>' SKIP
                         '      </tr>' SKIP.
               END.

        ASSIGN totalPrevisto           = totalPrevisto           + ttCrapcdp.VlCusEve
               totalRealizado          = totalRealizado          + ttCrapcdp.ValorRealizado
               totalDiferenca          = totalDiferenca          + ttCrapcdp.ValorDiferenca
               totalPercentual         = ((totalRealizado / totalPrevisto) * 100)

               totalDoEventoPrevisto   = totalDoEventoPrevisto   + ttCrapcdp.VlCusEve
               totalDoEventoRealizado  = totalDoEventoRealizado  + ttCrapcdp.ValorRealizado
               totalDoEventoDiferenca  = totalDoEventoDiferenca  + ttCrapcdp.ValorDiferenca
               totalDoEventoPercentual = ((totalDoEventoRealizado / totalDoEventoPrevisto) * 100).
                   
        IF LAST-OF(ttCrapcdp.CdAgenci)
           THEN
               DO:
                  {&out} '      <tr bgcolor="' corEmUso '">' SKIP
                         '         <td>' ttCrapcdp.CdAgenci ' - '  ttCrapcdp.NomeDoPac '</td>' SKIP
                         '         <td align="right">' totalPrevisto FORMAT "-zzz,zzz,zz9.99" '&nbsp;&nbsp;</td>' SKIP
                         '         <td align="right">' totalRealizado FORMAT "-zzz,zzz,zz9.99" '&nbsp;&nbsp;</td>' SKIP
                         '         <td align="right"' IF totalDiferenca < 0 THEN ' style="color: #AA0000"' ELSE '' '>' totalDiferenca FORMAT "-zzz,zzz,zz9.99" '&nbsp;&nbsp;</td>' SKIP
                         '         <td align="right"' IF totalPercentual < 0 THEN ' style="color: #AA0000"' ELSE '' '>' totalPercentual FORMAT "-z,zz9.99%" '&nbsp;&nbsp;</td>' SKIP
                         '      </tr>' SKIP.

                  ASSIGN totalPrevisto   = 0
                         totalRealizado  = 0
                         totalDiferenca  = 0
                         totalPercentual = 0.
         
                  IF corEmUso = "#FFFFFF"
                     THEN
                         ASSIGN corEmUso = "#F5F5F5".
                     ELSE
                         ASSIGN corEmUso = "#FFFFFF".
               END.

        IF LAST-OF(ttCrapcdp.CdEvento) 
           THEN
               DO:
                  {&out} '      <tr class="tdCab3">' SKIP
                         '         <td>Totais para o Evento: ' ttCrapcdp.CdEvento ' - '  ttCrapcdp.NomeDoEvento '</td>' SKIP
                         '         <td align="right" style="border-top: 1px #000000 solid">' totalDoEventoPrevisto FORMAT "-zzz,zzz,zz9.99" '&nbsp;&nbsp;</td>' SKIP
                         '         <td align="right" style="border-top: 1px #000000 solid">' totalDoEventoRealizado FORMAT "-zzz,zzz,zz9.99" '&nbsp;&nbsp;</td>' SKIP
                         '         <td align="right"' IF totalDoEventoDiferenca < 0 THEN ' style="color: #AA0000; border-top: 1px #000000 solid"' ELSE ' style="border-top: 1px #000000 solid"' '>' totalDoEventoDiferenca FORMAT "-zzz,zzz,zz9.99" '&nbsp;&nbsp;</td>' SKIP
                         '         <td align="right"' IF totalDoEventoPercentual < 0 THEN ' style="color: #AA0000; border-top: 1px #000000 solid"' ELSE ' style="border-top: 1px #000000 solid"' '>' totalDoEventoPercentual FORMAT "-z,zz9.99%" '&nbsp;&nbsp;</td>' SKIP
                         '      </tr>' SKIP
                         '      <tr><td colspan="5" align="center"> &nbsp; </td></tr>' SKIP
                         '      <tr><td colspan="5" align="center"><hr></td></tr>' SKIP
                         '      <tr><td colspan="5" align="center"> &nbsp; </td></tr>' SKIP.
                  
                  ASSIGN totalDoEventoPrevisto   = 0
                         totalDoEventoRealizado  = 0
                         totalDoEventoDiferenca  = 0
                         totalDoEventoPercentual = 0
                         corEmUso                = "#FFFFFF".
               END.

    END. /* FOR EACH ttCrapcdp */
    
    {&out} '   </table>' SKIP.

    RETURN TRUE.

END FUNCTION. /* montaTelaSinteticoPorEvento RETURNS LOGICAL () */


FUNCTION montaTela RETURNS LOGICAL ():

    DEFINE VARIABLE totalPrevisto        AS DECIMAL.
    DEFINE VARIABLE totalRealizado       AS DECIMAL.
    DEFINE VARIABLE totalDiferenca       AS DECIMAL.
    DEFINE VARIABLE totalPercentual      AS DECIMAL.
    
    DEFINE VARIABLE totalPrevistoGeral   AS DECIMAL.
    DEFINE VARIABLE totalRealizadoGeral  AS DECIMAL.
    DEFINE VARIABLE totalDiferencaGeral  AS DECIMAL.
    DEFINE VARIABLE totalPercentualGeral AS DECIMAL.
    DEFINE VARIABLE totalVerbaGeral      AS DECIMAL.
    

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

    /* *** Logo *** */
    {&out} '   <table border="0" cellspacing="0" cellpadding="0" width="100%" class="tab1">' SKIP
           '      <tr>' SKIP
           '         <td align="center"><img src="' imagemDoProgrid '" border="0"></td>' SKIP
           '         <td class="tdTitulo1" colspan="4" align="center">' nomeDaCooperativa ' - Orçamento - ' dtAnoAge '</td>' SKIP
           '         <td align="center"><img src="' imagemDaCooperativa '" border="0"></td>' SKIP
           '      </tr>' SKIP
           '   </table>' SKIP. 

    {&out} '<br>' SKIP.

    CASE tipoDeRelatorio:
         WHEN 1 THEN
              montaTelaAnalitico().
         WHEN 2 THEN
              montaTelaSinteticoPorPac().
         WHEN 3 THEN
              montaTelaSinteticoPorEvento().
         OTHERWISE
             ASSIGN msgsDeErro = msgsDeErro + "-> Tipo de relatório ainda não implementado.<br>".
    END CASE.
                         
    FIND FIRST ttCrapcdp NO-LOCK NO-ERROR.
    IF AVAILABLE ttCrapcdp
       THEN
           DO:
              /* *** Custos diversos *** */
              {&out} '   <table border="0" cellspacing="0" cellpadding="1" width="100%">' SKIP
                     '      <tr>' SKIP
                     '         <td class="tdCab1" colspan="5">Custos diversos</td>' SKIP
                     '      </tr>' SKIP.

              FIND FIRST ttCrapcdp WHERE ttCrapcdp.TpCusEve = 2 NO-LOCK NO-ERROR.
              IF NOT AVAILABLE ttCrapcdp
                 THEN
                     {&out} '      <tr>' SKIP
                            '         <td colspan="5">Não existem custos diversos para a pesquisa informada</td>' SKIP
                            '      </tr>' SKIP
                            '      <tr><td colspan="5" align="center"> &nbsp; </td></tr>' SKIP
                            '      <tr><td colspan="5" align="center"><hr></td></tr>' SKIP
                            '      <tr><td colspan="5" align="center"> &nbsp; </td></tr>' SKIP
                            '   </table>' SKIP.
                 ELSE
                     DO:
                        {&out} '      <tr class="tdCab3">' SKIP
                               '         <td>Descrição</td>' SKIP
                               '         <td align="right">Previsto</td>' SKIP
                               '         <td align="right">Realizado</td>' SKIP
                               '         <td align="right">Saldo</td>' SKIP
                               '         <td align="right">% Gasto</td>' SKIP
                               '      </tr>' SKIP.
               
                        ASSIGN corEmUso = "#FFFFFF".
                        FOR EACH ttCrapcdp WHERE ttCrapcdp.TpCusEve = 2 NO-LOCK BREAK BY ttCrapcdp.IdEvento BY ttCrapcdp.CdCooper BY ttCrapcdp.CdAgenci BY ttCrapcdp.Auxiliar1:
                            {&out} '      <tr bgcolor="' corEmUso '">' SKIP
                                   '         <td>' ttCrapcdp.CdCusEve ' - '  ttCrapcdp.NomeDoTipoDoCusto '</td>' SKIP
                                   '         <td align="right">' ttCrapcdp.VlCusEve FORMAT "-zzz,zzz,zz9.99" '&nbsp;&nbsp;</td>' SKIP
                                   '         <td align="right">' ttCrapcdp.ValorRealizado FORMAT "-zzz,zzz,zz9.99" '&nbsp;&nbsp;</td>' SKIP
                                   '         <td align="right"' IF ttCrapcdp.ValorDiferenca < 0 THEN ' style="color: #AA0000"' ELSE '' '>' ttCrapcdp.ValorDiferenca FORMAT "-zzz,zzz,zz9.99" '&nbsp;&nbsp;</td>' SKIP
                                   '         <td align="right"' IF ttCrapcdp.PercentualDiferenca < 0 THEN ' style="color: #AA0000"' ELSE '' '>' ttCrapcdp.PercentualDiferenca FORMAT "-z,zz9.99%" '&nbsp;&nbsp;</td>' SKIP
                                   '      </tr>' SKIP.
        
                            IF corEmUso = "#FFFFFF"
                               THEN
                                   ASSIGN corEmUso = "#F5F5F5".
                               ELSE
                                   ASSIGN corEmUso = "#FFFFFF".
                        END. 
                        {&out} '      <tr><td colspan="5" align="center"> &nbsp; </td></tr>' SKIP
                               '      <tr><td colspan="5" align="center"><hr></td></tr>' SKIP
                               '      <tr><td colspan="5" align="center"> &nbsp; </td></tr>' SKIP
                               '   </table>' SKIP.
                     END.

              /* *** Resumo e totais *** */
              {&out} '   <table border="0" cellspacing="0" cellpadding="1" width="100%">' SKIP
                     '      <tr>' SKIP
                     '         <td class="tdCab1" colspan="6">Resumo e totais</td>' SKIP
                     '      </tr>' SKIP
                     '      <tr>' SKIP
                     '         <td class="tdCab2" colspan="6">Resumo por PA</td>' SKIP
                     '      </tr>' SKIP
                     '      <tr class="tdCab3">' SKIP
                     '         <td>PA</td>' SKIP
                     '         <td align="right">Verba</td>' SKIP
                     '         <td align="right">Previsto</td>' SKIP
                     '         <td align="right">Realizado</td>' SKIP
                     '         <td align="right">Saldo</td>' SKIP
                     '         <td align="right">% Gasto</td>' SKIP
                     '      </tr>' SKIP.

              ASSIGN corEmUso             = "#FFFFFF"
                     totalPrevisto        = 0
                     totalRealizado       = 0
                     totalDiferenca       = 0
                     totalPercentual      = 0

                     totalPrevistoGeral   = 0
                     totalRealizadoGeral  = 0
                     totalDiferencaGeral  = 0
                     totalPercentualGeral = 0
                     totalVerbaGeral      = 0.

              FOR EACH ttCrapcdp WHERE ttCrapcdp.TpCusEve = 1 NO-LOCK BREAK BY ttCrapcdp.IdEvento BY ttCrapcdp.CdCooper BY ttCrapcdp.CdAgenci:

                  ASSIGN totalPrevisto        = totalPrevisto        + ttCrapcdp.VlCusEve
                         totalRealizado       = totalRealizado       + ttCrapcdp.ValorRealizado
                         totalDiferenca       = totalDiferenca       + ttCrapcdp.ValorDiferenca
                         totalPercentual      = ((totalRealizado / totalPrevisto) * 100)
                      
                         totalPrevistoGeral   = totalPrevistoGeral   + ttCrapcdp.VlCusEve
                         totalRealizadoGeral  = totalRealizadoGeral  + ttCrapcdp.ValorRealizado
                         totalDiferencaGeral  = totalDiferencaGeral  + ttCrapcdp.ValorDiferenca
                         totalPercentualGeral = ((totalRealizadoGeral / totalPrevistoGeral) * 100).


                  IF LAST-OF(ttCrapcdp.CdAgenci) 
                     THEN
                         DO:
                            /* *** Busca verba para o Pa *** */
                            FIND Crapvdp WHERE Crapvdp.IdEvento = ttCrapcdp.IdEvento AND
                                               Crapvdp.CdCooper = ttCrapcdp.CdCooper AND
                                               Crapvdp.CdAgenci = ttCrapcdp.CdAgenci AND
                                               Crapvdp.DtAnoAge = ttCrapcdp.DtAnoAge NO-LOCK NO-ERROR.
                            IF AVAILABLE Crapvdp
                               THEN
                                   ASSIGN valorDaVerba = Crapvdp.VlVerbaT.
                               ELSE
                                   ASSIGN valorDaVerba = ?.
                            ASSIGN totalVerbaGeral = totalVerbaGeral + valorDaVerba.

                            {&out} '      <tr bgcolor="' corEmUso '">' SKIP
                                   '         <td>' ttCrapcdp.CdAgenci ' - '  ttCrapcdp.NomeDoPac '</td>' SKIP 
                                   '         <td align="right">' valorDaVerba FORMAT "-zzz,zzz,zz9.99" '</td>' SKIP
                                   '         <td align="right">' totalPrevisto FORMAT "-zzz,zzz,zz9.99" '&nbsp;&nbsp;</td>' SKIP
                                   '         <td align="right">' totalRealizado FORMAT "-zzz,zzz,zz9.99" '&nbsp;&nbsp;</td>' SKIP
                                   '         <td align="right"' IF totalDiferenca < 0 THEN ' style="color: #AA0000"' ELSE '' '>' totalDiferenca FORMAT "-zzz,zzz,zz9.99" '&nbsp;&nbsp;</td>' SKIP
                                   '         <td align="right"' IF totalPercentual < 0 THEN ' style="color: #AA0000"' ELSE '' '>' totalPercentual FORMAT "-z,zz9.99%" '&nbsp;&nbsp;</td>' SKIP
                                   '      </tr>' SKIP.

                            ASSIGN totalPrevisto   = 0
                                   totalRealizado  = 0
                                   totalDiferenca  = 0
                                   totalPercentual = 0.
                            IF corEmUso = "#FFFFFF"
                               THEN
                                   ASSIGN corEmUso = "#F5F5F5".
                               ELSE
                                   ASSIGN corEmUso = "#FFFFFF".
                         END.
                  IF LAST(ttCrapcdp.CdAgenci)
                     THEN
                         {&out} '      <tr class="tdCab3">' SKIP
                                '         <td> &nbsp; </td>' SKIP 
                                '         <td align="right" style="border-top: 1px #000000 solid">' totalVerbaGeral FORMAT "-zzz,zzz,zz9.99" '</td>' SKIP
                                '         <td align="right" style="border-top: 1px #000000 solid">' totalPrevistoGeral FORMAT "-zzz,zzz,zz9.99" '&nbsp;&nbsp;</td>' SKIP
                                '         <td align="right" style="border-top: 1px #000000 solid">' totalRealizadoGeral FORMAT "-zzz,zzz,zz9.99" '&nbsp;&nbsp;</td>' SKIP
                                '         <td align="right"' IF totalDiferencaGeral < 0 THEN ' style="color: #AA0000; border-top: 1px #000000 solid"' ELSE ' style="border-top: 1px #000000 solid"' '>' totalDiferencaGeral FORMAT "-zzz,zzz,zz9.99" '&nbsp;&nbsp;</td>' SKIP
                                '         <td align="right"' IF totalPercentualGeral < 0 THEN ' style="color: #AA0000; border-top: 1px #000000 solid"' ELSE ' style="border-top: 1px #000000 solid"' '>' totalPercentualGeral FORMAT "-z,zz9.99%" '&nbsp;&nbsp;</td>' SKIP
                                '      </tr>' SKIP
                                '      <tr><td colspan="6" align="center"> &nbsp; </td></tr>' SKIP
                                '      <tr><td colspan="6" align="center"><hr></td></tr>' SKIP
                                '      <tr><td colspan="6" align="center"> &nbsp; </td></tr>' SKIP.

              END.

              {&out} '      <tr>' SKIP
                     '         <td class="tdCab2" colspan="6">Resumo por evento</td>' SKIP
                     '      </tr>' SKIP
                     '      <tr class="tdCab3">' SKIP
                     '         <td colspan="2">Evento</td>' SKIP
                     '         <td align="right">Previsto</td>' SKIP
                     '         <td align="right">Realizado</td>' SKIP
                     '         <td align="right">Saldo</td>' SKIP
                     '         <td align="right">% Gasto</td>' SKIP
                     '      </tr>' SKIP.

              ASSIGN corEmUso             = "#FFFFFF"
                     totalPrevisto        = 0
                     totalRealizado       = 0
                     totalDiferenca       = 0
                     totalPercentual      = 0

                     totalPrevistoGeral   = 0
                     totalRealizadoGeral  = 0
                     totalDiferencaGeral  = 0
                     totalPercentualGeral = 0.

              FOR EACH ttCrapcdp WHERE ttCrapcdp.TpCusEve = 1 NO-LOCK BREAK BY ttCrapcdp.CdEvento BY ttCrapcdp.CdAgenci BY ttCrapcdp.Auxiliar1:

                  ASSIGN totalPrevisto        = totalPrevisto        + ttCrapcdp.VlCusEve
                         totalRealizado       = totalRealizado       + ttCrapcdp.ValorRealizado
                         totalDiferenca       = totalDiferenca       + ttCrapcdp.ValorDiferenca
                         totalPercentual      = ((totalRealizado / totalPrevisto) * 100)
                         
                         totalPrevistoGeral   = totalPrevistoGeral   + ttCrapcdp.VlCusEve
                         totalRealizadoGeral  = totalRealizadoGeral  + ttCrapcdp.ValorRealizado
                         totalDiferencaGeral  = totalDiferencaGeral  + ttCrapcdp.ValorDiferenca
                         totalPercentualGeral = ((totalRealizadoGeral / totalPrevistoGeral) * 100).


                  IF LAST-OF(ttCrapcdp.CdEvento) 
                     THEN
                         DO:
                            {&out} '      <tr bgcolor="' corEmUso '">' SKIP
                                   '         <td colspan="2">' ttCrapcdp.CdEvento ' - '  ttCrapcdp.NomeDoEvento '</td>' SKIP 
                                   '         <td align="right">' totalPrevisto FORMAT "-zzz,zzz,zz9.99" '&nbsp;&nbsp;</td>' SKIP
                                   '         <td align="right">' totalRealizado FORMAT "-zzz,zzz,zz9.99" '&nbsp;&nbsp;</td>' SKIP
                                   '         <td align="right"' IF totalDiferenca < 0 THEN ' style="color: #AA0000"' ELSE '' '>' totalDiferenca FORMAT "-zzz,zzz,zz9.99" '&nbsp;&nbsp;</td>' SKIP
                                   '         <td align="right"' IF totalPercentual < 0 THEN ' style="color: #AA0000"' ELSE '' '>' totalPercentual FORMAT "-z,zz9.99%" '&nbsp;&nbsp;</td>' SKIP
                                   '      </tr>' SKIP.

                            ASSIGN totalPrevisto   = 0
                                   totalRealizado  = 0
                                   totalDiferenca  = 0
                                   totalPercentual = 0.
                            IF corEmUso = "#FFFFFF"
                               THEN
                                   ASSIGN corEmUso = "#F5F5F5".
                               ELSE
                                   ASSIGN corEmUso = "#FFFFFF".
                         END.
                  IF LAST(ttCrapcdp.CdEvento)
                     THEN
                         {&out} '      <tr class="tdCab3">' SKIP
                                '         <td colspan="2"> &nbsp; </td>' SKIP 
                                '         <td align="right" style="border-top: 1px #000000 solid">' totalPrevistoGeral FORMAT "-zzz,zzz,zz9.99" '&nbsp;&nbsp;</td>' SKIP
                                '         <td align="right" style="border-top: 1px #000000 solid">' totalRealizadoGeral FORMAT "-zzz,zzz,zz9.99" '&nbsp;&nbsp;</td>' SKIP
                                '         <td align="right"' IF totalDiferencaGeral < 0 THEN ' style="color: #AA0000; border-top: 1px #000000 solid"' ELSE ' style="border-top: 1px #000000 solid"' '>' totalDiferencaGeral FORMAT "-zzz,zzz,zz9.99" '&nbsp;&nbsp;</td>' SKIP
                                '         <td align="right"' IF totalPercentualGeral < 0 THEN ' style="color: #AA0000; border-top: 1px #000000 solid"' ELSE ' style="border-top: 1px #000000 solid"' '>' totalPercentualGeral FORMAT "-z,zz9.99%" '&nbsp;&nbsp;</td>' SKIP
                                '      </tr>' SKIP.
              END.
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
/*                                                                           */
/*   Bloco de principal do programa                                          */
/*                                                                           */
/*****************************************************************************/


output-content-type("text/html").

ASSIGN cookieEmUso = GET-COOKIE("cookie-usuario-em-uso").

/* Usado FOR EACH para poder utilizar o CONTAINS e WORD-INDEX, alterado para MATCHES*/
FOR EACH gnapses WHERE gnapses.idsessao MATCHES "*" + cookieEmUso + "*" NO-LOCK:
    LEAVE.
END.

RUN PermissaoDeAcesso("", OUTPUT IdentificacaoDaSessao, OUTPUT permiteExecutar).
  
IF permiteExecutar = "1" OR permiteExecutar = "2"
   THEN
       erroNaValidacaoDoLogin(permiteExecutar).
   ELSE
       DO:
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
                 nrseqpgm                     = INTEGER(GET-VALUE("parametro11")) NO-ERROR.          
                  
          /* *** 
             tipoDeRelatorio ->  1 = Analitico
                                     2 = Sintético por PA
                                     3 = Sintético por evento

             Crapadp.TpCusEve -> 1 = direto 
                                 2 = indireto 
                                 
             Crapadp.CdCusEve -> 1 = Honorários 
                                 2 = Local
                                 3 - Alimentação
                                 4 - Material
                                 5 - Transporte
                                 6 - Brinde
                                 7 - Divulgação
                                 8 - Outros
           *** */                      

          /* *** Localiza os eventos que satisfazem ao filtro (apenas custos diretos) *** */


          IF cdAgenci = 0  /* Todos os PA´s */
             THEN 
                 IF cdEvento = 0  /* Todos os eventos */
                    THEN
                        FOR EACH Crapadp WHERE Crapadp.IdEvento = idEvento  AND
                                               Crapadp.CdCooper = cdCooper  AND
                                               Crapadp.CdAgenci > 0         AND
                                               Crapadp.DtAnoAge = dtAnoAge  AND
                                               Crapadp.CdEvento > 0         AND
                                               Crapadp.NrSeqDig > 0         NO-LOCK:
                            IF (Crapadp.DtIniEve >= dataInicial AND Crapadp.DtFinEve <= dataFinal) OR ((Crapadp.DtIniEve = ? AND Crapadp.DtFinEve = ?) AND consideraEventosForaDaAgenda)
                               THEN
                                   DO:
                                      FOR EACH Crapcdp WHERE Crapcdp.IdEvento = Crapadp.IdEvento    AND
                                                             Crapcdp.CdCooper = Crapadp.CdCooper    AND
                                                             Crapcdp.CdAgenci = Crapadp.CdAgenci    AND
                                                             Crapcdp.DtAnoAge = Crapadp.DtAnoAge    AND
                                                             Crapcdp.TpCusEve = 1                   AND           
                                                             Crapcdp.CdEvento = Crapadp.CdEvento    AND
                                                             Crapcdp.CdCusEve > 0                   NO-LOCK:                                          
                                          
                                          CREATE ttCrapcdp.
                                          BUFFER-COPY Crapcdp TO ttCrapcdp.
                                          ASSIGN ttCrapcdp.DtIniEve = Crapadp.DtIniEve
                                                 ttCrapcdp.DtFinEve = Crapadp.DtFinEve
                                                 ttCrapcdp.NrSeqDig = Crapadp.NrSeqDig
                                                 ttCrapcdp.Mes      = Crapadp.NrMesEve.
                                      END.
                                   END.
                        END.
                    ELSE
                        FOR EACH Crapadp WHERE Crapadp.IdEvento = idEvento  AND
                                               Crapadp.CdCooper = cdCooper  AND
                                               /*Crapadp.CdAgenci > 0         AND*/
                                               Crapadp.DtAnoAge = dtAnoAge  AND
                                               Crapadp.CdEvento = cdEvento  AND
                                               Crapadp.NrSeqDig > 0         NO-LOCK:
                        /*rosangela*/
                      

                            IF (Crapadp.DtIniEve >= dataInicial AND Crapadp.DtFinEve <= dataFinal) OR ((Crapadp.DtIniEve = ? AND Crapadp.DtFinEve = ?) AND consideraEventosForaDaAgenda)
                               THEN
                                   DO:
                                      FOR EACH Crapcdp WHERE Crapcdp.IdEvento = Crapadp.IdEvento    AND
                                                             Crapcdp.CdCooper = Crapadp.CdCooper    AND
                                                             Crapcdp.CdAgenci = Crapadp.CdAgenci    AND
                                                             Crapcdp.DtAnoAge = Crapadp.DtAnoAge    AND
                                                             Crapcdp.TpCusEve = 1                   AND           
                                                             Crapcdp.CdEvento = Crapadp.CdEvento    AND
                                                             Crapcdp.CdCusEve > 0                   NO-LOCK:
                                          
                                          CREATE ttCrapcdp.
                                          BUFFER-COPY Crapcdp TO ttCrapcdp.
                                          ASSIGN ttCrapcdp.DtIniEve = Crapadp.DtIniEve
                                                 ttCrapcdp.DtFinEve = Crapadp.DtFinEve
                                                 ttCrapcdp.NrSeqDig = Crapadp.NrSeqDig
                                                 ttCrapcdp.Mes      = Crapadp.NrMesEve.
                                      END.
                                   END.
                        END.
             ELSE 
                 IF cdEvento = 0  /* Todos os eventos */
                    THEN
                        FOR EACH Crapadp WHERE Crapadp.IdEvento = idEvento  AND
                                               Crapadp.CdCooper = cdCooper  AND
                                              (Crapadp.CdAgenci = cdAgenci  OR 
                                               Crapadp.CdAgenci = 0)        AND
                                               Crapadp.DtAnoAge = dtAnoAge  AND
                                               Crapadp.CdEvento > 0         AND
                                               Crapadp.NrSeqDig > 0         NO-LOCK:
                            IF (Crapadp.DtIniEve >= dataInicial AND Crapadp.DtFinEve <= dataFinal) OR ((Crapadp.DtIniEve = ? AND Crapadp.DtFinEve = ?) AND consideraEventosForaDaAgenda)
                               THEN
                                   DO:
                                      FOR EACH Crapcdp WHERE Crapcdp.IdEvento = Crapadp.IdEvento    AND
                                                             Crapcdp.CdCooper = Crapadp.CdCooper    AND
                                                             Crapcdp.CdAgenci = CdAgenci            AND
                                                             Crapcdp.DtAnoAge = Crapadp.DtAnoAge    AND
                                                             Crapcdp.TpCusEve = 1                   AND           
                                                             Crapcdp.CdEvento = Crapadp.CdEvento    AND
                                                             Crapcdp.CdCusEve > 0                   NO-LOCK:
                                          
                                          CREATE ttCrapcdp.
                                          BUFFER-COPY Crapcdp TO ttCrapcdp.
                                          ASSIGN ttCrapcdp.DtIniEve = Crapadp.DtIniEve
                                                 ttCrapcdp.DtFinEve = Crapadp.DtFinEve
                                                 ttCrapcdp.NrSeqDig = Crapadp.NrSeqDig
                                                 ttCrapcdp.Mes      = Crapadp.NrMesEve.

                                      END.
                                   END.
                        END.
                    ELSE /* para um pa e evento específico */
                        FOR EACH Crapadp WHERE Crapadp.IdEvento = idEvento  AND
                                               Crapadp.CdCooper = cdCooper  AND
                                              (Crapadp.CdAgenci = cdAgenci  OR 
                                               Crapadp.CdAgenci = 0)        AND
                                               Crapadp.DtAnoAge = dtAnoAge  AND
                                               Crapadp.CdEvento = cdEvento  AND
                                               Crapadp.NrSeqDig > 0         NO-LOCK:
                            IF (Crapadp.DtIniEve >= dataInicial AND Crapadp.DtFinEve <= dataFinal) OR ((Crapadp.DtIniEve = ? AND Crapadp.DtFinEve = ?) AND consideraEventosForaDaAgenda)
                               THEN
                                   DO:
                                      FOR EACH Crapcdp WHERE Crapcdp.IdEvento = Crapadp.IdEvento    AND
                                                             Crapcdp.CdCooper = Crapadp.CdCooper    AND
                                                             Crapcdp.CdAgenci = CdAgenci            AND
                                                             Crapcdp.DtAnoAge = Crapadp.DtAnoAge    AND
                                                             Crapcdp.TpCusEve = 1                   AND
                                                             Crapcdp.CdEvento = Crapadp.CdEvento    AND
                                                             Crapcdp.CdCusEve > 0                   NO-LOCK:
                                          
                                          CREATE ttCrapcdp.
                                          BUFFER-COPY Crapcdp TO ttCrapcdp.
                                          ASSIGN ttCrapcdp.DtIniEve = Crapadp.DtIniEve
                                                 ttCrapcdp.DtFinEve = Crapadp.DtFinEve
                                                 ttCrapcdp.NrSeqDig = Crapadp.NrSeqDig
                                                 ttCrapcdp.Mes      = Crapadp.NrMesEve.
                                      END.
                                   END.
                        END.

          /* *** Carrega custos indiretos *** */
          FOR EACH Crapcdp WHERE Crapcdp.IdEvento = idEvento    AND
                                 Crapcdp.CdCooper = cdCooper    AND
                                 /*Crapcdp.CdAgenci = cdAgenci    AND*/
                                 Crapcdp.DtAnoAge = dtAnoAge    AND
                                 Crapcdp.TpCusEve = 2           AND           
                                /*(Crapcdp.CdEvento = 0           OR 
                                 Crapcdp.CdEvento = ?)            AND*/
                                 Crapcdp.CdCusEve > 0           NO-LOCK:
              
              CREATE ttCrapcdp.
              BUFFER-COPY Crapcdp TO ttCrapcdp.
          END.
          
          /* *** Varre a temp para carregar a descriçao do tipo do custo, agencia e evento *** */
          FIND Craptab WHERE Craptab.cdcooper = 0               AND
                             Craptab.NmSistem = "CRED"          AND
                             Craptab.TpTabela = "CONFIG"        AND 
                             Craptab.CdEmpres = 0               AND
                             Craptab.CdAcesso = "PGDCUSTEVE"    AND
                             Craptab.TpRegist = 0               NO-LOCK NO-ERROR.

          ASSIGN conta = 0.
          FOR EACH ttCrapcdp, 
					  FIRST Crapedp WHERE Crapedp.IdEvento = ttCrapcdp.IdEvento  AND
                                     Crapedp.CdCooper = ttCrapcdp.CdCooper  AND
                                     Crapedp.DtAnoAge = ttCrapcdp.DtAnoAge  AND
                                     Crapedp.CdEvento = ttCrapcdp.CdEvento  AND
                                    (Crapedp.nrseqpgm = nrseqpgm            OR
                                     nrseqpgm = 0) NO-LOCK:

            /* *** Descricao do tipo de custo *** */
            IF ttCrapcdp.TpCusEve = 1 THEN DO:

                /* *** Custo direto *** */
                IF AVAILABLE CrapTab THEN
                    IF Craptab.DsTexTab = "" THEN
                        ASSIGN ttCrapcdp.NomeDoTipoDoCusto = "Diversos".
                    ELSE
                        IF NUM-ENTRIES(Craptab.DsTexTab) >= 2 THEN DO:
                            ASSIGN ttCrapcdp.NomeDoTipoDoCusto = "Diversos".
                            
                            DO conta = 2 TO NUM-ENTRIES(Craptab.DsTexTab) BY 2:
                                IF INTEGER(ENTRY(conta,Craptab.DsTexTab)) = ttCrapcdp.CdCusEve THEN
                                    ASSIGN ttCrapcdp.NomeDoTipoDoCusto = ENTRY(conta - 1,Craptab.DsTexTab).
                            END.
                        END.
                        ELSE
                            ASSIGN ttCrapcdp.NomeDoTipoDoCusto = "Diversos".
                ELSE
                    ASSIGN ttCrapcdp.NomeDoTipoDoCusto = "Diversos".
            END.
            ELSE DO:

                /* *** Custo indireto *** */
                FIND Crapcdi WHERE Crapcdi.IdEvento = ttCrapcdp.IdEvento    AND
                                   Crapcdi.NrSeqDig = ttCrapcdp.CdCusEve    NO-LOCK NO-ERROR.
                IF AVAILABLE Crapcdi THEN
                    ASSIGN ttCrapcdp.NomeDoTipoDoCusto = Crapcdi.DsCusInd.
                ELSE
                    ASSIGN ttCrapcdp.NomeDoTipoDoCusto = "Diversos".
            
            END.

            /* *** Nome do PA *** */
            FIND Crapage WHERE Crapage.CdCooper = ttCrapcdp.CdCooper    AND 
                               Crapage.CdAgenci = ttCrapcdp.CdAgenci    NO-LOCK NO-ERROR.
            IF AVAILABLE Crapage THEN
                ASSIGN ttCrapcdp.NomeDoPac = Crapage.NmResAge. /* + " - " + Crapage.NmExtAge. */
            ELSE
                ASSIGN ttCrapcdp.NomeDoPac = "Agencia " + STRING(ttCrapcdp.CdAgenci,"999").

            /* *** Nome do evento *** */
            /*FIND FIRST Crapedp WHERE Crapedp.IdEvento = ttCrapcdp.IdEvento  AND
                                     Crapedp.CdCooper = ttCrapcdp.CdCooper  AND
                                     Crapedp.DtAnoAge = ttCrapcdp.DtAnoAge  AND
                                     Crapedp.CdEvento = ttCrapcdp.CdEvento  AND
                                    (Crapedp.nrseqpgm = nrseqpgm            OR
                                     nrseqpgm = 0) NO-LOCK NO-ERROR.*/
            IF AVAILABLE Crapedp THEN
                ASSIGN ttCrapcdp.NomeDoEvento = Crapedp.NmEvento.
            ELSE
                ASSIGN ttCrapcdp.NomeDoEvento = "Evento " + STRING(ttCrapcdp.CdEvento,"999").



            /* *** Complemento para o nome do evento *** */
            IF (ttCrapcdp.DtFinEve - ttCrapcdp.DtIniEve) = 0 THEN
                ASSIGN ttCrapcdp.SobreNomeDoEvento1 = ' (' + STRING(ttCrapcdp.DtIniEve,"99/99/9999") + ')'
                       ttCrapcdp.SobreNomeDoEvento2 = ' (' + STRING(ttCrapcdp.DtIniEve,"99/99/99") + ')'.
            ELSE
                IF (ttCrapcdp.DtFinEve - ttCrapcdp.DtIniEve) > 0 THEN
                    ASSIGN ttCrapcdp.SobreNomeDoEvento1 = ' (período de ' + STRING(ttCrapcdp.DtIniEve,"99/99/9999") + ' a ' + STRING(ttCrapcdp.DtFinEve,"99/99/9999") + ')'
                           ttCrapcdp.SobreNomeDoEvento2 = ' (' + STRING(ttCrapcdp.DtIniEve,"99/99/99") + ' a ' + STRING(ttCrapcdp.DtFinEve,"99/99/99") + ')'.
                ELSE DO:

                    IF ttCrapcdp.Mes > 0 AND ttCrapcdp.Mes < 13 THEN
                        ASSIGN ttCrapcdp.SobreNomeDoEvento1 = ' (mês de ' + ENTRY(ttCrapcdp.Mes,mes) + ')'
                               ttCrapcdp.SobreNomeDoEvento2 = ' (' + ENTRY(ttCrapcdp.Mes,mes) + ')'.
                    ELSE
                        ASSIGN ttCrapcdp.SobreNomeDoEvento1 = ' (' + STRING(ttCrapcdp.Sequenciador,"Z9") + ')'
                               ttCrapcdp.SobreNomeDoEvento2 = ' (' + STRING(ttCrapcdp.Sequenciador,"Z9") + ')'.
                END.
          END. /* FOR EACH ttCrapcdp */

          /* *** Cria valor auxiliar1 para faciliar break by da impressão baseado na data*** */
          FOR EACH ttCrapcdp WHERE ttCrapcdp.DtIniEve <> ?:
              ASSIGN ttCrapcdp.Auxiliar1 = STRING(ttCrapcdp.CdEvento,"9999") + STRING(YEAR(ttCrapcdp.DtIniEve),"9999") + STRING(MONTH(ttCrapcdp.DtIniEve),"99") + STRING(DAY(ttCrapcdp.DtIniEve),"99")
                     ttCrapcdp.Ano       = YEAR(ttCrapcdp.DtIniEve).
          END.

          /* *** Cria valor auxiliar1 para faciliar break by da impressão baseado no mes, se possivel *** */
          ASSIGN conta = 32.
          FOR EACH ttCrapcdp WHERE ttCrapcdp.DtIniEve = ? BREAK BY ttCrapcdp.IdEvento BY ttCrapcdp.CdCooper BY ttCrapcdp.CdAgenci BY ttCrapcdp.NrSeqDig BY ttCrapcdp.CdCusEve:
              IF ttCrapcdp.Mes > 0 AND ttCrapcdp.mes < 13
                 THEN
                     ASSIGN ttCrapcdp.Auxiliar1    = STRING(ttCrapcdp.CdEvento,"9999") + STRING(ttCrapcdp.DtAnoAge,"9999") +  STRING(ttCrapcdp.Mes,"99") + STRING(conta,"999")
                            ttCrapcdp.Ano          = ttCrapcdp.DtAnoAge
                            ttCrapcdp.Sequenciador = conta - 31.
                 ELSE
                     ASSIGN ttCrapcdp.Auxiliar1    = STRING(ttCrapcdp.CdEvento,"9999") + "9999" + "99" + STRING(conta,"999")
                            ttCrapcdp.Ano          = ttCrapcdp.DtAnoAge
                            ttCrapcdp.Sequenciador = conta - 31.
          
              IF ttCrapcdp.CdCusEve = 8
                 THEN
                     ASSIGN conta = conta + 1.
          END.
           
          /* *** Busca registro do realizado para custos diretos *** */
          /*rosangela*/
          FOR EACH ttCrapcdp WHERE ttCrapcdp.TpCusEve = 1:

              FOR EACH Crapcrp WHERE Crapcrp.IdEvento = ttCrapcdp.IdEvento  AND
                                     Crapcrp.CdCooper = ttCrapcdp.CdCooper  AND
                                     /*Crapcrp.CdAgenci = CdAgenci            AND */
                                     Crapcrp.TpCusEve = ttCrapcdp.TpCusEve  AND
                                     Crapcrp.CdEvento = ttCrapcdp.CdEvento  AND
                                     Crapcrp.CdCusEve = ttCrapcdp.CdCusEve  AND 
                                     Crapcrp.nrseqeve = ttCrapcdp.NrSeqDig  NO-LOCK:
                
                  ASSIGN ttCrapcdp.ValorRealizado = ttCrapcdp.ValorRealizado + Crapcrp.VlCusRea.
                  /*Rosangela*/            
              END.
              ASSIGN ttCrapcdp.ValorDiferenca      = ttCrapcdp.VlCusEve - ttCrapcdp.ValorRealizado
                     ttCrapcdp.PercentualDiferenca = IF ttCrapcdp.VlCusEve = 0 THEN 0
                                                       ELSE ((ttCrapcdp.ValorRealizado / ttCrapcdp.VlCusEve) * 100).

              
              
          END.

          /* *** Busca registro do realizado para custos indiretos *** */
          
          FOR EACH ttCrapcdp WHERE ttCrapcdp.TpCusEve = 2 BREAK BY ttCrapcdp.CdCusEve:
              
              FOR EACH Crapcrp WHERE Crapcrp.IdEvento = ttCrapcdp.IdEvento    AND
                                     Crapcrp.CdCooper = ttCrapcdp.CdCooper    AND
                                     Crapcrp.TpCusEve = 2                     AND
                                     Crapcrp.CdCusEve = ttCrapcdp.CdCusEve    NO-LOCK:
                  IF AVAILABLE Crapcrp THEN
                      ASSIGN ttCrapcdp.ValorRealizado = ttCrapcdp.ValorRealizado + Crapcrp.VlCusRea.
                  
              END.
              ASSIGN ttCrapcdp.ValorDiferenca = ttCrapcdp.VlCusEve - ttCrapcdp.ValorRealizado
                     ttCrapcdp.PercentualDiferenca = IF ttCrapcdp.VlCusEve = 0 THEN 0
                                                     ELSE ((ttCrapcdp.ValorRealizado / ttCrapcdp.VlCusEve) * 100).
          END.

          /*FOR EACH ttCrapcdp WHERE ttCrapcdp.TpCusEve = 2:
              FIND FIRST Crapcrp WHERE Crapcrp.IdEvento = ttCrapcdp.IdEvento AND
                                       Crapcrp.CdCooper = ttCrapcdp.CdCooper AND
                                       Crapcrp.TpCusEve = 2                  AND
                                       Crapcrp.CdCusEve = ttCrapcdp.CdCusEve NO-LOCK.
              IF AVAILABLE Crapcrp
                 THEN
                     ASSIGN ttCrapcdp.ValorRealizado = Crapcrp.VlCusRea.
              ASSIGN ttCrapcdp.ValorDiferenca = ttCrapcdp.VlCusEve - ttCrapcdp.ValorRealizado
                     ttCrapcdp.PercentualDiferenca = ((100 * ttCrapcdp.ValorDiferenca) / ttCrapcdp.VlCusEve).
          END.
          */

          FIND FIRST ttCrapcdp NO-LOCK NO-ERROR.
          IF NOT AVAILABLE ttCrapcdp
             THEN
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

