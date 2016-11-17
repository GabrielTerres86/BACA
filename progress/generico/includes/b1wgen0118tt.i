/* .............................................................................

   Include: b1wgen0118tt.i                   
   Autor  : Gabriel.
   Data   : 06/10/2011                     Ultima atualizacao: 15/03/2013

   Dados referentes ao programa:

   Objetivo  : Include com as temp-table da B1wgen0118.p      

   Alteracoes: 15/03/2013 - Incluir origem da operacao (Gabriel).
   
               21/07/2014 - Adicionado campo dsorigem (Reinert).
............................................................................ */

DEF TEMP-TABLE tt-crapldt 
         FIELD cdagerem LIKE crapldt.cdagerem
         FIELD dsagerem AS CHAR
         FIELD cdpacrem AS INTE /* LIKE crapldt.cdpacrem */
         FIELD nrctarem LIKE crapldt.nrctarem
         FIELD nmprirem AS CHAR
         FIELD nrcpfrem AS DECI 
         FIELD inpesrem AS INTE
         FIELD cdagedst LIKE crapldt.cdagedst   
         FIELD dsagedst AS CHAR
         FIELD cdpacdst AS INTE /* Gabriel */
         FIELD nrctadst LIKE crapldt.nrctadst
         FIELD nmpridst AS CHAR
         FIELD nrcpfdst AS DECI   
         FIELD inpesdst AS INTE
         FIELD dstransa AS CHAR
         FIELD vllanmto LIKE crapldt.vllanmto   
         FIELD dspacrem AS CHAR
         FIELD dsorigem AS CHAR
         INDEX tt-crapldt1 cdagedst cdagerem. 
                                                                               
                                                                               
/* ......................................................................... */ 
