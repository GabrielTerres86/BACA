/*
select distinct 'delete from Cartao where Cartao.NumeroCartao = %' + convert(varchar(32), crawcrd.nrcrcard) + '%'
  from openquery(ayllosp,'
    select distinct
           agrp0001.md5(crd.nrcrcard) nrcrcard
      from crawcrd crd
         , crapass ass
     where crd.cdcooper = 1
       and nvl(crd.nrcrcard,0) > 0
	   and crd.insitcrd not in (5,6)
       and ass.cdcooper  = crd.cdcooper
       and ass.nrdconta  = crd.nrdconta
	   and ass.nrcpfcgc <> crd.nrcpftit') crawcrd
     , Cartao
 where Cartao.NumeroCartao = crawcrd.nrcrcard
*/

delete from Cartao where Cartao.NumeroCartao = 'CBAF2D7BEBDEFAF31AA579E340BF8B10'
delete from Cartao where Cartao.NumeroCartao = '6506CDD3C71F04B39B64B10770CC7278'
delete from Cartao where Cartao.NumeroCartao = '52C11C2C2AFF54D7BA57105D5B943D3D'
delete from Cartao where Cartao.NumeroCartao = '4188AFB79181BDB56E58EA1B82C6F236'
delete from Cartao where Cartao.NumeroCartao = '788EE305026977E1E808FE0A5A8E2178'
delete from Cartao where Cartao.NumeroCartao = '37213DF4E2587EFCA731DEE9D15FB0FD'
delete from Cartao where Cartao.NumeroCartao = 'F12B118278DDD67AE0563FE570BB8E3B'
delete from Cartao where Cartao.NumeroCartao = '3DCA2DA5E78F91B6F7F6D8CD4B5344D4'
delete from Cartao where Cartao.NumeroCartao = '9B5A55A53CD8E4990D55C8C93F6D80F4'
delete from Cartao where Cartao.NumeroCartao = 'C995CF55CDE06AED8DDADB183339224B'
delete from Cartao where Cartao.NumeroCartao = 'B70070602F3EF6EF514DBDE87BA7DE3B'
delete from Cartao where Cartao.NumeroCartao = '0C9EA5D792333756BEC496B7A6D42FA4'
delete from Cartao where Cartao.NumeroCartao = '8FED3E7B506566EC2D3F40D14083834F'