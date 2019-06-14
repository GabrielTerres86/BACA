<?php 

	//************************************************************************//
	//*** Fonte: capital.php                                               ***//
	//*** Autor: David                                                     ***//
	//*** Data : Outubro/2007                  Ultima Alteracao 03/10/2015 ***//
	//***                                                                  ***//
	//*** Objetivo  : Mostrar rotina de Capital da tela ATENDA             ***//
	//***                                                                  ***//	 
	//*** Alteracoes: 03/10/2015 - Reformulacao cadastral (Gabriel-RKAM)   ***//
	//***             25/07/2016 - Adicionado classe (SetWindow/SetFoco) - necessaria para navegação com teclado - (Evandro - RKAM) ***//
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
		echo 'showError("error","Par&acirc;metros incorretos.","Alerta - Aimaro","");';
		echo '</script>';
		exit();
	}	
	
	$executandoProdutos = $_POST['executandoProdutos'];
	$cdproduto			= $_POST['cdproduto'];
	$labelRot			= $_POST['labelRot'];

	// Carrega permiss&otilde;es do operador
	include("../../../includes/carrega_permissoes.php");	
	
	setVarSession("opcoesTela",$opcoesTela);
	
?>
<table cellpadding="0" cellspacing="0" border="0" width="100%">
  <tr>
    <td align="center">
      <table border="0" cellpadding="0" cellspacing="0" width="430">
        <tr>
          <td>
            <table width="100%" border="0" cellspacing="0" cellpadding="0">
              <tr>
                <td width="11">
                  <img src="<?php echo $UrlImagens; ?>background/tit_tela_esquerda.gif" width="11" height="21">
                </td>
                <td id="<?php echo $labelRot; ?>" class="txtBrancoBold ponteiroDrag SetWindow SetFoco" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif">CAPITAL
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
                      <?php 
											$contador    = 0;
											$idPrincipal = 0;		
											
											// Mostrar op&ccedil;&otilde;es da rotina de capital no layer conforme permiss&atilde;o do operador
											for ($i = 0; $i < count($opcoesTela); $i++) {
												switch ($opcoesTela[$i]) {			
													case "@": $nameOpcao = "Principal"; $idPrincipal = $i; break;
													case "S": $nameOpcao = "Subscri&ccedil;&atilde;o Inicial"; break;
													case "P": $nameOpcao = "Plano de Capital"; break;
													case "E": $nameOpcao = "Extrato"; break;
													case "I": $nameOpcao = "Integraliza&ccedil;&atilde;o"; break;
												}
												
												$contador++;
											?>
                      <td>
                        <img src="<?php echo $UrlImagens; ?>background/mnu_nle.gif" width="4" height="21" id="imgAbaEsq<?php echo $i; ?>">
                      </td>
                      <td align="center" style="background-color: #C6C8CA;" id="imgAbaCen<?php echo $i; ?>"><a href="#" id="linkAba<?php echo $i; ?>" onClick="acessaOpcaoAba(<?php echo count($opcoesTela); ?>,<?php echo $i; ?>,'<?php echo $opcoesTela[$i]; ?>');return false;" class="txtNormalBold"><?php echo $nameOpcao; ?>
                        </a>
                      </td>
                      <td>
                        <img src="<?php echo $UrlImagens; ?>background/mnu_nld.gif" width="4" height="21" id="imgAbaDir<?php echo $i; ?>">
                      </td>
                      <td width="1"></td>
                      <?php
											} // Fim do for
											?>
                    </tr>
                  </table>
                </td>
              </tr>
              <tr>
                <td align="center" style="border: 2px solid #969FA9; background-color: #F4F3F0; padding: 2px;">
                  <div id="divConteudoOpcao" style="height: 150px;">&nbsp;</div>

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

  // Esconde mensagem de aguardo
  hideMsgAguardo();

  <?php 
	if ($executandoProdutos == 'true') { // Vem da tela Produtos
		if ($cdproduto == 12) {
			echo "acessaOpcaoAba(".count($opcoesTela).",4,'I');";
		} else {
			echo "acessaOpcaoAba(".count($opcoesTela).",2,'P');";
		}
	} else if (in_array("@",$opcoesTela)) { // Se operador possuir permiss&atilde;o, executa op&ccedil;&atilde;o Principal da rotina		
		echo "acessaOpcaoAba(".count($opcoesTela).",".$idPrincipal.",'".$opcoesTela[$idPrincipal]."');";
	} else  {
		echo "acessaOpcaoAba(".count($opcoesTela).",0,'".$opcoesTela[0]."');";
	}
	?>
</script>