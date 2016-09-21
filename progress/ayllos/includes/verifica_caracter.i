/* ..........................................................................
   Programa: includes/verifica_caracter.i
   Sistema : 
   Sigla   : CRED
   Autor   : Tiago
   Data    : Dezembro/2015                      Ultima atualizacao: 00/00/0000

   Dados referentes ao programa:

   Frequencia: Sempre que for chamado.
   Objetivo  : Processar validacoes de caracteres em campos digitaveis

   Alteracoes: 
............................................................................. */

FUNCTION fn_caracteres_validos RETURN LOGICAL(INPUT letra AS CHAR,
                                              INPUT valido AS CHAR,
                                              INPUT invalido AS CHAR):
    
    IF letra = "CURSOR-LEFT"  OR 
       letra = "CURSOR-RIGHT" OR 
       letra = "BACKSPACE"    OR
       letra = "DELETE-CHARACTER" OR
       letra = "END-ERROR"    OR 
       letra = "RETURN"       THEN
       RETURN TRUE.

    /*
    IF UPPER(invalido) MATCHES "*" + UPPER(letra) + "*"  THEN
       RETURN FALSE.
    */
    IF invalido = " " AND letra = " " THEN
       RETURN FALSE.

    IF CAN-DO(UPPER(invalido),UPPER(letra)) THEN
       RETURN FALSE.

    IF CAN-DO("0,1,2,3,4,5,6,7,8,9,Q,W,E,R,T,Y,U,I,O,P,A,S,D,F,G,H,J,K,L,Z,X,C,V,B,N,M",UPPER(letra)) THEN
       RETURN TRUE.

    IF valido = " " AND letra = " " THEN
       RETURN TRUE.
                   
    IF CAN-DO(UPPER(valido),UPPER(letra)) THEN
       RETURN TRUE. 

    /* IF "0123456789QWERTYUIOPASDFGHJKLZXCVBNM" + upper(valido) MATCHES "*" + upper(letra) + "*"  THEN
          RETURN TRUE. */

    RETURN FALSE.
END FUNCTION.
