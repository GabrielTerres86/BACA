/* .............................................................................

   Programa: Fontes/novatela.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Setembro/91.                        Ultima atualizacao: 06/12/2016

   Dados referentes ao programa:

   Frequencia: Sempre que chamado por outros programas (ON-LINE).
   Objetivo  : Processar o desvio interativo de telas.

   Alteracoes: 14/02/2000 - Alterado para tratar glb_nmrotina (Edson).
               11/03/2005 - Recalcular data tela qdo glb_inproces >=3.
                            (Chamada prog. verdata.p)(Mirtes).
                            
               13/03/2006 - Incluida chamada ao programa 'inicia_help.p' para o
                            controle de mensagens para uma nova versao da AJUDA
                            da tela (Evandro).
                            
               23/08/2006 - Alterado para limpar a variavel glb_nmrotina para
                            nao ficar "sujeira" de outra tela (Evandro).
                            
               12/09/2006 - Colocar NO na variavel glb_opvihelp (Evandro).
               
               04/12/2006 - Criar ponto de fuga para o sistema operacional
                            para o SUPER-USUARIO (Edson).
                            
               20/05/2009 - Alteracao CDOPERAD (Kbase).
               
               06/12/2016 - Alterado campo dsdepart para cddepart.
                            PRJ341 - BANCENJUD (Odirlei-AMcom)
                            
............................................................................. */

{ includes/var_online.i }

DEF        VAR aux_contador AS INT     INIT 1                        NO-UNDO.
DEF        VAR aux_stimeout AS INT                                   NO-UNDO.
DEF        VAR aux_flgdesco AS LOGICAL INIT FALSE                    NO-UNDO.

FORM SPACE(1) glb_nmdatela  HELP "Entre com o nome da tela desejada!"
     WITH ROW  1 COLUMN 16 OVERLAY NO-LABEL WIDTH 10 FRAME f_nmdatela.

ASSIGN glb_nmtelant = glb_nmdatela
       glb_nmdatela = ""
       glb_nmrotina = "".
       
{ includes/gg0000.i } 
/* Se ja estava conectado, nao desconecta */
IF   CONNECTED("bdgener")   THEN
     aux_flgdesco = FALSE.
ELSE
     aux_flgdesco = TRUE.

IF  f_conectagener() THEN
    DO:
       /* Verifica se o usuario viu a versao da AJUDA para inclui-lo na lista */
       RUN fontes/inicia_help.p (FALSE).

       IF   aux_flgdesco   THEN
            RUN p_desconectagener.
    END.


DO WHILE TRUE:

   RUN fontes/verdata.p.

   UPDATE glb_nmdatela AUTO-RETURN WITH FRAME f_nmdatela

   EDITING:

      aux_stimeout = 0.

      DO WHILE TRUE:

         READKEY PAUSE 1.

         IF   LASTKEY = -1   THEN
              DO:
                  aux_stimeout = aux_stimeout + 1.

                  IF   aux_stimeout > glb_stimeout   THEN
                       QUIT.

                  NEXT.
              END.

         LEAVE.

      END.  /*  Fim do DO WHILE TRUE  */

      IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN  /*F4 OU FIM*/
           DO:
               IF   aux_contador = 1   THEN
                    ASSIGN glb_nmdatela = glb_nmtelant
                           aux_contador = 2.
               ELSE
                    ASSIGN glb_nmdatela = ""
                           aux_contador = 1.

               DISPLAY glb_nmdatela WITH FRAME f_nmdatela.
               NEXT.
           END.

      APPLY LASTKEY.

      IF   GO-PENDING   THEN
           LEAVE.

   END.  /*  Fim do EDITING  */

   ASSIGN glb_nmdatela = CAPS(glb_nmdatela)
          glb_nmrotina = ""
          glb_opvihelp = NO.

   IF   glb_nmdatela = "GOHPUX"  AND   
        glb_cddepart = 20        THEN /* TI */
        DO:
            UNIX.
        END.
   
   RETURN.

END.  /*  Fim do DO WHILE TRUE  */
/* .......................................................................... */
