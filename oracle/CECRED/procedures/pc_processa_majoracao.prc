create or replace procedure cecred.pc_processa_majoracao(pr_skcarga in number) is
  /* .............................................................................

  Programa: pc_processa_majoracao                      
  Sistema : 
  Sigla   : CRED
  Autor   : 
  Data    :                                Ultima atualizacao:  20/08/2019

  Dados referentes ao programa:

  Frequencia: Diaria

  
  Objetivo  : 

  Alteracoes: 20/08/2019 - P450 - Verifica se rating continua ao majorar via SAS
                           Luiz Otavio Olinegr Momm (AMCOM)
  ............................................................................. */
  vr_dserro varchar2(1000);
  vr_contador_rating number := 0;

  cursor c_cargas is
    select x.skcarga
      from INTEGRADADOS.DW_FATOCONTROLECARGA@SASP x
     where x.skprocesso = 118
       and x.qtregistroprocessado > 0
       and nvl(x.qtregistrook,0) = 0
       and nvl(x.qtregistroatencao,0) = 0
       and nvl(x.qtregistroerro,0) = 0
       and x.dthorafiminclusao is not null
       and x.skcarga = decode(pr_skcarga,0,x.skcarga,pr_skcarga)
     order
        by skcarga asc;

  procedure pc_processa_carga(pr_skcarga in number) is
    vr_dserr        varchar2(1000);
    vr_cdcooper     crapcop.cdcooper%type;
    vr_nrdconta     crapass.nrdconta%type;
    vr_nrctrlim     craplim.nrctrlim%type;
    vr_vllimite     number;
    vr_vldivida     number;
    vr_dtbase       date;
    er_vencido      exception;
    er_inativo      exception;
    er_valor        exception;
    er_contrato     exception;
    er_update       exception;
    er_rating       exception;
    er_campo_zerado exception;
    er_zero_neg     exception;
    er_flag_age     exception;
    er_flag_ass     exception;
    er_qtd_rating   exception;
    wdtinivig       craplim.dtinivig%type;
    wdtfimvig       craplim.dtfimvig%type;
    wvllimite       craplim.vllimite%type;
    wdtdemiss       crapass.dtdemiss%type;
    wflmajora_ass   crapass.flmajora%type;
    wflmajora_age   crapage.flmajora%type;
    winsitlim       craplim.insitlim%type;
    vr_dsmotivo     varchar2(1000);
    vr_majorado     number(1);
    vr_sqlerrm      varchar2(1000);
    --
    vr_limite_rating   number := 100;
    --
    vr_tab_impress_coop     RATI0001.typ_tab_impress_coop;
    vr_tab_impress_rating   RATI0001.typ_tab_impress_rating;
    vr_tab_impress_risco_cl RATI0001.typ_tab_impress_risco;
    vr_tab_impress_risco_tl RATI0001.typ_tab_impress_risco;
    vr_tab_impress_assina   RATI0001.typ_tab_impress_assina;
    vr_tab_efetivacao       RATI0001.typ_tab_efetivacao;
    vr_tab_ratings          RATI0001.typ_tab_ratings;
    vr_tab_crapras          RATI0001.typ_tab_crapras;
    vr_tab_erro             GENE0001.typ_tab_erro;

    cursor c1 is
      select m.cdcooper
           , m.nrdconta
           , m.nrcontrato
           , m.vllimite
           , m.dtbase
           , nvl(c.vlsdeved,0)
               + nvl(c.vldeschq,0)
               + nvl(c.vldestit,0)
               + nvl(c.vllimcre,0)
               + (select /*+ index(y CRAPEPR##CRAPEPR1) */
                         nvl(sum(y.vlemprst),0)
                    from crapepr y
                   where y.cdcooper (+) = m.cdcooper
                     and y.dtmvtolt (+) = d.dtmvtolt
                     and y.nrdconta (+) = m.nrdconta
                     and y.inliquid (+) = 0) vldivida
           , case when nvl(c.vlsdeved,0)
                     + nvl(c.vldeschq,0)
                     + nvl(c.vldestit,0)
                     + nvl(c.vllimcre,0)
                     + (select /*+ index(y CRAPEPR##CRAPEPR1) */
                               nvl(sum(y.vlemprst),0)
                          from crapepr y
                         where y.cdcooper (+) = m.cdcooper
                           and y.dtmvtolt (+) = d.dtmvtolt
                           and y.nrdconta (+) = m.nrdconta
                           and y.inliquid (+) = 0) >= gene0002.fn_char_para_number(substr(t.dstextab,15,11)) then 1 else 0 end as idrating
        from craptab t
           , crapsda c
           , crapdat d
           , INTEGRADADOS.sasf_majoracao@SASP m
           , INTEGRADADOS.DW_FATOCONTROLECARGA@SASP x
       where t.cdcooper = m.cdcooper
         and UPPER(t.nmsistem) = 'CRED'
         and UPPER(t.tptabela) = 'GENERI'
         and t.cdempres        = 00
         and UPPER(t.cdacesso) = 'PROVISAOCL'
         and t.tpregist        = 999
         and c.cdcooper = m.cdcooper
         and c.nrdconta = m.nrdconta
         and c.dtmvtolt = d.dtmvtoan
         and d.cdcooper = m.cdcooper
         and m.skcarga  = x.skcarga
         and x.skcarga  = pr_skcarga;

    cursor c2(pr_cdcooper in crapcop.cdcooper%type
             ,pr_nrdconta in crapass.nrdconta%type
             ,pr_nrctrlim in craplim.nrctrlim%type) is
      select b.dtdemiss
           , a.dtinivig
           , a.dtfimvig
           , a.vllimite
           , b.flmajora flmajora_ass
           , c.flmajora flmajora_age
           , a.insitlim
        from crapage c
           , crapass b
           , craplim a
       where c.cdcooper = b.cdcooper
         and c.cdagenci = b.cdagenci
         and b.cdcooper = a.cdcooper
         and b.nrdconta = a.nrdconta
         and a.cdcooper = pr_cdcooper
         and a.nrdconta = pr_nrdconta
         and a.nrctrlim = pr_nrctrlim
         and a.tpctrlim = 1;
  begin
    begin
      update INTEGRADADOS.DW_FATOCONTROLECARGA@SASP
         set dthorainicioprocesso         = sysdate
       where skcarga = pr_skcarga;

      commit;
    exception
      when others then
        vr_sqlerrm := sqlerrm;
        raise;
    end;

    for r1 in c1 loop
      begin
        vr_dsmotivo := '';
        vr_dserro := '';
        vr_dserr := '';
        vr_tab_crapras.delete;
        vr_tab_impress_coop.delete;
        vr_tab_impress_rating.delete;
        vr_tab_impress_risco_cl.delete;
        vr_tab_impress_risco_tl.delete;
        vr_tab_impress_assina.delete;
        vr_tab_efetivacao.delete;
        vr_tab_ratings.delete;
        vr_tab_crapras.delete;
        vr_tab_erro.delete;
        vr_majorado := 0;

        vr_cdcooper := r1.cdcooper;
        vr_nrdconta := r1.nrdconta;
        vr_nrctrlim := r1.nrcontrato;
        vr_vllimite := r1.vllimite;
        vr_vldivida := r1.vldivida;
        vr_dtbase   := r1.dtbase;
        
        if vr_contador_rating > vr_limite_rating and r1.idrating = 1 then
          raise er_qtd_rating;
        end if;

        if nvl(vr_cdcooper,0) = 0 or nvl(vr_nrdconta,0) = 0 or nvl(vr_nrctrlim,0) = 0 then
          raise er_campo_zerado;
        end if;

        if nvl(vr_vllimite,0) <= 0 then
          raise er_zero_neg;
        end if;

        open c2(vr_cdcooper, vr_nrdconta, vr_nrctrlim);
        fetch c2 into wdtdemiss, wdtinivig, wdtfimvig, wvllimite, wflmajora_ass, wflmajora_age, winsitlim;
        if c2%notfound then
          close c2;
          raise er_contrato;
        else
          close c2;
        end if;

        if nvl(wflmajora_age,1) = 0 then
          raise er_flag_age;
        elsif nvl(wflmajora_ass,1) = 0 then
          raise er_flag_ass;
        elsif wdtdemiss is not null then
          raise er_inativo;
        elsif ((wdtinivig > trunc(sysdate)) or (wdtfimvig <= trunc(sysdate)) or winsitlim <> 2) then
          raise er_vencido;
        elsif wvllimite >= vr_vllimite then
          raise er_valor;
        else
          begin
            update craplim c
               set c.vllimite = vr_vllimite
                 , c.cdoperad = '1'
             where c.cdcooper = vr_cdcooper
               and c.nrdconta = vr_nrdconta
               and c.nrctrlim = vr_nrctrlim
               and c.tpctrlim = 1;

            update crapass a
               set a.vllimcre = vr_vllimite
                 , a.dtultlcr = trunc(sysdate)
             where a.cdcooper = vr_cdcooper
               and a.nrdconta = vr_nrdconta;

            if r1.idrating = 1 then
              vr_contador_rating := vr_contador_rating + 1;

              rati0001.pc_gera_rating(pr_cdcooper => vr_cdcooper
                                    , pr_cdagenci => 0
                                    , pr_nrdcaixa => 0
                                    , pr_cdoperad => '1'
                                    , pr_nmdatela => ' '
                                    , pr_idorigem => 7
                                    , pr_nrdconta => vr_nrdconta
                                    , pr_idseqttl => 1
                                    , pr_dtmvtolt => trunc(sysdate)
                                    , pr_dtmvtopr => gene0005.fn_valida_dia_util(1,trunc(sysdate))
                                    , pr_inproces => 1
                                    , pr_tpctrrat => 1
                                    , pr_nrctrrat => vr_nrctrlim
                                    , pr_flgcriar => 1
                                    , pr_flgerlog => 1
                                    , pr_tab_rating_sing => vr_tab_crapras
                                    , pr_tab_impress_coop => vr_tab_impress_coop
                                    , pr_tab_impress_rating => vr_tab_impress_rating
                                    , pr_tab_impress_risco_cl => vr_tab_impress_risco_cl
                                    , pr_tab_impress_risco_tl => vr_tab_impress_risco_tl
                                    , pr_tab_impress_assina => vr_tab_impress_assina
                                    , pr_tab_efetivacao => vr_tab_efetivacao
                                    , pr_tab_ratings => vr_tab_ratings
                                    , pr_tab_crapras => vr_tab_crapras
                                    , pr_tab_erro => vr_tab_erro
                                    , pr_des_reto => vr_dserr);

              if vr_dserr <> 'OK' and vr_tab_erro.count > 0
                then
                if vr_tab_erro(0).dscritic is not null then
                  raise er_rating;
                end if;
              end if;
            end if;

            vr_majorado := 1;

            commit;
          exception
            when er_rating then
              raise er_rating;
            when others then
              vr_sqlerrm := sqlerrm;
              raise er_update;
          end;
        end if;
      exception
        when er_flag_age then
          vr_majorado := 2;
          vr_dsmotivo := 'Agencia nao habilitada para majoracao';
        when er_flag_ass then
          vr_majorado := 2;
          vr_dsmotivo := 'Cooperado nao habilitado para majoracao';
        when er_update then
          vr_majorado := 3;
          vr_dsmotivo := 'Erro ao atualizar - '||vr_sqlerrm;
        when er_contrato then
          vr_majorado := 2;
          vr_dsmotivo := 'Contrato nao encontrado';
        when er_vencido then
          vr_majorado := 2;
          vr_dsmotivo := 'Contrato informado nao esta vigente';
        when er_inativo then
          vr_majorado := 2;
          vr_dsmotivo := 'Conta do cooperado esta inativa';
        when er_valor then
          vr_majorado := 2;
          vr_dsmotivo := 'Valor solicitado e menor ou igual ao valor vigente';
        when er_campo_zerado then
          vr_majorado := 3;
          vr_dsmotivo := 'Campos cdcooper, nrdconta ou nrcontrato nulos/zerados';
        when er_zero_neg then
          vr_majorado := 3;
          vr_dsmotivo := 'Limite zerado ou negativo';
        when er_rating then
          vr_majorado := 3;
          vr_dsmotivo := 'Erro na geração do rating - '||vr_tab_erro(0).dscritic;
        when er_qtd_rating then
          vr_majorado := 2;
          vr_dsmotivo := 'Excesso de atualização de rating';
        when invalid_number then
          vr_majorado := 3;
          vr_dsmotivo := 'Dado invalido na linha';
        when value_error then
          vr_majorado := 3;
          vr_dsmotivo := 'Dado invalido na linha';
        when others then
          vr_majorado := 3;
          vr_dsmotivo := 'Erro nao identificado - '||sqlerrm;
      end;

      begin
        update INTEGRADADOS.sasf_majoracao@SASP
           set dtmajoracao = sysdate
             , cdmajorado  = vr_majorado
             , dsexclusao  = vr_dsmotivo
         where cdcooper    = vr_cdcooper
           and nrdconta    = vr_nrdconta
           and nrcontrato  = vr_nrctrlim
           and dtbase      = vr_dtbase;
      exception
        when others then
          vr_sqlerrm := sqlerrm;
          raise;
      end;
    end loop;

    begin
      update INTEGRADADOS.DW_FATOCONTROLECARGA@SASP
         set dthorafimprocesso    = sysdate
           , qtregistrook         = (select count(*) from INTEGRADADOS.sasf_majoracao@SASP where skcarga = pr_skcarga and cdmajorado = 1)
           , qtregistroatencao    = (select count(*) from INTEGRADADOS.sasf_majoracao@SASP where skcarga = pr_skcarga and cdmajorado = 2)
           , qtregistroerro       = (select count(*) from INTEGRADADOS.sasf_majoracao@SASP where skcarga = pr_skcarga and cdmajorado = 3)
       where skcarga = pr_skcarga;

      commit;
    exception
      when others then
        vr_sqlerrm := sqlerrm;
        raise;
    end;
  exception
    when others then
      rollback;
      vr_dserro := 'Erro: '||vr_sqlerrm;
      raise;
  end pc_processa_carga;
begin
  for r_cargas in c_cargas loop
    pc_processa_carga(r_cargas.skcarga);
  end loop;
exception
  when others then
    pc_internal_exception(3);
    raise_application_error(-20001, vr_dserro);
end pc_processa_majoracao;
/
