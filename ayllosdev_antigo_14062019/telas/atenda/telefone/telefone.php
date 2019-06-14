<?php  

/***************************************************************
  Fonte: telefone.php
  Autor: Gabriel
  Data : Janeiro/2011                 Ultima atualizacao:
  
  Objetivo: Mostrar a rotina de Telefone na ATENDA.
  
  Alteracoes: 
  18/08/2016 - Adicionado classe SetFoco(Evandro - RKAM)
****************************************************************/

session_start();
	
// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
require_once("../../../includes/config.php");
require_once("../../../includes/funcoes.php");		
require_once("../../../includes/controla_secao.php");

// Verifica se tela foi chamada pelo método POST
isPostMethod();

// Classe para leitura do xml de retorno
require_once("../../../class/xmlfile.php");

  $labelRot = $_POST['labelRot'];	

// Carrega permissões do operador
include("../../../includes/carrega_permissoes.php");	

	setVarSession("opcoesTela",$opcoesTela);

?>


<table id="telaInicial" id="telaInicial" cellpadding="0" cellspacing="0" border="0" width="100%">
  <tr>
    <td align="center">
      <table cellpadding="0" cellspacing="0" border="0" width="100%">
        <tr>
          <td>
            <table width="100%" border="0" cellspacing="0" cellpadding="0" >
              <tr>
                <td width="11">
                  <img src="<?php echo $UrlImagens; ?>background/tit_tela_esquerda.gif" width="11" height="21">
                </td>
                <td id="<?php echo $labelRot; ?>" class="txtBrancoBold ponteiroDrag SetFoco" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif"> TELEFONES
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

        <tr >
          <td class="tdConteudoTela" align="center">
            <table width="100%" border="0" cellspacing="0" cellpadding="0">
              <tr>
                <td>
                  <table border="0" cellspacing="0" cellpadding="0">
                    <tr>

                      <td>
                        <img src="<?php echo $UrlImagens; ?>background/mnu_nle.gif" width="4" height="21" id="imgAbaEsq0">
                      </td>
                      <td align="center" style="background-color: #C6C8CA;" id="imgAbaCen0">
                        <a href="#" id="linkAba0" class="txtNormalBold" onClick="acessaOpcaoAba();return false;">Principal</a>
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
                  <div id="divConteudoOpcao"> </div>
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
  <?php echo "acessaOpcaoAba();"; ?>

</script>
