/*.............................................................................

   Programa: fontes/zoom_tipo_aplica.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Elton
   Data    : Maio/2007                            Ultima alteracao: 12/08/2008

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Zoom dos tipos de aplicacoes -  crapdtc.

   Alteracoes: 12/08/2008 - Unificacao dos bancos, incluido cdcooper na busca
                            da tabela crapttx(Guilherme).

............................................................................. */

DEF  INPUT   PARAM par_tptaxrdc AS INT                               NO-UNDO.

DEF  SHARED  VAR   shr_tptaxrdc LIKE crapttx.tptaxrdc                NO-UNDO.
DEF  SHARED  VAR   shr_cdperapl LIKE crapttx.cdperapl                NO-UNDO.
                 
DEF QUERY  q_crapttx FOR crapttx. 
DEF BROWSE b_crapttx QUERY q_crapttx
      
      DISP tptaxrdc        FORMAT "z9"         COLUMN-LABEL "Aplicacao"
           cdperapl                            COLUMN-LABEL "Periodo"
           WITH 4 DOWN OVERLAY TITLE "PERIODO APLICACAO".    
          
FORM b_crapttx HELP "Use <TAB> para navegar" SKIP 
          WITH NO-BOX CENTERED OVERLAY ROW 11 FRAME f_alterar.          
          
DEF VAR aux_cdcooper AS INTE NO-UNDO.

aux_cdcooper = INT(OS-GETENV("CDCOOPER")).

IF   aux_cdcooper = ?   THEN
     aux_cdcooper = 0.          

/***************************************************/
                   
   ON RETURN OF b_crapttx 
      DO:
          ASSIGN shr_tptaxrdc = crapttx.tptaxrdc
                 shr_cdperapl = crapttx.cdperapl.
                 
          CLOSE QUERY q_crapttx.               
          APPLY "END-ERROR" TO b_crapttx.
                 
      END.                                                      

  OPEN QUERY q_crapttx                            
       FOR EACH crapttx  WHERE  crapttx.cdcooper = aux_cdcooper AND
                                crapttx.tptaxrdc = par_tptaxrdc  NO-LOCK.
   
   UPDATE  b_crapttx WITH FRAME f_alterar.
           
/****************************************************************************/
               