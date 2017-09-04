/* .............................................................................

   Programa: includes/var_logcontas.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Evandro
   Data    : Abril/2006.                       Ultima atualizacao: 20/04/2017

   Dados referentes ao programa:

   Frequencia: Sempre que for chamada.
   Objetivo  : Trazer as variaveis necessarias para a rotina de alteracoes nas
               telas referentes a tela CONTAS.

   Alteracoes: 06/10/2006 - Incluir o log_nrdctitg (Ze).
   
               11/01/2007 - Criada a procedure atualiza_crapalt porque alguns
                            programas que usam essa include excederam os 64kb
                            permitidos (Evandro).
                            
               13/04/2008 - Retirada dos campos Rec. Arq. Cobranca e Email (Ze)

               18/06/2009 - Ajuste para contemplar novo campo de rendimentos
                            e valores. Variaveis para logar item BENS (Gabriel).
               
               04/12/2009 - Incluido novos campos referentes ao item 
                            "INF. ADICIONAL" da pessoa fisica (Elton).
                            
               16/12/2009 - Eliminada variavel log_cdgrpext (Diego).
               
               20/05/2011 - Substituicao do campo crapenc.nranores por 
                            crapenc.dtinires (data que o cooperado passou a
                            residir no endereco informado). Fabricio
                            
               19/04/2017 - Alteraçao DSNACION pelo campo CDNACION.
                            PRJ339 - CRM (Odirlei-AMcom)
			   20/04/2017 - Ajuste para retirar o uso de campos removidos da tabela
			                crapass, crapttl, crapjur 
							(Adriano - P339).

..............................................................................*/

/* Variaveis genericas da rotina */
DEF        VAR log_confirma AS CHAR    FORMAT "x"                    NO-UNDO.
DEF        VAR log_tpaltera AS INT                                   NO-UNDO.
DEF        VAR log_flgrecad AS LOGICAL                               NO-UNDO.
DEF        VAR log_nmdcampo AS CHAR                                  NO-UNDO.
DEF        VAR log_flgctitg LIKE crapalt.flgctitg                    NO-UNDO.
DEF        VAR log_qtfoltal LIKE crapass.qtfoltal                    NO-UNDO.

/* Variaveis para o log da tela: CONTAS -> CONTA CORRENTE */
DEF        VAR log_cdageass LIKE crapass.cdagenci                    NO-UNDO.
DEF        VAR log_cdtipcta LIKE crapass.cdtipcta                    NO-UNDO.
DEF        VAR log_nrdctitg LIKE crapass.nrdctitg                    NO-UNDO.
DEF        VAR log_cdsitdct LIKE crapass.cdsitdct                    NO-UNDO.
DEF        VAR log_flgiddep LIKE crapass.flgiddep                    NO-UNDO.
DEF        VAR log_tpavsdeb LIKE crapass.tpavsdeb                    NO-UNDO.
DEF        VAR log_tpextcta LIKE crapass.tpextcta                    NO-UNDO.
DEF        VAR log_cdsecext LIKE crapass.cdsecext                    NO-UNDO.
DEF        VAR log_dtcnsspc LIKE crapass.dtcnsspc                    NO-UNDO.

DEF        VAR log_dtcnsscr LIKE crapass.dtcnsscr                    NO-UNDO.
DEF        VAR log_dtdsdspc LIKE crapass.dtdsdspc                    NO-UNDO.
DEF        VAR log_dsinadim AS CHAR                                  NO-UNDO.
DEF        VAR log_dslbacen AS CHAR                                  NO-UNDO.

/* Variaveis para o log da tela: CONTAS -> TELEFONES */
DEF        VAR log_cdopetfn     LIKE craptfc.cdopetfn                NO-UNDO.
DEF        VAR log_nrdddtfc     LIKE craptfc.nrdddtfc                NO-UNDO.
DEF        VAR log_nrtelefo     LIKE craptfc.nrtelefo                NO-UNDO.
DEF        VAR log_nrdramal     LIKE craptfc.nrdramal                NO-UNDO.
DEF        VAR log_tptelefo     LIKE craptfc.tptelefo                NO-UNDO.
DEF        VAR log_secpscto_tfc LIKE craptfc.secpscto                NO-UNDO.
DEF        VAR log_nmpescto_tfc LIKE craptfc.nmpescto                NO-UNDO.

/* Variaveis para o log da tela: CONTAS -> EMAILS */
DEF        VAR log_dsdemail     LIKE crapcem.dsdemail                NO-UNDO.
DEF        VAR log_secpscto_cem LIKE crapcem.secpscto                NO-UNDO.
DEF        VAR log_nmpescto_cem LIKE crapcem.nmpescto                NO-UNDO.

/* Variaveis para o log da tela: CONTAS -> ENDERECO */
DEF        VAR log_incasprp LIKE crapenc.incasprp                    NO-UNDO.
DEF        VAR log_dtinires LIKE crapenc.dtinires                    NO-UNDO.
DEF        VAR log_vlalugue LIKE crapenc.vlalugue                    NO-UNDO.
DEF        VAR log_nrcepend LIKE crapenc.nrcepend                    NO-UNDO.
DEF        VAR log_dsendere LIKE crapenc.dsendere                    NO-UNDO.
DEF        VAR log_nrendere LIKE crapenc.nrendere                    NO-UNDO.
DEF        VAR log_complend LIKE crapenc.complend                    NO-UNDO.
DEF        VAR log_nmbairro LIKE crapenc.nmbairro                    NO-UNDO.
DEF        VAR log_nmcidade LIKE crapenc.nmcidade                    NO-UNDO.
DEF        VAR log_cdufende LIKE crapenc.cdufende                    NO-UNDO.
DEF        VAR log_nrcxapst LIKE crapenc.nrcxapst                    NO-UNDO.

/* Variaveis para o log da tela: CONTAS -> IDENTIFICACAO (juridica) */
DEF        VAR log_nmfansia     LIKE crapjur.nmfansia                NO-UNDO.
DEF        VAR log_natjurid     LIKE crapjur.natjurid                NO-UNDO.
DEF        VAR log_qtfilial     LIKE crapjur.qtfilial                NO-UNDO.
DEF        VAR log_qtfuncio     LIKE crapjur.qtfuncio                NO-UNDO.
DEF        VAR log_dtiniatv     LIKE crapjur.dtiniatv                NO-UNDO.
DEF        VAR log_setecono     LIKE crapjur.cdseteco                NO-UNDO.
DEF        VAR log_cdrmativ     LIKE crapjur.cdrmativ                NO-UNDO.
DEF        VAR log_dsendweb     LIKE crapjur.dsendweb                NO-UNDO.
DEF        VAR log_nmtalttl_jur LIKE crapjur.nmtalttl                NO-UNDO.

/* Variaveis para o log da tela: CONTAS -> REGISTRO (juridica) */
DEF        VAR log_vlfatano LIKE crapjur.vlfatano                    NO-UNDO.
DEF        VAR log_nrinsest LIKE crapjur.nrinsest                    NO-UNDO.
DEF        VAR log_vlcaprea LIKE crapjur.vlcaprea                    NO-UNDO.
DEF        VAR log_dtregemp LIKE crapjur.dtregemp                    NO-UNDO.
DEF        VAR log_nrregemp LIKE crapjur.nrregemp                    NO-UNDO.
DEF        VAR log_orregemp LIKE crapjur.orregemp                    NO-UNDO.
DEF        VAR log_dtinsnum LIKE crapjur.dtinsnum                    NO-UNDO.
DEF        VAR log_nrinsmun LIKE crapjur.nrinsmun                    NO-UNDO.
DEF        VAR log_flgrefis LIKE crapjur.flgrefis                    NO-UNDO.
DEF        VAR log_nrcdnire LIKE crapjur.nrcdnire                    NO-UNDO.

/* Variaveis para o log da tela: CONTAS -> IDENTIFICACAO (fisica) */
DEF        VAR log_dtcnscpf     LIKE crapttl.dtcnscpf                NO-UNDO.
DEF        VAR log_cdsitcpf     LIKE crapttl.cdsitcpf                NO-UNDO.
DEF        VAR log_tpdocttl     LIKE crapttl.tpdocttl                NO-UNDO.
DEF        VAR log_nrdocttl     LIKE crapttl.nrdocttl                NO-UNDO.
DEF        VAR log_cdoedttl     LIKE crapttl.cdoedttl                NO-UNDO.
DEF        VAR log_cdufdttl     LIKE crapttl.cdufdttl                NO-UNDO.
DEF        VAR log_dtemdttl     LIKE crapttl.dtemdttl                NO-UNDO.
DEF        VAR log_dtnasttl     LIKE crapttl.dtnasttl                NO-UNDO.
DEF        VAR log_cdsexotl     LIKE crapttl.cdsexotl                NO-UNDO.
DEF        VAR log_tpnacion     LIKE crapttl.tpnacion                NO-UNDO.
DEF        VAR log_cdnacion     LIKE crapnac.cdnacion                NO-UNDO.
DEF        VAR log_dsnacion     LIKE crapnac.dsnacion                NO-UNDO.
DEF        VAR log_dsnatura     LIKE crapttl.dsnatura                NO-UNDO.
DEF        VAR log_inhabmen     LIKE crapttl.inhabmen                NO-UNDO.
DEF        VAR log_dthabmen     LIKE crapttl.dthabmen                NO-UNDO.
DEF        VAR log_cdgraupr     LIKE crapttl.cdgraupr                NO-UNDO.
DEF        VAR log_cdestcvl     LIKE crapttl.cdestcvl                NO-UNDO.
DEF        VAR log_grescola     LIKE crapttl.grescola                NO-UNDO.
DEF        VAR log_cdfrmttl     LIKE crapttl.cdfrmttl                NO-UNDO.
DEF        VAR log_nmtalttl_ttl LIKE crapttl.nmtalttl                NO-UNDO.

/* Variaveis para o log da tela: CONTAS -> REFERENCIAS (JURIDICA)
                                 CONTAS -> CONTATOS (FISICA)
                                 CONTAS -> RESPONSAVEL LEGAL (FISICA) */
DEF        VAR log_nmdavali     LIKE crapavt.nmdavali                NO-UNDO.
DEF        VAR log_nmextemp     LIKE crapavt.nmextemp                NO-UNDO.
DEF        VAR log_cddbanco     LIKE crapavt.cddbanco                NO-UNDO.
DEF        VAR log_cdagenci     LIKE crapavt.cdagenci                NO-UNDO.
DEF        VAR log_dsproftl     LIKE crapavt.dsproftl                NO-UNDO.
DEF        VAR log_cepender     LIKE crapavt.nrcepend                NO-UNDO.
DEF        VAR log_endereco     LIKE crapavt.dsendres                NO-UNDO.
DEF        VAR log_numender     LIKE crapavt.nrendere                NO-UNDO.
DEF        VAR log_compleme     LIKE crapavt.complend                NO-UNDO.
DEF        VAR log_dsbairro     LIKE crapavt.nmbairro                NO-UNDO.
DEF        VAR log_dscidade     LIKE crapavt.nmcidade                NO-UNDO.
DEF        VAR log_sigladuf     LIKE crapavt.cdufresd                NO-UNDO.
DEF        VAR log_caixapst     LIKE crapavt.nrcxapst                NO-UNDO.
DEF        VAR log_telefone     LIKE crapavt.nrtelefo                NO-UNDO.
DEF        VAR log_endemail     LIKE crapavt.dsdemail                NO-UNDO.
DEF        VAR log_tpdocava     LIKE crapavt.tpdocava                NO-UNDO.
DEF        VAR log_nrdocava     LIKE crapavt.nrdocava                NO-UNDO.
DEF        VAR log_cdoeddoc     LIKE crapavt.cdoeddoc                NO-UNDO.
DEF        VAR log_cdufddoc     LIKE crapavt.cdufddoc                NO-UNDO.
DEF        VAR log_dtemddoc     LIKE crapavt.dtemddoc                NO-UNDO.
DEF        VAR log_dtnascto     LIKE crapavt.dtnascto                NO-UNDO.
DEF        VAR log_cdsexcto     LIKE crapavt.cdsexcto                NO-UNDO.
DEF        VAR log_cdestcvl_avt LIKE crapavt.cdestcvl                NO-UNDO.
DEF        VAR log_cdnacion_avt LIKE crapnac.cdnacion                NO-UNDO.
DEF        VAR log_dsnacion_avt LIKE crapnac.dsnacion                NO-UNDO.
DEF        VAR log_dsnatura_avt LIKE crapavt.dsnatura                NO-UNDO.
DEF        VAR log_nmmaecto     LIKE crapavt.nmmaecto                NO-UNDO.
DEF        VAR log_nmpaicto     LIKE crapavt.nmpaicto                NO-UNDO.

/* Variaveis para log da tela: CONTAS -> CONJUGE (fisica) */
DEF        VAR log_nrctacje LIKE crapcje.nrctacje                    NO-UNDO.
DEF        VAR log_nrcpfcjg LIKE crapcje.nrcpfcjg                    NO-UNDO.
DEF        VAR log_nmconjug LIKE crapcje.nmconjug                    NO-UNDO. 
DEF        VAR log_dtnasccj LIKE crapcje.dtnasccj                    NO-UNDO.
DEF        VAR log_tpdoccje LIKE crapcje.tpdoccje                    NO-UNDO.
DEF        VAR log_nrdoccje LIKE crapcje.nrdoccje                    NO-UNDO.
DEF        VAR log_cdoedcje LIKE crapcje.cdoedcje                    NO-UNDO.
DEF        VAR log_cdufdcje LIKE crapcje.cdufdcje                    NO-UNDO.
DEF        VAR log_dtemdcje LIKE crapcje.dtemdcje                    NO-UNDO.
DEF        VAR log_gresccjg LIKE crapcje.grescola                    NO-UNDO.
DEF        VAR log_cdfrmcje LIKE crapcje.cdfrmttl                    NO-UNDO.
DEF        VAR log_cdnatopc LIKE crapcje.cdnatopc                    NO-UNDO.
DEF        VAR log_cdocpttl LIKE crapcje.cdocpcje                    NO-UNDO.
DEF        VAR log_tpcttrab LIKE crapcje.tpcttrab                    NO-UNDO.
DEF        VAR log_nmempcje LIKE crapcje.nmextemp                    NO-UNDO.
DEF        VAR log_nrcpfemp LIKE crapcje.nrdocnpj                    NO-UNDO.
DEF        VAR log_dsprocje LIKE crapcje.dsproftl                    NO-UNDO.
DEF        VAR log_cdnvlcgo LIKE crapcje.cdnvlcgo                    NO-UNDO.
DEF        VAR log_nrfonemp LIKE crapcje.nrfonemp                    NO-UNDO.
DEF        VAR log_nrramemp LIKE crapcje.nrramemp                    NO-UNDO.
DEF        VAR log_cdturnos LIKE crapcje.cdturnos                    NO-UNDO.
DEF        VAR log_dtadmemp LIKE crapcje.dtadmemp                    NO-UNDO.
DEF        VAR log_vlsalari LIKE crapcje.vlsalari                    NO-UNDO.

/* Variaveis para log da tela: CONTAS -> DEPENDENTES */
DEF        VAR log_dtnascim LIKE crapdep.dtnascto                    NO-UNDO.
DEF        VAR log_cdtipdep LIKE crapdep.tpdepend                    NO-UNDO.

/* Variaveis para log da tela: CONTAS -> COMERCIAL */
DEF        VAR log_cdnatopc_ttl LIKE crapttl.cdnatopc                NO-UNDO.
DEF        VAR log_cdocpttl_tll LIKE crapttl.cdocpttl                NO-UNDO.
DEF        VAR log_tpcttrab_ttl LIKE crapttl.tpcttrab                NO-UNDO.
DEF        VAR log_nmextemp_ttl LIKE crapttl.nmextemp                NO-UNDO.
DEF        VAR log_nrcpfemp_ttl LIKE crapttl.nrcpfemp                NO-UNDO.
DEF        VAR log_dsproftl_ttl LIKE crapttl.dsproftl                NO-UNDO.
DEF        VAR log_cdnvlcgo_ttl LIKE crapttl.cdnvlcgo                NO-UNDO.
DEF        VAR log_cdturnos_ttl LIKE crapttl.cdturnos                NO-UNDO.
DEF        VAR log_dtadmemp_ttl LIKE crapttl.dtadmemp                NO-UNDO.
DEF        VAR log_vlsalari_ttl LIKE crapttl.vlsalari                NO-UNDO.
DEF        VAR log_cdempres     LIKE crapttl.cdempres                NO-UNDO.
DEF        VAR log_nrcadast     LIKE crapttl.nrcadast                NO-UNDO.
DEF        VAR log_cdtipren     LIKE crapttl.tpdrendi                NO-UNDO.
DEF        VAR log_vlrendim     LIKE crapttl.vldrendi                NO-UNDO.

/* Variaveis para log da tela: CONTAS -> BENS */
DEF        VAR log_dsrelbem     LIKE crapbem.dsrelbem                NO-UNDO.
DEF        VAR log_persemon     LIKE crapbem.persemon                NO-UNDO.
DEF        VAR log_qtprebem     LIKE crapbem.qtprebem                NO-UNDO.
DEF        VAR log_vlprebem     LIKE crapbem.vlprebem                NO-UNDO.
DEF        VAR log_vlrdobem     LIKE crapbem.vlrdobem                NO-UNDO.

/* Variaveis de faturamento : CONTAS -> JURIDICA */
DEF        VAR log_perfatcl     LIKE crapjfn.perfatcl                NO-UNDO.
DEF        VAR log_mesftbru     LIKE crapjfn.mesftbru                NO-UNDO.
DEF        VAR log_anoftbru     LIKE crapjfn.anoftbru                NO-UNDO.
DEF        VAR log_vlrftbru     LIKE crapjfn.vlrftbru                NO-UNDO.

/* Variaveis para log da tela: CONTAS -> INF. CADASTRAL - FISICA */
DEF        VAR log_nrinfcad     LIKE crapttl.nrinfcad                NO-UNDO.
DEF        VAR log_nrpatlvr     LIKE crapttl.nrpatlvr                NO-UNDO.


PROCEDURE atualiza_crapalt:
    
    ASSIGN crapalt.flgctitg = log_flgctitg
           crapalt.cdoperad = glb_cdoperad
           crapalt.dsaltera = crapalt.dsaltera + log_nmdcampo + ",".
 
END PROCEDURE.
/*..........................................................................*/
