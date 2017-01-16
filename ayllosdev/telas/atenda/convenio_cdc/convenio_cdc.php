<?
/*!
 * FONTE        : convenio_cdc.php
 * CRIA��O      : Andre Santos (SUPERO)
 * DATA CRIA��O : Janeiro/2015
 * OBJETIVO     : Mostrar rotina de Convenio CDC da tela CONTAS
 * --------------
 * ALTERA��ES   :
 * --------------
 * 25/07/2016 - Adicionado classe (SetWindow) - necessaria para navega��o com teclado - (Evandro - RKAM).
 */	
?>
<?
	session_start();
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");		
	require_once("../../../includes/controla_secao.php");
	require_once("../../../class/xmlfile.php");
	isPostMethod();	
	
	// Se par&acirc;metros necess&aacute;rios n&atilde;o foram informados
	if (!isset($_POST["nmdatela"]) || !isset($_POST["nmrotina"])) {
		echo 'hideMsgAguardo();';
		echo 'showError("error","Par&acirc;metros incorretos.","Alerta - Ayllos","");';
		exit();
	}
	
    $labelRot = $_POST['labelRot'];	
	
	// Carrega permiss�es do operador
	include("../../../includes/carrega_permissoes.php");	

	setVarSession("opcoesTela",$opcoesTela);
?>
<table cellpadding="0" cellspacing="0" border="0" width="100%">
	<tr>
		<td align="center">		
			<table border="0" cellpadding="0" cellspacing="0" width="100%">
				<tr>
					<td>
						<table width="100%" border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td width="11"><img src="<?php echo $UrlImagens; ?>background/tit_tela_esquerda.gif" width="11" height="21"></td>
								<td id="<?php echo $labelRot; ?>" class="txtBrancoBold ponteiroDrag SetWindow SetFoco" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif">Conv&ecirc;nio CDC</td>
								<td width="12" id="tdTitTela" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif"><a href="#" onClick="encerraRotina(true);return false;"><img src="<?php echo $UrlImagens; ?>geral/excluir.jpg" width="12" height="12" border="0"></a></td>
								<td width="8"><img src="<?php echo $UrlImagens; ?>background/tit_tela_direita.gif" width="8" height="21"></td>
							</tr>
						</table>     
					</td> 
				</tr>    
				<tr>
					<td class="tdConteudoTela" align="center">	
						<table width="100%"  border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td style="border: 1px solid #F4F3F0;">
									<table border="background-color: #F4F3F0;" cellspacing="0" cellpadding="0" >
										<tr>
											<td><img src="<?php echo $UrlImagens; ?>background/mnu_nle.gif" width="8" height="21" id="imgAbaEsq0"></td>
										<td align="center" style="background-color: #C6C8CA;" id="imgAbaCen0"><a href="#" id="linkAba0" onClick="acessaOpcaoAba()" class="txtNormalBold">Principal</a></td>
											<td><img src="<?php echo $UrlImagens; ?>background/mnu_nld.gif" width="8" height="21" id="imgAbaDir0"></td>
											<td width="1"></td>
										</tr>
									</table>
								</td>
							</tr>
							<tr>
								<td align="center" style="border: 2px solid #969FA9; background-color: #F4F3F0; padding: 2px;">
									<div id="divConteudoOpcao"></div>
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
	exibeRotina(divRotina);
	// Esconde mensagem de aguardo
	hideMsgAguardo();
	acessaOpcaoAba();	
</script>