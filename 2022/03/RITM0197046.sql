begin

declare
  vr_cdcritic           PLS_INTEGER;
  vr_dscritic           VARCHAR2(4000);
begin
  cecred.pc_envia_arq_seg_prst(pr_cdcritic => vr_cdcritic,
                               pr_dscritic => vr_dscritic);
end;

end;