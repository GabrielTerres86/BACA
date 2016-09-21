/* .............................................................................

   Programa: Includes/taxcdic.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Margarete                       Ultima Atualizacao: 17/11/2011 
   Data    : Novembro/2003

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Processar a rotina de consulta da tela taxcdi.

   Alteracoes: 02/02/2006 - Unificacao dos Bancos - SQLWorks - Luciane.
               
               19/09/2006 - Mostrar Taxa CDI e Poupanca na consulta (Elton).
               
               19/03/2009 - Ajustes para unificacao dos bancos de dados
                            (Evandro).
                            
               17/11/2011 - Incluir a coluna CDI Acumulado na opcao "C"
                            (Isara - RKAM).                             

............................................................................. */

DEF VAR aux_dtinicon AS DATE                                        NO-UNDO.

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
                  

   EMPTY TEMP-TABLE w-crapmfx.

   FIND LAST craptrd WHERE craptrd.cdcooper = glb_cdcooper
                           USE-INDEX craptrd1 NO-LOCK NO-ERROR.
                           
   DO  aux_dtinicon = tel_dtinicon TO craptrd.dtiniper:
       CREATE  w-crapmfx.
       ASSIGN  w-crapmfx.cdcooper = glb_cdcooper 
               w-crapmfx.dtmvtolt = aux_dtinicon.        
    END.

   FOR EACH crapmfx WHERE  crapmfx.cdcooper  = glb_cdcooper  AND
                           crapmfx.dtmvtolt >= tel_dtinicon  AND
                          (crapmfx.tpmoefix  = 8  OR 
                           crapmfx.tpmoefix  = 16 OR
                           crapmfx.tpmoefix  = 17)
                           NO-LOCK:

        FIND FIRST w-crapmfx  
             WHERE w-crapmfx.cdcooper = glb_cdcooper     
               AND w-crapmfx.dtmvtolt = crapmfx.dtmvtolt NO-ERROR.
        IF AVAIL w-crapmfx THEN
        DO:
            IF  crapmfx.tpmoefix = 8 THEN
                ASSIGN  w-crapmfx.vlmofx08 = 
                                   STRING(crapmfx.vlmoefix, "z9.999999").
                                         
            IF  crapmfx.tpmoefix = 16 THEN
                ASSIGN  w-crapmfx.vlmofx16 = 
                                     STRING(crapmfx.vlmoefix, "z9.999999").
    
            IF  crapmfx.tpmoefix = 17 THEN
                ASSIGN  w-crapmfx.vlmofx17 = 
                                     STRING(crapmfx.vlmoefix, "z9.999999").
        END.
   END.
               
   FOR  EACH craptrd WHERE craptrd.cdcooper  = glb_cdcooper  AND
                           craptrd.dtiniper >= tel_dtinicon  AND
                           craptrd.tptaxrda  = tel_tptaxcon  AND
                           craptrd.vlfaixas  = tel_vlfaixas
                           NO-LOCK:
            
        FIND FIRST w-crapmfx  
             WHERE w-crapmfx.cdcooper = glb_cdcooper     
               AND w-crapmfx.dtmvtolt = craptrd.dtiniper NO-ERROR.
        IF AVAIL w-crapmfx THEN
        DO:
            IF w-crapmfx.vlmofx08 = STRING(craptrd.vltrapli, "z9.999999") THEN
                w-crapmfx.vlmofx08 = w-crapmfx.vlmofx08 + "*" .
             
            IF w-crapmfx.vlmofx16 = STRING(craptrd.vltrapli, "z9.999999") THEN
                w-crapmfx.vlmofx16 = w-crapmfx.vlmofx16 + "*".

            IF w-crapmfx.vlmofx17 = STRING(craptrd.vltrapli, "z9.999999") THEN
                w-crapmfx.vlmofx17 = w-crapmfx.vlmofx17 + "*".
        END.
   END. 
   
   OPEN QUERY bcraptr1-q 
        FOR EACH  craptrd WHERE craptrd.cdcooper  = glb_cdcooper   AND
                                craptrd.dtiniper >= tel_dtinicon   AND
                                craptrd.tptaxrda  = tel_tptaxcon   AND
                                craptrd.vlfaixas  = tel_vlfaixas
                                NO-LOCK,
                               
              FIRST w-crapmfx WHERE w-crapmfx.cdcooper = glb_cdcooper AND 
                                    w-crapmfx.dtmvtolt = craptrd.dtiniper
                                    NO-LOCK.        

   ENABLE bcraptr1-b WITH FRAME f_tipo_data.
                       
   WAIT-FOR WINDOW-CLOSE OF CURRENT-WINDOW.
 
END.
                         
HIDE FRAME f_tipo_data.
/* .......................................................................... */

