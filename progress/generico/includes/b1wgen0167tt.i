/* .............................................................................

   Programa: b1wgen0167tt.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : André Santos - SUPERO
   Data    : Agosto/2013.                       Ultima atualizacao: 04/08/2015

   Dados referentes ao programa:

   Objetivo  : Tabelas Temporarias -- Tela FINALI 

   Alteracoes: 05/06/2014 - Alterado format do cdlcremp de 3 para 4 
                            Softdesk 137074 (Lucas R.)
                            
               04/08/2015 - Alteração nomenclatura (Lunelli SD 102123)
   
............................................................................. */

DEF TEMP-TABLE tt-craplch NO-UNDO LIKE craplch
    FIELD dslcremp AS CHAR FORMAT "x(30)".

DEF TEMP-TABLE tt-linhas-cred NO-UNDO
    FIELD cdlcremp AS INTE FORMAT "zzz9"
    FIELD dslcremp AS CHAR FORMAT "x(30)".

