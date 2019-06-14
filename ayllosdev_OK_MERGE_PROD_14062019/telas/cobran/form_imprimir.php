<?
/*!
 * FONTE        : form_imprimir.php
 * CRIAÇÃO      : Rogérius Militão - DB1 Informatica
 * DATA CRIAÇÃO : 28/02/2012 
 * OBJETIVO     : Tela do formulario de impressao
 */	 
?>

<?
	session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");
	
	$arquivo1 = $_POST['arquivo1'];
	$arquivo2 = $_POST['arquivo2'];
	
?>

<table cellpadding="0" cellspacing="0" border="0" >
	<tr>
		<td align="center">		
			<table border="0" cellpadding="0" cellspacing="0"  >
				<tr>
					<td>
						<table width="100%" border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td width="11"><img src="<?php echo $UrlImagens; ?>background/tit_tela_esquerda.gif" width="11" height="21"></td>
								<td class="txtBrancoBold ponteiroDrag" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif"><? echo utf8ToHtml('IMPRIMIR') ?></td>
								<td width="12" id="tdTitTela" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif"><a href="#" onClick="estadoInicial();  return false;" ><img src="<?php echo $UrlImagens; ?>geral/excluir.jpg" width="12" height="12" border="0"></a></td>
								<td width="8"><img src="<?php echo $UrlImagens; ?>background/tit_tela_direita.gif" width="8" height="21"></td>
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
											<td><img src="<?php echo $UrlImagens; ?>background/mnu_nle.gif" width="4" height="21" id="imgAbaEsq0"></td>
											<td align="center" style="background-color: #C6C8CA;" id="imgAbaCen0"><a href="#" id="linkAba0" class="txtNormalBold">Principal</a></td>
											<td><img src="<?php echo $UrlImagens; ?>background/mnu_nld.gif" width="4" height="21" id="imgAbaDir0"></td>
											<td width="1"></td>
										</tr>
									</table>
								</td>
							</tr>
							<tr>
								<td align="center" style="border: 2px solid #969FA9; background-color: #F4F3F0; padding: 2px;">
									<div id="divConteudo">
										
										<form id="frmImprimir" name="frmImprimir" class="formulario" onsubmit="return false;">

											<fieldset>
												<legend><? echo utf8ToHtml('Imprimir') ?></legend>
												<?php if ( !empty($arquivo1) ) { ?>
												<input name="arquivo1" id="arquivo1" type="button" value="<?php echo utf8ToHtml('Relatório Integrado'); ?>" onClick="Gera_Impressao('<?php echo $arquivo1 ?>'); return false "/>
												<?php } ?>
												
												<?php if ( !empty($arquivo2) ) { ?>
												<input name="arquivo2" id="arquivo2" type="button" value="<?php echo utf8ToHtml('Relatório Rejeitado'); ?>" onClick="Gera_Impressao('<?php echo $arquivo2 ?>'); return false "/>
												<?php } ?> 
											</fieldset>	
										</form>
			
										<div id="divBotoes" style="padding-bottom:10px">
											<a href="#" class="botao" id="btVoltar" onclick="estadoInicial(); return false;">Fechar</a>										
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