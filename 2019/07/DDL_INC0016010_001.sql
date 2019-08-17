/*
INC006010 - Não está apresentado a quantidade de dias no Cyber
Algumas contas não baixadas, estão com dtdpagto = null, por conta de uma liberação do projeto de desconto de títulos
Foram ajustadas as contas em 2018, porém faltaram algumas
Ana - 24/07/2019

--validando uma das contas após atualização -> dtdpagto deve ter informação
select cdcooper, a.nrdconta, a.nrctremp, dtmvtolt, dtdpagto, a.dtdbaixa, dtatufin
from crapcyb a where dtdbaixa IS NULL and cdorigem = 1 and dtprejuz is null and nrdconta = 141488 and cdcooper = 5

*/
DECLARE

  vr_cdcritic   NUMBER;
  vr_dscritic   VARCHAR2(2000);
  vr_idprglog   tbgen_prglog.idprglog%TYPE := 0;
  rw_crapdat    btch0001.cr_crapdat%rowtype;

  CURSOR cr_contas IS
    select (select min(z.dtmvtolt)
            from crapsda z
           where z.cdcooper = s.cdcooper
             and z.nrdconta = s.nrdconta
             and (((nvl(z.vlsddisp, 0) * -1) > nvl(z.vllimcre, 0)) and
                 (nvl(z.vllimutl, 0) >= nvl(z.vllimcre, 0)))
             and z.dtmvtolt >
                 ((select max(z.dtmvtolt)
                     from crapsda z
                    where z.cdcooper = s.cdcooper
                      and z.nrdconta = s.nrdconta
                      and (z.vlsddisp >= 0 OR
                          ((z.vlsddisp < 0) AND
                          NOT (((nvl(z.vlsddisp, 0) * -1) > nvl(z.vllimcre, 0)) and
                           (nvl(z.vllimutl, 0) >= nvl(z.vllimcre, 0)))))))) "DTDPAGTO_CALCULADO",
         s.progress_recid,
         s.dtdpagto "DTDPAGTO_ANTES",
         s.nrdconta,
         s.nrctremp,
         s.cdorigem,
         s.cdcooper
    from crapcyb s
   where s.dtdbaixa is null
     and s.cdorigem = 1
     and (s.cdcooper, s.nrdconta) in
         (select d.cdcooper, d.nrdconta
            from crapcyb d
           where d.dtdbaixa is null
             and d.dtdpagto is null
             and d.cdorigem = 1)
     and exists
         (select 1
            from crapsda x
           where (x.vlsddisp < 0)
             and (x.cdcooper = s.cdcooper)
             and (x.nrdconta = s.nrdconta)
             and (x.dtmvtolt = (select crapdat.dtmvtoan
                                  from crapdat
                                 where crapdat.cdcooper = s.cdcooper))
             and (((nvl(x.vlsddisp, 0) * -1) > nvl(x.vllimcre, 0)) and
                 (nvl(x.vllimutl, 0) >= nvl(x.vllimcre, 0))))
                 order by cdcooper, nrdconta; 
   rw_contas cr_contas%ROWTYPE;
  
BEGIN
  --Busca as contas a atualizar
  FOR rw_contas IN cr_contas LOOP
    BEGIN
      UPDATE CRAPCYB
      SET    dtdpagto = rw_contas.dtdpagto_calculado
      WHERE  progress_recid = rw_contas.progress_recid;

      dbms_output.put_line('Conta atualizada :'||rw_contas.nrdconta||', Coop:'||rw_contas.cdcooper
                 ||', Contrato:'||rw_contas.nrctremp||', Origem:'||rw_contas.cdorigem
                 ||', Dtdpagto:'||rw_contas.dtdpagto_calculado);

    EXCEPTION
      WHEN OTHERS THEN
        vr_cdcritic := 1035;
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||'CRAPCYB:'||
                            ' dtdpagto:'||rw_contas.dtdpagto_calculado||
                            ' com rowid:'||rw_contas.progress_recid||
                            '. '||sqlerrm;

        CECRED.pc_log_programa(pr_dstiplog      => 'E', 
                               pr_cdcooper      => rw_contas.cdcooper, 
                               pr_tpocorrencia  => 2, 
                               pr_cdprograma    => 'BACA_INC0016010', 
                               pr_tpexecucao    => 0,
                               pr_cdcriticidade => 0,
                               pr_cdmensagem    => vr_cdcritic,
                               pr_dsmensagem    => vr_dscritic,
                               pr_idprglog      => vr_idprglog,
                               pr_nmarqlog      => NULL);

    END;
  END LOOP;

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
END;
               
