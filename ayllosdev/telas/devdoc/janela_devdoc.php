<?php
	 
 /************************************************************************
   Fonte: janela_devdoc.php
   Autor: Jorge I. Hamaguchi
   Data : 18/03/2014                 Última Alteração: 00/00/0000

   Objetivo  : Detalhes de documento da tela DEVDOC
   
   Alterações: 
  ************************************************************************/
?>


<div id="divDetalheDoc">
<table cellpadding="0" cellspacing="0" border="0" width="100%">
	<tr>
		<td align="center">		
			<table border="0" cellpadding="0" cellspacing="0" width="600">
				<tr>
					<td>
						<table width="100%" border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td width="11"><img src="<?php echo $UrlImagens; ?>background/tit_tela_esquerda.gif" width="11" height="21"></td>
								<td class="txtBrancoBold ponteiroDrag" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif">Detalhes DOC</td>
								<td width="12" id="tdTitTela" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif"><a href="#" onClick="fechaDetalhe();return false;"><img src="<?php echo $UrlImagens; ?>geral/excluir.jpg" width="12" height="12" border="0"></a></td>
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
									<table width="100%" height="100%" border="0" cellpadding="0" cellspacing="2">
										<tr>
											<td align="center" valign="center">
												
												<?php include("form_devdoc.php"); ?>
												
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