delete crapprm
where CDACESSO = 'REGRA_MOTOR_IBRA_CDC_PF'
/
delete crapprm
where CDACESSO = 'REGRA_MOTOR_IBRA_CDC_PJ'
/

declare
  cursor cr_crapcop is
    select  *
    from    crapcop;
begin
  for rw_crapcop in cr_crapcop loop
    INSERT INTO crapprm ( NMSISTEM
                         ,CDCOOPER
                         ,CDACESSO
                         ,DSTEXPRM
                         ,DSVLRPRM
                         ,PROGRESS_RECID
                        )
                 values ( 'CRED'
                         ,rw_crapcop.cdcooper
                         ,'REGRA_MOTOR_IBRA_CDC_PF'
                         ,'Nome da politica de credito para CDC PF a ser executada no Motor de Credito IBRATAN'
                         ,'PoliticaGeralFinancPF'
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
                         ,rw_crapcop.cdcooper
                         ,'REGRA_MOTOR_IBRA_CDC_PJ'
                         ,'Nome da politica de credito para CDC PJ a ser executada no Motor de Credito IBRATAN'
                         ,'PoliticaGeralFinancPJ'
                         ,NULL
                        );
  end loop;
  commit;
end;
