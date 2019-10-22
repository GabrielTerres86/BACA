
-- Inicio -- Renda Comprovada
ALTER TABLE crapttl
ADD (inrendacomprovada NUMBER(2) DEFAULT 0);

COMMENT ON COLUMN crapttl.inrendacomprovada
IS 'Indicativo de renda comprovada. 0 - Nao comprovada; 1 - Comprovada';

ALTER TABLE tbcadast_pessoa_renda
ADD (inrendacomprovada NUMBER(2) DEFAULT 0);

COMMENT ON COLUMN tbcadast_pessoa_renda.inrendacomprovada
IS 'Indicativo de renda comprovada. 0 - Nao comprovada; 1 - Comprovada';

-- Fim -- Renda Comprovada

-- Inicio -- Referencia Contato
ALTER TABLE crapttl
ADD (tppreferenciacontato VARCHAR2(10) NULL);

COMMENT ON COLUMN crapttl.tppreferenciacontato
IS 'Preferencia de contato (Dominio:TBCADAST_DOMINIO_CAMPO)';

ALTER TABLE tbcadast_pessoa_renda
ADD (tppreferenciacontato VARCHAR2(10) NULL);

COMMENT ON COLUMN tbcadast_pessoa_renda.tppreferenciacontato
IS 'Preferencia de contato (Dominio:TBCADAST_DOMINIO_CAMPO)';
-- Fim -- Referencia Contato

-- Inicio -- PCD
ALTER TABLE crapttl
ADD (tppcd VARCHAR2(10) NULL);

COMMENT ON COLUMN crapttl.tppcd
IS 'Tipo de PCD (Dominio:TBCADAST_DOMINIO_CAMPO)';

ALTER TABLE tbcadast_pessoa_renda
ADD (tppcd VARCHAR2(10) NULL);

COMMENT ON COLUMN tbcadast_pessoa_renda.tppcd
IS 'Tipo de PCD (Dominio:TBCADAST_DOMINIO_CAMPO)';
-- Fim -- PCD

-- Inicio -- Tipo de Necessidade
ALTER TABLE crapttl
ADD (tpnecessidadepcd VARCHAR2(10) NULL);

COMMENT ON COLUMN crapttl.tpnecessidadepcd
IS 'Tipo de necessidade de PCD (Dominio:TBCADAST_DOMINIO_CAMPO)';

ALTER TABLE tbcadast_pessoa_renda
ADD (tpnecessidadepcd VARCHAR2(10) NULL);

COMMENT ON COLUMN tbcadast_pessoa_renda.tpnecessidadepcd
IS 'Tipo de necessidade de PCD (Dominio:TBCADAST_DOMINIO_CAMPO)';
-- Fim -- Tipo de Necessidade
