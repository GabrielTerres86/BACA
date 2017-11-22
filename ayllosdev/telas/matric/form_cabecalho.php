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
				: 22/07/2016 - Alteração para disponibilizar no javascript se o 
				  sistema está sendo acessado em base de produção ou não.
				  Caso sim, as consultas a receita federal serão realizadas. - (MACCIEL)
				  27/07/2016 - Corrigi o uso da variavel $registro. SD 479874 (Carlos R.)

 * --------------
 */ 

// VARIFICAR SE É PRODUÇÃO
$arr = get_defined_vars();
$inbcprod = 'N';
$servidores = array('pkgprod', 'pkglibera1', 'pkgdesen1', 'pkgdesen2', 'pkgdesen3');
$servidor = strtolower($arr['DataServer']);

if(in_array($servidor, $servidores)){
	$inbcprod = 'S';
}

?>

<form id="frmCabMatric" name="frmCabMatric" class="formulario">

	<input type="hidden" id="rowidass" name="rowidass" value="<?php echo ( isset($registro) ) ? getByTagName($registro,'rowidass') : ''; ?>" />
	<input type="hidden" id="inmatric" name="inmatric" value="<?php echo ( isset($registro) ) ? getByTagName($registro,'inmatric') : ''; ?>" />
	<input type="hidden" id="inbcprod" name="inbcprod" value="<? echo $inbcprod ?>" />
	
	<!-- <label><? echo $servidor.' -- '.$inbcprod; ?></label><br/> -->

	<label for="opcao">Op&ccedil;&atilde;o:</label>
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
	<input type="text" id="nrdconta" name="nrdconta" value="<?php echo getByTagName($registro,'nrdconta') ?>" alt="Informe o numero da conta do cooperado." />
	<a><img src="<?php echo $UrlImagens; ?>geral/ico_lupa.gif" /></a>
	<a href="#" class="botao" onclick="consultaInicial();return false;">Ok</a>
	
	<label for="cdagepac">PA:</label>
	<input name="cdagepac" id="cdagepac" type="text" value="<?php echo getByTagName($registro,'cdagepac') ?>" />
	<a><img src="<?php echo $UrlImagens; ?>geral/ico_lupa.gif"></a>
	<input name="nmresage" id="nmresage" type="text" value="<?php echo getByTagName($registro,'nmresage') ?>" />
	
	<label for="nrmatric">Matr.:</label> 
	<input type="text" id="nrmatric" name="nrmatric" value="<?php echo getByTagName($registro,'nrmatric') ?>" />
	
	<label for="inpessoa"></label>	
	<input name="inpessoa" id="pessoaFi" type="radio" class="radio" value="1" <?php if ($tpPessoa == 1) { echo ' checked'; } ?> />
	<label for="pessoaFi" class="radio">F&iacute;s</label>
	<input name="inpessoa" id="pessoaJu" type="radio" class="radio" value="2" <?php if ( $tpPessoa == 2 || $tpPessoa == 3 ) { echo ' checked'; } ?> />
	<label for="pessoaJu" class="radio">Jur</label>
	
	<br style="clear:both" />	
</form>

<script type='text/javascript'>

    formataCabecalho();

</script>