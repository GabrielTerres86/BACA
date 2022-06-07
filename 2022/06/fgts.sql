begin
  UPDATE gncontr gnc
  SET gnc.qtdoctos = 0, 
      gnc.vldoctos = 0
  WHERE gnc.cdcooper = 3 
    AND gnc.dtmvtolt = to_date('06/06/2022','DD/MM/YYYY');           

commit;
end;