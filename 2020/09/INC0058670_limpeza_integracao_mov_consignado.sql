BEGIN
  update tbepr_consig_movimento_tmp set instatusproces = 'P' where dtmovimento <= to_date('31/03/2020','DD/MM/YYYY') and instatusproces is null;
  commit;
END;
