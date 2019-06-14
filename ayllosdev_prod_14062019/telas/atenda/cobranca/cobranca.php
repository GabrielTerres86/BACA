<?php

/***************************************************************

  Fonte: cobranca.php
  Autor: Gabriel
  Data : Dezembro/2010            Ultima atualizacao: 28/04/2016
  
  Objetivo: Mostrar a rotina de Cobranca na ATENDA.
  
  Alteracoes: 14/07/2011 - Alterado para layout padrão 
*						   (Gabriel Capoia - DB1)
*		   
*	          26/07/2011 - Incluir frame com as testemunhas
*						   (Gabriel)
*
*			  09/07/2012 - Retirado campo "redirect" popup. (Jorge)
*
*             28/04/2016 - PRJ 318 - Ajustes projeto Nova Plataforma de cobrança (Odirlei/AMcom)
*
*			  25/07/2016 - Adicionado classe (SetWindow) - necessaria para navegação com teclado - (Evandro - RKAM)
****************************************************************/

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
	echo 'showError("error","Par&acirc;metros incorretos.","Alerta - Aimaro","");';
	exit();
}	

    $labelRot = $_POST['labelRot'];	
	// utilizada variavel para controle da origem da tela
	$telaOrigem = ((!empty($_POST['opeProdutos'])) ? $_POST['opeProdutos'] : '');

// Carrega permiss&otilde;es do operador
include("../../../includes/carrega_permissoes.php");	
	
	setVarSession("opcoesTela",$opcoesTela);


?>

<form action="<?php echo $UrlSite; ?>telas/atenda/cobranca/imprimir_relatorio.php" name="frmRelatorio" class="formulario" id="frmRelatorio" method="post">
	<input type="hidden" name="sidlogin" id="sidlogin" value="<?php echo $glbvars["sidlogin"]; ?>" />
    <input type="hidden" name="nmarquiv" id="nmarquiv" />
    <input type="hidden" name="nrdconta" id="nrdconta" />
    <input type="hidden" name="nmprimtl" id="nmprimtl" />
    <input type="hidden" name="cdagenci" id="cdagenci" />
</form>	

<form action="<?php echo $UrlSite; ?>telas/atenda/cobranca/impressao_termo.php" name="frmTermo" class="formulario" id="frmTermo" method="post">
	<input type="hidden" id="nrdconta" name="nrdconta" value="">	
	<input type="hidden" id="dsdtitul" name="dsdtitul" value="">
	<input type="hidden" id="flgregis" name="flgregis" value="">
	<input type="hidden" id="nmdtest1" name="nmdtest1" value="">
	<input type="hidden" id="cpftest1" name="cpftest1" value="">
	<input type="hidden" id="nmdtest2" name="nmdtest2" value="">
	<input type="hidden" id="cpftest2" name="cpftest2" value="">
	<input type="hidden" id="nrconven" name="nrconven" value="">
	<input type="hidden" id="sidlogin" name="sidlogin" value="<?php echo $glbvars["sidlogin"]; ?>">
	<input type="hidden" id="tpimpres" name="tpimpres" value="">
</form>	

<table id="telaInicial" id="telaInicial" cellpadding="0" cellspacing="0" border="0" width="100%">
	<tr>
		<td align="center">
			<table cellpadding="0" cellspacing="0" border="0" width="420">
			   <tr>
					<td>
						<table width="100%" border="0" cellspacing="0" cellpadding="0" >
							<tr>
								<td width="11"><img src="<?php echo $UrlImagens; ?>background/tit_tela_esquerda.gif" width="11" height="21"></td>
								<td id="<?php echo $labelRot; ?>" class="txtBrancoBold ponteiroDrag SetWindow SetFoco" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif"> COBRAN&Ccedil;A </td>
								<td width="12" id="tdTitTela" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif"><a id="btSair" href="#" onClick="encerraRotina(true);return false;"><img src="<?php echo $UrlImagens; ?>geral/excluir.jpg" width="12" height="12" border="0"></a></td>
								<td width="8"><img src="<?php echo $UrlImagens; ?>background/tit_tela_direita.gif" width="8" height="21"></td>						
							</tr>
						</table>					
					</td>  
			   </tr>
			   			   
			   <tr >		   
					<td class="tdConteudoTela" align="center">																	
					  <table width="480" border="0" cellspacing="0" cellpadding="0">							
						<tr>													
							<td>								
								<table border="0" cellspacing="0" cellpadding="0">
								<tr>
		
									<td><img src="<?php echo $UrlImagens; ?>background/mnu_nle.gif" width="4" height="21" id="imgAbaEsq0"></td>
									<td align="center" style="background-color: #C6C8CA;" id="imgAbaCen0"><a href="#" id="linkAba0" class="txtNormalBold" onClick="acessaOpcaoAba();return false;">Principal</a></td>
									<td><img src="<?php echo $UrlImagens; ?>background/mnu_nld.gif" width="4" height="21" id="imgAbaDir0"></td>
									<td width="1"></td>								
								</tr>
								</table>																		
							</td>
						</tr>
						
						<tr>	
							<td align="center" style="border: 2px solid #969FA9; background-color: #F4F3F0; padding: 2px;">
								<div id="divConteudoOpcao"> </div>
								<div id="divOpcaoConsulta"></div>
								<div id="divOpcaoIncluiAltera"></div>
								<div id="divTitular"></div>
							    <div id="divTestemunhas"></div>
                                <div id="divLogCeb"></div>
                                <div id="divServSMS"></div>
								<div id="divHabilita_SMS"></div>
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

	var telaOrigem = '<?php echo $telaOrigem; ?>';

	// Mostra div da rotina
	mostraRotina();

	// Esconde mensagem de aguardo
	hideMsgAguardo();
	
	// Mostra a Aba Principal com lista dos Conv&ecirc;nios
	<?php echo "acessaOpcaoAba();"; ?>

</script>