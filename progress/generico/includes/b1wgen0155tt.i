/*.............................................................................

    Programa: sistema/generico/includes/b1wgen0155tt.i
    Autor(a): Guilherme / SUPERO
    Data    : Abril/2013                     Ultima atualizacao: 17/09/2014 
  
    Dados referentes ao programa:
  
    Objetivo  : Definicao das temp-tables para a tela BLQJUD.
                
  
    Alteracoes: 17/09/2014 - Retirado tt-dados-blq-grid. 
                             (Jorge/Gielow - SD 175038)
                             
.............................................................................*/

DEF TEMP-TABLE tt-cooperado    NO-UNDO
    FIELD cdcooper AS INT
    FIELD nrdconta AS INT
    FIELD nrcpfcgc AS DECI
    FIELD vlsldcap AS DECI   /* VLR CAPITAL */
    FIELD vlsldapl AS DECI   /* VLR APLICACAO */
    FIELD vlsldppr AS DECI   /* VLR POUP. PROGRAMADA */
    FIELD vlstotal AS DECI.  /* VLR CONTA CORRENTE */
    
DEF TEMP-TABLE tt-dados-blq LIKE crapblj 
    FIELD dsmodali AS CHAR
    FIELD vltotblq AS DECI
    FIELD nmrofici AS CHAR
    FIELD dscpfcgc AS CHAR
    FIELD idmodali AS INT
	FIELD dsblqini AS CHAR
    FIELD dsblqfim AS CHAR.
	
DEF TEMP-TABLE tt-dados-blq-oficio NO-UNDO
    FIELD nrdconta AS INT
    FIELD nroficio AS CHAR
    FIELD vlbloque AS DECI.

DEF TEMP-TABLE tt-imprime-bloqueio NO-UNDO
    FIELD cdagenci AS INT
    FIELD nrdconta AS INT
    FIELD nroficio LIKE crapblj.nroficio
    FIELD dtblqini LIKE crapblj.dtblqini
    FIELD dtblqfim LIKE crapblj.dtblqfim
    FIELD dsmodali AS CHAR
    FIELD vlbloque LIKE crapblj.vlbloque
    FIELD vlabloqu LIKE crapblj.vlbloque
    FIELD dsdsitua AS CHAR.

DEF TEMP-TABLE tt-imprime-bloqueio-transf NO-UNDO
    FIELD cdagenci AS INT
    FIELD nrdconta AS INT
    FIELD nmprimtl LIKE crapass.nmprimtl
    FIELD nroficio LIKE crapblj.nroficio
    FIELD dtblqini LIKE crapblj.dtblqini
    FIELD vlbloque LIKE crapblj.vlbloque.

DEF TEMP-TABLE tt-imprime-total NO-UNDO
    FIELD cdtipmov AS INT
    FIELD dsmodali AS CHAR
    FIELD qtdbloqu AS INT
    FIELD vldbloqu AS DEC
    FIELD qtddesbl AS INT
    FIELD vlddesbl AS DEC.


DEF VAR aux_nrcpfcgc AS DECI                                           NO-UNDO.
DEF VAR aux_nrdconta AS CHAR                                           NO-UNDO.
DEF VAR aux_cdtipmov AS CHAR                                           NO-UNDO.
DEF VAR aux_cdmodali AS CHAR                                           NO-UNDO.
DEF VAR aux_vlbloque AS CHAR                                           NO-UNDO.
DEF VAR aux_vlresblq AS CHAR                                           NO-UNDO.
DEF VAR aux_nroficio AS CHAR                                           NO-UNDO.
DEF VAR aux_nrproces AS CHAR                                           NO-UNDO.
DEF VAR aux_dsjuizem AS CHAR                                           NO-UNDO.
DEF VAR aux_dsresord AS CHAR                                           NO-UNDO.
DEF VAR aux_flblcrft AS LOGI                                           NO-UNDO.
DEF VAR aux_vlrsaldo AS DECIMAL                                        NO-UNDO.
DEF VAR aux_dtenvres AS DATE                                           NO-UNDO.


/* .......................................................................... */
