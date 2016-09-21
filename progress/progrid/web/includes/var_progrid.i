/*..............................................................................

   Programa: var_progrid.i                  
   Autor   : Jean Michel
   Data    : Junho/2015                      Ultima atualizacao: 05/06/2015

   Dados referentes ao programa:

   Objetivo  : Arquivo com variaveis utlizadas nas BO's genericas do Progrid

   Alteracoes: 
               
..............................................................................*/
DEF VAR  aux_srvprogrid AS CHAR                                           NO-UNDO.

CASE OS-GETENV("PKGNAME"):
	
    /** DESENVOLVIMENTO **/
	WHEN "pkgdesen1" 	THEN aux_srvprogrid = "http://iprogriddev1.cecred.coop.br".
	WHEN "pkgdesen2" 	THEN aux_srvprogrid = "http://iprogriddev2.cecred.coop.br".
	/** HOMOLOGACAO **/
	WHEN "pkghomol1" 	THEN aux_srvprogrid = "http://iprogridhomol1.cecred.coop.br".
	WHEN "pkghomol2" 	THEN aux_srvprogrid = "http://iprogridhomol2.cecred.coop.br".
	WHEN "pkghomol3" 	THEN aux_srvprogrid = "http://iprogridhomol3.cecred.coop.br".
	WHEN "pkghomol4" 	THEN aux_srvprogrid = "http://iprogridhomol4.cecred.coop.br".
	/** QUALIDADE **/
	WHEN "pkgqa1" 		THEN aux_srvprogrid = "http://iprogridqa1.cecred.coop.br".
	WHEN "pkgqa2" 		THEN aux_srvprogrid = "http://iprogridqa2.cecred.coop.br".
	/** TREINA **/
	WHEN "pkgtreina" 	THEN aux_srvprogrid = "http://iprogridtreina2.cecred.coop.br".
	WHEN "pkgtreina2" 	THEN aux_srvprogrid = "http://iprogridtreina2.cecred.coop.br".
	/** LIBERA **/
	WHEN "pkglibera1" 	THEN aux_srvprogrid = "http://iprogridlibera1.cecred.coop.br".
	/** PRODUCAO **/
	WHEN "pkgprod" 	THEN aux_srvprogrid = "http://iprogrid.cecred.coop.br".
	
END CASE.
