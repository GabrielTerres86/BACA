/* ............................................................................

   Programa: Fontes/crps523.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Elton
   Data    : Janeiro/2009                   Ultima alteracao:   05/08/2014          
   
   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Atende a solicitacao 86.
               Gera relatorio de movimentos de GPS.
               Emite relatorio 427.
               Ordem: 52
    
   Alteracoes:  
   
   05/08/2014 - Alteração da Nomeclatura para PA (Vanessa).
............................................................................ */

DEF     STREAM str_1. /* relatorio */

{ includes/var_batch.i "NEW" }

{ includes/var_movgps_r.i }     

FORM SKIP(2)
     "GUIAS DA PREVIDENCIA -" 
     crapban.nmresbcc
     SPACE (2)
     "REFERENTE : "
     glb_dtmvtolt FORMAT "99/99/9999" 
     SKIP(2)
     WITH DOWN NO-BOX NO-LABELS WIDTH 132 FRAME f_titulo_guias.
    
ASSIGN glb_cdprogra = "crps523".
                      
RUN fontes/iniprg.p.

IF   glb_cdcritic > 0 THEN
     QUIT.
        
FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.

IF   NOT AVAILABLE crapcop THEN
     DO:
         glb_cdcritic = 651.
         RUN fontes/critic.p.
         UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                           " - " + glb_cdprogra + "' --> '"  +
                           glb_dscritic + " >> log/proc_batch.log").
         QUIT.
     END.

ASSIGN aux_nmarqimp = "rl/crrl427.lst".  

OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGED PAGE-SIZE 84.

{ includes/cabrel132_1.i }
        
VIEW STREAM str_1 FRAME f_cabrel132_1.
        
IF   crapcop.cdcrdarr = 0   THEN
     FIND crapban WHERE crapban.cdbccxlt = 1 NO-LOCK NO-ERROR.
ELSE
     FIND crapban WHERE crapban.cdbccxlt = 756 NO-LOCK NO-ERROR.
                                
DISPLAY STREAM str_1  crapban.nmresbcc 
                      glb_dtmvtolt       
                      WITH FRAME f_titulo_guias.  
                       
FOR EACH craplgp WHERE  craplgp.cdcooper  = glb_cdcooper      AND
                        craplgp.dtmvtolt  = glb_dtmvtolt      AND  
                        craplgp.flgenvio  = YES               NO-LOCK,
                  FIRST crapope WHERE 
                        crapope.cdcooper = glb_cdcooper       AND
                        crapope.cdoperad = craplgp.cdopecxa   NO-LOCK
                                BREAK BY craplgp.cdagenci                 
                                         BY craplgp.nrdcaixa
                                            BY craplgp.nrdolote           
                                               BY craplgp.nrautdoc:
                                   
    IF   LINE-COUNTER(str_1) >= (PAGE-SIZE(str_1) - 4)  THEN
         DO:
             PAGE STREAM str_1.
             VIEW STREAM str_1 FRAME f_cabrel132_1.
         END.

    IF   FIRST-OF (craplgp.cdagenci)   THEN
         DO:
             ASSIGN rel_vltotpag = 0.

             DISPLAY STREAM str_1  craplgp.cdagenci  WITH FRAME f_pac.
             DOWN STREAM str_1 WITH FRAME f_pac.
         END.

    IF   FIRST-OF (craplgp.nrdcaixa)   THEN
         DO:
             ASSIGN rel_vltotpag_cx = 0.
                 
             DISPLAY STREAM str_1  craplgp.nrdcaixa 
                                   craplgp.nrdolote
                                   WITH FRAME f_caixa.
         END.
         
    ASSIGN aux_nmoperad = craplgp.cdopecxa + "-" +  crapope.nmoperad.
            
    ASSIGN tel_hrtransa = STRING(craplgp.hrtransa,"HH:MM:SS").
                 
    DISPLAY STREAM str_1   tel_hrtransa
                           craplgp.cdidenti
                           craplgp.mmaacomp
                           craplgp.cddpagto
                           craplgp.vlrouent
                           craplgp.vlrjuros
                           craplgp.vlrdinss 
                           craplgp.vlrtotal
                           craplgp.nrautdoc 
                           aux_nmoperad
                           craplgp.flgenvio
                           WITH FRAME f_valores.
                           
    DOWN STREAM str_1 WITH FRAME f_valores.
    
    ASSIGN rel_vltotpag    = rel_vltotpag    + craplgp.vlrtotal
           rel_vltotpag_cx = rel_vltotpag_cx + craplgp.vlrtotal
           rel_vltotpag_tt = rel_vltotpag_tt + craplgp.vlrtotal.

    /* total do caixa */
    IF   LAST-OF (craplgp.nrdcaixa)   THEN
         DO:
              DOWN 1 STREAM str_1 WITH FRAME f_valores.
                     
              DISPLAY STREAM str_1  " " @ tel_hrtransa
                                    " " @ craplgp.cddpagto
                                    " " @ craplgp.mmaacomp
                                    " " @ craplgp.cdidenti
                                    " " @ craplgp.vlrouent  
                                    " " @ craplgp.vlrdinss
                                    rel_vltotpag_cx @ craplgp.vlrtotal
                                    " " @ craplgp.nrautdoc 
                                    "    Tot.Caixa"   @ craplgp.vlrjuros
                                    " " @ aux_nmoperad
                                    " " @ craplgp.flgenvio
                                    WITH FRAME f_valores.
                   
                     DOWN STREAM str_1 WITH FRAME f_valores.
         END.
        
    /* total do PA */
    IF   LAST-OF (craplgp.cdagenci)   THEN
         DO:
              DOWN 2 STREAM str_1 WITH FRAME f_valores.
                
              DISPLAY STREAM str_1  " " @ tel_hrtransa
                                    " " @ craplgp.cddpagto 
                                    " " @ craplgp.mmaacomp          
                                    " " @ craplgp.cdidenti
                                    " " @ craplgp.vlrouent
                                    " " @ craplgp.vlrdinss
                                    rel_vltotpag @ craplgp.vlrtotal
                                    " " @ craplgp.nrautdoc 
                                    "    Tot.PA"  @ craplgp.vlrjuros
                                    " " @ aux_nmoperad
                                    " " @ craplgp.flgenvio
                                    WITH FRAME f_valores.
                                    
              DOWN STREAM str_1 WITH FRAME f_valores.
         END.
        
END.

DOWN 2 STREAM str_1 WITH FRAME f_valores.
          
/* total geral  */
DISPLAY STREAM str_1   " " @ tel_hrtransa
                       " " @ craplgp.cddpagto 
                       " " @ craplgp.mmaacomp  
                       " " @ craplgp.cdidenti
                       " " @ craplgp.vlrouent
                       " " @ craplgp.vlrdinss 
                       rel_vltotpag_tt    @ craplgp.vlrtotal
                       " " @ craplgp.nrautdoc 
                       "    Tot.Geral"  @ craplgp.vlrjuros
                       " " @ aux_nmoperad
                       " " @ craplgp.flgenvio
                       WITH FRAME f_valores.
                       
DOWN STREAM str_1 WITH FRAME f_valores.

DISPLAY STREAM str_1 " ".
               
OUTPUT STREAM str_1 CLOSE.

ASSIGN glb_nrcopias = 1
       glb_nmformul = "132col" 
       glb_nmarqimp = aux_nmarqimp.
       
       
RUN fontes/imprim.p.
         
RUN fontes/fimprg.p.                
                
/*...........................................................................*/
