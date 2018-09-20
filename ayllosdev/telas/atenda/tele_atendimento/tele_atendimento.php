<?php 

	//************************************************************************//
	//*** Fonte: tele_atendimento.php                                      ***//
	//*** Autor: David                                                     ***//
	//*** Data : Fevereiro/2008               &Uacute;ltima Altera&ccedil;&atilde;o: 30/06/2011 ***//
	//***                                                                  ***//
	//*** Objetivo  : Mostrar rotina de Tele Atendimento da tela ATENDA    ***//
	//***                                                                  ***//	 
	//*** Alteracoes: 15/07/2009 - Padroniza&ccedil;&atilde;o de bot&otilde;es (Guilherme).     ***//
	//***		  	  30/06/2011 - Alterado para layout padrão (Rogerius - DB1)***//
	//***             25/07/2016 - Adicionado classe (SetWindow) - necessaria para navegação com teclado - (Evandro - RKAM) ***//	
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
	
    $labelRot = $_POST['labelRot'];	

	// Carrega permiss&otilde;es do operador
	include("../../../includes/carrega_permissoes.php");	
	
	setVarSession("opcoesTela",$opcoesTela);
	
?>
<table cellpadding="0" cellspacing="0" border="0" width="100%">
	<tr>
		<td align="center">		
			<table border="0" cellpadding="0" cellspacing="0" width="300">
				<tr>
					<td>
						<table width="100%" border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td width="11"><img src="<?php echo $UrlImagens; ?>background/tit_tela_esquerda.gif" width="11" height="21"></td>
								<td id="<?php echo $labelRot; ?>" class="txtBrancoBold ponteiroDrag SetWindow SetFoco" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif">TELE-ATENDIMENTO</td>
								<td width="12" id="tdTitTela" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif"><a id="btSair" href="#" onClick="encerraRotina(true);return false;"><img src="<?php echo $UrlImagens; ?>geral/excluir.jpg" width="12" height="12" border="0"></a></td>
								<td width="8"><img src="<?php echo $UrlImagens; ?>background/tit_tela_direita.gif" width="8" height="21"></td>
							</tr>
						</table>     
					</td> 
				</tr>    
				<tr>
					<td class="tdConteudoTela" align="center">	
						<table width="100%"  border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td align="center" style="border: 2px solid #969FA9; background-color: #F4F3F0; padding: 2px;">
									<div id="divConteudoOpcao" style="height: 130px;"><? include('form_tele_atendimento.php') ?></div>
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

// Formata layout
controlaLayout();

// Mostra div da rotina
mostraRotina();

$("#cddsenh1","#frmSenhaURA").setMask("INTEGER","zzzzzzzz","","");
$("#cddsenh2","#frmSenhaURA").setMask("INTEGER","zzzzzzzz","","");

// Esconde mensagem de aguardo
hideMsgAguardo();	

// Busca dados da senha do Tele Atendimento
acessaOpcaoPrincipal();
</script>