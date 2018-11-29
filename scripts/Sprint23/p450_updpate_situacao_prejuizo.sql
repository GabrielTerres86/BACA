----------------------------------
-- Fabio Oliveira
alter table CECRED.crapass
add  CDSITDCT_ORIGINAL NUMBER(5) default 0;

Comment on column cecred.crapass.CDSITDCT_ORIGINAL 
is 'Código da situação da conta original antes do prejuízo';
----------------------------------
-- Ornelas
Declare
  cursor c1 is -- 45 Registros no H3
   select a.cdcooper, a.nrdconta, a.cdsitdct_original
      from tbcc_prejuizo a;
  --where a.cdcooper = 5;
  --and   a.nrdconta = &nrconta
  --
  contador number(10) := 0;
  contador_tot number(10) := 0;
  --
Begin
  For reg_c1 in c1 loop
    update crapass x
       set x.cdsitdct_original = reg_c1.cdsitdct_original
     where x.cdcooper = reg_c1.cdcooper
       and x.nrdconta = reg_c1.nrdconta;
    --
    contador := contador + 1;
    contador_tot := contador_tot + 1;
  
    if contador >= 5000 then
      -- para não estourar área de Rollback
      contador := 0;
      --commit;
    end if; --
  --
  End loop;
  --
  dbms_output.put_line('Quantidade de registros atualizados: ' ||
                       contador_tot);
  --
  --commit;
End;

----------------------------------
-- Ornelas
alter table tbcc_prejuizo
drop column cdsitdct_original;
