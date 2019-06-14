<?
/*!
 * FONTE        : imp_termo_pf_html.php
 * CRIAÇÃO      : Gabriel Capoia (DB1)
 * DATA CRIAÇÃO : 15/04/2010 
 * OBJETIVO     : Responsável por buscar as informações que serão apresentadas no PDF de Termo da 
 *                rotina Impressões.
 *
 * ALTERACOES   : 07/06/2011 - Aumento do formato da cidade (Gabriel)
 *                15/08/2013 - Alteração da sigla PAC para PA (Carlos)
 * 				  15/01/2014 - Ajuste em tamanho de UF para caber o CEP. (Jorge)
 *                07/02/2014 - Inclusao da data de demissao (Carlos)
 */	 
?>
<?
	require_once('../../includes/funcoes.php');
	require_once('../../class/xmlfile.php');
	
	$xmlObjeto = $GLOBALS['xmlObjeto']; 	
		
	$cabecalho    = $xmlObjeto->roottag->tags[0]->tags[0]->tags;
	$parcelamento = $xmlObjeto->roottag->tags[1]->tags[0]->tags;
	$pJuridica    = $xmlObjeto->roottag->tags[3]->tags[0]->tags;
	$procuradores = $xmlObjeto->roottag->tags[4]->tags;
	
	function preenchePagina( $str ){
		$j = 2;
		for( $i = $GLOBALS['numLinha']; $i < 81 ; $i++ ){
			escreveLinha( preencheString($str,$j,' ','D') );
			$j = $j+2;
		}	
	}
	
?>
<style type="text/css">
	pre { 
		font-family: monospace, "Courier New", Courier; 
		font-size:8pt;
	}
	p {
		 page-break-before: always;
		 padding: 0px;
		 margin:0px;	
	}
</style>
<?
	echo '<pre>'; 
	pulaLinha(1);
	escreveLinha( preencheString(getByTagName($cabecalho,'nmextcop'),69) );
	escreveLinha( preencheString(getByTagName($cabecalho,'dsendcop'),69) );
	escreveLinha( preencheString(getByTagName($cabecalho,'nrdocnpj'),69) );
	
	pulaLinha(2);
	
	escreveLinha( preencheString('-------------------',69,' ','D') );
	escreveLinha( preencheString('|MATR.: ',58,' ','D').preencheString(getByTagName($cabecalho,'nrmatric'),10,' ','D').'|' );
	escreveLinha( preencheString('MATRICULA DE COOPERADO       |CONTA: ',58,' ','D').preencheString(getByTagName($cabecalho,'nrdconta'),10,' ','D').'|' );
	escreveLinha( preencheString('-------------------',69,' ','D') );
	
	pulaLinha(2);
	
	escreveLinha( preencheString('PA (POSTO DE ATENDIMENTO): '.getByTagName($pJuridica,'cdagenci').' - '.getByTagName($pJuridica,'nmresage'),69) );
	
	pulaLinha(1);
	
	escreveLinha( preencheString('CONTA / DV....: '.getByTagName($pJuridica,'nrdconta'),69) );
		
	pulaLinha(1);
	
	escreveLinha( preencheString('RAZAO SOCIAL..: '.getByTagName($pJuridica,'nmprimtl'),69) );
	
	pulaLinha(1);
	
	escreveLinha( preencheString('NOME FANTASIA.: '.getByTagName($pJuridica,'nmfansia'),69) );
	
	pulaLinha(1);
	
	escreveLinha( preencheString('CNPJ..........: '.preencheString(getByTagName($pJuridica,'nrcpfcgc'),21).' INSCR.ESTAD.: '.getByTagName($pJuridica,'nrinsest'),69) );
	
	pulaLinha(1);
	
	escreveLinha( preencheString('DATA CONSTITU.: '.preencheString(getByTagName($pJuridica,'dtiniatv'),21).' NAT.JURIDICA: '.getByTagName($pJuridica,'rsnatjur'),69) );
	
	pulaLinha(1);
	
	escreveLinha( preencheString('ATIV.PRINCIPAL: '.getByTagName($pJuridica,'cdrmativ').' - '.getByTagName($pJuridica,'dsrmativ'),69) );
		
	pulaLinha(1);
	
	escreveLinha( preencheString('ENDERECO......: '.preencheString(getByTagName($pJuridica,'dsendere'),40).' NRO: '.getByTagName($pJuridica,'nrendere'),69) );
	
	pulaLinha(1);
	
	escreveLinha( preencheString('COMPLEMENTO...: '.getByTagName($pJuridica,'complend'),69) );
	
	pulaLinha(1);
	
	escreveLinha( preencheString('BAIRRO........: '.getByTagName($pJuridica,'nmbairro'),69) );
	
	pulaLinha(1);
	
	escreveLinha( preencheString('CIDADE........: '.preencheString(getByTagName($pJuridica,'nmcidade'),25).' UF: '.preencheString(getByTagName($pJuridica,'cdufende'),3).' CEP: '.getByTagName($pJuridica,'nrcepend'),69) );
	
	pulaLinha(1);
	
	escreveLinha( preencheString('TELEFONE......: ('.preencheString(getByTagName($pJuridica,'nrdddtfc'),3,'0','D').') '.getByTagName($pJuridica,'nrtelefo'),69) );
	
	pulaLinha(1);
	
	escreveLinha( preencheString('-----------REPRESENTANTES LEGAIS/MANDATARIOS OU PREPOSTOS------------',69) );
	escreveLinha( preencheString('NOME                            CPF              FUNCAO',69) );
	
	foreach( $procuradores as $procurador ){
		escreveLinha( preencheString( preencheString(getByTagName($procurador->tags,'nmdavali'),31).' '.preencheString(getByTagName($procurador->tags,'nrcpfcgc'),16).' '.getByTagName($procurador->tags,'dsproftl'),69) );
	}
	
	if ( $GLOBALS['numLinha'] > 44 ) {
		preenchePagina('**');
		
		pulaLinha(2);
		
		escreveLinha( preencheString(getByTagName($cabecalho,'nmextcop'),69) );
		escreveLinha( preencheString(getByTagName($cabecalho,'dsendcop'),69) );
		escreveLinha( preencheString(getByTagName($cabecalho,'nrdocnpj'),69) );
		
		pulaLinha(2);
		
		escreveLinha( preencheString('-------------------',69,' ','D') );
		escreveLinha( preencheString('|MATR.: ',58,' ','D').preencheString(getByTagName($cabecalho,'nrmatric'),10,' ','D').'|' );
		escreveLinha( preencheString('MATRICULA DE COOPERADO       |CONTA: ',58,' ','D').preencheString(getByTagName($cabecalho,'nrdconta'),10,' ','D').'|' );
		escreveLinha( preencheString('-------------------',69,' ','D') );
		
		pulaLinha(1);
	}
	
	pulaLinha(1);
	
	escreveLinha( preencheString('T E R M O    D E    A D M I S S A O',69,' ','C') );
	
	pulaLinha(1);
	
	escreveLinha( preencheString('O acima qualificado e abaixo assinado,  solicita  sua  admissao  como',69) );
    escreveLinha( preencheString('cooperado desta Cooperativa, subscrevendo e integralizando  as  cotas',69) );
    escreveLinha( preencheString('de capital minimas estipulados no seu Estatuto Social.',69) );
    
	pulaLinha(1);
	
    escreveLinha( preencheString('Em consequencia da sua admissao,  autoriza  o  debito  em  sua  conta',69) );
    escreveLinha( preencheString('corrente de quaisquer parcelas e/ou valores  relativos  a  obrigacoes',69) );
    escreveLinha( preencheString('que venha a assumir  com  a  Cooperativa,  inclusive  decorrentes  de',69) );
    escreveLinha( preencheString('responsabilidade subsidiaria, em face da condicao de cooperado.',69) );
    
	pulaLinha(1);
	
    escreveLinha( preencheString('Por final, declara que, de forma livre e espontanea esta integrando o',69) );
    escreveLinha( preencheString('quadro social da Cooperativa, vinculando-se as disposicoes legais que',69) );
    escreveLinha( preencheString('regulam o cooperativismo, ao Sistema AILOS, ao  Estatuto  Social  da',69) );
    escreveLinha( preencheString('Cooperativa, ao seu Regimento Interno, as  deliberacoes  assembleares',69) );
    escreveLinha( preencheString('desta e as do seu Conselho de Administracao,  reconhecendo  desde  ja',69) );
    escreveLinha( preencheString('que qualquer celebracao  de  contrato,  seja  ativo,  passivo  ou  de',69) );
    escreveLinha( preencheString('prestacao de servicos, tera caracteristica de ATO COOPERATIVO.',69) );
	
	pulaLinha(4);
	
	escreveLinha( preencheString('A D M I S S A O',69) );

	pulaLinha(1);
     
	echo '<b>';escreveLinha( preencheString('  '.getByTagName($cabecalho,'dtadmiss'),15) );echo '</b>';
	escreveLinha( preencheString('_______________   __________________________   ______________________',69) );
	escreveLinha( preencheString('     DATA          ASSINATURA DO COOPERADO     ASSINATURA DO DIRETOR',69) );

	pulaLinha(4);

    escreveLinha( preencheString('D E M I S S A O',69) );
	
	pulaLinha(1);
     
	echo '<b>';escreveLinha( preencheString('  '.getByTagName($cabecalho,'dtdemiss'),15) );echo '</b>';
    escreveLinha( preencheString('_______________   __________________________   ______________________',69) );
	escreveLinha( preencheString('     DATA          ASSINATURA DO COOPERADO     ASSINATURA DO DIRETOR',69) );
	
	if (  count($parcelamento) > 0 ) {
	echo "<p>&nbsp;</p>"; $GLOBALS['numPagina']++; $GLOBALS['numLinha'] = 0;
	
	pulaLinha(2);
		
	escreveLinha( preencheString(getByTagName($cabecalho,'nmextcop'),69) );
	escreveLinha( preencheString(getByTagName($cabecalho,'dsendcop'),69) );
	escreveLinha( preencheString(getByTagName($cabecalho,'nrdocnpj'),69) );
	
	pulaLinha(4);
	
	escreveLinha( preencheString('AUTORIZACAO DE DEBITO EM CONTA-CORRENTE PARA AUMENTO DE CAPITAL)',63) );
	escreveLinha( preencheString('',63,'=') );
	escreveLinha( preencheString('             (PARCELAMENTO DA SUBSCRICAO INICIAL)',66) );
	
	pulaLinha(3);
	
	escreveLinha( preencheString( preencheString(' Conta/dv: '.getByTagName($parcelamento,'nrdconta'),25).' Matricula: '.getByTagName($parcelamento,'nrmatric'),90)  );
	
	pulaLinha(1);
	
	escreveLinha( preencheString('Associado: '.getByTagName($parcelamento,'nmprimtl'),66) );
	
	pulaLinha(4);
	
	escreveLinha( preencheString('O associado acima qualificado, autoriza um debito mensal em conta-', 66 ) );
	escreveLinha( preencheString('corrente de depositos a vista, em '.getByTagName($parcelamento,'dsdprazo').' parcela(s), na importancia de', 66 ) );
	escreveLinha( preencheString('R$ '.preencheString( getByTagName($parcelamento,'vlparcel') , 10 ).getByTagName($parcelamento[5]->tags,'dsparcel.1'), 66 ) );
	escreveLinha( preencheString(getByTagName($parcelamento[5]->tags,'dsparcel.2'), 66 ) );
	escreveLinha( preencheString('a partir de '.getByTagName($parcelamento,'dtdebito').' , para credito de suas cotas de CAPITAL.', 66 ) );
	
	pulaLinha(4);
	
	escreveLinha( preencheString('O debito sera efetuado  somente mediante  suficiente  provisao  de',66 ) );
	escreveLinha( preencheString('fundos. Quando a data do debito nao coincidir com dia util, o lan-',66 ) );
	escreveLinha( preencheString('camento sera efetuado no primeiro dia util subsequente.',66 ) );
		
	pulaLinha(9);
	
	escreveLinha( preencheString( preencheString( getByTagName($cabecalho,'nmcidade') , 19 ).' '.getByTagName($cabecalho,'dtmvtolt'), 66 ) );
	
	pulaLinha(5);
	
	escreveLinha( preencheString('_________________________________  _______________________________',66 ) );
	escreveLinha( preencheString( preencheString( getByTagName($parcelamento,'nmprimtl') , 33 ).'  '.preencheString( getByTagName($cabecalho[9]->tags,'nmrescop.1') , 31,' ','C' ), 66 ) );
	escreveLinha( preencheString( preencheString( ' ' , 33 ).'  '.preencheString( getByTagName($cabecalho[9]->tags,'nmrescop.2') , 31,' ','C' ), 66 ) );
	}
	echo '</pre>';
	
	echo '</pre>';
?>