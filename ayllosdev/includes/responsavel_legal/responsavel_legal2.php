<?
/*!
 * FONTE        : responsavel_legal2.php
 * CRIAÇÃO      : ADRIANO
 * DATA CRIAÇÃO : 04/05/2012 
 * OBJETIVO     : Mostra rotina de Reponsavel Legal da tela de CONTAS
 *
 * ALTERACOES   : 01/09/2015 - Reformulacao Cadastral (Gabriel-RKAM).
 */	
?>
 
<?
		
	// Carregas as opções da Rotina de Procuradores/representantes
	$flgAcesso	  = (in_array('@', $glbvars['opcoesTela']));
	$flgConsultar = (in_array('C', $glbvars['opcoesTela']));
	$flgAlterar   = (in_array('A', $glbvars['opcoesTela']));
	$flgIncluir   = (in_array('I', $glbvars['opcoesTela']));
	$flgExcluir   = (in_array('E', $glbvars['opcoesTela']));
	
	$nmdatela     = $_POST["nmdatela"];
	$nmrotina     = $_POST["nmrotina"];
	$tagScript    = ($nmdatela == 'CONTAS') ? false : true;
	$flgcadas     = $_POST["flgcadas"];
	$metodo       = ($flgcadas == 'M') ? 'proximaRotina();' : 'encerraRotina(false);';
	
		
	if ($flgAcesso == '') exibirErro('error','Seu usu&aacute;rio n&atilde;o possui permiss&atilde;o de acesso a tela de Responsavel Legal.','Alerta - Aimaro',$metodo,$tagScript);
?>

<div id="divOpcoesDaOpcao2">&nbsp;</div>
			
<script type="text/javascript">
	
	// Declara os flags para as opções da Rotina de Procuradores
	var flgAlterar   = "<? echo $flgAlterar;   ?>";	
	var flgIncluir   = "<? echo $flgIncluir;   ?>";	
	var flgExcluir   = "<? echo $flgExcluir;   ?>";	
	var flgConsultar = "<? echo $flgConsultar; ?>";
	var nmdatela     = "<? echo $nmdatela;     ?>";
	var nmrotina     = "<? echo $nmrotina;     ?>";
		
	// Função que exibe a Rotina
	exibeRotina(divRotina);
	
	
	<? echo "acessaOpcaoAbaResp(".count($opcoesTela).",0,'".$opcoesTela[0]."');"; ?>
			
	
	<? echo '$("#tdTitRotina").html("'.utf8ToHtml("RESPONSÁVEL LEGAL").'");'; ?>
		
	
</script>


