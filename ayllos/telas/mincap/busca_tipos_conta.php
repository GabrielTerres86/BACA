<?php

	/**************************************************************************************
	  Fonte: bsuc_tipos_conta.php                                               
	  Autor: Jonata - RKAM                                                  
	  Data : Junho/2017                       			Última Alteração:  
	                                                                   
	  Objetivo  : Realiza a busca dos tipos de conta para o campo "Tipo de conta"
	                                                                 
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
	$cdcopsel = (isset($_POST["cdcopsel"])) ? $_POST["cdcopsel"] : 0;    
	$nriniseq = isset($_POST["nriniseq"]) ? $_POST["nriniseq"] : 0;
	$nrregist = isset($_POST["nrregist"]) ? $_POST["nrregist"] : 0;
	$tppessoa = (isset($_POST["tppessoa"])) ? $_POST["tppessoa"] : 0;    
		
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
	
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}					
		
	validaDados();
		
	$xml = "<Root>";
	$xml .= " <Dados>";
	$xml .= "   <cdcopsel>".$cdcopsel."</cdcopsel>";
	$xml .= "   <nrregist>".$nrregist."</nrregist>";	
	$xml .= "   <nriniseq>".$nriniseq."</nriniseq>";
	$xml .= "	<tppessoa>".$tppessoa."</tppessoa>";
	$xml .= " </Dados>";
	$xml .= "</Root>";

	$xmlResult = mensageria($xml, "CADA0003", "BUSCA_TIPOS_CONTA", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObj = getObjectXML($xmlResult);

	if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
		$msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
		if ($msgErro == "") {
			$msgErro = $xmlObj->roottag->tags[0]->cdata;
		}

		exibirErro('error',$msgErro,'Alerta - Ayllos','estadoInicial();',false);
		
	}	
	
	$registros = $xmlObj->roottag->tags[0]->tags;
    $qtregist  = $xmlObj->roottag->attributes["QTREGIST"];
	
	function validaDados(){
		
		//Código da cooperativa
        if ( $GLOBALS["cdcopsel"] == '0'){
            exibirErro('error','Cooperativa inv&aacute;lida.','Alerta - Ayllos','$(\'#cdcopsel\',\'#frmFiltro\').focus();',false);
        }
		
		//Tipo da pessoa
        if (  $GLOBALS["tppessoa"] != 1 && $GLOBALS["tppessoa"] != 2){
            exibirErro('error','Tipo da pessoa inv&aacute;lido.','Alerta - Ayllos','$(\'#cdcopsel\',\'#frmFiltro\').focus();',false);
        }
				
								
	}
?>


<form id="frmTiposConta" name="frmTiposConta" class="formulario" style="display:none;">	
	
	<fieldset id="fsetTiposConta" name="fsetTiposConta" style="padding:0px; margin:0px; padding-bottom:10px;">
	
		<legend><? echo "Tipos de Conta"; ?></legend>		
			
		<div class="divRegistros">		
			<table>
				<thead>
					<tr>
					   <th>Tipo</th>
					   <th>Descri&ccedil;&atilde;o</th>
					   <th>Valor</th>
					</tr>
				</thead>
				<tbody>
					<? for ($i = 0; $i < count($registros); $i++) {    ?>
					
						<tr>	
							<td><span><? echo getByTagName($registros[$i]->tags,'cdtipcta'); ?></span> <? echo getByTagName($registros[$i]->tags,'cdtipcta'); ?> </td>
							<td><span><? echo getByTagName($registros[$i]->tags,'dstipcta'); ?></span> <? echo getByTagName($registros[$i]->tags,'dstipcta'); ?> </td>
							<td><span><? echo getByTagName($registros[$i]->tags,'vlminimo'); ?></span> <? echo getByTagName($registros[$i]->tags,'vlminimo'); ?> </td>
							
							<input type="hidden" id="valorMinimo" name="valorMinimo" value="<?echo getByTagName($registros[$i]->tags,'vlminimo'); ?>"/>
							<input type="hidden" id="tipoConta" name="tipoConta" value="<?echo getByTagName($registros[$i]->tags,'cdtipcta'); ?>"/>
							
						</tr>	
					<? } ?>
				</tbody>	
			</table>
		</div>
		<div id="divRegistrosRodape" class="divRegistrosRodape">
			<table>	
				<tr>
					<td>
						<? if (isset($qtregist) and $qtregist == 0){ $nriniseq = 0;} ?>
						<? if ($nriniseq > 1){ ?>
							   <a class="paginacaoAnt"><<< Anterior</a>
						<? }else{ ?>
								&nbsp;
						<? } ?>
					</td>
					<td>
						<? if (isset($nriniseq)) { ?>
							   Exibindo <? echo $nriniseq; ?> at&eacute; <? if (($nriniseq + $nrregist) > $qtregist) { echo $qtregist; } else { echo ($nriniseq + $nrregist - 1); } ?> de <? echo $qtregist; ?>
							<? } ?>
					</td>
					<td>
						<? if($qtregist > ($nriniseq + $nrregist - 1)) { ?>
							  <a class="paginacaoProx">Pr&oacute;ximo >>></a>
						<? }else{ ?>
								&nbsp;
						<? } ?>
					</td>
				</tr>
			</table>
		</div>	
		
		<br style="clear:both" />	

	</fieldset>
					
							
</form>

<div id="divBotoesTiposConta" style="margin-top:5px; margin-bottom :10px; display:none; text-align: center;">
		
	<a href="#" class="botao" id="btVoltar" onClick="controlaVoltar('2');">Voltar</a>
	
	<?if(count($registros) > 0){?>
		<a href="#" class="botao" id="btProsseguir" >Prosseguir</a>	
	<?}?>
				
</div>

<script type="text/javascript">
	
	
	$('input,select','#frmFiltro').desabilitaCampo();
	$('#divBotoesFiltro').css('display','none');
	
	$('a.paginacaoAnt','#frmTiposConta').unbind('click').bind('click', function() {
		
		buscaTiposConta('<? echo ($nriniseq - $nrregist)?>','<?php echo $nrregist?>');
		
    });

	$('a.paginacaoProx','#frmTiposConta').unbind('click').bind('click', function() {
		
		buscaTiposConta('<? echo ($nriniseq + $nrregist)?>','<?php echo $nrregist?>');
		
	});	
	
	formataTabelaTiposContas();
	
</script>

