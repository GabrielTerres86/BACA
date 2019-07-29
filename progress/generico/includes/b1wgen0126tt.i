/*.............................................................................

    Programa: sistema/generico/includes/b1wgen0126tt.i
    Autor(a): Rogerius Militao (DB1)
    Data    : Dezembro/2011                        Ultima atualizacao: 06/06/2014
  
    Dados referentes ao programa:
  
    Objetivo  : Include com Temp-Tables para a BO b1wgen0126.
  
    Alteracoes: 06/06/2014 - Incluso campos inpessoa e dtnascto na 
                             tabela tt-contrato-avalista (Daniel/Thiago)
                             
                10/06/2014 - Troca do campo crapass.nmconjug 
                             por crapcje.nmconjug. 
                             (Chamado 117414) - (Tiago Castro - RKAM).
    
    
.............................................................................*/ 

DEF TEMP-TABLE tt-infoass NO-UNDO 
    FIELD cdcooper LIKE crapass.cdcooper
    FIELD nrdconta LIKE crapass.nrdconta
    FIELD nmprimtl LIKE crapass.nmprimtl.

DEF TEMP-TABLE tt-contrato NO-UNDO 
    FIELD nrdconta LIKE crapepr.nrdconta
    FIELD nrctremp AS INT  FORMAT "zz,zzz,zz9"
    FIELD dslcremp AS CHAR FORMAT "x(40)"  
    FIELD dsfinemp AS CHAR FORMAT "x(40)"
    FIELD vlemprst LIKE crapepr.vlemprst
    FIELD vlpreemp LIKE crapepr.vlpreemp
    FIELD qtpreemp LIKE crapepr.qtpreemp
    FIELD nrctaav1 LIKE crapepr.nrctaav1
    FIELD nrctaav2 LIKE crapepr.nrctaav2.

DEF TEMP-TABLE tt-contrato-avalista NO-UNDO 
    FIELD nrindice AS INT 
    FIELD nrctaava LIKE crapass.nrdconta 
    FIELD nmdavali LIKE crapass.nmprimtl
    FIELD dscpfava AS CHAR
    FIELD nmcjgava LIKE crapcje.nmconjug
    FIELD dsendava AS CHAR  EXTENT 2 
    FIELD dscfcava AS CHAR
    FIELD nmcidade LIKE crapenc.nmcidade
    FIELD cdufende LIKE crapenc.cdufende
    FIELD nrcepend LIKE crapenc.nrcepend
    FIELD nrendere LIKE crapenc.nrendere
    FIELD nrcxapst LIKE crapenc.nrcxapst
    FIELD complend LIKE crapenc.complend
    FIELD nrcpfcgc LIKE crapavt.nrcpfcgc
    FIELD tpdocava LIKE crapavt.tpdocava
    FIELD nrcpfcjg LIKE crapavt.nrcpfcjg
    FIELD tpdoccjg LIKE crapavt.tpdoccjg
    FIELD nrfonres LIKE crapavt.nrfonres
    FIELD dsdemail LIKE crapavt.dsdemail
    FIELD cdufresd LIKE crapavt.cdufresd
    FIELD inpessoa LIKE crapavt.inpessoa
    FIELD cdnacion LIKE crapass.cdnacion
    FIELD dsnacion LIKE crapnac.dsnacion
    FIELD nrctacjg LIKE crapcje.nrctacje
    FIELD vlrencjg AS DECI
    FIELD vlrenmes LIKE crapavt.vlrenmes
    FIELD dtnascto LIKE crapavt.dtnascto.

DEF TEMP-TABLE tt-avalista NO-UNDO LIKE tt-contrato-avalista.

DEF TEMP-TABLE tt-contrato-imprimir NO-UNDO 
    FIELD nrcpfava AS DECI
    FIELD nmdavali AS CHAR
    FIELD uladitiv AS INT.
