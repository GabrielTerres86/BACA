/* .............................................................................

   Programa: Includes/secexta.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Setembro/91                         Ultima Atualizacao: 01/02/2006

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Processar a rotina de alteracao da tela SECEXT.

   Alteracoes: Unificacao dos Bancos - SQLWorks - Fernando.

............................................................................. */


DO WHILE TRUE:

   ASSIGN tel_cdsecext  =  crapdes.cdsecext
          tel_nmsecext  =  crapdes.nmsecext
          tel_nmpesext  =  crapdes.nmpesext
          tel_cdagenci  =  crapdes.cdagenci
          tel_nrfonext  =  crapdes.nrfonext
          tel_indespac  =  IF   crapdes.indespac = 0 THEN
                                TRUE
                           ELSE FALSE.
            
   DISPLAY  tel_nmsecext  tel_nmpesext  tel_nrfonext  tel_indespac
            WITH FRAME f_secao.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
      
      UPDATE  tel_nmsecext  tel_nmpesext  tel_nrfonext  tel_indespac
              WITH FRAME f_secao.
               
      LEAVE.
      
   END.        

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR" THEN  /* F4 OU FIM */
        DO:
            HIDE FRAME f_secao.
            RETURN. 
        END.
            
   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      aux_confirma = "N".
      glb_cdcritic = 78.
      RUN fontes/critic.p.
      BELL.
      glb_cdcritic = 0.
      MESSAGE COLOR NORMAL glb_dscritic UPDATE aux_confirma.
      LEAVE.

   END.  /*  Fim do DO WHILE TRUE  */

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   OR
        aux_confirma <> "S" THEN
        DO:
            glb_cdcritic = 79.
            RUN fontes/critic.p.
            glb_cdcritic = 0.
            BELL.
            MESSAGE glb_dscritic.
            PAUSE 5 NO-MESSAGE.
            HIDE FRAME f_secao.
            RETURN.
        END.    
 
   DO TRANSACTION:
   
      FIND crapdes WHERE crapdes.cdcooper = glb_cdcooper  AND 
                         crapdes.cdagenci = tel_cdagenci  AND
                         crapdes.cdsecext = tel_cdsecext 
                         EXCLUSIVE-LOCK  NO-ERROR.
           
      ASSIGN crapdes.nmsecext  =  tel_nmsecext
             crapdes.nmpesext  =  tel_nmpesext
             crapdes.nrfonext  =  tel_nrfonext
             crapdes.indespac  =  IF   tel_indespac THEN
                                       0
                                  ELSE 1.    
      RELEASE crapdes.
            
   END.  /*  Fim do DO TRANSACTION  */

   HIDE FRAME f_secao.

   LEAVE.

END.  /*  Fim do DO WHILE TRUE  */

/* .......................................................................... */

