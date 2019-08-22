/* ..........................................................................

   Programa: Includes/var_crps010.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Janeiro/92.                         Ultima atualizacao: 16/10/2008

   Dados referentes ao programa:

   Frequencia: Mensal (Batch - Background).
   Objetivo  : Definicao das variaveis utilizadas pelo programa crps010.p.

   Alteracoes: 06/05/2004 - Mostrar o capital a integralizar (Edson).
   
               18/08/2005 - Detalhar os admitidos de cada PAC (Evandro).
               
               22/11/2006 - Variavel aux_desconto (Evandro).
               
               22/08/2008 - Incluidas variaveis para calcular total da listagem
                            do relatorio 031 (Gabriel).
               
               16/10/2008 - Incluida variavel "aux_desctitu" para calculo de
                            desconto de titulos (Elton). 
                                        
............................................................................. */

DEF {1} SHARED VAR rel_nrmodulo AS INT     FORMAT "9"                NO-UNDO.
DEF {1} SHARED VAR rel_nmmodulo AS CHAR    FORMAT "x(15)" EXTENT 5
                                   INIT ["DEP. A VISTA   ","CAPITAL        ",
                                         "EMPRESTIMOS    ","DIGITACAO      ",
                                         "GENERICO       "]          NO-UNDO.

DEF {1} SHARED VAR rel_dsagenci     AS CHAR    FORMAT "x(21)"          NO-UNDO.
DEF {1} SHARED VAR rel_dslimcre     AS CHAR    FORMAT "x(2)"           NO-UNDO.
DEF {1} SHARED VAR rel_nmempres     AS CHAR    FORMAT "x(15)"          NO-UNDO.
DEF {1} SHARED VAR rel_nmresemp     AS CHAR    FORMAT "x(15)"          NO-UNDO.
DEF {1} SHARED VAR rel_dsdacstp     AS CHAR                            NO-UNDO.
DEF {1} SHARED VAR rel_nmrelato     AS CHAR    FORMAT "x(40)" EXTENT 5 NO-UNDO.
DEF {1} SHARED VAR rel_dsmsgrec     AS CHAR    INIT "** RECADASTRAR **" NO-UNDO.

DEF {1} SHARED VAR rel_nomemes1     AS CHAR                            NO-UNDO.
DEF {1} SHARED VAR rel_nomemes2     AS CHAR                            NO-UNDO.
DEF {1} SHARED VAR rel_nomemes3     AS CHAR                            NO-UNDO.

DEF {1} SHARED VAR rel_vlsmtrag     AS DECIMAL                         NO-UNDO.
DEF {1} SHARED VAR rel_vlsmmes1     AS DECIMAL                         NO-UNDO.
DEF {1} SHARED VAR rel_vlsmmes2     AS DECIMAL                         NO-UNDO.
DEF {1} SHARED VAR rel_vlsmmes3     AS DECIMAL                         NO-UNDO.

DEF {1} SHARED VAR rel_vlcaptal     AS DECIMAL                         NO-UNDO.
DEF {1} SHARED VAR rel_vlprepla     AS DECIMAL                         NO-UNDO.

DEF {1} SHARED VAR rel_qtprpgpl     AS INT                             NO-UNDO.
DEF {1} SHARED VAR rel_qtpreapg     AS INT                             NO-UNDO.

DEF {1} SHARED VAR tot_nmtitulo     AS CHAR                            NO-UNDO.
DEF {1} SHARED VAR tot_nmresage     AS CHAR                            NO-UNDO.
DEF {1} SHARED VAR age_dsagenci     AS CHAR                            NO-UNDO.

DEF NEW SHARED VAR tot_lancamen     AS INTEGER                         NO-UNDO.
DEF NEW SHARED VAR tot_vllanmto     AS DECIMAL                         NO-UNDO.

DEF {1} SHARED VAR tot_nrassmag     AS INT     EXTENT 599              NO-UNDO.
DEF {1} SHARED VAR tot_vlsmtrag     AS DECIMAL EXTENT 599              NO-UNDO.
DEF {1} SHARED VAR tot_vlsmmes1     AS DECIMAL EXTENT 599              NO-UNDO.
DEF {1} SHARED VAR tot_vlsmmes2     AS DECIMAL EXTENT 599              NO-UNDO.
DEF {1} SHARED VAR tot_vlsmmes3     AS DECIMAL EXTENT 599              NO-UNDO.
DEF {1} SHARED VAR tot_vlcaptal     AS DECIMAL EXTENT 599              NO-UNDO.

DEF {1} SHARED VAR tot_qtassemp     AS INT     EXTENT 599              NO-UNDO.
DEF {1} SHARED VAR tot_qtctremp     AS INT     EXTENT 599              NO-UNDO.
DEF {1} SHARED VAR tot_vlpreemp     AS DECIMAL EXTENT 599              NO-UNDO.
DEF {1} SHARED VAR tot_vlsdeved     AS DECIMAL EXTENT 599              NO-UNDO.
DEF {1} SHARED VAR tot_vljurmes     AS DECIMAL EXTENT 599              NO-UNDO.

DEF {1} SHARED VAR tot_nrdplaag     AS INT     EXTENT 599              NO-UNDO.
DEF {1} SHARED VAR tot_vlprepla     AS DECIMAL EXTENT 599              NO-UNDO.

DEF {1} SHARED VAR tot_qtjrecad     AS INT     EXTENT 599              NO-UNDO.
DEF {1} SHARED VAR tot_qtnrecad     AS INT     EXTENT 599              NO-UNDO.
DEF {1} SHARED VAR tot_qtadmiss     AS INT     EXTENT 599              NO-UNDO.

DEF {1} SHARED VAR age_qtcotist_ati AS INT     EXTENT 599              NO-UNDO.
DEF {1} SHARED VAR age_qtcotist_dem AS INT     EXTENT 599              NO-UNDO.
DEF {1} SHARED VAR age_qtassmes_adm AS INT     EXTENT 599              NO-UNDO.

DEF {1} SHARED VAR ger_nrassmag     AS INT                             NO-UNDO.
DEF {1} SHARED VAR ger_vlsmtrag     AS DECIMAL                         NO-UNDO.
DEF {1} SHARED VAR ger_vlsmmes1     AS DECIMAL                         NO-UNDO.
DEF {1} SHARED VAR ger_vlsmmes2     AS DECIMAL                         NO-UNDO.
DEF {1} SHARED VAR ger_vlsmmes3     AS DECIMAL                         NO-UNDO.
DEF {1} SHARED VAR ger_vlcaptal     AS DECIMAL                         NO-UNDO.

DEF {1} SHARED VAR ger_qtassemp     AS INT                             NO-UNDO.
DEF {1} SHARED VAR ger_qtctremp     AS INT                             NO-UNDO.
DEF {1} SHARED VAR ger_vlpreemp     AS DECIMAL                         NO-UNDO.
DEF {1} SHARED VAR ger_vlsdeved     AS DECIMAL                         NO-UNDO.
DEF {1} SHARED VAR ger_vljurmes     AS DECIMAL                         NO-UNDO.

DEF {1} SHARED VAR ger_nrdplaag     AS INT                             NO-UNDO.
DEF {1} SHARED VAR ger_vlprepla     AS DECIMAL                         NO-UNDO.

DEF {1} SHARED VAR ger_qtjrecad     AS INT                             NO-UNDO.
DEF {1} SHARED VAR ger_qtnrecad     AS INT                             NO-UNDO.
DEF {1} SHARED VAR ger_qtadmiss     AS INT                             NO-UNDO.

DEF {1} SHARED VAR int_vlcapcrz_ati AS DECIMAL                         NO-UNDO.
DEF {1} SHARED VAR int_vlcapcrz_dem AS DECIMAL                         NO-UNDO.
DEF {1} SHARED VAR int_vlcapcrz_exc AS DECIMAL                         NO-UNDO.
DEF {1} SHARED VAR int_vlcapcrz_tot AS DECIMAL                         NO-UNDO.

DEF {1} SHARED VAR sub_vlcapcrz_ati AS DECIMAL                         NO-UNDO.
DEF {1} SHARED VAR sub_vlcapcrz_dem AS DECIMAL                         NO-UNDO.
DEF {1} SHARED VAR sub_vlcapcrz_exc AS DECIMAL                         NO-UNDO.
DEF {1} SHARED VAR sub_vlcapcrz_tot AS DECIMAL                         NO-UNDO.

DEF {1} SHARED VAR tcs_vlcapcrz_ati AS DECIMAL                         NO-UNDO.
DEF {1} SHARED VAR tcs_vlcapcrz_dem AS DECIMAL                         NO-UNDO.
DEF {1} SHARED VAR tcs_vlcapcrz_exc AS DECIMAL                         NO-UNDO.
DEF {1} SHARED VAR tcs_vlcapcrz_tot AS DECIMAL                         NO-UNDO.

DEF {1} SHARED VAR res_vlcapcrz_ati AS DECIMAL                         NO-UNDO.
DEF {1} SHARED VAR res_vlcapcrz_dem AS DECIMAL                         NO-UNDO.
DEF {1} SHARED VAR res_vlcapcrz_exc AS DECIMAL                         NO-UNDO.
DEF {1} SHARED VAR res_vlcapcrz_tot AS DECIMAL                         NO-UNDO.

DEF {1} SHARED VAR res_vlcapmfx_ati AS DECIMAL                         NO-UNDO.
DEF {1} SHARED VAR res_vlcapmfx_dem AS DECIMAL                         NO-UNDO.
DEF {1} SHARED VAR res_vlcapmfx_exc AS DECIMAL                         NO-UNDO.
DEF {1} SHARED VAR res_vlcapmfx_tot AS DECIMAL                         NO-UNDO.

DEF {1} SHARED VAR res_vlcmicot_ati AS DECIMAL                         NO-UNDO.
DEF {1} SHARED VAR res_vlcmicot_dem AS DECIMAL                         NO-UNDO.
DEF {1} SHARED VAR res_vlcmicot_exc AS DECIMAL                         NO-UNDO.
DEF {1} SHARED VAR res_vlcmicot_tot AS DECIMAL                         NO-UNDO.

DEF {1} SHARED VAR res_vlcmmcot_ati AS DECIMAL                         NO-UNDO.
DEF {1} SHARED VAR res_vlcmmcot_dem AS DECIMAL                         NO-UNDO.
DEF {1} SHARED VAR res_vlcmmcot_exc AS DECIMAL                         NO-UNDO.
DEF {1} SHARED VAR res_vlcmmcot_tot AS DECIMAL                         NO-UNDO.

DEF {1} SHARED VAR res_qtcotist_ati AS INT                             NO-UNDO.
DEF {1} SHARED VAR res_qtcotist_dem AS INT                             NO-UNDO.
DEF {1} SHARED VAR res_qtcotist_exc AS INT                             NO-UNDO.
DEF {1} SHARED VAR res_qtcotist_tot AS INT                             NO-UNDO.

DEF {1} SHARED VAR dup_qtcotist_ati AS INT                             NO-UNDO.
DEF {1} SHARED VAR dup_qtcotist_dem AS INT                             NO-UNDO.
DEF {1} SHARED VAR dup_qtcotist_exc AS INT                             NO-UNDO.
DEF {1} SHARED VAR dup_qtcotist_tot AS INT                             NO-UNDO.

DEF {1} SHARED VAR res_qtdemmes_ati AS INT                             NO-UNDO.
DEF {1} SHARED VAR res_qtdemmes_dem AS INT                             NO-UNDO.
DEF {1} SHARED VAR res_qtdemmes_exc AS INT                             NO-UNDO.

DEF {1} SHARED VAR res_qtdesmes_ati AS INT                             NO-UNDO.
DEF {1} SHARED VAR res_qtdesmes_dem AS INT                             NO-UNDO.
DEF {1} SHARED VAR res_qtdesmes_exc AS INT                             NO-UNDO.

DEF {1} SHARED VAR res_qtassati     AS INT                             NO-UNDO.
DEF {1} SHARED VAR res_qtassdem     AS INT                             NO-UNDO.
DEF {1} SHARED VAR res_qtassbai     AS INT                             NO-UNDO.
DEF {1} SHARED VAR res_qtassmes     AS INT                             NO-UNDO.

DEF {1} SHARED VAR tot_qtassati     AS INT                             NO-UNDO.
DEF {1} SHARED VAR tot_qtassdem     AS INT                             NO-UNDO.
DEF {1} SHARED VAR tot_qtassexc     AS INT                             NO-UNDO.

DEF {1} SHARED VAR aux_cdagenci AS INT                                 NO-UNDO.
DEF {1} SHARED VAR aux_dtmvtolt AS DATE                                NO-UNDO.

DEF {1} SHARED VAR aux_qtctremp AS INT                                 NO-UNDO.
DEF {1} SHARED VAR aux_vlsdeved AS DECIMAL                             NO-UNDO.
DEF {1} SHARED VAR aux_desconto AS DECIMAL FORMAT "zz,zzz,zz9.99"      NO-UNDO.
DEF {1} SHARED VAR aux_desctitu AS DECIMAL FORMAT "zz,zzz,zz9.99"      NO-UNDO.
DEF {1} SHARED VAR aux_vlpreemp AS DECIMAL                             NO-UNDO.

DEF {1} SHARED VAR aux_nmmesano AS CHAR    FORMAT "x(9)" EXTENT 12
                               INIT ["  JANEIRO","FEVEREIRO","    MARCO",
                                     "    ABRIL","     MAIO","    JUNHO",
                                     "    JULHO","   AGOSTO"," SETEMBRO",
                                     "  OUTUBRO"," NOVEMBRO"," DEZEMBRO"]
                                                                   NO-UNDO.

DEF {1} SHARED VAR aux_nmresage AS CHAR    EXTENT 999                  NO-UNDO.

DEF {1} SHARED VAR aux_contador AS INT     FORMAT "zz9"                NO-UNDO.
DEF {1} SHARED VAR aux_nmformul AS CHAR    FORMAT "x(05)"              NO-UNDO.
DEF {1} SHARED VAR aux_dsdtraco AS CHAR                                NO-UNDO.
DEF {1} SHARED VAR aux_dstraco2 AS CHAR                                NO-UNDO.

DEF {1} SHARED VAR aux_flgfirst AS LOGICAL                             NO-UNDO.
DEF {1} SHARED VAR aux_flgnvpag AS LOGICAL                             NO-UNDO.
DEF {1} SHARED VAR aux_flgexepr AS LOGICAL                             NO-UNDO.
DEF {1} SHARED VAR aux_regexist AS LOGICAL                             NO-UNDO.

/* .......................................................................... */
