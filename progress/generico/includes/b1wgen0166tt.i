/*.............................................................................

    Programa: sistema/generico/includes/b1wgen0166tt.i
    Autor   : Oliver Fagionato (GATI)
    Data    : Agosto/2013

    Objetivo  : Definição da BO b1wgen0166.p

    Alteracoes: 21/11/2013 - Alteração para adeguar o fonte no padrão CECRED
                
                17/06/2015 - Prj-158 - Alteracoes no Layout, inclusao de novos campos
                             na tela. (Andre Santos - SUPERO)
                             
                12/08/2015 - Projeto Reformulacao cadastral
                             Eliminado o campo nmdsecao (Tiago Castro - RKAM).
                             
                25/11/2015 - Ajustando a busca dos valores de tarifas dos
                             convenios. (Andre Santos - SUPERO)

                18/05/2016 - Criacao do campo dtlimdeb. (Jaison/Marcos)

				17/04/2017 - Ajuste para retirar o uso de campos removidos da tabela
			                 crapass, crapttl, crapjur 
							(Adriano - P339).

.............................................................................*/

DEF TEMP-TABLE tt-crapemp NO-UNDO 
    FIELD inavscot LIKE crapemp.inavscot
    FIELD inavsemp LIKE crapemp.inavsemp
    FIELD inavsppr LIKE crapemp.inavsppr
    FIELD inavsden LIKE crapemp.inavsden
    FIELD inavsseg LIKE crapemp.inavsseg
    FIELD inavssau LIKE crapemp.inavssau
    FIELD cdempres LIKE crapemp.cdempres
    FIELD nmresemp LIKE crapemp.nmresemp
    FIELD nmextemp LIKE crapemp.nmextemp
    FIELD cdcooper LIKE crapemp.cdcooper
    FIELD tpdebemp LIKE crapemp.tpdebemp
    FIELD tpdebcot LIKE crapemp.tpdebcot
    FIELD tpdebppr LIKE crapemp.tpdebppr
    FIELD cdempfol LIKE crapemp.cdempfol
    FIELD dtavscot LIKE crapemp.dtavscot
    FIELD dtavsemp LIKE crapemp.dtavsemp
    FIELD dtavsppr LIKE crapemp.dtavsppr
    FIELD flgpagto LIKE crapemp.flgpagto
    FIELD tpconven LIKE crapemp.tpconven
    FIELD cdufdemp LIKE crapemp.cdufdemp 
    FIELD dscomple LIKE crapemp.dscomple
    FIELD dsdemail LIKE crapemp.dsdemail
    FIELD dsendemp LIKE crapemp.dsendemp
    FIELD dtfchfol LIKE crapemp.dtfchfol
    FIELD indescsg LIKE crapemp.indescsg
    FIELD nmbairro LIKE crapemp.nmbairro
    FIELD nmcidade LIKE crapemp.nmcidade
    FIELD nrcepend LIKE crapemp.nrcepend
    FIELD nrdocnpj LIKE crapemp.nrdocnpj
    FIELD nrendemp LIKE crapemp.nrendemp
    FIELD nrfaxemp LIKE crapemp.nrfaxemp
    FIELD nrfonemp LIKE crapemp.nrfonemp
    FIELD flgarqrt LIKE crapemp.flgarqrt
    FIELD flgvlddv LIKE crapemp.flgvlddv
    FIELD idtpempr LIKE crapemp.idtpempr
    FIELD nrdconta LIKE crapemp.nrdconta
    FIELD nmcontat LIKE crapemp.nmcontat
    FIELD flgpgtib LIKE crapemp.flgpgtib
    FIELD cdcontar LIKE crapemp.cdcontar
    FIELD vllimfol LIKE crapemp.vllimfol
    FIELD nmextttl LIKE crapass.nmprimtl
    FIELD dscontar LIKE crapcfp.dscontar
    FIELD dtultufp LIKE crapemp.dtultufp
    FIELD dtlimdeb LIKE crapemp.dtlimdeb.

DEF TEMP-TABLE tt-craptab NO-UNDO
    FIELD nmsistem LIKE craptab.nmsistem
    FIELD tptabela LIKE craptab.tptabela
    FIELD cdempres LIKE craptab.cdempres
    FIELD cdacesso LIKE craptab.cdacesso
    FIELD tpregist LIKE craptab.tpregist
    FIELD dstextab LIKE craptab.dstextab
    FIELD cdcooper LIKE craptab.cdcooper.

DEF TEMP-TABLE tt-dados-ass NO-UNDO
    FIELD nmrazsoc LIKE crapass.nmprimtl
    FIELD nmfansia LIKE crapjur.nmfansia
    FIELD nmcontat LIKE crapass.nmprimtl
    FIELD nrcpfcgc LIKE crapass.nrcpfcgc
    FIELD dsdemail LIKE crapcem.dsdemail 
    FIELD dsendere LIKE crapenc.dsendere 
    FIELD nrendere LIKE crapenc.nrendere 
    FIELD complend LIKE crapenc.complend 
    FIELD nmbairro LIKE crapenc.nmbairro 
    FIELD nmcidade LIKE crapenc.nmcidade
    FIELD cdufende LIKE crapenc.cdufende 
    FIELD nrcepend LIKE crapenc.nrcepend.

/* utilizado no zoom de associados */
DEFINE TEMP-TABLE tt-titular NO-UNDO
    FIELD cdcooper LIKE crapttl.cdcooper
    FIELD nrdconta LIKE crapttl.nrdconta
    FIELD cdagenci LIKE crapass.cdagenci
    FIELD nmextttl LIKE crapttl.nmextttl
    FIELD nmprimtl LIKE crapass.nmprimtl
    FIELD nrdctitg LIKE crapass.nrdctitg
    FIELD idseqttl LIKE crapttl.idseqttl
    FIELD nmpesttl LIKE crapttl.nmextttl
    FIELD dtnasttl LIKE crapttl.dtnasttl
    FIELD cdempres LIKE crapttl.cdempres
    FIELD dtdemiss LIKE crapass.dtdemiss
    FIELD nrdocttl AS CHAR
    FIELD dsagenci AS CHAR.

/* utilizado para procuradores */
DEFINE TEMP-TABLE tt-procuradores-emp NO-UNDO
    FIELD idctasel AS LOGICAL
    FIELD nrdctato LIKE crapavt.nrdctato
    FIELD nmprimtl LIKE crapass.nmprimtl
    FIELD nrcpfcgc LIKE crapass.nrcpfcgc
    FIELD dtvalida LIKE crapavt.dtvalida
    FIELD dsproftl LIKE crapavt.dsproftl.

DEF TEMP-TABLE tt-convenio NO-UNDO
    FIELD cdcooper LIKE crapcfp.cdcooper
    FIELD cdcontar LIKE crapcfp.cdcontar
    FIELD dscontar LIKE crapcfp.dscontar
    FIELD vltarid0 AS DECI
    FIELD vltarid1 AS DECI
    FIELD vltarid2 AS DECI.


