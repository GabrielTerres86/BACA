/*.............................................................................

    Programa: sistema/generico/includes/b1wgen0112tt.i
    Autor(a): Gabriel Capoia dos Santos (DB1)
    Data    : Agosto/2011                        Ultima atualizacao: 20/04/2017
  
    Dados referentes ao programa:
  
    Objetivo  : Include com Temp-Tables para a BO b1wgen0112.
  
    Alteracoes: 
    
                01/02/2012 - Criado tt-retencao_ir contendo informacoes quanto
                             ao rendimento e imposto de renda (utilizado em
                             pessoa juridica).
                           - Adicionado campos: vlrencot, vlirfcot e anirfcot
                             em tt-extrato_ir. (Jorge)
                
                10/09/2012 - Demonstrativo Aplicacoes - Criacao da temp-table
                             tt-demonstrativo. (Guilherme/Supero)
                             
                08/10/2012 - Incluir campo dsextrat na tt-extrato_epr_aux 
                             (Lucas R)
                
                30/01/2013 - Incluir campo flglista na tt-extrato_epr_aux
                             (Lucas R.)
                
                26/01/2015 - Alterado o formato do campo nrctremp para 8 
                             caracters (Kelvin - 233714)
                             
                29/10/2015 - Incluso novo campo cdorigem e cdhistor
				             na tt-extrato_epr_aux (Daniel)
                             
				20/04/2017 - Ajuste para retirar o uso de campos removidos da tabela
			                 crapass, crapttl, crapjur 
							(Adriano - P339).
                             
.............................................................................
.............................................................................*/

DEF TEMP-TABLE tt-impres NO-UNDO
    FIELD nrdconta AS INTE  FORMAT "zzzz,zz9,9" LABEL "Conta/dv"
    FIELD dtrefere AS DATE  FORMAT "99/99/99"
    FIELD dtreffim AS DATE  FORMAT "99/99/99"
    FIELD tpextrat AS INTE  FORMAT "9"
    FIELD dsextrat AS CHAR  FORMAT "x(04)"
    FIELD tpmodelo AS INTE  FORMAT "9"
    FIELD nranoref AS INTE  FORMAT "zzz9"
    FIELD nrctremp AS INTE  FORMAT "zz,zzz,zz9"
    FIELD nraplica AS INTE  FORMAT "zzzz,zz9"
    FIELD inselext AS INTE  FORMAT "9"
    FIELD inrelext AS INTE  FORMAT "9"
    FIELD inisenta AS LOGI
    FIELD insitext AS INTE
    FIELD flgemiss AS LOGI
    FIELD flgtarif AS LOGI
    FIELD nrsequen AS INTE
    INDEX tt-impres1 AS PRIMARY nrsequen DESCENDING.
    
DEF TEMP-TABLE tt-retencao_ir NO-UNDO
    FIELD nrcpfbnf AS CHAR FORMAT "x(18)"
    FIELD nmmesref AS CHAR FORMAT "x(3)"
    FIELD cdretenc AS CHAR    
    FIELD dsretenc AS CHAR FORMAT "x(41)"
    FIELD vlrentot AS DECI FORMAT "zz,zzz,zz9.99-"
    FIELD vlirfont AS DECI FORMAT "zz,zzz,zz9.99-".

DEF TEMP-TABLE tt-extrato_ir NO-UNDO
    FIELD nrcpfcgc AS CHAR FORMAT "x(18)"
    FIELD nrdconta LIKE crapass.nrdconta
    FIELD nmprimtl LIKE crapass.nmprimtl
    FIELD cdagenci LIKE crapass.cdagenci
    FIELD nmsegntl LIKE crapttl.nmextttl
    FIELD dsanoant AS CHAR FORMAT "x(8)"
    FIELD dtrefer1 AS DATE FORMAT "99/99/9999"
    FIELD vlsdapl1 AS DECI FORMAT "z,zzz,zzz,zz9.99-"
    FIELD vlsdccd1 AS DECI FORMAT "zzzzz,zzz,zz9.99-"
    FIELD vlsddve1 AS DECI FORMAT "zzzzz,zzz,zz9.99-"
    FIELD vlttcca1 AS DECI FORMAT "zzzzz,zzz,zz9.99-"
    FIELD dtrefer2 AS DATE FORMAT "99/99/9999"        
    FIELD vlsdapl2 AS DECI FORMAT "z,zzz,zzz,zz9.99-" 
    FIELD vlsdccd2 AS DECI FORMAT "zzzzz,zzz,zz9.99-" 
    FIELD vlsddve2 AS DECI FORMAT "zzzzz,zzz,zz9.99-" 
    FIELD vlttcca2 AS DECI FORMAT "zzzzz,zzz,zz9.99-" 
    FIELD vlrendim AS DECI FORMAT "zzzzz,zz9.99-"
    FIELD nmextcop LIKE crapcop.nmextcop
    FIELD nrdocnpj AS CHAR
    FIELD dsendcop AS CHAR EXTENT 2
    FIELD dscpmfpg AS CHAR FORMAT "x(16)"
    FIELD vlcpmfpg AS DECI FORMAT "zzzzz,zzz,zz9.99-"
    FIELD vldoirrf AS DECI FORMAT "zzzzz,zzz,zz9.99-"
    FIELD cdagectl LIKE crapcop.cdagectl
    FIELD nmcidade AS CHAR
    FIELD regexis1 AS LOGI
    FIELD dsagenci AS CHAR FORMAT "x(21)"
    FIELD dtmvtolt AS DATE FORMAT "99/99/9999"
    FIELD dtmvtol1 AS DATE FORMAT "99/99/9999"
    FIELD vlsddvem AS DECI
    FIELD vlsdccdp AS DECI
    FIELD vlsdapli AS DECI
    FIELD vlttccap AS DECI
    FIELD qtjaicmf AS DECI
    FIELD qtjaicm1 AS DECI
    FIELD vlrenap1 AS DECI
    FIELD vlmoefix AS DECI DECIMALS 8
    FIELD vlmoefi1 AS DECI DECIMALS 8
    FIELD dscooper AS CHAR
    FIELD dstelcop AS CHAR
    FIELD vlrenapl AS DECI
    FIELD flganter AS LOGI
    FIELD vlrencot AS DECI FORMAT "zzzzz,zz9.99-"
    FIELD vlirfcot AS DECI FORMAT "zzzzz,zzz,zz9.99-"
    FIELD anirfcot AS DECI FORMAT "zzzzz,zzz,zz9.99-".

DEF TEMP-TABLE tt-extrato_epr_aux
    FIELD nrdconta LIKE crapass.nrdconta
    FIELD dtmvtolt LIKE craplem.dtmvtolt
    FIELD cdagenci LIKE craplem.cdagenci
    FIELD cdbccxlt LIKE craplem.cdbccxlt
    FIELD nrdolote LIKE craplem.nrdolote
    FIELD dshistor AS   CHAR
    FIELD nrdocmto LIKE craplem.nrdocmto
    FIELD indebcre AS   CHAR FORMAT "x(01)"
    FIELD vllanmto LIKE craplem.vllanmto 
    FIELD txjurepr LIKE craplem.txjurepr 
    FIELD qtpresta AS   DECI FORMAT "zz9.9999"
    FIELD nrparepr AS   CHAR
    FIELD vldebito LIKE craplem.vllanmto 
    FIELD vlcredit LIKE craplem.vllanmto 
    FIELD vlsaldo  LIKE craplem.vllanmto 
    FIELD dsextrat AS CHAR
    FIELD flglista AS LOGICAL INITIAL TRUE
    FIELD cdorigem LIKE craplem.cdorigem
    FIELD cdhistor LIKE craplem.cdhistor.

DEF TEMP-TABLE tt-demonstrativo NO-UNDO
    FIELD nraplica LIKE craprda.nraplica
    FIELD idsequen AS INT
    FIELD dstplanc AS CHAR
    FIELD vlcolu01 AS DECI
    FIELD vlcolu02 AS DECI
    FIELD vlcolu03 AS DECI
    FIELD vlcolu04 AS DECI
    FIELD vlcolu05 AS DECI
    FIELD vlcolu06 AS DECI
    FIELD vlcolu07 AS DECI
    FIELD vlcolu08 AS DECI
    FIELD vlcolu09 AS DECI
    FIELD vlcolu10 AS DECI
    FIELD vlcolu11 AS DECI
    FIELD vlcolu12 AS DECI
    FIELD vlcolu13 AS DECI
    FIELD vlcolu14 AS CHAR
    FIELD vlcolu15 AS CHAR.

DEF TEMP-TABLE tt-crapcpc NO-UNDO LIKE crapcpc.
