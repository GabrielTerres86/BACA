insert into crapaca (nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
             values ('INSERIRCONVENIOTED','PGTA0001','pc_inserir_convenio_ted','pr_cdcooper, pr_nrdconta, pr_tpconvenio, pr_cdoperad',886);
             
         
insert into crapaca (nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
             values ('ALTERARCONVENIOTED','PGTA0001','pc_alterar_convenio_ted','pr_nrdconta, pr_nrcontpj, pr_flghomol',886);
             
insert into crapaca (nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
             values ('CONSULTARCONVENIOTED','PGTA0001','pc_consultar_convenio_ted','pr_cdcooper, pr_nrdconta',886);


insert into crapaca (nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
             values ('BLOQUEARCONVENIOTED','PGTA0001','pc_bloqueia_convenio_ted','pr_nrdconta, pr_nrcontpj, pr_flgbloqueio, pr_dsmotivo',886);
   
insert into crapaca (nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
             values ('CONSULTABLQCONVENIOTED','PGTA0001','pc_consulta_blq_convenio_ted','pr_cdcooper, pr_nrdconta, pr_nrcontpj',886);  
          

insert into crapaca (nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
             values ('CONSULTATEDADESAO','PGTA0001','pc_consulta_adesao_atenda','pr_cdcooper, pr_nrdconta, pr_cdproduto',886);  
commit;
