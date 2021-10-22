begin

    update tbcadast_pessoa_atualiza atl 
        set atl.INSIT_ATUALIZA = 4 
        where atl.insit_atualiza = 1 
        AND atl.nrdconta = '13652630';

    commit;

exception

    WHEN others THEN
        rollback;
        raise_application_error(-20501, SQLERRM);

end;
/