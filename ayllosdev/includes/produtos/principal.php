<?php 

	/********************************************************************
	 Fonte: principal.php                                             
	 Autor: Gabriel - Rkam                                                     
	 Data : Setembro - 2015                  Última Alteração: 
	                                                                  
	 Objetivo  : Mostrar opcao Principal da rotina de Produtos da   tela ATENDA                                          
	                                                                  	 
	 Alteraçães: 01/10/2015 - Projeto 217 Reformulacao Cadastral (Tiago Castro - RKAM)
						  
                 14/07/2016 - Correcao na forma de recuperacao de parametros do array $_POST. SD 479874 (Carlos Rafael Tanholi)
				 
                 16/05/2018 - Adicionado parametro flgautom na mensageria
                              SERVICOS_OFERECIDOS. PRJ366 (Lombardi).
	 
	 
	*********************************************************************/
	
	session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once('../config.php');
	require_once('../funcoes.php');
	require_once('../controla_secao.php');	

	// Verifica se tela foi chamada pelo método POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once('../../class/xmlfile.php');
	
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"C")) <> "") {
		exibirErro('error',$msgError,'Alerta - Aimaro','blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))');
	}		
	
	// Verifica se os parâmetros foram passados
	if (!isset($_POST["nrdconta"])  || !isset($_POST["nmrotina"]) || !isset($_POST["opeProdutos"])) {	
		exibirErro('error','Par&acirc;metros incorretos.','Alerta - Aimaro','blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))');
	}	

	$nmrotina				 = ( isset($_POST["nmrotina"]) ) ? $_POST["nmrotina"] : '';
	$nrdconta				 = ( isset($_POST["nrdconta"]) ) ? $_POST["nrdconta"] : 0;
	$opeProdutos        = ( isset($_POST["opeProdutos"]) ) ? $_POST["opeProdutos"] : 0;
	$atualizarServicos = ( isset($_POST["atualizarServicos"]) ) ? $_POST["atualizarServicos"] : array();
	$flgcadas				 = ( isset($_POST['flgcadas']) ) ? $_POST['flgcadas'] : '';	
	
	
	// Verifica se o número da conta é um inteiro válido
	if (!validaInteiro($nrdconta)) {
		exibirErro('error','Conta/dv inv&aacute;lida.','Alerta - Aimaro','blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))');
	}
	
	if( ($opeProdutos == 2 && $flgcadas == 'M') || $opeProdutos == 3 ) {
		
		//Chamar a rotina do oracle ATUALIZA_PRODUTO_OFERECIDO 			
		foreach ($atualizarServicos as $key => $value) {
	
			$campospc = "";
			$dadosprc = "";
			$contador = 0;
						
			// Monta o xml de requisição
			$xmlAtualizaServicos  = "";
			$xmlAtualizaServicos .= "<Root>";
			$xmlAtualizaServicos .= "   <Dados>";
			$xmlAtualizaServicos .= "	   <nrdconta>".$nrdconta."</nrdconta>";
			
			foreach( $value as $chave => $valor ){
				
				$contador++;
								
				$xmlAtualizaServicos .= "<".$chave.">".$valor."</".$chave.">";
				
			}
			
			$xmlAtualizaServicos .= "   </Dados>";
			$xmlAtualizaServicos .= "</Root>";
						
			// Executa script para envio do XML	
			$xmlResult = mensageria($xmlAtualizaServicos, "SERVICOSOFERECIDOS", "ATUALIZAPRODUTOS", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
				
			// Cria objeto para classe de tratamento de XML
			$xmlObjAtualizaServicos =$xmlObj = simplexml_load_string($xmlResult);
			
			// Se ocorrer um erro, mostra crítica
			if ($xmlObjAtualizaServicos->Erro->Registro->dscritic != '') {
				
				$msgErro = utf8ToHtml($xmlObjAtualizaServicos->Erro->Registro->dscritic);
				
				exibirErro('error',$msgErro,'Alerta - Aimaro','blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))');
			
			}
			
		}	
		
		// Gravar o horario fim do cadastro da conta (crapass.hrfimcad)
		if ($opeProdutos == 3 && $flgcadas == 'M') {
					
			// Monta o xml de requisição
			$xmlAtualizaServicos  = "";
			$xmlAtualizaServicos .= "<Root>";
			$xmlAtualizaServicos .= "   <Dados>";
			$xmlAtualizaServicos .= "	   <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
			$xmlAtualizaServicos .= "	   <nrdconta>".$nrdconta."</nrdconta>";
			$xmlAtualizaServicos .= "   </Dados>";
			$xmlAtualizaServicos .= "</Root>";
			
			// Executa script para envio do XML	
			$xmlResult = mensageria($xmlAtualizaServicos, "CADA0003", "FIN_CAD", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
				
			// Cria objeto para classe de tratamento de XML
			$xmlObjAtualizaServicos = simplexml_load_string($xmlResult);
						
			// Se ocorrer um erro, mostra crítica
			if ($xmlObjAtualizaServicos->Erro->Registro->dscritic != '') {
				
				$msgErro = utf8ToHtml($xmlObjAtualizaServicos->Erro->Registro->dscritic);
				
				exibirErro('error',$msgErro,'Alerta - Aimaro','blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))');
			
			}
		
		}	
			
	}
	
	// Monta o xml de requisição
	$xmlBuscaServicos  = "";
	$xmlBuscaServicos .= "<Root>";
	$xmlBuscaServicos .= "   <Dados>";
	$xmlBuscaServicos .= "	   <nrdconta>".$nrdconta."</nrdconta>";
	$xmlBuscaServicos .= "	   <flgautom>".    0    ."</flgautom>";
	$xmlBuscaServicos .= "   </Dados>";
	$xmlBuscaServicos .= "</Root>";
		
	// Executa script para envio do XML	
	$xmlResult = mensageria($xmlBuscaServicos, "MATRIC", "SERVICOS_OFERECIDOS", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
		
	// Cria objeto para classe de tratamento de XML
	$xmlObjServicos = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjServicos->roottag->tags[0]->name) == "ERRO") {
		
		exibirErro('error',$xmlObjServicos->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Aimaro','blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))');
	}
		
	//Pega todos os servicos essenciais
	$regServicos = $xmlObjServicos->roottag->tags[0]->tags[1]->tags;
	
	//Pega todos os servicos adicionais
	$regServicosAdicionais = $xmlObjServicos->roottag->tags[1]->tags[1]->tags;
			
?>
					
<div id="divServicos">		
				
	<form id="frmServicos" name="frmServicos" class="formulario">	
			
		<fieldset>
		
			<legend><? echo utf8ToHtml('ESSENCIAIS') ?></legend>
									
			<table id="tabelaServicos" style="padding-left:0px;width:100%">
			
				<tr>	
					<td ></td>	
					<td ></td>							
					<td style="vertical-align: bottom;">
						<label >Habilitar</label>
					</td>															
				</tr>	
				
				<?foreach( $regServicos as $result ) {?>
					
					<tr id="<?echo getByTagName($result->tags,'cdproduto');?>">
					
						<?if(getByTagName($result->tags,'flativo') == 'N'){?>						
							<td><a style="padding: 0px 0 0 3px;"><img style="width:25px; height:25px;" src="<? echo $UrlImagens; ?>geral/servico_nao_ativo.gif" id="lupaServico" name="lupaServico"/></a></td>							
						<?}else if(getByTagName($result->tags,'flativo') == 'S'){?>	
							<td><a style="padding: 0px 0 0 3px;"><img style="width:25px; height:25px;" src="<? echo $UrlImagens; ?>geral/servico_ativo.gif" id="lupaServico" name="lupaServico" /></a></td>
						<?}else{?>
							<td></td>
						<?}?>				
						
						<td style="text-align:left;width:260px">
							<label for="<?echo getByTagName($result->tags,'cdproduto');?>"><?echo getByTagName($result->tags,'dsproduto');?></label>
						</td>
						<td style="text-align:left;">
						<? if (getByTagName($result->tags,'flativo') != 'S') { ?>	
							<input name="<?echo getByTagName($result->tags,'cdproduto');?>" id="habilitar"  class="checkbox" type="checkbox" />
						<? } ?>	
							<input type="hidden" id="flgkitbv "          name="flgkitbv"           value="<? echo getByTagName($result->tags,'flgkitbv') ?>" />							
						</td>
										
					</tr>
													
				<?}?>
							
			</table>
				
			<br style="clear:both" />	
			
		</fieldset>
					
	</form>
	
	<form id="frmServicosAdicionais" name="frmServicosAdicionais" class="formulario">	
			
		<fieldset>
		
			<legend><? echo utf8ToHtml('ADICIONAIS') ?></legend>
								
			<table id="tabelaServicosAdicionais" style="padding-left:0px;width:100%">
			
				<tr>	
					<td></td>		
					<td></td>	
					<td style="vertical-align: bottom; ">
						<label >Ofertar</label>
					</td>	
					<td style="vertical-align: bottom; ">
						<label >Habilitar</label>
					</td>
					<td style="vertical-align: bottom;">
						<label >Outras Instit.</label>
					</td>
					<td style="vertical-align: bottom; ">
						<label >Vencimento</label>
					</td>											
				</tr>		
				
				<? foreach( $regServicosAdicionais as $result) {?>
											
					<tr id="<?echo getByTagName($result->tags,'cdproduto');?>" >		

						<?if(getByTagName($result->tags,'flativo') == 'N'){?>						
							<td><a style="padding: 0px 0 0 3px;"><img style="width:25px; height:25px;" src="<? echo $UrlImagens; ?>geral/servico_nao_ativo.gif" id="lupaServico" name="lupaServico"/></a></td>							
						<?}else if(getByTagName($result->tags,'flativo') == 'S'){?>	
							<td><a style="padding: 0px 0 0 3px;"><img style="width:25px; height:25px;" src="<? echo $UrlImagens; ?>geral/servico_ativo.gif" id="lupaServico" name="lupaServico" /></a></td>
						<?}else{?>
							<td></td>
						<?}?>	
					
						<td style="text-align:left; width:260px;">
							<label for="<?echo getByTagName($result->tags,'cdproduto');?>"><?echo getByTagName($result->tags,'dsproduto'); ?></label>
						</td>	
						<td style="text-align:left; ">
							<input name="<?echo getByTagName($result->tags,'cdproduto');?>" id="ofertar" class="checkbox" type="checkbox" />
						</td>
					
						<td style="text-align:center; ">
							<? if (getByTagName($result->tags,'flativo') != 'S') { ?>	
								<input name="<?echo getByTagName($result->tags,'cdproduto');?>" id="habilitar" class="checkbox" type="checkbox" />
							<? } ?>
						</td>
						
						<td style="text-align:center; ">
							<input name="<?echo getByTagName($result->tags,'cdproduto');?>" id="outras" class="checkbox" type="checkbox" />
						</td>
						<td style="text-align:left;">
							<input name="<?echo getByTagName($result->tags,'cdproduto');?>" id="vencimento" class="campo" type="text" />
							<input type="hidden" id="flgkitbv " name="flgkitbv" value="<? echo getByTagName($result->tags,'flgkitbv') ?>" />	
						</td>	

						<input type="hidden" name="<?echo getByTagName($result->tags,'cdproduto');?>" id="checkadesaoexterna" value="<? echo getByTagName($result->tags,'checkadesaoexterna'); ?>" />			
						<input type="hidden" name="<?echo getByTagName($result->tags,'cdproduto');?>" id="checkvencto"        value="<? echo getByTagName($result->tags,'checkvencto'); ?>"        />				
						<input type="hidden" name="<?echo getByTagName($result->tags,'cdproduto');?>" id="inadesaoexterna"    value="<? echo getByTagName($result->tags,'inadesaoexterna'); ?>"    />
						<input type="hidden" name="<?echo getByTagName($result->tags,'cdproduto');?>" id="dtvencto"           value="<? echo getByTagName($result->tags,'dtvencto'); ?>"           />
						
					</tr>
			
				<? } ?>
		
			</table>
					
			<br style="clear:both" />	
					
		</fieldset>
					
	</form>
	
	
	<br style="clear:both" />	
	
	<div id="divBotoes">
	
		<div id="divBotoesServicos" style="margin-top:5px; margin-bottom :10px; text-align: center;">
		
			<a href="#" class="botao" id="btSalvar">Continuar</a>
			
		</div>
		
		<div id="divBotoesServicosAdicionais" style="margin-top:5px; margin-bottom :10px; text-align: center;">
		
			<a href="#" class="botao" id="btSalvar">Continuar</a>
			
		</div>
		
	</div>
		
</div>

<script type="text/javascript">

	var tamFrmServicos = parseFloat($('#frmServicos').css('height').replace('px','')) ;
	var tamFrmServicosAdicionais = parseFloat($('#frmServicosAdicionais').css('height').replace('px','')) ;
				
	if(tamFrmServicos > tamFrmServicosAdicionais){
		$('#frmServicosAdicionais').css('height',tamFrmServicos + 'px');
		$('#frmServicos').css('height',tamFrmServicos + 'px');
	}else{ 
		$('#frmServicosAdicionais').css('height',tamFrmServicosAdicionais + 'px');
		$('#frmServicos').css('height',tamFrmServicosAdicionais + 'px');
		
	}
		
	hideMsgAguardo();
	
	bloqueiaFundo(divRotina);
	
	controlaLayout('<?echo $opeProdutos?>');	
	
</script>
	
	



