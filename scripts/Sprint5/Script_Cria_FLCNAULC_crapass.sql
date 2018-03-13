alter table CECRED.crapass
add column FLCNAULC number(1) not null default 1;
 
COMMENT ON COLUMN CECRED.CRAPASS.FLCNAULC IS 'Cancelamento Automático do Limite de Crédito (0-nao/1-sim)';
 
 
