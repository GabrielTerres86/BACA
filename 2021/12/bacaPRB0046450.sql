BEGIN


delete from   cecred.tbcapt_custodia_arquivo e			
where  e.idtipo_operacao = 'E'         
and    e.idsituacao      <> 0                         
and    e.idtipo_arquivo  <> 9                         
and    e.dtprocesso      is not null                  
and    e.dtprocesso      > to_date('01/01/2019')
and    e.dtregistro      = to_date('25/06/2021')
and    not exists 
            ( select  1 from cecred.tbcapt_custodia_arquivo r 
              where   r.idarquivo_origem = e.idarquivo );

update cecred.tbcapt_custodia_lanctos  
set idsituacao = 8
where idlancamento = 30395124;
			  

merge into cecred.tbcapt_custodia_lanctos t1
using (
  select lct.*, 
         count(1) over(partition by lct.cdcooper, lct.idtipo_arquivo, lct.dtregistro) qtregis,
         row_number() over(partition by lct.cdcooper, lct.idtipo_arquivo, lct.dtregistro order by lct.cdcooper, lct.idtipo_arquivo, lct.dtregistro) nrseqreg
    from (select rda.cdcooper,
                 rda.nrdconta,
                 rda.nraplica,
                 0 cdprodut,
                 lct.*
            from cecred.craprda                   rda,
                 cecred.tbcapt_custodia_aplicacao apl,
                 cecred.tbcapt_custodia_lanctos   lct
           where apl.idaplicacao = lct.idaplicacao
             and rda.idaplcus = apl.idaplicacao
             and lct.idsituacao = 1
             and apl.tpaplicacao in (1, 2)
             and lct.idtipo_arquivo <> 9
             and ((lct.idtipo_lancto = 2 and rda.cdcooper in (2,5,6,7,8)) or
                  (lct.idtipo_lancto = 1 and rda.cdcooper in (2,5,6,7,8,9) and nvl(rda.insaqtot,0) = 0))
             and trunc(lct.dtregistro) = to_date('25/06/2021','dd/mm/yyyy')
          union
          select rac.cdcooper,
                 rac.nrdconta,
                 rac.nraplica,
                 rac.cdprodut,
                 lct.*
            from cecred.craprac                   rac,
                 cecred.tbcapt_custodia_aplicacao apl,
                 cecred.tbcapt_custodia_lanctos   lct
           where apl.idaplicacao = lct.idaplicacao
             and rac.idaplcus = apl.idaplicacao
             and lct.idsituacao = 1
             and apl.tpaplicacao in (3, 4)
             and lct.idtipo_arquivo <> 9
             and ((lct.idtipo_lancto = 2 and rac.cdcooper in (2,5,6,7,8)) or
                  (lct.idtipo_lancto = 1 and rac.cdcooper in (2,5,6,7,8,9) and nvl(rac.idsaqtot,0) = 0))
             and trunc(lct.dtregistro) = to_date('25/06/2021','dd/mm/yyyy')) lct
         WHERE (lct.idlancto_origem is null or
                exists (select 1
                          from cecred.tbcapt_custodia_lanctos lctori
                         where lctori.idlancamento = lct.idlancto_origem
                           and lctori.idsituacao = 8
                           and lctori.cdoperac_cetip is not null))
 order by cdcooper, lct.idtipo_lancto, lct.idaplicacao, lct.nrdconta  	
	
	
COMMIT;	

END;