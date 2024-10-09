#INCLUDE 'Protheus.ch'
#INCLUDE 'PRTOPDEF.CH'

//---------------------------------------------------------------------------
/*/{PROTHEUS.DOC} LJ7061
PE LJ7061 - Ponto de Entrada chamado para validações na digitação do código 
			do produto na Venda Assitida e antes da impressão concomitante.
@OWNER MADECENTER
@VERSION PROTHEUS 12
@SINCE 24/09/2024
/*/
//---------------------------------------------------------------------------
User Function LJ7061()
	
	Local lRet := .T.
	Local nPosPro := aScan(aHeader, {|x| Alltrim(x[2])=="LR_PRODUTO" })
	Local nPosDes := aScan(aHeader, {|x| Alltrim(x[2])=="LR_DESCRI" })
	Local nPosEnt := aScan(aHeader, {|x| Alltrim(x[2])=="LR_ENTREGA" })
	Local cCodPro := aCOLS[N][nPosPro]
	Local cDescPr := AllTrim(aCOLS[N][nPosDes])
	Local lProdSV := ( AllTrim(Posicione("SB1",1,xFilial("SB1")+cCodPro,"B1_TIPO")) == 'SV' )
	Local nY 

	DeFault lNota := .F.

	For nY := 1 To Len(aCOLS)
<<<<<<< HEAD
		IF nY != N .And. !(aCOLS[N][Len(aCOLS[N])])
=======
		IF nY != N .And. (aCOLS[N][Len(aCOLS[N])])
>>>>>>> f0e877557bc629ff5af504b04e89013a78ac7e8d
			IF aCOLS[nY][nPosPro] == aCOLS[N][nPosPro]
				FWAlertWarning("O Produto " + AllTrim(cCodPro) + " - " + cDescPr +", já foi inserido anteriormente.","Produto")
				lRet := .F.
			EndIF
		EndIF 
	Next 

	IF lRet .And. lProdSV
		aCOLS[N][nPosEnt] := '2'
	EndIF  

	IF lRet .And. lNota
		aCOLS[N][nPosEnt] := '3'
	EndIF 

Return lRet
