-- Atualizar o nome do CNPJ
UPDATE tbcadast_pessoa b
SET b.nmpessoa = 'ORSEGUPS SEGURANCA E VIGILANCIA LTDA'
where b.nrcpfcgc = 75092593001304;

COMMIT;
