<? 
/*!
 * FONTE        : formulario_dependentes.php
 * CRIAÇÃO      : Rodolpho Telmo (DB1)
 * DATA CRIAÇÃO : 24/05/2010 
 * OBJETIVO     : Formulário da rotina DEPENDENTES da tela de CONTAS
 *
 * ALTERACOES   : 02/09/2015 - Reformulacao Cadastral (Gabriel-RKAM).
 */	
?>

<form name="frmDependentes" id="frmDependentes" class="formulario">	

	<input id="nrdrowid" name="nrdrowid" type="hidden" value="<? echo getByTagName($registro,'nrdrowid') ?>" />
	
	<label for="nmdepend">Nome:</label>
	<input name="nmdepend" id="nmdepend" type="text" value="<? echo getByTagName($registro,'nmdepend') ?>" />	
	<br />
	
	<label for="dtnascto">Data Nascimento:</label>
	<input name="dtnascto" id="dtnascto" type="text" value="<? echo getByTagName($registro,'dtnascto') ?>" />
	<br />
	
	<label for="cdtipdep">Tipo Dependente:</label>
	<input name="cdtipdep" id="cdtipdep" type="text" value="<? echo getByTagName($registro,'cdtipdep') ?>" />
	<a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>
	<input name="dstipdep" id="dstipdep" type="text" value="<? echo getByTagName($registro,'dstipdep') ?>" />
	<br />
	
</form>

<div id="divBotoes">
	<? if ( $operacao == 'TA' ) { ?>
		<input type="image" id="btVoltar"  src="<?php echo $UrlImagens; ?>botoes/voltar.gif"   onClick="controlaOperacaoDependentes('AT'); return false;" />		
		<input type="image" id="btSalvar"  src="<?php echo $UrlImagens; ?>botoes/concluir.gif" onClick="controlaOperacaoDependentes('AV'); return false;" />
	<? } else if ($operacao == 'TI') { ?>
		<input type="image" id="btVoltar"  src="<?php echo $UrlImagens; ?>botoes/voltar.gif"   onClick="controlaOperacaoDependentes('IT'); return false;" />		
		<input type="image" id="btSalvar"  src="<?php echo $UrlImagens; ?>botoes/concluir.gif" onClick="controlaOperacaoDependentes('IV'); return false;" />
	<? } else if ($operacao == 'CF'){?>
		<input type="image" id="btVoltar"  src="<?php echo $UrlImagens; ?>botoes/voltar.gif"   onClick="controlaOperacaoDependentes(); return false;" />
	<?}?>
</div>