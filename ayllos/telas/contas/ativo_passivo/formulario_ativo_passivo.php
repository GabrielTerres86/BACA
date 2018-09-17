<? 
/*!
 * FONTE        : formulario_endereco.php
 * CRIAÇÃO      : Gabriel Capoia (DB1)
 * DATA CRIAÇÃO : Abril/2010 
 * OBJETIVO     : Formulário da rotina Ativo/Passivo da tela de CONTAS
 *
 * ALTERACOES   : [05/08/2015] Gabriel (RKAM) : Reformulacao cadastral.
 */	
?>
<form name="frmAtivoPassivo" id="frmAtivoPassivo" class="formulario">
	
	<fieldset>
		<label for="mesdbase">Data base:</label>
		<input name="mesdbase" id="mesdbase" class="inteiro" type="text" value="<? echo getByTagName($ativoPassivo,'mesdbase') ?>" />
		<label for="anodbase">/</label>
		<input name="anodbase" id="anodbase" class="inteiro" type="text" value="<? echo getByTagName($ativoPassivo,'anodbase') ?>" />
	</fieldset>
	
	<fieldset>
		<legend><? echo utf8ToHtml('Contas Ativas ( Valores em R$ )') ?></legend>
		
		<label for="vlcxbcaf">Caixa,Bancos,Aplicações:</label>
		<input name="vlcxbcaf" id="vlcxbcaf" class="monetario" type="text" value="<? echo getByTagName($ativoPassivo,'vlcxbcaf') ?>" />
		
		<label for="vlctarcb">Contas a receber:</label>
		<input name="vlctarcb" id="vlctarcb" class="monetario" type="text" value="<? echo getByTagName($ativoPassivo,'vlctarcb') ?>" />
		<br />
		
		<label for="vlrestoq">Estoque:</label>
		<input name="vlrestoq" id="vlrestoq" class="monetario" type="text" value="<? echo getByTagName($ativoPassivo,'vlrestoq') ?>" />
		
		<label for="vloutatv">Outros Ativos:</label>
		<input name="vloutatv" id="vloutatv" class="monetario" type="text" value="<? echo getByTagName($ativoPassivo,'vloutatv') ?>" />
		<br />
		
		<label for="vlrimobi">Imobilizado:</label>
		<input name="vlrimobi" id="vlrimobi" class="monetario" type="text" value="<? echo getByTagName($ativoPassivo,'vlrimobi') ?>" />
		<br style="clear:both;" />
	</fieldset>	
	
	<fieldset>
		<legend><? echo utf8ToHtml('Contas Passivas ( Valores em R$ )') ?></legend>
	
		<label for="vlfornec">Fornecedores:</label>
		<input name="vlfornec" id="vlfornec" class="monetario" type="text" value="<? echo getByTagName($ativoPassivo,'vlfornec') ?>" />
		
		<label for="vloutpas">Outros Passivos:</label>
		<input name="vloutpas" id="vloutpas" class="monetario" type="text" value="<? echo getByTagName($ativoPassivo,'vloutpas') ?>" />
		<br />
		
		<label for="vldivbco">Endividamento Bancário:</label>
		<input name="vldivbco" id="vldivbco" style="clear:right;" class="monetario" type="text" value="<? echo getByTagName($ativoPassivo,'vldivbco') ?>" />
		<br style="clear:both;" />
	</fieldset>
	
	<div class="divFinanc">			
		<label for="dtaltjfn">Dados Ativas/Passivas => Alterado:</label>
		<input name="dtaltjfn" id="dtaltjfn" type="text" value="<? echo getByTagName($ativoPassivo,'dtaltjfn') ?>" />
		
		<label for="cdopejfn">Operador:</label>
		<input name="cdopejfn" id="cdopejfn" type="text" value="<? echo getByTagName($ativoPassivo,'cdopejfn') ?>" />
		<input name="nmoperad" id="nmoperad" type="text" value="<? echo getByTagName($ativoPassivo,'nmoperad') ?>" />
	</div>
</form>

<div id="divBotoes">		
	<? if ( in_array($operacao,array('AC','')) ) { ?>	
		<input type="image" id="btVoltar"  src="<? echo $UrlImagens; ?>botoes/voltar.gif"   onClick="fechaRotina(divRotina)" />
		<input type="image" id="btAlterar" src="<? echo $UrlImagens; ?>botoes/alterar.gif"  onClick="controlaOperacao('CA')" />
	<? } else if ( $operacao == 'CA' ) { ?>
	
		<? if ($flgcadas == 'M' ) { ?>
			<input type="image" id="btVoltar"  src="<? echo $UrlImagens; ?>botoes/voltar.gif"  onClick="voltarRotina();" />
		<? } else { ?>
			<input type="image" id="btVoltar"  src="<? echo $UrlImagens; ?>botoes/voltar.gif"  onClick="controlaOperacao('AC');" />
		<? } ?>
		<input type="image" id="btSalvar" src="<? echo $UrlImagens; ?>botoes/alterar.gif"  onClick="controlaOperacao('VA');" />
	<? } ?>
	<input type="image" id="btContinuar"  src="<? echo $UrlImagens; ?>botoes/continuar.gif" onClick="controlaContinuar();" />
</div>
