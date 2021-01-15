-- Atualizar data de liberacao da renegociacao para corrigir exibicao em telas de efetivacao e botoes de historico
UPDATE tbepr_renegociacao SET dtlibera = '28/09/2020' WHERE cdcooper = 1 AND nrdconta = 10711481 AND nrctremp = 2979149;
COMMIT;
