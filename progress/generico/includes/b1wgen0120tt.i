/*.............................................................................

    Programa: sistema/generico/includes/b1wgen0120tt.i
    Autor(a): Gabriel Capoia dos Santos (DB1)
    Data    : Outubro/2011                      Ultima atualizacao: 13/04/2017
  
    Dados referentes ao programa:
  
    Objetivo  : Include com Temp-Tables para a BO b1wgen0120.
  
    Alteracoes: 23/08/2016 - Agrupamento das informacoes (M36 - Kelvin).
    
                13/04/2017 - Inserido campo nrsequen na tt-estorno #625135
				             (Tiago/Elton).

				24/01/2018 - Aumentar o campo CRATFIT.BLIDENTI de 40 para 59 posições, pois estava truncando a tag "Final do BL"
				             SD 812596 - Marcelo Telles Coelho
.............................................................................*/ 
DEF TEMP-TABLE tt-boletimcx NO-UNDO
    FIELD cdagenci LIKE crapbcx.cdagenci
    FIELD nrdcaixa LIKE crapbcx.nrdcaixa
    FIELD cdopecxa LIKE crapbcx.cdopecxa
    FIELD nmoperad LIKE crapope.nmoperad
    FIELD hrabtbcx LIKE crapbcx.hrabtbcx
    FIELD hrfecbcx LIKE crapbcx.hrfecbcx
    FIELD vldsdini LIKE crapbcx.vldsdini
    FIELD vldsdfin LIKE crapbcx.vldsdfin
    FIELD nrdmaqui LIKE crapbcx.nrdmaqui
    FIELD qtautent LIKE crapbcx.qtautent
    FIELD nrdlacre LIKE crapbcx.nrdlacre
    FIELD cdsitbcx LIKE crapbcx.cdsitbcx
    FIELD dshrabtb AS CHAR FORMAT "x(8)"
    FIELD dshrfecb AS CHAR FORMAT "x(8)"
    FIELD nrcrecid AS RECID.

DEF TEMP-TABLE tt-lanctos NO-UNDO
    FIELD cdhistor LIKE craplcx.cdhistor
    FIELD dshistor LIKE craphis.dshistor
    FIELD dsdcompl LIKE craplcx.dsdcompl        
    FIELD nrdocmto LIKE craplcx.nrdocmto        
    FIELD vldocmto LIKE craplcx.vldocmto        
    FIELD nrseqdig LIKE craplcx.nrseqdig.

DEF TEMP-TABLE tt-histor NO-UNDO
    FIELD cdhistor LIKE craphis.cdhistor
    FIELD dshistor AS CHARACTER FORMAT "x(18)"
    FIELD dsdcompl AS CHARACTER FORMAT "x(50)"
    FIELD qtlanmto AS INTEGER
    FIELD vllanmto LIKE craplcm.vllanmto
    FIELD qtlanmto-recibo AS INTEGER
    FIELD vllanmto-recibo LIKE craplcm.vllanmto
    FIELD qtlanmto-cartao AS INTEGER
    FIELD vllanmto-cartao LIKE craplcm.vllanmto
	FIELD vlarccon LIKE craplcm.vllanmto
    FIELD vlarcdar LIKE craplcm.vllanmto
    FIELD vlarcgps LIKE craplcm.vllanmto
    FIELD vlarcnac LIKE craplcm.vllanmto    
    FIELD qtarccon AS INTEGER
    FIELD qtarcdar AS INTEGER
    FIELD qtarcgps AS INTEGER
    FIELD qtarcnac AS INTEGER.

DEF TEMP-TABLE tt-empresa NO-UNDO
    FIELD cdempres LIKE crapccs.cdempres
    FIELD qtlanmto AS INT
    FIELD vllanmto LIKE craplcs.vllanmto
    INDEX w_empresa1 cdempres.

DEF TEMP-TABLE tt-estorno NO-UNDO
    FIELD cdagenci LIKE crapbcx.cdagenci
    FIELD nrdcaixa LIKE crapbcx.nrdcaixa
    FIELD nrseqaut LIKE crapaut.nrseqaut
	FIELD nrsequen LIKE crapaut.nrsequen
    INDEX estorno AS UNIQUE PRIMARY
          cdagenci
          nrdcaixa
          nrseqaut
		  nrsequen.

DEF TEMP-TABLE cratfit NO-UNDO
    FIELD nrsequen AS INT     FORMAT "zzzz9"
    FIELD nrdconta AS INT     FORMAT "zzzz,zz9,9"
    FIELD nrdocmto AS DECIMAL FORMAT "zz,zzz,zzz,zz9"
    FIELD vllanmto AS DECIMAL FORMAT "zzz,zzz,zz9.99"
    FIELD hrautent AS INT     FORMAT "zz,zz9"
    FIELD blidenti AS CHAR    FORMAT "x(59)"
    FIELD cdhistor AS INT     FORMAT "zzz9"
    FIELD tpoperac AS LOGICAL FORMAT "PG/RC"
    FIELD dsdocmto AS CHAR    FORMAT "x(50)"
    FIELD tplotmov AS INT     FORMAT "z9"
    FIELD estorno  AS LOGICAL FORMAT "Sim/Nao"
    FIELD nrseqaut AS INT     FORMAT "zzz9"
    FIELD dslitera AS CHAR    FORMAT "x(48)"
    FIELD bltotpag AS DECIMAL FORMAT "-zzz,zz9.99"
    FIELD bltotrec AS DECIMAL FORMAT "-zzz,zz9.99"
    FIELD blsldini AS DECIMAL FORMAT "-zzz,zz9.99"
    FIELD blvalrec AS DECIMAL FORMAT "-zzz,zz9.99"
    FIELD dsidenti LIKE craplcm.dsidenti
    FIELD dsidenve LIKE crapaut.dslitera
    INDEX cratfit1 nrsequen.


