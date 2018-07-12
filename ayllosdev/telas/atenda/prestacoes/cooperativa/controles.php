<?php

/*
 * FONTE        : controles.php
 * CRIAÇÃO      : Diego Simas (AMcom)
 * DATA CRIAÇÃO : 12/07/2018
 * OBJETIVO     : Mostra a tela para escolhas do controle.
 */	
	
	session_start();
	require_once('../../../../includes/config.php');
	require_once('../../../../includes/funcoes.php');
	require_once('../../../../includes/controla_secao.php');
	require_once('../../../../class/xmlfile.php');

?>

	<table id="tdImp"cellpadding="0" cellspacing="0" border="0" width="100%">
		<tr>
			<td align="center">		
				<table border="0" cellpadding="0" cellspacing="0" width="450">
					<tr>
						<td>
							<table width="100%" border="0" cellspacing="0" cellpadding="0">
								<tr>
									<td width="11"><img src="<?php echo $UrlImagens; ?>background/tit_tela_esquerda.gif" width="11" height="21"></td>
									<td class="txtBrancoBold ponteiroDrag" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif">Ajustes Controles</td>
									<td width="12" id="tdTitTela" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif"><a href="#" onClick="fechaRotina($('#divUsoGenerico'),divRotina);"><img src="<?php echo $UrlImagens; ?>geral/excluir.jpg" width="12" height="12" border="0"></a></td>
									<td width="8"><img src="<?php echo $UrlImagens; ?>background/tit_tela_direita.gif" width="8" height="21"></td>
								</tr>
							</table>     
						</td> 
					</tr>    
					<tr>
						<td class="tdConteudoTela" align="center">	
							<table width="100%" border="0" cellspacing="0" cellpadding="0">
								<tr>
									<td align="center" style="border: 2px solid #969FA9; background-color: #F4F3F0; padding: 2px 2px 8px;">
										<div id="divConteudoOpcao">

											<form name="frmControleQual" id="frmControleQual" class="formulario condensado">	

												<input id="nrctremp" name="nrctremp" type="hidden" value="" />
		
												<fieldset>
													<legend><? echo utf8ToHtml('Controles') ?></legend>																										
                                                    <div id="divBotoes">                                                        
                                                        <a href="#" style="padding:4;" class="botao" onClick="controlaOperacao('CON_QUALIFICA');">Qualifica&ccedil;&atilde;o da Opera&ccedil;&atilde;o</a>
                                                        <a href="#" style="padding:4;" class="botao" onClick="controlaOperacao('CON_CONTRATOS_LIQ');">Contratos Liquidados</a>
                                                        <br/><br/>
                                                        <a href="#" style="padding:4;" class="botao" onClick="fechaRotina($('#divUsoGenerico'),divRotina);">Voltar</a>                                                
                                                    </div>
                                                    <br/>
												</fieldset>
												
											</form>
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
	// Esconde mensagem de aguardo
	hideMsgAguardo();	

	// Bloqueia conteÃºdo que estÃ¡ Ã¡tras do div da rotina
	blockBackground(parseInt($("#divRotina").css("z-index")));
</script>

