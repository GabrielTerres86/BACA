/*Atualização das Sequences para criação da LEM*/
declare
 cursor c1 is
  select l.cdcooper,
         l.dtmvtolt,
         l.cdagenci,
         l.cdbccxlt,
         l.nrdolote,
         max(l.nrseqdig) nrseqdig
    from craplem l,
         crapdat d
   where l.dtmvtolt = d.dtmvtolt   
     and l.cdcooper = d.cdcooper
   group by l.cdcooper,
            l.dtmvtolt,
            l.cdagenci,
            l.cdbccxlt,
            l.nrdolote;

 vr_nrseqdig number;
begin
  

 for r1 in c1 loop
 
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
     dbms_output.put_line('Lote: '||to_char(r1.nrdolote));
     commit;
 end loop;

end;
