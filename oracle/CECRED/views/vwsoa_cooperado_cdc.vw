CREATE OR REPLACE VIEW CECRED.VWSOA_COOPERADO_CDC AS
   select cdc.cdcooper
         ,cdc.idcooperado_cdc
         ,cdc.idmatriz
         ,ass.nmprimtl
         ,cdc.nmfantasia         
         ,case when ass.inpessoa <> 1
               /* Pessoa jurídica devemos buscar o CNAE da crapass */
               then ass.cdclcnae
               /* Quando tiver uma matriz, buscar o CNAE da matriz */  
               else nvl(mtz.cdcnae,cdc.cdcnae)
           end cdcnae
         ,cna.dscnae
         ,cdc.dslogradouro
         ,cdc.dscomplemento
         ,cdc.idcidade
         ,mun.cdestado
         ,mun.dscidesp
         ,cdc.nmbairro
         ,cdc.nrendereco
         ,cdc.nrcep
         ,cdc.dstelefone
         ,cdc.dsemail
         ,cdc.dslink_google_maps
     from tbsite_cooperado_cdc cdc
     join crapass ass
       on ass.cdcooper = cdc.cdcooper
      and ass.nrdconta = cdc.nrdconta
     join crapcdr cdr
       on cdr.cdcooper = ass.cdcooper
      and cdr.nrdconta = ass.nrdconta
      and cdr.flgconve = 1 /* Esta configurado como conveniado CDC */
left join crapmun mun
       on mun.idcidade = cdc.idcidade
left join tbsite_cooperado_cdc mtz
       on mtz.idcooperado_cdc = cdc.idmatriz
left join tbgen_cnae cna
       on cna.cdcnae = case when ass.inpessoa <> 1
                            /* Pessoa jurídica devemos buscar o CNAE da crapass */
                            then ass.cdclcnae
                            /* Quando tiver uma matriz, buscar o CNAE da matriz */  
                            else nvl(mtz.cdcnae,cdc.cdcnae)
                        end
    where ass.dtdemiss is null