BEGIN
    Update cecred.crapprm 
    set dsvlrprm = 1 
    where cdacesso = 'SAQPAG_NOVO_CORE';
commit;
end;