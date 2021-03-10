DECLARE
  --
  vr_permitidos VARCHAR2(500);
  vr_bloqueados VARCHAR2(500);
  --
BEGIN
  -- Lista de caracteres permitidos
  vr_permitidos := 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789:;.,@?_ ' || chr(10);
  --
  FOR i in 1..length(vr_permitidos)
  LOOP
    dbms_output.put_line(i || ': ' || substr(vr_permitidos, i, 1) || chr(10));
    INSERT INTO cecred.tbcc_dominio_campo (
      nmdominio, 
      cddominio,
      dscodigo
    )
    VALUES (
      'MAPA_CARACTERES_VALIDOS',          -- nmdominio, 
      substr(vr_permitidos, i, 1),        -- cddominio
	    ' '
    );
  end loop;
  --
  -- Lista de caracteres que geram erro no xml
  vr_bloqueados := 'ÀÁÂÃÄÅàáâãäåÒÓÔÕÖØòóôõöøÈÉÊËèéêëÇçÌÍÎÏìíîïÙÚÛÜùúûüÿÑñ!#*-=+[]{}\°ºª^~¨´`';
  --
  FOR i in 1..length(vr_bloqueados)
  LOOP
    dbms_output.put_line(i || ': ' || substr(vr_bloqueados, i, 1) || chr(10));
    INSERT INTO cecred.tbcc_dominio_campo (
      nmdominio, 
      cddominio,
      dscodigo
    )
    VALUES (
      'MAPA_CARACTERES_BLOQUEADOS',        -- nmdominio, 
      substr(vr_bloqueados, i, 1),         -- cddominio
      'Carga inicial'
    );
  end loop;
  --
  COMMIT;
  --
  DBMS_OUTPUT.PUT_LINE('Sucesso na atualização.');
  --
EXCEPTION
  WHEN OTHERS THEN
    --
    ROLLBACK;
    --
    RAISE_APPLICATION_ERROR(-20000, 'Erro ao executar script: ' || SQLERRM);
    --
END;






