/* Atualiza os parâmetros da tabela TAB089 incluíndo novos parâmetros.
   Projeto: 438 - Sprint 8 - Rubens Lima (Mouts)

  # Alteração de avalista\
  # Valor máximo para alteração de avalista sem perda de aprovação
  

*/ 
BEGIN
update craptab
set dstextab=case 
               when length(dstextab)=130 then dstextab ||' 1 000010000,00'
               when length(dstextab)>130 then substr(dstextab,0,130) ||' 1 000010000,00'
             end
where tptabela = 'USUARI'
and cdempres   = 11
AND cdcooper   <> 1
and cdacesso   = 'PAREMPREST'
and length(dstextab)>=130;

COMMIT;

update craptab
set dstextab=case 
               when length(dstextab)=130 then dstextab ||' 1 003000000,00'
               when length(dstextab)>130 then substr(dstextab,0,130) ||' 1 003000000,00'
             end
where tptabela = 'USUARI'
and cdempres   = 11
AND cdcooper   = 1
and cdacesso   = 'PAREMPREST'
and length(dstextab)>=130;
COMMIT;
END;

