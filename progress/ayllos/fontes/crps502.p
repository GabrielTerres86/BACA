/* ..........................................................................

   Programa: Fontes/crps502.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Evandro
   Data    : Janeiro/2008                     Ultima atualizacao: 12/09/2011

   Dados referentes ao programa:

   Frequencia: Diario (Batch).
   Objetivo  : Atende a solicitacao 86.
               Envio de e-mail com os formularios de segunda via de cartao e
               senha ao INSS - BANCOOB.

   Alteracoes: 26/02/2008 - Enviar o e-mail somente caso haja solicitacoes de
                            segunda via cartao/senha (Evandro).
                            
               12/09/2011 - Alterado o email de inss@bancoob.com.br para 
                            francieli@cecred.coop.br (Henrique).
                            
............................................................................. */

{ includes/var_batch.i "NEW" }

DEF     VAR h-b1crap85      AS HANDLE                               NO-UNDO.
DEF     VAR h-b1wgen0011    AS HANDLE                               NO-UNDO.
DEF     VAR aux_contador    AS INT                                  NO-UNDO.


glb_cdprogra = "crps502".

RUN fontes/iniprg.p.

IF   glb_cdcritic > 0   THEN
     QUIT.

/* Limpa os arquivos gerados anteriormente */
UNIX SILENT VALUE("rm arq/crps502*.txt 2> /dev/null").

RUN siscaixa/web/dbo/b1crap85.p PERSISTENT SET h-b1crap85.

IF   NOT VALID-HANDLE(h-b1crap85)   THEN
     DO:
         UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                           glb_cdprogra + "' --> '" +
                           "Nao foi possivel instanciar a BO b1crap85!" +
                           " >> log/proc_batch.log").
         QUIT.
     END.

FOR EACH crapsci WHERE crapsci.cdcooper = glb_cdcooper   AND
                       crapsci.dtdenvio = ?
                       EXCLUSIVE-LOCK:
                       
    aux_contador = aux_contador + 1.
    
    RUN segunda_via IN h-b1crap85(INPUT crapsci.cdcooper,
                                  INPUT crapsci.cdagenci,
                                  INPUT crapsci.dtmvtolt,
                                  INPUT crapsci.nrrecben,
                                  INPUT crapsci.nrbenefi,
                                  INPUT crapsci.tpsolici,
                                  INPUT crapsci.cdmotsol,
                                  INPUT "arq/crps502_" +
                                        STRING(aux_contador) + 
                                        ".txt").
     
    IF   RETURN-VALUE = "NOK"   THEN
         DO:
             UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                               glb_cdprogra + "' --> '" +
                               "Nao foi possivel gerar formulario para " +
                               "NIT: " + STRING(crapsci.nrrecben) + " - " +
                               "NB: " + STRING(crapsci.nrbenefi) +
                               " >> log/proc_batch.log").
             NEXT.
         END.

    ASSIGN crapsci.dtdenvio = glb_dtmvtolt.
END.

DELETE PROCEDURE h-b1crap85.

IF   aux_contador > 0   THEN
     DO:
         /* Junta os arquivos gerados num unico arquivo */
         UNIX SILENT VALUE("cat arq/crps502_*.txt > " +
                           "arq/crps502.txt 2> /dev/null").

         /* Remove os arquivos temporarios */
         UNIX SILENT VALUE("rm arq/crps502_*.txt 2> /dev/null").

         /* Converte e envia o arquivo via e-mail para o INSS */
         RUN sistema/generico/procedures/b1wgen0011.p
             PERSISTENT SET h-b1wgen0011.
                      
         RUN converte_arquivo IN h-b1wgen0011 (INPUT glb_cdcooper,
                                               INPUT "arq/crps502.txt",
                                               INPUT "crps502.txt").
                     
         RUN enviar_email IN h-b1wgen0011 (INPUT glb_cdcooper,
                                           INPUT glb_cdprogra,
                                           INPUT "francieli@cecred.coop.br",
                                           INPUT "INSS - 2a. VIA DE " +
                                                 "CARTOES/SENHAS",
                                           INPUT "crps502.txt",
                                           INPUT FALSE).

         DELETE PROCEDURE h-b1wgen0011.

         /* Move o arquivo para o salvar */
         UNIX SILENT VALUE("mv arq/crps502.txt salvar 2> /dev/null").
     END.

RUN fontes/fimprg.p.

