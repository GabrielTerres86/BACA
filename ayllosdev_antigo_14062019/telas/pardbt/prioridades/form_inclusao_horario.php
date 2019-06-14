<?php
/*
 * FONTE        : form_inclusao_horario.php
 * CRIAÇÃO      : Reginaldo Rubens da Silva (AMcom)
 * DATA CRIAÇÃO : 17/01/2018
 * OBJETIVO     : Mostra a tela para inclusao de um novo horário para execução do programa
 *                na tela ALTERAR do cadastro de prioridades da parametrização do
 *                Debitador Único
 */	  
	
	session_start();
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");	
	require_once("../../../includes/controla_secao.php");	
	require_once('../../../class/xmlfile.php');

	//----------------------------------------------------------------------------------------------------------------------------------	
	// Controle de Erros
	//----------------------------------------------------------------------------------------------------------------------------------
	if ( $glbvars['cddepart'] <> 20 && $cddopcao <> 'C' ) {
		$msgErro	= "Acesso n&atilde;o permitido.";
		exibirErro('error', $msgErro, 'Alerta - Ayllos','',false);
	}

    isPostMethod();
		
	$cdprocesso = $_POST['cdprocesso'];		

    // Monta o xml de requisição
	$xml = "<Root>";
    $xml .= " <Dados>";
    $xml .= " <cdprocesso>" . $cdprocesso . "</cdprocesso>";
    $xml .= " </Dados>";
    $xml .= "</Root>";

    $xmlResult = mensageria($xml, "DEBITADOR_UNICO", "DEBITADOR_PR_BUSCA_HOR", 
		$glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], 
		$glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");    


	$xmlObjeto = getObjectXML($xmlResult);

	//----------------------------------------------------------------------------------------------------------------------------------	
	// Controle de Erros
	//----------------------------------------------------------------------------------------------------------------------------------
	if ( strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO" ) {
		$msgErro	= $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
		exibirErro('error',$msgErro,'Alerta - Ayllos','unblockBackground()',false);
	}
	
	$horarios = $xmlObjeto->roottag->tags[0]->tags;

    if (count($horarios) == 0) {
        exibirErro('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.<br>N&atilde;o h&aacute; hor&aacute;rios para serem adicionados.', 'Alerta - Ayllos', 'unblockBackground();', false);
		exit;
    }
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
											<form name="frmDet" id="frmDet" class="formulario condensado">
						
												<fieldset style="text-align: left; padding: 10px;">
													<legend><?php echo utf8ToHtml('Adicionar horÃ¡rio'); ?></legend>

													<label for="cdprocesso" style="width: 120px;">Programa:</label>													
													<input name="cdprocesso" id="cdprocesso" class="campo" style="width:140px;" type="text" value="<?=$cdprocesso?>" readonly />
													<br style="line-height: 30px;"/>
													
													<label for="idhora_processamento" style="width: 120px;"><?php echo utf8ToHtml('HorÃ¡rio:');?></label>
													<select id="idhora_processamento" class="campo" style="width:140px;">
                                                    <option value="">----</option>
                                                    <?php
                                                    foreach($horarios as $horario) {
                                                        echo '<option value="' .getByTagName($horario->tags, 'idhora_processamento') . '">' . 
                                                            getByTagName($horario->tags, 'dhprocessamento') . '</option>';
                                                    }
                                                    ?>
                                                    </select>
												</fieldset>
												<div id="divBotoes">													                                        
													<a href="javascript:;" class="botao" style="width:65px;" id="btGravar" onClick="gravarNovoHorarioProc();">Gravar</a>
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

	// Bloqueia conteúdo que está Atrás do div da rotina
	blockBackground(parseInt($("#divRotina").css("z-index")));

	$('#idhora_processamento', '#frmDet').focus();
</script>