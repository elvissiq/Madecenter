#INCLUDE "RWMAKE.CH" 

User Function SCRPED()   

	Local aArea 			:= FWGetArea()
	Local aAreaSL1 			:= SL1->(FWGetArea())
	Local aAreaSL2 			:= SL2->(FWGetArea())
	Local nY                := 0

	Private nOrcam			:= 0
	Private sTexto      	:= ""              
	Private nCheques		:= 0
	Private nCartaoC		:= 0
	Private nCartaoD		:= 0
	Private nConveni		:= 0
	Private nVales			:= 0
	Private nFinanc			:= 0
	Private nCredito		:= 0
	Private nOutros			:= 0
	Private cQuant 			:= ""	
	Private cVrUnit			:= "" 								// Valor unitário
	Private cDesconto		:= ""
	Private cVlrItem		:= ""
	Private nVlrIcmsRet		:= 0								// Valor do icms retido (Substituicao tributaria)
	Private nTroco			:= 0
	Private lMvLjTroco  	:= SuperGetMV("MV_LJTROCO", ,.F. )	// Verifica se utiliza troco nas diferentes formas de pagamento
	Private aProdGarantia 	:={}								// Array com os parâmetros do rkmake de impressão do relatório de Garantia
	Private lMvGarFP		:= SuperGetMV("MV_LJGarFP", ,.F.)	// Define o conc
	Private lLibQtdGE		:= SuperGetMv("MV_LJLIBGE", , .F.) 	// Libera quantidade da garantia estendida  .. por default é Falso
	Private cServType		:= SuperGetMv("MV_LJTPSF",,"SF")	// Define o tipo do produto de servico financeiro
	Private nValTot			:= 0
	Private nDescTot		:= 0
	Private nFatorRes		:= 1
	Private nValPag			:= 0
	Private nVlrDescIt		:= 0
	Private cGarType		:= SuperGetMv("MV_LJTPGAR",,"GE")	// Define o tipo do produto de garantia estendida
	Private nVlrFSD			:= 0								// Valor do frete + seguro + despesas
	Private cDocPed       	:= ""								// Documento do Pedido
	Private cSerPed       	:= ""								// Serie do pedido
	Private nVlrTot       	:= 0                                // Valor Total
	Private nVlrAcres     	:= 0                                // Valor Acrescimo
	Private lMvArrefat    	:= SuperGetMv("MV_ARREFAT") == "S"
	Private nMvLjTpDes    	:= SuperGetMv("MV_LJTPDES",, 0) 	// Indica qual desconto sera' utilizado 0 - Antigo / 1 - Novo (objeto)
	Private nTotDesc		:= 0 								// Total de desconto de acordo com L2_DESCPRO
	Private lPedido			:= .F.								// Indica se a venda tem itens com pedido
	Private nMaxChar 		:= 47 // MÁXIMO DE CARACTERES POR LINHA
	Private aFieldSM0 		:= { ;
								"M0_NOMECOM",;   //Posição [1]
								"M0_ENDENT",;    //Posição [2]
								"M0_BAIRENT",;   //Posição [3]
								"M0_CIDENT",;    //Posição [4]
								"M0_ESTENT",;    //Posição [5]
								"M0_CEPENT",;    //Posição [6]
								"M0_CGC",;       //Posição [7]
								"M0_INSC",;      //Posição [8]
								"M0_COMPENT",;   //Posição [9]
								"M0_TEL";		 //Posição [10]
								}        
	Private aSM0Data 		:= FWSM0Util():GetSM0Data(, SL1->L1_FILIAL, aFieldSM0)
	Private cNomCom       	:= aSM0Data[1,2] // Nome Comercial da Empresa
	Private cEndEnt       	:= aSM0Data[2,2] // Endereço de Entrega
	Private cBaiEnt       	:= aSM0Data[3,2] // Bairro de Entrega
	Private cCidEnt       	:= aSM0Data[4,2] // Cidade de Entrega
	Private cEstEnt       	:= aSM0Data[5,2] // Estado de Entrega
	Private cCepEnt       	:= aSM0Data[6,2] // Cep de Entrega
	Private cCgcEnt       	:= aSM0Data[7,2] // CNPJ 
	Private cInsEnt       	:= aSM0Data[8,2] // Inscrição Estadual
	Private cNomCli       	:= Posicione("SA1",1,xFILIAL("SA1")+SL1->L1_CLIENTE+SL1->L1_LOJA,"A1_NREDUZ") //Nome do Cliente
	Private cNomVen       	:= Posicione("SA3",1,xFilial("SA3")+SL1->L1_VEND,"A3_NOME")  // Nome do Vendedor
	Private cNomOpe       	:= Posicione("SA6",1,xFilial("SA6")+SL1->L1_OPERADO,"A6_NOME")  // Nome do Operador
	Private cTxImp        	:= ""
	Private aPrdMaFe     	:= {}

	If ValType(PARAMIXB) == "A" .AND. Len(PARAMIXB) > 0  
		If ValType(PARAMIXB[1]) == "A" .AND. Len(PARAMIXB[1]) > 0
			ProdGarantia := PARAMIXB[1]
		EndIf
		If (Len(PARAMIXB) > 1) .And. ValType(PARAMIXB[2]) == "N" .AND. (PARAMIXB[2] > 0)
			nFatorRes	:=	PARAMIXB[2]
		EndIf
		If (Len(PARAMIXB) > 2) .And. ValType(PARAMIXB[3]) == "N" .AND. (PARAMIXB[2] > 0)
			nCredito	:=	PARAMIXB[3]
		EndIf
		If ValType(PARAMIXB) == "A" .AND. Len(PARAMIXB) >= 4 .AND. ValType(PARAMIXB[4]) == "A"
			cSerPed := PARAMIXB[4,1,1]
			cDocPed := PARAMIXB[4,1,2]
		Else
			Return sTexto 
		EndIf
	EndIf

	fCompPag()

	fPrdMadFerr()

	For nY := 1 To Len(aPrdMaFe)
		If !Empty(aPrdMaFe[nY])
			fCompRet(nY)
		EndIF
	Next 

	FWRestArea(aAreaSL1)
	FWRestArea(aAreaSL2)  
	FWRestArea(aArea)

Return sTexto

//-------------------------------------------------------------------
/*/{Protheus.doc} fCompPag
Funcao para impressao do comprovante de pagamento
@type function
@param 

@author Varejo
@version P12
@return cTexto, retorna texto do comprovante do caixa e do cliente

/*/
//-------------------------------------------------------------------
Static Function fCompPag() 
	
	sTexto:= '<ce>'+ alltrim(cNomCom) +'</ce>'+ Chr(13)+ Chr(10)
	sTexto:= sTexto +'<ce>'+ alltrim(cEndEnt) + ' - '+ alltrim(cBaiEnt) +'</ce>'+ Chr(13)+ Chr(10)
	sTexto:= sTexto +'<ce>'+ alltrim(cCidEnt) + ' - '+ alltrim(cEstEnt) + ' CEP:'+ alltrim(cCepEnt) +'</ce>'+ Chr(13)+ Chr(10)
	sTexto:= sTexto +'<ce> CNPJ: '+ alltrim(cCgcEnt) + ' IE: '+ alltrim(cInsEnt) +'</ce>'+ Chr(13)+ Chr(10)

	sTexto:= sTexto + Replicate("-", nMaxChar)						   + Chr(13)+ Chr(10)
	sTexto:= sTexto + '<b><ce>COMPROVANTE DE PAGAMENTO</ce></b>' 	   + Chr(13)+ Chr(10)
	sTexto:= sTexto + Replicate("-", nMaxChar)						   + Chr(13)+ Chr(10)
	dbSelectArea("SL1")                                                                  
	dbSetOrder(1)  
	nOrcam		:= SL1->L1_NUM
	nTroco		:= Iif(SL1->(FieldPos("L1_TROCO1")) > 0,(nFatorRes * SL1->L1_TROCO1), 0)
	nDinheir	:= (nFatorRes * SL1->L1_DINHEIR)
	nCheques	:= (nFatorRes * SL1->L1_CHEQUES)
	nCartaoC 	:= (nFatorRes * SL1->L1_CARTAO)
	nCartaoD 	:= (nFatorRes * SL1->L1_VLRDEBI)
	nConveni	:= (nFatorRes * SL1->L1_CONVENI)
	nVales  	:= (nFatorRes * SL1->L1_VALES)  	
	nCredito	:= (nFatorRes * SL1->L1_CREDITO)  	
	nFinanc		:= (nFatorRes * SL1->L1_FINANC)
	nOutros		:= (nFatorRes * SL1->L1_OUTROS)
	nValTot		:= 0
	nDescTot	:= 0

	/* Soma o valor de todas as formas de pagamento
	Necessariio dar um round em cada forma para verificar se ha diferença de arredondamento no somatorio dos pagamentos*/
	nValPag :=	Round(nDinheir,2)	+	Round(nCheques,2)	+	Round(nCartaoC,2)	+	Round(nCartaoD,2)	+;
				Round(nConveni,2)	+	Round(nVales,2)	+	Round(nCredito,2)	+	Round(nFinanc,2)	+;
				Round(nOutros,2)

	dbSelectArea("SL2")
	dbSetOrder(1)  
	dbSeek(xFilial("SL2") + nOrcam)
		
	While !SL2->(Eof()) .AND. SL2->L2_FILIAL + SL2->L2_NUM == xFilial("SL2") + nOrcam
		/* Entrega ou Retira Posterior ou Vale Presente*/	
		If SL2->L2_ENTREGA $("1|3|4|5") .OR. !Empty(SL2->L2_VALEPRE) ;
			.OR. (Posicione("SB1",1,xFilial("SB1") + SL2->L2_PRODUTO,"SB1->B1_TIPO") == cServType) ;
			.OR. (Posicione("SB1",1,xFilial("SB1") + SL2->L2_PRODUTO,"SB1->B1_TIPO") == cGarType)
			
			If SL2->L2_ENTREGA $("3|5")
				lPedido := .T.
			EndIf
			
			If aScan(aProdGarantia, { |p| RTrim(p[1]) ==  RTRim(SL2->L2_PRODUTO)} ) > 0
				cGarantia := "*"
			Else
				If SL2->(FieldPos("L2_GARANT")) > 0 .AND.  !Empty(SL2->L2_GARANT)
					cGarantia := "#"
				Else
					cGarantia := ""
				EndIf
			EndIf
		
			If !Empty(SL2->L2_ENTREGA)
				If !Empty(cGarantia)
					cGarantia += IIF(SL2->L2_ENTREGA == "3", " E", IIF(SL2->L2_ENTREGA == "1", " P", ""))
				Else
					cGarantia := IIF(SL2->L2_ENTREGA == "3", "E", IIF(SL2->L2_ENTREGA == "1", "P", ""))
				EndIf
		
			EndIf

			//Faz o tratamento do valor do ICMS ret.
			If SL2->(FieldPos("L2_ICMSRET")) > 0
				nVlrIcmsRet	:= SL2->L2_ICMSRET
			Endif

			If (!lMvGarFP .AND. !lLibQtdGE ) .AND. (cGarantia == "*" .OR. (Posicione("SB1",1,xFilial("SB1")+SL2->L2_PRODUTO, "B1_TIPO") == SuperGetMV("MV_LJTPGAR",,"GE")))
				cVrUnit	:= Str(((SL2->L2_QUANT * SL2->L2_VLRITEM) + SL2->L2_VALIPI + nVlrIcmsRet) / SL2->L2_QUANT, 15, 2)
			Else
				cVrUnit	:= Str(((SL2->L2_QUANT * SL2->L2_PRCTAB) + SL2->L2_VALIPI + nVlrIcmsRet) / SL2->L2_QUANT, 15, 2)
			EndIf

			//Valor de desconto no item
			nVlrDescIt += SL2->L2_VALDESC
			nTotDesc   += SL2->L2_DESCPRO
			cVlrItem   := Str(Val(cVrUnit) * SL2->L2_QUANT, 15, 2)
			
			nValTot  += Val(cVlrItem)
	
			SL2->(DbSkip())
		Else
			SL2->(DbSkip())
		EndIf
	EndDo                    

	cDesconto	:= Str(nVlrDescIt, TamSx3("L2_VALDESC")[1], TamSx3("L2_VALDESC")[2])
	nVlrFSD		:= SL1->L1_FRETE + SL1->L1_SEGURO + SL1->L1_DESPESA

	If SL1->L1_DESCONTO > 0
		//O valor de desconto deve ser encontrada atraves da soma de todos os produtos (seus valores originais) (sem frete / sem desconto / sem acrescimo)
		//Porem quando é selecionado a NCC para pagamento os valores vem um pouco diferentes.
		If SL1->L1_CREDITO > 0 
			nDescTot	:= SL1->L1_DESCONT * (  (nValTot-nVlrDescIt) / (SL1->L1_VALBRUT - nVlrFSD + SL1->L1_DESCONT))
		Else
			nDescTot	:= nTotDesc
		EndIf 
		
		sTexto	:= sTexto + 'Desconto no Total:             ' + Str(nDescTot, 15, 2) + Chr(13) + Chr(10)
	EndIf

	//Armazena Valor Total
	If lMvArrefat
		nVlrTot := Round((nValTot - nDescTot - nVlrDescIt + nTroco), TamSX3("D2_TOTAL")[2])
	Else
		nVlrTot := NoRound((nValTot - nDescTot - nVlrDescIt + nTroco), TamSX3("D2_TOTAL")[2])
	EndIf

	//Calcula juros
	If SL1->L1_JUROS > 0    
		If nMvLjTpDes <> 2
			nVlrAcres := NoRound((nVlrTot * SL1->L1_JUROS) / 100, TamSx3("D2_VALACRS")[2])    
		Else
			nVlrAcres := Round((nVlrTot * SL1->L1_JUROS) / 100, TamSx3("D2_VALACRS")[2]) 
		EndIf
		
		nVlrTot   += nVlrAcres //Adiciona acrescimo no valor total
		sTexto    := sTexto + 'Acrescimo no Total:            ' + Transform(SL1->L1_JUROS, "@R 99.99%") + Chr(13) + Chr(10)
	EndIf

	//Adiciona frete somente quando existe um item com pedido na venda
	If nVlrFSD > 0 .And. lPedido
		nVlrTot += nVlrFSD
	EndIf

	/* Ajusta o valor proporcionalizado na condição de pagamento em $
	Necessario para evitar diferença de 0,01 centavos em determinados casos de venda mista*/
	If nDinheir > 0
		If nValPag <> nVlrTot
			// Ajusto o valor em dinheiro para impressão no comprovante não fiscal		
			nDinheir := nDinheir + Round(nValTot + nVlrFSD - nDescTot - nVlrDescIt + nTroco + nVlrAcres,2) - nValPag
		EndIf	            
	EndIf
																		
	If nVlrFSD > 0 .And. lPedido
		sTexto	:= sTexto + 'Frete:                         ' + Transform(nVlrFSD, PesqPict("SL1","L1_FRETE")) + Chr(13) + Chr(10)
	EndIf

	sTexto := sTexto + Replicate("-", nMaxChar)						     + Chr(13) + Chr(10)
	sTexto	:= sTexto + 'TOTAL                          ' + Str(nVlrTot, 15, 2) + Chr(13) + Chr(10)
	If nDinheir > 0 
		sTexto := sTexto + 'DINHEIRO' + '                   ' + Str( nDinheir , 15, 2) + ' (+)' + Chr(13) + Chr(10)
	EndIf
	If nCheques > 0 
		sTexto := sTexto + 'CHEQUE' + '                     ' + Str(nCheques, 15, 2) + ' (+)' +  Chr(13) + Chr(10)
	EndIf
	If nCartaoC > 0 
		sTexto := sTexto + 'CARTAO CRED' + '                ' + Str(nCartaoC, 15, 2) + ' (+)' +  Chr(13) + Chr(10)
	EndIf
	If nCartaoD > 0 
		sTexto := sTexto + 'CARTAO DEB' + '                 ' + Str(nCartaoD, 15, 2) + ' (+)' + Chr(13) + Chr(10)
	EndIf
	If nConveni > 0 
		sTexto := sTexto + 'CONVENIO' + '                   ' + Str(nConveni, 15, 2) + ' (+)' + Chr(13) + Chr(10)
	EndIf
	If nOutros > 0 
		sTexto := sTexto + 'Outros' + '                      ' + Str(nOutros, 15, 2) + ' (+)' + Chr(13) + Chr(10)
	EndIf
	If nVales > 0 
		sTexto := sTexto + 'VALES' + '                      ' + Str(nVales, 15, 2) + ' (+)' + Chr(13) + Chr(10)
	EndIf
	If nFinanc > 0 
		sTexto := sTexto + 'CARTEIRA' + '                   ' + Str(nFinanc, 15, 2) + ' (+)' + Chr(13) + Chr(10)
	EndIf  
	If nCredito > 0
		sTexto := sTexto + 'CREDITO ' + '                   ' + Str(nCredito, 15, 2) + ' (+)' + Chr(13) + Chr(10)
	EndIf			 
	If lMvLjTroco .And. nTroco > 0
		sTexto := sTexto + 'TROCO   ' + '                   ' + Str(nTroco, 15, 2) +' (-)'+ Chr(13) + Chr(10)
	EndIf			                                                                                        
	sTexto := sTexto + Replicate("-", nMaxChar)						   + Chr(13)+ Chr(10) 

	sTexto := sTexto + '<b>Orcamento: </b>' + AllTrim(SL1->L1_NUM) + Chr(13) + Chr(10)
	sTexto := sTexto + ' ' + Chr(13) + Chr(10)
	sTexto := sTexto + '<b>Cliente:</b> ' +  Alltrim(cNomCli)    + Chr(13) + Chr(10)
	sTexto := sTexto + Replicate("-", nMaxChar)						     + Chr(13) + Chr(10) 
	
	sTexto := sTexto + '<b>Data:</b> ' + DtoC(dDatabase) + ' <b>Hora: </b>' +Time() + Chr(13) + Chr(10)
	sTexto := sTexto + '<b>Vendedor:</b> ' + Alltrim(SL1->L1_VEND)+' - ' +  Alltrim(cNomVen) + Chr(13) + Chr(10)
	sTexto := sTexto + '<b>Caixa:</b> ' + Alltrim(SL1->L1_ESTACAO)+'<b> Operador: </b>' + Alltrim(SL1->L1_OPERADO)+' - ' +  Alltrim(cNomOpe) + Chr(13) + Chr(10)
	sTexto := sTexto + Replicate("-", nMaxChar)						     + Chr(13) + Chr(10)
	sTexto := sTexto + ' ' + Chr(13) + Chr(10)

	cTxImp := StrTran( sTexto, ',', '.' )
	STWManagReportPrint(cTxImp,1) //Envia comando para a Impressora
	STWManagReportPrint(cTxImp,1) //Envia comando para a Impressora

	sTexto := ''

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fCompPag
Funcao para impressao do comprovante de pagamento
@type function
@param 

@author Varejo
@version P12
@return cTexto, retorna texto do comprovante do caixa e do cliente

/*/
//-------------------------------------------------------------------
Static Function fPrdMadFerr()
	Local cGrpProd := ""

	aAdd(aPrdMaFe,{})
	aAdd(aPrdMaFe,{})

	dbSelectArea("SL2")
	dbSetOrder(1)  
	dbSeek(xFilial("SL2") + nOrcam)
	
	dbSelectArea("ACV")
	ACV->(dbSetOrder(4))

	While !SL2->(Eof()) .AND. SL2->L2_FILIAL + SL2->L2_NUM == xFilial("SL2") + nOrcam
		/* Entrega ou Retira Posterior ou Vale Presente*/	
		If SL2->L2_ENTREGA $("1|3|4|5") .OR. !Empty(SL2->L2_VALEPRE) ;
			.OR. (Posicione("SB1",1,xFilial("SB1") + SL2->L2_PRODUTO,"SB1->B1_TIPO") == cServType) ;
			.OR. (Posicione("SB1",1,xFilial("SB1") + SL2->L2_PRODUTO,"SB1->B1_TIPO") == cGarType)
			
			cGrpProd := Posicione("SB1",1,xFilial("SB1") + SL2->L2_PRODUTO,"SB1->B1_GRUPO")

			IF ACV->(MSSeek(xFilial("ACV")+cGrpProd))
				Do Case
					Case ACV->ACV_CATEGO == '000001'
						aAdd(aPrdMaFe[1],{ SL2->L2_ITEM, SL2->L2_PRODUTO })
					Case ACV->ACV_CATEGO == '000002'
						aAdd(aPrdMaFe[2],{ SL2->L2_ITEM, SL2->L2_PRODUTO })
				End Case
			Else
				aAdd(aPrdMaFe[3],{ SL2->L2_ITEM, SL2->L2_PRODUTO })
			EndIF 
	
			SL2->(DbSkip())
		Else
			SL2->(DbSkip())
		EndIf
	EndDo

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} fCompRet
Funcao para impressao do comprovante de Retira
@type function
@param 

@author Varejo
@version P12
@return cTexto, retorna texto do comprovante do cliente

/*/
//-------------------------------------------------------------------
Static Function fCompRet(pPos)
	Local cComprov := IIF(pPos == 1, 'MADEIRA', 'DIVERSOS')
	Local cMsg     := ""
	Local nLinMsg  := 0
	Local nY       := 0

	sTexto:= '<ce>'+ alltrim(cNomCom) +'</ce>'+ Chr(13)+ Chr(10)
	sTexto:= sTexto +'<ce>'+ alltrim(cEndEnt) + ' - '+ alltrim(cBaiEnt) +'</ce>'+ Chr(13)+ Chr(10)
	sTexto:= sTexto +'<ce>'+ alltrim(cCidEnt) + ' - '+ alltrim(cEstEnt) + ' CEP:'+ alltrim(cCepEnt) +'</ce>'+ Chr(13)+ Chr(10)
	sTexto:= sTexto +'<ce> CNPJ: '+ alltrim(cCgcEnt) + ' IE: '+ alltrim(cInsEnt) +'</ce>'+ Chr(13)+ Chr(10)

	sTexto:= sTexto + Replicate("-", nMaxChar)						   		+ Chr(13)+ Chr(10)
	sTexto:= sTexto + '<b><ce>COMPROVANTE DE RETIRA '+cComprov+'</ce></b>' 	+ Chr(13)+ Chr(10)
	sTexto:= sTexto + Replicate("-", nMaxChar)						   		+ Chr(13)+ Chr(10)
	sTexto:= sTexto + 'Codigo         Descricao' 					   		+ Chr(13)+ Chr(10)
	sTexto:= sTexto + 'Qtd            VlrUnit              VlrTot'    		+ Chr(13)+ Chr(10)
	sTexto:= sTexto + Replicate("-", nMaxChar)						   		+ Chr(13)+ Chr(10)
	dbSelectArea("SL1")                                                                  
	dbSetOrder(1)  
	dbSeek(xFilial("SL1") + nOrcam)

	nTroco		:= Iif(SL1->(FieldPos("L1_TROCO1")) > 0,(nFatorRes * SL1->L1_TROCO1), 0)
	nDinheir	:= (nFatorRes * SL1->L1_DINHEIR)
	nCheques	:= (nFatorRes * SL1->L1_CHEQUES)
	nCartaoC 	:= (nFatorRes * SL1->L1_CARTAO)
	nCartaoD 	:= (nFatorRes * SL1->L1_VLRDEBI)
	nConveni	:= (nFatorRes * SL1->L1_CONVENI)
	nVales  	:= (nFatorRes * SL1->L1_VALES)  	
	nCredito	:= (nFatorRes * SL1->L1_CREDITO)  	
	nFinanc		:= (nFatorRes * SL1->L1_FINANC)
	nOutros		:= (nFatorRes * SL1->L1_OUTROS)
	nValTot		:= 0
	nDescTot	:= 0

	/* Soma o valor de todas as formas de pagamento
	Necessariio dar um round em cada forma para verificar se ha diferença de arredondamento no somatorio dos pagamentos*/
	nValPag :=	Round(nDinheir,2)	+	Round(nCheques,2)	+	Round(nCartaoC,2)	+	Round(nCartaoD,2)	+;
				Round(nConveni,2)	+	Round(nVales,2)	+	Round(nCredito,2)	+	Round(nFinanc,2)	+;
				Round(nOutros,2)

	dbSelectArea("SL2")
	dbSetOrder(1)  
		
	For nY := 1 To Len(aPrdMaFe[pPos])
		
		dbSeek(xFilial("SL2") + nOrcam + aPrdMaFe[pPos,nY,1] + aPrdMaFe[pPos,nY,2])

		If SL2->L2_ENTREGA $("3|5")
			lPedido := .T.
		EndIf
		
		If aScan(aProdGarantia, { |p| RTrim(p[1]) ==  RTRim(SL2->L2_PRODUTO)} ) > 0
			cGarantia := "*"
		Else
			If SL2->(FieldPos("L2_GARANT")) > 0 .AND.  !Empty(SL2->L2_GARANT)
				cGarantia := "#"
			Else
				cGarantia := ""
			EndIf
		EndIf
	
		If !Empty(SL2->L2_ENTREGA)
			If !Empty(cGarantia)
				cGarantia += IIF(SL2->L2_ENTREGA == "3", " E", IIF(SL2->L2_ENTREGA == "1", " P", ""))
			Else
				cGarantia := IIF(SL2->L2_ENTREGA == "3", "E", IIF(SL2->L2_ENTREGA == "1", "P", ""))
			EndIf
	
		EndIf
		
		//Faz o tratamento do valor do ICMS ret.
		If SL2->(FieldPos("L2_ICMSRET")) > 0
			nVlrIcmsRet	:= SL2->L2_ICMSRET
		Endif
		
		cQuant 	:= Alltrim(Transform(SL2->L2_QUANT, "@E 999,999,999.99"))
		If (!lMvGarFP .AND. !lLibQtdGE ) .AND. (cGarantia == "*" .OR. (Posicione("SB1",1,xFilial("SB1")+SL2->L2_PRODUTO, "B1_TIPO") == SuperGetMV("MV_LJTPGAR",,"GE")))
			cVrUnit	:= Str(((SL2->L2_QUANT * SL2->L2_VLRITEM) + SL2->L2_VALIPI + nVlrIcmsRet) / SL2->L2_QUANT, 15, 2)
		Else
			cVrUnit	:= Str(((SL2->L2_QUANT * SL2->L2_PRCTAB) + SL2->L2_VALIPI + nVlrIcmsRet) / SL2->L2_QUANT, 15, 2)
		EndIf
		
		//Valor de desconto no item
		nVlrDescIt += SL2->L2_VALDESC
		nTotDesc   += SL2->L2_DESCPRO
		cVlrItem   := Str(Val(cVrUnit) * SL2->L2_QUANT, 15, 2)
		sTexto	   := sTexto + PadR( Alltrim(SL2->L2_PRODUTO) + ' - ' + Alltrim(SL2->L2_DESCRI) ,nMaxChar) + Chr(13) + Chr(10)
		sTexto	   := sTexto + '<b>'+cQuant + '  ' + cVrUnit + '      ' + cVlrItem +'</b>'+ Chr(13) + Chr(10)
		If SL2->L2_VALDESC > 0
			sTexto	:= sTexto + 'Desconto no Item: ' + Str(SL2->L2_VALDESC, 15, 2) + Chr(13) + Chr(10)
		EndIf
		If !Empty(SL2->L2_LOCALIZ)
			sTexto	:= sTexto + '<b>Endereço:</b> ' + Alltrim(SL2->L2_LOCALIZ) + Chr(13) + Chr(10)
		EndIf
		
		nValTot  += Val(cVlrItem)
	
	Next                  

	cDesconto	:= Str(nVlrDescIt, TamSx3("L2_VALDESC")[1], TamSx3("L2_VALDESC")[2])
	nVlrFSD		:= SL1->L1_FRETE + SL1->L1_SEGURO + SL1->L1_DESPESA

	If SL1->L1_DESCONTO > 0
		//O valor de desconto deve ser encontrada atraves da soma de todos os produtos (seus valores originais) (sem frete / sem desconto / sem acrescimo)
		//Porem quando é selecionado a NCC para pagamento os valores vem um pouco diferentes.
		If SL1->L1_CREDITO > 0 
			nDescTot	:= SL1->L1_DESCONT * (  (nValTot-nVlrDescIt) / (SL1->L1_VALBRUT - nVlrFSD + SL1->L1_DESCONT))
		Else
			nDescTot	:= nTotDesc
		EndIf 
		
		sTexto	:= sTexto + 'Desconto no Total:             ' + Str(nDescTot, 15, 2) + Chr(13) + Chr(10)
	EndIf

	//Armazena Valor Total
	If lMvArrefat
		nVlrTot := Round((nValTot - nDescTot - nVlrDescIt + nTroco), TamSX3("D2_TOTAL")[2])
	Else
		nVlrTot := NoRound((nValTot - nDescTot - nVlrDescIt + nTroco), TamSX3("D2_TOTAL")[2])
	EndIf

	//Calcula juros
	If SL1->L1_JUROS > 0    
		If nMvLjTpDes <> 2
			nVlrAcres := NoRound((nVlrTot * SL1->L1_JUROS) / 100, TamSx3("D2_VALACRS")[2])    
		Else
			nVlrAcres := Round((nVlrTot * SL1->L1_JUROS) / 100, TamSx3("D2_VALACRS")[2]) 
		EndIf
		
		nVlrTot   += nVlrAcres //Adiciona acrescimo no valor total
		sTexto    := sTexto + 'Acrescimo no Total:            ' + Transform(SL1->L1_JUROS, "@R 99.99%") + Chr(13) + Chr(10)
	EndIf

	//Adiciona frete somente quando existe um item com pedido na venda
	If nVlrFSD > 0 .And. lPedido
		nVlrTot += nVlrFSD
	EndIf

	/* Ajusta o valor proporcionalizado na condição de pagamento em $
	Necessario para evitar diferença de 0,01 centavos em determinados casos de venda mista*/
	If nDinheir > 0
		If nValPag <> nVlrTot
			// Ajusto o valor em dinheiro para impressão no comprovante não fiscal		
			nDinheir := nDinheir + Round(nValTot + nVlrFSD - nDescTot - nVlrDescIt + nTroco + nVlrAcres,2) - nValPag
		EndIf	            
	EndIf
																		
	If nVlrFSD > 0 .And. lPedido
		sTexto	:= sTexto + 'Frete:                         ' + Transform(nVlrFSD, PesqPict("SL1","L1_FRETE")) + Chr(13) + Chr(10)
	EndIf

	sTexto := sTexto + Replicate("-", nMaxChar)						     + Chr(13) + Chr(10)
	sTexto	:= sTexto + 'TOTAL                          ' + Str(nVlrTot, 15, 2) + Chr(13) + Chr(10)
	
	sTexto := sTexto + '<b>Orc. Res.: </b>' + AllTrim(SL1->L1_NUM) + Chr(13) + Chr(10)
	sTexto := sTexto + ' ' + Chr(13) + Chr(10)
	sTexto := sTexto + '<b>Cliente:</b> ' +  Alltrim(cNomCli)    + Chr(13) + Chr(10)
	sTexto := sTexto + Replicate("-", nMaxChar)						     + Chr(13) + Chr(10) 

	sTexto := sTexto + '<b>Data:</b> ' + DtoC(dDatabase) + ' <b>Hora: </b>' +Time() + Chr(13) + Chr(10)
	sTexto := sTexto + '<b>Vendedor:</b> ' + Alltrim(SL1->L1_VEND)+' - ' +  Alltrim(cNomVen) + Chr(13) + Chr(10)
	sTexto := sTexto + '<b>Caixa:</b> ' + Alltrim(SL1->L1_ESTACAO)+'<b> Operador: </b>' + Alltrim(SL1->L1_OPERADO)+' - ' +  Alltrim(cNomOpe) + Chr(13) + Chr(10)
	sTexto := sTexto + Replicate("-", nMaxChar)						     + Chr(13) + Chr(10)
	sTexto := sTexto + ' ' + Chr(13) + Chr(10)

	If !Empty(SL1->L1_XMSGI)
		cMsg    := SL1->L1_XMSGI
		nLinMsg := MLCount(SL1->L1_XMSGI,nMaxChar)

		For nY := 1 To nLinMsg
			sTexto := sTexto + '<ce>' + MemoLine(cMsg,nMaxChar,nY) + '</ce>' + Chr(13) + Chr(10)
		Next nY
		
		sTexto := sTexto + ' ' + Chr(13) + Chr(10)
	EndIf

	sTexto := sTexto + '<ce>' + 'Prezado(a) Cliente informamos que o prazo ' + '</ce>' + Chr(13) + Chr(10)
	sTexto := sTexto + '<ce>' + 'para retirada da mercadoria é de 15 dias ' + '</ce>' + Chr(13) + Chr(10)
	sTexto := sTexto + '<ce>' + 'a partir do fechamento da venda.' + '</ce>' + Chr(13) + Chr(10)
	
	sTexto := sTexto + Replicate("-", nMaxChar)						     + Chr(13) + Chr(10)

	sTexto := sTexto + '<ce>' + 'Prezado(a) Cliente gostaríamos de informar ' + '</ce>' + Chr(13) + Chr(10)
	sTexto := sTexto + '<ce>' + 'que o prazo para devolução é de 30 dias ' + '</ce>' + Chr(13) + Chr(10)
	sTexto := sTexto + '<ce>' + 'a partir da data de recebimento do produto. ' + '</ce>' + Chr(13) + Chr(10)
	sTexto := sTexto + ' ' + Chr(13) + Chr(10)
	sTexto := sTexto + '<ce>' + 'Agradecemos pela sua atenção! ' + '</ce>' + Chr(13) + Chr(10)

	sTexto := sTexto + Replicate("-", nMaxChar)						     + Chr(13) + Chr(10)

	cTxImp := StrTran( sTexto, ',', '.' )
	STWManagReportPrint(cTxImp,1) //Envia comando para a Impressora

	sTexto := ''

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LjPrtPdLoc  ºAutor³Vendas CRM		     º Data ³ 10/06/11    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³Descri‡…o ³Rotina para impressao de Comprovante de Venda - Release 11.5³±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe   ³ExpL1 := LjPrtPdLoc()                       				  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³											                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SIGALOJA/SIGAFRT	                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/  
User Function LjPrtPdLoc ()
	Local lRet := .T.


	Local wnrel   	:= "SCRPED"
	Local cString  	:= "SL1"
	Local cDesc1   	:= "Comprobante de Venta"
	Local cDesc2   	:= ""
	Local cDesc3   	:= ""
	Local nLastKey 	:= 0 
	Local nOrcam    := 0          
	Local nCheques	:= 0 
	Local nCartao	:= 0 
	Local nConveni	:= 0 
	Local nVales	:= 0 
	Local nFinanc	:= 0 
	Local nCredito	:= 0
	Local nOutros 	:= 0 
	Local cQuant 	:= ""
	Local cVrUnit	:= ""
	Local cDesconto	:= ""
	Local cVlrItem	:= "" 
	Local cTpEntrega:= ""
	Local nLinha	:= 10 
	Local nMoedaCor	:= 1						//Moeda Corrente
	Local nDecimais := MsDecimais(nMoedaCor)	//Decimais

	Private cTitulo  	:= "Comprobante de Venta"
	Private aReturn := { "Especial", 1,"Administracion", 1, 2, 1,"",1 }

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Envia controle para a funcao SETPRINT³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	wnrel:=SetPrint(cString,wnrel,"",@cTitulo,cDesc1,cDesc2,cDesc3,.F.)
	If nLastKey == 27
		Return .F.
	Endif

	SetDefault(aReturn,cString)

	If nLastKey == 27
		Return .F.
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica Posicao do Formulario na Impressora³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	VerImp()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verificar os itens que atendem o tipo de ³
	//³entrega de acordo com o pais.            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Do Case
		Case cPaisLoc == "COL"
			cTpEntrega := "1|3"		
		Case cPaisLoc == "CHI"
			cTpEntrega := "1"
	EndCase


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³                                              CABECALHO                                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	@ nLinha, 001 PSAY "Codigo"
	@ nLinha, 010 PSAY "Descripcion"
	@ nLinha, 060 PSAY "Cantidad"
	@ nLinha, 080 PSAY "Unitario"
	@ nLinha, 100 PSAY "Total"

	nLinha++
	@ nLinha, 001 PSAY "----------------------------------------------------------------------------------------------------------------------------"
	nLinha++

	dbSelectArea("SL1")                                                                  
	dbSetOrder(1)  
	nOrcam		:= SL1->L1_NUM
	nDinheir	:= SL1->L1_DINHEIR
	nCheques	:= SL1->L1_CHEQUES
	nCartao 	:= SL1->L1_CARTAO
	nConveni	:= SL1->L1_CONVENI
	nVales  	:= SL1->L1_VALES  	
	nFinanc		:= SL1->L1_FINANC
	nCredito	:= SL1->L1_CREDITO
	nOutros		:= SL1->L1_OUTROS
			
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³                                              ITENS		                                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SL2")
	dbSetOrder(1)  
	dbSeek(xFilial("SL2") + nOrcam)
		
	While !SL2->(Eof()) .AND. SL2->L2_FILIAL + SL2->L2_NUM == cFilAnt + nOrcam
		If SL2->L2_ENTREGA $ cTpEntrega	
			cQuant 		:= StrZero(SL2->L2_QUANT, 8, 3)
			cVrUnit		:= Str(((SL2->L2_QUANT * SL2->L2_PRCTAB) / SL2->L2_QUANT), 15, nDecimais)
			cDesconto	:= Str(SL2->L2_VALDESC, TamSx3("L2_VALDESC")[1], TamSx3("L2_VALDESC")[2])
			cVlrItem	:= Str(Val(cVrUnit) * SL2->L2_QUANT, 15, nDecimais)
			
			@ nLinha, 001 PSAY SL2->L2_PRODUTO
			@ nLinha, 010 PSAY SL2->L2_DESCRI
			@ nLinha, 060 PSAY cQuant
			@ nLinha, 080 PSAY AllTrim(cVrUnit)
			@ nLinha, 100 PSAY AllTrim(cVlrItem)
			
			If SL2->L2_VALDESC > 0 
				nLinha++
				@ nLinha, 060 PSAY 'Descuento del Item: ' + Str(SL2->L2_VALDESC, 15, nDecimais)
			EndIf
		EndIf
		SL2->(DbSkip())
		nLinha++
	Enddo                      

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³                                              RODAPE		                                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nLinha++
	If SL1->L1_DESCONTO > 0
		@ nLinha, 080 PSAY 'Descuento Total: 	            ' + Str(SL1->L1_DESCONTO, 15, nDecimais)
		nLinha++
	EndIf                                                                              
	If SL1->L1_JUROS > 0
		@ nLinha, 080 PSAY 'Incremento Total:            	' + Transform(SL1->L1_JUROS, "@R 99.99%")
		nLinha++
	EndIf

	nLinha++
	@ nLinha, 001 PSAY "----------------------------------------------------------------------------------------------------------------------------"
	nLinha++

	@ nLinha, 080 PSAY 'TOTAL                         ' + Str(SL1->L1_VLRLIQ+nCredito, 15, nDecimais)

	If nDinheir > 0
		nLinha++ 
		@ nLinha, 080 PSAY 'DINERO' + '                      	 ' + Str(nDinheir, 15, nDecimais)
	EndIf
	If nCheques > 0 
		nLinha++
		@ nLinha, 080 PSAY 'CHEQUE' + '                         ' + Str(nCheques, 15, nDecimais)
	EndIf
	If nCartao > 0 
		nLinha++
		@ nLinha, 080 PSAY 'TARJETA' + '                          ' + Str(nCartao, 15, nDecimais)
	EndIf
	If nConveni > 0 
		nLinha++
		@ nLinha, 080 PSAY 'CONVENIO' + '                        ' + Str(nConveni, 15, nDecimais)
	EndIf
	If nVales > 0 
		nLinha++
		@ nLinha, 080 PSAY 'BONOS' + '                           ' + Str(nVales, 15, nDecimais)
	EndIf
	If nFinanc > 0 
		nLinha++
		@ nLinha, 080 PSAY 'FINANCIADO' + '                      ' + Str(nFinanc, 15, nDecimais)
	EndIf  
	If nCredito > 0
		nLinha++
		@ nLinha, 080 PSAY 'CREDITO' + '                       ' + Str(nCredito, 15, nDecimais)
	EndIf			
				
	nLinha++
	@ nLinha, 001 PSAY "----------------------------------------------------------------------------------------------------------------------------"


	Set Device To Screen
	If aReturn[5] == 1
		Set Printer TO
		dbcommitAll()
		ourspool(wnrel)
	Endif
	MS_FLUSH()

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³ VerImp   ºAutor  ³Vendas CRM		     º Data ³  10/06/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Verifica posicionamento de papel na Impressora             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SCRPED	                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function VerImp()

Local aDriver  :=  ""
Local nOpc     

nLin:= 0                // Contador de Linhas
aDriver:=ReadDriver()
If aReturn[5]==2
	
	nOpc       := 1
	While .T.
		
		SetPrc(0,0)
		dbCommitAll()
		
		@ 00   ,000	PSAY aDriver[5]
		@ nLin ,000 PSAY " "
		@ nLin ,004 PSAY "*"
		@ nLin ,022 PSAY "."
		
		IF MsgYesNo(OemToAnsi("¿Fomulario esta en posicion? "),'')
		   nOpc := 1
		ElseIF MsgYesNo(OemToAnsi("¿Intenta Nuevamente? "),'')
		   nOpc := 2
		Else
		   nOpc := 3
		Endif

		Do Case
		Case nOpc==1
			lContinua := .T.
			Exit
		Case nOpc==2
			Loop
		Case nOpc==3
			lContinua := .F.
			Return
		EndCase
	End
Endif
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} SCRCRED
Funcao para impressao de Comprovante de crédito do cliente
@type function
@param 

@author Varejo
@version P12
@return cTexto, retorna texto do comprovante de credito do cliente

/*/
//-------------------------------------------------------------------
User Function SCRCRED()   

	Local aArea 		:= GetArea()	// Guarda area atual
	Local cTexto		:= ""			// Texto do comprovante a ser impresso
	Local nX			:= 0 			// Contador
	Local nTotNCCs		:= 0 			// Valor Total de todas as NCCs disponiveis para uso
	Local cPicValor     := PesqPict("SL1","L1_VLRTOT")//Picture de valor
	Local nTPCompNCC    := SuperGetMV("MV_LJCPNCC",,1)//Compensacao de NCC 1-Compensacao atual 2- Nova Compensacao 
	Local nVlrCred 		:= PARAMIXB[1] 	// Valor de credito usado na venda L1_CREDITO
	Local aNCCs 		:= PARAMIXB[2] 	// Array com todas NCCs abertas do cliente
	//Local nTotSelNCC	:= PARAMIXB[3] 	// Valor Total NCCs selecionadas
	Local cCodCli    	:= PARAMIXB[4] 	// Codigo do Cliente
	Local cCodLojCli	:= PARAMIXB[5] 	// Codigo da loja do cliente
	Local nMaxChar 		:= 47
	Local aFieldSM0 	:= { ;
							"M0_NOMECOM",;   //Posição [1]
							"M0_ENDENT",;    //Posição [2]
							"M0_BAIRENT",;   //Posição [3]
							"M0_CIDENT",;    //Posição [4]
							"M0_ESTENT",;    //Posição [5]
							"M0_CEPENT",;    //Posição [6]
							"M0_CGC",;       //Posição [7]
							"M0_INSC",;      //Posição [8]
							"M0_COMPENT",;   //Posição [9]
							"M0_TEL";		 //Posição [10]
							}        
	Local aSM0Data 		:= FWSM0Util():GetSM0Data(, SL1->L1_FILIAL, aFieldSM0)
	Local cNomCom       := aSM0Data[1,2] // Nome Comercial da Empresa
	Local cEndEnt       := aSM0Data[2,2] // Endereço de Entrega
	Local cBaiEnt       := aSM0Data[3,2] // Bairro de Entrega
	Local cCidEnt       := aSM0Data[4,2] // Cidade de Entrega
	Local cEstEnt       := aSM0Data[5,2] // Estado de Entrega
	Local cCepEnt       := aSM0Data[6,2] // Cep de Entrega
	Local cCgcEnt       := aSM0Data[7,2] // CNPJ 
	Local cInsEnt       := aSM0Data[8,2] // Inscrição Estadual
	Local cNomCli       := Posicione("SA1",1,xFILIAL("SA1")+PARAMIXB[4]+PARAMIXB[5],"A1_NOME") //Nome do Cliente
	Local cNomOpe       := Posicione("SA6",1,xFilial("SA6")+SL1->L1_OPERADO,"A6_NOME")  // Nome do Operador
	Local cMsgCred      := SuperGetMV("MV_XMSGCRED",.F.,"")

	/*   
		Posicoes do Array aNCCs
		
		aNCCs[x,1]  = .F.	// Caso a NCC seja selecionada, este campo recebe TRUE			 
		aNCCs[x,2]  = SE1->E1_SALDO  
		aNCCs[x,3]  = SE1->E1_NUM		
		aNCCs[x,4]  = SE1->E1_EMISSAO
		aNCCs[x,5]  = SE1->(Recno()) 
		aNCCs[x,6]  = SE1->E1_SALDO
		aNCCs[x,7]  = SuperGetMV("MV_MOEDA1")
		aNCCs[x,8]  = SE1->E1_MOEDA
		aNCCs[x,9]  = SE1->E1_PREFIXO	
		aNCCs[x,10] = SE1->E1_PARCELA	 
		aNCCs[x,11] = SE1->E1_TIPO
	*/

	//Somente Imprime para tipo de compensação 1 e 2 
	If nTPCompNCC >= 1 .And. nTPCompNCC <= 2
		If Len(aNCCs) > 0 .AND. nVlrCred > 0

			cTexto := '<ce>'+ alltrim(cNomCom) +'</ce>'+ Chr(13)+ Chr(10)
			cTexto += '<ce>'+ alltrim(cEndEnt) + ' - '+ alltrim(cBaiEnt) +'</ce>'+ Chr(13)+ Chr(10)
			cTexto += '<ce>'+ alltrim(cCidEnt) + ' - '+ alltrim(cEstEnt) + ' CEP:'+ alltrim(cCepEnt) +'</ce>'+ Chr(13)+ Chr(10)
			cTexto += '<ce> CNPJ: '+ alltrim(cCgcEnt) + ' IE: '+ alltrim(cInsEnt) +'</ce>'+ Chr(13)+ Chr(10)
			cTexto += Replicate(" ", nMaxChar) + Chr(13)+ Chr(10)
			cTexto += Replicate("-", nMaxChar)						   + Chr(13)+ Chr(10)
			cTexto += '<b><ce>C O M P R O V A N T E   C R E D I T O</ce></b>'		   + Chr(13)+ Chr(10)
			cTexto += Replicate("-",nMaxChar) + Chr(13)+ Chr(10)
			cTexto += Replicate(" ", nMaxChar) + Chr(13)+ Chr(10)
			cTexto += PADC(AllTrim(cCodCli) + "/" + cCodLojCli + " - " +  AllTrim(cNomCli),nMaxChar)	+ Chr(13)+ Chr(10)
			cTexto += Replicate("-",nMaxChar) + Chr(13)+ Chr(10)
			For nX := 1 To Len(aNCCs) 
				nTotNCCs += aNCCs[nX][2] //Soma total de NCCs disponiveis
			Next nX
			cTexto += Replicate("*",nMaxChar) + Chr(13)+ Chr(10)
			cTexto += "<b><ce>Posição de crédito disponível</b></ce>" + Chr(13)+ Chr(10) 
			cTexto += Replicate(" ", nMaxChar) + Chr(13) + Chr(10)
			cTexto += PADR("<b>Crédito utilizado na venda:</b> ",nMaxChar-14) + PADL("R$ " +AllTrim(Transform(nVlrCred,cPicValor)),14) + Chr(13)+ Chr(10)
			cTexto += PADR("<b>*** Saldo Restante:</b> ",nMaxChar-15) + PADL("R$ " + AllTrim(Transform(nTotNCCs-nVlrCred,cPicValor)),15) + Chr(13)+ Chr(10)
			cTexto += Replicate(" ", nMaxChar) + Chr(13) + Chr(10)
			cTexto += Replicate("*",nMaxChar) + Chr(13)+ Chr(10)
			cTexto += Replicate("-",nMaxChar) + Chr(13)+ Chr(10)
			cTexto += Replicate(" ", nMaxChar) + Chr(13) + Chr(10)
			cTexto += '<b>Data:</b> ' + DtoC(dDatabase) + ' <b>Hora: </b>' +Time() + Chr(13) + Chr(10)
			cTexto += '<b>Caixa:</b> ' + Alltrim(SL1->L1_ESTACAO)+'<b> Operador: </b>' + Alltrim(SL1->L1_OPERADO)+' - ' +  Alltrim(cNomOpe) + Chr(13) + Chr(10)
			cTexto += Replicate("-", nMaxChar) + Chr(13) + Chr(10) 
			cTexto += Replicate(" ", nMaxChar) + Chr(13) + Chr(10) 
			cTexto += '<ce>' + cMsgCred + '</ce>' + Chr(13) + Chr(10) 

		EndIf	
	EndIf		
	RestArea(aArea)

Return cTexto   

//-------------------------------------------------------------------
/*/{Protheus.doc} CARTEIRA
Funcao para impressao de Comprovante de Carteira (Financiado)
@type function
@param 

@author Varejo
@version P12
@return cTexto, retorna texto do comprovante de credito do cliente

/*/
//-------------------------------------------------------------------
User Function CARTEIRA(nFinanc)   

	Local aArea 		:= GetArea()	// Guarda area atual
	Local cTexto		:= ""			// Texto do comprovante a ser impresso
	Local cPicValor     := PesqPict("SL1","L1_VLRTOT")//Picture de valor
	Local nMaxChar 		:= 47 
	Local aFieldSM0 	:= { ;
							"M0_NOMECOM",;   //Posição [1]
							"M0_ENDENT",;    //Posição [2]
							"M0_BAIRENT",;   //Posição [3]
							"M0_CIDENT",;    //Posição [4]
							"M0_ESTENT",;    //Posição [5]
							"M0_CEPENT",;    //Posição [6]
							"M0_CGC",;       //Posição [7]
							"M0_INSC",;      //Posição [8]
							"M0_COMPENT",;   //Posição [9]
							"M0_TEL";		 //Posição [10]
							}        
	Local aSM0Data 		:= FWSM0Util():GetSM0Data(, SL1->L1_FILIAL, aFieldSM0)
	Local cNomCom       := aSM0Data[1,2] // Nome Comercial da Empresa
	Local cEndEnt       := aSM0Data[2,2] // Endereço de Entrega
	Local cBaiEnt       := aSM0Data[3,2] // Bairro de Entrega
	Local cCidEnt       := aSM0Data[4,2] // Cidade de Entrega
	Local cEstEnt       := aSM0Data[5,2] // Estado de Entrega
	Local cCepEnt       := aSM0Data[6,2] // Cep de Entrega
	Local cCgcEnt       := aSM0Data[7,2] // CNPJ 
	Local cInsEnt       := aSM0Data[8,2] // Inscrição Estadual
	Local cNomCli       := Posicione("SA1",1,xFILIAL("SA1")+SL1->L1_CLIENTE+SL1->L1_LOJA,"A1_NOME") //Nome do Cliente
	Local cCGCCli       := Posicione("SA1",1,xFILIAL("SA1")+SL1->L1_CLIENTE+SL1->L1_LOJA,"A1_CGC") //CPF/CNPJ do Cliente
	Local cTpCli        := Posicione("SA1",1,xFILIAL("SA1")+SL1->L1_CLIENTE+SL1->L1_LOJA,"A1_PESSOA") //Cliente Pessoa Física ou Juridica
	Local cNomVen       := Posicione("SA3",1,xFilial("SA3")+SL1->L1_VEND,"A3_NOME")  // Nome do Vendedor
	Local cNomOpe       := Posicione("SA6",1,xFilial("SA6")+SL1->L1_OPERADO,"A6_NOME")  // Nome do Operador
	Local cMsgCart      := SuperGetMV("MV_XMSGCART",.F.,"Declaro responsabilidade e firmo o compromisso de pagamento.")

	If cTpCli == 'F'
		cCGCCli := "CPF: " + Alltrim(Transform(cCGCCli, "@R 999.999.999-99"))
	ElseIF cTpCli == 'J'
		cCGCCli := "CNPJ: " + Alltrim(Transform(cCGCCli, "@R 99.999.999/9999-99"))
	EndIF

	If nFinanc > 0
			
		cTexto := '<ce>'+ alltrim(cNomCom) +'</ce>'+ Chr(13)+ Chr(10)
		cTexto += '<ce>'+ alltrim(cEndEnt) + ' - '+ alltrim(cBaiEnt) +'</ce>'+ Chr(13)+ Chr(10)
		cTexto += '<ce>'+ alltrim(cCidEnt) + ' - '+ alltrim(cEstEnt) + ' CEP:'+ alltrim(cCepEnt) +'</ce>'+ Chr(13)+ Chr(10)
		cTexto += '<ce> CNPJ: '+ alltrim(cCgcEnt) + ' IE: '+ alltrim(cInsEnt) +'</ce>'+ Chr(13)+ Chr(10)

		cTexto += Replicate("-", nMaxChar)						   + Chr(13)+ Chr(10)
		cTexto += '<b><ce>COMPROVANTE CARTEIRA</b></ce>'		   + Chr(13)+ Chr(10)
		cTexto += Replicate("-", nMaxChar)						   + Chr(13)+ Chr(10)
			 
		cTexto += Replicate(" ", nMaxChar) + Chr(13)+ Chr(10)	
		cTexto += "Pagamento Carteira: R$ " +AllTrim(Transform(nFinanc,cPicValor)) + CHR(10)
		cTexto += Replicate(" ", nMaxChar) + Chr(13)+ Chr(10)
		cTexto += Replicate("-", nMaxChar)						   + Chr(13)+ Chr(10)
			
		cTexto += Replicate(" ", nMaxChar) + Chr(13)+ Chr(10)
		cTexto += '<ce>' + cMsgCart + '</ce>' + Chr(13) + Chr(10)
		
		cTexto += " " + Chr(13)+ Chr(10)
		cTexto += " " + Chr(13)+ Chr(10)
		cTexto += " " + Chr(13)+ Chr(10)
		cTexto += " " + Chr(13)+ Chr(10)

		cTexto += '<ce>'+ Replicate("_", nMaxChar-7) +'</ce> '  + Chr(13) + Chr(10)
		cTexto += '<b><ce>' + AllTrim(cNomCli) + '</b></ce>' + Chr(13) + Chr(10)
		cTexto += '<b><ce>' + cCGCCli + '</b></ce>' + Chr(13) + Chr(10)
		cTexto += Replicate(" ", nMaxChar) + Chr(13)+ Chr(10)
			
		cTexto += Replicate("-", nMaxChar)						     + Chr(13) + Chr(10) 
		cTexto += '<b>Data:</b> ' + DtoC(dDatabase) + ' <b>Hora: </b>' +Time() + Chr(13) + Chr(10)
		cTexto += '<b>Vendedor:</b> ' + Alltrim(SL1->L1_VEND)+' - ' +  Alltrim(cNomVen) + Chr(13) + Chr(10)
		cTexto += '<b>Caixa:</b> ' + Alltrim(SL1->L1_ESTACAO)+'<b> Operador: </b>' + Alltrim(SL1->L1_OPERADO)+' - ' +  Alltrim(cNomOpe) + Chr(13) + Chr(10)
		cTexto += Replicate("-", nMaxChar)						     + Chr(13) + Chr(10) 

		STWManagReportPrint(cTexto,1) //Envia comando para a Impressora

	EndIf	

	RestArea(aArea)

Return   
