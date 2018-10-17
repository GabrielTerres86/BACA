<?
/*!
 * FONTE        : mostrar_xml_completo.php
 * CRIAÇÃO      : Mateus Zimmermann - Mouts
 * DATA CRIAÇÃO : 19/08/2018
 * OBJETIVO     : Mostra XML completo
 * --------------
 * ALTERAÇÃO    :
 * --------------
 */	 
?>

<?	
	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();
	
	$log = isset($_POST["log"]) ? $_POST["log"] : 0;
	
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
								<td id="<?php echo $labelRot; ?>" class="txtBrancoBold ponteiroDrag SetFoco" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif">LOG</td>
								<td width="12" id="tdTitTela" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif"><a href="#" onClick="fechaRotina($('#divRotina'));return false;"><img src="<?php echo $UrlImagens; ?>geral/excluir.jpg" width="12" height="12" border="0"></a></td>
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
									<textarea style="overflow-y: scroll; overflow-x: hidden; width: 500px; height: 300px;"><? echo $log; ?></textarea>
								</td>
							</tr>
						</table>			    
					</td> 
				</tr>
			</table>
		</td>
	</tr>
</table>