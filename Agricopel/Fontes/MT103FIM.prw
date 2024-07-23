#include "Protheus.ch"
#include "Topconn.ch"
#INCLUDE "AP5MAIL.CH"

User Function MT103FIM()

Local nOpcao    := PARAMIXB[1]      // Opção Escolhida pelo usuario no aRotina 
Local lConfirma := PARAMIXB[2] == 1 // Indica se usuário confirmou a operação
Local cQuery    := ""
Local lRet      := .F.
Local _aCabec   := {}    
Local cPrefixo  := ""
Local _aAreaM   := {} //getarea()             
Local cBANCOBX   := ""
Local cAGENCIABX := ""
Local cCONTABX   := ""
Local _nI        := 0 
Local aCmp   	 := aClone(PARAMIXB)
Local _cQuery    := ""
Local aAreaTab1
Local _NposProd	:= aScan(aHeader,{|x| AllTrim(x[2])=="D1_COD"})
//////////////////////////////////////// Variáveis das tabelas
Private _cTab1     := Upper(AllTrim(GetNewPar("MV_XGTTAB1", "")))  // XMLs do Importador NFe
Private _cTab2     := Upper(AllTrim(GetNewPar("MV_XGTTAB2", "")))  // Importador NFe
//Private _cTab3     := Upper(AllTrim(GetNewPar("MV_XGTTAB3", "")))  // Usuários Importador
Private _cTab4     := Upper(AllTrim(GetNewPar("MV_XGTTAB4", "")))  // Tabela Unidade de Medida por Produto
Private _cTab5     := Upper(AllTrim(GetNewPar("MV_XGTTAB5", "")))  // Tabela para o cadastro de Tipo de Nota
Private _cTab6     := Upper(AllTrim(GetNewPar("MV_XGTTAB6", "")))  // CFOPs do Tipo de Nota
Private _cTab8     := Upper(AllTrim(GetNewPar("MV_ZGOTAB8", "")))  // 

Private _cCmp1     := IIf(SubStr(_cTab1, 1, 1) == "S", SubStr(_cTab1, 2, 2), _cTab1)
Private _cCmp2     := IIf(SubStr(_cTab2, 1, 1) == "S", SubStr(_cTab2, 2, 2), _cTab2)
//Private _cCmp3     := IIf(SubStr(_cTab3, 1, 1) == "S", SubStr(_cTab3, 2, 2), _cTab3)
Private _cCmp4     := IIf(SubStr(_cTab4, 1, 1) == "S", SubStr(_cTab4, 2, 2), _cTab4)
Private _cCmp5     := IIf(SubStr(_cTab5, 1, 1) == "S", SubStr(_cTab5, 2, 2), _cTab5)
Private _cCmp6     := IIf(SubStr(_cTab6, 1, 1) == "S", SubStr(_cTab6, 2, 2), _cTab6)
Private _cCmp8     := IIf(SubStr(_cTab8, 1, 1) == "S", SubStr(_cTab8, 2, 2), _cTab8)
////////////////////////////////////////

// Geração e apontamento de OP de Beneficiamento ARLA
Private _cProduto   := PadR((SuperGetMV("AG_PRODREM",.F.,"00338")),TamSX3("B1_COD")[1]) //Produto da remessa
Private _cProdOp    := PadR((SuperGetMV("AG_PRODOP",.F.,"44380001")),TamSX3("B1_COD")[1])//Produto do retorno
Private _cServico   := PadR((SuperGetMV("AG_PRDSERV",.F.,"401138")),TamSX3("B1_COD")[1])//Produto do serviço
Private _lGeraOP    := SuperGetMV("AG_ARLAOP",.F.,.F.)//Gera OP Para ARLA
Private nQtdeOp     := 0
Private _cError     := ""
Private _cMailErr   := SuperGetMV("AG_PRODERR",.F.,"leandro.h@agricopel.com.br;ronaldo.f@agricopel.com.br")
// FIM Geração e apontamento de OP de Beneficiamento ARLA

aAreaTab1 := (_cTab1)->( GetArea() )

    //##########################################//
    //  Leandro Spiller - 27.12.2016            //
    //  Chama a função de Manifesto Logo após   //
    //  a gravação da NF                        //
    //##########################################//
    If SF1->F1_FORMUL <> "S" .and. !Empty(SF1->F1_CHVNFE) .and. Alltrim(SF1->F1_ESPECIE) == "SPED" .AND. lConfirma .And. (nOpcao == 3 .Or. nOpcao == 4) 
	    _aAreaM   := getarea()  
	    _cAlias := 'SF1'
    	_nReg   := SF1->(Recno())
    	_nOpcx	:= (nOpcao - 2) //1-Inclusão ; 2-Alteração  
    	
    	If(FunName()$"MATA103")
    		A103Manif(_cAlias,_nReg,_nOpcx) 
		Else
			U_SLAManif(_cAlias,_nReg,_nOpcx) 
		Endif
		Restarea(_aAreaM)
	Endif      
	
	//Spiller - Gera Tabela CD6 
	If lConfirma .And. (nOpcao == 3 .Or. nOpcao == 4) 
		u_XAG0032E()
	Endif       

	If lConfirma .And. (nOpcao == 3 .Or. nOpcao == 4)

		If (CCONDICAO == "800") .Or. (CCONDICAO == "801") .Or. (CCONDICAO == "919")

			//cPrefixo :=  AllTrim(Substr(CSERIE,1,3))  
			cPrefixo :=  SF1->F1_PREFIXO  
            If (CCONDICAO == "800")
               cBANCOBX   := 'CX1'
               cAGENCIABX := '00001'
               cCONTABX   := '0000000001'
            EndIf

            If (CCONDICAO == "801")
               cBANCOBX   := '999'
               cAGENCIABX := '99999'
               cCONTABX   := '9999999999'
            EndIf

		  If (CCONDICAO == "919")
               cBANCOBX   := '919'
               cAGENCIABX := '919  '
               cCONTABX   := '919       '
            EndIf


			cQuery := " SELECT * FROM " + RetSQLName("SE2") + " (NOLOCK) "
			cQuery += " WHERE E2_PREFIXO = '"  + cPrefixo        + "' "
			cQuery += "   AND E2_NUM     = '"  + CNFISCAL        + "' "
			cQuery += "   AND E2_EMISSAO = '"  + DtoS(DDEMISSAO) + "' "
			cQuery += "   AND E2_FORNECE = '"  + CA100FOR        + "' "
			cQuery += "   AND E2_LOJA    = '"  + CLOJA           + "' "
			cQuery += "   AND E2_SALDO   > 0 "
			cQuery += "   AND D_E_L_E_T_ <> '*' " 
			cQuery += "   AND E2_PARCELA = '' "
	
			If (Select("QRYSE2") <> 0)
				DbSelectArea("QRYSE2")
				DbCloseArea()
			EndIf

			TCQuery cQuery NEW ALIAS "QRYSE2"
	
	        dbSelectArea("QRYSE2")
	        dbGotop()
	        While !Eof() 
	
	           lRet := .F.
	
		        _aCabec      := {}
		        Aadd(_aCabec, {"E2_PREFIXO"      , QRYSE2->E2_PREFIXO          , Nil})
		        Aadd(_aCabec, {"E2_NUM"          , QRYSE2->E2_NUM              , Nil})
		        Aadd(_aCabec, {"E2_PARCELA"      , QRYSE2->E2_PARCELA          , Nil})
		        Aadd(_aCabec, {"E2_TIPO"         , QRYSE2->E2_TIPO             , Nil})
		        Aadd(_aCabec, {"E2_FORNECE"      , QRYSE2->E2_FORNECE          , Nil})
		        Aadd(_aCabec, {"E2_LOJA"         , QRYSE2->E2_LOJA             , Nil})
		          
	            Aadd(_aCabec, {"AUTBANCO"        , cBANCOBX   , Nil})
	            Aadd(_aCabec, {"AUTAGENCIA"      , cAGENCIABX , Nil})
	            Aadd(_aCabec, {"AUTCONTA"        , cCONTABX   , Nil}) 
	
				Aadd(_aCabec,{"AUTHIST"    ,'Baixa Automatica',Nil})//12 //'Baixa Automatica'
				Aadd(_aCabec,{"AUTDESCONT" ,0                 ,Nil})//13
				Aadd(_aCabec,{"AUTMULTA"   ,0                 ,Nil})//14 
				Aadd(_aCabec,{"AUTJUROS"   ,0                 ,Nil})//15
				Aadd(_aCabec,{"AUTOUTGAS"  ,0                 ,Nil})//16
				Aadd(_aCabec,{"AUTVLRPG"   ,0                 ,Nil})//17
				Aadd(_aCabec,{"AUTVLRME"   ,0                 ,Nil})//18
				Aadd(_aCabec,{"AUTCHEQUE"  ,""                ,Nil})//19
				Aadd(_aCabec,{"AUTTXMOEDA" ,0                 ,Nil})//20
	
				Aadd(_aCabec, {"AUTMOTBX"         , "NOR "                       , Nil})
				Aadd(_aCabec, {"AUTDTBAIXA"       , dDataBase                    , Nil})
				Aadd(_aCabec, {"AUTDTCREDITO"     , dDataBase                    , Nil})
	
				lMsErroAuto := .F.
				Begin Transaction
					MSExecAuto({|x,y| fina080(x,y)},_aCabec, 3 )
					IF lMsErroAuto
						DisarmTransaction()
						Break
					Else
						//SUCESSO
						lRet := .T.
	                Endif
				End Transaction     

				If lRet

				  	cQuery := " UPDATE " + RETSQLNAME("SE5")
					cQuery += " SET E5_BANCO = '"+ cBANCOBX +"', E5_AGENCIA = '"+ cAGENCIABX +"', E5_CONTA = '"+ cCONTABX +"' "
					cQuery += " WHERE E5_PREFIXO = '"  +  cPrefixo        + "' "
					cQuery += "   AND E5_NUMERO  = '"  +  CNFISCAL        + "' "
					cQuery += "   AND E5_DATA    = '"  +  dtos(DDEMISSAO) + "' "
					cQuery += "   AND E5_CLIFOR  = '"  +  CA100FOR        + "' "
					cQuery += "   AND E5_LOJA    = '"  +  CLOJA           + "' "
					cQuery += "   AND D_E_L_E_T_ <> '*' "
					cQuery += "   AND E5_PARCELA = '' "

				  	TcSqlExec(cQuery)
				EndIf

				dbSelectArea("QRYSE2")
				QRYSE2->(dbSkip())
			EndDo

			If (Select("QRYSE2") <> 0)
				DbSelectArea("QRYSE2")
				DbCloseArea()
			EndIf

		EndIf
        
        if (AllTrim(SF1->F1_ESPECIE) <> "CTE")
		   U_AGX522()
		   U_AGX525() 
		EndIf

	EndIF

	/* ####################################################################### *\
	|| #              É EXECUTADO DEPOIS QUE A NOTA É EXCLUÍDA               # ||
	\* ####################################################################### */
	// * Tipo exclusão    * Nota realmente excluída
	If aCmp[1] == 5 .AND. aCmp[2] == 1 .And. !Empty(SF1->F1_CHVNFE)

		//U_CriRespArq("NFE", {SF1->F1_CHVNFE}, .T.)
		dbSelectArea(_cTab1)
		(_cTab1)->( dbSetOrder(1) )

		//*Chave *NFe *Importado
		If (_cTab1)->( dbSeek(SF1->F1_CHVNFE + "1" + "2") )
			RecLock(_cTab1, .F.)
		        If GetNewPar("MV_XGTDELX", .F.)
					dbDelete()
				Else
					If IsInCallStack("A140EstCla")
						(_cTab1)->&(_cCmp1+"_SIT") := "2"
						(_cTab1)->&(_cCmp1+"_LIBALM") := "1"
					Else
						(_cTab1)->&(_cCmp1+"_SIT") := "1"
						If (_cTab1)->&(_cCmp1+"_LIBALM") == "3"
							(_cTab1)->&(_cCmp1+"_LIBALM") := " "
						EndIf
					EndIf
				EndIf
			(_cTab1)->( MsUnlock() )

			// Voltar as informaçoes dos itens 

			U_GOX21AIT()

		ElseIf (_cTab1)->( dbSeek(SF1->F1_CHVNFE + "2" + "2") )

			If SF1->F1_TIPO == "C"

				dbSelectArea("SF8")
				SF8->( dbSetOrder(3) )
				SF8->( dbSeek(xFilial("SF8") + SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA) )
				//F8_FILIAL+F8_NFDIFRE+F8_SEDIFRE+F8_TRANSP+F8_LOJTRAN
				While !SF8->( Eof() ) .And. SF8->F8_FILIAL == xFilial("SF8") .And. SF8->F8_NFDIFRE == SF1->F1_DOC .And. ;
					SF8->F8_SEDIFRE == SF1->F1_SERIE .And. SF8->F8_TRANSP == SF1->F1_FORNECE .And. SF8->F8_LOJTRAN == SF1->F1_LOJA

					RecLock("SF8", .F.)
						dbDelete()
					SF8->( MsUnlock() )

					SF8->( dbSkip() )

				EndDo

			EndIf

			RecLock(_cTab1, .F.)
		       If GetNewPar("MV_XGTDELX", .F.)
					dbDelete()
				Else
					(_cTab1)->&(_cCmp1+"_SIT") := "1"
				EndIf
			(_cTab1)->( MsUnlock() )
		EndIf

	// * Produto Padrão * Tipo inclusão * Nota realmente incluída
	ElseIf (aCmp[1] == 3 .Or. aCmp[1] == 4) .And. aCmp[2] == 1 .And. !Empty(SF1->F1_CHVNFE)

		If aCmp[1] == 4 //IsInCallStack("ImpClassNf")
			
			dbSelectArea(_cTab1)
			(_cTab1)->( dbSetOrder(1) )
	
			//*Chave *NFe *Importado
			If (_cTab1)->( dbSeek(SF1->F1_CHVNFE + "1" + "2") ) .Or. (_cTab1)->( dbSeek(SF1->F1_CHVNFE + "2" + "2") )
				
				If (_cTab1)->&(_cCmp1 + "_LIBALM") == '1'

					RecLock(_cTab1, .F.)

						(_cTab1)->&(_cCmp1 + "_LIBALM") := "3"

					(_cTab1)->( MSUnlock() )
					
				EndIf
				
			EndIf
			
		EndIf

		// Atualiza Situaçao nos itens

		dbSelectArea(_cTab1)
		(_cTab1)->( dbSetOrder(1) )

		//*Chave *NFe *Importado
		If (_cTab1)->( dbSeek(SF1->F1_CHVNFE + "1") )

			U_GOX21AIT()

		EndIf

		// Faz a manifestação de Notas acima de 100 mil reais
		If AllTrim(SF1->F1_ESPECIE) $ "SPED" .And. SF1->F1_VALMERC >= GetNewPar("MV_ZSNVLMN", 0) .And. SF1->F1_EST # "EX" .And. SF1->F1_FORMUL # "S"

			_aRetMnf := U_GOX11MD(SF1->F1_CHVNFE)

			If !_aRetMnf[1]

				MsgInfo("Ocorreu um erro ao realizar o Manifesto Destinatário Automático, será necessário realizá-lo posteriormente. Erro: " + _aRetMnf[2])

			EndIf
			
		ElseIf AllTrim(SF1->F1_ESPECIE) $ "CTE/CTEOS" .And. SF1->F1_EST # "EX" .And. SF1->F1_FORMUL # "S"
			
			// Marca CT-e como importado...
			U_GOX11PRC(SF1->F1_CHVNFE)
			
		EndIf
		
		// Gravar Origem
		
		If IsInCallStack("U_GOX001") .Or. IsInCallStack("U_GOX008")
			
			RecLock("SF1")
				
				SF1->F1_ORIIMP := "GOX001"
				
			SF1->( MSUnlock() )
			
		EndIf

	EndIf
	//FIM

	//------------------------------------------------
	// OP Beneficiamento ARLA
	// 05/10/2022
	// Dirlei@uxpert
	//------------------------------------------------
	// Validar NF Retorno Beneficiamento
	If lConfirma .And. (nOpcao == 3 .Or. nOpcao == 4) .and. _lGeraOP

		If alltrim(SF1->F1_ESPECIE) <> 'CTE'
			For _nI := 1 To Len(aCols)
				If /*SD1->D1_COD*/alltrim(aCols[_nI][_NposProd]) == alltrim(_cServico) //.And. !Empty(SD1->D1_NFORI)

					// Gera OP
					If fGeraOP()

						// Baixa OP
						fBaixaOP()
					EndIf
					Exit
				EndIf
				
			Next _nI
		Else //Se for Cte verifico se é de Remessa de Ureia
			
			ltemZD6SF8 := .F.	
			If Select("ZD6") //Procuro na ZD6

				_cQuery := " SELECT D2_LOCAL FROM "+RetSqlName('ZD6')+" (NOLOCK) ZD6 "
				_cQuery += " INNER JOIN "+RetSqlName('SF2')+" (NOLOCK) SF2 ON F2_FILIAL = ZD6_FILIAL "
				_cQuery += " AND F2_CHVNFE = ZD6_CHVNFE AND SF2.D_E_L_E_T_ = '' "
				_cQuery += " INNER JOIN "+RetSqlName('SD2')+" (NOLOCK) SD2 ON F2_FILIAL = D2_FILIAL AND F2_DOC = D2_DOC AND F2_SERIE = D2_SERIE " 
				_cQuery += " AND F2_CLIENTE = D2_CLIENTE AND F2_LOJA = D2_LOJA AND SD2.D_E_L_E_T_ = '' "
				_cQuery += " WHERE ZD6_CHVCTE = '"+SF1->F1_CHVNFE+"' AND ZD6.D_E_L_E_T_ = '' "
				_cQuery += " AND D2_COD = '"+_cProduto+"' AND D2_IDENTB6 <> '' " 
			
				If (Select("XCUSCTE") <> 0)
					DbSelectArea("XCUSCTE")
					DbCloseArea()
				EndIf

				TCQuery _cQuery NEW ALIAS "XCUSCTE"
				
				If XCUSCTE->(!eof())
					ltemZD6SF8 := .T.	
				Endif 
			Endif 


			If !ltemZD6SF8
				//Busco a nota na SF8
				Dbselectarea('SF8')
				DbSetOrder(1)
				if Dbseek(xfilial('SF8') + SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA )

					_cQuery := " SELECT D2_LOCAL FROM "+RetSqlName('SD2')+"(NOLOCK) "
					_cQuery += " WHERE D2_FILIAL = '"+xFilial('SD2')+"' AND D2_DOC = '"+SF8->F8_NFORIG +"' AND "
					_cQuery += " D2_SERIE = '"+SF8->F8_SERORIG + "' AND D2_CLIENTE = '"+SF8->F8_FORNECE+"' AND "
					_cQuery += " D2_LOJA = '"+SF8->F8_LOJA+"'  AND D2_IDENTB6 <> '' AND "
					_cQuery += " D2_COD = '"+_cProduto+"' AND D_E_L_E_T_ = ''"
				
					If (Select("XCUSCTE") <> 0)
						DbSelectArea("XCUSCTE")
						DbCloseArea()
					EndIf

					TCQuery _cQuery NEW ALIAS "XCUSCTE"

					If XCUSCTE->(!eof())
						ltemZD6SF8 := .T.	
					Endif 
				Endif 
			Endif 	
	
			//Se for um Cte de Remessa de Arla Crio o movimento para Agregar Custo
			If ltemZD6SF8
				fCustoCte(XCUSCTE->D2_LOCAL)
			Endif
			
			If (Select("XCUSCTE") <> 0)
				DbSelectArea("XCUSCTE")
				DbCloseArea()
			EndIf
			
		Endif

	EndIf


RestArea(aAreaTab1)

Return


//---------------------------------------------------------------------
/*/{Protheus.doc} fGeraOP
Rotina para gerar Ordem Produção

@author     Dirlei@uxpert
@since      10/11/2022

@return     Nil, Nenhum
@type       function
/*/
//---------------------------------------------------------------------
Static Function fGeraOP()

Local aArea	:= GetArea()
Local aOrdem := {}
Local cNumOP := 0   
Local nModAux := nModulo
Local cChvDoc := ""
Local lRet := .T.

Private oDlg := Nil
Private oSayInf := Nil
Private oSayQtd := Nil

dbSelectArea("SB1") 
SB1->(dbSetOrder(1)) // B1_FILIAL + B1_COD

dbSelectArea("SF4") 
SF4->(dbSetOrder(1)) // F4_FILIAL + F4_CODIGO

dbSelectArea("SC2") 
SC2->(dbSetOrder(1)) // C2_FILIAL + C2_NUM + C2_ITEM + C2_SEQUEN

dbSelectArea("SG1") 
SG1->(dbSetOrder(1)) // G1_FILIAL + G1_COD + G1_COMP

dbSelectArea("SD1")
SD1->(dbSetOrder(1)) // D1_FILIAL + D1_DOC + D1_SERIE + D1_FORNECE + D1_LOJA 

If SD1->(dbSeek(xFilial("SD1") + SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA))
	While !SD1->(Eof()) .And. SD1->D1_DOC + SD1->D1_SERIE + SD1->D1_FORNECE + SD1->D1_LOJA == SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA

		If alltrim(SD1->D1_COD) == alltrim(_cServico)
			cChvDoc := SD1->D1_DOC + SD1->D1_SERIE + SD1->D1_FORNECE + SD1->D1_LOJA + SD1->D1_ITEM
		
	   		//If SF4->(dbSeek(xFilial("SF4") + SD1->D1_TES)) .And. SF4->F4_ESTOQUE == "S" .And. SF4->F4_PODER3 = "D" // TES Devolução

            //If SG1->(dbSeek(xFilial("SG1") + _cProdOp + SD1->D1_COD))

			nQtdeOp := SD1->D1_QUANT //Round(SD1->D1_QUANT / SG1->G1_QUANT,2)

			//Define MSDialog oDlg Title "Quantidade Produzida" From 000, 000 To 200, 400 Colors 0, 16777215 Pixel
			//
			//@ 005, 010 Say oSayInf Prompt "Confirme/Altere a quantidade beneficiada para geração da OP." Size 180, 012 Of oDlg Colors 0, 16777215 Pixel
			//@ 020, 010 Say oSayQtd Prompt "Quantidade: " Size 050, 012 Of oDlg Colors 0, 16777215 Pixel
			//@ 020, 075 MSGet oGetQtd Var nQtdeOp Size 100, 010 Of oDlg Colors 0, 16777215 Pixel Picture "@E 999,999,999.99"
			//@ 045, 150 Button "Confirmar" Size 040,010 Of oDlg Action oDlg:End() Pixel
			//
			//Activate MSDialog oDlg Centered

            // Posiciona produto
            SB1->(dbSeek(xFilial("SB1") + _cProdOp))

            If !SC2->(dbSeek(xFilial("SC2") + SD1->D1_OP)) .OR. FUNNAME() == 'AGRFORMU' .OR. Empty(SD1->D1_OP)

                // Gera OP AQUI
                cNumOP := GetNumSC2()
                ConfirmSX8()

				//Varre banco até encontrar uma numeração ainda nao utilizada
				While SC2->(dbSeek(xFilial("SC2") + cNumOP))
					cNumOP := GetNumSC2()
                	ConfirmSX8()
				Enddo 

                aOrdem := { {"C2_NUM"    ,cNumOP		 , Nil},;
                          	{"C2_ITEM"   ,"01"		     , Nil},;
                            {"C2_SEQUEN" ,"001"		     , Nil},;
                            {"C2_PRODUTO",_cProdOp        , Nil},;
                            {"C2_QUANT"  ,nQtdeOp        , Nil},;
                            {"C2_DATPRI" ,dDataBase	     , Nil},;
                            {"C2_DATPRF" ,dDataBase	     , Nil},;
                            {"C2_EMISSAO",dDataBase	     , Nil},;
                            {"C2_OBS"    ,cChvDoc	     , Nil},;
                            {"C2_PRIOR"  ,"500"		     , Nil},;
                            {"C2_LOCAL"  ,SD1->D1_LOCAL/*SB1->B1_LOCPAD*/ , Nil},;
                            {"C2_UM"     ,SB1->B1_UM     , Nil},;
                            {"C2_STATUS" ,"N"		     , Nil},;
                            {"AUTEXPLODE","S"            , Nil},;
                            {"C2_TPOP"   ,"F"		     , Nil} }
                    
                nModulo := 4 // Estoque/Custos
                lMsErroAuto := .F.
		        MSExecAuto({|x,y| MATA650(x,y)},aOrdem,3)
                    
                If !lMsErroAuto
                    //MsgInfo("Ordem de Produção "+ SC2->(C2_NUM + C2_ITEM + C2_SEQUEN) +" gerada com sucesso!","Ordem Produção")
                    Conout("Ordem de Produção "+ SC2->(C2_NUM + C2_ITEM + C2_SEQUEN) +" gerada com sucesso!")
                    // Grava OP no Doc.Entrada
                    RecLock("SD1",.F.)
                    	SD1->D1_OP := SC2->C2_NUM + SC2->C2_ITEM + SC2->C2_SEQUEN
                    SD1->(MsUnlock())					

					//Agrega custo do serviço ao PA
					fServOP()

					lRet := .T.
                Else
					_cError := MostraErro("/dirdoc", "error.log")
					SendMail(   ,_cMailErr,'','MT103FIM - FGeraop - Erro Apontamento de OP,NF: '+SD1->D1_FILIAL+'-'+SD1->D1_DOC +'/' +SD1->D1_SERIE,_cError)
                    Aviso("Atenção!",_cError,{"Ok"},,,,,.T.,10000)//Alert(_cError)
					lRet := .F.
					
                EndIf
                        
            EndIf

		EndIf
        SD1->(dbSkip())
    EndDo
EndIf

RestArea(aArea)
nModulo := nModAux

Return lRet


//---------------------------------------------------------------------
/*/{Protheus.doc} fBaixaOP
Rotina para baixar Ordem Produção

@author     Dirlei@uxpert
@since      10/11/2022

@return     Nil, Nenhum
@type       function
/*/
//---------------------------------------------------------------------
Static Function fBaixaOP()

// INCLUSÃO 
Local aArea	:= GetArea()
Local nModAux := nModulo
Local aOrdem := {}          
Local cTpMov := SuperGetMV("MV_TMPAD",.F.,"010")

nModulo := 4 // Estoque/Custos
lMsErroAuto := .F.   
       

dbSelectArea("SD1")
SD1->(dbSetOrder(1)) // D1_FILIAL + D1_DOC + D1_SERIE + D1_FORNECE + D1_LOJA

If SD1->(dbSeek(xFilial("SD1") + SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA))

	// Posiciona produto
    SB1->(dbSeek(xFilial("SB1") + _cProdOp))

	aOrdem := { {"D3_OP"     , SD1->D1_OP    , Nil},;
				{"D3_TM"     , cTpMov        , Nil},;
				{"D3_COD"    , _cProdOp       , Nil},;
            	{"D3_QUANT"  , nQtdeOp       , Nil},;
				{"D3_LOCAL"  , SD1->D1_LOCAL/*SB1->B1_LOCPAD*/, Nil},;
				{"D3_EMISSAO", dDataBase     , Nil},;
            	{"D3_PERDA"  , 0             , Nil},;
            	{"D3_PARCTOT", "T"           , Nil},;
	        	{"ATUEMP"    , "T"           , Nil} }

	MSExecAuto({|x, y| MATA250(x, y)},aOrdem, 3)  

	If lMsErroAuto    
    	//MostraErro()
		_cError := MostraErro("/dirdoc", "error.log")
		SendMail(   ,_cMailErr,'','MT103FIM - fbaixaop - Erro Apontamento de OP,NF: '+SD1->D1_FILIAL+'-'+SD1->D1_DOC +'/' +SD1->D1_SERIE,_cError)
		Aviso("Atenção!",_cError,{"Ok"},,,,,.T.,10000)//Alert(_cError)
	Else    
		//MsgInfo("Ordem de Produção "+ SD1->D1_OP +" apontada com sucesso!","Ordem Produção")
		Conout("Ordem de Produção "+ SD1->D1_OP +" apontada com sucesso!")
	EndIf

EndIf

RestArea(aArea)
nModulo := nModAux

Return


//Agrega custo do Servico ao custo medio 
Static Function fServOP()

	Local _atotitem := {}
	Local _aCab1 := {}
	Local _aItem := {} 
	//Local _lContinua := .T.
	

	//Posiciona SB1 se necessário
	If alltrim(SB1->B1_COD) <> alltrim(_cServico)
		dbselectarea('SB1')
		dbsetorder(1)
		dbseek(xfilial('SB1') + _cServico )
	Endif 
	

	//M->D3_DOC := _cServico

	lMsErroAuto := .F.
	//lMsHelpAuto := .T.

	//While _lContinua

	_aCab1 := {{"D3_DOC"    ,NextNumero("SD3",2,"D3_DOC",.T.), NIL},;
        	   {"D3_TM"      ,"021"	 , NIL},;
       		   {"D3_CC"      , ""		 , NIL},;
               {"D3_EMISSAO" ,ddatabase, NIL}}

	_aItem:={{"D3_COD"   , _cServico     ,NIL},;
 		 	 {"D3_UM"     , SB1->B1_UM    ,NIL},; 
  			 {"D3_QUANT"  , 0 		     ,NIL},;
			 {"D3_CF"     , "DE6"         ,NIL},;
			 {"D3_CONTA"  , SB1->B1_CONTA ,NIL},;
  			 {"D3_LOCAL"  , SD1->D1_LOCAL ,NIL},;
			 {"D3_GRUPO"  , SB1->B1_GRUPO ,NIL},;
			 {"D3_CUSTO1" ,  SD1->D1_CUSTO,NIL},; 
  			 {"D3_LOTECTL", ""            ,NIL},;
  			 {"D3_LOCALIZ", " "           ,NIL},;
			 {"D3_XOP"	  , SD1->D1_OP	 ,NIL}}
	
	aadd(_atotitem,_aitem)	
	MSExecAuto({|x,y,z| MATA241(x,y,z)},_aCab1,_atotitem,3)	
	
	If lMsErroAuto 
		//Mostraerro()
		_cError := MostraErro("/dirdoc", "error.log")
		SendMail(   ,_cMailErr,'','MT103FIM - Fservop - Erro Apontamento de OP,NF: '+SD1->D1_FILIAL+'-'+SD1->D1_DOC +'/' +SD1->D1_SERIE,_cError)
        Aviso("Atenção!",_cError,{"Ok"},,,,,.T.,10000)//Alert(_cError) 
	Endif 

	If !lMsErroAuto 
		_atotitem := {}
		
		_aCab1 := { {"D3_DOC"     ,NextNumero("SD3",2,"D3_DOC",.T.), NIL},;
					{"D3_TM"      ,"521"	 , NIL},;
					{"D3_CC"      , ""		 , NIL},;
					{"D3_EMISSAO" ,ddatabase, NIL}}

		_aItem := { {"D3_COD"    ,_cServico  	 ,NIL},;
					{"D3_UM"     ,SB1->B1_UM 	 ,NIL},; 
					{"D3_QUANT"  ,0 		 	 ,NIL},;
					{"D3_CF"     ,"RE6" 	 	 ,NIL},;
					{"D3_CONTA"  ,SB1->B1_CONTA  ,NIL},;
					{"D3_LOCAL"  ,SD1->D1_LOCAL  ,NIL},;
					{"D3_GRUPO"  ,SB1->B1_GRUPO  ,NIL},;
					{"D3_CUSTO1" , SD1->D1_CUSTO ,NIL},; 
					{"D3_LOTECTL",""			 ,NIL},;
					{"D3_LOCALIZ", " "			 ,NIL},;
					{"D3_OP", SD1->D1_OP	 ,NIL}}
	
		aadd(_atotitem,_aitem)	
		MSExecAuto({|x,y,z| MATA241(x,y,z)},_aCab1,_atotitem,3)	
	
		If lMsErroAuto 
			//Mostraerro() 
			_cError := MostraErro("/dirdoc", "error.log")
			SendMail(   ,_cMailErr,'','MT103FIM - fServOP - Erro na OP,NF: '+SD1->D1_FILIAL+'-'+SD1->D1_DOC +'/' +SD1->D1_SERIE,_cError)
            Aviso("Atenção!",_cError,{"Ok"},,,,,.T.,10000)//Alert(_cError)
		Endif 

	Endif 

Return  

//Agrega o Custo do CTE da Remessa no produto Ureia
Static Function fCustoCte(xLocal)
	
	Local _atotitem := {}
	Local _aCab1 := {}
	Local _aItem := {} 
	Local _aSb1a := SB1->(getArea())
	
	DbSelectarea('SD3')
    If FieldPos("D3_XCHVNFE") == 0
		Return
	Endif 
	//Posiciona SB1 se necessário
	If alltrim(SB1->B1_COD) <> alltrim(_cProduto)
		dbselectarea('SB1')
		dbsetorder(1)
		dbseek(xfilial('SB1') + _cProduto )
	Endif 

	lMsErroAuto := .F.
	
	_aCab1 := {{"D3_DOC"    ,NextNumero("SD3",2,"D3_DOC",.T.), NIL},;
        	   {"D3_TM"      ,"022"	 , NIL},;
       		   {"D3_CC"      , ""		 , NIL},;
               {"D3_EMISSAO" ,ddatabase, NIL}}

	_aItem :={{"D3_COD"   , _cProduto       ,NIL},;
 		 	  {"D3_UM"     , SB1->B1_UM     ,NIL},; 
  			  {"D3_QUANT"  , 0 		        ,NIL},;
			  {"D3_CF"     , "DE6"          ,NIL},;
			  {"D3_CONTA"  , SB1->B1_CONTA  ,NIL},;
  			  {"D3_LOCAL"  , xLocal		    ,NIL},;
			  {"D3_GRUPO"  , SB1->B1_GRUPO  ,NIL},;
			  {"D3_CUSTO1" , SD1->D1_CUSTO  ,NIL},; 
  			  {"D3_LOTECTL", ""             ,NIL},;
  			  {"D3_LOCALIZ", " "            ,NIL},;
			  {"D3_XCHVNFE", SF1->F1_CHVNFE ,NIL},;
			  {"D3_OBSERVA"	  , "CTE:"+SF1->F1_DOC+"-"+SF1->F1_SERIE+"("+SF1->F1_FORNECE+'-'+SF1->F1_LOJA+")"	  ,NIL}}
	
	aadd(_atotitem,_aitem)	
	MSExecAuto({|x,y,z| MATA241(x,y,z)},_aCab1,_atotitem,3)	
	
	If lMsErroAuto 
		//Mostraerro() 
		_cError := MostraErro("/dirdoc", "error.log")
		SendMail(   ,_cMailErr,'','MT103FIM - fCustoCte - Erro na OP,NF: '+SD1->D1_FILIAL+'-'+SD1->D1_DOC +'/' +SD1->D1_SERIE,_cError)
        Aviso("Atenção!",_cError,{"Ok"},,,,,.T.,10000)//Alert(_cError)
	Endif 

	RestArea(_aSb1a)

Return


User Function TestaOP(xDoc,xSerie,xFornece,xLoja,xProduto)//u_TestaOP('000006623','1  ','011998','02','401138         ')

	Default xDoc := '000006623'
	Default xSerie := '1  '
	Default xFornece := '011998'
	Default xLoja := '02'
	Default xitem  := '0001'
	Default xProduto  := '401138         '

	// Geração e apontamento de OP de Beneficiamento ARLA
	Private _cProduto   := PadR((SuperGetMV("AG_PRODREM",.F.,"00338")),TamSX3("B1_COD")[1]) //Produto da remessa
	Private _cProdOp    := PadR((SuperGetMV("AG_PRODOP",.F.,"44380001")),TamSX3("B1_COD")[1])//Produto do retorno
	Private _cServico   := PadR((SuperGetMV("AG_PRDSERV",.F.,"401138")),TamSX3("B1_COD")[1])//Produto do serviço
	Private _lGeraOP    := SuperGetMV("AG_ARLAOP",.F.,.F.)//Gera OP Para ARLA
	Private nQtdeOp     := 0
	Private _cMailErr   := SuperGetMV("AG_PRODERR",.F.,"leandro.h@agricopel.com.br")

	Dbselectarea('SF1')
	Dbsetorder(1)
	If Dbseek(xFilial('SF1') + xDoc + xSerie + xFornece + xLoja )

		Dbselectarea('SD1')
		Dbsetorder(1)
		If Dbseek(xFilial('SD1') + xDoc + xSerie + xFornece + xLoja + xProduto)

			If fGeraOP()

				// Baixa OP
				fBaixaOP()
			EndIf
		
		Endif 

	Endif 


Return 


Static Function SendMail(xFrom, cTo, cCC, cSubject, cMsg, cAttach)
********************************************************************

	Local cServer    := GetMV("MV_RELSERV"),;
		  cAccount   := GetMV("MV_RELACNT"),;
		  cPassword  := GetMV("MV_RELPSW"),;
		  lAutentica := GetMv("MV_RELAUTH")
	Local lEmOk, cError    

	cFrom    := If( Empty(xFrom),"protheus@agricopel.com.br",xFrom)
	
	Begin Sequence 
	
	If !Empty(cServer) .and. !Empty(cAccount)
		CONNECT SMTP SERVER cServer ACCOUNT cAccount PASSWORD cPassword Result lEmOk
		If lEmOk
			If lAutentica
				If !MailAuth(cAccount, cPassword)
					DISCONNECT SMTP SERVER
					MsgInfo("Falha na Autenticacao do Usuario","Alerta")
					lEmOk := .F.
					Break
				EndIf
			EndIf
				
			If cAttach <> Nil
				SEND MAIL FROM cFrom TO cTo CC cCC SUBJECT cSubject BODY cMsg ATTACHMENT cAttach Result lEmOk
			Else
				SEND MAIL FROM cFrom TO cTo CC cCC SUBJECT cSubject BODY cMsg Result lEmOk
			Endif
				
			If !lEmOk
				GET MAIL ERROR cError
				// Conout("Erro no envio de Email - "+cError+" O e-mail '"+cSubject+"' não pôde ser enviado.", "Alerta")
			Else
				//MsgInfo(STR0046, STR0056)//
				// Conout("E-mail enviado com sucesso - "+cTo)
			EndIf
			DISCONNECT SMTP SERVER
		Else
			GET MAIL ERROR cError
			DISCONNECT SMTP SERVER
			// Conout("Erro na conexão com o servidor de Email - "+cError+"O e-mail '"+cSubject+"' não pôde ser enviado.","Alerta")
		EndIf
	Else
		// Conout("Não foi possível enviar o e-mail porque o as informações de servidor e conta de envio não estão configuradas corretamente.", "Alerta")  
		lEmOk := .F.
	EndIf
	
	End Sequence

Return lEmOk
