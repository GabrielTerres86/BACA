/* ..............................................................................

Procedure: efetua_reboot.p 
Objetivo : Efetuar reboot do TAA
Autor    : Evandro
Data     : Fevereiro 2011


Ultima alteração: 

............................................................................... */

{ includes/var_taa.i }

DEFINE VARIABLE aux_dssistem AS CHARACTER               NO-UNDO.
DEFINE VARIABLE buff         AS CHAR        EXTENT 6    NO-UNDO.
        
/* Fecha o sistema e reinicia a máquina */
RUN procedures/grava_log.p (INPUT "Reiniciando sistema...").

IF  xfs_painop_em_uso  THEN
    DO:
        buff = "".
        RUN procedures/atualiza_painop.p (INPUT buff).

        ASSIGN buff[2] = "        TAA SENDO REINICIADO"
               buff[4] = "             AGUARDE...".

        RUN procedures/atualiza_painop.p (INPUT buff).

        PAUSE 2 NO-MESSAGE.
    END.
ELSE
    DO:
        RUN mensagem.w (INPUT YES,
                        INPUT "    ATENÇÃO",
                        INPUT "",
                        INPUT "TAA sendo reiniciado.",
                        INPUT "",
                        INPUT "Aguarde...",
                        INPUT "").
        
        PAUSE 3 NO-MESSAGE.
        h_mensagem:HIDDEN = YES.
    END.


/* Derruba o script que controla o sistema aberto */
DOS SILENT VALUE("TASKKILL /F /IM wscript.exe").

/* Inicia o reboot */
DOS SILENT VALUE("SHUTDOWN -F -R -T 3").


/* Fecha o sistema */
QUIT.


/* ........................................................................... */

