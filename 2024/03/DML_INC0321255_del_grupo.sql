BEGIN
  DELETE gestaoderisco.tbrisco_grupo_economico_integrante g
   WHERE g.cdcooper = 1
     AND g.NRDCONTA = 10736174
     AND g.cdgrupo_economico = 131188;
  COMMIT;   
END;