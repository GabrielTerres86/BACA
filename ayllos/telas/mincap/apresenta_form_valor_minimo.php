<?php

	/**************************************************************************************
	  Fonte: apresenta_form_valor_minimo.php                                               
	  Autor: Jonata - RKAM                                                  
	  Data : Agosto/2017                       			Última Alteração:  
	                                                                   
	  Objetivo  : Apresenta o form para altereção do valor minimo
	                                                                 
	  Alterações:  
	                                                                  
	**************************************************************************************/

	session_start();
	
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");	
	require_once("../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo método POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../class/xmlfile.php");
		
	// Carrega permissões do operador
	require_once('../../includes/carrega_permissoes.php');		
			
	$cddopcao = (isset($_POST["cddopcao"])) ? $_POST["cddopcao"] : '';    
	$vlminimo = (isset($_POST["vlminimo"])) ? $_POST["vlminimo"] : 0;   
	$cdtipcta = (isset($_POST["cdtipcta"])) ? $_POST["cdtipcta"] : 0;   
		
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
	
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}					
		
	
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
								<td class="txtBrancoBold"  background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif">VALOR MÍNIMO</td>
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
								<td align="left" style="border: 2px solid #969FA9; background-color: #F4F3F0; padding: 2px;">
									<div id="divConteudo">
																				
										<form id="frmValorMinimo" name="frmValorMinimo" class="formulario" style="display:none;">	
											
											<fieldset id="fsetValorMinimo" name="fsetValorMinimo" style="padding:0px; margin:0px; padding-bottom:10px;">
											
												<legend><? echo "Valor"; ?></legend>
												
												<label for="vlminimo"><? echo utf8ToHtml('Valor m&iacute;nimo R$:') ?></label>
												<input type="text" id="vlminimo" name="vlminimo" />
												
												<input type="hidden" id="cdtipcta" name="cdtipcta" value="<?echo $cdtipcta; ?>"/>
																					
												<br style="clear:both" />	

											</fieldset>																	
																	
										</form>

										<div id="divBotoesValorMinimo" style="margin-top:5px; margin-bottom :10px; display:none; text-align: center;">
												
											<a href="#" class="botao" id="btVoltar" onClick="fechaRotina($('#divRotina')); return false;">Voltar</a>	
											
											<?if($cddopcao == 'A'){?>
											
												<a href="#" class="botao" id="btConcluir" onClick="showConfirmacao('Deseja confirmar opera&ccedil;&atilde;o?','Confirma&ccedil;&atilde;o - Ayllos','manterRotina()','blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));$(\'#btVoltar\',\'#divBotoesValorMinimo\').focus()','sim.gif','nao.gif');return false;">Concluir</a>	
											
											<?}?>											
											
										</div>
									<div>																																						
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
	
	//$('#divRotina').css({'width':'820px'});
	$('#divRotina').centralizaRotinaH();
	exibeRotina($('#divRotina'));
	hideMsgAguardo();
	bloqueiaFundo($('#divRotina'));
	
	$('#vlminimo','#frmValorMinimo').val('<?echo $vlminimo;?>');
	
	formataFormularioValorMinimo();
	
		
</script>
