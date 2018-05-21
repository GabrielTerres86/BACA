/*............................................................................

   Programa: Fontes/substitui_caracter.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Gabriel
   Data    : Julho/2009                          Ultima atualizacao: 07/04/2016

   Dados referentes ao programa:
   
   Frequencia: Sempre que chamado por outros programas.
   Objetivo  : Substituir caracter acentuados pelos nao acentuados, usado
               para converter strings do progrid para o ayllos.
               
   Alteracoes: 31/05/2010 - Substituir caracteres "/" e "'" por " "
               (Fernando).
               
               03/03/2011 - Deixar um espaco em branco quando aspas simples
                            (Gabriel).
                            
               05/04/2011 - Modificar o keyfunction pelo caracter 
                            correspondente.
                            Substituir o caracter '`' por branco. (Gabriel).
                            
               09/08/2013 - Adicionado replace para 'ý' e 'Ý'. (Fabricio)
			   
			         06/04/2016 - Complementando os acentos que faltavam na validacao. (Kelvin)
               
               07/04/2016 - Adicionado a remocao do caracter "&" para vazio para
                            correcao do chamado 430305 (Kelvin).

               26/03/2017 - Adicionado remocao do caracter "Ü" e "ü" para corrigir o chamado 869784 (Alcemir - Mouts).
.............................................................................*/


DEF INPUT-OUTPUT PARAM par_dsstring AS CHARACTER                       NO-UNDO.

ASSIGN par_dsstring = REPLACE(par_dsstring,"Á","A")
	     par_dsstring = REPLACE(par_dsstring,"À","A")
       par_dsstring = REPLACE(par_dsstring,"Â","A")
       par_dsstring = REPLACE(par_dsstring,"Ã","A")
	   
       par_dsstring = REPLACE(par_dsstring,"É","E")     
	     par_dsstring = REPLACE(par_dsstring,"È","E")
       par_dsstring = REPLACE(par_dsstring,"Ê","E")
	    
       par_dsstring = REPLACE(par_dsstring,"Í","I")
	     par_dsstring = REPLACE(par_dsstring,"Ì","I")
	     par_dsstring = REPLACE(par_dsstring,"Î","I")
	   
       par_dsstring = REPLACE(par_dsstring,"Ó","O")      
	     par_dsstring = REPLACE(par_dsstring,"Ò","O")      
       par_dsstring = REPLACE(par_dsstring,"Ô","O")        
       par_dsstring = REPLACE(par_dsstring,"Õ","O")
          
       par_dsstring = REPLACE(par_dsstring,"Ú","U")    
	     par_dsstring = REPLACE(par_dsstring,"Ù","U")
       par_dsstring = REPLACE(par_dsstring,"Û","U")

       par_dsstring = REPLACE(par_dsstring,"Ç","C")   

       par_dsstring = REPLACE(par_dsstring,"'","")        
       par_dsstring = REPLACE(par_dsstring,"`","")
       par_dsstring = REPLACE(par_dsstring,"´","")
       par_dsstring = REPLACE(par_dsstring,"&","")
       
       par_dsstring = REPLACE(par_dsstring,"ý","")
	     par_dsstring = REPLACE(par_dsstring,"ý","y")
       
	   par_dsstring = REPLACE(par_dsstring,"ü","u")
	   par_dsstring = REPLACE(par_dsstring,"Ü","U")
	   
       par_dsstring = REPLACE(par_dsstring,"Ñ","N").
       
       
       
                                                      
/*............................................................................*/
