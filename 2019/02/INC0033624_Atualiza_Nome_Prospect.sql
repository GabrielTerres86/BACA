-- Ajustar nome de prospect no CRM (Cadastro unificado). - Wagner - Sustentação.
-- INC0033624 
UPDATE tbcadast_pessoa a
    SET a.nmpessoa = 'METALCAVA FUNDICAO DE METAIS EIRELI'
  WHERE a.nrcpfcgc = 00899825000190;
  
COMMIT;

  