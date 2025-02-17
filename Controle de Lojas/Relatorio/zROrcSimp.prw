//Bibliotecas
#Include "Protheus.ch"
#Include "Totvs.ch"
#Include "TopConn.ch"
#Include "RPTDef.ch"
#Include "FWPrintSetup.ch"

// CONSTANTES NECESSÁRIAS
#Define ENTER  Chr(10) // SALTO DE LINHA (CARRIAGE RETURN)
#Define TAB    Chr(9)  // TABULAÇÃO (TAB)
#Define BULLET Chr(7)  // TÓPICO (BULLET POINT)

//Variaveis utilizadas no fonte inteiro
Static nPadLeft   := 0                                  //Alinhamento a Esquerda
Static nPadRight  := 1                                  //Alinhamento a Direita
Static nPadCenter := 2                                  //Alinhamento Centralizado
Static nPosCod    := 0000                               //Posição Inicial da Coluna de Código do Produto 
Static nPosDesc   := 0000                               //Posição Inicial da Coluna de Descrição
Static nPosUnid   := 0000                               //Posição Inicial da Coluna de Unidade de Medida
Static nPosUnid2  := 0000                               //Posição Inicial da Coluna de Unidade de Medida
Static nPosQuan   := 0000                               //Posição Inicial da Coluna de Quantidade
Static nPosQuan2  := 0000                               //Posição Inicial da Coluna de Quantidade
Static nPosVlIP   := 0000                               //Posição Inicial da Coluna de Valor do IPI
Static nPosVlST   := 0000                               //Posição Inicial da Coluna de Valor do ICMS ST
Static nPosVUni   := 0000                               //Posição Inicial da Coluna de Valor Unitario
Static nPosVDes   := 0000                               //Posição Inicial da Coluna de Valor Desconto
Static nPosVTot   := 0000                               //Posição Inicial da Coluna de Valor Total
Static nPosPacot  := 0000                               //Posição Inicial da Coluna de Quantidade do pacote
Static nPosVM2    := 0000                               //Posição Inicial da Coluna de Valor do ICMS
Static nPosIPI    := 0000                               //Posição Inicial da Coluna de Valor do IPI
Static nTamFundo  := 15                                 //Altura de fundo dos blocos com Titulo
Static nCorAzul   := RGB(89, 111, 117)                  //Cor Azul usada nos Titulos
Static cNomeFont  := "Arial"                            //Nome da Fonte padrao
Static oFontDet   := Nil                                //Fonte utilizada na impressao dos itens
Static oFontDetN  := Nil                                //Fonte utilizada no cabeçalho dos itens
Static oFontRod   := Nil                                //Fonte utilizada no rodape da Pagina
Static oFontTit   := Nil                                //Fonte utilizada no Titulo das seções
Static oFontCab   := Nil                                //Fonte utilizada na impressao dos textos dentro das seções
Static oFontCabE  := Nil                                //Fonte utilizada na impressao dos textos dentro das seções
Static oFontCabN  := Nil                                //Fonte negrita utilizada na impressao dos textos dentro das seções
Static oFontObs   := Nil                                //Fonte utilizada na impressao dos textos dentro das observações
Static oFontObsN  := Nil                                //Fonte utilizada na impressao dos textos dentro das observações
Static cMaskPad   := "@E 999,999.99"                    //Mascara padrao de valor
Static cMaskCNPJ  := "@R 99.999.999/9999-99"            //Mascara de CNPJ
Static cMaskCEP   := "@R 99999-999"                     //Mascara de CEP
Static cMaskCPF   := "@R 999.999.999-99"                //Mascara de CPF
Static cMaskQtd   := "@E 99,999,999,999.99"             //Mascara de quantidade
Static cMaskPrc   := "@E 99,999,999,999.99"             //Mascara de preço
Static cMaskVlr   := "@E 99,999,999,999.99"             //Mascara de valor

/*/{Protheus.doc} zROrcSimp
impressao Grafica generica de Orçamento de Venda (em pdf)
@type function
@author Elvis Siqueira
@since 30/08/2024
@version 1.0
	@example
	u_zROrcSimp()
/*/

User Function zROrcSimp()
Local aArea      := GetArea()
Local aAreaL1    := SL1->(GetArea())
Local oProcess   := Nil

Private cLogoEmp := fLogoEmp()
Private cPedido  := SL1->L1_NUM
Private nQdtTot  := 0
Private nVUnTot  := 0
Private nDescont := 0
Private nIPITot  := 0
	
	fLayout()
		
	oProcess := MsNewProcess():New({|| fMontaRel(@oProcess) }, "Impressao Orçamentos de Venda", "Processando", .F.)
	oProcess:Activate()

	RestArea(aAreaL1)
	RestArea(aArea)
Return

/*---------------------------------------------------------------------*
 | Func:  fLayout                                                       |
 | Desc:  Função que monta as variáveis das colunas do layout           |
 *---------------------------------------------------------------------*/

Static Function fLayout()
	oFontRod   := TFont():New(cNomeFont, , -10, , .F.)
	oFontTit   := TFont():New(cNomeFont, , -12, , .T.)
	oFontCab   := TFont():New(cNomeFont, , -10, , .F.)
	oFontCabE  := TFont():New(cNomeFont, , -09, , .F.)
	oFontCabN  := TFont():New(cNomeFont, , -10, , .T.)
	oFontDet   := TFont():New(cNomeFont, , -10, , .F.)
	oFontDetN  := TFont():New(cNomeFont, , -10, , .T.)
	oFontObs   := TFont():New(cNomeFont, , -11, , .F.)
	oFontObsN  := TFont():New(cNomeFont, , -11, , .T.)

	nPosCod   := 0010 // Codigo do Produto
	nPosDesc  := 0060 // Descricao
	nPosUnid  := 0280 // 1ª Unidade de Medida 
	nPosQuan  := 0320 // Quantidade 1ª UM
	nPosVTot  := 0520 // Valor Total
Return

/*---------------------------------------------------------------------*
 | Func:  fMontaRel                                                    |
 | Desc:  Função principal que monta o relatorio                       |
 *---------------------------------------------------------------------*/

Static Function fMontaRel(oProc)
	//Variaveis usada no controle das réguas
	Local nTotIte       := 0
	Local nItAtu        := 0
	Local nTotPed       := 0
	Local nPedAtu       := 0
	//Consultas SQL
	Local cQryPed       := ""
	Local cQryIte       := ""
	//Variaveis do relatorio
	Local cNomeRel      := "Orçamento_venda_"+FunName()+"_"+__cUserID+"_"+dToS(Date())+"_"+StrTran(Time(), ":", "-")
	Local nVUnit        := 0
	Local nVlrItem      := 0
	
	Private oPrintPvt
	Private cHoraEx     := Time()
	Private nPagAtu     := 1
	Private aDuplicatas := {}
	//Linhas e colunas
	Private nLinAtu     := 0
	Private nLinFin     := 780
	Private nColIni     := 010
	Private nColFin     := 550
	Private nColMeio    := (nColFin-nColIni)/2
	//Totalizadores
	Private nTotFrete   := 0
	Private nTotDesp    := 0
	Private nValorTot   := 0
	Private nTotVal     := 0
	Private nTotIPI     := 0
	Private nVSTTot     := 0
	
	DbSelectArea("SB1")
	SB1->(DbSetOrder(1)) //B1_FILIAL+B1_COD
	SB1->(DbGoTop())
	DbSelectArea("SL1")
	
	//Criando o objeto de impressao
	oPrintPvt:= FWMSPrinter():New(cNomeRel, IMP_PDF, .F., /*cStartPath*/, .T., , @oPrintPvt, , , , , .T.)
	oPrintPvt:cPathPDF := GetTempPath()
	oPrintPvt:SetResolution(72)
	oPrintPvt:SetPortrait()
	oPrintPvt:SetPaperSize(DMPAPER_A4)
	oPrintPvt:SetMargin(60, 60, 60, 60)
	
	//Selecionando os Orçamentos
	cQryPed := " SELECT "           + CRLF
	cQryPed += "    L1_FILIAL, "    + CRLF
	cQryPed += "    L1_NUM, "       + CRLF
	cQryPed += "    L1_EMISSAO, "   + CRLF
	cQryPed += "    L1_CLIENTE, "   + CRLF
	cQryPed += "    L1_LOJA, "      + CRLF
	cQryPed += "    A1_NOME, "     	+ CRLF
	cQryPed += "    A1_NREDUZ, "    + CRLF
	cQryPed += "    A1_PESSOA, "    + CRLF
	cQryPed += "    A1_CGC, "       + CRLF
	cQryPed += "    A1_END, "       + CRLF
	cQryPed += "    A1_BAIRRO, "    + CRLF
	cQryPed += "    A1_MUN, "       + CRLF
	cQryPed += "    A1_EST, "       + CRLF
	cQryPed += "    A1_DDD, "       + CRLF
	cQryPed += "    A1_TEL, "       + CRLF
	cQryPed += "    A1_EMAIL, "     + CRLF
	cQryPed += "    L1_TABELA, "    + CRLF
	cQryPed += "    L1_COND, "      + CRLF
	cQryPed += "    L1_TRANSP, "    + CRLF
	cQryPed += "    L1_VEND, "      + CRLF
	cQryPed += "    A3_NREDUZ, "    + CRLF
	cQryPed += "    A3_DDDTEL, "    + CRLF
	cQryPed += "    A3_TEL, "       + CRLF
	cQryPed += "    A3_EMAIL, "     + CRLF
	cQryPed += "    L1_VLRLIQ, "    + CRLF
	cQryPed += "    L1_TPFRET, "    + CRLF
	cQryPed += "    L1_FRETE, "     + CRLF
	cQryPed += "    L1_PBRUTO, "    + CRLF
	cQryPed += "    L1_MENNOTA, "   + CRLF
	cQryPed += "    L1_DESCONT, "   + CRLF
	cQryPed += "    L1_VALMERC, "   + CRLF
	cQryPed += "    SL1.R_E_C_N_O_ AS L1REC "                    + CRLF
	cQryPed += " FROM "                                          + CRLF
	cQryPed += "    "+RetSQLName("SL1")+" SL1 "                  + CRLF
	cQryPed += "    LEFT JOIN "+RetSQLName("SA1")+" SA1 ON ( "   + CRLF
	cQryPed += "        A1_FILIAL   = '"+FWxFilial("SA1")+"' "   + CRLF
	cQryPed += "        AND A1_COD  = SL1.L1_CLIENTE "           + CRLF
	cQryPed += "        AND A1_LOJA = SL1.L1_LOJA "              + CRLF
	cQryPed += "        AND SA1.D_E_L_E_T_ = ' ' "               + CRLF
	cQryPed += "    ) "                                          + CRLF
	cQryPed += "    LEFT JOIN "+RetSQLName("SE4")+" SE4 ON ( "   + CRLF
	cQryPed += "        E4_FILIAL     = '"+FWxFilial("SE4")+"' " + CRLF
	cQryPed += "        AND E4_CODIGO = SL1.L1_COND "            + CRLF
	cQryPed += "        AND SE4.D_E_L_E_T_ = ' ' "               + CRLF
	cQryPed += "    ) "                                          + CRLF
	cQryPed += "    LEFT JOIN "+RetSQLName("SA3")+" SA3 ON ( "   + CRLF
	cQryPed += "        A3_FILIAL  = '"+FWxFilial("SA3")+"' "    + CRLF
	cQryPed += "        AND A3_COD = SL1.L1_VEND "               + CRLF
	cQryPed += "        AND SA3.D_E_L_E_T_ = ' ' "               + CRLF
	cQryPed += "    ) "                                          + CRLF
	cQryPed += " WHERE "                                         + CRLF
	cQryPed += "    L1_FILIAL   = '"+FWxFilial("SL1")+"' "       + CRLF
	cQryPed += "    AND L1_NUM  = '"+cPedido+"' "                + CRLF
	cQryPed += "    AND SL1.D_E_L_E_T_ = ' ' "                   + CRLF
	TCQuery cQryPed New Alias "QRY_PED"
	TCSetField("QRY_PED", "L1_EMISSAO", "D")
	Count To nTotPed
	oProc:SetRegua1(nTotPed)
	
	//Somente se houver Orçamentos
	If nTotPed != 0
	
		//Enquanto houver Orçamentos
		QRY_PED->(DbGoTop())
		While ! QRY_PED->(EoF())
			nPedAtu++
			oProc:IncRegua1("Processando o Orçamento "+cValToChar(nPedAtu)+" de "+cValToChar(nTotPed)+"...")
			oProc:SetRegua2(1)
			oProc:IncRegua2("...")
			
			//Imprime o cabeçalho
			fImpCab()
			
			//Inicializa os calculos de impostos
			nItAtu   := 0
			nTotIte  := 0
			nVSTTot  := 0
			nTotIPI  := 0
			SL1->(DbGoTo(QRY_PED->L1REC))
			MaFisIni(SL1->L1_CLIENTE,;                   // 01 - Codigo Cliente/Fornecedor
				SL1->L1_LOJA,;                           // 02 - Loja do Cliente/Fornecedor
				Iif(SL1->L1_TIPO $ "D;B", "F", "C"),;    // 03 - C:Cliente , F:Fornecedor
				SL1->L1_TIPO,;                           // 04 - Tipo da NF
				SL1->L1_TIPOCLI,;                        // 05 - Tipo do Cliente/Fornecedor
				MaFisRelImp("MT100", {"SF2", "SD2"}),;   // 06 - Relacao de Impostos que suportados no arquivo
				,;                                       // 07 - Tipo de complemento
				,;                                       // 08 - Permite Incluir Impostos no Rodape .T./.F.
				"SB1",;                                  // 09 - Alias do Cadastro de Produtos - ("SBI" P/ Front Loja)
				"MATA461")                               // 10 - Nome da rotina que esta utilizando a funcao
			
			//Seleciona agora os itens do Orçamento
			cQryIte := " SELECT "                                                 + CRLF
			cQryIte += "    L2_PRODUTO, "                                         + CRLF
			cQryIte += "    L2_CODBAR, "                                          + CRLF
			cQryIte += "    B1_DESC, "						                      + CRLF
			cQryIte += "    L2_UM, "                                              + CRLF
			cQryIte += "    L2_SEGUM, "                                           + CRLF
			cQryIte += "    L2_ENTREGA, "                                         + CRLF
			cQryIte += "    L2_TES, "                                             + CRLF
			cQryIte += "    L2_QUANT, "                                           + CRLF
			cQryIte += "    L2_VRUNIT, "                                          + CRLF
			cQryIte += "    L2_PRCTAB, "                                          + CRLF
			cQryIte += "    L2_VALDESC, "                                         + CRLF
			cQryIte += "    L2_DESCPRO, "                                         + CRLF
			cQryIte += "    L2_DOC, "                                             + CRLF
			cQryIte += "    L2_SERIE, "                                           + CRLF
			cQryIte += "    L2_VLRITEM, "                                         + CRLF
			cQryIte += "    L2_VALIPI, "                                          + CRLF
			cQryIte += "    L2_ICMSRET, "                                         + CRLF
			cQryIte += "    L2_VALDESC "                                          + CRLF
			cQryIte += " FROM "                                                   + CRLF
			cQryIte += "    "+RetSQLName("SL2")+" SL2 "                           + CRLF
			cQryIte += "    LEFT JOIN "+RetSQLName("SB1")+" SB1 ON ( "            + CRLF
			cQryIte += "        B1_FILIAL = '"+FWxFilial("SB1")+"' "              + CRLF
			cQryIte += "        AND B1_COD = SL2.L2_PRODUTO "                     + CRLF
			cQryIte += "        AND SB1.D_E_L_E_T_ = ' ' "                        + CRLF
			cQryIte += "    ) "                                                   + CRLF
			cQryIte += " WHERE "                                                  + CRLF
			cQryIte += "    L2_FILIAL = '"+FWxFilial("SL2")+"' "                  + CRLF
			cQryIte += "    AND L2_NUM = '"+QRY_PED->L1_NUM+"' "                  + CRLF
			cQryIte += "    AND SL2.D_E_L_E_T_ = ' ' "                            + CRLF
			cQryIte += " ORDER BY "                                               + CRLF
			cQryIte += "    L2_ITEM "                                             + CRLF
			TCQuery cQryIte New Alias "QRY_ITE"
			
			TCSetField("QRY_ITE", "L2_ENTREGA", "D")
			
			Count To nTotIte

			nValorTot := 0

			oProc:SetRegua2(nTotIte)
			
			//Enquanto houver itens
			QRY_ITE->(DbGoTop())

			oProc:IncRegua2("...")
			oProc:SetRegua2(nTotIte)
			
			QRY_ITE->(DbGoTop())

			nItAtu   := 0

			While ! QRY_ITE->(EoF())
				nItAtu++
				oProc:IncRegua2("Imprimindo item "+cValToChar(nItAtu)+" de "+cValToChar(nTotIte)+"...")
				
				nQdtTot  += QRY_ITE->L2_QUANT
				nVUnTot  += QRY_ITE->L2_PRCTAB + (QRY_ITE->L2_VALIPI / QRY_ITE->L2_QUANT)
				nVSTTot  += QRY_ITE->L2_ICMSRET
				nDescont += QRY_ITE->L2_VALDESC
				nIPITot  += QRY_ITE->L2_VALIPI
				nValorTot += ((QRY_ITE->L2_PRCTAB * QRY_ITE->L2_QUANT) + QRY_ITE->L2_ICMSRET + QRY_ITE->L2_VALIPI) - QRY_ITE->L2_VALDESC

				nVUnit   := QRY_ITE->L2_PRCTAB + (QRY_ITE->L2_VALIPI / QRY_ITE->L2_QUANT)
				nVlrItem := ((QRY_ITE->L2_PRCTAB * QRY_ITE->L2_QUANT) + QRY_ITE->L2_ICMSRET + QRY_ITE->L2_VALIPI) - QRY_ITE->L2_VALDESC

				oPrintPvt:SayAlign(nLinAtu, nPosCod,   Alltrim(QRY_ITE->L2_PRODUTO),                      	oFontDet, 200, 07, , nPadLeft,)
				oPrintPvt:SayAlign(nLinAtu, nPosDesc,  SubStr(Alltrim(QRY_ITE->B1_DESC),1,40),             	oFontDet, 300, 07, , nPadLeft,)
				oPrintPvt:SayAlign(nLinAtu, nPosUnid,  QRY_ITE->L2_UM,                                    	oFontDet, 100, 07, , nPadLeft,)
				oPrintPvt:SayAlign(nLinAtu, nPosQuan,  Alltrim(Transform(QRY_ITE->L2_QUANT, cMaskQtd)),   	oFontDet, 100, 07, , nPadLeft,)
				nLinAtu += 10

				//Se por acaso atingiu o limite da Pagina, finaliza, e começa uma nova Pagina
				If nLinAtu >= nLinFin
					fImpRod()
					fImpCab()
				EndIf

				QRY_ITE->(DbSkip())
			EndDo

			nTotFrete := MaFisRet(, "NF_FRETE")
			nTotDesp  := MaFisRet(, "NF_DESPESA")
			nTotVal   := MaFisRet(, "NF_TOTAL")

			QRY_ITE->(DbCloseArea())
			MaFisEnd()
			
			//Imprime o total do Orçamento
			fImpTot()
			
			//Imprime as duplicatas
			fImpDupl()
			
			//Mensagem de observação
			fMsgObs()

			//Imprime o rodapé
			fImpRod()
			
			QRY_PED->(DbSkip())
		EndDo
		
		//Gera o pdf para visualização
		oPrintPvt:Preview()
	
	Else
		MsgStop("Nao há Orçamentos!", "Atenção")
	EndIf
	QRY_PED->(DbCloseArea())
Return

/*---------------------------------------------------------------------*
 | Func:  fImpCab                                                      |
 | Desc:  Função que imprime o cabeçalho                               |
 *---------------------------------------------------------------------*/

Static Function fImpCab()
	Local nLinCab     := 025
	Local nLinCabOrig := nLinCab
	Local lCNPJ       := (QRY_PED->A1_PESSOA != "F")
	Local cCliAux     := QRY_PED->L1_CLIENTE+"/"+QRY_PED->L1_LOJA+" - "+QRY_PED->A1_NOME
	Local cCGC        := ""
	Local cTipoOrc    := ""
	Local aCamposEmp  := {'M0_NOMECOM',;
						  'M0_CGC'    ,;
						  'M0_INSC'   ,;
						  'M0_ENDENT' ,;
						  'M0_BAIRENT',;
						  'M0_CIDENT' ,;
						  'M0_ESTENT' ,;
						  'M0_CEPENT' ,;
						  'M0_TEL'}
	Local aDadosEmp   := FWSM0Util():GetSM0Data(cEmpAnt,cFilAnt,aCamposEmp)
	
	//Iniciando Pagina
	oPrintPvt:StartPage()
	
	//Logo
	oPrintPvt:Box(nLinCab, nColIni, nLinCab+100, 100)
	oPrintPvt:SayBitmap(nLinCab+3, nColIni+5, cLogoEmp, 070, 070)      

	//Dados da Empresa
	oPrintPvt:Box(nLinCab, 100, nLinCab+100, 480)
	nLinCab += 010                                                      
	oPrintPvt:SayAlign(nLinCab,   nColIni+100, aDadosEmp[1][2],        	    					oFontCabN,  500, 07, , nPadLeft, )
	nLinCab += 015                                                      
	oPrintPvt:SayAlign(nLinCab,   nColIni+100, "CNPJ: "+Transform(aDadosEmp[2][2],cMaskCNPJ),  	oFontCabE,   500, 07, , nPadLeft, )
	oPrintPvt:SayAlign(nLinCab,   nColIni+185, " - IE: " + aDadosEmp[3][2],         			oFontCabE,   500, 07, , nPadLeft, )
	nLinCab += 010                                                      
	oPrintPvt:SayAlign(nLinCab,   nColIni+100, Alltrim(aDadosEmp[4][2])+", "+;
											   Alltrim(aDadosEmp[5][2])+", "+;
											   Alltrim(aDadosEmp[6][2])+" - "+;
											   Alltrim(aDadosEmp[7][2]),						oFontCabE,   500, 07, , nPadLeft, )
	nLinCab += 010                                                      
	oPrintPvt:SayAlign(nLinCab,   nColIni+100, "CEP: "+ Transform(aDadosEmp[8][2],cMaskCEP),	oFontCabE,   500, 07, , nPadLeft, )
	nLinCab += 010                                                      
	oPrintPvt:SayAlign(nLinCab,   nColIni+100, "Fone: "+aDadosEmp[9][2],    					oFontCabE,   500, 07, , nPadLeft, )                                                     
	
	nLinCab := nLinCabOrig
	
	//Nº do Orçamento / Tipo / Data de Emissão
	oPrintPvt:Box(nLinCab, nColIni+450, nLinCabOrig+100, nColFin)
	nLinCab += 010
	oPrintPvt:SayAlign(nLinCab, nColIni+453,  "Nº Orçamento:",                          oFontCabN, 200, 07, , nPadLeft, )
	nLinCab += 010
	oPrintPvt:SayAlign(nLinCab, nColIni+470, QRY_PED->L1_NUM,                           oFontCab,  200, 07, , nPadLeft, )
	nLinCab += 015
	
	DbSelectArea("SL2")
	IF SL2->(MsSeek(xFilial("SL2")+SL1->L1_NUM))
	Do Case
		Case SL2->L2_ENTREGA $("1/4")
			cTipoOrc := "Retira Posterior"
		Case SL2->L2_ENTREGA $("3/5")
			cTipoOrc := "Entrega"
		Case SL2->L2_ENTREGA == "2"
			cTipoOrc := "Retira"
	EndCase
	oPrintPvt:SayAlign(nLinCab, nColIni+453,  "Tipo: ",      			            oFontCabN, 200, 07, , nPadLeft, )
	oPrintPvt:SayAlign(nLinCab, nColIni+475, cTipoOrc,                        		oFontCab,  200, 07, , nPadLeft, )
	EndIF 
	nLinCab += 015
	
	oPrintPvt:Line(nLinCab, nColIni+450, nLinCab, nColFin)
	oPrintPvt:SayAlign(nLinCab, nColIni+453,  "Dt.Emissao:",                            oFontCabN, 200, 07, , nPadLeft, )
	nLinCab += 010
	oPrintPvt:SayAlign(nLinCab, nColIni+470, dToC(QRY_PED->L1_EMISSAO),                 oFontCab,  200, 07, , nPadLeft, )
	
	nLinCab := nLinCabOrig
	nLinCab += 075

	//Dados do Cliente
	oPrintPvt:Box(nLinCab, nColIni, nLinCab+070, nColFin)
	nLinCab += nTamFundo - 5
	oPrintPvt:SayAlign(nLinCab-10, nColIni+5,  "Dados do cliente",		                    oFontTit,  200, nTamFundo, nCorAzul, nPadLeft, )
	nLinCab += 002
	oPrintPvt:Line(nLinCab, nColIni, nLinCab, nColFin)
	nLinCab += 005
	oPrintPvt:SayAlign(nLinCab,    nColIni+5,  "Cliente:",                                  oFontCabN, 200, 07, , nPadLeft, )
	oPrintPvt:SayAlign(nLinCab,    nColIni+40, cCliAux,                                     oFontCab, 500, 07, , nPadLeft, )
	nLinCab += 010
	oPrintPvt:SayAlign(nLinCab,    nColIni+5,  "Nome Fantasia: ",                           oFontCabN, 200, 07, , nPadLeft, )
	oPrintPvt:SayAlign(nLinCab,    nColIni+70, QRY_PED->A1_NREDUZ,     	                    oFontCab, 500, 07, , nPadLeft, )
	nLinCab += 010
	cCGC := QRY_PED->A1_CGC
	If lCNPJ
		cCGC := Iif(!Empty(cCGC), Alltrim(Transform(cCGC, cMaskCNPJ)), "-")
		oPrintPvt:SayAlign(nLinCab, nColIni+5, "CNPJ:",                                     oFontCabN, 200, 07, , nPadLeft, )
	Else
		cCGC := Iif(!Empty(cCGC), Alltrim(Transform(cCGC, cMaskCPF)), "-")
		oPrintPvt:SayAlign(nLinCab, nColIni+5, "CPF:",                                      oFontCabN, 200, 07, , nPadLeft, )
	EndIf
	oPrintPvt:SayAlign(nLinCab, nColIni+30, cCGC,                                           oFontCab,  500, 07, , nPadLeft, )
	nLinCab += 010
	oPrintPvt:SayAlign(nLinCab, nColIni+5, "Endereco:",	                                    oFontCabN, 200, 07, , nPadLeft, )
	oPrintPvt:SayAlign(nLinCab, nColIni+050, Alltrim(QRY_PED->A1_END)+", "+;
											 Alltrim(QRY_PED->A1_BAIRRO)+", "+;
											 Alltrim(QRY_PED->A1_MUN)+" - "+;
											 Alltrim(QRY_PED->A1_EST),			 			oFontCab,  500, 07, , nPadLeft, )
	nLinCab += 010
	oPrintPvt:SayAlign(nLinCab, nColIni+5, "Telefone:",	                                    oFontCabN, 200, 07, , nPadLeft, )
	oPrintPvt:SayAlign(nLinCab, nColIni+043,Alltrim(QRY_PED->A1_DDD)+" "+;
											Alltrim(QRY_PED->A1_TEL),						oFontCab,  500, 07, , nPadLeft, )
	oPrintPvt:SayAlign(nLinCab, nColIni+120, "E-mail:",		                                oFontCabN, 200, 07, , nPadLeft, )
	oPrintPvt:SayAlign(nLinCab, nColIni+150, QRY_PED->A1_EMAIL,		 						oFontCab,  500, 07, , nPadLeft, )
	
	nLinCab := nLinCabOrig
	nLinCab += 145

	//Dados do Orçamento
	oPrintPvt:Box(nLinCab, nColIni, nLinCab+040, nColFin)
	nLinCab += nTamFundo - 5
	oPrintPvt:SayAlign(nLinCab-10, nColIni+5,  "Dados do orçamento",		                    oFontTit,  200, nTamFundo, nCorAzul, nPadLeft, )
	nLinCab += 002
	oPrintPvt:Line(nLinCab, nColIni, nLinCab, nColFin)
	nLinCab += 005
	oPrintPvt:SayAlign(nLinCab, nColIni+5, "Vendedor:",                                     oFontCabN, 200, 07, , nPadLeft, )
	oPrintPvt:SayAlign(nLinCab, nColIni+50, QRY_PED->L1_VEND + " - "+QRY_PED->A3_NREDUZ,    oFontCab,  500, 07, , nPadLeft, )
	nLinCab += 010
	oPrintPvt:SayAlign(nLinCab, nColIni+5, "Telefone:",	                                    oFontCabN, 200, 07, , nPadLeft, )
	oPrintPvt:SayAlign(nLinCab, nColIni+043,Alltrim(QRY_PED->A3_DDDTEL)+" "+;
											Alltrim(QRY_PED->A3_TEL),						oFontCab,  500, 07, , nPadLeft, )
	oPrintPvt:SayAlign(nLinCab, nColIni+120, "E-mail:",		                                oFontCabN, 200, 07, , nPadLeft, )
	oPrintPvt:SayAlign(nLinCab, nColIni+150, QRY_PED->A3_EMAIL,		 						oFontCab,  500, 07, , nPadLeft, )

	nLinCab := nLinCabOrig
	nLinCab += 215

	//Produtos
	oPrintPvt:SayAlign(nLinCab-10, nColIni,  "Produtos", oFontTit,  200, nTamFundo, nCorAzul, nPadLeft, )
	nLinCab += 002
	oPrintPvt:Line(nLinCab, nColIni, nLinCab, nColFin)
	nLinCab += 002
	oPrintPvt:SayAlign(nLinCab, nPosCod,   "Código", 		oFontDetN, 200, 07,, nPadLeft,)
	oPrintPvt:SayAlign(nLinCab, nPosDesc,  "Descricao", 	oFontDetN, 200, 07,, nPadLeft,)
	oPrintPvt:SayAlign(nLinCab, nPosUnid,  "UM",    		oFontDetN, 200, 07,, nPadLeft,)
	oPrintPvt:SayAlign(nLinCab, nPosQuan,  "Qtd.", 			oFontDetN, 200, 07,, nPadLeft,)
	
	//Atualizando a linha inicial do relatorio
	nLinAtu := nLinCab + 020
Return

/*---------------------------------------------------------------------*
 | Func:  fImpRod                                                      |
 | Desc:  Função que imprime o rodape                                  |
 *---------------------------------------------------------------------*/

Static Function fImpRod()
	Local nLinRod:= nLinFin + 10
	Local cTexto := ""

	//Linha Separatória
	oPrintPvt:Line(nLinRod, nColIni, nLinRod, nColFin)
	nLinRod += 3
	
	//Dados da Esquerda
	cTexto := "Orçamento: "+QRY_PED->L1_NUM+"    |    "+dToC(dDataBase)+"     "+cHoraEx+"     "+cModulo+"     "+cUserName
	oPrintPvt:SayAlign(nLinRod, nColIni,    cTexto, oFontRod, 250, 07, , nPadLeft, )
	
	//Direita
	cTexto := "Pagina "+cValToChar(nPagAtu)
	oPrintPvt:SayAlign(nLinRod, nColFin-40, cTexto, oFontRod, 040, 07, , nPadRight, )
	
	//Finalizando a Pagina e somando mais um
	oPrintPvt:EndPage()
	nPagAtu++
Return

/*---------------------------------------------------------------------*
 | Func:  fLogoEmp                                                     |
 | Desc:  Função que retorna o logo da empresa (igual a DANFE)         |
 *---------------------------------------------------------------------*/

Static Function fLogoEmp()
	Local cGrpCompany := AllTrim(FWGrpCompany())
	Local cCodEmpGrp  := AllTrim(FWCodEmp())
	Local cUnitGrp    := AllTrim(FWUnitBusiness())
	Local cFilGrp     := AllTrim(FWFilial())
	Local cLogo       := ""
	Local cCamFim     := GetTempPath()
	Local cStart      := GetSrvProfString("Startpath", "")

	//Se tiver filiais por grupo de empresas
	If !Empty(cUnitGrp)
		cDescLogo := cGrpCompany + cCodEmpGrp + cUnitGrp + cFilGrp
		
	//SeNao, será apenas, empresa + filial
	Else
		cDescLogo	:= cEmpAnt + cFilAnt
	EndIf
	
	//Pega a imagem
	cLogo := cStart + "LGMID" + cDescLogo + ".PNG"
	
	//Se o arquivo Nao existir, pega apenas o da empresa, desconsiderando a filial
	If !File(cLogo)
		cLogo := cStart + "LGMID" + cEmpAnt + ".PNG"
	EndIf
	
	//Copia para a temporária do s.o.
	CpyS2T(cLogo, cCamFim)
	cLogo := cCamFim + StrTran(cLogo, cStart, "")
	
	//Se o arquivo Nao existir na temporária, espera meio segundo para terminar a cópia
	If !File(cLogo)
		Sleep(500)
	EndIf
Return cLogo

/*---------------------------------------------------------------------*
 | Func:  fImpTot                                                      |
 | Desc:  Função para imprimir os totais                               |
 *---------------------------------------------------------------------*/

Static Function fImpTot()
	nLinAtu += 4
	
	//Se atingir o fim da Pagina, quebra
	If nLinAtu + 50 >= nLinFin
		fImpRod()
		fImpCab()
	EndIf
	
    oPrintPvt:SayAlign(nLinAtu, nPosVTot-60, "Total a Pagar:", oFontCabN, 200, 07, , nPadLeft, )
	oPrintPvt:SayAlign(nLinAtu, nPosVTot, 	 Alltrim(Transform(nValorTot, cMaskVlr)),oFontCabN, 080, 07, , nPadLeft, )
Return

/*---------------------------------------------------------------------*
 | Func:  fImpDupl                                                     |
 | Desc:  Função para imprimir as duplicatas                           |
 *---------------------------------------------------------------------*/

Static Function fImpDupl()
	Local nLinhas 		:= NoRound(Len(aDuplicatas)/2, 0) + 1
	Local nAtual  		:= 0
	Local nLinDup 		:= 0
	Local nLinDupAux    := 0
	Local nLinLim 		:= nLinAtu + ((nLinhas+1)*7) + nTamFundo
	Local nColAux 		:= nColIni
	Local aParcelas     := {}
	Local cQry          := ""
	Local _cAlias       := GetNextAlias()
	nLinAtu += 020
	
	//Se atingir o fim da Pagina, quebra
	If nLinLim+5 >= nLinFin
		fImpRod()
		fImpCab()
	EndIf

	// Condição de Pagamento
	oPrintPvt:SayAlign(nLinAtu, nColIni, "Forma de Pagamento:  ", 									oFontTit, nColFin-nColIni, nTamFundo, nCorAzul, nPadLeft, )
	nLinAtu += 015
	oPrintPvt:Line(nLinAtu, nColIni, nLinAtu, nColFin)
	nLinAtu += 005
	nLinDup := nLinAtu

	cQry := " SELECT L4_FORMA, SUM(L4_VALOR) AS VALOR, COUNT(L4_FORMA) AS QTD FROM " + RetSQLName('SL4') 
    cQry += " WHERE D_E_L_E_T_ <> '*' "
    cQry += "   AND L4_FILIAL = '" +xFilial("SL4")+"'"
    cQry += "   AND L4_NUM = '" +SL1->L1_NUM+"'"
    cQry += " GROUP BY L4_FORMA"
    cQry := ChangeQuery(cQry)
    IF Select(_cAlias) <> 0
        (_cAlias)->(DbCloseArea())
    EndIf
    dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),_cAlias,.T.,.T.) 
    While (_cAlias)->(!Eof())
        IF (_cAlias)->QTD == 1
            aAdd(aParcelas,{ "R$ " + AllTrim(AllToChar((_cAlias)->VALOR, "@E 9,999,999,999,999.99")) + " - " ;
                             + Upper(AllTrim(FWGetSX5("24",AllTrim((_cAlias)->(L4_FORMA)),"pt-br")[1,4])) })
        Else
            aAdd(aParcelas,{ "R$ " + AllTrim(AllToChar((_cAlias)->VALOR, "@E 9,999,999,999,999.99")) + " - " ;
                             + Upper(AllTrim(FWGetSX5("24",AllTrim((_cAlias)->(L4_FORMA)),"pt-br")[1,4])) + " em " + cValToChar((_cAlias)->QTD) + "X" })
        EndIF 
    (_cAlias)->(DBSkip())
    End
    IF Select(_cAlias) <> 0
        (_cAlias)->(DbCloseArea())
    EndIf

	//Percorre as duplicatas
	For nAtual := 1 To Len(aParcelas)
		oPrintPvt:SayAlign(nLinDup, nColAux+0005, StrZero(nAtual, 2)+" - "+ aParcelas[nAtual][1],	oFontCab,  500, 07, , nPadLeft, )
		nLinDup += 7
		nLinDupAux += 5

		//Se atingiu o numero de linhas, muda para imprimir na coluna do meio
		If nAtual == 10
			nLinDup := nLinAtu
			nColAux := nColMeio
		EndIf
	Next
	
	nLinAtu += (nLinhas*7) + 3
	nLinAtu += (nLinDupAux / 2)

Return

/*---------------------------------------------------------------------*
 | Func:  fMsgObs                                                      |
 | Desc:  Função para imprimir mensagem de observação                  |
 *---------------------------------------------------------------------*/

Static Function fMsgObs()
Local cMsg      := ""
Local cCliente  := Alltrim(QRY_PED->A1_NOME)
Local lCNPJ     := (QRY_PED->A1_PESSOA != "F")
Local cCGC      := Alltrim(QRY_PED->A1_CGC)
Local nValidade := SuperGetMV("MV_DTLIMIT")
Local cDtValid  := DtoC(DaySum(SL1->L1_EMISSAO,nValidade))
Local nTotCarac := 70
Local nLinMsg   := 0
Local nId       := 0
	
	nLinAtu += 008
	
	//Se existir campo customizado para observação do orçamento
	If SL1->(FieldPos("L1_XMSGI") > 0) 
		If !Empty(SL1->L1_XMSGI)

			cMsg    := SL1->L1_XMSGI
			nLinMsg := MLCount(SL1->L1_XMSGI,nTotCarac)
		
		EndIf 
	Endif 

	//Se atingir o fim da Pagina, quebra
	If nLinAtu + (nLinMsg*10) >= nLinFin
		fImpRod()
		fImpCab()
	EndIf

	//Cria o grupo de Observação
	oPrintPvt:SayAlign(nLinAtu, nColIni, "Observações: ",   oFontTit,  100, nTamFundo, nCorAzul, nPadLeft, )
	nLinAtu += 010
	
	For nId := 1 To nLinMsg
		oPrintPvt:SayAlign(nLinAtu, nColIni, MemoLine(cMsg,nTotCarac,nId),    oFontCab,  540, 07, , nPadLeft, )
	nLinAtu += 008
	Next nId
	nLinAtu += 010

	oPrintPvt:SayAlign(nLinAtu, nColIni, "Orçamento válido até: "+cDtValid,    oFontObsN,  540, 07, , nPadCenter, )
	nLinAtu += 010
	oPrintPvt:SayAlign(nLinAtu, nColIni, "Este orçamento não pode ser alterado. Qualquer alteração que seja realizada neste documento",    	oFontObs,  540, 07, , nPadCenter, )
	nLinAtu += 010
	oPrintPvt:SayAlign(nLinAtu, nColIni, "após sua emissão, estará sujeita a alteração de preço de acordo com a cotação do dia.",    		 	oFontObs,  540, 07, , nPadCenter, )
	nLinAtu += 040
	
	oPrintPvt:SayAlign(nLinAtu, nColIni, Replicate("_",50),  oFontCabN,  540, 07, , nPadCenter, )
	nLinAtu += 010
	oPrintPvt:SayAlign(nLinAtu, nColIni, cCliente,  oFontCabN,  540, 07, , nPadCenter, )
	nLinAtu += 008

	If lCNPJ
		cCGC := IIF(!Empty(cCGC), "CNPJ: "+ Alltrim(Transform(cCGC, cMaskCNPJ)), "-")
	Else
		cCGC := IIF(!Empty(cCGC), "CPF: "+ Alltrim(Transform(cCGC, cMaskCPF)), "-")
	EndIf

	oPrintPvt:SayAlign(nLinAtu, nColIni, cCGC,  oFontCabN,  540, 07, , nPadCenter, )
Return
