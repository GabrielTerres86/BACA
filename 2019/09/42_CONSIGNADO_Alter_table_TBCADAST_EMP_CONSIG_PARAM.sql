-- Add/modify columns 
alter table CECRED.TBCADAST_EMP_CONSIG_PARAM modify idemprconsigparam number;

-- Alter sequence
alter sequence CECRED.SEQ_TBCADAST_EMP_CONSIG_PARAM 
maxvalue 9999999999999999999999999999;