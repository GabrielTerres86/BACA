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
                            
               09/08/2013 - Adicionado replace para 'Щ' e 'щ'. (Fabricio)
			   
			         06/04/2016 - Complementando os acentos que faltavam na validacao. (Kelvin)
               
               07/04/2016 - Adicionado a remocao do caracter "&" para vazio para
                            correcao do chamado 430305 (Kelvin).

               26/03/2017 - Adicionado remocao do caracter "э" e "Э" para corrigir o chamado 869784 (Alcemir - Mouts).
							
               05/07/2018 - Adicionado a remocao dos caracteres "дкож" para "AEIO" para
                            correcao do chamado PRB0040132 (AndrИ Bohn - MoutS).							
.............................................................................*/


DEF INPUT-OUTPUT PARAM par_dsstring AS CHARACTER                       NO-UNDO.

ASSIGN par_dsstring = REPLACE(par_dsstring,"а","A")
	     par_dsstring = REPLACE(par_dsstring,"ю","A")
       par_dsstring = REPLACE(par_dsstring,"б","A")
       par_dsstring = REPLACE(par_dsstring,"ц","A")
       par_dsstring = REPLACE(par_dsstring,"д","A")
	   
       par_dsstring = REPLACE(par_dsstring,"и","E")     
	     par_dsstring = REPLACE(par_dsstring,"х","E")
       par_dsstring = REPLACE(par_dsstring,"й","E")
       par_dsstring = REPLACE(par_dsstring,"к","E")
	    
       par_dsstring = REPLACE(par_dsstring,"м","I")
	     par_dsstring = REPLACE(par_dsstring,"л","I")
	     par_dsstring = REPLACE(par_dsstring,"н","I")
	     par_dsstring = REPLACE(par_dsstring,"о","I")
	   
       par_dsstring = REPLACE(par_dsstring,"с","O")      
	     par_dsstring = REPLACE(par_dsstring,"р","O")      
       par_dsstring = REPLACE(par_dsstring,"т","O")        
       par_dsstring = REPLACE(par_dsstring,"у","O")
       par_dsstring = REPLACE(par_dsstring,"ж","O")
          
       par_dsstring = REPLACE(par_dsstring,"з","U")    
	     par_dsstring = REPLACE(par_dsstring,"ы","U")
       par_dsstring = REPLACE(par_dsstring,"ш","U")

       par_dsstring = REPLACE(par_dsstring,"г","C")   

       par_dsstring = REPLACE(par_dsstring,"'","")        
       par_dsstring = REPLACE(par_dsstring,"`","")
       par_dsstring = REPLACE(par_dsstring,"╢","")
       par_dsstring = REPLACE(par_dsstring,"&","")
       
       par_dsstring = REPLACE(par_dsstring,"Щ","")
	     par_dsstring = REPLACE(par_dsstring,"Щ","y")
       
	   par_dsstring = REPLACE(par_dsstring,"Э","u")
	   par_dsstring = REPLACE(par_dsstring,"э","U")
	   
       par_dsstring = REPLACE(par_dsstring,"я","N").
       
       
       
                                                      
/*............................................................................*/
