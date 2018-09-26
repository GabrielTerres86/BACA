<?php
   /* FONTE        : realiza_pesquisa_dominios.php
	* CRIAÇÃO      : Rodolpho Telmo (DB1)
	* DATA CRIAÇÃO : Jonata/2017
	* OBJETIVO     : Realiza a pesquisa de dominios
	* --------------
	* ALTERAÇÕES   :
	* --------------
	
	*/ 

	session_start();
	require_once("../config.php");
	require_once("../funcoes.php");
	require_once("../controla_secao.php");
	require_once("../../class/xmlfile.php");
	isPostMethod();		
		
	// Verifica se os parâmetros de desenvolvimento necessários 
	if ( !isset($_POST["businessObject"]) || 
	     !isset($_POST["nomeProcedure" ]) || 
		 !isset($_POST["tituloPesquisa"]) ||
		 !isset($_POST["filtros"       ]) ||
		 !isset($_POST["camposRetorno" ])) { 
		 exibirErro('error','Parâmetros incorretos para a pesquisa.','Alerta - Aimaro','bloqueiaFundo($(\'#divPesquisa\'))');
	}	
	
	// Pega os valores nas devidas variáveis
	$businessObject	= $_POST["businessObject"];
	$nomeProcedure	= $_POST["nomeProcedure"];
	$tituloPesquisa	= $_POST["tituloPesquisa"];
	$filtros		= $_POST["filtros"];
	$camposRetorno	= utf8_decode($_POST["camposRetorno"]);
	$colunas		= utf8_decode($_POST["colunas"]);
	$rotina			= $_POST["rotina"] == '' ? 'undefined' : $_POST["rotina"];
	$cdcooper		= $_POST["cdcooper"];
	
	if ($cdcooper == null || $cdcooper == 0 || $cdcooper == ''){
		$cdcooper = $glbvars["cdcooper"];
	}
		
	// OBSERVAÇÕES
	// LAYOUT FILTROS: "filtroNome;filtroValor|filtroNome;filtroValor"
	// LAYOUT COLUNAS: "rotulo;campo;largura;alinhamento|rotulo;campo;largura;alinhamento";
	
	// Dados para paginação dos cooperados
	$nriniseq	= isset($_POST["nriniseq"]) ? $_POST["nriniseq"] : 1;
	$nrregist	= isset($_POST["quantReg"]) ? $_POST["quantReg"] : 20;	
	
	// Monta o xml de requisição
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "  <Dados>";
	
	// Explodo a variavel filtros para obter a quantidade de campos que deve ser passada ao XML
	$filtroParametro = '';
	$arrayFiltros = explode("|", $filtros);	
	$arrayCamposRetorno = explode(";", $camposRetorno);	
	
	foreach( $arrayFiltros as $itens ) {
	
		$filtroParametro .= ($filtroParametro == '') ? '' : ';';
		
		// Explodo a variavel campo para obter seu nome e valor
		$opcao = explode(";", $itens);
		
		// Recebendo os valores
		$nome	= $opcao[0];
		$valor	= $opcao[1];
		
		$filtroParametro .= $nome;
		
		// Inserindo no XML
		$xml .= "		<".$nome.">".$valor."</".$nome.">";				
	}		

	$xml .= "		<nrregist>".$nrregist."</nrregist>";
	$xml .= "		<nriniseq>".$nriniseq."</nriniseq>";
	$xml .= "  </Dados>";
	$xml .= "</Root>";	
	
	$xmlResult = mensageria($xml, $businessObject, $nomeProcedure, $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObjPesquisa = getObjectXML($xmlResult);	
	
	// Se ocorrer um erro, mostra cr&iacute;tica
	if (isset($xmlObjPesquisa->roottag->tags[0]->name) && strtoupper($xmlObjPesquisa->roottag->tags[0]->name) == "ERRO") 
		exibirErro('error',$xmlObjPesquisa->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Aimaro','bloqueiaFundo($(\'#divPesquisa\'))');
	
	$pesquisa = ( isset($xmlObjPesquisa->roottag->tags) ) ? $xmlObjPesquisa->roottag->tags : array(); 
	
	// Quantidade total de cooperados na pesquisa
	$qtregist = ( isset($xmlObjPesquisa->roottag->attributes["QTREGIST"]) ) ? $xmlObjPesquisa->roottag->attributes["QTREGIST"] : 0;
	$flpossui_subdominio = ( isset($xmlObjPesquisa->roottag->attributes["FLPOSSUI_SUBDOMINIO"]) ) ? $xmlObjPesquisa->roottag->attributes["FLPOSSUI_SUBDOMINIO"] : 0;
	$dstipo_dominio = ( isset($xmlObjPesquisa->roottag->attributes["DSTIPO_DOMINIO"]) ) ? $xmlObjPesquisa->roottag->attributes["DSTIPO_DOMINIO"] : '';
	
?>	

<script type="text/javascript">

	// Inicia da montagem do cabecalho da tabela dos resultados da pesquisa
	$("#formPesquisa").after('<div id="divCabecalhoPesquisa" class="divCabecalhoPesquisa"></div>');
	$("#divCabecalhoPesquisa").html('<table></table>');
	$("#divCabecalhoPesquisa > table").html('<thead></thead>');
	$("#divCabecalhoPesquisa > table > thead").html('<tr></tr>');
	
</script>

<? if($flpossui_subdominio == '0'){?>						
	
	<script type="text/javascript">
		
		$('div.divPesquisaItens').css({ 'height': '250px' });
		$("#divCabecalhoPesquisa > table").css("width","575px");
		$("#divCabecalhoPesquisa > table").css("float","left");
		$("#divResultadoPesquisa > table").css("width","590px");
		$("#divCabecalhoPesquisa").css("width","590px");
		$("#divResultadoPesquisa").css("width","590px");
		$("#divResultadoPesquisa").css("height","300px");
				
		// Definicoes das variaveis
		var arrayColunas 	= new Array();
		var paramColuna 	= new Array();

		var colunas = '<?echo $colunas;?>';
		var tipoColuna = colunas.split("#");
		
		// Explodo o parametro colunas para desenhar a tabela onde serao exibidos os resultados da pesquisa	
		arrayColunas = tipoColuna[0].split("|");
		for( var i in arrayColunas ) {		    
		
			// Explodo a coluna para obter suas opcoes
			paramColuna = arrayColunas[i].split(";");				
			
			// Atribuo as opcoes em variaveis
			var rotulo		= paramColuna[0];
			var campo		= paramColuna[1];
			var largura		= paramColuna[2];
			var alinhamento	= paramColuna[3];
			/*! alteracao 037 - utilizado o param [5] pois o [4] ja esta sendo usado em realiza_pesquisa.php */
			var colvisivel  = paramColuna[5] == undefined || paramColuna[5] == "S" ? "" : "display:none;";
			
			// Incluo a coluna na linha da tabela
			$("#divCabecalhoPesquisa > table > thead > tr").append('<td style="width:'+largura+';text-align:'+alinhamento+';'+colvisivel+'">'+rotulo+'</td>');		
		}		
		
	</script>	
	
<?}else{ ?>

	<script type="text/javascript">
	
		$('div.divPesquisaItens').css({ 'height': '250px' });
		$("#divCabecalhoPesquisa > table").css("width","675px");
		$("#divCabecalhoPesquisa > table").css("float","left");
		$("#divResultadoPesquisa > table").css("width","690px");
		$("#divCabecalhoPesquisa").css("width","690px");
		$("#divResultadoPesquisa").css("width","690px");
		$("#divResultadoPesquisa").css("height","300px");
		
		// Definicoes das variaveis
		var arrayColunas 	= new Array();
		var paramColuna 	= new Array();

		var colunas = '<?echo $colunas;?>';
		var tipoColuna = colunas.split("#");
		
		// Explodo o parametro colunas para desenhar a tabela onde serao exibidos os resultados da pesquisa	
		arrayColunas = tipoColuna[1].split("|");
		for( var i in arrayColunas ) {		    
		
			// Explodo a coluna para obter suas opcoes
			paramColuna = arrayColunas[i].split(";");				
			
			// Atribuo as opcoes em variaveis
			var rotulo		= paramColuna[0];
			var campo		= paramColuna[1];
			var largura		= paramColuna[2];
			var alinhamento	= paramColuna[3];
			/*! alteracao 037 - utilizado o param [5] pois o [4] ja esta sendo usado em realiza_pesquisa.php */
			var colvisivel  = paramColuna[5] == undefined || paramColuna[5] == "S" ? "" : "display:none;";
			
			// Incluo a coluna na linha da tabela
			$("#divCabecalhoPesquisa > table > thead > tr").append('<td style="width:'+largura+';text-align:'+alinhamento+';'+colvisivel+'">'+rotulo+'</td>');		
		}	
		
	</script>
	
<?} ?>	

<div id="divPesquisaItens" class="divPesquisaItens">	
	<table>		
		<?
			// Explodo as colunas pelo pipe "|".
			$tipoColunas = explode("#", $colunas);
		
			if($flpossui_subdominio == '0'){
			
			  $arrayColunas = explode("|", $tipoColunas[0]);
			  
			  for($i = 0; $i < count($pesquisa); $i++) {		 
			  
				$stringParametro = "";	 
				
				for($j = 0; $j < count($arrayCamposRetorno); $j++){
					
					$arrayCamposDePara = explode("|", $arrayCamposRetorno[$j]);								
					
					// Caso a variável $stringParametro não é vazia, concatenar o pipe (|) indicando que é outro campoRetorno
					$stringParametro .= ($stringParametro == "") ? "" : "|";						
					
					// Explodo os arrays para obter suas opções
					$camposDe  = ( isset($arrayCamposDePara[0]) ) ? $arrayCamposDePara[0] : '';
					$campoPara  = ( isset($arrayCamposDePara[1]) ) ? $arrayCamposDePara[1] : '';
					
					$resultado  = getByTagName($pesquisa[$i]->tags,$camposDe);
					$resultado  = str_replace("'","\'",$resultado);
					
					$stringParametro .= $campoPara.";".$resultado;
					
				}	
				?>
				
				<tr onClick="selecionaPesquisa(<? echo "'".$stringParametro."'"; ?>,<? echo "'".$rotina."'"; ?>); return false;">
					
					<?php	
					// Agora monto as colunas (td) da tabela, de acordo com o parâmetro colunas
					for($j = 0; $j < count($arrayColunas); $j++) {				
						
						// Explodo a variavel coluna para obter suas opções
						$opcoesColuna = explode(";", $arrayColunas[$j]);
						
						// Recebendo os valores
						$colunaRotulo		= ( isset($opcoesColuna[0]) ) ? $opcoesColuna[0] : '';
						$colunaNome			= ( isset($opcoesColuna[1]) ) ? $opcoesColuna[1] : '';
						$colunaLargura		= ( isset($opcoesColuna[2]) ) ? $opcoesColuna[2] : '';
						$colunaAlinhamento	= ( isset($opcoesColuna[3]) ) ? $opcoesColuna[3] : '';
						$colunaVisivel   	= ( isset($opcoesColuna[5]) && $opcoesColuna[5] != null && $opcoesColuna[5] == "N" ) ? "display:none;" : "";
						
						// Busco nas tags do resultado da pesquisa que tenha o mesmo nome da coluna que estou desenhando
						foreach( $pesquisa[$i]->tags as $tag ) {						    
							$resultado = ( $tag->name == strtoupper($colunaNome) ) ? ($tag->cdata == "yes" ? "Sim" : ($tag->cdata == "no" ? "N&atilde;o" : $tag->cdata)) : $resultado;
						}											
						?>	
						<td style="<? echo "width:".$colunaLargura.";text-align:".$colunaAlinhamento.";".$colunaVisivel ?>">
							<? echo $colunaNome == 'nrispbif' || $colunaNome == 'cdispbif' ? str_pad($resultado, 8, "0", STR_PAD_LEFT) : $resultado; ?>
						</td> 
						<?php
					} 
					?>						
					
				</tr>
				
		  <?} 
	
		}else{
		
			$arrayColunas = explode("|", $tipoColunas[1]);
			
			for($i = 0; $i < count($pesquisa); $i++) {	
			
				$stringParametro = "";	 
				
				for($j = 0; $j < count($arrayCamposRetorno); $j++){
					
					$arrayCamposDePara = explode("|", $arrayCamposRetorno[$j]);								
					
					// Caso a variável $stringParametro não é vazia, concatenar o pipe (|) indicando que é outro campoRetorno
					$stringParametro .= ($stringParametro == "") ? "" : "|";						
					
					// Explodo os arrays para obter suas opções
					$camposDe  = ( isset($arrayCamposDePara[0]) ) ? $arrayCamposDePara[0] : '';
					$campoPara  = ( isset($arrayCamposDePara[1]) ) ? $arrayCamposDePara[1] : '';
					
					$resultado  = getByTagName($pesquisa[$i]->tags,$camposDe);
					$resultado  = str_replace("'","\'",$resultado);
					
					$stringParametro .= $campoPara.";".$resultado;
					
				}
										
				?>
				  
				<tr onClick="selecionaPesquisa(<? echo "'".$stringParametro."'"; ?>,<? echo "'".$rotina."'"; ?>); return false;">
				
					<?php	
					// Agora monto as colunas (td) da tabela, de acordo com o parâmetro colunas
					for($j = 0; $j < count($arrayColunas); $j++) {				
						
						// Explodo a variavel coluna para obter suas opções
						$opcoesColuna = explode(";", $arrayColunas[$j]);
						
						// Recebendo os valores
						$colunaRotulo		= ( isset($opcoesColuna[0]) ) ? $opcoesColuna[0] : '';
						$colunaNome			= ( isset($opcoesColuna[1]) ) ? $opcoesColuna[1] : '';
						$colunaLargura		= ( isset($opcoesColuna[2]) ) ? $opcoesColuna[2] : '';
						$colunaAlinhamento	= ( isset($opcoesColuna[3]) ) ? $opcoesColuna[3] : '';
						$colunaVisivel   	= ( isset($opcoesColuna[5]) && $opcoesColuna[5] != null && $opcoesColuna[5] == "N" ) ? "display:none;" : "";
						
						// Busco nas tags do resultado da pesquisa que tenha o mesmo nome da coluna que estou desenhando
						foreach( $pesquisa[$i]->tags as $tag ) {						    
							$resultado = ( $tag->name == strtoupper($colunaNome) ) ? ($tag->cdata == "yes" ? "Sim" : ($tag->cdata == "no" ? "N&atilde;o" : $tag->cdata)) : $resultado;
						}											
						?>	
						<td style="<? echo "width:".$colunaLargura.";text-align:".$colunaAlinhamento.";".$colunaVisivel ?>">
							<? echo $colunaNome == 'nrispbif' || $colunaNome == 'cdispbif' ? str_pad($resultado, 8, "0", STR_PAD_LEFT) : $resultado; ?>
						</td> 
						<?php
					} 
					?>		
					
				</tr>
					
			<?} 
		
		}?>		
	
	</table>
	<br clear="both" />
</div>	

<div id="divPesquisaRodape" class="divPesquisaRodape">
	<table>	
		<tr>
			<td>
				<?php
					// Se a paginação não está na primeira, exibe botão voltar
					if ($nriniseq > 1) { 
						?> <a class='paginacaoAnt'><<< Anterior</a> <? 
					} else {
						?> &nbsp; <?
					}
				?>
			</td>
			<td>
				Exibindo <? echo $nriniseq; ?> at&eacute; <? if (($nriniseq + $nrregist) > $qtregist) { echo $qtregist; } else { echo ($nriniseq + $nrregist - 1); } ?> de <? echo $qtregist; ?>
			</td>
			<td>
				<?php
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
		realizaPesquisaDominios(<? echo "'".($nriniseq - $nrregist)."','".$nrregist."','".$businessObject."','".$nomeProcedure."','".utf8ToHtml($tituloPesquisa)."','".$filtroParametro."','".$rotina."'," . $cdcooper ; ?>);
				
	});
	
	$('a.paginacaoProx').unbind('click').bind('click', function() {
		realizaPesquisaDominios(<? echo "'".($nriniseq + $nrregist)."','".$nrregist."','".$businessObject."','".$nomeProcedure."','".utf8ToHtml($tituloPesquisa)."','".$filtroParametro."','".$rotina."'," . $cdcooper ; ?>);
	});	
	
	// Muda o t&iacute;tulo da Janela de acordo com o parâmetro tituloPesquisa
	$("span.tituloJanelaPesquisa").html( "pesquisa <? echo $tituloPesquisa.': '.$dstipo_dominio;?>" );
	
	//formataTabelaDominios('<?echo $flpossui_subdominio; ?>');
	hideMsgAguardo();
	bloqueiaFundo($("#divPesquisa"));
	
</script>