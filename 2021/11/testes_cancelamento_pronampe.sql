begin
  update credito.tbcred_pronampe_contrato p set p.dtcancelamento = to_timestamp(sysdate-1)
  WHERE p.cdcooper = 1 AND p.dtcancelamento IS NOT NULL and to_date(p.dtcancelamento, 'DD/MM/YYYY') = to_date('12/11/2021', 'DD/MM/YYYY');  
commit;
end;