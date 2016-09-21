/*..............................................................................

    Programa: b1wgen0181tt.i
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Oliver - GATI
    Data    : Setembro/2013                        Ultima atualizacao: /  /

    Dados referentes ao programa:

    Objetivo  : Arquivo com variáveis ultizadas na BO b1wgen0181.p       
..............................................................................*/

DEF TEMP-TABLE tt-crapcsg NO-UNDO
    FIELD cdcooper AS INT
    FIELD cdsegura AS INT  FORMAT "zzz,zzz,zz9"
    FIELD nmsegura AS CHAR FORMAT "X(40)" 
    FIELD flgativo AS LOG  FORMAT "Sim/Nao"
    FIELD cdhstaut AS INT  FORMAT "z,zz9" EXTENT 10
    FIELD cdhstcas AS INT  FORMAT "z,zz9" EXTENT 10
    FIELD nmresseg AS CHAR FORMAT "X(20)"
    FIELD nrcgcseg AS DEC  FORMAT "zz,zzz,zzz,zzzz,z9"
    FIELD nrctrato AS INT  FORMAT "zz,zzz,zz9"
    FIELD nrultpra AS INT  FORMAT "zzz,zzz,zz9"
    FIELD nrlimpra AS INT  FORMAT "zzz,zzz,zz9"
    FIELD nrultprc AS INT  FORMAT "zzz,zzz,zz9"
    FIELD nrlimprc AS INT  FORMAT "zzz,zzz,zz9"
    FIELD dsasauto AS CHAR FORMAT "X(40)"
    FIELD dsmsgseg AS CHAR FORMAT "X(60)".

