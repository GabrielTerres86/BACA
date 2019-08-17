-- Atualizar o nome de um cooperado já demitido que havia sido alterado para o nome da sua esposa.
UPDATE tbcadast_pessoa b
  SET b.nmpessoa = 'ALIRIO WOLF'
where b.nrcpfcgc = 29272483972;

COMMIT;

