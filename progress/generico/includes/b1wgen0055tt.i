/*..............................................................................

    Programa: b1wgen0055tt.i
    Autor   : Jose Luis
    Data    : Janeiro/2010                   Ultima atualizacao: 19/04/2017

    Objetivo  : Definicao das Temp-Tables

    Alteracoes: 17/05/2012 - Criado a temp-table tt-resp_legal e incluido os 
                             campos nrdeanos, nrdmeses, dsdidade na tabela
                             tt-dados-fis (Adriano).
                             
                12/08/2013 - Incluido campo cdufnatu na temp-table tt-dados-fis.
                             (Reinert)
                             
                27/07/2015 - Reformulacao cadastral (Gabriel-RKAM)             
                
				19/04/2017 - Ajuste para retirar o uso de campos removidos da tabela
			                 crapass, crapttl, crapjur 
							(Adriano - P339).             
                
                19/04/2017 - Alteraçao DSNACION pelo campo CDNACION.
                             PRJ339 - CRM (Odirlei-AMcom)    

                21/07/2017 - Alteraçao CDOEDTTL pelo campo IDORGEXP.
                             PRJ339 - CRM (Odirlei-AMcom)          

..............................................................................*/

                                                                             
DEFINE TEMP-TABLE tt-dados-fis NO-UNDO
    FIELD nrctattl LIKE crapttl.nrdconta
    FIELD idseqttl LIKE crapttl.idseqttl
    FIELD cdgraupr AS INTEGER FORMAT ">"
    FIELD nrcpfcgc LIKE crapttl.nrcpfcgc
    FIELD dspessoa AS CHARACTER              
    FIELD dssitcpf AS CHARACTER              
    FIELD cdoedttl AS CHARACTER              
    FIELD dtnasttl LIKE crapttl.dtnasttl     
    FIELD destpnac AS CHARACTER              
    FIELD inhabmen LIKE crapttl.inhabmen    
    FIELD dsgraupr AS CHARACTER              
    FIELD dsestcvl AS CHARACTER          
    FIELD cdfrmttl LIKE crapttl.cdfrmttl 
    FIELD nmtalttl LIKE crapttl.nmtalttl 
    FIELD qtfoltal LIKE crapass.qtfoltal 
    FIELD nmextttl LIKE crapttl.nmextttl 
    FIELD dtcnscpf LIKE crapttl.dtcnscpf 
    FIELD tpdocttl LIKE crapttl.tpdocttl 
    FIELD cdufdttl LIKE crapttl.cdufdttl 
    FIELD cdsexotl LIKE crapttl.cdsexotl
    FIELD dsnacion AS CHARACTER          
    FIELD dshabmen AS CHARACTER          
    FIELD cdestcvl LIKE crapttl.cdestcvl
    FIELD grescola LIKE crapttl.grescola
    FIELD rsfrmttl LIKE gncdfrm.rsfrmttl
    FIELD inpessoa LIKE crapass.inpessoa
    FIELD cdsitcpf LIKE crapass.cdsitcpf
    FIELD nrdocttl LIKE crapttl.nrdocttl
    FIELD dtemdttl LIKE crapttl.dtemdttl
    FIELD tpnacion LIKE crapttl.tpnacion
    FIELD dsnatura LIKE crapttl.dsnatura
    FIELD cdufnatu LIKE crapttl.cdufnatu
    FIELD dthabmen LIKE crapttl.dthabmen
    FIELD dsescola AS CHARACTER
    FIELD cdnatopc LIKE crapttl.cdnatopc
    FIELD cdocpttl LIKE crapttl.cdocpttl
    FIELD tpcttrab LIKE crapttl.tpcttrab
    FIELD nmextemp LIKE crapttl.nmextemp
    FIELD nrcpfemp LIKE crapttl.nrcpfemp
    FIELD dsproftl LIKE crapttl.dsproftl
    FIELD cdnvlcgo LIKE crapttl.cdnvlcgo
    FIELD cdturnos LIKE crapttl.cdturnos
    FIELD dtadmemp LIKE crapttl.dtadmemp
    FIELD vlsalari LIKE crapttl.vlsalari
    FIELD msgconta AS CHARACTER
    FIELD nrdeanos AS INT
    FIELD nrdmeses AS INT
    FIELD dsdidade AS CHAR
    FIELD idorgexp AS INT 
    FIELD cdnacion AS INTEGER.
                
&IF DEFINED(TT-LOG) <> 0 &THEN

    DEFINE TEMP-TABLE tt-dados-fis-ant NO-UNDO LIKE tt-dados-fis.

    DEFINE TEMP-TABLE tt-dados-fis-atl NO-UNDO LIKE tt-dados-fis-ant.

&ENDIF

/*............................................................................*/

