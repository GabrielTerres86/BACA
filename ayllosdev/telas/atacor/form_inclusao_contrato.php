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

		
	$nracordo = 124092;		
	$cdcooper = 1;
	//$nrctremp = 7486472;

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
											<form name="frmincctr" id="frmincctr" class="formulario condensado">

												<input id="nracordo" name="nracordo" type="hidden" value="<?=$nracordo?>" />
		
												<fieldset>
													<legend>Incluir Contratos</legend>
													<input type="hidden" id="cdcooper" name="cdcooper" value="<?=$cdcooper?>">
													
													<label for="nroacordo" style="width:180px">Acordo:</label>													
													<input name="nroacordo" id="nroacordo" style="width:140px" type="text" value="<?=$nracordo?>" readonly="true" />
													<br/>
													
													<label for="idnrctremp" style="width:180px">Contratos:</label>
													<input name="nrctremp" id="nrctremp" onblur="valida_contrato();" style="width:120px" type="text" value="<?=$nrctremp?>"/>
													<a id="lupaControle" name="lupaControle"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>
													<br/>
												</fieldset>
												<div id="divBotoes">
													<a href="#" class="botao" style="width:58px;" id="btCancelar" onclick="fechaRotina($('#divUsoGenerico'),$('#divRotina')); return false;">Cancelar</a>                                                
													<a href="#" class="botao" style="width:65px;" id="btGravar" onClick="controlaOperacao('BUSCA_CONTRATOS_LC100');">Gravar</a>
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
	
	var lupa = $('#lupaControle', '#frmincctr');
		
	lupa.css('cursor', 'pointer');
	lupa.css('display', 'block');	

	$("#lupaControle").bind('click', function () {	
		pck = 'TELA_ATACOR';
        acao = 'BUSCA_CONTRATOS_LC100';
		titulo = 'Contratos';
		qtReg = '10';		
		filtros = 'Contrato;nracordo;100px;N;0|Data;dtmvtolt;80px;N;|Emprestimo;vlemprst;100px;N;';
		colunas = 'Nro Contrato;nracordo;40%;left|Data;dtmvtolt;20%;center|Valor Emprestimo;vlemprst;30%;left';			
		mostraPesquisa(pck, acao, titulo, qtReg, filtros, colunas);	
		var telaPrincipal = $('#divPesquisa');	
		telaPrincipal.css('zIndex', 4000);		
		return false;
	});

</script>