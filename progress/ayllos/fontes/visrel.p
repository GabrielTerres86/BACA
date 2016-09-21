/* .............................................................................

   Programa: fontes/visrel.p
   Sistema : Conta-Corrente - Cooperativa 
   Sigla   : CRED
   Autor   : Junior
   Data    : 17/10/2001.                        Ultima atualizacao: 02/06/2014

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar os relatorios da tela IMPREL em video.
   
   Alteracao : 10/09/2003 - No final do arquivo, foi retirado o VIEW FRAME para
                            f_moldura e f_cmd (Fernando).
                            
               21/07/2008 - Aumento no tamanho da variavel edi_relatorio
                            (Diego).
                
               07/10/2009 - Aumentado size do frame para 78 (Gabriel).
               
               13/05/2010 - Alterar help da visualizacao (Gabriel).
               
               21/10/2011 - Criar o arquivo temporário usando o ID da sessão
                            (Gabriel - DB1).
                            
               02/06/2014 - Concatena o numero do servidor no endereco do
                            terminal (Tiago-RKAM).
............................................................................. */

{ includes/var_online.i }

/* Variaveis para a opcao visualizar */

DEFINE INPUT PARAMETER rel_nmarqimp AS CHAR NO-UNDO.

DEF VAR rel_nmtmpimp    AS CHAR NO-UNDO.

DEF VAR edi_relatorio   AS CHAR VIEW-AS EDITOR SIZE 250  BY 15
                    /*  SCROLLBAR-VERTICAL */ PFCOLOR 0.     

DEF FRAME fra_relatorio
    edi_relatorio HELP "Pressione <F4> ou <END> para sair." 
    WITH CENTERED SIZE 78 BY 15 ROW 6 COLUMN 3 USE-TEXT NO-BOX NO-LABELS OVERLAY.

INPUT THROUGH basename `tty` NO-ECHO.
SET rel_nmtmpimp WITH FRAME f_terminal.
INPUT CLOSE.

rel_nmtmpimp = substr(glb_hostname,length(glb_hostname) - 1) +
                      rel_nmtmpimp.

ASSIGN rel_nmtmpimp = "rl/" + rel_nmtmpimp + STRING(TIME) + ".tmp".

DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                                                              
   ENABLE edi_relatorio WITH FRAME fra_relatorio.
   DISPLAY edi_relatorio WITH FRAME fra_relatorio.
   ASSIGN edi_relatorio:READ-ONLY IN FRAME fra_relatorio = YES.

   IF   SEARCH(rel_nmarqimp) = ?   THEN
        DO:
            glb_cdcritic = 182.
            RUN fontes/critic.p.
            BELL.
            HIDE MESSAGE NO-PAUSE.
            MESSAGE glb_dscritic rel_nmarqimp.
            glb_cdcritic = 0.
            RETURN.
        END.

   UNIX SILENT VALUE("tr -d \014 < " + rel_nmarqimp + " > " + rel_nmtmpimp).
   
   IF   edi_relatorio:INSERT-FILE(rel_nmtmpimp)   THEN
        DO:
            ASSIGN edi_relatorio:CURSOR-LINE IN FRAME fra_relatorio = 1.
            WAIT-FOR GO OF edi_relatorio IN FRAME fra_relatorio. 
        END.
   ELSE   
        DO:
            MESSAGE "Arquivo nao encontrado".
            LEAVE.
        END.
  
END.

ASSIGN edi_relatorio:SCREEN-VALUE = "".
CLEAR FRAME fra_relatorio ALL.
HIDE FRAME fra_relatorio NO-PAUSE.
UNIX SILENT VALUE("rm " + rel_nmtmpimp + " 2> /dev/null").
/* ...........................................................................*/
