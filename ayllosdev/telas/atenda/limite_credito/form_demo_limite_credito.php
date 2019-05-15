<?php
/**
 * Autor: Bruno Luiz Katzjarowski - Mout's
 * Data: 05/12/2018
 * Ultimas alterações:
 * 
 * Alterações:
 */
?>
<fieldset id='fsDemoLimiteCredito'>
	<legend><? echo utf8ToHtml('Demonstração de Limite de Crédito');?></legend>

	<label for="demoNivrisco" class="rotulo txtNormalBold" ><?php echo utf8ToHtml('Nível de Risco:'); ?></label>
	<input name="demoNivrisco" id="demoNivrisco" type="text" value="" class='campo'/>
	<br /> <br />

	<label for="demoNrctrlim" class="rotulo txtNormalBold" ><?php echo utf8ToHtml('Número do Contrato:'); ?></label>
	<input name="demoNrctrlim" id="demoNrctrlim" type="text" value="" class='campo'/>
				
	<label for="demoVllimite" class="rotulo txtNormalBold" ><?php echo utf8ToHtml('Valor do Limite:'); ?></label>
	<input name="demoVllimite" id="demoVllimite" type="text" value="" class='campo'/>
	<br /> <br />

	<label for="demoCddlinha" class="rotulo txtNormalBold" ><?php echo utf8ToHtml('Linha de Crédito:'); ?></label>
	<input name="demoCddlinha" id="demoCddlinha" type="text" value="" class='campo'/>
	<br /> <br />

	<label for="demoDsdtxfix" class="rotulo txtNormalBold" ><?php echo utf8ToHtml('Taxa:'); ?></label>
	<input name="demoDsdtxfix" id="demoDsdtxfix" type="text" value="" class='campo'/>
	<br /> <br />

	<label for="demoQtdiavig" class="rotulo txtNormalBold" ><?php echo utf8ToHtml('Vigência:'); ?></label>
	<input name="demoQtdiavig" id="demoQtdiavig" type="text" value="" class='campo'/>
	<br /> <br />

</fieldset>

<div id="divBotoes">
	<input type="image" id="btVoltar" src="<? echo $UrlImagens; ?>botoes/voltar.gif" onClick="abrirTelaDemoLimiteCredito(false);">
	
	<? if ($cddopcao == 'N') { // Se for novo limite ou alteracao  ?>
		<input type="image" id="btCancelar" src="<? echo $UrlImagens; ?>botoes/cancelar.gif" onClick="<? echo $fncPrincipal; ?>return false;">	
		<? if ($flgProposta) { // Alteracao ?>
			<input type="image" id="btContinuar" src="<? echo $UrlImagens; ?>botoes/continuar.gif" onClick="controlaOperacao('A_PROTECAO_AVAL');return false;">	
		<? } else {			   // Inclusao ?>			  
			<input type="image" id="btSalvar" src="<? echo $UrlImagens; ?>botoes/concluir.gif" onClick="buscaGrupoEconomico();return false;">	
		<? } ?>
		
	<? } else { // Consulta ?>
		<input type="image" id="btContinuar" src="<? echo $UrlImagens; ?>botoes/continuar.gif" onClick="controlaOperacao('C_PROTECAO_AVAL'); return false;">
	<? } ?>

</div>	