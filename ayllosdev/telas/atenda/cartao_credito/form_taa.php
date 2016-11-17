<?
/*
   FONTE        : form_taa.php
   CRIAÇÃO      : James Prust Júnior
   DATA CRIAÇÃO : 29/07/2015
   OBJETIVO     : Mostra a tela de cadastro de senha, letras do TAA
   ALTERACOES   : 
*/	
?>
<fieldset id="fieldsetTAA">
	<legend>TAA</legend>

	<div id="divBotoes">
		<a class="botao" onclick="acessaOpcaoAba(14,0,'2'); return false;" href="#">Voltar</a>
		
		<? if ($inacetaa == '0'){ ?>
			<a class="botao" onclick="validaDadosLiberacaoTAA(); return false;" href="#"><? echo utf8ToHtml('Liberar') ?></a>
		<? }else if ($inacetaa == '1'){ ?>
			<a class="botao" onclick="validaDadosBloqueioTAA(); return false;" href="#"><? echo utf8ToHtml('Bloquear') ?></a>	
		<? } ?>
		
		<a class="botao" onclick="validaDadosSenhaNumericaTAA(); return false;" href="#"><? echo utf8ToHtml('Senha Numérica') ?></a>
		<a class="botao" onclick="validaDadosSenhaLetrasTAA(); return false;" href="#"><? echo utf8ToHtml('Letras de Segurança') ?></a>	
	</div>
</fieldset>