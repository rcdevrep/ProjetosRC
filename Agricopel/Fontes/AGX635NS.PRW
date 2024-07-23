#INCLUDE "PROTHEUS.CH"
//#INCLUDE "PARMTYPE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"

/*/{Protheus.doc} AGX635NS
//ROTINA DE INTEGRAÇÃO COM DBGINT - NFS de Saída
@author Spiller
@since 11/09/2017
@version undefined
@param aEmpDePara, array, Empresas
@type function
/*/
User Function AGX635NS(aEmpDePara,xReproc)

	Local aEmpPara       := {}
	Local nCountDe       := 0
	Local nCountPara     := 0
	//Local oTmpTable		 := Nil
	Local cEmpPara       := ""
	Local cFilialPara    := ""

	Private nEmpDe       := 0
	Private cCapaNFS     := ""
	Private cAliasNFE    := ""
	Private aIntCAPA	 := {} //Array com Notas que foram integradas
	Private aIntITENS	 := {} //Array com Notas que foram integradas
	Private aLogs		 := {} //Array de Logs
	Private lClearEnv    := .F.
	Default xReproc      := .F.
	Private lReproc      := xReproc
	Private aItens116    := {}
	Private  oError := ErrorBlock({|e| GVErrorlog(e)})


	//bError := ErrorBlock({|oError| U_AGX635LO(aLogs,'AGX635NS','IMPORTACAO NF SAIDA')/*MostraLog(oError:Description,.T.)*/ })
	Begin Sequence

		For nCountDe := 1 To Len(aEmpDePara)

			nEmpDe   := aEmpDePara[nCountDe][1]
			aEmpPara := aEmpDePara[nCountDe][2]

			For nCountPara := 1 To Len(aEmpPara)

				cEmpPara     := aEmpPara[nCountPara][2]
				cFilialPara  := aEmpPara[nCountPara][3]
				nFilde       := aEmpPara[nCountPara][1]

				lClearEnv := .T.
				conout(' AGX635NS '+cEmpPara+' / '+cFilialPara)
				PREPARE ENVIRONMENT Empresa cEmpPara Filial cFilialPara Tables "SA1","SA2","SB1","SF2","SD2","SF3","SE1","SF4","SX5","XXS"

				//RPCSetType()
				If RPCSetEnv(cEmpPara, cFilialPara)

					/*oTmpTable := CriaArqNS(nEmpDe,nFilde)

					cCapaNFS := oTmpTable:GetAlias()*/

					cCapaNFS := CriaArqNS(nEmpDe,nFilde)
					
					If Select(cCapaNFS) <> 0
						nQtdeNFS := (cCapaNFS)->(RecCount())
						//CONOUT('AGX635NS  - QUANT DE NOTAS')
						//CONOUT(nQtdeNFS)
						If nQtdeNFS > 0
							InserirNFS(cCapaNFS)
						Endif

						(cCapaNFS)->(DbCloseArea())
						//oTmpTable:Delete()
						//FreeObj(oTmpTable)
					Else
						conout("AGX635NS - CriaArqNE: Nao foi criar alias "+cCapaNFS)
					Endif

					RPCClearEnv()
					dbCloseAll()
				Else
					conout("AGX635NS - CriaArqNE: Nao foi abrir o ambiente: "+cEmpPara+' - '+cFilialPara)
				Endif 

				RESET ENVIRONMENT

			Next nCountPara

		Next nCountDe

		If len(aLogs) > 0
			//Grava Log
			U_AGX635LO(aLogs,'AGX635NS','IMPORTACAO NF SAIDA')
		Endif

	End Sequence
	ErrorBlock(oError)

Return(aEmpDePara)


//Busca NFS´S para importação
Static Function SelectNS(nEmpOrigem,nFilOrigem)

	Local cCapaNFS := "SelectNS"//GetNextAlias()
	Local cQuery    := ""

	Default nFilOrigem := 0
	Default nEmpOrigem := 1

	cQuery := " SELECT"
	cQuery += " VEN_NOTSAI.GEN_TABEMP_Codigo	AS 	DBEMP  ,"+CHR(13)
	cQuery += " VEN_NOTSAI.GEN_TABFIL_Codigo	AS 	DBFIL  ,"+CHR(13)
	cQuery += " GEN_ESTMUN_Estado    			AS  UFCLI ,"+CHR(13)
	cQuery += " VEN_NOTSAI.GEN_NATOPE_Codigo    AS  NATOP, "+CHR(13)
	cQuery +="  GEN_NATOPE_TES 					AS D2_TES  ,"+CHR(13)//  TES Protheus
	cQuery += " ENDENT.GEN_ENDENT_IF     AS  	CNPJ_CPF   ,"+CHR(13)
	cQuery += " VEN_NOTSAI.VEN_NOTSAI_Numero	AS 	ID     ,"+CHR(13)
	//cQuery += " VEN_NOTSAI_Emissao		 AS 	F2_PREEMIS ,"+CHR(13)
	cQuery += " VEN_NFSEMI_Emissao       AS 	F2_EMISSAO ,"+CHR(13)
	cQuery += " VEN_NOTSAI_TipoNF		 AS 	F2_TIPO    ,"+CHR(13)
	cQuery += " VEN_NOTSAI_FilialDest	 AS 	TRANSFER   ,"+CHR(13)
	cQuery += " VEN_NOTSAI_Cli_Cod		 AS 	DBCLI      ,"+CHR(13)
	cQuery += " VEN_NOTSAI_ECL_Cod		 AS 	DBLOJA     ,"+CHR(13)
	cQuery += " VEN_NOTSAI_Tra_Cod		 AS 	DBTRANS    ,"+CHR(13)
	cQuery += " VEN_NOTSAI_ETr_Cod		 AS 	DBTRANSLOJ ,"+CHR(13)
	cQuery += " VEN_NOTSAI_BIPI			 AS 	F2_BASEIPI ,"+CHR(13)
	cQuery += " VEN_NOTSAI_IPI			 AS 	F2_VALIPI  ,"+CHR(13)
	cQuery += " VEN_NOTSAI_ValorProd	 AS 	F2_VALMERC ,"+CHR(13)
	cQuery += " VEN_NOTSAI_ValorNF		 AS     F2_VALBRUT ,"+CHR(13)
	cQuery += " VEN_NOTSAI_INSS			 AS 	F2_VALINSS ,"+CHR(13)
	cQuery += " VEN_NOTSAI_PIS			 AS 	F2_VALIMP6  ,"+CHR(13)
	cQuery += " VEN_NOTSAI_Cofins		 AS 	F2_VALIMP5 ,"+CHR(13)
	cQuery += " VEN_NOTSAI_CSLL			 AS 	F2_VALCSLL ,"+CHR(13)
	cQuery += " VEN_NOTSAI_BaseST		 AS 	F2_BRICMS  ,"+CHR(13)
	cQuery += " VEN_NOTSAI_ValorST		 AS 	F2_ICMSRET ,"+CHR(13)
	cQuery += " VEN_NOTSAI_PesoLiq		 AS 	F2_PLIQUI  ,"+CHR(13)//--F2_PESOL
	cQuery += " VEN_NOTSAI_PesoBruto	 AS 	F2_PBRUTO  ,"+CHR(13)
	cQuery += " VEN_NOTSAI_Placa		 AS 	F2_PLACA   ,"+CHR(13)
	cQuery += " VEN_NOTSAI_TipoFrete	 AS 	F2_TPFRETE ,"+CHR(13)
	cQuery += " VEN_NOTSAI_ValorFrete	 AS 	F2_VALROMA ,"+CHR(13)
	cQuery += " VEN_NOTSAI_ValorSeguro	 AS 	F2_SEGURO  ,"+CHR(13)
	cQuery += " VEN_NOTSAI_ISS			 AS 	F2_VALISS  ,"+CHR(13)
	cQuery += " VEN_NOTSAI_IRRF			 AS 	F2_VALIRRF ,"+CHR(13)
	cQuery += " VEN_NOTSAI_BPIS			 AS 	F2_BASIMP6  ,"+CHR(13)
	cQuery += " VEN_NOTSAI_BCSLL		 AS 	F2_BASCSLL ,"+CHR(13)
	cQuery += " VEN_NOTSAI_BCOFINS		 AS 	F2_BASIMP5 ,"+CHR(13)
	cQuery += " VEN_NOTSAI_QtdVolume	 AS 	F2_VOLUME1 ,"+CHR(13)
	cQuery += " VEN_NOTSAI_EspecieVolume AS 	F2_ESPECI1 ,"+CHR(13)
	cQuery += " VEN_NOTSAI_ICMS          AS     F2_VALICM  ,"+CHR(13)
	cQuery += " VEN_NOTSAI_BICMS 		 AS     F2_BASEICM ,"+CHR(13)
	cQuery += " CAST(VEN_NFSEMI_Numero AS  CHAR)  AS 	F2_DOC	   ,"+CHR(13)
	cQuery += " CAST(VEN_NFSEMI_Serie AS  CHAR)   AS 	F2_SERIE, "	+CHR(13)
	cQuery += " VEN_NOTSAI_FilialDest    AS     FILDEST , "	+CHR(13)
	cQuery += " VEN_NFSEMI_RXMotivo      AS MSG_MOT, "+CHR(13)
	cQuery += " VEN_NFSEMI_Cancelada     AS CANCELA, "+CHR(13)
	cQuery += " VEN_NFSEMI_NChNFe        AS F2_CHVNFE, "+CHR(13)
	cQuery += " VEN_NOTSAI_ValorFrete    AS F2_FRETE, "+CHR(13)
	cQuery += " VEN_NOTSAI_ValorDespAc   AS F2_DESPESA, "+CHR(13)
	cQuery += " VEN_NFSEMI_DataCanc      AS DT_CANC  "+CHR(13)
	cQuery += " FROM VEN_NOTSAI VEN_NOTSAI" +chr(13)
	cQuery += " INNER JOIN GEN_NATOPE GEN_NATOPE ON VEN_NOTSAI.GEN_NATOPE_Codigo = GEN_NATOPE.GEN_NATOPE_Codigo "+chr(13)
	cQuery += " INNER JOIN GEN_ENDENT ENDENT ON GEN_TABENT_CODIGO = VEN_NOTSAI_Cli_Cod "+CHR(13)
	cQuery += " AND GEN_ENDENT_Codigo = VEN_NOTSAI_ECL_Cod   "+CHR(13)
	cQuery += " INNER JOIN VEN_NFSEMI VEN_NFSEMI ON VEN_NFSEMI.VEN_NOTSAI_Numero = VEN_NOTSAI.VEN_NOTSAI_Numero " +CHR(13)
	cQuery += " AND VEN_NOTSAI.GEN_TABEMP_Codigo = VEN_NFSEMI.GEN_TABEMP_Codigo  "+CHR(13)
	cQuery += " AND VEN_NOTSAI.GEN_TABFIL_Codigo = VEN_NFSEMI.GEN_TABFIL_Codigo  "+CHR(13)
	cQuery += " WHERE (VEN_NOTSAI_DHIntTotvs IS NULL OR VEN_NOTSAI_DHIntTotvs = '1000-01-01 00:00:00' )AND " +CHR(13)
	cQuery += " VEN_NOTSAI.GEN_TABEMP_Codigo = " + cValToChar(nEmpOrigem)
	cQuery += " AND (VEN_NFSEMI_NCStat IN ('100','101','102') OR ( VEN_NOTSAI_TipoNF = 'S' OR VEN_NOTSAI_TipoNF = 'B' ))"	 +CHR(13)

	//Caso filtre por filial inclui o campo
	If nFilOrigem <> 0
		cQuery += " AND  VEN_NOTSAI.GEN_TABFIL_Codigo = " + cValToChar(nFilOrigem)
	Endif
	
	//cQuery += " AND  VEN_NFSEMI_Numero = 11  AND  VEN_NOTSAI_ValorNF = 1005.78 "

	CONOUT('AGX635NS')
	//CONOUT(cQuery)
	U_AGX635CN("DBG")

	If Select(cCapaNFS) <> 0
		dbSelectArea(cCapaNFS)
		(cCapaNFS)->(dbCloseArea())
	Endif

	TCQuery cQuery NEW ALIAS (cCapaNFS)

	TCSETFIELD(cCapaNFS,"DBCLI"   ,"N",14,0)
	TCSETFIELD(cCapaNFS,"DBTRANS" ,"N",14,0)
	TCSETFIELD(cCapaNFS,"F2_VALMERC"   ,"N",14,2)
	TCSETFIELD(cCapaNFS,"F2_VALBRUT"   ,"N",14,2)
	TCSETFIELD(cCapaNFS,"F2_BASIMP6"   ,"N",14,2)
	TCSETFIELD(cCapaNFS,"F2_VALIMP6"   ,"N",14,2)
	TCSETFIELD(cCapaNFS,"F2_BASIMP5"   ,"N",14,2)
	TCSETFIELD(cCapaNFS,"F2_VALIMP5"   ,"N",14,2)



Return(cCapaNFS)


//Inserir Dados no Protheus
Static Function InserirNFS(cCapaNFS)

	Local lRegOK     := .T.
	Local cContaCF   :=  ""
	Private cFil     := ''
	Private cTipoNf  := ''
	Private cCliFor  := ""
	Private cLoja    := ""


	U_AGX635CN("PRT")

	(cCapaNFS)->(dbgotop())
	While (cCapaNFS)->(!eof())

		//Conout('AGX635NS: Validando Registro: '+(cCapaNFS)->(F2_DOC)+'-'+(cCapaNFS)->(F2_SERIE))

		//Adequa Tipo de Nota fiscal
		//N = Nota Fiscal Normal   ;D = Devolução      ;  C = Nota Complementar ou Conhec.;Transp.I = Nota Complementar de ICMS;P = Nota Complementar de IPI
		//(V-Venda,T-Transferencia, D-Devolucação Venda,  C-Complemento, S-Serviço, E-Entrada, M-Devolução de Compra)
		If alltrim((cCapaNFS)->F2_TIPO ) == 'V'  .OR. alltrim((cCapaNFS)->F2_TIPO ) == 'T' .OR. alltrim((cCapaNFS)->F2_TIPO ) == 'S'
			cTipoNf := 'N'
		Elseif alltrim((cCapaNFS)->F2_TIPO ) == 'M' .OR. alltrim((cCapaNFS)->F2_TIPO ) == 'D'
			cTipoNf := 'D'
		Elseif alltrim((cCapaNFS)->F2_TIPO ) == 'P'
			cTipoNf := 'C'
		Elseif alltrim((cCapaNFS)->F2_TIPO ) == 'E'
			cTipoNf := 'E'
		Else
			cTipoNf := (cCapaNFS)->F2_TIPO
		Endif

		//Se For uma devolução, carrega o fornecedor
		If cTipoNf == 'D' .OR. cTipoNf == 'E'

			SA2->(DbSetOrder(3))
			SA2->(DbGoTop())
			If !SA2->(DbSeek(xFilial("SA2")+(cCapaNFS)->(CNPJ_CPF)))
				//Inclui Cliente
				cContaCF :=  U_AGX635CF((cCapaNFS)->(CNPJ_CPF),'SA2')
			Else
				cContaCF := SA2->A2_CONTA
			Endif
			cCliFor  := SA2->A2_COD
			cLoja    := SA2->A2_LOJA

			If alltrim(SA2->A2_CONTA) == ''  .or. alltrim(cContaCF) == ""
				lRegOK := .F.
				// {'ZDB_EMP','ZDB_FIL','ZDB_MSG','ZDB_DATA','ZDB_HORA'}
				//GRAVA Array de LOG
				AADD(aLogs,{;
					{'ZDB_DBEMP'  ,(cCapaNFS)->(DBEMP)},;
					{'ZDB_DBFIL'  ,(cCapaNFS)->(DBFIL)},;
					{'ZDB_MSG'	  ,'Fornecedor sem conta: '+(cCapaNFS)->(CNPJ_CPF)},;
					{'ZDB_DATA'	  ,ddatabase},;
					{'ZDB_HORA'	  ,time()},;
					{'ZDB_EMP'	  ,cEmpant},;
					{'ZDB_FILIAL' ,cFilAnt},;
					{'ZDB_DBCHAV' ,(cCapaNFS)->(F2_DOC)+'+'+(cCapaNFS)->(F2_SERIE)+'+'+alltrim(str((cCapaNFS)->(DBCLI)))+'+'+alltrim(str((cCapaNFS)->(DBLOJA)))},;
					{'ZDB_TAB' 	  ,'SA1'},;
					{'ZDB_INDICE' ,3},;
					{'ZDB_TIPOWF' ,8},;
					{'ZDB_CHAVE'  ,(cCapaNFS)->(CNPJ_CPF)};
					})
				//conout('AGX635NS Fornecedor sem conta : '+(cCapaNFS)->(F2_DOC)+'+'+(cCapaNFS)->(F2_SERIE))
				(cCapaNFS)->(dbskip())
				LOOP
			Endif

		Else

			SA1->(DbSetOrder(3))
			SA1->(DbGoTop())
			If !SA1->(DbSeek(xFilial("SA1")+(cCapaNFS)->(CNPJ_CPF)))
				//Inclui Cliente
				cContaCF := U_AGX635CF((cCapaNFS)->(CNPJ_CPF),'SA1')

				If alltrim(SA1->A1_CONTA) == ''  .or. alltrim(cContaCF) == ""
					lRegOK := .F.
					// {'ZDB_EMP','ZDB_FIL','ZDB_MSG','ZDB_DATA','ZDB_HORA'}
					//GRAVA Array de LOG
					AADD(aLogs,{;
						{'ZDB_DBEMP'  ,(cCapaNFS)->(DBEMP)},;
						{'ZDB_DBFIL'  ,(cCapaNFS)->(DBFIL)},;
						{'ZDB_MSG'	  ,'Cliente sem conta: '+(cCapaNFS)->(CNPJ_CPF)},;
						{'ZDB_DATA'	  ,ddatabase},;
						{'ZDB_HORA'	  ,time()},;
						{'ZDB_EMP'	  ,cEmpant},;
						{'ZDB_FILIAL' ,cFilAnt},;
						{'ZDB_DBCHAV' ,(cCapaNFS)->(F2_DOC)+'+'+(cCapaNFS)->(F2_SERIE)+'+'+alltrim(str((cCapaNFS)->(DBCLI)))+'+'+alltrim(str((cCapaNFS)->(DBLOJA)))},;
						{'ZDB_TAB' 	  ,'SA1'},;
						{'ZDB_INDICE' ,3},;
						{'ZDB_TIPOWF' ,8},;
						{'ZDB_CHAVE'  ,(cCapaNFS)->(CNPJ_CPF)};
						})
					(cCapaNFS)->(dbskip())
					LOOP
				Endif
			Endif
			cCliFor  := SA1->A1_COD
			cLoja    := SA1->A1_LOJA
		Endif

		aTam    := {}
		aTam    := TamSX3("F2_DOC")
		_cDoc   := PADL(alltrim((cCapaNFS)->(F2_DOC)),aTam[1],'0')

		aTam    := {}
		aTam    := TamSX3("F2_SERIE")
		_cSerie := PADR(alltrim((cCapaNFS)->(F2_SERIE)),aTam[1],' ')

		cEspecie := ""
		cEspecie := "SPED"
		//Chamado[71330] - Gravar como NFS notas de serviço
		IF alltrim((cCapaNFS)->F2_TIPO ) == 'S'
			cEspecie := "NFS"
		Endif
		//CONOUT('**** LINHA 312')
		//Verifica se já existe no Protheus
		dbselectarea('SF2')
		dbsetorder(1)
		If dbseek(xfilial('SF2')+_cDoc+_cSerie+cCliFor+cLoja) .AND. !( alltrim(cTipoNf) $ 'E/B')
			// {'ZDB_EMP','ZDB_FIL','ZDB_MSG','ZDB_DATA','ZDB_HORA'}
			//Se For um cancelamento Exclui
			If  (cCapaNFS)->(CANCELA) <> 'N'
				ExcluirSF2(SF2->F2_DOC, SF2->F2_SERIE, SF2->F2_CLIENTE, SF2->F2_LOJA, SF2->F2_FILIAL, (cCapaNFS)->DT_CANC,cTipoNf,cEspecie , SF2->F2_PREFIXO)
			Else
				//GRAVA Array de LOG
				AADD(aLogs,{;
					{'ZDB_DBEMP'  ,(cCapaNFS)->(DBEMP)},;
					{'ZDB_DBFIL'  ,(cCapaNFS)->(DBFIL)},;
					{'ZDB_MSG'	  ,'Nota Fiscal saída já existe: '+(cCapaNFS)->(F2_DOC)+'-'+(cCapaNFS)->(F2_SERIE)+'('+cCliFor+cLoja+')'},;
					{'ZDB_DATA'	  ,ddatabase},;
					{'ZDB_HORA'	  ,time()},;
					{'ZDB_EMP'	  ,cEmpant},;
					{'ZDB_FILIAL' ,cFilAnt},;
					{'ZDB_DBCHAV' , (cCapaNFS)->(ID) },;
					{'ZDB_TAB' 	  ,'SF2'},;
					{'ZDB_INDICE' ,1},;
					{'ZDB_TIPOWF' ,8},;
					{'ZDB_CHAVE'  ,xfilial('SF2')+_cDoc+_cSerie+cCliFor+cLoja};
					})
			Endif

			(cCapaNFS)->(dbskip())
			LOOP
		Endif

		DbSelectArea( "SX5" )
		DbSetOrder(1)
		IF !(DbSeek( xFilial( "SX5" ) + "42" + cEspecie )) .AND.!( alltrim(cTipoNf) $ 'E/B')

			If !lReproc
				//GRAVA Array de LOG
				AADD(aLogs,{;
					{'ZDB_DBEMP'  ,(cCapaNFS)->(DBEMP)},;
					{'ZDB_DBFIL'  ,(cCapaNFS)->(DBFIL)},;
					{'ZDB_MSG'	  ,'Especie Invalida: '+cEspecie},;
					{'ZDB_DATA'	  ,ddatabase},;
					{'ZDB_HORA'	  ,time()},;
					{'ZDB_EMP'	  ,cEmpant},;
					{'ZDB_FILIAL' ,cFilAnt},;
					{'ZDB_TAB'	  ,'SX5'},;
					{'ZDB_INDICE' ,1},;
					{'ZDB_TIPOWF' ,5},;
					{'ZDB_CHAVE'  ,"42" + cEspecie};
					})
			Else
				Alert('Especie Invalida: '+cEspecie)
			Endif
			(cCapaNFS)->(dbskip())
			LOOP
		Endif

		//Conout('AGX635NS: Incluindo registro: '+_cDoc+'-'+_cSerie)

		U_AGX635CN("PRT")
		
		//Para esse tipo de nota é feita uma entrada
		If alltrim(cTipoNf) == 'E'

			//Captura dados da Empresa, posicao 22 é UF
			aArrayEmp := FWArrFilAtu()
			cUFEmp   := substr( alltrim(aArrayEmp[22]) ,  len(alltrim(aArrayEmp[22]))-1,  len(alltrim(aArrayEmp[22]) ))

			//Inicia a Transação
			BEGIN TRANSACTION //Begintran()

				nRecF1 := 0
				lOkProd := .F.
				nRecF1 := CabEntrada()
				lOkProd := IteEntrada((cCapaNFS)->ID,(cCapaNFS)->DBEMP,(cCapaNFS)->DBFIL,cUFEmp)

				If lOkProd
					//Empresa           ,  Filial              , Documento                        , Serie, Fornece				, Loja
					AADD(aIntCAPA,{(cCapaNFS)->DBEMP, (cCapaNFS)->DBFIL, (cCapaNFS)->(ID)})//(cCapaNFS)->F2_DOC,(cCapaNFS)->F2_SERIE , (cCapaNFS)->DBLOJA , (cCapaNFS)->DBLOJA  })
					EditTxt("\logs\AGX635NS.log",dtos(date())+" "+"AGX635NZ: "+"TIPO E Gravou aInTCapa: "+alltrim(str((cCapaNFS)->DBEMP))+alltrim(str((cCapaNFS)->DBFIL))+alltrim(str( (cCapaNFS)->(ID)))+" ")

					//Se for uma Devolução gera contas a pagar
					TITEntrada((cCapaNFS)->(ID),(cCapaNFS)->DBEMP, (cCapaNFS)->DBFIL)
				Else
					DisarmTransaction()//Faz rollBack da transação
				Endif

				//Destrava todas as conexões
				MsUnlockAll()
			END TRANSACTION //Begintran()

			If nRecF1 > 0

				DbSelectarea('SF1')
				DbGoto(nRecF1)

				//Se For um cancelamento Exclui
				If  (cCapaNFS)->(CANCELA) <> 'N'
					U_AGX635JB(SF1->F1_VALBRUT)
				Endif

			Endif
		Elseif alltrim(cTipoNf) == 'B'

			//Se gerou dados Grava para baixar o registro
			If ProcCRB((cCapaNFS)->(ID),(cCapaNFS)->DBEMP, (cCapaNFS)->DBFIL)
				AADD(aIntCAPA,{(cCapaNFS)->DBEMP, (cCapaNFS)->DBFIL, (cCapaNFS)->(ID)})
				EditTxt("\logs\AGX635NS.log",dtos(date())+" "+"AGX635NZ: "+"Gravou aInTCapa: "+alltrim(str((cCapaNFS)->DBEMP))+alltrim(str((cCapaNFS)->DBFIL))+alltrim(str( (cCapaNFS)->(ID)))+" ")
			else
				EditTxt("\logs\AGX635NS.log",dtos(date())+" "+"AGX635NZ: "+"NAO GRAVOU aInTCapa: "+alltrim(str((cCapaNFS)->DBEMP))+alltrim(str((cCapaNFS)->DBFIL))+alltrim(str( (cCapaNFS)->(ID)))+" ")
			Endif

		Else
			//Inicia a Transação
			BEGIN TRANSACTION //Begintran()

				RecLock("SF2" , .T.)
				SF2->F2_FILIAL  := xFilial('SF2')
				SF2->F2_DOC 	:= _cDoc
				SF2->F2_SERIE   := _cSerie
				SF2->F2_CLIENTE := cCliFor
				SF2->F2_LOJA    := cLoja
				SF2->F2_COND    := "001"
				SF2->F2_DUPL    := _cDoc
				SF2->F2_EMISSAO := (cCapaNFS)->F2_EMISSAO
				SF2->F2_EST     := SA1->A1_EST
				SF2->F2_TIPOCLI := SA1->A1_TIPO
				SF2->F2_VALBRUT := (cCapaNFS)->(F2_VALBRUT)
				SF2->F2_VALICM  := (cCapaNFS)->(F2_VALICM)
				SF2->F2_BASEICM := (cCapaNFS)->(F2_BASEICM)
				SF2->F2_VALMERC := (cCapaNFS)->(F2_VALMERC)
				SF2->F2_VALFAT  := (cCapaNFS)->(F2_VALMERC)
				SF2->F2_TIPO    := cTipoNf//(cCapaNFS)->F2_TIPO  //*** Ver aqui
				SF2->F2_VOLUME1 := (cCapaNFS)->F2_VOLUME1//SF2->F2_VOLUME1 := 1
				SF2->F2_PLIQUI  := (cCapaNFS)->F2_PLIQUI
				SF2->F2_PBRUTO  := (cCapaNFS)->F2_PBRUTO
				SF2->F2_ESPECIE := cEspecie//**Ver aqui
				SF2->F2_PREFIXO := substr(_cSerie,1,3)
				SF2->F2_MOEDA   := 1
				SF2->F2_TPFRETE := (cCapaNFS)->F2_TPFRETE
				SF2->F2_ORIIMP  := "AGX635NS"
				SF2->F2_CHVNFE	:= (cCapaNFS)->F2_CHVNFE
				SF2->F2_BASIMP5 := (cCapaNFS)->(F2_BASIMP5)//PIS/COFINS Apuração
				SF2->F2_BASIMP6 := (cCapaNFS)->(F2_BASIMP6)
				SF2->F2_VALIMP5 := (cCapaNFS)->(F2_VALIMP5)
				SF2->F2_VALIMP6 := (cCapaNFS)->(F2_VALIMP6)
				SF2->F2_PLACA   := SUBSTR(alltrim((cCapaNFS)->F2_PLACA),1,3)+SUBSTR(alltrim((cCapaNFS)->F2_PLACA),5,4)
				SF2->F2_VALINSS := (cCapaNFS)->F2_VALINSS

				SF2->F2_VALCSLL := (cCapaNFS)->F2_VALCSLL
				SF2->F2_BRICMS  := (cCapaNFS)->F2_BRICMS
				SF2->F2_ICMSRET := (cCapaNFS)->F2_ICMSRET
				SF2->F2_VALROMA := (cCapaNFS)->F2_VALROMA
				SF2->F2_SEGURO  := (cCapaNFS)->F2_SEGURO
				SF2->F2_VALISS  := (cCapaNFS)->F2_VALISS
				SF2->F2_VALIRRF := (cCapaNFS)->F2_VALIRRF
				SF2->F2_DESPESA := (cCapaNFS)->F2_DESPESA
				SF2->F2_FRETE   := (cCapaNFS)->F2_FRETE
				SF2->F2_BASCSLL := (cCapaNFS)->F2_BASCSLL

				SF2->(Msunlock())

				//Conout('FIM Incluindo NFS SF2: '+_cDoc+'-'+_cSerie)

				//Captura dados da Empresa, posicao 22 é UF
				aArrayEmp := FWArrFilAtu()
				cUFEmp   := substr( alltrim(aArrayEmp[22]) ,  len(alltrim(aArrayEmp[22]))-1,  len(alltrim(aArrayEmp[22]) ))
				lOkProd := .F.

				//Insere produtos referentes a Nota Fiscal
				If alltrim((cCapaNFS)->(F2_TIPO)) == 'S'
					lOkProd := GravaServ((cCapaNFS)->ID,(cCapaNFS)->DBEMP,(cCapaNFS)->DBFIL,cUFEmp)
				Else
					lOkProd := GravaProd((cCapaNFS)->ID,(cCapaNFS)->DBEMP,(cCapaNFS)->DBFIL,cUFEmp)
				Endif

				If !lOkProd
					DisarmTransaction()
				Endif

				MsUnlockAll()
			END TRANSACTION //EndTran() //Finaliza Transação

			// Se inseriu corretamente o produto
			// Grava Array de Atualização dos dados, Senão desarma a Transação
			If lOkProd
				//Empresa           ,  Filial              , Documento                        , Serie, Fornece				, Loja
				AADD(aIntCAPA,{(cCapaNFS)->DBEMP, (cCapaNFS)->DBFIL, (cCapaNFS)->(ID)})//(cCapaNFS)->F2_DOC,(cCapaNFS)->F2_SERIE , (cCapaNFS)->DBLOJA , (cCapaNFS)->DBLOJA  })
				EditTxt("\logs\AGX635NS.log",dtos(date())+" "+"AGX635NZ: "+"ELSE Gravou aInTCapa: "+alltrim(str((cCapaNFS)->DBEMP))+alltrim(str((cCapaNFS)->DBFIL))+alltrim(str( (cCapaNFS)->(ID)))+" ")

				//Se for uma Devolução gera contas a pagar
				If cTipoNf == 'D'
					ProcCP((cCapaNFS)->(ID),(cCapaNFS)->DBEMP, (cCapaNFS)->DBFIL)
				Else
					ProcCR((cCapaNFS)->(ID),(cCapaNFS)->DBEMP, (cCapaNFS)->DBFIL)
				Endif

				//Chamado[12484]: Não estava cancelando notas que foram geradas e canceladas antes da importação
				If  (cCapaNFS)->(CANCELA) == 'S'.AND. cTipoNf <> 'E'
					ExcluirSF2(SF2->F2_DOC, SF2->F2_SERIE, SF2->F2_CLIENTE, SF2->F2_LOJA, SF2->F2_FILIAL, (cCapaNFS)->DT_CANC,cTipoNf,cEspecie, SF2->F2_PREFIXO)
				Endif

			Endif

		Endif
		(cCapaNFS)->(dbskip())
	Enddo

	// MARCA DATA/HORA PARA IDENTIFICAR QUE REGISTRO FOI IMPORTADOS
	If Len(aIntCAPA) > 0
		BaixarNFS(aIntCAPA)
		aIntCAPA := {}
	Endif

Return()


Static Function CriaArqNS(nEmpOrigem,nFilOrigem)

	Local aStruTmp     := {}
	//Local oTmpTable    := Nil
	Local cFieldName   := ""
	Local cAliasQry    := ""
	Local cAliasArea   := ""
	Local nFieldCount  := 0
	Local nX		   := 0

	cAliasQry := SelectNS(nEmpOrigem,nFilOrigem)

	aStruTmp := (cAliasQry)->(DbStruct())

	/*oTmpTable := FwTemporaryTable():New()
	oTmpTable:SetFields(aStruTmp)
	oTmpTable:AddIndex("1", {aStruTmp[1][1]})
	oTmpTable:Create()

	cAliasArea := oTmpTable:GetAlias()*/

	cAliasArea := "CriaArqNS"//GetNextAlias()
	cArquivo := CriaTrab(,.F.)
	dbCreate(cArquivo,aStruTmp)
	dbUseArea(.T.,__LocalDriver,cArquivo,cAliasArea,.F.,.F.)

	nFieldCount := (cAliasArea)->(FCount())

	While !(cAliasQry)->(Eof())

		RecLock((cAliasArea), .T.)

		For nX := 1 To nFieldCount
			cFieldName := (cAliasArea)->(FieldName(nX))
			(cAliasArea)->&(cFieldName) := (cAliasQry)->&(cFieldName)
		Next nX

		MsUnlock((cAliasArea))
		(cAliasQry)->(DbSkip())
	End

Return(cAliasArea)


//Grava Data/hora da Importação
Static Function BaixarNFS(xIntCapa)

	Local cNFSIN   := ""
	Local nQtdeIN  := 0
	Local i        := 0

	U_AGX635CN("DBG")

	For i := 1 to len(xIntCapa)

		//Monta Clausula Where do documento
		If nQtdeIN == 0
			cNFSIN := " AND (("
		Else
			cNFSIN += " ) OR ("
		Endif
		cNFSIN += " GEN_TABEMP_Codigo 	  =  "+alltrim(str(xIntCapa[i][1]))+""
		cNFSIN += " AND GEN_TABFIL_Codigo	  =  "+alltrim(str(xIntCapa[i][2]))+""
		cNFSIN += " AND VEN_NOTSAI_Numero		  =  "+alltrim(str(xIntCapa[i][3]))+""

		nQtdeIN += 1

		If (nQtdeIN >= 10) .Or. len(xIntCapa) == i

			cNFSIN += ") )"

			UpdateNFS(cNFSIN)

			nQtdeIN := 0
			cNFSIN := ""
		EndIf
	Next i

Return()

Static Function UpdateNFS(cNFSIN)

	Local cQuery   := ""

	//Atualiza CAPA
	cQuery += " UPDATE VEN_NOTSAI SET "
	cQuery += " VEN_NOTSAI_DHIntTotvs = current_timestamp() "
	cQuery += " WHERE ( (VEN_NOTSAI_DHIntTotvs IS NULL OR  VEN_NOTSAI_DHIntTotvs = '1000-01-01 00:00:00' )"
	cQuery += cNFSIN +") "
	//conout(cQuery)
	EditTxt("\logs\AGX635NS.log",dtos(date())+" "+cQuery)

	If (TCSQLExec(cQuery) < 0)
		Conout("Falha ao executar SQL: " + cQuery)
		Conout("TCSQLError() - " + TCSQLError())
	EndIf

Return()


//*********************
//  Contas a Receber 
//*********************
Static Function ProcCR(xIDNFS,xEmp,xFil)

	Local lRet      := .F.
	Local cPrefixo  := ""
	Local cAliasSE1 := "AGX635SE1N"
	Local cQuery     := ""
	Local aBaixa 	 := {}

	cQuery := " SELECT  "
	cQuery += "	GEN_TABEMP_Codigo  	  AS DBEMP, "
	cQuery += " GEN_TABFIL_Codigo  	  AS DBFIL, "
	cQuery += " VEN_NOTSAI_Numero  	  AS ID_NFS, "
	cQuery += " VEN_FINNFS_Parcela 	  AS E1_PARCELA,"
	cQuery += " VEN_FINNFS_Valor   	  AS E1_VALOR, "
	cQuery += " VEN_FINNFS_Vencimento AS E1_VENCTO, "
	cQuery += " CXB_TABBAN_Codigo     AS E1_BANCO  "
	cQuery += "FROM VEN_FINNFS "
	cQuery += "WHERE "
	cQuery += " VEN_NOTSAI_Numero = "+alltrim(str(xIDNFS))+" AND "
	cQuery += " GEN_TABFIL_Codigo = "+alltrim(str(xFil))+" AND "
	cQuery += " GEN_TABEMP_Codigo= "+alltrim(str(xEmp))+" "

	U_AGX635CN("DBG")
	//CONOUT(cQuery)

	If Select(cAliasSE1) <> 0
		dbSelectArea(cAliasSE1)
		(cAliasSE1)->(dbclosearea())
	Endif

	TCQuery cQuery NEW ALIAS (cAliasSE1)

	(cAliasSE1)->(dbgotop())

	//se não encontra Registros,sai da rotina
	If (cAliasSE1)->(eof())
		Return
	endif

	cFil := cFilant//STRZERO((cAliasSE1)->DBEMP,2)

	U_AGX635CN("PRT")

	//** Adequa Campo Doc e Serie
	aTam    := {};aTam    := TamSX3("F2_DOC");     _cDoc   := PADL(alltrim((cCapaNFS)->(F2_DOC)),aTam[1],'0')
	aTam    := {};aTam    := TamSX3("F2_SERIE")	;  _cSerie := PADR(alltrim((cCapaNFS)->(F2_SERIE)),aTam[1],' ')

	//CONOUT('Inserindo SE1 '+_cDoc+' - '+_cSerie )

	//Posiciona CLIENTE
	SA1->(DbSetOrder(3))
	SA1->(DbGoTop())
	SA1->(DbSeek(xFilial("SA1")+(cCapaNFS)->(CNPJ_CPF)))

	//Posiciona no Documento
	dbselectarea('SF2')
	SF2->(dbsetorder(1));SF2->(DbGoTop())
	SF2->(dbseek(xfilial('SF2')+_cDoc+_cSerie+SA1->A1_COD+SA1->A1_LOJA))


	lTitBaixad := .F.



	//Verifica se Existe Título Gerado
	dbselectarea('SE1')
	dbsetorder(2)  // E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
	If !dbseek(xfilial('SE1')+SF2->F2_CLIENTE+SF2->F2_LOJA+SF2->F2_PREFIXO+SF2->F2_DOC)
		If dbseek(xfilial('SE1')+SF2->F2_CLIENTE+SF2->F2_LOJA+cFilAnt+SF2->F2_PREFIXO+SF2->F2_DOC)
			If Empty(SE1->E1_BAIXA)
				Reclock('SE1',.F.)
				dbdelete()
				Msunlock()
			Else
				lTitBaixad := .T.
			Endif
		Endif
	Else
		If dbseek(xfilial('SE1')+SF2->F2_CLIENTE+SF2->F2_LOJA+cFilAnt+SF2->F2_PREFIXO+SF2->F2_DOC)
			if Alltrim(SF2->F2_FILIAL) == Alltrim(SE1->E1_FILORIG)
				If Empty(SE1->E1_BAIXA)
					Reclock('SE1',.F.)
					dbdelete()
					Msunlock()
				Else
					lTitBaixad := .T.
				Endif
			Endif
		Endif
	Endif

	//Se Título já foi baixado
	If lTitBaixad

		//GRAVA Array de LOG
		AADD(aLogs,{;
			{'ZDB_DBEMP'  ,(cCapaNFS)->(DBEMP)},;
			{'ZDB_DBFIL'  ,(cCapaNFS)->(DBFIL)}								,;
			{'ZDB_MSG'	  ,	'Título já baixado: '+SE1->E1_FILIAL+SE1->E1_CLIENTE+SE1->E1_LOJA+SE1->E1_PREFIXO+SE1->E1_NUM},;
			{'ZDB_DATA'	  ,ddatabase},;
			{'ZDB_HORA'	  ,time()},;
			{'ZDB_EMP'	  ,cEmpant},;
			{'ZDB_FILIAL' ,cFilAnt},;
			{'ZDB_DBCHAV' ,_cDoc+'+'+_cSerie+'+'+SA1->A1_COD+'+'+SA1->A1_LOJA},;
			{'ZDB_TAB' 	  ,'SE1'},;
			{'ZDB_INDICE' ,1	},;
			{'ZDB_TIPOWF' ,4},;
			{'ZDB_CHAVE'  , SE1->E1_FILIAL+SE1->E1_CLIENTE+SE1->E1_LOJA+SE1->E1_PREFIXO+SE1->E1_NUM};
			})
		Return .F.
	Endif


	DbSelectArea(cAliasSE1)
	dbGotop()
	While (cAliasSE1)->(!eof())


		aTam     := {}
		aTam     := TamSX3("E1_NUM")
		cTitulo  := ""
		cTitulo  := SF2->F2_DOC//StrZero(MSE1->E1_NUM,aTam[1])
		cSerie   := ""
		cSerie   := substr(alltrim(SF2->F2_SERIE),1,3)
		cForCod	 := SF2->F2_CLIENTE
		cForLoja := SF2->F2_LOJA
		cForNome := POSICIONE('SA1',1,xfilial('SA1')+cForCod+cForLoja,'A1_NOME')

		cFilEnt  := SF2->F2_FILIAL
		cPrefixo := ""
		do Case
		Case cFilEnt == "01"
			cPrefixo := SubStr(cSerie,1,2)+"A"
		Case cFilEnt == "02"
			cPrefixo := SubStr(cSerie,1,2)+"B"
		Case cFilEnt == "03"
			cPrefixo := SubStr(cSerie,1,2)+"C"
		Case cFilEnt == "04"
			cPrefixo := SubStr(cSerie,1,2)+"D"
		Case cFilEnt == "05"
			cPrefixo := SubStr(cSerie,1,2)+"E"
		Case cFilEnt == "06"
			cPrefixo := SubStr(cSerie,1,2)+"F"
		Case cFilEnt == "07"
			cPrefixo := SubStr(cSerie,1,2)+"G"
		Case cFilEnt == "08"
			cPrefixo := SubStr(cSerie,1,2)+"H"
		Case cFilEnt == "09"
			cPrefixo := SubStr(cSerie,1,2)+"I"
		Case cFilEnt == "10"
			cPrefixo := SubStr(cSerie,1,2)+"J"
		Case cFilEnt == "11"
			cPrefixo := SubStr(cSerie,1,2)+"K"
		Case cFilEnt == "12"
			cPrefixo := SubStr(cSerie,1,2)+"L"
		Case cFilEnt == "13"
			cPrefixo := SubStr(cSerie,1,2)+"M"
		Case cFilEnt == "14"
			cPrefixo := SubStr(cSerie,1,2)+"N"
		Case cFilEnt == "15"
			cPrefixo := SubStr(cSerie,1,2)+"O"
		Case cFilEnt == "16"
			cPrefixo := SubStr(cSerie,1,2)+"P"
		Case cFilEnt == "17"
			cPrefixo := SubStr(cSerie,1,2)+"Q"
		Case cFilEnt == "18"
			cPrefixo := SubStr(cSerie,1,2)+"R"
		Case cFilEnt == "19"
			cPrefixo := SubStr(cSerie,1,2)+"S"
		Case cFilEnt == "20"
			cPrefixo := SubStr(cSerie,1,2)+"T"
		Case cFilEnt == "21"
			cPrefixo := SubStr(cSerie,1,2)+"U"
		Case cFilEnt == "22"
			cPrefixo := SubStr(cSerie,1,2)+"V"
		Case cFilEnt == "23"
			cPrefixo := SubStr(cSerie,1,2)+"W"
		Case cFilEnt == "24"
			cPrefixo := SubStr(cSerie,1,2)+"X"
		Case cFilEnt == "25"
			cPrefixo := SubStr(cSerie,1,2)+"Y"
		Case cFilEnt == "26"
			cPrefixo := SubStr(cSerie,1,2)+"Z"
		EndCase


		cParcela := alltrim(cValToChar((cAliasSE1)->E1_PARCELA)) //StrZero(MSE1->E1_PARCELA,3)

		dEmissao := SF2->F2_EMISSAO
		dVencto  := (cAliasSE1)->E1_VENCTO
		dDtDigit := SF2->F2_EMISSAO

		Begin Transaction
			RecLock("SE1",.T.)
			SE1->E1_PREFIXO		:= cPrefixo
			SE1->E1_NUM			:= cTitulo
			SE1->E1_PARCELA  	:= cParcela
			SE1->E1_CLIENTE		:= cForCod
			SE1->E1_LOJA		:= cForLoja
			SE1->E1_NOMCLI		:= cForNome
			SE1->E1_EMISSAO  	:= dEmissao
			SE1->E1_VENCTO 		:= dVencto
			SE1->E1_VENCREA		:= DataValida(dVencto,.T.)
			SE1->E1_VALOR		:= (cAliasSE1)->E1_VALOR
			SE1->E1_EMIS1 		:= dDtDigit//STOD(cAliasSE1)->E1_EMIS1)
			SE1->E1_HIST		:= "AGX635NS"
			SE1->E1_LA			:= ""
			SE1->E1_SALDO		:= (cAliasSE1)->E1_VALOR
			SE1->E1_VALLIQ		:= (cAliasSE1)->E1_VALOR
			SE1->E1_VENCORI		:= dVencto
			SE1->E1_MOEDA		:= 1
			SE1->E1_VLCRUZ		:= (cAliasSE1)->E1_VALOR
			SE1->E1_ORIGEM		:= "MATA460"
			SE1->E1_NATUREZ  	:= "101009" // "101011"
			SE1->E1_LA 			:= 'S'
			SE1->E1_SITUACA 	:= '0'
			SE1->E1_STATUS 		:= 'A'
			SE1->E1_TIPO 		:= "NF"
			SE1->E1_ORIIMP  	:= "AGX635NS"
			SE1->E1_SERIE       := cSerie
			SE1->E1_FILORIG		:= cFilEnt
			SE1->(MsUnLock())
		End Transaction

		If dEmissao == dVencto// dDtDigit == dVencto    //Realizo baixa automatica se o titulo for a vista.
			lRet    := .F.
			aBaixa := {}
			aBaixa := {{"E1_PREFIXO"  ,cPrefixo               ,Nil    },;
				{"E1_NUM"      ,cTitulo                ,Nil    },;
				{"E1_TIPO"     ,"NF "                  ,Nil    },;
				{"AUTMOTBX"    ,"NOR"                  ,Nil    },;
				{"AUTBANCO"    ,"CX1"                  ,Nil    },;
				{"AUTAGENCIA"  ,"00001"                ,Nil    },;
				{"AUTCONTA"    ,"0000000001"           ,Nil    },;
				{"AUTDTBAIXA"  ,dDtDigit               ,Nil    },;
				{"AUTDTCREDITO",dDtDigit               ,Nil    },;
				{"AUTHIST"     ,'Baixa Automatica'     ,Nil    },;
				{"AUTJUROS"    ,0                      ,Nil,.T.},;
				{"AUTVALREC"   ,(cAliasSE1)->E1_VALOR  ,Nil    }}

			dbSelectArea("SE1")
			SE1->(dbSetOrder(1))
			SE1->(dbGoTop())
			If SE1->(dbSeek(xFilial("SE1") + cPrefixo + cTitulo + cParcela + "NF " ))

				lMsErroAuto := .F.
				//Begin Transaction
				MSExecAuto({|x,y| Fina070(x,y)},aBaixa,3)
				IF lMsErroAuto
					//MOSTRAERRO()
				Else
					//SUCESSO
					lRet := .T.
				Endif

				If lRet
					cQuery := " UPDATE " + RETSQLNAME("SE5")
					cQuery += " SET E5_BANCO = 'CX1', E5_AGENCIA = '00001', E5_CONTA = '0000000001' "
					cQuery += " WHERE E5_PREFIXO = '"  +  cPrefixo        + "' "
					cQuery += "   AND E5_NUMERO     = '"  +  cTitulo        + "' "
					cQuery += "   AND E5_DATA = '"  +  dtos(dDtDigit) + "' "
					cQuery += "   AND E5_CLIFOR = '"  +  cForCod        + "' "
					cQuery += "   AND E5_LOJA    = '"  +  cForLoja      + "' "
					cQuery += "   AND D_E_L_E_T_ <> '*' "
					cQuery += "   AND E5_PARCELA = '" + alltrim(cParcela) + "' "

					TcSqlExec(cQuery)
				EndIf
			Endif
		EndIf

		dbSelectArea(cAliasSE1)
		(cAliasSE1)->(dbskip())
	EndDo

Return()


//*********************
//  Contas a Receber 
//*********************
Static Function ProcCRB(xIDNFS,xEmp,xFil)

	Local lRet      := .F.
	Local cPrefixo  := ""
	Local cAliasSE1 := "AGX635SE1N"
	Local cQuery    := ""
	Local aBaixa 	:= {}
	Local cTipo     := "NDC"
	Local cCCusto   := ""

	cQuery := " SELECT  "
	cQuery += "	GEN_TABEMP_Codigo  	  AS DBEMP, "
	cQuery += " GEN_TABFIL_Codigo  	  AS DBFIL, "
	cQuery += " VEN_NOTSAI_Numero  	  AS ID_NFS, "
	cQuery += " VEN_FINNFS_Parcela 	  AS E1_PARCELA,"
	cQuery += " VEN_FINNFS_Valor   	  AS E1_VALOR, "
	cQuery += " VEN_FINNFS_Vencimento AS E1_VENCTO, "
	cQuery += " CXB_TABBAN_Codigo     AS E1_BANCO  "
	cQuery += "FROM VEN_FINNFS "
	cQuery += "WHERE "
	cQuery += " VEN_NOTSAI_Numero = "+alltrim(str(xIDNFS))+" AND "
	cQuery += " GEN_TABFIL_Codigo = "+alltrim(str(xFil))+" AND "
	cQuery += " GEN_TABEMP_Codigo= "+alltrim(str(xEmp))+" "

	U_AGX635CN("DBG")
	//CONOUT(cQuery)

	If Select(cAliasSE1) <> 0
		dbSelectArea(cAliasSE1)
		(cAliasSE1)->(dbclosearea())
	Endif

	TCQuery cQuery NEW ALIAS (cAliasSE1)

	(cAliasSE1)->(dbgotop())

	//se não encontra Registros,sai da rotina
	If (cAliasSE1)->(eof())
		EditTxt("\logs\AGX635NS.log",dtos(date())+" "+"AGX635NZ: "+"Não encontrou Registros: "+alltrim(str(xEmp))+alltrim(str(xFil))+alltrim(str(xIDNFS))+" ")
		Return .F.
	endif

	cFil := cFilant//STRZERO((cAliasSE1)->DBEMP,2)

	U_AGX635CN("PRT")

	//** Adequa Campo Doc e Serie
	aTam    := {};aTam    := TamSX3("F2_DOC");     _cDoc   := PADL(alltrim((cCapaNFS)->(F2_DOC)),aTam[1],'0')
	aTam    := {};aTam    := TamSX3("F2_SERIE")	;  _cSerie := PADR(alltrim((cCapaNFS)->(F2_SERIE)),aTam[1],' ')

	//CONOUT('Inserindo SE1 '+_cDoc+' - '+_cSerie )

	//Posiciona CLIENTE
	SA1->(DbSetOrder(3))
	SA1->(DbGoTop())
	iF !(SA1->(DbSeek(xFilial("SA1")+(cCapaNFS)->(CNPJ_CPF))))
		EditTxt("\logs\AGX635NS.log",dtos(date())+" "+"AGX635NZ: "+"Cliente nao encotrado "+alltrim(str(xEmp))+alltrim(str(xFil))+alltrim(str(xIDNFS))+" ")
		Return .F.
	Endif

	cPrefixo := _cSerie

	lTitBaixad := .F.

	//Verifica se Existe Título Já baixado
	dbselectarea('SE1')
	dbsetorder(2)  // E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
	cChave := xfilial('SE1') + SA1->A1_COD + SA1->A1_LOJA + cPrefixo + _cDoc
	CONOUT('AGX635NS - CHAVE '+cChave)
	If dbseek(cChave)
		While cChave  == xfilial('SE1') + SE1->E1_CLIENTE + SE1->E1_LOJA + SE1->E1_PREFIXO + SE1->E1_NUM
			If !Empty(SE1->E1_BAIXA)
				lTitBaixad := .T.
			Endif
			SE1->(dbskip())
		Enddo
	Endif
	//CONOUT('AGX635NS - 909')
	//CONOUT(lTitBaixad)
	//Se Título já foi baixado
	If lTitBaixad
		EditTxt("\logs\AGX635NS.log",dtos(date())+" "+"AGX635NZ: "+"Ja Baixado "+alltrim(str(xEmp))+alltrim(str(xFil))+alltrim(str(xIDNFS))+" ")

		//GRAVA Array de LOG
		AADD(aLogs,{;
			{'ZDB_DBEMP'  ,(cCapaNFS)->(DBEMP)},;
			{'ZDB_DBFIL'  ,(cCapaNFS)->(DBFIL)}								,;
			{'ZDB_MSG'	  ,	'Título já baixado: '+SE1->E1_FILIAL+SE1->E1_CLIENTE+'-'+SE1->E1_LOJA+SE1->E1_PREFIXO+SE1->E1_NUM},;
			{'ZDB_DATA'	  ,ddatabase},;
			{'ZDB_HORA'	  ,time()},;
			{'ZDB_EMP'	  ,cEmpant},;
			{'ZDB_FILIAL' ,cFilAnt},;
			{'ZDB_DBCHAV' ,_cDoc+'+'+_cSerie+'+'+SA1->A1_COD+'+'+SA1->A1_LOJA},;
			{'ZDB_TAB' 	  ,'SE1'},;
			{'ZDB_INDICE' ,1	},;
			{'ZDB_TIPOWF' ,4},;
			{'ZDB_CHAVE'  , SE1->E1_FILIAL+SE1->E1_CLIENTE+SE1->E1_LOJA+SE1->E1_PREFIXO+SE1->E1_NUM};
			})
		Return .F.
	Endif

	DbSelectArea(cAliasSE1)
	(cAliasSE1)->(dbGotop())
	While (cAliasSE1)->(!eof())

		EditTxt("\logs\AGX635NS.log",dtos(date())+" "+"AGX635NZ: "+"Inicio Grv SE1 "+alltrim(str(xEmp))+alltrim(str(xFil))+alltrim(str(xIDNFS))+" ")

		aTam     := {}
		aTam     := TamSX3("E1_NUM")
		cTitulo  := ""
		cTitulo  := _cDoc//SF2->F2_DOC//StrZero(MSE1->E1_NUM,aTam[1])
		cForCod	 := SA1->A1_COD
		cForLoja := SA1->A1_LOJA
		cForNome := POSICIONE('SA1',1,xfilial('SA1')+cForCod+cForLoja,'A1_NOME')

		cFilEnt  := cFilAnt
		
		cPrefixo := ""
		do Case
		Case cFilEnt == "01"
			cPrefixo := SubStr(_cSerie,1,2)+"A"
		Case cFilEnt == "02"
			cPrefixo := SubStr(_cSerie,1,2)+"B"
		Case cFilEnt == "03"
			cPrefixo := SubStr(_cSerie,1,2)+"C"
		Case cFilEnt == "04"
			cPrefixo := SubStr(_cSerie,1,2)+"D"
		Case cFilEnt == "05"
			cPrefixo := SubStr(_cSerie,1,2)+"E"
		Case cFilEnt == "06"
			cPrefixo := SubStr(_cSerie,1,2)+"F"
		Case cFilEnt == "07"
			cPrefixo := SubStr(_cSerie,1,2)+"G"
		Case cFilEnt == "08"
			cPrefixo := SubStr(_cSerie,1,2)+"H"
		Case cFilEnt == "09"
			cPrefixo := SubStr(_cSerie,1,2)+"I"
		Case cFilEnt == "10"
			cPrefixo := SubStr(_cSerie,1,2)+"J"
		Case cFilEnt == "11"
			cPrefixo := SubStr(_cSerie,1,2)+"K"
		Case cFilEnt == "12"
			cPrefixo := SubStr(_cSerie,1,2)+"L"
		Case cFilEnt == "13"
			cPrefixo := SubStr(_cSerie,1,2)+"M"
		Case cFilEnt == "14"
			cPrefixo := SubStr(_cSerie,1,2)+"N"
		Case cFilEnt == "15"
			cPrefixo := SubStr(_cSerie,1,2)+"O"
		Case cFilEnt == "16"
			cPrefixo := SubStr(_cSerie,1,2)+"P"
		Case cFilEnt == "17"
			cPrefixo := SubStr(_cSerie,1,2)+"Q"
		Case cFilEnt == "18"
			cPrefixo := SubStr(_cSerie,1,2)+"R"
		Case cFilEnt == "19"
			cPrefixo := SubStr(_cSerie,1,2)+"S"
		Case cFilEnt == "20"
			cPrefixo := SubStr(_cSerie,1,2)+"T"
		Case cFilEnt == "21"
			cPrefixo := SubStr(_cSerie,1,2)+"U"
		Case cFilEnt == "22"
			cPrefixo := SubStr(_cSerie,1,2)+"V"
		Case cFilEnt == "23"
			cPrefixo := SubStr(_cSerie,1,2)+"W"
		Case cFilEnt == "24"
			cPrefixo := SubStr(_cSerie,1,2)+"X"
		Case cFilEnt == "25"
			cPrefixo := SubStr(_cSerie,1,2)+"Y"
		Case cFilEnt == "26"
			cPrefixo := SubStr(_cSerie,1,2)+"Z"
		EndCase

		cParcela := PADR(alltrim(cValToChar((cAliasSE1)->E1_PARCELA)),3,' ') //StrZero(MSE1->E1_PARCELA,3)

		dEmissao := (cCapaNFS)->F2_EMISSAO
		dVencto  := (cAliasSE1)->E1_VENCTO
		dDtDigit := (cCapaNFS)->F2_EMISSAO

		If (cCapaNFS)->(CANCELA) == 'S'
			EditTxt("\logs\AGX635NS.log",dtos(date())+" "+"AGX635NZ: "+"CANCELADO "+alltrim(str(xEmp))+alltrim(str(xFil))+alltrim(str(xIDNFS))+" ")
			If !ExcluirSE1(cPrefixo, cTitulo, cParcela, cTipo )
				Return .F.
			Endif
			lRet := .T.
		Else
			EditTxt("\logs\AGX635NS.log",dtos(date())+" "+"AGX635NZ: "+"ATIVO "+alltrim(str(xEmp))+alltrim(str(xFil))+alltrim(str(xIDNFS))+" ")

			DbSelectArea('SE1')
			DbSetOrder(1)
			If DbSeek(xFilial('SE1') + cPrefixo + cTitulo + cParcela + cTipo)
				Reclock('SE1',.F.)
				dbdelete()
				Msunlock()
			Endif

			lRet := .F.
			cCCusto := alltrim(U_X635TGBU(cEmpant,'','02' ,cFilEnt,'ZDA_CAMP1','ZDA_CAMP2'))
			EditTxt("\logs\AGX635NS.log",dtos(date())+" "+"AGX635NZ: "+"cCCusto "+alltrim(str(xEmp))+alltrim(str(xFil))+alltrim(str(xIDNFS))+" - "+cCCusto)

			Begin Transaction
				DbSelectArea('SE1')
				If 	RecLock("SE1",.T.)
					SE1->E1_PREFIXO		:= cPrefixo
					SE1->E1_NUM			:= cTitulo
					SE1->E1_PARCELA  	:= cParcela
					SE1->E1_CLIENTE		:= cForCod
					SE1->E1_LOJA		:= cForLoja
					SE1->E1_NOMCLI		:= cForNome
					SE1->E1_EMISSAO  	:= dEmissao
					SE1->E1_VENCTO 		:= dVencto
					SE1->E1_VENCREA		:= DataValida(dVencto,.T.)
					SE1->E1_VALOR		:= (cAliasSE1)->E1_VALOR
					SE1->E1_EMIS1 		:= dDtDigit//STOD(cAliasSE1)->E1_EMIS1)
					SE1->E1_HIST		:= "AGX635NS"
					SE1->E1_ORIIMP		:= "AGX635NS"
					SE1->E1_LA			:= ""
					SE1->E1_SALDO		:= (cAliasSE1)->E1_VALOR
					SE1->E1_VALLIQ		:= (cAliasSE1)->E1_VALOR
					SE1->E1_VENCORI		:= dVencto
					SE1->E1_MOEDA		:= 1
					SE1->E1_VLCRUZ		:= (cAliasSE1)->E1_VALOR
					SE1->E1_ORIGEM		:= "FINA040"//"MATA460"
					SE1->E1_NATUREZ  	:= (cCapaNFS)->NATOP//"101009" // "101011"
					SE1->E1_SITUACA 	:= '0'
					SE1->E1_STATUS 		:= 'A'
					SE1->E1_TIPO 		:= cTipo
					SE1->E1_SERIE       := _cSerie
					SE1->E1_FILORIG		:= cFilEnt
					SE1->E1_CCUSTO      := cCCusto//alltrim(U_X635TGBU(cEmpant,'','02' ,cFilEnt,'ZDA_CAMP1','ZDA_CAMP2'))
					SE1->(MsUnLock())
					EditTxt("\logs\AGX635NS.log",dtos(date())+" "+"AGX635NZ: "+"GRavou SE1 "+alltrim(str(xEmp))+alltrim(str(xFil))+alltrim(str(xIDNFS)))

				else
					EditTxt("\logs\AGX635NS.log",dtos(date())+" "+"AGX635NZ: "+"RECLOCK Não Travou a tabela "+cPrefixo+"-"+cTitulo+"-"+cValtochar((cCapaNFS)->ID))
				Endif
			End TRansaction

			conout("AGX635NS:" + SE1->E1_PREFIXO	+ SE1->E1_NUM )
			DbSelectArea('SE1')
			DbSetOrder(1)
			If DbSeek(xFilial('SE1') + cPrefixo + cTitulo + cParcela + cTipo)
				lRet := .T.
				EditTxt("\logs\AGX635NS.log",dtos(date())+" "+"AGX635NZ: "+"Achou Titulo"+alltrim(str(xEmp))+alltrim(str(xFil))+alltrim(str(xIDNFS)))

			Else
				EditTxt("\logs\AGX635NS.log",dtos(date())+" "+"AGX635NZ: "+"Nao Encontrou Titulo "+alltrim(str(xEmp))+alltrim(str(xFil))+alltrim(str(xIDNFS)))

				lRet := .F.

				//GRAVA Array de LOG
				AADD(aLogs,{;
					{'ZDB_DBEMP'  ,'01'},;
					{'ZDB_DBFIL'  ,cFilEnt},;
					{'ZDB_MSG'	  ,'Não Incluiu na SE1: '+ cTitulo},;
					{'ZDB_DATA'	  ,ddatabase},;
					{'ZDB_HORA'	  ,time()},;
					{'ZDB_EMP'	  ,cEmpant},;
					{'ZDB_FILIAL' ,cFilAnt},;
					{'ZDB_DBCHAV' , cTitulo },;
					{'ZDB_TAB' 	  ,'SE1'},;
					{'ZDB_INDICE' ,1},;
					{'ZDB_TIPOWF' ,8},;
					{'ZDB_CHAVE'  ,cPrefixo + cTitulo };
					})
			Endif


			If dEmissao == dVencto .and. lRet
				EditTxt("\logs\AGX635NS.log",dtos(date())+" "+"AGX635NZ: "+"Emissao = Vencimento "+alltrim(str(xEmp))+alltrim(str(xFil))+alltrim(str(xIDNFS)))

				_lRetbx    := .F.
				aBaixa := {}
				aBaixa := {{"E1_PREFIXO"  ,cPrefixo               ,Nil    },;
					{"E1_NUM"      ,cTitulo                ,Nil    },;
					{"E1_TIPO"     ,cTipo		          ,Nil    },;
					{"AUTMOTBX"    ,"NOR"                  ,Nil    },;
					{"AUTBANCO"    ,"CX1"                  ,Nil    },;
					{"AUTAGENCIA"  ,"00001"                ,Nil    },;
					{"AUTCONTA"    ,"0000000001"           ,Nil    },;
					{"AUTDTBAIXA"  ,dDtDigit               ,Nil    },;
					{"AUTDTCREDITO",dDtDigit               ,Nil    },;
					{"AUTHIST"     ,'Baixa Automatica'     ,Nil    },;
					{"AUTJUROS"    ,0                      ,Nil,.T.},;
					{"AUTVALREC"   ,(cAliasSE1)->E1_VALOR  ,Nil    }}

				dbSelectArea("SE1")
				SE1->(dbSetOrder(1))
				SE1->(dbGoTop())
				If SE1->(dbSeek(xFilial("SE1") + cPrefixo + cTitulo + cParcela + cTipo ))

					lMsErroAuto := .F.
					conout("AGX635NS: MSExecAuto " + SE1->E1_PREFIXO	+ SE1->E1_NUM )
					MSExecAuto({|x,y| Fina070(x,y)},aBaixa,3)
					IF lMsErroAuto
						EditTxt("\logs\AGX635NS.log",dtos(date())+" "+"AGX635NZ: "+"Erro ao baixar "+alltrim(str(xEmp))+alltrim(str(xFil))+alltrim(str(xIDNFS))+" - "+cCCusto)

						//MOSTRAERRO()
						_lRetbx    := .F.
					Else
						EditTxt("\logs\AGX635NS.log",dtos(date())+" "+"AGX635NZ: "+"Sucesso ao baixar "+alltrim(str(xEmp))+alltrim(str(xFil))+alltrim(str(xIDNFS)))

						//SUCESSO
						_lRetbx := .T.
					Endif
					//	End Transaction
					If _lRetbx
						cQuery := " UPDATE " + RETSQLNAME("SE5")
						cQuery += " SET E5_BANCO = 'CX1', E5_AGENCIA = '00001', E5_CONTA = '0000000001' "
						cQuery += " WHERE E5_PREFIXO = '"  +  cPrefixo        + "' "
						cQuery += "   AND E5_NUMERO     = '"  +  cTitulo        + "' "
						cQuery += "   AND E5_DATA = '"  +  dtos(dDtDigit) + "' "
						cQuery += "   AND E5_CLIFOR = '"  +  cForCod        + "' "
						cQuery += "   AND E5_LOJA    = '"  +  cForLoja      + "' "
						cQuery += "   AND D_E_L_E_T_ <> '*' "
						cQuery += "   AND E5_PARCELA = '" + alltrim(cParcela) + "' "
						EditTxt("\logs\AGX635NS.log",dtos(date())+" "+"AGX635NZ: "+"UPDATE BAIXA "+cQuery)

						TcSqlExec(cQuery)
					EndIf
				Endif
			EndIf
		Endif
		//conout("AGX635NS:1089")
		dbSelectArea(cAliasSE1)
		(cAliasSE1)->(dbskip())
	EndDo
	EditTxt("\logs\AGX635NS.log",dtos(date())+" "+"AGX635NZ: FIM ProcCRB")

Return lRet


//*********************
//  Contas a PAGAR 
//*********************
Static Function ProcCP(xIDNFS,xEmp,xFil)

	Local cPrefixo  := ""
	Local cAliasSE2 := "AGX635SE2N"
	Local cQuery    := ""

	cQuery := " SELECT  "
	cQuery += "	GEN_TABEMP_Codigo  	  AS DBEMP, "
	cQuery += " GEN_TABFIL_Codigo  	  AS DBFIL, "
	cQuery += " VEN_NOTSAI_Numero  	  AS ID_NFS, "
	cQuery += " VEN_FINNFS_Parcela 	  AS E2_PARCELA,"
	cQuery += " VEN_FINNFS_Valor   	  AS E2_VALOR, "
	cQuery += " VEN_FINNFS_Vencimento AS E2_VENCTO, "
	cQuery += " CXB_TABBAN_Codigo     AS E2_BANCO"
	cQuery += " FROM VEN_FINNFS "
	cQuery += "WHERE "
	cQuery += " VEN_NOTSAI_Numero = "+alltrim(str(xIDNFS))+" AND "
	cQuery += " GEN_TABFIL_Codigo = "+alltrim(str(xFil))+" AND "
	cQuery += " GEN_TABEMP_Codigo= "+alltrim(str(xEmp))+" "

	U_AGX635CN("DBG")
	//CONOUT(cQuery)
	If Select(cAliasSE2) <> 0
		dbSelectArea(cAliasSE2)
		(cAliasSE2)->(dbclosearea())
	Endif

	TCQuery cQuery NEW ALIAS (cAliasSE2)
	cFil := cFilant//STRZERO((cAliasSE2)->DBEMP,2)

	U_AGX635CN("PRT")

	//** Adequa Campo Doc e Serie
	aTam    := {};aTam    := TamSX3("F2_DOC");     _cDoc   := PADL(alltrim((cCapaNFS)->(F2_DOC)),aTam[1],'0')
	aTam    := {};aTam    := TamSX3("F2_SERIE")	;  _cSerie := PADR(alltrim((cCapaNFS)->(F2_SERIE)),aTam[1],' ')

	//CONOUT('Inserindo SE2 '+_cDoc+' - '+_cSerie )

	//Posiciona CLIENTE
	SA2->(DbSetOrder(3))
	SA2->(DbGoTop())
	SA2->(DbSeek(xFilial("SA2")+(cCapaNFS)->(CNPJ_CPF)))

	//Posiciona no Documento
	dbselectarea('SF2')
	SF2->(dbsetorder(1));SF2->(DbGoTop())
	If SF2->(dbseek(xfilial('SF2')+_cDoc+_cSerie+SA2->A2_COD+SA2->A2_LOJA))

		lTitBaixad := .F.
		//Verifica se Existe Título Gerado
		dbselectarea('SE2')
		dbsetorder(6)  // E2_FILIAL+E2_CLIENTE+E2_LOJA+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO
		If !dbseek(xfilial('SE2')+SF2->F2_CLIENTE+SF2->F2_LOJA+SF2->F2_PREFIXO+SF2->F2_DOC)
			If dbseek(xfilial('SE2')+SF2->F2_CLIENTE+SF2->F2_LOJA+cFilAnt+SF2->F2_PREFIXO+SF2->F2_DOC)
				If Empty(SE2->E2_BAIXA) .AND. alltrim(SE2->E2_TIPO = 'NDF')
					Reclock('SE2',.F.)
					dbdelete()
					Msunlock()
				Else
					lTitBaixad := .T.
				Endif
			Endif
		Else
			If dbseek(xfilial('SE2')+SF2->F2_CLIENTE+SF2->F2_LOJA+cFilAnt+SF2->F2_PREFIXO+SF2->F2_DOC)
				If Empty(SE2->E2_BAIXA) .AND. alltrim(SE2->E2_TIPO = 'NDF')
					Reclock('SE2',.F.)
					dbdelete()
					Msunlock()
				Else
					lTitBaixad := .T.
				Endif
			Endif
		Endif

		//Se Título já foi baixado
		If lTitBaixad
			//GRAVA Array de LOG
			AADD(aLogs,{;
				{'ZDB_DBEMP'  ,(cCapaNFS)->(DBEMP)},;
				{'ZDB_DBFIL'  ,(cCapaNFS)->(DBFIL)}								,;
				{'ZDB_MSG'	  ,	'Título já baixado: '+SE2->E2_FILIAL+SE2->E2_FORNECE+SE2->E2_LOJA+SE2->E2_PREFIXO+SE2->E2_NUM},;
				{'ZDB_DATA'	  ,ddatabase},;
				{'ZDB_HORA'	  ,time()},;
				{'ZDB_EMP'	  ,cEmpant},;
				{'ZDB_FILIAL' ,cFilAnt},;
				{'ZDB_DBCHAV' ,_cDoc+'+'+_cSerie+'+'+SA2->A2_COD+'+'+SA2->A2_LOJA},;
				{'ZDB_TAB' 	  ,'SE2'},;
				{'ZDB_INDICE' ,1	},;
				{'ZDB_TIPOWF' ,4},;
				{'ZDB_CHAVE'  , SE2->E2_FILIAL+SE2->E2_FORNECE+SE2->E2_LOJA+SE2->E2_PREFIXO+SE2->E2_NUM};
				})
			Return .F.
		Endif
	
	Endif 

	DbSelectArea(cAliasSE2)
	dbGotop()
	While (cAliasSE2)->(!eof())

		aTam     := {}
		aTam     := TamSX3("E2_NUM")
		cTitulo  := ""
		cTitulo  := SF2->F2_DOC//StrZero(MSE2->E2_NUM,aTam[1])
		cSerie   := ""
		cSerie   := substr(alltrim(SF2->F2_SERIE),1,3)
		cForCod	 := SF2->F2_CLIENTE
		cForLoja := SF2->F2_LOJA
		cForNome := POSICIONE('SA2',1,xfilial('SA2')+cForCod+cForLoja,'A2_NOME')

		cFilEnt  := SF2->F2_FILIAL
		cPrefixo := ""
		cPrefixo := substr(cSerie,1,3)
		cParcela := alltrim(cValToChar((cAliasSE2)->E2_PARCELA)) //StrZero(MSE2->E2_PARCELA,3)

		dEmissao := SF2->F2_EMISSAO
		dVencto  := (cAliasSE2)->E2_VENCTO
		dDtDigit := SF2->F2_EMISSAO

		RecLock("SE2",.T.)
		SE2->E2_PREFIXO		:= cPrefixo
		SE2->E2_NUM			:= cTitulo
		SE2->E2_PARCELA  	:= cParcela
		SE2->E2_FORNECE		:= cForCod
		SE2->E2_LOJA		:= cForLoja
		SE2->E2_NOMFOR		:= cForNome
		SE2->E2_EMISSAO  	:= dEmissao
		SE2->E2_VENCTO 		:= dVencto
		SE2->E2_VENCREA		:= dVencto
		SE2->E2_VALOR		:= (cAliasSE2)->E2_VALOR
		SE2->E2_EMIS1 		:= dDtDigit//STOD(cAliasSE2)->E2_EMIS1)
		SE2->E2_LA			:= ""
		SE2->E2_SALDO		:= (cAliasSE2)->E2_VALOR
		SE2->E2_VALLIQ		:= (cAliasSE2)->E2_VALOR
		SE2->E2_VENCORI		:= dVencto
		SE2->E2_MOEDA		:= 1
		SE2->E2_VLCRUZ		:= (cAliasSE2)->E2_VALOR
		SE2->E2_ORIGEM		:= "MATA460"
		SE2->E2_NATUREZ  	:= "201010" // "101011"
		SE2->E2_TIPO 		:= "NDF"
		SE2->E2_ORIIMP  	:= "AGX635NS"
		SE2->E2_FILORIG		:= cFilEnt
		SE2->(MsUnLock())

		//GeraNDF
		iF U_XAG0053V(SF2->F2_FILIAL)
			U_XAG0053()
		Endif
		dbSelectArea(cAliasSE2)
		(cAliasSE2)->(dbskip())
	EndDo

Return()


//Reprocessa Nota
Static Function ReprocSF2(dData, cNrDoc, cSerieDoc, cClieForn, cLojaCli, cNrFil)

	Local aPerg930  := {}
	Local nRegSM0   := 0
	Local aSegSM0   := SM0->(GetArea())
	Local lOutraFil := .F.

	If (AllTrim(cNrFil) <> AllTrim(cFilAnt))
		dbSelectArea("SM0")
		nRegSM0 := RecNo()
		cFilAnt := cNrFil

		dbSelectArea("SM0")
		dbSeek(cEmpAnt+cFilAnt,.T.)

		lOutraFil := .T.
	EndIf

	aAdd(aPerg930, DTOC(dData))
	aAdd(aPerg930, DTOC(dData))
	aAdd(aPerg930, 2)

	aAdd(aPerg930, cNrDoc)
	aAdd(aPerg930, cNrDoc)

	aAdd(aPerg930, cSerieDoc)
	aAdd(aPerg930, cSerieDoc)

	aAdd(aPerg930, cClieForn)
	aAdd(aPerg930, cClieForn)

	aAdd(aPerg930, cLojaCli)
	aAdd(aPerg930, cLojaCli)

	MSExecAuto({|x,y|MATA930(x,y)}, .T., aPerg930)

	If (lOutraFil)
		dbSelectArea("SM0")
		dbGoTo(nRegSM0)
		cFilAnt := Alltrim(SM0->M0_CODFIL)

		RestArea(aSegSM0)
	EndIf
Return()


//Inserir Produtos
Static Function GravaProd(xId,xEmp,xFil,xUF)

	Local cQuery    := ""
	Local lRetProd  := .F.
	Local cAliasSD2 := "TSD2"

	cQuery := "SELECT "
	cQuery += "VEN_ITENFS.GEN_TABEMP_Codigo	 	AS 	DBEMP,"
	cQuery += "VEN_ITENFS.GEN_TABFIL_Codigo	 	AS 	DBFIL,"
	cQuery += "VEN_NOTSAI_Numero	 	AS 	ID,"
	cQuery += "GEN_NATOPE_TES 			AS D2_TES  ,"+CHR(13)//  TES Protheus
	cQuery += "VEN_ITENFS_Sequencia		AS 	D2_ITEM,"
	cQuery += "VEN_ITENFS_Quantidade	AS 	D2_QUANT,"
	cQuery += "VEN_ITENFS_Valor	 		AS 	D2_PRCVEN,"
	cQuery += "VEN_ITENFS_PercIPI		AS 	D2_IPI,"
	cQuery += "VEN_ITENFS_Desconto	 	AS 	D2_DESC,"
	cQuery += "VEN_ITENFS_Acrescimo		AS 	D2_VALACRS,"
	cQuery += "VEN_ITENFS_NFDev	 		AS 	NFDEV,"
	cQuery += "VEN_ITENFS_SerieNFDev	AS 	NFSERDEV,"
	cQuery += "VEN_ITENFS_SitTrib	 	AS 	D2_SITTRIB,"
	cQuery += "VEN_ITENFS_Pro_Cod	 	AS 	D2_COD,"
	cQuery += "VEN_ITENFS_ICMS	 		AS 	D2_VALICM,"
	cQuery += "VEN_ITENFS_Ope_Cod	 	AS 	NATOPER,"
	cQuery += "VEN_ITENFS_BICMS	 		AS 	D2_BASEICM,"
	cQuery += "VEN_ITENFS_AICMS	 		AS 	D2_PICM,"
	cQuery += "VEN_ITENFS_BIPI	 		AS 	D2_BASEIPI,"
	cQuery += "VEN_ITENFS_IPI	 		AS 	D2_VALIPI,"
	//	cQuery += "VEN_ITENFS_CICMS	 		AS 	D2_ICMSCOM,"
	cQuery += "VEN_ITENFS_ValorFrete	AS 	D2_VALFRE,"
	cQuery += "VEN_ITENFS_ValorDA	 	AS 	D2_DESPESA,"
	cQuery += "VEN_ITENFS_ValorSeguro	AS 	D2_SEGURO,"
	cQuery += "VEN_ITENFS_AliqPIS	 	AS 	D2_ALQIMP6,"
	cQuery += "VEN_ITENFS_AliqCOFINS	AS 	D2_ALQIMP5,"
	cQuery += "VEN_ITENFS_BasePIS	 	AS 	D2_BASIMP6,"
	cQuery += "VEN_ITENFS_BaseCOFINS	AS 	D2_BASIMP5,"
	cQuery += "VEN_ITENFS_ValorPIS	 	AS 	D2_VALIMP6,"
	cQuery += "VEN_ITENFS_ValorCOFINS	AS 	D2_VALIMP5,"
	cQuery += "VEN_ITENFS_Carro         AS  CC_CARRO,  "
	cQuery += "VEN_ITENFS_CentroCusto   AS  CC_DBG,    "
	cQuery += "VEN_ITENFS_CCIntegracao  AS  CC_INTEGRA "
	cQuery += " FROM  VEN_ITENFS "
	cQuery += " INNER JOIN GEN_NATOPE GEN_NATOPE ON VEN_ITENFS.VEN_ITENFS_Ope_Cod = GEN_NATOPE.GEN_NATOPE_Codigo "+chr(13)
	cQuery += "WHERE VEN_NOTSAI_Numero = "+alltrim(str(xId))+" AND "
	cQuery += "VEN_ITENFS.GEN_TABEMP_Codigo = "+alltrim(str(xEmp))+" AND  "
	cQuery += "VEN_ITENFS.GEN_TABFIL_Codigo = "+alltrim(str(xFil))+" "

	//CONOUT('AGX635NS - ITENS' )
	//CONOUT(cQuery)
	U_AGX635CN("DBG")

	If Select(cAliasSD2) <> 0
		dbSelectArea(cAliasSD2)
		(cAliasSD2)->(dbclosearea())
	Endif

	TCQuery cQuery NEW ALIAS (cAliasSD2)

	TCSETFIELD(cAliasSD2,"D2_DESC"   ,"N",12,2)

	cFil := cFilant
	U_AGX635CN("PRT")
	(cAliasSD2)->(DBGOTOP())

	While (cAliasSD2)->(!eof())

		//Valida TES
		dbselectarea('SF4')
		dbsetorder(1)
		If !(dbseek(xfilial('SF4')+alltrim((cAliasSD2)->D2_TES)))  .or. val((cAliasSD2)->D2_TES) == 0
			AADD(aLogs,{;
				{'ZDB_DBEMP'  ,(cAliasSD2)->(DBEMP)},;
				{'ZDB_DBFIL'  ,(cAliasSD2)->(DBFIL)},;
				{'ZDB_MSG'	  ,	'Doc Saída: '+alltrim(SF2->F2_DOC)+'-'+SF2->F2_SERIE+',TES invalida:'+alltrim((cAliasSD2)->(D2_TES))},;
				{'ZDB_DATA'	  ,ddatabase},;
				{'ZDB_HORA'	  ,time()},;
				{'ZDB_EMP'	  ,cEmpant},;
				{'ZDB_FILIAL' ,cFilAnt},;
				{'ZDB_INDICE' ,1},;
				{'ZDB_TAB'  ,'SF4'},;
				{'ZDB_TIPOWF'  ,5},;
				{'ZDB_CHAVE'  ,alltrim(SF2->F2_DOC)+'+'+alltrim(SF2->F2_SERIE)+'+'+alltrim((cCapaNFS)->(DBCLI))+'+'+alltrim((cCapaNFS)->(DBLOJA))};
				})

			Return .F.
		Endif

		//Valida Produto
		dbselectarea('SB1')
		dbsetorder(1)
		If ! dbseek( xfilial('SB1')+alltrim((cAliasSD2)->(D2_COD)) )
			AADD(aLogs,{;
				{'ZDB_DBEMP'  ,(cAliasSD2)->(DBEMP)},;
				{'ZDB_DBFIL'  ,(cAliasSD2)->(DBFIL)}								,;
				{'ZDB_MSG'	  ,	'Doc Saída: '+alltrim(SF2->F2_DOC)+'-'+SF2->F2_SERIE+', Produto invalido:'+alltrim((cAliasSD2)->(D2_COD))},;
				{'ZDB_DATA'	  ,ddatabase},;
				{'ZDB_HORA'	  ,time()},;
				{'ZDB_EMP'	  ,cEmpant},;
				{'ZDB_FILIAL' ,cFilAnt},;
				{'ZDB_INDICE' ,1},;
				{'ZDB_TAB'  ,'SB1'},;
				{'ZDB_TIPOWF'  ,5},;
				{'ZDB_CHAVE'  ,alltrim(SF2->F2_DOC)+'+'+alltrim(SF2->F2_SERIE)+'+'+alltrim((cCapaNFS)->(DBCLI))+'+'+alltrim((cCapaNFS)->(DBLOJA))};
				})
			Return .F.

		Endif

		(cAliasSD2)->(dbskip())
	Enddo

	(cAliasSD2)->(DBGOTOP())
	While (cAliasSD2)->(!eof())

		//Posiciona na TES
		dbselectarea('SF4')
		dbsetorder(1)
		dbseek(xfilial('SF4')+alltrim((cAliasSD2)->D2_TES))

		//Posiciona no Produto
		dbselectarea('SB1')
		dbsetorder(1)
		dbseek( xfilial('SB1')+alltrim((cAliasSD2)->(D2_COD)) )

		//Conout(' Incluindo NFS SD2: '+_cDoc+'-'+_cSerie)
		Dbselectarea('SD2')
		Dbsetorder(1)

		Begin Transaction
			Reclock('SD2',.T.)

			cItemDOC := STRZERO((cAliasSD2)->(D2_ITEM),2)
			SD2->D2_FILIAL   := SF2->F2_FILIAL
			SD2->D2_ITEM     := cItemDOC
			SD2->D2_DOC      := SF2->F2_DOC
			SD2->D2_SERIE    := SF2->F2_SERIE
			SD2->D2_QUANT    := (cAliasSD2)->(D2_QUANT)
			SD2->D2_PRCVEN   := (cAliasSD2)->(D2_PRCVEN)
			SD2->D2_IPI      := (cAliasSD2)->(D2_IPI)
			SD2->D2_DESCON  := (cAliasSD2)->(D2_DESC)
			SD2->D2_UM       := SB1->B1_UM
			SD2->D2_TES      := SF4->F4_CODIGO
			SD2->D2_TIPO     := SF2->F2_TIPO
			/* Campos de ajuste 04/07/2018   */
			SD2->D2_CLIENTE  := SF2->F2_CLIENTE
			SD2->D2_LOJA     := SF2->F2_LOJA
			SD2->D2_TOTAL    := (SD2->D2_QUANT * SD2->D2_PRCVEN)
			SD2->D2_LOCAL   := SB1->B1_LOCPAD//"01"
			SD2->D2_EMISSAO := SF2->F2_EMISSAO
			SD2->D2_PRUNIT  := (cAliasSD2)->(D2_PRCVEN)
			SD2->D2_TP      := SB1->B1_TIPO
			//Validação de Centro de Custo para Notas Devolução
			cCusto := (cAliasSD2)->(CC_INTEGRA)
			If alltrim(cCusto) == ''
				cCusto := (cAliasSD2)->(CC_DBG)
			Endif
			If alltrim(cCusto) == ''
				cCusto := (cAliasSD2)->(CC_CARRO)
			Endif

			If alltrim(cCusto) <> ''
				SD2->D2_CCUSTO := alltrim(STR(VAL(cCusto)))
				SD2->D2_ITEMCC := SF2->F2_FILIAL
			Endif

			// Tratamento para CF com destino Fora do Estado
			// Deve iniciar com 6
			cCFOP := SF4->F4_CF
			If (cCapaNFS)->(UFCLI) <> xUF //** AQUI
				cCFOP := '6'+substr(alltrim(SF4->F4_CF),2,3)
			Endif

			SD2->D2_CF      := cCFOP

			SD2->D2_VALACRS      := (cAliasSD2)->(D2_VALACRS)
			SD2->D2_SITTRIB  := (cAliasSD2)->(D2_SITTRIB)
			SD2->D2_COD      := (cAliasSD2)->(D2_COD )
			SD2->D2_VALICM   := (cAliasSD2)->(D2_VALICM)
			SD2->D2_BASEICM  := (cAliasSD2)->(D2_BASEICM)
			SD2->D2_PICM     := (cAliasSD2)->(D2_PICM)
			SD2->D2_BASEIPI  := (cAliasSD2)->(D2_BASEIPI)
			SD2->D2_VALIPI   := (cAliasSD2)->(D2_VALIPI)
			SD2->D2_VALFRE   := (cAliasSD2)->(D2_VALFRE)
			SD2->D2_DESPESA  := (cAliasSD2)->(D2_DESPESA)
			SD2->D2_SEGURO   := (cAliasSD2)->(D2_SEGURO)

			//Retenção
			//SD2->D2_ALQPIS   := (cAliasSD2)->(D2_ALQPIS)
			//SD2->D2_ALQCOF   := (cAliasSD2)->(D2_ALQCOF)
			//SD2->D2_BASEPIS  := (cAliasSD2)->(D2_BASEPIS)
			//SD2->D2_BASECOF  := (cAliasSD2)->(D2_BASECOF)
			//SD2->D2_VALPIS   := (cAliasSD2)->(D2_VALPIS)
			//SD2->D2_VALCOF   := (cAliasSD2)->(D2_VALCOF)
			//Apuração
			SD2->D2_ALQIMP5 := (cAliasSD2)->(D2_ALQIMP5)//COFINS
			SD2->D2_ALQIMP6 := (cAliasSD2)->(D2_ALQIMP6)//PIS
			SD2->D2_VALIMP5 := (cAliasSD2)->(D2_VALIMP5)//COFINS
			SD2->D2_VALIMP6 := (cAliasSD2)->(D2_VALIMP6)//PIS
			SD2->D2_BASIMP5 := (cAliasSD2)->(D2_BASIMP5)//COFINS
			SD2->D2_BASIMP6 := (cAliasSD2)->(D2_BASIMP6)//PIS
			SD2->D2_ORIIMP  := "AGX635NS"

			//Campos de fundo de combate a pobreza nfe 4.0
			SD2->D2_BSFCCMP := 0
			SD2->D2_FCPAUX  := 0
			SD2->D2_BASFECP := 0
			SD2->D2_BSFCPST := 0

			lRetProd := .T.
			SD2->(MsUnlock())
		End Transaction

		(cAliasSD2)->(dbskip())
	Enddo

Return lRetProd


//Inserir Servicos
Static Function GravaServ(xId,xEmp,xFil,xUF)

	Local cQuery   := ""
	Local lRetProd := .F.
	Local _cProduto  := ""
	Local  cAliasSD2 := "SD2SERV"

	cQuery := " SELECT "
	cQuery += " VEN_NOTSAI.GEN_NATOPE_Codigo    AS  NATOP,"
	cQuery += " GEN_NATOPE_TES 				  	AS D2_TES  ,"
	cQuery += " VEN_SRVNFS.GEN_TABEMP_Codigo	AS 	DBEMP,"
	cQuery += " VEN_SRVNFS.GEN_TABFIL_Codigo	AS 	DBFIL,"
	cQuery += " VEN_SRVNFS.VEN_NOTSAI_Numero	AS 	ID,"
	cQuery += " VEN_SRVNFS_Sequencia			AS 	D2_ITEM,"
	cQuery += " GEN_TABSRV_Codigo 				AS 	D2_COD,"
	cQuery += " VEN_SRVNFS_Quantidade 			AS 	D2_QUANT,"
	cQuery += " VEN_SRVNFS_Valor				AS 	D2_PRCVEN,"
	cQuery += " VEN_SRVNFS_AliqISS  			AS D2_ALIQISS,"
	cQuery += " VEN_SRVNFS_ISS      			AS D2_VALISS,"
	cQuery += " VEN_SRVNFS_AliqIRRF 			AS D2_ALQIRRF,"
	cQuery += " VEN_SRVNFS_ISSRetido			AS ISSRETIDO,"
	cQuery += " VEN_SRVNFS_IRRF 				AS D2_VALIRRF"
	cQuery += " FROM VEN_SRVNFS "

	cQuery += " INNER JOIN VEN_NOTSAI VEN_NOTSAI ON VEN_NOTSAI.VEN_NOTSAI_Numero = VEN_SRVNFS.VEN_NOTSAI_Numero "
	cQuery += " INNER JOIN GEN_NATOPE GEN_NATOPE ON VEN_NOTSAI.GEN_NATOPE_Codigo = GEN_NATOPE.GEN_NATOPE_Codigo "
	cQuery += " AND VEN_NOTSAI.GEN_TABEMP_Codigo = VEN_SRVNFS.GEN_TABEMP_Codigo AND VEN_NOTSAI.GEN_TABFIL_Codigo = VEN_SRVNFS.GEN_TABFIL_Codigo "
	cQuery += " WHERE VEN_NOTSAI.VEN_NOTSAI_Numero = "+alltrim(str(xId))+" AND "
	cQuery += " VEN_NOTSAI.GEN_TABEMP_Codigo = "+alltrim(str(xEmp))+" AND "
	cQuery += " VEN_NOTSAI.GEN_TABFIL_Codigo = "+alltrim(str(xFil))+" "

	//CONOUT(cQuery)
	//CONOUT('AGX635NS - ITENS SERVICO' )
	U_AGX635CN("DBG")

	If Select(cAliasSD2) <> 0
		dbSelectArea(cAliasSD2)
		(cAliasSD2)->(dbclosearea())
	Endif

	TCQuery cQuery NEW ALIAS (cAliasSD2)

	cFil := cFilant

	U_AGX635CN("PRT")

	//Chamado 45326
	_cProduto := alltrim((cAliasSD2)->(D2_COD))
	If cEmpant == '01' .and. xfilial('SD2') $'04/05/08'
		if  xfilial('SD2') $'08' .and. (cAliasSD2)->(ISSRETIDO) > 0 //.and. alltrim((cAliasSD2)->NATOP) == '5933002'
			_cProduto := '99935'
		Else
			_cProduto := '99920'
		Endif
	Else
		AADD(aLogs,{;
			{'ZDB_DBEMP'  ,(cAliasSD2)->(DBEMP)},;
			{'ZDB_DBFIL'  ,(cAliasSD2)->(DBFIL)}								,;
			{'ZDB_MSG'	  ,	'Doc Saída SERVICO: '+alltrim(SF2->F2_DOC)+'-'+SF2->F2_SERIE+', Empresa nao Permitida('+cEmpant+cFilAnt+')'},;
			{'ZDB_DATA'	  ,ddatabase},;
			{'ZDB_HORA'	  ,time()},;
			{'ZDB_EMP'	  ,cEmpant},;
			{'ZDB_FILIAL' ,cFilAnt},;
			{'ZDB_INDICE' ,1},;
			{'ZDB_TAB'  ,'SB1'},;
			{'ZDB_TIPOWF'  ,5},;
			{'ZDB_CHAVE'  ,alltrim(SF2->F2_DOC)+'+'+alltrim(SF2->F2_SERIE)+'+'+alltrim((cCapaNFS)->(DBCLI))+'+'+alltrim((cCapaNFS)->(DBLOJA))};
			})
		Return .F.

	Endif

	dbSelectarea('SB1')
	dbsetorder(1)
	dbSeek(xfilial('SB1')+_cProduto)

	//Validações
	(cAliasSD2)->(DBGOTOP())
	While (cAliasSD2)->(!eof())

		//Valida TES
		dbselectarea('SF4')
		dbsetorder(1)
		If !(dbseek(xfilial('SF4')+alltrim((cAliasSD2)->D2_TES)))  .or. val((cAliasSD2)->D2_TES) == 0
			AADD(aLogs,{;
				{'ZDB_DBEMP'  ,(cAliasSD2)->(DBEMP)},;
				{'ZDB_DBFIL'  ,(cAliasSD2)->(DBFIL)},;
				{'ZDB_MSG'	  ,	'Doc Saída SERVICO: '+alltrim(SF2->F2_DOC)+'-'+SF2->F2_SERIE+',TES invalida:'+alltrim((cAliasSD2)->(D2_TES))},;
				{'ZDB_DATA'	  ,ddatabase},;
				{'ZDB_HORA'	  ,time()},;
				{'ZDB_EMP'	  ,cEmpant},;
				{'ZDB_FILIAL' ,cFilAnt},;
				{'ZDB_INDICE' ,1},;
				{'ZDB_TAB'  ,'SF4'},;
				{'ZDB_TIPOWF'  ,5},;
				{'ZDB_CHAVE'  ,alltrim(SF2->F2_DOC)+'+'+alltrim(SF2->F2_SERIE)+'+'+alltrim((cCapaNFS)->(DBCLI))+'+'+alltrim((cCapaNFS)->(DBLOJA))};
				})

			Return .F.
		Endif

		//Valida Produto
		dbselectarea('SB1')
		dbsetorder(1)
		If ! dbseek( xfilial('SB1')+_cProduto )
			AADD(aLogs,{;
				{'ZDB_DBEMP'  ,(cAliasSD2)->(DBEMP)},;
				{'ZDB_DBFIL'  ,(cAliasSD2)->(DBFIL)}								,;
				{'ZDB_MSG'	  ,	'Doc Saída SERVICO: '+alltrim(SF2->F2_DOC)+'-'+SF2->F2_SERIE+', Produto invalido:'+alltrim(_cProduto)},;
				{'ZDB_DATA'	  ,ddatabase},;
				{'ZDB_HORA'	  ,time()},;
				{'ZDB_EMP'	  ,cEmpant},;
				{'ZDB_FILIAL' ,cFilAnt},;
				{'ZDB_INDICE' ,1},;
				{'ZDB_TAB'  ,'SB1'},;
				{'ZDB_TIPOWF'  ,5},;
				{'ZDB_CHAVE'  ,alltrim(SF2->F2_DOC)+'+'+alltrim(SF2->F2_SERIE)+'+'+alltrim((cCapaNFS)->(DBCLI))+'+'+alltrim((cCapaNFS)->(DBLOJA))};
				})
			Return .F.

		Endif

		(cAliasSD2)->(dbskip())
	Enddo

	//Gravação
	(cAliasSD2)->(DBGOTOP())
	While (cAliasSD2)->(!eof())

		//Posiciona na TES
		dbselectarea('SF4')
		dbsetorder(1)
		dbseek(xfilial('SF4')+alltrim((cAliasSD2)->D2_TES))

		//Posiciona no Produto
		dbselectarea('SB1')
		dbsetorder(1)
		dbseek( xfilial('SB1')+_cProduto )

		//Tratamento para CF com destino Fora do Estado
		// Deve iniciar com 6
		cCFOP := SF4->F4_CF
		If (cCapaNFS)->(UFCLI) <> xUF //** AQUI
			cCFOP := '6'+substr(alltrim(SF4->F4_CF),2,3)
		Endif

		Dbselectarea('SD2')
		Dbsetorder(1)
		Reclock('SD2',.T.)
		SD2->D2_FILIAL   := SF2->F2_FILIAL
		SD2->D2_DOC      := SF2->F2_DOC
		SD2->D2_SERIE    := SF2->F2_SERIE
		SD2->D2_CLIENTE  := SF2->F2_CLIENTE
		SD2->D2_LOJA     := SF2->F2_LOJA
		cItemDOC := STRZERO((cAliasSD2)->(D2_ITEM),2)
		SD2->D2_ITEM     := cItemDOC
		SD2->D2_COD      := _cProduto
		SD2->D2_QUANT    := (cAliasSD2)->(D2_QUANT)
		SD2->D2_PRCVEN   := (cAliasSD2)->(D2_PRCVEN)
		SD2->D2_TOTAL    := (SD2->D2_QUANT * SD2->D2_PRCVEN)
		SD2->D2_EMISSAO := SF2->F2_EMISSAO
		SD2->D2_UM       := SB1->B1_UM
		SD2->D2_ALIQISS	 := (cAliasSD2)->(D2_ALIQISS)
		SD2->D2_BASEISS  :=  (SD2->D2_QUANT * SD2->D2_PRCVEN)//Gravado sempre o valor total pois nao tem campo
		SD2->D2_CODISS   := '16.01'
		SD2->D2_VALISS	 := (cAliasSD2)->(D2_VALISS)
		SD2->D2_ALQIRRF  := (cAliasSD2)->(D2_ALQIRRF)
		SD2->D2_VALIRRF	 := (cAliasSD2)->(D2_VALIRRF)
		SD2->D2_ORIIMP   := "AGX635NS"
		SD2->D2_TES      := (cAliasSD2)->(D2_TES)
		SD2->D2_CF       := cCFOP
		SD2->D2_TIPO     := SF2->F2_TIPO
		SD2->D2_PRUNIT  := (cAliasSD2)->(D2_PRCVEN)
		SD2->D2_TP      := SB1->B1_TIPO

		//Campos de fundo de combate a pobreza nfe 4.0
		SD2->D2_BSFCCMP := 0
		SD2->D2_FCPAUX  := 0
		SD2->D2_BASFECP := 0
		SD2->D2_BSFCPST := 0

		lRetProd := .T.
		SD2->(MsUnlock())

		(cAliasSD2)->(dbskip())
	Enddo

Return lRetProd


//Exclui SF2    
Static Function ExcluirSF2(cNrDoc, cSerieDoc, cClieForn, cLoja, cNrFilial, cDtCanc, xTipo, xEspecie , xPrefixo)

	Local cQuery := ""
	Local cAliasSE2 := "EXCLUIRSF2"

	//CONOUT('*** ExcluirSF2 ****')

	U_AGX635CN("PRT")

	//CONOUT('** Excluindo Nota '+cNrDoc+'-'+cSerieDoc+'/'+cClieForn+'-'+cLoja+'-'+cNrFilial)
	cDtCanc := DTOS(cDtCanc)

	cQuery := " UPDATE " + RETSQLNAME("SF2") + " SET "
	cQuery += "        D_E_L_E_T_   = '*', "
	cQuery += "        R_E_C_D_E_L_ = R_E_C_N_O_ "
	cQuery += "  WHERE F2_FILIAL   = '" + ALLTRIM(cNrFilial) + "' "
	cQuery += "    AND F2_DOC      = '" + ALLTRIM(cNrDoc)    + "' "
	cQuery += "    AND F2_SERIE    = '" + ALLTRIM(cSerieDoc) + "' "
	cQuery += "    AND F2_CLIENTE  = '" + ALLTRIM(cClieForn) + "' "
	cQuery += "    AND F2_LOJA     = '" + ALLTRIM(cLoja)     + "' "
	cQuery += "    AND F2_TIPO     = '"+xTipo+"'   "
	cQuery += "    AND F2_ESPECIE  = '"+xEspecie+"' "
	cQuery += "    AND D_E_L_E_T_  <> '*'  "

	//CONOUT(cQuery)
	If (TCSQLExec(cQuery) < 0)
		Conout("Falha ao Atualizar SF2: " + cQuery)
		Conout("TCSQLError() - " + TCSQLError())
	EndIf


	cQuery := " UPDATE " + RETSQLNAME("SD2") + " SET "
	cQuery += "        D_E_L_E_T_   = '*', "
	cQuery += "        R_E_C_D_E_L_ = R_E_C_N_O_ "
	cQuery += "  WHERE D2_FILIAL   = '" + ALLTRIM(cNrFilial) + "' "
	cQuery += "    AND D2_DOC      = '" + ALLTRIM(cNrDoc)    + "' "
	cQuery += "    AND D2_SERIE    = '" + ALLTRIM(cSerieDoc) + "' "
	cQuery += "    AND D2_CLIENTE  = '" + ALLTRIM(cClieForn) + "' "
	cQuery += "    AND D2_LOJA     = '" + ALLTRIM(cLoja)     + "' "
//	cQuery += "    AND D2_TP       = 'N' " 
	cQuery += "    AND D2_TIPO     = '"+xTipo+"'   "
	cQuery += "    AND D_E_L_E_T_ <> '*' "

	//CONOUT(cQuery)
	If (TCSQLExec(cQuery) < 0)
		Conout("Falha ao Atualizar SD2: " + cQuery)
		Conout("TCSQLError() - " + TCSQLError())
	EndIf

	//CONOUT('*** XTIPO  ****')	
	//CONOUT(xTipo)	
	//Se for uma devolução exclui SE2,senao SE1
	If xTipo == 'D'

		//Busco dados na SE2
		cQuery := " SELECT R_E_C_N_O_ AS RECNO  FROM " + RETSQLNAME("SE2") + " (NOLOCK) "
		cQuery += "  WHERE E2_FILORIG  = '" + ALLTRIM(cNrFilial) + "' "
		cQuery += "    AND E2_NUM      = '" + ALLTRIM(cNrDoc)    + "' "
		cQuery += "    AND E2_PREFIXO    = '" + xPrefixo + "' "
		cQuery += "    AND E2_FORNECE  = '" + ALLTRIM(cClieForn) + "' "
		cQuery += "    AND E2_LOJA     = '" + ALLTRIM(cLoja)     + "' "
		cQuery += "    AND E2_TIPO     = 'NDF' "
		cQuery += "    AND D_E_L_E_T_ <> '*'  "

		//CONOUT(cQuery)
		If Select(cAliasSE2) <> 0
			dbSelectArea(cAliasSE2)
			(cAliasSE2)->(dbclosearea())
		Endif

		TCQuery cQuery NEW ALIAS (cAliasSE2)

		//Varro todos os registros da SE2
		While (cAliasSE2)->(!eof())

				//Verifico de tem NCF vinculado na SE1
			  	DbSelectarea('SE1')
				If FieldPos("E1_XCHVNDF") > 0
					
					_cChvNDF := SE2->E2_FILIAL + SE2->E2_PREFIXO + SE2->E2_NUM + SE2->E2_PARCELA + SE2->E2_TIPO + SE2->E2_FORNECE + SE2->E2_LOJA
			
					cQuery := " UPDATE " + RETSQLNAME("SE1") + " SET "
					cQuery += "        D_E_L_E_T_   = '*', "
					cQuery += "        R_E_C_D_E_L_ = R_E_C_N_O_ "
					cQuery += "  WHERE E1_XCHVNDF  = '" + _cChvNDF + "' "
					cQuery += "  AND E1_TIPO = 'NCF' AND D_E_L_E_T_ = ''

					//CONOUT(cQuery)
					If (TCSQLExec(cQuery) < 0)
						Conout("Falha ao Atualizar SE1: " + cQuery)
						Conout("TCSQLError() - " + TCSQLError())
					EndIf

				Endif

				//Excluo registro na SE2
				DbSelectarea('SE2')
				Dbgoto((cAliasSE2)->RECNO)
				Reclock('SE2',.F.)
					dbdelete()
				SE1->(Msunlock())
			
			(cAliasSE2)->(dbskip())
		Enddo


	Else
		cQuery := " UPDATE " + RETSQLNAME("SE1") + " SET "
		cQuery += "        D_E_L_E_T_   = '*', "
		cQuery += "        R_E_C_D_E_L_ = R_E_C_N_O_ "
		cQuery += "  WHERE E1_FILORIG  = '" + ALLTRIM(cNrFilial) + "' "
		cQuery += "    AND E1_NUM      = '" + ALLTRIM(cNrDoc)    + "' "
		cQuery += "    AND E1_PREFIXO    = '" + xPrefixo + "' "
		//cQuery += "    AND E1_SERIE    = '" + ALLTRIM(cSerieDoc) + "' "
		cQuery += "    AND E1_CLIENTE  = '" + ALLTRIM(cClieForn) + "' "
		cQuery += "    AND E1_LOJA     = '" + ALLTRIM(cLoja)     + "' "
		cQuery += "    AND E1_TIPO     = 'NF' "
		cQuery += "    AND D_E_L_E_T_ <> '*'  "
		//CONOUT(cQuery)
		If (TCSQLExec(cQuery) < 0)
			Conout("Falha ao Atualizar SE1: " + cQuery)
			Conout("TCSQLError() - " + TCSQLError())
		EndIf
	Endif


	cQuery := " UPDATE " + RETSQLNAME("SF3") + " SET "
	cQuery += "        F3_OBSERV   = 'NF CANCELADA', "
	cQuery += "        F3_DTCANC   = '" + cDtCanc + "' "
	cQuery += "  WHERE F3_FILIAL   = '" + ALLTRIM(cNrFilial) + "' "
	cQuery += "    AND F3_NFISCAL  = '" + ALLTRIM(cNrDoc)    + "' "
	cQuery += "    AND F3_SERIE    = '" + ALLTRIM(cSerieDoc) + "' "
	cQuery += "    AND F3_CLIEFOR  = '" + ALLTRIM(cClieForn) + "' "
	cQuery += "    AND F3_LOJA     = '" + ALLTRIM(cLoja)     + "' "
	//cQuery += "    AND F3_ESPECIE  = 'CTE' "
	//CONOUT(cQuery)
	If (TCSQLExec(cQuery) < 0)
		Conout("Falha ao Atualizar SF3: " + cQuery)
		Conout("TCSQLError() - " + TCSQLError())
	EndIf

	cQuery := " UPDATE " + RETSQLNAME("SFT") + " SET "
	cQuery += "        FT_OBSERV   = 'NF CANCELADA', "
	cQuery += "        FT_DTCANC   = '" + cDtCanc + "' "
	cQuery += "  WHERE FT_FILIAL   = '" + ALLTRIM(cNrFilial) + "' "
	cQuery += "    AND FT_NFISCAL  = '" + ALLTRIM(cNrDoc)    + "' "
	cQuery += "    AND FT_SERIE    = '" + ALLTRIM(cSerieDoc) + "' "
	cQuery += "    AND FT_CLIEFOR  = '" + ALLTRIM(cClieForn) + "' "
	cQuery += "    AND FT_LOJA     = '" + ALLTRIM(cLoja)     + "' "
	//cQuery += "    AND FT_ESPECIE  = 'CTE' "
	//CONOUT(cQuery)
	If (TCSQLExec(cQuery) < 0)
		Conout("Falha ao Atualizar SFT: " + cQuery)
		Conout("TCSQLError() - " + TCSQLError())
	EndIf

Return()


Static Function CabEntrada()

	Local nRecnoF1 := 0
	Local lNovo    := .T.

	DbSelectArea('SF1')
	DbSetOrder(1)
	If Dbseek(xfilial('SF1') + _cDoc + _cSerie + cCliFor + cLoja + 'D')
		lNovo := .F.
	Endif


	RecLock("SF1" , lNovo)

	SF1->F1_FILIAL  := xFilial('SF1')
	SF1->F1_DOC		:= _cDoc//(cAliasCapa)->(F1_DOC)
	SF1->F1_SERIE   := _cSerie//(cAliasCapa)->(F1_SERIE)
	SF1->F1_FORNECE := cCliFor
	SF1->F1_LOJA    := cLoja
	SF1->F1_COND    := "001"
	SF1->F1_DUPL    := _cDoc//(cAliasCapa)->(F1_DOC)
	SF1->F1_EMISSAO := (cCapaNFS)->F2_EMISSAO
	SF1->F1_VALBRUT := ((cCapaNFS)->(F2_VALBRUT)) //+ (cAliasCapa)->(F1_DESCONT)
	SF1->F1_VALICM  := (cCapaNFS)->(F2_VALICM)
	SF1->F1_BASEICM := (cCapaNFS)->(F2_BASEICM)
	SF1->F1_VALMERC := (cCapaNFS)->(F2_VALMERC) //+ (cAliasCapa)->(F1_DESCONT)
	SF1->F1_TIPO    := 'D'//ctipoNF
	SF1->F1_ESPECIE := cEspecie//(cAliasCapa)->(STG_GEN_TABESP_Codigo)
	//SF1->  DOCUMENTO.CD_C
	SF1->F1_DTDIGIT := (cCapaNFS)->F2_EMISSAO
	SF1->F1_RECBMTO := (cCapaNFS)->F2_EMISSAO
	SF1->F1_EST   	:= SA2->A2_EST
	SF1->F1_FRETE   := (cCapaNFS)->F2_FRETE
	SF1->F1_DESPESA := (cCapaNFS)->F2_DESPESA
	//SF1->F1_DESCONT := (cAliasCapa)->(F1_DESCONT)
	SF1->F1_BRICMS  := (cCapaNFS)->F2_BRICMS
	SF1->F1_ICMSRET := (cCapaNFS)->F2_ICMSRET
	SF1->F1_ICMS    := (cCapaNFS)->(F2_VALICM)
	//SF1->F1_PESOL   := MSF1->F1_PESOL
	SF1->F1_SEGURO	:= (cCapaNFS)->F2_SEGURO
	SF1->F1_CHVNFE  := (cCapaNFS)->F2_CHVNFE
	SF1->F1_ORIIMP  := "AGX635NS"
	SF1->F1_PREFIXO :=  substr(alltrim(_cSerie),1,3)

	SF1->F1_STATUS  := "A"

	//Campos Novos
	SF1->F1_ISS 	:= (cCapaNFS)->F2_VALISS
	//PIS/COFINS APURAÇÃO
	SF1->F1_VALIMP6 := (cCapaNFS)->(F2_VALIMP6)
	SF1->F1_BASIMP6 := (cCapaNFS)->(F2_BASIMP6)
	SF1->F1_VALIMP5 := (cCapaNFS)->(F2_VALIMP5)
	SF1->F1_BASIMP5 := (cCapaNFS)->(F2_BASIMP5)
	SF1->F1_VALCSLL := (cCapaNFS)->F2_VALCSLL
	SF1->F1_VALIRF  := (cCapaNFS)->F2_VALIRRF
	SF1->F1_INSS 	:= (cCapaNFS)->F2_VALINSS

	SF1->(Msunlock())
	//Conout('FIM Incluindo NFE SF2: '+_cDoc+'-'+_cSerie)
	nRecnoF1 := SF1->(Recno())

Return nRecnoF1


Static Function IteEntrada(xId,xEmp,xFil,xUF)

	Local cQuery    := ""
	Local lRetProd  := .T.
	Local cAliasSD2 := "TSD2"

	cQuery := "SELECT "
	cQuery += "VEN_ITENFS.GEN_TABEMP_Codigo	 	AS 	DBEMP,"
	cQuery += "VEN_ITENFS.GEN_TABFIL_Codigo	 	AS 	DBFIL,"
	cQuery += "VEN_NOTSAI_Numero	 	AS 	ID,"
	cQuery += "GEN_NATOPE_TES 			AS D2_TES  ,"+CHR(13)//  TES Protheus
	cQuery += "VEN_ITENFS_Sequencia		AS 	D2_ITEM,"
	cQuery += "VEN_ITENFS_Quantidade	AS 	D2_QUANT,"
	cQuery += "VEN_ITENFS_Valor	 		AS 	D2_PRCVEN,"
	cQuery += "VEN_ITENFS_PercIPI		AS 	D2_IPI,"
	cQuery += "VEN_ITENFS_Desconto	 	AS 	D2_DESC,"
	cQuery += "VEN_ITENFS_Acrescimo		AS 	D2_VALACRS,"
	cQuery += "VEN_ITENFS_NFDev	 		AS 	NFDEV,"
	cQuery += "VEN_ITENFS_SerieNFDev	AS 	NFSERDEV,"
	cQuery += "VEN_ITENFS_SitTrib	 	AS 	D2_SITTRIB,"
	cQuery += "VEN_ITENFS_Pro_Cod	 	AS 	D2_COD,"
	cQuery += "VEN_ITENFS_ICMS	 		AS 	D2_VALICM,"
	cQuery += "VEN_ITENFS_Ope_Cod	 	AS 	NATOPER,"
	cQuery += "VEN_ITENFS_BICMS	 		AS 	D2_BASEICM,"
	cQuery += "VEN_ITENFS_AICMS	 		AS 	D2_PICM,"
	cQuery += "VEN_ITENFS_BIPI	 		AS 	D2_BASEIPI,"
	cQuery += "VEN_ITENFS_IPI	 		AS 	D2_VALIPI,"
	//cQuery += "VEN_ITENFS_CICMS	 		AS 	D2_ICMSCOM,"
	cQuery += "VEN_ITENFS_ValorFrete	AS 	D2_VALFRE,"
	cQuery += "VEN_ITENFS_ValorDA	 	AS 	D2_DESPESA,"
	cQuery += "VEN_ITENFS_ValorSeguro	AS 	D2_SEGURO,"
	cQuery += "VEN_ITENFS_AliqPIS	 	AS 	D2_ALQIMP6,"
	cQuery += "VEN_ITENFS_AliqCOFINS	AS 	D2_ALQIMP5,"
	cQuery += "VEN_ITENFS_BasePIS	 	AS 	D2_BASIMP6,"
	cQuery += "VEN_ITENFS_BaseCOFINS	AS 	D2_BASIMP5,"
	cQuery += "VEN_ITENFS_ValorPIS	 	AS 	D2_VALIMP6,"
	cQuery += "VEN_ITENFS_ValorCOFINS	AS 	D2_VALIMP5 "
	cQuery += " FROM  VEN_ITENFS "
	cQuery += " INNER JOIN GEN_NATOPE GEN_NATOPE ON VEN_ITENFS.VEN_ITENFS_Ope_Cod = GEN_NATOPE.GEN_NATOPE_Codigo "+chr(13)
	cQuery += "WHERE VEN_NOTSAI_Numero = "+alltrim(str(xId))+" AND "
	cQuery += "VEN_ITENFS.GEN_TABEMP_Codigo = "+alltrim(str(xEmp))+" AND  "
	cQuery += "VEN_ITENFS.GEN_TABFIL_Codigo = "+alltrim(str(xFil))+" "

	//CONOUT('AGX635NS - ITENS' )
	//CONOUT(cQuery)
	U_AGX635CN("DBG")

	If Select(cAliasSD2) <> 0
		dbSelectArea(cAliasSD2)
		(cAliasSD2)->(dbclosearea())
	Endif

	TCQuery cQuery NEW ALIAS (cAliasSD2)

	TCSETFIELD(cAliasSD2,"D2_DESC"   ,"N",12,2)

	cFil := cFilant
	U_AGX635CN("PRT")
	(cAliasSD2)->(DBGOTOP())

	While (cAliasSD2)->(!eof())

		//Valida TES
		dbselectarea('SF4')
		dbsetorder(1)
		If !(dbseek(xfilial('SF4')+alltrim((cAliasSD2)->D2_TES)))  .or. val((cAliasSD2)->D2_TES) == 0
			AADD(aLogs,{;
				{'ZDB_DBEMP'  ,(cAliasSD2)->(DBEMP)},;
				{'ZDB_DBFIL'  ,(cAliasSD2)->(DBFIL)},;
				{'ZDB_MSG'	  ,	'Doc Saída: '+alltrim(SF2->F2_DOC)+'-'+SF2->F2_SERIE+',TES invalida:'+alltrim((cAliasSD2)->(D2_TES))},;
				{'ZDB_DATA'	  ,ddatabase},;
				{'ZDB_HORA'	  ,time()},;
				{'ZDB_EMP'	  ,cEmpant},;
				{'ZDB_FILIAL' ,cFilAnt},;
				{'ZDB_INDICE' ,1},;
				{'ZDB_TAB'  ,'SF4'},;
				{'ZDB_TIPOWF'  ,5},;
				{'ZDB_CHAVE'  ,alltrim(SF2->F2_DOC)+'+'+alltrim(SF2->F2_SERIE)+'+'+alltrim((cCapaNFS)->(DBCLI))+'+'+alltrim((cCapaNFS)->(DBLOJA))};
				})

			Return .F.
		Endif

		//Valida Produto
		dbselectarea('SB1')
		dbsetorder(1)
		If ! dbseek( xfilial('SB1')+alltrim((cAliasSD2)->(D2_COD)) )
			AADD(aLogs,{;
				{'ZDB_DBEMP'  ,(cAliasSD2)->(DBEMP)},;
				{'ZDB_DBFIL'  ,(cAliasSD2)->(DBFIL)}								,;
				{'ZDB_MSG'	  ,	'Doc Saída: '+alltrim(SF2->F2_DOC)+'-'+SF2->F2_SERIE+', Produto invalido:'+alltrim((cAliasSD2)->(D2_COD))},;
				{'ZDB_DATA'	  ,ddatabase},;
				{'ZDB_HORA'	  ,time()},;
				{'ZDB_EMP'	  ,cEmpant},;
				{'ZDB_FILIAL' ,cFilAnt},;
				{'ZDB_INDICE' ,1},;
				{'ZDB_TAB'  ,'SB1'},;
				{'ZDB_TIPOWF'  ,5},;
				{'ZDB_CHAVE'  ,alltrim(SF2->F2_DOC)+'+'+alltrim(SF2->F2_SERIE)+'+'+alltrim((cCapaNFS)->(DBCLI))+'+'+alltrim((cCapaNFS)->(DBLOJA))};
				})
			Return .F.

		Endif

		(cAliasSD2)->(dbskip())
	Enddo

	(cAliasSD2)->(DBGOTOP())
	While (cAliasSD2)->(!eof())


		//Posiciona na TES
		dbselectarea('SF4')
		dbsetorder(1)
		dbseek(xfilial('SF4')+alltrim((cAliasSD2)->D2_TES))

		//Posiciona no Produto
		dbselectarea('SB1')
		dbsetorder(1)
		dbseek( xfilial('SB1')+alltrim((cAliasSD2)->(D2_COD)) )

		//Conout(' Incluindo NFS SD2: '+_cDoc+'-'+_cSerie)
		Dbselectarea('SD1')
		Dbsetorder(1)


		//Captura dados da Empresa, posicao 22 é UF
		aArrayEmp := FWArrFilAtu()
		cUFEmp    := substr( alltrim(aArrayEmp[22]) ,  len(alltrim(aArrayEmp[22]))-1,  len(alltrim(aArrayEmp[22]) ))
		cItemDOC := STRZERO((cAliasSD2)->(D2_ITEM),4)

		Begin Transaction
			RecLock("SD1", 	.T. )

			SD1->D1_FILIAL 	:= SF1->F1_FILIAL
			SD1->D1_COD		:= (cAliasSD2)->(D2_COD )
			SD1->D1_UM		:= SB1->B1_UM
			SD1->D1_LOCAL   :=  "01"
			SD1->D1_RATEIO  := "2"
			if !(alltrim(cEmpant) $ '50/03')//alltrim(cEmpant) <> '50'
				SD1->D1_DESCRI  := SB1->B1_DESC
			Endif
			SD1->D1_QUANT   := (cAliasSD2)->(D2_QUANT)
			SD1->D1_VUNIT   := (cAliasSD2)->(D2_PRCVEN)
			SD1->D1_TOTAL   := ((cAliasSD2)->D2_QUANT * (cAliasSD2)->D2_PRCVEN) //MSD1->D1_TOTAL + ROUND(MSD1->D1_DESC ,2)
			SD1->D1_VALICM  := (cAliasSD2)->(D2_VALICM)//MSD1->D1_VALICM
			SD1->D1_VALDESC	:= (cAliasSD2)->(D2_DESC)//ROUND(MSD1->D1_DESC ,2)
			SD1->D1_PICM    := (cAliasSD2)->(D2_PICM)//MSD1->D1_PICM
			SD1->D1_FORNECE := SA2->A2_COD
			SD1->D1_LOJA    := SA2->A2_LOJA//cForLoja
			SD1->D1_DOC     := SF1->F1_DOC	//cDoc
			SD1->D1_EMISSAO := SF1->F1_EMISSAO//STOD(cDataEmis)
			SD1->D1_DTDIGIT := SF1->F1_EMISSAO//STOD(cDataDigit)
			SD1->D1_SERIE   := SF1->F1_SERIE//cSerie
			SD1->D1_ITEM    := cItemDOC//STRZERO(cItemDOC,4)//cItem
			SD1->D1_TIPO    := SF1->F1_TIPO//"N"
			SD1->D1_ORIIMP  := "AGX635NS"

			//Ver cadastro de TES NO dbgint
			SD1->D1_TES     := SF4->F4_CODIGO//cTes

			cCFOP := SF4->F4_CF
			If (cCapaNFS)->(UFCLI) <> xUF
				cCFOP := '2'+substr(alltrim(SF4->F4_CF),2,3)
			Endif
			SD1->D1_CF      := cCFOP//SF4->F4_CF//cNatureza
			SD1->D1_CONTA   := SB1->B1_CONTA

			SD1->D1_DESPESA := (cAliasSD2)->(D2_DESPESA)
			SD1->D1_VALFRE  := (cAliasSD2)->(D2_VALFRE)

			//Flag se Exige CC
				/*If (cAliasPROD)->(EX_CC) == 1 
					   
				 	SD1->D1_CC := 	alltrim(str(val( (cAliasPROD)->(DOC_CC) ) ) ) 
				 	
				 	If VAL(SD1->D1_CC) == 0  .OR. alltrim(SD1->D1_CC) == ''  
						SD1->D1_CC  := 	alltrim(str(val( (cAliasPROD)->(PLACA_CC_A) ) ) ) //;CONOUT('744')				
					Endif 
			 			                             
					//Pega CC da linha do Item 
					If VAL(SD1->D1_CC) == 0  .OR. alltrim(SD1->D1_CC) == '' 
						SD1->D1_CC      := alltrim(str(val( (cAliasPROD)->(D1_CC) ) ) )   	
					Endif 
					
					If VAL(SD1->D1_CC) == 0   .OR. alltrim(SD1->D1_CC) == ''   
				   		SD1->D1_CC := 	alltrim(str(val( (cAliasPROD)->(RAT_CC) ) ) ) 
				 	Endif	
					
				    //Caso não haja Centro de Custo pega da Placa
					If VAL(SD1->D1_CC) == 0  .OR. alltrim(SD1->D1_CC) == ''  
						SD1->D1_CC := 	alltrim(str(val( (cAliasPROD)->(PLACA_CC) ) ) )  
					Endif
					      
				Endif */
				SD1->D1_BASIMP6 := (cAliasSD2)->(D2_BASIMP6)
				SD1->D1_VALIMP6 := (cAliasSD2)->(D2_VALIMP6)
				SD1->D1_ALQIMP6 := (cAliasSD2)->(D2_ALQIMP6)  
				
				SD1->D1_BASIMP5 := (cAliasSD2)->(D2_BASIMP5)
				SD1->D1_VALIMP5 := (cAliasSD2)->(D2_VALIMP5) 
				SD1->D1_ALQIMP5 := (cAliasSD2)->(D2_ALQIMP5)  
				
				//Campos de IPI
				SD1->D1_VALIPI 	:= (cAliasSD2)->(D2_VALIPI) 
		   		SD1->D1_BASEIPI := (cAliasSD2)->(D2_BASEIPI) 
				SD1->D1_IPI 	:= (cAliasSD2)->(D2_IPI) //ALIQUOTA LEMBRAR  
				 
				//Campos NFE 4.0 
				SD1->D1_BFCPANT := 0 
				SD1->D1_BSFCCMP := 0  
				SD1->D1_FCPAUX  := 0 
				SD1->D1_BASFECP := 0 
				SD1->D1_BSFCPST := 0 
				
	  			SD1->(MsUnlock()) 
	  			 
	   	End Transaction 
	      
		(cAliasSD2)->(dbskip())
	Enddo

Return lRetProd    
                      


Static Function TITEntrada(xIDNFS,xEmp,xFil)  

	Local cPrefixo  := "" 	
	Local cAliasSE2 := "AGX635SE2N"
	Local cQuery     := "" 
	    
	cQuery := " SELECT  "	
	cQuery += "	GEN_TABEMP_Codigo  	  AS DBEMP, "  
	cQuery += " GEN_TABFIL_Codigo  	  AS DBFIL, "
	cQuery += " VEN_NOTSAI_Numero  	  AS ID_NFS, "
	cQuery += " VEN_FINNFS_Parcela 	  AS E2_PARCELA,"
	cQuery += " VEN_FINNFS_Valor   	  AS E2_VALOR, "
	cQuery += " VEN_FINNFS_Vencimento AS E2_VENCTO, "
	cQuery += " CXB_TABBAN_Codigo     AS E2_BANCO"
	cQuery += " FROM VEN_FINNFS "
    cQuery += "WHERE "  
    cQuery += " VEN_NOTSAI_Numero = "+alltrim(str(xIDNFS))+" AND " 
    cQuery += " GEN_TABFIL_Codigo = "+alltrim(str(xFil))+" AND "
    cQuery += " GEN_TABEMP_Codigo = "+alltrim(str(xEmp))+" "

	U_AGX635CN("DBG")    
	//CONOUT(cQuery)
	If Select(cAliasSE2) <> 0
		dbSelectArea(cAliasSE2)
		(cAliasSE2)->(dbclosearea())
	Endif   
	
	TCQuery cQuery NEW ALIAS (cAliasSE2)  	        
	cFil := cFilant//STRZERO((cAliasSE2)->DBEMP,2) 
   
	U_AGX635CN("PRT")       
		
	//** Adequa Campo Doc e Serie         
	aTam    := {};aTam    := TamSX3("F1_DOC");     _cDoc   := PADL(alltrim((cCapaNFS)->(F2_DOC)),aTam[1],'0')     
    aTam    := {};aTam    := TamSX3("F1_SERIE")	;  _cSerie := PADR(alltrim((cCapaNFS)->(F2_SERIE)),aTam[1],' ') 
        
    //CONOUT('Inserindo SE2 '+_cDoc+' - '+_cSerie+' - '+SA2->A2_COD+SA2->A2_LOJA )
    //CONOUT('CHAVE SE2 - '+xfilial('SE2')+SF1->F1_FORNECE+SF1->F1_LOJA+SF1->F1_PREFIXO+SF1->F1_DOC )
    
    //Posiciona CLIENTE
   	SA2->(DbSetOrder(3))
	SA2->(DbGoTop())
	SA2->(DbSeek(xFilial("SA2")+(cCapaNFS)->(CNPJ_CPF)))
     
    //Posiciona no Documento    
    dbselectarea('SF1')
	SF1->(dbsetorder(1));SF1->(DbGoTop())
	SF1->(dbseek(xfilial('SF1')+_cDoc+_cSerie+SA2->A2_COD+SA2->A2_LOJA)) 
                 
     lTitBaixad := .F.                                                                                             
	//Verifica se Existe Título Gerado
    dbselectarea('SE2')
    dbsetorder(6)  // E2_FILIAL+E2_CLIENTE+E2_LOJA+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO                                                                                               
    If !dbseek(xfilial('SE2')+SF1->F1_FORNECE+SF1->F1_LOJA+SF1->F1_PREFIXO+SF1->F1_DOC)        
    	If dbseek(xfilial('SE2')+SF1->F1_FORNECE+SF1->F1_LOJA+cFilAnt+SF1->F1_PREFIXO+SF1->F1_DOC)        
          	If Empty(SE2->E2_BAIXA) .AND. alltrim(SE2->E2_TIPO = 'NDF')
          		Reclock('SE2',.F.)
          			dbdelete()
          		Msunlock() 
          	Else
          		lTitBaixad := .T.
          	Endif
    	Endif  
    Else
    	If Empty(SE2->E2_BAIXA) .AND. alltrim(SE2->E2_TIPO) = 'NDF' 
    		
    	// CONOUT('EXCLUIU  - '+SE2->E2_PREFIXO+' - '+SE2->E2_NUM+' - '+SE2->E2_FORNECE+' - '+SE2->E2_LOJA  )
    	
     		Reclock('SE2',.F.)
       			dbdelete()
       		Msunlock() 
        Else   
        	//CONOUT('JA BAIXADO  - '+SE2->E2_PREFIXO+' - '+SE2->E2_NUM+' - '+SE2->E2_FORNECE+' - '+SE2->E2_LOJA  )
       		lTitBaixad := .T.
       	Endif		
    Endif   
    
    //Se Título já foi baixado
    If lTitBaixad		 
		//GRAVA Array de LOG
    	AADD(aLogs,{;
			{'ZDB_DBEMP'  ,(cCapaNFS)->(DBEMP)},;
			{'ZDB_DBFIL'  ,(cCapaNFS)->(DBFIL)}								,;
			{'ZDB_MSG'	  ,	'Título já baixado: '+SE2->E2_FILIAL+SE2->E2_FORNECE+SE2->E2_LOJA+SE2->E2_PREFIXO+SE2->E2_NUM},;
			{'ZDB_DATA'	  ,ddatabase},;
			{'ZDB_HORA'	  ,time()},;
			{'ZDB_EMP'	  ,cEmpant},;
			{'ZDB_FILIAL' ,cFilAnt},;
			{'ZDB_DBCHAV' ,_cDoc+'+'+_cSerie+'+'+SA2->A2_COD+'+'+SA2->A2_LOJA},; 
			{'ZDB_TAB' 	  ,'SE2'},; 
			{'ZDB_INDICE' ,1	},; 
			{'ZDB_TIPOWF' ,4},; 
			{'ZDB_CHAVE'  , SE2->E2_FILIAL+SE2->E2_FORNECE+SE2->E2_LOJA+SE2->E2_PREFIXO+SE2->E2_NUM};
			})  
		Return .F.   
    Endif
	
	
	DbSelectArea(cAliasSE2)
	dbGotop()
	While (cAliasSE2)->(!eof())

		aTam     := {}
		aTam     := TamSX3("E2_NUM")
		cTitulo  := ""
		cTitulo  := SF1->F1_DOC//StrZero(MSE2->E2_NUM,aTam[1])
		cSerie   := ""
		cSerie   := substr(alltrim(SF1->F1_SERIE),1,3)        
		cForCod	 := SF1->F1_FORNECE
		cForLoja := SF1->F1_LOJA
		cForNome := POSICIONE('SA2',1,xfilial('SA2')+cForCod+cForLoja,'A2_NOME')

		cFilEnt  := SF1->F1_FILIAL
		cPrefixo := ""
		cPrefixo := substr(cSerie,1,3)
		cParcela := alltrim(cValToChar((cAliasSE2)->E2_PARCELA)) //StrZero(MSE2->E2_PARCELA,3) 
		
		dEmissao := SF1->F1_EMISSAO
		dVencto  := (cAliasSE2)->E2_VENCTO
		dDtDigit := SF1->F1_EMISSAO

		RecLock("SE2",.T.)
			SE2->E2_PREFIXO		:= cPrefixo
			SE2->E2_NUM			:= cTitulo
			SE2->E2_PARCELA  	:= cParcela
			SE2->E2_FORNECE		:= cForCod
			SE2->E2_LOJA		:= cForLoja
			SE2->E2_NOMFOR		:= cForNome
			SE2->E2_EMISSAO  	:= dEmissao
			SE2->E2_VENCTO 		:= dVencto
			SE2->E2_VENCREA		:= dVencto
			SE2->E2_VALOR		:= (cAliasSE2)->E2_VALOR
			SE2->E2_EMIS1 		:= dDtDigit//STOD(cAliasSE2)->E2_EMIS1)
			//SE2->E2_HIST		:= "AGX635NS"
			SE2->E2_LA			:= ""
			SE2->E2_SALDO		:= (cAliasSE2)->E2_VALOR
			SE2->E2_VALLIQ		:= (cAliasSE2)->E2_VALOR
			SE2->E2_VENCORI		:= dVencto
			SE2->E2_MOEDA		:= 1
			SE2->E2_VLCRUZ		:= (cAliasSE2)->E2_VALOR
			SE2->E2_ORIGEM		:= "MATA460"
			SE2->E2_NATUREZ  	:= "201010" // "101011"
			//SE2->E2_LA 			:= 'S'
			//SE2->E2_SITUACA 	:= '0'
	   		//SE2->E2_STATUS 		:= 'A'
			SE2->E2_TIPO 		:= "NF"
			SE2->E2_ORIIMP  	:= "AGX635NS"
			SE2->E2_FILORIG		:= cFilEnt
		SE2->(MsUnLock())

		dbSelectArea(cAliasSE2)
		(cAliasSE2)->(dbskip())
	EndDo

Return() 


Static Function GVErrorlog(xError)

	CONOUT('*******************')
	CONOUT('GRERRORLOG')
	CONOUT(xError:Description) 
	CONOUT('*******************')

	//GRAVA Array de LOG
	AADD(aLogs,{;
			{'ZDB_DBEMP'  ,''},;
			{'ZDB_DBFIL'  ,''},;
			{'ZDB_MSG'	  ,'ERRORLOG '+xError:Description},;
			{'ZDB_DATA'	  ,ddatabase},;
			{'ZDB_HORA'	  ,time()},;
			{'ZDB_EMP'	  ,cEmpant},;
			{'ZDB_FILIAL' ,cFilAnt},;
			{'ZDB_DBCHAV' ,'ERRORLOG'},; 
			{'ZDB_TAB' 	  ,''},; 
			{'ZDB_INDICE' ,1},;   
			{'ZDB_TIPOWF' ,8},; 
			{'ZDB_CHAVE'  ,'ERRORLOG'};
			})   

				
    // MARCA DATA/HORA PARA IDENTIFICAR QUE REGISTRO FOI IMPORTADOS 
    If Len(aIntCAPA) > 0 
		BaixarNFS(aIntCAPA) 
		aIntCAPA := {} 
    Endif 

	If len(aLogs) > 0     
 		//Grava Log
		U_AGX635LO(aLogs,'AGX635NS','IMPORTACAO NF SAIDA')
 	Endif

//		DisarmTransaction()

Return



Static Function ExcluirSE1(xPrefixo, xNum, xParcela, xTipo )

	Local _aSE1  := {}
	Local lRet   := .T.
     
	U_AGX635CN("PRT")  

	//CONOUT('AGX635NS - '+xFilial('SE1') + xPrefixo + xNum + xParcela + xTipo)
	DbSelectArea('SE1')
	DbSetOrder(1)
	If DbSeek(xFilial('SE1') + xPrefixo + xNum + xParcela + xTipo) 
	
		//CONOUT('AGX635NS - '+SE1->E1_PREFIXO+SE1->E1_NUM)

		aAdd(_aSE1, {"E1_FILIAL" , xFilial("SE1"), Nil})
		aAdd(_aSE1, {"E1_PREFIXO", SE1->E1_PREFIXO, Nil})
		aAdd(_aSE1, {"E1_NUM"    ,  SE1->E1_NUM  , Nil})
		
		lMsErroAuto := .F.
		
		MSExecAuto({|x,y| Fina040(x,y)},_aSE1,5)
		If lMsErroAuto
			//GRAVA Array de LOG
			AADD(aLogs,{;
				{'ZDB_DBEMP'  ,(cCapaNFS)->(DBEMP)},;
				{'ZDB_DBFIL'  ,(cCapaNFS)->(DBFIL)}								,;
				{'ZDB_MSG'	  ,'Exclusão Titulo inválida: '+SE1->E1_PREFIXO+SE1->E1_NUM + LerLogErro()},;
				{'ZDB_DATA'	  ,ddatabase},;
				{'ZDB_HORA'	  ,time()},;
				{'ZDB_EMP'	  ,cEmpant},;
				{'ZDB_FILIAL' ,cFilAnt},;
				{'ZDB_DBCHAV' ,SE1->E1_NUM+'+'+SE1->E1_PREFIXO+'+'+SE1->E1_CLIENTE+'+'+SE1->E1_LOJA},; 
				{'ZDB_TAB' 	  ,'SE1'},; 
				{'ZDB_INDICE' ,1	},; 
				{'ZDB_TIPOWF' ,4},; 
				{'ZDB_CHAVE'  , SE1->E1_FILIAL+SE1->E1_CLIENTE+SE1->E1_LOJA+SE1->E1_PREFIXO+SE1->E1_NUM};
				})  	
			lRet  := .F.
		Else
			Conout("Titulo Gerado com Sucesso:  " + SE1->E1_PREFIXO +' / '+SE1->E1_NUM, SE1->E1_PREFIXO +' / '+SE1->E1_NUM )
		Endif 
	Endif
	
	

Return lRet 


//Funcão Criada para Avaliar o problema de não inclusão de nota de debito 
User Function AGX635NZ(xdata)

	Local dUlmes    := GetMv('MV_ULMES')
	Local cQuery    := ""
	Local cCapaNFS  := "AGX635NZD"
	Local cGetPRT   := "AGX635NZP"
	Local cQueryPrt := ""
	Local cTipoNf   := ""
	Local cTitNimp  := ""
	Local aTam      := {} 
	Local cChaveFlag   := ""
	Local cUpdDbg    := ""

	cQuery := " SELECT"
	cQuery += "  replace(replace(replace(FILIAL.GEN_TABFIL_CNPJ,'.',''),'/',''),'-','')    		AS CNPJFIL ,"+CHR(13)
	cQuery += " CAST(VEN_NOTSAI.GEN_TABEMP_Codigo as char) 	AS 	DBEMP  ,"+CHR(13)
	cQuery += "  CAST(VEN_NOTSAI.GEN_TABFIL_Codigo as char) 	AS 	DBFIL  ,"+CHR(13)
	//cQuery += " GEN_ESTMUN_Estado    			AS  UFCLI ,"+CHR(13)
	cQuery += " VEN_NOTSAI.GEN_NATOPE_Codigo    AS  NATOP, "+CHR(13)
	cQuery +="  GEN_NATOPE_TES 					AS D2_TES  ,"+CHR(13)//  TES Protheus 
	cQuery += " ENDENT.GEN_ENDENT_IF     AS  	CNPJ_CPF   ,"+CHR(13)
	cQuery += " VEN_NOTSAI.VEN_NOTSAI_Numero	AS 	ID     ,"+CHR(13)
	//cQuery += " VEN_NOTSAI_Emissao		 AS 	F2_EMISSAO ,"+CHR(13)
	cQuery += " VEN_NFSEMI_Emissao	AS 	F2_EMISSAO ,"+CHR(13)
	cQuery += " VEN_NOTSAI_TipoNF		 AS 	F2_TIPO    ,"+CHR(13)
	cQuery += " VEN_NOTSAI_FilialDest	 AS 	TRANSFER   ,"+CHR(13)
	cQuery += " VEN_NOTSAI_Cli_Cod		 AS 	DBCLI      ,"+CHR(13)
	cQuery += " VEN_NOTSAI_ECL_Cod		 AS 	DBLOJA     ,"+CHR(13)
	cQuery += " VEN_NOTSAI_Tra_Cod		 AS 	DBTRANS    ,"+CHR(13)
	cQuery += " VEN_NOTSAI_ETr_Cod		 AS 	DBTRANSLOJ ,"+CHR(13)
	cQuery += " VEN_NOTSAI_BIPI			 AS 	F2_BASEIPI ,"+CHR(13)
	cQuery += " VEN_NOTSAI_IPI			 AS 	F2_VALIPI  ,"+CHR(13)
	cQuery += " VEN_NOTSAI_ValorProd	 AS 	F2_VALMERC ,"+CHR(13)
	cQuery += " VEN_NOTSAI_ValorNF		 AS     F2_VALBRUT ,"+CHR(13)
	cQuery += " VEN_NOTSAI_INSS			 AS 	F2_VALINSS ,"+CHR(13)
	cQuery += " VEN_NOTSAI_PIS			 AS 	F2_VALIMP6  ,"+CHR(13)
	cQuery += " VEN_NOTSAI_Cofins		 AS 	F2_VALIMP5 ,"+CHR(13)
	cQuery += " VEN_NOTSAI_CSLL			 AS 	F2_VALCSLL ,"+CHR(13)
	cQuery += " VEN_NOTSAI_BaseST		 AS 	F2_BRICMS  ,"+CHR(13)
	cQuery += " VEN_NOTSAI_ValorST		 AS 	F2_ICMSRET ,"+CHR(13)
	cQuery += " VEN_NOTSAI_PesoLiq		 AS 	F2_PLIQUI  ,"+CHR(13)//--F2_PESOL
	cQuery += " VEN_NOTSAI_PesoBruto	 AS 	F2_PBRUTO  ,"+CHR(13)
	cQuery += " VEN_NOTSAI_Placa		 AS 	F2_PLACA   ,"+CHR(13)
	cQuery += " VEN_NOTSAI_TipoFrete	 AS 	F2_TPFRETE ,"+CHR(13)
	cQuery += " VEN_NOTSAI_ValorFrete	 AS 	F2_VALROMA ,"+CHR(13)
	cQuery += " VEN_NOTSAI_ValorSeguro	 AS 	F2_SEGURO  ,"+CHR(13)
	cQuery += " VEN_NOTSAI_ISS			 AS 	F2_VALISS  ,"+CHR(13)
	cQuery += " VEN_NOTSAI_IRRF			 AS 	F2_VALIRRF ,"+CHR(13) 
	cQuery += " VEN_NOTSAI_BPIS			 AS 	F2_BASIMP6  ,"+CHR(13)
	cQuery += " VEN_NOTSAI_BCSLL		 AS 	F2_BASCSLL ,"+CHR(13)
	cQuery += " VEN_NOTSAI_BCOFINS		 AS 	F2_BASIMP5 ,"+CHR(13)
	cQuery += " VEN_NOTSAI_QtdVolume	 AS 	F2_VOLUME1 ,"+CHR(13)
	cQuery += " VEN_NOTSAI_EspecieVolume AS 	F2_ESPECI1 ,"+CHR(13)
	cQuery += " VEN_NOTSAI_ICMS          AS     F2_VALICM  ,"+CHR(13)  
	cQuery += " VEN_NOTSAI_BICMS 		 AS     F2_BASEICM ,"+CHR(13)  
	cQuery += " CAST(VEN_NFSEMI_Numero AS  CHAR)  AS 	F2_DOC	   ,"+CHR(13)
	cQuery += " CAST(VEN_NFSEMI_Serie AS  CHAR)   AS 	F2_SERIE, "	+CHR(13)  
	cQuery += " VEN_NOTSAI_FilialDest    AS     FILDEST , "	+CHR(13) 
	cQuery += " VEN_NFSEMI_RXMotivo      AS MSG_MOT, "+CHR(13)  
	cQuery += " VEN_NFSEMI_Cancelada     AS CANCELA, "+CHR(13)
	cQuery += " VEN_NFSEMI_NChNFe        AS F2_CHVNFE, "+CHR(13) 
	cQuery += " VEN_NOTSAI_ValorFrete    AS F2_FRETE, "+CHR(13)
	cQuery += " VEN_NOTSAI_ValorDespAc   AS F2_DESPESA, "+CHR(13)
	cQuery += " VEN_NFSEMI_DataCanc      AS DT_CANC  "+CHR(13)
	
	cQuery += " FROM VEN_NOTSAI VEN_NOTSAI" +chr(13)  
	cQuery += " INNER JOIN GEN_TABFIL FILIAL ON VEN_NOTSAI.GEN_TABEMP_Codigo = FILIAL.GEN_TABEMP_Codigo	 "+CHR(13)
	cQuery += " AND  VEN_NOTSAI.GEN_TABFIL_Codigo = FILIAL.GEN_TABFIL_Codigo "+CHR(13)
	cQuery += " INNER JOIN GEN_NATOPE GEN_NATOPE ON VEN_NOTSAI.GEN_NATOPE_Codigo = GEN_NATOPE.GEN_NATOPE_Codigo "+chr(13)  
	cQuery += " INNER JOIN GEN_ENDENT ENDENT ON GEN_TABENT_CODIGO = VEN_NOTSAI_Cli_Cod "+CHR(13) 
   	cQuery += " AND GEN_ENDENT_Codigo = VEN_NOTSAI_ECL_Cod   "+CHR(13) 
	cQuery += " INNER JOIN VEN_NFSEMI VEN_NFSEMI ON VEN_NFSEMI.VEN_NOTSAI_Numero = VEN_NOTSAI.VEN_NOTSAI_Numero " +CHR(13)
	cQuery += " AND VEN_NOTSAI.GEN_TABEMP_Codigo = VEN_NFSEMI.GEN_TABEMP_Codigo  "+CHR(13)
	cQuery += " AND VEN_NOTSAI.GEN_TABFIL_Codigo = VEN_NFSEMI.GEN_TABFIL_Codigo  "+CHR(13)
	cQuery += " WHERE "
	cQuery += " VEN_NOTSAI_DHIntTotvs is NOT NULL AND VEN_NFSEMI_Cancelada <> 'S' "
	//(VEN_NOTSAI_DHIntTotvs IS NULL OR VEN_NOTSAI_DHIntTotvs = '1000-01-01 00:00:00' )AND " +CHR(13)
	//cQuery += " AND VEN_NOTSAI.GEN_TABEMP_Codigo = " + cValToChar(nEmpOrigem)  
	cQuery += " AND (VEN_NFSEMI_NCStat IN ('100','101','102') OR ( VEN_NOTSAI_TipoNF = 'S' OR VEN_NOTSAI_TipoNF = 'B' ))"	 +CHR(13) 
	//Caso filtre por filial inclui o campo
	//If nFilOrigem <> 0  
	//	cQuery += " AND  VEN_NOTSAI.GEN_TABFIL_Codigo = " + cValToChar(nFilOrigem)
    //Endif
	cQuery += " AND VEN_NOTSAI_Emissao >= '"+ dtos(dUlmes)+"' "

	U_AGX635CN("DBG")    
	
  	If Select(cCapaNFS) <> 0
  		dbSelectArea(cCapaNFS)
   		(cCapaNFS)->(dbCloseArea())
  	Endif

 	TCQuery cQuery NEW ALIAS (cCapaNFS) 
 	
 	TCSETFIELD(cCapaNFS,"DBCLI"   ,"N",14,0) 
 	TCSETFIELD(cCapaNFS,"DBTRANS" ,"N",14,0) 
 	TCSETFIELD(cCapaNFS,"F2_VALMERC"   ,"N",14,2)  
 	TCSETFIELD(cCapaNFS,"F2_VALBRUT"   ,"N",14,2) 	
 	TCSETFIELD(cCapaNFS,"F2_BASIMP6"   ,"N",14,2) 
	TCSETFIELD(cCapaNFS,"F2_VALIMP6"   ,"N",14,2) 
	TCSETFIELD(cCapaNFS,"F2_BASIMP5"   ,"N",14,2) 
	
	U_AGX635CN("PRT") 
	
	While   (cCapaNFS)->(!eof())

		If alltrim((cCapaNFS)->F2_TIPO ) == 'V'  .OR. alltrim((cCapaNFS)->F2_TIPO ) == 'T' .OR. alltrim((cCapaNFS)->F2_TIPO ) == 'S' 
			cTipoNf := 'N'
		Elseif alltrim((cCapaNFS)->F2_TIPO ) == 'M' .OR. alltrim((cCapaNFS)->F2_TIPO ) == 'D' 
			cTipoNf := 'D' 
		Elseif alltrim((cCapaNFS)->F2_TIPO ) == 'P'
		  	cTipoNf := 'C'    
		Elseif alltrim((cCapaNFS)->F2_TIPO ) == 'E'    
	   		cTipoNf := 'E' 
		Else 
			cTipoNf := (cCapaNFS)->F2_TIPO
		Endif

		aTam    := TamSX3("F2_DOC")
		
		iF cTipoNf == 'B' 
	
			cTipoPRT := 'NDC'
	
			_cDoc   := PADL(alltrim((cCapaNFS)->(F2_DOC)),aTam[1],'0') 
			cQueryPrt := " SELECT E1_PREFIXO, E1_NUM, E1_SERIE, E1_VALOR, EMP_FIL, EMP_COD FROM "+RetSqlName('SE1')+"(NOLOCK) "
			cQueryPrt += " LEFT JOIN EMPRESAS ON EMP_CNPJ = '"+ (cCapaNFS)->CNPJFIL+"' AND EMP_COD = '01' "
			cQueryPrt += " WHERE E1_NUM = '"+_cDoc+ "' "
			cQueryPrt += " AND E1_SERIE  = '" +(cCapaNFS)->F2_SERIE+ "' "
			cQueryPrt += " AND E1_TIPO = '"+cTipoPRT+"' "
			cQueryPrt += " AND E1_FILORIG = EMP_FIL "
			cQueryPrt += " AND D_E_L_E_T_ = '' "

			If Select(cGetPRT) <> 0
  				dbSelectArea(cGetPRT)
   				(cGetPRT)->(dbCloseArea())
  			Endif

 			TCQuery cQueryPrt NEW ALIAS (cGetPRT) 

			If (cGetPRT)->(Eof()) .or. alltrim((cGetPRT)->E1_NUM) == ''
				cTitNimp   +="Fil(DBG)- Pre Nota - Doc-Serie-Tipo: "+(cCapaNFS)->DBFIL+'-'+cValtochar((cCapaNFS)->ID) +'-'+(cCapaNFS)->F2_DOC+'-'+(cCapaNFS)->F2_SERIE +'-'+ cTipoNf + chr(10)+ chr(13)
				cChaveFlag += " (GEN_TABEMP_Codigo = "+(cCapaNFS)->DBEMP+" AND GEN_TABFIL_Codigo = "+(cCapaNFS)->DBFIL+"  "
				cChaveFlag += " AND VEN_NOTSAI_Numero =  "+cvaltochar((cCapaNFS)->ID)+" )    OR  "
			Endif 

		Endif

		(cCapaNFS)->(dbskip())
	Enddo 


	iF alltrim(cTitNimp) <> ''
		
		u_msgmemo("NOTAS DE SAIDA ",cTitNimp,.f.)

		If MsgYesNo("Deseja Limpar a Flag para importação ? ", "DbGint")
			U_AGX635CN("DBG") 
			cUpdDbg := " UPDATE VEN_NOTSAI SET VEN_NOTSAI_DHIntTotvs = NULL"
			cUpdDbg += " WHERE "
			cUpdDbg +=   Substr(cChaveFlag,1,len(cChaveFlag) - 5) 
			
			If (TCSQLExec(cUpdDbg) < 0)
				Alert("Falha ao executar SQL: " + cUpdDbg + "TCSQLError() - " + TCSQLError())
			else
				u_msgmemo("UPDATE EXECUTADO",cUpdDbg,.f.)
			EndIf  

			EditTxt("\logs\AGX635NS.log",dtos(date())+" "+"AGX635NZ: "+cUpdDbg)
			U_AGX635CN("PRT") 
		Endif 
	Else 
		Alert("Nenhuma inconsistencia a partir do ultimo fechamento "+dtos(dUlmes))
	Endif 

Return 


Static Function EditTxt(_cArq,_cInfo) //_cArq: Nome do arquivo ja com extensao //_cInfo: Informacao a ser gravada

	Local _nHdl

	If File(_cArq)
		_nHdl = fopen(_cArq,1)
	Else
		_nHdl = fcreate(_cArq,0)
	Endif
	
	fseek (_nHdl,0,2)  // Encontra final do arquivo
	fwrite(_nHdl,_cInfo+chr(13)+chr(10))
	fclose(_nHdl)

Return(.T.)
