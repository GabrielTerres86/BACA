<?php 
	/************************************************************************
         Fonte: convenios.php
         Autor: Guilherme
         Data : Fevereiro/2008                  &Uacute;ltima Altera&ccedil;&atilde;o:   /  /

         Objetivo  : Mostrar rotina de CONVENIOS da tela ATENDA

         Altera&ccedil;&otilde;es:
              30/06/2011 - Aumentado a largura para o novo layout (Rogerius - DB1).		
					
	  ************************************************************************/
	
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
		echo 'hideMsgAguardo();';
		echo 'showError("error","Par&acirc;metros incorretos.","Alerta - Ayllos","");';
		exit();
	}
	
    $labelRot = $_POST['labelRot'];	
	

	// Carrega permiss&otilde;es do operador
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
                <td id="<?php echo $labelRot; ?>" class="txtBrancoBold ponteiroDrag SetFoco" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif">CONV&Ecirc;NIOS
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
                      <td>
                        <img src="<?php echo $UrlImagens; ?>background/mnu_nle.gif" width="4" height="21" id="imgAbaEsq0">
                      </td>
                      <td align="center" style="background-color: #C6C8CA;" id="imgAbaCen0">
                        <a href="#" id="linkAba0" class="txtNormalBold" onClick="acessaOpcaoAba(1,0,0);return false;">Principal</a>
                      </td>
                      <td>
                        <img src="<?php echo $UrlImagens; ?>background/mnu_nld.gif" width="4" height="21" id="imgAbaDir0">
                      </td>
                      <td width="1"></td>
                    </tr>
                  </table>
                </td>
              </tr>
              <tr>
                <td align="center" style="border: 2px solid #969FA9; background-color: #F4F3F0; padding: 2px;">
                  <div id="divConteudoOpcao" style="height: 210px;">&nbsp;</div>
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

  // Mostra a Aba Principal com lista dos Conv&ecirc;nios
  <?php echo "acessaOpcaoAba(1,0,0);"; ?>

</script>
