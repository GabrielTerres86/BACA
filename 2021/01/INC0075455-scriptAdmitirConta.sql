-- INC0075455 - atribuição de grupos para contas criadas desde que a atribuição automática parou
declare
 
  pr_retxml xmltype;
  vr_cdcritic varchar2 (4000);
  vr_dscritic varchar2 (4000);

-- Busca as contas que não possuem grupos atribuidos
  CURSOR cr_coopdiver IS
    select a.cdcooper cdcooper,a.nrdconta nrdconta from crapass a where a.cdcooper in (1,9,13,14)  and a.dtdemiss is null and not exists
      (select 1 from tbevento_pessoa_grupos where cdcooper = a.cdcooper and nrcpfcgc = a.nrcpfcgc );
begin
  FOR rw_coopdiver in cr_coopdiver LOOP
    -- Chama a procedure que atribui os grupos
    cecred.AGRP0001.pc_admitir_conta(pr_cdcooper => rw_coopdiver.cdcooper,
                                    pr_nrdconta => rw_coopdiver.nrdconta,
                                    pr_retxml => pr_retxml,
                                    pr_cdcritic => vr_cdcritic,
                                    pr_dscritic => vr_dscritic);
  END LOOP;                                    
end;
/
--resultado esperado: inserir conta no tbevento_pessoa_grupos