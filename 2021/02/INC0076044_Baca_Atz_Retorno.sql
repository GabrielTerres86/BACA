declare
  --
  procedure pc_verifica_jd(pr_idtitleg number
                          ,pr_nratutit_cob number
                          ,pr_nratutit_jd out number) is
    --
    cursor c_jd(pr_idtitleg_cr varchar2
               ,pr_nratutit_cob_cr number) is
      SELECT jd2lg."NumRefAtlCadTit" nratutit_jd
      FROM tbjdnpcdstleg_jd2lg_optit@jdnpcbisql jd2lg
      WHERE jd2lg."SitOpJD" = 'RC'
        AND jd2lg."NumRefAtlCadTit" > pr_nratutit_cob_cr
        AND jd2lg."IdTituloLeg" = pr_idtitleg_cr
      ORDER BY jd2lg."NumRefAtlCadTit" desc;
    r_jd c_jd%rowtype;
    --
    vr_idlocalizou number(1) := 0;
    --
  begin
    --
    open c_jd(pr_idtitleg_cr     => trim(to_char(pr_idtitleg))
             ,pr_nratutit_cob_cr => pr_nratutit_cob);
    fetch c_jd into r_jd;
    if c_jd%found then
      vr_idlocalizou := 1;
    end if;
    close c_jd;
    --
    if vr_idlocalizou = 1 then
      pr_nratutit_jd := r_jd.nratutit_jd;
    else
      pr_nratutit_jd := null;
    end if;
    --
  end pc_verifica_jd;
  --
begin
  --
  declare
    --
    cursor c_cob is
      SELECT /*+index (cob CRAPCOB##CRAPCOB9)*/
             cob.rowid rowid_cob
            ,cob.cdcooper
            ,cob.cdbandoc
            ,cob.nrdctabb
            ,cob.nrcnvcob
            ,cob.nrdconta
            ,cob.nrdocmto
            ,cob.idtitleg
            ,cob.nratutit nratutit_cob
        FROM crapcob cob
            ,crapcco cco
       WHERE not exists (
                         select 1
                          from tbcobran_retorno_npc trn
                          where trn.cdsituac = 1
                            and trn.nratutit = cob.nratutit
                            and trn.idtitleg = trim(to_char(cob.idtitleg))
                        )
         AND cob.dtmvtolt < to_date('01102020','ddmmyyyy') --após essa data foi implantado retorno diferenciado crps718
         AND cob.ininscip = 1 --somente registros que estão aguardando retorno
         AND cob.incobran = 0 --boletos em aberto
         AND cob.cdbandoc = cco.cddbanco
         AND cob.nrdconta = 850004 --conta padrão utilizado pela recuperação de crédito para acordos
         AND cob.nrcnvcob = cco.nrconven
         AND cob.dtvencto >= to_date('01112020','ddmmyyyy')
         AND cob.dtvencto <  to_date('01042021','ddmmyyyy')
         AND cob.cdcooper = cco.cdcooper
         --
         AND cco.cddbanco = 85
         AND cco.dsorgarq = 'ACORDO';
    --
    TYPE typ_reg_cob IS record (rowid_cob    varchar2(18)
                               ,cdcooper     crapcob.cdcooper%type
                               ,cdbandoc     crapcob.cdbandoc%type
                               ,nrdctabb     crapcob.nrdctabb%type
                               ,nrcnvcob     crapcob.nrcnvcob%type
                               ,nrdconta     crapcob.nrdconta%type
                               ,nrdocmto     crapcob.nrdocmto%type
                               ,idtitleg     crapcob.idtitleg%type
                               ,nratutit_cob crapcob.nratutit%type);
    TYPE typ_tab_cob IS table of typ_reg_cob index by pls_integer;
    vr_tab_cob typ_tab_cob;
    --
    vr_qtregistro_total    number := 0;
    vr_qtregistro_alterado number := 0;
    vr_nratutit_jd         number;
    vr_dscritic            varchar2(2000);
    vr_des_erro            varchar2(200);
    --
  begin
    --
    open c_cob;
    fetch c_cob bulk collect into vr_tab_cob;
    close c_cob;
    --
    IF nvl(vr_tab_cob.count,0) > 0 THEN
      --
      for i in vr_tab_cob.first .. vr_tab_cob.last
      loop
        --
        vr_qtregistro_total := vr_qtregistro_total + 1;
        --
        vr_nratutit_jd := null;
        --
        pc_verifica_jd(pr_idtitleg     => vr_tab_cob(i).idtitleg
                      ,pr_nratutit_cob => vr_tab_cob(i).nratutit_cob
                      ,pr_nratutit_jd  => vr_nratutit_jd);
        --
        if vr_nratutit_jd is not null then
          --
          vr_qtregistro_alterado := vr_qtregistro_alterado + 1;
--          dbms_output.put_line('vr_tab_cob(i).idtitleg: '||vr_tab_cob(i).idtitleg||' vr_tab_cob(i).nratutit_cob: '||vr_tab_cob(i).nratutit_cob||' vr_nratutit_jd: '||vr_nratutit_jd);
--/*
          update crapcob cob
          set cob.nratutit = vr_nratutit_jd
             ,cob.ininscip = 2
          where cob.nratutit = vr_tab_cob(i).nratutit_cob
            and cob.idtitleg = vr_tab_cob(i).idtitleg
            and cob.rowid    = vr_tab_cob(i).rowid_cob;

          paga0001.pc_cria_log_cobranca(pr_idtabcob => vr_tab_cob(i).rowid_cob
                                       ,pr_cdoperad => '1'
                                       ,pr_dtmvtolt => sysdate
                                       ,pr_dsmensag => 'Alteração de Titulo Registrado no SFN (INC0076044)'
                                       ,pr_des_erro => vr_des_erro
                                       ,pr_dscritic => vr_dscritic);
/*/
          dbms_output.put_line('update crapcob cob'
                            ||' set cob.nratutit = '||trim(to_char(vr_tab_cob(i).nratutit_cob))
                            ||' where cob.nratutit = '||trim(to_char(vr_nratutit_jd))
                              ||' and cob.idtitleg = '||vr_tab_cob(i).idtitleg
                              ||' and cob.nrdocmto = '||vr_tab_cob(i).nrdocmto
                              ||' and cob.nrdconta = '||vr_tab_cob(i).nrdconta
                              ||' and cob.nrcnvcob = '||vr_tab_cob(i).nrcnvcob
                              ||' and cob.nrdctabb = '||vr_tab_cob(i).nrdctabb
                              ||' and cob.cdbandoc = '||vr_tab_cob(i).cdbandoc
                              ||' and cob.cdcooper = '||vr_tab_cob(i).cdcooper||';');
--*/
          --
        end if;
        --
        commit;
        --
      end loop;
      --
    end if;
    --
    dbms_output.put_line('-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-');
    dbms_output.put_line('vr_qtregistro_total   : '||vr_qtregistro_total);
    dbms_output.put_line('vr_qtregistro_alterado: '||vr_qtregistro_alterado);
    --
  end;
  --
end;
