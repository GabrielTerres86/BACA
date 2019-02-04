-- Create table
CREATE TABLE CECRED.TBCRD_DOMINIO_CAMPO
(
  nmdominio VARCHAR2(30) NOT NULL,
  cddominio VARCHAR2(10) NOT NULL,
  dscodigo  VARCHAR2(100) NOT NULL,
  inativo   NUMBER(1) DEFAULT 0
);

-- Add comments to the table 
COMMENT ON TABLE CECRED.TBCRD_DOMINIO_CAMPO
  IS 'Tabela de dominios do modulo de cartões';
  
COMMENT ON COLUMN CECRED.TBCRD_DOMINIO_CAMPO.nmdominio
  IS 'Nome do campo dominio';
  
COMMENT ON COLUMN CECRED.TBCRD_DOMINIO_CAMPO.cddominio
  IS 'Codigo do dominio';
  
COMMENT ON COLUMN CECRED.TBCRD_DOMINIO_CAMPO.dscodigo
  IS 'Descricao do codigo dominio';
  
COMMENT ON COLUMN CECRED.TBCRD_DOMINIO.inativo
  IS 'Indicador de ativo e inativo do registro';
  
-- Create/Recreate primary, unique and foreign key constraints 
ALTER TABLE CECRED.TBCRD_DOMINIO_CAMPO
  ADD CONSTRAINTS TBCRD_DOMINIO_CAMPO_PK PRIMARY KEY (NMDOMINIO, CDDOMINIO)
  USING INDEX;
  
 
