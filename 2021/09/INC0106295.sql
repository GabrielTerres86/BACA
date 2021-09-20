begin
    update crapepr
    set CDORIGEM = 4
    where nrctremp = 21200155
    and nrdconta = 502464
    and cdcooper = 9;

    commit;
end;