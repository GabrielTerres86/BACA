<?php
/*!
 * FONTE        : apresenta_form_tipo_pessoa.php                    Última alteração: 
 * CRIAÇÃO      : Jonata (Mouts)
 * DATA CRIAÇÃO : Setembro/2018
 * OBJETIVO     : Rotina para apresentar form de alteração do tipo de pessoa
 * --------------
 * ALTERAÇÕES   :  
 *
 */
?>

<?php

    session_start();
    require_once('../../includes/config.php');
    require_once('../../includes/funcoes.php');
    require_once('../../includes/controla_secao.php');
    require_once('../../class/xmlfile.php');
    isPostMethod();

    // Carrega permissões do operador
    require_once('../../includes/carrega_permissoes.php');

    $cddopcao = (isset($_POST["cddopcao"])) ? $_POST["cddopcao"] : '';

    if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {

        exibirErro('error',$msgError,'Alerta - Ayllos','',false);
    }

	$nrdconta = (isset($_POST["nrdconta"])) ? $_POST["nrdconta"] : 0;
		
   		
	?>
		<table cellpadding="0" cellspacing="0" border="0" width="100%">
			<tr>
				<td align="center">		
					<table border="0" cellpadding="0" cellspacing="0" width="400px">
						<tr>
							<td>
								<table width="100%" border="0" cellspacing="0" cellpadding="0">
									<tr>
										<td width="11"><img src="<?php echo $UrlImagens; ?>background/tit_tela_esquerda.gif" width="11" height="21"></td>
										<td class="txtBrancoBold"  background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif">TIPO DE PESSOA</td>
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
													<form id="frmTipoPessoa" name="frmTipoPessoa" class="formulario" style="display:none;">
														
														<input type="hidden" id="nrdconta" name="nrdconta" value="<? echo $nrdconta; ?>" />							
														
														<fieldset id="fsetTipoPessoa" name="fsetTipoPessoa" style="padding:0px; margin:0px; padding-bottom:10px;">
															
															<legend><? echo "Tipo de Pessoa"; ?></legend>
															
															<label for="inpessoa"><? echo utf8ToHtml('Tipo de Pessoa:') ?></label>
															<select id="inpessoa" name="inpessoa" >
																<option value="2" SELECTED> Pessoa Jur&iacute;dica</option>
																<option value="3" > Conta Administrativa</option>						
															</select>
														</fieldset>
	
													</form>

													<div id="divBotoesTipoPessoa" style='text-align:center; margin-bottom: 10px; margin-top: 10px; display:none;' >
																																
														<a href="#" class="botao" id="btVoltar" onClick="fechaRotina($('#divRotina')); return false;">Voltar</a>																																							
														<a href="#" class="botao" id="btConcluir" onClick="showConfirmacao('Deseja confirmar opera&ccedil;&atilde;o?','Confirma&ccedil;&atilde;o - Ayllos','alterarTipoPessoa();','blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));$(\'#btVoltar\',\'#divBotoesTipoPessoa\').focus();','sim.gif','nao.gif');return false;">Concluir</a>	
														
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
			
			$('#divRotina').centralizaRotinaH();
			exibeRotina($('#divRotina'));
			hideMsgAguardo();
			bloqueiaFundo($('#divRotina'));
			formataFormTipoPessoa();
						
		</script>
	<?
	
 ?>
