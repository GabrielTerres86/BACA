<?php 

	//******************************************************************************************//
	//*** Fonte: aplicacoes_programadas.php                                                  ***//
	//*** Autor: David                                                                       ***//
	//*** Data : Março/2010                   Última Alteração: 27/07/2018                   ***//
	//***                                                                                    ***//
	//*** Objetivo  : Mostrar rotina de Poupança Programada da tela ATENDA                   ***//
	//***                                                                                    ***//	 
	//*** Alterações:                                                                        ***//
	//***	25/07/2016 - Adicionado classe (SetWindow) - necessaria para navegação com teclado - (Evandro - RKAM) ***//
	//***   27/07/2018 - Derivação para Aplicação Programada (Proj. 411.2 - CIS Corporate)   ***//  
	//******************************************************************************************//
	
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
		echo 'hideMsgAguardo();';
		echo 'showError("error","Par&acirc;metros incorretos.","Alerta - Aimaro","");';
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
      <table cellpadding="0" cellspacing="0" border="0" width="545">
        <tr>
          <td>
            <table width="100%" border="0" cellspacing="0" cellpadding="0">
              <tr>
                <td width="11">
                  <img src="<?php echo $UrlImagens; ?>background/tit_tela_esquerda.gif" width="11" height="21">
                </td>
                <td id="<?php echo $labelRot; ?>" class="txtBrancoBold ponteiroDrag SetWindow SetFoco" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif">POUPAN&Ccedil;A PROGRAMADA
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
											$idPrincipal = 0;		
											
											// Mostrar opções da rotina de aplicações no layer conforme permissão do operador
											for ($i = 0; $i < count($opcoesTela); $i++) {
												if ($opcoesTela[$i] <> "@") {
													continue;
												}
												
												switch ($opcoesTela[$i]) {			
													case "@": $nameOpcao = "Principal"; $idPrincipal = $i; break;													
												}
											?>
                      <td>
                        <img src="<?php echo $UrlImagens; ?>background/mnu_nle.gif" width="4" height="21" id="imgAbaEsq<?php echo $i; ?>">
                      </td>
                      <td align="center" style="background-color: #C6C8CA;" id="imgAbaCen<?php echo $i; ?>"><a href="#" id="linkAba<?php echo $i; ?>" class="txtNormalBold" onClick="acessaOpcaoAba(<?php echo count($opcoesTela); ?>,<?php echo $i; ?>,'<?php echo $opcoesTela[$i]; ?>');return false;"><?php echo $nameOpcao; ?>
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
                <tr>
                  <td align="center" style="border: 2px solid #969FA9; background-color: #F4F3F0; padding: 2px;">
                    <div id="divConteudoOpcao" style="height: 205px;">&nbsp;</div>
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
if (in_array("@",$opcoesTela)) { // Se operador possuir permissão, executa opção Principal da rotina 
	echo "acessaOpcaoAba(".count($opcoesTela).",".$idPrincipal.",'".$opcoesTela[$idPrincipal]."');";
} else { // Executa primeira opção da rotina que o operador tem permissão
	echo "acessaOpcaoAba(".count($opcoesTela).",0,'".$opcoesTela[0]."');";
}
?>
</script>
