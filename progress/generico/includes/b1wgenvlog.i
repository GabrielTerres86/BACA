/* .............................................................................

   Programa: sistema/generico/includes/b1wgenvlog.i (var_logcontas.i)
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
               
               01/03/2010 - Adaptar para uso das BO's (Jose Luis).
               
               11/03/2011 - Retirar campo dsdemail e inarqcbr da crapass
                           (Gabriel).
                           
               20/05/2011 - Substituicao do campo crapenc.nranores por 
                            crapenc.dtinires (data que o cooperado passou a
                            residir no endereco informado). Fabricio 
                            
               13/06/2011 - Incluir campo de 'Pessoa politicamente Exposta'
                            (Gabriel).           
                            
               05/07/2011 - Incluidas as variaveis log_nrdoapto e log_cddbloco                    
                            (Henrique).
                            
               02/12/2011 - Incluido a variavel log_dsjusren (Adriano).
               
               13/04/2012 - Incluido variaveis para logar a crapcrl - Respons.
                            Legal (Adriano).
                            
               29/04/2013 - Alterado campo crapass.dsnatura por crapttl.dsnatura
                            (Lucas R.)
                            
               30/09/2013 - Removido campo log_nrfonres. (Reinert)

               16/05/2014 - Alterado o LIKE do log_cdestcvl, log_vlsalari de
                            crapass para crapttl. (Douglas - Chamado 131253)
                            
               10/06/2014 - (Chamado 117414) - Troca do campo crapass.nmconjug por crapcje.nmconjug
                            (Tiago Castro - RKAM).

               05/01/2015 - Incluido variavel log_flgrenli. (James)
               
               27/10/2015 - Incluido campo log_idastcjt, Prj. 131 - Assinatura Conjunta.(Jean Michel)

               29/02/2016 - Trocando o campo flpolexp para inpolexp conforme
                            solicitado no chamado 402159 (Kelvin)
			   20/04/2017 - Ajuste para retirar o uso de campos removidos da tabela
			                crapass, crapttl, crapjur 
							(Adriano - P339).

.............................................................................*/

&IF DEFINED(VAR-GERAL) <> 0 &THEN
    /* Variaveis de uso geral */
    DEF VAR aux_tpatlcad AS INTE                                      NO-UNDO.
    DEF VAR aux_msgatcad AS CHAR                                      NO-UNDO.
    DEF VAR aux_chavealt AS CHAR                                      NO-UNDO.
    DEF VAR aux_msgrecad AS CHAR                                      NO-UNDO.
&ENDIF

&IF DEFINED(SESSAO-BO) <> 0 &THEN
    /* Variaveis genericas da rotina */

    DEF        VAR aux_flgnvalt AS LOG                                NO-UNDO.
    DEF        VAR log_flaltera AS LOG                                NO-UNDO.
    DEF        VAR log_confirma AS CHAR    FORMAT "x"                 NO-UNDO.
    DEF        VAR log_tpaltera AS INT                                NO-UNDO.
    DEF        VAR log_flgrecad AS LOGICAL                            NO-UNDO.
    DEF        VAR log_msgrecad AS CHAR                               NO-UNDO.
    DEF        VAR log_nmdcampo AS CHAR                               NO-UNDO.
    DEF        VAR log_flgctitg LIKE crapalt.flgctitg                 NO-UNDO.
    DEF        VAR log_qtfoltal LIKE crapass.qtfoltal                 NO-UNDO.
    DEF        VAR par_dsvarlog AS CHAR                               NO-UNDO.
    
    DEF        VAR log_chavealt AS CHAR                               NO-UNDO.
    DEF        VAR log_contador AS INTE                               NO-UNDO.
    DEF        VAR log_cddopcao AS CHAR                               NO-UNDO.
    DEF        VAR log_cdcooper AS INTE                               NO-UNDO.
    DEF        VAR log_nrdconta AS INTE                               NO-UNDO.
    DEF        VAR log_idseqttl AS INTE                               NO-UNDO.
    DEF        VAR log_dtmvtolt AS DATE                               NO-UNDO.
    DEF        VAR log_nmavalis AS CHAR                               NO-UNDO.
    DEF        VAR log_nmdatela AS CHAR                               NO-UNDO.
    DEF        VAR log_cdoperad AS CHAR                               NO-UNDO.
    DEF        VAR log_tpatlcad AS INTE                               NO-UNDO.
    DEF        VAR log_msgatcad AS CHAR                               NO-UNDO.
    DEF        VAR log_dtaltera AS DATE                               NO-UNDO.

    &IF DEFINED(TELA-MANTAL) <> 0 &THEN
    
        DEF        VAR log_nrdctabb LIKE crapass.nrdconta              NO-UNDO.
        DEF        VAR log_nrdocmto LIKE crapcst.nrcheque              NO-UNDO.
        DEF        VAR log_desopcao AS CHARACTER  FORMAT "x(11)"       NO-UNDO.
        DEF        VAR log_qtletras AS INTEGER                         NO-UNDO.
        DEF        VAR log_qtlinhas AS INTEGER                         NO-UNDO.
    
    &ENDIF
    
    &IF DEFINED(TELA-MATRIC) <> 0 &THEN
    
       /* Variaveis de recadastramento (geram tipo de alteracao 1) */
       
       DEF VAR aux_nmconjug1 LIKE crapcje.nmconjug NO-UNDO.
       DEF VAR aux_dtnasccj LIKE crapcje.dtnasccj NO-UNDO.
       DEF VAR aux_dsendcom LIKE crapcje.dsendcom NO-UNDO.

       DEF        VAR log_qtletras AS INTEGER                         NO-UNDO.
       DEF        VAR log_qtlinhas AS INTEGER                         NO-UNDO.

       DEF        VAR log_nmprimtl LIKE crapass.nmprimtl              NO-UNDO.
       DEF        VAR log_dtnasctl LIKE crapass.dtnasctl              NO-UNDO.
       DEF        VAR log_nrcpfcgc LIKE crapass.nrcpfcgc              NO-UNDO.
       DEF        VAR log_dsnacion LIKE crapass.dsnacion              NO-UNDO.
       DEF        VAR log_cdestcvl LIKE crapttl.cdestcvl              NO-UNDO.
       DEF        VAR log_dsproftl LIKE crapass.dsproftl              NO-UNDO.
       DEF        VAR log_tpdocptl LIKE crapass.tpdocptl              NO-UNDO.
       DEF        VAR log_nrdocptl LIKE crapass.nrdocptl              NO-UNDO.
       DEF        VAR log_dsnatura LIKE crapttl.dsnatura              NO-UNDO.
       DEF        VAR log_cdufnatu LIKE crapttl.cdufnatu              NO-UNDO.
       DEF        VAR log_cdsexotl LIKE crapass.cdsexotl              NO-UNDO.
       DEF        VAR log_dsfiliac LIKE crapass.dsfiliac              NO-UNDO.
       DEF        VAR log_nmconjug LIKE crapcje.nmconjug              NO-UNDO.
       DEF        VAR log_dtcnscpf LIKE crapass.dtcnscpf              NO-UNDO.
       DEF        VAR log_cdsitcpf LIKE crapass.cdsitcpf              NO-UNDO.
       DEF        VAR log_nrdctitg LIKE crapass.nrdctitg              NO-UNDO.
       DEF        VAR log_nmpaiptl LIKE crapass.nmpaiptl              NO-UNDO.
       DEF        VAR log_nmmaeptl LIKE crapass.nmmaeptl              NO-UNDO.
       DEF        VAR log_tpnacion LIKE crapttl.tpnacion              NO-UNDO.
       DEF        VAR log_cdocpttl LIKE crapttl.cdocpttl              NO-UNDO.

       /* Endereco */
       DEF        VAR log_nrcepend LIKE crapenc.nrcepend              NO-UNDO.
       DEF        VAR log_dsendere LIKE crapenc.dsendere              NO-UNDO.
       DEF        VAR log_nrendere LIKE crapenc.nrendere              NO-UNDO.
       DEF        VAR log_complend LIKE crapenc.complend              NO-UNDO.
       DEF        VAR log_nmbairro LIKE crapenc.nmbairro              NO-UNDO.
       DEF        VAR log_nmcidade LIKE crapenc.nmcidade              NO-UNDO.
       DEF        VAR log_cdufende LIKE crapenc.cdufende              NO-UNDO.
       DEF        VAR log_nrcxapst LIKE crapenc.nrcxapst              NO-UNDO.
       DEF        VAR log_incasprp LIKE crapenc.incasprp              NO-UNDO.
       DEF        VAR log_vlalugue LIKE crapenc.vlalugue              NO-UNDO.
       DEF        VAR log_dtinires LIKE crapenc.dtinires              NO-UNDO.


       /* Dados de pessoa juridica */
       DEF        VAR log_dtiniatv LIKE crapjur.dtiniatv              NO-UNDO.
       DEF        VAR log_natjurid LIKE crapjur.natjurid              NO-UNDO.
       DEF        VAR log_nmfansia LIKE crapjur.nmfansia              NO-UNDO.
       DEF        VAR log_nrinsest LIKE crapjur.nrinsest              NO-UNDO.
       DEF        VAR log_cdrmativ LIKE crapjur.cdrmativ              NO-UNDO.
       DEF        VAR log_cdseteco LIKE crapjur.cdseteco              NO-UNDO.

       /* Telefone */
       DEF        VAR log_nrdddtfc LIKE craptfc.nrdddtfc              NO-UNDO.
       DEF        VAR log_nrtelefo LIKE craptfc.nrtelefo              NO-UNDO.

       /* Variaveis de manutencao do log (geram tipo de alteracao 2) */

       DEF        VAR log_cdagenci LIKE crapass.cdagenci              NO-UNDO.
       DEF        VAR log_cdempres LIKE crapttl.cdempres              NO-UNDO.
       DEF        VAR log_nrcadast LIKE crapass.nrcadast              NO-UNDO.
       DEF        VAR log_dtdemiss LIKE crapass.dtdemiss              NO-UNDO.
       DEF        VAR log_dtnasccj LIKE crapcje.dtnasccj              NO-UNDO.
       DEF        VAR log_dsendcom LIKE crapcje.dsendcom              NO-UNDO.
       DEF        VAR log_dtadmemp LIKE crapass.dtadmemp              NO-UNDO.
       DEF        VAR log_cdturnos LIKE crapttl.cdturnos              NO-UNDO.
       DEF        VAR log_nrfonemp LIKE craptfc.nrtelefo              NO-UNDO.
       DEF        VAR log_nrramemp LIKE crapass.nrramemp              NO-UNDO.
       DEF        VAR log_nrctacto LIKE crapass.nrctacto              NO-UNDO.
       DEF        VAR log_nrctaprp LIKE crapass.nrctaprp              NO-UNDO.
       DEF        VAR log_cdtipcta LIKE crapass.cdtipcta              NO-UNDO.
       DEF        VAR log_cdsitdct LIKE crapass.cdsitdct              NO-UNDO.
       DEF        VAR log_cdsecext LIKE crapass.cdsecext              NO-UNDO.
       DEF        VAR log_cdgraupr LIKE crapttl.cdgraupr              NO-UNDO.
       DEF        VAR log_dtcnsspc LIKE crapass.dtcnsspc              NO-UNDO.
       DEF        VAR log_dtdsdspc LIKE crapass.dtdsdspc              NO-UNDO.
       DEF        VAR log_inadimpl LIKE crapass.inadimpl              NO-UNDO.
       DEF        VAR log_inlbacen LIKE crapass.inlbacen              NO-UNDO.
       DEF        VAR log_tpextcta LIKE crapass.tpextcta              NO-UNDO.
       DEF        VAR log_cddsenha LIKE crapsnh.cddsenha              NO-UNDO.
       DEF        VAR log_cdoedptl LIKE crapass.cdoedptl              NO-UNDO.
       DEF        VAR log_cdufdptl LIKE crapass.cdufdptl              NO-UNDO.
       DEF        VAR log_inhabmen LIKE crapttl.inhabmen              NO-UNDO.
       DEF        VAR log_dtemdptl LIKE crapass.dtemdptl              NO-UNDO.
       DEF        VAR log_vlsalari LIKE crapttl.vlsalari              NO-UNDO.
       DEF        VAR log_cdsitdtl LIKE crapass.cdsitdtl              NO-UNDO.
       DEF        VAR log_tpavsdeb LIKE crapass.tpavsdeb              NO-UNDO.
       DEF        VAR log_nrdctabb LIKE crapass.nrdconta              NO-UNDO.
       DEF        VAR log_nrdocmto LIKE crapcst.nrcheque              NO-UNDO.
       DEF        VAR log_desopcao AS CHARACTER  FORMAT "x(11)"       NO-UNDO.
       DEF        VAR log_flgiddep LIKE crapass.flgiddep              NO-UNDO.
    
       /* variaveis de log da tela MANEXT */ 
       DEF        VAR log_cddemail LIKE crapcex.cddemail              NO-UNDO.
       DEF        VAR log_cdperiod LIKE crapcex.cdperiod              NO-UNDO.
       DEF        VAR log_cdrefere LIKE crapcex.cdrefere              NO-UNDO.
       DEF        VAR log_nmpessoa LIKE crapcex.nmpessoa              NO-UNDO.
       DEF        VAR log_tpextrat LIKE crapcex.tpextrat              NO-UNDO.

       /* variaveis de log da tela EMAIL */
       DEF        VAR log_codemail LIKE crapcem.cddemail              NO-UNDO.
       DEF        VAR log_desemail LIKE crapcem.dsdemail              NO-UNDO.

       /* variaveis de log da tela CADSPC */
       DEF        VAR log_dtvencto LIKE crapspc.dtvencto              NO-UNDO.
       DEF        VAR log_vldivida LIKE crapspc.vldivida              NO-UNDO.
       DEF        VAR log_dtinclus LIKE crapspc.dtinclus              NO-UNDO.
       DEF        VAR log_dtdbaixa LIKE crapspc.dtdbaixa              NO-UNDO.
       DEF        VAR log_dsoberv1 LIKE crapspc.dsoberva              NO-UNDO.
       DEF        VAR log_dsoberv2 LIKE crapspc.dsobsbxa              NO-UNDO.
    &ENDIF

    &IF DEFINED(TELA-CONTAS) = 0 &THEN
        /* Variaveis para o log da tela: CONTAS -> CONTA CORRENTE */
        DEF        VAR log_cdageass LIKE crapass.cdagenci             NO-UNDO.
        DEF        VAR log_cdtipcta LIKE crapass.cdtipcta             NO-UNDO.
        DEF        VAR log_nrdctitg LIKE crapass.nrdctitg             NO-UNDO.
        DEF        VAR log_cdsitdct LIKE crapass.cdsitdct             NO-UNDO.
        DEF        VAR log_flgiddep LIKE crapass.flgiddep             NO-UNDO.
        DEF        VAR log_tpavsdeb LIKE crapass.tpavsdeb             NO-UNDO.
        DEF        VAR log_tpextcta LIKE crapass.tpextcta             NO-UNDO.
        DEF        VAR log_cdsecext LIKE crapass.cdsecext             NO-UNDO.
        DEF        VAR log_dtcnsspc LIKE crapass.dtcnsspc             NO-UNDO.
        DEF        VAR log_flgrenli LIKE crapass.flgrenli             NO-UNDO.
        DEF        VAR log_idastcjt LIKE crapass.idastcjt             NO-UNDO.
        
        DEF        VAR log_dtcnsscr LIKE crapass.dtcnsscr             NO-UNDO.
        DEF        VAR log_dtdsdspc LIKE crapass.dtdsdspc             NO-UNDO.
        DEF        VAR log_dsinadim AS CHAR                           NO-UNDO.
        DEF        VAR log_dslbacen AS CHAR                           NO-UNDO.
        
        /* Variaveis para o log da tela: CONTAS -> TELEFONES */
        DEF        VAR log_cdopetfn     LIKE craptfc.cdopetfn         NO-UNDO.
        DEF        VAR log_nrdddtfc     LIKE craptfc.nrdddtfc         NO-UNDO.
        DEF        VAR log_nrtelefo     LIKE craptfc.nrtelefo         NO-UNDO.
        DEF        VAR log_nrdramal     LIKE craptfc.nrdramal         NO-UNDO.
        DEF        VAR log_tptelefo     LIKE craptfc.tptelefo         NO-UNDO.
        DEF        VAR log_secpscto_tfc LIKE craptfc.secpscto         NO-UNDO.
        DEF        VAR log_nmpescto_tfc LIKE craptfc.nmpescto         NO-UNDO.
        
        /* Variaveis para o log da tela: CONTAS -> EMAILS */
        DEF        VAR log_dsdemail     LIKE crapcem.dsdemail         NO-UNDO.
        DEF        VAR log_secpscto_cem LIKE crapcem.secpscto         NO-UNDO.
        DEF        VAR log_nmpescto_cem LIKE crapcem.nmpescto         NO-UNDO.
        
        /* Variaveis para o log da tela: CONTAS -> ENDERECO */
        DEF        VAR log_incasprp LIKE crapenc.incasprp             NO-UNDO.
        DEF        VAR log_dtinires LIKE crapenc.dtinires             NO-UNDO.
        DEF        VAR log_vlalugue LIKE crapenc.vlalugue             NO-UNDO.
        DEF        VAR log_nrcepend LIKE crapenc.nrcepend             NO-UNDO.
        DEF        VAR log_dsendere LIKE crapenc.dsendere             NO-UNDO.
        DEF        VAR log_nrendere LIKE crapenc.nrendere             NO-UNDO.
        DEF        VAR log_complend LIKE crapenc.complend             NO-UNDO.
        DEF        VAR log_nrdoapto LIKE crapenc.nrdoapto             NO-UNDO. 
        DEF        VAR log_cddbloco LIKE crapenc.cddbloco             NO-UNDO. 
        DEF        VAR log_nmbairro LIKE crapenc.nmbairro             NO-UNDO.
        DEF        VAR log_nmcidade LIKE crapenc.nmcidade             NO-UNDO.
        DEF        VAR log_cdufende LIKE crapenc.cdufende             NO-UNDO.
        DEF        VAR log_nrcxapst LIKE crapenc.nrcxapst             NO-UNDO.
        DEF        VAR log_flencnet AS LOGI                           NO-UNDO.
        
        /* Variaveis para o log da tela: CONTAS -> IDENTIFICACAO (juridica) */
        DEF        VAR log_nmfansia     LIKE crapjur.nmfansia         NO-UNDO.
        DEF        VAR log_natjurid     LIKE crapjur.natjurid         NO-UNDO.
        DEF        VAR log_qtfilial     LIKE crapjur.qtfilial         NO-UNDO.
        DEF        VAR log_qtfuncio     LIKE crapjur.qtfuncio         NO-UNDO.
        DEF        VAR log_dtiniatv     LIKE crapjur.dtiniatv         NO-UNDO.
        DEF        VAR log_setecono     LIKE crapjur.cdseteco         NO-UNDO.
        DEF        VAR log_cdrmativ     LIKE crapjur.cdrmativ         NO-UNDO.
        DEF        VAR log_dsendweb     LIKE crapjur.dsendweb         NO-UNDO.
        DEF        VAR log_nmtalttl_jur LIKE crapjur.nmtalttl         NO-UNDO.
        
        /* Variaveis para o log da tela: CONTAS -> REGISTRO (juridica) */
        DEF        VAR log_vlfatano LIKE crapjur.vlfatano             NO-UNDO.
        DEF        VAR log_nrinsest LIKE crapjur.nrinsest             NO-UNDO.
      
        DEF        VAR log_vlcaprea LIKE crapjur.vlcaprea             NO-UNDO.
        DEF        VAR log_dtregemp LIKE crapjur.dtregemp             NO-UNDO.
        DEF        VAR log_nrregemp LIKE crapjur.nrregemp             NO-UNDO.
        DEF        VAR log_orregemp LIKE crapjur.orregemp             NO-UNDO.
        DEF        VAR log_dtinsnum LIKE crapjur.dtinsnum             NO-UNDO.
        DEF        VAR log_nrinsmun LIKE crapjur.nrinsmun             NO-UNDO.
        DEF        VAR log_flgrefis LIKE crapjur.flgrefis             NO-UNDO.
        DEF        VAR log_nrcdnire LIKE crapjur.nrcdnire             NO-UNDO.
        
        /* Variaveis para o log da tela: CONTAS -> IDENTIFICACAO (fisica) */
        DEF        VAR log_dtcnscpf     LIKE crapttl.dtcnscpf         NO-UNDO.
        DEF        VAR log_cdsitcpf     LIKE crapttl.cdsitcpf         NO-UNDO.
        DEF        VAR log_tpdocttl     LIKE crapttl.tpdocttl         NO-UNDO.
        DEF        VAR log_nrdocttl     LIKE crapttl.nrdocttl         NO-UNDO.
        DEF        VAR log_cdoedttl     LIKE crapttl.cdoedttl         NO-UNDO.
        DEF        VAR log_cdufdttl     LIKE crapttl.cdufdttl         NO-UNDO.
        DEF        VAR log_dtemdttl     LIKE crapttl.dtemdttl         NO-UNDO.
        DEF        VAR log_dtnasttl     LIKE crapttl.dtnasttl         NO-UNDO.
        DEF        VAR log_cdsexotl     LIKE crapttl.cdsexotl         NO-UNDO.
        DEF        VAR log_tpnacion     LIKE crapttl.tpnacion         NO-UNDO.
        DEF        VAR log_dsnacion     LIKE crapttl.dsnacion         NO-UNDO.
        DEF        VAR log_dsnatura     LIKE crapttl.dsnatura         NO-UNDO.
        DEF        VAR log_cdufnatu     LIKE crapttl.cdufnatu         NO-UNDO.
        DEF        VAR log_inhabmen     LIKE crapttl.inhabmen         NO-UNDO.
        DEF        VAR log_dthabmen     LIKE crapttl.dthabmen         NO-UNDO.
        DEF        VAR log_cdgraupr     LIKE crapttl.cdgraupr         NO-UNDO.
        DEF        VAR log_cdestcvl     LIKE crapttl.cdestcvl         NO-UNDO.
        DEF        VAR log_grescola     LIKE crapttl.grescola         NO-UNDO.
        DEF        VAR log_cdfrmttl     LIKE crapttl.cdfrmttl         NO-UNDO.
        DEF        VAR log_nmtalttl_ttl LIKE crapttl.nmtalttl         NO-UNDO.
        DEF        VAR log_inpolexp     LIKE crapttl.inpolexp         NO-UNDO.
        
        /* Variaveis para o log da tela: CONTAS -> REFERENCIAS (JURIDICA)
                                         CONTAS -> CONTATOS (FISICA) */
        DEF        VAR log_nrdctato     LIKE crapavt.nrdctato         NO-UNDO.
        DEF        VAR log_nmdavali     LIKE crapavt.nmdavali         NO-UNDO.
        DEF        VAR log_nmextemp     LIKE crapavt.nmextemp         NO-UNDO.
        DEF        VAR log_cddbanco     LIKE crapavt.cddbanco         NO-UNDO.
        DEF        VAR log_cdagenci     LIKE crapavt.cdagenci         NO-UNDO.
        DEF        VAR log_dsproftl     LIKE crapavt.dsproftl         NO-UNDO.
        DEF        VAR log_cepender     LIKE crapavt.nrcepend         NO-UNDO.
        DEF        VAR log_endereco     LIKE crapavt.dsendres         NO-UNDO.
        DEF        VAR log_numender     LIKE crapavt.nrendere         NO-UNDO.
        DEF        VAR log_compleme     LIKE crapavt.complend         NO-UNDO.
        DEF        VAR log_dsbairro     LIKE crapavt.nmbairro         NO-UNDO.
        DEF        VAR log_dscidade     LIKE crapavt.nmcidade         NO-UNDO.
        DEF        VAR log_sigladuf     LIKE crapavt.cdufresd         NO-UNDO.
        DEF        VAR log_caixapst     LIKE crapavt.nrcxapst         NO-UNDO.
        DEF        VAR log_telefone     LIKE crapavt.nrtelefo         NO-UNDO.
        DEF        VAR log_endemail     LIKE crapavt.dsdemail         NO-UNDO.
        DEF        VAR log_tpdocava     LIKE crapavt.tpdocava         NO-UNDO.
        DEF        VAR log_nrdocava     LIKE crapavt.nrdocava         NO-UNDO.
        DEF        VAR log_cdoeddoc     LIKE crapavt.cdoeddoc         NO-UNDO.
        DEF        VAR log_cdufddoc     LIKE crapavt.cdufddoc         NO-UNDO.
        DEF        VAR log_dtemddoc     LIKE crapavt.dtemddoc         NO-UNDO.
        DEF        VAR log_dtnascto     LIKE crapavt.dtnascto         NO-UNDO.
        DEF        VAR log_cdsexcto     LIKE crapavt.cdsexcto         NO-UNDO.
        DEF        VAR log_cdestcvl_avt LIKE crapavt.cdestcvl         NO-UNDO.
        DEF        VAR log_dsnacion_avt LIKE crapavt.dsnacion         NO-UNDO.
        DEF        VAR log_dsnatura_avt LIKE crapavt.dsnatura         NO-UNDO.
        DEF        VAR log_nmmaecto     LIKE crapavt.nmmaecto         NO-UNDO.
        DEF        VAR log_nmpaicto     LIKE crapavt.nmpaicto         NO-UNDO.


        /* Variaveis para log da tela: CONTAS -> RESPONSAVEL LEGAL(FISICA)*/
        DEF        VAR log_cdcooper_crl LIKE crapcrl.cdcooper         NO-UNDO.
        DEF        VAR log_nrctamen_crl LIKE crapcrl.nrctamen         NO-UNDO.
        DEF        VAR log_nrcpfmen_crl LIKE crapcrl.nrcpfmen         NO-UNDO.
        DEF        VAR log_idseqmen_crl LIKE crapcrl.idseqmen         NO-UNDO.
        DEF        VAR log_nrdconta_crl LIKE crapcrl.nrdconta         NO-UNDO.
        DEF        VAR log_nrcpfcgc_crl LIKE crapcrl.nrcpfcgc         NO-UNDO.
        DEF        VAR log_nmrespon_crl LIKE crapcrl.nmrespon         NO-UNDO.
        DEF        VAR log_nridenti_crl LIKE crapcrl.nridenti         NO-UNDO.
        DEF        VAR log_tpdeiden_crl LIKE crapcrl.tpdeiden         NO-UNDO.
        DEF        VAR log_dsorgemi_crl LIKE crapcrl.dsorgemi         NO-UNDO.
        DEF        VAR log_cdufiden_crl LIKE crapcrl.cdufiden         NO-UNDO.
        DEF        VAR log_dtemiden_crl LIKE crapcrl.dtemiden         NO-UNDO.
        DEF        VAR log_dtnascin_crl LIKE crapcrl.dtnascin         NO-UNDO.
        DEF        VAR log_cddosexo_crl LIKE crapcrl.cddosexo         NO-UNDO.
        DEF        VAR log_cdestciv_crl LIKE crapcrl.cdestciv         NO-UNDO.
        DEF        VAR log_dsnacion_crl LIKE crapcrl.dsnacion         NO-UNDO.
        DEF        VAR log_dsnatura_crl LIKE crapcrl.dsnatura         NO-UNDO.
        DEF        VAR log_cdcepres_crl LIKE crapcrl.cdcepres         NO-UNDO.
        DEF        VAR log_dsendres_crl LIKE crapcrl.dsendres         NO-UNDO.
        DEF        VAR log_nrendres_crl LIKE crapcrl.nrendres         NO-UNDO.
        DEF        VAR log_dscomres_crl LIKE crapcrl.dscomres         NO-UNDO.
        DEF        VAR log_dsbaires_crl LIKE crapcrl.dsbaires         NO-UNDO.
        DEF        VAR log_nrcxpost_crl LIKE crapcrl.nrcxpost         NO-UNDO.
        DEF        VAR log_dscidres_crl LIKE crapcrl.dscidres         NO-UNDO.
        DEF        VAR log_dsdufres_crl LIKE crapcrl.dsdufres         NO-UNDO.
        DEF        VAR log_nmpairsp_crl LIKE crapcrl.nmpairsp         NO-UNDO.
        DEF        VAR log_nmmaersp_crl LIKE crapcrl.nmmaersp         NO-UNDO.

        
        /* Variaveis para log da tela: CONTAS -> CONJUGE (fisica) */
        DEF        VAR log_nrctacje LIKE crapcje.nrctacje            NO-UNDO.
        DEF        VAR log_nrcpfcjg LIKE crapcje.nrcpfcjg            NO-UNDO.
        DEF        VAR log_nmconjug LIKE crapcje.nmconjug            NO-UNDO. 
        DEF        VAR log_dtnasccj LIKE crapcje.dtnasccj            NO-UNDO.
        DEF        VAR log_tpdoccje LIKE crapcje.tpdoccje            NO-UNDO.
        DEF        VAR log_nrdoccje LIKE crapcje.nrdoccje            NO-UNDO.
        DEF        VAR log_cdoedcje LIKE crapcje.cdoedcje            NO-UNDO.
        DEF        VAR log_cdufdcje LIKE crapcje.cdufdcje            NO-UNDO.
        DEF        VAR log_dtemdcje LIKE crapcje.dtemdcje            NO-UNDO.
        DEF        VAR log_gresccjg LIKE crapcje.grescola            NO-UNDO.
        DEF        VAR log_cdfrmcje LIKE crapcje.cdfrmttl            NO-UNDO.
        DEF        VAR log_cdnatopc LIKE crapcje.cdnatopc            NO-UNDO.
        DEF        VAR log_cdocpttl LIKE crapcje.cdocpcje            NO-UNDO.
        DEF        VAR log_tpcttrab LIKE crapcje.tpcttrab            NO-UNDO.
        DEF        VAR log_nmempcje LIKE crapcje.nmextemp            NO-UNDO.
        DEF        VAR log_nrcpfemp LIKE crapcje.nrdocnpj            NO-UNDO.
        DEF        VAR log_dsprocje LIKE crapcje.dsproftl            NO-UNDO.
        DEF        VAR log_cdnvlcgo LIKE crapcje.cdnvlcgo            NO-UNDO.
        DEF        VAR log_nrfonemp LIKE crapcje.nrfonemp            NO-UNDO.
        DEF        VAR log_nrramemp LIKE crapcje.nrramemp            NO-UNDO.
        DEF        VAR log_cdturnos LIKE crapcje.cdturnos            NO-UNDO.
        DEF        VAR log_dtadmemp LIKE crapcje.dtadmemp            NO-UNDO.
        DEF        VAR log_vlsalari LIKE crapcje.vlsalari            NO-UNDO.
        
        /* Variaveis para log da tela: CONTAS -> DEPENDENTES */
        DEF        VAR log_dtnascim LIKE crapdep.dtnascto            NO-UNDO.
        DEF        VAR log_cdtipdep LIKE crapdep.tpdepend            NO-UNDO.
        
        /* Variaveis para log da tela: CONTAS -> COMERCIAL */
        DEF        VAR log_cdnatopc_ttl LIKE crapttl.cdnatopc        NO-UNDO.
        DEF        VAR log_cdocpttl_tll LIKE crapttl.cdocpttl        NO-UNDO.
        DEF        VAR log_tpcttrab_ttl LIKE crapttl.tpcttrab        NO-UNDO.
        DEF        VAR log_nmextemp_ttl LIKE crapttl.nmextemp        NO-UNDO.
        DEF        VAR log_nrcpfemp_ttl LIKE crapttl.nrcpfemp        NO-UNDO.
        DEF        VAR log_dsproftl_ttl LIKE crapttl.dsproftl        NO-UNDO.
        DEF        VAR log_cdnvlcgo_ttl LIKE crapttl.cdnvlcgo        NO-UNDO.
        DEF        VAR log_cdturnos_ttl LIKE crapttl.cdturnos        NO-UNDO.
        DEF        VAR log_dtadmemp_ttl LIKE crapttl.dtadmemp        NO-UNDO.
        DEF        VAR log_vlsalari_ttl LIKE crapttl.vlsalari        NO-UNDO.
        DEF        VAR log_cdempres     LIKE crapttl.cdempres        NO-UNDO.
        DEF        VAR log_nrcadast     LIKE crapttl.nrcadast        NO-UNDO.
        DEF        VAR log_cdtipren     LIKE crapttl.tpdrendi        NO-UNDO.
        DEF        VAR log_vlrendim     LIKE crapttl.vldrendi        NO-UNDO.
        DEF        VAR log_dsjusren     LIKE crapttl.dsjusren        NO-UNDO.
        
        /* Variaveis para log da tela: CONTAS -> BENS */
        DEF        VAR log_dsrelbem     LIKE crapbem.dsrelbem        NO-UNDO.
        DEF        VAR log_persemon     LIKE crapbem.persemon        NO-UNDO.
        DEF        VAR log_qtprebem     LIKE crapbem.qtprebem        NO-UNDO.
        DEF        VAR log_vlprebem     LIKE crapbem.vlprebem        NO-UNDO.
        DEF        VAR log_vlrdobem     LIKE crapbem.vlrdobem        NO-UNDO.
        
        /* Variaveis de faturamento : CONTAS -> JURIDICA */
        DEF        VAR log_perfatcl     LIKE crapjfn.perfatcl        NO-UNDO.
        DEF        VAR log_mesftbru     LIKE crapjfn.mesftbru        NO-UNDO.
        DEF        VAR log_anoftbru     LIKE crapjfn.anoftbru        NO-UNDO.
        DEF        VAR log_vlrftbru     LIKE crapjfn.vlrftbru        NO-UNDO.
        
        /* Variaveis para log da tela: CONTAS -> INF. CADASTRAL - FISICA */
        DEF        VAR log_nrinfcad     LIKE crapttl.nrinfcad       NO-UNDO.
        DEF        VAR log_nrpatlvr     LIKE crapttl.nrpatlvr       NO-UNDO.
        
    &ENDIF
    
    /*............................. PROCEDURES ..............................*/
    PROCEDURE atualiza_crapalt:
        
        ASSIGN crapalt.flgctitg = log_flgctitg
               crapalt.cdoperad = log_cdoperad 
               crapalt.dsaltera = crapalt.dsaltera + log_nmdcampo + ",".
     
    END PROCEDURE.
                  
    /* Jose Luis, DB1 - Adaptacao p/ uso das BO's - Registra Recadastramento */
    PROCEDURE registra_recad:
        /* Responsavel por atualizar o recadastramento do associado */
    
        DEF  INPUT PARAM par_chavealt AS CHAR                          NO-UNDO.
        DEF  INPUT PARAM par_cdoperad AS CHAR                          NO-UNDO.

        DEF OUTPUT PARAM TABLE FOR tt-erro.

        DEF VAR aux_contaalt AS INTE                                   NO-UNDO.
        DEF VAR aux_dscrialt AS CHAR                                   NO-UNDO.

        ContadorAlt: DO aux_contaalt = 1 TO 10:

           FIND crapalt WHERE 
                        crapalt.cdcooper = INTE(ENTRY(1,par_chavealt)) AND
                        crapalt.nrdconta = INTE(ENTRY(2,par_chavealt)) AND
                        crapalt.dtaltera = DATE(ENTRY(3,par_chavealt)) 
                        USE-INDEX crapalt1 EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

           IF  NOT AVAILABLE crapalt   THEN
               DO:
                  IF  LOCKED(crapalt) THEN
                      DO:
                         IF  aux_contaalt = 10 THEN
                             DO:
                                aux_dscrialt = "Log ALTERA (crapalt) esta " +
                                               "sendo alterado em outra "   +
                                               "estacao".
                                LEAVE ContadorAlt.
                             END.
                         ELSE
                             DO:
                                PAUSE 1 NO-MESSAGE.
                                NEXT ContadorAlt.
                             END.
                      END.
                  ELSE
                      DO:
                         CREATE crapalt.
                         ASSIGN crapalt.nrdconta = INTE(ENTRY(2,par_chavealt))
                                crapalt.dtaltera = DATE(ENTRY(3,par_chavealt))
                                crapalt.tpaltera = 2
                                crapalt.dsaltera = ""
                                crapalt.cdcooper = INTE(ENTRY(1,par_chavealt)).
                      END.
               END.
           ELSE
               LEAVE ContadorAlt.

        END.  /*  Fim do DO ContadorAlt  */

        EMPTY TEMP-TABLE tt-erro.

        IF  aux_dscrialt <> "" THEN
            DO:
                RUN gera_erro (INPUT INTE(ENTRY(1,par_chavealt)), /*cdcooper*/
                               INPUT 0,
                               INPUT 0,
                               INPUT 1,
                               INPUT 0,
                               INPUT-OUTPUT aux_dscrialt).
                UNDO, RETURN "NOK".
            END.

        IF  AVAILABLE crapalt THEN
            ASSIGN 
               crapalt.dsaltera = REPLACE(crapalt.dsaltera,
                                          "revisao cadastral,","")
               crapalt.tpaltera = 1
               crapalt.cdoperad = par_cdoperad.

        FIND CURRENT crapalt NO-LOCK NO-ERROR.

        RETURN "OK".

    END PROCEDURE.
    
    /* Jose Luis, DB1 - Adaptacao para uso das BO's - Registra Revisao */
    PROCEDURE registra_revis:
        /* Responsavel por realizar a revisao cadastral do associado */
    
        DEF  INPUT PARAM par_chavealt AS CHAR                          NO-UNDO.
        DEF  INPUT PARAM par_cdoperad AS CHAR                          NO-UNDO.

        DEF OUTPUT PARAM TABLE FOR tt-erro.

        DEF VAR aux_contaalt AS INTE                                   NO-UNDO.
        DEF VAR aux_dscrialt AS CHAR                                   NO-UNDO.

        ContadorAlt: DO aux_contaalt = 1 TO 10:

           FIND crapalt WHERE 
                        crapalt.cdcooper = INTE(ENTRY(1,par_chavealt)) AND
                        crapalt.nrdconta = INTE(ENTRY(2,par_chavealt)) AND
                        crapalt.dtaltera = DATE(ENTRY(3,par_chavealt)) 
                        USE-INDEX crapalt1 EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

           IF  NOT AVAILABLE crapalt   THEN
               DO:
                  IF  LOCKED(crapalt) THEN
                      DO:
                         IF  aux_contaalt = 10 THEN
                             DO:
                                aux_dscrialt = "Log ALTERA (crapalt) esta " +
                                               "sendo alterado em outra "   +
                                               "estacao".
                                LEAVE ContadorAlt.
                             END.
                         ELSE
                             DO:
                                PAUSE 1 NO-MESSAGE.
                                NEXT ContadorAlt.
                             END.
                      END.
                  ELSE
                      DO:
                         CREATE crapalt.
                         ASSIGN crapalt.nrdconta = INTE(ENTRY(2,par_chavealt))
                                crapalt.dtaltera = DATE(ENTRY(3,par_chavealt))
                                crapalt.tpaltera = 2
                                crapalt.dsaltera = ""
                                crapalt.cdcooper = INTE(ENTRY(1,par_chavealt)).
                      END.
               END.
           ELSE
               LEAVE ContadorAlt.

        END.  /*  Fim do DO ContadorAlt  */

        EMPTY TEMP-TABLE tt-erro.

        IF  aux_dscrialt <> "" THEN
            DO:
                RUN gera_erro (INPUT INTE(ENTRY(1,par_chavealt)), /*cdcooper*/
                               INPUT 0,
                               INPUT 0,
                               INPUT 1,
                               INPUT 0,
                               INPUT-OUTPUT aux_dscrialt).
                UNDO, RETURN "NOK".
            END.

        IF  AVAILABLE crapalt THEN
            DO:
                IF  NOT CAN-DO(crapalt.dsaltera, "revisao cadastral") THEN
                    crapalt.dsaltera = crapalt.dsaltera + "revisao cadastral,".
    
                ASSIGN crapalt.tpaltera = 1
                       crapalt.cdoperad = par_cdoperad.
            END.

        FIND CURRENT crapalt NO-LOCK NO-ERROR.

        RETURN "OK".
    
    END PROCEDURE.

    /* Jose Luis, DB1 - Adaptacao p/ uso das BO's - Registra Alteracao */
    PROCEDURE registra_altera:
    
        DEF  INPUT PARAM par_chavealt AS CHAR                          NO-UNDO.

        DEF OUTPUT PARAM TABLE FOR tt-erro.

        DEF VAR aux_contaalt AS INTE                                   NO-UNDO.
        DEF VAR aux_dscrialt AS CHAR                                   NO-UNDO.
        DEF VAR aux_tpaltera AS INTE                                   NO-UNDO.

        ASSIGN aux_tpaltera = 0.

        /* critica 401 */
        IF  NUM-ENTRIES(par_chavealt) >= 4 THEN
            DO:
               ASSIGN aux_tpaltera = INTEGER(ENTRY(4,par_chavealt,",")).

               IF  aux_tpaltera <> 1 AND aux_tpaltera <> 2 THEN
                   RETURN "OK".
            END.

        ContadorAlt: DO aux_contaalt = 1 TO 10:

           FIND crapalt WHERE 
                        crapalt.cdcooper = INTE(ENTRY(1,par_chavealt)) AND
                        crapalt.nrdconta = INTE(ENTRY(2,par_chavealt)) AND
                        crapalt.dtaltera = DATE(ENTRY(3,par_chavealt)) 
                        USE-INDEX crapalt1 EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

           IF  NOT AVAILABLE crapalt   THEN
               DO:
                  IF  LOCKED(crapalt) THEN
                      DO:
                         IF  aux_contaalt = 10 THEN
                             DO:
                                aux_dscrialt = "Log ALTERA (crapalt) esta " +
                                               "sendo alterado em outra "   +
                                               "estacao".
                                LEAVE ContadorAlt.
                             END.

                         PAUSE 1 NO-MESSAGE.
                         NEXT ContadorAlt.
                      END.
                  ELSE
                      LEAVE ContadorAlt.
               END.
           ELSE
               LEAVE ContadorAlt.

        END.  /*  Fim do DO ContadorAlt  */

        EMPTY TEMP-TABLE tt-erro.

        IF  aux_dscrialt <> "" THEN
            DO:
                RUN gera_erro (INPUT INTE(ENTRY(1,par_chavealt)), /*cdcooper*/
                               INPUT 0,
                               INPUT 0,
                               INPUT 1,
                               INPUT 0,
                               INPUT-OUTPUT aux_dscrialt).
                UNDO, RETURN "NOK".
            END.

        IF  AVAILABLE crapalt THEN
            ASSIGN crapalt.tpaltera = aux_tpaltera.

        FIND CURRENT crapalt NO-LOCK NO-ERROR.

        RETURN "OK".

    END PROCEDURE.

    PROCEDURE proc_altcad:

        DEFINE INPUT  PARAMETER par_tpatlcad AS INTEGER     NO-UNDO.
        DEFINE INPUT  PARAMETER par_chavealt AS CHARACTER   NO-UNDO.
        DEFINE INPUT  PARAMETER par_cdoperad AS CHARACTER   NO-UNDO.

        DEFINE OUTPUT PARAMETER TABLE FOR tt-erro.
    
        DEFINE VARIABLE aux_retorno  AS CHARACTER   NO-UNDO.
        DEFINE VARIABLE aux_tpaltera AS INTEGER     NO-UNDO.

        ASSIGN aux_retorno = "NOK".

        /* realizar a atualizacao cadastral - crapalt */
        IF  par_tpatlcad = 1 OR par_tpatlcad = 2 THEN
            DO:
                IF  par_tpatlcad = 1 THEN 
                    RUN registra_recad 
                        (INPUT par_chavealt,
                         INPUT par_cdoperad,
                         OUTPUT TABLE tt-erro).
                ELSE 
                    RUN registra_revis
                        (INPUT par_chavealt,
                         INPUT par_cdoperad,
                         OUTPUT TABLE tt-erro).

                ASSIGN aux_retorno = RETURN-VALUE.
            END.
        ELSE
            ASSIGN aux_retorno = "OK".

        /* obteve a critica 401 */
        IF  NUM-ENTRIES(par_chavealt) >= 4 THEN
            DO:
               ASSIGN aux_tpaltera = INTEGER(ENTRY(4,par_chavealt,",")).

               IF  aux_tpaltera = 1 OR aux_tpaltera = 2 THEN
                   DO:
                      RUN registra_altera 
                          ( INPUT par_chavealt,
                           OUTPUT TABLE tt-erro ).

                      IF  RETURN-VALUE <> "OK" THEN
                          ASSIGN aux_retorno = "NOK".
                      ELSE 
                          ASSIGN aux_retorno = "OK".
                   END.
            END.

        RETURN aux_retorno.

    END PROCEDURE.
&ENDIF /* SESSAO-BO */

/*..........................................................................*/

&IF DEFINED(SESSAO-DESKTOP) <> 0 &THEN

    PROCEDURE proc_altcad:

        DEFINE INPUT  PARAMETER par_programa AS CHARACTER     NO-UNDO.
    
        DEFINE VARIABLE h-procaltcad AS HANDLE                NO-UNDO.
        DEFINE VARIABLE aux_flgatcad AS CHARACTER FORMAT "X"  NO-UNDO.

        /* realizar a atualizacao cadastral - crapalt */
        IF  aux_tpatlcad = 1 OR aux_tpatlcad = 2 THEN
            DO:
               Cadastro: DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                   ASSIGN aux_flgatcad = "N".
                   MESSAGE aux_msgatcad UPDATE aux_flgatcad.
                   LEAVE Cadastro.
               END.
    
               IF  aux_flgatcad = "S" THEN
                   DO:
                      IF   NOT VALID-HANDLE(h-procaltcad) THEN
                           RUN VALUE("sistema/generico/procedures/" + 
                                     par_programa) PERSISTENT SET h-procaltcad.
    
                      IF  aux_tpatlcad = 1 THEN 
                          RUN registra_recad IN h-procaltcad
                              (INPUT aux_chavealt,
                               INPUT glb_cdoperad,
                               OUTPUT TABLE tt-erro).
                      ELSE 
                          RUN registra_revis IN h-procaltcad 
                              (INPUT aux_chavealt,
                               INPUT glb_cdoperad,
                               OUTPUT TABLE tt-erro).

                      IF  VALID-HANDLE(h-procaltcad) THEN
                          DELETE OBJECT h-procaltcad.

                      IF  RETURN-VALUE <> "OK" THEN
                          DO:
                             FIND FIRST tt-erro NO-ERROR.

                             IF  AVAILABLE tt-erro THEN
                                 DO:
                                    MESSAGE tt-erro.dscritic.
                                    PAUSE.
                                    RETURN "NOK".
                                 END.
                          END.
                   END.
            END.

        RETURN "OK".

    END PROCEDURE.
&ENDIF /* SESSAO-DESKTOP */

/*..........................................................................*/

&IF DEFINED(SESSAO-WEB) <> 0 &THEN

    PROCEDURE proc_altcad:

        RUN proc_altcad IN hBO (INPUT aux_tpatlcad,
                                INPUT aux_chavealt,
                                INPUT aux_cdoperad,
                                OUTPUT TABLE tt-erro).

        IF  RETURN-VALUE <> "OK" THEN
            DO:
                FIND FIRST tt-erro NO-LOCK NO-ERROR.

                IF  NOT AVAILABLE tt-erro  THEN
                    DO:
                        CREATE tt-erro.
                        ASSIGN tt-erro.dscritic = "Nao foi possivel concluir" +
                                                  " a atualizacao cadastral.".
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

&ENDIF /* SESSAO-WEB */

/*..........................................................................*/


