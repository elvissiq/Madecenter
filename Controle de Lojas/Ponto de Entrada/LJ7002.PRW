#Include 'Protheus.ch'
#Include "TOPCONN.ch"

/*/
/*-----------------------------------------------------------------------
  Fun��o: LJ7002

  Tipo: Ponto de entrada

  Localiza��o: Ponto de Entrada chamado depois da grava��o de todos os
               dados e da impress�o do cupom fiscal na Venda Assistida
               e ap�s o processamento do Job LjGrvBatch(FRONT LOJA)

  Uso: Venda Assistida

  Par�metros:
    ExpN1	 Num�rico	 Cont�m o tipo de opera��o de grava��o, sendo:
      1 - Or�amento
      2 - Venda
      3 - Pedido

    ExpA2	 Array of Record Array de 1 dimens�o contendo os dados da
                   devolu��o na seguinte ordem:
      1 - s�rie da NF de devolu��o
      2 - N�mero da NF de devolu��o
      3 - Cliente
      4 - Loja do cliente
      5 - Tipo de opera��o (1 - troca; 2 - devolu��o)

    ExpN3	Array of Record	Cont�m a origem da chamada da fun��o, sendo:
      1 - Gen�rica
      2 - GRVBatch
Retorno:
Nenhum
--------------------------------------------------------------------------
  @history
  22/11/2024 - Desenvolvimento da Rotina.
/*/

User Function LJ7002()
  Local aArea     := FWGetArea()
  Local aAreaSG1  := SG1->(FWGetArea())
  Local cOpcao    := cValToChar(ParamIxB[1])
  Local lGrvBatch := IIF(ParamIxB[3] == 2,.T.,.F.)
  Local cNomCli   := Pad(AllTrim(Posicione("SA1",1,xFilial("SA1") + SL1->L1_CLIENTE + SL1->L1_LOJA, "A1_NOME" )),FWTamSX3("L1_NOMCLI")[1])
  Local aBankBXCH := FormatIn(SuperGetMV("MV_XBANKCH",.F.,""),"/")
  Local aBXTitCH  := {}
  Local cQry      := ""

  Private lMsHelpAuto := .T.
	Private lMsErroAuto := .F.
  Private _cAlias     := GetNextAlias()

  If cOpcao == "1" .AND. !(lGrvBatch)
        
    IF INCLUI .Or. ALTERA 
      If ExistBlock("MLJF04")
			  ExecBlock("MLJF04",.F.,.F.,{})
		  EndIf
    EndIF
  
  ElseIF cOpcao == '2' .AND. lGrvBatch

    //================================================================
    // Gera OP para produtos que possuem Estrutura 
    //================================================================
    
    cQry := " SELECT * FROM " + RetSQLName('SL2') + " "
    cQry += " WHERE D_E_L_E_T_ <> '*' "
    cQry += "   AND L2_FILIAL  = '" + SL1->L1_FILIAL + "' "
    cQry += "   AND L2_NUM     = '" + SL1->L1_NUM  + "' "
    cQuery := ChangeQuery(cQry)
    IF Select(_cAlias) <> 0
      (_cAlias)->(DbCloseArea())
    EndIf
    TCQuery cQry ALIAS (_cAlias) NEW

    dbSelectArea(_cAlias)

    While (_cAlias)->(!Eof())
      
      dbSelectArea("SG1")
      dbSetOrder(1)
      If SG1->(MsSeek(xFilial("SG1") + (_cAlias)->L2_PRODUTO ))
          fnGrvOP()
        (_cAlias)->(DbSkip())
      Else
        (_cAlias)->(DbSkip())
      EndIf
    End

    IF Select(_cAlias) <> 0
      (_cAlias)->(DbCloseArea())
    EndIf

    //================================================================
  EndIf

  //================================================================
  // Baixa do t�tulo do tipo CH 
  //================================================================
  cQry := " SELECT * FROM " + RetSQLName('SE1') + " "
  cQry += " WHERE D_E_L_E_T_ <> '*' "
  cQry += "   AND E1_FILIAL  = '" + xFilial("SE1") + "' "
  cQry += "   AND E1_PREFIXO = '" + SL1->L1_SERPED + "' "
  cQry += "   AND E1_NUM     = '" + SL1->L1_DOCPED + "' "
  cQry += "   AND E1_CLIENTE = '" + SL1->L1_CLIENTE + "' "
  cQry += "   AND E1_LOJA    = '" + SL1->L1_LOJA + "' "
  cQry += "   AND E1_TIPO    = 'CH' "
  cQuery := ChangeQuery(cQry)
  IF Select(_cAlias) <> 0
    (_cAlias)->(DbCloseArea())
  EndIf
  TCQuery cQry ALIAS (_cAlias) NEW
  
  While (_cAlias)->(!Eof()) .AND. !Empty(aBankBXCH)
    
    aAdd(aBXTitCH,{"E1_PREFIXO"  , (_cAlias)->E1_PREFIXO       ,Nil    })
    aAdd(aBXTitCH,{"E1_NUM"      , (_cAlias)->E1_NUM           ,Nil    })
    aAdd(aBXTitCH,{"E1_PARCELA"  , (_cAlias)->E1_PARCELA       ,Nil    })
    aAdd(aBXTitCH,{"E1_TIPO"     , (_cAlias)->E1_TIPO          ,Nil    })
    aAdd(aBXTitCH,{"AUTMOTBX"    , "NOR"                       ,Nil    })
    aAdd(aBXTitCH,{"AUTBANCO"    , aBankBXCH[1]                ,Nil    })
    aAdd(aBXTitCH,{"AUTAGENCIA"  , aBankBXCH[2]                ,Nil    })
    aAdd(aBXTitCH,{"AUTCONTA"    , aBankBXCH[3]                ,Nil    })
    aAdd(aBXTitCH,{"AUTDTBAIXA"  , SToD((_cAlias)->E1_EMISSAO) ,Nil    })
    aAdd(aBXTitCH,{"AUTDTCREDITO", SToD((_cAlias)->E1_EMISSAO) ,Nil    })
    aAdd(aBXTitCH,{"AUTHIST"     , "Baixa automatica CH"       ,Nil    })
    aAdd(aBXTitCH,{"AUTJUROS"    , 0                           ,Nil,.T.})
    aAdd(aBXTitCH,{"AUTVALREC"   , (_cAlias)->E1_SALDO         ,Nil    })    
    
    lMsErroAuto:= .F. 
    MSExecAuto({|x,y| FINA070(x,y)},aBXTitCH,3)
  
    (_cAlias)->(DBSkip())
  End

  IF Select(_cAlias) <> 0
    (_cAlias)->(DbCloseArea())
  EndIf
  //================================================================

  RecLock("SL1",.F.)
    SL1->L1_NOMCLI := cNomCli
  SL1->(MsUnLock())

  FWRestArea(aAreaSG1)
  FWRestArea(aArea)
  
Return

//------------------------------------------------------------------------
/*/{PROTHEUS.DOC} fnGrvOP
@TYPE FUNCTION fnGrvOP - Gera e Baixa a OP conforme informado no item do Pedido de Venda
@AUTHOR TOTVS Nordeste
@VERSION PROTHEUS 12
/*/
Static Function fnGrvOP()
  Local aVetorOP  := {}
  Local aVetorBX  := {}
  Local cNumOP    := ""
  Local dData     := CToD("")
  
  cNumOP := fGeraNum("C2")

	aAdd(aVetorOP, {'C2_NUM'    , cNumOP                                      , Nil} )
	aAdd(aVetorOP, {'C2_ITEM'   , '01'                       					        , Nil} )
	aAdd(aVetorOP, {'C2_SEQUEN' , '001'                      					        , Nil} )
	aAdd(aVetorOP, {'C2_PRODUTO', (_cAlias)->L2_PRODUTO         					    , Nil} )
	aAdd(aVetorOP, {'C2_QUANT'  , (_cAlias)->L2_QUANT        					        , Nil} )
	aAdd(aVetorOP, {'C2_LOCAL'  , (_cAlias)->L2_LOCAL        					        , Nil} )
	aAdd(aVetorOP, {'C2_DATPRI' , SToD((_cAlias)->L2_EMISSAO)        	   			, Nil} )
	aAdd(aVetorOP, {'C2_DATPRF' , SToD((_cAlias)->L2_EMISSAO)              		, Nil} )
	aAdd(aVetorOP, {'C2_EMISSAO', SToD((_cAlias)->L2_EMISSAO)              		, Nil} )
	aAdd(aVetorOP, {'C2_OBS'    , 'OP Gerada aut. Orc.: '+ (_cAlias)->L2_NUM 	, Nil} )
  aAdd(aVetorOP, {'C2_XL1NUM' , (_cAlias)->L2_NUM 	                        , Nil} )
  aAdd(aVetorOP, {'AUTEXPLODE', 'S'                        					        , Nil} )

  lMsErroAuto:= .F. 
  MSExecAuto({|x, y| MATA650(x, y)}, aVetorOP, 3)

	If !lMsErroAuto
	  
    dData := dDataBase
    
    aVetorBX := {;
                {"D3_OP"		,cNumOP + '01' + '001'  	,NIL},;
                {"D3_TM"		,"001"				            ,NIL}}

    MSExecAuto({|x, y| MATA250(x, y)},aVetorBX, 3 )
	EndIF

Return

/*/{Protheus.doc} fGeraNum
	Gera o proximo numero do documento
	@type  Static Function
	@author Elvis Siqueira (TOTVS Recife)
/*/
Static Function fGeraNum(pTab)
	Local cNum  := ""
	Local cQry  := ""
	Local cAPrx	:= GetNextAlias()

	cQry := " SELECT MAX("+pTab+"_NUM) ULTIMO "
	cQry += " FROM " + RetSqlName("S"+pTab)
	cQry += " WHERE "+pTab+"_FILIAL = '" + xFilial("S"+pTab) + "' "
	cQry := ChangeQuery(cQry)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),cAPrx,.F.,.T.)

    IF (cAPrx)->(!Eof())
        cNum := Soma1((cAPrx)->ULTIMO)
    Else 
        cNum := StrZero(1,FWTamSX3(pTab+"_NUM")[1])
    EndIF 
    
    (cAPrx)->(DbCloseArea())
	
Return cNum
