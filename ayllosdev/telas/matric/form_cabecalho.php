<?
/*!
 * FONTE        : form_cabecalho.php
 * CRIAÇÃO      : Rodolpho Telmo (DB1)
 * DATA CRIAÇÃO : 07/06/2010
 * OBJETIVO     : Cabeçalho para a tela MATRIC
 * --------------
 * ALTERAÇÕES   : 15/08/2013 - Alteração da sigla PAC para PA (Carlos).
 *              : 09/07/2015 - Projeto Reformulacao Cadastral (Gabriel-RKAM). 
 *				: 01/10/2015 - Adicionado nova opção "J" para alteração
							   apenas do cpf/cnpj e removido a possibilidade de
							   alteração pela opção "X", conforme solicitado no 
							   chamado 321572 (Kelvin).
				: 08/07/2016 - Criacao do campo inexerfb, chamado 447730 (Rafael Maciel - RKAM)
 * --------------
 */ 

/* cria indice que valida se esta no banco de producao ou nao */
$inexerfb = 'N';
$pkgprod1 = 'pkgprod';
$pkgprod2 = 'pkglibera';
if((strtolower($DataServer) === $pkgprod1) || (strtolower($DataServer) === $pkgprod2)){
	$inexerfb = 'S';
}

?>


<form id="frmCabMatric" name="frmCabMatric" class="formulario">

	<input type="hidden" id="inexerfb" name="inexerfb" value="<? echo $inexerfb; ?>" />
	<input type="hidden" id="rowidass" name="rowidass" value="<? echo getByTagName($registro,'rowidass') ?>" />
	<input type="hidden" id="inmatric" name="inmatric" value="<? echo getByTagName($registro,'inmatric') ?>" />
	
	<label for="opcao"><? echo utf8ToHtml('Opção:') ?></label>
	<select id="opcao" name="opcao" alt="Informe a opcao desejada (A, C, D, I, R, X ou J).">
		<option value="FC"> C - Consultar os dados cadastrais da matricula do cooperado.</option> 
		<option value="CA"> A - Alterar os dados cadastrais da matricula do cooperado.</option>
		<option value="CD"> D - Desvincular o numero da matricula de uma conta duplicada da conta mae (conta origem da duplicacao).</option>
		<option value="CI"> I - Incluir os dados cadastrais do novo cooperado.</option>
		<option value="CR"> R - Imprimir a ficha de matricula do cooperado</option>
		<option value="CX"> X - Alterar somente o Nome do cooperado.</option>
		<option value="CJ"> J - Alterar somente o CPF/CNPJ do cooperado.</option>
	</select>
	<br />
	
	<label for="nrdconta">Conta:</label>
	<input type="text" id="nrdconta" name="nrdconta" value="<? echo getByTagName($registro,'nrdconta') ?>" alt="Informe o numero da conta do cooperado." />
	<a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif" /></a>
	<a href="#" class="botao" onclick="consultaInicial();return false;">Ok</a>
	
	<label for="cdagepac">PA:</label>
	<input name="cdagepac" id="cdagepac" type="text" value="<? echo getByTagName($registro,'cdagepac') ?>" />
	<a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>
	<input name="nmresage" id="nmresage" type="text" value="<? echo getByTagName($registro,'nmresage') ?>" />
	
	<label for="nrmatric">Matr.:</label> 
	<input type="text" id="nrmatric" name="nrmatric" value="<? echo getByTagName($registro,'nrmatric') ?>" />
	
	<label for="inpessoa"></label>	
	<input name="inpessoa" id="pessoaFi" type="radio" class="radio" value="1" <? if ($tpPessoa == 1) { echo ' checked'; } ?> />
	<label for="pessoaFi" class="radio"><? echo utf8ToHtml('Fís') ?></label>
	<input name="inpessoa" id="pessoaJu" type="radio" class="radio" value="2" <? if ( $tpPessoa == 2 || $tpPessoa == 3 ) { echo ' checked'; } ?> />
	<label for="pessoaJu" class="radio"><? echo utf8ToHtml('Jur') ?></label>
	
	<br style="clear:both" />	
</form>

<script type='text/javascript'>
	
	formataCabecalho();
	
</script>