Declare
  cursor cr_parametros is
    select p.idseqpar,
           p.cdcooper,
           p.tppessoa,
           p.cdsegura,
           p.tpdpagto,
           p.modalida,
           p.qtparcel,
           p.piedias,
           p.pieparce,
           p.pielimit,
           p.pietaxa,
           p.ifttdias,
           p.ifttparc,
           p.ifttlimi,
           p.iftttaxa,
           p.lmpseleg,
           p.tpcustei,
           p.vlcomiss,
           p.tpadesao,
           p.limitdps,
           '000000077001166' as nrapolic,
           p.enderftp,
           p.loginftp,
           p.senhaftp,
           p.flgelepf,
           p.flginden,
           p.idadedps,
           0.3038000 as pagsegu,
           1 as seqarqu,
           to_date('04/03/2024', 'dd/mm/yyyy') as dtinivigencia,
           to_date('30/11/2033', 'dd/mm/yyyy') as dtfimvigencia,
           p.lminsoci,
           p.dtctrmista
      from cecred.tbseg_parametros_prst p, cecred.crapcop c
     where p.tpcustei = 1
       AND p.tppessoa = 1
       and p.cdcooper = c.cdcooper
       and c.flgativo = 1;

  cursor cr_cap(pidseqpar tbseg_parametros_prst.idseqpar%type) is
    select s.idademin, s.idademax, s.capitmin, 3000000 as capitmax
      from cecred.tbseg_parametros_prst    p,
           cecred.tbseg_param_prst_cap_seg s
     where p.idseqpar = s.idseqpar
       and p.tpcustei = 1
       AND p.tppessoa = 1
       and s.idseqpar = pidseqpar;

  cursor cr_cob(pidseqpar tbseg_parametros_prst.idseqpar%type) is
    select s.gbidamin,
           s.gbidamax,
           0.28504790 as gbsegmin,
           0.01875210 as gbsegmax
      from cecred.tbseg_parametros_prst    p,
           cecred.tbseg_param_prst_tax_cob s
     where p.idseqpar = s.idseqpar
       and p.tpcustei = 1
       AND p.tppessoa = 1
       and s.idseqpar = pidseqpar;

  vidseqpar_seq tbseg_parametros_prst.idseqpar%type;
  vr_exc_erro   varchar2(2000);
begin
  FOR rw_parametros IN cr_parametros LOOP  
    select cecred.tbseg_parametros_prst_seq.nextval
      into vidseqpar_seq
      from dual;  
    insert into cecred.tbseg_parametros_prst
      (idseqpar,
       cdcooper,
       tppessoa,
       cdsegura,
       tpdpagto,
       modalida,
       qtparcel,
       piedias,
       pieparce,
       pielimit,
       pietaxa,
       ifttdias,
       ifttparc,
       ifttlimi,
       iftttaxa,
       lmpseleg,
       tpcustei,
       vlcomiss,
       tpadesao,
       limitdps,
       nrapolic,
       enderftp,
       loginftp,
       senhaftp,
       flgelepf,
       flginden,
       idadedps,
       pagsegu,
       seqarqu,
       dtinivigencia,
       dtfimvigencia,
       lminsoci,
       dtctrmista)
    values
      (vidseqpar_seq,
       rw_parametros.cdcooper,
       rw_parametros.tppessoa,
       rw_parametros.cdsegura,
       rw_parametros.tpdpagto,
       rw_parametros.modalida,
       rw_parametros.qtparcel,
       rw_parametros.piedias,
       rw_parametros.pieparce,
       rw_parametros.pielimit,
       rw_parametros.pietaxa,
       rw_parametros.ifttdias,
       rw_parametros.ifttparc,
       rw_parametros.ifttlimi,
       rw_parametros.iftttaxa,
       rw_parametros.lmpseleg,
       rw_parametros.tpcustei,
       rw_parametros.vlcomiss,
       rw_parametros.tpadesao,
       rw_parametros.limitdps,
       rw_parametros.nrapolic,
       rw_parametros.enderftp,
       rw_parametros.loginftp,
       rw_parametros.senhaftp,
       rw_parametros.flgelepf,
       rw_parametros.flginden,
       rw_parametros.idadedps,
       rw_parametros.pagsegu,
       rw_parametros.seqarqu,
       rw_parametros.dtinivigencia,
       rw_parametros.dtfimvigencia,
       rw_parametros.lminsoci,
       rw_parametros.dtctrmista);
  
    for rw_cap in cr_cap(rw_parametros.idseqpar) loop
      insert into cecred.tbseg_param_prst_cap_seg
        (idseqpar, idademin, idademax, capitmin, capitmax)
      values
        (vidseqpar_seq,
         rw_cap.idademin,
         rw_cap.idademax,
         rw_cap.capitmin,
         rw_cap.capitmax);
    end loop;
  
    for rw_cobp in cr_cob(rw_parametros.idseqpar) loop
      insert into cecred.tbseg_param_prst_tax_cob
        (idseqpar, gbidamin, gbidamax, gbsegmin, gbsegmax)
      values
        (vidseqpar_seq,
         rw_cobp.gbidamin,
         rw_cobp.gbidamax,
         rw_cobp.gbsegmin,
         rw_cobp.gbsegmax);
    end loop;
    
    update cecred.tbseg_parametros_prst p set p.dtfimvigencia = to_date('03/03/2024','dd/mm/yyyy') where p.idseqpar = rw_parametros.idseqpar; 
    
    update cecred.tbseg_nrproposta p set p.dhseguro = sysdate where p.dhseguro is null and p.tpcustei = 1 and p.nrproposta in ('770355059219','770353828525','770353828282','770349014165');
    update cecred.tbseg_nrproposta p set p.dhseguro = sysdate where p.dhseguro is null and p.tpcustei = 1 and p.nrproposta between '202213696426' and '202319716576';   
    
  end loop;
  commit;
exception
  when others then   
    null;
end;
