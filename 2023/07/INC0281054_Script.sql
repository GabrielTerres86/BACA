DECLARE
BEGIN
  FOR rw IN (SELECT nrtitulo_npc
               FROM pagamento.tb_baixa_pcr_remessa bx
              WHERE bx.dhinclusao > to_date('30/06/2023', 'DD/MM/RRRR')
                AND bx.tpoperjd = 'CX'
                AND bx.NRTITULO_NPC > 0) LOOP
    UPDATE cecred.crapcob
       SET ininscip = 2
     WHERE nrdident = rw.nrtitulo_npc
       AND incobran = 0
       AND ininscip = 1;
  
  END LOOP;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    sistema.excecaointerna(pr_cdcooper => 3, pr_compleme => 'INC0281054');
    RAISE;
  
END;
