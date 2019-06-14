<?php 

	/************************************************************************
	Fonte: folhas_cheque.php                                         
	Autor: David                                                     
	Data : Fevereiro/2008               Ultima Alteracao: 23/05/2012 
	
	Objetivo  : Emitir lista de cheques compensados                  
	                                                                 	 
	Alteracoes:                                                      
	23/05/2012 - Retirado atributo target do form frmCheques (Jorge).
	09/07/2012 - Retirado campo "redirect" popup do form (Jorge).
	25/05/2018 - Alterada pra ser uma tela com os botões "Cheques nao compensados"
	             e "Solicitar Talonario". PRJ366 (Lombardi)
	16/08/2018 - Adicionado o botão "Entrega Talonario". Acelera - Entrega de Talonarios no Ayllos (Lombardi)
	24/01/2019 - Criado campo qtreqtal. Acelera - Entrega de Talonarios no Ayllos (Lombardi)
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
		
if (!in_array("@",$opcoesTela)) { // Executa primeira op&ccedil;&atilde;o da rotina que o operador tem permiss&atilde;o
	echo '<script type="text/javascript">';
	echo 'hideMsgAguardo();';
	echo 'showError("error","Operador n&atilde;o possui permiss&atilde;o para acessar essa op&ccedil;&atilde;o.","Alerta - Aimaro","encerraRotina(false)");';
	echo '</script>';
	exit();
}
?>
<form action="<?php echo $UrlSite; ?>telas/atenda/folhas_cheque/lista_cheques.php" name="frmCheques" id="frmCheques" method="post">
<input type="hidden" id="<?php echo $labelRot; ?>" class="SetFoco">
<input type="hidden" name="nrdconta" id="nrdconta" value="">
<input type="hidden" name="nmprimtl" id="nmprimtl" value="">
<input type="hidden" name="sidlogin" id="sidlogin" value="<?php echo $glbvars["sidlogin"]; ?>">
</form>
<table cellpadding="0" cellspacing="0" border="0" width="100%">
	<tr>
		<td align="center">		
			<table border="0" cellpadding="0" cellspacing="0" width="350">
				<tr>
					<td>
						<table width="100%" border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td width="11"><img src="<?echo $UrlImagens; ?>background/tit_tela_esquerda.gif" width="11" height="21"></td>
								<td id="<?php echo $labelRot; ?>" id="tdTitRotina" class="txtBrancoBold ponteiroDrag SetWindow SetFoco" background="<?echo $UrlImagens; ?>background/tit_tela_fundo.gif">FOLHAS DE CHEQUE</td>
								<td width="12" id="tdTitTela" background="<?echo $UrlImagens; ?>background/tit_tela_fundo.gif"><a id="btSair" href="#" onClick="encerraRotina(true);return false;"><img src="<?echo $UrlImagens; ?>geral/excluir.jpg" width="12" height="12" border="0"></a></td>
								<td width="8"><img src="<?echo $UrlImagens; ?>background/tit_tela_direita.gif" width="8" height="21"></td>
							</tr>
						</table>     
					</td> 
				</tr>    
				<tr>
					<td class="tdConteudoTela" align="center">	
						<table width="100%" border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td align="center" style="border: 2px solid #969FA9; background-color: #F4F3F0; padding: 2px;">
									<div id="divTalionario"></div>
									<div id="divConteudoOpcao" style="height: 100px;">
										<div id="divBotoes" style="height:100px;">
											<a href="#" class="botao" name="chequeNaoCompensados" id="chequeNaoCompensados" onClick="confirmaChequesNaoCompensados();">Cheques n&atilde;o compensados</a>
											<div style="height: 10px;" />
											<a href="#" class="botao" name="solicitarTalonario" id="solicitarTalonario" onClick="acessaSolicitaTalonario();">Solicitar Talon&aacute;rio</a>
											<div style="height: 10px;" />
											<a href="#" class="botao" name="entregaTalonario" id="entregaTalonario" onClick="acessaEntregaTalonario();">Entrega Talon&aacute;rio</a>
										</div>
									</div>
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
hideMsgAguardo();	
	mostraRotina();	
	bloqueiaFundo(divRotina);	
</script>