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
                            
               09/08/2013 - Adicionado replace para '�' e '�'. (Fabricio)
			   
			         06/04/2016 - Complementando os acentos que faltavam na validacao. (Kelvin)
               
               07/04/2016 - Adicionado a remocao do caracter "&" para vazio para
                            correcao do chamado 430305 (Kelvin).

               26/03/2017 - Adicionado remocao do caracter "�" e "�" para corrigir o chamado 869784 (Alcemir - Mouts).
							
               05/07/2018 - Adicionado a remocao dos caracteres "����" para "AEIO" para
                            correcao do chamado PRB0040132 (Andr� Bohn - MoutS).							
.............................................................................*/


DEF INPUT-OUTPUT PARAM par_dsstring AS CHARACTER                       NO-UNDO.

ASSIGN par_dsstring = REPLACE(par_dsstring,"�","A")
	     par_dsstring = REPLACE(par_dsstring,"�","A")
       par_dsstring = REPLACE(par_dsstring,"�","A")
       par_dsstring = REPLACE(par_dsstring,"�","A")
       par_dsstring = REPLACE(par_dsstring,"�","A")
	   
       par_dsstring = REPLACE(par_dsstring,"�","E")     
	     par_dsstring = REPLACE(par_dsstring,"�","E")
       par_dsstring = REPLACE(par_dsstring,"�","E")
       par_dsstring = REPLACE(par_dsstring,"�","E")
	    
       par_dsstring = REPLACE(par_dsstring,"�","I")
	     par_dsstring = REPLACE(par_dsstring,"�","I")
	     par_dsstring = REPLACE(par_dsstring,"�","I")
	     par_dsstring = REPLACE(par_dsstring,"�","I")
	   
       par_dsstring = REPLACE(par_dsstring,"�","O")      
	     par_dsstring = REPLACE(par_dsstring,"�","O")      
       par_dsstring = REPLACE(par_dsstring,"�","O")        
       par_dsstring = REPLACE(par_dsstring,"�","O")
       par_dsstring = REPLACE(par_dsstring,"�","O")
          
       par_dsstring = REPLACE(par_dsstring,"�","U")    
	     par_dsstring = REPLACE(par_dsstring,"�","U")
       par_dsstring = REPLACE(par_dsstring,"�","U")

       par_dsstring = REPLACE(par_dsstring,"�","C")   

       par_dsstring = REPLACE(par_dsstring,"'","")        
       par_dsstring = REPLACE(par_dsstring,"`","")
       par_dsstring = REPLACE(par_dsstring,"�","")
       par_dsstring = REPLACE(par_dsstring,"&","")
       
       par_dsstring = REPLACE(par_dsstring,"�","")
	     par_dsstring = REPLACE(par_dsstring,"�","y")
       
	   par_dsstring = REPLACE(par_dsstring,"�","u")
	   par_dsstring = REPLACE(par_dsstring,"�","U")
	   
       par_dsstring = REPLACE(par_dsstring,"�","N").
       
       
       
                                                      
/*............................................................................*/
