PL/SQL Developer Test script 3.0
146
-- Created on 01/10/2019 by F0032386 
declare 
  

  cursor cr_craplcm is
    select x.rowid, x.*
      from craplcm x
     where x.cdcooper = 1
       and x.nrdconta in (1989103, 3721701, 9463518, 10464328)
       and x.cdhistor = 15
       and x.dtmvtolt = '30/09/2019';
       
  vr_nrseqdig number;       


begin
  
  for rw_craplcm in cr_craplcm loop
    
    vr_nrseqdig := null;
  
    begin
      update craplot lot
         set lot.vlcompcr = lot.vlcompcr - rw_craplcm.vllanmto,
             lot.vlinfocr = lot.vlcompcr - rw_craplcm.vllanmto            
       where lot.CDCOOPER = rw_craplcm.cdcooper
         and lot.DTMVTOLT = rw_craplcm.dtmvtolt
         and lot.CDAGENCI = rw_craplcm.cdagenci       
         and lot.CDBCCXLT = rw_craplcm.cdbccxlt
         and lot.NRDOLOTE = rw_craplcm.nrdolote;

      update craplot lot
         set lot.vlcompcr = lot.vlcompcr + rw_craplcm.vllanmto,
             lot.vlinfocr = lot.vlcompcr + rw_craplcm.vllanmto,
             lot.nrseqdig = lot.nrseqdig + 1
       where lot.CDCOOPER = rw_craplcm.cdcooper
         and lot.DTMVTOLT = to_date('01/10/2019','DD/MM/RRRR')
         and lot.CDAGENCI = rw_craplcm.cdagenci       
         and lot.CDBCCXLT = rw_craplcm.cdbccxlt
         and lot.NRDOLOTE = rw_craplcm.nrdolote
         returning lot.nrseqdig into  vr_nrseqdig;
       
       if sql%rowcount = 0 then
         raise_application_error(-20500,'Não localizado registro de lote');         
       end if;    
         
         
    exception   
      when others then
        raise_application_error(-20500,'Erro ao atualizar lote lcm.rowid'|| rw_craplcm.rowid ||'Sqlerrm:' || sqlerrm );
    end;
  
  
    begin
    
      insert into craplcm
          ( dtmvtolt, 
            cdagenci, 
            cdbccxlt, 
            nrdolote, 
            nrdconta, 
            nrdocmto, 
            cdhistor, 
            nrseqdig, 
            vllanmto, 
            nrdctabb, 
            cdpesqbb, 
            vldoipmf, 
            nrautdoc, 
            nrsequni, 
            cdbanchq, 
            cdcmpchq, 
            cdagechq, 
            nrctachq, 
            nrlotchq, 
            sqlotchq, 
            dtrefere, 
            hrtransa, 
            cdoperad, 
            dsidenti, 
            cdcooper, 
            nrdctitg, 
            dscedent, 
            cdcoptfn, 
            cdagetfn, 
            nrterfin, 
            nrparepr, 
            nrseqava, 
            nraplica, 
            cdorigem, 
            idlautom)
          select  to_date('01/10/2019','DD/MM/RRRR'), 
            cdagenci, 
            cdbccxlt, 
            nrdolote, 
            nrdconta, 
            nrdocmto, 
            cdhistor, 
            vr_nrseqdig, 
            vllanmto, 
            nrdctabb, 
            cdpesqbb, 
            vldoipmf, 
            nrautdoc, 
            nrsequni, 
            cdbanchq, 
            cdcmpchq, 
            cdagechq, 
            nrctachq, 
            nrlotchq, 
            sqlotchq, 
            dtrefere, 
            hrtransa, 
            cdoperad, 
            dsidenti, 
            cdcooper, 
            nrdctitg, 
            dscedent, 
            cdcoptfn, 
            cdagetfn, 
            nrterfin, 
            nrparepr, 
            nrseqava, 
            nraplica, 
            cdorigem, 
            idlautom
            from  craplcm l
       where l.rowid = rw_craplcm.rowid;    
      
    
     delete craplcm l
       where l.rowid = rw_craplcm.rowid; 
    
    exception
        when others then
          raise_application_error(-20500,'Erro ao atualizar lançamento '||rw_craplcm.rowid  ||'Sqlerrm:' || sqlerrm );
    end;
    
    
  end loop;  

  commit;

end;


0
0
