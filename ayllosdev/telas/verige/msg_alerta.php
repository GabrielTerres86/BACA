<?php
	 
 /************************************************************************
   Fonte: msg_alerta.php
   Autor: Adriano
   Data : 25/09/2012                 Última Alteração: 25/03/2013

   Objetivo  : Mensagens de alerta da tela PREVIS
			   
   Alterações: 25/03/2013 - Padronização de novo layout (Daniel). 
   
   
  ************************************************************************/
?>


<div id="divMsgsAlerta">

	<table cellpadding="0" cellspacing="0" border="0" width="100%" style="padding-left:120px; padding-top:60px;">
		<tr>
			<td align="center">		
				<table border="0" cellpadding="0" cellspacing="0" width="500">
					<tr>
						<td>
							<table width="100%" border="0" cellspacing="0" cellpadding="0">
								<tr>
									<td width="11"><img src="<?php echo $UrlImagens; ?>background/tit_tela_esquerda.gif" width="11" height="21"></td>
									<td class="txtBrancoBold" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif">MENSAGENS DE ALERTA</td>
									<td width="12" id="tdTitTela" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif"><a href="#" onClick="encerraMsgsAlerta();return false;"><img src="<?php echo $UrlImagens; ?>geral/excluir.jpg" width="12" height="12" border="0"></a></td>
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
												<td align="center" valign="center">
													<div id="divListaMsgsAlerta" style="overflow-y: scroll; overflow-x: hidden; height: 210px; width: 100%;">&nbsp;</div>																																					
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
	
</div>