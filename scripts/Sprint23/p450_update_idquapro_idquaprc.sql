Declare
  cursor c1 is  -- 891 Registros no H3
    SELECT x.cdcooper,
           x.nrdconta,
           x.nrctremp,
           x.idquapro,
           x.nrctrliq##1,
           x.nrliquid,
           x.dtmvtolt    x_dt_proposta,
           e.dtmvtolt    e_dt_efetivacao,
           e.idquaprc,
           e.inliquid,
           x.rowid  x_rowid,
           e.rowid  e_rowid
      FROM crawepr x, crapepr e
     WHERE e.cdcooper = x.cdcooper
       AND e.nrdconta = x.nrdconta
       AND e.nrctremp = x.nrctremp
       AND x.dtmvtolt > '01/03/2018'
       AND x.idquapro IN (2, 3, 4)
       AND e.inliquid    = 0
       AND x.nrctrliq##1 = 0
       AND x.nrliquid    = 0
     ORDER BY x.cdcooper, x.nrdconta, x.nrctremp, x.dtmvtolt, e.dtmvtolt;
  --
  contador         number(10) := 0;
  contador_crawepr number(10) := 0;
  contador_crapepr number(10) := 0;
  --
Begin
  For reg_c1 in c1 loop
    update crawepr x
       set x.idquapro = 1
     where x.rowid = reg_c1.x_rowid;
       --x.nrdconta = reg_c1.nrdconta
       --and x.cdcooper = reg_c1.cdcooper
       --and x.nrctremp = reg_c1.nrctremp
       --and x.dtmvtolt = reg_c1.x_dt_proposta
       --and x.idquapro IN (2, 3, 4)
       --and x.nrctrliq##1 = 0
       --and x.nrliquid    = 0;
    --
    if sql%rowcount > 0 then
      contador_crawepr := sql%rowcount;
    end if;
    --
    update crapepr e
       set e.idquaprc = 1
     where e.rowid = reg_c1.e_rowid
     and   e.idquaprc = reg_c1.idquapro;
       --e.nrdconta = reg_c1.nrdconta
       --and e.cdcooper = reg_c1.cdcooper
       --and e.nrctremp = reg_c1.nrctremp
       --and e.inliquid = reg_c1.inliquid;
    --
    if sql%rowcount > 0 then
      contador_crapepr := sql%rowcount;
    end if;
    --
    contador := contador + nvl(contador_crawepr,0) + nvl(contador_crapepr,0);
    --
  End loop;
  dbms_output.put_line('Quantidade de registros atualizados: ' || contador);
  --
  --commit;
End;
