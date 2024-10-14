#INCLUDE "RWMAKE.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡ao   ³ SCRRPS      ³ Autor ³ Vendas CLientes    ³ Data ³05/04/2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡ao³ Monta o texto a ser impresso no comprovante de venda       ³±±
±±³          ³ (nao fiscal) no caso de venda com itens de servico (RPS -  ³±±
±±³          ³ Recibo Provisorio de Servico).                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Retorno  ³ Texto a ser impresso                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Sigaloja                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/  
User Function SCRRPS()
	Local aDadosRPS 	:= PARAMIXB
	Local cOrcam		:= ""
	Local sTexto   		:= ""                      
	Local nDinheir		:= 0
	Local nCheques		:= 0
	Local nCartaoC		:= 0
	Local nCartaoD		:= 0
	Local nConveni		:= 0
	Local nVales		:= 0
	Local nFinanc		:= 0
	Local nCredito		:= 0
	Local nCarteir		:= 0
	Local nDeposit		:= 0
	Local nPIXManu		:= 0
	Local nOutros		:= 0
	Local nAbtoPCC		:= 0
	Local nAbtoISS		:= 0
	Local cQuant 		:= ""
	Local cVrUnit		:= ""
	Local cDesconto		:= ""
	Local cVlrItem		:= ""
	Local nVlrIcmsRet	:= 0				// Valor do icms retido (Substituicao tributaria)
	Local aFilCodMun 	:= {{"",""},{"",""}}
	Local lRPSOK 		:= .F.
	Local cNumRPS		:= ""
	Local cSerRPS		:= ""
	Local lL2ICMSRET 	:= SL2->(FieldPos("L2_ICMSRET")) > 0
	Local nValTot		:= 0
	Local nDescTot		:= 0
	Local nTotDesc		:= 0
	Local nVlrDescIt	:= 0
	Local nFatorRPS		:= 1
	Local nValPag		:= 0
	Local lMvArrefat    := SuperGetMv("MV_ARREFAT") == "S"
	Local nVlrTot       := 0                                // Valor Total
	Local nVlrFSD       := 0                                // Valor do frete + seguro + despesas
	Local nMaxChar 		:= 47 // MÁXIMO DE CARACTERES POR LINHA
	Local aFieldSM0     := { ;
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
	Local cNomCli       := Posicione("SA1",1,xFILIAL("SA1")+SL1->L1_CLIENTE+SL1->L1_LOJA,"A1_NREDUZ") //Nome do Cliente
	Local cNomVen       := Posicione("SA3",1,xFilial("SA3")+SL1->L1_VEND,"A3_NOME")  // Nome do Vendedor
	Local cNomOpe       := Posicione("SA6",1,xFilial("SA6")+SL1->L1_OPERADO,"A6_NOME")  // Nome do Operador
	Local cMsg     		:= ""
	Local nLinMsg  		:= 0
	Local nY       		:= 0

	Private aVlrFormas		:= SCRPRetPgt()	// Resgata os valores de cada forma de pagamento

	If FindClass("FWSM0Util") //Proteção, para ambiente com RPO Ctree essa função não existe
		aFilCodMun	:= FWSM0Util():GetSM0Data( cEmpAnt, cFilAnt , { "M0_CODMUN","M0_CIDCOB" } )
	EndIf

	lRPSOK		:= aDadosRPS[01] 		//Indica se trouxe a série do RPS
	If Len(aDadosRPS[02]) > 0
		cNumRPS	:= aDadosRPS[02][01]	//Número do RPS
		cSerRPS	:= aDadosRPS[02][02]	//Série do RPS
	EndIf
	nFatorRPS 	:= aDadosRPS[03]		//Fator de Cálculo (proporcional da venda) referente aos itens de serviço (RPS)

	sTexto:= '<ce>'+ alltrim(cNomCom) +'</ce>'+ Chr(13)+ Chr(10)
	sTexto:= sTexto+'<ce>'+ alltrim(cEndEnt) + ' - '+ alltrim(cBaiEnt) +'</ce>'+ Chr(13)+ Chr(10)
	sTexto:= sTexto+'<ce>'+ alltrim(cCidEnt) + ' - '+ alltrim(cEstEnt) + ' CEP:'+ alltrim(cCepEnt) +'</ce>'+ Chr(13)+ Chr(10)
	sTexto:= sTexto+'<ce> CNPJ: '+ alltrim(cCgcEnt) + ' IE: '+ alltrim(cInsEnt) +'</ce>'+ Chr(13)+ Chr(10)

	sTexto := sTexto + '==============================================='	+Chr(13)+Chr(10)
	sTexto := sTexto + '      RECIBO PROVISORIO DE SERVICOS (RPS)      '	+Chr(13)+Chr(10)
	sTexto := sTexto + '==============================================='	+Chr(13)+Chr(10)

	// Tratativa municipio Aquiraz - CE
	IF lRPSOK .AND. ( (!Empty(aFilCodMun[1][2]) .AND. AllTrim(aFilCodMun[1][2]) == "2301000") .OR.;
		!Empty(aFilCodMun[2][2]) .AND. Upper(AllTrim(aFilCodMun[2][2])) == "AQUIRAZ" )
		sTexto := sTexto + 'Numero RPS                    ' + AllTrim(cNumRPS)	+Chr(13)+Chr(10)
		sTexto := sTexto + '-----------------------------------------------'	+Chr(13)+Chr(10)
	EndIf

	sTexto:= sTexto+ 'Codigo         Descricao'+Chr(13)+Chr(10)
	sTexto:= sTexto+ 'Qtd             VlrUnit                 VlrTot'+Chr(13)+Chr(10)
	sTexto:= sTexto+'-----------------------------------------------'+Chr(13)+Chr(10)
	cOrcam		:= SL1->L1_NUM
	nDinheir	:= (nFatorRes * aVlrFormas[01][02] )
	nCheques	:= (nFatorRes * aVlrFormas[02][02] )
	nCartaoC 	:= (nFatorRes * aVlrFormas[03][02] )
	nCartaoD 	:= (nFatorRes * aVlrFormas[04][02] )
	nPIX	 	:= (nFatorRes * aVlrFormas[05][02] )
	nCartDig 	:= (nFatorRes * aVlrFormas[06][02] )
	nFinanc		:= (nFatorRes * aVlrFormas[07][02] )
	nConveni	:= (nFatorRes * aVlrFormas[08][02] )
	nVales  	:= (nFatorRes * aVlrFormas[09][02] )
	nCredito	:= (nFatorRes * aVlrFormas[10][02] )
	nCarteir	:= (nFatorRes * aVlrFormas[11][02] )
	nDeposit	:= (nFatorRes * aVlrFormas[12][02] )
	nPIXManu	:= (nFatorRes * aVlrFormas[13][02] )
	nOutros		:= (nFatorRes * aVlrFormas[14][02] )
	nAbtoPCC	:= (nFatorRPS * SL1->L1_ABTOPCC)
	nAbtoISS	:= RetAbatIss()	//Abatimento de ISS

	/* Soma o valor de todas as formas de pagamento
	Necessariio dar um round em cada forma para verificar se ha diferença de arredondamento no somatorio dos pagamentos*/
	nValPag :=	Round(nDinheir,2)	+	Round(nCheques,2)	+	Round(nCartaoC,2)	+	Round(nCartaoD,2)	+;
				Round(nConveni,2)	+	Round(nVales,2)	+	Round(nCredito,2)	+	Round(nFinanc,2)	+;
				Round(nOutros,2)
			
	dbSelectArea("SL2")
	dbSetOrder(1)  
	dbSeek(xFilial("SL2") + cOrcam)
		
	While !SL2->(Eof()) .AND. SL2->L2_FILIAL + SL2->L2_NUM == cFilAnt + cOrcam
		
		//Verifica se é item de servico (ISS)
		If LjIsItISS()

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Faz o tratamento do valor do ICMS ret.                       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lL2ICMSRET 
				nVlrIcmsRet	:= SL2->L2_ICMSRET
			Endif

			cQuant 		:= StrZero(SL2->L2_QUANT, 8, 3)
			cVrUnit		:= Str(((SL2->L2_QUANT * SL2->L2_PRCTAB) + SL2->L2_VALIPI + nVlrIcmsRet) / SL2->L2_QUANT, 15, 2)
			
			nVlrDescIt 	+= SL2->L2_VALDESC //Valor de desconto no item
			nTotDesc   	+= SL2->L2_DESCPRO //Valor de desconto Total (Proporcional)
			cVlrItem 	:= Str(Val(cVrUnit) * SL2->L2_QUANT, 15, 2)

			sTexto		:= sTexto + SL2->L2_PRODUTO + SL2->L2_DESCRI + Chr(13) + Chr(10)
			sTexto		:= sTexto + cQuant + '  ' + cVrUnit + '      ' + cVlrItem + Chr(13) + Chr(10)
			If SL2->L2_VALDESC > 0 
				sTexto	:= sTexto + 'Desconto no Item:              ' + Str(SL2->L2_VALDESC, 15, 2) + Chr(13) + Chr(10)
			EndIf

			nValTot  += Val(cVlrItem)

		EndIf
		SL2->(DbSkip())
	Enddo

	cDesconto	:= Str(nVlrDescIt, TamSx3("L2_VALDESC")[1], TamSx3("L2_VALDESC")[2])
	nVlrFSD		:= SL1->L1_FRETE + SL1->L1_SEGURO + SL1->L1_DESPESA

	If SL1->L1_DESCONTO > 0
		nDescTot	:= nTotDesc
		sTexto	:= sTexto + 'Desconto no Total:             ' + Str(nDescTot, 15, 2) + Chr(13) + Chr(10)
	EndIf

	//Armazena Valor Total
	nVlrTot := nValTot - nDescTot - nVlrDescIt
	nVlrTot := IIf(lMvArrefat, Round(nVlrTot,TamSX3("D2_TOTAL")[2]), NoRound(nVlrTot,TamSX3("D2_TOTAL")[2]))

	sTexto	:= sTexto + '-----------------------------------------------' + Chr(13) + Chr(10)
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
	If nPIX > 0 
		sTexto := sTexto + 'PIX' + '                        ' + Str(nPIX, 15, 2) + ' (+)' + Chr(13) + Chr(10)
	EndIf
	If nCartDig > 0 
		sTexto := sTexto + 'CARTEIRA DIGITAL' + '           ' + Str(nCartDig, 15, 2) + ' (+)' + Chr(13) + Chr(10)
	EndIf
	If nConveni > 0 
		sTexto := sTexto + 'CONVENIO' + '                   ' + Str(nConveni, 15, 2) + ' (+)' + Chr(13) + Chr(10)
	EndIf
	If nVales > 0 
		sTexto := sTexto + 'VALES' + '                      ' + Str(nVales, 15, 2) + ' (+)' + Chr(13) + Chr(10)
	EndIf
	If nFinanc > 0 
		sTexto := sTexto + 'BOLETO' + '                     ' + Str(nFinanc, 15, 2) + ' (+)' + Chr(13) + Chr(10)
	EndIf  
	If nCredito > 0
		sTexto := sTexto + 'CREDITO ' + '                   ' + Str(nCredito, 15, 2) + ' (+)' + Chr(13) + Chr(10)
	EndIf
	If nCarteir > 0
		sTexto := sTexto + 'CARTEIRA ' + '                  ' + Str(nCarteir, 15, 2) + ' (+)' + Chr(13) + Chr(10)
	EndIf
	If nDeposit > 0
		sTexto := sTexto + 'DEP. BANCARIO ' + '             ' + Str(nDeposit, 15, 2) + ' (+)' + Chr(13) + Chr(10)
	EndIf
	If nPIXManu > 0
		sTexto := sTexto + 'PIX Manual ' + '                ' + Str(nPIXManu, 15, 2) + ' (+)' + Chr(13) + Chr(10)
	EndIf
	If nOutros > 0 
		sTexto := sTexto + 'OUTROS' + '                      ' + Str(nOutros, 15, 2) + ' (+)' + Chr(13) + Chr(10)
	EndIf			
	If nAbtoPCC > 0
		sTexto := sTexto + 'RETENCAO PCC'	+ '                   ' + Str(nAbtoPCC, 15, 2) + Chr(13) + Chr(10)
	EndIf
	If nAbtoISS > 0
		sTexto := sTexto + 'RETENCAO ISS'	+ '                   ' + Str(nAbtoISS, 15, 2) + Chr(13) + Chr(10)
	EndIf

	sTexto := sTexto + '-----------------------------------------------' + Chr(13) + Chr(10)

	sTexto := sTexto + '<b><ce>Orcamento: </b></ce>' + AllTrim(SL1->L1_NUM) + Chr(13) + Chr(10)
	sTexto := sTexto + ' ' + Chr(13) + Chr(10)
	sTexto := sTexto + '<b><ce>Cliente:</b></ce> ' +  Alltrim(cNomCli)    + Chr(13) + Chr(10)
	sTexto := sTexto + Replicate("-", nMaxChar)						     + Chr(13) + Chr(10) 
	
	sTexto := sTexto + '<b><ce>Data:</b></ce> ' + DtoC(dDatabase) + ' <b>Hora: </b>' +Time() + Chr(13) + Chr(10)
	sTexto := sTexto + '<b><ce>Vendedor:</b></ce> ' + Alltrim(SL1->L1_VEND)+' - ' +  Alltrim(cNomVen) + Chr(13) + Chr(10)
	sTexto := sTexto + '<b><ce>Caixa:</b></ce> ' + Alltrim(SL1->L1_ESTACAO)+'<b><ce> Operador: </b></ce>' + Alltrim(SL1->L1_OPERADO)+' - ' +  Alltrim(cNomOpe) + Chr(13) + Chr(10)
	sTexto := sTexto + Replicate("-", nMaxChar)						     + Chr(13) + Chr(10)
	sTexto := sTexto + ' ' + Chr(13) + Chr(10)

	sTexto := sTexto + '<b><ce>Observacoes:</b></ce> ' + Chr(13) + Chr(10)

	If !Empty(SL1->L1_XMSGI)
		cMsg    := SL1->L1_XMSGI
		nLinMsg := MLCount(SL1->L1_XMSGI,nMaxChar)

		For nY := 1 To nLinMsg
			sTexto := sTexto + '<ce>' + MemoLine(cMsg,nMaxChar,nY) + '</ce>' + Chr(13) + Chr(10)
		Next nY
		
		sTexto := sTexto + ' ' + Chr(13) + Chr(10)
	EndIf

	STWManagReportPrint(sTexto,1) //Envia comando para a Impressora

Return sTexto

//-------------------------------------------------------------------
/*/{Protheus.doc} RetAbatIss
Retorna o valor de ISS que deve ser abatido do valor total da venda.

@type    Static Function
@author	 Varejo
@since	 03/02/2022
@version P12

@return Numérico, Valor de ISS que deve ser abatido do valor total da venda.
/*/
//-------------------------------------------------------------------
Static Function RetAbatIss()
Local nRet 			:= 0
Local lMvDescISS 	:= SuperGetMV("MV_DESCISS",,.F.)	//Indica se há desconto do ISS no financeiro
Local nMinRetISS  	:= SuperGetMv("MV_VRETISS",.F.,0) 	//Valor minimo para dispensa de retencao de ISS

//Faz a verificação se o valor do ISS deve ser abatido no valor total da venda
If lMvDescISS .And. SL1->L1_VALISS > 0 .And. SL1->L1_RECISS == "1" .And. SA1->A1_RECISS == "1"
	If SA1->A1_FRETISS == "1" //Forma de retencao de ISS (1=Cons Vlr Minimo; 2=Sempre Retem) 
		//Verifica se o valor total do ISS eh maior que o valor minimo para dispensa de retencao de ISS
		If nMinRetISS > 0
			If SL1->L1_VALISS > nMinRetISS
				nRet := SL1->L1_VALISS // Valor do abatimento do ISS
			EndIf
		Else
			nRet := SL1->L1_VALISS // Valor do abatimento do ISS
		EndIf
	Else
		nRet := SL1->L1_VALISS // Valor do abatimento do ISS
	EndIf
EndIf

Return nRet

//-------------------------------------------------------------------
/*/{Protheus.doc} LjIsItISS
Verifica é um item de Servico (ISS)

@type    Static Function
@author	 Varejo
@since	 02/08/2022
@version P12

@return Lógico, Retorna se é um item de Servico (ISS)
/*/
//-------------------------------------------------------------------
Static Function LjIsItISS()
Local lRet 		:= .F.

If SL2->L2_VALISS > 0
	//Se for Totvs PDV e Usa ECF ou se é PAF-ECF, só considera item de servico via importação de orçamento
	If (nModulo == 23 .And. STFGetCfg("lUseECF")) .Or. ;
		STBIsPAF()		//Verifica se é ambiente PAF-ECF								
		lRet := !Empty(SL2->L2_NUMORIG)
	Else
		lRet := .T.
	EndIf
EndIf

Return lRet

/*/{Protheus.doc} SCRPRetPgt
Retorna os valores de cada Forma de Pagamento da venda conforma os valores gravados na SL4
@type  Static Function
@author joao.marcos
@since 26/09/2023
@version version
@return aVlrFormas, arrray, array com os valores de cada Forma de Pagamento
/*/
Static Function SCRPRetPgt()
Local aAreaSL4		:= SL4->(GetArea())
Local aVlrFormas	:= {{"R$",0},;	// 01
						{"CH",0},;	// 02
						{"CC",0},;	// 03
						{"CD",0},;	// 04
						{"PX",0},;	// 05
						{"PD",0},;	// 06
						{"FI",0},;	// 07
						{"CO",0},;	// 08
						{"VA",0},;	// 09
						{"CR",0},;	// 10
						{"CA",0},;	// 11
						{"DB",0},;	// 12
						{"PI",0},;	// 13
						{"OUTRO",0}} // 14

SL4->(dbSetOrder(1))
If SL4->(dbSeek(SL1->L1_FILIAL + SL1->L1_NUM))
	While SL4->(!EOF()) .AND. SL4->L4_FILIAL == SL1->L1_FILIAL .AND. SL4->L4_NUM == SL1->L1_NUM
		Do Case
			Case AllTrim(SL4->L4_FORMA) == "R$"
				aVlrFormas[01][02] += SL4->L4_VALOR
			Case AllTrim(SL4->L4_FORMA) == "CH"
				aVlrFormas[02][02] += SL4->L4_VALOR
			Case AllTrim(SL4->L4_FORMA) == "CC"
				aVlrFormas[03][02] += SL4->L4_VALOR
			Case AllTrim(SL4->L4_FORMA) == "CD"
				aVlrFormas[04][02] += SL4->L4_VALOR
			Case AllTrim(SL4->L4_FORMA) == "PX"
				aVlrFormas[05][02] += SL4->L4_VALOR
			Case AllTrim(SL4->L4_FORMA) == "PD"
				aVlrFormas[06][02] += SL4->L4_VALOR
			Case AllTrim(SL4->L4_FORMA) == "FI"
				aVlrFormas[07][02] += SL4->L4_VALOR
			Case AllTrim(SL4->L4_FORMA) == "CO"
				aVlrFormas[08][02] += SL4->L4_VALOR
			Case AllTrim(SL4->L4_FORMA) == "VA"
				aVlrFormas[09][02] += SL4->L4_VALOR	
			Case AllTrim(SL4->L4_FORMA) == "CR"
				aVlrFormas[10][02] += SL4->L4_VALOR
			Case AllTrim(SL4->L4_FORMA) == "CA"
				aVlrFormas[11][02] += SL4->L4_VALOR
			Case AllTrim(SL4->L4_FORMA) == "DB"
				aVlrFormas[12][02] += SL4->L4_VALOR
			Case AllTrim(SL4->L4_FORMA) == "PI"
				aVlrFormas[13][02] += SL4->L4_VALOR
			Otherwise
				aVlrFormas[14][02] += SL4->L4_VALOR	
		EndCase

		SL4->(dbSkip())
	EndDo
EndIf

RestArea(aAreaSL4)
	
Return aVlrFormas
