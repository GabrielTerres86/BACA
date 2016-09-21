/* ..........................................................................

   Programa: b1wgen0087tt.i                  
   Autor   : Elton
   Data    : Abril/2011                       Ultima atualizacao: 06/02/2014
   Dados referentes ao programa:

   Objetivo  :  Temp-tables utlizadas na BO b1wgen0087.p
                DDA/COBRANCA REGISTRADA

   Alteracoes:  
   
   30/01/2012 - Adicionado em tt-remessa-dda os parametros: tpmodcal, dtvalcal
                e flavvenc. (Jorge)
                
   04/07/2013 - Adicionada a temp-table tt-pagar (titulos a pagar) (Carlos)
 
   06/02/2014 - Igualar as temp-tables as tabelas fisicas criadas (Gabriel)
   
............................................................................ */


DEF TEMP-TABLE tt-verifica-sacado NO-UNDO
               FIELD tppessoa   AS CHAR 
               FIELD nrcpfcgc   AS INT64 
               FIELD flgsacad   AS LOGICAL.
                
DEF TEMP-TABLE tt-remessa-dda NO-UNDO 
               LIKE WT_REMESSA_DDA.

DEF TEMP-TABLE tt-retorno-dda NO-UNDO
               LIKE wt_retorno_dda.
                
/* Cooperativa        PAC                Conta/DV  
   Cód. Barras        Vencto             Valor    */
DEF TEMP-TABLE tt-pagar NO-UNDO
    FIELD nmrescop LIKE crapcop.nmrescop
    FIELD cdagenci LIKE crapass.cdagenci
    FIELD nrdconta LIKE crapcob.nrdconta
    FIELD cdbarras   AS CHAR
    FIELD dtvencto LIKE crapcob.dtvencto
    FIELD vltitulo LIKE crapcob.vltitulo.
