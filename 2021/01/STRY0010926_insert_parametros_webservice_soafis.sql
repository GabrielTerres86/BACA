delete crapprm
where CDACESSO = 'SOAFIS_ENDERECO_CALCULO'
/
delete crapprm
where CDACESSO = 'AUTHORIZATION_SOAFIS'
/

INSERT INTO crapprm ( NMSISTEM
                     ,CDCOOPER
                     ,CDACESSO
                     ,DSTEXPRM
                     ,DSVLRPRM
                     ,PROGRESS_RECID
                    )
             values ( 'CRED'
                     ,0
                     ,'SOAFIS_ENDERECO_CALCULO'
                     ,'Endereço de serviço do webservice do FIS via SOA'
                     ,'http://servicosinternostst2.cecred.coop.br/osb-soa/TransacaoCreditoRestService/v1/CalcularCreditoConsignado'
                     ,NULL
                    );

INSERT INTO crapprm ( NMSISTEM
                     ,CDCOOPER
                     ,CDACESSO
                     ,DSTEXPRM
                     ,DSVLRPRM
                     ,PROGRESS_RECID
                    )
             values ( 'CRED'
                     ,0
                     ,'AUTHORIZATION_SOAFIS'
                     ,'Authorization para cálculo do empréstimo no FIS via SOA'
                     ,'Basic aWJzdnJjb3JlOndlbGNvbWUx'
                     ,NULL
                    );

commit;
