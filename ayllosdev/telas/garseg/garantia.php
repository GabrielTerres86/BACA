<? 
/*!
 * FONTE        : garantia.php
 * CRIAÇÃO      : Rogério Giacomini de Almeida (GATI)
 * DATA CRIAÇÃO : 16/09/2011 
 * OBJETIVO     : Arquivo que carrega o formulário de garantias
 **/	
?>
<div id="divGarantiaAlcada">
	<table cellpadding="0" cellspacing="0" border="0" width="100%">
		<tr>
			<td align="center">		
				<table border="0" cellpadding="0" cellspacing="0" width="470x">
					<tr>
						<td>
							<table width="100%" border="0" cellspacing="0" cellpadding="0">
								<tr>
									<td width="11"><img src="<? echo $UrlImagens; ?>background/tit_tela_esquerda.gif" width="11" height="21"></td>
									<td class="txtBrancoBold ponteiroDrag" style="text-transform: uppercase;" background="<? echo $UrlImagens; ?>background/tit_tela_fundo.gif"><span>Garantias</span></td>
									<td width="12" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif"><a href="#" onClick="escondeRotina();return false;"><img src="<?php echo $UrlImagens; ?>geral/excluir.jpg" width="12" height="12" border="0"></a></td>
									<td width="8"><img src="<? echo $UrlImagens; ?>background/tit_tela_direita.gif" width="8" height="21"></td>
								</tr>
							</table>
						</td> 
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
									<td align="center" valign="center">												
										<? include('form_garantia.php'); ?>
									</td>
								</tr>
							</table>																												
						</td>
					</tr>
				</table>
			</td>
		</tr>
	</table>																			
</div>