DECLARE
  vr_cdcooper crapcop.cdcooper%TYPE;
  vr_flgresta INTEGER; --> Flag padrão para utilização de restart
  vr_stprogra INTEGER; --> Saída de termino da execução
  vr_infimsol INTEGER; --> Saída de termino da solicitação
  vr_cdcritic crapcri.cdcritic%TYPE; --> Critica encontrada
  vr_dscritic VARCHAR2(4000);
begin
  -- Call the procedure
  vr_cdcooper := 3;
  vr_flgresta := 0;
  vr_stprogra := 0;
  cecred.pc_crps658(vr_cdcooper,
                    vr_flgresta,
                    vr_stprogra,
                    vr_infimsol,
                    vr_cdcritic,
                    vr_dscritic);
commit;
end;
/
