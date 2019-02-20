/*.............................................................................

    Programa: sistema/generico/includes/b1wgen0108tt.i
    Autor(a): Gabriel Capoia dos Santos (DB1)
    Data    : Agosto/2011                        Ultima atualizacao:
  
    Dados referentes ao programa:
  
    Objetivo  : Include com Temp-Tables para a BO b1wgen0108.
  
    Alteracoes: 26/12/2018 - Projeto 510 - Incluí o campo tppagmto na tt-movimentos (Daniel - Envolti)
    
............................................................................*/ 

DEF TEMP-TABLE tt-movimentos NO-UNDO
    FIELD cdagenci LIKE crapcbb.cdagenci
    FIELD cdbccxlt LIKE crapcbb.cdbccxlt
    FIELD cdopecxa LIKE crapcbb.cdopecxa
    FIELD nrdcaixa LIKE crapcbb.nrdcaixa
    FIELD nrdolote LIKE crapcbb.nrdolote
    FIELD valordoc LIKE crapcbb.valordoc
    FIELD valorpag LIKE crapcbb.valorpag
    FIELD flgrgatv LIKE crapcbb.flgrgatv
    FIELD cdbarras LIKE crapcbb.cdbarras
    FIELD dsdocmc7 LIKE crapcbb.dsdocmc7
    FIELD vldescto LIKE crapcbb.vldescto
    FIELD nrautdoc LIKE crapcbb.nrautdoc
    FIELD tpdocmto LIKE crapcbb.tpdocmto
    FIELD dtvencto LIKE crapcbb.dtvencto
    FIELD nmoperad LIKE crapope.nmoperad
    FIELD dsdocmto AS CHAR FORMAT "x(7)"
    FIELD nrdrowid AS ROWID
	  FIELD tppagmto LIKE crapcbb.tppagmto
    FIELD dstppgto AS CHAR FORMAT "X(10)"
    .

DEF TEMP-TABLE tt-concbb NO-UNDO
    FIELD qttitrec AS DECI FORMAT "zzz,zz9"       
    FIELD vltitrec AS DECI FORMAT "zzz,zzz,zz9.99"
    FIELD qttitliq AS DECI FORMAT "zzz,zz9"       
    FIELD vltitliq AS DECI FORMAT "zzz,zzz,zz9.99"
    FIELD qttitcan AS DECI FORMAT "zzz,zz9"       
    FIELD vltitcan AS DECI FORMAT "zzz,zzz,zz9.99"
    FIELD qtfatrec AS DECI FORMAT "zzz,zz9"       
    FIELD vlfatrec AS DECI FORMAT "zzz,zzz,zz9.99"
    FIELD qtfatliq AS DECI FORMAT "zzz,zz9"       
    FIELD vlfatliq AS DECI FORMAT "zzz,zzz,zz9.99"
    FIELD qtinss   AS DECI FORMAT "zzz,zz9"       
    FIELD vlinss   AS DECI FORMAT "zzz,zzz,zz9.99"
    FIELD qtfatcan AS DECI FORMAT "zzz,zz9"       
    FIELD vlfatcan AS DECI FORMAT "zzz,zzz,zz9.99"
    FIELD qtdinhei AS DECI FORMAT "zzz,zz9"       
    FIELD vldinhei AS DECI FORMAT "zzz,zzz,zz9.99"
    FIELD qtcheque AS DECI FORMAT "zzz,zz9"       
    FIELD vlcheque AS DECI FORMAT "zzz,zzz,zz9.99".

DEFINE TEMP-TABLE tt-arquivo NO-UNDO
    FIELD nmarquivo AS CHAR FORMAT "x(30)".

DEFINE TEMP-TABLE tt-movtos NO-UNDO
    FIELD nmarquivo AS CHAR FORMAT "x(20)"
    FIELD dtmvtolt  AS DATE
    FIELD cdchaveb  AS CHAR FORMAT "x(08)"
    FIELD cdtransa  AS CHAR FORMAT "x(04)"
    FIELD dtmovto   AS DATE
    FIELD valorpag  AS DEC
    FIELD cdagenci  AS INTE FORMAT "9999"
    FIELD nrdcaixa  AS INTE FORMAT "9999"
    FIELD formaliq  AS INTE FORMAT "99"
    FIELD flgrgatv  AS INTE FORMAT "9"
    FIELD cdbarras  AS CHAR FORMAT "x(45)"
    FIELD hora      AS INTE FORMAT "999999"
    FIELD autchave  AS INTE FORMAT "9999"
    FIELD cdagerel  AS INTE FORMAT "9999"
    FIELD datadarq  AS DATE 
    FIELD nrseqarq  AS INTE.

DEFINE TEMP-TABLE tt-total NO-UNDO
    FIELD qttitrec  AS DECI   FORMAT "zzz,zz9"       
    FIELD vltitrec  AS DECI   FORMAT "zzz,zzz,zz9.99"
    FIELD qttitliq  AS DECI   FORMAT "zzz,zz9"       
    FIELD vltitliq  AS DECI   FORMAT "zzz,zzz,zz9.99"
    FIELD qttitcan  AS DECI   FORMAT "zzz,zz9"       
    FIELD vltitcan  AS DECI   FORMAT "zzz,zzz,zz9.99"
    FIELD qtfatrec  AS DECI   FORMAT "zzz,zz9"       
    FIELD vlfatrec  AS DECI   FORMAT "zzz,zzz,zz9.99"
    FIELD qtfatliq  AS DECI   FORMAT "zzz,zz9"       
    FIELD vlfatliq  AS DECI   FORMAT "zzz,zzz,zz9.99"
    FIELD qtfatcan  AS DECI   FORMAT "zzz,zz9"       
    FIELD vlfatcan  AS DECI   FORMAT "zzz,zzz,zz9.99"
    FIELD qtdinhei  AS DECI   FORMAT "zzz,zz9"       
    FIELD vldinhei  AS DECI   FORMAT "zzz,zzz,zz9.99"
    FIELD qtcheque  AS DECI   FORMAT "zzz,zz9"       
    FIELD vlcheque  AS DECI   FORMAT "zzz,zzz,zz9.99"
    FIELD qtinss    AS DECI   FORMAT "zzz,zz9"       
    FIELD vlinss    AS DECI   FORMAT "zzz,zzz,zz9.99"
    FIELD vlrepasse AS DECI.

DEF TEMP-TABLE tt-mensagens NO-UNDO
    FIELD nrsequen AS INTE
    FIELD dsmensag AS CHAR
    INDEX tt-mensagens1 AS PRIMARY nrsequen.

DEF TEMP-TABLE tt-rcb-rowid NO-UNDO
    FIELD rowid AS ROWID.
