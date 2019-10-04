-- Adicionar um novo campo
ALTER TABLE GNCONVE  ADD  INORIGEM_INCLUSAO NUMBER(2);
-- Adicionar comentario do campo
COMMENT ON COLUMN GNCONVE.INORIGEM_INCLUSAO IS 'Indica a Origem da Inclusao (1-Cooperativa, 2-Empresa Conveniada, 3-Misto)';