/******************************************************************************
  Programa wpgd0043a.p - Listagem de fechamento final (chamado a partir dos dados de wpgd0043)

  Alteracoes: 03/11/2008 - Inclusao do widget-pool.

              10/12/2008 - Melhoria de performance para a tabela gnapses (Evandro).
              
              18/03/2009 - Quebra de coluna "realizado" em "Cooperativo", "Comunidade"
                           e "Total" para tabelas com participantes (Martin)

              05/06/2012 - Adaptação dos fontes para projeto Oracle. Alterado
                           busca na gnapses de CONTAINS para MATCHES (Guilherme Maba).
                           
              04/04/2013 - Alteração para receber logo na alto vale,
                           recebendo nome de viacrediav e buscando com
                           o respectivo nome (David Kruger).
               
              23/06/2015 - Inclusao de tratamento para todas as cooperativas e 
                           criacao de novas funcoes para melhorar o codigo
                           (Jean Michel).
                            
              05/10/2015 - Incluida verificacao de qtmaxtur na crapeap antes
                           da atribuicao da crapedp Projeto 229 (Jean Michel).              
                
              24/03/2016 - Inclusao de EAD, Projeto 229 (Jean Michel).     
              
              22/04/2016 - Correcao no contabilizador total de cursos EAD 
                           (Carlos Rafael Tanholi)
              
              25/04/2016 - Correcao na mascara dos campos de percentual. 
                           Correcao da coluna previsto na tabela kits/guia
                           (Carlos Rafael Tanholi).           
                           
              26/04/2016 - Alteracao nos cabecalhos de tabelas totalizadoras e
                           tambem criacao de colunas. (Carlos Rafael Tanholi)
                           
              27/04/2016 - Correcao do erro que estava preenchendo o LOG, informando
                           que registro na crapced nao existia, decorrende da falta
                           de uso do AVAIL no comando FIND. Alem disso erro na 
                           validacao do percentual de faltas sem uso de AVAIL, tambem
                           foi corrigido. (Carlos Rafael Tanholi)                         
                           
              28/04/2016 - Correcao no total geral das participações que nao estava 
                           contabilizando os valores EAD.(Carlos Rafael Tanholi)
                           
              11/05/2016 - Finalizaçao dos cálculos e consultas do relatório para
                           exibiçao dos dados de EAD. (Jean Michel)
                           
              30/05/2016 - Correcao no TOTAL de turmas EAD dividido pelo numero
                           de meses. (Carlos Rafael Tanholi)
                           
              01/06/2016 - Ajuste somatorio dos participantes previstos
                           para nao somar os EADs.
                           PRJ229 - Melhorias OQS(Odirlei-AMcom)
                           
              30/08/2017 - Inclusao do filtro por Programa,Prj. 322 (Jean Michel).             
                         
******************************************************************************/

create widget-pool.

/*****************************************************************************/
/*   Bloco de variaveis                                                      */
/*****************************************************************************/

DEFINE VARIABLE cookieEmUso                  AS CHARACTER               NO-UNDO.
DEFINE VARIABLE permiteExecutar              AS CHARACTER               NO-UNDO.
DEFINE VARIABLE IdentificacaoDaSessao        AS CHARACTER               NO-UNDO.
DEFINE VARIABLE msgsDeErro                   AS CHARACTER               NO-UNDO.
DEFINE VARIABLE cdcooper                     AS CHARACTER               NO-UNDO.

DEFINE VARIABLE idEvento                     AS INTEGER                 NO-UNDO.
DEFINE VARIABLE dtAnoAge                     AS INTEGER                 NO-UNDO.
DEFINE VARIABLE aux_contador                 AS INTEGER                 NO-UNDO.
DEFINE VARIABLE aux_contcoop                 AS INTEGER                 NO-UNDO.
DEFINE VARIABLE aux_mesatual                 AS INTEGER                 NO-UNDO.
DEFINE VARIABLE aux_qtmaxtur                 AS INTEGER                 NO-UNDO.

DEFINE VARIABLE aux_nmrescop                 AS CHARACTER               NO-UNDO.

/* Turmas */
DEFINE VARIABLE tur_qtprevis                 AS INTEGER EXTENT 12 NO-UNDO.
DEFINE VARIABLE tur_qtprevis_ead             AS INTEGER EXTENT 12 NO-UNDO.
DEFINE VARIABLE tot_tur_qtprevis             AS INTEGER EXTENT 12 NO-UNDO.
DEFINE VARIABLE tot_tur_qtprevis_ead         AS INTEGER EXTENT 12 NO-UNDO.

DEFINE VARIABLE tur_qtcancel                 AS INTEGER EXTENT 12 NO-UNDO.
DEFINE VARIABLE tur_qtcancel_ead             AS INTEGER EXTENT 12 NO-UNDO.
DEFINE VARIABLE tot_tur_qtcancel             AS INTEGER EXTENT 12 NO-UNDO.
DEFINE VARIABLE tot_tur_qtcancel_ead         AS INTEGER EXTENT 12 NO-UNDO.

DEFINE VARIABLE tur_qtrecebi                 AS INTEGER EXTENT 12 NO-UNDO.
DEFINE VARIABLE tur_qtrecebi_ead             AS INTEGER EXTENT 12 NO-UNDO.
DEFINE VARIABLE tot_tur_qtrecebi             AS INTEGER EXTENT 12 NO-UNDO.
DEFINE VARIABLE tot_tur_qtrecebi_ead         AS INTEGER EXTENT 12 NO-UNDO.

DEFINE VARIABLE tur_qtacresc                 AS INTEGER EXTENT 12 NO-UNDO.
DEFINE VARIABLE tur_qtacresc_ead             AS INTEGER EXTENT 12 NO-UNDO.
DEFINE VARIABLE tot_tur_qtacresc             AS INTEGER EXTENT 12 NO-UNDO.
DEFINE VARIABLE tot_tur_qtacresc_ead         AS INTEGER EXTENT 12 NO-UNDO.

DEFINE VARIABLE tur_qttransf                 AS INTEGER EXTENT 12 NO-UNDO.
DEFINE VARIABLE tur_qttransf_ead             AS INTEGER EXTENT 12 NO-UNDO.
DEFINE VARIABLE tot_tur_qttransf             AS INTEGER EXTENT 12 NO-UNDO.
DEFINE VARIABLE tot_tur_qttransf_ead         AS INTEGER EXTENT 12 NO-UNDO.

DEFINE VARIABLE tur_qtrealiz                 AS INTEGER EXTENT 12 NO-UNDO.
DEFINE VARIABLE tur_qtrealiz_ead             AS INTEGER EXTENT 12 NO-UNDO.
DEFINE VARIABLE tot_tur_qtrealiz             AS INTEGER EXTENT 12 NO-UNDO.
DEFINE VARIABLE tot_tur_qtrealiz_ead         AS INTEGER EXTENT 12 NO-UNDO.

DEFINE VARIABLE tur_andament                 AS INTEGER EXTENT 12 NO-UNDO.
DEFINE VARIABLE tur_andament_ead             AS INTEGER EXTENT 12 NO-UNDO.
DEFINE VARIABLE tot_tur_andament             AS INTEGER EXTENT 12 NO-UNDO.
DEFINE VARIABLE tot_tur_andament_ead         AS INTEGER EXTENT 12 NO-UNDO.

DEFINE VARIABLE tur_ttprevis                 AS INTEGER NO-UNDO.
DEFINE VARIABLE tot_tur_ttprevis             AS INTEGER NO-UNDO.
DEFINE VARIABLE tot_tur_ttprevis_ead         AS INTEGER NO-UNDO.
DEFINE VARIABLE tur_ttcancel                 AS INTEGER NO-UNDO.
DEFINE VARIABLE tot_tur_ttcancel             AS INTEGER NO-UNDO.
DEFINE VARIABLE tot_tur_ttcancel_ead         AS INTEGER NO-UNDO.
DEFINE VARIABLE tur_ttrecebi                 AS INTEGER NO-UNDO.
DEFINE VARIABLE tot_tur_ttrecebi             AS INTEGER NO-UNDO.
DEFINE VARIABLE tot_tur_ttrecebi_ead         AS INTEGER NO-UNDO.
DEFINE VARIABLE tur_ttacresc                 AS INTEGER NO-UNDO.
DEFINE VARIABLE tot_tur_ttacresc             AS INTEGER NO-UNDO.
DEFINE VARIABLE tot_tur_ttacresc_ead         AS INTEGER NO-UNDO.
DEFINE VARIABLE tur_tttransf                 AS INTEGER NO-UNDO.
DEFINE VARIABLE tot_tur_tttransf             AS INTEGER NO-UNDO.
DEFINE VARIABLE tot_tur_tttransf_ead         AS INTEGER NO-UNDO.
DEFINE VARIABLE tur_ttrealiz                 AS INTEGER NO-UNDO.
DEFINE VARIABLE tot_tur_ttrealiz             AS INTEGER NO-UNDO.
DEFINE VARIABLE tot_tur_ttrealiz_ead         AS INTEGER NO-UNDO.
DEFINE VARIABLE tur_ttandame                 AS INTEGER NO-UNDO.
DEFINE VARIABLE tot_tur_ttandame             AS INTEGER NO-UNDO.
DEFINE VARIABLE tot_tur_ttandame_ead         AS INTEGER NO-UNDO.

DEFINE VARIABLE tur_ttprevis_ead             AS INTEGER NO-UNDO.
DEFINE VARIABLE aux_tur_ttprevis_ead         AS INTEGER NO-UNDO.
DEFINE VARIABLE tur_ttcancel_ead             AS INTEGER NO-UNDO.
DEFINE VARIABLE tur_ttrecebi_ead             AS INTEGER NO-UNDO.
DEFINE VARIABLE tur_ttacresc_ead             AS INTEGER NO-UNDO.
DEFINE VARIABLE tur_tttransf_ead             AS INTEGER NO-UNDO.
DEFINE VARIABLE tur_ttrealiz_ead             AS INTEGER NO-UNDO.
DEFINE VARIABLE tur_ttandame_ead             AS INTEGER NO-UNDO.

/* Participantes */
DEFINE VARIABLE prt_qtprevis                 AS INTEGER EXTENT 12   NO-UNDO.
DEFINE VARIABLE tot_prt_qtprevis             AS INTEGER EXTENT 12   NO-UNDO.
DEFINE VARIABLE tot_prt_qtprevis_ead         AS INTEGER EXTENT 12   NO-UNDO.
DEFINE VARIABLE prt_qtrecoop                 AS INTEGER EXTENT 12   NO-UNDO.
DEFINE VARIABLE tot_prt_qtrecoop             AS INTEGER EXTENT 12   NO-UNDO.
DEFINE VARIABLE tot_prt_qtrecoop_ead         AS INTEGER EXTENT 12   NO-UNDO.
DEFINE VARIABLE prt_qtrecomu                 AS INTEGER EXTENT 12   NO-UNDO.
DEFINE VARIABLE tot_prt_qtrecomu             AS INTEGER EXTENT 12   NO-UNDO.
DEFINE VARIABLE tot_prt_qtrecomu_ead         AS INTEGER EXTENT 12   NO-UNDO.
DEFINE VARIABLE prt_qtrealiz                 AS INTEGER EXTENT 12   NO-UNDO.
DEFINE VARIABLE tot_prt_qtrealiz             AS INTEGER EXTENT 12   NO-UNDO.
DEFINE VARIABLE tot_prt_qtrealiz_ead         AS INTEGER EXTENT 12   NO-UNDO.

DEFINE VARIABLE prt_qtprevis_ead             AS INTEGER EXTENT 12   NO-UNDO.
DEFINE VARIABLE prt_qtrecoop_ead             AS INTEGER EXTENT 12   NO-UNDO.
DEFINE VARIABLE prt_qtrecomu_ead             AS INTEGER EXTENT 12   NO-UNDO.
DEFINE VARIABLE prt_qtrealiz_ead             AS INTEGER EXTENT 12   NO-UNDO.

DEFINE VARIABLE prt_ttprevis                 AS INTEGER             NO-UNDO.
DEFINE VARIABLE tot_prt_ttprevis             AS INTEGER             NO-UNDO.
DEFINE VARIABLE tot_prt_ttprevis_ead         AS INTEGER             NO-UNDO.
DEFINE VARIABLE aux_tot_prt_qtprevis_ead     AS INTEGER             NO-UNDO.
DEFINE VARIABLE prt_ttrecoop                 AS INTEGER             NO-UNDO.
DEFINE VARIABLE tot_prt_ttrecoop             AS INTEGER             NO-UNDO.
DEFINE VARIABLE tot_prt_ttrecoop_ead         AS INTEGER             NO-UNDO.
DEFINE VARIABLE prt_ttrecomu                 AS INTEGER             NO-UNDO.
DEFINE VARIABLE tot_prt_ttrecomu             AS INTEGER             NO-UNDO.
DEFINE VARIABLE tot_prt_ttrecomu_ead         AS INTEGER             NO-UNDO.
DEFINE VARIABLE prt_ttrealiz                 AS INTEGER             NO-UNDO.
DEFINE VARIABLE tot_prt_ttrealiz             AS INTEGER             NO-UNDO.
DEFINE VARIABLE tot_prt_ttrealiz_ead         AS INTEGER             NO-UNDO.

DEFINE VARIABLE tot_par_ttprevis             AS INTEGER             NO-UNDO.
DEFINE VARIABLE tot_par_ttrecoop             AS INTEGER             NO-UNDO.
DEFINE VARIABLE tot_par_ttrecomu             AS INTEGER             NO-UNDO.
DEFINE VARIABLE tot_par_ttrealiz             AS INTEGER             NO-UNDO.

DEFINE VARIABLE prt_ttprevis_ead             AS INTEGER             NO-UNDO.
DEFINE VARIABLE aux_prt_ttprevis_ead         AS INTEGER             NO-UNDO.
DEFINE VARIABLE prt_ttrecoop_ead             AS INTEGER             NO-UNDO.
DEFINE VARIABLE prt_ttrecomu_ead             AS INTEGER             NO-UNDO.
DEFINE VARIABLE prt_ttrealiz_ead             AS INTEGER             NO-UNDO.

/* Questionarios */
DEFINE VARIABLE qst_qtprevis                 AS INTEGER     EXTENT 12   NO-UNDO.
DEFINE VARIABLE tot_qst_qtprevis             AS INTEGER     EXTENT 12   NO-UNDO.
DEFINE VARIABLE qst_qtrealiz                 AS INTEGER     EXTENT 12   NO-UNDO.
DEFINE VARIABLE tot_qst_qtrealiz             AS INTEGER     EXTENT 12   NO-UNDO.

DEFINE VARIABLE qst_ttprevis                 AS INTEGER                 NO-UNDO.
DEFINE VARIABLE tot_qst_ttprevis             AS INTEGER                 NO-UNDO.
DEFINE VARIABLE qst_ttrealiz                 AS INTEGER                 NO-UNDO.
DEFINE VARIABLE tot_qst_ttrealiz             AS INTEGER                 NO-UNDO.

DEFINE VARIABLE imagemDoProgrid              AS CHARACTER               NO-UNDO.
DEFINE VARIABLE imagemDaCooperativa          AS CHARACTER               NO-UNDO.
DEFINE VARIABLE nomeDaCooperativa            AS CHARACTER               NO-UNDO.

DEFINE VARIABLE mes                          AS CHARACTER   EXTENT 12
                                                INITIAL ["Jan","Fev","Mar","Abr","Mai","Jun",
                                                         "Jul","Ago","Set","Out","Nov","Dez"]    NO-UNDO.

DEFINE VARIABLE aux_tpevento                 AS INTEGER                 NO-UNDO.
DEFINE VARIABLE nrseqpgm                     AS INTEGER NO-UNDO.

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

FUNCTION turmas RETURNS LOGICAL ():

    {&out} '   <table class="tab2" border="1" cellspacing="0" cellpadding="0" width="500px">' SKIP
           '     <tr>' SKIP
           '       <td class="td2" align="center" valign="middle" colspan="9">' SKIP
           '         INÍCIO DAS TURMAS - PRESENCIAL' SKIP
           '       </td>' SKIP
           '     </tr>' SKIP
           '     <tr>' SKIP
           '       <td class="td2" align="center">' SKIP
           '         &nbsp;' SKIP
           '       </td>' SKIP
           '       <td class="td2" align="center">' SKIP
           '         PREVI.' SKIP
           '       </td>' SKIP
           '       <td class="td2" align="center">' SKIP
           '         CANCEL.' SKIP
           '       </td>' SKIP
           '       <td class="td2" align="center">' SKIP
           '         RECEBIDO' SKIP
           '       </td>' SKIP
           '       <td class="td2" align="center">' SKIP
           '         ACRESCIDO' SKIP
           '       </td>' SKIP
           '       <td class="td2" align="center">' SKIP
           '         TRANSF.' SKIP
           '       </td>' SKIP
           '       <td class="td2" align="center">' SKIP
           '         REALIZADO' SKIP
           '       </td>' SKIP
/*                   '       <td class="td2" align="center">' SKIP
           '        EM ANDAM.' SKIP
           '       </td>' SKIP*/
           '       <td class="td2" align="center">' SKIP
           '         %' SKIP
           '       </td>' SKIP
           '     </tr>' SKIP.

    ASSIGN tur_ttprevis = 0
           tur_ttcancel = 0
           tur_ttrecebi = 0
           tur_ttacresc = 0
           tur_tttransf = 0
           tur_ttrealiz = 0
           tur_ttandame = 0.
    
    DO aux_contador = 1 TO 12:

       {&out} '     <tr>' SKIP
              '       <td class="td2" align="center">' SKIP
                        mes[aux_contador] SKIP
              '       </td>' SKIP
              '       <td class="tdDados2" align="center">' SKIP
                        tur_qtprevis[aux_contador] SKIP
              '       </td>' SKIP
              '       <td class="tdDados2" align="center">' SKIP
                        tur_qtcancel[aux_contador] SKIP
              '       </td>' SKIP
              '       <td class="tdDados2" align="center">' SKIP
                        tur_qtrecebi[aux_contador] SKIP
              '       </td>' SKIP
              '       <td class="tdDados2" align="center">' SKIP
                        tur_qtacresc[aux_contador] SKIP
              '       </td>' SKIP
              '       <td class="tdDados2" align="center">' SKIP
                        tur_qttransf[aux_contador] SKIP
              '       </td>' SKIP
              '       <td class="tdDados2" align="center">' SKIP
                        tur_qtrealiz[aux_contador] SKIP
              '       </td>' SKIP
              /*'       <td class="tdDados2" align="center">' SKIP
                      tur_andament[aux_contador] SKIP
              '       </td>' SKIP*/
              '       <td class="tdDados2" align="center">' SKIP.

       IF   tur_qtprevis[aux_contador] <> 0   THEN
            {&out} '&nbsp;' STRING(ROUND((tur_qtrealiz[aux_contador] * 100) / tur_qtprevis[aux_contador],2),"zz9.99") '%&nbsp;' SKIP.
       ELSE
            {&out} '&nbsp;0,00%&nbsp;' SKIP.

       {&out} '       </td>' SKIP
              '     </tr>' SKIP.

       ASSIGN tur_ttprevis = tur_ttprevis + tur_qtprevis[aux_contador]
              tur_ttcancel = tur_ttcancel + tur_qtcancel[aux_contador]
              tur_ttrecebi = tur_ttrecebi + tur_qtrecebi[aux_contador]
              tur_ttacresc = tur_ttacresc + tur_qtacresc[aux_contador]
              tur_tttransf = tur_tttransf + tur_qttransf[aux_contador]
              tur_ttrealiz = tur_ttrealiz + tur_qtrealiz[aux_contador]
              tur_ttandame = tur_ttandame + tur_andament[aux_contador].
    END.
    
    {&out} '     <tr>' SKIP
           '       <td class="td2" align="center">' SKIP
           '         TOTAL' SKIP
           '       </td>' SKIP
           '       <td class="tdDados2" align="center">' SKIP
                     tur_ttprevis SKIP
           '       </td>' SKIP
           '       <td class="tdDados2" align="center">' SKIP
                     tur_ttcancel SKIP
           '       </td>' SKIP
           '       <td class="tdDados2" align="center">' SKIP
                     tur_ttrecebi SKIP
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
/*           '       <td class="tdDados2" align="center">' SKIP
                     tur_ttandame SKIP
           '       </td>' SKIP*/
           '       <td class="tdDados2" align="center">' SKIP.

    IF   tur_ttprevis <> 0   THEN
         {&out} '&nbsp;' STRING(ROUND((tur_ttrealiz * 100) / tur_ttprevis,2),"zz9.99") '%&nbsp;' SKIP.
    ELSE
         {&out} '&nbsp;0,00%&nbsp;' SKIP.

    {&out} '       </td>' SKIP
           '     </tr>' SKIP
           '   </table>'.

END FUNCTION. /* fim turmas */

FUNCTION turmasEAD RETURNS LOGICAL ():

    {&out} '   <table class="tab2" border="1" cellspacing="0" cellpadding="0" width="500px">' SKIP
           '     <tr>' SKIP
           '       <td class="td2" align="center" valign="middle" colspan="9">' SKIP
           '         INÍCIO DAS TURMAS - EAD' SKIP
           '       </td>' SKIP
           '     </tr>' SKIP
           '     <tr>' SKIP
           '       <td class="td2" align="center">' SKIP
           '         &nbsp;' SKIP
           '       </td>' SKIP
           '       <td class="td2" align="center">' SKIP
           '         PREVI.' SKIP
           '       </td>' SKIP
           '       <td class="td2" align="center">' SKIP
           '         CANCEL.' SKIP
           '       </td>' SKIP
           '       <td class="td2" align="center">' SKIP
           '         RECEBIDO' SKIP
           '       </td>' SKIP
           '       <td class="td2" align="center">' SKIP
           '         ACRESCIDO' SKIP
           '       </td>' SKIP
           '       <td class="td2" align="center">' SKIP
           '         TRANSF.' SKIP
           '       </td>' SKIP
           '       <td class="td2" align="center">' SKIP
           '         REALIZADO' SKIP
           '       </td>' SKIP
           /*'       <td class="td2" align="center">' SKIP
           '        EM ANDAM.' SKIP
           '       </td>' SKIP*/
           '       <td class="td2" align="center">' SKIP
           '         %' SKIP
           '       </td>' SKIP
           '     </tr>' SKIP.

    ASSIGN tur_ttcancel_ead = 0
           tur_ttrecebi_ead = 0
           tur_ttacresc_ead = 0
           tur_tttransf_ead = 0
           tur_ttrealiz_ead = 0
           tur_ttandame_ead = 0.
    
    DO aux_contador = 1 TO 12:

       {&out} '     <tr>' SKIP
              '       <td class="td2" align="center">' SKIP
                        mes[aux_contador] SKIP
              '       </td>' SKIP
              '       <td class="tdDados2" align="center">' SKIP
                        tur_qtprevis_ead[aux_contador] SKIP
              '       </td>' SKIP
              '       <td class="tdDados2" align="center">' SKIP
                        tur_qtcancel_ead[aux_contador] SKIP
              '       </td>' SKIP
              '       <td class="tdDados2" align="center">' SKIP
                        tur_qtrecebi_ead[aux_contador] SKIP
              '       </td>' SKIP
              '       <td class="tdDados2" align="center">' SKIP
                        tur_qtacresc_ead[aux_contador] SKIP
              '       </td>' SKIP
              '       <td class="tdDados2" align="center">' SKIP
                        tur_qttransf_ead[aux_contador] SKIP
              '       </td>' SKIP
              '       <td class="tdDados2" align="center">' SKIP
                        tur_qtrealiz_ead[aux_contador] SKIP
              '       </td>' SKIP
              /*'       <td class="tdDados2" align="center">' SKIP
                      tur_andament_ead[aux_contador] SKIP
              '       </td>' SKIP*/
              '       <td class="tdDados2" align="center">' SKIP.

       IF   tur_qtprevis_ead[aux_contador] <> 0   THEN
            {&out} '&nbsp;' STRING(ROUND((tur_qtrealiz_ead[aux_contador] * 100) / tur_qtprevis_ead[aux_contador],2),"zz9.99") '%&nbsp;' SKIP.
       ELSE
            {&out} '&nbsp;0,00%&nbsp;' SKIP.

       {&out} '       </td>' SKIP
              '     </tr>' SKIP.

       ASSIGN tur_ttcancel_ead = tur_ttcancel_ead + tur_qtcancel_ead[aux_contador]
              tur_ttrecebi_ead = tur_ttrecebi_ead + tur_qtrecebi_ead[aux_contador]
              tur_ttacresc_ead = tur_ttacresc_ead + tur_qtacresc_ead[aux_contador]
              tur_tttransf_ead = tur_tttransf_ead + tur_qttransf_ead[aux_contador]
              tur_ttrealiz_ead = tur_ttrealiz_ead + tur_qtrealiz_ead[aux_contador]
              tur_ttandame_ead = tur_ttandame_ead + tur_andament_ead[aux_contador].
    END.
    
    {&out} '     <tr>' SKIP
           '       <td class="td2" align="center">' SKIP
           '         TOTAL' SKIP
           '       </td>' SKIP
           '       <td class="tdDados2" align="center">' SKIP
                     tur_ttprevis_ead SKIP
           '       </td>' SKIP
           '       <td class="tdDados2" align="center">' SKIP
                     tur_ttcancel_ead SKIP
           '       </td>' SKIP
           '       <td class="tdDados2" align="center">' SKIP
                     tur_ttrecebi_ead SKIP
           '       </td>' SKIP
           '       <td class="tdDados2" align="center">' SKIP
                     tur_ttacresc_ead SKIP
           '       </td>' SKIP
           '       <td class="tdDados2" align="center">' SKIP
                     tur_tttransf_ead SKIP
           '       </td>' SKIP
           '       <td class="tdDados2" align="center">' SKIP
                     tur_ttrealiz_ead SKIP
           '       </td>' SKIP
           /*'       <td class="tdDados2" align="center">' SKIP
                     tur_ttandame_ead SKIP
           '       </td>' SKIP*/
           '       <td class="tdDados2" align="center">' SKIP.

    IF   tur_ttprevis_ead <> 0   THEN
         {&out} '&nbsp;' STRING(ROUND((tur_ttrealiz_ead * 100) / tur_ttprevis_ead,2),"zz9.99") '%&nbsp;' SKIP.
    ELSE
         {&out} '&nbsp;0,00%&nbsp;' SKIP.

    {&out} '       </td>' SKIP
           '     </tr>' SKIP
           '   </table>'.

END FUNCTION. /* fim turmas EAD */

FUNCTION turmasGERAL RETURNS LOGICAL ():

    {&out} '   <table class="tab2" border="1" cellspacing="0" cellpadding="0" width="500px">' SKIP
           '     <tr>' SKIP
           '       <td class="td2" align="center" valign="middle" colspan="9">' SKIP
           '         TOTAL DAS TURMAS - (PRESENCIAL + EAD)' SKIP
           '       </td>' SKIP
           '     </tr>' SKIP    
           '     <tr>' SKIP
           '       <td class="td2" align="center">' SKIP
           '         &nbsp;' SKIP
           '       </td>' SKIP
           '       <td class="td2" align="center">' SKIP
           '         PREVI.' SKIP
           '       </td>' SKIP
           '       <td class="td2" align="center">' SKIP
           '         CANCEL.' SKIP
           '       </td>' SKIP
           '       <td class="td2" align="center">' SKIP
           '         RECEBIDO' SKIP
           '       </td>' SKIP
           '       <td class="td2" align="center">' SKIP
           '         ACRESCIDO' SKIP
           '       </td>' SKIP
           '       <td class="td2" align="center">' SKIP
           '         TRANSF.' SKIP
           '       </td>' SKIP
           '       <td class="td2" align="center">' SKIP
           '         REALIZADO' SKIP
           '       </td>' SKIP
           /*'       <td class="td2" align="center">' SKIP
           '        EM ANDAM.' SKIP
           '       </td>' SKIP*/
           '       <td class="td2" align="center">' SKIP
           '         %' SKIP
           '       </td>' SKIP
           '     </tr>' SKIP           
           '     <tr>' SKIP
           '       <td class="td2" align="center">' SKIP
           '         GERAL' SKIP
           '       </td>' SKIP
           '       <td class="tdDados2" align="center">' SKIP
                     tur_ttprevis_ead + tur_ttprevis SKIP
           '       </td>' SKIP
           '       <td class="tdDados2" align="center">' SKIP
                     tur_ttcancel_ead + tur_ttcancel SKIP
           '       </td>' SKIP
           '       <td class="tdDados2" align="center">' SKIP
                     tur_ttrecebi_ead + tur_ttrecebi SKIP
           '       </td>' SKIP
           '       <td class="tdDados2" align="center">' SKIP
                     tur_ttacresc_ead + tur_ttacresc SKIP
           '       </td>' SKIP
           '       <td class="tdDados2" align="center">' SKIP
                     tur_tttransf_ead + tur_tttransf SKIP
           '       </td>' SKIP
           '       <td class="tdDados2" align="center">' SKIP
                     tur_ttrealiz_ead + tur_ttrealiz SKIP
           '       </td>' SKIP
           /*'<td class="tdDados2" align="center">' SKIP
                     tur_ttandame_ead + tur_ttandame SKIP
           '       </td>' SKIP*/
           '       <td class="tdDados2" align="center">' SKIP.

    IF ((tur_ttprevis_ead + tur_ttprevis) <> 0) THEN
         {&out} '&nbsp;' STRING(ROUND(((tur_ttrealiz_ead + tur_ttrealiz) * 100) / (tur_ttprevis_ead + tur_ttprevis),2),"zz9.99") '%&nbsp;' SKIP.
    ELSE
         {&out} '&nbsp;0,00%&nbsp;' SKIP.

    {&out} '       </td>' SKIP
           '     </tr>' SKIP
           '   </table>'.

END FUNCTION. /* fim turmas GERAL */

FUNCTION turmasGeralTotal RETURNS LOGICAL ():

    {&out} '   <table class="tab2" border="1" cellspacing="0" cellpadding="0" width="500px">' SKIP
           '     <tr>' SKIP
           '       <td class="td2" align="center" valign="middle" colspan="9">' SKIP
           '         TOTAL DAS TURMAS - (PRESENCIAL + EAD)' SKIP
           '       </td>' SKIP
           '     </tr>' SKIP    
           '     <tr>' SKIP
           '       <td class="td2" align="center">' SKIP
           '         &nbsp;' SKIP
           '       </td>' SKIP
           '       <td class="td2" align="center">' SKIP
           '         PREVI.' SKIP
           '       </td>' SKIP
           '       <td class="td2" align="center">' SKIP
           '         CANCEL.' SKIP
           '       </td>' SKIP
           '       <td class="td2" align="center">' SKIP
           '         RECEBIDO' SKIP
           '       </td>' SKIP
           '       <td class="td2" align="center">' SKIP
           '         ACRESCIDO' SKIP
           '       </td>' SKIP
           '       <td class="td2" align="center">' SKIP
           '         TRANSF.' SKIP
           '       </td>' SKIP
           '       <td class="td2" align="center">' SKIP
           '         REALIZADO' SKIP
           '       </td>' SKIP
           /*'       <td class="td2" align="center">' SKIP
           '        EM ANDAM.' SKIP
           '       </td>' SKIP*/
           '       <td class="td2" align="center">' SKIP
           '         %' SKIP
           '       </td>' SKIP
           '     </tr>' SKIP               
           '     <tr>' SKIP
           '       <td class="td2" align="center">' SKIP
           '         GERAL' SKIP
           '       </td>' SKIP
           '       <td class="tdDados2" align="center">' SKIP
                     tot_tur_ttprevis_ead + tot_tur_ttprevis SKIP
           '       </td>' SKIP
           '       <td class="tdDados2" align="center">' SKIP
                     tot_tur_ttcancel_ead + tot_tur_ttcancel SKIP
           '       </td>' SKIP
           '       <td class="tdDados2" align="center">' SKIP
                     tot_tur_ttrecebi_ead + tot_tur_ttrecebi SKIP
           '       </td>' SKIP
           '       <td class="tdDados2" align="center">' SKIP
                     tot_tur_ttacresc_ead + tot_tur_ttacresc SKIP
           '       </td>' SKIP
           '       <td class="tdDados2" align="center">' SKIP
                     tot_tur_tttransf_ead + tot_tur_tttransf SKIP
           '       </td>' SKIP
           '       <td class="tdDados2" align="center">' SKIP
                     tot_tur_ttrealiz_ead + tot_tur_ttrealiz SKIP
           '       </td>' SKIP
           /*'       <td class="tdDados2" align="center">' SKIP
                     tot_tur_ttandame_ead + tot_tur_ttandame SKIP
           '       </td>' SKIP*/
           '       <td class="tdDados2" align="center">' SKIP.

    IF ((tot_tur_ttprevis_ead + tot_tur_ttprevis) <> 0) THEN
         {&out} '&nbsp;' STRING(ROUND(((tot_tur_ttrealiz_ead + tot_tur_ttrealiz) * 100) / (tot_tur_ttprevis_ead + tot_tur_ttprevis),2),"zz9.99") '%&nbsp;' SKIP.
    ELSE
         {&out} '&nbsp;0,00%&nbsp;' SKIP.

    {&out} '       </td>' SKIP
           '     </tr>' SKIP
           '   </table>'.

END FUNCTION. /* fim turmas GERAL TOTAL */

FUNCTION turmasTotal RETURNS LOGICAL ():

    {&out} '   <table class="tab2" border="1" cellspacing="0" cellpadding="0" width="500px">' SKIP
           '     <tr>' SKIP
           '       <td class="td2" align="center" valign="middle" colspan="9">' SKIP
           '         INÍCIO DAS TURMAS - PRESENCIAL' SKIP
           '       </td>' SKIP
           '     </tr>' SKIP
           '     <tr>' SKIP
           '       <td class="td2" align="center">' SKIP
           '         &nbsp;' SKIP
           '       </td>' SKIP
           '       <td class="td2" align="center">' SKIP
           '         PREVI.' SKIP
           '       </td>' SKIP
           '       <td class="td2" align="center">' SKIP
           '         CANCEL.' SKIP
           '       </td>' SKIP
           '       <td class="td2" align="center">' SKIP
           '         RECEBIDO' SKIP
           '       </td>' SKIP
           '       <td class="td2" align="center">' SKIP
           '         ACRESCIDO' SKIP
           '       </td>' SKIP
           '       <td class="td2" align="center">' SKIP
           '         TRANSF.' SKIP
           '       </td>' SKIP
           '       <td class="td2" align="center">' SKIP
           '         REALIZADO' SKIP
           '       </td>' SKIP
           /*'       <td class="td2" align="center">' SKIP
           '        EM ANDAM.' SKIP
           '       </td>' SKIP*/
           '       <td class="td2" align="center">' SKIP
           '         %' SKIP
           '       </td>' SKIP
           '     </tr>' SKIP.
    
    DO aux_contador = 1 TO 12:

       {&out} '     <tr>' SKIP
              '       <td class="td2" align="center">' SKIP
                        mes[aux_contador] SKIP
              '       </td>' SKIP
              '       <td class="tdDados2" align="center">' SKIP
                        tot_tur_qtprevis[aux_contador] SKIP
              '       </td>' SKIP
              '       <td class="tdDados2" align="center">' SKIP
                        tot_tur_qtcancel[aux_contador] SKIP
              '       </td>' SKIP
              '       <td class="tdDados2" align="center">' SKIP
                        tot_tur_qtrecebi[aux_contador] SKIP
              '       </td>' SKIP
              '       <td class="tdDados2" align="center">' SKIP
                        tot_tur_qtacresc[aux_contador] SKIP
              '       </td>' SKIP
              '       <td class="tdDados2" align="center">' SKIP
                        tot_tur_qttransf[aux_contador] SKIP
              '       </td>' SKIP
              '       <td class="tdDados2" align="center">' SKIP
                        tot_tur_qtrealiz[aux_contador] SKIP
              '       </td>' SKIP
              /*'       <td class="tdDados2" align="center">' SKIP
                      tot_tur_andament[aux_contador] SKIP
              '       </td>' SKIP*/
              '       <td class="tdDados2" align="center">' SKIP.

       IF   tot_tur_qtprevis[aux_contador] <> 0   THEN
            {&out} '&nbsp;' STRING(ROUND((tot_tur_qtrealiz[aux_contador] * 100) / tot_tur_qtprevis[aux_contador],2),"zz9.99") '%&nbsp;' SKIP.
       ELSE
            {&out} '&nbsp;0,00%&nbsp;' SKIP.

       {&out} '       </td>' SKIP
              '     </tr>' SKIP.

       ASSIGN tot_tur_ttprevis = tot_tur_ttprevis + tot_tur_qtprevis[aux_contador]
              tot_tur_ttcancel = tot_tur_ttcancel + tot_tur_qtcancel[aux_contador]
              tot_tur_ttrecebi = tot_tur_ttrecebi + tot_tur_qtrecebi[aux_contador]
              tot_tur_ttacresc = tot_tur_ttacresc + tot_tur_qtacresc[aux_contador]
              tot_tur_tttransf = tot_tur_tttransf + tot_tur_qttransf[aux_contador]
              tot_tur_ttrealiz = tot_tur_ttrealiz + tot_tur_qtrealiz[aux_contador]
              tot_tur_ttandame = tot_tur_ttandame + tot_tur_andament[aux_contador].
    END.
    
    {&out} '     <tr>' SKIP
           '       <td class="td2" align="center">' SKIP
           '         TOTAL' SKIP
           '       </td>' SKIP
           '       <td class="tdDados2" align="center">' SKIP
                     tot_tur_ttprevis SKIP
           '       </td>' SKIP
           '       <td class="tdDados2" align="center">' SKIP
                     tot_tur_ttcancel SKIP
           '       </td>' SKIP
           '       <td class="tdDados2" align="center">' SKIP
                     tot_tur_ttrecebi SKIP
           '       </td>' SKIP
           '       <td class="tdDados2" align="center">' SKIP
                     tot_tur_ttacresc SKIP
           '       </td>' SKIP
           '       <td class="tdDados2" align="center">' SKIP
                     tot_tur_tttransf SKIP
           '       </td>' SKIP
           '       <td class="tdDados2" align="center">' SKIP
                     tot_tur_ttrealiz SKIP
           '       </td>' SKIP
           /*'       <td class="tdDados2" align="center">' SKIP
                     tot_tur_ttandame SKIP
           '       </td>' SKIP*/
           '       <td class="tdDados2" align="center">' SKIP.

    IF   tot_tur_ttprevis <> 0   THEN
         {&out} '&nbsp;' STRING(ROUND((tot_tur_ttrealiz * 100) / tot_tur_ttprevis,2),"zz9.99") '%&nbsp;' SKIP.
    ELSE
         {&out} '&nbsp;0,00%&nbsp;' SKIP.

    {&out} '       </td>' SKIP
           '     </tr>' SKIP
           '   </table>'.

END FUNCTION. /* fim turmasTotal */

FUNCTION turmasEADTotal RETURNS LOGICAL ():

    {&out} '   <table class="tab2" border="1" cellspacing="0" cellpadding="0" width="500px">' SKIP
           '     <tr>' SKIP
           '       <td class="td2" align="center" valign="middle" colspan="9">' SKIP
           '         INÍCIO DAS TURMAS - EAD' SKIP
           '       </td>' SKIP
           '     </tr>' SKIP
           '     <tr>' SKIP
           '       <td class="td2" align="center">' SKIP
           '         &nbsp;' SKIP
           '       </td>' SKIP
           '       <td class="td2" align="center">' SKIP
           '         PREVI.' SKIP
           '       </td>' SKIP
           '       <td class="td2" align="center">' SKIP
           '         CANCEL.' SKIP
           '       </td>' SKIP
           '       <td class="td2" align="center">' SKIP
           '         RECEBIDO' SKIP
           '       </td>' SKIP
           '       <td class="td2" align="center">' SKIP
           '         ACRESCIDO' SKIP
           '       </td>' SKIP
           '       <td class="td2" align="center">' SKIP
           '         TRANSF.' SKIP
           '       </td>' SKIP
           '       <td class="td2" align="center">' SKIP
           '         REALIZADO' SKIP
           '       </td>' SKIP
           /*'       <td class="td2" align="center">' SKIP
           '        EM ANDAM.' SKIP
           '       </td>' SKIP*/
           '       <td class="td2" align="center">' SKIP
           '         %' SKIP
           '       </td>' SKIP
           '     </tr>' SKIP.
    
    ASSIGN tot_tur_ttcancel_ead = 0
           tot_tur_ttrecebi_ead = 0
           tot_tur_ttacresc_ead = 0
           tot_tur_tttransf_ead = 0
           tot_tur_ttrealiz_ead = 0
           tot_tur_ttandame_ead = 0.
    
    DO aux_contador = 1 TO 12:

       {&out} '     <tr>' SKIP
              '       <td class="td2" align="center">' SKIP
                        mes[aux_contador] SKIP
              '       </td>' SKIP
              '       <td class="tdDados2" align="center">' SKIP
                        tot_tur_qtprevis_ead[aux_contador] SKIP
              '       </td>' SKIP
              '       <td class="tdDados2" align="center">' SKIP
                        tot_tur_qtcancel_ead[aux_contador] SKIP
              '       </td>' SKIP
              '       <td class="tdDados2" align="center">' SKIP
                        tot_tur_qtrecebi_ead[aux_contador] SKIP
              '       </td>' SKIP
              '       <td class="tdDados2" align="center">' SKIP
                        tot_tur_qtacresc_ead[aux_contador] SKIP
              '       </td>' SKIP
              '       <td class="tdDados2" align="center">' SKIP
                        tot_tur_qttransf_ead[aux_contador] SKIP
              '       </td>' SKIP
              '       <td class="tdDados2" align="center">' SKIP
                        tot_tur_qtrealiz_ead[aux_contador] SKIP
              '       </td>' SKIP
              /*'       <td class="tdDados2" align="center">' SKIP
                      tot_tur_andament_ead[aux_contador] SKIP
              '       </td>' SKIP*/
              '       <td class="tdDados2" align="center">' SKIP.

       IF   tot_tur_qtprevis_ead[aux_contador] <> 0   THEN
            {&out} '&nbsp;' STRING(ROUND((tot_tur_qtrealiz_ead[aux_contador] * 100) / tot_tur_qtprevis_ead[aux_contador],2),"zz9.99") '%&nbsp;' SKIP.
       ELSE
            {&out} '&nbsp;0,00%&nbsp;' SKIP.

       {&out} '       </td>' SKIP
              '     </tr>' SKIP.

       ASSIGN tot_tur_ttcancel_ead = tot_tur_ttcancel_ead + tot_tur_qtcancel_ead[aux_contador]
              tot_tur_ttrecebi_ead = tot_tur_ttrecebi_ead + tot_tur_qtrecebi_ead[aux_contador]
              tot_tur_ttacresc_ead = tot_tur_ttacresc_ead + tot_tur_qtacresc_ead[aux_contador]
              tot_tur_tttransf_ead = tot_tur_tttransf_ead + tot_tur_qttransf_ead[aux_contador]
              tot_tur_ttrealiz_ead = tot_tur_ttrealiz_ead + tot_tur_qtrealiz_ead[aux_contador]
              tot_tur_ttandame_ead = tot_tur_ttandame_ead + tot_tur_andament_ead[aux_contador].              
    END.
    
    {&out} '     <tr>' SKIP
           '       <td class="td2" align="center">' SKIP
           '         TOTAL' SKIP
           '       </td>' SKIP
           '       <td class="tdDados2" align="center">' SKIP
                     tot_tur_ttprevis_ead SKIP
           '       </td>' SKIP
           '       <td class="tdDados2" align="center">' SKIP
                     tot_tur_ttcancel_ead SKIP
           '       </td>' SKIP
           '       <td class="tdDados2" align="center">' SKIP
                     tot_tur_ttrecebi_ead SKIP
           '       </td>' SKIP
           '       <td class="tdDados2" align="center">' SKIP
                     tot_tur_ttacresc_ead SKIP
           '       </td>' SKIP
           '       <td class="tdDados2" align="center">' SKIP
                     tot_tur_tttransf_ead SKIP
           '       </td>' SKIP
           '       <td class="tdDados2" align="center">' SKIP
                     tot_tur_ttrealiz_ead SKIP
           '       </td>' SKIP
           /*'       <td class="tdDados2" align="center">' SKIP
                     tot_tur_ttandame_ead SKIP
           '       </td>' SKIP*/
           '       <td class="tdDados2" align="center">' SKIP.

    IF   tot_tur_ttprevis_ead <> 0   THEN
         {&out} '&nbsp;' STRING(ROUND((tot_tur_ttrealiz_ead * 100) / tot_tur_ttprevis_ead,2),"zz9.99") '%&nbsp;' SKIP.
    ELSE
         {&out} '&nbsp;0,00%&nbsp;' SKIP.

    {&out} '       </td>' SKIP
           '     </tr>' SKIP
           '   </table>'.

END FUNCTION. /* fim turmasEADTotal */

FUNCTION participantes RETURNS LOGICAL ():

    {&out} '   <table class="tab2" border="1" cellspacing="0" cellpadding="0" width="400px">' SKIP
           '     <tr>' SKIP
           '       <td class="td2" align="center" valign="middle" colspan="8">' SKIP
           '         PARTICIPANTES - PRESENCIAL' SKIP
           '       </td>' SKIP
           '     </tr>' SKIP
           '     <tr>' SKIP
           '       <td class="td2" align="center">' SKIP
           '         &nbsp;' SKIP
           '       </td>' SKIP
           '       <td class="td2" align="center">' SKIP
           '         PREVI.' SKIP
           '       </td>' SKIP
           '       <td class="td2" align="center">' SKIP
           '         COOP.' SKIP
           '       </td>' SKIP
           '       <td class="td2" align="center">' SKIP
           '         COMU.' SKIP
           '       </td>' SKIP
           '       <td class="td2" align="center">' SKIP
           '         TOT.' SKIP
           '       </td>' SKIP
           '       <td class="td2" align="center">' SKIP
           '         %' SKIP
           '       </td>' SKIP
           '     </tr>' SKIP.

    ASSIGN prt_ttprevis = 0
           prt_ttrecoop = 0
           prt_ttrecomu = 0
           prt_ttrealiz = 0.
    
    DO aux_contador = 1 TO 12:

       {&out} '     <tr>' SKIP
              '       <td class="td2" align="center">' SKIP
                        mes[aux_contador] SKIP
              '       </td>' SKIP
              '       <td class="tdDados2" align="center">' SKIP
                        prt_qtprevis[aux_contador] SKIP
              '       </td>' SKIP
              '       <td class="tdDados2" align="center">' SKIP
                        prt_qtrecoop[aux_contador] SKIP
              '       </td>' SKIP
              '       <td class="tdDados2" align="center">' SKIP
                        prt_qtrecomu[aux_contador] SKIP
              '       </td>' SKIP
              '       <td class="tdDados2" align="center">' SKIP
                        prt_qtrealiz[aux_contador] SKIP
              '       </td>' SKIP
              '       <td class="tdDados2" align="center">' SKIP.

       IF   prt_qtprevis[aux_contador] <> 0   THEN
            {&out} '&nbsp;' STRING(ROUND((prt_qtrealiz[aux_contador] * 100) / prt_qtprevis[aux_contador],2),"zz9.99") '%&nbsp;' SKIP.
       ELSE
            {&out} '&nbsp;0,00%&nbsp;' SKIP.

       {&out} '       </td>' SKIP
              '     </tr>' SKIP.

       ASSIGN prt_ttprevis = prt_ttprevis + prt_qtprevis[aux_contador]
              prt_ttrecoop = prt_ttrecoop + prt_qtrecoop[aux_contador]
              prt_ttrecomu = prt_ttrecomu + prt_qtrecomu[aux_contador]
              prt_ttrealiz = prt_ttrealiz + prt_qtrealiz[aux_contador].
    END.
    
    {&out} '     <tr>' SKIP
           '       <td class="td2" align="center">' SKIP
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
         {&out} '&nbsp;' STRING(ROUND((prt_ttrealiz * 100) / prt_ttprevis,2),"zz9.99") '%&nbsp;' SKIP.
    ELSE
         {&out} '&nbsp;0,00%&nbsp;' SKIP.

    {&out} '       </td>' SKIP
           '     </tr>' SKIP
           '   </table>'.

END FUNCTION. /* fim participantes */

FUNCTION participantesEAD RETURNS LOGICAL ():

    {&out} '   <table class="tab2" border="1" cellspacing="0" cellpadding="0" width="400px">' SKIP
           '     <tr>' SKIP
           '       <td class="td2" align="center" valign="middle" colspan="8">' SKIP
           '         PARTICIPANTES - EAD' SKIP
           '       </td>' SKIP
           '     </tr>' SKIP
           '     <tr>' SKIP
           '       <td class="td2" align="center">' SKIP
           '         &nbsp;' SKIP
           '       </td>' SKIP
           '       <td class="td2" align="center">' SKIP
           '         PREVI.' SKIP
           '       </td>' SKIP
           '       <td class="td2" align="center">' SKIP
           '         COOP.' SKIP
           '       </td>' SKIP
           '       <td class="td2" align="center">' SKIP
           '         COMU.' SKIP
           '       </td>' SKIP
           '       <td class="td2" align="center">' SKIP
           '         TOT.' SKIP
           '       </td>' SKIP
           '       <td class="td2" align="center">' SKIP
           '         %' SKIP
           '       </td>' SKIP
           '     </tr>' SKIP.

    ASSIGN prt_ttrecoop_ead = 0
           prt_ttrecomu_ead = 0
           prt_ttrealiz_ead = 0.
    
    DO aux_contador = 1 TO 12:

       {&out} '<tr>' SKIP
              '  <td class="td2" align="center">' SKIP
                   mes[aux_contador] SKIP
              '  </td>' SKIP
              '  <td class="tdDados2" align="center">' SKIP
                   prt_qtprevis_ead[aux_contador] SKIP
              '  </td>' SKIP
              '  <td class="tdDados2" align="center">' SKIP
                   prt_qtrecoop_ead[aux_contador] SKIP
              '  </td>' SKIP
              '  <td class="tdDados2" align="center">' SKIP
                   prt_qtrecomu_ead[aux_contador] SKIP
              '  </td>' SKIP
              '  <td class="tdDados2" align="center">' SKIP
                   prt_qtrealiz_ead[aux_contador] SKIP
              '  </td>' SKIP
              '  <td class="tdDados2" align="center">' SKIP.

       IF   prt_qtprevis_ead[aux_contador] <> 0   THEN
            {&out} '&nbsp;' STRING(ROUND((prt_qtrealiz_ead[aux_contador] * 100) / prt_qtprevis_ead[aux_contador],2),"zzzz9.99") '%&nbsp;' SKIP.
       ELSE
            {&out} '&nbsp;0,00%&nbsp;' SKIP.

       {&out} '       </td>' SKIP
              '     </tr>' SKIP.

       ASSIGN prt_ttrecoop_ead = prt_ttrecoop_ead + prt_qtrecoop_ead[aux_contador]
              prt_ttrecomu_ead = prt_ttrecomu_ead + prt_qtrecomu_ead[aux_contador]
              prt_ttrealiz_ead = prt_ttrealiz_ead + prt_qtrealiz_ead[aux_contador].
    END.
    
    {&out} '<tr>' SKIP
           '  <td class="td2" align="center">' SKIP
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
         {&out} '&nbsp;' STRING(ROUND((prt_ttrealiz_ead * 100) / prt_ttprevis_ead,2),"zzzz9.99") '%&nbsp;' SKIP.
    ELSE
         {&out} '&nbsp;0,00%&nbsp;' SKIP.

    {&out} '    </td>' SKIP
           '  </tr>' SKIP
           '</table>'.

END FUNCTION. /* fim participantes EAD */
           
FUNCTION participantesGeral RETURNS LOGICAL ():

    {&out} '<table class="tab2" border="1" cellspacing="0" cellpadding="0" width="400px">' SKIP
           '     <tr>' SKIP
           '       <td class="td2" align="center" valign="middle" colspan="9">' SKIP
           '         TOTAL DOS PARTICIPANTES - (PRESENCIAL + EAD)' SKIP
           '       </td>' SKIP
           '     </tr>' SKIP
           '     <tr>' SKIP
           '       <td class="td2" align="center">' SKIP
           '         &nbsp;' SKIP
           '       </td>' SKIP
           '       <td class="td2" align="center">' SKIP
           '         PREVI.' SKIP
           '       </td>' SKIP
           '       <td class="td2" align="center">' SKIP
           '         COOP.' SKIP
           '       </td>' SKIP
           '       <td class="td2" align="center">' SKIP
           '         COMU.' SKIP
           '       </td>' SKIP
           '       <td class="td2" align="center">' SKIP
           '         TOT.' SKIP
           '       </td>' SKIP
           '       <td class="td2" align="center">' SKIP
           '         %' SKIP
           '       </td>' SKIP
           '     </tr>' SKIP           
           ' <tr>' SKIP
           '  <td class="td2" align="center">' SKIP
           '    GERAL' SKIP
           '  </td>' SKIP
           '  <td class="tdDados2" align="center">' SKIP
                prt_ttprevis_ead + prt_ttprevis SKIP
           '  </td>' SKIP
           '  <td class="tdDados2" align="center">' SKIP
                prt_ttrecoop_ead + prt_ttrecoop SKIP
           '  </td>' SKIP
           '  <td class="tdDados2" align="center">' SKIP
                prt_ttrecomu_ead + prt_ttrecomu SKIP
           '  </td>' SKIP
           '  <td class="tdDados2" align="center">' SKIP
                prt_ttrealiz_ead + prt_ttrealiz SKIP
           '  </td>' SKIP
           '  <td class="tdDados2" align="center">' SKIP.
           
    IF ((prt_ttprevis_ead + prt_ttprevis) <> 0)   THEN
         {&out} '&nbsp;' STRING(ROUND(((prt_ttrealiz_ead + prt_ttrealiz) * 100) / (prt_ttprevis_ead + prt_ttprevis),2),"zz9.99") '%&nbsp;' SKIP.
    ELSE
         {&out} '&nbsp;0,00%&nbsp;' SKIP.

    {&out} '    </td>' SKIP
           '  </tr>' SKIP
           '</table>'.

END FUNCTION. /* fim participantes GERAL */

FUNCTION participantesGeralTotal RETURNS LOGICAL ():

    {&out} '<table class="tab2" border="1" cellspacing="0" cellpadding="0" width="400px">' SKIP
           '     <tr>' SKIP
           '       <td class="td2" align="center" valign="middle" colspan="9">' SKIP
           '         TOTAL DOS PARTICIPANTES - (PRESENCIAL + EAD)' SKIP
           '       </td>' SKIP
           '     </tr>' SKIP
           '     <tr>' SKIP
           '       <td class="td2" align="center">' SKIP
           '         &nbsp;' SKIP
           '       </td>' SKIP
           '       <td class="td2" align="center">' SKIP
           '         PREVI.' SKIP
           '       </td>' SKIP
           '       <td class="td2" align="center">' SKIP
           '         COOP.' SKIP
           '       </td>' SKIP
           '       <td class="td2" align="center">' SKIP
           '         COMU.' SKIP
           '       </td>' SKIP
           '       <td class="td2" align="center">' SKIP
           '         TOT.' SKIP
           '       </td>' SKIP
           '       <td class="td2" align="center">' SKIP
           '         %' SKIP
           '       </td>' SKIP
           '     </tr>' SKIP     
           ' <tr>' SKIP
           '  <td class="td2" align="center" width="20%">' SKIP
           '    GERAL' SKIP
           '  </td>' SKIP
           '  <td class="tdDados2" align="center" width="16%">' SKIP
                tot_prt_ttprevis_ead + tot_prt_ttprevis SKIP
           '  </td>' SKIP
           '  <td class="tdDados2" align="center" width="17%">' SKIP
                tot_prt_ttrecoop_ead + tot_prt_ttrecoop SKIP
           '  </td>' SKIP
           '  <td class="tdDados2" align="center" width="18%">' SKIP
                tot_prt_ttrecomu_ead + tot_prt_ttrecomu SKIP
           '  </td>' SKIP
           '  <td class="tdDados2" align="center" width="12%">' SKIP
                tot_prt_ttrealiz_ead + tot_prt_ttrealiz SKIP
           '  </td>' SKIP
           '  <td class="tdDados2" align="center" width="12%">' SKIP.
           
    IF ((tot_prt_ttprevis_ead + tot_prt_ttprevis) <> 0)   THEN
         {&out} '&nbsp;' STRING(ROUND(((tot_prt_ttrealiz_ead + tot_prt_ttrealiz) * 100) / (tot_prt_ttprevis_ead + tot_prt_ttprevis),2),"zz9.99") '%&nbsp;' SKIP.
    ELSE
         {&out} '&nbsp;0,00%&nbsp;' SKIP.

    {&out} '    </td>' SKIP
           '  </tr>' SKIP
           '</table>'.

END FUNCTION. /* fim participantes GERAL Total*/

FUNCTION participantesTotal RETURNS LOGICAL ():

    {&out} '<table class="tab2" border="1" cellspacing="0" cellpadding="0" width="400px">' SKIP
           '  <tr>' SKIP
           '    <td class="td2" align="center" valign="middle" colspan="8">' SKIP
           '      PARTICIPANTES - PRESENCIAL' SKIP
           '    </td>' SKIP
           '  </tr>' SKIP
           '  <tr>' SKIP
           '    <td class="td2" align="center">' SKIP
           '      &nbsp;' SKIP
           '    </td>' SKIP
           '    <td class="td2" align="center">' SKIP
           '      PREVI.' SKIP
           '    </td>' SKIP
           '    <td class="td2" align="center">' SKIP
           '      COOP.' SKIP
           '    </td>' SKIP
           '    <td class="td2" align="center">' SKIP
           '      COMU.' SKIP
           '    </td>' SKIP
           '    <td class="td2" align="center">' SKIP
           '      TOT.' SKIP
           '    </td>' SKIP
           '    <td class="td2" align="center">' SKIP
           '      %' SKIP
           '    </td>' SKIP
           '  </tr>' SKIP.
    
    DO aux_contador = 1 TO 12:

       {&out} '<tr>' SKIP
              '  <td class="td2" align="center">' SKIP
                   mes[aux_contador] SKIP
              '  </td>' SKIP
              '  <td class="tdDados2" align="center">' SKIP
                   tot_prt_qtprevis[aux_contador] SKIP
              '  </td>' SKIP
              '  <td class="tdDados2" align="center">' SKIP
                   tot_prt_qtrecoop[aux_contador] SKIP
              '  </td>' SKIP
              '  <td class="tdDados2" align="center">' SKIP
                   tot_prt_qtrecomu[aux_contador] SKIP
              '  </td>' SKIP
              '  <td class="tdDados2" align="center">' SKIP
                   tot_prt_qtrealiz[aux_contador] SKIP
              '  </td>' SKIP
              '  <td class="tdDados2" align="center">' SKIP.

       IF   tot_prt_qtprevis[aux_contador] <> 0   THEN
            {&out} '&nbsp;' STRING(ROUND((tot_prt_qtrealiz[aux_contador] * 100) / tot_prt_qtprevis[aux_contador],2),"zz9.99") '%&nbsp;' SKIP.
       ELSE
            {&out} '&nbsp;0,00%&nbsp;' SKIP.

       {&out} '       </td>' SKIP
              '     </tr>' SKIP.
			  
       ASSIGN tot_prt_ttprevis = tot_prt_ttprevis + tot_prt_qtprevis[aux_contador]
              tot_prt_ttrecoop = tot_prt_ttrecoop + tot_prt_qtrecoop[aux_contador]
              tot_prt_ttrecomu = tot_prt_ttrecomu + tot_prt_qtrecomu[aux_contador]
              tot_prt_ttrealiz = tot_prt_ttrealiz + tot_prt_qtrealiz[aux_contador].
    END.
    
    {&out} '<tr>' SKIP
           '  <td class="td2" align="center">' SKIP
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

    IF   tot_prt_ttprevis <> 0   THEN
         {&out} '&nbsp;' STRING(ROUND((tot_prt_ttrealiz * 100) / tot_prt_ttprevis,2),"zz9.99") '%&nbsp;' SKIP.
    ELSE
         {&out} '&nbsp;0,00%&nbsp;' SKIP.

    {&out} '    </td>' SKIP
           '  </tr>' SKIP
           '</table>'.

END FUNCTION. /* fim participantesTotal */

FUNCTION participantesEADTotal RETURNS LOGICAL ():

    {&out} '<table class="tab2" border="1" cellspacing="0" cellpadding="0" width="400px">' SKIP
           '  <tr>' SKIP
           '    <td class="td2" align="center" valign="middle" colspan="8">' SKIP
           '      PARTICIPANTES - EAD' SKIP
           '    </td>' SKIP
           '  </tr>' SKIP
           '  <tr>' SKIP
           '    <td class="td2" align="center">' SKIP
           '      &nbsp;' SKIP
           '    </td>' SKIP
           '    <td class="td2" align="center">' SKIP
           '      PREVI.' SKIP
           '    </td>' SKIP
           '    <td class="td2" align="center">' SKIP
           '      COOP.' SKIP
           '    </td>' SKIP
           '    <td class="td2" align="center">' SKIP
           '      COMU.' SKIP
           '    </td>' SKIP
           '    <td class="td2" align="center">' SKIP
           '      TOT.' SKIP
           '    </td>' SKIP
           '    <td class="td2" align="center">' SKIP
           '      %' SKIP
           '    </td>' SKIP
           '  </tr>' SKIP.
    
    DO aux_contador = 1 TO 12:

       {&out} '     <tr>' SKIP
              '       <td class="td2" align="center">' SKIP
                        mes[aux_contador] SKIP
              '       </td>' SKIP
              '       <td class="tdDados2" align="center">' SKIP
                        tot_prt_qtprevis_ead[aux_contador] SKIP
              '       </td>' SKIP
              '       <td class="tdDados2" align="center">' SKIP
                        tot_prt_qtrecoop_ead[aux_contador] SKIP
              '       </td>' SKIP
              '       <td class="tdDados2" align="center">' SKIP
                        tot_prt_qtrecomu_ead[aux_contador] SKIP
              '       </td>' SKIP
              '       <td class="tdDados2" align="center">' SKIP
                        tot_prt_qtrealiz_ead[aux_contador] SKIP
              '       </td>' SKIP
              '       <td class="tdDados2" align="center">' SKIP.

       IF tot_prt_qtprevis_ead[aux_contador] <> 0 THEN
         {&out} '&nbsp;' STRING(ROUND((tot_prt_qtrealiz_ead[aux_contador] * 100) / tot_prt_qtprevis_ead[aux_contador],2),"zz9.99") '%&nbsp;' SKIP.
       ELSE
         {&out} '&nbsp;0,00%&nbsp;' SKIP.

       {&out} '  </td>' SKIP
              '</tr>' SKIP.
			  
       ASSIGN tot_prt_ttrecoop_ead = tot_prt_ttrecoop_ead + tot_prt_qtrecoop_ead[aux_contador]
              tot_prt_ttrecomu_ead = tot_prt_ttrecomu_ead + tot_prt_qtrecomu_ead[aux_contador]
              tot_prt_ttrealiz_ead = tot_prt_ttrealiz_ead + tot_prt_qtrealiz_ead[aux_contador].
    END.
    
    {&out} '<tr>' SKIP
           '  <td class="td2" align="center">' SKIP
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

    IF   tot_prt_ttprevis_ead <> 0   THEN
         {&out} '&nbsp;' STRING(ROUND((tot_prt_ttrealiz_ead * 100) / tot_prt_ttprevis_ead,2),"zz9.99") '%&nbsp;' SKIP.
    ELSE
         {&out} '&nbsp;0,00%&nbsp;' SKIP.

    {&out} '    </td>' SKIP
           '  </tr>' SKIP
           '</table>'.

END FUNCTION. /* fim participantesEADTotal */

FUNCTION questionarios RETURNS LOGICAL ():

    {&out} '<table class="tab2" border="1" cellspacing="0" cellpadding="0" width="500px">' SKIP
           '  <tr>' SKIP
           '    <td class="td2" align="center" valign="middle" colspan="8">' SKIP
           '      KITS / GUIA DO COOPERADO' SKIP
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
           '      REALIZADO' SKIP
           '    </td>' SKIP
           '    <td class="td2" align="center">' SKIP
           '      %' SKIP
           '    </td>' SKIP
           '  </tr>' SKIP.

    ASSIGN qst_ttprevis = 0
           qst_ttrealiz = 0.
    
    DO aux_contador = 1 TO 12:

       {&out} '<tr>' SKIP
              '  <td class="td2" align="center">' SKIP
                   mes[aux_contador] SKIP
              '  </td>' SKIP
              '  <td class="tdDados2" align="center">' SKIP
                   qst_qtprevis[aux_contador] SKIP
              '  </td>' SKIP
              '  <td class="tdDados2" align="center">' SKIP
                   qst_qtrealiz[aux_contador] SKIP
              '  </td>' SKIP
              '  <td class="tdDados2" align="center">' SKIP.

       IF   qst_qtprevis[aux_contador] <> 0   THEN
            {&out} '&nbsp;' STRING(ROUND((qst_qtrealiz[aux_contador] * 100) / qst_qtprevis[aux_contador],2),"zz9.99") '%&nbsp;' SKIP.
       ELSE
            {&out} '&nbsp;0,00%&nbsp;' SKIP.

       {&out} '  </td>' SKIP
              '</tr>' SKIP.

       ASSIGN qst_ttprevis = qst_ttprevis + qst_qtprevis[aux_contador]
              qst_ttrealiz = qst_ttrealiz + qst_qtrealiz[aux_contador].
    END.
    
    {&out} '<tr>' SKIP
           '  <td class="td2" align="center">' SKIP
           '    TOTAL' SKIP
           '  </td>' SKIP
           '  <td class="tdDados2" align="center">' SKIP
                qst_ttprevis SKIP
           '  </td>' SKIP
           '  <td class="tdDados2" align="center">' SKIP
                qst_ttrealiz SKIP
           '  </td>' SKIP
           '  <td class="tdDados2" align="center">' SKIP.

    IF   qst_ttprevis <> 0   THEN
         {&out} '&nbsp;' STRING(ROUND((qst_ttrealiz * 100) / qst_ttprevis,2),"zz9.99") '%&nbsp;' SKIP.
    ELSE
         {&out} '&nbsp;0,00%&nbsp;' SKIP.

    {&out} '    </td>' SKIP
           '  </tr>' SKIP
           '</table>'.

END FUNCTION. /* fim questionarios */

FUNCTION questionariosTotal RETURNS LOGICAL ():

    {&out} '<table class="tab2" border="1" cellspacing="0" cellpadding="0" width="500px">' SKIP
           '  <tr>' SKIP
           '    <td class="td2" align="center" valign="middle" colspan="8">' SKIP
           '      KITS / GUIA COOPERADO' SKIP
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
           '      REALIZADO' SKIP
           '    </td>' SKIP
           '    <td class="td2" align="center">' SKIP
           '      %' SKIP
           '    </td>' SKIP
           '  </tr>' SKIP.
    
    DO aux_contador = 1 TO 12:

       {&out} '<tr>' SKIP
              '  <td class="td2" align="center">' SKIP
                   mes[aux_contador] SKIP
              '  </td>' SKIP
              '  <td class="tdDados2" align="center">' SKIP
                   tot_qst_qtprevis[aux_contador] SKIP
              '  </td>' SKIP
              '  <td class="tdDados2" align="center">' SKIP
                   tot_qst_qtrealiz[aux_contador] SKIP
              '  </td>' SKIP
              '  <td class="tdDados2" align="center">' SKIP.

       IF   tot_qst_qtprevis[aux_contador] <> 0   THEN
            {&out} '&nbsp;' STRING(ROUND((tot_qst_qtrealiz[aux_contador] * 100) / tot_qst_qtprevis[aux_contador],2),"zz9.99") '%&nbsp;' SKIP.
       ELSE
            {&out} '&nbsp;0,00%&nbsp;' SKIP.

       {&out} '  </td>' SKIP
              '</tr>' SKIP.

       ASSIGN tot_qst_ttprevis = tot_qst_ttprevis + tot_qst_qtprevis[aux_contador]
              tot_qst_ttrealiz = tot_qst_ttrealiz + tot_qst_qtrealiz[aux_contador].
    END.
    
    {&out} '<tr>' SKIP
           '  <td class="td2" align="center">' SKIP
           '    TOTAL' SKIP
           '  </td>' SKIP
           '  <td class="tdDados2" align="center">' SKIP
                tot_qst_ttprevis SKIP
           '  </td>' SKIP
           '  <td class="tdDados2" align="center">' SKIP
                tot_qst_ttrealiz SKIP
           '  </td>' SKIP
           '  <td class="tdDados2" align="center">' SKIP.

    IF   tot_qst_ttprevis <> 0   THEN
         {&out} '&nbsp;' STRING(ROUND((tot_qst_ttrealiz * 100) / tot_qst_ttprevis,2),"zz9.99") '%&nbsp;' SKIP.
    ELSE
         {&out} '&nbsp;0,00%&nbsp;' SKIP.

    {&out} '    </td>' SKIP
           '  </tr>' SKIP
           '</table>'.

END FUNCTION. /* fim questionariosTotal */

FUNCTION totalGeral RETURNS LOGICAL ():

    {&out} '<table class="tab2" border="1" cellspacing="0" cellpadding="0" width="200px">' SKIP
           '  <tr>' SKIP
           '    <td class="td2" align="center" valign="middle">' SKIP
           '      TOTAL GERAL DAS PARTICIPAÇ&Otilde;ES (PRESENCIAL + KITS + EAD)' SKIP
           '    </td>' SKIP
           '  </tr>' SKIP
		   
           '  <tr>' SKIP
           '    <td class="td2" align="center" valign="middle">' SKIP
           '      <table class="tab2" border="0" cellspacing="0" cellpadding="0" width="100%">' SKIP
           '        <tr>' SKIP
           '          <td class="tdDados2" align="right" width="60%">' SKIP
           '            PREVISTO:&nbsp;&nbsp;' SKIP
           '          </td>' SKIP
           '          <td class="tdDados2" align="left">' SKIP
                        prt_ttprevis + qst_ttprevis + prt_ttprevis_ead SKIP
           '          </td>' SKIP
           '        </tr>' SKIP
           '      </table>' SKIP
           '    </td>' SKIP
           '  </tr>' SKIP

           '  <tr>' SKIP
           '    <td class="td2" align="center" valign="middle">' SKIP
           '      <table class="tab2" border="0" cellspacing="0" cellpadding="0" width="100%">' SKIP
           '        <tr>' SKIP
           '          <td class="tdDados2" align="right" width="60%">' SKIP
           '            COOPERADOS:&nbsp;&nbsp;' SKIP
           '          </td>' SKIP
           '          <td class="tdDados2" align="left">' SKIP
                         prt_ttrecoop + qst_ttrealiz + prt_ttrecoop_ead SKIP
           '          </td>' SKIP
           '        </tr>' SKIP
           '      </table>' SKIP
           '    </td>' SKIP
           '  </tr>' SKIP
              
            '  <tr>' SKIP
            '    <td class="td2" align="center" valign="middle">' SKIP
            '      <table class="tab2" border="0" cellspacing="0" cellpadding="0" width="100%">' SKIP
            '        <tr>' SKIP
            '          <td class="tdDados2" align="right" width="60%">' SKIP
            '            COMUNIDADE:&nbsp;&nbsp;' SKIP
            '          </td>' SKIP
            '          <td class="tdDados2" align="left">' SKIP
                         prt_ttrecomu + prt_ttrecomu_ead  SKIP
            '          </td>' SKIP
            '        </tr>' SKIP
            '      </table>' SKIP
            '    </td>' SKIP
            '  </tr>' SKIP        
           '  <tr>' SKIP
           '    <td class="td2" align="center" valign="middle">' SKIP
           '      <table class="tab2" border="0" cellspacing="0" cellpadding="0" width="100%">' SKIP
           '        <tr>' SKIP
           '          <td class="tdDados2" align="right" width="60%">' SKIP
           '            REALIZADO:&nbsp;&nbsp;' SKIP
           '          </td>' SKIP
           '          <td class="tdDados2" align="left">' SKIP
                        prt_ttrecomu + prt_ttrecoop + qst_ttrealiz + prt_ttrealiz_ead SKIP
           '          </td>' SKIP
           '        </tr>' SKIP
           '      </table>' SKIP
           '    </td>' SKIP
           '  </tr>' SKIP
           '  <tr>' SKIP
           '    <td class="td2" align="center" valign="middle">' SKIP
           '      <table class="tab2" border="0" cellspacing="0" cellpadding="0" width="100%">' SKIP
           '        <tr>' SKIP
           '          <td class="tdDados2" align="right" width="60%">' SKIP
           '            ATINGIDO:&nbsp;&nbsp;' SKIP
           '          </td>' SKIP
           '          <td class="tdDados2" align="left">' SKIP
                        ROUND(((prt_ttrecoop + prt_ttrecomu + qst_ttrealiz + prt_ttrealiz_ead) * 100) / (prt_ttprevis + qst_ttprevis + prt_ttprevis_ead),2) '%&nbsp;' SKIP
           '          </td>' SKIP
           '        </tr>' SKIP
           '      </table>' SKIP
           '    </td>' SKIP
           '  </tr>' SKIP
           '</table>' SKIP.

END FUNCTION. /* fim total_geral */

FUNCTION totalGeralTotal RETURNS LOGICAL ():

    {&out} '<table class="tab2" border="1" cellspacing="0" cellpadding="0" width="200px">' SKIP
           '  <tr>' SKIP
           '    <td class="td2" align="center" valign="middle">' SKIP
           '      TOTAL GERAL DAS PARTICIPAÇ&Otilde;ES (PRESENCIAL + KITS + EAD)' SKIP
           '    </td>' SKIP
           '  </tr>' SKIP
		   
           '  <tr>' SKIP
           '    <td class="td2" align="center" valign="middle">' SKIP
           '      <table class="tab2" border="0" cellspacing="0" cellpadding="0" width="100%">' SKIP
           '        <tr>' SKIP
           '          <td class="tdDados2" align="right" width="60%">' SKIP
           '            PREVISTO:&nbsp;&nbsp;' SKIP
           '          </td>' SKIP
           '          <td class="tdDados2" align="left">' SKIP
                        tot_prt_ttprevis + tot_qst_ttprevis + tot_prt_ttprevis_ead SKIP
           '          </td>' SKIP
           '        </tr>' SKIP
           '      </table>' SKIP
           '    </td>' SKIP
           '  </tr>' SKIP
           '  <tr>' SKIP
           '    <td class="td2" align="center" valign="middle">' SKIP
           '      <table class="tab2" border="0" cellspacing="0" cellpadding="0" width="100%">' SKIP
           '        <tr>' SKIP
           '          <td class="tdDados2" align="right" width="60%">' SKIP
           '            COOPERADOS:&nbsp;&nbsp;' SKIP
           '          </td>' SKIP
           '          <td class="tdDados2" align="left">' SKIP
                         tot_prt_ttrecoop + tot_qst_ttrealiz + tot_prt_ttrecoop_ead SKIP
           '          </td>' SKIP
           '        </tr>' SKIP
           '      </table>' SKIP
           '    </td>' SKIP
           '  </tr>' SKIP  
           
           '  <tr>' SKIP
           '    <td class="td2" align="center" valign="middle">' SKIP
           '      <table class="tab2" border="0" cellspacing="0" cellpadding="0" width="100%">' SKIP
           '        <tr>' SKIP
           '          <td class="tdDados2" align="right" width="60%">' SKIP
           '            COMUNIDADE:&nbsp;&nbsp;' SKIP
           '          </td>' SKIP
           '          <td class="tdDados2" align="left">' SKIP
                        tot_prt_ttrecomu + tot_prt_ttrecomu_ead SKIP
           '          </td>' SKIP
           '        </tr>' SKIP
           '      </table>' SKIP
           '    </td>' SKIP
           '  </tr>' SKIP
        
           '  <tr>' SKIP
           '    <td class="td2" align="center" valign="middle">' SKIP
           '      <table class="tab2" border="0" cellspacing="0" cellpadding="0" width="100%">' SKIP
           '        <tr>' SKIP
           '          <td class="tdDados2" align="right" width="60%">' SKIP
           '            REALIZADO:&nbsp;&nbsp;' SKIP
           '          </td>' SKIP
           '          <td class="tdDados2" align="left">' SKIP
                        tot_prt_ttrecomu + tot_prt_ttrecoop + tot_qst_ttrealiz + tot_prt_ttrealiz_ead SKIP
           '          </td>' SKIP
           '        </tr>' SKIP
           '      </table>' SKIP
           '    </td>' SKIP
           '  </tr>' SKIP

           '  <tr>' SKIP
           '    <td class="td2" align="center" valign="middle">' SKIP
           '      <table class="tab2" border="0" cellspacing="0" cellpadding="0" width="100%">' SKIP
           '        <tr>' SKIP
           '          <td class="tdDados2" align="right" width="60%">' SKIP
           '            ATINGIDO:&nbsp;&nbsp;' SKIP
           '          </td>' SKIP
           '          <td class="tdDados2" align="left">' SKIP																														
                        ROUND(((tot_prt_ttrecoop + tot_prt_ttrecomu + tot_qst_ttrealiz + tot_prt_ttrealiz_ead) * 100) / (tot_prt_ttprevis + tot_qst_ttprevis + tot_prt_ttprevis_ead),2) '%&nbsp;' SKIP
           '          </td>' SKIP
           '        </tr>' SKIP
           '      </table>' SKIP
           '    </td>' SKIP
           '  </tr>' SKIP
           '</table>' SKIP.

END FUNCTION. /* fim totalGeralTotal */

FUNCTION montaCabecalho RETURNS LOGICAL ():

    {&out} '<html>' SKIP
           '<head>' SKIP
           '<title>Progrid - Fechamento Final</title>' SKIP.

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
    {&out} '<div align="left" id="botoes">' SKIP
           '   <table border="0" cellspacing="0" cellpadding="0" width="100%">' SKIP
           '      <tr>' SKIP
           '         <td align="right">' SKIP
           '            <img src="/cecred/images/botoes/btn_fechar.gif" alt="Fechar esta janela" style="cursor: hand" onClick="top.close()">' SKIP
           '            <img src="/cecred/images/botoes/btn_imprimir.gif" alt="Imprimir" style="cursor: hand" onClick="document.all.botoes.style.visibility = ~'hidden~'; print(); document.all.botoes.style.visibility = ~'visible~';">' SKIP
           '         </td>' SKIP
           '      </tr>' SKIP
           '   </table>' SKIP
           '</div>' SKIP.

    {&out} '<table border="0" cellspacing="0" cellpadding="0" width="100%">' SKIP
           '   <tr>' SKIP
           '      <td class="tdprogra" colspan="5" align="right">wpgd0043a - ' TODAY '</td>' SKIP
           '</table>' SKIP. 

    /* *** Cabecalho geral *** */
    {&out} '<table border="0" cellspacing="0" cellpadding="0" width="100%" >' SKIP
           '   <tr>' SKIP
           '      <td align="center"><img src="/cecred/images/geral/logo_cecred.gif" border="0"></td>' SKIP
           '      <td class="tdTitulo1" align="center">Fechamento Geral - ' dtAnoAge '</td>' SKIP
           '   </tr>' SKIP
           '   <tr>' SKIP
           '      <td align="center" colspan="6">&nbsp;</td>' SKIP
           '   </tr>' SKIP
           '   <tr>' SKIP
		   '      <td width="25%">&nbsp;</td>' SKIP
           '      <td class="tdTitulo2" align="center">DADOS QUANTITATIVOS</td>' SKIP
           '   </tr>' SKIP
           '</table>' SKIP. 

    {&out} '<br>' SKIP. 

    RETURN TRUE.

END FUNCTION. /* montaCabecalho RETURNS LOGICAL () */

FUNCTION montaTela RETURNS LOGICAL ():
	
	/**** Logo Cooperativa ****/
  {&out} '<br><div width="100%" style="text-align:left; float: left;"><table border="0" cellspacing="0" cellpadding="0" >' SKIP
         '  <table style="text-align:left; float: left;">' SKIP
         '    <tr>' SKIP
         '       <td align="left">&nbsp;&nbsp;&nbsp;<img src="' imagemDaCooperativa '" border="0"></td>' SKIP
         '       <td class="tdTitulo1" align="left">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;' nomeDaCooperativa '</td>' SKIP
         '    </tr>' SKIP
         '  </table><div>' SKIP. 

  {&out} '<br>' SKIP.

  {&out} '<table border="0" width="100%" style="text-align:left; float: left;">' SKIP
         '  <tr>' SKIP
         '    <td width="50%">' SKIP.
  {&out} '<br>' SKIP.
  turmas().

  {&out} '    </td>' SKIP
         '    <td width="50%">'  SKIP.
  {&out} '<br>' SKIP.     
  participantes().                               

  {&out} '    </td>' SKIP
         '  </tr>' SKIP
         '</table>' SKIP.
         
  {&out} '<br>' SKIP.

  {&out} '<table border="0" width="100%" style="text-align:left; float: left;">' SKIP
         '  <tr>' SKIP
         '    <td width="50%">' SKIP.
  {&out} '<br>' SKIP.
  turmasEAD().

  {&out} '    </td>' SKIP
         '    <td width="50%">'  SKIP.
  {&out} '<br>' SKIP. 
  
  participantesEAD().                               

  {&out} '    </td>' SKIP
         '  </tr>' SKIP
         '</table>' SKIP. 
      
  {&out} '<br><table border="0" width="100%" style="text-align:left; float: left;">' SKIP
         '  <tr>' SKIP
         '    <td width="50%">' SKIP.
  {&out} '<br>' SKIP.
  
  turmasGeral().

  {&out} '       </td>' SKIP
         '       <td width="50%">'  SKIP.
  {&out} '   <br>' SKIP.   
  
  participantesGeral().

  {&out} '       </td>' SKIP
         '     </tr>' SKIP
         '   </table>' SKIP.

  {&out} '   <br>' SKIP
         '   <table border="0" width="100%" style="text-align:left; float: left;">' SKIP
         '     <tr>' SKIP
         '       <td width="50%">' SKIP.
  
  {&out} '   <br>' SKIP.
  
  questionarios().

  {&out} '       </td>' SKIP
         '       <td width="50%">'  SKIP.

  totalGeral().

  {&out} '       </td>' SKIP
         '     </tr>' SKIP
         '   </table>' SKIP.

  {&out} '   <br>' SKIP.
  
  {&out} '   <table border="0" cellspacing="1" cellpadding="1" style="text-align:left; float: left;">' SKIP
         '      <tr>' SKIP
         '         <td></td>' SKIP
         '      </tr>' SKIP
         '   </table>' SKIP.
         
  {&out} '   <br>' SKIP.
  
  IF msgsDeErro <> "" THEN
    {&out} '   <table border="0" cellspacing="1" cellpadding="1" style="text-align:left; float: left;">' SKIP
          '      <tr>' SKIP
          '         <td>' msgsDeErro '</td>' SKIP
          '      </tr>' SKIP
          '   </table>' SKIP.

	{&out} ' <br>' SKIP. 
		
  RETURN TRUE.

END FUNCTION. /* montaTela RETURNS LOGICAL () */

FUNCTION montaTelaTotal RETURNS LOGICAL ():
	
	/* *** Logo Cooperativa *** */
    {&out} '   <div width="100%" style="text-align:left; float: left;"><table border="0" cellspacing="0" cellpadding="0" >' SKIP
           '      <tr>' SKIP
           '         <td align="left">&nbsp;&nbsp;&nbsp;<img src="/cecred/images/geral/logo_cecred.gif" border="0"></td>' SKIP
           '         <td class="tdTitulo1" align="left">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; TOTAL GERAL</td>' SKIP
           '      </tr>' SKIP
           '   </table><div>' SKIP. 

    {&out} ' <br>' SKIP.
	
    {&out} '   <table border="0" width="100%">' SKIP
           '     <tr>' SKIP
           '       <td width="50%">' SKIP.
    turmasTotal().

    {&out} '       </td>' SKIP
           '       <td width="50%">'  SKIP.
    participantesTotal().

    {&out} '       </td>' SKIP
           '     </tr>' SKIP
           '   </table>' SKIP.
           
    {&out} ' <br>' SKIP.
	
    {&out} '   <table border="0" width="100%">' SKIP
           '     <tr>' SKIP
           '       <td width="50%">' SKIP.

    turmasEADTotal().

    {&out} '       </td>' SKIP
           '       <td width="50%">'  SKIP.

    participantesEADTotal().

    {&out} '       </td>' SKIP
           '     </tr>' SKIP
           '   </table>' SKIP.       

    {&out} ' <br><table border="0" width="100%" style="text-align:left; float: left;">' SKIP
         '     <tr>' SKIP
         '       <td width="50%">' SKIP.

    turmasGeralTotal().

    {&out} '       </td>' SKIP
           '       <td width="50%">'  SKIP.
     
    participantesGeralTotal().

    {&out} '       </td>' SKIP
           '     </tr>' SKIP
           '   </table>' SKIP.           
    
    {&out} '   <br>' SKIP
           '   <table border="0" width="100%" style="text-align:left; float: left;">' SKIP
           '     <tr>' SKIP
           '       <td width="50%">' SKIP.
    
    {&out} '   <br>' SKIP.
    
    questionariosTotal().

    {&out} '       </td>' SKIP
           '       <td width="50%">'  SKIP.

    totalGeralTotal().

    {&out} '       </td>' SKIP
           '     </tr>' SKIP
           '   </table>' SKIP.

    IF msgsDeErro <> ""
       THEN
           {&out} '   <table border="0" cellspacing="1" cellpadding="1">' SKIP
                  '      <tr>' SKIP
                  '         <td>' msgsDeErro '</td>' SKIP
                  '      </tr>' SKIP
                  '   </table>' SKIP.

	{&out} ' <br>' SKIP. 
		
    RETURN TRUE.

END FUNCTION. /* montaTelaTotal RETURNS LOGICAL () */

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
		ASSIGN idevento = INTEGER(GET-VALUE("parametro1"))
			     cdcooper =  STRING(GET-VALUE("parametro2"))
			     dtanoage = INTEGER(GET-VALUE("parametro3"))
           nrseqpgm = INTEGER(GET-VALUE("parametro4")) NO-ERROR.          

		montaCabecalho().
		
		ASSIGN 	tot_tur_qtprevis = 0
            tot_tur_qtcancel = 0
            tot_tur_qtrecebi = 0
            tot_tur_qtacresc = 0
            tot_tur_qttransf = 0
            tot_tur_qtrealiz = 0
            tot_tur_andament = 0            
            tot_tur_qtprevis_ead = 0
            tot_tur_qtcancel_ead = 0
            tot_tur_qtrecebi_ead = 0
            tot_tur_qtacresc_ead = 0
            tot_tur_qttransf_ead = 0
            tot_tur_qtrealiz_ead = 0
            tot_tur_andament_ead = 0 /*TURMAS*/                          
            tot_prt_qtprevis = 0
            tot_prt_qtrecoop = 0
            tot_prt_qtrecomu = 0
            tot_prt_qtrealiz = 0              
            tot_prt_ttprevis = 0
            tot_prt_ttrecoop = 0
            tot_prt_ttrecomu = 0
            tot_prt_ttrealiz = 0 /*PARTICIPANTES*/            
            tot_prt_qtprevis_ead = 0
            tot_prt_qtrecoop_ead = 0
            tot_prt_qtrecomu_ead = 0
            tot_prt_qtrealiz_ead = 0              
            tot_prt_ttprevis_ead = 0
            tot_prt_ttrecoop_ead = 0
            tot_prt_ttrecomu_ead = 0
            tot_prt_ttrealiz_ead = 0            
            tot_qst_qtrealiz = 0
            aux_contcoop     = 0.
					
		FOR EACH crapcop WHERE CAN-DO(cdcooper,STRING(crapcop.cdcooper)) NO-LOCK
												BY crapcop.nmrescop:
		
			ASSIGN aux_contcoop = aux_contcoop + 1
             aux_tur_ttprevis_ead = 0
			       aux_prt_ttprevis_ead = 0
             tur_ttprevis_ead = 0
             prt_ttprevis_ead = 0.
             
			FIND LAST gnpapgd WHERE gnpapgd.idevento = idevento
                          AND gnpapgd.cdcooper = crapcop.cdcooper
                          AND gnpapgd.dtanonov = dtanoage NO-LOCK NO-ERROR.

			ASSIGN tur_qtprevis = 0
             tur_qtcancel = 0
             tur_qtrecebi = 0
             tur_qtacresc = 0
             tur_qttransf = 0
             tur_qtrealiz = 0
             tur_andament = 0             
             tur_qtprevis_ead = 0
             tur_qtcancel_ead = 0
             tur_qtrecebi_ead = 0
             tur_qtacresc_ead = 0
             tur_qttransf_ead = 0
             tur_qtrealiz_ead = 0
             tur_andament_ead = 0 /*TURMAS*/              
             prt_qtprevis = 0
             prt_qtrecoop = 0
             prt_qtrecomu = 0
             prt_qtrealiz = 0             
             prt_qtprevis_ead = 0
             prt_qtrecoop_ead = 0
             prt_qtrecomu_ead = 0
             prt_qtrealiz_ead = 0  /*PARTICIPANTES*/             
             qst_qtprevis = gnpapgd.qtretque / 12
             qst_qtrealiz = 0.
				
			DO aux_contador = 1 TO 12:
        
        IF aux_contador = 1 THEN
          DO:
            FOR EACH crapced WHERE crapced.dtanoage = dtanoage
                               AND crapced.cdcooper = crapcop.cdcooper NO-LOCK:
            
              ASSIGN tur_ttprevis_ead = tur_ttprevis_ead + crapced.qtocoeve
                     prt_ttprevis_ead = prt_ttprevis_ead + (crapced.qtocoeve * crapced.qtpareve)
                     aux_tur_ttprevis_ead = aux_tur_ttprevis_ead + crapced.qtocoeve
                     aux_prt_ttprevis_ead = aux_prt_ttprevis_ead + (crapced.qtocoeve * crapced.qtpareve)
                     tur_qtprevis_ead[aux_contador] = tur_qtprevis_ead[aux_contador] + crapced.qtocoeve                     
                     prt_qtprevis_ead[aux_contador] = prt_qtprevis_ead[aux_contador] + (crapced.qtpareve * crapced.qtocoeve)
                     aux_tot_prt_qtprevis_ead =  aux_tot_prt_qtprevis_ead + (crapced.qtpareve * crapced.qtocoeve).
            END.                   
            
            ASSIGN tur_ttprevis_ead                   = tur_ttprevis_ead
                   tot_tur_ttprevis_ead               = tot_tur_ttprevis_ead + tur_ttprevis_ead
                   prt_ttprevis_ead                   = prt_ttprevis_ead
                   tot_prt_ttprevis_ead               = aux_tot_prt_qtprevis_ead
                   tur_qtprevis_ead[aux_contador]     = ROUND(tur_qtprevis_ead[aux_contador] / 12,0)
                   prt_qtprevis_ead[aux_contador]     = ROUND(prt_qtprevis_ead[aux_contador] / 12,0).
          END.
                  
        ASSIGN tur_qtprevis_ead[aux_contador]     = tur_qtprevis_ead[1]
               prt_qtprevis_ead[aux_contador]     = prt_qtprevis_ead[1].
        
        IF aux_tur_ttprevis_ead < 0 THEN       
           ASSIGN tur_qtprevis_ead[aux_contador] = 0.
        ELSE IF aux_tur_ttprevis_ead < tur_qtprevis_ead[1] THEN
           ASSIGN tur_qtprevis_ead[aux_contador] = aux_tur_ttprevis_ead.
        
        ASSIGN aux_tur_ttprevis_ead = aux_tur_ttprevis_ead - tur_qtprevis_ead[1].

        IF aux_contador = 12 AND aux_tur_ttprevis_ead > 0 THEN        
          tur_qtprevis_ead[aux_contador] = tur_qtprevis_ead[aux_contador] + aux_tur_ttprevis_ead.

                
        IF aux_prt_ttprevis_ead < 0 THEN       
           ASSIGN prt_qtprevis_ead[aux_contador] = 0.
        ELSE IF aux_prt_ttprevis_ead < prt_qtprevis_ead[1] THEN
           ASSIGN prt_qtprevis_ead[aux_contador] = aux_prt_ttprevis_ead.
           
        ASSIGN aux_prt_ttprevis_ead = aux_prt_ttprevis_ead - prt_qtprevis_ead[1]
               tot_tur_qtprevis_ead[aux_contador] = tot_tur_qtprevis_ead[aux_contador] + tur_qtprevis_ead[aux_contador]
               tot_prt_qtprevis_ead[aux_contador] = tot_prt_qtprevis_ead[aux_contador] + prt_qtprevis_ead[aux_contador]. 
                
        IF aux_contador = 12 AND aux_prt_ttprevis_ead > 0 THEN        
          prt_qtprevis_ead[aux_contador] = prt_qtprevis_ead[aux_contador] + aux_prt_ttprevis_ead.
          
        /* totalizador da quantidade de kits previstos */
        IF aux_contcoop > 0 THEN
          ASSIGN tot_qst_qtprevis[aux_contador] = tot_qst_qtprevis[aux_contador] + gnpapgd.qtretque / 12.        

				/* Eventos originados no mes */
				FOR EACH crapadp WHERE crapadp.idevento = idevento
                           AND crapadp.cdcooper = crapcop.cdcooper
                           AND crapadp.dtanoage = dtanoage
                           AND crapadp.nrmesage = aux_contador NO-LOCK,
					 EACH crapedp WHERE crapedp.idevento = crapadp.idevento 
													AND crapedp.cdcooper = crapadp.cdcooper
													AND crapedp.dtanoage = crapadp.dtanoage 
													AND crapedp.cdevento = crapadp.cdevento
													AND (crapedp.nrseqpgm = INT(nrseqpgm)      
													OR INT(nrseqpgm) = 0) NO-LOCK:
				
				  ASSIGN aux_tpevento = crapedp.tpevento. 
                      
					IF CAN-FIND(FIRST craphep WHERE craphep.idevento = 0
                                      AND craphep.cdcooper = 0
                                      AND craphep.dtanoage = 0
                                      AND craphep.cdevento = 0
                                      AND craphep.cdagenci = crapadp.nrseqdig
                                      AND craphep.dshiseve MATCHES "*acrescido*" NO-LOCK) THEN
            DO:
              /* Acrescido */
              
              IF aux_tpevento = 10 THEN
                ASSIGN tur_qtacresc_ead[aux_contador] = tur_qtacresc_ead[aux_contador] + 1
                       tot_tur_qtacresc_ead[aux_contador] = tot_tur_qtacresc_ead[aux_contador] + 1. /*JMD*/
              ELSE
                ASSIGN tur_qtacresc[aux_contador] = tur_qtacresc[aux_contador] + 1
                       tot_tur_qtacresc[aux_contador] = tot_tur_qtacresc[aux_contador] + 1. 
            END.       
					ELSE
            DO:              
              /* Previsto */
              IF aux_tpevento <> 10 THEN
                ASSIGN tur_qtprevis[aux_contador] = tur_qtprevis[aux_contador] + 1
                       tot_tur_qtprevis[aux_contador] = tot_tur_qtprevis[aux_contador] + 1.
            END.    
            
					/* Transferido */
					IF crapadp.nrmesage <> crapadp.nrmeseve   THEN
            DO:
              IF aux_tpevento = 10 THEN
                ASSIGN tur_qttransf_ead[aux_contador] = tur_qttransf_ead[aux_contador] + 1 /*JMD*/
                       tot_tur_qttransf_ead[aux_contador] = tot_tur_qttransf_ead[aux_contador] + 1.
              ELSE
                ASSIGN tur_qttransf[aux_contador] = tur_qttransf[aux_contador] + 1
                       tot_tur_qttransf[aux_contador] = tot_tur_qttransf[aux_contador] + 1.
            END.         
					ELSE
						DO:
							/* cancelado */
							IF crapadp.idstaeve = 2 THEN 
                DO:
                  IF aux_tpevento = 10 THEN
                    ASSIGN tur_qtcancel_ead[aux_contador] = tur_qtcancel_ead[aux_contador] + 1 /*JMD*/
                           tot_tur_qtcancel_ead[aux_contador] = tot_tur_qtcancel_ead[aux_contador] + 1.
                  ELSE
                    ASSIGN tur_qtcancel[aux_contador] = tur_qtcancel[aux_contador] + 1
                           tot_tur_qtcancel[aux_contador] = tot_tur_qtcancel[aux_contador] + 1.
                END.            
							ELSE
								DO:
									/* realizado */ 
									IF crapadp.dtfineve < TODAY THEN
										DO:                      
                      
											/* Considerar mês da data final do evento para Realizado */ 
											
                      IF aux_tpevento = 10 THEN
                        ASSIGN tur_qtrealiz_ead[MONTH(crapadp.dtfineve)] = tur_qtrealiz_ead[MONTH(crapadp.dtfineve)] + 1 /*JMD*/
                               tot_tur_qtrealiz_ead[MONTH(crapadp.dtfineve)] = tot_tur_qtrealiz_ead[MONTH(crapadp.dtfineve)] + 1.
                      ELSE
                        ASSIGN tur_qtrealiz[MONTH(crapadp.dtfineve)] = tur_qtrealiz[MONTH(crapadp.dtfineve)] + 1
                               tot_tur_qtrealiz[MONTH(crapadp.dtfineve)] = tot_tur_qtrealiz[MONTH(crapadp.dtfineve)] + 1. 
																							
											/* Contabiliza "Em andamento" para os meses anteriores ao mês final do evento */ 
											IF MONTH(crapadp.dtinieve) <> MONTH(crapadp.dtfineve)  THEN
												DO:
													DO aux_mesatual = MONTH(crapadp.dtinieve) TO MONTH(crapadp.dtfineve) - 1:
														
                            IF aux_tpevento = 10 THEN
                              ASSIGN tur_andament_ead[aux_mesatual] = tur_andament_ead[aux_mesatual] + 1 /*JMD*/
                                     tot_tur_andament_ead[aux_mesatual] = tot_tur_andament_ead[aux_mesatual] + 1.
                            ELSE
                              ASSIGN tur_andament[aux_mesatual] = tur_andament[aux_mesatual] + 1
                                     tot_tur_andament[aux_mesatual] = tot_tur_andament[aux_mesatual] + 1.
													END.
												END.
										END.
									ELSE
										DO:
											/*IF MONTH(crapadp.dtinieve) <= MONTH(TODAY)  THEN
												DO:
													/* Contabiliza "Em andamento" do mês inicial até o mês da data de consulta */ 
													DO aux_mesatual = MONTH(crapadp.dtinieve) TO MONTH(TODAY):
														/* em andamento */ 
														
                            IF aux_tpevento = 10 THEN
                              ASSIGN tur_andament_ead[aux_mesatual] = tur_andament_ead[aux_mesatual] + 1 /*JMD*/
                                     tot_tur_andament_ead[aux_mesatual] = tot_tur_andament_ead[aux_mesatual] + 1.
                            ELSE
                              ASSIGN tur_andament[aux_mesatual] = tur_andament[aux_mesatual] + 1
                                     tot_tur_andament[aux_mesatual] = tot_tur_andament[aux_mesatual] + 1.
                              
													END.
												END.*/
                        IF aux_tpevento = 10 THEN
                          ASSIGN tur_andament_ead[aux_contador] = tur_andament_ead[aux_contador] + 1 /*JMD*/
                                 tot_tur_andament_ead[aux_contador] = tot_tur_andament_ead[aux_contador] + 1.
                        ELSE
                          DO:
                            IF MONTH(crapadp.dtinieve) <= MONTH(TODAY)  THEN
                              DO:
                                /* Contabiliza "Em andamento" do mês inicial até o mês da data de consulta */ 
                                DO aux_mesatual = MONTH(crapadp.dtinieve) TO MONTH(TODAY):
                                  /* em andamento */ 
                                  
                                  IF aux_tpevento = 10 THEN
                                    ASSIGN tur_andament_ead[aux_mesatual] = tur_andament_ead[aux_mesatual] + 1 /*JMD*/
                                           tot_tur_andament_ead[aux_mesatual] = tot_tur_andament_ead[aux_mesatual] + 1.
                                  ELSE
                                    ASSIGN tur_andament[aux_mesatual] = tur_andament[aux_mesatual] + 1
                                           tot_tur_andament[aux_mesatual] = tot_tur_andament[aux_mesatual] + 1.
                                    
                                END.
                              END.
                          END.
                        
										END.
								END.
						END.
            
            IF aux_tpevento <> 10 THEN
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
                                     AND crapeap.cdagenci = crapadp.cdagenci NO-LOCK NO-ERROR NO-WAIT.
                 
                IF AVAILABLE crapeap THEN
                  DO:
                    IF crapeap.qtmaxtur > 0 THEN
                      DO:
                        /*IF aux_tpevento = 10 THEN
                          DO:
                            FIND FIRST crapced WHERE crapced.dtanoage = crapadp.dtanoage
                                                 AND crapced.cdcooper = crapadp.cdcooper
                                                 AND crapced.cdagenci = crapadp.cdagenci
                                                 AND crapced.cdevento = crapadp.cdevento NO-LOCK NO-ERROR NO-WAIT.
                                                 
                            IF AVAILABLE crapced THEN                      
                              DO:
                                ASSIGN prt_qtprevis_ead[aux_contador] = prt_qtprevis_ead[aux_contador] + crapced.qtpareve
                                       tot_prt_qtprevis_ead[aux_contador] = tot_prt_qtprevis_ead[aux_contador] + crapeap.qtmaxtur. /*JMD*/
                              END.         
                          END.  
                        ELSE*/
                          
                          ASSIGN prt_qtprevis[aux_contador] = prt_qtprevis[aux_contador] + crapeap.qtmaxtur
                                 tot_prt_qtprevis[aux_contador] = tot_prt_qtprevis[aux_contador] + crapeap.qtmaxtur.
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
                                /*IF aux_tpevento = 10 THEN
                                  ASSIGN prt_qtprevis_ead[aux_contador] = prt_qtprevis_ead[aux_contador] + crabedp.qtmaxtur
                                         tot_prt_qtprevis_ead[aux_contador] = tot_prt_qtprevis_ead[aux_contador] + crabedp.qtmaxtur. /*JMD*/
                                ELSE*/
                                  
                                  ASSIGN prt_qtprevis[aux_contador] = prt_qtprevis[aux_contador] + crabedp.qtmaxtur
                                         tot_prt_qtprevis[aux_contador] = tot_prt_qtprevis[aux_contador] + crabedp.qtmaxtur.
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
                                    /*IF aux_tpevento = 10 THEN
                                      ASSIGN prt_qtprevis_ead[aux_contador] = prt_qtprevis_ead[aux_contador] + crabedp.qtmaxtur
                                               tot_prt_qtprevis_ead[aux_contador] = tot_prt_qtprevis_ead[aux_contador] + crabedp.qtmaxtur. /*JMD*/
                                    ELSE*/
                                      
                                      ASSIGN prt_qtprevis[aux_contador] = prt_qtprevis[aux_contador] + crabedp.qtmaxtur
                                               tot_prt_qtprevis[aux_contador] = tot_prt_qtprevis[aux_contador] + crabedp.qtmaxtur.
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
                            /*IF aux_tpevento = 10 THEN
                              ASSIGN prt_qtprevis_ead[aux_contador] = prt_qtprevis_ead[aux_contador] + crabedp.qtmaxtur
                                     tot_prt_qtprevis_ead[aux_contador] = tot_prt_qtprevis_ead[aux_contador] + crabedp.qtmaxtur. /*JMD*/
                            ELSE*/
                              
                              ASSIGN prt_qtprevis[aux_contador] = prt_qtprevis[aux_contador] + crabedp.qtmaxtur
                                     tot_prt_qtprevis[aux_contador] = tot_prt_qtprevis[aux_contador] + crabedp.qtmaxtur.
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
                                /*IF aux_tpevento = 10 THEN
                                  ASSIGN prt_qtprevis_ead[aux_contador] = prt_qtprevis_ead[aux_contador] + crabedp.qtmaxtur
                                         tot_prt_qtprevis_ead[aux_contador] = tot_prt_qtprevis_ead[aux_contador] + crabedp.qtmaxtur. /*JMD*/
                                ELSE*/
                                  
                                  ASSIGN prt_qtprevis[aux_contador] = prt_qtprevis[aux_contador] + crabedp.qtmaxtur
                                         tot_prt_qtprevis[aux_contador] = tot_prt_qtprevis[aux_contador] + crabedp.qtmaxtur.
                              END.         
                          END.
                      END.
                  END.
              END.    
            END. /*FIM IF aux_tpevento = 10 */
            
				END. /* FIM - eventos originados no mes */ /*JMD HJ*/
				 
				/* eventos executados no mes */
				FOR EACH crapadp WHERE crapadp.idevento  = idevento
                           AND crapadp.cdcooper  = crapcop.cdcooper
                           AND crapadp.dtanoage  = dtanoage
                           AND crapadp.nrmeseve  = aux_contador NO-LOCK:

          ASSIGN aux_tpevento = 0.
					
          FOR FIRST crapedp FIELDS(tpevento) WHERE crapedp.cdevento = crapadp.cdevento
                                               AND crapedp.cdcooper = 0
                                               AND crapedp.dtanoage = 0
                                               AND crapedp.idevento = idevento 
                                               AND (crapedp.nrseqpgm = INT(nrseqpgm)      
                                                OR INT(nrseqpgm) = 0) NO-LOCK. END.
          
          IF NOT AVAILABLE crapedp THEN
            ASSIGN aux_tpevento = 0.
          ELSE
            ASSIGN aux_tpevento = crapedp.tpevento. 
            
					IF crapadp.nrmeseve <> crapadp.nrmesage   THEN
						DO:
							/* recebido */							
              IF aux_tpevento = 10 THEN
                ASSIGN tur_qtrecebi_ead[aux_contador] = tur_qtrecebi_ead[aux_contador] + 1 /*JMD*/
                       tot_tur_qtrecebi_ead[aux_contador] = tot_tur_qtrecebi_ead[aux_contador] + 1.
              ELSE
                ASSIGN tur_qtrecebi[aux_contador] = tur_qtrecebi[aux_contador] + 1
                       tot_tur_qtrecebi[aux_contador] = tot_tur_qtrecebi[aux_contador] + 1. 

							/* cancelado */
							IF crapadp.idstaeve = 2 THEN
                DO:
                  IF aux_tpevento = 10 THEN
                    ASSIGN tur_qtcancel_ead[aux_contador] = tur_qtcancel_ead[aux_contador] + 1 /*JMD*/
                           tot_tur_qtcancel_ead[aux_contador] = tot_tur_qtcancel_ead[aux_contador] + 1.
                  ELSE
                    ASSIGN tur_qtcancel[aux_contador] = tur_qtcancel[aux_contador] + 1
                           tot_tur_qtcancel[aux_contador] = tot_tur_qtcancel[aux_contador] + 1.
                END.       
							ELSE
								DO:
									/* realizado */
									IF crapadp.dtfineve < TODAY   THEN
										DO: 
											IF aux_tpevento = 10 THEN
                        ASSIGN tur_qtrealiz_ead[MONTH(crapadp.dtfineve)] = tur_qtrealiz_ead[MONTH(crapadp.dtfineve)] + 1 /*JMD*/
                               tot_tur_qtrealiz_ead[MONTH(crapadp.dtfineve)] = tot_tur_qtrealiz_ead[MONTH(crapadp.dtfineve)] + 1. 
                      ELSE
                        ASSIGN tur_qtrealiz[MONTH(crapadp.dtfineve)] = tur_qtrealiz[MONTH(crapadp.dtfineve)] + 1
                               tot_tur_qtrealiz[MONTH(crapadp.dtfineve)] = tot_tur_qtrealiz[MONTH(crapadp.dtfineve)] + 1.
																							
											/* Contabiliza "Em andamento" para os meses anteriores ao mês final do evento */ 
											IF MONTH(crapadp.dtinieve) <> MONTH(crapadp.dtfineve)  THEN
												DO:
													DO aux_mesatual = MONTH(crapadp.dtinieve) TO MONTH(crapadp.dtfineve) - 1:
	                             
                            /*IF aux_tpevento = 10 THEN
                              ASSIGN tur_andament_ead[aux_mesatual] = tur_andament_ead[aux_mesatual] + 1 /*JMD*/ 					
                                     tot_tur_andament_ead[aux_mesatual] = tot_tur_andament_ead[aux_mesatual] + 1.
                            ELSE*/
                              ASSIGN tur_andament[aux_mesatual] = tur_andament[aux_mesatual] + 1
                                     tot_tur_andament[aux_mesatual] = tot_tur_andament[aux_mesatual] + 1.                                   						
													END.
												END.
										END.        
									ELSE
										DO:
											IF MONTH(crapadp.dtinieve) <= MONTH(TODAY) THEN
												DO:
													/* Contabiliza "Em andamento" do mês inicial até o mês da data de consulta */ 
													DO aux_mesatual = MONTH(crapadp.dtinieve) TO MONTH(TODAY):
														
                            IF aux_tpevento = 10 THEN
                              ASSIGN tur_andament_ead[aux_mesatual] = 666 /*tur_andament_ead[aux_mesatual] + 1 /*JMD*/*/
                                     tot_tur_andament_ead[aux_mesatual] = 666. /*tot_tur_andament_ead[aux_mesatual] + 1.*/
                            ELSE
                              ASSIGN tur_andament[aux_mesatual] = tur_andament[aux_mesatual] + 1
                                     tot_tur_andament[aux_mesatual] = tot_tur_andament[aux_mesatual] + 1.                                   
													END.
												END.
										END.        
								END.
						END.

					/* para a frequencia minima */
					FIND FIRST crapedp WHERE crapedp.idevento = crapadp.idevento
                               AND crapedp.cdcooper = crapadp.cdcooper
                               AND crapedp.dtanoage = crapadp.dtanoage
                               AND crapedp.cdevento = crapadp.cdevento
                               AND (crapedp.nrseqpgm = INT(nrseqpgm)      
                                OR INT(nrseqpgm) = 0) NO-LOCK.
						  
					/* Participantes realizados */
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
              
              IF AVAILABLE crapidp AND AVAILABLE crapadp AND AVAILABLE crapedp THEN                 
              DO:
								/* Se percentual de faltas for suficiente em relacao ao percentual mínimo exigido */
								IF ((crapidp.qtfaleve * 100) / crapadp.qtdiaeve) <= (100 - crapedp.prfreque) THEN
									DO:
										IF crapidp.tpinseve = 1 THEN
                      DO:
                        IF aux_tpevento = 10 THEN
                          ASSIGN prt_qtrecoop_ead[MONTH(crapidp.dtconins)] = prt_qtrecoop_ead[MONTH(crapidp.dtconins)] + 1 /*JMD*/
                                 tot_prt_qtrecoop_ead[MONTH(crapidp.dtconins)] = tot_prt_qtrecoop_ead[MONTH(crapidp.dtconins)] + 1.
                        ELSE
                          ASSIGN prt_qtrecoop[MONTH(crapadp.dtfineve)] = prt_qtrecoop[MONTH(crapadp.dtfineve)] + 1
                                 tot_prt_qtrecoop[MONTH(crapadp.dtfineve)] = tot_prt_qtrecoop[MONTH(crapadp.dtfineve)] + 1.
                               
                      END.         
										ELSE 
                      DO:
                        IF aux_tpevento = 10 THEN
                          ASSIGN prt_qtrecomu_ead[MONTH(crapidp.dtconins)] = prt_qtrecomu_ead[MONTH(crapidp.dtconins)] + 1 /*JMD*/
                                 tot_prt_qtrecomu_ead[MONTH(crapidp.dtconins)] = tot_prt_qtrecomu_ead[MONTH(crapidp.dtconins)] + 1. 
                        ELSE
                          ASSIGN prt_qtrecomu[MONTH(crapadp.dtfineve)] = prt_qtrecomu[MONTH(crapadp.dtfineve)] + 1
                                 tot_prt_qtrecomu[MONTH(crapadp.dtfineve)] = tot_prt_qtrecomu[MONTH(crapadp.dtfineve)] + 1.
                          
                      END.
										                    
                    IF aux_tpevento = 10 THEN
                      ASSIGN prt_qtrealiz_ead[MONTH(crapidp.dtconins)] = prt_qtrealiz_ead[MONTH(crapidp.dtconins)] + 1 /*JMD*/
                             tot_prt_qtrealiz_ead[MONTH(crapidp.dtconins)] = tot_prt_qtrealiz_ead[MONTH(crapidp.dtconins)] + 1. 
                    ELSE
                      ASSIGN prt_qtrealiz[MONTH(crapadp.dtfineve)] = prt_qtrealiz[MONTH(crapadp.dtfineve)] + 1
                             tot_prt_qtrealiz[MONTH(crapadp.dtfineve)] = tot_prt_qtrealiz[MONTH(crapadp.dtfineve)] + 1.
                           
									END.
                END.
              END.  
					END.
									 
				END. /* FIM - eventos executados no mes */ /*JMD HJ*/
							 
				/* Questionários realizados no mes */
				FOR EACH crapkbq WHERE crapkbq.idevento = idevento
                           AND crapkbq.cdcooper = crapcop.cdcooper
                           AND crapkbq.dtanoage = dtanoage
                           AND crapkbq.tpdeitem = 3 /*Questionários*/
                           AND MONTH(crapkbq.dtdenvio) = aux_contador NO-LOCK:
					 
					ASSIGN tot_qst_qtrealiz[aux_contador] = tot_qst_qtrealiz[aux_contador] + crapkbq.qtdenvio
                 qst_qtrealiz[aux_contador] = qst_qtrealiz[aux_contador] + crapkbq.qtdenvio.
				END.
				
				/* FIM - Questionários realizados no mes */
                 
			END. /* fim do DO .. TO */				  
			
			ASSIGN nomedacooperativa = TRIM(crapcop.nmrescop).
		   
			IF INDEX(crapcop.nmrescop, " ") <> 0  THEN
				DO: 
					aux_nmrescop = LC(TRIM(crapcop.nmrescop)).
					SUBSTRING( aux_nmrescop, (INDEX(aux_nmrescop, " ")),1) = "_".
					imagemDaCooperativa =  "/cecred/images/admin/logo_" +  aux_nmrescop + ".gif".
				END.			
			ELSE
				imagemDaCooperativa  = "/cecred/images/admin/logo_" + TRIM(LC(crapcop.nmrescop)) + ".gif" .
				
			montaTela(). 
			
		END. /* Fim FOR EACH crapcop */
		
		IF R-INDEX(cdcooper,",") > 0 THEN
			DO:
        montaTelaTotal(). 
			END.
		
		montaRodape().
	END.
          
/**************************/
/*   Bloco de procdures   */
/**************************/

PROCEDURE PermissaoDeAcesso:
	{includes/wpgd0009.i}
END PROCEDURE.