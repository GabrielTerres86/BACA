/* ..........................................................................

   Programa: Includes/var_crps120.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Junho/95.                          Ultima atualizacao: 23/05/2016

   Dados referentes ao programa:

   Frequencia: Diario (Batch).
   Objetivo  : Criar as variaveis e form do programa CRPS120.

   Alteracoes: 07/08/96 - Alterado para tratar varios convenios de dentistas
                          (Edson).

               21/02/97 - Tratar convenio saude Bradesco (Odair).

               21/05/97 - Alterado para tratar demais convenios (Edson).

               22/10/97 - Tratar demais convenios f_aviso (Odair)

               13/11/97 - Criar variavel de historicos convenios 18 e 19 (Odair)

               27/04/98 - Tratamento para milenio e troca para V8 (Margarete).

               30/10/00 - Alterar nrdolote p/6 posicoes (Margarete/Planner).
               
               11/12/2006 - Verificar se eh Conta Salario - crapccs (Ze).

               21/02/2008 - Alterado turno no frame f_aviso a partir da
                            crapttl (Gabriel).
                            
               29/10/2008 - Alteracao CDEMPRES (Diego).
               
               01/10/2013 - Renomeado "aux_nmarqimp EXTENT" para "aux_nmarquiv", pois
                            aux_nmarqimp eh usado na impressao.i (Carlos)
                            
               29/10/2013 - Incluida var aux_flarqden para saber se copia o 
                            rel crrl114 para o dir rlnsv no crps120.p (Carlos)

               23/05/2016 - Criacao da aux_dtexecde. (Jaison/Marcos - Supero)

............................................................................. */

DEF {1} SHARED STREAM str_1.  /*  Para relatorio de criticas da integracao  */
DEF {1} SHARED STREAM str_2.  /*  Para o arquivo de entrada da integracao  */
DEF {1} SHARED STREAM str_3.  /*  Para o relatorio de estouros  */
DEF {1} SHARED STREAM str_4.  /*  Para o relatorio de estouros dentista  */

DEF {1} SHARED VAR rel_nmresemp     AS CHAR    FORMAT "x(15)"          NO-UNDO.
DEF {1} SHARED VAR rel_nmrelato     AS CHAR    FORMAT "x(40)" EXTENT 5 NO-UNDO.

DEF {1} SHARED VAR rel_cdagenci     AS INT                            NO-UNDO.
DEF {1} SHARED VAR rel_dsagenci     AS CHAR    EXTENT 1000            NO-UNDO.
DEF {1} SHARED VAR rel_dsintegr     AS CHAR                           NO-UNDO.
DEF {1} SHARED VAR rel_dshistor     AS CHAR                           NO-UNDO.
DEF {1} SHARED VAR rel_dscritic     AS CHAR                           NO-UNDO.
DEF {1} SHARED VAR rel_dsconven     AS CHAR                           NO-UNDO.
DEF {1} SHARED VAR rel_dsempres     AS CHAR                           NO-UNDO.
DEF {1} SHARED VAR rel_nmempres     AS CHAR                           NO-UNDO.
DEF {1} SHARED VAR rel_qtdifeln     AS INT                            NO-UNDO.

DEF {1} SHARED VAR rel_qttarifa     AS INT                            NO-UNDO.

DEF {1} SHARED VAR rel_vldifedb     AS DECIMAL                        NO-UNDO.
DEF {1} SHARED VAR rel_vldifecr     AS DECIMAL                        NO-UNDO.
DEF {1} SHARED VAR rel_vlestdif     AS DECIMAL                        NO-UNDO.

DEF {1} SHARED VAR tot_qtinfoln     AS INT                            NO-UNDO.
DEF {1} SHARED VAR tot_vlinfodb     AS DECIMAL                        NO-UNDO.
DEF {1} SHARED VAR tot_vlinfocr     AS DECIMAL                        NO-UNDO.
DEF {1} SHARED VAR tot_qtcompln     AS INT                            NO-UNDO.
DEF {1} SHARED VAR tot_vlcompdb     AS DECIMAL                        NO-UNDO.
DEF {1} SHARED VAR tot_vlcompcr     AS DECIMAL                        NO-UNDO.
DEF {1} SHARED VAR tot_qtdifeln     AS INT                            NO-UNDO.
DEF {1} SHARED VAR tot_vldifedb     AS DECIMAL                        NO-UNDO.
DEF {1} SHARED VAR tot_vldifecr     AS DECIMAL                        NO-UNDO.

DEF {1} SHARED VAR aux_flfirst2     AS LOGICAL                        NO-UNDO.
DEF {1} SHARED VAR aux_flgctsal     AS LOGICAL                        NO-UNDO.
DEF {1} SHARED VAR aux_nrdocmt2     AS INT                            NO-UNDO.
DEF {1} SHARED VAR aux_nrlotccs     AS INT                            NO-UNDO.

DEF {1} SHARED VAR rel_vltarifa     AS DECIMAL                        NO-UNDO.
DEF {1} SHARED VAR rel_vlcobrar     AS DECIMAL                        NO-UNDO.

DEF {1} SHARED VAR rel_nrmodulo AS INT     FORMAT "9"                 NO-UNDO.
DEF {1} SHARED VAR rel_nmmodulo AS CHAR    FORMAT "x(15)" EXTENT 5
                               INIT ["DEP. A VISTA   ","CAPITAL        ",
                                     "EMPRESTIMOS    ","DIGITACAO      ",
                                     "GENERICO       "]              NO-UNDO.

DEF {1} SHARED VAR tab_inusatab AS LOGICAL                            NO-UNDO.

DEF {1} SHARED VAR tot_vlsalliq AS DECIMAL                            NO-UNDO.
DEF {1} SHARED VAR tot_vldebsau AS DECIMAL                            NO-UNDO.
DEF {1} SHARED VAR tot_vldebemp AS DECIMAL                            NO-UNDO.
DEF {1} SHARED VAR tot_vldebcot AS DECIMAL                            NO-UNDO.
DEF {1} SHARED VAR tot_vldebden AS DECIMAL EXTENT 999                 NO-UNDO.
DEF {1} SHARED VAR tot_vldebcta AS DECIMAL EXTENT 999                 NO-UNDO.
DEF {1} SHARED VAR tot_vlhstsau AS DECIMAL EXTENT 999                 NO-UNDO.

DEF {1} SHARED VAR tot_qtestcot AS INT     EXTENT 999                 NO-UNDO.
DEF {1} SHARED VAR tot_qtestemp AS INT     EXTENT 999                 NO-UNDO.
DEF {1} SHARED VAR tot_qtestden AS INT     EXTENT 999                 NO-UNDO.

DEF {1} SHARED VAR tot_vlestcot AS DECIMAL EXTENT 999                 NO-UNDO.
DEF {1} SHARED VAR tot_vlestemp AS DECIMAL EXTENT 999                 NO-UNDO.
DEF {1} SHARED VAR tot_vlestden AS DECIMAL EXTENT 999                 NO-UNDO.

DEF {1} SHARED VAR ger_qtestcot AS INT                                NO-UNDO.
DEF {1} SHARED VAR ger_qtestemp AS INT                                NO-UNDO.
DEF {1} SHARED VAR ger_qtestden AS INT                                NO-UNDO.
DEF {1} SHARED VAR ger_qtavsden AS INT                                NO-UNDO.
DEF {1} SHARED VAR ger_qtdebden AS INT                                NO-UNDO.
DEF {1} SHARED VAR ger_qtestsau AS INT                                NO-UNDO.

DEF {1} SHARED VAR ger_vlestcot AS DECIMAL                            NO-UNDO.
DEF {1} SHARED VAR ger_vlestemp AS DECIMAL                            NO-UNDO.
DEF {1} SHARED VAR ger_vlestden AS DECIMAL                            NO-UNDO.
DEF {1} SHARED VAR ger_vlestsau AS DECIMAL                            NO-UNDO.

DEF {1} SHARED VAR ger_vlantcot AS DECIMAL                            NO-UNDO.
DEF {1} SHARED VAR ger_vlantemp AS DECIMAL                            NO-UNDO.
DEF {1} SHARED VAR ger_vlantden AS DECIMAL                            NO-UNDO.

DEF {1} SHARED VAR ger_vlavsemp AS DECIMAL                            NO-UNDO.
DEF {1} SHARED VAR ger_vlavscot AS DECIMAL                            NO-UNDO.
DEF {1} SHARED VAR ger_vlavsden AS DECIMAL                            NO-UNDO.

DEF {1} SHARED VAR ger_vldebemp AS DECIMAL                            NO-UNDO.
DEF {1} SHARED VAR ger_vldebcot AS DECIMAL                            NO-UNDO.
DEF {1} SHARED VAR ger_vldebden AS DECIMAL                            NO-UNDO.

DEF {1} SHARED VAR ass_vlestemp AS DECIMAL                            NO-UNDO.
DEF {1} SHARED VAR ass_vlestcot AS DECIMAL                            NO-UNDO.
DEF {1} SHARED VAR ass_vlestden AS DECIMAL                            NO-UNDO.
DEF {1} SHARED VAR ass_vlestdif AS DECIMAL                            NO-UNDO.

DEF {1} SHARED VAR avs_vlestdif AS DECIMAL                            NO-UNDO.

DEF {1} SHARED VAR ant_nrdconta AS INT                                NO-UNDO.

DEF {1} SHARED VAR aux_nmarqint AS CHAR    FORMAT "x(50)"             NO-UNDO.
DEF {1} SHARED VAR aux_dsintegr AS CHAR                               NO-UNDO.
DEF {1} SHARED VAR aux_nrseqsol AS CHAR                               NO-UNDO.
DEF {1} SHARED VAR aux_lshstden AS CHAR                               NO-UNDO.
DEF {1} SHARED VAR aux_lshstsau AS CHAR                               NO-UNDO.
DEF {1} SHARED VAR aux_lshstdiv AS CHAR                               NO-UNDO.
DEF {1} SHARED VAR aux_lshstfun AS CHAR                               NO-UNDO.

DEF {1} SHARED VAR aux_dshstden AS CHAR                   EXTENT 999  NO-UNDO.

DEF {1} SHARED VAR aux_nmarquiv AS CHAR    FORMAT "x(20)" EXTENT 99   NO-UNDO.
DEF            VAR aux_nmarqimp AS CHAR                               NO-UNDO.

DEF {1} SHARED VAR aux_nmarqest AS CHAR    FORMAT "x(20)" EXTENT 99   NO-UNDO.
DEF {1} SHARED VAR aux_nmarqden AS CHAR    FORMAT "x(20)" EXTENT 99   NO-UNDO.
DEF {1} SHARED VAR aux_nrdevias AS INT     FORMAT "z9"    EXTENT 99   NO-UNDO.

DEF {1} SHARED VAR aux_qtdifeln AS INT                                NO-UNDO.
DEF {1} SHARED VAR aux_vldifedb AS DECIMAL                            NO-UNDO.
DEF {1} SHARED VAR aux_vldifecr AS DECIMAL                            NO-UNDO.
DEF {1} SHARED VAR aux_vldoipmf AS DECIMAL                            NO-UNDO.

DEF {1} SHARED VAR aux_regexist AS LOGICAL                            NO-UNDO.
DEF {1} SHARED VAR aux_flgfirst AS LOGICAL                            NO-UNDO.
DEF {1} SHARED VAR aux_flgclote AS LOGICAL                            NO-UNDO.
DEF {1} SHARED VAR aux_flglotes AS LOGICAL                            NO-UNDO.
DEF {1} SHARED VAR aux_flgestou AS LOGICAL                            NO-UNDO.
DEF {1} SHARED VAR aux_flgentra AS LOGICAL                            NO-UNDO.
DEF {1} SHARED VAR aux_flgatual AS LOGICAL                            NO-UNDO.
DEF {1} SHARED VAR aux_flgceval AS LOGICAL                            NO-UNDO.
DEF {1} SHARED VAR aux_flgsomar AS LOGICAL                            NO-UNDO.
DEF {1} SHARED VAR aux_flgsaude AS LOGICAL                            NO-UNDO.

DEF {1} SHARED VAR est_flgsomar AS LOGICAL                            NO-UNDO.
DEF {1} SHARED VAR est_flgfirst AS LOGICAL                            NO-UNDO.
DEF {1} SHARED VAR est_regexist AS LOGICAL                            NO-UNDO.


DEF {1} SHARED VAR aux_dtintegr AS DATE                               NO-UNDO.
DEF {1} SHARED VAR aux_dtrefere AS DATE FORMAT "99/99/9999"           NO-UNDO.
DEF {1} SHARED VAR aux_dtmvtolt AS DATE                               NO-UNDO.
DEF {1} SHARED VAR aux_dtsegdeb AS DATE                               NO-UNDO.
DEF {1} SHARED VAR aux_dtexecde AS DATE                               NO-UNDO.

DEF {1} SHARED VAR aux_contaarq AS INT                                NO-UNDO.
DEF {1} SHARED VAR aux_contador AS INT                                NO-UNDO.
DEF {1} SHARED VAR aux_cdagenci AS INT     INIT 1                     NO-UNDO.
DEF {1} SHARED VAR aux_cdbccxlt AS INT     INIT 100                   NO-UNDO.
DEF {1} SHARED VAR aux_nrdolote AS INT                                NO-UNDO.
DEF {1} SHARED VAR aux_nrdocmto AS INT                                NO-UNDO.

DEF {1} SHARED VAR aux_nrlotfol AS INT                                NO-UNDO.
DEF {1} SHARED VAR aux_nrlotemp AS INT                                NO-UNDO.
DEF {1} SHARED VAR aux_nrlotcot AS INT                                NO-UNDO.
DEF {1} SHARED VAR aux_indmarca AS INT                                NO-UNDO.

DEF {1} SHARED VAR aux_tpregist AS INT     FORMAT "9"                 NO-UNDO.
DEF {1} SHARED VAR aux_tpdebito AS INT     FORMAT "9"                 NO-UNDO.
DEF {1} SHARED VAR aux_nrdconta AS INT     FORMAT "999999999"         NO-UNDO.
DEF {1} SHARED VAR aux_cdhistor AS INT     FORMAT "9999"              NO-UNDO.
DEF {1} SHARED VAR aux_cdempres AS INT     FORMAT "99999"             NO-UNDO.
DEF {1} SHARED VAR aux_nrseqint AS INT     FORMAT "999999"            NO-UNDO.
DEF {1} SHARED VAR aux_dtmvtoin AS DATE    FORMAT "99/99/9999"        NO-UNDO.
DEF {1} SHARED VAR aux_vldaurvs AS DECIMAL FORMAT "99999.99"          NO-UNDO.
DEF {1} SHARED VAR aux_vllanmto AS DECIMAL FORMAT "99999999999.99-"   NO-UNDO.

DEF {1} SHARED VAR aux_nrdoclot AS CHAR                               NO-UNDO.

DEF {1} SHARED VAR aux_cdempsol AS INT                                NO-UNDO.
DEF {1} SHARED VAR aux_cdempfol AS INT                                NO-UNDO.

/* arqden existe (crps120_e.p) */
DEF {1} SHARED VAR aux_flarqden AS LOGICAL                            NO-UNDO.

DEF {1} SHARED FRAME f_integracao.
DEF {1} SHARED FRAME f_rejeitados.
DEF {1} SHARED FRAME f_totais.
DEF {1} SHARED FRAME f_agencia.
DEF {1} SHARED FRAME f_label_aviso.
DEF {1} SHARED FRAME f_label_total.
DEF {1} SHARED FRAME f_aviso.
DEF {1} SHARED FRAME f_total_ass.
DEF {1} SHARED FRAME f_total_age.
DEF {1} SHARED FRAME f_total_ger.
DEF {1} SHARED FRAME f_total.

FORM rel_dsintegr     AT  1 FORMAT "x(70)"    LABEL "TIPO"
     SKIP(1)
     rel_dsempres     AT  1 FORMAT "x(30)"    LABEL "EMPRESA"
     SKIP(1)
     craplot.dtmvtolt AT  1 FORMAT "99/99/9999" LABEL "DATA"
     craplot.cdagenci AT 18 FORMAT "zz9"        LABEL "AGENCIA"
     craplot.cdbccxlt AT 33 FORMAT "zz9"        LABEL "BANCO/CAIXA"
     craplot.nrdolote AT 52 FORMAT "zzz,zz9"    LABEL "LOTE"
     craplot.tplotmov AT 66 FORMAT "99"         LABEL "TIPO"
     SKIP(1)
     WITH NO-BOX SIDE-LABELS NO-LABELS WIDTH 80 FRAME f_integracao.

FORM craprej.nrdconta AT  1 FORMAT "zzzz,zzz,9"          LABEL "CONTA/DV"
     craprej.cdhistor AT 14 FORMAT "zzz9"                LABEL "HST"
     craprej.vllanmto AT 19 FORMAT "zzz,zzz,zzz,zzz.99-" LABEL "VALOR "
     glb_dscritic     AT 40 FORMAT "x(40)"               LABEL "CRITICA"
     WITH NO-BOX DOWN NO-LABELS WIDTH 80 FRAME f_rejeitados.

FORM SKIP(1)
     "QTD               DEBITO               CREDITO" AT 26
     SKIP
     "A INTEGRAR: "     AT  9
     craplot.qtinfoln   AT 22 FORMAT "zzz,zz9-"
     craplot.vlinfodb   AT 32 FORMAT "zzz,zzz,zzz,zz9.99-"
     craplot.vlinfocr   AT 54 FORMAT "zzz,zzz,zzz,zz9.99-"
     SKIP
     "INTEGRADOS: "     AT  9
     craplot.qtcompln   AT 22 FORMAT "zzz,zz9-"
     craplot.vlcompdb   AT 32 FORMAT "zzz,zzz,zzz,zz9.99-"
     craplot.vlcompcr   AT 54 FORMAT "zzz,zzz,zzz,zz9.99-"
     SKIP(1)
     "REJEITADOS: "     AT  9
     rel_qtdifeln       AT 22 FORMAT "zzz,zz9-"
     rel_vldifedb       AT 32 FORMAT "zzz,zzz,zzz,zz9.99-"
     rel_vldifecr       AT 54 FORMAT "zzz,zzz,zzz,zz9.99-"
     WITH NO-BOX NO-LABELS WIDTH 80 FRAME f_totais.

FORM SKIP(1)
     "TARIFAS:"         AT 12
     "QTD         VALOR TARIFA        VALOR A COBRAR" AT 26
     SKIP
     rel_qttarifa       AT 22 FORMAT "zzz,zz9"
     rel_vltarifa       AT 32 FORMAT "zzz,zzz,zzz,zz9.99"
     rel_vlcobrar       AT 54 FORMAT "zzz,zzz,zzz,zz9.99"
     WITH NO-BOX NO-LABELS WIDTH 80 FRAME f_tarifa.

FORM rel_dsagenci[rel_cdagenci] AT   1 FORMAT "x(25)" LABEL "AGENCIA"
     rel_dsconven               AT  53 FORMAT "x(40)" NO-LABEL
     SKIP(1)
     rel_dsempres               AT   1 FORMAT "x(25)" LABEL "EMPRESA"
     aux_dtrefere               AT  53 FORMAT "99/99/9999"
                                       LABEL "DATA DE REFERENCIA"
     SKIP(1)
     WITH NO-BOX SIDE-LABELS WIDTH 132 FRAME f_agencia.

FORM "PAC   CONTA/DV RAM. TU NOME"                          AT   1
     "HISTORICO        DOCMTO SEQ. VALOR AVISO  VLR DEBITO" AT  54
     "ESTOURO/DIF.  CRITICA"
     SKIP(1)
     WITH NO-BOX NO-LABELS WIDTH 132 FRAME f_label_aviso.

FORM crapass.cdagenci AT   1 FORMAT "zz9"
     crapavs.nrdconta AT   5 FORMAT "zzzz,zzz,9"
     crapass.nrramemp AT  16 FORMAT "zzz9"
     crapttl.cdturnos AT  21 FORMAT "zz"
     crapass.nmprimtl AT  24 FORMAT "x(29)" 
     rel_dshistor     AT  54 FORMAT "x(13)"
     crapavs.nrdocmto AT  68 FORMAT "z,zzz,zz9"
     crapavs.nrseqdig AT  78 FORMAT "zzz9"
     crapavs.vllanmto AT  83 FORMAT "zzzz,zz9.99"
     crapavs.vldebito AT  95 FORMAT "zzzz,zz9.99"
     rel_vlestdif     AT 107 FORMAT "zzzz,zz9.99"
     rel_dscritic     AT 121 FORMAT "x(12)"
     WITH NO-BOX NO-LABELS WIDTH 132 FRAME f_aviso.

FORM "-------------" AT 107
     SKIP
     ass_vlestdif    AT 107 FORMAT "zzzzzz,zz9.99"
     SKIP(1)
     WITH NO-BOX NO-LABELS WIDTH 132 FRAME f_total_ass.

FORM SKIP(1)
     tot_qtestcot[rel_cdagenci] AT  21 FORMAT "zzz,zz9"
                                       LABEL "CONTAS COM ESTOURO COTAS"
     tot_vlestcot[rel_cdagenci] AT  81 FORMAT "zzzzzz,zz9.99"
                                       LABEL "TOTAL DO ESTOURO COTAS"
     SKIP
     tot_qtestemp[rel_cdagenci] AT  16 FORMAT "zzz,zz9"
                                       LABEL "CONTAS COM ESTOURO EMPRESTIMO"
     tot_vlestemp[rel_cdagenci] AT  76 FORMAT "zzzzzz,zz9.99"
                                       LABEL "TOTAL DO ESTOURO EMPRESTIMO"
     WITH NO-BOX SIDE-LABELS WIDTH 132 FRAME f_total_age.

FORM SKIP(1)
     tot_qtestden[rel_cdagenci] AT  17 FORMAT "zzz,zz9"
                                       LABEL "CONTAS COM ESTOURO CONVENIO"
     tot_vlestden[rel_cdagenci] AT  77 FORMAT "zzzzzz,zz9.99"
                                       LABEL "TOTAL DO ESTOURO CONVENIO"
     WITH NO-BOX SIDE-LABELS WIDTH 132 FRAME f_total_age_den.

FORM "AGENCIA"            AT   1
     "ESTOURO COTAS"      AT  38
     "ESTOURO EMPRESTIMO" AT  63
     SKIP(1)
     WITH NO-BOX WIDTH 132 FRAME f_label_total.

FORM "AGENCIA"            AT   1
     "ESTOURO CONVENIO"  AT  34
     SKIP(1)
     WITH NO-BOX WIDTH 132 FRAME f_label_total_den.

FORM rel_dsagenci[rel_cdagenci] AT   1 FORMAT "x(25)"
     tot_qtestcot[rel_cdagenci] AT  28 FORMAT "zzz,zz9"
     tot_vlestcot[rel_cdagenci] AT  37 FORMAT "zzz,zzz,zz9.99"
     tot_qtestemp[rel_cdagenci] AT  58 FORMAT "zzz,zz9"
     tot_vlestemp[rel_cdagenci] AT  67 FORMAT "zzz,zzz,zz9.99"
     WITH NO-BOX NO-LABELS WIDTH 132 FRAME f_total_ger.

FORM rel_dsagenci[rel_cdagenci] AT   1 FORMAT "x(25)"
     tot_qtestden[rel_cdagenci] AT  28 FORMAT "zzz,zz9"
     tot_vlestden[rel_cdagenci] AT  37 FORMAT "zzz,zzz,zz9.99"
     WITH NO-BOX NO-LABELS WIDTH 132 FRAME f_total_ger_den.

FORM "-------  --------------       -------  --------------" AT 28
     SKIP
     ger_qtestcot AT  28 FORMAT "zzz,zz9"        NO-LABEL
     ger_vlestcot AT  37 FORMAT "zzz,zzz,zz9.99" NO-LABEL
     ger_qtestemp AT  58 FORMAT "zzz,zz9"        NO-LABEL
     ger_vlestemp AT  67 FORMAT "zzz,zzz,zz9.99" NO-LABEL
     SKIP(1)
     ger_vlavscot AT  28 FORMAT "zzz,zzz,zz9.99" LABEL "AVISADO"
     ger_vlavsemp AT  58 FORMAT "zzz,zzz,zz9.99" LABEL "AVISADO"
     SKIP
     ger_vldebcot AT  27 FORMAT "zzz,zzz,zz9.99" LABEL "DEBITADO"
     ger_vldebemp AT  57 FORMAT "zzz,zzz,zz9.99" LABEL "DEBITADO"
     SKIP
     ger_vlantcot AT  25 FORMAT "zzz,zzz,zz9.99-" LABEL "ABATIMENTO"
     ger_vlantemp AT  55 FORMAT "zzz,zzz,zz9.99-" LABEL "ABATIMENTO"
     WITH NO-BOX SIDE-LABELS WIDTH 132 FRAME f_total.

FORM "-------  --------------" AT 28
     SKIP
     ger_qtestden AT  28 FORMAT "zzz,zz9"        NO-LABEL
     ger_vlestden AT  37 FORMAT "zzz,zzz,zz9.99" NO-LABEL
     SKIP(1)
     ger_qtavsden AT  19 FORMAT "zzz,zz9" LABEL "AVISADO"
     ger_vlavsden AT  37 FORMAT "zzz,zzz,zz9.99" NO-LABEL
     SKIP
     ger_qtdebden AT  18 FORMAT "zzz,zz9" LABEL "DEBITADO"
     ger_vldebden AT  37 FORMAT "zzz,zzz,zz9.99" NO-LABEL
     WITH NO-BOX SIDE-LABELS WIDTH 132 FRAME f_total_den.

/* .......................................................................... */
