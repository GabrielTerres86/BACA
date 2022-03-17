  begin
         update crapprm prm set prm.dsvlrprm =1
         WHERE prm.nmsistem = 'CRED'
           AND prm.cdcooper =1 
           AND prm.cdacesso = 'NPC_LOG_FAULTPACKET';
 commit;
end;