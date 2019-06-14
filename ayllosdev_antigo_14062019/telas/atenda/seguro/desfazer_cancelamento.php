<? 
/*!
 * FONTE        : desfazer_cancelamento.php
 * CRIAÇÃO      : Rogério Giacomini de Almeida (GATI)
 * DATA CRIAÇÃO : 22/09/2011 
 * OBJETIVO     : Exibir lista de motivos para cancelamento de seguro (quanto tipo do seguro for CASA)
 * --------------
 * ALTERAÇÕES   : 
 * --------------
 */
 ?>
  
<?
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");	
?>

<table id="divDesfazerCancelamento" cellpadding="0" cellspacing="0" border="0" width="100%">
	<tr>
		<td align="center">		
			<table border="0" cellpadding="0" cellspacing="0" width="350">
				<tr>
					<td>
						<table width="100%" border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td width="11"><img src="<?php echo $UrlImagens; ?>background/tit_tela_esquerda.gif" width="11" height="21"></td>
								<td class="txtBrancoBold ponteiroDrag" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif">Seguro Cancelado</td>
								<td width="12" id="tdTitTela" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif"><a href="#" onClick="fechaMotivoCancelamento();"><img src="<?php echo $UrlImagens; ?>geral/excluir.jpg" width="12" height="12" border="0"></a></td>
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
									<div id="divConteudoCancelamento" style="padding:20px;">
										<input style="margin-right:10px;"type="image" class="rotulo" id="btImprimir"  alt="Imprimir Termo de Cancelamento" src="<?php echo $UrlImagens; ?>botoes/imprimir_termo.gif" onClick="imprimirTermoCancelamento();return false;" />
										<input style="margin-left:10px;" type="image" class="rotulo" id="btContinuar" alt="Desfazer cancelamento de Seguro" src="<?php echo $UrlImagens; ?>botoes/desfazer_cancelamento.gif" onClick="showConfirmacao('Deseja desfazer o cancelamento?','Confirma&ccedil;&atilde;o - Aimaro','desfazerCancelamentoSeguro();','fechaMotivoCancelamento()','sim.gif','nao.gif'); return false;" />
										<br />
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