/* Ajuste controles do Debitador após segunda parada, envolvendo pc_crps642_priori. 
Neste segundo contorno foi removido da lista da 3a execução os programas que já haviam rodado, e foi ajustado o controle dos programas
subsequentes ao pc_crps509 haja visto que ainda não tinham conseguido rodar na 3a execução na Viacredi */

DELETE FROM tbgen_debitador_horario_proc
WHERE idhora_processamento = 3
AND cdprocesso IN ('PC_CRPS785', 'PC_CRPS782', 'PC_CRPS750', 'PC_CRPS724', 'EMPR0025.PC_DEBITAR_IMOBILIARIO',
'TELA_LAUTOM.PC_EFETIVA_LCTO_PENDENTE_JOB', 'PC_CRPS735', 'PC_CRPS674', 'PC_CRPS663', 'PC_CRPS509_PRIORI', 'PC_CRPS509');

COMMIT;


UPDATE crapprm
SET dsvlrprm = '24/12/2021#2'
WHERE cdcooper = 1 AND dsvlrprm = '24/12/2021#3';

COMMIT;
