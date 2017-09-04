/* .............................................................................

   Programa: sistema/generico/includes/b1wgenalog.i (agn_logcontas.i)
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Evandro
   Data    : Abril/2006.                      Ultima atualizacao: 20/04/2017

   Dados referentes ao programa:

   Frequencia: Sempre que for chamada.
   Objetivo  : Fazer a movimentacao dos campos das tabelas para as variaveis do
               log de alteracoes.

   Alteracoes: 13/04/2008 - Retirada dos campos Rec. Arq. Cobranca (Ze)
   
               18/06/2009 - Ajuste para tipo de rendimento e o valor (Gabriel)
                            e logar item de BENS.
               
               04/12/2009 - Incluido campos para o item "INF. ADICIONAL" da
                            pessoa fisica (Elton).         
                            
               16/12/2009 - Eliminado campo crapttl.cdgrpext (Diego).                  
               
               16/03/2010 - Adaptacao para uso das BO's (Jose Luis)
               
               14/03/2011 - Retirar da ass o campo dsdemail e inarqcbr
                           (Gabriel).
                           
               20/05/2011 - Substituicao do campo crapenc.nranores por 
                            crapenc.dtinires (data que o cooperado passou a
                            residir no endereco informado). Fabricio
                            
               13/06/2011 - Criar campo 'Pessoa Politicamente Exposta'
                            (Gabriel).
                            
               05/07/2011 - Incluidas as variaveis log_nrdoapto e log_cddbloco 
                            (Henrique).                                
                            
               02/12/2011 - Incluido a variavel log_dsjusren (Adriano).
               
               13/04/2012 - Incluido as variaveis para logar a crapcrl - Respon.
                            Legal (Adriano).
                                                     
               29/04/2013 - Alterado campo crapass.dsnatura por crapttl.dsnatura
                            (Lucas R.)

               20/08/2013 - Alterado posicao do campo dsnatura para alimentar a 
                            variavel somente se a crapttl estiver disponivel.
                            (Reinert)
                            
               30/09/2013 - Removido campo log_nrfonres. (Reinert)

               16/05/2014 - Alterado o valor dos campos log_cdestcvl, 
                            log_vlsalari da tabela crapass para crapttl. 
                            (Douglas - Chamado 131253)
                            
               10/06/2014 - (Chamado 117414) - Troca do campo crapass.nmconjug por crapcje.nmconjug
                            (Tiago Castro - RKAM).
                            
               05/01/2015 - Incluido variavel log_flgrenli. (James)         
               
               12/08/2015 - Projeto Reformulacao cadastral
                            Eliminado o campo nmdsecao (Tiago Castro - RKAM).

               27/10/2015 - Inclusao de verificacao do campo crapass.idastcjt,
							              Prj. 131 (Jean Michel)               
                            
               29/02/2016 - Trocando o campo flpolexp para inpolexp conforme
                            solicitado no chamado 402159 (Kelvin).

			   20/04/2017 - Ajuste para retirar o uso de campos removidos da tabela
			                crapass, crapttl, crapjur 
							(Adriano - P339).

............................................................................. */
&IF DEFINED(TELA-MATRIC) <> 0 &THEN
    /* Variaveis de recadastramento (geram tipo de alteracao 1) */
    IF AVAILABLE crapcje THEN
     ASSIGN log_nmconjug = crapcje.nmconjug
            log_dtnasccj = crapcje.dtnasccj
            log_dsendcom = crapcje.dsendcom.
     
    ASSIGN log_nmprimtl = crapass.nmprimtl
           log_dtnasctl = crapass.dtnasctl
           log_nrcpfcgc = crapass.nrcpfcgc
           log_dsnacion = crapass.dsnacion
           log_dsproftl = crapass.dsproftl
           log_tpdocptl = crapass.tpdocptl
           log_nrdocptl = crapass.nrdocptl
           log_cdsexotl = crapass.cdsexotl
           log_dsfiliac = crapass.dsfiliac           
           log_dtcnscpf = crapass.dtcnscpf
           log_cdsitcpf = crapass.cdsitcpf
           log_nrdctitg = crapass.nrdctitg
           log_nmpaiptl = crapass.nmpaiptl
           log_nmmaeptl = crapass.nmmaeptl.

    ASSIGN log_cdagenci = crapass.cdagenci
           log_nrcadast = crapass.nrcadast
           log_dtdemiss = crapass.dtdemiss           
           log_dtadmemp = crapass.dtadmemp
           log_nrramemp = crapass.nrramemp
           log_nrctacto = crapass.nrctacto
           log_nrctaprp = crapass.nrctaprp
           log_cdtipcta = crapass.cdtipcta
           log_cdsitdct = crapass.cdsitdct
           log_cdsecext = crapass.cdsecext
           log_dtcnsspc = crapass.dtcnsspc
           log_dtdsdspc = crapass.dtdsdspc
           log_inadimpl = crapass.inadimpl
           log_inlbacen = crapass.inlbacen
           log_tpextcta = crapass.tpextcta
           log_tpavsdeb = crapass.tpavsdeb
           log_flgiddep = crapass.flgiddep
           log_cdoedptl = crapass.cdoedptl                    
           log_cdufdptl = crapass.cdufdptl                    
           log_dtemdptl = crapass.dtemdptl                    
           log_cdsitdtl = crapass.cdsitdtl.

    IF   AVAILABLE crapttl   THEN
         ASSIGN log_tpnacion = crapttl.tpnacion
                log_dsnatura = crapttl.dsnatura
                log_cdufnatu = crapttl.cdufnatu
                log_cdocpttl = crapttl.cdocpttl
                log_cdturnos = crapttl.cdturnos
                log_cdempres = crapttl.cdempres
                log_cdestcvl = crapttl.cdestcvl
                log_vlsalari = crapttl.vlsalari.
    ELSE
         ASSIGN log_cdturnos = 0.

    IF   AVAILABLE crapenc   THEN
         ASSIGN log_nrcepend = crapenc.nrcepend
                log_dsendere = crapenc.dsendere
                log_nrendere = crapenc.nrendere
                log_complend = crapenc.complend
                log_nmbairro = crapenc.nmbairro
                log_nmcidade = crapenc.nmcidade
                log_cdufende = crapenc.cdufende
                log_nrcxapst = crapenc.nrcxapst
                log_incasprp = crapenc.incasprp 
                log_vlalugue = crapenc.vlalugue 
                log_dtinires = crapenc.dtinires.

    IF   AVAILABLE crapjur   THEN
         ASSIGN log_dtiniatv = crapjur.dtiniatv
                log_natjurid = crapjur.natjurid
                log_nmfansia = crapjur.nmfansia
                log_nrinsest = crapjur.nrinsest
                log_cdrmativ = crapjur.cdrmativ
                log_cdseteco = crapjur.cdseteco.

    IF   AVAILABLE craptfc   THEN
         ASSIGN log_nrdddtfc = craptfc.nrdddtfc
                log_nrtelefo = craptfc.nrtelefo.

    /* Atribuicoes para log da tela MANEXT */       
    IF   AVAILABLE crapcex   THEN
         ASSIGN  log_cddemail = crapcex.cddemail
                 log_cdperiod = crapcex.cdperiod
                 log_cdrefere = crapcex.cdrefere
                 log_nmpessoa = crapcex.nmpessoa
                 log_tpextrat = crapcex.tpextrat.

    /* Atribuicoes para log da tela EMAIL */       
    IF   AVAILABLE crapcem   THEN
         ASSIGN  log_codemail = crapcem.cddemail
                 log_desemail = crapcem.dsdemail.

    /* Atribuicao para log da tela CADSPC */
    IF   AVAILABLE crapspc   THEN
         ASSIGN log_dtvencto = crapspc.dtvencto
                log_vldivida = crapspc.vldivida
                log_dtinclus = crapspc.dtinclus
                log_dtdbaixa = crapspc.dtdbaixa
                log_dsoberv1 = crapspc.dsoberva
                log_dsoberv2 = crapspc.dsobsbxa.

    FIND LAST crapalt WHERE crapalt.cdcooper = par_cdcooper AND
                            crapalt.nrdconta = par_nrdconta AND
                            crapalt.tpaltera = 1                
                            NO-LOCK NO-ERROR.

    IF  NOT AVAILABLE (crapalt) THEN
        ASSIGN log_dtaltera = ?.
    ELSE
        ASSIGN log_dtaltera = crapalt.dtaltera.

&ENDIF /* {&TELA-MATRIC} */

&IF DEFINED(TELA-CONTAS) = 0 &THEN

    /* Atribuicoes para o log dos campos genericos */
    IF   AVAILABLE crapass   THEN
         ASSIGN log_qtfoltal = crapass.qtfoltal

    /* Atribuicoes para o log da tela: CONTAS -> CONTA CORRENTE */
                log_cdageass = crapass.cdagenci
                log_cdtipcta = crapass.cdtipcta
                log_nrdctitg = crapass.nrdctitg
                log_cdsitdct = crapass.cdsitdct
                log_flgiddep = crapass.flgiddep
                log_tpavsdeb = crapass.tpavsdeb
                log_tpextcta = crapass.tpextcta
                log_cdsecext = crapass.cdsecext
                log_dtcnsspc = crapass.dtcnsspc
                log_dtcnsscr = crapass.dtcnsscr
                log_dtdsdspc = crapass.dtdsdspc
                log_flgrenli = crapass.flgrenli
				log_idastcjt = crapass.idastcjt
                log_dsinadim = IF   crapass.inadimpl = 0 THEN
                                    "N"
                               ELSE "S"     
                log_dslbacen = IF   crapass.inlbacen = 0 THEN
                                    "N"
                               ELSE "S".

    /* Atribuicoes para o log da tela: CONTAS -> TELEFONES */
    IF   AVAILABLE craptfc   THEN
         ASSIGN log_cdopetfn     = craptfc.cdopetfn
                log_nrdddtfc     = craptfc.nrdddtfc
                log_nrtelefo     = craptfc.nrtelefo
                log_nrdramal     = craptfc.nrdramal
                log_tptelefo     = craptfc.tptelefo
                log_secpscto_tfc = craptfc.secpscto
                log_nmpescto_tfc = craptfc.nmpescto.

    /* Atribuicoes para o log da tela: CONTAS -> EMAILS */
    IF   AVAILABLE crapcem   THEN
         ASSIGN log_dsdemail     = crapcem.dsdemail
                log_secpscto_cem = crapcem.secpscto
                log_nmpescto_cem = crapcem.nmpescto.

    /* Atribuicoes para o log da tela: CONTAS -> ENDERECO */
    IF   AVAILABLE crapenc   THEN
         ASSIGN log_incasprp = crapenc.incasprp
                log_dtinires = crapenc.dtinires
                log_vlalugue = crapenc.vlalugue
                log_nrcepend = crapenc.nrcepend
                log_dsendere = crapenc.dsendere
                log_nrendere = crapenc.nrendere
                log_complend = crapenc.complend
                log_nrdoapto = crapenc.nrdoapto
                log_cddbloco = crapenc.cddbloco
                log_nmbairro = crapenc.nmbairro
                log_nmcidade = crapenc.nmcidade
                log_cdufende = crapenc.cdufende
                log_nrcxapst = crapenc.nrcxapst.

    /* Atribuicoes para o log da tela: CONTAS -> IDENTIFICACAO (juridica) */
    IF   AVAILABLE crapjur   THEN
         ASSIGN log_nmfansia     = crapjur.nmfansia 
                log_natjurid     = crapjur.natjurid 
                log_qtfilial     = crapjur.qtfilial 
                log_qtfuncio     = crapjur.qtfuncio 
                log_dtiniatv     = crapjur.dtiniatv
                log_setecono     = crapjur.cdseteco
                log_cdrmativ     = crapjur.cdrmativ 
                log_dsendweb     = crapjur.dsendweb 
                log_nmtalttl_jur = crapjur.nmtalttl

    /* Atribuicoes para o log da tela: CONTAS -> REGISTRO (juridica) */
                log_vlfatano = crapjur.vlfatano
                log_nrinsest = crapjur.nrinsest
                log_vlcaprea = crapjur.vlcaprea
                log_dtregemp = crapjur.dtregemp
                log_nrregemp = crapjur.nrregemp
                log_orregemp = crapjur.orregemp
                log_dtinsnum = crapjur.dtinsnum
                log_nrinsmun = crapjur.nrinsmun
                log_flgrefis = crapjur.flgrefis
                log_nrcdnire = crapjur.nrcdnire.

    /* Atribuicoes para o log da tela: CONTAS -> IDENTIFICACAO (fisica) */
    IF   AVAILABLE crapttl   THEN
         ASSIGN log_dtcnscpf     = crapttl.dtcnscpf
                log_cdsitcpf     = crapttl.cdsitcpf
                log_tpdocttl     = crapttl.tpdocttl
                log_nrdocttl     = crapttl.nrdocttl
                log_cdoedttl     = crapttl.cdoedttl
                log_cdufdttl     = crapttl.cdufdttl
                log_dtemdttl     = crapttl.dtemdttl
                log_dtnasttl     = crapttl.dtnasttl
                log_cdsexotl     = crapttl.cdsexotl
                log_tpnacion     = crapttl.tpnacion
                log_dsnacion     = crapttl.dsnacion
                log_dsnatura     = crapttl.dsnatura
                log_cdufnatu     = crapttl.cdufnatu
                log_inhabmen     = crapttl.inhabmen
                log_dthabmen     = crapttl.dthabmen
                log_cdgraupr     = crapttl.cdgraupr
                log_cdestcvl     = crapttl.cdestcvl
                log_grescola     = crapttl.grescola
                log_cdfrmttl     = crapttl.cdfrmttl
                log_nmtalttl_ttl = crapttl.nmtalttl
                log_inpolexp     = crapttl.inpolexp 

    /* Atribuicoes para o log da tela: CONTAS -> COMERCIAL */
                log_cdnatopc_ttl = crapttl.cdnatopc
                log_cdocpttl_tll = crapttl.cdocpttl
                log_tpcttrab_ttl = crapttl.tpcttrab
                log_nmextemp_ttl = crapttl.nmextemp
                log_nrcpfemp_ttl = crapttl.nrcpfemp
                log_dsproftl_ttl = crapttl.dsproftl
                log_cdnvlcgo_ttl = crapttl.cdnvlcgo
                log_cdturnos_ttl = crapttl.cdturnos
                log_dtadmemp_ttl = crapttl.dtadmemp
                log_vlsalari_ttl = crapttl.vlsalari
                log_cdempres     = crapttl.cdempres
                log_nrcadast     = crapttl.nrcadast
                log_cdtipren[1]  = crapttl.tpdrendi[1]
                log_vlrendim[1]  = crapttl.vldrendi[1]
                log_cdtipren[2]  = crapttl.tpdrendi[2]
                log_vlrendim[2]  = crapttl.vldrendi[2]
                log_cdtipren[3]  = crapttl.tpdrendi[3]
                log_vlrendim[3]  = crapttl.vldrendi[3]
                log_cdtipren[4]  = crapttl.tpdrendi[4]
                log_vlrendim[4]  = crapttl.vldrendi[4]
                log_dsjusren     = crapttl.dsjusren

    /* Atribuicoes para o log da tela: CONTAS -> INF. CADASTRAL (FISICA) */
                log_nrinfcad     = crapttl.nrinfcad
                log_nrpatlvr     = crapttl.nrpatlvr.


    /* Atribuicoes para o log da tela: CONTAS -> REFERENCIAS (JURIDICA)
                                       CONTAS -> CONTATOS (FISICA) */
    IF   AVAILABLE crapavt   THEN
         ASSIGN log_nrdctato     = crapavt.nrdctato
                log_nmdavali     = crapavt.nmdavali
                log_nmextemp     = crapavt.nmextemp
                log_cddbanco     = crapavt.cddbanco
                log_cdagenci     = crapavt.cdagenci
                log_dsproftl     = crapavt.dsproftl
                log_cepender     = crapavt.nrcepend
                log_endereco     = crapavt.dsendres[1]
                log_numender     = crapavt.nrendere
                log_compleme     = crapavt.complend
                log_dsbairro     = crapavt.nmbairro
                log_dscidade     = crapavt.nmcidade
                log_sigladuf     = crapavt.cdufresd
                log_caixapst     = crapavt.nrcxapst
                log_telefone     = crapavt.nrtelefo
                log_endemail     = crapavt.dsdemail
                log_tpdocava     = crapavt.tpdocava
                log_nrdocava     = crapavt.nrdocava
                log_cdoeddoc     = crapavt.cdoeddoc
                log_cdufddoc     = crapavt.cdufddoc
                log_dtemddoc     = crapavt.dtemddoc
                log_dtnascto     = crapavt.dtnascto
                log_cdsexcto     = crapavt.cdsexcto
                log_cdestcvl_avt = crapavt.cdestcvl
                log_dsnacion_avt = crapavt.dsnacion
                log_dsnatura_avt = crapavt.dsnatura
                log_nmmaecto     = crapavt.nmmaecto
                log_nmpaicto     = crapavt.nmpaicto.

    /* Atribuicoes para o log da tela: CONTAS -> RESPONSAVEL LEGAL (FISICA) */
    IF AVAIL crapcrl THEN
       ASSIGN log_cdcooper_crl = crapcrl.cdcooper 
              log_nrctamen_crl = crapcrl.nrctamen
              log_nrcpfmen_crl = crapcrl.nrcpfmen
              log_idseqmen_crl = crapcrl.idseqmen
              log_nrdconta_crl = crapcrl.nrdconta
              log_nrcpfcgc_crl = crapcrl.nrcpfcgc
              log_nmrespon_crl = crapcrl.nmrespon
              log_nridenti_crl = crapcrl.nridenti
              log_tpdeiden_crl = crapcrl.tpdeiden
              log_dsorgemi_crl = crapcrl.dsorgemi
              log_cdufiden_crl = crapcrl.cdufiden
              log_dtemiden_crl = crapcrl.dtemiden
              log_dtnascin_crl = crapcrl.dtnascin
              log_cddosexo_crl = crapcrl.cddosexo
              log_cdestciv_crl = crapcrl.cdestciv
              log_dsnacion_crl = crapcrl.dsnacion
              log_dsnatura_crl = crapcrl.dsnatura
              log_cdcepres_crl = crapcrl.cdcepres
              log_dsendres_crl = crapcrl.dsendres
              log_nrendres_crl = crapcrl.nrendres
              log_dscomres_crl = crapcrl.dscomres
              log_dsbaires_crl = crapcrl.dsbaires
              log_nrcxpost_crl = crapcrl.nrcxpost
              log_dscidres_crl = crapcrl.dscidres
              log_dsdufres_crl = crapcrl.dsdufres
              log_nmpairsp_crl = crapcrl.nmpairsp
              log_nmmaersp_crl = crapcrl.nmmaersp.

    /*Atribuicoes para log da tela: CONTAS -> CONJUGE (fisica) */
    IF   AVAILABLE crapcje THEN
         ASSIGN log_nrctacje = crapcje.nrctacje
                log_nmconjug = crapcje.nmconjug                     
                log_nrcpfcjg = crapcje.nrcpfcjg
                log_dtnasccj = crapcje.dtnasccj
                log_tpdoccje = crapcje.tpdoccje
                log_nrdoccje = crapcje.nrdoccje
                log_cdoedcje = crapcje.cdoedcje
                log_cdufdcje = crapcje.cdufdcje                       
                log_dtemdcje = crapcje.dtemdcje
                log_gresccjg = crapcje.grescola
                log_cdfrmcje = crapcje.cdfrmttl
                log_cdnatopc = crapcje.cdnatopc
                log_cdocpttl = crapcje.cdocpcje
                log_tpcttrab = crapcje.tpcttrab
                log_nmempcje = crapcje.nmextemp                   
                log_nrcpfemp = crapcje.nrdocnpj                   
                log_dsprocje = crapcje.dsproftl                   
                log_cdnvlcgo = crapcje.cdnvlcgo                   
                log_nrfonemp = crapcje.nrfonemp               
                log_nrramemp = crapcje.nrramemp               
                log_cdturnos = crapcje.cdturnos               
                log_dtadmemp = crapcje.dtadmemp               
                log_vlsalari = crapcje.vlsalari.              

    /*Atribuicoes para log da tela: CONTAS -> DEPENDENTES */
    IF   AVAILABLE crapdep THEN
         ASSIGN log_dtnascim = crapdep.dtnascto
                log_cdtipdep = crapdep.tpdepend.

    /* Atribuicoes para log da tela : CONTAS -> BENS */
    IF   AVAILABLE crapbem   THEN
         ASSIGN log_dsrelbem = crapbem.dsrelbem
                log_persemon = crapbem.persemon
                log_qtprebem = crapbem.qtprebem
                log_vlprebem = crapbem.vlprebem
                log_vlrdobem = crapbem.vlrdobem.

    IF   AVAILABLE crapjfn   THEN
         DO:
             ASSIGN log_perfatcl = crapjfn.perfatcl.

             DO aux_contador = 1 TO 12:

                ASSIGN log_mesftbru[aux_contador] = crapjfn.mesftbru[aux_contador]
                       log_anoftbru[aux_contador] = crapjfn.anoftbru[aux_contador]
                       log_vlrftbru[aux_contador] = crapjfn.vlrftbru[aux_contador].

             END.   

         END.

    /* Indica se o endereco atualizado foi cadastrado via InternetBank. */
    /* Sera atribuido como TRUE na procedure que faz essa atualizacao.  */
    ASSIGN log_flencnet = FALSE.

&ENDIF /* {&TELA-CONTAS} */

ASSIGN log_cddopcao = par_cddopcao
       log_dtmvtolt = par_dtmvtolt
       log_cdcooper = par_cdcooper
       log_nrdconta = par_nrdconta
       log_idseqttl = par_idseqttl
       log_nmdatela = par_nmdatela
       log_cdoperad = par_cdoperad.

/*..........................................................................*/
