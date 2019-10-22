-- Adequacao dos campos para nova tabela
ALTER TABLE tbcadast_pessoa_renda
DROP (tppreferenciacontato, tppcd, tpnecessidadepcd);

-- Inicio -- Referencia Contato
ALTER TABLE tbcadast_pessoa_fisica
ADD (tppreferenciacontato VARCHAR2(10) NULL);

COMMENT ON COLUMN tbcadast_pessoa_fisica.tppreferenciacontato
IS 'Preferencia de contato (Dominio:TBCADAST_DOMINIO_CAMPO)';
-- Fim -- Referencia Contato


-- Inicio -- PCD
ALTER TABLE tbcadast_pessoa_fisica
ADD (tppcd VARCHAR2(10) NULL);

COMMENT ON COLUMN tbcadast_pessoa_fisica.tppcd
IS 'Tipo de PCD (Dominio:TBCADAST_DOMINIO_CAMPO)';
-- Fim -- PCD

-- Inicio -- Tipo de Necessidade
ALTER TABLE tbcadast_pessoa_fisica
ADD (tpnecessidadepcd VARCHAR2(10) NULL);

COMMENT ON COLUMN tbcadast_pessoa_fisica.tpnecessidadepcd
IS 'Tipo de necessidade de PCD (Dominio:TBCADAST_DOMINIO_CAMPO)';
-- Fim -- Tipo de Necessidade
