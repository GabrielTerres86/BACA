/* ............................................................................

   Programa: Fontes/movgps_r.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Diego/Mirtes
   Data    : Julho/2005                     Ultima alteracao: 06/10/2016
   
   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Gerar o relatorio de Movimentos Guias Previdencia

   Alteracoes:  30/08/2005 - Incluidos campos competencia e cod. pagto(Mirtes)
   
                08/09/2005 - Acrescentado campo referente Hora (Diego).
                
                07/10/2005 - Incluido Relatorio para rel_tipo_relatorio = 2
                             (Diego).
                
               31/01/2006 - Unificacao dos Bancos - SQLWorks - Luciane.

               28/02/2008 - Incluido campo "tpcontri" na TEMP-TABLE crawlgp e
                            tratamento para BB e do BANCOOB (Evandro).

               15/09/2008 - Incluir logo apos o cabecalho a data de referencia
                            do relatorio (Gabriel).
                         -  Alterado para obter informacoes do codigo de
                            pagamento no relatorio, da tabela craplgp;
                         -  Incluido cddpagto nos finds da craplgp (Elton).
                         
               04/11/2008 - bloqueia tecla F4 (martin).
               
               21/01/2009 - Substituido as variaveis e forms pela include
                            "var_movgps_r.i" (Elton).          
               
               05/09/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).             
                            
               29/05/2014 - Incluida a clausula craplgp.idsicred = 0 no
                            relatorio tipo 1 (Carlos)
                            
               02/06/2014 - Concatena o numero do servidor no endereco do
                            terminal (Tiago-RKAM).

               06/10/2016 - SD 489677 - Inclusao do flgativo na CRAPLGP
                            (Guilherme/SUPERO)
............................................................................ */

DEF     STREAM str_1. /* relatorio */

{ includes/var_online.i }
{ includes/var_movgps_r.i }
                                      
                   
DEF     INPUT PARAM     rel_dtmvtolt AS DATE   FORMAT "99/99/9999"   NO-UNDO.
DEF     INPUT PARAM     rel_cdagenci AS INT    FORMAT "zz9"          NO-UNDO.
DEF     INPUT PARAM     rel_nrdcaixa AS INT    FORMAT "zz9"          NO-UNDO.
DEF     INPUT PARAM     rel_tipo_relatorio AS INT                    NO-UNDO.
DEF     INPUT PARAM     par_flgenvio AS LOGICAL                      NO-UNDO.
DEF     INPUT PARAM     par_flgenvi2 AS LOGICAL                      NO-UNDO.
DEF     INPUT PARAM     TABLE FOR  crawlgp.


FORM SKIP(2)
     "GUIAS DA PREVIDENCIA -" /* AT 23*/
     crapban.nmresbcc
     SPACE (2)
     "REFERENTE : "
     rel_dtmvtolt
     SKIP(2)
     WITH DOWN NO-BOX NO-LABELS WIDTH 132 FRAME f_titulo_guias.
     
     
FORM SKIP(1)
     "ATENCAO!   Ligue a impressora e posicione o papel!" AT 3
     SKIP(1)
     tel_dsimprim AT 14
     tel_dscancel AT 29
     SKIP(1)
     WITH ROW 14 COLUMN 14 OVERLAY NO-LABELS WIDTH 56
          TITLE glb_nmformul FRAME f_atencao.

    
/* Bloqueia tecla F4 */
ON "f4" ANYWHERE DO:
    RETURN NO-APPLY.
END.


DISPLAY tel_dsimprim tel_dscancel WITH FRAME f_atencao.
CHOOSE FIELD tel_dsimprim tel_dscancel WITH FRAME f_atencao.

IF   FRAME-VALUE <> tel_dsimprim   THEN
     DO:
         HIDE FRAME f_atencao NO-PAUSE.
         RETURN.
     END.

FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.

IF   NOT AVAILABLE crapcop THEN
     DO:
         glb_cdcritic = 651.
         RUN fontes/critic.p.
         MESSAGE glb_dscritic.
         RETURN.
     END.
 
ASSIGN glb_cdcritic    = 0
       glb_nrdevias    = 1
       glb_cdempres    = 11
       glb_cdrelato[1] = 427. 

INPUT THROUGH basename `tty` NO-ECHO.
SET aux_nmendter WITH FRAME f_terminal.
INPUT CLOSE.

aux_nmendter = substr(glb_hostname,length(glb_hostname) - 1) +
                      aux_nmendter.

UNIX SILENT VALUE("rm rl/" + aux_nmendter + "* 2> /dev/null").
ASSIGN aux_nmarqimp = "rl/" + aux_nmendter + STRING(TIME) + ".ex".

ASSIGN aux_cdagefim = IF   rel_cdagenci = 0   THEN    9999
                      ELSE rel_cdagenci.
ASSIGN aux_nrdcaixa = IF   rel_nrdcaixa = 0   THEN 999
                      ELSE rel_nrdcaixa.
ASSIGN rel_vltotpag_tt = 0.

OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGED PAGE-SIZE 84.

IF  rel_tipo_relatorio = 1 THEN
    DO:   /* Relatorio Normal */

        { includes/cabrel132_1.i }

        VIEW STREAM str_1 FRAME f_cabrel132_1.
        
        IF   crapcop.cdcrdarr = 0   THEN
             FIND crapban WHERE crapban.cdbccxlt = 1 NO-LOCK NO-ERROR.
        ELSE
             FIND crapban WHERE crapban.cdbccxlt = 756 NO-LOCK NO-ERROR.
        
        DISPLAY STREAM str_1 crapban.nmresbcc 
                             rel_dtmvtolt
                             WITH FRAME f_titulo_guias.
                                                                   
        FOR EACH craplgp WHERE  craplgp.cdcooper  = glb_cdcooper      AND
                                craplgp.dtmvtolt  = rel_dtmvtolt      AND 
                                craplgp.cdagenci >= rel_cdagenci      AND
                                craplgp.cdagenci <= aux_cdagefim      AND
                                craplgp.nrdcaixa >= rel_nrdcaixa      AND
                                craplgp.nrdcaixa <= aux_nrdcaixa      AND 
                                craplgp.idsicred  = 0                 AND
                               (craplgp.flgenvio  = par_flgenvio      OR      
                                craplgp.flgenvio  = par_flgenvi2)
                            AND craplgp.flgativo  = YES               NO-LOCK,
                          FIRST crapope
                          WHERE crapope.cdcooper        = glb_cdcooper
                            AND UPPER(crapope.cdoperad) = UPPER(craplgp.cdopecxa)   NO-LOCK
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
                 
            DISPLAY STREAM str_1 
                           tel_hrtransa
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
                     
                     DISPLAY STREAM str_1 
                                    " " @ tel_hrtransa
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
                
                     DISPLAY STREAM str_1 
                                    " " @ tel_hrtransa
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
        DISPLAY STREAM str_1 
                       " " @ tel_hrtransa
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
    END.
ELSE
    DO:
        { includes/cabrel080_1.i }

        VIEW STREAM str_1 FRAME f_cabrel080_1.
        
        IF   crapcop.cdcrdarr = 0   THEN
             FIND crapban WHERE crapban.cdbccxlt = 1 NO-LOCK NO-ERROR.
        ELSE
             FIND crapban WHERE crapban.cdbccxlt = 756 NO-LOCK NO-ERROR.
        
        DISPLAY STREAM str_1 crapban.nmresbcc 
                             rel_dtmvtolt
                             WITH FRAME f_titulo_guias.

        FOR EACH crawlgp NO-LOCK,
            FIRST craplgp WHERE
                  craplgp.cdcooper = crapcop.cdcooper AND
                  craplgp.dtmvtolt = rel_dtmvtolt     AND
                  craplgp.cdagenci = crawlgp.cdagenci AND
                  craplgp.cdbccxlt = crawlgp.cdbccxlt AND
                  craplgp.nrdolote = crawlgp.nrdolote AND
                  craplgp.cdidenti = crawlgp.cdidenti AND
                  craplgp.mmaacomp = crawlgp.mmaacomp AND   
                  craplgp.cddpagto = crawlgp.cddpagto AND    
                  craplgp.vlrtotal = crawlgp.vlrtotal NO-LOCK, 
                          FIRST crapope WHERE 
                                crapope.cdcooper = glb_cdcooper     AND
                                crapope.cdoperad = craplgp.cdopecxa NO-LOCK
                                BREAK BY craplgp.cdagenci:

            ASSIGN rel_contagui = rel_contagui + 1
                   rel_contavlr = rel_contavlr + craplgp.vlrtotal.

            IF   LAST-OF(craplgp.cdagenci)  THEN
                 DO:
                     DISPLAY STREAM str_1 craplgp.cdagenci  rel_contagui
                                    rel_contavlr WITH FRAME f_guias.
                                                  
                     DOWN STREAM str_1 WITH FRAME f_guias.
                     
                     ASSIGN rel_totguias = rel_totguias + rel_contagui
                            rel_totalvlr = rel_totalvlr + rel_contavlr.        
                                         
                     ASSIGN rel_contagui = 0
                            rel_contavlr = 0.
                 END.
            
        END.
         
        DISPLAY STREAM str_1 rel_totguias rel_totalvlr 
                WITH FRAME f_geral_guias. 
    END.
       
OUTPUT STREAM str_1 CLOSE.

ASSIGN glb_nrdevias = 1
       glb_nmformul = IF  rel_tipo_relatorio = 2   THEN 
                          "80col"
                      ELSE
                          "132col" 
       par_flgrodar = TRUE.

VIEW FRAME f_aguarde.
PAUSE 3 NO-MESSAGE.
HIDE FRAME f_aguarde NO-PAUSE.

FIND FIRST crapass WHERE crapass.cdcooper = glb_cdcooper  NO-LOCK NO-ERROR.

{   includes/impressao.i }
/*...........................................................................*/
