/*..............................................................................

    Programa: b1wgen0053tt.i
    Autor   : Jose Luis
    Data    : Janeiro/2010                   Ultima atualizacao: 25/10/2015   

    Objetivo  : Definicao das Temp-Tables para tela contas_dados_juridica.p

    Alteracoes: 23/07/2015 - Reformulacao cadastral (Gabriel-RKAM).
	            
				01/02/2016 - Melhoria 147 - Adicionar Campos e Aprovacao de
				             Transferencia entre PAs (Heitor - RKAM)
   
                25/10/2016 - Melhoria 310 novos campos na temptable tt-dados-jur
				             (Tiago/Thiago).
..............................................................................*/

                                                                             
DEFINE TEMP-TABLE tt-dados-jur NO-UNDO
    FIELD nmprimtl AS CHAR
    FIELD inpessoa LIKE crapass.inpessoa
    FIELD dspessoa AS CHAR
    FIELD nrcpfcgc AS CHAR
    FIELD dtcnscpf LIKE crapass.dtcnscpf
    FIELD cdsitcpf LIKE crapass.cdsitcpf
    FIELD dssitcpf AS CHAR
    FIELD nmfatasi LIKE crapjur.nmfansia
    FIELD cdnatjur LIKE crapjur.natjurid
    FIELD dsnatjur LIKE gncdntj.dsnatjur
    FIELD cdrmativ LIKE crapjur.cdrmativ
    FIELD dsendweb LIKE crapjur.dsendweb
    FIELD nmtalttl LIKE crapjur.nmtalttl
    FIELD qtfoltal LIKE crapass.qtfoltal
    FIELD qtfilial LIKE crapjur.qtfilial
    FIELD qtfuncio LIKE crapjur.qtfuncio
    FIELD dtiniatv LIKE crapjur.dtiniatv
    FIELD cdseteco LIKE crapjur.cdseteco
    FIELD nmseteco LIKE craptab.dstextab
    FIELD dsrmativ LIKE gnrativ.nmrmativ
    FIELD dtcadass LIKE crapass.dtmvtolt
    FIELD cdclcnae LIKE crapass.cdclcnae
    FIELD nrlicamb AS DECI
	FIELD dtvallic LIKE crapjur.dtvallic
	FIELD idregtrb LIKE crapjur.idregtrb.

&IF DEFINED(TT-LOG) <> 0 &THEN

    DEFINE TEMP-TABLE tt-dados-jur-ant NO-UNDO 
        FIELD qtfoltal LIKE crapass.qtfoltal
        FIELD dtcnscpf LIKE crapass.dtcnscpf
        FIELD cdsitcpf LIKE crapass.cdsitcpf
        FIELD nmfansia LIKE crapjur.nmfansia
        FIELD natjurid LIKE crapjur.natjurid
        FIELD dtiniatv LIKE crapjur.dtiniatv
        FIELD cdrmativ LIKE crapjur.cdrmativ
        FIELD qtfilial LIKE crapjur.qtfilial
        FIELD qtfuncio LIKE crapjur.qtfuncio
        FIELD dsendweb LIKE crapjur.dsendweb
        FIELD nmtalttl LIKE crapjur.nmtalttl
        FIELD cdseteco LIKE crapjur.cdseteco
		FIELD nrlicamb LIKE crapjur.nrlicamb
		FIELD dtvallic LIKE crapjur.dtvallic
		FIELD idregtrb LIKE crapjur.idregtrb.

    DEFINE TEMP-TABLE tt-dados-jur-atl NO-UNDO LIKE tt-dados-jur-ant.

&ENDIF

/*............................................................................*/

