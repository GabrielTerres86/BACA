declare

  vr_dscritic crapcri.dscritic%type;
  vr_exc_saida EXCEPTION;

begin

  begin
    insert into crapaca
      (NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
    values
      ('TAB057_LAUTOM',
       'TELA_TAB057',
       'pc_busca_total_lanctos_futuros',
       'pr_cdcooper,pr_cddopcao,pr_cdagente,pr_dtmvtopg',
       1184);
  exception
    when others then
      vr_dscritic := 'Erro ao inserir na crapaca. ' || sqlerrm;
      raise vr_exc_saida;
  end;

  begin
    update craptel
       set craptel.cdopptel = craptel.cdopptel || ',L',
           craptel.lsopptel = craptel.lsopptel || ',LANCAMENTOS FUTUROS'
     where craptel.cdcooper in
           (select crapcop.cdcooper from crapcop where crapcop.flgativo = 1)
       and upper(craptel.nmdatela) = 'TAB057';
  exception
    when others then
      vr_dscritic := 'Erro ao atualizar craptel. ' || sqlerrm;
      raise vr_exc_saida;
  end;

  commit;

exception
  when vr_exc_saida then
    rollback;
    dbms_output.put_line(vr_dscritic);
end;
