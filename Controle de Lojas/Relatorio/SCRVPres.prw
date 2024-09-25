#INCLUDE 'Protheus.ch'
#INCLUDE "TOTVS.CH"
#INCLUDE "RWMAKE.CH"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
��� Fun�ao   � SCRVPres    � Autor � Vendas CLientes    � Data �08/01/2014���
�������������������������������������������������������������������������Ĵ��
��� Descri�ao� Monta o texto a ser impresso no comprovante de venda       ���
���          � (nao fiscal) no caso de venda de VALE PRESENTE.            ���
�������������������������������������������������������������������������Ĵ��
��� Retorno  � Texto a ser impresso                                       ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Sigaloja                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/  
User Function SCRVPres()
	Local nOrcam
	Local sTexto                      
	Local nCheques
	Local nCartao
	Local nConveni
	Local nVales
	Local nFinanc
	Local nCredito		:= 0
	Local nOutros
	Local cQuant 		:= ""
	Local cVrUnit		:= ""
	Local cDesconto		:= ""
	Local cVlrItem		:= ""
	Local nMaxChar 		:= 47 // M�XIMO DE CARACTERES POR LINHA
	Local aFieldSM0     := { ;
							"M0_NOMECOM",;   //Posi��o [1]
							"M0_ENDENT",;    //Posi��o [2]
							"M0_BAIRENT",;   //Posi��o [3]
							"M0_CIDENT",;    //Posi��o [4]
							"M0_ESTENT",;    //Posi��o [5]
							"M0_CEPENT",;    //Posi��o [6]
							"M0_CGC",;       //Posi��o [7]
							"M0_INSC",;      //Posi��o [8]
							"M0_COMPENT",;   //Posi��o [9]
							"M0_TEL";		 //Posi��o [10]
							}        
	Local aSM0Data 		:= FWSM0Util():GetSM0Data(, SL1->L1_FILIAL, aFieldSM0)
	Local cNomCom       := aSM0Data[1,2] // Nome Comercial da Empresa
	Local cEndEnt       := aSM0Data[2,2] // Endere�o de Entrega
	Local cBaiEnt       := aSM0Data[3,2] // Bairro de Entrega
	Local cCidEnt       := aSM0Data[4,2] // Cidade de Entrega
	Local cEstEnt       := aSM0Data[5,2] // Estado de Entrega
	Local cCepEnt       := aSM0Data[6,2] // Cep de Entrega
	Local cCgcEnt       := aSM0Data[7,2] // CNPJ 
	Local cInsEnt       := aSM0Data[8,2] // Inscri��o Estadual
	Local cNomCli       := Posicione("SA1",1,xFILIAL("SA1")+SL1->L1_CLIENTE+SL1->L1_LOJA,"A1_NREDUZ") //Nome do Cliente
	Local cNomVen       := Posicione("SA3",1,xFilial("SA3")+SL1->L1_VEND,"A3_NOME")  // Nome do Vendedor
	Local cNomOpe       := Posicione("SA6",1,xFilial("SA6")+SL1->L1_OPERADO,"A6_NOME")  // Nome do Operador
	Local cValePre      := ""

	sTexto:= '<ce>'+ alltrim(cNomCom) +'</ce>'+ Chr(13)+ Chr(10)
	sTexto:= sTexto +'<ce>'+ alltrim(cEndEnt) + ' - '+ alltrim(cBaiEnt) +'</ce>'+ Chr(13)+ Chr(10)
	sTexto:= sTexto +'<ce>'+ alltrim(cCidEnt) + ' - '+ alltrim(cEstEnt) + ' CEP:'+ alltrim(cCepEnt) +'</ce>'+ Chr(13)+ Chr(10)
	sTexto:= sTexto +'<ce> CNPJ: '+ alltrim(cCgcEnt) + ' IE: '+ alltrim(cInsEnt) +'</ce>'+ Chr(13)+ Chr(10)

	sTexto:= sTexto + Replicate("-", nMaxChar)						   + Chr(13)+ Chr(10)
	sTexto:= sTexto + '<b><ce>COMPROVANTE DE CREDITO CORRENTISTA</ce></b>' 	   + Chr(13)+ Chr(10)
	sTexto:= sTexto + Replicate("-", nMaxChar)						   + Chr(13)+ Chr(10)
	
	sTexto:= 'Codigo         Descricao'+Chr(13)+Chr(10)
	sTexto:= sTexto+ 'Qtd             VlrUnit                 VlrTot'+Chr(13)+Chr(10)
	sTexto:= sTexto+'-----------------------------------------------'+Chr(13)+Chr(10)
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
			
	dbSelectArea("SL2")
	dbSetOrder(1)  
	dbSeek(xFilial("SL2") + nOrcam)
		
	While !SL2->(Eof()) .AND. SL2->L2_FILIAL + SL2->L2_NUM == cFilAnt + nOrcam
		cQuant 		:= StrZero(SL2->L2_QUANT, 8, 3)
		cVrUnit		:= Str(( (SL2->L2_QUANT * SL2->L2_PRCTAB) ) / SL2->L2_QUANT, 15, 2)
		cDesconto	:= Str(SL2->L2_VALDESC, TamSx3("L2_VALDESC")[1], TamSx3("L2_VALDESC")[2])
		cVlrItem	:= Str(Val(cVrUnit) * SL2->L2_QUANT, 15, 2)
		cValePre    := Alltrim(SL2->L2_VALEPRE)

		sTexto		:= sTexto + SL2->L2_PRODUTO + SL2->L2_DESCRI + Chr(13) + Chr(10)
		sTexto		:= sTexto + cQuant + '  ' + cVrUnit + '      ' + cVlrItem + Chr(13) + Chr(10)
		If SL2->L2_VALDESC > 0 
			sTexto	:= sTexto + 'Desconto no Item:              ' + Str(SL2->L2_VALDESC, 15, 2) + Chr(13) + Chr(10)
		EndIf
		SL2->(DbSkip())
	Enddo                      

	If SL1->L1_DESCONTO > 0
		sTexto	:= sTexto + 'Desconto no Total:             ' + Str(SL1->L1_DESCONTO, 15, 2) + Chr(13) + Chr(10)
	EndIf                                                                              
	If SL1->L1_JUROS > 0
		sTexto	:= sTexto + 'Acrescimo no Total:            ' + Transform(SL1->L1_JUROS, "@R 99.99%") + Chr(13) + Chr(10)
	EndIf

	sTexto	:= sTexto + '-----------------------------------------------' + Chr(13) + Chr(10)
	sTexto	:= sTexto + 'TOTAL                         ' + Str(SL1->L1_VLRLIQ, 15, 2) + Chr(13) + Chr(10)

	If nDinheir > 0 
		sTexto := sTexto + 'DINHEIRO' + '                       ' + Str(nDinheir, 15, 2) + Chr(13) + Chr(10)
	EndIf
	If nCheques > 0 
		sTexto := sTexto + 'CHEQUE' + '                         ' + Str(nCheques, 15, 2) + Chr(13) + Chr(10)
	EndIf
	If nCartao > 0 
		sTexto := sTexto + 'CARTAO' + '                          ' + Str(nCartao, 15, 2) + Chr(13) + Chr(10)
	EndIf
	If nConveni > 0 
		sTexto := sTexto + 'CONVENIO' + '                        ' + Str(nConveni, 15, 2) + Chr(13) + Chr(10)
	EndIf
	If nVales > 0 
		sTexto := sTexto + 'VALES' + '                           ' + Str(nVales, 15, 2) + Chr(13) + Chr(10)
	EndIf
	If nFinanc > 0 
		sTexto := sTexto + 'FINANCIADO' + '                      ' + Str(nFinanc, 15, 2) + Chr(13) + Chr(10)
	EndIf  
	If nCredito > 0
		sTexto := sTexto + 'CREDITO ' + '                       ' + Str(nCredito, 15, 2) + Chr(13) + Chr(10)
	EndIf			
				
	sTexto := sTexto + '-----------------------------------------------' + Chr(13) + Chr(10)

	sTexto := sTexto + '<b>Codigo Vale: </b>' + cValePre + Chr(13) + Chr(10)
	sTexto := sTexto + ' ' + Chr(13) + Chr(10)
	sTexto := sTexto + '<b>Orcamento: </b>' + AllTrim(SL1->L1_NUM) + Chr(13) + Chr(10)
	sTexto := sTexto + ' ' + Chr(13) + Chr(10)
	sTexto := sTexto + '<b>Cliente:</b> ' +  Alltrim(cNomCli)    + Chr(13) + Chr(10)
	sTexto := sTexto + Replicate("-", nMaxChar)						     + Chr(13) + Chr(10) 
	
	sTexto := sTexto + '<b>Data:</b> ' + DtoC(dDatabase) + ' <b>Hora: </b>' +Time() + Chr(13) + Chr(10)
	sTexto := sTexto + '<b>Vendedor:</b> ' + Alltrim(SL1->L1_VEND)+' - ' +  Alltrim(cNomVen) + Chr(13) + Chr(10)
	sTexto := sTexto + '<b>Caixa:</b> ' + Alltrim(SL1->L1_ESTACAO)+'<b> Operador: </b>' + Alltrim(SL1->L1_OPERADO)+' - ' +  Alltrim(cNomOpe) + Chr(13) + Chr(10)
	sTexto := sTexto + Replicate("-", nMaxChar)						     + Chr(13) + Chr(10)
	sTexto := sTexto + ' ' + Chr(13) + Chr(10)

Return sTexto
