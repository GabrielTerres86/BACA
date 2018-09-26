<?php 

	/************************************************************************
	      Fonte: internet.php                                              
	      Autor: David                                                     
	      Data : Junho/2008                   �ltima Altera��o: 11/12/2012
	                                                                  
	      Objetivo  : Mostrar rotina de Internet da tela ATENDA            
	                                                                  	 
	      Alteracoes: 22/10/2010 - Ajuste na chamada acessaOpcaoAba(David) 
	 				
	   			      13/07/2011 - Alterado para layout padr�o (Gabriel - DB1)
	 				
	  			      11/12/2012 - Alterado tamanho tabela (Daniel)
	
					      04/10/2015 - Reformulacao cadastral (Gabriel-RKAM). 
                
					      07/09/2016 - Adicionado classe SetFoco(Evandro - RKAM)
	**************************************************************************/
	
	session_start();
	
	// Includes para controle da session, vari�veis globais de controle, e biblioteca de fun��es
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");		
	require_once("../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo m�todo POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../../class/xmlfile.php");
	
	// Se par�metros necess�rios n�o foram informados
	if (!isset($_POST["nmdatela"]) || !isset($_POST["nmrotina"])) {
		echo '<script type="text/javascript">';
		echo 'hideMsgAguardo();';
		echo 'showError("error","Par&acirc;metros incorretos.","Alerta - Aimaro","");';
		echo '</script>';
		exit();
	}	
	
	$cdproduto = $_POST['cdproduto'];
    $labelRot  = $_POST['labelRot'];	

	// Carrega permiss�es do operador
	include("../../../includes/carrega_permissoes.php");	
	
	setVarSession("opcoesTela",$opcoesTela);
	
?>
<table cellpadding="0" cellspacing="0" border="0" width="100%">
  <tr>
    <td align="center">
      <table border="0" cellpadding="0" cellspacing="0" width="600">
        <tr>
          <td>
            <table width="100%" border="0" cellspacing="0" cellpadding="0">
              <tr>
                <td width="11">
                  <img src="<?php echo $UrlImagens; ?>background/tit_tela_esquerda.gif" width="11" height="21">
                </td>
                <td id="<?php echo $labelRot; ?>" class="txtBrancoBold ponteiroDrag SetFoco" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif">INTERNET
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
											
											// Mostrar op��es da rotina de capital no layer conforme permiss�o do operador
											for ($i = 0; $i < count($opcoesTela); $i++) {
												if ($opcoesTela[$i] <> "@") {
													continue;
												}
												
												switch ($opcoesTela[$i]) {							
													case "@": $nameOpcao = "Principal"; $idPrincipal = $i; break;													
												}												
											?>
											<td><img src="<?php echo $UrlImagens; ?>background/mnu_nle.gif" width="4" height="21" id="imgAbaEsq<?php echo $i; ?>"></td>
											<td align="center" style="background-color: #C6C8CA;" id="imgAbaCen<?php echo $i; ?>"><a href="#" id="linkAba<?php echo $i; ?>" onClick="redimensiona(); acessaOpcaoAba(<?php echo count($opcoesTela); ?>,<?php echo $i; ?>,'<?php echo $opcoesTela[$i]; ?>');return false;" class="txtNormalBold"><?php echo $nameOpcao; ?></a></td>
											<td><img src="<?php echo $UrlImagens; ?>background/mnu_nld.gif" width="4" height="21" id="imgAbaDir<?php echo $i; ?>"></td>
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
                  <div id="divConteudoOpcao" style="height: 275px;">&nbsp;</div>
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

  var cdproduto = <? echo $cdproduto; ?>;

// Mostra div da rotina
mostraRotina();

// Esconde mensagem de aguardo
hideMsgAguardo();	

<?php 	
if (in_array("@",$opcoesTela)) { // Se operador possuir permissao, executa opcao Principal da rotina		
	echo "acessaOpcaoAba(".count($opcoesTela).",".$idPrincipal.",'".$opcoesTela[$idPrincipal]."');";
} else {
	echo "acessaOpcaoAba(".count($opcoesTela).",0,'".$opcoesTela[0]."');";
}
?>
</script>
