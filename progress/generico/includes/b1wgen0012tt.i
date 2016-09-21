/*..............................................................................

   Programa: b1wgen0012tt.i                  
   Autor   : Guilherme
   Data    : Julho/2010                      Ultima atualizacao:   /  /

   Dados referentes ao programa:

   Objetivo  : Arquivo com variaveis e tt's utlizadas na BO b1wgen0012.p

   Alteracoes:             
                                        
..............................................................................*/

DEF TEMP-TABLE crattem                                                  NO-UNDO
         FIELD cdseqarq       AS INTEGER
         FIELD nrdolote       AS INTEGER
         FIELD cddbanco       AS INTEGER
         FIELD nmarquiv       AS CHAR
         FIELD nrrectit       AS RECID
         FIELD nrdconta       LIKE crapccs.nrdconta
         FIELD cdagenci       LIKE crapccs.cdagenci
         FIELD cdbantrf       LIKE crapccs.cdbantrf
         FIELD cdagetrf       LIKE crapccs.cdagetrf
         FIELD nrctatrf       LIKE crapccs.nrctatrf
         FIELD nrdigtrf       LIKE crapccs.nrdigtrf
         FIELD nmfuncio       LIKE crapccs.nmfuncio
         FIELD nrcpfcgc       LIKE crapccs.nrcpfcgc
         FIELD nrdocmto       LIKE craplcs.nrdocmto
         FIELD vllanmto       LIKE craplcs.vllanmto
         FIELD dtmvtolt       LIKE craplcs.dtmvtolt
         FIELD tppessoa       AS INT FORMAT "9"
         INDEX crattem1 cdseqarq nrdolote.

DEF TEMP-TABLE crawage                                                  NO-UNDO
         FIELD  cdcooper      LIKE crapage.cdcooper
         FIELD  cdagenci      LIKE crapage.cdagenci
         FIELD  nmresage      LIKE crapage.nmresage
         FIELD  nmcidade      LIKE crapage.nmcidade 
         FIELD  cdbandoc      LIKE crapage.cdbandoc
         FIELD  cdbantit      LIKE crapage.cdbantit
         FIELD  cdagecbn      LIKE crapage.cdagecbn
         FIELD  cdbanchq      LIKE crapage.cdbanchq
         FIELD  cdcomchq      LIKE crapage.cdcomchq.

DEFINE TEMP-TABLE tt-titulos                                            NO-UNDO
         FIELD qttitrec       AS INT
         FIELD vltitrec       AS DEC
         FIELD qttitrgt       AS INT
         FIELD vltitrgt       AS DEC
         FIELD qttiterr       AS INT
         FIELD vltiterr       AS DEC
         FIELD qttitprg       AS INT
         FIELD vltitprg       AS DEC
         FIELD qttitcxa       AS INT
         FIELD vltitcxa       AS DEC
         FIELD qttitulo       AS INT
         FIELD vltitulo       AS DEC.
                              
DEFINE TEMP-TABLE tt-compel                                             NO-UNDO
         FIELD qtchdcxi       AS INT
         FIELD qtchdcxs       AS INT
         FIELD qtchdcxg       AS INT
         FIELD qtchdcsi       AS INT
         FIELD qtchdcss       AS INT
         FIELD qtchdcsg       AS INT
         FIELD qtchddci       AS INT
         FIELD qtchddcs       AS INT
         FIELD qtchddcg       AS INT
         FIELD qtchdtti       AS INT
         FIELD qtchdtts       AS INT
         FIELD qtchdttg       AS INT
         FIELD vlchdcxi       AS DEC
         FIELD vlchdcxs       AS DEC
         FIELD vlchdcxg       AS DEC
         FIELD vlchdcsi       AS DEC
         FIELD vlchdcss       AS DEC
         FIELD vlchdcsg       AS DEC
         FIELD vlchddci       AS DEC
         FIELD vlchddcs       AS DEC
         FIELD vlchddcg       AS DEC
         FIELD vlchdtti       AS DEC
         FIELD vlchdtts       AS DEC
         FIELD vlchdttg       AS DEC.

DEFINE TEMP-TABLE tt-doctos                                             NO-UNDO
         FIELD cdagenci       LIKE craptvl.cdagenci
         FIELD cdbccxlt       LIKE craptvl.cdbccxlt
         FIELD nrdolote       LIKE craptvl.nrdolote
         FIELD nrdconta       LIKE craptvl.nrdconta
         FIELD nrdocmto       LIKE craptvl.nrdocmto
         FIELD vldocrcb       LIKE craptvl.vldocrcb.

DEFINE TEMP-TABLE tt-dados-arq NO-UNDO
    FIELD cdcooper AS INT
    FIELD cdagenci AS INT
    FIELD nrdcaixa AS INT
    FIELD cdoperad AS CHAR
    FIELD qtarquiv AS INT
    FIELD qttotreg AS INT
    FIELD vltotreg AS DEC
    FIELD vlrtotal AS DEC
    FIELD qtdtotal AS INT
    FIELD nmarquiv AS CHAR.
