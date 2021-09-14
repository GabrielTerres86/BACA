-- Created on 27/04/2021 by F0033123 
declare
  -- Local variables here
  vr_cdcooper crapcop.cdcooper%TYPE;

  CURSOR cr_operacoes(pr_cdcooper crapcop.cdcooper%TYPE) IS
    select distinct cdcooper,
                    nrdconta,
                    cdoperacao,
                    dtoperacao,
                    nrsequen,
                    total_estorno
      from (select ope.*,
                   (select count(1)
                      from craplcm lcm_est
                     where lcm_est.dtmvtolt = ope.dtoperacao
                       and lcm_est.nrdconta = ope.nrdconta
                       and lcm_est.cdhistor in (570, 857)
                       and lcm_est.nrdctabb = 0
                       and lcm_est.cdcooper = ope.cdcooper
                       and (case
                             when ope.cdoperacao = 18 then
                              90
                             when ope.cdoperacao = 19 then
                              91
                             else
                              99999999
                           END) = lcm_est.cdagenci) total_estorno
              FROM tbcc_operacoes_diarias ope, craplcm lcm
             WHERE lcm.dtmvtolt = ope.dtoperacao
               AND lcm.nrdconta = ope.nrdconta
               AND lcm.cdhistor in (570, 857)
               AND lcm.cdcooper = ope.cdcooper
               and ope.cdoperacao in (18, 19)
               AND ope.dtoperacao > to_date('31/12/2020','dd/mm/yyyy')
               AND ope.dtoperacao < to_date('01/01/2022','dd/mm/yyyy')
               AND ope.cdcooper = pr_cdcooper
               AND (CASE
                     when ope.cdoperacao = 18 then
                      90
                     when ope.cdoperacao = 19 then
                      91
                     else
                      99999999
                   END) = lcm.cdagenci)
     WHERE total_estorno > 0
     ORDER BY dtoperacao;

begin
  vr_cdcooper := 3;

  FOR rw_operacoes IN cr_operacoes(vr_cdcooper) LOOP
  
    IF rw_operacoes.nrsequen >= rw_operacoes.total_estorno THEN
      update tbcc_operacoes_diarias ope
         set ope.nrsequen = ope.nrsequen - rw_operacoes.total_estorno
       where ope.nrdconta = rw_operacoes.nrdconta
         and ope.cdcooper = rw_operacoes.cdcooper
         and ope.cdoperacao = rw_operacoes.cdoperacao
         and ope.dtoperacao = rw_operacoes.dtoperacao
         and ope.nrsequen = rw_operacoes.nrsequen;
    END IF;
  
  END LOOP;

  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Erro ao atualizar operações: ' || sqlerrm);
    ROLLBACK;
  
end;
