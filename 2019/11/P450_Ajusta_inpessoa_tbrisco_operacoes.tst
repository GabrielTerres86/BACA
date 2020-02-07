PL/SQL Developer Test script 3.0
19
declare 
  CURSOR cr_operacoes IS
    SELECT o.cdcooper, o.nrdconta
         , o.nrcpfcnpj_base, a.inpessoa
     FROM tbrisco_operacoes o, crapass a
    WHERE o.cdcooper = a.cdcooper
      AND o.nrcpfcnpj_base = a.nrcpfcnpj_base
      AND o.inpessoa <> a.inpessoa
     ORDER BY o.cdcooper, o.nrcpfcnpj_base;
begin

  FOR rw_operacoes IN cr_operacoes LOOP
      UPDATE tbrisco_operacoes o
         SET o.inpessoa       = rw_operacoes.inpessoa
       WHERE o.cdcooper       = rw_operacoes.cdcooper
         AND o.nrcpfcnpj_base = rw_operacoes.nrcpfcnpj_base;
     dbms_output.put_line('CNPJ/CPF alterados: ' || rw_operacoes.cdcooper || ' -> ' || rw_operacoes.nrcpfcnpj_base);
  END LOOP;
end;
0
0
