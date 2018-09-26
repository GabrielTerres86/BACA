<?php
/*!
 * FONTE        : cheques_valor_limite.php
 * CRIAÇÃO      : Lombardi
 * DATA CRIAÇÃO : 06/09/2016 
 * OBJETIVO     : Tela para renovação do valor limite de desconto de cheque. Projeto 300. (Lombardi)
 * ALTERAÇÕES   : 
 * --------------
 * 000:
 *
 *
 */	
?>
 
<?php
	session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../../../includes/config.php");
	require_once("../../../../includes/funcoes.php");
    require_once('../../../../includes/controla_secao.php');
	require_once("../../../../class/xmlfile.php");

	setVarSession("nmrotina","DSC CHQS - LIMITE");
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],"R",false)) <> '') {
		exibirErro("error",$msgError,"Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')))",true);
	}
	
	$vllimite = (isset($_POST['vllimite'])) ? $_POST['vllimite'] : 0;
	$nrctrlim = (isset($_POST['nrctrlim'])) ? $_POST['nrctrlim'] : 0;
	
?>

<table cellpadding="0" cellspacing="0" border="0" width="100%">
	<tr>
		<td align="center">		
			<table border="0" cellpadding="0" cellspacing="0" width="288px">
				<tr>
					<td>
						<table width="100%" border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td width="11"><img src="<?php echo $UrlImagens; ?>background/tit_tela_esquerda.gif" width="11" height="21"></td>
								<td class="txtBrancoBold ponteiroDrag" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif">DESCONTO DE CHEQUES</td>
								<td width="12" id="tdTitTela" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif"><a href="#" onClick="fechaRotina($('#divUsoGenerico'),divRotina);"><img src="<?php echo $UrlImagens; ?>geral/excluir.jpg" width="12" height="12" border="0"></a></td>
								<td width="8"><img src="<?php echo $UrlImagens; ?>background/tit_tela_direita.gif" width="8" height="21"></td>
							</tr>
						</table>     
					</td> 
				</tr>    
				<tr>
					<td class="tdConteudoTela" align="center">	
						<table width="100%" border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td align="center" style="border: 2px solid #969FA9; background-color: #F4F3F0; padding: 2px;">
									<form id="frmReLimite" onsubmit="return false;">
										<br>
										<label for="vllimite"> Valor Limite: </label>
										<input type="text" class="campo" id="vllimite" name="vllimite" value="<? echo $vllimite; ?>" />
										<input type="hidden" class="campo" id="nrctrlim" name="nrctrlim" value="<? echo $nrctrlim; ?>" />
									</form>
									<div style="width: 240px;" id="divConteudoAltara" class="divBotoes">
										<a href="#" class="botao" style="margin: 6px 0px 0px 0px;" id="btVoltar" onClick="fechaRotina($('#divUsoGenerico'), $('#divRotina'));return false;"> Voltar </a>
										<a href="#" class="botao" style="margin: 6px 0px 0px 0px;" id="btRenovar"> Renovar </a>
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
