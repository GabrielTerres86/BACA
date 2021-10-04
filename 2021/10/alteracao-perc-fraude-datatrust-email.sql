begin
  UPDATE CECRED.crapprm
     SET dsvlrprm = 'prev.fraudes03@ailos.coop.br'
   WHERE cdacesso = 'EMAIL_RISCOFRAUDE_ADM';
  commit;
end;
