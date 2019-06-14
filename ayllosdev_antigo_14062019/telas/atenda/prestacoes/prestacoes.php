<? 
/*!
 * FONTE        : prestacoes.php
 * CRIAÇÃO      : Lucas R. (CECRED)
 * DATA CRIAÇÃO : Maio/2013
 * OBJETIVO     : Mostrar janela de opções (Cooperativa ou BNDES)
 * --------------
 * ALTERAÇÕES   :
 *  25/07/2016 - Adicionado classe (SetWindow) - necessaria para naveção com teclado - (Evandro - RKAM)
 * --------------
 */
 ?>

<?
	session_start();
	require_once('../../../includes/config.php');
	require_once('../../../includes/funcoes.php');
	require_once('../../../includes/controla_secao.php');
	require_once('../../../class/xmlfile.php');
	isPostMethod();		
	
	// Se parâmetros necessários não foram informados
	if (!isset($_POST["nmdatela"]) || !isset($_POST["nmrotina"])) {
		exibirErro('error','Par&acirc;metros incorretos.','Alerta - Aimaro','');	
	}
	
    $labelRot = $_POST['labelRot'];	

	// Carrega permissões do operador
	include('../../../includes/carrega_permissoes.php');	

?>

<table cellpadding="0" cellspacing="0" border="0" width="100%">
	<tr>
		<td align="center">		
			<table border="0" cellpadding="0" cellspacing="0" width="350">
				<tr>
					<td>
						<table width="100%" border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td width="11"><img src="<?echo $UrlImagens; ?>background/tit_tela_esquerda.gif" width="11" height="21"></td>
								<td id="<?php echo $labelRot; ?>" class="txtBrancoBold ponteiroDrag SetWindow SetFoco" background="<?echo $UrlImagens; ?>background/tit_tela_fundo.gif">Presta&ccedil;&otilde;es</td>
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
																			
									<div id="divConteudoOpcao" style="height: 80px;">
									
									<div id="divBotoes" style="height:80px;">
										<input style="margin:20px 10px 0 0;" type="image" src="<?echo $UrlImagens; ?>botoes/cooperativa.gif" onClick="CarregaCooperativa();return false;" />
										<input style="margin:20px 0 0 0;" type="image" src="<?echo $UrlImagens; ?>botoes/bndes.gif" onClick="CarregaBndes();return false;" />
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
	mostraRotina();	
	hideMsgAguardo();	
	bloqueiaFundo(divRotina);
	controlaFoco();
</script>							
							