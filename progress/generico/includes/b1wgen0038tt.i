/*.............................................................................

    Programa: sistema/generico/includes/b1wgen0038tt.i                  
    Autor   : David
    Data    : Janeiro/2009                    Ultima atualizacao: 13/08/2015

   Dados referentes ao programa:

   Objetivo  : Arquivo com variaveis utlizadas na BO b1wgen0038.p

   Alteracoes: 31/03/2010 - Adaptacao para tela CONTAS (David).
   
               06/04/2011 - Inclusão temp-table tt-endereco para busca
                            (André - DB1)
                            
               28/04/2011 - Inserção de campo dtinires. (André - DB1)
               
               14/06/2011 - Criado tt-msg-endereco (Jorge).  
               
               01/07/2011 - Incluidos campos nrdoapto cddbloco na temp-table 
                            tt-endereco-cooperado (Henrique).
                                             
               08/08/2011 - Incluido campo nrdrowid na temp-table 
                            tt-endereco (Henrique).
                            
               14/03/2012 - Adicionado index idoricad em tt-enderecos. (Jorge)
               
               13/08/2015 - Reformulacao cadastral (Gabriel-RKAM).
			   
			   01/02/2016 - Melhoria 147 - Adicionar Campos e Aprovacao de
			                Transferencia entre PAs (Heitor - RKAM)
                                             
               23/03/2019 - Inclusão dos campos de dsdcanal; dtrevisa (Vitor S. Assanuma - GFT)
                                             
.............................................................................*/


DEF TEMP-TABLE tt-endereco-cooperado                                    NO-UNDO
    FIELD flgtpenc AS LOGI
    FIELD incasprp AS INTE
    FIELD dscasprp AS CHAR
    FIELD nranores AS CHAR
    FIELD dtinires AS CHAR
    FIELD vlalugue AS DECI
    FIELD nrcepend AS INTE
    FIELD dsendere AS CHAR
    FIELD nrendere AS INTE
    FIELD complend AS CHAR
    FIELD nmbairro AS CHAR
    FIELD nmcidade AS CHAR
    FIELD cdufende AS CHAR
    FIELD nrcxapst AS INTE
    FIELD cdseqinc AS INTE
    FIELD tpendass AS INTE
    FIELD nrdoapto AS INTE
    FIELD cddbloco AS CHAR
    FIELD qtprebem AS INTE
    FIELD vlprebem AS DECI
    FIELD idorigem AS INTE
    FIELD dsdcanal AS CHAR
    FIELD dtrevisa AS DATE FORMAT "99/99/9999".

DEF TEMP-TABLE tt-endereco                                              NO-UNDO
    FIELD nrcepend AS INTE FORMAT "99999,999"
    FIELD dsendere AS CHAR FORMAT "x(40)" /* Endereco com tipo de logradouro */   
    FIELD dscmpend AS CHAR FORMAT "x(90)"    
    FIELD dsendcmp AS CHAR FORMAT "x(50)"    
    FIELD cdufende AS CHAR FORMAT "!(2)"
    FIELD nmbairro AS CHAR FORMAT "x(40)"
    FIELD nmcidade AS CHAR FORMAT "x(50)"
    FIELD dsoricad AS CHAR FORMAT "x(40)"
    FIELD dstiplog AS CHAR FORMAT "x(25)"
    FIELD idoricad AS INTE FORMAT "9"
    FIELD nrdrowid AS ROWID
    FIELD dsender2 AS CHAR FORMAT "x(40)" /* Endereco sem tipo de logradouro */
    INDEX tt-endereco1 idoricad dsender2.
    
DEF TEMP-TABLE tt-msg-endereco                                    NO-UNDO
    FIELD dsmsagem AS CHAR.
                                   
DEF TEMP-TABLE tt-arquivos                                        NO-UNDO
    FIELD nmarquiv AS CHAR.


/*............................................................................*/



