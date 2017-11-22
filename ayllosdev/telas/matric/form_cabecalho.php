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

				  26/06/2017 - Ajustes para inclusão da nova opção "G" (Jonata - RKAM P364).

 * --------------
 */ 

	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');	
	require_once('../../class/xmlfile.php');
	isPostMethod();	
	
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

	<input type="hidden" id="inbcprod" name="inbcprod" value="<? echo $inbcprod ?>" />
	
	<!-- <label><? echo $servidor.' -- '.$inbcprod; ?></label><br/> -->

	<label for="opcao">Op&ccedil;&atilde;o:</label>
	<select id="opcao" name="opcao" alt="Informe a opcao desejada (A, C, D, I, R, X ou J).">
		<option value="FC"> C - Consultar os dados cadastrais da matricula do cooperado.</option> 
		<option value="CD"> D - Desvincular o numero da matricula de uma conta duplicada da conta mae (conta origem da duplicacao).</option>
		<option value="CI"> I - Incluir os dados cadastrais do novo cooperado.</option>
		<option value="CR"> R - Imprimir a ficha de matricula do cooperado</option>
		<option value="CX"> X - Alterar somente o Nome do cooperado.</option>
		<option value="CJ"> J - Alterar somente o CPF/CNPJ do cooperado.</option>
		<option value="CG"> G - Devolu&ccedil;&atilde;o de capital ap&oacute;s AGO.</option>
	</select>
		
	<a href="#" class="botao" id="btOK"  style="text-align: right;">OK</a>
	
	<br style="clear:both" />	
	
</form>
