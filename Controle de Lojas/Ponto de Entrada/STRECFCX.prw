
#Include 'Protheus.ch'
#Include 'Totvs.ch'

/*/{Protheus.doc} STRECFCX
Ponto de Entrada para customização do Relatório de Conferencia da rotina Encerramento de Caixa do Totvs Pdv.
@type function
@author TOTVS Recife (Elvis Siqueira)
@since 17/02/2022
@Parametros
	PARAMIXB[1] - Matriz das formas de pagamentos e respectivos valores digitados e apurados (array)
	PARAMIXB[2] - Número do Caixa (string)
	PARAMIXB[3] - Código da Estação (string)
	PARAMIXB[4] - Número do Pdv (string)
	PARAMIXB[5] - Data da abertura do movimento (string)
	PARAMIXB[6] - Hora da abertura do movimento (string)
	PARAMIXB[7] - Data do fechamento (string)
	PARAMIXB[8] - Hora do fechamento (string)
	PARAMIXB[9] - Número do movimento (string)
@return texto a ser impresso (string)
/*/

User Function STRECFCX()
	Local aPaym     :=  PARAMIXB[1] 
	Local sCaixa    :=  PARAMIXB[2]
	Local sEstacao  :=  PARAMIXB[3]
	Local sPdv      :=  PARAMIXB[4]
	Local sDtAbert  :=  PARAMIXB[5]
	Local sAbHora   :=  PARAMIXB[6] 
	Local sDtFech   :=  PARAMIXB[7] 
	Local sFcHora   :=  PARAMIXB[8]
	Local sNumMov   :=  PARAMIXB[9]
	Local aFieldSM0 := { ;
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
	Local aSM0Data 	:= FWSM0Util():GetSM0Data(, SL1->L1_FILIAL, aFieldSM0)
	Local cNomCom   := aSM0Data[1,2] // Nome Comercial da Empresa
	Local cEndEnt   := aSM0Data[2,2] // Endereço de Entrega
	Local cBaiEnt   := aSM0Data[3,2] // Bairro de Entrega
	Local cCidEnt   := aSM0Data[4,2] // Cidade de Entrega
	Local cEstEnt   := aSM0Data[5,2] // Estado de Entrega
	Local cCepEnt   := aSM0Data[6,2] // Cep de Entrega
	Local cCgcEnt   := aSM0Data[7,2] // CNPJ 
	Local cInsEnt   := aSM0Data[8,2] // Inscrição Estadual
	Local cTexto    :=  ""
	Local nTotApu   :=  0
	Local nTotDig   :=  0
	Local cCRLF     :=  Chr(13) + Chr(10) 
	Local nX        :=  0

	cTexto := cCRLF + cCRLF 

	cTexto:= '<ce>'+ alltrim(cNomCom) +'</ce>'+ cCRLF
	cTexto:= cTexto +'<ce>'+ alltrim(cEndEnt) + ' - '+ alltrim(cBaiEnt) +'</ce>'+ cCRLF
	cTexto:= cTexto +'<ce>'+ alltrim(cCidEnt) + ' - '+ alltrim(cEstEnt) + ' CEP:'+ alltrim(cCepEnt) +'</ce>'+ cCRLF
	cTexto:= cTexto +'<ce> CNPJ: '+ alltrim(cCgcEnt) + ' IE: '+ alltrim(cInsEnt) +'</ce>'+ cCRLF
	cTexto:= cTexto + Replicate("-", 47) + cCRLF
	cTexto:= cTexto + '<b><ce>ENCERRAMENTO DE CAIXA</ce></b>'+ cCRLF
	cTexto:= cTexto + Replicate("-", 47) + cCRLF

	cTexto += 'Caixa.....: ' + sCaixa   + cCRLF  
	cTexto += 'Estação...: ' + sEstacao + cCRLF  
	cTexto += 'PDV.......: ' + sPdv     + cCRLF 
	cTexto += 'Abertura..: ' + sDtAbert + ' - ' + 'Hora: ' + AllTrim(sAbHora) + cCRLF 
	cTexto += 'Fechamento: ' + sDtFech  + ' - ' + 'Hora: ' + AllTrim(sFcHora) + cCRLF 
	cTexto += 'Movimento.: ' + sNumMov      + cCRLF
	cTexto += cCRLF + cCRLF
	
	cTexto += 'Forma !Descrição                ! Valor Dig !  Valor Ap.'

	cTexto += cCRLF

	For nX := 1 To Len(aPaym)
		cTexto += aPaym[nX][1] + '!' + SubStr(aPaym[nX][2],1,22) + Space(3) + '!' + Str(Val(aPaym[nX][7]),10,2) + '!' + Str(aPaym[nX][8],10,2) + cCRLF
		nTotApu := nTotApu + aPaym[nX][8]
		nTotDig := nTotDig + Val(aPaym[nX][7])
	Next nX

	cTexto += cCRLF + cCRLF
	cTexto += cCRLF + "Total Apurado :" + Str(nTotApu,10,2)
	cTexto += cCRLF + "Total Digitado:" + Str(nTotDig,10,2)
	cTexto += cCRLF + 'Ass. Caixa    :' + Replic("_",28)
	cTexto += cCRLF + 'Ass. Superior :' + Replic("_",28) + cCRLF 

Return cTexto
