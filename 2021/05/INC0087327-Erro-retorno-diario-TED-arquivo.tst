declare
       vr_cdcritic number;
       vr_dscritic varchar2(10000);
       vr_datectrl date;
begin
       vr_datectrl := to_date('19/04/2021');
       loop
          cecred.pgta0001.pc_gerar_seg_arquivo_retorno(pr_dtretorno => vr_datectrl
                                                      ,pr_cdcritic => vr_cdcritic
                                                      ,pr_dscritic => vr_dscritic);
          if vr_dscritic is not null then
              RAISE_application_error(-20500,'Erro rotina pc_gerar_seg_arquivo_retorno: '||vr_dscritic);
          end if;
          
          vr_datectrl := vr_datectrl + 1;
          
          exit when vr_datectrl > sysdate;
        end loop;
end;