rem PL/SQL Developer Test Script

set feedback off
set autoprint off

rem Execute PL/SQL Block
-- Created on 13/01/2020 by F0032615 
DECLARE
   -- Local variables here
   i INTEGER;
BEGIN
   --Elimina JOB Horarios Natal
   BEGIN
      sys.dbms_scheduler.drop_job(job_name => 'CECRED.JBPRM_ALTERA_HORARIO');
   EXCEPTION
      WHEN OTHERS THEN
         NULL;
   END;

   --Elimina JOB CIP
   BEGIN
      sys.dbms_scheduler.drop_job(job_name => 'CECRED.JBPRM_ALTERA_HORAR_CIP');
   EXCEPTION
      WHEN OTHERS THEN
         NULL;
   END;

   --Elimina Procedures utilizada para aplicação de horarios de natal do Debitador Único
   BEGIN
      EXECUTE IMMEDIATE 'drop PROCEDURE cecred.pc_hora_debunic_nat';
   EXCEPTION
      WHEN OTHERS THEN
         NULL;
   END;

   --Elimina Procedures utilizada para aplicação de horarios de natal na Debitador Único (2)
   BEGIN
      EXECUTE IMMEDIATE 'drop PROCEDURE cecred.pc_hora_debunic_natal';
   EXCEPTION
      WHEN OTHERS THEN
         NULL;
   END;

   --Elimina Procedures utilizada para aplicação de horarios de natal na VIACREDI
   BEGIN
      EXECUTE IMMEDIATE 'drop PROCEDURE cecred.pc_prm_altera_horario';
   EXCEPTION
      WHEN OTHERS THEN
         NULL;
   END;

   --Elimina Procedures utilizada para aplicação de horarios de natal e ano novo para programas da CIP
   BEGIN
      EXECUTE IMMEDIATE 'drop PROCEDURE cecred.pc_prm_altera_hora_cip';
   EXCEPTION
      WHEN OTHERS THEN
         NULL;
   END;
END;
/
