insert into craprdr ( NRSEQRDR
                     ,NMPROGRA
                     ,DTSOLICI
                     )
             values ( 2088
                     ,'RENEGOCIACAO'
                     ,sysdate
                     )
/

insert into crapaca ( NRSEQACA
                     ,NMDEACAO
                     ,NMPACKAG
                     ,NMPROCED
                     ,LSTPARAM
                     ,NRSEQRDR
                     )
             values ( 4120
                     ,'OBTERNUMEROULTIMOADITIVRENEG'
                     ,null
                     ,'CECRED.obterNumeroUltimoAditivReneg'
                     ,'pr_cdcooper,pr_nrdconta,pr_nrctremp,pr_nraditiv,pr_dscritic'
                     ,2088
                     )
/

commit
/
