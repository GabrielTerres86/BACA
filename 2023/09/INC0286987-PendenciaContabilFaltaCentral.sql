BEGIN
  
  UPDATE CECRED.tbfin_recursos_movimento fin
     SET inpessoa_creditada = 1
       , dtdevolucao_ted    = to_date('26/06/2023','DD/MM/RRRR')
       , dsdevted_descricao = 'Conciliacao ajustada por script'
       , indevted_motivo    = 1
   WHERE dtmvtolt = to_date('23/06/2023','DD/MM/RRRR')
     AND cdhistor = 2622
     AND vllanmto = 2177.35
     AND cdcooper = 3
     AND nrdconta = 10000003;
     
  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    raise_application_error(-20000,'Erro ao atualizar TBFIN_RECURSOS_MOVIMENTO:'||SQLERRM);
END;
