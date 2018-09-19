<?php

	/***********************************************************************************
	  Fonte: busca_rel_solicitados.php                                               
	  Autor: Adriano                                                  
	  Data : Março/2015                     		  Última Alteração: 
	                                                                   
	  Objetivo  : Busca os relatórios solicitados do usuário logado e lista em uma tabela
				  para que possam ser visualizados no browser.
	                                                                 
	  Alterações: 
	                                                                  
	************************************************************************************/

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
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
	
		exibirErro('error',$msgError,'Alerta - Aimaro','',false);
	}
		
	validaDados();
	
	$nriniseq = (isset($_POST["nriniseq"])) ? $_POST["nriniseq"] : 1;
	$nrregist = (isset($_POST["nrregist"])) ? $_POST["nrregist"] : 30;
	$idtiprel = (isset($_POST["idtiprel"])) ? $_POST["idtiprel"] : '';
	$dsiduser = session_id();			
	
	$xmlSolicitaRelatorioBeneficiosPagar .= "";
	$xmlSolicitaRelatorioBeneficiosPagar .= " <Root>";
	$xmlSolicitaRelatorioBeneficiosPagar .= "    <Dados>";
	$xmlSolicitaRelatorioBeneficiosPagar .= "	    <dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xmlSolicitaRelatorioBeneficiosPagar .= "       <cddopcao>".$cddopcao."</cddopcao>";
	$xmlSolicitaRelatorioBeneficiosPagar .= "       <dsiduser>".$dsiduser."</dsiduser>";	
	$xmlSolicitaRelatorioBeneficiosPagar .= "	  	<nriniseq>".$nriniseq."</nriniseq>";
	$xmlSolicitaRelatorioBeneficiosPagar .= "		<nrregist>".$nrregist."</nrregist>";	
	$xmlSolicitaRelatorioBeneficiosPagar .= "		<idtiprel>".$idtiprel."</idtiprel>";
	$xmlSolicitaRelatorioBeneficiosPagar .= "    </Dados>";
	$xmlSolicitaRelatorioBeneficiosPagar .= "</Root>";
		
	// Executa script para envio do XML e cria objeto para classe de tratamento de XML
	$xmlResult = mensageria($xmlSolicitaRelatorioBeneficiosPagar, "INSS", "RELSOLINSS", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObjSolicitaRelatorioBeneficiosPagar = getObjectXML($xmlResult);	
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjSolicitaRelatorioBeneficiosPagar->roottag->tags[0]->name) == "ERRO") {
	
		$msgErro = $xmlObjSolicitaRelatorioBeneficiosPagar->roottag->tags[0]->tags[0]->tags[4]->cdata;
		
		if($idtiprel == 'PAGAR'){
		    
			$mtdErro = "controlaVoltar('V8');$('input','#frmRelatorioBeneficiosPagar').removeClass('campoErro');";  
			 
		}else{
			
			$mtdErro = "controlaVoltar('V7');$('input','#frmRelatorioBeneficiosPagos').removeClass('campoErro');";  
			
		}
		
		exibirErro('error',$msgErro,'Alerta - Aimaro',$mtdErro.'blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));',false);
			
	}   
	
	$registros = $xmlObjSolicitaRelatorioBeneficiosPagar->roottag->tags;
	$qtregist  = $xmlObjSolicitaRelatorioBeneficiosPagar->roottag->attributes["QTREGIST"];	
	
	?>
	
	<div id="divRegistros" class="divRegistros">
		<table>
			<thead>
				<tr>
					<th>Horário</th>					
					<th>Relatório</th>					
				</tr>			
			</thead>
			<tbody>
				<?
				for($i=0; $i<count($registros); $i++){		    
			
					// Recebo todos valores em variáveis
					$nmrelato = getByTagName($registros[$i]->tags,'nmrelato');
					$nmfinal = getByTagName($registros[$i]->tags,'nmfinal');
					$horario = getByTagName($registros[$i]->tags,'horario');
																						
				?>			
					<tr>
						<td><span><? echo $horario ?></span>
							<? echo $horario; ?>
							
						</td>
						<td><span><? echo $nmfinal ?></span>
							<? echo $nmfinal; ?>
							
						</td>
						
						<input type="hidden" id="nmrelato" value="<?echo $nmrelato;?>"/>
															
					</tr>	
				<? } ?>			
			</tbody>
		</table>
	</div>

	<div id="divPesquisaRodape" class="divPesquisaRodape">
		<table>	
			<tr>
				<td>
					<?					
						//
						if (isset($qtregist) and $qtregist == 0) $nriniseq = 0;
						
						// Se a paginação não está na primeira, exibe botão voltar
						if ($nriniseq > 1) { 
							?> <a class='paginacaoAnt'><<< Anterior</a> <? 
						} else {
							?> &nbsp; <?
						}
					?>
				</td>
				<td>
					<?
						if (isset($nriniseq)) { 
							?> Exibindo <? echo $nriniseq; ?> at&eacute; <? if (($nriniseq + $nrregist) > $qtregist) { echo $qtregist; } else { echo ($nriniseq + $nrregist - 1); } ?> de <? echo $qtregist; ?><?
						}
					?>
				</td>
				<td>
					<?
						// Se a paginação não está na &uacute;ltima página, exibe botão proximo
						if ($qtregist > ($nriniseq + $nrregist - 1)) {
							?> <a class='paginacaoProx'>Pr&oacute;ximo >>></a> <?
						} else {
							?> &nbsp; <?
						}
					?>			
				</td>
			</tr>
		</table>
	</div>

	<script type="text/javascript">
		$('a.paginacaoAnt').unbind('click').bind('click', function() {
			buscaRelatorioSolicitados(<? echo "'".($nriniseq - $nrregist)."','".$nrregist."','".$idtiprel."','".$cddopcao."'"; ?>);					      
		});
		$('a.paginacaoProx').unbind('click').bind('click', function() {
			buscaRelatorioSolicitados(<? echo "'".($nriniseq + $nrregist)."','".$nrregist."','".$idtiprel."','".$cddopcao."'"; ?>);
		});	
		
		$('#divPesquisaRodape').formataRodapePesquisa();
		
		if('<?echo $idtiprel?>' == "PAGOS"){
		
			$('#frmRelatorioBeneficiosPagos').css('display','none');
			$('#btGerados','#divBotoesRelatorioBeneficiosPagos').css('display','none');
			$('#btConcluir','#divBotoesRelatorioBeneficiosPagos').css('display','none');
			
			//Adiciona o evento click ao botao btVoltar
			$('#btVoltar','#divBotoesRelatorioBeneficiosPagos').unbind('click').bind('click', function(){
			
				controlaVoltar('V7');
				return false;
				
			});
			
		}else{
		
			$('#frmRelatorioBeneficiosPagar').css('display','none');
			$('#btGerados','#divBotoesRelatorioBeneficiosPagar').css('display','none');
			$('#btConcluir','#divBotoesRelatorioBeneficiosPagar').css('display','none');
			
			//Adiciona o evento click ao botao btVoltar
			$('#btVoltar','#divBotoesRelatorioBeneficiosPagar').unbind('click').bind('click', function(){
			
				controlaVoltar('V8');
				return false;
				
			});
			
		}
		
		$('#divTabelaRelatorios').css('display','block');
		formataTabela();
		blockBackground(parseInt($('#divRotina').css('z-index')));
		
	</script>

	
	<?
	function validaDados(){

		
	}	
			
?>



				


				

