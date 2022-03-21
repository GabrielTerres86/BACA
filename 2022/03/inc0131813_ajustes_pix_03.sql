declare
  vr_idblqpix varchar2(4000);
  vr_instatus number(1) := 1;
  vr_cdcritic crapcri.cdcritic%type;
  vr_dscritic crapcri.dscritic%type;
begin
  vr_idblqpix := 'DA84BFE13B910564E0530A293574A648';

  contacorrente.finalizaBloqueioPix(pr_idblqpix => vr_idblqpix,
                                    pr_instatus => vr_instatus,
                                    pr_cdcritic => vr_cdcritic,
                                    pr_dscritic => vr_dscritic);

  IF (vr_dscritic is not null) or (nvl(vr_dscritic, 0) <> 0) THEN
    RAISE_APPLICATION_ERROR(-20000,
                            'Erro ao finalizar o Bloqueio ' || vr_idblqpix ||
                            ' com status ' || vr_instatus || ' - ' ||
                            'vr_cdcritic: ' || vr_cdcritic || ' / ' ||
                            'vr_dscritic: ' || vr_dscritic);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-20000,
                            'Erro ao finalizar o Bloqueio ' || vr_idblqpix ||
                            ' com status ' || vr_instatus || ' - ' ||
                            SQLERRM);
END;