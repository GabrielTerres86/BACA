BEGIN
  update credito.tbepr_contrato_imobiliario contr
      set contr.cdagenci = nvl(to_number(substr(contr.cdagenci,length(contr.cdagenci)-4,length(contr.cdagenci))),contr.cdagenci);
  commit;
  
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;    
END;