declare
  cursor c1 is
    select c.cdcooper
         , c.dtmvtolt
         , c.cdagenci
         , c.cdbccxlt
         , c.nrdolote
         , c.nrseqdig
      from craplot c
         , crapdat x
     where c.cdcooper = x.cdcooper
       and c.dtmvtolt = x.dtmvtolt
       and c.nrseqdig > 0;

  vr_dschave varchar2(200);
begin
  begin
    insert into crapsqt(nmtabela, nmdcampo, dsdchave, flgciclo, qtincrem, qtmaxseq) values ('CRAPLOT', 'NRSEQDIG', 'CDCOOPER;DTMVTOLT;CDAGENCI;CDBCCXLT;NRDOLOTE',0,1,999999999999999);
  exception
    when dup_val_on_index then
      null;
    when others then
      raise_application_error(-20001,'Erro ao criar sequencia - Contactar o analista responsavel');
  end;
  
  for r1 in c1 loop
    vr_dschave := r1.cdcooper||';'||to_char(r1.dtmvtolt,'DD/MM/RRRR')||';'||r1.cdagenci||';'||r1.cdbccxlt||';'||r1.nrdolote;
    
    begin
      insert into crapsqu(nmtabela, nmdcampo, dsdchave, nrseqatu) values ('CRAPLOT', 'NRSEQDIG', vr_dschave, r1.nrseqdig);
    exception
      when dup_val_on_index then
        update crapsqu c
           set c.nrseqatu = greatest(r1.nrseqdig,c.nrseqatu)
         where upper(c.nmtabela) = 'CRAPLOT'
           and upper(c.nmdcampo) = 'NRSEQDIG'
           and upper(c.dsdchave) = vr_dschave;
      when others then
        dbms_output.put_line('Erro - '||sqlerrm);
    end;
    
    commit;
  end loop;
end;
/
