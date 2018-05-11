<?
/*!
 * FONTE        : imp_termo_pf._html.php
 * CRIAÇÃO      : Gabriel Capoia (DB1)
 * DATA CRIAÇÃO : 12/04/2010 
 * OBJETIVO     : Responsável por buscar as informações que serão apresentadas no PDF de Termo da 
 *                rotina Impressões.
 *
 * ALTERAÇÕES   : 14/08/2013 - Alteração da sigla PAC para PA (Carlos).
 */	 
?>
<?
	require_once('../../../includes/funcoes.php');
	require_once('../../../class/xmlfile.php');
	
	$xmlObjeto = $GLOBALS['xmlObjeto']; 	
		
	$termoIdent = $xmlObjeto->roottag->tags[23]->tags[0]->tags;
	$termoAssin = $xmlObjeto->roottag->tags[24]->tags[0]->tags;
		
?>
<style type="text/css">
	pre { 
		font-family: monospace, "Courier New", Courier; 
		font-size:9pt;
	}
	p {
		 page-break-before: always;
		 padding: 0px;
		 margin:0px;	
	}
</style>
<?
if ( count($termoIdent) != 0 ) {
	echo '<pre>';
	if ( count($termoIdent) != 0 ) {	
		if ( $GLOBALS['tprelato'] == 'completo' ) { 
			echo "<p>&nbsp;</p>"; $GLOBALS['numPagina']++; $GLOBALS['numLinha'] = 0;
			//escreveLinha( preencheString('PAG '.$GLOBALS['numPagina'],76,' ','D') );	
		}
		
		$linha = preencheString(getByTagName($termoIdent,'nmextcop'),76);
		escreveLinha( $linha );
		
		escreveLinha( '' );escreveLinha( '' );escreveLinha( '' );
		
		$linha = preencheString('PA: ',47,' ','D');
		$linha .= preencheString(getByTagName($termoIdent,'cdagenci'),8);
		$linha .= ' CONTA/DV: '.preencheString(getByTagName($termoIdent,'nrdconta'),11);
		escreveLinha( $linha );
	
		pulaLinha(4);
		
		echo '<b>';escreveLinha( preencheString('TERMO DE CONHECIMENTO E AUTORIZACAO',76,' ','C') );echo '</b>';
		
		pulaLinha(3);
		
		$linha = preencheString('Em  conformidade  com  a  legislacao  vigente  e  os  normativos  do  Banco',76);
		escreveLinha( $linha );
		
		$linha = preencheString('Central  do  Brasil,  como  titular  da  conta-corrente     <b>'.getByTagName($termoIdent,'nrdconta').'</b>  , na',83);
		escreveLinha( $linha );
				
		echo '<b>';escreveLinha( preencheString( preencheString(' '.getByTagName($termoIdent,'nmextcop'),51).preencheString(' - '.getByTagName($termoIdent,'nmrescop'),18).'</b>,  de-',80) );
		
		escreveLinha( preencheString('claro que:',76) );
		escreveLinha( preencheString('a) Tenho conhecimento que a Cooperativa  tem  parceria com outras institui-',76) );
		escreveLinha( preencheString('coes para execucao dos servicos de: Centralizacao da Compensacao de Cheques',76) );
		escreveLinha( preencheString('e Outros Papeis (COMPE); manutencao do Cadastro de Emitentes de Cheques sem',76) );
		escreveLinha( preencheString('Fundos; Sistema de Liquidacao de Pagamentos e Transferencias Interbancarias',76) );
		escreveLinha( preencheString('do Sistema Financeiro Nacional; e, a disponibilizacao  de  Cartoes e Conve-',76) );
		escreveLinha( preencheString('nios diversos;',76) );
		escreveLinha( preencheString('b) Minha relacao contratual e exclusiva com a Cooperativa, sendo que somen-',76) );
		escreveLinha( preencheString('te poderei cobrar desta as responsabilidades decorrentes  da  prestacao de',76) );
		escreveLinha( preencheString('servicos por terceiros, podendo a Cooperativa  se  valer do direito de re-',76) );
		escreveLinha( preencheString('gresso; e',76) );
		escreveLinha( preencheString('c) Autorizo a Cooperativa a repassar minhas informacoes cadastrais as ins-',76) );
		escreveLinha( preencheString('tituicoes parceiras para consecucao dos servicos relacionados no item \'a\'.',76) );
		
		pulaLinha(3);
		
		escreveLinha( preencheString(getByTagName($termoIdent,'dsmvtolt'),76) );
		
		pulaLinha(6);
		
		escreveLinha( preencheString('________________________________________',76) );
		escreveLinha( preencheString(getByTagName($termoAssin,'nmprimtl'),76) );
		escreveLinha( preencheString('CPF/CNPJ: '.getByTagName($termoAssin,'nrcpfcgc'),76) );
		
		pulaLinha(9);
		
		escreveLinha( preencheString('________________________________________',76) );
		escreveLinha( preencheString('OPERADOR - '.getByTagName($termoAssin,'nmoperad'),76) );
	}	
	echo '</pre>';
}	
?>