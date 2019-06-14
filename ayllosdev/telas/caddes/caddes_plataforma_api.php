<?php
/*!
 * FONTE        : caddes_plataforma_api.php
 * CRIAÇÃO      : Andrey Formigari - Supero
 * DATA CRIAÇÃO : Abril/2019
 * OBJETIVO     : Mostrar tela Cadastro de Desenvolvedores para a tela Plataforma API
 * --------------
 * ALTERAÇÕES   : 
 *
 * --------------
 */

session_start();

require_once('../../includes/config.php');
require_once('../../includes/funcoes.php');	
require_once('../../includes/controla_secao.php');
require_once('../../class/xmlfile.php');

isPostMethod();

require_once("../../includes/carrega_permissoes.php");
?>
<script>
	var dtmvtolt = '<? echo $glbvars['dtmvtolt']?>';
</script>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="pt-br" lang="pt-br">
    <head>
		<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">	
		<meta http-equiv="Pragma" content="no-cache">
		<meta http-equiv="X-UA-Compatible" content="IE=Edge" >
        <title><? echo $TituloSistema; ?></title>
		<link href="../../css/estilo2.css" rel="stylesheet" type="text/css">
    	<link rel="stylesheet" href="../../css/base/jquery.ui.all.css">
		<script type="text/javascript" src="../../scripts/scripts.js?sidlogin=<?php echo $glbvars["sidlogin"]; ?>" charset="utf-8"></script>
		<script type="text/javascript" src="../../scripts/dimensions.js?sidlogin=<?php echo $glbvars["sidlogin"]; ?>"></script>
		<script type="text/javascript" src="../../scripts/funcoes.js?sidlogin=<?php echo $glbvars["sidlogin"]; ?>"></script>
		<script type="text/javascript" src="../../scripts/mascara.js?sidlogin=<?php echo $glbvars["sidlogin"]; ?>"></script>
		<script type="text/javascript" src="../../scripts/menu.js?sidlogin=<?php echo $glbvars["sidlogin"]; ?>"></script>
        <script type="text/javascript" src="../../scripts/ui/jquery.ui.core.js"></script>
        <script type="text/javascript" src="../../scripts/ui/jquery.ui.datepicker.js"></script>
        <script type="text/javascript" src="../../scripts/ui/i18n/jquery.ui.datepicker-pt-BR.js"></script>
        <script type="text/javascript" src="../../includes/pesquisa/pesquisa.js?sidlogin=<?php echo $glbvars["sidlogin"]; ?>"></script>
		<script type="text/javascript" src="caddes.js?keyrand=<?php echo mt_rand(); ?>"></script>
		<style>
			center {text-align: left;}
		</style>
	</head>
	<body style="background-color: #F4F3F0;">
		
		<div style="display: none;">
		<?php
			include("../../includes/topo.php");
			include("../../includes/menu.php");
		?>
		</div>
		
		<!-- INCLUDE DA TELA DE PESQUISA -->
		<? require_once("../../includes/pesquisa/pesquisa_endereco.php");  ?>

		<div id="divTela">
			<div style="display: none;"><? include('form_cabecalho.php'); ?></div>
		</div>
		
		<div id="divRotina"></div>
		<div id="divUsoGenerico"></div>	
		<div id="divPrincipal"></div>
		<div id="divFraseDesenvolvedor"></div>
		<div id="divPesquisaDesenvolvedor"></div>

		<script type="text/javascript">
			$.datepicker.setDefaults( $.datepicker.regional[ "pt-BR" ] );
			UrlSite = parent.window.location.href.substr(0,parent.window.location.href.lastIndexOf("/") -12); // Url do site
			UrlImagens = UrlSite + "imagens/";
			
			setTimeout(function(){				
				$('#cddopcao option[value="I"]').attr('selected', 'selected');
				$('#btnOKCab').click();
			}, 100);
			
		</script>
		
	</body>
</html>