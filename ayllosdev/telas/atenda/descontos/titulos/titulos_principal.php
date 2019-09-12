<?php 

	/****************************************************************************************
       Fonte: dep_vista.php
       Autor: Vitor Shimada (GFT)
       Data : Outubro/2018                  Última alteração: 

       Objetivo  : Mostrar rotina de Desconto de Título

       Alterações: Removido as abas da tela principal de desconto de títulos PRJ 438 - Sprint 16 (Mateus Z / Mouts)
								
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
<!-- PRJ 438 - Sprint 16 - Removido as abas da tela principal de Desconto de Títulos -->
<table cellpadding="0" cellspacing="0" border="0" width="525">
  <tr>
    <td align="center">
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

  <?php echo "acessaTelaPrincipal();"; ?>
</script>
