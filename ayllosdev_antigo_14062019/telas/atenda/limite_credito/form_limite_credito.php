<? 
/*!
 * FONTE        : form_limite_credito.php
 * CRIAÇÃO      : Rodolpho Telmo(DB1)
 * DATA CRIAÇÃO : 29/04/2011 
 * OBJETIVO     : Formulário da rotina LIMITE DE CREDITO
 
 * ALTERAÇÕES   : 23/11/2012  - Inicializado as variáveis aux_inconfir, aux_inconfi2 e passado
								as mesmas como parametro da função validarNovoLimite
							    (Adriano).

                  15/01/2014 - Implementacoes referentes ao projeto melhoria alteracao
                               de proposta SD237152(Tiago/Gielow)
							   
				  13/02/2015 - Alterado botao continuar por alterar (Lucas R./Gielow)
				  
				  07/04/2015 - Consultas automatizadas (Jonata-RKAM)
				
				  13/04/2018 - Incluida chamada da function validaAdesaoValorProduto. PRJ366 (Lombardi)
				
 */	
?>

<fieldset class="fsLimiteCredito">

	<legend><? echo utf8ToHtml('Dados do Limite de Crédito') ?></legend>			

	<label for="nrctrlim"><? echo utf8ToHtml('Contrato:') ?></label>	
	<input name="nrctrlim" id="nrctrlim" type="text" value="<? echo $nrctrlim; ?>" />
	<br>
	
	<label for="cddlinha"><? echo utf8ToHtml('Linha:') ?></label>
	<input name="cddlinha" id="cddlinha" type="text" value="<? echo $cddlinha; ?>" />
	<a class="lupa"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>
	<input name="dsdlinha" type="text" id="dsdlinha"  value="<? echo $dsdlinha; ?>" />
	<br />
	
	<label for="vllimite"><? echo utf8ToHtml('Valor do Limite:') ?></label>	
	<input name="vllimite" type="text" id="vllimite" value="<?php echo number_format(str_replace(",",".",$vllimite),2,",","."); ?>" />
	<br />
	
	<label for="flgimpnp"><? echo utf8ToHtml('Nota Promissória:') ?></label>
	<select name="flgimpnp" id="flgimpnp">
		<option value="yes"<? if (strtolower($flgimpnp) == "yes") echo " selected"; ?>>Imprime</option>
	</select>	
	
	<br style="clear:both" />	
	
</fieldset>		

<div id="divBotoes">
	
	<? if ($cddopcao == 'N') { // Se for novo limite ou alteracao ?>

		<input type="image" id="btVoltar" src="<? echo $UrlImagens; ?>botoes/voltar.gif" onClick="<? echo $fncPrincipal; ?>return false;">
		
		<? if ($flgProposta == "true") { ?>	
			<input type="image" src="<? echo $UrlImagens; ?>botoes/imprimir_contrato.gif" onClick="verificaEnvioEmail(2,'<? echo $flgimpnp; ?>',<? echo $nrctrpro; ?>);return false;">
			<input type="image" src="<? echo $UrlImagens; ?>botoes/excluir_novo_limite.gif" onClick="showConfirmacao('Deseja excluir o novo ' + strTitRotinaLC + '?','Confirma&ccedil;&atilde;o - Aimaro','excluirNovoLimite()',metodoBlock,'sim.gif','nao.gif');return false;">
			<input type="image" id="btSalvar" src="<? echo $UrlImagens; ?>botoes/alterar.gif" onClick="aux_inconfir = 1; aux_inconfi2 = 30; validaAdesaoValorProduto('validarAlteracaoLimite('+aux_inconfir+','+aux_inconfi2+');'); return false;">
		<? } else { ?>
			<input type="image" id="btSalvar" src="<? echo $UrlImagens; ?>botoes/validar_novo_limite.gif" onClick="aux_inconfir = 1; aux_inconfi2 = 30; validaAdesaoValorProduto('validarNovoLimite('+aux_inconfir+','+aux_inconfi2+');'); return false;">
		<? } ?>	
	
	<? } else { // Se for consulta 
			if ($nrctrlim > 0)  { // Se tiver contrato ou proposta ?>
				<input type="image" src="<? echo $UrlImagens; ?>botoes/continuar.gif" onClick="dadosRenda(); return false;">
			<? } ?>
	<? } ?>
	
</div>