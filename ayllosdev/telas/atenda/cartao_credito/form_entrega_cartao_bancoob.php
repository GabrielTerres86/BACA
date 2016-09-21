<? 
 /*!
 * FONTE        : form_entrega_cartao_bancoob.php
 * CRIAÇÃO      : James Prust Júnior
 * DATA CRIAÇÃO : 15/05/2014
 * OBJETIVO     : Formulario de entrega de cartao da bancoob.
 *
 * ALTERACAO    : 
 * 001: [24/06/2015] James 			(CECRED) : Criar o campo Conta Cartao
 */	
?>
<form name="frmEntregaCartaoBancoob" id="frmEntregaCartaoBancoob" class="formulario">	

	<fieldset id="fieldEntregar" name="fieldEntregar">
		<legend>Entregar</legend>
		<input name="nrcrcard" id="nrcrcard" type="hidden" value="" />
		
		<div>
			<label for="nrcctitg"><? echo utf8ToHtml('Conta Cartão:') ?></label>
			<input name="nrcctitg" id="nrcctitg" type="text" value="" />
		</div>
		
		<div>
			<label for="nrcctitg2"><? echo utf8ToHtml('Redigite Conta Cartão:') ?></label>
			<input name="nrcctitg2" id="nrcctitg2" type="text" value="" />
		</div>		
		
		<div>
			<label for="repsolic">Nome do portador:</label>
			<input name="repsolic" id="repsolic" type="text" value="" />
		</div>
		
		<div>
			<label for="nrcarfor"><? echo utf8ToHtml('Número do cartão:') ?></label>				    
			<input name="nrcarfor" id="nrcarfor" type="text" value="" />
		</div>
		
		<label for="dtvalida">Data de Validade:</label>
		<input name="dtvalida" id="dtvalida" type="text" value="" />
		<br />
	</fieldset>		
</form>
<div id="divBotoes">
	<a class="botao" onclick="voltaDiv(0,1,4); return false;" href="#">Voltar</a>
	<a class="botao" id="btnLerCartaoChip" 		name="btnLerCartaoChip" 	 onclick="lerCartaoChip(); return false;" href="#"><? echo utf8ToHtml('Inserir o cartão') ?></a>
	<a class="botao" id="btnLerCartaoMagnetico" name="btnLerCartaoMagnetico" onclick="lerCartaoMagnetico(); return false;" href="#"><? echo utf8ToHtml('Passar o cartão') ?></a>	
	<a id="btnProsseguir" name="btnProsseguir" class="botao" href="#">Prosseguir</a>
</div>