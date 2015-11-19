/* ..............................................................................

Procedure: verifica_reboot.p 
Objetivo : Verificar se houve reboot do TAA
Autor    : Evandro
Data     : Fevereiro 2011


Ultima alteração: 

............................................................................... */

DEFINE OUTPUT PARAMETER par_flgderro    AS LOGICAL      INIT NO     NO-UNDO.

DEFINE VARIABLE aux_dsdlinha            AS CHAR                     NO-UNDO.
DEFINE VARIABLE aux_dia_boot            AS INT                      NO-UNDO.
DEFINE VARIABLE aux_hrs_boot            AS INT                      NO-UNDO.
DEFINE VARIABLE aux_min_boot            AS INT                      NO-UNDO.


/* verifica UPTIME do windows */
INPUT THROUGH VALUE("systeminfo | find ~"Tempo de ativação do sistema~"").
IMPORT UNFORMATTED aux_dsdlinha.
INPUT CLOSE.

ASSIGN aux_dia_boot = INT(SUBSTRING(aux_dsdlinha,42,3))
       aux_hrs_boot = INT(SUBSTRING(aux_dsdlinha,53,2))
       aux_min_boot = INT(SUBSTRING(aux_dsdlinha,65,2)).


/* se subiu a maquina em ate 10 minutos, considera reboot OK */
IF  aux_dia_boot = 0   AND
    aux_hrs_boot = 0   AND
    aux_min_boot < 10  THEN
    DO:
        /* confirma o reboot ok ao servidor */
        RUN procedures/confirma_reboot.p (OUTPUT par_flgderro).

        RETURN RETURN-VALUE.
    END.
ELSE
    DO:
        par_flgderro = YES.
        RETURN "NOK".
    END.

/* ........................................................................... */

