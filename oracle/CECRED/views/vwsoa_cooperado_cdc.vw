create or replace view cecred.vwsoa_cooperado_cdc as
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
         ,cdc.nrlatitude
         ,cdc.nrlongitude
         ,listagg(sub.cdsubsegmento,';') WITHIN GROUP(ORDER BY cdc.idcooperado_cdc) cdsubsegmento_list
         ,listagg(sub.dssubsegmento,';') WITHIN GROUP(ORDER BY cdc.idcooperado_cdc) dssubsegmento_list
         ,listagg(seg.cdsegmento,';') WITHIN GROUP(ORDER BY cdc.idcooperado_cdc) cdsegmento_list
         ,listagg(seg.dssegmento,';') WITHIN GROUP(ORDER BY cdc.idcooperado_cdc) dssegmento_list
         ,listagg(seg.tpproduto,';') WITHIN GROUP(ORDER BY cdc.idcooperado_cdc) tpproduto_list
         ,listagg(sub.cdsegmento||','||(select xseg.dssegmento from tbepr_cdc_segmento xseg where sub.cdsegmento=xseg.cdsegmento) || ':' || sub.cdsubsegmento || ',' || sub.dssubsegmento, ';') WITHIN GROUP(ORDER BY cdc.idcooperado_cdc) segmentos_lojista_list
     from tbsite_cooperado_cdc cdc
     join crapass ass on ass.cdcooper = cdc.cdcooper and ass.nrdconta = cdc.nrdconta
     join crapcdr cdr on cdr.cdcooper = ass.cdcooper and cdr.nrdconta = ass.nrdconta and cdr.flgconve = 1 /* Esta configurado como conveniado CDC */
     left join crapmun mun on mun.idcidade = cdc.idcidade left join tbsite_cooperado_cdc mtz on mtz.idcooperado_cdc = cdc.idmatriz
     left join tbgen_cnae cna on cna.cdcnae = case when ass.inpessoa <> 1
                            /* Pessoa jurídica devemos buscar o CNAE da crapass */
                            then ass.cdclcnae
                            /* Quando tiver uma matriz, buscar o CNAE da matriz */
                            else nvl(mtz.cdcnae,cdc.cdcnae)
                        end
      left join tbepr_cdc_lojista_subseg loj on loj.idcooperado_cdc=cdc.idcooperado_cdc
      left join tbepr_cdc_subsegmento sub on sub.cdsubsegmento=loj.cdsubsegmento
      left join tbepr_cdc_segmento seg on seg.cdsegmento=sub.cdsegmento
    where ass.dtdemiss is null
    group by cdc.cdcooper
            ,cdc.idcooperado_cdc
            ,cdc.idmatriz
            ,ass.nmprimtl
            ,cdc.nmfantasia
            ,case when ass.inpessoa <> 1 /* Pessoa jurídica devemos buscar o CNAE da crapass */  then ass.cdclcnae /* Quando tiver uma matriz, buscar o CNAE da matriz */  else nvl(mtz.cdcnae,cdc.cdcnae) end
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
            ,cdc.nrlatitude
            ,cdc.nrlongitude
