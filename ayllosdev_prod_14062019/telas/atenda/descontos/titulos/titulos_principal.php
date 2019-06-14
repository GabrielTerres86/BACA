<?php 

	/****************************************************************************************
       Fonte: dep_vista.php
       Autor: Vitor Shimada (GFT)
       Data : Outubro/2018                  Última alteração: 

       Objetivo  : Mostrar rotina de Desconto de Título

       Alterações: 
								
      **************************************************************************************/
	
	session_start();
  
  // Includes para controle da session, variáveis globais de controle, e biblioteca de funções  
  require_once("../../../../includes/config.php");
  require_once("../../../../includes/funcoes.php");
  require_once("../../../../includes/controla_secao.php");

  // Verifica se tela foi chamada pelo método POST
  isPostMethod(); 
    
  // Classe para leitura do xml de retorno
  require_once("../../../../class/xmlfile.php");
  
  require_once("../../../../includes/carrega_permissoes.php");

?>
<table cellpadding="0" cellspacing="0" border="0" width="525">
  <tr>
    <td>
      <table border="0" cellspacing="0" cellpadding="0">
        <tr>
          <td>
            <img src="<?php echo $UrlImagens; ?>background/mnu_nle.gif" width="4" height="21" id="imgAbaEsq0">
          </td>
          <td align="center" style="background-color: #C6C8CA;" id="imgAbaCen0">
            <a href="#" id="linkAba0" class="txtNormalBold" onClick="acessaOpcaoAba(0);return false;">Principal</a>
          </td>
          <td>
            <img src="<?php echo $UrlImagens; ?>background/mnu_nld.gif" width="4" height="21" id="imgAbaDir0">
          </td>
          <td width="1"></td>
          <td>
            <img src="<?php echo $UrlImagens; ?>background/mnu_nle.gif" width="4" height="21" id="imgAbaEsq1">
          </td>
          <td align="center" style="background-color: #C6C8CA;" id="imgAbaCen1">
            <a href="#" id="linkAba1" class="txtNormalBold" onClick="acessaOpcaoAba(1);return false;">&Uacute;ltimas Altera&ccedil;&otilde;es</a>
          </td>
          <td>
            <img src="<?php echo $UrlImagens; ?>background/mnu_nld.gif" width="4" height="21" id="imgAbaDir1">
          </td>
          <td width="1"></td>
        </tr>
      </table>
    </td>
  </tr>
  <tr>
    <td align="center" style="border: 2px solid #969FA9; background-color: #F4F3F0; padding: 2px;">
      <div id="divConteudoTab" style="height: 280px;">&nbsp;</div>
    </td>
  </tr>
</table>
<script type="text/javascript">
  dscShowHideDiv("divOpcoesDaOpcao1","divConteudoOpcao");

  // Muda o título da tela
  $("#tdTitRotina").html("DESCONTO DE T&Iacute;TULOS");

//  formataLayout('frmTitulos');

  // Esconde mensagem de aguardo
  hideMsgAguardo();

  // Bloqueia conteúdo que está átras do div da rotina
  blockBackground(parseInt($("#divRotina").css("z-index")));

  <?php echo "acessaOpcaoAba(0);"; ?>
</script>
