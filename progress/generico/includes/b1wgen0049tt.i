/*..............................................................................

    Programa: b1wgen0049tt.i
    Autor   : David
    Data    : Novembro/2009                   Ultima atualizacao: 00/00/0000   

    Objetivo  : 

    Alteracoes: 
   
..............................................................................*/

                                                                               
DEF TEMP-TABLE tt-contato-juridica NO-UNDO
    FIELD nrdctato LIKE crapavt.nrdctato
    FIELD nmdavali LIKE crapavt.nmdavali
    FIELD nrtelefo LIKE crapavt.nrtelefo
    FIELD dsdemail LIKE crapavt.dsdemail
    FIELD cddctato AS CHAR
    FIELD nrdrowid AS ROWID.

DEF TEMP-TABLE tt-contato-jur NO-UNDO
    FIELD nrdctato LIKE crapavt.nrdctato
    FIELD nmdavali LIKE crapavt.nmdavali
    FIELD nmextemp LIKE crapavt.nmextemp
    FIELD cddbanco LIKE crapavt.cddbanco
    FIELD cdageban LIKE crapavt.cdagenci
    FIELD dsproftl LIKE crapavt.dsproftl
    FIELD nrcepend LIKE crapavt.nrcepend
    FIELD dsendere LIKE crapavt.dsendres[1]
    FIELD nrendere LIKE crapavt.nrendere
    FIELD complend LIKE crapavt.complend
    FIELD nmbairro LIKE crapavt.nmbairro
    FIELD nmcidade LIKE crapavt.nmcidade
    FIELD cdufende LIKE crapavt.cdufresd
    FIELD nrcxapst LIKE crapavt.nrcxapst
    FIELD nrtelefo LIKE crapavt.nrfonres
    FIELD dsdemail LIKE crapavt.dsdemail
    FIELD nmdbanco LIKE crapban.nmresbcc
    FIELD nmageban LIKE crapagb.nmageban
    FIELD nrdrowid AS ROWID.

                                                                             
/*............................................................................*/
