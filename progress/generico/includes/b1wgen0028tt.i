/*..............................................................................

   Programa: b1wgen0028tt.i                  
   Autor   : Guilherme
   Data    : Marco/2008                        Ultima atualizacao: 20/04/2017

   Dados referentes ao programa:

   Objetivo  : Temp-tables utlizadas na BO b1wgen0028.p - CARTOES CREDITO

   Alteracoes: 04/09/2008 - Novo campo na temp-table tt-dados_cartao (David).

               16/09/2008 - Novo campo ds2viacr na temp-table tt-dados_cartao 
                            (David).

               02/06/2009 - Inclusao de campo cdadmcrd na temp-table 
                            tt-nova_proposta para incluir codigos das 
                            administradoras cadastradas - GATI - Eder

               26/08/2010 - Inclusao PJ - GATI - Sandro

               07/10/2010 - Inclusao tt_dados_promissora
                            GATI - Sandro

               19/01/2011 - Alteracao de formato do campo nome do cooperado
                            para 50 posicoes;
                            Inclusao de campo para gravacao do nome extenso
                            da Cooperativa (GATI - Eder)

               28/03/2011 - Incluido campo nmresadm em tt-termocan-cartao
                            (Irlan).

               24/05/2011 - Aumentar EXTENT para 3 no campo dsendav1 e dsendav2
                            da tt_dados_promissoria (David).

               15/07/2011 - Inclusao temp-table tt-extrato-cartao 
                            (Guilherme/Supero)
                            
               12/09/2011 - Inclusao temp-table tt-cartao (Henrique).
               
               29/09/2011 - Inclusao do campo dddebant na temp-table 
                            tt-dados_cartao. (Fabricio)
                            
               22/12/2011 - Inclusao da tabela tt-cartoes-filtro para armazenar
                            relação de cartões [InternetBanking - Op. 70] (Lucas).
                            
               10/07/2012 - Incluido na temp-table tt-dados_cartao campo 
                            nmextttl (Guilherme Maba).
                            
               29/04/2013 - Incluido campo nrdctitg na TEMP-TABLE cartao (Daniele). 
               
               01/04/2013 - Inclusao da TEMP-TABLE tt-dados-cartao (Jean Michel).
               
               16/05/2014 - Incluir o campo flgcchip na temp-table tt-cartoes. (James)
               
               10/06/2014 - (Chamado 117414) - Troca do campo crapass.nmconjug por crapcje.nmconjug
                            (Tiago Castro - RKAM).
               
               28/07/2014 - Novo campo para tratamento de exibição parcial do
                            número do cartão (Lunelli).
                            
               21/08/2014 - Incluso campo nmempcrd na tt-dados-cartao (Daniel) - SoftDesk  188116 
               
               24/08/2015 - Incluido na temp-table tt-dados_cartao campos inacetaa, dtacetaa e 
                            cdoperad. (James)
                            
               08/10/2015 - Desenvolvimento do projeto 126. (James)
               
               28/04/2016 - Adicionar o campo flgdebit na temp-table tt-dados-cartao
                            (Douglas - Chamado 415437)
                            
               23/09/2016 - Correçao nas TEMP-TABLES colocar NO-UNDO, tt-motivos_2via (Oscar).
                            Correçao nas TEMP-TABLES colocar NO-UNDO, tt_dados_promissoria_imp (Oscar).
               
			   20/04/2017 - Ajuste para retirar o uso de campos removidos da tabela
			                crapass, crapttl, crapjur 
							(Adriano - P339).
               
....................................................................................*/

DEF TEMP-TABLE tt-lim_total NO-UNDO
    FIELD vltotccr AS DECI.

DEF TEMP-TABLE tt-cartoes NO-UNDO
    FIELD nrdconta LIKE crapass.nrdconta
    FIELD nmtitcrd AS CHAR 
    FIELD nmresadm AS CHAR 
    FIELD nrcrcard AS CHAR 
    FIELD dscrcard AS CHAR
    FIELD dssitcrd AS CHAR 
    FIELD insitcrd AS INTE
    FIELD nrctrcrd LIKE crawcrd.nrctrcrd
    FIELD cdadmcrd LIKE crawcrd.cdadmcrd
    FIELD flgcchip LIKE crapadc.flgcchip.
	FIELD flgprcrd LIKE crawcrd.flgprcrd.
    
DEF TEMP-TABLE tt-dados_cartao NO-UNDO
    FIELD nrcrcard LIKE crawcrd.nrcrcard  
    FIELD nrdoccrd LIKE crawcrd.nrdoccrd
    FIELD nrctrcrd LIKE crawcrd.nrctrcrd
    FIELD nmresadm LIKE crapadc.nmresadm
    FIELD dscartao AS CHAR 
    FIELD nmempttl LIKE crapass.nmprimtl
    FIELD nrcnpjtl LIKE crapass.nrcpfcgc
    FIELD nmtitcrd LIKE crawcrd.nmtitcrd
    FIELD nmextttl LIKE crawcrd.nmextttl
    FIELD nrcpftit LIKE crawcrd.nrcpftit
    FIELD dsparent AS CHAR             
    FIELD dssituac AS CHAR             
    FIELD vlsalari LIKE crawcrd.vlsalari
    FIELD vlsalcon LIKE crawcrd.vlsalcon
    FIELD vloutras LIKE crawcrd.vloutras
    FIELD vlalugue LIKE crawcrd.vlalugue
    FIELD dddebito LIKE crawcrd.dddebito
    FIELD dddebant LIKE crawcrd.dddebant
    FIELD vllimite AS CHAR            
    FIELD dtpropos LIKE crawcrd.dtpropos
    FIELD vllimdeb LIKE crapass.vllimdeb
    FIELD dtsolici LIKE crawcrd.dtsolici
    FIELD dtlibera LIKE crawcrd.dtlibera
    FIELD dtentreg LIKE crawcrd.dtentreg
    FIELD dtcancel LIKE crawcrd.dtcancel
    FIELD dsmotivo AS CHAR          
    FIELD dtvalida LIKE crawcrd.dtvalida
    FIELD qtanuida LIKE crawcrd.qtanuida
    FIELD nrctamae AS DECI
    FIELD dsde2via AS CHAR       
    FIELD dtanucrd AS DATE             
    FIELD dspaganu AS CHAR             
    FIELD nmoperad AS CHAR
    FIELD ds2viasn AS CHAR
    FIELD ds2viacr AS CHAR
    FIELD lbcanblq AS CHAR
    FIELD inpessoa LIKE crapass.inpessoa
    FIELD inacetaa LIKE crapcrd.inacetaa
    FIELD dsacetaa AS CHAR
    FIELD dtacetaa LIKE crapcrd.dtacetaa
    FIELD cdopetaa LIKE crapcrd.cdopetaa
    FIELD nmopetaa AS CHAR
    FIELD cdadmcrd LIKE crawcrd.cdadmcrd
    FIELD flgdebit LIKE crawcrd.flgdebit
    FIELD dtrejeit LIKE crawcrd.dtrejeit
    FIELD nrcctitg LIKE crawcrd.nrcctitg
    FIELD dsdpagto AS CHAR
    FIELD dsgraupr AS CHAR
    FIELD nmempcrd LIKE crawcrd.nmempcrd.
    
DEF TEMP-TABLE tt-hab_cartao NO-UNDO
    FIELD nrcpfcgc LIKE crapass.nrcpfcgc
    FIELD nmprimtl LIKE crapass.nmprimtl
    FIELD nrdconta LIKE craphcj.nrdconta
    FIELD vllimglb LIKE craphcj.vllimglb
    FIELD flgativo LIKE craphcj.flgativo
    FIELD nrcpfpri LIKE craphcj.nrcpfpri
    FIELD nrcpfseg LIKE craphcj.nrcpfseg
    FIELD nrcpfter LIKE craphcj.nrcpfter
    FIELD nmpespri LIKE crapncp.nmpessoa
    FIELD nmpesseg LIKE crapncp.nmpessoa
    FIELD nmpester LIKE crapncp.nmpessoa
    FIELD nrctrcrd LIKE craphcj.nrctrhcj
    FIELD nrctaav1 LIKE craphcj.nrctaav1
    FIELD nrctaav2 LIKE craphcj.nrctaav2
    FIELD dtnaspri AS DATE
    FIELD dtnasseg AS DATE
    FIELD dtnaster AS DATE
    FIELD flgrepr1 AS LOGI
    FIELD flgrepr2 AS LOGI
    FIELD flgrepr3 AS LOGI
    FIELD flgalter AS LOGI.

DEF TEMP-TABLE tt-novo_cartao NO-UNDO
    FIELD dsgraupr /* "Parentesco"         */ AS CHAR         
    FIELD nrcpfcpf /* "C.P.F."             */ AS CHAR         
    FIELD nmtitcrd /* "Titular do Cartao"  */ AS CHAR         
    FIELD nrdoccrd /* "Identidade"         */ AS CHAR         
    FIELD dtnasccr /* "Nascimento"         */ AS CHAR         
    FIELD dsadmcrd /* "Administradora"     */ AS CHAR         
    FIELD dscartao /* "Tipo"               */ AS CHAR          
    FIELD vlsalari /* "Salario"            */ AS CHAR         
    FIELD vlsalcjg /* "Salario conjuge"    */ AS CHAR         
    FIELD vlrendas /* "Outras rendas"      */ AS CHAR         
    FIELD vlalugue /* "Aluguel"            */ AS CHAR         
    FIELD dddebito /* "Dia debito"         */ AS CHAR         
    FIELD vllimpro /* "Limite proposto"    */ AS DECI         
    FIELD flgimpnp /* "Promissoria"        */ AS CHAR         
    FIELD vllimdeb /* "Limite Debito"      */ AS CHAR.    
    
DEF TEMP-TABLE tt-nova_proposta NO-UNDO
    FIELD dsgraupr /* "Parentesco"         */ AS CHAR         
    FIELD dsadmcrd /* "Administradora"     */ AS CHAR
    FIELD dscartao /* "Tipo"               */ AS CHAR          
    FIELD vlsalari /* "Salario"            */ AS DECI
    FIELD dddebito /* "Dia debito"         */ AS CHAR
    FIELD cdtipcta LIKE crapass.cdtipcta
    FIELD nrcpfstl LIKE crapttl.nrcpfcgc
    FIELD inpessoa LIKE crapass.inpessoa
    FIELD dtnasstl LIKE crapttl.dtnasttl
    FIELD nrdocstl LIKE crapttl.nrdocttl
    FIELD nmconjug LIKE crapcje.nmconjug
    FIELD dtnasccj LIKE crapcje.dtnasccj
    FIELD nmtitcrd LIKE crapass.nmprimtl
    FIELD nrcpfcgc LIKE crapass.nrcpfcgc
    FIELD dtnasctl LIKE crapass.dtnasctl
    FIELD nrdocptl LIKE crapass.nrdocptl
    FIELD cdgraupr AS CHAR
    FIELD nmsegntl AS CHAR
    FIELD cdadmdeb AS CHAR
    FIELD cdadmcrd AS CHAR
    FIELD nmprimtl LIKE crapass.nmprimtl        
    FIELD nrrepinc AS CHAR
    FIELD dsrepinc AS CHAR
    FIELD nmbandei AS CHAR
    FIELD dslimite AS CHAR
    FIELD dsoutros AS CHAR.
    
DEF TEMP-TABLE tt-ult_deb NO-UNDO
    FIELD dtdebito LIKE crapdcd.dtdebito
    FIELD vldebito LIKE crapdcd.vldebito.    
    
DEF TEMP-TABLE tt-dados_renovacao_cartao NO-UNDO
    FIELD nrctrcrd LIKE crawcrd.nrcrcard 
    FIELD dtvalida AS DATE               
    FIELD dtaltval AS DATE               
    FIELD nrctaav1 LIKE crawcrd.nrctaav1 
    FIELD nrctaav2 LIKE crawcrd.nrctaav2.
    
DEF TEMP-TABLE tt-termo_cancblq_cartao NO-UNDO
    FIELD nrdconta LIKE crapass.nrdconta
    FIELD nrcrcard LIKE crawcrd.nrcrcard
    FIELD nmprimtl LIKE crapass.nmprimtl
    FIELD dsadmcrd AS CHAR
    FIELD localdat AS CHAR
    FIELD operador AS CHAR
    FIELD dsdtermo AS CHAR.
    
DEF TEMP-TABLE tt-limite_deb_cartao NO-UNDO
    FIELD vllimdeb AS DECI.
    
DEF TEMP-TABLE tt-limite_crd_cartao NO-UNDO
    FIELD vllimcrd AS DECI.
    
DEF TEMP-TABLE tt-dtvencimento_cartao NO-UNDO
    FIELD diasdadm AS CHAR
    FIELD dddebito AS INTE.
    
DEF TEMP-TABLE tt-motivos_2via NO-UNDO
    FIELD dsmotivo AS CHAR
    FIELD cdmotivo AS INTE.

DEF TEMP-TABLE tt-dados_prp_ccr NO-UNDO
    FIELD dddebito AS INTE
    FIELD vllimdeb AS DECI
    FIELD nrcpftit AS DECI
    FIELD vllimcrd AS DECI
    FIELD cdlimcrd AS INTE
    FIELD nrctamae AS DECI
    FIELD dsparent AS CHAR
    FIELD nmtitcrd AS CHAR
    FIELD tpcartao AS CHAR
    FIELD nmresemp AS CHAR
    FIELD dsadicio AS CHAR
    FIELD nmextcop AS CHAR
    FIELD nmrecop1 AS CHAR
    FIELD nmrecop2 AS CHAR
    FIELD nmcidade AS CHAR
    FIELD cdufdcop AS CHAR
    FIELD nrdconta AS INTE
    FIELD nrmatric AS INTE
    FIELD nrcpfcgc AS CHAR
    FIELD nmprimtl AS CHAR
    FIELD nmsegntl AS CHAR
    FIELD dtadmiss AS DATE
    FIELD nmdsecao AS CHAR
    FIELD nmresage AS CHAR
    FIELD dsempres AS CHAR
    FIELD nrdofone AS CHAR
    FIELD dstipcta AS CHAR
    FIELD dssitdct AS CHAR
    FIELD nrctrcrd AS INTE
    FIELD vllimite AS DECI
    FIELD vllimcre AS DECI
    FIELD vlsalari AS DECI
    FIELD vlsalcon AS DECI
    FIELD vloutras AS DECI
    FIELD vlalugue AS DECI
    FIELD dsobser1 AS CHAR
    FIELD dsobser2 AS CHAR
    FIELD dsobser3 AS CHAR
    FIELD vlutiliz AS DECI
    FIELD vlaplica AS DECI
    FIELD vlsmdtri AS DECI DECIMALS 2
    FIELD vlcaptal AS DECI
    FIELD vlprepla AS DECI
    FIELD vltotccr AS DECI
    FIELD vltotemp AS DECI
    FIELD vltotpre AS DECI
    FIELD nmoperad AS CHAR
    FIELD dsemsprp AS CHAR
    FIELD dslinha1 AS CHAR
    FIELD dslinha2 AS CHAR
    FIELD dslinha3 AS CHAR
    FIELD dsdestin AS CHAR
    FIELD dscontat AS CHAR
    FIELD nrcrcard AS DECI
    FIELD dsemprp2 AS CHAR
    FIELD dsectrnp AS CHAR
    FIELD nmexcop1 AS CHAR
    FIELD nmexcop2 AS CHAR
    FIELD dscpfcgc AS CHAR
    FIELD endeass1 AS CHAR 
    FIELD endeass2 AS CHAR
    FIELD nmcidpac AS CHAR
    FIELD dsctrcrd AS CHAR
    FIELD dsvlcrd1 AS CHAR
    FIELD dsvlcrd2 AS CHAR
    FIELD dsdtmvt1 AS CHAR
    FIELD dsdtmvt2 AS CHAR
    FIELD dsvlnpr1 AS CHAR
    FIELD dsvlnpr2 AS CHAR
    FIELD dsdmoeda AS CHAR    
    FIELD vlrftmes AS DECI
    FIELD vlrfttot AS DECI.
    
DEF TEMP-TABLE tt-dados_prp_emiss_ccr NO-UNDO
    FIELD nmextcop LIKE crapcop.nmextcop
    FIELD nmprimtl LIKE crapass.nmprimtl
    FIELD nrcpfcgc AS CHAR
    FIELD nrdconta LIKE crapass.nrdconta
    FIELD nrdocnpj AS CHAR 
    FIELD nrcrcard LIKE crawcrd.nrcrcard
    FIELD nrctrcrd LIKE crawcrd.nrctrcrd
    FIELD nmtitcrd LIKE crawcrd.nmtitcrd
    FIELD dsendcop LIKE crapcop.dsendcop
    FIELD nrendcop LIKE crapcop.nrendcop
    FIELD dscomple LIKE crapcop.dscomple
    FIELD nmbairro LIKE crapcop.nmbairro
    FIELD nmcidade LIKE crapcop.nmcidade
    FIELD cdufdcop LIKE crapcop.cdufdcop
    FIELD dtnasctl LIKE crapass.dtnasctl
    FIELD vllimcrd LIKE craptlc.vllimcrd
    FIELD dddebito LIKE crawcrd.dddebito
    FIELD dsemsctr AS CHAR
    FIELD dsrepinc AS CHAR
    FIELD nrcpftit AS CHAR.

DEF TEMP-TABLE tt-outros_cartoes NO-UNDO
    FIELD dsdnomes AS CHAR 
    FIELD vllimite AS DECI 
    FIELD dstipcrd AS CHAR
    FIELD dssituac AS CHAR.
    
DEF TEMP-TABLE tt-ctr_credicard NO-UNDO
    FIELD nmextcop LIKE crapcop.nmextcop
    FIELD dssubsti AS CHAR 
    FIELD nmprimtl LIKE crapass.nmprimtl
    FIELD nrcpfcgc LIKE crapass.nrcpfcgc
    FIELD nrdconta LIKE crapass.nrdconta
    FIELD cdagenci LIKE crapass.cdagenci
    FIELD nrdocnpj AS CHAR 
    FIELD nmrescop LIKE crapcop.nmrescop
    FIELD nrcrcard LIKE crawcrd.nrcrcard
    FIELD nrctrcrd LIKE crawcrd.nrctrcrd
    FIELD nmtitcrd LIKE crawcrd.nmtitcrd
    FIELD nmcidade LIKE crapcop.nmcidade
    FIELD cdufdcop LIKE crapcop.cdufdcop
    FIELD dsemsctr AS CHAR
    FIELD nmoperad AS CHAR
    FIELD nmrecop1 AS CHAR
    FIELD nmrecop2 AS CHAR
    FIELD dsectrnp AS CHAR
    FIELD nmexcop1 AS CHAR
    FIELD nmexcop2 AS CHAR
    FIELD dscpfcgc AS CHAR
    FIELD endeass1 AS CHAR 
    FIELD endeass2 AS CHAR
    FIELD nmcidpac AS CHAR
    FIELD dsctrcrd AS CHAR
    FIELD vllimite AS DECI
    FIELD dsvlcrd1 AS CHAR
    FIELD dsvlcrd2 AS CHAR
    FIELD dsdtmvt1 AS CHAR
    FIELD dsdtmvt2 AS CHAR
    FIELD dsvlnpr1 AS CHAR
    FIELD dsvlnpr2 AS CHAR
    FIELD dsdmoeda AS CHAR.    
    
DEF TEMP-TABLE tt-bdn_visa_cecred NO-UNDO
    FIELD nmcartao AS CHAR 
    FIELD dssubsti AS CHAR 
    FIELD nrctrcrd LIKE crawcrd.nrctrcrd
    FIELD nmextcop LIKE crapcop.nmextcop
    FIELD nmrescop LIKE crapcop.nmrescop
    FIELD nrdocnpj AS CHAR 
    FIELD dsendcop LIKE crapcop.dsendcop
    FIELD nrendcop LIKE crapcop.nrendcop
    FIELD nmbairro LIKE crapcop.nmbairro
    FIELD nmcidade LIKE crapcop.nmcidade
    FIELD cdufdcop LIKE crapcop.cdufdcop
    FIELD nmprimtl LIKE crapass.nmprimtl
    FIELD nrcpfcgc AS CHAR 
    FIELD nrdconta LIKE crapass.nrdconta
    FIELD dsvincul AS CHAR 
    FIELD nrcrcard LIKE crawcrd.nrcrcard
    FIELD nmtitcrd LIKE crawcrd.nmtitcrd
    FIELD dsemsctr AS CHAR 
    FIELD nmoperad AS CHAR
    FIELD nmexcop1 AS CHAR
    FIELD nmexcop2 AS CHAR
    FIELD dscpfcgc AS CHAR
    FIELD endeass1 AS CHAR 
    FIELD endeass2 AS CHAR
    FIELD nmcidpac AS CHAR
    FIELD dsctrcrd AS CHAR
    FIELD vllimite AS DECI
    FIELD dsvlcrd1 AS CHAR
    FIELD dsvlcrd2 AS CHAR
    FIELD dsdtmvt1 AS CHAR
    FIELD dsdtmvt2 AS CHAR
    FIELD dsvlnpr1 AS CHAR
    FIELD dsvlnpr2 AS CHAR
    FIELD nmdaval1 AS CHAR
    FIELD cpfcgc1  AS CHAR
    FIELD nmdaval2 AS CHAR
    FIELD cpfcgc2  AS CHAR
    FIELD nmconju1 AS CHAR
    FIELD nrcpfcj1 AS CHAR
    FIELD nmconju2 AS CHAR
    FIELD nrcpfcj2 AS CHAR
    FIELD vllimglb LIKE craphcj.vllimglb 
    FIELD dsrepre1 AS CHAR
    FIELD dsrepre2 AS CHAR
    FIELD dsendere AS CHAR
    FIELD nrendere AS INTE
    FIELD complend AS CHAR
    FIELD nmbaiend AS CHAR
    FIELD nmcidend AS CHAR
    FIELD cdufende AS CHAR
    FIELD nrcepend AS INTE
    FIELD dsvllim1 AS CHAR 
    FIELD dsvllim2 AS CHAR
    FIELD dsdmoeda AS CHAR.

DEF TEMP-TABLE tt-ctr_novo_cartao NO-UNDO
    FIELD nrctrcrd AS INTE.
    
DEF TEMP-TABLE tt-termo_solici2via NO-UNDO
    FIELD nmextcop LIKE crapcop.nmextcop
    FIELD nrdocnpj LIKE crapcop.nrdocnpj
    FIELD nrcrcard LIKE crawcrd.nrcrcard 
    FIELD nrdconta LIKE crapass.nrdconta
    FIELD nmprimtl LIKE crapass.nmprimtl
    FIELD dsadmcrd AS CHAR 
    FIELD dsmot2vi AS CHAR 
    FIELD localdat AS CHAR 
    FIELD dsdtermo AS CHAR
    FIELD nmrecop1 AS CHAR
    FIELD nmrecop2 AS CHAR.
    
DEF TEMP-TABLE tt-ctr_bb NO-UNDO
    FIELD nmcartao AS CHAR 
    FIELD nrctrcrd LIKE crawcrd.nrctrcrd
    FIELD nmextcop LIKE crapcop.nmextcop
    FIELD nmrescop LIKE crapcop.nmrescop
    FIELD nrdocnpj AS CHAR 
    FIELD dsendcop LIKE crapcop.dsendcop
    FIELD nrendcop LIKE crapcop.nrendcop
    FIELD nmbairroc LIKE crapcop.nmbairro
    FIELD nmcidadec LIKE crapcop.nmcidade
    FIELD cdufdcop LIKE crapcop.cdufdcop
    FIELD nmprimtl LIKE crapass.nmprimtl
    FIELD nrcpfcgc AS CHAR 
    FIELD nrdconta LIKE crapass.nrdconta
    FIELD nrdctitg LIKE crapass.nrdctitg
    FIELD dsvincul AS CHAR 
    FIELD nrcrcard LIKE crawcrd.nrcrcard
    FIELD nmtitcrd LIKE crawcrd.nmtitcrd
    FIELD dsendere LIKE crapenc.dsendere
    FIELD nmcidade LIKE crapenc.nmcidade
    FIELD nmbairro LIKE crapenc.nmbairro
    FIELD nrendere LIKE crapenc.nrendere
    FIELD nrcepend LIKE crapenc.nrcepend
    FIELD cdufende LIKE crapenc.cdufende
    FIELD cdagenci LIKE crapass.cdagenci
    FIELD dsemsdnp AS CHAR
    FIELD dsemsctr AS CHAR 
    FIELD nmoperad AS CHAR
    FIELD nmexcop1 AS CHAR
    FIELD nmexcop2 AS CHAR
    FIELD dscpfcgc AS CHAR
    FIELD endeass1 AS CHAR 
    FIELD endeass2 AS CHAR
    FIELD nmcidpac AS CHAR
    FIELD dsctrcrd AS CHAR
    FIELD vllimite AS DECI
    FIELD dsvlcrd1 AS CHAR
    FIELD dsvlcrd2 AS CHAR
    FIELD dsdtmvt1 AS CHAR
    FIELD dsdtmvt2 AS CHAR
    FIELD dsvlnpr1 AS CHAR
    FIELD dsvlnpr2 AS CHAR
    FIELD dsdmoeda AS CHAR.    
    
DEF TEMP-TABLE tt-termo_alt_dt_venc NO-UNDO
    FIELD nmextcop LIKE crapcop.nmextcop
    FIELD dslinha1 AS CHAR
    FIELD dslinha2 AS CHAR
    FIELD dslinha3 AS CHAR
    FIELD dsemsctr AS CHAR
    FIELD nrcrcard LIKE crawcrd.nrcrcard
    FIELD nmtitcrd LIKE crawcrd.nmtitcrd
    FIELD dddebito LIKE crawcrd.dddebito
    FIELD nmprimtl LIKE crapass.nmprimtl
    FIELD dsoperad AS CHAR
    FIELD nmrecop1 AS CHAR
    FIELD nmrecop2 AS CHAR.

DEFINE TEMP-TABLE ttPeriodo NO-UNDO
    FIELD ano       AS INTEGER
    FIELD mes       AS INTEGER.

DEF TEMP-TABLE tt_dados_promissoria NO-UNDO
   FIELD dsemsctr AS CHAR
   FIELD dsctrcrd AS CHAR
   FIELD dsdmoeda AS CHAR
   FIELD vllimite AS DECI
   FIELD dsdtmvt1 AS CHAR
   FIELD dsdtmvt2 AS CHAR
   FIELD nmextcop LIKE crapcop.nmextcop
   FIELD nmrescop LIKE crapcop.nmrescop
   FIELD dsvlnpr1 AS CHAR
   FIELD dsvlnpr2 AS CHAR
   FIELD nmcidpac AS CHAR
   FIELD nmprimtl LIKE crapass.nmprimtl
   FIELD dscpfcgc AS CHAR
   FIELD nrdconta LIKE crapass.nrdconta
   FIELD endeass1 AS CHAR
   FIELD endeass2 AS CHAR
   FIELD nmcidade AS CHAR
   FIELD nmdaval1 AS CHAR
   FIELD nmdcjav1 AS CHAR
   FIELD dscpfav1 AS CHAR
   FIELD dscfcav1 AS CHAR
   FIELD dsendav1 AS CHAR EXTENT 3
   FIELD nmdaval2 AS CHAR
   FIELD nmdcjav2 AS CHAR
   FIELD dscpfav2 AS CHAR
   FIELD dscfcav2 AS CHAR
   FIELD dsendav2 AS CHAR EXTENT 3
   FIELD dsmvtolt AS CHAR.

DEF TEMP-TABLE tt_dados_promissoria_imp NO-UNDO LIKE tt_dados_promissoria.

DEFINE TEMP-TABLE tt-termo-entreg-pj NO-UNDO
    FIELD nome     AS CHAR FORMAT "x(50)"
    FIELD cnpj     AS DEC FORMAT "zz,zzz,zzz,zzzz,zz"
    FIELD nrrepent LIKE crawcrd.nrrepent
    FIELD nrcpfcgc LIKE crapass.nrcpfcgc
    FIELD nmrescop LIKE crapcop.nmrescop
    FIELD nmextcop LIKE crapcop.nmextcop
    FIELD nrdocnpj LIKE crapcop.nrdocnpj
    FIELD dsendere LIKE crapenc.dsendere
    FIELD nrendere LIKE crapenc.nrendere
    FIELD nmbairro LIKE crapenc.nmbairro
    FIELD nmcidade LIKE crapenc.nmcidade
    FIELD cdufende LIKE crapenc.cdufende
    FIELD nrcepend LIKE crapenc.nrcepend
    FIELD nmrepsol AS CHAR FORMAT "x(40)"
    FIELD nrcrcard LIKE crawcrd.nrcrcard
    FIELD nrcpftit LIKE crawcrd.nrcpftit
    FIELD nmtitcrd LIKE crawcrd.nmtitcrd
    FIELD nmprimtl LIKE crapass.nmprimtl
    FIELD dsemsctr AS CHAR FORMAT "x(50)"
    FIELD dsmotivo AS CHAR FORMAT "x(20)"
    FIELD cdcooper LIKE crapcop.cdcooper.

DEFINE TEMP-TABLE tt-segvia-cartao NO-UNDO
    FIELD nome     AS CHAR FORMAT "x(40)"
    FIELD cnpj     AS DEC FORMAT "zz,zzz,zzz,zzzz,zz"
    FIELD nrrepent LIKE crawcrd.nrrepent
    FIELD nrcpfcgc LIKE crapass.nrcpfcgc
    FIELD nmrescop LIKE crapcop.nmrescop
    FIELD nmextcop LIKE crapcop.nmextcop
    FIELD nrdocnpj LIKE crapcop.nrdocnpj
    FIELD dsendere LIKE crapenc.dsendere
    FIELD nrendere LIKE crapenc.nrendere
    FIELD nmbairro LIKE crapenc.nmbairro
    FIELD nmcidade LIKE crapenc.nmcidade
    FIELD cdufende LIKE crapenc.cdufende
    FIELD nrcepend LIKE crapenc.nrcepend
    FIELD nmrepsol AS CHAR FORMAT "x(40)"
    FIELD nrcrcard LIKE crawcrd.nrcrcard
    FIELD nrcpftit LIKE crawcrd.nrcpftit
    FIELD nmtitcrd LIKE crawcrd.nmtitcrd
    FIELD nmprimtl LIKE crapass.nmprimtl
    FIELD dsemsctr AS CHAR FORMAT "x(50)"
    FIELD dsmotivo AS CHAR FORMAT "x(20)"
    FIELD nrrepcar LIKE crawcrd.nrrepsen
    FIELD dsrepcar AS CHAR
    FIELD cdcooper LIKE crapcop.cdcooper.

DEFINE TEMP-TABLE tt-segviasen-cartao NO-UNDO
    FIELD nome     AS CHAR FORMAT "x(40)"
    FIELD cnpj     AS DEC FORMAT "zz,zzz,zzz,zzzz,zz"
    FIELD nrrepent LIKE crawcrd.nrrepent
    FIELD nrcpfcgc LIKE crapass.nrcpfcgc
    FIELD nmrescop LIKE crapcop.nmrescop
    FIELD nmextcop LIKE crapcop.nmextcop
    FIELD nrdocnpj LIKE crapcop.nrdocnpj
    FIELD dsendere LIKE crapenc.dsendere
    FIELD nrendere LIKE crapenc.nrendere
    FIELD nmbairro LIKE crapenc.nmbairro
    FIELD nmcidade LIKE crapenc.nmcidade
    FIELD cdufende LIKE crapenc.cdufende
    FIELD nrcepend LIKE crapenc.nrcepend
    FIELD nmrepsol AS CHAR FORMAT "x(40)"
    FIELD nrcrcard LIKE crawcrd.nrcrcard
    FIELD nrcpftit LIKE crawcrd.nrcpftit
    FIELD nmtitcrd LIKE crawcrd.nmtitcrd
    FIELD nmprimtl LIKE crapass.nmprimtl
    FIELD dsemsctr AS CHAR FORMAT "x(50)"
    FIELD dsmotivo AS CHAR FORMAT "x(20)"
    FIELD nrrepsen LIKE crawcrd.nrrepcar 
    FIELD dsrepsen AS CHAR
    FIELD cdcooper LIKE crapcop.cdcooper.

DEFINE TEMP-TABLE tt-termocan-cartao NO-UNDO
    FIELD nome     AS CHAR FORMAT "x(40)"
    FIELD cnpj     AS DEC FORMAT "zz,zzz,zzz,zzzz,zz"
    FIELD nrrepent LIKE crawcrd.nrrepent
    FIELD nrcpfcgc LIKE crapass.nrcpfcgc
    FIELD nmrescop LIKE crapcop.nmrescop
    FIELD nmextcop LIKE crapcop.nmextcop
    FIELD nrdocnpj LIKE crapcop.nrdocnpj
    FIELD dsendere LIKE crapenc.dsendere
    FIELD nrendere LIKE crapenc.nrendere
    FIELD nmbairro LIKE crapenc.nmbairro
    FIELD nmcidade LIKE crapenc.nmcidade
    FIELD cdufende LIKE crapenc.cdufende
    FIELD nrcepend LIKE crapenc.nrcepend
    FIELD nmrepsol AS CHAR FORMAT "x(40)"
    FIELD nrcrcard LIKE crawcrd.nrcrcard
    FIELD nrcpftit LIKE crawcrd.nrcpftit
    FIELD nmtitcrd LIKE crawcrd.nmtitcrd
    FIELD nmprimtl LIKE crapass.nmprimtl
    FIELD dsemsctr AS CHAR FORMAT "x(50)"
    FIELD dsmotivo AS CHAR FORMAT "x(20)"
    FIELD nrrepcan LIKE crawcrd.nrrepcan
    FIELD dsrepcan AS CHAR
    FIELD cdcooper LIKE crapcop.cdcooper
    FIELD nmresadm LIKE crapadc.nmresadm.

DEFINE TEMP-TABLE tt-alt-limite-pj NO-UNDO
    FIELD nome     AS CHAR FORMAT "x(50)"
    FIELD cnpj     AS DEC FORMAT "zz,zzz,zzz,zzzz,zz"
    FIELD nrrepent LIKE crawcrd.nrrepent
    FIELD nrcpfcgc LIKE crapass.nrcpfcgc
    FIELD nmrescop LIKE crapcop.nmrescop
    FIELD nmextcop LIKE crapcop.nmextcop
    FIELD nrdocnpj LIKE crapcop.nrdocnpj
    FIELD dsendere LIKE crapenc.dsendere
    FIELD nrendere LIKE crapenc.nrendere
    FIELD nmbairro LIKE crapenc.nmbairro
    FIELD nmcidade LIKE crapenc.nmcidade
    FIELD cdufende LIKE crapenc.cdufende
    FIELD nrcepend LIKE crapenc.nrcepend
    FIELD nmrepsol AS CHAR FORMAT "x(40)"
    FIELD nrcrcard LIKE crawcrd.nrcrcard
    FIELD nrcpftit LIKE crawcrd.nrcpftit
    FIELD nmtitcrd LIKE crawcrd.nmtitcrd
    FIELD nmprimtl LIKE crapass.nmprimtl
    FIELD dsemsctr AS CHAR FORMAT "x(50)"
    FIELD dsmotivo AS CHAR FORMAT "x(20)"
    FIELD cdcooper LIKE crapcop.cdcooper
    FIELD nrreplim LIKE crawcrd.nrreplim
    FIELD vllimcrd LIKE craptlc.vllimcrd.

DEFINE TEMP-TABLE tt-alt-dtvenc-pj NO-UNDO
    FIELD nome     AS CHAR FORMAT "x(50)"
    FIELD cnpj     AS DEC FORMAT "zz,zzz,zzz,zzzz,zz"
    FIELD nrrepent LIKE crawcrd.nrrepent
    FIELD nrcpfcgc LIKE crapass.nrcpfcgc
    FIELD nmrescop LIKE crapcop.nmrescop
    FIELD nmextcop LIKE crapcop.nmextcop
    FIELD nrdocnpj LIKE crapcop.nrdocnpj
    FIELD dsendere LIKE crapenc.dsendere
    FIELD nrendere LIKE crapenc.nrendere
    FIELD nmbairro LIKE crapenc.nmbairro
    FIELD nmcidade LIKE crapenc.nmcidade
    FIELD cdufende LIKE crapenc.cdufende
    FIELD nrcepend LIKE crapenc.nrcepend
    FIELD nmrepsol AS CHAR FORMAT "x(40)"
    FIELD nrcrcard LIKE crawcrd.nrcrcard
    FIELD nrcpftit LIKE crawcrd.nrcpftit
    FIELD nmtitcrd LIKE crawcrd.nmtitcrd
    FIELD nmprimtl LIKE crapass.nmprimtl
    FIELD dsemsctr AS CHAR FORMAT "x(50)"
    FIELD dsmotivo AS CHAR FORMAT "x(20)"
    FIELD nrrepven LIKE crawcrd.nrrepven
    FIELD dddebito LIKE crawcrd.dddebito
    FIELD cdcooper LIKE crapcop.cdcooper.


DEFINE TEMP-TABLE tt-extrato-cartao NO-UNDO
    FIELD cdcooper LIKE crapecv.cdcooper
    FIELD nrcrcard LIKE crapecv.nrcrcard
    FIELD nrdconta LIKE crapecv.nrdconta
    FIELD nmtitcrd LIKE crapecv.nmtitcrd /* Nome no Cartao */
    FIELD nmprimtl AS CHAR               /* Nome Titular Conta */
    FIELD dtvencto LIKE crapecv.dtvencto
    FIELD dtcompra LIKE crapecv.dtcompra
    FIELD cdmoedtr LIKE crapecv.cdmoedtr
    FIELD dsatvcom LIKE crapecv.dsatvcom
    FIELD dsestabe LIKE crapecv.dsestabe
    FIELD nmcidade LIKE crapecv.nmcidade
    FIELD cdufende LIKE crapecv.cdufende
    FIELD idseqinc LIKE crapecv.idseqinc
    FIELD indebcre LIKE crapecv.indebcre
    FIELD nmarqimp LIKE crapecv.nmarqimp
    FIELD tpatvcom LIKE crapecv.tpatvcom
    FIELD vlcpaori LIKE crapecv.vlcpaori
    FIELD vlcparea LIKE crapecv.vlcparea
    FIELD dtmvtolt LIKE crapecv.dtmvtolt
    FIELD vllimite AS DECI              /* Valor do Limite do Cartao */
    FIELD cdcritic LIKE crapecv.cdcritic
    FIELD cdoperad LIKE crapecv.cdoperad
    FIELD cdtransa LIKE crapecv.cdtransa.

DEFINE TEMP-TABLE tt-cartao NO-UNDO
    FIELD nmrescop LIKE crapcop.nmrescop
    FIELD nrdconta LIKE crawcrd.nrdconta
    FIELD nrcrcard LIKE crawcrd.nrcrcard
    FIELD nmtitcrd LIKE crawcrd.nmtitcrd
    FIELD cdadmcrd LIKE crawcrd.cdadmcrd
    FIELD nmextttl LIKE crapass.nmprimtl
    FIELD nmplastc LIKE crawcrd.nmtitcrd
    FIELD cdagenci LIKE crawcrd.cdagenci
    FIELD nrdctitg LIKE crapass.nrdctitg
    FIELD insitcrd AS   CHAR. 

DEFINE TEMP-TABLE tt-periodos NO-UNDO
    FIELD cdseqper AS INT
    FIELD dsperiod AS CHAR.

DEFINE TEMP-TABLE tt-cartoes-filtro NO-UNDO
    FIELD nrcrexib AS   CHAR FORMAT "x(20)"   
    FIELD nrcarres AS   DECIMAL FORMAT "zzzzzzz9".

DEFINE TEMP-TABLE tt-dados-cartao NO-UNDO
    FIELD dddebito LIKE crawcrd.dddebito    /* Dia de débto */
    FIELD vllimcrd LIKE crawcrd.vllimcrd    /* Limite Proposto */
    FIELD tpenvcrd LIKE crawcrd.tpenvcrd    /* Tipo de Envio */
    FIELD tpdpagto LIKE crawcrd.tpdpagto    /* Forma de Pagamento */
    FIELD nmempcrd LIKE crawcrd.nmempcrd    /* Empresa Plastico */
    FIELD flgdebit LIKE crawcrd.flgdebit.   /* Funcao Debito */

DEFINE TEMP-TABLE tt-dados-admin NO-UNDO
    FIELD dsaadmin AS CHAR    
    FIELD dsnadmin AS CHAR.   
/*...........................................................................*/
