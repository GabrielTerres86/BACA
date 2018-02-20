<?php
/*
 * FONTE        : form_inclusao_contrato.php
 * CRIAÇÃO       : Leticia Terres (AMcom)
 * DATA CRIAÇÃO : 17/01/2018
 * OBJETIVO     : Mostra a tela para inclusao de contrato
 */	  
	
	session_start();
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");	
	require_once("../../includes/controla_secao.php");	
	require_once('../../class/xmlfile.php');

		
	$nracordo = $_POST['nracordo'];		
?>
	<table id="tdImp"cellpadding="0" cellspacing="0" border="0" width="100%">
		<tr>
			<td align="center">		
				<table border="0" cellpadding="0" cellspacing="0" width="400">
					<tr>
						<td>
							<table width="100%" border="0" cellspacing="0" cellpadding="0">
								<tr>
									<td width="11"><img src="<?php echo $UrlImagens; ?>background/tit_tela_esquerda.gif" width="11" height="21"></td>
									<td class="txtBrancoBold ponteiroDrag" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif">Incluir</td>
									<td width="12" id="tdTitTela" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif"><a href="javascript:;" onclick="fechaRotina($('#divUsoGenerico'),$('#divTela')); return false;"><img src="<?php echo $UrlImagens; ?>geral/excluir.jpg" width="12" height="12" border="0"></a></td>
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
											<form name="frmincctr" id="frmincctr" class="formulario condensado">
						
												<fieldset style="text-align: left; padding: 10px;">
													<legend>Incluir contrato no acordo</legend>

													<label for="nracordo" style="width: 120px;">Acordo:</label>													
													<input name="nracordo" id="nracordo" style="width:140px; border: 1px solid #777; height: 20px; text-align: right;" type="text" value="<?=$nracordo?>" readonly />
													<br style="line-height: 30px;"/>
													
													<label for="nrctremp" style="width: 120px;">Contrato:</label>
													<input name="nrctremp" id="nrctremp" style="width:120px;  border: 1px solid #777; height: 20px; text-align: right;" type="text" value="<?=$nrctremp?>" onblur="validaContrato()"/>
													<a id="lupaControle" name="lupaControle"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>
													<br/>
												</fieldset>
												<div id="divBotoes">													                                        
													<a href="javascript:;" class="botao" style="width:65px;" id="btGravar" onClick="gravarContrato();">Gravar</a>
													<a href="javascript:;" class="botao" style="width:58px;" id="btCancelar" onclick="fechaRotina($('#divUsoGenerico'),$('#divTela')); return false;">Cancelar</a>
												</div>
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

	// Bloqueia conte?¨¬do que est?¢® ?¢®tras do div da rotina
	blockBackground(parseInt($("#divRotina").css("z-index")));

	$('#nrctremp', '#frmincctr').focus();
	
	var lupa = $('#lupaControle', '#frmincctr');
		
	lupa.css('cursor', 'pointer');
	lupa.css('display', 'block');	

	$("#lupaControle").bind('click', function () {	
		pck = 'TELA_ATACOR';
        acao = 'BUSCA_CONTRATOS_LC100';
		titulo = 'Contratos LC100';
		qtReg = '10';		
		filtros = 'contrato;nrctremp;60px;S;;N|data;dtmvtolt;60px;S;;N|valor;vlemprst;60px;S;;N|acordo;nracordo;60px;S;' + $('#nracordo', '#frmincctr').val() + ';N';
		colunas = 'Nro Contrato;nrctremp;40%;left|Data;dtmvtolt;20%;center|Valor;vlemprst;30%;right';			
		mostraPesquisa(pck, acao, titulo, qtReg, filtros, colunas, "");
		$('#divPesquisa').css('zIndex', 4000);
		$('#divAguardo').css('zIndex', 4001);
		$('#btPesquisar').hide();			
		return false;
	});

</script>