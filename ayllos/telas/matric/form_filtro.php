<?
/*!
 * FONTE        : form_filtro.php
 * CRIAÇÃO      : Jonata/RKAM 
 * DATA CRIAÇÃO : Junho/2017
 * OBJETIVO     : Form para apresentar os filtros de pesquisa da tela MATRIC.
 * --------------
 * ALTERAÇÕES   :  

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
	
	// Carrega permissões do operador
	require_once('../../includes/carrega_permissoes.php');		
	
	setVarSession("rotinasTela",$rotinasTela);
	$glbvars['opcoesTela' ] = $opcoesTela;
	
	// Carregas as opções da Rotina de Bens		
	$flgConsultar	= (in_array('C', $glbvars['opcoesTela']));	
	$flgIncluir		= (in_array('I', $glbvars['opcoesTela']));
	$flgRelatorio	= (in_array('R', $glbvars['opcoesTela']));
	$flgNome		= (in_array('X', $glbvars['opcoesTela']));
	$flgDesvincula	= (in_array('D', $glbvars['opcoesTela']));	
	$flgCpfCnpj		= (in_array('J', $glbvars['opcoesTela']));	
	
	

?>

<form id="frmFiltro" name="frmFiltro" class="formulario" style="display:none;">

	<input type="hidden" id="rowidass" name="rowidass" />
	<input type="hidden" id="inmatric" name="inmatric" />
		
	<fieldset id="fsetFiltro" name="fsetFiltro" style="padding:0px; margin:0px; padding-bottom:10px;">
		
		<legend><? echo "Filtros"; ?></legend>
		
		<label for="nrdconta">Conta:</label>
		<input type="text" id="nrdconta" name="nrdconta" value="<?php echo getByTagName($registro,'nrdconta') ?>" alt="Informe o numero da conta do cooperado." />
		<a><img src="<?php echo $UrlImagens; ?>geral/ico_lupa.gif" /></a>
		
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
		
	</fieldset>
		
</form>


<div id="divBotoesFiltro" style='text-align:center; margin-bottom: 10px; margin-top: 10px; display:none;'>
																			
	<a href="#" class="botao" id="btVoltar" onClick="controlaVoltar('1'); return false;">Voltar</a>																																							
	<a href="#" class="botao" id="btProsseguir" >Prosseguir</a>	
		   																			
</div>

<script type='text/javascript'>
	
	// Alimenta opções que o operador tem acesso
	flgConsultar	= '<?php echo $flgConsultar; 	?>';
	flgIncluir		= '<?php echo $flgIncluir; 	?>';
	flgRelatorio	= '<?php echo $flgRelatorio; 	?>';
	flgNome			= '<?php echo $flgNome; 		?>';
	flgDesvincula	= '<?php echo $flgDesvincula;	?>';
    flgCpfCnpj      = '<?php echo $flgCpfCnpj;	    ?>';
	
	
	// Alimenta as variáveis globais
	tppessoa = '1';	
	cdpactra = '<?php echo $glbvars["cdpactra"] ?>';	
				
</script>


