<?php 

	//************************************************************************//
	//*** Fonte: folhas_cheque.php                                         ***//
	//*** Autor: David                                                     ***//
	//*** Data : Fevereiro/2008               Ultima Alteracao: 23/05/2012 ***//
	//***                                                                  ***//
	//*** Objetivo  : Emitir lista de cheques compensados                  ***//
	//***                                                                  ***//	 
	//*** Alteracoes:                                                      ***//
	//*** 23/05/2012 - Retirado atributo target do form frmCheques (Jorge).***//
	//*** 09/07/2012 - Retirado campo "redirect" popup do form (Jorge).    ***//
	//************************************************************************//
	
	session_start();
	
	// Includes para controle da session, vari&aacute;veis globais de controle, e biblioteca de fun&ccedil;&otilde;es
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");		
	require_once("../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo m&eacute;todo POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../../class/xmlfile.php");

	// Se par&acirc;metros necess&aacute;rios n&atilde;o foram informados
	if (!isset($_POST["nmdatela"]) || !isset($_POST["nmrotina"])) {
		echo '<script type="text/javascript">';
		echo 'hideMsgAguardo();';
		echo 'showError("error","Par&acirc;metros incorretos.","Alerta - Ayllos","");';
		echo '</script>';
		exit();
	}

    $labelRot = $_POST['labelRot'];	

	// Carrega permiss&otilde;es do operador
	include("../../../includes/carrega_permissoes.php");	
	
	setVarSession("opcoesTela",$opcoesTela);
		
?>
<form action="<?php echo $UrlSite; ?>telas/atenda/folhas_cheque/lista_cheques.php" name="frmCheques" id="frmCheques" method="post">
<input type="hidden" id="<?php echo $labelRot; ?>" class="SetFoco">
<input type="hidden" name="nrdconta" id="nrdconta" value="">
<input type="hidden" name="nmprimtl" id="nmprimtl" value="">
<input type="hidden" name="sidlogin" id="sidlogin" value="<?php echo $glbvars["sidlogin"]; ?>">
</form>
<script type="text/javascript">
// Esconde mensagem de aguardo
hideMsgAguardo();	

<?php 	
if (in_array("@",$opcoesTela)) { // Se operador possuir permiss&atilde;o, executa op&ccedil;&atilde;o Principal da rotina		
	echo "showConfirmacao('Deseja visualizar a rela&ccedil;&atilde;o de cheques n&atilde;o compensados?','Confirma&ccedil;&atilde;o - Ayllos','carrega_lista();','encerraRotina(false)','sim.gif','nao.gif');";
} else { // Executa primeira op&ccedil;&atilde;o da rotina que o operador tem permiss&atilde;o
	echo "showError('error','Operador n&atilde;o possui permiss&atilde;o para acessar essa op&ccedil;&atilde;o.','Alerta - Ayllos','encerraRotina(false)');";
}
?>	

</script>