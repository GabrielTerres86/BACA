<?php
/* 
 * Classe Responsavel da requisicao REST da proposta
 * 
 * @autor: Lucas Reinert
 *
 * Alteração: 22/06/2018 - Inclusão de novos campos. Odirlei-AMcom
 */
require_once('../class/class_rest_server_json.php');

class RestCDC extends RestServerJson{
    
    private $aParamsRequiredI;
    private $aParamsRequiredA;
    private $aParamsRequiredE;
    
    public function __construct(){
		// Parâmetros obrigatórios Inclusão
        $this->aParamsRequiredI = array('cooperativaAssociadoCodigo',
									    'contaAssociadoNumero',
									    'contaAssociadoDV',
									    'PACodigo',
									    'tipoPessoa',
									    'tipoEmprestimo',
									    'valorTotalEmprestimo',
									    'valorLiquidoEmprestimo',
									    'IOFValor',
									    'CETValor',
									    'prestacaoQuantidade',
									    'prestacaoValor',
									    'linhaCreditoCodigo',
									    'finalidadeCodigo',
									    'observacaoDescricao',
									    'dataMovimento',
									    'imprimirContrato',
									    'dataPrimeiraPrestacao',
										'cooperativaLojistaCodigo',
                                        'contaLojistaNumero',
                                        'contaLojistaDV',
                                        'vendedor');        
		// Parâmetros obrigatórios Alteração								
		$this->aParamsRequiredA = array('contratoNumero',
										'cooperativaAssociadoCodigo',
									    'contaAssociadoNumero',
									    'contaAssociadoDV',
									    'PACodigo',
									    'tipoPessoa',
									    'tipoEmprestimo',
									    'valorTotalEmprestimo',
									    'valorLiquidoEmprestimo',
									    'IOFValor',
									    'CETValor',
									    'prestacaoQuantidade',
									    'prestacaoValor',
									    'linhaCreditoCodigo',
									    'finalidadeCodigo',
									    'observacaoDescricao',
									    'dataMovimento',
									    'imprimirContrato',
									    'dataPrimeiraPrestacao',
										'cooperativaLojistaCodigo',
                                        'reiniciaFluxo',
									    'contaLojistaNumero',
                                        'contaLojistaDV');
		// Parâmetros obrigatórios Cancelamento
		$this->aParamsRequiredE = array('cooperativaAssociadoCodigo',
										'agenciaAssociadoCodigo',
									    'contaAssociadoNumero',
									    'contaAssociadoDV',
										'dataMovimento',
										'contratoNumero');
										
    }
    
    public function __destruct(){
        unset($this->aParamsRequiredI);
        unset($this->aParamsRequiredA);
        unset($this->aParamsRequiredE);
    }
	
    /**
     * Método responsavel por enviar a mensagem de resposta a requisicao
     * @param String $status
     * @param String $mensagemDetalhe
     * @param String $numeroTransacao
     * @param String $contas
     * @param String $cdcritic
     * @param String $dscritic
     * @return boolean
     */
    private function processaRetorno($status, 
									 $mensagemDetalhe, 
									 $numeroTransacao = '00000000000000000000', 
									 $dsjsonan = '',
									 $nrctrprp = '0',
									 $cdcritic = '0', 
									 $dscritic = ''){		
        $aRetorno = array();
        $aRetorno['status']      = $status;
        $aRetorno['nrtransacao'] = $numeroTransacao;
		if (is_array($dsjsonan)){
			// Percorrer cada item retornado do json
			foreach($dsjsonan as $key => $val){
				$aRetorno[$key] = $val;
			}
		}
        $aRetorno['cdcritic']    = $cdcritic;
        $aRetorno['dscritic']    = $dscritic;
        $aRetorno['msg_detalhe'] = $mensagemDetalhe;
		
		// Atualizar acionamento do serviço
		$xml  = "<Root>";
		$xml .= " <Dados>";
		$xml .= "	<cdstatus_http>".$status."</cdstatus_http>";
		$xml .= "	<flgreenvia>0</flgreenvia>";
		$xml .= "	<idacionamento>".$numeroTransacao."</idacionamento>";
		$xml .= "	<dsresposta_requisicao>".json_encode($aRetorno)."</dsresposta_requisicao>";
		$xml .= "	<nrctrprp>".$nrctrprp."</nrctrprp>";
		$xml .= " </Dados>";
		$xml .= "</Root>";
		$sXmlResult = mensageria($xml, "WEBS0003", "ATUALIZA_ACIONAMENTO", 0, 0, 0, 5, 0, "</Root>");		
		
        // Setando o codigo do status no Header da resposta
        header("Cache-Control: no-cache, must-revalidate");
		header("Expires: 0");
		header('Content-Type: ' . RestFormat::$aRestFormat[$this->getTypeFormato()]);
        header('Status-Code: '.$status, true, $status);
		
        // Enviando a resposta para o servico
        return $this->processaRetornoFormato($aRetorno);
    }
    
    /**
     * Método responsavel por enviar a mensagem de Exception
     * @param String Status
     * @param String Mensagem de detalhe
     * @return boolean
     */
    private function processaRetornoErro($status, $mensagemDetalhe, $cdcritic='0', $dscritic = '', $idacionamento = ''){		
        // Grava o erro no arquivo TEXTO
        $xml  = "<Root>";
        $xml .= " <Dados>";
        $xml .= "   <dsmessag>".$mensagemDetalhe."</dsmessag>";
        $xml .= "   <dsrequis>".$this->getFileContents()."</dsrequis>";
        $xml .= "   <nmarqlog>integracaocdc</nmarqlog>";
        $xml .= " </Dados>";
        $xml .= "</Root>";
        mensageria($xml, "WEBS0003", "GRAVA_REQUISICAO_ERRO", 0, 0, 0, 5, 0, "</Root>");
        // Retorna a mensagem de critica
        return $this->processaRetorno((string) $status,(string) $mensagemDetalhe,(string) $idacionamento, '', '0', (string) $cdcritic,(string) $dscritic);
    }
    
    /**
     * Método responsavel por enviar de sucesso
     * @param String $status
     * @param String $mensagemDetalhe
     * @param String $numeroTransacao
     * @param json $dsjsonan
     * @param String $cdcritic
     * @param String $dscritic
     * @return boolean
     */
    private function processaRetornoSucesso($status,$mensagemDetalhe,$numeroTransacao,$dsjsonan,$cdcritic,$dscritic){
        return $this->processaRetorno((string) $status,(string) $mensagemDetalhe,(string) $numeroTransacao, $dsjsonan,(string) $cdcritic,(string) $dscritic);
    }

    /**
     * Valida se todos os parametros recebidos estão corretos
     * @param Object $oDados
     * @return boolean
     */
    private function validaParametrosRecebidos($oDados){
        // Condicao para verificar se eh um objeto
        if (!is_object($oDados)){
            $this->processaRetornoErro(400,'Parametro invalido.');
            return false;
        }
		
		switch (strtoupper($_SERVER['REQUEST_METHOD'])) {
			case 'POST': // Inclusão
				$params = $this->aParamsRequiredI;
				break;
			case 'PUT': // Alteração
				$params = $this->aParamsRequiredA;
				break;
			case 'DELETE': // Cancelamento
				$params = $this->aParamsRequiredE;
				break;
		}
		
        // Verifica se todos os parametros foram recebidos
        foreach ($params as $sPametro){
			if (!array_key_exists($sPametro,get_object_vars($oDados))){
                $this->processaRetornoErro(400,'Parametro invalido.');
                return false;
            }
        }
		
        return true;
    }
    
    /**
     * Processa os dados da Requisicao
     */
    public function processaRequisicao(){
        try{
            $this->setMetodoRequisitado(strtoupper($_SERVER['REQUEST_METHOD']));
            
            // Valida os dados da requisicao
            if (!$this->validaRequisicao()){
                return false;
            }

            // Busca os dados da requisicao
            $oDados = $this->getDados();
			
            // Valida se veio todos os parametros obrigatorios
            if (!$this->validaParametrosRecebidos($oDados)){
                return false;            
            }
			
			// Monta retorno da proposta a partir do motor de crédito
			$xml  = "<Root>";
			$xml .= " <Dados>";
			$xml .= "	<cdcooper>".$oDados->cooperativaAssociadoCodigo."</cdcooper>";
			$xml .= "   <dsusuari>".$this->getUsuario()."</dsusuari>";
			$xml .= "   <dsdsenha>".$this->getSenha()."</dsdsenha>";
			$xml .= "   <cdcliente>1</cdcliente>";
			$xml .= " </Dados>";
			$xml .= "</Root>";
			$sXmlResult = mensageria($xml, "EMPR0012", "VALIDA_INTEGRACAO", 0, 0, 0, 5, 0, "</Root>");
			$oRetorno  = simplexml_load_string($sXmlResult);
			
			// Vamos verificar se veio retorno de erro
			if (isset($oRetorno->Erro->Registro->dscritic)){
				$cdcritic = $oRetorno->Erro->Registro->cdcritic;
				$dscritic = $oRetorno->Erro->Registro->dscritic;
				if (strpos($dscritic, 'Erro geral') !== false){
					$this->processaRetornoErro(500,'Ocorreu um erro interno no sistema.',$cdcritic,$dscritic,$idacionamento);
				}else{
					$this->processaRetornoErro(400,'Erro de validacao do negocio',$cdcritic,$dscritic,$idacionamento);
				}
				return false;
			}
			
			switch (strtoupper($_SERVER['REQUEST_METHOD'])) {
				case 'POST': // Inclusão
					$nrctremp = 0;
					$cdagenci = $oDados->PACodigo;
					$cddopcao = 'I';
					$msgsucesso = 'Proposta criada com sucesso';
					$msgerro 	= 'Proposta nao foi criada';
					$dsoperacao = 'INTEGRACAO CDC - INCLUSAO PROPOSTA';
					$reiniciaFluxo = 1;
					$conjugeCorresponsavel = (isset($oDados->conjugeCorresponsavel))? $oDados->conjugeCorresponsavel : FALSE;
					break;
				case 'PUT': // Alteração
					$nrctremp = str_replace('.', '', trim($oDados->contratoNumero));
					$cdagenci = $oDados->PACodigo;
					$cddopcao = 'A';
					$msgsucesso = 'Proposta alterada com sucesso';
					$msgerro 	= 'Proposta nao foi alterada';
					$dsoperacao = 'INTEGRACAO CDC - ALTERACAO PROPOSTA';
					$reiniciaFluxo = $oDados->reiniciaFluxo;
					$conjugeCorresponsavel = (isset($oDados->conjugeCorresponsavel))? $oDados->conjugeCorresponsavel : FALSE;
					break;
				case 'DELETE': // Cancelamento
					$nrctremp = str_replace('.', '', trim($oDados->contratoNumero));
					$cdagenci = $oDados->agenciaAssociadoCodigo;
					$cddopcao = 'E';
					$msgsucesso = 'Proposta cancelada com sucesso';
					$dsoperacao = 'INTEGRACAO CDC - CANCELAMENTO PROPOSTA';
					break;
			}
			
            // Gravar acionamento do serviço
            $xml  = "<Root>";
            $xml .= " <Dados>";
			$xml .= "	<cdcooper>".$oDados->cooperativaAssociadoCodigo."</cdcooper>";
			$xml .= "	<cdagenci>".$cdagenci."</cdagenci>";
			$xml .= "	<cdoperad>AUTOCDC</cdoperad>";
			$xml .= "	<cdorigem>5</cdorigem>";			
			$xml .= "	<nrctrprp>".$nrctremp."</nrctrprp>";
			$xml .= "	<nrdconta>".$oDados->contaAssociadoNumero.$oDados->contaAssociadoDV."</nrdconta>";
			$xml .= "	<cdcliente>1</cdcliente>";
			$xml .= "	<tpacionamento>1</tpacionamento>";
			$xml .= "	<dsoperacao>".$dsoperacao."</dsoperacao>";
			$xml .= "	<dsuriservico><![CDATA[".$this->getURI()."]]></dsuriservico>";
			$xml .= "	<dsmetodo>".$this->getMetodoRequisitado()."</dsmetodo>";
			$xml .= "	<dtmvtolt>".$oDados->dataMovimento."</dtmvtolt>";			
			$xml .= "	<cdstatus_http></cdstatus_http>";
			$xml .= "	<dsconteudo_requisicao>".$this->getFileContents()."</dsconteudo_requisicao>";
			$xml .= "	<dsresposta_requisicao></dsresposta_requisicao>";
			$xml .= "	<dsprotocolo></dsprotocolo>";
			$xml .= "	<flgreenvia>0</flgreenvia>";
			$xml .= "	<nrreenvio>0</nrreenvio>";
			$xml .= "	<tpconteudo>1</tpconteudo>";
			$xml .= "	<tpproduto>0</tpproduto>";
            $xml .= " </Dados>";
            $xml .= "</Root>";
            $sXmlResult = mensageria($xml, "WEBS0003", "GRAVA_ACIONAMENTO", 0, 0, 0, 5, 0, "</Root>");
            $oRetorno  = simplexml_load_string($sXmlResult);
			
            // Vamos verificar se veio retorno de erro
            if (isset($oRetorno->Erro->Registro->dscritic)){
				$cdcritic = $oRetorno->Erro->Registro->cdcritic;
				$dscritic = $oRetorno->Erro->Registro->dscritic;
				if (strpos($dscritic, 'Erro geral') !== false){
					$this->processaRetornoErro(500,'Ocorreu um erro interno no sistema.',$cdcritic,$dscritic);
				}else{
					$this->processaRetornoErro(400,$dscritic);
				}
                return false;
            }
			// Capturar o identificador de acionamento
			$idacionamento = $oRetorno->idacionamento;

			if ($cddopcao == 'E'){
				// Chamar rotina de cancelamento da proposta
				$xml  = '';
				$xml .= '<Root>';
				$xml .= '	<Cabecalho>';
				$xml .= '		<Bo>b1wgen0002.p</Bo>';
				$xml .= '		<Proc>excluir-proposta</Proc>';
				$xml .= '	</Cabecalho>';
				$xml .= '	<Dados>';
				$xml .= '		<cdcooper>'.$oDados->cooperativaAssociadoCodigo.'</cdcooper>';
				$xml .= '		<cdagenci>'.$cdagenci.'</cdagenci>';
				$xml .= '		<nrdcaixa>1</nrdcaixa>';
				$xml .= '		<cdoperad>AUTOCDC</cdoperad>';
				$xml .= '		<nmdatela>AUTOCDC</nmdatela>';
				$xml .= '		<idorigem>5</idorigem>';
				$xml .= '		<dtmvtolt>'.$oDados->dataMovimento.'</dtmvtolt>';
				$xml .= '		<nrdconta>'.$oDados->contaAssociadoNumero.$oDados->contaAssociadoDV.'</nrdconta>';
				$xml .= '		<nrctremp>'.$nrctremp.'</nrctremp>';
				$xml .= '		<idseqttl>1</idseqttl>';
				$xml .= '	</Dados>';
				$xml .= '</Root>';

				$xmlResult = getDataXML($xml);
				$xmlObjeto = getObjectXML($xmlResult);

				// Vamos verificar se veio retorno de erro
				if (sizeof($xmlObjeto->roottag->tags) > 0){
					if (strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO') {
                        $cdcritic = $xmlObjeto->roottag->tags[0]->tags[0]->tags[3]->cdata;
						$dscritic = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
						if (strpos($dscritic, 'Nao foi possivel concluir') !== false){
							$this->processaRetornoErro(500,'Ocorreu um erro interno no sistema.',$cdcritic,$dscritic,$idacionamento);
						}else{
							$this->processaRetornoErro(202,'Erro de negocio',$cdcritic,$dscritic,$idacionamento);
						}
						return false;
					}
				}
				// Apenas enviar o json de retorno vazio
				$dsjsonan = '';
				
				/*---------------------------------------------------------------*/
				// Notificao de push de cancelamento
                $xml  = "<Root>";
                $xml .= " <Dados>";
			    $xml .= "	<cdcooper>".$oDados->cooperativaAssociadoCodigo."</cdcooper>";
			    $xml .= "	<nrdconta>".$oDados->contaAssociadoNumero.$oDados->contaAssociadoDV."</nrdconta>";
			    $xml .= "	<nrctremp>".$nrctremp."</nrctremp>";
			    $xml .= "	<insitpro>8</insitpro>";
                $xml .= " </Dados>";
                $xml .= "</Root>";
                $pXmlResult = mensageria($xml, "EMPR0012", "REGISTRA_PUSH_PRP_CDC", 0, 0, 0, 5, 0, "</Root>");
                $poRetorno  = simplexml_load_string($pXmlResult);
				/*---------------------------------------------------------------*/

			}else{
			
				$jbens = json_encode($oDados->bensAlienacao);
				$abens = json_decode($jbens, true);
				$sbens = '';
				for ($i = 0; $i < sizeof($abens); $i++) {
					$sbens = $sbens . '|' . implode("; " , $abens[$i]);
				}

				// Processa a informacao do banco de dados
				$xml  = "";
				$xml .= "<Root>";
				$xml .= "	<Cabecalho>";
				$xml .= "		<Bo>b1wgen0201.p</Bo>";
				$xml .= "		<Proc>integra_proposta</Proc>";
				$xml .= "	</Cabecalho>";
				$xml .= "	<Dados>";
				$xml .= "		<cdcooper>".$oDados->cooperativaAssociadoCodigo."</cdcooper>";
				$xml .= "		<cdagenci>".$cdagenci."</cdagenci>";
				$xml .= "		<nrdcaixa>1</nrdcaixa>";
				$xml .= "		<cdoperad>AUTOCDC</cdoperad>";
				$xml .= "		<nmdatela>AUTOCDC</nmdatela>";
				$xml .= "		<idorigem>5</idorigem>";
				$xml .= "		<nrdconta>".$oDados->contaAssociadoNumero.$oDados->contaAssociadoDV."</nrdconta>";
				$xml .= "		<idseqttl>1</idseqttl>";
				$xml .= "		<inpessoa>".$oDados->tipoPessoa."</inpessoa>";
				$xml .= "		<tpemprst>".$oDados->tipoEmprestimo."</tpemprst>";
				$xml .= "		<vlemprst>".formataMoeda($oDados->valorLiquidoEmprestimo)."</vlemprst>";
				$xml .= "		<vlliqemp>".formataMoeda($oDados->valorLiquidoEmprestimo)."</vlliqemp>";
				$xml .= "		<vliofepr>".formataMoeda($oDados->IOFValor)."</vliofepr>";
				$xml .= "		<percetop>".formataMoeda($oDados->CETValor)."</percetop>";
				$xml .= "		<qtpreemp>".$oDados->prestacaoQuantidade."</qtpreemp>";
				$xml .= "		<vlpreemp>".formataMoeda($oDados->prestacaoValor)."</vlpreemp>";
				$xml .= "		<cdlcremp>".$oDados->linhaCreditoCodigo."</cdlcremp>";
				$xml .= "		<cdfinemp>".$oDados->finalidadeCodigo."</cdfinemp>";
				$xml .= "		<dsobserv>".$oDados->observacaoDescricao."</dsobserv>";
				$xml .= "		<dtmvtolt>".$oDados->dataMovimento."</dtmvtolt>";
				$xml .= "		<flgimppr>".$oDados->imprimirContrato."</flgimppr>";
				$xml .= "		<dtdpagto>".$oDados->dataPrimeiraPrestacao."</dtdpagto>";
				$xml .= "		<dsdalien>".$sbens."</dsdalien>";
				$xml .= "		<cddopcao>".$cddopcao."</cddopcao>";
				$xml .= "		<nrctremp>".$nrctremp."</nrctremp>";
                $xml .= "		<inresapr>".$reiniciaFluxo."</inresapr>";                
                $xml .= "		<cdcoploj>".$oDados->cooperativaLojistaCodigo."</cdcoploj>";
                $xml .= "		<nrctaloj>".$oDados->contaLojistaNumero.$oDados->contaLojistaDV."</nrctaloj>";
                $xml .= "		<dsvended>".$oDados->vendedor."</dsvended>";
				$xml .= "		<flgdocje>".$conjugeCorresponsavel."</flgdocje>";
				$xml .= "	</Dados>";
				$xml .= "</Root>";
				
				$xmlResult = getDataXML($xml);
				$xmlObjeto = getObjectXML($xmlResult);

				// Vamos verificar se veio retorno de erro
				if (strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO") {
					$cdcritic = $xmlObjeto->roottag->tags[0]->tags[0]->tags[3]->cdata;
					$dscritic = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
					if (strpos($dscritic, 'Erro geral') !== false){
						$this->processaRetornoErro(500,'Ocorreu um erro interno no sistema.',$cdcritic,$dscritic,$idacionamento);
					}else{
						$this->processaRetornoErro(202,'Erro na validacao do negocio',$cdcritic,$dscritic,$idacionamento);
					}
					return false;
				}
				
				// Capturar numero do contrato
				$nrctremp = $xmlObjeto->roottag->tags[0]->attributes['NRCTREMP'];
                
                // Buscar retorno do JSON
                $dsjsonan_xml  = $xmlObjeto->roottag->tags[0]->attributes['DSJSONAN'];
                
                // Repassar retorno do motor para variável
				$dsjsonan = json_decode($dsjsonan_xml, TRUE);
                
			}
            
            //Retorna a resposta para o servico
            $this->processaRetornoSucesso(200,
                                          $msgsucesso,
                                          $idacionamento,
										  $dsjsonan,
										  $nrctremp,
                                          0,
                                          '');

        } catch(RestException $oException){
            $this->processaRetornoErro($oException->getCode(), $oException->getMessage(), 0, '');
            return false;            
        } catch (Exception $oException){
            $this->processaRetornoErro(500,'Ocorreu um erro interno no sistema.','0', 'Erro geral do sistema.');
            return false;
        }
        return true;
    }
}
?>