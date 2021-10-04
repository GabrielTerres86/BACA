begin
  UPDATE CECRED.CRAPPRM
     SET DSVLRPRM = '74'
   WHERE CDACESSO = 'PERC_ALTO_FRAUDE_ADM';
  commit;

  UPDATE CECRED.crapprm
     SET dsvlrprm = 'mouts-petronio.junior@ailos.coop.br'
   WHERE cdacesso = 'EMAIL_RISCOFRAUDE_ADM';
  commit;
end;
