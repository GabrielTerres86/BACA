/*.............................................................................

   Programa: fontes/zoom_tipo_taxas.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Margarete
   Data    : Outubro/2004                   Ultima alteracao: 23/08/2013

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Zoom das nacionalidades - le gntpnac.

   Alteracoes: 12/08/2008 - Unificacao dos bancos, incluido cdcooper na busca 
                            da tabela crapdtc(Guilherme).
                            
               23/08/2013 - Alteração clausula consultas crapdtc (Lucas).

............................................................................. */

DEF  /* SHARED */  VAR shr_tpaplica LIKE crapdtc.tpaplica                NO-UNDO.
DEF  /* SHARED  */ VAR shr_dsaplica LIKE crapdtc.dsaplica                NO-UNDO.
                 
DEF VAR aux_cdcooper AS INTE NO-UNDO.

aux_cdcooper = INT(OS-GETENV("CDCOOPER")).

IF   aux_cdcooper = ?   THEN
     aux_cdcooper = 0.

DEF QUERY  q_crapdtc FOR crapdtc. 
DEF BROWSE b_crapdtc QUERY q_crapdtc
      
      DISP tpaplica        FORMAT "z9"         COLUMN-LABEL "Tipo"
           dsaplica                            COLUMN-LABEL "Descricao"
           WITH 10 DOWN OVERLAY TITLE "TIPO APLICACAO".    
          
FORM b_crapdtc HELP "Use <TAB> para navegar" SKIP 
          WITH NO-BOX CENTERED OVERLAY ROW 8 FRAME f_alterar.          

/***************************************************/
                   
   ON RETURN OF b_crapdtc 
      DO:
          ASSIGN shr_tpaplica = crapdtc.tpaplica
                 shr_dsaplica = crapdtc.dsaplica.
                 
          CLOSE QUERY q_crapdtc.               
          APPLY "END-ERROR" TO b_crapdtc.
                 
      END.
                       
   OPEN QUERY q_crapdtc 
        FOR EACH crapdtc WHERE crapdtc.cdcooper = aux_cdcooper  AND
                              (crapdtc.tpaplrdc = 1             OR 
                               crapdtc.tpaplrdc = 2)            NO-LOCK.
                                                                
   SET b_crapdtc WITH FRAME f_alterar.
           
/****************************************************************************/
