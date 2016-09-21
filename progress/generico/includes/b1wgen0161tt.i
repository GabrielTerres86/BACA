/*..............................................................................

    Programa: b1wgen0161tt.i
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Andre Santos - Supero
    Data    : Julho/2013                        Ultima atualizacao: 05/05/2014

    Dados referentes ao programa:

    Objetivo  : Arquivo com variáveis ultizadas na BO b1wgen0161.p
               
    Alteracoes: 05/05/2014 - Aumentado o format do campo cdlcremp de 3 para 4
                             posicoes (Tiago/Gielow SD137074).
                            
..............................................................................*/

DEF TEMP-TABLE tt-emprestimo NO-UNDO
    FIELD cdagenci AS INT      FORMAT "zz9"  
    FIELD nrdconta AS INT      FORMAT "zzzz,zzz,9"
    FIELD nmprimtl AS CHAR     FORMAT "x(36)"
    FIELD nrctremp AS INT      FORMAT "zzz,zzz,zz9"
    FIELD dtmvtolt AS DATE     FORMAT "99/99/9999"
    FIELD vlemprst AS DECIMAL  FORMAT "zzz,zzz,zz9.99"
    FIELD vlsdeved AS DECIMAL  FORMAT "zzz,zzz,zz9.99-"
    FIELD cdlcremp AS INT      FORMAT "zzz9"
    FIELD diaprmed AS INT      FORMAT "zz9"
    FIELD dtmvtprp AS DATE     FORMAT "99/99/9999"
    FIELD dsorigem AS CHAR.

DEF TEMP-TABLE tt-emprestimo_pag NO-UNDO LIKE tt-emprestimo. 
