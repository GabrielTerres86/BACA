/* .............................................................................

   Programa: Includes/acesso.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Setembro/91.                        Ultima atualizacao: 18/09/2014

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Processar a rotina que verifica as permissoes de acesso a tela.

   Alteracoes: 20/07/94 - Alterado para quando o sistema estiver em manutencao
                          somente permitir consultar os dados (Edson).

               05/08/96 - Alterado para nao verificar o acesso para
                          SUPER-USUARIO E PESSOAL DE DESENVOLVIMENTO (Edson).

               14/01/99 - Alterado para liberar a tela ATENDA p/o terceiro
                          turno (Deborah).

               05/04/1999 - Alterado para liberar a tela CADAST p/o terceiro
                            turno (Deborah).

               17/04/1999 - Alterado para liberar as telas CONTA, MANTAL e
                            MATRIC para o terceiro turno (Deborah).

               27/10/1999 - Alterado para liberar as telas "SECEXT, DESEXT e
                            NOTJUS" para o terceiro turno (Deborah).

               14/02/2000 - Alterado para tratar glb_nmrotina (Edson).

               09/08/2000 - Alterado para liberar a tela ESKECI (Deborah).
               
               29/09/2005 - Alterado para ler tbm codigo da cooperativa na
                            tabela crapace (Diego).
                            
               04/10/2005 - Alterado para NAO validar acesso quando o servidor
                            for o l1000 (Edson).
                            
               03/02/2006 - Unificacao dos Bancos - SQLWorks - Andre
               
               23/08/2006 - Alterado para nao limpar o nome da rotina quando o
                            usuario tem acesso, para poder acessar o F2 de cada
                            rotina (Evandro).
                            
               11/05/2009 - Alteracao CDOPERAD (Kbase).
               
               04/04/2013 - Adicionado verificacao por ambiente de acesso, 
                            campo crapace.idambace e craptel.idambtel. (Jorge)
                            
               18/09/2014 - Alteracao adicionado FIND FIRST na crapace 
                            Chamado: 191758 - (Jonathan - RKAM).                            
							
			   08/12/2016 - P341-Automatização BACENJUD - Realizar a validação 
			                do departamento pelo código do mesmo (Renato Darosci)
............................................................................. */

INPUT THROUGH hostname NO-ECHO.

SET glb_dscritic.

INPUT CLOSE.       
IF   glb_dscritic <> "l1000"   THEN
                  
IF   glb_cddepart <> 20 THEN  /* TI */
     DO:
         FIND FIRST crapace WHERE crapace.cdcooper = glb_cdcooper   AND
                                  crapace.nmdatela = glb_nmdatela   AND
                                  crapace.nmrotina = glb_nmrotina   AND
                                  crapace.cddopcao = glb_cddopcao   AND
                                  crapace.cdoperad = glb_cdoperad   AND 
                                  crapace.idambace = 1 /* 1 - Caracter 
                                                          2 - Web 
                                                          3 - Progrid */
                                  NO-LOCK NO-ERROR NO-WAIT.

         IF   NOT AVAILABLE crapace   THEN
              DO:
                  glb_cdcritic = 36.
                  RUN fontes/critic.p.
                  BELL.
                  MESSAGE glb_dscritic.
                  ASSIGN glb_cdcritic = 0
                         glb_nmrotina = "".
                  NEXT.
              END.

         FIND craptel WHERE craptel.cdcooper = glb_cdcooper       AND
                            craptel.nmdatela = crapace.nmdatela   AND
                            craptel.nmrotina = crapace.nmrotina   AND
                            (craptel.idambtel = 1 OR craptel.idambtel = 0)
                            /* 0 - Caracter  e Web, 1 - Caracter e 2 - Web */
                            NO-LOCK NO-ERROR.
                            
         IF   NOT AVAILABLE craptel   THEN
              NEXT.
              
         IF   NOT craptel.flgtelbl   THEN
              DO:
                  MESSAGE "Rotina BLOQUEADA no momento!".
                  NEXT.
              END.

         IF   SEARCH("arquivos/so_consulta") <> ?     AND
              glb_cddopcao                   <> "C"   THEN
              IF   glb_nmdatela <> "ATENDA" AND 
                   glb_nmdatela <> "CADAST" AND
                   glb_nmdatela <> "MANTAL" AND
                   glb_nmdatela <> "CONTA"  AND
                   glb_nmdatela <> "MATRIC" AND
                   glb_nmdatela <> "DESEXT" AND
                   glb_nmdatela <> "SECEXT" AND
                   glb_nmdatela <> "NOTJUS" AND
                   glb_nmdatela <> "AUTORI" AND
                   glb_nmdatela <> "ESKECI" THEN
                   DO:
                       glb_cdcritic = 399.
                       RUN fontes/critic.p.
                       BELL.
                       MESSAGE glb_dscritic.
                       glb_cdcritic = 0.
                       NEXT.
                   END.
              ELSE
                   RELEASE crapace.
         ELSE
              RELEASE crapace.
     END.

/* .......................................................................... */
 
