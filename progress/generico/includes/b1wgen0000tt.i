/*..............................................................................

   Programa: b1wgen0000tt.i                  
   Autor   : David
   Data    : Agosto/2007                      Ultima atualizacao: 27/06/2016

   Dados referentes ao programa:

   Objetivo  : Arquivo com variaveis utlizadas na BO b1wgen0000.p

   Alteracoes: 30/07/2008 - Adicionar tldatela na tt-menu (Guilherme).
               
               12/08/2008 - Incluir campo stimeout na tt-login (David).
               
               30/07/2010 - Incluir campos dsdepart e nmdircop na tt-login 
                            (David).
                            
               14/07/2011 - Incluir campo para informar se senha deve ser
                            trocada (Gabriel)             
               
               19/01/2012 - Incluir campo cdpactra na tt-login (Tiago).
               
               07/02/2013 - Incluir campo flgperac e nvoperad em temp-table 
                            tt-login (Lucas R.).
                            
               27/06/2016 - Incluir o cdoperad na tt-login para e setar a
                            variavel de sessao com valor que esta retornando do
                            cadastro do operador. Quando o operador digita o
                            codigo do operador em maisculo na variavel de sessao
                            gravava o cdoperad digitado enquanto no cadastro
                            estava em minusculo, isto gerava problemas no oracle
                            ao consultar um nome de operador usando a variavel
                            cdoperad da sessao que estava em maisculo.        

			   07/12/2016 - P341-Automatização BACENJUD - Incluir o CDDEPART na 
			                temp-table tt-login (Renato Darosci)
..............................................................................*/

DEF TEMP-TABLE tt-login                                                 NO-UNDO
    FIELD nmoperad LIKE crapope.nmoperad
    FIELD nmrescop LIKE crapcop.nmrescop 
    FIELD dtmvtolt LIKE crapdat.dtmvtolt
    FIELD dtmvtopr LIKE crapdat.dtmvtopr
    FIELD dtmvtoan LIKE crapdat.dtmvtoan
    FIELD inproces LIKE crapdat.inproces
    FIELD stimeout AS INTE
	 FIELD dsdepart LIKE crapdpo.dsdepart
    FIELD dsdircop LIKE crapcop.dsdircop
    FIELD flgdsenh AS LOGI
    FIELD cdpactra LIKE crapope.cdpactra
    FIELD flgperac LIKE crapope.flgperac
    FIELD nvoperad LIKE crapope.nvoperad
    FIELD cdoperad LIKE crapope.cdoperad
	FIELD cddepart LIKE crapdpo.cddepart.
    
DEF TEMP-TABLE tt-menu                                                  NO-UNDO
    FIELD nmdatela LIKE craptel.nmdatela
    FIELD nrmodulo LIKE craptel.nrmodulo.

DEF TEMP-TABLE tt-opcoes                                                NO-UNDO
    FIELD cddopcao LIKE crapace.cddopcao.

DEF TEMP-TABLE tt-rotinas                                               NO-UNDO
    FIELD nmrotina LIKE craptel.nmrotina.

DEF TEMP-TABLE tt-cabec-relatorio                                       NO-UNDO
    FIELD nmrescop LIKE crapcop.nmrescop
    FIELD nmrelato LIKE craprel.nmrelato
    FIELD nmdestin LIKE craprel.nmdestin.

 
/*............................................................................*/
