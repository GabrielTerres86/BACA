--
-- Gera base nrbase_cpfcgc a partir do campo nrcpfcgc 
--
declare
  --Seleciona os cooperados
  CURSOR cr_cop IS
    SELECT c.cdcooper
      FROM crapcop c
     WHERE c.flgativo = 1;

  cursor c1 (pr_cdcooper IN crapcop.cdcooper%TYPE)is
    select ass.cdcooper
          ,ass.nrdconta
          ,ass.nrcpfcgc
          ,ass.inpessoa
		  ,ass.rowid 
      from crapass ass
     WHERE ass.cdcooper       = pr_cdcooper
       AND ass.nrcpfcnpj_base = 0
       ; -- apenas os que ainda nao foram processados
  --Variáveis de trabalho
  w_contador  number(10) := 0;
--
BEGIN
  dbms_output.put_line('inicio: ' || to_char(SYSDATE,'hh24:mi:ss'));
  --Tratar cooperados
  FOR rw_cop IN cr_cop LOOP
    FOR r1 IN c1 (rw_cop.cdcooper) LOOP
      --Atualiza cooperado
      update crapass ass
         set ass.nrbase_cpfcgc  = DECODE(ass.inpessoa,1,ass.nrcpfcgc,to_number(SUBSTR(to_char(ass.nrcpfcgc,'FM00000000000000'),1,8) ) )
       where ass.rowid = r1.rowid;
      --Inclementa contador
      w_contador := w_contador +1;
      --Verifica limite do contador para atualização
      if w_contador > 1000 THEN
        dbms_output.put_line('  QTDE: ' || to_char(w_contador));
        w_contador := 1;
        --Grava atualizações
        commit;
      end if;
    End LOOP;
    commit;
  END LOOP;
  --Grava atualizações
  commit;
  dbms_output.put_line('fim: ' || to_char(SYSDATE,'hh24:mi:ss'));
end;
