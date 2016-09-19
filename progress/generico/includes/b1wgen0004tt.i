/*..............................................................................

   Programa: b1wgen0004tt.i                  
   Autor   : David
   Data    : Agosto/2007                      Ultima atualizacao: 22/10/2014

   Dados referentes ao programa:

   Objetivo  : Arquivo com variaveis utlizadas na BO b1wgen0004.p

   Alteracoes: 21/02/2008 - Retirado tt-output, conflito BO1(Guilherme).

               31/03/2008 - Incluir temp-table tt-acumula (David).
               
               09/10/2009 - Incluir campo cddresga na tt-saldo-rdca (David).
               
               21/09/2010 - Inlcuir temp-table tt-dados-aplicacao (Vitor).
               
               30/11/2010 - Foram retirdas algumas das TEMP-TABLES e passadas
                            para a nova BO b1wgen0081tt.i (Adriano).
                            
               01/08/2011 - Adicionado os campos cdoperad, qtdiaapl, qtdiauti
                            dsaplica,tpaplrdc, vlaplica, vlsdrdad na temp-table
                            tt-saldo-rdca ( Gabriel - DB1 ).
                            
               16/08/2011 - Criado temp-table tt-resposta-cliente e 
                                              tt-dados-resgate. (Fabricio)
                                              
               13/10/2014 - Aumentado format do campo dsaplica na tt-saldo-rdca
                            (Reinert).
               
                   22/10/2014 - Criacao do novo campo idtipapl na tt-saldo-rdca
                            necessario para distinguir as aplicacoes novas
                            e antigas na B1WGEN0112.P 
                            (Carlos R. - Projeto Captacao)             
               
               01/04/2015 - Criacao de novo campo dtcarenc na tt-saldo-rdca
                            SD - 266191 (Kelvin)
                            
               08/04/2015 - Criacao do novo campo dsnomenc na tt-saldo-rdca
                            necessario na B1WGEN0112.P 
                            (Carlos R. - Projeto Captacao)                 
.............................................................................*/

DEF TEMP-TABLE tt-acumula NO-UNDO
    FIELD nraplica LIKE craprda.nraplica
    FIELD tpaplica AS CHAR 
    FIELD vlsdrdca LIKE craprda.vlsdrdca.
    
DEF TEMP-TABLE tt-saldo-rdca NO-UNDO
    FIELD dtmvtolt AS DATE FORMAT "99/99/9999"
    FIELD nraplica AS INTE FORMAT "zzz,zz9"
    FIELD dshistor AS CHAR FORMAT "x(25)"
    FIELD nrdocmto AS CHAR FORMAT "x(12)"
    FIELD dtvencto AS DATE FORMAT "99/99/9999"
    FIELD indebcre AS CHAR FORMAT " x "
    FIELD vllanmto AS DECI FORMAT "zzz,zzz,zzz,zz9.99-"
    FIELD sldresga AS DECI FORMAT "zzz,zzz,zzz,zz9.99-"
    FIELD vlsdrdad AS DECI FORMAT "zzz,zzz,zzz,zz9.99-"
    FIELD cddresga AS CHAR FORMAT "x(3)"
    FIELD dtresgat AS DATE FORMAT "99/99/9999"
    FIELD dssitapl AS CHAR FORMAT "x(10)"
    FIELD txaplmax AS CHAR FORMAT "x(10)"
    FIELD txaplmin AS CHAR FORMAT "x(10)"
    FIELD qtdiacar AS INTE FORMAT "zz9"
    FIELD cdoperad AS CHAR FORMAT "x(10)"
    FIELD qtdiaapl AS INTE FORMAT "zzz9"
    FIELD qtdiauti AS INTE FORMAT "zzz9"
    FIELD dsaplica AS CHAR FORMAT "x(20)"
    FIELD tpaplrdc AS INTE FORMAT "zzz9"
    FIELD tpaplica AS INTE FORMAT "zzz9"
    FIELD vlaplica AS DECI FORMAT "zzz,zzz,zzz,zz9.99"
    FIELD cdprodut LIKE craprac.cdprodut
    FIELD idtipapl AS CHAR FORMAT "x(1)"
    FIELD dtiniper AS DATE FORMAT "99/99/9999"
    FIELD dtcarenc AS DATE FORMAT "99/99/9999"
    FIELD dsnomenc AS CHAR FORMAT "x(20)".
    
DEF TEMP-TABLE tt-extr-rdc NO-UNDO
    FIELD dtmvtolt LIKE crapdat.dtmvtolt
    FIELD cdagenci LIKE crapage.cdagenci
    FIELD cdbccxlt LIKE craplap.cdbccxlt
    FIELD nrdolote LIKE craplap.nrdolote
    FIELD cdhistor LIKE craphis.cdhistor
    FIELD dshistor LIKE craphis.dshistor
    FIELD nrdocmto LIKE craplap.nrdocmto
    FIELD indebcre LIKE craphis.indebcre
    FIELD vllanmto LIKE craplap.vllanmto
    FIELD vlsdlsap LIKE craplap.vlsdlsap
    FIELD txaplica LIKE craplap.txaplica
    FIELD vlpvlrgt LIKE craplap.vlpvlrgt.

/* tabela para retornar as respostas do cliente caso a aplicacao esteja a menos
   de dez dias para vencer(Ayllos Web) */
DEF TEMP-TABLE tt-resposta-cliente NO-UNDO
    FIELD nraplica LIKE craprda.nraplica
    FIELD dtvencto LIKE craprda.dtvencto
    FIELD resposta AS CHAR.

DEF TEMP-TABLE tt-dados-resgate NO-UNDO LIKE tt-saldo-rdca
    FIELD vlresgat LIKE tt-dados-resgate.sldresga
    FIELD tpresgat AS CHAR.


/*............................................................................*/
