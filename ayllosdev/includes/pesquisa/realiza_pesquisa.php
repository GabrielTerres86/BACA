<?php
   /* FONTE        : realiza_pesquisa.php
 * CRIAÇÃO      : Rodolpho Telmo (DB1)
 * DATA CRIAÇÃO : Janeiro/2010
 * OBJETIVO     : Realiza a pesquisa genérica
 * --------------
 * ALTERAÇÕES   :
 * --------------
	* 001: [22/10/2020] David          (CECRED) : Incluir novo parametro para a funcao getDataXML (David).
 * 002: [17/16/2011] Gabriel Capoia (DB1) : Tratamento para retornar um valor diferente do que é exibido na busca ( Ex.: Exibe completo e retorna o resumido ).
	* 003: [07/08/2012] Adriano	       (CECRED) : Incluido o parametro rotina. Ajuste referente ao projeto GP - Sócios Menores.
	* 004: [28/01/2014] Jorge   	   (CECRED) : Ajuste em popular tabela, verificando caso venha "yes" ou "no" e botando em portugues.
	* 005: [16/05/2014] Jean Michel    (CECRED) : inclusao do parametro nmdatela na montagem do XML (Projeto de Novos Cartões Bancoob (TELA TRNBCB)).
	* 006: [31/03/2015] Jorge          (CECRED) : Adicionado parametro $opcoesColuna[5], opcional para coluna ficar visivel ou nao. (SD 229250)
	* 007: [23/04/2015] Vanessa 	   (CECRED) : Tratamemnto para mostrar o nrispbif com 8 posições
	* 008: [17/07/2015] Gabriel        (RKAM)   : Suporte para rotinas Oracle.  
	* 009: [27/07/2016] Carlos R.	   (CECRED) : Corrigi a forma de recuperacao dos dados do XML. SD 479874.
	* 010: [08/11/2016] Jaison/Andrino (CECRED) : Ajuste para passar o CDOPERAD e nao NMOPERAD como parametro da mensageria.
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
		 !isset($_POST["colunas"       ]) ) { 
		 exibirErro('error','Parâmetros incorretos para a pesquisa.','Alerta - Aimaro','bloqueiaFundo($(\'#divPesquisa\'))');
	}	
	
	// Pega os valores nas devidas variáveis
	$businessObject	= $_POST["businessObject"];
	$nomeProcedure	= $_POST["nomeProcedure"];
	$tituloPesquisa	= $_POST["tituloPesquisa"];
	$filtros		= $_POST["filtros"];
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
	
		
	// Verifica se e' uma rotina Progress ou Oracle
	$flgProgress = (substr($businessObject,0,6) == 'b1wgen');
	
	
	// Monta o xml de requisição
	$xml  = "";
	$xml .= "<Root>";
	
	if ($flgProgress) {
	
		$xml .= "  <Cabecalho>";
		$xml .= "  		<Bo>".$businessObject."</Bo>";
		$xml .= "		<Proc>".$nomeProcedure."</Proc>";
		$xml .= "  </Cabecalho>";
	
	}
	
	$xml .= "  <Dados>";
	
	if ($flgProgress) {
	
		$xml .= "        <cdcooper>".$cdcooper."</cdcooper>";
		$xml .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
		$xml .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
		$xml .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
		$xml .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";
		$xml .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	
	}
	
	// Explodo a variavel filtros para obter a quantidade de campos que deve ser passada ao XML
	$filtroParametro = '';
	$arrayFiltros = explode("|", $filtros);	
	
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

	$xml .= "		<nriniseq>".$nriniseq."</nriniseq>";
	$xml .= "		<nrregist>".$nrregist."</nrregist>";
	$xml .= "  </Dados>";
	$xml .= "</Root>";	
	
	// Executa script para envio do XML e Cria objeto para classe de tratamento de XML	
	if ($flgProgress) {
		$xmlResult = getDataXML($xml,false);
	} else {
		$xmlResult = mensageria($xml, $businessObject, $nomeProcedure, $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	}
	
	$xmlObjPesquisa = getObjectXML($xmlResult);	
	
	// Se ocorrer um erro, mostra cr&iacute;tica
	if (isset($xmlObjPesquisa->roottag->tags[0]->name) && strtoupper($xmlObjPesquisa->roottag->tags[0]->name) == "ERRO") 
		exibirErro('error',$xmlObjPesquisa->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Aimaro','bloqueiaFundo($(\'#divPesquisa\'))');
	
	$pesquisa = ( isset($xmlObjPesquisa->roottag->tags[0]->tags) ) ? $xmlObjPesquisa->roottag->tags[0]->tags : array(); 
	
	// Quantidade total de cooperados na pesquisa
	$qtregist = ( isset($xmlObjPesquisa->roottag->tags[0]->attributes["QTREGIST"]) ) ? $xmlObjPesquisa->roottag->tags[0]->attributes["QTREGIST"] : 0;
?>	

<div id="divPesquisaItens" class="divPesquisaItens">
	<table>
		<?php
		// Explodo as colunas pelo pipe "|".
		$arrayColunas = explode("|", $colunas);
		
		// Caso a pesquisa não retornou itens, montar uma célula mesclada com a quantidade colunas que seria exibida
		if ( count($pesquisa) == 0 ) {
			$i = 0;					
			// Monta uma coluna mesclada com a quantidade de colunas que seria exibida
			?> 
			<tr>
				<td colspan="<? echo count($arrayColunas); ?>" style="font-size:12px; text-align:center;">
					<? echo utf8ToHtml('Não existe '.$tituloPesquisa.' com os dados informados.'); ?>
				</td>
			</tr> 
			<?php						
		} else {	
			// Realiza um loop nos registros retornados e desenha cada um em uma linha da tabela
			for($i = 0; $i < count($pesquisa); $i++) {							
				
				// Monto a string, no formato abaixo, que será passada como parâmetro para a função selecionaPesquisa: (campoNome;resultado|campoNome;resultado)
				// A primeira componente de cada item separado pelo pipe "|", o "campoNome" deve casar com a segunda componente "resultado" da seguinte forma:
				// O 1º "campoNome" do Filtro, vai casar com 1º "resultado" das Colunas
				// O 2º "campoNome" do Filtro, vai casar com 2º "resultado" das Colunas, e assim por diante
				$stringParametro = "";	 			
				for($j = 0; $j < count($arrayColunas); $j++) {					
				
					// Caso a variável $stringParametro não é vazia, concatenar o pipe (|) indicando que é outro campoRetorno
					$stringParametro .= ($stringParametro == "") ? "" : "|";						
					
					// Explodo os arrays para obter suas opções
					$opcoesColunas  = ( isset($arrayColunas[$j]) ) ? explode(";", $arrayColunas[$j]) : array();
					$opcoesFiltros  = ( isset($arrayFiltros[$j]) ) ? explode(";", $arrayFiltros[$j]) : array();
					
					$campoNome  = ( isset($opcoesFiltros[0]) ) ? $opcoesFiltros[0] : '';
					$colunaNome = ( isset($opcoesColunas[1]) ) ? $opcoesColunas[1] : '';
					$campoBusca = ( isset($opcoesColunas[4]) ) ? $opcoesColunas[4] : '';
					
					$resultado  = getByTagName($pesquisa[$i]->tags,$colunaNome);
					$resultado  = str_replace("'","\'",$resultado);
					
					if ( $campoBusca != null ){ 
						$resultado1 = getByTagName($pesquisa[$i]->tags,$campoBusca);
						$stringParametro .= $campoNome.";".$resultado1;
					}else{					
						$stringParametro .= $campoNome.";".$resultado;
					}
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
				<?
			} // fecha o loop for
		} // fecha o else
		?>			
	</table>
	<br clear="both" />
</div>

<script type="text/javascript">

	$('a.paginacaoAnt').unbind('click').bind('click', function() {
		realizaPesquisa(<? echo "'".($nriniseq - $nrregist)."','".$nrregist."','".$businessObject."','".$nomeProcedure."','".utf8ToHtml($tituloPesquisa)."','".$filtroParametro."','".$colunas."','".$rotina."'," . $cdcooper ; ?>);
	});
	
	$('a.paginacaoProx').unbind('click').bind('click', function() {
		realizaPesquisa(<? echo "'".($nriniseq + $nrregist)."','".$nrregist."','".$businessObject."','".$nomeProcedure."','".utf8ToHtml($tituloPesquisa)."','".$filtroParametro."','".$colunas."','".$rotina."'," . $cdcooper ; ?>);
	});	
	
</script>

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

	hideMsgAguardo();
	bloqueiaFundo($("#divPesquisa"));
	
</script>