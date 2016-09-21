/*..............................................................................

   Programa: b1wgen0003tt.i                  
   Autor   : David
   Data    : Agosto/2007                      Ultima atualizacao: 09/07/2008   

   Dados referentes ao programa:

   Objetivo  : Arquivo com variaveis utlizadas na BO b1wgen0003.p

   Alteracoes: 20/02/2008 - Retirar temp-table tt-saldo_lanmto_futuro (David)
                            Incluir temp-table tt-vllautom (Guilherme)

               19/05/2008 - Modificar format do historico de lancamentos
                            futuros e novos campos para totais (David).
                            
               09/07/2008 - Quando folha mostrava 01/01/1099 no debito (Magui).
..............................................................................*/

DEF TEMP-TABLE tt-totais-futuros NO-UNDO
    FIELD vllautom AS DECI
    FIELD vllaudeb AS DECI
    FIELD vllaucre AS DECI.

DEF TEMP-TABLE tt-lancamento_futuro NO-UNDO
    FIELD dtmvtolt AS DATE    FORMAT "99/99/9999" /*0*/
    FIELD dshistor AS CHAR    FORMAT "x(50)" /*1*/ 
    FIELD nrdocmto AS CHAR    FORMAT "x(11)" /*2*/ 
    FIELD indebcre AS CHAR    FORMAT " x "   /*3*/
    FIELD vllanmto AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99-" /*4*/
    FIELD dsmvtolt AS CHAR    FORMAT "x(10)" /*5*/
    FIELD dstabela AS CHAR    FORMAT "x(20)" /*6*/
    FIELD cdhistor LIKE craphis.cdhistor     /*7*/
    FIELD genrecid AS RECID.              /*8*/
    

/* Temp-table com os campos que serao listados - cheques pendentes */
DEF TEMP-TABLE cratfdc NO-UNDO
    FIELD dtemschq LIKE crapfdc.dtemschq
    FIELD dtretchq LIKE crapfdc.dtretchq
    FIELD nrdctabb LIKE crapfdc.nrdctabb
    FIELD nrcheque LIKE crapfdc.nrcheque   FORMAT "zzz,zzz,9"
    FIELD chqtaltb AS LOGICAL              FORMAT "**/  "
    FIELD dsobserv AS CHAR.

/*............................................................................*/
