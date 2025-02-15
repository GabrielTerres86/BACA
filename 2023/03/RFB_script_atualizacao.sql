Begin
  insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM) 
       values ('CRED', 0, 'RFB_AGENCIA_ARQ', 'Numero da Agencia enviada no arquivo para a Receita - Darf Sem barras', '0001');

  UPDATE crapprm SET DSVLRPRM = 'K3244.K%' WHERE CDACESSO = 'ENVIO_SERPRO_D0064';
  UPDATE crapprm SET DSVLRPRM = 'K3244.K%' WHERE CDACESSO = 'ENVIO_SERPRO_D0100';
  UPDATE crapprm SET DSVLRPRM = 'K3244.K%' WHERE CDACESSO = 'ENVIO_SERPRO_D0153';
  UPDATE crapprm SET DSVLRPRM = 'K3244.K%' WHERE CDACESSO = 'ENVIO_SERPRO_D0328';
  UPDATE crapprm SET DSVLRPRM = 'K3244.K%' WHERE CDACESSO = 'ENVIO_SERPRO_D0385';
  UPDATE crapprm SET DSVLRPRM = 'K3244.K%' WHERE CDACESSO = 'ENVIO_SERPRO_D0432';

  UPDATE crapprm SET DSVLRPRM = 'K3249.K%' WHERE CDACESSO = 'RETORNO_SERPRO_D0064';
  UPDATE crapprm SET DSVLRPRM = 'K3249.K%' WHERE CDACESSO = 'RETORNO_SERPRO_D0100';
  UPDATE crapprm SET DSVLRPRM = 'K3249.K%' WHERE CDACESSO = 'RETORNO_SERPRO_D0153';
  UPDATE crapprm SET DSVLRPRM = 'K3249.K%' WHERE CDACESSO = 'RETORNO_SERPRO_D0328';
  UPDATE crapprm SET DSVLRPRM = 'K3249.K%' WHERE CDACESSO = 'RETORNO_SERPRO_D0385';
  UPDATE crapprm SET DSVLRPRM = 'K3249.K%' WHERE CDACESSO = 'RETORNO_SERPRO_D0432'; 

  commit;
end;