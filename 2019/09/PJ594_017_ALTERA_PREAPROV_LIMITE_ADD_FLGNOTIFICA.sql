-- Adicionar nova coluna na tabela de limite pre aprovado para notificacao

ALTER TABLE tbcrd_preaprov_limite 
ADD (flgnotifica NUMBER(2) DEFAULT 0);

COMMENT ON COLUMN tbcrd_preaprov_limite.flgnotifica IS
'Flag para informar se o cooperado foi informado do limite pre aprovado. 0 = nao; 1 = sim'; 