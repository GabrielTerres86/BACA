/*.............................................................................

    Programa: sistema/generico/includes/b1wgen0151tt.i
    Autor(a): Gabriel Capoia (DB1)
    Data    : 07/02/2013                      Ultima atualizacao: 14/05/2018
  
    Dados referentes ao programa:
  
    Objetivo  : Include com Temp-Tables para a BO b1wgen0151.
  
    Alteracoes: 14/05/2018 - Incluido novo campo "Tipo de Conta" (tpctatrf) na tela CTASAL
                             Projeto 479-Catalogo de Servicos SPB
                             (Mateus Z - Mouts)
    
.............................................................................*/ 

DEF TEMP-TABLE tt-crapccs NO-UNDO
    FIELD cdagenci LIKE crapccs.cdagenci
    FIELD cdempres LIKE crapccs.cdempres
    FIELD cdagetrf LIKE crapccs.cdagetrf
    FIELD cdbantrf LIKE crapccs.cdbantrf
    FIELD nrdigtrf LIKE crapccs.nrdigtrf
    FIELD nrctatrf LIKE crapccs.nrctatrf
    FIELD nrcpfcgc LIKE crapccs.nrcpfcgc
    FIELD nmfuncio LIKE crapccs.nmfuncio
    FIELD dtcantrf LIKE crapccs.dtcantrf
    FIELD dtadmiss LIKE crapccs.dtadmiss
    FIELD cdsitcta AS CHAR
    FIELD nmresage LIKE crapage.nmresage
    FIELD nmresemp LIKE crapemp.nmresemp
    FIELD dsbantrf LIKE crapban.nmresbcc
    FIELD nrdconta LIKE crapccs.nrdconta
    FIELD tpctatrf LIKE crapccs.tpctatrf
    FIELD dsagetrf AS CHAR.
