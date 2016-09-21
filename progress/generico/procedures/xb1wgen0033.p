/*.............................................................................

   Programa: xb1wgen0033.p
   Autor   : Guilherme
   Data    : Agosto/2008                     Ultima atualizacao: 18/12/2015

   Dados referentes ao programa:

   Objetivo  : BO de Comunicacao XML VS BO de Seguros (b1wgen0033.p)

   Alteracoes: 31/08/2011 - Inclusao de procedures incluir_garantias,
                            alterar_garantias, excluir_garantias,
                            gerar_atualizacao_seg, buscar_associados,
                            buscar_coberturas_plano, desfaz_canc_seguro,
                            cancelar_seguro, buscar_motivo_can,
                            atualizar_seguro, buscar_tip_seguro,
                            valida_inc_seguro, buscar_cooperativa,
                            buscar_empresa. Alteradas procedures
                            busca_seguros, buscar_proposta_seguro,
                            buscar_seguradora (Gati - Oliver)

               16/12/2011 - Incluido a passagem do parametro aux_dtnascsg 
                            nas procedures:
                            - validar_criacao
                            - cria_seguro
                            (Adriano).
                            
               01/03/2012 - Alterado o parametro de log para FALSE nas 
                            procedures:
                            - cria_seguros
                            - buscar_seguros
                            - validar_criacao
                            - buscar_propostas_seguro
                            - imprimir_termo_cancelamento
                            - cancelar_seguro
                            - buscar_tip_seguro
                            - valida_inc_seguro
                            - buscar_seguradora
                            - buscar_plano_seguro
                            - imprimir_proposta_seguro
                            - buscar_seguro_geral
                            - buscar_end_coo
                            - atualizar_seguro
                            - imprimir_alt_seg_vida
                            - buscar_motivo_can
                            - buscar_associados
                            - validar_inclusao_vida
                            (Adriano).             
               
               12/11/2012 - Alteracao de parametros de log (David Kruger).  
               
               27/02/2013 - Incluir aux_flgsegur em procedure cria_seguro e 
                            incluir aux_cddopcao em procedure imprimir_alt_seg_vida
                            (Lucas R.)
               
               25/07/2013 - Incluido o parametro de entrada "complend" na 
                            procedure "cria_seguro". (James)
                            
               02/10/2013 - Realizada inclusão das procedures pi_atualizar_perc_seg
                                                              pi_atualizar_valor_seg
                                                              
               18/12/2015 - Ajuste para liberacao da conversao Web da tela
                            ALTSEG
                            (Adriano).
..............................................................................*/

DEF VAR aux_cdcooper AS INTE                                           NO-UNDO.
DEF VAR aux_reccraws AS CHAR                                           NO-UNDO.
DEF VAR aux_cdagenci AS INTE                                           NO-UNDO.
DEF VAR aux_nrdcaixa AS INTE                                           NO-UNDO.
DEF VAR aux_cdoperad AS CHAR                                           NO-UNDO.
DEF VAR aux_nmdatela AS CHAR                                           NO-UNDO.
DEF VAR aux_idorigem AS INTE                                           NO-UNDO.
DEF VAR aux_dspesseg AS CHAR                                           NO-UNDO.
DEF VAR aux_dtultdia AS DATE                                           NO-UNDO.
DEF VAR aux_nmdcampo AS CHAR                                           NO-UNDO.
DEF VAR aux_nrpagina AS INTE                                           NO-UNDO.
DEF VAR aux_cdsitdct AS INTE                                           NO-UNDO.
DEF VAR aux_vlmorada LIKE craptsg.vlmorada                             NO-UNDO.
DEF VAR aux_vlplaseg LIKE craptsg.vlplaseg                             NO-UNDO.
DEF VAR aux_tpmesano AS CHAR                                           NO-UNDO.
DEF VAR aux_qtmesano AS INTE                                           NO-UNDO.
DEF VAR aux_cdsexosg AS INTE                                           NO-UNDO.
DEF VAR aux_dtnascsg AS DATE                                           NO-UNDO.
DEF VAR aux_dtcalcul AS DATE                                           NO-UNDO.
DEF VAR aux_dsendres LIKE crawseg.dsendres                             NO-UNDO.
DEF VAR aux_nrendres LIKE crawseg.nrendres                             NO-UNDO.
DEF VAR aux_complend LIKE crawseg.complend                             NO-UNDO.
DEF VAR aux_nmbairro LIKE crawseg.nmbairro                             NO-UNDO.
DEF VAR aux_nmcidade LIKE crawseg.nmcidade                             NO-UNDO.
DEF VAR aux_cdufresd LIKE crawseg.cdufresd                             NO-UNDO.
DEF VAR aux_nrcepend LIKE crawseg.nrcepend                             NO-UNDO.
DEF VAR aux_vlseguro LIKE crawseg.vlseguro                             NO-UNDO.
DEF VAR aux_cdcalcul LIKE crawseg.cdcalcul                             NO-UNDO.
DEF VAR aux_nmrotina AS CHAR                                           NO-UNDO.
DEF VAR aux_nmdsegur LIKE crawseg.nmdsegur                             NO-UNDO.
DEF VAR aux_vltotpre LIKE crapseg.vlpremio                             NO-UNDO.
DEF VAR aux_nrdconta AS INTE                                           NO-UNDO.
DEF VAR aux_rec_crawseg AS RECID                                       NO-UNDO.
DEF VAR aux_vlcapseg LIKE craptsg.vlmorada                             NO-UNDO.
DEF VAR aux_nrcpfcgc LIKE crawseg.nrcpfcgc                             NO-UNDO.
DEF VAR aux_dsgraupr1 AS CHAR FORMAT "x(20)"                           NO-UNDO.
DEF VAR aux_dsgraupr2 AS CHAR FORMAT "x(20)"                           NO-UNDO.
DEF VAR aux_dsgraupr3 AS CHAR FORMAT "x(20)"                           NO-UNDO.
DEF VAR aux_dsgraupr4 AS CHAR FORMAT "x(20)"                           NO-UNDO.
DEF VAR aux_dsgraupr5 AS CHAR FORMAT "x(20)"                           NO-UNDO.
DEF VAR aux_nmbenvid1 AS CHAR FORMAT "x(40)"                           NO-UNDO.
DEF VAR aux_nmbenvid2 AS CHAR FORMAT "x(40)"                           NO-UNDO.
DEF VAR aux_nmbenvid3 AS CHAR FORMAT "x(40)"                           NO-UNDO.
DEF VAR aux_nmbenvid4 AS CHAR FORMAT "x(40)"                           NO-UNDO.
DEF VAR aux_nmbenvid5 AS CHAR FORMAT "x(40)"                           NO-UNDO.
DEF VAR aux_txpartic1 AS DECIMAL FORMAT ">>9.99"                       NO-UNDO.
DEF VAR aux_txpartic2 AS DECIMAL FORMAT ">>9.99"                       NO-UNDO.
DEF VAR aux_txpartic3 AS DECIMAL FORMAT ">>9.99"                       NO-UNDO.
DEF VAR aux_txpartic4 AS DECIMAL FORMAT ">>9.99"                       NO-UNDO.
DEF VAR aux_txpartic5 AS DECIMAL FORMAT ">>9.99"                       NO-UNDO.
DEF VAR aux_dstipseg AS CHAR                                           NO-UNDO.
DEF VAR aux_idseqttl AS INTE                                           NO-UNDO.
DEF VAR aux_qtsegass AS INTE                                           NO-UNDO.
DEF VAR aux_vltotseg AS DECI                                           NO-UNDO.
DEF VAR aux_nrctrseg LIKE crapseg.nrctrseg                             NO-UNDO.
DEF VAR aux_dtinivig LIKE crapseg.dtinivig                             NO-UNDO.
DEF VAR aux_dtfimvig LIKE crapseg.dtfimvig                             NO-UNDO.
DEF VAR aux_cdbccxlt LIKE crapseg.cdbccxlt                             NO-UNDO.
DEF VAR aux_cdsitseg LIKE crapseg.cdsitseg                             NO-UNDO.
DEF VAR aux_dtaltseg LIKE crapseg.dtaltseg                             NO-UNDO.
DEF VAR aux_dtcancel LIKE crapseg.dtcancel                             NO-UNDO.
DEF VAR aux_dtdebito LIKE crapseg.dtdebito                             NO-UNDO.
DEF VAR aux_dtiniseg LIKE crapseg.dtiniseg                             NO-UNDO.
DEF VAR aux_indebito LIKE crapseg.indebito                             NO-UNDO.
DEF VAR aux_nrdolote LIKE crapseg.nrdolote                             NO-UNDO.
DEF VAR aux_nrseqdig LIKE crapseg.nrseqdig                             NO-UNDO.
DEF VAR aux_qtprepag LIKE crapseg.qtprepag                             NO-UNDO.
DEF VAR aux_vlprepag LIKE crapseg.vlprepag                             NO-UNDO.
DEF VAR aux_dtultpag LIKE crapseg.dtultpag                             NO-UNDO.
DEF VAR aux_tpseguro LIKE crapseg.tpseguro                             NO-UNDO.
DEF VAR aux_tpplaseg LIKE crapseg.tpplaseg                             NO-UNDO.
DEF VAR aux_qtprevig LIKE crapseg.qtprevig                             NO-UNDO.
DEF VAR aux_cdsegura LIKE crapseg.cdsegura                             NO-UNDO.
DEF VAR aux_lsctrant LIKE crapseg.lsctrant                             NO-UNDO.
DEF VAR aux_nrctratu LIKE crapseg.nrctratu                             NO-UNDO.
DEF VAR aux_flgunica LIKE crapseg.flgunica                             NO-UNDO.
DEF VAR aux_dtprideb LIKE crapseg.dtprideb                             NO-UNDO.
DEF VAR aux_vldifseg LIKE crapseg.vldifseg                             NO-UNDO.
DEF VAR aux_nmbenvid LIKE crapseg.nmbenvid                             NO-UNDO.
DEF VAR aux_dsgraupr LIKE crapseg.dsgraupr                             NO-UNDO.
DEF VAR aux_txpartic LIKE crapseg.txpartic                             NO-UNDO.
DEF VAR aux_dtultalt LIKE crapseg.dtultalt                             NO-UNDO.
DEF VAR aux_vlpremio LIKE crapseg.vlpremio                             NO-UNDO.
DEF VAR aux_qtparcel LIKE crapseg.qtparcel                             NO-UNDO.
DEF VAR aux_tpdpagto LIKE crapseg.tpdpagto                             NO-UNDO.
DEF VAR aux_flgconve LIKE crapseg.flgconve                             NO-UNDO.
DEF VAR aux_flgclabe LIKE crapseg.flgclabe                             NO-UNDO.
DEF VAR aux_cdmotcan LIKE crapseg.cdmotcan                             NO-UNDO.
DEF VAR aux_qtregist AS INTE                                           NO-UNDO.
DEF VAR aux_tpendcor LIKE crapseg.tpendcor                             NO-UNDO.
DEF VAR aux_inpessoa LIKE crapass.inpessoa                             NO-UNDO.
DEF VAR aux_dsgarant LIKE crapgsg.dsgarant                             NO-UNDO.
DEF VAR aux_vlgarant LIKE crapgsg.vlgarant                             NO-UNDO.
DEF VAR aux_dsfranqu LIKE crapgsg.dsfranqu                             NO-UNDO.
DEF VAR aux_nrseqinc LIKE crapgsg.nrseqinc                             NO-UNDO.
DEF VAR aux_nrtabela LIKE craptsg.nrtabela                             NO-UNDO.
DEF VAR aux_vlpercen AS DEC FORMAT "zzz,zz9.9999-"                     NO-UNDO.
DEF VAR aux_dtdespre AS DATE FORMAT "99/99/9999"                       NO-UNDO.
DEF VAR aux_cdsitpsg LIKE craptsg.cdsitpsg                             NO-UNDO.
DEF VAR aux_cdempres LIKE crapemp.cdempres                             NO-UNDO.
DEF VAR aux_nmendter AS CHAR FORMAT "x(20)"                            NO-UNDO.
DEF VAR aux_nmarqimp AS CHAR                                           NO-UNDO.
DEF VAR aux_nmarqpdf AS CHAR                                           NO-UNDO.
DEF VAR aux_dtferiad LIKE crapfer.dtferiad                             NO-UNDO.
DEF VAR aux_vlpreseg LIKE crapseg.vlpreseg                             NO-UNDO.
DEF VAR aux_dscobert LIKE craptsg.dsmorada                             NO-UNDO.
DEF VAR aux_nmsegura LIKE crapcsg.nmsegura                             NO-UNDO.
DEF VAR aux_dsmotcan AS CHAR                                           NO-UNDO.
DEF VAR aux_cddopcao AS CHAR                                           NO-UNDO.
DEF VAR aux_flgsegur AS LOG                                            NO-UNDO.
DEF VAR aux_dsmorada AS CHAR                                           NO-UNDO.
DEF VAR aux_ddcancel LIKE craptsg.ddcancel                             NO-UNDO.
DEF VAR aux_dddcorte LIKE craptsg.dddcorte                             NO-UNDO.
DEF VAR aux_ddmaxpag LIKE craptsg.ddmaxpag                             NO-UNDO.
DEF VAR aux_dsocupac LIKE craptsg.dsocupac                             NO-UNDO.
DEF VAR aux_inplaseg LIKE craptsg.inplaseg                             NO-UNDO.
DEF VAR aux_mmpripag LIKE craptsg.mmpripag                             NO-UNDO.
DEF VAR aux_qtdiacar LIKE craptsg.qtdiacar                             NO-UNDO.
DEF VAR aux_qtmaxpar LIKE craptsg.qtmaxpar                             NO-UNDO.
DEF VAR aux_dtpagmto AS DATE                                           NO-UNDO.  
DEF VAR aux_datdespr AS DATE                                           NO-UNDO.
DEF VAR aux_datdebit AS DATE                                           NO-UNDO.
DEF VAR aux_nrregist AS INT                                            NO-UNDO.
DEF VAR aux_nriniseq AS INT                                            NO-UNDO.

{ sistema/generico/includes/b1wgen0033tt.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/supermetodos.i }

/*................................ PROCEDURES ................................*/


/******************************************************************************/
/**      Procedure para atribuicao dos dados de entrada enviados por XML     **/
/******************************************************************************/
PROCEDURE valores_entrada:
    FOR EACH tt-param:

        CASE tt-param.nomeCampo:
            WHEN "nmsegura"    THEN aux_nmsegura    = tt-param.valorCampo. 
            WHEN "dsmotcan"    THEN aux_dsmotcan    = tt-param.valorCampo. 
            WHEN "cdcooper"    THEN aux_cdcooper    = INTE(tt-param.valorCampo).
            WHEN "cdagenci"    THEN aux_cdagenci    = INTE(tt-param.valorCampo).
            WHEN "nrdcaixa"    THEN aux_nrdcaixa    = INTE(tt-param.valorCampo).
            WHEN "cdoperad"    THEN aux_cdoperad    =      tt-param.valorCampo.
            WHEN "idorigem"    THEN aux_idorigem    = INTE(tt-param.valorCampo).
            WHEN "nmdatela"    THEN aux_nmdatela    =      tt-param.valorCampo.
            WHEN "nmrotina"    THEN aux_nmrotina    =      tt-param.valorCampo.
            WHEN "nrdconta"    THEN aux_nrdconta    = INTE(tt-param.valorCampo).
            WHEN "idseqttl"    THEN aux_idseqttl    = INTE(tt-param.valorCampo).
            WHEN "nrdconta"    THEN aux_nrdconta    = INTE(tt-param.valorCampo).
            WHEN "nrctrseg"    THEN aux_nrctrseg    = INTE(tt-param.valorCampo).
            WHEN "dtinivig"    THEN aux_dtinivig    = DATE(tt-param.valorCampo).
            WHEN "dtfimvig"    THEN aux_dtfimvig    = DATE(tt-param.valorCampo).
            WHEN "dtmvtolt"    THEN aux_dtmvtolt    = DATE(tt-param.valorCampo).
            WHEN "cdbccxlt"    THEN aux_cdbccxlt    = INTE(tt-param.valorCampo).
            WHEN "cdsitseg"    THEN aux_cdsitseg    = INTE(tt-param.valorCampo).
            WHEN "dtaltseg"    THEN aux_dtaltseg    = DATE(tt-param.valorCampo).
            WHEN "dtcancel"    THEN aux_dtcancel    = DATE(tt-param.valorCampo).
            WHEN "dtdebito"    THEN aux_dtdebito    = DATE(tt-param.valorCampo).
            WHEN "dtiniseg"    THEN aux_dtiniseg    = DATE(tt-param.valorCampo).
            WHEN "indebito"    THEN aux_indebito    = INTE(tt-param.valorCampo).
            WHEN "nrdolote"    THEN aux_nrdolote    = INTE(tt-param.valorCampo).
            WHEN "nrseqdig"    THEN aux_nrseqdig    = INTE(tt-param.valorCampo).
            WHEN "qtprepag"    THEN aux_qtprepag    = INTE(tt-param.valorCampo).
            WHEN "vlprepag"    THEN aux_vlprepag    =  DEC(tt-param.valorCampo).
            WHEN "dtultpag"    THEN aux_dtultpag    = DATE(tt-param.valorCampo).
            WHEN "tpseguro"    THEN aux_tpseguro    = INTE(tt-param.valorCampo).
            WHEN "tpplaseg"    THEN aux_tpplaseg    = INTE(tt-param.valorCampo).
            WHEN "qtprevig"    THEN aux_qtprevig    = INTE(tt-param.valorCampo).
            WHEN "cdsegura"    THEN aux_cdsegura    = INTE(tt-param.valorCampo).
            WHEN "lsctrant"    THEN aux_lsctrant    =      tt-param.valorCampo.
            WHEN "nrctratu"    THEN aux_nrctratu    = INTE(tt-param.valorCampo).
            WHEN "flgunica"    THEN aux_flgunica    =  LOGICAL(tt-param.valorCampo).
            WHEN "dtprideb"    THEN aux_dtprideb    = DATE(tt-param.valorCampo).
            WHEN "vldifseg"    THEN aux_vldifseg    =  DEC(tt-param.valorCampo).
            WHEN "dspesseg"    THEN aux_dspesseg    = tt-param.valorCampo.
            WHEN "nmbenvid[1]" THEN aux_nmbenvid[1] =      tt-param.valorCampo.
            WHEN "nmbenvid[2]" THEN aux_nmbenvid[2] =      tt-param.valorCampo.
            WHEN "nmbenvid[3]" THEN aux_nmbenvid[3] =      tt-param.valorCampo.
            WHEN "nmbenvid[4]" THEN aux_nmbenvid[4] =      tt-param.valorCampo.
            WHEN "nmbenvid[5]" THEN aux_nmbenvid[5] =      tt-param.valorCampo.
            WHEN "dsgraupr[1]" THEN aux_dsgraupr[1] =      tt-param.valorCampo.
            WHEN "dsgraupr[2]" THEN aux_dsgraupr[2] =      tt-param.valorCampo.
            WHEN "dsgraupr[3]" THEN aux_dsgraupr[3] =      tt-param.valorCampo.
            WHEN "dsgraupr[4]" THEN aux_dsgraupr[4] =      tt-param.valorCampo.
            WHEN "dsgraupr[5]" THEN aux_dsgraupr[5] =      tt-param.valorCampo.
            WHEN "txpartic[1]" THEN aux_txpartic[1] =  DEC(tt-param.valorCampo).
            WHEN "txpartic[2]" THEN aux_txpartic[2] =  DEC(tt-param.valorCampo).
            WHEN "txpartic[3]" THEN aux_txpartic[3] =  DEC(tt-param.valorCampo).
            WHEN "txpartic[4]" THEN aux_txpartic[4] =  DEC(tt-param.valorCampo).
            WHEN "txpartic[5]" THEN aux_txpartic[5] =  DEC(tt-param.valorCampo).
            WHEN "dtultalt"    THEN aux_dtultalt    = DATE(tt-param.valorCampo).
            WHEN "vlpremio"    THEN aux_vlpremio    =  DEC(tt-param.valorCampo).
            WHEN "qtparcel"    THEN aux_qtparcel    = INTE(tt-param.valorCampo).
            WHEN "tpdpagto"    THEN aux_tpdpagto    = INTE(tt-param.valorCampo).
            WHEN "flgconve"    THEN aux_flgconve    = LOGICAL(tt-param.valorCampo).
            WHEN "flgclabe"    THEN aux_flgclabe    = LOGICAL(tt-param.valorCampo).
            WHEN "cdmotcan"    THEN aux_cdmotcan    = INTE(tt-param.valorCampo).
            WHEN "qtregist"    THEN aux_qtregist    = INTE(tt-param.valorCampo).
            WHEN "tpendcor"    THEN aux_tpendcor    = INTE(tt-param.valorCampo).
            WHEN "inpessoa"    THEN aux_inpessoa    = INTE(tt-param.valorCampo).
            WHEN "dsgarant"    THEN aux_dsgarant    =      tt-param.valorCampo.
            WHEN "vlgarant"    THEN aux_vlgarant    =  DEC(tt-param.valorCampo).
            WHEN "dsfranqu"    THEN aux_dsfranqu    =      tt-param.valorCampo.
            WHEN "reccraws"    THEN aux_reccraws    = tt-param.valorCampo.
            WHEN "nrseqinc"    THEN aux_nrseqinc    = INTE(tt-param.valorCampo).
            WHEN "nrtabela"    THEN aux_nrtabela    = INTE(tt-param.valorCampo).
            WHEN "vlpercen"    THEN aux_vlpercen    =  DEC(tt-param.valorCampo).
            WHEN "dtdespre"    THEN aux_dtdespre    = DATE(tt-param.valorCampo).
            WHEN "cdsitpsg"    THEN aux_cdsitpsg    = INTE(tt-param.valorCampo).
            WHEN "cdempres"    THEN aux_cdempres    = INTE(tt-param.valorCampo).
            WHEN "nmendter"    THEN aux_nmendter    =      tt-param.valorCampo.
            WHEN "dtferiad"    THEN aux_dtferiad    = DATE(tt-param.valorCampo).
            WHEN "vlpreseg"    THEN aux_vlpreseg    =  DEC(tt-param.valorCampo).
            WHEN "dsgraupr1"   THEN aux_dsgraupr1   =      tt-param.valorCampo.
            WHEN "dsgraupr2"   THEN aux_dsgraupr2   =      tt-param.valorCampo.
            WHEN "dsgraupr3"   THEN aux_dsgraupr3   =      tt-param.valorCampo.
            WHEN "dsgraupr4"   THEN aux_dsgraupr4   =      tt-param.valorCampo.
            WHEN "dsgraupr5"   THEN aux_dsgraupr5   =      tt-param.valorCampo.
            WHEN "nmbenvid1"   THEN aux_nmbenvid1   =      tt-param.valorCampo.
            WHEN "nmbenvid2"   THEN aux_nmbenvid2   =      tt-param.valorCampo.
            WHEN "nmbenvid3"   THEN aux_nmbenvid3   =      tt-param.valorCampo.
            WHEN "nmbenvid4"   THEN aux_nmbenvid4   =      tt-param.valorCampo.
            WHEN "nmbenvid5"   THEN aux_nmbenvid5   =      tt-param.valorCampo.
            WHEN "txpartic1"   THEN aux_txpartic1   =  DEC(tt-param.valorCampo).
            WHEN "txpartic2"   THEN aux_txpartic2   =  DEC(tt-param.valorCampo).
            WHEN "txpartic3"   THEN aux_txpartic3   =  DEC(tt-param.valorCampo).
            WHEN "txpartic4"   THEN aux_txpartic4   =  DEC(tt-param.valorCampo).
            WHEN "txpartic5"   THEN aux_txpartic5   =  DEC(tt-param.valorCampo).
            WHEN "vlcapseg"    THEN aux_vlcapseg    =  DEC(tt-param.valorCampo).
            WHEN "nrcpfcgc"    THEN aux_nrcpfcgc    =      tt-param.valorCampo.
            WHEN "nmdsegur"    THEN aux_nmdsegur    =      tt-param.valorCampo.
            WHEN "vltotpre"    THEN aux_vltotpre    =  DEC(tt-param.valorCampo).
            WHEN "cdcalcul"    THEN aux_cdcalcul    = INTE(tt-param.valorCampo).
            WHEN "vlseguro"    THEN aux_vlseguro    =  DEC(tt-param.valorCampo).
            WHEN "dsendres"    THEN aux_dsendres    =      tt-param.valorCampo.
            WHEN "nrendres"    THEN aux_nrendres    = INTE(tt-param.valorCampo).
            WHEN "complend"    THEN aux_complend    =      tt-param.valorCampo.
            WHEN "nmbairro"    THEN aux_nmbairro    =      tt-param.valorCampo.
            WHEN "nmcidade"    THEN aux_nmcidade    =      tt-param.valorCampo.
            WHEN "cdufresd"    THEN aux_cdufresd    =      tt-param.valorCampo.
            WHEN "nrcepend"    THEN aux_nrcepend    = INTE(tt-param.valorCampo).
            WHEN "cdsitdct"    THEN aux_cdsitdct    = INTE(tt-param.valorCampo).
            WHEN "dtnascsg"    THEN aux_dtnascsg    = DATE(tt-param.valorCampo).
            WHEN "cdsexosg"    THEN aux_cdsexosg    = INTE(tt-param.valorCampo).
            WHEN "qtmesano"    THEN aux_qtmesano    = INTE(tt-param.valorCampo).
            WHEN "tpmesano"    THEN aux_tpmesano    =      tt-param.valorCampo.
            WHEN "vlplaseg"    THEN aux_vlplaseg    =  DEC(tt-param.valorCampo).
            WHEN "vlmorada"    THEN aux_vlmorada    =  DEC(tt-param.valorCampo).
            WHEN "nrpagina"    THEN aux_nrpagina    = INTE(tt-param.valorCampo).
            WHEN "dtultdia"    THEN aux_dtultdia    = DATE(tt-param.valorCampo).
            WHEN "cddopcao"    THEN aux_cddopcao    = tt-param.valorCampo.
            WHEN "dsmorada"    THEN aux_dsmorada    = tt-param.valorCampo.                  
            WHEN "ddcancel"    THEN aux_ddcancel    = INTE(tt-param.valorCampo).
            WHEN "dddcorte"    THEN aux_dddcorte    = INTE(tt-param.valorCampo).
            WHEN "ddmaxpag"    THEN aux_ddmaxpag    = INTE(tt-param.valorCampo).
            WHEN "dsocupac"    THEN aux_dsocupac    = tt-param.valorCampo.
            WHEN "dtpagmto"    THEN aux_dtpagmto    = DATE(tt-param.valorCampo).
            WHEN "qtdiacar"    THEN aux_qtdiacar    = DEC(tt-param.valorCampo).
            WHEN "qtmaxpar"    THEN aux_qtmaxpar    = DEC(tt-param.valorCampo).
            WHEN "mmpripag"    THEN aux_mmpripag    = int(tt-param.valorCampo).
            WHEN "inplaseg"    THEN aux_inplaseg    = int(tt-param.valorCampo).
            WHEN "datdespr"    THEN aux_datdespr    = DATE(tt-param.valorCampo).
            WHEN "datdebit"    THEN aux_datdebit    = DATE(tt-param.valorCampo).
            WHEN "nrregist"    THEN aux_nrregist    = INT(tt-param.valorCampo).
            WHEN "nriniseq"    THEN aux_nriniseq    = INT(tt-param.valorCampo).

            
        END CASE.        
    END. /** Fim do FOR EACH tt-param **/

END PROCEDURE.

PROCEDURE validar_criacao:
    RUN validar_criacao IN hBO (INPUT aux_cdcooper,       
                                INPUT aux_cdagenci,       
                                INPUT aux_nrdcaixa,       
                                INPUT aux_cdoperad,       
                                INPUT aux_dtmvtolt,       
                                INPUT aux_nrdconta,       
                                INPUT aux_idseqttl,       
                                INPUT aux_idorigem,       
                                INPUT aux_nmdatela,       
                                INPUT FALSE,               
                                INPUT aux_cdsegura,       
                                INPUT day(aux_dtdebito),       
                                INPUT aux_dtfimvig,       
                                INPUT aux_dtiniseg,       
                                INPUT aux_dtprideb,       
                                INPUT aux_nmbenvid1,      
                                INPUT aux_nmbenvid2,      
                                INPUT aux_nmbenvid3,      
                                INPUT aux_nmbenvid4,      
                                INPUT aux_nmbenvid5,      
                                INPUT aux_nrctrseg,       
                                INPUT aux_nrdolote,       
                                INPUT aux_tpplaseg,       
                                INPUT aux_tpseguro,       
                                INPUT aux_txpartic1,      
                                INPUT aux_txpartic2,      
                                INPUT aux_txpartic3,      
                                INPUT aux_txpartic4,      
                                INPUT aux_txpartic5,      
                                INPUT aux_vlpreseg,       
                                INPUT aux_vlcapseg,       
                                INPUT aux_cdbccxlt,       
                                INPUT aux_nrcpfcgc,       
                                INPUT aux_nmdsegur,       
                                INPUT aux_nmcidade,
                                INPUT aux_nrcepend,
                                INPUT aux_tpendcor,
                                INPUT aux_nrpagina,
                                INPUT aux_dtnascsg,
                                OUTPUT aux_rec_crawseg,
                                OUTPUT aux_nmdcampo,
                                OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.

            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE,
                             INPUT "Erro").
            RUN piXmlAtributo (INPUT "nmdcampo", INPUT TRIM(aux_nmdcampo)).
            RUN piXmlSave.
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlAtributo (INPUT "reccraws",INPUT STRING(aux_rec_crawseg)). 
            RUN piXmlSave.
        END.    
        
END PROCEDURE.

PROCEDURE cria_seguro:
           
    RUN cria_seguro IN hBO (INPUT aux_cdcooper,
                            INPUT aux_cdagenci,
                            INPUT aux_nrdcaixa,
                            INPUT aux_cdoperad,
                            INPUT aux_dtmvtolt,
                            INPUT aux_nrdconta,
                            INPUT aux_idseqttl,
                            INPUT aux_idorigem,
                            INPUT aux_nmdatela,
                            INPUT FALSE,
                            INPUT aux_cdmotcan,
                            INPUT aux_cdsegura,
                            INPUT aux_cdsitseg,
                            INPUT aux_dsgraupr1,
                            INPUT aux_dsgraupr2,
                            INPUT aux_dsgraupr3,
                            INPUT aux_dsgraupr4,
                            INPUT aux_dsgraupr5,
                            INPUT aux_dtaltseg,
                            INPUT aux_dtcancel,
                            INPUT aux_dtdebito,
                            INPUT aux_dtfimvig,
                            INPUT aux_dtiniseg,
                            INPUT aux_dtinivig,
                            INPUT aux_dtprideb,
                            INPUT aux_dtultalt,
                            INPUT aux_dtultpag,
                            INPUT aux_flgclabe,
                            INPUT aux_flgconve,
                            INPUT aux_flgunica,
                            INPUT aux_indebito,
                            INPUT aux_lsctrant,
                            INPUT aux_nmbenvid1,
                            INPUT aux_nmbenvid2,
                            INPUT aux_nmbenvid3,
                            INPUT aux_nmbenvid4,
                            INPUT aux_nmbenvid5,
                            INPUT aux_nrctratu,
                            INPUT aux_nrctrseg,
                            INPUT aux_nrdolote,
                            INPUT aux_qtparcel,
                            INPUT aux_qtprepag,
                            INPUT aux_qtprevig,
                            INPUT aux_tpdpagto,
                            INPUT aux_tpendcor,
                            INPUT aux_tpplaseg,
                            INPUT aux_tpseguro,
                            INPUT aux_txpartic1,
                            INPUT aux_txpartic2,
                            INPUT aux_txpartic3,
                            INPUT aux_txpartic4,
                            INPUT aux_txpartic5,
                            INPUT aux_vldifseg,
                            INPUT aux_vlpremio,
                            INPUT aux_vlprepag,
                            INPUT aux_vlpreseg,
                            INPUT aux_vlcapseg,
                            INPUT aux_cdbccxlt,
                            INPUT aux_nrcpfcgc,
                            INPUT aux_nmdsegur,
                            INPUT aux_vltotpre,
                            INPUT aux_cdcalcul,
                            INPUT aux_vlseguro,
                            INPUT aux_dsendres,
                            INPUT aux_nrendres,
                            INPUT aux_nmbairro,
                            INPUT aux_nmcidade,
                            INPUT aux_cdufresd,
                            INPUT aux_nrcepend,
                            INPUT aux_cdsexosg,
                            INPUT aux_cdempres,
                            INPUT aux_dtnascsg,
                            INPUT aux_complend,
                            OUTPUT aux_flgsegur,
                            OUTPUT aux_rec_crawseg,
                            OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:             
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:    
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO: 
            RUN piXmlNew.
            RUN piXmlAtributo (INPUT "flgsegur",INPUT LOGICAL(aux_flgsegur)).
            RUN piXmlAtributo (INPUT "reccraws",INPUT STRING(aux_rec_crawseg)).
            RUN piXmlSave.
        END.   
              
END PROCEDURE.
                            
PROCEDURE calcular_data_vigencia:
    RUN calcular_data_vigencia IN hBO (INPUT aux_cdcooper,
                                       INPUT aux_cdagenci,
                                       INPUT aux_nrdcaixa,
                                       INPUT aux_cdoperad,
                                       INPUT aux_dtmvtolt,
                                       INPUT aux_nrdconta,
                                       INPUT aux_idseqttl,
                                       INPUT aux_idorigem,
                                       INPUT aux_nmdatela,
                                       INPUT TRUE,
                                       INPUT aux_qtmesano,
                                       INPUT aux_tpmesano,
                                       OUTPUT aux_dtcalcul,
                                       OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlAtributo (INPUT "dtcalcul",INPUT STRING(aux_dtcalcul)).
            RUN piXmlSave.
        END.   
END PROCEDURE.

PROCEDURE seguro_auto:
    RUN seguro_auto IN hBO (INPUT aux_cdcooper,                     
                            INPUT aux_cdagenci,
                            INPUT aux_nrdcaixa,
                            INPUT aux_cdoperad,
                            INPUT aux_dtmvtolt,
                            INPUT aux_nrdconta,
                            INPUT aux_nrctrseg,
                            INPUT aux_idseqttl,
                            INPUT aux_idorigem,
                            INPUT aux_nmdatela,
                            INPUT TRUE,
                            OUTPUT TABLE tt-seguros_autos).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-seguros_autos:HANDLE,
                             INPUT "Seguro_auto").
            RUN piXmlSave.
        END.   
END PROCEDURE.

PROCEDURE atualizar_matricula:
    RUN atualizar_matricula IN hBO (INPUT aux_cdcooper,
                                    INPUT aux_cdagenci,
                                    INPUT aux_nrdcaixa,
                                    INPUT aux_cdoperad,
                                    INPUT aux_dtmvtolt,
                                    INPUT aux_nrdconta,
                                    INPUT aux_idseqttl,
                                    INPUT aux_idorigem,
                                    INPUT aux_nmdatela,
                                    INPUT TRUE,
                                    OUTPUT TABLE tt-matricula,
                                    OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlSave.
        END.   
END PROCEDURE.

PROCEDURE buscar_seq_matricula:
    RUN buscar_seq_matricula IN hBO (INPUT aux_cdcooper,
                                     INPUT aux_cdagenci,
                                     INPUT aux_nrdcaixa,
                                     INPUT aux_cdoperad,
                                     INPUT aux_dtmvtolt,
                                     INPUT aux_nrdconta,
                                     INPUT aux_idseqttl,
                                     INPUT aux_idorigem,
                                     INPUT aux_nmdatela,
                                     INPUT TRUE,
                                     OUTPUT TABLE tt-matricula,
                                     OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-matricula:HANDLE,
                             INPUT "Matricula").
            RUN piXmlSave.
        END.                                                      
END PROCEDURE.

PROCEDURE buscar_feriados:
    RUN buscar_feriados IN hBO (INPUT aux_cdcooper,
                                INPUT aux_cdagenci,
                                INPUT aux_nrdcaixa,
                                INPUT aux_cdoperad,
                                INPUT aux_dtmvtolt,
                                INPUT aux_nrdconta,
                                INPUT aux_idseqttl,
                                INPUT aux_idorigem,
                                INPUT aux_nmdatela,
                                INPUT TRUE,
                                INPUT aux_dtferiad,
                                OUTPUT TABLE tt-feriado,
                                OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-feriado:HANDLE,
                             INPUT "Feriados").
            RUN piXmlSave.
        END.                                                      
END PROCEDURE.

PROCEDURE buscar_end_coo:
    RUN buscar_end_coo IN hBO (INPUT aux_cdcooper,
                               INPUT aux_cdagenci,
                               INPUT aux_nrdcaixa,
                               INPUT aux_cdoperad,
                               INPUT aux_dtmvtolt,
                               INPUT aux_nrdconta,
                               INPUT aux_idseqttl,
                               INPUT aux_idorigem,
                               INPUT aux_nmdatela,
                               INPUT FALSE,
                               OUTPUT TABLE tt-end-coop,
                               OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-end-coop:HANDLE,
                             INPUT "Endereco_cooperado").
            RUN piXmlSave.
        END.                                                      
END PROCEDURE.

PROCEDURE buscar_inf_conjuge:
    RUN buscar_inf_conjuge IN hBO (INPUT aux_cdcooper,
                                   INPUT aux_cdagenci,
                                   INPUT aux_nrdcaixa,
                                   INPUT aux_cdoperad,
                                   INPUT aux_dtmvtolt,
                                   INPUT aux_nrdconta,
                                   INPUT aux_idseqttl,
                                   INPUT aux_idorigem,
                                   INPUT aux_nmdatela,
                                   INPUT TRUE,
                                   OUTPUT TABLE tt-inf-conj,
                                   OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-inf-conj:HANDLE,
                             INPUT "Conjuges").
            RUN piXmlSave.
        END.                                                      
END PROCEDURE.

PROCEDURE buscar_seguro_geral:
    RUN buscar_seguro_geral IN hBO (INPUT aux_cdcooper,
                                    INPUT aux_cdagenci,
                                    INPUT aux_nrdcaixa,
                                    INPUT aux_cdoperad,
                                    INPUT aux_dtmvtolt,
                                    INPUT aux_nrdconta,
                                    INPUT aux_idseqttl,
                                    INPUT aux_idorigem,
                                    INPUT aux_nmdatela,
                                    INPUT FALSE,
                                    INPUT aux_cdsegura,
                                    INPUT aux_tpseguro,
                                    INPUT aux_nrctrseg,
                                    OUTPUT TABLE tt-seg-geral,
                                    OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-seg-geral:HANDLE,
                             INPUT "Seguro_casa").
            RUN piXmlSave.
        END.                                                      
END PROCEDURE.

PROCEDURE buscar_cobertura_casa:
    RUN buscar_cobertura_casa IN hBO (INPUT aux_cdcooper,
                                      INPUT aux_cdagenci,
                                      INPUT aux_nrdcaixa,
                                      INPUT aux_cdoperad,
                                      INPUT aux_dtmvtolt,
                                      INPUT aux_nrdconta,
                                      INPUT aux_idseqttl,
                                      INPUT aux_idorigem,
                                      INPUT aux_nmdatela,
                                      INPUT TRUE,
                                      INPUT aux_nrtabela,
                                      OUTPUT TABLE tt-cobert-casa,
                                      OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-cobert-casa:HANDLE,
                             INPUT "Cobertura_casa").
            RUN piXmlSave.
        END.                                                      
END PROCEDURE.

PROCEDURE buscar_situacao_proposta:
    RUN buscar_situacao_proposta IN hBO (INPUT aux_cdcooper,
                                         INPUT aux_cdagenci,
                                         INPUT aux_nrdcaixa,
                                         INPUT aux_cdoperad,
                                         INPUT aux_dtmvtolt,
                                         INPUT aux_nrdconta,
                                         INPUT aux_idseqttl,
                                         INPUT aux_idorigem,
                                         INPUT aux_nmdatela,
                                         INPUT TRUE,
                                         INPUT aux_nrctrseg,
                                         INPUT aux_tpseguro,
                                         OUTPUT aux_cdsitseg,
                                         OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlAtributo (INPUT "cdsitseg",INPUT STRING(aux_cdsitseg)).
            RUN piXmlSave.
        END.
END PROCEDURE.

PROCEDURE atualizar_movtos_seg:
    RUN atualizar_movtos_seg IN hBO (INPUT aux_cdcooper,
                                     INPUT aux_cdagenci,
                                     INPUT aux_nrdcaixa,
                                     INPUT aux_cdoperad,
                                     INPUT aux_dtmvtolt,
                                     INPUT aux_nrdconta,
                                     INPUT aux_idseqttl,
                                     INPUT aux_idorigem,
                                     INPUT aux_nmdatela,
                                     INPUT TRUE,
                                     INPUT aux_nrtabela,
                                     INPUT aux_tpseguro,
                                     INPUT aux_tpplaseg,
                                     INPUT aux_vlpercen,
                                     INPUT aux_dtdebito,
                                     INPUT aux_dtdespre,
                                     INPUT aux_nrctrseg,
                                     OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlSave.
        END.   
END PROCEDURE.

PROCEDURE imprimir_proposta_seguro:
    RUN imprimir_proposta_seguro IN hBO (INPUT aux_cdcooper,
                                         INPUT aux_cdagenci,
                                         INPUT aux_nrdcaixa,
                                         INPUT aux_cdoperad,
                                         INPUT aux_dtmvtolt,
                                         INPUT aux_nrdconta,
                                         INPUT aux_idseqttl,
                                         INPUT aux_idorigem,
                                         INPUT aux_nmdatela,
                                         INPUT FALSE,
                                         INPUT aux_tpseguro,
                                         INPUT aux_tpplaseg,
                                         INPUT aux_cdsegura,
                                         INPUT aux_nrctrseg,
                                         INPUT aux_nmendter,
                                         INPUT aux_reccraws,
                                         OUTPUT aux_nmarqimp,
                                         OUTPUT aux_nmarqpdf,
                                         OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlAtributo (INPUT "nmarqimp",INPUT STRING(aux_nmarqimp)).
            RUN piXmlAtributo (INPUT "nmarqpdf",INPUT STRING(aux_nmarqpdf)).
            RUN piXmlSave.
        END.
END PROCEDURE.

PROCEDURE imprimir_alt_seg_vida:
    RUN imprimir_alt_seg_vida IN hBO (INPUT aux_cdcooper,
                                      INPUT aux_cdagenci,
                                      INPUT aux_nrdcaixa,
                                      INPUT aux_cdoperad,
                                      INPUT aux_dtmvtolt,
                                      INPUT aux_nrdconta,
                                      INPUT aux_idseqttl,
                                      INPUT aux_idorigem,
                                      INPUT aux_nmdatela,
                                      INPUT FALSE,
                                      INPUT aux_tpseguro,
                                      INPUT aux_tpplaseg,
                                      INPUT aux_cdsegura,
                                      INPUT aux_nrctrseg,
                                      INPUT aux_nmendter,
                                      INPUT aux_reccraws,
                                      INPUT aux_cddopcao,
                                      OUTPUT aux_nmarqimp,
                                      OUTPUT aux_nmarqpdf,
                                      OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlAtributo (INPUT "nmarqimp",INPUT STRING(aux_nmarqimp)).
            RUN piXmlAtributo (INPUT "nmarqpdf",INPUT STRING(aux_nmarqpdf)).
            RUN piXmlSave.
        END.
END PROCEDURE.

PROCEDURE imprimir_atual_movto_seg:

    RUN imprimir_atual_movto_seg IN hBO (INPUT aux_cdcooper,
                                         INPUT aux_cdagenci,
                                         INPUT aux_nrdcaixa,
                                         INPUT aux_cdoperad,
                                         INPUT aux_dtmvtolt,
                                         INPUT aux_nrdconta,
                                         INPUT aux_idseqttl,
                                         INPUT aux_idorigem,
                                         INPUT aux_nmdatela,
                                         INPUT TRUE,
                                         INPUT aux_nrtabela,
                                         INPUT aux_tpseguro,
                                         INPUT aux_tpplaseg,
                                         INPUT aux_vlpercen,
                                         INPUT aux_dtdebito,
                                         INPUT aux_dtdespre,
                                         INPUT aux_nrctrseg,
                                         INPUT aux_nmendter,
                                         OUTPUT aux_nmarqimp,
                                         OUTPUT aux_nmarqpdf,
                                         OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlAtributo (INPUT "nmarqimp",INPUT STRING(aux_nmarqimp)).
            RUN piXmlAtributo (INPUT "nmarqpdf",INPUT STRING(aux_nmarqpdf)).
            RUN piXmlSave.
        END.
END PROCEDURE.

PROCEDURE buscar_plano_seguro:
    RUN buscar_plano_seguro IN hBO (INPUT aux_cdcooper,
                                    INPUT aux_cdagenci,
                                    INPUT aux_nrdcaixa,
                                    INPUT aux_cdoperad,
                                    INPUT aux_dtmvtolt,
                                    INPUT aux_nrdconta,
                                    INPUT aux_idseqttl,
                                    INPUT aux_idorigem,
                                    INPUT aux_nmdatela,
                                    INPUT FALSE,
                                    INPUT aux_cdsegura,
                                    INPUT aux_tpseguro,
                                    INPUT aux_tpplaseg,
                                    OUTPUT TABLE tt-plano-seg,
                                    OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-plano-seg:HANDLE,
                             INPUT "Plano_seguro").
            RUN piXmlSave.
        END.
END PROCEDURE.

PROCEDURE valida_existe_plano_seg:
    RUN valida_existe_plano_seg IN hBO (INPUT aux_cdcooper,
                                        INPUT aux_cdagenci,
                                        INPUT aux_nrdcaixa,
                                        INPUT aux_cdoperad,
                                        INPUT aux_dtmvtolt,
                                        INPUT aux_nrdconta,
                                        INPUT aux_idseqttl,
                                        INPUT aux_idorigem,
                                        INPUT aux_nmdatela,
                                        INPUT FALSE,
                                        INPUT aux_cdsegura,
                                        INPUT aux_tpseguro,
                                        INPUT aux_tpplaseg,
                                        OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlSave.
        END.
END PROCEDURE.

PROCEDURE buscar_titular:
    RUN buscar_titular IN hBO (INPUT aux_cdcooper,
                               INPUT aux_cdagenci,
                               INPUT aux_nrdcaixa,
                               INPUT aux_cdoperad,
                               INPUT aux_dtmvtolt,
                               INPUT aux_nrdconta,
                               INPUT aux_idseqttl,
                               INPUT aux_idorigem,
                               INPUT aux_nmdatela,
                               INPUT TRUE,
                               OUTPUT TABLE tt-titular,
                               OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-titular:HANDLE,
                             INPUT "Titulares").
            RUN piXmlSave.
        END.
END PROCEDURE.

PROCEDURE buscar_empresa:
    RUN buscar_empresa IN hBO (INPUT aux_cdcooper,
                               INPUT aux_cdagenci,
                               INPUT aux_nrdcaixa,
                               INPUT aux_cdoperad,
                               INPUT aux_dtmvtolt,
                               INPUT aux_nrdconta,
                               INPUT aux_idseqttl,
                               INPUT aux_idorigem,
                               INPUT aux_nmdatela,
                               INPUT TRUE,
                               INPUT aux_cdempres,
                               OUTPUT TABLE tt-empresa,
                               OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-empresa:HANDLE,
                             INPUT "Empresas").
            RUN piXmlSave.
        END.
END PROCEDURE.

PROCEDURE buscar_pessoa_juridica:
    RUN buscar_pessoa_juridica IN hBO (INPUT aux_cdcooper,
                                       INPUT aux_cdagenci,
                                       INPUT aux_nrdcaixa,
                                       INPUT aux_cdoperad,
                                       INPUT aux_dtmvtolt,
                                       INPUT aux_nrdconta,
                                       INPUT aux_idseqttl,
                                       INPUT aux_idorigem,
                                       INPUT aux_nmdatela,
                                       INPUT TRUE,
                                       OUTPUT TABLE tt-pess-jur,
                                       OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-pess-jur:HANDLE,
                             INPUT "Pessoa_juridica").
            RUN piXmlSave.
        END.
END PROCEDURE.

PROCEDURE buscar_cooperativa:
    RUN buscar_cooperativa IN hBO (INPUT aux_cdcooper,
                                   INPUT aux_cdagenci,
                                   INPUT aux_nrdcaixa,
                                   INPUT aux_cdoperad,
                                   INPUT aux_dtmvtolt,
                                   INPUT aux_nrdconta,
                                   INPUT aux_idseqttl,
                                   INPUT aux_idorigem,
                                   INPUT aux_nmdatela,
                                   INPUT TRUE,
                                   OUTPUT TABLE tt-cooperativa,
                                   OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-cooperativa:HANDLE,
                             INPUT "Cooperativas").
            RUN piXmlSave.
        END.
END PROCEDURE.

PROCEDURE buscar_associados:
    RUN buscar_associados IN hBO (INPUT aux_cdcooper,
                                  INPUT aux_cdagenci,
                                  INPUT aux_nrdcaixa,
                                  INPUT aux_cdoperad,
                                  INPUT aux_dtmvtolt,
                                  INPUT aux_nrdconta,
                                  INPUT aux_idseqttl,
                                  INPUT aux_idorigem,
                                  INPUT aux_nmdatela,
                                  INPUT FALSE,
                                  OUTPUT TABLE tt-associado,
                                  OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-associado:HANDLE,
                             INPUT "Associados").
            RUN piXmlSave.
        END.
END PROCEDURE.

PROCEDURE gerar_atualizacao_seg:
    RUN gerar_atualizacao_seg IN hBO (INPUT aux_cdcooper,
                                      INPUT aux_cdagenci,
                                      INPUT aux_nrdcaixa,
                                      INPUT aux_cdoperad,
                                      INPUT aux_dtmvtolt,
                                      INPUT aux_nrdconta,
                                      INPUT aux_idseqttl,
                                      INPUT aux_idorigem,
                                      INPUT aux_nmdatela,
                                      INPUT TRUE,
                                      INPUT aux_nrtabela,
                                      INPUT aux_tpseguro,
                                      INPUT aux_tpplaseg,
                                      INPUT aux_vlpercen,
                                      INPUT aux_dtdebito,
                                      INPUT aux_dtdespre,
                                      OUTPUT TABLE tt-seguros,
                                      OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-seguros:HANDLE,
                             INPUT "Seguros").
            RUN piXmlSave.
        END.
END PROCEDURE.

PROCEDURE busca_end_cor:
    RUN busca_end_cor IN hBO (INPUT aux_cdcooper,
                              INPUT aux_cdagenci,
                              INPUT aux_nrdcaixa,
                              INPUT aux_cdoperad,
                              INPUT aux_dtmvtolt,
                              INPUT aux_nrdconta,
                              INPUT aux_idseqttl,
                              INPUT aux_idorigem,
                              INPUT aux_nmdatela,
                              INPUT FALSE,
                              INPUT aux_nrctrseg,
                              INPUT aux_tpendcor,
                              OUTPUT TABLE tt_end_cor,
                              OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt_end_cor:HANDLE,
                             INPUT "Endereco_correspondencia").
            RUN piXmlSave.
        END.
END PROCEDURE.

PROCEDURE validar_plano_seguro:
    RUN validar_plano_seguro IN hBO (INPUT aux_cdcooper,
                                     INPUT aux_cdagenci,
                                     INPUT aux_nrdcaixa,
                                     INPUT aux_cdoperad,
                                     INPUT aux_dtmvtolt,
                                     INPUT aux_nrdconta,
                                     INPUT aux_idseqttl,
                                     INPUT aux_idorigem,
                                     INPUT aux_nmdatela,
                                     INPUT TRUE,
                                     INPUT aux_cdsitpsg,
                                     INPUT aux_vlplaseg,
                                     INPUT aux_vlmorada,
                                     INPUT aux_vlpreseg,
                                     INPUT aux_vlcapseg,
                                     OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlSave.
        END.   
END PROCEDURE.

PROCEDURE validar_inclusao_vida:
    RUN validar_inclusao_vida IN hBO (INPUT aux_cdcooper,
                                      INPUT aux_cdagenci,
                                      INPUT aux_nrdcaixa,
                                      INPUT aux_cdoperad,
                                      INPUT aux_dtmvtolt,
                                      INPUT aux_nrdconta,
                                      INPUT aux_idseqttl,
                                      INPUT aux_idorigem,
                                      INPUT aux_nmdatela,
                                      INPUT FALSE,
                                      INPUT aux_inpessoa,
                                      INPUT aux_cdsitdct,
                                      INPUT aux_dtnascsg,
                                      INPUT aux_nmdsegur,
                                      OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlSave.
        END.   
END PROCEDURE.

PROCEDURE valida_inc_seguro:
    RUN valida_inc_seguro IN hBO (INPUT aux_cdcooper,
                                  INPUT aux_cdagenci,
                                  INPUT aux_nrdcaixa,
                                  INPUT aux_cdoperad,
                                  INPUT aux_dtmvtolt,
                                  INPUT aux_nrdconta,
                                  INPUT aux_idseqttl,
                                  INPUT aux_idorigem,
                                  INPUT aux_nmdatela,
                                  INPUT FALSE,
                                  INPUT aux_inpessoa,
                                  OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlSave.
        END.   
END PROCEDURE.

PROCEDURE buscar_tip_seguro:
    RUN buscar_tip_seguro IN hBO (INPUT aux_cdcooper,
                                  INPUT aux_cdagenci,
                                  INPUT aux_nrdcaixa,
                                  INPUT aux_cdoperad,
                                  INPUT aux_dtmvtolt,
                                  INPUT aux_nrdconta,
                                  INPUT aux_idseqttl,
                                  INPUT aux_idorigem,
                                  INPUT aux_nmdatela,
                                  INPUT FALSE,
                                  INPUT aux_cdsegura,
                                  INPUT aux_tpseguro,
                                  INPUT aux_nrctrseg,
                                  OUTPUT aux_dstipseg,
                                  OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:

            RUN piXmlNew.
            RUN piXmlAtributo (INPUT "dstipseg",INPUT STRING(aux_dstipseg)).
            RUN piXmlSave.
        END.
END PROCEDURE.

PROCEDURE buscar_seguradora:
    RUN buscar_seguradora IN hBO (INPUT aux_cdcooper,
                                  INPUT aux_cdagenci,
                                  INPUT aux_nrdcaixa,
                                  INPUT aux_cdoperad,
                                  INPUT aux_dtmvtolt,
                                  INPUT aux_nrdconta,
                                  INPUT aux_idseqttl,
                                  INPUT aux_idorigem,
                                  INPUT aux_nmdatela,
                                  INPUT FALSE,
                                  INPUT aux_tpseguro,
                                  INPUT aux_cdsitpsg,
                                  INPUT aux_cdsegura,
                                  INPUT aux_nmsegura,
                                  OUTPUT aux_qtregist,
                                  OUTPUT TABLE tt-seguradora,
                                  OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-seguradora:HANDLE,
                             INPUT "Seguradoras").
            RUN piXmlAtributo (INPUT "qtregist",INPUT STRING(aux_qtregist)).
            RUN piXmlSave.
        END.
END PROCEDURE.

PROCEDURE buscar_proposta_seguro:
    RUN buscar_proposta_seguro IN hBO (INPUT aux_cdcooper,
                                       INPUT aux_cdagenci,
                                       INPUT aux_nrdcaixa,
                                       INPUT aux_cdoperad,
                                       INPUT aux_dtmvtolt,
                                       INPUT aux_nrdconta,
                                       INPUT aux_idseqttl,
                                       INPUT aux_idorigem,
                                       INPUT aux_nmdatela,
                                       INPUT FALSE, /* LOG */
                                       OUTPUT TABLE tt-prop-seguros,
                                       OUTPUT aux_qtsegass,
                                       OUTPUT aux_vltotseg,
                                       OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-prop-seguros:HANDLE,
                             INPUT "Propostas_de_seguros").
            RUN piXmlAtributo (INPUT "qtsegass",INPUT STRING(aux_qtsegass)).
            RUN piXmlAtributo (INPUT "vltotseg",INPUT STRING(aux_vltotseg)).
            RUN piXmlSave.
        END.
END PROCEDURE.

PROCEDURE buscar_motivo_can:
    RUN buscar_motivo_can IN hBO (INPUT aux_cdcooper,
                                  INPUT aux_cdagenci,
                                  INPUT aux_nrdcaixa,
                                  INPUT aux_cdoperad,
                                  INPUT aux_dtmvtolt,
                                  INPUT aux_nrdconta,
                                  INPUT aux_idseqttl,
                                  INPUT aux_idorigem,
                                  INPUT aux_nmdatela,
                                  INPUT FALSE, /* LOG */
                                  INPUT aux_cdmotcan,
                                  INPUT aux_dsmotcan,
                                  OUTPUT aux_qtregist,
                                  OUTPUT TABLE tt-mot-can,
                                  OUTPUT TABLE tt-erro).
                                 
    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-mot-can:HANDLE,
                             INPUT "Motivo_cancelamento").  
            RUN piXmlAtributo (INPUT "qtregist",INPUT STRING(aux_qtregist)).
            RUN piXmlSave.
        END.                                         
END PROCEDURE.

PROCEDURE cancelar_seguro:
    RUN cancelar_seguro IN hBO (INPUT aux_cdcooper,
                                INPUT aux_cdagenci,
                                INPUT aux_nrdcaixa,
                                INPUT aux_cdoperad,
                                INPUT aux_dtmvtolt,
                                INPUT aux_nrdconta,
                                INPUT aux_idseqttl,
                                INPUT aux_idorigem,
                                INPUT aux_nmdatela,
                                INPUT TRUE, /* LOG */
                                INPUT aux_tpseguro,
                                INPUT aux_nrctrseg,
                                INPUT aux_cdmotcan,
                                OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlSave.
        END.   
END PROCEDURE.

PROCEDURE desfaz_canc_seguro:
    RUN desfaz_canc_seguro IN hBO (INPUT aux_cdcooper,
                                   INPUT aux_cdagenci,
                                   INPUT aux_nrdcaixa,
                                   INPUT aux_cdoperad,
                                   INPUT aux_dtmvtolt,
                                   INPUT aux_nrdconta,
                                   INPUT aux_idseqttl,
                                   INPUT aux_idorigem,
                                   INPUT aux_nmdatela,
                                   INPUT FALSE, /* LOG */
                                   INPUT aux_tpseguro,
                                   INPUT aux_nrctrseg,
                                   OUTPUT TABLE tt-erro).
                                
   IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlSave.
        END.   
END PROCEDURE.

PROCEDURE atualizar_seguro:
    RUN atualizar_seguro IN hBO (INPUT aux_cdcooper,                
                                 INPUT aux_cdagenci,                
                                 INPUT aux_nrdcaixa,                
                                 INPUT aux_cdoperad,                
                                 INPUT aux_dtmvtolt,                
                                 INPUT aux_nrdconta,                
                                 INPUT aux_idseqttl,                
                                 INPUT aux_idorigem,                
                                 INPUT aux_nmdatela,                
                                 INPUT FALSE, /* LOG */              
                                 INPUT aux_tpseguro,                
                                 INPUT aux_nrctrseg,                
                                 INPUT aux_cdsegura,                
                                 INPUT aux_cdsitseg,                
                                 INPUT aux_dsgraupr1,               
                                 INPUT aux_dsgraupr2,               
                                 INPUT aux_dsgraupr3,               
                                 INPUT aux_dsgraupr4,               
                                 INPUT aux_dsgraupr5,               
                                 INPUT aux_nmbenvid1,               
                                 INPUT aux_nmbenvid2,               
                                 INPUT aux_nmbenvid3,               
                                 INPUT aux_nmbenvid4,               
                                 INPUT aux_nmbenvid5,               
                                 INPUT aux_txpartic1,
                                 INPUT aux_txpartic2,               
                                 INPUT aux_txpartic3,               
                                 INPUT aux_txpartic4,               
                                 INPUT aux_txpartic5,               
                                 OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlSave.
        END.   
END PROCEDURE.

PROCEDURE busca_seguros:

    RUN busca_seguros IN hBO (INPUT aux_cdcooper,
                              INPUT aux_cdagenci,
                              INPUT aux_nrdcaixa,
                              INPUT aux_cdoperad,
                              INPUT aux_dtmvtolt,
                              INPUT aux_nrdconta,
                              INPUT aux_idseqttl,
                              INPUT aux_idorigem,
                              INPUT aux_nmdatela,
                              INPUT FALSE, /* LOG */
                              OUTPUT TABLE tt-seguros,
                              OUTPUT aux_qtsegass,
                              OUTPUT aux_vltotseg,
                              OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
           RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-seguros:HANDLE,
                             INPUT "Seguros").
            RUN piXmlAtributo (INPUT "qtsegass",INPUT STRING(aux_qtsegass)).
            RUN piXmlAtributo (INPUT "vltotseg",INPUT STRING(aux_vltotseg)).
            RUN piXmlSave.
        END.
    

END PROCEDURE.

PROCEDURE incluir_garantias:
    RUN incluir_garantias IN hBO (INPUT aux_cdsegura,
                                  INPUT aux_tpseguro,
                                  INPUT aux_tpplaseg,
                                  INPUT aux_cdcooper,
                                  INPUT aux_cdagenci,
                                  INPUT aux_nrdcaixa,
                                  INPUT aux_cdoperad,
                                  INPUT aux_dtmvtolt,
                                  INPUT aux_nrdconta,
                                  INPUT aux_idseqttl,
                                  INPUT aux_idorigem,
                                  INPUT aux_nmdatela,
                                  INPUT TRUE, /* LOG */
                                  INPUT aux_dsgarant,
                                  INPUT aux_vlgarant,
                                  INPUT aux_dsfranqu,
                                  OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlSave.
        END.   

END PROCEDURE.

PROCEDURE alterar_garantias:
    RUN alterar_garantias IN hBO (INPUT aux_cdcooper,
                                  INPUT aux_cdagenci,
                                  INPUT aux_nrdcaixa,
                                  INPUT aux_cdoperad,
                                  INPUT aux_dtmvtolt,
                                  INPUT aux_nrdconta,
                                  INPUT aux_idseqttl,
                                  INPUT aux_idorigem,
                                  INPUT aux_nmdatela,
                                  INPUT TRUE, /* LOG */
                                  INPUT aux_dsgarant,
                                  INPUT aux_vlgarant,
                                  INPUT aux_dsfranqu,
                                  INPUT aux_cdsegura,
                                  INPUT aux_tpseguro,
                                  INPUT aux_tpplaseg,
                                  INPUT aux_nrseqinc,
                                  OUTPUT TABLE tt-erro).
            
    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlSave.
        END.

END PROCEDURE.

PROCEDURE excluir_garantias:
    RUN excluir_garantias IN hBO (INPUT aux_nrseqinc,
                                  INPUT aux_cdsegura,
                                  INPUT aux_tpseguro,
                                  INPUT aux_tpplaseg,
                                  INPUT aux_cdcooper,
                                  INPUT aux_cdagenci,
                                  INPUT aux_nrdcaixa,
                                  INPUT aux_cdoperad,
                                  INPUT aux_dtmvtolt,
                                  INPUT aux_nrdconta,
                                  INPUT aux_idseqttl,
                                  INPUT aux_idorigem,
                                  INPUT aux_nmdatela,
                                  INPUT TRUE, /* LOG */
                                  INPUT aux_dsgarant,
                                  INPUT aux_vlgarant,
                                  INPUT aux_dsfranqu,
                                  OUTPUT TABLE tt-erro).
            
    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlSave.
        END.   
END PROCEDURE.

PROCEDURE buscar_garantias:
    RUN buscar_garantias IN hBO (INPUT aux_cdcooper,
                                 INPUT aux_cdagenci,
                                 INPUT aux_nrdcaixa,
                                 INPUT aux_cdoperad,
                                 INPUT aux_dtmvtolt,
                                 INPUT aux_nrdconta,
                                 INPUT aux_idseqttl,
                                 INPUT aux_idorigem,
                                 INPUT aux_nmdatela,
                                 INPUT TRUE, /* LOG */
                                 INPUT aux_cdsegura,
                                 INPUT aux_tpseguro,
                                 INPUT aux_tpplaseg,
                                 INPUT aux_nrseqinc,
                                 OUTPUT TABLE tt-gar-seg,
                                 OUTPUT TABLE tt-erro).
            
    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-gar-seg:HANDLE,
                             INPUT "Garantias_seguro").
            RUN piXmlSave.
        END.
END PROCEDURE.


PROCEDURE imprimir_termo_cancelamento:
    RUN imprimir_termo_cancelamento IN hBO (INPUT aux_cdcooper,
                                            INPUT aux_cdagenci,
                                            INPUT aux_nrdcaixa,
                                            INPUT aux_cdoperad,
                                            INPUT aux_dtmvtolt,
                                            INPUT aux_nrdconta,
                                            INPUT aux_nrctrseg,
                                            INPUT aux_tpseguro,
                                            INPUT aux_idseqttl,
                                            INPUT aux_idorigem,
                                            INPUT aux_nmdatela,
                                            INPUT FALSE, /* LOG */
                                            INPUT aux_nmendter,
                                            OUTPUT aux_nmarqimp,
                                            OUTPUT aux_nmarqpdf,
                                            OUTPUT TABLE tt-erro).
            
    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlAtributo (INPUT "nmarqimp",INPUT STRING(aux_nmarqimp)).
            RUN piXmlAtributo (INPUT "nmarqpdf",INPUT STRING(aux_nmarqpdf)).
            RUN piXmlSave.
        END.
END PROCEDURE.

PROCEDURE buscar_proposta_seguro_r:
    RUN buscar_proposta_seguro_r IN hBO (INPUT aux_cdcooper,                        
                                       INPUT aux_cdagenci,
                                       INPUT aux_nrdcaixa,
                                       INPUT aux_cdoperad,
                                       INPUT aux_dtmvtolt,
                                       INPUT aux_nrdconta,
                                       INPUT aux_idseqttl,
                                       INPUT aux_idorigem,
                                       INPUT aux_nmdatela,
                                       INPUT TRUE, /* LOG */
                                       INPUT aux_reccraws,
                                       OUTPUT TABLE tt-prop-seguros,
                                       OUTPUT aux_qtsegass,
                                       OUTPUT aux_vltotseg,
                                       OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-prop-seguros:HANDLE,
                             INPUT "Propostas_de_seguros").
            RUN piXmlAtributo (INPUT "qtsegass",INPUT STRING(aux_qtsegass)).
            RUN piXmlAtributo (INPUT "vltotseg",INPUT STRING(aux_vltotseg)).
            RUN piXmlSave.
        END.
END PROCEDURE.


PROCEDURE atualizar_plano_seguro:

   RUN atualizar_plano_seguro IN hBO ( input aux_cdcooper,
                                         input aux_cdagenci,
                                         input aux_nrdcaixa,
                                         input aux_cdoperad,
                                         input aux_dtmvtolt,
                                         input aux_nrdconta,
                                         input aux_idseqttl,
                                         input aux_idorigem,
                                         input aux_nmdatela,
                                         input TRUE        ,
                                         input aux_cdsegura,
                                         input aux_cdsitpsg,
                                         input aux_dsmorada,
                                         input aux_ddcancel,
                                         input aux_dddcorte,
                                         input aux_ddmaxpag,
                                         input aux_dsocupac,
                                         input aux_flgunica,
                                         input aux_inplaseg,
                                         input aux_mmpripag,
                                         input aux_nrtabela,
                                         input aux_qtdiacar,
                                         input aux_qtmaxpar,
                                         input aux_tpplaseg,
                                         input aux_tpseguro,
                                         input aux_vlmorada,
                                         input aux_vlplaseg,
                                         OUTPUT TABLE tt-erro).
        
    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlSave.
        END.

END PROCEDURE.



PROCEDURE pi_atualizar_perc_seg:

    RUN pi_atualizar_perc_seg IN hBO (input aux_cdcooper,
                                      input aux_cdagenci,
                                      input aux_nrdcaixa,
                                      input aux_cdoperad,
                                      input aux_dtmvtolt,
                                      input aux_nrdconta,
                                      input aux_idseqttl,
                                      input aux_idorigem,
                                      input aux_nmdatela,
                                      input FALSE,
                                      input aux_nrtabela,
                                      input aux_tpseguro,
                                      input aux_tpplaseg,
                                      INPUT aux_datdespr,
                                      INPUT aux_datdebit,
                                      INPUT aux_vlpercen,
                                      INPUT aux_nrregist,
                                      INPUT aux_nriniseq,
                                      OUTPUT aux_qtregist,
                                      OUTPUT TABLE cratseg,
                                      OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF NOT AVAILABLE tt-erro  THEN
               DO:
                   CREATE tt-erro.
                   ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                             "operacao.".
               END.
               
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE cratseg:HANDLE,
                             INPUT "planosseguros").
            RUN piXmlAtributo (INPUT "qtregist",INPUT STRING(aux_qtregist)).
            RUN piXmlSave.
        END.

END PROCEDURE.

PROCEDURE pi_atualizar_valor_seg:

    RUN pi_atualizar_valor_seg IN hBO ( INPUT aux_cdcooper,
                                        INPUT aux_cdagenci,
                                        INPUT aux_nrdcaixa,
                                        INPUT aux_cdoperad,
                                        INPUT aux_dtmvtolt,
                                        INPUT aux_nrdconta,
                                        INPUT aux_idseqttl,
                                        INPUT aux_idorigem,
                                        INPUT aux_nmdatela,
                                        INPUT TRUE,
                                        INPUT aux_nrtabela,
                                        INPUT aux_tpseguro,
                                        INPUT aux_tpplaseg,
                                        INPUT aux_datdespr,
                                        INPUT aux_datdebit,
                                        INPUT aux_vlpercen,
                                        OUTPUT TABLE tt-erro).



     IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlSave.
        END.



END PROCEDURE.

PROCEDURE imprimir_seg_atualizados:

    RUN imprimir_seg_atualizados IN hBO ( INPUT aux_cdcooper,
                                          INPUT aux_cdagenci,
                                          INPUT aux_nrdcaixa,
                                          INPUT aux_cdoperad,
                                          INPUT aux_dtmvtolt,
                                          INPUT aux_nrdconta,
                                          INPUT aux_idseqttl,
                                          INPUT aux_idorigem,
                                          INPUT aux_nmdatela,
                                          INPUT TRUE,
                                          INPUT aux_nrtabela,
                                          INPUT aux_tpseguro,
                                          INPUT aux_tpplaseg,
                                          INPUT aux_datdespr,
                                          INPUT aux_datdebit,
                                          INPUT aux_vlpercen,
                                          OUTPUT aux_nmarqimp,
                                          OUTPUT aux_nmarqpdf,
                                          OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlAtributo (INPUT "nmarqimp",INPUT STRING(aux_nmarqimp)).
            RUN piXmlAtributo (INPUT "nmarqpdf",INPUT STRING(aux_nmarqpdf)).
            RUN piXmlSave.
        END.

END PROCEDURE.
