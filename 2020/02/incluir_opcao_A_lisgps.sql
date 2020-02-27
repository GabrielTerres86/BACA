declare

  vr_dscritic crapcri.dscritic%type;
  vr_exc_saida EXCEPTION;

begin

  begin
    insert into crapaca
      (NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
    values
      ('ALT_ENVIO_GPS',
       'INSS0002',
       'pc_gps_alterar_status_envio',
       'pr_flgpagto,pr_nrdrowid',
       210);
  exception
    when others then
      vr_dscritic := 'Erro ao inserir na crapaca. ' || sqlerrm;
      raise vr_exc_saida;
  end;

  begin
    update craptel
       set craptel.cdopptel = craptel.cdopptel || ',A',
           craptel.lsopptel = craptel.lsopptel || ',ALTERAR'
     where craptel.cdcooper in
           (select crapcop.cdcooper from crapcop where crapcop.flgativo = 1)
       and upper(craptel.nmdatela) = 'LISGPS';
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
