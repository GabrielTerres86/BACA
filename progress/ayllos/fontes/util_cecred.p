/* ..........................................................................

   Programa: Fontes/util_cecred.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Julio
   Data    : Janeiro/2004.                       Ultima atualizacao: 22/06/2012

   Dados referentes ao programa:

   Frequencia: Diario (Batch).
   Objetivo  : Conter funcoes que poderao ser utilizadas por qualquer 
               programa que rodar no banco da CECRED.

   ROTINAS :

     PROCEDURE p_cdcooper { pesquisa no crapsig o codigo da cooperativa
               a partir do numero da conta junto a CECRED } - (Julio)
                  
     PROCEDURE p_nrdctabradesco { pesquisa no crapsig o numero da conta junto
               a CECRED a partir do crapsig.cdcooper } - (Julio)

     FUNCTION  f_nmrescop { pesquisa no crapsig o nome resumido da cooperativa
               a partir do numero da cooperativa } - (Julio)
               
     PROCEDURE f_cdultimacoop { retorna o codigo da ultima cooperativa
               cadastrada - utilizado no programa crps383 - Faturas Bradesco }
               - (Ze)

   Alteracoes: 20/02/2008 - Substituido uso da tabela crapsig pela tabela
                            crapcop (Elton).
                            
               26/11/2010 - Incluir a funcao f_cdultimacoop (Ze).
               
               22/06/2012 - Substituido gncoper por crapcop (Tiago).          
............................................................................ */
                        
PROCEDURE p_cdcooper:

  DEF   INPUT   PARAMETER   par_nrctactl   LIKE   crapcop.nrctactl     NO-UNDO.
  DEF   OUTPUT  PARAMETER   par_cdcooper   LIKE   crapcop.cdcooper     NO-UNDO.
  

  FIND crapcop WHERE crapcop.nrctactl = par_nrctactl NO-LOCK NO-ERROR.
  
  IF   NOT AVAILABLE crapcop THEN
       par_cdcooper = 0.
  ELSE
       par_cdcooper = crapcop.cdcooper.

END.

PROCEDURE p_nrdctacoop:

  DEF   INPUT   PARAMETER   par_cdcooper   LIKE  crapcop.cdcooper     NO-UNDO.
  DEF   OUTPUT  PARAMETER   par_nrctactl   LIKE  crapcop.nrctactl     NO-UNDO.
  
  FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

  IF   NOT AVAILABLE crapcop   THEN
       par_nrctactl = 0.
  ELSE
       par_nrctactl = crapcop.nrctactl.

END.

FUNCTION f_nmrescop RETURNS CHAR(INPUT par_cdcooper AS INTEGER):      

  FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

  IF   AVAILABLE crapcop   THEN
       RETURN "".
  ELSE
       RETURN crapcop.nmrescop.
       
END.

PROCEDURE f_cdultimacoop:

  DEF   OUTPUT  PARAMETER   par_qtcooper   LIKE  crapcop.nrctactl     NO-UNDO.

  FIND LAST crapcop WHERE crapcop.cdcooper <> 3 NO-LOCK NO-ERROR.
       
  IF   NOT AVAILABLE crapcop   THEN
       par_qtcooper = 0.
  ELSE
       par_qtcooper = crapcop.cdcooper.
       
END.

/* .......................................................................... */
