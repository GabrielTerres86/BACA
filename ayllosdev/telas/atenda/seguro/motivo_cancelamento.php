<? 
/*!
 * FONTE        : motivo_cancelamento.php
 * CRIAÇÃO      : Rogério Giacomini de Almeida (GATI)
 * DATA CRIAÇÃO : 20/09/2011 
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

<table id="divMotivo" cellpadding="0" cellspacing="0" border="0" width="100%">
	<tr>
		<td align="center">		
			<table border="0" cellpadding="0" cellspacing="0" width="300">
				<tr>
					<td>
						<table width="100%" border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td width="11"><img src="<?php echo $UrlImagens; ?>background/tit_tela_esquerda.gif" width="11" height="21"></td>
								<td class="txtBrancoBold ponteiroDrag" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif">Motivo do Cancelamento</td>
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
									<div id="divConteudoMotivo">
										<form name="frmMotivo" id="frmMotivo" class="formulario condensado">	
											<label for="cdmotcan"><? echo utf8ToHtml('Código Motivo:');?></label>
											<input type="text" id="cdmotcan" name="cdmotcan" alt="Informe o c&oacute;digo do motivo de cancelamento." />	
											<a class="lupa"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>
											<input name="dsmotcan" id="dsmotcan" type="text" alt=""/>
											<br style="clear:both;" />
										</form>
										<br />
										<input type="image" class="rotulo" id="btVoltar" src="<?php echo $UrlImagens; ?>botoes/voltar.gif" onClick="fechaMotivoCancelamento();return false;" />
										<input type="image" class="rotulo" id="btContinuar" src="<?php echo $UrlImagens; ?>botoes/continuar.gif" onClick="showConfirmacao('Deseja confirmar opera&ccedil;&atilde;o?','Confirma&ccedil;&atilde;o - Aimaro','cancelarSeguro();','bloqueiaFundo(divRotina)','sim.gif','nao.gif'); return false;" />
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
<script type="text/javascript">
controlaLayout('C');
controlaPesquisas('C');
</script>