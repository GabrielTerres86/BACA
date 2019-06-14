<?
/*****************************************************************
  Fonte        : form_incluir_municipio.php
  Criação      : Andrei - RKAM
  Data criação : Agosto/2016
  Objetivo     : Mostra o form de inclusão de municipios
  --------------
  Alterações   :
  --------------
 ****************************************************************/ 

 	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');	
	require_once('../../class/xmlfile.php');
	isPostMethod();		

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
								<td class="txtBrancoBold ponteiroDrag" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif"><?echo "Munic&iacute;pio";?></td>
								<td width="12" id="tdTitTela" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif"><a href="#" onClick="$('#btVoltar','#divRotina').click();return false;"><img src="<?php echo $UrlImagens; ?>geral/excluir.jpg" width="12" height="12" border="0"></a></td>
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
											<td align="center" style="background-color: #C6C8CA;" id="imgAbaCen0"><a href="#" id="linkAba0" onClick="acessaOpcaoAba(4,0,'@')" class="txtNormalBold">Principal</a></td>
											<td><img src="<?php echo $UrlImagens; ?>background/mnu_nld.gif" width="4" height="21" id="imgAbaDir0"></td>
											<td width="1"></td>
										</tr>
									</table>
								</td>
							</tr>
							<tr>
								<td align="center" style="border: 2px solid #969FA9; background-color: #F4F3F0; padding: 2px;">
									
									<div id="divIncluir" style=";margin-top:5px; margin-bottom :10px; display:none;">

										<form id="frmIncluir" name="frmIncluir" class="formulario" style="display:none;">
	
										<fieldset id="fsetIncluir" name="fsetIncluir" style="padding:0px; margin:0px; padding-bottom:10px;">
		
											<legend>Munic&iacute;pio</legend>
			
											<label for="dscidade"><? echo utf8ToHtml("Cidade:"); ?></label>
											<input type="text" id="dscidade" name="dscidade" >

											<br />

											<label for="cdestado"><? echo utf8ToHtml("UF:"); ?></label>
											<input type="text" id="cdestado" name="cdestado" >
		
										</fieldset>

									</div>
	
									<div id="divBotoesIncluir" style='text-align:center; margin-bottom: 10px; margin-top: 10px; display:none;' >
																			
										<a href="#" class="botao" id="btVoltar">Voltar</a>
										<a href="#" class="botao" id="btConcluir">Concluir</a> 
																	
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