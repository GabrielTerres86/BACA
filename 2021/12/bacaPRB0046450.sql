begin

--arquivo baca

delete from   cecred.tbcapt_custodia_arquivo e			--Deletar arquivos de monitoramento, pois serao reenviados
where  e.idtipo_operacao = 'E'         
and    e.idsituacao      <> 0                         -- processamento
and    e.idtipo_arquivo  <> 9                         -- ignorar arquivos de conciliação
and    e.dtprocesso      is not null                  -- com data de processo
and    e.dtprocesso      > to_date('01/01/2019')
and    e.dtregistro between to_date('25/06/2021') and to_date('28/06/2021')
and    not exists 
            ( select  1 from cecred.tbcapt_custodia_arquivo r 
              where   r.idarquivo_origem = e.idarquivo );

update cecred.tbcapt_custodia_lanctos  --Lançamento com cota negativa que ocorre erro, porem ja foi resgatado na B3
set idsituacao = 8
where idlancamento = 30395124;
			  
--UP

merge into cecred.tbcapt_custodia_lanctos t1
using (--cooper 2
 select lct.*, 
               count(1) over(partition by lct.cdcooper, lct.idtipo_arquivo, lct.dtregistro) qtregis,
               row_number() over(partition by lct.cdcooper, lct.idtipo_arquivo, lct.dtregistro order by lct.cdcooper, lct.idtipo_arquivo, lct.dtregistro) nrseqreg
          from (
                -- Registros ligados a RDC PRé e Pós
                select /*+ index (lct cecred.tbcapt_custodia_lanctos_idx01) */
                       rda.cdcooper,
                       rda.nrdconta,
                       rda.nraplica,
                       0 cdprodut,
                       lct.*
                  from cecred.craprda                   rda,
                       cecred.tbcapt_custodia_aplicacao apl,
                       cecred.tbcapt_custodia_lanctos   lct
                 where 1=1
                  and lct.idsituacao =1
                   and apl.idaplicacao = lct.idaplicacao
                   and apl.tpaplicacao in (1, 2) -- RDC PRé e Pós
                   and rda.idaplcus = apl.idaplicacao
				 and rda.cdcooper = 2
				  and lct.idtipo_arquivo <> 9 -- Não trazer COnciliação
                  and lct.IDTIPO_LANCTO = 2					 
                                    and trunc(lct.dtregistro) between to_date('25/06/2021','dd/mm/yyyy') and to_date('25/06/2021','dd/mm/yyyy')
                union
                -- Registros ligados a novo produto de Captação
                select /*+ index (lct cecred.tbcapt_custodia_lanctos_idx01) */
                       rac.cdcooper,
                       rac.nrdconta,
                       rac.nraplica,
                       rac.cdprodut,
                       lct.*
                  from cecred.craprac                   rac,
                       cecred.tbcapt_custodia_aplicacao apl,
                       cecred.tbcapt_custodia_lanctos   lct
                   where 1=1
                   and lct.idsituacao =1  
                   and apl.idaplicacao = lct.idaplicacao
                   and apl.tpaplicacao in (3, 4) -- PCAPTA Pré e Pós
                   and rac.idaplcus = apl.idaplicacao
				   and rac.cdcooper = 2
				  and lct.idtipo_arquivo <> 9 -- Não trazer COnciliação
                  and lct.IDTIPO_LANCTO = 2				   
                 and trunc(lct.dtregistro) between to_date('25/06/2021','dd/mm/yyyy') and to_date('25/06/2021','dd/mm/yyyy')
               ) lct
         WHERE 1=1
and lct.IDTIPO_LANCTO = 2
and ((lct.nrdconta = 653411  and  lct.nraplica = 2       )
or (lct.nrdconta = 647047  and  lct.nraplica = 2       )
or (lct.nrdconta = 467162  and  lct.nraplica = 6       )
or (lct.nrdconta = 669164  and  lct.nraplica = 6       )
or (lct.nrdconta = 669164  and  lct.nraplica = 7       )
or (lct.nrdconta = 638323  and  lct.nraplica = 8       )
or (lct.nrdconta = 669164  and  lct.nraplica = 8       )
or (lct.nrdconta = 729930  and  lct.nraplica = 1       )
or (lct.nrdconta = 560847  and  lct.nraplica = 46     )
or (lct.nrdconta = 669164  and  lct.nraplica = 9       )
or (lct.nrdconta = 560847  and  lct.nraplica = 47     )
or (lct.nrdconta = 669164  and  lct.nraplica = 10     )
or (lct.nrdconta = 166480  and  lct.nraplica = 65     )
or (lct.nrdconta = 166480  and  lct.nraplica = 65     )
or (lct.nrdconta = 166480  and  lct.nraplica = 65     )
or (lct.nrdconta = 166480  and  lct.nraplica = 65     )
or (lct.nrdconta = 560847  and  lct.nraplica = 48     )
or (lct.nrdconta = 401188  and  lct.nraplica = 10     )
or (lct.nrdconta = 560847  and  lct.nraplica = 49     )
or (lct.nrdconta = 669164  and  lct.nraplica = 11     )
or (lct.nrdconta = 669164  and  lct.nraplica = 12     )
or (lct.nrdconta = 429686  and  lct.nraplica = 129   )
or (lct.nrdconta = 633178  and  lct.nraplica = 18     )
or (lct.nrdconta = 429686  and  lct.nraplica = 131   )
or (lct.nrdconta = 559202  and  lct.nraplica = 11     )
or (lct.nrdconta = 559202  and  lct.nraplica = 11     )
or (lct.nrdconta = 429686  and  lct.nraplica = 132   )
or (lct.nrdconta = 652334  and  lct.nraplica = 4       )
or (lct.nrdconta = 730530  and  lct.nraplica = 23     )
or (lct.nrdconta = 499994  and  lct.nraplica = 19     )
or (lct.nrdconta = 669164  and  lct.nraplica = 13     )
or (lct.nrdconta = 560847  and  lct.nraplica = 50     )
or (lct.nrdconta = 633178  and  lct.nraplica = 19     )
or (lct.nrdconta = 633178  and  lct.nraplica = 19     )
or (lct.nrdconta = 633178  and  lct.nraplica = 19     )
or (lct.nrdconta = 633178  and  lct.nraplica = 19     )
or (lct.nrdconta = 520616  and  lct.nraplica = 13     )
or (lct.nrdconta = 669164  and  lct.nraplica = 14     )
or (lct.nrdconta = 829846  and  lct.nraplica = 1       )
or (lct.nrdconta = 520616  and  lct.nraplica = 14     )
or (lct.nrdconta = 633178  and  lct.nraplica = 20     )
or (lct.nrdconta = 633178  and  lct.nraplica = 20     )
or (lct.nrdconta = 633178  and  lct.nraplica = 20     )
or (lct.nrdconta = 633178  and  lct.nraplica = 20     )
or (lct.nrdconta = 382833  and  lct.nraplica = 83     )
or (lct.nrdconta = 669164  and  lct.nraplica = 15     )
or (lct.nrdconta = 559202  and  lct.nraplica = 12     )
or (lct.nrdconta = 560847  and  lct.nraplica = 51     )
or (lct.nrdconta = 520616  and  lct.nraplica = 15     )
or (lct.nrdconta = 382833  and  lct.nraplica = 85     )
or (lct.nrdconta = 633178  and  lct.nraplica = 21     )
or (lct.nrdconta = 633178  and  lct.nraplica = 21     )
or (lct.nrdconta = 633178  and  lct.nraplica = 21     )
or (lct.nrdconta = 669164  and  lct.nraplica = 16     )
or (lct.nrdconta = 619701  and  lct.nraplica = 65     )
or (lct.nrdconta = 408433  and  lct.nraplica = 13     )
or (lct.nrdconta = 515850  and  lct.nraplica = 24     )
or (lct.nrdconta = 840670  and  lct.nraplica = 1       )
or (lct.nrdconta = 559202  and  lct.nraplica = 13     )
or (lct.nrdconta = 842079  and  lct.nraplica = 1       )
or (lct.nrdconta = 520616  and  lct.nraplica = 16     )
or (lct.nrdconta = 382833  and  lct.nraplica = 87     )
or (lct.nrdconta = 633178  and  lct.nraplica = 22     )
or (lct.nrdconta = 633178  and  lct.nraplica = 22     )
or (lct.nrdconta = 669164  and  lct.nraplica = 17     )
or (lct.nrdconta = 842060  and  lct.nraplica = 1       )
or (lct.nrdconta = 627500  and  lct.nraplica = 31     )
or (lct.nrdconta = 619701  and  lct.nraplica = 68     )
or (lct.nrdconta = 559202  and  lct.nraplica = 14     )
or (lct.nrdconta = 392073  and  lct.nraplica = 18     )
or (lct.nrdconta = 845230  and  lct.nraplica = 1       )
or (lct.nrdconta = 520616  and  lct.nraplica = 17     )
or (lct.nrdconta = 382833  and  lct.nraplica = 89     )
or (lct.nrdconta = 858617  and  lct.nraplica = 1       )
or (lct.nrdconta = 520616  and  lct.nraplica = 18     )
or (lct.nrdconta = 590401  and  lct.nraplica = 7       )
or (lct.nrdconta = 590401  and  lct.nraplica = 7       )
or (lct.nrdconta = 619701  and  lct.nraplica = 71     )
or (lct.nrdconta = 852236  and  lct.nraplica = 1       )
or (lct.nrdconta = 669164  and  lct.nraplica = 18     )
or (lct.nrdconta = 822582  and  lct.nraplica = 1       )
or (lct.nrdconta = 822582  and  lct.nraplica = 2       )
or (lct.nrdconta = 627500  and  lct.nraplica = 33     )
or (lct.nrdconta = 822582  and  lct.nraplica = 3       )
or (lct.nrdconta = 560847  and  lct.nraplica = 52     )
or (lct.nrdconta = 520616  and  lct.nraplica = 19     )
or (lct.nrdconta = 520616  and  lct.nraplica = 20     )
or (lct.nrdconta = 619701  and  lct.nraplica = 72     )
or (lct.nrdconta = 811297  and  lct.nraplica = 7       )
or (lct.nrdconta = 669164  and  lct.nraplica = 19     )
or (lct.nrdconta = 737453  and  lct.nraplica = 14     )
or (lct.nrdconta = 627500  and  lct.nraplica = 35     )
or (lct.nrdconta = 559202  and  lct.nraplica = 15     )
or (lct.nrdconta = 559202  and  lct.nraplica = 15     )
or (lct.nrdconta = 822582  and  lct.nraplica = 4       )
or (lct.nrdconta = 560847  and  lct.nraplica = 53     )
or (lct.nrdconta = 885738  and  lct.nraplica = 1       )
or (lct.nrdconta = 269000  and  lct.nraplica = 36     )
or (lct.nrdconta = 861820  and  lct.nraplica = 1       )
or (lct.nrdconta = 520616  and  lct.nraplica = 22     )
or (lct.nrdconta = 852236  and  lct.nraplica = 2       )
or (lct.nrdconta = 727288  and  lct.nraplica = 17     )
or (lct.nrdconta = 885738  and  lct.nraplica = 2       )
or (lct.nrdconta = 811297  and  lct.nraplica = 8       )
or (lct.nrdconta = 669164  and  lct.nraplica = 20     )
or (lct.nrdconta = 619701  and  lct.nraplica = 74     )
or (lct.nrdconta = 883891  and  lct.nraplica = 1       )
or (lct.nrdconta = 737453  and  lct.nraplica = 15     )
or (lct.nrdconta = 852236  and  lct.nraplica = 3       )
or (lct.nrdconta = 456730  and  lct.nraplica = 25     )
or (lct.nrdconta = 883891  and  lct.nraplica = 2       )
or (lct.nrdconta = 852236  and  lct.nraplica = 4       )
or (lct.nrdconta = 811297  and  lct.nraplica = 9       )
or (lct.nrdconta = 619701  and  lct.nraplica = 77     )
or (lct.nrdconta = 737453  and  lct.nraplica = 16     )
or (lct.nrdconta = 669164  and  lct.nraplica = 21     )
or (lct.nrdconta = 894168  and  lct.nraplica = 3       )
or (lct.nrdconta = 559202  and  lct.nraplica = 16     )
or (lct.nrdconta = 887986  and  lct.nraplica = 5       )
or (lct.nrdconta = 825417  and  lct.nraplica = 6       )
or (lct.nrdconta = 627500  and  lct.nraplica = 38     )
or (lct.nrdconta = 523968  and  lct.nraplica = 10     )
or (lct.nrdconta = 695858  and  lct.nraplica = 41     )
or (lct.nrdconta = 900133  and  lct.nraplica = 3       )
or (lct.nrdconta = 196444  and  lct.nraplica = 20     )
or (lct.nrdconta = 753947  and  lct.nraplica = 13     )
or (lct.nrdconta = 752126  and  lct.nraplica = 1       )
or (lct.nrdconta = 752126  and  lct.nraplica = 1       )
or (lct.nrdconta = 269000  and  lct.nraplica = 40     )
or (lct.nrdconta = 316261  and  lct.nraplica = 80     )
or (lct.nrdconta = 316261  and  lct.nraplica = 80     )
or (lct.nrdconta = 290734  and  lct.nraplica = 213   )
or (lct.nrdconta = 456730  and  lct.nraplica = 26     )
or (lct.nrdconta = 669164  and  lct.nraplica = 22     )
or (lct.nrdconta = 852236  and  lct.nraplica = 5       )
or (lct.nrdconta = 596809  and  lct.nraplica = 29     )
or (lct.nrdconta = 811297  and  lct.nraplica = 10     )
or (lct.nrdconta = 619701  and  lct.nraplica = 79     )
or (lct.nrdconta = 269000  and  lct.nraplica = 42     )
or (lct.nrdconta = 627500  and  lct.nraplica = 40     )
or (lct.nrdconta = 883891  and  lct.nraplica = 3       )
or (lct.nrdconta = 900133  and  lct.nraplica = 4       )
or (lct.nrdconta = 290734  and  lct.nraplica = 214   )
or (lct.nrdconta = 159808  and  lct.nraplica = 99     )
or (lct.nrdconta = 456730  and  lct.nraplica = 27     )
or (lct.nrdconta = 883891  and  lct.nraplica = 4       )
or (lct.nrdconta = 669164  and  lct.nraplica = 23     )
or (lct.nrdconta = 852236  and  lct.nraplica = 6       )
or (lct.nrdconta = 811297  and  lct.nraplica = 11     )
or (lct.nrdconta = 619701  and  lct.nraplica = 81     )
or (lct.nrdconta = 596809  and  lct.nraplica = 30     )
or (lct.nrdconta = 800201  and  lct.nraplica = 13     )
or (lct.nrdconta = 559202  and  lct.nraplica = 17     )
or (lct.nrdconta = 727318  and  lct.nraplica = 31     )
or (lct.nrdconta = 881538  and  lct.nraplica = 7       )
or (lct.nrdconta = 737453  and  lct.nraplica = 17     )
or (lct.nrdconta = 825417  and  lct.nraplica = 7       )
or (lct.nrdconta = 900133  and  lct.nraplica = 5       )
or (lct.nrdconta = 591041  and  lct.nraplica = 53     )
or (lct.nrdconta = 591041  and  lct.nraplica = 53     )
or (lct.nrdconta = 627500  and  lct.nraplica = 42     )
or (lct.nrdconta = 896500  and  lct.nraplica = 19     )
or (lct.nrdconta = 752126  and  lct.nraplica = 2       )
or (lct.nrdconta = 785270  and  lct.nraplica = 4       )
or (lct.nrdconta = 661040  and  lct.nraplica = 36     )
or (lct.nrdconta = 731242  and  lct.nraplica = 19     )
or (lct.nrdconta = 659746  and  lct.nraplica = 25     )
or (lct.nrdconta = 896500  and  lct.nraplica = 20     )
or (lct.nrdconta = 403105  and  lct.nraplica = 88     )
or (lct.nrdconta = 919896  and  lct.nraplica = 2       )
or (lct.nrdconta = 874841  and  lct.nraplica = 1       )
or (lct.nrdconta = 669164  and  lct.nraplica = 24     )
or (lct.nrdconta = 596809  and  lct.nraplica = 31     )
or (lct.nrdconta = 627500  and  lct.nraplica = 43     )
or (lct.nrdconta = 843377  and  lct.nraplica = 2       )
or (lct.nrdconta = 843377  and  lct.nraplica = 2       )
or (lct.nrdconta = 852236  and  lct.nraplica = 7       )
or (lct.nrdconta = 619701  and  lct.nraplica = 83     )
or (lct.nrdconta = 811297  and  lct.nraplica = 12     )
or (lct.nrdconta = 719838  and  lct.nraplica = 5       )
or (lct.nrdconta = 746487  and  lct.nraplica = 161   )
or (lct.nrdconta = 515850  and  lct.nraplica = 39     )
or (lct.nrdconta = 644943  and  lct.nraplica = 60     )
or (lct.nrdconta = 825417  and  lct.nraplica = 8       )
or (lct.nrdconta = 627500  and  lct.nraplica = 45     )
or (lct.nrdconta = 752126  and  lct.nraplica = 3       )
or (lct.nrdconta = 515850  and  lct.nraplica = 40     )
or (lct.nrdconta = 515850  and  lct.nraplica = 41     )
or (lct.nrdconta = 896500  and  lct.nraplica = 21     )
or (lct.nrdconta = 896500  and  lct.nraplica = 21     )
or (lct.nrdconta = 896500  and  lct.nraplica = 22     )
or (lct.nrdconta = 896500  and  lct.nraplica = 22     )
or (lct.nrdconta = 904414  and  lct.nraplica = 5       )
or (lct.nrdconta = 659746  and  lct.nraplica = 26     )
or (lct.nrdconta = 642819  and  lct.nraplica = 10     )
or (lct.nrdconta = 642819  and  lct.nraplica = 10     )
or (lct.nrdconta = 642819  and  lct.nraplica = 10     )
or (lct.nrdconta = 642819  and  lct.nraplica = 10     )
or (lct.nrdconta = 642819  and  lct.nraplica = 10     )
or (lct.nrdconta = 642819  and  lct.nraplica = 10     )
or (lct.nrdconta = 642819  and  lct.nraplica = 10     )
or (lct.nrdconta = 642819  and  lct.nraplica = 10     )
or (lct.nrdconta = 642819  and  lct.nraplica = 10     )
or (lct.nrdconta = 731242  and  lct.nraplica = 20     )
or (lct.nrdconta = 916234  and  lct.nraplica = 1       )
or (lct.nrdconta = 916234  and  lct.nraplica = 1       )
or (lct.nrdconta = 874841  and  lct.nraplica = 2       )
or (lct.nrdconta = 896500  and  lct.nraplica = 23     )
or (lct.nrdconta = 932094  and  lct.nraplica = 2       )
or (lct.nrdconta = 627500  and  lct.nraplica = 46     )
or (lct.nrdconta = 619701  and  lct.nraplica = 85     )
or (lct.nrdconta = 669164  and  lct.nraplica = 25     )
or (lct.nrdconta = 852236  and  lct.nraplica = 8       )
or (lct.nrdconta = 596809  and  lct.nraplica = 32     )
or (lct.nrdconta = 896500  and  lct.nraplica = 24     )
or (lct.nrdconta = 896500  and  lct.nraplica = 24     )
or (lct.nrdconta = 746487  and  lct.nraplica = 171   )
or (lct.nrdconta = 731242  and  lct.nraplica = 21     )
or (lct.nrdconta = 651931  and  lct.nraplica = 26     )
or (lct.nrdconta = 651931  and  lct.nraplica = 26     )
or (lct.nrdconta = 515850  and  lct.nraplica = 42     )
or (lct.nrdconta = 634360  and  lct.nraplica = 3       )
or (lct.nrdconta = 825417  and  lct.nraplica = 9       )
or (lct.nrdconta = 778079  and  lct.nraplica = 17     )
or (lct.nrdconta = 615340  and  lct.nraplica = 5       )
or (lct.nrdconta = 515850  and  lct.nraplica = 43     )
or (lct.nrdconta = 515850  and  lct.nraplica = 44     )
or (lct.nrdconta = 644943  and  lct.nraplica = 69     )
or (lct.nrdconta = 844802  and  lct.nraplica = 29     )
or (lct.nrdconta = 626155  and  lct.nraplica = 35     )
or (lct.nrdconta = 611859  and  lct.nraplica = 30     )
or (lct.nrdconta = 968609  and  lct.nraplica = 1       )
or (lct.nrdconta = 796557  and  lct.nraplica = 9       )
or (lct.nrdconta = 659746  and  lct.nraplica = 27     )
or (lct.nrdconta = 896500  and  lct.nraplica = 25     )
or (lct.nrdconta = 896500  and  lct.nraplica = 26     )
or (lct.nrdconta = 896500  and  lct.nraplica = 27     )
or (lct.nrdconta = 932094  and  lct.nraplica = 3       )
or (lct.nrdconta = 932094  and  lct.nraplica = 4       )
or (lct.nrdconta = 896500  and  lct.nraplica = 28     )
or (lct.nrdconta = 645800  and  lct.nraplica = 3       )
or (lct.nrdconta = 856525  and  lct.nraplica = 18     )
or (lct.nrdconta = 856525  and  lct.nraplica = 17     )
or (lct.nrdconta = 896500  and  lct.nraplica = 29     )
or (lct.nrdconta = 503169  and  lct.nraplica = 49     )
or (lct.nrdconta = 874841  and  lct.nraplica = 3       )
or (lct.nrdconta = 896500  and  lct.nraplica = 30     )
or (lct.nrdconta = 691518  and  lct.nraplica = 18     )
or (lct.nrdconta = 695858  and  lct.nraplica = 47     )
or (lct.nrdconta = 826669  and  lct.nraplica = 13     )
or (lct.nrdconta = 596809  and  lct.nraplica = 33     )
or (lct.nrdconta = 619701  and  lct.nraplica = 87     )
or (lct.nrdconta = 771767  and  lct.nraplica = 27     )
or (lct.nrdconta = 826588  and  lct.nraplica = 25     )
or (lct.nrdconta = 852236  and  lct.nraplica = 9       )
or (lct.nrdconta = 191000  and  lct.nraplica = 41     )
or (lct.nrdconta = 731242  and  lct.nraplica = 22     )
or (lct.nrdconta = 896500  and  lct.nraplica = 31     )
or (lct.nrdconta = 896500  and  lct.nraplica = 31     )
or (lct.nrdconta = 709786  and  lct.nraplica = 23     )
or (lct.nrdconta = 605174  and  lct.nraplica = 48     )
or (lct.nrdconta = 896500  and  lct.nraplica = 32     )
or (lct.nrdconta = 492442  and  lct.nraplica = 113   )
or (lct.nrdconta = 644943  and  lct.nraplica = 76     )
or (lct.nrdconta = 515850  and  lct.nraplica = 45     )
or (lct.nrdconta = 921440  and  lct.nraplica = 8       )
or (lct.nrdconta = 515850  and  lct.nraplica = 46     )
or (lct.nrdconta = 269905  and  lct.nraplica = 96     )
or (lct.nrdconta = 515850  and  lct.nraplica = 47     )
or (lct.nrdconta = 752126  and  lct.nraplica = 4       )
or (lct.nrdconta = 976873  and  lct.nraplica = 1       )
or (lct.nrdconta = 896500  and  lct.nraplica = 33     )
or (lct.nrdconta = 557455  and  lct.nraplica = 67     )
or (lct.nrdconta = 699764  and  lct.nraplica = 27     )
or (lct.nrdconta = 864820  and  lct.nraplica = 9       )
or (lct.nrdconta = 645923  and  lct.nraplica = 115   )
or (lct.nrdconta = 567434  and  lct.nraplica = 48     )
or (lct.nrdconta = 722820  and  lct.nraplica = 34     )
or (lct.nrdconta = 551201  and  lct.nraplica = 25     )
or (lct.nrdconta = 159808  and  lct.nraplica = 100   )
or (lct.nrdconta = 658120  and  lct.nraplica = 32     )
or (lct.nrdconta = 376191  and  lct.nraplica = 162   )
or (lct.nrdconta = 896500  and  lct.nraplica = 34     )
or (lct.nrdconta = 840416  and  lct.nraplica = 2       )
or (lct.nrdconta = 394602  and  lct.nraplica = 93     )
or (lct.nrdconta = 707589  and  lct.nraplica = 36     )
or (lct.nrdconta = 394602  and  lct.nraplica = 97     )
or (lct.nrdconta = 394602  and  lct.nraplica = 98     )
or (lct.nrdconta = 622567  and  lct.nraplica = 36     )
or (lct.nrdconta = 397784  and  lct.nraplica = 117   )
or (lct.nrdconta = 132195  and  lct.nraplica = 27     )
or (lct.nrdconta = 132195  and  lct.nraplica = 27     )
or (lct.nrdconta = 896500  and  lct.nraplica = 35     )
or (lct.nrdconta = 824089  and  lct.nraplica = 3       )
or (lct.nrdconta = 824089  and  lct.nraplica = 3       )
or (lct.nrdconta = 863114  and  lct.nraplica = 22     )
or (lct.nrdconta = 723258  and  lct.nraplica = 25     )
or (lct.nrdconta = 547638  and  lct.nraplica = 4       )
or (lct.nrdconta = 896500  and  lct.nraplica = 36     )
or (lct.nrdconta = 932094  and  lct.nraplica = 5       )
or (lct.nrdconta = 944750  and  lct.nraplica = 4       )
or (lct.nrdconta = 856525  and  lct.nraplica = 20     )
or (lct.nrdconta = 617792  and  lct.nraplica = 39     )
or (lct.nrdconta = 881783  and  lct.nraplica = 9       )
or (lct.nrdconta = 504378  and  lct.nraplica = 17     )
or (lct.nrdconta = 394602  and  lct.nraplica = 100   )
or (lct.nrdconta = 896500  and  lct.nraplica = 37     )
or (lct.nrdconta = 963097  and  lct.nraplica = 1       )
or (lct.nrdconta = 826669  and  lct.nraplica = 14     )
or (lct.nrdconta = 969508  and  lct.nraplica = 1       )
or (lct.nrdconta = 695858  and  lct.nraplica = 48     )
or (lct.nrdconta = 627836  and  lct.nraplica = 39     )
or (lct.nrdconta = 823511  and  lct.nraplica = 21     )
or (lct.nrdconta = 196940  and  lct.nraplica = 73     )
or (lct.nrdconta = 196940  and  lct.nraplica = 74     )
or (lct.nrdconta = 199010  and  lct.nraplica = 17     )
or (lct.nrdconta = 537675  and  lct.nraplica = 6       )
or (lct.nrdconta = 852236  and  lct.nraplica = 12     )
or (lct.nrdconta = 771767  and  lct.nraplica = 29     )
or (lct.nrdconta = 796557  and  lct.nraplica = 20     )
or (lct.nrdconta = 895393  and  lct.nraplica = 35     )
or (lct.nrdconta = 963097  and  lct.nraplica = 2       )
or (lct.nrdconta = 693154  and  lct.nraplica = 26     )
or (lct.nrdconta = 559202  and  lct.nraplica = 18     )
or (lct.nrdconta = 559202  and  lct.nraplica = 19     )
or (lct.nrdconta = 559202  and  lct.nraplica = 19     )
or (lct.nrdconta = 559202  and  lct.nraplica = 19     )
or (lct.nrdconta = 588016  and  lct.nraplica = 61     )
or (lct.nrdconta = 932884  and  lct.nraplica = 1       )
or (lct.nrdconta = 746487  and  lct.nraplica = 189   )
or (lct.nrdconta = 727563  and  lct.nraplica = 12     )
or (lct.nrdconta = 394602  and  lct.nraplica = 102   )
or (lct.nrdconta = 637092  and  lct.nraplica = 42     )
or (lct.nrdconta = 394602  and  lct.nraplica = 103   )
or (lct.nrdconta = 559202  and  lct.nraplica = 20     )
or (lct.nrdconta = 559202  and  lct.nraplica = 20     )
or (lct.nrdconta = 605174  and  lct.nraplica = 49     )
or (lct.nrdconta = 731242  and  lct.nraplica = 23     )
or (lct.nrdconta = 972452  and  lct.nraplica = 1       )
or (lct.nrdconta = 986283  and  lct.nraplica = 2       )
or (lct.nrdconta = 746487  and  lct.nraplica = 190   )
or (lct.nrdconta = 332615  and  lct.nraplica = 30     )
or (lct.nrdconta = 645354  and  lct.nraplica = 25     )
or (lct.nrdconta = 955051  and  lct.nraplica = 7       )
or (lct.nrdconta = 896500  and  lct.nraplica = 38     )
or (lct.nrdconta = 644943  and  lct.nraplica = 81     )
or (lct.nrdconta = 515850  and  lct.nraplica = 48     )
or (lct.nrdconta = 834742  and  lct.nraplica = 7       )
or (lct.nrdconta = 987786  and  lct.nraplica = 2       )
or (lct.nrdconta = 515850  and  lct.nraplica = 49     )
or (lct.nrdconta = 397270  and  lct.nraplica = 43     )
or (lct.nrdconta = 896500  and  lct.nraplica = 39     )
or (lct.nrdconta = 777277  and  lct.nraplica = 35     )
or (lct.nrdconta = 777277  and  lct.nraplica = 35     )
or (lct.nrdconta = 946974  and  lct.nraplica = 4       )
or (lct.nrdconta = 670120  and  lct.nraplica = 47     )
or (lct.nrdconta = 896500  and  lct.nraplica = 40     )
or (lct.nrdconta = 644943  and  lct.nraplica = 82     )
or (lct.nrdconta = 838330  and  lct.nraplica = 11     )
or (lct.nrdconta = 166510  and  lct.nraplica = 40     )
or (lct.nrdconta = 567434  and  lct.nraplica = 53     )
or (lct.nrdconta = 658120  and  lct.nraplica = 33     )
or (lct.nrdconta = 551201  and  lct.nraplica = 26     )
or (lct.nrdconta = 963097  and  lct.nraplica = 3       )
or (lct.nrdconta = 990469  and  lct.nraplica = 2       )
or (lct.nrdconta = 963097  and  lct.nraplica = 4       )
or (lct.nrdconta = 394602  and  lct.nraplica = 106   )
or (lct.nrdconta = 873322  and  lct.nraplica = 4       )
or (lct.nrdconta = 896500  and  lct.nraplica = 41     )
or (lct.nrdconta = 394602  and  lct.nraplica = 107   )
or (lct.nrdconta = 896500  and  lct.nraplica = 42     )
or (lct.nrdconta = 405256  and  lct.nraplica = 116   )
or (lct.nrdconta = 851760  and  lct.nraplica = 16     )
or (lct.nrdconta = 757365  and  lct.nraplica = 61     )
or (lct.nrdconta = 752339  and  lct.nraplica = 8       )
or (lct.nrdconta = 848344  and  lct.nraplica = 42     )
or (lct.nrdconta = 811300  and  lct.nraplica = 12     )
or (lct.nrdconta = 868710  and  lct.nraplica = 6       )
or (lct.nrdconta = 432067  and  lct.nraplica = 35     )
or (lct.nrdconta = 394602  and  lct.nraplica = 108   )
or (lct.nrdconta = 542636  and  lct.nraplica = 209   )
or (lct.nrdconta = 676535  and  lct.nraplica = 16     )
or (lct.nrdconta = 394602  and  lct.nraplica = 111   )
or (lct.nrdconta = 810495  and  lct.nraplica = 10     )
or (lct.nrdconta = 952010  and  lct.nraplica = 12     )
or (lct.nrdconta = 394602  and  lct.nraplica = 109   )
or (lct.nrdconta = 765660  and  lct.nraplica = 22     )
or (lct.nrdconta = 765660  and  lct.nraplica = 22     )
or (lct.nrdconta = 982270  and  lct.nraplica = 1       )
or (lct.nrdconta = 929999  and  lct.nraplica = 8       )
or (lct.nrdconta = 854247  and  lct.nraplica = 13     )
or (lct.nrdconta = 896500  and  lct.nraplica = 43     )
or (lct.nrdconta = 394602  and  lct.nraplica = 112   )
or (lct.nrdconta = 394602  and  lct.nraplica = 112   )
or (lct.nrdconta = 636576  and  lct.nraplica = 62     )
or (lct.nrdconta = 723258  and  lct.nraplica = 26     )
or (lct.nrdconta = 883891  and  lct.nraplica = 5       )
or (lct.nrdconta = 860964  and  lct.nraplica = 19     )
or (lct.nrdconta = 963097  and  lct.nraplica = 5       )
or (lct.nrdconta = 589284  and  lct.nraplica = 52     )
or (lct.nrdconta = 545023  and  lct.nraplica = 19     )
or (lct.nrdconta = 870749  and  lct.nraplica = 40     )
or (lct.nrdconta = 825417  and  lct.nraplica = 10     )
or (lct.nrdconta = 669164  and  lct.nraplica = 26     )
or (lct.nrdconta = 318698  and  lct.nraplica = 60     )
or (lct.nrdconta = 696889  and  lct.nraplica = 29     )
or (lct.nrdconta = 789933  and  lct.nraplica = 5       )
or (lct.nrdconta = 986283  and  lct.nraplica = 3       )
or (lct.nrdconta = 971367  and  lct.nraplica = 1       )
or (lct.nrdconta = 394602  and  lct.nraplica = 113   )
or (lct.nrdconta = 433144  and  lct.nraplica = 26     )
or (lct.nrdconta = 789852  and  lct.nraplica = 38     )
or (lct.nrdconta = 860964  and  lct.nraplica = 20     )
or (lct.nrdconta = 709786  and  lct.nraplica = 26     )
or (lct.nrdconta = 726311  and  lct.nraplica = 31     )
or (lct.nrdconta = 826669  and  lct.nraplica = 15     )
or (lct.nrdconta = 823511  and  lct.nraplica = 22     )
or (lct.nrdconta = 196940  and  lct.nraplica = 75     )
or (lct.nrdconta = 196940  and  lct.nraplica = 76     )
or (lct.nrdconta = 199010  and  lct.nraplica = 18     )
or (lct.nrdconta = 784427  and  lct.nraplica = 20     )
or (lct.nrdconta = 658120  and  lct.nraplica = 34     )
or (lct.nrdconta = 890588  and  lct.nraplica = 8       )
or (lct.nrdconta = 943860  and  lct.nraplica = 4       )
or (lct.nrdconta = 666130  and  lct.nraplica = 36     )
or (lct.nrdconta = 771767  and  lct.nraplica = 30     )
or (lct.nrdconta = 777447  and  lct.nraplica = 1       )
or (lct.nrdconta = 883891  and  lct.nraplica = 6       )
or (lct.nrdconta = 627836  and  lct.nraplica = 40     )
or (lct.nrdconta = 635103  and  lct.nraplica = 51     )
or (lct.nrdconta = 927201  and  lct.nraplica = 7       )
or (lct.nrdconta = 652822  and  lct.nraplica = 2       )
or (lct.nrdconta = 896500  and  lct.nraplica = 44     )
or (lct.nrdconta = 896500  and  lct.nraplica = 44     )
or (lct.nrdconta = 627500  and  lct.nraplica = 52     )
or (lct.nrdconta = 635103  and  lct.nraplica = 52     )
or (lct.nrdconta = 305766  and  lct.nraplica = 58     )
or (lct.nrdconta = 311871  and  lct.nraplica = 162   )
or (lct.nrdconta = 311871  and  lct.nraplica = 162   )
or (lct.nrdconta = 892424  and  lct.nraplica = 36     )
or (lct.nrdconta = 394602  and  lct.nraplica = 114   )
or (lct.nrdconta = 831883  and  lct.nraplica = 9       )
or (lct.nrdconta = 627500  and  lct.nraplica = 53     )
or (lct.nrdconta = 807915  and  lct.nraplica = 19     )
or (lct.nrdconta = 769908  and  lct.nraplica = 86     )
or (lct.nrdconta = 654850  and  lct.nraplica = 35     )
or (lct.nrdconta = 588679  and  lct.nraplica = 29     )
or (lct.nrdconta = 647020  and  lct.nraplica = 34     )
or (lct.nrdconta = 504033  and  lct.nraplica = 43     )
or (lct.nrdconta = 817899  and  lct.nraplica = 26     )
or (lct.nrdconta = 892424  and  lct.nraplica = 37     )
or (lct.nrdconta = 936685  and  lct.nraplica = 3       )
or (lct.nrdconta = 956325  and  lct.nraplica = 7       )
or (lct.nrdconta = 863530  and  lct.nraplica = 43     )
or (lct.nrdconta = 652822  and  lct.nraplica = 3       )
or (lct.nrdconta = 828572  and  lct.nraplica = 21     )
or (lct.nrdconta = 934313  and  lct.nraplica = 2       )
or (lct.nrdconta = 769908  and  lct.nraplica = 89     )
or (lct.nrdconta = 769908  and  lct.nraplica = 89     )
or (lct.nrdconta = 573370  and  lct.nraplica = 16     )
or (lct.nrdconta = 573370  and  lct.nraplica = 16     )
or (lct.nrdconta = 677744  and  lct.nraplica = 10     )
or (lct.nrdconta = 769908  and  lct.nraplica = 88     )
or (lct.nrdconta = 944750  and  lct.nraplica = 10     )
or (lct.nrdconta = 627682  and  lct.nraplica = 34     )
or (lct.nrdconta = 515850  and  lct.nraplica = 50     )
or (lct.nrdconta = 958964  and  lct.nraplica = 5       )
or (lct.nrdconta = 857254  and  lct.nraplica = 30     )
or (lct.nrdconta = 833142  and  lct.nraplica = 113   )
or (lct.nrdconta = 727563  and  lct.nraplica = 13     )
or (lct.nrdconta = 394602  and  lct.nraplica = 120   )
or (lct.nrdconta = 547549  and  lct.nraplica = 43     )
or (lct.nrdconta = 870749  and  lct.nraplica = 42     )
or (lct.nrdconta = 850667  and  lct.nraplica = 15     )
or (lct.nrdconta = 733865  and  lct.nraplica = 67     )
or (lct.nrdconta = 394602  and  lct.nraplica = 119   )
or (lct.nrdconta = 636126  and  lct.nraplica = 17     )
or (lct.nrdconta = 772704  and  lct.nraplica = 18     )
or (lct.nrdconta = 629391  and  lct.nraplica = 36     )
or (lct.nrdconta = 782530  and  lct.nraplica = 20     )
or (lct.nrdconta = 817333  and  lct.nraplica = 10     )
or (lct.nrdconta = 305669  and  lct.nraplica = 53     )
or (lct.nrdconta = 972452  and  lct.nraplica = 2       )
or (lct.nrdconta = 856479  and  lct.nraplica = 37     )
or (lct.nrdconta = 629391  and  lct.nraplica = 35     )
or (lct.nrdconta = 848328  and  lct.nraplica = 25     )
or (lct.nrdconta = 848328  and  lct.nraplica = 26     )
or (lct.nrdconta = 666130  and  lct.nraplica = 37     )
or (lct.nrdconta = 971456  and  lct.nraplica = 11     )
or (lct.nrdconta = 971456  and  lct.nraplica = 11     )
or (lct.nrdconta = 652822  and  lct.nraplica = 5       )
or (lct.nrdconta = 833142  and  lct.nraplica = 114   )
or (lct.nrdconta = 733865  and  lct.nraplica = 68     )
or (lct.nrdconta = 999768  and  lct.nraplica = 1       )
or (lct.nrdconta = 781312  and  lct.nraplica = 11     )
or (lct.nrdconta = 681636  and  lct.nraplica = 29     )
or (lct.nrdconta = 717460  and  lct.nraplica = 58     )
or (lct.nrdconta = 397270  and  lct.nraplica = 45     )
or (lct.nrdconta = 397270  and  lct.nraplica = 45     )
or (lct.nrdconta = 838330  and  lct.nraplica = 12     )
or (lct.nrdconta = 515850  and  lct.nraplica = 51     )
or (lct.nrdconta = 515850  and  lct.nraplica = 52     )
or (lct.nrdconta = 629391  and  lct.nraplica = 37     )
or (lct.nrdconta = 662720  and  lct.nraplica = 88     )
or (lct.nrdconta = 922730  and  lct.nraplica = 9       )
or (lct.nrdconta = 860964  and  lct.nraplica = 24     )
or (lct.nrdconta = 892289  and  lct.nraplica = 11     )
or (lct.nrdconta = 966959  and  lct.nraplica = 13     )
or (lct.nrdconta = 733865  and  lct.nraplica = 69     )
or (lct.nrdconta = 929999  and  lct.nraplica = 12     )
or (lct.nrdconta = 929999  and  lct.nraplica = 12     )
or (lct.nrdconta = 610623  and  lct.nraplica = 3       )
or (lct.nrdconta = 831883  and  lct.nraplica = 10     )
or (lct.nrdconta = 633135  and  lct.nraplica = 65     )
or (lct.nrdconta = 537675  and  lct.nraplica = 7       )
or (lct.nrdconta = 774197  and  lct.nraplica = 19     )
or (lct.nrdconta = 730530  and  lct.nraplica = 68     )
or (lct.nrdconta = 992305  and  lct.nraplica = 1       )
or (lct.nrdconta = 764922  and  lct.nraplica = 14     )
or (lct.nrdconta = 764922  and  lct.nraplica = 14     )
or (lct.nrdconta = 733865  and  lct.nraplica = 70     )
or (lct.nrdconta = 1008137  and  lct.nraplica = 1    )
or (lct.nrdconta = 719854 and  lct.nraplica = 52      )
or (lct.nrdconta = 669164 and  lct.nraplica = 27      )
or (lct.nrdconta = 529079 and  lct.nraplica = 59      )
or (lct.nrdconta = 778940 and  lct.nraplica = 9        )
or (lct.nrdconta = 941093 and  lct.nraplica = 3        )
or (lct.nrdconta = 882453 and  lct.nraplica = 3        ))
  
           and (   lct.idlancto_origem is null
                or exists (select 1
                             from cecred.tbcapt_custodia_lanctos lctori
                            where lctori.idlancamento = lct.idlancto_origem
                              and lctori.idsituacao = 8
                              and lctori.cdoperac_cetip is not null))
                ) t2
ON (t1.idaplicacao = t2.idaplicacao and t1.idlancamento = t2.idlancamento)
WHEN MATCHED THEN 
	UPDATE SET T1.IDSITUACAO = 0;

merge into cecred.tbcapt_custodia_lanctos t1
using ( select lct.*,
               count(1) over(partition by lct.cdcooper, lct.idtipo_arquivo, lct.dtregistro) qtregis,
               row_number() over(partition by lct.cdcooper, lct.idtipo_arquivo, lct.dtregistro order by lct.cdcooper, lct.idtipo_arquivo, lct.dtregistro) nrseqreg
          from (
                -- Registros ligados a RDC PRé e Pós
                select /*+ index (lct cecred.tbcapt_custodia_lanctos_idx01) */
                       rda.cdcooper,
                       rda.nrdconta,
                       rda.nraplica,
                       0 cdprodut,
                       lct.*
                  from cecred.craprda                   rda,
                       cecred.tbcapt_custodia_aplicacao apl,
                       cecred.tbcapt_custodia_lanctos   lct
                 where 1=1
                 and lct.idsituacao =1
                   and apl.idaplicacao = lct.idaplicacao
                   and apl.tpaplicacao in (1, 2) -- RDC PRé e Pós
                   and rda.idaplcus = apl.idaplicacao
                      and rda.cdcooper = 5
				  and lct.idtipo_arquivo <> 9 -- Não trazer COnciliação
                  and lct.IDTIPO_LANCTO = 2							  
                                    and trunc(lct.dtregistro) between to_date('25/06/2021','dd/mm/yyyy') and to_date('25/06/2021','dd/mm/yyyy')
                union
                -- Registros ligados a novo produto de Captação
                select /*+ index (lct cecred.tbcapt_custodia_lanctos_idx01) */
                       rac.cdcooper,
                       rac.nrdconta,
                       rac.nraplica,
                       rac.cdprodut,
                       lct.*
                  from cecred.craprac                   rac,
                       cecred.tbcapt_custodia_aplicacao apl,
                       cecred.tbcapt_custodia_lanctos   lct
                   where 1=1
                   and lct.idsituacao =1
                   and apl.idaplicacao = lct.idaplicacao
                   and apl.tpaplicacao in (3, 4) -- PCAPTA Pré e Pós
                   and rac.idaplcus = apl.idaplicacao
                      and rac.cdcooper = 5
				  and lct.idtipo_arquivo <> 9 -- Não trazer COnciliação
                  and lct.IDTIPO_LANCTO = 2							  
                 and trunc(lct.dtregistro) between to_date('25/06/2021','dd/mm/yyyy') and to_date('25/06/2021','dd/mm/yyyy')
               ) lct
         WHERE 1=1
    and ((lct.nrdconta = 172383 and lct.nraplica = 1      )
    or (lct.nrdconta = 87572    and lct.nraplica = 67     )
    or (lct.nrdconta = 120650   and lct.nraplica = 13     )
    or (lct.nrdconta = 87572    and lct.nraplica = 68     )
    or (lct.nrdconta = 165603   and lct.nraplica = 4       )
    or (lct.nrdconta = 87572    and lct.nraplica = 69     )
    or (lct.nrdconta = 87572    and lct.nraplica = 70     )
    or (lct.nrdconta = 87572    and lct.nraplica = 71     )
    or (lct.nrdconta = 193526   and lct.nraplica = 1       )
    or (lct.nrdconta = 87572    and lct.nraplica = 72     )
    or (lct.nrdconta = 193909   and lct.nraplica = 1       )
    or (lct.nrdconta = 87572    and lct.nraplica = 73     )
    or (lct.nrdconta = 193836   and lct.nraplica = 2       )
    or (lct.nrdconta = 67334    and lct.nraplica = 8       )
    or (lct.nrdconta = 87572    and lct.nraplica = 74     )
    or (lct.nrdconta = 67334    and lct.nraplica = 9       )
    or (lct.nrdconta = 193909   and lct.nraplica = 2       )
    or (lct.nrdconta = 87572    and lct.nraplica = 75     )
    or (lct.nrdconta = 193909   and lct.nraplica = 3       )
    or (lct.nrdconta = 23302    and lct.nraplica = 112   )
    or (lct.nrdconta = 87572    and lct.nraplica = 76     )
    or (lct.nrdconta = 193909   and lct.nraplica = 4       )
    or (lct.nrdconta = 87572    and lct.nraplica = 77     )
    or (lct.nrdconta = 193909   and lct.nraplica = 5       )
    or (lct.nrdconta = 87572    and lct.nraplica = 78     )
    or (lct.nrdconta = 3484     and lct.nraplica = 38     )
    or (lct.nrdconta = 87670    and lct.nraplica = 53     )
    or (lct.nrdconta = 193909   and lct.nraplica = 6       )
    or (lct.nrdconta = 87572    and lct.nraplica = 79     )
    or (lct.nrdconta = 193909   and lct.nraplica = 7       )
    or (lct.nrdconta = 13196    and lct.nraplica = 332   )
    or (lct.nrdconta = 193909   and lct.nraplica = 8       )
    or (lct.nrdconta = 201189   and lct.nraplica = 7       )
    or (lct.nrdconta = 124460   and lct.nraplica = 29     )
    or (lct.nrdconta = 245690   and lct.nraplica = 3       )
    or (lct.nrdconta = 87572    and lct.nraplica = 80     )
    or (lct.nrdconta = 193836   and lct.nraplica = 3       )
    or (lct.nrdconta = 193909   and lct.nraplica = 9       )
    or (lct.nrdconta = 87572    and lct.nraplica = 81     )
    or (lct.nrdconta = 193836   and lct.nraplica = 4       )
    or (lct.nrdconta = 172383   and lct.nraplica = 2       )
    or (lct.nrdconta = 87572    and lct.nraplica = 82     )
    or (lct.nrdconta = 193836   and lct.nraplica = 5       )
    or (lct.nrdconta = 126446   and lct.nraplica = 44     )
    or (lct.nrdconta = 66028    and lct.nraplica = 26     )
    or (lct.nrdconta = 126446   and lct.nraplica = 45     )
    or (lct.nrdconta = 201189   and lct.nraplica = 8       )
    or (lct.nrdconta = 87572    and lct.nraplica = 83     )
    or (lct.nrdconta = 193836   and lct.nraplica = 6       )
    or (lct.nrdconta = 72834    and lct.nraplica = 10     )
    or (lct.nrdconta = 193836   and lct.nraplica = 7       )
    or (lct.nrdconta = 180718   and lct.nraplica = 4       )
    or (lct.nrdconta = 141003   and lct.nraplica = 1       )
    or (lct.nrdconta = 66028    and lct.nraplica = 27     )
    or (lct.nrdconta = 126446   and lct.nraplica = 46     )
    or (lct.nrdconta = 214345   and lct.nraplica = 2       )
    or (lct.nrdconta = 165603   and lct.nraplica = 5       )
    or (lct.nrdconta = 165603   and lct.nraplica = 5       )
    or (lct.nrdconta = 126446   and lct.nraplica = 47     )
    or (lct.nrdconta = 119156   and lct.nraplica = 39     )
    or (lct.nrdconta = 87572    and lct.nraplica = 84     )
    or (lct.nrdconta = 193836   and lct.nraplica = 8       )
    or (lct.nrdconta = 66028    and lct.nraplica = 28     )
    or (lct.nrdconta = 126446   and lct.nraplica = 48     )
    or (lct.nrdconta = 141003   and lct.nraplica = 2       )
    or (lct.nrdconta = 87572    and lct.nraplica = 85     )
    or (lct.nrdconta = 193836   and lct.nraplica = 9       )
    or (lct.nrdconta = 141003   and lct.nraplica = 3       )
    or (lct.nrdconta = 189413   and lct.nraplica = 21     )
    or (lct.nrdconta = 126446   and lct.nraplica = 50     )
    or (lct.nrdconta = 146285   and lct.nraplica = 63     )
    or (lct.nrdconta = 193909   and lct.nraplica = 10     )
    or (lct.nrdconta = 256870   and lct.nraplica = 3       )
    or (lct.nrdconta = 87572    and lct.nraplica = 86     )
    or (lct.nrdconta = 141003   and lct.nraplica = 4       )
    or (lct.nrdconta = 126446   and lct.nraplica = 51     )
    or (lct.nrdconta = 193909   and lct.nraplica = 11     )
    or (lct.nrdconta = 214345   and lct.nraplica = 3       )
    or (lct.nrdconta = 38202    and lct.nraplica = 56     )
    or (lct.nrdconta = 214345   and lct.nraplica = 4       )
    or (lct.nrdconta = 193836   and lct.nraplica = 10     )
    or (lct.nrdconta = 66028    and lct.nraplica = 29     )
    or (lct.nrdconta = 126446   and lct.nraplica = 52     )
    or (lct.nrdconta = 189413   and lct.nraplica = 24     )
    or (lct.nrdconta = 16225    and lct.nraplica = 108   )
    or (lct.nrdconta = 193836   and lct.nraplica = 11     )
    or (lct.nrdconta = 258024   and lct.nraplica = 5       )
    or (lct.nrdconta = 102520   and lct.nraplica = 25     )
    or (lct.nrdconta = 141003   and lct.nraplica = 5       )
    or (lct.nrdconta = 126446   and lct.nraplica = 53     )
    or (lct.nrdconta = 15873    and lct.nraplica = 38     )
    or (lct.nrdconta = 195120   and lct.nraplica = 16     )
    or (lct.nrdconta = 214345   and lct.nraplica = 5       )
    or (lct.nrdconta = 243671   and lct.nraplica = 10     )
    or (lct.nrdconta = 214345   and lct.nraplica = 6       )
    or (lct.nrdconta = 193836   and lct.nraplica = 12     )
    or (lct.nrdconta = 32069    and lct.nraplica = 30     )
    or (lct.nrdconta = 193836   and lct.nraplica = 13     )
    or (lct.nrdconta = 141003   and lct.nraplica = 6       )
    or (lct.nrdconta = 195120   and lct.nraplica = 17     )
    or (lct.nrdconta = 172383   and lct.nraplica = 3       )
    or (lct.nrdconta = 126446   and lct.nraplica = 54     )
    or (lct.nrdconta = 193062   and lct.nraplica = 6       )
    or (lct.nrdconta = 33235    and lct.nraplica = 122   )
    or (lct.nrdconta = 134783   and lct.nraplica = 27     )
    or (lct.nrdconta = 227269   and lct.nraplica = 1       )
    or (lct.nrdconta = 176044   and lct.nraplica = 29     )
    or (lct.nrdconta = 173355   and lct.nraplica = 24     )
    or (lct.nrdconta = 234907   and lct.nraplica = 25     )
    or (lct.nrdconta = 186074   and lct.nraplica = 27     )
    or (lct.nrdconta = 190047   and lct.nraplica = 21     )
    or (lct.nrdconta = 193909   and lct.nraplica = 12     )
    or (lct.nrdconta = 165727   and lct.nraplica = 30     )
    or (lct.nrdconta = 193836   and lct.nraplica = 14     )
    or (lct.nrdconta = 195120   and lct.nraplica = 18     )
    or (lct.nrdconta = 193909   and lct.nraplica = 13     )
    or (lct.nrdconta = 292923   and lct.nraplica = 24     )
    or (lct.nrdconta = 258954   and lct.nraplica = 1       )
    or (lct.nrdconta = 214345   and lct.nraplica = 7       )
    or (lct.nrdconta = 282812   and lct.nraplica = 3       )
    or (lct.nrdconta = 126446   and lct.nraplica = 55     )
    or (lct.nrdconta = 190047   and lct.nraplica = 22     )
    or (lct.nrdconta = 207217   and lct.nraplica = 10     )
    or (lct.nrdconta = 180521   and lct.nraplica = 28     )
    or (lct.nrdconta = 173355   and lct.nraplica = 27     )
    or (lct.nrdconta = 214345   and lct.nraplica = 8       )
    or (lct.nrdconta = 269816   and lct.nraplica = 8       )
    or (lct.nrdconta = 193577   and lct.nraplica = 22     )
    or (lct.nrdconta = 241318   and lct.nraplica = 6       )
    or (lct.nrdconta = 229059   and lct.nraplica = 9       )
    or (lct.nrdconta = 296872   and lct.nraplica = 1       )
    or (lct.nrdconta = 165727   and lct.nraplica = 31     )
    or (lct.nrdconta = 195120   and lct.nraplica = 19     )
    or (lct.nrdconta = 193909   and lct.nraplica = 14     )
    or (lct.nrdconta = 186074   and lct.nraplica = 30     )
    or (lct.nrdconta = 126446   and lct.nraplica = 57     )
    or (lct.nrdconta = 282812   and lct.nraplica = 4       )
    or (lct.nrdconta = 173355   and lct.nraplica = 29     )
    or (lct.nrdconta = 83933    and lct.nraplica = 68     )
    or (lct.nrdconta = 294497   and lct.nraplica = 3       )
    or (lct.nrdconta = 294497   and lct.nraplica = 3       )
    or (lct.nrdconta = 165603   and lct.nraplica = 10     )
    or (lct.nrdconta = 173355   and lct.nraplica = 30     )
    or (lct.nrdconta = 173355   and lct.nraplica = 31     )
    or (lct.nrdconta = 256870   and lct.nraplica = 5       )
    or (lct.nrdconta = 243671   and lct.nraplica = 14     )
    or (lct.nrdconta = 241318   and lct.nraplica = 7       )
    or (lct.nrdconta = 76651    and lct.nraplica = 46     )
    or (lct.nrdconta = 249220   and lct.nraplica = 13     )
    or (lct.nrdconta = 118427   and lct.nraplica = 21     )
    or (lct.nrdconta = 186074   and lct.nraplica = 32     )
    or (lct.nrdconta = 76651    and lct.nraplica = 47     )
    or (lct.nrdconta = 165727   and lct.nraplica = 32     )
    or (lct.nrdconta = 190047   and lct.nraplica = 23     )
    or (lct.nrdconta = 163120   and lct.nraplica = 26     )
    or (lct.nrdconta = 204714   and lct.nraplica = 16     )
    or (lct.nrdconta = 188328   and lct.nraplica = 26     )
    or (lct.nrdconta = 184519   and lct.nraplica = 25     )
    or (lct.nrdconta = 50911    and lct.nraplica = 37     )
    or (lct.nrdconta = 129160   and lct.nraplica = 51     )
    or (lct.nrdconta = 195120   and lct.nraplica = 20     )
    or (lct.nrdconta = 296872   and lct.nraplica = 2       )
    or (lct.nrdconta = 170283   and lct.nraplica = 22     )
    or (lct.nrdconta = 134783   and lct.nraplica = 30     )
    or (lct.nrdconta = 58580    and lct.nraplica = 54     )
    or (lct.nrdconta = 266647   and lct.nraplica = 18     )
    or (lct.nrdconta = 32069    and lct.nraplica = 33     )
    or (lct.nrdconta = 282812   and lct.nraplica = 6       )
    or (lct.nrdconta = 78298    and lct.nraplica = 83     )
    or (lct.nrdconta = 182192   and lct.nraplica = 21     )
    or (lct.nrdconta = 88102    and lct.nraplica = 42     )
    or (lct.nrdconta = 106496   and lct.nraplica = 72     )
    or (lct.nrdconta = 173355   and lct.nraplica = 32     )
    or (lct.nrdconta = 190047   and lct.nraplica = 24     )
    or (lct.nrdconta = 163120   and lct.nraplica = 27     )
    or (lct.nrdconta = 163120   and lct.nraplica = 27     )
    or (lct.nrdconta = 246034   and lct.nraplica = 12     )
    or (lct.nrdconta = 281930   and lct.nraplica = 16     )
    or (lct.nrdconta = 173355   and lct.nraplica = 33     )
    or (lct.nrdconta = 119407   and lct.nraplica = 29     ))
    
    
           and (   lct.idlancto_origem is null
                or exists (select 1
                             from cecred.tbcapt_custodia_lanctos lctori
                            where lctori.idlancamento = lct.idlancto_origem
                              and lctori.idsituacao = 8
                              and lctori.cdoperac_cetip is not null)) ) t2
ON (t1.idaplicacao = t2.idaplicacao and t1.idlancamento = t2.idlancamento)
WHEN MATCHED THEN 
	UPDATE SET T1.IDSITUACAO = 0;		
	
	
merge into cecred.tbcapt_custodia_lanctos t1
using (select lct.*, --COOPER 6
               count(1) over(partition by lct.cdcooper, lct.idtipo_arquivo, lct.dtregistro) qtregis,
               row_number() over(partition by lct.cdcooper, lct.idtipo_arquivo, lct.dtregistro order by lct.cdcooper, lct.idtipo_arquivo, lct.dtregistro) nrseqreg
          from (
                -- Registros ligados a RDC PRé e Pós
                select /*+ index (lct cecred.tbcapt_custodia_lanctos_idx01) */
                       rda.cdcooper,
                       rda.nrdconta,
                       rda.nraplica,
                       0 cdprodut,
                       lct.*
                  from cecred.craprda                   rda,
                       cecred.tbcapt_custodia_aplicacao apl,
                       cecred.tbcapt_custodia_lanctos   lct
                 where 1=1
                  and lct.idsituacao =1
                   and apl.idaplicacao = lct.idaplicacao
                   and apl.tpaplicacao in (1, 2) -- RDC PRé e Pós
                   and rda.idaplcus = apl.idaplicacao
                      and rda.cdcooper = 6
				  and lct.idtipo_arquivo <> 9 -- Não trazer COnciliação
                  and lct.IDTIPO_LANCTO = 2							  
                                    and trunc(lct.dtregistro) between to_date('25/06/2021','dd/mm/yyyy') and to_date('25/06/2021','dd/mm/yyyy')
                union
                -- Registros ligados a novo produto de Captação
                select /*+ index (lct cecred.tbcapt_custodia_lanctos_idx01) */
                       rac.cdcooper,
                       rac.nrdconta,
                       rac.nraplica,
                       rac.cdprodut,
                       lct.*
                  from cecred.craprac                   rac,
                       cecred.tbcapt_custodia_aplicacao apl,
                       cecred.tbcapt_custodia_lanctos   lct
                   where 1=1
                   and lct.idsituacao =1
                   and apl.idaplicacao = lct.idaplicacao
                   and apl.tpaplicacao in (3, 4) -- PCAPTA Pré e Pós
                   and rac.idaplcus = apl.idaplicacao
                      and rac.cdcooper = 6
				  and lct.idtipo_arquivo <> 9 -- Não trazer COnciliação
                  and lct.IDTIPO_LANCTO = 2							  
                 and trunc(lct.dtregistro) between to_date('25/06/2021','dd/mm/yyyy') and to_date('25/06/2021','dd/mm/yyyy')
               ) lct
         WHERE 1=1
           and (( lct.nrdconta = 108740   and lct.nraplica = 2    )
          or ( lct.nrdconta = 50555   and lct.nraplica = 28     )
          or ( lct.nrdconta = 152757    and lct.nraplica = 1      )
          or ( lct.nrdconta = 78530   and lct.nraplica = 9      )
          or ( lct.nrdconta = 108740    and lct.nraplica = 3      )
          or ( lct.nrdconta = 108740    and lct.nraplica = 3      )
          or ( lct.nrdconta = 78530   and lct.nraplica = 10     )
          or ( lct.nrdconta = 506664    and lct.nraplica = 15     )
          or ( lct.nrdconta = 118133    and lct.nraplica = 21     )
          or ( lct.nrdconta = 118133    and lct.nraplica = 23     )
          or ( lct.nrdconta = 118133    and lct.nraplica = 25     )
          or ( lct.nrdconta = 118133    and lct.nraplica = 27     )
          or ( lct.nrdconta = 118133    and lct.nraplica = 28     )
          or ( lct.nrdconta = 10952   and lct.nraplica = 48     )
          or ( lct.nrdconta = 4464      and lct.nraplica = 11     )
          or ( lct.nrdconta = 506664    and lct.nraplica = 17     )
          or ( lct.nrdconta = 24147   and lct.nraplica = 27     )
          or ( lct.nrdconta = 10952   and lct.nraplica = 50     )
          or ( lct.nrdconta = 140007    and lct.nraplica = 1      )
          or ( lct.nrdconta = 114928    and lct.nraplica = 9      )
          or ( lct.nrdconta = 103306    and lct.nraplica = 32     )
          or ( lct.nrdconta = 17507   and lct.nraplica = 19     )
          or ( lct.nrdconta = 17507   and lct.nraplica = 19     )
          or ( lct.nrdconta = 103306    and lct.nraplica = 35     )
          or ( lct.nrdconta = 113760    and lct.nraplica = 41     )
          or ( lct.nrdconta = 34495   and lct.nraplica = 70     )
          or ( lct.nrdconta = 29920   and lct.nraplica = 82     )
          or ( lct.nrdconta = 209210    and lct.nraplica = 2      )
          or ( lct.nrdconta = 209210    and lct.nraplica = 3      )
          or ( lct.nrdconta = 209210    and lct.nraplica = 4      )
          or ( lct.nrdconta = 1287      and lct.nraplica = 45     )
          or ( lct.nrdconta = 48631   and lct.nraplica = 31     )
          or ( lct.nrdconta = 1287      and lct.nraplica = 48     )
          or ( lct.nrdconta = 181188    and lct.nraplica = 22     )
          or ( lct.nrdconta = 149144    and lct.nraplica = 5      )
          or ( lct.nrdconta = 1287      and lct.nraplica =     49     )
          or ( lct.nrdconta = 210293    and lct.nraplica = 13     )
          or ( lct.nrdconta = 149144    and lct.nraplica = 6      )
          or ( lct.nrdconta = 15750   and lct.nraplica = 34     )
          or ( lct.nrdconta = 15750   and lct.nraplica = 34     )
          or ( lct.nrdconta = 10464   and lct.nraplica = 39     )
          or ( lct.nrdconta = 217530    and lct.nraplica = 1      )
          or ( lct.nrdconta = 1287      and lct.nraplica = 50     )
          or ( lct.nrdconta = 2267      and lct.nraplica = 44     )
          or ( lct.nrdconta = 127280    and lct.nraplica = 4      )
          or ( lct.nrdconta = 504629    and lct.nraplica = 89     )
          or ( lct.nrdconta = 504629    and lct.nraplica = 90     )
          or ( lct.nrdconta = 149144    and lct.nraplica = 7      )
          or ( lct.nrdconta = 72710   and lct.nraplica = 26     )
          or ( lct.nrdconta = 149144    and lct.nraplica = 8      )
          or ( lct.nrdconta = 206369    and lct.nraplica = 2      )
          or ( lct.nrdconta = 2267      and lct.nraplica = 46     )
          or ( lct.nrdconta = 118265    and lct.nraplica = 64     )
          or ( lct.nrdconta = 10464   and lct.nraplica = 40     )
          or ( lct.nrdconta = 165565    and lct.nraplica = 5      )
          or ( lct.nrdconta = 48577   and lct.nraplica = 65     )
          or ( lct.nrdconta = 172308    and lct.nraplica = 11     )
          or ( lct.nrdconta = 209082    and lct.nraplica = 3      )
          or ( lct.nrdconta = 88838   and lct.nraplica = 31     )
          or ( lct.nrdconta = 77518   and lct.nraplica = 136   )
          or ( lct.nrdconta = 2267      and lct.nraplica = 49     )
          or ( lct.nrdconta = 118265    and lct.nraplica = 65     )
          or ( lct.nrdconta = 10464   and lct.nraplica = 41     )
          or ( lct.nrdconta = 134724    and lct.nraplica = 6      )
          or ( lct.nrdconta = 103306    and lct.nraplica = 36     )
          or ( lct.nrdconta = 173398    and lct.nraplica = 2      )
          or ( lct.nrdconta = 121240    and lct.nraplica = 60     )
          or ( lct.nrdconta = 195596    and lct.nraplica = 3      )
          or ( lct.nrdconta = 508250    and lct.nraplica = 25     )
          or ( lct.nrdconta = 110469    and lct.nraplica = 74     )
          or ( lct.nrdconta = 51918   and lct.nraplica = 6      )
          or ( lct.nrdconta = 10464   and lct.nraplica = 42     )
          or ( lct.nrdconta = 50261   and lct.nraplica = 23     )
          or ( lct.nrdconta = 121371    and lct.nraplica = 48     )
          or ( lct.nrdconta = 2267      and lct.nraplica = 50     )
          or ( lct.nrdconta = 118265    and lct.nraplica = 66     )
          or ( lct.nrdconta = 103306    and lct.nraplica = 37     )
          or ( lct.nrdconta = 189839    and lct.nraplica = 13     )
          or ( lct.nrdconta = 63720   and lct.nraplica = 56     )
          or ( lct.nrdconta = 35220   and lct.nraplica = 39     )
          or ( lct.nrdconta = 35220   and lct.nraplica = 39     )
          or ( lct.nrdconta = 180360    and lct.nraplica = 28     )
          or ( lct.nrdconta = 121240    and lct.nraplica = 61     )
          or ( lct.nrdconta = 501484    and lct.nraplica = 130   ))
           and (   lct.idlancto_origem is null
                or exists (select 1
                             from cecred.tbcapt_custodia_lanctos lctori
                            where lctori.idlancamento = lct.idlancto_origem
                              and lctori.idsituacao = 8
                              and lctori.cdoperac_cetip is not null))) t2
ON (t1.idaplicacao = t2.idaplicacao and t1.idlancamento = t2.idlancamento)
WHEN MATCHED THEN 
	UPDATE SET T1.IDSITUACAO = 0;
	
	
merge into cecred.tbcapt_custodia_lanctos t1
using (--COOPER 7
 select lct.*,
               count(1) over(partition by lct.cdcooper, lct.idtipo_arquivo, lct.dtregistro) qtregis,
               row_number() over(partition by lct.cdcooper, lct.idtipo_arquivo, lct.dtregistro order by lct.cdcooper, lct.idtipo_arquivo, lct.dtregistro) nrseqreg
          from (
                -- Registros ligados a RDC PRé e Pós
                select /*+ index (lct cecred.tbcapt_custodia_lanctos_idx01) */
                       rda.cdcooper,
                       rda.nrdconta,
                       rda.nraplica,
                       0 cdprodut,
                       lct.*
                  from cecred.craprda                   rda,
                       cecred.tbcapt_custodia_aplicacao apl,
                       cecred.tbcapt_custodia_lanctos   lct
                 where 1=1
                   and lct.idsituacao =1
                   and apl.idaplicacao = lct.idaplicacao
                   and apl.tpaplicacao in (1, 2) -- RDC PRé e Pós
                   and rda.idaplcus = apl.idaplicacao
                      and rda.cdcooper = 7
				  and lct.idtipo_arquivo <> 9 -- Não trazer COnciliação
                  and lct.IDTIPO_LANCTO = 2							  
                                    and trunc(lct.dtregistro) between to_date('25/06/2021','dd/mm/yyyy') and to_date('25/06/2021','dd/mm/yyyy')
                union
                -- Registros ligados a novo produto de Captação
                select /*+ index (lct cecred.tbcapt_custodia_lanctos_idx01) */
                       rac.cdcooper,
                       rac.nrdconta,
                       rac.nraplica,
                       rac.cdprodut,
                       lct.*
                  from cecred.craprac                   rac,
                       cecred.tbcapt_custodia_aplicacao apl,
                       cecred.tbcapt_custodia_lanctos   lct
                   where 1=1
                   and lct.idsituacao =1
                   and apl.idaplicacao = lct.idaplicacao
                   and apl.tpaplicacao in (3, 4) -- PCAPTA Pré e Pós
                   and rac.idaplcus = apl.idaplicacao
                      and rac.cdcooper = 7					  
				  and lct.idtipo_arquivo <> 9 -- Não trazer COnciliação
                  and lct.IDTIPO_LANCTO = 2							  
                 and trunc(lct.dtregistro) between to_date('25/06/2021','dd/mm/yyyy') and to_date('25/06/2021','dd/mm/yyyy')
               ) lct
         WHERE 1=1
           and (( lct.nrdconta =  330264  and lct.nraplica =  15   )
or ( lct.nrdconta =  113000   and lct.nraplica =  10   )
or ( lct.nrdconta =  330264   and lct.nraplica =  16   )
or ( lct.nrdconta =  80667      and lct.nraplica =  3     )
or ( lct.nrdconta =  330264   and lct.nraplica =  17   )
or ( lct.nrdconta =  330264   and lct.nraplica =  18   )
or ( lct.nrdconta =  330264   and lct.nraplica =  19   )
or ( lct.nrdconta =  80667      and lct.nraplica =  4     )
or ( lct.nrdconta =  215759   and lct.nraplica =  16   )
or ( lct.nrdconta =  130230   and lct.nraplica =  21   )
or ( lct.nrdconta =  330264   and lct.nraplica =  20   )
or ( lct.nrdconta =  330264   and lct.nraplica =  21   )
or ( lct.nrdconta =  80667      and lct.nraplica =  5     )
or ( lct.nrdconta =  80667      and lct.nraplica =  6     )
or ( lct.nrdconta =  60410      and lct.nraplica =  14   )
or ( lct.nrdconta =  80667      and lct.nraplica =  7     )
or ( lct.nrdconta =  235733   and lct.nraplica =  19   )
or ( lct.nrdconta =  215759   and lct.nraplica =  17   )
or ( lct.nrdconta =  60410      and lct.nraplica =  15   )
or ( lct.nrdconta =  60410      and lct.nraplica =  16   )
or ( lct.nrdconta =  292559   and lct.nraplica =  1     )
or ( lct.nrdconta =  60410      and lct.nraplica =  17   )
or ( lct.nrdconta =  80667      and lct.nraplica =  8     )
or ( lct.nrdconta =  60410      and lct.nraplica =  18   )
or ( lct.nrdconta =  80667      and lct.nraplica =  9     )
or ( lct.nrdconta =  24880      and lct.nraplica =  45   )
or ( lct.nrdconta =  60410      and lct.nraplica =  19   )
or ( lct.nrdconta =  60410      and lct.nraplica =  20   )
or ( lct.nrdconta =  24880      and lct.nraplica =  46   )
or ( lct.nrdconta =  60410      and lct.nraplica =  21   )
or ( lct.nrdconta =  80667      and lct.nraplica =  10   )
or ( lct.nrdconta =  60410      and lct.nraplica =  22   )
or ( lct.nrdconta =  60410      and lct.nraplica =  23   )
or ( lct.nrdconta =  215759   and lct.nraplica =  18   )
or ( lct.nrdconta =  319058   and lct.nraplica =  7     )
or ( lct.nrdconta =  80667      and lct.nraplica =  11   )
or ( lct.nrdconta =  310727   and lct.nraplica =  30   )
or ( lct.nrdconta =  60410      and lct.nraplica =  24   )
or ( lct.nrdconta =  215759   and lct.nraplica =  19   )
or ( lct.nrdconta =  162604   and lct.nraplica =  3     )
or ( lct.nrdconta =  181226   and lct.nraplica =  13   )
or ( lct.nrdconta =  60410      and lct.nraplica =  25   )
or ( lct.nrdconta =  112887   and lct.nraplica =  1     )
or ( lct.nrdconta =  269859   and lct.nraplica =  4     )
or ( lct.nrdconta =  215759   and lct.nraplica =  20   )
or ( lct.nrdconta =  145203   and lct.nraplica =  1     )
or ( lct.nrdconta =  60410      and lct.nraplica =  26   )
or ( lct.nrdconta =  307807   and lct.nraplica =  2     )
or ( lct.nrdconta =  329002   and lct.nraplica =  1     )
or ( lct.nrdconta =  348538   and lct.nraplica =  1     )
or ( lct.nrdconta =  329002   and lct.nraplica =  2     )
or ( lct.nrdconta =  469        and lct.nraplica =  40   )
or ( lct.nrdconta =  21539      and lct.nraplica =  42   )
or ( lct.nrdconta =  60410      and lct.nraplica =  27   )
or ( lct.nrdconta =  60410      and lct.nraplica =  28   )
or ( lct.nrdconta =  129380   and lct.nraplica =  10   )
or ( lct.nrdconta =  333557   and lct.nraplica =  2     )
or ( lct.nrdconta =  63827      and lct.nraplica =  9     )
or ( lct.nrdconta =  303313   and lct.nraplica =  19   )
or ( lct.nrdconta =  60410      and lct.nraplica =  29   )
or ( lct.nrdconta =  330264   and lct.nraplica =  22   )
or ( lct.nrdconta =  161284   and lct.nraplica =  18   )
or ( lct.nrdconta =  215759   and lct.nraplica =  21   )
or ( lct.nrdconta =  75124      and lct.nraplica =  21   )
or ( lct.nrdconta =  80667      and lct.nraplica =  12   )
or ( lct.nrdconta =  167223   and lct.nraplica =  36   )
or ( lct.nrdconta =  1066     and lct.nraplica =  157 )
or ( lct.nrdconta =  215759   and lct.nraplica =  22   )
or ( lct.nrdconta =  68136      and lct.nraplica =  6     )
or ( lct.nrdconta =  68136      and lct.nraplica =  6     )
or ( lct.nrdconta =  303313   and lct.nraplica =  23   )
or ( lct.nrdconta =  60410      and lct.nraplica =  30   )
or ( lct.nrdconta =  58521      and lct.nraplica =  33   )
or ( lct.nrdconta =  167223   and lct.nraplica =  37   )
or ( lct.nrdconta =  167223   and lct.nraplica =  37   )
or ( lct.nrdconta =  258474   and lct.nraplica =  17   )
or ( lct.nrdconta =  299847   and lct.nraplica =  17   )
or ( lct.nrdconta =  343498   and lct.nraplica =  7     )
or ( lct.nrdconta =  60410      and lct.nraplica =  31   )
or ( lct.nrdconta =  56251      and lct.nraplica =  18   )
or ( lct.nrdconta =  343498   and lct.nraplica =  8     )
or ( lct.nrdconta =  366951   and lct.nraplica =  1     )
or ( lct.nrdconta =  101737   and lct.nraplica =  63   )
or ( lct.nrdconta =  158020   and lct.nraplica =  24   )
or ( lct.nrdconta =  153257   and lct.nraplica =  16   )
or ( lct.nrdconta =  201243   and lct.nraplica =  14   )
or ( lct.nrdconta =  60410      and lct.nraplica =  32   )
or ( lct.nrdconta =  211583   and lct.nraplica =  22   )
or ( lct.nrdconta =  211583   and lct.nraplica =  22   )
or ( lct.nrdconta =  211583   and lct.nraplica =  22   )
or ( lct.nrdconta =  211583   and lct.nraplica =  22   )
or ( lct.nrdconta =  211583   and lct.nraplica =  22   )
or ( lct.nrdconta =  211583   and lct.nraplica =  22   )
or ( lct.nrdconta =  115525   and lct.nraplica =  72   )
or ( lct.nrdconta =  343498   and lct.nraplica =  9     )
or ( lct.nrdconta =  379298   and lct.nraplica =  3     )
or ( lct.nrdconta =  379298   and lct.nraplica =  2     )
or ( lct.nrdconta =  343498   and lct.nraplica =  10   )
or ( lct.nrdconta =  18945      and lct.nraplica =  52   )
or ( lct.nrdconta =  339016   and lct.nraplica =  8     )
or ( lct.nrdconta =  75124      and lct.nraplica =  23   )
or ( lct.nrdconta =  115525   and lct.nraplica =  74   )
or ( lct.nrdconta =  144070   and lct.nraplica =  51   )
or ( lct.nrdconta =  338958   and lct.nraplica =  5     )
or ( lct.nrdconta =  60410      and lct.nraplica =  33   )
or ( lct.nrdconta =  132225   and lct.nraplica =  23   )
or ( lct.nrdconta =  65935      and lct.nraplica =  44   )
or ( lct.nrdconta =  80667      and lct.nraplica =  13   )
or ( lct.nrdconta =  47309      and lct.nraplica =  129 )
or ( lct.nrdconta =  47309      and lct.nraplica =  127 )
or ( lct.nrdconta =  47309      and lct.nraplica =  127 )
or ( lct.nrdconta =  47309      and lct.nraplica =  131 )
or ( lct.nrdconta =  47309      and lct.nraplica =  131 )
or ( lct.nrdconta =  47309      and lct.nraplica =  131 )
or ( lct.nrdconta =  11614      and lct.nraplica =  20   )
or ( lct.nrdconta =  47309      and lct.nraplica =  130 )
or ( lct.nrdconta =  47309      and lct.nraplica =  130 )
or ( lct.nrdconta =  47309      and lct.nraplica =  130 )
or ( lct.nrdconta =  335746   and lct.nraplica =  49   )
or ( lct.nrdconta =  366951   and lct.nraplica =  2     )
or ( lct.nrdconta =  75124      and lct.nraplica =  24   )
or ( lct.nrdconta =  23841      and lct.nraplica =  32   )
or ( lct.nrdconta =  4626     and lct.nraplica =  23   )
or ( lct.nrdconta =  60410      and lct.nraplica =  34   )
or ( lct.nrdconta =  18945      and lct.nraplica =  53   )
or ( lct.nrdconta =  339016   and lct.nraplica =  9     )
or ( lct.nrdconta =  24821      and lct.nraplica =  105 )
or ( lct.nrdconta =  132225   and lct.nraplica =  24   )
or ( lct.nrdconta =  154695   and lct.nraplica =  12   )
or ( lct.nrdconta =  149195   and lct.nraplica =  74   )
or ( lct.nrdconta =  80667      and lct.nraplica =  14   )
or ( lct.nrdconta =  129380   and lct.nraplica =  11   )
or ( lct.nrdconta =  4626     and lct.nraplica =  24   )
or ( lct.nrdconta =  31020      and lct.nraplica =  97   )
or ( lct.nrdconta =  125091   and lct.nraplica =  27   )
or ( lct.nrdconta =  115525   and lct.nraplica =  75   )
or ( lct.nrdconta =  366951   and lct.nraplica =  3     )
or ( lct.nrdconta =  251216   and lct.nraplica =  58   )
or ( lct.nrdconta =  277959   and lct.nraplica =  12   )
or ( lct.nrdconta =  18945      and lct.nraplica =  54   )
or ( lct.nrdconta =  53708      and lct.nraplica =  12   )
or ( lct.nrdconta =  60410      and lct.nraplica =  35   )
or ( lct.nrdconta =  339016   and lct.nraplica =  10   )
or ( lct.nrdconta =  56057      and lct.nraplica =  34   )
or ( lct.nrdconta =  100129   and lct.nraplica =  28   )
or ( lct.nrdconta =  359769   and lct.nraplica =  1     )
or ( lct.nrdconta =  247898   and lct.nraplica =  75   )
or ( lct.nrdconta =  132225   and lct.nraplica =  25   )
or ( lct.nrdconta =  149195   and lct.nraplica =  77   )
or ( lct.nrdconta =  242659   and lct.nraplica =  31   )
or ( lct.nrdconta =  191329   and lct.nraplica =  42   )
or ( lct.nrdconta =  351911   and lct.nraplica =  17   )
or ( lct.nrdconta =  80667      and lct.nraplica =  15   )
or ( lct.nrdconta =  306037   and lct.nraplica =  62   )
or ( lct.nrdconta =  342106   and lct.nraplica =  20   )
or ( lct.nrdconta =  238503   and lct.nraplica =  48   )
or ( lct.nrdconta =  238503   and lct.nraplica =  48   )
or ( lct.nrdconta =  299340   and lct.nraplica =  11   )
or ( lct.nrdconta =  164640   and lct.nraplica =  63   )
or ( lct.nrdconta =  395420   and lct.nraplica =  1     )
or ( lct.nrdconta =  164640   and lct.nraplica =  62   )
or ( lct.nrdconta =  164640   and lct.nraplica =  61   )
or ( lct.nrdconta =  366951   and lct.nraplica =  5     )
or ( lct.nrdconta =  36471      and lct.nraplica =  12   )
or ( lct.nrdconta =  56057      and lct.nraplica =  35   )
or ( lct.nrdconta =  18945      and lct.nraplica =  58   )
or ( lct.nrdconta =  53708      and lct.nraplica =  13   )
or ( lct.nrdconta =  149195   and lct.nraplica =  78   )
or ( lct.nrdconta =  149195   and lct.nraplica =  79   )
or ( lct.nrdconta =  8621     and lct.nraplica =  68   )
or ( lct.nrdconta =  60410      and lct.nraplica =  36   )
or ( lct.nrdconta =  140635   and lct.nraplica =  174 )
or ( lct.nrdconta =  318272   and lct.nraplica =  2     )
or ( lct.nrdconta =  188425   and lct.nraplica =  1     )
or ( lct.nrdconta =  164640   and lct.nraplica =  66   )
or ( lct.nrdconta =  164640   and lct.nraplica =  65   )
or ( lct.nrdconta =  164640   and lct.nraplica =  65   )
or ( lct.nrdconta =  164640   and lct.nraplica =  64   )
or ( lct.nrdconta =  164640   and lct.nraplica =  64   )
or ( lct.nrdconta =  164640   and lct.nraplica =  64   )
or ( lct.nrdconta =  75124      and lct.nraplica =  25   )
or ( lct.nrdconta =  280798   and lct.nraplica =  51   )
or ( lct.nrdconta =  296635   and lct.nraplica =  42   )
or ( lct.nrdconta =  294276   and lct.nraplica =  13   )
or ( lct.nrdconta =  294276   and lct.nraplica =  13   )
or ( lct.nrdconta =  132225   and lct.nraplica =  26   )
or ( lct.nrdconta =  208795   and lct.nraplica =  27   )
or ( lct.nrdconta =  251968   and lct.nraplica =  25   )
or ( lct.nrdconta =  299898   and lct.nraplica =  62   )
or ( lct.nrdconta =  75124      and lct.nraplica =  26   )
or ( lct.nrdconta =  303879   and lct.nraplica =  32   )
or ( lct.nrdconta =  303879   and lct.nraplica =  32   )
or ( lct.nrdconta =  250759   and lct.nraplica =  2     )
or ( lct.nrdconta =  250759   and lct.nraplica =  2     )
or ( lct.nrdconta =  366951   and lct.nraplica =  6     )
or ( lct.nrdconta =  198307   and lct.nraplica =  72   )
or ( lct.nrdconta =  251224   and lct.nraplica =  18   )
or ( lct.nrdconta =  149195   and lct.nraplica =  80   ))        
           and (   lct.idlancto_origem is null
                or exists (select 1
                             from cecred.tbcapt_custodia_lanctos lctori
                            where lctori.idlancamento = lct.idlancto_origem
                              and lctori.idsituacao = 8
                              and lctori.cdoperac_cetip is not null)) ) t2
ON (t1.idaplicacao = t2.idaplicacao and t1.idlancamento = t2.idlancamento)
WHEN MATCHED THEN 
	UPDATE SET T1.IDSITUACAO = 0;

merge into cecred.tbcapt_custodia_lanctos t1
using ( select lct.*, ---cooper 8
               count(1) over(partition by lct.cdcooper, lct.idtipo_arquivo, lct.dtregistro) qtregis,
               row_number() over(partition by lct.cdcooper, lct.idtipo_arquivo, lct.dtregistro order by lct.cdcooper, lct.idtipo_arquivo, lct.dtregistro) nrseqreg
          from (
                -- Registros ligados a RDC PRé e Pós
                select /*+ index (lct cecred.tbcapt_custodia_lanctos_idx01) */
                       rda.cdcooper,
                       rda.nrdconta,
                       rda.nraplica,
                       0 cdprodut,
                       lct.*
                  from cecred.craprda                   rda,
                       cecred.tbcapt_custodia_aplicacao apl,
                       cecred.tbcapt_custodia_lanctos   lct
                 where 1=1
                   and lct.idsituacao =1
                   and apl.idaplicacao = lct.idaplicacao
                   and apl.tpaplicacao in (1, 2) -- RDC PRé e Pós
                   and rda.idaplcus = apl.idaplicacao
                      and rda.cdcooper = 8
				  and lct.idtipo_arquivo <> 9 -- Não trazer COnciliação
                  and lct.IDTIPO_LANCTO = 2							  
                                    and trunc(lct.dtregistro) between to_date('25/06/2021','dd/mm/yyyy') and to_date('25/06/2021','dd/mm/yyyy')
                union
                -- Registros ligados a novo produto de Captação
                select /*+ index (lct cecred.tbcapt_custodia_lanctos_idx01) */
                       rac.cdcooper,
                       rac.nrdconta,
                       rac.nraplica,
                       rac.cdprodut,
                       lct.*
                  from cecred.craprac                   rac,
                       cecred.tbcapt_custodia_aplicacao apl,
                       cecred.tbcapt_custodia_lanctos   lct
                   where 1=1
                   and lct.idsituacao =1
                   and apl.idaplicacao = lct.idaplicacao
                   and apl.tpaplicacao in (3, 4) -- PCAPTA Pré e Pós
                   and rac.idaplcus = apl.idaplicacao
                      and rac.cdcooper = 8
				  and lct.idtipo_arquivo <> 9 -- Não trazer COnciliação
                  and lct.IDTIPO_LANCTO = 2							  
                 and trunc(lct.dtregistro) between to_date('25/06/2021','dd/mm/yyyy') and to_date('25/06/2021','dd/mm/yyyy')
               ) lct
         WHERE 1=1
        and (( lct.nrdconta =  28517   and lct.nraplica = 17)
or ( lct.nrdconta =  28517   and lct.nraplica = 18    )
or ( lct.nrdconta =  18619   and lct.nraplica = 33    )
or ( lct.nrdconta =  8141  and lct.nraplica = 36    )
or ( lct.nrdconta =  54208   and lct.nraplica = 1      )
or ( lct.nrdconta =  30635   and lct.nraplica = 24    )
or ( lct.nrdconta =  29327   and lct.nraplica = 50    )
or ( lct.nrdconta =  19348   and lct.nraplica = 27    )
or ( lct.nrdconta =  1910  and lct.nraplica = 107  )
or ( lct.nrdconta =  31453   and lct.nraplica = 76    )
or ( lct.nrdconta =  22799   and lct.nraplica = 44    )
or ( lct.nrdconta =  29327   and lct.nraplica = 52    )
or ( lct.nrdconta =  7196  and lct.nraplica = 41    )
or ( lct.nrdconta =  27197   and lct.nraplica = 22    )
or ( lct.nrdconta =  1910  and lct.nraplica = 110  )
or ( lct.nrdconta =  30635   and lct.nraplica = 30    )
or ( lct.nrdconta =  50253   and lct.nraplica = 29    )
or ( lct.nrdconta =  37621   and lct.nraplica = 57    )
or ( lct.nrdconta =  31208   and lct.nraplica = 23    )
or ( lct.nrdconta =  29327   and lct.nraplica = 53    )
or ( lct.nrdconta =  20133   and lct.nraplica = 32    )
or ( lct.nrdconta =  49859   and lct.nraplica = 11    )
or ( lct.nrdconta =  31208   and lct.nraplica = 24    )
or ( lct.nrdconta =  43087   and lct.nraplica = 1478))
           and (   lct.idlancto_origem is null
                or exists (select 1
                             from cecred.tbcapt_custodia_lanctos lctori
                            where lctori.idlancamento = lct.idlancto_origem
                              and lctori.idsituacao = 8
                              and lctori.cdoperac_cetip is not null))) t2
ON (t1.idaplicacao = t2.idaplicacao and t1.idlancamento = t2.idlancamento)
WHEN MATCHED THEN 
	UPDATE SET T1.IDSITUACAO = 0;
	
	
merge into cecred.tbcapt_custodia_lanctos t1
using (--cooper 2
 select lct.*, 
               count(1) over(partition by lct.cdcooper, lct.idtipo_arquivo, lct.dtregistro) qtregis,
               row_number() over(partition by lct.cdcooper, lct.idtipo_arquivo, lct.dtregistro order by lct.cdcooper, lct.idtipo_arquivo, lct.dtregistro) nrseqreg
          from (
                -- Registros ligados a RDC PRé e Pós
                select /*+ index (lct tbcapt_custodia_lanctos_idx01) */
                       rda.cdcooper,
                       rda.nrdconta,
                       rda.nraplica,
                       0 cdprodut,
                       lct.*
                  from cecred.craprda                   rda,
                       cecred.tbcapt_custodia_aplicacao apl,
                       cecred.tbcapt_custodia_lanctos   lct
                 where 1=1
                   and lct.idsituacao =1
                   and apl.idaplicacao = lct.idaplicacao
                   and apl.tpaplicacao in (1, 2) -- RDC PRé e Pós
                   and rda.idaplcus = apl.idaplicacao
             and rda.cdcooper = 2
       and nvl(rda.INSAQTOT,0) =0
            and lct.IDTIPO_LANCTO = 1
        and lct.idtipo_arquivo <> 9 -- Não trazer COnciliação
                                    and trunc(lct.dtregistro) between to_date('25/06/2021','dd/mm/yyyy') and to_date('25/06/2021','dd/mm/yyyy')               
                union
                -- Registros ligados a novo produto de Captação
                select /*+ index (lct tbcapt_custodia_lanctos_idx01) */
                       rac.cdcooper,
                       rac.nrdconta,
                       rac.nraplica,
                       rac.cdprodut,
                       lct.*
                  from cecred.craprac                   rac,
                       cecred.tbcapt_custodia_aplicacao apl,
                       cecred.tbcapt_custodia_lanctos   lct
                   where 1=1
                    and lct.idsituacao =1
                   and apl.idaplicacao = lct.idaplicacao
                   and apl.tpaplicacao in (3, 4) -- PCAPTA Pré e Pós
                   and rac.idaplcus = apl.idaplicacao
          and rac.cdcooper = 2
        and nvl(rac.IDSAQTOT,0) =0          
        and lct.IDTIPO_LANCTO = 1
        and lct.idtipo_arquivo <> 9 -- Não trazer COnciliação      
                 and trunc(lct.dtregistro) between to_date('25/06/2021','dd/mm/yyyy') and to_date('25/06/2021','dd/mm/yyyy')
               ) lct
         WHERE 1=1
           -- Se este possui registros de origem, os registros de origem devem
           -- ter gerado Numero CETIP e estarem OK
       and ((lct.nrdconta = 1005936  and  lct.nraplica =  6   )
or (lct.nrdconta = 909190      and  lct.nraplica =  8       )
or (lct.nrdconta = 874655      and  lct.nraplica =  19      )
or (lct.nrdconta = 600482      and  lct.nraplica =  135    )
or (lct.nrdconta = 619450      and  lct.nraplica =  107    )
or (lct.nrdconta = 199761      and  lct.nraplica =  61      )
or (lct.nrdconta = 780235      and  lct.nraplica =  20      )
or (lct.nrdconta = 979562      and  lct.nraplica =  2       )
or (lct.nrdconta = 372765      and  lct.nraplica =  178    )
or (lct.nrdconta = 544841      and  lct.nraplica =  38      )
or (lct.nrdconta = 900273      and  lct.nraplica =  3       )
or (lct.nrdconta = 913553      and  lct.nraplica =  12      )
or (lct.nrdconta = 394513      and  lct.nraplica =  65      )
or (lct.nrdconta = 992305      and  lct.nraplica =  3       )
or (lct.nrdconta = 698237      and  lct.nraplica =  15      )
or (lct.nrdconta = 929930      and  lct.nraplica =  10      )
or (lct.nrdconta = 450642      and  lct.nraplica =  39      )
or (lct.nrdconta = 764922      and  lct.nraplica =  15      )
or (lct.nrdconta = 684783      and  lct.nraplica =  38      )
or (lct.nrdconta = 870501      and  lct.nraplica =  1       )
or (lct.nrdconta = 290742      and  lct.nraplica =  58      )
or (lct.nrdconta = 742716      and  lct.nraplica =  6       )
or (lct.nrdconta = 505285      and  lct.nraplica =  56      )
or (lct.nrdconta = 454095      and  lct.nraplica =  123    )
or (lct.nrdconta = 239771      and  lct.nraplica =  71      )
or (lct.nrdconta = 306444      and  lct.nraplica =  29      )
or (lct.nrdconta = 581895      and  lct.nraplica =  23      )
or (lct.nrdconta = 1006380     and  lct.nraplica =  1       )
or (lct.nrdconta = 456730      and  lct.nraplica =  33      )
or (lct.nrdconta = 800570      and  lct.nraplica =  2       )
or (lct.nrdconta = 514330      and  lct.nraplica =  28      )
or (lct.nrdconta = 635049      and  lct.nraplica =  46      )
or (lct.nrdconta = 606243      and  lct.nraplica =  3       )
or (lct.nrdconta = 541621      and  lct.nraplica =  122    )
or (lct.nrdconta = 505285      and  lct.nraplica =  55      )
or (lct.nrdconta = 992305      and  lct.nraplica =  2       )
or (lct.nrdconta = 518832      and  lct.nraplica =  60      )
or (lct.nrdconta = 562386      and  lct.nraplica =  112    )
or (lct.nrdconta = 953229      and  lct.nraplica =  5       )
or (lct.nrdconta = 917958      and  lct.nraplica =  20      )
or (lct.nrdconta = 969788      and  lct.nraplica =  5       )
or (lct.nrdconta = 936103      and  lct.nraplica =  7       )
or (lct.nrdconta = 941506      and  lct.nraplica =  2       )
or (lct.nrdconta = 781070      and  lct.nraplica =  19      )
or (lct.nrdconta = 767115      and  lct.nraplica =  120    )
or (lct.nrdconta = 533211      and  lct.nraplica =  53      )
or (lct.nrdconta = 377996      and  lct.nraplica =  111    )
or (lct.nrdconta = 549177      and  lct.nraplica =  46      )
or (lct.nrdconta = 547522      and  lct.nraplica =  59      )
or (lct.nrdconta = 1009443     and  lct.nraplica =  1       )
or (lct.nrdconta = 950378      and  lct.nraplica =  4       )
or (lct.nrdconta = 623652      and  lct.nraplica =  53      )
or (lct.nrdconta = 709891      and  lct.nraplica =  95      )
or (lct.nrdconta = 722952      and  lct.nraplica =  9       )
or (lct.nrdconta = 339954      and  lct.nraplica =  37      )
or (lct.nrdconta = 783692      and  lct.nraplica =  33      )
or (lct.nrdconta = 709891      and  lct.nraplica =  96      )
or (lct.nrdconta = 461415      and  lct.nraplica =  160    )
or (lct.nrdconta = 664693      and  lct.nraplica =  45      )
or (lct.nrdconta = 538965      and  lct.nraplica =  89      )
or (lct.nrdconta = 479381      and  lct.nraplica =  82      )
or (lct.nrdconta = 657344      and  lct.nraplica =  15      )
or (lct.nrdconta = 460133      and  lct.nraplica =  3       )
or (lct.nrdconta = 992836      and  lct.nraplica =  1       )
or (lct.nrdconta = 451720      and  lct.nraplica =  74      )
or (lct.nrdconta = 702633      and  lct.nraplica =  5       )
or (lct.nrdconta = 962600      and  lct.nraplica =  9       )
or (lct.nrdconta = 296333      and  lct.nraplica =  38      )
or (lct.nrdconta = 890480      and  lct.nraplica =  4       )
or (lct.nrdconta = 886807      and  lct.nraplica =  17      )
or (lct.nrdconta = 769908      and  lct.nraplica =  91      )
or (lct.nrdconta = 706116      and  lct.nraplica =  37      )
or (lct.nrdconta = 515663      and  lct.nraplica =  33      )
or (lct.nrdconta = 619450      and  lct.nraplica =  106    )
or (lct.nrdconta = 542636      and  lct.nraplica =  212    )
or (lct.nrdconta = 953962      and  lct.nraplica =  5       )
or (lct.nrdconta = 452670      and  lct.nraplica =  56      )
or (lct.nrdconta = 957550      and  lct.nraplica =  1       )
or (lct.nrdconta = 502545      and  lct.nraplica =  6       )
or (lct.nrdconta = 552178      and  lct.nraplica =  133    )
or (lct.nrdconta = 644943      and  lct.nraplica =  88      )
or (lct.nrdconta = 631949      and  lct.nraplica =  51      )
or (lct.nrdconta = 147540      and  lct.nraplica =  118    )
or (lct.nrdconta = 708445      and  lct.nraplica =  21      )
or (lct.nrdconta = 549827      and  lct.nraplica =  80      )
or (lct.nrdconta = 580244      and  lct.nraplica =  189    )
or (lct.nrdconta = 543080      and  lct.nraplica =  244    )
or (lct.nrdconta = 887234      and  lct.nraplica =  18      )
or (lct.nrdconta = 890510      and  lct.nraplica =  3       )
or (lct.nrdconta = 596272      and  lct.nraplica =  23      )
or (lct.nrdconta = 727067      and  lct.nraplica =  22      )
or (lct.nrdconta = 946974      and  lct.nraplica =  8       )
or (lct.nrdconta = 315222      and  lct.nraplica =  54      )
or (lct.nrdconta = 999768      and  lct.nraplica =  3       )
or (lct.nrdconta = 537500      and  lct.nraplica =  72      )
or (lct.nrdconta = 999768      and  lct.nraplica =  2       )
or (lct.nrdconta = 798940      and  lct.nraplica =  16      )
or (lct.nrdconta = 200204      and  lct.nraplica =  69      )
or (lct.nrdconta = 717894      and  lct.nraplica =  239    )
or (lct.nrdconta = 733865      and  lct.nraplica =  71      )
or (lct.nrdconta = 191388      and  lct.nraplica =  136    )
or (lct.nrdconta = 957623      and  lct.nraplica =  2       )
or (lct.nrdconta = 376191      and  lct.nraplica =  173    )
or (lct.nrdconta = 656909      and  lct.nraplica =  12      )
or (lct.nrdconta = 857254      and  lct.nraplica =  33      )
or (lct.nrdconta = 357880      and  lct.nraplica =  42      )
or (lct.nrdconta = 895393      and  lct.nraplica =  43      )
or (lct.nrdconta = 591653      and  lct.nraplica =  2       )
or (lct.nrdconta = 502006      and  lct.nraplica =  14      )
or (lct.nrdconta = 544698      and  lct.nraplica =  77      )
or (lct.nrdconta = 998060      and  lct.nraplica =  2       )
or (lct.nrdconta = 727253      and  lct.nraplica =  8       )
or (lct.nrdconta = 966940      and  lct.nraplica =  2       )
or (lct.nrdconta = 973408      and  lct.nraplica =  4       )
or (lct.nrdconta = 810207      and  lct.nraplica =  16      )
or (lct.nrdconta = 661040      and  lct.nraplica =  41      )
or (lct.nrdconta = 885231      and  lct.nraplica =  9       )
or (lct.nrdconta = 533149      and  lct.nraplica =  30      )
or (lct.nrdconta = 709891      and  lct.nraplica =  94      )
or (lct.nrdconta = 500755      and  lct.nraplica =  20      )
or (lct.nrdconta = 935247      and  lct.nraplica =  7       )
or (lct.nrdconta = 971367      and  lct.nraplica =  3       )
or (lct.nrdconta = 471895      and  lct.nraplica =  24      )
or (lct.nrdconta = 553239      and  lct.nraplica =  9       )
or (lct.nrdconta = 764930      and  lct.nraplica =  7       )
or (lct.nrdconta = 941328      and  lct.nraplica =  13      )
or (lct.nrdconta = 298255      and  lct.nraplica =  75      )
or (lct.nrdconta = 653500      and  lct.nraplica =  131    )
or (lct.nrdconta = 903850      and  lct.nraplica =  25      )
or (lct.nrdconta = 889075      and  lct.nraplica =  16      )
or (lct.nrdconta = 523143      and  lct.nraplica =  110    )
or (lct.nrdconta = 374610      and  lct.nraplica =  83      )
or (lct.nrdconta = 902675      and  lct.nraplica =  1       )
or (lct.nrdconta = 844845      and  lct.nraplica =  2       )
or (lct.nrdconta = 587176      and  lct.nraplica =  90      )
or (lct.nrdconta = 1010468     and  lct.nraplica =  1       )
or (lct.nrdconta = 833142      and  lct.nraplica =  115    )
or (lct.nrdconta = 494623      and  lct.nraplica =  69      )
or (lct.nrdconta = 973416      and  lct.nraplica =  4       )
or (lct.nrdconta = 581887      and  lct.nraplica =  39      )
or (lct.nrdconta = 833452      and  lct.nraplica =  2       )
or (lct.nrdconta = 871117      and  lct.nraplica =  14      )
or (lct.nrdconta = 1010310     and  lct.nraplica =  1       )
or (lct.nrdconta = 508586      and  lct.nraplica =  34      )
or (lct.nrdconta = 937029      and  lct.nraplica =  6       )
or (lct.nrdconta = 857254      and  lct.nraplica =  32      )
or (lct.nrdconta = 936200      and  lct.nraplica =  5       )
or (lct.nrdconta = 585505      and  lct.nraplica =  29      )
or (lct.nrdconta = 625051      and  lct.nraplica =  41      )
or (lct.nrdconta = 625256      and  lct.nraplica =  36      )
or (lct.nrdconta = 647454      and  lct.nraplica =  21      )
or (lct.nrdconta = 801712      and  lct.nraplica =  25      )
or (lct.nrdconta = 877905      and  lct.nraplica =  9       )
or (lct.nrdconta = 877980      and  lct.nraplica =  30      )
or (lct.nrdconta = 969508      and  lct.nraplica =  2       )
or (lct.nrdconta = 428175      and  lct.nraplica =  45      )
or (lct.nrdconta = 619450      and  lct.nraplica =  105    )
or (lct.nrdconta = 694240      and  lct.nraplica =  31      )
or (lct.nrdconta = 784915      and  lct.nraplica =  22      )
or (lct.nrdconta = 813966      and  lct.nraplica =  14      )
or (lct.nrdconta = 856517      and  lct.nraplica =  11      )
or (lct.nrdconta = 932019      and  lct.nraplica =  5       )
or (lct.nrdconta = 932060      and  lct.nraplica =  5       )
or (lct.nrdconta = 933511      and  lct.nraplica =  5       )
or (lct.nrdconta = 933520      and  lct.nraplica =  10      )
or (lct.nrdconta = 934178      and  lct.nraplica =  5       )
or (lct.nrdconta = 934208      and  lct.nraplica =  4       )
or (lct.nrdconta = 934518      and  lct.nraplica =  5       )
or (lct.nrdconta = 935298      and  lct.nraplica =  5       )
or (lct.nrdconta = 935565      and  lct.nraplica =  6       )
or (lct.nrdconta = 940020      and  lct.nraplica =  4       )
or (lct.nrdconta = 940658      and  lct.nraplica =  4       )
or (lct.nrdconta = 941964      and  lct.nraplica =  4       )
or (lct.nrdconta = 941980      and  lct.nraplica =  4       )
or (lct.nrdconta = 942936      and  lct.nraplica =  4       )
or (lct.nrdconta = 944254      and  lct.nraplica =  4       )
or (lct.nrdconta = 335746      and  lct.nraplica =  36      )
or (lct.nrdconta = 504769      and  lct.nraplica =  27      )
or (lct.nrdconta = 506842      and  lct.nraplica =  33      )
or (lct.nrdconta = 567434      and  lct.nraplica =  57      )
or (lct.nrdconta = 594660      and  lct.nraplica =  34      )
or (lct.nrdconta = 604836      and  lct.nraplica =  48      )
or (lct.nrdconta = 611085      and  lct.nraplica =  36      )
or (lct.nrdconta = 646431      and  lct.nraplica =  31      )
or (lct.nrdconta = 646474      and  lct.nraplica =  30      )
or (lct.nrdconta = 672610      and  lct.nraplica =  61      )
or (lct.nrdconta = 672610      and  lct.nraplica =  62      )
or (lct.nrdconta = 674486      and  lct.nraplica =  50      )
or (lct.nrdconta = 686719      and  lct.nraplica =  23      )
or (lct.nrdconta = 709417      and  lct.nraplica =  23      )
or (lct.nrdconta = 709522      and  lct.nraplica =  26      )
or (lct.nrdconta = 797758      and  lct.nraplica =  17      )
or (lct.nrdconta = 314951      and  lct.nraplica =  220    )
or (lct.nrdconta = 465410      and  lct.nraplica =  30      )
or (lct.nrdconta = 623695      and  lct.nraplica =  28      )
or (lct.nrdconta = 633470      and  lct.nraplica =  34      )
or (lct.nrdconta = 673765      and  lct.nraplica =  9       )
or (lct.nrdconta = 684031      and  lct.nraplica =  27      )
or (lct.nrdconta = 691720      and  lct.nraplica =  14      )
or (lct.nrdconta = 694258      and  lct.nraplica =  28      )
or (lct.nrdconta = 737860      and  lct.nraplica =  26      )
or (lct.nrdconta = 768944      and  lct.nraplica =  20      )
or (lct.nrdconta = 778346      and  lct.nraplica =  41      )
or (lct.nrdconta = 816108      and  lct.nraplica =  22      )
or (lct.nrdconta = 838497      and  lct.nraplica =  22      )
or (lct.nrdconta = 847950      and  lct.nraplica =  16      )
or (lct.nrdconta = 939838      and  lct.nraplica =  5       )
or (lct.nrdconta = 718246      and  lct.nraplica =  10      )
or (lct.nrdconta = 625647      and  lct.nraplica =  42      )
or (lct.nrdconta = 787868      and  lct.nraplica =  19      )
or (lct.nrdconta = 803782      and  lct.nraplica =  26      )
or (lct.nrdconta = 803782      and  lct.nraplica =  27      )
or (lct.nrdconta = 812080      and  lct.nraplica =  79      )
or (lct.nrdconta = 927635      and  lct.nraplica =  4       )
or (lct.nrdconta = 875368      and  lct.nraplica =  12      )
or (lct.nrdconta = 927660      and  lct.nraplica =  5       )
or (lct.nrdconta = 994316      and  lct.nraplica =  1       )
or (lct.nrdconta = 761540      and  lct.nraplica =  23      )
or (lct.nrdconta = 918105      and  lct.nraplica =  97      )
or (lct.nrdconta = 841277      and  lct.nraplica =  23      )
or (lct.nrdconta = 956520      and  lct.nraplica =  4       )
or (lct.nrdconta = 205818      and  lct.nraplica =  43      )
or (lct.nrdconta = 208060      and  lct.nraplica =  38      )
or (lct.nrdconta = 306975      and  lct.nraplica =  45      )
or (lct.nrdconta = 308250      and  lct.nraplica =  83      )
or (lct.nrdconta = 394238      and  lct.nraplica =  89      )
or (lct.nrdconta = 396168      and  lct.nraplica =  29      )
or (lct.nrdconta = 398152      and  lct.nraplica =  34      )
or (lct.nrdconta = 478695      and  lct.nraplica =  46      )
or (lct.nrdconta = 600245      and  lct.nraplica =  18      )
or (lct.nrdconta = 624420      and  lct.nraplica =  23      )
or (lct.nrdconta = 624470      and  lct.nraplica =  21      )
or (lct.nrdconta = 696153      and  lct.nraplica =  51      )
or (lct.nrdconta = 709620      and  lct.nraplica =  20      )
or (lct.nrdconta = 719749      and  lct.nraplica =  27      )
or (lct.nrdconta = 779644      and  lct.nraplica =  29      )
or (lct.nrdconta = 299057      and  lct.nraplica =  27      )
or (lct.nrdconta = 371033      and  lct.nraplica =  77      )
or (lct.nrdconta = 371033      and  lct.nraplica =  78      )
or (lct.nrdconta = 371734      and  lct.nraplica =  8       )
or (lct.nrdconta = 425737      and  lct.nraplica =  30      )
or (lct.nrdconta = 506893      and  lct.nraplica =  59      )
or (lct.nrdconta = 542822      and  lct.nraplica =  306    )
or (lct.nrdconta = 583740      and  lct.nraplica =  26      )
or (lct.nrdconta = 621684      and  lct.nraplica =  73      )
or (lct.nrdconta = 691828      and  lct.nraplica =  28      )
or (lct.nrdconta = 693677      and  lct.nraplica =  26      )
or (lct.nrdconta = 442321      and  lct.nraplica =  30      )
or (lct.nrdconta = 466875      and  lct.nraplica =  23      )
or (lct.nrdconta = 469890      and  lct.nraplica =  37      )
or (lct.nrdconta = 487929      and  lct.nraplica =  79      )
or (lct.nrdconta = 491640      and  lct.nraplica =  82      )
or (lct.nrdconta = 646121      and  lct.nraplica =  58      )
or (lct.nrdconta = 683507      and  lct.nraplica =  24      )
or (lct.nrdconta = 683507      and  lct.nraplica =  25      )
or (lct.nrdconta = 683507      and  lct.nraplica =  26      )
or (lct.nrdconta = 691259      and  lct.nraplica =  28      )
or (lct.nrdconta = 692255      and  lct.nraplica =  49      )
or (lct.nrdconta = 773379      and  lct.nraplica =  9       )
or (lct.nrdconta = 817686      and  lct.nraplica =  23      )
or (lct.nrdconta = 219304      and  lct.nraplica =  81      )
or (lct.nrdconta = 404578      and  lct.nraplica =  94      )
or (lct.nrdconta = 408697      and  lct.nraplica =  8       )
or (lct.nrdconta = 566136      and  lct.nraplica =  75      )
or (lct.nrdconta = 655724      and  lct.nraplica =  18      )
or (lct.nrdconta = 821365      and  lct.nraplica =  14      )
or (lct.nrdconta = 854662      and  lct.nraplica =  11      )
or (lct.nrdconta = 854760      and  lct.nraplica =  11      )
or (lct.nrdconta = 854794      and  lct.nraplica =  11      )
or (lct.nrdconta = 855480      and  lct.nraplica =  11      )
or (lct.nrdconta = 855502      and  lct.nraplica =  11      )
or (lct.nrdconta = 855596      and  lct.nraplica =  11      )
or (lct.nrdconta = 856304      and  lct.nraplica =  11      )
or (lct.nrdconta = 856630      and  lct.nraplica =  12      )
or (lct.nrdconta = 856673      and  lct.nraplica =  11      )
or (lct.nrdconta = 935654      and  lct.nraplica =  6       )
or (lct.nrdconta = 263095      and  lct.nraplica =  40      )
or (lct.nrdconta = 267376      and  lct.nraplica =  39      )
or (lct.nrdconta = 268054      and  lct.nraplica =  95      )
or (lct.nrdconta = 347540      and  lct.nraplica =  72      )
or (lct.nrdconta = 347540      and  lct.nraplica =  73      )
or (lct.nrdconta = 358770      and  lct.nraplica =  32      )
or (lct.nrdconta = 381969      and  lct.nraplica =  39      )
or (lct.nrdconta = 510327      and  lct.nraplica =  68      )
or (lct.nrdconta = 510327      and  lct.nraplica =  69      )
or (lct.nrdconta = 510904      and  lct.nraplica =  84      )
or (lct.nrdconta = 510904      and  lct.nraplica =  85      )
or (lct.nrdconta = 510904      and  lct.nraplica =  86      )
or (lct.nrdconta = 513423      and  lct.nraplica =  98      )
or (lct.nrdconta = 520675      and  lct.nraplica =  42      )
or (lct.nrdconta = 523968      and  lct.nraplica =  11      )
or (lct.nrdconta = 608360      and  lct.nraplica =  32      )
or (lct.nrdconta = 790257      and  lct.nraplica =  17      )
or (lct.nrdconta = 794295      and  lct.nraplica =  22      )
or (lct.nrdconta = 794295      and  lct.nraplica =  23      )
or (lct.nrdconta = 794295      and  lct.nraplica =  24      )
or (lct.nrdconta = 796115      and  lct.nraplica =  21      )
or (lct.nrdconta = 847828      and  lct.nraplica =  11      )
or (lct.nrdconta = 335754      and  lct.nraplica =  220    )
or (lct.nrdconta = 557455      and  lct.nraplica =  73      )
or (lct.nrdconta = 856541      and  lct.nraplica =  5       )
or (lct.nrdconta = 999555      and  lct.nraplica =  1       )
or (lct.nrdconta = 328723      and  lct.nraplica =  3       )
or (lct.nrdconta = 542652      and  lct.nraplica =  18      )
or (lct.nrdconta = 583391      and  lct.nraplica =  6       )
or (lct.nrdconta = 742112      and  lct.nraplica =  40      )
or (lct.nrdconta = 814946      and  lct.nraplica =  20      )
or (lct.nrdconta = 169617      and  lct.nraplica =  20      )
or (lct.nrdconta = 219304      and  lct.nraplica =  82      )
or (lct.nrdconta = 851930      and  lct.nraplica =  14      )
or (lct.nrdconta = 901563      and  lct.nraplica =  7       )
or (lct.nrdconta = 660523      and  lct.nraplica =  161    )
or (lct.nrdconta = 781665      and  lct.nraplica =  17      )
or (lct.nrdconta = 874841      and  lct.nraplica =  4       )
or (lct.nrdconta = 428183      and  lct.nraplica =  38      )
or (lct.nrdconta = 589608      and  lct.nraplica =  22      )
or (lct.nrdconta = 589608      and  lct.nraplica =  23      )
or (lct.nrdconta = 808814      and  lct.nraplica =  15      )
or (lct.nrdconta = 335975      and  lct.nraplica =  87      )
or (lct.nrdconta = 686719      and  lct.nraplica =  24      )
or (lct.nrdconta = 710059      and  lct.nraplica =  166    )
or (lct.nrdconta = 962600      and  lct.nraplica =  10      )
or (lct.nrdconta = 787540      and  lct.nraplica =  15      )
or (lct.nrdconta = 818143      and  lct.nraplica =  17      )
or (lct.nrdconta = 868507      and  lct.nraplica =  10      )
or (lct.nrdconta = 954241      and  lct.nraplica =  3       )
or (lct.nrdconta = 965871      and  lct.nraplica =  1       )
or (lct.nrdconta = 671800      and  lct.nraplica =  313    )
or (lct.nrdconta = 671800      and  lct.nraplica =  314    )
or (lct.nrdconta = 671800      and  lct.nraplica =  315    )
or (lct.nrdconta = 671800      and  lct.nraplica =  316    )
or (lct.nrdconta = 597929      and  lct.nraplica =  70      )
or (lct.nrdconta = 639249      and  lct.nraplica =  1       )
or (lct.nrdconta = 963089      and  lct.nraplica =  3       )
or (lct.nrdconta = 529079      and  lct.nraplica =  60      )
or (lct.nrdconta = 750794      and  lct.nraplica =  20      )
or (lct.nrdconta = 753238      and  lct.nraplica =  24      )
or (lct.nrdconta = 605174      and  lct.nraplica =  50      )
or (lct.nrdconta = 790273      and  lct.nraplica =  19      )
or (lct.nrdconta = 539295      and  lct.nraplica =  10      )
or (lct.nrdconta = 595772      and  lct.nraplica =  54      )
or (lct.nrdconta = 647454      and  lct.nraplica =  22      )
or (lct.nrdconta = 695858      and  lct.nraplica =  49      )
or (lct.nrdconta = 877980      and  lct.nraplica =  31      )
or (lct.nrdconta = 992658      and  lct.nraplica =  1       )
or (lct.nrdconta = 675822      and  lct.nraplica =  25      )
or (lct.nrdconta = 488917      and  lct.nraplica =  31      )
or (lct.nrdconta = 674486      and  lct.nraplica =  51      )
or (lct.nrdconta = 674486      and  lct.nraplica =  52      )
or (lct.nrdconta = 721379      and  lct.nraplica =  25      )
or (lct.nrdconta = 677540      and  lct.nraplica =  41      )
or (lct.nrdconta = 809713      and  lct.nraplica =  6       )
or (lct.nrdconta = 756288      and  lct.nraplica =  12      )
or (lct.nrdconta = 912875      and  lct.nraplica =  4       )
or (lct.nrdconta = 992976      and  lct.nraplica =  1       )
or (lct.nrdconta = 867578      and  lct.nraplica =  13      )
or (lct.nrdconta = 943371      and  lct.nraplica =  3       )
or (lct.nrdconta = 977608      and  lct.nraplica =  2       )
or (lct.nrdconta = 811300      and  lct.nraplica =  14      )
or (lct.nrdconta = 874230      and  lct.nraplica =  9       )
or (lct.nrdconta = 575186      and  lct.nraplica =  38      )
or (lct.nrdconta = 788724      and  lct.nraplica =  21      )
or (lct.nrdconta = 788724      and  lct.nraplica =  22      )
or (lct.nrdconta = 842354      and  lct.nraplica =  13      )
or (lct.nrdconta = 984272      and  lct.nraplica =  1       )
or (lct.nrdconta = 846589      and  lct.nraplica =  10      )
or (lct.nrdconta = 892335      and  lct.nraplica =  11      ))  
           and (   lct.idlancto_origem is null
                or exists (select 1
                             from tbcapt_custodia_lanctos lctori
                            where lctori.idlancamento = lct.idlancto_origem
                              and lctori.idsituacao = 8
                              and lctori.cdoperac_cetip is not null))) t2
ON (t1.idaplicacao = t2.idaplicacao and t1.idlancamento = t2.idlancamento)
WHEN MATCHED THEN 
  UPDATE SET T1.IDSITUACAO = 0;
  
merge into cecred.tbcapt_custodia_lanctos t1
using (--cooper 5        
 select lct.*,
               count(1) over(partition by lct.cdcooper, lct.idtipo_arquivo, lct.dtregistro) qtregis,
               row_number() over(partition by lct.cdcooper, lct.idtipo_arquivo, lct.dtregistro order by lct.cdcooper, lct.idtipo_arquivo, lct.dtregistro) nrseqreg
          from (
                -- Registros ligados a RDC PRé e Pós
                select /*+ index (lct tbcapt_custodia_lanctos_idx01) */
                       rda.cdcooper,
                       rda.nrdconta,
                       rda.nraplica,
                       0 cdprodut,
                       lct.*
                  from cecred.craprda                   rda,
                       cecred.tbcapt_custodia_aplicacao apl,
                       cecred.tbcapt_custodia_lanctos   lct
                 where 1=1
                   and lct.idsituacao =1
                   and apl.idaplicacao = lct.idaplicacao
                   and apl.tpaplicacao in (1, 2) -- RDC PRé e Pós
                   and rda.idaplcus = apl.idaplicacao
                      and rda.cdcooper = 5
            and nvl(rda.INSAQTOT,0) =0
        and lct.IDTIPO_LANCTO = 1
        and lct.idtipo_arquivo <> 9 -- Não trazer COnciliação           
                                    and trunc(lct.dtregistro) between to_date('25/06/2021','dd/mm/yyyy') and to_date('25/06/2021','dd/mm/yyyy')
                union
                -- Registros ligados a novo produto de Captação
                select /*+ index (lct tbcapt_custodia_lanctos_idx01) */
                       rac.cdcooper,
                       rac.nrdconta,
                       rac.nraplica,
                       rac.cdprodut,
                       lct.*
                  from cecred.craprac                   rac,
                       cecred.tbcapt_custodia_aplicacao apl,
                       cecred.tbcapt_custodia_lanctos   lct
                   where 1=1
                   and lct.idsituacao =1
                   and apl.idaplicacao = lct.idaplicacao
                   and apl.tpaplicacao in (3, 4) -- PCAPTA Pré e Pós
                   and rac.idaplcus = apl.idaplicacao
                      and rac.cdcooper = 5
            and nvl(rac.IDSAQTOT,0) =0
        and lct.IDTIPO_LANCTO = 1
        and lct.idtipo_arquivo <> 9 -- Não trazer COnciliação           
                 and trunc(lct.dtregistro) between to_date('25/06/2021','dd/mm/yyyy') and to_date('25/06/2021','dd/mm/yyyy')
               ) lct
         WHERE 1=1 -- Não trazer COnciliação
           -- Se este possui registros de origem, os registros de origem devem
           -- ter gerado Numero CETIP e estarem OK
         and ((lct.nrdconta =  53619    and  lct.nraplica =   27    )
or (lct.nrdconta =  243671    and  lct.nraplica =   17    )
or (lct.nrdconta =  157597    and  lct.nraplica =   22    )
or (lct.nrdconta =  256870    and  lct.nraplica =   8      )
or (lct.nrdconta =  193577    and  lct.nraplica =   25    )
or (lct.nrdconta =  56170   and  lct.nraplica =   57        )
or (lct.nrdconta =  24686   and  lct.nraplica =   33        )
or (lct.nrdconta =  128627    and  lct.nraplica =   23    )
or (lct.nrdconta =  114642    and  lct.nraplica =   13    )
or (lct.nrdconta =  138363    and  lct.nraplica =   12    )
or (lct.nrdconta =  167045    and  lct.nraplica =   2      )
or (lct.nrdconta =  109070    and  lct.nraplica =   39    )
or (lct.nrdconta =  99368   and  lct.nraplica =   44        )
or (lct.nrdconta =  119652    and  lct.nraplica =   50    )
or (lct.nrdconta =  281930    and  lct.nraplica =   17    )
or (lct.nrdconta =  104116    and  lct.nraplica =   32    )
or (lct.nrdconta =  241016    and  lct.nraplica =   13    )
or (lct.nrdconta =  208744    and  lct.nraplica =   9      )
or (lct.nrdconta =  266647    and  lct.nraplica =   19    )
or (lct.nrdconta =  264180    and  lct.nraplica =   1      )
or (lct.nrdconta =  61255   and  lct.nraplica =   204      )
or (lct.nrdconta =  281220    and  lct.nraplica =   15    )
or (lct.nrdconta =  301957    and  lct.nraplica =   5      )
or (lct.nrdconta =  46000   and  lct.nraplica =   88        )
or (lct.nrdconta =  131040    and  lct.nraplica =   126  )
or (lct.nrdconta =  256870    and  lct.nraplica =   9      )
or (lct.nrdconta =  10111   and  lct.nraplica =   13        )
or (lct.nrdconta =  238147    and  lct.nraplica =   23    )
or (lct.nrdconta =  59595   and  lct.nraplica =   3          )
or (lct.nrdconta =  144088    and  lct.nraplica =   8      )
or (lct.nrdconta =  137642    and  lct.nraplica =   49    )
or (lct.nrdconta =  224235    and  lct.nraplica =   36    )
or (lct.nrdconta =  293849    and  lct.nraplica =   5      )
or (lct.nrdconta =  266809    and  lct.nraplica =   10    )
or (lct.nrdconta =  84190   and  lct.nraplica =   1          )
or (lct.nrdconta =  173355    and  lct.nraplica =   34    )
or (lct.nrdconta =  173355    and  lct.nraplica =   35    )
or (lct.nrdconta =  201510    and  lct.nraplica =   20    )
or (lct.nrdconta =  58122   and  lct.nraplica =   40        )
or (lct.nrdconta =  74624   and  lct.nraplica =   32        )
or (lct.nrdconta =  70920   and  lct.nraplica =   32        )
or (lct.nrdconta =  193062    and  lct.nraplica =   7      )
or (lct.nrdconta =  147842    and  lct.nraplica =   24    )
or (lct.nrdconta =  304026    and  lct.nraplica =   2      )
or (lct.nrdconta =  255815    and  lct.nraplica =   6      )
or (lct.nrdconta =  161071    and  lct.nraplica =   24    )
or (lct.nrdconta =  175595    and  lct.nraplica =   26    )
or (lct.nrdconta =  180580    and  lct.nraplica =   17    )
or (lct.nrdconta =  206687    and  lct.nraplica =   22    )
or (lct.nrdconta =  238376    and  lct.nraplica =   15    )
or (lct.nrdconta =  276537    and  lct.nraplica =   4      )
or (lct.nrdconta =  257400    and  lct.nraplica =   12    )
or (lct.nrdconta =  156426    and  lct.nraplica =   14    )
or (lct.nrdconta =  256668    and  lct.nraplica =   11    )
or (lct.nrdconta =  306606    and  lct.nraplica =   1      )
or (lct.nrdconta =  307874    and  lct.nraplica =   1      )
or (lct.nrdconta =  128562    and  lct.nraplica =   36    )
or (lct.nrdconta =  189324    and  lct.nraplica =   12    )
or (lct.nrdconta =  120472    and  lct.nraplica =   46    )
or (lct.nrdconta =  120472    and  lct.nraplica =   47    )
or (lct.nrdconta =  141194    and  lct.nraplica =   29    )
or (lct.nrdconta =  145610    and  lct.nraplica =   40    )
or (lct.nrdconta =  149330    and  lct.nraplica =   37    )
or (lct.nrdconta =  161284    and  lct.nraplica =   25    )
or (lct.nrdconta =  181765    and  lct.nraplica =   26    )
or (lct.nrdconta =  194336    and  lct.nraplica =   20    )
or (lct.nrdconta =  214345    and  lct.nraplica =   9      )
or (lct.nrdconta =  230618    and  lct.nraplica =   18    )
or (lct.nrdconta =  243906    and  lct.nraplica =   10    )
or (lct.nrdconta =  243949    and  lct.nraplica =   4      )
or (lct.nrdconta =  243965    and  lct.nraplica =   11    )
or (lct.nrdconta =  255025    and  lct.nraplica =   1      )
or (lct.nrdconta =  81744   and  lct.nraplica =   25        )
or (lct.nrdconta =  94048   and  lct.nraplica =   37        )
or (lct.nrdconta =  107409    and  lct.nraplica =   37    )
or (lct.nrdconta =  111341    and  lct.nraplica =   34    )
or (lct.nrdconta =  123838    and  lct.nraplica =   18    )
or (lct.nrdconta =  126454    and  lct.nraplica =   36    )
or (lct.nrdconta =  131920    and  lct.nraplica =   62    )
or (lct.nrdconta =  149314    and  lct.nraplica =   37    )
or (lct.nrdconta =  149390    and  lct.nraplica =   33    )
or (lct.nrdconta =  157449    and  lct.nraplica =   34    )
or (lct.nrdconta =  160431    and  lct.nraplica =   32    )
or (lct.nrdconta =  176508    and  lct.nraplica =   19    )
or (lct.nrdconta =  179779    and  lct.nraplica =   24    )
or (lct.nrdconta =  187020    and  lct.nraplica =   25    )
or (lct.nrdconta =  211117    and  lct.nraplica =   20    )
or (lct.nrdconta =  95532   and  lct.nraplica =   38        )
or (lct.nrdconta =  208841    and  lct.nraplica =   19    )
or (lct.nrdconta =  247820    and  lct.nraplica =   26    )
or (lct.nrdconta =  251810    and  lct.nraplica =   2      )
or (lct.nrdconta =  252050    and  lct.nraplica =   12    )
or (lct.nrdconta =  259926    and  lct.nraplica =   7      )
or (lct.nrdconta =  260100    and  lct.nraplica =   8      )
or (lct.nrdconta =  260223    and  lct.nraplica =   10    )
or (lct.nrdconta =  260258    and  lct.nraplica =   1      )
or (lct.nrdconta =  301078    and  lct.nraplica =   2      )
or (lct.nrdconta =  141054    and  lct.nraplica =   13    )
or (lct.nrdconta =  141216    and  lct.nraplica =   28    )
or (lct.nrdconta =  158461    and  lct.nraplica =   33    )
or (lct.nrdconta =  236608    and  lct.nraplica =   1      )
or (lct.nrdconta =  308323    and  lct.nraplica =   1      )
or (lct.nrdconta =  50920   and  lct.nraplica =   39        )
or (lct.nrdconta =  141410    and  lct.nraplica =   79    )
or (lct.nrdconta =  146510    and  lct.nraplica =   22    )
or (lct.nrdconta =  160555    and  lct.nraplica =   32    )
or (lct.nrdconta =  179922    and  lct.nraplica =   28    )
or (lct.nrdconta =  247855    and  lct.nraplica =   15    )
or (lct.nrdconta =  155900    and  lct.nraplica =   21    )
or (lct.nrdconta =  175129    and  lct.nraplica =   33    )
or (lct.nrdconta =  222291    and  lct.nraplica =   47    )
or (lct.nrdconta =  222291    and  lct.nraplica =   48    )
or (lct.nrdconta =  79685   and  lct.nraplica =   42        )
or (lct.nrdconta =  159794    and  lct.nraplica =   51    )
or (lct.nrdconta =  167649    and  lct.nraplica =   21    )
or (lct.nrdconta =  187100    and  lct.nraplica =   10    )
or (lct.nrdconta =  191299    and  lct.nraplica =   4      )
or (lct.nrdconta =  191310    and  lct.nraplica =   54    )
or (lct.nrdconta =  191310    and  lct.nraplica =   55    )
or (lct.nrdconta =  209996    and  lct.nraplica =   20    ))
  
           and (   lct.idlancto_origem is null
                or exists (select 1
                             from tbcapt_custodia_lanctos lctori
                            where lctori.idlancamento = lct.idlancto_origem
                              and lctori.idsituacao = 8
                              and lctori.cdoperac_cetip is not null))) t2
ON (t1.idaplicacao = t2.idaplicacao and t1.idlancamento = t2.idlancamento)
WHEN MATCHED THEN 
  UPDATE SET T1.IDSITUACAO = 0;
  
merge into cecred.tbcapt_custodia_lanctos t1
using (select lct.*, --cooper 6 
               count(1) over(partition by lct.cdcooper, lct.idtipo_arquivo, lct.dtregistro) qtregis,
               row_number() over(partition by lct.cdcooper, lct.idtipo_arquivo, lct.dtregistro order by lct.cdcooper, lct.idtipo_arquivo, lct.dtregistro) nrseqreg
          from (
                -- Registros ligados a RDC PRé e Pós
                select /*+ index (lct tbcapt_custodia_lanctos_idx01) */
                       rda.cdcooper,
                       rda.nrdconta,
                       rda.nraplica,
                       0 cdprodut,
                       lct.*
                  from cecred.craprda                   rda,
                       cecred.tbcapt_custodia_aplicacao apl,
                       cecred.tbcapt_custodia_lanctos   lct
                 where 1=1
              and lct.idsituacao =1
                   and apl.idaplicacao = lct.idaplicacao
                   and apl.tpaplicacao in (1, 2) -- RDC PRé e Pós
                   and rda.idaplcus = apl.idaplicacao
                      and rda.cdcooper = 6
            and nvl(rda.INSAQTOT,0) =0
        and lct.IDTIPO_LANCTO = 1
        and lct.idtipo_arquivo <> 9 -- Não trazer COnciliação                 
                                    and trunc(lct.dtregistro) between to_date('25/06/2021','dd/mm/yyyy') and to_date('25/06/2021','dd/mm/yyyy')
                union
                -- Registros ligados a novo produto de Captação
                select /*+ index (lct tbcapt_custodia_lanctos_idx01) */
                       rac.cdcooper,
                       rac.nrdconta,
                       rac.nraplica,
                       rac.cdprodut,
                       lct.*
                  from cecred.craprac                   rac,
                       cecred.tbcapt_custodia_aplicacao apl,
                       cecred.tbcapt_custodia_lanctos   lct
                   where 1=1
                and lct.idsituacao =1
                   and apl.idaplicacao = lct.idaplicacao
                   and apl.tpaplicacao in (3, 4) -- PCAPTA Pré e Pós
                   and rac.idaplcus = apl.idaplicacao
                      and rac.cdcooper = 6
            and nvl(rac.IDSAQTOT,0) =0
        and lct.IDTIPO_LANCTO = 1
        and lct.idtipo_arquivo <> 9 -- Não trazer COnciliação                 
                 and trunc(lct.dtregistro) between to_date('25/06/2021','dd/mm/yyyy') and to_date('25/06/2021','dd/mm/yyyy')
               ) lct
         WHERE 1=1
     and lct.IDTIPO_LANCTO = 1
           -- Se este possui registros de origem, os registros de origem devem
           -- ter gerado Numero CETIP e estarem OK
          and ((lct.nrdconta =  196304  and lct.nraplica =   6    )
or (lct.nrdconta =  130052    and lct.nraplica =   9    )
or (lct.nrdconta =  56359     and lct.nraplica =   128 )
or (lct.nrdconta =  57525     and lct.nraplica =   12   )
or (lct.nrdconta =  79839     and lct.nraplica =   12   )
or (lct.nrdconta =  501484    and lct.nraplica =   131 )
or (lct.nrdconta =  173398    and lct.nraplica =   3    )
or (lct.nrdconta =  107735    and lct.nraplica =   3    )
or (lct.nrdconta =  139246    and lct.nraplica =   7    )
or (lct.nrdconta =  166111    and lct.nraplica =   46   )
or (lct.nrdconta =  184136    and lct.nraplica =   19   )
or (lct.nrdconta =  189278    and lct.nraplica =   16   )
or (lct.nrdconta =  19844     and lct.nraplica =   50   )
or (lct.nrdconta =  504823    and lct.nraplica =   83   )
or (lct.nrdconta =  2577      and lct.nraplica =   47   )
or (lct.nrdconta =  233110    and lct.nraplica =   1    )
or (lct.nrdconta =  135836    and lct.nraplica =   6    )
or (lct.nrdconta =  91693     and lct.nraplica =   4    )
or (lct.nrdconta =  100889    and lct.nraplica =   98   )
or (lct.nrdconta =  159263    and lct.nraplica =   222 )
or (lct.nrdconta =  217336    and lct.nraplica =   1    )
or (lct.nrdconta =  13765     and lct.nraplica =   2    )
or (lct.nrdconta =  149144    and lct.nraplica =   9    )
or (lct.nrdconta =  135836    and lct.nraplica =   5    )
or (lct.nrdconta =  173800    and lct.nraplica =   193 )
or (lct.nrdconta =  201383    and lct.nraplica =   173 )
or (lct.nrdconta =  79855     and lct.nraplica =   22   )
or (lct.nrdconta =  16543     and lct.nraplica =   239 )
or (lct.nrdconta =  19399     and lct.nraplica =   39   )
or (lct.nrdconta =  94277     and lct.nraplica =   66   )
or (lct.nrdconta =  35114     and lct.nraplica =   31   )
or (lct.nrdconta =  60178     and lct.nraplica =   66   )
or (lct.nrdconta =  60607     and lct.nraplica =   61   )
or (lct.nrdconta =  65005     and lct.nraplica =   89   )
or (lct.nrdconta =  153451    and lct.nraplica =   43   )
or (lct.nrdconta =  166111    and lct.nraplica =   43   )
or (lct.nrdconta =  212318    and lct.nraplica =   13   )
or (lct.nrdconta =  502464    and lct.nraplica =   45   )
or (lct.nrdconta =  46604     and lct.nraplica =   27   )
or (lct.nrdconta =  169927    and lct.nraplica =   14   )
or (lct.nrdconta =  173320    and lct.nraplica =   11   )
or (lct.nrdconta =  227137    and lct.nraplica =   8    )
or (lct.nrdconta =  29920     and lct.nraplica =   92   )
or (lct.nrdconta =  166111    and lct.nraplica =   45   )
or (lct.nrdconta =  233110    and lct.nraplica =   2    )
or (lct.nrdconta =  180360    and lct.nraplica =   29   )
or (lct.nrdconta =  101869    and lct.nraplica =   25   )
or (lct.nrdconta =  37249     and lct.nraplica =   25   )
or (lct.nrdconta =  178330    and lct.nraplica =   8    )
or (lct.nrdconta =  224782    and lct.nraplica =   3      )
or (lct.nrdconta =  227137    and lct.nraplica =   9 ) )
           and (   lct.idlancto_origem is null
                or exists (select 1
                             from cecred.tbcapt_custodia_lanctos lctori
                            where lctori.idlancamento = lct.idlancto_origem
                              and lctori.idsituacao = 8
                              and lctori.cdoperac_cetip is not null))) t2
ON (t1.idaplicacao = t2.idaplicacao and t1.idlancamento = t2.idlancamento)
WHEN MATCHED THEN 
  UPDATE SET T1.IDSITUACAO = 0;
  
merge into cecred.tbcapt_custodia_lanctos t1
using (--cooper 7
 select lct.*,
               count(1) over(partition by lct.cdcooper, lct.idtipo_arquivo, lct.dtregistro) qtregis,
               row_number() over(partition by lct.cdcooper, lct.idtipo_arquivo, lct.dtregistro order by lct.cdcooper, lct.idtipo_arquivo, lct.dtregistro) nrseqreg
          from (
                -- Registros ligados a RDC PRé e Pós
                select /*+ index (lct tbcapt_custodia_lanctos_idx01) */
                       rda.cdcooper,
                       rda.nrdconta,
                       rda.nraplica,
                       0 cdprodut,
                       lct.*
                  from cecred.craprda                   rda,
                       cecred.tbcapt_custodia_aplicacao apl,
                       cecred.tbcapt_custodia_lanctos   lct
                 where 1=1
                    and lct.idsituacao =1
                   and apl.idaplicacao = lct.idaplicacao
                   and apl.tpaplicacao in (1, 2) -- RDC PRé e Pós
                   and rda.idaplcus = apl.idaplicacao
                      and rda.cdcooper = 7
            and nvl(rda.INSAQTOT,0) =0
              and lct.IDTIPO_LANCTO = 1
        and lct.idtipo_arquivo <> 9 -- Não trazer COnciliação           
                                    and trunc(lct.dtregistro) between to_date('25/06/2021','dd/mm/yyyy') and to_date('25/06/2021','dd/mm/yyyy')
                union
                -- Registros ligados a novo produto de Captação
                select /*+ index (lct tbcapt_custodia_lanctos_idx01) */
                       rac.cdcooper,
                       rac.nrdconta,
                       rac.nraplica,
                       rac.cdprodut,
                       lct.*
                  from cecred.craprac                   rac,
                       cecred.tbcapt_custodia_aplicacao apl,
                       cecred.tbcapt_custodia_lanctos   lct
                   where 1=1
                   and lct.idsituacao =1
                   and apl.idaplicacao = lct.idaplicacao
                   and apl.tpaplicacao in (3, 4) -- PCAPTA Pré e Pós
                   and rac.idaplcus = apl.idaplicacao
                      and rac.cdcooper = 7
            and nvl(rac.IDSAQTOT,0) =0
              and lct.IDTIPO_LANCTO = 1
        and lct.idtipo_arquivo <> 9 -- Não trazer COnciliação           
                 and trunc(lct.dtregistro) between to_date('25/06/2021','dd/mm/yyyy') and to_date('25/06/2021','dd/mm/yyyy')
               ) lct
         WHERE 1=1 -- Não trazer COnciliação
           -- Se este possui registros de origem, os registros de origem devem
           -- ter gerado Numero CETIP e estarem OK
         and  ((lct.nrdconta =  332607  and lct.nraplica =    5   )
or  (lct.nrdconta =  267090   and lct.nraplica =    11      )
or  (lct.nrdconta =  294756   and lct.nraplica =    62      )
or  (lct.nrdconta =  364320   and lct.nraplica =    8       )
or  (lct.nrdconta =  294756   and lct.nraplica =    61      )
or  (lct.nrdconta =  270156   and lct.nraplica =    12      )
or  (lct.nrdconta =  358576   and lct.nraplica =    19      )
or  (lct.nrdconta =  159611   and lct.nraplica =    3       )
or  (lct.nrdconta =  14834      and lct.nraplica =    29      )
or  (lct.nrdconta =  17922      and lct.nraplica =    19      )
or  (lct.nrdconta =  55077      and lct.nraplica =    28      )
or  (lct.nrdconta =  164640   and lct.nraplica =    70      )
or  (lct.nrdconta =  150380   and lct.nraplica =    31      )
or  (lct.nrdconta =  164640   and lct.nraplica =    77      )
or  (lct.nrdconta =  164640   and lct.nraplica =    69      )
or  (lct.nrdconta =  294756   and lct.nraplica =    60      )
or  (lct.nrdconta =  221325   and lct.nraplica =    90      )
or  (lct.nrdconta =  63312      and lct.nraplica =    83      )
or  (lct.nrdconta =  143405   and lct.nraplica =    111    )
or  (lct.nrdconta =  394424   and lct.nraplica =    2       )
or  (lct.nrdconta =  60780      and lct.nraplica =    59      )
or  (lct.nrdconta =  127981   and lct.nraplica =    27      )
or  (lct.nrdconta =  233447   and lct.nraplica =    33      )
or  (lct.nrdconta =  164640   and lct.nraplica =    72      )
or  (lct.nrdconta =  67172      and lct.nraplica =    6       )
or  (lct.nrdconta =  73709      and lct.nraplica =    80      )
or  (lct.nrdconta =  180238   and lct.nraplica =    48      )
or  (lct.nrdconta =  90395      and lct.nraplica =    32      )
or  (lct.nrdconta =  57444      and lct.nraplica =    71      )
or  (lct.nrdconta =  216860   and lct.nraplica =    82      )
or  (lct.nrdconta =  396702   and lct.nraplica =    1       )
or  (lct.nrdconta =  140635   and lct.nraplica =    180    )
or  (lct.nrdconta =  7846     and lct.nraplica =    32      )
or  (lct.nrdconta =  210498   and lct.nraplica =    74      )
or  (lct.nrdconta =  60780      and lct.nraplica =    60      )
or  (lct.nrdconta =  348589   and lct.nraplica =    1       )
or  (lct.nrdconta =  102768   and lct.nraplica =    35      )
or  (lct.nrdconta =  289825   and lct.nraplica =    2       )
or  (lct.nrdconta =  323845   and lct.nraplica =    1       )
or  (lct.nrdconta =  329002   and lct.nraplica =    3       )
or  (lct.nrdconta =  203530   and lct.nraplica =    65      )
or  (lct.nrdconta =  164640   and lct.nraplica =    73      )
or  (lct.nrdconta =  164640   and lct.nraplica =    71      )
or  (lct.nrdconta =  164640   and lct.nraplica =    75      )
or  (lct.nrdconta =  102210   and lct.nraplica =    8       )
or  (lct.nrdconta =  164640   and lct.nraplica =    76      )
or  (lct.nrdconta =  241504   and lct.nraplica =    47      )
or  (lct.nrdconta =  145246   and lct.nraplica =    21      )
or  (lct.nrdconta =  144568   and lct.nraplica =    119    )
or  (lct.nrdconta =  394424   and lct.nraplica =    1       )
or  (lct.nrdconta =  66672      and lct.nraplica =    18      )
or  (lct.nrdconta =  355933   and lct.nraplica =    3       )
or  (lct.nrdconta =  389579   and lct.nraplica =    2       )
or  (lct.nrdconta =  312860   and lct.nraplica =    38      )
or  (lct.nrdconta =  365084   and lct.nraplica =    29      )
or  (lct.nrdconta =  289248   and lct.nraplica =    5       )
or  (lct.nrdconta =  164640   and lct.nraplica =    74      )
or  (lct.nrdconta =  117501   and lct.nraplica =    31      )
or  (lct.nrdconta =  3689     and lct.nraplica =    128    )
or  (lct.nrdconta =  361658   and lct.nraplica =    5       )
or  (lct.nrdconta =  9849     and lct.nraplica =    11      )
or  (lct.nrdconta =  15660      and lct.nraplica =    38      )
or  (lct.nrdconta =  110442   and lct.nraplica =    30      )
or  (lct.nrdconta =  37214      and lct.nraplica =    11      )
or  (lct.nrdconta =  116556   and lct.nraplica =    24      )
or  (lct.nrdconta =  125091   and lct.nraplica =    29      )
or  (lct.nrdconta =  166499   and lct.nraplica =    66      )
or  (lct.nrdconta =  259039   and lct.nraplica =    93      )
or  (lct.nrdconta =  299898   and lct.nraplica =    63      )
or  (lct.nrdconta =  173150   and lct.nraplica =    29      )
or  (lct.nrdconta =  164720   and lct.nraplica =    36      )
or  (lct.nrdconta =  362182   and lct.nraplica =    6       )
or  (lct.nrdconta =  102040   and lct.nraplica =    25      )
or  (lct.nrdconta =  104000   and lct.nraplica =    2       )
or  (lct.nrdconta =  138169   and lct.nraplica =    33      )
or  (lct.nrdconta =  345172   and lct.nraplica =    9       )
or  (lct.nrdconta =  21253      and lct.nraplica =    48      )
or  (lct.nrdconta =  22330      and lct.nraplica =    30      )
or  (lct.nrdconta =  40070      and lct.nraplica =    38      )
or  (lct.nrdconta =  41661      and lct.nraplica =    37      )
or  (lct.nrdconta =  128473   and lct.nraplica =    44      )
or  (lct.nrdconta =  168718   and lct.nraplica =    44      )
or  (lct.nrdconta =  215112   and lct.nraplica =    22      )
or  (lct.nrdconta =  239739   and lct.nraplica =    9       )
or  (lct.nrdconta =  264130   and lct.nraplica =    17      )
or  (lct.nrdconta =  220094   and lct.nraplica =    88      )
or  (lct.nrdconta =  224588   and lct.nraplica =    8       )
or  (lct.nrdconta =  300896   and lct.nraplica =    19      )
or  (lct.nrdconta =  322032   and lct.nraplica =    36      )
or  (lct.nrdconta =  376698   and lct.nraplica =    8       )
or  (lct.nrdconta =  376728   and lct.nraplica =    8       )
or  (lct.nrdconta =  14346      and lct.nraplica =    36      )
or  (lct.nrdconta =  37575      and lct.nraplica =    69      )
or  (lct.nrdconta =  44717      and lct.nraplica =    58      )
or  (lct.nrdconta =  85790      and lct.nraplica =    38      )
or  (lct.nrdconta =  130206   and lct.nraplica =    82      )
or  (lct.nrdconta =  148806   and lct.nraplica =    30      )
or  (lct.nrdconta =  160300   and lct.nraplica =    32      )
or  (lct.nrdconta =  189081   and lct.nraplica =    65      )
or  (lct.nrdconta =  208434   and lct.nraplica =    40      )
or  (lct.nrdconta =  230600   and lct.nraplica =    33      )
or  (lct.nrdconta =  249017   and lct.nraplica =    7       )
or  (lct.nrdconta =  257052   and lct.nraplica =    32      )
or  (lct.nrdconta =  258920   and lct.nraplica =    30      )
or  (lct.nrdconta =  277487   and lct.nraplica =    25      )
or  (lct.nrdconta =  330272   and lct.nraplica =    112    )
or  (lct.nrdconta =  332062   and lct.nraplica =    39      )
or  (lct.nrdconta =  333034   and lct.nraplica =    47      )
or  (lct.nrdconta =  334367   and lct.nraplica =    35      )
or  (lct.nrdconta =  334766   and lct.nraplica =    27      )
or  (lct.nrdconta =  24821      and lct.nraplica =    117    )
or  (lct.nrdconta =  31020      and lct.nraplica =    102    )
or  (lct.nrdconta =  36781      and lct.nraplica =    39      )
or  (lct.nrdconta =  156248   and lct.nraplica =    32      )
or  (lct.nrdconta =  243159   and lct.nraplica =    13      )
or  (lct.nrdconta =  26743      and lct.nraplica =    57      )
or  (lct.nrdconta =  60771      and lct.nraplica =    48      )
or  (lct.nrdconta =  66281      and lct.nraplica =    97      )
or  (lct.nrdconta =  113000   and lct.nraplica =    44      )
or  (lct.nrdconta =  125180   and lct.nraplica =    36      )
or  (lct.nrdconta =  136921   and lct.nraplica =    37      )
or  (lct.nrdconta =  140090   and lct.nraplica =    39      )
or  (lct.nrdconta =  203530   and lct.nraplica =    64      )
or  (lct.nrdconta =  1422     and lct.nraplica =    34      )
or  (lct.nrdconta =  2712     and lct.nraplica =    44      )
or  (lct.nrdconta =  8729     and lct.nraplica =    33      )
or  (lct.nrdconta =  29360      and lct.nraplica =    38      )
or  (lct.nrdconta =  58491      and lct.nraplica =    43      )
or  (lct.nrdconta =  112356   and lct.nraplica =    92      )
or  (lct.nrdconta =  120707   and lct.nraplica =    33      )
or  (lct.nrdconta =  127230   and lct.nraplica =    40      )
or  (lct.nrdconta =  127647   and lct.nraplica =    43      )
or  (lct.nrdconta =  131164   and lct.nraplica =    36      )
or  (lct.nrdconta =  148300   and lct.nraplica =    77      )
or  (lct.nrdconta =  212873   and lct.nraplica =    64      )
or  (lct.nrdconta =  261025   and lct.nraplica =    88      )
or  (lct.nrdconta =  261025   and lct.nraplica =    89      )
or  (lct.nrdconta =  297224   and lct.nraplica =    10      )
or  (lct.nrdconta =  80357      and lct.nraplica =    81      )
or  (lct.nrdconta =  80659      and lct.nraplica =    44      )
or  (lct.nrdconta =  80756      and lct.nraplica =    71      )
or  (lct.nrdconta =  82309      and lct.nraplica =    26      )
or  (lct.nrdconta =  86487      and lct.nraplica =    27      )
or  (lct.nrdconta =  109142   and lct.nraplica =    37      )
or  (lct.nrdconta =  131474   and lct.nraplica =    28      )
or  (lct.nrdconta =  252549   and lct.nraplica =    179    )
or  (lct.nrdconta =  280992   and lct.nraplica =    34      )
or  (lct.nrdconta =  300845   and lct.nraplica =    22      )
or  (lct.nrdconta =  300853   and lct.nraplica =    21      )
or  (lct.nrdconta =  361658   and lct.nraplica =    6       )
or  (lct.nrdconta =  90689      and lct.nraplica =    24      )
or  (lct.nrdconta =  156906   and lct.nraplica =    38      )
or  (lct.nrdconta =  187526   and lct.nraplica =    36      )
or  (lct.nrdconta =  203149   and lct.nraplica =    47      )
or  (lct.nrdconta =  277304   and lct.nraplica =    25      )
or  (lct.nrdconta =  277312   and lct.nraplica =    25      )
or  (lct.nrdconta =  291919   and lct.nraplica =    11      )
or  (lct.nrdconta =  309842   and lct.nraplica =    5       )
or  (lct.nrdconta =  100943   and lct.nraplica =    36      )
or  (lct.nrdconta =  101028   and lct.nraplica =    35      )
or  (lct.nrdconta =  103462   and lct.nraplica =    43      )
or  (lct.nrdconta =  110124   and lct.nraplica =    46      )
or  (lct.nrdconta =  114847   and lct.nraplica =    37      )
or  (lct.nrdconta =  154083   and lct.nraplica =    32      )
or  (lct.nrdconta =  202460   and lct.nraplica =    40      )
or  (lct.nrdconta =  49352      and lct.nraplica =    35      )
or  (lct.nrdconta =  108480   and lct.nraplica =    30      )
or  (lct.nrdconta =  118869   and lct.nraplica =    75      )
or  (lct.nrdconta =  137731   and lct.nraplica =    22      )
or  (lct.nrdconta =  166570   and lct.nraplica =    46      )
or  (lct.nrdconta =  180700   and lct.nraplica =    93      )
or  (lct.nrdconta =  304166   and lct.nraplica =    5       )
or  (lct.nrdconta =  345830   and lct.nraplica =    9       )
or  (lct.nrdconta =  354406   and lct.nraplica =    7       )
or  (lct.nrdconta =  354406   and lct.nraplica =    8       )
or  (lct.nrdconta =  209007   and lct.nraplica =    18      )
or  (lct.nrdconta =  225304   and lct.nraplica =    93      )
or  (lct.nrdconta =  143570   and lct.nraplica =    46      )
or  (lct.nrdconta =  172588   and lct.nraplica =    32      )
or  (lct.nrdconta =  233854   and lct.nraplica =    31      )
or  (lct.nrdconta =  34452      and lct.nraplica =    6       )
or  (lct.nrdconta =  68357      and lct.nraplica =    22      )
or  (lct.nrdconta =  80667      and lct.nraplica =    16      )
or  (lct.nrdconta =  360295   and lct.nraplica =    9       )
or  (lct.nrdconta =  116165   and lct.nraplica =    26      ))  
           and (   lct.idlancto_origem is null
                or exists (select 1
                             from cecred.tbcapt_custodia_lanctos lctori
                            where lctori.idlancamento = lct.idlancto_origem
                              and lctori.idsituacao = 8
                              and lctori.cdoperac_cetip is not null))) t2
ON (t1.idaplicacao = t2.idaplicacao and t1.idlancamento = t2.idlancamento)
WHEN MATCHED THEN 
  UPDATE SET T1.IDSITUACAO = 0;
  
merge into cecred.tbcapt_custodia_lanctos t1
using (---cooper 8
 select lct.*,
               count(1) over(partition by lct.cdcooper, lct.idtipo_arquivo, lct.dtregistro) qtregis,
               row_number() over(partition by lct.cdcooper, lct.idtipo_arquivo, lct.dtregistro order by lct.cdcooper, lct.idtipo_arquivo, lct.dtregistro) nrseqreg
          from (
                -- Registros ligados a RDC PRé e Pós
                select /*+ index (lct tbcapt_custodia_lanctos_idx01) */
                       rda.cdcooper,
                       rda.nrdconta,
                       rda.nraplica,
                       0 cdprodut,
                       lct.*
                  from cecred.craprda                   rda,
                       cecred.tbcapt_custodia_aplicacao apl,
                       cecred.tbcapt_custodia_lanctos   lct
                 where 1=1
                   and lct.idsituacao =1
                   and apl.idaplicacao = lct.idaplicacao
                   and apl.tpaplicacao in (1, 2) -- RDC PRé e Pós
                   and rda.idaplcus = apl.idaplicacao
                      and rda.cdcooper = 8
            and nvl(rda.INSAQTOT,0) =0
              and lct.IDTIPO_LANCTO = 1
        and lct.idtipo_arquivo <> 9 -- Não trazer COnciliação           
                                    and trunc(lct.dtregistro) between to_date('25/06/2021','dd/mm/yyyy') and to_date('25/06/2021','dd/mm/yyyy')
                union
                -- Registros ligados a novo produto de Captação
                select /*+ index (lct tbcapt_custodia_lanctos_idx01) */
                       rac.cdcooper,
                       rac.nrdconta,
                       rac.nraplica,
                       rac.cdprodut,
                       lct.*
                  from cecred.craprac                   rac,
                       cecred.tbcapt_custodia_aplicacao apl,
                       cecred.tbcapt_custodia_lanctos   lct
                   where 1=1
                   and lct.idsituacao =1
                   and apl.idaplicacao = lct.idaplicacao
                   and apl.tpaplicacao in (3, 4) -- PCAPTA Pré e Pós
                   and rac.idaplcus = apl.idaplicacao
                      and rac.cdcooper = 8
            and nvl(rac.IDSAQTOT,0) =0
        and lct.IDTIPO_LANCTO = 1
        and lct.idtipo_arquivo <> 9 -- Não trazer COnciliação                 
                 and trunc(lct.dtregistro) between to_date('25/06/2021','dd/mm/yyyy') and to_date('25/06/2021','dd/mm/yyyy')
               ) lct
         WHERE 1=1 -- Não trazer COnciliação
           -- Se este possui registros de origem, os registros de origem devem
           -- ter gerado Numero CETIP e estarem OK
           and  ((lct.nrdconta =  5894  and lct.nraplica =  119 )
or  (lct.nrdconta =  26310  and lct.nraplica =  46   )
or  (lct.nrdconta =  4421 and lct.nraplica =  40   )
or  (lct.nrdconta =  22462  and lct.nraplica =  24   )
or  (lct.nrdconta =  710    and lct.nraplica =  38   )
or  (lct.nrdconta =  7633 and lct.nraplica =  25   )
or  (lct.nrdconta =  27197  and lct.nraplica =  23   )
or  (lct.nrdconta =  27600  and lct.nraplica =  863 )
or  (lct.nrdconta =  29475  and lct.nraplica =  129 )
or  (lct.nrdconta =  31348  and lct.nraplica =  59   )
or  (lct.nrdconta =  31399  and lct.nraplica =  36   )
or  (lct.nrdconta =  28207  and lct.nraplica =  54   )
or  (lct.nrdconta =  30260  and lct.nraplica =  36   )
or  (lct.nrdconta =  30945  and lct.nraplica =  98   )
or  (lct.nrdconta =  53376  and lct.nraplica =  7     )
or  (lct.nrdconta =  37680  and lct.nraplica =  28   )
or  (lct.nrdconta =  46116  and lct.nraplica =  4     )
or  (lct.nrdconta =  35548  and lct.nraplica =  32   )
or  (lct.nrdconta =  15989  and lct.nraplica =  24   ))
           and (   lct.idlancto_origem is null
                or exists (select 1
                             from cecred.tbcapt_custodia_lanctos lctori
                            where lctori.idlancamento = lct.idlancto_origem
                              and lctori.idsituacao = 8
                              and lctori.cdoperac_cetip is not null))) t2
ON (t1.idaplicacao = t2.idaplicacao and t1.idlancamento = t2.idlancamento)
WHEN MATCHED THEN 
  UPDATE SET T1.IDSITUACAO = 0;
  
merge into cecred.tbcapt_custodia_lanctos t1
using (--cooper 9
 select lct.*,
               count(1) over(partition by lct.cdcooper, lct.idtipo_arquivo, lct.dtregistro) qtregis,
               row_number() over(partition by lct.cdcooper, lct.idtipo_arquivo, lct.dtregistro order by lct.cdcooper, lct.idtipo_arquivo, lct.dtregistro) nrseqreg
          from (
                -- Registros ligados a RDC PRé e Pós
                select /*+ index (lct tbcapt_custodia_lanctos_idx01) */
                       rda.cdcooper,
                       rda.nrdconta,
                       rda.nraplica,
                       0 cdprodut,
                       lct.*
                  from cecred.craprda                   rda,
                       cecred.tbcapt_custodia_aplicacao apl,
                       cecred.tbcapt_custodia_lanctos   lct
                 where 1=1
                  and lct.idsituacao =1
                   and apl.idaplicacao = lct.idaplicacao
                   and apl.tpaplicacao in (1, 2) -- RDC PRé e Pós
                   and rda.idaplcus = apl.idaplicacao
                   and rda.cdcooper = 9
          and nvl(rda.INSAQTOT,0) =0
          and lct.IDTIPO_LANCTO = 1
          and lct.idtipo_arquivo <> 9 -- Não trazer COnciliação           
          and trunc(lct.dtregistro) between to_date('25/06/2021','dd/mm/yyyy') and to_date('25/06/2021','dd/mm/yyyy')
                union
                -- Registros ligados a novo produto de Captação
                select /*+ index (lct tbcapt_custodia_lanctos_idx01) */
                       rac.cdcooper,
                       rac.nrdconta,
                       rac.nraplica,
                       rac.cdprodut,
                       lct.*
                  from cecred.craprac                   rac,
                       cecred.tbcapt_custodia_aplicacao apl,
                       cecred.tbcapt_custodia_lanctos   lct
                   where 1=1
               and lct.idsituacao =1
                   and apl.idaplicacao = lct.idaplicacao
                   and apl.tpaplicacao in (3, 4) -- PCAPTA Pré e Pós
                   and rac.idaplcus = apl.idaplicacao
                    and rac.cdcooper = 9
          and nvl(rac.IDSAQTOT,0) =0
          and lct.IDTIPO_LANCTO = 1
        and lct.idtipo_arquivo <> 9 -- Não trazer COnciliação           
                 and trunc(lct.dtregistro) between to_date('25/06/2021','dd/mm/yyyy') and to_date('25/06/2021','dd/mm/yyyy')
               ) lct
         WHERE 1=1 -- Não trazer COnciliação
           -- Se este possui registros de origem, os registros de origem devem
           -- ter gerado Numero CETIP e estarem OK
           and ((lct.nrdconta = 406066    and  lct.nraplica = 3 )
or (lct.nrdconta = 18902    and  lct.nraplica = 57     )
or (lct.nrdconta = 901490   and  lct.nraplica = 48     )
or (lct.nrdconta = 208248   and  lct.nraplica = 5     )
or (lct.nrdconta = 291692   and  lct.nraplica = 1     )
or (lct.nrdconta = 50636    and  lct.nraplica = 105   )
or (lct.nrdconta = 361127   and  lct.nraplica = 28     )
or (lct.nrdconta = 18902    and  lct.nraplica = 58     )
or (lct.nrdconta = 368644   and  lct.nraplica = 7     )
or (lct.nrdconta = 121070   and  lct.nraplica = 23     )
or (lct.nrdconta = 377538   and  lct.nraplica = 18     )
or (lct.nrdconta = 272175   and  lct.nraplica = 1     )
or (lct.nrdconta = 310484   and  lct.nraplica = 17     )
or (lct.nrdconta = 121649   and  lct.nraplica = 17     )
or (lct.nrdconta = 18902    and  lct.nraplica = 56     )
or (lct.nrdconta = 251089   and  lct.nraplica = 9     )
or (lct.nrdconta = 8435     and  lct.nraplica = 109   )
or (lct.nrdconta = 1481     and  lct.nraplica = 86     )
or (lct.nrdconta = 388920   and  lct.nraplica = 35     )
or (lct.nrdconta = 415138   and  lct.nraplica = 1     )
or (lct.nrdconta = 234257   and  lct.nraplica = 34     )
or (lct.nrdconta = 167169   and  lct.nraplica = 42     )
or (lct.nrdconta = 354899   and  lct.nraplica = 6     )
or (lct.nrdconta = 417939   and  lct.nraplica = 1     )
or (lct.nrdconta = 354651   and  lct.nraplica = 6     )
or (lct.nrdconta = 326020   and  lct.nraplica = 3     )
or (lct.nrdconta = 360767   and  lct.nraplica = 10     )
or (lct.nrdconta = 399132   and  lct.nraplica = 4     )
or (lct.nrdconta = 99910    and  lct.nraplica = 106   )
or (lct.nrdconta = 297380   and  lct.nraplica = 2     )
or (lct.nrdconta = 336661   and  lct.nraplica = 21     )
or (lct.nrdconta = 345407   and  lct.nraplica = 2     )
or (lct.nrdconta = 202932   and  lct.nraplica = 1     )
or (lct.nrdconta = 324590   and  lct.nraplica = 25     )
or (lct.nrdconta = 58076    and  lct.nraplica = 24     )
or (lct.nrdconta = 369918   and  lct.nraplica = 10     )
or (lct.nrdconta = 260053   and  lct.nraplica = 3     )
or (lct.nrdconta = 352926   and  lct.nraplica = 16     )
or (lct.nrdconta = 263125   and  lct.nraplica = 12     )
or (lct.nrdconta = 224014   and  lct.nraplica = 7     )
or (lct.nrdconta = 26980    and  lct.nraplica = 43     )
or (lct.nrdconta = 204021   and  lct.nraplica = 25     )
or (lct.nrdconta = 362301   and  lct.nraplica = 1     )
or (lct.nrdconta = 89249    and  lct.nraplica = 42     )
or (lct.nrdconta = 43761    and  lct.nraplica = 57     )
or (lct.nrdconta = 416983   and  lct.nraplica = 2     )
or (lct.nrdconta = 340650   and  lct.nraplica = 8     )
or (lct.nrdconta = 901792   and  lct.nraplica = 39     )
or (lct.nrdconta = 310778   and  lct.nraplica = 20     )
or (lct.nrdconta = 349445   and  lct.nraplica = 11     )
or (lct.nrdconta = 349445   and  lct.nraplica = 12     )
or (lct.nrdconta = 150398   and  lct.nraplica = 16     )
or (lct.nrdconta = 250708   and  lct.nraplica = 1     )
or (lct.nrdconta = 73326    and  lct.nraplica = 39     )
or (lct.nrdconta = 149063   and  lct.nraplica = 19     )
or (lct.nrdconta = 172936   and  lct.nraplica = 11     )
or (lct.nrdconta = 172979   and  lct.nraplica = 36     )
or (lct.nrdconta = 101745   and  lct.nraplica = 55     )
or (lct.nrdconta = 397156   and  lct.nraplica = 5     )
or (lct.nrdconta = 107514   and  lct.nraplica = 78     )
or (lct.nrdconta = 192791   and  lct.nraplica = 11     )
or (lct.nrdconta = 11185    and  lct.nraplica = 36     )
or (lct.nrdconta = 173428   and  lct.nraplica = 26     )
or (lct.nrdconta = 180939   and  lct.nraplica = 1     )
or (lct.nrdconta = 188700   and  lct.nraplica = 3     )
or (lct.nrdconta = 406350   and  lct.nraplica = 2     )
or (lct.nrdconta = 354023   and  lct.nraplica = 8     )
or (lct.nrdconta = 77402    and  lct.nraplica = 22     )
or (lct.nrdconta = 89150    and  lct.nraplica = 92     )
or (lct.nrdconta = 217786   and  lct.nraplica = 3     )
or (lct.nrdconta = 155721   and  lct.nraplica = 23     )
or (lct.nrdconta = 340243   and  lct.nraplica = 13     )
or (lct.nrdconta = 275441   and  lct.nraplica = 3     )
or (lct.nrdconta = 366480   and  lct.nraplica = 8     )
or (lct.nrdconta = 416568   and  lct.nraplica = 1     )
or (lct.nrdconta = 321230   and  lct.nraplica = 16     )
or (lct.nrdconta = 349380   and  lct.nraplica = 11     )
or (lct.nrdconta = 349445   and  lct.nraplica = 13     )
or (lct.nrdconta = 354899   and  lct.nraplica = 8     )
or (lct.nrdconta = 303755   and  lct.nraplica = 11     )
or (lct.nrdconta = 347132   and  lct.nraplica = 11     )
or (lct.nrdconta = 350222   and  lct.nraplica = 11     )
or (lct.nrdconta = 249939   and  lct.nraplica = 28     )
or (lct.nrdconta = 28010    and  lct.nraplica = 27     )
or (lct.nrdconta = 229350   and  lct.nraplica = 74     )
or (lct.nrdconta = 286613   and  lct.nraplica = 15     )
or (lct.nrdconta = 42510    and  lct.nraplica = 87     )
or (lct.nrdconta = 42510    and  lct.nraplica = 88     )
or (lct.nrdconta = 42510    and  lct.nraplica = 89     )
or (lct.nrdconta = 42510    and  lct.nraplica = 90     )
or (lct.nrdconta = 116637   and  lct.nraplica = 32     )
or (lct.nrdconta = 301507   and  lct.nraplica = 16     )
or (lct.nrdconta = 347469   and  lct.nraplica = 10     )
or (lct.nrdconta = 121070   and  lct.nraplica = 22     )
or (lct.nrdconta = 21490    and  lct.nraplica = 33     )
or (lct.nrdconta = 50997    and  lct.nraplica = 30     )
or (lct.nrdconta = 115223   and  lct.nraplica = 23     )
or (lct.nrdconta = 809      and  lct.nraplica = 107   )
or (lct.nrdconta = 14990    and  lct.nraplica = 16     )
or (lct.nrdconta = 16780    and  lct.nraplica = 133   )
or (lct.nrdconta = 20672    and  lct.nraplica = 28     )
or (lct.nrdconta = 25410    and  lct.nraplica = 60     )
or (lct.nrdconta = 29777    and  lct.nraplica = 36     )
or (lct.nrdconta = 59293    and  lct.nraplica = 37     )
or (lct.nrdconta = 73326    and  lct.nraplica = 38     )
or (lct.nrdconta = 80675    and  lct.nraplica = 37     )
or (lct.nrdconta = 122939   and  lct.nraplica = 65     )
or (lct.nrdconta = 124265   and  lct.nraplica = 55     )
or (lct.nrdconta = 130753   and  lct.nraplica = 50     )
or (lct.nrdconta = 130788   and  lct.nraplica = 33     )
or (lct.nrdconta = 130826   and  lct.nraplica = 26     )
or (lct.nrdconta = 130893   and  lct.nraplica = 40     )
or (lct.nrdconta = 132268   and  lct.nraplica = 48     )
or (lct.nrdconta = 146412   and  lct.nraplica = 37     )
or (lct.nrdconta = 146692   and  lct.nraplica = 27     )
or (lct.nrdconta = 146706   and  lct.nraplica = 39     )
or (lct.nrdconta = 161420   and  lct.nraplica = 172   )
or (lct.nrdconta = 162590   and  lct.nraplica = 38     )
or (lct.nrdconta = 220868   and  lct.nraplica = 36     )
or (lct.nrdconta = 248002   and  lct.nraplica = 1     )
or (lct.nrdconta = 253855   and  lct.nraplica = 5     )
or (lct.nrdconta = 280313   and  lct.nraplica = 9     )
or (lct.nrdconta = 296295   and  lct.nraplica = 16     )
or (lct.nrdconta = 19623    and  lct.nraplica = 42     )
or (lct.nrdconta = 29580    and  lct.nraplica = 39     )
or (lct.nrdconta = 46663    and  lct.nraplica = 38     )
or (lct.nrdconta = 50512    and  lct.nraplica = 59     )
or (lct.nrdconta = 85740    and  lct.nraplica = 10     )
or (lct.nrdconta = 141089   and  lct.nraplica = 55     )
or (lct.nrdconta = 200476   and  lct.nraplica = 1     )
or (lct.nrdconta = 110612   and  lct.nraplica = 39     )
or (lct.nrdconta = 150703   and  lct.nraplica = 47     )
or (lct.nrdconta = 280470   and  lct.nraplica = 45     )
or (lct.nrdconta = 323187   and  lct.nraplica = 20     )
or (lct.nrdconta = 16357    and  lct.nraplica = 109   )
or (lct.nrdconta = 17680    and  lct.nraplica = 35     )
or (lct.nrdconta = 122025   and  lct.nraplica = 25     )
or (lct.nrdconta = 140988   and  lct.nraplica = 40     )
or (lct.nrdconta = 196983   and  lct.nraplica = 25     )
or (lct.nrdconta = 275956   and  lct.nraplica = 21     )
or (lct.nrdconta = 312029   and  lct.nraplica = 17     )
or (lct.nrdconta = 329967   and  lct.nraplica = 13     )
or (lct.nrdconta = 365009   and  lct.nraplica = 10     )
or (lct.nrdconta = 399132   and  lct.nraplica = 3     )
or (lct.nrdconta = 399620   and  lct.nraplica = 4     )
or (lct.nrdconta = 40150    and  lct.nraplica = 19     )
or (lct.nrdconta = 87726    and  lct.nraplica = 22     )
or (lct.nrdconta = 114383   and  lct.nraplica = 24     )
or (lct.nrdconta = 173576   and  lct.nraplica = 2     )
or (lct.nrdconta = 245550   and  lct.nraplica = 29     )
or (lct.nrdconta = 251763   and  lct.nraplica = 26     )
or (lct.nrdconta = 251763   and  lct.nraplica = 27     )
or (lct.nrdconta = 287920   and  lct.nraplica = 13     )
or (lct.nrdconta = 297577   and  lct.nraplica = 4     )
or (lct.nrdconta = 329142   and  lct.nraplica = 15     )
or (lct.nrdconta = 32778    and  lct.nraplica = 33     )
or (lct.nrdconta = 35998    and  lct.nraplica = 21     )
or (lct.nrdconta = 37192    and  lct.nraplica = 38     )
or (lct.nrdconta = 38156    and  lct.nraplica = 33     )
or (lct.nrdconta = 40711    and  lct.nraplica = 46     )
or (lct.nrdconta = 40720    and  lct.nraplica = 51     )
or (lct.nrdconta = 58785    and  lct.nraplica = 45     )
or (lct.nrdconta = 58793    and  lct.nraplica = 24     )
or (lct.nrdconta = 61255    and  lct.nraplica = 36     )
or (lct.nrdconta = 64874    and  lct.nraplica = 25     )
or (lct.nrdconta = 145300   and  lct.nraplica = 35     )
or (lct.nrdconta = 161837   and  lct.nraplica = 41     )
or (lct.nrdconta = 161870   and  lct.nraplica = 41     )
or (lct.nrdconta = 161900   and  lct.nraplica = 44     )
or (lct.nrdconta = 185175   and  lct.nraplica = 36     )
or (lct.nrdconta = 225720   and  lct.nraplica = 23     )
or (lct.nrdconta = 275743   and  lct.nraplica = 18     )
or (lct.nrdconta = 339679   and  lct.nraplica = 11     )
or (lct.nrdconta = 344214   and  lct.nraplica = 15     )
or (lct.nrdconta = 346497   and  lct.nraplica = 10     )
or (lct.nrdconta = 361550   and  lct.nraplica = 9     )
or (lct.nrdconta = 416622   and  lct.nraplica = 1     )
or (lct.nrdconta = 139416   and  lct.nraplica = 36     )
or (lct.nrdconta = 159263   and  lct.nraplica = 15     )
or (lct.nrdconta = 264091   and  lct.nraplica = 9     )
or (lct.nrdconta = 280445   and  lct.nraplica = 18     )
or (lct.nrdconta = 362484   and  lct.nraplica = 22     )
or (lct.nrdconta = 135453   and  lct.nraplica = 20     )
or (lct.nrdconta = 158526   and  lct.nraplica = 15     )
or (lct.nrdconta = 274089   and  lct.nraplica = 15     )
or (lct.nrdconta = 148423   and  lct.nraplica = 33     )
or (lct.nrdconta = 202924   and  lct.nraplica = 13     )
or (lct.nrdconta = 234389   and  lct.nraplica = 15     )
or (lct.nrdconta = 271845   and  lct.nraplica = 11     )
or (lct.nrdconta = 271861   and  lct.nraplica = 11     )
or (lct.nrdconta = 379085   and  lct.nraplica = 5     )
or (lct.nrdconta = 379107   and  lct.nraplica = 5     )
or (lct.nrdconta = 398004   and  lct.nraplica = 3     )
or (lct.nrdconta = 298603   and  lct.nraplica = 1     )
or (lct.nrdconta = 380288   and  lct.nraplica = 3     )
or (lct.nrdconta = 184594   and  lct.nraplica = 22     )
or (lct.nrdconta = 221210   and  lct.nraplica = 7     )
or (lct.nrdconta = 254932   and  lct.nraplica = 24     )
or (lct.nrdconta = 265942   and  lct.nraplica = 23     )
or (lct.nrdconta = 315044   and  lct.nraplica = 14     )
or (lct.nrdconta = 323420   and  lct.nraplica = 17     )
or (lct.nrdconta = 329517   and  lct.nraplica = 6     )
or (lct.nrdconta = 355143   and  lct.nraplica = 3     )
or (lct.nrdconta = 320617   and  lct.nraplica = 15     )
or (lct.nrdconta = 194280   and  lct.nraplica = 36     )
or (lct.nrdconta = 240362   and  lct.nraplica = 30     )
or (lct.nrdconta = 246948   and  lct.nraplica = 26     )
or (lct.nrdconta = 288241   and  lct.nraplica = 20     )
or (lct.nrdconta = 288519   and  lct.nraplica = 21     )
or (lct.nrdconta = 331414   and  lct.nraplica = 1     )
or (lct.nrdconta = 354007   and  lct.nraplica = 10     )
or (lct.nrdconta = 292265   and  lct.nraplica = 2     )
or (lct.nrdconta = 408891   and  lct.nraplica = 2     )
or (lct.nrdconta = 413208   and  lct.nraplica = 1     )
or (lct.nrdconta = 413283   and  lct.nraplica = 1     )
or (lct.nrdconta = 346802   and  lct.nraplica = 18     )
or (lct.nrdconta = 245046   and  lct.nraplica = 246   )
or (lct.nrdconta = 247235   and  lct.nraplica = 2     )
or (lct.nrdconta = 339415   and  lct.nraplica = 7     )
or (lct.nrdconta = 406848   and  lct.nraplica = 2     )
or (lct.nrdconta = 331260   and  lct.nraplica = 10     )
or (lct.nrdconta = 385948   and  lct.nraplica = 8     )
or (lct.nrdconta = 200042   and  lct.nraplica = 39     )
or (lct.nrdconta = 201430   and  lct.nraplica = 16     )
or (lct.nrdconta = 210528   and  lct.nraplica = 21     )
or (lct.nrdconta = 313009   and  lct.nraplica = 15     )
or (lct.nrdconta = 314048   and  lct.nraplica = 12     )
or (lct.nrdconta = 314072   and  lct.nraplica = 16     )
or (lct.nrdconta = 315567   and  lct.nraplica = 15     )
or (lct.nrdconta = 276405   and  lct.nraplica = 14     )
or (lct.nrdconta = 294128   and  lct.nraplica = 18     )
or (lct.nrdconta = 297364   and  lct.nraplica = 24     )
or (lct.nrdconta = 304875   and  lct.nraplica = 22     )
or (lct.nrdconta = 305685   and  lct.nraplica = 18     )
or (lct.nrdconta = 318396   and  lct.nraplica = 21     )
or (lct.nrdconta = 318574   and  lct.nraplica = 16     )
or (lct.nrdconta = 318604   and  lct.nraplica = 20     )
or (lct.nrdconta = 319350   and  lct.nraplica = 15     )
or (lct.nrdconta = 319767   and  lct.nraplica = 7     )
or (lct.nrdconta = 319899   and  lct.nraplica = 9     )
or (lct.nrdconta = 322180   and  lct.nraplica = 14     )
or (lct.nrdconta = 322229   and  lct.nraplica = 17     )
or (lct.nrdconta = 323012   and  lct.nraplica = 15     )
or (lct.nrdconta = 323055   and  lct.nraplica = 8     )
or (lct.nrdconta = 324469   and  lct.nraplica = 12     )
or (lct.nrdconta = 325376   and  lct.nraplica = 20     )
or (lct.nrdconta = 327220   and  lct.nraplica = 14     )
or (lct.nrdconta = 328898   and  lct.nraplica = 17     )
or (lct.nrdconta = 332283   and  lct.nraplica = 15     )
or (lct.nrdconta = 332470   and  lct.nraplica = 12     )
or (lct.nrdconta = 332658   and  lct.nraplica = 14     )
or (lct.nrdconta = 332674   and  lct.nraplica = 12     )
or (lct.nrdconta = 332747   and  lct.nraplica = 12     )
or (lct.nrdconta = 337358   and  lct.nraplica = 11     )
or (lct.nrdconta = 337676   and  lct.nraplica = 12     )
or (lct.nrdconta = 339385   and  lct.nraplica = 11     )
or (lct.nrdconta = 341479   and  lct.nraplica = 11     )
or (lct.nrdconta = 343560   and  lct.nraplica = 10     )
or (lct.nrdconta = 343676   and  lct.nraplica = 11     )
or (lct.nrdconta = 350257   and  lct.nraplica = 10     )
or (lct.nrdconta = 351466   and  lct.nraplica = 12     )
or (lct.nrdconta = 352098   and  lct.nraplica = 13     )
or (lct.nrdconta = 352357   and  lct.nraplica = 10     )
or (lct.nrdconta = 354074   and  lct.nraplica = 11     )
or (lct.nrdconta = 354252   and  lct.nraplica = 11     )
or (lct.nrdconta = 356204   and  lct.nraplica = 11     )
or (lct.nrdconta = 361267   and  lct.nraplica = 4     )
or (lct.nrdconta = 394734   and  lct.nraplica = 3     )
or (lct.nrdconta = 392170   and  lct.nraplica = 1     )
or (lct.nrdconta = 395803   and  lct.nraplica = 5     )
or (lct.nrdconta = 4030     and  lct.nraplica = 133   )
or (lct.nrdconta = 123650   and  lct.nraplica = 30     )
or (lct.nrdconta = 248002   and  lct.nraplica = 2     )
or (lct.nrdconta = 353981   and  lct.nraplica = 11     )
or (lct.nrdconta = 35394    and  lct.nraplica = 44     )
or (lct.nrdconta = 312053   and  lct.nraplica = 18     )
or (lct.nrdconta = 355640   and  lct.nraplica = 5     )
or (lct.nrdconta = 361178   and  lct.nraplica = 10     )
or (lct.nrdconta = 219894   and  lct.nraplica = 34     )
or (lct.nrdconta = 229342   and  lct.nraplica = 31     )
or (lct.nrdconta = 229989   and  lct.nraplica = 27     )
or (lct.nrdconta = 33723    and  lct.nraplica = 9     )
or (lct.nrdconta = 153079   and  lct.nraplica = 23     )
or (lct.nrdconta = 234397   and  lct.nraplica = 28     )
or (lct.nrdconta = 378534   and  lct.nraplica = 5     )
or (lct.nrdconta = 391034   and  lct.nraplica = 2     )
or (lct.nrdconta = 371076   and  lct.nraplica = 5     )
or (lct.nrdconta = 373176   and  lct.nraplica = 3     )
or (lct.nrdconta = 414166   and  lct.nraplica = 3     )
or (lct.nrdconta = 415405   and  lct.nraplica = 1     )
or (lct.nrdconta = 245950   and  lct.nraplica = 28     )
or (lct.nrdconta = 301582   and  lct.nraplica = 12     )
or (lct.nrdconta = 373753   and  lct.nraplica = 6     )
or (lct.nrdconta = 377198   and  lct.nraplica = 5     )
or (lct.nrdconta = 397040   and  lct.nraplica = 1     )
or (lct.nrdconta = 403296   and  lct.nraplica = 2     )
or (lct.nrdconta = 312347   and  lct.nraplica = 16     )
or (lct.nrdconta = 354651   and  lct.nraplica = 7     )
or (lct.nrdconta = 377171   and  lct.nraplica = 7     )
or (lct.nrdconta = 291501   and  lct.nraplica = 3     )
or (lct.nrdconta = 377740   and  lct.nraplica = 10     )
or (lct.nrdconta = 409332   and  lct.nraplica = 2     )
or (lct.nrdconta = 354899   and  lct.nraplica = 7     ))
           and (   lct.idlancto_origem is null
                or exists (select 1
                             from cecred.tbcapt_custodia_lanctos lctori
                            where lctori.idlancamento = lct.idlancto_origem
                              and lctori.idsituacao = 8
                              and lctori.cdoperac_cetip is not null))) t2
ON (t1.idaplicacao = t2.idaplicacao and t1.idlancamento = t2.idlancamento)
WHEN MATCHED THEN 
  UPDATE SET T1.IDSITUACAO = 0; 
  	
	
	
commit;	

end;