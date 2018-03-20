alter table CECRED.crapass
add column FLCNAULC number(1) not null default 1;
 
COMMENT ON COLUMN CECRED.CRAPASS.FLCNAULC IS 'Cancelamento Automatico do Limite de Credito (0-Nao/1-Sim)';
 
 
