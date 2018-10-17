/*.............................................................................

    Programa: sistema/generico/includes/b1wgen0115tt.i
    Autor(a): Gabriel Capoia dos Santos (DB1)
    Data    : Setembro/2011                      Ultima atualizacao: 30/07/2018
  
    Dados referentes ao programa:
  
    Objetivo  : Include com Temp-Tables para a BO b1wgen0115.
  
    Alteracoes: 15/12/2014 - Adicionado campo tpproapl na temp-table 
                             tt-aplicacoes. (Reinert)
    
                30/10/2017 - Adicionado tpctrato. (Jaison/Marcos Martini - PRJ404)
                
                30/07/2018 - P442 - Inclusão de campos do projeto (Marcos-Envolti)

.............................................................................*/

DEF TEMP-TABLE tt-aditiv NO-UNDO
    FIELD cdaditiv  AS INT     FORMAT "9"                                                   
    FIELD nraditiv  AS INT     FORMAT "z9"                                                  
    FIELD idseqbem  AS INTE    FORMAT "99"                                                  
    FIELD nrsequen  AS INTE    FORMAT "99"                                                  
    FIELD nrctremp  LIKE crapadt.nrctremp                                                   
    FIELD nmprimtl  LIKE crapass.nmprimtl                                                   
    FIELD nrdconta  LIKE crapadi.nrdconta                                                   
    FIELD nrctagar  LIKE crapadt.nrctagar                                                   
    FIELD dtmvtolt  LIKE crapadt.dtmvtolt                                                   
    FIELD flgpagto  AS LOGICAL FORMAT "FOLHA DE PAGTO/CONTA CORRENTE"                       
    FIELD dtdpagto  LIKE crapadi.dtdpagto                                                   
    FIELD dscatbem  LIKE crapadi.dscatbem                       
    FIELD dsmarbem  LIKE crapadi.dsmarbem                       
    FIELD dsbemfin  LIKE crapadi.dsbemfin                                                   
    FIELD dschassi  LIKE crapadi.dschassi                                                   
    FIELD nrdplaca  LIKE crapadi.nrdplaca                                                   
    FIELD dscorbem  LIKE crapadi.dscorbem                                                   
    FIELD nranobem  LIKE crapadi.nranobem                                                   
    FIELD nrmodbem  LIKE crapadi.nrmodbem                                                   
    FIELD dstpcomb  LIKE crapadi.dstpcomb                   
    FIELD vlrdobem  LIKE crapadi.vlrdobem           
    FIELD vlfipbem  LIKE crapadi.vlfipbem           
    FIELD dstipbem  LIKE crapadi.dstipbem          
    FIELD tpaplica  AS INT     FORMAT "9"        EXTENT 20                                  
    FIELD nraplica  AS INT     FORMAT "zzzz,zz9" EXTENT 20                                  
    FIELD impdocir  AS LOGICAL FORMAT "S/N"      INIT TRUE                                  
    FIELD nrrenava  LIKE crapadi.nrrenava                                                   
    FIELD tpchassi  LIKE crapadi.tpchassi                                                   
    FIELD ufdplaca  LIKE crapadi.ufdplaca                                                   
    FIELD uflicenc  LIKE crapadi.uflicenc                                                   
    FIELD nmdavali  LIKE crapadi.nmdavali                                                   
    FIELD nrcpfcgc  LIKE crapadi.nrcpfcgc                                                   
    FIELD nrcpfgar  LIKE crapadt.nrcpfgar                                                   
    FIELD nrdocgar  LIKE crapadt.nrdocgar
    FIELD nmdgaran  LIKE crapadt.nmdgaran
    FIELD nrpromis  AS CHAR    FORMAT "x(20)"           EXTENT 10
    FIELD vlpromis  AS DECIMAL FORMAT "zzz,zzz,zz9.99"  EXTENT 10
    FIELD dsaditiv  AS CHAR    FORMAT "x(36)"
    FIELD dscpfavl  AS CHAR    FORMAT "x(18)"
    FIELD tpdescto  AS INTE    FORMAT 9
    FIELD tpctrato  LIKE crapadt.tpctrato
    FIELD dssitgrv  AS CHAR    FORMAT "x(25)".

DEF TEMP-TABLE tt-aplicacoes NO-UNDO
    FIELD nraplica AS INTE FORMAT "zzz,zz9"
    FIELD dtmvtolt AS DATE FORMAT "99/99/9999"
    FIELD dshistor AS CHAR FORMAT "x(25)"
    FIELD nrdocmto AS CHAR FORMAT "x(12)"
    FIELD dtvencto AS DATE FORMAT "99/99/9999"
    FIELD vlsldapl AS DECI FORMAT "zzz,zzz,zzz,zz9.99-"
    FIELD sldresga AS DECI FORMAT "zzz,zzz,zzz,zz9.99-"
    FIELD flgselec AS LOG
    FIELD tpaplica AS INTE FORMAT "9"
    FIELD vlaplica AS DECI FORMAT "zzz,zzz,zzz,zz9.99"
    FIELD tpproapl AS INTE FORMAT "9".
