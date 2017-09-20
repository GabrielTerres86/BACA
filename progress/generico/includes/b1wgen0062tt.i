/*.............................................................................

    Programa: b1wgen0062tt.i
    Autor   : Jose Luis
    Data    : Marco/2010                   Ultima atualizacao: 20/04/2017

    Objetivo  : Definicao das Temp-Tables para impressao da FICHA CADASTRAL

    Alteracoes: 18/08/2011 - Adicionado campos nrdoapto e cddbloco em 
                             tt-fcad (Jorge).
                             
                03/04/2012 - Retirado campo nranores e acidionado campo dtinires,
                             dtabrres e dstemres de tt-fcad. (Jorge)
                             
                25/04/2012 - Incluido os campos:
                             - flgdepec, persocio, inhabmen, dthabmen, dshabmen,
                               cpfprocu na tabela tt-fcad-procu;
                             - nrcpfmen na tabela tt-fcad-respl
                             Ajustado o nome dos fields da tabela tt-fcad-respl
                             para antender a tabela crapcrl (Resp. Legal)
                             (Adriano).
                             
                25/04/2013 - Incluir campo cdufnatu na tt-fcad-psfis (Lucas R.)
                 
                02/07/2013 - Inclusao tt-fcad-poderes (Jean Michel) .
                
                23/05/2014 - Adicionado campo nrcpfcgc em tt-fcad-poder.
                             (Jorge/Rosangela) - SD 155408
                             
                12/08/2015 - Projeto Reformulacao cadastral
                             Eliminado o campo nmdsecao (Tiago Castro - RKAM).
                             
                19/04/2017 - Alteraçao DSNACION pelo campo CDNACION.
                             PRJ339 - CRM (Odirlei-AMcom)             
                             

				20/04/2017 - Ajuste para retirar o uso de campos removidos da tabela
			                 crapass, crapttl, crapjur 
							(Adriano - P339).

.............................................................................*/



/*...........................................................................*/

/* Inicio - Dados comuns a PF e PJ */
DEFINE TEMP-TABLE tt-fcad NO-UNDO
    /* f_identi */
    FIELD nmextcop AS CHAR
    FIELD nrdconta AS CHAR 
    FIELD dsagenci AS CHAR 
    FIELD nrmatric AS CHAR 
    /* f_cadast */
    FIELD dsmvtolt AS CHAR
    FIELD nmprimtl AS CHAR
    /* f_responsa */
    FIELD dsoperad AS CHAR
    /* f_endereco */
    FIELD incasprp AS INTE
    FIELD dscasprp AS CHAR
    FIELD dtinires AS DATE
    FIELD vlalugue AS DECI
    FIELD nrcepend AS CHAR
    FIELD dsendere AS CHAR
    FIELD nrendere AS INTE
    FIELD complend AS CHAR
    FIELD nmbairro AS CHAR
    FIELD nmcidade AS CHAR
    FIELD cdufende AS CHAR
    FIELD nrcxapst AS INTE
    FIELD inpessoa AS INTE
    FIELD nrdoapto AS INTE
    FIELD cddbloco AS CHAR
    FIELD dtabrres AS CHAR
    FIELD dstemres AS CHAR
    FIELD dscidade LIKE crapmun.dscidade.

DEFINE TEMP-TABLE tt-fcad-telef NO-UNDO
    /* f_telefones */
    FIELD dsopetfn AS CHAR
    FIELD nrdddtfc AS INTE 
    FIELD nrtelefo AS DECI
    FIELD nrdramal AS INTE
    FIELD tptelefo AS CHAR
    FIELD secpscto AS CHAR
    FIELD nmpescto AS CHAR.

DEFINE TEMP-TABLE tt-fcad-email NO-UNDO
    /* f_emails */
    FIELD dsdemail AS CHAR
    FIELD secpscto AS CHAR
    FIELD nmpescto AS CHAR.

DEFINE TEMP-TABLE tt-fcad-poder NO-UNDO
    /* f_poder */
    FIELD nrdconta AS INT
    FIELD nrctapro AS INT
    FIELD nrcpfcgc AS CHAR
    FIELD dscpoder AS CHAR
    FIELD flgisola AS CHAR
    FIELD flgconju AS CHAR
    FIELD dsoutpod AS CHAR.
/* Fim - Dados comuns a PF e PJ */

/* Inicio - Dados PF */
DEFINE TEMP-TABLE tt-fcad-psfis NO-UNDO
    /* f_dados_pf */
    FIELD nmextttl AS CHAR
    FIELD inpessoa AS INTE
    FIELD dspessoa AS CHAR 
    FIELD nrcpfcgc AS CHAR
    FIELD dtcnscpf AS DATE
    FIELD cdsitcpf AS INTE
    FIELD dssitcpf AS CHAR
    FIELD tpdocttl AS CHAR
    FIELD nrdocttl AS CHAR
    FIELD cdoedttl AS CHAR
    FIELD cdufdttl AS CHAR
    FIELD dtemdttl AS DATE 
    FIELD dtnasttl AS DATE 
    FIELD cdsexotl AS CHAR 
    FIELD tpnacion AS INTE 
    FIELD restpnac AS CHAR 
    FIELD dsnacion AS CHAR 
    FIELD dsnatura AS CHAR 
    FIELD inhabmen AS INTE 
    FIELD dshabmen AS CHAR 
    FIELD dthabmen AS DATE 
    FIELD cdgraupr AS INTE 
    FIELD dsgraupr AS CHAR 
    FIELD cdestcvl AS INTE 
    FIELD dsestcvl AS CHAR   
    FIELD grescola AS INTE 
    FIELD dsescola AS CHAR 
    FIELD cdfrmttl AS INTE 
    FIELD rsfrmttl AS CHAR 
    FIELD nmtalttl AS CHAR 
    FIELD qtfoltal AS INTE
    FIELD nmprimtl AS CHAR
    FIELD cdufnatu LIKE crapttl.cdufnatu
    FIELD inpolexp AS INTE.
     
DEFINE TEMP-TABLE tt-fcad-filia NO-UNDO
    /* f_filiacao */
    FIELD nmmaettl AS CHAR
    FIELD nmpaittl AS CHAR.

DEFINE TEMP-TABLE tt-fcad-comer NO-UNDO
    /* f_comercial_pf */
    FIELD cdnatopc AS INTE
    FIELD rsnatocp AS CHAR
    FIELD cdocpttl AS INTE
    FIELD rsocupa  AS CHAR
    FIELD tpcttrab AS INTE
    FIELD dsctrtab AS CHAR
    FIELD cdempres AS INTE
    FIELD nmresemp AS CHAR
    FIELD nmextemp AS CHAR
    FIELD nrcgcemp AS CHAR
    FIELD dsproftl AS CHAR
    FIELD cdnvlcgo AS INTE
    FIELD rsnvlcgo AS CHAR
    FIELD nrcepend AS CHAR
    FIELD dsendere AS CHAR
    FIELD nrendere AS INTE
    FIELD complend AS CHAR
    FIELD nmbairro AS CHAR
    FIELD nmcidade AS CHAR
    FIELD cdufende AS CHAR
    FIELD nrcxapst AS INTE
    FIELD cdturnos AS INTE
    FIELD dtadmemp AS DATE
    FIELD vlsalari AS DECI
    FIELD tpdrend1 AS INTE 
    FIELD dstipre1 AS CHAR
    FIELD vldrend1 AS DECI
    FIELD tpdrend2 AS INTE
    FIELD dstipre2 AS CHAR
    FIELD vldrend2 AS DECI
    FIELD tpdrend3 AS INTE
    FIELD dstipre3 AS CHAR
    FIELD vldrend3 AS DECI
    FIELD tpdrend4 AS INTE
    FIELD dstipre4 AS CHAR
    FIELD vldrend4 AS DECI

    FIELD cdocupacao       LIKE tbcadast_politico_exposto.cdocupacao
    FIELD cdrelacionamento LIKE tbcadast_politico_exposto.cdrelacionamento
    FIELD dtinicio         LIKE tbcadast_politico_exposto.dtinicio
    FIELD dttermino        LIKE tbcadast_politico_exposto.dttermino
    FIELD nmempresa        LIKE tbcadast_politico_exposto.nmempresa
    FIELD nmpolitico       LIKE tbcadast_politico_exposto.nmpolitico
    FIELD nrcnpj_empresa   LIKE tbcadast_politico_exposto.nrcnpj_empresa
    FIELD nrcpf_politico   LIKE tbcadast_politico_exposto.nrcpf_politico
    FIELD tpexposto        LIKE tbcadast_politico_exposto.tpexposto
    FIELD dsdocupa         LIKE gncdocp.dsdocupa
    FIELD dsrelacionamento AS CHAR
    FIELD nmextttl         AS CHAR.

DEFINE TEMP-TABLE tt-fcad-cbens NO-UNDO
    FIELD dsrelbem AS CHAR
    FIELD persemon AS DECI
    FIELD qtprebem AS INTE
    FIELD vlprebem AS DECI
    FIELD vlrdobem AS DECI.

DEFINE TEMP-TABLE tt-fcad-depen NO-UNDO
    FIELD nmdepend LIKE crapdep.nmdepend
    FIELD tpdepend LIKE crapdep.tpdepend
    FIELD dtnascto LIKE crapdep.dtnascto
    FIELD dstextab AS CHAR.

DEFINE TEMP-TABLE tt-fcad-ctato NO-UNDO
    FIELD nrdctato AS CHAR
    FIELD nmdavali AS CHAR
    FIELD nrcepend AS CHAR
    FIELD dsendere AS CHAR
    FIELD nrendere AS INTE
    FIELD complend AS CHAR
    FIELD nmbairro AS CHAR
    FIELD nmcidade AS CHAR
    FIELD cdufende AS CHAR
    FIELD nrcxapst AS INTE
    FIELD nrtelefo AS CHAR
    FIELD dsdemail AS CHAR.

DEFINE TEMP-TABLE tt-fcad-respl NO-UNDO 
    FIELD nrdconta AS CHAR
    FIELD nrcpfcgc AS CHAR
    FIELD nmrespon LIKE crapcrl.nmrespon
    FIELD tpdeiden LIKE crapcrl.tpdeiden
    FIELD nridenti LIKE crapcrl.nridenti
    FIELD dsorgemi AS CHAR
    FIELD cdufiden LIKE crapcrl.cdufiden
    FIELD dtemiden LIKE crapcrl.dtemiden
    FIELD dtnascin LIKE crapcrl.dtnascin
    FIELD cddosexo AS CHAR 
    FIELD cdestciv LIKE crapcrl.cdestciv
    FIELD dsestciv AS CHAR
    FIELD dsnacion LIKE crapnac.dsnacion
    FIELD dsnatura LIKE crapcrl.dsnatura
    FIELD cdcepres AS CHAR
    FIELD dsendres LIKE crapcrl.dsendres
    FIELD nrendres LIKE crapcrl.nrendres
    FIELD dscomres LIKE crapcrl.dscomres
    FIELD dsbaires LIKE crapcrl.dsbaires
    FIELD dscidres LIKE crapcrl.dscidres
    FIELD dsdufres LIKE crapcrl.dsdufres
    FIELD nrcxpost LIKE crapcrl.nrcxpost
    FIELD nmmaersp LIKE crapcrl.nmmaersp
    FIELD nmpairsp LIKE crapcrl.nmpairsp
    FIELD nrcpfmen LIKE crapcrl.nrcpfmen
    FIELD nrctamen LIKE crapcrl.nrctamen
    FIELD cdnacion LIKE crapcrl.cdnacion.

DEFINE TEMP-TABLE tt-fcad-cjuge NO-UNDO
    FIELD nrctacje AS CHAR
    FIELD nmconjug LIKE crapcje.nmconjug 
    FIELD nrcpfcje AS CHAR /*crapcje.nrcpfcjg*/
    FIELD dtnasccj LIKE crapcje.dtnasccj
    FIELD tpdoccje LIKE crapcje.tpdoccje
    FIELD nrdoccje LIKE crapcje.nrdoccje
    FIELD cdoedcje AS CHAR
    FIELD cdufdcje LIKE crapcje.cdufdcje
    FIELD dtemdcje LIKE crapcje.dtemdcje
    FIELD gresccje LIKE crapcje.grescola
    FIELD dsescola AS CHAR
    FIELD cdfrmttl LIKE crapcje.cdfrmttl
    FIELD rsfrmttl AS CHAR
    FIELD cdnatopc LIKE crapcje.cdnatopc
    FIELD rsnatocp AS CHAR
    FIELD cdocpttl LIKE crapcje.cdocpcje
    FIELD rsocupa  AS CHAR     
    FIELD tpcttrab LIKE crapcje.tpcttrab
    FIELD dsctrtab AS CHAR
    FIELD nmextemp LIKE crapcje.nmextemp
    FIELD nrcpfemp AS CHAR /*crapcje.nrdocnpj*/    
    FIELD dsproftl LIKE crapcje.dsproftl
    FIELD cdnvlcgo LIKE crapcje.cdnvlcgo
    FIELD rsnvlcgo AS CHAR
    FIELD nrfonemp LIKE crapcje.nrfonemp
    FIELD nrramemp LIKE crapcje.nrramemp
    FIELD cdturnos LIKE crapcje.cdturnos
    FIELD dtadmemp LIKE crapcje.dtadmemp
    FIELD vlsalari LIKE crapcje.vlsalari.

/* Fim - Dados PF */

/* Inicio - Dados PJ */
DEFINE TEMP-TABLE tt-fcad-psjur NO-UNDO
    /* f_dados_pj */
    FIELD nmprimtl AS CHAR 
    FIELD inpessoa AS INTE 
    FIELD dspessoa AS CHAR 
    FIELD nmfansia AS CHAR 
    FIELD nrcpfcgc AS CHAR 
    FIELD dtcnscpf AS DATE
    FIELD cdsitcpf AS INTE
    FIELD dssitcpf AS CHAR 
    FIELD natjurid AS INTE
    FIELD dsnatjur AS CHAR 
    FIELD qtfilial AS INTE
    FIELD qtfuncio AS INTE
    FIELD dtiniatv AS DATE
    FIELD cdseteco AS INTE
    FIELD nmseteco AS CHAR
    FIELD cdrmativ AS INTE
    FIELD dsrmativ AS CHAR
    FIELD dsendweb AS CHAR
    FIELD nmtalttl AS CHAR
    FIELD qtfoltal AS INTE.

DEFINE TEMP-TABLE tt-fcad-regis NO-UNDO
    /* f_registro_pj */
    FIELD vlfatano AS DECI
    FIELD vlcaprea AS DECI
    FIELD nrregemp AS DECI
    FIELD dtregemp AS DATE
    FIELD orregemp AS CHAR
    FIELD nrinsmun AS DECI
    FIELD dtinsnum AS DATE
    FIELD nrinsest AS CHAR
    FIELD flgrefis AS CHAR FORMAT "Sim/Nao"
    FIELD perfatcl AS DECI
    FIELD nrcdnire AS DECI.

DEFINE TEMP-TABLE tt-fcad-procu NO-UNDO
    /* f_procuradores_pj e f_procuradores_pf*/
    FIELD nrdctato AS DEC
    FIELD nrcpfcgc AS CHAR
    FIELD nmdavali AS CHAR
    FIELD tpdocava AS CHAR
    FIELD nrdocava AS CHAR
    FIELD cdoeddoc AS CHAR
    FIELD cdufddoc AS CHAR
    FIELD dtemddoc AS DATE
    FIELD dtnascto AS DATE
    FIELD cdsexcto AS CHAR
    FIELD cdestcvl AS INTE
    FIELD dsestcvl AS CHAR
    FIELD dsnacion AS CHAR
    FIELD dsnatura AS CHAR
    FIELD nrcepend AS CHAR
    FIELD dsendere AS CHAR
    FIELD nrendere AS INTE
    FIELD complend AS CHAR
    FIELD nmbairro AS CHAR
    FIELD nmcidade AS CHAR
    FIELD cdufende AS CHAR
    FIELD nrcxapst AS INTE
    FIELD nmmaecto AS CHAR
    FIELD nmpaicto AS CHAR
    FIELD vledvmto AS DECI
    FIELD dtvalida AS CHAR
    FIELD dsproftl AS CHAR
    FIELD flgdepec AS LOG
    FIELD persocio AS DEC
    FIELD inhabmen AS INT 
    FIELD dthabmen AS DATE
    FIELD dshabmen AS CHAR
    FIELD cpfprocu AS DEC
    FIELD cdnacion AS INTE.
    

DEFINE TEMP-TABLE tt-fcad-bensp NO-UNDO
    /* f_bens */
    FIELD nrcpfcgc AS CHAR
    FIELD dsrelbem AS CHAR
    FIELD persemon AS DECI
    FIELD qtprebem AS INTE
    FIELD vlprebem AS DECI
    FIELD vlrdobem AS DECI.

DEFINE TEMP-TABLE tt-fcad-refer NO-UNDO
    /* f_referencias_pj */
    FIELD nrdctato AS CHAR
    FIELD nmdavali AS CHAR
    FIELD nmextemp AS CHAR
    FIELD cddbanco AS INTE
    FIELD dsdbanco AS CHAR
    FIELD cdagenci AS INTE
    FIELD dsproftl AS CHAR
    FIELD nrcepend AS CHAR
    FIELD dsendere AS CHAR
    FIELD nrendere AS INTE
    FIELD complend AS CHAR
    FIELD nmbairro AS CHAR
    FIELD nmcidade AS CHAR
    FIELD cdufende AS CHAR
    FIELD nrcxapst AS INTE
    FIELD nrtelefo AS CHAR
    FIELD dsdemail AS CHAR.

/* Fim - Dados PJ */

&IF DEFINED(SESSAO-BO) &THEN

&ENDIF


