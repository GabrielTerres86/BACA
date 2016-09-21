/* .............................................................................

   Programa: b1wgen0165tt.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Renersson Agostini - Gati
   Data    : Agosto/2013.                       Ultima atualizacao: 07/03/2014

   Dados referentes ao programa:

   Objetivo  : Tabelas Temporarias -- Tela EMPRES

   Alteracoes: 07/03/2014 - Ajustes referentes aos nomes dos campos das 
                            temp-tables, retirado aux_ que tinha frente de
                            todos os campos (Lucas R.)
   
............................................................................. */

DEFINE TEMP-TABLE tt-crapepr NO-UNDO
    FIELD cdcooper LIKE crapepr.cdcooper
    FIELD nrdconta LIKE crapepr.nrdconta
    FIELD nrctremp LIKE crapepr.nrctremp
    FIELD dtmvtolt LIKE crapepr.dtmvtolt
    FIELD vlemprst LIKE crapepr.vlemprst
    FIELD qtpreemp LIKE crapepr.qtpreemp
    FIELD vlpreemp LIKE crapepr.vlpreemp
    FIELD cdlcremp LIKE crapepr.cdlcremp
    FIELD cdfinemp LIKE crapepr.cdfinemp
    FIELD dscontra AS CHAR.

DEFINE TEMP-TABLE tt-crapass NO-UNDO
    FIELD cdtipsfx AS INTEGER  
    FIELD nmprimtl AS CHARACTER.

DEFINE TEMP-TABLE tt-pesqsr NO-UNDO
    FIELD nrdconta LIKE crapepr.nrdconta                   /* Numero da conta corrente */
    FIELD nmprimtl LIKE crapass.nmprimtl                   /* Titular */
    FIELD cdtipsfx LIKE crapass.cdtipsfx                   /* T.F. */
    FIELD nrctremp LIKE crapepr.nrctremp                   /* Contrato */
    FIELD cdpesqui AS CHAR    FORMAT "x(25)"               /* Pesquisa */
    FIELD vlemprst LIKE crapepr.vlemprst                   /* Valor emprestado */
    FIELD txdjuros AS DECIMAL DECIMALS 7                   /* Taxa de juros */
    FIELD vlsdeved AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99-" /* Saldo devedor */
    FIELD vljurmes AS DECIMAL FORMAT "zzz,zzz,zz9.99-"     /* Juros do mes */
    FIELD vlpreemp LIKE crapepr.vlpreemp                   /* Valor da prestacao */
    FIELD vljuracu AS DECIMAL FORMAT "zzz,zzz,zz9.99-"     /* Juros acumulados */
    FIELD vlprepag AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99"  /* Valor pago no mes */
    FIELD qtmesdec AS INT     FORMAT "zz9"                 /* Meses decorridos */
    FIELD vlpreapg AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99-" /* Valor a regularizar */
    FIELD dsdpagto AS CHAR    FORMAT "x(36)"               /* Descrição do pagamento */
    FIELD qtprecal AS DECIMAL DECIMALS 4 FORMAT "zz9.9999" /* Prestações pagas */
    FIELD dslcremp AS CHAR    FORMAT "x(31)"               /* Limite de credito */
    FIELD qtpreapg AS DECIMAL DECIMALS 4 FORMAT "zz9.9999-"/* Prestações a pagar */
    FIELD dsfinemp AS CHAR    FORMAT "x(31)"               /* Finalidade do emprestimo */
    FIELD nrctaav1 LIKE crapepr.nrctaav1                   /* Conta do primeiro avalis */
    FIELD cpfcgc1  LIKE crapavt.nrcpfcgc                   /* CPF/CNPJ do prim. avalis */
    FIELD nmdaval1 LIKE crapavt.nmdavali                   /* Nome do prim. avalis */
    FIELD nrraval1 LIKE crapass.nrramemp                   /* Ramal do prim. avalis */
    FIELD nrctaav2 LIKE crapepr.nrctaav2                   /* Conta do seg. avalis */   
    FIELD cpfcgc2  LIKE crapavt.nrcpfcgc                   /* CPF/CNPJ do seg. avalis */
    FIELD nmdaval2 LIKE crapavt.nmdavali                   /* Nome do segundo avalis */    
    FIELD nrraval2 LIKE crapass.nrramemp.                  /* Ramal do segundo avalis */   
