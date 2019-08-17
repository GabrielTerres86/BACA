declare 
  -- Local variables here
  i integer:=0;
  vr_dscritic varchar2(500);
  
begin

BEGIN
  insert into crapoco
  SELECT crapoco.cdcooper
      ,crapoco.cddbanco
      ,22 cdocorre
      ,crapoco.tpocorre
      ,'Titulo enviado ao cartorio' dsocorre
      ,crapoco.cdoperad
      ,trunc(sysdate) dtaltera
      ,crapoco.hrtransa
      ,crapoco.flgativo
      ,NULL progress_recid
    FROM crapoco
   WHERE crapoco.tpocorre = 2
     AND crapoco.cddbanco = 85
     AND crapoco.cdocorre = 2
   order by 1;
    EXCEPTION
      WHEN dup_val_on_index THEN
        NULL; --> Caso ja exista nao deve apresentar critica
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao inserir crapoco: '||SQLERRM;
        dbms_output.put_line(vr_dscritic);
    END;
  Commit;
end;