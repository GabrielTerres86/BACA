/* .............................................................................

   Programa: Fontes/secexti.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Setembro/91                       Ultima Atualizacao: 01/02/2006

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Processar a rotina de inclusao da tela SECEXT.

   Alteracoes: 06/07/2005 - Alimentado campo cdcooper da tabela crapdes (Diego).

               01/02/2006 - Unificacao dos campos - SQLWorks - Fernando.

............................................................................. */

DO WHILE TRUE:

   ASSIGN tel_nmsecext  = "" 
          tel_nmpesext  = "" 
          tel_nrfonext  = "" 
          tel_indespac  = TRUE.
            
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
   
      CREATE crapdes.
      ASSIGN crapdes.cdagenci  =  tel_cdagenci
             crapdes.cdsecext  =  tel_cdsecext
             crapdes.nmsecext  =  CAPS(tel_nmsecext)
             crapdes.nmpesext  =  CAPS(tel_nmpesext)
             crapdes.nrfonext  =  tel_nrfonext
             crapdes.cdcooper  =  glb_cdcooper
             crapdes.indespac  =  IF   tel_indespac THEN
                                       0
                                  ELSE 1.    
      RELEASE crapdes.
            
   END.  /*  Fim do DO TRANSACTION  */

   HIDE FRAME f_secao.

   LEAVE.

END.  /*  Fim do DO WHILE TRUE  */

/* .......................................................................... */

