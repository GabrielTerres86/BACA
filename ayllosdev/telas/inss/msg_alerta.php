<?php
	 
 /************************************************************************
   Fonte: msg_alerta.php
   Autor: Lombardi
   Data : 01/12/2015                 Última Alteração: 00/00/0000

   Objetivo  : Mensagens de alerta da tela INSS
			   
   Alterações: 
  ************************************************************************/
?>

<?
  session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções
	
  require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');	
	require_once('../../class/xmlfile.php');

  $msgpvida = (isset($_POST["msgpvida"])) ? $_POST["msgpvida"] : "";
?>
<table cellpadding="0" cellspacing="0" border="0" width="100%">
	<tr>
		<td align="center">		
			<table border="0" cellpadding="0" cellspacing="0" width="500">
				<tr>
					<td>
						<table width="100%" border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td width="11"><img src="<?php echo $UrlImagens; ?>background/tit_tela_esquerda.gif" width="11" height="21"></td>
								<td class="txtBrancoBold" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif">MENSAGENS DE ALERTA</td>
								<td width="12" id="tdTitTela" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif"><a href="#" onClick="fechaRotina($('#divRotina')); return false;"><img src="<?php echo $UrlImagens; ?>geral/excluir.jpg" width="12" height="12" border="0"></a></td>
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
									<table width="100%" height="100%" border="0" cellpadding="0" cellspacing="0">
										<tr>
											<td>
												<div id="divListaMsgsAlerta" style="overflow-y: scroll; overflow-x: hidden; height: 210px; width: 100%;"><?echo $msgpvida?></div>																																					
											</td>
										</tr>
									</table>																												
								</td>
							</tr>
						</table>
					</td>
				</tr>
			</table>
		</td>
	</tr>
</table>