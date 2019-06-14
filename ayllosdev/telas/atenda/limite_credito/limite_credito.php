<?php 

	//************************************************************************//
	//*** Fonte: limite_credito.php                                        ***//
	//*** Autor: David                                                     ***//
	//*** Data : Setembro/2007                Última Alteração: 06/04/2015 ***//
	//***                                                                  ***//
	//*** Objetivo  : Mostrar rotina de Limite de Crédito da tela ATENDA   ***//
	//***                                                                  ***//
	//*** Alterações: 31/12/2014 - Incluir tratamento para a acao Renovar  ***//
	//***                          (James)								   ***//
	//***                                                                  ***//
	//*** 			      20/02/2015 - Corrigido erro das abas duplicadas      ***//
	//***						   (Kelvin)								   ***//
	//***                                                                  ***//
	//***             06/04/2015 - Consultas automatizadas (Jonata-RKAM)   ***//
	//***             25/07/2016 - Adicionado classe (SetWindow) - necessaria para naveção com teclado - (Evandro - RKAM) ***//
	//************************************************************************//
	
	session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");		
	require_once("../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo método POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../../class/xmlfile.php");
	
	// Se parâmetros necessários não foram informados
	if (!isset($_POST["nmdatela"]) || !isset($_POST["nmrotina"])) {
		echo '<script type="text/javascript">';
		echo 'hideMsgAguardo();';
		echo 'showError("error","Par&acirc;metros incorretos.","Alerta - Aimaro","");';
		echo '</script>';
		exit();
	}	

    $labelRot = $_POST['labelRot'];	
	
	// Carrega permissões do operador
	include("../../../includes/carrega_permissoes.php");	
	
	setVarSession("opcoesTela",$opcoesTela);
	
?>
<table cellpadding="0" cellspacing="0" border="0" width="100%">
  <tr>
    <td align="center">

      <table border="0" cellpadding="0" cellspacing="0" width="570">
        <tr>
          <td>
            <table width="100%" border="0" cellspacing="0" cellpadding="0">
              <tr>
                <td width="11">
                  <img src="<?php echo $UrlImagens; ?>background/tit_tela_esquerda.gif" width="11" height="21">
                </td>
                <td id="<?php echo $labelRot; ?>" id="tdTitRotina" class="txtBrancoBold  ponteiroDrag SetWindowLimCred SetFoco" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif">LIMITE DE CREDITO
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
            <table width="100%" border="0" cellspacing="0" cellpadding="0">
              <tr>
                <td>
                  <table border="0" cellspacing="0" cellpadding="0">
                    <tr>
                      <?php 
											$idPrincipal = 0;	
											// Mostrar opções da rotina de capital no layer conforme permissão do operador
											for ($i = 0; $i < 1; $i++) { //bruno - prj - 438 - sprint 7 - tela principal
												if (($opcoesTela[$i] == "C") OR ($opcoesTela[$i] == "R")) {
													continue;
												}
												
												switch ($opcoesTela[$i]) {							
													case "@": $nameOpcao = "Principal"; $idPrincipal = $i; break;													
													case "N": $nameOpcao = "Novo Limite"; break;
													case "U": $nameOpcao = "&Uacute;ltimas Altera&ccedil;&otilde;es"; break;
													case "I": $nameOpcao = "Imprimir"; break;
													case "A": $nameOpcao = "Cons. Lim. Ativo"; break;
													case "P": $nameOpcao = "Cons. Lim. Proposto"; break;
												}												
											?>
                      <td>
                        <img src="<?php echo $UrlImagens; ?>background/mnu_nle.gif" width="4" height="21" id="imgAbaEsq<?php echo $i; ?>">
                      </td>
                      <td align="center" style="background-color: #C6C8CA;" id="imgAbaCen<?php echo $i; ?>"><a href="#" id="linkAba<?php echo $i; ?>" onClick="acessaOpcaoAba(<?php echo count($opcoesTela); ?>,<?php echo $i; ?>,'<?php echo $opcoesTela[$i]; ?>');return false;" class="txtNormalBold" name="<?php echo $opcoesTela[$i]; ?>"><?php echo $nameOpcao; ?>
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
                  <?php include("../../../includes/rating/rating_formulario_impressao.php"); ?>
                  <div id="divConteudoOpcao">&nbsp;</div>
                  <?php include('form_confirma_rating.php'); ?>
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
  // Altera título da rotina
  $("#tdTitRotina").html(strTitRotinaUC);

  // Mostra div da rotina
  mostraRotina();

  // Esconde mensagem de aguardo
  hideMsgAguardo();

  <?php 	
if (in_array("@",$opcoesTela)) { // Se operador possuir permissão, executa opção Principal da rotina		
	echo "acessaOpcaoAba(".count($opcoesTela).",".$idPrincipal.",'".$opcoesTela[$idPrincipal]."');";
} else { // Executa primeira opção da rotina que o operador tem permissão
	echo "acessaOpcaoAba(".count($opcoesTela).",0,'".$opcoesTela[0]."');";
}
?>
</script>