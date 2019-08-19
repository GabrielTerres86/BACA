PL/SQL Developer Test script 3.0
31
-- Created on 30/01/2019 by F0030367 
declare 
  -- Local variables here
  vr_cdcritic pls_integer;
  vr_dscritic varchar2(10000);
  
  vr_dtmvtopg date;
begin

    dbms_output.put_line(to_char(sysdate, 'dd/mm/rrrr hh24:mi:ss') || 
                         ' >> Inicio da geração arquivos de pagamento.'||chr(13));

    vr_dtmvtopg:= to_date('29/01/2019');

    PGTA0001.pc_gera_retorno_tit_pago(pr_cdcooper => 1
                                    , pr_dtmvtolt => vr_dtmvtopg
                                    , pr_idorigem => 3    -- Ayllos
                                    , pr_cdoperad => '1'
                                    , pr_cdcritic => vr_cdcritic
                                    , pr_dscritic => vr_dscritic );
    --Se ocorreu erro
    IF vr_dscritic IS NOT NULL OR vr_cdcritic IS NOT NULL THEN
       --Levantar Excecao
       dbms_output.put_line('Erro ao executar PGTA0001.pc_gera_retorno_tit_pago: '|| vr_dscritic||chr(13));
    END IF;
  
    dbms_output.put_line(to_char(sysdate, 'dd/mm/rrrr hh24:mi:ss') || 
                         ' >> Final da geração arquivos de pagamento.');

  commit;
end;
0
0
