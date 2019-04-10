-- Add/modify columns
ALTER TABLE CECRED.TBCRD_APROVACAO_CARTAO ADD cdaprovador VARCHAR2(10);
-- Add comments to the columns
COMMENT ON COLUMN CECRED.TBCRD_APROVACAO_CARTAO.cdaprovador IS 'Codigo do operador supervisor.';