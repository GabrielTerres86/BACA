/* .............................................................................

   Programa: Fontes/criticas_proces.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Margarete
   Data    : Junho/2004.                     Ultima atualizacao: 01/02/2017

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Criticas que impedem a solicitacao do PROCESSO.

   Alteracoes: 10/09/2004 - Corrigir critica da sol026 (Margarete).

               14/09/2004 - Melhorar critica de protocolos de custodia 
                            (Deborah).

               29/10/2004 - Chamada para o programa gera_critica_proces, para
                            permitir solicitacao automatica(Mirtes)

               10/10/2007 - Definir TEMP-TABLE w_criticas como parametro de
                            saida (David).
                            
               30/05/2014 - Concatena o numero do servidor no endereco do
                            terminal (Tiago-RKAM).             
               
               11/06/2014 - Alterado para chamar a stored procedure do oracle, 
                            para validar nova rotina oracle (Odirlei-AMcom).
                            
               25/08/2014 - Removido chamada da rotina oracle temporaria 
                            para validação(Odirlei-AMcom).             
                            
               01/02/2017 - Ajustes para consultar dados da tela PROCES de todas as cooperativas
                            (Lucas Ranghetti #491624)
............................................................................*/

DEF VAR aux_nmarq_parm AS CHAR.

DEF VAR vr_dsdirmic    AS CHAR NO-UNDO.

{ includes/var_online.i }

{ includes/var_proces.i }

MESSAGE "Aguarde...".

INPUT THROUGH basename `tty` NO-ECHO.

SET aux_nmendter WITH FRAME f_terminal.

INPUT CLOSE.

ASSIGN aux_nmendter = substr(glb_hostname,length(glb_hostname) - 1) +
                      aux_nmendter. 

UNIX SILENT VALUE("rm rl/" + aux_nmendter + "* 2> /dev/null").

ASSIGN aux_nmarqimp   = "rl/" + aux_nmendter + STRING(TIME) + ".ex".

ASSIGN aux_nmarq_parm = aux_nmarqimp.

RUN fontes/gera_criticas_proces.p (INPUT aux_nmarq_parm,
                                   OUTPUT aux_nrsequen,
                                   OUTPUT TABLE w_criticas).
                                                                                     
IF   glb_nmdatela = "PROCES"   THEN
     DO:       
         IF  choice = 1 OR 
             choice = 4 OR  
             (choice = 2 AND aux_nrsequen <> 0)   THEN
              DO:
                  PAUSE (0).
            
                  VIEW FRAME f_moldura.
               
                  PAUSE(0).
               
                  RUN fontes/visualiza_criticas_proces.p.
         END.
     END.                                    
/* .......................................................................... */
