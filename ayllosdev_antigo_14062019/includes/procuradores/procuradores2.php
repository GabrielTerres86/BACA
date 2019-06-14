<?
/*!
 * FONTE        : procuradores2.php
 * CRIAÇÃO      : ADRIANO
 * DATA CRIAÇÃO : 04/06/2012
 * OBJETIVO     : Mostra rotina de Representantes/Procuradores da tela de CONTAS
 *
 * ALTERACOES   : 04/07/2013 - Inclusão de poderes (Jean Michel).
 *
 *                06/10/2015 - Reformulacao cadastral (Gabriel-RKAM).
 */	
?>
 
<?
		
	// Carregas as opções da Rotina de Procuradores/representantes
	$flgAcesso	  = (in_array('@', $glbvars['opcoesTela']));
	$flgConsultar = (in_array('C', $glbvars['opcoesTela']));
	$flgAlterar   = (in_array('A', $glbvars['opcoesTela']));
	$flgIncluir   = (in_array('I', $glbvars['opcoesTela']));
	$flgExcluir   = (in_array('E', $glbvars['opcoesTela']));
	$flgPoderes	  = (in_array('P', $glbvars['opcoesTela']));
	$nmdatela     = $_POST['nmdatela'];
	
	if ($flgAcesso == '') exibirErro('error','Seu usu&aacute;rio n&atilde;o possui permiss&atilde;o de acesso a tela de Representantes/Procuradores.','Alerta - Aimaro','');
?>

<div id="divOpcoesDaOpcao2">&nbsp;</div>

<script type="text/javascript">
	
	// Declara os flags para as opções da Rotina de Procuradores
	var flgAlterar   = "<? echo $flgAlterar;   ?>";	
	var flgIncluir   = "<? echo $flgIncluir;   ?>";	
	var flgExcluir   = "<? echo $flgExcluir;   ?>";	
	var flgConsultar = "<? echo $flgConsultar; ?>";	
	var flgPoderes 	 = "<? echo $flgPoderes;   ?>";
	var nmdatela     = "<? echo $nmdatela;     ?>";
	
	// Função que exibe a Rotina
	exibeRotina(divRotina);
	
	<? echo "acessaOpcaoAbaProc(".count($opcoesTela).",0,'".$opcoesTela[0]."');"; ?>
	
	<? echo '$("#tdTitRotina").html("'.utf8ToHtml("REPRESENTANTE/PROCURADOR").'");'; ?>
	
</script>


