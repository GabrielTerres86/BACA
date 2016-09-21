/*..............................................................................

   Programa: b1wgen0096tt.i                  
   Autor   : GATI - Diego
   Data    : Abril/2011                      Ultima atualizacao: 18/02/2015

   Dados referentes ao programa:

   Objetivo  : Arquivo com variaveis utlizadas na BO b1wgen0096.p
   
   Alteracoes: 22/01/2013 - Adicionado campo cdagenci na tabela tt_crapbcx (Daniele).
   
               18/04/2013 - Incluir campo tpcaicof na temp-table tt_crapbcx
                            (Lucas R.)

               18/02/2015 - Incluir campos vltotcai, vltotcof, totcacof na 
                            temp-table tt_crapbcx (Lucas R. #245838)
..............................................................................*/

DEFINE TEMP-TABLE tt_crapbcx NO-UNDO
    FIELD cdagenci AS INTEGER   FORMAT "zz9"
    FIELD nrdcaixa AS INTEGER   FORMAT "zz9"
    FIELD nmoperad AS CHARACTER FORMAT "x(30)"
    FIELD vldsdtot AS DECIMAL   FORMAT "zzz,zzz,zz9.99-"
    FIELD csituaca AS CHAR      FORMAT "x(16)"
    FIELD tpcaicof AS CHAR      FORMAT "x(5)"
    FIELD vltotcai AS DECIMAL   FORMAT "zzz,zzz,zz9.99-"
    FIELD vltotcof AS DECIMAL   FORMAT "zzz,zzz,zz9.99-"
    FIELD totcacof AS DECIMAL   FORMAT "zzz,zzz,zz9.99-".
