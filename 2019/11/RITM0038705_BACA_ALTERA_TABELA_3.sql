-- Adequacao dos campos para nova tabela

-- Inicio -- Preferencia Contato
ALTER TABLE tbcadast_pessoa_juridica
ADD (tppreferenciacontato VARCHAR2(10) NULL);

COMMENT ON COLUMN tbcadast_pessoa_juridica.tppreferenciacontato
IS 'Preferencia de contato (Dominio:TBCADAST_DOMINIO_CAMPO)';

ALTER TABLE crapjur
ADD (tppreferenciacontato VARCHAR2(10) NULL);

COMMENT ON COLUMN crapjur.tppreferenciacontato 
IS 'Preferencia de contato (Dominio:TBCADAST_DOMINIO_CAMPO)';

-- Fim -- Preferencia Contato