<?php 

	//************************************************************************//
	//*** Fonte: principal.php                                             ***//
	//*** Autor: David                                                     ***//
	//*** Data : Julho/2007                   Última Alteração: 07/04/2017 ***//
	//***                                                                  ***//
	//*** Objetivo  : Tela inicial do sistema                              ***//
	//***                                                                  ***//	 
	//*** Alterações: 08/09/2011 - Implementar controle para limpeza de    ***//
	//***                          sub-session antiga (David).             ***//
    //***                                                                  ***//
    //***             07/04/2017 - Permitir acessar o Ayllos mesmo vindo   ***//
    //***                          do CRM. (Jaison/Andrino)                ***//
    //***                                                                  ***//
	//************************************************************************//
	
	session_start();
	
	// Includes para variáveis globais de controle e biblioteca de funções
	require_once("includes/config.php");
	require_once("includes/funcoes.php");	
	require_once("includes/controla_secao.php");
	
	// Verifica se foi a primeira chamada ao sistema, redirecionado do login
	if (isset($_SESSION["sidlogin"])) {
		unset($_SESSION["sidlogin"]);
		unset($_SESSION["hrdlogin"]);
		
		if (trim($glbvars["sidlogin"]) == "") {
			redirecionaErro("html",$UrlLogin,"_parent","Sess&atilde;o Inv&aacute;lida.");
		}
		
		// Efetuar limpeza na SESSION, quando existir uma sub-session antiga
		foreach($_SESSION["glbvars"] as $subsession => $dados_subsession) {
			if ($subsession == $glbvars["sidlogin"]) {
				continue;
			}
			
			if ((!isset($_SESSION["glbvars"][$subsession]["sidlogin"])) || ((strtotime("now") - $_SESSION["glbvars"][$subsession]["hraction"]) > $_SESSION["glbvars"][$subsession]["stimeout"])) {
				unset($_SESSION["glbvars"][$subsession]);
			}
		}
	}
	
	// Classe para leitura do xml de retorno
	require_once("class/xmlfile.php");
	
	// Verificar se foi enviado alguma crítica para a tela principal
	if (isset($_POST["dsmsgerr"]) && trim($_POST["dsmsgerr"]) <> "") {
		$dsmsgerr = $_POST["dsmsgerr"];
	}
	
	// Limpar variáveis da tela na session
	setVarSession("nmdatela","");
	setVarSession("nmrotina","");	
	
?>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<meta http-equiv="Pragma" content="no-cache">
<title><?php echo $TituloSistema; ?></title>
<link href="css/estilo.css" rel="stylesheet" type="text/css">
<script type="text/javascript" src="scripts/jquery.js"></script>
<script type="text/javascript" src="scripts/dimensions.js"></script>
<script type="text/javascript" src="scripts/funcoes.js"></script>
<script type="text/javascript">
<?php
    // Inicializa
    $nmtelini = 'ATENDA';
    // Caso tenha vindo do CRM
    if ($_SESSION["glbvars"][$glbvars["sidlogin"]]['CRM_INACESSO'] == 1) {
        $nmtelini = $_SESSION["glbvars"][$glbvars["sidlogin"]]['CRM_NMDATELA'];
        $nrctacrm = $_SESSION["glbvars"][$glbvars["sidlogin"]]['CRM_NRDCONTA'];
        ?>
        $(document).ready(function() {
            $("#nrdconta","#frmMenu").val('<?php echo $nrctacrm; ?>');
        });
        <?php
    }
?>
// Tela inicial
var glb_nmdatela = '<?php echo $nmtelini; ?>';
</script>
<script type="text/javascript" src="scripts/menu.js"></script>
<?php if (isset($dsmsgerr)) { ?>
<script type="text/javascript">
$(document).ready(function() {
	showError("error","<?php echo addslashes($dsmsgerr); ?>","Alerta - Aimaro","");
});
</script>
<?php } ?>
</head>
<body>
<table width="100%" border="0" cellpadding="0" cellspacing="0">
	<tr>
		<td><?php include("includes/topo.php"); ?></td>
	</tr>
	<tr>
		<td id="tdConteudo" valign="top">
			<table width="100%" height="100%" border="0" cellpadding="0" cellspacing="0">
				<tr> 
					<td width="175" valign="top">
						<table width="100%" border="0" cellpadding="0" cellspacing="0">
							<tr>
								<td id="tdMenu"><?php include("includes/menu.php"); ?></td>
							</tr>  
						</table>
					</td>
					<td id="tdTela" valign="top">
						<table width="100%" border="0" cellpadding="0" cellspacing="0">
							<tr>
								<td>
									<table width="100%"  border="0" cellspacing="0" cellpadding="0">
										<tr>
											<td width="11"><img src="<?php echo $UrlImagens; ?>background/tit_tela_esquerda.gif" width="11" height="21"></td>
											<td class="txtBrancoBold" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif">HOME</td>
											<td width="8"><img src="<?php echo $UrlImagens; ?>background/tit_tela_direita.gif" width="8" height="21"></td>
										</tr>
									</table>
								</td>
							</tr>
							<tr>
								<td id="tdConteudoTela" class="tdConteudoTela" align="center">&nbsp;</td>
							</tr>
						</table>
					</td>
				</tr>
			</table>
		</td>
	</tr>
</table>
</body>
</html>