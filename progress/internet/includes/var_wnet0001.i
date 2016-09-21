/* .............................................................................

   Programa: var_wnet0001.i
   Sistema : Internet - Cooperativa de Credito
   Sigla   : CRED
   Autor   : David
   Data    : Outubro/2006.                     Ultima atualizacao: 15/09/2008

   Dados referentes ao programa:

   Objetivo  : Variaveis utilizadas no programa siscaixa/web/InternetBank.w e
               na BO sistema/internet/procedures/b1wnet0001.
   
   Alteracoes: 13/03/2007 - Incluir variaveis para rotina de consulta de 
                            boletos (David).
                            
               15/09/2008 - Removido campo crapcob.nrdoccop (Diego).
                            
............................................................................. */

DEF TEMP-TABLE tt-dados-blt               
    FIELD nrdctabb LIKE crapcco.nrdctabb
    FIELD nrconven LIKE crapcco.nrconven
    FIELD tamannro LIKE crapcco.tamannro
    FIELD nmprimtl LIKE crapass.nmprimtl
    FIELD nrcpfcgc LIKE crapass.nrcpfcgc
    FIELD inpessoa LIKE crapass.inpessoa
    FIELD dsendere LIKE crapenc.dsendere
    FIELD nrendere LIKE crapenc.nrendere
    FIELD nmbairro LIKE crapenc.nmbairro
    FIELD nmcidade LIKE crapenc.nmcidade
    FIELD cdufende LIKE crapenc.cdufende
    FIELD nrcepend LIKE crapenc.nrcepend
    FIELD dtmvtolt LIKE crapdat.dtmvtolt
    FIELD vllbolet LIKE crapsnh.vllbolet.

DEF TEMP-TABLE tt-sacados-blt
    FIELD nmdsacad LIKE crapsab.nmdsacad
    FIELD nrinssac LIKE crapsab.nrinssac.
    
DEF TEMP-TABLE tt-gera-blt                  
    FIELD nrdocmto LIKE crapcob.nrdocmto
    FIELD nrcnvceb LIKE crapceb.nrcnvceb
    FIELD nrdoccop AS DECIMAL
    FIELD dtvencto LIKE crapcob.dtvencto
    FIELD nrinssac LIKE crapcob.nrinssac.
     
DEF TEMP-TABLE tt-consulta-blt
    FIELD cdcooper LIKE crapcop.cdcooper
    FIELD nrdconta LIKE crapass.nrdconta
    FIELD nmprimtl LIKE crapass.nmprimtl
    FIELD incobran AS CHAR FORMAT "x"
    FIELD nossonro AS CHAR FORMAT "x(19)"    
    FIELD nmdsacad LIKE crapcob.nmdsacad
    FIELD nrinssac LIKE crapcob.nrinssac
    FIELD cdtpinsc LIKE crapcob.cdtpinsc
    FIELD dsendsac LIKE crapcob.dsendsac
    FIELD complend LIKE crapsab.complend
    FIELD nmbaisac LIKE crapcob.nmbaisac
    FIELD nmcidsac LIKE crapcob.nmcidsac
    FIELD cdufsaca LIKE crapcob.cdufsaca
    FIELD nrcepsac LIKE crapcob.nrcepsac
    FIELD nmdavali LIKE crapcob.nmdavali
    FIELD nrcnvcob LIKE crapcob.nrcnvcob
    FIELD nrcnvceb LIKE crapceb.nrcnvceb
    FIELD nrdctabb LIKE crapcob.nrdctabb
    FIELD nrcpfcgc LIKE crapass.nrcpfcgc
    FIELD inpessoa LIKE crapass.inpessoa
    FIELD nrdocmto LIKE crapcob.nrdocmto
    FIELD dtmvtolt LIKE crapcob.dtmvtolt
    FIELD dsdinstr LIKE crapcob.dsdinstr
    FIELD nrdoccop AS DECIMAL
    FIELD dtvencto LIKE crapcob.dtvencto
    FIELD dtretcob LIKE crapcob.dtretcob
    FIELD dtdpagto LIKE crapcob.dtdpagto
    FIELD vltitulo LIKE crapcob.vltitulo
    FIELD vldpagto LIKE crapcob.vldpagto
    FIELD vldescto LIKE crapcob.vldescto
    FIELD cdmensag LIKE crapcob.cdmensag
    FIELD dsdpagto AS CHAR FORMAT "x(11)"
    FIELD dsorgarq LIKE crapcco.dsorgarq
    FIELD nrregist AS INTE.
    
DEF TEMP-TABLE tt-dados-sacado-blt LIKE crapsab.
   
DEF VAR l-erro       AS LOGICAL INITIAL YES                          NO-UNDO.
DEF VAR i-cod-erro   AS INTE    INITIAL 0                            NO-UNDO.
DEF VAR c-dsc-erro   AS CHAR    INITIAL ""                           NO-UNDO.
DEF VAR aux_sequen   AS INTE                                         NO-UNDO.

DEF VAR h-b1crapcob  AS HANDLE                                       NO-UNDO.
DEF VAR h-b1wgen010  AS HANDLE                                       NO-UNDO.
DEF VAR h-b1crapsab  AS HANDLE                                       NO-UNDO.

/*............................................................................*/
