/*Atualização das Sequences para criação da LEM*/
declare
 cursor c1(pr_cop in number,pr_data in date) is
  select l.cdcooper,
         l.dtmvtolt,
         l.cdagenci,
         l.cdbccxlt,
         l.nrdolote,
         t.nrseqdig
    from craplem l,
         craplot t
   where l.nrdolote = t.nrdolote
     and l.cdhistor = t.cdhistor
     and l.dtmvtolt = t.dtmvtolt
     and l.cdcooper = t.cdcooper
     and l.nrseqdig = t.nrseqdig
     and l.dtmvtolt = pr_data   
     and l.cdcooper = pr_cop
   group by l.cdcooper,
            l.dtmvtolt,
            l.cdagenci,
            l.cdbccxlt,
            l.nrdolote,
            t.nrseqdig;

 vr_nrseqdig number;
 rw_crapdat btch0001.cr_crapdat%ROWTYPE;    
begin
  
for r_cop in (select cdcooper from crapcop) loop

 dbms_output.put_line('INICIO Coop: '||r_cop.cdcooper );

 OPEN btch0001.cr_crapdat(pr_cdcooper => r_cop.cdcooper);
   FETCH btch0001.cr_crapdat INTO rw_crapdat;
 CLOSE btch0001.cr_crapdat; 
  
 dbms_output.put_line('Data: '||to_char(rw_crapdat.dtmvtolt,'DD/MM/YYYY') );
 
 for r1 in c1(r_cop.cdcooper,rw_crapdat.dtmvtolt) loop
 
    /*Iniciando a Sequence*/
    vr_nrseqdig := FN_SEQUENCE(pr_nmtabela => 'CRAPLOT'
                              ,pr_nmdcampo => 'NRSEQDIG'
                              ,pr_dsdchave => to_char(r1.cdcooper)||';'||
                               to_char(r1.dtmvtolt, 'DD/MM/RRRR')||';'||
                               to_char(r1.cdagenci)||';'||
                               to_char(r1.cdbccxlt)||';'||
                               to_char(r1.nrdolote));    
     begin
        update crapsqu
           set nrseqatu = r1.nrseqdig+1
         where UPPER(nmtabela) = 'CRAPLOT'
           and UPPER(nmdcampo) = 'NRSEQDIG'
           and UPPER(dsdchave) = to_char(r1.cdcooper)||';'||
                                 to_char(r1.dtmvtolt, 'DD/MM/RRRR')||';'||
                                 to_char(r1.cdagenci)||';'||
                                 to_char(r1.cdbccxlt)||';'||
                                 to_char(r1.nrdolote);
     exception
        when others then
         rollback;
         dbms_output.put_line('Erro ao atualizar crapsqu: '||sqlerrm );
     end;
     commit;
     dbms_output.put_line('Lote: '||to_char(r1.nrdolote));
 end loop;
 dbms_output.put_line('FIM: '||vr_count );
end loop; 
end;
