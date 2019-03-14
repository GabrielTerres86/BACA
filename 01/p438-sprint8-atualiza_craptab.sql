/* Atualiza os par�metros da tabela TAB089 inclu�ndo novos par�metros.
   Projeto: 438 - Sprint 8 - Rubens Lima (Mouts)

  # Altera��o de avalista\
  # Valor m�ximo para altera��o de avalista sem perda de aprova��o
  
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

