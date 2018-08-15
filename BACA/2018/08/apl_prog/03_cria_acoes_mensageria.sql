declare 
  v_NRSEQRDR pls_integer;
begin
  -- Inserir na CRAPRDR
  Insert into craprdr (nmprogra,dtsolici) values ('APLI0008',sysdate);
  -- Inserir na CRAPACA
  Select nrseqrdr into v_NRSEQRDR from craprdr where nmprogra='APLI0008';
  Insert into crapaca (NMDEACAO,NMPACKAG,NMPROCED,LSTPARAM,NRSEQRDR) Values ('RECUPERA_APL_PGM_PADRAO','APLI0008','pc_buscar_apl_prog_padrao_web',null,v_NRSEQRDR);
  
  Insert into crapaca (NMDEACAO,NMPACKAG,NMPROCED,LSTPARAM,NRSEQRDR) Values ('INCLUI_APL_PGM','APLI0008','pc_incluir_apl_prog_web','pr_nrdconta,pr_idseqttl,pr_cdprodut,pr_dtmvtolt,pr_qtdiacar,pr_qtdiaprz,pr_dtinirpp,pr_dtvctopp,pr_vlprerpp,pr_tpemiext,pr_flgerlog,pr_dsfinali,pr_flgteimo,pr_flgdbpar',v_NRSEQRDR);
  Insert into crapaca (NMDEACAO,NMPACKAG,NMPROCED,LSTPARAM,NRSEQRDR) Values ('EXTRATO_APL_PROG','APLI0008','pc_buscar_extrato_apl_prog_web','pr_nrdconta,pr_idseqttl,pr_nrctrrpp,pr_dtmvtolt_ini,pr_dtmvtolt_fim,pr_idlstdhs,pr_idgerlog',v_NRSEQRDR);
  Insert into crapaca (NMDEACAO,NMPACKAG,NMPROCED,LSTPARAM,NRSEQRDR) Values ('SALDO_APL_PGM','APLI0008','pc_calc_saldo_apl_prog_web','pr_nrdconta,pr_idseqttl,pr_nrctrrpp,pr_dtmvtolt',v_NRSEQRDR);
  Insert into crapaca (NMDEACAO,NMPACKAG,NMPROCED,LSTPARAM,NRSEQRDR) Values ('DETALHE_APL_PGM','APLI0008','pc_buscar_detalhe_apl_prog_web','pr_nrdconta,pr_idseqttl,pr_nrctrrpp,pr_dtmvtolt',v_NRSEQRDR);
  commit;
end;


