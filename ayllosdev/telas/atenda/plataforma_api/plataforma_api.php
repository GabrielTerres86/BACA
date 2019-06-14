<?php 

	//****************************************************************************************//
	//*** Fonte: plataforma_api.php                                                         ***//
	//*** Autor: Andrey Formigari (Supero)                                                  ***//
	//*** Data : Fevereiro/2019        		        Ultima Alteracao:            		    ***//
	//***                                                                                   ***//
	//*** Objetivo  : Mostrar rotina de Plataforma de APIs da tela ATENDA            	    ***//
	//***                                                                                   ***//	 
	//*** Alteracoes:                                                                       ***//
	//****************************************************************************************//
	
	session_start();
	
	// Includes para controle da session, variaveis globais de controle, e biblioteca de funcionalidades 
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");		
	require_once("../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo metodo POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../../class/xmlfile.php");
	
	// Se parametros necessários não foram informados
	if (!isset($_POST["nmdatela"]) || !isset($_POST["nmrotina"])) {
		echo '<script type="text/javascript">';
		echo 'hideMsgAguardo();';
		echo 'showError("error","Parâmetros incorretos.","Alerta - Aimaro","");';
		echo '</script>';
		exit();
	}
	
	$executandoProdutos = $_POST['executandoProdutos'];
	$cdproduto			= $_POST['cdproduto'];
	$labelRot			= $_POST['labelRot'];

	// Carrega permissões do operador
	include("../../../includes/carrega_permissoes.php");	
	
	setVarSession("opcoesTela",$opcoesTela);
	
?>
<style>
	input.botao {
		cursor: pointer;
	}
</style>
<table cellpadding="0" cellspacing="0" border="0" width="100%">
  <tr>
    <td align="center">
      <table border="0" cellpadding="0" cellspacing="0" width="100%">
        <tr>
          <td>
            <table width="100%" border="0" cellspacing="0" cellpadding="0">
              <tr>
                <td width="11">
                  <img src="<?php echo $UrlImagens; ?>background/tit_tela_esquerda.gif" width="11" height="21">
                </td>
                <td id="<?php echo $labelRot; ?>" class="txtBrancoBold ponteiroDrag SetWindow SetFoco" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif">PLATAFORMA APIs
                </td>
                <td width="12" id="tdTitTela" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif"><a id="btSair" href="#" onClick="encerraRotina(true);return false;">
                    <img src="<?php echo $UrlImagens; ?>geral/excluir.jpg" width="12" height="12" border="0">
                  </a>
                </td>
                <td width="8">
                  <img src="<?php echo $UrlImagens; ?>background/tit_tela_direita.gif" width="8" height="21">
                </td>
              </tr>
            </table>
          </td>
        </tr>
        <tr>
          <td class="tdConteudoTela" align="center">
            <table width="100%"  border="0" cellspacing="0" cellpadding="0">
              <tr>
                <td>
                  <table border="0" cellspacing="0" cellpadding="0">
                    <tr>
                      <td><img src="<?php echo $UrlImagens; ?>background/mnu_nle.gif" width="4" height="21" id="imgAbaEsq0"></td>
                      <td align="center" style="background-color: #C6C8CA;" id="imgAbaCen0"><a href="#" id="linkAba0" class="txtNormalBold" onClick="acessaOpcaoAba(2,0,'0');return false;">Principal</a></td>
                      <td><img src="<?php echo $UrlImagens; ?>background/mnu_nld.gif" width="4" height="21" id="imgAbaDir0"></td>
                      <td width="1"></td>
                    </tr>
                  </table>
                </td>
              </tr>
              <tr>
                <td align="center" style="border: 2px solid #969FA9; background-color: #F4F3F0; padding: 2px;">
                  <div id="divConteudoOpcao"></div>
                </td>
              </tr>
            </table>
          </td>
        </tr>
      </table>
    </td>
  </tr>
</table>
<script type="text/javascript">
	// Mostra div da rotina
	mostraRotina();
	
	// guarda parametros enviados pela Atenda
	paramsDefaultPlataformaAPI = '<?php echo json_encode($_POST);?>';
	paramsDefaultPlataformaAPI = JSON.parse(paramsDefaultPlataformaAPI);

	// chama a principal
	controlaOperacao('LP');
</script>