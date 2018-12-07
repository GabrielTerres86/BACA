/*..............................................................................

    Programa: b1wgen0175tt.i
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Andre Santos - Supero
    Data    : Setembro/2013                        Ultima atualizacao: 19/08/2016

    Dados referentes ao programa:

    Objetivo  : Arquivo com variáveis ultizadas na BO b1wgen0175.p
               
    Alteracoes: 19/08/2016 - Ajustes referentes a Melhoria 69 - Devolucao automatica 
                             de cheques (Lucas Ranghetti #484923)
				
			    07/12/2018 - Melhoria no processo de devoluções de cheques.
                             Alcemir Mout's (INC0022559).

                            
..............................................................................*/

DEF TEMP-TABLE tt-devolu NO-UNDO
    FIELD cdbccxlt LIKE crapdev.cdbccxlt
    FIELD cdagechq LIKE crapdev.cdagechq
    FIELD nrdconta LIKE crapdev.nrdconta
    FIELD nrcheque LIKE crapdev.nrcheque
    FIELD vllanmto LIKE crapdev.vllanmto
    FIELD cdalinea LIKE crapdev.cdalinea
    FIELD insitdev LIKE crapdev.insitdev
    FIELD dssituac AS CHAR
    FIELD nmoperad LIKE crapope.nmoperad
    FIELD vlaplica AS DECIMAL
    FIELD vlsldprp AS DECIMAL
    FIELD dsaplica AS CHAR 
    FIELD dtliquid AS DATE
    FIELD nrctachq AS DEC
	FIELD cdbandep AS INT
	FIELD cdagedep AS INT
	FIELD nrctadep AS DEC.

DEF TEMP-TABLE tt-telefones NO-UNDO    
    FIELD idseqttl LIKE craptfc.idseqttl
    FIELD nrdddtfc LIKE craptfc.nrdddtfc
    FIELD nrtelefo LIKE craptfc.nrtelefo.
    
DEF TEMP-TABLE tt-emails NO-UNDO    
    FIELD idseqttl LIKE crapcem.idseqttl
    FIELD dsdemail LIKE crapcem.dsdemail.    

DEF TEMP-TABLE tt-lancto NO-UNDO
    FIELD cdcooper AS INT
    FIELD dsbccxlt AS CHAR FORMAT               "x(8)"
    FIELD nrdocmto AS DECI FORMAT         "zz,zzz,zz9"
    FIELD nrdctitg AS CHAR FORMAT        "9.999.999-X"
    FIELD cdbanchq AS INT  FORMAT              "z,zz9"
    FIELD banco    AS INT  FORMAT              "z,zz9"
    FIELD cdagechq AS INT  FORMAT              "z,zz9"
    FIELD nrctachq AS DEC
    FIELD vllanmto AS DECI FORMAT  "zz,zzz,zzz,zz9.99"
    FIELD dssituac AS CHAR FORMAT              "x(10)"
    FIELD cdalinea AS INTE FORMAT                "zz9"
    FIELD nmoperad AS CHAR FORMAT              "x(18)"
    FIELD cddsitua AS INTE FORMAT                "zz9"
    FIELD flag     AS LOGI
    FIELD nrdrecid AS RECID
    FIELD vlaplica AS DECIMAL
    FIELD vlsldprp AS DECIMAL
    FIELD dsaplica AS CHAR
    FIELD dstabela AS CHAR
	FIELD cdbandep AS INT
	FIELD cdagedep AS INT
	FIELD nrctadep AS DEC.
    
DEF TEMP-TABLE tt-desmarcar NO-UNDO    
    FIELD nrcheque AS DEC
    FIELD cdbanchq AS INT
    FIELD cdagechq AS INT
    FIELD cdbandep AS INT
    FIELD cdagedep AS INT
    FIELD nrctadep AS DEC
	FIELD nrdconta AS DEC
    FIELD cdalinea AS INT
    FIELD vllanmto AS DEC
    FIELD nrctachq AS DEC
    FIELD nrdctitg AS DEC
    FIELD nrdrecid AS RECID
    FIELD flag     AS LOG.
 
DEF TEMP-TABLE tt-relchdv NO-UNDO
    FIELD nrdconta LIKE crapass.nrdconta     
    FIELD nmprimtl LIKE crapass.nmprimtl
    FIELD cdpesqui LIKE crapdev.cdpesqui
    FIELD nrcheque LIKE crapdev.nrcheque
    FIELD vllanmto LIKE crapdev.vllanmto
    FIELD cdalinea LIKE crapdev.cdalinea
    FIELD cdagenci LIKE crapass.cdagenci
    FIELD cdoperad LIKE crapope.cdoperad
    FIELD dsorigem AS CHAR FORMAT "x(13)"
    FIELD dstipcta AS CHAR FORMAT "x(15)"
    INDEX nrdconta IS PRIMARY nrdconta
          nrcheque. 
