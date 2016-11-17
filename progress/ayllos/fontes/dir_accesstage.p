/*.............................................................................

 Programa: fontes/dir_accesstage.p
 Sistema : Conta-Corrente - Cooperativa de Credito
 Sigla   : CRED
 Autora  : Julio
 Data    : Janeiro/2014                        Ultima Atualizacao: 02/01/2014

 Dados referentes ao programa:
   
 Frequencia: Chamado pelo Script TransAccesStage.sh
 Objetivo  : Relacionar os diretorios utilizados para os convenios que utilizam
             AccesStage como meio de transmissao.
.............................................................................*/
  
DEF STREAM str_1.                       

FUNCTION fNomeArq RETURNS CHARACTER(INPUT par_nmarquiv as CHAR):
  DEF VAR aux_contachr AS INT  INIT 1  NO-UNDO.
  DEF VAR aux_retorno  AS CHAR INIT "" NO-UNDO.
  
  DO WHILE aux_contachr <= LENGTH(par_nmarquiv):
     IF ASC(SUBSTR(par_nmarquiv, aux_contachr, 1)) >= 97 AND 
        ASC(SUBSTR(par_nmarquiv, aux_contachr, 1)) <= 122 THEN
        aux_retorno = aux_retorno + SUBSTR(par_nmarquiv, aux_contachr, 1).
     aux_contachr = aux_contachr + 1.
  END.   
  
  RETURN aux_retorno.
END.
      
OUTPUT STREAM str_1 TO /tmp/dir_accesstage.tmp.

FOR EACH gnconve WHERE gnconve.tpdenvio = 5 AND gnconve.flgativo NO-LOCK:
    IF TRIM(gnconve.nmarqatu) <> "" THEN
       PUT STREAM str_1 UNFORMATTED gnconve.cdconven ":" gnconve.dsdiracc ":" 
                        fNomeArq(gnconve.nmarqatu) ":Envia" SKIP.
                     
    IF TRIM(gnconve.nmarqdeb) <> "" THEN
       PUT STREAM str_1 UNFORMATTED gnconve.cdconven ":" gnconve.dsdiracc ":"
                        fNomeArq(gnconve.nmarqdeb) ":Envia" SKIP.
                     
    IF TRIM(gnconve.nmarqcxa) <> "" THEN
       PUT STREAM str_1 UNFORMATTED gnconve.cdconven ":" gnconve.dsdiracc ":" 
                        fNomeArq(gnconve.nmarqcxa) ":Envia" SKIP.
                     
    IF TRIM(gnconve.nmarqint) <> "" THEN
       PUT STREAM str_1 UNFORMATTED gnconve.cdconven ":" gnconve.dsdiracc ":"
                        fNomeArq(gnconve.nmarqint) ":Recebe" SKIP.
END.

OUTPUT STREAM str_1 CLOSE.

/*...........................................................................*/
