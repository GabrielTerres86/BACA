declare
  --
  CURSOR cr_cooper IS
  select DISTINCT cop.cdcooper
    from crapcop cop
   where cop.cdcooper <> 3;--CECRED
  rw_cooper cr_cooper%ROWTYPE;
begin
  --
  open cr_cooper;
  loop
    fetch cr_cooper into rw_cooper;
    exit when cr_cooper%notfound;

    insert into tbgen_batch_controle(IDCONTROLE
                                    ,CDCOOPER
                                    ,CDPROGRA
                                    ,DTMVTOLT
                                    ,TPAGRUPADOR
                                    ,CDAGRUPADOR
                                    ,CDRESTART
                                    ,INSITUACAO
                                    ,NREXECUCAO)
                              values((select max(idcontrole)+1
                                        from tbgen_batch_controle)              -- IDCONTROLE
                                    ,rw_cooper.cdcooper                         -- CDCOOPER
                                    ,'RISC0003.PC_RISCO_CENTRAL_OCR'            -- CDPROGRA
                                    ,(select dat.dtmvtolt
                                        from crapdat dat
                                       where dat.cdcooper = rw_cooper.cdcooper) -- DTMVTOLT
                                    ,1                                          -- TPAGRUPADOR
                                    ,0                                          -- CDAGRUPADOR
                                    ,0                                          -- CDRESTART
                                    ,2                                          -- INSITUACAO
                                    ,1);                                        -- NREXECUCAO
    -- Salva registro inserido!
    COMMIT;
    --
  end loop;
  close cr_cooper;
end;