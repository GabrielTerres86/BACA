ALTER TABLE cecred.crapage ADD TPUNIATE NUMBER(5) DEFAULT 0;
COMMENT ON COLUMN crapage.TPUNIATE IS 'Tipo de Unidade de Atendimento:0-Posto de Atendimento, 1-Posto de Relacionamento, 2-Sala de Negocio';
