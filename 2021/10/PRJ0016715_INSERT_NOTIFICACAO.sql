DECLARE
  CURSOR cr_crapcop IS
    SELECT cdcooper FROM crapcop WHERE flgativo = 1;
  vr_idinconsist_grp NUMBER;
  vr_emails          VARCHAR2(1000) := 'juliana.ottersbach@ailos.coop.br;beatriz.weege@ailos.coop.br;juliana@ailos.coop.br';
BEGIN
  dbms_output.put_line('SCRIPT INICIADO EM ' ||
                       to_char(SYSDATE, 'dd/mm/yyyy hh24:mi:ss'));

  INSERT INTO cecred.tbgen_inconsist_grp
    (idinconsist_grp
    ,nminconsist_grp
    ,tpconfig_email
    ,dsassunto_email
    ,tpperiodicidade_email)
  VALUES
    ((SELECT MAX(idinconsist_grp) + 1 FROM cecred.tbgen_inconsist_grp)
    ,'Reativacao Prejuizo'
    ,1
    ,'Erro processar reativacao de prejuizo - Acordo'
    ,1
     )
  RETURNING idinconsist_grp INTO vr_idinconsist_grp;

  FOR cop IN cr_crapcop LOOP
    INSERT INTO cecred.tbgen_inconsist_email_grp
      (cdcooper
      ,idinconsist_grp
      ,dsendereco_email)
    VALUES
      (cop.cdcooper
      ,vr_idinconsist_grp
      ,vr_emails);
  END LOOP;

  COMMIT;

  dbms_output.put_line('SCRIPT FINALIZADO COM SUCESSO EM ' ||
                       to_char(SYSDATE, 'dd/mm/yyyy hh24:mi:ss'));
EXCEPTION
  WHEN OTHERS THEN
    dbms_output.put_line('ERRO NAO TRATADO NA EXECUCAO DO SCRIPT EXCECAO: ' ||
                         substr(SQLERRM, 1, 255));
    ROLLBACK;
    raise_application_error(-20002,
                            'ERRO NAO TRATADO NA EXECUCAO DO SCRIPT. EXCECAO: ' ||
                            substr(SQLERRM, 1, 255));
END;
