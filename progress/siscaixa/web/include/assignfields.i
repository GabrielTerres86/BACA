/***************************************************************
** Include para guardar o valor da v_msg
***************************************************************/

DEFINE VARIABLE c_temp_mensagem AS CHARACTER  NO-UNDO.

ASSIGN c_temp_mensagem = v_msg.
RUN assignFields.
ASSIGN v_msg = c_temp_mensagem.
