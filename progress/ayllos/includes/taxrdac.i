/* .............................................................................

   Programa: Includes/taxrdac.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Margarete                       Ultima Atualizacao: 02/02/2006
   Data    : Janeiro/2002

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Processar a rotina de consulta da tela taxrda.

   Alteracoes: 25/09/2003 - Atualizar campo de T.R usada (Margarete).

               02/02/2006 - Unificacao dos Bancos - SQLWorks - Luciane.
............................................................................. */

DO WHILE TRUE ON ENDKEY UNDO WITH FRAME f_consulta:
  
   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"  AND
        aux_prmconsu                        THEN
        LEAVE.
                     
   CLEAR FRAME f_tipo_data.
   HIDE FRAME f_tipo_data.
   
   UPDATE tel_tptaxcon tel_dtinicon tel_vlfaixas WITH FRAME f_consulta
   EDITING:
            READKEY.
            
            IF   FRAME-FIELD = "tel_tptaxcon"       
            AND  KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN 
                 DO:
                     IF   aux_prmconsu   THEN
                          APPLY LASTKEY.
                     ELSE     
                          LEAVE.
                 END.
            ELSE 
                
            IF   FRAME-FIELD = "tel_vlfaixas"   THEN
                 IF   LASTKEY =  KEYCODE(".")   THEN
                      APPLY 44.
                 ELSE
                      APPLY LASTKEY.
            ELSE
                 APPLY LASTKEY.

   END.  /*  Fim do EDITING  */
                    
   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
        LEAVE.
                                 
   ASSIGN aux_prmconsu = NO.
                  
   OPEN QUERY bcraptr1-q 
        FOR EACH craptrd WHERE craptrd.cdcooper = glb_cdcooper    AND
                               craptrd.dtiniper >= tel_dtinicon   AND
                               craptrd.tptaxrda  = tel_tptaxcon   AND
                               craptrd.vlfaixas  = tel_vlfaixas   NO-LOCK.        
   ENABLE bcraptr1-b WITH FRAME f_tipo_data.
                       
   WAIT-FOR WINDOW-CLOSE OF CURRENT-WINDOW.
 
END.
                         
HIDE FRAME f_tipo_data.
/* .......................................................................... */

