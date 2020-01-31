BEGIN 
  DECLARE 
    vr_params  VARCHAR(1000) := '';
    vr_nvparam VARCHAR(100)  := ',pr_nrmxrene,pr_nrmxcore';
  BEGIN
    SELECT lstparam 
      INTO vr_params 
      FROM crapaca 
     WHERE nmdeacao = 'TAB089_ALTERAR';
    
    UPDATE crapaca
       SET lstparam = vr_params || vr_nvparam
     WHERE nmdeacao = 'TAB089_ALTERAR';

    COMMIT;
  END;
END;

